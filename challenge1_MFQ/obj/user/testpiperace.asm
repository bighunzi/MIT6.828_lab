
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
  80002c:	e8 c3 01 00 00       	call   8001f4 <libmain>
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
  80003b:	68 20 27 80 00       	push   $0x802720
  800040:	e8 ed 02 00 00       	call   800332 <cprintf>
	if ((r = pipe(p)) < 0)
  800045:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800048:	89 04 24             	mov    %eax,(%esp)
  80004b:	e8 e7 20 00 00       	call   802137 <pipe>
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	78 5f                	js     8000b6 <umain+0x83>
		panic("pipe: %e", r);
	max = 200;
	if ((r = fork()) < 0)
  800057:	e8 fc 0f 00 00       	call   801058 <fork>
  80005c:	89 c6                	mov    %eax,%esi
  80005e:	85 c0                	test   %eax,%eax
  800060:	78 66                	js     8000c8 <umain+0x95>
		panic("fork: %e", r);
	if (r == 0) {
  800062:	74 76                	je     8000da <umain+0xa7>
		}
		// do something to be not runnable besides exiting
		ipc_recv(0,0,0);
	}
	pid = r;
	cprintf("pid is %d\n", pid);
  800064:	83 ec 08             	sub    $0x8,%esp
  800067:	56                   	push   %esi
  800068:	68 71 27 80 00       	push   $0x802771
  80006d:	e8 c0 02 00 00       	call   800332 <cprintf>
	va = 0;
	kid = &envs[ENVX(pid)];
  800072:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
	cprintf("kid is %d\n", kid-envs);
  800078:	83 c4 08             	add    $0x8,%esp
  80007b:	69 c6 8c 00 00 00    	imul   $0x8c,%esi,%eax
  800081:	c1 f8 02             	sar    $0x2,%eax
  800084:	69 c0 8b af f8 8a    	imul   $0x8af8af8b,%eax,%eax
  80008a:	50                   	push   %eax
  80008b:	68 7c 27 80 00       	push   $0x80277c
  800090:	e8 9d 02 00 00       	call   800332 <cprintf>
	dup(p[0], 10);
  800095:	83 c4 08             	add    $0x8,%esp
  800098:	6a 0a                	push   $0xa
  80009a:	ff 75 f0             	push   -0x10(%ebp)
  80009d:	e8 32 14 00 00       	call   8014d4 <dup>
	while (kid->env_status == ENV_RUNNABLE)
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	69 de 8c 00 00 00    	imul   $0x8c,%esi,%ebx
  8000ab:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  8000b1:	e9 92 00 00 00       	jmp    800148 <umain+0x115>
		panic("pipe: %e", r);
  8000b6:	50                   	push   %eax
  8000b7:	68 39 27 80 00       	push   $0x802739
  8000bc:	6a 0d                	push   $0xd
  8000be:	68 42 27 80 00       	push   $0x802742
  8000c3:	e8 8f 01 00 00       	call   800257 <_panic>
		panic("fork: %e", r);
  8000c8:	50                   	push   %eax
  8000c9:	68 18 2c 80 00       	push   $0x802c18
  8000ce:	6a 10                	push   $0x10
  8000d0:	68 42 27 80 00       	push   $0x802742
  8000d5:	e8 7d 01 00 00       	call   800257 <_panic>
		close(p[1]);
  8000da:	83 ec 0c             	sub    $0xc,%esp
  8000dd:	ff 75 f4             	push   -0xc(%ebp)
  8000e0:	e8 9d 13 00 00       	call   801482 <close>
  8000e5:	83 c4 10             	add    $0x10,%esp
  8000e8:	bb c8 00 00 00       	mov    $0xc8,%ebx
  8000ed:	eb 0a                	jmp    8000f9 <umain+0xc6>
			sys_yield();
  8000ef:	e8 f5 0b 00 00       	call   800ce9 <sys_yield>
		for (i=0; i<max; i++) {
  8000f4:	83 eb 01             	sub    $0x1,%ebx
  8000f7:	74 29                	je     800122 <umain+0xef>
			if(pipeisclosed(p[0])){
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	ff 75 f0             	push   -0x10(%ebp)
  8000ff:	e8 7d 21 00 00       	call   802281 <pipeisclosed>
  800104:	83 c4 10             	add    $0x10,%esp
  800107:	85 c0                	test   %eax,%eax
  800109:	74 e4                	je     8000ef <umain+0xbc>
				cprintf("RACE: pipe appears closed\n");
  80010b:	83 ec 0c             	sub    $0xc,%esp
  80010e:	68 56 27 80 00       	push   $0x802756
  800113:	e8 1a 02 00 00       	call   800332 <cprintf>
				exit();
  800118:	e8 20 01 00 00       	call   80023d <exit>
  80011d:	83 c4 10             	add    $0x10,%esp
  800120:	eb cd                	jmp    8000ef <umain+0xbc>
		ipc_recv(0,0,0);
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	6a 00                	push   $0x0
  800127:	6a 00                	push   $0x0
  800129:	6a 00                	push   $0x0
  80012b:	e8 ab 10 00 00       	call   8011db <ipc_recv>
  800130:	83 c4 10             	add    $0x10,%esp
  800133:	e9 2c ff ff ff       	jmp    800064 <umain+0x31>
		dup(p[0], 10);
  800138:	83 ec 08             	sub    $0x8,%esp
  80013b:	6a 0a                	push   $0xa
  80013d:	ff 75 f0             	push   -0x10(%ebp)
  800140:	e8 8f 13 00 00       	call   8014d4 <dup>
  800145:	83 c4 10             	add    $0x10,%esp
	while (kid->env_status == ENV_RUNNABLE)
  800148:	8b 43 64             	mov    0x64(%ebx),%eax
  80014b:	83 f8 02             	cmp    $0x2,%eax
  80014e:	74 e8                	je     800138 <umain+0x105>

	cprintf("child done with loop\n");
  800150:	83 ec 0c             	sub    $0xc,%esp
  800153:	68 87 27 80 00       	push   $0x802787
  800158:	e8 d5 01 00 00       	call   800332 <cprintf>
	if (pipeisclosed(p[0]))
  80015d:	83 c4 04             	add    $0x4,%esp
  800160:	ff 75 f0             	push   -0x10(%ebp)
  800163:	e8 19 21 00 00       	call   802281 <pipeisclosed>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	85 c0                	test   %eax,%eax
  80016d:	75 48                	jne    8001b7 <umain+0x184>
		panic("somehow the other end of p[0] got closed!");
	if ((r = fd_lookup(p[0], &fd)) < 0)
  80016f:	83 ec 08             	sub    $0x8,%esp
  800172:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800175:	50                   	push   %eax
  800176:	ff 75 f0             	push   -0x10(%ebp)
  800179:	e8 d7 11 00 00       	call   801355 <fd_lookup>
  80017e:	83 c4 10             	add    $0x10,%esp
  800181:	85 c0                	test   %eax,%eax
  800183:	78 46                	js     8001cb <umain+0x198>
		panic("cannot look up p[0]: %e", r);
	va = fd2data(fd);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	ff 75 ec             	push   -0x14(%ebp)
  80018b:	e8 5e 11 00 00       	call   8012ee <fd2data>
	if (pageref(va) != 3+1)
  800190:	89 04 24             	mov    %eax,(%esp)
  800193:	e8 2e 19 00 00       	call   801ac6 <pageref>
  800198:	83 c4 10             	add    $0x10,%esp
  80019b:	83 f8 04             	cmp    $0x4,%eax
  80019e:	74 3d                	je     8001dd <umain+0x1aa>
		cprintf("\nchild detected race\n");
  8001a0:	83 ec 0c             	sub    $0xc,%esp
  8001a3:	68 b5 27 80 00       	push   $0x8027b5
  8001a8:	e8 85 01 00 00       	call   800332 <cprintf>
  8001ad:	83 c4 10             	add    $0x10,%esp
	else
		cprintf("\nrace didn't happen\n", max);
}
  8001b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001b3:	5b                   	pop    %ebx
  8001b4:	5e                   	pop    %esi
  8001b5:	5d                   	pop    %ebp
  8001b6:	c3                   	ret    
		panic("somehow the other end of p[0] got closed!");
  8001b7:	83 ec 04             	sub    $0x4,%esp
  8001ba:	68 e0 27 80 00       	push   $0x8027e0
  8001bf:	6a 3a                	push   $0x3a
  8001c1:	68 42 27 80 00       	push   $0x802742
  8001c6:	e8 8c 00 00 00       	call   800257 <_panic>
		panic("cannot look up p[0]: %e", r);
  8001cb:	50                   	push   %eax
  8001cc:	68 9d 27 80 00       	push   $0x80279d
  8001d1:	6a 3c                	push   $0x3c
  8001d3:	68 42 27 80 00       	push   $0x802742
  8001d8:	e8 7a 00 00 00       	call   800257 <_panic>
		cprintf("\nrace didn't happen\n", max);
  8001dd:	83 ec 08             	sub    $0x8,%esp
  8001e0:	68 c8 00 00 00       	push   $0xc8
  8001e5:	68 cb 27 80 00       	push   $0x8027cb
  8001ea:	e8 43 01 00 00       	call   800332 <cprintf>
  8001ef:	83 c4 10             	add    $0x10,%esp
}
  8001f2:	eb bc                	jmp    8001b0 <umain+0x17d>

008001f4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001f4:	55                   	push   %ebp
  8001f5:	89 e5                	mov    %esp,%ebp
  8001f7:	56                   	push   %esi
  8001f8:	53                   	push   %ebx
  8001f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001fc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8001ff:	e8 c6 0a 00 00       	call   800cca <sys_getenvid>
  800204:	25 ff 03 00 00       	and    $0x3ff,%eax
  800209:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80020f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800214:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800219:	85 db                	test   %ebx,%ebx
  80021b:	7e 07                	jle    800224 <libmain+0x30>
		binaryname = argv[0];
  80021d:	8b 06                	mov    (%esi),%eax
  80021f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	56                   	push   %esi
  800228:	53                   	push   %ebx
  800229:	e8 05 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80022e:	e8 0a 00 00 00       	call   80023d <exit>
}
  800233:	83 c4 10             	add    $0x10,%esp
  800236:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800239:	5b                   	pop    %ebx
  80023a:	5e                   	pop    %esi
  80023b:	5d                   	pop    %ebp
  80023c:	c3                   	ret    

0080023d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800243:	e8 67 12 00 00       	call   8014af <close_all>
	sys_env_destroy(0);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	6a 00                	push   $0x0
  80024d:	e8 37 0a 00 00       	call   800c89 <sys_env_destroy>
}
  800252:	83 c4 10             	add    $0x10,%esp
  800255:	c9                   	leave  
  800256:	c3                   	ret    

00800257 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	56                   	push   %esi
  80025b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80025c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80025f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800265:	e8 60 0a 00 00       	call   800cca <sys_getenvid>
  80026a:	83 ec 0c             	sub    $0xc,%esp
  80026d:	ff 75 0c             	push   0xc(%ebp)
  800270:	ff 75 08             	push   0x8(%ebp)
  800273:	56                   	push   %esi
  800274:	50                   	push   %eax
  800275:	68 14 28 80 00       	push   $0x802814
  80027a:	e8 b3 00 00 00       	call   800332 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80027f:	83 c4 18             	add    $0x18,%esp
  800282:	53                   	push   %ebx
  800283:	ff 75 10             	push   0x10(%ebp)
  800286:	e8 56 00 00 00       	call   8002e1 <vcprintf>
	cprintf("\n");
  80028b:	c7 04 24 37 27 80 00 	movl   $0x802737,(%esp)
  800292:	e8 9b 00 00 00       	call   800332 <cprintf>
  800297:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80029a:	cc                   	int3   
  80029b:	eb fd                	jmp    80029a <_panic+0x43>

0080029d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	53                   	push   %ebx
  8002a1:	83 ec 04             	sub    $0x4,%esp
  8002a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002a7:	8b 13                	mov    (%ebx),%edx
  8002a9:	8d 42 01             	lea    0x1(%edx),%eax
  8002ac:	89 03                	mov    %eax,(%ebx)
  8002ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002b1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002b5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002ba:	74 09                	je     8002c5 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002bc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8002c3:	c9                   	leave  
  8002c4:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8002c5:	83 ec 08             	sub    $0x8,%esp
  8002c8:	68 ff 00 00 00       	push   $0xff
  8002cd:	8d 43 08             	lea    0x8(%ebx),%eax
  8002d0:	50                   	push   %eax
  8002d1:	e8 76 09 00 00       	call   800c4c <sys_cputs>
		b->idx = 0;
  8002d6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002dc:	83 c4 10             	add    $0x10,%esp
  8002df:	eb db                	jmp    8002bc <putch+0x1f>

008002e1 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002ea:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002f1:	00 00 00 
	b.cnt = 0;
  8002f4:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002fb:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002fe:	ff 75 0c             	push   0xc(%ebp)
  800301:	ff 75 08             	push   0x8(%ebp)
  800304:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80030a:	50                   	push   %eax
  80030b:	68 9d 02 80 00       	push   $0x80029d
  800310:	e8 14 01 00 00       	call   800429 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800315:	83 c4 08             	add    $0x8,%esp
  800318:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80031e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800324:	50                   	push   %eax
  800325:	e8 22 09 00 00       	call   800c4c <sys_cputs>

	return b.cnt;
}
  80032a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800338:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80033b:	50                   	push   %eax
  80033c:	ff 75 08             	push   0x8(%ebp)
  80033f:	e8 9d ff ff ff       	call   8002e1 <vcprintf>
	va_end(ap);

	return cnt;
}
  800344:	c9                   	leave  
  800345:	c3                   	ret    

00800346 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	57                   	push   %edi
  80034a:	56                   	push   %esi
  80034b:	53                   	push   %ebx
  80034c:	83 ec 1c             	sub    $0x1c,%esp
  80034f:	89 c7                	mov    %eax,%edi
  800351:	89 d6                	mov    %edx,%esi
  800353:	8b 45 08             	mov    0x8(%ebp),%eax
  800356:	8b 55 0c             	mov    0xc(%ebp),%edx
  800359:	89 d1                	mov    %edx,%ecx
  80035b:	89 c2                	mov    %eax,%edx
  80035d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800360:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800363:	8b 45 10             	mov    0x10(%ebp),%eax
  800366:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800369:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80036c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800373:	39 c2                	cmp    %eax,%edx
  800375:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800378:	72 3e                	jb     8003b8 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80037a:	83 ec 0c             	sub    $0xc,%esp
  80037d:	ff 75 18             	push   0x18(%ebp)
  800380:	83 eb 01             	sub    $0x1,%ebx
  800383:	53                   	push   %ebx
  800384:	50                   	push   %eax
  800385:	83 ec 08             	sub    $0x8,%esp
  800388:	ff 75 e4             	push   -0x1c(%ebp)
  80038b:	ff 75 e0             	push   -0x20(%ebp)
  80038e:	ff 75 dc             	push   -0x24(%ebp)
  800391:	ff 75 d8             	push   -0x28(%ebp)
  800394:	e8 37 21 00 00       	call   8024d0 <__udivdi3>
  800399:	83 c4 18             	add    $0x18,%esp
  80039c:	52                   	push   %edx
  80039d:	50                   	push   %eax
  80039e:	89 f2                	mov    %esi,%edx
  8003a0:	89 f8                	mov    %edi,%eax
  8003a2:	e8 9f ff ff ff       	call   800346 <printnum>
  8003a7:	83 c4 20             	add    $0x20,%esp
  8003aa:	eb 13                	jmp    8003bf <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ac:	83 ec 08             	sub    $0x8,%esp
  8003af:	56                   	push   %esi
  8003b0:	ff 75 18             	push   0x18(%ebp)
  8003b3:	ff d7                	call   *%edi
  8003b5:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003b8:	83 eb 01             	sub    $0x1,%ebx
  8003bb:	85 db                	test   %ebx,%ebx
  8003bd:	7f ed                	jg     8003ac <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003bf:	83 ec 08             	sub    $0x8,%esp
  8003c2:	56                   	push   %esi
  8003c3:	83 ec 04             	sub    $0x4,%esp
  8003c6:	ff 75 e4             	push   -0x1c(%ebp)
  8003c9:	ff 75 e0             	push   -0x20(%ebp)
  8003cc:	ff 75 dc             	push   -0x24(%ebp)
  8003cf:	ff 75 d8             	push   -0x28(%ebp)
  8003d2:	e8 19 22 00 00       	call   8025f0 <__umoddi3>
  8003d7:	83 c4 14             	add    $0x14,%esp
  8003da:	0f be 80 37 28 80 00 	movsbl 0x802837(%eax),%eax
  8003e1:	50                   	push   %eax
  8003e2:	ff d7                	call   *%edi
}
  8003e4:	83 c4 10             	add    $0x10,%esp
  8003e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003ea:	5b                   	pop    %ebx
  8003eb:	5e                   	pop    %esi
  8003ec:	5f                   	pop    %edi
  8003ed:	5d                   	pop    %ebp
  8003ee:	c3                   	ret    

008003ef <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003f5:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003f9:	8b 10                	mov    (%eax),%edx
  8003fb:	3b 50 04             	cmp    0x4(%eax),%edx
  8003fe:	73 0a                	jae    80040a <sprintputch+0x1b>
		*b->buf++ = ch;
  800400:	8d 4a 01             	lea    0x1(%edx),%ecx
  800403:	89 08                	mov    %ecx,(%eax)
  800405:	8b 45 08             	mov    0x8(%ebp),%eax
  800408:	88 02                	mov    %al,(%edx)
}
  80040a:	5d                   	pop    %ebp
  80040b:	c3                   	ret    

0080040c <printfmt>:
{
  80040c:	55                   	push   %ebp
  80040d:	89 e5                	mov    %esp,%ebp
  80040f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800412:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800415:	50                   	push   %eax
  800416:	ff 75 10             	push   0x10(%ebp)
  800419:	ff 75 0c             	push   0xc(%ebp)
  80041c:	ff 75 08             	push   0x8(%ebp)
  80041f:	e8 05 00 00 00       	call   800429 <vprintfmt>
}
  800424:	83 c4 10             	add    $0x10,%esp
  800427:	c9                   	leave  
  800428:	c3                   	ret    

