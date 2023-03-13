
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
  80003b:	68 20 22 80 00       	push   $0x802220
  800040:	e8 e4 02 00 00       	call   800329 <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 fe 1b 00 00       	call   801c4e <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	78 59                	js     8000b0 <umain+0x7d>
		panic("pipe: %e", r);
	max = 200;
	if ((r = fork()) < 0)
  800057:	e8 92 0f 00 00       	call   800fee <fork>
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
  800068:	68 71 22 80 00       	push   $0x802271
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
  800088:	68 7c 22 80 00       	push   $0x80227c
  80008d:	e8 97 02 00 00       	call   800329 <cprintf>
	dup(p[0], 10);
  800092:	83 c4 08             	add    $0x8,%esp
  800095:	6a 0a                	push   $0xa
  800097:	ff 75 f0             	push   -0x10(%ebp)
  80009a:	e8 b4 13 00 00       	call   801453 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  80009f:	83 c4 10             	add    $0x10,%esp
  8000a2:	6b de 7c             	imul   $0x7c,%esi,%ebx
  8000a5:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8000ab:	e9 92 00 00 00       	jmp    800142 <umain+0x10f>
		panic("pipe: %e", r);
  8000b0:	50                   	push   %eax
  8000b1:	68 39 22 80 00       	push   $0x802239
  8000b6:	6a 0d                	push   $0xd
  8000b8:	68 42 22 80 00       	push   $0x802242
  8000bd:	e8 8c 01 00 00       	call   80024e <_panic>
		panic("fork: %e", r);
  8000c2:	50                   	push   %eax
  8000c3:	68 18 27 80 00       	push   $0x802718
  8000c8:	6a 10                	push   $0x10
  8000ca:	68 42 22 80 00       	push   $0x802242
  8000cf:	e8 7a 01 00 00       	call   80024e <_panic>
		close(p[1]);
  8000d4:	83 ec 0c             	sub    $0xc,%esp
  8000d7:	ff 75 f4             	push   -0xc(%ebp)
  8000da:	e8 22 13 00 00       	call   801401 <close>
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
  8000f9:	e8 9a 1c 00 00       	call   801d98 <pipeisclosed>
  8000fe:	83 c4 10             	add    $0x10,%esp
  800101:	85 c0                	test   %eax,%eax
  800103:	74 e4                	je     8000e9 <umain+0xb6>
				cprintf("RACE: pipe appears closed\n");
  800105:	83 ec 0c             	sub    $0xc,%esp
  800108:	68 56 22 80 00       	push   $0x802256
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
  800125:	e8 44 10 00 00       	call   80116e <ipc_recv>
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	e9 32 ff ff ff       	jmp    800064 <umain+0x31>
		dup(p[0], 10);
  800132:	83 ec 08             	sub    $0x8,%esp
  800135:	6a 0a                	push   $0xa
  800137:	ff 75 f0             	push   -0x10(%ebp)
  80013a:	e8 14 13 00 00       	call   801453 <dup>
  80013f:	83 c4 10             	add    $0x10,%esp
	while (kid->env_status == ENV_RUNNABLE)
  800142:	8b 43 54             	mov    0x54(%ebx),%eax
  800145:	83 f8 02             	cmp    $0x2,%eax
  800148:	74 e8                	je     800132 <umain+0xff>

	cprintf("child done with loop\n");
  80014a:	83 ec 0c             	sub    $0xc,%esp
  80014d:	68 87 22 80 00       	push   $0x802287
  800152:	e8 d2 01 00 00       	call   800329 <cprintf>
	if (pipeisclosed(p[0]))
  800157:	83 c4 04             	add    $0x4,%esp
  80015a:	ff 75 f0             	push   -0x10(%ebp)
  80015d:	e8 36 1c 00 00       	call   801d98 <pipeisclosed>
  800162:	83 c4 10             	add    $0x10,%esp
  800165:	85 c0                	test   %eax,%eax
  800167:	75 48                	jne    8001b1 <umain+0x17e>
		panic("somehow the other end of p[0] got closed!");
	if ((r = fd_lookup(p[0], &fd)) < 0)
  800169:	83 ec 08             	sub    $0x8,%esp
  80016c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80016f:	50                   	push   %eax
  800170:	ff 75 f0             	push   -0x10(%ebp)
  800173:	e8 61 11 00 00       	call   8012d9 <fd_lookup>
  800178:	83 c4 10             	add    $0x10,%esp
  80017b:	85 c0                	test   %eax,%eax
  80017d:	78 46                	js     8001c5 <umain+0x192>
		panic("cannot look up p[0]: %e", r);
	va = fd2data(fd);
  80017f:	83 ec 0c             	sub    $0xc,%esp
  800182:	ff 75 ec             	push   -0x14(%ebp)
  800185:	e8 e8 10 00 00       	call   801272 <fd2data>
	if (pageref(va) != 3+1)
  80018a:	89 04 24             	mov    %eax,(%esp)
  80018d:	e8 b3 18 00 00       	call   801a45 <pageref>
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	83 f8 04             	cmp    $0x4,%eax
  800198:	74 3d                	je     8001d7 <umain+0x1a4>
		cprintf("\nchild detected race\n");
  80019a:	83 ec 0c             	sub    $0xc,%esp
  80019d:	68 b5 22 80 00       	push   $0x8022b5
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
  8001b4:	68 e0 22 80 00       	push   $0x8022e0
  8001b9:	6a 3a                	push   $0x3a
  8001bb:	68 42 22 80 00       	push   $0x802242
  8001c0:	e8 89 00 00 00       	call   80024e <_panic>
		panic("cannot look up p[0]: %e", r);
  8001c5:	50                   	push   %eax
  8001c6:	68 9d 22 80 00       	push   $0x80229d
  8001cb:	6a 3c                	push   $0x3c
  8001cd:	68 42 22 80 00       	push   $0x802242
  8001d2:	e8 77 00 00 00       	call   80024e <_panic>
		cprintf("\nrace didn't happen\n", max);
  8001d7:	83 ec 08             	sub    $0x8,%esp
  8001da:	68 c8 00 00 00       	push   $0xc8
  8001df:	68 cb 22 80 00       	push   $0x8022cb
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
  80023a:	e8 ef 11 00 00       	call   80142e <close_all>
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
  80026c:	68 14 23 80 00       	push   $0x802314
  800271:	e8 b3 00 00 00       	call   800329 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800276:	83 c4 18             	add    $0x18,%esp
  800279:	53                   	push   %ebx
  80027a:	ff 75 10             	push   0x10(%ebp)
  80027d:	e8 56 00 00 00       	call   8002d8 <vcprintf>
	cprintf("\n");
  800282:	c7 04 24 37 22 80 00 	movl   $0x802237,(%esp)
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
  80038b:	e8 50 1c 00 00       	call   801fe0 <__udivdi3>
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
  8003c9:	e8 32 1d 00 00       	call   802100 <__umoddi3>
  8003ce:	83 c4 14             	add    $0x14,%esp
  8003d1:	0f be 80 37 23 80 00 	movsbl 0x802337(%eax),%eax
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
  80048b:	ff 24 85 80 24 80 00 	jmp    *0x802480(,%eax,4)
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
  800559:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  800560:	85 d2                	test   %edx,%edx
  800562:	74 18                	je     80057c <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800564:	52                   	push   %edx
  800565:	68 fd 27 80 00       	push   $0x8027fd
  80056a:	53                   	push   %ebx
  80056b:	56                   	push   %esi
  80056c:	e8 92 fe ff ff       	call   800403 <printfmt>
  800571:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800574:	89 7d 14             	mov    %edi,0x14(%ebp)
  800577:	e9 66 02 00 00       	jmp    8007e2 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80057c:	50                   	push   %eax
  80057d:	68 4f 23 80 00       	push   $0x80234f
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
  8005a4:	b8 48 23 80 00       	mov    $0x802348,%eax
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
  800cb0:	68 3f 26 80 00       	push   $0x80263f
  800cb5:	6a 2a                	push   $0x2a
  800cb7:	68 5c 26 80 00       	push   $0x80265c
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
  800d31:	68 3f 26 80 00       	push   $0x80263f
  800d36:	6a 2a                	push   $0x2a
  800d38:	68 5c 26 80 00       	push   $0x80265c
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
  800d73:	68 3f 26 80 00       	push   $0x80263f
  800d78:	6a 2a                	push   $0x2a
  800d7a:	68 5c 26 80 00       	push   $0x80265c
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
  800db5:	68 3f 26 80 00       	push   $0x80263f
  800dba:	6a 2a                	push   $0x2a
  800dbc:	68 5c 26 80 00       	push   $0x80265c
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
  800df7:	68 3f 26 80 00       	push   $0x80263f
  800dfc:	6a 2a                	push   $0x2a
  800dfe:	68 5c 26 80 00       	push   $0x80265c
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
  800e39:	68 3f 26 80 00       	push   $0x80263f
  800e3e:	6a 2a                	push   $0x2a
  800e40:	68 5c 26 80 00       	push   $0x80265c
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
  800e7b:	68 3f 26 80 00       	push   $0x80263f
  800e80:	6a 2a                	push   $0x2a
  800e82:	68 5c 26 80 00       	push   $0x80265c
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
  800edf:	68 3f 26 80 00       	push   $0x80263f
  800ee4:	6a 2a                	push   $0x2a
  800ee6:	68 5c 26 80 00       	push   $0x80265c
  800eeb:	e8 5e f3 ff ff       	call   80024e <_panic>

00800ef0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	56                   	push   %esi
  800ef4:	53                   	push   %ebx
  800ef5:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ef8:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800efa:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800efe:	0f 84 8e 00 00 00    	je     800f92 <pgfault+0xa2>
  800f04:	89 f0                	mov    %esi,%eax
  800f06:	c1 e8 0c             	shr    $0xc,%eax
  800f09:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f10:	f6 c4 08             	test   $0x8,%ah
  800f13:	74 7d                	je     800f92 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800f15:	e8 a7 fd ff ff       	call   800cc1 <sys_getenvid>
  800f1a:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800f1c:	83 ec 04             	sub    $0x4,%esp
  800f1f:	6a 07                	push   $0x7
  800f21:	68 00 f0 7f 00       	push   $0x7ff000
  800f26:	50                   	push   %eax
  800f27:	e8 d3 fd ff ff       	call   800cff <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f2c:	83 c4 10             	add    $0x10,%esp
  800f2f:	85 c0                	test   %eax,%eax
  800f31:	78 73                	js     800fa6 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800f33:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800f39:	83 ec 04             	sub    $0x4,%esp
  800f3c:	68 00 10 00 00       	push   $0x1000
  800f41:	56                   	push   %esi
  800f42:	68 00 f0 7f 00       	push   $0x7ff000
  800f47:	e8 4d fb ff ff       	call   800a99 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800f4c:	83 c4 08             	add    $0x8,%esp
  800f4f:	56                   	push   %esi
  800f50:	53                   	push   %ebx
  800f51:	e8 2e fe ff ff       	call   800d84 <sys_page_unmap>
  800f56:	83 c4 10             	add    $0x10,%esp
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	78 5b                	js     800fb8 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800f5d:	83 ec 0c             	sub    $0xc,%esp
  800f60:	6a 07                	push   $0x7
  800f62:	56                   	push   %esi
  800f63:	53                   	push   %ebx
  800f64:	68 00 f0 7f 00       	push   $0x7ff000
  800f69:	53                   	push   %ebx
  800f6a:	e8 d3 fd ff ff       	call   800d42 <sys_page_map>
  800f6f:	83 c4 20             	add    $0x20,%esp
  800f72:	85 c0                	test   %eax,%eax
  800f74:	78 54                	js     800fca <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800f76:	83 ec 08             	sub    $0x8,%esp
  800f79:	68 00 f0 7f 00       	push   $0x7ff000
  800f7e:	53                   	push   %ebx
  800f7f:	e8 00 fe ff ff       	call   800d84 <sys_page_unmap>
  800f84:	83 c4 10             	add    $0x10,%esp
  800f87:	85 c0                	test   %eax,%eax
  800f89:	78 51                	js     800fdc <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800f8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800f92:	83 ec 04             	sub    $0x4,%esp
  800f95:	68 6c 26 80 00       	push   $0x80266c
  800f9a:	6a 1d                	push   $0x1d
  800f9c:	68 e8 26 80 00       	push   $0x8026e8
  800fa1:	e8 a8 f2 ff ff       	call   80024e <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800fa6:	50                   	push   %eax
  800fa7:	68 a4 26 80 00       	push   $0x8026a4
  800fac:	6a 29                	push   $0x29
  800fae:	68 e8 26 80 00       	push   $0x8026e8
  800fb3:	e8 96 f2 ff ff       	call   80024e <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800fb8:	50                   	push   %eax
  800fb9:	68 c8 26 80 00       	push   $0x8026c8
  800fbe:	6a 2e                	push   $0x2e
  800fc0:	68 e8 26 80 00       	push   $0x8026e8
  800fc5:	e8 84 f2 ff ff       	call   80024e <_panic>
		panic("pgfault: page map failed (%e)", r);
  800fca:	50                   	push   %eax
  800fcb:	68 f3 26 80 00       	push   $0x8026f3
  800fd0:	6a 30                	push   $0x30
  800fd2:	68 e8 26 80 00       	push   $0x8026e8
  800fd7:	e8 72 f2 ff ff       	call   80024e <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800fdc:	50                   	push   %eax
  800fdd:	68 c8 26 80 00       	push   $0x8026c8
  800fe2:	6a 32                	push   $0x32
  800fe4:	68 e8 26 80 00       	push   $0x8026e8
  800fe9:	e8 60 f2 ff ff       	call   80024e <_panic>

