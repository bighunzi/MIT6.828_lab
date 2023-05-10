
obj/user/pingpongs.debug：     文件格式 elf32-i386


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
  80002c:	e8 d2 00 00 00       	call   800103 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003c:	e8 49 10 00 00       	call   80108a <sfork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	75 74                	jne    8000bc <umain+0x89>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  800048:	83 ec 04             	sub    $0x4,%esp
  80004b:	6a 00                	push   $0x0
  80004d:	6a 00                	push   $0x0
  80004f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800052:	50                   	push   %eax
  800053:	e8 4c 10 00 00       	call   8010a4 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  800058:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  80005e:	8b 7b 58             	mov    0x58(%ebx),%edi
  800061:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800064:	a1 00 40 80 00       	mov    0x804000,%eax
  800069:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80006c:	e8 22 0b 00 00       	call   800b93 <sys_getenvid>
  800071:	83 c4 08             	add    $0x8,%esp
  800074:	57                   	push   %edi
  800075:	53                   	push   %ebx
  800076:	56                   	push   %esi
  800077:	ff 75 d4             	push   -0x2c(%ebp)
  80007a:	50                   	push   %eax
  80007b:	68 50 26 80 00       	push   $0x802650
  800080:	e8 76 01 00 00       	call   8001fb <cprintf>
		if (val == 10)
  800085:	a1 00 40 80 00       	mov    0x804000,%eax
  80008a:	83 c4 20             	add    $0x20,%esp
  80008d:	83 f8 0a             	cmp    $0xa,%eax
  800090:	74 22                	je     8000b4 <umain+0x81>
			return;
		++val;
  800092:	83 c0 01             	add    $0x1,%eax
  800095:	a3 00 40 80 00       	mov    %eax,0x804000
		ipc_send(who, 0, 0, 0);
  80009a:	6a 00                	push   $0x0
  80009c:	6a 00                	push   $0x0
  80009e:	6a 00                	push   $0x0
  8000a0:	ff 75 e4             	push   -0x1c(%ebp)
  8000a3:	e8 6c 10 00 00       	call   801114 <ipc_send>
		if (val == 10)
  8000a8:	83 c4 10             	add    $0x10,%esp
  8000ab:	83 3d 00 40 80 00 0a 	cmpl   $0xa,0x804000
  8000b2:	75 94                	jne    800048 <umain+0x15>
			return;
	}

}
  8000b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  8000bc:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  8000c2:	e8 cc 0a 00 00       	call   800b93 <sys_getenvid>
  8000c7:	83 ec 04             	sub    $0x4,%esp
  8000ca:	53                   	push   %ebx
  8000cb:	50                   	push   %eax
  8000cc:	68 20 26 80 00       	push   $0x802620
  8000d1:	e8 25 01 00 00       	call   8001fb <cprintf>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000d6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8000d9:	e8 b5 0a 00 00       	call   800b93 <sys_getenvid>
  8000de:	83 c4 0c             	add    $0xc,%esp
  8000e1:	53                   	push   %ebx
  8000e2:	50                   	push   %eax
  8000e3:	68 3a 26 80 00       	push   $0x80263a
  8000e8:	e8 0e 01 00 00       	call   8001fb <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ed:	6a 00                	push   $0x0
  8000ef:	6a 00                	push   $0x0
  8000f1:	6a 00                	push   $0x0
  8000f3:	ff 75 e4             	push   -0x1c(%ebp)
  8000f6:	e8 19 10 00 00       	call   801114 <ipc_send>
  8000fb:	83 c4 20             	add    $0x20,%esp
  8000fe:	e9 45 ff ff ff       	jmp    800048 <umain+0x15>

00800103 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800103:	55                   	push   %ebp
  800104:	89 e5                	mov    %esp,%ebp
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80010b:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  80010e:	e8 80 0a 00 00       	call   800b93 <sys_getenvid>
  800113:	25 ff 03 00 00       	and    $0x3ff,%eax
  800118:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80011e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800123:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800128:	85 db                	test   %ebx,%ebx
  80012a:	7e 07                	jle    800133 <libmain+0x30>
		binaryname = argv[0];
  80012c:	8b 06                	mov    (%esi),%eax
  80012e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800133:	83 ec 08             	sub    $0x8,%esp
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
  800138:	e8 f6 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80013d:	e8 0a 00 00 00       	call   80014c <exit>
}
  800142:	83 c4 10             	add    $0x10,%esp
  800145:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800148:	5b                   	pop    %ebx
  800149:	5e                   	pop    %esi
  80014a:	5d                   	pop    %ebp
  80014b:	c3                   	ret    

0080014c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800152:	e8 21 12 00 00       	call   801378 <close_all>
	sys_env_destroy(0);
  800157:	83 ec 0c             	sub    $0xc,%esp
  80015a:	6a 00                	push   $0x0
  80015c:	e8 f1 09 00 00       	call   800b52 <sys_env_destroy>
}
  800161:	83 c4 10             	add    $0x10,%esp
  800164:	c9                   	leave  
  800165:	c3                   	ret    

00800166 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	53                   	push   %ebx
  80016a:	83 ec 04             	sub    $0x4,%esp
  80016d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800170:	8b 13                	mov    (%ebx),%edx
  800172:	8d 42 01             	lea    0x1(%edx),%eax
  800175:	89 03                	mov    %eax,(%ebx)
  800177:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80017a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80017e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800183:	74 09                	je     80018e <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800185:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800189:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80018c:	c9                   	leave  
  80018d:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80018e:	83 ec 08             	sub    $0x8,%esp
  800191:	68 ff 00 00 00       	push   $0xff
  800196:	8d 43 08             	lea    0x8(%ebx),%eax
  800199:	50                   	push   %eax
  80019a:	e8 76 09 00 00       	call   800b15 <sys_cputs>
		b->idx = 0;
  80019f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a5:	83 c4 10             	add    $0x10,%esp
  8001a8:	eb db                	jmp    800185 <putch+0x1f>

008001aa <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001aa:	55                   	push   %ebp
  8001ab:	89 e5                	mov    %esp,%ebp
  8001ad:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ba:	00 00 00 
	b.cnt = 0;
  8001bd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c7:	ff 75 0c             	push   0xc(%ebp)
  8001ca:	ff 75 08             	push   0x8(%ebp)
  8001cd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d3:	50                   	push   %eax
  8001d4:	68 66 01 80 00       	push   $0x800166
  8001d9:	e8 14 01 00 00       	call   8002f2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001de:	83 c4 08             	add    $0x8,%esp
  8001e1:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001e7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ed:	50                   	push   %eax
  8001ee:	e8 22 09 00 00       	call   800b15 <sys_cputs>

	return b.cnt;
}
  8001f3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f9:	c9                   	leave  
  8001fa:	c3                   	ret    

008001fb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001fb:	55                   	push   %ebp
  8001fc:	89 e5                	mov    %esp,%ebp
  8001fe:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800201:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800204:	50                   	push   %eax
  800205:	ff 75 08             	push   0x8(%ebp)
  800208:	e8 9d ff ff ff       	call   8001aa <vcprintf>
	va_end(ap);

	return cnt;
}
  80020d:	c9                   	leave  
  80020e:	c3                   	ret    

0080020f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	57                   	push   %edi
  800213:	56                   	push   %esi
  800214:	53                   	push   %ebx
  800215:	83 ec 1c             	sub    $0x1c,%esp
  800218:	89 c7                	mov    %eax,%edi
  80021a:	89 d6                	mov    %edx,%esi
  80021c:	8b 45 08             	mov    0x8(%ebp),%eax
  80021f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800222:	89 d1                	mov    %edx,%ecx
  800224:	89 c2                	mov    %eax,%edx
  800226:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800229:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80022c:	8b 45 10             	mov    0x10(%ebp),%eax
  80022f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800232:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800235:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80023c:	39 c2                	cmp    %eax,%edx
  80023e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800241:	72 3e                	jb     800281 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800243:	83 ec 0c             	sub    $0xc,%esp
  800246:	ff 75 18             	push   0x18(%ebp)
  800249:	83 eb 01             	sub    $0x1,%ebx
  80024c:	53                   	push   %ebx
  80024d:	50                   	push   %eax
  80024e:	83 ec 08             	sub    $0x8,%esp
  800251:	ff 75 e4             	push   -0x1c(%ebp)
  800254:	ff 75 e0             	push   -0x20(%ebp)
  800257:	ff 75 dc             	push   -0x24(%ebp)
  80025a:	ff 75 d8             	push   -0x28(%ebp)
  80025d:	e8 7e 21 00 00       	call   8023e0 <__udivdi3>
  800262:	83 c4 18             	add    $0x18,%esp
  800265:	52                   	push   %edx
  800266:	50                   	push   %eax
  800267:	89 f2                	mov    %esi,%edx
  800269:	89 f8                	mov    %edi,%eax
  80026b:	e8 9f ff ff ff       	call   80020f <printnum>
  800270:	83 c4 20             	add    $0x20,%esp
  800273:	eb 13                	jmp    800288 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800275:	83 ec 08             	sub    $0x8,%esp
  800278:	56                   	push   %esi
  800279:	ff 75 18             	push   0x18(%ebp)
  80027c:	ff d7                	call   *%edi
  80027e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800281:	83 eb 01             	sub    $0x1,%ebx
  800284:	85 db                	test   %ebx,%ebx
  800286:	7f ed                	jg     800275 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800288:	83 ec 08             	sub    $0x8,%esp
  80028b:	56                   	push   %esi
  80028c:	83 ec 04             	sub    $0x4,%esp
  80028f:	ff 75 e4             	push   -0x1c(%ebp)
  800292:	ff 75 e0             	push   -0x20(%ebp)
  800295:	ff 75 dc             	push   -0x24(%ebp)
  800298:	ff 75 d8             	push   -0x28(%ebp)
  80029b:	e8 60 22 00 00       	call   802500 <__umoddi3>
  8002a0:	83 c4 14             	add    $0x14,%esp
  8002a3:	0f be 80 80 26 80 00 	movsbl 0x802680(%eax),%eax
  8002aa:	50                   	push   %eax
  8002ab:	ff d7                	call   *%edi
}
  8002ad:	83 c4 10             	add    $0x10,%esp
  8002b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b3:	5b                   	pop    %ebx
  8002b4:	5e                   	pop    %esi
  8002b5:	5f                   	pop    %edi
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    

008002b8 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b8:	55                   	push   %ebp
  8002b9:	89 e5                	mov    %esp,%ebp
  8002bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002be:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002c2:	8b 10                	mov    (%eax),%edx
  8002c4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c7:	73 0a                	jae    8002d3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002cc:	89 08                	mov    %ecx,(%eax)
  8002ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8002d1:	88 02                	mov    %al,(%edx)
}
  8002d3:	5d                   	pop    %ebp
  8002d4:	c3                   	ret    

008002d5 <printfmt>:
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002db:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002de:	50                   	push   %eax
  8002df:	ff 75 10             	push   0x10(%ebp)
  8002e2:	ff 75 0c             	push   0xc(%ebp)
  8002e5:	ff 75 08             	push   0x8(%ebp)
  8002e8:	e8 05 00 00 00       	call   8002f2 <vprintfmt>
}
  8002ed:	83 c4 10             	add    $0x10,%esp
  8002f0:	c9                   	leave  
  8002f1:	c3                   	ret    

008002f2 <vprintfmt>:
{
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	57                   	push   %edi
  8002f6:	56                   	push   %esi
  8002f7:	53                   	push   %ebx
  8002f8:	83 ec 3c             	sub    $0x3c,%esp
  8002fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8002fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800301:	8b 7d 10             	mov    0x10(%ebp),%edi
  800304:	eb 0a                	jmp    800310 <vprintfmt+0x1e>
			putch(ch, putdat);
  800306:	83 ec 08             	sub    $0x8,%esp
  800309:	53                   	push   %ebx
  80030a:	50                   	push   %eax
  80030b:	ff d6                	call   *%esi
  80030d:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800310:	83 c7 01             	add    $0x1,%edi
  800313:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800317:	83 f8 25             	cmp    $0x25,%eax
  80031a:	74 0c                	je     800328 <vprintfmt+0x36>
			if (ch == '\0')
  80031c:	85 c0                	test   %eax,%eax
  80031e:	75 e6                	jne    800306 <vprintfmt+0x14>
}
  800320:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800323:	5b                   	pop    %ebx
  800324:	5e                   	pop    %esi
  800325:	5f                   	pop    %edi
  800326:	5d                   	pop    %ebp
  800327:	c3                   	ret    
		padc = ' ';
  800328:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80032c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800333:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80033a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800341:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800346:	8d 47 01             	lea    0x1(%edi),%eax
  800349:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80034c:	0f b6 17             	movzbl (%edi),%edx
  80034f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800352:	3c 55                	cmp    $0x55,%al
  800354:	0f 87 bb 03 00 00    	ja     800715 <vprintfmt+0x423>
  80035a:	0f b6 c0             	movzbl %al,%eax
  80035d:	ff 24 85 c0 27 80 00 	jmp    *0x8027c0(,%eax,4)
  800364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800367:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80036b:	eb d9                	jmp    800346 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80036d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800370:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800374:	eb d0                	jmp    800346 <vprintfmt+0x54>
  800376:	0f b6 d2             	movzbl %dl,%edx
  800379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80037c:	b8 00 00 00 00       	mov    $0x0,%eax
  800381:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800384:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800387:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80038b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80038e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800391:	83 f9 09             	cmp    $0x9,%ecx
  800394:	77 55                	ja     8003eb <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800396:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800399:	eb e9                	jmp    800384 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80039b:	8b 45 14             	mov    0x14(%ebp),%eax
  80039e:	8b 00                	mov    (%eax),%eax
  8003a0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a6:	8d 40 04             	lea    0x4(%eax),%eax
  8003a9:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003af:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b3:	79 91                	jns    800346 <vprintfmt+0x54>
				width = precision, precision = -1;
  8003b5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003b8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003bb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003c2:	eb 82                	jmp    800346 <vprintfmt+0x54>
  8003c4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003c7:	85 d2                	test   %edx,%edx
  8003c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ce:	0f 49 c2             	cmovns %edx,%eax
  8003d1:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003d7:	e9 6a ff ff ff       	jmp    800346 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003df:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003e6:	e9 5b ff ff ff       	jmp    800346 <vprintfmt+0x54>
  8003eb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003f1:	eb bc                	jmp    8003af <vprintfmt+0xbd>
			lflag++;
  8003f3:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f9:	e9 48 ff ff ff       	jmp    800346 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800401:	8d 78 04             	lea    0x4(%eax),%edi
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	53                   	push   %ebx
  800408:	ff 30                	push   (%eax)
  80040a:	ff d6                	call   *%esi
			break;
  80040c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80040f:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800412:	e9 9d 02 00 00       	jmp    8006b4 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800417:	8b 45 14             	mov    0x14(%ebp),%eax
  80041a:	8d 78 04             	lea    0x4(%eax),%edi
  80041d:	8b 10                	mov    (%eax),%edx
  80041f:	89 d0                	mov    %edx,%eax
  800421:	f7 d8                	neg    %eax
  800423:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800426:	83 f8 0f             	cmp    $0xf,%eax
  800429:	7f 23                	jg     80044e <vprintfmt+0x15c>
  80042b:	8b 14 85 20 29 80 00 	mov    0x802920(,%eax,4),%edx
  800432:	85 d2                	test   %edx,%edx
  800434:	74 18                	je     80044e <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800436:	52                   	push   %edx
  800437:	68 41 2b 80 00       	push   $0x802b41
  80043c:	53                   	push   %ebx
  80043d:	56                   	push   %esi
  80043e:	e8 92 fe ff ff       	call   8002d5 <printfmt>
  800443:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800446:	89 7d 14             	mov    %edi,0x14(%ebp)
  800449:	e9 66 02 00 00       	jmp    8006b4 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80044e:	50                   	push   %eax
  80044f:	68 98 26 80 00       	push   $0x802698
  800454:	53                   	push   %ebx
  800455:	56                   	push   %esi
  800456:	e8 7a fe ff ff       	call   8002d5 <printfmt>
  80045b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80045e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800461:	e9 4e 02 00 00       	jmp    8006b4 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800466:	8b 45 14             	mov    0x14(%ebp),%eax
  800469:	83 c0 04             	add    $0x4,%eax
  80046c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80046f:	8b 45 14             	mov    0x14(%ebp),%eax
  800472:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800474:	85 d2                	test   %edx,%edx
  800476:	b8 91 26 80 00       	mov    $0x802691,%eax
  80047b:	0f 45 c2             	cmovne %edx,%eax
  80047e:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800481:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800485:	7e 06                	jle    80048d <vprintfmt+0x19b>
  800487:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80048b:	75 0d                	jne    80049a <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800490:	89 c7                	mov    %eax,%edi
  800492:	03 45 e0             	add    -0x20(%ebp),%eax
  800495:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800498:	eb 55                	jmp    8004ef <vprintfmt+0x1fd>
  80049a:	83 ec 08             	sub    $0x8,%esp
  80049d:	ff 75 d8             	push   -0x28(%ebp)
  8004a0:	ff 75 cc             	push   -0x34(%ebp)
  8004a3:	e8 0a 03 00 00       	call   8007b2 <strnlen>
  8004a8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ab:	29 c1                	sub    %eax,%ecx
  8004ad:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004b5:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bc:	eb 0f                	jmp    8004cd <vprintfmt+0x1db>
					putch(padc, putdat);
  8004be:	83 ec 08             	sub    $0x8,%esp
  8004c1:	53                   	push   %ebx
  8004c2:	ff 75 e0             	push   -0x20(%ebp)
  8004c5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c7:	83 ef 01             	sub    $0x1,%edi
  8004ca:	83 c4 10             	add    $0x10,%esp
  8004cd:	85 ff                	test   %edi,%edi
  8004cf:	7f ed                	jg     8004be <vprintfmt+0x1cc>
  8004d1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004d4:	85 d2                	test   %edx,%edx
  8004d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004db:	0f 49 c2             	cmovns %edx,%eax
  8004de:	29 c2                	sub    %eax,%edx
  8004e0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004e3:	eb a8                	jmp    80048d <vprintfmt+0x19b>
					putch(ch, putdat);
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	53                   	push   %ebx
  8004e9:	52                   	push   %edx
  8004ea:	ff d6                	call   *%esi
  8004ec:	83 c4 10             	add    $0x10,%esp
  8004ef:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004f2:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f4:	83 c7 01             	add    $0x1,%edi
  8004f7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004fb:	0f be d0             	movsbl %al,%edx
  8004fe:	85 d2                	test   %edx,%edx
  800500:	74 4b                	je     80054d <vprintfmt+0x25b>
  800502:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800506:	78 06                	js     80050e <vprintfmt+0x21c>
  800508:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80050c:	78 1e                	js     80052c <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80050e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800512:	74 d1                	je     8004e5 <vprintfmt+0x1f3>
  800514:	0f be c0             	movsbl %al,%eax
  800517:	83 e8 20             	sub    $0x20,%eax
  80051a:	83 f8 5e             	cmp    $0x5e,%eax
  80051d:	76 c6                	jbe    8004e5 <vprintfmt+0x1f3>
					putch('?', putdat);
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	53                   	push   %ebx
  800523:	6a 3f                	push   $0x3f
  800525:	ff d6                	call   *%esi
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	eb c3                	jmp    8004ef <vprintfmt+0x1fd>
  80052c:	89 cf                	mov    %ecx,%edi
  80052e:	eb 0e                	jmp    80053e <vprintfmt+0x24c>
				putch(' ', putdat);
  800530:	83 ec 08             	sub    $0x8,%esp
  800533:	53                   	push   %ebx
  800534:	6a 20                	push   $0x20
  800536:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800538:	83 ef 01             	sub    $0x1,%edi
  80053b:	83 c4 10             	add    $0x10,%esp
  80053e:	85 ff                	test   %edi,%edi
  800540:	7f ee                	jg     800530 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800542:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800545:	89 45 14             	mov    %eax,0x14(%ebp)
  800548:	e9 67 01 00 00       	jmp    8006b4 <vprintfmt+0x3c2>
  80054d:	89 cf                	mov    %ecx,%edi
  80054f:	eb ed                	jmp    80053e <vprintfmt+0x24c>
	if (lflag >= 2)
  800551:	83 f9 01             	cmp    $0x1,%ecx
  800554:	7f 1b                	jg     800571 <vprintfmt+0x27f>
	else if (lflag)
  800556:	85 c9                	test   %ecx,%ecx
  800558:	74 63                	je     8005bd <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8b 00                	mov    (%eax),%eax
  80055f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800562:	99                   	cltd   
  800563:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8d 40 04             	lea    0x4(%eax),%eax
  80056c:	89 45 14             	mov    %eax,0x14(%ebp)
  80056f:	eb 17                	jmp    800588 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8b 50 04             	mov    0x4(%eax),%edx
  800577:	8b 00                	mov    (%eax),%eax
  800579:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8d 40 08             	lea    0x8(%eax),%eax
  800585:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800588:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80058b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80058e:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800593:	85 c9                	test   %ecx,%ecx
  800595:	0f 89 ff 00 00 00    	jns    80069a <vprintfmt+0x3a8>
				putch('-', putdat);
  80059b:	83 ec 08             	sub    $0x8,%esp
  80059e:	53                   	push   %ebx
  80059f:	6a 2d                	push   $0x2d
  8005a1:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a9:	f7 da                	neg    %edx
  8005ab:	83 d1 00             	adc    $0x0,%ecx
  8005ae:	f7 d9                	neg    %ecx
  8005b0:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005b3:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005b8:	e9 dd 00 00 00       	jmp    80069a <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8b 00                	mov    (%eax),%eax
  8005c2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c5:	99                   	cltd   
  8005c6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cc:	8d 40 04             	lea    0x4(%eax),%eax
  8005cf:	89 45 14             	mov    %eax,0x14(%ebp)
  8005d2:	eb b4                	jmp    800588 <vprintfmt+0x296>
	if (lflag >= 2)
  8005d4:	83 f9 01             	cmp    $0x1,%ecx
  8005d7:	7f 1e                	jg     8005f7 <vprintfmt+0x305>
	else if (lflag)
  8005d9:	85 c9                	test   %ecx,%ecx
  8005db:	74 32                	je     80060f <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8005dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e0:	8b 10                	mov    (%eax),%edx
  8005e2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ed:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8005f2:	e9 a3 00 00 00       	jmp    80069a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8b 10                	mov    (%eax),%edx
  8005fc:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ff:	8d 40 08             	lea    0x8(%eax),%eax
  800602:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800605:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80060a:	e9 8b 00 00 00       	jmp    80069a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8b 10                	mov    (%eax),%edx
  800614:	b9 00 00 00 00       	mov    $0x0,%ecx
  800619:	8d 40 04             	lea    0x4(%eax),%eax
  80061c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80061f:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800624:	eb 74                	jmp    80069a <vprintfmt+0x3a8>
	if (lflag >= 2)
  800626:	83 f9 01             	cmp    $0x1,%ecx
  800629:	7f 1b                	jg     800646 <vprintfmt+0x354>
	else if (lflag)
  80062b:	85 c9                	test   %ecx,%ecx
  80062d:	74 2c                	je     80065b <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8b 10                	mov    (%eax),%edx
  800634:	b9 00 00 00 00       	mov    $0x0,%ecx
  800639:	8d 40 04             	lea    0x4(%eax),%eax
  80063c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80063f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800644:	eb 54                	jmp    80069a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800646:	8b 45 14             	mov    0x14(%ebp),%eax
  800649:	8b 10                	mov    (%eax),%edx
  80064b:	8b 48 04             	mov    0x4(%eax),%ecx
  80064e:	8d 40 08             	lea    0x8(%eax),%eax
  800651:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800654:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800659:	eb 3f                	jmp    80069a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80065b:	8b 45 14             	mov    0x14(%ebp),%eax
  80065e:	8b 10                	mov    (%eax),%edx
  800660:	b9 00 00 00 00       	mov    $0x0,%ecx
  800665:	8d 40 04             	lea    0x4(%eax),%eax
  800668:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80066b:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800670:	eb 28                	jmp    80069a <vprintfmt+0x3a8>
			putch('0', putdat);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	53                   	push   %ebx
  800676:	6a 30                	push   $0x30
  800678:	ff d6                	call   *%esi
			putch('x', putdat);
  80067a:	83 c4 08             	add    $0x8,%esp
  80067d:	53                   	push   %ebx
  80067e:	6a 78                	push   $0x78
  800680:	ff d6                	call   *%esi
			num = (unsigned long long)
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8b 10                	mov    (%eax),%edx
  800687:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80068c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80068f:	8d 40 04             	lea    0x4(%eax),%eax
  800692:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800695:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80069a:	83 ec 0c             	sub    $0xc,%esp
  80069d:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006a1:	50                   	push   %eax
  8006a2:	ff 75 e0             	push   -0x20(%ebp)
  8006a5:	57                   	push   %edi
  8006a6:	51                   	push   %ecx
  8006a7:	52                   	push   %edx
  8006a8:	89 da                	mov    %ebx,%edx
  8006aa:	89 f0                	mov    %esi,%eax
  8006ac:	e8 5e fb ff ff       	call   80020f <printnum>
			break;
  8006b1:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006b7:	e9 54 fc ff ff       	jmp    800310 <vprintfmt+0x1e>
	if (lflag >= 2)
  8006bc:	83 f9 01             	cmp    $0x1,%ecx
  8006bf:	7f 1b                	jg     8006dc <vprintfmt+0x3ea>
	else if (lflag)
  8006c1:	85 c9                	test   %ecx,%ecx
  8006c3:	74 2c                	je     8006f1 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c8:	8b 10                	mov    (%eax),%edx
  8006ca:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cf:	8d 40 04             	lea    0x4(%eax),%eax
  8006d2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d5:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8006da:	eb be                	jmp    80069a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8b 10                	mov    (%eax),%edx
  8006e1:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e4:	8d 40 08             	lea    0x8(%eax),%eax
  8006e7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ea:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8006ef:	eb a9                	jmp    80069a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f4:	8b 10                	mov    (%eax),%edx
  8006f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006fb:	8d 40 04             	lea    0x4(%eax),%eax
  8006fe:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800701:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800706:	eb 92                	jmp    80069a <vprintfmt+0x3a8>
			putch(ch, putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	53                   	push   %ebx
  80070c:	6a 25                	push   $0x25
  80070e:	ff d6                	call   *%esi
			break;
  800710:	83 c4 10             	add    $0x10,%esp
  800713:	eb 9f                	jmp    8006b4 <vprintfmt+0x3c2>
			putch('%', putdat);
  800715:	83 ec 08             	sub    $0x8,%esp
  800718:	53                   	push   %ebx
  800719:	6a 25                	push   $0x25
  80071b:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071d:	83 c4 10             	add    $0x10,%esp
  800720:	89 f8                	mov    %edi,%eax
  800722:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800726:	74 05                	je     80072d <vprintfmt+0x43b>
  800728:	83 e8 01             	sub    $0x1,%eax
  80072b:	eb f5                	jmp    800722 <vprintfmt+0x430>
  80072d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800730:	eb 82                	jmp    8006b4 <vprintfmt+0x3c2>

00800732 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	83 ec 18             	sub    $0x18,%esp
  800738:	8b 45 08             	mov    0x8(%ebp),%eax
  80073b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800741:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800745:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800748:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074f:	85 c0                	test   %eax,%eax
  800751:	74 26                	je     800779 <vsnprintf+0x47>
  800753:	85 d2                	test   %edx,%edx
  800755:	7e 22                	jle    800779 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800757:	ff 75 14             	push   0x14(%ebp)
  80075a:	ff 75 10             	push   0x10(%ebp)
  80075d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800760:	50                   	push   %eax
  800761:	68 b8 02 80 00       	push   $0x8002b8
  800766:	e8 87 fb ff ff       	call   8002f2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800771:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800774:	83 c4 10             	add    $0x10,%esp
}
  800777:	c9                   	leave  
  800778:	c3                   	ret    
		return -E_INVAL;
  800779:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077e:	eb f7                	jmp    800777 <vsnprintf+0x45>

