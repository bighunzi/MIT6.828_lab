
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
  80004c:	e8 2b 15 00 00       	call   80157c <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	75 49                	jne    8000a2 <primeproc+0x6f>
	cprintf("%d\n", p);
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	ff 75 e0             	push   -0x20(%ebp)
  80005f:	68 81 27 80 00       	push   $0x802781
  800064:	e8 06 03 00 00       	call   80036f <cprintf>
	if ((i=pipe(pfd)) < 0)
  800069:	89 3c 24             	mov    %edi,(%esp)
  80006c:	e8 c1 1f 00 00       	call   802032 <pipe>
  800071:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	85 c0                	test   %eax,%eax
  800079:	78 47                	js     8000c2 <primeproc+0x8f>
		panic("pipe: %e", i);
	if ((id = fork()) < 0)
  80007b:	e8 15 10 00 00       	call   801095 <fork>
  800080:	85 c0                	test   %eax,%eax
  800082:	78 50                	js     8000d4 <primeproc+0xa1>
		panic("fork: %e", id);
	if (id == 0) {
  800084:	75 60                	jne    8000e6 <primeproc+0xb3>
		close(fd);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	53                   	push   %ebx
  80008a:	e8 2a 13 00 00       	call   8013b9 <close>
		close(pfd[1]);
  80008f:	83 c4 04             	add    $0x4,%esp
  800092:	ff 75 dc             	push   -0x24(%ebp)
  800095:	e8 1f 13 00 00       	call   8013b9 <close>
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
  8000b1:	68 40 27 80 00       	push   $0x802740
  8000b6:	6a 15                	push   $0x15
  8000b8:	68 6f 27 80 00       	push   $0x80276f
  8000bd:	e8 d2 01 00 00       	call   800294 <_panic>
		panic("pipe: %e", i);
  8000c2:	50                   	push   %eax
  8000c3:	68 85 27 80 00       	push   $0x802785
  8000c8:	6a 1b                	push   $0x1b
  8000ca:	68 6f 27 80 00       	push   $0x80276f
  8000cf:	e8 c0 01 00 00       	call   800294 <_panic>
		panic("fork: %e", id);
  8000d4:	50                   	push   %eax
  8000d5:	68 f8 2b 80 00       	push   $0x802bf8
  8000da:	6a 1d                	push   $0x1d
  8000dc:	68 6f 27 80 00       	push   $0x80276f
  8000e1:	e8 ae 01 00 00       	call   800294 <_panic>
	}

	close(pfd[0]);
  8000e6:	83 ec 0c             	sub    $0xc,%esp
  8000e9:	ff 75 d8             	push   -0x28(%ebp)
  8000ec:	e8 c8 12 00 00       	call   8013b9 <close>
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
  800101:	e8 76 14 00 00       	call   80157c <readn>
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
  800120:	e8 9e 14 00 00       	call   8015c3 <write>
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
  80013f:	68 aa 27 80 00       	push   $0x8027aa
  800144:	6a 2e                	push   $0x2e
  800146:	68 6f 27 80 00       	push   $0x80276f
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
  800163:	68 8e 27 80 00       	push   $0x80278e
  800168:	6a 2b                	push   $0x2b
  80016a:	68 6f 27 80 00       	push   $0x80276f
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
  80017b:	c7 05 00 30 80 00 c4 	movl   $0x8027c4,0x803000
  800182:	27 80 00 

	if ((i=pipe(p)) < 0)
  800185:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800188:	50                   	push   %eax
  800189:	e8 a4 1e 00 00       	call   802032 <pipe>
  80018e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800191:	83 c4 10             	add    $0x10,%esp
  800194:	85 c0                	test   %eax,%eax
  800196:	78 21                	js     8001b9 <umain+0x45>
		panic("pipe: %e", i);

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  800198:	e8 f8 0e 00 00       	call   801095 <fork>
  80019d:	85 c0                	test   %eax,%eax
  80019f:	78 2a                	js     8001cb <umain+0x57>
		panic("fork: %e", id);

	if (id == 0) {
  8001a1:	75 3a                	jne    8001dd <umain+0x69>
		close(p[1]);
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	ff 75 f0             	push   -0x10(%ebp)
  8001a9:	e8 0b 12 00 00       	call   8013b9 <close>
		primeproc(p[0]);
  8001ae:	83 c4 04             	add    $0x4,%esp
  8001b1:	ff 75 ec             	push   -0x14(%ebp)
  8001b4:	e8 7a fe ff ff       	call   800033 <primeproc>
		panic("pipe: %e", i);
  8001b9:	50                   	push   %eax
  8001ba:	68 85 27 80 00       	push   $0x802785
  8001bf:	6a 3a                	push   $0x3a
  8001c1:	68 6f 27 80 00       	push   $0x80276f
  8001c6:	e8 c9 00 00 00       	call   800294 <_panic>
		panic("fork: %e", id);
  8001cb:	50                   	push   %eax
  8001cc:	68 f8 2b 80 00       	push   $0x802bf8
  8001d1:	6a 3e                	push   $0x3e
  8001d3:	68 6f 27 80 00       	push   $0x80276f
  8001d8:	e8 b7 00 00 00       	call   800294 <_panic>
	}

	close(p[0]);
  8001dd:	83 ec 0c             	sub    $0xc,%esp
  8001e0:	ff 75 ec             	push   -0x14(%ebp)
  8001e3:	e8 d1 11 00 00       	call   8013b9 <close>
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
  800207:	e8 b7 13 00 00       	call   8015c3 <write>
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
  800223:	68 cf 27 80 00       	push   $0x8027cf
  800228:	6a 4a                	push   $0x4a
  80022a:	68 6f 27 80 00       	push   $0x80276f
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
  800280:	e8 61 11 00 00       	call   8013e6 <close_all>
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
  8002b2:	68 f4 27 80 00       	push   $0x8027f4
  8002b7:	e8 b3 00 00 00       	call   80036f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002bc:	83 c4 18             	add    $0x18,%esp
  8002bf:	53                   	push   %ebx
  8002c0:	ff 75 10             	push   0x10(%ebp)
  8002c3:	e8 56 00 00 00       	call   80031e <vcprintf>
	cprintf("\n");
  8002c8:	c7 04 24 83 27 80 00 	movl   $0x802783,(%esp)
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
  8003d1:	e8 1a 21 00 00       	call   8024f0 <__udivdi3>
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
  80040f:	e8 fc 21 00 00       	call   802610 <__umoddi3>
  800414:	83 c4 14             	add    $0x14,%esp
  800417:	0f be 80 17 28 80 00 	movsbl 0x802817(%eax),%eax
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
  8004d1:	ff 24 85 60 29 80 00 	jmp    *0x802960(,%eax,4)
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
  80059f:	8b 14 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%edx
  8005a6:	85 d2                	test   %edx,%edx
  8005a8:	74 18                	je     8005c2 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8005aa:	52                   	push   %edx
  8005ab:	68 c1 2c 80 00       	push   $0x802cc1
  8005b0:	53                   	push   %ebx
  8005b1:	56                   	push   %esi
  8005b2:	e8 92 fe ff ff       	call   800449 <printfmt>
  8005b7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8005ba:	89 7d 14             	mov    %edi,0x14(%ebp)
  8005bd:	e9 66 02 00 00       	jmp    800828 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8005c2:	50                   	push   %eax
  8005c3:	68 2f 28 80 00       	push   $0x80282f
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
  8005ea:	b8 28 28 80 00       	mov    $0x802828,%eax
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
  800cf6:	68 1f 2b 80 00       	push   $0x802b1f
  800cfb:	6a 2a                	push   $0x2a
  800cfd:	68 3c 2b 80 00       	push   $0x802b3c
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
  800d77:	68 1f 2b 80 00       	push   $0x802b1f
  800d7c:	6a 2a                	push   $0x2a
  800d7e:	68 3c 2b 80 00       	push   $0x802b3c
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
  800db9:	68 1f 2b 80 00       	push   $0x802b1f
  800dbe:	6a 2a                	push   $0x2a
  800dc0:	68 3c 2b 80 00       	push   $0x802b3c
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
  800dfb:	68 1f 2b 80 00       	push   $0x802b1f
  800e00:	6a 2a                	push   $0x2a
  800e02:	68 3c 2b 80 00       	push   $0x802b3c
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
  800e3d:	68 1f 2b 80 00       	push   $0x802b1f
  800e42:	6a 2a                	push   $0x2a
  800e44:	68 3c 2b 80 00       	push   $0x802b3c
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
  800e7f:	68 1f 2b 80 00       	push   $0x802b1f
  800e84:	6a 2a                	push   $0x2a
  800e86:	68 3c 2b 80 00       	push   $0x802b3c
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
  800ec1:	68 1f 2b 80 00       	push   $0x802b1f
  800ec6:	6a 2a                	push   $0x2a
  800ec8:	68 3c 2b 80 00       	push   $0x802b3c
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
  800f25:	68 1f 2b 80 00       	push   $0x802b1f
  800f2a:	6a 2a                	push   $0x2a
  800f2c:	68 3c 2b 80 00       	push   $0x802b3c
  800f31:	e8 5e f3 ff ff       	call   800294 <_panic>

00800f36 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	57                   	push   %edi
  800f3a:	56                   	push   %esi
  800f3b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800f41:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f46:	89 d1                	mov    %edx,%ecx
  800f48:	89 d3                	mov    %edx,%ebx
  800f4a:	89 d7                	mov    %edx,%edi
  800f4c:	89 d6                	mov    %edx,%esi
  800f4e:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f50:	5b                   	pop    %ebx
  800f51:	5e                   	pop    %esi
  800f52:	5f                   	pop    %edi
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    

00800f55 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	57                   	push   %edi
  800f59:	56                   	push   %esi
  800f5a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f5b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f60:	8b 55 08             	mov    0x8(%ebp),%edx
  800f63:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f66:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f6b:	89 df                	mov    %ebx,%edi
  800f6d:	89 de                	mov    %ebx,%esi
  800f6f:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800f71:	5b                   	pop    %ebx
  800f72:	5e                   	pop    %esi
  800f73:	5f                   	pop    %edi
  800f74:	5d                   	pop    %ebp
  800f75:	c3                   	ret    

00800f76 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800f76:	55                   	push   %ebp
  800f77:	89 e5                	mov    %esp,%ebp
  800f79:	57                   	push   %edi
  800f7a:	56                   	push   %esi
  800f7b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f7c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f81:	8b 55 08             	mov    0x8(%ebp),%edx
  800f84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f87:	b8 10 00 00 00       	mov    $0x10,%eax
  800f8c:	89 df                	mov    %ebx,%edi
  800f8e:	89 de                	mov    %ebx,%esi
  800f90:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800f92:	5b                   	pop    %ebx
  800f93:	5e                   	pop    %esi
  800f94:	5f                   	pop    %edi
  800f95:	5d                   	pop    %ebp
  800f96:	c3                   	ret    

00800f97 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f97:	55                   	push   %ebp
  800f98:	89 e5                	mov    %esp,%ebp
  800f9a:	56                   	push   %esi
  800f9b:	53                   	push   %ebx
  800f9c:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f9f:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800fa1:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fa5:	0f 84 8e 00 00 00    	je     801039 <pgfault+0xa2>
  800fab:	89 f0                	mov    %esi,%eax
  800fad:	c1 e8 0c             	shr    $0xc,%eax
  800fb0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb7:	f6 c4 08             	test   $0x8,%ah
  800fba:	74 7d                	je     801039 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800fbc:	e8 46 fd ff ff       	call   800d07 <sys_getenvid>
  800fc1:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800fc3:	83 ec 04             	sub    $0x4,%esp
  800fc6:	6a 07                	push   $0x7
  800fc8:	68 00 f0 7f 00       	push   $0x7ff000
  800fcd:	50                   	push   %eax
  800fce:	e8 72 fd ff ff       	call   800d45 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800fd3:	83 c4 10             	add    $0x10,%esp
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	78 73                	js     80104d <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800fda:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800fe0:	83 ec 04             	sub    $0x4,%esp
  800fe3:	68 00 10 00 00       	push   $0x1000
  800fe8:	56                   	push   %esi
  800fe9:	68 00 f0 7f 00       	push   $0x7ff000
  800fee:	e8 ec fa ff ff       	call   800adf <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800ff3:	83 c4 08             	add    $0x8,%esp
  800ff6:	56                   	push   %esi
  800ff7:	53                   	push   %ebx
  800ff8:	e8 cd fd ff ff       	call   800dca <sys_page_unmap>
  800ffd:	83 c4 10             	add    $0x10,%esp
  801000:	85 c0                	test   %eax,%eax
  801002:	78 5b                	js     80105f <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  801004:	83 ec 0c             	sub    $0xc,%esp
  801007:	6a 07                	push   $0x7
  801009:	56                   	push   %esi
  80100a:	53                   	push   %ebx
  80100b:	68 00 f0 7f 00       	push   $0x7ff000
  801010:	53                   	push   %ebx
  801011:	e8 72 fd ff ff       	call   800d88 <sys_page_map>
  801016:	83 c4 20             	add    $0x20,%esp
  801019:	85 c0                	test   %eax,%eax
  80101b:	78 54                	js     801071 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  80101d:	83 ec 08             	sub    $0x8,%esp
  801020:	68 00 f0 7f 00       	push   $0x7ff000
  801025:	53                   	push   %ebx
  801026:	e8 9f fd ff ff       	call   800dca <sys_page_unmap>
  80102b:	83 c4 10             	add    $0x10,%esp
  80102e:	85 c0                	test   %eax,%eax
  801030:	78 51                	js     801083 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  801032:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801035:	5b                   	pop    %ebx
  801036:	5e                   	pop    %esi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  801039:	83 ec 04             	sub    $0x4,%esp
  80103c:	68 4c 2b 80 00       	push   $0x802b4c
  801041:	6a 1d                	push   $0x1d
  801043:	68 c8 2b 80 00       	push   $0x802bc8
  801048:	e8 47 f2 ff ff       	call   800294 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  80104d:	50                   	push   %eax
  80104e:	68 84 2b 80 00       	push   $0x802b84
  801053:	6a 29                	push   $0x29
  801055:	68 c8 2b 80 00       	push   $0x802bc8
  80105a:	e8 35 f2 ff ff       	call   800294 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  80105f:	50                   	push   %eax
  801060:	68 a8 2b 80 00       	push   $0x802ba8
  801065:	6a 2e                	push   $0x2e
  801067:	68 c8 2b 80 00       	push   $0x802bc8
  80106c:	e8 23 f2 ff ff       	call   800294 <_panic>
		panic("pgfault: page map failed (%e)", r);
  801071:	50                   	push   %eax
  801072:	68 d3 2b 80 00       	push   $0x802bd3
  801077:	6a 30                	push   $0x30
  801079:	68 c8 2b 80 00       	push   $0x802bc8
  80107e:	e8 11 f2 ff ff       	call   800294 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  801083:	50                   	push   %eax
  801084:	68 a8 2b 80 00       	push   $0x802ba8
  801089:	6a 32                	push   $0x32
  80108b:	68 c8 2b 80 00       	push   $0x802bc8
  801090:	e8 ff f1 ff ff       	call   800294 <_panic>

