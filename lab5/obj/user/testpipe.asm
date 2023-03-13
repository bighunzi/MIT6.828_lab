
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
  80003b:	c7 05 04 30 80 00 60 	movl   $0x802360,0x803004
  800042:	23 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 b4 1b 00 00       	call   801c02 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	0f 88 1b 01 00 00    	js     800176 <umain+0x143>
		panic("pipe: %e", i);

	if ((pid = fork()) < 0)
  80005b:	e8 72 10 00 00       	call   8010d2 <fork>
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
  80007f:	68 85 23 80 00       	push   $0x802385
  800084:	e8 84 03 00 00       	call   80040d <cprintf>
		close(p[1]);
  800089:	83 c4 04             	add    $0x4,%esp
  80008c:	ff 75 90             	push   -0x70(%ebp)
  80008f:	e8 5d 13 00 00       	call   8013f1 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  800094:	a1 00 40 80 00       	mov    0x804000,%eax
  800099:	8b 40 48             	mov    0x48(%eax),%eax
  80009c:	83 c4 0c             	add    $0xc,%esp
  80009f:	ff 75 8c             	push   -0x74(%ebp)
  8000a2:	50                   	push   %eax
  8000a3:	68 a2 23 80 00       	push   $0x8023a2
  8000a8:	e8 60 03 00 00       	call   80040d <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000ad:	83 c4 0c             	add    $0xc,%esp
  8000b0:	6a 63                	push   $0x63
  8000b2:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000b5:	50                   	push   %eax
  8000b6:	ff 75 8c             	push   -0x74(%ebp)
  8000b9:	e8 f6 14 00 00       	call   8015b4 <readn>
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
  8000f0:	68 c8 23 80 00       	push   $0x8023c8
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
  800106:	e8 74 1c 00 00       	call   801d7f <wait>

	binaryname = "pipewriteeof";
  80010b:	c7 05 04 30 80 00 1e 	movl   $0x80241e,0x803004
  800112:	24 80 00 
	if ((i = pipe(p)) < 0)
  800115:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800118:	89 04 24             	mov    %eax,(%esp)
  80011b:	e8 e2 1a 00 00       	call   801c02 <pipe>
  800120:	89 c6                	mov    %eax,%esi
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	0f 88 32 01 00 00    	js     80025f <umain+0x22c>
		panic("pipe: %e", i);

	if ((pid = fork()) < 0)
  80012d:	e8 a0 0f 00 00       	call   8010d2 <fork>
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
  800148:	e8 a4 12 00 00       	call   8013f1 <close>
	close(p[1]);
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 90             	push   -0x70(%ebp)
  800153:	e8 99 12 00 00       	call   8013f1 <close>
	wait(pid);
  800158:	89 1c 24             	mov    %ebx,(%esp)
  80015b:	e8 1f 1c 00 00       	call   801d7f <wait>

	cprintf("pipe tests passed\n");
  800160:	c7 04 24 4c 24 80 00 	movl   $0x80244c,(%esp)
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
  800177:	68 6c 23 80 00       	push   $0x80236c
  80017c:	6a 0e                	push   $0xe
  80017e:	68 75 23 80 00       	push   $0x802375
  800183:	e8 aa 01 00 00       	call   800332 <_panic>
		panic("fork: %e", i);
  800188:	56                   	push   %esi
  800189:	68 b8 28 80 00       	push   $0x8028b8
  80018e:	6a 11                	push   $0x11
  800190:	68 75 23 80 00       	push   $0x802375
  800195:	e8 98 01 00 00       	call   800332 <_panic>
			panic("read: %e", i);
  80019a:	50                   	push   %eax
  80019b:	68 bf 23 80 00       	push   $0x8023bf
  8001a0:	6a 19                	push   $0x19
  8001a2:	68 75 23 80 00       	push   $0x802375
  8001a7:	e8 86 01 00 00       	call   800332 <_panic>
			cprintf("\ngot %d bytes: %s\n", i, buf);
  8001ac:	83 ec 04             	sub    $0x4,%esp
  8001af:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8001b2:	50                   	push   %eax
  8001b3:	56                   	push   %esi
  8001b4:	68 e4 23 80 00       	push   $0x8023e4
  8001b9:	e8 4f 02 00 00       	call   80040d <cprintf>
  8001be:	83 c4 10             	add    $0x10,%esp
  8001c1:	e9 37 ff ff ff       	jmp    8000fd <umain+0xca>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  8001c6:	a1 00 40 80 00       	mov    0x804000,%eax
  8001cb:	8b 40 48             	mov    0x48(%eax),%eax
  8001ce:	83 ec 04             	sub    $0x4,%esp
  8001d1:	ff 75 8c             	push   -0x74(%ebp)
  8001d4:	50                   	push   %eax
  8001d5:	68 85 23 80 00       	push   $0x802385
  8001da:	e8 2e 02 00 00       	call   80040d <cprintf>
		close(p[0]);
  8001df:	83 c4 04             	add    $0x4,%esp
  8001e2:	ff 75 8c             	push   -0x74(%ebp)
  8001e5:	e8 07 12 00 00       	call   8013f1 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  8001ea:	a1 00 40 80 00       	mov    0x804000,%eax
  8001ef:	8b 40 48             	mov    0x48(%eax),%eax
  8001f2:	83 c4 0c             	add    $0xc,%esp
  8001f5:	ff 75 90             	push   -0x70(%ebp)
  8001f8:	50                   	push   %eax
  8001f9:	68 f7 23 80 00       	push   $0x8023f7
  8001fe:	e8 0a 02 00 00       	call   80040d <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800203:	83 c4 04             	add    $0x4,%esp
  800206:	ff 35 00 30 80 00    	push   0x803000
  80020c:	e8 9b 07 00 00       	call   8009ac <strlen>
  800211:	83 c4 0c             	add    $0xc,%esp
  800214:	50                   	push   %eax
  800215:	ff 35 00 30 80 00    	push   0x803000
  80021b:	ff 75 90             	push   -0x70(%ebp)
  80021e:	e8 d8 13 00 00       	call   8015fb <write>
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
  800240:	e8 ac 11 00 00       	call   8013f1 <close>
  800245:	83 c4 10             	add    $0x10,%esp
  800248:	e9 b5 fe ff ff       	jmp    800102 <umain+0xcf>
			panic("write: %e", i);
  80024d:	56                   	push   %esi
  80024e:	68 14 24 80 00       	push   $0x802414
  800253:	6a 25                	push   $0x25
  800255:	68 75 23 80 00       	push   $0x802375
  80025a:	e8 d3 00 00 00       	call   800332 <_panic>
		panic("pipe: %e", i);
  80025f:	50                   	push   %eax
  800260:	68 6c 23 80 00       	push   $0x80236c
  800265:	6a 2c                	push   $0x2c
  800267:	68 75 23 80 00       	push   $0x802375
  80026c:	e8 c1 00 00 00       	call   800332 <_panic>
		panic("fork: %e", i);
  800271:	56                   	push   %esi
  800272:	68 b8 28 80 00       	push   $0x8028b8
  800277:	6a 2f                	push   $0x2f
  800279:	68 75 23 80 00       	push   $0x802375
  80027e:	e8 af 00 00 00       	call   800332 <_panic>
		close(p[0]);
  800283:	83 ec 0c             	sub    $0xc,%esp
  800286:	ff 75 8c             	push   -0x74(%ebp)
  800289:	e8 63 11 00 00       	call   8013f1 <close>
  80028e:	83 c4 10             	add    $0x10,%esp
			cprintf(".");
  800291:	83 ec 0c             	sub    $0xc,%esp
  800294:	68 2b 24 80 00       	push   $0x80242b
  800299:	e8 6f 01 00 00       	call   80040d <cprintf>
			if (write(p[1], "x", 1) != 1)
  80029e:	83 c4 0c             	add    $0xc,%esp
  8002a1:	6a 01                	push   $0x1
  8002a3:	68 2d 24 80 00       	push   $0x80242d
  8002a8:	ff 75 90             	push   -0x70(%ebp)
  8002ab:	e8 4b 13 00 00       	call   8015fb <write>
  8002b0:	83 c4 10             	add    $0x10,%esp
  8002b3:	83 f8 01             	cmp    $0x1,%eax
  8002b6:	74 d9                	je     800291 <umain+0x25e>
		cprintf("\npipe write closed properly\n");
  8002b8:	83 ec 0c             	sub    $0xc,%esp
  8002bb:	68 2f 24 80 00       	push   $0x80242f
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
  80031e:	e8 fb 10 00 00       	call   80141e <close_all>
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
  800350:	68 b0 24 80 00       	push   $0x8024b0
  800355:	e8 b3 00 00 00       	call   80040d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80035a:	83 c4 18             	add    $0x18,%esp
  80035d:	53                   	push   %ebx
  80035e:	ff 75 10             	push   0x10(%ebp)
  800361:	e8 56 00 00 00       	call   8003bc <vcprintf>
	cprintf("\n");
  800366:	c7 04 24 a0 23 80 00 	movl   $0x8023a0,(%esp)
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
  80046f:	e8 9c 1c 00 00       	call   802110 <__udivdi3>
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
  8004ad:	e8 7e 1d 00 00       	call   802230 <__umoddi3>
  8004b2:	83 c4 14             	add    $0x14,%esp
  8004b5:	0f be 80 d3 24 80 00 	movsbl 0x8024d3(%eax),%eax
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
  80056f:	ff 24 85 20 26 80 00 	jmp    *0x802620(,%eax,4)
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
  80063d:	8b 14 85 80 27 80 00 	mov    0x802780(,%eax,4),%edx
  800644:	85 d2                	test   %edx,%edx
  800646:	74 18                	je     800660 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800648:	52                   	push   %edx
  800649:	68 7d 29 80 00       	push   $0x80297d
  80064e:	53                   	push   %ebx
  80064f:	56                   	push   %esi
  800650:	e8 92 fe ff ff       	call   8004e7 <printfmt>
  800655:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800658:	89 7d 14             	mov    %edi,0x14(%ebp)
  80065b:	e9 66 02 00 00       	jmp    8008c6 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800660:	50                   	push   %eax
  800661:	68 eb 24 80 00       	push   $0x8024eb
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
  800688:	b8 e4 24 80 00       	mov    $0x8024e4,%eax
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
  800d94:	68 df 27 80 00       	push   $0x8027df
  800d99:	6a 2a                	push   $0x2a
  800d9b:	68 fc 27 80 00       	push   $0x8027fc
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
  800e15:	68 df 27 80 00       	push   $0x8027df
  800e1a:	6a 2a                	push   $0x2a
  800e1c:	68 fc 27 80 00       	push   $0x8027fc
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
  800e57:	68 df 27 80 00       	push   $0x8027df
  800e5c:	6a 2a                	push   $0x2a
  800e5e:	68 fc 27 80 00       	push   $0x8027fc
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
  800e99:	68 df 27 80 00       	push   $0x8027df
  800e9e:	6a 2a                	push   $0x2a
  800ea0:	68 fc 27 80 00       	push   $0x8027fc
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
  800edb:	68 df 27 80 00       	push   $0x8027df
  800ee0:	6a 2a                	push   $0x2a
  800ee2:	68 fc 27 80 00       	push   $0x8027fc
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
  800f1d:	68 df 27 80 00       	push   $0x8027df
  800f22:	6a 2a                	push   $0x2a
  800f24:	68 fc 27 80 00       	push   $0x8027fc
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
  800f5f:	68 df 27 80 00       	push   $0x8027df
  800f64:	6a 2a                	push   $0x2a
  800f66:	68 fc 27 80 00       	push   $0x8027fc
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
  800fc3:	68 df 27 80 00       	push   $0x8027df
  800fc8:	6a 2a                	push   $0x2a
  800fca:	68 fc 27 80 00       	push   $0x8027fc
  800fcf:	e8 5e f3 ff ff       	call   800332 <_panic>