00800780 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800786:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800789:	50                   	push   %eax
  80078a:	ff 75 10             	push   0x10(%ebp)
  80078d:	ff 75 0c             	push   0xc(%ebp)
  800790:	ff 75 08             	push   0x8(%ebp)
  800793:	e8 9a ff ff ff       	call   800732 <vsnprintf>
	va_end(ap);

	return rc;
}
  800798:	c9                   	leave  
  800799:	c3                   	ret    

0080079a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80079a:	55                   	push   %ebp
  80079b:	89 e5                	mov    %esp,%ebp
  80079d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a5:	eb 03                	jmp    8007aa <strlen+0x10>
		n++;
  8007a7:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007aa:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ae:	75 f7                	jne    8007a7 <strlen+0xd>
	return n;
}
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c0:	eb 03                	jmp    8007c5 <strnlen+0x13>
		n++;
  8007c2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c5:	39 d0                	cmp    %edx,%eax
  8007c7:	74 08                	je     8007d1 <strnlen+0x1f>
  8007c9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007cd:	75 f3                	jne    8007c2 <strnlen+0x10>
  8007cf:	89 c2                	mov    %eax,%edx
	return n;
}
  8007d1:	89 d0                	mov    %edx,%eax
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	53                   	push   %ebx
  8007d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007df:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e4:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007e8:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007eb:	83 c0 01             	add    $0x1,%eax
  8007ee:	84 d2                	test   %dl,%dl
  8007f0:	75 f2                	jne    8007e4 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007f2:	89 c8                	mov    %ecx,%eax
  8007f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f7:	c9                   	leave  
  8007f8:	c3                   	ret    

008007f9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	53                   	push   %ebx
  8007fd:	83 ec 10             	sub    $0x10,%esp
  800800:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800803:	53                   	push   %ebx
  800804:	e8 91 ff ff ff       	call   80079a <strlen>
  800809:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80080c:	ff 75 0c             	push   0xc(%ebp)
  80080f:	01 d8                	add    %ebx,%eax
  800811:	50                   	push   %eax
  800812:	e8 be ff ff ff       	call   8007d5 <strcpy>
	return dst;
}
  800817:	89 d8                	mov    %ebx,%eax
  800819:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80081c:	c9                   	leave  
  80081d:	c3                   	ret    

0080081e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	56                   	push   %esi
  800822:	53                   	push   %ebx
  800823:	8b 75 08             	mov    0x8(%ebp),%esi
  800826:	8b 55 0c             	mov    0xc(%ebp),%edx
  800829:	89 f3                	mov    %esi,%ebx
  80082b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082e:	89 f0                	mov    %esi,%eax
  800830:	eb 0f                	jmp    800841 <strncpy+0x23>
		*dst++ = *src;
  800832:	83 c0 01             	add    $0x1,%eax
  800835:	0f b6 0a             	movzbl (%edx),%ecx
  800838:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80083b:	80 f9 01             	cmp    $0x1,%cl
  80083e:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800841:	39 d8                	cmp    %ebx,%eax
  800843:	75 ed                	jne    800832 <strncpy+0x14>
	}
	return ret;
}
  800845:	89 f0                	mov    %esi,%eax
  800847:	5b                   	pop    %ebx
  800848:	5e                   	pop    %esi
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	56                   	push   %esi
  80084f:	53                   	push   %ebx
  800850:	8b 75 08             	mov    0x8(%ebp),%esi
  800853:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800856:	8b 55 10             	mov    0x10(%ebp),%edx
  800859:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80085b:	85 d2                	test   %edx,%edx
  80085d:	74 21                	je     800880 <strlcpy+0x35>
  80085f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800863:	89 f2                	mov    %esi,%edx
  800865:	eb 09                	jmp    800870 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800867:	83 c1 01             	add    $0x1,%ecx
  80086a:	83 c2 01             	add    $0x1,%edx
  80086d:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800870:	39 c2                	cmp    %eax,%edx
  800872:	74 09                	je     80087d <strlcpy+0x32>
  800874:	0f b6 19             	movzbl (%ecx),%ebx
  800877:	84 db                	test   %bl,%bl
  800879:	75 ec                	jne    800867 <strlcpy+0x1c>
  80087b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80087d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800880:	29 f0                	sub    %esi,%eax
}
  800882:	5b                   	pop    %ebx
  800883:	5e                   	pop    %esi
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    

00800886 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088f:	eb 06                	jmp    800897 <strcmp+0x11>
		p++, q++;
  800891:	83 c1 01             	add    $0x1,%ecx
  800894:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800897:	0f b6 01             	movzbl (%ecx),%eax
  80089a:	84 c0                	test   %al,%al
  80089c:	74 04                	je     8008a2 <strcmp+0x1c>
  80089e:	3a 02                	cmp    (%edx),%al
  8008a0:	74 ef                	je     800891 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a2:	0f b6 c0             	movzbl %al,%eax
  8008a5:	0f b6 12             	movzbl (%edx),%edx
  8008a8:	29 d0                	sub    %edx,%eax
}
  8008aa:	5d                   	pop    %ebp
  8008ab:	c3                   	ret    

008008ac <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ac:	55                   	push   %ebp
  8008ad:	89 e5                	mov    %esp,%ebp
  8008af:	53                   	push   %ebx
  8008b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b6:	89 c3                	mov    %eax,%ebx
  8008b8:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008bb:	eb 06                	jmp    8008c3 <strncmp+0x17>
		n--, p++, q++;
  8008bd:	83 c0 01             	add    $0x1,%eax
  8008c0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008c3:	39 d8                	cmp    %ebx,%eax
  8008c5:	74 18                	je     8008df <strncmp+0x33>
  8008c7:	0f b6 08             	movzbl (%eax),%ecx
  8008ca:	84 c9                	test   %cl,%cl
  8008cc:	74 04                	je     8008d2 <strncmp+0x26>
  8008ce:	3a 0a                	cmp    (%edx),%cl
  8008d0:	74 eb                	je     8008bd <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d2:	0f b6 00             	movzbl (%eax),%eax
  8008d5:	0f b6 12             	movzbl (%edx),%edx
  8008d8:	29 d0                	sub    %edx,%eax
}
  8008da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008dd:	c9                   	leave  
  8008de:	c3                   	ret    
		return 0;
  8008df:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e4:	eb f4                	jmp    8008da <strncmp+0x2e>

008008e6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f0:	eb 03                	jmp    8008f5 <strchr+0xf>
  8008f2:	83 c0 01             	add    $0x1,%eax
  8008f5:	0f b6 10             	movzbl (%eax),%edx
  8008f8:	84 d2                	test   %dl,%dl
  8008fa:	74 06                	je     800902 <strchr+0x1c>
		if (*s == c)
  8008fc:	38 ca                	cmp    %cl,%dl
  8008fe:	75 f2                	jne    8008f2 <strchr+0xc>
  800900:	eb 05                	jmp    800907 <strchr+0x21>
			return (char *) s;
	return 0;
  800902:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	8b 45 08             	mov    0x8(%ebp),%eax
  80090f:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800913:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800916:	38 ca                	cmp    %cl,%dl
  800918:	74 09                	je     800923 <strfind+0x1a>
  80091a:	84 d2                	test   %dl,%dl
  80091c:	74 05                	je     800923 <strfind+0x1a>
	for (; *s; s++)
  80091e:	83 c0 01             	add    $0x1,%eax
  800921:	eb f0                	jmp    800913 <strfind+0xa>
			break;
	return (char *) s;
}
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	57                   	push   %edi
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800931:	85 c9                	test   %ecx,%ecx
  800933:	74 2f                	je     800964 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800935:	89 f8                	mov    %edi,%eax
  800937:	09 c8                	or     %ecx,%eax
  800939:	a8 03                	test   $0x3,%al
  80093b:	75 21                	jne    80095e <memset+0x39>
		c &= 0xFF;
  80093d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800941:	89 d0                	mov    %edx,%eax
  800943:	c1 e0 08             	shl    $0x8,%eax
  800946:	89 d3                	mov    %edx,%ebx
  800948:	c1 e3 18             	shl    $0x18,%ebx
  80094b:	89 d6                	mov    %edx,%esi
  80094d:	c1 e6 10             	shl    $0x10,%esi
  800950:	09 f3                	or     %esi,%ebx
  800952:	09 da                	or     %ebx,%edx
  800954:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800956:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800959:	fc                   	cld    
  80095a:	f3 ab                	rep stos %eax,%es:(%edi)
  80095c:	eb 06                	jmp    800964 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800961:	fc                   	cld    
  800962:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800964:	89 f8                	mov    %edi,%eax
  800966:	5b                   	pop    %ebx
  800967:	5e                   	pop    %esi
  800968:	5f                   	pop    %edi
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	57                   	push   %edi
  80096f:	56                   	push   %esi
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	8b 75 0c             	mov    0xc(%ebp),%esi
  800976:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800979:	39 c6                	cmp    %eax,%esi
  80097b:	73 32                	jae    8009af <memmove+0x44>
  80097d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800980:	39 c2                	cmp    %eax,%edx
  800982:	76 2b                	jbe    8009af <memmove+0x44>
		s += n;
		d += n;
  800984:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800987:	89 d6                	mov    %edx,%esi
  800989:	09 fe                	or     %edi,%esi
  80098b:	09 ce                	or     %ecx,%esi
  80098d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800993:	75 0e                	jne    8009a3 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800995:	83 ef 04             	sub    $0x4,%edi
  800998:	8d 72 fc             	lea    -0x4(%edx),%esi
  80099b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80099e:	fd                   	std    
  80099f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a1:	eb 09                	jmp    8009ac <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a3:	83 ef 01             	sub    $0x1,%edi
  8009a6:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009a9:	fd                   	std    
  8009aa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ac:	fc                   	cld    
  8009ad:	eb 1a                	jmp    8009c9 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009af:	89 f2                	mov    %esi,%edx
  8009b1:	09 c2                	or     %eax,%edx
  8009b3:	09 ca                	or     %ecx,%edx
  8009b5:	f6 c2 03             	test   $0x3,%dl
  8009b8:	75 0a                	jne    8009c4 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009ba:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009bd:	89 c7                	mov    %eax,%edi
  8009bf:	fc                   	cld    
  8009c0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009c2:	eb 05                	jmp    8009c9 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009c4:	89 c7                	mov    %eax,%edi
  8009c6:	fc                   	cld    
  8009c7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c9:	5e                   	pop    %esi
  8009ca:	5f                   	pop    %edi
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d3:	ff 75 10             	push   0x10(%ebp)
  8009d6:	ff 75 0c             	push   0xc(%ebp)
  8009d9:	ff 75 08             	push   0x8(%ebp)
  8009dc:	e8 8a ff ff ff       	call   80096b <memmove>
}
  8009e1:	c9                   	leave  
  8009e2:	c3                   	ret    

008009e3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	56                   	push   %esi
  8009e7:	53                   	push   %ebx
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ee:	89 c6                	mov    %eax,%esi
  8009f0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f3:	eb 06                	jmp    8009fb <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009f5:	83 c0 01             	add    $0x1,%eax
  8009f8:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009fb:	39 f0                	cmp    %esi,%eax
  8009fd:	74 14                	je     800a13 <memcmp+0x30>
		if (*s1 != *s2)
  8009ff:	0f b6 08             	movzbl (%eax),%ecx
  800a02:	0f b6 1a             	movzbl (%edx),%ebx
  800a05:	38 d9                	cmp    %bl,%cl
  800a07:	74 ec                	je     8009f5 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a09:	0f b6 c1             	movzbl %cl,%eax
  800a0c:	0f b6 db             	movzbl %bl,%ebx
  800a0f:	29 d8                	sub    %ebx,%eax
  800a11:	eb 05                	jmp    800a18 <memcmp+0x35>
	}

	return 0;
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a18:	5b                   	pop    %ebx
  800a19:	5e                   	pop    %esi
  800a1a:	5d                   	pop    %ebp
  800a1b:	c3                   	ret    