00801095 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	57                   	push   %edi
  801099:	56                   	push   %esi
  80109a:	53                   	push   %ebx
  80109b:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  80109e:	68 97 0f 80 00       	push   $0x800f97
  8010a3:	e8 7b 12 00 00       	call   802323 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010a8:	b8 07 00 00 00       	mov    $0x7,%eax
  8010ad:	cd 30                	int    $0x30
  8010af:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  8010b2:	83 c4 10             	add    $0x10,%esp
  8010b5:	85 c0                	test   %eax,%eax
  8010b7:	78 2d                	js     8010e6 <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  8010b9:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  8010be:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8010c2:	75 73                	jne    801137 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010c4:	e8 3e fc ff ff       	call   800d07 <sys_getenvid>
  8010c9:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010ce:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010d1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010d6:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  8010db:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  8010de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e1:	5b                   	pop    %ebx
  8010e2:	5e                   	pop    %esi
  8010e3:	5f                   	pop    %edi
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  8010e6:	50                   	push   %eax
  8010e7:	68 f1 2b 80 00       	push   $0x802bf1
  8010ec:	6a 78                	push   $0x78
  8010ee:	68 c8 2b 80 00       	push   $0x802bc8
  8010f3:	e8 9c f1 ff ff       	call   800294 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  8010f8:	83 ec 0c             	sub    $0xc,%esp
  8010fb:	ff 75 e4             	push   -0x1c(%ebp)
  8010fe:	57                   	push   %edi
  8010ff:	ff 75 dc             	push   -0x24(%ebp)
  801102:	57                   	push   %edi
  801103:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801106:	56                   	push   %esi
  801107:	e8 7c fc ff ff       	call   800d88 <sys_page_map>
	if(r<0) return r;
  80110c:	83 c4 20             	add    $0x20,%esp
  80110f:	85 c0                	test   %eax,%eax
  801111:	78 cb                	js     8010de <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  801113:	83 ec 0c             	sub    $0xc,%esp
  801116:	ff 75 e4             	push   -0x1c(%ebp)
  801119:	57                   	push   %edi
  80111a:	56                   	push   %esi
  80111b:	57                   	push   %edi
  80111c:	56                   	push   %esi
  80111d:	e8 66 fc ff ff       	call   800d88 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  801122:	83 c4 20             	add    $0x20,%esp
  801125:	85 c0                	test   %eax,%eax
  801127:	78 76                	js     80119f <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801129:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80112f:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  801135:	74 75                	je     8011ac <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  801137:	89 d8                	mov    %ebx,%eax
  801139:	c1 e8 16             	shr    $0x16,%eax
  80113c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801143:	a8 01                	test   $0x1,%al
  801145:	74 e2                	je     801129 <fork+0x94>
  801147:	89 de                	mov    %ebx,%esi
  801149:	c1 ee 0c             	shr    $0xc,%esi
  80114c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801153:	a8 01                	test   $0x1,%al
  801155:	74 d2                	je     801129 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  801157:	e8 ab fb ff ff       	call   800d07 <sys_getenvid>
  80115c:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  80115f:	89 f7                	mov    %esi,%edi
  801161:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  801164:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80116b:	89 c1                	mov    %eax,%ecx
  80116d:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801173:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  801176:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  80117d:	f6 c6 04             	test   $0x4,%dh
  801180:	0f 85 72 ff ff ff    	jne    8010f8 <fork+0x63>
		perm &= ~PTE_W;
  801186:	25 05 0e 00 00       	and    $0xe05,%eax
  80118b:	80 cc 08             	or     $0x8,%ah
  80118e:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  801194:	0f 44 c1             	cmove  %ecx,%eax
  801197:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80119a:	e9 59 ff ff ff       	jmp    8010f8 <fork+0x63>
  80119f:	ba 00 00 00 00       	mov    $0x0,%edx
  8011a4:	0f 4f c2             	cmovg  %edx,%eax
  8011a7:	e9 32 ff ff ff       	jmp    8010de <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  8011ac:	83 ec 04             	sub    $0x4,%esp
  8011af:	6a 07                	push   $0x7
  8011b1:	68 00 f0 bf ee       	push   $0xeebff000
  8011b6:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8011b9:	57                   	push   %edi
  8011ba:	e8 86 fb ff ff       	call   800d45 <sys_page_alloc>
	if(r<0) return r;
  8011bf:	83 c4 10             	add    $0x10,%esp
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	0f 88 14 ff ff ff    	js     8010de <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8011ca:	83 ec 08             	sub    $0x8,%esp
  8011cd:	68 99 23 80 00       	push   $0x802399
  8011d2:	57                   	push   %edi
  8011d3:	e8 b8 fc ff ff       	call   800e90 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  8011d8:	83 c4 10             	add    $0x10,%esp
  8011db:	85 c0                	test   %eax,%eax
  8011dd:	0f 88 fb fe ff ff    	js     8010de <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8011e3:	83 ec 08             	sub    $0x8,%esp
  8011e6:	6a 02                	push   $0x2
  8011e8:	57                   	push   %edi
  8011e9:	e8 1e fc ff ff       	call   800e0c <sys_env_set_status>
	if(r<0) return r;
  8011ee:	83 c4 10             	add    $0x10,%esp
	return envid;
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	0f 49 c7             	cmovns %edi,%eax
  8011f6:	e9 e3 fe ff ff       	jmp    8010de <fork+0x49>

008011fb <sfork>:

// Challenge!
int
sfork(void)
{
  8011fb:	55                   	push   %ebp
  8011fc:	89 e5                	mov    %esp,%ebp
  8011fe:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801201:	68 01 2c 80 00       	push   $0x802c01
  801206:	68 a1 00 00 00       	push   $0xa1
  80120b:	68 c8 2b 80 00       	push   $0x802bc8
  801210:	e8 7f f0 ff ff       	call   800294 <_panic>

00801215 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801218:	8b 45 08             	mov    0x8(%ebp),%eax
  80121b:	05 00 00 00 30       	add    $0x30000000,%eax
  801220:	c1 e8 0c             	shr    $0xc,%eax
}
  801223:	5d                   	pop    %ebp
  801224:	c3                   	ret    

00801225 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801228:	8b 45 08             	mov    0x8(%ebp),%eax
  80122b:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801230:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801235:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80123a:	5d                   	pop    %ebp
  80123b:	c3                   	ret    

0080123c <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801244:	89 c2                	mov    %eax,%edx
  801246:	c1 ea 16             	shr    $0x16,%edx
  801249:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801250:	f6 c2 01             	test   $0x1,%dl
  801253:	74 29                	je     80127e <fd_alloc+0x42>
  801255:	89 c2                	mov    %eax,%edx
  801257:	c1 ea 0c             	shr    $0xc,%edx
  80125a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801261:	f6 c2 01             	test   $0x1,%dl
  801264:	74 18                	je     80127e <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801266:	05 00 10 00 00       	add    $0x1000,%eax
  80126b:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801270:	75 d2                	jne    801244 <fd_alloc+0x8>
  801272:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801277:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80127c:	eb 05                	jmp    801283 <fd_alloc+0x47>
			return 0;
  80127e:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801283:	8b 55 08             	mov    0x8(%ebp),%edx
  801286:	89 02                	mov    %eax,(%edx)
}
  801288:	89 c8                	mov    %ecx,%eax
  80128a:	5d                   	pop    %ebp
  80128b:	c3                   	ret    

0080128c <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80128c:	55                   	push   %ebp
  80128d:	89 e5                	mov    %esp,%ebp
  80128f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801292:	83 f8 1f             	cmp    $0x1f,%eax
  801295:	77 30                	ja     8012c7 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801297:	c1 e0 0c             	shl    $0xc,%eax
  80129a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80129f:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8012a5:	f6 c2 01             	test   $0x1,%dl
  8012a8:	74 24                	je     8012ce <fd_lookup+0x42>
  8012aa:	89 c2                	mov    %eax,%edx
  8012ac:	c1 ea 0c             	shr    $0xc,%edx
  8012af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012b6:	f6 c2 01             	test   $0x1,%dl
  8012b9:	74 1a                	je     8012d5 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012be:	89 02                	mov    %eax,(%edx)
	return 0;
  8012c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012c5:	5d                   	pop    %ebp
  8012c6:	c3                   	ret    
		return -E_INVAL;
  8012c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012cc:	eb f7                	jmp    8012c5 <fd_lookup+0x39>
		return -E_INVAL;
  8012ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d3:	eb f0                	jmp    8012c5 <fd_lookup+0x39>
  8012d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012da:	eb e9                	jmp    8012c5 <fd_lookup+0x39>

008012dc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012dc:	55                   	push   %ebp
  8012dd:	89 e5                	mov    %esp,%ebp
  8012df:	53                   	push   %ebx
  8012e0:	83 ec 04             	sub    $0x4,%esp
  8012e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012eb:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8012f0:	39 13                	cmp    %edx,(%ebx)
  8012f2:	74 37                	je     80132b <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8012f4:	83 c0 01             	add    $0x1,%eax
  8012f7:	8b 1c 85 94 2c 80 00 	mov    0x802c94(,%eax,4),%ebx
  8012fe:	85 db                	test   %ebx,%ebx
  801300:	75 ee                	jne    8012f0 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801302:	a1 00 40 80 00       	mov    0x804000,%eax
  801307:	8b 40 48             	mov    0x48(%eax),%eax
  80130a:	83 ec 04             	sub    $0x4,%esp
  80130d:	52                   	push   %edx
  80130e:	50                   	push   %eax
  80130f:	68 18 2c 80 00       	push   $0x802c18
  801314:	e8 56 f0 ff ff       	call   80036f <cprintf>
	*dev = 0;
	return -E_INVAL;
  801319:	83 c4 10             	add    $0x10,%esp
  80131c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801321:	8b 55 0c             	mov    0xc(%ebp),%edx
  801324:	89 1a                	mov    %ebx,(%edx)
}
  801326:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801329:	c9                   	leave  
  80132a:	c3                   	ret    
			return 0;
  80132b:	b8 00 00 00 00       	mov    $0x0,%eax
  801330:	eb ef                	jmp    801321 <dev_lookup+0x45>