00800fd4 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	56                   	push   %esi
  800fd8:	53                   	push   %ebx
  800fd9:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fdc:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800fde:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fe2:	0f 84 8e 00 00 00    	je     801076 <pgfault+0xa2>
  800fe8:	89 f0                	mov    %esi,%eax
  800fea:	c1 e8 0c             	shr    $0xc,%eax
  800fed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff4:	f6 c4 08             	test   $0x8,%ah
  800ff7:	74 7d                	je     801076 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800ff9:	e8 a7 fd ff ff       	call   800da5 <sys_getenvid>
  800ffe:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  801000:	83 ec 04             	sub    $0x4,%esp
  801003:	6a 07                	push   $0x7
  801005:	68 00 f0 7f 00       	push   $0x7ff000
  80100a:	50                   	push   %eax
  80100b:	e8 d3 fd ff ff       	call   800de3 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  801010:	83 c4 10             	add    $0x10,%esp
  801013:	85 c0                	test   %eax,%eax
  801015:	78 73                	js     80108a <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  801017:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  80101d:	83 ec 04             	sub    $0x4,%esp
  801020:	68 00 10 00 00       	push   $0x1000
  801025:	56                   	push   %esi
  801026:	68 00 f0 7f 00       	push   $0x7ff000
  80102b:	e8 4d fb ff ff       	call   800b7d <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  801030:	83 c4 08             	add    $0x8,%esp
  801033:	56                   	push   %esi
  801034:	53                   	push   %ebx
  801035:	e8 2e fe ff ff       	call   800e68 <sys_page_unmap>
  80103a:	83 c4 10             	add    $0x10,%esp
  80103d:	85 c0                	test   %eax,%eax
  80103f:	78 5b                	js     80109c <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  801041:	83 ec 0c             	sub    $0xc,%esp
  801044:	6a 07                	push   $0x7
  801046:	56                   	push   %esi
  801047:	53                   	push   %ebx
  801048:	68 00 f0 7f 00       	push   $0x7ff000
  80104d:	53                   	push   %ebx
  80104e:	e8 d3 fd ff ff       	call   800e26 <sys_page_map>
  801053:	83 c4 20             	add    $0x20,%esp
  801056:	85 c0                	test   %eax,%eax
  801058:	78 54                	js     8010ae <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  80105a:	83 ec 08             	sub    $0x8,%esp
  80105d:	68 00 f0 7f 00       	push   $0x7ff000
  801062:	53                   	push   %ebx
  801063:	e8 00 fe ff ff       	call   800e68 <sys_page_unmap>
  801068:	83 c4 10             	add    $0x10,%esp
  80106b:	85 c0                	test   %eax,%eax
  80106d:	78 51                	js     8010c0 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  80106f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801072:	5b                   	pop    %ebx
  801073:	5e                   	pop    %esi
  801074:	5d                   	pop    %ebp
  801075:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  801076:	83 ec 04             	sub    $0x4,%esp
  801079:	68 0c 28 80 00       	push   $0x80280c
  80107e:	6a 1d                	push   $0x1d
  801080:	68 88 28 80 00       	push   $0x802888
  801085:	e8 a8 f2 ff ff       	call   800332 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  80108a:	50                   	push   %eax
  80108b:	68 44 28 80 00       	push   $0x802844
  801090:	6a 29                	push   $0x29
  801092:	68 88 28 80 00       	push   $0x802888
  801097:	e8 96 f2 ff ff       	call   800332 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  80109c:	50                   	push   %eax
  80109d:	68 68 28 80 00       	push   $0x802868
  8010a2:	6a 2e                	push   $0x2e
  8010a4:	68 88 28 80 00       	push   $0x802888
  8010a9:	e8 84 f2 ff ff       	call   800332 <_panic>
		panic("pgfault: page map failed (%e)", r);
  8010ae:	50                   	push   %eax
  8010af:	68 93 28 80 00       	push   $0x802893
  8010b4:	6a 30                	push   $0x30
  8010b6:	68 88 28 80 00       	push   $0x802888
  8010bb:	e8 72 f2 ff ff       	call   800332 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  8010c0:	50                   	push   %eax
  8010c1:	68 68 28 80 00       	push   $0x802868
  8010c6:	6a 32                	push   $0x32
  8010c8:	68 88 28 80 00       	push   $0x802888
  8010cd:	e8 60 f2 ff ff       	call   800332 <_panic>

008010d2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	57                   	push   %edi
  8010d6:	56                   	push   %esi
  8010d7:	53                   	push   %ebx
  8010d8:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  8010db:	68 d4 0f 80 00       	push   $0x800fd4
  8010e0:	e8 5d 0e 00 00       	call   801f42 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010e5:	b8 07 00 00 00       	mov    $0x7,%eax
  8010ea:	cd 30                	int    $0x30
  8010ec:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  8010ef:	83 c4 10             	add    $0x10,%esp
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	78 2d                	js     801123 <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  8010f6:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  8010fb:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8010ff:	75 73                	jne    801174 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  801101:	e8 9f fc ff ff       	call   800da5 <sys_getenvid>
  801106:	25 ff 03 00 00       	and    $0x3ff,%eax
  80110b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80110e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801113:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  801118:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  80111b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111e:	5b                   	pop    %ebx
  80111f:	5e                   	pop    %esi
  801120:	5f                   	pop    %edi
  801121:	5d                   	pop    %ebp
  801122:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  801123:	50                   	push   %eax
  801124:	68 b1 28 80 00       	push   $0x8028b1
  801129:	6a 78                	push   $0x78
  80112b:	68 88 28 80 00       	push   $0x802888
  801130:	e8 fd f1 ff ff       	call   800332 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  801135:	83 ec 0c             	sub    $0xc,%esp
  801138:	ff 75 e4             	push   -0x1c(%ebp)
  80113b:	57                   	push   %edi
  80113c:	ff 75 dc             	push   -0x24(%ebp)
  80113f:	57                   	push   %edi
  801140:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801143:	56                   	push   %esi
  801144:	e8 dd fc ff ff       	call   800e26 <sys_page_map>
	if(r<0) return r;
  801149:	83 c4 20             	add    $0x20,%esp
  80114c:	85 c0                	test   %eax,%eax
  80114e:	78 cb                	js     80111b <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  801150:	83 ec 0c             	sub    $0xc,%esp
  801153:	ff 75 e4             	push   -0x1c(%ebp)
  801156:	57                   	push   %edi
  801157:	56                   	push   %esi
  801158:	57                   	push   %edi
  801159:	56                   	push   %esi
  80115a:	e8 c7 fc ff ff       	call   800e26 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  80115f:	83 c4 20             	add    $0x20,%esp
  801162:	85 c0                	test   %eax,%eax
  801164:	78 76                	js     8011dc <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801166:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80116c:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801172:	74 75                	je     8011e9 <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  801174:	89 d8                	mov    %ebx,%eax
  801176:	c1 e8 16             	shr    $0x16,%eax
  801179:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801180:	a8 01                	test   $0x1,%al
  801182:	74 e2                	je     801166 <fork+0x94>
  801184:	89 de                	mov    %ebx,%esi
  801186:	c1 ee 0c             	shr    $0xc,%esi
  801189:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801190:	a8 01                	test   $0x1,%al
  801192:	74 d2                	je     801166 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  801194:	e8 0c fc ff ff       	call   800da5 <sys_getenvid>
  801199:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  80119c:	89 f7                	mov    %esi,%edi
  80119e:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  8011a1:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011a8:	89 c1                	mov    %eax,%ecx
  8011aa:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  8011b0:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  8011b3:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  8011ba:	f6 c6 04             	test   $0x4,%dh
  8011bd:	0f 85 72 ff ff ff    	jne    801135 <fork+0x63>
		perm &= ~PTE_W;
  8011c3:	25 05 0e 00 00       	and    $0xe05,%eax
  8011c8:	80 cc 08             	or     $0x8,%ah
  8011cb:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  8011d1:	0f 44 c1             	cmove  %ecx,%eax
  8011d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8011d7:	e9 59 ff ff ff       	jmp    801135 <fork+0x63>
  8011dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8011e1:	0f 4f c2             	cmovg  %edx,%eax
  8011e4:	e9 32 ff ff ff       	jmp    80111b <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  8011e9:	83 ec 04             	sub    $0x4,%esp
  8011ec:	6a 07                	push   $0x7
  8011ee:	68 00 f0 bf ee       	push   $0xeebff000
  8011f3:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8011f6:	57                   	push   %edi
  8011f7:	e8 e7 fb ff ff       	call   800de3 <sys_page_alloc>
	if(r<0) return r;
  8011fc:	83 c4 10             	add    $0x10,%esp
  8011ff:	85 c0                	test   %eax,%eax
  801201:	0f 88 14 ff ff ff    	js     80111b <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801207:	83 ec 08             	sub    $0x8,%esp
  80120a:	68 b8 1f 80 00       	push   $0x801fb8
  80120f:	57                   	push   %edi
  801210:	e8 19 fd ff ff       	call   800f2e <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	85 c0                	test   %eax,%eax
  80121a:	0f 88 fb fe ff ff    	js     80111b <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801220:	83 ec 08             	sub    $0x8,%esp
  801223:	6a 02                	push   $0x2
  801225:	57                   	push   %edi
  801226:	e8 7f fc ff ff       	call   800eaa <sys_env_set_status>
	if(r<0) return r;
  80122b:	83 c4 10             	add    $0x10,%esp
	return envid;
  80122e:	85 c0                	test   %eax,%eax
  801230:	0f 49 c7             	cmovns %edi,%eax
  801233:	e9 e3 fe ff ff       	jmp    80111b <fork+0x49>

00801238 <sfork>:

// Challenge!
int
sfork(void)
{
  801238:	55                   	push   %ebp
  801239:	89 e5                	mov    %esp,%ebp
  80123b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80123e:	68 c1 28 80 00       	push   $0x8028c1
  801243:	68 a1 00 00 00       	push   $0xa1
  801248:	68 88 28 80 00       	push   $0x802888
  80124d:	e8 e0 f0 ff ff       	call   800332 <_panic>

00801252 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801252:	55                   	push   %ebp
  801253:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801255:	8b 45 08             	mov    0x8(%ebp),%eax
  801258:	05 00 00 00 30       	add    $0x30000000,%eax
  80125d:	c1 e8 0c             	shr    $0xc,%eax
}
  801260:	5d                   	pop    %ebp
  801261:	c3                   	ret    

00801262 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801265:	8b 45 08             	mov    0x8(%ebp),%eax
  801268:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80126d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801272:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801277:	5d                   	pop    %ebp
  801278:	c3                   	ret    

00801279 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801279:	55                   	push   %ebp
  80127a:	89 e5                	mov    %esp,%ebp
  80127c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801281:	89 c2                	mov    %eax,%edx
  801283:	c1 ea 16             	shr    $0x16,%edx
  801286:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80128d:	f6 c2 01             	test   $0x1,%dl
  801290:	74 29                	je     8012bb <fd_alloc+0x42>
  801292:	89 c2                	mov    %eax,%edx
  801294:	c1 ea 0c             	shr    $0xc,%edx
  801297:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80129e:	f6 c2 01             	test   $0x1,%dl
  8012a1:	74 18                	je     8012bb <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8012a3:	05 00 10 00 00       	add    $0x1000,%eax
  8012a8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012ad:	75 d2                	jne    801281 <fd_alloc+0x8>
  8012af:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8012b4:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8012b9:	eb 05                	jmp    8012c0 <fd_alloc+0x47>
			return 0;
  8012bb:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8012c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c3:	89 02                	mov    %eax,(%edx)
}
  8012c5:	89 c8                	mov    %ecx,%eax
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    

008012c9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
  8012cc:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012cf:	83 f8 1f             	cmp    $0x1f,%eax
  8012d2:	77 30                	ja     801304 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012d4:	c1 e0 0c             	shl    $0xc,%eax
  8012d7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012dc:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8012e2:	f6 c2 01             	test   $0x1,%dl
  8012e5:	74 24                	je     80130b <fd_lookup+0x42>
  8012e7:	89 c2                	mov    %eax,%edx
  8012e9:	c1 ea 0c             	shr    $0xc,%edx
  8012ec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012f3:	f6 c2 01             	test   $0x1,%dl
  8012f6:	74 1a                	je     801312 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012fb:	89 02                	mov    %eax,(%edx)
	return 0;
  8012fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801302:	5d                   	pop    %ebp
  801303:	c3                   	ret    
		return -E_INVAL;
  801304:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801309:	eb f7                	jmp    801302 <fd_lookup+0x39>
		return -E_INVAL;
  80130b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801310:	eb f0                	jmp    801302 <fd_lookup+0x39>
  801312:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801317:	eb e9                	jmp    801302 <fd_lookup+0x39>