00800a1c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a1c:	55                   	push   %ebp
  800a1d:	89 e5                	mov    %esp,%ebp
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a25:	89 c2                	mov    %eax,%edx
  800a27:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a2a:	eb 03                	jmp    800a2f <memfind+0x13>
  800a2c:	83 c0 01             	add    $0x1,%eax
  800a2f:	39 d0                	cmp    %edx,%eax
  800a31:	73 04                	jae    800a37 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a33:	38 08                	cmp    %cl,(%eax)
  800a35:	75 f5                	jne    800a2c <memfind+0x10>
			break;
	return (void *) s;
}
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	57                   	push   %edi
  800a3d:	56                   	push   %esi
  800a3e:	53                   	push   %ebx
  800a3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a42:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a45:	eb 03                	jmp    800a4a <strtol+0x11>
		s++;
  800a47:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a4a:	0f b6 02             	movzbl (%edx),%eax
  800a4d:	3c 20                	cmp    $0x20,%al
  800a4f:	74 f6                	je     800a47 <strtol+0xe>
  800a51:	3c 09                	cmp    $0x9,%al
  800a53:	74 f2                	je     800a47 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a55:	3c 2b                	cmp    $0x2b,%al
  800a57:	74 2a                	je     800a83 <strtol+0x4a>
	int neg = 0;
  800a59:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a5e:	3c 2d                	cmp    $0x2d,%al
  800a60:	74 2b                	je     800a8d <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a62:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a68:	75 0f                	jne    800a79 <strtol+0x40>
  800a6a:	80 3a 30             	cmpb   $0x30,(%edx)
  800a6d:	74 28                	je     800a97 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a6f:	85 db                	test   %ebx,%ebx
  800a71:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a76:	0f 44 d8             	cmove  %eax,%ebx
  800a79:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a7e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a81:	eb 46                	jmp    800ac9 <strtol+0x90>
		s++;
  800a83:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a86:	bf 00 00 00 00       	mov    $0x0,%edi
  800a8b:	eb d5                	jmp    800a62 <strtol+0x29>
		s++, neg = 1;
  800a8d:	83 c2 01             	add    $0x1,%edx
  800a90:	bf 01 00 00 00       	mov    $0x1,%edi
  800a95:	eb cb                	jmp    800a62 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a97:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a9b:	74 0e                	je     800aab <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a9d:	85 db                	test   %ebx,%ebx
  800a9f:	75 d8                	jne    800a79 <strtol+0x40>
		s++, base = 8;
  800aa1:	83 c2 01             	add    $0x1,%edx
  800aa4:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aa9:	eb ce                	jmp    800a79 <strtol+0x40>
		s += 2, base = 16;
  800aab:	83 c2 02             	add    $0x2,%edx
  800aae:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab3:	eb c4                	jmp    800a79 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ab5:	0f be c0             	movsbl %al,%eax
  800ab8:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800abb:	3b 45 10             	cmp    0x10(%ebp),%eax
  800abe:	7d 3a                	jge    800afa <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ac0:	83 c2 01             	add    $0x1,%edx
  800ac3:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ac7:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ac9:	0f b6 02             	movzbl (%edx),%eax
  800acc:	8d 70 d0             	lea    -0x30(%eax),%esi
  800acf:	89 f3                	mov    %esi,%ebx
  800ad1:	80 fb 09             	cmp    $0x9,%bl
  800ad4:	76 df                	jbe    800ab5 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ad6:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ad9:	89 f3                	mov    %esi,%ebx
  800adb:	80 fb 19             	cmp    $0x19,%bl
  800ade:	77 08                	ja     800ae8 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ae0:	0f be c0             	movsbl %al,%eax
  800ae3:	83 e8 57             	sub    $0x57,%eax
  800ae6:	eb d3                	jmp    800abb <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800ae8:	8d 70 bf             	lea    -0x41(%eax),%esi
  800aeb:	89 f3                	mov    %esi,%ebx
  800aed:	80 fb 19             	cmp    $0x19,%bl
  800af0:	77 08                	ja     800afa <strtol+0xc1>
			dig = *s - 'A' + 10;
  800af2:	0f be c0             	movsbl %al,%eax
  800af5:	83 e8 37             	sub    $0x37,%eax
  800af8:	eb c1                	jmp    800abb <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800afa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afe:	74 05                	je     800b05 <strtol+0xcc>
		*endptr = (char *) s;
  800b00:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b03:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b05:	89 c8                	mov    %ecx,%eax
  800b07:	f7 d8                	neg    %eax
  800b09:	85 ff                	test   %edi,%edi
  800b0b:	0f 45 c8             	cmovne %eax,%ecx
}
  800b0e:	89 c8                	mov    %ecx,%eax
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5f                   	pop    %edi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	57                   	push   %edi
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b1b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b20:	8b 55 08             	mov    0x8(%ebp),%edx
  800b23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b26:	89 c3                	mov    %eax,%ebx
  800b28:	89 c7                	mov    %eax,%edi
  800b2a:	89 c6                	mov    %eax,%esi
  800b2c:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2e:	5b                   	pop    %ebx
  800b2f:	5e                   	pop    %esi
  800b30:	5f                   	pop    %edi
  800b31:	5d                   	pop    %ebp
  800b32:	c3                   	ret    

00800b33 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b33:	55                   	push   %ebp
  800b34:	89 e5                	mov    %esp,%ebp
  800b36:	57                   	push   %edi
  800b37:	56                   	push   %esi
  800b38:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b39:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b43:	89 d1                	mov    %edx,%ecx
  800b45:	89 d3                	mov    %edx,%ebx
  800b47:	89 d7                	mov    %edx,%edi
  800b49:	89 d6                	mov    %edx,%esi
  800b4b:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4d:	5b                   	pop    %ebx
  800b4e:	5e                   	pop    %esi
  800b4f:	5f                   	pop    %edi
  800b50:	5d                   	pop    %ebp
  800b51:	c3                   	ret    

00800b52 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
  800b58:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b60:	8b 55 08             	mov    0x8(%ebp),%edx
  800b63:	b8 03 00 00 00       	mov    $0x3,%eax
  800b68:	89 cb                	mov    %ecx,%ebx
  800b6a:	89 cf                	mov    %ecx,%edi
  800b6c:	89 ce                	mov    %ecx,%esi
  800b6e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b70:	85 c0                	test   %eax,%eax
  800b72:	7f 08                	jg     800b7c <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b74:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b77:	5b                   	pop    %ebx
  800b78:	5e                   	pop    %esi
  800b79:	5f                   	pop    %edi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7c:	83 ec 0c             	sub    $0xc,%esp
  800b7f:	50                   	push   %eax
  800b80:	6a 03                	push   $0x3
  800b82:	68 7f 29 80 00       	push   $0x80297f
  800b87:	6a 2a                	push   $0x2a
  800b89:	68 9c 29 80 00       	push   $0x80299c
  800b8e:	e8 22 17 00 00       	call   8022b5 <_panic>

00800b93 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	57                   	push   %edi
  800b97:	56                   	push   %esi
  800b98:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b99:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9e:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba3:	89 d1                	mov    %edx,%ecx
  800ba5:	89 d3                	mov    %edx,%ebx
  800ba7:	89 d7                	mov    %edx,%edi
  800ba9:	89 d6                	mov    %edx,%esi
  800bab:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bad:	5b                   	pop    %ebx
  800bae:	5e                   	pop    %esi
  800baf:	5f                   	pop    %edi
  800bb0:	5d                   	pop    %ebp
  800bb1:	c3                   	ret    

00800bb2 <sys_yield>:

void
sys_yield(void)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bbd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bc2:	89 d1                	mov    %edx,%ecx
  800bc4:	89 d3                	mov    %edx,%ebx
  800bc6:	89 d7                	mov    %edx,%edi
  800bc8:	89 d6                	mov    %edx,%esi
  800bca:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bcc:	5b                   	pop    %ebx
  800bcd:	5e                   	pop    %esi
  800bce:	5f                   	pop    %edi
  800bcf:	5d                   	pop    %ebp
  800bd0:	c3                   	ret    

00800bd1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bd1:	55                   	push   %ebp
  800bd2:	89 e5                	mov    %esp,%ebp
  800bd4:	57                   	push   %edi
  800bd5:	56                   	push   %esi
  800bd6:	53                   	push   %ebx
  800bd7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bda:	be 00 00 00 00       	mov    $0x0,%esi
  800bdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800be2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be5:	b8 04 00 00 00       	mov    $0x4,%eax
  800bea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bed:	89 f7                	mov    %esi,%edi
  800bef:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bf1:	85 c0                	test   %eax,%eax
  800bf3:	7f 08                	jg     800bfd <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf8:	5b                   	pop    %ebx
  800bf9:	5e                   	pop    %esi
  800bfa:	5f                   	pop    %edi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfd:	83 ec 0c             	sub    $0xc,%esp
  800c00:	50                   	push   %eax
  800c01:	6a 04                	push   $0x4
  800c03:	68 7f 29 80 00       	push   $0x80297f
  800c08:	6a 2a                	push   $0x2a
  800c0a:	68 9c 29 80 00       	push   $0x80299c
  800c0f:	e8 a1 16 00 00       	call   8022b5 <_panic>

00800c14 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c14:	55                   	push   %ebp
  800c15:	89 e5                	mov    %esp,%ebp
  800c17:	57                   	push   %edi
  800c18:	56                   	push   %esi
  800c19:	53                   	push   %ebx
  800c1a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800c20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c23:	b8 05 00 00 00       	mov    $0x5,%eax
  800c28:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c2b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c2e:	8b 75 18             	mov    0x18(%ebp),%esi
  800c31:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c33:	85 c0                	test   %eax,%eax
  800c35:	7f 08                	jg     800c3f <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3a:	5b                   	pop    %ebx
  800c3b:	5e                   	pop    %esi
  800c3c:	5f                   	pop    %edi
  800c3d:	5d                   	pop    %ebp
  800c3e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3f:	83 ec 0c             	sub    $0xc,%esp
  800c42:	50                   	push   %eax
  800c43:	6a 05                	push   $0x5
  800c45:	68 7f 29 80 00       	push   $0x80297f
  800c4a:	6a 2a                	push   $0x2a
  800c4c:	68 9c 29 80 00       	push   $0x80299c
  800c51:	e8 5f 16 00 00       	call   8022b5 <_panic>

00800c56 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
  800c5c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c6f:	89 df                	mov    %ebx,%edi
  800c71:	89 de                	mov    %ebx,%esi
  800c73:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c75:	85 c0                	test   %eax,%eax
  800c77:	7f 08                	jg     800c81 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7c:	5b                   	pop    %ebx
  800c7d:	5e                   	pop    %esi
  800c7e:	5f                   	pop    %edi
  800c7f:	5d                   	pop    %ebp
  800c80:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c81:	83 ec 0c             	sub    $0xc,%esp
  800c84:	50                   	push   %eax
  800c85:	6a 06                	push   $0x6
  800c87:	68 7f 29 80 00       	push   $0x80297f
  800c8c:	6a 2a                	push   $0x2a
  800c8e:	68 9c 29 80 00       	push   $0x80299c
  800c93:	e8 1d 16 00 00       	call   8022b5 <_panic>

00800c98 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c98:	55                   	push   %ebp
  800c99:	89 e5                	mov    %esp,%ebp
  800c9b:	57                   	push   %edi
  800c9c:	56                   	push   %esi
  800c9d:	53                   	push   %ebx
  800c9e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ca1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca6:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cac:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb1:	89 df                	mov    %ebx,%edi
  800cb3:	89 de                	mov    %ebx,%esi
  800cb5:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	7f 08                	jg     800cc3 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc3:	83 ec 0c             	sub    $0xc,%esp
  800cc6:	50                   	push   %eax
  800cc7:	6a 08                	push   $0x8
  800cc9:	68 7f 29 80 00       	push   $0x80297f
  800cce:	6a 2a                	push   $0x2a
  800cd0:	68 9c 29 80 00       	push   $0x80299c
  800cd5:	e8 db 15 00 00       	call   8022b5 <_panic>

00800cda <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cee:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf3:	89 df                	mov    %ebx,%edi
  800cf5:	89 de                	mov    %ebx,%esi
  800cf7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	7f 08                	jg     800d05 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cfd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d00:	5b                   	pop    %ebx
  800d01:	5e                   	pop    %esi
  800d02:	5f                   	pop    %edi
  800d03:	5d                   	pop    %ebp
  800d04:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d05:	83 ec 0c             	sub    $0xc,%esp
  800d08:	50                   	push   %eax
  800d09:	6a 09                	push   $0x9
  800d0b:	68 7f 29 80 00       	push   $0x80297f
  800d10:	6a 2a                	push   $0x2a
  800d12:	68 9c 29 80 00       	push   $0x80299c
  800d17:	e8 99 15 00 00       	call   8022b5 <_panic>

00800d1c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d1c:	55                   	push   %ebp
  800d1d:	89 e5                	mov    %esp,%ebp
  800d1f:	57                   	push   %edi
  800d20:	56                   	push   %esi
  800d21:	53                   	push   %ebx
  800d22:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d30:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d35:	89 df                	mov    %ebx,%edi
  800d37:	89 de                	mov    %ebx,%esi
  800d39:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	7f 08                	jg     800d47 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d42:	5b                   	pop    %ebx
  800d43:	5e                   	pop    %esi
  800d44:	5f                   	pop    %edi
  800d45:	5d                   	pop    %ebp
  800d46:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d47:	83 ec 0c             	sub    $0xc,%esp
  800d4a:	50                   	push   %eax
  800d4b:	6a 0a                	push   $0xa
  800d4d:	68 7f 29 80 00       	push   $0x80297f
  800d52:	6a 2a                	push   $0x2a
  800d54:	68 9c 29 80 00       	push   $0x80299c
  800d59:	e8 57 15 00 00       	call   8022b5 <_panic>

00800d5e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d6f:	be 00 00 00 00       	mov    $0x0,%esi
  800d74:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d77:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d7a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d7c:	5b                   	pop    %ebx
  800d7d:	5e                   	pop    %esi
  800d7e:	5f                   	pop    %edi
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	57                   	push   %edi
  800d85:	56                   	push   %esi
  800d86:	53                   	push   %ebx
  800d87:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d92:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d97:	89 cb                	mov    %ecx,%ebx
  800d99:	89 cf                	mov    %ecx,%edi
  800d9b:	89 ce                	mov    %ecx,%esi
  800d9d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d9f:	85 c0                	test   %eax,%eax
  800da1:	7f 08                	jg     800dab <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da6:	5b                   	pop    %ebx
  800da7:	5e                   	pop    %esi
  800da8:	5f                   	pop    %edi
  800da9:	5d                   	pop    %ebp
  800daa:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dab:	83 ec 0c             	sub    $0xc,%esp
  800dae:	50                   	push   %eax
  800daf:	6a 0d                	push   $0xd
  800db1:	68 7f 29 80 00       	push   $0x80297f
  800db6:	6a 2a                	push   $0x2a
  800db8:	68 9c 29 80 00       	push   $0x80299c
  800dbd:	e8 f3 14 00 00       	call   8022b5 <_panic>

00800dc2 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	57                   	push   %edi
  800dc6:	56                   	push   %esi
  800dc7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dcd:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dd2:	89 d1                	mov    %edx,%ecx
  800dd4:	89 d3                	mov    %edx,%ebx
  800dd6:	89 d7                	mov    %edx,%edi
  800dd8:	89 d6                	mov    %edx,%esi
  800dda:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ddc:	5b                   	pop    %ebx
  800ddd:	5e                   	pop    %esi
  800dde:	5f                   	pop    %edi
  800ddf:	5d                   	pop    %ebp
  800de0:	c3                   	ret    

00800de1 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	57                   	push   %edi
  800de5:	56                   	push   %esi
  800de6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800de7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dec:	8b 55 08             	mov    0x8(%ebp),%edx
  800def:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df2:	b8 0f 00 00 00       	mov    $0xf,%eax
  800df7:	89 df                	mov    %ebx,%edi
  800df9:	89 de                	mov    %ebx,%esi
  800dfb:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800dfd:	5b                   	pop    %ebx
  800dfe:	5e                   	pop    %esi
  800dff:	5f                   	pop    %edi
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	57                   	push   %edi
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e13:	b8 10 00 00 00       	mov    $0x10,%eax
  800e18:	89 df                	mov    %ebx,%edi
  800e1a:	89 de                	mov    %ebx,%esi
  800e1c:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800e1e:	5b                   	pop    %ebx
  800e1f:	5e                   	pop    %esi
  800e20:	5f                   	pop    %edi
  800e21:	5d                   	pop    %ebp
  800e22:	c3                   	ret    

00800e23 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e23:	55                   	push   %ebp
  800e24:	89 e5                	mov    %esp,%ebp
  800e26:	56                   	push   %esi
  800e27:	53                   	push   %ebx
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e2b:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e2d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e31:	0f 84 8e 00 00 00    	je     800ec5 <pgfault+0xa2>
  800e37:	89 f0                	mov    %esi,%eax
  800e39:	c1 e8 0c             	shr    $0xc,%eax
  800e3c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e43:	f6 c4 08             	test   $0x8,%ah
  800e46:	74 7d                	je     800ec5 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800e48:	e8 46 fd ff ff       	call   800b93 <sys_getenvid>
  800e4d:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800e4f:	83 ec 04             	sub    $0x4,%esp
  800e52:	6a 07                	push   $0x7
  800e54:	68 00 f0 7f 00       	push   $0x7ff000
  800e59:	50                   	push   %eax
  800e5a:	e8 72 fd ff ff       	call   800bd1 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e5f:	83 c4 10             	add    $0x10,%esp
  800e62:	85 c0                	test   %eax,%eax
  800e64:	78 73                	js     800ed9 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800e66:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800e6c:	83 ec 04             	sub    $0x4,%esp
  800e6f:	68 00 10 00 00       	push   $0x1000
  800e74:	56                   	push   %esi
  800e75:	68 00 f0 7f 00       	push   $0x7ff000
  800e7a:	e8 ec fa ff ff       	call   80096b <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800e7f:	83 c4 08             	add    $0x8,%esp
  800e82:	56                   	push   %esi
  800e83:	53                   	push   %ebx
  800e84:	e8 cd fd ff ff       	call   800c56 <sys_page_unmap>
  800e89:	83 c4 10             	add    $0x10,%esp
  800e8c:	85 c0                	test   %eax,%eax
  800e8e:	78 5b                	js     800eeb <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800e90:	83 ec 0c             	sub    $0xc,%esp
  800e93:	6a 07                	push   $0x7
  800e95:	56                   	push   %esi
  800e96:	53                   	push   %ebx
  800e97:	68 00 f0 7f 00       	push   $0x7ff000
  800e9c:	53                   	push   %ebx
  800e9d:	e8 72 fd ff ff       	call   800c14 <sys_page_map>
  800ea2:	83 c4 20             	add    $0x20,%esp
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	78 54                	js     800efd <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800ea9:	83 ec 08             	sub    $0x8,%esp
  800eac:	68 00 f0 7f 00       	push   $0x7ff000
  800eb1:	53                   	push   %ebx
  800eb2:	e8 9f fd ff ff       	call   800c56 <sys_page_unmap>
  800eb7:	83 c4 10             	add    $0x10,%esp
  800eba:	85 c0                	test   %eax,%eax
  800ebc:	78 51                	js     800f0f <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800ebe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ec1:	5b                   	pop    %ebx
  800ec2:	5e                   	pop    %esi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800ec5:	83 ec 04             	sub    $0x4,%esp
  800ec8:	68 ac 29 80 00       	push   $0x8029ac
  800ecd:	6a 1d                	push   $0x1d
  800ecf:	68 28 2a 80 00       	push   $0x802a28
  800ed4:	e8 dc 13 00 00       	call   8022b5 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800ed9:	50                   	push   %eax
  800eda:	68 e4 29 80 00       	push   $0x8029e4
  800edf:	6a 29                	push   $0x29
  800ee1:	68 28 2a 80 00       	push   $0x802a28
  800ee6:	e8 ca 13 00 00       	call   8022b5 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800eeb:	50                   	push   %eax
  800eec:	68 08 2a 80 00       	push   $0x802a08
  800ef1:	6a 2e                	push   $0x2e
  800ef3:	68 28 2a 80 00       	push   $0x802a28
  800ef8:	e8 b8 13 00 00       	call   8022b5 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800efd:	50                   	push   %eax
  800efe:	68 33 2a 80 00       	push   $0x802a33
  800f03:	6a 30                	push   $0x30
  800f05:	68 28 2a 80 00       	push   $0x802a28
  800f0a:	e8 a6 13 00 00       	call   8022b5 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800f0f:	50                   	push   %eax
  800f10:	68 08 2a 80 00       	push   $0x802a08
  800f15:	6a 32                	push   $0x32
  800f17:	68 28 2a 80 00       	push   $0x802a28
  800f1c:	e8 94 13 00 00       	call   8022b5 <_panic>