00801332 <fd_close>:
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	57                   	push   %edi
  801336:	56                   	push   %esi
  801337:	53                   	push   %ebx
  801338:	83 ec 24             	sub    $0x24,%esp
  80133b:	8b 75 08             	mov    0x8(%ebp),%esi
  80133e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801341:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801344:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801345:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80134b:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80134e:	50                   	push   %eax
  80134f:	e8 38 ff ff ff       	call   80128c <fd_lookup>
  801354:	89 c3                	mov    %eax,%ebx
  801356:	83 c4 10             	add    $0x10,%esp
  801359:	85 c0                	test   %eax,%eax
  80135b:	78 05                	js     801362 <fd_close+0x30>
	    || fd != fd2)
  80135d:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801360:	74 16                	je     801378 <fd_close+0x46>
		return (must_exist ? r : 0);
  801362:	89 f8                	mov    %edi,%eax
  801364:	84 c0                	test   %al,%al
  801366:	b8 00 00 00 00       	mov    $0x0,%eax
  80136b:	0f 44 d8             	cmove  %eax,%ebx
}
  80136e:	89 d8                	mov    %ebx,%eax
  801370:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801373:	5b                   	pop    %ebx
  801374:	5e                   	pop    %esi
  801375:	5f                   	pop    %edi
  801376:	5d                   	pop    %ebp
  801377:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801378:	83 ec 08             	sub    $0x8,%esp
  80137b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80137e:	50                   	push   %eax
  80137f:	ff 36                	push   (%esi)
  801381:	e8 56 ff ff ff       	call   8012dc <dev_lookup>
  801386:	89 c3                	mov    %eax,%ebx
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	85 c0                	test   %eax,%eax
  80138d:	78 1a                	js     8013a9 <fd_close+0x77>
		if (dev->dev_close)
  80138f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801392:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801395:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80139a:	85 c0                	test   %eax,%eax
  80139c:	74 0b                	je     8013a9 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80139e:	83 ec 0c             	sub    $0xc,%esp
  8013a1:	56                   	push   %esi
  8013a2:	ff d0                	call   *%eax
  8013a4:	89 c3                	mov    %eax,%ebx
  8013a6:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013a9:	83 ec 08             	sub    $0x8,%esp
  8013ac:	56                   	push   %esi
  8013ad:	6a 00                	push   $0x0
  8013af:	e8 16 fa ff ff       	call   800dca <sys_page_unmap>
	return r;
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	eb b5                	jmp    80136e <fd_close+0x3c>

008013b9 <close>:

int
close(int fdnum)
{
  8013b9:	55                   	push   %ebp
  8013ba:	89 e5                	mov    %esp,%ebp
  8013bc:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c2:	50                   	push   %eax
  8013c3:	ff 75 08             	push   0x8(%ebp)
  8013c6:	e8 c1 fe ff ff       	call   80128c <fd_lookup>
  8013cb:	83 c4 10             	add    $0x10,%esp
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	79 02                	jns    8013d4 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8013d2:	c9                   	leave  
  8013d3:	c3                   	ret    
		return fd_close(fd, 1);
  8013d4:	83 ec 08             	sub    $0x8,%esp
  8013d7:	6a 01                	push   $0x1
  8013d9:	ff 75 f4             	push   -0xc(%ebp)
  8013dc:	e8 51 ff ff ff       	call   801332 <fd_close>
  8013e1:	83 c4 10             	add    $0x10,%esp
  8013e4:	eb ec                	jmp    8013d2 <close+0x19>

008013e6 <close_all>:

void
close_all(void)
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	53                   	push   %ebx
  8013ea:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013ed:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013f2:	83 ec 0c             	sub    $0xc,%esp
  8013f5:	53                   	push   %ebx
  8013f6:	e8 be ff ff ff       	call   8013b9 <close>
	for (i = 0; i < MAXFD; i++)
  8013fb:	83 c3 01             	add    $0x1,%ebx
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	83 fb 20             	cmp    $0x20,%ebx
  801404:	75 ec                	jne    8013f2 <close_all+0xc>
}
  801406:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801409:	c9                   	leave  
  80140a:	c3                   	ret    

0080140b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	57                   	push   %edi
  80140f:	56                   	push   %esi
  801410:	53                   	push   %ebx
  801411:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801414:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801417:	50                   	push   %eax
  801418:	ff 75 08             	push   0x8(%ebp)
  80141b:	e8 6c fe ff ff       	call   80128c <fd_lookup>
  801420:	89 c3                	mov    %eax,%ebx
  801422:	83 c4 10             	add    $0x10,%esp
  801425:	85 c0                	test   %eax,%eax
  801427:	78 7f                	js     8014a8 <dup+0x9d>
		return r;
	close(newfdnum);
  801429:	83 ec 0c             	sub    $0xc,%esp
  80142c:	ff 75 0c             	push   0xc(%ebp)
  80142f:	e8 85 ff ff ff       	call   8013b9 <close>

	newfd = INDEX2FD(newfdnum);
  801434:	8b 75 0c             	mov    0xc(%ebp),%esi
  801437:	c1 e6 0c             	shl    $0xc,%esi
  80143a:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801440:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801443:	89 3c 24             	mov    %edi,(%esp)
  801446:	e8 da fd ff ff       	call   801225 <fd2data>
  80144b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80144d:	89 34 24             	mov    %esi,(%esp)
  801450:	e8 d0 fd ff ff       	call   801225 <fd2data>
  801455:	83 c4 10             	add    $0x10,%esp
  801458:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80145b:	89 d8                	mov    %ebx,%eax
  80145d:	c1 e8 16             	shr    $0x16,%eax
  801460:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801467:	a8 01                	test   $0x1,%al
  801469:	74 11                	je     80147c <dup+0x71>
  80146b:	89 d8                	mov    %ebx,%eax
  80146d:	c1 e8 0c             	shr    $0xc,%eax
  801470:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801477:	f6 c2 01             	test   $0x1,%dl
  80147a:	75 36                	jne    8014b2 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80147c:	89 f8                	mov    %edi,%eax
  80147e:	c1 e8 0c             	shr    $0xc,%eax
  801481:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801488:	83 ec 0c             	sub    $0xc,%esp
  80148b:	25 07 0e 00 00       	and    $0xe07,%eax
  801490:	50                   	push   %eax
  801491:	56                   	push   %esi
  801492:	6a 00                	push   $0x0
  801494:	57                   	push   %edi
  801495:	6a 00                	push   $0x0
  801497:	e8 ec f8 ff ff       	call   800d88 <sys_page_map>
  80149c:	89 c3                	mov    %eax,%ebx
  80149e:	83 c4 20             	add    $0x20,%esp
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	78 33                	js     8014d8 <dup+0xcd>
		goto err;

	return newfdnum;
  8014a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014a8:	89 d8                	mov    %ebx,%eax
  8014aa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014ad:	5b                   	pop    %ebx
  8014ae:	5e                   	pop    %esi
  8014af:	5f                   	pop    %edi
  8014b0:	5d                   	pop    %ebp
  8014b1:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014b9:	83 ec 0c             	sub    $0xc,%esp
  8014bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c1:	50                   	push   %eax
  8014c2:	ff 75 d4             	push   -0x2c(%ebp)
  8014c5:	6a 00                	push   $0x0
  8014c7:	53                   	push   %ebx
  8014c8:	6a 00                	push   $0x0
  8014ca:	e8 b9 f8 ff ff       	call   800d88 <sys_page_map>
  8014cf:	89 c3                	mov    %eax,%ebx
  8014d1:	83 c4 20             	add    $0x20,%esp
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	79 a4                	jns    80147c <dup+0x71>
	sys_page_unmap(0, newfd);
  8014d8:	83 ec 08             	sub    $0x8,%esp
  8014db:	56                   	push   %esi
  8014dc:	6a 00                	push   $0x0
  8014de:	e8 e7 f8 ff ff       	call   800dca <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014e3:	83 c4 08             	add    $0x8,%esp
  8014e6:	ff 75 d4             	push   -0x2c(%ebp)
  8014e9:	6a 00                	push   $0x0
  8014eb:	e8 da f8 ff ff       	call   800dca <sys_page_unmap>
	return r;
  8014f0:	83 c4 10             	add    $0x10,%esp
  8014f3:	eb b3                	jmp    8014a8 <dup+0x9d>

008014f5 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014f5:	55                   	push   %ebp
  8014f6:	89 e5                	mov    %esp,%ebp
  8014f8:	56                   	push   %esi
  8014f9:	53                   	push   %ebx
  8014fa:	83 ec 18             	sub    $0x18,%esp
  8014fd:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801500:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801503:	50                   	push   %eax
  801504:	56                   	push   %esi
  801505:	e8 82 fd ff ff       	call   80128c <fd_lookup>
  80150a:	83 c4 10             	add    $0x10,%esp
  80150d:	85 c0                	test   %eax,%eax
  80150f:	78 3c                	js     80154d <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801511:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801514:	83 ec 08             	sub    $0x8,%esp
  801517:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151a:	50                   	push   %eax
  80151b:	ff 33                	push   (%ebx)
  80151d:	e8 ba fd ff ff       	call   8012dc <dev_lookup>
  801522:	83 c4 10             	add    $0x10,%esp
  801525:	85 c0                	test   %eax,%eax
  801527:	78 24                	js     80154d <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801529:	8b 43 08             	mov    0x8(%ebx),%eax
  80152c:	83 e0 03             	and    $0x3,%eax
  80152f:	83 f8 01             	cmp    $0x1,%eax
  801532:	74 20                	je     801554 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801534:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801537:	8b 40 08             	mov    0x8(%eax),%eax
  80153a:	85 c0                	test   %eax,%eax
  80153c:	74 37                	je     801575 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80153e:	83 ec 04             	sub    $0x4,%esp
  801541:	ff 75 10             	push   0x10(%ebp)
  801544:	ff 75 0c             	push   0xc(%ebp)
  801547:	53                   	push   %ebx
  801548:	ff d0                	call   *%eax
  80154a:	83 c4 10             	add    $0x10,%esp
}
  80154d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801550:	5b                   	pop    %ebx
  801551:	5e                   	pop    %esi
  801552:	5d                   	pop    %ebp
  801553:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801554:	a1 00 40 80 00       	mov    0x804000,%eax
  801559:	8b 40 48             	mov    0x48(%eax),%eax
  80155c:	83 ec 04             	sub    $0x4,%esp
  80155f:	56                   	push   %esi
  801560:	50                   	push   %eax
  801561:	68 59 2c 80 00       	push   $0x802c59
  801566:	e8 04 ee ff ff       	call   80036f <cprintf>
		return -E_INVAL;
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801573:	eb d8                	jmp    80154d <read+0x58>
		return -E_NOT_SUPP;
  801575:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80157a:	eb d1                	jmp    80154d <read+0x58>

0080157c <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	57                   	push   %edi
  801580:	56                   	push   %esi
  801581:	53                   	push   %ebx
  801582:	83 ec 0c             	sub    $0xc,%esp
  801585:	8b 7d 08             	mov    0x8(%ebp),%edi
  801588:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80158b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801590:	eb 02                	jmp    801594 <readn+0x18>
  801592:	01 c3                	add    %eax,%ebx
  801594:	39 f3                	cmp    %esi,%ebx
  801596:	73 21                	jae    8015b9 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801598:	83 ec 04             	sub    $0x4,%esp
  80159b:	89 f0                	mov    %esi,%eax
  80159d:	29 d8                	sub    %ebx,%eax
  80159f:	50                   	push   %eax
  8015a0:	89 d8                	mov    %ebx,%eax
  8015a2:	03 45 0c             	add    0xc(%ebp),%eax
  8015a5:	50                   	push   %eax
  8015a6:	57                   	push   %edi
  8015a7:	e8 49 ff ff ff       	call   8014f5 <read>
		if (m < 0)
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 04                	js     8015b7 <readn+0x3b>
			return m;
		if (m == 0)
  8015b3:	75 dd                	jne    801592 <readn+0x16>
  8015b5:	eb 02                	jmp    8015b9 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015b7:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8015b9:	89 d8                	mov    %ebx,%eax
  8015bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015be:	5b                   	pop    %ebx
  8015bf:	5e                   	pop    %esi
  8015c0:	5f                   	pop    %edi
  8015c1:	5d                   	pop    %ebp
  8015c2:	c3                   	ret    

008015c3 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015c3:	55                   	push   %ebp
  8015c4:	89 e5                	mov    %esp,%ebp
  8015c6:	56                   	push   %esi
  8015c7:	53                   	push   %ebx
  8015c8:	83 ec 18             	sub    $0x18,%esp
  8015cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d1:	50                   	push   %eax
  8015d2:	53                   	push   %ebx
  8015d3:	e8 b4 fc ff ff       	call   80128c <fd_lookup>
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	85 c0                	test   %eax,%eax
  8015dd:	78 37                	js     801616 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015df:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015e2:	83 ec 08             	sub    $0x8,%esp
  8015e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e8:	50                   	push   %eax
  8015e9:	ff 36                	push   (%esi)
  8015eb:	e8 ec fc ff ff       	call   8012dc <dev_lookup>
  8015f0:	83 c4 10             	add    $0x10,%esp
  8015f3:	85 c0                	test   %eax,%eax
  8015f5:	78 1f                	js     801616 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015f7:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8015fb:	74 20                	je     80161d <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8015fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801600:	8b 40 0c             	mov    0xc(%eax),%eax
  801603:	85 c0                	test   %eax,%eax
  801605:	74 37                	je     80163e <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801607:	83 ec 04             	sub    $0x4,%esp
  80160a:	ff 75 10             	push   0x10(%ebp)
  80160d:	ff 75 0c             	push   0xc(%ebp)
  801610:	56                   	push   %esi
  801611:	ff d0                	call   *%eax
  801613:	83 c4 10             	add    $0x10,%esp
}
  801616:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801619:	5b                   	pop    %ebx
  80161a:	5e                   	pop    %esi
  80161b:	5d                   	pop    %ebp
  80161c:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80161d:	a1 00 40 80 00       	mov    0x804000,%eax
  801622:	8b 40 48             	mov    0x48(%eax),%eax
  801625:	83 ec 04             	sub    $0x4,%esp
  801628:	53                   	push   %ebx
  801629:	50                   	push   %eax
  80162a:	68 75 2c 80 00       	push   $0x802c75
  80162f:	e8 3b ed ff ff       	call   80036f <cprintf>
		return -E_INVAL;
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80163c:	eb d8                	jmp    801616 <write+0x53>
		return -E_NOT_SUPP;
  80163e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801643:	eb d1                	jmp    801616 <write+0x53>

