
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
  80003b:	c7 05 04 30 80 00 40 	movl   $0x802840,0x803004
  800042:	28 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 88 20 00 00       	call   8020d6 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	0f 88 1b 01 00 00    	js     800176 <umain+0x143>
		panic("pipe: %e", i);

	if ((pid = fork()) < 0)
  80005b:	e8 d6 10 00 00       	call   801136 <fork>
  800060:	89 c3                	mov    %eax,%ebx
  800062:	85 c0                	test   %eax,%eax
  800064:	0f 88 1e 01 00 00    	js     800188 <umain+0x155>
		panic("fork: %e", i);

	if (pid == 0) {
  80006a:	0f 85 56 01 00 00    	jne    8001c6 <umain+0x193>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  800070:	a1 00 40 80 00       	mov    0x804000,%eax
  800075:	8b 40 58             	mov    0x58(%eax),%eax
  800078:	83 ec 04             	sub    $0x4,%esp
  80007b:	ff 75 90             	push   -0x70(%ebp)
  80007e:	50                   	push   %eax
  80007f:	68 65 28 80 00       	push   $0x802865
  800084:	e8 87 03 00 00       	call   800410 <cprintf>
		close(p[1]);
  800089:	83 c4 04             	add    $0x4,%esp
  80008c:	ff 75 90             	push   -0x70(%ebp)
  80008f:	e8 c9 13 00 00       	call   80145d <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  800094:	a1 00 40 80 00       	mov    0x804000,%eax
  800099:	8b 40 58             	mov    0x58(%eax),%eax
  80009c:	83 c4 0c             	add    $0xc,%esp
  80009f:	ff 75 8c             	push   -0x74(%ebp)
  8000a2:	50                   	push   %eax
  8000a3:	68 82 28 80 00       	push   $0x802882
  8000a8:	e8 63 03 00 00       	call   800410 <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000ad:	83 c4 0c             	add    $0xc,%esp
  8000b0:	6a 63                	push   $0x63
  8000b2:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000b5:	50                   	push   %eax
  8000b6:	ff 75 8c             	push   -0x74(%ebp)
  8000b9:	e8 62 15 00 00       	call   801620 <readn>
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
  8000dd:	e8 b9 09 00 00       	call   800a9b <strcmp>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	85 c0                	test   %eax,%eax
  8000e7:	0f 85 bf 00 00 00    	jne    8001ac <umain+0x179>
			cprintf("\npipe read closed properly\n");
  8000ed:	83 ec 0c             	sub    $0xc,%esp
  8000f0:	68 a8 28 80 00       	push   $0x8028a8
  8000f5:	e8 16 03 00 00       	call   800410 <cprintf>
  8000fa:	83 c4 10             	add    $0x10,%esp
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
		exit();
  8000fd:	e8 19 02 00 00       	call   80031b <exit>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
			panic("write: %e", i);
		close(p[1]);
	}
	wait(pid);
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	53                   	push   %ebx
  800106:	e8 48 21 00 00       	call   802253 <wait>

	binaryname = "pipewriteeof";
  80010b:	c7 05 04 30 80 00 fe 	movl   $0x8028fe,0x803004
  800112:	28 80 00 
	if ((i = pipe(p)) < 0)
  800115:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800118:	89 04 24             	mov    %eax,(%esp)
  80011b:	e8 b6 1f 00 00       	call   8020d6 <pipe>
  800120:	89 c6                	mov    %eax,%esi
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	85 c0                	test   %eax,%eax
  800127:	0f 88 32 01 00 00    	js     80025f <umain+0x22c>
		panic("pipe: %e", i);

	if ((pid = fork()) < 0)
  80012d:	e8 04 10 00 00       	call   801136 <fork>
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
  800148:	e8 10 13 00 00       	call   80145d <close>
	close(p[1]);
  80014d:	83 c4 04             	add    $0x4,%esp
  800150:	ff 75 90             	push   -0x70(%ebp)
  800153:	e8 05 13 00 00       	call   80145d <close>
	wait(pid);
  800158:	89 1c 24             	mov    %ebx,(%esp)
  80015b:	e8 f3 20 00 00       	call   802253 <wait>

	cprintf("pipe tests passed\n");
  800160:	c7 04 24 2c 29 80 00 	movl   $0x80292c,(%esp)
  800167:	e8 a4 02 00 00       	call   800410 <cprintf>
}
  80016c:	83 c4 10             	add    $0x10,%esp
  80016f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800172:	5b                   	pop    %ebx
  800173:	5e                   	pop    %esi
  800174:	5d                   	pop    %ebp
  800175:	c3                   	ret    
		panic("pipe: %e", i);
  800176:	50                   	push   %eax
  800177:	68 4c 28 80 00       	push   $0x80284c
  80017c:	6a 0e                	push   $0xe
  80017e:	68 55 28 80 00       	push   $0x802855
  800183:	e8 ad 01 00 00       	call   800335 <_panic>
		panic("fork: %e", i);
  800188:	56                   	push   %esi
  800189:	68 98 2d 80 00       	push   $0x802d98
  80018e:	6a 11                	push   $0x11
  800190:	68 55 28 80 00       	push   $0x802855
  800195:	e8 9b 01 00 00       	call   800335 <_panic>
			panic("read: %e", i);
  80019a:	50                   	push   %eax
  80019b:	68 9f 28 80 00       	push   $0x80289f
  8001a0:	6a 19                	push   $0x19
  8001a2:	68 55 28 80 00       	push   $0x802855
  8001a7:	e8 89 01 00 00       	call   800335 <_panic>
			cprintf("\ngot %d bytes: %s\n", i, buf);
  8001ac:	83 ec 04             	sub    $0x4,%esp
  8001af:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8001b2:	50                   	push   %eax
  8001b3:	56                   	push   %esi
  8001b4:	68 c4 28 80 00       	push   $0x8028c4
  8001b9:	e8 52 02 00 00       	call   800410 <cprintf>
  8001be:	83 c4 10             	add    $0x10,%esp
  8001c1:	e9 37 ff ff ff       	jmp    8000fd <umain+0xca>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  8001c6:	a1 00 40 80 00       	mov    0x804000,%eax
  8001cb:	8b 40 58             	mov    0x58(%eax),%eax
  8001ce:	83 ec 04             	sub    $0x4,%esp
  8001d1:	ff 75 8c             	push   -0x74(%ebp)
  8001d4:	50                   	push   %eax
  8001d5:	68 65 28 80 00       	push   $0x802865
  8001da:	e8 31 02 00 00       	call   800410 <cprintf>
		close(p[0]);
  8001df:	83 c4 04             	add    $0x4,%esp
  8001e2:	ff 75 8c             	push   -0x74(%ebp)
  8001e5:	e8 73 12 00 00       	call   80145d <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  8001ea:	a1 00 40 80 00       	mov    0x804000,%eax
  8001ef:	8b 40 58             	mov    0x58(%eax),%eax
  8001f2:	83 c4 0c             	add    $0xc,%esp
  8001f5:	ff 75 90             	push   -0x70(%ebp)
  8001f8:	50                   	push   %eax
  8001f9:	68 d7 28 80 00       	push   $0x8028d7
  8001fe:	e8 0d 02 00 00       	call   800410 <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800203:	83 c4 04             	add    $0x4,%esp
  800206:	ff 35 00 30 80 00    	push   0x803000
  80020c:	e8 9e 07 00 00       	call   8009af <strlen>
  800211:	83 c4 0c             	add    $0xc,%esp
  800214:	50                   	push   %eax
  800215:	ff 35 00 30 80 00    	push   0x803000
  80021b:	ff 75 90             	push   -0x70(%ebp)
  80021e:	e8 44 14 00 00       	call   801667 <write>
  800223:	89 c6                	mov    %eax,%esi
  800225:	83 c4 04             	add    $0x4,%esp
  800228:	ff 35 00 30 80 00    	push   0x803000
  80022e:	e8 7c 07 00 00       	call   8009af <strlen>
  800233:	83 c4 10             	add    $0x10,%esp
  800236:	39 f0                	cmp    %esi,%eax
  800238:	75 13                	jne    80024d <umain+0x21a>
		close(p[1]);
  80023a:	83 ec 0c             	sub    $0xc,%esp
  80023d:	ff 75 90             	push   -0x70(%ebp)
  800240:	e8 18 12 00 00       	call   80145d <close>
  800245:	83 c4 10             	add    $0x10,%esp
  800248:	e9 b5 fe ff ff       	jmp    800102 <umain+0xcf>
			panic("write: %e", i);
  80024d:	56                   	push   %esi
  80024e:	68 f4 28 80 00       	push   $0x8028f4
  800253:	6a 25                	push   $0x25
  800255:	68 55 28 80 00       	push   $0x802855
  80025a:	e8 d6 00 00 00       	call   800335 <_panic>
		panic("pipe: %e", i);
  80025f:	50                   	push   %eax
  800260:	68 4c 28 80 00       	push   $0x80284c
  800265:	6a 2c                	push   $0x2c
  800267:	68 55 28 80 00       	push   $0x802855
  80026c:	e8 c4 00 00 00       	call   800335 <_panic>
		panic("fork: %e", i);
  800271:	56                   	push   %esi
  800272:	68 98 2d 80 00       	push   $0x802d98
  800277:	6a 2f                	push   $0x2f
  800279:	68 55 28 80 00       	push   $0x802855
  80027e:	e8 b2 00 00 00       	call   800335 <_panic>
		close(p[0]);
  800283:	83 ec 0c             	sub    $0xc,%esp
  800286:	ff 75 8c             	push   -0x74(%ebp)
  800289:	e8 cf 11 00 00       	call   80145d <close>
  80028e:	83 c4 10             	add    $0x10,%esp
			cprintf(".");
  800291:	83 ec 0c             	sub    $0xc,%esp
  800294:	68 0b 29 80 00       	push   $0x80290b
  800299:	e8 72 01 00 00       	call   800410 <cprintf>
			if (write(p[1], "x", 1) != 1)
  80029e:	83 c4 0c             	add    $0xc,%esp
  8002a1:	6a 01                	push   $0x1
  8002a3:	68 0d 29 80 00       	push   $0x80290d
  8002a8:	ff 75 90             	push   -0x70(%ebp)
  8002ab:	e8 b7 13 00 00       	call   801667 <write>
  8002b0:	83 c4 10             	add    $0x10,%esp
  8002b3:	83 f8 01             	cmp    $0x1,%eax
  8002b6:	74 d9                	je     800291 <umain+0x25e>
		cprintf("\npipe write closed properly\n");
  8002b8:	83 ec 0c             	sub    $0xc,%esp
  8002bb:	68 0f 29 80 00       	push   $0x80290f
  8002c0:	e8 4b 01 00 00       	call   800410 <cprintf>
		exit();
  8002c5:	e8 51 00 00 00       	call   80031b <exit>
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
  8002dd:	e8 c6 0a 00 00       	call   800da8 <sys_getenvid>
  8002e2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002e7:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8002ed:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002f2:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002f7:	85 db                	test   %ebx,%ebx
  8002f9:	7e 07                	jle    800302 <libmain+0x30>
		binaryname = argv[0];
  8002fb:	8b 06                	mov    (%esi),%eax
  8002fd:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800302:	83 ec 08             	sub    $0x8,%esp
  800305:	56                   	push   %esi
  800306:	53                   	push   %ebx
  800307:	e8 27 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80030c:	e8 0a 00 00 00       	call   80031b <exit>
}
  800311:	83 c4 10             	add    $0x10,%esp
  800314:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800317:	5b                   	pop    %ebx
  800318:	5e                   	pop    %esi
  800319:	5d                   	pop    %ebp
  80031a:	c3                   	ret    

0080031b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800321:	e8 64 11 00 00       	call   80148a <close_all>
	sys_env_destroy(0);
  800326:	83 ec 0c             	sub    $0xc,%esp
  800329:	6a 00                	push   $0x0
  80032b:	e8 37 0a 00 00       	call   800d67 <sys_env_destroy>
}
  800330:	83 c4 10             	add    $0x10,%esp
  800333:	c9                   	leave  
  800334:	c3                   	ret    

00800335 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	56                   	push   %esi
  800339:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80033a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80033d:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800343:	e8 60 0a 00 00       	call   800da8 <sys_getenvid>
  800348:	83 ec 0c             	sub    $0xc,%esp
  80034b:	ff 75 0c             	push   0xc(%ebp)
  80034e:	ff 75 08             	push   0x8(%ebp)
  800351:	56                   	push   %esi
  800352:	50                   	push   %eax
  800353:	68 90 29 80 00       	push   $0x802990
  800358:	e8 b3 00 00 00       	call   800410 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80035d:	83 c4 18             	add    $0x18,%esp
  800360:	53                   	push   %ebx
  800361:	ff 75 10             	push   0x10(%ebp)
  800364:	e8 56 00 00 00       	call   8003bf <vcprintf>
	cprintf("\n");
  800369:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800370:	e8 9b 00 00 00       	call   800410 <cprintf>
  800375:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800378:	cc                   	int3   
  800379:	eb fd                	jmp    800378 <_panic+0x43>

0080037b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	53                   	push   %ebx
  80037f:	83 ec 04             	sub    $0x4,%esp
  800382:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800385:	8b 13                	mov    (%ebx),%edx
  800387:	8d 42 01             	lea    0x1(%edx),%eax
  80038a:	89 03                	mov    %eax,(%ebx)
  80038c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80038f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800393:	3d ff 00 00 00       	cmp    $0xff,%eax
  800398:	74 09                	je     8003a3 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80039a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80039e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a1:	c9                   	leave  
  8003a2:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	68 ff 00 00 00       	push   $0xff
  8003ab:	8d 43 08             	lea    0x8(%ebx),%eax
  8003ae:	50                   	push   %eax
  8003af:	e8 76 09 00 00       	call   800d2a <sys_cputs>
		b->idx = 0;
  8003b4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003ba:	83 c4 10             	add    $0x10,%esp
  8003bd:	eb db                	jmp    80039a <putch+0x1f>

008003bf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003bf:	55                   	push   %ebp
  8003c0:	89 e5                	mov    %esp,%ebp
  8003c2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003c8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003cf:	00 00 00 
	b.cnt = 0;
  8003d2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003d9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003dc:	ff 75 0c             	push   0xc(%ebp)
  8003df:	ff 75 08             	push   0x8(%ebp)
  8003e2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003e8:	50                   	push   %eax
  8003e9:	68 7b 03 80 00       	push   $0x80037b
  8003ee:	e8 14 01 00 00       	call   800507 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003f3:	83 c4 08             	add    $0x8,%esp
  8003f6:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8003fc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800402:	50                   	push   %eax
  800403:	e8 22 09 00 00       	call   800d2a <sys_cputs>

	return b.cnt;
}
  800408:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80040e:	c9                   	leave  
  80040f:	c3                   	ret    

00800410 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800410:	55                   	push   %ebp
  800411:	89 e5                	mov    %esp,%ebp
  800413:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800416:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800419:	50                   	push   %eax
  80041a:	ff 75 08             	push   0x8(%ebp)
  80041d:	e8 9d ff ff ff       	call   8003bf <vcprintf>
	va_end(ap);

	return cnt;
}
  800422:	c9                   	leave  
  800423:	c3                   	ret    

00800424 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	57                   	push   %edi
  800428:	56                   	push   %esi
  800429:	53                   	push   %ebx
  80042a:	83 ec 1c             	sub    $0x1c,%esp
  80042d:	89 c7                	mov    %eax,%edi
  80042f:	89 d6                	mov    %edx,%esi
  800431:	8b 45 08             	mov    0x8(%ebp),%eax
  800434:	8b 55 0c             	mov    0xc(%ebp),%edx
  800437:	89 d1                	mov    %edx,%ecx
  800439:	89 c2                	mov    %eax,%edx
  80043b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80043e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800441:	8b 45 10             	mov    0x10(%ebp),%eax
  800444:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800447:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80044a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800451:	39 c2                	cmp    %eax,%edx
  800453:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800456:	72 3e                	jb     800496 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800458:	83 ec 0c             	sub    $0xc,%esp
  80045b:	ff 75 18             	push   0x18(%ebp)
  80045e:	83 eb 01             	sub    $0x1,%ebx
  800461:	53                   	push   %ebx
  800462:	50                   	push   %eax
  800463:	83 ec 08             	sub    $0x8,%esp
  800466:	ff 75 e4             	push   -0x1c(%ebp)
  800469:	ff 75 e0             	push   -0x20(%ebp)
  80046c:	ff 75 dc             	push   -0x24(%ebp)
  80046f:	ff 75 d8             	push   -0x28(%ebp)
  800472:	e8 89 21 00 00       	call   802600 <__udivdi3>
  800477:	83 c4 18             	add    $0x18,%esp
  80047a:	52                   	push   %edx
  80047b:	50                   	push   %eax
  80047c:	89 f2                	mov    %esi,%edx
  80047e:	89 f8                	mov    %edi,%eax
  800480:	e8 9f ff ff ff       	call   800424 <printnum>
  800485:	83 c4 20             	add    $0x20,%esp
  800488:	eb 13                	jmp    80049d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80048a:	83 ec 08             	sub    $0x8,%esp
  80048d:	56                   	push   %esi
  80048e:	ff 75 18             	push   0x18(%ebp)
  800491:	ff d7                	call   *%edi
  800493:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800496:	83 eb 01             	sub    $0x1,%ebx
  800499:	85 db                	test   %ebx,%ebx
  80049b:	7f ed                	jg     80048a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80049d:	83 ec 08             	sub    $0x8,%esp
  8004a0:	56                   	push   %esi
  8004a1:	83 ec 04             	sub    $0x4,%esp
  8004a4:	ff 75 e4             	push   -0x1c(%ebp)
  8004a7:	ff 75 e0             	push   -0x20(%ebp)
  8004aa:	ff 75 dc             	push   -0x24(%ebp)
  8004ad:	ff 75 d8             	push   -0x28(%ebp)
  8004b0:	e8 6b 22 00 00       	call   802720 <__umoddi3>
  8004b5:	83 c4 14             	add    $0x14,%esp
  8004b8:	0f be 80 b3 29 80 00 	movsbl 0x8029b3(%eax),%eax
  8004bf:	50                   	push   %eax
  8004c0:	ff d7                	call   *%edi
}
  8004c2:	83 c4 10             	add    $0x10,%esp
  8004c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004c8:	5b                   	pop    %ebx
  8004c9:	5e                   	pop    %esi
  8004ca:	5f                   	pop    %edi
  8004cb:	5d                   	pop    %ebp
  8004cc:	c3                   	ret    

008004cd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004cd:	55                   	push   %ebp
  8004ce:	89 e5                	mov    %esp,%ebp
  8004d0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004d3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004d7:	8b 10                	mov    (%eax),%edx
  8004d9:	3b 50 04             	cmp    0x4(%eax),%edx
  8004dc:	73 0a                	jae    8004e8 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004de:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e1:	89 08                	mov    %ecx,(%eax)
  8004e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e6:	88 02                	mov    %al,(%edx)
}
  8004e8:	5d                   	pop    %ebp
  8004e9:	c3                   	ret    

008004ea <printfmt>:
{
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004f0:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004f3:	50                   	push   %eax
  8004f4:	ff 75 10             	push   0x10(%ebp)
  8004f7:	ff 75 0c             	push   0xc(%ebp)
  8004fa:	ff 75 08             	push   0x8(%ebp)
  8004fd:	e8 05 00 00 00       	call   800507 <vprintfmt>
}
  800502:	83 c4 10             	add    $0x10,%esp
  800505:	c9                   	leave  
  800506:	c3                   	ret    