00800fee <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800fee:	55                   	push   %ebp
  800fef:	89 e5                	mov    %esp,%ebp
  800ff1:	57                   	push   %edi
  800ff2:	56                   	push   %esi
  800ff3:	53                   	push   %ebx
  800ff4:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800ff7:	68 f0 0e 80 00       	push   $0x800ef0
  800ffc:	e8 3e 0f 00 00       	call   801f3f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801001:	b8 07 00 00 00       	mov    $0x7,%eax
  801006:	cd 30                	int    $0x30
  801008:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  80100b:	83 c4 10             	add    $0x10,%esp
  80100e:	85 c0                	test   %eax,%eax
  801010:	78 2d                	js     80103f <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801012:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  801017:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80101b:	75 73                	jne    801090 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  80101d:	e8 9f fc ff ff       	call   800cc1 <sys_getenvid>
  801022:	25 ff 03 00 00       	and    $0x3ff,%eax
  801027:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80102a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80102f:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  801034:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  801037:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80103a:	5b                   	pop    %ebx
  80103b:	5e                   	pop    %esi
  80103c:	5f                   	pop    %edi
  80103d:	5d                   	pop    %ebp
  80103e:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  80103f:	50                   	push   %eax
  801040:	68 11 27 80 00       	push   $0x802711
  801045:	6a 78                	push   $0x78
  801047:	68 e8 26 80 00       	push   $0x8026e8
  80104c:	e8 fd f1 ff ff       	call   80024e <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  801051:	83 ec 0c             	sub    $0xc,%esp
  801054:	ff 75 e4             	push   -0x1c(%ebp)
  801057:	57                   	push   %edi
  801058:	ff 75 dc             	push   -0x24(%ebp)
  80105b:	57                   	push   %edi
  80105c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80105f:	56                   	push   %esi
  801060:	e8 dd fc ff ff       	call   800d42 <sys_page_map>
	if(r<0) return r;
  801065:	83 c4 20             	add    $0x20,%esp
  801068:	85 c0                	test   %eax,%eax
  80106a:	78 cb                	js     801037 <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  80106c:	83 ec 0c             	sub    $0xc,%esp
  80106f:	ff 75 e4             	push   -0x1c(%ebp)
  801072:	57                   	push   %edi
  801073:	56                   	push   %esi
  801074:	57                   	push   %edi
  801075:	56                   	push   %esi
  801076:	e8 c7 fc ff ff       	call   800d42 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  80107b:	83 c4 20             	add    $0x20,%esp
  80107e:	85 c0                	test   %eax,%eax
  801080:	78 76                	js     8010f8 <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801082:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801088:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80108e:	74 75                	je     801105 <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  801090:	89 d8                	mov    %ebx,%eax
  801092:	c1 e8 16             	shr    $0x16,%eax
  801095:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80109c:	a8 01                	test   $0x1,%al
  80109e:	74 e2                	je     801082 <fork+0x94>
  8010a0:	89 de                	mov    %ebx,%esi
  8010a2:	c1 ee 0c             	shr    $0xc,%esi
  8010a5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010ac:	a8 01                	test   $0x1,%al
  8010ae:	74 d2                	je     801082 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  8010b0:	e8 0c fc ff ff       	call   800cc1 <sys_getenvid>
  8010b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  8010b8:	89 f7                	mov    %esi,%edi
  8010ba:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  8010bd:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010c4:	89 c1                	mov    %eax,%ecx
  8010c6:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  8010cc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  8010cf:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  8010d6:	f6 c6 04             	test   $0x4,%dh
  8010d9:	0f 85 72 ff ff ff    	jne    801051 <fork+0x63>
		perm &= ~PTE_W;
  8010df:	25 05 0e 00 00       	and    $0xe05,%eax
  8010e4:	80 cc 08             	or     $0x8,%ah
  8010e7:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  8010ed:	0f 44 c1             	cmove  %ecx,%eax
  8010f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010f3:	e9 59 ff ff ff       	jmp    801051 <fork+0x63>
  8010f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8010fd:	0f 4f c2             	cmovg  %edx,%eax
  801100:	e9 32 ff ff ff       	jmp    801037 <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801105:	83 ec 04             	sub    $0x4,%esp
  801108:	6a 07                	push   $0x7
  80110a:	68 00 f0 bf ee       	push   $0xeebff000
  80110f:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801112:	57                   	push   %edi
  801113:	e8 e7 fb ff ff       	call   800cff <sys_page_alloc>
	if(r<0) return r;
  801118:	83 c4 10             	add    $0x10,%esp
  80111b:	85 c0                	test   %eax,%eax
  80111d:	0f 88 14 ff ff ff    	js     801037 <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801123:	83 ec 08             	sub    $0x8,%esp
  801126:	68 b5 1f 80 00       	push   $0x801fb5
  80112b:	57                   	push   %edi
  80112c:	e8 19 fd ff ff       	call   800e4a <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801131:	83 c4 10             	add    $0x10,%esp
  801134:	85 c0                	test   %eax,%eax
  801136:	0f 88 fb fe ff ff    	js     801037 <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80113c:	83 ec 08             	sub    $0x8,%esp
  80113f:	6a 02                	push   $0x2
  801141:	57                   	push   %edi
  801142:	e8 7f fc ff ff       	call   800dc6 <sys_env_set_status>
	if(r<0) return r;
  801147:	83 c4 10             	add    $0x10,%esp
	return envid;
  80114a:	85 c0                	test   %eax,%eax
  80114c:	0f 49 c7             	cmovns %edi,%eax
  80114f:	e9 e3 fe ff ff       	jmp    801037 <fork+0x49>

00801154 <sfork>:

// Challenge!
int
sfork(void)
{
  801154:	55                   	push   %ebp
  801155:	89 e5                	mov    %esp,%ebp
  801157:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80115a:	68 21 27 80 00       	push   $0x802721
  80115f:	68 a1 00 00 00       	push   $0xa1
  801164:	68 e8 26 80 00       	push   $0x8026e8
  801169:	e8 e0 f0 ff ff       	call   80024e <_panic>

0080116e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	56                   	push   %esi
  801172:	53                   	push   %ebx
  801173:	8b 75 08             	mov    0x8(%ebp),%esi
  801176:	8b 45 0c             	mov    0xc(%ebp),%eax
  801179:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80117c:	85 c0                	test   %eax,%eax
  80117e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801183:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801186:	83 ec 0c             	sub    $0xc,%esp
  801189:	50                   	push   %eax
  80118a:	e8 20 fd ff ff       	call   800eaf <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	85 f6                	test   %esi,%esi
  801194:	74 14                	je     8011aa <ipc_recv+0x3c>
  801196:	ba 00 00 00 00       	mov    $0x0,%edx
  80119b:	85 c0                	test   %eax,%eax
  80119d:	78 09                	js     8011a8 <ipc_recv+0x3a>
  80119f:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8011a5:	8b 52 74             	mov    0x74(%edx),%edx
  8011a8:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8011aa:	85 db                	test   %ebx,%ebx
  8011ac:	74 14                	je     8011c2 <ipc_recv+0x54>
  8011ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	78 09                	js     8011c0 <ipc_recv+0x52>
  8011b7:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8011bd:	8b 52 78             	mov    0x78(%edx),%edx
  8011c0:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	78 08                	js     8011ce <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  8011c6:	a1 00 40 80 00       	mov    0x804000,%eax
  8011cb:	8b 40 70             	mov    0x70(%eax),%eax
}
  8011ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011d1:	5b                   	pop    %ebx
  8011d2:	5e                   	pop    %esi
  8011d3:	5d                   	pop    %ebp
  8011d4:	c3                   	ret    

008011d5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	57                   	push   %edi
  8011d9:	56                   	push   %esi
  8011da:	53                   	push   %ebx
  8011db:	83 ec 0c             	sub    $0xc,%esp
  8011de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8011e7:	85 db                	test   %ebx,%ebx
  8011e9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8011ee:	0f 44 d8             	cmove  %eax,%ebx
  8011f1:	eb 05                	jmp    8011f8 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8011f3:	e8 e8 fa ff ff       	call   800ce0 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8011f8:	ff 75 14             	push   0x14(%ebp)
  8011fb:	53                   	push   %ebx
  8011fc:	56                   	push   %esi
  8011fd:	57                   	push   %edi
  8011fe:	e8 89 fc ff ff       	call   800e8c <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801209:	74 e8                	je     8011f3 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80120b:	85 c0                	test   %eax,%eax
  80120d:	78 08                	js     801217 <ipc_send+0x42>
	}while (r<0);

}
  80120f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801212:	5b                   	pop    %ebx
  801213:	5e                   	pop    %esi
  801214:	5f                   	pop    %edi
  801215:	5d                   	pop    %ebp
  801216:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801217:	50                   	push   %eax
  801218:	68 37 27 80 00       	push   $0x802737
  80121d:	6a 3d                	push   $0x3d
  80121f:	68 4b 27 80 00       	push   $0x80274b
  801224:	e8 25 f0 ff ff       	call   80024e <_panic>

00801229 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801229:	55                   	push   %ebp
  80122a:	89 e5                	mov    %esp,%ebp
  80122c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80122f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801234:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801237:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80123d:	8b 52 50             	mov    0x50(%edx),%edx
  801240:	39 ca                	cmp    %ecx,%edx
  801242:	74 11                	je     801255 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801244:	83 c0 01             	add    $0x1,%eax
  801247:	3d 00 04 00 00       	cmp    $0x400,%eax
  80124c:	75 e6                	jne    801234 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80124e:	b8 00 00 00 00       	mov    $0x0,%eax
  801253:	eb 0b                	jmp    801260 <ipc_find_env+0x37>
			return envs[i].env_id;
  801255:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801258:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80125d:	8b 40 48             	mov    0x48(%eax),%eax
}
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    

00801262 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801265:	8b 45 08             	mov    0x8(%ebp),%eax
  801268:	05 00 00 00 30       	add    $0x30000000,%eax
  80126d:	c1 e8 0c             	shr    $0xc,%eax
}
  801270:	5d                   	pop    %ebp
  801271:	c3                   	ret    

00801272 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801275:	8b 45 08             	mov    0x8(%ebp),%eax
  801278:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80127d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801282:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801287:	5d                   	pop    %ebp
  801288:	c3                   	ret    