00801645 <seek>:

int
seek(int fdnum, off_t offset)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80164b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80164e:	50                   	push   %eax
  80164f:	ff 75 08             	push   0x8(%ebp)
  801652:	e8 35 fc ff ff       	call   80128c <fd_lookup>
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	85 c0                	test   %eax,%eax
  80165c:	78 0e                	js     80166c <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80165e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801661:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801664:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801667:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80166c:	c9                   	leave  
  80166d:	c3                   	ret    

0080166e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	56                   	push   %esi
  801672:	53                   	push   %ebx
  801673:	83 ec 18             	sub    $0x18,%esp
  801676:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801679:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167c:	50                   	push   %eax
  80167d:	53                   	push   %ebx
  80167e:	e8 09 fc ff ff       	call   80128c <fd_lookup>
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	85 c0                	test   %eax,%eax
  801688:	78 34                	js     8016be <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80168a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80168d:	83 ec 08             	sub    $0x8,%esp
  801690:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801693:	50                   	push   %eax
  801694:	ff 36                	push   (%esi)
  801696:	e8 41 fc ff ff       	call   8012dc <dev_lookup>
  80169b:	83 c4 10             	add    $0x10,%esp
  80169e:	85 c0                	test   %eax,%eax
  8016a0:	78 1c                	js     8016be <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016a2:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8016a6:	74 1d                	je     8016c5 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8016a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ab:	8b 40 18             	mov    0x18(%eax),%eax
  8016ae:	85 c0                	test   %eax,%eax
  8016b0:	74 34                	je     8016e6 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016b2:	83 ec 08             	sub    $0x8,%esp
  8016b5:	ff 75 0c             	push   0xc(%ebp)
  8016b8:	56                   	push   %esi
  8016b9:	ff d0                	call   *%eax
  8016bb:	83 c4 10             	add    $0x10,%esp
}
  8016be:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c1:	5b                   	pop    %ebx
  8016c2:	5e                   	pop    %esi
  8016c3:	5d                   	pop    %ebp
  8016c4:	c3                   	ret    
			thisenv->env_id, fdnum);
  8016c5:	a1 00 40 80 00       	mov    0x804000,%eax
  8016ca:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016cd:	83 ec 04             	sub    $0x4,%esp
  8016d0:	53                   	push   %ebx
  8016d1:	50                   	push   %eax
  8016d2:	68 38 2c 80 00       	push   $0x802c38
  8016d7:	e8 93 ec ff ff       	call   80036f <cprintf>
		return -E_INVAL;
  8016dc:	83 c4 10             	add    $0x10,%esp
  8016df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016e4:	eb d8                	jmp    8016be <ftruncate+0x50>
		return -E_NOT_SUPP;
  8016e6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016eb:	eb d1                	jmp    8016be <ftruncate+0x50>

008016ed <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
  8016f0:	56                   	push   %esi
  8016f1:	53                   	push   %ebx
  8016f2:	83 ec 18             	sub    $0x18,%esp
  8016f5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fb:	50                   	push   %eax
  8016fc:	ff 75 08             	push   0x8(%ebp)
  8016ff:	e8 88 fb ff ff       	call   80128c <fd_lookup>
  801704:	83 c4 10             	add    $0x10,%esp
  801707:	85 c0                	test   %eax,%eax
  801709:	78 49                	js     801754 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170b:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80170e:	83 ec 08             	sub    $0x8,%esp
  801711:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801714:	50                   	push   %eax
  801715:	ff 36                	push   (%esi)
  801717:	e8 c0 fb ff ff       	call   8012dc <dev_lookup>
  80171c:	83 c4 10             	add    $0x10,%esp
  80171f:	85 c0                	test   %eax,%eax
  801721:	78 31                	js     801754 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801723:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801726:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80172a:	74 2f                	je     80175b <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80172c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80172f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801736:	00 00 00 
	stat->st_isdir = 0;
  801739:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801740:	00 00 00 
	stat->st_dev = dev;
  801743:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801749:	83 ec 08             	sub    $0x8,%esp
  80174c:	53                   	push   %ebx
  80174d:	56                   	push   %esi
  80174e:	ff 50 14             	call   *0x14(%eax)
  801751:	83 c4 10             	add    $0x10,%esp
}
  801754:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801757:	5b                   	pop    %ebx
  801758:	5e                   	pop    %esi
  801759:	5d                   	pop    %ebp
  80175a:	c3                   	ret    
		return -E_NOT_SUPP;
  80175b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801760:	eb f2                	jmp    801754 <fstat+0x67>

00801762 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	56                   	push   %esi
  801766:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801767:	83 ec 08             	sub    $0x8,%esp
  80176a:	6a 00                	push   $0x0
  80176c:	ff 75 08             	push   0x8(%ebp)
  80176f:	e8 e4 01 00 00       	call   801958 <open>
  801774:	89 c3                	mov    %eax,%ebx
  801776:	83 c4 10             	add    $0x10,%esp
  801779:	85 c0                	test   %eax,%eax
  80177b:	78 1b                	js     801798 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80177d:	83 ec 08             	sub    $0x8,%esp
  801780:	ff 75 0c             	push   0xc(%ebp)
  801783:	50                   	push   %eax
  801784:	e8 64 ff ff ff       	call   8016ed <fstat>
  801789:	89 c6                	mov    %eax,%esi
	close(fd);
  80178b:	89 1c 24             	mov    %ebx,(%esp)
  80178e:	e8 26 fc ff ff       	call   8013b9 <close>
	return r;
  801793:	83 c4 10             	add    $0x10,%esp
  801796:	89 f3                	mov    %esi,%ebx
}
  801798:	89 d8                	mov    %ebx,%eax
  80179a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80179d:	5b                   	pop    %ebx
  80179e:	5e                   	pop    %esi
  80179f:	5d                   	pop    %ebp
  8017a0:	c3                   	ret    

008017a1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	56                   	push   %esi
  8017a5:	53                   	push   %ebx
  8017a6:	89 c6                	mov    %eax,%esi
  8017a8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017aa:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8017b1:	74 27                	je     8017da <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017b3:	6a 07                	push   $0x7
  8017b5:	68 00 50 80 00       	push   $0x805000
  8017ba:	56                   	push   %esi
  8017bb:	ff 35 00 60 80 00    	push   0x806000
  8017c1:	e8 60 0c 00 00       	call   802426 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017c6:	83 c4 0c             	add    $0xc,%esp
  8017c9:	6a 00                	push   $0x0
  8017cb:	53                   	push   %ebx
  8017cc:	6a 00                	push   $0x0
  8017ce:	e8 ec 0b 00 00       	call   8023bf <ipc_recv>
}
  8017d3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017d6:	5b                   	pop    %ebx
  8017d7:	5e                   	pop    %esi
  8017d8:	5d                   	pop    %ebp
  8017d9:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017da:	83 ec 0c             	sub    $0xc,%esp
  8017dd:	6a 01                	push   $0x1
  8017df:	e8 96 0c 00 00       	call   80247a <ipc_find_env>
  8017e4:	a3 00 60 80 00       	mov    %eax,0x806000
  8017e9:	83 c4 10             	add    $0x10,%esp
  8017ec:	eb c5                	jmp    8017b3 <fsipc+0x12>

008017ee <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8017fa:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801802:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801807:	ba 00 00 00 00       	mov    $0x0,%edx
  80180c:	b8 02 00 00 00       	mov    $0x2,%eax
  801811:	e8 8b ff ff ff       	call   8017a1 <fsipc>
}
  801816:	c9                   	leave  
  801817:	c3                   	ret    

00801818 <devfile_flush>:
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80181e:	8b 45 08             	mov    0x8(%ebp),%eax
  801821:	8b 40 0c             	mov    0xc(%eax),%eax
  801824:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801829:	ba 00 00 00 00       	mov    $0x0,%edx
  80182e:	b8 06 00 00 00       	mov    $0x6,%eax
  801833:	e8 69 ff ff ff       	call   8017a1 <fsipc>
}
  801838:	c9                   	leave  
  801839:	c3                   	ret    

0080183a <devfile_stat>:
{
  80183a:	55                   	push   %ebp
  80183b:	89 e5                	mov    %esp,%ebp
  80183d:	53                   	push   %ebx
  80183e:	83 ec 04             	sub    $0x4,%esp
  801841:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801844:	8b 45 08             	mov    0x8(%ebp),%eax
  801847:	8b 40 0c             	mov    0xc(%eax),%eax
  80184a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80184f:	ba 00 00 00 00       	mov    $0x0,%edx
  801854:	b8 05 00 00 00       	mov    $0x5,%eax
  801859:	e8 43 ff ff ff       	call   8017a1 <fsipc>
  80185e:	85 c0                	test   %eax,%eax
  801860:	78 2c                	js     80188e <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801862:	83 ec 08             	sub    $0x8,%esp
  801865:	68 00 50 80 00       	push   $0x805000
  80186a:	53                   	push   %ebx
  80186b:	e8 d9 f0 ff ff       	call   800949 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801870:	a1 80 50 80 00       	mov    0x805080,%eax
  801875:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80187b:	a1 84 50 80 00       	mov    0x805084,%eax
  801880:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801886:	83 c4 10             	add    $0x10,%esp
  801889:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80188e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801891:	c9                   	leave  
  801892:	c3                   	ret    

00801893 <devfile_write>:
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	83 ec 0c             	sub    $0xc,%esp
  801899:	8b 45 10             	mov    0x10(%ebp),%eax
  80189c:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018a1:	39 d0                	cmp    %edx,%eax
  8018a3:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8018a9:	8b 52 0c             	mov    0xc(%edx),%edx
  8018ac:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018b2:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018b7:	50                   	push   %eax
  8018b8:	ff 75 0c             	push   0xc(%ebp)
  8018bb:	68 08 50 80 00       	push   $0x805008
  8018c0:	e8 1a f2 ff ff       	call   800adf <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8018c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ca:	b8 04 00 00 00       	mov    $0x4,%eax
  8018cf:	e8 cd fe ff ff       	call   8017a1 <fsipc>
}
  8018d4:	c9                   	leave  
  8018d5:	c3                   	ret    

008018d6 <devfile_read>:
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
  8018d9:	56                   	push   %esi
  8018da:	53                   	push   %ebx
  8018db:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018de:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8018e4:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018e9:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f4:	b8 03 00 00 00       	mov    $0x3,%eax
  8018f9:	e8 a3 fe ff ff       	call   8017a1 <fsipc>
  8018fe:	89 c3                	mov    %eax,%ebx
  801900:	85 c0                	test   %eax,%eax
  801902:	78 1f                	js     801923 <devfile_read+0x4d>
	assert(r <= n);
  801904:	39 f0                	cmp    %esi,%eax
  801906:	77 24                	ja     80192c <devfile_read+0x56>
	assert(r <= PGSIZE);
  801908:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80190d:	7f 33                	jg     801942 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80190f:	83 ec 04             	sub    $0x4,%esp
  801912:	50                   	push   %eax
  801913:	68 00 50 80 00       	push   $0x805000
  801918:	ff 75 0c             	push   0xc(%ebp)
  80191b:	e8 bf f1 ff ff       	call   800adf <memmove>
	return r;
  801920:	83 c4 10             	add    $0x10,%esp
}
  801923:	89 d8                	mov    %ebx,%eax
  801925:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801928:	5b                   	pop    %ebx
  801929:	5e                   	pop    %esi
  80192a:	5d                   	pop    %ebp
  80192b:	c3                   	ret    
	assert(r <= n);
  80192c:	68 a8 2c 80 00       	push   $0x802ca8
  801931:	68 af 2c 80 00       	push   $0x802caf
  801936:	6a 7c                	push   $0x7c
  801938:	68 c4 2c 80 00       	push   $0x802cc4
  80193d:	e8 52 e9 ff ff       	call   800294 <_panic>
	assert(r <= PGSIZE);
  801942:	68 cf 2c 80 00       	push   $0x802ccf
  801947:	68 af 2c 80 00       	push   $0x802caf
  80194c:	6a 7d                	push   $0x7d
  80194e:	68 c4 2c 80 00       	push   $0x802cc4
  801953:	e8 3c e9 ff ff       	call   800294 <_panic>