00800507 <vprintfmt>:
{
  800507:	55                   	push   %ebp
  800508:	89 e5                	mov    %esp,%ebp
  80050a:	57                   	push   %edi
  80050b:	56                   	push   %esi
  80050c:	53                   	push   %ebx
  80050d:	83 ec 3c             	sub    $0x3c,%esp
  800510:	8b 75 08             	mov    0x8(%ebp),%esi
  800513:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800516:	8b 7d 10             	mov    0x10(%ebp),%edi
  800519:	eb 0a                	jmp    800525 <vprintfmt+0x1e>
			putch(ch, putdat);
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	53                   	push   %ebx
  80051f:	50                   	push   %eax
  800520:	ff d6                	call   *%esi
  800522:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800525:	83 c7 01             	add    $0x1,%edi
  800528:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80052c:	83 f8 25             	cmp    $0x25,%eax
  80052f:	74 0c                	je     80053d <vprintfmt+0x36>
			if (ch == '\0')
  800531:	85 c0                	test   %eax,%eax
  800533:	75 e6                	jne    80051b <vprintfmt+0x14>
}
  800535:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800538:	5b                   	pop    %ebx
  800539:	5e                   	pop    %esi
  80053a:	5f                   	pop    %edi
  80053b:	5d                   	pop    %ebp
  80053c:	c3                   	ret    
		padc = ' ';
  80053d:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800541:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800548:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80054f:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800556:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80055b:	8d 47 01             	lea    0x1(%edi),%eax
  80055e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800561:	0f b6 17             	movzbl (%edi),%edx
  800564:	8d 42 dd             	lea    -0x23(%edx),%eax
  800567:	3c 55                	cmp    $0x55,%al
  800569:	0f 87 bb 03 00 00    	ja     80092a <vprintfmt+0x423>
  80056f:	0f b6 c0             	movzbl %al,%eax
  800572:	ff 24 85 00 2b 80 00 	jmp    *0x802b00(,%eax,4)
  800579:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80057c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800580:	eb d9                	jmp    80055b <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800582:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800585:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800589:	eb d0                	jmp    80055b <vprintfmt+0x54>
  80058b:	0f b6 d2             	movzbl %dl,%edx
  80058e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800591:	b8 00 00 00 00       	mov    $0x0,%eax
  800596:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800599:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80059c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005a0:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005a3:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005a6:	83 f9 09             	cmp    $0x9,%ecx
  8005a9:	77 55                	ja     800600 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8005ab:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005ae:	eb e9                	jmp    800599 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8005b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b3:	8b 00                	mov    (%eax),%eax
  8005b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8d 40 04             	lea    0x4(%eax),%eax
  8005be:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005c4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005c8:	79 91                	jns    80055b <vprintfmt+0x54>
				width = precision, precision = -1;
  8005ca:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005cd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005d7:	eb 82                	jmp    80055b <vprintfmt+0x54>
  8005d9:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005dc:	85 d2                	test   %edx,%edx
  8005de:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e3:	0f 49 c2             	cmovns %edx,%eax
  8005e6:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005ec:	e9 6a ff ff ff       	jmp    80055b <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005f4:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005fb:	e9 5b ff ff ff       	jmp    80055b <vprintfmt+0x54>
  800600:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800603:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800606:	eb bc                	jmp    8005c4 <vprintfmt+0xbd>
			lflag++;
  800608:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80060b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80060e:	e9 48 ff ff ff       	jmp    80055b <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8d 78 04             	lea    0x4(%eax),%edi
  800619:	83 ec 08             	sub    $0x8,%esp
  80061c:	53                   	push   %ebx
  80061d:	ff 30                	push   (%eax)
  80061f:	ff d6                	call   *%esi
			break;
  800621:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800624:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800627:	e9 9d 02 00 00       	jmp    8008c9 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8d 78 04             	lea    0x4(%eax),%edi
  800632:	8b 10                	mov    (%eax),%edx
  800634:	89 d0                	mov    %edx,%eax
  800636:	f7 d8                	neg    %eax
  800638:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80063b:	83 f8 0f             	cmp    $0xf,%eax
  80063e:	7f 23                	jg     800663 <vprintfmt+0x15c>
  800640:	8b 14 85 60 2c 80 00 	mov    0x802c60(,%eax,4),%edx
  800647:	85 d2                	test   %edx,%edx
  800649:	74 18                	je     800663 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80064b:	52                   	push   %edx
  80064c:	68 61 2e 80 00       	push   $0x802e61
  800651:	53                   	push   %ebx
  800652:	56                   	push   %esi
  800653:	e8 92 fe ff ff       	call   8004ea <printfmt>
  800658:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80065b:	89 7d 14             	mov    %edi,0x14(%ebp)
  80065e:	e9 66 02 00 00       	jmp    8008c9 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800663:	50                   	push   %eax
  800664:	68 cb 29 80 00       	push   $0x8029cb
  800669:	53                   	push   %ebx
  80066a:	56                   	push   %esi
  80066b:	e8 7a fe ff ff       	call   8004ea <printfmt>
  800670:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800673:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800676:	e9 4e 02 00 00       	jmp    8008c9 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	83 c0 04             	add    $0x4,%eax
  800681:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800684:	8b 45 14             	mov    0x14(%ebp),%eax
  800687:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800689:	85 d2                	test   %edx,%edx
  80068b:	b8 c4 29 80 00       	mov    $0x8029c4,%eax
  800690:	0f 45 c2             	cmovne %edx,%eax
  800693:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800696:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80069a:	7e 06                	jle    8006a2 <vprintfmt+0x19b>
  80069c:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006a0:	75 0d                	jne    8006af <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a2:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006a5:	89 c7                	mov    %eax,%edi
  8006a7:	03 45 e0             	add    -0x20(%ebp),%eax
  8006aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ad:	eb 55                	jmp    800704 <vprintfmt+0x1fd>
  8006af:	83 ec 08             	sub    $0x8,%esp
  8006b2:	ff 75 d8             	push   -0x28(%ebp)
  8006b5:	ff 75 cc             	push   -0x34(%ebp)
  8006b8:	e8 0a 03 00 00       	call   8009c7 <strnlen>
  8006bd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006c0:	29 c1                	sub    %eax,%ecx
  8006c2:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8006ca:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d1:	eb 0f                	jmp    8006e2 <vprintfmt+0x1db>
					putch(padc, putdat);
  8006d3:	83 ec 08             	sub    $0x8,%esp
  8006d6:	53                   	push   %ebx
  8006d7:	ff 75 e0             	push   -0x20(%ebp)
  8006da:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006dc:	83 ef 01             	sub    $0x1,%edi
  8006df:	83 c4 10             	add    $0x10,%esp
  8006e2:	85 ff                	test   %edi,%edi
  8006e4:	7f ed                	jg     8006d3 <vprintfmt+0x1cc>
  8006e6:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006e9:	85 d2                	test   %edx,%edx
  8006eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f0:	0f 49 c2             	cmovns %edx,%eax
  8006f3:	29 c2                	sub    %eax,%edx
  8006f5:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006f8:	eb a8                	jmp    8006a2 <vprintfmt+0x19b>
					putch(ch, putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	53                   	push   %ebx
  8006fe:	52                   	push   %edx
  8006ff:	ff d6                	call   *%esi
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800707:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800709:	83 c7 01             	add    $0x1,%edi
  80070c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800710:	0f be d0             	movsbl %al,%edx
  800713:	85 d2                	test   %edx,%edx
  800715:	74 4b                	je     800762 <vprintfmt+0x25b>
  800717:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80071b:	78 06                	js     800723 <vprintfmt+0x21c>
  80071d:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800721:	78 1e                	js     800741 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800723:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800727:	74 d1                	je     8006fa <vprintfmt+0x1f3>
  800729:	0f be c0             	movsbl %al,%eax
  80072c:	83 e8 20             	sub    $0x20,%eax
  80072f:	83 f8 5e             	cmp    $0x5e,%eax
  800732:	76 c6                	jbe    8006fa <vprintfmt+0x1f3>
					putch('?', putdat);
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	53                   	push   %ebx
  800738:	6a 3f                	push   $0x3f
  80073a:	ff d6                	call   *%esi
  80073c:	83 c4 10             	add    $0x10,%esp
  80073f:	eb c3                	jmp    800704 <vprintfmt+0x1fd>
  800741:	89 cf                	mov    %ecx,%edi
  800743:	eb 0e                	jmp    800753 <vprintfmt+0x24c>
				putch(' ', putdat);
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	53                   	push   %ebx
  800749:	6a 20                	push   $0x20
  80074b:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80074d:	83 ef 01             	sub    $0x1,%edi
  800750:	83 c4 10             	add    $0x10,%esp
  800753:	85 ff                	test   %edi,%edi
  800755:	7f ee                	jg     800745 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800757:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80075a:	89 45 14             	mov    %eax,0x14(%ebp)
  80075d:	e9 67 01 00 00       	jmp    8008c9 <vprintfmt+0x3c2>
  800762:	89 cf                	mov    %ecx,%edi
  800764:	eb ed                	jmp    800753 <vprintfmt+0x24c>
	if (lflag >= 2)
  800766:	83 f9 01             	cmp    $0x1,%ecx
  800769:	7f 1b                	jg     800786 <vprintfmt+0x27f>
	else if (lflag)
  80076b:	85 c9                	test   %ecx,%ecx
  80076d:	74 63                	je     8007d2 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80076f:	8b 45 14             	mov    0x14(%ebp),%eax
  800772:	8b 00                	mov    (%eax),%eax
  800774:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800777:	99                   	cltd   
  800778:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80077b:	8b 45 14             	mov    0x14(%ebp),%eax
  80077e:	8d 40 04             	lea    0x4(%eax),%eax
  800781:	89 45 14             	mov    %eax,0x14(%ebp)
  800784:	eb 17                	jmp    80079d <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	8b 50 04             	mov    0x4(%eax),%edx
  80078c:	8b 00                	mov    (%eax),%eax
  80078e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800791:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800794:	8b 45 14             	mov    0x14(%ebp),%eax
  800797:	8d 40 08             	lea    0x8(%eax),%eax
  80079a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80079d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007a0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007a3:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8007a8:	85 c9                	test   %ecx,%ecx
  8007aa:	0f 89 ff 00 00 00    	jns    8008af <vprintfmt+0x3a8>
				putch('-', putdat);
  8007b0:	83 ec 08             	sub    $0x8,%esp
  8007b3:	53                   	push   %ebx
  8007b4:	6a 2d                	push   $0x2d
  8007b6:	ff d6                	call   *%esi
				num = -(long long) num;
  8007b8:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007bb:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007be:	f7 da                	neg    %edx
  8007c0:	83 d1 00             	adc    $0x0,%ecx
  8007c3:	f7 d9                	neg    %ecx
  8007c5:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007c8:	bf 0a 00 00 00       	mov    $0xa,%edi
  8007cd:	e9 dd 00 00 00       	jmp    8008af <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8b 00                	mov    (%eax),%eax
  8007d7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007da:	99                   	cltd   
  8007db:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007de:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e1:	8d 40 04             	lea    0x4(%eax),%eax
  8007e4:	89 45 14             	mov    %eax,0x14(%ebp)
  8007e7:	eb b4                	jmp    80079d <vprintfmt+0x296>
	if (lflag >= 2)
  8007e9:	83 f9 01             	cmp    $0x1,%ecx
  8007ec:	7f 1e                	jg     80080c <vprintfmt+0x305>
	else if (lflag)
  8007ee:	85 c9                	test   %ecx,%ecx
  8007f0:	74 32                	je     800824 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8007f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f5:	8b 10                	mov    (%eax),%edx
  8007f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fc:	8d 40 04             	lea    0x4(%eax),%eax
  8007ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800802:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800807:	e9 a3 00 00 00       	jmp    8008af <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80080c:	8b 45 14             	mov    0x14(%ebp),%eax
  80080f:	8b 10                	mov    (%eax),%edx
  800811:	8b 48 04             	mov    0x4(%eax),%ecx
  800814:	8d 40 08             	lea    0x8(%eax),%eax
  800817:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80081a:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80081f:	e9 8b 00 00 00       	jmp    8008af <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800824:	8b 45 14             	mov    0x14(%ebp),%eax
  800827:	8b 10                	mov    (%eax),%edx
  800829:	b9 00 00 00 00       	mov    $0x0,%ecx
  80082e:	8d 40 04             	lea    0x4(%eax),%eax
  800831:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800834:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800839:	eb 74                	jmp    8008af <vprintfmt+0x3a8>
	if (lflag >= 2)
  80083b:	83 f9 01             	cmp    $0x1,%ecx
  80083e:	7f 1b                	jg     80085b <vprintfmt+0x354>
	else if (lflag)
  800840:	85 c9                	test   %ecx,%ecx
  800842:	74 2c                	je     800870 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800844:	8b 45 14             	mov    0x14(%ebp),%eax
  800847:	8b 10                	mov    (%eax),%edx
  800849:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084e:	8d 40 04             	lea    0x4(%eax),%eax
  800851:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800854:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800859:	eb 54                	jmp    8008af <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80085b:	8b 45 14             	mov    0x14(%ebp),%eax
  80085e:	8b 10                	mov    (%eax),%edx
  800860:	8b 48 04             	mov    0x4(%eax),%ecx
  800863:	8d 40 08             	lea    0x8(%eax),%eax
  800866:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800869:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80086e:	eb 3f                	jmp    8008af <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800870:	8b 45 14             	mov    0x14(%ebp),%eax
  800873:	8b 10                	mov    (%eax),%edx
  800875:	b9 00 00 00 00       	mov    $0x0,%ecx
  80087a:	8d 40 04             	lea    0x4(%eax),%eax
  80087d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800880:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800885:	eb 28                	jmp    8008af <vprintfmt+0x3a8>
			putch('0', putdat);
  800887:	83 ec 08             	sub    $0x8,%esp
  80088a:	53                   	push   %ebx
  80088b:	6a 30                	push   $0x30
  80088d:	ff d6                	call   *%esi
			putch('x', putdat);
  80088f:	83 c4 08             	add    $0x8,%esp
  800892:	53                   	push   %ebx
  800893:	6a 78                	push   $0x78
  800895:	ff d6                	call   *%esi
			num = (unsigned long long)
  800897:	8b 45 14             	mov    0x14(%ebp),%eax
  80089a:	8b 10                	mov    (%eax),%edx
  80089c:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008a1:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008a4:	8d 40 04             	lea    0x4(%eax),%eax
  8008a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008aa:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8008af:	83 ec 0c             	sub    $0xc,%esp
  8008b2:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8008b6:	50                   	push   %eax
  8008b7:	ff 75 e0             	push   -0x20(%ebp)
  8008ba:	57                   	push   %edi
  8008bb:	51                   	push   %ecx
  8008bc:	52                   	push   %edx
  8008bd:	89 da                	mov    %ebx,%edx
  8008bf:	89 f0                	mov    %esi,%eax
  8008c1:	e8 5e fb ff ff       	call   800424 <printnum>
			break;
  8008c6:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008cc:	e9 54 fc ff ff       	jmp    800525 <vprintfmt+0x1e>
	if (lflag >= 2)
  8008d1:	83 f9 01             	cmp    $0x1,%ecx
  8008d4:	7f 1b                	jg     8008f1 <vprintfmt+0x3ea>
	else if (lflag)
  8008d6:	85 c9                	test   %ecx,%ecx
  8008d8:	74 2c                	je     800906 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8008da:	8b 45 14             	mov    0x14(%ebp),%eax
  8008dd:	8b 10                	mov    (%eax),%edx
  8008df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008e4:	8d 40 04             	lea    0x4(%eax),%eax
  8008e7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008ea:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8008ef:	eb be                	jmp    8008af <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8008f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f4:	8b 10                	mov    (%eax),%edx
  8008f6:	8b 48 04             	mov    0x4(%eax),%ecx
  8008f9:	8d 40 08             	lea    0x8(%eax),%eax
  8008fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008ff:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800904:	eb a9                	jmp    8008af <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800906:	8b 45 14             	mov    0x14(%ebp),%eax
  800909:	8b 10                	mov    (%eax),%edx
  80090b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800910:	8d 40 04             	lea    0x4(%eax),%eax
  800913:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800916:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80091b:	eb 92                	jmp    8008af <vprintfmt+0x3a8>
			putch(ch, putdat);
  80091d:	83 ec 08             	sub    $0x8,%esp
  800920:	53                   	push   %ebx
  800921:	6a 25                	push   $0x25
  800923:	ff d6                	call   *%esi
			break;
  800925:	83 c4 10             	add    $0x10,%esp
  800928:	eb 9f                	jmp    8008c9 <vprintfmt+0x3c2>
			putch('%', putdat);
  80092a:	83 ec 08             	sub    $0x8,%esp
  80092d:	53                   	push   %ebx
  80092e:	6a 25                	push   $0x25
  800930:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800932:	83 c4 10             	add    $0x10,%esp
  800935:	89 f8                	mov    %edi,%eax
  800937:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80093b:	74 05                	je     800942 <vprintfmt+0x43b>
  80093d:	83 e8 01             	sub    $0x1,%eax
  800940:	eb f5                	jmp    800937 <vprintfmt+0x430>
  800942:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800945:	eb 82                	jmp    8008c9 <vprintfmt+0x3c2>

00800947 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	83 ec 18             	sub    $0x18,%esp
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800953:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800956:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80095a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80095d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800964:	85 c0                	test   %eax,%eax
  800966:	74 26                	je     80098e <vsnprintf+0x47>
  800968:	85 d2                	test   %edx,%edx
  80096a:	7e 22                	jle    80098e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80096c:	ff 75 14             	push   0x14(%ebp)
  80096f:	ff 75 10             	push   0x10(%ebp)
  800972:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800975:	50                   	push   %eax
  800976:	68 cd 04 80 00       	push   $0x8004cd
  80097b:	e8 87 fb ff ff       	call   800507 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800980:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800983:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800986:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800989:	83 c4 10             	add    $0x10,%esp
}
  80098c:	c9                   	leave  
  80098d:	c3                   	ret    
		return -E_INVAL;
  80098e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800993:	eb f7                	jmp    80098c <vsnprintf+0x45>

00800995 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80099b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80099e:	50                   	push   %eax
  80099f:	ff 75 10             	push   0x10(%ebp)
  8009a2:	ff 75 0c             	push   0xc(%ebp)
  8009a5:	ff 75 08             	push   0x8(%ebp)
  8009a8:	e8 9a ff ff ff       	call   800947 <vsnprintf>
	va_end(ap);

	return rc;
}
  8009ad:	c9                   	leave  
  8009ae:	c3                   	ret    

008009af <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ba:	eb 03                	jmp    8009bf <strlen+0x10>
		n++;
  8009bc:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009bf:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009c3:	75 f7                	jne    8009bc <strlen+0xd>
	return n;
}
  8009c5:	5d                   	pop    %ebp
  8009c6:	c3                   	ret    

008009c7 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009c7:	55                   	push   %ebp
  8009c8:	89 e5                	mov    %esp,%ebp
  8009ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cd:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d5:	eb 03                	jmp    8009da <strnlen+0x13>
		n++;
  8009d7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009da:	39 d0                	cmp    %edx,%eax
  8009dc:	74 08                	je     8009e6 <strnlen+0x1f>
  8009de:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009e2:	75 f3                	jne    8009d7 <strnlen+0x10>
  8009e4:	89 c2                	mov    %eax,%edx
	return n;
}
  8009e6:	89 d0                	mov    %edx,%eax
  8009e8:	5d                   	pop    %ebp
  8009e9:	c3                   	ret    

008009ea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	53                   	push   %ebx
  8009ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f9:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8009fd:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a00:	83 c0 01             	add    $0x1,%eax
  800a03:	84 d2                	test   %dl,%dl
  800a05:	75 f2                	jne    8009f9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a07:	89 c8                	mov    %ecx,%eax
  800a09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0c:	c9                   	leave  
  800a0d:	c3                   	ret    

00800a0e <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a0e:	55                   	push   %ebp
  800a0f:	89 e5                	mov    %esp,%ebp
  800a11:	53                   	push   %ebx
  800a12:	83 ec 10             	sub    $0x10,%esp
  800a15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a18:	53                   	push   %ebx
  800a19:	e8 91 ff ff ff       	call   8009af <strlen>
  800a1e:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a21:	ff 75 0c             	push   0xc(%ebp)
  800a24:	01 d8                	add    %ebx,%eax
  800a26:	50                   	push   %eax
  800a27:	e8 be ff ff ff       	call   8009ea <strcpy>
	return dst;
}
  800a2c:	89 d8                	mov    %ebx,%eax
  800a2e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a31:	c9                   	leave  
  800a32:	c3                   	ret    

00800a33 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	56                   	push   %esi
  800a37:	53                   	push   %ebx
  800a38:	8b 75 08             	mov    0x8(%ebp),%esi
  800a3b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3e:	89 f3                	mov    %esi,%ebx
  800a40:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a43:	89 f0                	mov    %esi,%eax
  800a45:	eb 0f                	jmp    800a56 <strncpy+0x23>
		*dst++ = *src;
  800a47:	83 c0 01             	add    $0x1,%eax
  800a4a:	0f b6 0a             	movzbl (%edx),%ecx
  800a4d:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a50:	80 f9 01             	cmp    $0x1,%cl
  800a53:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800a56:	39 d8                	cmp    %ebx,%eax
  800a58:	75 ed                	jne    800a47 <strncpy+0x14>
	}
	return ret;
}
  800a5a:	89 f0                	mov    %esi,%eax
  800a5c:	5b                   	pop    %ebx
  800a5d:	5e                   	pop    %esi
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a60:	55                   	push   %ebp
  800a61:	89 e5                	mov    %esp,%ebp
  800a63:	56                   	push   %esi
  800a64:	53                   	push   %ebx
  800a65:	8b 75 08             	mov    0x8(%ebp),%esi
  800a68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a6b:	8b 55 10             	mov    0x10(%ebp),%edx
  800a6e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a70:	85 d2                	test   %edx,%edx
  800a72:	74 21                	je     800a95 <strlcpy+0x35>
  800a74:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a78:	89 f2                	mov    %esi,%edx
  800a7a:	eb 09                	jmp    800a85 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a7c:	83 c1 01             	add    $0x1,%ecx
  800a7f:	83 c2 01             	add    $0x1,%edx
  800a82:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800a85:	39 c2                	cmp    %eax,%edx
  800a87:	74 09                	je     800a92 <strlcpy+0x32>
  800a89:	0f b6 19             	movzbl (%ecx),%ebx
  800a8c:	84 db                	test   %bl,%bl
  800a8e:	75 ec                	jne    800a7c <strlcpy+0x1c>
  800a90:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a92:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a95:	29 f0                	sub    %esi,%eax
}
  800a97:	5b                   	pop    %ebx
  800a98:	5e                   	pop    %esi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aa4:	eb 06                	jmp    800aac <strcmp+0x11>
		p++, q++;
  800aa6:	83 c1 01             	add    $0x1,%ecx
  800aa9:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800aac:	0f b6 01             	movzbl (%ecx),%eax
  800aaf:	84 c0                	test   %al,%al
  800ab1:	74 04                	je     800ab7 <strcmp+0x1c>
  800ab3:	3a 02                	cmp    (%edx),%al
  800ab5:	74 ef                	je     800aa6 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab7:	0f b6 c0             	movzbl %al,%eax
  800aba:	0f b6 12             	movzbl (%edx),%edx
  800abd:	29 d0                	sub    %edx,%eax
}
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	53                   	push   %ebx
  800ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800acb:	89 c3                	mov    %eax,%ebx
  800acd:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ad0:	eb 06                	jmp    800ad8 <strncmp+0x17>
		n--, p++, q++;
  800ad2:	83 c0 01             	add    $0x1,%eax
  800ad5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ad8:	39 d8                	cmp    %ebx,%eax
  800ada:	74 18                	je     800af4 <strncmp+0x33>
  800adc:	0f b6 08             	movzbl (%eax),%ecx
  800adf:	84 c9                	test   %cl,%cl
  800ae1:	74 04                	je     800ae7 <strncmp+0x26>
  800ae3:	3a 0a                	cmp    (%edx),%cl
  800ae5:	74 eb                	je     800ad2 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae7:	0f b6 00             	movzbl (%eax),%eax
  800aea:	0f b6 12             	movzbl (%edx),%edx
  800aed:	29 d0                	sub    %edx,%eax
}
  800aef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800af2:	c9                   	leave  
  800af3:	c3                   	ret    
		return 0;
  800af4:	b8 00 00 00 00       	mov    $0x0,%eax
  800af9:	eb f4                	jmp    800aef <strncmp+0x2e>

