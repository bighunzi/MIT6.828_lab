
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
  80003c:	e8 e2 0f 00 00       	call   801023 <sfork>
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
  800053:	e8 e5 0f 00 00       	call   80103d <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  800058:	8b 1d 04 40 80 00    	mov    0x804004,%ebx
  80005e:	8b 7b 48             	mov    0x48(%ebx),%edi
  800061:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800064:	a1 00 40 80 00       	mov    0x804000,%eax
  800069:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80006c:	e8 1f 0b 00 00       	call   800b90 <sys_getenvid>
  800071:	83 c4 08             	add    $0x8,%esp
  800074:	57                   	push   %edi
  800075:	53                   	push   %ebx
  800076:	56                   	push   %esi
  800077:	ff 75 d4             	push   -0x2c(%ebp)
  80007a:	50                   	push   %eax
  80007b:	68 70 21 80 00       	push   $0x802170
  800080:	e8 73 01 00 00       	call   8001f8 <cprintf>
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
  8000a3:	e8 fc 0f 00 00       	call   8010a4 <ipc_send>
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
  8000c2:	e8 c9 0a 00 00       	call   800b90 <sys_getenvid>
  8000c7:	83 ec 04             	sub    $0x4,%esp
  8000ca:	53                   	push   %ebx
  8000cb:	50                   	push   %eax
  8000cc:	68 40 21 80 00       	push   $0x802140
  8000d1:	e8 22 01 00 00       	call   8001f8 <cprintf>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000d6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8000d9:	e8 b2 0a 00 00       	call   800b90 <sys_getenvid>
  8000de:	83 c4 0c             	add    $0xc,%esp
  8000e1:	53                   	push   %ebx
  8000e2:	50                   	push   %eax
  8000e3:	68 5a 21 80 00       	push   $0x80215a
  8000e8:	e8 0b 01 00 00       	call   8001f8 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ed:	6a 00                	push   $0x0
  8000ef:	6a 00                	push   $0x0
  8000f1:	6a 00                	push   $0x0
  8000f3:	ff 75 e4             	push   -0x1c(%ebp)
  8000f6:	e8 a9 0f 00 00       	call   8010a4 <ipc_send>
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
  80010e:	e8 7d 0a 00 00       	call   800b90 <sys_getenvid>
  800113:	25 ff 03 00 00       	and    $0x3ff,%eax
  800118:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800120:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800125:	85 db                	test   %ebx,%ebx
  800127:	7e 07                	jle    800130 <libmain+0x2d>
		binaryname = argv[0];
  800129:	8b 06                	mov    (%esi),%eax
  80012b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800130:	83 ec 08             	sub    $0x8,%esp
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
  800135:	e8 f9 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80013a:	e8 0a 00 00 00       	call   800149 <exit>
}
  80013f:	83 c4 10             	add    $0x10,%esp
  800142:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800145:	5b                   	pop    %ebx
  800146:	5e                   	pop    %esi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80014f:	e8 a9 11 00 00       	call   8012fd <close_all>
	sys_env_destroy(0);
  800154:	83 ec 0c             	sub    $0xc,%esp
  800157:	6a 00                	push   $0x0
  800159:	e8 f1 09 00 00       	call   800b4f <sys_env_destroy>
}
  80015e:	83 c4 10             	add    $0x10,%esp
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	53                   	push   %ebx
  800167:	83 ec 04             	sub    $0x4,%esp
  80016a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80016d:	8b 13                	mov    (%ebx),%edx
  80016f:	8d 42 01             	lea    0x1(%edx),%eax
  800172:	89 03                	mov    %eax,(%ebx)
  800174:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800177:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80017b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800180:	74 09                	je     80018b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800182:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800186:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800189:	c9                   	leave  
  80018a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80018b:	83 ec 08             	sub    $0x8,%esp
  80018e:	68 ff 00 00 00       	push   $0xff
  800193:	8d 43 08             	lea    0x8(%ebx),%eax
  800196:	50                   	push   %eax
  800197:	e8 76 09 00 00       	call   800b12 <sys_cputs>
		b->idx = 0;
  80019c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001a2:	83 c4 10             	add    $0x10,%esp
  8001a5:	eb db                	jmp    800182 <putch+0x1f>

008001a7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001b0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b7:	00 00 00 
	b.cnt = 0;
  8001ba:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001c1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c4:	ff 75 0c             	push   0xc(%ebp)
  8001c7:	ff 75 08             	push   0x8(%ebp)
  8001ca:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d0:	50                   	push   %eax
  8001d1:	68 63 01 80 00       	push   $0x800163
  8001d6:	e8 14 01 00 00       	call   8002ef <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001db:	83 c4 08             	add    $0x8,%esp
  8001de:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001e4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ea:	50                   	push   %eax
  8001eb:	e8 22 09 00 00       	call   800b12 <sys_cputs>

	return b.cnt;
}
  8001f0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001f6:	c9                   	leave  
  8001f7:	c3                   	ret    

008001f8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001fe:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800201:	50                   	push   %eax
  800202:	ff 75 08             	push   0x8(%ebp)
  800205:	e8 9d ff ff ff       	call   8001a7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80020c:	55                   	push   %ebp
  80020d:	89 e5                	mov    %esp,%ebp
  80020f:	57                   	push   %edi
  800210:	56                   	push   %esi
  800211:	53                   	push   %ebx
  800212:	83 ec 1c             	sub    $0x1c,%esp
  800215:	89 c7                	mov    %eax,%edi
  800217:	89 d6                	mov    %edx,%esi
  800219:	8b 45 08             	mov    0x8(%ebp),%eax
  80021c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80021f:	89 d1                	mov    %edx,%ecx
  800221:	89 c2                	mov    %eax,%edx
  800223:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800226:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800229:	8b 45 10             	mov    0x10(%ebp),%eax
  80022c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80022f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800232:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800239:	39 c2                	cmp    %eax,%edx
  80023b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80023e:	72 3e                	jb     80027e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	ff 75 18             	push   0x18(%ebp)
  800246:	83 eb 01             	sub    $0x1,%ebx
  800249:	53                   	push   %ebx
  80024a:	50                   	push   %eax
  80024b:	83 ec 08             	sub    $0x8,%esp
  80024e:	ff 75 e4             	push   -0x1c(%ebp)
  800251:	ff 75 e0             	push   -0x20(%ebp)
  800254:	ff 75 dc             	push   -0x24(%ebp)
  800257:	ff 75 d8             	push   -0x28(%ebp)
  80025a:	e8 91 1c 00 00       	call   801ef0 <__udivdi3>
  80025f:	83 c4 18             	add    $0x18,%esp
  800262:	52                   	push   %edx
  800263:	50                   	push   %eax
  800264:	89 f2                	mov    %esi,%edx
  800266:	89 f8                	mov    %edi,%eax
  800268:	e8 9f ff ff ff       	call   80020c <printnum>
  80026d:	83 c4 20             	add    $0x20,%esp
  800270:	eb 13                	jmp    800285 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800272:	83 ec 08             	sub    $0x8,%esp
  800275:	56                   	push   %esi
  800276:	ff 75 18             	push   0x18(%ebp)
  800279:	ff d7                	call   *%edi
  80027b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80027e:	83 eb 01             	sub    $0x1,%ebx
  800281:	85 db                	test   %ebx,%ebx
  800283:	7f ed                	jg     800272 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800285:	83 ec 08             	sub    $0x8,%esp
  800288:	56                   	push   %esi
  800289:	83 ec 04             	sub    $0x4,%esp
  80028c:	ff 75 e4             	push   -0x1c(%ebp)
  80028f:	ff 75 e0             	push   -0x20(%ebp)
  800292:	ff 75 dc             	push   -0x24(%ebp)
  800295:	ff 75 d8             	push   -0x28(%ebp)
  800298:	e8 73 1d 00 00       	call   802010 <__umoddi3>
  80029d:	83 c4 14             	add    $0x14,%esp
  8002a0:	0f be 80 a0 21 80 00 	movsbl 0x8021a0(%eax),%eax
  8002a7:	50                   	push   %eax
  8002a8:	ff d7                	call   *%edi
}
  8002aa:	83 c4 10             	add    $0x10,%esp
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002bb:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bf:	8b 10                	mov    (%eax),%edx
  8002c1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c4:	73 0a                	jae    8002d0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c9:	89 08                	mov    %ecx,(%eax)
  8002cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ce:	88 02                	mov    %al,(%edx)
}
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <printfmt>:
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002db:	50                   	push   %eax
  8002dc:	ff 75 10             	push   0x10(%ebp)
  8002df:	ff 75 0c             	push   0xc(%ebp)
  8002e2:	ff 75 08             	push   0x8(%ebp)
  8002e5:	e8 05 00 00 00       	call   8002ef <vprintfmt>
}
  8002ea:	83 c4 10             	add    $0x10,%esp
  8002ed:	c9                   	leave  
  8002ee:	c3                   	ret    