00801958 <open>:
{
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	56                   	push   %esi
  80195c:	53                   	push   %ebx
  80195d:	83 ec 1c             	sub    $0x1c,%esp
  801960:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801963:	56                   	push   %esi
  801964:	e8 a5 ef ff ff       	call   80090e <strlen>
  801969:	83 c4 10             	add    $0x10,%esp
  80196c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801971:	7f 6c                	jg     8019df <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801973:	83 ec 0c             	sub    $0xc,%esp
  801976:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801979:	50                   	push   %eax
  80197a:	e8 bd f8 ff ff       	call   80123c <fd_alloc>
  80197f:	89 c3                	mov    %eax,%ebx
  801981:	83 c4 10             	add    $0x10,%esp
  801984:	85 c0                	test   %eax,%eax
  801986:	78 3c                	js     8019c4 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801988:	83 ec 08             	sub    $0x8,%esp
  80198b:	56                   	push   %esi
  80198c:	68 00 50 80 00       	push   $0x805000
  801991:	e8 b3 ef ff ff       	call   800949 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801996:	8b 45 0c             	mov    0xc(%ebp),%eax
  801999:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80199e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8019a6:	e8 f6 fd ff ff       	call   8017a1 <fsipc>
  8019ab:	89 c3                	mov    %eax,%ebx
  8019ad:	83 c4 10             	add    $0x10,%esp
  8019b0:	85 c0                	test   %eax,%eax
  8019b2:	78 19                	js     8019cd <open+0x75>
	return fd2num(fd);
  8019b4:	83 ec 0c             	sub    $0xc,%esp
  8019b7:	ff 75 f4             	push   -0xc(%ebp)
  8019ba:	e8 56 f8 ff ff       	call   801215 <fd2num>
  8019bf:	89 c3                	mov    %eax,%ebx
  8019c1:	83 c4 10             	add    $0x10,%esp
}
  8019c4:	89 d8                	mov    %ebx,%eax
  8019c6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c9:	5b                   	pop    %ebx
  8019ca:	5e                   	pop    %esi
  8019cb:	5d                   	pop    %ebp
  8019cc:	c3                   	ret    
		fd_close(fd, 0);
  8019cd:	83 ec 08             	sub    $0x8,%esp
  8019d0:	6a 00                	push   $0x0
  8019d2:	ff 75 f4             	push   -0xc(%ebp)
  8019d5:	e8 58 f9 ff ff       	call   801332 <fd_close>
		return r;
  8019da:	83 c4 10             	add    $0x10,%esp
  8019dd:	eb e5                	jmp    8019c4 <open+0x6c>
		return -E_BAD_PATH;
  8019df:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019e4:	eb de                	jmp    8019c4 <open+0x6c>

008019e6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f1:	b8 08 00 00 00       	mov    $0x8,%eax
  8019f6:	e8 a6 fd ff ff       	call   8017a1 <fsipc>
}
  8019fb:	c9                   	leave  
  8019fc:	c3                   	ret    

008019fd <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8019fd:	55                   	push   %ebp
  8019fe:	89 e5                	mov    %esp,%ebp
  801a00:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a03:	68 db 2c 80 00       	push   $0x802cdb
  801a08:	ff 75 0c             	push   0xc(%ebp)
  801a0b:	e8 39 ef ff ff       	call   800949 <strcpy>
	return 0;
}
  801a10:	b8 00 00 00 00       	mov    $0x0,%eax
  801a15:	c9                   	leave  
  801a16:	c3                   	ret    

00801a17 <devsock_close>:
{
  801a17:	55                   	push   %ebp
  801a18:	89 e5                	mov    %esp,%ebp
  801a1a:	53                   	push   %ebx
  801a1b:	83 ec 10             	sub    $0x10,%esp
  801a1e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a21:	53                   	push   %ebx
  801a22:	e8 8c 0a 00 00       	call   8024b3 <pageref>
  801a27:	89 c2                	mov    %eax,%edx
  801a29:	83 c4 10             	add    $0x10,%esp
		return 0;
  801a2c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801a31:	83 fa 01             	cmp    $0x1,%edx
  801a34:	74 05                	je     801a3b <devsock_close+0x24>
}
  801a36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a39:	c9                   	leave  
  801a3a:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801a3b:	83 ec 0c             	sub    $0xc,%esp
  801a3e:	ff 73 0c             	push   0xc(%ebx)
  801a41:	e8 b7 02 00 00       	call   801cfd <nsipc_close>
  801a46:	83 c4 10             	add    $0x10,%esp
  801a49:	eb eb                	jmp    801a36 <devsock_close+0x1f>

00801a4b <devsock_write>:
{
  801a4b:	55                   	push   %ebp
  801a4c:	89 e5                	mov    %esp,%ebp
  801a4e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a51:	6a 00                	push   $0x0
  801a53:	ff 75 10             	push   0x10(%ebp)
  801a56:	ff 75 0c             	push   0xc(%ebp)
  801a59:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5c:	ff 70 0c             	push   0xc(%eax)
  801a5f:	e8 79 03 00 00       	call   801ddd <nsipc_send>
}
  801a64:	c9                   	leave  
  801a65:	c3                   	ret    

00801a66 <devsock_read>:
{
  801a66:	55                   	push   %ebp
  801a67:	89 e5                	mov    %esp,%ebp
  801a69:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a6c:	6a 00                	push   $0x0
  801a6e:	ff 75 10             	push   0x10(%ebp)
  801a71:	ff 75 0c             	push   0xc(%ebp)
  801a74:	8b 45 08             	mov    0x8(%ebp),%eax
  801a77:	ff 70 0c             	push   0xc(%eax)
  801a7a:	e8 ef 02 00 00       	call   801d6e <nsipc_recv>
}
  801a7f:	c9                   	leave  
  801a80:	c3                   	ret    

00801a81 <fd2sockid>:
{
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
  801a84:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a87:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a8a:	52                   	push   %edx
  801a8b:	50                   	push   %eax
  801a8c:	e8 fb f7 ff ff       	call   80128c <fd_lookup>
  801a91:	83 c4 10             	add    $0x10,%esp
  801a94:	85 c0                	test   %eax,%eax
  801a96:	78 10                	js     801aa8 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801a98:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a9b:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801aa1:	39 08                	cmp    %ecx,(%eax)
  801aa3:	75 05                	jne    801aaa <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801aa5:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801aa8:	c9                   	leave  
  801aa9:	c3                   	ret    
		return -E_NOT_SUPP;
  801aaa:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801aaf:	eb f7                	jmp    801aa8 <fd2sockid+0x27>

00801ab1 <alloc_sockfd>:
{
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	56                   	push   %esi
  801ab5:	53                   	push   %ebx
  801ab6:	83 ec 1c             	sub    $0x1c,%esp
  801ab9:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801abb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801abe:	50                   	push   %eax
  801abf:	e8 78 f7 ff ff       	call   80123c <fd_alloc>
  801ac4:	89 c3                	mov    %eax,%ebx
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	85 c0                	test   %eax,%eax
  801acb:	78 43                	js     801b10 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801acd:	83 ec 04             	sub    $0x4,%esp
  801ad0:	68 07 04 00 00       	push   $0x407
  801ad5:	ff 75 f4             	push   -0xc(%ebp)
  801ad8:	6a 00                	push   $0x0
  801ada:	e8 66 f2 ff ff       	call   800d45 <sys_page_alloc>
  801adf:	89 c3                	mov    %eax,%ebx
  801ae1:	83 c4 10             	add    $0x10,%esp
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	78 28                	js     801b10 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aeb:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801af1:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801afd:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b00:	83 ec 0c             	sub    $0xc,%esp
  801b03:	50                   	push   %eax
  801b04:	e8 0c f7 ff ff       	call   801215 <fd2num>
  801b09:	89 c3                	mov    %eax,%ebx
  801b0b:	83 c4 10             	add    $0x10,%esp
  801b0e:	eb 0c                	jmp    801b1c <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801b10:	83 ec 0c             	sub    $0xc,%esp
  801b13:	56                   	push   %esi
  801b14:	e8 e4 01 00 00       	call   801cfd <nsipc_close>
		return r;
  801b19:	83 c4 10             	add    $0x10,%esp
}
  801b1c:	89 d8                	mov    %ebx,%eax
  801b1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b21:	5b                   	pop    %ebx
  801b22:	5e                   	pop    %esi
  801b23:	5d                   	pop    %ebp
  801b24:	c3                   	ret    

00801b25 <accept>:
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2e:	e8 4e ff ff ff       	call   801a81 <fd2sockid>
  801b33:	85 c0                	test   %eax,%eax
  801b35:	78 1b                	js     801b52 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b37:	83 ec 04             	sub    $0x4,%esp
  801b3a:	ff 75 10             	push   0x10(%ebp)
  801b3d:	ff 75 0c             	push   0xc(%ebp)
  801b40:	50                   	push   %eax
  801b41:	e8 0e 01 00 00       	call   801c54 <nsipc_accept>
  801b46:	83 c4 10             	add    $0x10,%esp
  801b49:	85 c0                	test   %eax,%eax
  801b4b:	78 05                	js     801b52 <accept+0x2d>
	return alloc_sockfd(r);
  801b4d:	e8 5f ff ff ff       	call   801ab1 <alloc_sockfd>
}
  801b52:	c9                   	leave  
  801b53:	c3                   	ret    

00801b54 <bind>:
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5d:	e8 1f ff ff ff       	call   801a81 <fd2sockid>
  801b62:	85 c0                	test   %eax,%eax
  801b64:	78 12                	js     801b78 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801b66:	83 ec 04             	sub    $0x4,%esp
  801b69:	ff 75 10             	push   0x10(%ebp)
  801b6c:	ff 75 0c             	push   0xc(%ebp)
  801b6f:	50                   	push   %eax
  801b70:	e8 31 01 00 00       	call   801ca6 <nsipc_bind>
  801b75:	83 c4 10             	add    $0x10,%esp
}
  801b78:	c9                   	leave  
  801b79:	c3                   	ret    

00801b7a <shutdown>:
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b80:	8b 45 08             	mov    0x8(%ebp),%eax
  801b83:	e8 f9 fe ff ff       	call   801a81 <fd2sockid>
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	78 0f                	js     801b9b <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801b8c:	83 ec 08             	sub    $0x8,%esp
  801b8f:	ff 75 0c             	push   0xc(%ebp)
  801b92:	50                   	push   %eax
  801b93:	e8 43 01 00 00       	call   801cdb <nsipc_shutdown>
  801b98:	83 c4 10             	add    $0x10,%esp
}
  801b9b:	c9                   	leave  
  801b9c:	c3                   	ret    

00801b9d <connect>:
{
  801b9d:	55                   	push   %ebp
  801b9e:	89 e5                	mov    %esp,%ebp
  801ba0:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba6:	e8 d6 fe ff ff       	call   801a81 <fd2sockid>
  801bab:	85 c0                	test   %eax,%eax
  801bad:	78 12                	js     801bc1 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801baf:	83 ec 04             	sub    $0x4,%esp
  801bb2:	ff 75 10             	push   0x10(%ebp)
  801bb5:	ff 75 0c             	push   0xc(%ebp)
  801bb8:	50                   	push   %eax
  801bb9:	e8 59 01 00 00       	call   801d17 <nsipc_connect>
  801bbe:	83 c4 10             	add    $0x10,%esp
}
  801bc1:	c9                   	leave  
  801bc2:	c3                   	ret    

00801bc3 <listen>:
{
  801bc3:	55                   	push   %ebp
  801bc4:	89 e5                	mov    %esp,%ebp
  801bc6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bcc:	e8 b0 fe ff ff       	call   801a81 <fd2sockid>
  801bd1:	85 c0                	test   %eax,%eax
  801bd3:	78 0f                	js     801be4 <listen+0x21>
	return nsipc_listen(r, backlog);
  801bd5:	83 ec 08             	sub    $0x8,%esp
  801bd8:	ff 75 0c             	push   0xc(%ebp)
  801bdb:	50                   	push   %eax
  801bdc:	e8 6b 01 00 00       	call   801d4c <nsipc_listen>
  801be1:	83 c4 10             	add    $0x10,%esp
}
  801be4:	c9                   	leave  
  801be5:	c3                   	ret    

00801be6 <socket>:

int
socket(int domain, int type, int protocol)
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bec:	ff 75 10             	push   0x10(%ebp)
  801bef:	ff 75 0c             	push   0xc(%ebp)
  801bf2:	ff 75 08             	push   0x8(%ebp)
  801bf5:	e8 41 02 00 00       	call   801e3b <nsipc_socket>
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	78 05                	js     801c06 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c01:	e8 ab fe ff ff       	call   801ab1 <alloc_sockfd>
}
  801c06:	c9                   	leave  
  801c07:	c3                   	ret    