00800afb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	8b 45 08             	mov    0x8(%ebp),%eax
  800b01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b05:	eb 03                	jmp    800b0a <strchr+0xf>
  800b07:	83 c0 01             	add    $0x1,%eax
  800b0a:	0f b6 10             	movzbl (%eax),%edx
  800b0d:	84 d2                	test   %dl,%dl
  800b0f:	74 06                	je     800b17 <strchr+0x1c>
		if (*s == c)
  800b11:	38 ca                	cmp    %cl,%dl
  800b13:	75 f2                	jne    800b07 <strchr+0xc>
  800b15:	eb 05                	jmp    800b1c <strchr+0x21>
			return (char *) s;
	return 0;
  800b17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	8b 45 08             	mov    0x8(%ebp),%eax
  800b24:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b28:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b2b:	38 ca                	cmp    %cl,%dl
  800b2d:	74 09                	je     800b38 <strfind+0x1a>
  800b2f:	84 d2                	test   %dl,%dl
  800b31:	74 05                	je     800b38 <strfind+0x1a>
	for (; *s; s++)
  800b33:	83 c0 01             	add    $0x1,%eax
  800b36:	eb f0                	jmp    800b28 <strfind+0xa>
			break;
	return (char *) s;
}
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    

00800b3a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	57                   	push   %edi
  800b3e:	56                   	push   %esi
  800b3f:	53                   	push   %ebx
  800b40:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b43:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b46:	85 c9                	test   %ecx,%ecx
  800b48:	74 2f                	je     800b79 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b4a:	89 f8                	mov    %edi,%eax
  800b4c:	09 c8                	or     %ecx,%eax
  800b4e:	a8 03                	test   $0x3,%al
  800b50:	75 21                	jne    800b73 <memset+0x39>
		c &= 0xFF;
  800b52:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b56:	89 d0                	mov    %edx,%eax
  800b58:	c1 e0 08             	shl    $0x8,%eax
  800b5b:	89 d3                	mov    %edx,%ebx
  800b5d:	c1 e3 18             	shl    $0x18,%ebx
  800b60:	89 d6                	mov    %edx,%esi
  800b62:	c1 e6 10             	shl    $0x10,%esi
  800b65:	09 f3                	or     %esi,%ebx
  800b67:	09 da                	or     %ebx,%edx
  800b69:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b6b:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b6e:	fc                   	cld    
  800b6f:	f3 ab                	rep stos %eax,%es:(%edi)
  800b71:	eb 06                	jmp    800b79 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b76:	fc                   	cld    
  800b77:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b79:	89 f8                	mov    %edi,%eax
  800b7b:	5b                   	pop    %ebx
  800b7c:	5e                   	pop    %esi
  800b7d:	5f                   	pop    %edi
  800b7e:	5d                   	pop    %ebp
  800b7f:	c3                   	ret    

00800b80 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b80:	55                   	push   %ebp
  800b81:	89 e5                	mov    %esp,%ebp
  800b83:	57                   	push   %edi
  800b84:	56                   	push   %esi
  800b85:	8b 45 08             	mov    0x8(%ebp),%eax
  800b88:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b8b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b8e:	39 c6                	cmp    %eax,%esi
  800b90:	73 32                	jae    800bc4 <memmove+0x44>
  800b92:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b95:	39 c2                	cmp    %eax,%edx
  800b97:	76 2b                	jbe    800bc4 <memmove+0x44>
		s += n;
		d += n;
  800b99:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b9c:	89 d6                	mov    %edx,%esi
  800b9e:	09 fe                	or     %edi,%esi
  800ba0:	09 ce                	or     %ecx,%esi
  800ba2:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ba8:	75 0e                	jne    800bb8 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800baa:	83 ef 04             	sub    $0x4,%edi
  800bad:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bb0:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800bb3:	fd                   	std    
  800bb4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bb6:	eb 09                	jmp    800bc1 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bb8:	83 ef 01             	sub    $0x1,%edi
  800bbb:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bbe:	fd                   	std    
  800bbf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bc1:	fc                   	cld    
  800bc2:	eb 1a                	jmp    800bde <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc4:	89 f2                	mov    %esi,%edx
  800bc6:	09 c2                	or     %eax,%edx
  800bc8:	09 ca                	or     %ecx,%edx
  800bca:	f6 c2 03             	test   $0x3,%dl
  800bcd:	75 0a                	jne    800bd9 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bcf:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800bd2:	89 c7                	mov    %eax,%edi
  800bd4:	fc                   	cld    
  800bd5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bd7:	eb 05                	jmp    800bde <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800bd9:	89 c7                	mov    %eax,%edi
  800bdb:	fc                   	cld    
  800bdc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bde:	5e                   	pop    %esi
  800bdf:	5f                   	pop    %edi
  800be0:	5d                   	pop    %ebp
  800be1:	c3                   	ret    

00800be2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800be8:	ff 75 10             	push   0x10(%ebp)
  800beb:	ff 75 0c             	push   0xc(%ebp)
  800bee:	ff 75 08             	push   0x8(%ebp)
  800bf1:	e8 8a ff ff ff       	call   800b80 <memmove>
}
  800bf6:	c9                   	leave  
  800bf7:	c3                   	ret    

00800bf8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bf8:	55                   	push   %ebp
  800bf9:	89 e5                	mov    %esp,%ebp
  800bfb:	56                   	push   %esi
  800bfc:	53                   	push   %ebx
  800bfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800c00:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c03:	89 c6                	mov    %eax,%esi
  800c05:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c08:	eb 06                	jmp    800c10 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c0a:	83 c0 01             	add    $0x1,%eax
  800c0d:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800c10:	39 f0                	cmp    %esi,%eax
  800c12:	74 14                	je     800c28 <memcmp+0x30>
		if (*s1 != *s2)
  800c14:	0f b6 08             	movzbl (%eax),%ecx
  800c17:	0f b6 1a             	movzbl (%edx),%ebx
  800c1a:	38 d9                	cmp    %bl,%cl
  800c1c:	74 ec                	je     800c0a <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800c1e:	0f b6 c1             	movzbl %cl,%eax
  800c21:	0f b6 db             	movzbl %bl,%ebx
  800c24:	29 d8                	sub    %ebx,%eax
  800c26:	eb 05                	jmp    800c2d <memcmp+0x35>
	}

	return 0;
  800c28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5d                   	pop    %ebp
  800c30:	c3                   	ret    

00800c31 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c31:	55                   	push   %ebp
  800c32:	89 e5                	mov    %esp,%ebp
  800c34:	8b 45 08             	mov    0x8(%ebp),%eax
  800c37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c3a:	89 c2                	mov    %eax,%edx
  800c3c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c3f:	eb 03                	jmp    800c44 <memfind+0x13>
  800c41:	83 c0 01             	add    $0x1,%eax
  800c44:	39 d0                	cmp    %edx,%eax
  800c46:	73 04                	jae    800c4c <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c48:	38 08                	cmp    %cl,(%eax)
  800c4a:	75 f5                	jne    800c41 <memfind+0x10>
			break;
	return (void *) s;
}
  800c4c:	5d                   	pop    %ebp
  800c4d:	c3                   	ret    

00800c4e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c4e:	55                   	push   %ebp
  800c4f:	89 e5                	mov    %esp,%ebp
  800c51:	57                   	push   %edi
  800c52:	56                   	push   %esi
  800c53:	53                   	push   %ebx
  800c54:	8b 55 08             	mov    0x8(%ebp),%edx
  800c57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c5a:	eb 03                	jmp    800c5f <strtol+0x11>
		s++;
  800c5c:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800c5f:	0f b6 02             	movzbl (%edx),%eax
  800c62:	3c 20                	cmp    $0x20,%al
  800c64:	74 f6                	je     800c5c <strtol+0xe>
  800c66:	3c 09                	cmp    $0x9,%al
  800c68:	74 f2                	je     800c5c <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c6a:	3c 2b                	cmp    $0x2b,%al
  800c6c:	74 2a                	je     800c98 <strtol+0x4a>
	int neg = 0;
  800c6e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c73:	3c 2d                	cmp    $0x2d,%al
  800c75:	74 2b                	je     800ca2 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c77:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c7d:	75 0f                	jne    800c8e <strtol+0x40>
  800c7f:	80 3a 30             	cmpb   $0x30,(%edx)
  800c82:	74 28                	je     800cac <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c84:	85 db                	test   %ebx,%ebx
  800c86:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c8b:	0f 44 d8             	cmove  %eax,%ebx
  800c8e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c93:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c96:	eb 46                	jmp    800cde <strtol+0x90>
		s++;
  800c98:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800c9b:	bf 00 00 00 00       	mov    $0x0,%edi
  800ca0:	eb d5                	jmp    800c77 <strtol+0x29>
		s++, neg = 1;
  800ca2:	83 c2 01             	add    $0x1,%edx
  800ca5:	bf 01 00 00 00       	mov    $0x1,%edi
  800caa:	eb cb                	jmp    800c77 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cac:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cb0:	74 0e                	je     800cc0 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800cb2:	85 db                	test   %ebx,%ebx
  800cb4:	75 d8                	jne    800c8e <strtol+0x40>
		s++, base = 8;
  800cb6:	83 c2 01             	add    $0x1,%edx
  800cb9:	bb 08 00 00 00       	mov    $0x8,%ebx
  800cbe:	eb ce                	jmp    800c8e <strtol+0x40>
		s += 2, base = 16;
  800cc0:	83 c2 02             	add    $0x2,%edx
  800cc3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cc8:	eb c4                	jmp    800c8e <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800cca:	0f be c0             	movsbl %al,%eax
  800ccd:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cd0:	3b 45 10             	cmp    0x10(%ebp),%eax
  800cd3:	7d 3a                	jge    800d0f <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800cd5:	83 c2 01             	add    $0x1,%edx
  800cd8:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800cdc:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800cde:	0f b6 02             	movzbl (%edx),%eax
  800ce1:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ce4:	89 f3                	mov    %esi,%ebx
  800ce6:	80 fb 09             	cmp    $0x9,%bl
  800ce9:	76 df                	jbe    800cca <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ceb:	8d 70 9f             	lea    -0x61(%eax),%esi
  800cee:	89 f3                	mov    %esi,%ebx
  800cf0:	80 fb 19             	cmp    $0x19,%bl
  800cf3:	77 08                	ja     800cfd <strtol+0xaf>
			dig = *s - 'a' + 10;
  800cf5:	0f be c0             	movsbl %al,%eax
  800cf8:	83 e8 57             	sub    $0x57,%eax
  800cfb:	eb d3                	jmp    800cd0 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800cfd:	8d 70 bf             	lea    -0x41(%eax),%esi
  800d00:	89 f3                	mov    %esi,%ebx
  800d02:	80 fb 19             	cmp    $0x19,%bl
  800d05:	77 08                	ja     800d0f <strtol+0xc1>
			dig = *s - 'A' + 10;
  800d07:	0f be c0             	movsbl %al,%eax
  800d0a:	83 e8 37             	sub    $0x37,%eax
  800d0d:	eb c1                	jmp    800cd0 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d0f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d13:	74 05                	je     800d1a <strtol+0xcc>
		*endptr = (char *) s;
  800d15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d18:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800d1a:	89 c8                	mov    %ecx,%eax
  800d1c:	f7 d8                	neg    %eax
  800d1e:	85 ff                	test   %edi,%edi
  800d20:	0f 45 c8             	cmovne %eax,%ecx
}
  800d23:	89 c8                	mov    %ecx,%eax
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d30:	b8 00 00 00 00       	mov    $0x0,%eax
  800d35:	8b 55 08             	mov    0x8(%ebp),%edx
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	89 c3                	mov    %eax,%ebx
  800d3d:	89 c7                	mov    %eax,%edi
  800d3f:	89 c6                	mov    %eax,%esi
  800d41:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d53:	b8 01 00 00 00       	mov    $0x1,%eax
  800d58:	89 d1                	mov    %edx,%ecx
  800d5a:	89 d3                	mov    %edx,%ebx
  800d5c:	89 d7                	mov    %edx,%edi
  800d5e:	89 d6                	mov    %edx,%esi
  800d60:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d62:	5b                   	pop    %ebx
  800d63:	5e                   	pop    %esi
  800d64:	5f                   	pop    %edi
  800d65:	5d                   	pop    %ebp
  800d66:	c3                   	ret    

00800d67 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d70:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d75:	8b 55 08             	mov    0x8(%ebp),%edx
  800d78:	b8 03 00 00 00       	mov    $0x3,%eax
  800d7d:	89 cb                	mov    %ecx,%ebx
  800d7f:	89 cf                	mov    %ecx,%edi
  800d81:	89 ce                	mov    %ecx,%esi
  800d83:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d85:	85 c0                	test   %eax,%eax
  800d87:	7f 08                	jg     800d91 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800d89:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8c:	5b                   	pop    %ebx
  800d8d:	5e                   	pop    %esi
  800d8e:	5f                   	pop    %edi
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d91:	83 ec 0c             	sub    $0xc,%esp
  800d94:	50                   	push   %eax
  800d95:	6a 03                	push   $0x3
  800d97:	68 bf 2c 80 00       	push   $0x802cbf
  800d9c:	6a 2a                	push   $0x2a
  800d9e:	68 dc 2c 80 00       	push   $0x802cdc
  800da3:	e8 8d f5 ff ff       	call   800335 <_panic>

00800da8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800da8:	55                   	push   %ebp
  800da9:	89 e5                	mov    %esp,%ebp
  800dab:	57                   	push   %edi
  800dac:	56                   	push   %esi
  800dad:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dae:	ba 00 00 00 00       	mov    $0x0,%edx
  800db3:	b8 02 00 00 00       	mov    $0x2,%eax
  800db8:	89 d1                	mov    %edx,%ecx
  800dba:	89 d3                	mov    %edx,%ebx
  800dbc:	89 d7                	mov    %edx,%edi
  800dbe:	89 d6                	mov    %edx,%esi
  800dc0:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dc2:	5b                   	pop    %ebx
  800dc3:	5e                   	pop    %esi
  800dc4:	5f                   	pop    %edi
  800dc5:	5d                   	pop    %ebp
  800dc6:	c3                   	ret    

00800dc7 <sys_yield>:

void
sys_yield(void)
{
  800dc7:	55                   	push   %ebp
  800dc8:	89 e5                	mov    %esp,%ebp
  800dca:	57                   	push   %edi
  800dcb:	56                   	push   %esi
  800dcc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dcd:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd2:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dd7:	89 d1                	mov    %edx,%ecx
  800dd9:	89 d3                	mov    %edx,%ebx
  800ddb:	89 d7                	mov    %edx,%edi
  800ddd:	89 d6                	mov    %edx,%esi
  800ddf:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800de1:	5b                   	pop    %ebx
  800de2:	5e                   	pop    %esi
  800de3:	5f                   	pop    %edi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800de6:	55                   	push   %ebp
  800de7:	89 e5                	mov    %esp,%ebp
  800de9:	57                   	push   %edi
  800dea:	56                   	push   %esi
  800deb:	53                   	push   %ebx
  800dec:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800def:	be 00 00 00 00       	mov    $0x0,%esi
  800df4:	8b 55 08             	mov    0x8(%ebp),%edx
  800df7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfa:	b8 04 00 00 00       	mov    $0x4,%eax
  800dff:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e02:	89 f7                	mov    %esi,%edi
  800e04:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e06:	85 c0                	test   %eax,%eax
  800e08:	7f 08                	jg     800e12 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
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
  800e16:	6a 04                	push   $0x4
  800e18:	68 bf 2c 80 00       	push   $0x802cbf
  800e1d:	6a 2a                	push   $0x2a
  800e1f:	68 dc 2c 80 00       	push   $0x802cdc
  800e24:	e8 0c f5 ff ff       	call   800335 <_panic>

00800e29 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	57                   	push   %edi
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e32:	8b 55 08             	mov    0x8(%ebp),%edx
  800e35:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e38:	b8 05 00 00 00       	mov    $0x5,%eax
  800e3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e40:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e43:	8b 75 18             	mov    0x18(%ebp),%esi
  800e46:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e48:	85 c0                	test   %eax,%eax
  800e4a:	7f 08                	jg     800e54 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
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
  800e58:	6a 05                	push   $0x5
  800e5a:	68 bf 2c 80 00       	push   $0x802cbf
  800e5f:	6a 2a                	push   $0x2a
  800e61:	68 dc 2c 80 00       	push   $0x802cdc
  800e66:	e8 ca f4 ff ff       	call   800335 <_panic>

00800e6b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e6b:	55                   	push   %ebp
  800e6c:	89 e5                	mov    %esp,%ebp
  800e6e:	57                   	push   %edi
  800e6f:	56                   	push   %esi
  800e70:	53                   	push   %ebx
  800e71:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e74:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e79:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7f:	b8 06 00 00 00       	mov    $0x6,%eax
  800e84:	89 df                	mov    %ebx,%edi
  800e86:	89 de                	mov    %ebx,%esi
  800e88:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e8a:	85 c0                	test   %eax,%eax
  800e8c:	7f 08                	jg     800e96 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e91:	5b                   	pop    %ebx
  800e92:	5e                   	pop    %esi
  800e93:	5f                   	pop    %edi
  800e94:	5d                   	pop    %ebp
  800e95:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e96:	83 ec 0c             	sub    $0xc,%esp
  800e99:	50                   	push   %eax
  800e9a:	6a 06                	push   $0x6
  800e9c:	68 bf 2c 80 00       	push   $0x802cbf
  800ea1:	6a 2a                	push   $0x2a
  800ea3:	68 dc 2c 80 00       	push   $0x802cdc
  800ea8:	e8 88 f4 ff ff       	call   800335 <_panic>

00800ead <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	57                   	push   %edi
  800eb1:	56                   	push   %esi
  800eb2:	53                   	push   %ebx
  800eb3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800eb6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ebb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec1:	b8 08 00 00 00       	mov    $0x8,%eax
  800ec6:	89 df                	mov    %ebx,%edi
  800ec8:	89 de                	mov    %ebx,%esi
  800eca:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ecc:	85 c0                	test   %eax,%eax
  800ece:	7f 08                	jg     800ed8 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ed0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ed3:	5b                   	pop    %ebx
  800ed4:	5e                   	pop    %esi
  800ed5:	5f                   	pop    %edi
  800ed6:	5d                   	pop    %ebp
  800ed7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed8:	83 ec 0c             	sub    $0xc,%esp
  800edb:	50                   	push   %eax
  800edc:	6a 08                	push   $0x8
  800ede:	68 bf 2c 80 00       	push   $0x802cbf
  800ee3:	6a 2a                	push   $0x2a
  800ee5:	68 dc 2c 80 00       	push   $0x802cdc
  800eea:	e8 46 f4 ff ff       	call   800335 <_panic>

00800eef <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	57                   	push   %edi
  800ef3:	56                   	push   %esi
  800ef4:	53                   	push   %ebx
  800ef5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ef8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efd:	8b 55 08             	mov    0x8(%ebp),%edx
  800f00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f03:	b8 09 00 00 00       	mov    $0x9,%eax
  800f08:	89 df                	mov    %ebx,%edi
  800f0a:	89 de                	mov    %ebx,%esi
  800f0c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f0e:	85 c0                	test   %eax,%eax
  800f10:	7f 08                	jg     800f1a <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f15:	5b                   	pop    %ebx
  800f16:	5e                   	pop    %esi
  800f17:	5f                   	pop    %edi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1a:	83 ec 0c             	sub    $0xc,%esp
  800f1d:	50                   	push   %eax
  800f1e:	6a 09                	push   $0x9
  800f20:	68 bf 2c 80 00       	push   $0x802cbf
  800f25:	6a 2a                	push   $0x2a
  800f27:	68 dc 2c 80 00       	push   $0x802cdc
  800f2c:	e8 04 f4 ff ff       	call   800335 <_panic>

00800f31 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	57                   	push   %edi
  800f35:	56                   	push   %esi
  800f36:	53                   	push   %ebx
  800f37:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f3a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800f42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f45:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f4a:	89 df                	mov    %ebx,%edi
  800f4c:	89 de                	mov    %ebx,%esi
  800f4e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f50:	85 c0                	test   %eax,%eax
  800f52:	7f 08                	jg     800f5c <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f57:	5b                   	pop    %ebx
  800f58:	5e                   	pop    %esi
  800f59:	5f                   	pop    %edi
  800f5a:	5d                   	pop    %ebp
  800f5b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5c:	83 ec 0c             	sub    $0xc,%esp
  800f5f:	50                   	push   %eax
  800f60:	6a 0a                	push   $0xa
  800f62:	68 bf 2c 80 00       	push   $0x802cbf
  800f67:	6a 2a                	push   $0x2a
  800f69:	68 dc 2c 80 00       	push   $0x802cdc
  800f6e:	e8 c2 f3 ff ff       	call   800335 <_panic>

00800f73 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	57                   	push   %edi
  800f77:	56                   	push   %esi
  800f78:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f79:	8b 55 08             	mov    0x8(%ebp),%edx
  800f7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f7f:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f84:	be 00 00 00 00       	mov    $0x0,%esi
  800f89:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f8c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f8f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f91:	5b                   	pop    %ebx
  800f92:	5e                   	pop    %esi
  800f93:	5f                   	pop    %edi
  800f94:	5d                   	pop    %ebp
  800f95:	c3                   	ret    

00800f96 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f96:	55                   	push   %ebp
  800f97:	89 e5                	mov    %esp,%ebp
  800f99:	57                   	push   %edi
  800f9a:	56                   	push   %esi
  800f9b:	53                   	push   %ebx
  800f9c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa4:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa7:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fac:	89 cb                	mov    %ecx,%ebx
  800fae:	89 cf                	mov    %ecx,%edi
  800fb0:	89 ce                	mov    %ecx,%esi
  800fb2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	7f 08                	jg     800fc0 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fbb:	5b                   	pop    %ebx
  800fbc:	5e                   	pop    %esi
  800fbd:	5f                   	pop    %edi
  800fbe:	5d                   	pop    %ebp
  800fbf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc0:	83 ec 0c             	sub    $0xc,%esp
  800fc3:	50                   	push   %eax
  800fc4:	6a 0d                	push   $0xd
  800fc6:	68 bf 2c 80 00       	push   $0x802cbf
  800fcb:	6a 2a                	push   $0x2a
  800fcd:	68 dc 2c 80 00       	push   $0x802cdc
  800fd2:	e8 5e f3 ff ff       	call   800335 <_panic>

00800fd7 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	57                   	push   %edi
  800fdb:	56                   	push   %esi
  800fdc:	53                   	push   %ebx
	asm volatile("int %1\n"
  800fdd:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe2:	b8 0e 00 00 00       	mov    $0xe,%eax
  800fe7:	89 d1                	mov    %edx,%ecx
  800fe9:	89 d3                	mov    %edx,%ebx
  800feb:	89 d7                	mov    %edx,%edi
  800fed:	89 d6                	mov    %edx,%esi
  800fef:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ff1:	5b                   	pop    %ebx
  800ff2:	5e                   	pop    %esi
  800ff3:	5f                   	pop    %edi
  800ff4:	5d                   	pop    %ebp
  800ff5:	c3                   	ret    

00800ff6 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	57                   	push   %edi
  800ffa:	56                   	push   %esi
  800ffb:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ffc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801001:	8b 55 08             	mov    0x8(%ebp),%edx
  801004:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801007:	b8 0f 00 00 00       	mov    $0xf,%eax
  80100c:	89 df                	mov    %ebx,%edi
  80100e:	89 de                	mov    %ebx,%esi
  801010:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  801012:	5b                   	pop    %ebx
  801013:	5e                   	pop    %esi
  801014:	5f                   	pop    %edi
  801015:	5d                   	pop    %ebp
  801016:	c3                   	ret    

00801017 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  801017:	55                   	push   %ebp
  801018:	89 e5                	mov    %esp,%ebp
  80101a:	57                   	push   %edi
  80101b:	56                   	push   %esi
  80101c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80101d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801022:	8b 55 08             	mov    0x8(%ebp),%edx
  801025:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801028:	b8 10 00 00 00       	mov    $0x10,%eax
  80102d:	89 df                	mov    %ebx,%edi
  80102f:	89 de                	mov    %ebx,%esi
  801031:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  801033:	5b                   	pop    %ebx
  801034:	5e                   	pop    %esi
  801035:	5f                   	pop    %edi
  801036:	5d                   	pop    %ebp
  801037:	c3                   	ret    

00801038 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	56                   	push   %esi
  80103c:	53                   	push   %ebx
  80103d:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801040:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  801042:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801046:	0f 84 8e 00 00 00    	je     8010da <pgfault+0xa2>
  80104c:	89 f0                	mov    %esi,%eax
  80104e:	c1 e8 0c             	shr    $0xc,%eax
  801051:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801058:	f6 c4 08             	test   $0x8,%ah
  80105b:	74 7d                	je     8010da <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  80105d:	e8 46 fd ff ff       	call   800da8 <sys_getenvid>
  801062:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  801064:	83 ec 04             	sub    $0x4,%esp
  801067:	6a 07                	push   $0x7
  801069:	68 00 f0 7f 00       	push   $0x7ff000
  80106e:	50                   	push   %eax
  80106f:	e8 72 fd ff ff       	call   800de6 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  801074:	83 c4 10             	add    $0x10,%esp
  801077:	85 c0                	test   %eax,%eax
  801079:	78 73                	js     8010ee <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  80107b:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  801081:	83 ec 04             	sub    $0x4,%esp
  801084:	68 00 10 00 00       	push   $0x1000
  801089:	56                   	push   %esi
  80108a:	68 00 f0 7f 00       	push   $0x7ff000
  80108f:	e8 ec fa ff ff       	call   800b80 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  801094:	83 c4 08             	add    $0x8,%esp
  801097:	56                   	push   %esi
  801098:	53                   	push   %ebx
  801099:	e8 cd fd ff ff       	call   800e6b <sys_page_unmap>
  80109e:	83 c4 10             	add    $0x10,%esp
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	78 5b                	js     801100 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  8010a5:	83 ec 0c             	sub    $0xc,%esp
  8010a8:	6a 07                	push   $0x7
  8010aa:	56                   	push   %esi
  8010ab:	53                   	push   %ebx
  8010ac:	68 00 f0 7f 00       	push   $0x7ff000
  8010b1:	53                   	push   %ebx
  8010b2:	e8 72 fd ff ff       	call   800e29 <sys_page_map>
  8010b7:	83 c4 20             	add    $0x20,%esp
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	78 54                	js     801112 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  8010be:	83 ec 08             	sub    $0x8,%esp
  8010c1:	68 00 f0 7f 00       	push   $0x7ff000
  8010c6:	53                   	push   %ebx
  8010c7:	e8 9f fd ff ff       	call   800e6b <sys_page_unmap>
  8010cc:	83 c4 10             	add    $0x10,%esp
  8010cf:	85 c0                	test   %eax,%eax
  8010d1:	78 51                	js     801124 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  8010d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010d6:	5b                   	pop    %ebx
  8010d7:	5e                   	pop    %esi
  8010d8:	5d                   	pop    %ebp
  8010d9:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  8010da:	83 ec 04             	sub    $0x4,%esp
  8010dd:	68 ec 2c 80 00       	push   $0x802cec
  8010e2:	6a 1d                	push   $0x1d
  8010e4:	68 68 2d 80 00       	push   $0x802d68
  8010e9:	e8 47 f2 ff ff       	call   800335 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  8010ee:	50                   	push   %eax
  8010ef:	68 24 2d 80 00       	push   $0x802d24
  8010f4:	6a 29                	push   $0x29
  8010f6:	68 68 2d 80 00       	push   $0x802d68
  8010fb:	e8 35 f2 ff ff       	call   800335 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  801100:	50                   	push   %eax
  801101:	68 48 2d 80 00       	push   $0x802d48
  801106:	6a 2e                	push   $0x2e
  801108:	68 68 2d 80 00       	push   $0x802d68
  80110d:	e8 23 f2 ff ff       	call   800335 <_panic>
		panic("pgfault: page map failed (%e)", r);
  801112:	50                   	push   %eax
  801113:	68 73 2d 80 00       	push   $0x802d73
  801118:	6a 30                	push   $0x30
  80111a:	68 68 2d 80 00       	push   $0x802d68
  80111f:	e8 11 f2 ff ff       	call   800335 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  801124:	50                   	push   %eax
  801125:	68 48 2d 80 00       	push   $0x802d48
  80112a:	6a 32                	push   $0x32
  80112c:	68 68 2d 80 00       	push   $0x802d68
  801131:	e8 ff f1 ff ff       	call   800335 <_panic>

00801136 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	57                   	push   %edi
  80113a:	56                   	push   %esi
  80113b:	53                   	push   %ebx
  80113c:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  80113f:	68 38 10 80 00       	push   $0x801038
  801144:	e8 d0 12 00 00       	call   802419 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801149:	b8 07 00 00 00       	mov    $0x7,%eax
  80114e:	cd 30                	int    $0x30
  801150:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  801153:	83 c4 10             	add    $0x10,%esp
  801156:	85 c0                	test   %eax,%eax
  801158:	78 30                	js     80118a <fork+0x54>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  80115a:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  80115f:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801163:	75 76                	jne    8011db <fork+0xa5>
		thisenv = &envs[ENVX(sys_getenvid())];
  801165:	e8 3e fc ff ff       	call   800da8 <sys_getenvid>
  80116a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80116f:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  801175:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80117a:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  80117f:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  801182:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801185:	5b                   	pop    %ebx
  801186:	5e                   	pop    %esi
  801187:	5f                   	pop    %edi
  801188:	5d                   	pop    %ebp
  801189:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  80118a:	50                   	push   %eax
  80118b:	68 91 2d 80 00       	push   $0x802d91
  801190:	6a 78                	push   $0x78
  801192:	68 68 2d 80 00       	push   $0x802d68
  801197:	e8 99 f1 ff ff       	call   800335 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  80119c:	83 ec 0c             	sub    $0xc,%esp
  80119f:	ff 75 e4             	push   -0x1c(%ebp)
  8011a2:	57                   	push   %edi
  8011a3:	ff 75 dc             	push   -0x24(%ebp)
  8011a6:	57                   	push   %edi
  8011a7:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8011aa:	56                   	push   %esi
  8011ab:	e8 79 fc ff ff       	call   800e29 <sys_page_map>
	if(r<0) return r;
  8011b0:	83 c4 20             	add    $0x20,%esp
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	78 cb                	js     801182 <fork+0x4c>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  8011b7:	83 ec 0c             	sub    $0xc,%esp
  8011ba:	ff 75 e4             	push   -0x1c(%ebp)
  8011bd:	57                   	push   %edi
  8011be:	56                   	push   %esi
  8011bf:	57                   	push   %edi
  8011c0:	56                   	push   %esi
  8011c1:	e8 63 fc ff ff       	call   800e29 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  8011c6:	83 c4 20             	add    $0x20,%esp
  8011c9:	85 c0                	test   %eax,%eax
  8011cb:	78 76                	js     801243 <fork+0x10d>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  8011cd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011d3:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8011d9:	74 75                	je     801250 <fork+0x11a>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  8011db:	89 d8                	mov    %ebx,%eax
  8011dd:	c1 e8 16             	shr    $0x16,%eax
  8011e0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011e7:	a8 01                	test   $0x1,%al
  8011e9:	74 e2                	je     8011cd <fork+0x97>
  8011eb:	89 de                	mov    %ebx,%esi
  8011ed:	c1 ee 0c             	shr    $0xc,%esi
  8011f0:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8011f7:	a8 01                	test   $0x1,%al
  8011f9:	74 d2                	je     8011cd <fork+0x97>
	envid_t this_envid = sys_getenvid();//父进程号
  8011fb:	e8 a8 fb ff ff       	call   800da8 <sys_getenvid>
  801200:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  801203:	89 f7                	mov    %esi,%edi
  801205:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  801208:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80120f:	89 c1                	mov    %eax,%ecx
  801211:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801217:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  80121a:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  801221:	f6 c6 04             	test   $0x4,%dh
  801224:	0f 85 72 ff ff ff    	jne    80119c <fork+0x66>
		perm &= ~PTE_W;
  80122a:	25 05 0e 00 00       	and    $0xe05,%eax
  80122f:	80 cc 08             	or     $0x8,%ah
  801232:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  801238:	0f 44 c1             	cmove  %ecx,%eax
  80123b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80123e:	e9 59 ff ff ff       	jmp    80119c <fork+0x66>
  801243:	ba 00 00 00 00       	mov    $0x0,%edx
  801248:	0f 4f c2             	cmovg  %edx,%eax
  80124b:	e9 32 ff ff ff       	jmp    801182 <fork+0x4c>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801250:	83 ec 04             	sub    $0x4,%esp
  801253:	6a 07                	push   $0x7
  801255:	68 00 f0 bf ee       	push   $0xeebff000
  80125a:	8b 7d dc             	mov    -0x24(%ebp),%edi
  80125d:	57                   	push   %edi
  80125e:	e8 83 fb ff ff       	call   800de6 <sys_page_alloc>
	if(r<0) return r;
  801263:	83 c4 10             	add    $0x10,%esp
  801266:	85 c0                	test   %eax,%eax
  801268:	0f 88 14 ff ff ff    	js     801182 <fork+0x4c>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  80126e:	83 ec 08             	sub    $0x8,%esp
  801271:	68 8f 24 80 00       	push   $0x80248f
  801276:	57                   	push   %edi
  801277:	e8 b5 fc ff ff       	call   800f31 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  80127c:	83 c4 10             	add    $0x10,%esp
  80127f:	85 c0                	test   %eax,%eax
  801281:	0f 88 fb fe ff ff    	js     801182 <fork+0x4c>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801287:	83 ec 08             	sub    $0x8,%esp
  80128a:	6a 02                	push   $0x2
  80128c:	57                   	push   %edi
  80128d:	e8 1b fc ff ff       	call   800ead <sys_env_set_status>
	if(r<0) return r;
  801292:	83 c4 10             	add    $0x10,%esp
	return envid;
  801295:	85 c0                	test   %eax,%eax
  801297:	0f 49 c7             	cmovns %edi,%eax
  80129a:	e9 e3 fe ff ff       	jmp    801182 <fork+0x4c>

0080129f <sfork>:

// Challenge!
int
sfork(void)
{
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8012a5:	68 a1 2d 80 00       	push   $0x802da1
  8012aa:	68 a1 00 00 00       	push   $0xa1
  8012af:	68 68 2d 80 00       	push   $0x802d68
  8012b4:	e8 7c f0 ff ff       	call   800335 <_panic>

008012b9 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012b9:	55                   	push   %ebp
  8012ba:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bf:	05 00 00 00 30       	add    $0x30000000,%eax
  8012c4:	c1 e8 0c             	shr    $0xc,%eax
}
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    

008012c9 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012c9:	55                   	push   %ebp
  8012ca:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012cc:	8b 45 08             	mov    0x8(%ebp),%eax
  8012cf:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8012d4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012d9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012de:	5d                   	pop    %ebp
  8012df:	c3                   	ret    

008012e0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012e8:	89 c2                	mov    %eax,%edx
  8012ea:	c1 ea 16             	shr    $0x16,%edx
  8012ed:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012f4:	f6 c2 01             	test   $0x1,%dl
  8012f7:	74 29                	je     801322 <fd_alloc+0x42>
  8012f9:	89 c2                	mov    %eax,%edx
  8012fb:	c1 ea 0c             	shr    $0xc,%edx
  8012fe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801305:	f6 c2 01             	test   $0x1,%dl
  801308:	74 18                	je     801322 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  80130a:	05 00 10 00 00       	add    $0x1000,%eax
  80130f:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801314:	75 d2                	jne    8012e8 <fd_alloc+0x8>
  801316:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80131b:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801320:	eb 05                	jmp    801327 <fd_alloc+0x47>
			return 0;
  801322:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801327:	8b 55 08             	mov    0x8(%ebp),%edx
  80132a:	89 02                	mov    %eax,(%edx)
}
  80132c:	89 c8                	mov    %ecx,%eax
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    

00801330 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801330:	55                   	push   %ebp
  801331:	89 e5                	mov    %esp,%ebp
  801333:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801336:	83 f8 1f             	cmp    $0x1f,%eax
  801339:	77 30                	ja     80136b <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80133b:	c1 e0 0c             	shl    $0xc,%eax
  80133e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801343:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801349:	f6 c2 01             	test   $0x1,%dl
  80134c:	74 24                	je     801372 <fd_lookup+0x42>
  80134e:	89 c2                	mov    %eax,%edx
  801350:	c1 ea 0c             	shr    $0xc,%edx
  801353:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80135a:	f6 c2 01             	test   $0x1,%dl
  80135d:	74 1a                	je     801379 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80135f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801362:	89 02                	mov    %eax,(%edx)
	return 0;
  801364:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801369:	5d                   	pop    %ebp
  80136a:	c3                   	ret    
		return -E_INVAL;
  80136b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801370:	eb f7                	jmp    801369 <fd_lookup+0x39>
		return -E_INVAL;
  801372:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801377:	eb f0                	jmp    801369 <fd_lookup+0x39>
  801379:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80137e:	eb e9                	jmp    801369 <fd_lookup+0x39>

00801380 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	53                   	push   %ebx
  801384:	83 ec 04             	sub    $0x4,%esp
  801387:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80138a:	b8 00 00 00 00       	mov    $0x0,%eax
  80138f:	bb 08 30 80 00       	mov    $0x803008,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801394:	39 13                	cmp    %edx,(%ebx)
  801396:	74 37                	je     8013cf <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  801398:	83 c0 01             	add    $0x1,%eax
  80139b:	8b 1c 85 34 2e 80 00 	mov    0x802e34(,%eax,4),%ebx
  8013a2:	85 db                	test   %ebx,%ebx
  8013a4:	75 ee                	jne    801394 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013a6:	a1 00 40 80 00       	mov    0x804000,%eax
  8013ab:	8b 40 58             	mov    0x58(%eax),%eax
  8013ae:	83 ec 04             	sub    $0x4,%esp
  8013b1:	52                   	push   %edx
  8013b2:	50                   	push   %eax
  8013b3:	68 b8 2d 80 00       	push   $0x802db8
  8013b8:	e8 53 f0 ff ff       	call   800410 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8013c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c8:	89 1a                	mov    %ebx,(%edx)
}
  8013ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013cd:	c9                   	leave  
  8013ce:	c3                   	ret    
			return 0;
  8013cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8013d4:	eb ef                	jmp    8013c5 <dev_lookup+0x45>

008013d6 <fd_close>:
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	57                   	push   %edi
  8013da:	56                   	push   %esi
  8013db:	53                   	push   %ebx
  8013dc:	83 ec 24             	sub    $0x24,%esp
  8013df:	8b 75 08             	mov    0x8(%ebp),%esi
  8013e2:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013e5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013e8:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8013e9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013ef:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013f2:	50                   	push   %eax
  8013f3:	e8 38 ff ff ff       	call   801330 <fd_lookup>
  8013f8:	89 c3                	mov    %eax,%ebx
  8013fa:	83 c4 10             	add    $0x10,%esp
  8013fd:	85 c0                	test   %eax,%eax
  8013ff:	78 05                	js     801406 <fd_close+0x30>
	    || fd != fd2)
  801401:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801404:	74 16                	je     80141c <fd_close+0x46>
		return (must_exist ? r : 0);
  801406:	89 f8                	mov    %edi,%eax
  801408:	84 c0                	test   %al,%al
  80140a:	b8 00 00 00 00       	mov    $0x0,%eax
  80140f:	0f 44 d8             	cmove  %eax,%ebx
}
  801412:	89 d8                	mov    %ebx,%eax
  801414:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801417:	5b                   	pop    %ebx
  801418:	5e                   	pop    %esi
  801419:	5f                   	pop    %edi
  80141a:	5d                   	pop    %ebp
  80141b:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80141c:	83 ec 08             	sub    $0x8,%esp
  80141f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801422:	50                   	push   %eax
  801423:	ff 36                	push   (%esi)
  801425:	e8 56 ff ff ff       	call   801380 <dev_lookup>
  80142a:	89 c3                	mov    %eax,%ebx
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	85 c0                	test   %eax,%eax
  801431:	78 1a                	js     80144d <fd_close+0x77>
		if (dev->dev_close)
  801433:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801436:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801439:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80143e:	85 c0                	test   %eax,%eax
  801440:	74 0b                	je     80144d <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801442:	83 ec 0c             	sub    $0xc,%esp
  801445:	56                   	push   %esi
  801446:	ff d0                	call   *%eax
  801448:	89 c3                	mov    %eax,%ebx
  80144a:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80144d:	83 ec 08             	sub    $0x8,%esp
  801450:	56                   	push   %esi
  801451:	6a 00                	push   $0x0
  801453:	e8 13 fa ff ff       	call   800e6b <sys_page_unmap>
	return r;
  801458:	83 c4 10             	add    $0x10,%esp
  80145b:	eb b5                	jmp    801412 <fd_close+0x3c>

0080145d <close>:

int
close(int fdnum)
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801463:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801466:	50                   	push   %eax
  801467:	ff 75 08             	push   0x8(%ebp)
  80146a:	e8 c1 fe ff ff       	call   801330 <fd_lookup>
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	85 c0                	test   %eax,%eax
  801474:	79 02                	jns    801478 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801476:	c9                   	leave  
  801477:	c3                   	ret    
		return fd_close(fd, 1);
  801478:	83 ec 08             	sub    $0x8,%esp
  80147b:	6a 01                	push   $0x1
  80147d:	ff 75 f4             	push   -0xc(%ebp)
  801480:	e8 51 ff ff ff       	call   8013d6 <fd_close>
  801485:	83 c4 10             	add    $0x10,%esp
  801488:	eb ec                	jmp    801476 <close+0x19>

0080148a <close_all>:

void
close_all(void)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	53                   	push   %ebx
  80148e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801491:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801496:	83 ec 0c             	sub    $0xc,%esp
  801499:	53                   	push   %ebx
  80149a:	e8 be ff ff ff       	call   80145d <close>
	for (i = 0; i < MAXFD; i++)
  80149f:	83 c3 01             	add    $0x1,%ebx
  8014a2:	83 c4 10             	add    $0x10,%esp
  8014a5:	83 fb 20             	cmp    $0x20,%ebx
  8014a8:	75 ec                	jne    801496 <close_all+0xc>
}
  8014aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ad:	c9                   	leave  
  8014ae:	c3                   	ret    

