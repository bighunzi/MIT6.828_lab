
obj/user/primespipe.debug：     文件格式 elf32-i386


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
  80002c:	e8 03 02 00 00       	call   800234 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
  80003c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  80003f:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800042:	8d 7d d8             	lea    -0x28(%ebp),%edi
	if ((r = readn(fd, &p, 4)) != 4)
  800045:	83 ec 04             	sub    $0x4,%esp
  800048:	6a 04                	push   $0x4
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	e8 c5 14 00 00       	call   801516 <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	75 49                	jne    8000a2 <primeproc+0x6f>
	cprintf("%d\n", p);
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	ff 75 e0             	push   -0x20(%ebp)
  80005f:	68 c1 22 80 00       	push   $0x8022c1
  800064:	e8 06 03 00 00       	call   80036f <cprintf>
	if ((i=pipe(pfd)) < 0)
  800069:	89 3c 24             	mov    %edi,(%esp)
  80006c:	e8 f3 1a 00 00       	call   801b64 <pipe>
  800071:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	85 c0                	test   %eax,%eax
  800079:	78 47                	js     8000c2 <primeproc+0x8f>
		panic("pipe: %e", i);
	if ((id = fork()) < 0)
  80007b:	e8 b4 0f 00 00       	call   801034 <fork>
  800080:	85 c0                	test   %eax,%eax
  800082:	78 50                	js     8000d4 <primeproc+0xa1>
		panic("fork: %e", id);
	if (id == 0) {
  800084:	75 60                	jne    8000e6 <primeproc+0xb3>
		close(fd);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	53                   	push   %ebx
  80008a:	e8 c4 12 00 00       	call   801353 <close>
		close(pfd[1]);
  80008f:	83 c4 04             	add    $0x4,%esp
  800092:	ff 75 dc             	push   -0x24(%ebp)
  800095:	e8 b9 12 00 00       	call   801353 <close>
		fd = pfd[0];
  80009a:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	eb a3                	jmp    800045 <primeproc+0x12>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  8000a2:	83 ec 0c             	sub    $0xc,%esp
  8000a5:	85 c0                	test   %eax,%eax
  8000a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ac:	0f 4e d0             	cmovle %eax,%edx
  8000af:	52                   	push   %edx
  8000b0:	50                   	push   %eax
  8000b1:	68 80 22 80 00       	push   $0x802280
  8000b6:	6a 15                	push   $0x15
  8000b8:	68 af 22 80 00       	push   $0x8022af
  8000bd:	e8 d2 01 00 00       	call   800294 <_panic>
		panic("pipe: %e", i);
  8000c2:	50                   	push   %eax
  8000c3:	68 c5 22 80 00       	push   $0x8022c5
  8000c8:	6a 1b                	push   $0x1b
  8000ca:	68 af 22 80 00       	push   $0x8022af
  8000cf:	e8 c0 01 00 00       	call   800294 <_panic>
		panic("fork: %e", id);
  8000d4:	50                   	push   %eax
  8000d5:	68 38 27 80 00       	push   $0x802738
  8000da:	6a 1d                	push   $0x1d
  8000dc:	68 af 22 80 00       	push   $0x8022af
  8000e1:	e8 ae 01 00 00       	call   800294 <_panic>
	}

	close(pfd[0]);
  8000e6:	83 ec 0c             	sub    $0xc,%esp
  8000e9:	ff 75 d8             	push   -0x28(%ebp)
  8000ec:	e8 62 12 00 00       	call   801353 <close>
	wfd = pfd[1];
  8000f1:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f4:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000f7:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000fa:	83 ec 04             	sub    $0x4,%esp
  8000fd:	6a 04                	push   $0x4
  8000ff:	56                   	push   %esi
  800100:	53                   	push   %ebx
  800101:	e8 10 14 00 00       	call   801516 <readn>
  800106:	83 c4 10             	add    $0x10,%esp
  800109:	83 f8 04             	cmp    $0x4,%eax
  80010c:	75 42                	jne    800150 <primeproc+0x11d>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
		if (i%p)
  80010e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800111:	99                   	cltd   
  800112:	f7 7d e0             	idivl  -0x20(%ebp)
  800115:	85 d2                	test   %edx,%edx
  800117:	74 e1                	je     8000fa <primeproc+0xc7>
			if ((r=write(wfd, &i, 4)) != 4)
  800119:	83 ec 04             	sub    $0x4,%esp
  80011c:	6a 04                	push   $0x4
  80011e:	56                   	push   %esi
  80011f:	57                   	push   %edi
  800120:	e8 38 14 00 00       	call   80155d <write>
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	83 f8 04             	cmp    $0x4,%eax
  80012b:	74 cd                	je     8000fa <primeproc+0xc7>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  80012d:	83 ec 08             	sub    $0x8,%esp
  800130:	85 c0                	test   %eax,%eax
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	0f 4e d0             	cmovle %eax,%edx
  80013a:	52                   	push   %edx
  80013b:	50                   	push   %eax
  80013c:	ff 75 e0             	push   -0x20(%ebp)
  80013f:	68 ea 22 80 00       	push   $0x8022ea
  800144:	6a 2e                	push   $0x2e
  800146:	68 af 22 80 00       	push   $0x8022af
  80014b:	e8 44 01 00 00       	call   800294 <_panic>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800150:	83 ec 04             	sub    $0x4,%esp
  800153:	85 c0                	test   %eax,%eax
  800155:	ba 00 00 00 00       	mov    $0x0,%edx
  80015a:	0f 4e d0             	cmovle %eax,%edx
  80015d:	52                   	push   %edx
  80015e:	50                   	push   %eax
  80015f:	53                   	push   %ebx
  800160:	ff 75 e0             	push   -0x20(%ebp)
  800163:	68 ce 22 80 00       	push   $0x8022ce
  800168:	6a 2b                	push   $0x2b
  80016a:	68 af 22 80 00       	push   $0x8022af
  80016f:	e8 20 01 00 00       	call   800294 <_panic>

00800174 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	53                   	push   %ebx
  800178:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  80017b:	c7 05 00 30 80 00 04 	movl   $0x802304,0x803000
  800182:	23 80 00 

	if ((i=pipe(p)) < 0)
  800185:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800188:	50                   	push   %eax
  800189:	e8 d6 19 00 00       	call   801b64 <pipe>
  80018e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800191:	83 c4 10             	add    $0x10,%esp
  800194:	85 c0                	test   %eax,%eax
  800196:	78 21                	js     8001b9 <umain+0x45>
		panic("pipe: %e", i);

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  800198:	e8 97 0e 00 00       	call   801034 <fork>
  80019d:	85 c0                	test   %eax,%eax
  80019f:	78 2a                	js     8001cb <umain+0x57>
		panic("fork: %e", id);

	if (id == 0) {
  8001a1:	75 3a                	jne    8001dd <umain+0x69>
		close(p[1]);
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	ff 75 f0             	push   -0x10(%ebp)
  8001a9:	e8 a5 11 00 00       	call   801353 <close>
		primeproc(p[0]);
  8001ae:	83 c4 04             	add    $0x4,%esp
  8001b1:	ff 75 ec             	push   -0x14(%ebp)
  8001b4:	e8 7a fe ff ff       	call   800033 <primeproc>
		panic("pipe: %e", i);
  8001b9:	50                   	push   %eax
  8001ba:	68 c5 22 80 00       	push   $0x8022c5
  8001bf:	6a 3a                	push   $0x3a
  8001c1:	68 af 22 80 00       	push   $0x8022af
  8001c6:	e8 c9 00 00 00       	call   800294 <_panic>
		panic("fork: %e", id);
  8001cb:	50                   	push   %eax
  8001cc:	68 38 27 80 00       	push   $0x802738
  8001d1:	6a 3e                	push   $0x3e
  8001d3:	68 af 22 80 00       	push   $0x8022af
  8001d8:	e8 b7 00 00 00       	call   800294 <_panic>
	}

	close(p[0]);
  8001dd:	83 ec 0c             	sub    $0xc,%esp
  8001e0:	ff 75 ec             	push   -0x14(%ebp)
  8001e3:	e8 6b 11 00 00       	call   801353 <close>
  8001e8:	83 c4 10             	add    $0x10,%esp
  8001eb:	b8 02 00 00 00       	mov    $0x2,%eax

	// feed all the integers through
	for (i=2;; i++)
		if ((r=write(p[1], &i, 4)) != 4)
  8001f0:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001f3:	eb 06                	jmp    8001fb <umain+0x87>
	for (i=2;; i++)
  8001f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8001f8:	83 c0 01             	add    $0x1,%eax
  8001fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
  8001fe:	83 ec 04             	sub    $0x4,%esp
  800201:	6a 04                	push   $0x4
  800203:	53                   	push   %ebx
  800204:	ff 75 f0             	push   -0x10(%ebp)
  800207:	e8 51 13 00 00       	call   80155d <write>
  80020c:	83 c4 10             	add    $0x10,%esp
  80020f:	83 f8 04             	cmp    $0x4,%eax
  800212:	74 e1                	je     8001f5 <umain+0x81>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800214:	83 ec 0c             	sub    $0xc,%esp
  800217:	85 c0                	test   %eax,%eax
  800219:	ba 00 00 00 00       	mov    $0x0,%edx
  80021e:	0f 4e d0             	cmovle %eax,%edx
  800221:	52                   	push   %edx
  800222:	50                   	push   %eax
  800223:	68 0f 23 80 00       	push   $0x80230f
  800228:	6a 4a                	push   $0x4a
  80022a:	68 af 22 80 00       	push   $0x8022af
  80022f:	e8 60 00 00 00       	call   800294 <_panic>

00800234 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800234:	55                   	push   %ebp
  800235:	89 e5                	mov    %esp,%ebp
  800237:	56                   	push   %esi
  800238:	53                   	push   %ebx
  800239:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80023c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  80023f:	e8 c3 0a 00 00       	call   800d07 <sys_getenvid>
  800244:	25 ff 03 00 00       	and    $0x3ff,%eax
  800249:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80024c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800251:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800256:	85 db                	test   %ebx,%ebx
  800258:	7e 07                	jle    800261 <libmain+0x2d>
		binaryname = argv[0];
  80025a:	8b 06                	mov    (%esi),%eax
  80025c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800261:	83 ec 08             	sub    $0x8,%esp
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	e8 09 ff ff ff       	call   800174 <umain>

	// exit gracefully
	exit();
  80026b:	e8 0a 00 00 00       	call   80027a <exit>
}
  800270:	83 c4 10             	add    $0x10,%esp
  800273:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800276:	5b                   	pop    %ebx
  800277:	5e                   	pop    %esi
  800278:	5d                   	pop    %ebp
  800279:	c3                   	ret    

0080027a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80027a:	55                   	push   %ebp
  80027b:	89 e5                	mov    %esp,%ebp
  80027d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800280:	e8 fb 10 00 00       	call   801380 <close_all>
	sys_env_destroy(0);
  800285:	83 ec 0c             	sub    $0xc,%esp
  800288:	6a 00                	push   $0x0
  80028a:	e8 37 0a 00 00       	call   800cc6 <sys_env_destroy>
}
  80028f:	83 c4 10             	add    $0x10,%esp
  800292:	c9                   	leave  
  800293:	c3                   	ret    

00800294 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	56                   	push   %esi
  800298:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800299:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80029c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002a2:	e8 60 0a 00 00       	call   800d07 <sys_getenvid>
  8002a7:	83 ec 0c             	sub    $0xc,%esp
  8002aa:	ff 75 0c             	push   0xc(%ebp)
  8002ad:	ff 75 08             	push   0x8(%ebp)
  8002b0:	56                   	push   %esi
  8002b1:	50                   	push   %eax
  8002b2:	68 34 23 80 00       	push   $0x802334
  8002b7:	e8 b3 00 00 00       	call   80036f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002bc:	83 c4 18             	add    $0x18,%esp
  8002bf:	53                   	push   %ebx
  8002c0:	ff 75 10             	push   0x10(%ebp)
  8002c3:	e8 56 00 00 00       	call   80031e <vcprintf>
	cprintf("\n");
  8002c8:	c7 04 24 c3 22 80 00 	movl   $0x8022c3,(%esp)
  8002cf:	e8 9b 00 00 00       	call   80036f <cprintf>
  8002d4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002d7:	cc                   	int3   
  8002d8:	eb fd                	jmp    8002d7 <_panic+0x43>

008002da <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	53                   	push   %ebx
  8002de:	83 ec 04             	sub    $0x4,%esp
  8002e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e4:	8b 13                	mov    (%ebx),%edx
  8002e6:	8d 42 01             	lea    0x1(%edx),%eax
  8002e9:	89 03                	mov    %eax,(%ebx)
  8002eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ee:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002f7:	74 09                	je     800302 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002f9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800300:	c9                   	leave  
  800301:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800302:	83 ec 08             	sub    $0x8,%esp
  800305:	68 ff 00 00 00       	push   $0xff
  80030a:	8d 43 08             	lea    0x8(%ebx),%eax
  80030d:	50                   	push   %eax
  80030e:	e8 76 09 00 00       	call   800c89 <sys_cputs>
		b->idx = 0;
  800313:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800319:	83 c4 10             	add    $0x10,%esp
  80031c:	eb db                	jmp    8002f9 <putch+0x1f>

0080031e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80031e:	55                   	push   %ebp
  80031f:	89 e5                	mov    %esp,%ebp
  800321:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800327:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80032e:	00 00 00 
	b.cnt = 0;
  800331:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800338:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033b:	ff 75 0c             	push   0xc(%ebp)
  80033e:	ff 75 08             	push   0x8(%ebp)
  800341:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800347:	50                   	push   %eax
  800348:	68 da 02 80 00       	push   $0x8002da
  80034d:	e8 14 01 00 00       	call   800466 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800352:	83 c4 08             	add    $0x8,%esp
  800355:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80035b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800361:	50                   	push   %eax
  800362:	e8 22 09 00 00       	call   800c89 <sys_cputs>

	return b.cnt;
}
  800367:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036d:	c9                   	leave  
  80036e:	c3                   	ret    

0080036f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
  800372:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800375:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800378:	50                   	push   %eax
  800379:	ff 75 08             	push   0x8(%ebp)
  80037c:	e8 9d ff ff ff       	call   80031e <vcprintf>
	va_end(ap);

	return cnt;
}
  800381:	c9                   	leave  
  800382:	c3                   	ret    

00800383 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	57                   	push   %edi
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
  800389:	83 ec 1c             	sub    $0x1c,%esp
  80038c:	89 c7                	mov    %eax,%edi
  80038e:	89 d6                	mov    %edx,%esi
  800390:	8b 45 08             	mov    0x8(%ebp),%eax
  800393:	8b 55 0c             	mov    0xc(%ebp),%edx
  800396:	89 d1                	mov    %edx,%ecx
  800398:	89 c2                	mov    %eax,%edx
  80039a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80039d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003b0:	39 c2                	cmp    %eax,%edx
  8003b2:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8003b5:	72 3e                	jb     8003f5 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003b7:	83 ec 0c             	sub    $0xc,%esp
  8003ba:	ff 75 18             	push   0x18(%ebp)
  8003bd:	83 eb 01             	sub    $0x1,%ebx
  8003c0:	53                   	push   %ebx
  8003c1:	50                   	push   %eax
  8003c2:	83 ec 08             	sub    $0x8,%esp
  8003c5:	ff 75 e4             	push   -0x1c(%ebp)
  8003c8:	ff 75 e0             	push   -0x20(%ebp)
  8003cb:	ff 75 dc             	push   -0x24(%ebp)
  8003ce:	ff 75 d8             	push   -0x28(%ebp)
  8003d1:	e8 5a 1c 00 00       	call   802030 <__udivdi3>
  8003d6:	83 c4 18             	add    $0x18,%esp
  8003d9:	52                   	push   %edx
  8003da:	50                   	push   %eax
  8003db:	89 f2                	mov    %esi,%edx
  8003dd:	89 f8                	mov    %edi,%eax
  8003df:	e8 9f ff ff ff       	call   800383 <printnum>
  8003e4:	83 c4 20             	add    $0x20,%esp
  8003e7:	eb 13                	jmp    8003fc <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003e9:	83 ec 08             	sub    $0x8,%esp
  8003ec:	56                   	push   %esi
  8003ed:	ff 75 18             	push   0x18(%ebp)
  8003f0:	ff d7                	call   *%edi
  8003f2:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003f5:	83 eb 01             	sub    $0x1,%ebx
  8003f8:	85 db                	test   %ebx,%ebx
  8003fa:	7f ed                	jg     8003e9 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003fc:	83 ec 08             	sub    $0x8,%esp
  8003ff:	56                   	push   %esi
  800400:	83 ec 04             	sub    $0x4,%esp
  800403:	ff 75 e4             	push   -0x1c(%ebp)
  800406:	ff 75 e0             	push   -0x20(%ebp)
  800409:	ff 75 dc             	push   -0x24(%ebp)
  80040c:	ff 75 d8             	push   -0x28(%ebp)
  80040f:	e8 3c 1d 00 00       	call   802150 <__umoddi3>
  800414:	83 c4 14             	add    $0x14,%esp
  800417:	0f be 80 57 23 80 00 	movsbl 0x802357(%eax),%eax
  80041e:	50                   	push   %eax
  80041f:	ff d7                	call   *%edi
}
  800421:	83 c4 10             	add    $0x10,%esp
  800424:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800427:	5b                   	pop    %ebx
  800428:	5e                   	pop    %esi
  800429:	5f                   	pop    %edi
  80042a:	5d                   	pop    %ebp
  80042b:	c3                   	ret    

0080042c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800432:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800436:	8b 10                	mov    (%eax),%edx
  800438:	3b 50 04             	cmp    0x4(%eax),%edx
  80043b:	73 0a                	jae    800447 <sprintputch+0x1b>
		*b->buf++ = ch;
  80043d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800440:	89 08                	mov    %ecx,(%eax)
  800442:	8b 45 08             	mov    0x8(%ebp),%eax
  800445:	88 02                	mov    %al,(%edx)
}
  800447:	5d                   	pop    %ebp
  800448:	c3                   	ret    

00800449 <printfmt>:
{
  800449:	55                   	push   %ebp
  80044a:	89 e5                	mov    %esp,%ebp
  80044c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80044f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800452:	50                   	push   %eax
  800453:	ff 75 10             	push   0x10(%ebp)
  800456:	ff 75 0c             	push   0xc(%ebp)
  800459:	ff 75 08             	push   0x8(%ebp)
  80045c:	e8 05 00 00 00       	call   800466 <vprintfmt>
}
  800461:	83 c4 10             	add    $0x10,%esp
  800464:	c9                   	leave  
  800465:	c3                   	ret    