00800429 <vprintfmt>:
{
  800429:	55                   	push   %ebp
  80042a:	89 e5                	mov    %esp,%ebp
  80042c:	57                   	push   %edi
  80042d:	56                   	push   %esi
  80042e:	53                   	push   %ebx
  80042f:	83 ec 3c             	sub    $0x3c,%esp
  800432:	8b 75 08             	mov    0x8(%ebp),%esi
  800435:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800438:	8b 7d 10             	mov    0x10(%ebp),%edi
  80043b:	eb 0a                	jmp    800447 <vprintfmt+0x1e>
			putch(ch, putdat);
  80043d:	83 ec 08             	sub    $0x8,%esp
  800440:	53                   	push   %ebx
  800441:	50                   	push   %eax
  800442:	ff d6                	call   *%esi
  800444:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800447:	83 c7 01             	add    $0x1,%edi
  80044a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80044e:	83 f8 25             	cmp    $0x25,%eax
  800451:	74 0c                	je     80045f <vprintfmt+0x36>
			if (ch == '\0')
  800453:	85 c0                	test   %eax,%eax
  800455:	75 e6                	jne    80043d <vprintfmt+0x14>
}
  800457:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80045a:	5b                   	pop    %ebx
  80045b:	5e                   	pop    %esi
  80045c:	5f                   	pop    %edi
  80045d:	5d                   	pop    %ebp
  80045e:	c3                   	ret    
		padc = ' ';
  80045f:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800463:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80046a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800471:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800478:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8d 47 01             	lea    0x1(%edi),%eax
  800480:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800483:	0f b6 17             	movzbl (%edi),%edx
  800486:	8d 42 dd             	lea    -0x23(%edx),%eax
  800489:	3c 55                	cmp    $0x55,%al
  80048b:	0f 87 bb 03 00 00    	ja     80084c <vprintfmt+0x423>
  800491:	0f b6 c0             	movzbl %al,%eax
  800494:	ff 24 85 80 29 80 00 	jmp    *0x802980(,%eax,4)
  80049b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80049e:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8004a2:	eb d9                	jmp    80047d <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8004a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004a7:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8004ab:	eb d0                	jmp    80047d <vprintfmt+0x54>
  8004ad:	0f b6 d2             	movzbl %dl,%edx
  8004b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8004b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8004bb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004be:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004c2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004c5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004c8:	83 f9 09             	cmp    $0x9,%ecx
  8004cb:	77 55                	ja     800522 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8004cd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004d0:	eb e9                	jmp    8004bb <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8004d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004d5:	8b 00                	mov    (%eax),%eax
  8004d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004da:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dd:	8d 40 04             	lea    0x4(%eax),%eax
  8004e0:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004e6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004ea:	79 91                	jns    80047d <vprintfmt+0x54>
				width = precision, precision = -1;
  8004ec:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004ef:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f2:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004f9:	eb 82                	jmp    80047d <vprintfmt+0x54>
  8004fb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004fe:	85 d2                	test   %edx,%edx
  800500:	b8 00 00 00 00       	mov    $0x0,%eax
  800505:	0f 49 c2             	cmovns %edx,%eax
  800508:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80050b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80050e:	e9 6a ff ff ff       	jmp    80047d <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800513:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800516:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80051d:	e9 5b ff ff ff       	jmp    80047d <vprintfmt+0x54>
  800522:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800525:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800528:	eb bc                	jmp    8004e6 <vprintfmt+0xbd>
			lflag++;
  80052a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80052d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800530:	e9 48 ff ff ff       	jmp    80047d <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800535:	8b 45 14             	mov    0x14(%ebp),%eax
  800538:	8d 78 04             	lea    0x4(%eax),%edi
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	53                   	push   %ebx
  80053f:	ff 30                	push   (%eax)
  800541:	ff d6                	call   *%esi
			break;
  800543:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800546:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800549:	e9 9d 02 00 00       	jmp    8007eb <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8d 78 04             	lea    0x4(%eax),%edi
  800554:	8b 10                	mov    (%eax),%edx
  800556:	89 d0                	mov    %edx,%eax
  800558:	f7 d8                	neg    %eax
  80055a:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055d:	83 f8 0f             	cmp    $0xf,%eax
  800560:	7f 23                	jg     800585 <vprintfmt+0x15c>
  800562:	8b 14 85 e0 2a 80 00 	mov    0x802ae0(,%eax,4),%edx
  800569:	85 d2                	test   %edx,%edx
  80056b:	74 18                	je     800585 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80056d:	52                   	push   %edx
  80056e:	68 01 2d 80 00       	push   $0x802d01
  800573:	53                   	push   %ebx
  800574:	56                   	push   %esi
  800575:	e8 92 fe ff ff       	call   80040c <printfmt>
  80057a:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80057d:	89 7d 14             	mov    %edi,0x14(%ebp)
  800580:	e9 66 02 00 00       	jmp    8007eb <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800585:	50                   	push   %eax
  800586:	68 4f 28 80 00       	push   $0x80284f
  80058b:	53                   	push   %ebx
  80058c:	56                   	push   %esi
  80058d:	e8 7a fe ff ff       	call   80040c <printfmt>
  800592:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800595:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800598:	e9 4e 02 00 00       	jmp    8007eb <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	83 c0 04             	add    $0x4,%eax
  8005a3:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8005ab:	85 d2                	test   %edx,%edx
  8005ad:	b8 48 28 80 00       	mov    $0x802848,%eax
  8005b2:	0f 45 c2             	cmovne %edx,%eax
  8005b5:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005b8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005bc:	7e 06                	jle    8005c4 <vprintfmt+0x19b>
  8005be:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8005c2:	75 0d                	jne    8005d1 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c4:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005c7:	89 c7                	mov    %eax,%edi
  8005c9:	03 45 e0             	add    -0x20(%ebp),%eax
  8005cc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005cf:	eb 55                	jmp    800626 <vprintfmt+0x1fd>
  8005d1:	83 ec 08             	sub    $0x8,%esp
  8005d4:	ff 75 d8             	push   -0x28(%ebp)
  8005d7:	ff 75 cc             	push   -0x34(%ebp)
  8005da:	e8 0a 03 00 00       	call   8008e9 <strnlen>
  8005df:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005e2:	29 c1                	sub    %eax,%ecx
  8005e4:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8005e7:	83 c4 10             	add    $0x10,%esp
  8005ea:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8005ec:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005f0:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005f3:	eb 0f                	jmp    800604 <vprintfmt+0x1db>
					putch(padc, putdat);
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	53                   	push   %ebx
  8005f9:	ff 75 e0             	push   -0x20(%ebp)
  8005fc:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fe:	83 ef 01             	sub    $0x1,%edi
  800601:	83 c4 10             	add    $0x10,%esp
  800604:	85 ff                	test   %edi,%edi
  800606:	7f ed                	jg     8005f5 <vprintfmt+0x1cc>
  800608:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80060b:	85 d2                	test   %edx,%edx
  80060d:	b8 00 00 00 00       	mov    $0x0,%eax
  800612:	0f 49 c2             	cmovns %edx,%eax
  800615:	29 c2                	sub    %eax,%edx
  800617:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80061a:	eb a8                	jmp    8005c4 <vprintfmt+0x19b>
					putch(ch, putdat);
  80061c:	83 ec 08             	sub    $0x8,%esp
  80061f:	53                   	push   %ebx
  800620:	52                   	push   %edx
  800621:	ff d6                	call   *%esi
  800623:	83 c4 10             	add    $0x10,%esp
  800626:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800629:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80062b:	83 c7 01             	add    $0x1,%edi
  80062e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800632:	0f be d0             	movsbl %al,%edx
  800635:	85 d2                	test   %edx,%edx
  800637:	74 4b                	je     800684 <vprintfmt+0x25b>
  800639:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80063d:	78 06                	js     800645 <vprintfmt+0x21c>
  80063f:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800643:	78 1e                	js     800663 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800645:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800649:	74 d1                	je     80061c <vprintfmt+0x1f3>
  80064b:	0f be c0             	movsbl %al,%eax
  80064e:	83 e8 20             	sub    $0x20,%eax
  800651:	83 f8 5e             	cmp    $0x5e,%eax
  800654:	76 c6                	jbe    80061c <vprintfmt+0x1f3>
					putch('?', putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	53                   	push   %ebx
  80065a:	6a 3f                	push   $0x3f
  80065c:	ff d6                	call   *%esi
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	eb c3                	jmp    800626 <vprintfmt+0x1fd>
  800663:	89 cf                	mov    %ecx,%edi
  800665:	eb 0e                	jmp    800675 <vprintfmt+0x24c>
				putch(' ', putdat);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	53                   	push   %ebx
  80066b:	6a 20                	push   $0x20
  80066d:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80066f:	83 ef 01             	sub    $0x1,%edi
  800672:	83 c4 10             	add    $0x10,%esp
  800675:	85 ff                	test   %edi,%edi
  800677:	7f ee                	jg     800667 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800679:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80067c:	89 45 14             	mov    %eax,0x14(%ebp)
  80067f:	e9 67 01 00 00       	jmp    8007eb <vprintfmt+0x3c2>
  800684:	89 cf                	mov    %ecx,%edi
  800686:	eb ed                	jmp    800675 <vprintfmt+0x24c>
	if (lflag >= 2)
  800688:	83 f9 01             	cmp    $0x1,%ecx
  80068b:	7f 1b                	jg     8006a8 <vprintfmt+0x27f>
	else if (lflag)
  80068d:	85 c9                	test   %ecx,%ecx
  80068f:	74 63                	je     8006f4 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8b 00                	mov    (%eax),%eax
  800696:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800699:	99                   	cltd   
  80069a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80069d:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a0:	8d 40 04             	lea    0x4(%eax),%eax
  8006a3:	89 45 14             	mov    %eax,0x14(%ebp)
  8006a6:	eb 17                	jmp    8006bf <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8b 50 04             	mov    0x4(%eax),%edx
  8006ae:	8b 00                	mov    (%eax),%eax
  8006b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8d 40 08             	lea    0x8(%eax),%eax
  8006bc:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006bf:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006c2:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8006c5:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8006ca:	85 c9                	test   %ecx,%ecx
  8006cc:	0f 89 ff 00 00 00    	jns    8007d1 <vprintfmt+0x3a8>
				putch('-', putdat);
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	6a 2d                	push   $0x2d
  8006d8:	ff d6                	call   *%esi
				num = -(long long) num;
  8006da:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006dd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006e0:	f7 da                	neg    %edx
  8006e2:	83 d1 00             	adc    $0x0,%ecx
  8006e5:	f7 d9                	neg    %ecx
  8006e7:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006ea:	bf 0a 00 00 00       	mov    $0xa,%edi
  8006ef:	e9 dd 00 00 00       	jmp    8007d1 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8b 00                	mov    (%eax),%eax
  8006f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fc:	99                   	cltd   
  8006fd:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800700:	8b 45 14             	mov    0x14(%ebp),%eax
  800703:	8d 40 04             	lea    0x4(%eax),%eax
  800706:	89 45 14             	mov    %eax,0x14(%ebp)
  800709:	eb b4                	jmp    8006bf <vprintfmt+0x296>
	if (lflag >= 2)
  80070b:	83 f9 01             	cmp    $0x1,%ecx
  80070e:	7f 1e                	jg     80072e <vprintfmt+0x305>
	else if (lflag)
  800710:	85 c9                	test   %ecx,%ecx
  800712:	74 32                	je     800746 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8b 10                	mov    (%eax),%edx
  800719:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071e:	8d 40 04             	lea    0x4(%eax),%eax
  800721:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800724:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800729:	e9 a3 00 00 00       	jmp    8007d1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80072e:	8b 45 14             	mov    0x14(%ebp),%eax
  800731:	8b 10                	mov    (%eax),%edx
  800733:	8b 48 04             	mov    0x4(%eax),%ecx
  800736:	8d 40 08             	lea    0x8(%eax),%eax
  800739:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80073c:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800741:	e9 8b 00 00 00       	jmp    8007d1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800746:	8b 45 14             	mov    0x14(%ebp),%eax
  800749:	8b 10                	mov    (%eax),%edx
  80074b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800750:	8d 40 04             	lea    0x4(%eax),%eax
  800753:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800756:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80075b:	eb 74                	jmp    8007d1 <vprintfmt+0x3a8>
	if (lflag >= 2)
  80075d:	83 f9 01             	cmp    $0x1,%ecx
  800760:	7f 1b                	jg     80077d <vprintfmt+0x354>
	else if (lflag)
  800762:	85 c9                	test   %ecx,%ecx
  800764:	74 2c                	je     800792 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	8b 10                	mov    (%eax),%edx
  80076b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800770:	8d 40 04             	lea    0x4(%eax),%eax
  800773:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800776:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80077b:	eb 54                	jmp    8007d1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80077d:	8b 45 14             	mov    0x14(%ebp),%eax
  800780:	8b 10                	mov    (%eax),%edx
  800782:	8b 48 04             	mov    0x4(%eax),%ecx
  800785:	8d 40 08             	lea    0x8(%eax),%eax
  800788:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80078b:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800790:	eb 3f                	jmp    8007d1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800792:	8b 45 14             	mov    0x14(%ebp),%eax
  800795:	8b 10                	mov    (%eax),%edx
  800797:	b9 00 00 00 00       	mov    $0x0,%ecx
  80079c:	8d 40 04             	lea    0x4(%eax),%eax
  80079f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8007a2:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8007a7:	eb 28                	jmp    8007d1 <vprintfmt+0x3a8>
			putch('0', putdat);
  8007a9:	83 ec 08             	sub    $0x8,%esp
  8007ac:	53                   	push   %ebx
  8007ad:	6a 30                	push   $0x30
  8007af:	ff d6                	call   *%esi
			putch('x', putdat);
  8007b1:	83 c4 08             	add    $0x8,%esp
  8007b4:	53                   	push   %ebx
  8007b5:	6a 78                	push   $0x78
  8007b7:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bc:	8b 10                	mov    (%eax),%edx
  8007be:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007c3:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007c6:	8d 40 04             	lea    0x4(%eax),%eax
  8007c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007cc:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8007d1:	83 ec 0c             	sub    $0xc,%esp
  8007d4:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8007d8:	50                   	push   %eax
  8007d9:	ff 75 e0             	push   -0x20(%ebp)
  8007dc:	57                   	push   %edi
  8007dd:	51                   	push   %ecx
  8007de:	52                   	push   %edx
  8007df:	89 da                	mov    %ebx,%edx
  8007e1:	89 f0                	mov    %esi,%eax
  8007e3:	e8 5e fb ff ff       	call   800346 <printnum>
			break;
  8007e8:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007ee:	e9 54 fc ff ff       	jmp    800447 <vprintfmt+0x1e>
	if (lflag >= 2)
  8007f3:	83 f9 01             	cmp    $0x1,%ecx
  8007f6:	7f 1b                	jg     800813 <vprintfmt+0x3ea>
	else if (lflag)
  8007f8:	85 c9                	test   %ecx,%ecx
  8007fa:	74 2c                	je     800828 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8007fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ff:	8b 10                	mov    (%eax),%edx
  800801:	b9 00 00 00 00       	mov    $0x0,%ecx
  800806:	8d 40 04             	lea    0x4(%eax),%eax
  800809:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80080c:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800811:	eb be                	jmp    8007d1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800813:	8b 45 14             	mov    0x14(%ebp),%eax
  800816:	8b 10                	mov    (%eax),%edx
  800818:	8b 48 04             	mov    0x4(%eax),%ecx
  80081b:	8d 40 08             	lea    0x8(%eax),%eax
  80081e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800821:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800826:	eb a9                	jmp    8007d1 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800828:	8b 45 14             	mov    0x14(%ebp),%eax
  80082b:	8b 10                	mov    (%eax),%edx
  80082d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800832:	8d 40 04             	lea    0x4(%eax),%eax
  800835:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800838:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80083d:	eb 92                	jmp    8007d1 <vprintfmt+0x3a8>
			putch(ch, putdat);
  80083f:	83 ec 08             	sub    $0x8,%esp
  800842:	53                   	push   %ebx
  800843:	6a 25                	push   $0x25
  800845:	ff d6                	call   *%esi
			break;
  800847:	83 c4 10             	add    $0x10,%esp
  80084a:	eb 9f                	jmp    8007eb <vprintfmt+0x3c2>
			putch('%', putdat);
  80084c:	83 ec 08             	sub    $0x8,%esp
  80084f:	53                   	push   %ebx
  800850:	6a 25                	push   $0x25
  800852:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800854:	83 c4 10             	add    $0x10,%esp
  800857:	89 f8                	mov    %edi,%eax
  800859:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80085d:	74 05                	je     800864 <vprintfmt+0x43b>
  80085f:	83 e8 01             	sub    $0x1,%eax
  800862:	eb f5                	jmp    800859 <vprintfmt+0x430>
  800864:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800867:	eb 82                	jmp    8007eb <vprintfmt+0x3c2>

00800869 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800869:	55                   	push   %ebp
  80086a:	89 e5                	mov    %esp,%ebp
  80086c:	83 ec 18             	sub    $0x18,%esp
  80086f:	8b 45 08             	mov    0x8(%ebp),%eax
  800872:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800875:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800878:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80087c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80087f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800886:	85 c0                	test   %eax,%eax
  800888:	74 26                	je     8008b0 <vsnprintf+0x47>
  80088a:	85 d2                	test   %edx,%edx
  80088c:	7e 22                	jle    8008b0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80088e:	ff 75 14             	push   0x14(%ebp)
  800891:	ff 75 10             	push   0x10(%ebp)
  800894:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800897:	50                   	push   %eax
  800898:	68 ef 03 80 00       	push   $0x8003ef
  80089d:	e8 87 fb ff ff       	call   800429 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008a5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ab:	83 c4 10             	add    $0x10,%esp
}
  8008ae:	c9                   	leave  
  8008af:	c3                   	ret    
		return -E_INVAL;
  8008b0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008b5:	eb f7                	jmp    8008ae <vsnprintf+0x45>

008008b7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008bd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008c0:	50                   	push   %eax
  8008c1:	ff 75 10             	push   0x10(%ebp)
  8008c4:	ff 75 0c             	push   0xc(%ebp)
  8008c7:	ff 75 08             	push   0x8(%ebp)
  8008ca:	e8 9a ff ff ff       	call   800869 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008cf:	c9                   	leave  
  8008d0:	c3                   	ret    

008008d1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008dc:	eb 03                	jmp    8008e1 <strlen+0x10>
		n++;
  8008de:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008e1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008e5:	75 f7                	jne    8008de <strlen+0xd>
	return n;
}
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ef:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f7:	eb 03                	jmp    8008fc <strnlen+0x13>
		n++;
  8008f9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008fc:	39 d0                	cmp    %edx,%eax
  8008fe:	74 08                	je     800908 <strnlen+0x1f>
  800900:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800904:	75 f3                	jne    8008f9 <strnlen+0x10>
  800906:	89 c2                	mov    %eax,%edx
	return n;
}
  800908:	89 d0                	mov    %edx,%eax
  80090a:	5d                   	pop    %ebp
  80090b:	c3                   	ret    

0080090c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80090c:	55                   	push   %ebp
  80090d:	89 e5                	mov    %esp,%ebp
  80090f:	53                   	push   %ebx
  800910:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800913:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
  80091b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80091f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800922:	83 c0 01             	add    $0x1,%eax
  800925:	84 d2                	test   %dl,%dl
  800927:	75 f2                	jne    80091b <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800929:	89 c8                	mov    %ecx,%eax
  80092b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80092e:	c9                   	leave  
  80092f:	c3                   	ret    

00800930 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	53                   	push   %ebx
  800934:	83 ec 10             	sub    $0x10,%esp
  800937:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80093a:	53                   	push   %ebx
  80093b:	e8 91 ff ff ff       	call   8008d1 <strlen>
  800940:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800943:	ff 75 0c             	push   0xc(%ebp)
  800946:	01 d8                	add    %ebx,%eax
  800948:	50                   	push   %eax
  800949:	e8 be ff ff ff       	call   80090c <strcpy>
	return dst;
}
  80094e:	89 d8                	mov    %ebx,%eax
  800950:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800953:	c9                   	leave  
  800954:	c3                   	ret    

00800955 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	56                   	push   %esi
  800959:	53                   	push   %ebx
  80095a:	8b 75 08             	mov    0x8(%ebp),%esi
  80095d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800960:	89 f3                	mov    %esi,%ebx
  800962:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800965:	89 f0                	mov    %esi,%eax
  800967:	eb 0f                	jmp    800978 <strncpy+0x23>
		*dst++ = *src;
  800969:	83 c0 01             	add    $0x1,%eax
  80096c:	0f b6 0a             	movzbl (%edx),%ecx
  80096f:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800972:	80 f9 01             	cmp    $0x1,%cl
  800975:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800978:	39 d8                	cmp    %ebx,%eax
  80097a:	75 ed                	jne    800969 <strncpy+0x14>
	}
	return ret;
}
  80097c:	89 f0                	mov    %esi,%eax
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	56                   	push   %esi
  800986:	53                   	push   %ebx
  800987:	8b 75 08             	mov    0x8(%ebp),%esi
  80098a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098d:	8b 55 10             	mov    0x10(%ebp),%edx
  800990:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800992:	85 d2                	test   %edx,%edx
  800994:	74 21                	je     8009b7 <strlcpy+0x35>
  800996:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80099a:	89 f2                	mov    %esi,%edx
  80099c:	eb 09                	jmp    8009a7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80099e:	83 c1 01             	add    $0x1,%ecx
  8009a1:	83 c2 01             	add    $0x1,%edx
  8009a4:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8009a7:	39 c2                	cmp    %eax,%edx
  8009a9:	74 09                	je     8009b4 <strlcpy+0x32>
  8009ab:	0f b6 19             	movzbl (%ecx),%ebx
  8009ae:	84 db                	test   %bl,%bl
  8009b0:	75 ec                	jne    80099e <strlcpy+0x1c>
  8009b2:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009b4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009b7:	29 f0                	sub    %esi,%eax
}
  8009b9:	5b                   	pop    %ebx
  8009ba:	5e                   	pop    %esi
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009c6:	eb 06                	jmp    8009ce <strcmp+0x11>
		p++, q++;
  8009c8:	83 c1 01             	add    $0x1,%ecx
  8009cb:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009ce:	0f b6 01             	movzbl (%ecx),%eax
  8009d1:	84 c0                	test   %al,%al
  8009d3:	74 04                	je     8009d9 <strcmp+0x1c>
  8009d5:	3a 02                	cmp    (%edx),%al
  8009d7:	74 ef                	je     8009c8 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d9:	0f b6 c0             	movzbl %al,%eax
  8009dc:	0f b6 12             	movzbl (%edx),%edx
  8009df:	29 d0                	sub    %edx,%eax
}
  8009e1:	5d                   	pop    %ebp
  8009e2:	c3                   	ret    

008009e3 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	53                   	push   %ebx
  8009e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ed:	89 c3                	mov    %eax,%ebx
  8009ef:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009f2:	eb 06                	jmp    8009fa <strncmp+0x17>
		n--, p++, q++;
  8009f4:	83 c0 01             	add    $0x1,%eax
  8009f7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009fa:	39 d8                	cmp    %ebx,%eax
  8009fc:	74 18                	je     800a16 <strncmp+0x33>
  8009fe:	0f b6 08             	movzbl (%eax),%ecx
  800a01:	84 c9                	test   %cl,%cl
  800a03:	74 04                	je     800a09 <strncmp+0x26>
  800a05:	3a 0a                	cmp    (%edx),%cl
  800a07:	74 eb                	je     8009f4 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a09:	0f b6 00             	movzbl (%eax),%eax
  800a0c:	0f b6 12             	movzbl (%edx),%edx
  800a0f:	29 d0                	sub    %edx,%eax
}
  800a11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a14:	c9                   	leave  
  800a15:	c3                   	ret    
		return 0;
  800a16:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1b:	eb f4                	jmp    800a11 <strncmp+0x2e>