008014af <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014af:	55                   	push   %ebp
  8014b0:	89 e5                	mov    %esp,%ebp
  8014b2:	57                   	push   %edi
  8014b3:	56                   	push   %esi
  8014b4:	53                   	push   %ebx
  8014b5:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014b8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014bb:	50                   	push   %eax
  8014bc:	ff 75 08             	push   0x8(%ebp)
  8014bf:	e8 6c fe ff ff       	call   801330 <fd_lookup>
  8014c4:	89 c3                	mov    %eax,%ebx
  8014c6:	83 c4 10             	add    $0x10,%esp
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 7f                	js     80154c <dup+0x9d>
		return r;
	close(newfdnum);
  8014cd:	83 ec 0c             	sub    $0xc,%esp
  8014d0:	ff 75 0c             	push   0xc(%ebp)
  8014d3:	e8 85 ff ff ff       	call   80145d <close>

	newfd = INDEX2FD(newfdnum);
  8014d8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014db:	c1 e6 0c             	shl    $0xc,%esi
  8014de:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8014e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014e7:	89 3c 24             	mov    %edi,(%esp)
  8014ea:	e8 da fd ff ff       	call   8012c9 <fd2data>
  8014ef:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8014f1:	89 34 24             	mov    %esi,(%esp)
  8014f4:	e8 d0 fd ff ff       	call   8012c9 <fd2data>
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014ff:	89 d8                	mov    %ebx,%eax
  801501:	c1 e8 16             	shr    $0x16,%eax
  801504:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80150b:	a8 01                	test   $0x1,%al
  80150d:	74 11                	je     801520 <dup+0x71>
  80150f:	89 d8                	mov    %ebx,%eax
  801511:	c1 e8 0c             	shr    $0xc,%eax
  801514:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80151b:	f6 c2 01             	test   $0x1,%dl
  80151e:	75 36                	jne    801556 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801520:	89 f8                	mov    %edi,%eax
  801522:	c1 e8 0c             	shr    $0xc,%eax
  801525:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80152c:	83 ec 0c             	sub    $0xc,%esp
  80152f:	25 07 0e 00 00       	and    $0xe07,%eax
  801534:	50                   	push   %eax
  801535:	56                   	push   %esi
  801536:	6a 00                	push   $0x0
  801538:	57                   	push   %edi
  801539:	6a 00                	push   $0x0
  80153b:	e8 e9 f8 ff ff       	call   800e29 <sys_page_map>
  801540:	89 c3                	mov    %eax,%ebx
  801542:	83 c4 20             	add    $0x20,%esp
  801545:	85 c0                	test   %eax,%eax
  801547:	78 33                	js     80157c <dup+0xcd>
		goto err;

	return newfdnum;
  801549:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80154c:	89 d8                	mov    %ebx,%eax
  80154e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801551:	5b                   	pop    %ebx
  801552:	5e                   	pop    %esi
  801553:	5f                   	pop    %edi
  801554:	5d                   	pop    %ebp
  801555:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801556:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80155d:	83 ec 0c             	sub    $0xc,%esp
  801560:	25 07 0e 00 00       	and    $0xe07,%eax
  801565:	50                   	push   %eax
  801566:	ff 75 d4             	push   -0x2c(%ebp)
  801569:	6a 00                	push   $0x0
  80156b:	53                   	push   %ebx
  80156c:	6a 00                	push   $0x0
  80156e:	e8 b6 f8 ff ff       	call   800e29 <sys_page_map>
  801573:	89 c3                	mov    %eax,%ebx
  801575:	83 c4 20             	add    $0x20,%esp
  801578:	85 c0                	test   %eax,%eax
  80157a:	79 a4                	jns    801520 <dup+0x71>
	sys_page_unmap(0, newfd);
  80157c:	83 ec 08             	sub    $0x8,%esp
  80157f:	56                   	push   %esi
  801580:	6a 00                	push   $0x0
  801582:	e8 e4 f8 ff ff       	call   800e6b <sys_page_unmap>
	sys_page_unmap(0, nva);
  801587:	83 c4 08             	add    $0x8,%esp
  80158a:	ff 75 d4             	push   -0x2c(%ebp)
  80158d:	6a 00                	push   $0x0
  80158f:	e8 d7 f8 ff ff       	call   800e6b <sys_page_unmap>
	return r;
  801594:	83 c4 10             	add    $0x10,%esp
  801597:	eb b3                	jmp    80154c <dup+0x9d>

00801599 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801599:	55                   	push   %ebp
  80159a:	89 e5                	mov    %esp,%ebp
  80159c:	56                   	push   %esi
  80159d:	53                   	push   %ebx
  80159e:	83 ec 18             	sub    $0x18,%esp
  8015a1:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015a7:	50                   	push   %eax
  8015a8:	56                   	push   %esi
  8015a9:	e8 82 fd ff ff       	call   801330 <fd_lookup>
  8015ae:	83 c4 10             	add    $0x10,%esp
  8015b1:	85 c0                	test   %eax,%eax
  8015b3:	78 3c                	js     8015f1 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015b5:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8015b8:	83 ec 08             	sub    $0x8,%esp
  8015bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015be:	50                   	push   %eax
  8015bf:	ff 33                	push   (%ebx)
  8015c1:	e8 ba fd ff ff       	call   801380 <dev_lookup>
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	78 24                	js     8015f1 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015cd:	8b 43 08             	mov    0x8(%ebx),%eax
  8015d0:	83 e0 03             	and    $0x3,%eax
  8015d3:	83 f8 01             	cmp    $0x1,%eax
  8015d6:	74 20                	je     8015f8 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8015d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015db:	8b 40 08             	mov    0x8(%eax),%eax
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	74 37                	je     801619 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015e2:	83 ec 04             	sub    $0x4,%esp
  8015e5:	ff 75 10             	push   0x10(%ebp)
  8015e8:	ff 75 0c             	push   0xc(%ebp)
  8015eb:	53                   	push   %ebx
  8015ec:	ff d0                	call   *%eax
  8015ee:	83 c4 10             	add    $0x10,%esp
}
  8015f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015f4:	5b                   	pop    %ebx
  8015f5:	5e                   	pop    %esi
  8015f6:	5d                   	pop    %ebp
  8015f7:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015f8:	a1 00 40 80 00       	mov    0x804000,%eax
  8015fd:	8b 40 58             	mov    0x58(%eax),%eax
  801600:	83 ec 04             	sub    $0x4,%esp
  801603:	56                   	push   %esi
  801604:	50                   	push   %eax
  801605:	68 f9 2d 80 00       	push   $0x802df9
  80160a:	e8 01 ee ff ff       	call   800410 <cprintf>
		return -E_INVAL;
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801617:	eb d8                	jmp    8015f1 <read+0x58>
		return -E_NOT_SUPP;
  801619:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80161e:	eb d1                	jmp    8015f1 <read+0x58>

00801620 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801620:	55                   	push   %ebp
  801621:	89 e5                	mov    %esp,%ebp
  801623:	57                   	push   %edi
  801624:	56                   	push   %esi
  801625:	53                   	push   %ebx
  801626:	83 ec 0c             	sub    $0xc,%esp
  801629:	8b 7d 08             	mov    0x8(%ebp),%edi
  80162c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80162f:	bb 00 00 00 00       	mov    $0x0,%ebx
  801634:	eb 02                	jmp    801638 <readn+0x18>
  801636:	01 c3                	add    %eax,%ebx
  801638:	39 f3                	cmp    %esi,%ebx
  80163a:	73 21                	jae    80165d <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80163c:	83 ec 04             	sub    $0x4,%esp
  80163f:	89 f0                	mov    %esi,%eax
  801641:	29 d8                	sub    %ebx,%eax
  801643:	50                   	push   %eax
  801644:	89 d8                	mov    %ebx,%eax
  801646:	03 45 0c             	add    0xc(%ebp),%eax
  801649:	50                   	push   %eax
  80164a:	57                   	push   %edi
  80164b:	e8 49 ff ff ff       	call   801599 <read>
		if (m < 0)
  801650:	83 c4 10             	add    $0x10,%esp
  801653:	85 c0                	test   %eax,%eax
  801655:	78 04                	js     80165b <readn+0x3b>
			return m;
		if (m == 0)
  801657:	75 dd                	jne    801636 <readn+0x16>
  801659:	eb 02                	jmp    80165d <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80165b:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80165d:	89 d8                	mov    %ebx,%eax
  80165f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801662:	5b                   	pop    %ebx
  801663:	5e                   	pop    %esi
  801664:	5f                   	pop    %edi
  801665:	5d                   	pop    %ebp
  801666:	c3                   	ret    

00801667 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801667:	55                   	push   %ebp
  801668:	89 e5                	mov    %esp,%ebp
  80166a:	56                   	push   %esi
  80166b:	53                   	push   %ebx
  80166c:	83 ec 18             	sub    $0x18,%esp
  80166f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801672:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801675:	50                   	push   %eax
  801676:	53                   	push   %ebx
  801677:	e8 b4 fc ff ff       	call   801330 <fd_lookup>
  80167c:	83 c4 10             	add    $0x10,%esp
  80167f:	85 c0                	test   %eax,%eax
  801681:	78 37                	js     8016ba <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801683:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801686:	83 ec 08             	sub    $0x8,%esp
  801689:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168c:	50                   	push   %eax
  80168d:	ff 36                	push   (%esi)
  80168f:	e8 ec fc ff ff       	call   801380 <dev_lookup>
  801694:	83 c4 10             	add    $0x10,%esp
  801697:	85 c0                	test   %eax,%eax
  801699:	78 1f                	js     8016ba <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80169b:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80169f:	74 20                	je     8016c1 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a7:	85 c0                	test   %eax,%eax
  8016a9:	74 37                	je     8016e2 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016ab:	83 ec 04             	sub    $0x4,%esp
  8016ae:	ff 75 10             	push   0x10(%ebp)
  8016b1:	ff 75 0c             	push   0xc(%ebp)
  8016b4:	56                   	push   %esi
  8016b5:	ff d0                	call   *%eax
  8016b7:	83 c4 10             	add    $0x10,%esp
}
  8016ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016bd:	5b                   	pop    %ebx
  8016be:	5e                   	pop    %esi
  8016bf:	5d                   	pop    %ebp
  8016c0:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016c1:	a1 00 40 80 00       	mov    0x804000,%eax
  8016c6:	8b 40 58             	mov    0x58(%eax),%eax
  8016c9:	83 ec 04             	sub    $0x4,%esp
  8016cc:	53                   	push   %ebx
  8016cd:	50                   	push   %eax
  8016ce:	68 15 2e 80 00       	push   $0x802e15
  8016d3:	e8 38 ed ff ff       	call   800410 <cprintf>
		return -E_INVAL;
  8016d8:	83 c4 10             	add    $0x10,%esp
  8016db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016e0:	eb d8                	jmp    8016ba <write+0x53>
		return -E_NOT_SUPP;
  8016e2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016e7:	eb d1                	jmp    8016ba <write+0x53>

008016e9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016e9:	55                   	push   %ebp
  8016ea:	89 e5                	mov    %esp,%ebp
  8016ec:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016f2:	50                   	push   %eax
  8016f3:	ff 75 08             	push   0x8(%ebp)
  8016f6:	e8 35 fc ff ff       	call   801330 <fd_lookup>
  8016fb:	83 c4 10             	add    $0x10,%esp
  8016fe:	85 c0                	test   %eax,%eax
  801700:	78 0e                	js     801710 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801702:	8b 55 0c             	mov    0xc(%ebp),%edx
  801705:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801708:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80170b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801710:	c9                   	leave  
  801711:	c3                   	ret    

00801712 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801712:	55                   	push   %ebp
  801713:	89 e5                	mov    %esp,%ebp
  801715:	56                   	push   %esi
  801716:	53                   	push   %ebx
  801717:	83 ec 18             	sub    $0x18,%esp
  80171a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80171d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801720:	50                   	push   %eax
  801721:	53                   	push   %ebx
  801722:	e8 09 fc ff ff       	call   801330 <fd_lookup>
  801727:	83 c4 10             	add    $0x10,%esp
  80172a:	85 c0                	test   %eax,%eax
  80172c:	78 34                	js     801762 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80172e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801731:	83 ec 08             	sub    $0x8,%esp
  801734:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801737:	50                   	push   %eax
  801738:	ff 36                	push   (%esi)
  80173a:	e8 41 fc ff ff       	call   801380 <dev_lookup>
  80173f:	83 c4 10             	add    $0x10,%esp
  801742:	85 c0                	test   %eax,%eax
  801744:	78 1c                	js     801762 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801746:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80174a:	74 1d                	je     801769 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80174c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80174f:	8b 40 18             	mov    0x18(%eax),%eax
  801752:	85 c0                	test   %eax,%eax
  801754:	74 34                	je     80178a <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801756:	83 ec 08             	sub    $0x8,%esp
  801759:	ff 75 0c             	push   0xc(%ebp)
  80175c:	56                   	push   %esi
  80175d:	ff d0                	call   *%eax
  80175f:	83 c4 10             	add    $0x10,%esp
}
  801762:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801765:	5b                   	pop    %ebx
  801766:	5e                   	pop    %esi
  801767:	5d                   	pop    %ebp
  801768:	c3                   	ret    
			thisenv->env_id, fdnum);
  801769:	a1 00 40 80 00       	mov    0x804000,%eax
  80176e:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801771:	83 ec 04             	sub    $0x4,%esp
  801774:	53                   	push   %ebx
  801775:	50                   	push   %eax
  801776:	68 d8 2d 80 00       	push   $0x802dd8
  80177b:	e8 90 ec ff ff       	call   800410 <cprintf>
		return -E_INVAL;
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801788:	eb d8                	jmp    801762 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80178a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80178f:	eb d1                	jmp    801762 <ftruncate+0x50>

00801791 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	56                   	push   %esi
  801795:	53                   	push   %ebx
  801796:	83 ec 18             	sub    $0x18,%esp
  801799:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80179c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80179f:	50                   	push   %eax
  8017a0:	ff 75 08             	push   0x8(%ebp)
  8017a3:	e8 88 fb ff ff       	call   801330 <fd_lookup>
  8017a8:	83 c4 10             	add    $0x10,%esp
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	78 49                	js     8017f8 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017af:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8017b2:	83 ec 08             	sub    $0x8,%esp
  8017b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017b8:	50                   	push   %eax
  8017b9:	ff 36                	push   (%esi)
  8017bb:	e8 c0 fb ff ff       	call   801380 <dev_lookup>
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	85 c0                	test   %eax,%eax
  8017c5:	78 31                	js     8017f8 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8017c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ca:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017ce:	74 2f                	je     8017ff <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017d0:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017d3:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017da:	00 00 00 
	stat->st_isdir = 0;
  8017dd:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017e4:	00 00 00 
	stat->st_dev = dev;
  8017e7:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017ed:	83 ec 08             	sub    $0x8,%esp
  8017f0:	53                   	push   %ebx
  8017f1:	56                   	push   %esi
  8017f2:	ff 50 14             	call   *0x14(%eax)
  8017f5:	83 c4 10             	add    $0x10,%esp
}
  8017f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017fb:	5b                   	pop    %ebx
  8017fc:	5e                   	pop    %esi
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    
		return -E_NOT_SUPP;
  8017ff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801804:	eb f2                	jmp    8017f8 <fstat+0x67>

00801806 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801806:	55                   	push   %ebp
  801807:	89 e5                	mov    %esp,%ebp
  801809:	56                   	push   %esi
  80180a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80180b:	83 ec 08             	sub    $0x8,%esp
  80180e:	6a 00                	push   $0x0
  801810:	ff 75 08             	push   0x8(%ebp)
  801813:	e8 e4 01 00 00       	call   8019fc <open>
  801818:	89 c3                	mov    %eax,%ebx
  80181a:	83 c4 10             	add    $0x10,%esp
  80181d:	85 c0                	test   %eax,%eax
  80181f:	78 1b                	js     80183c <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801821:	83 ec 08             	sub    $0x8,%esp
  801824:	ff 75 0c             	push   0xc(%ebp)
  801827:	50                   	push   %eax
  801828:	e8 64 ff ff ff       	call   801791 <fstat>
  80182d:	89 c6                	mov    %eax,%esi
	close(fd);
  80182f:	89 1c 24             	mov    %ebx,(%esp)
  801832:	e8 26 fc ff ff       	call   80145d <close>
	return r;
  801837:	83 c4 10             	add    $0x10,%esp
  80183a:	89 f3                	mov    %esi,%ebx
}
  80183c:	89 d8                	mov    %ebx,%eax
  80183e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801841:	5b                   	pop    %ebx
  801842:	5e                   	pop    %esi
  801843:	5d                   	pop    %ebp
  801844:	c3                   	ret    

00801845 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801845:	55                   	push   %ebp
  801846:	89 e5                	mov    %esp,%ebp
  801848:	56                   	push   %esi
  801849:	53                   	push   %ebx
  80184a:	89 c6                	mov    %eax,%esi
  80184c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80184e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801855:	74 27                	je     80187e <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801857:	6a 07                	push   $0x7
  801859:	68 00 50 80 00       	push   $0x805000
  80185e:	56                   	push   %esi
  80185f:	ff 35 00 60 80 00    	push   0x806000
  801865:	e8 bb 0c 00 00       	call   802525 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80186a:	83 c4 0c             	add    $0xc,%esp
  80186d:	6a 00                	push   $0x0
  80186f:	53                   	push   %ebx
  801870:	6a 00                	push   $0x0
  801872:	e8 3e 0c 00 00       	call   8024b5 <ipc_recv>
}
  801877:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187a:	5b                   	pop    %ebx
  80187b:	5e                   	pop    %esi
  80187c:	5d                   	pop    %ebp
  80187d:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80187e:	83 ec 0c             	sub    $0xc,%esp
  801881:	6a 01                	push   $0x1
  801883:	e8 f1 0c 00 00       	call   802579 <ipc_find_env>
  801888:	a3 00 60 80 00       	mov    %eax,0x806000
  80188d:	83 c4 10             	add    $0x10,%esp
  801890:	eb c5                	jmp    801857 <fsipc+0x12>

00801892 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801898:	8b 45 08             	mov    0x8(%ebp),%eax
  80189b:	8b 40 0c             	mov    0xc(%eax),%eax
  80189e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a6:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b0:	b8 02 00 00 00       	mov    $0x2,%eax
  8018b5:	e8 8b ff ff ff       	call   801845 <fsipc>
}
  8018ba:	c9                   	leave  
  8018bb:	c3                   	ret    

008018bc <devfile_flush>:
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d2:	b8 06 00 00 00       	mov    $0x6,%eax
  8018d7:	e8 69 ff ff ff       	call   801845 <fsipc>
}
  8018dc:	c9                   	leave  
  8018dd:	c3                   	ret    

008018de <devfile_stat>:
{
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	53                   	push   %ebx
  8018e2:	83 ec 04             	sub    $0x4,%esp
  8018e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ee:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f8:	b8 05 00 00 00       	mov    $0x5,%eax
  8018fd:	e8 43 ff ff ff       	call   801845 <fsipc>
  801902:	85 c0                	test   %eax,%eax
  801904:	78 2c                	js     801932 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801906:	83 ec 08             	sub    $0x8,%esp
  801909:	68 00 50 80 00       	push   $0x805000
  80190e:	53                   	push   %ebx
  80190f:	e8 d6 f0 ff ff       	call   8009ea <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801914:	a1 80 50 80 00       	mov    0x805080,%eax
  801919:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80191f:	a1 84 50 80 00       	mov    0x805084,%eax
  801924:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80192a:	83 c4 10             	add    $0x10,%esp
  80192d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801932:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801935:	c9                   	leave  
  801936:	c3                   	ret    

00801937 <devfile_write>:
{
  801937:	55                   	push   %ebp
  801938:	89 e5                	mov    %esp,%ebp
  80193a:	83 ec 0c             	sub    $0xc,%esp
  80193d:	8b 45 10             	mov    0x10(%ebp),%eax
  801940:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801945:	39 d0                	cmp    %edx,%eax
  801947:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80194a:	8b 55 08             	mov    0x8(%ebp),%edx
  80194d:	8b 52 0c             	mov    0xc(%edx),%edx
  801950:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801956:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80195b:	50                   	push   %eax
  80195c:	ff 75 0c             	push   0xc(%ebp)
  80195f:	68 08 50 80 00       	push   $0x805008
  801964:	e8 17 f2 ff ff       	call   800b80 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801969:	ba 00 00 00 00       	mov    $0x0,%edx
  80196e:	b8 04 00 00 00       	mov    $0x4,%eax
  801973:	e8 cd fe ff ff       	call   801845 <fsipc>
}
  801978:	c9                   	leave  
  801979:	c3                   	ret    

0080197a <devfile_read>:
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	56                   	push   %esi
  80197e:	53                   	push   %ebx
  80197f:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801982:	8b 45 08             	mov    0x8(%ebp),%eax
  801985:	8b 40 0c             	mov    0xc(%eax),%eax
  801988:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80198d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801993:	ba 00 00 00 00       	mov    $0x0,%edx
  801998:	b8 03 00 00 00       	mov    $0x3,%eax
  80199d:	e8 a3 fe ff ff       	call   801845 <fsipc>
  8019a2:	89 c3                	mov    %eax,%ebx
  8019a4:	85 c0                	test   %eax,%eax
  8019a6:	78 1f                	js     8019c7 <devfile_read+0x4d>
	assert(r <= n);
  8019a8:	39 f0                	cmp    %esi,%eax
  8019aa:	77 24                	ja     8019d0 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8019ac:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019b1:	7f 33                	jg     8019e6 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019b3:	83 ec 04             	sub    $0x4,%esp
  8019b6:	50                   	push   %eax
  8019b7:	68 00 50 80 00       	push   $0x805000
  8019bc:	ff 75 0c             	push   0xc(%ebp)
  8019bf:	e8 bc f1 ff ff       	call   800b80 <memmove>
	return r;
  8019c4:	83 c4 10             	add    $0x10,%esp
}
  8019c7:	89 d8                	mov    %ebx,%eax
  8019c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019cc:	5b                   	pop    %ebx
  8019cd:	5e                   	pop    %esi
  8019ce:	5d                   	pop    %ebp
  8019cf:	c3                   	ret    
	assert(r <= n);
  8019d0:	68 48 2e 80 00       	push   $0x802e48
  8019d5:	68 4f 2e 80 00       	push   $0x802e4f
  8019da:	6a 7c                	push   $0x7c
  8019dc:	68 64 2e 80 00       	push   $0x802e64
  8019e1:	e8 4f e9 ff ff       	call   800335 <_panic>
	assert(r <= PGSIZE);
  8019e6:	68 6f 2e 80 00       	push   $0x802e6f
  8019eb:	68 4f 2e 80 00       	push   $0x802e4f
  8019f0:	6a 7d                	push   $0x7d
  8019f2:	68 64 2e 80 00       	push   $0x802e64
  8019f7:	e8 39 e9 ff ff       	call   800335 <_panic>