00800466 <vprintfmt>:
{
  800466:	55                   	push   %ebp
  800467:	89 e5                	mov    %esp,%ebp
  800469:	57                   	push   %edi
  80046a:	56                   	push   %esi
  80046b:	53                   	push   %ebx
  80046c:	83 ec 3c             	sub    $0x3c,%esp
  80046f:	8b 75 08             	mov    0x8(%ebp),%esi
  800472:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800475:	8b 7d 10             	mov    0x10(%ebp),%edi
  800478:	eb 0a                	jmp    800484 <vprintfmt+0x1e>
			putch(ch, putdat);
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	53                   	push   %ebx
  80047e:	50                   	push   %eax
  80047f:	ff d6                	call   *%esi
  800481:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800484:	83 c7 01             	add    $0x1,%edi
  800487:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80048b:	83 f8 25             	cmp    $0x25,%eax
  80048e:	74 0c                	je     80049c <vprintfmt+0x36>
			if (ch == '\0')
  800490:	85 c0                	test   %eax,%eax
  800492:	75 e6                	jne    80047a <vprintfmt+0x14>
}
  800494:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800497:	5b                   	pop    %ebx
  800498:	5e                   	pop    %esi
  800499:	5f                   	pop    %edi
  80049a:	5d                   	pop    %ebp
  80049b:	c3                   	ret    
		padc = ' ';
  80049c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8004a0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8004a7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8004ae:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004b5:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004ba:	8d 47 01             	lea    0x1(%edi),%eax
  8004bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004c0:	0f b6 17             	movzbl (%edi),%edx
  8004c3:	8d 42 dd             	lea    -0x23(%edx),%eax
  8004c6:	3c 55                	cmp    $0x55,%al
  8004c8:	0f 87 bb 03 00 00    	ja     800889 <vprintfmt+0x423>
  8004ce:	0f b6 c0             	movzbl %al,%eax
  8004d1:	ff 24 85 a0 24 80 00 	jmp    *0x8024a0(,%eax,4)
  8004d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8004db:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8004df:	eb d9                	jmp    8004ba <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8004e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e4:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8004e8:	eb d0                	jmp    8004ba <vprintfmt+0x54>
  8004ea:	0f b6 d2             	movzbl %dl,%edx
  8004ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8004f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8004f8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004fb:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8004ff:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800502:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800505:	83 f9 09             	cmp    $0x9,%ecx
  800508:	77 55                	ja     80055f <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80050a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80050d:	eb e9                	jmp    8004f8 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80050f:	8b 45 14             	mov    0x14(%ebp),%eax
  800512:	8b 00                	mov    (%eax),%eax
  800514:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800517:	8b 45 14             	mov    0x14(%ebp),%eax
  80051a:	8d 40 04             	lea    0x4(%eax),%eax
  80051d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800520:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800523:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800527:	79 91                	jns    8004ba <vprintfmt+0x54>
				width = precision, precision = -1;
  800529:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80052c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80052f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800536:	eb 82                	jmp    8004ba <vprintfmt+0x54>
  800538:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80053b:	85 d2                	test   %edx,%edx
  80053d:	b8 00 00 00 00       	mov    $0x0,%eax
  800542:	0f 49 c2             	cmovns %edx,%eax
  800545:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800548:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80054b:	e9 6a ff ff ff       	jmp    8004ba <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800550:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800553:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80055a:	e9 5b ff ff ff       	jmp    8004ba <vprintfmt+0x54>
  80055f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	eb bc                	jmp    800523 <vprintfmt+0xbd>
			lflag++;
  800567:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80056d:	e9 48 ff ff ff       	jmp    8004ba <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8d 78 04             	lea    0x4(%eax),%edi
  800578:	83 ec 08             	sub    $0x8,%esp
  80057b:	53                   	push   %ebx
  80057c:	ff 30                	push   (%eax)
  80057e:	ff d6                	call   *%esi
			break;
  800580:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800583:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800586:	e9 9d 02 00 00       	jmp    800828 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80058b:	8b 45 14             	mov    0x14(%ebp),%eax
  80058e:	8d 78 04             	lea    0x4(%eax),%edi
  800591:	8b 10                	mov    (%eax),%edx
  800593:	89 d0                	mov    %edx,%eax
  800595:	f7 d8                	neg    %eax
  800597:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80059a:	83 f8 0f             	cmp    $0xf,%eax
  80059d:	7f 23                	jg     8005c2 <vprintfmt+0x15c>
  80059f:	8b 14 85 00 26 80 00 	mov    0x802600(,%eax,4),%edx
  8005a6:	85 d2                	test   %edx,%edx
  8005a8:	74 18                	je     8005c2 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8005aa:	52                   	push   %edx
  8005ab:	68 fd 27 80 00       	push   $0x8027fd
  8005b0:	53                   	push   %ebx
  8005b1:	56                   	push   %esi
  8005b2:	e8 92 fe ff ff       	call   800449 <printfmt>
  8005b7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8005ba:	89 7d 14             	mov    %edi,0x14(%ebp)
  8005bd:	e9 66 02 00 00       	jmp    800828 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8005c2:	50                   	push   %eax
  8005c3:	68 6f 23 80 00       	push   $0x80236f
  8005c8:	53                   	push   %ebx
  8005c9:	56                   	push   %esi
  8005ca:	e8 7a fe ff ff       	call   800449 <printfmt>
  8005cf:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8005d2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8005d5:	e9 4e 02 00 00       	jmp    800828 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	83 c0 04             	add    $0x4,%eax
  8005e0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8005e8:	85 d2                	test   %edx,%edx
  8005ea:	b8 68 23 80 00       	mov    $0x802368,%eax
  8005ef:	0f 45 c2             	cmovne %edx,%eax
  8005f2:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005f5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f9:	7e 06                	jle    800601 <vprintfmt+0x19b>
  8005fb:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8005ff:	75 0d                	jne    80060e <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800601:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800604:	89 c7                	mov    %eax,%edi
  800606:	03 45 e0             	add    -0x20(%ebp),%eax
  800609:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060c:	eb 55                	jmp    800663 <vprintfmt+0x1fd>
  80060e:	83 ec 08             	sub    $0x8,%esp
  800611:	ff 75 d8             	push   -0x28(%ebp)
  800614:	ff 75 cc             	push   -0x34(%ebp)
  800617:	e8 0a 03 00 00       	call   800926 <strnlen>
  80061c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80061f:	29 c1                	sub    %eax,%ecx
  800621:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800624:	83 c4 10             	add    $0x10,%esp
  800627:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800629:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80062d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800630:	eb 0f                	jmp    800641 <vprintfmt+0x1db>
					putch(padc, putdat);
  800632:	83 ec 08             	sub    $0x8,%esp
  800635:	53                   	push   %ebx
  800636:	ff 75 e0             	push   -0x20(%ebp)
  800639:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80063b:	83 ef 01             	sub    $0x1,%edi
  80063e:	83 c4 10             	add    $0x10,%esp
  800641:	85 ff                	test   %edi,%edi
  800643:	7f ed                	jg     800632 <vprintfmt+0x1cc>
  800645:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800648:	85 d2                	test   %edx,%edx
  80064a:	b8 00 00 00 00       	mov    $0x0,%eax
  80064f:	0f 49 c2             	cmovns %edx,%eax
  800652:	29 c2                	sub    %eax,%edx
  800654:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800657:	eb a8                	jmp    800601 <vprintfmt+0x19b>
					putch(ch, putdat);
  800659:	83 ec 08             	sub    $0x8,%esp
  80065c:	53                   	push   %ebx
  80065d:	52                   	push   %edx
  80065e:	ff d6                	call   *%esi
  800660:	83 c4 10             	add    $0x10,%esp
  800663:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800666:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800668:	83 c7 01             	add    $0x1,%edi
  80066b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80066f:	0f be d0             	movsbl %al,%edx
  800672:	85 d2                	test   %edx,%edx
  800674:	74 4b                	je     8006c1 <vprintfmt+0x25b>
  800676:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80067a:	78 06                	js     800682 <vprintfmt+0x21c>
  80067c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800680:	78 1e                	js     8006a0 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800682:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800686:	74 d1                	je     800659 <vprintfmt+0x1f3>
  800688:	0f be c0             	movsbl %al,%eax
  80068b:	83 e8 20             	sub    $0x20,%eax
  80068e:	83 f8 5e             	cmp    $0x5e,%eax
  800691:	76 c6                	jbe    800659 <vprintfmt+0x1f3>
					putch('?', putdat);
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	6a 3f                	push   $0x3f
  800699:	ff d6                	call   *%esi
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	eb c3                	jmp    800663 <vprintfmt+0x1fd>
  8006a0:	89 cf                	mov    %ecx,%edi
  8006a2:	eb 0e                	jmp    8006b2 <vprintfmt+0x24c>
				putch(' ', putdat);
  8006a4:	83 ec 08             	sub    $0x8,%esp
  8006a7:	53                   	push   %ebx
  8006a8:	6a 20                	push   $0x20
  8006aa:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8006ac:	83 ef 01             	sub    $0x1,%edi
  8006af:	83 c4 10             	add    $0x10,%esp
  8006b2:	85 ff                	test   %edi,%edi
  8006b4:	7f ee                	jg     8006a4 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8006b6:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8006b9:	89 45 14             	mov    %eax,0x14(%ebp)
  8006bc:	e9 67 01 00 00       	jmp    800828 <vprintfmt+0x3c2>
  8006c1:	89 cf                	mov    %ecx,%edi
  8006c3:	eb ed                	jmp    8006b2 <vprintfmt+0x24c>
	if (lflag >= 2)
  8006c5:	83 f9 01             	cmp    $0x1,%ecx
  8006c8:	7f 1b                	jg     8006e5 <vprintfmt+0x27f>
	else if (lflag)
  8006ca:	85 c9                	test   %ecx,%ecx
  8006cc:	74 63                	je     800731 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8b 00                	mov    (%eax),%eax
  8006d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d6:	99                   	cltd   
  8006d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006da:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dd:	8d 40 04             	lea    0x4(%eax),%eax
  8006e0:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e3:	eb 17                	jmp    8006fc <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8006e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e8:	8b 50 04             	mov    0x4(%eax),%edx
  8006eb:	8b 00                	mov    (%eax),%eax
  8006ed:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f6:	8d 40 08             	lea    0x8(%eax),%eax
  8006f9:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006fc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006ff:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800702:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800707:	85 c9                	test   %ecx,%ecx
  800709:	0f 89 ff 00 00 00    	jns    80080e <vprintfmt+0x3a8>
				putch('-', putdat);
  80070f:	83 ec 08             	sub    $0x8,%esp
  800712:	53                   	push   %ebx
  800713:	6a 2d                	push   $0x2d
  800715:	ff d6                	call   *%esi
				num = -(long long) num;
  800717:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80071a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80071d:	f7 da                	neg    %edx
  80071f:	83 d1 00             	adc    $0x0,%ecx
  800722:	f7 d9                	neg    %ecx
  800724:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800727:	bf 0a 00 00 00       	mov    $0xa,%edi
  80072c:	e9 dd 00 00 00       	jmp    80080e <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800731:	8b 45 14             	mov    0x14(%ebp),%eax
  800734:	8b 00                	mov    (%eax),%eax
  800736:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800739:	99                   	cltd   
  80073a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80073d:	8b 45 14             	mov    0x14(%ebp),%eax
  800740:	8d 40 04             	lea    0x4(%eax),%eax
  800743:	89 45 14             	mov    %eax,0x14(%ebp)
  800746:	eb b4                	jmp    8006fc <vprintfmt+0x296>
	if (lflag >= 2)
  800748:	83 f9 01             	cmp    $0x1,%ecx
  80074b:	7f 1e                	jg     80076b <vprintfmt+0x305>
	else if (lflag)
  80074d:	85 c9                	test   %ecx,%ecx
  80074f:	74 32                	je     800783 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	8b 10                	mov    (%eax),%edx
  800756:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075b:	8d 40 04             	lea    0x4(%eax),%eax
  80075e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800761:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800766:	e9 a3 00 00 00       	jmp    80080e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80076b:	8b 45 14             	mov    0x14(%ebp),%eax
  80076e:	8b 10                	mov    (%eax),%edx
  800770:	8b 48 04             	mov    0x4(%eax),%ecx
  800773:	8d 40 08             	lea    0x8(%eax),%eax
  800776:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800779:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80077e:	e9 8b 00 00 00       	jmp    80080e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8b 10                	mov    (%eax),%edx
  800788:	b9 00 00 00 00       	mov    $0x0,%ecx
  80078d:	8d 40 04             	lea    0x4(%eax),%eax
  800790:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800793:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800798:	eb 74                	jmp    80080e <vprintfmt+0x3a8>
	if (lflag >= 2)
  80079a:	83 f9 01             	cmp    $0x1,%ecx
  80079d:	7f 1b                	jg     8007ba <vprintfmt+0x354>
	else if (lflag)
  80079f:	85 c9                	test   %ecx,%ecx
  8007a1:	74 2c                	je     8007cf <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8b 10                	mov    (%eax),%edx
  8007a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ad:	8d 40 04             	lea    0x4(%eax),%eax
  8007b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8007b3:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8007b8:	eb 54                	jmp    80080e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bd:	8b 10                	mov    (%eax),%edx
  8007bf:	8b 48 04             	mov    0x4(%eax),%ecx
  8007c2:	8d 40 08             	lea    0x8(%eax),%eax
  8007c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8007c8:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8007cd:	eb 3f                	jmp    80080e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8b 10                	mov    (%eax),%edx
  8007d4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d9:	8d 40 04             	lea    0x4(%eax),%eax
  8007dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8007df:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8007e4:	eb 28                	jmp    80080e <vprintfmt+0x3a8>
			putch('0', putdat);
  8007e6:	83 ec 08             	sub    $0x8,%esp
  8007e9:	53                   	push   %ebx
  8007ea:	6a 30                	push   $0x30
  8007ec:	ff d6                	call   *%esi
			putch('x', putdat);
  8007ee:	83 c4 08             	add    $0x8,%esp
  8007f1:	53                   	push   %ebx
  8007f2:	6a 78                	push   $0x78
  8007f4:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f9:	8b 10                	mov    (%eax),%edx
  8007fb:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800800:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800803:	8d 40 04             	lea    0x4(%eax),%eax
  800806:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800809:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80080e:	83 ec 0c             	sub    $0xc,%esp
  800811:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800815:	50                   	push   %eax
  800816:	ff 75 e0             	push   -0x20(%ebp)
  800819:	57                   	push   %edi
  80081a:	51                   	push   %ecx
  80081b:	52                   	push   %edx
  80081c:	89 da                	mov    %ebx,%edx
  80081e:	89 f0                	mov    %esi,%eax
  800820:	e8 5e fb ff ff       	call   800383 <printnum>
			break;
  800825:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800828:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80082b:	e9 54 fc ff ff       	jmp    800484 <vprintfmt+0x1e>
	if (lflag >= 2)
  800830:	83 f9 01             	cmp    $0x1,%ecx
  800833:	7f 1b                	jg     800850 <vprintfmt+0x3ea>
	else if (lflag)
  800835:	85 c9                	test   %ecx,%ecx
  800837:	74 2c                	je     800865 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800839:	8b 45 14             	mov    0x14(%ebp),%eax
  80083c:	8b 10                	mov    (%eax),%edx
  80083e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800843:	8d 40 04             	lea    0x4(%eax),%eax
  800846:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800849:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  80084e:	eb be                	jmp    80080e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800850:	8b 45 14             	mov    0x14(%ebp),%eax
  800853:	8b 10                	mov    (%eax),%edx
  800855:	8b 48 04             	mov    0x4(%eax),%ecx
  800858:	8d 40 08             	lea    0x8(%eax),%eax
  80085b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80085e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800863:	eb a9                	jmp    80080e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800865:	8b 45 14             	mov    0x14(%ebp),%eax
  800868:	8b 10                	mov    (%eax),%edx
  80086a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086f:	8d 40 04             	lea    0x4(%eax),%eax
  800872:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800875:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80087a:	eb 92                	jmp    80080e <vprintfmt+0x3a8>
			putch(ch, putdat);
  80087c:	83 ec 08             	sub    $0x8,%esp
  80087f:	53                   	push   %ebx
  800880:	6a 25                	push   $0x25
  800882:	ff d6                	call   *%esi
			break;
  800884:	83 c4 10             	add    $0x10,%esp
  800887:	eb 9f                	jmp    800828 <vprintfmt+0x3c2>
			putch('%', putdat);
  800889:	83 ec 08             	sub    $0x8,%esp
  80088c:	53                   	push   %ebx
  80088d:	6a 25                	push   $0x25
  80088f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800891:	83 c4 10             	add    $0x10,%esp
  800894:	89 f8                	mov    %edi,%eax
  800896:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80089a:	74 05                	je     8008a1 <vprintfmt+0x43b>
  80089c:	83 e8 01             	sub    $0x1,%eax
  80089f:	eb f5                	jmp    800896 <vprintfmt+0x430>
  8008a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008a4:	eb 82                	jmp    800828 <vprintfmt+0x3c2>

008008a6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	83 ec 18             	sub    $0x18,%esp
  8008ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008b2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008b5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008b9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008bc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008c3:	85 c0                	test   %eax,%eax
  8008c5:	74 26                	je     8008ed <vsnprintf+0x47>
  8008c7:	85 d2                	test   %edx,%edx
  8008c9:	7e 22                	jle    8008ed <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008cb:	ff 75 14             	push   0x14(%ebp)
  8008ce:	ff 75 10             	push   0x10(%ebp)
  8008d1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d4:	50                   	push   %eax
  8008d5:	68 2c 04 80 00       	push   $0x80042c
  8008da:	e8 87 fb ff ff       	call   800466 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008df:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008e2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e8:	83 c4 10             	add    $0x10,%esp
}
  8008eb:	c9                   	leave  
  8008ec:	c3                   	ret    
		return -E_INVAL;
  8008ed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008f2:	eb f7                	jmp    8008eb <vsnprintf+0x45>

008008f4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008fa:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008fd:	50                   	push   %eax
  8008fe:	ff 75 10             	push   0x10(%ebp)
  800901:	ff 75 0c             	push   0xc(%ebp)
  800904:	ff 75 08             	push   0x8(%ebp)
  800907:	e8 9a ff ff ff       	call   8008a6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80090c:	c9                   	leave  
  80090d:	c3                   	ret    

