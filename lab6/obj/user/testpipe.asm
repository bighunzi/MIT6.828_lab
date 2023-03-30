
obj/user/testpipe.debug：     文件格式 elf32-i386


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
  80002c:	e8 a1 02 00 00       	call   8002d2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 30 80 00 20 	movl   $0x802820,0x803004
  800042:	28 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 82 20 00 00       	call   8020d0 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	0f 88 1b 01 00 00    	js     800176 <umain+0x143>
		panic("pipe: %e", i);

	if ((pid = fork()) < 0)
  80005b:	e8 d3 10 00 00       	call   801133 <fork>
  800060:	89 c3                	mov    %eax,%ebx
  800062:	85 c0                	test   %eax,%eax
  800064:	0f 88 1e 01 00 00    	js     800188 <umain+0x155>
		panic("fork: %e", i);

	if (pid == 0) {
  80006a:	0f 85 56 01 00 00    	jne    8001c6 <umain+0x193>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  800070:	a1 00 40 80 00       	mov    0x804000,%eax
  800075:	8b 40 48             	mov    0x48(%eax),%eax
  800078:	83 ec 04             	sub    $0x4,%esp
  80007b:	ff 75 90             	push   -0x70(%ebp)
  80007e:	50                   	push   %eax
  80007f:	68 45 28 80 00       	push   $0x802845
  800084:	e8 84 03 00 00       	call   80040d <cprintf>
		close(p[1]);
  800089:	83 c4 04             	add    $0x4,%esp
  80008c:	ff 75 90             	push   -0x70(%ebp)
  80008f:	e8 c3 13 00 00       	call   801457 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  800094:	a1 00 40 80 00       	mov    0x804000,%eax
  800099:	8b 40 48             	mov    0x48(%eax),%eax
  80009c:	83 c4 0c             	add    $0xc,%esp
  80009f:	ff 75 8c             	push   -0x74(%ebp)
  8000a2:	50                   	push   %eax
  8000a3:	68 62 28 80 00       	push   $0x802862
  8000a8:	e8 60 03 00 00       	call   80040d <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000ad:	83 c4 0c             	add    $0xc,%esp
  8000b0:	6a 63                	push   $0x63
  8000b2:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000b5:	50                   	push   %eax
  8000b6:	ff 75 8c             	push   -0x74(%ebp)
  8000b9:	e8 5c 15 00 00       	call   80161a <readn>
  8000be:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	85 c0                	test   %eax,%eax
  8000c5:	0f 88 cf 00 00 00    	js     80019a <umain+0x167>
			panic("read: %e", i);
		buf[i] = 0;
  8000cb:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000d0:	83 ec 08             	sub    $0x8,%esp
  8000d3:	ff 35 00 30 80 00    	push   0x803000
  8000d9:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000dc:	50                   	push   %eax
  8000dd:	e8 b6 09 00 00       	call   800a98 <strcmp>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	85 c0                	test   %eax,%eax
  8000e7:	0f 85 bf 00 00 00    	jne    8001ac <umain+0x179>
			cprintf("\npipe read closed properly\n");
  8000ed:	83 ec 0c             	sub    $0xc,%esp
  8000f0:	68 88 28 80 00       	push   $0x802888
  8000f5:	e8 13 03 00 00       	call   80040d <cprintf>
  8000fa:	83 c4 10             	add    $0x10,%esp
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
		exit();
  8000fd:	e8 16 02 00 00       	call   800318 <exit>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
			panic("write: %e", i);
		close(p[1]);
	}
	wait(pid);
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	53                   	push   %ebx
  800106:	e8 42 21 00 00       	call   80224d <wait>

	binaryname = "pipewriteeof";
  80010b:	c7 05 04 30 80 00 de 	movl   $0x8028de,0x803004
  800112:	28 80 00 
	if ((i = pipe(p)) < 0)
  800115:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800118:	89 04 24             	mov    %eax,(%esp)
  80011b:	e8 b0 1f 00 00       	call   8020d0 <pipe>
  800120:	89 c6                	mov    %eax,%esi
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	0f 88 32 01 00 00    	js     80025f <umain+0x22c>
		panic("pipe: %e", i);

	if ((pid = fork()) < 0)
  80012d:	e8 01 10 00 00       	call   801133 <fork>
  800132:	89 c3                	mov    %eax,%ebx
  800134:	85 c0                	test   %eax,%eax
  800136:	0f 88 35 01 00 00    	js     800271 <umain+0x23e>
		panic("fork: %e", i);

	if (pid == 0) {
  80013c:	0f 84 41 01 00 00    	je     800283 <umain+0x250>
				break;
		}
		cprintf("\npipe write closed properly\n");
		exit();
	}
	close(p[0]);
  800142:	83 ec 0c             	sub    $0xc,%esp
  800145:	ff 75 8c             	push   -0x74(%ebp)
  800148:	e8 0a 13 00 00       	call   801457 <close>
	close(p[1]);
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 90             	push   -0x70(%ebp)
  800153:	e8 ff 12 00 00       	call   801457 <close>
	wait(pid);
  800158:	89 1c 24             	mov    %ebx,(%esp)
  80015b:	e8 ed 20 00 00       	call   80224d <wait>

	cprintf("pipe tests passed\n");
  800160:	c7 04 24 0c 29 80 00 	movl   $0x80290c,(%esp)
  800167:	e8 a1 02 00 00       	call   80040d <cprintf>
}
  80016c:	83 c4 10             	add    $0x10,%esp
  80016f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800172:	5b                   	pop    %ebx
  800173:	5e                   	pop    %esi
  800174:	5d                   	pop    %ebp
  800175:	c3                   	ret    
		panic("pipe: %e", i);
  800176:	50                   	push   %eax
  800177:	68 2c 28 80 00       	push   $0x80282c
  80017c:	6a 0e                	push   $0xe
  80017e:	68 35 28 80 00       	push   $0x802835
  800183:	e8 aa 01 00 00       	call   800332 <_panic>
		panic("fork: %e", i);
  800188:	56                   	push   %esi
  800189:	68 78 2d 80 00       	push   $0x802d78
  80018e:	6a 11                	push   $0x11
  800190:	68 35 28 80 00       	push   $0x802835
  800195:	e8 98 01 00 00       	call   800332 <_panic>
			panic("read: %e", i);
  80019a:	50                   	push   %eax
  80019b:	68 7f 28 80 00       	push   $0x80287f
  8001a0:	6a 19                	push   $0x19
  8001a2:	68 35 28 80 00       	push   $0x802835
  8001a7:	e8 86 01 00 00       	call   800332 <_panic>
			cprintf("\ngot %d bytes: %s\n", i, buf);
  8001ac:	83 ec 04             	sub    $0x4,%esp
  8001af:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8001b2:	50                   	push   %eax
  8001b3:	56                   	push   %esi
  8001b4:	68 a4 28 80 00       	push   $0x8028a4
  8001b9:	e8 4f 02 00 00       	call   80040d <cprintf>
  8001be:	83 c4 10             	add    $0x10,%esp
  8001c1:	e9 37 ff ff ff       	jmp    8000fd <umain+0xca>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  8001c6:	a1 00 40 80 00       	mov    0x804000,%eax
  8001cb:	8b 40 48             	mov    0x48(%eax),%eax
  8001ce:	83 ec 04             	sub    $0x4,%esp
  8001d1:	ff 75 8c             	push   -0x74(%ebp)
  8001d4:	50                   	push   %eax
  8001d5:	68 45 28 80 00       	push   $0x802845
  8001da:	e8 2e 02 00 00       	call   80040d <cprintf>
		close(p[0]);
  8001df:	83 c4 04             	add    $0x4,%esp
  8001e2:	ff 75 8c             	push   -0x74(%ebp)
  8001e5:	e8 6d 12 00 00       	call   801457 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  8001ea:	a1 00 40 80 00       	mov    0x804000,%eax
  8001ef:	8b 40 48             	mov    0x48(%eax),%eax
  8001f2:	83 c4 0c             	add    $0xc,%esp
  8001f5:	ff 75 90             	push   -0x70(%ebp)
  8001f8:	50                   	push   %eax
  8001f9:	68 b7 28 80 00       	push   $0x8028b7
  8001fe:	e8 0a 02 00 00       	call   80040d <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800203:	83 c4 04             	add    $0x4,%esp
  800206:	ff 35 00 30 80 00    	push   0x803000
  80020c:	e8 9b 07 00 00       	call   8009ac <strlen>
  800211:	83 c4 0c             	add    $0xc,%esp
  800214:	50                   	push   %eax
  800215:	ff 35 00 30 80 00    	push   0x803000
  80021b:	ff 75 90             	push   -0x70(%ebp)
  80021e:	e8 3e 14 00 00       	call   801661 <write>
  800223:	89 c6                	mov    %eax,%esi
  800225:	83 c4 04             	add    $0x4,%esp
  800228:	ff 35 00 30 80 00    	push   0x803000
  80022e:	e8 79 07 00 00       	call   8009ac <strlen>
  800233:	83 c4 10             	add    $0x10,%esp
  800236:	39 f0                	cmp    %esi,%eax
  800238:	75 13                	jne    80024d <umain+0x21a>
		close(p[1]);
  80023a:	83 ec 0c             	sub    $0xc,%esp
  80023d:	ff 75 90             	push   -0x70(%ebp)
  800240:	e8 12 12 00 00       	call   801457 <close>
  800245:	83 c4 10             	add    $0x10,%esp
  800248:	e9 b5 fe ff ff       	jmp    800102 <umain+0xcf>
			panic("write: %e", i);
  80024d:	56                   	push   %esi
  80024e:	68 d4 28 80 00       	push   $0x8028d4
  800253:	6a 25                	push   $0x25
  800255:	68 35 28 80 00       	push   $0x802835
  80025a:	e8 d3 00 00 00       	call   800332 <_panic>
		panic("pipe: %e", i);
  80025f:	50                   	push   %eax
  800260:	68 2c 28 80 00       	push   $0x80282c
  800265:	6a 2c                	push   $0x2c
  800267:	68 35 28 80 00       	push   $0x802835
  80026c:	e8 c1 00 00 00       	call   800332 <_panic>
		panic("fork: %e", i);
  800271:	56                   	push   %esi
  800272:	68 78 2d 80 00       	push   $0x802d78
  800277:	6a 2f                	push   $0x2f
  800279:	68 35 28 80 00       	push   $0x802835
  80027e:	e8 af 00 00 00       	call   800332 <_panic>
		close(p[0]);
  800283:	83 ec 0c             	sub    $0xc,%esp
  800286:	ff 75 8c             	push   -0x74(%ebp)
  800289:	e8 c9 11 00 00       	call   801457 <close>
  80028e:	83 c4 10             	add    $0x10,%esp
			cprintf(".");
  800291:	83 ec 0c             	sub    $0xc,%esp
  800294:	68 eb 28 80 00       	push   $0x8028eb
  800299:	e8 6f 01 00 00       	call   80040d <cprintf>
			if (write(p[1], "x", 1) != 1)
  80029e:	83 c4 0c             	add    $0xc,%esp
  8002a1:	6a 01                	push   $0x1
  8002a3:	68 ed 28 80 00       	push   $0x8028ed
  8002a8:	ff 75 90             	push   -0x70(%ebp)
  8002ab:	e8 b1 13 00 00       	call   801661 <write>
  8002b0:	83 c4 10             	add    $0x10,%esp
  8002b3:	83 f8 01             	cmp    $0x1,%eax
  8002b6:	74 d9                	je     800291 <umain+0x25e>
		cprintf("\npipe write closed properly\n");
  8002b8:	83 ec 0c             	sub    $0xc,%esp
  8002bb:	68 ef 28 80 00       	push   $0x8028ef
  8002c0:	e8 48 01 00 00       	call   80040d <cprintf>
		exit();
  8002c5:	e8 4e 00 00 00       	call   800318 <exit>
  8002ca:	83 c4 10             	add    $0x10,%esp
  8002cd:	e9 70 fe ff ff       	jmp    800142 <umain+0x10f>

008002d2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	56                   	push   %esi
  8002d6:	53                   	push   %ebx
  8002d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002da:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8002dd:	e8 c3 0a 00 00       	call   800da5 <sys_getenvid>
  8002e2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002e7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002ea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002ef:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002f4:	85 db                	test   %ebx,%ebx
  8002f6:	7e 07                	jle    8002ff <libmain+0x2d>
		binaryname = argv[0];
  8002f8:	8b 06                	mov    (%esi),%eax
  8002fa:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	53                   	push   %ebx
  800304:	e8 2a fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800309:	e8 0a 00 00 00       	call   800318 <exit>
}
  80030e:	83 c4 10             	add    $0x10,%esp
  800311:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800314:	5b                   	pop    %ebx
  800315:	5e                   	pop    %esi
  800316:	5d                   	pop    %ebp
  800317:	c3                   	ret    

00800318 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800318:	55                   	push   %ebp
  800319:	89 e5                	mov    %esp,%ebp
  80031b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80031e:	e8 61 11 00 00       	call   801484 <close_all>
	sys_env_destroy(0);
  800323:	83 ec 0c             	sub    $0xc,%esp
  800326:	6a 00                	push   $0x0
  800328:	e8 37 0a 00 00       	call   800d64 <sys_env_destroy>
}
  80032d:	83 c4 10             	add    $0x10,%esp
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800337:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80033a:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800340:	e8 60 0a 00 00       	call   800da5 <sys_getenvid>
  800345:	83 ec 0c             	sub    $0xc,%esp
  800348:	ff 75 0c             	push   0xc(%ebp)
  80034b:	ff 75 08             	push   0x8(%ebp)
  80034e:	56                   	push   %esi
  80034f:	50                   	push   %eax
  800350:	68 70 29 80 00       	push   $0x802970
  800355:	e8 b3 00 00 00       	call   80040d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80035a:	83 c4 18             	add    $0x18,%esp
  80035d:	53                   	push   %ebx
  80035e:	ff 75 10             	push   0x10(%ebp)
  800361:	e8 56 00 00 00       	call   8003bc <vcprintf>
	cprintf("\n");
  800366:	c7 04 24 60 28 80 00 	movl   $0x802860,(%esp)
  80036d:	e8 9b 00 00 00       	call   80040d <cprintf>
  800372:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800375:	cc                   	int3   
  800376:	eb fd                	jmp    800375 <_panic+0x43>

00800378 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800378:	55                   	push   %ebp
  800379:	89 e5                	mov    %esp,%ebp
  80037b:	53                   	push   %ebx
  80037c:	83 ec 04             	sub    $0x4,%esp
  80037f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800382:	8b 13                	mov    (%ebx),%edx
  800384:	8d 42 01             	lea    0x1(%edx),%eax
  800387:	89 03                	mov    %eax,(%ebx)
  800389:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80038c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800390:	3d ff 00 00 00       	cmp    $0xff,%eax
  800395:	74 09                	je     8003a0 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800397:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80039b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80039e:	c9                   	leave  
  80039f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003a0:	83 ec 08             	sub    $0x8,%esp
  8003a3:	68 ff 00 00 00       	push   $0xff
  8003a8:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ab:	50                   	push   %eax
  8003ac:	e8 76 09 00 00       	call   800d27 <sys_cputs>
		b->idx = 0;
  8003b1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003b7:	83 c4 10             	add    $0x10,%esp
  8003ba:	eb db                	jmp    800397 <putch+0x1f>

008003bc <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
  8003bf:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003c5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003cc:	00 00 00 
	b.cnt = 0;
  8003cf:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003d6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003d9:	ff 75 0c             	push   0xc(%ebp)
  8003dc:	ff 75 08             	push   0x8(%ebp)
  8003df:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003e5:	50                   	push   %eax
  8003e6:	68 78 03 80 00       	push   $0x800378
  8003eb:	e8 14 01 00 00       	call   800504 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f0:	83 c4 08             	add    $0x8,%esp
  8003f3:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8003f9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ff:	50                   	push   %eax
  800400:	e8 22 09 00 00       	call   800d27 <sys_cputs>

	return b.cnt;
}
  800405:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80040b:	c9                   	leave  
  80040c:	c3                   	ret    

0080040d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80040d:	55                   	push   %ebp
  80040e:	89 e5                	mov    %esp,%ebp
  800410:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800413:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800416:	50                   	push   %eax
  800417:	ff 75 08             	push   0x8(%ebp)
  80041a:	e8 9d ff ff ff       	call   8003bc <vcprintf>
	va_end(ap);

	return cnt;
}
  80041f:	c9                   	leave  
  800420:	c3                   	ret    

00800421 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800421:	55                   	push   %ebp
  800422:	89 e5                	mov    %esp,%ebp
  800424:	57                   	push   %edi
  800425:	56                   	push   %esi
  800426:	53                   	push   %ebx
  800427:	83 ec 1c             	sub    $0x1c,%esp
  80042a:	89 c7                	mov    %eax,%edi
  80042c:	89 d6                	mov    %edx,%esi
  80042e:	8b 45 08             	mov    0x8(%ebp),%eax
  800431:	8b 55 0c             	mov    0xc(%ebp),%edx
  800434:	89 d1                	mov    %edx,%ecx
  800436:	89 c2                	mov    %eax,%edx
  800438:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80043b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80043e:	8b 45 10             	mov    0x10(%ebp),%eax
  800441:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800444:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800447:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80044e:	39 c2                	cmp    %eax,%edx
  800450:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800453:	72 3e                	jb     800493 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800455:	83 ec 0c             	sub    $0xc,%esp
  800458:	ff 75 18             	push   0x18(%ebp)
  80045b:	83 eb 01             	sub    $0x1,%ebx
  80045e:	53                   	push   %ebx
  80045f:	50                   	push   %eax
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	ff 75 e4             	push   -0x1c(%ebp)
  800466:	ff 75 e0             	push   -0x20(%ebp)
  800469:	ff 75 dc             	push   -0x24(%ebp)
  80046c:	ff 75 d8             	push   -0x28(%ebp)
  80046f:	e8 6c 21 00 00       	call   8025e0 <__udivdi3>
  800474:	83 c4 18             	add    $0x18,%esp
  800477:	52                   	push   %edx
  800478:	50                   	push   %eax
  800479:	89 f2                	mov    %esi,%edx
  80047b:	89 f8                	mov    %edi,%eax
  80047d:	e8 9f ff ff ff       	call   800421 <printnum>
  800482:	83 c4 20             	add    $0x20,%esp
  800485:	eb 13                	jmp    80049a <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800487:	83 ec 08             	sub    $0x8,%esp
  80048a:	56                   	push   %esi
  80048b:	ff 75 18             	push   0x18(%ebp)
  80048e:	ff d7                	call   *%edi
  800490:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800493:	83 eb 01             	sub    $0x1,%ebx
  800496:	85 db                	test   %ebx,%ebx
  800498:	7f ed                	jg     800487 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80049a:	83 ec 08             	sub    $0x8,%esp
  80049d:	56                   	push   %esi
  80049e:	83 ec 04             	sub    $0x4,%esp
  8004a1:	ff 75 e4             	push   -0x1c(%ebp)
  8004a4:	ff 75 e0             	push   -0x20(%ebp)
  8004a7:	ff 75 dc             	push   -0x24(%ebp)
  8004aa:	ff 75 d8             	push   -0x28(%ebp)
  8004ad:	e8 4e 22 00 00       	call   802700 <__umoddi3>
  8004b2:	83 c4 14             	add    $0x14,%esp
  8004b5:	0f be 80 93 29 80 00 	movsbl 0x802993(%eax),%eax
  8004bc:	50                   	push   %eax
  8004bd:	ff d7                	call   *%edi
}
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004c5:	5b                   	pop    %ebx
  8004c6:	5e                   	pop    %esi
  8004c7:	5f                   	pop    %edi
  8004c8:	5d                   	pop    %ebp
  8004c9:	c3                   	ret    

008004ca <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d0:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004d4:	8b 10                	mov    (%eax),%edx
  8004d6:	3b 50 04             	cmp    0x4(%eax),%edx
  8004d9:	73 0a                	jae    8004e5 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004db:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004de:	89 08                	mov    %ecx,(%eax)
  8004e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e3:	88 02                	mov    %al,(%edx)
}
  8004e5:	5d                   	pop    %ebp
  8004e6:	c3                   	ret    

008004e7 <printfmt>:
{
  8004e7:	55                   	push   %ebp
  8004e8:	89 e5                	mov    %esp,%ebp
  8004ea:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004ed:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f0:	50                   	push   %eax
  8004f1:	ff 75 10             	push   0x10(%ebp)
  8004f4:	ff 75 0c             	push   0xc(%ebp)
  8004f7:	ff 75 08             	push   0x8(%ebp)
  8004fa:	e8 05 00 00 00       	call   800504 <vprintfmt>
}
  8004ff:	83 c4 10             	add    $0x10,%esp
  800502:	c9                   	leave  
  800503:	c3                   	ret    