008019fc <open>:
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	56                   	push   %esi
  801a00:	53                   	push   %ebx
  801a01:	83 ec 1c             	sub    $0x1c,%esp
  801a04:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801a07:	56                   	push   %esi
  801a08:	e8 a2 ef ff ff       	call   8009af <strlen>
  801a0d:	83 c4 10             	add    $0x10,%esp
  801a10:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a15:	7f 6c                	jg     801a83 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801a17:	83 ec 0c             	sub    $0xc,%esp
  801a1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a1d:	50                   	push   %eax
  801a1e:	e8 bd f8 ff ff       	call   8012e0 <fd_alloc>
  801a23:	89 c3                	mov    %eax,%ebx
  801a25:	83 c4 10             	add    $0x10,%esp
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	78 3c                	js     801a68 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801a2c:	83 ec 08             	sub    $0x8,%esp
  801a2f:	56                   	push   %esi
  801a30:	68 00 50 80 00       	push   $0x805000
  801a35:	e8 b0 ef ff ff       	call   8009ea <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a3d:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a42:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a45:	b8 01 00 00 00       	mov    $0x1,%eax
  801a4a:	e8 f6 fd ff ff       	call   801845 <fsipc>
  801a4f:	89 c3                	mov    %eax,%ebx
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	85 c0                	test   %eax,%eax
  801a56:	78 19                	js     801a71 <open+0x75>
	return fd2num(fd);
  801a58:	83 ec 0c             	sub    $0xc,%esp
  801a5b:	ff 75 f4             	push   -0xc(%ebp)
  801a5e:	e8 56 f8 ff ff       	call   8012b9 <fd2num>
  801a63:	89 c3                	mov    %eax,%ebx
  801a65:	83 c4 10             	add    $0x10,%esp
}
  801a68:	89 d8                	mov    %ebx,%eax
  801a6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6d:	5b                   	pop    %ebx
  801a6e:	5e                   	pop    %esi
  801a6f:	5d                   	pop    %ebp
  801a70:	c3                   	ret    
		fd_close(fd, 0);
  801a71:	83 ec 08             	sub    $0x8,%esp
  801a74:	6a 00                	push   $0x0
  801a76:	ff 75 f4             	push   -0xc(%ebp)
  801a79:	e8 58 f9 ff ff       	call   8013d6 <fd_close>
		return r;
  801a7e:	83 c4 10             	add    $0x10,%esp
  801a81:	eb e5                	jmp    801a68 <open+0x6c>
		return -E_BAD_PATH;
  801a83:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801a88:	eb de                	jmp    801a68 <open+0x6c>

00801a8a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a90:	ba 00 00 00 00       	mov    $0x0,%edx
  801a95:	b8 08 00 00 00       	mov    $0x8,%eax
  801a9a:	e8 a6 fd ff ff       	call   801845 <fsipc>
}
  801a9f:	c9                   	leave  
  801aa0:	c3                   	ret    

00801aa1 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801aa1:	55                   	push   %ebp
  801aa2:	89 e5                	mov    %esp,%ebp
  801aa4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801aa7:	68 7b 2e 80 00       	push   $0x802e7b
  801aac:	ff 75 0c             	push   0xc(%ebp)
  801aaf:	e8 36 ef ff ff       	call   8009ea <strcpy>
	return 0;
}
  801ab4:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab9:	c9                   	leave  
  801aba:	c3                   	ret    

00801abb <devsock_close>:
{
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	53                   	push   %ebx
  801abf:	83 ec 10             	sub    $0x10,%esp
  801ac2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ac5:	53                   	push   %ebx
  801ac6:	e8 ed 0a 00 00       	call   8025b8 <pageref>
  801acb:	89 c2                	mov    %eax,%edx
  801acd:	83 c4 10             	add    $0x10,%esp
		return 0;
  801ad0:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801ad5:	83 fa 01             	cmp    $0x1,%edx
  801ad8:	74 05                	je     801adf <devsock_close+0x24>
}
  801ada:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801add:	c9                   	leave  
  801ade:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801adf:	83 ec 0c             	sub    $0xc,%esp
  801ae2:	ff 73 0c             	push   0xc(%ebx)
  801ae5:	e8 b7 02 00 00       	call   801da1 <nsipc_close>
  801aea:	83 c4 10             	add    $0x10,%esp
  801aed:	eb eb                	jmp    801ada <devsock_close+0x1f>

00801aef <devsock_write>:
{
  801aef:	55                   	push   %ebp
  801af0:	89 e5                	mov    %esp,%ebp
  801af2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801af5:	6a 00                	push   $0x0
  801af7:	ff 75 10             	push   0x10(%ebp)
  801afa:	ff 75 0c             	push   0xc(%ebp)
  801afd:	8b 45 08             	mov    0x8(%ebp),%eax
  801b00:	ff 70 0c             	push   0xc(%eax)
  801b03:	e8 79 03 00 00       	call   801e81 <nsipc_send>
}
  801b08:	c9                   	leave  
  801b09:	c3                   	ret    

00801b0a <devsock_read>:
{
  801b0a:	55                   	push   %ebp
  801b0b:	89 e5                	mov    %esp,%ebp
  801b0d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b10:	6a 00                	push   $0x0
  801b12:	ff 75 10             	push   0x10(%ebp)
  801b15:	ff 75 0c             	push   0xc(%ebp)
  801b18:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1b:	ff 70 0c             	push   0xc(%eax)
  801b1e:	e8 ef 02 00 00       	call   801e12 <nsipc_recv>
}
  801b23:	c9                   	leave  
  801b24:	c3                   	ret    

00801b25 <fd2sockid>:
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b2b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b2e:	52                   	push   %edx
  801b2f:	50                   	push   %eax
  801b30:	e8 fb f7 ff ff       	call   801330 <fd_lookup>
  801b35:	83 c4 10             	add    $0x10,%esp
  801b38:	85 c0                	test   %eax,%eax
  801b3a:	78 10                	js     801b4c <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801b3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b3f:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  801b45:	39 08                	cmp    %ecx,(%eax)
  801b47:	75 05                	jne    801b4e <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801b49:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801b4c:	c9                   	leave  
  801b4d:	c3                   	ret    
		return -E_NOT_SUPP;
  801b4e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b53:	eb f7                	jmp    801b4c <fd2sockid+0x27>

00801b55 <alloc_sockfd>:
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	56                   	push   %esi
  801b59:	53                   	push   %ebx
  801b5a:	83 ec 1c             	sub    $0x1c,%esp
  801b5d:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801b5f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b62:	50                   	push   %eax
  801b63:	e8 78 f7 ff ff       	call   8012e0 <fd_alloc>
  801b68:	89 c3                	mov    %eax,%ebx
  801b6a:	83 c4 10             	add    $0x10,%esp
  801b6d:	85 c0                	test   %eax,%eax
  801b6f:	78 43                	js     801bb4 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801b71:	83 ec 04             	sub    $0x4,%esp
  801b74:	68 07 04 00 00       	push   $0x407
  801b79:	ff 75 f4             	push   -0xc(%ebp)
  801b7c:	6a 00                	push   $0x0
  801b7e:	e8 63 f2 ff ff       	call   800de6 <sys_page_alloc>
  801b83:	89 c3                	mov    %eax,%ebx
  801b85:	83 c4 10             	add    $0x10,%esp
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	78 28                	js     801bb4 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b8f:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801b95:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b9a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ba1:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ba4:	83 ec 0c             	sub    $0xc,%esp
  801ba7:	50                   	push   %eax
  801ba8:	e8 0c f7 ff ff       	call   8012b9 <fd2num>
  801bad:	89 c3                	mov    %eax,%ebx
  801baf:	83 c4 10             	add    $0x10,%esp
  801bb2:	eb 0c                	jmp    801bc0 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801bb4:	83 ec 0c             	sub    $0xc,%esp
  801bb7:	56                   	push   %esi
  801bb8:	e8 e4 01 00 00       	call   801da1 <nsipc_close>
		return r;
  801bbd:	83 c4 10             	add    $0x10,%esp
}
  801bc0:	89 d8                	mov    %ebx,%eax
  801bc2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc5:	5b                   	pop    %ebx
  801bc6:	5e                   	pop    %esi
  801bc7:	5d                   	pop    %ebp
  801bc8:	c3                   	ret    

00801bc9 <accept>:
{
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd2:	e8 4e ff ff ff       	call   801b25 <fd2sockid>
  801bd7:	85 c0                	test   %eax,%eax
  801bd9:	78 1b                	js     801bf6 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801bdb:	83 ec 04             	sub    $0x4,%esp
  801bde:	ff 75 10             	push   0x10(%ebp)
  801be1:	ff 75 0c             	push   0xc(%ebp)
  801be4:	50                   	push   %eax
  801be5:	e8 0e 01 00 00       	call   801cf8 <nsipc_accept>
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	85 c0                	test   %eax,%eax
  801bef:	78 05                	js     801bf6 <accept+0x2d>
	return alloc_sockfd(r);
  801bf1:	e8 5f ff ff ff       	call   801b55 <alloc_sockfd>
}
  801bf6:	c9                   	leave  
  801bf7:	c3                   	ret    

00801bf8 <bind>:
{
  801bf8:	55                   	push   %ebp
  801bf9:	89 e5                	mov    %esp,%ebp
  801bfb:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  801c01:	e8 1f ff ff ff       	call   801b25 <fd2sockid>
  801c06:	85 c0                	test   %eax,%eax
  801c08:	78 12                	js     801c1c <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801c0a:	83 ec 04             	sub    $0x4,%esp
  801c0d:	ff 75 10             	push   0x10(%ebp)
  801c10:	ff 75 0c             	push   0xc(%ebp)
  801c13:	50                   	push   %eax
  801c14:	e8 31 01 00 00       	call   801d4a <nsipc_bind>
  801c19:	83 c4 10             	add    $0x10,%esp
}
  801c1c:	c9                   	leave  
  801c1d:	c3                   	ret    

00801c1e <shutdown>:
{
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c24:	8b 45 08             	mov    0x8(%ebp),%eax
  801c27:	e8 f9 fe ff ff       	call   801b25 <fd2sockid>
  801c2c:	85 c0                	test   %eax,%eax
  801c2e:	78 0f                	js     801c3f <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801c30:	83 ec 08             	sub    $0x8,%esp
  801c33:	ff 75 0c             	push   0xc(%ebp)
  801c36:	50                   	push   %eax
  801c37:	e8 43 01 00 00       	call   801d7f <nsipc_shutdown>
  801c3c:	83 c4 10             	add    $0x10,%esp
}
  801c3f:	c9                   	leave  
  801c40:	c3                   	ret    

00801c41 <connect>:
{
  801c41:	55                   	push   %ebp
  801c42:	89 e5                	mov    %esp,%ebp
  801c44:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c47:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4a:	e8 d6 fe ff ff       	call   801b25 <fd2sockid>
  801c4f:	85 c0                	test   %eax,%eax
  801c51:	78 12                	js     801c65 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801c53:	83 ec 04             	sub    $0x4,%esp
  801c56:	ff 75 10             	push   0x10(%ebp)
  801c59:	ff 75 0c             	push   0xc(%ebp)
  801c5c:	50                   	push   %eax
  801c5d:	e8 59 01 00 00       	call   801dbb <nsipc_connect>
  801c62:	83 c4 10             	add    $0x10,%esp
}
  801c65:	c9                   	leave  
  801c66:	c3                   	ret    

00801c67 <listen>:
{
  801c67:	55                   	push   %ebp
  801c68:	89 e5                	mov    %esp,%ebp
  801c6a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801c6d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c70:	e8 b0 fe ff ff       	call   801b25 <fd2sockid>
  801c75:	85 c0                	test   %eax,%eax
  801c77:	78 0f                	js     801c88 <listen+0x21>
	return nsipc_listen(r, backlog);
  801c79:	83 ec 08             	sub    $0x8,%esp
  801c7c:	ff 75 0c             	push   0xc(%ebp)
  801c7f:	50                   	push   %eax
  801c80:	e8 6b 01 00 00       	call   801df0 <nsipc_listen>
  801c85:	83 c4 10             	add    $0x10,%esp
}
  801c88:	c9                   	leave  
  801c89:	c3                   	ret    

00801c8a <socket>:

int
socket(int domain, int type, int protocol)
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c90:	ff 75 10             	push   0x10(%ebp)
  801c93:	ff 75 0c             	push   0xc(%ebp)
  801c96:	ff 75 08             	push   0x8(%ebp)
  801c99:	e8 41 02 00 00       	call   801edf <nsipc_socket>
  801c9e:	83 c4 10             	add    $0x10,%esp
  801ca1:	85 c0                	test   %eax,%eax
  801ca3:	78 05                	js     801caa <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ca5:	e8 ab fe ff ff       	call   801b55 <alloc_sockfd>
}
  801caa:	c9                   	leave  
  801cab:	c3                   	ret    

00801cac <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	53                   	push   %ebx
  801cb0:	83 ec 04             	sub    $0x4,%esp
  801cb3:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801cb5:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801cbc:	74 26                	je     801ce4 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801cbe:	6a 07                	push   $0x7
  801cc0:	68 00 70 80 00       	push   $0x807000
  801cc5:	53                   	push   %ebx
  801cc6:	ff 35 00 80 80 00    	push   0x808000
  801ccc:	e8 54 08 00 00       	call   802525 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801cd1:	83 c4 0c             	add    $0xc,%esp
  801cd4:	6a 00                	push   $0x0
  801cd6:	6a 00                	push   $0x0
  801cd8:	6a 00                	push   $0x0
  801cda:	e8 d6 07 00 00       	call   8024b5 <ipc_recv>
}
  801cdf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ce2:	c9                   	leave  
  801ce3:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ce4:	83 ec 0c             	sub    $0xc,%esp
  801ce7:	6a 02                	push   $0x2
  801ce9:	e8 8b 08 00 00       	call   802579 <ipc_find_env>
  801cee:	a3 00 80 80 00       	mov    %eax,0x808000
  801cf3:	83 c4 10             	add    $0x10,%esp
  801cf6:	eb c6                	jmp    801cbe <nsipc+0x12>

00801cf8 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cf8:	55                   	push   %ebp
  801cf9:	89 e5                	mov    %esp,%ebp
  801cfb:	56                   	push   %esi
  801cfc:	53                   	push   %ebx
  801cfd:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801d00:	8b 45 08             	mov    0x8(%ebp),%eax
  801d03:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801d08:	8b 06                	mov    (%esi),%eax
  801d0a:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801d0f:	b8 01 00 00 00       	mov    $0x1,%eax
  801d14:	e8 93 ff ff ff       	call   801cac <nsipc>
  801d19:	89 c3                	mov    %eax,%ebx
  801d1b:	85 c0                	test   %eax,%eax
  801d1d:	79 09                	jns    801d28 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801d1f:	89 d8                	mov    %ebx,%eax
  801d21:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d24:	5b                   	pop    %ebx
  801d25:	5e                   	pop    %esi
  801d26:	5d                   	pop    %ebp
  801d27:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801d28:	83 ec 04             	sub    $0x4,%esp
  801d2b:	ff 35 10 70 80 00    	push   0x807010
  801d31:	68 00 70 80 00       	push   $0x807000
  801d36:	ff 75 0c             	push   0xc(%ebp)
  801d39:	e8 42 ee ff ff       	call   800b80 <memmove>
		*addrlen = ret->ret_addrlen;
  801d3e:	a1 10 70 80 00       	mov    0x807010,%eax
  801d43:	89 06                	mov    %eax,(%esi)
  801d45:	83 c4 10             	add    $0x10,%esp
	return r;
  801d48:	eb d5                	jmp    801d1f <nsipc_accept+0x27>

00801d4a <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d4a:	55                   	push   %ebp
  801d4b:	89 e5                	mov    %esp,%ebp
  801d4d:	53                   	push   %ebx
  801d4e:	83 ec 08             	sub    $0x8,%esp
  801d51:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801d54:	8b 45 08             	mov    0x8(%ebp),%eax
  801d57:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801d5c:	53                   	push   %ebx
  801d5d:	ff 75 0c             	push   0xc(%ebp)
  801d60:	68 04 70 80 00       	push   $0x807004
  801d65:	e8 16 ee ff ff       	call   800b80 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801d6a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801d70:	b8 02 00 00 00       	mov    $0x2,%eax
  801d75:	e8 32 ff ff ff       	call   801cac <nsipc>
}
  801d7a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d7d:	c9                   	leave  
  801d7e:	c3                   	ret    

00801d7f <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801d7f:	55                   	push   %ebp
  801d80:	89 e5                	mov    %esp,%ebp
  801d82:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d85:	8b 45 08             	mov    0x8(%ebp),%eax
  801d88:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801d8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d90:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801d95:	b8 03 00 00 00       	mov    $0x3,%eax
  801d9a:	e8 0d ff ff ff       	call   801cac <nsipc>
}
  801d9f:	c9                   	leave  
  801da0:	c3                   	ret    

00801da1 <nsipc_close>:

int
nsipc_close(int s)
{
  801da1:	55                   	push   %ebp
  801da2:	89 e5                	mov    %esp,%ebp
  801da4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801da7:	8b 45 08             	mov    0x8(%ebp),%eax
  801daa:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801daf:	b8 04 00 00 00       	mov    $0x4,%eax
  801db4:	e8 f3 fe ff ff       	call   801cac <nsipc>
}
  801db9:	c9                   	leave  
  801dba:	c3                   	ret    

00801dbb <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	53                   	push   %ebx
  801dbf:	83 ec 08             	sub    $0x8,%esp
  801dc2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc8:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801dcd:	53                   	push   %ebx
  801dce:	ff 75 0c             	push   0xc(%ebp)
  801dd1:	68 04 70 80 00       	push   $0x807004
  801dd6:	e8 a5 ed ff ff       	call   800b80 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ddb:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801de1:	b8 05 00 00 00       	mov    $0x5,%eax
  801de6:	e8 c1 fe ff ff       	call   801cac <nsipc>
}
  801deb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dee:	c9                   	leave  
  801def:	c3                   	ret    

00801df0 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801df6:	8b 45 08             	mov    0x8(%ebp),%eax
  801df9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801dfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e01:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801e06:	b8 06 00 00 00       	mov    $0x6,%eax
  801e0b:	e8 9c fe ff ff       	call   801cac <nsipc>
}
  801e10:	c9                   	leave  
  801e11:	c3                   	ret    

00801e12 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	56                   	push   %esi
  801e16:	53                   	push   %ebx
  801e17:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801e22:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801e28:	8b 45 14             	mov    0x14(%ebp),%eax
  801e2b:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801e30:	b8 07 00 00 00       	mov    $0x7,%eax
  801e35:	e8 72 fe ff ff       	call   801cac <nsipc>
  801e3a:	89 c3                	mov    %eax,%ebx
  801e3c:	85 c0                	test   %eax,%eax
  801e3e:	78 22                	js     801e62 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801e40:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801e45:	39 c6                	cmp    %eax,%esi
  801e47:	0f 4e c6             	cmovle %esi,%eax
  801e4a:	39 c3                	cmp    %eax,%ebx
  801e4c:	7f 1d                	jg     801e6b <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e4e:	83 ec 04             	sub    $0x4,%esp
  801e51:	53                   	push   %ebx
  801e52:	68 00 70 80 00       	push   $0x807000
  801e57:	ff 75 0c             	push   0xc(%ebp)
  801e5a:	e8 21 ed ff ff       	call   800b80 <memmove>
  801e5f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801e62:	89 d8                	mov    %ebx,%eax
  801e64:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e67:	5b                   	pop    %ebx
  801e68:	5e                   	pop    %esi
  801e69:	5d                   	pop    %ebp
  801e6a:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801e6b:	68 87 2e 80 00       	push   $0x802e87
  801e70:	68 4f 2e 80 00       	push   $0x802e4f
  801e75:	6a 62                	push   $0x62
  801e77:	68 9c 2e 80 00       	push   $0x802e9c
  801e7c:	e8 b4 e4 ff ff       	call   800335 <_panic>

00801e81 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e81:	55                   	push   %ebp
  801e82:	89 e5                	mov    %esp,%ebp
  801e84:	53                   	push   %ebx
  801e85:	83 ec 04             	sub    $0x4,%esp
  801e88:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8e:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801e93:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e99:	7f 2e                	jg     801ec9 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e9b:	83 ec 04             	sub    $0x4,%esp
  801e9e:	53                   	push   %ebx
  801e9f:	ff 75 0c             	push   0xc(%ebp)
  801ea2:	68 0c 70 80 00       	push   $0x80700c
  801ea7:	e8 d4 ec ff ff       	call   800b80 <memmove>
	nsipcbuf.send.req_size = size;
  801eac:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801eb2:	8b 45 14             	mov    0x14(%ebp),%eax
  801eb5:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801eba:	b8 08 00 00 00       	mov    $0x8,%eax
  801ebf:	e8 e8 fd ff ff       	call   801cac <nsipc>
}
  801ec4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ec7:	c9                   	leave  
  801ec8:	c3                   	ret    
	assert(size < 1600);
  801ec9:	68 a8 2e 80 00       	push   $0x802ea8
  801ece:	68 4f 2e 80 00       	push   $0x802e4f
  801ed3:	6a 6d                	push   $0x6d
  801ed5:	68 9c 2e 80 00       	push   $0x802e9c
  801eda:	e8 56 e4 ff ff       	call   800335 <_panic>

00801edf <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801edf:	55                   	push   %ebp
  801ee0:	89 e5                	mov    %esp,%ebp
  801ee2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ee5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ee8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801eed:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ef0:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801ef5:	8b 45 10             	mov    0x10(%ebp),%eax
  801ef8:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801efd:	b8 09 00 00 00       	mov    $0x9,%eax
  801f02:	e8 a5 fd ff ff       	call   801cac <nsipc>
}
  801f07:	c9                   	leave  
  801f08:	c3                   	ret    