00800f21 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	57                   	push   %edi
  800f25:	56                   	push   %esi
  800f26:	53                   	push   %ebx
  800f27:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800f2a:	68 23 0e 80 00       	push   $0x800e23
  800f2f:	e8 c7 13 00 00       	call   8022fb <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f34:	b8 07 00 00 00       	mov    $0x7,%eax
  800f39:	cd 30                	int    $0x30
  800f3b:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800f3e:	83 c4 10             	add    $0x10,%esp
  800f41:	85 c0                	test   %eax,%eax
  800f43:	78 30                	js     800f75 <fork+0x54>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f45:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800f4a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f4e:	75 76                	jne    800fc6 <fork+0xa5>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f50:	e8 3e fc ff ff       	call   800b93 <sys_getenvid>
  800f55:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f5a:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800f60:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f65:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f6a:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800f6d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f70:	5b                   	pop    %ebx
  800f71:	5e                   	pop    %esi
  800f72:	5f                   	pop    %edi
  800f73:	5d                   	pop    %ebp
  800f74:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  800f75:	50                   	push   %eax
  800f76:	68 51 2a 80 00       	push   $0x802a51
  800f7b:	6a 78                	push   $0x78
  800f7d:	68 28 2a 80 00       	push   $0x802a28
  800f82:	e8 2e 13 00 00       	call   8022b5 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  800f87:	83 ec 0c             	sub    $0xc,%esp
  800f8a:	ff 75 e4             	push   -0x1c(%ebp)
  800f8d:	57                   	push   %edi
  800f8e:	ff 75 dc             	push   -0x24(%ebp)
  800f91:	57                   	push   %edi
  800f92:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800f95:	56                   	push   %esi
  800f96:	e8 79 fc ff ff       	call   800c14 <sys_page_map>
	if(r<0) return r;
  800f9b:	83 c4 20             	add    $0x20,%esp
  800f9e:	85 c0                	test   %eax,%eax
  800fa0:	78 cb                	js     800f6d <fork+0x4c>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  800fa2:	83 ec 0c             	sub    $0xc,%esp
  800fa5:	ff 75 e4             	push   -0x1c(%ebp)
  800fa8:	57                   	push   %edi
  800fa9:	56                   	push   %esi
  800faa:	57                   	push   %edi
  800fab:	56                   	push   %esi
  800fac:	e8 63 fc ff ff       	call   800c14 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800fb1:	83 c4 20             	add    $0x20,%esp
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	78 76                	js     80102e <fork+0x10d>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800fb8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fbe:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fc4:	74 75                	je     80103b <fork+0x11a>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800fc6:	89 d8                	mov    %ebx,%eax
  800fc8:	c1 e8 16             	shr    $0x16,%eax
  800fcb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd2:	a8 01                	test   $0x1,%al
  800fd4:	74 e2                	je     800fb8 <fork+0x97>
  800fd6:	89 de                	mov    %ebx,%esi
  800fd8:	c1 ee 0c             	shr    $0xc,%esi
  800fdb:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fe2:	a8 01                	test   $0x1,%al
  800fe4:	74 d2                	je     800fb8 <fork+0x97>
	envid_t this_envid = sys_getenvid();//父进程号
  800fe6:	e8 a8 fb ff ff       	call   800b93 <sys_getenvid>
  800feb:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  800fee:	89 f7                	mov    %esi,%edi
  800ff0:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  800ff3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ffa:	89 c1                	mov    %eax,%ecx
  800ffc:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801002:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  801005:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  80100c:	f6 c6 04             	test   $0x4,%dh
  80100f:	0f 85 72 ff ff ff    	jne    800f87 <fork+0x66>
		perm &= ~PTE_W;
  801015:	25 05 0e 00 00       	and    $0xe05,%eax
  80101a:	80 cc 08             	or     $0x8,%ah
  80101d:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  801023:	0f 44 c1             	cmove  %ecx,%eax
  801026:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801029:	e9 59 ff ff ff       	jmp    800f87 <fork+0x66>
  80102e:	ba 00 00 00 00       	mov    $0x0,%edx
  801033:	0f 4f c2             	cmovg  %edx,%eax
  801036:	e9 32 ff ff ff       	jmp    800f6d <fork+0x4c>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  80103b:	83 ec 04             	sub    $0x4,%esp
  80103e:	6a 07                	push   $0x7
  801040:	68 00 f0 bf ee       	push   $0xeebff000
  801045:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801048:	57                   	push   %edi
  801049:	e8 83 fb ff ff       	call   800bd1 <sys_page_alloc>
	if(r<0) return r;
  80104e:	83 c4 10             	add    $0x10,%esp
  801051:	85 c0                	test   %eax,%eax
  801053:	0f 88 14 ff ff ff    	js     800f6d <fork+0x4c>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801059:	83 ec 08             	sub    $0x8,%esp
  80105c:	68 71 23 80 00       	push   $0x802371
  801061:	57                   	push   %edi
  801062:	e8 b5 fc ff ff       	call   800d1c <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801067:	83 c4 10             	add    $0x10,%esp
  80106a:	85 c0                	test   %eax,%eax
  80106c:	0f 88 fb fe ff ff    	js     800f6d <fork+0x4c>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801072:	83 ec 08             	sub    $0x8,%esp
  801075:	6a 02                	push   $0x2
  801077:	57                   	push   %edi
  801078:	e8 1b fc ff ff       	call   800c98 <sys_env_set_status>
	if(r<0) return r;
  80107d:	83 c4 10             	add    $0x10,%esp
	return envid;
  801080:	85 c0                	test   %eax,%eax
  801082:	0f 49 c7             	cmovns %edi,%eax
  801085:	e9 e3 fe ff ff       	jmp    800f6d <fork+0x4c>

0080108a <sfork>:

// Challenge!
int
sfork(void)
{
  80108a:	55                   	push   %ebp
  80108b:	89 e5                	mov    %esp,%ebp
  80108d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801090:	68 61 2a 80 00       	push   $0x802a61
  801095:	68 a1 00 00 00       	push   $0xa1
  80109a:	68 28 2a 80 00       	push   $0x802a28
  80109f:	e8 11 12 00 00       	call   8022b5 <_panic>

008010a4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	56                   	push   %esi
  8010a8:	53                   	push   %ebx
  8010a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8010ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010af:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8010b2:	85 c0                	test   %eax,%eax
  8010b4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8010b9:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8010bc:	83 ec 0c             	sub    $0xc,%esp
  8010bf:	50                   	push   %eax
  8010c0:	e8 bc fc ff ff       	call   800d81 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8010c5:	83 c4 10             	add    $0x10,%esp
  8010c8:	85 f6                	test   %esi,%esi
  8010ca:	74 17                	je     8010e3 <ipc_recv+0x3f>
  8010cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d1:	85 c0                	test   %eax,%eax
  8010d3:	78 0c                	js     8010e1 <ipc_recv+0x3d>
  8010d5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8010db:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  8010e1:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8010e3:	85 db                	test   %ebx,%ebx
  8010e5:	74 17                	je     8010fe <ipc_recv+0x5a>
  8010e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ec:	85 c0                	test   %eax,%eax
  8010ee:	78 0c                	js     8010fc <ipc_recv+0x58>
  8010f0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8010f6:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  8010fc:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8010fe:	85 c0                	test   %eax,%eax
  801100:	78 0b                	js     80110d <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801102:	a1 04 40 80 00       	mov    0x804004,%eax
  801107:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  80110d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801110:	5b                   	pop    %ebx
  801111:	5e                   	pop    %esi
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	57                   	push   %edi
  801118:	56                   	push   %esi
  801119:	53                   	push   %ebx
  80111a:	83 ec 0c             	sub    $0xc,%esp
  80111d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801120:	8b 75 0c             	mov    0xc(%ebp),%esi
  801123:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801126:	85 db                	test   %ebx,%ebx
  801128:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80112d:	0f 44 d8             	cmove  %eax,%ebx
  801130:	eb 05                	jmp    801137 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801132:	e8 7b fa ff ff       	call   800bb2 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801137:	ff 75 14             	push   0x14(%ebp)
  80113a:	53                   	push   %ebx
  80113b:	56                   	push   %esi
  80113c:	57                   	push   %edi
  80113d:	e8 1c fc ff ff       	call   800d5e <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801142:	83 c4 10             	add    $0x10,%esp
  801145:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801148:	74 e8                	je     801132 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80114a:	85 c0                	test   %eax,%eax
  80114c:	78 08                	js     801156 <ipc_send+0x42>
	}while (r<0);

}
  80114e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801151:	5b                   	pop    %ebx
  801152:	5e                   	pop    %esi
  801153:	5f                   	pop    %edi
  801154:	5d                   	pop    %ebp
  801155:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801156:	50                   	push   %eax
  801157:	68 77 2a 80 00       	push   $0x802a77
  80115c:	6a 3d                	push   $0x3d
  80115e:	68 8b 2a 80 00       	push   $0x802a8b
  801163:	e8 4d 11 00 00       	call   8022b5 <_panic>

00801168 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80116e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801173:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  801179:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80117f:	8b 52 60             	mov    0x60(%edx),%edx
  801182:	39 ca                	cmp    %ecx,%edx
  801184:	74 11                	je     801197 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  801186:	83 c0 01             	add    $0x1,%eax
  801189:	3d 00 04 00 00       	cmp    $0x400,%eax
  80118e:	75 e3                	jne    801173 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801190:	b8 00 00 00 00       	mov    $0x0,%eax
  801195:	eb 0e                	jmp    8011a5 <ipc_find_env+0x3d>
			return envs[i].env_id;
  801197:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80119d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011a2:	8b 40 58             	mov    0x58(%eax),%eax
}
  8011a5:	5d                   	pop    %ebp
  8011a6:	c3                   	ret    

008011a7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ad:	05 00 00 00 30       	add    $0x30000000,%eax
  8011b2:	c1 e8 0c             	shr    $0xc,%eax
}
  8011b5:	5d                   	pop    %ebp
  8011b6:	c3                   	ret    

008011b7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011b7:	55                   	push   %ebp
  8011b8:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8011bd:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011c2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011c7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011d6:	89 c2                	mov    %eax,%edx
  8011d8:	c1 ea 16             	shr    $0x16,%edx
  8011db:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011e2:	f6 c2 01             	test   $0x1,%dl
  8011e5:	74 29                	je     801210 <fd_alloc+0x42>
  8011e7:	89 c2                	mov    %eax,%edx
  8011e9:	c1 ea 0c             	shr    $0xc,%edx
  8011ec:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011f3:	f6 c2 01             	test   $0x1,%dl
  8011f6:	74 18                	je     801210 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8011f8:	05 00 10 00 00       	add    $0x1000,%eax
  8011fd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801202:	75 d2                	jne    8011d6 <fd_alloc+0x8>
  801204:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801209:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80120e:	eb 05                	jmp    801215 <fd_alloc+0x47>
			return 0;
  801210:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801215:	8b 55 08             	mov    0x8(%ebp),%edx
  801218:	89 02                	mov    %eax,(%edx)
}
  80121a:	89 c8                	mov    %ecx,%eax
  80121c:	5d                   	pop    %ebp
  80121d:	c3                   	ret    

0080121e <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801224:	83 f8 1f             	cmp    $0x1f,%eax
  801227:	77 30                	ja     801259 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801229:	c1 e0 0c             	shl    $0xc,%eax
  80122c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801231:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801237:	f6 c2 01             	test   $0x1,%dl
  80123a:	74 24                	je     801260 <fd_lookup+0x42>
  80123c:	89 c2                	mov    %eax,%edx
  80123e:	c1 ea 0c             	shr    $0xc,%edx
  801241:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801248:	f6 c2 01             	test   $0x1,%dl
  80124b:	74 1a                	je     801267 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80124d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801250:	89 02                	mov    %eax,(%edx)
	return 0;
  801252:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801257:	5d                   	pop    %ebp
  801258:	c3                   	ret    
		return -E_INVAL;
  801259:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80125e:	eb f7                	jmp    801257 <fd_lookup+0x39>
		return -E_INVAL;
  801260:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801265:	eb f0                	jmp    801257 <fd_lookup+0x39>
  801267:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80126c:	eb e9                	jmp    801257 <fd_lookup+0x39>

0080126e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	53                   	push   %ebx
  801272:	83 ec 04             	sub    $0x4,%esp
  801275:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801278:	b8 00 00 00 00       	mov    $0x0,%eax
  80127d:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801282:	39 13                	cmp    %edx,(%ebx)
  801284:	74 37                	je     8012bd <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  801286:	83 c0 01             	add    $0x1,%eax
  801289:	8b 1c 85 14 2b 80 00 	mov    0x802b14(,%eax,4),%ebx
  801290:	85 db                	test   %ebx,%ebx
  801292:	75 ee                	jne    801282 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801294:	a1 04 40 80 00       	mov    0x804004,%eax
  801299:	8b 40 58             	mov    0x58(%eax),%eax
  80129c:	83 ec 04             	sub    $0x4,%esp
  80129f:	52                   	push   %edx
  8012a0:	50                   	push   %eax
  8012a1:	68 98 2a 80 00       	push   $0x802a98
  8012a6:	e8 50 ef ff ff       	call   8001fb <cprintf>
	*dev = 0;
	return -E_INVAL;
  8012ab:	83 c4 10             	add    $0x10,%esp
  8012ae:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8012b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012b6:	89 1a                	mov    %ebx,(%edx)
}
  8012b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bb:	c9                   	leave  
  8012bc:	c3                   	ret    
			return 0;
  8012bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c2:	eb ef                	jmp    8012b3 <dev_lookup+0x45>

008012c4 <fd_close>:
{
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	57                   	push   %edi
  8012c8:	56                   	push   %esi
  8012c9:	53                   	push   %ebx
  8012ca:	83 ec 24             	sub    $0x24,%esp
  8012cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8012d0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012d3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012d6:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012d7:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012dd:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012e0:	50                   	push   %eax
  8012e1:	e8 38 ff ff ff       	call   80121e <fd_lookup>
  8012e6:	89 c3                	mov    %eax,%ebx
  8012e8:	83 c4 10             	add    $0x10,%esp
  8012eb:	85 c0                	test   %eax,%eax
  8012ed:	78 05                	js     8012f4 <fd_close+0x30>
	    || fd != fd2)
  8012ef:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8012f2:	74 16                	je     80130a <fd_close+0x46>
		return (must_exist ? r : 0);
  8012f4:	89 f8                	mov    %edi,%eax
  8012f6:	84 c0                	test   %al,%al
  8012f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012fd:	0f 44 d8             	cmove  %eax,%ebx
}
  801300:	89 d8                	mov    %ebx,%eax
  801302:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801305:	5b                   	pop    %ebx
  801306:	5e                   	pop    %esi
  801307:	5f                   	pop    %edi
  801308:	5d                   	pop    %ebp
  801309:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80130a:	83 ec 08             	sub    $0x8,%esp
  80130d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801310:	50                   	push   %eax
  801311:	ff 36                	push   (%esi)
  801313:	e8 56 ff ff ff       	call   80126e <dev_lookup>
  801318:	89 c3                	mov    %eax,%ebx
  80131a:	83 c4 10             	add    $0x10,%esp
  80131d:	85 c0                	test   %eax,%eax
  80131f:	78 1a                	js     80133b <fd_close+0x77>
		if (dev->dev_close)
  801321:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801324:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801327:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80132c:	85 c0                	test   %eax,%eax
  80132e:	74 0b                	je     80133b <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801330:	83 ec 0c             	sub    $0xc,%esp
  801333:	56                   	push   %esi
  801334:	ff d0                	call   *%eax
  801336:	89 c3                	mov    %eax,%ebx
  801338:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80133b:	83 ec 08             	sub    $0x8,%esp
  80133e:	56                   	push   %esi
  80133f:	6a 00                	push   $0x0
  801341:	e8 10 f9 ff ff       	call   800c56 <sys_page_unmap>
	return r;
  801346:	83 c4 10             	add    $0x10,%esp
  801349:	eb b5                	jmp    801300 <fd_close+0x3c>

0080134b <close>:

int
close(int fdnum)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801351:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801354:	50                   	push   %eax
  801355:	ff 75 08             	push   0x8(%ebp)
  801358:	e8 c1 fe ff ff       	call   80121e <fd_lookup>
  80135d:	83 c4 10             	add    $0x10,%esp
  801360:	85 c0                	test   %eax,%eax
  801362:	79 02                	jns    801366 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801364:	c9                   	leave  
  801365:	c3                   	ret    
		return fd_close(fd, 1);
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	6a 01                	push   $0x1
  80136b:	ff 75 f4             	push   -0xc(%ebp)
  80136e:	e8 51 ff ff ff       	call   8012c4 <fd_close>
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	eb ec                	jmp    801364 <close+0x19>

00801378 <close_all>:

void
close_all(void)
{
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	53                   	push   %ebx
  80137c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80137f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801384:	83 ec 0c             	sub    $0xc,%esp
  801387:	53                   	push   %ebx
  801388:	e8 be ff ff ff       	call   80134b <close>
	for (i = 0; i < MAXFD; i++)
  80138d:	83 c3 01             	add    $0x1,%ebx
  801390:	83 c4 10             	add    $0x10,%esp
  801393:	83 fb 20             	cmp    $0x20,%ebx
  801396:	75 ec                	jne    801384 <close_all+0xc>
}
  801398:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80139b:	c9                   	leave  
  80139c:	c3                   	ret    

0080139d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80139d:	55                   	push   %ebp
  80139e:	89 e5                	mov    %esp,%ebp
  8013a0:	57                   	push   %edi
  8013a1:	56                   	push   %esi
  8013a2:	53                   	push   %ebx
  8013a3:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8013a6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8013a9:	50                   	push   %eax
  8013aa:	ff 75 08             	push   0x8(%ebp)
  8013ad:	e8 6c fe ff ff       	call   80121e <fd_lookup>
  8013b2:	89 c3                	mov    %eax,%ebx
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	78 7f                	js     80143a <dup+0x9d>
		return r;
	close(newfdnum);
  8013bb:	83 ec 0c             	sub    $0xc,%esp
  8013be:	ff 75 0c             	push   0xc(%ebp)
  8013c1:	e8 85 ff ff ff       	call   80134b <close>

	newfd = INDEX2FD(newfdnum);
  8013c6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013c9:	c1 e6 0c             	shl    $0xc,%esi
  8013cc:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013d5:	89 3c 24             	mov    %edi,(%esp)
  8013d8:	e8 da fd ff ff       	call   8011b7 <fd2data>
  8013dd:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013df:	89 34 24             	mov    %esi,(%esp)
  8013e2:	e8 d0 fd ff ff       	call   8011b7 <fd2data>
  8013e7:	83 c4 10             	add    $0x10,%esp
  8013ea:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013ed:	89 d8                	mov    %ebx,%eax
  8013ef:	c1 e8 16             	shr    $0x16,%eax
  8013f2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013f9:	a8 01                	test   $0x1,%al
  8013fb:	74 11                	je     80140e <dup+0x71>
  8013fd:	89 d8                	mov    %ebx,%eax
  8013ff:	c1 e8 0c             	shr    $0xc,%eax
  801402:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801409:	f6 c2 01             	test   $0x1,%dl
  80140c:	75 36                	jne    801444 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80140e:	89 f8                	mov    %edi,%eax
  801410:	c1 e8 0c             	shr    $0xc,%eax
  801413:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80141a:	83 ec 0c             	sub    $0xc,%esp
  80141d:	25 07 0e 00 00       	and    $0xe07,%eax
  801422:	50                   	push   %eax
  801423:	56                   	push   %esi
  801424:	6a 00                	push   $0x0
  801426:	57                   	push   %edi
  801427:	6a 00                	push   $0x0
  801429:	e8 e6 f7 ff ff       	call   800c14 <sys_page_map>
  80142e:	89 c3                	mov    %eax,%ebx
  801430:	83 c4 20             	add    $0x20,%esp
  801433:	85 c0                	test   %eax,%eax
  801435:	78 33                	js     80146a <dup+0xcd>
		goto err;

	return newfdnum;
  801437:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80143a:	89 d8                	mov    %ebx,%eax
  80143c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80143f:	5b                   	pop    %ebx
  801440:	5e                   	pop    %esi
  801441:	5f                   	pop    %edi
  801442:	5d                   	pop    %ebp
  801443:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801444:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80144b:	83 ec 0c             	sub    $0xc,%esp
  80144e:	25 07 0e 00 00       	and    $0xe07,%eax
  801453:	50                   	push   %eax
  801454:	ff 75 d4             	push   -0x2c(%ebp)
  801457:	6a 00                	push   $0x0
  801459:	53                   	push   %ebx
  80145a:	6a 00                	push   $0x0
  80145c:	e8 b3 f7 ff ff       	call   800c14 <sys_page_map>
  801461:	89 c3                	mov    %eax,%ebx
  801463:	83 c4 20             	add    $0x20,%esp
  801466:	85 c0                	test   %eax,%eax
  801468:	79 a4                	jns    80140e <dup+0x71>
	sys_page_unmap(0, newfd);
  80146a:	83 ec 08             	sub    $0x8,%esp
  80146d:	56                   	push   %esi
  80146e:	6a 00                	push   $0x0
  801470:	e8 e1 f7 ff ff       	call   800c56 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801475:	83 c4 08             	add    $0x8,%esp
  801478:	ff 75 d4             	push   -0x2c(%ebp)
  80147b:	6a 00                	push   $0x0
  80147d:	e8 d4 f7 ff ff       	call   800c56 <sys_page_unmap>
	return r;
  801482:	83 c4 10             	add    $0x10,%esp
  801485:	eb b3                	jmp    80143a <dup+0x9d>