00800504 <vprintfmt>:
{
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
  800507:	57                   	push   %edi
  800508:	56                   	push   %esi
  800509:	53                   	push   %ebx
  80050a:	83 ec 3c             	sub    $0x3c,%esp
  80050d:	8b 75 08             	mov    0x8(%ebp),%esi
  800510:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800513:	8b 7d 10             	mov    0x10(%ebp),%edi
  800516:	eb 0a                	jmp    800522 <vprintfmt+0x1e>
			putch(ch, putdat);
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	53                   	push   %ebx
  80051c:	50                   	push   %eax
  80051d:	ff d6                	call   *%esi
  80051f:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800522:	83 c7 01             	add    $0x1,%edi
  800525:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800529:	83 f8 25             	cmp    $0x25,%eax
  80052c:	74 0c                	je     80053a <vprintfmt+0x36>
			if (ch == '\0')
  80052e:	85 c0                	test   %eax,%eax
  800530:	75 e6                	jne    800518 <vprintfmt+0x14>
}
  800532:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800535:	5b                   	pop    %ebx
  800536:	5e                   	pop    %esi
  800537:	5f                   	pop    %edi
  800538:	5d                   	pop    %ebp
  800539:	c3                   	ret    
		padc = ' ';
  80053a:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80053e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800545:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80054c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800553:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800558:	8d 47 01             	lea    0x1(%edi),%eax
  80055b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80055e:	0f b6 17             	movzbl (%edi),%edx
  800561:	8d 42 dd             	lea    -0x23(%edx),%eax
  800564:	3c 55                	cmp    $0x55,%al
  800566:	0f 87 bb 03 00 00    	ja     800927 <vprintfmt+0x423>
  80056c:	0f b6 c0             	movzbl %al,%eax
  80056f:	ff 24 85 e0 2a 80 00 	jmp    *0x802ae0(,%eax,4)
  800576:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800579:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80057d:	eb d9                	jmp    800558 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80057f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800582:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800586:	eb d0                	jmp    800558 <vprintfmt+0x54>
  800588:	0f b6 d2             	movzbl %dl,%edx
  80058b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80058e:	b8 00 00 00 00       	mov    $0x0,%eax
  800593:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800596:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800599:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80059d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005a0:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005a3:	83 f9 09             	cmp    $0x9,%ecx
  8005a6:	77 55                	ja     8005fd <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8005a8:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005ab:	eb e9                	jmp    800596 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8005ad:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b0:	8b 00                	mov    (%eax),%eax
  8005b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b8:	8d 40 04             	lea    0x4(%eax),%eax
  8005bb:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005c1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c5:	79 91                	jns    800558 <vprintfmt+0x54>
				width = precision, precision = -1;
  8005c7:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005cd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005d4:	eb 82                	jmp    800558 <vprintfmt+0x54>
  8005d6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005d9:	85 d2                	test   %edx,%edx
  8005db:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e0:	0f 49 c2             	cmovns %edx,%eax
  8005e3:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005e6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005e9:	e9 6a ff ff ff       	jmp    800558 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005f1:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005f8:	e9 5b ff ff ff       	jmp    800558 <vprintfmt+0x54>
  8005fd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800600:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800603:	eb bc                	jmp    8005c1 <vprintfmt+0xbd>
			lflag++;
  800605:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800608:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80060b:	e9 48 ff ff ff       	jmp    800558 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 78 04             	lea    0x4(%eax),%edi
  800616:	83 ec 08             	sub    $0x8,%esp
  800619:	53                   	push   %ebx
  80061a:	ff 30                	push   (%eax)
  80061c:	ff d6                	call   *%esi
			break;
  80061e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800621:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800624:	e9 9d 02 00 00       	jmp    8008c6 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800629:	8b 45 14             	mov    0x14(%ebp),%eax
  80062c:	8d 78 04             	lea    0x4(%eax),%edi
  80062f:	8b 10                	mov    (%eax),%edx
  800631:	89 d0                	mov    %edx,%eax
  800633:	f7 d8                	neg    %eax
  800635:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800638:	83 f8 0f             	cmp    $0xf,%eax
  80063b:	7f 23                	jg     800660 <vprintfmt+0x15c>
  80063d:	8b 14 85 40 2c 80 00 	mov    0x802c40(,%eax,4),%edx
  800644:	85 d2                	test   %edx,%edx
  800646:	74 18                	je     800660 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800648:	52                   	push   %edx
  800649:	68 41 2e 80 00       	push   $0x802e41
  80064e:	53                   	push   %ebx
  80064f:	56                   	push   %esi
  800650:	e8 92 fe ff ff       	call   8004e7 <printfmt>
  800655:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800658:	89 7d 14             	mov    %edi,0x14(%ebp)
  80065b:	e9 66 02 00 00       	jmp    8008c6 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800660:	50                   	push   %eax
  800661:	68 ab 29 80 00       	push   $0x8029ab
  800666:	53                   	push   %ebx
  800667:	56                   	push   %esi
  800668:	e8 7a fe ff ff       	call   8004e7 <printfmt>
  80066d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800670:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800673:	e9 4e 02 00 00       	jmp    8008c6 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	83 c0 04             	add    $0x4,%eax
  80067e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800681:	8b 45 14             	mov    0x14(%ebp),%eax
  800684:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800686:	85 d2                	test   %edx,%edx
  800688:	b8 a4 29 80 00       	mov    $0x8029a4,%eax
  80068d:	0f 45 c2             	cmovne %edx,%eax
  800690:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800693:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800697:	7e 06                	jle    80069f <vprintfmt+0x19b>
  800699:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80069d:	75 0d                	jne    8006ac <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80069f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006a2:	89 c7                	mov    %eax,%edi
  8006a4:	03 45 e0             	add    -0x20(%ebp),%eax
  8006a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006aa:	eb 55                	jmp    800701 <vprintfmt+0x1fd>
  8006ac:	83 ec 08             	sub    $0x8,%esp
  8006af:	ff 75 d8             	push   -0x28(%ebp)
  8006b2:	ff 75 cc             	push   -0x34(%ebp)
  8006b5:	e8 0a 03 00 00       	call   8009c4 <strnlen>
  8006ba:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006bd:	29 c1                	sub    %eax,%ecx
  8006bf:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8006c7:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ce:	eb 0f                	jmp    8006df <vprintfmt+0x1db>
					putch(padc, putdat);
  8006d0:	83 ec 08             	sub    $0x8,%esp
  8006d3:	53                   	push   %ebx
  8006d4:	ff 75 e0             	push   -0x20(%ebp)
  8006d7:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d9:	83 ef 01             	sub    $0x1,%edi
  8006dc:	83 c4 10             	add    $0x10,%esp
  8006df:	85 ff                	test   %edi,%edi
  8006e1:	7f ed                	jg     8006d0 <vprintfmt+0x1cc>
  8006e3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006e6:	85 d2                	test   %edx,%edx
  8006e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8006ed:	0f 49 c2             	cmovns %edx,%eax
  8006f0:	29 c2                	sub    %eax,%edx
  8006f2:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006f5:	eb a8                	jmp    80069f <vprintfmt+0x19b>
					putch(ch, putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	53                   	push   %ebx
  8006fb:	52                   	push   %edx
  8006fc:	ff d6                	call   *%esi
  8006fe:	83 c4 10             	add    $0x10,%esp
  800701:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800704:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800706:	83 c7 01             	add    $0x1,%edi
  800709:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80070d:	0f be d0             	movsbl %al,%edx
  800710:	85 d2                	test   %edx,%edx
  800712:	74 4b                	je     80075f <vprintfmt+0x25b>
  800714:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800718:	78 06                	js     800720 <vprintfmt+0x21c>
  80071a:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80071e:	78 1e                	js     80073e <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800720:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800724:	74 d1                	je     8006f7 <vprintfmt+0x1f3>
  800726:	0f be c0             	movsbl %al,%eax
  800729:	83 e8 20             	sub    $0x20,%eax
  80072c:	83 f8 5e             	cmp    $0x5e,%eax
  80072f:	76 c6                	jbe    8006f7 <vprintfmt+0x1f3>
					putch('?', putdat);
  800731:	83 ec 08             	sub    $0x8,%esp
  800734:	53                   	push   %ebx
  800735:	6a 3f                	push   $0x3f
  800737:	ff d6                	call   *%esi
  800739:	83 c4 10             	add    $0x10,%esp
  80073c:	eb c3                	jmp    800701 <vprintfmt+0x1fd>
  80073e:	89 cf                	mov    %ecx,%edi
  800740:	eb 0e                	jmp    800750 <vprintfmt+0x24c>
				putch(' ', putdat);
  800742:	83 ec 08             	sub    $0x8,%esp
  800745:	53                   	push   %ebx
  800746:	6a 20                	push   $0x20
  800748:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80074a:	83 ef 01             	sub    $0x1,%edi
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	85 ff                	test   %edi,%edi
  800752:	7f ee                	jg     800742 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800754:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800757:	89 45 14             	mov    %eax,0x14(%ebp)
  80075a:	e9 67 01 00 00       	jmp    8008c6 <vprintfmt+0x3c2>
  80075f:	89 cf                	mov    %ecx,%edi
  800761:	eb ed                	jmp    800750 <vprintfmt+0x24c>
	if (lflag >= 2)
  800763:	83 f9 01             	cmp    $0x1,%ecx
  800766:	7f 1b                	jg     800783 <vprintfmt+0x27f>
	else if (lflag)
  800768:	85 c9                	test   %ecx,%ecx
  80076a:	74 63                	je     8007cf <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8b 00                	mov    (%eax),%eax
  800771:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800774:	99                   	cltd   
  800775:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800778:	8b 45 14             	mov    0x14(%ebp),%eax
  80077b:	8d 40 04             	lea    0x4(%eax),%eax
  80077e:	89 45 14             	mov    %eax,0x14(%ebp)
  800781:	eb 17                	jmp    80079a <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8b 50 04             	mov    0x4(%eax),%edx
  800789:	8b 00                	mov    (%eax),%eax
  80078b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 40 08             	lea    0x8(%eax),%eax
  800797:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80079a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80079d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007a0:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8007a5:	85 c9                	test   %ecx,%ecx
  8007a7:	0f 89 ff 00 00 00    	jns    8008ac <vprintfmt+0x3a8>
				putch('-', putdat);
  8007ad:	83 ec 08             	sub    $0x8,%esp
  8007b0:	53                   	push   %ebx
  8007b1:	6a 2d                	push   $0x2d
  8007b3:	ff d6                	call   *%esi
				num = -(long long) num;
  8007b5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007b8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007bb:	f7 da                	neg    %edx
  8007bd:	83 d1 00             	adc    $0x0,%ecx
  8007c0:	f7 d9                	neg    %ecx
  8007c2:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007c5:	bf 0a 00 00 00       	mov    $0xa,%edi
  8007ca:	e9 dd 00 00 00       	jmp    8008ac <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8b 00                	mov    (%eax),%eax
  8007d4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007d7:	99                   	cltd   
  8007d8:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007db:	8b 45 14             	mov    0x14(%ebp),%eax
  8007de:	8d 40 04             	lea    0x4(%eax),%eax
  8007e1:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e4:	eb b4                	jmp    80079a <vprintfmt+0x296>
	if (lflag >= 2)
  8007e6:	83 f9 01             	cmp    $0x1,%ecx
  8007e9:	7f 1e                	jg     800809 <vprintfmt+0x305>
	else if (lflag)
  8007eb:	85 c9                	test   %ecx,%ecx
  8007ed:	74 32                	je     800821 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8b 10                	mov    (%eax),%edx
  8007f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f9:	8d 40 04             	lea    0x4(%eax),%eax
  8007fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007ff:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800804:	e9 a3 00 00 00       	jmp    8008ac <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800809:	8b 45 14             	mov    0x14(%ebp),%eax
  80080c:	8b 10                	mov    (%eax),%edx
  80080e:	8b 48 04             	mov    0x4(%eax),%ecx
  800811:	8d 40 08             	lea    0x8(%eax),%eax
  800814:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800817:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80081c:	e9 8b 00 00 00       	jmp    8008ac <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800821:	8b 45 14             	mov    0x14(%ebp),%eax
  800824:	8b 10                	mov    (%eax),%edx
  800826:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082b:	8d 40 04             	lea    0x4(%eax),%eax
  80082e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800831:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800836:	eb 74                	jmp    8008ac <vprintfmt+0x3a8>
	if (lflag >= 2)
  800838:	83 f9 01             	cmp    $0x1,%ecx
  80083b:	7f 1b                	jg     800858 <vprintfmt+0x354>
	else if (lflag)
  80083d:	85 c9                	test   %ecx,%ecx
  80083f:	74 2c                	je     80086d <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800841:	8b 45 14             	mov    0x14(%ebp),%eax
  800844:	8b 10                	mov    (%eax),%edx
  800846:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084b:	8d 40 04             	lea    0x4(%eax),%eax
  80084e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800851:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800856:	eb 54                	jmp    8008ac <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800858:	8b 45 14             	mov    0x14(%ebp),%eax
  80085b:	8b 10                	mov    (%eax),%edx
  80085d:	8b 48 04             	mov    0x4(%eax),%ecx
  800860:	8d 40 08             	lea    0x8(%eax),%eax
  800863:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800866:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80086b:	eb 3f                	jmp    8008ac <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80086d:	8b 45 14             	mov    0x14(%ebp),%eax
  800870:	8b 10                	mov    (%eax),%edx
  800872:	b9 00 00 00 00       	mov    $0x0,%ecx
  800877:	8d 40 04             	lea    0x4(%eax),%eax
  80087a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80087d:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800882:	eb 28                	jmp    8008ac <vprintfmt+0x3a8>
			putch('0', putdat);
  800884:	83 ec 08             	sub    $0x8,%esp
  800887:	53                   	push   %ebx
  800888:	6a 30                	push   $0x30
  80088a:	ff d6                	call   *%esi
			putch('x', putdat);
  80088c:	83 c4 08             	add    $0x8,%esp
  80088f:	53                   	push   %ebx
  800890:	6a 78                	push   $0x78
  800892:	ff d6                	call   *%esi
			num = (unsigned long long)
  800894:	8b 45 14             	mov    0x14(%ebp),%eax
  800897:	8b 10                	mov    (%eax),%edx
  800899:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80089e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008a1:	8d 40 04             	lea    0x4(%eax),%eax
  8008a4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008a7:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8008ac:	83 ec 0c             	sub    $0xc,%esp
  8008af:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8008b3:	50                   	push   %eax
  8008b4:	ff 75 e0             	push   -0x20(%ebp)
  8008b7:	57                   	push   %edi
  8008b8:	51                   	push   %ecx
  8008b9:	52                   	push   %edx
  8008ba:	89 da                	mov    %ebx,%edx
  8008bc:	89 f0                	mov    %esi,%eax
  8008be:	e8 5e fb ff ff       	call   800421 <printnum>
			break;
  8008c3:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008c9:	e9 54 fc ff ff       	jmp    800522 <vprintfmt+0x1e>
	if (lflag >= 2)
  8008ce:	83 f9 01             	cmp    $0x1,%ecx
  8008d1:	7f 1b                	jg     8008ee <vprintfmt+0x3ea>
	else if (lflag)
  8008d3:	85 c9                	test   %ecx,%ecx
  8008d5:	74 2c                	je     800903 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8008d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8008da:	8b 10                	mov    (%eax),%edx
  8008dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008e1:	8d 40 04             	lea    0x4(%eax),%eax
  8008e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008e7:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8008ec:	eb be                	jmp    8008ac <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8008ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f1:	8b 10                	mov    (%eax),%edx
  8008f3:	8b 48 04             	mov    0x4(%eax),%ecx
  8008f6:	8d 40 08             	lea    0x8(%eax),%eax
  8008f9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008fc:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800901:	eb a9                	jmp    8008ac <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800903:	8b 45 14             	mov    0x14(%ebp),%eax
  800906:	8b 10                	mov    (%eax),%edx
  800908:	b9 00 00 00 00       	mov    $0x0,%ecx
  80090d:	8d 40 04             	lea    0x4(%eax),%eax
  800910:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800913:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800918:	eb 92                	jmp    8008ac <vprintfmt+0x3a8>
			putch(ch, putdat);
  80091a:	83 ec 08             	sub    $0x8,%esp
  80091d:	53                   	push   %ebx
  80091e:	6a 25                	push   $0x25
  800920:	ff d6                	call   *%esi
			break;
  800922:	83 c4 10             	add    $0x10,%esp
  800925:	eb 9f                	jmp    8008c6 <vprintfmt+0x3c2>
			putch('%', putdat);
  800927:	83 ec 08             	sub    $0x8,%esp
  80092a:	53                   	push   %ebx
  80092b:	6a 25                	push   $0x25
  80092d:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80092f:	83 c4 10             	add    $0x10,%esp
  800932:	89 f8                	mov    %edi,%eax
  800934:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800938:	74 05                	je     80093f <vprintfmt+0x43b>
  80093a:	83 e8 01             	sub    $0x1,%eax
  80093d:	eb f5                	jmp    800934 <vprintfmt+0x430>
  80093f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800942:	eb 82                	jmp    8008c6 <vprintfmt+0x3c2>

00800944 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	83 ec 18             	sub    $0x18,%esp
  80094a:	8b 45 08             	mov    0x8(%ebp),%eax
  80094d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800950:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800953:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800957:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80095a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800961:	85 c0                	test   %eax,%eax
  800963:	74 26                	je     80098b <vsnprintf+0x47>
  800965:	85 d2                	test   %edx,%edx
  800967:	7e 22                	jle    80098b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800969:	ff 75 14             	push   0x14(%ebp)
  80096c:	ff 75 10             	push   0x10(%ebp)
  80096f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800972:	50                   	push   %eax
  800973:	68 ca 04 80 00       	push   $0x8004ca
  800978:	e8 87 fb ff ff       	call   800504 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80097d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800980:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800983:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800986:	83 c4 10             	add    $0x10,%esp
}
  800989:	c9                   	leave  
  80098a:	c3                   	ret    
		return -E_INVAL;
  80098b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800990:	eb f7                	jmp    800989 <vsnprintf+0x45>

00800992 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800998:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80099b:	50                   	push   %eax
  80099c:	ff 75 10             	push   0x10(%ebp)
  80099f:	ff 75 0c             	push   0xc(%ebp)
  8009a2:	ff 75 08             	push   0x8(%ebp)
  8009a5:	e8 9a ff ff ff       	call   800944 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009aa:	c9                   	leave  
  8009ab:	c3                   	ret    

008009ac <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b7:	eb 03                	jmp    8009bc <strlen+0x10>
		n++;
  8009b9:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009bc:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009c0:	75 f7                	jne    8009b9 <strlen+0xd>
	return n;
}
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ca:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d2:	eb 03                	jmp    8009d7 <strnlen+0x13>
		n++;
  8009d4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d7:	39 d0                	cmp    %edx,%eax
  8009d9:	74 08                	je     8009e3 <strnlen+0x1f>
  8009db:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009df:	75 f3                	jne    8009d4 <strnlen+0x10>
  8009e1:	89 c2                	mov    %eax,%edx
	return n;
}
  8009e3:	89 d0                	mov    %edx,%eax
  8009e5:	5d                   	pop    %ebp
  8009e6:	c3                   	ret    

008009e7 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009e7:	55                   	push   %ebp
  8009e8:	89 e5                	mov    %esp,%ebp
  8009ea:	53                   	push   %ebx
  8009eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ee:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f6:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8009fa:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8009fd:	83 c0 01             	add    $0x1,%eax
  800a00:	84 d2                	test   %dl,%dl
  800a02:	75 f2                	jne    8009f6 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a04:	89 c8                	mov    %ecx,%eax
  800a06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a09:	c9                   	leave  
  800a0a:	c3                   	ret    

00800a0b <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	53                   	push   %ebx
  800a0f:	83 ec 10             	sub    $0x10,%esp
  800a12:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a15:	53                   	push   %ebx
  800a16:	e8 91 ff ff ff       	call   8009ac <strlen>
  800a1b:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a1e:	ff 75 0c             	push   0xc(%ebp)
  800a21:	01 d8                	add    %ebx,%eax
  800a23:	50                   	push   %eax
  800a24:	e8 be ff ff ff       	call   8009e7 <strcpy>
	return dst;
}
  800a29:	89 d8                	mov    %ebx,%eax
  800a2b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a2e:	c9                   	leave  
  800a2f:	c3                   	ret    

00800a30 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	56                   	push   %esi
  800a34:	53                   	push   %ebx
  800a35:	8b 75 08             	mov    0x8(%ebp),%esi
  800a38:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3b:	89 f3                	mov    %esi,%ebx
  800a3d:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a40:	89 f0                	mov    %esi,%eax
  800a42:	eb 0f                	jmp    800a53 <strncpy+0x23>
		*dst++ = *src;
  800a44:	83 c0 01             	add    $0x1,%eax
  800a47:	0f b6 0a             	movzbl (%edx),%ecx
  800a4a:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a4d:	80 f9 01             	cmp    $0x1,%cl
  800a50:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800a53:	39 d8                	cmp    %ebx,%eax
  800a55:	75 ed                	jne    800a44 <strncpy+0x14>
	}
	return ret;
}
  800a57:	89 f0                	mov    %esi,%eax
  800a59:	5b                   	pop    %ebx
  800a5a:	5e                   	pop    %esi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    

00800a5d <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	56                   	push   %esi
  800a61:	53                   	push   %ebx
  800a62:	8b 75 08             	mov    0x8(%ebp),%esi
  800a65:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a68:	8b 55 10             	mov    0x10(%ebp),%edx
  800a6b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a6d:	85 d2                	test   %edx,%edx
  800a6f:	74 21                	je     800a92 <strlcpy+0x35>
  800a71:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a75:	89 f2                	mov    %esi,%edx
  800a77:	eb 09                	jmp    800a82 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a79:	83 c1 01             	add    $0x1,%ecx
  800a7c:	83 c2 01             	add    $0x1,%edx
  800a7f:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800a82:	39 c2                	cmp    %eax,%edx
  800a84:	74 09                	je     800a8f <strlcpy+0x32>
  800a86:	0f b6 19             	movzbl (%ecx),%ebx
  800a89:	84 db                	test   %bl,%bl
  800a8b:	75 ec                	jne    800a79 <strlcpy+0x1c>
  800a8d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a8f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a92:	29 f0                	sub    %esi,%eax
}
  800a94:	5b                   	pop    %ebx
  800a95:	5e                   	pop    %esi
  800a96:	5d                   	pop    %ebp
  800a97:	c3                   	ret    