00801f09 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	56                   	push   %esi
  801f0d:	53                   	push   %ebx
  801f0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801f11:	83 ec 0c             	sub    $0xc,%esp
  801f14:	ff 75 08             	push   0x8(%ebp)
  801f17:	e8 ad f3 ff ff       	call   8012c9 <fd2data>
  801f1c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801f1e:	83 c4 08             	add    $0x8,%esp
  801f21:	68 b4 2e 80 00       	push   $0x802eb4
  801f26:	53                   	push   %ebx
  801f27:	e8 be ea ff ff       	call   8009ea <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801f2c:	8b 46 04             	mov    0x4(%esi),%eax
  801f2f:	2b 06                	sub    (%esi),%eax
  801f31:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801f37:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801f3e:	00 00 00 
	stat->st_dev = &devpipe;
  801f41:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  801f48:	30 80 00 
	return 0;
}
  801f4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f53:	5b                   	pop    %ebx
  801f54:	5e                   	pop    %esi
  801f55:	5d                   	pop    %ebp
  801f56:	c3                   	ret    

00801f57 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801f57:	55                   	push   %ebp
  801f58:	89 e5                	mov    %esp,%ebp
  801f5a:	53                   	push   %ebx
  801f5b:	83 ec 0c             	sub    $0xc,%esp
  801f5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801f61:	53                   	push   %ebx
  801f62:	6a 00                	push   $0x0
  801f64:	e8 02 ef ff ff       	call   800e6b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f69:	89 1c 24             	mov    %ebx,(%esp)
  801f6c:	e8 58 f3 ff ff       	call   8012c9 <fd2data>
  801f71:	83 c4 08             	add    $0x8,%esp
  801f74:	50                   	push   %eax
  801f75:	6a 00                	push   $0x0
  801f77:	e8 ef ee ff ff       	call   800e6b <sys_page_unmap>
}
  801f7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f7f:	c9                   	leave  
  801f80:	c3                   	ret    

00801f81 <_pipeisclosed>:
{
  801f81:	55                   	push   %ebp
  801f82:	89 e5                	mov    %esp,%ebp
  801f84:	57                   	push   %edi
  801f85:	56                   	push   %esi
  801f86:	53                   	push   %ebx
  801f87:	83 ec 1c             	sub    $0x1c,%esp
  801f8a:	89 c7                	mov    %eax,%edi
  801f8c:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801f8e:	a1 00 40 80 00       	mov    0x804000,%eax
  801f93:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f96:	83 ec 0c             	sub    $0xc,%esp
  801f99:	57                   	push   %edi
  801f9a:	e8 19 06 00 00       	call   8025b8 <pageref>
  801f9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801fa2:	89 34 24             	mov    %esi,(%esp)
  801fa5:	e8 0e 06 00 00       	call   8025b8 <pageref>
		nn = thisenv->env_runs;
  801faa:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801fb0:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801fb3:	83 c4 10             	add    $0x10,%esp
  801fb6:	39 cb                	cmp    %ecx,%ebx
  801fb8:	74 1b                	je     801fd5 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801fba:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801fbd:	75 cf                	jne    801f8e <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801fbf:	8b 42 68             	mov    0x68(%edx),%eax
  801fc2:	6a 01                	push   $0x1
  801fc4:	50                   	push   %eax
  801fc5:	53                   	push   %ebx
  801fc6:	68 bb 2e 80 00       	push   $0x802ebb
  801fcb:	e8 40 e4 ff ff       	call   800410 <cprintf>
  801fd0:	83 c4 10             	add    $0x10,%esp
  801fd3:	eb b9                	jmp    801f8e <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801fd5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801fd8:	0f 94 c0             	sete   %al
  801fdb:	0f b6 c0             	movzbl %al,%eax
}
  801fde:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fe1:	5b                   	pop    %ebx
  801fe2:	5e                   	pop    %esi
  801fe3:	5f                   	pop    %edi
  801fe4:	5d                   	pop    %ebp
  801fe5:	c3                   	ret    

00801fe6 <devpipe_write>:
{
  801fe6:	55                   	push   %ebp
  801fe7:	89 e5                	mov    %esp,%ebp
  801fe9:	57                   	push   %edi
  801fea:	56                   	push   %esi
  801feb:	53                   	push   %ebx
  801fec:	83 ec 28             	sub    $0x28,%esp
  801fef:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ff2:	56                   	push   %esi
  801ff3:	e8 d1 f2 ff ff       	call   8012c9 <fd2data>
  801ff8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ffa:	83 c4 10             	add    $0x10,%esp
  801ffd:	bf 00 00 00 00       	mov    $0x0,%edi
  802002:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802005:	75 09                	jne    802010 <devpipe_write+0x2a>
	return i;
  802007:	89 f8                	mov    %edi,%eax
  802009:	eb 23                	jmp    80202e <devpipe_write+0x48>
			sys_yield();
  80200b:	e8 b7 ed ff ff       	call   800dc7 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802010:	8b 43 04             	mov    0x4(%ebx),%eax
  802013:	8b 0b                	mov    (%ebx),%ecx
  802015:	8d 51 20             	lea    0x20(%ecx),%edx
  802018:	39 d0                	cmp    %edx,%eax
  80201a:	72 1a                	jb     802036 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  80201c:	89 da                	mov    %ebx,%edx
  80201e:	89 f0                	mov    %esi,%eax
  802020:	e8 5c ff ff ff       	call   801f81 <_pipeisclosed>
  802025:	85 c0                	test   %eax,%eax
  802027:	74 e2                	je     80200b <devpipe_write+0x25>
				return 0;
  802029:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80202e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802031:	5b                   	pop    %ebx
  802032:	5e                   	pop    %esi
  802033:	5f                   	pop    %edi
  802034:	5d                   	pop    %ebp
  802035:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802036:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802039:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80203d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802040:	89 c2                	mov    %eax,%edx
  802042:	c1 fa 1f             	sar    $0x1f,%edx
  802045:	89 d1                	mov    %edx,%ecx
  802047:	c1 e9 1b             	shr    $0x1b,%ecx
  80204a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80204d:	83 e2 1f             	and    $0x1f,%edx
  802050:	29 ca                	sub    %ecx,%edx
  802052:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802056:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80205a:	83 c0 01             	add    $0x1,%eax
  80205d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802060:	83 c7 01             	add    $0x1,%edi
  802063:	eb 9d                	jmp    802002 <devpipe_write+0x1c>

00802065 <devpipe_read>:
{
  802065:	55                   	push   %ebp
  802066:	89 e5                	mov    %esp,%ebp
  802068:	57                   	push   %edi
  802069:	56                   	push   %esi
  80206a:	53                   	push   %ebx
  80206b:	83 ec 18             	sub    $0x18,%esp
  80206e:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802071:	57                   	push   %edi
  802072:	e8 52 f2 ff ff       	call   8012c9 <fd2data>
  802077:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802079:	83 c4 10             	add    $0x10,%esp
  80207c:	be 00 00 00 00       	mov    $0x0,%esi
  802081:	3b 75 10             	cmp    0x10(%ebp),%esi
  802084:	75 13                	jne    802099 <devpipe_read+0x34>
	return i;
  802086:	89 f0                	mov    %esi,%eax
  802088:	eb 02                	jmp    80208c <devpipe_read+0x27>
				return i;
  80208a:	89 f0                	mov    %esi,%eax
}
  80208c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80208f:	5b                   	pop    %ebx
  802090:	5e                   	pop    %esi
  802091:	5f                   	pop    %edi
  802092:	5d                   	pop    %ebp
  802093:	c3                   	ret    
			sys_yield();
  802094:	e8 2e ed ff ff       	call   800dc7 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802099:	8b 03                	mov    (%ebx),%eax
  80209b:	3b 43 04             	cmp    0x4(%ebx),%eax
  80209e:	75 18                	jne    8020b8 <devpipe_read+0x53>
			if (i > 0)
  8020a0:	85 f6                	test   %esi,%esi
  8020a2:	75 e6                	jne    80208a <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8020a4:	89 da                	mov    %ebx,%edx
  8020a6:	89 f8                	mov    %edi,%eax
  8020a8:	e8 d4 fe ff ff       	call   801f81 <_pipeisclosed>
  8020ad:	85 c0                	test   %eax,%eax
  8020af:	74 e3                	je     802094 <devpipe_read+0x2f>
				return 0;
  8020b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8020b6:	eb d4                	jmp    80208c <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8020b8:	99                   	cltd   
  8020b9:	c1 ea 1b             	shr    $0x1b,%edx
  8020bc:	01 d0                	add    %edx,%eax
  8020be:	83 e0 1f             	and    $0x1f,%eax
  8020c1:	29 d0                	sub    %edx,%eax
  8020c3:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8020c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8020cb:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8020ce:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8020d1:	83 c6 01             	add    $0x1,%esi
  8020d4:	eb ab                	jmp    802081 <devpipe_read+0x1c>

008020d6 <pipe>:
{
  8020d6:	55                   	push   %ebp
  8020d7:	89 e5                	mov    %esp,%ebp
  8020d9:	56                   	push   %esi
  8020da:	53                   	push   %ebx
  8020db:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8020de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020e1:	50                   	push   %eax
  8020e2:	e8 f9 f1 ff ff       	call   8012e0 <fd_alloc>
  8020e7:	89 c3                	mov    %eax,%ebx
  8020e9:	83 c4 10             	add    $0x10,%esp
  8020ec:	85 c0                	test   %eax,%eax
  8020ee:	0f 88 23 01 00 00    	js     802217 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020f4:	83 ec 04             	sub    $0x4,%esp
  8020f7:	68 07 04 00 00       	push   $0x407
  8020fc:	ff 75 f4             	push   -0xc(%ebp)
  8020ff:	6a 00                	push   $0x0
  802101:	e8 e0 ec ff ff       	call   800de6 <sys_page_alloc>
  802106:	89 c3                	mov    %eax,%ebx
  802108:	83 c4 10             	add    $0x10,%esp
  80210b:	85 c0                	test   %eax,%eax
  80210d:	0f 88 04 01 00 00    	js     802217 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802113:	83 ec 0c             	sub    $0xc,%esp
  802116:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802119:	50                   	push   %eax
  80211a:	e8 c1 f1 ff ff       	call   8012e0 <fd_alloc>
  80211f:	89 c3                	mov    %eax,%ebx
  802121:	83 c4 10             	add    $0x10,%esp
  802124:	85 c0                	test   %eax,%eax
  802126:	0f 88 db 00 00 00    	js     802207 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80212c:	83 ec 04             	sub    $0x4,%esp
  80212f:	68 07 04 00 00       	push   $0x407
  802134:	ff 75 f0             	push   -0x10(%ebp)
  802137:	6a 00                	push   $0x0
  802139:	e8 a8 ec ff ff       	call   800de6 <sys_page_alloc>
  80213e:	89 c3                	mov    %eax,%ebx
  802140:	83 c4 10             	add    $0x10,%esp
  802143:	85 c0                	test   %eax,%eax
  802145:	0f 88 bc 00 00 00    	js     802207 <pipe+0x131>
	va = fd2data(fd0);
  80214b:	83 ec 0c             	sub    $0xc,%esp
  80214e:	ff 75 f4             	push   -0xc(%ebp)
  802151:	e8 73 f1 ff ff       	call   8012c9 <fd2data>
  802156:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802158:	83 c4 0c             	add    $0xc,%esp
  80215b:	68 07 04 00 00       	push   $0x407
  802160:	50                   	push   %eax
  802161:	6a 00                	push   $0x0
  802163:	e8 7e ec ff ff       	call   800de6 <sys_page_alloc>
  802168:	89 c3                	mov    %eax,%ebx
  80216a:	83 c4 10             	add    $0x10,%esp
  80216d:	85 c0                	test   %eax,%eax
  80216f:	0f 88 82 00 00 00    	js     8021f7 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802175:	83 ec 0c             	sub    $0xc,%esp
  802178:	ff 75 f0             	push   -0x10(%ebp)
  80217b:	e8 49 f1 ff ff       	call   8012c9 <fd2data>
  802180:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802187:	50                   	push   %eax
  802188:	6a 00                	push   $0x0
  80218a:	56                   	push   %esi
  80218b:	6a 00                	push   $0x0
  80218d:	e8 97 ec ff ff       	call   800e29 <sys_page_map>
  802192:	89 c3                	mov    %eax,%ebx
  802194:	83 c4 20             	add    $0x20,%esp
  802197:	85 c0                	test   %eax,%eax
  802199:	78 4e                	js     8021e9 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  80219b:	a1 40 30 80 00       	mov    0x803040,%eax
  8021a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021a3:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8021a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8021a8:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8021af:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021b2:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8021b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8021b7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8021be:	83 ec 0c             	sub    $0xc,%esp
  8021c1:	ff 75 f4             	push   -0xc(%ebp)
  8021c4:	e8 f0 f0 ff ff       	call   8012b9 <fd2num>
  8021c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021cc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8021ce:	83 c4 04             	add    $0x4,%esp
  8021d1:	ff 75 f0             	push   -0x10(%ebp)
  8021d4:	e8 e0 f0 ff ff       	call   8012b9 <fd2num>
  8021d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021dc:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8021df:	83 c4 10             	add    $0x10,%esp
  8021e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021e7:	eb 2e                	jmp    802217 <pipe+0x141>
	sys_page_unmap(0, va);
  8021e9:	83 ec 08             	sub    $0x8,%esp
  8021ec:	56                   	push   %esi
  8021ed:	6a 00                	push   $0x0
  8021ef:	e8 77 ec ff ff       	call   800e6b <sys_page_unmap>
  8021f4:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8021f7:	83 ec 08             	sub    $0x8,%esp
  8021fa:	ff 75 f0             	push   -0x10(%ebp)
  8021fd:	6a 00                	push   $0x0
  8021ff:	e8 67 ec ff ff       	call   800e6b <sys_page_unmap>
  802204:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802207:	83 ec 08             	sub    $0x8,%esp
  80220a:	ff 75 f4             	push   -0xc(%ebp)
  80220d:	6a 00                	push   $0x0
  80220f:	e8 57 ec ff ff       	call   800e6b <sys_page_unmap>
  802214:	83 c4 10             	add    $0x10,%esp
}
  802217:	89 d8                	mov    %ebx,%eax
  802219:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80221c:	5b                   	pop    %ebx
  80221d:	5e                   	pop    %esi
  80221e:	5d                   	pop    %ebp
  80221f:	c3                   	ret    

00802220 <pipeisclosed>:
{
  802220:	55                   	push   %ebp
  802221:	89 e5                	mov    %esp,%ebp
  802223:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802226:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802229:	50                   	push   %eax
  80222a:	ff 75 08             	push   0x8(%ebp)
  80222d:	e8 fe f0 ff ff       	call   801330 <fd_lookup>
  802232:	83 c4 10             	add    $0x10,%esp
  802235:	85 c0                	test   %eax,%eax
  802237:	78 18                	js     802251 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802239:	83 ec 0c             	sub    $0xc,%esp
  80223c:	ff 75 f4             	push   -0xc(%ebp)
  80223f:	e8 85 f0 ff ff       	call   8012c9 <fd2data>
  802244:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802246:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802249:	e8 33 fd ff ff       	call   801f81 <_pipeisclosed>
  80224e:	83 c4 10             	add    $0x10,%esp
}
  802251:	c9                   	leave  
  802252:	c3                   	ret    

00802253 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802253:	55                   	push   %ebp
  802254:	89 e5                	mov    %esp,%ebp
  802256:	56                   	push   %esi
  802257:	53                   	push   %ebx
  802258:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80225b:	85 f6                	test   %esi,%esi
  80225d:	74 16                	je     802275 <wait+0x22>
	e = &envs[ENVX(envid)];
  80225f:	89 f3                	mov    %esi,%ebx
  802261:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802267:	69 db 8c 00 00 00    	imul   $0x8c,%ebx,%ebx
  80226d:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802273:	eb 1b                	jmp    802290 <wait+0x3d>
	assert(envid != 0);
  802275:	68 d3 2e 80 00       	push   $0x802ed3
  80227a:	68 4f 2e 80 00       	push   $0x802e4f
  80227f:	6a 09                	push   $0x9
  802281:	68 de 2e 80 00       	push   $0x802ede
  802286:	e8 aa e0 ff ff       	call   800335 <_panic>
		sys_yield();
  80228b:	e8 37 eb ff ff       	call   800dc7 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802290:	8b 43 58             	mov    0x58(%ebx),%eax
  802293:	39 f0                	cmp    %esi,%eax
  802295:	75 07                	jne    80229e <wait+0x4b>
  802297:	8b 43 64             	mov    0x64(%ebx),%eax
  80229a:	85 c0                	test   %eax,%eax
  80229c:	75 ed                	jne    80228b <wait+0x38>
}
  80229e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022a1:	5b                   	pop    %ebx
  8022a2:	5e                   	pop    %esi
  8022a3:	5d                   	pop    %ebp
  8022a4:	c3                   	ret    

008022a5 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  8022a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8022aa:	c3                   	ret    

008022ab <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8022ab:	55                   	push   %ebp
  8022ac:	89 e5                	mov    %esp,%ebp
  8022ae:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8022b1:	68 e9 2e 80 00       	push   $0x802ee9
  8022b6:	ff 75 0c             	push   0xc(%ebp)
  8022b9:	e8 2c e7 ff ff       	call   8009ea <strcpy>
	return 0;
}
  8022be:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c3:	c9                   	leave  
  8022c4:	c3                   	ret    

008022c5 <devcons_write>:
{
  8022c5:	55                   	push   %ebp
  8022c6:	89 e5                	mov    %esp,%ebp
  8022c8:	57                   	push   %edi
  8022c9:	56                   	push   %esi
  8022ca:	53                   	push   %ebx
  8022cb:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8022d1:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8022d6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8022dc:	eb 2e                	jmp    80230c <devcons_write+0x47>
		m = n - tot;
  8022de:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022e1:	29 f3                	sub    %esi,%ebx
  8022e3:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8022e8:	39 c3                	cmp    %eax,%ebx
  8022ea:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8022ed:	83 ec 04             	sub    $0x4,%esp
  8022f0:	53                   	push   %ebx
  8022f1:	89 f0                	mov    %esi,%eax
  8022f3:	03 45 0c             	add    0xc(%ebp),%eax
  8022f6:	50                   	push   %eax
  8022f7:	57                   	push   %edi
  8022f8:	e8 83 e8 ff ff       	call   800b80 <memmove>
		sys_cputs(buf, m);
  8022fd:	83 c4 08             	add    $0x8,%esp
  802300:	53                   	push   %ebx
  802301:	57                   	push   %edi
  802302:	e8 23 ea ff ff       	call   800d2a <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802307:	01 de                	add    %ebx,%esi
  802309:	83 c4 10             	add    $0x10,%esp
  80230c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80230f:	72 cd                	jb     8022de <devcons_write+0x19>
}
  802311:	89 f0                	mov    %esi,%eax
  802313:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802316:	5b                   	pop    %ebx
  802317:	5e                   	pop    %esi
  802318:	5f                   	pop    %edi
  802319:	5d                   	pop    %ebp
  80231a:	c3                   	ret    