008002ef <vprintfmt>:
{
  8002ef:	55                   	push   %ebp
  8002f0:	89 e5                	mov    %esp,%ebp
  8002f2:	57                   	push   %edi
  8002f3:	56                   	push   %esi
  8002f4:	53                   	push   %ebx
  8002f5:	83 ec 3c             	sub    $0x3c,%esp
  8002f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  800301:	eb 0a                	jmp    80030d <vprintfmt+0x1e>
			putch(ch, putdat);
  800303:	83 ec 08             	sub    $0x8,%esp
  800306:	53                   	push   %ebx
  800307:	50                   	push   %eax
  800308:	ff d6                	call   *%esi
  80030a:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80030d:	83 c7 01             	add    $0x1,%edi
  800310:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800314:	83 f8 25             	cmp    $0x25,%eax
  800317:	74 0c                	je     800325 <vprintfmt+0x36>
			if (ch == '\0')
  800319:	85 c0                	test   %eax,%eax
  80031b:	75 e6                	jne    800303 <vprintfmt+0x14>
}
  80031d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800320:	5b                   	pop    %ebx
  800321:	5e                   	pop    %esi
  800322:	5f                   	pop    %edi
  800323:	5d                   	pop    %ebp
  800324:	c3                   	ret    
		padc = ' ';
  800325:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800329:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800330:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800337:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80033e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800343:	8d 47 01             	lea    0x1(%edi),%eax
  800346:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800349:	0f b6 17             	movzbl (%edi),%edx
  80034c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80034f:	3c 55                	cmp    $0x55,%al
  800351:	0f 87 bb 03 00 00    	ja     800712 <vprintfmt+0x423>
  800357:	0f b6 c0             	movzbl %al,%eax
  80035a:	ff 24 85 e0 22 80 00 	jmp    *0x8022e0(,%eax,4)
  800361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800364:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800368:	eb d9                	jmp    800343 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80036d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800371:	eb d0                	jmp    800343 <vprintfmt+0x54>
  800373:	0f b6 d2             	movzbl %dl,%edx
  800376:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800379:	b8 00 00 00 00       	mov    $0x0,%eax
  80037e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800381:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800384:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800388:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80038b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80038e:	83 f9 09             	cmp    $0x9,%ecx
  800391:	77 55                	ja     8003e8 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800393:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800396:	eb e9                	jmp    800381 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800398:	8b 45 14             	mov    0x14(%ebp),%eax
  80039b:	8b 00                	mov    (%eax),%eax
  80039d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a3:	8d 40 04             	lea    0x4(%eax),%eax
  8003a6:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003ac:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003b0:	79 91                	jns    800343 <vprintfmt+0x54>
				width = precision, precision = -1;
  8003b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003b5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003b8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003bf:	eb 82                	jmp    800343 <vprintfmt+0x54>
  8003c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003c4:	85 d2                	test   %edx,%edx
  8003c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cb:	0f 49 c2             	cmovns %edx,%eax
  8003ce:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003d4:	e9 6a ff ff ff       	jmp    800343 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003dc:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003e3:	e9 5b ff ff ff       	jmp    800343 <vprintfmt+0x54>
  8003e8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003eb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ee:	eb bc                	jmp    8003ac <vprintfmt+0xbd>
			lflag++;
  8003f0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f6:	e9 48 ff ff ff       	jmp    800343 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fe:	8d 78 04             	lea    0x4(%eax),%edi
  800401:	83 ec 08             	sub    $0x8,%esp
  800404:	53                   	push   %ebx
  800405:	ff 30                	push   (%eax)
  800407:	ff d6                	call   *%esi
			break;
  800409:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80040c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80040f:	e9 9d 02 00 00       	jmp    8006b1 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800414:	8b 45 14             	mov    0x14(%ebp),%eax
  800417:	8d 78 04             	lea    0x4(%eax),%edi
  80041a:	8b 10                	mov    (%eax),%edx
  80041c:	89 d0                	mov    %edx,%eax
  80041e:	f7 d8                	neg    %eax
  800420:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800423:	83 f8 0f             	cmp    $0xf,%eax
  800426:	7f 23                	jg     80044b <vprintfmt+0x15c>
  800428:	8b 14 85 40 24 80 00 	mov    0x802440(,%eax,4),%edx
  80042f:	85 d2                	test   %edx,%edx
  800431:	74 18                	je     80044b <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800433:	52                   	push   %edx
  800434:	68 5d 26 80 00       	push   $0x80265d
  800439:	53                   	push   %ebx
  80043a:	56                   	push   %esi
  80043b:	e8 92 fe ff ff       	call   8002d2 <printfmt>
  800440:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800443:	89 7d 14             	mov    %edi,0x14(%ebp)
  800446:	e9 66 02 00 00       	jmp    8006b1 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80044b:	50                   	push   %eax
  80044c:	68 b8 21 80 00       	push   $0x8021b8
  800451:	53                   	push   %ebx
  800452:	56                   	push   %esi
  800453:	e8 7a fe ff ff       	call   8002d2 <printfmt>
  800458:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80045b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80045e:	e9 4e 02 00 00       	jmp    8006b1 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800463:	8b 45 14             	mov    0x14(%ebp),%eax
  800466:	83 c0 04             	add    $0x4,%eax
  800469:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80046c:	8b 45 14             	mov    0x14(%ebp),%eax
  80046f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800471:	85 d2                	test   %edx,%edx
  800473:	b8 b1 21 80 00       	mov    $0x8021b1,%eax
  800478:	0f 45 c2             	cmovne %edx,%eax
  80047b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80047e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800482:	7e 06                	jle    80048a <vprintfmt+0x19b>
  800484:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800488:	75 0d                	jne    800497 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80048a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80048d:	89 c7                	mov    %eax,%edi
  80048f:	03 45 e0             	add    -0x20(%ebp),%eax
  800492:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800495:	eb 55                	jmp    8004ec <vprintfmt+0x1fd>
  800497:	83 ec 08             	sub    $0x8,%esp
  80049a:	ff 75 d8             	push   -0x28(%ebp)
  80049d:	ff 75 cc             	push   -0x34(%ebp)
  8004a0:	e8 0a 03 00 00       	call   8007af <strnlen>
  8004a5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a8:	29 c1                	sub    %eax,%ecx
  8004aa:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004ad:	83 c4 10             	add    $0x10,%esp
  8004b0:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004b2:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004b9:	eb 0f                	jmp    8004ca <vprintfmt+0x1db>
					putch(padc, putdat);
  8004bb:	83 ec 08             	sub    $0x8,%esp
  8004be:	53                   	push   %ebx
  8004bf:	ff 75 e0             	push   -0x20(%ebp)
  8004c2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c4:	83 ef 01             	sub    $0x1,%edi
  8004c7:	83 c4 10             	add    $0x10,%esp
  8004ca:	85 ff                	test   %edi,%edi
  8004cc:	7f ed                	jg     8004bb <vprintfmt+0x1cc>
  8004ce:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004d1:	85 d2                	test   %edx,%edx
  8004d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d8:	0f 49 c2             	cmovns %edx,%eax
  8004db:	29 c2                	sub    %eax,%edx
  8004dd:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004e0:	eb a8                	jmp    80048a <vprintfmt+0x19b>
					putch(ch, putdat);
  8004e2:	83 ec 08             	sub    $0x8,%esp
  8004e5:	53                   	push   %ebx
  8004e6:	52                   	push   %edx
  8004e7:	ff d6                	call   *%esi
  8004e9:	83 c4 10             	add    $0x10,%esp
  8004ec:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ef:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004f1:	83 c7 01             	add    $0x1,%edi
  8004f4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f8:	0f be d0             	movsbl %al,%edx
  8004fb:	85 d2                	test   %edx,%edx
  8004fd:	74 4b                	je     80054a <vprintfmt+0x25b>
  8004ff:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800503:	78 06                	js     80050b <vprintfmt+0x21c>
  800505:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800509:	78 1e                	js     800529 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80050b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80050f:	74 d1                	je     8004e2 <vprintfmt+0x1f3>
  800511:	0f be c0             	movsbl %al,%eax
  800514:	83 e8 20             	sub    $0x20,%eax
  800517:	83 f8 5e             	cmp    $0x5e,%eax
  80051a:	76 c6                	jbe    8004e2 <vprintfmt+0x1f3>
					putch('?', putdat);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	53                   	push   %ebx
  800520:	6a 3f                	push   $0x3f
  800522:	ff d6                	call   *%esi
  800524:	83 c4 10             	add    $0x10,%esp
  800527:	eb c3                	jmp    8004ec <vprintfmt+0x1fd>
  800529:	89 cf                	mov    %ecx,%edi
  80052b:	eb 0e                	jmp    80053b <vprintfmt+0x24c>
				putch(' ', putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	53                   	push   %ebx
  800531:	6a 20                	push   $0x20
  800533:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800535:	83 ef 01             	sub    $0x1,%edi
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	85 ff                	test   %edi,%edi
  80053d:	7f ee                	jg     80052d <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80053f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800542:	89 45 14             	mov    %eax,0x14(%ebp)
  800545:	e9 67 01 00 00       	jmp    8006b1 <vprintfmt+0x3c2>
  80054a:	89 cf                	mov    %ecx,%edi
  80054c:	eb ed                	jmp    80053b <vprintfmt+0x24c>
	if (lflag >= 2)
  80054e:	83 f9 01             	cmp    $0x1,%ecx
  800551:	7f 1b                	jg     80056e <vprintfmt+0x27f>
	else if (lflag)
  800553:	85 c9                	test   %ecx,%ecx
  800555:	74 63                	je     8005ba <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8b 00                	mov    (%eax),%eax
  80055c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055f:	99                   	cltd   
  800560:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800563:	8b 45 14             	mov    0x14(%ebp),%eax
  800566:	8d 40 04             	lea    0x4(%eax),%eax
  800569:	89 45 14             	mov    %eax,0x14(%ebp)
  80056c:	eb 17                	jmp    800585 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80056e:	8b 45 14             	mov    0x14(%ebp),%eax
  800571:	8b 50 04             	mov    0x4(%eax),%edx
  800574:	8b 00                	mov    (%eax),%eax
  800576:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800579:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8d 40 08             	lea    0x8(%eax),%eax
  800582:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800585:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800588:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80058b:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800590:	85 c9                	test   %ecx,%ecx
  800592:	0f 89 ff 00 00 00    	jns    800697 <vprintfmt+0x3a8>
				putch('-', putdat);
  800598:	83 ec 08             	sub    $0x8,%esp
  80059b:	53                   	push   %ebx
  80059c:	6a 2d                	push   $0x2d
  80059e:	ff d6                	call   *%esi
				num = -(long long) num;
  8005a0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005a6:	f7 da                	neg    %edx
  8005a8:	83 d1 00             	adc    $0x0,%ecx
  8005ab:	f7 d9                	neg    %ecx
  8005ad:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005b0:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005b5:	e9 dd 00 00 00       	jmp    800697 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bd:	8b 00                	mov    (%eax),%eax
  8005bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c2:	99                   	cltd   
  8005c3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 40 04             	lea    0x4(%eax),%eax
  8005cc:	89 45 14             	mov    %eax,0x14(%ebp)
  8005cf:	eb b4                	jmp    800585 <vprintfmt+0x296>
	if (lflag >= 2)
  8005d1:	83 f9 01             	cmp    $0x1,%ecx
  8005d4:	7f 1e                	jg     8005f4 <vprintfmt+0x305>
	else if (lflag)
  8005d6:	85 c9                	test   %ecx,%ecx
  8005d8:	74 32                	je     80060c <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8005da:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dd:	8b 10                	mov    (%eax),%edx
  8005df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e4:	8d 40 04             	lea    0x4(%eax),%eax
  8005e7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ea:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8005ef:	e9 a3 00 00 00       	jmp    800697 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8b 10                	mov    (%eax),%edx
  8005f9:	8b 48 04             	mov    0x4(%eax),%ecx
  8005fc:	8d 40 08             	lea    0x8(%eax),%eax
  8005ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800602:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800607:	e9 8b 00 00 00       	jmp    800697 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8b 10                	mov    (%eax),%edx
  800611:	b9 00 00 00 00       	mov    $0x0,%ecx
  800616:	8d 40 04             	lea    0x4(%eax),%eax
  800619:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80061c:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800621:	eb 74                	jmp    800697 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800623:	83 f9 01             	cmp    $0x1,%ecx
  800626:	7f 1b                	jg     800643 <vprintfmt+0x354>
	else if (lflag)
  800628:	85 c9                	test   %ecx,%ecx
  80062a:	74 2c                	je     800658 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80062c:	8b 45 14             	mov    0x14(%ebp),%eax
  80062f:	8b 10                	mov    (%eax),%edx
  800631:	b9 00 00 00 00       	mov    $0x0,%ecx
  800636:	8d 40 04             	lea    0x4(%eax),%eax
  800639:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80063c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800641:	eb 54                	jmp    800697 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8b 10                	mov    (%eax),%edx
  800648:	8b 48 04             	mov    0x4(%eax),%ecx
  80064b:	8d 40 08             	lea    0x8(%eax),%eax
  80064e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800651:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800656:	eb 3f                	jmp    800697 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8b 10                	mov    (%eax),%edx
  80065d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800662:	8d 40 04             	lea    0x4(%eax),%eax
  800665:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800668:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80066d:	eb 28                	jmp    800697 <vprintfmt+0x3a8>
			putch('0', putdat);
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	6a 30                	push   $0x30
  800675:	ff d6                	call   *%esi
			putch('x', putdat);
  800677:	83 c4 08             	add    $0x8,%esp
  80067a:	53                   	push   %ebx
  80067b:	6a 78                	push   $0x78
  80067d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8b 10                	mov    (%eax),%edx
  800684:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800689:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80068c:	8d 40 04             	lea    0x4(%eax),%eax
  80068f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800692:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800697:	83 ec 0c             	sub    $0xc,%esp
  80069a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80069e:	50                   	push   %eax
  80069f:	ff 75 e0             	push   -0x20(%ebp)
  8006a2:	57                   	push   %edi
  8006a3:	51                   	push   %ecx
  8006a4:	52                   	push   %edx
  8006a5:	89 da                	mov    %ebx,%edx
  8006a7:	89 f0                	mov    %esi,%eax
  8006a9:	e8 5e fb ff ff       	call   80020c <printnum>
			break;
  8006ae:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006b4:	e9 54 fc ff ff       	jmp    80030d <vprintfmt+0x1e>
	if (lflag >= 2)
  8006b9:	83 f9 01             	cmp    $0x1,%ecx
  8006bc:	7f 1b                	jg     8006d9 <vprintfmt+0x3ea>
	else if (lflag)
  8006be:	85 c9                	test   %ecx,%ecx
  8006c0:	74 2c                	je     8006ee <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8b 10                	mov    (%eax),%edx
  8006c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006cc:	8d 40 04             	lea    0x4(%eax),%eax
  8006cf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006d2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8006d7:	eb be                	jmp    800697 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dc:	8b 10                	mov    (%eax),%edx
  8006de:	8b 48 04             	mov    0x4(%eax),%ecx
  8006e1:	8d 40 08             	lea    0x8(%eax),%eax
  8006e4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e7:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8006ec:	eb a9                	jmp    800697 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8b 10                	mov    (%eax),%edx
  8006f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f8:	8d 40 04             	lea    0x4(%eax),%eax
  8006fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006fe:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800703:	eb 92                	jmp    800697 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800705:	83 ec 08             	sub    $0x8,%esp
  800708:	53                   	push   %ebx
  800709:	6a 25                	push   $0x25
  80070b:	ff d6                	call   *%esi
			break;
  80070d:	83 c4 10             	add    $0x10,%esp
  800710:	eb 9f                	jmp    8006b1 <vprintfmt+0x3c2>
			putch('%', putdat);
  800712:	83 ec 08             	sub    $0x8,%esp
  800715:	53                   	push   %ebx
  800716:	6a 25                	push   $0x25
  800718:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071a:	83 c4 10             	add    $0x10,%esp
  80071d:	89 f8                	mov    %edi,%eax
  80071f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800723:	74 05                	je     80072a <vprintfmt+0x43b>
  800725:	83 e8 01             	sub    $0x1,%eax
  800728:	eb f5                	jmp    80071f <vprintfmt+0x430>
  80072a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80072d:	eb 82                	jmp    8006b1 <vprintfmt+0x3c2>

0080072f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80072f:	55                   	push   %ebp
  800730:	89 e5                	mov    %esp,%ebp
  800732:	83 ec 18             	sub    $0x18,%esp
  800735:	8b 45 08             	mov    0x8(%ebp),%eax
  800738:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80073b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800742:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800745:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80074c:	85 c0                	test   %eax,%eax
  80074e:	74 26                	je     800776 <vsnprintf+0x47>
  800750:	85 d2                	test   %edx,%edx
  800752:	7e 22                	jle    800776 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800754:	ff 75 14             	push   0x14(%ebp)
  800757:	ff 75 10             	push   0x10(%ebp)
  80075a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80075d:	50                   	push   %eax
  80075e:	68 b5 02 80 00       	push   $0x8002b5
  800763:	e8 87 fb ff ff       	call   8002ef <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800768:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80076e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800771:	83 c4 10             	add    $0x10,%esp
}
  800774:	c9                   	leave  
  800775:	c3                   	ret    
		return -E_INVAL;
  800776:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077b:	eb f7                	jmp    800774 <vsnprintf+0x45>

0080077d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80077d:	55                   	push   %ebp
  80077e:	89 e5                	mov    %esp,%ebp
  800780:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800783:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800786:	50                   	push   %eax
  800787:	ff 75 10             	push   0x10(%ebp)
  80078a:	ff 75 0c             	push   0xc(%ebp)
  80078d:	ff 75 08             	push   0x8(%ebp)
  800790:	e8 9a ff ff ff       	call   80072f <vsnprintf>
	va_end(ap);

	return rc;
}
  800795:	c9                   	leave  
  800796:	c3                   	ret    

00800797 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80079d:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a2:	eb 03                	jmp    8007a7 <strlen+0x10>
		n++;
  8007a4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007a7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007ab:	75 f7                	jne    8007a4 <strlen+0xd>
	return n;
}
  8007ad:	5d                   	pop    %ebp
  8007ae:	c3                   	ret    

008007af <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007b8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007bd:	eb 03                	jmp    8007c2 <strnlen+0x13>
		n++;
  8007bf:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c2:	39 d0                	cmp    %edx,%eax
  8007c4:	74 08                	je     8007ce <strnlen+0x1f>
  8007c6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ca:	75 f3                	jne    8007bf <strnlen+0x10>
  8007cc:	89 c2                	mov    %eax,%edx
	return n;
}
  8007ce:	89 d0                	mov    %edx,%eax
  8007d0:	5d                   	pop    %ebp
  8007d1:	c3                   	ret    

008007d2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	53                   	push   %ebx
  8007d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007e5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007e8:	83 c0 01             	add    $0x1,%eax
  8007eb:	84 d2                	test   %dl,%dl
  8007ed:	75 f2                	jne    8007e1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007ef:	89 c8                	mov    %ecx,%eax
  8007f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f4:	c9                   	leave  
  8007f5:	c3                   	ret    

008007f6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	53                   	push   %ebx
  8007fa:	83 ec 10             	sub    $0x10,%esp
  8007fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800800:	53                   	push   %ebx
  800801:	e8 91 ff ff ff       	call   800797 <strlen>
  800806:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800809:	ff 75 0c             	push   0xc(%ebp)
  80080c:	01 d8                	add    %ebx,%eax
  80080e:	50                   	push   %eax
  80080f:	e8 be ff ff ff       	call   8007d2 <strcpy>
	return dst;
}
  800814:	89 d8                	mov    %ebx,%eax
  800816:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800819:	c9                   	leave  
  80081a:	c3                   	ret    

0080081b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	56                   	push   %esi
  80081f:	53                   	push   %ebx
  800820:	8b 75 08             	mov    0x8(%ebp),%esi
  800823:	8b 55 0c             	mov    0xc(%ebp),%edx
  800826:	89 f3                	mov    %esi,%ebx
  800828:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80082b:	89 f0                	mov    %esi,%eax
  80082d:	eb 0f                	jmp    80083e <strncpy+0x23>
		*dst++ = *src;
  80082f:	83 c0 01             	add    $0x1,%eax
  800832:	0f b6 0a             	movzbl (%edx),%ecx
  800835:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800838:	80 f9 01             	cmp    $0x1,%cl
  80083b:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80083e:	39 d8                	cmp    %ebx,%eax
  800840:	75 ed                	jne    80082f <strncpy+0x14>
	}
	return ret;
}
  800842:	89 f0                	mov    %esi,%eax
  800844:	5b                   	pop    %ebx
  800845:	5e                   	pop    %esi
  800846:	5d                   	pop    %ebp
  800847:	c3                   	ret    

00800848 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	56                   	push   %esi
  80084c:	53                   	push   %ebx
  80084d:	8b 75 08             	mov    0x8(%ebp),%esi
  800850:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800853:	8b 55 10             	mov    0x10(%ebp),%edx
  800856:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800858:	85 d2                	test   %edx,%edx
  80085a:	74 21                	je     80087d <strlcpy+0x35>
  80085c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800860:	89 f2                	mov    %esi,%edx
  800862:	eb 09                	jmp    80086d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800864:	83 c1 01             	add    $0x1,%ecx
  800867:	83 c2 01             	add    $0x1,%edx
  80086a:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80086d:	39 c2                	cmp    %eax,%edx
  80086f:	74 09                	je     80087a <strlcpy+0x32>
  800871:	0f b6 19             	movzbl (%ecx),%ebx
  800874:	84 db                	test   %bl,%bl
  800876:	75 ec                	jne    800864 <strlcpy+0x1c>
  800878:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80087a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80087d:	29 f0                	sub    %esi,%eax
}
  80087f:	5b                   	pop    %ebx
  800880:	5e                   	pop    %esi
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    

00800883 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800889:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80088c:	eb 06                	jmp    800894 <strcmp+0x11>
		p++, q++;
  80088e:	83 c1 01             	add    $0x1,%ecx
  800891:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800894:	0f b6 01             	movzbl (%ecx),%eax
  800897:	84 c0                	test   %al,%al
  800899:	74 04                	je     80089f <strcmp+0x1c>
  80089b:	3a 02                	cmp    (%edx),%al
  80089d:	74 ef                	je     80088e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80089f:	0f b6 c0             	movzbl %al,%eax
  8008a2:	0f b6 12             	movzbl (%edx),%edx
  8008a5:	29 d0                	sub    %edx,%eax
}
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	53                   	push   %ebx
  8008ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b3:	89 c3                	mov    %eax,%ebx
  8008b5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008b8:	eb 06                	jmp    8008c0 <strncmp+0x17>
		n--, p++, q++;
  8008ba:	83 c0 01             	add    $0x1,%eax
  8008bd:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008c0:	39 d8                	cmp    %ebx,%eax
  8008c2:	74 18                	je     8008dc <strncmp+0x33>
  8008c4:	0f b6 08             	movzbl (%eax),%ecx
  8008c7:	84 c9                	test   %cl,%cl
  8008c9:	74 04                	je     8008cf <strncmp+0x26>
  8008cb:	3a 0a                	cmp    (%edx),%cl
  8008cd:	74 eb                	je     8008ba <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008cf:	0f b6 00             	movzbl (%eax),%eax
  8008d2:	0f b6 12             	movzbl (%edx),%edx
  8008d5:	29 d0                	sub    %edx,%eax
}
  8008d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008da:	c9                   	leave  
  8008db:	c3                   	ret    
		return 0;
  8008dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e1:	eb f4                	jmp    8008d7 <strncmp+0x2e>

008008e3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008e3:	55                   	push   %ebp
  8008e4:	89 e5                	mov    %esp,%ebp
  8008e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ed:	eb 03                	jmp    8008f2 <strchr+0xf>
  8008ef:	83 c0 01             	add    $0x1,%eax
  8008f2:	0f b6 10             	movzbl (%eax),%edx
  8008f5:	84 d2                	test   %dl,%dl
  8008f7:	74 06                	je     8008ff <strchr+0x1c>
		if (*s == c)
  8008f9:	38 ca                	cmp    %cl,%dl
  8008fb:	75 f2                	jne    8008ef <strchr+0xc>
  8008fd:	eb 05                	jmp    800904 <strchr+0x21>
			return (char *) s;
	return 0;
  8008ff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	8b 45 08             	mov    0x8(%ebp),%eax
  80090c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800910:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800913:	38 ca                	cmp    %cl,%dl
  800915:	74 09                	je     800920 <strfind+0x1a>
  800917:	84 d2                	test   %dl,%dl
  800919:	74 05                	je     800920 <strfind+0x1a>
	for (; *s; s++)
  80091b:	83 c0 01             	add    $0x1,%eax
  80091e:	eb f0                	jmp    800910 <strfind+0xa>
			break;
	return (char *) s;
}
  800920:	5d                   	pop    %ebp
  800921:	c3                   	ret    

00800922 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	57                   	push   %edi
  800926:	56                   	push   %esi
  800927:	53                   	push   %ebx
  800928:	8b 7d 08             	mov    0x8(%ebp),%edi
  80092b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80092e:	85 c9                	test   %ecx,%ecx
  800930:	74 2f                	je     800961 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800932:	89 f8                	mov    %edi,%eax
  800934:	09 c8                	or     %ecx,%eax
  800936:	a8 03                	test   $0x3,%al
  800938:	75 21                	jne    80095b <memset+0x39>
		c &= 0xFF;
  80093a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80093e:	89 d0                	mov    %edx,%eax
  800940:	c1 e0 08             	shl    $0x8,%eax
  800943:	89 d3                	mov    %edx,%ebx
  800945:	c1 e3 18             	shl    $0x18,%ebx
  800948:	89 d6                	mov    %edx,%esi
  80094a:	c1 e6 10             	shl    $0x10,%esi
  80094d:	09 f3                	or     %esi,%ebx
  80094f:	09 da                	or     %ebx,%edx
  800951:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800953:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800956:	fc                   	cld    
  800957:	f3 ab                	rep stos %eax,%es:(%edi)
  800959:	eb 06                	jmp    800961 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80095b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095e:	fc                   	cld    
  80095f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800961:	89 f8                	mov    %edi,%eax
  800963:	5b                   	pop    %ebx
  800964:	5e                   	pop    %esi
  800965:	5f                   	pop    %edi
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    