00800a98 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a98:	55                   	push   %ebp
  800a99:	89 e5                	mov    %esp,%ebp
  800a9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aa1:	eb 06                	jmp    800aa9 <strcmp+0x11>
		p++, q++;
  800aa3:	83 c1 01             	add    $0x1,%ecx
  800aa6:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800aa9:	0f b6 01             	movzbl (%ecx),%eax
  800aac:	84 c0                	test   %al,%al
  800aae:	74 04                	je     800ab4 <strcmp+0x1c>
  800ab0:	3a 02                	cmp    (%edx),%al
  800ab2:	74 ef                	je     800aa3 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab4:	0f b6 c0             	movzbl %al,%eax
  800ab7:	0f b6 12             	movzbl (%edx),%edx
  800aba:	29 d0                	sub    %edx,%eax
}
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	53                   	push   %ebx
  800ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac8:	89 c3                	mov    %eax,%ebx
  800aca:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800acd:	eb 06                	jmp    800ad5 <strncmp+0x17>
		n--, p++, q++;
  800acf:	83 c0 01             	add    $0x1,%eax
  800ad2:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ad5:	39 d8                	cmp    %ebx,%eax
  800ad7:	74 18                	je     800af1 <strncmp+0x33>
  800ad9:	0f b6 08             	movzbl (%eax),%ecx
  800adc:	84 c9                	test   %cl,%cl
  800ade:	74 04                	je     800ae4 <strncmp+0x26>
  800ae0:	3a 0a                	cmp    (%edx),%cl
  800ae2:	74 eb                	je     800acf <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae4:	0f b6 00             	movzbl (%eax),%eax
  800ae7:	0f b6 12             	movzbl (%edx),%edx
  800aea:	29 d0                	sub    %edx,%eax
}
  800aec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aef:	c9                   	leave  
  800af0:	c3                   	ret    
		return 0;
  800af1:	b8 00 00 00 00       	mov    $0x0,%eax
  800af6:	eb f4                	jmp    800aec <strncmp+0x2e>

00800af8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	8b 45 08             	mov    0x8(%ebp),%eax
  800afe:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b02:	eb 03                	jmp    800b07 <strchr+0xf>
  800b04:	83 c0 01             	add    $0x1,%eax
  800b07:	0f b6 10             	movzbl (%eax),%edx
  800b0a:	84 d2                	test   %dl,%dl
  800b0c:	74 06                	je     800b14 <strchr+0x1c>
		if (*s == c)
  800b0e:	38 ca                	cmp    %cl,%dl
  800b10:	75 f2                	jne    800b04 <strchr+0xc>
  800b12:	eb 05                	jmp    800b19 <strchr+0x21>
			return (char *) s;
	return 0;
  800b14:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b25:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b28:	38 ca                	cmp    %cl,%dl
  800b2a:	74 09                	je     800b35 <strfind+0x1a>
  800b2c:	84 d2                	test   %dl,%dl
  800b2e:	74 05                	je     800b35 <strfind+0x1a>
	for (; *s; s++)
  800b30:	83 c0 01             	add    $0x1,%eax
  800b33:	eb f0                	jmp    800b25 <strfind+0xa>
			break;
	return (char *) s;
}
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	57                   	push   %edi
  800b3b:	56                   	push   %esi
  800b3c:	53                   	push   %ebx
  800b3d:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b40:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b43:	85 c9                	test   %ecx,%ecx
  800b45:	74 2f                	je     800b76 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b47:	89 f8                	mov    %edi,%eax
  800b49:	09 c8                	or     %ecx,%eax
  800b4b:	a8 03                	test   $0x3,%al
  800b4d:	75 21                	jne    800b70 <memset+0x39>
		c &= 0xFF;
  800b4f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b53:	89 d0                	mov    %edx,%eax
  800b55:	c1 e0 08             	shl    $0x8,%eax
  800b58:	89 d3                	mov    %edx,%ebx
  800b5a:	c1 e3 18             	shl    $0x18,%ebx
  800b5d:	89 d6                	mov    %edx,%esi
  800b5f:	c1 e6 10             	shl    $0x10,%esi
  800b62:	09 f3                	or     %esi,%ebx
  800b64:	09 da                	or     %ebx,%edx
  800b66:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b68:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b6b:	fc                   	cld    
  800b6c:	f3 ab                	rep stos %eax,%es:(%edi)
  800b6e:	eb 06                	jmp    800b76 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b73:	fc                   	cld    
  800b74:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b76:	89 f8                	mov    %edi,%eax
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	8b 45 08             	mov    0x8(%ebp),%eax
  800b85:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b88:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b8b:	39 c6                	cmp    %eax,%esi
  800b8d:	73 32                	jae    800bc1 <memmove+0x44>
  800b8f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b92:	39 c2                	cmp    %eax,%edx
  800b94:	76 2b                	jbe    800bc1 <memmove+0x44>
		s += n;
		d += n;
  800b96:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b99:	89 d6                	mov    %edx,%esi
  800b9b:	09 fe                	or     %edi,%esi
  800b9d:	09 ce                	or     %ecx,%esi
  800b9f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ba5:	75 0e                	jne    800bb5 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ba7:	83 ef 04             	sub    $0x4,%edi
  800baa:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bad:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800bb0:	fd                   	std    
  800bb1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb3:	eb 09                	jmp    800bbe <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bb5:	83 ef 01             	sub    $0x1,%edi
  800bb8:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bbb:	fd                   	std    
  800bbc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bbe:	fc                   	cld    
  800bbf:	eb 1a                	jmp    800bdb <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc1:	89 f2                	mov    %esi,%edx
  800bc3:	09 c2                	or     %eax,%edx
  800bc5:	09 ca                	or     %ecx,%edx
  800bc7:	f6 c2 03             	test   $0x3,%dl
  800bca:	75 0a                	jne    800bd6 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bcc:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800bcf:	89 c7                	mov    %eax,%edi
  800bd1:	fc                   	cld    
  800bd2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bd4:	eb 05                	jmp    800bdb <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800bd6:	89 c7                	mov    %eax,%edi
  800bd8:	fc                   	cld    
  800bd9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800be5:	ff 75 10             	push   0x10(%ebp)
  800be8:	ff 75 0c             	push   0xc(%ebp)
  800beb:	ff 75 08             	push   0x8(%ebp)
  800bee:	e8 8a ff ff ff       	call   800b7d <memmove>
}
  800bf3:	c9                   	leave  
  800bf4:	c3                   	ret    

00800bf5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c00:	89 c6                	mov    %eax,%esi
  800c02:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c05:	eb 06                	jmp    800c0d <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c07:	83 c0 01             	add    $0x1,%eax
  800c0a:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800c0d:	39 f0                	cmp    %esi,%eax
  800c0f:	74 14                	je     800c25 <memcmp+0x30>
		if (*s1 != *s2)
  800c11:	0f b6 08             	movzbl (%eax),%ecx
  800c14:	0f b6 1a             	movzbl (%edx),%ebx
  800c17:	38 d9                	cmp    %bl,%cl
  800c19:	74 ec                	je     800c07 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800c1b:	0f b6 c1             	movzbl %cl,%eax
  800c1e:	0f b6 db             	movzbl %bl,%ebx
  800c21:	29 d8                	sub    %ebx,%eax
  800c23:	eb 05                	jmp    800c2a <memcmp+0x35>
	}

	return 0;
  800c25:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c2a:	5b                   	pop    %ebx
  800c2b:	5e                   	pop    %esi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	8b 45 08             	mov    0x8(%ebp),%eax
  800c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c37:	89 c2                	mov    %eax,%edx
  800c39:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c3c:	eb 03                	jmp    800c41 <memfind+0x13>
  800c3e:	83 c0 01             	add    $0x1,%eax
  800c41:	39 d0                	cmp    %edx,%eax
  800c43:	73 04                	jae    800c49 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c45:	38 08                	cmp    %cl,(%eax)
  800c47:	75 f5                	jne    800c3e <memfind+0x10>
			break;
	return (void *) s;
}
  800c49:	5d                   	pop    %ebp
  800c4a:	c3                   	ret    

00800c4b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	57                   	push   %edi
  800c4f:	56                   	push   %esi
  800c50:	53                   	push   %ebx
  800c51:	8b 55 08             	mov    0x8(%ebp),%edx
  800c54:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c57:	eb 03                	jmp    800c5c <strtol+0x11>
		s++;
  800c59:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800c5c:	0f b6 02             	movzbl (%edx),%eax
  800c5f:	3c 20                	cmp    $0x20,%al
  800c61:	74 f6                	je     800c59 <strtol+0xe>
  800c63:	3c 09                	cmp    $0x9,%al
  800c65:	74 f2                	je     800c59 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c67:	3c 2b                	cmp    $0x2b,%al
  800c69:	74 2a                	je     800c95 <strtol+0x4a>
	int neg = 0;
  800c6b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c70:	3c 2d                	cmp    $0x2d,%al
  800c72:	74 2b                	je     800c9f <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c74:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c7a:	75 0f                	jne    800c8b <strtol+0x40>
  800c7c:	80 3a 30             	cmpb   $0x30,(%edx)
  800c7f:	74 28                	je     800ca9 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c81:	85 db                	test   %ebx,%ebx
  800c83:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c88:	0f 44 d8             	cmove  %eax,%ebx
  800c8b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c90:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c93:	eb 46                	jmp    800cdb <strtol+0x90>
		s++;
  800c95:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800c98:	bf 00 00 00 00       	mov    $0x0,%edi
  800c9d:	eb d5                	jmp    800c74 <strtol+0x29>
		s++, neg = 1;
  800c9f:	83 c2 01             	add    $0x1,%edx
  800ca2:	bf 01 00 00 00       	mov    $0x1,%edi
  800ca7:	eb cb                	jmp    800c74 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ca9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cad:	74 0e                	je     800cbd <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800caf:	85 db                	test   %ebx,%ebx
  800cb1:	75 d8                	jne    800c8b <strtol+0x40>
		s++, base = 8;
  800cb3:	83 c2 01             	add    $0x1,%edx
  800cb6:	bb 08 00 00 00       	mov    $0x8,%ebx
  800cbb:	eb ce                	jmp    800c8b <strtol+0x40>
		s += 2, base = 16;
  800cbd:	83 c2 02             	add    $0x2,%edx
  800cc0:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cc5:	eb c4                	jmp    800c8b <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800cc7:	0f be c0             	movsbl %al,%eax
  800cca:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ccd:	3b 45 10             	cmp    0x10(%ebp),%eax
  800cd0:	7d 3a                	jge    800d0c <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800cd2:	83 c2 01             	add    $0x1,%edx
  800cd5:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800cd9:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800cdb:	0f b6 02             	movzbl (%edx),%eax
  800cde:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ce1:	89 f3                	mov    %esi,%ebx
  800ce3:	80 fb 09             	cmp    $0x9,%bl
  800ce6:	76 df                	jbe    800cc7 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ce8:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ceb:	89 f3                	mov    %esi,%ebx
  800ced:	80 fb 19             	cmp    $0x19,%bl
  800cf0:	77 08                	ja     800cfa <strtol+0xaf>
			dig = *s - 'a' + 10;
  800cf2:	0f be c0             	movsbl %al,%eax
  800cf5:	83 e8 57             	sub    $0x57,%eax
  800cf8:	eb d3                	jmp    800ccd <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800cfa:	8d 70 bf             	lea    -0x41(%eax),%esi
  800cfd:	89 f3                	mov    %esi,%ebx
  800cff:	80 fb 19             	cmp    $0x19,%bl
  800d02:	77 08                	ja     800d0c <strtol+0xc1>
			dig = *s - 'A' + 10;
  800d04:	0f be c0             	movsbl %al,%eax
  800d07:	83 e8 37             	sub    $0x37,%eax
  800d0a:	eb c1                	jmp    800ccd <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d0c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d10:	74 05                	je     800d17 <strtol+0xcc>
		*endptr = (char *) s;
  800d12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d15:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800d17:	89 c8                	mov    %ecx,%eax
  800d19:	f7 d8                	neg    %eax
  800d1b:	85 ff                	test   %edi,%edi
  800d1d:	0f 45 c8             	cmovne %eax,%ecx
}
  800d20:	89 c8                	mov    %ecx,%eax
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    

00800d27 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d2d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d38:	89 c3                	mov    %eax,%ebx
  800d3a:	89 c7                	mov    %eax,%edi
  800d3c:	89 c6                	mov    %eax,%esi
  800d3e:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d50:	b8 01 00 00 00       	mov    $0x1,%eax
  800d55:	89 d1                	mov    %edx,%ecx
  800d57:	89 d3                	mov    %edx,%ebx
  800d59:	89 d7                	mov    %edx,%edi
  800d5b:	89 d6                	mov    %edx,%esi
  800d5d:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d5f:	5b                   	pop    %ebx
  800d60:	5e                   	pop    %esi
  800d61:	5f                   	pop    %edi
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	57                   	push   %edi
  800d68:	56                   	push   %esi
  800d69:	53                   	push   %ebx
  800d6a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d6d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	b8 03 00 00 00       	mov    $0x3,%eax
  800d7a:	89 cb                	mov    %ecx,%ebx
  800d7c:	89 cf                	mov    %ecx,%edi
  800d7e:	89 ce                	mov    %ecx,%esi
  800d80:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d82:	85 c0                	test   %eax,%eax
  800d84:	7f 08                	jg     800d8e <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
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
  800d92:	6a 03                	push   $0x3
  800d94:	68 9f 2c 80 00       	push   $0x802c9f
  800d99:	6a 2a                	push   $0x2a
  800d9b:	68 bc 2c 80 00       	push   $0x802cbc
  800da0:	e8 8d f5 ff ff       	call   800332 <_panic>

00800da5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	57                   	push   %edi
  800da9:	56                   	push   %esi
  800daa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dab:	ba 00 00 00 00       	mov    $0x0,%edx
  800db0:	b8 02 00 00 00       	mov    $0x2,%eax
  800db5:	89 d1                	mov    %edx,%ecx
  800db7:	89 d3                	mov    %edx,%ebx
  800db9:	89 d7                	mov    %edx,%edi
  800dbb:	89 d6                	mov    %edx,%esi
  800dbd:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dbf:	5b                   	pop    %ebx
  800dc0:	5e                   	pop    %esi
  800dc1:	5f                   	pop    %edi
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_yield>:

void
sys_yield(void)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	57                   	push   %edi
  800dc8:	56                   	push   %esi
  800dc9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dca:	ba 00 00 00 00       	mov    $0x0,%edx
  800dcf:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dd4:	89 d1                	mov    %edx,%ecx
  800dd6:	89 d3                	mov    %edx,%ebx
  800dd8:	89 d7                	mov    %edx,%edi
  800dda:	89 d6                	mov    %edx,%esi
  800ddc:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800dde:	5b                   	pop    %ebx
  800ddf:	5e                   	pop    %esi
  800de0:	5f                   	pop    %edi
  800de1:	5d                   	pop    %ebp
  800de2:	c3                   	ret    

00800de3 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	57                   	push   %edi
  800de7:	56                   	push   %esi
  800de8:	53                   	push   %ebx
  800de9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dec:	be 00 00 00 00       	mov    $0x0,%esi
  800df1:	8b 55 08             	mov    0x8(%ebp),%edx
  800df4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df7:	b8 04 00 00 00       	mov    $0x4,%eax
  800dfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dff:	89 f7                	mov    %esi,%edi
  800e01:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e03:	85 c0                	test   %eax,%eax
  800e05:	7f 08                	jg     800e0f <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
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
  800e13:	6a 04                	push   $0x4
  800e15:	68 9f 2c 80 00       	push   $0x802c9f
  800e1a:	6a 2a                	push   $0x2a
  800e1c:	68 bc 2c 80 00       	push   $0x802cbc
  800e21:	e8 0c f5 ff ff       	call   800332 <_panic>

00800e26 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	57                   	push   %edi
  800e2a:	56                   	push   %esi
  800e2b:	53                   	push   %ebx
  800e2c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e2f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e35:	b8 05 00 00 00       	mov    $0x5,%eax
  800e3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e40:	8b 75 18             	mov    0x18(%ebp),%esi
  800e43:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e45:	85 c0                	test   %eax,%eax
  800e47:	7f 08                	jg     800e51 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
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
  800e55:	6a 05                	push   $0x5
  800e57:	68 9f 2c 80 00       	push   $0x802c9f
  800e5c:	6a 2a                	push   $0x2a
  800e5e:	68 bc 2c 80 00       	push   $0x802cbc
  800e63:	e8 ca f4 ff ff       	call   800332 <_panic>

00800e68 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	57                   	push   %edi
  800e6c:	56                   	push   %esi
  800e6d:	53                   	push   %ebx
  800e6e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e76:	8b 55 08             	mov    0x8(%ebp),%edx
  800e79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7c:	b8 06 00 00 00       	mov    $0x6,%eax
  800e81:	89 df                	mov    %ebx,%edi
  800e83:	89 de                	mov    %ebx,%esi
  800e85:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e87:	85 c0                	test   %eax,%eax
  800e89:	7f 08                	jg     800e93 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e8e:	5b                   	pop    %ebx
  800e8f:	5e                   	pop    %esi
  800e90:	5f                   	pop    %edi
  800e91:	5d                   	pop    %ebp
  800e92:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e93:	83 ec 0c             	sub    $0xc,%esp
  800e96:	50                   	push   %eax
  800e97:	6a 06                	push   $0x6
  800e99:	68 9f 2c 80 00       	push   $0x802c9f
  800e9e:	6a 2a                	push   $0x2a
  800ea0:	68 bc 2c 80 00       	push   $0x802cbc
  800ea5:	e8 88 f4 ff ff       	call   800332 <_panic>

00800eaa <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	57                   	push   %edi
  800eae:	56                   	push   %esi
  800eaf:	53                   	push   %ebx
  800eb0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800eb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ebe:	b8 08 00 00 00       	mov    $0x8,%eax
  800ec3:	89 df                	mov    %ebx,%edi
  800ec5:	89 de                	mov    %ebx,%esi
  800ec7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	7f 08                	jg     800ed5 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ecd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed5:	83 ec 0c             	sub    $0xc,%esp
  800ed8:	50                   	push   %eax
  800ed9:	6a 08                	push   $0x8
  800edb:	68 9f 2c 80 00       	push   $0x802c9f
  800ee0:	6a 2a                	push   $0x2a
  800ee2:	68 bc 2c 80 00       	push   $0x802cbc
  800ee7:	e8 46 f4 ff ff       	call   800332 <_panic>

00800eec <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	57                   	push   %edi
  800ef0:	56                   	push   %esi
  800ef1:	53                   	push   %ebx
  800ef2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ef5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efa:	8b 55 08             	mov    0x8(%ebp),%edx
  800efd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f00:	b8 09 00 00 00       	mov    $0x9,%eax
  800f05:	89 df                	mov    %ebx,%edi
  800f07:	89 de                	mov    %ebx,%esi
  800f09:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	7f 08                	jg     800f17 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f12:	5b                   	pop    %ebx
  800f13:	5e                   	pop    %esi
  800f14:	5f                   	pop    %edi
  800f15:	5d                   	pop    %ebp
  800f16:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f17:	83 ec 0c             	sub    $0xc,%esp
  800f1a:	50                   	push   %eax
  800f1b:	6a 09                	push   $0x9
  800f1d:	68 9f 2c 80 00       	push   $0x802c9f
  800f22:	6a 2a                	push   $0x2a
  800f24:	68 bc 2c 80 00       	push   $0x802cbc
  800f29:	e8 04 f4 ff ff       	call   800332 <_panic>

00800f2e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
  800f31:	57                   	push   %edi
  800f32:	56                   	push   %esi
  800f33:	53                   	push   %ebx
  800f34:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f42:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f47:	89 df                	mov    %ebx,%edi
  800f49:	89 de                	mov    %ebx,%esi
  800f4b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	7f 08                	jg     800f59 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f54:	5b                   	pop    %ebx
  800f55:	5e                   	pop    %esi
  800f56:	5f                   	pop    %edi
  800f57:	5d                   	pop    %ebp
  800f58:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f59:	83 ec 0c             	sub    $0xc,%esp
  800f5c:	50                   	push   %eax
  800f5d:	6a 0a                	push   $0xa
  800f5f:	68 9f 2c 80 00       	push   $0x802c9f
  800f64:	6a 2a                	push   $0x2a
  800f66:	68 bc 2c 80 00       	push   $0x802cbc
  800f6b:	e8 c2 f3 ff ff       	call   800332 <_panic>

00800f70 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f70:	55                   	push   %ebp
  800f71:	89 e5                	mov    %esp,%ebp
  800f73:	57                   	push   %edi
  800f74:	56                   	push   %esi
  800f75:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f76:	8b 55 08             	mov    0x8(%ebp),%edx
  800f79:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f81:	be 00 00 00 00       	mov    $0x0,%esi
  800f86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f89:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f8c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5f                   	pop    %edi
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	57                   	push   %edi
  800f97:	56                   	push   %esi
  800f98:	53                   	push   %ebx
  800f99:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa1:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa4:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fa9:	89 cb                	mov    %ecx,%ebx
  800fab:	89 cf                	mov    %ecx,%edi
  800fad:	89 ce                	mov    %ecx,%esi
  800faf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fb1:	85 c0                	test   %eax,%eax
  800fb3:	7f 08                	jg     800fbd <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fb8:	5b                   	pop    %ebx
  800fb9:	5e                   	pop    %esi
  800fba:	5f                   	pop    %edi
  800fbb:	5d                   	pop    %ebp
  800fbc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800fbd:	83 ec 0c             	sub    $0xc,%esp
  800fc0:	50                   	push   %eax
  800fc1:	6a 0d                	push   $0xd
  800fc3:	68 9f 2c 80 00       	push   $0x802c9f
  800fc8:	6a 2a                	push   $0x2a
  800fca:	68 bc 2c 80 00       	push   $0x802cbc
  800fcf:	e8 5e f3 ff ff       	call   800332 <_panic>

