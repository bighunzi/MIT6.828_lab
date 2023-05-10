
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
  80004c:	e8 31 15 00 00       	call   801582 <readn>
  800051:	83 c4 10             	add    $0x10,%esp
  800054:	83 f8 04             	cmp    $0x4,%eax
  800057:	75 49                	jne    8000a2 <primeproc+0x6f>
	cprintf("%d\n", p);
  800059:	83 ec 08             	sub    $0x8,%esp
  80005c:	ff 75 e0             	push   -0x20(%ebp)
  80005f:	68 a1 27 80 00       	push   $0x8027a1
  800064:	e8 09 03 00 00       	call   800372 <cprintf>
	if ((i=pipe(pfd)) < 0)
  800069:	89 3c 24             	mov    %edi,(%esp)
  80006c:	e8 c7 1f 00 00       	call   802038 <pipe>
  800071:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	85 c0                	test   %eax,%eax
  800079:	78 47                	js     8000c2 <primeproc+0x8f>
		panic("pipe: %e", i);
	if ((id = fork()) < 0)
  80007b:	e8 18 10 00 00       	call   801098 <fork>
  800080:	85 c0                	test   %eax,%eax
  800082:	78 50                	js     8000d4 <primeproc+0xa1>
		panic("fork: %e", id);
	if (id == 0) {
  800084:	75 60                	jne    8000e6 <primeproc+0xb3>
		close(fd);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	53                   	push   %ebx
  80008a:	e8 30 13 00 00       	call   8013bf <close>
		close(pfd[1]);
  80008f:	83 c4 04             	add    $0x4,%esp
  800092:	ff 75 dc             	push   -0x24(%ebp)
  800095:	e8 25 13 00 00       	call   8013bf <close>
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
  8000b1:	68 60 27 80 00       	push   $0x802760
  8000b6:	6a 15                	push   $0x15
  8000b8:	68 8f 27 80 00       	push   $0x80278f
  8000bd:	e8 d5 01 00 00       	call   800297 <_panic>
		panic("pipe: %e", i);
  8000c2:	50                   	push   %eax
  8000c3:	68 a5 27 80 00       	push   $0x8027a5
  8000c8:	6a 1b                	push   $0x1b
  8000ca:	68 8f 27 80 00       	push   $0x80278f
  8000cf:	e8 c3 01 00 00       	call   800297 <_panic>
		panic("fork: %e", id);
  8000d4:	50                   	push   %eax
  8000d5:	68 18 2c 80 00       	push   $0x802c18
  8000da:	6a 1d                	push   $0x1d
  8000dc:	68 8f 27 80 00       	push   $0x80278f
  8000e1:	e8 b1 01 00 00       	call   800297 <_panic>
	}

	close(pfd[0]);
  8000e6:	83 ec 0c             	sub    $0xc,%esp
  8000e9:	ff 75 d8             	push   -0x28(%ebp)
  8000ec:	e8 ce 12 00 00       	call   8013bf <close>
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
  800101:	e8 7c 14 00 00       	call   801582 <readn>
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
  800120:	e8 a4 14 00 00       	call   8015c9 <write>
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
  80013f:	68 ca 27 80 00       	push   $0x8027ca
  800144:	6a 2e                	push   $0x2e
  800146:	68 8f 27 80 00       	push   $0x80278f
  80014b:	e8 47 01 00 00       	call   800297 <_panic>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800150:	83 ec 04             	sub    $0x4,%esp
  800153:	85 c0                	test   %eax,%eax
  800155:	ba 00 00 00 00       	mov    $0x0,%edx
  80015a:	0f 4e d0             	cmovle %eax,%edx
  80015d:	52                   	push   %edx
  80015e:	50                   	push   %eax
  80015f:	53                   	push   %ebx
  800160:	ff 75 e0             	push   -0x20(%ebp)
  800163:	68 ae 27 80 00       	push   $0x8027ae
  800168:	6a 2b                	push   $0x2b
  80016a:	68 8f 27 80 00       	push   $0x80278f
  80016f:	e8 23 01 00 00       	call   800297 <_panic>

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
  80017b:	c7 05 00 30 80 00 e4 	movl   $0x8027e4,0x803000
  800182:	27 80 00 

	if ((i=pipe(p)) < 0)
  800185:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800188:	50                   	push   %eax
  800189:	e8 aa 1e 00 00       	call   802038 <pipe>
  80018e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800191:	83 c4 10             	add    $0x10,%esp
  800194:	85 c0                	test   %eax,%eax
  800196:	78 21                	js     8001b9 <umain+0x45>
		panic("pipe: %e", i);

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  800198:	e8 fb 0e 00 00       	call   801098 <fork>
  80019d:	85 c0                	test   %eax,%eax
  80019f:	78 2a                	js     8001cb <umain+0x57>
		panic("fork: %e", id);

	if (id == 0) {
  8001a1:	75 3a                	jne    8001dd <umain+0x69>
		close(p[1]);
  8001a3:	83 ec 0c             	sub    $0xc,%esp
  8001a6:	ff 75 f0             	push   -0x10(%ebp)
  8001a9:	e8 11 12 00 00       	call   8013bf <close>
		primeproc(p[0]);
  8001ae:	83 c4 04             	add    $0x4,%esp
  8001b1:	ff 75 ec             	push   -0x14(%ebp)
  8001b4:	e8 7a fe ff ff       	call   800033 <primeproc>
		panic("pipe: %e", i);
  8001b9:	50                   	push   %eax
  8001ba:	68 a5 27 80 00       	push   $0x8027a5
  8001bf:	6a 3a                	push   $0x3a
  8001c1:	68 8f 27 80 00       	push   $0x80278f
  8001c6:	e8 cc 00 00 00       	call   800297 <_panic>
		panic("fork: %e", id);
  8001cb:	50                   	push   %eax
  8001cc:	68 18 2c 80 00       	push   $0x802c18
  8001d1:	6a 3e                	push   $0x3e
  8001d3:	68 8f 27 80 00       	push   $0x80278f
  8001d8:	e8 ba 00 00 00       	call   800297 <_panic>
	}

	close(p[0]);
  8001dd:	83 ec 0c             	sub    $0xc,%esp
  8001e0:	ff 75 ec             	push   -0x14(%ebp)
  8001e3:	e8 d7 11 00 00       	call   8013bf <close>
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
  800207:	e8 bd 13 00 00       	call   8015c9 <write>
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
  800223:	68 ef 27 80 00       	push   $0x8027ef
  800228:	6a 4a                	push   $0x4a
  80022a:	68 8f 27 80 00       	push   $0x80278f
  80022f:	e8 63 00 00 00       	call   800297 <_panic>

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
  80023f:	e8 c6 0a 00 00       	call   800d0a <sys_getenvid>
  800244:	25 ff 03 00 00       	and    $0x3ff,%eax
  800249:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80024f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800254:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800259:	85 db                	test   %ebx,%ebx
  80025b:	7e 07                	jle    800264 <libmain+0x30>
		binaryname = argv[0];
  80025d:	8b 06                	mov    (%esi),%eax
  80025f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800264:	83 ec 08             	sub    $0x8,%esp
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	e8 06 ff ff ff       	call   800174 <umain>

	// exit gracefully
	exit();
  80026e:	e8 0a 00 00 00       	call   80027d <exit>
}
  800273:	83 c4 10             	add    $0x10,%esp
  800276:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800279:	5b                   	pop    %ebx
  80027a:	5e                   	pop    %esi
  80027b:	5d                   	pop    %ebp
  80027c:	c3                   	ret    

0080027d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800283:	e8 64 11 00 00       	call   8013ec <close_all>
	sys_env_destroy(0);
  800288:	83 ec 0c             	sub    $0xc,%esp
  80028b:	6a 00                	push   $0x0
  80028d:	e8 37 0a 00 00       	call   800cc9 <sys_env_destroy>
}
  800292:	83 c4 10             	add    $0x10,%esp
  800295:	c9                   	leave  
  800296:	c3                   	ret    

00800297 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800297:	55                   	push   %ebp
  800298:	89 e5                	mov    %esp,%ebp
  80029a:	56                   	push   %esi
  80029b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80029c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80029f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002a5:	e8 60 0a 00 00       	call   800d0a <sys_getenvid>
  8002aa:	83 ec 0c             	sub    $0xc,%esp
  8002ad:	ff 75 0c             	push   0xc(%ebp)
  8002b0:	ff 75 08             	push   0x8(%ebp)
  8002b3:	56                   	push   %esi
  8002b4:	50                   	push   %eax
  8002b5:	68 14 28 80 00       	push   $0x802814
  8002ba:	e8 b3 00 00 00       	call   800372 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002bf:	83 c4 18             	add    $0x18,%esp
  8002c2:	53                   	push   %ebx
  8002c3:	ff 75 10             	push   0x10(%ebp)
  8002c6:	e8 56 00 00 00       	call   800321 <vcprintf>
	cprintf("\n");
  8002cb:	c7 04 24 a3 27 80 00 	movl   $0x8027a3,(%esp)
  8002d2:	e8 9b 00 00 00       	call   800372 <cprintf>
  8002d7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002da:	cc                   	int3   
  8002db:	eb fd                	jmp    8002da <_panic+0x43>

008002dd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	53                   	push   %ebx
  8002e1:	83 ec 04             	sub    $0x4,%esp
  8002e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002e7:	8b 13                	mov    (%ebx),%edx
  8002e9:	8d 42 01             	lea    0x1(%edx),%eax
  8002ec:	89 03                	mov    %eax,(%ebx)
  8002ee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8002f5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002fa:	74 09                	je     800305 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8002fc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800300:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800303:	c9                   	leave  
  800304:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800305:	83 ec 08             	sub    $0x8,%esp
  800308:	68 ff 00 00 00       	push   $0xff
  80030d:	8d 43 08             	lea    0x8(%ebx),%eax
  800310:	50                   	push   %eax
  800311:	e8 76 09 00 00       	call   800c8c <sys_cputs>
		b->idx = 0;
  800316:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80031c:	83 c4 10             	add    $0x10,%esp
  80031f:	eb db                	jmp    8002fc <putch+0x1f>

00800321 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800321:	55                   	push   %ebp
  800322:	89 e5                	mov    %esp,%ebp
  800324:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80032a:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800331:	00 00 00 
	b.cnt = 0;
  800334:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80033b:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80033e:	ff 75 0c             	push   0xc(%ebp)
  800341:	ff 75 08             	push   0x8(%ebp)
  800344:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80034a:	50                   	push   %eax
  80034b:	68 dd 02 80 00       	push   $0x8002dd
  800350:	e8 14 01 00 00       	call   800469 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800355:	83 c4 08             	add    $0x8,%esp
  800358:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80035e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800364:	50                   	push   %eax
  800365:	e8 22 09 00 00       	call   800c8c <sys_cputs>

	return b.cnt;
}
  80036a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800370:	c9                   	leave  
  800371:	c3                   	ret    

00800372 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800378:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80037b:	50                   	push   %eax
  80037c:	ff 75 08             	push   0x8(%ebp)
  80037f:	e8 9d ff ff ff       	call   800321 <vcprintf>
	va_end(ap);

	return cnt;
}
  800384:	c9                   	leave  
  800385:	c3                   	ret    

00800386 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800386:	55                   	push   %ebp
  800387:	89 e5                	mov    %esp,%ebp
  800389:	57                   	push   %edi
  80038a:	56                   	push   %esi
  80038b:	53                   	push   %ebx
  80038c:	83 ec 1c             	sub    $0x1c,%esp
  80038f:	89 c7                	mov    %eax,%edi
  800391:	89 d6                	mov    %edx,%esi
  800393:	8b 45 08             	mov    0x8(%ebp),%eax
  800396:	8b 55 0c             	mov    0xc(%ebp),%edx
  800399:	89 d1                	mov    %edx,%ecx
  80039b:	89 c2                	mov    %eax,%edx
  80039d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8003a6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ac:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003b3:	39 c2                	cmp    %eax,%edx
  8003b5:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8003b8:	72 3e                	jb     8003f8 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003ba:	83 ec 0c             	sub    $0xc,%esp
  8003bd:	ff 75 18             	push   0x18(%ebp)
  8003c0:	83 eb 01             	sub    $0x1,%ebx
  8003c3:	53                   	push   %ebx
  8003c4:	50                   	push   %eax
  8003c5:	83 ec 08             	sub    $0x8,%esp
  8003c8:	ff 75 e4             	push   -0x1c(%ebp)
  8003cb:	ff 75 e0             	push   -0x20(%ebp)
  8003ce:	ff 75 dc             	push   -0x24(%ebp)
  8003d1:	ff 75 d8             	push   -0x28(%ebp)
  8003d4:	e8 37 21 00 00       	call   802510 <__udivdi3>
  8003d9:	83 c4 18             	add    $0x18,%esp
  8003dc:	52                   	push   %edx
  8003dd:	50                   	push   %eax
  8003de:	89 f2                	mov    %esi,%edx
  8003e0:	89 f8                	mov    %edi,%eax
  8003e2:	e8 9f ff ff ff       	call   800386 <printnum>
  8003e7:	83 c4 20             	add    $0x20,%esp
  8003ea:	eb 13                	jmp    8003ff <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	56                   	push   %esi
  8003f0:	ff 75 18             	push   0x18(%ebp)
  8003f3:	ff d7                	call   *%edi
  8003f5:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8003f8:	83 eb 01             	sub    $0x1,%ebx
  8003fb:	85 db                	test   %ebx,%ebx
  8003fd:	7f ed                	jg     8003ec <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8003ff:	83 ec 08             	sub    $0x8,%esp
  800402:	56                   	push   %esi
  800403:	83 ec 04             	sub    $0x4,%esp
  800406:	ff 75 e4             	push   -0x1c(%ebp)
  800409:	ff 75 e0             	push   -0x20(%ebp)
  80040c:	ff 75 dc             	push   -0x24(%ebp)
  80040f:	ff 75 d8             	push   -0x28(%ebp)
  800412:	e8 19 22 00 00       	call   802630 <__umoddi3>
  800417:	83 c4 14             	add    $0x14,%esp
  80041a:	0f be 80 37 28 80 00 	movsbl 0x802837(%eax),%eax
  800421:	50                   	push   %eax
  800422:	ff d7                	call   *%edi
}
  800424:	83 c4 10             	add    $0x10,%esp
  800427:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042a:	5b                   	pop    %ebx
  80042b:	5e                   	pop    %esi
  80042c:	5f                   	pop    %edi
  80042d:	5d                   	pop    %ebp
  80042e:	c3                   	ret    

0080042f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
  800432:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800435:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800439:	8b 10                	mov    (%eax),%edx
  80043b:	3b 50 04             	cmp    0x4(%eax),%edx
  80043e:	73 0a                	jae    80044a <sprintputch+0x1b>
		*b->buf++ = ch;
  800440:	8d 4a 01             	lea    0x1(%edx),%ecx
  800443:	89 08                	mov    %ecx,(%eax)
  800445:	8b 45 08             	mov    0x8(%ebp),%eax
  800448:	88 02                	mov    %al,(%edx)
}
  80044a:	5d                   	pop    %ebp
  80044b:	c3                   	ret    

0080044c <printfmt>:
{
  80044c:	55                   	push   %ebp
  80044d:	89 e5                	mov    %esp,%ebp
  80044f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800452:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800455:	50                   	push   %eax
  800456:	ff 75 10             	push   0x10(%ebp)
  800459:	ff 75 0c             	push   0xc(%ebp)
  80045c:	ff 75 08             	push   0x8(%ebp)
  80045f:	e8 05 00 00 00       	call   800469 <vprintfmt>
}
  800464:	83 c4 10             	add    $0x10,%esp
  800467:	c9                   	leave  
  800468:	c3                   	ret    