00801289 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801289:	55                   	push   %ebp
  80128a:	89 e5                	mov    %esp,%ebp
  80128c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801291:	89 c2                	mov    %eax,%edx
  801293:	c1 ea 16             	shr    $0x16,%edx
  801296:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80129d:	f6 c2 01             	test   $0x1,%dl
  8012a0:	74 29                	je     8012cb <fd_alloc+0x42>
  8012a2:	89 c2                	mov    %eax,%edx
  8012a4:	c1 ea 0c             	shr    $0xc,%edx
  8012a7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ae:	f6 c2 01             	test   $0x1,%dl
  8012b1:	74 18                	je     8012cb <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8012b3:	05 00 10 00 00       	add    $0x1000,%eax
  8012b8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012bd:	75 d2                	jne    801291 <fd_alloc+0x8>
  8012bf:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8012c4:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8012c9:	eb 05                	jmp    8012d0 <fd_alloc+0x47>
			return 0;
  8012cb:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8012d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8012d3:	89 02                	mov    %eax,(%edx)
}
  8012d5:	89 c8                	mov    %ecx,%eax
  8012d7:	5d                   	pop    %ebp
  8012d8:	c3                   	ret    

008012d9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012d9:	55                   	push   %ebp
  8012da:	89 e5                	mov    %esp,%ebp
  8012dc:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012df:	83 f8 1f             	cmp    $0x1f,%eax
  8012e2:	77 30                	ja     801314 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012e4:	c1 e0 0c             	shl    $0xc,%eax
  8012e7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012ec:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8012f2:	f6 c2 01             	test   $0x1,%dl
  8012f5:	74 24                	je     80131b <fd_lookup+0x42>
  8012f7:	89 c2                	mov    %eax,%edx
  8012f9:	c1 ea 0c             	shr    $0xc,%edx
  8012fc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801303:	f6 c2 01             	test   $0x1,%dl
  801306:	74 1a                	je     801322 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801308:	8b 55 0c             	mov    0xc(%ebp),%edx
  80130b:	89 02                	mov    %eax,(%edx)
	return 0;
  80130d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801312:	5d                   	pop    %ebp
  801313:	c3                   	ret    
		return -E_INVAL;
  801314:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801319:	eb f7                	jmp    801312 <fd_lookup+0x39>
		return -E_INVAL;
  80131b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801320:	eb f0                	jmp    801312 <fd_lookup+0x39>
  801322:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801327:	eb e9                	jmp    801312 <fd_lookup+0x39>

00801329 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801329:	55                   	push   %ebp
  80132a:	89 e5                	mov    %esp,%ebp
  80132c:	53                   	push   %ebx
  80132d:	83 ec 04             	sub    $0x4,%esp
  801330:	8b 55 08             	mov    0x8(%ebp),%edx
  801333:	b8 d4 27 80 00       	mov    $0x8027d4,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  801338:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80133d:	39 13                	cmp    %edx,(%ebx)
  80133f:	74 32                	je     801373 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  801341:	83 c0 04             	add    $0x4,%eax
  801344:	8b 18                	mov    (%eax),%ebx
  801346:	85 db                	test   %ebx,%ebx
  801348:	75 f3                	jne    80133d <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80134a:	a1 00 40 80 00       	mov    0x804000,%eax
  80134f:	8b 40 48             	mov    0x48(%eax),%eax
  801352:	83 ec 04             	sub    $0x4,%esp
  801355:	52                   	push   %edx
  801356:	50                   	push   %eax
  801357:	68 58 27 80 00       	push   $0x802758
  80135c:	e8 c8 ef ff ff       	call   800329 <cprintf>
	*dev = 0;
	return -E_INVAL;
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801369:	8b 55 0c             	mov    0xc(%ebp),%edx
  80136c:	89 1a                	mov    %ebx,(%edx)
}
  80136e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801371:	c9                   	leave  
  801372:	c3                   	ret    
			return 0;
  801373:	b8 00 00 00 00       	mov    $0x0,%eax
  801378:	eb ef                	jmp    801369 <dev_lookup+0x40>

0080137a <fd_close>:
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	57                   	push   %edi
  80137e:	56                   	push   %esi
  80137f:	53                   	push   %ebx
  801380:	83 ec 24             	sub    $0x24,%esp
  801383:	8b 75 08             	mov    0x8(%ebp),%esi
  801386:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801389:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80138c:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80138d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801393:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801396:	50                   	push   %eax
  801397:	e8 3d ff ff ff       	call   8012d9 <fd_lookup>
  80139c:	89 c3                	mov    %eax,%ebx
  80139e:	83 c4 10             	add    $0x10,%esp
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	78 05                	js     8013aa <fd_close+0x30>
	    || fd != fd2)
  8013a5:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8013a8:	74 16                	je     8013c0 <fd_close+0x46>
		return (must_exist ? r : 0);
  8013aa:	89 f8                	mov    %edi,%eax
  8013ac:	84 c0                	test   %al,%al
  8013ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b3:	0f 44 d8             	cmove  %eax,%ebx
}
  8013b6:	89 d8                	mov    %ebx,%eax
  8013b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013bb:	5b                   	pop    %ebx
  8013bc:	5e                   	pop    %esi
  8013bd:	5f                   	pop    %edi
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013c0:	83 ec 08             	sub    $0x8,%esp
  8013c3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013c6:	50                   	push   %eax
  8013c7:	ff 36                	push   (%esi)
  8013c9:	e8 5b ff ff ff       	call   801329 <dev_lookup>
  8013ce:	89 c3                	mov    %eax,%ebx
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	78 1a                	js     8013f1 <fd_close+0x77>
		if (dev->dev_close)
  8013d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013da:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8013dd:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8013e2:	85 c0                	test   %eax,%eax
  8013e4:	74 0b                	je     8013f1 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8013e6:	83 ec 0c             	sub    $0xc,%esp
  8013e9:	56                   	push   %esi
  8013ea:	ff d0                	call   *%eax
  8013ec:	89 c3                	mov    %eax,%ebx
  8013ee:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013f1:	83 ec 08             	sub    $0x8,%esp
  8013f4:	56                   	push   %esi
  8013f5:	6a 00                	push   $0x0
  8013f7:	e8 88 f9 ff ff       	call   800d84 <sys_page_unmap>
	return r;
  8013fc:	83 c4 10             	add    $0x10,%esp
  8013ff:	eb b5                	jmp    8013b6 <fd_close+0x3c>

00801401 <close>:

int
close(int fdnum)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801407:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80140a:	50                   	push   %eax
  80140b:	ff 75 08             	push   0x8(%ebp)
  80140e:	e8 c6 fe ff ff       	call   8012d9 <fd_lookup>
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	85 c0                	test   %eax,%eax
  801418:	79 02                	jns    80141c <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80141a:	c9                   	leave  
  80141b:	c3                   	ret    
		return fd_close(fd, 1);
  80141c:	83 ec 08             	sub    $0x8,%esp
  80141f:	6a 01                	push   $0x1
  801421:	ff 75 f4             	push   -0xc(%ebp)
  801424:	e8 51 ff ff ff       	call   80137a <fd_close>
  801429:	83 c4 10             	add    $0x10,%esp
  80142c:	eb ec                	jmp    80141a <close+0x19>

0080142e <close_all>:

void
close_all(void)
{
  80142e:	55                   	push   %ebp
  80142f:	89 e5                	mov    %esp,%ebp
  801431:	53                   	push   %ebx
  801432:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801435:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80143a:	83 ec 0c             	sub    $0xc,%esp
  80143d:	53                   	push   %ebx
  80143e:	e8 be ff ff ff       	call   801401 <close>
	for (i = 0; i < MAXFD; i++)
  801443:	83 c3 01             	add    $0x1,%ebx
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	83 fb 20             	cmp    $0x20,%ebx
  80144c:	75 ec                	jne    80143a <close_all+0xc>
}
  80144e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801451:	c9                   	leave  
  801452:	c3                   	ret    

00801453 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801453:	55                   	push   %ebp
  801454:	89 e5                	mov    %esp,%ebp
  801456:	57                   	push   %edi
  801457:	56                   	push   %esi
  801458:	53                   	push   %ebx
  801459:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80145c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80145f:	50                   	push   %eax
  801460:	ff 75 08             	push   0x8(%ebp)
  801463:	e8 71 fe ff ff       	call   8012d9 <fd_lookup>
  801468:	89 c3                	mov    %eax,%ebx
  80146a:	83 c4 10             	add    $0x10,%esp
  80146d:	85 c0                	test   %eax,%eax
  80146f:	78 7f                	js     8014f0 <dup+0x9d>
		return r;
	close(newfdnum);
  801471:	83 ec 0c             	sub    $0xc,%esp
  801474:	ff 75 0c             	push   0xc(%ebp)
  801477:	e8 85 ff ff ff       	call   801401 <close>

	newfd = INDEX2FD(newfdnum);
  80147c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80147f:	c1 e6 0c             	shl    $0xc,%esi
  801482:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801488:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80148b:	89 3c 24             	mov    %edi,(%esp)
  80148e:	e8 df fd ff ff       	call   801272 <fd2data>
  801493:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801495:	89 34 24             	mov    %esi,(%esp)
  801498:	e8 d5 fd ff ff       	call   801272 <fd2data>
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014a3:	89 d8                	mov    %ebx,%eax
  8014a5:	c1 e8 16             	shr    $0x16,%eax
  8014a8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014af:	a8 01                	test   $0x1,%al
  8014b1:	74 11                	je     8014c4 <dup+0x71>
  8014b3:	89 d8                	mov    %ebx,%eax
  8014b5:	c1 e8 0c             	shr    $0xc,%eax
  8014b8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014bf:	f6 c2 01             	test   $0x1,%dl
  8014c2:	75 36                	jne    8014fa <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014c4:	89 f8                	mov    %edi,%eax
  8014c6:	c1 e8 0c             	shr    $0xc,%eax
  8014c9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014d0:	83 ec 0c             	sub    $0xc,%esp
  8014d3:	25 07 0e 00 00       	and    $0xe07,%eax
  8014d8:	50                   	push   %eax
  8014d9:	56                   	push   %esi
  8014da:	6a 00                	push   $0x0
  8014dc:	57                   	push   %edi
  8014dd:	6a 00                	push   $0x0
  8014df:	e8 5e f8 ff ff       	call   800d42 <sys_page_map>
  8014e4:	89 c3                	mov    %eax,%ebx
  8014e6:	83 c4 20             	add    $0x20,%esp
  8014e9:	85 c0                	test   %eax,%eax
  8014eb:	78 33                	js     801520 <dup+0xcd>
		goto err;

	return newfdnum;
  8014ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014f0:	89 d8                	mov    %ebx,%eax
  8014f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014f5:	5b                   	pop    %ebx
  8014f6:	5e                   	pop    %esi
  8014f7:	5f                   	pop    %edi
  8014f8:	5d                   	pop    %ebp
  8014f9:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014fa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801501:	83 ec 0c             	sub    $0xc,%esp
  801504:	25 07 0e 00 00       	and    $0xe07,%eax
  801509:	50                   	push   %eax
  80150a:	ff 75 d4             	push   -0x2c(%ebp)
  80150d:	6a 00                	push   $0x0
  80150f:	53                   	push   %ebx
  801510:	6a 00                	push   $0x0
  801512:	e8 2b f8 ff ff       	call   800d42 <sys_page_map>
  801517:	89 c3                	mov    %eax,%ebx
  801519:	83 c4 20             	add    $0x20,%esp
  80151c:	85 c0                	test   %eax,%eax
  80151e:	79 a4                	jns    8014c4 <dup+0x71>
	sys_page_unmap(0, newfd);
  801520:	83 ec 08             	sub    $0x8,%esp
  801523:	56                   	push   %esi
  801524:	6a 00                	push   $0x0
  801526:	e8 59 f8 ff ff       	call   800d84 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80152b:	83 c4 08             	add    $0x8,%esp
  80152e:	ff 75 d4             	push   -0x2c(%ebp)
  801531:	6a 00                	push   $0x0
  801533:	e8 4c f8 ff ff       	call   800d84 <sys_page_unmap>
	return r;
  801538:	83 c4 10             	add    $0x10,%esp
  80153b:	eb b3                	jmp    8014f0 <dup+0x9d>