00801c08 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	53                   	push   %ebx
  801c0c:	83 ec 04             	sub    $0x4,%esp
  801c0f:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c11:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801c18:	74 26                	je     801c40 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c1a:	6a 07                	push   $0x7
  801c1c:	68 00 70 80 00       	push   $0x807000
  801c21:	53                   	push   %ebx
  801c22:	ff 35 00 80 80 00    	push   0x808000
  801c28:	e8 f9 07 00 00       	call   802426 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c2d:	83 c4 0c             	add    $0xc,%esp
  801c30:	6a 00                	push   $0x0
  801c32:	6a 00                	push   $0x0
  801c34:	6a 00                	push   $0x0
  801c36:	e8 84 07 00 00       	call   8023bf <ipc_recv>
}
  801c3b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c3e:	c9                   	leave  
  801c3f:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c40:	83 ec 0c             	sub    $0xc,%esp
  801c43:	6a 02                	push   $0x2
  801c45:	e8 30 08 00 00       	call   80247a <ipc_find_env>
  801c4a:	a3 00 80 80 00       	mov    %eax,0x808000
  801c4f:	83 c4 10             	add    $0x10,%esp
  801c52:	eb c6                	jmp    801c1a <nsipc+0x12>

00801c54 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c54:	55                   	push   %ebp
  801c55:	89 e5                	mov    %esp,%ebp
  801c57:	56                   	push   %esi
  801c58:	53                   	push   %ebx
  801c59:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c64:	8b 06                	mov    (%esi),%eax
  801c66:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c6b:	b8 01 00 00 00       	mov    $0x1,%eax
  801c70:	e8 93 ff ff ff       	call   801c08 <nsipc>
  801c75:	89 c3                	mov    %eax,%ebx
  801c77:	85 c0                	test   %eax,%eax
  801c79:	79 09                	jns    801c84 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801c7b:	89 d8                	mov    %ebx,%eax
  801c7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c80:	5b                   	pop    %ebx
  801c81:	5e                   	pop    %esi
  801c82:	5d                   	pop    %ebp
  801c83:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c84:	83 ec 04             	sub    $0x4,%esp
  801c87:	ff 35 10 70 80 00    	push   0x807010
  801c8d:	68 00 70 80 00       	push   $0x807000
  801c92:	ff 75 0c             	push   0xc(%ebp)
  801c95:	e8 45 ee ff ff       	call   800adf <memmove>
		*addrlen = ret->ret_addrlen;
  801c9a:	a1 10 70 80 00       	mov    0x807010,%eax
  801c9f:	89 06                	mov    %eax,(%esi)
  801ca1:	83 c4 10             	add    $0x10,%esp
	return r;
  801ca4:	eb d5                	jmp    801c7b <nsipc_accept+0x27>

00801ca6 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ca6:	55                   	push   %ebp
  801ca7:	89 e5                	mov    %esp,%ebp
  801ca9:	53                   	push   %ebx
  801caa:	83 ec 08             	sub    $0x8,%esp
  801cad:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801cb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb3:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cb8:	53                   	push   %ebx
  801cb9:	ff 75 0c             	push   0xc(%ebp)
  801cbc:	68 04 70 80 00       	push   $0x807004
  801cc1:	e8 19 ee ff ff       	call   800adf <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801cc6:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801ccc:	b8 02 00 00 00       	mov    $0x2,%eax
  801cd1:	e8 32 ff ff ff       	call   801c08 <nsipc>
}
  801cd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cd9:	c9                   	leave  
  801cda:	c3                   	ret    

00801cdb <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801cdb:	55                   	push   %ebp
  801cdc:	89 e5                	mov    %esp,%ebp
  801cde:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ce1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801ce9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cec:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801cf1:	b8 03 00 00 00       	mov    $0x3,%eax
  801cf6:	e8 0d ff ff ff       	call   801c08 <nsipc>
}
  801cfb:	c9                   	leave  
  801cfc:	c3                   	ret    

00801cfd <nsipc_close>:

int
nsipc_close(int s)
{
  801cfd:	55                   	push   %ebp
  801cfe:	89 e5                	mov    %esp,%ebp
  801d00:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d03:	8b 45 08             	mov    0x8(%ebp),%eax
  801d06:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801d0b:	b8 04 00 00 00       	mov    $0x4,%eax
  801d10:	e8 f3 fe ff ff       	call   801c08 <nsipc>
}
  801d15:	c9                   	leave  
  801d16:	c3                   	ret    

00801d17 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d17:	55                   	push   %ebp
  801d18:	89 e5                	mov    %esp,%ebp
  801d1a:	53                   	push   %ebx
  801d1b:	83 ec 08             	sub    $0x8,%esp
  801d1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d21:	8b 45 08             	mov    0x8(%ebp),%eax
  801d24:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d29:	53                   	push   %ebx
  801d2a:	ff 75 0c             	push   0xc(%ebp)
  801d2d:	68 04 70 80 00       	push   $0x807004
  801d32:	e8 a8 ed ff ff       	call   800adf <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d37:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801d3d:	b8 05 00 00 00       	mov    $0x5,%eax
  801d42:	e8 c1 fe ff ff       	call   801c08 <nsipc>
}
  801d47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d4a:	c9                   	leave  
  801d4b:	c3                   	ret    

00801d4c <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d52:	8b 45 08             	mov    0x8(%ebp),%eax
  801d55:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801d5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d5d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801d62:	b8 06 00 00 00       	mov    $0x6,%eax
  801d67:	e8 9c fe ff ff       	call   801c08 <nsipc>
}
  801d6c:	c9                   	leave  
  801d6d:	c3                   	ret    

00801d6e <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d6e:	55                   	push   %ebp
  801d6f:	89 e5                	mov    %esp,%ebp
  801d71:	56                   	push   %esi
  801d72:	53                   	push   %ebx
  801d73:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d76:	8b 45 08             	mov    0x8(%ebp),%eax
  801d79:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801d7e:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801d84:	8b 45 14             	mov    0x14(%ebp),%eax
  801d87:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d8c:	b8 07 00 00 00       	mov    $0x7,%eax
  801d91:	e8 72 fe ff ff       	call   801c08 <nsipc>
  801d96:	89 c3                	mov    %eax,%ebx
  801d98:	85 c0                	test   %eax,%eax
  801d9a:	78 22                	js     801dbe <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801d9c:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801da1:	39 c6                	cmp    %eax,%esi
  801da3:	0f 4e c6             	cmovle %esi,%eax
  801da6:	39 c3                	cmp    %eax,%ebx
  801da8:	7f 1d                	jg     801dc7 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801daa:	83 ec 04             	sub    $0x4,%esp
  801dad:	53                   	push   %ebx
  801dae:	68 00 70 80 00       	push   $0x807000
  801db3:	ff 75 0c             	push   0xc(%ebp)
  801db6:	e8 24 ed ff ff       	call   800adf <memmove>
  801dbb:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801dbe:	89 d8                	mov    %ebx,%eax
  801dc0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dc3:	5b                   	pop    %ebx
  801dc4:	5e                   	pop    %esi
  801dc5:	5d                   	pop    %ebp
  801dc6:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801dc7:	68 e7 2c 80 00       	push   $0x802ce7
  801dcc:	68 af 2c 80 00       	push   $0x802caf
  801dd1:	6a 62                	push   $0x62
  801dd3:	68 fc 2c 80 00       	push   $0x802cfc
  801dd8:	e8 b7 e4 ff ff       	call   800294 <_panic>

00801ddd <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ddd:	55                   	push   %ebp
  801dde:	89 e5                	mov    %esp,%ebp
  801de0:	53                   	push   %ebx
  801de1:	83 ec 04             	sub    $0x4,%esp
  801de4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801de7:	8b 45 08             	mov    0x8(%ebp),%eax
  801dea:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801def:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801df5:	7f 2e                	jg     801e25 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801df7:	83 ec 04             	sub    $0x4,%esp
  801dfa:	53                   	push   %ebx
  801dfb:	ff 75 0c             	push   0xc(%ebp)
  801dfe:	68 0c 70 80 00       	push   $0x80700c
  801e03:	e8 d7 ec ff ff       	call   800adf <memmove>
	nsipcbuf.send.req_size = size;
  801e08:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801e0e:	8b 45 14             	mov    0x14(%ebp),%eax
  801e11:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801e16:	b8 08 00 00 00       	mov    $0x8,%eax
  801e1b:	e8 e8 fd ff ff       	call   801c08 <nsipc>
}
  801e20:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e23:	c9                   	leave  
  801e24:	c3                   	ret    
	assert(size < 1600);
  801e25:	68 08 2d 80 00       	push   $0x802d08
  801e2a:	68 af 2c 80 00       	push   $0x802caf
  801e2f:	6a 6d                	push   $0x6d
  801e31:	68 fc 2c 80 00       	push   $0x802cfc
  801e36:	e8 59 e4 ff ff       	call   800294 <_panic>

00801e3b <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e3b:	55                   	push   %ebp
  801e3c:	89 e5                	mov    %esp,%ebp
  801e3e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e41:	8b 45 08             	mov    0x8(%ebp),%eax
  801e44:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801e49:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e4c:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801e51:	8b 45 10             	mov    0x10(%ebp),%eax
  801e54:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801e59:	b8 09 00 00 00       	mov    $0x9,%eax
  801e5e:	e8 a5 fd ff ff       	call   801c08 <nsipc>
}
  801e63:	c9                   	leave  
  801e64:	c3                   	ret    

00801e65 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e65:	55                   	push   %ebp
  801e66:	89 e5                	mov    %esp,%ebp
  801e68:	56                   	push   %esi
  801e69:	53                   	push   %ebx
  801e6a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e6d:	83 ec 0c             	sub    $0xc,%esp
  801e70:	ff 75 08             	push   0x8(%ebp)
  801e73:	e8 ad f3 ff ff       	call   801225 <fd2data>
  801e78:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e7a:	83 c4 08             	add    $0x8,%esp
  801e7d:	68 14 2d 80 00       	push   $0x802d14
  801e82:	53                   	push   %ebx
  801e83:	e8 c1 ea ff ff       	call   800949 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e88:	8b 46 04             	mov    0x4(%esi),%eax
  801e8b:	2b 06                	sub    (%esi),%eax
  801e8d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e93:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e9a:	00 00 00 
	stat->st_dev = &devpipe;
  801e9d:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ea4:	30 80 00 
	return 0;
}
  801ea7:	b8 00 00 00 00       	mov    $0x0,%eax
  801eac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eaf:	5b                   	pop    %ebx
  801eb0:	5e                   	pop    %esi
  801eb1:	5d                   	pop    %ebp
  801eb2:	c3                   	ret    

00801eb3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801eb3:	55                   	push   %ebp
  801eb4:	89 e5                	mov    %esp,%ebp
  801eb6:	53                   	push   %ebx
  801eb7:	83 ec 0c             	sub    $0xc,%esp
  801eba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ebd:	53                   	push   %ebx
  801ebe:	6a 00                	push   $0x0
  801ec0:	e8 05 ef ff ff       	call   800dca <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ec5:	89 1c 24             	mov    %ebx,(%esp)
  801ec8:	e8 58 f3 ff ff       	call   801225 <fd2data>
  801ecd:	83 c4 08             	add    $0x8,%esp
  801ed0:	50                   	push   %eax
  801ed1:	6a 00                	push   $0x0
  801ed3:	e8 f2 ee ff ff       	call   800dca <sys_page_unmap>
}
  801ed8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801edb:	c9                   	leave  
  801edc:	c3                   	ret    

00801edd <_pipeisclosed>:
{
  801edd:	55                   	push   %ebp
  801ede:	89 e5                	mov    %esp,%ebp
  801ee0:	57                   	push   %edi
  801ee1:	56                   	push   %esi
  801ee2:	53                   	push   %ebx
  801ee3:	83 ec 1c             	sub    $0x1c,%esp
  801ee6:	89 c7                	mov    %eax,%edi
  801ee8:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801eea:	a1 00 40 80 00       	mov    0x804000,%eax
  801eef:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ef2:	83 ec 0c             	sub    $0xc,%esp
  801ef5:	57                   	push   %edi
  801ef6:	e8 b8 05 00 00       	call   8024b3 <pageref>
  801efb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801efe:	89 34 24             	mov    %esi,(%esp)
  801f01:	e8 ad 05 00 00       	call   8024b3 <pageref>
		nn = thisenv->env_runs;
  801f06:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f0c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f0f:	83 c4 10             	add    $0x10,%esp
  801f12:	39 cb                	cmp    %ecx,%ebx
  801f14:	74 1b                	je     801f31 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801f16:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f19:	75 cf                	jne    801eea <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f1b:	8b 42 58             	mov    0x58(%edx),%eax
  801f1e:	6a 01                	push   $0x1
  801f20:	50                   	push   %eax
  801f21:	53                   	push   %ebx
  801f22:	68 1b 2d 80 00       	push   $0x802d1b
  801f27:	e8 43 e4 ff ff       	call   80036f <cprintf>
  801f2c:	83 c4 10             	add    $0x10,%esp
  801f2f:	eb b9                	jmp    801eea <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801f31:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f34:	0f 94 c0             	sete   %al
  801f37:	0f b6 c0             	movzbl %al,%eax
}
  801f3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3d:	5b                   	pop    %ebx
  801f3e:	5e                   	pop    %esi
  801f3f:	5f                   	pop    %edi
  801f40:	5d                   	pop    %ebp
  801f41:	c3                   	ret    