00800469 <vprintfmt>:
{
  800469:	55                   	push   %ebp
  80046a:	89 e5                	mov    %esp,%ebp
  80046c:	57                   	push   %edi
  80046d:	56                   	push   %esi
  80046e:	53                   	push   %ebx
  80046f:	83 ec 3c             	sub    $0x3c,%esp
  800472:	8b 75 08             	mov    0x8(%ebp),%esi
  800475:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800478:	8b 7d 10             	mov    0x10(%ebp),%edi
  80047b:	eb 0a                	jmp    800487 <vprintfmt+0x1e>
			putch(ch, putdat);
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	53                   	push   %ebx
  800481:	50                   	push   %eax
  800482:	ff d6                	call   *%esi
  800484:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800487:	83 c7 01             	add    $0x1,%edi
  80048a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80048e:	83 f8 25             	cmp    $0x25,%eax
  800491:	74 0c                	je     80049f <vprintfmt+0x36>
			if (ch == '\0')
  800493:	85 c0                	test   %eax,%eax
  800495:	75 e6                	jne    80047d <vprintfmt+0x14>
}
  800497:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80049a:	5b                   	pop    %ebx
  80049b:	5e                   	pop    %esi
  80049c:	5f                   	pop    %edi
  80049d:	5d                   	pop    %ebp
  80049e:	c3                   	ret    
		padc = ' ';
  80049f:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8004a3:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8004aa:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8004b1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8004b8:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8d 47 01             	lea    0x1(%edi),%eax
  8004c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004c3:	0f b6 17             	movzbl (%edi),%edx
  8004c6:	8d 42 dd             	lea    -0x23(%edx),%eax
  8004c9:	3c 55                	cmp    $0x55,%al
  8004cb:	0f 87 bb 03 00 00    	ja     80088c <vprintfmt+0x423>
  8004d1:	0f b6 c0             	movzbl %al,%eax
  8004d4:	ff 24 85 80 29 80 00 	jmp    *0x802980(,%eax,4)
  8004db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8004de:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8004e2:	eb d9                	jmp    8004bd <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8004e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e7:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8004eb:	eb d0                	jmp    8004bd <vprintfmt+0x54>
  8004ed:	0f b6 d2             	movzbl %dl,%edx
  8004f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8004f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8004fb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8004fe:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800502:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800505:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800508:	83 f9 09             	cmp    $0x9,%ecx
  80050b:	77 55                	ja     800562 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80050d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800510:	eb e9                	jmp    8004fb <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800512:	8b 45 14             	mov    0x14(%ebp),%eax
  800515:	8b 00                	mov    (%eax),%eax
  800517:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8d 40 04             	lea    0x4(%eax),%eax
  800520:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800523:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800526:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80052a:	79 91                	jns    8004bd <vprintfmt+0x54>
				width = precision, precision = -1;
  80052c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80052f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800532:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800539:	eb 82                	jmp    8004bd <vprintfmt+0x54>
  80053b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80053e:	85 d2                	test   %edx,%edx
  800540:	b8 00 00 00 00       	mov    $0x0,%eax
  800545:	0f 49 c2             	cmovns %edx,%eax
  800548:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80054b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80054e:	e9 6a ff ff ff       	jmp    8004bd <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800553:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800556:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80055d:	e9 5b ff ff ff       	jmp    8004bd <vprintfmt+0x54>
  800562:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800565:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800568:	eb bc                	jmp    800526 <vprintfmt+0xbd>
			lflag++;
  80056a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80056d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800570:	e9 48 ff ff ff       	jmp    8004bd <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	8d 78 04             	lea    0x4(%eax),%edi
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	53                   	push   %ebx
  80057f:	ff 30                	push   (%eax)
  800581:	ff d6                	call   *%esi
			break;
  800583:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800586:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800589:	e9 9d 02 00 00       	jmp    80082b <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80058e:	8b 45 14             	mov    0x14(%ebp),%eax
  800591:	8d 78 04             	lea    0x4(%eax),%edi
  800594:	8b 10                	mov    (%eax),%edx
  800596:	89 d0                	mov    %edx,%eax
  800598:	f7 d8                	neg    %eax
  80059a:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80059d:	83 f8 0f             	cmp    $0xf,%eax
  8005a0:	7f 23                	jg     8005c5 <vprintfmt+0x15c>
  8005a2:	8b 14 85 e0 2a 80 00 	mov    0x802ae0(,%eax,4),%edx
  8005a9:	85 d2                	test   %edx,%edx
  8005ab:	74 18                	je     8005c5 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8005ad:	52                   	push   %edx
  8005ae:	68 e1 2c 80 00       	push   $0x802ce1
  8005b3:	53                   	push   %ebx
  8005b4:	56                   	push   %esi
  8005b5:	e8 92 fe ff ff       	call   80044c <printfmt>
  8005ba:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8005bd:	89 7d 14             	mov    %edi,0x14(%ebp)
  8005c0:	e9 66 02 00 00       	jmp    80082b <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8005c5:	50                   	push   %eax
  8005c6:	68 4f 28 80 00       	push   $0x80284f
  8005cb:	53                   	push   %ebx
  8005cc:	56                   	push   %esi
  8005cd:	e8 7a fe ff ff       	call   80044c <printfmt>
  8005d2:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8005d5:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8005d8:	e9 4e 02 00 00       	jmp    80082b <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	83 c0 04             	add    $0x4,%eax
  8005e3:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8005e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e9:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8005eb:	85 d2                	test   %edx,%edx
  8005ed:	b8 48 28 80 00       	mov    $0x802848,%eax
  8005f2:	0f 45 c2             	cmovne %edx,%eax
  8005f5:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8005f8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005fc:	7e 06                	jle    800604 <vprintfmt+0x19b>
  8005fe:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800602:	75 0d                	jne    800611 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800604:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800607:	89 c7                	mov    %eax,%edi
  800609:	03 45 e0             	add    -0x20(%ebp),%eax
  80060c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80060f:	eb 55                	jmp    800666 <vprintfmt+0x1fd>
  800611:	83 ec 08             	sub    $0x8,%esp
  800614:	ff 75 d8             	push   -0x28(%ebp)
  800617:	ff 75 cc             	push   -0x34(%ebp)
  80061a:	e8 0a 03 00 00       	call   800929 <strnlen>
  80061f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800622:	29 c1                	sub    %eax,%ecx
  800624:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800627:	83 c4 10             	add    $0x10,%esp
  80062a:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80062c:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800630:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800633:	eb 0f                	jmp    800644 <vprintfmt+0x1db>
					putch(padc, putdat);
  800635:	83 ec 08             	sub    $0x8,%esp
  800638:	53                   	push   %ebx
  800639:	ff 75 e0             	push   -0x20(%ebp)
  80063c:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80063e:	83 ef 01             	sub    $0x1,%edi
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	85 ff                	test   %edi,%edi
  800646:	7f ed                	jg     800635 <vprintfmt+0x1cc>
  800648:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80064b:	85 d2                	test   %edx,%edx
  80064d:	b8 00 00 00 00       	mov    $0x0,%eax
  800652:	0f 49 c2             	cmovns %edx,%eax
  800655:	29 c2                	sub    %eax,%edx
  800657:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80065a:	eb a8                	jmp    800604 <vprintfmt+0x19b>
					putch(ch, putdat);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	53                   	push   %ebx
  800660:	52                   	push   %edx
  800661:	ff d6                	call   *%esi
  800663:	83 c4 10             	add    $0x10,%esp
  800666:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800669:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066b:	83 c7 01             	add    $0x1,%edi
  80066e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800672:	0f be d0             	movsbl %al,%edx
  800675:	85 d2                	test   %edx,%edx
  800677:	74 4b                	je     8006c4 <vprintfmt+0x25b>
  800679:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80067d:	78 06                	js     800685 <vprintfmt+0x21c>
  80067f:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800683:	78 1e                	js     8006a3 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800685:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800689:	74 d1                	je     80065c <vprintfmt+0x1f3>
  80068b:	0f be c0             	movsbl %al,%eax
  80068e:	83 e8 20             	sub    $0x20,%eax
  800691:	83 f8 5e             	cmp    $0x5e,%eax
  800694:	76 c6                	jbe    80065c <vprintfmt+0x1f3>
					putch('?', putdat);
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	53                   	push   %ebx
  80069a:	6a 3f                	push   $0x3f
  80069c:	ff d6                	call   *%esi
  80069e:	83 c4 10             	add    $0x10,%esp
  8006a1:	eb c3                	jmp    800666 <vprintfmt+0x1fd>
  8006a3:	89 cf                	mov    %ecx,%edi
  8006a5:	eb 0e                	jmp    8006b5 <vprintfmt+0x24c>
				putch(' ', putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	53                   	push   %ebx
  8006ab:	6a 20                	push   $0x20
  8006ad:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8006af:	83 ef 01             	sub    $0x1,%edi
  8006b2:	83 c4 10             	add    $0x10,%esp
  8006b5:	85 ff                	test   %edi,%edi
  8006b7:	7f ee                	jg     8006a7 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8006b9:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8006bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8006bf:	e9 67 01 00 00       	jmp    80082b <vprintfmt+0x3c2>
  8006c4:	89 cf                	mov    %ecx,%edi
  8006c6:	eb ed                	jmp    8006b5 <vprintfmt+0x24c>
	if (lflag >= 2)
  8006c8:	83 f9 01             	cmp    $0x1,%ecx
  8006cb:	7f 1b                	jg     8006e8 <vprintfmt+0x27f>
	else if (lflag)
  8006cd:	85 c9                	test   %ecx,%ecx
  8006cf:	74 63                	je     800734 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8b 00                	mov    (%eax),%eax
  8006d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d9:	99                   	cltd   
  8006da:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e0:	8d 40 04             	lea    0x4(%eax),%eax
  8006e3:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e6:	eb 17                	jmp    8006ff <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8b 50 04             	mov    0x4(%eax),%edx
  8006ee:	8b 00                	mov    (%eax),%eax
  8006f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006f3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8d 40 08             	lea    0x8(%eax),%eax
  8006fc:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8006ff:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800702:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800705:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80070a:	85 c9                	test   %ecx,%ecx
  80070c:	0f 89 ff 00 00 00    	jns    800811 <vprintfmt+0x3a8>
				putch('-', putdat);
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	53                   	push   %ebx
  800716:	6a 2d                	push   $0x2d
  800718:	ff d6                	call   *%esi
				num = -(long long) num;
  80071a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80071d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800720:	f7 da                	neg    %edx
  800722:	83 d1 00             	adc    $0x0,%ecx
  800725:	f7 d9                	neg    %ecx
  800727:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80072a:	bf 0a 00 00 00       	mov    $0xa,%edi
  80072f:	e9 dd 00 00 00       	jmp    800811 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800734:	8b 45 14             	mov    0x14(%ebp),%eax
  800737:	8b 00                	mov    (%eax),%eax
  800739:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80073c:	99                   	cltd   
  80073d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800740:	8b 45 14             	mov    0x14(%ebp),%eax
  800743:	8d 40 04             	lea    0x4(%eax),%eax
  800746:	89 45 14             	mov    %eax,0x14(%ebp)
  800749:	eb b4                	jmp    8006ff <vprintfmt+0x296>
	if (lflag >= 2)
  80074b:	83 f9 01             	cmp    $0x1,%ecx
  80074e:	7f 1e                	jg     80076e <vprintfmt+0x305>
	else if (lflag)
  800750:	85 c9                	test   %ecx,%ecx
  800752:	74 32                	je     800786 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800754:	8b 45 14             	mov    0x14(%ebp),%eax
  800757:	8b 10                	mov    (%eax),%edx
  800759:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075e:	8d 40 04             	lea    0x4(%eax),%eax
  800761:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800764:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800769:	e9 a3 00 00 00       	jmp    800811 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80076e:	8b 45 14             	mov    0x14(%ebp),%eax
  800771:	8b 10                	mov    (%eax),%edx
  800773:	8b 48 04             	mov    0x4(%eax),%ecx
  800776:	8d 40 08             	lea    0x8(%eax),%eax
  800779:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80077c:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800781:	e9 8b 00 00 00       	jmp    800811 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800786:	8b 45 14             	mov    0x14(%ebp),%eax
  800789:	8b 10                	mov    (%eax),%edx
  80078b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800790:	8d 40 04             	lea    0x4(%eax),%eax
  800793:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800796:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80079b:	eb 74                	jmp    800811 <vprintfmt+0x3a8>
	if (lflag >= 2)
  80079d:	83 f9 01             	cmp    $0x1,%ecx
  8007a0:	7f 1b                	jg     8007bd <vprintfmt+0x354>
	else if (lflag)
  8007a2:	85 c9                	test   %ecx,%ecx
  8007a4:	74 2c                	je     8007d2 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	8b 10                	mov    (%eax),%edx
  8007ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007b0:	8d 40 04             	lea    0x4(%eax),%eax
  8007b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8007b6:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8007bb:	eb 54                	jmp    800811 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c0:	8b 10                	mov    (%eax),%edx
  8007c2:	8b 48 04             	mov    0x4(%eax),%ecx
  8007c5:	8d 40 08             	lea    0x8(%eax),%eax
  8007c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8007cb:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8007d0:	eb 3f                	jmp    800811 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8b 10                	mov    (%eax),%edx
  8007d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007dc:	8d 40 04             	lea    0x4(%eax),%eax
  8007df:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8007e2:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8007e7:	eb 28                	jmp    800811 <vprintfmt+0x3a8>
			putch('0', putdat);
  8007e9:	83 ec 08             	sub    $0x8,%esp
  8007ec:	53                   	push   %ebx
  8007ed:	6a 30                	push   $0x30
  8007ef:	ff d6                	call   *%esi
			putch('x', putdat);
  8007f1:	83 c4 08             	add    $0x8,%esp
  8007f4:	53                   	push   %ebx
  8007f5:	6a 78                	push   $0x78
  8007f7:	ff d6                	call   *%esi
			num = (unsigned long long)
  8007f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fc:	8b 10                	mov    (%eax),%edx
  8007fe:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800803:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800806:	8d 40 04             	lea    0x4(%eax),%eax
  800809:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80080c:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800811:	83 ec 0c             	sub    $0xc,%esp
  800814:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800818:	50                   	push   %eax
  800819:	ff 75 e0             	push   -0x20(%ebp)
  80081c:	57                   	push   %edi
  80081d:	51                   	push   %ecx
  80081e:	52                   	push   %edx
  80081f:	89 da                	mov    %ebx,%edx
  800821:	89 f0                	mov    %esi,%eax
  800823:	e8 5e fb ff ff       	call   800386 <printnum>
			break;
  800828:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80082b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80082e:	e9 54 fc ff ff       	jmp    800487 <vprintfmt+0x1e>
	if (lflag >= 2)
  800833:	83 f9 01             	cmp    $0x1,%ecx
  800836:	7f 1b                	jg     800853 <vprintfmt+0x3ea>
	else if (lflag)
  800838:	85 c9                	test   %ecx,%ecx
  80083a:	74 2c                	je     800868 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	8b 10                	mov    (%eax),%edx
  800841:	b9 00 00 00 00       	mov    $0x0,%ecx
  800846:	8d 40 04             	lea    0x4(%eax),%eax
  800849:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80084c:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800851:	eb be                	jmp    800811 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800853:	8b 45 14             	mov    0x14(%ebp),%eax
  800856:	8b 10                	mov    (%eax),%edx
  800858:	8b 48 04             	mov    0x4(%eax),%ecx
  80085b:	8d 40 08             	lea    0x8(%eax),%eax
  80085e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800861:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800866:	eb a9                	jmp    800811 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800868:	8b 45 14             	mov    0x14(%ebp),%eax
  80086b:	8b 10                	mov    (%eax),%edx
  80086d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800872:	8d 40 04             	lea    0x4(%eax),%eax
  800875:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800878:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80087d:	eb 92                	jmp    800811 <vprintfmt+0x3a8>
			putch(ch, putdat);
  80087f:	83 ec 08             	sub    $0x8,%esp
  800882:	53                   	push   %ebx
  800883:	6a 25                	push   $0x25
  800885:	ff d6                	call   *%esi
			break;
  800887:	83 c4 10             	add    $0x10,%esp
  80088a:	eb 9f                	jmp    80082b <vprintfmt+0x3c2>
			putch('%', putdat);
  80088c:	83 ec 08             	sub    $0x8,%esp
  80088f:	53                   	push   %ebx
  800890:	6a 25                	push   $0x25
  800892:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800894:	83 c4 10             	add    $0x10,%esp
  800897:	89 f8                	mov    %edi,%eax
  800899:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80089d:	74 05                	je     8008a4 <vprintfmt+0x43b>
  80089f:	83 e8 01             	sub    $0x1,%eax
  8008a2:	eb f5                	jmp    800899 <vprintfmt+0x430>
  8008a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008a7:	eb 82                	jmp    80082b <vprintfmt+0x3c2>

008008a9 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	83 ec 18             	sub    $0x18,%esp
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008b8:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008bc:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008c6:	85 c0                	test   %eax,%eax
  8008c8:	74 26                	je     8008f0 <vsnprintf+0x47>
  8008ca:	85 d2                	test   %edx,%edx
  8008cc:	7e 22                	jle    8008f0 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008ce:	ff 75 14             	push   0x14(%ebp)
  8008d1:	ff 75 10             	push   0x10(%ebp)
  8008d4:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008d7:	50                   	push   %eax
  8008d8:	68 2f 04 80 00       	push   $0x80042f
  8008dd:	e8 87 fb ff ff       	call   800469 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008e2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008e5:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008eb:	83 c4 10             	add    $0x10,%esp
}
  8008ee:	c9                   	leave  
  8008ef:	c3                   	ret    
		return -E_INVAL;
  8008f0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008f5:	eb f7                	jmp    8008ee <vsnprintf+0x45>

008008f7 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008f7:	55                   	push   %ebp
  8008f8:	89 e5                	mov    %esp,%ebp
  8008fa:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008fd:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800900:	50                   	push   %eax
  800901:	ff 75 10             	push   0x10(%ebp)
  800904:	ff 75 0c             	push   0xc(%ebp)
  800907:	ff 75 08             	push   0x8(%ebp)
  80090a:	e8 9a ff ff ff       	call   8008a9 <vsnprintf>
	va_end(ap);

	return rc;
}
  80090f:	c9                   	leave  
  800910:	c3                   	ret    

00800911 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800917:	b8 00 00 00 00       	mov    $0x0,%eax
  80091c:	eb 03                	jmp    800921 <strlen+0x10>
		n++;
  80091e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800921:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800925:	75 f7                	jne    80091e <strlen+0xd>
	return n;
}
  800927:	5d                   	pop    %ebp
  800928:	c3                   	ret    

00800929 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092f:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800932:	b8 00 00 00 00       	mov    $0x0,%eax
  800937:	eb 03                	jmp    80093c <strnlen+0x13>
		n++;
  800939:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80093c:	39 d0                	cmp    %edx,%eax
  80093e:	74 08                	je     800948 <strnlen+0x1f>
  800940:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800944:	75 f3                	jne    800939 <strnlen+0x10>
  800946:	89 c2                	mov    %eax,%edx
	return n;
}
  800948:	89 d0                	mov    %edx,%eax
  80094a:	5d                   	pop    %ebp
  80094b:	c3                   	ret    

0080094c <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80094c:	55                   	push   %ebp
  80094d:	89 e5                	mov    %esp,%ebp
  80094f:	53                   	push   %ebx
  800950:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800953:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800956:	b8 00 00 00 00       	mov    $0x0,%eax
  80095b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80095f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800962:	83 c0 01             	add    $0x1,%eax
  800965:	84 d2                	test   %dl,%dl
  800967:	75 f2                	jne    80095b <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800969:	89 c8                	mov    %ecx,%eax
  80096b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80096e:	c9                   	leave  
  80096f:	c3                   	ret    

00800970 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	53                   	push   %ebx
  800974:	83 ec 10             	sub    $0x10,%esp
  800977:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80097a:	53                   	push   %ebx
  80097b:	e8 91 ff ff ff       	call   800911 <strlen>
  800980:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800983:	ff 75 0c             	push   0xc(%ebp)
  800986:	01 d8                	add    %ebx,%eax
  800988:	50                   	push   %eax
  800989:	e8 be ff ff ff       	call   80094c <strcpy>
	return dst;
}
  80098e:	89 d8                	mov    %ebx,%eax
  800990:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	56                   	push   %esi
  800999:	53                   	push   %ebx
  80099a:	8b 75 08             	mov    0x8(%ebp),%esi
  80099d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a0:	89 f3                	mov    %esi,%ebx
  8009a2:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a5:	89 f0                	mov    %esi,%eax
  8009a7:	eb 0f                	jmp    8009b8 <strncpy+0x23>
		*dst++ = *src;
  8009a9:	83 c0 01             	add    $0x1,%eax
  8009ac:	0f b6 0a             	movzbl (%edx),%ecx
  8009af:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009b2:	80 f9 01             	cmp    $0x1,%cl
  8009b5:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8009b8:	39 d8                	cmp    %ebx,%eax
  8009ba:	75 ed                	jne    8009a9 <strncpy+0x14>
	}
	return ret;
}
  8009bc:	89 f0                	mov    %esi,%eax
  8009be:	5b                   	pop    %ebx
  8009bf:	5e                   	pop    %esi
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	56                   	push   %esi
  8009c6:	53                   	push   %ebx
  8009c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009cd:	8b 55 10             	mov    0x10(%ebp),%edx
  8009d0:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009d2:	85 d2                	test   %edx,%edx
  8009d4:	74 21                	je     8009f7 <strlcpy+0x35>
  8009d6:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8009da:	89 f2                	mov    %esi,%edx
  8009dc:	eb 09                	jmp    8009e7 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8009de:	83 c1 01             	add    $0x1,%ecx
  8009e1:	83 c2 01             	add    $0x1,%edx
  8009e4:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8009e7:	39 c2                	cmp    %eax,%edx
  8009e9:	74 09                	je     8009f4 <strlcpy+0x32>
  8009eb:	0f b6 19             	movzbl (%ecx),%ebx
  8009ee:	84 db                	test   %bl,%bl
  8009f0:	75 ec                	jne    8009de <strlcpy+0x1c>
  8009f2:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009f4:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009f7:	29 f0                	sub    %esi,%eax
}
  8009f9:	5b                   	pop    %ebx
  8009fa:	5e                   	pop    %esi
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a03:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a06:	eb 06                	jmp    800a0e <strcmp+0x11>
		p++, q++;
  800a08:	83 c1 01             	add    $0x1,%ecx
  800a0b:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a0e:	0f b6 01             	movzbl (%ecx),%eax
  800a11:	84 c0                	test   %al,%al
  800a13:	74 04                	je     800a19 <strcmp+0x1c>
  800a15:	3a 02                	cmp    (%edx),%al
  800a17:	74 ef                	je     800a08 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a19:	0f b6 c0             	movzbl %al,%eax
  800a1c:	0f b6 12             	movzbl (%edx),%edx
  800a1f:	29 d0                	sub    %edx,%eax
}
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	53                   	push   %ebx
  800a27:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a2d:	89 c3                	mov    %eax,%ebx
  800a2f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a32:	eb 06                	jmp    800a3a <strncmp+0x17>
		n--, p++, q++;
  800a34:	83 c0 01             	add    $0x1,%eax
  800a37:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a3a:	39 d8                	cmp    %ebx,%eax
  800a3c:	74 18                	je     800a56 <strncmp+0x33>
  800a3e:	0f b6 08             	movzbl (%eax),%ecx
  800a41:	84 c9                	test   %cl,%cl
  800a43:	74 04                	je     800a49 <strncmp+0x26>
  800a45:	3a 0a                	cmp    (%edx),%cl
  800a47:	74 eb                	je     800a34 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a49:	0f b6 00             	movzbl (%eax),%eax
  800a4c:	0f b6 12             	movzbl (%edx),%edx
  800a4f:	29 d0                	sub    %edx,%eax
}
  800a51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a54:	c9                   	leave  
  800a55:	c3                   	ret    
		return 0;
  800a56:	b8 00 00 00 00       	mov    $0x0,%eax
  800a5b:	eb f4                	jmp    800a51 <strncmp+0x2e>

00800a5d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a5d:	55                   	push   %ebp
  800a5e:	89 e5                	mov    %esp,%ebp
  800a60:	8b 45 08             	mov    0x8(%ebp),%eax
  800a63:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a67:	eb 03                	jmp    800a6c <strchr+0xf>
  800a69:	83 c0 01             	add    $0x1,%eax
  800a6c:	0f b6 10             	movzbl (%eax),%edx
  800a6f:	84 d2                	test   %dl,%dl
  800a71:	74 06                	je     800a79 <strchr+0x1c>
		if (*s == c)
  800a73:	38 ca                	cmp    %cl,%dl
  800a75:	75 f2                	jne    800a69 <strchr+0xc>
  800a77:	eb 05                	jmp    800a7e <strchr+0x21>
			return (char *) s;
	return 0;
  800a79:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a7e:	5d                   	pop    %ebp
  800a7f:	c3                   	ret    