00800a1d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a27:	eb 03                	jmp    800a2c <strchr+0xf>
  800a29:	83 c0 01             	add    $0x1,%eax
  800a2c:	0f b6 10             	movzbl (%eax),%edx
  800a2f:	84 d2                	test   %dl,%dl
  800a31:	74 06                	je     800a39 <strchr+0x1c>
		if (*s == c)
  800a33:	38 ca                	cmp    %cl,%dl
  800a35:	75 f2                	jne    800a29 <strchr+0xc>
  800a37:	eb 05                	jmp    800a3e <strchr+0x21>
			return (char *) s;
	return 0;
  800a39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a40:	55                   	push   %ebp
  800a41:	89 e5                	mov    %esp,%ebp
  800a43:	8b 45 08             	mov    0x8(%ebp),%eax
  800a46:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a4a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a4d:	38 ca                	cmp    %cl,%dl
  800a4f:	74 09                	je     800a5a <strfind+0x1a>
  800a51:	84 d2                	test   %dl,%dl
  800a53:	74 05                	je     800a5a <strfind+0x1a>
	for (; *s; s++)
  800a55:	83 c0 01             	add    $0x1,%eax
  800a58:	eb f0                	jmp    800a4a <strfind+0xa>
			break;
	return (char *) s;
}
  800a5a:	5d                   	pop    %ebp
  800a5b:	c3                   	ret    

00800a5c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a5c:	55                   	push   %ebp
  800a5d:	89 e5                	mov    %esp,%ebp
  800a5f:	57                   	push   %edi
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
  800a62:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a65:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a68:	85 c9                	test   %ecx,%ecx
  800a6a:	74 2f                	je     800a9b <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a6c:	89 f8                	mov    %edi,%eax
  800a6e:	09 c8                	or     %ecx,%eax
  800a70:	a8 03                	test   $0x3,%al
  800a72:	75 21                	jne    800a95 <memset+0x39>
		c &= 0xFF;
  800a74:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a78:	89 d0                	mov    %edx,%eax
  800a7a:	c1 e0 08             	shl    $0x8,%eax
  800a7d:	89 d3                	mov    %edx,%ebx
  800a7f:	c1 e3 18             	shl    $0x18,%ebx
  800a82:	89 d6                	mov    %edx,%esi
  800a84:	c1 e6 10             	shl    $0x10,%esi
  800a87:	09 f3                	or     %esi,%ebx
  800a89:	09 da                	or     %ebx,%edx
  800a8b:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a8d:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a90:	fc                   	cld    
  800a91:	f3 ab                	rep stos %eax,%es:(%edi)
  800a93:	eb 06                	jmp    800a9b <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a95:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a98:	fc                   	cld    
  800a99:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a9b:	89 f8                	mov    %edi,%eax
  800a9d:	5b                   	pop    %ebx
  800a9e:	5e                   	pop    %esi
  800a9f:	5f                   	pop    %edi
  800aa0:	5d                   	pop    %ebp
  800aa1:	c3                   	ret    

00800aa2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	57                   	push   %edi
  800aa6:	56                   	push   %esi
  800aa7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaa:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab0:	39 c6                	cmp    %eax,%esi
  800ab2:	73 32                	jae    800ae6 <memmove+0x44>
  800ab4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ab7:	39 c2                	cmp    %eax,%edx
  800ab9:	76 2b                	jbe    800ae6 <memmove+0x44>
		s += n;
		d += n;
  800abb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800abe:	89 d6                	mov    %edx,%esi
  800ac0:	09 fe                	or     %edi,%esi
  800ac2:	09 ce                	or     %ecx,%esi
  800ac4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aca:	75 0e                	jne    800ada <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800acc:	83 ef 04             	sub    $0x4,%edi
  800acf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ad2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ad5:	fd                   	std    
  800ad6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad8:	eb 09                	jmp    800ae3 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ada:	83 ef 01             	sub    $0x1,%edi
  800add:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ae0:	fd                   	std    
  800ae1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ae3:	fc                   	cld    
  800ae4:	eb 1a                	jmp    800b00 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae6:	89 f2                	mov    %esi,%edx
  800ae8:	09 c2                	or     %eax,%edx
  800aea:	09 ca                	or     %ecx,%edx
  800aec:	f6 c2 03             	test   $0x3,%dl
  800aef:	75 0a                	jne    800afb <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800af1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800af4:	89 c7                	mov    %eax,%edi
  800af6:	fc                   	cld    
  800af7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800af9:	eb 05                	jmp    800b00 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800afb:	89 c7                	mov    %eax,%edi
  800afd:	fc                   	cld    
  800afe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b00:	5e                   	pop    %esi
  800b01:	5f                   	pop    %edi
  800b02:	5d                   	pop    %ebp
  800b03:	c3                   	ret    

00800b04 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b04:	55                   	push   %ebp
  800b05:	89 e5                	mov    %esp,%ebp
  800b07:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b0a:	ff 75 10             	push   0x10(%ebp)
  800b0d:	ff 75 0c             	push   0xc(%ebp)
  800b10:	ff 75 08             	push   0x8(%ebp)
  800b13:	e8 8a ff ff ff       	call   800aa2 <memmove>
}
  800b18:	c9                   	leave  
  800b19:	c3                   	ret    

00800b1a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	56                   	push   %esi
  800b1e:	53                   	push   %ebx
  800b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b22:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b25:	89 c6                	mov    %eax,%esi
  800b27:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2a:	eb 06                	jmp    800b32 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b2c:	83 c0 01             	add    $0x1,%eax
  800b2f:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800b32:	39 f0                	cmp    %esi,%eax
  800b34:	74 14                	je     800b4a <memcmp+0x30>
		if (*s1 != *s2)
  800b36:	0f b6 08             	movzbl (%eax),%ecx
  800b39:	0f b6 1a             	movzbl (%edx),%ebx
  800b3c:	38 d9                	cmp    %bl,%cl
  800b3e:	74 ec                	je     800b2c <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b40:	0f b6 c1             	movzbl %cl,%eax
  800b43:	0f b6 db             	movzbl %bl,%ebx
  800b46:	29 d8                	sub    %ebx,%eax
  800b48:	eb 05                	jmp    800b4f <memcmp+0x35>
	}

	return 0;
  800b4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b4f:	5b                   	pop    %ebx
  800b50:	5e                   	pop    %esi
  800b51:	5d                   	pop    %ebp
  800b52:	c3                   	ret    

00800b53 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	8b 45 08             	mov    0x8(%ebp),%eax
  800b59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b5c:	89 c2                	mov    %eax,%edx
  800b5e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b61:	eb 03                	jmp    800b66 <memfind+0x13>
  800b63:	83 c0 01             	add    $0x1,%eax
  800b66:	39 d0                	cmp    %edx,%eax
  800b68:	73 04                	jae    800b6e <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b6a:	38 08                	cmp    %cl,(%eax)
  800b6c:	75 f5                	jne    800b63 <memfind+0x10>
			break;
	return (void *) s;
}
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    

00800b70 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
  800b76:	8b 55 08             	mov    0x8(%ebp),%edx
  800b79:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b7c:	eb 03                	jmp    800b81 <strtol+0x11>
		s++;
  800b7e:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b81:	0f b6 02             	movzbl (%edx),%eax
  800b84:	3c 20                	cmp    $0x20,%al
  800b86:	74 f6                	je     800b7e <strtol+0xe>
  800b88:	3c 09                	cmp    $0x9,%al
  800b8a:	74 f2                	je     800b7e <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b8c:	3c 2b                	cmp    $0x2b,%al
  800b8e:	74 2a                	je     800bba <strtol+0x4a>
	int neg = 0;
  800b90:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b95:	3c 2d                	cmp    $0x2d,%al
  800b97:	74 2b                	je     800bc4 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b99:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b9f:	75 0f                	jne    800bb0 <strtol+0x40>
  800ba1:	80 3a 30             	cmpb   $0x30,(%edx)
  800ba4:	74 28                	je     800bce <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ba6:	85 db                	test   %ebx,%ebx
  800ba8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bad:	0f 44 d8             	cmove  %eax,%ebx
  800bb0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bb5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bb8:	eb 46                	jmp    800c00 <strtol+0x90>
		s++;
  800bba:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800bbd:	bf 00 00 00 00       	mov    $0x0,%edi
  800bc2:	eb d5                	jmp    800b99 <strtol+0x29>
		s++, neg = 1;
  800bc4:	83 c2 01             	add    $0x1,%edx
  800bc7:	bf 01 00 00 00       	mov    $0x1,%edi
  800bcc:	eb cb                	jmp    800b99 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bce:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bd2:	74 0e                	je     800be2 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800bd4:	85 db                	test   %ebx,%ebx
  800bd6:	75 d8                	jne    800bb0 <strtol+0x40>
		s++, base = 8;
  800bd8:	83 c2 01             	add    $0x1,%edx
  800bdb:	bb 08 00 00 00       	mov    $0x8,%ebx
  800be0:	eb ce                	jmp    800bb0 <strtol+0x40>
		s += 2, base = 16;
  800be2:	83 c2 02             	add    $0x2,%edx
  800be5:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bea:	eb c4                	jmp    800bb0 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bec:	0f be c0             	movsbl %al,%eax
  800bef:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bf2:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bf5:	7d 3a                	jge    800c31 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bf7:	83 c2 01             	add    $0x1,%edx
  800bfa:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bfe:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800c00:	0f b6 02             	movzbl (%edx),%eax
  800c03:	8d 70 d0             	lea    -0x30(%eax),%esi
  800c06:	89 f3                	mov    %esi,%ebx
  800c08:	80 fb 09             	cmp    $0x9,%bl
  800c0b:	76 df                	jbe    800bec <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800c0d:	8d 70 9f             	lea    -0x61(%eax),%esi
  800c10:	89 f3                	mov    %esi,%ebx
  800c12:	80 fb 19             	cmp    $0x19,%bl
  800c15:	77 08                	ja     800c1f <strtol+0xaf>
			dig = *s - 'a' + 10;
  800c17:	0f be c0             	movsbl %al,%eax
  800c1a:	83 e8 57             	sub    $0x57,%eax
  800c1d:	eb d3                	jmp    800bf2 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800c1f:	8d 70 bf             	lea    -0x41(%eax),%esi
  800c22:	89 f3                	mov    %esi,%ebx
  800c24:	80 fb 19             	cmp    $0x19,%bl
  800c27:	77 08                	ja     800c31 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c29:	0f be c0             	movsbl %al,%eax
  800c2c:	83 e8 37             	sub    $0x37,%eax
  800c2f:	eb c1                	jmp    800bf2 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c31:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c35:	74 05                	je     800c3c <strtol+0xcc>
		*endptr = (char *) s;
  800c37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c3a:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c3c:	89 c8                	mov    %ecx,%eax
  800c3e:	f7 d8                	neg    %eax
  800c40:	85 ff                	test   %edi,%edi
  800c42:	0f 45 c8             	cmovne %eax,%ecx
}
  800c45:	89 c8                	mov    %ecx,%eax
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c52:	b8 00 00 00 00       	mov    $0x0,%eax
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5d:	89 c3                	mov    %eax,%ebx
  800c5f:	89 c7                	mov    %eax,%edi
  800c61:	89 c6                	mov    %eax,%esi
  800c63:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <sys_cgetc>:

int
sys_cgetc(void)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c70:	ba 00 00 00 00       	mov    $0x0,%edx
  800c75:	b8 01 00 00 00       	mov    $0x1,%eax
  800c7a:	89 d1                	mov    %edx,%ecx
  800c7c:	89 d3                	mov    %edx,%ebx
  800c7e:	89 d7                	mov    %edx,%edi
  800c80:	89 d6                	mov    %edx,%esi
  800c82:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
  800c8f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c92:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800c9f:	89 cb                	mov    %ecx,%ebx
  800ca1:	89 cf                	mov    %ecx,%edi
  800ca3:	89 ce                	mov    %ecx,%esi
  800ca5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ca7:	85 c0                	test   %eax,%eax
  800ca9:	7f 08                	jg     800cb3 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800cab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cae:	5b                   	pop    %ebx
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb3:	83 ec 0c             	sub    $0xc,%esp
  800cb6:	50                   	push   %eax
  800cb7:	6a 03                	push   $0x3
  800cb9:	68 3f 2b 80 00       	push   $0x802b3f
  800cbe:	6a 2a                	push   $0x2a
  800cc0:	68 5c 2b 80 00       	push   $0x802b5c
  800cc5:	e8 8d f5 ff ff       	call   800257 <_panic>

00800cca <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800cca:	55                   	push   %ebp
  800ccb:	89 e5                	mov    %esp,%ebp
  800ccd:	57                   	push   %edi
  800cce:	56                   	push   %esi
  800ccf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cd0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cd5:	b8 02 00 00 00       	mov    $0x2,%eax
  800cda:	89 d1                	mov    %edx,%ecx
  800cdc:	89 d3                	mov    %edx,%ebx
  800cde:	89 d7                	mov    %edx,%edi
  800ce0:	89 d6                	mov    %edx,%esi
  800ce2:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800ce4:	5b                   	pop    %ebx
  800ce5:	5e                   	pop    %esi
  800ce6:	5f                   	pop    %edi
  800ce7:	5d                   	pop    %ebp
  800ce8:	c3                   	ret    

00800ce9 <sys_yield>:

void
sys_yield(void)
{
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	57                   	push   %edi
  800ced:	56                   	push   %esi
  800cee:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cef:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cf9:	89 d1                	mov    %edx,%ecx
  800cfb:	89 d3                	mov    %edx,%ebx
  800cfd:	89 d7                	mov    %edx,%edi
  800cff:	89 d6                	mov    %edx,%esi
  800d01:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d11:	be 00 00 00 00       	mov    $0x0,%esi
  800d16:	8b 55 08             	mov    0x8(%ebp),%edx
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	b8 04 00 00 00       	mov    $0x4,%eax
  800d21:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d24:	89 f7                	mov    %esi,%edi
  800d26:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d28:	85 c0                	test   %eax,%eax
  800d2a:	7f 08                	jg     800d34 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d2f:	5b                   	pop    %ebx
  800d30:	5e                   	pop    %esi
  800d31:	5f                   	pop    %edi
  800d32:	5d                   	pop    %ebp
  800d33:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d34:	83 ec 0c             	sub    $0xc,%esp
  800d37:	50                   	push   %eax
  800d38:	6a 04                	push   $0x4
  800d3a:	68 3f 2b 80 00       	push   $0x802b3f
  800d3f:	6a 2a                	push   $0x2a
  800d41:	68 5c 2b 80 00       	push   $0x802b5c
  800d46:	e8 0c f5 ff ff       	call   800257 <_panic>

00800d4b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
  800d51:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d54:	8b 55 08             	mov    0x8(%ebp),%edx
  800d57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d62:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d65:	8b 75 18             	mov    0x18(%ebp),%esi
  800d68:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d6a:	85 c0                	test   %eax,%eax
  800d6c:	7f 08                	jg     800d76 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d71:	5b                   	pop    %ebx
  800d72:	5e                   	pop    %esi
  800d73:	5f                   	pop    %edi
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d76:	83 ec 0c             	sub    $0xc,%esp
  800d79:	50                   	push   %eax
  800d7a:	6a 05                	push   $0x5
  800d7c:	68 3f 2b 80 00       	push   $0x802b3f
  800d81:	6a 2a                	push   $0x2a
  800d83:	68 5c 2b 80 00       	push   $0x802b5c
  800d88:	e8 ca f4 ff ff       	call   800257 <_panic>

00800d8d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	57                   	push   %edi
  800d91:	56                   	push   %esi
  800d92:	53                   	push   %ebx
  800d93:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d96:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800da1:	b8 06 00 00 00       	mov    $0x6,%eax
  800da6:	89 df                	mov    %ebx,%edi
  800da8:	89 de                	mov    %ebx,%esi
  800daa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dac:	85 c0                	test   %eax,%eax
  800dae:	7f 08                	jg     800db8 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800db0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db3:	5b                   	pop    %ebx
  800db4:	5e                   	pop    %esi
  800db5:	5f                   	pop    %edi
  800db6:	5d                   	pop    %ebp
  800db7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db8:	83 ec 0c             	sub    $0xc,%esp
  800dbb:	50                   	push   %eax
  800dbc:	6a 06                	push   $0x6
  800dbe:	68 3f 2b 80 00       	push   $0x802b3f
  800dc3:	6a 2a                	push   $0x2a
  800dc5:	68 5c 2b 80 00       	push   $0x802b5c
  800dca:	e8 88 f4 ff ff       	call   800257 <_panic>

00800dcf <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	57                   	push   %edi
  800dd3:	56                   	push   %esi
  800dd4:	53                   	push   %ebx
  800dd5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddd:	8b 55 08             	mov    0x8(%ebp),%edx
  800de0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de3:	b8 08 00 00 00       	mov    $0x8,%eax
  800de8:	89 df                	mov    %ebx,%edi
  800dea:	89 de                	mov    %ebx,%esi
  800dec:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dee:	85 c0                	test   %eax,%eax
  800df0:	7f 08                	jg     800dfa <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800df2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df5:	5b                   	pop    %ebx
  800df6:	5e                   	pop    %esi
  800df7:	5f                   	pop    %edi
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dfa:	83 ec 0c             	sub    $0xc,%esp
  800dfd:	50                   	push   %eax
  800dfe:	6a 08                	push   $0x8
  800e00:	68 3f 2b 80 00       	push   $0x802b3f
  800e05:	6a 2a                	push   $0x2a
  800e07:	68 5c 2b 80 00       	push   $0x802b5c
  800e0c:	e8 46 f4 ff ff       	call   800257 <_panic>

00800e11 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	57                   	push   %edi
  800e15:	56                   	push   %esi
  800e16:	53                   	push   %ebx
  800e17:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e25:	b8 09 00 00 00       	mov    $0x9,%eax
  800e2a:	89 df                	mov    %ebx,%edi
  800e2c:	89 de                	mov    %ebx,%esi
  800e2e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e30:	85 c0                	test   %eax,%eax
  800e32:	7f 08                	jg     800e3c <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e37:	5b                   	pop    %ebx
  800e38:	5e                   	pop    %esi
  800e39:	5f                   	pop    %edi
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3c:	83 ec 0c             	sub    $0xc,%esp
  800e3f:	50                   	push   %eax
  800e40:	6a 09                	push   $0x9
  800e42:	68 3f 2b 80 00       	push   $0x802b3f
  800e47:	6a 2a                	push   $0x2a
  800e49:	68 5c 2b 80 00       	push   $0x802b5c
  800e4e:	e8 04 f4 ff ff       	call   800257 <_panic>

00800e53 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e53:	55                   	push   %ebp
  800e54:	89 e5                	mov    %esp,%ebp
  800e56:	57                   	push   %edi
  800e57:	56                   	push   %esi
  800e58:	53                   	push   %ebx
  800e59:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e61:	8b 55 08             	mov    0x8(%ebp),%edx
  800e64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e67:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e6c:	89 df                	mov    %ebx,%edi
  800e6e:	89 de                	mov    %ebx,%esi
  800e70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e72:	85 c0                	test   %eax,%eax
  800e74:	7f 08                	jg     800e7e <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e79:	5b                   	pop    %ebx
  800e7a:	5e                   	pop    %esi
  800e7b:	5f                   	pop    %edi
  800e7c:	5d                   	pop    %ebp
  800e7d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7e:	83 ec 0c             	sub    $0xc,%esp
  800e81:	50                   	push   %eax
  800e82:	6a 0a                	push   $0xa
  800e84:	68 3f 2b 80 00       	push   $0x802b3f
  800e89:	6a 2a                	push   $0x2a
  800e8b:	68 5c 2b 80 00       	push   $0x802b5c
  800e90:	e8 c2 f3 ff ff       	call   800257 <_panic>

00800e95 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e95:	55                   	push   %ebp
  800e96:	89 e5                	mov    %esp,%ebp
  800e98:	57                   	push   %edi
  800e99:	56                   	push   %esi
  800e9a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ea6:	be 00 00 00 00       	mov    $0x0,%esi
  800eab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eae:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eb1:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800eb3:	5b                   	pop    %ebx
  800eb4:	5e                   	pop    %esi
  800eb5:	5f                   	pop    %edi
  800eb6:	5d                   	pop    %ebp
  800eb7:	c3                   	ret    

00800eb8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	57                   	push   %edi
  800ebc:	56                   	push   %esi
  800ebd:	53                   	push   %ebx
  800ebe:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ec1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ec6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec9:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ece:	89 cb                	mov    %ecx,%ebx
  800ed0:	89 cf                	mov    %ecx,%edi
  800ed2:	89 ce                	mov    %ecx,%esi
  800ed4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ed6:	85 c0                	test   %eax,%eax
  800ed8:	7f 08                	jg     800ee2 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800edd:	5b                   	pop    %ebx
  800ede:	5e                   	pop    %esi
  800edf:	5f                   	pop    %edi
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee2:	83 ec 0c             	sub    $0xc,%esp
  800ee5:	50                   	push   %eax
  800ee6:	6a 0d                	push   $0xd
  800ee8:	68 3f 2b 80 00       	push   $0x802b3f
  800eed:	6a 2a                	push   $0x2a
  800eef:	68 5c 2b 80 00       	push   $0x802b5c
  800ef4:	e8 5e f3 ff ff       	call   800257 <_panic>

00800ef9 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ef9:	55                   	push   %ebp
  800efa:	89 e5                	mov    %esp,%ebp
  800efc:	57                   	push   %edi
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
	asm volatile("int %1\n"
  800eff:	ba 00 00 00 00       	mov    $0x0,%edx
  800f04:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f09:	89 d1                	mov    %edx,%ecx
  800f0b:	89 d3                	mov    %edx,%ebx
  800f0d:	89 d7                	mov    %edx,%edi
  800f0f:	89 d6                	mov    %edx,%esi
  800f11:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f13:	5b                   	pop    %ebx
  800f14:	5e                   	pop    %esi
  800f15:	5f                   	pop    %edi
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    

00800f18 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	57                   	push   %edi
  800f1c:	56                   	push   %esi
  800f1d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f23:	8b 55 08             	mov    0x8(%ebp),%edx
  800f26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f29:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f2e:	89 df                	mov    %ebx,%edi
  800f30:	89 de                	mov    %ebx,%esi
  800f32:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800f34:	5b                   	pop    %ebx
  800f35:	5e                   	pop    %esi
  800f36:	5f                   	pop    %edi
  800f37:	5d                   	pop    %ebp
  800f38:	c3                   	ret    

00800f39 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	57                   	push   %edi
  800f3d:	56                   	push   %esi
  800f3e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f44:	8b 55 08             	mov    0x8(%ebp),%edx
  800f47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f4a:	b8 10 00 00 00       	mov    $0x10,%eax
  800f4f:	89 df                	mov    %ebx,%edi
  800f51:	89 de                	mov    %ebx,%esi
  800f53:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800f55:	5b                   	pop    %ebx
  800f56:	5e                   	pop    %esi
  800f57:	5f                   	pop    %edi
  800f58:	5d                   	pop    %ebp
  800f59:	c3                   	ret    

00800f5a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f5a:	55                   	push   %ebp
  800f5b:	89 e5                	mov    %esp,%ebp
  800f5d:	56                   	push   %esi
  800f5e:	53                   	push   %ebx
  800f5f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f62:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800f64:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f68:	0f 84 8e 00 00 00    	je     800ffc <pgfault+0xa2>
  800f6e:	89 f0                	mov    %esi,%eax
  800f70:	c1 e8 0c             	shr    $0xc,%eax
  800f73:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f7a:	f6 c4 08             	test   $0x8,%ah
  800f7d:	74 7d                	je     800ffc <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800f7f:	e8 46 fd ff ff       	call   800cca <sys_getenvid>
  800f84:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800f86:	83 ec 04             	sub    $0x4,%esp
  800f89:	6a 07                	push   $0x7
  800f8b:	68 00 f0 7f 00       	push   $0x7ff000
  800f90:	50                   	push   %eax
  800f91:	e8 72 fd ff ff       	call   800d08 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f96:	83 c4 10             	add    $0x10,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	78 73                	js     801010 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800f9d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800fa3:	83 ec 04             	sub    $0x4,%esp
  800fa6:	68 00 10 00 00       	push   $0x1000
  800fab:	56                   	push   %esi
  800fac:	68 00 f0 7f 00       	push   $0x7ff000
  800fb1:	e8 ec fa ff ff       	call   800aa2 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800fb6:	83 c4 08             	add    $0x8,%esp
  800fb9:	56                   	push   %esi
  800fba:	53                   	push   %ebx
  800fbb:	e8 cd fd ff ff       	call   800d8d <sys_page_unmap>
  800fc0:	83 c4 10             	add    $0x10,%esp
  800fc3:	85 c0                	test   %eax,%eax
  800fc5:	78 5b                	js     801022 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800fc7:	83 ec 0c             	sub    $0xc,%esp
  800fca:	6a 07                	push   $0x7
  800fcc:	56                   	push   %esi
  800fcd:	53                   	push   %ebx
  800fce:	68 00 f0 7f 00       	push   $0x7ff000
  800fd3:	53                   	push   %ebx
  800fd4:	e8 72 fd ff ff       	call   800d4b <sys_page_map>
  800fd9:	83 c4 20             	add    $0x20,%esp
  800fdc:	85 c0                	test   %eax,%eax
  800fde:	78 54                	js     801034 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800fe0:	83 ec 08             	sub    $0x8,%esp
  800fe3:	68 00 f0 7f 00       	push   $0x7ff000
  800fe8:	53                   	push   %ebx
  800fe9:	e8 9f fd ff ff       	call   800d8d <sys_page_unmap>
  800fee:	83 c4 10             	add    $0x10,%esp
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	78 51                	js     801046 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800ff5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ff8:	5b                   	pop    %ebx
  800ff9:	5e                   	pop    %esi
  800ffa:	5d                   	pop    %ebp
  800ffb:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800ffc:	83 ec 04             	sub    $0x4,%esp
  800fff:	68 6c 2b 80 00       	push   $0x802b6c
  801004:	6a 1d                	push   $0x1d
  801006:	68 e8 2b 80 00       	push   $0x802be8
  80100b:	e8 47 f2 ff ff       	call   800257 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  801010:	50                   	push   %eax
  801011:	68 a4 2b 80 00       	push   $0x802ba4
  801016:	6a 29                	push   $0x29
  801018:	68 e8 2b 80 00       	push   $0x802be8
  80101d:	e8 35 f2 ff ff       	call   800257 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  801022:	50                   	push   %eax
  801023:	68 c8 2b 80 00       	push   $0x802bc8
  801028:	6a 2e                	push   $0x2e
  80102a:	68 e8 2b 80 00       	push   $0x802be8
  80102f:	e8 23 f2 ff ff       	call   800257 <_panic>
		panic("pgfault: page map failed (%e)", r);
  801034:	50                   	push   %eax
  801035:	68 f3 2b 80 00       	push   $0x802bf3
  80103a:	6a 30                	push   $0x30
  80103c:	68 e8 2b 80 00       	push   $0x802be8
  801041:	e8 11 f2 ff ff       	call   800257 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  801046:	50                   	push   %eax
  801047:	68 c8 2b 80 00       	push   $0x802bc8
  80104c:	6a 32                	push   $0x32
  80104e:	68 e8 2b 80 00       	push   $0x802be8
  801053:	e8 ff f1 ff ff       	call   800257 <_panic>

00801058 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	57                   	push   %edi
  80105c:	56                   	push   %esi
  80105d:	53                   	push   %ebx
  80105e:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  801061:	68 5a 0f 80 00       	push   $0x800f5a
  801066:	e8 bd 13 00 00       	call   802428 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80106b:	b8 07 00 00 00       	mov    $0x7,%eax
  801070:	cd 30                	int    $0x30
  801072:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  801075:	83 c4 10             	add    $0x10,%esp
  801078:	85 c0                	test   %eax,%eax
  80107a:	78 30                	js     8010ac <fork+0x54>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  80107c:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  801081:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801085:	75 76                	jne    8010fd <fork+0xa5>
		thisenv = &envs[ENVX(sys_getenvid())];
  801087:	e8 3e fc ff ff       	call   800cca <sys_getenvid>
  80108c:	25 ff 03 00 00       	and    $0x3ff,%eax
  801091:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  801097:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80109c:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  8010a1:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  8010a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010a7:	5b                   	pop    %ebx
  8010a8:	5e                   	pop    %esi
  8010a9:	5f                   	pop    %edi
  8010aa:	5d                   	pop    %ebp
  8010ab:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  8010ac:	50                   	push   %eax
  8010ad:	68 11 2c 80 00       	push   $0x802c11
  8010b2:	6a 78                	push   $0x78
  8010b4:	68 e8 2b 80 00       	push   $0x802be8
  8010b9:	e8 99 f1 ff ff       	call   800257 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  8010be:	83 ec 0c             	sub    $0xc,%esp
  8010c1:	ff 75 e4             	push   -0x1c(%ebp)
  8010c4:	57                   	push   %edi
  8010c5:	ff 75 dc             	push   -0x24(%ebp)
  8010c8:	57                   	push   %edi
  8010c9:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8010cc:	56                   	push   %esi
  8010cd:	e8 79 fc ff ff       	call   800d4b <sys_page_map>
	if(r<0) return r;
  8010d2:	83 c4 20             	add    $0x20,%esp
  8010d5:	85 c0                	test   %eax,%eax
  8010d7:	78 cb                	js     8010a4 <fork+0x4c>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  8010d9:	83 ec 0c             	sub    $0xc,%esp
  8010dc:	ff 75 e4             	push   -0x1c(%ebp)
  8010df:	57                   	push   %edi
  8010e0:	56                   	push   %esi
  8010e1:	57                   	push   %edi
  8010e2:	56                   	push   %esi
  8010e3:	e8 63 fc ff ff       	call   800d4b <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  8010e8:	83 c4 20             	add    $0x20,%esp
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	78 76                	js     801165 <fork+0x10d>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  8010ef:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010f5:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010fb:	74 75                	je     801172 <fork+0x11a>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  8010fd:	89 d8                	mov    %ebx,%eax
  8010ff:	c1 e8 16             	shr    $0x16,%eax
  801102:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801109:	a8 01                	test   $0x1,%al
  80110b:	74 e2                	je     8010ef <fork+0x97>
  80110d:	89 de                	mov    %ebx,%esi
  80110f:	c1 ee 0c             	shr    $0xc,%esi
  801112:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801119:	a8 01                	test   $0x1,%al
  80111b:	74 d2                	je     8010ef <fork+0x97>
	envid_t this_envid = sys_getenvid();//父进程号
  80111d:	e8 a8 fb ff ff       	call   800cca <sys_getenvid>
  801122:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  801125:	89 f7                	mov    %esi,%edi
  801127:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  80112a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801131:	89 c1                	mov    %eax,%ecx
  801133:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801139:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  80113c:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  801143:	f6 c6 04             	test   $0x4,%dh
  801146:	0f 85 72 ff ff ff    	jne    8010be <fork+0x66>
		perm &= ~PTE_W;
  80114c:	25 05 0e 00 00       	and    $0xe05,%eax
  801151:	80 cc 08             	or     $0x8,%ah
  801154:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  80115a:	0f 44 c1             	cmove  %ecx,%eax
  80115d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801160:	e9 59 ff ff ff       	jmp    8010be <fork+0x66>
  801165:	ba 00 00 00 00       	mov    $0x0,%edx
  80116a:	0f 4f c2             	cmovg  %edx,%eax
  80116d:	e9 32 ff ff ff       	jmp    8010a4 <fork+0x4c>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801172:	83 ec 04             	sub    $0x4,%esp
  801175:	6a 07                	push   $0x7
  801177:	68 00 f0 bf ee       	push   $0xeebff000
  80117c:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80117f:	57                   	push   %edi
  801180:	e8 83 fb ff ff       	call   800d08 <sys_page_alloc>
	if(r<0) return r;
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	85 c0                	test   %eax,%eax
  80118a:	0f 88 14 ff ff ff    	js     8010a4 <fork+0x4c>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801190:	83 ec 08             	sub    $0x8,%esp
  801193:	68 9e 24 80 00       	push   $0x80249e
  801198:	57                   	push   %edi
  801199:	e8 b5 fc ff ff       	call   800e53 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  80119e:	83 c4 10             	add    $0x10,%esp
  8011a1:	85 c0                	test   %eax,%eax
  8011a3:	0f 88 fb fe ff ff    	js     8010a4 <fork+0x4c>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8011a9:	83 ec 08             	sub    $0x8,%esp
  8011ac:	6a 02                	push   $0x2
  8011ae:	57                   	push   %edi
  8011af:	e8 1b fc ff ff       	call   800dcf <sys_env_set_status>
	if(r<0) return r;
  8011b4:	83 c4 10             	add    $0x10,%esp
	return envid;
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	0f 49 c7             	cmovns %edi,%eax
  8011bc:	e9 e3 fe ff ff       	jmp    8010a4 <fork+0x4c>

008011c1 <sfork>:

// Challenge!
int
sfork(void)
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011c7:	68 21 2c 80 00       	push   $0x802c21
  8011cc:	68 a1 00 00 00       	push   $0xa1
  8011d1:	68 e8 2b 80 00       	push   $0x802be8
  8011d6:	e8 7c f0 ff ff       	call   800257 <_panic>

008011db <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	56                   	push   %esi
  8011df:	53                   	push   %ebx
  8011e0:	8b 75 08             	mov    0x8(%ebp),%esi
  8011e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011e6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8011e9:	85 c0                	test   %eax,%eax
  8011eb:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8011f0:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8011f3:	83 ec 0c             	sub    $0xc,%esp
  8011f6:	50                   	push   %eax
  8011f7:	e8 bc fc ff ff       	call   800eb8 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8011fc:	83 c4 10             	add    $0x10,%esp
  8011ff:	85 f6                	test   %esi,%esi
  801201:	74 17                	je     80121a <ipc_recv+0x3f>
  801203:	ba 00 00 00 00       	mov    $0x0,%edx
  801208:	85 c0                	test   %eax,%eax
  80120a:	78 0c                	js     801218 <ipc_recv+0x3d>
  80120c:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801212:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801218:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  80121a:	85 db                	test   %ebx,%ebx
  80121c:	74 17                	je     801235 <ipc_recv+0x5a>
  80121e:	ba 00 00 00 00       	mov    $0x0,%edx
  801223:	85 c0                	test   %eax,%eax
  801225:	78 0c                	js     801233 <ipc_recv+0x58>
  801227:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80122d:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801233:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801235:	85 c0                	test   %eax,%eax
  801237:	78 0b                	js     801244 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801239:	a1 00 40 80 00       	mov    0x804000,%eax
  80123e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  801244:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801247:	5b                   	pop    %ebx
  801248:	5e                   	pop    %esi
  801249:	5d                   	pop    %ebp
  80124a:	c3                   	ret    

0080124b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	57                   	push   %edi
  80124f:	56                   	push   %esi
  801250:	53                   	push   %ebx
  801251:	83 ec 0c             	sub    $0xc,%esp
  801254:	8b 7d 08             	mov    0x8(%ebp),%edi
  801257:	8b 75 0c             	mov    0xc(%ebp),%esi
  80125a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  80125d:	85 db                	test   %ebx,%ebx
  80125f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801264:	0f 44 d8             	cmove  %eax,%ebx
  801267:	eb 05                	jmp    80126e <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801269:	e8 7b fa ff ff       	call   800ce9 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80126e:	ff 75 14             	push   0x14(%ebp)
  801271:	53                   	push   %ebx
  801272:	56                   	push   %esi
  801273:	57                   	push   %edi
  801274:	e8 1c fc ff ff       	call   800e95 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801279:	83 c4 10             	add    $0x10,%esp
  80127c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80127f:	74 e8                	je     801269 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801281:	85 c0                	test   %eax,%eax
  801283:	78 08                	js     80128d <ipc_send+0x42>
	}while (r<0);

}
  801285:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801288:	5b                   	pop    %ebx
  801289:	5e                   	pop    %esi
  80128a:	5f                   	pop    %edi
  80128b:	5d                   	pop    %ebp
  80128c:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80128d:	50                   	push   %eax
  80128e:	68 37 2c 80 00       	push   $0x802c37
  801293:	6a 3d                	push   $0x3d
  801295:	68 4b 2c 80 00       	push   $0x802c4b
  80129a:	e8 b8 ef ff ff       	call   800257 <_panic>

0080129f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8012a5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8012aa:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  8012b0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8012b6:	8b 52 60             	mov    0x60(%edx),%edx
  8012b9:	39 ca                	cmp    %ecx,%edx
  8012bb:	74 11                	je     8012ce <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  8012bd:	83 c0 01             	add    $0x1,%eax
  8012c0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8012c5:	75 e3                	jne    8012aa <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8012c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cc:	eb 0e                	jmp    8012dc <ipc_find_env+0x3d>
			return envs[i].env_id;
  8012ce:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8012d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012d9:	8b 40 58             	mov    0x58(%eax),%eax
}
  8012dc:	5d                   	pop    %ebp
  8012dd:	c3                   	ret    

008012de <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012e4:	05 00 00 00 30       	add    $0x30000000,%eax
  8012e9:	c1 e8 0c             	shr    $0xc,%eax
}
  8012ec:	5d                   	pop    %ebp
  8012ed:	c3                   	ret    

008012ee <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012ee:	55                   	push   %ebp
  8012ef:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f4:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8012f9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012fe:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    

00801305 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80130d:	89 c2                	mov    %eax,%edx
  80130f:	c1 ea 16             	shr    $0x16,%edx
  801312:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801319:	f6 c2 01             	test   $0x1,%dl
  80131c:	74 29                	je     801347 <fd_alloc+0x42>
  80131e:	89 c2                	mov    %eax,%edx
  801320:	c1 ea 0c             	shr    $0xc,%edx
  801323:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80132a:	f6 c2 01             	test   $0x1,%dl
  80132d:	74 18                	je     801347 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  80132f:	05 00 10 00 00       	add    $0x1000,%eax
  801334:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801339:	75 d2                	jne    80130d <fd_alloc+0x8>
  80133b:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801340:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801345:	eb 05                	jmp    80134c <fd_alloc+0x47>
			return 0;
  801347:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80134c:	8b 55 08             	mov    0x8(%ebp),%edx
  80134f:	89 02                	mov    %eax,(%edx)
}
  801351:	89 c8                	mov    %ecx,%eax
  801353:	5d                   	pop    %ebp
  801354:	c3                   	ret    

00801355 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801355:	55                   	push   %ebp
  801356:	89 e5                	mov    %esp,%ebp
  801358:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80135b:	83 f8 1f             	cmp    $0x1f,%eax
  80135e:	77 30                	ja     801390 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801360:	c1 e0 0c             	shl    $0xc,%eax
  801363:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801368:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80136e:	f6 c2 01             	test   $0x1,%dl
  801371:	74 24                	je     801397 <fd_lookup+0x42>
  801373:	89 c2                	mov    %eax,%edx
  801375:	c1 ea 0c             	shr    $0xc,%edx
  801378:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80137f:	f6 c2 01             	test   $0x1,%dl
  801382:	74 1a                	je     80139e <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801384:	8b 55 0c             	mov    0xc(%ebp),%edx
  801387:	89 02                	mov    %eax,(%edx)
	return 0;
  801389:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80138e:	5d                   	pop    %ebp
  80138f:	c3                   	ret    
		return -E_INVAL;
  801390:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801395:	eb f7                	jmp    80138e <fd_lookup+0x39>
		return -E_INVAL;
  801397:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80139c:	eb f0                	jmp    80138e <fd_lookup+0x39>
  80139e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a3:	eb e9                	jmp    80138e <fd_lookup+0x39>

008013a5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	53                   	push   %ebx
  8013a9:	83 ec 04             	sub    $0x4,%esp
  8013ac:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8013af:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b4:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8013b9:	39 13                	cmp    %edx,(%ebx)
  8013bb:	74 37                	je     8013f4 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8013bd:	83 c0 01             	add    $0x1,%eax
  8013c0:	8b 1c 85 d4 2c 80 00 	mov    0x802cd4(,%eax,4),%ebx
  8013c7:	85 db                	test   %ebx,%ebx
  8013c9:	75 ee                	jne    8013b9 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013cb:	a1 00 40 80 00       	mov    0x804000,%eax
  8013d0:	8b 40 58             	mov    0x58(%eax),%eax
  8013d3:	83 ec 04             	sub    $0x4,%esp
  8013d6:	52                   	push   %edx
  8013d7:	50                   	push   %eax
  8013d8:	68 58 2c 80 00       	push   $0x802c58
  8013dd:	e8 50 ef ff ff       	call   800332 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8013e2:	83 c4 10             	add    $0x10,%esp
  8013e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8013ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013ed:	89 1a                	mov    %ebx,(%edx)
}
  8013ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f2:	c9                   	leave  
  8013f3:	c3                   	ret    
			return 0;
  8013f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f9:	eb ef                	jmp    8013ea <dev_lookup+0x45>

008013fb <fd_close>:
{
  8013fb:	55                   	push   %ebp
  8013fc:	89 e5                	mov    %esp,%ebp
  8013fe:	57                   	push   %edi
  8013ff:	56                   	push   %esi
  801400:	53                   	push   %ebx
  801401:	83 ec 24             	sub    $0x24,%esp
  801404:	8b 75 08             	mov    0x8(%ebp),%esi
  801407:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80140a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80140d:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80140e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801414:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801417:	50                   	push   %eax
  801418:	e8 38 ff ff ff       	call   801355 <fd_lookup>
  80141d:	89 c3                	mov    %eax,%ebx
  80141f:	83 c4 10             	add    $0x10,%esp
  801422:	85 c0                	test   %eax,%eax
  801424:	78 05                	js     80142b <fd_close+0x30>
	    || fd != fd2)
  801426:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801429:	74 16                	je     801441 <fd_close+0x46>
		return (must_exist ? r : 0);
  80142b:	89 f8                	mov    %edi,%eax
  80142d:	84 c0                	test   %al,%al
  80142f:	b8 00 00 00 00       	mov    $0x0,%eax
  801434:	0f 44 d8             	cmove  %eax,%ebx
}
  801437:	89 d8                	mov    %ebx,%eax
  801439:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80143c:	5b                   	pop    %ebx
  80143d:	5e                   	pop    %esi
  80143e:	5f                   	pop    %edi
  80143f:	5d                   	pop    %ebp
  801440:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801441:	83 ec 08             	sub    $0x8,%esp
  801444:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801447:	50                   	push   %eax
  801448:	ff 36                	push   (%esi)
  80144a:	e8 56 ff ff ff       	call   8013a5 <dev_lookup>
  80144f:	89 c3                	mov    %eax,%ebx
  801451:	83 c4 10             	add    $0x10,%esp
  801454:	85 c0                	test   %eax,%eax
  801456:	78 1a                	js     801472 <fd_close+0x77>
		if (dev->dev_close)
  801458:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80145b:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80145e:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801463:	85 c0                	test   %eax,%eax
  801465:	74 0b                	je     801472 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801467:	83 ec 0c             	sub    $0xc,%esp
  80146a:	56                   	push   %esi
  80146b:	ff d0                	call   *%eax
  80146d:	89 c3                	mov    %eax,%ebx
  80146f:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801472:	83 ec 08             	sub    $0x8,%esp
  801475:	56                   	push   %esi
  801476:	6a 00                	push   $0x0
  801478:	e8 10 f9 ff ff       	call   800d8d <sys_page_unmap>
	return r;
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	eb b5                	jmp    801437 <fd_close+0x3c>