00801319 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801319:	55                   	push   %ebp
  80131a:	89 e5                	mov    %esp,%ebp
  80131c:	53                   	push   %ebx
  80131d:	83 ec 04             	sub    $0x4,%esp
  801320:	8b 55 08             	mov    0x8(%ebp),%edx
  801323:	b8 54 29 80 00       	mov    $0x802954,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  801328:	bb 08 30 80 00       	mov    $0x803008,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80132d:	39 13                	cmp    %edx,(%ebx)
  80132f:	74 32                	je     801363 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  801331:	83 c0 04             	add    $0x4,%eax
  801334:	8b 18                	mov    (%eax),%ebx
  801336:	85 db                	test   %ebx,%ebx
  801338:	75 f3                	jne    80132d <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80133a:	a1 00 40 80 00       	mov    0x804000,%eax
  80133f:	8b 40 48             	mov    0x48(%eax),%eax
  801342:	83 ec 04             	sub    $0x4,%esp
  801345:	52                   	push   %edx
  801346:	50                   	push   %eax
  801347:	68 d8 28 80 00       	push   $0x8028d8
  80134c:	e8 bc f0 ff ff       	call   80040d <cprintf>
	*dev = 0;
	return -E_INVAL;
  801351:	83 c4 10             	add    $0x10,%esp
  801354:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801359:	8b 55 0c             	mov    0xc(%ebp),%edx
  80135c:	89 1a                	mov    %ebx,(%edx)
}
  80135e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801361:	c9                   	leave  
  801362:	c3                   	ret    
			return 0;
  801363:	b8 00 00 00 00       	mov    $0x0,%eax
  801368:	eb ef                	jmp    801359 <dev_lookup+0x40>

0080136a <fd_close>:
{
  80136a:	55                   	push   %ebp
  80136b:	89 e5                	mov    %esp,%ebp
  80136d:	57                   	push   %edi
  80136e:	56                   	push   %esi
  80136f:	53                   	push   %ebx
  801370:	83 ec 24             	sub    $0x24,%esp
  801373:	8b 75 08             	mov    0x8(%ebp),%esi
  801376:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801379:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80137c:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80137d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801383:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801386:	50                   	push   %eax
  801387:	e8 3d ff ff ff       	call   8012c9 <fd_lookup>
  80138c:	89 c3                	mov    %eax,%ebx
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	85 c0                	test   %eax,%eax
  801393:	78 05                	js     80139a <fd_close+0x30>
	    || fd != fd2)
  801395:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801398:	74 16                	je     8013b0 <fd_close+0x46>
		return (must_exist ? r : 0);
  80139a:	89 f8                	mov    %edi,%eax
  80139c:	84 c0                	test   %al,%al
  80139e:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a3:	0f 44 d8             	cmove  %eax,%ebx
}
  8013a6:	89 d8                	mov    %ebx,%eax
  8013a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ab:	5b                   	pop    %ebx
  8013ac:	5e                   	pop    %esi
  8013ad:	5f                   	pop    %edi
  8013ae:	5d                   	pop    %ebp
  8013af:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013b0:	83 ec 08             	sub    $0x8,%esp
  8013b3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8013b6:	50                   	push   %eax
  8013b7:	ff 36                	push   (%esi)
  8013b9:	e8 5b ff ff ff       	call   801319 <dev_lookup>
  8013be:	89 c3                	mov    %eax,%ebx
  8013c0:	83 c4 10             	add    $0x10,%esp
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	78 1a                	js     8013e1 <fd_close+0x77>
		if (dev->dev_close)
  8013c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013ca:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8013cd:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	74 0b                	je     8013e1 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8013d6:	83 ec 0c             	sub    $0xc,%esp
  8013d9:	56                   	push   %esi
  8013da:	ff d0                	call   *%eax
  8013dc:	89 c3                	mov    %eax,%ebx
  8013de:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013e1:	83 ec 08             	sub    $0x8,%esp
  8013e4:	56                   	push   %esi
  8013e5:	6a 00                	push   $0x0
  8013e7:	e8 7c fa ff ff       	call   800e68 <sys_page_unmap>
	return r;
  8013ec:	83 c4 10             	add    $0x10,%esp
  8013ef:	eb b5                	jmp    8013a6 <fd_close+0x3c>

008013f1 <close>:

int
close(int fdnum)
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fa:	50                   	push   %eax
  8013fb:	ff 75 08             	push   0x8(%ebp)
  8013fe:	e8 c6 fe ff ff       	call   8012c9 <fd_lookup>
  801403:	83 c4 10             	add    $0x10,%esp
  801406:	85 c0                	test   %eax,%eax
  801408:	79 02                	jns    80140c <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80140a:	c9                   	leave  
  80140b:	c3                   	ret    
		return fd_close(fd, 1);
  80140c:	83 ec 08             	sub    $0x8,%esp
  80140f:	6a 01                	push   $0x1
  801411:	ff 75 f4             	push   -0xc(%ebp)
  801414:	e8 51 ff ff ff       	call   80136a <fd_close>
  801419:	83 c4 10             	add    $0x10,%esp
  80141c:	eb ec                	jmp    80140a <close+0x19>

0080141e <close_all>:

void
close_all(void)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	53                   	push   %ebx
  801422:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801425:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80142a:	83 ec 0c             	sub    $0xc,%esp
  80142d:	53                   	push   %ebx
  80142e:	e8 be ff ff ff       	call   8013f1 <close>
	for (i = 0; i < MAXFD; i++)
  801433:	83 c3 01             	add    $0x1,%ebx
  801436:	83 c4 10             	add    $0x10,%esp
  801439:	83 fb 20             	cmp    $0x20,%ebx
  80143c:	75 ec                	jne    80142a <close_all+0xc>
}
  80143e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801441:	c9                   	leave  
  801442:	c3                   	ret    

00801443 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
  801446:	57                   	push   %edi
  801447:	56                   	push   %esi
  801448:	53                   	push   %ebx
  801449:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80144c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80144f:	50                   	push   %eax
  801450:	ff 75 08             	push   0x8(%ebp)
  801453:	e8 71 fe ff ff       	call   8012c9 <fd_lookup>
  801458:	89 c3                	mov    %eax,%ebx
  80145a:	83 c4 10             	add    $0x10,%esp
  80145d:	85 c0                	test   %eax,%eax
  80145f:	78 7f                	js     8014e0 <dup+0x9d>
		return r;
	close(newfdnum);
  801461:	83 ec 0c             	sub    $0xc,%esp
  801464:	ff 75 0c             	push   0xc(%ebp)
  801467:	e8 85 ff ff ff       	call   8013f1 <close>

	newfd = INDEX2FD(newfdnum);
  80146c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80146f:	c1 e6 0c             	shl    $0xc,%esi
  801472:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80147b:	89 3c 24             	mov    %edi,(%esp)
  80147e:	e8 df fd ff ff       	call   801262 <fd2data>
  801483:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801485:	89 34 24             	mov    %esi,(%esp)
  801488:	e8 d5 fd ff ff       	call   801262 <fd2data>
  80148d:	83 c4 10             	add    $0x10,%esp
  801490:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801493:	89 d8                	mov    %ebx,%eax
  801495:	c1 e8 16             	shr    $0x16,%eax
  801498:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80149f:	a8 01                	test   $0x1,%al
  8014a1:	74 11                	je     8014b4 <dup+0x71>
  8014a3:	89 d8                	mov    %ebx,%eax
  8014a5:	c1 e8 0c             	shr    $0xc,%eax
  8014a8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014af:	f6 c2 01             	test   $0x1,%dl
  8014b2:	75 36                	jne    8014ea <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8014b4:	89 f8                	mov    %edi,%eax
  8014b6:	c1 e8 0c             	shr    $0xc,%eax
  8014b9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014c0:	83 ec 0c             	sub    $0xc,%esp
  8014c3:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c8:	50                   	push   %eax
  8014c9:	56                   	push   %esi
  8014ca:	6a 00                	push   $0x0
  8014cc:	57                   	push   %edi
  8014cd:	6a 00                	push   $0x0
  8014cf:	e8 52 f9 ff ff       	call   800e26 <sys_page_map>
  8014d4:	89 c3                	mov    %eax,%ebx
  8014d6:	83 c4 20             	add    $0x20,%esp
  8014d9:	85 c0                	test   %eax,%eax
  8014db:	78 33                	js     801510 <dup+0xcd>
		goto err;

	return newfdnum;
  8014dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014e0:	89 d8                	mov    %ebx,%eax
  8014e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014e5:	5b                   	pop    %ebx
  8014e6:	5e                   	pop    %esi
  8014e7:	5f                   	pop    %edi
  8014e8:	5d                   	pop    %ebp
  8014e9:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014ea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014f1:	83 ec 0c             	sub    $0xc,%esp
  8014f4:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f9:	50                   	push   %eax
  8014fa:	ff 75 d4             	push   -0x2c(%ebp)
  8014fd:	6a 00                	push   $0x0
  8014ff:	53                   	push   %ebx
  801500:	6a 00                	push   $0x0
  801502:	e8 1f f9 ff ff       	call   800e26 <sys_page_map>
  801507:	89 c3                	mov    %eax,%ebx
  801509:	83 c4 20             	add    $0x20,%esp
  80150c:	85 c0                	test   %eax,%eax
  80150e:	79 a4                	jns    8014b4 <dup+0x71>
	sys_page_unmap(0, newfd);
  801510:	83 ec 08             	sub    $0x8,%esp
  801513:	56                   	push   %esi
  801514:	6a 00                	push   $0x0
  801516:	e8 4d f9 ff ff       	call   800e68 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80151b:	83 c4 08             	add    $0x8,%esp
  80151e:	ff 75 d4             	push   -0x2c(%ebp)
  801521:	6a 00                	push   $0x0
  801523:	e8 40 f9 ff ff       	call   800e68 <sys_page_unmap>
	return r;
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	eb b3                	jmp    8014e0 <dup+0x9d>

0080152d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80152d:	55                   	push   %ebp
  80152e:	89 e5                	mov    %esp,%ebp
  801530:	56                   	push   %esi
  801531:	53                   	push   %ebx
  801532:	83 ec 18             	sub    $0x18,%esp
  801535:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801538:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80153b:	50                   	push   %eax
  80153c:	56                   	push   %esi
  80153d:	e8 87 fd ff ff       	call   8012c9 <fd_lookup>
  801542:	83 c4 10             	add    $0x10,%esp
  801545:	85 c0                	test   %eax,%eax
  801547:	78 3c                	js     801585 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801549:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80154c:	83 ec 08             	sub    $0x8,%esp
  80154f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801552:	50                   	push   %eax
  801553:	ff 33                	push   (%ebx)
  801555:	e8 bf fd ff ff       	call   801319 <dev_lookup>
  80155a:	83 c4 10             	add    $0x10,%esp
  80155d:	85 c0                	test   %eax,%eax
  80155f:	78 24                	js     801585 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801561:	8b 43 08             	mov    0x8(%ebx),%eax
  801564:	83 e0 03             	and    $0x3,%eax
  801567:	83 f8 01             	cmp    $0x1,%eax
  80156a:	74 20                	je     80158c <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80156c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80156f:	8b 40 08             	mov    0x8(%eax),%eax
  801572:	85 c0                	test   %eax,%eax
  801574:	74 37                	je     8015ad <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801576:	83 ec 04             	sub    $0x4,%esp
  801579:	ff 75 10             	push   0x10(%ebp)
  80157c:	ff 75 0c             	push   0xc(%ebp)
  80157f:	53                   	push   %ebx
  801580:	ff d0                	call   *%eax
  801582:	83 c4 10             	add    $0x10,%esp
}
  801585:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801588:	5b                   	pop    %ebx
  801589:	5e                   	pop    %esi
  80158a:	5d                   	pop    %ebp
  80158b:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80158c:	a1 00 40 80 00       	mov    0x804000,%eax
  801591:	8b 40 48             	mov    0x48(%eax),%eax
  801594:	83 ec 04             	sub    $0x4,%esp
  801597:	56                   	push   %esi
  801598:	50                   	push   %eax
  801599:	68 19 29 80 00       	push   $0x802919
  80159e:	e8 6a ee ff ff       	call   80040d <cprintf>
		return -E_INVAL;
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ab:	eb d8                	jmp    801585 <read+0x58>
		return -E_NOT_SUPP;
  8015ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015b2:	eb d1                	jmp    801585 <read+0x58>