00800a80 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	8b 45 08             	mov    0x8(%ebp),%eax
  800a86:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a8a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a8d:	38 ca                	cmp    %cl,%dl
  800a8f:	74 09                	je     800a9a <strfind+0x1a>
  800a91:	84 d2                	test   %dl,%dl
  800a93:	74 05                	je     800a9a <strfind+0x1a>
	for (; *s; s++)
  800a95:	83 c0 01             	add    $0x1,%eax
  800a98:	eb f0                	jmp    800a8a <strfind+0xa>
			break;
	return (char *) s;
}
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	57                   	push   %edi
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
  800aa2:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aa5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800aa8:	85 c9                	test   %ecx,%ecx
  800aaa:	74 2f                	je     800adb <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aac:	89 f8                	mov    %edi,%eax
  800aae:	09 c8                	or     %ecx,%eax
  800ab0:	a8 03                	test   $0x3,%al
  800ab2:	75 21                	jne    800ad5 <memset+0x39>
		c &= 0xFF;
  800ab4:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ab8:	89 d0                	mov    %edx,%eax
  800aba:	c1 e0 08             	shl    $0x8,%eax
  800abd:	89 d3                	mov    %edx,%ebx
  800abf:	c1 e3 18             	shl    $0x18,%ebx
  800ac2:	89 d6                	mov    %edx,%esi
  800ac4:	c1 e6 10             	shl    $0x10,%esi
  800ac7:	09 f3                	or     %esi,%ebx
  800ac9:	09 da                	or     %ebx,%edx
  800acb:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800acd:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800ad0:	fc                   	cld    
  800ad1:	f3 ab                	rep stos %eax,%es:(%edi)
  800ad3:	eb 06                	jmp    800adb <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ad5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad8:	fc                   	cld    
  800ad9:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800adb:	89 f8                	mov    %edi,%eax
  800add:	5b                   	pop    %ebx
  800ade:	5e                   	pop    %esi
  800adf:	5f                   	pop    %edi
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aea:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800af0:	39 c6                	cmp    %eax,%esi
  800af2:	73 32                	jae    800b26 <memmove+0x44>
  800af4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800af7:	39 c2                	cmp    %eax,%edx
  800af9:	76 2b                	jbe    800b26 <memmove+0x44>
		s += n;
		d += n;
  800afb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afe:	89 d6                	mov    %edx,%esi
  800b00:	09 fe                	or     %edi,%esi
  800b02:	09 ce                	or     %ecx,%esi
  800b04:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b0a:	75 0e                	jne    800b1a <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b0c:	83 ef 04             	sub    $0x4,%edi
  800b0f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b12:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b15:	fd                   	std    
  800b16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b18:	eb 09                	jmp    800b23 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b1a:	83 ef 01             	sub    $0x1,%edi
  800b1d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b20:	fd                   	std    
  800b21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b23:	fc                   	cld    
  800b24:	eb 1a                	jmp    800b40 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b26:	89 f2                	mov    %esi,%edx
  800b28:	09 c2                	or     %eax,%edx
  800b2a:	09 ca                	or     %ecx,%edx
  800b2c:	f6 c2 03             	test   $0x3,%dl
  800b2f:	75 0a                	jne    800b3b <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b31:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b34:	89 c7                	mov    %eax,%edi
  800b36:	fc                   	cld    
  800b37:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b39:	eb 05                	jmp    800b40 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800b3b:	89 c7                	mov    %eax,%edi
  800b3d:	fc                   	cld    
  800b3e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b40:	5e                   	pop    %esi
  800b41:	5f                   	pop    %edi
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b4a:	ff 75 10             	push   0x10(%ebp)
  800b4d:	ff 75 0c             	push   0xc(%ebp)
  800b50:	ff 75 08             	push   0x8(%ebp)
  800b53:	e8 8a ff ff ff       	call   800ae2 <memmove>
}
  800b58:	c9                   	leave  
  800b59:	c3                   	ret    

00800b5a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
  800b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b65:	89 c6                	mov    %eax,%esi
  800b67:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b6a:	eb 06                	jmp    800b72 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b6c:	83 c0 01             	add    $0x1,%eax
  800b6f:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800b72:	39 f0                	cmp    %esi,%eax
  800b74:	74 14                	je     800b8a <memcmp+0x30>
		if (*s1 != *s2)
  800b76:	0f b6 08             	movzbl (%eax),%ecx
  800b79:	0f b6 1a             	movzbl (%edx),%ebx
  800b7c:	38 d9                	cmp    %bl,%cl
  800b7e:	74 ec                	je     800b6c <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b80:	0f b6 c1             	movzbl %cl,%eax
  800b83:	0f b6 db             	movzbl %bl,%ebx
  800b86:	29 d8                	sub    %ebx,%eax
  800b88:	eb 05                	jmp    800b8f <memcmp+0x35>
	}

	return 0;
  800b8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b8f:	5b                   	pop    %ebx
  800b90:	5e                   	pop    %esi
  800b91:	5d                   	pop    %ebp
  800b92:	c3                   	ret    

00800b93 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	8b 45 08             	mov    0x8(%ebp),%eax
  800b99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b9c:	89 c2                	mov    %eax,%edx
  800b9e:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ba1:	eb 03                	jmp    800ba6 <memfind+0x13>
  800ba3:	83 c0 01             	add    $0x1,%eax
  800ba6:	39 d0                	cmp    %edx,%eax
  800ba8:	73 04                	jae    800bae <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800baa:	38 08                	cmp    %cl,(%eax)
  800bac:	75 f5                	jne    800ba3 <memfind+0x10>
			break;
	return (void *) s;
}
  800bae:	5d                   	pop    %ebp
  800baf:	c3                   	ret    

00800bb0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	57                   	push   %edi
  800bb4:	56                   	push   %esi
  800bb5:	53                   	push   %ebx
  800bb6:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bbc:	eb 03                	jmp    800bc1 <strtol+0x11>
		s++;
  800bbe:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800bc1:	0f b6 02             	movzbl (%edx),%eax
  800bc4:	3c 20                	cmp    $0x20,%al
  800bc6:	74 f6                	je     800bbe <strtol+0xe>
  800bc8:	3c 09                	cmp    $0x9,%al
  800bca:	74 f2                	je     800bbe <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800bcc:	3c 2b                	cmp    $0x2b,%al
  800bce:	74 2a                	je     800bfa <strtol+0x4a>
	int neg = 0;
  800bd0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bd5:	3c 2d                	cmp    $0x2d,%al
  800bd7:	74 2b                	je     800c04 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bd9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bdf:	75 0f                	jne    800bf0 <strtol+0x40>
  800be1:	80 3a 30             	cmpb   $0x30,(%edx)
  800be4:	74 28                	je     800c0e <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800be6:	85 db                	test   %ebx,%ebx
  800be8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bed:	0f 44 d8             	cmove  %eax,%ebx
  800bf0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bf8:	eb 46                	jmp    800c40 <strtol+0x90>
		s++;
  800bfa:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800bfd:	bf 00 00 00 00       	mov    $0x0,%edi
  800c02:	eb d5                	jmp    800bd9 <strtol+0x29>
		s++, neg = 1;
  800c04:	83 c2 01             	add    $0x1,%edx
  800c07:	bf 01 00 00 00       	mov    $0x1,%edi
  800c0c:	eb cb                	jmp    800bd9 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c0e:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c12:	74 0e                	je     800c22 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800c14:	85 db                	test   %ebx,%ebx
  800c16:	75 d8                	jne    800bf0 <strtol+0x40>
		s++, base = 8;
  800c18:	83 c2 01             	add    $0x1,%edx
  800c1b:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c20:	eb ce                	jmp    800bf0 <strtol+0x40>
		s += 2, base = 16;
  800c22:	83 c2 02             	add    $0x2,%edx
  800c25:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c2a:	eb c4                	jmp    800bf0 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c2c:	0f be c0             	movsbl %al,%eax
  800c2f:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c32:	3b 45 10             	cmp    0x10(%ebp),%eax
  800c35:	7d 3a                	jge    800c71 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c37:	83 c2 01             	add    $0x1,%edx
  800c3a:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800c3e:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800c40:	0f b6 02             	movzbl (%edx),%eax
  800c43:	8d 70 d0             	lea    -0x30(%eax),%esi
  800c46:	89 f3                	mov    %esi,%ebx
  800c48:	80 fb 09             	cmp    $0x9,%bl
  800c4b:	76 df                	jbe    800c2c <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800c4d:	8d 70 9f             	lea    -0x61(%eax),%esi
  800c50:	89 f3                	mov    %esi,%ebx
  800c52:	80 fb 19             	cmp    $0x19,%bl
  800c55:	77 08                	ja     800c5f <strtol+0xaf>
			dig = *s - 'a' + 10;
  800c57:	0f be c0             	movsbl %al,%eax
  800c5a:	83 e8 57             	sub    $0x57,%eax
  800c5d:	eb d3                	jmp    800c32 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800c5f:	8d 70 bf             	lea    -0x41(%eax),%esi
  800c62:	89 f3                	mov    %esi,%ebx
  800c64:	80 fb 19             	cmp    $0x19,%bl
  800c67:	77 08                	ja     800c71 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c69:	0f be c0             	movsbl %al,%eax
  800c6c:	83 e8 37             	sub    $0x37,%eax
  800c6f:	eb c1                	jmp    800c32 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c71:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c75:	74 05                	je     800c7c <strtol+0xcc>
		*endptr = (char *) s;
  800c77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c7a:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c7c:	89 c8                	mov    %ecx,%eax
  800c7e:	f7 d8                	neg    %eax
  800c80:	85 ff                	test   %edi,%edi
  800c82:	0f 45 c8             	cmovne %eax,%ecx
}
  800c85:	89 c8                	mov    %ecx,%eax
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    

00800c8c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	57                   	push   %edi
  800c90:	56                   	push   %esi
  800c91:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c92:	b8 00 00 00 00       	mov    $0x0,%eax
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9d:	89 c3                	mov    %eax,%ebx
  800c9f:	89 c7                	mov    %eax,%edi
  800ca1:	89 c6                	mov    %eax,%esi
  800ca3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_cgetc>:

int
sys_cgetc(void)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	57                   	push   %edi
  800cae:	56                   	push   %esi
  800caf:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cb0:	ba 00 00 00 00       	mov    $0x0,%edx
  800cb5:	b8 01 00 00 00       	mov    $0x1,%eax
  800cba:	89 d1                	mov    %edx,%ecx
  800cbc:	89 d3                	mov    %edx,%ebx
  800cbe:	89 d7                	mov    %edx,%edi
  800cc0:	89 d6                	mov    %edx,%esi
  800cc2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    

00800cc9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cd2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	b8 03 00 00 00       	mov    $0x3,%eax
  800cdf:	89 cb                	mov    %ecx,%ebx
  800ce1:	89 cf                	mov    %ecx,%edi
  800ce3:	89 ce                	mov    %ecx,%esi
  800ce5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800ce7:	85 c0                	test   %eax,%eax
  800ce9:	7f 08                	jg     800cf3 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ceb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5f                   	pop    %edi
  800cf1:	5d                   	pop    %ebp
  800cf2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf3:	83 ec 0c             	sub    $0xc,%esp
  800cf6:	50                   	push   %eax
  800cf7:	6a 03                	push   $0x3
  800cf9:	68 3f 2b 80 00       	push   $0x802b3f
  800cfe:	6a 2a                	push   $0x2a
  800d00:	68 5c 2b 80 00       	push   $0x802b5c
  800d05:	e8 8d f5 ff ff       	call   800297 <_panic>

00800d0a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d10:	ba 00 00 00 00       	mov    $0x0,%edx
  800d15:	b8 02 00 00 00       	mov    $0x2,%eax
  800d1a:	89 d1                	mov    %edx,%ecx
  800d1c:	89 d3                	mov    %edx,%ebx
  800d1e:	89 d7                	mov    %edx,%edi
  800d20:	89 d6                	mov    %edx,%esi
  800d22:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <sys_yield>:

void
sys_yield(void)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	57                   	push   %edi
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d34:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d39:	89 d1                	mov    %edx,%ecx
  800d3b:	89 d3                	mov    %edx,%ebx
  800d3d:	89 d7                	mov    %edx,%edi
  800d3f:	89 d6                	mov    %edx,%esi
  800d41:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
  800d4e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d51:	be 00 00 00 00       	mov    $0x0,%esi
  800d56:	8b 55 08             	mov    0x8(%ebp),%edx
  800d59:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5c:	b8 04 00 00 00       	mov    $0x4,%eax
  800d61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d64:	89 f7                	mov    %esi,%edi
  800d66:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	7f 08                	jg     800d74 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d6f:	5b                   	pop    %ebx
  800d70:	5e                   	pop    %esi
  800d71:	5f                   	pop    %edi
  800d72:	5d                   	pop    %ebp
  800d73:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d74:	83 ec 0c             	sub    $0xc,%esp
  800d77:	50                   	push   %eax
  800d78:	6a 04                	push   $0x4
  800d7a:	68 3f 2b 80 00       	push   $0x802b3f
  800d7f:	6a 2a                	push   $0x2a
  800d81:	68 5c 2b 80 00       	push   $0x802b5c
  800d86:	e8 0c f5 ff ff       	call   800297 <_panic>

00800d8b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	57                   	push   %edi
  800d8f:	56                   	push   %esi
  800d90:	53                   	push   %ebx
  800d91:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d94:	8b 55 08             	mov    0x8(%ebp),%edx
  800d97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d9a:	b8 05 00 00 00       	mov    $0x5,%eax
  800d9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800da2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800da5:	8b 75 18             	mov    0x18(%ebp),%esi
  800da8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800daa:	85 c0                	test   %eax,%eax
  800dac:	7f 08                	jg     800db6 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800dae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db1:	5b                   	pop    %ebx
  800db2:	5e                   	pop    %esi
  800db3:	5f                   	pop    %edi
  800db4:	5d                   	pop    %ebp
  800db5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db6:	83 ec 0c             	sub    $0xc,%esp
  800db9:	50                   	push   %eax
  800dba:	6a 05                	push   $0x5
  800dbc:	68 3f 2b 80 00       	push   $0x802b3f
  800dc1:	6a 2a                	push   $0x2a
  800dc3:	68 5c 2b 80 00       	push   $0x802b5c
  800dc8:	e8 ca f4 ff ff       	call   800297 <_panic>

00800dcd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	57                   	push   %edi
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
  800dd3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ddb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dde:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de1:	b8 06 00 00 00       	mov    $0x6,%eax
  800de6:	89 df                	mov    %ebx,%edi
  800de8:	89 de                	mov    %ebx,%esi
  800dea:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dec:	85 c0                	test   %eax,%eax
  800dee:	7f 08                	jg     800df8 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800df3:	5b                   	pop    %ebx
  800df4:	5e                   	pop    %esi
  800df5:	5f                   	pop    %edi
  800df6:	5d                   	pop    %ebp
  800df7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800df8:	83 ec 0c             	sub    $0xc,%esp
  800dfb:	50                   	push   %eax
  800dfc:	6a 06                	push   $0x6
  800dfe:	68 3f 2b 80 00       	push   $0x802b3f
  800e03:	6a 2a                	push   $0x2a
  800e05:	68 5c 2b 80 00       	push   $0x802b5c
  800e0a:	e8 88 f4 ff ff       	call   800297 <_panic>

00800e0f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	57                   	push   %edi
  800e13:	56                   	push   %esi
  800e14:	53                   	push   %ebx
  800e15:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e23:	b8 08 00 00 00       	mov    $0x8,%eax
  800e28:	89 df                	mov    %ebx,%edi
  800e2a:	89 de                	mov    %ebx,%esi
  800e2c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e2e:	85 c0                	test   %eax,%eax
  800e30:	7f 08                	jg     800e3a <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e32:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e35:	5b                   	pop    %ebx
  800e36:	5e                   	pop    %esi
  800e37:	5f                   	pop    %edi
  800e38:	5d                   	pop    %ebp
  800e39:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3a:	83 ec 0c             	sub    $0xc,%esp
  800e3d:	50                   	push   %eax
  800e3e:	6a 08                	push   $0x8
  800e40:	68 3f 2b 80 00       	push   $0x802b3f
  800e45:	6a 2a                	push   $0x2a
  800e47:	68 5c 2b 80 00       	push   $0x802b5c
  800e4c:	e8 46 f4 ff ff       	call   800297 <_panic>

00800e51 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	57                   	push   %edi
  800e55:	56                   	push   %esi
  800e56:	53                   	push   %ebx
  800e57:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e62:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e65:	b8 09 00 00 00       	mov    $0x9,%eax
  800e6a:	89 df                	mov    %ebx,%edi
  800e6c:	89 de                	mov    %ebx,%esi
  800e6e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e70:	85 c0                	test   %eax,%eax
  800e72:	7f 08                	jg     800e7c <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e77:	5b                   	pop    %ebx
  800e78:	5e                   	pop    %esi
  800e79:	5f                   	pop    %edi
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7c:	83 ec 0c             	sub    $0xc,%esp
  800e7f:	50                   	push   %eax
  800e80:	6a 09                	push   $0x9
  800e82:	68 3f 2b 80 00       	push   $0x802b3f
  800e87:	6a 2a                	push   $0x2a
  800e89:	68 5c 2b 80 00       	push   $0x802b5c
  800e8e:	e8 04 f4 ff ff       	call   800297 <_panic>

00800e93 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	57                   	push   %edi
  800e97:	56                   	push   %esi
  800e98:	53                   	push   %ebx
  800e99:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea1:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800eac:	89 df                	mov    %ebx,%edi
  800eae:	89 de                	mov    %ebx,%esi
  800eb0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	7f 08                	jg     800ebe <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800eb6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb9:	5b                   	pop    %ebx
  800eba:	5e                   	pop    %esi
  800ebb:	5f                   	pop    %edi
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebe:	83 ec 0c             	sub    $0xc,%esp
  800ec1:	50                   	push   %eax
  800ec2:	6a 0a                	push   $0xa
  800ec4:	68 3f 2b 80 00       	push   $0x802b3f
  800ec9:	6a 2a                	push   $0x2a
  800ecb:	68 5c 2b 80 00       	push   $0x802b5c
  800ed0:	e8 c2 f3 ff ff       	call   800297 <_panic>