00801482 <close>:

int
close(int fdnum)
{
  801482:	55                   	push   %ebp
  801483:	89 e5                	mov    %esp,%ebp
  801485:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80148b:	50                   	push   %eax
  80148c:	ff 75 08             	push   0x8(%ebp)
  80148f:	e8 c1 fe ff ff       	call   801355 <fd_lookup>
  801494:	83 c4 10             	add    $0x10,%esp
  801497:	85 c0                	test   %eax,%eax
  801499:	79 02                	jns    80149d <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80149b:	c9                   	leave  
  80149c:	c3                   	ret    
		return fd_close(fd, 1);
  80149d:	83 ec 08             	sub    $0x8,%esp
  8014a0:	6a 01                	push   $0x1
  8014a2:	ff 75 f4             	push   -0xc(%ebp)
  8014a5:	e8 51 ff ff ff       	call   8013fb <fd_close>
  8014aa:	83 c4 10             	add    $0x10,%esp
  8014ad:	eb ec                	jmp    80149b <close+0x19>

008014af <close_all>:

void
close_all(void)
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	53                   	push   %ebx
  8014b3:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014b6:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014bb:	83 ec 0c             	sub    $0xc,%esp
  8014be:	53                   	push   %ebx
  8014bf:	e8 be ff ff ff       	call   801482 <close>
	for (i = 0; i < MAXFD; i++)
  8014c4:	83 c3 01             	add    $0x1,%ebx
  8014c7:	83 c4 10             	add    $0x10,%esp
  8014ca:	83 fb 20             	cmp    $0x20,%ebx
  8014cd:	75 ec                	jne    8014bb <close_all+0xc>
}
  8014cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014d2:	c9                   	leave  
  8014d3:	c3                   	ret    

008014d4 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014d4:	55                   	push   %ebp
  8014d5:	89 e5                	mov    %esp,%ebp
  8014d7:	57                   	push   %edi
  8014d8:	56                   	push   %esi
  8014d9:	53                   	push   %ebx
  8014da:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014dd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014e0:	50                   	push   %eax
  8014e1:	ff 75 08             	push   0x8(%ebp)
  8014e4:	e8 6c fe ff ff       	call   801355 <fd_lookup>
  8014e9:	89 c3                	mov    %eax,%ebx
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	78 7f                	js     801571 <dup+0x9d>
		return r;
	close(newfdnum);
  8014f2:	83 ec 0c             	sub    $0xc,%esp
  8014f5:	ff 75 0c             	push   0xc(%ebp)
  8014f8:	e8 85 ff ff ff       	call   801482 <close>

	newfd = INDEX2FD(newfdnum);
  8014fd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801500:	c1 e6 0c             	shl    $0xc,%esi
  801503:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801509:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80150c:	89 3c 24             	mov    %edi,(%esp)
  80150f:	e8 da fd ff ff       	call   8012ee <fd2data>
  801514:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801516:	89 34 24             	mov    %esi,(%esp)
  801519:	e8 d0 fd ff ff       	call   8012ee <fd2data>
  80151e:	83 c4 10             	add    $0x10,%esp
  801521:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801524:	89 d8                	mov    %ebx,%eax
  801526:	c1 e8 16             	shr    $0x16,%eax
  801529:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801530:	a8 01                	test   $0x1,%al
  801532:	74 11                	je     801545 <dup+0x71>
  801534:	89 d8                	mov    %ebx,%eax
  801536:	c1 e8 0c             	shr    $0xc,%eax
  801539:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801540:	f6 c2 01             	test   $0x1,%dl
  801543:	75 36                	jne    80157b <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801545:	89 f8                	mov    %edi,%eax
  801547:	c1 e8 0c             	shr    $0xc,%eax
  80154a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801551:	83 ec 0c             	sub    $0xc,%esp
  801554:	25 07 0e 00 00       	and    $0xe07,%eax
  801559:	50                   	push   %eax
  80155a:	56                   	push   %esi
  80155b:	6a 00                	push   $0x0
  80155d:	57                   	push   %edi
  80155e:	6a 00                	push   $0x0
  801560:	e8 e6 f7 ff ff       	call   800d4b <sys_page_map>
  801565:	89 c3                	mov    %eax,%ebx
  801567:	83 c4 20             	add    $0x20,%esp
  80156a:	85 c0                	test   %eax,%eax
  80156c:	78 33                	js     8015a1 <dup+0xcd>
		goto err;

	return newfdnum;
  80156e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801571:	89 d8                	mov    %ebx,%eax
  801573:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801576:	5b                   	pop    %ebx
  801577:	5e                   	pop    %esi
  801578:	5f                   	pop    %edi
  801579:	5d                   	pop    %ebp
  80157a:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80157b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801582:	83 ec 0c             	sub    $0xc,%esp
  801585:	25 07 0e 00 00       	and    $0xe07,%eax
  80158a:	50                   	push   %eax
  80158b:	ff 75 d4             	push   -0x2c(%ebp)
  80158e:	6a 00                	push   $0x0
  801590:	53                   	push   %ebx
  801591:	6a 00                	push   $0x0
  801593:	e8 b3 f7 ff ff       	call   800d4b <sys_page_map>
  801598:	89 c3                	mov    %eax,%ebx
  80159a:	83 c4 20             	add    $0x20,%esp
  80159d:	85 c0                	test   %eax,%eax
  80159f:	79 a4                	jns    801545 <dup+0x71>
	sys_page_unmap(0, newfd);
  8015a1:	83 ec 08             	sub    $0x8,%esp
  8015a4:	56                   	push   %esi
  8015a5:	6a 00                	push   $0x0
  8015a7:	e8 e1 f7 ff ff       	call   800d8d <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015ac:	83 c4 08             	add    $0x8,%esp
  8015af:	ff 75 d4             	push   -0x2c(%ebp)
  8015b2:	6a 00                	push   $0x0
  8015b4:	e8 d4 f7 ff ff       	call   800d8d <sys_page_unmap>
	return r;
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	eb b3                	jmp    801571 <dup+0x9d>

008015be <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015be:	55                   	push   %ebp
  8015bf:	89 e5                	mov    %esp,%ebp
  8015c1:	56                   	push   %esi
  8015c2:	53                   	push   %ebx
  8015c3:	83 ec 18             	sub    $0x18,%esp
  8015c6:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015cc:	50                   	push   %eax
  8015cd:	56                   	push   %esi
  8015ce:	e8 82 fd ff ff       	call   801355 <fd_lookup>
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	85 c0                	test   %eax,%eax
  8015d8:	78 3c                	js     801616 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015da:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8015dd:	83 ec 08             	sub    $0x8,%esp
  8015e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e3:	50                   	push   %eax
  8015e4:	ff 33                	push   (%ebx)
  8015e6:	e8 ba fd ff ff       	call   8013a5 <dev_lookup>
  8015eb:	83 c4 10             	add    $0x10,%esp
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	78 24                	js     801616 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015f2:	8b 43 08             	mov    0x8(%ebx),%eax
  8015f5:	83 e0 03             	and    $0x3,%eax
  8015f8:	83 f8 01             	cmp    $0x1,%eax
  8015fb:	74 20                	je     80161d <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8015fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801600:	8b 40 08             	mov    0x8(%eax),%eax
  801603:	85 c0                	test   %eax,%eax
  801605:	74 37                	je     80163e <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801607:	83 ec 04             	sub    $0x4,%esp
  80160a:	ff 75 10             	push   0x10(%ebp)
  80160d:	ff 75 0c             	push   0xc(%ebp)
  801610:	53                   	push   %ebx
  801611:	ff d0                	call   *%eax
  801613:	83 c4 10             	add    $0x10,%esp
}
  801616:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801619:	5b                   	pop    %ebx
  80161a:	5e                   	pop    %esi
  80161b:	5d                   	pop    %ebp
  80161c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80161d:	a1 00 40 80 00       	mov    0x804000,%eax
  801622:	8b 40 58             	mov    0x58(%eax),%eax
  801625:	83 ec 04             	sub    $0x4,%esp
  801628:	56                   	push   %esi
  801629:	50                   	push   %eax
  80162a:	68 99 2c 80 00       	push   $0x802c99
  80162f:	e8 fe ec ff ff       	call   800332 <cprintf>
		return -E_INVAL;
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80163c:	eb d8                	jmp    801616 <read+0x58>
		return -E_NOT_SUPP;
  80163e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801643:	eb d1                	jmp    801616 <read+0x58>

00801645 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	57                   	push   %edi
  801649:	56                   	push   %esi
  80164a:	53                   	push   %ebx
  80164b:	83 ec 0c             	sub    $0xc,%esp
  80164e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801651:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801654:	bb 00 00 00 00       	mov    $0x0,%ebx
  801659:	eb 02                	jmp    80165d <readn+0x18>
  80165b:	01 c3                	add    %eax,%ebx
  80165d:	39 f3                	cmp    %esi,%ebx
  80165f:	73 21                	jae    801682 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801661:	83 ec 04             	sub    $0x4,%esp
  801664:	89 f0                	mov    %esi,%eax
  801666:	29 d8                	sub    %ebx,%eax
  801668:	50                   	push   %eax
  801669:	89 d8                	mov    %ebx,%eax
  80166b:	03 45 0c             	add    0xc(%ebp),%eax
  80166e:	50                   	push   %eax
  80166f:	57                   	push   %edi
  801670:	e8 49 ff ff ff       	call   8015be <read>
		if (m < 0)
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	85 c0                	test   %eax,%eax
  80167a:	78 04                	js     801680 <readn+0x3b>
			return m;
		if (m == 0)
  80167c:	75 dd                	jne    80165b <readn+0x16>
  80167e:	eb 02                	jmp    801682 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801680:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801682:	89 d8                	mov    %ebx,%eax
  801684:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801687:	5b                   	pop    %ebx
  801688:	5e                   	pop    %esi
  801689:	5f                   	pop    %edi
  80168a:	5d                   	pop    %ebp
  80168b:	c3                   	ret    

0080168c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
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
  80169c:	e8 b4 fc ff ff       	call   801355 <fd_lookup>
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 37                	js     8016df <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a8:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8016ab:	83 ec 08             	sub    $0x8,%esp
  8016ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b1:	50                   	push   %eax
  8016b2:	ff 36                	push   (%esi)
  8016b4:	e8 ec fc ff ff       	call   8013a5 <dev_lookup>
  8016b9:	83 c4 10             	add    $0x10,%esp
  8016bc:	85 c0                	test   %eax,%eax
  8016be:	78 1f                	js     8016df <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c0:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8016c4:	74 20                	je     8016e6 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c9:	8b 40 0c             	mov    0xc(%eax),%eax
  8016cc:	85 c0                	test   %eax,%eax
  8016ce:	74 37                	je     801707 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016d0:	83 ec 04             	sub    $0x4,%esp
  8016d3:	ff 75 10             	push   0x10(%ebp)
  8016d6:	ff 75 0c             	push   0xc(%ebp)
  8016d9:	56                   	push   %esi
  8016da:	ff d0                	call   *%eax
  8016dc:	83 c4 10             	add    $0x10,%esp
}
  8016df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e2:	5b                   	pop    %ebx
  8016e3:	5e                   	pop    %esi
  8016e4:	5d                   	pop    %ebp
  8016e5:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016e6:	a1 00 40 80 00       	mov    0x804000,%eax
  8016eb:	8b 40 58             	mov    0x58(%eax),%eax
  8016ee:	83 ec 04             	sub    $0x4,%esp
  8016f1:	53                   	push   %ebx
  8016f2:	50                   	push   %eax
  8016f3:	68 b5 2c 80 00       	push   $0x802cb5
  8016f8:	e8 35 ec ff ff       	call   800332 <cprintf>
		return -E_INVAL;
  8016fd:	83 c4 10             	add    $0x10,%esp
  801700:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801705:	eb d8                	jmp    8016df <write+0x53>
		return -E_NOT_SUPP;
  801707:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80170c:	eb d1                	jmp    8016df <write+0x53>

0080170e <seek>:

int
seek(int fdnum, off_t offset)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801714:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801717:	50                   	push   %eax
  801718:	ff 75 08             	push   0x8(%ebp)
  80171b:	e8 35 fc ff ff       	call   801355 <fd_lookup>
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	85 c0                	test   %eax,%eax
  801725:	78 0e                	js     801735 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801727:	8b 55 0c             	mov    0xc(%ebp),%edx
  80172a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80172d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801730:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801735:	c9                   	leave  
  801736:	c3                   	ret    

00801737 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801737:	55                   	push   %ebp
  801738:	89 e5                	mov    %esp,%ebp
  80173a:	56                   	push   %esi
  80173b:	53                   	push   %ebx
  80173c:	83 ec 18             	sub    $0x18,%esp
  80173f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801742:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801745:	50                   	push   %eax
  801746:	53                   	push   %ebx
  801747:	e8 09 fc ff ff       	call   801355 <fd_lookup>
  80174c:	83 c4 10             	add    $0x10,%esp
  80174f:	85 c0                	test   %eax,%eax
  801751:	78 34                	js     801787 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801753:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801756:	83 ec 08             	sub    $0x8,%esp
  801759:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175c:	50                   	push   %eax
  80175d:	ff 36                	push   (%esi)
  80175f:	e8 41 fc ff ff       	call   8013a5 <dev_lookup>
  801764:	83 c4 10             	add    $0x10,%esp
  801767:	85 c0                	test   %eax,%eax
  801769:	78 1c                	js     801787 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80176b:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80176f:	74 1d                	je     80178e <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801771:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801774:	8b 40 18             	mov    0x18(%eax),%eax
  801777:	85 c0                	test   %eax,%eax
  801779:	74 34                	je     8017af <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80177b:	83 ec 08             	sub    $0x8,%esp
  80177e:	ff 75 0c             	push   0xc(%ebp)
  801781:	56                   	push   %esi
  801782:	ff d0                	call   *%eax
  801784:	83 c4 10             	add    $0x10,%esp
}
  801787:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178a:	5b                   	pop    %ebx
  80178b:	5e                   	pop    %esi
  80178c:	5d                   	pop    %ebp
  80178d:	c3                   	ret    
			thisenv->env_id, fdnum);
  80178e:	a1 00 40 80 00       	mov    0x804000,%eax
  801793:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801796:	83 ec 04             	sub    $0x4,%esp
  801799:	53                   	push   %ebx
  80179a:	50                   	push   %eax
  80179b:	68 78 2c 80 00       	push   $0x802c78
  8017a0:	e8 8d eb ff ff       	call   800332 <cprintf>
		return -E_INVAL;
  8017a5:	83 c4 10             	add    $0x10,%esp
  8017a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017ad:	eb d8                	jmp    801787 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8017af:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017b4:	eb d1                	jmp    801787 <ftruncate+0x50>

008017b6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	56                   	push   %esi
  8017ba:	53                   	push   %ebx
  8017bb:	83 ec 18             	sub    $0x18,%esp
  8017be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017c4:	50                   	push   %eax
  8017c5:	ff 75 08             	push   0x8(%ebp)
  8017c8:	e8 88 fb ff ff       	call   801355 <fd_lookup>
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	78 49                	js     80181d <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017d4:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8017d7:	83 ec 08             	sub    $0x8,%esp
  8017da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017dd:	50                   	push   %eax
  8017de:	ff 36                	push   (%esi)
  8017e0:	e8 c0 fb ff ff       	call   8013a5 <dev_lookup>
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	78 31                	js     80181d <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8017ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ef:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017f3:	74 2f                	je     801824 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017f5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017f8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017ff:	00 00 00 
	stat->st_isdir = 0;
  801802:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801809:	00 00 00 
	stat->st_dev = dev;
  80180c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801812:	83 ec 08             	sub    $0x8,%esp
  801815:	53                   	push   %ebx
  801816:	56                   	push   %esi
  801817:	ff 50 14             	call   *0x14(%eax)
  80181a:	83 c4 10             	add    $0x10,%esp
}
  80181d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801820:	5b                   	pop    %ebx
  801821:	5e                   	pop    %esi
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    
		return -E_NOT_SUPP;
  801824:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801829:	eb f2                	jmp    80181d <fstat+0x67>

0080182b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	56                   	push   %esi
  80182f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801830:	83 ec 08             	sub    $0x8,%esp
  801833:	6a 00                	push   $0x0
  801835:	ff 75 08             	push   0x8(%ebp)
  801838:	e8 e4 01 00 00       	call   801a21 <open>
  80183d:	89 c3                	mov    %eax,%ebx
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	85 c0                	test   %eax,%eax
  801844:	78 1b                	js     801861 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801846:	83 ec 08             	sub    $0x8,%esp
  801849:	ff 75 0c             	push   0xc(%ebp)
  80184c:	50                   	push   %eax
  80184d:	e8 64 ff ff ff       	call   8017b6 <fstat>
  801852:	89 c6                	mov    %eax,%esi
	close(fd);
  801854:	89 1c 24             	mov    %ebx,(%esp)
  801857:	e8 26 fc ff ff       	call   801482 <close>
	return r;
  80185c:	83 c4 10             	add    $0x10,%esp
  80185f:	89 f3                	mov    %esi,%ebx
}
  801861:	89 d8                	mov    %ebx,%eax
  801863:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801866:	5b                   	pop    %ebx
  801867:	5e                   	pop    %esi
  801868:	5d                   	pop    %ebp
  801869:	c3                   	ret    

0080186a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	56                   	push   %esi
  80186e:	53                   	push   %ebx
  80186f:	89 c6                	mov    %eax,%esi
  801871:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801873:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80187a:	74 27                	je     8018a3 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80187c:	6a 07                	push   $0x7
  80187e:	68 00 50 80 00       	push   $0x805000
  801883:	56                   	push   %esi
  801884:	ff 35 00 60 80 00    	push   0x806000
  80188a:	e8 bc f9 ff ff       	call   80124b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80188f:	83 c4 0c             	add    $0xc,%esp
  801892:	6a 00                	push   $0x0
  801894:	53                   	push   %ebx
  801895:	6a 00                	push   $0x0
  801897:	e8 3f f9 ff ff       	call   8011db <ipc_recv>
}
  80189c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80189f:	5b                   	pop    %ebx
  8018a0:	5e                   	pop    %esi
  8018a1:	5d                   	pop    %ebp
  8018a2:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018a3:	83 ec 0c             	sub    $0xc,%esp
  8018a6:	6a 01                	push   $0x1
  8018a8:	e8 f2 f9 ff ff       	call   80129f <ipc_find_env>
  8018ad:	a3 00 60 80 00       	mov    %eax,0x806000
  8018b2:	83 c4 10             	add    $0x10,%esp
  8018b5:	eb c5                	jmp    80187c <fsipc+0x12>

008018b7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018b7:	55                   	push   %ebp
  8018b8:	89 e5                	mov    %esp,%ebp
  8018ba:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c3:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018cb:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d5:	b8 02 00 00 00       	mov    $0x2,%eax
  8018da:	e8 8b ff ff ff       	call   80186a <fsipc>
}
  8018df:	c9                   	leave  
  8018e0:	c3                   	ret    

008018e1 <devfile_flush>:
{
  8018e1:	55                   	push   %ebp
  8018e2:	89 e5                	mov    %esp,%ebp
  8018e4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ed:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f7:	b8 06 00 00 00       	mov    $0x6,%eax
  8018fc:	e8 69 ff ff ff       	call   80186a <fsipc>
}
  801901:	c9                   	leave  
  801902:	c3                   	ret    

00801903 <devfile_stat>:
{
  801903:	55                   	push   %ebp
  801904:	89 e5                	mov    %esp,%ebp
  801906:	53                   	push   %ebx
  801907:	83 ec 04             	sub    $0x4,%esp
  80190a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80190d:	8b 45 08             	mov    0x8(%ebp),%eax
  801910:	8b 40 0c             	mov    0xc(%eax),%eax
  801913:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801918:	ba 00 00 00 00       	mov    $0x0,%edx
  80191d:	b8 05 00 00 00       	mov    $0x5,%eax
  801922:	e8 43 ff ff ff       	call   80186a <fsipc>
  801927:	85 c0                	test   %eax,%eax
  801929:	78 2c                	js     801957 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80192b:	83 ec 08             	sub    $0x8,%esp
  80192e:	68 00 50 80 00       	push   $0x805000
  801933:	53                   	push   %ebx
  801934:	e8 d3 ef ff ff       	call   80090c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801939:	a1 80 50 80 00       	mov    0x805080,%eax
  80193e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801944:	a1 84 50 80 00       	mov    0x805084,%eax
  801949:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80194f:	83 c4 10             	add    $0x10,%esp
  801952:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801957:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80195a:	c9                   	leave  
  80195b:	c3                   	ret    

0080195c <devfile_write>:
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	83 ec 0c             	sub    $0xc,%esp
  801962:	8b 45 10             	mov    0x10(%ebp),%eax
  801965:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80196a:	39 d0                	cmp    %edx,%eax
  80196c:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80196f:	8b 55 08             	mov    0x8(%ebp),%edx
  801972:	8b 52 0c             	mov    0xc(%edx),%edx
  801975:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80197b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801980:	50                   	push   %eax
  801981:	ff 75 0c             	push   0xc(%ebp)
  801984:	68 08 50 80 00       	push   $0x805008
  801989:	e8 14 f1 ff ff       	call   800aa2 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80198e:	ba 00 00 00 00       	mov    $0x0,%edx
  801993:	b8 04 00 00 00       	mov    $0x4,%eax
  801998:	e8 cd fe ff ff       	call   80186a <fsipc>
}
  80199d:	c9                   	leave  
  80199e:	c3                   	ret    