008015b4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015b4:	55                   	push   %ebp
  8015b5:	89 e5                	mov    %esp,%ebp
  8015b7:	57                   	push   %edi
  8015b8:	56                   	push   %esi
  8015b9:	53                   	push   %ebx
  8015ba:	83 ec 0c             	sub    $0xc,%esp
  8015bd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015c0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015c3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015c8:	eb 02                	jmp    8015cc <readn+0x18>
  8015ca:	01 c3                	add    %eax,%ebx
  8015cc:	39 f3                	cmp    %esi,%ebx
  8015ce:	73 21                	jae    8015f1 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015d0:	83 ec 04             	sub    $0x4,%esp
  8015d3:	89 f0                	mov    %esi,%eax
  8015d5:	29 d8                	sub    %ebx,%eax
  8015d7:	50                   	push   %eax
  8015d8:	89 d8                	mov    %ebx,%eax
  8015da:	03 45 0c             	add    0xc(%ebp),%eax
  8015dd:	50                   	push   %eax
  8015de:	57                   	push   %edi
  8015df:	e8 49 ff ff ff       	call   80152d <read>
		if (m < 0)
  8015e4:	83 c4 10             	add    $0x10,%esp
  8015e7:	85 c0                	test   %eax,%eax
  8015e9:	78 04                	js     8015ef <readn+0x3b>
			return m;
		if (m == 0)
  8015eb:	75 dd                	jne    8015ca <readn+0x16>
  8015ed:	eb 02                	jmp    8015f1 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015ef:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8015f1:	89 d8                	mov    %ebx,%eax
  8015f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f6:	5b                   	pop    %ebx
  8015f7:	5e                   	pop    %esi
  8015f8:	5f                   	pop    %edi
  8015f9:	5d                   	pop    %ebp
  8015fa:	c3                   	ret    

008015fb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	56                   	push   %esi
  8015ff:	53                   	push   %ebx
  801600:	83 ec 18             	sub    $0x18,%esp
  801603:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801606:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801609:	50                   	push   %eax
  80160a:	53                   	push   %ebx
  80160b:	e8 b9 fc ff ff       	call   8012c9 <fd_lookup>
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	85 c0                	test   %eax,%eax
  801615:	78 37                	js     80164e <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801617:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80161a:	83 ec 08             	sub    $0x8,%esp
  80161d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801620:	50                   	push   %eax
  801621:	ff 36                	push   (%esi)
  801623:	e8 f1 fc ff ff       	call   801319 <dev_lookup>
  801628:	83 c4 10             	add    $0x10,%esp
  80162b:	85 c0                	test   %eax,%eax
  80162d:	78 1f                	js     80164e <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80162f:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801633:	74 20                	je     801655 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801635:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801638:	8b 40 0c             	mov    0xc(%eax),%eax
  80163b:	85 c0                	test   %eax,%eax
  80163d:	74 37                	je     801676 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80163f:	83 ec 04             	sub    $0x4,%esp
  801642:	ff 75 10             	push   0x10(%ebp)
  801645:	ff 75 0c             	push   0xc(%ebp)
  801648:	56                   	push   %esi
  801649:	ff d0                	call   *%eax
  80164b:	83 c4 10             	add    $0x10,%esp
}
  80164e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801651:	5b                   	pop    %ebx
  801652:	5e                   	pop    %esi
  801653:	5d                   	pop    %ebp
  801654:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801655:	a1 00 40 80 00       	mov    0x804000,%eax
  80165a:	8b 40 48             	mov    0x48(%eax),%eax
  80165d:	83 ec 04             	sub    $0x4,%esp
  801660:	53                   	push   %ebx
  801661:	50                   	push   %eax
  801662:	68 35 29 80 00       	push   $0x802935
  801667:	e8 a1 ed ff ff       	call   80040d <cprintf>
		return -E_INVAL;
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801674:	eb d8                	jmp    80164e <write+0x53>
		return -E_NOT_SUPP;
  801676:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80167b:	eb d1                	jmp    80164e <write+0x53>

0080167d <seek>:

int
seek(int fdnum, off_t offset)
{
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
  801680:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801683:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801686:	50                   	push   %eax
  801687:	ff 75 08             	push   0x8(%ebp)
  80168a:	e8 3a fc ff ff       	call   8012c9 <fd_lookup>
  80168f:	83 c4 10             	add    $0x10,%esp
  801692:	85 c0                	test   %eax,%eax
  801694:	78 0e                	js     8016a4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801696:	8b 55 0c             	mov    0xc(%ebp),%edx
  801699:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80169f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016a4:	c9                   	leave  
  8016a5:	c3                   	ret    

008016a6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	56                   	push   %esi
  8016aa:	53                   	push   %ebx
  8016ab:	83 ec 18             	sub    $0x18,%esp
  8016ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016b1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016b4:	50                   	push   %eax
  8016b5:	53                   	push   %ebx
  8016b6:	e8 0e fc ff ff       	call   8012c9 <fd_lookup>
  8016bb:	83 c4 10             	add    $0x10,%esp
  8016be:	85 c0                	test   %eax,%eax
  8016c0:	78 34                	js     8016f6 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016c2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8016c5:	83 ec 08             	sub    $0x8,%esp
  8016c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016cb:	50                   	push   %eax
  8016cc:	ff 36                	push   (%esi)
  8016ce:	e8 46 fc ff ff       	call   801319 <dev_lookup>
  8016d3:	83 c4 10             	add    $0x10,%esp
  8016d6:	85 c0                	test   %eax,%eax
  8016d8:	78 1c                	js     8016f6 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016da:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8016de:	74 1d                	je     8016fd <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8016e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e3:	8b 40 18             	mov    0x18(%eax),%eax
  8016e6:	85 c0                	test   %eax,%eax
  8016e8:	74 34                	je     80171e <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016ea:	83 ec 08             	sub    $0x8,%esp
  8016ed:	ff 75 0c             	push   0xc(%ebp)
  8016f0:	56                   	push   %esi
  8016f1:	ff d0                	call   *%eax
  8016f3:	83 c4 10             	add    $0x10,%esp
}
  8016f6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f9:	5b                   	pop    %ebx
  8016fa:	5e                   	pop    %esi
  8016fb:	5d                   	pop    %ebp
  8016fc:	c3                   	ret    
			thisenv->env_id, fdnum);
  8016fd:	a1 00 40 80 00       	mov    0x804000,%eax
  801702:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801705:	83 ec 04             	sub    $0x4,%esp
  801708:	53                   	push   %ebx
  801709:	50                   	push   %eax
  80170a:	68 f8 28 80 00       	push   $0x8028f8
  80170f:	e8 f9 ec ff ff       	call   80040d <cprintf>
		return -E_INVAL;
  801714:	83 c4 10             	add    $0x10,%esp
  801717:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80171c:	eb d8                	jmp    8016f6 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80171e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801723:	eb d1                	jmp    8016f6 <ftruncate+0x50>

00801725 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	56                   	push   %esi
  801729:	53                   	push   %ebx
  80172a:	83 ec 18             	sub    $0x18,%esp
  80172d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801730:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801733:	50                   	push   %eax
  801734:	ff 75 08             	push   0x8(%ebp)
  801737:	e8 8d fb ff ff       	call   8012c9 <fd_lookup>
  80173c:	83 c4 10             	add    $0x10,%esp
  80173f:	85 c0                	test   %eax,%eax
  801741:	78 49                	js     80178c <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801743:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801746:	83 ec 08             	sub    $0x8,%esp
  801749:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174c:	50                   	push   %eax
  80174d:	ff 36                	push   (%esi)
  80174f:	e8 c5 fb ff ff       	call   801319 <dev_lookup>
  801754:	83 c4 10             	add    $0x10,%esp
  801757:	85 c0                	test   %eax,%eax
  801759:	78 31                	js     80178c <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80175b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80175e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801762:	74 2f                	je     801793 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801764:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801767:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80176e:	00 00 00 
	stat->st_isdir = 0;
  801771:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801778:	00 00 00 
	stat->st_dev = dev;
  80177b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801781:	83 ec 08             	sub    $0x8,%esp
  801784:	53                   	push   %ebx
  801785:	56                   	push   %esi
  801786:	ff 50 14             	call   *0x14(%eax)
  801789:	83 c4 10             	add    $0x10,%esp
}
  80178c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80178f:	5b                   	pop    %ebx
  801790:	5e                   	pop    %esi
  801791:	5d                   	pop    %ebp
  801792:	c3                   	ret    
		return -E_NOT_SUPP;
  801793:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801798:	eb f2                	jmp    80178c <fstat+0x67>

0080179a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	56                   	push   %esi
  80179e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80179f:	83 ec 08             	sub    $0x8,%esp
  8017a2:	6a 00                	push   $0x0
  8017a4:	ff 75 08             	push   0x8(%ebp)
  8017a7:	e8 e4 01 00 00       	call   801990 <open>
  8017ac:	89 c3                	mov    %eax,%ebx
  8017ae:	83 c4 10             	add    $0x10,%esp
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	78 1b                	js     8017d0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8017b5:	83 ec 08             	sub    $0x8,%esp
  8017b8:	ff 75 0c             	push   0xc(%ebp)
  8017bb:	50                   	push   %eax
  8017bc:	e8 64 ff ff ff       	call   801725 <fstat>
  8017c1:	89 c6                	mov    %eax,%esi
	close(fd);
  8017c3:	89 1c 24             	mov    %ebx,(%esp)
  8017c6:	e8 26 fc ff ff       	call   8013f1 <close>
	return r;
  8017cb:	83 c4 10             	add    $0x10,%esp
  8017ce:	89 f3                	mov    %esi,%ebx
}
  8017d0:	89 d8                	mov    %ebx,%eax
  8017d2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d5:	5b                   	pop    %ebx
  8017d6:	5e                   	pop    %esi
  8017d7:	5d                   	pop    %ebp
  8017d8:	c3                   	ret    

008017d9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	56                   	push   %esi
  8017dd:	53                   	push   %ebx
  8017de:	89 c6                	mov    %eax,%esi
  8017e0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017e2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8017e9:	74 27                	je     801812 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017eb:	6a 07                	push   $0x7
  8017ed:	68 00 50 80 00       	push   $0x805000
  8017f2:	56                   	push   %esi
  8017f3:	ff 35 00 60 80 00    	push   0x806000
  8017f9:	e8 47 08 00 00       	call   802045 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017fe:	83 c4 0c             	add    $0xc,%esp
  801801:	6a 00                	push   $0x0
  801803:	53                   	push   %ebx
  801804:	6a 00                	push   $0x0
  801806:	e8 d3 07 00 00       	call   801fde <ipc_recv>
}
  80180b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80180e:	5b                   	pop    %ebx
  80180f:	5e                   	pop    %esi
  801810:	5d                   	pop    %ebp
  801811:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801812:	83 ec 0c             	sub    $0xc,%esp
  801815:	6a 01                	push   $0x1
  801817:	e8 7d 08 00 00       	call   802099 <ipc_find_env>
  80181c:	a3 00 60 80 00       	mov    %eax,0x806000
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	eb c5                	jmp    8017eb <fsipc+0x12>

00801826 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80182c:	8b 45 08             	mov    0x8(%ebp),%eax
  80182f:	8b 40 0c             	mov    0xc(%eax),%eax
  801832:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801837:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80183f:	ba 00 00 00 00       	mov    $0x0,%edx
  801844:	b8 02 00 00 00       	mov    $0x2,%eax
  801849:	e8 8b ff ff ff       	call   8017d9 <fsipc>
}
  80184e:	c9                   	leave  
  80184f:	c3                   	ret    

00801850 <devfile_flush>:
{
  801850:	55                   	push   %ebp
  801851:	89 e5                	mov    %esp,%ebp
  801853:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801856:	8b 45 08             	mov    0x8(%ebp),%eax
  801859:	8b 40 0c             	mov    0xc(%eax),%eax
  80185c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801861:	ba 00 00 00 00       	mov    $0x0,%edx
  801866:	b8 06 00 00 00       	mov    $0x6,%eax
  80186b:	e8 69 ff ff ff       	call   8017d9 <fsipc>
}
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <devfile_stat>:
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	53                   	push   %ebx
  801876:	83 ec 04             	sub    $0x4,%esp
  801879:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80187c:	8b 45 08             	mov    0x8(%ebp),%eax
  80187f:	8b 40 0c             	mov    0xc(%eax),%eax
  801882:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801887:	ba 00 00 00 00       	mov    $0x0,%edx
  80188c:	b8 05 00 00 00       	mov    $0x5,%eax
  801891:	e8 43 ff ff ff       	call   8017d9 <fsipc>
  801896:	85 c0                	test   %eax,%eax
  801898:	78 2c                	js     8018c6 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80189a:	83 ec 08             	sub    $0x8,%esp
  80189d:	68 00 50 80 00       	push   $0x805000
  8018a2:	53                   	push   %ebx
  8018a3:	e8 3f f1 ff ff       	call   8009e7 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018a8:	a1 80 50 80 00       	mov    0x805080,%eax
  8018ad:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8018b3:	a1 84 50 80 00       	mov    0x805084,%eax
  8018b8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8018be:	83 c4 10             	add    $0x10,%esp
  8018c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c9:	c9                   	leave  
  8018ca:	c3                   	ret    