0080153d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80153d:	55                   	push   %ebp
  80153e:	89 e5                	mov    %esp,%ebp
  801540:	56                   	push   %esi
  801541:	53                   	push   %ebx
  801542:	83 ec 18             	sub    $0x18,%esp
  801545:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801548:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154b:	50                   	push   %eax
  80154c:	56                   	push   %esi
  80154d:	e8 87 fd ff ff       	call   8012d9 <fd_lookup>
  801552:	83 c4 10             	add    $0x10,%esp
  801555:	85 c0                	test   %eax,%eax
  801557:	78 3c                	js     801595 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801559:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80155c:	83 ec 08             	sub    $0x8,%esp
  80155f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801562:	50                   	push   %eax
  801563:	ff 33                	push   (%ebx)
  801565:	e8 bf fd ff ff       	call   801329 <dev_lookup>
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	85 c0                	test   %eax,%eax
  80156f:	78 24                	js     801595 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801571:	8b 43 08             	mov    0x8(%ebx),%eax
  801574:	83 e0 03             	and    $0x3,%eax
  801577:	83 f8 01             	cmp    $0x1,%eax
  80157a:	74 20                	je     80159c <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80157c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157f:	8b 40 08             	mov    0x8(%eax),%eax
  801582:	85 c0                	test   %eax,%eax
  801584:	74 37                	je     8015bd <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801586:	83 ec 04             	sub    $0x4,%esp
  801589:	ff 75 10             	push   0x10(%ebp)
  80158c:	ff 75 0c             	push   0xc(%ebp)
  80158f:	53                   	push   %ebx
  801590:	ff d0                	call   *%eax
  801592:	83 c4 10             	add    $0x10,%esp
}
  801595:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801598:	5b                   	pop    %ebx
  801599:	5e                   	pop    %esi
  80159a:	5d                   	pop    %ebp
  80159b:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80159c:	a1 00 40 80 00       	mov    0x804000,%eax
  8015a1:	8b 40 48             	mov    0x48(%eax),%eax
  8015a4:	83 ec 04             	sub    $0x4,%esp
  8015a7:	56                   	push   %esi
  8015a8:	50                   	push   %eax
  8015a9:	68 99 27 80 00       	push   $0x802799
  8015ae:	e8 76 ed ff ff       	call   800329 <cprintf>
		return -E_INVAL;
  8015b3:	83 c4 10             	add    $0x10,%esp
  8015b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015bb:	eb d8                	jmp    801595 <read+0x58>
		return -E_NOT_SUPP;
  8015bd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015c2:	eb d1                	jmp    801595 <read+0x58>

008015c4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	57                   	push   %edi
  8015c8:	56                   	push   %esi
  8015c9:	53                   	push   %ebx
  8015ca:	83 ec 0c             	sub    $0xc,%esp
  8015cd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015d0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015d3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015d8:	eb 02                	jmp    8015dc <readn+0x18>
  8015da:	01 c3                	add    %eax,%ebx
  8015dc:	39 f3                	cmp    %esi,%ebx
  8015de:	73 21                	jae    801601 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015e0:	83 ec 04             	sub    $0x4,%esp
  8015e3:	89 f0                	mov    %esi,%eax
  8015e5:	29 d8                	sub    %ebx,%eax
  8015e7:	50                   	push   %eax
  8015e8:	89 d8                	mov    %ebx,%eax
  8015ea:	03 45 0c             	add    0xc(%ebp),%eax
  8015ed:	50                   	push   %eax
  8015ee:	57                   	push   %edi
  8015ef:	e8 49 ff ff ff       	call   80153d <read>
		if (m < 0)
  8015f4:	83 c4 10             	add    $0x10,%esp
  8015f7:	85 c0                	test   %eax,%eax
  8015f9:	78 04                	js     8015ff <readn+0x3b>
			return m;
		if (m == 0)
  8015fb:	75 dd                	jne    8015da <readn+0x16>
  8015fd:	eb 02                	jmp    801601 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015ff:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801601:	89 d8                	mov    %ebx,%eax
  801603:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801606:	5b                   	pop    %ebx
  801607:	5e                   	pop    %esi
  801608:	5f                   	pop    %edi
  801609:	5d                   	pop    %ebp
  80160a:	c3                   	ret    

0080160b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	56                   	push   %esi
  80160f:	53                   	push   %ebx
  801610:	83 ec 18             	sub    $0x18,%esp
  801613:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801616:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801619:	50                   	push   %eax
  80161a:	53                   	push   %ebx
  80161b:	e8 b9 fc ff ff       	call   8012d9 <fd_lookup>
  801620:	83 c4 10             	add    $0x10,%esp
  801623:	85 c0                	test   %eax,%eax
  801625:	78 37                	js     80165e <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801627:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80162a:	83 ec 08             	sub    $0x8,%esp
  80162d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801630:	50                   	push   %eax
  801631:	ff 36                	push   (%esi)
  801633:	e8 f1 fc ff ff       	call   801329 <dev_lookup>
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	85 c0                	test   %eax,%eax
  80163d:	78 1f                	js     80165e <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80163f:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801643:	74 20                	je     801665 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801645:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801648:	8b 40 0c             	mov    0xc(%eax),%eax
  80164b:	85 c0                	test   %eax,%eax
  80164d:	74 37                	je     801686 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80164f:	83 ec 04             	sub    $0x4,%esp
  801652:	ff 75 10             	push   0x10(%ebp)
  801655:	ff 75 0c             	push   0xc(%ebp)
  801658:	56                   	push   %esi
  801659:	ff d0                	call   *%eax
  80165b:	83 c4 10             	add    $0x10,%esp
}
  80165e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801661:	5b                   	pop    %ebx
  801662:	5e                   	pop    %esi
  801663:	5d                   	pop    %ebp
  801664:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801665:	a1 00 40 80 00       	mov    0x804000,%eax
  80166a:	8b 40 48             	mov    0x48(%eax),%eax
  80166d:	83 ec 04             	sub    $0x4,%esp
  801670:	53                   	push   %ebx
  801671:	50                   	push   %eax
  801672:	68 b5 27 80 00       	push   $0x8027b5
  801677:	e8 ad ec ff ff       	call   800329 <cprintf>
		return -E_INVAL;
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801684:	eb d8                	jmp    80165e <write+0x53>
		return -E_NOT_SUPP;
  801686:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80168b:	eb d1                	jmp    80165e <write+0x53>

0080168d <seek>:

int
seek(int fdnum, off_t offset)
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801693:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801696:	50                   	push   %eax
  801697:	ff 75 08             	push   0x8(%ebp)
  80169a:	e8 3a fc ff ff       	call   8012d9 <fd_lookup>
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	85 c0                	test   %eax,%eax
  8016a4:	78 0e                	js     8016b4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ac:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016b4:	c9                   	leave  
  8016b5:	c3                   	ret    

008016b6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	56                   	push   %esi
  8016ba:	53                   	push   %ebx
  8016bb:	83 ec 18             	sub    $0x18,%esp
  8016be:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c4:	50                   	push   %eax
  8016c5:	53                   	push   %ebx
  8016c6:	e8 0e fc ff ff       	call   8012d9 <fd_lookup>
  8016cb:	83 c4 10             	add    $0x10,%esp
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	78 34                	js     801706 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8016d5:	83 ec 08             	sub    $0x8,%esp
  8016d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016db:	50                   	push   %eax
  8016dc:	ff 36                	push   (%esi)
  8016de:	e8 46 fc ff ff       	call   801329 <dev_lookup>
  8016e3:	83 c4 10             	add    $0x10,%esp
  8016e6:	85 c0                	test   %eax,%eax
  8016e8:	78 1c                	js     801706 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016ea:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8016ee:	74 1d                	je     80170d <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8016f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016f3:	8b 40 18             	mov    0x18(%eax),%eax
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	74 34                	je     80172e <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016fa:	83 ec 08             	sub    $0x8,%esp
  8016fd:	ff 75 0c             	push   0xc(%ebp)
  801700:	56                   	push   %esi
  801701:	ff d0                	call   *%eax
  801703:	83 c4 10             	add    $0x10,%esp
}
  801706:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801709:	5b                   	pop    %ebx
  80170a:	5e                   	pop    %esi
  80170b:	5d                   	pop    %ebp
  80170c:	c3                   	ret    
			thisenv->env_id, fdnum);
  80170d:	a1 00 40 80 00       	mov    0x804000,%eax
  801712:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801715:	83 ec 04             	sub    $0x4,%esp
  801718:	53                   	push   %ebx
  801719:	50                   	push   %eax
  80171a:	68 78 27 80 00       	push   $0x802778
  80171f:	e8 05 ec ff ff       	call   800329 <cprintf>
		return -E_INVAL;
  801724:	83 c4 10             	add    $0x10,%esp
  801727:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80172c:	eb d8                	jmp    801706 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80172e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801733:	eb d1                	jmp    801706 <ftruncate+0x50>

00801735 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	56                   	push   %esi
  801739:	53                   	push   %ebx
  80173a:	83 ec 18             	sub    $0x18,%esp
  80173d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801740:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801743:	50                   	push   %eax
  801744:	ff 75 08             	push   0x8(%ebp)
  801747:	e8 8d fb ff ff       	call   8012d9 <fd_lookup>
  80174c:	83 c4 10             	add    $0x10,%esp
  80174f:	85 c0                	test   %eax,%eax
  801751:	78 49                	js     80179c <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801753:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801756:	83 ec 08             	sub    $0x8,%esp
  801759:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175c:	50                   	push   %eax
  80175d:	ff 36                	push   (%esi)
  80175f:	e8 c5 fb ff ff       	call   801329 <dev_lookup>
  801764:	83 c4 10             	add    $0x10,%esp
  801767:	85 c0                	test   %eax,%eax
  801769:	78 31                	js     80179c <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80176b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80176e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801772:	74 2f                	je     8017a3 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801774:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801777:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80177e:	00 00 00 
	stat->st_isdir = 0;
  801781:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801788:	00 00 00 
	stat->st_dev = dev;
  80178b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801791:	83 ec 08             	sub    $0x8,%esp
  801794:	53                   	push   %ebx
  801795:	56                   	push   %esi
  801796:	ff 50 14             	call   *0x14(%eax)
  801799:	83 c4 10             	add    $0x10,%esp
}
  80179c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80179f:	5b                   	pop    %ebx
  8017a0:	5e                   	pop    %esi
  8017a1:	5d                   	pop    %ebp
  8017a2:	c3                   	ret    
		return -E_NOT_SUPP;
  8017a3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017a8:	eb f2                	jmp    80179c <fstat+0x67>

008017aa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	56                   	push   %esi
  8017ae:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017af:	83 ec 08             	sub    $0x8,%esp
  8017b2:	6a 00                	push   $0x0
  8017b4:	ff 75 08             	push   0x8(%ebp)
  8017b7:	e8 e4 01 00 00       	call   8019a0 <open>
  8017bc:	89 c3                	mov    %eax,%ebx
  8017be:	83 c4 10             	add    $0x10,%esp
  8017c1:	85 c0                	test   %eax,%eax
  8017c3:	78 1b                	js     8017e0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017c5:	83 ec 08             	sub    $0x8,%esp
  8017c8:	ff 75 0c             	push   0xc(%ebp)
  8017cb:	50                   	push   %eax
  8017cc:	e8 64 ff ff ff       	call   801735 <fstat>
  8017d1:	89 c6                	mov    %eax,%esi
	close(fd);
  8017d3:	89 1c 24             	mov    %ebx,(%esp)
  8017d6:	e8 26 fc ff ff       	call   801401 <close>
	return r;
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	89 f3                	mov    %esi,%ebx
}
  8017e0:	89 d8                	mov    %ebx,%eax
  8017e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e5:	5b                   	pop    %ebx
  8017e6:	5e                   	pop    %esi
  8017e7:	5d                   	pop    %ebp
  8017e8:	c3                   	ret    