00800968 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	57                   	push   %edi
  80096c:	56                   	push   %esi
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 75 0c             	mov    0xc(%ebp),%esi
  800973:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800976:	39 c6                	cmp    %eax,%esi
  800978:	73 32                	jae    8009ac <memmove+0x44>
  80097a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80097d:	39 c2                	cmp    %eax,%edx
  80097f:	76 2b                	jbe    8009ac <memmove+0x44>
		s += n;
		d += n;
  800981:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800984:	89 d6                	mov    %edx,%esi
  800986:	09 fe                	or     %edi,%esi
  800988:	09 ce                	or     %ecx,%esi
  80098a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800990:	75 0e                	jne    8009a0 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800992:	83 ef 04             	sub    $0x4,%edi
  800995:	8d 72 fc             	lea    -0x4(%edx),%esi
  800998:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80099b:	fd                   	std    
  80099c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099e:	eb 09                	jmp    8009a9 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009a0:	83 ef 01             	sub    $0x1,%edi
  8009a3:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009a6:	fd                   	std    
  8009a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a9:	fc                   	cld    
  8009aa:	eb 1a                	jmp    8009c6 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ac:	89 f2                	mov    %esi,%edx
  8009ae:	09 c2                	or     %eax,%edx
  8009b0:	09 ca                	or     %ecx,%edx
  8009b2:	f6 c2 03             	test   $0x3,%dl
  8009b5:	75 0a                	jne    8009c1 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009b7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009ba:	89 c7                	mov    %eax,%edi
  8009bc:	fc                   	cld    
  8009bd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009bf:	eb 05                	jmp    8009c6 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009c1:	89 c7                	mov    %eax,%edi
  8009c3:	fc                   	cld    
  8009c4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009c6:	5e                   	pop    %esi
  8009c7:	5f                   	pop    %edi
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ca:	55                   	push   %ebp
  8009cb:	89 e5                	mov    %esp,%ebp
  8009cd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009d0:	ff 75 10             	push   0x10(%ebp)
  8009d3:	ff 75 0c             	push   0xc(%ebp)
  8009d6:	ff 75 08             	push   0x8(%ebp)
  8009d9:	e8 8a ff ff ff       	call   800968 <memmove>
}
  8009de:	c9                   	leave  
  8009df:	c3                   	ret    

008009e0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009eb:	89 c6                	mov    %eax,%esi
  8009ed:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f0:	eb 06                	jmp    8009f8 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009f2:	83 c0 01             	add    $0x1,%eax
  8009f5:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009f8:	39 f0                	cmp    %esi,%eax
  8009fa:	74 14                	je     800a10 <memcmp+0x30>
		if (*s1 != *s2)
  8009fc:	0f b6 08             	movzbl (%eax),%ecx
  8009ff:	0f b6 1a             	movzbl (%edx),%ebx
  800a02:	38 d9                	cmp    %bl,%cl
  800a04:	74 ec                	je     8009f2 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a06:	0f b6 c1             	movzbl %cl,%eax
  800a09:	0f b6 db             	movzbl %bl,%ebx
  800a0c:	29 d8                	sub    %ebx,%eax
  800a0e:	eb 05                	jmp    800a15 <memcmp+0x35>
	}

	return 0;
  800a10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a15:	5b                   	pop    %ebx
  800a16:	5e                   	pop    %esi
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a22:	89 c2                	mov    %eax,%edx
  800a24:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a27:	eb 03                	jmp    800a2c <memfind+0x13>
  800a29:	83 c0 01             	add    $0x1,%eax
  800a2c:	39 d0                	cmp    %edx,%eax
  800a2e:	73 04                	jae    800a34 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a30:	38 08                	cmp    %cl,(%eax)
  800a32:	75 f5                	jne    800a29 <memfind+0x10>
			break;
	return (void *) s;
}
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	57                   	push   %edi
  800a3a:	56                   	push   %esi
  800a3b:	53                   	push   %ebx
  800a3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a42:	eb 03                	jmp    800a47 <strtol+0x11>
		s++;
  800a44:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a47:	0f b6 02             	movzbl (%edx),%eax
  800a4a:	3c 20                	cmp    $0x20,%al
  800a4c:	74 f6                	je     800a44 <strtol+0xe>
  800a4e:	3c 09                	cmp    $0x9,%al
  800a50:	74 f2                	je     800a44 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a52:	3c 2b                	cmp    $0x2b,%al
  800a54:	74 2a                	je     800a80 <strtol+0x4a>
	int neg = 0;
  800a56:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a5b:	3c 2d                	cmp    $0x2d,%al
  800a5d:	74 2b                	je     800a8a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a65:	75 0f                	jne    800a76 <strtol+0x40>
  800a67:	80 3a 30             	cmpb   $0x30,(%edx)
  800a6a:	74 28                	je     800a94 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a6c:	85 db                	test   %ebx,%ebx
  800a6e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a73:	0f 44 d8             	cmove  %eax,%ebx
  800a76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a7b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a7e:	eb 46                	jmp    800ac6 <strtol+0x90>
		s++;
  800a80:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a83:	bf 00 00 00 00       	mov    $0x0,%edi
  800a88:	eb d5                	jmp    800a5f <strtol+0x29>
		s++, neg = 1;
  800a8a:	83 c2 01             	add    $0x1,%edx
  800a8d:	bf 01 00 00 00       	mov    $0x1,%edi
  800a92:	eb cb                	jmp    800a5f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a94:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a98:	74 0e                	je     800aa8 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a9a:	85 db                	test   %ebx,%ebx
  800a9c:	75 d8                	jne    800a76 <strtol+0x40>
		s++, base = 8;
  800a9e:	83 c2 01             	add    $0x1,%edx
  800aa1:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aa6:	eb ce                	jmp    800a76 <strtol+0x40>
		s += 2, base = 16;
  800aa8:	83 c2 02             	add    $0x2,%edx
  800aab:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab0:	eb c4                	jmp    800a76 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ab2:	0f be c0             	movsbl %al,%eax
  800ab5:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ab8:	3b 45 10             	cmp    0x10(%ebp),%eax
  800abb:	7d 3a                	jge    800af7 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800abd:	83 c2 01             	add    $0x1,%edx
  800ac0:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ac4:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ac6:	0f b6 02             	movzbl (%edx),%eax
  800ac9:	8d 70 d0             	lea    -0x30(%eax),%esi
  800acc:	89 f3                	mov    %esi,%ebx
  800ace:	80 fb 09             	cmp    $0x9,%bl
  800ad1:	76 df                	jbe    800ab2 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ad3:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ad6:	89 f3                	mov    %esi,%ebx
  800ad8:	80 fb 19             	cmp    $0x19,%bl
  800adb:	77 08                	ja     800ae5 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800add:	0f be c0             	movsbl %al,%eax
  800ae0:	83 e8 57             	sub    $0x57,%eax
  800ae3:	eb d3                	jmp    800ab8 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800ae5:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ae8:	89 f3                	mov    %esi,%ebx
  800aea:	80 fb 19             	cmp    $0x19,%bl
  800aed:	77 08                	ja     800af7 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800aef:	0f be c0             	movsbl %al,%eax
  800af2:	83 e8 37             	sub    $0x37,%eax
  800af5:	eb c1                	jmp    800ab8 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800af7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800afb:	74 05                	je     800b02 <strtol+0xcc>
		*endptr = (char *) s;
  800afd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b00:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b02:	89 c8                	mov    %ecx,%eax
  800b04:	f7 d8                	neg    %eax
  800b06:	85 ff                	test   %edi,%edi
  800b08:	0f 45 c8             	cmovne %eax,%ecx
}
  800b0b:	89 c8                	mov    %ecx,%eax
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5f                   	pop    %edi
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	57                   	push   %edi
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b18:	b8 00 00 00 00       	mov    $0x0,%eax
  800b1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b23:	89 c3                	mov    %eax,%ebx
  800b25:	89 c7                	mov    %eax,%edi
  800b27:	89 c6                	mov    %eax,%esi
  800b29:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b36:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b40:	89 d1                	mov    %edx,%ecx
  800b42:	89 d3                	mov    %edx,%ebx
  800b44:	89 d7                	mov    %edx,%edi
  800b46:	89 d6                	mov    %edx,%esi
  800b48:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b4a:	5b                   	pop    %ebx
  800b4b:	5e                   	pop    %esi
  800b4c:	5f                   	pop    %edi
  800b4d:	5d                   	pop    %ebp
  800b4e:	c3                   	ret    

00800b4f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	53                   	push   %ebx
  800b55:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b58:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b5d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b60:	b8 03 00 00 00       	mov    $0x3,%eax
  800b65:	89 cb                	mov    %ecx,%ebx
  800b67:	89 cf                	mov    %ecx,%edi
  800b69:	89 ce                	mov    %ecx,%esi
  800b6b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b6d:	85 c0                	test   %eax,%eax
  800b6f:	7f 08                	jg     800b79 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b74:	5b                   	pop    %ebx
  800b75:	5e                   	pop    %esi
  800b76:	5f                   	pop    %edi
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b79:	83 ec 0c             	sub    $0xc,%esp
  800b7c:	50                   	push   %eax
  800b7d:	6a 03                	push   $0x3
  800b7f:	68 9f 24 80 00       	push   $0x80249f
  800b84:	6a 2a                	push   $0x2a
  800b86:	68 bc 24 80 00       	push   $0x8024bc
  800b8b:	e8 42 12 00 00       	call   801dd2 <_panic>

00800b90 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b96:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9b:	b8 02 00 00 00       	mov    $0x2,%eax
  800ba0:	89 d1                	mov    %edx,%ecx
  800ba2:	89 d3                	mov    %edx,%ebx
  800ba4:	89 d7                	mov    %edx,%edi
  800ba6:	89 d6                	mov    %edx,%esi
  800ba8:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_yield>:

void
sys_yield(void)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bba:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bbf:	89 d1                	mov    %edx,%ecx
  800bc1:	89 d3                	mov    %edx,%ebx
  800bc3:	89 d7                	mov    %edx,%edi
  800bc5:	89 d6                	mov    %edx,%esi
  800bc7:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bc9:	5b                   	pop    %ebx
  800bca:	5e                   	pop    %esi
  800bcb:	5f                   	pop    %edi
  800bcc:	5d                   	pop    %ebp
  800bcd:	c3                   	ret    

00800bce <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bce:	55                   	push   %ebp
  800bcf:	89 e5                	mov    %esp,%ebp
  800bd1:	57                   	push   %edi
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd7:	be 00 00 00 00       	mov    $0x0,%esi
  800bdc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be2:	b8 04 00 00 00       	mov    $0x4,%eax
  800be7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bea:	89 f7                	mov    %esi,%edi
  800bec:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bee:	85 c0                	test   %eax,%eax
  800bf0:	7f 08                	jg     800bfa <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bfa:	83 ec 0c             	sub    $0xc,%esp
  800bfd:	50                   	push   %eax
  800bfe:	6a 04                	push   $0x4
  800c00:	68 9f 24 80 00       	push   $0x80249f
  800c05:	6a 2a                	push   $0x2a
  800c07:	68 bc 24 80 00       	push   $0x8024bc
  800c0c:	e8 c1 11 00 00       	call   801dd2 <_panic>

00800c11 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	57                   	push   %edi
  800c15:	56                   	push   %esi
  800c16:	53                   	push   %ebx
  800c17:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c20:	b8 05 00 00 00       	mov    $0x5,%eax
  800c25:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c28:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c2b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c2e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c30:	85 c0                	test   %eax,%eax
  800c32:	7f 08                	jg     800c3c <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c3c:	83 ec 0c             	sub    $0xc,%esp
  800c3f:	50                   	push   %eax
  800c40:	6a 05                	push   $0x5
  800c42:	68 9f 24 80 00       	push   $0x80249f
  800c47:	6a 2a                	push   $0x2a
  800c49:	68 bc 24 80 00       	push   $0x8024bc
  800c4e:	e8 7f 11 00 00       	call   801dd2 <_panic>

00800c53 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	57                   	push   %edi
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c61:	8b 55 08             	mov    0x8(%ebp),%edx
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	b8 06 00 00 00       	mov    $0x6,%eax
  800c6c:	89 df                	mov    %ebx,%edi
  800c6e:	89 de                	mov    %ebx,%esi
  800c70:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c72:	85 c0                	test   %eax,%eax
  800c74:	7f 08                	jg     800c7e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c76:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c79:	5b                   	pop    %ebx
  800c7a:	5e                   	pop    %esi
  800c7b:	5f                   	pop    %edi
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7e:	83 ec 0c             	sub    $0xc,%esp
  800c81:	50                   	push   %eax
  800c82:	6a 06                	push   $0x6
  800c84:	68 9f 24 80 00       	push   $0x80249f
  800c89:	6a 2a                	push   $0x2a
  800c8b:	68 bc 24 80 00       	push   $0x8024bc
  800c90:	e8 3d 11 00 00       	call   801dd2 <_panic>

00800c95 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c95:	55                   	push   %ebp
  800c96:	89 e5                	mov    %esp,%ebp
  800c98:	57                   	push   %edi
  800c99:	56                   	push   %esi
  800c9a:	53                   	push   %ebx
  800c9b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c9e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	b8 08 00 00 00       	mov    $0x8,%eax
  800cae:	89 df                	mov    %ebx,%edi
  800cb0:	89 de                	mov    %ebx,%esi
  800cb2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	7f 08                	jg     800cc0 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbb:	5b                   	pop    %ebx
  800cbc:	5e                   	pop    %esi
  800cbd:	5f                   	pop    %edi
  800cbe:	5d                   	pop    %ebp
  800cbf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc0:	83 ec 0c             	sub    $0xc,%esp
  800cc3:	50                   	push   %eax
  800cc4:	6a 08                	push   $0x8
  800cc6:	68 9f 24 80 00       	push   $0x80249f
  800ccb:	6a 2a                	push   $0x2a
  800ccd:	68 bc 24 80 00       	push   $0x8024bc
  800cd2:	e8 fb 10 00 00       	call   801dd2 <_panic>

00800cd7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cd7:	55                   	push   %ebp
  800cd8:	89 e5                	mov    %esp,%ebp
  800cda:	57                   	push   %edi
  800cdb:	56                   	push   %esi
  800cdc:	53                   	push   %ebx
  800cdd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ce5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ceb:	b8 09 00 00 00       	mov    $0x9,%eax
  800cf0:	89 df                	mov    %ebx,%edi
  800cf2:	89 de                	mov    %ebx,%esi
  800cf4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf6:	85 c0                	test   %eax,%eax
  800cf8:	7f 08                	jg     800d02 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d02:	83 ec 0c             	sub    $0xc,%esp
  800d05:	50                   	push   %eax
  800d06:	6a 09                	push   $0x9
  800d08:	68 9f 24 80 00       	push   $0x80249f
  800d0d:	6a 2a                	push   $0x2a
  800d0f:	68 bc 24 80 00       	push   $0x8024bc
  800d14:	e8 b9 10 00 00       	call   801dd2 <_panic>

00800d19 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d19:	55                   	push   %ebp
  800d1a:	89 e5                	mov    %esp,%ebp
  800d1c:	57                   	push   %edi
  800d1d:	56                   	push   %esi
  800d1e:	53                   	push   %ebx
  800d1f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d22:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d32:	89 df                	mov    %ebx,%edi
  800d34:	89 de                	mov    %ebx,%esi
  800d36:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	7f 08                	jg     800d44 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5f                   	pop    %edi
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	50                   	push   %eax
  800d48:	6a 0a                	push   $0xa
  800d4a:	68 9f 24 80 00       	push   $0x80249f
  800d4f:	6a 2a                	push   $0x2a
  800d51:	68 bc 24 80 00       	push   $0x8024bc
  800d56:	e8 77 10 00 00       	call   801dd2 <_panic>

00800d5b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d61:	8b 55 08             	mov    0x8(%ebp),%edx
  800d64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d67:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d6c:	be 00 00 00 00       	mov    $0x0,%esi
  800d71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d74:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d77:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d79:	5b                   	pop    %ebx
  800d7a:	5e                   	pop    %esi
  800d7b:	5f                   	pop    %edi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	57                   	push   %edi
  800d82:	56                   	push   %esi
  800d83:	53                   	push   %ebx
  800d84:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d87:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d94:	89 cb                	mov    %ecx,%ebx
  800d96:	89 cf                	mov    %ecx,%edi
  800d98:	89 ce                	mov    %ecx,%esi
  800d9a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d9c:	85 c0                	test   %eax,%eax
  800d9e:	7f 08                	jg     800da8 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da3:	5b                   	pop    %ebx
  800da4:	5e                   	pop    %esi
  800da5:	5f                   	pop    %edi
  800da6:	5d                   	pop    %ebp
  800da7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800da8:	83 ec 0c             	sub    $0xc,%esp
  800dab:	50                   	push   %eax
  800dac:	6a 0d                	push   $0xd
  800dae:	68 9f 24 80 00       	push   $0x80249f
  800db3:	6a 2a                	push   $0x2a
  800db5:	68 bc 24 80 00       	push   $0x8024bc
  800dba:	e8 13 10 00 00       	call   801dd2 <_panic>