008018cb <devfile_write>:
{
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	83 ec 0c             	sub    $0xc,%esp
  8018d1:	8b 45 10             	mov    0x10(%ebp),%eax
  8018d4:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018d9:	39 d0                	cmp    %edx,%eax
  8018db:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018de:	8b 55 08             	mov    0x8(%ebp),%edx
  8018e1:	8b 52 0c             	mov    0xc(%edx),%edx
  8018e4:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018ea:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018ef:	50                   	push   %eax
  8018f0:	ff 75 0c             	push   0xc(%ebp)
  8018f3:	68 08 50 80 00       	push   $0x805008
  8018f8:	e8 80 f2 ff ff       	call   800b7d <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8018fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801902:	b8 04 00 00 00       	mov    $0x4,%eax
  801907:	e8 cd fe ff ff       	call   8017d9 <fsipc>
}
  80190c:	c9                   	leave  
  80190d:	c3                   	ret    

0080190e <devfile_read>:
{
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	56                   	push   %esi
  801912:	53                   	push   %ebx
  801913:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801916:	8b 45 08             	mov    0x8(%ebp),%eax
  801919:	8b 40 0c             	mov    0xc(%eax),%eax
  80191c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801921:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801927:	ba 00 00 00 00       	mov    $0x0,%edx
  80192c:	b8 03 00 00 00       	mov    $0x3,%eax
  801931:	e8 a3 fe ff ff       	call   8017d9 <fsipc>
  801936:	89 c3                	mov    %eax,%ebx
  801938:	85 c0                	test   %eax,%eax
  80193a:	78 1f                	js     80195b <devfile_read+0x4d>
	assert(r <= n);
  80193c:	39 f0                	cmp    %esi,%eax
  80193e:	77 24                	ja     801964 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801940:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801945:	7f 33                	jg     80197a <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801947:	83 ec 04             	sub    $0x4,%esp
  80194a:	50                   	push   %eax
  80194b:	68 00 50 80 00       	push   $0x805000
  801950:	ff 75 0c             	push   0xc(%ebp)
  801953:	e8 25 f2 ff ff       	call   800b7d <memmove>
	return r;
  801958:	83 c4 10             	add    $0x10,%esp
}
  80195b:	89 d8                	mov    %ebx,%eax
  80195d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801960:	5b                   	pop    %ebx
  801961:	5e                   	pop    %esi
  801962:	5d                   	pop    %ebp
  801963:	c3                   	ret    
	assert(r <= n);
  801964:	68 64 29 80 00       	push   $0x802964
  801969:	68 6b 29 80 00       	push   $0x80296b
  80196e:	6a 7c                	push   $0x7c
  801970:	68 80 29 80 00       	push   $0x802980
  801975:	e8 b8 e9 ff ff       	call   800332 <_panic>
	assert(r <= PGSIZE);
  80197a:	68 8b 29 80 00       	push   $0x80298b
  80197f:	68 6b 29 80 00       	push   $0x80296b
  801984:	6a 7d                	push   $0x7d
  801986:	68 80 29 80 00       	push   $0x802980
  80198b:	e8 a2 e9 ff ff       	call   800332 <_panic>

00801990 <open>:
{
  801990:	55                   	push   %ebp
  801991:	89 e5                	mov    %esp,%ebp
  801993:	56                   	push   %esi
  801994:	53                   	push   %ebx
  801995:	83 ec 1c             	sub    $0x1c,%esp
  801998:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80199b:	56                   	push   %esi
  80199c:	e8 0b f0 ff ff       	call   8009ac <strlen>
  8019a1:	83 c4 10             	add    $0x10,%esp
  8019a4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8019a9:	7f 6c                	jg     801a17 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8019ab:	83 ec 0c             	sub    $0xc,%esp
  8019ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b1:	50                   	push   %eax
  8019b2:	e8 c2 f8 ff ff       	call   801279 <fd_alloc>
  8019b7:	89 c3                	mov    %eax,%ebx
  8019b9:	83 c4 10             	add    $0x10,%esp
  8019bc:	85 c0                	test   %eax,%eax
  8019be:	78 3c                	js     8019fc <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8019c0:	83 ec 08             	sub    $0x8,%esp
  8019c3:	56                   	push   %esi
  8019c4:	68 00 50 80 00       	push   $0x805000
  8019c9:	e8 19 f0 ff ff       	call   8009e7 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8019ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d1:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019d6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019d9:	b8 01 00 00 00       	mov    $0x1,%eax
  8019de:	e8 f6 fd ff ff       	call   8017d9 <fsipc>
  8019e3:	89 c3                	mov    %eax,%ebx
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	78 19                	js     801a05 <open+0x75>
	return fd2num(fd);
  8019ec:	83 ec 0c             	sub    $0xc,%esp
  8019ef:	ff 75 f4             	push   -0xc(%ebp)
  8019f2:	e8 5b f8 ff ff       	call   801252 <fd2num>
  8019f7:	89 c3                	mov    %eax,%ebx
  8019f9:	83 c4 10             	add    $0x10,%esp
}
  8019fc:	89 d8                	mov    %ebx,%eax
  8019fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a01:	5b                   	pop    %ebx
  801a02:	5e                   	pop    %esi
  801a03:	5d                   	pop    %ebp
  801a04:	c3                   	ret    
		fd_close(fd, 0);
  801a05:	83 ec 08             	sub    $0x8,%esp
  801a08:	6a 00                	push   $0x0
  801a0a:	ff 75 f4             	push   -0xc(%ebp)
  801a0d:	e8 58 f9 ff ff       	call   80136a <fd_close>
		return r;
  801a12:	83 c4 10             	add    $0x10,%esp
  801a15:	eb e5                	jmp    8019fc <open+0x6c>
		return -E_BAD_PATH;
  801a17:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a1c:	eb de                	jmp    8019fc <open+0x6c>

00801a1e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a1e:	55                   	push   %ebp
  801a1f:	89 e5                	mov    %esp,%ebp
  801a21:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a24:	ba 00 00 00 00       	mov    $0x0,%edx
  801a29:	b8 08 00 00 00       	mov    $0x8,%eax
  801a2e:	e8 a6 fd ff ff       	call   8017d9 <fsipc>
}
  801a33:	c9                   	leave  
  801a34:	c3                   	ret    

00801a35 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	56                   	push   %esi
  801a39:	53                   	push   %ebx
  801a3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a3d:	83 ec 0c             	sub    $0xc,%esp
  801a40:	ff 75 08             	push   0x8(%ebp)
  801a43:	e8 1a f8 ff ff       	call   801262 <fd2data>
  801a48:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a4a:	83 c4 08             	add    $0x8,%esp
  801a4d:	68 97 29 80 00       	push   $0x802997
  801a52:	53                   	push   %ebx
  801a53:	e8 8f ef ff ff       	call   8009e7 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a58:	8b 46 04             	mov    0x4(%esi),%eax
  801a5b:	2b 06                	sub    (%esi),%eax
  801a5d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a63:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a6a:	00 00 00 
	stat->st_dev = &devpipe;
  801a6d:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801a74:	30 80 00 
	return 0;
}
  801a77:	b8 00 00 00 00       	mov    $0x0,%eax
  801a7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7f:	5b                   	pop    %ebx
  801a80:	5e                   	pop    %esi
  801a81:	5d                   	pop    %ebp
  801a82:	c3                   	ret    

00801a83 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a83:	55                   	push   %ebp
  801a84:	89 e5                	mov    %esp,%ebp
  801a86:	53                   	push   %ebx
  801a87:	83 ec 0c             	sub    $0xc,%esp
  801a8a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a8d:	53                   	push   %ebx
  801a8e:	6a 00                	push   $0x0
  801a90:	e8 d3 f3 ff ff       	call   800e68 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a95:	89 1c 24             	mov    %ebx,(%esp)
  801a98:	e8 c5 f7 ff ff       	call   801262 <fd2data>
  801a9d:	83 c4 08             	add    $0x8,%esp
  801aa0:	50                   	push   %eax
  801aa1:	6a 00                	push   $0x0
  801aa3:	e8 c0 f3 ff ff       	call   800e68 <sys_page_unmap>
}
  801aa8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aab:	c9                   	leave  
  801aac:	c3                   	ret    

00801aad <_pipeisclosed>:
{
  801aad:	55                   	push   %ebp
  801aae:	89 e5                	mov    %esp,%ebp
  801ab0:	57                   	push   %edi
  801ab1:	56                   	push   %esi
  801ab2:	53                   	push   %ebx
  801ab3:	83 ec 1c             	sub    $0x1c,%esp
  801ab6:	89 c7                	mov    %eax,%edi
  801ab8:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801aba:	a1 00 40 80 00       	mov    0x804000,%eax
  801abf:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ac2:	83 ec 0c             	sub    $0xc,%esp
  801ac5:	57                   	push   %edi
  801ac6:	e8 07 06 00 00       	call   8020d2 <pageref>
  801acb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ace:	89 34 24             	mov    %esi,(%esp)
  801ad1:	e8 fc 05 00 00       	call   8020d2 <pageref>
		nn = thisenv->env_runs;
  801ad6:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801adc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	39 cb                	cmp    %ecx,%ebx
  801ae4:	74 1b                	je     801b01 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801ae6:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ae9:	75 cf                	jne    801aba <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aeb:	8b 42 58             	mov    0x58(%edx),%eax
  801aee:	6a 01                	push   $0x1
  801af0:	50                   	push   %eax
  801af1:	53                   	push   %ebx
  801af2:	68 9e 29 80 00       	push   $0x80299e
  801af7:	e8 11 e9 ff ff       	call   80040d <cprintf>
  801afc:	83 c4 10             	add    $0x10,%esp
  801aff:	eb b9                	jmp    801aba <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801b01:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801b04:	0f 94 c0             	sete   %al
  801b07:	0f b6 c0             	movzbl %al,%eax
}
  801b0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0d:	5b                   	pop    %ebx
  801b0e:	5e                   	pop    %esi
  801b0f:	5f                   	pop    %edi
  801b10:	5d                   	pop    %ebp
  801b11:	c3                   	ret    

00801b12 <devpipe_write>:
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	57                   	push   %edi
  801b16:	56                   	push   %esi
  801b17:	53                   	push   %ebx
  801b18:	83 ec 28             	sub    $0x28,%esp
  801b1b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801b1e:	56                   	push   %esi
  801b1f:	e8 3e f7 ff ff       	call   801262 <fd2data>
  801b24:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b26:	83 c4 10             	add    $0x10,%esp
  801b29:	bf 00 00 00 00       	mov    $0x0,%edi
  801b2e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b31:	75 09                	jne    801b3c <devpipe_write+0x2a>
	return i;
  801b33:	89 f8                	mov    %edi,%eax
  801b35:	eb 23                	jmp    801b5a <devpipe_write+0x48>
			sys_yield();
  801b37:	e8 88 f2 ff ff       	call   800dc4 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b3c:	8b 43 04             	mov    0x4(%ebx),%eax
  801b3f:	8b 0b                	mov    (%ebx),%ecx
  801b41:	8d 51 20             	lea    0x20(%ecx),%edx
  801b44:	39 d0                	cmp    %edx,%eax
  801b46:	72 1a                	jb     801b62 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801b48:	89 da                	mov    %ebx,%edx
  801b4a:	89 f0                	mov    %esi,%eax
  801b4c:	e8 5c ff ff ff       	call   801aad <_pipeisclosed>
  801b51:	85 c0                	test   %eax,%eax
  801b53:	74 e2                	je     801b37 <devpipe_write+0x25>
				return 0;
  801b55:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b5a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5d:	5b                   	pop    %ebx
  801b5e:	5e                   	pop    %esi
  801b5f:	5f                   	pop    %edi
  801b60:	5d                   	pop    %ebp
  801b61:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b65:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b69:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b6c:	89 c2                	mov    %eax,%edx
  801b6e:	c1 fa 1f             	sar    $0x1f,%edx
  801b71:	89 d1                	mov    %edx,%ecx
  801b73:	c1 e9 1b             	shr    $0x1b,%ecx
  801b76:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b79:	83 e2 1f             	and    $0x1f,%edx
  801b7c:	29 ca                	sub    %ecx,%edx
  801b7e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b82:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b86:	83 c0 01             	add    $0x1,%eax
  801b89:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801b8c:	83 c7 01             	add    $0x1,%edi
  801b8f:	eb 9d                	jmp    801b2e <devpipe_write+0x1c>