0080199f <devfile_read>:
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	56                   	push   %esi
  8019a3:	53                   	push   %ebx
  8019a4:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ad:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019b2:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bd:	b8 03 00 00 00       	mov    $0x3,%eax
  8019c2:	e8 a3 fe ff ff       	call   80186a <fsipc>
  8019c7:	89 c3                	mov    %eax,%ebx
  8019c9:	85 c0                	test   %eax,%eax
  8019cb:	78 1f                	js     8019ec <devfile_read+0x4d>
	assert(r <= n);
  8019cd:	39 f0                	cmp    %esi,%eax
  8019cf:	77 24                	ja     8019f5 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8019d1:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019d6:	7f 33                	jg     801a0b <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019d8:	83 ec 04             	sub    $0x4,%esp
  8019db:	50                   	push   %eax
  8019dc:	68 00 50 80 00       	push   $0x805000
  8019e1:	ff 75 0c             	push   0xc(%ebp)
  8019e4:	e8 b9 f0 ff ff       	call   800aa2 <memmove>
	return r;
  8019e9:	83 c4 10             	add    $0x10,%esp
}
  8019ec:	89 d8                	mov    %ebx,%eax
  8019ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019f1:	5b                   	pop    %ebx
  8019f2:	5e                   	pop    %esi
  8019f3:	5d                   	pop    %ebp
  8019f4:	c3                   	ret    
	assert(r <= n);
  8019f5:	68 e8 2c 80 00       	push   $0x802ce8
  8019fa:	68 ef 2c 80 00       	push   $0x802cef
  8019ff:	6a 7c                	push   $0x7c
  801a01:	68 04 2d 80 00       	push   $0x802d04
  801a06:	e8 4c e8 ff ff       	call   800257 <_panic>
	assert(r <= PGSIZE);
  801a0b:	68 0f 2d 80 00       	push   $0x802d0f
  801a10:	68 ef 2c 80 00       	push   $0x802cef
  801a15:	6a 7d                	push   $0x7d
  801a17:	68 04 2d 80 00       	push   $0x802d04
  801a1c:	e8 36 e8 ff ff       	call   800257 <_panic>

00801a21 <open>:
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	56                   	push   %esi
  801a25:	53                   	push   %ebx
  801a26:	83 ec 1c             	sub    $0x1c,%esp
  801a29:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801a2c:	56                   	push   %esi
  801a2d:	e8 9f ee ff ff       	call   8008d1 <strlen>
  801a32:	83 c4 10             	add    $0x10,%esp
  801a35:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a3a:	7f 6c                	jg     801aa8 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801a3c:	83 ec 0c             	sub    $0xc,%esp
  801a3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a42:	50                   	push   %eax
  801a43:	e8 bd f8 ff ff       	call   801305 <fd_alloc>
  801a48:	89 c3                	mov    %eax,%ebx
  801a4a:	83 c4 10             	add    $0x10,%esp
  801a4d:	85 c0                	test   %eax,%eax
  801a4f:	78 3c                	js     801a8d <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801a51:	83 ec 08             	sub    $0x8,%esp
  801a54:	56                   	push   %esi
  801a55:	68 00 50 80 00       	push   $0x805000
  801a5a:	e8 ad ee ff ff       	call   80090c <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a62:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a67:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a6a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a6f:	e8 f6 fd ff ff       	call   80186a <fsipc>
  801a74:	89 c3                	mov    %eax,%ebx
  801a76:	83 c4 10             	add    $0x10,%esp
  801a79:	85 c0                	test   %eax,%eax
  801a7b:	78 19                	js     801a96 <open+0x75>
	return fd2num(fd);
  801a7d:	83 ec 0c             	sub    $0xc,%esp
  801a80:	ff 75 f4             	push   -0xc(%ebp)
  801a83:	e8 56 f8 ff ff       	call   8012de <fd2num>
  801a88:	89 c3                	mov    %eax,%ebx
  801a8a:	83 c4 10             	add    $0x10,%esp
}
  801a8d:	89 d8                	mov    %ebx,%eax
  801a8f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a92:	5b                   	pop    %ebx
  801a93:	5e                   	pop    %esi
  801a94:	5d                   	pop    %ebp
  801a95:	c3                   	ret    
		fd_close(fd, 0);
  801a96:	83 ec 08             	sub    $0x8,%esp
  801a99:	6a 00                	push   $0x0
  801a9b:	ff 75 f4             	push   -0xc(%ebp)
  801a9e:	e8 58 f9 ff ff       	call   8013fb <fd_close>
		return r;
  801aa3:	83 c4 10             	add    $0x10,%esp
  801aa6:	eb e5                	jmp    801a8d <open+0x6c>
		return -E_BAD_PATH;
  801aa8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801aad:	eb de                	jmp    801a8d <open+0x6c>

00801aaf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801aaf:	55                   	push   %ebp
  801ab0:	89 e5                	mov    %esp,%ebp
  801ab2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ab5:	ba 00 00 00 00       	mov    $0x0,%edx
  801aba:	b8 08 00 00 00       	mov    $0x8,%eax
  801abf:	e8 a6 fd ff ff       	call   80186a <fsipc>
}
  801ac4:	c9                   	leave  
  801ac5:	c3                   	ret    

00801ac6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801acc:	89 c2                	mov    %eax,%edx
  801ace:	c1 ea 16             	shr    $0x16,%edx
  801ad1:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801ad8:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801add:	f6 c1 01             	test   $0x1,%cl
  801ae0:	74 1c                	je     801afe <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801ae2:	c1 e8 0c             	shr    $0xc,%eax
  801ae5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801aec:	a8 01                	test   $0x1,%al
  801aee:	74 0e                	je     801afe <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801af0:	c1 e8 0c             	shr    $0xc,%eax
  801af3:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801afa:	ef 
  801afb:	0f b7 d2             	movzwl %dx,%edx
}
  801afe:	89 d0                	mov    %edx,%eax
  801b00:	5d                   	pop    %ebp
  801b01:	c3                   	ret    

00801b02 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b02:	55                   	push   %ebp
  801b03:	89 e5                	mov    %esp,%ebp
  801b05:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801b08:	68 1b 2d 80 00       	push   $0x802d1b
  801b0d:	ff 75 0c             	push   0xc(%ebp)
  801b10:	e8 f7 ed ff ff       	call   80090c <strcpy>
	return 0;
}
  801b15:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1a:	c9                   	leave  
  801b1b:	c3                   	ret    

00801b1c <devsock_close>:
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	53                   	push   %ebx
  801b20:	83 ec 10             	sub    $0x10,%esp
  801b23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b26:	53                   	push   %ebx
  801b27:	e8 9a ff ff ff       	call   801ac6 <pageref>
  801b2c:	89 c2                	mov    %eax,%edx
  801b2e:	83 c4 10             	add    $0x10,%esp
		return 0;
  801b31:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801b36:	83 fa 01             	cmp    $0x1,%edx
  801b39:	74 05                	je     801b40 <devsock_close+0x24>
}
  801b3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b3e:	c9                   	leave  
  801b3f:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801b40:	83 ec 0c             	sub    $0xc,%esp
  801b43:	ff 73 0c             	push   0xc(%ebx)
  801b46:	e8 b7 02 00 00       	call   801e02 <nsipc_close>
  801b4b:	83 c4 10             	add    $0x10,%esp
  801b4e:	eb eb                	jmp    801b3b <devsock_close+0x1f>

00801b50 <devsock_write>:
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b56:	6a 00                	push   $0x0
  801b58:	ff 75 10             	push   0x10(%ebp)
  801b5b:	ff 75 0c             	push   0xc(%ebp)
  801b5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b61:	ff 70 0c             	push   0xc(%eax)
  801b64:	e8 79 03 00 00       	call   801ee2 <nsipc_send>
}
  801b69:	c9                   	leave  
  801b6a:	c3                   	ret    

00801b6b <devsock_read>:
{
  801b6b:	55                   	push   %ebp
  801b6c:	89 e5                	mov    %esp,%ebp
  801b6e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b71:	6a 00                	push   $0x0
  801b73:	ff 75 10             	push   0x10(%ebp)
  801b76:	ff 75 0c             	push   0xc(%ebp)
  801b79:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7c:	ff 70 0c             	push   0xc(%eax)
  801b7f:	e8 ef 02 00 00       	call   801e73 <nsipc_recv>
}
  801b84:	c9                   	leave  
  801b85:	c3                   	ret    

00801b86 <fd2sockid>:
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b8c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b8f:	52                   	push   %edx
  801b90:	50                   	push   %eax
  801b91:	e8 bf f7 ff ff       	call   801355 <fd_lookup>
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	78 10                	js     801bad <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801b9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ba0:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801ba6:	39 08                	cmp    %ecx,(%eax)
  801ba8:	75 05                	jne    801baf <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801baa:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801bad:	c9                   	leave  
  801bae:	c3                   	ret    
		return -E_NOT_SUPP;
  801baf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801bb4:	eb f7                	jmp    801bad <fd2sockid+0x27>

00801bb6 <alloc_sockfd>:
{
  801bb6:	55                   	push   %ebp
  801bb7:	89 e5                	mov    %esp,%ebp
  801bb9:	56                   	push   %esi
  801bba:	53                   	push   %ebx
  801bbb:	83 ec 1c             	sub    $0x1c,%esp
  801bbe:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801bc0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc3:	50                   	push   %eax
  801bc4:	e8 3c f7 ff ff       	call   801305 <fd_alloc>
  801bc9:	89 c3                	mov    %eax,%ebx
  801bcb:	83 c4 10             	add    $0x10,%esp
  801bce:	85 c0                	test   %eax,%eax
  801bd0:	78 43                	js     801c15 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801bd2:	83 ec 04             	sub    $0x4,%esp
  801bd5:	68 07 04 00 00       	push   $0x407
  801bda:	ff 75 f4             	push   -0xc(%ebp)
  801bdd:	6a 00                	push   $0x0
  801bdf:	e8 24 f1 ff ff       	call   800d08 <sys_page_alloc>
  801be4:	89 c3                	mov    %eax,%ebx
  801be6:	83 c4 10             	add    $0x10,%esp
  801be9:	85 c0                	test   %eax,%eax
  801beb:	78 28                	js     801c15 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf0:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bf6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c02:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c05:	83 ec 0c             	sub    $0xc,%esp
  801c08:	50                   	push   %eax
  801c09:	e8 d0 f6 ff ff       	call   8012de <fd2num>
  801c0e:	89 c3                	mov    %eax,%ebx
  801c10:	83 c4 10             	add    $0x10,%esp
  801c13:	eb 0c                	jmp    801c21 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801c15:	83 ec 0c             	sub    $0xc,%esp
  801c18:	56                   	push   %esi
  801c19:	e8 e4 01 00 00       	call   801e02 <nsipc_close>
		return r;
  801c1e:	83 c4 10             	add    $0x10,%esp
}
  801c21:	89 d8                	mov    %ebx,%eax
  801c23:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c26:	5b                   	pop    %ebx
  801c27:	5e                   	pop    %esi
  801c28:	5d                   	pop    %ebp
  801c29:	c3                   	ret    

00801c2a <accept>:
{
  801c2a:	55                   	push   %ebp
  801c2b:	89 e5                	mov    %esp,%ebp
  801c2d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c30:	8b 45 08             	mov    0x8(%ebp),%eax
  801c33:	e8 4e ff ff ff       	call   801b86 <fd2sockid>
  801c38:	85 c0                	test   %eax,%eax
  801c3a:	78 1b                	js     801c57 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c3c:	83 ec 04             	sub    $0x4,%esp
  801c3f:	ff 75 10             	push   0x10(%ebp)
  801c42:	ff 75 0c             	push   0xc(%ebp)
  801c45:	50                   	push   %eax
  801c46:	e8 0e 01 00 00       	call   801d59 <nsipc_accept>
  801c4b:	83 c4 10             	add    $0x10,%esp
  801c4e:	85 c0                	test   %eax,%eax
  801c50:	78 05                	js     801c57 <accept+0x2d>
	return alloc_sockfd(r);
  801c52:	e8 5f ff ff ff       	call   801bb6 <alloc_sockfd>
}
  801c57:	c9                   	leave  
  801c58:	c3                   	ret    

00801c59 <bind>:
{
  801c59:	55                   	push   %ebp
  801c5a:	89 e5                	mov    %esp,%ebp
  801c5c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c62:	e8 1f ff ff ff       	call   801b86 <fd2sockid>
  801c67:	85 c0                	test   %eax,%eax
  801c69:	78 12                	js     801c7d <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801c6b:	83 ec 04             	sub    $0x4,%esp
  801c6e:	ff 75 10             	push   0x10(%ebp)
  801c71:	ff 75 0c             	push   0xc(%ebp)
  801c74:	50                   	push   %eax
  801c75:	e8 31 01 00 00       	call   801dab <nsipc_bind>
  801c7a:	83 c4 10             	add    $0x10,%esp
}
  801c7d:	c9                   	leave  
  801c7e:	c3                   	ret    

00801c7f <shutdown>:
{
  801c7f:	55                   	push   %ebp
  801c80:	89 e5                	mov    %esp,%ebp
  801c82:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c85:	8b 45 08             	mov    0x8(%ebp),%eax
  801c88:	e8 f9 fe ff ff       	call   801b86 <fd2sockid>
  801c8d:	85 c0                	test   %eax,%eax
  801c8f:	78 0f                	js     801ca0 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801c91:	83 ec 08             	sub    $0x8,%esp
  801c94:	ff 75 0c             	push   0xc(%ebp)
  801c97:	50                   	push   %eax
  801c98:	e8 43 01 00 00       	call   801de0 <nsipc_shutdown>
  801c9d:	83 c4 10             	add    $0x10,%esp
}
  801ca0:	c9                   	leave  
  801ca1:	c3                   	ret    

00801ca2 <connect>:
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ca8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cab:	e8 d6 fe ff ff       	call   801b86 <fd2sockid>
  801cb0:	85 c0                	test   %eax,%eax
  801cb2:	78 12                	js     801cc6 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801cb4:	83 ec 04             	sub    $0x4,%esp
  801cb7:	ff 75 10             	push   0x10(%ebp)
  801cba:	ff 75 0c             	push   0xc(%ebp)
  801cbd:	50                   	push   %eax
  801cbe:	e8 59 01 00 00       	call   801e1c <nsipc_connect>
  801cc3:	83 c4 10             	add    $0x10,%esp
}
  801cc6:	c9                   	leave  
  801cc7:	c3                   	ret    

00801cc8 <listen>:
{
  801cc8:	55                   	push   %ebp
  801cc9:	89 e5                	mov    %esp,%ebp
  801ccb:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801cce:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd1:	e8 b0 fe ff ff       	call   801b86 <fd2sockid>
  801cd6:	85 c0                	test   %eax,%eax
  801cd8:	78 0f                	js     801ce9 <listen+0x21>
	return nsipc_listen(r, backlog);
  801cda:	83 ec 08             	sub    $0x8,%esp
  801cdd:	ff 75 0c             	push   0xc(%ebp)
  801ce0:	50                   	push   %eax
  801ce1:	e8 6b 01 00 00       	call   801e51 <nsipc_listen>
  801ce6:	83 c4 10             	add    $0x10,%esp
}
  801ce9:	c9                   	leave  
  801cea:	c3                   	ret    

00801ceb <socket>:

int
socket(int domain, int type, int protocol)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801cf1:	ff 75 10             	push   0x10(%ebp)
  801cf4:	ff 75 0c             	push   0xc(%ebp)
  801cf7:	ff 75 08             	push   0x8(%ebp)
  801cfa:	e8 41 02 00 00       	call   801f40 <nsipc_socket>
  801cff:	83 c4 10             	add    $0x10,%esp
  801d02:	85 c0                	test   %eax,%eax
  801d04:	78 05                	js     801d0b <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801d06:	e8 ab fe ff ff       	call   801bb6 <alloc_sockfd>
}
  801d0b:	c9                   	leave  
  801d0c:	c3                   	ret    

00801d0d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d0d:	55                   	push   %ebp
  801d0e:	89 e5                	mov    %esp,%ebp
  801d10:	53                   	push   %ebx
  801d11:	83 ec 04             	sub    $0x4,%esp
  801d14:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d16:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801d1d:	74 26                	je     801d45 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d1f:	6a 07                	push   $0x7
  801d21:	68 00 70 80 00       	push   $0x807000
  801d26:	53                   	push   %ebx
  801d27:	ff 35 00 80 80 00    	push   0x808000
  801d2d:	e8 19 f5 ff ff       	call   80124b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d32:	83 c4 0c             	add    $0xc,%esp
  801d35:	6a 00                	push   $0x0
  801d37:	6a 00                	push   $0x0
  801d39:	6a 00                	push   $0x0
  801d3b:	e8 9b f4 ff ff       	call   8011db <ipc_recv>
}
  801d40:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d43:	c9                   	leave  
  801d44:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d45:	83 ec 0c             	sub    $0xc,%esp
  801d48:	6a 02                	push   $0x2
  801d4a:	e8 50 f5 ff ff       	call   80129f <ipc_find_env>
  801d4f:	a3 00 80 80 00       	mov    %eax,0x808000
  801d54:	83 c4 10             	add    $0x10,%esp
  801d57:	eb c6                	jmp    801d1f <nsipc+0x12>

00801d59 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d59:	55                   	push   %ebp
  801d5a:	89 e5                	mov    %esp,%ebp
  801d5c:	56                   	push   %esi
  801d5d:	53                   	push   %ebx
  801d5e:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d61:	8b 45 08             	mov    0x8(%ebp),%eax
  801d64:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d69:	8b 06                	mov    (%esi),%eax
  801d6b:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d70:	b8 01 00 00 00       	mov    $0x1,%eax
  801d75:	e8 93 ff ff ff       	call   801d0d <nsipc>
  801d7a:	89 c3                	mov    %eax,%ebx
  801d7c:	85 c0                	test   %eax,%eax
  801d7e:	79 09                	jns    801d89 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801d80:	89 d8                	mov    %ebx,%eax
  801d82:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d85:	5b                   	pop    %ebx
  801d86:	5e                   	pop    %esi
  801d87:	5d                   	pop    %ebp
  801d88:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d89:	83 ec 04             	sub    $0x4,%esp
  801d8c:	ff 35 10 70 80 00    	push   0x807010
  801d92:	68 00 70 80 00       	push   $0x807000
  801d97:	ff 75 0c             	push   0xc(%ebp)
  801d9a:	e8 03 ed ff ff       	call   800aa2 <memmove>
		*addrlen = ret->ret_addrlen;
  801d9f:	a1 10 70 80 00       	mov    0x807010,%eax
  801da4:	89 06                	mov    %eax,(%esi)
  801da6:	83 c4 10             	add    $0x10,%esp
	return r;
  801da9:	eb d5                	jmp    801d80 <nsipc_accept+0x27>

00801dab <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	53                   	push   %ebx
  801daf:	83 ec 08             	sub    $0x8,%esp
  801db2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801db5:	8b 45 08             	mov    0x8(%ebp),%eax
  801db8:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801dbd:	53                   	push   %ebx
  801dbe:	ff 75 0c             	push   0xc(%ebp)
  801dc1:	68 04 70 80 00       	push   $0x807004
  801dc6:	e8 d7 ec ff ff       	call   800aa2 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801dcb:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801dd1:	b8 02 00 00 00       	mov    $0x2,%eax
  801dd6:	e8 32 ff ff ff       	call   801d0d <nsipc>
}
  801ddb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dde:	c9                   	leave  
  801ddf:	c3                   	ret    

00801de0 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801de6:	8b 45 08             	mov    0x8(%ebp),%eax
  801de9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801dee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df1:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801df6:	b8 03 00 00 00       	mov    $0x3,%eax
  801dfb:	e8 0d ff ff ff       	call   801d0d <nsipc>
}
  801e00:	c9                   	leave  
  801e01:	c3                   	ret    

00801e02 <nsipc_close>:

int
nsipc_close(int s)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e08:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0b:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801e10:	b8 04 00 00 00       	mov    $0x4,%eax
  801e15:	e8 f3 fe ff ff       	call   801d0d <nsipc>
}
  801e1a:	c9                   	leave  
  801e1b:	c3                   	ret    