00801487 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801487:	55                   	push   %ebp
  801488:	89 e5                	mov    %esp,%ebp
  80148a:	56                   	push   %esi
  80148b:	53                   	push   %ebx
  80148c:	83 ec 18             	sub    $0x18,%esp
  80148f:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801492:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801495:	50                   	push   %eax
  801496:	56                   	push   %esi
  801497:	e8 82 fd ff ff       	call   80121e <fd_lookup>
  80149c:	83 c4 10             	add    $0x10,%esp
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	78 3c                	js     8014df <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a3:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8014a6:	83 ec 08             	sub    $0x8,%esp
  8014a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ac:	50                   	push   %eax
  8014ad:	ff 33                	push   (%ebx)
  8014af:	e8 ba fd ff ff       	call   80126e <dev_lookup>
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	78 24                	js     8014df <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014bb:	8b 43 08             	mov    0x8(%ebx),%eax
  8014be:	83 e0 03             	and    $0x3,%eax
  8014c1:	83 f8 01             	cmp    $0x1,%eax
  8014c4:	74 20                	je     8014e6 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c9:	8b 40 08             	mov    0x8(%eax),%eax
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	74 37                	je     801507 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014d0:	83 ec 04             	sub    $0x4,%esp
  8014d3:	ff 75 10             	push   0x10(%ebp)
  8014d6:	ff 75 0c             	push   0xc(%ebp)
  8014d9:	53                   	push   %ebx
  8014da:	ff d0                	call   *%eax
  8014dc:	83 c4 10             	add    $0x10,%esp
}
  8014df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014e2:	5b                   	pop    %ebx
  8014e3:	5e                   	pop    %esi
  8014e4:	5d                   	pop    %ebp
  8014e5:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014e6:	a1 04 40 80 00       	mov    0x804004,%eax
  8014eb:	8b 40 58             	mov    0x58(%eax),%eax
  8014ee:	83 ec 04             	sub    $0x4,%esp
  8014f1:	56                   	push   %esi
  8014f2:	50                   	push   %eax
  8014f3:	68 d9 2a 80 00       	push   $0x802ad9
  8014f8:	e8 fe ec ff ff       	call   8001fb <cprintf>
		return -E_INVAL;
  8014fd:	83 c4 10             	add    $0x10,%esp
  801500:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801505:	eb d8                	jmp    8014df <read+0x58>
		return -E_NOT_SUPP;
  801507:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80150c:	eb d1                	jmp    8014df <read+0x58>

0080150e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80150e:	55                   	push   %ebp
  80150f:	89 e5                	mov    %esp,%ebp
  801511:	57                   	push   %edi
  801512:	56                   	push   %esi
  801513:	53                   	push   %ebx
  801514:	83 ec 0c             	sub    $0xc,%esp
  801517:	8b 7d 08             	mov    0x8(%ebp),%edi
  80151a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80151d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801522:	eb 02                	jmp    801526 <readn+0x18>
  801524:	01 c3                	add    %eax,%ebx
  801526:	39 f3                	cmp    %esi,%ebx
  801528:	73 21                	jae    80154b <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80152a:	83 ec 04             	sub    $0x4,%esp
  80152d:	89 f0                	mov    %esi,%eax
  80152f:	29 d8                	sub    %ebx,%eax
  801531:	50                   	push   %eax
  801532:	89 d8                	mov    %ebx,%eax
  801534:	03 45 0c             	add    0xc(%ebp),%eax
  801537:	50                   	push   %eax
  801538:	57                   	push   %edi
  801539:	e8 49 ff ff ff       	call   801487 <read>
		if (m < 0)
  80153e:	83 c4 10             	add    $0x10,%esp
  801541:	85 c0                	test   %eax,%eax
  801543:	78 04                	js     801549 <readn+0x3b>
			return m;
		if (m == 0)
  801545:	75 dd                	jne    801524 <readn+0x16>
  801547:	eb 02                	jmp    80154b <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801549:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80154b:	89 d8                	mov    %ebx,%eax
  80154d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801550:	5b                   	pop    %ebx
  801551:	5e                   	pop    %esi
  801552:	5f                   	pop    %edi
  801553:	5d                   	pop    %ebp
  801554:	c3                   	ret    

00801555 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801555:	55                   	push   %ebp
  801556:	89 e5                	mov    %esp,%ebp
  801558:	56                   	push   %esi
  801559:	53                   	push   %ebx
  80155a:	83 ec 18             	sub    $0x18,%esp
  80155d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801560:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801563:	50                   	push   %eax
  801564:	53                   	push   %ebx
  801565:	e8 b4 fc ff ff       	call   80121e <fd_lookup>
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	85 c0                	test   %eax,%eax
  80156f:	78 37                	js     8015a8 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801571:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801574:	83 ec 08             	sub    $0x8,%esp
  801577:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157a:	50                   	push   %eax
  80157b:	ff 36                	push   (%esi)
  80157d:	e8 ec fc ff ff       	call   80126e <dev_lookup>
  801582:	83 c4 10             	add    $0x10,%esp
  801585:	85 c0                	test   %eax,%eax
  801587:	78 1f                	js     8015a8 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801589:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80158d:	74 20                	je     8015af <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80158f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801592:	8b 40 0c             	mov    0xc(%eax),%eax
  801595:	85 c0                	test   %eax,%eax
  801597:	74 37                	je     8015d0 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801599:	83 ec 04             	sub    $0x4,%esp
  80159c:	ff 75 10             	push   0x10(%ebp)
  80159f:	ff 75 0c             	push   0xc(%ebp)
  8015a2:	56                   	push   %esi
  8015a3:	ff d0                	call   *%eax
  8015a5:	83 c4 10             	add    $0x10,%esp
}
  8015a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ab:	5b                   	pop    %ebx
  8015ac:	5e                   	pop    %esi
  8015ad:	5d                   	pop    %ebp
  8015ae:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8015af:	a1 04 40 80 00       	mov    0x804004,%eax
  8015b4:	8b 40 58             	mov    0x58(%eax),%eax
  8015b7:	83 ec 04             	sub    $0x4,%esp
  8015ba:	53                   	push   %ebx
  8015bb:	50                   	push   %eax
  8015bc:	68 f5 2a 80 00       	push   $0x802af5
  8015c1:	e8 35 ec ff ff       	call   8001fb <cprintf>
		return -E_INVAL;
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ce:	eb d8                	jmp    8015a8 <write+0x53>
		return -E_NOT_SUPP;
  8015d0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015d5:	eb d1                	jmp    8015a8 <write+0x53>

008015d7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015d7:	55                   	push   %ebp
  8015d8:	89 e5                	mov    %esp,%ebp
  8015da:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015e0:	50                   	push   %eax
  8015e1:	ff 75 08             	push   0x8(%ebp)
  8015e4:	e8 35 fc ff ff       	call   80121e <fd_lookup>
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	85 c0                	test   %eax,%eax
  8015ee:	78 0e                	js     8015fe <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015f6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015fe:	c9                   	leave  
  8015ff:	c3                   	ret    

00801600 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801600:	55                   	push   %ebp
  801601:	89 e5                	mov    %esp,%ebp
  801603:	56                   	push   %esi
  801604:	53                   	push   %ebx
  801605:	83 ec 18             	sub    $0x18,%esp
  801608:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80160e:	50                   	push   %eax
  80160f:	53                   	push   %ebx
  801610:	e8 09 fc ff ff       	call   80121e <fd_lookup>
  801615:	83 c4 10             	add    $0x10,%esp
  801618:	85 c0                	test   %eax,%eax
  80161a:	78 34                	js     801650 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80161c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80161f:	83 ec 08             	sub    $0x8,%esp
  801622:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801625:	50                   	push   %eax
  801626:	ff 36                	push   (%esi)
  801628:	e8 41 fc ff ff       	call   80126e <dev_lookup>
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	85 c0                	test   %eax,%eax
  801632:	78 1c                	js     801650 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801634:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801638:	74 1d                	je     801657 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80163a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80163d:	8b 40 18             	mov    0x18(%eax),%eax
  801640:	85 c0                	test   %eax,%eax
  801642:	74 34                	je     801678 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801644:	83 ec 08             	sub    $0x8,%esp
  801647:	ff 75 0c             	push   0xc(%ebp)
  80164a:	56                   	push   %esi
  80164b:	ff d0                	call   *%eax
  80164d:	83 c4 10             	add    $0x10,%esp
}
  801650:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801653:	5b                   	pop    %ebx
  801654:	5e                   	pop    %esi
  801655:	5d                   	pop    %ebp
  801656:	c3                   	ret    
			thisenv->env_id, fdnum);
  801657:	a1 04 40 80 00       	mov    0x804004,%eax
  80165c:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80165f:	83 ec 04             	sub    $0x4,%esp
  801662:	53                   	push   %ebx
  801663:	50                   	push   %eax
  801664:	68 b8 2a 80 00       	push   $0x802ab8
  801669:	e8 8d eb ff ff       	call   8001fb <cprintf>
		return -E_INVAL;
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801676:	eb d8                	jmp    801650 <ftruncate+0x50>
		return -E_NOT_SUPP;
  801678:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80167d:	eb d1                	jmp    801650 <ftruncate+0x50>

0080167f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	56                   	push   %esi
  801683:	53                   	push   %ebx
  801684:	83 ec 18             	sub    $0x18,%esp
  801687:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80168a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80168d:	50                   	push   %eax
  80168e:	ff 75 08             	push   0x8(%ebp)
  801691:	e8 88 fb ff ff       	call   80121e <fd_lookup>
  801696:	83 c4 10             	add    $0x10,%esp
  801699:	85 c0                	test   %eax,%eax
  80169b:	78 49                	js     8016e6 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80169d:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8016a0:	83 ec 08             	sub    $0x8,%esp
  8016a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016a6:	50                   	push   %eax
  8016a7:	ff 36                	push   (%esi)
  8016a9:	e8 c0 fb ff ff       	call   80126e <dev_lookup>
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	85 c0                	test   %eax,%eax
  8016b3:	78 31                	js     8016e6 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8016b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016bc:	74 2f                	je     8016ed <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016be:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016c1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016c8:	00 00 00 
	stat->st_isdir = 0;
  8016cb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016d2:	00 00 00 
	stat->st_dev = dev;
  8016d5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016db:	83 ec 08             	sub    $0x8,%esp
  8016de:	53                   	push   %ebx
  8016df:	56                   	push   %esi
  8016e0:	ff 50 14             	call   *0x14(%eax)
  8016e3:	83 c4 10             	add    $0x10,%esp
}
  8016e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e9:	5b                   	pop    %ebx
  8016ea:	5e                   	pop    %esi
  8016eb:	5d                   	pop    %ebp
  8016ec:	c3                   	ret    
		return -E_NOT_SUPP;
  8016ed:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016f2:	eb f2                	jmp    8016e6 <fstat+0x67>

008016f4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	56                   	push   %esi
  8016f8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016f9:	83 ec 08             	sub    $0x8,%esp
  8016fc:	6a 00                	push   $0x0
  8016fe:	ff 75 08             	push   0x8(%ebp)
  801701:	e8 e4 01 00 00       	call   8018ea <open>
  801706:	89 c3                	mov    %eax,%ebx
  801708:	83 c4 10             	add    $0x10,%esp
  80170b:	85 c0                	test   %eax,%eax
  80170d:	78 1b                	js     80172a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80170f:	83 ec 08             	sub    $0x8,%esp
  801712:	ff 75 0c             	push   0xc(%ebp)
  801715:	50                   	push   %eax
  801716:	e8 64 ff ff ff       	call   80167f <fstat>
  80171b:	89 c6                	mov    %eax,%esi
	close(fd);
  80171d:	89 1c 24             	mov    %ebx,(%esp)
  801720:	e8 26 fc ff ff       	call   80134b <close>
	return r;
  801725:	83 c4 10             	add    $0x10,%esp
  801728:	89 f3                	mov    %esi,%ebx
}
  80172a:	89 d8                	mov    %ebx,%eax
  80172c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172f:	5b                   	pop    %ebx
  801730:	5e                   	pop    %esi
  801731:	5d                   	pop    %ebp
  801732:	c3                   	ret    

00801733 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801733:	55                   	push   %ebp
  801734:	89 e5                	mov    %esp,%ebp
  801736:	56                   	push   %esi
  801737:	53                   	push   %ebx
  801738:	89 c6                	mov    %eax,%esi
  80173a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80173c:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801743:	74 27                	je     80176c <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801745:	6a 07                	push   $0x7
  801747:	68 00 50 80 00       	push   $0x805000
  80174c:	56                   	push   %esi
  80174d:	ff 35 00 60 80 00    	push   0x806000
  801753:	e8 bc f9 ff ff       	call   801114 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801758:	83 c4 0c             	add    $0xc,%esp
  80175b:	6a 00                	push   $0x0
  80175d:	53                   	push   %ebx
  80175e:	6a 00                	push   $0x0
  801760:	e8 3f f9 ff ff       	call   8010a4 <ipc_recv>
}
  801765:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801768:	5b                   	pop    %ebx
  801769:	5e                   	pop    %esi
  80176a:	5d                   	pop    %ebp
  80176b:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80176c:	83 ec 0c             	sub    $0xc,%esp
  80176f:	6a 01                	push   $0x1
  801771:	e8 f2 f9 ff ff       	call   801168 <ipc_find_env>
  801776:	a3 00 60 80 00       	mov    %eax,0x806000
  80177b:	83 c4 10             	add    $0x10,%esp
  80177e:	eb c5                	jmp    801745 <fsipc+0x12>

00801780 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801786:	8b 45 08             	mov    0x8(%ebp),%eax
  801789:	8b 40 0c             	mov    0xc(%eax),%eax
  80178c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801791:	8b 45 0c             	mov    0xc(%ebp),%eax
  801794:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801799:	ba 00 00 00 00       	mov    $0x0,%edx
  80179e:	b8 02 00 00 00       	mov    $0x2,%eax
  8017a3:	e8 8b ff ff ff       	call   801733 <fsipc>
}
  8017a8:	c9                   	leave  
  8017a9:	c3                   	ret    

008017aa <devfile_flush>:
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8017b6:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c0:	b8 06 00 00 00       	mov    $0x6,%eax
  8017c5:	e8 69 ff ff ff       	call   801733 <fsipc>
}
  8017ca:	c9                   	leave  
  8017cb:	c3                   	ret    

008017cc <devfile_stat>:
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	53                   	push   %ebx
  8017d0:	83 ec 04             	sub    $0x4,%esp
  8017d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8017dc:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e6:	b8 05 00 00 00       	mov    $0x5,%eax
  8017eb:	e8 43 ff ff ff       	call   801733 <fsipc>
  8017f0:	85 c0                	test   %eax,%eax
  8017f2:	78 2c                	js     801820 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017f4:	83 ec 08             	sub    $0x8,%esp
  8017f7:	68 00 50 80 00       	push   $0x805000
  8017fc:	53                   	push   %ebx
  8017fd:	e8 d3 ef ff ff       	call   8007d5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801802:	a1 80 50 80 00       	mov    0x805080,%eax
  801807:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80180d:	a1 84 50 80 00       	mov    0x805084,%eax
  801812:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801818:	83 c4 10             	add    $0x10,%esp
  80181b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801820:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801823:	c9                   	leave  
  801824:	c3                   	ret    

00801825 <devfile_write>:
{
  801825:	55                   	push   %ebp
  801826:	89 e5                	mov    %esp,%ebp
  801828:	83 ec 0c             	sub    $0xc,%esp
  80182b:	8b 45 10             	mov    0x10(%ebp),%eax
  80182e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801833:	39 d0                	cmp    %edx,%eax
  801835:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801838:	8b 55 08             	mov    0x8(%ebp),%edx
  80183b:	8b 52 0c             	mov    0xc(%edx),%edx
  80183e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801844:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801849:	50                   	push   %eax
  80184a:	ff 75 0c             	push   0xc(%ebp)
  80184d:	68 08 50 80 00       	push   $0x805008
  801852:	e8 14 f1 ff ff       	call   80096b <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801857:	ba 00 00 00 00       	mov    $0x0,%edx
  80185c:	b8 04 00 00 00       	mov    $0x4,%eax
  801861:	e8 cd fe ff ff       	call   801733 <fsipc>
}
  801866:	c9                   	leave  
  801867:	c3                   	ret    

00801868 <devfile_read>:
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	56                   	push   %esi
  80186c:	53                   	push   %ebx
  80186d:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801870:	8b 45 08             	mov    0x8(%ebp),%eax
  801873:	8b 40 0c             	mov    0xc(%eax),%eax
  801876:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80187b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801881:	ba 00 00 00 00       	mov    $0x0,%edx
  801886:	b8 03 00 00 00       	mov    $0x3,%eax
  80188b:	e8 a3 fe ff ff       	call   801733 <fsipc>
  801890:	89 c3                	mov    %eax,%ebx
  801892:	85 c0                	test   %eax,%eax
  801894:	78 1f                	js     8018b5 <devfile_read+0x4d>
	assert(r <= n);
  801896:	39 f0                	cmp    %esi,%eax
  801898:	77 24                	ja     8018be <devfile_read+0x56>
	assert(r <= PGSIZE);
  80189a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80189f:	7f 33                	jg     8018d4 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018a1:	83 ec 04             	sub    $0x4,%esp
  8018a4:	50                   	push   %eax
  8018a5:	68 00 50 80 00       	push   $0x805000
  8018aa:	ff 75 0c             	push   0xc(%ebp)
  8018ad:	e8 b9 f0 ff ff       	call   80096b <memmove>
	return r;
  8018b2:	83 c4 10             	add    $0x10,%esp
}
  8018b5:	89 d8                	mov    %ebx,%eax
  8018b7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018ba:	5b                   	pop    %ebx
  8018bb:	5e                   	pop    %esi
  8018bc:	5d                   	pop    %ebp
  8018bd:	c3                   	ret    
	assert(r <= n);
  8018be:	68 28 2b 80 00       	push   $0x802b28
  8018c3:	68 2f 2b 80 00       	push   $0x802b2f
  8018c8:	6a 7c                	push   $0x7c
  8018ca:	68 44 2b 80 00       	push   $0x802b44
  8018cf:	e8 e1 09 00 00       	call   8022b5 <_panic>
	assert(r <= PGSIZE);
  8018d4:	68 4f 2b 80 00       	push   $0x802b4f
  8018d9:	68 2f 2b 80 00       	push   $0x802b2f
  8018de:	6a 7d                	push   $0x7d
  8018e0:	68 44 2b 80 00       	push   $0x802b44
  8018e5:	e8 cb 09 00 00       	call   8022b5 <_panic>