00801b91 <devpipe_read>:
{
  801b91:	55                   	push   %ebp
  801b92:	89 e5                	mov    %esp,%ebp
  801b94:	57                   	push   %edi
  801b95:	56                   	push   %esi
  801b96:	53                   	push   %ebx
  801b97:	83 ec 18             	sub    $0x18,%esp
  801b9a:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801b9d:	57                   	push   %edi
  801b9e:	e8 bf f6 ff ff       	call   801262 <fd2data>
  801ba3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ba5:	83 c4 10             	add    $0x10,%esp
  801ba8:	be 00 00 00 00       	mov    $0x0,%esi
  801bad:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bb0:	75 13                	jne    801bc5 <devpipe_read+0x34>
	return i;
  801bb2:	89 f0                	mov    %esi,%eax
  801bb4:	eb 02                	jmp    801bb8 <devpipe_read+0x27>
				return i;
  801bb6:	89 f0                	mov    %esi,%eax
}
  801bb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bbb:	5b                   	pop    %ebx
  801bbc:	5e                   	pop    %esi
  801bbd:	5f                   	pop    %edi
  801bbe:	5d                   	pop    %ebp
  801bbf:	c3                   	ret    
			sys_yield();
  801bc0:	e8 ff f1 ff ff       	call   800dc4 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801bc5:	8b 03                	mov    (%ebx),%eax
  801bc7:	3b 43 04             	cmp    0x4(%ebx),%eax
  801bca:	75 18                	jne    801be4 <devpipe_read+0x53>
			if (i > 0)
  801bcc:	85 f6                	test   %esi,%esi
  801bce:	75 e6                	jne    801bb6 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801bd0:	89 da                	mov    %ebx,%edx
  801bd2:	89 f8                	mov    %edi,%eax
  801bd4:	e8 d4 fe ff ff       	call   801aad <_pipeisclosed>
  801bd9:	85 c0                	test   %eax,%eax
  801bdb:	74 e3                	je     801bc0 <devpipe_read+0x2f>
				return 0;
  801bdd:	b8 00 00 00 00       	mov    $0x0,%eax
  801be2:	eb d4                	jmp    801bb8 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801be4:	99                   	cltd   
  801be5:	c1 ea 1b             	shr    $0x1b,%edx
  801be8:	01 d0                	add    %edx,%eax
  801bea:	83 e0 1f             	and    $0x1f,%eax
  801bed:	29 d0                	sub    %edx,%eax
  801bef:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801bf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bf7:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801bfa:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801bfd:	83 c6 01             	add    $0x1,%esi
  801c00:	eb ab                	jmp    801bad <devpipe_read+0x1c>

00801c02 <pipe>:
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	56                   	push   %esi
  801c06:	53                   	push   %ebx
  801c07:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801c0a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c0d:	50                   	push   %eax
  801c0e:	e8 66 f6 ff ff       	call   801279 <fd_alloc>
  801c13:	89 c3                	mov    %eax,%ebx
  801c15:	83 c4 10             	add    $0x10,%esp
  801c18:	85 c0                	test   %eax,%eax
  801c1a:	0f 88 23 01 00 00    	js     801d43 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c20:	83 ec 04             	sub    $0x4,%esp
  801c23:	68 07 04 00 00       	push   $0x407
  801c28:	ff 75 f4             	push   -0xc(%ebp)
  801c2b:	6a 00                	push   $0x0
  801c2d:	e8 b1 f1 ff ff       	call   800de3 <sys_page_alloc>
  801c32:	89 c3                	mov    %eax,%ebx
  801c34:	83 c4 10             	add    $0x10,%esp
  801c37:	85 c0                	test   %eax,%eax
  801c39:	0f 88 04 01 00 00    	js     801d43 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801c3f:	83 ec 0c             	sub    $0xc,%esp
  801c42:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c45:	50                   	push   %eax
  801c46:	e8 2e f6 ff ff       	call   801279 <fd_alloc>
  801c4b:	89 c3                	mov    %eax,%ebx
  801c4d:	83 c4 10             	add    $0x10,%esp
  801c50:	85 c0                	test   %eax,%eax
  801c52:	0f 88 db 00 00 00    	js     801d33 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c58:	83 ec 04             	sub    $0x4,%esp
  801c5b:	68 07 04 00 00       	push   $0x407
  801c60:	ff 75 f0             	push   -0x10(%ebp)
  801c63:	6a 00                	push   $0x0
  801c65:	e8 79 f1 ff ff       	call   800de3 <sys_page_alloc>
  801c6a:	89 c3                	mov    %eax,%ebx
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	85 c0                	test   %eax,%eax
  801c71:	0f 88 bc 00 00 00    	js     801d33 <pipe+0x131>
	va = fd2data(fd0);
  801c77:	83 ec 0c             	sub    $0xc,%esp
  801c7a:	ff 75 f4             	push   -0xc(%ebp)
  801c7d:	e8 e0 f5 ff ff       	call   801262 <fd2data>
  801c82:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c84:	83 c4 0c             	add    $0xc,%esp
  801c87:	68 07 04 00 00       	push   $0x407
  801c8c:	50                   	push   %eax
  801c8d:	6a 00                	push   $0x0
  801c8f:	e8 4f f1 ff ff       	call   800de3 <sys_page_alloc>
  801c94:	89 c3                	mov    %eax,%ebx
  801c96:	83 c4 10             	add    $0x10,%esp
  801c99:	85 c0                	test   %eax,%eax
  801c9b:	0f 88 82 00 00 00    	js     801d23 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ca1:	83 ec 0c             	sub    $0xc,%esp
  801ca4:	ff 75 f0             	push   -0x10(%ebp)
  801ca7:	e8 b6 f5 ff ff       	call   801262 <fd2data>
  801cac:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801cb3:	50                   	push   %eax
  801cb4:	6a 00                	push   $0x0
  801cb6:	56                   	push   %esi
  801cb7:	6a 00                	push   $0x0
  801cb9:	e8 68 f1 ff ff       	call   800e26 <sys_page_map>
  801cbe:	89 c3                	mov    %eax,%ebx
  801cc0:	83 c4 20             	add    $0x20,%esp
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	78 4e                	js     801d15 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801cc7:	a1 24 30 80 00       	mov    0x803024,%eax
  801ccc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ccf:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801cd1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801cd4:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801cdb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801cde:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801ce0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ce3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801cea:	83 ec 0c             	sub    $0xc,%esp
  801ced:	ff 75 f4             	push   -0xc(%ebp)
  801cf0:	e8 5d f5 ff ff       	call   801252 <fd2num>
  801cf5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cf8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cfa:	83 c4 04             	add    $0x4,%esp
  801cfd:	ff 75 f0             	push   -0x10(%ebp)
  801d00:	e8 4d f5 ff ff       	call   801252 <fd2num>
  801d05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d08:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d0b:	83 c4 10             	add    $0x10,%esp
  801d0e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801d13:	eb 2e                	jmp    801d43 <pipe+0x141>
	sys_page_unmap(0, va);
  801d15:	83 ec 08             	sub    $0x8,%esp
  801d18:	56                   	push   %esi
  801d19:	6a 00                	push   $0x0
  801d1b:	e8 48 f1 ff ff       	call   800e68 <sys_page_unmap>
  801d20:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801d23:	83 ec 08             	sub    $0x8,%esp
  801d26:	ff 75 f0             	push   -0x10(%ebp)
  801d29:	6a 00                	push   $0x0
  801d2b:	e8 38 f1 ff ff       	call   800e68 <sys_page_unmap>
  801d30:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801d33:	83 ec 08             	sub    $0x8,%esp
  801d36:	ff 75 f4             	push   -0xc(%ebp)
  801d39:	6a 00                	push   $0x0
  801d3b:	e8 28 f1 ff ff       	call   800e68 <sys_page_unmap>
  801d40:	83 c4 10             	add    $0x10,%esp
}
  801d43:	89 d8                	mov    %ebx,%eax
  801d45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d48:	5b                   	pop    %ebx
  801d49:	5e                   	pop    %esi
  801d4a:	5d                   	pop    %ebp
  801d4b:	c3                   	ret    

00801d4c <pipeisclosed>:
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d55:	50                   	push   %eax
  801d56:	ff 75 08             	push   0x8(%ebp)
  801d59:	e8 6b f5 ff ff       	call   8012c9 <fd_lookup>
  801d5e:	83 c4 10             	add    $0x10,%esp
  801d61:	85 c0                	test   %eax,%eax
  801d63:	78 18                	js     801d7d <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801d65:	83 ec 0c             	sub    $0xc,%esp
  801d68:	ff 75 f4             	push   -0xc(%ebp)
  801d6b:	e8 f2 f4 ff ff       	call   801262 <fd2data>
  801d70:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801d72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d75:	e8 33 fd ff ff       	call   801aad <_pipeisclosed>
  801d7a:	83 c4 10             	add    $0x10,%esp
}
  801d7d:	c9                   	leave  
  801d7e:	c3                   	ret    

00801d7f <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801d7f:	55                   	push   %ebp
  801d80:	89 e5                	mov    %esp,%ebp
  801d82:	56                   	push   %esi
  801d83:	53                   	push   %ebx
  801d84:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801d87:	85 f6                	test   %esi,%esi
  801d89:	74 13                	je     801d9e <wait+0x1f>
	e = &envs[ENVX(envid)];
  801d8b:	89 f3                	mov    %esi,%ebx
  801d8d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801d93:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801d96:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801d9c:	eb 1b                	jmp    801db9 <wait+0x3a>
	assert(envid != 0);
  801d9e:	68 b6 29 80 00       	push   $0x8029b6
  801da3:	68 6b 29 80 00       	push   $0x80296b
  801da8:	6a 09                	push   $0x9
  801daa:	68 c1 29 80 00       	push   $0x8029c1
  801daf:	e8 7e e5 ff ff       	call   800332 <_panic>
		sys_yield();
  801db4:	e8 0b f0 ff ff       	call   800dc4 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801db9:	8b 43 48             	mov    0x48(%ebx),%eax
  801dbc:	39 f0                	cmp    %esi,%eax
  801dbe:	75 07                	jne    801dc7 <wait+0x48>
  801dc0:	8b 43 54             	mov    0x54(%ebx),%eax
  801dc3:	85 c0                	test   %eax,%eax
  801dc5:	75 ed                	jne    801db4 <wait+0x35>
}
  801dc7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dca:	5b                   	pop    %ebx
  801dcb:	5e                   	pop    %esi
  801dcc:	5d                   	pop    %ebp
  801dcd:	c3                   	ret    

00801dce <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801dce:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd3:	c3                   	ret    

00801dd4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801dda:	68 cc 29 80 00       	push   $0x8029cc
  801ddf:	ff 75 0c             	push   0xc(%ebp)
  801de2:	e8 00 ec ff ff       	call   8009e7 <strcpy>
	return 0;
}
  801de7:	b8 00 00 00 00       	mov    $0x0,%eax
  801dec:	c9                   	leave  
  801ded:	c3                   	ret    

00801dee <devcons_write>:
{
  801dee:	55                   	push   %ebp
  801def:	89 e5                	mov    %esp,%ebp
  801df1:	57                   	push   %edi
  801df2:	56                   	push   %esi
  801df3:	53                   	push   %ebx
  801df4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801dfa:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801dff:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801e05:	eb 2e                	jmp    801e35 <devcons_write+0x47>
		m = n - tot;
  801e07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e0a:	29 f3                	sub    %esi,%ebx
  801e0c:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801e11:	39 c3                	cmp    %eax,%ebx
  801e13:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801e16:	83 ec 04             	sub    $0x4,%esp
  801e19:	53                   	push   %ebx
  801e1a:	89 f0                	mov    %esi,%eax
  801e1c:	03 45 0c             	add    0xc(%ebp),%eax
  801e1f:	50                   	push   %eax
  801e20:	57                   	push   %edi
  801e21:	e8 57 ed ff ff       	call   800b7d <memmove>
		sys_cputs(buf, m);
  801e26:	83 c4 08             	add    $0x8,%esp
  801e29:	53                   	push   %ebx
  801e2a:	57                   	push   %edi
  801e2b:	e8 f7 ee ff ff       	call   800d27 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801e30:	01 de                	add    %ebx,%esi
  801e32:	83 c4 10             	add    $0x10,%esp
  801e35:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e38:	72 cd                	jb     801e07 <devcons_write+0x19>
}
  801e3a:	89 f0                	mov    %esi,%eax
  801e3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e3f:	5b                   	pop    %ebx
  801e40:	5e                   	pop    %esi
  801e41:	5f                   	pop    %edi
  801e42:	5d                   	pop    %ebp
  801e43:	c3                   	ret    