00800dbf <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
  800dc4:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800dc7:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800dc9:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dcd:	0f 84 8e 00 00 00    	je     800e61 <pgfault+0xa2>
  800dd3:	89 f0                	mov    %esi,%eax
  800dd5:	c1 e8 0c             	shr    $0xc,%eax
  800dd8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ddf:	f6 c4 08             	test   $0x8,%ah
  800de2:	74 7d                	je     800e61 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800de4:	e8 a7 fd ff ff       	call   800b90 <sys_getenvid>
  800de9:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800deb:	83 ec 04             	sub    $0x4,%esp
  800dee:	6a 07                	push   $0x7
  800df0:	68 00 f0 7f 00       	push   $0x7ff000
  800df5:	50                   	push   %eax
  800df6:	e8 d3 fd ff ff       	call   800bce <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800dfb:	83 c4 10             	add    $0x10,%esp
  800dfe:	85 c0                	test   %eax,%eax
  800e00:	78 73                	js     800e75 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800e02:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800e08:	83 ec 04             	sub    $0x4,%esp
  800e0b:	68 00 10 00 00       	push   $0x1000
  800e10:	56                   	push   %esi
  800e11:	68 00 f0 7f 00       	push   $0x7ff000
  800e16:	e8 4d fb ff ff       	call   800968 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800e1b:	83 c4 08             	add    $0x8,%esp
  800e1e:	56                   	push   %esi
  800e1f:	53                   	push   %ebx
  800e20:	e8 2e fe ff ff       	call   800c53 <sys_page_unmap>
  800e25:	83 c4 10             	add    $0x10,%esp
  800e28:	85 c0                	test   %eax,%eax
  800e2a:	78 5b                	js     800e87 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800e2c:	83 ec 0c             	sub    $0xc,%esp
  800e2f:	6a 07                	push   $0x7
  800e31:	56                   	push   %esi
  800e32:	53                   	push   %ebx
  800e33:	68 00 f0 7f 00       	push   $0x7ff000
  800e38:	53                   	push   %ebx
  800e39:	e8 d3 fd ff ff       	call   800c11 <sys_page_map>
  800e3e:	83 c4 20             	add    $0x20,%esp
  800e41:	85 c0                	test   %eax,%eax
  800e43:	78 54                	js     800e99 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800e45:	83 ec 08             	sub    $0x8,%esp
  800e48:	68 00 f0 7f 00       	push   $0x7ff000
  800e4d:	53                   	push   %ebx
  800e4e:	e8 00 fe ff ff       	call   800c53 <sys_page_unmap>
  800e53:	83 c4 10             	add    $0x10,%esp
  800e56:	85 c0                	test   %eax,%eax
  800e58:	78 51                	js     800eab <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800e5a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e61:	83 ec 04             	sub    $0x4,%esp
  800e64:	68 cc 24 80 00       	push   $0x8024cc
  800e69:	6a 1d                	push   $0x1d
  800e6b:	68 48 25 80 00       	push   $0x802548
  800e70:	e8 5d 0f 00 00       	call   801dd2 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e75:	50                   	push   %eax
  800e76:	68 04 25 80 00       	push   $0x802504
  800e7b:	6a 29                	push   $0x29
  800e7d:	68 48 25 80 00       	push   $0x802548
  800e82:	e8 4b 0f 00 00       	call   801dd2 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800e87:	50                   	push   %eax
  800e88:	68 28 25 80 00       	push   $0x802528
  800e8d:	6a 2e                	push   $0x2e
  800e8f:	68 48 25 80 00       	push   $0x802548
  800e94:	e8 39 0f 00 00       	call   801dd2 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800e99:	50                   	push   %eax
  800e9a:	68 53 25 80 00       	push   $0x802553
  800e9f:	6a 30                	push   $0x30
  800ea1:	68 48 25 80 00       	push   $0x802548
  800ea6:	e8 27 0f 00 00       	call   801dd2 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800eab:	50                   	push   %eax
  800eac:	68 28 25 80 00       	push   $0x802528
  800eb1:	6a 32                	push   $0x32
  800eb3:	68 48 25 80 00       	push   $0x802548
  800eb8:	e8 15 0f 00 00       	call   801dd2 <_panic>

00800ebd <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	57                   	push   %edi
  800ec1:	56                   	push   %esi
  800ec2:	53                   	push   %ebx
  800ec3:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800ec6:	68 bf 0d 80 00       	push   $0x800dbf
  800ecb:	e8 48 0f 00 00       	call   801e18 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ed0:	b8 07 00 00 00       	mov    $0x7,%eax
  800ed5:	cd 30                	int    $0x30
  800ed7:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800eda:	83 c4 10             	add    $0x10,%esp
  800edd:	85 c0                	test   %eax,%eax
  800edf:	78 2d                	js     800f0e <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800ee1:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800ee6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800eea:	75 73                	jne    800f5f <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  800eec:	e8 9f fc ff ff       	call   800b90 <sys_getenvid>
  800ef1:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ef6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ef9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800efe:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f03:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800f06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f09:	5b                   	pop    %ebx
  800f0a:	5e                   	pop    %esi
  800f0b:	5f                   	pop    %edi
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  800f0e:	50                   	push   %eax
  800f0f:	68 71 25 80 00       	push   $0x802571
  800f14:	6a 78                	push   $0x78
  800f16:	68 48 25 80 00       	push   $0x802548
  800f1b:	e8 b2 0e 00 00       	call   801dd2 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  800f20:	83 ec 0c             	sub    $0xc,%esp
  800f23:	ff 75 e4             	push   -0x1c(%ebp)
  800f26:	57                   	push   %edi
  800f27:	ff 75 dc             	push   -0x24(%ebp)
  800f2a:	57                   	push   %edi
  800f2b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800f2e:	56                   	push   %esi
  800f2f:	e8 dd fc ff ff       	call   800c11 <sys_page_map>
	if(r<0) return r;
  800f34:	83 c4 20             	add    $0x20,%esp
  800f37:	85 c0                	test   %eax,%eax
  800f39:	78 cb                	js     800f06 <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  800f3b:	83 ec 0c             	sub    $0xc,%esp
  800f3e:	ff 75 e4             	push   -0x1c(%ebp)
  800f41:	57                   	push   %edi
  800f42:	56                   	push   %esi
  800f43:	57                   	push   %edi
  800f44:	56                   	push   %esi
  800f45:	e8 c7 fc ff ff       	call   800c11 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800f4a:	83 c4 20             	add    $0x20,%esp
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	78 76                	js     800fc7 <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f51:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f57:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f5d:	74 75                	je     800fd4 <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800f5f:	89 d8                	mov    %ebx,%eax
  800f61:	c1 e8 16             	shr    $0x16,%eax
  800f64:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f6b:	a8 01                	test   $0x1,%al
  800f6d:	74 e2                	je     800f51 <fork+0x94>
  800f6f:	89 de                	mov    %ebx,%esi
  800f71:	c1 ee 0c             	shr    $0xc,%esi
  800f74:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f7b:	a8 01                	test   $0x1,%al
  800f7d:	74 d2                	je     800f51 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  800f7f:	e8 0c fc ff ff       	call   800b90 <sys_getenvid>
  800f84:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  800f87:	89 f7                	mov    %esi,%edi
  800f89:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  800f8c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f93:	89 c1                	mov    %eax,%ecx
  800f95:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  800f9b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  800f9e:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  800fa5:	f6 c6 04             	test   $0x4,%dh
  800fa8:	0f 85 72 ff ff ff    	jne    800f20 <fork+0x63>
		perm &= ~PTE_W;
  800fae:	25 05 0e 00 00       	and    $0xe05,%eax
  800fb3:	80 cc 08             	or     $0x8,%ah
  800fb6:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  800fbc:	0f 44 c1             	cmove  %ecx,%eax
  800fbf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fc2:	e9 59 ff ff ff       	jmp    800f20 <fork+0x63>
  800fc7:	ba 00 00 00 00       	mov    $0x0,%edx
  800fcc:	0f 4f c2             	cmovg  %edx,%eax
  800fcf:	e9 32 ff ff ff       	jmp    800f06 <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  800fd4:	83 ec 04             	sub    $0x4,%esp
  800fd7:	6a 07                	push   $0x7
  800fd9:	68 00 f0 bf ee       	push   $0xeebff000
  800fde:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800fe1:	57                   	push   %edi
  800fe2:	e8 e7 fb ff ff       	call   800bce <sys_page_alloc>
	if(r<0) return r;
  800fe7:	83 c4 10             	add    $0x10,%esp
  800fea:	85 c0                	test   %eax,%eax
  800fec:	0f 88 14 ff ff ff    	js     800f06 <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800ff2:	83 ec 08             	sub    $0x8,%esp
  800ff5:	68 8e 1e 80 00       	push   $0x801e8e
  800ffa:	57                   	push   %edi
  800ffb:	e8 19 fd ff ff       	call   800d19 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801000:	83 c4 10             	add    $0x10,%esp
  801003:	85 c0                	test   %eax,%eax
  801005:	0f 88 fb fe ff ff    	js     800f06 <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80100b:	83 ec 08             	sub    $0x8,%esp
  80100e:	6a 02                	push   $0x2
  801010:	57                   	push   %edi
  801011:	e8 7f fc ff ff       	call   800c95 <sys_env_set_status>
	if(r<0) return r;
  801016:	83 c4 10             	add    $0x10,%esp
	return envid;
  801019:	85 c0                	test   %eax,%eax
  80101b:	0f 49 c7             	cmovns %edi,%eax
  80101e:	e9 e3 fe ff ff       	jmp    800f06 <fork+0x49>

00801023 <sfork>:

// Challenge!
int
sfork(void)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801029:	68 81 25 80 00       	push   $0x802581
  80102e:	68 a1 00 00 00       	push   $0xa1
  801033:	68 48 25 80 00       	push   $0x802548
  801038:	e8 95 0d 00 00       	call   801dd2 <_panic>

0080103d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80103d:	55                   	push   %ebp
  80103e:	89 e5                	mov    %esp,%ebp
  801040:	56                   	push   %esi
  801041:	53                   	push   %ebx
  801042:	8b 75 08             	mov    0x8(%ebp),%esi
  801045:	8b 45 0c             	mov    0xc(%ebp),%eax
  801048:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80104b:	85 c0                	test   %eax,%eax
  80104d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801052:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801055:	83 ec 0c             	sub    $0xc,%esp
  801058:	50                   	push   %eax
  801059:	e8 20 fd ff ff       	call   800d7e <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  80105e:	83 c4 10             	add    $0x10,%esp
  801061:	85 f6                	test   %esi,%esi
  801063:	74 14                	je     801079 <ipc_recv+0x3c>
  801065:	ba 00 00 00 00       	mov    $0x0,%edx
  80106a:	85 c0                	test   %eax,%eax
  80106c:	78 09                	js     801077 <ipc_recv+0x3a>
  80106e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801074:	8b 52 74             	mov    0x74(%edx),%edx
  801077:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801079:	85 db                	test   %ebx,%ebx
  80107b:	74 14                	je     801091 <ipc_recv+0x54>
  80107d:	ba 00 00 00 00       	mov    $0x0,%edx
  801082:	85 c0                	test   %eax,%eax
  801084:	78 09                	js     80108f <ipc_recv+0x52>
  801086:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80108c:	8b 52 78             	mov    0x78(%edx),%edx
  80108f:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801091:	85 c0                	test   %eax,%eax
  801093:	78 08                	js     80109d <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801095:	a1 04 40 80 00       	mov    0x804004,%eax
  80109a:	8b 40 70             	mov    0x70(%eax),%eax
}
  80109d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010a0:	5b                   	pop    %ebx
  8010a1:	5e                   	pop    %esi
  8010a2:	5d                   	pop    %ebp
  8010a3:	c3                   	ret    

008010a4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010a4:	55                   	push   %ebp
  8010a5:	89 e5                	mov    %esp,%ebp
  8010a7:	57                   	push   %edi
  8010a8:	56                   	push   %esi
  8010a9:	53                   	push   %ebx
  8010aa:	83 ec 0c             	sub    $0xc,%esp
  8010ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010b0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8010b6:	85 db                	test   %ebx,%ebx
  8010b8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8010bd:	0f 44 d8             	cmove  %eax,%ebx
  8010c0:	eb 05                	jmp    8010c7 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8010c2:	e8 e8 fa ff ff       	call   800baf <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8010c7:	ff 75 14             	push   0x14(%ebp)
  8010ca:	53                   	push   %ebx
  8010cb:	56                   	push   %esi
  8010cc:	57                   	push   %edi
  8010cd:	e8 89 fc ff ff       	call   800d5b <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8010d2:	83 c4 10             	add    $0x10,%esp
  8010d5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8010d8:	74 e8                	je     8010c2 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8010da:	85 c0                	test   %eax,%eax
  8010dc:	78 08                	js     8010e6 <ipc_send+0x42>
	}while (r<0);

}
  8010de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e1:	5b                   	pop    %ebx
  8010e2:	5e                   	pop    %esi
  8010e3:	5f                   	pop    %edi
  8010e4:	5d                   	pop    %ebp
  8010e5:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8010e6:	50                   	push   %eax
  8010e7:	68 97 25 80 00       	push   $0x802597
  8010ec:	6a 3d                	push   $0x3d
  8010ee:	68 ab 25 80 00       	push   $0x8025ab
  8010f3:	e8 da 0c 00 00       	call   801dd2 <_panic>

008010f8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010f8:	55                   	push   %ebp
  8010f9:	89 e5                	mov    %esp,%ebp
  8010fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8010fe:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801103:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801106:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80110c:	8b 52 50             	mov    0x50(%edx),%edx
  80110f:	39 ca                	cmp    %ecx,%edx
  801111:	74 11                	je     801124 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801113:	83 c0 01             	add    $0x1,%eax
  801116:	3d 00 04 00 00       	cmp    $0x400,%eax
  80111b:	75 e6                	jne    801103 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80111d:	b8 00 00 00 00       	mov    $0x0,%eax
  801122:	eb 0b                	jmp    80112f <ipc_find_env+0x37>
			return envs[i].env_id;
  801124:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801127:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80112c:	8b 40 48             	mov    0x48(%eax),%eax
}
  80112f:	5d                   	pop    %ebp
  801130:	c3                   	ret    

00801131 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801134:	8b 45 08             	mov    0x8(%ebp),%eax
  801137:	05 00 00 00 30       	add    $0x30000000,%eax
  80113c:	c1 e8 0c             	shr    $0xc,%eax
}
  80113f:	5d                   	pop    %ebp
  801140:	c3                   	ret    

00801141 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801144:	8b 45 08             	mov    0x8(%ebp),%eax
  801147:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80114c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  801151:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801156:	5d                   	pop    %ebp
  801157:	c3                   	ret    

00801158 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801160:	89 c2                	mov    %eax,%edx
  801162:	c1 ea 16             	shr    $0x16,%edx
  801165:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80116c:	f6 c2 01             	test   $0x1,%dl
  80116f:	74 29                	je     80119a <fd_alloc+0x42>
  801171:	89 c2                	mov    %eax,%edx
  801173:	c1 ea 0c             	shr    $0xc,%edx
  801176:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80117d:	f6 c2 01             	test   $0x1,%dl
  801180:	74 18                	je     80119a <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801182:	05 00 10 00 00       	add    $0x1000,%eax
  801187:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80118c:	75 d2                	jne    801160 <fd_alloc+0x8>
  80118e:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801193:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801198:	eb 05                	jmp    80119f <fd_alloc+0x47>
			return 0;
  80119a:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80119f:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a2:	89 02                	mov    %eax,(%edx)
}
  8011a4:	89 c8                	mov    %ecx,%eax
  8011a6:	5d                   	pop    %ebp
  8011a7:	c3                   	ret    

008011a8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011ae:	83 f8 1f             	cmp    $0x1f,%eax
  8011b1:	77 30                	ja     8011e3 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011b3:	c1 e0 0c             	shl    $0xc,%eax
  8011b6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011bb:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8011c1:	f6 c2 01             	test   $0x1,%dl
  8011c4:	74 24                	je     8011ea <fd_lookup+0x42>
  8011c6:	89 c2                	mov    %eax,%edx
  8011c8:	c1 ea 0c             	shr    $0xc,%edx
  8011cb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011d2:	f6 c2 01             	test   $0x1,%dl
  8011d5:	74 1a                	je     8011f1 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011da:	89 02                	mov    %eax,(%edx)
	return 0;
  8011dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011e1:	5d                   	pop    %ebp
  8011e2:	c3                   	ret    
		return -E_INVAL;
  8011e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e8:	eb f7                	jmp    8011e1 <fd_lookup+0x39>
		return -E_INVAL;
  8011ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011ef:	eb f0                	jmp    8011e1 <fd_lookup+0x39>
  8011f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011f6:	eb e9                	jmp    8011e1 <fd_lookup+0x39>

008011f8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	53                   	push   %ebx
  8011fc:	83 ec 04             	sub    $0x4,%esp
  8011ff:	8b 55 08             	mov    0x8(%ebp),%edx
  801202:	b8 34 26 80 00       	mov    $0x802634,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  801207:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80120c:	39 13                	cmp    %edx,(%ebx)
  80120e:	74 32                	je     801242 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  801210:	83 c0 04             	add    $0x4,%eax
  801213:	8b 18                	mov    (%eax),%ebx
  801215:	85 db                	test   %ebx,%ebx
  801217:	75 f3                	jne    80120c <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801219:	a1 04 40 80 00       	mov    0x804004,%eax
  80121e:	8b 40 48             	mov    0x48(%eax),%eax
  801221:	83 ec 04             	sub    $0x4,%esp
  801224:	52                   	push   %edx
  801225:	50                   	push   %eax
  801226:	68 b8 25 80 00       	push   $0x8025b8
  80122b:	e8 c8 ef ff ff       	call   8001f8 <cprintf>
	*dev = 0;
	return -E_INVAL;
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801238:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123b:	89 1a                	mov    %ebx,(%edx)
}
  80123d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801240:	c9                   	leave  
  801241:	c3                   	ret    
			return 0;
  801242:	b8 00 00 00 00       	mov    $0x0,%eax
  801247:	eb ef                	jmp    801238 <dev_lookup+0x40>