008017e9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	56                   	push   %esi
  8017ed:	53                   	push   %ebx
  8017ee:	89 c6                	mov    %eax,%esi
  8017f0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017f2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8017f9:	74 27                	je     801822 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017fb:	6a 07                	push   $0x7
  8017fd:	68 00 50 80 00       	push   $0x805000
  801802:	56                   	push   %esi
  801803:	ff 35 00 60 80 00    	push   0x806000
  801809:	e8 c7 f9 ff ff       	call   8011d5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80180e:	83 c4 0c             	add    $0xc,%esp
  801811:	6a 00                	push   $0x0
  801813:	53                   	push   %ebx
  801814:	6a 00                	push   $0x0
  801816:	e8 53 f9 ff ff       	call   80116e <ipc_recv>
}
  80181b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80181e:	5b                   	pop    %ebx
  80181f:	5e                   	pop    %esi
  801820:	5d                   	pop    %ebp
  801821:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801822:	83 ec 0c             	sub    $0xc,%esp
  801825:	6a 01                	push   $0x1
  801827:	e8 fd f9 ff ff       	call   801229 <ipc_find_env>
  80182c:	a3 00 60 80 00       	mov    %eax,0x806000
  801831:	83 c4 10             	add    $0x10,%esp
  801834:	eb c5                	jmp    8017fb <fsipc+0x12>

00801836 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80183c:	8b 45 08             	mov    0x8(%ebp),%eax
  80183f:	8b 40 0c             	mov    0xc(%eax),%eax
  801842:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801847:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80184f:	ba 00 00 00 00       	mov    $0x0,%edx
  801854:	b8 02 00 00 00       	mov    $0x2,%eax
  801859:	e8 8b ff ff ff       	call   8017e9 <fsipc>
}
  80185e:	c9                   	leave  
  80185f:	c3                   	ret    

00801860 <devfile_flush>:
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801866:	8b 45 08             	mov    0x8(%ebp),%eax
  801869:	8b 40 0c             	mov    0xc(%eax),%eax
  80186c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801871:	ba 00 00 00 00       	mov    $0x0,%edx
  801876:	b8 06 00 00 00       	mov    $0x6,%eax
  80187b:	e8 69 ff ff ff       	call   8017e9 <fsipc>
}
  801880:	c9                   	leave  
  801881:	c3                   	ret    

00801882 <devfile_stat>:
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	53                   	push   %ebx
  801886:	83 ec 04             	sub    $0x4,%esp
  801889:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80188c:	8b 45 08             	mov    0x8(%ebp),%eax
  80188f:	8b 40 0c             	mov    0xc(%eax),%eax
  801892:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801897:	ba 00 00 00 00       	mov    $0x0,%edx
  80189c:	b8 05 00 00 00       	mov    $0x5,%eax
  8018a1:	e8 43 ff ff ff       	call   8017e9 <fsipc>
  8018a6:	85 c0                	test   %eax,%eax
  8018a8:	78 2c                	js     8018d6 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018aa:	83 ec 08             	sub    $0x8,%esp
  8018ad:	68 00 50 80 00       	push   $0x805000
  8018b2:	53                   	push   %ebx
  8018b3:	e8 4b f0 ff ff       	call   800903 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018b8:	a1 80 50 80 00       	mov    0x805080,%eax
  8018bd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018c3:	a1 84 50 80 00       	mov    0x805084,%eax
  8018c8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018ce:	83 c4 10             	add    $0x10,%esp
  8018d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d9:	c9                   	leave  
  8018da:	c3                   	ret    

008018db <devfile_write>:
{
  8018db:	55                   	push   %ebp
  8018dc:	89 e5                	mov    %esp,%ebp
  8018de:	83 ec 0c             	sub    $0xc,%esp
  8018e1:	8b 45 10             	mov    0x10(%ebp),%eax
  8018e4:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018e9:	39 d0                	cmp    %edx,%eax
  8018eb:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8018f1:	8b 52 0c             	mov    0xc(%edx),%edx
  8018f4:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018fa:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018ff:	50                   	push   %eax
  801900:	ff 75 0c             	push   0xc(%ebp)
  801903:	68 08 50 80 00       	push   $0x805008
  801908:	e8 8c f1 ff ff       	call   800a99 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80190d:	ba 00 00 00 00       	mov    $0x0,%edx
  801912:	b8 04 00 00 00       	mov    $0x4,%eax
  801917:	e8 cd fe ff ff       	call   8017e9 <fsipc>
}
  80191c:	c9                   	leave  
  80191d:	c3                   	ret    

0080191e <devfile_read>:
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	56                   	push   %esi
  801922:	53                   	push   %ebx
  801923:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801926:	8b 45 08             	mov    0x8(%ebp),%eax
  801929:	8b 40 0c             	mov    0xc(%eax),%eax
  80192c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801931:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801937:	ba 00 00 00 00       	mov    $0x0,%edx
  80193c:	b8 03 00 00 00       	mov    $0x3,%eax
  801941:	e8 a3 fe ff ff       	call   8017e9 <fsipc>
  801946:	89 c3                	mov    %eax,%ebx
  801948:	85 c0                	test   %eax,%eax
  80194a:	78 1f                	js     80196b <devfile_read+0x4d>
	assert(r <= n);
  80194c:	39 f0                	cmp    %esi,%eax
  80194e:	77 24                	ja     801974 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801950:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801955:	7f 33                	jg     80198a <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801957:	83 ec 04             	sub    $0x4,%esp
  80195a:	50                   	push   %eax
  80195b:	68 00 50 80 00       	push   $0x805000
  801960:	ff 75 0c             	push   0xc(%ebp)
  801963:	e8 31 f1 ff ff       	call   800a99 <memmove>
	return r;
  801968:	83 c4 10             	add    $0x10,%esp
}
  80196b:	89 d8                	mov    %ebx,%eax
  80196d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801970:	5b                   	pop    %ebx
  801971:	5e                   	pop    %esi
  801972:	5d                   	pop    %ebp
  801973:	c3                   	ret    
	assert(r <= n);
  801974:	68 e4 27 80 00       	push   $0x8027e4
  801979:	68 eb 27 80 00       	push   $0x8027eb
  80197e:	6a 7c                	push   $0x7c
  801980:	68 00 28 80 00       	push   $0x802800
  801985:	e8 c4 e8 ff ff       	call   80024e <_panic>
	assert(r <= PGSIZE);
  80198a:	68 0b 28 80 00       	push   $0x80280b
  80198f:	68 eb 27 80 00       	push   $0x8027eb
  801994:	6a 7d                	push   $0x7d
  801996:	68 00 28 80 00       	push   $0x802800
  80199b:	e8 ae e8 ff ff       	call   80024e <_panic>

008019a0 <open>:
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	56                   	push   %esi
  8019a4:	53                   	push   %ebx
  8019a5:	83 ec 1c             	sub    $0x1c,%esp
  8019a8:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8019ab:	56                   	push   %esi
  8019ac:	e8 17 ef ff ff       	call   8008c8 <strlen>
  8019b1:	83 c4 10             	add    $0x10,%esp
  8019b4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019b9:	7f 6c                	jg     801a27 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8019bb:	83 ec 0c             	sub    $0xc,%esp
  8019be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c1:	50                   	push   %eax
  8019c2:	e8 c2 f8 ff ff       	call   801289 <fd_alloc>
  8019c7:	89 c3                	mov    %eax,%ebx
  8019c9:	83 c4 10             	add    $0x10,%esp
  8019cc:	85 c0                	test   %eax,%eax
  8019ce:	78 3c                	js     801a0c <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8019d0:	83 ec 08             	sub    $0x8,%esp
  8019d3:	56                   	push   %esi
  8019d4:	68 00 50 80 00       	push   $0x805000
  8019d9:	e8 25 ef ff ff       	call   800903 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e1:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019e6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ee:	e8 f6 fd ff ff       	call   8017e9 <fsipc>
  8019f3:	89 c3                	mov    %eax,%ebx
  8019f5:	83 c4 10             	add    $0x10,%esp
  8019f8:	85 c0                	test   %eax,%eax
  8019fa:	78 19                	js     801a15 <open+0x75>
	return fd2num(fd);
  8019fc:	83 ec 0c             	sub    $0xc,%esp
  8019ff:	ff 75 f4             	push   -0xc(%ebp)
  801a02:	e8 5b f8 ff ff       	call   801262 <fd2num>
  801a07:	89 c3                	mov    %eax,%ebx
  801a09:	83 c4 10             	add    $0x10,%esp
}
  801a0c:	89 d8                	mov    %ebx,%eax
  801a0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a11:	5b                   	pop    %ebx
  801a12:	5e                   	pop    %esi
  801a13:	5d                   	pop    %ebp
  801a14:	c3                   	ret    
		fd_close(fd, 0);
  801a15:	83 ec 08             	sub    $0x8,%esp
  801a18:	6a 00                	push   $0x0
  801a1a:	ff 75 f4             	push   -0xc(%ebp)
  801a1d:	e8 58 f9 ff ff       	call   80137a <fd_close>
		return r;
  801a22:	83 c4 10             	add    $0x10,%esp
  801a25:	eb e5                	jmp    801a0c <open+0x6c>
		return -E_BAD_PATH;
  801a27:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a2c:	eb de                	jmp    801a0c <open+0x6c>

00801a2e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a34:	ba 00 00 00 00       	mov    $0x0,%edx
  801a39:	b8 08 00 00 00       	mov    $0x8,%eax
  801a3e:	e8 a6 fd ff ff       	call   8017e9 <fsipc>
}
  801a43:	c9                   	leave  
  801a44:	c3                   	ret    

00801a45 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801a45:	55                   	push   %ebp
  801a46:	89 e5                	mov    %esp,%ebp
  801a48:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801a4b:	89 c2                	mov    %eax,%edx
  801a4d:	c1 ea 16             	shr    $0x16,%edx
  801a50:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801a57:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801a5c:	f6 c1 01             	test   $0x1,%cl
  801a5f:	74 1c                	je     801a7d <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801a61:	c1 e8 0c             	shr    $0xc,%eax
  801a64:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801a6b:	a8 01                	test   $0x1,%al
  801a6d:	74 0e                	je     801a7d <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801a6f:	c1 e8 0c             	shr    $0xc,%eax
  801a72:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801a79:	ef 
  801a7a:	0f b7 d2             	movzwl %dx,%edx
}
  801a7d:	89 d0                	mov    %edx,%eax
  801a7f:	5d                   	pop    %ebp
  801a80:	c3                   	ret    

00801a81 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
  801a84:	56                   	push   %esi
  801a85:	53                   	push   %ebx
  801a86:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a89:	83 ec 0c             	sub    $0xc,%esp
  801a8c:	ff 75 08             	push   0x8(%ebp)
  801a8f:	e8 de f7 ff ff       	call   801272 <fd2data>
  801a94:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a96:	83 c4 08             	add    $0x8,%esp
  801a99:	68 17 28 80 00       	push   $0x802817
  801a9e:	53                   	push   %ebx
  801a9f:	e8 5f ee ff ff       	call   800903 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801aa4:	8b 46 04             	mov    0x4(%esi),%eax
  801aa7:	2b 06                	sub    (%esi),%eax
  801aa9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801aaf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ab6:	00 00 00 
	stat->st_dev = &devpipe;
  801ab9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801ac0:	30 80 00 
	return 0;
}
  801ac3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ac8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801acb:	5b                   	pop    %ebx
  801acc:	5e                   	pop    %esi
  801acd:	5d                   	pop    %ebp
  801ace:	c3                   	ret    