00801e44 <devcons_read>:
{
  801e44:	55                   	push   %ebp
  801e45:	89 e5                	mov    %esp,%ebp
  801e47:	83 ec 08             	sub    $0x8,%esp
  801e4a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801e4f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e53:	75 07                	jne    801e5c <devcons_read+0x18>
  801e55:	eb 1f                	jmp    801e76 <devcons_read+0x32>
		sys_yield();
  801e57:	e8 68 ef ff ff       	call   800dc4 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801e5c:	e8 e4 ee ff ff       	call   800d45 <sys_cgetc>
  801e61:	85 c0                	test   %eax,%eax
  801e63:	74 f2                	je     801e57 <devcons_read+0x13>
	if (c < 0)
  801e65:	78 0f                	js     801e76 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801e67:	83 f8 04             	cmp    $0x4,%eax
  801e6a:	74 0c                	je     801e78 <devcons_read+0x34>
	*(char*)vbuf = c;
  801e6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e6f:	88 02                	mov    %al,(%edx)
	return 1;
  801e71:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801e76:	c9                   	leave  
  801e77:	c3                   	ret    
		return 0;
  801e78:	b8 00 00 00 00       	mov    $0x0,%eax
  801e7d:	eb f7                	jmp    801e76 <devcons_read+0x32>

00801e7f <cputchar>:
{
  801e7f:	55                   	push   %ebp
  801e80:	89 e5                	mov    %esp,%ebp
  801e82:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e85:	8b 45 08             	mov    0x8(%ebp),%eax
  801e88:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801e8b:	6a 01                	push   $0x1
  801e8d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e90:	50                   	push   %eax
  801e91:	e8 91 ee ff ff       	call   800d27 <sys_cputs>
}
  801e96:	83 c4 10             	add    $0x10,%esp
  801e99:	c9                   	leave  
  801e9a:	c3                   	ret    

00801e9b <getchar>:
{
  801e9b:	55                   	push   %ebp
  801e9c:	89 e5                	mov    %esp,%ebp
  801e9e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801ea1:	6a 01                	push   $0x1
  801ea3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ea6:	50                   	push   %eax
  801ea7:	6a 00                	push   $0x0
  801ea9:	e8 7f f6 ff ff       	call   80152d <read>
	if (r < 0)
  801eae:	83 c4 10             	add    $0x10,%esp
  801eb1:	85 c0                	test   %eax,%eax
  801eb3:	78 06                	js     801ebb <getchar+0x20>
	if (r < 1)
  801eb5:	74 06                	je     801ebd <getchar+0x22>
	return c;
  801eb7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ebb:	c9                   	leave  
  801ebc:	c3                   	ret    
		return -E_EOF;
  801ebd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801ec2:	eb f7                	jmp    801ebb <getchar+0x20>

00801ec4 <iscons>:
{
  801ec4:	55                   	push   %ebp
  801ec5:	89 e5                	mov    %esp,%ebp
  801ec7:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801eca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ecd:	50                   	push   %eax
  801ece:	ff 75 08             	push   0x8(%ebp)
  801ed1:	e8 f3 f3 ff ff       	call   8012c9 <fd_lookup>
  801ed6:	83 c4 10             	add    $0x10,%esp
  801ed9:	85 c0                	test   %eax,%eax
  801edb:	78 11                	js     801eee <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801edd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ee0:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801ee6:	39 10                	cmp    %edx,(%eax)
  801ee8:	0f 94 c0             	sete   %al
  801eeb:	0f b6 c0             	movzbl %al,%eax
}
  801eee:	c9                   	leave  
  801eef:	c3                   	ret    

00801ef0 <opencons>:
{
  801ef0:	55                   	push   %ebp
  801ef1:	89 e5                	mov    %esp,%ebp
  801ef3:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801ef6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ef9:	50                   	push   %eax
  801efa:	e8 7a f3 ff ff       	call   801279 <fd_alloc>
  801eff:	83 c4 10             	add    $0x10,%esp
  801f02:	85 c0                	test   %eax,%eax
  801f04:	78 3a                	js     801f40 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f06:	83 ec 04             	sub    $0x4,%esp
  801f09:	68 07 04 00 00       	push   $0x407
  801f0e:	ff 75 f4             	push   -0xc(%ebp)
  801f11:	6a 00                	push   $0x0
  801f13:	e8 cb ee ff ff       	call   800de3 <sys_page_alloc>
  801f18:	83 c4 10             	add    $0x10,%esp
  801f1b:	85 c0                	test   %eax,%eax
  801f1d:	78 21                	js     801f40 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801f1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f22:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f28:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f2d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f34:	83 ec 0c             	sub    $0xc,%esp
  801f37:	50                   	push   %eax
  801f38:	e8 15 f3 ff ff       	call   801252 <fd2num>
  801f3d:	83 c4 10             	add    $0x10,%esp
}
  801f40:	c9                   	leave  
  801f41:	c3                   	ret    

00801f42 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801f42:	55                   	push   %ebp
  801f43:	89 e5                	mov    %esp,%ebp
  801f45:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  801f48:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  801f4f:	74 0a                	je     801f5b <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801f51:	8b 45 08             	mov    0x8(%ebp),%eax
  801f54:	a3 04 60 80 00       	mov    %eax,0x806004
}
  801f59:	c9                   	leave  
  801f5a:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  801f5b:	e8 45 ee ff ff       	call   800da5 <sys_getenvid>
  801f60:	83 ec 04             	sub    $0x4,%esp
  801f63:	68 07 0e 00 00       	push   $0xe07
  801f68:	68 00 f0 bf ee       	push   $0xeebff000
  801f6d:	50                   	push   %eax
  801f6e:	e8 70 ee ff ff       	call   800de3 <sys_page_alloc>
		if (r < 0) {
  801f73:	83 c4 10             	add    $0x10,%esp
  801f76:	85 c0                	test   %eax,%eax
  801f78:	78 2c                	js     801fa6 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801f7a:	e8 26 ee ff ff       	call   800da5 <sys_getenvid>
  801f7f:	83 ec 08             	sub    $0x8,%esp
  801f82:	68 b8 1f 80 00       	push   $0x801fb8
  801f87:	50                   	push   %eax
  801f88:	e8 a1 ef ff ff       	call   800f2e <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801f8d:	83 c4 10             	add    $0x10,%esp
  801f90:	85 c0                	test   %eax,%eax
  801f92:	79 bd                	jns    801f51 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  801f94:	50                   	push   %eax
  801f95:	68 18 2a 80 00       	push   $0x802a18
  801f9a:	6a 28                	push   $0x28
  801f9c:	68 4e 2a 80 00       	push   $0x802a4e
  801fa1:	e8 8c e3 ff ff       	call   800332 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  801fa6:	50                   	push   %eax
  801fa7:	68 d8 29 80 00       	push   $0x8029d8
  801fac:	6a 23                	push   $0x23
  801fae:	68 4e 2a 80 00       	push   $0x802a4e
  801fb3:	e8 7a e3 ff ff       	call   800332 <_panic>

00801fb8 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801fb8:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801fb9:	a1 04 60 80 00       	mov    0x806004,%eax
	call *%eax
  801fbe:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801fc0:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  801fc3:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  801fc7:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801fca:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  801fce:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801fd2:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  801fd4:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  801fd7:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  801fd8:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  801fdb:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  801fdc:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  801fdd:	c3                   	ret    

00801fde <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	56                   	push   %esi
  801fe2:	53                   	push   %ebx
  801fe3:	8b 75 08             	mov    0x8(%ebp),%esi
  801fe6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801fec:	85 c0                	test   %eax,%eax
  801fee:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ff3:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801ff6:	83 ec 0c             	sub    $0xc,%esp
  801ff9:	50                   	push   %eax
  801ffa:	e8 94 ef ff ff       	call   800f93 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801fff:	83 c4 10             	add    $0x10,%esp
  802002:	85 f6                	test   %esi,%esi
  802004:	74 14                	je     80201a <ipc_recv+0x3c>
  802006:	ba 00 00 00 00       	mov    $0x0,%edx
  80200b:	85 c0                	test   %eax,%eax
  80200d:	78 09                	js     802018 <ipc_recv+0x3a>
  80200f:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802015:	8b 52 74             	mov    0x74(%edx),%edx
  802018:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  80201a:	85 db                	test   %ebx,%ebx
  80201c:	74 14                	je     802032 <ipc_recv+0x54>
  80201e:	ba 00 00 00 00       	mov    $0x0,%edx
  802023:	85 c0                	test   %eax,%eax
  802025:	78 09                	js     802030 <ipc_recv+0x52>
  802027:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80202d:	8b 52 78             	mov    0x78(%edx),%edx
  802030:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802032:	85 c0                	test   %eax,%eax
  802034:	78 08                	js     80203e <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  802036:	a1 00 40 80 00       	mov    0x804000,%eax
  80203b:	8b 40 70             	mov    0x70(%eax),%eax
}
  80203e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802041:	5b                   	pop    %ebx
  802042:	5e                   	pop    %esi
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    

00802045 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802045:	55                   	push   %ebp
  802046:	89 e5                	mov    %esp,%ebp
  802048:	57                   	push   %edi
  802049:	56                   	push   %esi
  80204a:	53                   	push   %ebx
  80204b:	83 ec 0c             	sub    $0xc,%esp
  80204e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802051:	8b 75 0c             	mov    0xc(%ebp),%esi
  802054:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802057:	85 db                	test   %ebx,%ebx
  802059:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80205e:	0f 44 d8             	cmove  %eax,%ebx
  802061:	eb 05                	jmp    802068 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802063:	e8 5c ed ff ff       	call   800dc4 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802068:	ff 75 14             	push   0x14(%ebp)
  80206b:	53                   	push   %ebx
  80206c:	56                   	push   %esi
  80206d:	57                   	push   %edi
  80206e:	e8 fd ee ff ff       	call   800f70 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802073:	83 c4 10             	add    $0x10,%esp
  802076:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802079:	74 e8                	je     802063 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80207b:	85 c0                	test   %eax,%eax
  80207d:	78 08                	js     802087 <ipc_send+0x42>
	}while (r<0);

}
  80207f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802082:	5b                   	pop    %ebx
  802083:	5e                   	pop    %esi
  802084:	5f                   	pop    %edi
  802085:	5d                   	pop    %ebp
  802086:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802087:	50                   	push   %eax
  802088:	68 5c 2a 80 00       	push   $0x802a5c
  80208d:	6a 3d                	push   $0x3d
  80208f:	68 70 2a 80 00       	push   $0x802a70
  802094:	e8 99 e2 ff ff       	call   800332 <_panic>

00802099 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802099:	55                   	push   %ebp
  80209a:	89 e5                	mov    %esp,%ebp
  80209c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80209f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8020a4:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8020a7:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8020ad:	8b 52 50             	mov    0x50(%edx),%edx
  8020b0:	39 ca                	cmp    %ecx,%edx
  8020b2:	74 11                	je     8020c5 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8020b4:	83 c0 01             	add    $0x1,%eax
  8020b7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020bc:	75 e6                	jne    8020a4 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8020be:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c3:	eb 0b                	jmp    8020d0 <ipc_find_env+0x37>
			return envs[i].env_id;
  8020c5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020c8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020cd:	8b 40 48             	mov    0x48(%eax),%eax
}
  8020d0:	5d                   	pop    %ebp
  8020d1:	c3                   	ret    