0080090e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800914:	b8 00 00 00 00       	mov    $0x0,%eax
  800919:	eb 03                	jmp    80091e <strlen+0x10>
		n++;
  80091b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80091e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800922:	75 f7                	jne    80091b <strlen+0xd>
	return n;
}
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80092f:	b8 00 00 00 00       	mov    $0x0,%eax
  800934:	eb 03                	jmp    800939 <strnlen+0x13>
		n++;
  800936:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800939:	39 d0                	cmp    %edx,%eax
  80093b:	74 08                	je     800945 <strnlen+0x1f>
  80093d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800941:	75 f3                	jne    800936 <strnlen+0x10>
  800943:	89 c2                	mov    %eax,%edx
	return n;
}
  800945:	89 d0                	mov    %edx,%eax
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	53                   	push   %ebx
  80094d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800950:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800953:	b8 00 00 00 00       	mov    $0x0,%eax
  800958:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80095c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80095f:	83 c0 01             	add    $0x1,%eax
  800962:	84 d2                	test   %dl,%dl
  800964:	75 f2                	jne    800958 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800966:	89 c8                	mov    %ecx,%eax
  800968:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80096b:	c9                   	leave  
  80096c:	c3                   	ret    

0080096d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	53                   	push   %ebx
  800971:	83 ec 10             	sub    $0x10,%esp
  800974:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800977:	53                   	push   %ebx
  800978:	e8 91 ff ff ff       	call   80090e <strlen>
  80097d:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800980:	ff 75 0c             	push   0xc(%ebp)
  800983:	01 d8                	add    %ebx,%eax
  800985:	50                   	push   %eax
  800986:	e8 be ff ff ff       	call   800949 <strcpy>
	return dst;
}
  80098b:	89 d8                	mov    %ebx,%eax
  80098d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800990:	c9                   	leave  
  800991:	c3                   	ret    

00800992 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	56                   	push   %esi
  800996:	53                   	push   %ebx
  800997:	8b 75 08             	mov    0x8(%ebp),%esi
  80099a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80099d:	89 f3                	mov    %esi,%ebx
  80099f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a2:	89 f0                	mov    %esi,%eax
  8009a4:	eb 0f                	jmp    8009b5 <strncpy+0x23>
		*dst++ = *src;
  8009a6:	83 c0 01             	add    $0x1,%eax
  8009a9:	0f b6 0a             	movzbl (%edx),%ecx
  8009ac:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009af:	80 f9 01             	cmp    $0x1,%cl
  8009b2:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8009b5:	39 d8                	cmp    %ebx,%eax
  8009b7:	75 ed                	jne    8009a6 <strncpy+0x14>
	}
	return ret;
}
  8009b9:	89 f0                	mov    %esi,%eax
  8009bb:	5b                   	pop    %ebx
  8009bc:	5e                   	pop    %esi
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	56                   	push   %esi
  8009c3:	53                   	push   %ebx
  8009c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8009c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ca:	8b 55 10             	mov    0x10(%ebp),%edx
  8009cd:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009cf:	85 d2                	test   %edx,%edx
  8009d1:	74 21                	je     8009f4 <strlcpy+0x35>
  8009d3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009d7:	89 f2                	mov    %esi,%edx
  8009d9:	eb 09                	jmp    8009e4 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009db:	83 c1 01             	add    $0x1,%ecx
  8009de:	83 c2 01             	add    $0x1,%edx
  8009e1:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8009e4:	39 c2                	cmp    %eax,%edx
  8009e6:	74 09                	je     8009f1 <strlcpy+0x32>
  8009e8:	0f b6 19             	movzbl (%ecx),%ebx
  8009eb:	84 db                	test   %bl,%bl
  8009ed:	75 ec                	jne    8009db <strlcpy+0x1c>
  8009ef:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009f1:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009f4:	29 f0                	sub    %esi,%eax
}
  8009f6:	5b                   	pop    %ebx
  8009f7:	5e                   	pop    %esi
  8009f8:	5d                   	pop    %ebp
  8009f9:	c3                   	ret    

008009fa <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a00:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a03:	eb 06                	jmp    800a0b <strcmp+0x11>
		p++, q++;
  800a05:	83 c1 01             	add    $0x1,%ecx
  800a08:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a0b:	0f b6 01             	movzbl (%ecx),%eax
  800a0e:	84 c0                	test   %al,%al
  800a10:	74 04                	je     800a16 <strcmp+0x1c>
  800a12:	3a 02                	cmp    (%edx),%al
  800a14:	74 ef                	je     800a05 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a16:	0f b6 c0             	movzbl %al,%eax
  800a19:	0f b6 12             	movzbl (%edx),%edx
  800a1c:	29 d0                	sub    %edx,%eax
}
  800a1e:	5d                   	pop    %ebp
  800a1f:	c3                   	ret    

00800a20 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	53                   	push   %ebx
  800a24:	8b 45 08             	mov    0x8(%ebp),%eax
  800a27:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2a:	89 c3                	mov    %eax,%ebx
  800a2c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a2f:	eb 06                	jmp    800a37 <strncmp+0x17>
		n--, p++, q++;
  800a31:	83 c0 01             	add    $0x1,%eax
  800a34:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a37:	39 d8                	cmp    %ebx,%eax
  800a39:	74 18                	je     800a53 <strncmp+0x33>
  800a3b:	0f b6 08             	movzbl (%eax),%ecx
  800a3e:	84 c9                	test   %cl,%cl
  800a40:	74 04                	je     800a46 <strncmp+0x26>
  800a42:	3a 0a                	cmp    (%edx),%cl
  800a44:	74 eb                	je     800a31 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a46:	0f b6 00             	movzbl (%eax),%eax
  800a49:	0f b6 12             	movzbl (%edx),%edx
  800a4c:	29 d0                	sub    %edx,%eax
}
  800a4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a51:	c9                   	leave  
  800a52:	c3                   	ret    
		return 0;
  800a53:	b8 00 00 00 00       	mov    $0x0,%eax
  800a58:	eb f4                	jmp    800a4e <strncmp+0x2e>

00800a5a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a60:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a64:	eb 03                	jmp    800a69 <strchr+0xf>
  800a66:	83 c0 01             	add    $0x1,%eax
  800a69:	0f b6 10             	movzbl (%eax),%edx
  800a6c:	84 d2                	test   %dl,%dl
  800a6e:	74 06                	je     800a76 <strchr+0x1c>
		if (*s == c)
  800a70:	38 ca                	cmp    %cl,%dl
  800a72:	75 f2                	jne    800a66 <strchr+0xc>
  800a74:	eb 05                	jmp    800a7b <strchr+0x21>
			return (char *) s;
	return 0;
  800a76:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a87:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a8a:	38 ca                	cmp    %cl,%dl
  800a8c:	74 09                	je     800a97 <strfind+0x1a>
  800a8e:	84 d2                	test   %dl,%dl
  800a90:	74 05                	je     800a97 <strfind+0x1a>
	for (; *s; s++)
  800a92:	83 c0 01             	add    $0x1,%eax
  800a95:	eb f0                	jmp    800a87 <strfind+0xa>
			break;
	return (char *) s;
}
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	57                   	push   %edi
  800a9d:	56                   	push   %esi
  800a9e:	53                   	push   %ebx
  800a9f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aa5:	85 c9                	test   %ecx,%ecx
  800aa7:	74 2f                	je     800ad8 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aa9:	89 f8                	mov    %edi,%eax
  800aab:	09 c8                	or     %ecx,%eax
  800aad:	a8 03                	test   $0x3,%al
  800aaf:	75 21                	jne    800ad2 <memset+0x39>
		c &= 0xFF;
  800ab1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ab5:	89 d0                	mov    %edx,%eax
  800ab7:	c1 e0 08             	shl    $0x8,%eax
  800aba:	89 d3                	mov    %edx,%ebx
  800abc:	c1 e3 18             	shl    $0x18,%ebx
  800abf:	89 d6                	mov    %edx,%esi
  800ac1:	c1 e6 10             	shl    $0x10,%esi
  800ac4:	09 f3                	or     %esi,%ebx
  800ac6:	09 da                	or     %ebx,%edx
  800ac8:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800aca:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800acd:	fc                   	cld    
  800ace:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad0:	eb 06                	jmp    800ad8 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ad2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad5:	fc                   	cld    
  800ad6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ad8:	89 f8                	mov    %edi,%eax
  800ada:	5b                   	pop    %ebx
  800adb:	5e                   	pop    %esi
  800adc:	5f                   	pop    %edi
  800add:	5d                   	pop    %ebp
  800ade:	c3                   	ret    

00800adf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	57                   	push   %edi
  800ae3:	56                   	push   %esi
  800ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae7:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aea:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aed:	39 c6                	cmp    %eax,%esi
  800aef:	73 32                	jae    800b23 <memmove+0x44>
  800af1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800af4:	39 c2                	cmp    %eax,%edx
  800af6:	76 2b                	jbe    800b23 <memmove+0x44>
		s += n;
		d += n;
  800af8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afb:	89 d6                	mov    %edx,%esi
  800afd:	09 fe                	or     %edi,%esi
  800aff:	09 ce                	or     %ecx,%esi
  800b01:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b07:	75 0e                	jne    800b17 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b09:	83 ef 04             	sub    $0x4,%edi
  800b0c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b0f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b12:	fd                   	std    
  800b13:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b15:	eb 09                	jmp    800b20 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b17:	83 ef 01             	sub    $0x1,%edi
  800b1a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b1d:	fd                   	std    
  800b1e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b20:	fc                   	cld    
  800b21:	eb 1a                	jmp    800b3d <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b23:	89 f2                	mov    %esi,%edx
  800b25:	09 c2                	or     %eax,%edx
  800b27:	09 ca                	or     %ecx,%edx
  800b29:	f6 c2 03             	test   $0x3,%dl
  800b2c:	75 0a                	jne    800b38 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b2e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b31:	89 c7                	mov    %eax,%edi
  800b33:	fc                   	cld    
  800b34:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b36:	eb 05                	jmp    800b3d <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800b38:	89 c7                	mov    %eax,%edi
  800b3a:	fc                   	cld    
  800b3b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b47:	ff 75 10             	push   0x10(%ebp)
  800b4a:	ff 75 0c             	push   0xc(%ebp)
  800b4d:	ff 75 08             	push   0x8(%ebp)
  800b50:	e8 8a ff ff ff       	call   800adf <memmove>
}
  800b55:	c9                   	leave  
  800b56:	c3                   	ret    

00800b57 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b57:	55                   	push   %ebp
  800b58:	89 e5                	mov    %esp,%ebp
  800b5a:	56                   	push   %esi
  800b5b:	53                   	push   %ebx
  800b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b62:	89 c6                	mov    %eax,%esi
  800b64:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b67:	eb 06                	jmp    800b6f <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b69:	83 c0 01             	add    $0x1,%eax
  800b6c:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800b6f:	39 f0                	cmp    %esi,%eax
  800b71:	74 14                	je     800b87 <memcmp+0x30>
		if (*s1 != *s2)
  800b73:	0f b6 08             	movzbl (%eax),%ecx
  800b76:	0f b6 1a             	movzbl (%edx),%ebx
  800b79:	38 d9                	cmp    %bl,%cl
  800b7b:	74 ec                	je     800b69 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b7d:	0f b6 c1             	movzbl %cl,%eax
  800b80:	0f b6 db             	movzbl %bl,%ebx
  800b83:	29 d8                	sub    %ebx,%eax
  800b85:	eb 05                	jmp    800b8c <memcmp+0x35>
	}

	return 0;
  800b87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b8c:	5b                   	pop    %ebx
  800b8d:	5e                   	pop    %esi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	8b 45 08             	mov    0x8(%ebp),%eax
  800b96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b99:	89 c2                	mov    %eax,%edx
  800b9b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b9e:	eb 03                	jmp    800ba3 <memfind+0x13>
  800ba0:	83 c0 01             	add    $0x1,%eax
  800ba3:	39 d0                	cmp    %edx,%eax
  800ba5:	73 04                	jae    800bab <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ba7:	38 08                	cmp    %cl,(%eax)
  800ba9:	75 f5                	jne    800ba0 <memfind+0x10>
			break;
	return (void *) s;
}
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	57                   	push   %edi
  800bb1:	56                   	push   %esi
  800bb2:	53                   	push   %ebx
  800bb3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb9:	eb 03                	jmp    800bbe <strtol+0x11>
		s++;
  800bbb:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800bbe:	0f b6 02             	movzbl (%edx),%eax
  800bc1:	3c 20                	cmp    $0x20,%al
  800bc3:	74 f6                	je     800bbb <strtol+0xe>
  800bc5:	3c 09                	cmp    $0x9,%al
  800bc7:	74 f2                	je     800bbb <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bc9:	3c 2b                	cmp    $0x2b,%al
  800bcb:	74 2a                	je     800bf7 <strtol+0x4a>
	int neg = 0;
  800bcd:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bd2:	3c 2d                	cmp    $0x2d,%al
  800bd4:	74 2b                	je     800c01 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bd6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bdc:	75 0f                	jne    800bed <strtol+0x40>
  800bde:	80 3a 30             	cmpb   $0x30,(%edx)
  800be1:	74 28                	je     800c0b <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800be3:	85 db                	test   %ebx,%ebx
  800be5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bea:	0f 44 d8             	cmove  %eax,%ebx
  800bed:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf2:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bf5:	eb 46                	jmp    800c3d <strtol+0x90>
		s++;
  800bf7:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800bfa:	bf 00 00 00 00       	mov    $0x0,%edi
  800bff:	eb d5                	jmp    800bd6 <strtol+0x29>
		s++, neg = 1;
  800c01:	83 c2 01             	add    $0x1,%edx
  800c04:	bf 01 00 00 00       	mov    $0x1,%edi
  800c09:	eb cb                	jmp    800bd6 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c0b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c0f:	74 0e                	je     800c1f <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800c11:	85 db                	test   %ebx,%ebx
  800c13:	75 d8                	jne    800bed <strtol+0x40>
		s++, base = 8;
  800c15:	83 c2 01             	add    $0x1,%edx
  800c18:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c1d:	eb ce                	jmp    800bed <strtol+0x40>
		s += 2, base = 16;
  800c1f:	83 c2 02             	add    $0x2,%edx
  800c22:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c27:	eb c4                	jmp    800bed <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c29:	0f be c0             	movsbl %al,%eax
  800c2c:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c2f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800c32:	7d 3a                	jge    800c6e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c34:	83 c2 01             	add    $0x1,%edx
  800c37:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800c3b:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800c3d:	0f b6 02             	movzbl (%edx),%eax
  800c40:	8d 70 d0             	lea    -0x30(%eax),%esi
  800c43:	89 f3                	mov    %esi,%ebx
  800c45:	80 fb 09             	cmp    $0x9,%bl
  800c48:	76 df                	jbe    800c29 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800c4a:	8d 70 9f             	lea    -0x61(%eax),%esi
  800c4d:	89 f3                	mov    %esi,%ebx
  800c4f:	80 fb 19             	cmp    $0x19,%bl
  800c52:	77 08                	ja     800c5c <strtol+0xaf>
			dig = *s - 'a' + 10;
  800c54:	0f be c0             	movsbl %al,%eax
  800c57:	83 e8 57             	sub    $0x57,%eax
  800c5a:	eb d3                	jmp    800c2f <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800c5c:	8d 70 bf             	lea    -0x41(%eax),%esi
  800c5f:	89 f3                	mov    %esi,%ebx
  800c61:	80 fb 19             	cmp    $0x19,%bl
  800c64:	77 08                	ja     800c6e <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c66:	0f be c0             	movsbl %al,%eax
  800c69:	83 e8 37             	sub    $0x37,%eax
  800c6c:	eb c1                	jmp    800c2f <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c6e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c72:	74 05                	je     800c79 <strtol+0xcc>
		*endptr = (char *) s;
  800c74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c77:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c79:	89 c8                	mov    %ecx,%eax
  800c7b:	f7 d8                	neg    %eax
  800c7d:	85 ff                	test   %edi,%edi
  800c7f:	0f 45 c8             	cmovne %eax,%ecx
}
  800c82:	89 c8                	mov    %ecx,%eax
  800c84:	5b                   	pop    %ebx
  800c85:	5e                   	pop    %esi
  800c86:	5f                   	pop    %edi
  800c87:	5d                   	pop    %ebp
  800c88:	c3                   	ret    

00800c89 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c89:	55                   	push   %ebp
  800c8a:	89 e5                	mov    %esp,%ebp
  800c8c:	57                   	push   %edi
  800c8d:	56                   	push   %esi
  800c8e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c94:	8b 55 08             	mov    0x8(%ebp),%edx
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	89 c3                	mov    %eax,%ebx
  800c9c:	89 c7                	mov    %eax,%edi
  800c9e:	89 c6                	mov    %eax,%esi
  800ca0:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ca2:	5b                   	pop    %ebx
  800ca3:	5e                   	pop    %esi
  800ca4:	5f                   	pop    %edi
  800ca5:	5d                   	pop    %ebp
  800ca6:	c3                   	ret    

00800ca7 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ca7:	55                   	push   %ebp
  800ca8:	89 e5                	mov    %esp,%ebp
  800caa:	57                   	push   %edi
  800cab:	56                   	push   %esi
  800cac:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cad:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb2:	b8 01 00 00 00       	mov    $0x1,%eax
  800cb7:	89 d1                	mov    %edx,%ecx
  800cb9:	89 d3                	mov    %edx,%ebx
  800cbb:	89 d7                	mov    %edx,%edi
  800cbd:	89 d6                	mov    %edx,%esi
  800cbf:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5f                   	pop    %edi
  800cc4:	5d                   	pop    %ebp
  800cc5:	c3                   	ret    

00800cc6 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ccf:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd7:	b8 03 00 00 00       	mov    $0x3,%eax
  800cdc:	89 cb                	mov    %ecx,%ebx
  800cde:	89 cf                	mov    %ecx,%edi
  800ce0:	89 ce                	mov    %ecx,%esi
  800ce2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	7f 08                	jg     800cf0 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ce8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf0:	83 ec 0c             	sub    $0xc,%esp
  800cf3:	50                   	push   %eax
  800cf4:	6a 03                	push   $0x3
  800cf6:	68 5f 26 80 00       	push   $0x80265f
  800cfb:	6a 2a                	push   $0x2a
  800cfd:	68 7c 26 80 00       	push   $0x80267c
  800d02:	e8 8d f5 ff ff       	call   800294 <_panic>

00800d07 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d12:	b8 02 00 00 00       	mov    $0x2,%eax
  800d17:	89 d1                	mov    %edx,%ecx
  800d19:	89 d3                	mov    %edx,%ebx
  800d1b:	89 d7                	mov    %edx,%edi
  800d1d:	89 d6                	mov    %edx,%esi
  800d1f:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d21:	5b                   	pop    %ebx
  800d22:	5e                   	pop    %esi
  800d23:	5f                   	pop    %edi
  800d24:	5d                   	pop    %ebp
  800d25:	c3                   	ret    