008018ea <open>:
{
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	56                   	push   %esi
  8018ee:	53                   	push   %ebx
  8018ef:	83 ec 1c             	sub    $0x1c,%esp
  8018f2:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8018f5:	56                   	push   %esi
  8018f6:	e8 9f ee ff ff       	call   80079a <strlen>
  8018fb:	83 c4 10             	add    $0x10,%esp
  8018fe:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801903:	7f 6c                	jg     801971 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801905:	83 ec 0c             	sub    $0xc,%esp
  801908:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80190b:	50                   	push   %eax
  80190c:	e8 bd f8 ff ff       	call   8011ce <fd_alloc>
  801911:	89 c3                	mov    %eax,%ebx
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	85 c0                	test   %eax,%eax
  801918:	78 3c                	js     801956 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80191a:	83 ec 08             	sub    $0x8,%esp
  80191d:	56                   	push   %esi
  80191e:	68 00 50 80 00       	push   $0x805000
  801923:	e8 ad ee ff ff       	call   8007d5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801928:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192b:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801930:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801933:	b8 01 00 00 00       	mov    $0x1,%eax
  801938:	e8 f6 fd ff ff       	call   801733 <fsipc>
  80193d:	89 c3                	mov    %eax,%ebx
  80193f:	83 c4 10             	add    $0x10,%esp
  801942:	85 c0                	test   %eax,%eax
  801944:	78 19                	js     80195f <open+0x75>
	return fd2num(fd);
  801946:	83 ec 0c             	sub    $0xc,%esp
  801949:	ff 75 f4             	push   -0xc(%ebp)
  80194c:	e8 56 f8 ff ff       	call   8011a7 <fd2num>
  801951:	89 c3                	mov    %eax,%ebx
  801953:	83 c4 10             	add    $0x10,%esp
}
  801956:	89 d8                	mov    %ebx,%eax
  801958:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195b:	5b                   	pop    %ebx
  80195c:	5e                   	pop    %esi
  80195d:	5d                   	pop    %ebp
  80195e:	c3                   	ret    
		fd_close(fd, 0);
  80195f:	83 ec 08             	sub    $0x8,%esp
  801962:	6a 00                	push   $0x0
  801964:	ff 75 f4             	push   -0xc(%ebp)
  801967:	e8 58 f9 ff ff       	call   8012c4 <fd_close>
		return r;
  80196c:	83 c4 10             	add    $0x10,%esp
  80196f:	eb e5                	jmp    801956 <open+0x6c>
		return -E_BAD_PATH;
  801971:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801976:	eb de                	jmp    801956 <open+0x6c>

00801978 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801978:	55                   	push   %ebp
  801979:	89 e5                	mov    %esp,%ebp
  80197b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80197e:	ba 00 00 00 00       	mov    $0x0,%edx
  801983:	b8 08 00 00 00       	mov    $0x8,%eax
  801988:	e8 a6 fd ff ff       	call   801733 <fsipc>
}
  80198d:	c9                   	leave  
  80198e:	c3                   	ret    

0080198f <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801995:	68 5b 2b 80 00       	push   $0x802b5b
  80199a:	ff 75 0c             	push   0xc(%ebp)
  80199d:	e8 33 ee ff ff       	call   8007d5 <strcpy>
	return 0;
}
  8019a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a7:	c9                   	leave  
  8019a8:	c3                   	ret    

008019a9 <devsock_close>:
{
  8019a9:	55                   	push   %ebp
  8019aa:	89 e5                	mov    %esp,%ebp
  8019ac:	53                   	push   %ebx
  8019ad:	83 ec 10             	sub    $0x10,%esp
  8019b0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019b3:	53                   	push   %ebx
  8019b4:	e8 de 09 00 00       	call   802397 <pageref>
  8019b9:	89 c2                	mov    %eax,%edx
  8019bb:	83 c4 10             	add    $0x10,%esp
		return 0;
  8019be:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8019c3:	83 fa 01             	cmp    $0x1,%edx
  8019c6:	74 05                	je     8019cd <devsock_close+0x24>
}
  8019c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019cb:	c9                   	leave  
  8019cc:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8019cd:	83 ec 0c             	sub    $0xc,%esp
  8019d0:	ff 73 0c             	push   0xc(%ebx)
  8019d3:	e8 b7 02 00 00       	call   801c8f <nsipc_close>
  8019d8:	83 c4 10             	add    $0x10,%esp
  8019db:	eb eb                	jmp    8019c8 <devsock_close+0x1f>

008019dd <devsock_write>:
{
  8019dd:	55                   	push   %ebp
  8019de:	89 e5                	mov    %esp,%ebp
  8019e0:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019e3:	6a 00                	push   $0x0
  8019e5:	ff 75 10             	push   0x10(%ebp)
  8019e8:	ff 75 0c             	push   0xc(%ebp)
  8019eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ee:	ff 70 0c             	push   0xc(%eax)
  8019f1:	e8 79 03 00 00       	call   801d6f <nsipc_send>
}
  8019f6:	c9                   	leave  
  8019f7:	c3                   	ret    

008019f8 <devsock_read>:
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019fe:	6a 00                	push   $0x0
  801a00:	ff 75 10             	push   0x10(%ebp)
  801a03:	ff 75 0c             	push   0xc(%ebp)
  801a06:	8b 45 08             	mov    0x8(%ebp),%eax
  801a09:	ff 70 0c             	push   0xc(%eax)
  801a0c:	e8 ef 02 00 00       	call   801d00 <nsipc_recv>
}
  801a11:	c9                   	leave  
  801a12:	c3                   	ret    

00801a13 <fd2sockid>:
{
  801a13:	55                   	push   %ebp
  801a14:	89 e5                	mov    %esp,%ebp
  801a16:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a19:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a1c:	52                   	push   %edx
  801a1d:	50                   	push   %eax
  801a1e:	e8 fb f7 ff ff       	call   80121e <fd_lookup>
  801a23:	83 c4 10             	add    $0x10,%esp
  801a26:	85 c0                	test   %eax,%eax
  801a28:	78 10                	js     801a3a <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2d:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a33:	39 08                	cmp    %ecx,(%eax)
  801a35:	75 05                	jne    801a3c <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801a37:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801a3a:	c9                   	leave  
  801a3b:	c3                   	ret    
		return -E_NOT_SUPP;
  801a3c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a41:	eb f7                	jmp    801a3a <fd2sockid+0x27>

00801a43 <alloc_sockfd>:
{
  801a43:	55                   	push   %ebp
  801a44:	89 e5                	mov    %esp,%ebp
  801a46:	56                   	push   %esi
  801a47:	53                   	push   %ebx
  801a48:	83 ec 1c             	sub    $0x1c,%esp
  801a4b:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801a4d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a50:	50                   	push   %eax
  801a51:	e8 78 f7 ff ff       	call   8011ce <fd_alloc>
  801a56:	89 c3                	mov    %eax,%ebx
  801a58:	83 c4 10             	add    $0x10,%esp
  801a5b:	85 c0                	test   %eax,%eax
  801a5d:	78 43                	js     801aa2 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a5f:	83 ec 04             	sub    $0x4,%esp
  801a62:	68 07 04 00 00       	push   $0x407
  801a67:	ff 75 f4             	push   -0xc(%ebp)
  801a6a:	6a 00                	push   $0x0
  801a6c:	e8 60 f1 ff ff       	call   800bd1 <sys_page_alloc>
  801a71:	89 c3                	mov    %eax,%ebx
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	85 c0                	test   %eax,%eax
  801a78:	78 28                	js     801aa2 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801a7a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a7d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a83:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a88:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a8f:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a92:	83 ec 0c             	sub    $0xc,%esp
  801a95:	50                   	push   %eax
  801a96:	e8 0c f7 ff ff       	call   8011a7 <fd2num>
  801a9b:	89 c3                	mov    %eax,%ebx
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	eb 0c                	jmp    801aae <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801aa2:	83 ec 0c             	sub    $0xc,%esp
  801aa5:	56                   	push   %esi
  801aa6:	e8 e4 01 00 00       	call   801c8f <nsipc_close>
		return r;
  801aab:	83 c4 10             	add    $0x10,%esp
}
  801aae:	89 d8                	mov    %ebx,%eax
  801ab0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ab3:	5b                   	pop    %ebx
  801ab4:	5e                   	pop    %esi
  801ab5:	5d                   	pop    %ebp
  801ab6:	c3                   	ret    

00801ab7 <accept>:
{
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801abd:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac0:	e8 4e ff ff ff       	call   801a13 <fd2sockid>
  801ac5:	85 c0                	test   %eax,%eax
  801ac7:	78 1b                	js     801ae4 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ac9:	83 ec 04             	sub    $0x4,%esp
  801acc:	ff 75 10             	push   0x10(%ebp)
  801acf:	ff 75 0c             	push   0xc(%ebp)
  801ad2:	50                   	push   %eax
  801ad3:	e8 0e 01 00 00       	call   801be6 <nsipc_accept>
  801ad8:	83 c4 10             	add    $0x10,%esp
  801adb:	85 c0                	test   %eax,%eax
  801add:	78 05                	js     801ae4 <accept+0x2d>
	return alloc_sockfd(r);
  801adf:	e8 5f ff ff ff       	call   801a43 <alloc_sockfd>
}
  801ae4:	c9                   	leave  
  801ae5:	c3                   	ret    

00801ae6 <bind>:
{
  801ae6:	55                   	push   %ebp
  801ae7:	89 e5                	mov    %esp,%ebp
  801ae9:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801aec:	8b 45 08             	mov    0x8(%ebp),%eax
  801aef:	e8 1f ff ff ff       	call   801a13 <fd2sockid>
  801af4:	85 c0                	test   %eax,%eax
  801af6:	78 12                	js     801b0a <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801af8:	83 ec 04             	sub    $0x4,%esp
  801afb:	ff 75 10             	push   0x10(%ebp)
  801afe:	ff 75 0c             	push   0xc(%ebp)
  801b01:	50                   	push   %eax
  801b02:	e8 31 01 00 00       	call   801c38 <nsipc_bind>
  801b07:	83 c4 10             	add    $0x10,%esp
}
  801b0a:	c9                   	leave  
  801b0b:	c3                   	ret    

00801b0c <shutdown>:
{
  801b0c:	55                   	push   %ebp
  801b0d:	89 e5                	mov    %esp,%ebp
  801b0f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b12:	8b 45 08             	mov    0x8(%ebp),%eax
  801b15:	e8 f9 fe ff ff       	call   801a13 <fd2sockid>
  801b1a:	85 c0                	test   %eax,%eax
  801b1c:	78 0f                	js     801b2d <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801b1e:	83 ec 08             	sub    $0x8,%esp
  801b21:	ff 75 0c             	push   0xc(%ebp)
  801b24:	50                   	push   %eax
  801b25:	e8 43 01 00 00       	call   801c6d <nsipc_shutdown>
  801b2a:	83 c4 10             	add    $0x10,%esp
}
  801b2d:	c9                   	leave  
  801b2e:	c3                   	ret    

00801b2f <connect>:
{
  801b2f:	55                   	push   %ebp
  801b30:	89 e5                	mov    %esp,%ebp
  801b32:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b35:	8b 45 08             	mov    0x8(%ebp),%eax
  801b38:	e8 d6 fe ff ff       	call   801a13 <fd2sockid>
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	78 12                	js     801b53 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801b41:	83 ec 04             	sub    $0x4,%esp
  801b44:	ff 75 10             	push   0x10(%ebp)
  801b47:	ff 75 0c             	push   0xc(%ebp)
  801b4a:	50                   	push   %eax
  801b4b:	e8 59 01 00 00       	call   801ca9 <nsipc_connect>
  801b50:	83 c4 10             	add    $0x10,%esp
}
  801b53:	c9                   	leave  
  801b54:	c3                   	ret    

00801b55 <listen>:
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5e:	e8 b0 fe ff ff       	call   801a13 <fd2sockid>
  801b63:	85 c0                	test   %eax,%eax
  801b65:	78 0f                	js     801b76 <listen+0x21>
	return nsipc_listen(r, backlog);
  801b67:	83 ec 08             	sub    $0x8,%esp
  801b6a:	ff 75 0c             	push   0xc(%ebp)
  801b6d:	50                   	push   %eax
  801b6e:	e8 6b 01 00 00       	call   801cde <nsipc_listen>
  801b73:	83 c4 10             	add    $0x10,%esp
}
  801b76:	c9                   	leave  
  801b77:	c3                   	ret    

00801b78 <socket>:

int
socket(int domain, int type, int protocol)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b7e:	ff 75 10             	push   0x10(%ebp)
  801b81:	ff 75 0c             	push   0xc(%ebp)
  801b84:	ff 75 08             	push   0x8(%ebp)
  801b87:	e8 41 02 00 00       	call   801dcd <nsipc_socket>
  801b8c:	83 c4 10             	add    $0x10,%esp
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	78 05                	js     801b98 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b93:	e8 ab fe ff ff       	call   801a43 <alloc_sockfd>
}
  801b98:	c9                   	leave  
  801b99:	c3                   	ret    

00801b9a <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b9a:	55                   	push   %ebp
  801b9b:	89 e5                	mov    %esp,%ebp
  801b9d:	53                   	push   %ebx
  801b9e:	83 ec 04             	sub    $0x4,%esp
  801ba1:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ba3:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801baa:	74 26                	je     801bd2 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bac:	6a 07                	push   $0x7
  801bae:	68 00 70 80 00       	push   $0x807000
  801bb3:	53                   	push   %ebx
  801bb4:	ff 35 00 80 80 00    	push   0x808000
  801bba:	e8 55 f5 ff ff       	call   801114 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bbf:	83 c4 0c             	add    $0xc,%esp
  801bc2:	6a 00                	push   $0x0
  801bc4:	6a 00                	push   $0x0
  801bc6:	6a 00                	push   $0x0
  801bc8:	e8 d7 f4 ff ff       	call   8010a4 <ipc_recv>
}
  801bcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd0:	c9                   	leave  
  801bd1:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bd2:	83 ec 0c             	sub    $0xc,%esp
  801bd5:	6a 02                	push   $0x2
  801bd7:	e8 8c f5 ff ff       	call   801168 <ipc_find_env>
  801bdc:	a3 00 80 80 00       	mov    %eax,0x808000
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	eb c6                	jmp    801bac <nsipc+0x12>

00801be6 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801be6:	55                   	push   %ebp
  801be7:	89 e5                	mov    %esp,%ebp
  801be9:	56                   	push   %esi
  801bea:	53                   	push   %ebx
  801beb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bee:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf1:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bf6:	8b 06                	mov    (%esi),%eax
  801bf8:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bfd:	b8 01 00 00 00       	mov    $0x1,%eax
  801c02:	e8 93 ff ff ff       	call   801b9a <nsipc>
  801c07:	89 c3                	mov    %eax,%ebx
  801c09:	85 c0                	test   %eax,%eax
  801c0b:	79 09                	jns    801c16 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801c0d:	89 d8                	mov    %ebx,%eax
  801c0f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c12:	5b                   	pop    %ebx
  801c13:	5e                   	pop    %esi
  801c14:	5d                   	pop    %ebp
  801c15:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c16:	83 ec 04             	sub    $0x4,%esp
  801c19:	ff 35 10 70 80 00    	push   0x807010
  801c1f:	68 00 70 80 00       	push   $0x807000
  801c24:	ff 75 0c             	push   0xc(%ebp)
  801c27:	e8 3f ed ff ff       	call   80096b <memmove>
		*addrlen = ret->ret_addrlen;
  801c2c:	a1 10 70 80 00       	mov    0x807010,%eax
  801c31:	89 06                	mov    %eax,(%esi)
  801c33:	83 c4 10             	add    $0x10,%esp
	return r;
  801c36:	eb d5                	jmp    801c0d <nsipc_accept+0x27>

00801c38 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c38:	55                   	push   %ebp
  801c39:	89 e5                	mov    %esp,%ebp
  801c3b:	53                   	push   %ebx
  801c3c:	83 ec 08             	sub    $0x8,%esp
  801c3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c42:	8b 45 08             	mov    0x8(%ebp),%eax
  801c45:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c4a:	53                   	push   %ebx
  801c4b:	ff 75 0c             	push   0xc(%ebp)
  801c4e:	68 04 70 80 00       	push   $0x807004
  801c53:	e8 13 ed ff ff       	call   80096b <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c58:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801c5e:	b8 02 00 00 00       	mov    $0x2,%eax
  801c63:	e8 32 ff ff ff       	call   801b9a <nsipc>
}
  801c68:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c6b:	c9                   	leave  
  801c6c:	c3                   	ret    

00801c6d <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c73:	8b 45 08             	mov    0x8(%ebp),%eax
  801c76:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801c7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7e:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801c83:	b8 03 00 00 00       	mov    $0x3,%eax
  801c88:	e8 0d ff ff ff       	call   801b9a <nsipc>
}
  801c8d:	c9                   	leave  
  801c8e:	c3                   	ret    

00801c8f <nsipc_close>:

int
nsipc_close(int s)
{
  801c8f:	55                   	push   %ebp
  801c90:	89 e5                	mov    %esp,%ebp
  801c92:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c95:	8b 45 08             	mov    0x8(%ebp),%eax
  801c98:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801c9d:	b8 04 00 00 00       	mov    $0x4,%eax
  801ca2:	e8 f3 fe ff ff       	call   801b9a <nsipc>
}
  801ca7:	c9                   	leave  
  801ca8:	c3                   	ret    

00801ca9 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ca9:	55                   	push   %ebp
  801caa:	89 e5                	mov    %esp,%ebp
  801cac:	53                   	push   %ebx
  801cad:	83 ec 08             	sub    $0x8,%esp
  801cb0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb6:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cbb:	53                   	push   %ebx
  801cbc:	ff 75 0c             	push   0xc(%ebp)
  801cbf:	68 04 70 80 00       	push   $0x807004
  801cc4:	e8 a2 ec ff ff       	call   80096b <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cc9:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801ccf:	b8 05 00 00 00       	mov    $0x5,%eax
  801cd4:	e8 c1 fe ff ff       	call   801b9a <nsipc>
}
  801cd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cdc:	c9                   	leave  
  801cdd:	c3                   	ret    

00801cde <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cde:	55                   	push   %ebp
  801cdf:	89 e5                	mov    %esp,%ebp
  801ce1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ce4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801cec:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cef:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801cf4:	b8 06 00 00 00       	mov    $0x6,%eax
  801cf9:	e8 9c fe ff ff       	call   801b9a <nsipc>
}
  801cfe:	c9                   	leave  
  801cff:	c3                   	ret    

00801d00 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	56                   	push   %esi
  801d04:	53                   	push   %ebx
  801d05:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d08:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801d10:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801d16:	8b 45 14             	mov    0x14(%ebp),%eax
  801d19:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d1e:	b8 07 00 00 00       	mov    $0x7,%eax
  801d23:	e8 72 fe ff ff       	call   801b9a <nsipc>
  801d28:	89 c3                	mov    %eax,%ebx
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	78 22                	js     801d50 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801d2e:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801d33:	39 c6                	cmp    %eax,%esi
  801d35:	0f 4e c6             	cmovle %esi,%eax
  801d38:	39 c3                	cmp    %eax,%ebx
  801d3a:	7f 1d                	jg     801d59 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d3c:	83 ec 04             	sub    $0x4,%esp
  801d3f:	53                   	push   %ebx
  801d40:	68 00 70 80 00       	push   $0x807000
  801d45:	ff 75 0c             	push   0xc(%ebp)
  801d48:	e8 1e ec ff ff       	call   80096b <memmove>
  801d4d:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d50:	89 d8                	mov    %ebx,%eax
  801d52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d55:	5b                   	pop    %ebx
  801d56:	5e                   	pop    %esi
  801d57:	5d                   	pop    %ebp
  801d58:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801d59:	68 67 2b 80 00       	push   $0x802b67
  801d5e:	68 2f 2b 80 00       	push   $0x802b2f
  801d63:	6a 62                	push   $0x62
  801d65:	68 7c 2b 80 00       	push   $0x802b7c
  801d6a:	e8 46 05 00 00       	call   8022b5 <_panic>

00801d6f <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d6f:	55                   	push   %ebp
  801d70:	89 e5                	mov    %esp,%ebp
  801d72:	53                   	push   %ebx
  801d73:	83 ec 04             	sub    $0x4,%esp
  801d76:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d79:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7c:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801d81:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d87:	7f 2e                	jg     801db7 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d89:	83 ec 04             	sub    $0x4,%esp
  801d8c:	53                   	push   %ebx
  801d8d:	ff 75 0c             	push   0xc(%ebp)
  801d90:	68 0c 70 80 00       	push   $0x80700c
  801d95:	e8 d1 eb ff ff       	call   80096b <memmove>
	nsipcbuf.send.req_size = size;
  801d9a:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801da0:	8b 45 14             	mov    0x14(%ebp),%eax
  801da3:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801da8:	b8 08 00 00 00       	mov    $0x8,%eax
  801dad:	e8 e8 fd ff ff       	call   801b9a <nsipc>
}
  801db2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801db5:	c9                   	leave  
  801db6:	c3                   	ret    
	assert(size < 1600);
  801db7:	68 88 2b 80 00       	push   $0x802b88
  801dbc:	68 2f 2b 80 00       	push   $0x802b2f
  801dc1:	6a 6d                	push   $0x6d
  801dc3:	68 7c 2b 80 00       	push   $0x802b7c
  801dc8:	e8 e8 04 00 00       	call   8022b5 <_panic>