00800fd4 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	57                   	push   %edi
  800fd8:	56                   	push   %esi
  800fd9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fda:	ba 00 00 00 00       	mov    $0x0,%edx
  800fdf:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fe4:	89 d1                	mov    %edx,%ecx
  800fe6:	89 d3                	mov    %edx,%ebx
  800fe8:	89 d7                	mov    %edx,%edi
  800fea:	89 d6                	mov    %edx,%esi
  800fec:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800fee:	5b                   	pop    %ebx
  800fef:	5e                   	pop    %esi
  800ff0:	5f                   	pop    %edi
  800ff1:	5d                   	pop    %ebp
  800ff2:	c3                   	ret    

00800ff3 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	57                   	push   %edi
  800ff7:	56                   	push   %esi
  800ff8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ff9:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ffe:	8b 55 08             	mov    0x8(%ebp),%edx
  801001:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801004:	b8 0f 00 00 00       	mov    $0xf,%eax
  801009:	89 df                	mov    %ebx,%edi
  80100b:	89 de                	mov    %ebx,%esi
  80100d:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  80100f:	5b                   	pop    %ebx
  801010:	5e                   	pop    %esi
  801011:	5f                   	pop    %edi
  801012:	5d                   	pop    %ebp
  801013:	c3                   	ret    

00801014 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  801014:	55                   	push   %ebp
  801015:	89 e5                	mov    %esp,%ebp
  801017:	57                   	push   %edi
  801018:	56                   	push   %esi
  801019:	53                   	push   %ebx
	asm volatile("int %1\n"
  80101a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80101f:	8b 55 08             	mov    0x8(%ebp),%edx
  801022:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801025:	b8 10 00 00 00       	mov    $0x10,%eax
  80102a:	89 df                	mov    %ebx,%edi
  80102c:	89 de                	mov    %ebx,%esi
  80102e:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  801030:	5b                   	pop    %ebx
  801031:	5e                   	pop    %esi
  801032:	5f                   	pop    %edi
  801033:	5d                   	pop    %ebp
  801034:	c3                   	ret    

00801035 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	56                   	push   %esi
  801039:	53                   	push   %ebx
  80103a:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80103d:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  80103f:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801043:	0f 84 8e 00 00 00    	je     8010d7 <pgfault+0xa2>
  801049:	89 f0                	mov    %esi,%eax
  80104b:	c1 e8 0c             	shr    $0xc,%eax
  80104e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801055:	f6 c4 08             	test   $0x8,%ah
  801058:	74 7d                	je     8010d7 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  80105a:	e8 46 fd ff ff       	call   800da5 <sys_getenvid>
  80105f:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  801061:	83 ec 04             	sub    $0x4,%esp
  801064:	6a 07                	push   $0x7
  801066:	68 00 f0 7f 00       	push   $0x7ff000
  80106b:	50                   	push   %eax
  80106c:	e8 72 fd ff ff       	call   800de3 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  801071:	83 c4 10             	add    $0x10,%esp
  801074:	85 c0                	test   %eax,%eax
  801076:	78 73                	js     8010eb <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  801078:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  80107e:	83 ec 04             	sub    $0x4,%esp
  801081:	68 00 10 00 00       	push   $0x1000
  801086:	56                   	push   %esi
  801087:	68 00 f0 7f 00       	push   $0x7ff000
  80108c:	e8 ec fa ff ff       	call   800b7d <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  801091:	83 c4 08             	add    $0x8,%esp
  801094:	56                   	push   %esi
  801095:	53                   	push   %ebx
  801096:	e8 cd fd ff ff       	call   800e68 <sys_page_unmap>
  80109b:	83 c4 10             	add    $0x10,%esp
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	78 5b                	js     8010fd <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  8010a2:	83 ec 0c             	sub    $0xc,%esp
  8010a5:	6a 07                	push   $0x7
  8010a7:	56                   	push   %esi
  8010a8:	53                   	push   %ebx
  8010a9:	68 00 f0 7f 00       	push   $0x7ff000
  8010ae:	53                   	push   %ebx
  8010af:	e8 72 fd ff ff       	call   800e26 <sys_page_map>
  8010b4:	83 c4 20             	add    $0x20,%esp
  8010b7:	85 c0                	test   %eax,%eax
  8010b9:	78 54                	js     80110f <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  8010bb:	83 ec 08             	sub    $0x8,%esp
  8010be:	68 00 f0 7f 00       	push   $0x7ff000
  8010c3:	53                   	push   %ebx
  8010c4:	e8 9f fd ff ff       	call   800e68 <sys_page_unmap>
  8010c9:	83 c4 10             	add    $0x10,%esp
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	78 51                	js     801121 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  8010d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010d3:	5b                   	pop    %ebx
  8010d4:	5e                   	pop    %esi
  8010d5:	5d                   	pop    %ebp
  8010d6:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  8010d7:	83 ec 04             	sub    $0x4,%esp
  8010da:	68 cc 2c 80 00       	push   $0x802ccc
  8010df:	6a 1d                	push   $0x1d
  8010e1:	68 48 2d 80 00       	push   $0x802d48
  8010e6:	e8 47 f2 ff ff       	call   800332 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  8010eb:	50                   	push   %eax
  8010ec:	68 04 2d 80 00       	push   $0x802d04
  8010f1:	6a 29                	push   $0x29
  8010f3:	68 48 2d 80 00       	push   $0x802d48
  8010f8:	e8 35 f2 ff ff       	call   800332 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  8010fd:	50                   	push   %eax
  8010fe:	68 28 2d 80 00       	push   $0x802d28
  801103:	6a 2e                	push   $0x2e
  801105:	68 48 2d 80 00       	push   $0x802d48
  80110a:	e8 23 f2 ff ff       	call   800332 <_panic>
		panic("pgfault: page map failed (%e)", r);
  80110f:	50                   	push   %eax
  801110:	68 53 2d 80 00       	push   $0x802d53
  801115:	6a 30                	push   $0x30
  801117:	68 48 2d 80 00       	push   $0x802d48
  80111c:	e8 11 f2 ff ff       	call   800332 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  801121:	50                   	push   %eax
  801122:	68 28 2d 80 00       	push   $0x802d28
  801127:	6a 32                	push   $0x32
  801129:	68 48 2d 80 00       	push   $0x802d48
  80112e:	e8 ff f1 ff ff       	call   800332 <_panic>

00801133 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	57                   	push   %edi
  801137:	56                   	push   %esi
  801138:	53                   	push   %ebx
  801139:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  80113c:	68 35 10 80 00       	push   $0x801035
  801141:	e8 ca 12 00 00       	call   802410 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801146:	b8 07 00 00 00       	mov    $0x7,%eax
  80114b:	cd 30                	int    $0x30
  80114d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  801150:	83 c4 10             	add    $0x10,%esp
  801153:	85 c0                	test   %eax,%eax
  801155:	78 2d                	js     801184 <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801157:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  80115c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801160:	75 73                	jne    8011d5 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  801162:	e8 3e fc ff ff       	call   800da5 <sys_getenvid>
  801167:	25 ff 03 00 00       	and    $0x3ff,%eax
  80116c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80116f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801174:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  801179:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  80117c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117f:	5b                   	pop    %ebx
  801180:	5e                   	pop    %esi
  801181:	5f                   	pop    %edi
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  801184:	50                   	push   %eax
  801185:	68 71 2d 80 00       	push   $0x802d71
  80118a:	6a 78                	push   $0x78
  80118c:	68 48 2d 80 00       	push   $0x802d48
  801191:	e8 9c f1 ff ff       	call   800332 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  801196:	83 ec 0c             	sub    $0xc,%esp
  801199:	ff 75 e4             	push   -0x1c(%ebp)
  80119c:	57                   	push   %edi
  80119d:	ff 75 dc             	push   -0x24(%ebp)
  8011a0:	57                   	push   %edi
  8011a1:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8011a4:	56                   	push   %esi
  8011a5:	e8 7c fc ff ff       	call   800e26 <sys_page_map>
	if(r<0) return r;
  8011aa:	83 c4 20             	add    $0x20,%esp
  8011ad:	85 c0                	test   %eax,%eax
  8011af:	78 cb                	js     80117c <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  8011b1:	83 ec 0c             	sub    $0xc,%esp
  8011b4:	ff 75 e4             	push   -0x1c(%ebp)
  8011b7:	57                   	push   %edi
  8011b8:	56                   	push   %esi
  8011b9:	57                   	push   %edi
  8011ba:	56                   	push   %esi
  8011bb:	e8 66 fc ff ff       	call   800e26 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  8011c0:	83 c4 20             	add    $0x20,%esp
  8011c3:	85 c0                	test   %eax,%eax
  8011c5:	78 76                	js     80123d <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  8011c7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011cd:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011d3:	74 75                	je     80124a <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  8011d5:	89 d8                	mov    %ebx,%eax
  8011d7:	c1 e8 16             	shr    $0x16,%eax
  8011da:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011e1:	a8 01                	test   $0x1,%al
  8011e3:	74 e2                	je     8011c7 <fork+0x94>
  8011e5:	89 de                	mov    %ebx,%esi
  8011e7:	c1 ee 0c             	shr    $0xc,%esi
  8011ea:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011f1:	a8 01                	test   $0x1,%al
  8011f3:	74 d2                	je     8011c7 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  8011f5:	e8 ab fb ff ff       	call   800da5 <sys_getenvid>
  8011fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  8011fd:	89 f7                	mov    %esi,%edi
  8011ff:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  801202:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801209:	89 c1                	mov    %eax,%ecx
  80120b:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801211:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  801214:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  80121b:	f6 c6 04             	test   $0x4,%dh
  80121e:	0f 85 72 ff ff ff    	jne    801196 <fork+0x63>
		perm &= ~PTE_W;
  801224:	25 05 0e 00 00       	and    $0xe05,%eax
  801229:	80 cc 08             	or     $0x8,%ah
  80122c:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  801232:	0f 44 c1             	cmove  %ecx,%eax
  801235:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801238:	e9 59 ff ff ff       	jmp    801196 <fork+0x63>
  80123d:	ba 00 00 00 00       	mov    $0x0,%edx
  801242:	0f 4f c2             	cmovg  %edx,%eax
  801245:	e9 32 ff ff ff       	jmp    80117c <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  80124a:	83 ec 04             	sub    $0x4,%esp
  80124d:	6a 07                	push   $0x7
  80124f:	68 00 f0 bf ee       	push   $0xeebff000
  801254:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801257:	57                   	push   %edi
  801258:	e8 86 fb ff ff       	call   800de3 <sys_page_alloc>
	if(r<0) return r;
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	85 c0                	test   %eax,%eax
  801262:	0f 88 14 ff ff ff    	js     80117c <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801268:	83 ec 08             	sub    $0x8,%esp
  80126b:	68 86 24 80 00       	push   $0x802486
  801270:	57                   	push   %edi
  801271:	e8 b8 fc ff ff       	call   800f2e <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801276:	83 c4 10             	add    $0x10,%esp
  801279:	85 c0                	test   %eax,%eax
  80127b:	0f 88 fb fe ff ff    	js     80117c <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801281:	83 ec 08             	sub    $0x8,%esp
  801284:	6a 02                	push   $0x2
  801286:	57                   	push   %edi
  801287:	e8 1e fc ff ff       	call   800eaa <sys_env_set_status>
	if(r<0) return r;
  80128c:	83 c4 10             	add    $0x10,%esp
	return envid;
  80128f:	85 c0                	test   %eax,%eax
  801291:	0f 49 c7             	cmovns %edi,%eax
  801294:	e9 e3 fe ff ff       	jmp    80117c <fork+0x49>

00801299 <sfork>:

// Challenge!
int
sfork(void)
{
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80129f:	68 81 2d 80 00       	push   $0x802d81
  8012a4:	68 a1 00 00 00       	push   $0xa1
  8012a9:	68 48 2d 80 00       	push   $0x802d48
  8012ae:	e8 7f f0 ff ff       	call   800332 <_panic>

008012b3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b9:	05 00 00 00 30       	add    $0x30000000,%eax
  8012be:	c1 e8 0c             	shr    $0xc,%eax
}
  8012c1:	5d                   	pop    %ebp
  8012c2:	c3                   	ret    

008012c3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c9:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8012ce:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012d3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    

008012da <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012e2:	89 c2                	mov    %eax,%edx
  8012e4:	c1 ea 16             	shr    $0x16,%edx
  8012e7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012ee:	f6 c2 01             	test   $0x1,%dl
  8012f1:	74 29                	je     80131c <fd_alloc+0x42>
  8012f3:	89 c2                	mov    %eax,%edx
  8012f5:	c1 ea 0c             	shr    $0xc,%edx
  8012f8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ff:	f6 c2 01             	test   $0x1,%dl
  801302:	74 18                	je     80131c <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801304:	05 00 10 00 00       	add    $0x1000,%eax
  801309:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80130e:	75 d2                	jne    8012e2 <fd_alloc+0x8>
  801310:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801315:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80131a:	eb 05                	jmp    801321 <fd_alloc+0x47>
			return 0;
  80131c:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801321:	8b 55 08             	mov    0x8(%ebp),%edx
  801324:	89 02                	mov    %eax,(%edx)
}
  801326:	89 c8                	mov    %ecx,%eax
  801328:	5d                   	pop    %ebp
  801329:	c3                   	ret    

0080132a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80132a:	55                   	push   %ebp
  80132b:	89 e5                	mov    %esp,%ebp
  80132d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801330:	83 f8 1f             	cmp    $0x1f,%eax
  801333:	77 30                	ja     801365 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801335:	c1 e0 0c             	shl    $0xc,%eax
  801338:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80133d:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801343:	f6 c2 01             	test   $0x1,%dl
  801346:	74 24                	je     80136c <fd_lookup+0x42>
  801348:	89 c2                	mov    %eax,%edx
  80134a:	c1 ea 0c             	shr    $0xc,%edx
  80134d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801354:	f6 c2 01             	test   $0x1,%dl
  801357:	74 1a                	je     801373 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801359:	8b 55 0c             	mov    0xc(%ebp),%edx
  80135c:	89 02                	mov    %eax,(%edx)
	return 0;
  80135e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801363:	5d                   	pop    %ebp
  801364:	c3                   	ret    
		return -E_INVAL;
  801365:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80136a:	eb f7                	jmp    801363 <fd_lookup+0x39>
		return -E_INVAL;
  80136c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801371:	eb f0                	jmp    801363 <fd_lookup+0x39>
  801373:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801378:	eb e9                	jmp    801363 <fd_lookup+0x39>

0080137a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80137a:	55                   	push   %ebp
  80137b:	89 e5                	mov    %esp,%ebp
  80137d:	53                   	push   %ebx
  80137e:	83 ec 04             	sub    $0x4,%esp
  801381:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801384:	b8 00 00 00 00       	mov    $0x0,%eax
  801389:	bb 08 30 80 00       	mov    $0x803008,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80138e:	39 13                	cmp    %edx,(%ebx)
  801390:	74 37                	je     8013c9 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  801392:	83 c0 01             	add    $0x1,%eax
  801395:	8b 1c 85 14 2e 80 00 	mov    0x802e14(,%eax,4),%ebx
  80139c:	85 db                	test   %ebx,%ebx
  80139e:	75 ee                	jne    80138e <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013a0:	a1 00 40 80 00       	mov    0x804000,%eax
  8013a5:	8b 40 48             	mov    0x48(%eax),%eax
  8013a8:	83 ec 04             	sub    $0x4,%esp
  8013ab:	52                   	push   %edx
  8013ac:	50                   	push   %eax
  8013ad:	68 98 2d 80 00       	push   $0x802d98
  8013b2:	e8 56 f0 ff ff       	call   80040d <cprintf>
	*dev = 0;
	return -E_INVAL;
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8013bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c2:	89 1a                	mov    %ebx,(%edx)
}
  8013c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013c7:	c9                   	leave  
  8013c8:	c3                   	ret    
			return 0;
  8013c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ce:	eb ef                	jmp    8013bf <dev_lookup+0x45>

008013d0 <fd_close>:
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	57                   	push   %edi
  8013d4:	56                   	push   %esi
  8013d5:	53                   	push   %ebx
  8013d6:	83 ec 24             	sub    $0x24,%esp
  8013d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8013dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013df:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013e2:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013e3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013e9:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013ec:	50                   	push   %eax
  8013ed:	e8 38 ff ff ff       	call   80132a <fd_lookup>
  8013f2:	89 c3                	mov    %eax,%ebx
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	78 05                	js     801400 <fd_close+0x30>
	    || fd != fd2)
  8013fb:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8013fe:	74 16                	je     801416 <fd_close+0x46>
		return (must_exist ? r : 0);
  801400:	89 f8                	mov    %edi,%eax
  801402:	84 c0                	test   %al,%al
  801404:	b8 00 00 00 00       	mov    $0x0,%eax
  801409:	0f 44 d8             	cmove  %eax,%ebx
}
  80140c:	89 d8                	mov    %ebx,%eax
  80140e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801411:	5b                   	pop    %ebx
  801412:	5e                   	pop    %esi
  801413:	5f                   	pop    %edi
  801414:	5d                   	pop    %ebp
  801415:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801416:	83 ec 08             	sub    $0x8,%esp
  801419:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80141c:	50                   	push   %eax
  80141d:	ff 36                	push   (%esi)
  80141f:	e8 56 ff ff ff       	call   80137a <dev_lookup>
  801424:	89 c3                	mov    %eax,%ebx
  801426:	83 c4 10             	add    $0x10,%esp
  801429:	85 c0                	test   %eax,%eax
  80142b:	78 1a                	js     801447 <fd_close+0x77>
		if (dev->dev_close)
  80142d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801430:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801433:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801438:	85 c0                	test   %eax,%eax
  80143a:	74 0b                	je     801447 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80143c:	83 ec 0c             	sub    $0xc,%esp
  80143f:	56                   	push   %esi
  801440:	ff d0                	call   *%eax
  801442:	89 c3                	mov    %eax,%ebx
  801444:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801447:	83 ec 08             	sub    $0x8,%esp
  80144a:	56                   	push   %esi
  80144b:	6a 00                	push   $0x0
  80144d:	e8 16 fa ff ff       	call   800e68 <sys_page_unmap>
	return r;
  801452:	83 c4 10             	add    $0x10,%esp
  801455:	eb b5                	jmp    80140c <fd_close+0x3c>

00801457 <close>:

int
close(int fdnum)
{
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80145d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801460:	50                   	push   %eax
  801461:	ff 75 08             	push   0x8(%ebp)
  801464:	e8 c1 fe ff ff       	call   80132a <fd_lookup>
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	85 c0                	test   %eax,%eax
  80146e:	79 02                	jns    801472 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801470:	c9                   	leave  
  801471:	c3                   	ret    
		return fd_close(fd, 1);
  801472:	83 ec 08             	sub    $0x8,%esp
  801475:	6a 01                	push   $0x1
  801477:	ff 75 f4             	push   -0xc(%ebp)
  80147a:	e8 51 ff ff ff       	call   8013d0 <fd_close>
  80147f:	83 c4 10             	add    $0x10,%esp
  801482:	eb ec                	jmp    801470 <close+0x19>

00801484 <close_all>:

void
close_all(void)
{
  801484:	55                   	push   %ebp
  801485:	89 e5                	mov    %esp,%ebp
  801487:	53                   	push   %ebx
  801488:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80148b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801490:	83 ec 0c             	sub    $0xc,%esp
  801493:	53                   	push   %ebx
  801494:	e8 be ff ff ff       	call   801457 <close>
	for (i = 0; i < MAXFD; i++)
  801499:	83 c3 01             	add    $0x1,%ebx
  80149c:	83 c4 10             	add    $0x10,%esp
  80149f:	83 fb 20             	cmp    $0x20,%ebx
  8014a2:	75 ec                	jne    801490 <close_all+0xc>
}
  8014a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a7:	c9                   	leave  
  8014a8:	c3                   	ret    

008014a9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014a9:	55                   	push   %ebp
  8014aa:	89 e5                	mov    %esp,%ebp
  8014ac:	57                   	push   %edi
  8014ad:	56                   	push   %esi
  8014ae:	53                   	push   %ebx
  8014af:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014b2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014b5:	50                   	push   %eax
  8014b6:	ff 75 08             	push   0x8(%ebp)
  8014b9:	e8 6c fe ff ff       	call   80132a <fd_lookup>
  8014be:	89 c3                	mov    %eax,%ebx
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	78 7f                	js     801546 <dup+0x9d>
		return r;
	close(newfdnum);
  8014c7:	83 ec 0c             	sub    $0xc,%esp
  8014ca:	ff 75 0c             	push   0xc(%ebp)
  8014cd:	e8 85 ff ff ff       	call   801457 <close>

	newfd = INDEX2FD(newfdnum);
  8014d2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014d5:	c1 e6 0c             	shl    $0xc,%esi
  8014d8:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8014de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014e1:	89 3c 24             	mov    %edi,(%esp)
  8014e4:	e8 da fd ff ff       	call   8012c3 <fd2data>
  8014e9:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014eb:	89 34 24             	mov    %esi,(%esp)
  8014ee:	e8 d0 fd ff ff       	call   8012c3 <fd2data>
  8014f3:	83 c4 10             	add    $0x10,%esp
  8014f6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014f9:	89 d8                	mov    %ebx,%eax
  8014fb:	c1 e8 16             	shr    $0x16,%eax
  8014fe:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801505:	a8 01                	test   $0x1,%al
  801507:	74 11                	je     80151a <dup+0x71>
  801509:	89 d8                	mov    %ebx,%eax
  80150b:	c1 e8 0c             	shr    $0xc,%eax
  80150e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801515:	f6 c2 01             	test   $0x1,%dl
  801518:	75 36                	jne    801550 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80151a:	89 f8                	mov    %edi,%eax
  80151c:	c1 e8 0c             	shr    $0xc,%eax
  80151f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801526:	83 ec 0c             	sub    $0xc,%esp
  801529:	25 07 0e 00 00       	and    $0xe07,%eax
  80152e:	50                   	push   %eax
  80152f:	56                   	push   %esi
  801530:	6a 00                	push   $0x0
  801532:	57                   	push   %edi
  801533:	6a 00                	push   $0x0
  801535:	e8 ec f8 ff ff       	call   800e26 <sys_page_map>
  80153a:	89 c3                	mov    %eax,%ebx
  80153c:	83 c4 20             	add    $0x20,%esp
  80153f:	85 c0                	test   %eax,%eax
  801541:	78 33                	js     801576 <dup+0xcd>
		goto err;

	return newfdnum;
  801543:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801546:	89 d8                	mov    %ebx,%eax
  801548:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80154b:	5b                   	pop    %ebx
  80154c:	5e                   	pop    %esi
  80154d:	5f                   	pop    %edi
  80154e:	5d                   	pop    %ebp
  80154f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801550:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801557:	83 ec 0c             	sub    $0xc,%esp
  80155a:	25 07 0e 00 00       	and    $0xe07,%eax
  80155f:	50                   	push   %eax
  801560:	ff 75 d4             	push   -0x2c(%ebp)
  801563:	6a 00                	push   $0x0
  801565:	53                   	push   %ebx
  801566:	6a 00                	push   $0x0
  801568:	e8 b9 f8 ff ff       	call   800e26 <sys_page_map>
  80156d:	89 c3                	mov    %eax,%ebx
  80156f:	83 c4 20             	add    $0x20,%esp
  801572:	85 c0                	test   %eax,%eax
  801574:	79 a4                	jns    80151a <dup+0x71>
	sys_page_unmap(0, newfd);
  801576:	83 ec 08             	sub    $0x8,%esp
  801579:	56                   	push   %esi
  80157a:	6a 00                	push   $0x0
  80157c:	e8 e7 f8 ff ff       	call   800e68 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801581:	83 c4 08             	add    $0x8,%esp
  801584:	ff 75 d4             	push   -0x2c(%ebp)
  801587:	6a 00                	push   $0x0
  801589:	e8 da f8 ff ff       	call   800e68 <sys_page_unmap>
	return r;
  80158e:	83 c4 10             	add    $0x10,%esp
  801591:	eb b3                	jmp    801546 <dup+0x9d>

00801593 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	56                   	push   %esi
  801597:	53                   	push   %ebx
  801598:	83 ec 18             	sub    $0x18,%esp
  80159b:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80159e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a1:	50                   	push   %eax
  8015a2:	56                   	push   %esi
  8015a3:	e8 82 fd ff ff       	call   80132a <fd_lookup>
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	85 c0                	test   %eax,%eax
  8015ad:	78 3c                	js     8015eb <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015af:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8015b2:	83 ec 08             	sub    $0x8,%esp
  8015b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b8:	50                   	push   %eax
  8015b9:	ff 33                	push   (%ebx)
  8015bb:	e8 ba fd ff ff       	call   80137a <dev_lookup>
  8015c0:	83 c4 10             	add    $0x10,%esp
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	78 24                	js     8015eb <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015c7:	8b 43 08             	mov    0x8(%ebx),%eax
  8015ca:	83 e0 03             	and    $0x3,%eax
  8015cd:	83 f8 01             	cmp    $0x1,%eax
  8015d0:	74 20                	je     8015f2 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8015d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015d5:	8b 40 08             	mov    0x8(%eax),%eax
  8015d8:	85 c0                	test   %eax,%eax
  8015da:	74 37                	je     801613 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015dc:	83 ec 04             	sub    $0x4,%esp
  8015df:	ff 75 10             	push   0x10(%ebp)
  8015e2:	ff 75 0c             	push   0xc(%ebp)
  8015e5:	53                   	push   %ebx
  8015e6:	ff d0                	call   *%eax
  8015e8:	83 c4 10             	add    $0x10,%esp
}
  8015eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ee:	5b                   	pop    %ebx
  8015ef:	5e                   	pop    %esi
  8015f0:	5d                   	pop    %ebp
  8015f1:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f2:	a1 00 40 80 00       	mov    0x804000,%eax
  8015f7:	8b 40 48             	mov    0x48(%eax),%eax
  8015fa:	83 ec 04             	sub    $0x4,%esp
  8015fd:	56                   	push   %esi
  8015fe:	50                   	push   %eax
  8015ff:	68 d9 2d 80 00       	push   $0x802dd9
  801604:	e8 04 ee ff ff       	call   80040d <cprintf>
		return -E_INVAL;
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801611:	eb d8                	jmp    8015eb <read+0x58>
		return -E_NOT_SUPP;
  801613:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801618:	eb d1                	jmp    8015eb <read+0x58>

0080161a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80161a:	55                   	push   %ebp
  80161b:	89 e5                	mov    %esp,%ebp
  80161d:	57                   	push   %edi
  80161e:	56                   	push   %esi
  80161f:	53                   	push   %ebx
  801620:	83 ec 0c             	sub    $0xc,%esp
  801623:	8b 7d 08             	mov    0x8(%ebp),%edi
  801626:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801629:	bb 00 00 00 00       	mov    $0x0,%ebx
  80162e:	eb 02                	jmp    801632 <readn+0x18>
  801630:	01 c3                	add    %eax,%ebx
  801632:	39 f3                	cmp    %esi,%ebx
  801634:	73 21                	jae    801657 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801636:	83 ec 04             	sub    $0x4,%esp
  801639:	89 f0                	mov    %esi,%eax
  80163b:	29 d8                	sub    %ebx,%eax
  80163d:	50                   	push   %eax
  80163e:	89 d8                	mov    %ebx,%eax
  801640:	03 45 0c             	add    0xc(%ebp),%eax
  801643:	50                   	push   %eax
  801644:	57                   	push   %edi
  801645:	e8 49 ff ff ff       	call   801593 <read>
		if (m < 0)
  80164a:	83 c4 10             	add    $0x10,%esp
  80164d:	85 c0                	test   %eax,%eax
  80164f:	78 04                	js     801655 <readn+0x3b>
			return m;
		if (m == 0)
  801651:	75 dd                	jne    801630 <readn+0x16>
  801653:	eb 02                	jmp    801657 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801655:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801657:	89 d8                	mov    %ebx,%eax
  801659:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80165c:	5b                   	pop    %ebx
  80165d:	5e                   	pop    %esi
  80165e:	5f                   	pop    %edi
  80165f:	5d                   	pop    %ebp
  801660:	c3                   	ret    

00801661 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	56                   	push   %esi
  801665:	53                   	push   %ebx
  801666:	83 ec 18             	sub    $0x18,%esp
  801669:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80166c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80166f:	50                   	push   %eax
  801670:	53                   	push   %ebx
  801671:	e8 b4 fc ff ff       	call   80132a <fd_lookup>
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	85 c0                	test   %eax,%eax
  80167b:	78 37                	js     8016b4 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167d:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801680:	83 ec 08             	sub    $0x8,%esp
  801683:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801686:	50                   	push   %eax
  801687:	ff 36                	push   (%esi)
  801689:	e8 ec fc ff ff       	call   80137a <dev_lookup>
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	85 c0                	test   %eax,%eax
  801693:	78 1f                	js     8016b4 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801695:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801699:	74 20                	je     8016bb <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80169b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169e:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	74 37                	je     8016dc <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016a5:	83 ec 04             	sub    $0x4,%esp
  8016a8:	ff 75 10             	push   0x10(%ebp)
  8016ab:	ff 75 0c             	push   0xc(%ebp)
  8016ae:	56                   	push   %esi
  8016af:	ff d0                	call   *%eax
  8016b1:	83 c4 10             	add    $0x10,%esp
}
  8016b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b7:	5b                   	pop    %ebx
  8016b8:	5e                   	pop    %esi
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016bb:	a1 00 40 80 00       	mov    0x804000,%eax
  8016c0:	8b 40 48             	mov    0x48(%eax),%eax
  8016c3:	83 ec 04             	sub    $0x4,%esp
  8016c6:	53                   	push   %ebx
  8016c7:	50                   	push   %eax
  8016c8:	68 f5 2d 80 00       	push   $0x802df5
  8016cd:	e8 3b ed ff ff       	call   80040d <cprintf>
		return -E_INVAL;
  8016d2:	83 c4 10             	add    $0x10,%esp
  8016d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016da:	eb d8                	jmp    8016b4 <write+0x53>
		return -E_NOT_SUPP;
  8016dc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016e1:	eb d1                	jmp    8016b4 <write+0x53>

008016e3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016e3:	55                   	push   %ebp
  8016e4:	89 e5                	mov    %esp,%ebp
  8016e6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016e9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ec:	50                   	push   %eax
  8016ed:	ff 75 08             	push   0x8(%ebp)
  8016f0:	e8 35 fc ff ff       	call   80132a <fd_lookup>
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	85 c0                	test   %eax,%eax
  8016fa:	78 0e                	js     80170a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801702:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801705:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80170a:	c9                   	leave  
  80170b:	c3                   	ret    

0080170c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80170c:	55                   	push   %ebp
  80170d:	89 e5                	mov    %esp,%ebp
  80170f:	56                   	push   %esi
  801710:	53                   	push   %ebx
  801711:	83 ec 18             	sub    $0x18,%esp
  801714:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801717:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171a:	50                   	push   %eax
  80171b:	53                   	push   %ebx
  80171c:	e8 09 fc ff ff       	call   80132a <fd_lookup>
  801721:	83 c4 10             	add    $0x10,%esp
  801724:	85 c0                	test   %eax,%eax
  801726:	78 34                	js     80175c <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801728:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80172b:	83 ec 08             	sub    $0x8,%esp
  80172e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801731:	50                   	push   %eax
  801732:	ff 36                	push   (%esi)
  801734:	e8 41 fc ff ff       	call   80137a <dev_lookup>
  801739:	83 c4 10             	add    $0x10,%esp
  80173c:	85 c0                	test   %eax,%eax
  80173e:	78 1c                	js     80175c <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801740:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801744:	74 1d                	je     801763 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801746:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801749:	8b 40 18             	mov    0x18(%eax),%eax
  80174c:	85 c0                	test   %eax,%eax
  80174e:	74 34                	je     801784 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801750:	83 ec 08             	sub    $0x8,%esp
  801753:	ff 75 0c             	push   0xc(%ebp)
  801756:	56                   	push   %esi
  801757:	ff d0                	call   *%eax
  801759:	83 c4 10             	add    $0x10,%esp
}
  80175c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80175f:	5b                   	pop    %ebx
  801760:	5e                   	pop    %esi
  801761:	5d                   	pop    %ebp
  801762:	c3                   	ret    
			thisenv->env_id, fdnum);
  801763:	a1 00 40 80 00       	mov    0x804000,%eax
  801768:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80176b:	83 ec 04             	sub    $0x4,%esp
  80176e:	53                   	push   %ebx
  80176f:	50                   	push   %eax
  801770:	68 b8 2d 80 00       	push   $0x802db8
  801775:	e8 93 ec ff ff       	call   80040d <cprintf>
		return -E_INVAL;
  80177a:	83 c4 10             	add    $0x10,%esp
  80177d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801782:	eb d8                	jmp    80175c <ftruncate+0x50>
		return -E_NOT_SUPP;
  801784:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801789:	eb d1                	jmp    80175c <ftruncate+0x50>

0080178b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80178b:	55                   	push   %ebp
  80178c:	89 e5                	mov    %esp,%ebp
  80178e:	56                   	push   %esi
  80178f:	53                   	push   %ebx
  801790:	83 ec 18             	sub    $0x18,%esp
  801793:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801796:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801799:	50                   	push   %eax
  80179a:	ff 75 08             	push   0x8(%ebp)
  80179d:	e8 88 fb ff ff       	call   80132a <fd_lookup>
  8017a2:	83 c4 10             	add    $0x10,%esp
  8017a5:	85 c0                	test   %eax,%eax
  8017a7:	78 49                	js     8017f2 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a9:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8017ac:	83 ec 08             	sub    $0x8,%esp
  8017af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b2:	50                   	push   %eax
  8017b3:	ff 36                	push   (%esi)
  8017b5:	e8 c0 fb ff ff       	call   80137a <dev_lookup>
  8017ba:	83 c4 10             	add    $0x10,%esp
  8017bd:	85 c0                	test   %eax,%eax
  8017bf:	78 31                	js     8017f2 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8017c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017c4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017c8:	74 2f                	je     8017f9 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017ca:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017cd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017d4:	00 00 00 
	stat->st_isdir = 0;
  8017d7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017de:	00 00 00 
	stat->st_dev = dev;
  8017e1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017e7:	83 ec 08             	sub    $0x8,%esp
  8017ea:	53                   	push   %ebx
  8017eb:	56                   	push   %esi
  8017ec:	ff 50 14             	call   *0x14(%eax)
  8017ef:	83 c4 10             	add    $0x10,%esp
}
  8017f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017f5:	5b                   	pop    %ebx
  8017f6:	5e                   	pop    %esi
  8017f7:	5d                   	pop    %ebp
  8017f8:	c3                   	ret    
		return -E_NOT_SUPP;
  8017f9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017fe:	eb f2                	jmp    8017f2 <fstat+0x67>

00801800 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	56                   	push   %esi
  801804:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801805:	83 ec 08             	sub    $0x8,%esp
  801808:	6a 00                	push   $0x0
  80180a:	ff 75 08             	push   0x8(%ebp)
  80180d:	e8 e4 01 00 00       	call   8019f6 <open>
  801812:	89 c3                	mov    %eax,%ebx
  801814:	83 c4 10             	add    $0x10,%esp
  801817:	85 c0                	test   %eax,%eax
  801819:	78 1b                	js     801836 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80181b:	83 ec 08             	sub    $0x8,%esp
  80181e:	ff 75 0c             	push   0xc(%ebp)
  801821:	50                   	push   %eax
  801822:	e8 64 ff ff ff       	call   80178b <fstat>
  801827:	89 c6                	mov    %eax,%esi
	close(fd);
  801829:	89 1c 24             	mov    %ebx,(%esp)
  80182c:	e8 26 fc ff ff       	call   801457 <close>
	return r;
  801831:	83 c4 10             	add    $0x10,%esp
  801834:	89 f3                	mov    %esi,%ebx
}
  801836:	89 d8                	mov    %ebx,%eax
  801838:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80183b:	5b                   	pop    %ebx
  80183c:	5e                   	pop    %esi
  80183d:	5d                   	pop    %ebp
  80183e:	c3                   	ret    

0080183f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	56                   	push   %esi
  801843:	53                   	push   %ebx
  801844:	89 c6                	mov    %eax,%esi
  801846:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801848:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80184f:	74 27                	je     801878 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801851:	6a 07                	push   $0x7
  801853:	68 00 50 80 00       	push   $0x805000
  801858:	56                   	push   %esi
  801859:	ff 35 00 60 80 00    	push   0x806000
  80185f:	e8 af 0c 00 00       	call   802513 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801864:	83 c4 0c             	add    $0xc,%esp
  801867:	6a 00                	push   $0x0
  801869:	53                   	push   %ebx
  80186a:	6a 00                	push   $0x0
  80186c:	e8 3b 0c 00 00       	call   8024ac <ipc_recv>
}
  801871:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801874:	5b                   	pop    %ebx
  801875:	5e                   	pop    %esi
  801876:	5d                   	pop    %ebp
  801877:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801878:	83 ec 0c             	sub    $0xc,%esp
  80187b:	6a 01                	push   $0x1
  80187d:	e8 e5 0c 00 00       	call   802567 <ipc_find_env>
  801882:	a3 00 60 80 00       	mov    %eax,0x806000
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	eb c5                	jmp    801851 <fsipc+0x12>

0080188c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801892:	8b 45 08             	mov    0x8(%ebp),%eax
  801895:	8b 40 0c             	mov    0xc(%eax),%eax
  801898:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80189d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018aa:	b8 02 00 00 00       	mov    $0x2,%eax
  8018af:	e8 8b ff ff ff       	call   80183f <fsipc>
}
  8018b4:	c9                   	leave  
  8018b5:	c3                   	ret    

008018b6 <devfile_flush>:
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018cc:	b8 06 00 00 00       	mov    $0x6,%eax
  8018d1:	e8 69 ff ff ff       	call   80183f <fsipc>
}
  8018d6:	c9                   	leave  
  8018d7:	c3                   	ret    

008018d8 <devfile_stat>:
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	53                   	push   %ebx
  8018dc:	83 ec 04             	sub    $0x4,%esp
  8018df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f2:	b8 05 00 00 00       	mov    $0x5,%eax
  8018f7:	e8 43 ff ff ff       	call   80183f <fsipc>
  8018fc:	85 c0                	test   %eax,%eax
  8018fe:	78 2c                	js     80192c <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801900:	83 ec 08             	sub    $0x8,%esp
  801903:	68 00 50 80 00       	push   $0x805000
  801908:	53                   	push   %ebx
  801909:	e8 d9 f0 ff ff       	call   8009e7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80190e:	a1 80 50 80 00       	mov    0x805080,%eax
  801913:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801919:	a1 84 50 80 00       	mov    0x805084,%eax
  80191e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801924:	83 c4 10             	add    $0x10,%esp
  801927:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80192c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192f:	c9                   	leave  
  801930:	c3                   	ret    

00801931 <devfile_write>:
{
  801931:	55                   	push   %ebp
  801932:	89 e5                	mov    %esp,%ebp
  801934:	83 ec 0c             	sub    $0xc,%esp
  801937:	8b 45 10             	mov    0x10(%ebp),%eax
  80193a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80193f:	39 d0                	cmp    %edx,%eax
  801941:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801944:	8b 55 08             	mov    0x8(%ebp),%edx
  801947:	8b 52 0c             	mov    0xc(%edx),%edx
  80194a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801950:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801955:	50                   	push   %eax
  801956:	ff 75 0c             	push   0xc(%ebp)
  801959:	68 08 50 80 00       	push   $0x805008
  80195e:	e8 1a f2 ff ff       	call   800b7d <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801963:	ba 00 00 00 00       	mov    $0x0,%edx
  801968:	b8 04 00 00 00       	mov    $0x4,%eax
  80196d:	e8 cd fe ff ff       	call   80183f <fsipc>
}
  801972:	c9                   	leave  
  801973:	c3                   	ret    

00801974 <devfile_read>:
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	56                   	push   %esi
  801978:	53                   	push   %ebx
  801979:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80197c:	8b 45 08             	mov    0x8(%ebp),%eax
  80197f:	8b 40 0c             	mov    0xc(%eax),%eax
  801982:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801987:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80198d:	ba 00 00 00 00       	mov    $0x0,%edx
  801992:	b8 03 00 00 00       	mov    $0x3,%eax
  801997:	e8 a3 fe ff ff       	call   80183f <fsipc>
  80199c:	89 c3                	mov    %eax,%ebx
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	78 1f                	js     8019c1 <devfile_read+0x4d>
	assert(r <= n);
  8019a2:	39 f0                	cmp    %esi,%eax
  8019a4:	77 24                	ja     8019ca <devfile_read+0x56>
	assert(r <= PGSIZE);
  8019a6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019ab:	7f 33                	jg     8019e0 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019ad:	83 ec 04             	sub    $0x4,%esp
  8019b0:	50                   	push   %eax
  8019b1:	68 00 50 80 00       	push   $0x805000
  8019b6:	ff 75 0c             	push   0xc(%ebp)
  8019b9:	e8 bf f1 ff ff       	call   800b7d <memmove>
	return r;
  8019be:	83 c4 10             	add    $0x10,%esp
}
  8019c1:	89 d8                	mov    %ebx,%eax
  8019c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c6:	5b                   	pop    %ebx
  8019c7:	5e                   	pop    %esi
  8019c8:	5d                   	pop    %ebp
  8019c9:	c3                   	ret    
	assert(r <= n);
  8019ca:	68 28 2e 80 00       	push   $0x802e28
  8019cf:	68 2f 2e 80 00       	push   $0x802e2f
  8019d4:	6a 7c                	push   $0x7c
  8019d6:	68 44 2e 80 00       	push   $0x802e44
  8019db:	e8 52 e9 ff ff       	call   800332 <_panic>
	assert(r <= PGSIZE);
  8019e0:	68 4f 2e 80 00       	push   $0x802e4f
  8019e5:	68 2f 2e 80 00       	push   $0x802e2f
  8019ea:	6a 7d                	push   $0x7d
  8019ec:	68 44 2e 80 00       	push   $0x802e44
  8019f1:	e8 3c e9 ff ff       	call   800332 <_panic>