00800d26 <sys_yield>:

void
sys_yield(void)
{
  800d26:	55                   	push   %ebp
  800d27:	89 e5                	mov    %esp,%ebp
  800d29:	57                   	push   %edi
  800d2a:	56                   	push   %esi
  800d2b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800d31:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d36:	89 d1                	mov    %edx,%ecx
  800d38:	89 d3                	mov    %edx,%ebx
  800d3a:	89 d7                	mov    %edx,%edi
  800d3c:	89 d6                	mov    %edx,%esi
  800d3e:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
  800d4b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d4e:	be 00 00 00 00       	mov    $0x0,%esi
  800d53:	8b 55 08             	mov    0x8(%ebp),%edx
  800d56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d59:	b8 04 00 00 00       	mov    $0x4,%eax
  800d5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d61:	89 f7                	mov    %esi,%edi
  800d63:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d65:	85 c0                	test   %eax,%eax
  800d67:	7f 08                	jg     800d71 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6c:	5b                   	pop    %ebx
  800d6d:	5e                   	pop    %esi
  800d6e:	5f                   	pop    %edi
  800d6f:	5d                   	pop    %ebp
  800d70:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d71:	83 ec 0c             	sub    $0xc,%esp
  800d74:	50                   	push   %eax
  800d75:	6a 04                	push   $0x4
  800d77:	68 5f 26 80 00       	push   $0x80265f
  800d7c:	6a 2a                	push   $0x2a
  800d7e:	68 7c 26 80 00       	push   $0x80267c
  800d83:	e8 0c f5 ff ff       	call   800294 <_panic>

00800d88 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
  800d8b:	57                   	push   %edi
  800d8c:	56                   	push   %esi
  800d8d:	53                   	push   %ebx
  800d8e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d91:	8b 55 08             	mov    0x8(%ebp),%edx
  800d94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d97:	b8 05 00 00 00       	mov    $0x5,%eax
  800d9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d9f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da2:	8b 75 18             	mov    0x18(%ebp),%esi
  800da5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800da7:	85 c0                	test   %eax,%eax
  800da9:	7f 08                	jg     800db3 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dae:	5b                   	pop    %ebx
  800daf:	5e                   	pop    %esi
  800db0:	5f                   	pop    %edi
  800db1:	5d                   	pop    %ebp
  800db2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db3:	83 ec 0c             	sub    $0xc,%esp
  800db6:	50                   	push   %eax
  800db7:	6a 05                	push   $0x5
  800db9:	68 5f 26 80 00       	push   $0x80265f
  800dbe:	6a 2a                	push   $0x2a
  800dc0:	68 7c 26 80 00       	push   $0x80267c
  800dc5:	e8 ca f4 ff ff       	call   800294 <_panic>

00800dca <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	57                   	push   %edi
  800dce:	56                   	push   %esi
  800dcf:	53                   	push   %ebx
  800dd0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dde:	b8 06 00 00 00       	mov    $0x6,%eax
  800de3:	89 df                	mov    %ebx,%edi
  800de5:	89 de                	mov    %ebx,%esi
  800de7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800de9:	85 c0                	test   %eax,%eax
  800deb:	7f 08                	jg     800df5 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ded:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df0:	5b                   	pop    %ebx
  800df1:	5e                   	pop    %esi
  800df2:	5f                   	pop    %edi
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df5:	83 ec 0c             	sub    $0xc,%esp
  800df8:	50                   	push   %eax
  800df9:	6a 06                	push   $0x6
  800dfb:	68 5f 26 80 00       	push   $0x80265f
  800e00:	6a 2a                	push   $0x2a
  800e02:	68 7c 26 80 00       	push   $0x80267c
  800e07:	e8 88 f4 ff ff       	call   800294 <_panic>

00800e0c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e0c:	55                   	push   %ebp
  800e0d:	89 e5                	mov    %esp,%ebp
  800e0f:	57                   	push   %edi
  800e10:	56                   	push   %esi
  800e11:	53                   	push   %ebx
  800e12:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e20:	b8 08 00 00 00       	mov    $0x8,%eax
  800e25:	89 df                	mov    %ebx,%edi
  800e27:	89 de                	mov    %ebx,%esi
  800e29:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e2b:	85 c0                	test   %eax,%eax
  800e2d:	7f 08                	jg     800e37 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e32:	5b                   	pop    %ebx
  800e33:	5e                   	pop    %esi
  800e34:	5f                   	pop    %edi
  800e35:	5d                   	pop    %ebp
  800e36:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e37:	83 ec 0c             	sub    $0xc,%esp
  800e3a:	50                   	push   %eax
  800e3b:	6a 08                	push   $0x8
  800e3d:	68 5f 26 80 00       	push   $0x80265f
  800e42:	6a 2a                	push   $0x2a
  800e44:	68 7c 26 80 00       	push   $0x80267c
  800e49:	e8 46 f4 ff ff       	call   800294 <_panic>

00800e4e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e4e:	55                   	push   %ebp
  800e4f:	89 e5                	mov    %esp,%ebp
  800e51:	57                   	push   %edi
  800e52:	56                   	push   %esi
  800e53:	53                   	push   %ebx
  800e54:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e57:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e62:	b8 09 00 00 00       	mov    $0x9,%eax
  800e67:	89 df                	mov    %ebx,%edi
  800e69:	89 de                	mov    %ebx,%esi
  800e6b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e6d:	85 c0                	test   %eax,%eax
  800e6f:	7f 08                	jg     800e79 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5f                   	pop    %edi
  800e77:	5d                   	pop    %ebp
  800e78:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e79:	83 ec 0c             	sub    $0xc,%esp
  800e7c:	50                   	push   %eax
  800e7d:	6a 09                	push   $0x9
  800e7f:	68 5f 26 80 00       	push   $0x80265f
  800e84:	6a 2a                	push   $0x2a
  800e86:	68 7c 26 80 00       	push   $0x80267c
  800e8b:	e8 04 f4 ff ff       	call   800294 <_panic>

00800e90 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	57                   	push   %edi
  800e94:	56                   	push   %esi
  800e95:	53                   	push   %ebx
  800e96:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e99:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ea9:	89 df                	mov    %ebx,%edi
  800eab:	89 de                	mov    %ebx,%esi
  800ead:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eaf:	85 c0                	test   %eax,%eax
  800eb1:	7f 08                	jg     800ebb <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eb3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb6:	5b                   	pop    %ebx
  800eb7:	5e                   	pop    %esi
  800eb8:	5f                   	pop    %edi
  800eb9:	5d                   	pop    %ebp
  800eba:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebb:	83 ec 0c             	sub    $0xc,%esp
  800ebe:	50                   	push   %eax
  800ebf:	6a 0a                	push   $0xa
  800ec1:	68 5f 26 80 00       	push   $0x80265f
  800ec6:	6a 2a                	push   $0x2a
  800ec8:	68 7c 26 80 00       	push   $0x80267c
  800ecd:	e8 c2 f3 ff ff       	call   800294 <_panic>

00800ed2 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	57                   	push   %edi
  800ed6:	56                   	push   %esi
  800ed7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ed8:	8b 55 08             	mov    0x8(%ebp),%edx
  800edb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ede:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ee3:	be 00 00 00 00       	mov    $0x0,%esi
  800ee8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eeb:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eee:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	57                   	push   %edi
  800ef9:	56                   	push   %esi
  800efa:	53                   	push   %ebx
  800efb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800efe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f03:	8b 55 08             	mov    0x8(%ebp),%edx
  800f06:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f0b:	89 cb                	mov    %ecx,%ebx
  800f0d:	89 cf                	mov    %ecx,%edi
  800f0f:	89 ce                	mov    %ecx,%esi
  800f11:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f13:	85 c0                	test   %eax,%eax
  800f15:	7f 08                	jg     800f1f <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f1a:	5b                   	pop    %ebx
  800f1b:	5e                   	pop    %esi
  800f1c:	5f                   	pop    %edi
  800f1d:	5d                   	pop    %ebp
  800f1e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1f:	83 ec 0c             	sub    $0xc,%esp
  800f22:	50                   	push   %eax
  800f23:	6a 0d                	push   $0xd
  800f25:	68 5f 26 80 00       	push   $0x80265f
  800f2a:	6a 2a                	push   $0x2a
  800f2c:	68 7c 26 80 00       	push   $0x80267c
  800f31:	e8 5e f3 ff ff       	call   800294 <_panic>

00800f36 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	56                   	push   %esi
  800f3a:	53                   	push   %ebx
  800f3b:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f3e:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800f40:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f44:	0f 84 8e 00 00 00    	je     800fd8 <pgfault+0xa2>
  800f4a:	89 f0                	mov    %esi,%eax
  800f4c:	c1 e8 0c             	shr    $0xc,%eax
  800f4f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f56:	f6 c4 08             	test   $0x8,%ah
  800f59:	74 7d                	je     800fd8 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800f5b:	e8 a7 fd ff ff       	call   800d07 <sys_getenvid>
  800f60:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800f62:	83 ec 04             	sub    $0x4,%esp
  800f65:	6a 07                	push   $0x7
  800f67:	68 00 f0 7f 00       	push   $0x7ff000
  800f6c:	50                   	push   %eax
  800f6d:	e8 d3 fd ff ff       	call   800d45 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f72:	83 c4 10             	add    $0x10,%esp
  800f75:	85 c0                	test   %eax,%eax
  800f77:	78 73                	js     800fec <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800f79:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800f7f:	83 ec 04             	sub    $0x4,%esp
  800f82:	68 00 10 00 00       	push   $0x1000
  800f87:	56                   	push   %esi
  800f88:	68 00 f0 7f 00       	push   $0x7ff000
  800f8d:	e8 4d fb ff ff       	call   800adf <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800f92:	83 c4 08             	add    $0x8,%esp
  800f95:	56                   	push   %esi
  800f96:	53                   	push   %ebx
  800f97:	e8 2e fe ff ff       	call   800dca <sys_page_unmap>
  800f9c:	83 c4 10             	add    $0x10,%esp
  800f9f:	85 c0                	test   %eax,%eax
  800fa1:	78 5b                	js     800ffe <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800fa3:	83 ec 0c             	sub    $0xc,%esp
  800fa6:	6a 07                	push   $0x7
  800fa8:	56                   	push   %esi
  800fa9:	53                   	push   %ebx
  800faa:	68 00 f0 7f 00       	push   $0x7ff000
  800faf:	53                   	push   %ebx
  800fb0:	e8 d3 fd ff ff       	call   800d88 <sys_page_map>
  800fb5:	83 c4 20             	add    $0x20,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	78 54                	js     801010 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800fbc:	83 ec 08             	sub    $0x8,%esp
  800fbf:	68 00 f0 7f 00       	push   $0x7ff000
  800fc4:	53                   	push   %ebx
  800fc5:	e8 00 fe ff ff       	call   800dca <sys_page_unmap>
  800fca:	83 c4 10             	add    $0x10,%esp
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	78 51                	js     801022 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800fd1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fd4:	5b                   	pop    %ebx
  800fd5:	5e                   	pop    %esi
  800fd6:	5d                   	pop    %ebp
  800fd7:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800fd8:	83 ec 04             	sub    $0x4,%esp
  800fdb:	68 8c 26 80 00       	push   $0x80268c
  800fe0:	6a 1d                	push   $0x1d
  800fe2:	68 08 27 80 00       	push   $0x802708
  800fe7:	e8 a8 f2 ff ff       	call   800294 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800fec:	50                   	push   %eax
  800fed:	68 c4 26 80 00       	push   $0x8026c4
  800ff2:	6a 29                	push   $0x29
  800ff4:	68 08 27 80 00       	push   $0x802708
  800ff9:	e8 96 f2 ff ff       	call   800294 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800ffe:	50                   	push   %eax
  800fff:	68 e8 26 80 00       	push   $0x8026e8
  801004:	6a 2e                	push   $0x2e
  801006:	68 08 27 80 00       	push   $0x802708
  80100b:	e8 84 f2 ff ff       	call   800294 <_panic>
		panic("pgfault: page map failed (%e)", r);
  801010:	50                   	push   %eax
  801011:	68 13 27 80 00       	push   $0x802713
  801016:	6a 30                	push   $0x30
  801018:	68 08 27 80 00       	push   $0x802708
  80101d:	e8 72 f2 ff ff       	call   800294 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  801022:	50                   	push   %eax
  801023:	68 e8 26 80 00       	push   $0x8026e8
  801028:	6a 32                	push   $0x32
  80102a:	68 08 27 80 00       	push   $0x802708
  80102f:	e8 60 f2 ff ff       	call   800294 <_panic>

00801034 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	57                   	push   %edi
  801038:	56                   	push   %esi
  801039:	53                   	push   %ebx
  80103a:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  80103d:	68 36 0f 80 00       	push   $0x800f36
  801042:	e8 0e 0e 00 00       	call   801e55 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801047:	b8 07 00 00 00       	mov    $0x7,%eax
  80104c:	cd 30                	int    $0x30
  80104e:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  801051:	83 c4 10             	add    $0x10,%esp
  801054:	85 c0                	test   %eax,%eax
  801056:	78 2d                	js     801085 <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801058:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  80105d:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  801061:	75 73                	jne    8010d6 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  801063:	e8 9f fc ff ff       	call   800d07 <sys_getenvid>
  801068:	25 ff 03 00 00       	and    $0x3ff,%eax
  80106d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801070:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801075:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  80107a:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  80107d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801080:	5b                   	pop    %ebx
  801081:	5e                   	pop    %esi
  801082:	5f                   	pop    %edi
  801083:	5d                   	pop    %ebp
  801084:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  801085:	50                   	push   %eax
  801086:	68 31 27 80 00       	push   $0x802731
  80108b:	6a 78                	push   $0x78
  80108d:	68 08 27 80 00       	push   $0x802708
  801092:	e8 fd f1 ff ff       	call   800294 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  801097:	83 ec 0c             	sub    $0xc,%esp
  80109a:	ff 75 e4             	push   -0x1c(%ebp)
  80109d:	57                   	push   %edi
  80109e:	ff 75 dc             	push   -0x24(%ebp)
  8010a1:	57                   	push   %edi
  8010a2:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8010a5:	56                   	push   %esi
  8010a6:	e8 dd fc ff ff       	call   800d88 <sys_page_map>
	if(r<0) return r;
  8010ab:	83 c4 20             	add    $0x20,%esp
  8010ae:	85 c0                	test   %eax,%eax
  8010b0:	78 cb                	js     80107d <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  8010b2:	83 ec 0c             	sub    $0xc,%esp
  8010b5:	ff 75 e4             	push   -0x1c(%ebp)
  8010b8:	57                   	push   %edi
  8010b9:	56                   	push   %esi
  8010ba:	57                   	push   %edi
  8010bb:	56                   	push   %esi
  8010bc:	e8 c7 fc ff ff       	call   800d88 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  8010c1:	83 c4 20             	add    $0x20,%esp
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	78 76                	js     80113e <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  8010c8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8010ce:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  8010d4:	74 75                	je     80114b <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  8010d6:	89 d8                	mov    %ebx,%eax
  8010d8:	c1 e8 16             	shr    $0x16,%eax
  8010db:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8010e2:	a8 01                	test   $0x1,%al
  8010e4:	74 e2                	je     8010c8 <fork+0x94>
  8010e6:	89 de                	mov    %ebx,%esi
  8010e8:	c1 ee 0c             	shr    $0xc,%esi
  8010eb:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  8010f2:	a8 01                	test   $0x1,%al
  8010f4:	74 d2                	je     8010c8 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  8010f6:	e8 0c fc ff ff       	call   800d07 <sys_getenvid>
  8010fb:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  8010fe:	89 f7                	mov    %esi,%edi
  801100:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  801103:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80110a:	89 c1                	mov    %eax,%ecx
  80110c:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801112:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  801115:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  80111c:	f6 c6 04             	test   $0x4,%dh
  80111f:	0f 85 72 ff ff ff    	jne    801097 <fork+0x63>
		perm &= ~PTE_W;
  801125:	25 05 0e 00 00       	and    $0xe05,%eax
  80112a:	80 cc 08             	or     $0x8,%ah
  80112d:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  801133:	0f 44 c1             	cmove  %ecx,%eax
  801136:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801139:	e9 59 ff ff ff       	jmp    801097 <fork+0x63>
  80113e:	ba 00 00 00 00       	mov    $0x0,%edx
  801143:	0f 4f c2             	cmovg  %edx,%eax
  801146:	e9 32 ff ff ff       	jmp    80107d <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  80114b:	83 ec 04             	sub    $0x4,%esp
  80114e:	6a 07                	push   $0x7
  801150:	68 00 f0 bf ee       	push   $0xeebff000
  801155:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801158:	57                   	push   %edi
  801159:	e8 e7 fb ff ff       	call   800d45 <sys_page_alloc>
	if(r<0) return r;
  80115e:	83 c4 10             	add    $0x10,%esp
  801161:	85 c0                	test   %eax,%eax
  801163:	0f 88 14 ff ff ff    	js     80107d <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801169:	83 ec 08             	sub    $0x8,%esp
  80116c:	68 cb 1e 80 00       	push   $0x801ecb
  801171:	57                   	push   %edi
  801172:	e8 19 fd ff ff       	call   800e90 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801177:	83 c4 10             	add    $0x10,%esp
  80117a:	85 c0                	test   %eax,%eax
  80117c:	0f 88 fb fe ff ff    	js     80107d <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801182:	83 ec 08             	sub    $0x8,%esp
  801185:	6a 02                	push   $0x2
  801187:	57                   	push   %edi
  801188:	e8 7f fc ff ff       	call   800e0c <sys_env_set_status>
	if(r<0) return r;
  80118d:	83 c4 10             	add    $0x10,%esp
	return envid;
  801190:	85 c0                	test   %eax,%eax
  801192:	0f 49 c7             	cmovns %edi,%eax
  801195:	e9 e3 fe ff ff       	jmp    80107d <fork+0x49>

0080119a <sfork>:

// Challenge!
int
sfork(void)
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8011a0:	68 41 27 80 00       	push   $0x802741
  8011a5:	68 a1 00 00 00       	push   $0xa1
  8011aa:	68 08 27 80 00       	push   $0x802708
  8011af:	e8 e0 f0 ff ff       	call   800294 <_panic>

008011b4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011b4:	55                   	push   %ebp
  8011b5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ba:	05 00 00 00 30       	add    $0x30000000,%eax
  8011bf:	c1 e8 0c             	shr    $0xc,%eax
}
  8011c2:	5d                   	pop    %ebp
  8011c3:	c3                   	ret    