00801249 <fd_close>:
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	57                   	push   %edi
  80124d:	56                   	push   %esi
  80124e:	53                   	push   %ebx
  80124f:	83 ec 24             	sub    $0x24,%esp
  801252:	8b 75 08             	mov    0x8(%ebp),%esi
  801255:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801258:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80125b:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80125c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801262:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801265:	50                   	push   %eax
  801266:	e8 3d ff ff ff       	call   8011a8 <fd_lookup>
  80126b:	89 c3                	mov    %eax,%ebx
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	85 c0                	test   %eax,%eax
  801272:	78 05                	js     801279 <fd_close+0x30>
	    || fd != fd2)
  801274:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801277:	74 16                	je     80128f <fd_close+0x46>
		return (must_exist ? r : 0);
  801279:	89 f8                	mov    %edi,%eax
  80127b:	84 c0                	test   %al,%al
  80127d:	b8 00 00 00 00       	mov    $0x0,%eax
  801282:	0f 44 d8             	cmove  %eax,%ebx
}
  801285:	89 d8                	mov    %ebx,%eax
  801287:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80128a:	5b                   	pop    %ebx
  80128b:	5e                   	pop    %esi
  80128c:	5f                   	pop    %edi
  80128d:	5d                   	pop    %ebp
  80128e:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80128f:	83 ec 08             	sub    $0x8,%esp
  801292:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801295:	50                   	push   %eax
  801296:	ff 36                	push   (%esi)
  801298:	e8 5b ff ff ff       	call   8011f8 <dev_lookup>
  80129d:	89 c3                	mov    %eax,%ebx
  80129f:	83 c4 10             	add    $0x10,%esp
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	78 1a                	js     8012c0 <fd_close+0x77>
		if (dev->dev_close)
  8012a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012a9:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8012ac:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	74 0b                	je     8012c0 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8012b5:	83 ec 0c             	sub    $0xc,%esp
  8012b8:	56                   	push   %esi
  8012b9:	ff d0                	call   *%eax
  8012bb:	89 c3                	mov    %eax,%ebx
  8012bd:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8012c0:	83 ec 08             	sub    $0x8,%esp
  8012c3:	56                   	push   %esi
  8012c4:	6a 00                	push   $0x0
  8012c6:	e8 88 f9 ff ff       	call   800c53 <sys_page_unmap>
	return r;
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	eb b5                	jmp    801285 <fd_close+0x3c>

008012d0 <close>:

int
close(int fdnum)
{
  8012d0:	55                   	push   %ebp
  8012d1:	89 e5                	mov    %esp,%ebp
  8012d3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d9:	50                   	push   %eax
  8012da:	ff 75 08             	push   0x8(%ebp)
  8012dd:	e8 c6 fe ff ff       	call   8011a8 <fd_lookup>
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	79 02                	jns    8012eb <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8012e9:	c9                   	leave  
  8012ea:	c3                   	ret    
		return fd_close(fd, 1);
  8012eb:	83 ec 08             	sub    $0x8,%esp
  8012ee:	6a 01                	push   $0x1
  8012f0:	ff 75 f4             	push   -0xc(%ebp)
  8012f3:	e8 51 ff ff ff       	call   801249 <fd_close>
  8012f8:	83 c4 10             	add    $0x10,%esp
  8012fb:	eb ec                	jmp    8012e9 <close+0x19>

008012fd <close_all>:

void
close_all(void)
{
  8012fd:	55                   	push   %ebp
  8012fe:	89 e5                	mov    %esp,%ebp
  801300:	53                   	push   %ebx
  801301:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801304:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801309:	83 ec 0c             	sub    $0xc,%esp
  80130c:	53                   	push   %ebx
  80130d:	e8 be ff ff ff       	call   8012d0 <close>
	for (i = 0; i < MAXFD; i++)
  801312:	83 c3 01             	add    $0x1,%ebx
  801315:	83 c4 10             	add    $0x10,%esp
  801318:	83 fb 20             	cmp    $0x20,%ebx
  80131b:	75 ec                	jne    801309 <close_all+0xc>
}
  80131d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801320:	c9                   	leave  
  801321:	c3                   	ret    

00801322 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801322:	55                   	push   %ebp
  801323:	89 e5                	mov    %esp,%ebp
  801325:	57                   	push   %edi
  801326:	56                   	push   %esi
  801327:	53                   	push   %ebx
  801328:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80132b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80132e:	50                   	push   %eax
  80132f:	ff 75 08             	push   0x8(%ebp)
  801332:	e8 71 fe ff ff       	call   8011a8 <fd_lookup>
  801337:	89 c3                	mov    %eax,%ebx
  801339:	83 c4 10             	add    $0x10,%esp
  80133c:	85 c0                	test   %eax,%eax
  80133e:	78 7f                	js     8013bf <dup+0x9d>
		return r;
	close(newfdnum);
  801340:	83 ec 0c             	sub    $0xc,%esp
  801343:	ff 75 0c             	push   0xc(%ebp)
  801346:	e8 85 ff ff ff       	call   8012d0 <close>

	newfd = INDEX2FD(newfdnum);
  80134b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80134e:	c1 e6 0c             	shl    $0xc,%esi
  801351:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80135a:	89 3c 24             	mov    %edi,(%esp)
  80135d:	e8 df fd ff ff       	call   801141 <fd2data>
  801362:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801364:	89 34 24             	mov    %esi,(%esp)
  801367:	e8 d5 fd ff ff       	call   801141 <fd2data>
  80136c:	83 c4 10             	add    $0x10,%esp
  80136f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801372:	89 d8                	mov    %ebx,%eax
  801374:	c1 e8 16             	shr    $0x16,%eax
  801377:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80137e:	a8 01                	test   $0x1,%al
  801380:	74 11                	je     801393 <dup+0x71>
  801382:	89 d8                	mov    %ebx,%eax
  801384:	c1 e8 0c             	shr    $0xc,%eax
  801387:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80138e:	f6 c2 01             	test   $0x1,%dl
  801391:	75 36                	jne    8013c9 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801393:	89 f8                	mov    %edi,%eax
  801395:	c1 e8 0c             	shr    $0xc,%eax
  801398:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80139f:	83 ec 0c             	sub    $0xc,%esp
  8013a2:	25 07 0e 00 00       	and    $0xe07,%eax
  8013a7:	50                   	push   %eax
  8013a8:	56                   	push   %esi
  8013a9:	6a 00                	push   $0x0
  8013ab:	57                   	push   %edi
  8013ac:	6a 00                	push   $0x0
  8013ae:	e8 5e f8 ff ff       	call   800c11 <sys_page_map>
  8013b3:	89 c3                	mov    %eax,%ebx
  8013b5:	83 c4 20             	add    $0x20,%esp
  8013b8:	85 c0                	test   %eax,%eax
  8013ba:	78 33                	js     8013ef <dup+0xcd>
		goto err;

	return newfdnum;
  8013bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013bf:	89 d8                	mov    %ebx,%eax
  8013c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c4:	5b                   	pop    %ebx
  8013c5:	5e                   	pop    %esi
  8013c6:	5f                   	pop    %edi
  8013c7:	5d                   	pop    %ebp
  8013c8:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013c9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013d0:	83 ec 0c             	sub    $0xc,%esp
  8013d3:	25 07 0e 00 00       	and    $0xe07,%eax
  8013d8:	50                   	push   %eax
  8013d9:	ff 75 d4             	push   -0x2c(%ebp)
  8013dc:	6a 00                	push   $0x0
  8013de:	53                   	push   %ebx
  8013df:	6a 00                	push   $0x0
  8013e1:	e8 2b f8 ff ff       	call   800c11 <sys_page_map>
  8013e6:	89 c3                	mov    %eax,%ebx
  8013e8:	83 c4 20             	add    $0x20,%esp
  8013eb:	85 c0                	test   %eax,%eax
  8013ed:	79 a4                	jns    801393 <dup+0x71>
	sys_page_unmap(0, newfd);
  8013ef:	83 ec 08             	sub    $0x8,%esp
  8013f2:	56                   	push   %esi
  8013f3:	6a 00                	push   $0x0
  8013f5:	e8 59 f8 ff ff       	call   800c53 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013fa:	83 c4 08             	add    $0x8,%esp
  8013fd:	ff 75 d4             	push   -0x2c(%ebp)
  801400:	6a 00                	push   $0x0
  801402:	e8 4c f8 ff ff       	call   800c53 <sys_page_unmap>
	return r;
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	eb b3                	jmp    8013bf <dup+0x9d>

0080140c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	56                   	push   %esi
  801410:	53                   	push   %ebx
  801411:	83 ec 18             	sub    $0x18,%esp
  801414:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801417:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141a:	50                   	push   %eax
  80141b:	56                   	push   %esi
  80141c:	e8 87 fd ff ff       	call   8011a8 <fd_lookup>
  801421:	83 c4 10             	add    $0x10,%esp
  801424:	85 c0                	test   %eax,%eax
  801426:	78 3c                	js     801464 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801428:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80142b:	83 ec 08             	sub    $0x8,%esp
  80142e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801431:	50                   	push   %eax
  801432:	ff 33                	push   (%ebx)
  801434:	e8 bf fd ff ff       	call   8011f8 <dev_lookup>
  801439:	83 c4 10             	add    $0x10,%esp
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 24                	js     801464 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801440:	8b 43 08             	mov    0x8(%ebx),%eax
  801443:	83 e0 03             	and    $0x3,%eax
  801446:	83 f8 01             	cmp    $0x1,%eax
  801449:	74 20                	je     80146b <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80144b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80144e:	8b 40 08             	mov    0x8(%eax),%eax
  801451:	85 c0                	test   %eax,%eax
  801453:	74 37                	je     80148c <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801455:	83 ec 04             	sub    $0x4,%esp
  801458:	ff 75 10             	push   0x10(%ebp)
  80145b:	ff 75 0c             	push   0xc(%ebp)
  80145e:	53                   	push   %ebx
  80145f:	ff d0                	call   *%eax
  801461:	83 c4 10             	add    $0x10,%esp
}
  801464:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801467:	5b                   	pop    %ebx
  801468:	5e                   	pop    %esi
  801469:	5d                   	pop    %ebp
  80146a:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80146b:	a1 04 40 80 00       	mov    0x804004,%eax
  801470:	8b 40 48             	mov    0x48(%eax),%eax
  801473:	83 ec 04             	sub    $0x4,%esp
  801476:	56                   	push   %esi
  801477:	50                   	push   %eax
  801478:	68 f9 25 80 00       	push   $0x8025f9
  80147d:	e8 76 ed ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  801482:	83 c4 10             	add    $0x10,%esp
  801485:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80148a:	eb d8                	jmp    801464 <read+0x58>
		return -E_NOT_SUPP;
  80148c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801491:	eb d1                	jmp    801464 <read+0x58>

00801493 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801493:	55                   	push   %ebp
  801494:	89 e5                	mov    %esp,%ebp
  801496:	57                   	push   %edi
  801497:	56                   	push   %esi
  801498:	53                   	push   %ebx
  801499:	83 ec 0c             	sub    $0xc,%esp
  80149c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80149f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014a2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a7:	eb 02                	jmp    8014ab <readn+0x18>
  8014a9:	01 c3                	add    %eax,%ebx
  8014ab:	39 f3                	cmp    %esi,%ebx
  8014ad:	73 21                	jae    8014d0 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014af:	83 ec 04             	sub    $0x4,%esp
  8014b2:	89 f0                	mov    %esi,%eax
  8014b4:	29 d8                	sub    %ebx,%eax
  8014b6:	50                   	push   %eax
  8014b7:	89 d8                	mov    %ebx,%eax
  8014b9:	03 45 0c             	add    0xc(%ebp),%eax
  8014bc:	50                   	push   %eax
  8014bd:	57                   	push   %edi
  8014be:	e8 49 ff ff ff       	call   80140c <read>
		if (m < 0)
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	85 c0                	test   %eax,%eax
  8014c8:	78 04                	js     8014ce <readn+0x3b>
			return m;
		if (m == 0)
  8014ca:	75 dd                	jne    8014a9 <readn+0x16>
  8014cc:	eb 02                	jmp    8014d0 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014ce:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8014d0:	89 d8                	mov    %ebx,%eax
  8014d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014d5:	5b                   	pop    %ebx
  8014d6:	5e                   	pop    %esi
  8014d7:	5f                   	pop    %edi
  8014d8:	5d                   	pop    %ebp
  8014d9:	c3                   	ret    

008014da <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014da:	55                   	push   %ebp
  8014db:	89 e5                	mov    %esp,%ebp
  8014dd:	56                   	push   %esi
  8014de:	53                   	push   %ebx
  8014df:	83 ec 18             	sub    $0x18,%esp
  8014e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e8:	50                   	push   %eax
  8014e9:	53                   	push   %ebx
  8014ea:	e8 b9 fc ff ff       	call   8011a8 <fd_lookup>
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	78 37                	js     80152d <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f6:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8014f9:	83 ec 08             	sub    $0x8,%esp
  8014fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ff:	50                   	push   %eax
  801500:	ff 36                	push   (%esi)
  801502:	e8 f1 fc ff ff       	call   8011f8 <dev_lookup>
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	85 c0                	test   %eax,%eax
  80150c:	78 1f                	js     80152d <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80150e:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801512:	74 20                	je     801534 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801514:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801517:	8b 40 0c             	mov    0xc(%eax),%eax
  80151a:	85 c0                	test   %eax,%eax
  80151c:	74 37                	je     801555 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80151e:	83 ec 04             	sub    $0x4,%esp
  801521:	ff 75 10             	push   0x10(%ebp)
  801524:	ff 75 0c             	push   0xc(%ebp)
  801527:	56                   	push   %esi
  801528:	ff d0                	call   *%eax
  80152a:	83 c4 10             	add    $0x10,%esp
}
  80152d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801530:	5b                   	pop    %ebx
  801531:	5e                   	pop    %esi
  801532:	5d                   	pop    %ebp
  801533:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801534:	a1 04 40 80 00       	mov    0x804004,%eax
  801539:	8b 40 48             	mov    0x48(%eax),%eax
  80153c:	83 ec 04             	sub    $0x4,%esp
  80153f:	53                   	push   %ebx
  801540:	50                   	push   %eax
  801541:	68 15 26 80 00       	push   $0x802615
  801546:	e8 ad ec ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  80154b:	83 c4 10             	add    $0x10,%esp
  80154e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801553:	eb d8                	jmp    80152d <write+0x53>
		return -E_NOT_SUPP;
  801555:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80155a:	eb d1                	jmp    80152d <write+0x53>

0080155c <seek>:

int
seek(int fdnum, off_t offset)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801562:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801565:	50                   	push   %eax
  801566:	ff 75 08             	push   0x8(%ebp)
  801569:	e8 3a fc ff ff       	call   8011a8 <fd_lookup>
  80156e:	83 c4 10             	add    $0x10,%esp
  801571:	85 c0                	test   %eax,%eax
  801573:	78 0e                	js     801583 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801575:	8b 55 0c             	mov    0xc(%ebp),%edx
  801578:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80157e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801583:	c9                   	leave  
  801584:	c3                   	ret    

00801585 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801585:	55                   	push   %ebp
  801586:	89 e5                	mov    %esp,%ebp
  801588:	56                   	push   %esi
  801589:	53                   	push   %ebx
  80158a:	83 ec 18             	sub    $0x18,%esp
  80158d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801590:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801593:	50                   	push   %eax
  801594:	53                   	push   %ebx
  801595:	e8 0e fc ff ff       	call   8011a8 <fd_lookup>
  80159a:	83 c4 10             	add    $0x10,%esp
  80159d:	85 c0                	test   %eax,%eax
  80159f:	78 34                	js     8015d5 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a1:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8015a4:	83 ec 08             	sub    $0x8,%esp
  8015a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015aa:	50                   	push   %eax
  8015ab:	ff 36                	push   (%esi)
  8015ad:	e8 46 fc ff ff       	call   8011f8 <dev_lookup>
  8015b2:	83 c4 10             	add    $0x10,%esp
  8015b5:	85 c0                	test   %eax,%eax
  8015b7:	78 1c                	js     8015d5 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015b9:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8015bd:	74 1d                	je     8015dc <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8015bf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c2:	8b 40 18             	mov    0x18(%eax),%eax
  8015c5:	85 c0                	test   %eax,%eax
  8015c7:	74 34                	je     8015fd <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015c9:	83 ec 08             	sub    $0x8,%esp
  8015cc:	ff 75 0c             	push   0xc(%ebp)
  8015cf:	56                   	push   %esi
  8015d0:	ff d0                	call   *%eax
  8015d2:	83 c4 10             	add    $0x10,%esp
}
  8015d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d8:	5b                   	pop    %ebx
  8015d9:	5e                   	pop    %esi
  8015da:	5d                   	pop    %ebp
  8015db:	c3                   	ret    
			thisenv->env_id, fdnum);
  8015dc:	a1 04 40 80 00       	mov    0x804004,%eax
  8015e1:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015e4:	83 ec 04             	sub    $0x4,%esp
  8015e7:	53                   	push   %ebx
  8015e8:	50                   	push   %eax
  8015e9:	68 d8 25 80 00       	push   $0x8025d8
  8015ee:	e8 05 ec ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015fb:	eb d8                	jmp    8015d5 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8015fd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801602:	eb d1                	jmp    8015d5 <ftruncate+0x50>