00801f42 <devpipe_write>:
{
  801f42:	55                   	push   %ebp
  801f43:	89 e5                	mov    %esp,%ebp
  801f45:	57                   	push   %edi
  801f46:	56                   	push   %esi
  801f47:	53                   	push   %ebx
  801f48:	83 ec 28             	sub    $0x28,%esp
  801f4b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801f4e:	56                   	push   %esi
  801f4f:	e8 d1 f2 ff ff       	call   801225 <fd2data>
  801f54:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f56:	83 c4 10             	add    $0x10,%esp
  801f59:	bf 00 00 00 00       	mov    $0x0,%edi
  801f5e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f61:	75 09                	jne    801f6c <devpipe_write+0x2a>
	return i;
  801f63:	89 f8                	mov    %edi,%eax
  801f65:	eb 23                	jmp    801f8a <devpipe_write+0x48>
			sys_yield();
  801f67:	e8 ba ed ff ff       	call   800d26 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f6c:	8b 43 04             	mov    0x4(%ebx),%eax
  801f6f:	8b 0b                	mov    (%ebx),%ecx
  801f71:	8d 51 20             	lea    0x20(%ecx),%edx
  801f74:	39 d0                	cmp    %edx,%eax
  801f76:	72 1a                	jb     801f92 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801f78:	89 da                	mov    %ebx,%edx
  801f7a:	89 f0                	mov    %esi,%eax
  801f7c:	e8 5c ff ff ff       	call   801edd <_pipeisclosed>
  801f81:	85 c0                	test   %eax,%eax
  801f83:	74 e2                	je     801f67 <devpipe_write+0x25>
				return 0;
  801f85:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f8d:	5b                   	pop    %ebx
  801f8e:	5e                   	pop    %esi
  801f8f:	5f                   	pop    %edi
  801f90:	5d                   	pop    %ebp
  801f91:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f95:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f99:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f9c:	89 c2                	mov    %eax,%edx
  801f9e:	c1 fa 1f             	sar    $0x1f,%edx
  801fa1:	89 d1                	mov    %edx,%ecx
  801fa3:	c1 e9 1b             	shr    $0x1b,%ecx
  801fa6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fa9:	83 e2 1f             	and    $0x1f,%edx
  801fac:	29 ca                	sub    %ecx,%edx
  801fae:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fb2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fb6:	83 c0 01             	add    $0x1,%eax
  801fb9:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801fbc:	83 c7 01             	add    $0x1,%edi
  801fbf:	eb 9d                	jmp    801f5e <devpipe_write+0x1c>

00801fc1 <devpipe_read>:
{
  801fc1:	55                   	push   %ebp
  801fc2:	89 e5                	mov    %esp,%ebp
  801fc4:	57                   	push   %edi
  801fc5:	56                   	push   %esi
  801fc6:	53                   	push   %ebx
  801fc7:	83 ec 18             	sub    $0x18,%esp
  801fca:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801fcd:	57                   	push   %edi
  801fce:	e8 52 f2 ff ff       	call   801225 <fd2data>
  801fd3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801fd5:	83 c4 10             	add    $0x10,%esp
  801fd8:	be 00 00 00 00       	mov    $0x0,%esi
  801fdd:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fe0:	75 13                	jne    801ff5 <devpipe_read+0x34>
	return i;
  801fe2:	89 f0                	mov    %esi,%eax
  801fe4:	eb 02                	jmp    801fe8 <devpipe_read+0x27>
				return i;
  801fe6:	89 f0                	mov    %esi,%eax
}
  801fe8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801feb:	5b                   	pop    %ebx
  801fec:	5e                   	pop    %esi
  801fed:	5f                   	pop    %edi
  801fee:	5d                   	pop    %ebp
  801fef:	c3                   	ret    
			sys_yield();
  801ff0:	e8 31 ed ff ff       	call   800d26 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801ff5:	8b 03                	mov    (%ebx),%eax
  801ff7:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ffa:	75 18                	jne    802014 <devpipe_read+0x53>
			if (i > 0)
  801ffc:	85 f6                	test   %esi,%esi
  801ffe:	75 e6                	jne    801fe6 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  802000:	89 da                	mov    %ebx,%edx
  802002:	89 f8                	mov    %edi,%eax
  802004:	e8 d4 fe ff ff       	call   801edd <_pipeisclosed>
  802009:	85 c0                	test   %eax,%eax
  80200b:	74 e3                	je     801ff0 <devpipe_read+0x2f>
				return 0;
  80200d:	b8 00 00 00 00       	mov    $0x0,%eax
  802012:	eb d4                	jmp    801fe8 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802014:	99                   	cltd   
  802015:	c1 ea 1b             	shr    $0x1b,%edx
  802018:	01 d0                	add    %edx,%eax
  80201a:	83 e0 1f             	and    $0x1f,%eax
  80201d:	29 d0                	sub    %edx,%eax
  80201f:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802024:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802027:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  80202a:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  80202d:	83 c6 01             	add    $0x1,%esi
  802030:	eb ab                	jmp    801fdd <devpipe_read+0x1c>

00802032 <pipe>:
{
  802032:	55                   	push   %ebp
  802033:	89 e5                	mov    %esp,%ebp
  802035:	56                   	push   %esi
  802036:	53                   	push   %ebx
  802037:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80203a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80203d:	50                   	push   %eax
  80203e:	e8 f9 f1 ff ff       	call   80123c <fd_alloc>
  802043:	89 c3                	mov    %eax,%ebx
  802045:	83 c4 10             	add    $0x10,%esp
  802048:	85 c0                	test   %eax,%eax
  80204a:	0f 88 23 01 00 00    	js     802173 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802050:	83 ec 04             	sub    $0x4,%esp
  802053:	68 07 04 00 00       	push   $0x407
  802058:	ff 75 f4             	push   -0xc(%ebp)
  80205b:	6a 00                	push   $0x0
  80205d:	e8 e3 ec ff ff       	call   800d45 <sys_page_alloc>
  802062:	89 c3                	mov    %eax,%ebx
  802064:	83 c4 10             	add    $0x10,%esp
  802067:	85 c0                	test   %eax,%eax
  802069:	0f 88 04 01 00 00    	js     802173 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  80206f:	83 ec 0c             	sub    $0xc,%esp
  802072:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802075:	50                   	push   %eax
  802076:	e8 c1 f1 ff ff       	call   80123c <fd_alloc>
  80207b:	89 c3                	mov    %eax,%ebx
  80207d:	83 c4 10             	add    $0x10,%esp
  802080:	85 c0                	test   %eax,%eax
  802082:	0f 88 db 00 00 00    	js     802163 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802088:	83 ec 04             	sub    $0x4,%esp
  80208b:	68 07 04 00 00       	push   $0x407
  802090:	ff 75 f0             	push   -0x10(%ebp)
  802093:	6a 00                	push   $0x0
  802095:	e8 ab ec ff ff       	call   800d45 <sys_page_alloc>
  80209a:	89 c3                	mov    %eax,%ebx
  80209c:	83 c4 10             	add    $0x10,%esp
  80209f:	85 c0                	test   %eax,%eax
  8020a1:	0f 88 bc 00 00 00    	js     802163 <pipe+0x131>
	va = fd2data(fd0);
  8020a7:	83 ec 0c             	sub    $0xc,%esp
  8020aa:	ff 75 f4             	push   -0xc(%ebp)
  8020ad:	e8 73 f1 ff ff       	call   801225 <fd2data>
  8020b2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020b4:	83 c4 0c             	add    $0xc,%esp
  8020b7:	68 07 04 00 00       	push   $0x407
  8020bc:	50                   	push   %eax
  8020bd:	6a 00                	push   $0x0
  8020bf:	e8 81 ec ff ff       	call   800d45 <sys_page_alloc>
  8020c4:	89 c3                	mov    %eax,%ebx
  8020c6:	83 c4 10             	add    $0x10,%esp
  8020c9:	85 c0                	test   %eax,%eax
  8020cb:	0f 88 82 00 00 00    	js     802153 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020d1:	83 ec 0c             	sub    $0xc,%esp
  8020d4:	ff 75 f0             	push   -0x10(%ebp)
  8020d7:	e8 49 f1 ff ff       	call   801225 <fd2data>
  8020dc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020e3:	50                   	push   %eax
  8020e4:	6a 00                	push   $0x0
  8020e6:	56                   	push   %esi
  8020e7:	6a 00                	push   $0x0
  8020e9:	e8 9a ec ff ff       	call   800d88 <sys_page_map>
  8020ee:	89 c3                	mov    %eax,%ebx
  8020f0:	83 c4 20             	add    $0x20,%esp
  8020f3:	85 c0                	test   %eax,%eax
  8020f5:	78 4e                	js     802145 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8020f7:	a1 3c 30 80 00       	mov    0x80303c,%eax
  8020fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8020ff:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802101:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802104:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80210b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80210e:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802110:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802113:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80211a:	83 ec 0c             	sub    $0xc,%esp
  80211d:	ff 75 f4             	push   -0xc(%ebp)
  802120:	e8 f0 f0 ff ff       	call   801215 <fd2num>
  802125:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802128:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80212a:	83 c4 04             	add    $0x4,%esp
  80212d:	ff 75 f0             	push   -0x10(%ebp)
  802130:	e8 e0 f0 ff ff       	call   801215 <fd2num>
  802135:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802138:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80213b:	83 c4 10             	add    $0x10,%esp
  80213e:	bb 00 00 00 00       	mov    $0x0,%ebx
  802143:	eb 2e                	jmp    802173 <pipe+0x141>
	sys_page_unmap(0, va);
  802145:	83 ec 08             	sub    $0x8,%esp
  802148:	56                   	push   %esi
  802149:	6a 00                	push   $0x0
  80214b:	e8 7a ec ff ff       	call   800dca <sys_page_unmap>
  802150:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802153:	83 ec 08             	sub    $0x8,%esp
  802156:	ff 75 f0             	push   -0x10(%ebp)
  802159:	6a 00                	push   $0x0
  80215b:	e8 6a ec ff ff       	call   800dca <sys_page_unmap>
  802160:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802163:	83 ec 08             	sub    $0x8,%esp
  802166:	ff 75 f4             	push   -0xc(%ebp)
  802169:	6a 00                	push   $0x0
  80216b:	e8 5a ec ff ff       	call   800dca <sys_page_unmap>
  802170:	83 c4 10             	add    $0x10,%esp
}
  802173:	89 d8                	mov    %ebx,%eax
  802175:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802178:	5b                   	pop    %ebx
  802179:	5e                   	pop    %esi
  80217a:	5d                   	pop    %ebp
  80217b:	c3                   	ret    

0080217c <pipeisclosed>:
{
  80217c:	55                   	push   %ebp
  80217d:	89 e5                	mov    %esp,%ebp
  80217f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802182:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802185:	50                   	push   %eax
  802186:	ff 75 08             	push   0x8(%ebp)
  802189:	e8 fe f0 ff ff       	call   80128c <fd_lookup>
  80218e:	83 c4 10             	add    $0x10,%esp
  802191:	85 c0                	test   %eax,%eax
  802193:	78 18                	js     8021ad <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802195:	83 ec 0c             	sub    $0xc,%esp
  802198:	ff 75 f4             	push   -0xc(%ebp)
  80219b:	e8 85 f0 ff ff       	call   801225 <fd2data>
  8021a0:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8021a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a5:	e8 33 fd ff ff       	call   801edd <_pipeisclosed>
  8021aa:	83 c4 10             	add    $0x10,%esp
}
  8021ad:	c9                   	leave  
  8021ae:	c3                   	ret    

008021af <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  8021af:	b8 00 00 00 00       	mov    $0x0,%eax
  8021b4:	c3                   	ret    

008021b5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021b5:	55                   	push   %ebp
  8021b6:	89 e5                	mov    %esp,%ebp
  8021b8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021bb:	68 2e 2d 80 00       	push   $0x802d2e
  8021c0:	ff 75 0c             	push   0xc(%ebp)
  8021c3:	e8 81 e7 ff ff       	call   800949 <strcpy>
	return 0;
}
  8021c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8021cd:	c9                   	leave  
  8021ce:	c3                   	ret    

008021cf <devcons_write>:
{
  8021cf:	55                   	push   %ebp
  8021d0:	89 e5                	mov    %esp,%ebp
  8021d2:	57                   	push   %edi
  8021d3:	56                   	push   %esi
  8021d4:	53                   	push   %ebx
  8021d5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8021db:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8021e0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8021e6:	eb 2e                	jmp    802216 <devcons_write+0x47>
		m = n - tot;
  8021e8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021eb:	29 f3                	sub    %esi,%ebx
  8021ed:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8021f2:	39 c3                	cmp    %eax,%ebx
  8021f4:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8021f7:	83 ec 04             	sub    $0x4,%esp
  8021fa:	53                   	push   %ebx
  8021fb:	89 f0                	mov    %esi,%eax
  8021fd:	03 45 0c             	add    0xc(%ebp),%eax
  802200:	50                   	push   %eax
  802201:	57                   	push   %edi
  802202:	e8 d8 e8 ff ff       	call   800adf <memmove>
		sys_cputs(buf, m);
  802207:	83 c4 08             	add    $0x8,%esp
  80220a:	53                   	push   %ebx
  80220b:	57                   	push   %edi
  80220c:	e8 78 ea ff ff       	call   800c89 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802211:	01 de                	add    %ebx,%esi
  802213:	83 c4 10             	add    $0x10,%esp
  802216:	3b 75 10             	cmp    0x10(%ebp),%esi
  802219:	72 cd                	jb     8021e8 <devcons_write+0x19>
}
  80221b:	89 f0                	mov    %esi,%eax
  80221d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802220:	5b                   	pop    %ebx
  802221:	5e                   	pop    %esi
  802222:	5f                   	pop    %edi
  802223:	5d                   	pop    %ebp
  802224:	c3                   	ret    