008011c4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011c4:	55                   	push   %ebp
  8011c5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ca:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011cf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011d4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011d9:	5d                   	pop    %ebp
  8011da:	c3                   	ret    

008011db <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011e3:	89 c2                	mov    %eax,%edx
  8011e5:	c1 ea 16             	shr    $0x16,%edx
  8011e8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ef:	f6 c2 01             	test   $0x1,%dl
  8011f2:	74 29                	je     80121d <fd_alloc+0x42>
  8011f4:	89 c2                	mov    %eax,%edx
  8011f6:	c1 ea 0c             	shr    $0xc,%edx
  8011f9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801200:	f6 c2 01             	test   $0x1,%dl
  801203:	74 18                	je     80121d <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801205:	05 00 10 00 00       	add    $0x1000,%eax
  80120a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80120f:	75 d2                	jne    8011e3 <fd_alloc+0x8>
  801211:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801216:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80121b:	eb 05                	jmp    801222 <fd_alloc+0x47>
			return 0;
  80121d:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801222:	8b 55 08             	mov    0x8(%ebp),%edx
  801225:	89 02                	mov    %eax,(%edx)
}
  801227:	89 c8                	mov    %ecx,%eax
  801229:	5d                   	pop    %ebp
  80122a:	c3                   	ret    

0080122b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801231:	83 f8 1f             	cmp    $0x1f,%eax
  801234:	77 30                	ja     801266 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801236:	c1 e0 0c             	shl    $0xc,%eax
  801239:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80123e:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801244:	f6 c2 01             	test   $0x1,%dl
  801247:	74 24                	je     80126d <fd_lookup+0x42>
  801249:	89 c2                	mov    %eax,%edx
  80124b:	c1 ea 0c             	shr    $0xc,%edx
  80124e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801255:	f6 c2 01             	test   $0x1,%dl
  801258:	74 1a                	je     801274 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80125a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125d:	89 02                	mov    %eax,(%edx)
	return 0;
  80125f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801264:	5d                   	pop    %ebp
  801265:	c3                   	ret    
		return -E_INVAL;
  801266:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126b:	eb f7                	jmp    801264 <fd_lookup+0x39>
		return -E_INVAL;
  80126d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801272:	eb f0                	jmp    801264 <fd_lookup+0x39>
  801274:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801279:	eb e9                	jmp    801264 <fd_lookup+0x39>

0080127b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	53                   	push   %ebx
  80127f:	83 ec 04             	sub    $0x4,%esp
  801282:	8b 55 08             	mov    0x8(%ebp),%edx
  801285:	b8 d4 27 80 00       	mov    $0x8027d4,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  80128a:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80128f:	39 13                	cmp    %edx,(%ebx)
  801291:	74 32                	je     8012c5 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  801293:	83 c0 04             	add    $0x4,%eax
  801296:	8b 18                	mov    (%eax),%ebx
  801298:	85 db                	test   %ebx,%ebx
  80129a:	75 f3                	jne    80128f <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80129c:	a1 00 40 80 00       	mov    0x804000,%eax
  8012a1:	8b 40 48             	mov    0x48(%eax),%eax
  8012a4:	83 ec 04             	sub    $0x4,%esp
  8012a7:	52                   	push   %edx
  8012a8:	50                   	push   %eax
  8012a9:	68 58 27 80 00       	push   $0x802758
  8012ae:	e8 bc f0 ff ff       	call   80036f <cprintf>
	*dev = 0;
	return -E_INVAL;
  8012b3:	83 c4 10             	add    $0x10,%esp
  8012b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8012bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012be:	89 1a                	mov    %ebx,(%edx)
}
  8012c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c3:	c9                   	leave  
  8012c4:	c3                   	ret    
			return 0;
  8012c5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ca:	eb ef                	jmp    8012bb <dev_lookup+0x40>

008012cc <fd_close>:
{
  8012cc:	55                   	push   %ebp
  8012cd:	89 e5                	mov    %esp,%ebp
  8012cf:	57                   	push   %edi
  8012d0:	56                   	push   %esi
  8012d1:	53                   	push   %ebx
  8012d2:	83 ec 24             	sub    $0x24,%esp
  8012d5:	8b 75 08             	mov    0x8(%ebp),%esi
  8012d8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012db:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012de:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012df:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012e5:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012e8:	50                   	push   %eax
  8012e9:	e8 3d ff ff ff       	call   80122b <fd_lookup>
  8012ee:	89 c3                	mov    %eax,%ebx
  8012f0:	83 c4 10             	add    $0x10,%esp
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	78 05                	js     8012fc <fd_close+0x30>
	    || fd != fd2)
  8012f7:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8012fa:	74 16                	je     801312 <fd_close+0x46>
		return (must_exist ? r : 0);
  8012fc:	89 f8                	mov    %edi,%eax
  8012fe:	84 c0                	test   %al,%al
  801300:	b8 00 00 00 00       	mov    $0x0,%eax
  801305:	0f 44 d8             	cmove  %eax,%ebx
}
  801308:	89 d8                	mov    %ebx,%eax
  80130a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80130d:	5b                   	pop    %ebx
  80130e:	5e                   	pop    %esi
  80130f:	5f                   	pop    %edi
  801310:	5d                   	pop    %ebp
  801311:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801312:	83 ec 08             	sub    $0x8,%esp
  801315:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801318:	50                   	push   %eax
  801319:	ff 36                	push   (%esi)
  80131b:	e8 5b ff ff ff       	call   80127b <dev_lookup>
  801320:	89 c3                	mov    %eax,%ebx
  801322:	83 c4 10             	add    $0x10,%esp
  801325:	85 c0                	test   %eax,%eax
  801327:	78 1a                	js     801343 <fd_close+0x77>
		if (dev->dev_close)
  801329:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80132c:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80132f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801334:	85 c0                	test   %eax,%eax
  801336:	74 0b                	je     801343 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801338:	83 ec 0c             	sub    $0xc,%esp
  80133b:	56                   	push   %esi
  80133c:	ff d0                	call   *%eax
  80133e:	89 c3                	mov    %eax,%ebx
  801340:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801343:	83 ec 08             	sub    $0x8,%esp
  801346:	56                   	push   %esi
  801347:	6a 00                	push   $0x0
  801349:	e8 7c fa ff ff       	call   800dca <sys_page_unmap>
	return r;
  80134e:	83 c4 10             	add    $0x10,%esp
  801351:	eb b5                	jmp    801308 <fd_close+0x3c>

00801353 <close>:

int
close(int fdnum)
{
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
  801356:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801359:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135c:	50                   	push   %eax
  80135d:	ff 75 08             	push   0x8(%ebp)
  801360:	e8 c6 fe ff ff       	call   80122b <fd_lookup>
  801365:	83 c4 10             	add    $0x10,%esp
  801368:	85 c0                	test   %eax,%eax
  80136a:	79 02                	jns    80136e <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80136c:	c9                   	leave  
  80136d:	c3                   	ret    
		return fd_close(fd, 1);
  80136e:	83 ec 08             	sub    $0x8,%esp
  801371:	6a 01                	push   $0x1
  801373:	ff 75 f4             	push   -0xc(%ebp)
  801376:	e8 51 ff ff ff       	call   8012cc <fd_close>
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	eb ec                	jmp    80136c <close+0x19>

00801380 <close_all>:

void
close_all(void)
{
  801380:	55                   	push   %ebp
  801381:	89 e5                	mov    %esp,%ebp
  801383:	53                   	push   %ebx
  801384:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801387:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80138c:	83 ec 0c             	sub    $0xc,%esp
  80138f:	53                   	push   %ebx
  801390:	e8 be ff ff ff       	call   801353 <close>
	for (i = 0; i < MAXFD; i++)
  801395:	83 c3 01             	add    $0x1,%ebx
  801398:	83 c4 10             	add    $0x10,%esp
  80139b:	83 fb 20             	cmp    $0x20,%ebx
  80139e:	75 ec                	jne    80138c <close_all+0xc>
}
  8013a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    

008013a5 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	57                   	push   %edi
  8013a9:	56                   	push   %esi
  8013aa:	53                   	push   %ebx
  8013ab:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013ae:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013b1:	50                   	push   %eax
  8013b2:	ff 75 08             	push   0x8(%ebp)
  8013b5:	e8 71 fe ff ff       	call   80122b <fd_lookup>
  8013ba:	89 c3                	mov    %eax,%ebx
  8013bc:	83 c4 10             	add    $0x10,%esp
  8013bf:	85 c0                	test   %eax,%eax
  8013c1:	78 7f                	js     801442 <dup+0x9d>
		return r;
	close(newfdnum);
  8013c3:	83 ec 0c             	sub    $0xc,%esp
  8013c6:	ff 75 0c             	push   0xc(%ebp)
  8013c9:	e8 85 ff ff ff       	call   801353 <close>

	newfd = INDEX2FD(newfdnum);
  8013ce:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013d1:	c1 e6 0c             	shl    $0xc,%esi
  8013d4:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013dd:	89 3c 24             	mov    %edi,(%esp)
  8013e0:	e8 df fd ff ff       	call   8011c4 <fd2data>
  8013e5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013e7:	89 34 24             	mov    %esi,(%esp)
  8013ea:	e8 d5 fd ff ff       	call   8011c4 <fd2data>
  8013ef:	83 c4 10             	add    $0x10,%esp
  8013f2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013f5:	89 d8                	mov    %ebx,%eax
  8013f7:	c1 e8 16             	shr    $0x16,%eax
  8013fa:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801401:	a8 01                	test   $0x1,%al
  801403:	74 11                	je     801416 <dup+0x71>
  801405:	89 d8                	mov    %ebx,%eax
  801407:	c1 e8 0c             	shr    $0xc,%eax
  80140a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801411:	f6 c2 01             	test   $0x1,%dl
  801414:	75 36                	jne    80144c <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801416:	89 f8                	mov    %edi,%eax
  801418:	c1 e8 0c             	shr    $0xc,%eax
  80141b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801422:	83 ec 0c             	sub    $0xc,%esp
  801425:	25 07 0e 00 00       	and    $0xe07,%eax
  80142a:	50                   	push   %eax
  80142b:	56                   	push   %esi
  80142c:	6a 00                	push   $0x0
  80142e:	57                   	push   %edi
  80142f:	6a 00                	push   $0x0
  801431:	e8 52 f9 ff ff       	call   800d88 <sys_page_map>
  801436:	89 c3                	mov    %eax,%ebx
  801438:	83 c4 20             	add    $0x20,%esp
  80143b:	85 c0                	test   %eax,%eax
  80143d:	78 33                	js     801472 <dup+0xcd>
		goto err;

	return newfdnum;
  80143f:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801442:	89 d8                	mov    %ebx,%eax
  801444:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801447:	5b                   	pop    %ebx
  801448:	5e                   	pop    %esi
  801449:	5f                   	pop    %edi
  80144a:	5d                   	pop    %ebp
  80144b:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80144c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801453:	83 ec 0c             	sub    $0xc,%esp
  801456:	25 07 0e 00 00       	and    $0xe07,%eax
  80145b:	50                   	push   %eax
  80145c:	ff 75 d4             	push   -0x2c(%ebp)
  80145f:	6a 00                	push   $0x0
  801461:	53                   	push   %ebx
  801462:	6a 00                	push   $0x0
  801464:	e8 1f f9 ff ff       	call   800d88 <sys_page_map>
  801469:	89 c3                	mov    %eax,%ebx
  80146b:	83 c4 20             	add    $0x20,%esp
  80146e:	85 c0                	test   %eax,%eax
  801470:	79 a4                	jns    801416 <dup+0x71>
	sys_page_unmap(0, newfd);
  801472:	83 ec 08             	sub    $0x8,%esp
  801475:	56                   	push   %esi
  801476:	6a 00                	push   $0x0
  801478:	e8 4d f9 ff ff       	call   800dca <sys_page_unmap>
	sys_page_unmap(0, nva);
  80147d:	83 c4 08             	add    $0x8,%esp
  801480:	ff 75 d4             	push   -0x2c(%ebp)
  801483:	6a 00                	push   $0x0
  801485:	e8 40 f9 ff ff       	call   800dca <sys_page_unmap>
	return r;
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	eb b3                	jmp    801442 <dup+0x9d>

0080148f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
  801492:	56                   	push   %esi
  801493:	53                   	push   %ebx
  801494:	83 ec 18             	sub    $0x18,%esp
  801497:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80149a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149d:	50                   	push   %eax
  80149e:	56                   	push   %esi
  80149f:	e8 87 fd ff ff       	call   80122b <fd_lookup>
  8014a4:	83 c4 10             	add    $0x10,%esp
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	78 3c                	js     8014e7 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014ab:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8014ae:	83 ec 08             	sub    $0x8,%esp
  8014b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b4:	50                   	push   %eax
  8014b5:	ff 33                	push   (%ebx)
  8014b7:	e8 bf fd ff ff       	call   80127b <dev_lookup>
  8014bc:	83 c4 10             	add    $0x10,%esp
  8014bf:	85 c0                	test   %eax,%eax
  8014c1:	78 24                	js     8014e7 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014c3:	8b 43 08             	mov    0x8(%ebx),%eax
  8014c6:	83 e0 03             	and    $0x3,%eax
  8014c9:	83 f8 01             	cmp    $0x1,%eax
  8014cc:	74 20                	je     8014ee <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d1:	8b 40 08             	mov    0x8(%eax),%eax
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	74 37                	je     80150f <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014d8:	83 ec 04             	sub    $0x4,%esp
  8014db:	ff 75 10             	push   0x10(%ebp)
  8014de:	ff 75 0c             	push   0xc(%ebp)
  8014e1:	53                   	push   %ebx
  8014e2:	ff d0                	call   *%eax
  8014e4:	83 c4 10             	add    $0x10,%esp
}
  8014e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ea:	5b                   	pop    %ebx
  8014eb:	5e                   	pop    %esi
  8014ec:	5d                   	pop    %ebp
  8014ed:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014ee:	a1 00 40 80 00       	mov    0x804000,%eax
  8014f3:	8b 40 48             	mov    0x48(%eax),%eax
  8014f6:	83 ec 04             	sub    $0x4,%esp
  8014f9:	56                   	push   %esi
  8014fa:	50                   	push   %eax
  8014fb:	68 99 27 80 00       	push   $0x802799
  801500:	e8 6a ee ff ff       	call   80036f <cprintf>
		return -E_INVAL;
  801505:	83 c4 10             	add    $0x10,%esp
  801508:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80150d:	eb d8                	jmp    8014e7 <read+0x58>
		return -E_NOT_SUPP;
  80150f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801514:	eb d1                	jmp    8014e7 <read+0x58>

00801516 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	57                   	push   %edi
  80151a:	56                   	push   %esi
  80151b:	53                   	push   %ebx
  80151c:	83 ec 0c             	sub    $0xc,%esp
  80151f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801522:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801525:	bb 00 00 00 00       	mov    $0x0,%ebx
  80152a:	eb 02                	jmp    80152e <readn+0x18>
  80152c:	01 c3                	add    %eax,%ebx
  80152e:	39 f3                	cmp    %esi,%ebx
  801530:	73 21                	jae    801553 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801532:	83 ec 04             	sub    $0x4,%esp
  801535:	89 f0                	mov    %esi,%eax
  801537:	29 d8                	sub    %ebx,%eax
  801539:	50                   	push   %eax
  80153a:	89 d8                	mov    %ebx,%eax
  80153c:	03 45 0c             	add    0xc(%ebp),%eax
  80153f:	50                   	push   %eax
  801540:	57                   	push   %edi
  801541:	e8 49 ff ff ff       	call   80148f <read>
		if (m < 0)
  801546:	83 c4 10             	add    $0x10,%esp
  801549:	85 c0                	test   %eax,%eax
  80154b:	78 04                	js     801551 <readn+0x3b>
			return m;
		if (m == 0)
  80154d:	75 dd                	jne    80152c <readn+0x16>
  80154f:	eb 02                	jmp    801553 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801551:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801553:	89 d8                	mov    %ebx,%eax
  801555:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801558:	5b                   	pop    %ebx
  801559:	5e                   	pop    %esi
  80155a:	5f                   	pop    %edi
  80155b:	5d                   	pop    %ebp
  80155c:	c3                   	ret    

0080155d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	56                   	push   %esi
  801561:	53                   	push   %ebx
  801562:	83 ec 18             	sub    $0x18,%esp
  801565:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801568:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156b:	50                   	push   %eax
  80156c:	53                   	push   %ebx
  80156d:	e8 b9 fc ff ff       	call   80122b <fd_lookup>
  801572:	83 c4 10             	add    $0x10,%esp
  801575:	85 c0                	test   %eax,%eax
  801577:	78 37                	js     8015b0 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801579:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80157c:	83 ec 08             	sub    $0x8,%esp
  80157f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801582:	50                   	push   %eax
  801583:	ff 36                	push   (%esi)
  801585:	e8 f1 fc ff ff       	call   80127b <dev_lookup>
  80158a:	83 c4 10             	add    $0x10,%esp
  80158d:	85 c0                	test   %eax,%eax
  80158f:	78 1f                	js     8015b0 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801591:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801595:	74 20                	je     8015b7 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801597:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80159a:	8b 40 0c             	mov    0xc(%eax),%eax
  80159d:	85 c0                	test   %eax,%eax
  80159f:	74 37                	je     8015d8 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8015a1:	83 ec 04             	sub    $0x4,%esp
  8015a4:	ff 75 10             	push   0x10(%ebp)
  8015a7:	ff 75 0c             	push   0xc(%ebp)
  8015aa:	56                   	push   %esi
  8015ab:	ff d0                	call   *%eax
  8015ad:	83 c4 10             	add    $0x10,%esp
}
  8015b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015b3:	5b                   	pop    %ebx
  8015b4:	5e                   	pop    %esi
  8015b5:	5d                   	pop    %ebp
  8015b6:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015b7:	a1 00 40 80 00       	mov    0x804000,%eax
  8015bc:	8b 40 48             	mov    0x48(%eax),%eax
  8015bf:	83 ec 04             	sub    $0x4,%esp
  8015c2:	53                   	push   %ebx
  8015c3:	50                   	push   %eax
  8015c4:	68 b5 27 80 00       	push   $0x8027b5
  8015c9:	e8 a1 ed ff ff       	call   80036f <cprintf>
		return -E_INVAL;
  8015ce:	83 c4 10             	add    $0x10,%esp
  8015d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015d6:	eb d8                	jmp    8015b0 <write+0x53>
		return -E_NOT_SUPP;
  8015d8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015dd:	eb d1                	jmp    8015b0 <write+0x53>

008015df <seek>:

int
seek(int fdnum, off_t offset)
{
  8015df:	55                   	push   %ebp
  8015e0:	89 e5                	mov    %esp,%ebp
  8015e2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e8:	50                   	push   %eax
  8015e9:	ff 75 08             	push   0x8(%ebp)
  8015ec:	e8 3a fc ff ff       	call   80122b <fd_lookup>
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	85 c0                	test   %eax,%eax
  8015f6:	78 0e                	js     801606 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015fe:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801601:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801606:	c9                   	leave  
  801607:	c3                   	ret    

00801608 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	56                   	push   %esi
  80160c:	53                   	push   %ebx
  80160d:	83 ec 18             	sub    $0x18,%esp
  801610:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801613:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801616:	50                   	push   %eax
  801617:	53                   	push   %ebx
  801618:	e8 0e fc ff ff       	call   80122b <fd_lookup>
  80161d:	83 c4 10             	add    $0x10,%esp
  801620:	85 c0                	test   %eax,%eax
  801622:	78 34                	js     801658 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801624:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162d:	50                   	push   %eax
  80162e:	ff 36                	push   (%esi)
  801630:	e8 46 fc ff ff       	call   80127b <dev_lookup>
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	85 c0                	test   %eax,%eax
  80163a:	78 1c                	js     801658 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80163c:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801640:	74 1d                	je     80165f <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801642:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801645:	8b 40 18             	mov    0x18(%eax),%eax
  801648:	85 c0                	test   %eax,%eax
  80164a:	74 34                	je     801680 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80164c:	83 ec 08             	sub    $0x8,%esp
  80164f:	ff 75 0c             	push   0xc(%ebp)
  801652:	56                   	push   %esi
  801653:	ff d0                	call   *%eax
  801655:	83 c4 10             	add    $0x10,%esp
}
  801658:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80165b:	5b                   	pop    %ebx
  80165c:	5e                   	pop    %esi
  80165d:	5d                   	pop    %ebp
  80165e:	c3                   	ret    
			thisenv->env_id, fdnum);
  80165f:	a1 00 40 80 00       	mov    0x804000,%eax
  801664:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801667:	83 ec 04             	sub    $0x4,%esp
  80166a:	53                   	push   %ebx
  80166b:	50                   	push   %eax
  80166c:	68 78 27 80 00       	push   $0x802778
  801671:	e8 f9 ec ff ff       	call   80036f <cprintf>
		return -E_INVAL;
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80167e:	eb d8                	jmp    801658 <ftruncate+0x50>
		return -E_NOT_SUPP;
  801680:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801685:	eb d1                	jmp    801658 <ftruncate+0x50>

00801687 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	56                   	push   %esi
  80168b:	53                   	push   %ebx
  80168c:	83 ec 18             	sub    $0x18,%esp
  80168f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801692:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801695:	50                   	push   %eax
  801696:	ff 75 08             	push   0x8(%ebp)
  801699:	e8 8d fb ff ff       	call   80122b <fd_lookup>
  80169e:	83 c4 10             	add    $0x10,%esp
  8016a1:	85 c0                	test   %eax,%eax
  8016a3:	78 49                	js     8016ee <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016a5:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8016a8:	83 ec 08             	sub    $0x8,%esp
  8016ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016ae:	50                   	push   %eax
  8016af:	ff 36                	push   (%esi)
  8016b1:	e8 c5 fb ff ff       	call   80127b <dev_lookup>
  8016b6:	83 c4 10             	add    $0x10,%esp
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	78 31                	js     8016ee <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8016bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016c0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016c4:	74 2f                	je     8016f5 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016c6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016c9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016d0:	00 00 00 
	stat->st_isdir = 0;
  8016d3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016da:	00 00 00 
	stat->st_dev = dev;
  8016dd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016e3:	83 ec 08             	sub    $0x8,%esp
  8016e6:	53                   	push   %ebx
  8016e7:	56                   	push   %esi
  8016e8:	ff 50 14             	call   *0x14(%eax)
  8016eb:	83 c4 10             	add    $0x10,%esp
}
  8016ee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016f1:	5b                   	pop    %ebx
  8016f2:	5e                   	pop    %esi
  8016f3:	5d                   	pop    %ebp
  8016f4:	c3                   	ret    
		return -E_NOT_SUPP;
  8016f5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016fa:	eb f2                	jmp    8016ee <fstat+0x67>

008016fc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	56                   	push   %esi
  801700:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801701:	83 ec 08             	sub    $0x8,%esp
  801704:	6a 00                	push   $0x0
  801706:	ff 75 08             	push   0x8(%ebp)
  801709:	e8 e4 01 00 00       	call   8018f2 <open>
  80170e:	89 c3                	mov    %eax,%ebx
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	85 c0                	test   %eax,%eax
  801715:	78 1b                	js     801732 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801717:	83 ec 08             	sub    $0x8,%esp
  80171a:	ff 75 0c             	push   0xc(%ebp)
  80171d:	50                   	push   %eax
  80171e:	e8 64 ff ff ff       	call   801687 <fstat>
  801723:	89 c6                	mov    %eax,%esi
	close(fd);
  801725:	89 1c 24             	mov    %ebx,(%esp)
  801728:	e8 26 fc ff ff       	call   801353 <close>
	return r;
  80172d:	83 c4 10             	add    $0x10,%esp
  801730:	89 f3                	mov    %esi,%ebx
}
  801732:	89 d8                	mov    %ebx,%eax
  801734:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801737:	5b                   	pop    %ebx
  801738:	5e                   	pop    %esi
  801739:	5d                   	pop    %ebp
  80173a:	c3                   	ret    

0080173b <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	56                   	push   %esi
  80173f:	53                   	push   %ebx
  801740:	89 c6                	mov    %eax,%esi
  801742:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801744:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80174b:	74 27                	je     801774 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80174d:	6a 07                	push   $0x7
  80174f:	68 00 50 80 00       	push   $0x805000
  801754:	56                   	push   %esi
  801755:	ff 35 00 60 80 00    	push   0x806000
  80175b:	e8 f8 07 00 00       	call   801f58 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801760:	83 c4 0c             	add    $0xc,%esp
  801763:	6a 00                	push   $0x0
  801765:	53                   	push   %ebx
  801766:	6a 00                	push   $0x0
  801768:	e8 84 07 00 00       	call   801ef1 <ipc_recv>
}
  80176d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801770:	5b                   	pop    %ebx
  801771:	5e                   	pop    %esi
  801772:	5d                   	pop    %ebp
  801773:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801774:	83 ec 0c             	sub    $0xc,%esp
  801777:	6a 01                	push   $0x1
  801779:	e8 2e 08 00 00       	call   801fac <ipc_find_env>
  80177e:	a3 00 60 80 00       	mov    %eax,0x806000
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	eb c5                	jmp    80174d <fsipc+0x12>

00801788 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80178e:	8b 45 08             	mov    0x8(%ebp),%eax
  801791:	8b 40 0c             	mov    0xc(%eax),%eax
  801794:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801799:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017a6:	b8 02 00 00 00       	mov    $0x2,%eax
  8017ab:	e8 8b ff ff ff       	call   80173b <fsipc>
}
  8017b0:	c9                   	leave  
  8017b1:	c3                   	ret    

008017b2 <devfile_flush>:
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017be:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c8:	b8 06 00 00 00       	mov    $0x6,%eax
  8017cd:	e8 69 ff ff ff       	call   80173b <fsipc>
}
  8017d2:	c9                   	leave  
  8017d3:	c3                   	ret    

008017d4 <devfile_stat>:
{
  8017d4:	55                   	push   %ebp
  8017d5:	89 e5                	mov    %esp,%ebp
  8017d7:	53                   	push   %ebx
  8017d8:	83 ec 04             	sub    $0x4,%esp
  8017db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017de:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8017e4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8017f3:	e8 43 ff ff ff       	call   80173b <fsipc>
  8017f8:	85 c0                	test   %eax,%eax
  8017fa:	78 2c                	js     801828 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017fc:	83 ec 08             	sub    $0x8,%esp
  8017ff:	68 00 50 80 00       	push   $0x805000
  801804:	53                   	push   %ebx
  801805:	e8 3f f1 ff ff       	call   800949 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80180a:	a1 80 50 80 00       	mov    0x805080,%eax
  80180f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801815:	a1 84 50 80 00       	mov    0x805084,%eax
  80181a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801820:	83 c4 10             	add    $0x10,%esp
  801823:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801828:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80182b:	c9                   	leave  
  80182c:	c3                   	ret    

0080182d <devfile_write>:
{
  80182d:	55                   	push   %ebp
  80182e:	89 e5                	mov    %esp,%ebp
  801830:	83 ec 0c             	sub    $0xc,%esp
  801833:	8b 45 10             	mov    0x10(%ebp),%eax
  801836:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80183b:	39 d0                	cmp    %edx,%eax
  80183d:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801840:	8b 55 08             	mov    0x8(%ebp),%edx
  801843:	8b 52 0c             	mov    0xc(%edx),%edx
  801846:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80184c:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801851:	50                   	push   %eax
  801852:	ff 75 0c             	push   0xc(%ebp)
  801855:	68 08 50 80 00       	push   $0x805008
  80185a:	e8 80 f2 ff ff       	call   800adf <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80185f:	ba 00 00 00 00       	mov    $0x0,%edx
  801864:	b8 04 00 00 00       	mov    $0x4,%eax
  801869:	e8 cd fe ff ff       	call   80173b <fsipc>
}
  80186e:	c9                   	leave  
  80186f:	c3                   	ret    

00801870 <devfile_read>:
{
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	56                   	push   %esi
  801874:	53                   	push   %ebx
  801875:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801878:	8b 45 08             	mov    0x8(%ebp),%eax
  80187b:	8b 40 0c             	mov    0xc(%eax),%eax
  80187e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801883:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801889:	ba 00 00 00 00       	mov    $0x0,%edx
  80188e:	b8 03 00 00 00       	mov    $0x3,%eax
  801893:	e8 a3 fe ff ff       	call   80173b <fsipc>
  801898:	89 c3                	mov    %eax,%ebx
  80189a:	85 c0                	test   %eax,%eax
  80189c:	78 1f                	js     8018bd <devfile_read+0x4d>
	assert(r <= n);
  80189e:	39 f0                	cmp    %esi,%eax
  8018a0:	77 24                	ja     8018c6 <devfile_read+0x56>
	assert(r <= PGSIZE);
  8018a2:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018a7:	7f 33                	jg     8018dc <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018a9:	83 ec 04             	sub    $0x4,%esp
  8018ac:	50                   	push   %eax
  8018ad:	68 00 50 80 00       	push   $0x805000
  8018b2:	ff 75 0c             	push   0xc(%ebp)
  8018b5:	e8 25 f2 ff ff       	call   800adf <memmove>
	return r;
  8018ba:	83 c4 10             	add    $0x10,%esp
}
  8018bd:	89 d8                	mov    %ebx,%eax
  8018bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018c2:	5b                   	pop    %ebx
  8018c3:	5e                   	pop    %esi
  8018c4:	5d                   	pop    %ebp
  8018c5:	c3                   	ret    
	assert(r <= n);
  8018c6:	68 e4 27 80 00       	push   $0x8027e4
  8018cb:	68 eb 27 80 00       	push   $0x8027eb
  8018d0:	6a 7c                	push   $0x7c
  8018d2:	68 00 28 80 00       	push   $0x802800
  8018d7:	e8 b8 e9 ff ff       	call   800294 <_panic>
	assert(r <= PGSIZE);
  8018dc:	68 0b 28 80 00       	push   $0x80280b
  8018e1:	68 eb 27 80 00       	push   $0x8027eb
  8018e6:	6a 7d                	push   $0x7d
  8018e8:	68 00 28 80 00       	push   $0x802800
  8018ed:	e8 a2 e9 ff ff       	call   800294 <_panic>

008018f2 <open>:
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	56                   	push   %esi
  8018f6:	53                   	push   %ebx
  8018f7:	83 ec 1c             	sub    $0x1c,%esp
  8018fa:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8018fd:	56                   	push   %esi
  8018fe:	e8 0b f0 ff ff       	call   80090e <strlen>
  801903:	83 c4 10             	add    $0x10,%esp
  801906:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80190b:	7f 6c                	jg     801979 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80190d:	83 ec 0c             	sub    $0xc,%esp
  801910:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801913:	50                   	push   %eax
  801914:	e8 c2 f8 ff ff       	call   8011db <fd_alloc>
  801919:	89 c3                	mov    %eax,%ebx
  80191b:	83 c4 10             	add    $0x10,%esp
  80191e:	85 c0                	test   %eax,%eax
  801920:	78 3c                	js     80195e <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801922:	83 ec 08             	sub    $0x8,%esp
  801925:	56                   	push   %esi
  801926:	68 00 50 80 00       	push   $0x805000
  80192b:	e8 19 f0 ff ff       	call   800949 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801930:	8b 45 0c             	mov    0xc(%ebp),%eax
  801933:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801938:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80193b:	b8 01 00 00 00       	mov    $0x1,%eax
  801940:	e8 f6 fd ff ff       	call   80173b <fsipc>
  801945:	89 c3                	mov    %eax,%ebx
  801947:	83 c4 10             	add    $0x10,%esp
  80194a:	85 c0                	test   %eax,%eax
  80194c:	78 19                	js     801967 <open+0x75>
	return fd2num(fd);
  80194e:	83 ec 0c             	sub    $0xc,%esp
  801951:	ff 75 f4             	push   -0xc(%ebp)
  801954:	e8 5b f8 ff ff       	call   8011b4 <fd2num>
  801959:	89 c3                	mov    %eax,%ebx
  80195b:	83 c4 10             	add    $0x10,%esp
}
  80195e:	89 d8                	mov    %ebx,%eax
  801960:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801963:	5b                   	pop    %ebx
  801964:	5e                   	pop    %esi
  801965:	5d                   	pop    %ebp
  801966:	c3                   	ret    
		fd_close(fd, 0);
  801967:	83 ec 08             	sub    $0x8,%esp
  80196a:	6a 00                	push   $0x0
  80196c:	ff 75 f4             	push   -0xc(%ebp)
  80196f:	e8 58 f9 ff ff       	call   8012cc <fd_close>
		return r;
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	eb e5                	jmp    80195e <open+0x6c>
		return -E_BAD_PATH;
  801979:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80197e:	eb de                	jmp    80195e <open+0x6c>

00801980 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801986:	ba 00 00 00 00       	mov    $0x0,%edx
  80198b:	b8 08 00 00 00       	mov    $0x8,%eax
  801990:	e8 a6 fd ff ff       	call   80173b <fsipc>
}
  801995:	c9                   	leave  
  801996:	c3                   	ret    

00801997 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801997:	55                   	push   %ebp
  801998:	89 e5                	mov    %esp,%ebp
  80199a:	56                   	push   %esi
  80199b:	53                   	push   %ebx
  80199c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80199f:	83 ec 0c             	sub    $0xc,%esp
  8019a2:	ff 75 08             	push   0x8(%ebp)
  8019a5:	e8 1a f8 ff ff       	call   8011c4 <fd2data>
  8019aa:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019ac:	83 c4 08             	add    $0x8,%esp
  8019af:	68 17 28 80 00       	push   $0x802817
  8019b4:	53                   	push   %ebx
  8019b5:	e8 8f ef ff ff       	call   800949 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8019ba:	8b 46 04             	mov    0x4(%esi),%eax
  8019bd:	2b 06                	sub    (%esi),%eax
  8019bf:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8019c5:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019cc:	00 00 00 
	stat->st_dev = &devpipe;
  8019cf:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8019d6:	30 80 00 
	return 0;
}
  8019d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8019de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e1:	5b                   	pop    %ebx
  8019e2:	5e                   	pop    %esi
  8019e3:	5d                   	pop    %ebp
  8019e4:	c3                   	ret    

008019e5 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019e5:	55                   	push   %ebp
  8019e6:	89 e5                	mov    %esp,%ebp
  8019e8:	53                   	push   %ebx
  8019e9:	83 ec 0c             	sub    $0xc,%esp
  8019ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019ef:	53                   	push   %ebx
  8019f0:	6a 00                	push   $0x0
  8019f2:	e8 d3 f3 ff ff       	call   800dca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019f7:	89 1c 24             	mov    %ebx,(%esp)
  8019fa:	e8 c5 f7 ff ff       	call   8011c4 <fd2data>
  8019ff:	83 c4 08             	add    $0x8,%esp
  801a02:	50                   	push   %eax
  801a03:	6a 00                	push   $0x0
  801a05:	e8 c0 f3 ff ff       	call   800dca <sys_page_unmap>
}
  801a0a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a0d:	c9                   	leave  
  801a0e:	c3                   	ret    

00801a0f <_pipeisclosed>:
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	57                   	push   %edi
  801a13:	56                   	push   %esi
  801a14:	53                   	push   %ebx
  801a15:	83 ec 1c             	sub    $0x1c,%esp
  801a18:	89 c7                	mov    %eax,%edi
  801a1a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801a1c:	a1 00 40 80 00       	mov    0x804000,%eax
  801a21:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801a24:	83 ec 0c             	sub    $0xc,%esp
  801a27:	57                   	push   %edi
  801a28:	e8 b8 05 00 00       	call   801fe5 <pageref>
  801a2d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a30:	89 34 24             	mov    %esi,(%esp)
  801a33:	e8 ad 05 00 00       	call   801fe5 <pageref>
		nn = thisenv->env_runs;
  801a38:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a3e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a41:	83 c4 10             	add    $0x10,%esp
  801a44:	39 cb                	cmp    %ecx,%ebx
  801a46:	74 1b                	je     801a63 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a48:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a4b:	75 cf                	jne    801a1c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a4d:	8b 42 58             	mov    0x58(%edx),%eax
  801a50:	6a 01                	push   $0x1
  801a52:	50                   	push   %eax
  801a53:	53                   	push   %ebx
  801a54:	68 1e 28 80 00       	push   $0x80281e
  801a59:	e8 11 e9 ff ff       	call   80036f <cprintf>
  801a5e:	83 c4 10             	add    $0x10,%esp
  801a61:	eb b9                	jmp    801a1c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801a63:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a66:	0f 94 c0             	sete   %al
  801a69:	0f b6 c0             	movzbl %al,%eax
}
  801a6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a6f:	5b                   	pop    %ebx
  801a70:	5e                   	pop    %esi
  801a71:	5f                   	pop    %edi
  801a72:	5d                   	pop    %ebp
  801a73:	c3                   	ret    