00801604 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	56                   	push   %esi
  801608:	53                   	push   %ebx
  801609:	83 ec 18             	sub    $0x18,%esp
  80160c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80160f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801612:	50                   	push   %eax
  801613:	ff 75 08             	push   0x8(%ebp)
  801616:	e8 8d fb ff ff       	call   8011a8 <fd_lookup>
  80161b:	83 c4 10             	add    $0x10,%esp
  80161e:	85 c0                	test   %eax,%eax
  801620:	78 49                	js     80166b <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801622:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801625:	83 ec 08             	sub    $0x8,%esp
  801628:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162b:	50                   	push   %eax
  80162c:	ff 36                	push   (%esi)
  80162e:	e8 c5 fb ff ff       	call   8011f8 <dev_lookup>
  801633:	83 c4 10             	add    $0x10,%esp
  801636:	85 c0                	test   %eax,%eax
  801638:	78 31                	js     80166b <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80163a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80163d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801641:	74 2f                	je     801672 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801643:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801646:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80164d:	00 00 00 
	stat->st_isdir = 0;
  801650:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801657:	00 00 00 
	stat->st_dev = dev;
  80165a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801660:	83 ec 08             	sub    $0x8,%esp
  801663:	53                   	push   %ebx
  801664:	56                   	push   %esi
  801665:	ff 50 14             	call   *0x14(%eax)
  801668:	83 c4 10             	add    $0x10,%esp
}
  80166b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80166e:	5b                   	pop    %ebx
  80166f:	5e                   	pop    %esi
  801670:	5d                   	pop    %ebp
  801671:	c3                   	ret    
		return -E_NOT_SUPP;
  801672:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801677:	eb f2                	jmp    80166b <fstat+0x67>

00801679 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801679:	55                   	push   %ebp
  80167a:	89 e5                	mov    %esp,%ebp
  80167c:	56                   	push   %esi
  80167d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80167e:	83 ec 08             	sub    $0x8,%esp
  801681:	6a 00                	push   $0x0
  801683:	ff 75 08             	push   0x8(%ebp)
  801686:	e8 e4 01 00 00       	call   80186f <open>
  80168b:	89 c3                	mov    %eax,%ebx
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	85 c0                	test   %eax,%eax
  801692:	78 1b                	js     8016af <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801694:	83 ec 08             	sub    $0x8,%esp
  801697:	ff 75 0c             	push   0xc(%ebp)
  80169a:	50                   	push   %eax
  80169b:	e8 64 ff ff ff       	call   801604 <fstat>
  8016a0:	89 c6                	mov    %eax,%esi
	close(fd);
  8016a2:	89 1c 24             	mov    %ebx,(%esp)
  8016a5:	e8 26 fc ff ff       	call   8012d0 <close>
	return r;
  8016aa:	83 c4 10             	add    $0x10,%esp
  8016ad:	89 f3                	mov    %esi,%ebx
}
  8016af:	89 d8                	mov    %ebx,%eax
  8016b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b4:	5b                   	pop    %ebx
  8016b5:	5e                   	pop    %esi
  8016b6:	5d                   	pop    %ebp
  8016b7:	c3                   	ret    

008016b8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016b8:	55                   	push   %ebp
  8016b9:	89 e5                	mov    %esp,%ebp
  8016bb:	56                   	push   %esi
  8016bc:	53                   	push   %ebx
  8016bd:	89 c6                	mov    %eax,%esi
  8016bf:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016c1:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8016c8:	74 27                	je     8016f1 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016ca:	6a 07                	push   $0x7
  8016cc:	68 00 50 80 00       	push   $0x805000
  8016d1:	56                   	push   %esi
  8016d2:	ff 35 00 60 80 00    	push   0x806000
  8016d8:	e8 c7 f9 ff ff       	call   8010a4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016dd:	83 c4 0c             	add    $0xc,%esp
  8016e0:	6a 00                	push   $0x0
  8016e2:	53                   	push   %ebx
  8016e3:	6a 00                	push   $0x0
  8016e5:	e8 53 f9 ff ff       	call   80103d <ipc_recv>
}
  8016ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016ed:	5b                   	pop    %ebx
  8016ee:	5e                   	pop    %esi
  8016ef:	5d                   	pop    %ebp
  8016f0:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016f1:	83 ec 0c             	sub    $0xc,%esp
  8016f4:	6a 01                	push   $0x1
  8016f6:	e8 fd f9 ff ff       	call   8010f8 <ipc_find_env>
  8016fb:	a3 00 60 80 00       	mov    %eax,0x806000
  801700:	83 c4 10             	add    $0x10,%esp
  801703:	eb c5                	jmp    8016ca <fsipc+0x12>

00801705 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80170b:	8b 45 08             	mov    0x8(%ebp),%eax
  80170e:	8b 40 0c             	mov    0xc(%eax),%eax
  801711:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801716:	8b 45 0c             	mov    0xc(%ebp),%eax
  801719:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80171e:	ba 00 00 00 00       	mov    $0x0,%edx
  801723:	b8 02 00 00 00       	mov    $0x2,%eax
  801728:	e8 8b ff ff ff       	call   8016b8 <fsipc>
}
  80172d:	c9                   	leave  
  80172e:	c3                   	ret    

0080172f <devfile_flush>:
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801735:	8b 45 08             	mov    0x8(%ebp),%eax
  801738:	8b 40 0c             	mov    0xc(%eax),%eax
  80173b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801740:	ba 00 00 00 00       	mov    $0x0,%edx
  801745:	b8 06 00 00 00       	mov    $0x6,%eax
  80174a:	e8 69 ff ff ff       	call   8016b8 <fsipc>
}
  80174f:	c9                   	leave  
  801750:	c3                   	ret    

00801751 <devfile_stat>:
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	53                   	push   %ebx
  801755:	83 ec 04             	sub    $0x4,%esp
  801758:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80175b:	8b 45 08             	mov    0x8(%ebp),%eax
  80175e:	8b 40 0c             	mov    0xc(%eax),%eax
  801761:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801766:	ba 00 00 00 00       	mov    $0x0,%edx
  80176b:	b8 05 00 00 00       	mov    $0x5,%eax
  801770:	e8 43 ff ff ff       	call   8016b8 <fsipc>
  801775:	85 c0                	test   %eax,%eax
  801777:	78 2c                	js     8017a5 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801779:	83 ec 08             	sub    $0x8,%esp
  80177c:	68 00 50 80 00       	push   $0x805000
  801781:	53                   	push   %ebx
  801782:	e8 4b f0 ff ff       	call   8007d2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801787:	a1 80 50 80 00       	mov    0x805080,%eax
  80178c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801792:	a1 84 50 80 00       	mov    0x805084,%eax
  801797:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80179d:	83 c4 10             	add    $0x10,%esp
  8017a0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a8:	c9                   	leave  
  8017a9:	c3                   	ret    

008017aa <devfile_write>:
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	83 ec 0c             	sub    $0xc,%esp
  8017b0:	8b 45 10             	mov    0x10(%ebp),%eax
  8017b3:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017b8:	39 d0                	cmp    %edx,%eax
  8017ba:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8017c0:	8b 52 0c             	mov    0xc(%edx),%edx
  8017c3:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017c9:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017ce:	50                   	push   %eax
  8017cf:	ff 75 0c             	push   0xc(%ebp)
  8017d2:	68 08 50 80 00       	push   $0x805008
  8017d7:	e8 8c f1 ff ff       	call   800968 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8017dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e1:	b8 04 00 00 00       	mov    $0x4,%eax
  8017e6:	e8 cd fe ff ff       	call   8016b8 <fsipc>
}
  8017eb:	c9                   	leave  
  8017ec:	c3                   	ret    

008017ed <devfile_read>:
{
  8017ed:	55                   	push   %ebp
  8017ee:	89 e5                	mov    %esp,%ebp
  8017f0:	56                   	push   %esi
  8017f1:	53                   	push   %ebx
  8017f2:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017fb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801800:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801806:	ba 00 00 00 00       	mov    $0x0,%edx
  80180b:	b8 03 00 00 00       	mov    $0x3,%eax
  801810:	e8 a3 fe ff ff       	call   8016b8 <fsipc>
  801815:	89 c3                	mov    %eax,%ebx
  801817:	85 c0                	test   %eax,%eax
  801819:	78 1f                	js     80183a <devfile_read+0x4d>
	assert(r <= n);
  80181b:	39 f0                	cmp    %esi,%eax
  80181d:	77 24                	ja     801843 <devfile_read+0x56>
	assert(r <= PGSIZE);
  80181f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801824:	7f 33                	jg     801859 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801826:	83 ec 04             	sub    $0x4,%esp
  801829:	50                   	push   %eax
  80182a:	68 00 50 80 00       	push   $0x805000
  80182f:	ff 75 0c             	push   0xc(%ebp)
  801832:	e8 31 f1 ff ff       	call   800968 <memmove>
	return r;
  801837:	83 c4 10             	add    $0x10,%esp
}
  80183a:	89 d8                	mov    %ebx,%eax
  80183c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80183f:	5b                   	pop    %ebx
  801840:	5e                   	pop    %esi
  801841:	5d                   	pop    %ebp
  801842:	c3                   	ret    
	assert(r <= n);
  801843:	68 44 26 80 00       	push   $0x802644
  801848:	68 4b 26 80 00       	push   $0x80264b
  80184d:	6a 7c                	push   $0x7c
  80184f:	68 60 26 80 00       	push   $0x802660
  801854:	e8 79 05 00 00       	call   801dd2 <_panic>
	assert(r <= PGSIZE);
  801859:	68 6b 26 80 00       	push   $0x80266b
  80185e:	68 4b 26 80 00       	push   $0x80264b
  801863:	6a 7d                	push   $0x7d
  801865:	68 60 26 80 00       	push   $0x802660
  80186a:	e8 63 05 00 00       	call   801dd2 <_panic>

0080186f <open>:
{
  80186f:	55                   	push   %ebp
  801870:	89 e5                	mov    %esp,%ebp
  801872:	56                   	push   %esi
  801873:	53                   	push   %ebx
  801874:	83 ec 1c             	sub    $0x1c,%esp
  801877:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80187a:	56                   	push   %esi
  80187b:	e8 17 ef ff ff       	call   800797 <strlen>
  801880:	83 c4 10             	add    $0x10,%esp
  801883:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801888:	7f 6c                	jg     8018f6 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80188a:	83 ec 0c             	sub    $0xc,%esp
  80188d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801890:	50                   	push   %eax
  801891:	e8 c2 f8 ff ff       	call   801158 <fd_alloc>
  801896:	89 c3                	mov    %eax,%ebx
  801898:	83 c4 10             	add    $0x10,%esp
  80189b:	85 c0                	test   %eax,%eax
  80189d:	78 3c                	js     8018db <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80189f:	83 ec 08             	sub    $0x8,%esp
  8018a2:	56                   	push   %esi
  8018a3:	68 00 50 80 00       	push   $0x805000
  8018a8:	e8 25 ef ff ff       	call   8007d2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b0:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018b8:	b8 01 00 00 00       	mov    $0x1,%eax
  8018bd:	e8 f6 fd ff ff       	call   8016b8 <fsipc>
  8018c2:	89 c3                	mov    %eax,%ebx
  8018c4:	83 c4 10             	add    $0x10,%esp
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	78 19                	js     8018e4 <open+0x75>
	return fd2num(fd);
  8018cb:	83 ec 0c             	sub    $0xc,%esp
  8018ce:	ff 75 f4             	push   -0xc(%ebp)
  8018d1:	e8 5b f8 ff ff       	call   801131 <fd2num>
  8018d6:	89 c3                	mov    %eax,%ebx
  8018d8:	83 c4 10             	add    $0x10,%esp
}
  8018db:	89 d8                	mov    %ebx,%eax
  8018dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e0:	5b                   	pop    %ebx
  8018e1:	5e                   	pop    %esi
  8018e2:	5d                   	pop    %ebp
  8018e3:	c3                   	ret    
		fd_close(fd, 0);
  8018e4:	83 ec 08             	sub    $0x8,%esp
  8018e7:	6a 00                	push   $0x0
  8018e9:	ff 75 f4             	push   -0xc(%ebp)
  8018ec:	e8 58 f9 ff ff       	call   801249 <fd_close>
		return r;
  8018f1:	83 c4 10             	add    $0x10,%esp
  8018f4:	eb e5                	jmp    8018db <open+0x6c>
		return -E_BAD_PATH;
  8018f6:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8018fb:	eb de                	jmp    8018db <open+0x6c>

008018fd <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
  801900:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801903:	ba 00 00 00 00       	mov    $0x0,%edx
  801908:	b8 08 00 00 00       	mov    $0x8,%eax
  80190d:	e8 a6 fd ff ff       	call   8016b8 <fsipc>
}
  801912:	c9                   	leave  
  801913:	c3                   	ret    

00801914 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801914:	55                   	push   %ebp
  801915:	89 e5                	mov    %esp,%ebp
  801917:	56                   	push   %esi
  801918:	53                   	push   %ebx
  801919:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80191c:	83 ec 0c             	sub    $0xc,%esp
  80191f:	ff 75 08             	push   0x8(%ebp)
  801922:	e8 1a f8 ff ff       	call   801141 <fd2data>
  801927:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801929:	83 c4 08             	add    $0x8,%esp
  80192c:	68 77 26 80 00       	push   $0x802677
  801931:	53                   	push   %ebx
  801932:	e8 9b ee ff ff       	call   8007d2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801937:	8b 46 04             	mov    0x4(%esi),%eax
  80193a:	2b 06                	sub    (%esi),%eax
  80193c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801942:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801949:	00 00 00 
	stat->st_dev = &devpipe;
  80194c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801953:	30 80 00 
	return 0;
}
  801956:	b8 00 00 00 00       	mov    $0x0,%eax
  80195b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195e:	5b                   	pop    %ebx
  80195f:	5e                   	pop    %esi
  801960:	5d                   	pop    %ebp
  801961:	c3                   	ret    

00801962 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	53                   	push   %ebx
  801966:	83 ec 0c             	sub    $0xc,%esp
  801969:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80196c:	53                   	push   %ebx
  80196d:	6a 00                	push   $0x0
  80196f:	e8 df f2 ff ff       	call   800c53 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801974:	89 1c 24             	mov    %ebx,(%esp)
  801977:	e8 c5 f7 ff ff       	call   801141 <fd2data>
  80197c:	83 c4 08             	add    $0x8,%esp
  80197f:	50                   	push   %eax
  801980:	6a 00                	push   $0x0
  801982:	e8 cc f2 ff ff       	call   800c53 <sys_page_unmap>
}
  801987:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198a:	c9                   	leave  
  80198b:	c3                   	ret    

0080198c <_pipeisclosed>:
{
  80198c:	55                   	push   %ebp
  80198d:	89 e5                	mov    %esp,%ebp
  80198f:	57                   	push   %edi
  801990:	56                   	push   %esi
  801991:	53                   	push   %ebx
  801992:	83 ec 1c             	sub    $0x1c,%esp
  801995:	89 c7                	mov    %eax,%edi
  801997:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801999:	a1 04 40 80 00       	mov    0x804004,%eax
  80199e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019a1:	83 ec 0c             	sub    $0xc,%esp
  8019a4:	57                   	push   %edi
  8019a5:	e8 0a 05 00 00       	call   801eb4 <pageref>
  8019aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8019ad:	89 34 24             	mov    %esi,(%esp)
  8019b0:	e8 ff 04 00 00       	call   801eb4 <pageref>
		nn = thisenv->env_runs;
  8019b5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8019bb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8019be:	83 c4 10             	add    $0x10,%esp
  8019c1:	39 cb                	cmp    %ecx,%ebx
  8019c3:	74 1b                	je     8019e0 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8019c5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8019c8:	75 cf                	jne    801999 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8019ca:	8b 42 58             	mov    0x58(%edx),%eax
  8019cd:	6a 01                	push   $0x1
  8019cf:	50                   	push   %eax
  8019d0:	53                   	push   %ebx
  8019d1:	68 7e 26 80 00       	push   $0x80267e
  8019d6:	e8 1d e8 ff ff       	call   8001f8 <cprintf>
  8019db:	83 c4 10             	add    $0x10,%esp
  8019de:	eb b9                	jmp    801999 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8019e0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8019e3:	0f 94 c0             	sete   %al
  8019e6:	0f b6 c0             	movzbl %al,%eax
}
  8019e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019ec:	5b                   	pop    %ebx
  8019ed:	5e                   	pop    %esi
  8019ee:	5f                   	pop    %edi
  8019ef:	5d                   	pop    %ebp
  8019f0:	c3                   	ret    