00801e1c <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	53                   	push   %ebx
  801e20:	83 ec 08             	sub    $0x8,%esp
  801e23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e26:	8b 45 08             	mov    0x8(%ebp),%eax
  801e29:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e2e:	53                   	push   %ebx
  801e2f:	ff 75 0c             	push   0xc(%ebp)
  801e32:	68 04 70 80 00       	push   $0x807004
  801e37:	e8 66 ec ff ff       	call   800aa2 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e3c:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801e42:	b8 05 00 00 00       	mov    $0x5,%eax
  801e47:	e8 c1 fe ff ff       	call   801d0d <nsipc>
}
  801e4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e4f:	c9                   	leave  
  801e50:	c3                   	ret    

00801e51 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801e51:	55                   	push   %ebp
  801e52:	89 e5                	mov    %esp,%ebp
  801e54:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801e57:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801e5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e62:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801e67:	b8 06 00 00 00       	mov    $0x6,%eax
  801e6c:	e8 9c fe ff ff       	call   801d0d <nsipc>
}
  801e71:	c9                   	leave  
  801e72:	c3                   	ret    

00801e73 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e73:	55                   	push   %ebp
  801e74:	89 e5                	mov    %esp,%ebp
  801e76:	56                   	push   %esi
  801e77:	53                   	push   %ebx
  801e78:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e7e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801e83:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801e89:	8b 45 14             	mov    0x14(%ebp),%eax
  801e8c:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e91:	b8 07 00 00 00       	mov    $0x7,%eax
  801e96:	e8 72 fe ff ff       	call   801d0d <nsipc>
  801e9b:	89 c3                	mov    %eax,%ebx
  801e9d:	85 c0                	test   %eax,%eax
  801e9f:	78 22                	js     801ec3 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801ea1:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801ea6:	39 c6                	cmp    %eax,%esi
  801ea8:	0f 4e c6             	cmovle %esi,%eax
  801eab:	39 c3                	cmp    %eax,%ebx
  801ead:	7f 1d                	jg     801ecc <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801eaf:	83 ec 04             	sub    $0x4,%esp
  801eb2:	53                   	push   %ebx
  801eb3:	68 00 70 80 00       	push   $0x807000
  801eb8:	ff 75 0c             	push   0xc(%ebp)
  801ebb:	e8 e2 eb ff ff       	call   800aa2 <memmove>
  801ec0:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ec3:	89 d8                	mov    %ebx,%eax
  801ec5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ec8:	5b                   	pop    %ebx
  801ec9:	5e                   	pop    %esi
  801eca:	5d                   	pop    %ebp
  801ecb:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801ecc:	68 27 2d 80 00       	push   $0x802d27
  801ed1:	68 ef 2c 80 00       	push   $0x802cef
  801ed6:	6a 62                	push   $0x62
  801ed8:	68 3c 2d 80 00       	push   $0x802d3c
  801edd:	e8 75 e3 ff ff       	call   800257 <_panic>

00801ee2 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ee2:	55                   	push   %ebp
  801ee3:	89 e5                	mov    %esp,%ebp
  801ee5:	53                   	push   %ebx
  801ee6:	83 ec 04             	sub    $0x4,%esp
  801ee9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801eec:	8b 45 08             	mov    0x8(%ebp),%eax
  801eef:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801ef4:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801efa:	7f 2e                	jg     801f2a <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801efc:	83 ec 04             	sub    $0x4,%esp
  801eff:	53                   	push   %ebx
  801f00:	ff 75 0c             	push   0xc(%ebp)
  801f03:	68 0c 70 80 00       	push   $0x80700c
  801f08:	e8 95 eb ff ff       	call   800aa2 <memmove>
	nsipcbuf.send.req_size = size;
  801f0d:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801f13:	8b 45 14             	mov    0x14(%ebp),%eax
  801f16:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801f1b:	b8 08 00 00 00       	mov    $0x8,%eax
  801f20:	e8 e8 fd ff ff       	call   801d0d <nsipc>
}
  801f25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f28:	c9                   	leave  
  801f29:	c3                   	ret    
	assert(size < 1600);
  801f2a:	68 48 2d 80 00       	push   $0x802d48
  801f2f:	68 ef 2c 80 00       	push   $0x802cef
  801f34:	6a 6d                	push   $0x6d
  801f36:	68 3c 2d 80 00       	push   $0x802d3c
  801f3b:	e8 17 e3 ff ff       	call   800257 <_panic>

00801f40 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801f40:	55                   	push   %ebp
  801f41:	89 e5                	mov    %esp,%ebp
  801f43:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801f46:	8b 45 08             	mov    0x8(%ebp),%eax
  801f49:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801f4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f51:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801f56:	8b 45 10             	mov    0x10(%ebp),%eax
  801f59:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801f5e:	b8 09 00 00 00       	mov    $0x9,%eax
  801f63:	e8 a5 fd ff ff       	call   801d0d <nsipc>
}
  801f68:	c9                   	leave  
  801f69:	c3                   	ret    

00801f6a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	56                   	push   %esi
  801f6e:	53                   	push   %ebx
  801f6f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f72:	83 ec 0c             	sub    $0xc,%esp
  801f75:	ff 75 08             	push   0x8(%ebp)
  801f78:	e8 71 f3 ff ff       	call   8012ee <fd2data>
  801f7d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f7f:	83 c4 08             	add    $0x8,%esp
  801f82:	68 54 2d 80 00       	push   $0x802d54
  801f87:	53                   	push   %ebx
  801f88:	e8 7f e9 ff ff       	call   80090c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f8d:	8b 46 04             	mov    0x4(%esi),%eax
  801f90:	2b 06                	sub    (%esi),%eax
  801f92:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f98:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f9f:	00 00 00 
	stat->st_dev = &devpipe;
  801fa2:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801fa9:	30 80 00 
	return 0;
}
  801fac:	b8 00 00 00 00       	mov    $0x0,%eax
  801fb1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb4:	5b                   	pop    %ebx
  801fb5:	5e                   	pop    %esi
  801fb6:	5d                   	pop    %ebp
  801fb7:	c3                   	ret    

00801fb8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801fb8:	55                   	push   %ebp
  801fb9:	89 e5                	mov    %esp,%ebp
  801fbb:	53                   	push   %ebx
  801fbc:	83 ec 0c             	sub    $0xc,%esp
  801fbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801fc2:	53                   	push   %ebx
  801fc3:	6a 00                	push   $0x0
  801fc5:	e8 c3 ed ff ff       	call   800d8d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801fca:	89 1c 24             	mov    %ebx,(%esp)
  801fcd:	e8 1c f3 ff ff       	call   8012ee <fd2data>
  801fd2:	83 c4 08             	add    $0x8,%esp
  801fd5:	50                   	push   %eax
  801fd6:	6a 00                	push   $0x0
  801fd8:	e8 b0 ed ff ff       	call   800d8d <sys_page_unmap>
}
  801fdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fe0:	c9                   	leave  
  801fe1:	c3                   	ret    

00801fe2 <_pipeisclosed>:
{
  801fe2:	55                   	push   %ebp
  801fe3:	89 e5                	mov    %esp,%ebp
  801fe5:	57                   	push   %edi
  801fe6:	56                   	push   %esi
  801fe7:	53                   	push   %ebx
  801fe8:	83 ec 1c             	sub    $0x1c,%esp
  801feb:	89 c7                	mov    %eax,%edi
  801fed:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801fef:	a1 00 40 80 00       	mov    0x804000,%eax
  801ff4:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ff7:	83 ec 0c             	sub    $0xc,%esp
  801ffa:	57                   	push   %edi
  801ffb:	e8 c6 fa ff ff       	call   801ac6 <pageref>
  802000:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802003:	89 34 24             	mov    %esi,(%esp)
  802006:	e8 bb fa ff ff       	call   801ac6 <pageref>
		nn = thisenv->env_runs;
  80200b:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802011:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  802014:	83 c4 10             	add    $0x10,%esp
  802017:	39 cb                	cmp    %ecx,%ebx
  802019:	74 1b                	je     802036 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  80201b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80201e:	75 cf                	jne    801fef <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802020:	8b 42 68             	mov    0x68(%edx),%eax
  802023:	6a 01                	push   $0x1
  802025:	50                   	push   %eax
  802026:	53                   	push   %ebx
  802027:	68 5b 2d 80 00       	push   $0x802d5b
  80202c:	e8 01 e3 ff ff       	call   800332 <cprintf>
  802031:	83 c4 10             	add    $0x10,%esp
  802034:	eb b9                	jmp    801fef <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802036:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802039:	0f 94 c0             	sete   %al
  80203c:	0f b6 c0             	movzbl %al,%eax
}
  80203f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802042:	5b                   	pop    %ebx
  802043:	5e                   	pop    %esi
  802044:	5f                   	pop    %edi
  802045:	5d                   	pop    %ebp
  802046:	c3                   	ret    

00802047 <devpipe_write>:
{
  802047:	55                   	push   %ebp
  802048:	89 e5                	mov    %esp,%ebp
  80204a:	57                   	push   %edi
  80204b:	56                   	push   %esi
  80204c:	53                   	push   %ebx
  80204d:	83 ec 28             	sub    $0x28,%esp
  802050:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802053:	56                   	push   %esi
  802054:	e8 95 f2 ff ff       	call   8012ee <fd2data>
  802059:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80205b:	83 c4 10             	add    $0x10,%esp
  80205e:	bf 00 00 00 00       	mov    $0x0,%edi
  802063:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802066:	75 09                	jne    802071 <devpipe_write+0x2a>
	return i;
  802068:	89 f8                	mov    %edi,%eax
  80206a:	eb 23                	jmp    80208f <devpipe_write+0x48>
			sys_yield();
  80206c:	e8 78 ec ff ff       	call   800ce9 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802071:	8b 43 04             	mov    0x4(%ebx),%eax
  802074:	8b 0b                	mov    (%ebx),%ecx
  802076:	8d 51 20             	lea    0x20(%ecx),%edx
  802079:	39 d0                	cmp    %edx,%eax
  80207b:	72 1a                	jb     802097 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  80207d:	89 da                	mov    %ebx,%edx
  80207f:	89 f0                	mov    %esi,%eax
  802081:	e8 5c ff ff ff       	call   801fe2 <_pipeisclosed>
  802086:	85 c0                	test   %eax,%eax
  802088:	74 e2                	je     80206c <devpipe_write+0x25>
				return 0;
  80208a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80208f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802092:	5b                   	pop    %ebx
  802093:	5e                   	pop    %esi
  802094:	5f                   	pop    %edi
  802095:	5d                   	pop    %ebp
  802096:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802097:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80209a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80209e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8020a1:	89 c2                	mov    %eax,%edx
  8020a3:	c1 fa 1f             	sar    $0x1f,%edx
  8020a6:	89 d1                	mov    %edx,%ecx
  8020a8:	c1 e9 1b             	shr    $0x1b,%ecx
  8020ab:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8020ae:	83 e2 1f             	and    $0x1f,%edx
  8020b1:	29 ca                	sub    %ecx,%edx
  8020b3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8020b7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8020bb:	83 c0 01             	add    $0x1,%eax
  8020be:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  8020c1:	83 c7 01             	add    $0x1,%edi
  8020c4:	eb 9d                	jmp    802063 <devpipe_write+0x1c>

008020c6 <devpipe_read>:
{
  8020c6:	55                   	push   %ebp
  8020c7:	89 e5                	mov    %esp,%ebp
  8020c9:	57                   	push   %edi
  8020ca:	56                   	push   %esi
  8020cb:	53                   	push   %ebx
  8020cc:	83 ec 18             	sub    $0x18,%esp
  8020cf:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8020d2:	57                   	push   %edi
  8020d3:	e8 16 f2 ff ff       	call   8012ee <fd2data>
  8020d8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8020da:	83 c4 10             	add    $0x10,%esp
  8020dd:	be 00 00 00 00       	mov    $0x0,%esi
  8020e2:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020e5:	75 13                	jne    8020fa <devpipe_read+0x34>
	return i;
  8020e7:	89 f0                	mov    %esi,%eax
  8020e9:	eb 02                	jmp    8020ed <devpipe_read+0x27>
				return i;
  8020eb:	89 f0                	mov    %esi,%eax
}
  8020ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020f0:	5b                   	pop    %ebx
  8020f1:	5e                   	pop    %esi
  8020f2:	5f                   	pop    %edi
  8020f3:	5d                   	pop    %ebp
  8020f4:	c3                   	ret    
			sys_yield();
  8020f5:	e8 ef eb ff ff       	call   800ce9 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8020fa:	8b 03                	mov    (%ebx),%eax
  8020fc:	3b 43 04             	cmp    0x4(%ebx),%eax
  8020ff:	75 18                	jne    802119 <devpipe_read+0x53>
			if (i > 0)
  802101:	85 f6                	test   %esi,%esi
  802103:	75 e6                	jne    8020eb <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  802105:	89 da                	mov    %ebx,%edx
  802107:	89 f8                	mov    %edi,%eax
  802109:	e8 d4 fe ff ff       	call   801fe2 <_pipeisclosed>
  80210e:	85 c0                	test   %eax,%eax
  802110:	74 e3                	je     8020f5 <devpipe_read+0x2f>
				return 0;
  802112:	b8 00 00 00 00       	mov    $0x0,%eax
  802117:	eb d4                	jmp    8020ed <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802119:	99                   	cltd   
  80211a:	c1 ea 1b             	shr    $0x1b,%edx
  80211d:	01 d0                	add    %edx,%eax
  80211f:	83 e0 1f             	and    $0x1f,%eax
  802122:	29 d0                	sub    %edx,%eax
  802124:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802129:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80212c:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80212f:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802132:	83 c6 01             	add    $0x1,%esi
  802135:	eb ab                	jmp    8020e2 <devpipe_read+0x1c>

00802137 <pipe>:
{
  802137:	55                   	push   %ebp
  802138:	89 e5                	mov    %esp,%ebp
  80213a:	56                   	push   %esi
  80213b:	53                   	push   %ebx
  80213c:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80213f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802142:	50                   	push   %eax
  802143:	e8 bd f1 ff ff       	call   801305 <fd_alloc>
  802148:	89 c3                	mov    %eax,%ebx
  80214a:	83 c4 10             	add    $0x10,%esp
  80214d:	85 c0                	test   %eax,%eax
  80214f:	0f 88 23 01 00 00    	js     802278 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802155:	83 ec 04             	sub    $0x4,%esp
  802158:	68 07 04 00 00       	push   $0x407
  80215d:	ff 75 f4             	push   -0xc(%ebp)
  802160:	6a 00                	push   $0x0
  802162:	e8 a1 eb ff ff       	call   800d08 <sys_page_alloc>
  802167:	89 c3                	mov    %eax,%ebx
  802169:	83 c4 10             	add    $0x10,%esp
  80216c:	85 c0                	test   %eax,%eax
  80216e:	0f 88 04 01 00 00    	js     802278 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802174:	83 ec 0c             	sub    $0xc,%esp
  802177:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80217a:	50                   	push   %eax
  80217b:	e8 85 f1 ff ff       	call   801305 <fd_alloc>
  802180:	89 c3                	mov    %eax,%ebx
  802182:	83 c4 10             	add    $0x10,%esp
  802185:	85 c0                	test   %eax,%eax
  802187:	0f 88 db 00 00 00    	js     802268 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80218d:	83 ec 04             	sub    $0x4,%esp
  802190:	68 07 04 00 00       	push   $0x407
  802195:	ff 75 f0             	push   -0x10(%ebp)
  802198:	6a 00                	push   $0x0
  80219a:	e8 69 eb ff ff       	call   800d08 <sys_page_alloc>
  80219f:	89 c3                	mov    %eax,%ebx
  8021a1:	83 c4 10             	add    $0x10,%esp
  8021a4:	85 c0                	test   %eax,%eax
  8021a6:	0f 88 bc 00 00 00    	js     802268 <pipe+0x131>
	va = fd2data(fd0);
  8021ac:	83 ec 0c             	sub    $0xc,%esp
  8021af:	ff 75 f4             	push   -0xc(%ebp)
  8021b2:	e8 37 f1 ff ff       	call   8012ee <fd2data>
  8021b7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021b9:	83 c4 0c             	add    $0xc,%esp
  8021bc:	68 07 04 00 00       	push   $0x407
  8021c1:	50                   	push   %eax
  8021c2:	6a 00                	push   $0x0
  8021c4:	e8 3f eb ff ff       	call   800d08 <sys_page_alloc>
  8021c9:	89 c3                	mov    %eax,%ebx
  8021cb:	83 c4 10             	add    $0x10,%esp
  8021ce:	85 c0                	test   %eax,%eax
  8021d0:	0f 88 82 00 00 00    	js     802258 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021d6:	83 ec 0c             	sub    $0xc,%esp
  8021d9:	ff 75 f0             	push   -0x10(%ebp)
  8021dc:	e8 0d f1 ff ff       	call   8012ee <fd2data>
  8021e1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8021e8:	50                   	push   %eax
  8021e9:	6a 00                	push   $0x0
  8021eb:	56                   	push   %esi
  8021ec:	6a 00                	push   $0x0
  8021ee:	e8 58 eb ff ff       	call   800d4b <sys_page_map>
  8021f3:	89 c3                	mov    %eax,%ebx
  8021f5:	83 c4 20             	add    $0x20,%esp
  8021f8:	85 c0                	test   %eax,%eax
  8021fa:	78 4e                	js     80224a <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8021fc:	a1 3c 30 80 00       	mov    0x80303c,%eax
  802201:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802204:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802206:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802209:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802210:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802213:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802215:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802218:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80221f:	83 ec 0c             	sub    $0xc,%esp
  802222:	ff 75 f4             	push   -0xc(%ebp)
  802225:	e8 b4 f0 ff ff       	call   8012de <fd2num>
  80222a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80222d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80222f:	83 c4 04             	add    $0x4,%esp
  802232:	ff 75 f0             	push   -0x10(%ebp)
  802235:	e8 a4 f0 ff ff       	call   8012de <fd2num>
  80223a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80223d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802240:	83 c4 10             	add    $0x10,%esp
  802243:	bb 00 00 00 00       	mov    $0x0,%ebx
  802248:	eb 2e                	jmp    802278 <pipe+0x141>
	sys_page_unmap(0, va);
  80224a:	83 ec 08             	sub    $0x8,%esp
  80224d:	56                   	push   %esi
  80224e:	6a 00                	push   $0x0
  802250:	e8 38 eb ff ff       	call   800d8d <sys_page_unmap>
  802255:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802258:	83 ec 08             	sub    $0x8,%esp
  80225b:	ff 75 f0             	push   -0x10(%ebp)
  80225e:	6a 00                	push   $0x0
  802260:	e8 28 eb ff ff       	call   800d8d <sys_page_unmap>
  802265:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802268:	83 ec 08             	sub    $0x8,%esp
  80226b:	ff 75 f4             	push   -0xc(%ebp)
  80226e:	6a 00                	push   $0x0
  802270:	e8 18 eb ff ff       	call   800d8d <sys_page_unmap>
  802275:	83 c4 10             	add    $0x10,%esp
}
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80227d:	5b                   	pop    %ebx
  80227e:	5e                   	pop    %esi
  80227f:	5d                   	pop    %ebp
  802280:	c3                   	ret    

00802281 <pipeisclosed>:
{
  802281:	55                   	push   %ebp
  802282:	89 e5                	mov    %esp,%ebp
  802284:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802287:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80228a:	50                   	push   %eax
  80228b:	ff 75 08             	push   0x8(%ebp)
  80228e:	e8 c2 f0 ff ff       	call   801355 <fd_lookup>
  802293:	83 c4 10             	add    $0x10,%esp
  802296:	85 c0                	test   %eax,%eax
  802298:	78 18                	js     8022b2 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80229a:	83 ec 0c             	sub    $0xc,%esp
  80229d:	ff 75 f4             	push   -0xc(%ebp)
  8022a0:	e8 49 f0 ff ff       	call   8012ee <fd2data>
  8022a5:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8022a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022aa:	e8 33 fd ff ff       	call   801fe2 <_pipeisclosed>
  8022af:	83 c4 10             	add    $0x10,%esp
}
  8022b2:	c9                   	leave  
  8022b3:	c3                   	ret    

008022b4 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  8022b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8022b9:	c3                   	ret    

008022ba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022ba:	55                   	push   %ebp
  8022bb:	89 e5                	mov    %esp,%ebp
  8022bd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022c0:	68 73 2d 80 00       	push   $0x802d73
  8022c5:	ff 75 0c             	push   0xc(%ebp)
  8022c8:	e8 3f e6 ff ff       	call   80090c <strcpy>
	return 0;
}
  8022cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8022d2:	c9                   	leave  
  8022d3:	c3                   	ret    