008019f6 <open>:
{
  8019f6:	55                   	push   %ebp
  8019f7:	89 e5                	mov    %esp,%ebp
  8019f9:	56                   	push   %esi
  8019fa:	53                   	push   %ebx
  8019fb:	83 ec 1c             	sub    $0x1c,%esp
  8019fe:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801a01:	56                   	push   %esi
  801a02:	e8 a5 ef ff ff       	call   8009ac <strlen>
  801a07:	83 c4 10             	add    $0x10,%esp
  801a0a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a0f:	7f 6c                	jg     801a7d <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801a11:	83 ec 0c             	sub    $0xc,%esp
  801a14:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a17:	50                   	push   %eax
  801a18:	e8 bd f8 ff ff       	call   8012da <fd_alloc>
  801a1d:	89 c3                	mov    %eax,%ebx
  801a1f:	83 c4 10             	add    $0x10,%esp
  801a22:	85 c0                	test   %eax,%eax
  801a24:	78 3c                	js     801a62 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801a26:	83 ec 08             	sub    $0x8,%esp
  801a29:	56                   	push   %esi
  801a2a:	68 00 50 80 00       	push   $0x805000
  801a2f:	e8 b3 ef ff ff       	call   8009e7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a37:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a3f:	b8 01 00 00 00       	mov    $0x1,%eax
  801a44:	e8 f6 fd ff ff       	call   80183f <fsipc>
  801a49:	89 c3                	mov    %eax,%ebx
  801a4b:	83 c4 10             	add    $0x10,%esp
  801a4e:	85 c0                	test   %eax,%eax
  801a50:	78 19                	js     801a6b <open+0x75>
	return fd2num(fd);
  801a52:	83 ec 0c             	sub    $0xc,%esp
  801a55:	ff 75 f4             	push   -0xc(%ebp)
  801a58:	e8 56 f8 ff ff       	call   8012b3 <fd2num>
  801a5d:	89 c3                	mov    %eax,%ebx
  801a5f:	83 c4 10             	add    $0x10,%esp
}
  801a62:	89 d8                	mov    %ebx,%eax
  801a64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a67:	5b                   	pop    %ebx
  801a68:	5e                   	pop    %esi
  801a69:	5d                   	pop    %ebp
  801a6a:	c3                   	ret    
		fd_close(fd, 0);
  801a6b:	83 ec 08             	sub    $0x8,%esp
  801a6e:	6a 00                	push   $0x0
  801a70:	ff 75 f4             	push   -0xc(%ebp)
  801a73:	e8 58 f9 ff ff       	call   8013d0 <fd_close>
		return r;
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	eb e5                	jmp    801a62 <open+0x6c>
		return -E_BAD_PATH;
  801a7d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a82:	eb de                	jmp    801a62 <open+0x6c>

00801a84 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a8a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8f:	b8 08 00 00 00       	mov    $0x8,%eax
  801a94:	e8 a6 fd ff ff       	call   80183f <fsipc>
}
  801a99:	c9                   	leave  
  801a9a:	c3                   	ret    

00801a9b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801aa1:	68 5b 2e 80 00       	push   $0x802e5b
  801aa6:	ff 75 0c             	push   0xc(%ebp)
  801aa9:	e8 39 ef ff ff       	call   8009e7 <strcpy>
	return 0;
}
  801aae:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab3:	c9                   	leave  
  801ab4:	c3                   	ret    

00801ab5 <devsock_close>:
{
  801ab5:	55                   	push   %ebp
  801ab6:	89 e5                	mov    %esp,%ebp
  801ab8:	53                   	push   %ebx
  801ab9:	83 ec 10             	sub    $0x10,%esp
  801abc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801abf:	53                   	push   %ebx
  801ac0:	e8 db 0a 00 00       	call   8025a0 <pageref>
  801ac5:	89 c2                	mov    %eax,%edx
  801ac7:	83 c4 10             	add    $0x10,%esp
		return 0;
  801aca:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801acf:	83 fa 01             	cmp    $0x1,%edx
  801ad2:	74 05                	je     801ad9 <devsock_close+0x24>
}
  801ad4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ad7:	c9                   	leave  
  801ad8:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801ad9:	83 ec 0c             	sub    $0xc,%esp
  801adc:	ff 73 0c             	push   0xc(%ebx)
  801adf:	e8 b7 02 00 00       	call   801d9b <nsipc_close>
  801ae4:	83 c4 10             	add    $0x10,%esp
  801ae7:	eb eb                	jmp    801ad4 <devsock_close+0x1f>

00801ae9 <devsock_write>:
{
  801ae9:	55                   	push   %ebp
  801aea:	89 e5                	mov    %esp,%ebp
  801aec:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801aef:	6a 00                	push   $0x0
  801af1:	ff 75 10             	push   0x10(%ebp)
  801af4:	ff 75 0c             	push   0xc(%ebp)
  801af7:	8b 45 08             	mov    0x8(%ebp),%eax
  801afa:	ff 70 0c             	push   0xc(%eax)
  801afd:	e8 79 03 00 00       	call   801e7b <nsipc_send>
}
  801b02:	c9                   	leave  
  801b03:	c3                   	ret    

00801b04 <devsock_read>:
{
  801b04:	55                   	push   %ebp
  801b05:	89 e5                	mov    %esp,%ebp
  801b07:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b0a:	6a 00                	push   $0x0
  801b0c:	ff 75 10             	push   0x10(%ebp)
  801b0f:	ff 75 0c             	push   0xc(%ebp)
  801b12:	8b 45 08             	mov    0x8(%ebp),%eax
  801b15:	ff 70 0c             	push   0xc(%eax)
  801b18:	e8 ef 02 00 00       	call   801e0c <nsipc_recv>
}
  801b1d:	c9                   	leave  
  801b1e:	c3                   	ret    

00801b1f <fd2sockid>:
{
  801b1f:	55                   	push   %ebp
  801b20:	89 e5                	mov    %esp,%ebp
  801b22:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b25:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b28:	52                   	push   %edx
  801b29:	50                   	push   %eax
  801b2a:	e8 fb f7 ff ff       	call   80132a <fd_lookup>
  801b2f:	83 c4 10             	add    $0x10,%esp
  801b32:	85 c0                	test   %eax,%eax
  801b34:	78 10                	js     801b46 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801b36:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b39:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  801b3f:	39 08                	cmp    %ecx,(%eax)
  801b41:	75 05                	jne    801b48 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801b43:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801b46:	c9                   	leave  
  801b47:	c3                   	ret    
		return -E_NOT_SUPP;
  801b48:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b4d:	eb f7                	jmp    801b46 <fd2sockid+0x27>

00801b4f <alloc_sockfd>:
{
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	56                   	push   %esi
  801b53:	53                   	push   %ebx
  801b54:	83 ec 1c             	sub    $0x1c,%esp
  801b57:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801b59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b5c:	50                   	push   %eax
  801b5d:	e8 78 f7 ff ff       	call   8012da <fd_alloc>
  801b62:	89 c3                	mov    %eax,%ebx
  801b64:	83 c4 10             	add    $0x10,%esp
  801b67:	85 c0                	test   %eax,%eax
  801b69:	78 43                	js     801bae <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b6b:	83 ec 04             	sub    $0x4,%esp
  801b6e:	68 07 04 00 00       	push   $0x407
  801b73:	ff 75 f4             	push   -0xc(%ebp)
  801b76:	6a 00                	push   $0x0
  801b78:	e8 66 f2 ff ff       	call   800de3 <sys_page_alloc>
  801b7d:	89 c3                	mov    %eax,%ebx
  801b7f:	83 c4 10             	add    $0x10,%esp
  801b82:	85 c0                	test   %eax,%eax
  801b84:	78 28                	js     801bae <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801b86:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b89:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801b8f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b94:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b9b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b9e:	83 ec 0c             	sub    $0xc,%esp
  801ba1:	50                   	push   %eax
  801ba2:	e8 0c f7 ff ff       	call   8012b3 <fd2num>
  801ba7:	89 c3                	mov    %eax,%ebx
  801ba9:	83 c4 10             	add    $0x10,%esp
  801bac:	eb 0c                	jmp    801bba <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801bae:	83 ec 0c             	sub    $0xc,%esp
  801bb1:	56                   	push   %esi
  801bb2:	e8 e4 01 00 00       	call   801d9b <nsipc_close>
		return r;
  801bb7:	83 c4 10             	add    $0x10,%esp
}
  801bba:	89 d8                	mov    %ebx,%eax
  801bbc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bbf:	5b                   	pop    %ebx
  801bc0:	5e                   	pop    %esi
  801bc1:	5d                   	pop    %ebp
  801bc2:	c3                   	ret    

00801bc3 <accept>:
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
  801bc6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcc:	e8 4e ff ff ff       	call   801b1f <fd2sockid>
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	78 1b                	js     801bf0 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bd5:	83 ec 04             	sub    $0x4,%esp
  801bd8:	ff 75 10             	push   0x10(%ebp)
  801bdb:	ff 75 0c             	push   0xc(%ebp)
  801bde:	50                   	push   %eax
  801bdf:	e8 0e 01 00 00       	call   801cf2 <nsipc_accept>
  801be4:	83 c4 10             	add    $0x10,%esp
  801be7:	85 c0                	test   %eax,%eax
  801be9:	78 05                	js     801bf0 <accept+0x2d>
	return alloc_sockfd(r);
  801beb:	e8 5f ff ff ff       	call   801b4f <alloc_sockfd>
}
  801bf0:	c9                   	leave  
  801bf1:	c3                   	ret    

00801bf2 <bind>:
{
  801bf2:	55                   	push   %ebp
  801bf3:	89 e5                	mov    %esp,%ebp
  801bf5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  801bfb:	e8 1f ff ff ff       	call   801b1f <fd2sockid>
  801c00:	85 c0                	test   %eax,%eax
  801c02:	78 12                	js     801c16 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801c04:	83 ec 04             	sub    $0x4,%esp
  801c07:	ff 75 10             	push   0x10(%ebp)
  801c0a:	ff 75 0c             	push   0xc(%ebp)
  801c0d:	50                   	push   %eax
  801c0e:	e8 31 01 00 00       	call   801d44 <nsipc_bind>
  801c13:	83 c4 10             	add    $0x10,%esp
}
  801c16:	c9                   	leave  
  801c17:	c3                   	ret    

00801c18 <shutdown>:
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c21:	e8 f9 fe ff ff       	call   801b1f <fd2sockid>
  801c26:	85 c0                	test   %eax,%eax
  801c28:	78 0f                	js     801c39 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801c2a:	83 ec 08             	sub    $0x8,%esp
  801c2d:	ff 75 0c             	push   0xc(%ebp)
  801c30:	50                   	push   %eax
  801c31:	e8 43 01 00 00       	call   801d79 <nsipc_shutdown>
  801c36:	83 c4 10             	add    $0x10,%esp
}
  801c39:	c9                   	leave  
  801c3a:	c3                   	ret    

00801c3b <connect>:
{
  801c3b:	55                   	push   %ebp
  801c3c:	89 e5                	mov    %esp,%ebp
  801c3e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c41:	8b 45 08             	mov    0x8(%ebp),%eax
  801c44:	e8 d6 fe ff ff       	call   801b1f <fd2sockid>
  801c49:	85 c0                	test   %eax,%eax
  801c4b:	78 12                	js     801c5f <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801c4d:	83 ec 04             	sub    $0x4,%esp
  801c50:	ff 75 10             	push   0x10(%ebp)
  801c53:	ff 75 0c             	push   0xc(%ebp)
  801c56:	50                   	push   %eax
  801c57:	e8 59 01 00 00       	call   801db5 <nsipc_connect>
  801c5c:	83 c4 10             	add    $0x10,%esp
}
  801c5f:	c9                   	leave  
  801c60:	c3                   	ret    

00801c61 <listen>:
{
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c67:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6a:	e8 b0 fe ff ff       	call   801b1f <fd2sockid>
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	78 0f                	js     801c82 <listen+0x21>
	return nsipc_listen(r, backlog);
  801c73:	83 ec 08             	sub    $0x8,%esp
  801c76:	ff 75 0c             	push   0xc(%ebp)
  801c79:	50                   	push   %eax
  801c7a:	e8 6b 01 00 00       	call   801dea <nsipc_listen>
  801c7f:	83 c4 10             	add    $0x10,%esp
}
  801c82:	c9                   	leave  
  801c83:	c3                   	ret    

00801c84 <socket>:

int
socket(int domain, int type, int protocol)
{
  801c84:	55                   	push   %ebp
  801c85:	89 e5                	mov    %esp,%ebp
  801c87:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c8a:	ff 75 10             	push   0x10(%ebp)
  801c8d:	ff 75 0c             	push   0xc(%ebp)
  801c90:	ff 75 08             	push   0x8(%ebp)
  801c93:	e8 41 02 00 00       	call   801ed9 <nsipc_socket>
  801c98:	83 c4 10             	add    $0x10,%esp
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	78 05                	js     801ca4 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c9f:	e8 ab fe ff ff       	call   801b4f <alloc_sockfd>
}
  801ca4:	c9                   	leave  
  801ca5:	c3                   	ret    

00801ca6 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
  801ca9:	53                   	push   %ebx
  801caa:	83 ec 04             	sub    $0x4,%esp
  801cad:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801caf:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801cb6:	74 26                	je     801cde <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801cb8:	6a 07                	push   $0x7
  801cba:	68 00 70 80 00       	push   $0x807000
  801cbf:	53                   	push   %ebx
  801cc0:	ff 35 00 80 80 00    	push   0x808000
  801cc6:	e8 48 08 00 00       	call   802513 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ccb:	83 c4 0c             	add    $0xc,%esp
  801cce:	6a 00                	push   $0x0
  801cd0:	6a 00                	push   $0x0
  801cd2:	6a 00                	push   $0x0
  801cd4:	e8 d3 07 00 00       	call   8024ac <ipc_recv>
}
  801cd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cdc:	c9                   	leave  
  801cdd:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801cde:	83 ec 0c             	sub    $0xc,%esp
  801ce1:	6a 02                	push   $0x2
  801ce3:	e8 7f 08 00 00       	call   802567 <ipc_find_env>
  801ce8:	a3 00 80 80 00       	mov    %eax,0x808000
  801ced:	83 c4 10             	add    $0x10,%esp
  801cf0:	eb c6                	jmp    801cb8 <nsipc+0x12>

00801cf2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cf2:	55                   	push   %ebp
  801cf3:	89 e5                	mov    %esp,%ebp
  801cf5:	56                   	push   %esi
  801cf6:	53                   	push   %ebx
  801cf7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801cfa:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfd:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d02:	8b 06                	mov    (%esi),%eax
  801d04:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d09:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0e:	e8 93 ff ff ff       	call   801ca6 <nsipc>
  801d13:	89 c3                	mov    %eax,%ebx
  801d15:	85 c0                	test   %eax,%eax
  801d17:	79 09                	jns    801d22 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801d19:	89 d8                	mov    %ebx,%eax
  801d1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d1e:	5b                   	pop    %ebx
  801d1f:	5e                   	pop    %esi
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d22:	83 ec 04             	sub    $0x4,%esp
  801d25:	ff 35 10 70 80 00    	push   0x807010
  801d2b:	68 00 70 80 00       	push   $0x807000
  801d30:	ff 75 0c             	push   0xc(%ebp)
  801d33:	e8 45 ee ff ff       	call   800b7d <memmove>
		*addrlen = ret->ret_addrlen;
  801d38:	a1 10 70 80 00       	mov    0x807010,%eax
  801d3d:	89 06                	mov    %eax,(%esi)
  801d3f:	83 c4 10             	add    $0x10,%esp
	return r;
  801d42:	eb d5                	jmp    801d19 <nsipc_accept+0x27>

00801d44 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
  801d47:	53                   	push   %ebx
  801d48:	83 ec 08             	sub    $0x8,%esp
  801d4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d51:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d56:	53                   	push   %ebx
  801d57:	ff 75 0c             	push   0xc(%ebp)
  801d5a:	68 04 70 80 00       	push   $0x807004
  801d5f:	e8 19 ee ff ff       	call   800b7d <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d64:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801d6a:	b8 02 00 00 00       	mov    $0x2,%eax
  801d6f:	e8 32 ff ff ff       	call   801ca6 <nsipc>
}
  801d74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d77:	c9                   	leave  
  801d78:	c3                   	ret    

00801d79 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d79:	55                   	push   %ebp
  801d7a:	89 e5                	mov    %esp,%ebp
  801d7c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801d82:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801d87:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d8a:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801d8f:	b8 03 00 00 00       	mov    $0x3,%eax
  801d94:	e8 0d ff ff ff       	call   801ca6 <nsipc>
}
  801d99:	c9                   	leave  
  801d9a:	c3                   	ret    

00801d9b <nsipc_close>:

int
nsipc_close(int s)
{
  801d9b:	55                   	push   %ebp
  801d9c:	89 e5                	mov    %esp,%ebp
  801d9e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801da1:	8b 45 08             	mov    0x8(%ebp),%eax
  801da4:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801da9:	b8 04 00 00 00       	mov    $0x4,%eax
  801dae:	e8 f3 fe ff ff       	call   801ca6 <nsipc>
}
  801db3:	c9                   	leave  
  801db4:	c3                   	ret    

00801db5 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	53                   	push   %ebx
  801db9:	83 ec 08             	sub    $0x8,%esp
  801dbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801dbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc2:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801dc7:	53                   	push   %ebx
  801dc8:	ff 75 0c             	push   0xc(%ebp)
  801dcb:	68 04 70 80 00       	push   $0x807004
  801dd0:	e8 a8 ed ff ff       	call   800b7d <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801dd5:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801ddb:	b8 05 00 00 00       	mov    $0x5,%eax
  801de0:	e8 c1 fe ff ff       	call   801ca6 <nsipc>
}
  801de5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801de8:	c9                   	leave  
  801de9:	c3                   	ret    

00801dea <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801dea:	55                   	push   %ebp
  801deb:	89 e5                	mov    %esp,%ebp
  801ded:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801df0:	8b 45 08             	mov    0x8(%ebp),%eax
  801df3:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801df8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dfb:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801e00:	b8 06 00 00 00       	mov    $0x6,%eax
  801e05:	e8 9c fe ff ff       	call   801ca6 <nsipc>
}
  801e0a:	c9                   	leave  
  801e0b:	c3                   	ret    

00801e0c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e0c:	55                   	push   %ebp
  801e0d:	89 e5                	mov    %esp,%ebp
  801e0f:	56                   	push   %esi
  801e10:	53                   	push   %ebx
  801e11:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e14:	8b 45 08             	mov    0x8(%ebp),%eax
  801e17:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801e1c:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801e22:	8b 45 14             	mov    0x14(%ebp),%eax
  801e25:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e2a:	b8 07 00 00 00       	mov    $0x7,%eax
  801e2f:	e8 72 fe ff ff       	call   801ca6 <nsipc>
  801e34:	89 c3                	mov    %eax,%ebx
  801e36:	85 c0                	test   %eax,%eax
  801e38:	78 22                	js     801e5c <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801e3a:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801e3f:	39 c6                	cmp    %eax,%esi
  801e41:	0f 4e c6             	cmovle %esi,%eax
  801e44:	39 c3                	cmp    %eax,%ebx
  801e46:	7f 1d                	jg     801e65 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e48:	83 ec 04             	sub    $0x4,%esp
  801e4b:	53                   	push   %ebx
  801e4c:	68 00 70 80 00       	push   $0x807000
  801e51:	ff 75 0c             	push   0xc(%ebp)
  801e54:	e8 24 ed ff ff       	call   800b7d <memmove>
  801e59:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e5c:	89 d8                	mov    %ebx,%eax
  801e5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e61:	5b                   	pop    %ebx
  801e62:	5e                   	pop    %esi
  801e63:	5d                   	pop    %ebp
  801e64:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801e65:	68 67 2e 80 00       	push   $0x802e67
  801e6a:	68 2f 2e 80 00       	push   $0x802e2f
  801e6f:	6a 62                	push   $0x62
  801e71:	68 7c 2e 80 00       	push   $0x802e7c
  801e76:	e8 b7 e4 ff ff       	call   800332 <_panic>

00801e7b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e7b:	55                   	push   %ebp
  801e7c:	89 e5                	mov    %esp,%ebp
  801e7e:	53                   	push   %ebx
  801e7f:	83 ec 04             	sub    $0x4,%esp
  801e82:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e85:	8b 45 08             	mov    0x8(%ebp),%eax
  801e88:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801e8d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e93:	7f 2e                	jg     801ec3 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e95:	83 ec 04             	sub    $0x4,%esp
  801e98:	53                   	push   %ebx
  801e99:	ff 75 0c             	push   0xc(%ebp)
  801e9c:	68 0c 70 80 00       	push   $0x80700c
  801ea1:	e8 d7 ec ff ff       	call   800b7d <memmove>
	nsipcbuf.send.req_size = size;
  801ea6:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801eac:	8b 45 14             	mov    0x14(%ebp),%eax
  801eaf:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801eb4:	b8 08 00 00 00       	mov    $0x8,%eax
  801eb9:	e8 e8 fd ff ff       	call   801ca6 <nsipc>
}
  801ebe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ec1:	c9                   	leave  
  801ec2:	c3                   	ret    
	assert(size < 1600);
  801ec3:	68 88 2e 80 00       	push   $0x802e88
  801ec8:	68 2f 2e 80 00       	push   $0x802e2f
  801ecd:	6a 6d                	push   $0x6d
  801ecf:	68 7c 2e 80 00       	push   $0x802e7c
  801ed4:	e8 59 e4 ff ff       	call   800332 <_panic>

00801ed9 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801edf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801ee7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eea:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801eef:	8b 45 10             	mov    0x10(%ebp),%eax
  801ef2:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801ef7:	b8 09 00 00 00       	mov    $0x9,%eax
  801efc:	e8 a5 fd ff ff       	call   801ca6 <nsipc>
}
  801f01:	c9                   	leave  
  801f02:	c3                   	ret    

00801f03 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f03:	55                   	push   %ebp
  801f04:	89 e5                	mov    %esp,%ebp
  801f06:	56                   	push   %esi
  801f07:	53                   	push   %ebx
  801f08:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f0b:	83 ec 0c             	sub    $0xc,%esp
  801f0e:	ff 75 08             	push   0x8(%ebp)
  801f11:	e8 ad f3 ff ff       	call   8012c3 <fd2data>
  801f16:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f18:	83 c4 08             	add    $0x8,%esp
  801f1b:	68 94 2e 80 00       	push   $0x802e94
  801f20:	53                   	push   %ebx
  801f21:	e8 c1 ea ff ff       	call   8009e7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f26:	8b 46 04             	mov    0x4(%esi),%eax
  801f29:	2b 06                	sub    (%esi),%eax
  801f2b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f31:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f38:	00 00 00 
	stat->st_dev = &devpipe;
  801f3b:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801f42:	30 80 00 
	return 0;
}
  801f45:	b8 00 00 00 00       	mov    $0x0,%eax
  801f4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f4d:	5b                   	pop    %ebx
  801f4e:	5e                   	pop    %esi
  801f4f:	5d                   	pop    %ebp
  801f50:	c3                   	ret    