0080231b <devcons_read>:
{
  80231b:	55                   	push   %ebp
  80231c:	89 e5                	mov    %esp,%ebp
  80231e:	83 ec 08             	sub    $0x8,%esp
  802321:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802326:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80232a:	75 07                	jne    802333 <devcons_read+0x18>
  80232c:	eb 1f                	jmp    80234d <devcons_read+0x32>
		sys_yield();
  80232e:	e8 94 ea ff ff       	call   800dc7 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802333:	e8 10 ea ff ff       	call   800d48 <sys_cgetc>
  802338:	85 c0                	test   %eax,%eax
  80233a:	74 f2                	je     80232e <devcons_read+0x13>
	if (c < 0)
  80233c:	78 0f                	js     80234d <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  80233e:	83 f8 04             	cmp    $0x4,%eax
  802341:	74 0c                	je     80234f <devcons_read+0x34>
	*(char*)vbuf = c;
  802343:	8b 55 0c             	mov    0xc(%ebp),%edx
  802346:	88 02                	mov    %al,(%edx)
	return 1;
  802348:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80234d:	c9                   	leave  
  80234e:	c3                   	ret    
		return 0;
  80234f:	b8 00 00 00 00       	mov    $0x0,%eax
  802354:	eb f7                	jmp    80234d <devcons_read+0x32>

00802356 <cputchar>:
{
  802356:	55                   	push   %ebp
  802357:	89 e5                	mov    %esp,%ebp
  802359:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80235c:	8b 45 08             	mov    0x8(%ebp),%eax
  80235f:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802362:	6a 01                	push   $0x1
  802364:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802367:	50                   	push   %eax
  802368:	e8 bd e9 ff ff       	call   800d2a <sys_cputs>
}
  80236d:	83 c4 10             	add    $0x10,%esp
  802370:	c9                   	leave  
  802371:	c3                   	ret    

00802372 <getchar>:
{
  802372:	55                   	push   %ebp
  802373:	89 e5                	mov    %esp,%ebp
  802375:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802378:	6a 01                	push   $0x1
  80237a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80237d:	50                   	push   %eax
  80237e:	6a 00                	push   $0x0
  802380:	e8 14 f2 ff ff       	call   801599 <read>
	if (r < 0)
  802385:	83 c4 10             	add    $0x10,%esp
  802388:	85 c0                	test   %eax,%eax
  80238a:	78 06                	js     802392 <getchar+0x20>
	if (r < 1)
  80238c:	74 06                	je     802394 <getchar+0x22>
	return c;
  80238e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802392:	c9                   	leave  
  802393:	c3                   	ret    
		return -E_EOF;
  802394:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802399:	eb f7                	jmp    802392 <getchar+0x20>

0080239b <iscons>:
{
  80239b:	55                   	push   %ebp
  80239c:	89 e5                	mov    %esp,%ebp
  80239e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8023a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023a4:	50                   	push   %eax
  8023a5:	ff 75 08             	push   0x8(%ebp)
  8023a8:	e8 83 ef ff ff       	call   801330 <fd_lookup>
  8023ad:	83 c4 10             	add    $0x10,%esp
  8023b0:	85 c0                	test   %eax,%eax
  8023b2:	78 11                	js     8023c5 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8023b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023b7:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8023bd:	39 10                	cmp    %edx,(%eax)
  8023bf:	0f 94 c0             	sete   %al
  8023c2:	0f b6 c0             	movzbl %al,%eax
}
  8023c5:	c9                   	leave  
  8023c6:	c3                   	ret    

008023c7 <opencons>:
{
  8023c7:	55                   	push   %ebp
  8023c8:	89 e5                	mov    %esp,%ebp
  8023ca:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8023cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8023d0:	50                   	push   %eax
  8023d1:	e8 0a ef ff ff       	call   8012e0 <fd_alloc>
  8023d6:	83 c4 10             	add    $0x10,%esp
  8023d9:	85 c0                	test   %eax,%eax
  8023db:	78 3a                	js     802417 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8023dd:	83 ec 04             	sub    $0x4,%esp
  8023e0:	68 07 04 00 00       	push   $0x407
  8023e5:	ff 75 f4             	push   -0xc(%ebp)
  8023e8:	6a 00                	push   $0x0
  8023ea:	e8 f7 e9 ff ff       	call   800de6 <sys_page_alloc>
  8023ef:	83 c4 10             	add    $0x10,%esp
  8023f2:	85 c0                	test   %eax,%eax
  8023f4:	78 21                	js     802417 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8023f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023f9:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8023ff:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802401:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802404:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80240b:	83 ec 0c             	sub    $0xc,%esp
  80240e:	50                   	push   %eax
  80240f:	e8 a5 ee ff ff       	call   8012b9 <fd2num>
  802414:	83 c4 10             	add    $0x10,%esp
}
  802417:	c9                   	leave  
  802418:	c3                   	ret    

00802419 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802419:	55                   	push   %ebp
  80241a:	89 e5                	mov    %esp,%ebp
  80241c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  80241f:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  802426:	74 0a                	je     802432 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802428:	8b 45 08             	mov    0x8(%ebp),%eax
  80242b:	a3 04 80 80 00       	mov    %eax,0x808004
}
  802430:	c9                   	leave  
  802431:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  802432:	e8 71 e9 ff ff       	call   800da8 <sys_getenvid>
  802437:	83 ec 04             	sub    $0x4,%esp
  80243a:	68 07 0e 00 00       	push   $0xe07
  80243f:	68 00 f0 bf ee       	push   $0xeebff000
  802444:	50                   	push   %eax
  802445:	e8 9c e9 ff ff       	call   800de6 <sys_page_alloc>
		if (r < 0) {
  80244a:	83 c4 10             	add    $0x10,%esp
  80244d:	85 c0                	test   %eax,%eax
  80244f:	78 2c                	js     80247d <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802451:	e8 52 e9 ff ff       	call   800da8 <sys_getenvid>
  802456:	83 ec 08             	sub    $0x8,%esp
  802459:	68 8f 24 80 00       	push   $0x80248f
  80245e:	50                   	push   %eax
  80245f:	e8 cd ea ff ff       	call   800f31 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802464:	83 c4 10             	add    $0x10,%esp
  802467:	85 c0                	test   %eax,%eax
  802469:	79 bd                	jns    802428 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  80246b:	50                   	push   %eax
  80246c:	68 38 2f 80 00       	push   $0x802f38
  802471:	6a 28                	push   $0x28
  802473:	68 6e 2f 80 00       	push   $0x802f6e
  802478:	e8 b8 de ff ff       	call   800335 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  80247d:	50                   	push   %eax
  80247e:	68 f8 2e 80 00       	push   $0x802ef8
  802483:	6a 23                	push   $0x23
  802485:	68 6e 2f 80 00       	push   $0x802f6e
  80248a:	e8 a6 de ff ff       	call   800335 <_panic>

0080248f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80248f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802490:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  802495:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802497:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  80249a:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  80249e:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  8024a1:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  8024a5:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  8024a9:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  8024ab:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  8024ae:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  8024af:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  8024b2:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  8024b3:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  8024b4:	c3                   	ret    

008024b5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024b5:	55                   	push   %ebp
  8024b6:	89 e5                	mov    %esp,%ebp
  8024b8:	56                   	push   %esi
  8024b9:	53                   	push   %ebx
  8024ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8024bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8024c3:	85 c0                	test   %eax,%eax
  8024c5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8024ca:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8024cd:	83 ec 0c             	sub    $0xc,%esp
  8024d0:	50                   	push   %eax
  8024d1:	e8 c0 ea ff ff       	call   800f96 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8024d6:	83 c4 10             	add    $0x10,%esp
  8024d9:	85 f6                	test   %esi,%esi
  8024db:	74 17                	je     8024f4 <ipc_recv+0x3f>
  8024dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8024e2:	85 c0                	test   %eax,%eax
  8024e4:	78 0c                	js     8024f2 <ipc_recv+0x3d>
  8024e6:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8024ec:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  8024f2:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8024f4:	85 db                	test   %ebx,%ebx
  8024f6:	74 17                	je     80250f <ipc_recv+0x5a>
  8024f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8024fd:	85 c0                	test   %eax,%eax
  8024ff:	78 0c                	js     80250d <ipc_recv+0x58>
  802501:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802507:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  80250d:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  80250f:	85 c0                	test   %eax,%eax
  802511:	78 0b                	js     80251e <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  802513:	a1 00 40 80 00       	mov    0x804000,%eax
  802518:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  80251e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802521:	5b                   	pop    %ebx
  802522:	5e                   	pop    %esi
  802523:	5d                   	pop    %ebp
  802524:	c3                   	ret    

00802525 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802525:	55                   	push   %ebp
  802526:	89 e5                	mov    %esp,%ebp
  802528:	57                   	push   %edi
  802529:	56                   	push   %esi
  80252a:	53                   	push   %ebx
  80252b:	83 ec 0c             	sub    $0xc,%esp
  80252e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802531:	8b 75 0c             	mov    0xc(%ebp),%esi
  802534:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802537:	85 db                	test   %ebx,%ebx
  802539:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80253e:	0f 44 d8             	cmove  %eax,%ebx
  802541:	eb 05                	jmp    802548 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802543:	e8 7f e8 ff ff       	call   800dc7 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802548:	ff 75 14             	push   0x14(%ebp)
  80254b:	53                   	push   %ebx
  80254c:	56                   	push   %esi
  80254d:	57                   	push   %edi
  80254e:	e8 20 ea ff ff       	call   800f73 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802553:	83 c4 10             	add    $0x10,%esp
  802556:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802559:	74 e8                	je     802543 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80255b:	85 c0                	test   %eax,%eax
  80255d:	78 08                	js     802567 <ipc_send+0x42>
	}while (r<0);

}
  80255f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802562:	5b                   	pop    %ebx
  802563:	5e                   	pop    %esi
  802564:	5f                   	pop    %edi
  802565:	5d                   	pop    %ebp
  802566:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802567:	50                   	push   %eax
  802568:	68 7c 2f 80 00       	push   $0x802f7c
  80256d:	6a 3d                	push   $0x3d
  80256f:	68 90 2f 80 00       	push   $0x802f90
  802574:	e8 bc dd ff ff       	call   800335 <_panic>

00802579 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802579:	55                   	push   %ebp
  80257a:	89 e5                	mov    %esp,%ebp
  80257c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80257f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802584:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  80258a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802590:	8b 52 60             	mov    0x60(%edx),%edx
  802593:	39 ca                	cmp    %ecx,%edx
  802595:	74 11                	je     8025a8 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  802597:	83 c0 01             	add    $0x1,%eax
  80259a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80259f:	75 e3                	jne    802584 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8025a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8025a6:	eb 0e                	jmp    8025b6 <ipc_find_env+0x3d>
			return envs[i].env_id;
  8025a8:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8025ae:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025b3:	8b 40 58             	mov    0x58(%eax),%eax
}
  8025b6:	5d                   	pop    %ebp
  8025b7:	c3                   	ret    

008025b8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025b8:	55                   	push   %ebp
  8025b9:	89 e5                	mov    %esp,%ebp
  8025bb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025be:	89 c2                	mov    %eax,%edx
  8025c0:	c1 ea 16             	shr    $0x16,%edx
  8025c3:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8025ca:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8025cf:	f6 c1 01             	test   $0x1,%cl
  8025d2:	74 1c                	je     8025f0 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8025d4:	c1 e8 0c             	shr    $0xc,%eax
  8025d7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8025de:	a8 01                	test   $0x1,%al
  8025e0:	74 0e                	je     8025f0 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025e2:	c1 e8 0c             	shr    $0xc,%eax
  8025e5:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8025ec:	ef 
  8025ed:	0f b7 d2             	movzwl %dx,%edx
}
  8025f0:	89 d0                	mov    %edx,%eax
  8025f2:	5d                   	pop    %ebp
  8025f3:	c3                   	ret    
  8025f4:	66 90                	xchg   %ax,%ax
  8025f6:	66 90                	xchg   %ax,%ax
  8025f8:	66 90                	xchg   %ax,%ax
  8025fa:	66 90                	xchg   %ax,%ax
  8025fc:	66 90                	xchg   %ax,%ax
  8025fe:	66 90                	xchg   %ax,%ax

00802600 <__udivdi3>:
  802600:	f3 0f 1e fb          	endbr32 
  802604:	55                   	push   %ebp
  802605:	57                   	push   %edi
  802606:	56                   	push   %esi
  802607:	53                   	push   %ebx
  802608:	83 ec 1c             	sub    $0x1c,%esp
  80260b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80260f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802613:	8b 74 24 34          	mov    0x34(%esp),%esi
  802617:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80261b:	85 c0                	test   %eax,%eax
  80261d:	75 19                	jne    802638 <__udivdi3+0x38>
  80261f:	39 f3                	cmp    %esi,%ebx
  802621:	76 4d                	jbe    802670 <__udivdi3+0x70>
  802623:	31 ff                	xor    %edi,%edi
  802625:	89 e8                	mov    %ebp,%eax
  802627:	89 f2                	mov    %esi,%edx
  802629:	f7 f3                	div    %ebx
  80262b:	89 fa                	mov    %edi,%edx
  80262d:	83 c4 1c             	add    $0x1c,%esp
  802630:	5b                   	pop    %ebx
  802631:	5e                   	pop    %esi
  802632:	5f                   	pop    %edi
  802633:	5d                   	pop    %ebp
  802634:	c3                   	ret    
  802635:	8d 76 00             	lea    0x0(%esi),%esi
  802638:	39 f0                	cmp    %esi,%eax
  80263a:	76 14                	jbe    802650 <__udivdi3+0x50>
  80263c:	31 ff                	xor    %edi,%edi
  80263e:	31 c0                	xor    %eax,%eax
  802640:	89 fa                	mov    %edi,%edx
  802642:	83 c4 1c             	add    $0x1c,%esp
  802645:	5b                   	pop    %ebx
  802646:	5e                   	pop    %esi
  802647:	5f                   	pop    %edi
  802648:	5d                   	pop    %ebp
  802649:	c3                   	ret    
  80264a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802650:	0f bd f8             	bsr    %eax,%edi
  802653:	83 f7 1f             	xor    $0x1f,%edi
  802656:	75 48                	jne    8026a0 <__udivdi3+0xa0>
  802658:	39 f0                	cmp    %esi,%eax
  80265a:	72 06                	jb     802662 <__udivdi3+0x62>
  80265c:	31 c0                	xor    %eax,%eax
  80265e:	39 eb                	cmp    %ebp,%ebx
  802660:	77 de                	ja     802640 <__udivdi3+0x40>
  802662:	b8 01 00 00 00       	mov    $0x1,%eax
  802667:	eb d7                	jmp    802640 <__udivdi3+0x40>
  802669:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802670:	89 d9                	mov    %ebx,%ecx
  802672:	85 db                	test   %ebx,%ebx
  802674:	75 0b                	jne    802681 <__udivdi3+0x81>
  802676:	b8 01 00 00 00       	mov    $0x1,%eax
  80267b:	31 d2                	xor    %edx,%edx
  80267d:	f7 f3                	div    %ebx
  80267f:	89 c1                	mov    %eax,%ecx
  802681:	31 d2                	xor    %edx,%edx
  802683:	89 f0                	mov    %esi,%eax
  802685:	f7 f1                	div    %ecx
  802687:	89 c6                	mov    %eax,%esi
  802689:	89 e8                	mov    %ebp,%eax
  80268b:	89 f7                	mov    %esi,%edi
  80268d:	f7 f1                	div    %ecx
  80268f:	89 fa                	mov    %edi,%edx
  802691:	83 c4 1c             	add    $0x1c,%esp
  802694:	5b                   	pop    %ebx
  802695:	5e                   	pop    %esi
  802696:	5f                   	pop    %edi
  802697:	5d                   	pop    %ebp
  802698:	c3                   	ret    
  802699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026a0:	89 f9                	mov    %edi,%ecx
  8026a2:	ba 20 00 00 00       	mov    $0x20,%edx
  8026a7:	29 fa                	sub    %edi,%edx
  8026a9:	d3 e0                	shl    %cl,%eax
  8026ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8026af:	89 d1                	mov    %edx,%ecx
  8026b1:	89 d8                	mov    %ebx,%eax
  8026b3:	d3 e8                	shr    %cl,%eax
  8026b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8026b9:	09 c1                	or     %eax,%ecx
  8026bb:	89 f0                	mov    %esi,%eax
  8026bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026c1:	89 f9                	mov    %edi,%ecx
  8026c3:	d3 e3                	shl    %cl,%ebx
  8026c5:	89 d1                	mov    %edx,%ecx
  8026c7:	d3 e8                	shr    %cl,%eax
  8026c9:	89 f9                	mov    %edi,%ecx
  8026cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8026cf:	89 eb                	mov    %ebp,%ebx
  8026d1:	d3 e6                	shl    %cl,%esi
  8026d3:	89 d1                	mov    %edx,%ecx
  8026d5:	d3 eb                	shr    %cl,%ebx
  8026d7:	09 f3                	or     %esi,%ebx
  8026d9:	89 c6                	mov    %eax,%esi
  8026db:	89 f2                	mov    %esi,%edx
  8026dd:	89 d8                	mov    %ebx,%eax
  8026df:	f7 74 24 08          	divl   0x8(%esp)
  8026e3:	89 d6                	mov    %edx,%esi
  8026e5:	89 c3                	mov    %eax,%ebx
  8026e7:	f7 64 24 0c          	mull   0xc(%esp)
  8026eb:	39 d6                	cmp    %edx,%esi
  8026ed:	72 19                	jb     802708 <__udivdi3+0x108>
  8026ef:	89 f9                	mov    %edi,%ecx
  8026f1:	d3 e5                	shl    %cl,%ebp
  8026f3:	39 c5                	cmp    %eax,%ebp
  8026f5:	73 04                	jae    8026fb <__udivdi3+0xfb>
  8026f7:	39 d6                	cmp    %edx,%esi
  8026f9:	74 0d                	je     802708 <__udivdi3+0x108>
  8026fb:	89 d8                	mov    %ebx,%eax
  8026fd:	31 ff                	xor    %edi,%edi
  8026ff:	e9 3c ff ff ff       	jmp    802640 <__udivdi3+0x40>
  802704:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802708:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80270b:	31 ff                	xor    %edi,%edi
  80270d:	e9 2e ff ff ff       	jmp    802640 <__udivdi3+0x40>
  802712:	66 90                	xchg   %ax,%ax
  802714:	66 90                	xchg   %ax,%ax
  802716:	66 90                	xchg   %ax,%ax
  802718:	66 90                	xchg   %ax,%ax
  80271a:	66 90                	xchg   %ax,%ax
  80271c:	66 90                	xchg   %ax,%ax
  80271e:	66 90                	xchg   %ax,%ax

00802720 <__umoddi3>:
  802720:	f3 0f 1e fb          	endbr32 
  802724:	55                   	push   %ebp
  802725:	57                   	push   %edi
  802726:	56                   	push   %esi
  802727:	53                   	push   %ebx
  802728:	83 ec 1c             	sub    $0x1c,%esp
  80272b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80272f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802733:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802737:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80273b:	89 f0                	mov    %esi,%eax
  80273d:	89 da                	mov    %ebx,%edx
  80273f:	85 ff                	test   %edi,%edi
  802741:	75 15                	jne    802758 <__umoddi3+0x38>
  802743:	39 dd                	cmp    %ebx,%ebp
  802745:	76 39                	jbe    802780 <__umoddi3+0x60>
  802747:	f7 f5                	div    %ebp
  802749:	89 d0                	mov    %edx,%eax
  80274b:	31 d2                	xor    %edx,%edx
  80274d:	83 c4 1c             	add    $0x1c,%esp
  802750:	5b                   	pop    %ebx
  802751:	5e                   	pop    %esi
  802752:	5f                   	pop    %edi
  802753:	5d                   	pop    %ebp
  802754:	c3                   	ret    
  802755:	8d 76 00             	lea    0x0(%esi),%esi
  802758:	39 df                	cmp    %ebx,%edi
  80275a:	77 f1                	ja     80274d <__umoddi3+0x2d>
  80275c:	0f bd cf             	bsr    %edi,%ecx
  80275f:	83 f1 1f             	xor    $0x1f,%ecx
  802762:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802766:	75 40                	jne    8027a8 <__umoddi3+0x88>
  802768:	39 df                	cmp    %ebx,%edi
  80276a:	72 04                	jb     802770 <__umoddi3+0x50>
  80276c:	39 f5                	cmp    %esi,%ebp
  80276e:	77 dd                	ja     80274d <__umoddi3+0x2d>
  802770:	89 da                	mov    %ebx,%edx
  802772:	89 f0                	mov    %esi,%eax
  802774:	29 e8                	sub    %ebp,%eax
  802776:	19 fa                	sbb    %edi,%edx
  802778:	eb d3                	jmp    80274d <__umoddi3+0x2d>
  80277a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802780:	89 e9                	mov    %ebp,%ecx
  802782:	85 ed                	test   %ebp,%ebp
  802784:	75 0b                	jne    802791 <__umoddi3+0x71>
  802786:	b8 01 00 00 00       	mov    $0x1,%eax
  80278b:	31 d2                	xor    %edx,%edx
  80278d:	f7 f5                	div    %ebp
  80278f:	89 c1                	mov    %eax,%ecx
  802791:	89 d8                	mov    %ebx,%eax
  802793:	31 d2                	xor    %edx,%edx
  802795:	f7 f1                	div    %ecx
  802797:	89 f0                	mov    %esi,%eax
  802799:	f7 f1                	div    %ecx
  80279b:	89 d0                	mov    %edx,%eax
  80279d:	31 d2                	xor    %edx,%edx
  80279f:	eb ac                	jmp    80274d <__umoddi3+0x2d>
  8027a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027a8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8027ac:	ba 20 00 00 00       	mov    $0x20,%edx
  8027b1:	29 c2                	sub    %eax,%edx
  8027b3:	89 c1                	mov    %eax,%ecx
  8027b5:	89 e8                	mov    %ebp,%eax
  8027b7:	d3 e7                	shl    %cl,%edi
  8027b9:	89 d1                	mov    %edx,%ecx
  8027bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8027bf:	d3 e8                	shr    %cl,%eax
  8027c1:	89 c1                	mov    %eax,%ecx
  8027c3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8027c7:	09 f9                	or     %edi,%ecx
  8027c9:	89 df                	mov    %ebx,%edi
  8027cb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027cf:	89 c1                	mov    %eax,%ecx
  8027d1:	d3 e5                	shl    %cl,%ebp
  8027d3:	89 d1                	mov    %edx,%ecx
  8027d5:	d3 ef                	shr    %cl,%edi
  8027d7:	89 c1                	mov    %eax,%ecx
  8027d9:	89 f0                	mov    %esi,%eax
  8027db:	d3 e3                	shl    %cl,%ebx
  8027dd:	89 d1                	mov    %edx,%ecx
  8027df:	89 fa                	mov    %edi,%edx
  8027e1:	d3 e8                	shr    %cl,%eax
  8027e3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8027e8:	09 d8                	or     %ebx,%eax
  8027ea:	f7 74 24 08          	divl   0x8(%esp)
  8027ee:	89 d3                	mov    %edx,%ebx
  8027f0:	d3 e6                	shl    %cl,%esi
  8027f2:	f7 e5                	mul    %ebp
  8027f4:	89 c7                	mov    %eax,%edi
  8027f6:	89 d1                	mov    %edx,%ecx
  8027f8:	39 d3                	cmp    %edx,%ebx
  8027fa:	72 06                	jb     802802 <__umoddi3+0xe2>
  8027fc:	75 0e                	jne    80280c <__umoddi3+0xec>
  8027fe:	39 c6                	cmp    %eax,%esi
  802800:	73 0a                	jae    80280c <__umoddi3+0xec>
  802802:	29 e8                	sub    %ebp,%eax
  802804:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802808:	89 d1                	mov    %edx,%ecx
  80280a:	89 c7                	mov    %eax,%edi
  80280c:	89 f5                	mov    %esi,%ebp
  80280e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802812:	29 fd                	sub    %edi,%ebp
  802814:	19 cb                	sbb    %ecx,%ebx
  802816:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80281b:	89 d8                	mov    %ebx,%eax
  80281d:	d3 e0                	shl    %cl,%eax
  80281f:	89 f1                	mov    %esi,%ecx
  802821:	d3 ed                	shr    %cl,%ebp
  802823:	d3 eb                	shr    %cl,%ebx
  802825:	09 e8                	or     %ebp,%eax
  802827:	89 da                	mov    %ebx,%edx
  802829:	83 c4 1c             	add    $0x1c,%esp
  80282c:	5b                   	pop    %ebx
  80282d:	5e                   	pop    %esi
  80282e:	5f                   	pop    %edi
  80282f:	5d                   	pop    %ebp
  802830:	c3                   	ret    