00801acf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	53                   	push   %ebx
  801ad3:	83 ec 0c             	sub    $0xc,%esp
  801ad6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ad9:	53                   	push   %ebx
  801ada:	6a 00                	push   $0x0
  801adc:	e8 a3 f2 ff ff       	call   800d84 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ae1:	89 1c 24             	mov    %ebx,(%esp)
  801ae4:	e8 89 f7 ff ff       	call   801272 <fd2data>
  801ae9:	83 c4 08             	add    $0x8,%esp
  801aec:	50                   	push   %eax
  801aed:	6a 00                	push   $0x0
  801aef:	e8 90 f2 ff ff       	call   800d84 <sys_page_unmap>
}
  801af4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801af7:	c9                   	leave  
  801af8:	c3                   	ret    

00801af9 <_pipeisclosed>:
{
  801af9:	55                   	push   %ebp
  801afa:	89 e5                	mov    %esp,%ebp
  801afc:	57                   	push   %edi
  801afd:	56                   	push   %esi
  801afe:	53                   	push   %ebx
  801aff:	83 ec 1c             	sub    $0x1c,%esp
  801b02:	89 c7                	mov    %eax,%edi
  801b04:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b06:	a1 00 40 80 00       	mov    0x804000,%eax
  801b0b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b0e:	83 ec 0c             	sub    $0xc,%esp
  801b11:	57                   	push   %edi
  801b12:	e8 2e ff ff ff       	call   801a45 <pageref>
  801b17:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b1a:	89 34 24             	mov    %esi,(%esp)
  801b1d:	e8 23 ff ff ff       	call   801a45 <pageref>
		nn = thisenv->env_runs;
  801b22:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801b28:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b2b:	83 c4 10             	add    $0x10,%esp
  801b2e:	39 cb                	cmp    %ecx,%ebx
  801b30:	74 1b                	je     801b4d <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801b32:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b35:	75 cf                	jne    801b06 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b37:	8b 42 58             	mov    0x58(%edx),%eax
  801b3a:	6a 01                	push   $0x1
  801b3c:	50                   	push   %eax
  801b3d:	53                   	push   %ebx
  801b3e:	68 1e 28 80 00       	push   $0x80281e
  801b43:	e8 e1 e7 ff ff       	call   800329 <cprintf>
  801b48:	83 c4 10             	add    $0x10,%esp
  801b4b:	eb b9                	jmp    801b06 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b4d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b50:	0f 94 c0             	sete   %al
  801b53:	0f b6 c0             	movzbl %al,%eax
}
  801b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b59:	5b                   	pop    %ebx
  801b5a:	5e                   	pop    %esi
  801b5b:	5f                   	pop    %edi
  801b5c:	5d                   	pop    %ebp
  801b5d:	c3                   	ret    

00801b5e <devpipe_write>:
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	57                   	push   %edi
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	83 ec 28             	sub    $0x28,%esp
  801b67:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b6a:	56                   	push   %esi
  801b6b:	e8 02 f7 ff ff       	call   801272 <fd2data>
  801b70:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b72:	83 c4 10             	add    $0x10,%esp
  801b75:	bf 00 00 00 00       	mov    $0x0,%edi
  801b7a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b7d:	75 09                	jne    801b88 <devpipe_write+0x2a>
	return i;
  801b7f:	89 f8                	mov    %edi,%eax
  801b81:	eb 23                	jmp    801ba6 <devpipe_write+0x48>
			sys_yield();
  801b83:	e8 58 f1 ff ff       	call   800ce0 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b88:	8b 43 04             	mov    0x4(%ebx),%eax
  801b8b:	8b 0b                	mov    (%ebx),%ecx
  801b8d:	8d 51 20             	lea    0x20(%ecx),%edx
  801b90:	39 d0                	cmp    %edx,%eax
  801b92:	72 1a                	jb     801bae <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801b94:	89 da                	mov    %ebx,%edx
  801b96:	89 f0                	mov    %esi,%eax
  801b98:	e8 5c ff ff ff       	call   801af9 <_pipeisclosed>
  801b9d:	85 c0                	test   %eax,%eax
  801b9f:	74 e2                	je     801b83 <devpipe_write+0x25>
				return 0;
  801ba1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ba6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ba9:	5b                   	pop    %ebx
  801baa:	5e                   	pop    %esi
  801bab:	5f                   	pop    %edi
  801bac:	5d                   	pop    %ebp
  801bad:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bb5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bb8:	89 c2                	mov    %eax,%edx
  801bba:	c1 fa 1f             	sar    $0x1f,%edx
  801bbd:	89 d1                	mov    %edx,%ecx
  801bbf:	c1 e9 1b             	shr    $0x1b,%ecx
  801bc2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bc5:	83 e2 1f             	and    $0x1f,%edx
  801bc8:	29 ca                	sub    %ecx,%edx
  801bca:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bce:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bd2:	83 c0 01             	add    $0x1,%eax
  801bd5:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801bd8:	83 c7 01             	add    $0x1,%edi
  801bdb:	eb 9d                	jmp    801b7a <devpipe_write+0x1c>

00801bdd <devpipe_read>:
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	57                   	push   %edi
  801be1:	56                   	push   %esi
  801be2:	53                   	push   %ebx
  801be3:	83 ec 18             	sub    $0x18,%esp
  801be6:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801be9:	57                   	push   %edi
  801bea:	e8 83 f6 ff ff       	call   801272 <fd2data>
  801bef:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801bf1:	83 c4 10             	add    $0x10,%esp
  801bf4:	be 00 00 00 00       	mov    $0x0,%esi
  801bf9:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bfc:	75 13                	jne    801c11 <devpipe_read+0x34>
	return i;
  801bfe:	89 f0                	mov    %esi,%eax
  801c00:	eb 02                	jmp    801c04 <devpipe_read+0x27>
				return i;
  801c02:	89 f0                	mov    %esi,%eax
}
  801c04:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c07:	5b                   	pop    %ebx
  801c08:	5e                   	pop    %esi
  801c09:	5f                   	pop    %edi
  801c0a:	5d                   	pop    %ebp
  801c0b:	c3                   	ret    
			sys_yield();
  801c0c:	e8 cf f0 ff ff       	call   800ce0 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c11:	8b 03                	mov    (%ebx),%eax
  801c13:	3b 43 04             	cmp    0x4(%ebx),%eax
  801c16:	75 18                	jne    801c30 <devpipe_read+0x53>
			if (i > 0)
  801c18:	85 f6                	test   %esi,%esi
  801c1a:	75 e6                	jne    801c02 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801c1c:	89 da                	mov    %ebx,%edx
  801c1e:	89 f8                	mov    %edi,%eax
  801c20:	e8 d4 fe ff ff       	call   801af9 <_pipeisclosed>
  801c25:	85 c0                	test   %eax,%eax
  801c27:	74 e3                	je     801c0c <devpipe_read+0x2f>
				return 0;
  801c29:	b8 00 00 00 00       	mov    $0x0,%eax
  801c2e:	eb d4                	jmp    801c04 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c30:	99                   	cltd   
  801c31:	c1 ea 1b             	shr    $0x1b,%edx
  801c34:	01 d0                	add    %edx,%eax
  801c36:	83 e0 1f             	and    $0x1f,%eax
  801c39:	29 d0                	sub    %edx,%eax
  801c3b:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c43:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801c46:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801c49:	83 c6 01             	add    $0x1,%esi
  801c4c:	eb ab                	jmp    801bf9 <devpipe_read+0x1c>

00801c4e <pipe>:
{
  801c4e:	55                   	push   %ebp
  801c4f:	89 e5                	mov    %esp,%ebp
  801c51:	56                   	push   %esi
  801c52:	53                   	push   %ebx
  801c53:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c56:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c59:	50                   	push   %eax
  801c5a:	e8 2a f6 ff ff       	call   801289 <fd_alloc>
  801c5f:	89 c3                	mov    %eax,%ebx
  801c61:	83 c4 10             	add    $0x10,%esp
  801c64:	85 c0                	test   %eax,%eax
  801c66:	0f 88 23 01 00 00    	js     801d8f <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c6c:	83 ec 04             	sub    $0x4,%esp
  801c6f:	68 07 04 00 00       	push   $0x407
  801c74:	ff 75 f4             	push   -0xc(%ebp)
  801c77:	6a 00                	push   $0x0
  801c79:	e8 81 f0 ff ff       	call   800cff <sys_page_alloc>
  801c7e:	89 c3                	mov    %eax,%ebx
  801c80:	83 c4 10             	add    $0x10,%esp
  801c83:	85 c0                	test   %eax,%eax
  801c85:	0f 88 04 01 00 00    	js     801d8f <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801c8b:	83 ec 0c             	sub    $0xc,%esp
  801c8e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c91:	50                   	push   %eax
  801c92:	e8 f2 f5 ff ff       	call   801289 <fd_alloc>
  801c97:	89 c3                	mov    %eax,%ebx
  801c99:	83 c4 10             	add    $0x10,%esp
  801c9c:	85 c0                	test   %eax,%eax
  801c9e:	0f 88 db 00 00 00    	js     801d7f <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca4:	83 ec 04             	sub    $0x4,%esp
  801ca7:	68 07 04 00 00       	push   $0x407
  801cac:	ff 75 f0             	push   -0x10(%ebp)
  801caf:	6a 00                	push   $0x0
  801cb1:	e8 49 f0 ff ff       	call   800cff <sys_page_alloc>
  801cb6:	89 c3                	mov    %eax,%ebx
  801cb8:	83 c4 10             	add    $0x10,%esp
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	0f 88 bc 00 00 00    	js     801d7f <pipe+0x131>
	va = fd2data(fd0);
  801cc3:	83 ec 0c             	sub    $0xc,%esp
  801cc6:	ff 75 f4             	push   -0xc(%ebp)
  801cc9:	e8 a4 f5 ff ff       	call   801272 <fd2data>
  801cce:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cd0:	83 c4 0c             	add    $0xc,%esp
  801cd3:	68 07 04 00 00       	push   $0x407
  801cd8:	50                   	push   %eax
  801cd9:	6a 00                	push   $0x0
  801cdb:	e8 1f f0 ff ff       	call   800cff <sys_page_alloc>
  801ce0:	89 c3                	mov    %eax,%ebx
  801ce2:	83 c4 10             	add    $0x10,%esp
  801ce5:	85 c0                	test   %eax,%eax
  801ce7:	0f 88 82 00 00 00    	js     801d6f <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ced:	83 ec 0c             	sub    $0xc,%esp
  801cf0:	ff 75 f0             	push   -0x10(%ebp)
  801cf3:	e8 7a f5 ff ff       	call   801272 <fd2data>
  801cf8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cff:	50                   	push   %eax
  801d00:	6a 00                	push   $0x0
  801d02:	56                   	push   %esi
  801d03:	6a 00                	push   $0x0
  801d05:	e8 38 f0 ff ff       	call   800d42 <sys_page_map>
  801d0a:	89 c3                	mov    %eax,%ebx
  801d0c:	83 c4 20             	add    $0x20,%esp
  801d0f:	85 c0                	test   %eax,%eax
  801d11:	78 4e                	js     801d61 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801d13:	a1 20 30 80 00       	mov    0x803020,%eax
  801d18:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d1b:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801d1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d20:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801d27:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801d2a:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801d2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d2f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801d36:	83 ec 0c             	sub    $0xc,%esp
  801d39:	ff 75 f4             	push   -0xc(%ebp)
  801d3c:	e8 21 f5 ff ff       	call   801262 <fd2num>
  801d41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d44:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d46:	83 c4 04             	add    $0x4,%esp
  801d49:	ff 75 f0             	push   -0x10(%ebp)
  801d4c:	e8 11 f5 ff ff       	call   801262 <fd2num>
  801d51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d54:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d57:	83 c4 10             	add    $0x10,%esp
  801d5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d5f:	eb 2e                	jmp    801d8f <pipe+0x141>
	sys_page_unmap(0, va);
  801d61:	83 ec 08             	sub    $0x8,%esp
  801d64:	56                   	push   %esi
  801d65:	6a 00                	push   $0x0
  801d67:	e8 18 f0 ff ff       	call   800d84 <sys_page_unmap>
  801d6c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d6f:	83 ec 08             	sub    $0x8,%esp
  801d72:	ff 75 f0             	push   -0x10(%ebp)
  801d75:	6a 00                	push   $0x0
  801d77:	e8 08 f0 ff ff       	call   800d84 <sys_page_unmap>
  801d7c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801d7f:	83 ec 08             	sub    $0x8,%esp
  801d82:	ff 75 f4             	push   -0xc(%ebp)
  801d85:	6a 00                	push   $0x0
  801d87:	e8 f8 ef ff ff       	call   800d84 <sys_page_unmap>
  801d8c:	83 c4 10             	add    $0x10,%esp
}
  801d8f:	89 d8                	mov    %ebx,%eax
  801d91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d94:	5b                   	pop    %ebx
  801d95:	5e                   	pop    %esi
  801d96:	5d                   	pop    %ebp
  801d97:	c3                   	ret    