00801f51 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f51:	55                   	push   %ebp
  801f52:	89 e5                	mov    %esp,%ebp
  801f54:	53                   	push   %ebx
  801f55:	83 ec 0c             	sub    $0xc,%esp
  801f58:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f5b:	53                   	push   %ebx
  801f5c:	6a 00                	push   $0x0
  801f5e:	e8 05 ef ff ff       	call   800e68 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f63:	89 1c 24             	mov    %ebx,(%esp)
  801f66:	e8 58 f3 ff ff       	call   8012c3 <fd2data>
  801f6b:	83 c4 08             	add    $0x8,%esp
  801f6e:	50                   	push   %eax
  801f6f:	6a 00                	push   $0x0
  801f71:	e8 f2 ee ff ff       	call   800e68 <sys_page_unmap>
}
  801f76:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f79:	c9                   	leave  
  801f7a:	c3                   	ret    

00801f7b <_pipeisclosed>:
{
  801f7b:	55                   	push   %ebp
  801f7c:	89 e5                	mov    %esp,%ebp
  801f7e:	57                   	push   %edi
  801f7f:	56                   	push   %esi
  801f80:	53                   	push   %ebx
  801f81:	83 ec 1c             	sub    $0x1c,%esp
  801f84:	89 c7                	mov    %eax,%edi
  801f86:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801f88:	a1 00 40 80 00       	mov    0x804000,%eax
  801f8d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f90:	83 ec 0c             	sub    $0xc,%esp
  801f93:	57                   	push   %edi
  801f94:	e8 07 06 00 00       	call   8025a0 <pageref>
  801f99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f9c:	89 34 24             	mov    %esi,(%esp)
  801f9f:	e8 fc 05 00 00       	call   8025a0 <pageref>
		nn = thisenv->env_runs;
  801fa4:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801faa:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801fad:	83 c4 10             	add    $0x10,%esp
  801fb0:	39 cb                	cmp    %ecx,%ebx
  801fb2:	74 1b                	je     801fcf <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801fb4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801fb7:	75 cf                	jne    801f88 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fb9:	8b 42 58             	mov    0x58(%edx),%eax
  801fbc:	6a 01                	push   $0x1
  801fbe:	50                   	push   %eax
  801fbf:	53                   	push   %ebx
  801fc0:	68 9b 2e 80 00       	push   $0x802e9b
  801fc5:	e8 43 e4 ff ff       	call   80040d <cprintf>
  801fca:	83 c4 10             	add    $0x10,%esp
  801fcd:	eb b9                	jmp    801f88 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801fcf:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801fd2:	0f 94 c0             	sete   %al
  801fd5:	0f b6 c0             	movzbl %al,%eax
}
  801fd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fdb:	5b                   	pop    %ebx
  801fdc:	5e                   	pop    %esi
  801fdd:	5f                   	pop    %edi
  801fde:	5d                   	pop    %ebp
  801fdf:	c3                   	ret    

00801fe0 <devpipe_write>:
{
  801fe0:	55                   	push   %ebp
  801fe1:	89 e5                	mov    %esp,%ebp
  801fe3:	57                   	push   %edi
  801fe4:	56                   	push   %esi
  801fe5:	53                   	push   %ebx
  801fe6:	83 ec 28             	sub    $0x28,%esp
  801fe9:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801fec:	56                   	push   %esi
  801fed:	e8 d1 f2 ff ff       	call   8012c3 <fd2data>
  801ff2:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ff4:	83 c4 10             	add    $0x10,%esp
  801ff7:	bf 00 00 00 00       	mov    $0x0,%edi
  801ffc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fff:	75 09                	jne    80200a <devpipe_write+0x2a>
	return i;
  802001:	89 f8                	mov    %edi,%eax
  802003:	eb 23                	jmp    802028 <devpipe_write+0x48>
			sys_yield();
  802005:	e8 ba ed ff ff       	call   800dc4 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80200a:	8b 43 04             	mov    0x4(%ebx),%eax
  80200d:	8b 0b                	mov    (%ebx),%ecx
  80200f:	8d 51 20             	lea    0x20(%ecx),%edx
  802012:	39 d0                	cmp    %edx,%eax
  802014:	72 1a                	jb     802030 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  802016:	89 da                	mov    %ebx,%edx
  802018:	89 f0                	mov    %esi,%eax
  80201a:	e8 5c ff ff ff       	call   801f7b <_pipeisclosed>
  80201f:	85 c0                	test   %eax,%eax
  802021:	74 e2                	je     802005 <devpipe_write+0x25>
				return 0;
  802023:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802028:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80202b:	5b                   	pop    %ebx
  80202c:	5e                   	pop    %esi
  80202d:	5f                   	pop    %edi
  80202e:	5d                   	pop    %ebp
  80202f:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802030:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802033:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802037:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80203a:	89 c2                	mov    %eax,%edx
  80203c:	c1 fa 1f             	sar    $0x1f,%edx
  80203f:	89 d1                	mov    %edx,%ecx
  802041:	c1 e9 1b             	shr    $0x1b,%ecx
  802044:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802047:	83 e2 1f             	and    $0x1f,%edx
  80204a:	29 ca                	sub    %ecx,%edx
  80204c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802050:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802054:	83 c0 01             	add    $0x1,%eax
  802057:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80205a:	83 c7 01             	add    $0x1,%edi
  80205d:	eb 9d                	jmp    801ffc <devpipe_write+0x1c>

0080205f <devpipe_read>:
{
  80205f:	55                   	push   %ebp
  802060:	89 e5                	mov    %esp,%ebp
  802062:	57                   	push   %edi
  802063:	56                   	push   %esi
  802064:	53                   	push   %ebx
  802065:	83 ec 18             	sub    $0x18,%esp
  802068:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80206b:	57                   	push   %edi
  80206c:	e8 52 f2 ff ff       	call   8012c3 <fd2data>
  802071:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802073:	83 c4 10             	add    $0x10,%esp
  802076:	be 00 00 00 00       	mov    $0x0,%esi
  80207b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80207e:	75 13                	jne    802093 <devpipe_read+0x34>
	return i;
  802080:	89 f0                	mov    %esi,%eax
  802082:	eb 02                	jmp    802086 <devpipe_read+0x27>
				return i;
  802084:	89 f0                	mov    %esi,%eax
}
  802086:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802089:	5b                   	pop    %ebx
  80208a:	5e                   	pop    %esi
  80208b:	5f                   	pop    %edi
  80208c:	5d                   	pop    %ebp
  80208d:	c3                   	ret    
			sys_yield();
  80208e:	e8 31 ed ff ff       	call   800dc4 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802093:	8b 03                	mov    (%ebx),%eax
  802095:	3b 43 04             	cmp    0x4(%ebx),%eax
  802098:	75 18                	jne    8020b2 <devpipe_read+0x53>
			if (i > 0)
  80209a:	85 f6                	test   %esi,%esi
  80209c:	75 e6                	jne    802084 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  80209e:	89 da                	mov    %ebx,%edx
  8020a0:	89 f8                	mov    %edi,%eax
  8020a2:	e8 d4 fe ff ff       	call   801f7b <_pipeisclosed>
  8020a7:	85 c0                	test   %eax,%eax
  8020a9:	74 e3                	je     80208e <devpipe_read+0x2f>
				return 0;
  8020ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8020b0:	eb d4                	jmp    802086 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020b2:	99                   	cltd   
  8020b3:	c1 ea 1b             	shr    $0x1b,%edx
  8020b6:	01 d0                	add    %edx,%eax
  8020b8:	83 e0 1f             	and    $0x1f,%eax
  8020bb:	29 d0                	sub    %edx,%eax
  8020bd:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8020c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020c5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8020c8:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8020cb:	83 c6 01             	add    $0x1,%esi
  8020ce:	eb ab                	jmp    80207b <devpipe_read+0x1c>

008020d0 <pipe>:
{
  8020d0:	55                   	push   %ebp
  8020d1:	89 e5                	mov    %esp,%ebp
  8020d3:	56                   	push   %esi
  8020d4:	53                   	push   %ebx
  8020d5:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8020d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020db:	50                   	push   %eax
  8020dc:	e8 f9 f1 ff ff       	call   8012da <fd_alloc>
  8020e1:	89 c3                	mov    %eax,%ebx
  8020e3:	83 c4 10             	add    $0x10,%esp
  8020e6:	85 c0                	test   %eax,%eax
  8020e8:	0f 88 23 01 00 00    	js     802211 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ee:	83 ec 04             	sub    $0x4,%esp
  8020f1:	68 07 04 00 00       	push   $0x407
  8020f6:	ff 75 f4             	push   -0xc(%ebp)
  8020f9:	6a 00                	push   $0x0
  8020fb:	e8 e3 ec ff ff       	call   800de3 <sys_page_alloc>
  802100:	89 c3                	mov    %eax,%ebx
  802102:	83 c4 10             	add    $0x10,%esp
  802105:	85 c0                	test   %eax,%eax
  802107:	0f 88 04 01 00 00    	js     802211 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  80210d:	83 ec 0c             	sub    $0xc,%esp
  802110:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802113:	50                   	push   %eax
  802114:	e8 c1 f1 ff ff       	call   8012da <fd_alloc>
  802119:	89 c3                	mov    %eax,%ebx
  80211b:	83 c4 10             	add    $0x10,%esp
  80211e:	85 c0                	test   %eax,%eax
  802120:	0f 88 db 00 00 00    	js     802201 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802126:	83 ec 04             	sub    $0x4,%esp
  802129:	68 07 04 00 00       	push   $0x407
  80212e:	ff 75 f0             	push   -0x10(%ebp)
  802131:	6a 00                	push   $0x0
  802133:	e8 ab ec ff ff       	call   800de3 <sys_page_alloc>
  802138:	89 c3                	mov    %eax,%ebx
  80213a:	83 c4 10             	add    $0x10,%esp
  80213d:	85 c0                	test   %eax,%eax
  80213f:	0f 88 bc 00 00 00    	js     802201 <pipe+0x131>
	va = fd2data(fd0);
  802145:	83 ec 0c             	sub    $0xc,%esp
  802148:	ff 75 f4             	push   -0xc(%ebp)
  80214b:	e8 73 f1 ff ff       	call   8012c3 <fd2data>
  802150:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802152:	83 c4 0c             	add    $0xc,%esp
  802155:	68 07 04 00 00       	push   $0x407
  80215a:	50                   	push   %eax
  80215b:	6a 00                	push   $0x0
  80215d:	e8 81 ec ff ff       	call   800de3 <sys_page_alloc>
  802162:	89 c3                	mov    %eax,%ebx
  802164:	83 c4 10             	add    $0x10,%esp
  802167:	85 c0                	test   %eax,%eax
  802169:	0f 88 82 00 00 00    	js     8021f1 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80216f:	83 ec 0c             	sub    $0xc,%esp
  802172:	ff 75 f0             	push   -0x10(%ebp)
  802175:	e8 49 f1 ff ff       	call   8012c3 <fd2data>
  80217a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802181:	50                   	push   %eax
  802182:	6a 00                	push   $0x0
  802184:	56                   	push   %esi
  802185:	6a 00                	push   $0x0
  802187:	e8 9a ec ff ff       	call   800e26 <sys_page_map>
  80218c:	89 c3                	mov    %eax,%ebx
  80218e:	83 c4 20             	add    $0x20,%esp
  802191:	85 c0                	test   %eax,%eax
  802193:	78 4e                	js     8021e3 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  802195:	a1 40 30 80 00       	mov    0x803040,%eax
  80219a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80219d:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80219f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021a2:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8021a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021ac:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8021ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021b1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8021b8:	83 ec 0c             	sub    $0xc,%esp
  8021bb:	ff 75 f4             	push   -0xc(%ebp)
  8021be:	e8 f0 f0 ff ff       	call   8012b3 <fd2num>
  8021c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021c6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021c8:	83 c4 04             	add    $0x4,%esp
  8021cb:	ff 75 f0             	push   -0x10(%ebp)
  8021ce:	e8 e0 f0 ff ff       	call   8012b3 <fd2num>
  8021d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021d6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021d9:	83 c4 10             	add    $0x10,%esp
  8021dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021e1:	eb 2e                	jmp    802211 <pipe+0x141>
	sys_page_unmap(0, va);
  8021e3:	83 ec 08             	sub    $0x8,%esp
  8021e6:	56                   	push   %esi
  8021e7:	6a 00                	push   $0x0
  8021e9:	e8 7a ec ff ff       	call   800e68 <sys_page_unmap>
  8021ee:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8021f1:	83 ec 08             	sub    $0x8,%esp
  8021f4:	ff 75 f0             	push   -0x10(%ebp)
  8021f7:	6a 00                	push   $0x0
  8021f9:	e8 6a ec ff ff       	call   800e68 <sys_page_unmap>
  8021fe:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802201:	83 ec 08             	sub    $0x8,%esp
  802204:	ff 75 f4             	push   -0xc(%ebp)
  802207:	6a 00                	push   $0x0
  802209:	e8 5a ec ff ff       	call   800e68 <sys_page_unmap>
  80220e:	83 c4 10             	add    $0x10,%esp
}
  802211:	89 d8                	mov    %ebx,%eax
  802213:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802216:	5b                   	pop    %ebx
  802217:	5e                   	pop    %esi
  802218:	5d                   	pop    %ebp
  802219:	c3                   	ret    

0080221a <pipeisclosed>:
{
  80221a:	55                   	push   %ebp
  80221b:	89 e5                	mov    %esp,%ebp
  80221d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802220:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802223:	50                   	push   %eax
  802224:	ff 75 08             	push   0x8(%ebp)
  802227:	e8 fe f0 ff ff       	call   80132a <fd_lookup>
  80222c:	83 c4 10             	add    $0x10,%esp
  80222f:	85 c0                	test   %eax,%eax
  802231:	78 18                	js     80224b <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802233:	83 ec 0c             	sub    $0xc,%esp
  802236:	ff 75 f4             	push   -0xc(%ebp)
  802239:	e8 85 f0 ff ff       	call   8012c3 <fd2data>
  80223e:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802240:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802243:	e8 33 fd ff ff       	call   801f7b <_pipeisclosed>
  802248:	83 c4 10             	add    $0x10,%esp
}
  80224b:	c9                   	leave  
  80224c:	c3                   	ret    

0080224d <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80224d:	55                   	push   %ebp
  80224e:	89 e5                	mov    %esp,%ebp
  802250:	56                   	push   %esi
  802251:	53                   	push   %ebx
  802252:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802255:	85 f6                	test   %esi,%esi
  802257:	74 13                	je     80226c <wait+0x1f>
	e = &envs[ENVX(envid)];
  802259:	89 f3                	mov    %esi,%ebx
  80225b:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802261:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802264:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80226a:	eb 1b                	jmp    802287 <wait+0x3a>
	assert(envid != 0);
  80226c:	68 b3 2e 80 00       	push   $0x802eb3
  802271:	68 2f 2e 80 00       	push   $0x802e2f
  802276:	6a 09                	push   $0x9
  802278:	68 be 2e 80 00       	push   $0x802ebe
  80227d:	e8 b0 e0 ff ff       	call   800332 <_panic>
		sys_yield();
  802282:	e8 3d eb ff ff       	call   800dc4 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802287:	8b 43 48             	mov    0x48(%ebx),%eax
  80228a:	39 f0                	cmp    %esi,%eax
  80228c:	75 07                	jne    802295 <wait+0x48>
  80228e:	8b 43 54             	mov    0x54(%ebx),%eax
  802291:	85 c0                	test   %eax,%eax
  802293:	75 ed                	jne    802282 <wait+0x35>
}
  802295:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802298:	5b                   	pop    %ebx
  802299:	5e                   	pop    %esi
  80229a:	5d                   	pop    %ebp
  80229b:	c3                   	ret    

0080229c <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80229c:	b8 00 00 00 00       	mov    $0x0,%eax
  8022a1:	c3                   	ret    

008022a2 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022a2:	55                   	push   %ebp
  8022a3:	89 e5                	mov    %esp,%ebp
  8022a5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022a8:	68 c9 2e 80 00       	push   $0x802ec9
  8022ad:	ff 75 0c             	push   0xc(%ebp)
  8022b0:	e8 32 e7 ff ff       	call   8009e7 <strcpy>
	return 0;
}
  8022b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8022ba:	c9                   	leave  
  8022bb:	c3                   	ret    

008022bc <devcons_write>:
{
  8022bc:	55                   	push   %ebp
  8022bd:	89 e5                	mov    %esp,%ebp
  8022bf:	57                   	push   %edi
  8022c0:	56                   	push   %esi
  8022c1:	53                   	push   %ebx
  8022c2:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8022c8:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8022cd:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8022d3:	eb 2e                	jmp    802303 <devcons_write+0x47>
		m = n - tot;
  8022d5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022d8:	29 f3                	sub    %esi,%ebx
  8022da:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8022df:	39 c3                	cmp    %eax,%ebx
  8022e1:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8022e4:	83 ec 04             	sub    $0x4,%esp
  8022e7:	53                   	push   %ebx
  8022e8:	89 f0                	mov    %esi,%eax
  8022ea:	03 45 0c             	add    0xc(%ebp),%eax
  8022ed:	50                   	push   %eax
  8022ee:	57                   	push   %edi
  8022ef:	e8 89 e8 ff ff       	call   800b7d <memmove>
		sys_cputs(buf, m);
  8022f4:	83 c4 08             	add    $0x8,%esp
  8022f7:	53                   	push   %ebx
  8022f8:	57                   	push   %edi
  8022f9:	e8 29 ea ff ff       	call   800d27 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8022fe:	01 de                	add    %ebx,%esi
  802300:	83 c4 10             	add    $0x10,%esp
  802303:	3b 75 10             	cmp    0x10(%ebp),%esi
  802306:	72 cd                	jb     8022d5 <devcons_write+0x19>
}
  802308:	89 f0                	mov    %esi,%eax
  80230a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80230d:	5b                   	pop    %ebx
  80230e:	5e                   	pop    %esi
  80230f:	5f                   	pop    %edi
  802310:	5d                   	pop    %ebp
  802311:	c3                   	ret    