00800ed5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	57                   	push   %edi
  800ed9:	56                   	push   %esi
  800eda:	53                   	push   %ebx
	asm volatile("int %1\n"
  800edb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ede:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee1:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ee6:	be 00 00 00 00       	mov    $0x0,%esi
  800eeb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ef1:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ef3:	5b                   	pop    %ebx
  800ef4:	5e                   	pop    %esi
  800ef5:	5f                   	pop    %edi
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    

00800ef8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	57                   	push   %edi
  800efc:	56                   	push   %esi
  800efd:	53                   	push   %ebx
  800efe:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800f01:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f06:	8b 55 08             	mov    0x8(%ebp),%edx
  800f09:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f0e:	89 cb                	mov    %ecx,%ebx
  800f10:	89 cf                	mov    %ecx,%edi
  800f12:	89 ce                	mov    %ecx,%esi
  800f14:	cd 30                	int    $0x30
	if(check && ret > 0)
  800f16:	85 c0                	test   %eax,%eax
  800f18:	7f 08                	jg     800f22 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f1d:	5b                   	pop    %ebx
  800f1e:	5e                   	pop    %esi
  800f1f:	5f                   	pop    %edi
  800f20:	5d                   	pop    %ebp
  800f21:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f22:	83 ec 0c             	sub    $0xc,%esp
  800f25:	50                   	push   %eax
  800f26:	6a 0d                	push   $0xd
  800f28:	68 3f 2b 80 00       	push   $0x802b3f
  800f2d:	6a 2a                	push   $0x2a
  800f2f:	68 5c 2b 80 00       	push   $0x802b5c
  800f34:	e8 5e f3 ff ff       	call   800297 <_panic>

00800f39 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	57                   	push   %edi
  800f3d:	56                   	push   %esi
  800f3e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f44:	b8 0e 00 00 00       	mov    $0xe,%eax
  800f49:	89 d1                	mov    %edx,%ecx
  800f4b:	89 d3                	mov    %edx,%ebx
  800f4d:	89 d7                	mov    %edx,%edi
  800f4f:	89 d6                	mov    %edx,%esi
  800f51:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800f53:	5b                   	pop    %ebx
  800f54:	5e                   	pop    %esi
  800f55:	5f                   	pop    %edi
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    

00800f58 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	57                   	push   %edi
  800f5c:	56                   	push   %esi
  800f5d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f63:	8b 55 08             	mov    0x8(%ebp),%edx
  800f66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f69:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f6e:	89 df                	mov    %ebx,%edi
  800f70:	89 de                	mov    %ebx,%esi
  800f72:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800f74:	5b                   	pop    %ebx
  800f75:	5e                   	pop    %esi
  800f76:	5f                   	pop    %edi
  800f77:	5d                   	pop    %ebp
  800f78:	c3                   	ret    

00800f79 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800f79:	55                   	push   %ebp
  800f7a:	89 e5                	mov    %esp,%ebp
  800f7c:	57                   	push   %edi
  800f7d:	56                   	push   %esi
  800f7e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f84:	8b 55 08             	mov    0x8(%ebp),%edx
  800f87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8a:	b8 10 00 00 00       	mov    $0x10,%eax
  800f8f:	89 df                	mov    %ebx,%edi
  800f91:	89 de                	mov    %ebx,%esi
  800f93:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800f95:	5b                   	pop    %ebx
  800f96:	5e                   	pop    %esi
  800f97:	5f                   	pop    %edi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    

00800f9a <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	56                   	push   %esi
  800f9e:	53                   	push   %ebx
  800f9f:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fa2:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800fa4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fa8:	0f 84 8e 00 00 00    	je     80103c <pgfault+0xa2>
  800fae:	89 f0                	mov    %esi,%eax
  800fb0:	c1 e8 0c             	shr    $0xc,%eax
  800fb3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fba:	f6 c4 08             	test   $0x8,%ah
  800fbd:	74 7d                	je     80103c <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800fbf:	e8 46 fd ff ff       	call   800d0a <sys_getenvid>
  800fc4:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800fc6:	83 ec 04             	sub    $0x4,%esp
  800fc9:	6a 07                	push   $0x7
  800fcb:	68 00 f0 7f 00       	push   $0x7ff000
  800fd0:	50                   	push   %eax
  800fd1:	e8 72 fd ff ff       	call   800d48 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800fd6:	83 c4 10             	add    $0x10,%esp
  800fd9:	85 c0                	test   %eax,%eax
  800fdb:	78 73                	js     801050 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800fdd:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800fe3:	83 ec 04             	sub    $0x4,%esp
  800fe6:	68 00 10 00 00       	push   $0x1000
  800feb:	56                   	push   %esi
  800fec:	68 00 f0 7f 00       	push   $0x7ff000
  800ff1:	e8 ec fa ff ff       	call   800ae2 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800ff6:	83 c4 08             	add    $0x8,%esp
  800ff9:	56                   	push   %esi
  800ffa:	53                   	push   %ebx
  800ffb:	e8 cd fd ff ff       	call   800dcd <sys_page_unmap>
  801000:	83 c4 10             	add    $0x10,%esp
  801003:	85 c0                	test   %eax,%eax
  801005:	78 5b                	js     801062 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  801007:	83 ec 0c             	sub    $0xc,%esp
  80100a:	6a 07                	push   $0x7
  80100c:	56                   	push   %esi
  80100d:	53                   	push   %ebx
  80100e:	68 00 f0 7f 00       	push   $0x7ff000
  801013:	53                   	push   %ebx
  801014:	e8 72 fd ff ff       	call   800d8b <sys_page_map>
  801019:	83 c4 20             	add    $0x20,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	78 54                	js     801074 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  801020:	83 ec 08             	sub    $0x8,%esp
  801023:	68 00 f0 7f 00       	push   $0x7ff000
  801028:	53                   	push   %ebx
  801029:	e8 9f fd ff ff       	call   800dcd <sys_page_unmap>
  80102e:	83 c4 10             	add    $0x10,%esp
  801031:	85 c0                	test   %eax,%eax
  801033:	78 51                	js     801086 <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  801035:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801038:	5b                   	pop    %ebx
  801039:	5e                   	pop    %esi
  80103a:	5d                   	pop    %ebp
  80103b:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  80103c:	83 ec 04             	sub    $0x4,%esp
  80103f:	68 6c 2b 80 00       	push   $0x802b6c
  801044:	6a 1d                	push   $0x1d
  801046:	68 e8 2b 80 00       	push   $0x802be8
  80104b:	e8 47 f2 ff ff       	call   800297 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  801050:	50                   	push   %eax
  801051:	68 a4 2b 80 00       	push   $0x802ba4
  801056:	6a 29                	push   $0x29
  801058:	68 e8 2b 80 00       	push   $0x802be8
  80105d:	e8 35 f2 ff ff       	call   800297 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  801062:	50                   	push   %eax
  801063:	68 c8 2b 80 00       	push   $0x802bc8
  801068:	6a 2e                	push   $0x2e
  80106a:	68 e8 2b 80 00       	push   $0x802be8
  80106f:	e8 23 f2 ff ff       	call   800297 <_panic>
		panic("pgfault: page map failed (%e)", r);
  801074:	50                   	push   %eax
  801075:	68 f3 2b 80 00       	push   $0x802bf3
  80107a:	6a 30                	push   $0x30
  80107c:	68 e8 2b 80 00       	push   $0x802be8
  801081:	e8 11 f2 ff ff       	call   800297 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  801086:	50                   	push   %eax
  801087:	68 c8 2b 80 00       	push   $0x802bc8
  80108c:	6a 32                	push   $0x32
  80108e:	68 e8 2b 80 00       	push   $0x802be8
  801093:	e8 ff f1 ff ff       	call   800297 <_panic>

00801098 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801098:	55                   	push   %ebp
  801099:	89 e5                	mov    %esp,%ebp
  80109b:	57                   	push   %edi
  80109c:	56                   	push   %esi
  80109d:	53                   	push   %ebx
  80109e:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  8010a1:	68 9a 0f 80 00       	push   $0x800f9a
  8010a6:	e8 7e 12 00 00       	call   802329 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010ab:	b8 07 00 00 00       	mov    $0x7,%eax
  8010b0:	cd 30                	int    $0x30
  8010b2:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  8010b5:	83 c4 10             	add    $0x10,%esp
  8010b8:	85 c0                	test   %eax,%eax
  8010ba:	78 30                	js     8010ec <fork+0x54>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  8010bc:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  8010c1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8010c5:	75 76                	jne    80113d <fork+0xa5>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010c7:	e8 3e fc ff ff       	call   800d0a <sys_getenvid>
  8010cc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010d1:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8010d7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010dc:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  8010e1:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  8010e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e7:	5b                   	pop    %ebx
  8010e8:	5e                   	pop    %esi
  8010e9:	5f                   	pop    %edi
  8010ea:	5d                   	pop    %ebp
  8010eb:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  8010ec:	50                   	push   %eax
  8010ed:	68 11 2c 80 00       	push   $0x802c11
  8010f2:	6a 78                	push   $0x78
  8010f4:	68 e8 2b 80 00       	push   $0x802be8
  8010f9:	e8 99 f1 ff ff       	call   800297 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  8010fe:	83 ec 0c             	sub    $0xc,%esp
  801101:	ff 75 e4             	push   -0x1c(%ebp)
  801104:	57                   	push   %edi
  801105:	ff 75 dc             	push   -0x24(%ebp)
  801108:	57                   	push   %edi
  801109:	8b 75 e0             	mov    -0x20(%ebp),%esi
  80110c:	56                   	push   %esi
  80110d:	e8 79 fc ff ff       	call   800d8b <sys_page_map>
	if(r<0) return r;
  801112:	83 c4 20             	add    $0x20,%esp
  801115:	85 c0                	test   %eax,%eax
  801117:	78 cb                	js     8010e4 <fork+0x4c>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  801119:	83 ec 0c             	sub    $0xc,%esp
  80111c:	ff 75 e4             	push   -0x1c(%ebp)
  80111f:	57                   	push   %edi
  801120:	56                   	push   %esi
  801121:	57                   	push   %edi
  801122:	56                   	push   %esi
  801123:	e8 63 fc ff ff       	call   800d8b <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  801128:	83 c4 20             	add    $0x20,%esp
  80112b:	85 c0                	test   %eax,%eax
  80112d:	78 76                	js     8011a5 <fork+0x10d>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  80112f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801135:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80113b:	74 75                	je     8011b2 <fork+0x11a>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  80113d:	89 d8                	mov    %ebx,%eax
  80113f:	c1 e8 16             	shr    $0x16,%eax
  801142:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801149:	a8 01                	test   $0x1,%al
  80114b:	74 e2                	je     80112f <fork+0x97>
  80114d:	89 de                	mov    %ebx,%esi
  80114f:	c1 ee 0c             	shr    $0xc,%esi
  801152:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801159:	a8 01                	test   $0x1,%al
  80115b:	74 d2                	je     80112f <fork+0x97>
	envid_t this_envid = sys_getenvid();//父进程号
  80115d:	e8 a8 fb ff ff       	call   800d0a <sys_getenvid>
  801162:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  801165:	89 f7                	mov    %esi,%edi
  801167:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  80116a:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801171:	89 c1                	mov    %eax,%ecx
  801173:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801179:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  80117c:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  801183:	f6 c6 04             	test   $0x4,%dh
  801186:	0f 85 72 ff ff ff    	jne    8010fe <fork+0x66>
		perm &= ~PTE_W;
  80118c:	25 05 0e 00 00       	and    $0xe05,%eax
  801191:	80 cc 08             	or     $0x8,%ah
  801194:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  80119a:	0f 44 c1             	cmove  %ecx,%eax
  80119d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8011a0:	e9 59 ff ff ff       	jmp    8010fe <fork+0x66>
  8011a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8011aa:	0f 4f c2             	cmovg  %edx,%eax
  8011ad:	e9 32 ff ff ff       	jmp    8010e4 <fork+0x4c>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  8011b2:	83 ec 04             	sub    $0x4,%esp
  8011b5:	6a 07                	push   $0x7
  8011b7:	68 00 f0 bf ee       	push   $0xeebff000
  8011bc:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8011bf:	57                   	push   %edi
  8011c0:	e8 83 fb ff ff       	call   800d48 <sys_page_alloc>
	if(r<0) return r;
  8011c5:	83 c4 10             	add    $0x10,%esp
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	0f 88 14 ff ff ff    	js     8010e4 <fork+0x4c>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8011d0:	83 ec 08             	sub    $0x8,%esp
  8011d3:	68 9f 23 80 00       	push   $0x80239f
  8011d8:	57                   	push   %edi
  8011d9:	e8 b5 fc ff ff       	call   800e93 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  8011de:	83 c4 10             	add    $0x10,%esp
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	0f 88 fb fe ff ff    	js     8010e4 <fork+0x4c>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8011e9:	83 ec 08             	sub    $0x8,%esp
  8011ec:	6a 02                	push   $0x2
  8011ee:	57                   	push   %edi
  8011ef:	e8 1b fc ff ff       	call   800e0f <sys_env_set_status>
	if(r<0) return r;
  8011f4:	83 c4 10             	add    $0x10,%esp
	return envid;
  8011f7:	85 c0                	test   %eax,%eax
  8011f9:	0f 49 c7             	cmovns %edi,%eax
  8011fc:	e9 e3 fe ff ff       	jmp    8010e4 <fork+0x4c>

00801201 <sfork>:

// Challenge!
int
sfork(void)
{
  801201:	55                   	push   %ebp
  801202:	89 e5                	mov    %esp,%ebp
  801204:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801207:	68 21 2c 80 00       	push   $0x802c21
  80120c:	68 a1 00 00 00       	push   $0xa1
  801211:	68 e8 2b 80 00       	push   $0x802be8
  801216:	e8 7c f0 ff ff       	call   800297 <_panic>

0080121b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80121e:	8b 45 08             	mov    0x8(%ebp),%eax
  801221:	05 00 00 00 30       	add    $0x30000000,%eax
  801226:	c1 e8 0c             	shr    $0xc,%eax
}
  801229:	5d                   	pop    %ebp
  80122a:	c3                   	ret    

0080122b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80122e:	8b 45 08             	mov    0x8(%ebp),%eax
  801231:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801236:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80123b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801240:	5d                   	pop    %ebp
  801241:	c3                   	ret    

00801242 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80124a:	89 c2                	mov    %eax,%edx
  80124c:	c1 ea 16             	shr    $0x16,%edx
  80124f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801256:	f6 c2 01             	test   $0x1,%dl
  801259:	74 29                	je     801284 <fd_alloc+0x42>
  80125b:	89 c2                	mov    %eax,%edx
  80125d:	c1 ea 0c             	shr    $0xc,%edx
  801260:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801267:	f6 c2 01             	test   $0x1,%dl
  80126a:	74 18                	je     801284 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  80126c:	05 00 10 00 00       	add    $0x1000,%eax
  801271:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801276:	75 d2                	jne    80124a <fd_alloc+0x8>
  801278:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80127d:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801282:	eb 05                	jmp    801289 <fd_alloc+0x47>
			return 0;
  801284:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801289:	8b 55 08             	mov    0x8(%ebp),%edx
  80128c:	89 02                	mov    %eax,(%edx)
}
  80128e:	89 c8                	mov    %ecx,%eax
  801290:	5d                   	pop    %ebp
  801291:	c3                   	ret    

00801292 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801298:	83 f8 1f             	cmp    $0x1f,%eax
  80129b:	77 30                	ja     8012cd <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80129d:	c1 e0 0c             	shl    $0xc,%eax
  8012a0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8012a5:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8012ab:	f6 c2 01             	test   $0x1,%dl
  8012ae:	74 24                	je     8012d4 <fd_lookup+0x42>
  8012b0:	89 c2                	mov    %eax,%edx
  8012b2:	c1 ea 0c             	shr    $0xc,%edx
  8012b5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012bc:	f6 c2 01             	test   $0x1,%dl
  8012bf:	74 1a                	je     8012db <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012c4:	89 02                	mov    %eax,(%edx)
	return 0;
  8012c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8012cb:	5d                   	pop    %ebp
  8012cc:	c3                   	ret    
		return -E_INVAL;
  8012cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d2:	eb f7                	jmp    8012cb <fd_lookup+0x39>
		return -E_INVAL;
  8012d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d9:	eb f0                	jmp    8012cb <fd_lookup+0x39>
  8012db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e0:	eb e9                	jmp    8012cb <fd_lookup+0x39>

008012e2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	53                   	push   %ebx
  8012e6:	83 ec 04             	sub    $0x4,%esp
  8012e9:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8012ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f1:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8012f6:	39 13                	cmp    %edx,(%ebx)
  8012f8:	74 37                	je     801331 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8012fa:	83 c0 01             	add    $0x1,%eax
  8012fd:	8b 1c 85 b4 2c 80 00 	mov    0x802cb4(,%eax,4),%ebx
  801304:	85 db                	test   %ebx,%ebx
  801306:	75 ee                	jne    8012f6 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801308:	a1 00 40 80 00       	mov    0x804000,%eax
  80130d:	8b 40 58             	mov    0x58(%eax),%eax
  801310:	83 ec 04             	sub    $0x4,%esp
  801313:	52                   	push   %edx
  801314:	50                   	push   %eax
  801315:	68 38 2c 80 00       	push   $0x802c38
  80131a:	e8 53 f0 ff ff       	call   800372 <cprintf>
	*dev = 0;
	return -E_INVAL;
  80131f:	83 c4 10             	add    $0x10,%esp
  801322:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801327:	8b 55 0c             	mov    0xc(%ebp),%edx
  80132a:	89 1a                	mov    %ebx,(%edx)
}
  80132c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80132f:	c9                   	leave  
  801330:	c3                   	ret    
			return 0;
  801331:	b8 00 00 00 00       	mov    $0x0,%eax
  801336:	eb ef                	jmp    801327 <dev_lookup+0x45>

00801338 <fd_close>:
{
  801338:	55                   	push   %ebp
  801339:	89 e5                	mov    %esp,%ebp
  80133b:	57                   	push   %edi
  80133c:	56                   	push   %esi
  80133d:	53                   	push   %ebx
  80133e:	83 ec 24             	sub    $0x24,%esp
  801341:	8b 75 08             	mov    0x8(%ebp),%esi
  801344:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801347:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80134a:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80134b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801351:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801354:	50                   	push   %eax
  801355:	e8 38 ff ff ff       	call   801292 <fd_lookup>
  80135a:	89 c3                	mov    %eax,%ebx
  80135c:	83 c4 10             	add    $0x10,%esp
  80135f:	85 c0                	test   %eax,%eax
  801361:	78 05                	js     801368 <fd_close+0x30>
	    || fd != fd2)
  801363:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801366:	74 16                	je     80137e <fd_close+0x46>
		return (must_exist ? r : 0);
  801368:	89 f8                	mov    %edi,%eax
  80136a:	84 c0                	test   %al,%al
  80136c:	b8 00 00 00 00       	mov    $0x0,%eax
  801371:	0f 44 d8             	cmove  %eax,%ebx
}
  801374:	89 d8                	mov    %ebx,%eax
  801376:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801379:	5b                   	pop    %ebx
  80137a:	5e                   	pop    %esi
  80137b:	5f                   	pop    %edi
  80137c:	5d                   	pop    %ebp
  80137d:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80137e:	83 ec 08             	sub    $0x8,%esp
  801381:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801384:	50                   	push   %eax
  801385:	ff 36                	push   (%esi)
  801387:	e8 56 ff ff ff       	call   8012e2 <dev_lookup>
  80138c:	89 c3                	mov    %eax,%ebx
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	85 c0                	test   %eax,%eax
  801393:	78 1a                	js     8013af <fd_close+0x77>
		if (dev->dev_close)
  801395:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801398:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80139b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	74 0b                	je     8013af <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8013a4:	83 ec 0c             	sub    $0xc,%esp
  8013a7:	56                   	push   %esi
  8013a8:	ff d0                	call   *%eax
  8013aa:	89 c3                	mov    %eax,%ebx
  8013ac:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8013af:	83 ec 08             	sub    $0x8,%esp
  8013b2:	56                   	push   %esi
  8013b3:	6a 00                	push   $0x0
  8013b5:	e8 13 fa ff ff       	call   800dcd <sys_page_unmap>
	return r;
  8013ba:	83 c4 10             	add    $0x10,%esp
  8013bd:	eb b5                	jmp    801374 <fd_close+0x3c>

008013bf <close>:

int
close(int fdnum)
{
  8013bf:	55                   	push   %ebp
  8013c0:	89 e5                	mov    %esp,%ebp
  8013c2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c8:	50                   	push   %eax
  8013c9:	ff 75 08             	push   0x8(%ebp)
  8013cc:	e8 c1 fe ff ff       	call   801292 <fd_lookup>
  8013d1:	83 c4 10             	add    $0x10,%esp
  8013d4:	85 c0                	test   %eax,%eax
  8013d6:	79 02                	jns    8013da <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8013d8:	c9                   	leave  
  8013d9:	c3                   	ret    
		return fd_close(fd, 1);
  8013da:	83 ec 08             	sub    $0x8,%esp
  8013dd:	6a 01                	push   $0x1
  8013df:	ff 75 f4             	push   -0xc(%ebp)
  8013e2:	e8 51 ff ff ff       	call   801338 <fd_close>
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	eb ec                	jmp    8013d8 <close+0x19>

008013ec <close_all>:

void
close_all(void)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	53                   	push   %ebx
  8013f0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8013f3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8013f8:	83 ec 0c             	sub    $0xc,%esp
  8013fb:	53                   	push   %ebx
  8013fc:	e8 be ff ff ff       	call   8013bf <close>
	for (i = 0; i < MAXFD; i++)
  801401:	83 c3 01             	add    $0x1,%ebx
  801404:	83 c4 10             	add    $0x10,%esp
  801407:	83 fb 20             	cmp    $0x20,%ebx
  80140a:	75 ec                	jne    8013f8 <close_all+0xc>
}
  80140c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80140f:	c9                   	leave  
  801410:	c3                   	ret    

00801411 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801411:	55                   	push   %ebp
  801412:	89 e5                	mov    %esp,%ebp
  801414:	57                   	push   %edi
  801415:	56                   	push   %esi
  801416:	53                   	push   %ebx
  801417:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80141a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80141d:	50                   	push   %eax
  80141e:	ff 75 08             	push   0x8(%ebp)
  801421:	e8 6c fe ff ff       	call   801292 <fd_lookup>
  801426:	89 c3                	mov    %eax,%ebx
  801428:	83 c4 10             	add    $0x10,%esp
  80142b:	85 c0                	test   %eax,%eax
  80142d:	78 7f                	js     8014ae <dup+0x9d>
		return r;
	close(newfdnum);
  80142f:	83 ec 0c             	sub    $0xc,%esp
  801432:	ff 75 0c             	push   0xc(%ebp)
  801435:	e8 85 ff ff ff       	call   8013bf <close>

	newfd = INDEX2FD(newfdnum);
  80143a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80143d:	c1 e6 0c             	shl    $0xc,%esi
  801440:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801449:	89 3c 24             	mov    %edi,(%esp)
  80144c:	e8 da fd ff ff       	call   80122b <fd2data>
  801451:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801453:	89 34 24             	mov    %esi,(%esp)
  801456:	e8 d0 fd ff ff       	call   80122b <fd2data>
  80145b:	83 c4 10             	add    $0x10,%esp
  80145e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801461:	89 d8                	mov    %ebx,%eax
  801463:	c1 e8 16             	shr    $0x16,%eax
  801466:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80146d:	a8 01                	test   $0x1,%al
  80146f:	74 11                	je     801482 <dup+0x71>
  801471:	89 d8                	mov    %ebx,%eax
  801473:	c1 e8 0c             	shr    $0xc,%eax
  801476:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80147d:	f6 c2 01             	test   $0x1,%dl
  801480:	75 36                	jne    8014b8 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801482:	89 f8                	mov    %edi,%eax
  801484:	c1 e8 0c             	shr    $0xc,%eax
  801487:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80148e:	83 ec 0c             	sub    $0xc,%esp
  801491:	25 07 0e 00 00       	and    $0xe07,%eax
  801496:	50                   	push   %eax
  801497:	56                   	push   %esi
  801498:	6a 00                	push   $0x0
  80149a:	57                   	push   %edi
  80149b:	6a 00                	push   $0x0
  80149d:	e8 e9 f8 ff ff       	call   800d8b <sys_page_map>
  8014a2:	89 c3                	mov    %eax,%ebx
  8014a4:	83 c4 20             	add    $0x20,%esp
  8014a7:	85 c0                	test   %eax,%eax
  8014a9:	78 33                	js     8014de <dup+0xcd>
		goto err;

	return newfdnum;
  8014ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8014ae:	89 d8                	mov    %ebx,%eax
  8014b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014b3:	5b                   	pop    %ebx
  8014b4:	5e                   	pop    %esi
  8014b5:	5f                   	pop    %edi
  8014b6:	5d                   	pop    %ebp
  8014b7:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014b8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014bf:	83 ec 0c             	sub    $0xc,%esp
  8014c2:	25 07 0e 00 00       	and    $0xe07,%eax
  8014c7:	50                   	push   %eax
  8014c8:	ff 75 d4             	push   -0x2c(%ebp)
  8014cb:	6a 00                	push   $0x0
  8014cd:	53                   	push   %ebx
  8014ce:	6a 00                	push   $0x0
  8014d0:	e8 b6 f8 ff ff       	call   800d8b <sys_page_map>
  8014d5:	89 c3                	mov    %eax,%ebx
  8014d7:	83 c4 20             	add    $0x20,%esp
  8014da:	85 c0                	test   %eax,%eax
  8014dc:	79 a4                	jns    801482 <dup+0x71>
	sys_page_unmap(0, newfd);
  8014de:	83 ec 08             	sub    $0x8,%esp
  8014e1:	56                   	push   %esi
  8014e2:	6a 00                	push   $0x0
  8014e4:	e8 e4 f8 ff ff       	call   800dcd <sys_page_unmap>
	sys_page_unmap(0, nva);
  8014e9:	83 c4 08             	add    $0x8,%esp
  8014ec:	ff 75 d4             	push   -0x2c(%ebp)
  8014ef:	6a 00                	push   $0x0
  8014f1:	e8 d7 f8 ff ff       	call   800dcd <sys_page_unmap>
	return r;
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	eb b3                	jmp    8014ae <dup+0x9d>