00801d98 <pipeisclosed>:
{
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801da1:	50                   	push   %eax
  801da2:	ff 75 08             	push   0x8(%ebp)
  801da5:	e8 2f f5 ff ff       	call   8012d9 <fd_lookup>
  801daa:	83 c4 10             	add    $0x10,%esp
  801dad:	85 c0                	test   %eax,%eax
  801daf:	78 18                	js     801dc9 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801db1:	83 ec 0c             	sub    $0xc,%esp
  801db4:	ff 75 f4             	push   -0xc(%ebp)
  801db7:	e8 b6 f4 ff ff       	call   801272 <fd2data>
  801dbc:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc1:	e8 33 fd ff ff       	call   801af9 <_pipeisclosed>
  801dc6:	83 c4 10             	add    $0x10,%esp
}
  801dc9:	c9                   	leave  
  801dca:	c3                   	ret    

00801dcb <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801dcb:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd0:	c3                   	ret    

00801dd1 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dd7:	68 36 28 80 00       	push   $0x802836
  801ddc:	ff 75 0c             	push   0xc(%ebp)
  801ddf:	e8 1f eb ff ff       	call   800903 <strcpy>
	return 0;
}
  801de4:	b8 00 00 00 00       	mov    $0x0,%eax
  801de9:	c9                   	leave  
  801dea:	c3                   	ret    

00801deb <devcons_write>:
{
  801deb:	55                   	push   %ebp
  801dec:	89 e5                	mov    %esp,%ebp
  801dee:	57                   	push   %edi
  801def:	56                   	push   %esi
  801df0:	53                   	push   %ebx
  801df1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801df7:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801dfc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e02:	eb 2e                	jmp    801e32 <devcons_write+0x47>
		m = n - tot;
  801e04:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e07:	29 f3                	sub    %esi,%ebx
  801e09:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e0e:	39 c3                	cmp    %eax,%ebx
  801e10:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e13:	83 ec 04             	sub    $0x4,%esp
  801e16:	53                   	push   %ebx
  801e17:	89 f0                	mov    %esi,%eax
  801e19:	03 45 0c             	add    0xc(%ebp),%eax
  801e1c:	50                   	push   %eax
  801e1d:	57                   	push   %edi
  801e1e:	e8 76 ec ff ff       	call   800a99 <memmove>
		sys_cputs(buf, m);
  801e23:	83 c4 08             	add    $0x8,%esp
  801e26:	53                   	push   %ebx
  801e27:	57                   	push   %edi
  801e28:	e8 16 ee ff ff       	call   800c43 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e2d:	01 de                	add    %ebx,%esi
  801e2f:	83 c4 10             	add    $0x10,%esp
  801e32:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e35:	72 cd                	jb     801e04 <devcons_write+0x19>
}
  801e37:	89 f0                	mov    %esi,%eax
  801e39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e3c:	5b                   	pop    %ebx
  801e3d:	5e                   	pop    %esi
  801e3e:	5f                   	pop    %edi
  801e3f:	5d                   	pop    %ebp
  801e40:	c3                   	ret    

00801e41 <devcons_read>:
{
  801e41:	55                   	push   %ebp
  801e42:	89 e5                	mov    %esp,%ebp
  801e44:	83 ec 08             	sub    $0x8,%esp
  801e47:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e4c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e50:	75 07                	jne    801e59 <devcons_read+0x18>
  801e52:	eb 1f                	jmp    801e73 <devcons_read+0x32>
		sys_yield();
  801e54:	e8 87 ee ff ff       	call   800ce0 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801e59:	e8 03 ee ff ff       	call   800c61 <sys_cgetc>
  801e5e:	85 c0                	test   %eax,%eax
  801e60:	74 f2                	je     801e54 <devcons_read+0x13>
	if (c < 0)
  801e62:	78 0f                	js     801e73 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801e64:	83 f8 04             	cmp    $0x4,%eax
  801e67:	74 0c                	je     801e75 <devcons_read+0x34>
	*(char*)vbuf = c;
  801e69:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e6c:	88 02                	mov    %al,(%edx)
	return 1;
  801e6e:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801e73:	c9                   	leave  
  801e74:	c3                   	ret    
		return 0;
  801e75:	b8 00 00 00 00       	mov    $0x0,%eax
  801e7a:	eb f7                	jmp    801e73 <devcons_read+0x32>

00801e7c <cputchar>:
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e82:	8b 45 08             	mov    0x8(%ebp),%eax
  801e85:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e88:	6a 01                	push   $0x1
  801e8a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e8d:	50                   	push   %eax
  801e8e:	e8 b0 ed ff ff       	call   800c43 <sys_cputs>
}
  801e93:	83 c4 10             	add    $0x10,%esp
  801e96:	c9                   	leave  
  801e97:	c3                   	ret    