00801a74 <devpipe_write>:
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	57                   	push   %edi
  801a78:	56                   	push   %esi
  801a79:	53                   	push   %ebx
  801a7a:	83 ec 28             	sub    $0x28,%esp
  801a7d:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801a80:	56                   	push   %esi
  801a81:	e8 3e f7 ff ff       	call   8011c4 <fd2data>
  801a86:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	bf 00 00 00 00       	mov    $0x0,%edi
  801a90:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a93:	75 09                	jne    801a9e <devpipe_write+0x2a>
	return i;
  801a95:	89 f8                	mov    %edi,%eax
  801a97:	eb 23                	jmp    801abc <devpipe_write+0x48>
			sys_yield();
  801a99:	e8 88 f2 ff ff       	call   800d26 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a9e:	8b 43 04             	mov    0x4(%ebx),%eax
  801aa1:	8b 0b                	mov    (%ebx),%ecx
  801aa3:	8d 51 20             	lea    0x20(%ecx),%edx
  801aa6:	39 d0                	cmp    %edx,%eax
  801aa8:	72 1a                	jb     801ac4 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801aaa:	89 da                	mov    %ebx,%edx
  801aac:	89 f0                	mov    %esi,%eax
  801aae:	e8 5c ff ff ff       	call   801a0f <_pipeisclosed>
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	74 e2                	je     801a99 <devpipe_write+0x25>
				return 0;
  801ab7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801abc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801abf:	5b                   	pop    %ebx
  801ac0:	5e                   	pop    %esi
  801ac1:	5f                   	pop    %edi
  801ac2:	5d                   	pop    %ebp
  801ac3:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801ac4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ac7:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801acb:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ace:	89 c2                	mov    %eax,%edx
  801ad0:	c1 fa 1f             	sar    $0x1f,%edx
  801ad3:	89 d1                	mov    %edx,%ecx
  801ad5:	c1 e9 1b             	shr    $0x1b,%ecx
  801ad8:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801adb:	83 e2 1f             	and    $0x1f,%edx
  801ade:	29 ca                	sub    %ecx,%edx
  801ae0:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ae4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ae8:	83 c0 01             	add    $0x1,%eax
  801aeb:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801aee:	83 c7 01             	add    $0x1,%edi
  801af1:	eb 9d                	jmp    801a90 <devpipe_write+0x1c>

00801af3 <devpipe_read>:
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	57                   	push   %edi
  801af7:	56                   	push   %esi
  801af8:	53                   	push   %ebx
  801af9:	83 ec 18             	sub    $0x18,%esp
  801afc:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801aff:	57                   	push   %edi
  801b00:	e8 bf f6 ff ff       	call   8011c4 <fd2data>
  801b05:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801b07:	83 c4 10             	add    $0x10,%esp
  801b0a:	be 00 00 00 00       	mov    $0x0,%esi
  801b0f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801b12:	75 13                	jne    801b27 <devpipe_read+0x34>
	return i;
  801b14:	89 f0                	mov    %esi,%eax
  801b16:	eb 02                	jmp    801b1a <devpipe_read+0x27>
				return i;
  801b18:	89 f0                	mov    %esi,%eax
}
  801b1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1d:	5b                   	pop    %ebx
  801b1e:	5e                   	pop    %esi
  801b1f:	5f                   	pop    %edi
  801b20:	5d                   	pop    %ebp
  801b21:	c3                   	ret    
			sys_yield();
  801b22:	e8 ff f1 ff ff       	call   800d26 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801b27:	8b 03                	mov    (%ebx),%eax
  801b29:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b2c:	75 18                	jne    801b46 <devpipe_read+0x53>
			if (i > 0)
  801b2e:	85 f6                	test   %esi,%esi
  801b30:	75 e6                	jne    801b18 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801b32:	89 da                	mov    %ebx,%edx
  801b34:	89 f8                	mov    %edi,%eax
  801b36:	e8 d4 fe ff ff       	call   801a0f <_pipeisclosed>
  801b3b:	85 c0                	test   %eax,%eax
  801b3d:	74 e3                	je     801b22 <devpipe_read+0x2f>
				return 0;
  801b3f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b44:	eb d4                	jmp    801b1a <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b46:	99                   	cltd   
  801b47:	c1 ea 1b             	shr    $0x1b,%edx
  801b4a:	01 d0                	add    %edx,%eax
  801b4c:	83 e0 1f             	and    $0x1f,%eax
  801b4f:	29 d0                	sub    %edx,%eax
  801b51:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b59:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b5c:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b5f:	83 c6 01             	add    $0x1,%esi
  801b62:	eb ab                	jmp    801b0f <devpipe_read+0x1c>

00801b64 <pipe>:
{
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
  801b67:	56                   	push   %esi
  801b68:	53                   	push   %ebx
  801b69:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801b6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b6f:	50                   	push   %eax
  801b70:	e8 66 f6 ff ff       	call   8011db <fd_alloc>
  801b75:	89 c3                	mov    %eax,%ebx
  801b77:	83 c4 10             	add    $0x10,%esp
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	0f 88 23 01 00 00    	js     801ca5 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b82:	83 ec 04             	sub    $0x4,%esp
  801b85:	68 07 04 00 00       	push   $0x407
  801b8a:	ff 75 f4             	push   -0xc(%ebp)
  801b8d:	6a 00                	push   $0x0
  801b8f:	e8 b1 f1 ff ff       	call   800d45 <sys_page_alloc>
  801b94:	89 c3                	mov    %eax,%ebx
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	0f 88 04 01 00 00    	js     801ca5 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801ba1:	83 ec 0c             	sub    $0xc,%esp
  801ba4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ba7:	50                   	push   %eax
  801ba8:	e8 2e f6 ff ff       	call   8011db <fd_alloc>
  801bad:	89 c3                	mov    %eax,%ebx
  801baf:	83 c4 10             	add    $0x10,%esp
  801bb2:	85 c0                	test   %eax,%eax
  801bb4:	0f 88 db 00 00 00    	js     801c95 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bba:	83 ec 04             	sub    $0x4,%esp
  801bbd:	68 07 04 00 00       	push   $0x407
  801bc2:	ff 75 f0             	push   -0x10(%ebp)
  801bc5:	6a 00                	push   $0x0
  801bc7:	e8 79 f1 ff ff       	call   800d45 <sys_page_alloc>
  801bcc:	89 c3                	mov    %eax,%ebx
  801bce:	83 c4 10             	add    $0x10,%esp
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	0f 88 bc 00 00 00    	js     801c95 <pipe+0x131>
	va = fd2data(fd0);
  801bd9:	83 ec 0c             	sub    $0xc,%esp
  801bdc:	ff 75 f4             	push   -0xc(%ebp)
  801bdf:	e8 e0 f5 ff ff       	call   8011c4 <fd2data>
  801be4:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801be6:	83 c4 0c             	add    $0xc,%esp
  801be9:	68 07 04 00 00       	push   $0x407
  801bee:	50                   	push   %eax
  801bef:	6a 00                	push   $0x0
  801bf1:	e8 4f f1 ff ff       	call   800d45 <sys_page_alloc>
  801bf6:	89 c3                	mov    %eax,%ebx
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	85 c0                	test   %eax,%eax
  801bfd:	0f 88 82 00 00 00    	js     801c85 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c03:	83 ec 0c             	sub    $0xc,%esp
  801c06:	ff 75 f0             	push   -0x10(%ebp)
  801c09:	e8 b6 f5 ff ff       	call   8011c4 <fd2data>
  801c0e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c15:	50                   	push   %eax
  801c16:	6a 00                	push   $0x0
  801c18:	56                   	push   %esi
  801c19:	6a 00                	push   $0x0
  801c1b:	e8 68 f1 ff ff       	call   800d88 <sys_page_map>
  801c20:	89 c3                	mov    %eax,%ebx
  801c22:	83 c4 20             	add    $0x20,%esp
  801c25:	85 c0                	test   %eax,%eax
  801c27:	78 4e                	js     801c77 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801c29:	a1 20 30 80 00       	mov    0x803020,%eax
  801c2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c31:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801c33:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c36:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801c3d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c40:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801c42:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c45:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c4c:	83 ec 0c             	sub    $0xc,%esp
  801c4f:	ff 75 f4             	push   -0xc(%ebp)
  801c52:	e8 5d f5 ff ff       	call   8011b4 <fd2num>
  801c57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c5a:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c5c:	83 c4 04             	add    $0x4,%esp
  801c5f:	ff 75 f0             	push   -0x10(%ebp)
  801c62:	e8 4d f5 ff ff       	call   8011b4 <fd2num>
  801c67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c6a:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c6d:	83 c4 10             	add    $0x10,%esp
  801c70:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c75:	eb 2e                	jmp    801ca5 <pipe+0x141>
	sys_page_unmap(0, va);
  801c77:	83 ec 08             	sub    $0x8,%esp
  801c7a:	56                   	push   %esi
  801c7b:	6a 00                	push   $0x0
  801c7d:	e8 48 f1 ff ff       	call   800dca <sys_page_unmap>
  801c82:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801c85:	83 ec 08             	sub    $0x8,%esp
  801c88:	ff 75 f0             	push   -0x10(%ebp)
  801c8b:	6a 00                	push   $0x0
  801c8d:	e8 38 f1 ff ff       	call   800dca <sys_page_unmap>
  801c92:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801c95:	83 ec 08             	sub    $0x8,%esp
  801c98:	ff 75 f4             	push   -0xc(%ebp)
  801c9b:	6a 00                	push   $0x0
  801c9d:	e8 28 f1 ff ff       	call   800dca <sys_page_unmap>
  801ca2:	83 c4 10             	add    $0x10,%esp
}
  801ca5:	89 d8                	mov    %ebx,%eax
  801ca7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801caa:	5b                   	pop    %ebx
  801cab:	5e                   	pop    %esi
  801cac:	5d                   	pop    %ebp
  801cad:	c3                   	ret    

00801cae <pipeisclosed>:
{
  801cae:	55                   	push   %ebp
  801caf:	89 e5                	mov    %esp,%ebp
  801cb1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801cb4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cb7:	50                   	push   %eax
  801cb8:	ff 75 08             	push   0x8(%ebp)
  801cbb:	e8 6b f5 ff ff       	call   80122b <fd_lookup>
  801cc0:	83 c4 10             	add    $0x10,%esp
  801cc3:	85 c0                	test   %eax,%eax
  801cc5:	78 18                	js     801cdf <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801cc7:	83 ec 0c             	sub    $0xc,%esp
  801cca:	ff 75 f4             	push   -0xc(%ebp)
  801ccd:	e8 f2 f4 ff ff       	call   8011c4 <fd2data>
  801cd2:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd7:	e8 33 fd ff ff       	call   801a0f <_pipeisclosed>
  801cdc:	83 c4 10             	add    $0x10,%esp
}
  801cdf:	c9                   	leave  
  801ce0:	c3                   	ret    

00801ce1 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801ce1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ce6:	c3                   	ret    

00801ce7 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ced:	68 31 28 80 00       	push   $0x802831
  801cf2:	ff 75 0c             	push   0xc(%ebp)
  801cf5:	e8 4f ec ff ff       	call   800949 <strcpy>
	return 0;
}
  801cfa:	b8 00 00 00 00       	mov    $0x0,%eax
  801cff:	c9                   	leave  
  801d00:	c3                   	ret    

00801d01 <devcons_write>:
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	57                   	push   %edi
  801d05:	56                   	push   %esi
  801d06:	53                   	push   %ebx
  801d07:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801d0d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801d12:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801d18:	eb 2e                	jmp    801d48 <devcons_write+0x47>
		m = n - tot;
  801d1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d1d:	29 f3                	sub    %esi,%ebx
  801d1f:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801d24:	39 c3                	cmp    %eax,%ebx
  801d26:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801d29:	83 ec 04             	sub    $0x4,%esp
  801d2c:	53                   	push   %ebx
  801d2d:	89 f0                	mov    %esi,%eax
  801d2f:	03 45 0c             	add    0xc(%ebp),%eax
  801d32:	50                   	push   %eax
  801d33:	57                   	push   %edi
  801d34:	e8 a6 ed ff ff       	call   800adf <memmove>
		sys_cputs(buf, m);
  801d39:	83 c4 08             	add    $0x8,%esp
  801d3c:	53                   	push   %ebx
  801d3d:	57                   	push   %edi
  801d3e:	e8 46 ef ff ff       	call   800c89 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801d43:	01 de                	add    %ebx,%esi
  801d45:	83 c4 10             	add    $0x10,%esp
  801d48:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d4b:	72 cd                	jb     801d1a <devcons_write+0x19>
}
  801d4d:	89 f0                	mov    %esi,%eax
  801d4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d52:	5b                   	pop    %ebx
  801d53:	5e                   	pop    %esi
  801d54:	5f                   	pop    %edi
  801d55:	5d                   	pop    %ebp
  801d56:	c3                   	ret    

00801d57 <devcons_read>:
{
  801d57:	55                   	push   %ebp
  801d58:	89 e5                	mov    %esp,%ebp
  801d5a:	83 ec 08             	sub    $0x8,%esp
  801d5d:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801d62:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801d66:	75 07                	jne    801d6f <devcons_read+0x18>
  801d68:	eb 1f                	jmp    801d89 <devcons_read+0x32>
		sys_yield();
  801d6a:	e8 b7 ef ff ff       	call   800d26 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801d6f:	e8 33 ef ff ff       	call   800ca7 <sys_cgetc>
  801d74:	85 c0                	test   %eax,%eax
  801d76:	74 f2                	je     801d6a <devcons_read+0x13>
	if (c < 0)
  801d78:	78 0f                	js     801d89 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801d7a:	83 f8 04             	cmp    $0x4,%eax
  801d7d:	74 0c                	je     801d8b <devcons_read+0x34>
	*(char*)vbuf = c;
  801d7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d82:	88 02                	mov    %al,(%edx)
	return 1;
  801d84:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801d89:	c9                   	leave  
  801d8a:	c3                   	ret    
		return 0;
  801d8b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d90:	eb f7                	jmp    801d89 <devcons_read+0x32>

00801d92 <cputchar>:
{
  801d92:	55                   	push   %ebp
  801d93:	89 e5                	mov    %esp,%ebp
  801d95:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d98:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9b:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801d9e:	6a 01                	push   $0x1
  801da0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801da3:	50                   	push   %eax
  801da4:	e8 e0 ee ff ff       	call   800c89 <sys_cputs>
}
  801da9:	83 c4 10             	add    $0x10,%esp
  801dac:	c9                   	leave  
  801dad:	c3                   	ret    

00801dae <getchar>:
{
  801dae:	55                   	push   %ebp
  801daf:	89 e5                	mov    %esp,%ebp
  801db1:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801db4:	6a 01                	push   $0x1
  801db6:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801db9:	50                   	push   %eax
  801dba:	6a 00                	push   $0x0
  801dbc:	e8 ce f6 ff ff       	call   80148f <read>
	if (r < 0)
  801dc1:	83 c4 10             	add    $0x10,%esp
  801dc4:	85 c0                	test   %eax,%eax
  801dc6:	78 06                	js     801dce <getchar+0x20>
	if (r < 1)
  801dc8:	74 06                	je     801dd0 <getchar+0x22>
	return c;
  801dca:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801dce:	c9                   	leave  
  801dcf:	c3                   	ret    
		return -E_EOF;
  801dd0:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801dd5:	eb f7                	jmp    801dce <getchar+0x20>

00801dd7 <iscons>:
{
  801dd7:	55                   	push   %ebp
  801dd8:	89 e5                	mov    %esp,%ebp
  801dda:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ddd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801de0:	50                   	push   %eax
  801de1:	ff 75 08             	push   0x8(%ebp)
  801de4:	e8 42 f4 ff ff       	call   80122b <fd_lookup>
  801de9:	83 c4 10             	add    $0x10,%esp
  801dec:	85 c0                	test   %eax,%eax
  801dee:	78 11                	js     801e01 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801df0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801df9:	39 10                	cmp    %edx,(%eax)
  801dfb:	0f 94 c0             	sete   %al
  801dfe:	0f b6 c0             	movzbl %al,%eax
}
  801e01:	c9                   	leave  
  801e02:	c3                   	ret    

00801e03 <opencons>:
{
  801e03:	55                   	push   %ebp
  801e04:	89 e5                	mov    %esp,%ebp
  801e06:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801e09:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e0c:	50                   	push   %eax
  801e0d:	e8 c9 f3 ff ff       	call   8011db <fd_alloc>
  801e12:	83 c4 10             	add    $0x10,%esp
  801e15:	85 c0                	test   %eax,%eax
  801e17:	78 3a                	js     801e53 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e19:	83 ec 04             	sub    $0x4,%esp
  801e1c:	68 07 04 00 00       	push   $0x407
  801e21:	ff 75 f4             	push   -0xc(%ebp)
  801e24:	6a 00                	push   $0x0
  801e26:	e8 1a ef ff ff       	call   800d45 <sys_page_alloc>
  801e2b:	83 c4 10             	add    $0x10,%esp
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	78 21                	js     801e53 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801e32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e35:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801e3b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801e3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e40:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801e47:	83 ec 0c             	sub    $0xc,%esp
  801e4a:	50                   	push   %eax
  801e4b:	e8 64 f3 ff ff       	call   8011b4 <fd2num>
  801e50:	83 c4 10             	add    $0x10,%esp
}
  801e53:	c9                   	leave  
  801e54:	c3                   	ret    

00801e55 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e55:	55                   	push   %ebp
  801e56:	89 e5                	mov    %esp,%ebp
  801e58:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  801e5b:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  801e62:	74 0a                	je     801e6e <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e64:	8b 45 08             	mov    0x8(%ebp),%eax
  801e67:	a3 04 60 80 00       	mov    %eax,0x806004
}
  801e6c:	c9                   	leave  
  801e6d:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  801e6e:	e8 94 ee ff ff       	call   800d07 <sys_getenvid>
  801e73:	83 ec 04             	sub    $0x4,%esp
  801e76:	68 07 0e 00 00       	push   $0xe07
  801e7b:	68 00 f0 bf ee       	push   $0xeebff000
  801e80:	50                   	push   %eax
  801e81:	e8 bf ee ff ff       	call   800d45 <sys_page_alloc>
		if (r < 0) {
  801e86:	83 c4 10             	add    $0x10,%esp
  801e89:	85 c0                	test   %eax,%eax
  801e8b:	78 2c                	js     801eb9 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801e8d:	e8 75 ee ff ff       	call   800d07 <sys_getenvid>
  801e92:	83 ec 08             	sub    $0x8,%esp
  801e95:	68 cb 1e 80 00       	push   $0x801ecb
  801e9a:	50                   	push   %eax
  801e9b:	e8 f0 ef ff ff       	call   800e90 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801ea0:	83 c4 10             	add    $0x10,%esp
  801ea3:	85 c0                	test   %eax,%eax
  801ea5:	79 bd                	jns    801e64 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  801ea7:	50                   	push   %eax
  801ea8:	68 80 28 80 00       	push   $0x802880
  801ead:	6a 28                	push   $0x28
  801eaf:	68 b6 28 80 00       	push   $0x8028b6
  801eb4:	e8 db e3 ff ff       	call   800294 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  801eb9:	50                   	push   %eax
  801eba:	68 40 28 80 00       	push   $0x802840
  801ebf:	6a 23                	push   $0x23
  801ec1:	68 b6 28 80 00       	push   $0x8028b6
  801ec6:	e8 c9 e3 ff ff       	call   800294 <_panic>

00801ecb <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801ecb:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801ecc:	a1 04 60 80 00       	mov    0x806004,%eax
	call *%eax
  801ed1:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801ed3:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  801ed6:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  801eda:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801edd:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  801ee1:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801ee5:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  801ee7:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  801eea:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  801eeb:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  801eee:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  801eef:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  801ef0:	c3                   	ret    

00801ef1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ef1:	55                   	push   %ebp
  801ef2:	89 e5                	mov    %esp,%ebp
  801ef4:	56                   	push   %esi
  801ef5:	53                   	push   %ebx
  801ef6:	8b 75 08             	mov    0x8(%ebp),%esi
  801ef9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801efc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801eff:	85 c0                	test   %eax,%eax
  801f01:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f06:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801f09:	83 ec 0c             	sub    $0xc,%esp
  801f0c:	50                   	push   %eax
  801f0d:	e8 e3 ef ff ff       	call   800ef5 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801f12:	83 c4 10             	add    $0x10,%esp
  801f15:	85 f6                	test   %esi,%esi
  801f17:	74 14                	je     801f2d <ipc_recv+0x3c>
  801f19:	ba 00 00 00 00       	mov    $0x0,%edx
  801f1e:	85 c0                	test   %eax,%eax
  801f20:	78 09                	js     801f2b <ipc_recv+0x3a>
  801f22:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f28:	8b 52 74             	mov    0x74(%edx),%edx
  801f2b:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801f2d:	85 db                	test   %ebx,%ebx
  801f2f:	74 14                	je     801f45 <ipc_recv+0x54>
  801f31:	ba 00 00 00 00       	mov    $0x0,%edx
  801f36:	85 c0                	test   %eax,%eax
  801f38:	78 09                	js     801f43 <ipc_recv+0x52>
  801f3a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f40:	8b 52 78             	mov    0x78(%edx),%edx
  801f43:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f45:	85 c0                	test   %eax,%eax
  801f47:	78 08                	js     801f51 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801f49:	a1 00 40 80 00       	mov    0x804000,%eax
  801f4e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f54:	5b                   	pop    %ebx
  801f55:	5e                   	pop    %esi
  801f56:	5d                   	pop    %ebp
  801f57:	c3                   	ret    

00801f58 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f58:	55                   	push   %ebp
  801f59:	89 e5                	mov    %esp,%ebp
  801f5b:	57                   	push   %edi
  801f5c:	56                   	push   %esi
  801f5d:	53                   	push   %ebx
  801f5e:	83 ec 0c             	sub    $0xc,%esp
  801f61:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f64:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f6a:	85 db                	test   %ebx,%ebx
  801f6c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f71:	0f 44 d8             	cmove  %eax,%ebx
  801f74:	eb 05                	jmp    801f7b <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f76:	e8 ab ed ff ff       	call   800d26 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f7b:	ff 75 14             	push   0x14(%ebp)
  801f7e:	53                   	push   %ebx
  801f7f:	56                   	push   %esi
  801f80:	57                   	push   %edi
  801f81:	e8 4c ef ff ff       	call   800ed2 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f86:	83 c4 10             	add    $0x10,%esp
  801f89:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f8c:	74 e8                	je     801f76 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	78 08                	js     801f9a <ipc_send+0x42>
	}while (r<0);

}
  801f92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f95:	5b                   	pop    %ebx
  801f96:	5e                   	pop    %esi
  801f97:	5f                   	pop    %edi
  801f98:	5d                   	pop    %ebp
  801f99:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f9a:	50                   	push   %eax
  801f9b:	68 c4 28 80 00       	push   $0x8028c4
  801fa0:	6a 3d                	push   $0x3d
  801fa2:	68 d8 28 80 00       	push   $0x8028d8
  801fa7:	e8 e8 e2 ff ff       	call   800294 <_panic>