00801dcd <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dcd:	55                   	push   %ebp
  801dce:	89 e5                	mov    %esp,%ebp
  801dd0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd6:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801ddb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dde:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801de3:	8b 45 10             	mov    0x10(%ebp),%eax
  801de6:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801deb:	b8 09 00 00 00       	mov    $0x9,%eax
  801df0:	e8 a5 fd ff ff       	call   801b9a <nsipc>
}
  801df5:	c9                   	leave  
  801df6:	c3                   	ret    

00801df7 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801df7:	55                   	push   %ebp
  801df8:	89 e5                	mov    %esp,%ebp
  801dfa:	56                   	push   %esi
  801dfb:	53                   	push   %ebx
  801dfc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dff:	83 ec 0c             	sub    $0xc,%esp
  801e02:	ff 75 08             	push   0x8(%ebp)
  801e05:	e8 ad f3 ff ff       	call   8011b7 <fd2data>
  801e0a:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e0c:	83 c4 08             	add    $0x8,%esp
  801e0f:	68 94 2b 80 00       	push   $0x802b94
  801e14:	53                   	push   %ebx
  801e15:	e8 bb e9 ff ff       	call   8007d5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e1a:	8b 46 04             	mov    0x4(%esi),%eax
  801e1d:	2b 06                	sub    (%esi),%eax
  801e1f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e25:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e2c:	00 00 00 
	stat->st_dev = &devpipe;
  801e2f:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e36:	30 80 00 
	return 0;
}
  801e39:	b8 00 00 00 00       	mov    $0x0,%eax
  801e3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e41:	5b                   	pop    %ebx
  801e42:	5e                   	pop    %esi
  801e43:	5d                   	pop    %ebp
  801e44:	c3                   	ret    

00801e45 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e45:	55                   	push   %ebp
  801e46:	89 e5                	mov    %esp,%ebp
  801e48:	53                   	push   %ebx
  801e49:	83 ec 0c             	sub    $0xc,%esp
  801e4c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e4f:	53                   	push   %ebx
  801e50:	6a 00                	push   $0x0
  801e52:	e8 ff ed ff ff       	call   800c56 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e57:	89 1c 24             	mov    %ebx,(%esp)
  801e5a:	e8 58 f3 ff ff       	call   8011b7 <fd2data>
  801e5f:	83 c4 08             	add    $0x8,%esp
  801e62:	50                   	push   %eax
  801e63:	6a 00                	push   $0x0
  801e65:	e8 ec ed ff ff       	call   800c56 <sys_page_unmap>
}
  801e6a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e6d:	c9                   	leave  
  801e6e:	c3                   	ret    

00801e6f <_pipeisclosed>:
{
  801e6f:	55                   	push   %ebp
  801e70:	89 e5                	mov    %esp,%ebp
  801e72:	57                   	push   %edi
  801e73:	56                   	push   %esi
  801e74:	53                   	push   %ebx
  801e75:	83 ec 1c             	sub    $0x1c,%esp
  801e78:	89 c7                	mov    %eax,%edi
  801e7a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801e7c:	a1 04 40 80 00       	mov    0x804004,%eax
  801e81:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e84:	83 ec 0c             	sub    $0xc,%esp
  801e87:	57                   	push   %edi
  801e88:	e8 0a 05 00 00       	call   802397 <pageref>
  801e8d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801e90:	89 34 24             	mov    %esi,(%esp)
  801e93:	e8 ff 04 00 00       	call   802397 <pageref>
		nn = thisenv->env_runs;
  801e98:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e9e:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801ea1:	83 c4 10             	add    $0x10,%esp
  801ea4:	39 cb                	cmp    %ecx,%ebx
  801ea6:	74 1b                	je     801ec3 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801ea8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801eab:	75 cf                	jne    801e7c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801ead:	8b 42 68             	mov    0x68(%edx),%eax
  801eb0:	6a 01                	push   $0x1
  801eb2:	50                   	push   %eax
  801eb3:	53                   	push   %ebx
  801eb4:	68 9b 2b 80 00       	push   $0x802b9b
  801eb9:	e8 3d e3 ff ff       	call   8001fb <cprintf>
  801ebe:	83 c4 10             	add    $0x10,%esp
  801ec1:	eb b9                	jmp    801e7c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801ec3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ec6:	0f 94 c0             	sete   %al
  801ec9:	0f b6 c0             	movzbl %al,%eax
}
  801ecc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ecf:	5b                   	pop    %ebx
  801ed0:	5e                   	pop    %esi
  801ed1:	5f                   	pop    %edi
  801ed2:	5d                   	pop    %ebp
  801ed3:	c3                   	ret    

00801ed4 <devpipe_write>:
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	57                   	push   %edi
  801ed8:	56                   	push   %esi
  801ed9:	53                   	push   %ebx
  801eda:	83 ec 28             	sub    $0x28,%esp
  801edd:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ee0:	56                   	push   %esi
  801ee1:	e8 d1 f2 ff ff       	call   8011b7 <fd2data>
  801ee6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ee8:	83 c4 10             	add    $0x10,%esp
  801eeb:	bf 00 00 00 00       	mov    $0x0,%edi
  801ef0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ef3:	75 09                	jne    801efe <devpipe_write+0x2a>
	return i;
  801ef5:	89 f8                	mov    %edi,%eax
  801ef7:	eb 23                	jmp    801f1c <devpipe_write+0x48>
			sys_yield();
  801ef9:	e8 b4 ec ff ff       	call   800bb2 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801efe:	8b 43 04             	mov    0x4(%ebx),%eax
  801f01:	8b 0b                	mov    (%ebx),%ecx
  801f03:	8d 51 20             	lea    0x20(%ecx),%edx
  801f06:	39 d0                	cmp    %edx,%eax
  801f08:	72 1a                	jb     801f24 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801f0a:	89 da                	mov    %ebx,%edx
  801f0c:	89 f0                	mov    %esi,%eax
  801f0e:	e8 5c ff ff ff       	call   801e6f <_pipeisclosed>
  801f13:	85 c0                	test   %eax,%eax
  801f15:	74 e2                	je     801ef9 <devpipe_write+0x25>
				return 0;
  801f17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f1f:	5b                   	pop    %ebx
  801f20:	5e                   	pop    %esi
  801f21:	5f                   	pop    %edi
  801f22:	5d                   	pop    %ebp
  801f23:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f27:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f2b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f2e:	89 c2                	mov    %eax,%edx
  801f30:	c1 fa 1f             	sar    $0x1f,%edx
  801f33:	89 d1                	mov    %edx,%ecx
  801f35:	c1 e9 1b             	shr    $0x1b,%ecx
  801f38:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f3b:	83 e2 1f             	and    $0x1f,%edx
  801f3e:	29 ca                	sub    %ecx,%edx
  801f40:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f44:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f48:	83 c0 01             	add    $0x1,%eax
  801f4b:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801f4e:	83 c7 01             	add    $0x1,%edi
  801f51:	eb 9d                	jmp    801ef0 <devpipe_write+0x1c>

00801f53 <devpipe_read>:
{
  801f53:	55                   	push   %ebp
  801f54:	89 e5                	mov    %esp,%ebp
  801f56:	57                   	push   %edi
  801f57:	56                   	push   %esi
  801f58:	53                   	push   %ebx
  801f59:	83 ec 18             	sub    $0x18,%esp
  801f5c:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801f5f:	57                   	push   %edi
  801f60:	e8 52 f2 ff ff       	call   8011b7 <fd2data>
  801f65:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f67:	83 c4 10             	add    $0x10,%esp
  801f6a:	be 00 00 00 00       	mov    $0x0,%esi
  801f6f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f72:	75 13                	jne    801f87 <devpipe_read+0x34>
	return i;
  801f74:	89 f0                	mov    %esi,%eax
  801f76:	eb 02                	jmp    801f7a <devpipe_read+0x27>
				return i;
  801f78:	89 f0                	mov    %esi,%eax
}
  801f7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f7d:	5b                   	pop    %ebx
  801f7e:	5e                   	pop    %esi
  801f7f:	5f                   	pop    %edi
  801f80:	5d                   	pop    %ebp
  801f81:	c3                   	ret    
			sys_yield();
  801f82:	e8 2b ec ff ff       	call   800bb2 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801f87:	8b 03                	mov    (%ebx),%eax
  801f89:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f8c:	75 18                	jne    801fa6 <devpipe_read+0x53>
			if (i > 0)
  801f8e:	85 f6                	test   %esi,%esi
  801f90:	75 e6                	jne    801f78 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801f92:	89 da                	mov    %ebx,%edx
  801f94:	89 f8                	mov    %edi,%eax
  801f96:	e8 d4 fe ff ff       	call   801e6f <_pipeisclosed>
  801f9b:	85 c0                	test   %eax,%eax
  801f9d:	74 e3                	je     801f82 <devpipe_read+0x2f>
				return 0;
  801f9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa4:	eb d4                	jmp    801f7a <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801fa6:	99                   	cltd   
  801fa7:	c1 ea 1b             	shr    $0x1b,%edx
  801faa:	01 d0                	add    %edx,%eax
  801fac:	83 e0 1f             	and    $0x1f,%eax
  801faf:	29 d0                	sub    %edx,%eax
  801fb1:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801fb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fb9:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801fbc:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801fbf:	83 c6 01             	add    $0x1,%esi
  801fc2:	eb ab                	jmp    801f6f <devpipe_read+0x1c>

00801fc4 <pipe>:
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	56                   	push   %esi
  801fc8:	53                   	push   %ebx
  801fc9:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801fcc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fcf:	50                   	push   %eax
  801fd0:	e8 f9 f1 ff ff       	call   8011ce <fd_alloc>
  801fd5:	89 c3                	mov    %eax,%ebx
  801fd7:	83 c4 10             	add    $0x10,%esp
  801fda:	85 c0                	test   %eax,%eax
  801fdc:	0f 88 23 01 00 00    	js     802105 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fe2:	83 ec 04             	sub    $0x4,%esp
  801fe5:	68 07 04 00 00       	push   $0x407
  801fea:	ff 75 f4             	push   -0xc(%ebp)
  801fed:	6a 00                	push   $0x0
  801fef:	e8 dd eb ff ff       	call   800bd1 <sys_page_alloc>
  801ff4:	89 c3                	mov    %eax,%ebx
  801ff6:	83 c4 10             	add    $0x10,%esp
  801ff9:	85 c0                	test   %eax,%eax
  801ffb:	0f 88 04 01 00 00    	js     802105 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  802001:	83 ec 0c             	sub    $0xc,%esp
  802004:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802007:	50                   	push   %eax
  802008:	e8 c1 f1 ff ff       	call   8011ce <fd_alloc>
  80200d:	89 c3                	mov    %eax,%ebx
  80200f:	83 c4 10             	add    $0x10,%esp
  802012:	85 c0                	test   %eax,%eax
  802014:	0f 88 db 00 00 00    	js     8020f5 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80201a:	83 ec 04             	sub    $0x4,%esp
  80201d:	68 07 04 00 00       	push   $0x407
  802022:	ff 75 f0             	push   -0x10(%ebp)
  802025:	6a 00                	push   $0x0
  802027:	e8 a5 eb ff ff       	call   800bd1 <sys_page_alloc>
  80202c:	89 c3                	mov    %eax,%ebx
  80202e:	83 c4 10             	add    $0x10,%esp
  802031:	85 c0                	test   %eax,%eax
  802033:	0f 88 bc 00 00 00    	js     8020f5 <pipe+0x131>
	va = fd2data(fd0);
  802039:	83 ec 0c             	sub    $0xc,%esp
  80203c:	ff 75 f4             	push   -0xc(%ebp)
  80203f:	e8 73 f1 ff ff       	call   8011b7 <fd2data>
  802044:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802046:	83 c4 0c             	add    $0xc,%esp
  802049:	68 07 04 00 00       	push   $0x407
  80204e:	50                   	push   %eax
  80204f:	6a 00                	push   $0x0
  802051:	e8 7b eb ff ff       	call   800bd1 <sys_page_alloc>
  802056:	89 c3                	mov    %eax,%ebx
  802058:	83 c4 10             	add    $0x10,%esp
  80205b:	85 c0                	test   %eax,%eax
  80205d:	0f 88 82 00 00 00    	js     8020e5 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802063:	83 ec 0c             	sub    $0xc,%esp
  802066:	ff 75 f0             	push   -0x10(%ebp)
  802069:	e8 49 f1 ff ff       	call   8011b7 <fd2data>
  80206e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802075:	50                   	push   %eax
  802076:	6a 00                	push   $0x0
  802078:	56                   	push   %esi
  802079:	6a 00                	push   $0x0
  80207b:	e8 94 eb ff ff       	call   800c14 <sys_page_map>
  802080:	89 c3                	mov    %eax,%ebx
  802082:	83 c4 20             	add    $0x20,%esp
  802085:	85 c0                	test   %eax,%eax
  802087:	78 4e                	js     8020d7 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  802089:	a1 3c 30 80 00       	mov    0x80303c,%eax
  80208e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802091:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802093:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802096:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80209d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020a0:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8020a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020a5:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8020ac:	83 ec 0c             	sub    $0xc,%esp
  8020af:	ff 75 f4             	push   -0xc(%ebp)
  8020b2:	e8 f0 f0 ff ff       	call   8011a7 <fd2num>
  8020b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020ba:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020bc:	83 c4 04             	add    $0x4,%esp
  8020bf:	ff 75 f0             	push   -0x10(%ebp)
  8020c2:	e8 e0 f0 ff ff       	call   8011a7 <fd2num>
  8020c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020ca:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020cd:	83 c4 10             	add    $0x10,%esp
  8020d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020d5:	eb 2e                	jmp    802105 <pipe+0x141>
	sys_page_unmap(0, va);
  8020d7:	83 ec 08             	sub    $0x8,%esp
  8020da:	56                   	push   %esi
  8020db:	6a 00                	push   $0x0
  8020dd:	e8 74 eb ff ff       	call   800c56 <sys_page_unmap>
  8020e2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8020e5:	83 ec 08             	sub    $0x8,%esp
  8020e8:	ff 75 f0             	push   -0x10(%ebp)
  8020eb:	6a 00                	push   $0x0
  8020ed:	e8 64 eb ff ff       	call   800c56 <sys_page_unmap>
  8020f2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8020f5:	83 ec 08             	sub    $0x8,%esp
  8020f8:	ff 75 f4             	push   -0xc(%ebp)
  8020fb:	6a 00                	push   $0x0
  8020fd:	e8 54 eb ff ff       	call   800c56 <sys_page_unmap>
  802102:	83 c4 10             	add    $0x10,%esp
}
  802105:	89 d8                	mov    %ebx,%eax
  802107:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80210a:	5b                   	pop    %ebx
  80210b:	5e                   	pop    %esi
  80210c:	5d                   	pop    %ebp
  80210d:	c3                   	ret    

0080210e <pipeisclosed>:
{
  80210e:	55                   	push   %ebp
  80210f:	89 e5                	mov    %esp,%ebp
  802111:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802114:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802117:	50                   	push   %eax
  802118:	ff 75 08             	push   0x8(%ebp)
  80211b:	e8 fe f0 ff ff       	call   80121e <fd_lookup>
  802120:	83 c4 10             	add    $0x10,%esp
  802123:	85 c0                	test   %eax,%eax
  802125:	78 18                	js     80213f <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802127:	83 ec 0c             	sub    $0xc,%esp
  80212a:	ff 75 f4             	push   -0xc(%ebp)
  80212d:	e8 85 f0 ff ff       	call   8011b7 <fd2data>
  802132:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802134:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802137:	e8 33 fd ff ff       	call   801e6f <_pipeisclosed>
  80213c:	83 c4 10             	add    $0x10,%esp
}
  80213f:	c9                   	leave  
  802140:	c3                   	ret    

00802141 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802141:	b8 00 00 00 00       	mov    $0x0,%eax
  802146:	c3                   	ret    

00802147 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802147:	55                   	push   %ebp
  802148:	89 e5                	mov    %esp,%ebp
  80214a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80214d:	68 b3 2b 80 00       	push   $0x802bb3
  802152:	ff 75 0c             	push   0xc(%ebp)
  802155:	e8 7b e6 ff ff       	call   8007d5 <strcpy>
	return 0;
}
  80215a:	b8 00 00 00 00       	mov    $0x0,%eax
  80215f:	c9                   	leave  
  802160:	c3                   	ret    

00802161 <devcons_write>:
{
  802161:	55                   	push   %ebp
  802162:	89 e5                	mov    %esp,%ebp
  802164:	57                   	push   %edi
  802165:	56                   	push   %esi
  802166:	53                   	push   %ebx
  802167:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80216d:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802172:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802178:	eb 2e                	jmp    8021a8 <devcons_write+0x47>
		m = n - tot;
  80217a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80217d:	29 f3                	sub    %esi,%ebx
  80217f:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802184:	39 c3                	cmp    %eax,%ebx
  802186:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802189:	83 ec 04             	sub    $0x4,%esp
  80218c:	53                   	push   %ebx
  80218d:	89 f0                	mov    %esi,%eax
  80218f:	03 45 0c             	add    0xc(%ebp),%eax
  802192:	50                   	push   %eax
  802193:	57                   	push   %edi
  802194:	e8 d2 e7 ff ff       	call   80096b <memmove>
		sys_cputs(buf, m);
  802199:	83 c4 08             	add    $0x8,%esp
  80219c:	53                   	push   %ebx
  80219d:	57                   	push   %edi
  80219e:	e8 72 e9 ff ff       	call   800b15 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8021a3:	01 de                	add    %ebx,%esi
  8021a5:	83 c4 10             	add    $0x10,%esp
  8021a8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021ab:	72 cd                	jb     80217a <devcons_write+0x19>
}
  8021ad:	89 f0                	mov    %esi,%eax
  8021af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021b2:	5b                   	pop    %ebx
  8021b3:	5e                   	pop    %esi
  8021b4:	5f                   	pop    %edi
  8021b5:	5d                   	pop    %ebp
  8021b6:	c3                   	ret    