008014fb <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	56                   	push   %esi
  8014ff:	53                   	push   %ebx
  801500:	83 ec 18             	sub    $0x18,%esp
  801503:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801506:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801509:	50                   	push   %eax
  80150a:	56                   	push   %esi
  80150b:	e8 82 fd ff ff       	call   801292 <fd_lookup>
  801510:	83 c4 10             	add    $0x10,%esp
  801513:	85 c0                	test   %eax,%eax
  801515:	78 3c                	js     801553 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801517:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80151a:	83 ec 08             	sub    $0x8,%esp
  80151d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801520:	50                   	push   %eax
  801521:	ff 33                	push   (%ebx)
  801523:	e8 ba fd ff ff       	call   8012e2 <dev_lookup>
  801528:	83 c4 10             	add    $0x10,%esp
  80152b:	85 c0                	test   %eax,%eax
  80152d:	78 24                	js     801553 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80152f:	8b 43 08             	mov    0x8(%ebx),%eax
  801532:	83 e0 03             	and    $0x3,%eax
  801535:	83 f8 01             	cmp    $0x1,%eax
  801538:	74 20                	je     80155a <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80153a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80153d:	8b 40 08             	mov    0x8(%eax),%eax
  801540:	85 c0                	test   %eax,%eax
  801542:	74 37                	je     80157b <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801544:	83 ec 04             	sub    $0x4,%esp
  801547:	ff 75 10             	push   0x10(%ebp)
  80154a:	ff 75 0c             	push   0xc(%ebp)
  80154d:	53                   	push   %ebx
  80154e:	ff d0                	call   *%eax
  801550:	83 c4 10             	add    $0x10,%esp
}
  801553:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801556:	5b                   	pop    %ebx
  801557:	5e                   	pop    %esi
  801558:	5d                   	pop    %ebp
  801559:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80155a:	a1 00 40 80 00       	mov    0x804000,%eax
  80155f:	8b 40 58             	mov    0x58(%eax),%eax
  801562:	83 ec 04             	sub    $0x4,%esp
  801565:	56                   	push   %esi
  801566:	50                   	push   %eax
  801567:	68 79 2c 80 00       	push   $0x802c79
  80156c:	e8 01 ee ff ff       	call   800372 <cprintf>
		return -E_INVAL;
  801571:	83 c4 10             	add    $0x10,%esp
  801574:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801579:	eb d8                	jmp    801553 <read+0x58>
		return -E_NOT_SUPP;
  80157b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801580:	eb d1                	jmp    801553 <read+0x58>

00801582 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801582:	55                   	push   %ebp
  801583:	89 e5                	mov    %esp,%ebp
  801585:	57                   	push   %edi
  801586:	56                   	push   %esi
  801587:	53                   	push   %ebx
  801588:	83 ec 0c             	sub    $0xc,%esp
  80158b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80158e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801591:	bb 00 00 00 00       	mov    $0x0,%ebx
  801596:	eb 02                	jmp    80159a <readn+0x18>
  801598:	01 c3                	add    %eax,%ebx
  80159a:	39 f3                	cmp    %esi,%ebx
  80159c:	73 21                	jae    8015bf <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80159e:	83 ec 04             	sub    $0x4,%esp
  8015a1:	89 f0                	mov    %esi,%eax
  8015a3:	29 d8                	sub    %ebx,%eax
  8015a5:	50                   	push   %eax
  8015a6:	89 d8                	mov    %ebx,%eax
  8015a8:	03 45 0c             	add    0xc(%ebp),%eax
  8015ab:	50                   	push   %eax
  8015ac:	57                   	push   %edi
  8015ad:	e8 49 ff ff ff       	call   8014fb <read>
		if (m < 0)
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	85 c0                	test   %eax,%eax
  8015b7:	78 04                	js     8015bd <readn+0x3b>
			return m;
		if (m == 0)
  8015b9:	75 dd                	jne    801598 <readn+0x16>
  8015bb:	eb 02                	jmp    8015bf <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015bd:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8015bf:	89 d8                	mov    %ebx,%eax
  8015c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015c4:	5b                   	pop    %ebx
  8015c5:	5e                   	pop    %esi
  8015c6:	5f                   	pop    %edi
  8015c7:	5d                   	pop    %ebp
  8015c8:	c3                   	ret    

008015c9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8015c9:	55                   	push   %ebp
  8015ca:	89 e5                	mov    %esp,%ebp
  8015cc:	56                   	push   %esi
  8015cd:	53                   	push   %ebx
  8015ce:	83 ec 18             	sub    $0x18,%esp
  8015d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015d7:	50                   	push   %eax
  8015d8:	53                   	push   %ebx
  8015d9:	e8 b4 fc ff ff       	call   801292 <fd_lookup>
  8015de:	83 c4 10             	add    $0x10,%esp
  8015e1:	85 c0                	test   %eax,%eax
  8015e3:	78 37                	js     80161c <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e5:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015e8:	83 ec 08             	sub    $0x8,%esp
  8015eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ee:	50                   	push   %eax
  8015ef:	ff 36                	push   (%esi)
  8015f1:	e8 ec fc ff ff       	call   8012e2 <dev_lookup>
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	78 1f                	js     80161c <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015fd:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801601:	74 20                	je     801623 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801603:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801606:	8b 40 0c             	mov    0xc(%eax),%eax
  801609:	85 c0                	test   %eax,%eax
  80160b:	74 37                	je     801644 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80160d:	83 ec 04             	sub    $0x4,%esp
  801610:	ff 75 10             	push   0x10(%ebp)
  801613:	ff 75 0c             	push   0xc(%ebp)
  801616:	56                   	push   %esi
  801617:	ff d0                	call   *%eax
  801619:	83 c4 10             	add    $0x10,%esp
}
  80161c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80161f:	5b                   	pop    %ebx
  801620:	5e                   	pop    %esi
  801621:	5d                   	pop    %ebp
  801622:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801623:	a1 00 40 80 00       	mov    0x804000,%eax
  801628:	8b 40 58             	mov    0x58(%eax),%eax
  80162b:	83 ec 04             	sub    $0x4,%esp
  80162e:	53                   	push   %ebx
  80162f:	50                   	push   %eax
  801630:	68 95 2c 80 00       	push   $0x802c95
  801635:	e8 38 ed ff ff       	call   800372 <cprintf>
		return -E_INVAL;
  80163a:	83 c4 10             	add    $0x10,%esp
  80163d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801642:	eb d8                	jmp    80161c <write+0x53>
		return -E_NOT_SUPP;
  801644:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801649:	eb d1                	jmp    80161c <write+0x53>

0080164b <seek>:

int
seek(int fdnum, off_t offset)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801651:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801654:	50                   	push   %eax
  801655:	ff 75 08             	push   0x8(%ebp)
  801658:	e8 35 fc ff ff       	call   801292 <fd_lookup>
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	85 c0                	test   %eax,%eax
  801662:	78 0e                	js     801672 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801664:	8b 55 0c             	mov    0xc(%ebp),%edx
  801667:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80166a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80166d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801672:	c9                   	leave  
  801673:	c3                   	ret    

00801674 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801674:	55                   	push   %ebp
  801675:	89 e5                	mov    %esp,%ebp
  801677:	56                   	push   %esi
  801678:	53                   	push   %ebx
  801679:	83 ec 18             	sub    $0x18,%esp
  80167c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801682:	50                   	push   %eax
  801683:	53                   	push   %ebx
  801684:	e8 09 fc ff ff       	call   801292 <fd_lookup>
  801689:	83 c4 10             	add    $0x10,%esp
  80168c:	85 c0                	test   %eax,%eax
  80168e:	78 34                	js     8016c4 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801690:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801693:	83 ec 08             	sub    $0x8,%esp
  801696:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801699:	50                   	push   %eax
  80169a:	ff 36                	push   (%esi)
  80169c:	e8 41 fc ff ff       	call   8012e2 <dev_lookup>
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 1c                	js     8016c4 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016a8:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8016ac:	74 1d                	je     8016cb <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8016ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b1:	8b 40 18             	mov    0x18(%eax),%eax
  8016b4:	85 c0                	test   %eax,%eax
  8016b6:	74 34                	je     8016ec <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8016b8:	83 ec 08             	sub    $0x8,%esp
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
			thisenv->env_id, fdnum);
  8016cb:	a1 00 40 80 00       	mov    0x804000,%eax
  8016d0:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016d3:	83 ec 04             	sub    $0x4,%esp
  8016d6:	53                   	push   %ebx
  8016d7:	50                   	push   %eax
  8016d8:	68 58 2c 80 00       	push   $0x802c58
  8016dd:	e8 90 ec ff ff       	call   800372 <cprintf>
		return -E_INVAL;
  8016e2:	83 c4 10             	add    $0x10,%esp
  8016e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016ea:	eb d8                	jmp    8016c4 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8016ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016f1:	eb d1                	jmp    8016c4 <ftruncate+0x50>

008016f3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8016f3:	55                   	push   %ebp
  8016f4:	89 e5                	mov    %esp,%ebp
  8016f6:	56                   	push   %esi
  8016f7:	53                   	push   %ebx
  8016f8:	83 ec 18             	sub    $0x18,%esp
  8016fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016fe:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801701:	50                   	push   %eax
  801702:	ff 75 08             	push   0x8(%ebp)
  801705:	e8 88 fb ff ff       	call   801292 <fd_lookup>
  80170a:	83 c4 10             	add    $0x10,%esp
  80170d:	85 c0                	test   %eax,%eax
  80170f:	78 49                	js     80175a <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801711:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801714:	83 ec 08             	sub    $0x8,%esp
  801717:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80171a:	50                   	push   %eax
  80171b:	ff 36                	push   (%esi)
  80171d:	e8 c0 fb ff ff       	call   8012e2 <dev_lookup>
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	85 c0                	test   %eax,%eax
  801727:	78 31                	js     80175a <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801729:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80172c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801730:	74 2f                	je     801761 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801732:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801735:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80173c:	00 00 00 
	stat->st_isdir = 0;
  80173f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801746:	00 00 00 
	stat->st_dev = dev;
  801749:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80174f:	83 ec 08             	sub    $0x8,%esp
  801752:	53                   	push   %ebx
  801753:	56                   	push   %esi
  801754:	ff 50 14             	call   *0x14(%eax)
  801757:	83 c4 10             	add    $0x10,%esp
}
  80175a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80175d:	5b                   	pop    %ebx
  80175e:	5e                   	pop    %esi
  80175f:	5d                   	pop    %ebp
  801760:	c3                   	ret    
		return -E_NOT_SUPP;
  801761:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801766:	eb f2                	jmp    80175a <fstat+0x67>

00801768 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	56                   	push   %esi
  80176c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80176d:	83 ec 08             	sub    $0x8,%esp
  801770:	6a 00                	push   $0x0
  801772:	ff 75 08             	push   0x8(%ebp)
  801775:	e8 e4 01 00 00       	call   80195e <open>
  80177a:	89 c3                	mov    %eax,%ebx
  80177c:	83 c4 10             	add    $0x10,%esp
  80177f:	85 c0                	test   %eax,%eax
  801781:	78 1b                	js     80179e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801783:	83 ec 08             	sub    $0x8,%esp
  801786:	ff 75 0c             	push   0xc(%ebp)
  801789:	50                   	push   %eax
  80178a:	e8 64 ff ff ff       	call   8016f3 <fstat>
  80178f:	89 c6                	mov    %eax,%esi
	close(fd);
  801791:	89 1c 24             	mov    %ebx,(%esp)
  801794:	e8 26 fc ff ff       	call   8013bf <close>
	return r;
  801799:	83 c4 10             	add    $0x10,%esp
  80179c:	89 f3                	mov    %esi,%ebx
}
  80179e:	89 d8                	mov    %ebx,%eax
  8017a0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a3:	5b                   	pop    %ebx
  8017a4:	5e                   	pop    %esi
  8017a5:	5d                   	pop    %ebp
  8017a6:	c3                   	ret    

008017a7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	56                   	push   %esi
  8017ab:	53                   	push   %ebx
  8017ac:	89 c6                	mov    %eax,%esi
  8017ae:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8017b0:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8017b7:	74 27                	je     8017e0 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8017b9:	6a 07                	push   $0x7
  8017bb:	68 00 50 80 00       	push   $0x805000
  8017c0:	56                   	push   %esi
  8017c1:	ff 35 00 60 80 00    	push   0x806000
  8017c7:	e8 69 0c 00 00       	call   802435 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017cc:	83 c4 0c             	add    $0xc,%esp
  8017cf:	6a 00                	push   $0x0
  8017d1:	53                   	push   %ebx
  8017d2:	6a 00                	push   $0x0
  8017d4:	e8 ec 0b 00 00       	call   8023c5 <ipc_recv>
}
  8017d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017dc:	5b                   	pop    %ebx
  8017dd:	5e                   	pop    %esi
  8017de:	5d                   	pop    %ebp
  8017df:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8017e0:	83 ec 0c             	sub    $0xc,%esp
  8017e3:	6a 01                	push   $0x1
  8017e5:	e8 9f 0c 00 00       	call   802489 <ipc_find_env>
  8017ea:	a3 00 60 80 00       	mov    %eax,0x806000
  8017ef:	83 c4 10             	add    $0x10,%esp
  8017f2:	eb c5                	jmp    8017b9 <fsipc+0x12>

008017f4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fd:	8b 40 0c             	mov    0xc(%eax),%eax
  801800:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801805:	8b 45 0c             	mov    0xc(%ebp),%eax
  801808:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80180d:	ba 00 00 00 00       	mov    $0x0,%edx
  801812:	b8 02 00 00 00       	mov    $0x2,%eax
  801817:	e8 8b ff ff ff       	call   8017a7 <fsipc>
}
  80181c:	c9                   	leave  
  80181d:	c3                   	ret    

0080181e <devfile_flush>:
{
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801824:	8b 45 08             	mov    0x8(%ebp),%eax
  801827:	8b 40 0c             	mov    0xc(%eax),%eax
  80182a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80182f:	ba 00 00 00 00       	mov    $0x0,%edx
  801834:	b8 06 00 00 00       	mov    $0x6,%eax
  801839:	e8 69 ff ff ff       	call   8017a7 <fsipc>
}
  80183e:	c9                   	leave  
  80183f:	c3                   	ret    

00801840 <devfile_stat>:
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	53                   	push   %ebx
  801844:	83 ec 04             	sub    $0x4,%esp
  801847:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80184a:	8b 45 08             	mov    0x8(%ebp),%eax
  80184d:	8b 40 0c             	mov    0xc(%eax),%eax
  801850:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801855:	ba 00 00 00 00       	mov    $0x0,%edx
  80185a:	b8 05 00 00 00       	mov    $0x5,%eax
  80185f:	e8 43 ff ff ff       	call   8017a7 <fsipc>
  801864:	85 c0                	test   %eax,%eax
  801866:	78 2c                	js     801894 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801868:	83 ec 08             	sub    $0x8,%esp
  80186b:	68 00 50 80 00       	push   $0x805000
  801870:	53                   	push   %ebx
  801871:	e8 d6 f0 ff ff       	call   80094c <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801876:	a1 80 50 80 00       	mov    0x805080,%eax
  80187b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801881:	a1 84 50 80 00       	mov    0x805084,%eax
  801886:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80188c:	83 c4 10             	add    $0x10,%esp
  80188f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801894:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801897:	c9                   	leave  
  801898:	c3                   	ret    

00801899 <devfile_write>:
{
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	83 ec 0c             	sub    $0xc,%esp
  80189f:	8b 45 10             	mov    0x10(%ebp),%eax
  8018a2:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018a7:	39 d0                	cmp    %edx,%eax
  8018a9:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8018ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8018af:	8b 52 0c             	mov    0xc(%edx),%edx
  8018b2:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8018b8:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8018bd:	50                   	push   %eax
  8018be:	ff 75 0c             	push   0xc(%ebp)
  8018c1:	68 08 50 80 00       	push   $0x805008
  8018c6:	e8 17 f2 ff ff       	call   800ae2 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8018cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d0:	b8 04 00 00 00       	mov    $0x4,%eax
  8018d5:	e8 cd fe ff ff       	call   8017a7 <fsipc>
}
  8018da:	c9                   	leave  
  8018db:	c3                   	ret    

008018dc <devfile_read>:
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	56                   	push   %esi
  8018e0:	53                   	push   %ebx
  8018e1:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8018ea:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8018ef:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8018ff:	e8 a3 fe ff ff       	call   8017a7 <fsipc>
  801904:	89 c3                	mov    %eax,%ebx
  801906:	85 c0                	test   %eax,%eax
  801908:	78 1f                	js     801929 <devfile_read+0x4d>
	assert(r <= n);
  80190a:	39 f0                	cmp    %esi,%eax
  80190c:	77 24                	ja     801932 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80190e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801913:	7f 33                	jg     801948 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801915:	83 ec 04             	sub    $0x4,%esp
  801918:	50                   	push   %eax
  801919:	68 00 50 80 00       	push   $0x805000
  80191e:	ff 75 0c             	push   0xc(%ebp)
  801921:	e8 bc f1 ff ff       	call   800ae2 <memmove>
	return r;
  801926:	83 c4 10             	add    $0x10,%esp
}
  801929:	89 d8                	mov    %ebx,%eax
  80192b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80192e:	5b                   	pop    %ebx
  80192f:	5e                   	pop    %esi
  801930:	5d                   	pop    %ebp
  801931:	c3                   	ret    
	assert(r <= n);
  801932:	68 c8 2c 80 00       	push   $0x802cc8
  801937:	68 cf 2c 80 00       	push   $0x802ccf
  80193c:	6a 7c                	push   $0x7c
  80193e:	68 e4 2c 80 00       	push   $0x802ce4
  801943:	e8 4f e9 ff ff       	call   800297 <_panic>
	assert(r <= PGSIZE);
  801948:	68 ef 2c 80 00       	push   $0x802cef
  80194d:	68 cf 2c 80 00       	push   $0x802ccf
  801952:	6a 7d                	push   $0x7d
  801954:	68 e4 2c 80 00       	push   $0x802ce4
  801959:	e8 39 e9 ff ff       	call   800297 <_panic>

0080195e <open>:
{
  80195e:	55                   	push   %ebp
  80195f:	89 e5                	mov    %esp,%ebp
  801961:	56                   	push   %esi
  801962:	53                   	push   %ebx
  801963:	83 ec 1c             	sub    $0x1c,%esp
  801966:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801969:	56                   	push   %esi
  80196a:	e8 a2 ef ff ff       	call   800911 <strlen>
  80196f:	83 c4 10             	add    $0x10,%esp
  801972:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801977:	7f 6c                	jg     8019e5 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801979:	83 ec 0c             	sub    $0xc,%esp
  80197c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197f:	50                   	push   %eax
  801980:	e8 bd f8 ff ff       	call   801242 <fd_alloc>
  801985:	89 c3                	mov    %eax,%ebx
  801987:	83 c4 10             	add    $0x10,%esp
  80198a:	85 c0                	test   %eax,%eax
  80198c:	78 3c                	js     8019ca <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80198e:	83 ec 08             	sub    $0x8,%esp
  801991:	56                   	push   %esi
  801992:	68 00 50 80 00       	push   $0x805000
  801997:	e8 b0 ef ff ff       	call   80094c <strcpy>
	fsipcbuf.open.req_omode = mode;
  80199c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199f:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8019a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019a7:	b8 01 00 00 00       	mov    $0x1,%eax
  8019ac:	e8 f6 fd ff ff       	call   8017a7 <fsipc>
  8019b1:	89 c3                	mov    %eax,%ebx
  8019b3:	83 c4 10             	add    $0x10,%esp
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	78 19                	js     8019d3 <open+0x75>
	return fd2num(fd);
  8019ba:	83 ec 0c             	sub    $0xc,%esp
  8019bd:	ff 75 f4             	push   -0xc(%ebp)
  8019c0:	e8 56 f8 ff ff       	call   80121b <fd2num>
  8019c5:	89 c3                	mov    %eax,%ebx
  8019c7:	83 c4 10             	add    $0x10,%esp
}
  8019ca:	89 d8                	mov    %ebx,%eax
  8019cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019cf:	5b                   	pop    %ebx
  8019d0:	5e                   	pop    %esi
  8019d1:	5d                   	pop    %ebp
  8019d2:	c3                   	ret    
		fd_close(fd, 0);
  8019d3:	83 ec 08             	sub    $0x8,%esp
  8019d6:	6a 00                	push   $0x0
  8019d8:	ff 75 f4             	push   -0xc(%ebp)
  8019db:	e8 58 f9 ff ff       	call   801338 <fd_close>
		return r;
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	eb e5                	jmp    8019ca <open+0x6c>
		return -E_BAD_PATH;
  8019e5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8019ea:	eb de                	jmp    8019ca <open+0x6c>