008019f1 <devpipe_write>:
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	57                   	push   %edi
  8019f5:	56                   	push   %esi
  8019f6:	53                   	push   %ebx
  8019f7:	83 ec 28             	sub    $0x28,%esp
  8019fa:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8019fd:	56                   	push   %esi
  8019fe:	e8 3e f7 ff ff       	call   801141 <fd2data>
  801a03:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a05:	83 c4 10             	add    $0x10,%esp
  801a08:	bf 00 00 00 00       	mov    $0x0,%edi
  801a0d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a10:	75 09                	jne    801a1b <devpipe_write+0x2a>
	return i;
  801a12:	89 f8                	mov    %edi,%eax
  801a14:	eb 23                	jmp    801a39 <devpipe_write+0x48>
			sys_yield();
  801a16:	e8 94 f1 ff ff       	call   800baf <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a1b:	8b 43 04             	mov    0x4(%ebx),%eax
  801a1e:	8b 0b                	mov    (%ebx),%ecx
  801a20:	8d 51 20             	lea    0x20(%ecx),%edx
  801a23:	39 d0                	cmp    %edx,%eax
  801a25:	72 1a                	jb     801a41 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801a27:	89 da                	mov    %ebx,%edx
  801a29:	89 f0                	mov    %esi,%eax
  801a2b:	e8 5c ff ff ff       	call   80198c <_pipeisclosed>
  801a30:	85 c0                	test   %eax,%eax
  801a32:	74 e2                	je     801a16 <devpipe_write+0x25>
				return 0;
  801a34:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a3c:	5b                   	pop    %ebx
  801a3d:	5e                   	pop    %esi
  801a3e:	5f                   	pop    %edi
  801a3f:	5d                   	pop    %ebp
  801a40:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a44:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a48:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a4b:	89 c2                	mov    %eax,%edx
  801a4d:	c1 fa 1f             	sar    $0x1f,%edx
  801a50:	89 d1                	mov    %edx,%ecx
  801a52:	c1 e9 1b             	shr    $0x1b,%ecx
  801a55:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801a58:	83 e2 1f             	and    $0x1f,%edx
  801a5b:	29 ca                	sub    %ecx,%edx
  801a5d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801a61:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801a65:	83 c0 01             	add    $0x1,%eax
  801a68:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801a6b:	83 c7 01             	add    $0x1,%edi
  801a6e:	eb 9d                	jmp    801a0d <devpipe_write+0x1c>

00801a70 <devpipe_read>:
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	57                   	push   %edi
  801a74:	56                   	push   %esi
  801a75:	53                   	push   %ebx
  801a76:	83 ec 18             	sub    $0x18,%esp
  801a79:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801a7c:	57                   	push   %edi
  801a7d:	e8 bf f6 ff ff       	call   801141 <fd2data>
  801a82:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a84:	83 c4 10             	add    $0x10,%esp
  801a87:	be 00 00 00 00       	mov    $0x0,%esi
  801a8c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a8f:	75 13                	jne    801aa4 <devpipe_read+0x34>
	return i;
  801a91:	89 f0                	mov    %esi,%eax
  801a93:	eb 02                	jmp    801a97 <devpipe_read+0x27>
				return i;
  801a95:	89 f0                	mov    %esi,%eax
}
  801a97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a9a:	5b                   	pop    %ebx
  801a9b:	5e                   	pop    %esi
  801a9c:	5f                   	pop    %edi
  801a9d:	5d                   	pop    %ebp
  801a9e:	c3                   	ret    
			sys_yield();
  801a9f:	e8 0b f1 ff ff       	call   800baf <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801aa4:	8b 03                	mov    (%ebx),%eax
  801aa6:	3b 43 04             	cmp    0x4(%ebx),%eax
  801aa9:	75 18                	jne    801ac3 <devpipe_read+0x53>
			if (i > 0)
  801aab:	85 f6                	test   %esi,%esi
  801aad:	75 e6                	jne    801a95 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801aaf:	89 da                	mov    %ebx,%edx
  801ab1:	89 f8                	mov    %edi,%eax
  801ab3:	e8 d4 fe ff ff       	call   80198c <_pipeisclosed>
  801ab8:	85 c0                	test   %eax,%eax
  801aba:	74 e3                	je     801a9f <devpipe_read+0x2f>
				return 0;
  801abc:	b8 00 00 00 00       	mov    $0x0,%eax
  801ac1:	eb d4                	jmp    801a97 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801ac3:	99                   	cltd   
  801ac4:	c1 ea 1b             	shr    $0x1b,%edx
  801ac7:	01 d0                	add    %edx,%eax
  801ac9:	83 e0 1f             	and    $0x1f,%eax
  801acc:	29 d0                	sub    %edx,%eax
  801ace:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801ad3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ad6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ad9:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801adc:	83 c6 01             	add    $0x1,%esi
  801adf:	eb ab                	jmp    801a8c <devpipe_read+0x1c>

00801ae1 <pipe>:
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	56                   	push   %esi
  801ae5:	53                   	push   %ebx
  801ae6:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ae9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aec:	50                   	push   %eax
  801aed:	e8 66 f6 ff ff       	call   801158 <fd_alloc>
  801af2:	89 c3                	mov    %eax,%ebx
  801af4:	83 c4 10             	add    $0x10,%esp
  801af7:	85 c0                	test   %eax,%eax
  801af9:	0f 88 23 01 00 00    	js     801c22 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aff:	83 ec 04             	sub    $0x4,%esp
  801b02:	68 07 04 00 00       	push   $0x407
  801b07:	ff 75 f4             	push   -0xc(%ebp)
  801b0a:	6a 00                	push   $0x0
  801b0c:	e8 bd f0 ff ff       	call   800bce <sys_page_alloc>
  801b11:	89 c3                	mov    %eax,%ebx
  801b13:	83 c4 10             	add    $0x10,%esp
  801b16:	85 c0                	test   %eax,%eax
  801b18:	0f 88 04 01 00 00    	js     801c22 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801b1e:	83 ec 0c             	sub    $0xc,%esp
  801b21:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b24:	50                   	push   %eax
  801b25:	e8 2e f6 ff ff       	call   801158 <fd_alloc>
  801b2a:	89 c3                	mov    %eax,%ebx
  801b2c:	83 c4 10             	add    $0x10,%esp
  801b2f:	85 c0                	test   %eax,%eax
  801b31:	0f 88 db 00 00 00    	js     801c12 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b37:	83 ec 04             	sub    $0x4,%esp
  801b3a:	68 07 04 00 00       	push   $0x407
  801b3f:	ff 75 f0             	push   -0x10(%ebp)
  801b42:	6a 00                	push   $0x0
  801b44:	e8 85 f0 ff ff       	call   800bce <sys_page_alloc>
  801b49:	89 c3                	mov    %eax,%ebx
  801b4b:	83 c4 10             	add    $0x10,%esp
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	0f 88 bc 00 00 00    	js     801c12 <pipe+0x131>
	va = fd2data(fd0);
  801b56:	83 ec 0c             	sub    $0xc,%esp
  801b59:	ff 75 f4             	push   -0xc(%ebp)
  801b5c:	e8 e0 f5 ff ff       	call   801141 <fd2data>
  801b61:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b63:	83 c4 0c             	add    $0xc,%esp
  801b66:	68 07 04 00 00       	push   $0x407
  801b6b:	50                   	push   %eax
  801b6c:	6a 00                	push   $0x0
  801b6e:	e8 5b f0 ff ff       	call   800bce <sys_page_alloc>
  801b73:	89 c3                	mov    %eax,%ebx
  801b75:	83 c4 10             	add    $0x10,%esp
  801b78:	85 c0                	test   %eax,%eax
  801b7a:	0f 88 82 00 00 00    	js     801c02 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b80:	83 ec 0c             	sub    $0xc,%esp
  801b83:	ff 75 f0             	push   -0x10(%ebp)
  801b86:	e8 b6 f5 ff ff       	call   801141 <fd2data>
  801b8b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801b92:	50                   	push   %eax
  801b93:	6a 00                	push   $0x0
  801b95:	56                   	push   %esi
  801b96:	6a 00                	push   $0x0
  801b98:	e8 74 f0 ff ff       	call   800c11 <sys_page_map>
  801b9d:	89 c3                	mov    %eax,%ebx
  801b9f:	83 c4 20             	add    $0x20,%esp
  801ba2:	85 c0                	test   %eax,%eax
  801ba4:	78 4e                	js     801bf4 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801ba6:	a1 20 30 80 00       	mov    0x803020,%eax
  801bab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bae:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801bb0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bb3:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801bba:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bbd:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801bbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bc2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801bc9:	83 ec 0c             	sub    $0xc,%esp
  801bcc:	ff 75 f4             	push   -0xc(%ebp)
  801bcf:	e8 5d f5 ff ff       	call   801131 <fd2num>
  801bd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bd7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801bd9:	83 c4 04             	add    $0x4,%esp
  801bdc:	ff 75 f0             	push   -0x10(%ebp)
  801bdf:	e8 4d f5 ff ff       	call   801131 <fd2num>
  801be4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801be7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801bea:	83 c4 10             	add    $0x10,%esp
  801bed:	bb 00 00 00 00       	mov    $0x0,%ebx
  801bf2:	eb 2e                	jmp    801c22 <pipe+0x141>
	sys_page_unmap(0, va);
  801bf4:	83 ec 08             	sub    $0x8,%esp
  801bf7:	56                   	push   %esi
  801bf8:	6a 00                	push   $0x0
  801bfa:	e8 54 f0 ff ff       	call   800c53 <sys_page_unmap>
  801bff:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801c02:	83 ec 08             	sub    $0x8,%esp
  801c05:	ff 75 f0             	push   -0x10(%ebp)
  801c08:	6a 00                	push   $0x0
  801c0a:	e8 44 f0 ff ff       	call   800c53 <sys_page_unmap>
  801c0f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801c12:	83 ec 08             	sub    $0x8,%esp
  801c15:	ff 75 f4             	push   -0xc(%ebp)
  801c18:	6a 00                	push   $0x0
  801c1a:	e8 34 f0 ff ff       	call   800c53 <sys_page_unmap>
  801c1f:	83 c4 10             	add    $0x10,%esp
}
  801c22:	89 d8                	mov    %ebx,%eax
  801c24:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c27:	5b                   	pop    %ebx
  801c28:	5e                   	pop    %esi
  801c29:	5d                   	pop    %ebp
  801c2a:	c3                   	ret    

00801c2b <pipeisclosed>:
{
  801c2b:	55                   	push   %ebp
  801c2c:	89 e5                	mov    %esp,%ebp
  801c2e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c34:	50                   	push   %eax
  801c35:	ff 75 08             	push   0x8(%ebp)
  801c38:	e8 6b f5 ff ff       	call   8011a8 <fd_lookup>
  801c3d:	83 c4 10             	add    $0x10,%esp
  801c40:	85 c0                	test   %eax,%eax
  801c42:	78 18                	js     801c5c <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801c44:	83 ec 0c             	sub    $0xc,%esp
  801c47:	ff 75 f4             	push   -0xc(%ebp)
  801c4a:	e8 f2 f4 ff ff       	call   801141 <fd2data>
  801c4f:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801c51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c54:	e8 33 fd ff ff       	call   80198c <_pipeisclosed>
  801c59:	83 c4 10             	add    $0x10,%esp
}
  801c5c:	c9                   	leave  
  801c5d:	c3                   	ret    

00801c5e <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801c5e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c63:	c3                   	ret    

00801c64 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801c64:	55                   	push   %ebp
  801c65:	89 e5                	mov    %esp,%ebp
  801c67:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801c6a:	68 96 26 80 00       	push   $0x802696
  801c6f:	ff 75 0c             	push   0xc(%ebp)
  801c72:	e8 5b eb ff ff       	call   8007d2 <strcpy>
	return 0;
}
  801c77:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7c:	c9                   	leave  
  801c7d:	c3                   	ret    

00801c7e <devcons_write>:
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801c8a:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801c8f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801c95:	eb 2e                	jmp    801cc5 <devcons_write+0x47>
		m = n - tot;
  801c97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801c9a:	29 f3                	sub    %esi,%ebx
  801c9c:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801ca1:	39 c3                	cmp    %eax,%ebx
  801ca3:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ca6:	83 ec 04             	sub    $0x4,%esp
  801ca9:	53                   	push   %ebx
  801caa:	89 f0                	mov    %esi,%eax
  801cac:	03 45 0c             	add    0xc(%ebp),%eax
  801caf:	50                   	push   %eax
  801cb0:	57                   	push   %edi
  801cb1:	e8 b2 ec ff ff       	call   800968 <memmove>
		sys_cputs(buf, m);
  801cb6:	83 c4 08             	add    $0x8,%esp
  801cb9:	53                   	push   %ebx
  801cba:	57                   	push   %edi
  801cbb:	e8 52 ee ff ff       	call   800b12 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801cc0:	01 de                	add    %ebx,%esi
  801cc2:	83 c4 10             	add    $0x10,%esp
  801cc5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cc8:	72 cd                	jb     801c97 <devcons_write+0x19>
}
  801cca:	89 f0                	mov    %esi,%eax
  801ccc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ccf:	5b                   	pop    %ebx
  801cd0:	5e                   	pop    %esi
  801cd1:	5f                   	pop    %edi
  801cd2:	5d                   	pop    %ebp
  801cd3:	c3                   	ret    

00801cd4 <devcons_read>:
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	83 ec 08             	sub    $0x8,%esp
  801cda:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801cdf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ce3:	75 07                	jne    801cec <devcons_read+0x18>
  801ce5:	eb 1f                	jmp    801d06 <devcons_read+0x32>
		sys_yield();
  801ce7:	e8 c3 ee ff ff       	call   800baf <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801cec:	e8 3f ee ff ff       	call   800b30 <sys_cgetc>
  801cf1:	85 c0                	test   %eax,%eax
  801cf3:	74 f2                	je     801ce7 <devcons_read+0x13>
	if (c < 0)
  801cf5:	78 0f                	js     801d06 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801cf7:	83 f8 04             	cmp    $0x4,%eax
  801cfa:	74 0c                	je     801d08 <devcons_read+0x34>
	*(char*)vbuf = c;
  801cfc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cff:	88 02                	mov    %al,(%edx)
	return 1;
  801d01:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801d06:	c9                   	leave  
  801d07:	c3                   	ret    
		return 0;
  801d08:	b8 00 00 00 00       	mov    $0x0,%eax
  801d0d:	eb f7                	jmp    801d06 <devcons_read+0x32>

00801d0f <cputchar>:
{
  801d0f:	55                   	push   %ebp
  801d10:	89 e5                	mov    %esp,%ebp
  801d12:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801d15:	8b 45 08             	mov    0x8(%ebp),%eax
  801d18:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801d1b:	6a 01                	push   $0x1
  801d1d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d20:	50                   	push   %eax
  801d21:	e8 ec ed ff ff       	call   800b12 <sys_cputs>
}
  801d26:	83 c4 10             	add    $0x10,%esp
  801d29:	c9                   	leave  
  801d2a:	c3                   	ret    

00801d2b <getchar>:
{
  801d2b:	55                   	push   %ebp
  801d2c:	89 e5                	mov    %esp,%ebp
  801d2e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801d31:	6a 01                	push   $0x1
  801d33:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801d36:	50                   	push   %eax
  801d37:	6a 00                	push   $0x0
  801d39:	e8 ce f6 ff ff       	call   80140c <read>
	if (r < 0)
  801d3e:	83 c4 10             	add    $0x10,%esp
  801d41:	85 c0                	test   %eax,%eax
  801d43:	78 06                	js     801d4b <getchar+0x20>
	if (r < 1)
  801d45:	74 06                	je     801d4d <getchar+0x22>
	return c;
  801d47:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801d4b:	c9                   	leave  
  801d4c:	c3                   	ret    
		return -E_EOF;
  801d4d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801d52:	eb f7                	jmp    801d4b <getchar+0x20>

00801d54 <iscons>:
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d5d:	50                   	push   %eax
  801d5e:	ff 75 08             	push   0x8(%ebp)
  801d61:	e8 42 f4 ff ff       	call   8011a8 <fd_lookup>
  801d66:	83 c4 10             	add    $0x10,%esp
  801d69:	85 c0                	test   %eax,%eax
  801d6b:	78 11                	js     801d7e <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d70:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d76:	39 10                	cmp    %edx,(%eax)
  801d78:	0f 94 c0             	sete   %al
  801d7b:	0f b6 c0             	movzbl %al,%eax
}
  801d7e:	c9                   	leave  
  801d7f:	c3                   	ret    

00801d80 <opencons>:
{
  801d80:	55                   	push   %ebp
  801d81:	89 e5                	mov    %esp,%ebp
  801d83:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801d86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d89:	50                   	push   %eax
  801d8a:	e8 c9 f3 ff ff       	call   801158 <fd_alloc>
  801d8f:	83 c4 10             	add    $0x10,%esp
  801d92:	85 c0                	test   %eax,%eax
  801d94:	78 3a                	js     801dd0 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801d96:	83 ec 04             	sub    $0x4,%esp
  801d99:	68 07 04 00 00       	push   $0x407
  801d9e:	ff 75 f4             	push   -0xc(%ebp)
  801da1:	6a 00                	push   $0x0
  801da3:	e8 26 ee ff ff       	call   800bce <sys_page_alloc>
  801da8:	83 c4 10             	add    $0x10,%esp
  801dab:	85 c0                	test   %eax,%eax
  801dad:	78 21                	js     801dd0 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801daf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801db2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801db8:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801dba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dbd:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801dc4:	83 ec 0c             	sub    $0xc,%esp
  801dc7:	50                   	push   %eax
  801dc8:	e8 64 f3 ff ff       	call   801131 <fd2num>
  801dcd:	83 c4 10             	add    $0x10,%esp
}
  801dd0:	c9                   	leave  
  801dd1:	c3                   	ret    