008022d4 <devcons_write>:
{
  8022d4:	55                   	push   %ebp
  8022d5:	89 e5                	mov    %esp,%ebp
  8022d7:	57                   	push   %edi
  8022d8:	56                   	push   %esi
  8022d9:	53                   	push   %ebx
  8022da:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8022e0:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8022e5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8022eb:	eb 2e                	jmp    80231b <devcons_write+0x47>
		m = n - tot;
  8022ed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022f0:	29 f3                	sub    %esi,%ebx
  8022f2:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8022f7:	39 c3                	cmp    %eax,%ebx
  8022f9:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8022fc:	83 ec 04             	sub    $0x4,%esp
  8022ff:	53                   	push   %ebx
  802300:	89 f0                	mov    %esi,%eax
  802302:	03 45 0c             	add    0xc(%ebp),%eax
  802305:	50                   	push   %eax
  802306:	57                   	push   %edi
  802307:	e8 96 e7 ff ff       	call   800aa2 <memmove>
		sys_cputs(buf, m);
  80230c:	83 c4 08             	add    $0x8,%esp
  80230f:	53                   	push   %ebx
  802310:	57                   	push   %edi
  802311:	e8 36 e9 ff ff       	call   800c4c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802316:	01 de                	add    %ebx,%esi
  802318:	83 c4 10             	add    $0x10,%esp
  80231b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80231e:	72 cd                	jb     8022ed <devcons_write+0x19>
}
  802320:	89 f0                	mov    %esi,%eax
  802322:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802325:	5b                   	pop    %ebx
  802326:	5e                   	pop    %esi
  802327:	5f                   	pop    %edi
  802328:	5d                   	pop    %ebp
  802329:	c3                   	ret    

0080232a <devcons_read>:
{
  80232a:	55                   	push   %ebp
  80232b:	89 e5                	mov    %esp,%ebp
  80232d:	83 ec 08             	sub    $0x8,%esp
  802330:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802335:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802339:	75 07                	jne    802342 <devcons_read+0x18>
  80233b:	eb 1f                	jmp    80235c <devcons_read+0x32>
		sys_yield();
  80233d:	e8 a7 e9 ff ff       	call   800ce9 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802342:	e8 23 e9 ff ff       	call   800c6a <sys_cgetc>
  802347:	85 c0                	test   %eax,%eax
  802349:	74 f2                	je     80233d <devcons_read+0x13>
	if (c < 0)
  80234b:	78 0f                	js     80235c <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  80234d:	83 f8 04             	cmp    $0x4,%eax
  802350:	74 0c                	je     80235e <devcons_read+0x34>
	*(char*)vbuf = c;
  802352:	8b 55 0c             	mov    0xc(%ebp),%edx
  802355:	88 02                	mov    %al,(%edx)
	return 1;
  802357:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80235c:	c9                   	leave  
  80235d:	c3                   	ret    
		return 0;
  80235e:	b8 00 00 00 00       	mov    $0x0,%eax
  802363:	eb f7                	jmp    80235c <devcons_read+0x32>

00802365 <cputchar>:
{
  802365:	55                   	push   %ebp
  802366:	89 e5                	mov    %esp,%ebp
  802368:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80236b:	8b 45 08             	mov    0x8(%ebp),%eax
  80236e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802371:	6a 01                	push   $0x1
  802373:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802376:	50                   	push   %eax
  802377:	e8 d0 e8 ff ff       	call   800c4c <sys_cputs>
}
  80237c:	83 c4 10             	add    $0x10,%esp
  80237f:	c9                   	leave  
  802380:	c3                   	ret    

00802381 <getchar>:
{
  802381:	55                   	push   %ebp
  802382:	89 e5                	mov    %esp,%ebp
  802384:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802387:	6a 01                	push   $0x1
  802389:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80238c:	50                   	push   %eax
  80238d:	6a 00                	push   $0x0
  80238f:	e8 2a f2 ff ff       	call   8015be <read>
	if (r < 0)
  802394:	83 c4 10             	add    $0x10,%esp
  802397:	85 c0                	test   %eax,%eax
  802399:	78 06                	js     8023a1 <getchar+0x20>
	if (r < 1)
  80239b:	74 06                	je     8023a3 <getchar+0x22>
	return c;
  80239d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8023a1:	c9                   	leave  
  8023a2:	c3                   	ret    
		return -E_EOF;
  8023a3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8023a8:	eb f7                	jmp    8023a1 <getchar+0x20>

008023aa <iscons>:
{
  8023aa:	55                   	push   %ebp
  8023ab:	89 e5                	mov    %esp,%ebp
  8023ad:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023b3:	50                   	push   %eax
  8023b4:	ff 75 08             	push   0x8(%ebp)
  8023b7:	e8 99 ef ff ff       	call   801355 <fd_lookup>
  8023bc:	83 c4 10             	add    $0x10,%esp
  8023bf:	85 c0                	test   %eax,%eax
  8023c1:	78 11                	js     8023d4 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8023c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023c6:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8023cc:	39 10                	cmp    %edx,(%eax)
  8023ce:	0f 94 c0             	sete   %al
  8023d1:	0f b6 c0             	movzbl %al,%eax
}
  8023d4:	c9                   	leave  
  8023d5:	c3                   	ret    

008023d6 <opencons>:
{
  8023d6:	55                   	push   %ebp
  8023d7:	89 e5                	mov    %esp,%ebp
  8023d9:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8023dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023df:	50                   	push   %eax
  8023e0:	e8 20 ef ff ff       	call   801305 <fd_alloc>
  8023e5:	83 c4 10             	add    $0x10,%esp
  8023e8:	85 c0                	test   %eax,%eax
  8023ea:	78 3a                	js     802426 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023ec:	83 ec 04             	sub    $0x4,%esp
  8023ef:	68 07 04 00 00       	push   $0x407
  8023f4:	ff 75 f4             	push   -0xc(%ebp)
  8023f7:	6a 00                	push   $0x0
  8023f9:	e8 0a e9 ff ff       	call   800d08 <sys_page_alloc>
  8023fe:	83 c4 10             	add    $0x10,%esp
  802401:	85 c0                	test   %eax,%eax
  802403:	78 21                	js     802426 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  802405:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802408:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80240e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802410:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802413:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80241a:	83 ec 0c             	sub    $0xc,%esp
  80241d:	50                   	push   %eax
  80241e:	e8 bb ee ff ff       	call   8012de <fd2num>
  802423:	83 c4 10             	add    $0x10,%esp
}
  802426:	c9                   	leave  
  802427:	c3                   	ret    

00802428 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802428:	55                   	push   %ebp
  802429:	89 e5                	mov    %esp,%ebp
  80242b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  80242e:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  802435:	74 0a                	je     802441 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802437:	8b 45 08             	mov    0x8(%ebp),%eax
  80243a:	a3 04 80 80 00       	mov    %eax,0x808004
}
  80243f:	c9                   	leave  
  802440:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  802441:	e8 84 e8 ff ff       	call   800cca <sys_getenvid>
  802446:	83 ec 04             	sub    $0x4,%esp
  802449:	68 07 0e 00 00       	push   $0xe07
  80244e:	68 00 f0 bf ee       	push   $0xeebff000
  802453:	50                   	push   %eax
  802454:	e8 af e8 ff ff       	call   800d08 <sys_page_alloc>
		if (r < 0) {
  802459:	83 c4 10             	add    $0x10,%esp
  80245c:	85 c0                	test   %eax,%eax
  80245e:	78 2c                	js     80248c <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802460:	e8 65 e8 ff ff       	call   800cca <sys_getenvid>
  802465:	83 ec 08             	sub    $0x8,%esp
  802468:	68 9e 24 80 00       	push   $0x80249e
  80246d:	50                   	push   %eax
  80246e:	e8 e0 e9 ff ff       	call   800e53 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802473:	83 c4 10             	add    $0x10,%esp
  802476:	85 c0                	test   %eax,%eax
  802478:	79 bd                	jns    802437 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  80247a:	50                   	push   %eax
  80247b:	68 c0 2d 80 00       	push   $0x802dc0
  802480:	6a 28                	push   $0x28
  802482:	68 f6 2d 80 00       	push   $0x802df6
  802487:	e8 cb dd ff ff       	call   800257 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  80248c:	50                   	push   %eax
  80248d:	68 80 2d 80 00       	push   $0x802d80
  802492:	6a 23                	push   $0x23
  802494:	68 f6 2d 80 00       	push   $0x802df6
  802499:	e8 b9 dd ff ff       	call   800257 <_panic>

0080249e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80249e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80249f:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  8024a4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8024a6:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  8024a9:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  8024ad:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  8024b0:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  8024b4:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  8024b8:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  8024ba:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  8024bd:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  8024be:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  8024c1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  8024c2:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  8024c3:	c3                   	ret    
  8024c4:	66 90                	xchg   %ax,%ax
  8024c6:	66 90                	xchg   %ax,%ax
  8024c8:	66 90                	xchg   %ax,%ax
  8024ca:	66 90                	xchg   %ax,%ax
  8024cc:	66 90                	xchg   %ax,%ax
  8024ce:	66 90                	xchg   %ax,%ax

008024d0 <__udivdi3>:
  8024d0:	f3 0f 1e fb          	endbr32 
  8024d4:	55                   	push   %ebp
  8024d5:	57                   	push   %edi
  8024d6:	56                   	push   %esi
  8024d7:	53                   	push   %ebx
  8024d8:	83 ec 1c             	sub    $0x1c,%esp
  8024db:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8024df:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8024e3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8024e7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8024eb:	85 c0                	test   %eax,%eax
  8024ed:	75 19                	jne    802508 <__udivdi3+0x38>
  8024ef:	39 f3                	cmp    %esi,%ebx
  8024f1:	76 4d                	jbe    802540 <__udivdi3+0x70>
  8024f3:	31 ff                	xor    %edi,%edi
  8024f5:	89 e8                	mov    %ebp,%eax
  8024f7:	89 f2                	mov    %esi,%edx
  8024f9:	f7 f3                	div    %ebx
  8024fb:	89 fa                	mov    %edi,%edx
  8024fd:	83 c4 1c             	add    $0x1c,%esp
  802500:	5b                   	pop    %ebx
  802501:	5e                   	pop    %esi
  802502:	5f                   	pop    %edi
  802503:	5d                   	pop    %ebp
  802504:	c3                   	ret    
  802505:	8d 76 00             	lea    0x0(%esi),%esi
  802508:	39 f0                	cmp    %esi,%eax
  80250a:	76 14                	jbe    802520 <__udivdi3+0x50>
  80250c:	31 ff                	xor    %edi,%edi
  80250e:	31 c0                	xor    %eax,%eax
  802510:	89 fa                	mov    %edi,%edx
  802512:	83 c4 1c             	add    $0x1c,%esp
  802515:	5b                   	pop    %ebx
  802516:	5e                   	pop    %esi
  802517:	5f                   	pop    %edi
  802518:	5d                   	pop    %ebp
  802519:	c3                   	ret    
  80251a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802520:	0f bd f8             	bsr    %eax,%edi
  802523:	83 f7 1f             	xor    $0x1f,%edi
  802526:	75 48                	jne    802570 <__udivdi3+0xa0>
  802528:	39 f0                	cmp    %esi,%eax
  80252a:	72 06                	jb     802532 <__udivdi3+0x62>
  80252c:	31 c0                	xor    %eax,%eax
  80252e:	39 eb                	cmp    %ebp,%ebx
  802530:	77 de                	ja     802510 <__udivdi3+0x40>
  802532:	b8 01 00 00 00       	mov    $0x1,%eax
  802537:	eb d7                	jmp    802510 <__udivdi3+0x40>
  802539:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802540:	89 d9                	mov    %ebx,%ecx
  802542:	85 db                	test   %ebx,%ebx
  802544:	75 0b                	jne    802551 <__udivdi3+0x81>
  802546:	b8 01 00 00 00       	mov    $0x1,%eax
  80254b:	31 d2                	xor    %edx,%edx
  80254d:	f7 f3                	div    %ebx
  80254f:	89 c1                	mov    %eax,%ecx
  802551:	31 d2                	xor    %edx,%edx
  802553:	89 f0                	mov    %esi,%eax
  802555:	f7 f1                	div    %ecx
  802557:	89 c6                	mov    %eax,%esi
  802559:	89 e8                	mov    %ebp,%eax
  80255b:	89 f7                	mov    %esi,%edi
  80255d:	f7 f1                	div    %ecx
  80255f:	89 fa                	mov    %edi,%edx
  802561:	83 c4 1c             	add    $0x1c,%esp
  802564:	5b                   	pop    %ebx
  802565:	5e                   	pop    %esi
  802566:	5f                   	pop    %edi
  802567:	5d                   	pop    %ebp
  802568:	c3                   	ret    
  802569:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802570:	89 f9                	mov    %edi,%ecx
  802572:	ba 20 00 00 00       	mov    $0x20,%edx
  802577:	29 fa                	sub    %edi,%edx
  802579:	d3 e0                	shl    %cl,%eax
  80257b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80257f:	89 d1                	mov    %edx,%ecx
  802581:	89 d8                	mov    %ebx,%eax
  802583:	d3 e8                	shr    %cl,%eax
  802585:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802589:	09 c1                	or     %eax,%ecx
  80258b:	89 f0                	mov    %esi,%eax
  80258d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802591:	89 f9                	mov    %edi,%ecx
  802593:	d3 e3                	shl    %cl,%ebx
  802595:	89 d1                	mov    %edx,%ecx
  802597:	d3 e8                	shr    %cl,%eax
  802599:	89 f9                	mov    %edi,%ecx
  80259b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80259f:	89 eb                	mov    %ebp,%ebx
  8025a1:	d3 e6                	shl    %cl,%esi
  8025a3:	89 d1                	mov    %edx,%ecx
  8025a5:	d3 eb                	shr    %cl,%ebx
  8025a7:	09 f3                	or     %esi,%ebx
  8025a9:	89 c6                	mov    %eax,%esi
  8025ab:	89 f2                	mov    %esi,%edx
  8025ad:	89 d8                	mov    %ebx,%eax
  8025af:	f7 74 24 08          	divl   0x8(%esp)
  8025b3:	89 d6                	mov    %edx,%esi
  8025b5:	89 c3                	mov    %eax,%ebx
  8025b7:	f7 64 24 0c          	mull   0xc(%esp)
  8025bb:	39 d6                	cmp    %edx,%esi
  8025bd:	72 19                	jb     8025d8 <__udivdi3+0x108>
  8025bf:	89 f9                	mov    %edi,%ecx
  8025c1:	d3 e5                	shl    %cl,%ebp
  8025c3:	39 c5                	cmp    %eax,%ebp
  8025c5:	73 04                	jae    8025cb <__udivdi3+0xfb>
  8025c7:	39 d6                	cmp    %edx,%esi
  8025c9:	74 0d                	je     8025d8 <__udivdi3+0x108>
  8025cb:	89 d8                	mov    %ebx,%eax
  8025cd:	31 ff                	xor    %edi,%edi
  8025cf:	e9 3c ff ff ff       	jmp    802510 <__udivdi3+0x40>
  8025d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025d8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8025db:	31 ff                	xor    %edi,%edi
  8025dd:	e9 2e ff ff ff       	jmp    802510 <__udivdi3+0x40>
  8025e2:	66 90                	xchg   %ax,%ax
  8025e4:	66 90                	xchg   %ax,%ax
  8025e6:	66 90                	xchg   %ax,%ax
  8025e8:	66 90                	xchg   %ax,%ax
  8025ea:	66 90                	xchg   %ax,%ax
  8025ec:	66 90                	xchg   %ax,%ax
  8025ee:	66 90                	xchg   %ax,%ax

008025f0 <__umoddi3>:
  8025f0:	f3 0f 1e fb          	endbr32 
  8025f4:	55                   	push   %ebp
  8025f5:	57                   	push   %edi
  8025f6:	56                   	push   %esi
  8025f7:	53                   	push   %ebx
  8025f8:	83 ec 1c             	sub    $0x1c,%esp
  8025fb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8025ff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802603:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802607:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80260b:	89 f0                	mov    %esi,%eax
  80260d:	89 da                	mov    %ebx,%edx
  80260f:	85 ff                	test   %edi,%edi
  802611:	75 15                	jne    802628 <__umoddi3+0x38>
  802613:	39 dd                	cmp    %ebx,%ebp
  802615:	76 39                	jbe    802650 <__umoddi3+0x60>
  802617:	f7 f5                	div    %ebp
  802619:	89 d0                	mov    %edx,%eax
  80261b:	31 d2                	xor    %edx,%edx
  80261d:	83 c4 1c             	add    $0x1c,%esp
  802620:	5b                   	pop    %ebx
  802621:	5e                   	pop    %esi
  802622:	5f                   	pop    %edi
  802623:	5d                   	pop    %ebp
  802624:	c3                   	ret    
  802625:	8d 76 00             	lea    0x0(%esi),%esi
  802628:	39 df                	cmp    %ebx,%edi
  80262a:	77 f1                	ja     80261d <__umoddi3+0x2d>
  80262c:	0f bd cf             	bsr    %edi,%ecx
  80262f:	83 f1 1f             	xor    $0x1f,%ecx
  802632:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802636:	75 40                	jne    802678 <__umoddi3+0x88>
  802638:	39 df                	cmp    %ebx,%edi
  80263a:	72 04                	jb     802640 <__umoddi3+0x50>
  80263c:	39 f5                	cmp    %esi,%ebp
  80263e:	77 dd                	ja     80261d <__umoddi3+0x2d>
  802640:	89 da                	mov    %ebx,%edx
  802642:	89 f0                	mov    %esi,%eax
  802644:	29 e8                	sub    %ebp,%eax
  802646:	19 fa                	sbb    %edi,%edx
  802648:	eb d3                	jmp    80261d <__umoddi3+0x2d>
  80264a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802650:	89 e9                	mov    %ebp,%ecx
  802652:	85 ed                	test   %ebp,%ebp
  802654:	75 0b                	jne    802661 <__umoddi3+0x71>
  802656:	b8 01 00 00 00       	mov    $0x1,%eax
  80265b:	31 d2                	xor    %edx,%edx
  80265d:	f7 f5                	div    %ebp
  80265f:	89 c1                	mov    %eax,%ecx
  802661:	89 d8                	mov    %ebx,%eax
  802663:	31 d2                	xor    %edx,%edx
  802665:	f7 f1                	div    %ecx
  802667:	89 f0                	mov    %esi,%eax
  802669:	f7 f1                	div    %ecx
  80266b:	89 d0                	mov    %edx,%eax
  80266d:	31 d2                	xor    %edx,%edx
  80266f:	eb ac                	jmp    80261d <__umoddi3+0x2d>
  802671:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802678:	8b 44 24 04          	mov    0x4(%esp),%eax
  80267c:	ba 20 00 00 00       	mov    $0x20,%edx
  802681:	29 c2                	sub    %eax,%edx
  802683:	89 c1                	mov    %eax,%ecx
  802685:	89 e8                	mov    %ebp,%eax
  802687:	d3 e7                	shl    %cl,%edi
  802689:	89 d1                	mov    %edx,%ecx
  80268b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80268f:	d3 e8                	shr    %cl,%eax
  802691:	89 c1                	mov    %eax,%ecx
  802693:	8b 44 24 04          	mov    0x4(%esp),%eax
  802697:	09 f9                	or     %edi,%ecx
  802699:	89 df                	mov    %ebx,%edi
  80269b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80269f:	89 c1                	mov    %eax,%ecx
  8026a1:	d3 e5                	shl    %cl,%ebp
  8026a3:	89 d1                	mov    %edx,%ecx
  8026a5:	d3 ef                	shr    %cl,%edi
  8026a7:	89 c1                	mov    %eax,%ecx
  8026a9:	89 f0                	mov    %esi,%eax
  8026ab:	d3 e3                	shl    %cl,%ebx
  8026ad:	89 d1                	mov    %edx,%ecx
  8026af:	89 fa                	mov    %edi,%edx
  8026b1:	d3 e8                	shr    %cl,%eax
  8026b3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8026b8:	09 d8                	or     %ebx,%eax
  8026ba:	f7 74 24 08          	divl   0x8(%esp)
  8026be:	89 d3                	mov    %edx,%ebx
  8026c0:	d3 e6                	shl    %cl,%esi
  8026c2:	f7 e5                	mul    %ebp
  8026c4:	89 c7                	mov    %eax,%edi
  8026c6:	89 d1                	mov    %edx,%ecx
  8026c8:	39 d3                	cmp    %edx,%ebx
  8026ca:	72 06                	jb     8026d2 <__umoddi3+0xe2>
  8026cc:	75 0e                	jne    8026dc <__umoddi3+0xec>
  8026ce:	39 c6                	cmp    %eax,%esi
  8026d0:	73 0a                	jae    8026dc <__umoddi3+0xec>
  8026d2:	29 e8                	sub    %ebp,%eax
  8026d4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8026d8:	89 d1                	mov    %edx,%ecx
  8026da:	89 c7                	mov    %eax,%edi
  8026dc:	89 f5                	mov    %esi,%ebp
  8026de:	8b 74 24 04          	mov    0x4(%esp),%esi
  8026e2:	29 fd                	sub    %edi,%ebp
  8026e4:	19 cb                	sbb    %ecx,%ebx
  8026e6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8026eb:	89 d8                	mov    %ebx,%eax
  8026ed:	d3 e0                	shl    %cl,%eax
  8026ef:	89 f1                	mov    %esi,%ecx
  8026f1:	d3 ed                	shr    %cl,%ebp
  8026f3:	d3 eb                	shr    %cl,%ebx
  8026f5:	09 e8                	or     %ebp,%eax
  8026f7:	89 da                	mov    %ebx,%edx
  8026f9:	83 c4 1c             	add    $0x1c,%esp
  8026fc:	5b                   	pop    %ebx
  8026fd:	5e                   	pop    %esi
  8026fe:	5f                   	pop    %edi
  8026ff:	5d                   	pop    %ebp
  802700:	c3                   	ret    