008020d2 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020d2:	55                   	push   %ebp
  8020d3:	89 e5                	mov    %esp,%ebp
  8020d5:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020d8:	89 c2                	mov    %eax,%edx
  8020da:	c1 ea 16             	shr    $0x16,%edx
  8020dd:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8020e4:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8020e9:	f6 c1 01             	test   $0x1,%cl
  8020ec:	74 1c                	je     80210a <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8020ee:	c1 e8 0c             	shr    $0xc,%eax
  8020f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020f8:	a8 01                	test   $0x1,%al
  8020fa:	74 0e                	je     80210a <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020fc:	c1 e8 0c             	shr    $0xc,%eax
  8020ff:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802106:	ef 
  802107:	0f b7 d2             	movzwl %dx,%edx
}
  80210a:	89 d0                	mov    %edx,%eax
  80210c:	5d                   	pop    %ebp
  80210d:	c3                   	ret    
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__udivdi3>:
  802110:	f3 0f 1e fb          	endbr32 
  802114:	55                   	push   %ebp
  802115:	57                   	push   %edi
  802116:	56                   	push   %esi
  802117:	53                   	push   %ebx
  802118:	83 ec 1c             	sub    $0x1c,%esp
  80211b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80211f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802123:	8b 74 24 34          	mov    0x34(%esp),%esi
  802127:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80212b:	85 c0                	test   %eax,%eax
  80212d:	75 19                	jne    802148 <__udivdi3+0x38>
  80212f:	39 f3                	cmp    %esi,%ebx
  802131:	76 4d                	jbe    802180 <__udivdi3+0x70>
  802133:	31 ff                	xor    %edi,%edi
  802135:	89 e8                	mov    %ebp,%eax
  802137:	89 f2                	mov    %esi,%edx
  802139:	f7 f3                	div    %ebx
  80213b:	89 fa                	mov    %edi,%edx
  80213d:	83 c4 1c             	add    $0x1c,%esp
  802140:	5b                   	pop    %ebx
  802141:	5e                   	pop    %esi
  802142:	5f                   	pop    %edi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    
  802145:	8d 76 00             	lea    0x0(%esi),%esi
  802148:	39 f0                	cmp    %esi,%eax
  80214a:	76 14                	jbe    802160 <__udivdi3+0x50>
  80214c:	31 ff                	xor    %edi,%edi
  80214e:	31 c0                	xor    %eax,%eax
  802150:	89 fa                	mov    %edi,%edx
  802152:	83 c4 1c             	add    $0x1c,%esp
  802155:	5b                   	pop    %ebx
  802156:	5e                   	pop    %esi
  802157:	5f                   	pop    %edi
  802158:	5d                   	pop    %ebp
  802159:	c3                   	ret    
  80215a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802160:	0f bd f8             	bsr    %eax,%edi
  802163:	83 f7 1f             	xor    $0x1f,%edi
  802166:	75 48                	jne    8021b0 <__udivdi3+0xa0>
  802168:	39 f0                	cmp    %esi,%eax
  80216a:	72 06                	jb     802172 <__udivdi3+0x62>
  80216c:	31 c0                	xor    %eax,%eax
  80216e:	39 eb                	cmp    %ebp,%ebx
  802170:	77 de                	ja     802150 <__udivdi3+0x40>
  802172:	b8 01 00 00 00       	mov    $0x1,%eax
  802177:	eb d7                	jmp    802150 <__udivdi3+0x40>
  802179:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802180:	89 d9                	mov    %ebx,%ecx
  802182:	85 db                	test   %ebx,%ebx
  802184:	75 0b                	jne    802191 <__udivdi3+0x81>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f3                	div    %ebx
  80218f:	89 c1                	mov    %eax,%ecx
  802191:	31 d2                	xor    %edx,%edx
  802193:	89 f0                	mov    %esi,%eax
  802195:	f7 f1                	div    %ecx
  802197:	89 c6                	mov    %eax,%esi
  802199:	89 e8                	mov    %ebp,%eax
  80219b:	89 f7                	mov    %esi,%edi
  80219d:	f7 f1                	div    %ecx
  80219f:	89 fa                	mov    %edi,%edx
  8021a1:	83 c4 1c             	add    $0x1c,%esp
  8021a4:	5b                   	pop    %ebx
  8021a5:	5e                   	pop    %esi
  8021a6:	5f                   	pop    %edi
  8021a7:	5d                   	pop    %ebp
  8021a8:	c3                   	ret    
  8021a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	89 f9                	mov    %edi,%ecx
  8021b2:	ba 20 00 00 00       	mov    $0x20,%edx
  8021b7:	29 fa                	sub    %edi,%edx
  8021b9:	d3 e0                	shl    %cl,%eax
  8021bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8021bf:	89 d1                	mov    %edx,%ecx
  8021c1:	89 d8                	mov    %ebx,%eax
  8021c3:	d3 e8                	shr    %cl,%eax
  8021c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8021c9:	09 c1                	or     %eax,%ecx
  8021cb:	89 f0                	mov    %esi,%eax
  8021cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021d1:	89 f9                	mov    %edi,%ecx
  8021d3:	d3 e3                	shl    %cl,%ebx
  8021d5:	89 d1                	mov    %edx,%ecx
  8021d7:	d3 e8                	shr    %cl,%eax
  8021d9:	89 f9                	mov    %edi,%ecx
  8021db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8021df:	89 eb                	mov    %ebp,%ebx
  8021e1:	d3 e6                	shl    %cl,%esi
  8021e3:	89 d1                	mov    %edx,%ecx
  8021e5:	d3 eb                	shr    %cl,%ebx
  8021e7:	09 f3                	or     %esi,%ebx
  8021e9:	89 c6                	mov    %eax,%esi
  8021eb:	89 f2                	mov    %esi,%edx
  8021ed:	89 d8                	mov    %ebx,%eax
  8021ef:	f7 74 24 08          	divl   0x8(%esp)
  8021f3:	89 d6                	mov    %edx,%esi
  8021f5:	89 c3                	mov    %eax,%ebx
  8021f7:	f7 64 24 0c          	mull   0xc(%esp)
  8021fb:	39 d6                	cmp    %edx,%esi
  8021fd:	72 19                	jb     802218 <__udivdi3+0x108>
  8021ff:	89 f9                	mov    %edi,%ecx
  802201:	d3 e5                	shl    %cl,%ebp
  802203:	39 c5                	cmp    %eax,%ebp
  802205:	73 04                	jae    80220b <__udivdi3+0xfb>
  802207:	39 d6                	cmp    %edx,%esi
  802209:	74 0d                	je     802218 <__udivdi3+0x108>
  80220b:	89 d8                	mov    %ebx,%eax
  80220d:	31 ff                	xor    %edi,%edi
  80220f:	e9 3c ff ff ff       	jmp    802150 <__udivdi3+0x40>
  802214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802218:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80221b:	31 ff                	xor    %edi,%edi
  80221d:	e9 2e ff ff ff       	jmp    802150 <__udivdi3+0x40>
  802222:	66 90                	xchg   %ax,%ax
  802224:	66 90                	xchg   %ax,%ax
  802226:	66 90                	xchg   %ax,%ax
  802228:	66 90                	xchg   %ax,%ax
  80222a:	66 90                	xchg   %ax,%ax
  80222c:	66 90                	xchg   %ax,%ax
  80222e:	66 90                	xchg   %ax,%ax

00802230 <__umoddi3>:
  802230:	f3 0f 1e fb          	endbr32 
  802234:	55                   	push   %ebp
  802235:	57                   	push   %edi
  802236:	56                   	push   %esi
  802237:	53                   	push   %ebx
  802238:	83 ec 1c             	sub    $0x1c,%esp
  80223b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80223f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802243:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802247:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80224b:	89 f0                	mov    %esi,%eax
  80224d:	89 da                	mov    %ebx,%edx
  80224f:	85 ff                	test   %edi,%edi
  802251:	75 15                	jne    802268 <__umoddi3+0x38>
  802253:	39 dd                	cmp    %ebx,%ebp
  802255:	76 39                	jbe    802290 <__umoddi3+0x60>
  802257:	f7 f5                	div    %ebp
  802259:	89 d0                	mov    %edx,%eax
  80225b:	31 d2                	xor    %edx,%edx
  80225d:	83 c4 1c             	add    $0x1c,%esp
  802260:	5b                   	pop    %ebx
  802261:	5e                   	pop    %esi
  802262:	5f                   	pop    %edi
  802263:	5d                   	pop    %ebp
  802264:	c3                   	ret    
  802265:	8d 76 00             	lea    0x0(%esi),%esi
  802268:	39 df                	cmp    %ebx,%edi
  80226a:	77 f1                	ja     80225d <__umoddi3+0x2d>
  80226c:	0f bd cf             	bsr    %edi,%ecx
  80226f:	83 f1 1f             	xor    $0x1f,%ecx
  802272:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802276:	75 40                	jne    8022b8 <__umoddi3+0x88>
  802278:	39 df                	cmp    %ebx,%edi
  80227a:	72 04                	jb     802280 <__umoddi3+0x50>
  80227c:	39 f5                	cmp    %esi,%ebp
  80227e:	77 dd                	ja     80225d <__umoddi3+0x2d>
  802280:	89 da                	mov    %ebx,%edx
  802282:	89 f0                	mov    %esi,%eax
  802284:	29 e8                	sub    %ebp,%eax
  802286:	19 fa                	sbb    %edi,%edx
  802288:	eb d3                	jmp    80225d <__umoddi3+0x2d>
  80228a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802290:	89 e9                	mov    %ebp,%ecx
  802292:	85 ed                	test   %ebp,%ebp
  802294:	75 0b                	jne    8022a1 <__umoddi3+0x71>
  802296:	b8 01 00 00 00       	mov    $0x1,%eax
  80229b:	31 d2                	xor    %edx,%edx
  80229d:	f7 f5                	div    %ebp
  80229f:	89 c1                	mov    %eax,%ecx
  8022a1:	89 d8                	mov    %ebx,%eax
  8022a3:	31 d2                	xor    %edx,%edx
  8022a5:	f7 f1                	div    %ecx
  8022a7:	89 f0                	mov    %esi,%eax
  8022a9:	f7 f1                	div    %ecx
  8022ab:	89 d0                	mov    %edx,%eax
  8022ad:	31 d2                	xor    %edx,%edx
  8022af:	eb ac                	jmp    80225d <__umoddi3+0x2d>
  8022b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022b8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8022bc:	ba 20 00 00 00       	mov    $0x20,%edx
  8022c1:	29 c2                	sub    %eax,%edx
  8022c3:	89 c1                	mov    %eax,%ecx
  8022c5:	89 e8                	mov    %ebp,%eax
  8022c7:	d3 e7                	shl    %cl,%edi
  8022c9:	89 d1                	mov    %edx,%ecx
  8022cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8022cf:	d3 e8                	shr    %cl,%eax
  8022d1:	89 c1                	mov    %eax,%ecx
  8022d3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8022d7:	09 f9                	or     %edi,%ecx
  8022d9:	89 df                	mov    %ebx,%edi
  8022db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022df:	89 c1                	mov    %eax,%ecx
  8022e1:	d3 e5                	shl    %cl,%ebp
  8022e3:	89 d1                	mov    %edx,%ecx
  8022e5:	d3 ef                	shr    %cl,%edi
  8022e7:	89 c1                	mov    %eax,%ecx
  8022e9:	89 f0                	mov    %esi,%eax
  8022eb:	d3 e3                	shl    %cl,%ebx
  8022ed:	89 d1                	mov    %edx,%ecx
  8022ef:	89 fa                	mov    %edi,%edx
  8022f1:	d3 e8                	shr    %cl,%eax
  8022f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8022f8:	09 d8                	or     %ebx,%eax
  8022fa:	f7 74 24 08          	divl   0x8(%esp)
  8022fe:	89 d3                	mov    %edx,%ebx
  802300:	d3 e6                	shl    %cl,%esi
  802302:	f7 e5                	mul    %ebp
  802304:	89 c7                	mov    %eax,%edi
  802306:	89 d1                	mov    %edx,%ecx
  802308:	39 d3                	cmp    %edx,%ebx
  80230a:	72 06                	jb     802312 <__umoddi3+0xe2>
  80230c:	75 0e                	jne    80231c <__umoddi3+0xec>
  80230e:	39 c6                	cmp    %eax,%esi
  802310:	73 0a                	jae    80231c <__umoddi3+0xec>
  802312:	29 e8                	sub    %ebp,%eax
  802314:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802318:	89 d1                	mov    %edx,%ecx
  80231a:	89 c7                	mov    %eax,%edi
  80231c:	89 f5                	mov    %esi,%ebp
  80231e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802322:	29 fd                	sub    %edi,%ebp
  802324:	19 cb                	sbb    %ecx,%ebx
  802326:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80232b:	89 d8                	mov    %ebx,%eax
  80232d:	d3 e0                	shl    %cl,%eax
  80232f:	89 f1                	mov    %esi,%ecx
  802331:	d3 ed                	shr    %cl,%ebp
  802333:	d3 eb                	shr    %cl,%ebx
  802335:	09 e8                	or     %ebp,%eax
  802337:	89 da                	mov    %ebx,%edx
  802339:	83 c4 1c             	add    $0x1c,%esp
  80233c:	5b                   	pop    %ebx
  80233d:	5e                   	pop    %esi
  80233e:	5f                   	pop    %edi
  80233f:	5d                   	pop    %ebp
  802340:	c3                   	ret    