00801fac <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fb2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fb7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fba:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fc0:	8b 52 50             	mov    0x50(%edx),%edx
  801fc3:	39 ca                	cmp    %ecx,%edx
  801fc5:	74 11                	je     801fd8 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801fc7:	83 c0 01             	add    $0x1,%eax
  801fca:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fcf:	75 e6                	jne    801fb7 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801fd1:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd6:	eb 0b                	jmp    801fe3 <ipc_find_env+0x37>
			return envs[i].env_id;
  801fd8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fdb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fe0:	8b 40 48             	mov    0x48(%eax),%eax
}
  801fe3:	5d                   	pop    %ebp
  801fe4:	c3                   	ret    

00801fe5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fe5:	55                   	push   %ebp
  801fe6:	89 e5                	mov    %esp,%ebp
  801fe8:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801feb:	89 c2                	mov    %eax,%edx
  801fed:	c1 ea 16             	shr    $0x16,%edx
  801ff0:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801ff7:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801ffc:	f6 c1 01             	test   $0x1,%cl
  801fff:	74 1c                	je     80201d <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802001:	c1 e8 0c             	shr    $0xc,%eax
  802004:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80200b:	a8 01                	test   $0x1,%al
  80200d:	74 0e                	je     80201d <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80200f:	c1 e8 0c             	shr    $0xc,%eax
  802012:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802019:	ef 
  80201a:	0f b7 d2             	movzwl %dx,%edx
}
  80201d:	89 d0                	mov    %edx,%eax
  80201f:	5d                   	pop    %ebp
  802020:	c3                   	ret    
  802021:	66 90                	xchg   %ax,%ax
  802023:	66 90                	xchg   %ax,%ax
  802025:	66 90                	xchg   %ax,%ax
  802027:	66 90                	xchg   %ax,%ax
  802029:	66 90                	xchg   %ax,%ax
  80202b:	66 90                	xchg   %ax,%ax
  80202d:	66 90                	xchg   %ax,%ax
  80202f:	90                   	nop

00802030 <__udivdi3>:
  802030:	f3 0f 1e fb          	endbr32 
  802034:	55                   	push   %ebp
  802035:	57                   	push   %edi
  802036:	56                   	push   %esi
  802037:	53                   	push   %ebx
  802038:	83 ec 1c             	sub    $0x1c,%esp
  80203b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80203f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802043:	8b 74 24 34          	mov    0x34(%esp),%esi
  802047:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80204b:	85 c0                	test   %eax,%eax
  80204d:	75 19                	jne    802068 <__udivdi3+0x38>
  80204f:	39 f3                	cmp    %esi,%ebx
  802051:	76 4d                	jbe    8020a0 <__udivdi3+0x70>
  802053:	31 ff                	xor    %edi,%edi
  802055:	89 e8                	mov    %ebp,%eax
  802057:	89 f2                	mov    %esi,%edx
  802059:	f7 f3                	div    %ebx
  80205b:	89 fa                	mov    %edi,%edx
  80205d:	83 c4 1c             	add    $0x1c,%esp
  802060:	5b                   	pop    %ebx
  802061:	5e                   	pop    %esi
  802062:	5f                   	pop    %edi
  802063:	5d                   	pop    %ebp
  802064:	c3                   	ret    
  802065:	8d 76 00             	lea    0x0(%esi),%esi
  802068:	39 f0                	cmp    %esi,%eax
  80206a:	76 14                	jbe    802080 <__udivdi3+0x50>
  80206c:	31 ff                	xor    %edi,%edi
  80206e:	31 c0                	xor    %eax,%eax
  802070:	89 fa                	mov    %edi,%edx
  802072:	83 c4 1c             	add    $0x1c,%esp
  802075:	5b                   	pop    %ebx
  802076:	5e                   	pop    %esi
  802077:	5f                   	pop    %edi
  802078:	5d                   	pop    %ebp
  802079:	c3                   	ret    
  80207a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802080:	0f bd f8             	bsr    %eax,%edi
  802083:	83 f7 1f             	xor    $0x1f,%edi
  802086:	75 48                	jne    8020d0 <__udivdi3+0xa0>
  802088:	39 f0                	cmp    %esi,%eax
  80208a:	72 06                	jb     802092 <__udivdi3+0x62>
  80208c:	31 c0                	xor    %eax,%eax
  80208e:	39 eb                	cmp    %ebp,%ebx
  802090:	77 de                	ja     802070 <__udivdi3+0x40>
  802092:	b8 01 00 00 00       	mov    $0x1,%eax
  802097:	eb d7                	jmp    802070 <__udivdi3+0x40>
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	89 d9                	mov    %ebx,%ecx
  8020a2:	85 db                	test   %ebx,%ebx
  8020a4:	75 0b                	jne    8020b1 <__udivdi3+0x81>
  8020a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020ab:	31 d2                	xor    %edx,%edx
  8020ad:	f7 f3                	div    %ebx
  8020af:	89 c1                	mov    %eax,%ecx
  8020b1:	31 d2                	xor    %edx,%edx
  8020b3:	89 f0                	mov    %esi,%eax
  8020b5:	f7 f1                	div    %ecx
  8020b7:	89 c6                	mov    %eax,%esi
  8020b9:	89 e8                	mov    %ebp,%eax
  8020bb:	89 f7                	mov    %esi,%edi
  8020bd:	f7 f1                	div    %ecx
  8020bf:	89 fa                	mov    %edi,%edx
  8020c1:	83 c4 1c             	add    $0x1c,%esp
  8020c4:	5b                   	pop    %ebx
  8020c5:	5e                   	pop    %esi
  8020c6:	5f                   	pop    %edi
  8020c7:	5d                   	pop    %ebp
  8020c8:	c3                   	ret    
  8020c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020d0:	89 f9                	mov    %edi,%ecx
  8020d2:	ba 20 00 00 00       	mov    $0x20,%edx
  8020d7:	29 fa                	sub    %edi,%edx
  8020d9:	d3 e0                	shl    %cl,%eax
  8020db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020df:	89 d1                	mov    %edx,%ecx
  8020e1:	89 d8                	mov    %ebx,%eax
  8020e3:	d3 e8                	shr    %cl,%eax
  8020e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020e9:	09 c1                	or     %eax,%ecx
  8020eb:	89 f0                	mov    %esi,%eax
  8020ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020f1:	89 f9                	mov    %edi,%ecx
  8020f3:	d3 e3                	shl    %cl,%ebx
  8020f5:	89 d1                	mov    %edx,%ecx
  8020f7:	d3 e8                	shr    %cl,%eax
  8020f9:	89 f9                	mov    %edi,%ecx
  8020fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020ff:	89 eb                	mov    %ebp,%ebx
  802101:	d3 e6                	shl    %cl,%esi
  802103:	89 d1                	mov    %edx,%ecx
  802105:	d3 eb                	shr    %cl,%ebx
  802107:	09 f3                	or     %esi,%ebx
  802109:	89 c6                	mov    %eax,%esi
  80210b:	89 f2                	mov    %esi,%edx
  80210d:	89 d8                	mov    %ebx,%eax
  80210f:	f7 74 24 08          	divl   0x8(%esp)
  802113:	89 d6                	mov    %edx,%esi
  802115:	89 c3                	mov    %eax,%ebx
  802117:	f7 64 24 0c          	mull   0xc(%esp)
  80211b:	39 d6                	cmp    %edx,%esi
  80211d:	72 19                	jb     802138 <__udivdi3+0x108>
  80211f:	89 f9                	mov    %edi,%ecx
  802121:	d3 e5                	shl    %cl,%ebp
  802123:	39 c5                	cmp    %eax,%ebp
  802125:	73 04                	jae    80212b <__udivdi3+0xfb>
  802127:	39 d6                	cmp    %edx,%esi
  802129:	74 0d                	je     802138 <__udivdi3+0x108>
  80212b:	89 d8                	mov    %ebx,%eax
  80212d:	31 ff                	xor    %edi,%edi
  80212f:	e9 3c ff ff ff       	jmp    802070 <__udivdi3+0x40>
  802134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802138:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80213b:	31 ff                	xor    %edi,%edi
  80213d:	e9 2e ff ff ff       	jmp    802070 <__udivdi3+0x40>
  802142:	66 90                	xchg   %ax,%ax
  802144:	66 90                	xchg   %ax,%ax
  802146:	66 90                	xchg   %ax,%ax
  802148:	66 90                	xchg   %ax,%ax
  80214a:	66 90                	xchg   %ax,%ax
  80214c:	66 90                	xchg   %ax,%ax
  80214e:	66 90                	xchg   %ax,%ax

00802150 <__umoddi3>:
  802150:	f3 0f 1e fb          	endbr32 
  802154:	55                   	push   %ebp
  802155:	57                   	push   %edi
  802156:	56                   	push   %esi
  802157:	53                   	push   %ebx
  802158:	83 ec 1c             	sub    $0x1c,%esp
  80215b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80215f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802163:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802167:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80216b:	89 f0                	mov    %esi,%eax
  80216d:	89 da                	mov    %ebx,%edx
  80216f:	85 ff                	test   %edi,%edi
  802171:	75 15                	jne    802188 <__umoddi3+0x38>
  802173:	39 dd                	cmp    %ebx,%ebp
  802175:	76 39                	jbe    8021b0 <__umoddi3+0x60>
  802177:	f7 f5                	div    %ebp
  802179:	89 d0                	mov    %edx,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	83 c4 1c             	add    $0x1c,%esp
  802180:	5b                   	pop    %ebx
  802181:	5e                   	pop    %esi
  802182:	5f                   	pop    %edi
  802183:	5d                   	pop    %ebp
  802184:	c3                   	ret    
  802185:	8d 76 00             	lea    0x0(%esi),%esi
  802188:	39 df                	cmp    %ebx,%edi
  80218a:	77 f1                	ja     80217d <__umoddi3+0x2d>
  80218c:	0f bd cf             	bsr    %edi,%ecx
  80218f:	83 f1 1f             	xor    $0x1f,%ecx
  802192:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802196:	75 40                	jne    8021d8 <__umoddi3+0x88>
  802198:	39 df                	cmp    %ebx,%edi
  80219a:	72 04                	jb     8021a0 <__umoddi3+0x50>
  80219c:	39 f5                	cmp    %esi,%ebp
  80219e:	77 dd                	ja     80217d <__umoddi3+0x2d>
  8021a0:	89 da                	mov    %ebx,%edx
  8021a2:	89 f0                	mov    %esi,%eax
  8021a4:	29 e8                	sub    %ebp,%eax
  8021a6:	19 fa                	sbb    %edi,%edx
  8021a8:	eb d3                	jmp    80217d <__umoddi3+0x2d>
  8021aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b0:	89 e9                	mov    %ebp,%ecx
  8021b2:	85 ed                	test   %ebp,%ebp
  8021b4:	75 0b                	jne    8021c1 <__umoddi3+0x71>
  8021b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021bb:	31 d2                	xor    %edx,%edx
  8021bd:	f7 f5                	div    %ebp
  8021bf:	89 c1                	mov    %eax,%ecx
  8021c1:	89 d8                	mov    %ebx,%eax
  8021c3:	31 d2                	xor    %edx,%edx
  8021c5:	f7 f1                	div    %ecx
  8021c7:	89 f0                	mov    %esi,%eax
  8021c9:	f7 f1                	div    %ecx
  8021cb:	89 d0                	mov    %edx,%eax
  8021cd:	31 d2                	xor    %edx,%edx
  8021cf:	eb ac                	jmp    80217d <__umoddi3+0x2d>
  8021d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021d8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021dc:	ba 20 00 00 00       	mov    $0x20,%edx
  8021e1:	29 c2                	sub    %eax,%edx
  8021e3:	89 c1                	mov    %eax,%ecx
  8021e5:	89 e8                	mov    %ebp,%eax
  8021e7:	d3 e7                	shl    %cl,%edi
  8021e9:	89 d1                	mov    %edx,%ecx
  8021eb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021ef:	d3 e8                	shr    %cl,%eax
  8021f1:	89 c1                	mov    %eax,%ecx
  8021f3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021f7:	09 f9                	or     %edi,%ecx
  8021f9:	89 df                	mov    %ebx,%edi
  8021fb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ff:	89 c1                	mov    %eax,%ecx
  802201:	d3 e5                	shl    %cl,%ebp
  802203:	89 d1                	mov    %edx,%ecx
  802205:	d3 ef                	shr    %cl,%edi
  802207:	89 c1                	mov    %eax,%ecx
  802209:	89 f0                	mov    %esi,%eax
  80220b:	d3 e3                	shl    %cl,%ebx
  80220d:	89 d1                	mov    %edx,%ecx
  80220f:	89 fa                	mov    %edi,%edx
  802211:	d3 e8                	shr    %cl,%eax
  802213:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802218:	09 d8                	or     %ebx,%eax
  80221a:	f7 74 24 08          	divl   0x8(%esp)
  80221e:	89 d3                	mov    %edx,%ebx
  802220:	d3 e6                	shl    %cl,%esi
  802222:	f7 e5                	mul    %ebp
  802224:	89 c7                	mov    %eax,%edi
  802226:	89 d1                	mov    %edx,%ecx
  802228:	39 d3                	cmp    %edx,%ebx
  80222a:	72 06                	jb     802232 <__umoddi3+0xe2>
  80222c:	75 0e                	jne    80223c <__umoddi3+0xec>
  80222e:	39 c6                	cmp    %eax,%esi
  802230:	73 0a                	jae    80223c <__umoddi3+0xec>
  802232:	29 e8                	sub    %ebp,%eax
  802234:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802238:	89 d1                	mov    %edx,%ecx
  80223a:	89 c7                	mov    %eax,%edi
  80223c:	89 f5                	mov    %esi,%ebp
  80223e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802242:	29 fd                	sub    %edi,%ebp
  802244:	19 cb                	sbb    %ecx,%ebx
  802246:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80224b:	89 d8                	mov    %ebx,%eax
  80224d:	d3 e0                	shl    %cl,%eax
  80224f:	89 f1                	mov    %esi,%ecx
  802251:	d3 ed                	shr    %cl,%ebp
  802253:	d3 eb                	shr    %cl,%ebx
  802255:	09 e8                	or     %ebp,%eax
  802257:	89 da                	mov    %ebx,%edx
  802259:	83 c4 1c             	add    $0x1c,%esp
  80225c:	5b                   	pop    %ebx
  80225d:	5e                   	pop    %esi
  80225e:	5f                   	pop    %edi
  80225f:	5d                   	pop    %ebp
  802260:	c3                   	ret    