008019ec <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8019ec:	55                   	push   %ebp
  8019ed:	89 e5                	mov    %esp,%ebp
  8019ef:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8019f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019f7:	b8 08 00 00 00       	mov    $0x8,%eax
  8019fc:	e8 a6 fd ff ff       	call   8017a7 <fsipc>
}
  801a01:	c9                   	leave  
  801a02:	c3                   	ret    

00801a03 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801a09:	68 fb 2c 80 00       	push   $0x802cfb
  801a0e:	ff 75 0c             	push   0xc(%ebp)
  801a11:	e8 36 ef ff ff       	call   80094c <strcpy>
	return 0;
}
  801a16:	b8 00 00 00 00       	mov    $0x0,%eax
  801a1b:	c9                   	leave  
  801a1c:	c3                   	ret    

00801a1d <devsock_close>:
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	53                   	push   %ebx
  801a21:	83 ec 10             	sub    $0x10,%esp
  801a24:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a27:	53                   	push   %ebx
  801a28:	e8 9b 0a 00 00       	call   8024c8 <pageref>
  801a2d:	89 c2                	mov    %eax,%edx
  801a2f:	83 c4 10             	add    $0x10,%esp
		return 0;
  801a32:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801a37:	83 fa 01             	cmp    $0x1,%edx
  801a3a:	74 05                	je     801a41 <devsock_close+0x24>
}
  801a3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801a41:	83 ec 0c             	sub    $0xc,%esp
  801a44:	ff 73 0c             	push   0xc(%ebx)
  801a47:	e8 b7 02 00 00       	call   801d03 <nsipc_close>
  801a4c:	83 c4 10             	add    $0x10,%esp
  801a4f:	eb eb                	jmp    801a3c <devsock_close+0x1f>

00801a51 <devsock_write>:
{
  801a51:	55                   	push   %ebp
  801a52:	89 e5                	mov    %esp,%ebp
  801a54:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a57:	6a 00                	push   $0x0
  801a59:	ff 75 10             	push   0x10(%ebp)
  801a5c:	ff 75 0c             	push   0xc(%ebp)
  801a5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a62:	ff 70 0c             	push   0xc(%eax)
  801a65:	e8 79 03 00 00       	call   801de3 <nsipc_send>
}
  801a6a:	c9                   	leave  
  801a6b:	c3                   	ret    

00801a6c <devsock_read>:
{
  801a6c:	55                   	push   %ebp
  801a6d:	89 e5                	mov    %esp,%ebp
  801a6f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801a72:	6a 00                	push   $0x0
  801a74:	ff 75 10             	push   0x10(%ebp)
  801a77:	ff 75 0c             	push   0xc(%ebp)
  801a7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7d:	ff 70 0c             	push   0xc(%eax)
  801a80:	e8 ef 02 00 00       	call   801d74 <nsipc_recv>
}
  801a85:	c9                   	leave  
  801a86:	c3                   	ret    

00801a87 <fd2sockid>:
{
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a8d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a90:	52                   	push   %edx
  801a91:	50                   	push   %eax
  801a92:	e8 fb f7 ff ff       	call   801292 <fd_lookup>
  801a97:	83 c4 10             	add    $0x10,%esp
  801a9a:	85 c0                	test   %eax,%eax
  801a9c:	78 10                	js     801aae <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa1:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801aa7:	39 08                	cmp    %ecx,(%eax)
  801aa9:	75 05                	jne    801ab0 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801aab:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801aae:	c9                   	leave  
  801aaf:	c3                   	ret    
		return -E_NOT_SUPP;
  801ab0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801ab5:	eb f7                	jmp    801aae <fd2sockid+0x27>

00801ab7 <alloc_sockfd>:
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	56                   	push   %esi
  801abb:	53                   	push   %ebx
  801abc:	83 ec 1c             	sub    $0x1c,%esp
  801abf:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801ac1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac4:	50                   	push   %eax
  801ac5:	e8 78 f7 ff ff       	call   801242 <fd_alloc>
  801aca:	89 c3                	mov    %eax,%ebx
  801acc:	83 c4 10             	add    $0x10,%esp
  801acf:	85 c0                	test   %eax,%eax
  801ad1:	78 43                	js     801b16 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ad3:	83 ec 04             	sub    $0x4,%esp
  801ad6:	68 07 04 00 00       	push   $0x407
  801adb:	ff 75 f4             	push   -0xc(%ebp)
  801ade:	6a 00                	push   $0x0
  801ae0:	e8 63 f2 ff ff       	call   800d48 <sys_page_alloc>
  801ae5:	89 c3                	mov    %eax,%ebx
  801ae7:	83 c4 10             	add    $0x10,%esp
  801aea:	85 c0                	test   %eax,%eax
  801aec:	78 28                	js     801b16 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801aee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801af7:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801af9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801afc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b03:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b06:	83 ec 0c             	sub    $0xc,%esp
  801b09:	50                   	push   %eax
  801b0a:	e8 0c f7 ff ff       	call   80121b <fd2num>
  801b0f:	89 c3                	mov    %eax,%ebx
  801b11:	83 c4 10             	add    $0x10,%esp
  801b14:	eb 0c                	jmp    801b22 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801b16:	83 ec 0c             	sub    $0xc,%esp
  801b19:	56                   	push   %esi
  801b1a:	e8 e4 01 00 00       	call   801d03 <nsipc_close>
		return r;
  801b1f:	83 c4 10             	add    $0x10,%esp
}
  801b22:	89 d8                	mov    %ebx,%eax
  801b24:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b27:	5b                   	pop    %ebx
  801b28:	5e                   	pop    %esi
  801b29:	5d                   	pop    %ebp
  801b2a:	c3                   	ret    

00801b2b <accept>:
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b31:	8b 45 08             	mov    0x8(%ebp),%eax
  801b34:	e8 4e ff ff ff       	call   801a87 <fd2sockid>
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	78 1b                	js     801b58 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b3d:	83 ec 04             	sub    $0x4,%esp
  801b40:	ff 75 10             	push   0x10(%ebp)
  801b43:	ff 75 0c             	push   0xc(%ebp)
  801b46:	50                   	push   %eax
  801b47:	e8 0e 01 00 00       	call   801c5a <nsipc_accept>
  801b4c:	83 c4 10             	add    $0x10,%esp
  801b4f:	85 c0                	test   %eax,%eax
  801b51:	78 05                	js     801b58 <accept+0x2d>
	return alloc_sockfd(r);
  801b53:	e8 5f ff ff ff       	call   801ab7 <alloc_sockfd>
}
  801b58:	c9                   	leave  
  801b59:	c3                   	ret    

00801b5a <bind>:
{
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b60:	8b 45 08             	mov    0x8(%ebp),%eax
  801b63:	e8 1f ff ff ff       	call   801a87 <fd2sockid>
  801b68:	85 c0                	test   %eax,%eax
  801b6a:	78 12                	js     801b7e <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801b6c:	83 ec 04             	sub    $0x4,%esp
  801b6f:	ff 75 10             	push   0x10(%ebp)
  801b72:	ff 75 0c             	push   0xc(%ebp)
  801b75:	50                   	push   %eax
  801b76:	e8 31 01 00 00       	call   801cac <nsipc_bind>
  801b7b:	83 c4 10             	add    $0x10,%esp
}
  801b7e:	c9                   	leave  
  801b7f:	c3                   	ret    

00801b80 <shutdown>:
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b86:	8b 45 08             	mov    0x8(%ebp),%eax
  801b89:	e8 f9 fe ff ff       	call   801a87 <fd2sockid>
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	78 0f                	js     801ba1 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801b92:	83 ec 08             	sub    $0x8,%esp
  801b95:	ff 75 0c             	push   0xc(%ebp)
  801b98:	50                   	push   %eax
  801b99:	e8 43 01 00 00       	call   801ce1 <nsipc_shutdown>
  801b9e:	83 c4 10             	add    $0x10,%esp
}
  801ba1:	c9                   	leave  
  801ba2:	c3                   	ret    

00801ba3 <connect>:
{
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bac:	e8 d6 fe ff ff       	call   801a87 <fd2sockid>
  801bb1:	85 c0                	test   %eax,%eax
  801bb3:	78 12                	js     801bc7 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801bb5:	83 ec 04             	sub    $0x4,%esp
  801bb8:	ff 75 10             	push   0x10(%ebp)
  801bbb:	ff 75 0c             	push   0xc(%ebp)
  801bbe:	50                   	push   %eax
  801bbf:	e8 59 01 00 00       	call   801d1d <nsipc_connect>
  801bc4:	83 c4 10             	add    $0x10,%esp
}
  801bc7:	c9                   	leave  
  801bc8:	c3                   	ret    

00801bc9 <listen>:
{
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801bcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd2:	e8 b0 fe ff ff       	call   801a87 <fd2sockid>
  801bd7:	85 c0                	test   %eax,%eax
  801bd9:	78 0f                	js     801bea <listen+0x21>
	return nsipc_listen(r, backlog);
  801bdb:	83 ec 08             	sub    $0x8,%esp
  801bde:	ff 75 0c             	push   0xc(%ebp)
  801be1:	50                   	push   %eax
  801be2:	e8 6b 01 00 00       	call   801d52 <nsipc_listen>
  801be7:	83 c4 10             	add    $0x10,%esp
}
  801bea:	c9                   	leave  
  801beb:	c3                   	ret    

00801bec <socket>:

int
socket(int domain, int type, int protocol)
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
  801bef:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801bf2:	ff 75 10             	push   0x10(%ebp)
  801bf5:	ff 75 0c             	push   0xc(%ebp)
  801bf8:	ff 75 08             	push   0x8(%ebp)
  801bfb:	e8 41 02 00 00       	call   801e41 <nsipc_socket>
  801c00:	83 c4 10             	add    $0x10,%esp
  801c03:	85 c0                	test   %eax,%eax
  801c05:	78 05                	js     801c0c <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801c07:	e8 ab fe ff ff       	call   801ab7 <alloc_sockfd>
}
  801c0c:	c9                   	leave  
  801c0d:	c3                   	ret    

00801c0e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c0e:	55                   	push   %ebp
  801c0f:	89 e5                	mov    %esp,%ebp
  801c11:	53                   	push   %ebx
  801c12:	83 ec 04             	sub    $0x4,%esp
  801c15:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c17:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801c1e:	74 26                	je     801c46 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c20:	6a 07                	push   $0x7
  801c22:	68 00 70 80 00       	push   $0x807000
  801c27:	53                   	push   %ebx
  801c28:	ff 35 00 80 80 00    	push   0x808000
  801c2e:	e8 02 08 00 00       	call   802435 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801c33:	83 c4 0c             	add    $0xc,%esp
  801c36:	6a 00                	push   $0x0
  801c38:	6a 00                	push   $0x0
  801c3a:	6a 00                	push   $0x0
  801c3c:	e8 84 07 00 00       	call   8023c5 <ipc_recv>
}
  801c41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c44:	c9                   	leave  
  801c45:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c46:	83 ec 0c             	sub    $0xc,%esp
  801c49:	6a 02                	push   $0x2
  801c4b:	e8 39 08 00 00       	call   802489 <ipc_find_env>
  801c50:	a3 00 80 80 00       	mov    %eax,0x808000
  801c55:	83 c4 10             	add    $0x10,%esp
  801c58:	eb c6                	jmp    801c20 <nsipc+0x12>

00801c5a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c5a:	55                   	push   %ebp
  801c5b:	89 e5                	mov    %esp,%ebp
  801c5d:	56                   	push   %esi
  801c5e:	53                   	push   %ebx
  801c5f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801c62:	8b 45 08             	mov    0x8(%ebp),%eax
  801c65:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801c6a:	8b 06                	mov    (%esi),%eax
  801c6c:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801c71:	b8 01 00 00 00       	mov    $0x1,%eax
  801c76:	e8 93 ff ff ff       	call   801c0e <nsipc>
  801c7b:	89 c3                	mov    %eax,%ebx
  801c7d:	85 c0                	test   %eax,%eax
  801c7f:	79 09                	jns    801c8a <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801c81:	89 d8                	mov    %ebx,%eax
  801c83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c86:	5b                   	pop    %ebx
  801c87:	5e                   	pop    %esi
  801c88:	5d                   	pop    %ebp
  801c89:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c8a:	83 ec 04             	sub    $0x4,%esp
  801c8d:	ff 35 10 70 80 00    	push   0x807010
  801c93:	68 00 70 80 00       	push   $0x807000
  801c98:	ff 75 0c             	push   0xc(%ebp)
  801c9b:	e8 42 ee ff ff       	call   800ae2 <memmove>
		*addrlen = ret->ret_addrlen;
  801ca0:	a1 10 70 80 00       	mov    0x807010,%eax
  801ca5:	89 06                	mov    %eax,(%esi)
  801ca7:	83 c4 10             	add    $0x10,%esp
	return r;
  801caa:	eb d5                	jmp    801c81 <nsipc_accept+0x27>

00801cac <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cac:	55                   	push   %ebp
  801cad:	89 e5                	mov    %esp,%ebp
  801caf:	53                   	push   %ebx
  801cb0:	83 ec 08             	sub    $0x8,%esp
  801cb3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb9:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801cbe:	53                   	push   %ebx
  801cbf:	ff 75 0c             	push   0xc(%ebp)
  801cc2:	68 04 70 80 00       	push   $0x807004
  801cc7:	e8 16 ee ff ff       	call   800ae2 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801ccc:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801cd2:	b8 02 00 00 00       	mov    $0x2,%eax
  801cd7:	e8 32 ff ff ff       	call   801c0e <nsipc>
}
  801cdc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cdf:	c9                   	leave  
  801ce0:	c3                   	ret    

00801ce1 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801ce1:	55                   	push   %ebp
  801ce2:	89 e5                	mov    %esp,%ebp
  801ce4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801ce7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cea:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801cef:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf2:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801cf7:	b8 03 00 00 00       	mov    $0x3,%eax
  801cfc:	e8 0d ff ff ff       	call   801c0e <nsipc>
}
  801d01:	c9                   	leave  
  801d02:	c3                   	ret    

00801d03 <nsipc_close>:

int
nsipc_close(int s)
{
  801d03:	55                   	push   %ebp
  801d04:	89 e5                	mov    %esp,%ebp
  801d06:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d09:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0c:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801d11:	b8 04 00 00 00       	mov    $0x4,%eax
  801d16:	e8 f3 fe ff ff       	call   801c0e <nsipc>
}
  801d1b:	c9                   	leave  
  801d1c:	c3                   	ret    

00801d1d <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	53                   	push   %ebx
  801d21:	83 ec 08             	sub    $0x8,%esp
  801d24:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d27:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2a:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d2f:	53                   	push   %ebx
  801d30:	ff 75 0c             	push   0xc(%ebp)
  801d33:	68 04 70 80 00       	push   $0x807004
  801d38:	e8 a5 ed ff ff       	call   800ae2 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d3d:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801d43:	b8 05 00 00 00       	mov    $0x5,%eax
  801d48:	e8 c1 fe ff ff       	call   801c0e <nsipc>
}
  801d4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d50:	c9                   	leave  
  801d51:	c3                   	ret    

00801d52 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801d52:	55                   	push   %ebp
  801d53:	89 e5                	mov    %esp,%ebp
  801d55:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d58:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801d60:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d63:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801d68:	b8 06 00 00 00       	mov    $0x6,%eax
  801d6d:	e8 9c fe ff ff       	call   801c0e <nsipc>
}
  801d72:	c9                   	leave  
  801d73:	c3                   	ret    

00801d74 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
  801d77:	56                   	push   %esi
  801d78:	53                   	push   %ebx
  801d79:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801d84:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801d8a:	8b 45 14             	mov    0x14(%ebp),%eax
  801d8d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d92:	b8 07 00 00 00       	mov    $0x7,%eax
  801d97:	e8 72 fe ff ff       	call   801c0e <nsipc>
  801d9c:	89 c3                	mov    %eax,%ebx
  801d9e:	85 c0                	test   %eax,%eax
  801da0:	78 22                	js     801dc4 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801da2:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801da7:	39 c6                	cmp    %eax,%esi
  801da9:	0f 4e c6             	cmovle %esi,%eax
  801dac:	39 c3                	cmp    %eax,%ebx
  801dae:	7f 1d                	jg     801dcd <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801db0:	83 ec 04             	sub    $0x4,%esp
  801db3:	53                   	push   %ebx
  801db4:	68 00 70 80 00       	push   $0x807000
  801db9:	ff 75 0c             	push   0xc(%ebp)
  801dbc:	e8 21 ed ff ff       	call   800ae2 <memmove>
  801dc1:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801dc4:	89 d8                	mov    %ebx,%eax
  801dc6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dc9:	5b                   	pop    %ebx
  801dca:	5e                   	pop    %esi
  801dcb:	5d                   	pop    %ebp
  801dcc:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801dcd:	68 07 2d 80 00       	push   $0x802d07
  801dd2:	68 cf 2c 80 00       	push   $0x802ccf
  801dd7:	6a 62                	push   $0x62
  801dd9:	68 1c 2d 80 00       	push   $0x802d1c
  801dde:	e8 b4 e4 ff ff       	call   800297 <_panic>

00801de3 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	53                   	push   %ebx
  801de7:	83 ec 04             	sub    $0x4,%esp
  801dea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ded:	8b 45 08             	mov    0x8(%ebp),%eax
  801df0:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801df5:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801dfb:	7f 2e                	jg     801e2b <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801dfd:	83 ec 04             	sub    $0x4,%esp
  801e00:	53                   	push   %ebx
  801e01:	ff 75 0c             	push   0xc(%ebp)
  801e04:	68 0c 70 80 00       	push   $0x80700c
  801e09:	e8 d4 ec ff ff       	call   800ae2 <memmove>
	nsipcbuf.send.req_size = size;
  801e0e:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801e14:	8b 45 14             	mov    0x14(%ebp),%eax
  801e17:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801e1c:	b8 08 00 00 00       	mov    $0x8,%eax
  801e21:	e8 e8 fd ff ff       	call   801c0e <nsipc>
}
  801e26:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e29:	c9                   	leave  
  801e2a:	c3                   	ret    
	assert(size < 1600);
  801e2b:	68 28 2d 80 00       	push   $0x802d28
  801e30:	68 cf 2c 80 00       	push   $0x802ccf
  801e35:	6a 6d                	push   $0x6d
  801e37:	68 1c 2d 80 00       	push   $0x802d1c
  801e3c:	e8 56 e4 ff ff       	call   800297 <_panic>

00801e41 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801e41:	55                   	push   %ebp
  801e42:	89 e5                	mov    %esp,%ebp
  801e44:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801e47:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801e4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e52:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801e57:	8b 45 10             	mov    0x10(%ebp),%eax
  801e5a:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801e5f:	b8 09 00 00 00       	mov    $0x9,%eax
  801e64:	e8 a5 fd ff ff       	call   801c0e <nsipc>
}
  801e69:	c9                   	leave  
  801e6a:	c3                   	ret    

00801e6b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e6b:	55                   	push   %ebp
  801e6c:	89 e5                	mov    %esp,%ebp
  801e6e:	56                   	push   %esi
  801e6f:	53                   	push   %ebx
  801e70:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801e73:	83 ec 0c             	sub    $0xc,%esp
  801e76:	ff 75 08             	push   0x8(%ebp)
  801e79:	e8 ad f3 ff ff       	call   80122b <fd2data>
  801e7e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e80:	83 c4 08             	add    $0x8,%esp
  801e83:	68 34 2d 80 00       	push   $0x802d34
  801e88:	53                   	push   %ebx
  801e89:	e8 be ea ff ff       	call   80094c <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e8e:	8b 46 04             	mov    0x4(%esi),%eax
  801e91:	2b 06                	sub    (%esi),%eax
  801e93:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e99:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ea0:	00 00 00 
	stat->st_dev = &devpipe;
  801ea3:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801eaa:	30 80 00 
	return 0;
}
  801ead:	b8 00 00 00 00       	mov    $0x0,%eax
  801eb2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801eb5:	5b                   	pop    %ebx
  801eb6:	5e                   	pop    %esi
  801eb7:	5d                   	pop    %ebp
  801eb8:	c3                   	ret    