008021b7 <devcons_read>:
{
  8021b7:	55                   	push   %ebp
  8021b8:	89 e5                	mov    %esp,%ebp
  8021ba:	83 ec 08             	sub    $0x8,%esp
  8021bd:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8021c2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021c6:	75 07                	jne    8021cf <devcons_read+0x18>
  8021c8:	eb 1f                	jmp    8021e9 <devcons_read+0x32>
		sys_yield();
  8021ca:	e8 e3 e9 ff ff       	call   800bb2 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8021cf:	e8 5f e9 ff ff       	call   800b33 <sys_cgetc>
  8021d4:	85 c0                	test   %eax,%eax
  8021d6:	74 f2                	je     8021ca <devcons_read+0x13>
	if (c < 0)
  8021d8:	78 0f                	js     8021e9 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8021da:	83 f8 04             	cmp    $0x4,%eax
  8021dd:	74 0c                	je     8021eb <devcons_read+0x34>
	*(char*)vbuf = c;
  8021df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021e2:	88 02                	mov    %al,(%edx)
	return 1;
  8021e4:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8021e9:	c9                   	leave  
  8021ea:	c3                   	ret    
		return 0;
  8021eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8021f0:	eb f7                	jmp    8021e9 <devcons_read+0x32>

008021f2 <cputchar>:
{
  8021f2:	55                   	push   %ebp
  8021f3:	89 e5                	mov    %esp,%ebp
  8021f5:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021fb:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8021fe:	6a 01                	push   $0x1
  802200:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802203:	50                   	push   %eax
  802204:	e8 0c e9 ff ff       	call   800b15 <sys_cputs>
}
  802209:	83 c4 10             	add    $0x10,%esp
  80220c:	c9                   	leave  
  80220d:	c3                   	ret    

0080220e <getchar>:
{
  80220e:	55                   	push   %ebp
  80220f:	89 e5                	mov    %esp,%ebp
  802211:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802214:	6a 01                	push   $0x1
  802216:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802219:	50                   	push   %eax
  80221a:	6a 00                	push   $0x0
  80221c:	e8 66 f2 ff ff       	call   801487 <read>
	if (r < 0)
  802221:	83 c4 10             	add    $0x10,%esp
  802224:	85 c0                	test   %eax,%eax
  802226:	78 06                	js     80222e <getchar+0x20>
	if (r < 1)
  802228:	74 06                	je     802230 <getchar+0x22>
	return c;
  80222a:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80222e:	c9                   	leave  
  80222f:	c3                   	ret    
		return -E_EOF;
  802230:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802235:	eb f7                	jmp    80222e <getchar+0x20>

00802237 <iscons>:
{
  802237:	55                   	push   %ebp
  802238:	89 e5                	mov    %esp,%ebp
  80223a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80223d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802240:	50                   	push   %eax
  802241:	ff 75 08             	push   0x8(%ebp)
  802244:	e8 d5 ef ff ff       	call   80121e <fd_lookup>
  802249:	83 c4 10             	add    $0x10,%esp
  80224c:	85 c0                	test   %eax,%eax
  80224e:	78 11                	js     802261 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802250:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802253:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802259:	39 10                	cmp    %edx,(%eax)
  80225b:	0f 94 c0             	sete   %al
  80225e:	0f b6 c0             	movzbl %al,%eax
}
  802261:	c9                   	leave  
  802262:	c3                   	ret    

00802263 <opencons>:
{
  802263:	55                   	push   %ebp
  802264:	89 e5                	mov    %esp,%ebp
  802266:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802269:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80226c:	50                   	push   %eax
  80226d:	e8 5c ef ff ff       	call   8011ce <fd_alloc>
  802272:	83 c4 10             	add    $0x10,%esp
  802275:	85 c0                	test   %eax,%eax
  802277:	78 3a                	js     8022b3 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802279:	83 ec 04             	sub    $0x4,%esp
  80227c:	68 07 04 00 00       	push   $0x407
  802281:	ff 75 f4             	push   -0xc(%ebp)
  802284:	6a 00                	push   $0x0
  802286:	e8 46 e9 ff ff       	call   800bd1 <sys_page_alloc>
  80228b:	83 c4 10             	add    $0x10,%esp
  80228e:	85 c0                	test   %eax,%eax
  802290:	78 21                	js     8022b3 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  802292:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802295:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80229b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80229d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022a7:	83 ec 0c             	sub    $0xc,%esp
  8022aa:	50                   	push   %eax
  8022ab:	e8 f7 ee ff ff       	call   8011a7 <fd2num>
  8022b0:	83 c4 10             	add    $0x10,%esp
}
  8022b3:	c9                   	leave  
  8022b4:	c3                   	ret    

008022b5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8022b5:	55                   	push   %ebp
  8022b6:	89 e5                	mov    %esp,%ebp
  8022b8:	56                   	push   %esi
  8022b9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8022ba:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8022bd:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8022c3:	e8 cb e8 ff ff       	call   800b93 <sys_getenvid>
  8022c8:	83 ec 0c             	sub    $0xc,%esp
  8022cb:	ff 75 0c             	push   0xc(%ebp)
  8022ce:	ff 75 08             	push   0x8(%ebp)
  8022d1:	56                   	push   %esi
  8022d2:	50                   	push   %eax
  8022d3:	68 c0 2b 80 00       	push   $0x802bc0
  8022d8:	e8 1e df ff ff       	call   8001fb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8022dd:	83 c4 18             	add    $0x18,%esp
  8022e0:	53                   	push   %ebx
  8022e1:	ff 75 10             	push   0x10(%ebp)
  8022e4:	e8 c1 de ff ff       	call   8001aa <vcprintf>
	cprintf("\n");
  8022e9:	c7 04 24 ac 2b 80 00 	movl   $0x802bac,(%esp)
  8022f0:	e8 06 df ff ff       	call   8001fb <cprintf>
  8022f5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8022f8:	cc                   	int3   
  8022f9:	eb fd                	jmp    8022f8 <_panic+0x43>

008022fb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022fb:	55                   	push   %ebp
  8022fc:	89 e5                	mov    %esp,%ebp
  8022fe:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  802301:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  802308:	74 0a                	je     802314 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80230a:	8b 45 08             	mov    0x8(%ebp),%eax
  80230d:	a3 04 80 80 00       	mov    %eax,0x808004
}
  802312:	c9                   	leave  
  802313:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  802314:	e8 7a e8 ff ff       	call   800b93 <sys_getenvid>
  802319:	83 ec 04             	sub    $0x4,%esp
  80231c:	68 07 0e 00 00       	push   $0xe07
  802321:	68 00 f0 bf ee       	push   $0xeebff000
  802326:	50                   	push   %eax
  802327:	e8 a5 e8 ff ff       	call   800bd1 <sys_page_alloc>
		if (r < 0) {
  80232c:	83 c4 10             	add    $0x10,%esp
  80232f:	85 c0                	test   %eax,%eax
  802331:	78 2c                	js     80235f <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802333:	e8 5b e8 ff ff       	call   800b93 <sys_getenvid>
  802338:	83 ec 08             	sub    $0x8,%esp
  80233b:	68 71 23 80 00       	push   $0x802371
  802340:	50                   	push   %eax
  802341:	e8 d6 e9 ff ff       	call   800d1c <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802346:	83 c4 10             	add    $0x10,%esp
  802349:	85 c0                	test   %eax,%eax
  80234b:	79 bd                	jns    80230a <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  80234d:	50                   	push   %eax
  80234e:	68 24 2c 80 00       	push   $0x802c24
  802353:	6a 28                	push   $0x28
  802355:	68 5a 2c 80 00       	push   $0x802c5a
  80235a:	e8 56 ff ff ff       	call   8022b5 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  80235f:	50                   	push   %eax
  802360:	68 e4 2b 80 00       	push   $0x802be4
  802365:	6a 23                	push   $0x23
  802367:	68 5a 2c 80 00       	push   $0x802c5a
  80236c:	e8 44 ff ff ff       	call   8022b5 <_panic>

00802371 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802371:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802372:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  802377:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802379:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  80237c:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802380:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802383:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802387:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  80238b:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  80238d:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  802390:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  802391:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  802394:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  802395:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  802396:	c3                   	ret    

00802397 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802397:	55                   	push   %ebp
  802398:	89 e5                	mov    %esp,%ebp
  80239a:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80239d:	89 c2                	mov    %eax,%edx
  80239f:	c1 ea 16             	shr    $0x16,%edx
  8023a2:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8023a9:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8023ae:	f6 c1 01             	test   $0x1,%cl
  8023b1:	74 1c                	je     8023cf <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8023b3:	c1 e8 0c             	shr    $0xc,%eax
  8023b6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8023bd:	a8 01                	test   $0x1,%al
  8023bf:	74 0e                	je     8023cf <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023c1:	c1 e8 0c             	shr    $0xc,%eax
  8023c4:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8023cb:	ef 
  8023cc:	0f b7 d2             	movzwl %dx,%edx
}
  8023cf:	89 d0                	mov    %edx,%eax
  8023d1:	5d                   	pop    %ebp
  8023d2:	c3                   	ret    
  8023d3:	66 90                	xchg   %ax,%ax
  8023d5:	66 90                	xchg   %ax,%ax
  8023d7:	66 90                	xchg   %ax,%ax
  8023d9:	66 90                	xchg   %ax,%ax
  8023db:	66 90                	xchg   %ax,%ax
  8023dd:	66 90                	xchg   %ax,%ax
  8023df:	90                   	nop

008023e0 <__udivdi3>:
  8023e0:	f3 0f 1e fb          	endbr32 
  8023e4:	55                   	push   %ebp
  8023e5:	57                   	push   %edi
  8023e6:	56                   	push   %esi
  8023e7:	53                   	push   %ebx
  8023e8:	83 ec 1c             	sub    $0x1c,%esp
  8023eb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8023ef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8023f3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023f7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8023fb:	85 c0                	test   %eax,%eax
  8023fd:	75 19                	jne    802418 <__udivdi3+0x38>
  8023ff:	39 f3                	cmp    %esi,%ebx
  802401:	76 4d                	jbe    802450 <__udivdi3+0x70>
  802403:	31 ff                	xor    %edi,%edi
  802405:	89 e8                	mov    %ebp,%eax
  802407:	89 f2                	mov    %esi,%edx
  802409:	f7 f3                	div    %ebx
  80240b:	89 fa                	mov    %edi,%edx
  80240d:	83 c4 1c             	add    $0x1c,%esp
  802410:	5b                   	pop    %ebx
  802411:	5e                   	pop    %esi
  802412:	5f                   	pop    %edi
  802413:	5d                   	pop    %ebp
  802414:	c3                   	ret    
  802415:	8d 76 00             	lea    0x0(%esi),%esi
  802418:	39 f0                	cmp    %esi,%eax
  80241a:	76 14                	jbe    802430 <__udivdi3+0x50>
  80241c:	31 ff                	xor    %edi,%edi
  80241e:	31 c0                	xor    %eax,%eax
  802420:	89 fa                	mov    %edi,%edx
  802422:	83 c4 1c             	add    $0x1c,%esp
  802425:	5b                   	pop    %ebx
  802426:	5e                   	pop    %esi
  802427:	5f                   	pop    %edi
  802428:	5d                   	pop    %ebp
  802429:	c3                   	ret    
  80242a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802430:	0f bd f8             	bsr    %eax,%edi
  802433:	83 f7 1f             	xor    $0x1f,%edi
  802436:	75 48                	jne    802480 <__udivdi3+0xa0>
  802438:	39 f0                	cmp    %esi,%eax
  80243a:	72 06                	jb     802442 <__udivdi3+0x62>
  80243c:	31 c0                	xor    %eax,%eax
  80243e:	39 eb                	cmp    %ebp,%ebx
  802440:	77 de                	ja     802420 <__udivdi3+0x40>
  802442:	b8 01 00 00 00       	mov    $0x1,%eax
  802447:	eb d7                	jmp    802420 <__udivdi3+0x40>
  802449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802450:	89 d9                	mov    %ebx,%ecx
  802452:	85 db                	test   %ebx,%ebx
  802454:	75 0b                	jne    802461 <__udivdi3+0x81>
  802456:	b8 01 00 00 00       	mov    $0x1,%eax
  80245b:	31 d2                	xor    %edx,%edx
  80245d:	f7 f3                	div    %ebx
  80245f:	89 c1                	mov    %eax,%ecx
  802461:	31 d2                	xor    %edx,%edx
  802463:	89 f0                	mov    %esi,%eax
  802465:	f7 f1                	div    %ecx
  802467:	89 c6                	mov    %eax,%esi
  802469:	89 e8                	mov    %ebp,%eax
  80246b:	89 f7                	mov    %esi,%edi
  80246d:	f7 f1                	div    %ecx
  80246f:	89 fa                	mov    %edi,%edx
  802471:	83 c4 1c             	add    $0x1c,%esp
  802474:	5b                   	pop    %ebx
  802475:	5e                   	pop    %esi
  802476:	5f                   	pop    %edi
  802477:	5d                   	pop    %ebp
  802478:	c3                   	ret    
  802479:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802480:	89 f9                	mov    %edi,%ecx
  802482:	ba 20 00 00 00       	mov    $0x20,%edx
  802487:	29 fa                	sub    %edi,%edx
  802489:	d3 e0                	shl    %cl,%eax
  80248b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80248f:	89 d1                	mov    %edx,%ecx
  802491:	89 d8                	mov    %ebx,%eax
  802493:	d3 e8                	shr    %cl,%eax
  802495:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802499:	09 c1                	or     %eax,%ecx
  80249b:	89 f0                	mov    %esi,%eax
  80249d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024a1:	89 f9                	mov    %edi,%ecx
  8024a3:	d3 e3                	shl    %cl,%ebx
  8024a5:	89 d1                	mov    %edx,%ecx
  8024a7:	d3 e8                	shr    %cl,%eax
  8024a9:	89 f9                	mov    %edi,%ecx
  8024ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8024af:	89 eb                	mov    %ebp,%ebx
  8024b1:	d3 e6                	shl    %cl,%esi
  8024b3:	89 d1                	mov    %edx,%ecx
  8024b5:	d3 eb                	shr    %cl,%ebx
  8024b7:	09 f3                	or     %esi,%ebx
  8024b9:	89 c6                	mov    %eax,%esi
  8024bb:	89 f2                	mov    %esi,%edx
  8024bd:	89 d8                	mov    %ebx,%eax
  8024bf:	f7 74 24 08          	divl   0x8(%esp)
  8024c3:	89 d6                	mov    %edx,%esi
  8024c5:	89 c3                	mov    %eax,%ebx
  8024c7:	f7 64 24 0c          	mull   0xc(%esp)
  8024cb:	39 d6                	cmp    %edx,%esi
  8024cd:	72 19                	jb     8024e8 <__udivdi3+0x108>
  8024cf:	89 f9                	mov    %edi,%ecx
  8024d1:	d3 e5                	shl    %cl,%ebp
  8024d3:	39 c5                	cmp    %eax,%ebp
  8024d5:	73 04                	jae    8024db <__udivdi3+0xfb>
  8024d7:	39 d6                	cmp    %edx,%esi
  8024d9:	74 0d                	je     8024e8 <__udivdi3+0x108>
  8024db:	89 d8                	mov    %ebx,%eax
  8024dd:	31 ff                	xor    %edi,%edi
  8024df:	e9 3c ff ff ff       	jmp    802420 <__udivdi3+0x40>
  8024e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024e8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8024eb:	31 ff                	xor    %edi,%edi
  8024ed:	e9 2e ff ff ff       	jmp    802420 <__udivdi3+0x40>
  8024f2:	66 90                	xchg   %ax,%ax
  8024f4:	66 90                	xchg   %ax,%ax
  8024f6:	66 90                	xchg   %ax,%ax
  8024f8:	66 90                	xchg   %ax,%ax
  8024fa:	66 90                	xchg   %ax,%ax
  8024fc:	66 90                	xchg   %ax,%ax
  8024fe:	66 90                	xchg   %ax,%ax

00802500 <__umoddi3>:
  802500:	f3 0f 1e fb          	endbr32 
  802504:	55                   	push   %ebp
  802505:	57                   	push   %edi
  802506:	56                   	push   %esi
  802507:	53                   	push   %ebx
  802508:	83 ec 1c             	sub    $0x1c,%esp
  80250b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80250f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802513:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802517:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80251b:	89 f0                	mov    %esi,%eax
  80251d:	89 da                	mov    %ebx,%edx
  80251f:	85 ff                	test   %edi,%edi
  802521:	75 15                	jne    802538 <__umoddi3+0x38>
  802523:	39 dd                	cmp    %ebx,%ebp
  802525:	76 39                	jbe    802560 <__umoddi3+0x60>
  802527:	f7 f5                	div    %ebp
  802529:	89 d0                	mov    %edx,%eax
  80252b:	31 d2                	xor    %edx,%edx
  80252d:	83 c4 1c             	add    $0x1c,%esp
  802530:	5b                   	pop    %ebx
  802531:	5e                   	pop    %esi
  802532:	5f                   	pop    %edi
  802533:	5d                   	pop    %ebp
  802534:	c3                   	ret    
  802535:	8d 76 00             	lea    0x0(%esi),%esi
  802538:	39 df                	cmp    %ebx,%edi
  80253a:	77 f1                	ja     80252d <__umoddi3+0x2d>
  80253c:	0f bd cf             	bsr    %edi,%ecx
  80253f:	83 f1 1f             	xor    $0x1f,%ecx
  802542:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802546:	75 40                	jne    802588 <__umoddi3+0x88>
  802548:	39 df                	cmp    %ebx,%edi
  80254a:	72 04                	jb     802550 <__umoddi3+0x50>
  80254c:	39 f5                	cmp    %esi,%ebp
  80254e:	77 dd                	ja     80252d <__umoddi3+0x2d>
  802550:	89 da                	mov    %ebx,%edx
  802552:	89 f0                	mov    %esi,%eax
  802554:	29 e8                	sub    %ebp,%eax
  802556:	19 fa                	sbb    %edi,%edx
  802558:	eb d3                	jmp    80252d <__umoddi3+0x2d>
  80255a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802560:	89 e9                	mov    %ebp,%ecx
  802562:	85 ed                	test   %ebp,%ebp
  802564:	75 0b                	jne    802571 <__umoddi3+0x71>
  802566:	b8 01 00 00 00       	mov    $0x1,%eax
  80256b:	31 d2                	xor    %edx,%edx
  80256d:	f7 f5                	div    %ebp
  80256f:	89 c1                	mov    %eax,%ecx
  802571:	89 d8                	mov    %ebx,%eax
  802573:	31 d2                	xor    %edx,%edx
  802575:	f7 f1                	div    %ecx
  802577:	89 f0                	mov    %esi,%eax
  802579:	f7 f1                	div    %ecx
  80257b:	89 d0                	mov    %edx,%eax
  80257d:	31 d2                	xor    %edx,%edx
  80257f:	eb ac                	jmp    80252d <__umoddi3+0x2d>
  802581:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802588:	8b 44 24 04          	mov    0x4(%esp),%eax
  80258c:	ba 20 00 00 00       	mov    $0x20,%edx
  802591:	29 c2                	sub    %eax,%edx
  802593:	89 c1                	mov    %eax,%ecx
  802595:	89 e8                	mov    %ebp,%eax
  802597:	d3 e7                	shl    %cl,%edi
  802599:	89 d1                	mov    %edx,%ecx
  80259b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80259f:	d3 e8                	shr    %cl,%eax
  8025a1:	89 c1                	mov    %eax,%ecx
  8025a3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8025a7:	09 f9                	or     %edi,%ecx
  8025a9:	89 df                	mov    %ebx,%edi
  8025ab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025af:	89 c1                	mov    %eax,%ecx
  8025b1:	d3 e5                	shl    %cl,%ebp
  8025b3:	89 d1                	mov    %edx,%ecx
  8025b5:	d3 ef                	shr    %cl,%edi
  8025b7:	89 c1                	mov    %eax,%ecx
  8025b9:	89 f0                	mov    %esi,%eax
  8025bb:	d3 e3                	shl    %cl,%ebx
  8025bd:	89 d1                	mov    %edx,%ecx
  8025bf:	89 fa                	mov    %edi,%edx
  8025c1:	d3 e8                	shr    %cl,%eax
  8025c3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8025c8:	09 d8                	or     %ebx,%eax
  8025ca:	f7 74 24 08          	divl   0x8(%esp)
  8025ce:	89 d3                	mov    %edx,%ebx
  8025d0:	d3 e6                	shl    %cl,%esi
  8025d2:	f7 e5                	mul    %ebp
  8025d4:	89 c7                	mov    %eax,%edi
  8025d6:	89 d1                	mov    %edx,%ecx
  8025d8:	39 d3                	cmp    %edx,%ebx
  8025da:	72 06                	jb     8025e2 <__umoddi3+0xe2>
  8025dc:	75 0e                	jne    8025ec <__umoddi3+0xec>
  8025de:	39 c6                	cmp    %eax,%esi
  8025e0:	73 0a                	jae    8025ec <__umoddi3+0xec>
  8025e2:	29 e8                	sub    %ebp,%eax
  8025e4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8025e8:	89 d1                	mov    %edx,%ecx
  8025ea:	89 c7                	mov    %eax,%edi
  8025ec:	89 f5                	mov    %esi,%ebp
  8025ee:	8b 74 24 04          	mov    0x4(%esp),%esi
  8025f2:	29 fd                	sub    %edi,%ebp
  8025f4:	19 cb                	sbb    %ecx,%ebx
  8025f6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8025fb:	89 d8                	mov    %ebx,%eax
  8025fd:	d3 e0                	shl    %cl,%eax
  8025ff:	89 f1                	mov    %esi,%ecx
  802601:	d3 ed                	shr    %cl,%ebp
  802603:	d3 eb                	shr    %cl,%ebx
  802605:	09 e8                	or     %ebp,%eax
  802607:	89 da                	mov    %ebx,%edx
  802609:	83 c4 1c             	add    $0x1c,%esp
  80260c:	5b                   	pop    %ebx
  80260d:	5e                   	pop    %esi
  80260e:	5f                   	pop    %edi
  80260f:	5d                   	pop    %ebp
  802610:	c3                   	ret    