00801e98 <getchar>:
{
  801e98:	55                   	push   %ebp
  801e99:	89 e5                	mov    %esp,%ebp
  801e9b:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801e9e:	6a 01                	push   $0x1
  801ea0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ea3:	50                   	push   %eax
  801ea4:	6a 00                	push   $0x0
  801ea6:	e8 92 f6 ff ff       	call   80153d <read>
	if (r < 0)
  801eab:	83 c4 10             	add    $0x10,%esp
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	78 06                	js     801eb8 <getchar+0x20>
	if (r < 1)
  801eb2:	74 06                	je     801eba <getchar+0x22>
	return c;
  801eb4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801eb8:	c9                   	leave  
  801eb9:	c3                   	ret    
		return -E_EOF;
  801eba:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ebf:	eb f7                	jmp    801eb8 <getchar+0x20>

00801ec1 <iscons>:
{
  801ec1:	55                   	push   %ebp
  801ec2:	89 e5                	mov    %esp,%ebp
  801ec4:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ec7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eca:	50                   	push   %eax
  801ecb:	ff 75 08             	push   0x8(%ebp)
  801ece:	e8 06 f4 ff ff       	call   8012d9 <fd_lookup>
  801ed3:	83 c4 10             	add    $0x10,%esp
  801ed6:	85 c0                	test   %eax,%eax
  801ed8:	78 11                	js     801eeb <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801eda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801edd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ee3:	39 10                	cmp    %edx,(%eax)
  801ee5:	0f 94 c0             	sete   %al
  801ee8:	0f b6 c0             	movzbl %al,%eax
}
  801eeb:	c9                   	leave  
  801eec:	c3                   	ret    

00801eed <opencons>:
{
  801eed:	55                   	push   %ebp
  801eee:	89 e5                	mov    %esp,%ebp
  801ef0:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801ef3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef6:	50                   	push   %eax
  801ef7:	e8 8d f3 ff ff       	call   801289 <fd_alloc>
  801efc:	83 c4 10             	add    $0x10,%esp
  801eff:	85 c0                	test   %eax,%eax
  801f01:	78 3a                	js     801f3d <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f03:	83 ec 04             	sub    $0x4,%esp
  801f06:	68 07 04 00 00       	push   $0x407
  801f0b:	ff 75 f4             	push   -0xc(%ebp)
  801f0e:	6a 00                	push   $0x0
  801f10:	e8 ea ed ff ff       	call   800cff <sys_page_alloc>
  801f15:	83 c4 10             	add    $0x10,%esp
  801f18:	85 c0                	test   %eax,%eax
  801f1a:	78 21                	js     801f3d <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801f1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f1f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f25:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f31:	83 ec 0c             	sub    $0xc,%esp
  801f34:	50                   	push   %eax
  801f35:	e8 28 f3 ff ff       	call   801262 <fd2num>
  801f3a:	83 c4 10             	add    $0x10,%esp
}
  801f3d:	c9                   	leave  
  801f3e:	c3                   	ret    

00801f3f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f3f:	55                   	push   %ebp
  801f40:	89 e5                	mov    %esp,%ebp
  801f42:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  801f45:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  801f4c:	74 0a                	je     801f58 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f51:	a3 04 60 80 00       	mov    %eax,0x806004
}
  801f56:	c9                   	leave  
  801f57:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  801f58:	e8 64 ed ff ff       	call   800cc1 <sys_getenvid>
  801f5d:	83 ec 04             	sub    $0x4,%esp
  801f60:	68 07 0e 00 00       	push   $0xe07
  801f65:	68 00 f0 bf ee       	push   $0xeebff000
  801f6a:	50                   	push   %eax
  801f6b:	e8 8f ed ff ff       	call   800cff <sys_page_alloc>
		if (r < 0) {
  801f70:	83 c4 10             	add    $0x10,%esp
  801f73:	85 c0                	test   %eax,%eax
  801f75:	78 2c                	js     801fa3 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801f77:	e8 45 ed ff ff       	call   800cc1 <sys_getenvid>
  801f7c:	83 ec 08             	sub    $0x8,%esp
  801f7f:	68 b5 1f 80 00       	push   $0x801fb5
  801f84:	50                   	push   %eax
  801f85:	e8 c0 ee ff ff       	call   800e4a <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801f8a:	83 c4 10             	add    $0x10,%esp
  801f8d:	85 c0                	test   %eax,%eax
  801f8f:	79 bd                	jns    801f4e <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  801f91:	50                   	push   %eax
  801f92:	68 84 28 80 00       	push   $0x802884
  801f97:	6a 28                	push   $0x28
  801f99:	68 ba 28 80 00       	push   $0x8028ba
  801f9e:	e8 ab e2 ff ff       	call   80024e <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  801fa3:	50                   	push   %eax
  801fa4:	68 44 28 80 00       	push   $0x802844
  801fa9:	6a 23                	push   $0x23
  801fab:	68 ba 28 80 00       	push   $0x8028ba
  801fb0:	e8 99 e2 ff ff       	call   80024e <_panic>

00801fb5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fb5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fb6:	a1 04 60 80 00       	mov    0x806004,%eax
	call *%eax
  801fbb:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fbd:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  801fc0:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  801fc4:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801fc7:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  801fcb:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801fcf:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  801fd1:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  801fd4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  801fd5:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  801fd8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  801fd9:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  801fda:	c3                   	ret    
  801fdb:	66 90                	xchg   %ax,%ax
  801fdd:	66 90                	xchg   %ax,%ax
  801fdf:	90                   	nop

00801fe0 <__udivdi3>:
  801fe0:	f3 0f 1e fb          	endbr32 
  801fe4:	55                   	push   %ebp
  801fe5:	57                   	push   %edi
  801fe6:	56                   	push   %esi
  801fe7:	53                   	push   %ebx
  801fe8:	83 ec 1c             	sub    $0x1c,%esp
  801feb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801fef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801ff3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ff7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801ffb:	85 c0                	test   %eax,%eax
  801ffd:	75 19                	jne    802018 <__udivdi3+0x38>
  801fff:	39 f3                	cmp    %esi,%ebx
  802001:	76 4d                	jbe    802050 <__udivdi3+0x70>
  802003:	31 ff                	xor    %edi,%edi
  802005:	89 e8                	mov    %ebp,%eax
  802007:	89 f2                	mov    %esi,%edx
  802009:	f7 f3                	div    %ebx
  80200b:	89 fa                	mov    %edi,%edx
  80200d:	83 c4 1c             	add    $0x1c,%esp
  802010:	5b                   	pop    %ebx
  802011:	5e                   	pop    %esi
  802012:	5f                   	pop    %edi
  802013:	5d                   	pop    %ebp
  802014:	c3                   	ret    
  802015:	8d 76 00             	lea    0x0(%esi),%esi
  802018:	39 f0                	cmp    %esi,%eax
  80201a:	76 14                	jbe    802030 <__udivdi3+0x50>
  80201c:	31 ff                	xor    %edi,%edi
  80201e:	31 c0                	xor    %eax,%eax
  802020:	89 fa                	mov    %edi,%edx
  802022:	83 c4 1c             	add    $0x1c,%esp
  802025:	5b                   	pop    %ebx
  802026:	5e                   	pop    %esi
  802027:	5f                   	pop    %edi
  802028:	5d                   	pop    %ebp
  802029:	c3                   	ret    
  80202a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802030:	0f bd f8             	bsr    %eax,%edi
  802033:	83 f7 1f             	xor    $0x1f,%edi
  802036:	75 48                	jne    802080 <__udivdi3+0xa0>
  802038:	39 f0                	cmp    %esi,%eax
  80203a:	72 06                	jb     802042 <__udivdi3+0x62>
  80203c:	31 c0                	xor    %eax,%eax
  80203e:	39 eb                	cmp    %ebp,%ebx
  802040:	77 de                	ja     802020 <__udivdi3+0x40>
  802042:	b8 01 00 00 00       	mov    $0x1,%eax
  802047:	eb d7                	jmp    802020 <__udivdi3+0x40>
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	89 d9                	mov    %ebx,%ecx
  802052:	85 db                	test   %ebx,%ebx
  802054:	75 0b                	jne    802061 <__udivdi3+0x81>
  802056:	b8 01 00 00 00       	mov    $0x1,%eax
  80205b:	31 d2                	xor    %edx,%edx
  80205d:	f7 f3                	div    %ebx
  80205f:	89 c1                	mov    %eax,%ecx
  802061:	31 d2                	xor    %edx,%edx
  802063:	89 f0                	mov    %esi,%eax
  802065:	f7 f1                	div    %ecx
  802067:	89 c6                	mov    %eax,%esi
  802069:	89 e8                	mov    %ebp,%eax
  80206b:	89 f7                	mov    %esi,%edi
  80206d:	f7 f1                	div    %ecx
  80206f:	89 fa                	mov    %edi,%edx
  802071:	83 c4 1c             	add    $0x1c,%esp
  802074:	5b                   	pop    %ebx
  802075:	5e                   	pop    %esi
  802076:	5f                   	pop    %edi
  802077:	5d                   	pop    %ebp
  802078:	c3                   	ret    
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	89 f9                	mov    %edi,%ecx
  802082:	ba 20 00 00 00       	mov    $0x20,%edx
  802087:	29 fa                	sub    %edi,%edx
  802089:	d3 e0                	shl    %cl,%eax
  80208b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80208f:	89 d1                	mov    %edx,%ecx
  802091:	89 d8                	mov    %ebx,%eax
  802093:	d3 e8                	shr    %cl,%eax
  802095:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802099:	09 c1                	or     %eax,%ecx
  80209b:	89 f0                	mov    %esi,%eax
  80209d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020a1:	89 f9                	mov    %edi,%ecx
  8020a3:	d3 e3                	shl    %cl,%ebx
  8020a5:	89 d1                	mov    %edx,%ecx
  8020a7:	d3 e8                	shr    %cl,%eax
  8020a9:	89 f9                	mov    %edi,%ecx
  8020ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020af:	89 eb                	mov    %ebp,%ebx
  8020b1:	d3 e6                	shl    %cl,%esi
  8020b3:	89 d1                	mov    %edx,%ecx
  8020b5:	d3 eb                	shr    %cl,%ebx
  8020b7:	09 f3                	or     %esi,%ebx
  8020b9:	89 c6                	mov    %eax,%esi
  8020bb:	89 f2                	mov    %esi,%edx
  8020bd:	89 d8                	mov    %ebx,%eax
  8020bf:	f7 74 24 08          	divl   0x8(%esp)
  8020c3:	89 d6                	mov    %edx,%esi
  8020c5:	89 c3                	mov    %eax,%ebx
  8020c7:	f7 64 24 0c          	mull   0xc(%esp)
  8020cb:	39 d6                	cmp    %edx,%esi
  8020cd:	72 19                	jb     8020e8 <__udivdi3+0x108>
  8020cf:	89 f9                	mov    %edi,%ecx
  8020d1:	d3 e5                	shl    %cl,%ebp
  8020d3:	39 c5                	cmp    %eax,%ebp
  8020d5:	73 04                	jae    8020db <__udivdi3+0xfb>
  8020d7:	39 d6                	cmp    %edx,%esi
  8020d9:	74 0d                	je     8020e8 <__udivdi3+0x108>
  8020db:	89 d8                	mov    %ebx,%eax
  8020dd:	31 ff                	xor    %edi,%edi
  8020df:	e9 3c ff ff ff       	jmp    802020 <__udivdi3+0x40>
  8020e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020e8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8020eb:	31 ff                	xor    %edi,%edi
  8020ed:	e9 2e ff ff ff       	jmp    802020 <__udivdi3+0x40>
  8020f2:	66 90                	xchg   %ax,%ax
  8020f4:	66 90                	xchg   %ax,%ax
  8020f6:	66 90                	xchg   %ax,%ax
  8020f8:	66 90                	xchg   %ax,%ax
  8020fa:	66 90                	xchg   %ax,%ax
  8020fc:	66 90                	xchg   %ax,%ax
  8020fe:	66 90                	xchg   %ax,%ax

00802100 <__umoddi3>:
  802100:	f3 0f 1e fb          	endbr32 
  802104:	55                   	push   %ebp
  802105:	57                   	push   %edi
  802106:	56                   	push   %esi
  802107:	53                   	push   %ebx
  802108:	83 ec 1c             	sub    $0x1c,%esp
  80210b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80210f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802113:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802117:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80211b:	89 f0                	mov    %esi,%eax
  80211d:	89 da                	mov    %ebx,%edx
  80211f:	85 ff                	test   %edi,%edi
  802121:	75 15                	jne    802138 <__umoddi3+0x38>
  802123:	39 dd                	cmp    %ebx,%ebp
  802125:	76 39                	jbe    802160 <__umoddi3+0x60>
  802127:	f7 f5                	div    %ebp
  802129:	89 d0                	mov    %edx,%eax
  80212b:	31 d2                	xor    %edx,%edx
  80212d:	83 c4 1c             	add    $0x1c,%esp
  802130:	5b                   	pop    %ebx
  802131:	5e                   	pop    %esi
  802132:	5f                   	pop    %edi
  802133:	5d                   	pop    %ebp
  802134:	c3                   	ret    
  802135:	8d 76 00             	lea    0x0(%esi),%esi
  802138:	39 df                	cmp    %ebx,%edi
  80213a:	77 f1                	ja     80212d <__umoddi3+0x2d>
  80213c:	0f bd cf             	bsr    %edi,%ecx
  80213f:	83 f1 1f             	xor    $0x1f,%ecx
  802142:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802146:	75 40                	jne    802188 <__umoddi3+0x88>
  802148:	39 df                	cmp    %ebx,%edi
  80214a:	72 04                	jb     802150 <__umoddi3+0x50>
  80214c:	39 f5                	cmp    %esi,%ebp
  80214e:	77 dd                	ja     80212d <__umoddi3+0x2d>
  802150:	89 da                	mov    %ebx,%edx
  802152:	89 f0                	mov    %esi,%eax
  802154:	29 e8                	sub    %ebp,%eax
  802156:	19 fa                	sbb    %edi,%edx
  802158:	eb d3                	jmp    80212d <__umoddi3+0x2d>
  80215a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802160:	89 e9                	mov    %ebp,%ecx
  802162:	85 ed                	test   %ebp,%ebp
  802164:	75 0b                	jne    802171 <__umoddi3+0x71>
  802166:	b8 01 00 00 00       	mov    $0x1,%eax
  80216b:	31 d2                	xor    %edx,%edx
  80216d:	f7 f5                	div    %ebp
  80216f:	89 c1                	mov    %eax,%ecx
  802171:	89 d8                	mov    %ebx,%eax
  802173:	31 d2                	xor    %edx,%edx
  802175:	f7 f1                	div    %ecx
  802177:	89 f0                	mov    %esi,%eax
  802179:	f7 f1                	div    %ecx
  80217b:	89 d0                	mov    %edx,%eax
  80217d:	31 d2                	xor    %edx,%edx
  80217f:	eb ac                	jmp    80212d <__umoddi3+0x2d>
  802181:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802188:	8b 44 24 04          	mov    0x4(%esp),%eax
  80218c:	ba 20 00 00 00       	mov    $0x20,%edx
  802191:	29 c2                	sub    %eax,%edx
  802193:	89 c1                	mov    %eax,%ecx
  802195:	89 e8                	mov    %ebp,%eax
  802197:	d3 e7                	shl    %cl,%edi
  802199:	89 d1                	mov    %edx,%ecx
  80219b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80219f:	d3 e8                	shr    %cl,%eax
  8021a1:	89 c1                	mov    %eax,%ecx
  8021a3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021a7:	09 f9                	or     %edi,%ecx
  8021a9:	89 df                	mov    %ebx,%edi
  8021ab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021af:	89 c1                	mov    %eax,%ecx
  8021b1:	d3 e5                	shl    %cl,%ebp
  8021b3:	89 d1                	mov    %edx,%ecx
  8021b5:	d3 ef                	shr    %cl,%edi
  8021b7:	89 c1                	mov    %eax,%ecx
  8021b9:	89 f0                	mov    %esi,%eax
  8021bb:	d3 e3                	shl    %cl,%ebx
  8021bd:	89 d1                	mov    %edx,%ecx
  8021bf:	89 fa                	mov    %edi,%edx
  8021c1:	d3 e8                	shr    %cl,%eax
  8021c3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021c8:	09 d8                	or     %ebx,%eax
  8021ca:	f7 74 24 08          	divl   0x8(%esp)
  8021ce:	89 d3                	mov    %edx,%ebx
  8021d0:	d3 e6                	shl    %cl,%esi
  8021d2:	f7 e5                	mul    %ebp
  8021d4:	89 c7                	mov    %eax,%edi
  8021d6:	89 d1                	mov    %edx,%ecx
  8021d8:	39 d3                	cmp    %edx,%ebx
  8021da:	72 06                	jb     8021e2 <__umoddi3+0xe2>
  8021dc:	75 0e                	jne    8021ec <__umoddi3+0xec>
  8021de:	39 c6                	cmp    %eax,%esi
  8021e0:	73 0a                	jae    8021ec <__umoddi3+0xec>
  8021e2:	29 e8                	sub    %ebp,%eax
  8021e4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8021e8:	89 d1                	mov    %edx,%ecx
  8021ea:	89 c7                	mov    %eax,%edi
  8021ec:	89 f5                	mov    %esi,%ebp
  8021ee:	8b 74 24 04          	mov    0x4(%esp),%esi
  8021f2:	29 fd                	sub    %edi,%ebp
  8021f4:	19 cb                	sbb    %ecx,%ebx
  8021f6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8021fb:	89 d8                	mov    %ebx,%eax
  8021fd:	d3 e0                	shl    %cl,%eax
  8021ff:	89 f1                	mov    %esi,%ecx
  802201:	d3 ed                	shr    %cl,%ebp
  802203:	d3 eb                	shr    %cl,%ebx
  802205:	09 e8                	or     %ebp,%eax
  802207:	89 da                	mov    %ebx,%edx
  802209:	83 c4 1c             	add    $0x1c,%esp
  80220c:	5b                   	pop    %ebx
  80220d:	5e                   	pop    %esi
  80220e:	5f                   	pop    %edi
  80220f:	5d                   	pop    %ebp
  802210:	c3                   	ret    