00801eb9 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801eb9:	55                   	push   %ebp
  801eba:	89 e5                	mov    %esp,%ebp
  801ebc:	53                   	push   %ebx
  801ebd:	83 ec 0c             	sub    $0xc,%esp
  801ec0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ec3:	53                   	push   %ebx
  801ec4:	6a 00                	push   $0x0
  801ec6:	e8 02 ef ff ff       	call   800dcd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801ecb:	89 1c 24             	mov    %ebx,(%esp)
  801ece:	e8 58 f3 ff ff       	call   80122b <fd2data>
  801ed3:	83 c4 08             	add    $0x8,%esp
  801ed6:	50                   	push   %eax
  801ed7:	6a 00                	push   $0x0
  801ed9:	e8 ef ee ff ff       	call   800dcd <sys_page_unmap>
}
  801ede:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ee1:	c9                   	leave  
  801ee2:	c3                   	ret    

00801ee3 <_pipeisclosed>:
{
  801ee3:	55                   	push   %ebp
  801ee4:	89 e5                	mov    %esp,%ebp
  801ee6:	57                   	push   %edi
  801ee7:	56                   	push   %esi
  801ee8:	53                   	push   %ebx
  801ee9:	83 ec 1c             	sub    $0x1c,%esp
  801eec:	89 c7                	mov    %eax,%edi
  801eee:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801ef0:	a1 00 40 80 00       	mov    0x804000,%eax
  801ef5:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ef8:	83 ec 0c             	sub    $0xc,%esp
  801efb:	57                   	push   %edi
  801efc:	e8 c7 05 00 00       	call   8024c8 <pageref>
  801f01:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f04:	89 34 24             	mov    %esi,(%esp)
  801f07:	e8 bc 05 00 00       	call   8024c8 <pageref>
		nn = thisenv->env_runs;
  801f0c:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f12:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801f15:	83 c4 10             	add    $0x10,%esp
  801f18:	39 cb                	cmp    %ecx,%ebx
  801f1a:	74 1b                	je     801f37 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801f1c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f1f:	75 cf                	jne    801ef0 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f21:	8b 42 68             	mov    0x68(%edx),%eax
  801f24:	6a 01                	push   $0x1
  801f26:	50                   	push   %eax
  801f27:	53                   	push   %ebx
  801f28:	68 3b 2d 80 00       	push   $0x802d3b
  801f2d:	e8 40 e4 ff ff       	call   800372 <cprintf>
  801f32:	83 c4 10             	add    $0x10,%esp
  801f35:	eb b9                	jmp    801ef0 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801f37:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f3a:	0f 94 c0             	sete   %al
  801f3d:	0f b6 c0             	movzbl %al,%eax
}
  801f40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f43:	5b                   	pop    %ebx
  801f44:	5e                   	pop    %esi
  801f45:	5f                   	pop    %edi
  801f46:	5d                   	pop    %ebp
  801f47:	c3                   	ret    

00801f48 <devpipe_write>:
{
  801f48:	55                   	push   %ebp
  801f49:	89 e5                	mov    %esp,%ebp
  801f4b:	57                   	push   %edi
  801f4c:	56                   	push   %esi
  801f4d:	53                   	push   %ebx
  801f4e:	83 ec 28             	sub    $0x28,%esp
  801f51:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801f54:	56                   	push   %esi
  801f55:	e8 d1 f2 ff ff       	call   80122b <fd2data>
  801f5a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f5c:	83 c4 10             	add    $0x10,%esp
  801f5f:	bf 00 00 00 00       	mov    $0x0,%edi
  801f64:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f67:	75 09                	jne    801f72 <devpipe_write+0x2a>
	return i;
  801f69:	89 f8                	mov    %edi,%eax
  801f6b:	eb 23                	jmp    801f90 <devpipe_write+0x48>
			sys_yield();
  801f6d:	e8 b7 ed ff ff       	call   800d29 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f72:	8b 43 04             	mov    0x4(%ebx),%eax
  801f75:	8b 0b                	mov    (%ebx),%ecx
  801f77:	8d 51 20             	lea    0x20(%ecx),%edx
  801f7a:	39 d0                	cmp    %edx,%eax
  801f7c:	72 1a                	jb     801f98 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801f7e:	89 da                	mov    %ebx,%edx
  801f80:	89 f0                	mov    %esi,%eax
  801f82:	e8 5c ff ff ff       	call   801ee3 <_pipeisclosed>
  801f87:	85 c0                	test   %eax,%eax
  801f89:	74 e2                	je     801f6d <devpipe_write+0x25>
				return 0;
  801f8b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f93:	5b                   	pop    %ebx
  801f94:	5e                   	pop    %esi
  801f95:	5f                   	pop    %edi
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f98:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f9b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f9f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fa2:	89 c2                	mov    %eax,%edx
  801fa4:	c1 fa 1f             	sar    $0x1f,%edx
  801fa7:	89 d1                	mov    %edx,%ecx
  801fa9:	c1 e9 1b             	shr    $0x1b,%ecx
  801fac:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801faf:	83 e2 1f             	and    $0x1f,%edx
  801fb2:	29 ca                	sub    %ecx,%edx
  801fb4:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fb8:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fbc:	83 c0 01             	add    $0x1,%eax
  801fbf:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801fc2:	83 c7 01             	add    $0x1,%edi
  801fc5:	eb 9d                	jmp    801f64 <devpipe_write+0x1c>

00801fc7 <devpipe_read>:
{
  801fc7:	55                   	push   %ebp
  801fc8:	89 e5                	mov    %esp,%ebp
  801fca:	57                   	push   %edi
  801fcb:	56                   	push   %esi
  801fcc:	53                   	push   %ebx
  801fcd:	83 ec 18             	sub    $0x18,%esp
  801fd0:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801fd3:	57                   	push   %edi
  801fd4:	e8 52 f2 ff ff       	call   80122b <fd2data>
  801fd9:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801fdb:	83 c4 10             	add    $0x10,%esp
  801fde:	be 00 00 00 00       	mov    $0x0,%esi
  801fe3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fe6:	75 13                	jne    801ffb <devpipe_read+0x34>
	return i;
  801fe8:	89 f0                	mov    %esi,%eax
  801fea:	eb 02                	jmp    801fee <devpipe_read+0x27>
				return i;
  801fec:	89 f0                	mov    %esi,%eax
}
  801fee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff1:	5b                   	pop    %ebx
  801ff2:	5e                   	pop    %esi
  801ff3:	5f                   	pop    %edi
  801ff4:	5d                   	pop    %ebp
  801ff5:	c3                   	ret    
			sys_yield();
  801ff6:	e8 2e ed ff ff       	call   800d29 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801ffb:	8b 03                	mov    (%ebx),%eax
  801ffd:	3b 43 04             	cmp    0x4(%ebx),%eax
  802000:	75 18                	jne    80201a <devpipe_read+0x53>
			if (i > 0)
  802002:	85 f6                	test   %esi,%esi
  802004:	75 e6                	jne    801fec <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  802006:	89 da                	mov    %ebx,%edx
  802008:	89 f8                	mov    %edi,%eax
  80200a:	e8 d4 fe ff ff       	call   801ee3 <_pipeisclosed>
  80200f:	85 c0                	test   %eax,%eax
  802011:	74 e3                	je     801ff6 <devpipe_read+0x2f>
				return 0;
  802013:	b8 00 00 00 00       	mov    $0x0,%eax
  802018:	eb d4                	jmp    801fee <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80201a:	99                   	cltd   
  80201b:	c1 ea 1b             	shr    $0x1b,%edx
  80201e:	01 d0                	add    %edx,%eax
  802020:	83 e0 1f             	and    $0x1f,%eax
  802023:	29 d0                	sub    %edx,%eax
  802025:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80202a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80202d:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802030:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802033:	83 c6 01             	add    $0x1,%esi
  802036:	eb ab                	jmp    801fe3 <devpipe_read+0x1c>

00802038 <pipe>:
{
  802038:	55                   	push   %ebp
  802039:	89 e5                	mov    %esp,%ebp
  80203b:	56                   	push   %esi
  80203c:	53                   	push   %ebx
  80203d:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802040:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802043:	50                   	push   %eax
  802044:	e8 f9 f1 ff ff       	call   801242 <fd_alloc>
  802049:	89 c3                	mov    %eax,%ebx
  80204b:	83 c4 10             	add    $0x10,%esp
  80204e:	85 c0                	test   %eax,%eax
  802050:	0f 88 23 01 00 00    	js     802179 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802056:	83 ec 04             	sub    $0x4,%esp
  802059:	68 07 04 00 00       	push   $0x407
  80205e:	ff 75 f4             	push   -0xc(%ebp)
  802061:	6a 00                	push   $0x0
  802063:	e8 e0 ec ff ff       	call   800d48 <sys_page_alloc>
  802068:	89 c3                	mov    %eax,%ebx
  80206a:	83 c4 10             	add    $0x10,%esp
  80206d:	85 c0                	test   %eax,%eax
  80206f:	0f 88 04 01 00 00    	js     802179 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802075:	83 ec 0c             	sub    $0xc,%esp
  802078:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80207b:	50                   	push   %eax
  80207c:	e8 c1 f1 ff ff       	call   801242 <fd_alloc>
  802081:	89 c3                	mov    %eax,%ebx
  802083:	83 c4 10             	add    $0x10,%esp
  802086:	85 c0                	test   %eax,%eax
  802088:	0f 88 db 00 00 00    	js     802169 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80208e:	83 ec 04             	sub    $0x4,%esp
  802091:	68 07 04 00 00       	push   $0x407
  802096:	ff 75 f0             	push   -0x10(%ebp)
  802099:	6a 00                	push   $0x0
  80209b:	e8 a8 ec ff ff       	call   800d48 <sys_page_alloc>
  8020a0:	89 c3                	mov    %eax,%ebx
  8020a2:	83 c4 10             	add    $0x10,%esp
  8020a5:	85 c0                	test   %eax,%eax
  8020a7:	0f 88 bc 00 00 00    	js     802169 <pipe+0x131>
	va = fd2data(fd0);
  8020ad:	83 ec 0c             	sub    $0xc,%esp
  8020b0:	ff 75 f4             	push   -0xc(%ebp)
  8020b3:	e8 73 f1 ff ff       	call   80122b <fd2data>
  8020b8:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ba:	83 c4 0c             	add    $0xc,%esp
  8020bd:	68 07 04 00 00       	push   $0x407
  8020c2:	50                   	push   %eax
  8020c3:	6a 00                	push   $0x0
  8020c5:	e8 7e ec ff ff       	call   800d48 <sys_page_alloc>
  8020ca:	89 c3                	mov    %eax,%ebx
  8020cc:	83 c4 10             	add    $0x10,%esp
  8020cf:	85 c0                	test   %eax,%eax
  8020d1:	0f 88 82 00 00 00    	js     802159 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020d7:	83 ec 0c             	sub    $0xc,%esp
  8020da:	ff 75 f0             	push   -0x10(%ebp)
  8020dd:	e8 49 f1 ff ff       	call   80122b <fd2data>
  8020e2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8020e9:	50                   	push   %eax
  8020ea:	6a 00                	push   $0x0
  8020ec:	56                   	push   %esi
  8020ed:	6a 00                	push   $0x0
  8020ef:	e8 97 ec ff ff       	call   800d8b <sys_page_map>
  8020f4:	89 c3                	mov    %eax,%ebx
  8020f6:	83 c4 20             	add    $0x20,%esp
  8020f9:	85 c0                	test   %eax,%eax
  8020fb:	78 4e                	js     80214b <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8020fd:	a1 3c 30 80 00       	mov    0x80303c,%eax
  802102:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802105:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802107:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80210a:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802111:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802114:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802116:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802119:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802120:	83 ec 0c             	sub    $0xc,%esp
  802123:	ff 75 f4             	push   -0xc(%ebp)
  802126:	e8 f0 f0 ff ff       	call   80121b <fd2num>
  80212b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80212e:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802130:	83 c4 04             	add    $0x4,%esp
  802133:	ff 75 f0             	push   -0x10(%ebp)
  802136:	e8 e0 f0 ff ff       	call   80121b <fd2num>
  80213b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80213e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802141:	83 c4 10             	add    $0x10,%esp
  802144:	bb 00 00 00 00       	mov    $0x0,%ebx
  802149:	eb 2e                	jmp    802179 <pipe+0x141>
	sys_page_unmap(0, va);
  80214b:	83 ec 08             	sub    $0x8,%esp
  80214e:	56                   	push   %esi
  80214f:	6a 00                	push   $0x0
  802151:	e8 77 ec ff ff       	call   800dcd <sys_page_unmap>
  802156:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  802159:	83 ec 08             	sub    $0x8,%esp
  80215c:	ff 75 f0             	push   -0x10(%ebp)
  80215f:	6a 00                	push   $0x0
  802161:	e8 67 ec ff ff       	call   800dcd <sys_page_unmap>
  802166:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  802169:	83 ec 08             	sub    $0x8,%esp
  80216c:	ff 75 f4             	push   -0xc(%ebp)
  80216f:	6a 00                	push   $0x0
  802171:	e8 57 ec ff ff       	call   800dcd <sys_page_unmap>
  802176:	83 c4 10             	add    $0x10,%esp
}
  802179:	89 d8                	mov    %ebx,%eax
  80217b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80217e:	5b                   	pop    %ebx
  80217f:	5e                   	pop    %esi
  802180:	5d                   	pop    %ebp
  802181:	c3                   	ret    

00802182 <pipeisclosed>:
{
  802182:	55                   	push   %ebp
  802183:	89 e5                	mov    %esp,%ebp
  802185:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802188:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80218b:	50                   	push   %eax
  80218c:	ff 75 08             	push   0x8(%ebp)
  80218f:	e8 fe f0 ff ff       	call   801292 <fd_lookup>
  802194:	83 c4 10             	add    $0x10,%esp
  802197:	85 c0                	test   %eax,%eax
  802199:	78 18                	js     8021b3 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80219b:	83 ec 0c             	sub    $0xc,%esp
  80219e:	ff 75 f4             	push   -0xc(%ebp)
  8021a1:	e8 85 f0 ff ff       	call   80122b <fd2data>
  8021a6:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8021a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021ab:	e8 33 fd ff ff       	call   801ee3 <_pipeisclosed>
  8021b0:	83 c4 10             	add    $0x10,%esp
}
  8021b3:	c9                   	leave  
  8021b4:	c3                   	ret    

008021b5 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  8021b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8021ba:	c3                   	ret    

008021bb <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8021bb:	55                   	push   %ebp
  8021bc:	89 e5                	mov    %esp,%ebp
  8021be:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8021c1:	68 4e 2d 80 00       	push   $0x802d4e
  8021c6:	ff 75 0c             	push   0xc(%ebp)
  8021c9:	e8 7e e7 ff ff       	call   80094c <strcpy>
	return 0;
}
  8021ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8021d3:	c9                   	leave  
  8021d4:	c3                   	ret    

008021d5 <devcons_write>:
{
  8021d5:	55                   	push   %ebp
  8021d6:	89 e5                	mov    %esp,%ebp
  8021d8:	57                   	push   %edi
  8021d9:	56                   	push   %esi
  8021da:	53                   	push   %ebx
  8021db:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8021e1:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8021e6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8021ec:	eb 2e                	jmp    80221c <devcons_write+0x47>
		m = n - tot;
  8021ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8021f1:	29 f3                	sub    %esi,%ebx
  8021f3:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8021f8:	39 c3                	cmp    %eax,%ebx
  8021fa:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8021fd:	83 ec 04             	sub    $0x4,%esp
  802200:	53                   	push   %ebx
  802201:	89 f0                	mov    %esi,%eax
  802203:	03 45 0c             	add    0xc(%ebp),%eax
  802206:	50                   	push   %eax
  802207:	57                   	push   %edi
  802208:	e8 d5 e8 ff ff       	call   800ae2 <memmove>
		sys_cputs(buf, m);
  80220d:	83 c4 08             	add    $0x8,%esp
  802210:	53                   	push   %ebx
  802211:	57                   	push   %edi
  802212:	e8 75 ea ff ff       	call   800c8c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802217:	01 de                	add    %ebx,%esi
  802219:	83 c4 10             	add    $0x10,%esp
  80221c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80221f:	72 cd                	jb     8021ee <devcons_write+0x19>
}
  802221:	89 f0                	mov    %esi,%eax
  802223:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802226:	5b                   	pop    %ebx
  802227:	5e                   	pop    %esi
  802228:	5f                   	pop    %edi
  802229:	5d                   	pop    %ebp
  80222a:	c3                   	ret    