00801dd2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
  801dd5:	56                   	push   %esi
  801dd6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801dd7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801dda:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801de0:	e8 ab ed ff ff       	call   800b90 <sys_getenvid>
  801de5:	83 ec 0c             	sub    $0xc,%esp
  801de8:	ff 75 0c             	push   0xc(%ebp)
  801deb:	ff 75 08             	push   0x8(%ebp)
  801dee:	56                   	push   %esi
  801def:	50                   	push   %eax
  801df0:	68 a4 26 80 00       	push   $0x8026a4
  801df5:	e8 fe e3 ff ff       	call   8001f8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801dfa:	83 c4 18             	add    $0x18,%esp
  801dfd:	53                   	push   %ebx
  801dfe:	ff 75 10             	push   0x10(%ebp)
  801e01:	e8 a1 e3 ff ff       	call   8001a7 <vcprintf>
	cprintf("\n");
  801e06:	c7 04 24 8f 26 80 00 	movl   $0x80268f,(%esp)
  801e0d:	e8 e6 e3 ff ff       	call   8001f8 <cprintf>
  801e12:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e15:	cc                   	int3   
  801e16:	eb fd                	jmp    801e15 <_panic+0x43>

00801e18 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e18:	55                   	push   %ebp
  801e19:	89 e5                	mov    %esp,%ebp
  801e1b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  801e1e:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  801e25:	74 0a                	je     801e31 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e27:	8b 45 08             	mov    0x8(%ebp),%eax
  801e2a:	a3 04 60 80 00       	mov    %eax,0x806004
}
  801e2f:	c9                   	leave  
  801e30:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  801e31:	e8 5a ed ff ff       	call   800b90 <sys_getenvid>
  801e36:	83 ec 04             	sub    $0x4,%esp
  801e39:	68 07 0e 00 00       	push   $0xe07
  801e3e:	68 00 f0 bf ee       	push   $0xeebff000
  801e43:	50                   	push   %eax
  801e44:	e8 85 ed ff ff       	call   800bce <sys_page_alloc>
		if (r < 0) {
  801e49:	83 c4 10             	add    $0x10,%esp
  801e4c:	85 c0                	test   %eax,%eax
  801e4e:	78 2c                	js     801e7c <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801e50:	e8 3b ed ff ff       	call   800b90 <sys_getenvid>
  801e55:	83 ec 08             	sub    $0x8,%esp
  801e58:	68 8e 1e 80 00       	push   $0x801e8e
  801e5d:	50                   	push   %eax
  801e5e:	e8 b6 ee ff ff       	call   800d19 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801e63:	83 c4 10             	add    $0x10,%esp
  801e66:	85 c0                	test   %eax,%eax
  801e68:	79 bd                	jns    801e27 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  801e6a:	50                   	push   %eax
  801e6b:	68 08 27 80 00       	push   $0x802708
  801e70:	6a 28                	push   $0x28
  801e72:	68 3e 27 80 00       	push   $0x80273e
  801e77:	e8 56 ff ff ff       	call   801dd2 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  801e7c:	50                   	push   %eax
  801e7d:	68 c8 26 80 00       	push   $0x8026c8
  801e82:	6a 23                	push   $0x23
  801e84:	68 3e 27 80 00       	push   $0x80273e
  801e89:	e8 44 ff ff ff       	call   801dd2 <_panic>

00801e8e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e8e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e8f:	a1 04 60 80 00       	mov    0x806004,%eax
	call *%eax
  801e94:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e96:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  801e99:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  801e9d:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801ea0:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  801ea4:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801ea8:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  801eaa:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  801ead:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  801eae:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  801eb1:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  801eb2:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  801eb3:	c3                   	ret    

00801eb4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801eb4:	55                   	push   %ebp
  801eb5:	89 e5                	mov    %esp,%ebp
  801eb7:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801eba:	89 c2                	mov    %eax,%edx
  801ebc:	c1 ea 16             	shr    $0x16,%edx
  801ebf:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801ec6:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801ecb:	f6 c1 01             	test   $0x1,%cl
  801ece:	74 1c                	je     801eec <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801ed0:	c1 e8 0c             	shr    $0xc,%eax
  801ed3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801eda:	a8 01                	test   $0x1,%al
  801edc:	74 0e                	je     801eec <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ede:	c1 e8 0c             	shr    $0xc,%eax
  801ee1:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801ee8:	ef 
  801ee9:	0f b7 d2             	movzwl %dx,%edx
}
  801eec:	89 d0                	mov    %edx,%eax
  801eee:	5d                   	pop    %ebp
  801eef:	c3                   	ret    

00801ef0 <__udivdi3>:
  801ef0:	f3 0f 1e fb          	endbr32 
  801ef4:	55                   	push   %ebp
  801ef5:	57                   	push   %edi
  801ef6:	56                   	push   %esi
  801ef7:	53                   	push   %ebx
  801ef8:	83 ec 1c             	sub    $0x1c,%esp
  801efb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801eff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801f03:	8b 74 24 34          	mov    0x34(%esp),%esi
  801f07:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801f0b:	85 c0                	test   %eax,%eax
  801f0d:	75 19                	jne    801f28 <__udivdi3+0x38>
  801f0f:	39 f3                	cmp    %esi,%ebx
  801f11:	76 4d                	jbe    801f60 <__udivdi3+0x70>
  801f13:	31 ff                	xor    %edi,%edi
  801f15:	89 e8                	mov    %ebp,%eax
  801f17:	89 f2                	mov    %esi,%edx
  801f19:	f7 f3                	div    %ebx
  801f1b:	89 fa                	mov    %edi,%edx
  801f1d:	83 c4 1c             	add    $0x1c,%esp
  801f20:	5b                   	pop    %ebx
  801f21:	5e                   	pop    %esi
  801f22:	5f                   	pop    %edi
  801f23:	5d                   	pop    %ebp
  801f24:	c3                   	ret    
  801f25:	8d 76 00             	lea    0x0(%esi),%esi
  801f28:	39 f0                	cmp    %esi,%eax
  801f2a:	76 14                	jbe    801f40 <__udivdi3+0x50>
  801f2c:	31 ff                	xor    %edi,%edi
  801f2e:	31 c0                	xor    %eax,%eax
  801f30:	89 fa                	mov    %edi,%edx
  801f32:	83 c4 1c             	add    $0x1c,%esp
  801f35:	5b                   	pop    %ebx
  801f36:	5e                   	pop    %esi
  801f37:	5f                   	pop    %edi
  801f38:	5d                   	pop    %ebp
  801f39:	c3                   	ret    
  801f3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f40:	0f bd f8             	bsr    %eax,%edi
  801f43:	83 f7 1f             	xor    $0x1f,%edi
  801f46:	75 48                	jne    801f90 <__udivdi3+0xa0>
  801f48:	39 f0                	cmp    %esi,%eax
  801f4a:	72 06                	jb     801f52 <__udivdi3+0x62>
  801f4c:	31 c0                	xor    %eax,%eax
  801f4e:	39 eb                	cmp    %ebp,%ebx
  801f50:	77 de                	ja     801f30 <__udivdi3+0x40>
  801f52:	b8 01 00 00 00       	mov    $0x1,%eax
  801f57:	eb d7                	jmp    801f30 <__udivdi3+0x40>
  801f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f60:	89 d9                	mov    %ebx,%ecx
  801f62:	85 db                	test   %ebx,%ebx
  801f64:	75 0b                	jne    801f71 <__udivdi3+0x81>
  801f66:	b8 01 00 00 00       	mov    $0x1,%eax
  801f6b:	31 d2                	xor    %edx,%edx
  801f6d:	f7 f3                	div    %ebx
  801f6f:	89 c1                	mov    %eax,%ecx
  801f71:	31 d2                	xor    %edx,%edx
  801f73:	89 f0                	mov    %esi,%eax
  801f75:	f7 f1                	div    %ecx
  801f77:	89 c6                	mov    %eax,%esi
  801f79:	89 e8                	mov    %ebp,%eax
  801f7b:	89 f7                	mov    %esi,%edi
  801f7d:	f7 f1                	div    %ecx
  801f7f:	89 fa                	mov    %edi,%edx
  801f81:	83 c4 1c             	add    $0x1c,%esp
  801f84:	5b                   	pop    %ebx
  801f85:	5e                   	pop    %esi
  801f86:	5f                   	pop    %edi
  801f87:	5d                   	pop    %ebp
  801f88:	c3                   	ret    
  801f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f90:	89 f9                	mov    %edi,%ecx
  801f92:	ba 20 00 00 00       	mov    $0x20,%edx
  801f97:	29 fa                	sub    %edi,%edx
  801f99:	d3 e0                	shl    %cl,%eax
  801f9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f9f:	89 d1                	mov    %edx,%ecx
  801fa1:	89 d8                	mov    %ebx,%eax
  801fa3:	d3 e8                	shr    %cl,%eax
  801fa5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801fa9:	09 c1                	or     %eax,%ecx
  801fab:	89 f0                	mov    %esi,%eax
  801fad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801fb1:	89 f9                	mov    %edi,%ecx
  801fb3:	d3 e3                	shl    %cl,%ebx
  801fb5:	89 d1                	mov    %edx,%ecx
  801fb7:	d3 e8                	shr    %cl,%eax
  801fb9:	89 f9                	mov    %edi,%ecx
  801fbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801fbf:	89 eb                	mov    %ebp,%ebx
  801fc1:	d3 e6                	shl    %cl,%esi
  801fc3:	89 d1                	mov    %edx,%ecx
  801fc5:	d3 eb                	shr    %cl,%ebx
  801fc7:	09 f3                	or     %esi,%ebx
  801fc9:	89 c6                	mov    %eax,%esi
  801fcb:	89 f2                	mov    %esi,%edx
  801fcd:	89 d8                	mov    %ebx,%eax
  801fcf:	f7 74 24 08          	divl   0x8(%esp)
  801fd3:	89 d6                	mov    %edx,%esi
  801fd5:	89 c3                	mov    %eax,%ebx
  801fd7:	f7 64 24 0c          	mull   0xc(%esp)
  801fdb:	39 d6                	cmp    %edx,%esi
  801fdd:	72 19                	jb     801ff8 <__udivdi3+0x108>
  801fdf:	89 f9                	mov    %edi,%ecx
  801fe1:	d3 e5                	shl    %cl,%ebp
  801fe3:	39 c5                	cmp    %eax,%ebp
  801fe5:	73 04                	jae    801feb <__udivdi3+0xfb>
  801fe7:	39 d6                	cmp    %edx,%esi
  801fe9:	74 0d                	je     801ff8 <__udivdi3+0x108>
  801feb:	89 d8                	mov    %ebx,%eax
  801fed:	31 ff                	xor    %edi,%edi
  801fef:	e9 3c ff ff ff       	jmp    801f30 <__udivdi3+0x40>
  801ff4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ff8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801ffb:	31 ff                	xor    %edi,%edi
  801ffd:	e9 2e ff ff ff       	jmp    801f30 <__udivdi3+0x40>
  802002:	66 90                	xchg   %ax,%ax
  802004:	66 90                	xchg   %ax,%ax
  802006:	66 90                	xchg   %ax,%ax
  802008:	66 90                	xchg   %ax,%ax
  80200a:	66 90                	xchg   %ax,%ax
  80200c:	66 90                	xchg   %ax,%ax
  80200e:	66 90                	xchg   %ax,%ax

00802010 <__umoddi3>:
  802010:	f3 0f 1e fb          	endbr32 
  802014:	55                   	push   %ebp
  802015:	57                   	push   %edi
  802016:	56                   	push   %esi
  802017:	53                   	push   %ebx
  802018:	83 ec 1c             	sub    $0x1c,%esp
  80201b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80201f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802023:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802027:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80202b:	89 f0                	mov    %esi,%eax
  80202d:	89 da                	mov    %ebx,%edx
  80202f:	85 ff                	test   %edi,%edi
  802031:	75 15                	jne    802048 <__umoddi3+0x38>
  802033:	39 dd                	cmp    %ebx,%ebp
  802035:	76 39                	jbe    802070 <__umoddi3+0x60>
  802037:	f7 f5                	div    %ebp
  802039:	89 d0                	mov    %edx,%eax
  80203b:	31 d2                	xor    %edx,%edx
  80203d:	83 c4 1c             	add    $0x1c,%esp
  802040:	5b                   	pop    %ebx
  802041:	5e                   	pop    %esi
  802042:	5f                   	pop    %edi
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    
  802045:	8d 76 00             	lea    0x0(%esi),%esi
  802048:	39 df                	cmp    %ebx,%edi
  80204a:	77 f1                	ja     80203d <__umoddi3+0x2d>
  80204c:	0f bd cf             	bsr    %edi,%ecx
  80204f:	83 f1 1f             	xor    $0x1f,%ecx
  802052:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802056:	75 40                	jne    802098 <__umoddi3+0x88>
  802058:	39 df                	cmp    %ebx,%edi
  80205a:	72 04                	jb     802060 <__umoddi3+0x50>
  80205c:	39 f5                	cmp    %esi,%ebp
  80205e:	77 dd                	ja     80203d <__umoddi3+0x2d>
  802060:	89 da                	mov    %ebx,%edx
  802062:	89 f0                	mov    %esi,%eax
  802064:	29 e8                	sub    %ebp,%eax
  802066:	19 fa                	sbb    %edi,%edx
  802068:	eb d3                	jmp    80203d <__umoddi3+0x2d>
  80206a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802070:	89 e9                	mov    %ebp,%ecx
  802072:	85 ed                	test   %ebp,%ebp
  802074:	75 0b                	jne    802081 <__umoddi3+0x71>
  802076:	b8 01 00 00 00       	mov    $0x1,%eax
  80207b:	31 d2                	xor    %edx,%edx
  80207d:	f7 f5                	div    %ebp
  80207f:	89 c1                	mov    %eax,%ecx
  802081:	89 d8                	mov    %ebx,%eax
  802083:	31 d2                	xor    %edx,%edx
  802085:	f7 f1                	div    %ecx
  802087:	89 f0                	mov    %esi,%eax
  802089:	f7 f1                	div    %ecx
  80208b:	89 d0                	mov    %edx,%eax
  80208d:	31 d2                	xor    %edx,%edx
  80208f:	eb ac                	jmp    80203d <__umoddi3+0x2d>
  802091:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802098:	8b 44 24 04          	mov    0x4(%esp),%eax
  80209c:	ba 20 00 00 00       	mov    $0x20,%edx
  8020a1:	29 c2                	sub    %eax,%edx
  8020a3:	89 c1                	mov    %eax,%ecx
  8020a5:	89 e8                	mov    %ebp,%eax
  8020a7:	d3 e7                	shl    %cl,%edi
  8020a9:	89 d1                	mov    %edx,%ecx
  8020ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8020af:	d3 e8                	shr    %cl,%eax
  8020b1:	89 c1                	mov    %eax,%ecx
  8020b3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8020b7:	09 f9                	or     %edi,%ecx
  8020b9:	89 df                	mov    %ebx,%edi
  8020bb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020bf:	89 c1                	mov    %eax,%ecx
  8020c1:	d3 e5                	shl    %cl,%ebp
  8020c3:	89 d1                	mov    %edx,%ecx
  8020c5:	d3 ef                	shr    %cl,%edi
  8020c7:	89 c1                	mov    %eax,%ecx
  8020c9:	89 f0                	mov    %esi,%eax
  8020cb:	d3 e3                	shl    %cl,%ebx
  8020cd:	89 d1                	mov    %edx,%ecx
  8020cf:	89 fa                	mov    %edi,%edx
  8020d1:	d3 e8                	shr    %cl,%eax
  8020d3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8020d8:	09 d8                	or     %ebx,%eax
  8020da:	f7 74 24 08          	divl   0x8(%esp)
  8020de:	89 d3                	mov    %edx,%ebx
  8020e0:	d3 e6                	shl    %cl,%esi
  8020e2:	f7 e5                	mul    %ebp
  8020e4:	89 c7                	mov    %eax,%edi
  8020e6:	89 d1                	mov    %edx,%ecx
  8020e8:	39 d3                	cmp    %edx,%ebx
  8020ea:	72 06                	jb     8020f2 <__umoddi3+0xe2>
  8020ec:	75 0e                	jne    8020fc <__umoddi3+0xec>
  8020ee:	39 c6                	cmp    %eax,%esi
  8020f0:	73 0a                	jae    8020fc <__umoddi3+0xec>
  8020f2:	29 e8                	sub    %ebp,%eax
  8020f4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8020f8:	89 d1                	mov    %edx,%ecx
  8020fa:	89 c7                	mov    %eax,%edi
  8020fc:	89 f5                	mov    %esi,%ebp
  8020fe:	8b 74 24 04          	mov    0x4(%esp),%esi
  802102:	29 fd                	sub    %edi,%ebp
  802104:	19 cb                	sbb    %ecx,%ebx
  802106:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80210b:	89 d8                	mov    %ebx,%eax
  80210d:	d3 e0                	shl    %cl,%eax
  80210f:	89 f1                	mov    %esi,%ecx
  802111:	d3 ed                	shr    %cl,%ebp
  802113:	d3 eb                	shr    %cl,%ebx
  802115:	09 e8                	or     %ebp,%eax
  802117:	89 da                	mov    %ebx,%edx
  802119:	83 c4 1c             	add    $0x1c,%esp
  80211c:	5b                   	pop    %ebx
  80211d:	5e                   	pop    %esi
  80211e:	5f                   	pop    %edi
  80211f:	5d                   	pop    %ebp
  802120:	c3                   	ret    