00802225 <devcons_read>:
{
  802225:	55                   	push   %ebp
  802226:	89 e5                	mov    %esp,%ebp
  802228:	83 ec 08             	sub    $0x8,%esp
  80222b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802230:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802234:	75 07                	jne    80223d <devcons_read+0x18>
  802236:	eb 1f                	jmp    802257 <devcons_read+0x32>
		sys_yield();
  802238:	e8 e9 ea ff ff       	call   800d26 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  80223d:	e8 65 ea ff ff       	call   800ca7 <sys_cgetc>
  802242:	85 c0                	test   %eax,%eax
  802244:	74 f2                	je     802238 <devcons_read+0x13>
	if (c < 0)
  802246:	78 0f                	js     802257 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802248:	83 f8 04             	cmp    $0x4,%eax
  80224b:	74 0c                	je     802259 <devcons_read+0x34>
	*(char*)vbuf = c;
  80224d:	8b 55 0c             	mov    0xc(%ebp),%edx
  802250:	88 02                	mov    %al,(%edx)
	return 1;
  802252:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802257:	c9                   	leave  
  802258:	c3                   	ret    
		return 0;
  802259:	b8 00 00 00 00       	mov    $0x0,%eax
  80225e:	eb f7                	jmp    802257 <devcons_read+0x32>

00802260 <cputchar>:
{
  802260:	55                   	push   %ebp
  802261:	89 e5                	mov    %esp,%ebp
  802263:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802266:	8b 45 08             	mov    0x8(%ebp),%eax
  802269:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80226c:	6a 01                	push   $0x1
  80226e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802271:	50                   	push   %eax
  802272:	e8 12 ea ff ff       	call   800c89 <sys_cputs>
}
  802277:	83 c4 10             	add    $0x10,%esp
  80227a:	c9                   	leave  
  80227b:	c3                   	ret    

0080227c <getchar>:
{
  80227c:	55                   	push   %ebp
  80227d:	89 e5                	mov    %esp,%ebp
  80227f:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802282:	6a 01                	push   $0x1
  802284:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802287:	50                   	push   %eax
  802288:	6a 00                	push   $0x0
  80228a:	e8 66 f2 ff ff       	call   8014f5 <read>
	if (r < 0)
  80228f:	83 c4 10             	add    $0x10,%esp
  802292:	85 c0                	test   %eax,%eax
  802294:	78 06                	js     80229c <getchar+0x20>
	if (r < 1)
  802296:	74 06                	je     80229e <getchar+0x22>
	return c;
  802298:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80229c:	c9                   	leave  
  80229d:	c3                   	ret    
		return -E_EOF;
  80229e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8022a3:	eb f7                	jmp    80229c <getchar+0x20>

008022a5 <iscons>:
{
  8022a5:	55                   	push   %ebp
  8022a6:	89 e5                	mov    %esp,%ebp
  8022a8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022ae:	50                   	push   %eax
  8022af:	ff 75 08             	push   0x8(%ebp)
  8022b2:	e8 d5 ef ff ff       	call   80128c <fd_lookup>
  8022b7:	83 c4 10             	add    $0x10,%esp
  8022ba:	85 c0                	test   %eax,%eax
  8022bc:	78 11                	js     8022cf <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8022be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c1:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022c7:	39 10                	cmp    %edx,(%eax)
  8022c9:	0f 94 c0             	sete   %al
  8022cc:	0f b6 c0             	movzbl %al,%eax
}
  8022cf:	c9                   	leave  
  8022d0:	c3                   	ret    

008022d1 <opencons>:
{
  8022d1:	55                   	push   %ebp
  8022d2:	89 e5                	mov    %esp,%ebp
  8022d4:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8022d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022da:	50                   	push   %eax
  8022db:	e8 5c ef ff ff       	call   80123c <fd_alloc>
  8022e0:	83 c4 10             	add    $0x10,%esp
  8022e3:	85 c0                	test   %eax,%eax
  8022e5:	78 3a                	js     802321 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022e7:	83 ec 04             	sub    $0x4,%esp
  8022ea:	68 07 04 00 00       	push   $0x407
  8022ef:	ff 75 f4             	push   -0xc(%ebp)
  8022f2:	6a 00                	push   $0x0
  8022f4:	e8 4c ea ff ff       	call   800d45 <sys_page_alloc>
  8022f9:	83 c4 10             	add    $0x10,%esp
  8022fc:	85 c0                	test   %eax,%eax
  8022fe:	78 21                	js     802321 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  802300:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802303:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802309:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80230b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80230e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802315:	83 ec 0c             	sub    $0xc,%esp
  802318:	50                   	push   %eax
  802319:	e8 f7 ee ff ff       	call   801215 <fd2num>
  80231e:	83 c4 10             	add    $0x10,%esp
}
  802321:	c9                   	leave  
  802322:	c3                   	ret    

00802323 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802323:	55                   	push   %ebp
  802324:	89 e5                	mov    %esp,%ebp
  802326:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  802329:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  802330:	74 0a                	je     80233c <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802332:	8b 45 08             	mov    0x8(%ebp),%eax
  802335:	a3 04 80 80 00       	mov    %eax,0x808004
}
  80233a:	c9                   	leave  
  80233b:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  80233c:	e8 c6 e9 ff ff       	call   800d07 <sys_getenvid>
  802341:	83 ec 04             	sub    $0x4,%esp
  802344:	68 07 0e 00 00       	push   $0xe07
  802349:	68 00 f0 bf ee       	push   $0xeebff000
  80234e:	50                   	push   %eax
  80234f:	e8 f1 e9 ff ff       	call   800d45 <sys_page_alloc>
		if (r < 0) {
  802354:	83 c4 10             	add    $0x10,%esp
  802357:	85 c0                	test   %eax,%eax
  802359:	78 2c                	js     802387 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80235b:	e8 a7 e9 ff ff       	call   800d07 <sys_getenvid>
  802360:	83 ec 08             	sub    $0x8,%esp
  802363:	68 99 23 80 00       	push   $0x802399
  802368:	50                   	push   %eax
  802369:	e8 22 eb ff ff       	call   800e90 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80236e:	83 c4 10             	add    $0x10,%esp
  802371:	85 c0                	test   %eax,%eax
  802373:	79 bd                	jns    802332 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  802375:	50                   	push   %eax
  802376:	68 7c 2d 80 00       	push   $0x802d7c
  80237b:	6a 28                	push   $0x28
  80237d:	68 b2 2d 80 00       	push   $0x802db2
  802382:	e8 0d df ff ff       	call   800294 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  802387:	50                   	push   %eax
  802388:	68 3c 2d 80 00       	push   $0x802d3c
  80238d:	6a 23                	push   $0x23
  80238f:	68 b2 2d 80 00       	push   $0x802db2
  802394:	e8 fb de ff ff       	call   800294 <_panic>

00802399 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802399:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80239a:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  80239f:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023a1:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  8023a4:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  8023a8:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  8023ab:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  8023af:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  8023b3:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  8023b5:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  8023b8:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  8023b9:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  8023bc:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  8023bd:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  8023be:	c3                   	ret    

008023bf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023bf:	55                   	push   %ebp
  8023c0:	89 e5                	mov    %esp,%ebp
  8023c2:	56                   	push   %esi
  8023c3:	53                   	push   %ebx
  8023c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8023c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8023cd:	85 c0                	test   %eax,%eax
  8023cf:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8023d4:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8023d7:	83 ec 0c             	sub    $0xc,%esp
  8023da:	50                   	push   %eax
  8023db:	e8 15 eb ff ff       	call   800ef5 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8023e0:	83 c4 10             	add    $0x10,%esp
  8023e3:	85 f6                	test   %esi,%esi
  8023e5:	74 14                	je     8023fb <ipc_recv+0x3c>
  8023e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8023ec:	85 c0                	test   %eax,%eax
  8023ee:	78 09                	js     8023f9 <ipc_recv+0x3a>
  8023f0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8023f6:	8b 52 74             	mov    0x74(%edx),%edx
  8023f9:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8023fb:	85 db                	test   %ebx,%ebx
  8023fd:	74 14                	je     802413 <ipc_recv+0x54>
  8023ff:	ba 00 00 00 00       	mov    $0x0,%edx
  802404:	85 c0                	test   %eax,%eax
  802406:	78 09                	js     802411 <ipc_recv+0x52>
  802408:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80240e:	8b 52 78             	mov    0x78(%edx),%edx
  802411:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802413:	85 c0                	test   %eax,%eax
  802415:	78 08                	js     80241f <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  802417:	a1 00 40 80 00       	mov    0x804000,%eax
  80241c:	8b 40 70             	mov    0x70(%eax),%eax
}
  80241f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802422:	5b                   	pop    %ebx
  802423:	5e                   	pop    %esi
  802424:	5d                   	pop    %ebp
  802425:	c3                   	ret    

00802426 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802426:	55                   	push   %ebp
  802427:	89 e5                	mov    %esp,%ebp
  802429:	57                   	push   %edi
  80242a:	56                   	push   %esi
  80242b:	53                   	push   %ebx
  80242c:	83 ec 0c             	sub    $0xc,%esp
  80242f:	8b 7d 08             	mov    0x8(%ebp),%edi
  802432:	8b 75 0c             	mov    0xc(%ebp),%esi
  802435:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802438:	85 db                	test   %ebx,%ebx
  80243a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80243f:	0f 44 d8             	cmove  %eax,%ebx
  802442:	eb 05                	jmp    802449 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802444:	e8 dd e8 ff ff       	call   800d26 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802449:	ff 75 14             	push   0x14(%ebp)
  80244c:	53                   	push   %ebx
  80244d:	56                   	push   %esi
  80244e:	57                   	push   %edi
  80244f:	e8 7e ea ff ff       	call   800ed2 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802454:	83 c4 10             	add    $0x10,%esp
  802457:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80245a:	74 e8                	je     802444 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80245c:	85 c0                	test   %eax,%eax
  80245e:	78 08                	js     802468 <ipc_send+0x42>
	}while (r<0);

}
  802460:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802463:	5b                   	pop    %ebx
  802464:	5e                   	pop    %esi
  802465:	5f                   	pop    %edi
  802466:	5d                   	pop    %ebp
  802467:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802468:	50                   	push   %eax
  802469:	68 c0 2d 80 00       	push   $0x802dc0
  80246e:	6a 3d                	push   $0x3d
  802470:	68 d4 2d 80 00       	push   $0x802dd4
  802475:	e8 1a de ff ff       	call   800294 <_panic>

0080247a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80247a:	55                   	push   %ebp
  80247b:	89 e5                	mov    %esp,%ebp
  80247d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802480:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802485:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802488:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80248e:	8b 52 50             	mov    0x50(%edx),%edx
  802491:	39 ca                	cmp    %ecx,%edx
  802493:	74 11                	je     8024a6 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802495:	83 c0 01             	add    $0x1,%eax
  802498:	3d 00 04 00 00       	cmp    $0x400,%eax
  80249d:	75 e6                	jne    802485 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80249f:	b8 00 00 00 00       	mov    $0x0,%eax
  8024a4:	eb 0b                	jmp    8024b1 <ipc_find_env+0x37>
			return envs[i].env_id;
  8024a6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8024a9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024ae:	8b 40 48             	mov    0x48(%eax),%eax
}
  8024b1:	5d                   	pop    %ebp
  8024b2:	c3                   	ret    

008024b3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024b3:	55                   	push   %ebp
  8024b4:	89 e5                	mov    %esp,%ebp
  8024b6:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024b9:	89 c2                	mov    %eax,%edx
  8024bb:	c1 ea 16             	shr    $0x16,%edx
  8024be:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8024c5:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8024ca:	f6 c1 01             	test   $0x1,%cl
  8024cd:	74 1c                	je     8024eb <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8024cf:	c1 e8 0c             	shr    $0xc,%eax
  8024d2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8024d9:	a8 01                	test   $0x1,%al
  8024db:	74 0e                	je     8024eb <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024dd:	c1 e8 0c             	shr    $0xc,%eax
  8024e0:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8024e7:	ef 
  8024e8:	0f b7 d2             	movzwl %dx,%edx
}
  8024eb:	89 d0                	mov    %edx,%eax
  8024ed:	5d                   	pop    %ebp
  8024ee:	c3                   	ret    
  8024ef:	90                   	nop

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