0080222b <devcons_read>:
{
  80222b:	55                   	push   %ebp
  80222c:	89 e5                	mov    %esp,%ebp
  80222e:	83 ec 08             	sub    $0x8,%esp
  802231:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802236:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80223a:	75 07                	jne    802243 <devcons_read+0x18>
  80223c:	eb 1f                	jmp    80225d <devcons_read+0x32>
		sys_yield();
  80223e:	e8 e6 ea ff ff       	call   800d29 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802243:	e8 62 ea ff ff       	call   800caa <sys_cgetc>
  802248:	85 c0                	test   %eax,%eax
  80224a:	74 f2                	je     80223e <devcons_read+0x13>
	if (c < 0)
  80224c:	78 0f                	js     80225d <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  80224e:	83 f8 04             	cmp    $0x4,%eax
  802251:	74 0c                	je     80225f <devcons_read+0x34>
	*(char*)vbuf = c;
  802253:	8b 55 0c             	mov    0xc(%ebp),%edx
  802256:	88 02                	mov    %al,(%edx)
	return 1;
  802258:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80225d:	c9                   	leave  
  80225e:	c3                   	ret    
		return 0;
  80225f:	b8 00 00 00 00       	mov    $0x0,%eax
  802264:	eb f7                	jmp    80225d <devcons_read+0x32>

00802266 <cputchar>:
{
  802266:	55                   	push   %ebp
  802267:	89 e5                	mov    %esp,%ebp
  802269:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80226c:	8b 45 08             	mov    0x8(%ebp),%eax
  80226f:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802272:	6a 01                	push   $0x1
  802274:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802277:	50                   	push   %eax
  802278:	e8 0f ea ff ff       	call   800c8c <sys_cputs>
}
  80227d:	83 c4 10             	add    $0x10,%esp
  802280:	c9                   	leave  
  802281:	c3                   	ret    

00802282 <getchar>:
{
  802282:	55                   	push   %ebp
  802283:	89 e5                	mov    %esp,%ebp
  802285:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802288:	6a 01                	push   $0x1
  80228a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80228d:	50                   	push   %eax
  80228e:	6a 00                	push   $0x0
  802290:	e8 66 f2 ff ff       	call   8014fb <read>
	if (r < 0)
  802295:	83 c4 10             	add    $0x10,%esp
  802298:	85 c0                	test   %eax,%eax
  80229a:	78 06                	js     8022a2 <getchar+0x20>
	if (r < 1)
  80229c:	74 06                	je     8022a4 <getchar+0x22>
	return c;
  80229e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8022a2:	c9                   	leave  
  8022a3:	c3                   	ret    
		return -E_EOF;
  8022a4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8022a9:	eb f7                	jmp    8022a2 <getchar+0x20>

008022ab <iscons>:
{
  8022ab:	55                   	push   %ebp
  8022ac:	89 e5                	mov    %esp,%ebp
  8022ae:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022b4:	50                   	push   %eax
  8022b5:	ff 75 08             	push   0x8(%ebp)
  8022b8:	e8 d5 ef ff ff       	call   801292 <fd_lookup>
  8022bd:	83 c4 10             	add    $0x10,%esp
  8022c0:	85 c0                	test   %eax,%eax
  8022c2:	78 11                	js     8022d5 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8022c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022c7:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022cd:	39 10                	cmp    %edx,(%eax)
  8022cf:	0f 94 c0             	sete   %al
  8022d2:	0f b6 c0             	movzbl %al,%eax
}
  8022d5:	c9                   	leave  
  8022d6:	c3                   	ret    

008022d7 <opencons>:
{
  8022d7:	55                   	push   %ebp
  8022d8:	89 e5                	mov    %esp,%ebp
  8022da:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8022dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022e0:	50                   	push   %eax
  8022e1:	e8 5c ef ff ff       	call   801242 <fd_alloc>
  8022e6:	83 c4 10             	add    $0x10,%esp
  8022e9:	85 c0                	test   %eax,%eax
  8022eb:	78 3a                	js     802327 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022ed:	83 ec 04             	sub    $0x4,%esp
  8022f0:	68 07 04 00 00       	push   $0x407
  8022f5:	ff 75 f4             	push   -0xc(%ebp)
  8022f8:	6a 00                	push   $0x0
  8022fa:	e8 49 ea ff ff       	call   800d48 <sys_page_alloc>
  8022ff:	83 c4 10             	add    $0x10,%esp
  802302:	85 c0                	test   %eax,%eax
  802304:	78 21                	js     802327 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  802306:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802309:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80230f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802311:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802314:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80231b:	83 ec 0c             	sub    $0xc,%esp
  80231e:	50                   	push   %eax
  80231f:	e8 f7 ee ff ff       	call   80121b <fd2num>
  802324:	83 c4 10             	add    $0x10,%esp
}
  802327:	c9                   	leave  
  802328:	c3                   	ret    

00802329 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802329:	55                   	push   %ebp
  80232a:	89 e5                	mov    %esp,%ebp
  80232c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  80232f:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  802336:	74 0a                	je     802342 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802338:	8b 45 08             	mov    0x8(%ebp),%eax
  80233b:	a3 04 80 80 00       	mov    %eax,0x808004
}
  802340:	c9                   	leave  
  802341:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  802342:	e8 c3 e9 ff ff       	call   800d0a <sys_getenvid>
  802347:	83 ec 04             	sub    $0x4,%esp
  80234a:	68 07 0e 00 00       	push   $0xe07
  80234f:	68 00 f0 bf ee       	push   $0xeebff000
  802354:	50                   	push   %eax
  802355:	e8 ee e9 ff ff       	call   800d48 <sys_page_alloc>
		if (r < 0) {
  80235a:	83 c4 10             	add    $0x10,%esp
  80235d:	85 c0                	test   %eax,%eax
  80235f:	78 2c                	js     80238d <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802361:	e8 a4 e9 ff ff       	call   800d0a <sys_getenvid>
  802366:	83 ec 08             	sub    $0x8,%esp
  802369:	68 9f 23 80 00       	push   $0x80239f
  80236e:	50                   	push   %eax
  80236f:	e8 1f eb ff ff       	call   800e93 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802374:	83 c4 10             	add    $0x10,%esp
  802377:	85 c0                	test   %eax,%eax
  802379:	79 bd                	jns    802338 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  80237b:	50                   	push   %eax
  80237c:	68 9c 2d 80 00       	push   $0x802d9c
  802381:	6a 28                	push   $0x28
  802383:	68 d2 2d 80 00       	push   $0x802dd2
  802388:	e8 0a df ff ff       	call   800297 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  80238d:	50                   	push   %eax
  80238e:	68 5c 2d 80 00       	push   $0x802d5c
  802393:	6a 23                	push   $0x23
  802395:	68 d2 2d 80 00       	push   $0x802dd2
  80239a:	e8 f8 de ff ff       	call   800297 <_panic>

0080239f <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80239f:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023a0:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  8023a5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023a7:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  8023aa:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  8023ae:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  8023b1:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  8023b5:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  8023b9:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  8023bb:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  8023be:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  8023bf:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  8023c2:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  8023c3:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  8023c4:	c3                   	ret    

008023c5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8023c5:	55                   	push   %ebp
  8023c6:	89 e5                	mov    %esp,%ebp
  8023c8:	56                   	push   %esi
  8023c9:	53                   	push   %ebx
  8023ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8023cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8023d3:	85 c0                	test   %eax,%eax
  8023d5:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8023da:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8023dd:	83 ec 0c             	sub    $0xc,%esp
  8023e0:	50                   	push   %eax
  8023e1:	e8 12 eb ff ff       	call   800ef8 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8023e6:	83 c4 10             	add    $0x10,%esp
  8023e9:	85 f6                	test   %esi,%esi
  8023eb:	74 17                	je     802404 <ipc_recv+0x3f>
  8023ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8023f2:	85 c0                	test   %eax,%eax
  8023f4:	78 0c                	js     802402 <ipc_recv+0x3d>
  8023f6:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8023fc:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  802402:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802404:	85 db                	test   %ebx,%ebx
  802406:	74 17                	je     80241f <ipc_recv+0x5a>
  802408:	ba 00 00 00 00       	mov    $0x0,%edx
  80240d:	85 c0                	test   %eax,%eax
  80240f:	78 0c                	js     80241d <ipc_recv+0x58>
  802411:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802417:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  80241d:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  80241f:	85 c0                	test   %eax,%eax
  802421:	78 0b                	js     80242e <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  802423:	a1 00 40 80 00       	mov    0x804000,%eax
  802428:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  80242e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802431:	5b                   	pop    %ebx
  802432:	5e                   	pop    %esi
  802433:	5d                   	pop    %ebp
  802434:	c3                   	ret    

00802435 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802435:	55                   	push   %ebp
  802436:	89 e5                	mov    %esp,%ebp
  802438:	57                   	push   %edi
  802439:	56                   	push   %esi
  80243a:	53                   	push   %ebx
  80243b:	83 ec 0c             	sub    $0xc,%esp
  80243e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802441:	8b 75 0c             	mov    0xc(%ebp),%esi
  802444:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802447:	85 db                	test   %ebx,%ebx
  802449:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80244e:	0f 44 d8             	cmove  %eax,%ebx
  802451:	eb 05                	jmp    802458 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802453:	e8 d1 e8 ff ff       	call   800d29 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802458:	ff 75 14             	push   0x14(%ebp)
  80245b:	53                   	push   %ebx
  80245c:	56                   	push   %esi
  80245d:	57                   	push   %edi
  80245e:	e8 72 ea ff ff       	call   800ed5 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802463:	83 c4 10             	add    $0x10,%esp
  802466:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802469:	74 e8                	je     802453 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80246b:	85 c0                	test   %eax,%eax
  80246d:	78 08                	js     802477 <ipc_send+0x42>
	}while (r<0);

}
  80246f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802472:	5b                   	pop    %ebx
  802473:	5e                   	pop    %esi
  802474:	5f                   	pop    %edi
  802475:	5d                   	pop    %ebp
  802476:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802477:	50                   	push   %eax
  802478:	68 e0 2d 80 00       	push   $0x802de0
  80247d:	6a 3d                	push   $0x3d
  80247f:	68 f4 2d 80 00       	push   $0x802df4
  802484:	e8 0e de ff ff       	call   800297 <_panic>

00802489 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802489:	55                   	push   %ebp
  80248a:	89 e5                	mov    %esp,%ebp
  80248c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80248f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802494:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  80249a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8024a0:	8b 52 60             	mov    0x60(%edx),%edx
  8024a3:	39 ca                	cmp    %ecx,%edx
  8024a5:	74 11                	je     8024b8 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  8024a7:	83 c0 01             	add    $0x1,%eax
  8024aa:	3d 00 04 00 00       	cmp    $0x400,%eax
  8024af:	75 e3                	jne    802494 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8024b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8024b6:	eb 0e                	jmp    8024c6 <ipc_find_env+0x3d>
			return envs[i].env_id;
  8024b8:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8024be:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8024c3:	8b 40 58             	mov    0x58(%eax),%eax
}
  8024c6:	5d                   	pop    %ebp
  8024c7:	c3                   	ret    

008024c8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8024c8:	55                   	push   %ebp
  8024c9:	89 e5                	mov    %esp,%ebp
  8024cb:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8024ce:	89 c2                	mov    %eax,%edx
  8024d0:	c1 ea 16             	shr    $0x16,%edx
  8024d3:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8024da:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8024df:	f6 c1 01             	test   $0x1,%cl
  8024e2:	74 1c                	je     802500 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8024e4:	c1 e8 0c             	shr    $0xc,%eax
  8024e7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8024ee:	a8 01                	test   $0x1,%al
  8024f0:	74 0e                	je     802500 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8024f2:	c1 e8 0c             	shr    $0xc,%eax
  8024f5:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8024fc:	ef 
  8024fd:	0f b7 d2             	movzwl %dx,%edx
}
  802500:	89 d0                	mov    %edx,%eax
  802502:	5d                   	pop    %ebp
  802503:	c3                   	ret    
  802504:	66 90                	xchg   %ax,%ax
  802506:	66 90                	xchg   %ax,%ax
  802508:	66 90                	xchg   %ax,%ax
  80250a:	66 90                	xchg   %ax,%ax
  80250c:	66 90                	xchg   %ax,%ax
  80250e:	66 90                	xchg   %ax,%ax

00802510 <__udivdi3>:
  802510:	f3 0f 1e fb          	endbr32 
  802514:	55                   	push   %ebp
  802515:	57                   	push   %edi
  802516:	56                   	push   %esi
  802517:	53                   	push   %ebx
  802518:	83 ec 1c             	sub    $0x1c,%esp
  80251b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80251f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802523:	8b 74 24 34          	mov    0x34(%esp),%esi
  802527:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80252b:	85 c0                	test   %eax,%eax
  80252d:	75 19                	jne    802548 <__udivdi3+0x38>
  80252f:	39 f3                	cmp    %esi,%ebx
  802531:	76 4d                	jbe    802580 <__udivdi3+0x70>
  802533:	31 ff                	xor    %edi,%edi
  802535:	89 e8                	mov    %ebp,%eax
  802537:	89 f2                	mov    %esi,%edx
  802539:	f7 f3                	div    %ebx
  80253b:	89 fa                	mov    %edi,%edx
  80253d:	83 c4 1c             	add    $0x1c,%esp
  802540:	5b                   	pop    %ebx
  802541:	5e                   	pop    %esi
  802542:	5f                   	pop    %edi
  802543:	5d                   	pop    %ebp
  802544:	c3                   	ret    
  802545:	8d 76 00             	lea    0x0(%esi),%esi
  802548:	39 f0                	cmp    %esi,%eax
  80254a:	76 14                	jbe    802560 <__udivdi3+0x50>
  80254c:	31 ff                	xor    %edi,%edi
  80254e:	31 c0                	xor    %eax,%eax
  802550:	89 fa                	mov    %edi,%edx
  802552:	83 c4 1c             	add    $0x1c,%esp
  802555:	5b                   	pop    %ebx
  802556:	5e                   	pop    %esi
  802557:	5f                   	pop    %edi
  802558:	5d                   	pop    %ebp
  802559:	c3                   	ret    
  80255a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802560:	0f bd f8             	bsr    %eax,%edi
  802563:	83 f7 1f             	xor    $0x1f,%edi
  802566:	75 48                	jne    8025b0 <__udivdi3+0xa0>
  802568:	39 f0                	cmp    %esi,%eax
  80256a:	72 06                	jb     802572 <__udivdi3+0x62>
  80256c:	31 c0                	xor    %eax,%eax
  80256e:	39 eb                	cmp    %ebp,%ebx
  802570:	77 de                	ja     802550 <__udivdi3+0x40>
  802572:	b8 01 00 00 00       	mov    $0x1,%eax
  802577:	eb d7                	jmp    802550 <__udivdi3+0x40>
  802579:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802580:	89 d9                	mov    %ebx,%ecx
  802582:	85 db                	test   %ebx,%ebx
  802584:	75 0b                	jne    802591 <__udivdi3+0x81>
  802586:	b8 01 00 00 00       	mov    $0x1,%eax
  80258b:	31 d2                	xor    %edx,%edx
  80258d:	f7 f3                	div    %ebx
  80258f:	89 c1                	mov    %eax,%ecx
  802591:	31 d2                	xor    %edx,%edx
  802593:	89 f0                	mov    %esi,%eax
  802595:	f7 f1                	div    %ecx
  802597:	89 c6                	mov    %eax,%esi
  802599:	89 e8                	mov    %ebp,%eax
  80259b:	89 f7                	mov    %esi,%edi
  80259d:	f7 f1                	div    %ecx
  80259f:	89 fa                	mov    %edi,%edx
  8025a1:	83 c4 1c             	add    $0x1c,%esp
  8025a4:	5b                   	pop    %ebx
  8025a5:	5e                   	pop    %esi
  8025a6:	5f                   	pop    %edi
  8025a7:	5d                   	pop    %ebp
  8025a8:	c3                   	ret    
  8025a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025b0:	89 f9                	mov    %edi,%ecx
  8025b2:	ba 20 00 00 00       	mov    $0x20,%edx
  8025b7:	29 fa                	sub    %edi,%edx
  8025b9:	d3 e0                	shl    %cl,%eax
  8025bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025bf:	89 d1                	mov    %edx,%ecx
  8025c1:	89 d8                	mov    %ebx,%eax
  8025c3:	d3 e8                	shr    %cl,%eax
  8025c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8025c9:	09 c1                	or     %eax,%ecx
  8025cb:	89 f0                	mov    %esi,%eax
  8025cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025d1:	89 f9                	mov    %edi,%ecx
  8025d3:	d3 e3                	shl    %cl,%ebx
  8025d5:	89 d1                	mov    %edx,%ecx
  8025d7:	d3 e8                	shr    %cl,%eax
  8025d9:	89 f9                	mov    %edi,%ecx
  8025db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8025df:	89 eb                	mov    %ebp,%ebx
  8025e1:	d3 e6                	shl    %cl,%esi
  8025e3:	89 d1                	mov    %edx,%ecx
  8025e5:	d3 eb                	shr    %cl,%ebx
  8025e7:	09 f3                	or     %esi,%ebx
  8025e9:	89 c6                	mov    %eax,%esi
  8025eb:	89 f2                	mov    %esi,%edx
  8025ed:	89 d8                	mov    %ebx,%eax
  8025ef:	f7 74 24 08          	divl   0x8(%esp)
  8025f3:	89 d6                	mov    %edx,%esi
  8025f5:	89 c3                	mov    %eax,%ebx
  8025f7:	f7 64 24 0c          	mull   0xc(%esp)
  8025fb:	39 d6                	cmp    %edx,%esi
  8025fd:	72 19                	jb     802618 <__udivdi3+0x108>
  8025ff:	89 f9                	mov    %edi,%ecx
  802601:	d3 e5                	shl    %cl,%ebp
  802603:	39 c5                	cmp    %eax,%ebp
  802605:	73 04                	jae    80260b <__udivdi3+0xfb>
  802607:	39 d6                	cmp    %edx,%esi
  802609:	74 0d                	je     802618 <__udivdi3+0x108>
  80260b:	89 d8                	mov    %ebx,%eax
  80260d:	31 ff                	xor    %edi,%edi
  80260f:	e9 3c ff ff ff       	jmp    802550 <__udivdi3+0x40>
  802614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802618:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80261b:	31 ff                	xor    %edi,%edi
  80261d:	e9 2e ff ff ff       	jmp    802550 <__udivdi3+0x40>
  802622:	66 90                	xchg   %ax,%ax
  802624:	66 90                	xchg   %ax,%ax
  802626:	66 90                	xchg   %ax,%ax
  802628:	66 90                	xchg   %ax,%ax
  80262a:	66 90                	xchg   %ax,%ax
  80262c:	66 90                	xchg   %ax,%ax
  80262e:	66 90                	xchg   %ax,%ax

00802630 <__umoddi3>:
  802630:	f3 0f 1e fb          	endbr32 
  802634:	55                   	push   %ebp
  802635:	57                   	push   %edi
  802636:	56                   	push   %esi
  802637:	53                   	push   %ebx
  802638:	83 ec 1c             	sub    $0x1c,%esp
  80263b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80263f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802643:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802647:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80264b:	89 f0                	mov    %esi,%eax
  80264d:	89 da                	mov    %ebx,%edx
  80264f:	85 ff                	test   %edi,%edi
  802651:	75 15                	jne    802668 <__umoddi3+0x38>
  802653:	39 dd                	cmp    %ebx,%ebp
  802655:	76 39                	jbe    802690 <__umoddi3+0x60>
  802657:	f7 f5                	div    %ebp
  802659:	89 d0                	mov    %edx,%eax
  80265b:	31 d2                	xor    %edx,%edx
  80265d:	83 c4 1c             	add    $0x1c,%esp
  802660:	5b                   	pop    %ebx
  802661:	5e                   	pop    %esi
  802662:	5f                   	pop    %edi
  802663:	5d                   	pop    %ebp
  802664:	c3                   	ret    
  802665:	8d 76 00             	lea    0x0(%esi),%esi
  802668:	39 df                	cmp    %ebx,%edi
  80266a:	77 f1                	ja     80265d <__umoddi3+0x2d>
  80266c:	0f bd cf             	bsr    %edi,%ecx
  80266f:	83 f1 1f             	xor    $0x1f,%ecx
  802672:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802676:	75 40                	jne    8026b8 <__umoddi3+0x88>
  802678:	39 df                	cmp    %ebx,%edi
  80267a:	72 04                	jb     802680 <__umoddi3+0x50>
  80267c:	39 f5                	cmp    %esi,%ebp
  80267e:	77 dd                	ja     80265d <__umoddi3+0x2d>
  802680:	89 da                	mov    %ebx,%edx
  802682:	89 f0                	mov    %esi,%eax
  802684:	29 e8                	sub    %ebp,%eax
  802686:	19 fa                	sbb    %edi,%edx
  802688:	eb d3                	jmp    80265d <__umoddi3+0x2d>
  80268a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802690:	89 e9                	mov    %ebp,%ecx
  802692:	85 ed                	test   %ebp,%ebp
  802694:	75 0b                	jne    8026a1 <__umoddi3+0x71>
  802696:	b8 01 00 00 00       	mov    $0x1,%eax
  80269b:	31 d2                	xor    %edx,%edx
  80269d:	f7 f5                	div    %ebp
  80269f:	89 c1                	mov    %eax,%ecx
  8026a1:	89 d8                	mov    %ebx,%eax
  8026a3:	31 d2                	xor    %edx,%edx
  8026a5:	f7 f1                	div    %ecx
  8026a7:	89 f0                	mov    %esi,%eax
  8026a9:	f7 f1                	div    %ecx
  8026ab:	89 d0                	mov    %edx,%eax
  8026ad:	31 d2                	xor    %edx,%edx
  8026af:	eb ac                	jmp    80265d <__umoddi3+0x2d>
  8026b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026b8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8026bc:	ba 20 00 00 00       	mov    $0x20,%edx
  8026c1:	29 c2                	sub    %eax,%edx
  8026c3:	89 c1                	mov    %eax,%ecx
  8026c5:	89 e8                	mov    %ebp,%eax
  8026c7:	d3 e7                	shl    %cl,%edi
  8026c9:	89 d1                	mov    %edx,%ecx
  8026cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8026cf:	d3 e8                	shr    %cl,%eax
  8026d1:	89 c1                	mov    %eax,%ecx
  8026d3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8026d7:	09 f9                	or     %edi,%ecx
  8026d9:	89 df                	mov    %ebx,%edi
  8026db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8026df:	89 c1                	mov    %eax,%ecx
  8026e1:	d3 e5                	shl    %cl,%ebp
  8026e3:	89 d1                	mov    %edx,%ecx
  8026e5:	d3 ef                	shr    %cl,%edi
  8026e7:	89 c1                	mov    %eax,%ecx
  8026e9:	89 f0                	mov    %esi,%eax
  8026eb:	d3 e3                	shl    %cl,%ebx
  8026ed:	89 d1                	mov    %edx,%ecx
  8026ef:	89 fa                	mov    %edi,%edx
  8026f1:	d3 e8                	shr    %cl,%eax
  8026f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8026f8:	09 d8                	or     %ebx,%eax
  8026fa:	f7 74 24 08          	divl   0x8(%esp)
  8026fe:	89 d3                	mov    %edx,%ebx
  802700:	d3 e6                	shl    %cl,%esi
  802702:	f7 e5                	mul    %ebp
  802704:	89 c7                	mov    %eax,%edi
  802706:	89 d1                	mov    %edx,%ecx
  802708:	39 d3                	cmp    %edx,%ebx
  80270a:	72 06                	jb     802712 <__umoddi3+0xe2>
  80270c:	75 0e                	jne    80271c <__umoddi3+0xec>
  80270e:	39 c6                	cmp    %eax,%esi
  802710:	73 0a                	jae    80271c <__umoddi3+0xec>
  802712:	29 e8                	sub    %ebp,%eax
  802714:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802718:	89 d1                	mov    %edx,%ecx
  80271a:	89 c7                	mov    %eax,%edi
  80271c:	89 f5                	mov    %esi,%ebp
  80271e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802722:	29 fd                	sub    %edi,%ebp
  802724:	19 cb                	sbb    %ecx,%ebx
  802726:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80272b:	89 d8                	mov    %ebx,%eax
  80272d:	d3 e0                	shl    %cl,%eax
  80272f:	89 f1                	mov    %esi,%ecx
  802731:	d3 ed                	shr    %cl,%ebp
  802733:	d3 eb                	shr    %cl,%ebx
  802735:	09 e8                	or     %ebp,%eax
  802737:	89 da                	mov    %ebx,%edx
  802739:	83 c4 1c             	add    $0x1c,%esp
  80273c:	5b                   	pop    %ebx
  80273d:	5e                   	pop    %esi
  80273e:	5f                   	pop    %edi
  80273f:	5d                   	pop    %ebp
  802740:	c3                   	ret    