00802312 <devcons_read>:
{
  802312:	55                   	push   %ebp
  802313:	89 e5                	mov    %esp,%ebp
  802315:	83 ec 08             	sub    $0x8,%esp
  802318:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80231d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802321:	75 07                	jne    80232a <devcons_read+0x18>
  802323:	eb 1f                	jmp    802344 <devcons_read+0x32>
		sys_yield();
  802325:	e8 9a ea ff ff       	call   800dc4 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80232a:	e8 16 ea ff ff       	call   800d45 <sys_cgetc>
  80232f:	85 c0                	test   %eax,%eax
  802331:	74 f2                	je     802325 <devcons_read+0x13>
	if (c < 0)
  802333:	78 0f                	js     802344 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802335:	83 f8 04             	cmp    $0x4,%eax
  802338:	74 0c                	je     802346 <devcons_read+0x34>
	*(char*)vbuf = c;
  80233a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80233d:	88 02                	mov    %al,(%edx)
	return 1;
  80233f:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802344:	c9                   	leave  
  802345:	c3                   	ret    
		return 0;
  802346:	b8 00 00 00 00       	mov    $0x0,%eax
  80234b:	eb f7                	jmp    802344 <devcons_read+0x32>

0080234d <cputchar>:
{
  80234d:	55                   	push   %ebp
  80234e:	89 e5                	mov    %esp,%ebp
  802350:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802353:	8b 45 08             	mov    0x8(%ebp),%eax
  802356:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802359:	6a 01                	push   $0x1
  80235b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80235e:	50                   	push   %eax
  80235f:	e8 c3 e9 ff ff       	call   800d27 <sys_cputs>
}
  802364:	83 c4 10             	add    $0x10,%esp
  802367:	c9                   	leave  
  802368:	c3                   	ret    

00802369 <getchar>:
{
  802369:	55                   	push   %ebp
  80236a:	89 e5                	mov    %esp,%ebp
  80236c:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80236f:	6a 01                	push   $0x1
  802371:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802374:	50                   	push   %eax
  802375:	6a 00                	push   $0x0
  802377:	e8 17 f2 ff ff       	call   801593 <read>
	if (r < 0)
  80237c:	83 c4 10             	add    $0x10,%esp
  80237f:	85 c0                	test   %eax,%eax
  802381:	78 06                	js     802389 <getchar+0x20>
	if (r < 1)
  802383:	74 06                	je     80238b <getchar+0x22>
	return c;
  802385:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802389:	c9                   	leave  
  80238a:	c3                   	ret    
		return -E_EOF;
  80238b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802390:	eb f7                	jmp    802389 <getchar+0x20>

00802392 <iscons>:
{
  802392:	55                   	push   %ebp
  802393:	89 e5                	mov    %esp,%ebp
  802395:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802398:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80239b:	50                   	push   %eax
  80239c:	ff 75 08             	push   0x8(%ebp)
  80239f:	e8 86 ef ff ff       	call   80132a <fd_lookup>
  8023a4:	83 c4 10             	add    $0x10,%esp
  8023a7:	85 c0                	test   %eax,%eax
  8023a9:	78 11                	js     8023bc <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8023ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023ae:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8023b4:	39 10                	cmp    %edx,(%eax)
  8023b6:	0f 94 c0             	sete   %al
  8023b9:	0f b6 c0             	movzbl %al,%eax
}
  8023bc:	c9                   	leave  
  8023bd:	c3                   	ret    

008023be <opencons>:
{
  8023be:	55                   	push   %ebp
  8023bf:	89 e5                	mov    %esp,%ebp
  8023c1:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8023c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023c7:	50                   	push   %eax
  8023c8:	e8 0d ef ff ff       	call   8012da <fd_alloc>
  8023cd:	83 c4 10             	add    $0x10,%esp
  8023d0:	85 c0                	test   %eax,%eax
  8023d2:	78 3a                	js     80240e <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023d4:	83 ec 04             	sub    $0x4,%esp
  8023d7:	68 07 04 00 00       	push   $0x407
  8023dc:	ff 75 f4             	push   -0xc(%ebp)
  8023df:	6a 00                	push   $0x0
  8023e1:	e8 fd e9 ff ff       	call   800de3 <sys_page_alloc>
  8023e6:	83 c4 10             	add    $0x10,%esp
  8023e9:	85 c0                	test   %eax,%eax
  8023eb:	78 21                	js     80240e <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8023ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f0:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8023f6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8023f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023fb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802402:	83 ec 0c             	sub    $0xc,%esp
  802405:	50                   	push   %eax
  802406:	e8 a8 ee ff ff       	call   8012b3 <fd2num>
  80240b:	83 c4 10             	add    $0x10,%esp
}
  80240e:	c9                   	leave  
  80240f:	c3                   	ret    

00802410 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802410:	55                   	push   %ebp
  802411:	89 e5                	mov    %esp,%ebp
  802413:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  802416:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  80241d:	74 0a                	je     802429 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80241f:	8b 45 08             	mov    0x8(%ebp),%eax
  802422:	a3 04 80 80 00       	mov    %eax,0x808004
}
  802427:	c9                   	leave  
  802428:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  802429:	e8 77 e9 ff ff       	call   800da5 <sys_getenvid>
  80242e:	83 ec 04             	sub    $0x4,%esp
  802431:	68 07 0e 00 00       	push   $0xe07
  802436:	68 00 f0 bf ee       	push   $0xeebff000
  80243b:	50                   	push   %eax
  80243c:	e8 a2 e9 ff ff       	call   800de3 <sys_page_alloc>
		if (r < 0) {
  802441:	83 c4 10             	add    $0x10,%esp
  802444:	85 c0                	test   %eax,%eax
  802446:	78 2c                	js     802474 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802448:	e8 58 e9 ff ff       	call   800da5 <sys_getenvid>
  80244d:	83 ec 08             	sub    $0x8,%esp
  802450:	68 86 24 80 00       	push   $0x802486
  802455:	50                   	push   %eax
  802456:	e8 d3 ea ff ff       	call   800f2e <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80245b:	83 c4 10             	add    $0x10,%esp
  80245e:	85 c0                	test   %eax,%eax
  802460:	79 bd                	jns    80241f <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  802462:	50                   	push   %eax
  802463:	68 18 2f 80 00       	push   $0x802f18
  802468:	6a 28                	push   $0x28
  80246a:	68 4e 2f 80 00       	push   $0x802f4e
  80246f:	e8 be de ff ff       	call   800332 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  802474:	50                   	push   %eax
  802475:	68 d8 2e 80 00       	push   $0x802ed8
  80247a:	6a 23                	push   $0x23
  80247c:	68 4e 2f 80 00       	push   $0x802f4e
  802481:	e8 ac de ff ff       	call   800332 <_panic>

00802486 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802486:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802487:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  80248c:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80248e:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802491:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802495:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802498:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  80249c:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  8024a0:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  8024a2:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  8024a5:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  8024a6:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  8024a9:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  8024aa:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  8024ab:	c3                   	ret    

008024ac <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024ac:	55                   	push   %ebp
  8024ad:	89 e5                	mov    %esp,%ebp
  8024af:	56                   	push   %esi
  8024b0:	53                   	push   %ebx
  8024b1:	8b 75 08             	mov    0x8(%ebp),%esi
  8024b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8024ba:	85 c0                	test   %eax,%eax
  8024bc:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8024c1:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8024c4:	83 ec 0c             	sub    $0xc,%esp
  8024c7:	50                   	push   %eax
  8024c8:	e8 c6 ea ff ff       	call   800f93 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8024cd:	83 c4 10             	add    $0x10,%esp
  8024d0:	85 f6                	test   %esi,%esi
  8024d2:	74 14                	je     8024e8 <ipc_recv+0x3c>
  8024d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8024d9:	85 c0                	test   %eax,%eax
  8024db:	78 09                	js     8024e6 <ipc_recv+0x3a>
  8024dd:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8024e3:	8b 52 74             	mov    0x74(%edx),%edx
  8024e6:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8024e8:	85 db                	test   %ebx,%ebx
  8024ea:	74 14                	je     802500 <ipc_recv+0x54>
  8024ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8024f1:	85 c0                	test   %eax,%eax
  8024f3:	78 09                	js     8024fe <ipc_recv+0x52>
  8024f5:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8024fb:	8b 52 78             	mov    0x78(%edx),%edx
  8024fe:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802500:	85 c0                	test   %eax,%eax
  802502:	78 08                	js     80250c <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  802504:	a1 00 40 80 00       	mov    0x804000,%eax
  802509:	8b 40 70             	mov    0x70(%eax),%eax
}
  80250c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80250f:	5b                   	pop    %ebx
  802510:	5e                   	pop    %esi
  802511:	5d                   	pop    %ebp
  802512:	c3                   	ret    

00802513 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802513:	55                   	push   %ebp
  802514:	89 e5                	mov    %esp,%ebp
  802516:	57                   	push   %edi
  802517:	56                   	push   %esi
  802518:	53                   	push   %ebx
  802519:	83 ec 0c             	sub    $0xc,%esp
  80251c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80251f:	8b 75 0c             	mov    0xc(%ebp),%esi
  802522:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802525:	85 db                	test   %ebx,%ebx
  802527:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80252c:	0f 44 d8             	cmove  %eax,%ebx
  80252f:	eb 05                	jmp    802536 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802531:	e8 8e e8 ff ff       	call   800dc4 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802536:	ff 75 14             	push   0x14(%ebp)
  802539:	53                   	push   %ebx
  80253a:	56                   	push   %esi
  80253b:	57                   	push   %edi
  80253c:	e8 2f ea ff ff       	call   800f70 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802541:	83 c4 10             	add    $0x10,%esp
  802544:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802547:	74 e8                	je     802531 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802549:	85 c0                	test   %eax,%eax
  80254b:	78 08                	js     802555 <ipc_send+0x42>
	}while (r<0);

}
  80254d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802550:	5b                   	pop    %ebx
  802551:	5e                   	pop    %esi
  802552:	5f                   	pop    %edi
  802553:	5d                   	pop    %ebp
  802554:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802555:	50                   	push   %eax
  802556:	68 5c 2f 80 00       	push   $0x802f5c
  80255b:	6a 3d                	push   $0x3d
  80255d:	68 70 2f 80 00       	push   $0x802f70
  802562:	e8 cb dd ff ff       	call   800332 <_panic>

00802567 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802567:	55                   	push   %ebp
  802568:	89 e5                	mov    %esp,%ebp
  80256a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80256d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802572:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802575:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80257b:	8b 52 50             	mov    0x50(%edx),%edx
  80257e:	39 ca                	cmp    %ecx,%edx
  802580:	74 11                	je     802593 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802582:	83 c0 01             	add    $0x1,%eax
  802585:	3d 00 04 00 00       	cmp    $0x400,%eax
  80258a:	75 e6                	jne    802572 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80258c:	b8 00 00 00 00       	mov    $0x0,%eax
  802591:	eb 0b                	jmp    80259e <ipc_find_env+0x37>
			return envs[i].env_id;
  802593:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802596:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80259b:	8b 40 48             	mov    0x48(%eax),%eax
}
  80259e:	5d                   	pop    %ebp
  80259f:	c3                   	ret    

008025a0 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025a0:	55                   	push   %ebp
  8025a1:	89 e5                	mov    %esp,%ebp
  8025a3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025a6:	89 c2                	mov    %eax,%edx
  8025a8:	c1 ea 16             	shr    $0x16,%edx
  8025ab:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8025b2:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8025b7:	f6 c1 01             	test   $0x1,%cl
  8025ba:	74 1c                	je     8025d8 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8025bc:	c1 e8 0c             	shr    $0xc,%eax
  8025bf:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8025c6:	a8 01                	test   $0x1,%al
  8025c8:	74 0e                	je     8025d8 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025ca:	c1 e8 0c             	shr    $0xc,%eax
  8025cd:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8025d4:	ef 
  8025d5:	0f b7 d2             	movzwl %dx,%edx
}
  8025d8:	89 d0                	mov    %edx,%eax
  8025da:	5d                   	pop    %ebp
  8025db:	c3                   	ret    
  8025dc:	66 90                	xchg   %ax,%ax
  8025de:	66 90                	xchg   %ax,%ax

008025e0 <__udivdi3>:
  8025e0:	f3 0f 1e fb          	endbr32 
  8025e4:	55                   	push   %ebp
  8025e5:	57                   	push   %edi
  8025e6:	56                   	push   %esi
  8025e7:	53                   	push   %ebx
  8025e8:	83 ec 1c             	sub    $0x1c,%esp
  8025eb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8025ef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8025f3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8025f7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8025fb:	85 c0                	test   %eax,%eax
  8025fd:	75 19                	jne    802618 <__udivdi3+0x38>
  8025ff:	39 f3                	cmp    %esi,%ebx
  802601:	76 4d                	jbe    802650 <__udivdi3+0x70>
  802603:	31 ff                	xor    %edi,%edi
  802605:	89 e8                	mov    %ebp,%eax
  802607:	89 f2                	mov    %esi,%edx
  802609:	f7 f3                	div    %ebx
  80260b:	89 fa                	mov    %edi,%edx
  80260d:	83 c4 1c             	add    $0x1c,%esp
  802610:	5b                   	pop    %ebx
  802611:	5e                   	pop    %esi
  802612:	5f                   	pop    %edi
  802613:	5d                   	pop    %ebp
  802614:	c3                   	ret    
  802615:	8d 76 00             	lea    0x0(%esi),%esi
  802618:	39 f0                	cmp    %esi,%eax
  80261a:	76 14                	jbe    802630 <__udivdi3+0x50>
  80261c:	31 ff                	xor    %edi,%edi
  80261e:	31 c0                	xor    %eax,%eax
  802620:	89 fa                	mov    %edi,%edx
  802622:	83 c4 1c             	add    $0x1c,%esp
  802625:	5b                   	pop    %ebx
  802626:	5e                   	pop    %esi
  802627:	5f                   	pop    %edi
  802628:	5d                   	pop    %ebp
  802629:	c3                   	ret    
  80262a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802630:	0f bd f8             	bsr    %eax,%edi
  802633:	83 f7 1f             	xor    $0x1f,%edi
  802636:	75 48                	jne    802680 <__udivdi3+0xa0>
  802638:	39 f0                	cmp    %esi,%eax
  80263a:	72 06                	jb     802642 <__udivdi3+0x62>
  80263c:	31 c0                	xor    %eax,%eax
  80263e:	39 eb                	cmp    %ebp,%ebx
  802640:	77 de                	ja     802620 <__udivdi3+0x40>
  802642:	b8 01 00 00 00       	mov    $0x1,%eax
  802647:	eb d7                	jmp    802620 <__udivdi3+0x40>
  802649:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802650:	89 d9                	mov    %ebx,%ecx
  802652:	85 db                	test   %ebx,%ebx
  802654:	75 0b                	jne    802661 <__udivdi3+0x81>
  802656:	b8 01 00 00 00       	mov    $0x1,%eax
  80265b:	31 d2                	xor    %edx,%edx
  80265d:	f7 f3                	div    %ebx
  80265f:	89 c1                	mov    %eax,%ecx
  802661:	31 d2                	xor    %edx,%edx
  802663:	89 f0                	mov    %esi,%eax
  802665:	f7 f1                	div    %ecx
  802667:	89 c6                	mov    %eax,%esi
  802669:	89 e8                	mov    %ebp,%eax
  80266b:	89 f7                	mov    %esi,%edi
  80266d:	f7 f1                	div    %ecx
  80266f:	89 fa                	mov    %edi,%edx
  802671:	83 c4 1c             	add    $0x1c,%esp
  802674:	5b                   	pop    %ebx
  802675:	5e                   	pop    %esi
  802676:	5f                   	pop    %edi
  802677:	5d                   	pop    %ebp
  802678:	c3                   	ret    
  802679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802680:	89 f9                	mov    %edi,%ecx
  802682:	ba 20 00 00 00       	mov    $0x20,%edx
  802687:	29 fa                	sub    %edi,%edx
  802689:	d3 e0                	shl    %cl,%eax
  80268b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80268f:	89 d1                	mov    %edx,%ecx
  802691:	89 d8                	mov    %ebx,%eax
  802693:	d3 e8                	shr    %cl,%eax
  802695:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802699:	09 c1                	or     %eax,%ecx
  80269b:	89 f0                	mov    %esi,%eax
  80269d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026a1:	89 f9                	mov    %edi,%ecx
  8026a3:	d3 e3                	shl    %cl,%ebx
  8026a5:	89 d1                	mov    %edx,%ecx
  8026a7:	d3 e8                	shr    %cl,%eax
  8026a9:	89 f9                	mov    %edi,%ecx
  8026ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8026af:	89 eb                	mov    %ebp,%ebx
  8026b1:	d3 e6                	shl    %cl,%esi
  8026b3:	89 d1                	mov    %edx,%ecx
  8026b5:	d3 eb                	shr    %cl,%ebx
  8026b7:	09 f3                	or     %esi,%ebx
  8026b9:	89 c6                	mov    %eax,%esi
  8026bb:	89 f2                	mov    %esi,%edx
  8026bd:	89 d8                	mov    %ebx,%eax
  8026bf:	f7 74 24 08          	divl   0x8(%esp)
  8026c3:	89 d6                	mov    %edx,%esi
  8026c5:	89 c3                	mov    %eax,%ebx
  8026c7:	f7 64 24 0c          	mull   0xc(%esp)
  8026cb:	39 d6                	cmp    %edx,%esi
  8026cd:	72 19                	jb     8026e8 <__udivdi3+0x108>
  8026cf:	89 f9                	mov    %edi,%ecx
  8026d1:	d3 e5                	shl    %cl,%ebp
  8026d3:	39 c5                	cmp    %eax,%ebp
  8026d5:	73 04                	jae    8026db <__udivdi3+0xfb>
  8026d7:	39 d6                	cmp    %edx,%esi
  8026d9:	74 0d                	je     8026e8 <__udivdi3+0x108>
  8026db:	89 d8                	mov    %ebx,%eax
  8026dd:	31 ff                	xor    %edi,%edi
  8026df:	e9 3c ff ff ff       	jmp    802620 <__udivdi3+0x40>
  8026e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026e8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8026eb:	31 ff                	xor    %edi,%edi
  8026ed:	e9 2e ff ff ff       	jmp    802620 <__udivdi3+0x40>
  8026f2:	66 90                	xchg   %ax,%ax
  8026f4:	66 90                	xchg   %ax,%ax
  8026f6:	66 90                	xchg   %ax,%ax
  8026f8:	66 90                	xchg   %ax,%ax
  8026fa:	66 90                	xchg   %ax,%ax
  8026fc:	66 90                	xchg   %ax,%ax
  8026fe:	66 90                	xchg   %ax,%ax

00802700 <__umoddi3>:
  802700:	f3 0f 1e fb          	endbr32 
  802704:	55                   	push   %ebp
  802705:	57                   	push   %edi
  802706:	56                   	push   %esi
  802707:	53                   	push   %ebx
  802708:	83 ec 1c             	sub    $0x1c,%esp
  80270b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80270f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802713:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802717:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80271b:	89 f0                	mov    %esi,%eax
  80271d:	89 da                	mov    %ebx,%edx
  80271f:	85 ff                	test   %edi,%edi
  802721:	75 15                	jne    802738 <__umoddi3+0x38>
  802723:	39 dd                	cmp    %ebx,%ebp
  802725:	76 39                	jbe    802760 <__umoddi3+0x60>
  802727:	f7 f5                	div    %ebp
  802729:	89 d0                	mov    %edx,%eax
  80272b:	31 d2                	xor    %edx,%edx
  80272d:	83 c4 1c             	add    $0x1c,%esp
  802730:	5b                   	pop    %ebx
  802731:	5e                   	pop    %esi
  802732:	5f                   	pop    %edi
  802733:	5d                   	pop    %ebp
  802734:	c3                   	ret    
  802735:	8d 76 00             	lea    0x0(%esi),%esi
  802738:	39 df                	cmp    %ebx,%edi
  80273a:	77 f1                	ja     80272d <__umoddi3+0x2d>
  80273c:	0f bd cf             	bsr    %edi,%ecx
  80273f:	83 f1 1f             	xor    $0x1f,%ecx
  802742:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802746:	75 40                	jne    802788 <__umoddi3+0x88>
  802748:	39 df                	cmp    %ebx,%edi
  80274a:	72 04                	jb     802750 <__umoddi3+0x50>
  80274c:	39 f5                	cmp    %esi,%ebp
  80274e:	77 dd                	ja     80272d <__umoddi3+0x2d>
  802750:	89 da                	mov    %ebx,%edx
  802752:	89 f0                	mov    %esi,%eax
  802754:	29 e8                	sub    %ebp,%eax
  802756:	19 fa                	sbb    %edi,%edx
  802758:	eb d3                	jmp    80272d <__umoddi3+0x2d>
  80275a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802760:	89 e9                	mov    %ebp,%ecx
  802762:	85 ed                	test   %ebp,%ebp
  802764:	75 0b                	jne    802771 <__umoddi3+0x71>
  802766:	b8 01 00 00 00       	mov    $0x1,%eax
  80276b:	31 d2                	xor    %edx,%edx
  80276d:	f7 f5                	div    %ebp
  80276f:	89 c1                	mov    %eax,%ecx
  802771:	89 d8                	mov    %ebx,%eax
  802773:	31 d2                	xor    %edx,%edx
  802775:	f7 f1                	div    %ecx
  802777:	89 f0                	mov    %esi,%eax
  802779:	f7 f1                	div    %ecx
  80277b:	89 d0                	mov    %edx,%eax
  80277d:	31 d2                	xor    %edx,%edx
  80277f:	eb ac                	jmp    80272d <__umoddi3+0x2d>
  802781:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802788:	8b 44 24 04          	mov    0x4(%esp),%eax
  80278c:	ba 20 00 00 00       	mov    $0x20,%edx
  802791:	29 c2                	sub    %eax,%edx
  802793:	89 c1                	mov    %eax,%ecx
  802795:	89 e8                	mov    %ebp,%eax
  802797:	d3 e7                	shl    %cl,%edi
  802799:	89 d1                	mov    %edx,%ecx
  80279b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80279f:	d3 e8                	shr    %cl,%eax
  8027a1:	89 c1                	mov    %eax,%ecx
  8027a3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8027a7:	09 f9                	or     %edi,%ecx
  8027a9:	89 df                	mov    %ebx,%edi
  8027ab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027af:	89 c1                	mov    %eax,%ecx
  8027b1:	d3 e5                	shl    %cl,%ebp
  8027b3:	89 d1                	mov    %edx,%ecx
  8027b5:	d3 ef                	shr    %cl,%edi
  8027b7:	89 c1                	mov    %eax,%ecx
  8027b9:	89 f0                	mov    %esi,%eax
  8027bb:	d3 e3                	shl    %cl,%ebx
  8027bd:	89 d1                	mov    %edx,%ecx
  8027bf:	89 fa                	mov    %edi,%edx
  8027c1:	d3 e8                	shr    %cl,%eax
  8027c3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027c8:	09 d8                	or     %ebx,%eax
  8027ca:	f7 74 24 08          	divl   0x8(%esp)
  8027ce:	89 d3                	mov    %edx,%ebx
  8027d0:	d3 e6                	shl    %cl,%esi
  8027d2:	f7 e5                	mul    %ebp
  8027d4:	89 c7                	mov    %eax,%edi
  8027d6:	89 d1                	mov    %edx,%ecx
  8027d8:	39 d3                	cmp    %edx,%ebx
  8027da:	72 06                	jb     8027e2 <__umoddi3+0xe2>
  8027dc:	75 0e                	jne    8027ec <__umoddi3+0xec>
  8027de:	39 c6                	cmp    %eax,%esi
  8027e0:	73 0a                	jae    8027ec <__umoddi3+0xec>
  8027e2:	29 e8                	sub    %ebp,%eax
  8027e4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8027e8:	89 d1                	mov    %edx,%ecx
  8027ea:	89 c7                	mov    %eax,%edi
  8027ec:	89 f5                	mov    %esi,%ebp
  8027ee:	8b 74 24 04          	mov    0x4(%esp),%esi
  8027f2:	29 fd                	sub    %edi,%ebp
  8027f4:	19 cb                	sbb    %ecx,%ebx
  8027f6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8027fb:	89 d8                	mov    %ebx,%eax
  8027fd:	d3 e0                	shl    %cl,%eax
  8027ff:	89 f1                	mov    %esi,%ecx
  802801:	d3 ed                	shr    %cl,%ebp
  802803:	d3 eb                	shr    %cl,%ebx
  802805:	09 e8                	or     %ebp,%eax
  802807:	89 da                	mov    %ebx,%edx
  802809:	83 c4 1c             	add    $0x1c,%esp
  80280c:	5b                   	pop    %ebx
  80280d:	5e                   	pop    %esi
  80280e:	5f                   	pop    %edi
  80280f:	5d                   	pop    %ebp
  802810:	c3                   	ret    
