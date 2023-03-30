
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
  80003c:	e8 43 10 00 00       	call   801084 <sfork>
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
  800053:	e8 46 10 00 00       	call   80109e <ipc_recv>
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
  80007b:	68 30 26 80 00       	push   $0x802630
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
  8000a3:	e8 5d 10 00 00       	call   801105 <ipc_send>
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
  8000cc:	68 00 26 80 00       	push   $0x802600
  8000d1:	e8 22 01 00 00       	call   8001f8 <cprintf>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000d6:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8000d9:	e8 b2 0a 00 00       	call   800b90 <sys_getenvid>
  8000de:	83 c4 0c             	add    $0xc,%esp
  8000e1:	53                   	push   %ebx
  8000e2:	50                   	push   %eax
  8000e3:	68 1a 26 80 00       	push   $0x80261a
  8000e8:	e8 0b 01 00 00       	call   8001f8 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000ed:	6a 00                	push   $0x0
  8000ef:	6a 00                	push   $0x0
  8000f1:	6a 00                	push   $0x0
  8000f3:	ff 75 e4             	push   -0x1c(%ebp)
  8000f6:	e8 0a 10 00 00       	call   801105 <ipc_send>
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
  80014f:	e8 0f 12 00 00       	call   801363 <close_all>
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
  80025a:	e8 61 21 00 00       	call   8023c0 <__udivdi3>
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
  800298:	e8 43 22 00 00       	call   8024e0 <__umoddi3>
  80029d:	83 c4 14             	add    $0x14,%esp
  8002a0:	0f be 80 60 26 80 00 	movsbl 0x802660(%eax),%eax
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
  80035a:	ff 24 85 a0 27 80 00 	jmp    *0x8027a0(,%eax,4)
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
  800428:	8b 14 85 00 29 80 00 	mov    0x802900(,%eax,4),%edx
  80042f:	85 d2                	test   %edx,%edx
  800431:	74 18                	je     80044b <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800433:	52                   	push   %edx
  800434:	68 21 2b 80 00       	push   $0x802b21
  800439:	53                   	push   %ebx
  80043a:	56                   	push   %esi
  80043b:	e8 92 fe ff ff       	call   8002d2 <printfmt>
  800440:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800443:	89 7d 14             	mov    %edi,0x14(%ebp)
  800446:	e9 66 02 00 00       	jmp    8006b1 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80044b:	50                   	push   %eax
  80044c:	68 78 26 80 00       	push   $0x802678
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
  800473:	b8 71 26 80 00       	mov    $0x802671,%eax
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
  800b7f:	68 5f 29 80 00       	push   $0x80295f
  800b84:	6a 2a                	push   $0x2a
  800b86:	68 7c 29 80 00       	push   $0x80297c
  800b8b:	e8 10 17 00 00       	call   8022a0 <_panic>

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
  800c00:	68 5f 29 80 00       	push   $0x80295f
  800c05:	6a 2a                	push   $0x2a
  800c07:	68 7c 29 80 00       	push   $0x80297c
  800c0c:	e8 8f 16 00 00       	call   8022a0 <_panic>

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
  800c42:	68 5f 29 80 00       	push   $0x80295f
  800c47:	6a 2a                	push   $0x2a
  800c49:	68 7c 29 80 00       	push   $0x80297c
  800c4e:	e8 4d 16 00 00       	call   8022a0 <_panic>

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
  800c84:	68 5f 29 80 00       	push   $0x80295f
  800c89:	6a 2a                	push   $0x2a
  800c8b:	68 7c 29 80 00       	push   $0x80297c
  800c90:	e8 0b 16 00 00       	call   8022a0 <_panic>

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
  800cc6:	68 5f 29 80 00       	push   $0x80295f
  800ccb:	6a 2a                	push   $0x2a
  800ccd:	68 7c 29 80 00       	push   $0x80297c
  800cd2:	e8 c9 15 00 00       	call   8022a0 <_panic>

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
  800d08:	68 5f 29 80 00       	push   $0x80295f
  800d0d:	6a 2a                	push   $0x2a
  800d0f:	68 7c 29 80 00       	push   $0x80297c
  800d14:	e8 87 15 00 00       	call   8022a0 <_panic>

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
  800d4a:	68 5f 29 80 00       	push   $0x80295f
  800d4f:	6a 2a                	push   $0x2a
  800d51:	68 7c 29 80 00       	push   $0x80297c
  800d56:	e8 45 15 00 00       	call   8022a0 <_panic>

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
  800dae:	68 5f 29 80 00       	push   $0x80295f
  800db3:	6a 2a                	push   $0x2a
  800db5:	68 7c 29 80 00       	push   $0x80297c
  800dba:	e8 e1 14 00 00       	call   8022a0 <_panic>

00800dbf <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800dca:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dcf:	89 d1                	mov    %edx,%ecx
  800dd1:	89 d3                	mov    %edx,%ebx
  800dd3:	89 d7                	mov    %edx,%edi
  800dd5:	89 d6                	mov    %edx,%esi
  800dd7:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dd9:	5b                   	pop    %ebx
  800dda:	5e                   	pop    %esi
  800ddb:	5f                   	pop    %edi
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    

00800dde <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	57                   	push   %edi
  800de2:	56                   	push   %esi
  800de3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800de4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800de9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800def:	b8 0f 00 00 00       	mov    $0xf,%eax
  800df4:	89 df                	mov    %ebx,%edi
  800df6:	89 de                	mov    %ebx,%esi
  800df8:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800dfa:	5b                   	pop    %ebx
  800dfb:	5e                   	pop    %esi
  800dfc:	5f                   	pop    %edi
  800dfd:	5d                   	pop    %ebp
  800dfe:	c3                   	ret    

00800dff <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800dff:	55                   	push   %ebp
  800e00:	89 e5                	mov    %esp,%ebp
  800e02:	57                   	push   %edi
  800e03:	56                   	push   %esi
  800e04:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e10:	b8 10 00 00 00       	mov    $0x10,%eax
  800e15:	89 df                	mov    %ebx,%edi
  800e17:	89 de                	mov    %ebx,%esi
  800e19:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800e1b:	5b                   	pop    %ebx
  800e1c:	5e                   	pop    %esi
  800e1d:	5f                   	pop    %edi
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	56                   	push   %esi
  800e24:	53                   	push   %ebx
  800e25:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e28:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e2a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e2e:	0f 84 8e 00 00 00    	je     800ec2 <pgfault+0xa2>
  800e34:	89 f0                	mov    %esi,%eax
  800e36:	c1 e8 0c             	shr    $0xc,%eax
  800e39:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e40:	f6 c4 08             	test   $0x8,%ah
  800e43:	74 7d                	je     800ec2 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800e45:	e8 46 fd ff ff       	call   800b90 <sys_getenvid>
  800e4a:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800e4c:	83 ec 04             	sub    $0x4,%esp
  800e4f:	6a 07                	push   $0x7
  800e51:	68 00 f0 7f 00       	push   $0x7ff000
  800e56:	50                   	push   %eax
  800e57:	e8 72 fd ff ff       	call   800bce <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e5c:	83 c4 10             	add    $0x10,%esp
  800e5f:	85 c0                	test   %eax,%eax
  800e61:	78 73                	js     800ed6 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800e63:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800e69:	83 ec 04             	sub    $0x4,%esp
  800e6c:	68 00 10 00 00       	push   $0x1000
  800e71:	56                   	push   %esi
  800e72:	68 00 f0 7f 00       	push   $0x7ff000
  800e77:	e8 ec fa ff ff       	call   800968 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800e7c:	83 c4 08             	add    $0x8,%esp
  800e7f:	56                   	push   %esi
  800e80:	53                   	push   %ebx
  800e81:	e8 cd fd ff ff       	call   800c53 <sys_page_unmap>
  800e86:	83 c4 10             	add    $0x10,%esp
  800e89:	85 c0                	test   %eax,%eax
  800e8b:	78 5b                	js     800ee8 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800e8d:	83 ec 0c             	sub    $0xc,%esp
  800e90:	6a 07                	push   $0x7
  800e92:	56                   	push   %esi
  800e93:	53                   	push   %ebx
  800e94:	68 00 f0 7f 00       	push   $0x7ff000
  800e99:	53                   	push   %ebx
  800e9a:	e8 72 fd ff ff       	call   800c11 <sys_page_map>
  800e9f:	83 c4 20             	add    $0x20,%esp
  800ea2:	85 c0                	test   %eax,%eax
  800ea4:	78 54                	js     800efa <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800ea6:	83 ec 08             	sub    $0x8,%esp
  800ea9:	68 00 f0 7f 00       	push   $0x7ff000
  800eae:	53                   	push   %ebx
  800eaf:	e8 9f fd ff ff       	call   800c53 <sys_page_unmap>
  800eb4:	83 c4 10             	add    $0x10,%esp
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	78 51                	js     800f0c <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800ebb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ebe:	5b                   	pop    %ebx
  800ebf:	5e                   	pop    %esi
  800ec0:	5d                   	pop    %ebp
  800ec1:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800ec2:	83 ec 04             	sub    $0x4,%esp
  800ec5:	68 8c 29 80 00       	push   $0x80298c
  800eca:	6a 1d                	push   $0x1d
  800ecc:	68 08 2a 80 00       	push   $0x802a08
  800ed1:	e8 ca 13 00 00       	call   8022a0 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800ed6:	50                   	push   %eax
  800ed7:	68 c4 29 80 00       	push   $0x8029c4
  800edc:	6a 29                	push   $0x29
  800ede:	68 08 2a 80 00       	push   $0x802a08
  800ee3:	e8 b8 13 00 00       	call   8022a0 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800ee8:	50                   	push   %eax
  800ee9:	68 e8 29 80 00       	push   $0x8029e8
  800eee:	6a 2e                	push   $0x2e
  800ef0:	68 08 2a 80 00       	push   $0x802a08
  800ef5:	e8 a6 13 00 00       	call   8022a0 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800efa:	50                   	push   %eax
  800efb:	68 13 2a 80 00       	push   $0x802a13
  800f00:	6a 30                	push   $0x30
  800f02:	68 08 2a 80 00       	push   $0x802a08
  800f07:	e8 94 13 00 00       	call   8022a0 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800f0c:	50                   	push   %eax
  800f0d:	68 e8 29 80 00       	push   $0x8029e8
  800f12:	6a 32                	push   $0x32
  800f14:	68 08 2a 80 00       	push   $0x802a08
  800f19:	e8 82 13 00 00       	call   8022a0 <_panic>

00800f1e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	57                   	push   %edi
  800f22:	56                   	push   %esi
  800f23:	53                   	push   %ebx
  800f24:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800f27:	68 20 0e 80 00       	push   $0x800e20
  800f2c:	e8 b5 13 00 00       	call   8022e6 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f31:	b8 07 00 00 00       	mov    $0x7,%eax
  800f36:	cd 30                	int    $0x30
  800f38:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800f3b:	83 c4 10             	add    $0x10,%esp
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	78 2d                	js     800f6f <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f42:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800f47:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f4b:	75 73                	jne    800fc0 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f4d:	e8 3e fc ff ff       	call   800b90 <sys_getenvid>
  800f52:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f57:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f5a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f5f:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  800f64:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800f67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f6a:	5b                   	pop    %ebx
  800f6b:	5e                   	pop    %esi
  800f6c:	5f                   	pop    %edi
  800f6d:	5d                   	pop    %ebp
  800f6e:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  800f6f:	50                   	push   %eax
  800f70:	68 31 2a 80 00       	push   $0x802a31
  800f75:	6a 78                	push   $0x78
  800f77:	68 08 2a 80 00       	push   $0x802a08
  800f7c:	e8 1f 13 00 00       	call   8022a0 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  800f81:	83 ec 0c             	sub    $0xc,%esp
  800f84:	ff 75 e4             	push   -0x1c(%ebp)
  800f87:	57                   	push   %edi
  800f88:	ff 75 dc             	push   -0x24(%ebp)
  800f8b:	57                   	push   %edi
  800f8c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800f8f:	56                   	push   %esi
  800f90:	e8 7c fc ff ff       	call   800c11 <sys_page_map>
	if(r<0) return r;
  800f95:	83 c4 20             	add    $0x20,%esp
  800f98:	85 c0                	test   %eax,%eax
  800f9a:	78 cb                	js     800f67 <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  800f9c:	83 ec 0c             	sub    $0xc,%esp
  800f9f:	ff 75 e4             	push   -0x1c(%ebp)
  800fa2:	57                   	push   %edi
  800fa3:	56                   	push   %esi
  800fa4:	57                   	push   %edi
  800fa5:	56                   	push   %esi
  800fa6:	e8 66 fc ff ff       	call   800c11 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800fab:	83 c4 20             	add    $0x20,%esp
  800fae:	85 c0                	test   %eax,%eax
  800fb0:	78 76                	js     801028 <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800fb2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800fb8:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fbe:	74 75                	je     801035 <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800fc0:	89 d8                	mov    %ebx,%eax
  800fc2:	c1 e8 16             	shr    $0x16,%eax
  800fc5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fcc:	a8 01                	test   $0x1,%al
  800fce:	74 e2                	je     800fb2 <fork+0x94>
  800fd0:	89 de                	mov    %ebx,%esi
  800fd2:	c1 ee 0c             	shr    $0xc,%esi
  800fd5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fdc:	a8 01                	test   $0x1,%al
  800fde:	74 d2                	je     800fb2 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  800fe0:	e8 ab fb ff ff       	call   800b90 <sys_getenvid>
  800fe5:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  800fe8:	89 f7                	mov    %esi,%edi
  800fea:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  800fed:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800ff4:	89 c1                	mov    %eax,%ecx
  800ff6:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  800ffc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  800fff:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  801006:	f6 c6 04             	test   $0x4,%dh
  801009:	0f 85 72 ff ff ff    	jne    800f81 <fork+0x63>
		perm &= ~PTE_W;
  80100f:	25 05 0e 00 00       	and    $0xe05,%eax
  801014:	80 cc 08             	or     $0x8,%ah
  801017:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  80101d:	0f 44 c1             	cmove  %ecx,%eax
  801020:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801023:	e9 59 ff ff ff       	jmp    800f81 <fork+0x63>
  801028:	ba 00 00 00 00       	mov    $0x0,%edx
  80102d:	0f 4f c2             	cmovg  %edx,%eax
  801030:	e9 32 ff ff ff       	jmp    800f67 <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801035:	83 ec 04             	sub    $0x4,%esp
  801038:	6a 07                	push   $0x7
  80103a:	68 00 f0 bf ee       	push   $0xeebff000
  80103f:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801042:	57                   	push   %edi
  801043:	e8 86 fb ff ff       	call   800bce <sys_page_alloc>
	if(r<0) return r;
  801048:	83 c4 10             	add    $0x10,%esp
  80104b:	85 c0                	test   %eax,%eax
  80104d:	0f 88 14 ff ff ff    	js     800f67 <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801053:	83 ec 08             	sub    $0x8,%esp
  801056:	68 5c 23 80 00       	push   $0x80235c
  80105b:	57                   	push   %edi
  80105c:	e8 b8 fc ff ff       	call   800d19 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801061:	83 c4 10             	add    $0x10,%esp
  801064:	85 c0                	test   %eax,%eax
  801066:	0f 88 fb fe ff ff    	js     800f67 <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80106c:	83 ec 08             	sub    $0x8,%esp
  80106f:	6a 02                	push   $0x2
  801071:	57                   	push   %edi
  801072:	e8 1e fc ff ff       	call   800c95 <sys_env_set_status>
	if(r<0) return r;
  801077:	83 c4 10             	add    $0x10,%esp
	return envid;
  80107a:	85 c0                	test   %eax,%eax
  80107c:	0f 49 c7             	cmovns %edi,%eax
  80107f:	e9 e3 fe ff ff       	jmp    800f67 <fork+0x49>

00801084 <sfork>:

// Challenge!
int
sfork(void)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80108a:	68 41 2a 80 00       	push   $0x802a41
  80108f:	68 a1 00 00 00       	push   $0xa1
  801094:	68 08 2a 80 00       	push   $0x802a08
  801099:	e8 02 12 00 00       	call   8022a0 <_panic>

0080109e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	56                   	push   %esi
  8010a2:	53                   	push   %ebx
  8010a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8010a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8010ac:	85 c0                	test   %eax,%eax
  8010ae:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8010b3:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8010b6:	83 ec 0c             	sub    $0xc,%esp
  8010b9:	50                   	push   %eax
  8010ba:	e8 bf fc ff ff       	call   800d7e <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8010bf:	83 c4 10             	add    $0x10,%esp
  8010c2:	85 f6                	test   %esi,%esi
  8010c4:	74 14                	je     8010da <ipc_recv+0x3c>
  8010c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8010cb:	85 c0                	test   %eax,%eax
  8010cd:	78 09                	js     8010d8 <ipc_recv+0x3a>
  8010cf:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8010d5:	8b 52 74             	mov    0x74(%edx),%edx
  8010d8:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8010da:	85 db                	test   %ebx,%ebx
  8010dc:	74 14                	je     8010f2 <ipc_recv+0x54>
  8010de:	ba 00 00 00 00       	mov    $0x0,%edx
  8010e3:	85 c0                	test   %eax,%eax
  8010e5:	78 09                	js     8010f0 <ipc_recv+0x52>
  8010e7:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8010ed:	8b 52 78             	mov    0x78(%edx),%edx
  8010f0:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	78 08                	js     8010fe <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  8010f6:	a1 04 40 80 00       	mov    0x804004,%eax
  8010fb:	8b 40 70             	mov    0x70(%eax),%eax
}
  8010fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801101:	5b                   	pop    %ebx
  801102:	5e                   	pop    %esi
  801103:	5d                   	pop    %ebp
  801104:	c3                   	ret    

00801105 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	57                   	push   %edi
  801109:	56                   	push   %esi
  80110a:	53                   	push   %ebx
  80110b:	83 ec 0c             	sub    $0xc,%esp
  80110e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801111:	8b 75 0c             	mov    0xc(%ebp),%esi
  801114:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801117:	85 db                	test   %ebx,%ebx
  801119:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80111e:	0f 44 d8             	cmove  %eax,%ebx
  801121:	eb 05                	jmp    801128 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801123:	e8 87 fa ff ff       	call   800baf <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801128:	ff 75 14             	push   0x14(%ebp)
  80112b:	53                   	push   %ebx
  80112c:	56                   	push   %esi
  80112d:	57                   	push   %edi
  80112e:	e8 28 fc ff ff       	call   800d5b <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801133:	83 c4 10             	add    $0x10,%esp
  801136:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801139:	74 e8                	je     801123 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80113b:	85 c0                	test   %eax,%eax
  80113d:	78 08                	js     801147 <ipc_send+0x42>
	}while (r<0);

}
  80113f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801142:	5b                   	pop    %ebx
  801143:	5e                   	pop    %esi
  801144:	5f                   	pop    %edi
  801145:	5d                   	pop    %ebp
  801146:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801147:	50                   	push   %eax
  801148:	68 57 2a 80 00       	push   $0x802a57
  80114d:	6a 3d                	push   $0x3d
  80114f:	68 6b 2a 80 00       	push   $0x802a6b
  801154:	e8 47 11 00 00       	call   8022a0 <_panic>

00801159 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801159:	55                   	push   %ebp
  80115a:	89 e5                	mov    %esp,%ebp
  80115c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80115f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801164:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801167:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80116d:	8b 52 50             	mov    0x50(%edx),%edx
  801170:	39 ca                	cmp    %ecx,%edx
  801172:	74 11                	je     801185 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801174:	83 c0 01             	add    $0x1,%eax
  801177:	3d 00 04 00 00       	cmp    $0x400,%eax
  80117c:	75 e6                	jne    801164 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80117e:	b8 00 00 00 00       	mov    $0x0,%eax
  801183:	eb 0b                	jmp    801190 <ipc_find_env+0x37>
			return envs[i].env_id;
  801185:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801188:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80118d:	8b 40 48             	mov    0x48(%eax),%eax
}
  801190:	5d                   	pop    %ebp
  801191:	c3                   	ret    

00801192 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801195:	8b 45 08             	mov    0x8(%ebp),%eax
  801198:	05 00 00 00 30       	add    $0x30000000,%eax
  80119d:	c1 e8 0c             	shr    $0xc,%eax
}
  8011a0:	5d                   	pop    %ebp
  8011a1:	c3                   	ret    

008011a2 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8011a2:	55                   	push   %ebp
  8011a3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a8:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8011ad:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8011b2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    

008011b9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011b9:	55                   	push   %ebp
  8011ba:	89 e5                	mov    %esp,%ebp
  8011bc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011c1:	89 c2                	mov    %eax,%edx
  8011c3:	c1 ea 16             	shr    $0x16,%edx
  8011c6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011cd:	f6 c2 01             	test   $0x1,%dl
  8011d0:	74 29                	je     8011fb <fd_alloc+0x42>
  8011d2:	89 c2                	mov    %eax,%edx
  8011d4:	c1 ea 0c             	shr    $0xc,%edx
  8011d7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011de:	f6 c2 01             	test   $0x1,%dl
  8011e1:	74 18                	je     8011fb <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8011e3:	05 00 10 00 00       	add    $0x1000,%eax
  8011e8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011ed:	75 d2                	jne    8011c1 <fd_alloc+0x8>
  8011ef:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8011f4:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8011f9:	eb 05                	jmp    801200 <fd_alloc+0x47>
			return 0;
  8011fb:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  801200:	8b 55 08             	mov    0x8(%ebp),%edx
  801203:	89 02                	mov    %eax,(%edx)
}
  801205:	89 c8                	mov    %ecx,%eax
  801207:	5d                   	pop    %ebp
  801208:	c3                   	ret    

00801209 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801209:	55                   	push   %ebp
  80120a:	89 e5                	mov    %esp,%ebp
  80120c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80120f:	83 f8 1f             	cmp    $0x1f,%eax
  801212:	77 30                	ja     801244 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801214:	c1 e0 0c             	shl    $0xc,%eax
  801217:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80121c:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801222:	f6 c2 01             	test   $0x1,%dl
  801225:	74 24                	je     80124b <fd_lookup+0x42>
  801227:	89 c2                	mov    %eax,%edx
  801229:	c1 ea 0c             	shr    $0xc,%edx
  80122c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801233:	f6 c2 01             	test   $0x1,%dl
  801236:	74 1a                	je     801252 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801238:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123b:	89 02                	mov    %eax,(%edx)
	return 0;
  80123d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801242:	5d                   	pop    %ebp
  801243:	c3                   	ret    
		return -E_INVAL;
  801244:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801249:	eb f7                	jmp    801242 <fd_lookup+0x39>
		return -E_INVAL;
  80124b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801250:	eb f0                	jmp    801242 <fd_lookup+0x39>
  801252:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801257:	eb e9                	jmp    801242 <fd_lookup+0x39>

00801259 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801259:	55                   	push   %ebp
  80125a:	89 e5                	mov    %esp,%ebp
  80125c:	53                   	push   %ebx
  80125d:	83 ec 04             	sub    $0x4,%esp
  801260:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801263:	b8 00 00 00 00       	mov    $0x0,%eax
  801268:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80126d:	39 13                	cmp    %edx,(%ebx)
  80126f:	74 37                	je     8012a8 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  801271:	83 c0 01             	add    $0x1,%eax
  801274:	8b 1c 85 f4 2a 80 00 	mov    0x802af4(,%eax,4),%ebx
  80127b:	85 db                	test   %ebx,%ebx
  80127d:	75 ee                	jne    80126d <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80127f:	a1 04 40 80 00       	mov    0x804004,%eax
  801284:	8b 40 48             	mov    0x48(%eax),%eax
  801287:	83 ec 04             	sub    $0x4,%esp
  80128a:	52                   	push   %edx
  80128b:	50                   	push   %eax
  80128c:	68 78 2a 80 00       	push   $0x802a78
  801291:	e8 62 ef ff ff       	call   8001f8 <cprintf>
	*dev = 0;
	return -E_INVAL;
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  80129e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012a1:	89 1a                	mov    %ebx,(%edx)
}
  8012a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a6:	c9                   	leave  
  8012a7:	c3                   	ret    
			return 0;
  8012a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ad:	eb ef                	jmp    80129e <dev_lookup+0x45>

008012af <fd_close>:
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	57                   	push   %edi
  8012b3:	56                   	push   %esi
  8012b4:	53                   	push   %ebx
  8012b5:	83 ec 24             	sub    $0x24,%esp
  8012b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8012bb:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012be:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8012c1:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012c2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012c8:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012cb:	50                   	push   %eax
  8012cc:	e8 38 ff ff ff       	call   801209 <fd_lookup>
  8012d1:	89 c3                	mov    %eax,%ebx
  8012d3:	83 c4 10             	add    $0x10,%esp
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	78 05                	js     8012df <fd_close+0x30>
	    || fd != fd2)
  8012da:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8012dd:	74 16                	je     8012f5 <fd_close+0x46>
		return (must_exist ? r : 0);
  8012df:	89 f8                	mov    %edi,%eax
  8012e1:	84 c0                	test   %al,%al
  8012e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8012e8:	0f 44 d8             	cmove  %eax,%ebx
}
  8012eb:	89 d8                	mov    %ebx,%eax
  8012ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f0:	5b                   	pop    %ebx
  8012f1:	5e                   	pop    %esi
  8012f2:	5f                   	pop    %edi
  8012f3:	5d                   	pop    %ebp
  8012f4:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012f5:	83 ec 08             	sub    $0x8,%esp
  8012f8:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8012fb:	50                   	push   %eax
  8012fc:	ff 36                	push   (%esi)
  8012fe:	e8 56 ff ff ff       	call   801259 <dev_lookup>
  801303:	89 c3                	mov    %eax,%ebx
  801305:	83 c4 10             	add    $0x10,%esp
  801308:	85 c0                	test   %eax,%eax
  80130a:	78 1a                	js     801326 <fd_close+0x77>
		if (dev->dev_close)
  80130c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80130f:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801312:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801317:	85 c0                	test   %eax,%eax
  801319:	74 0b                	je     801326 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80131b:	83 ec 0c             	sub    $0xc,%esp
  80131e:	56                   	push   %esi
  80131f:	ff d0                	call   *%eax
  801321:	89 c3                	mov    %eax,%ebx
  801323:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801326:	83 ec 08             	sub    $0x8,%esp
  801329:	56                   	push   %esi
  80132a:	6a 00                	push   $0x0
  80132c:	e8 22 f9 ff ff       	call   800c53 <sys_page_unmap>
	return r;
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	eb b5                	jmp    8012eb <fd_close+0x3c>

00801336 <close>:

int
close(int fdnum)
{
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80133c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133f:	50                   	push   %eax
  801340:	ff 75 08             	push   0x8(%ebp)
  801343:	e8 c1 fe ff ff       	call   801209 <fd_lookup>
  801348:	83 c4 10             	add    $0x10,%esp
  80134b:	85 c0                	test   %eax,%eax
  80134d:	79 02                	jns    801351 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80134f:	c9                   	leave  
  801350:	c3                   	ret    
		return fd_close(fd, 1);
  801351:	83 ec 08             	sub    $0x8,%esp
  801354:	6a 01                	push   $0x1
  801356:	ff 75 f4             	push   -0xc(%ebp)
  801359:	e8 51 ff ff ff       	call   8012af <fd_close>
  80135e:	83 c4 10             	add    $0x10,%esp
  801361:	eb ec                	jmp    80134f <close+0x19>

00801363 <close_all>:

void
close_all(void)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	53                   	push   %ebx
  801367:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80136a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80136f:	83 ec 0c             	sub    $0xc,%esp
  801372:	53                   	push   %ebx
  801373:	e8 be ff ff ff       	call   801336 <close>
	for (i = 0; i < MAXFD; i++)
  801378:	83 c3 01             	add    $0x1,%ebx
  80137b:	83 c4 10             	add    $0x10,%esp
  80137e:	83 fb 20             	cmp    $0x20,%ebx
  801381:	75 ec                	jne    80136f <close_all+0xc>
}
  801383:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801386:	c9                   	leave  
  801387:	c3                   	ret    

00801388 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	57                   	push   %edi
  80138c:	56                   	push   %esi
  80138d:	53                   	push   %ebx
  80138e:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801391:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801394:	50                   	push   %eax
  801395:	ff 75 08             	push   0x8(%ebp)
  801398:	e8 6c fe ff ff       	call   801209 <fd_lookup>
  80139d:	89 c3                	mov    %eax,%ebx
  80139f:	83 c4 10             	add    $0x10,%esp
  8013a2:	85 c0                	test   %eax,%eax
  8013a4:	78 7f                	js     801425 <dup+0x9d>
		return r;
	close(newfdnum);
  8013a6:	83 ec 0c             	sub    $0xc,%esp
  8013a9:	ff 75 0c             	push   0xc(%ebp)
  8013ac:	e8 85 ff ff ff       	call   801336 <close>

	newfd = INDEX2FD(newfdnum);
  8013b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013b4:	c1 e6 0c             	shl    $0xc,%esi
  8013b7:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8013bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013c0:	89 3c 24             	mov    %edi,(%esp)
  8013c3:	e8 da fd ff ff       	call   8011a2 <fd2data>
  8013c8:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8013ca:	89 34 24             	mov    %esi,(%esp)
  8013cd:	e8 d0 fd ff ff       	call   8011a2 <fd2data>
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013d8:	89 d8                	mov    %ebx,%eax
  8013da:	c1 e8 16             	shr    $0x16,%eax
  8013dd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013e4:	a8 01                	test   $0x1,%al
  8013e6:	74 11                	je     8013f9 <dup+0x71>
  8013e8:	89 d8                	mov    %ebx,%eax
  8013ea:	c1 e8 0c             	shr    $0xc,%eax
  8013ed:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013f4:	f6 c2 01             	test   $0x1,%dl
  8013f7:	75 36                	jne    80142f <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8013f9:	89 f8                	mov    %edi,%eax
  8013fb:	c1 e8 0c             	shr    $0xc,%eax
  8013fe:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801405:	83 ec 0c             	sub    $0xc,%esp
  801408:	25 07 0e 00 00       	and    $0xe07,%eax
  80140d:	50                   	push   %eax
  80140e:	56                   	push   %esi
  80140f:	6a 00                	push   $0x0
  801411:	57                   	push   %edi
  801412:	6a 00                	push   $0x0
  801414:	e8 f8 f7 ff ff       	call   800c11 <sys_page_map>
  801419:	89 c3                	mov    %eax,%ebx
  80141b:	83 c4 20             	add    $0x20,%esp
  80141e:	85 c0                	test   %eax,%eax
  801420:	78 33                	js     801455 <dup+0xcd>
		goto err;

	return newfdnum;
  801422:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801425:	89 d8                	mov    %ebx,%eax
  801427:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80142a:	5b                   	pop    %ebx
  80142b:	5e                   	pop    %esi
  80142c:	5f                   	pop    %edi
  80142d:	5d                   	pop    %ebp
  80142e:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80142f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801436:	83 ec 0c             	sub    $0xc,%esp
  801439:	25 07 0e 00 00       	and    $0xe07,%eax
  80143e:	50                   	push   %eax
  80143f:	ff 75 d4             	push   -0x2c(%ebp)
  801442:	6a 00                	push   $0x0
  801444:	53                   	push   %ebx
  801445:	6a 00                	push   $0x0
  801447:	e8 c5 f7 ff ff       	call   800c11 <sys_page_map>
  80144c:	89 c3                	mov    %eax,%ebx
  80144e:	83 c4 20             	add    $0x20,%esp
  801451:	85 c0                	test   %eax,%eax
  801453:	79 a4                	jns    8013f9 <dup+0x71>
	sys_page_unmap(0, newfd);
  801455:	83 ec 08             	sub    $0x8,%esp
  801458:	56                   	push   %esi
  801459:	6a 00                	push   $0x0
  80145b:	e8 f3 f7 ff ff       	call   800c53 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801460:	83 c4 08             	add    $0x8,%esp
  801463:	ff 75 d4             	push   -0x2c(%ebp)
  801466:	6a 00                	push   $0x0
  801468:	e8 e6 f7 ff ff       	call   800c53 <sys_page_unmap>
	return r;
  80146d:	83 c4 10             	add    $0x10,%esp
  801470:	eb b3                	jmp    801425 <dup+0x9d>

00801472 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	56                   	push   %esi
  801476:	53                   	push   %ebx
  801477:	83 ec 18             	sub    $0x18,%esp
  80147a:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80147d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801480:	50                   	push   %eax
  801481:	56                   	push   %esi
  801482:	e8 82 fd ff ff       	call   801209 <fd_lookup>
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 3c                	js     8014ca <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148e:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801491:	83 ec 08             	sub    $0x8,%esp
  801494:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801497:	50                   	push   %eax
  801498:	ff 33                	push   (%ebx)
  80149a:	e8 ba fd ff ff       	call   801259 <dev_lookup>
  80149f:	83 c4 10             	add    $0x10,%esp
  8014a2:	85 c0                	test   %eax,%eax
  8014a4:	78 24                	js     8014ca <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8014a6:	8b 43 08             	mov    0x8(%ebx),%eax
  8014a9:	83 e0 03             	and    $0x3,%eax
  8014ac:	83 f8 01             	cmp    $0x1,%eax
  8014af:	74 20                	je     8014d1 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8014b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b4:	8b 40 08             	mov    0x8(%eax),%eax
  8014b7:	85 c0                	test   %eax,%eax
  8014b9:	74 37                	je     8014f2 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014bb:	83 ec 04             	sub    $0x4,%esp
  8014be:	ff 75 10             	push   0x10(%ebp)
  8014c1:	ff 75 0c             	push   0xc(%ebp)
  8014c4:	53                   	push   %ebx
  8014c5:	ff d0                	call   *%eax
  8014c7:	83 c4 10             	add    $0x10,%esp
}
  8014ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014cd:	5b                   	pop    %ebx
  8014ce:	5e                   	pop    %esi
  8014cf:	5d                   	pop    %ebp
  8014d0:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8014d1:	a1 04 40 80 00       	mov    0x804004,%eax
  8014d6:	8b 40 48             	mov    0x48(%eax),%eax
  8014d9:	83 ec 04             	sub    $0x4,%esp
  8014dc:	56                   	push   %esi
  8014dd:	50                   	push   %eax
  8014de:	68 b9 2a 80 00       	push   $0x802ab9
  8014e3:	e8 10 ed ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  8014e8:	83 c4 10             	add    $0x10,%esp
  8014eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014f0:	eb d8                	jmp    8014ca <read+0x58>
		return -E_NOT_SUPP;
  8014f2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014f7:	eb d1                	jmp    8014ca <read+0x58>

008014f9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	57                   	push   %edi
  8014fd:	56                   	push   %esi
  8014fe:	53                   	push   %ebx
  8014ff:	83 ec 0c             	sub    $0xc,%esp
  801502:	8b 7d 08             	mov    0x8(%ebp),%edi
  801505:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801508:	bb 00 00 00 00       	mov    $0x0,%ebx
  80150d:	eb 02                	jmp    801511 <readn+0x18>
  80150f:	01 c3                	add    %eax,%ebx
  801511:	39 f3                	cmp    %esi,%ebx
  801513:	73 21                	jae    801536 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801515:	83 ec 04             	sub    $0x4,%esp
  801518:	89 f0                	mov    %esi,%eax
  80151a:	29 d8                	sub    %ebx,%eax
  80151c:	50                   	push   %eax
  80151d:	89 d8                	mov    %ebx,%eax
  80151f:	03 45 0c             	add    0xc(%ebp),%eax
  801522:	50                   	push   %eax
  801523:	57                   	push   %edi
  801524:	e8 49 ff ff ff       	call   801472 <read>
		if (m < 0)
  801529:	83 c4 10             	add    $0x10,%esp
  80152c:	85 c0                	test   %eax,%eax
  80152e:	78 04                	js     801534 <readn+0x3b>
			return m;
		if (m == 0)
  801530:	75 dd                	jne    80150f <readn+0x16>
  801532:	eb 02                	jmp    801536 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801534:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801536:	89 d8                	mov    %ebx,%eax
  801538:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80153b:	5b                   	pop    %ebx
  80153c:	5e                   	pop    %esi
  80153d:	5f                   	pop    %edi
  80153e:	5d                   	pop    %ebp
  80153f:	c3                   	ret    

00801540 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801540:	55                   	push   %ebp
  801541:	89 e5                	mov    %esp,%ebp
  801543:	56                   	push   %esi
  801544:	53                   	push   %ebx
  801545:	83 ec 18             	sub    $0x18,%esp
  801548:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80154b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80154e:	50                   	push   %eax
  80154f:	53                   	push   %ebx
  801550:	e8 b4 fc ff ff       	call   801209 <fd_lookup>
  801555:	83 c4 10             	add    $0x10,%esp
  801558:	85 c0                	test   %eax,%eax
  80155a:	78 37                	js     801593 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80155c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80155f:	83 ec 08             	sub    $0x8,%esp
  801562:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801565:	50                   	push   %eax
  801566:	ff 36                	push   (%esi)
  801568:	e8 ec fc ff ff       	call   801259 <dev_lookup>
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	85 c0                	test   %eax,%eax
  801572:	78 1f                	js     801593 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801574:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801578:	74 20                	je     80159a <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80157a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157d:	8b 40 0c             	mov    0xc(%eax),%eax
  801580:	85 c0                	test   %eax,%eax
  801582:	74 37                	je     8015bb <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801584:	83 ec 04             	sub    $0x4,%esp
  801587:	ff 75 10             	push   0x10(%ebp)
  80158a:	ff 75 0c             	push   0xc(%ebp)
  80158d:	56                   	push   %esi
  80158e:	ff d0                	call   *%eax
  801590:	83 c4 10             	add    $0x10,%esp
}
  801593:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801596:	5b                   	pop    %ebx
  801597:	5e                   	pop    %esi
  801598:	5d                   	pop    %ebp
  801599:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80159a:	a1 04 40 80 00       	mov    0x804004,%eax
  80159f:	8b 40 48             	mov    0x48(%eax),%eax
  8015a2:	83 ec 04             	sub    $0x4,%esp
  8015a5:	53                   	push   %ebx
  8015a6:	50                   	push   %eax
  8015a7:	68 d5 2a 80 00       	push   $0x802ad5
  8015ac:	e8 47 ec ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015b9:	eb d8                	jmp    801593 <write+0x53>
		return -E_NOT_SUPP;
  8015bb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015c0:	eb d1                	jmp    801593 <write+0x53>

008015c2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8015c2:	55                   	push   %ebp
  8015c3:	89 e5                	mov    %esp,%ebp
  8015c5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cb:	50                   	push   %eax
  8015cc:	ff 75 08             	push   0x8(%ebp)
  8015cf:	e8 35 fc ff ff       	call   801209 <fd_lookup>
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	85 c0                	test   %eax,%eax
  8015d9:	78 0e                	js     8015e9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015e1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e9:	c9                   	leave  
  8015ea:	c3                   	ret    

008015eb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015eb:	55                   	push   %ebp
  8015ec:	89 e5                	mov    %esp,%ebp
  8015ee:	56                   	push   %esi
  8015ef:	53                   	push   %ebx
  8015f0:	83 ec 18             	sub    $0x18,%esp
  8015f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f9:	50                   	push   %eax
  8015fa:	53                   	push   %ebx
  8015fb:	e8 09 fc ff ff       	call   801209 <fd_lookup>
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	85 c0                	test   %eax,%eax
  801605:	78 34                	js     80163b <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801607:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80160a:	83 ec 08             	sub    $0x8,%esp
  80160d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801610:	50                   	push   %eax
  801611:	ff 36                	push   (%esi)
  801613:	e8 41 fc ff ff       	call   801259 <dev_lookup>
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	85 c0                	test   %eax,%eax
  80161d:	78 1c                	js     80163b <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80161f:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801623:	74 1d                	je     801642 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801625:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801628:	8b 40 18             	mov    0x18(%eax),%eax
  80162b:	85 c0                	test   %eax,%eax
  80162d:	74 34                	je     801663 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80162f:	83 ec 08             	sub    $0x8,%esp
  801632:	ff 75 0c             	push   0xc(%ebp)
  801635:	56                   	push   %esi
  801636:	ff d0                	call   *%eax
  801638:	83 c4 10             	add    $0x10,%esp
}
  80163b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80163e:	5b                   	pop    %ebx
  80163f:	5e                   	pop    %esi
  801640:	5d                   	pop    %ebp
  801641:	c3                   	ret    
			thisenv->env_id, fdnum);
  801642:	a1 04 40 80 00       	mov    0x804004,%eax
  801647:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80164a:	83 ec 04             	sub    $0x4,%esp
  80164d:	53                   	push   %ebx
  80164e:	50                   	push   %eax
  80164f:	68 98 2a 80 00       	push   $0x802a98
  801654:	e8 9f eb ff ff       	call   8001f8 <cprintf>
		return -E_INVAL;
  801659:	83 c4 10             	add    $0x10,%esp
  80165c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801661:	eb d8                	jmp    80163b <ftruncate+0x50>
		return -E_NOT_SUPP;
  801663:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801668:	eb d1                	jmp    80163b <ftruncate+0x50>

0080166a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	56                   	push   %esi
  80166e:	53                   	push   %ebx
  80166f:	83 ec 18             	sub    $0x18,%esp
  801672:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801675:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801678:	50                   	push   %eax
  801679:	ff 75 08             	push   0x8(%ebp)
  80167c:	e8 88 fb ff ff       	call   801209 <fd_lookup>
  801681:	83 c4 10             	add    $0x10,%esp
  801684:	85 c0                	test   %eax,%eax
  801686:	78 49                	js     8016d1 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801688:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80168b:	83 ec 08             	sub    $0x8,%esp
  80168e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801691:	50                   	push   %eax
  801692:	ff 36                	push   (%esi)
  801694:	e8 c0 fb ff ff       	call   801259 <dev_lookup>
  801699:	83 c4 10             	add    $0x10,%esp
  80169c:	85 c0                	test   %eax,%eax
  80169e:	78 31                	js     8016d1 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8016a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016a7:	74 2f                	je     8016d8 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016a9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016ac:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016b3:	00 00 00 
	stat->st_isdir = 0;
  8016b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016bd:	00 00 00 
	stat->st_dev = dev;
  8016c0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016c6:	83 ec 08             	sub    $0x8,%esp
  8016c9:	53                   	push   %ebx
  8016ca:	56                   	push   %esi
  8016cb:	ff 50 14             	call   *0x14(%eax)
  8016ce:	83 c4 10             	add    $0x10,%esp
}
  8016d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016d4:	5b                   	pop    %ebx
  8016d5:	5e                   	pop    %esi
  8016d6:	5d                   	pop    %ebp
  8016d7:	c3                   	ret    
		return -E_NOT_SUPP;
  8016d8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016dd:	eb f2                	jmp    8016d1 <fstat+0x67>

008016df <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	56                   	push   %esi
  8016e3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016e4:	83 ec 08             	sub    $0x8,%esp
  8016e7:	6a 00                	push   $0x0
  8016e9:	ff 75 08             	push   0x8(%ebp)
  8016ec:	e8 e4 01 00 00       	call   8018d5 <open>
  8016f1:	89 c3                	mov    %eax,%ebx
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	78 1b                	js     801715 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8016fa:	83 ec 08             	sub    $0x8,%esp
  8016fd:	ff 75 0c             	push   0xc(%ebp)
  801700:	50                   	push   %eax
  801701:	e8 64 ff ff ff       	call   80166a <fstat>
  801706:	89 c6                	mov    %eax,%esi
	close(fd);
  801708:	89 1c 24             	mov    %ebx,(%esp)
  80170b:	e8 26 fc ff ff       	call   801336 <close>
	return r;
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	89 f3                	mov    %esi,%ebx
}
  801715:	89 d8                	mov    %ebx,%eax
  801717:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80171a:	5b                   	pop    %ebx
  80171b:	5e                   	pop    %esi
  80171c:	5d                   	pop    %ebp
  80171d:	c3                   	ret    

0080171e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80171e:	55                   	push   %ebp
  80171f:	89 e5                	mov    %esp,%ebp
  801721:	56                   	push   %esi
  801722:	53                   	push   %ebx
  801723:	89 c6                	mov    %eax,%esi
  801725:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801727:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80172e:	74 27                	je     801757 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801730:	6a 07                	push   $0x7
  801732:	68 00 50 80 00       	push   $0x805000
  801737:	56                   	push   %esi
  801738:	ff 35 00 60 80 00    	push   0x806000
  80173e:	e8 c2 f9 ff ff       	call   801105 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801743:	83 c4 0c             	add    $0xc,%esp
  801746:	6a 00                	push   $0x0
  801748:	53                   	push   %ebx
  801749:	6a 00                	push   $0x0
  80174b:	e8 4e f9 ff ff       	call   80109e <ipc_recv>
}
  801750:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801753:	5b                   	pop    %ebx
  801754:	5e                   	pop    %esi
  801755:	5d                   	pop    %ebp
  801756:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801757:	83 ec 0c             	sub    $0xc,%esp
  80175a:	6a 01                	push   $0x1
  80175c:	e8 f8 f9 ff ff       	call   801159 <ipc_find_env>
  801761:	a3 00 60 80 00       	mov    %eax,0x806000
  801766:	83 c4 10             	add    $0x10,%esp
  801769:	eb c5                	jmp    801730 <fsipc+0x12>

0080176b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801771:	8b 45 08             	mov    0x8(%ebp),%eax
  801774:	8b 40 0c             	mov    0xc(%eax),%eax
  801777:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80177c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80177f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801784:	ba 00 00 00 00       	mov    $0x0,%edx
  801789:	b8 02 00 00 00       	mov    $0x2,%eax
  80178e:	e8 8b ff ff ff       	call   80171e <fsipc>
}
  801793:	c9                   	leave  
  801794:	c3                   	ret    

00801795 <devfile_flush>:
{
  801795:	55                   	push   %ebp
  801796:	89 e5                	mov    %esp,%ebp
  801798:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80179b:	8b 45 08             	mov    0x8(%ebp),%eax
  80179e:	8b 40 0c             	mov    0xc(%eax),%eax
  8017a1:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ab:	b8 06 00 00 00       	mov    $0x6,%eax
  8017b0:	e8 69 ff ff ff       	call   80171e <fsipc>
}
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    

008017b7 <devfile_stat>:
{
  8017b7:	55                   	push   %ebp
  8017b8:	89 e5                	mov    %esp,%ebp
  8017ba:	53                   	push   %ebx
  8017bb:	83 ec 04             	sub    $0x4,%esp
  8017be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d1:	b8 05 00 00 00       	mov    $0x5,%eax
  8017d6:	e8 43 ff ff ff       	call   80171e <fsipc>
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	78 2c                	js     80180b <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017df:	83 ec 08             	sub    $0x8,%esp
  8017e2:	68 00 50 80 00       	push   $0x805000
  8017e7:	53                   	push   %ebx
  8017e8:	e8 e5 ef ff ff       	call   8007d2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017ed:	a1 80 50 80 00       	mov    0x805080,%eax
  8017f2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017f8:	a1 84 50 80 00       	mov    0x805084,%eax
  8017fd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80180b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80180e:	c9                   	leave  
  80180f:	c3                   	ret    

00801810 <devfile_write>:
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	83 ec 0c             	sub    $0xc,%esp
  801816:	8b 45 10             	mov    0x10(%ebp),%eax
  801819:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80181e:	39 d0                	cmp    %edx,%eax
  801820:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801823:	8b 55 08             	mov    0x8(%ebp),%edx
  801826:	8b 52 0c             	mov    0xc(%edx),%edx
  801829:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80182f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801834:	50                   	push   %eax
  801835:	ff 75 0c             	push   0xc(%ebp)
  801838:	68 08 50 80 00       	push   $0x805008
  80183d:	e8 26 f1 ff ff       	call   800968 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801842:	ba 00 00 00 00       	mov    $0x0,%edx
  801847:	b8 04 00 00 00       	mov    $0x4,%eax
  80184c:	e8 cd fe ff ff       	call   80171e <fsipc>
}
  801851:	c9                   	leave  
  801852:	c3                   	ret    

00801853 <devfile_read>:
{
  801853:	55                   	push   %ebp
  801854:	89 e5                	mov    %esp,%ebp
  801856:	56                   	push   %esi
  801857:	53                   	push   %ebx
  801858:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80185b:	8b 45 08             	mov    0x8(%ebp),%eax
  80185e:	8b 40 0c             	mov    0xc(%eax),%eax
  801861:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801866:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80186c:	ba 00 00 00 00       	mov    $0x0,%edx
  801871:	b8 03 00 00 00       	mov    $0x3,%eax
  801876:	e8 a3 fe ff ff       	call   80171e <fsipc>
  80187b:	89 c3                	mov    %eax,%ebx
  80187d:	85 c0                	test   %eax,%eax
  80187f:	78 1f                	js     8018a0 <devfile_read+0x4d>
	assert(r <= n);
  801881:	39 f0                	cmp    %esi,%eax
  801883:	77 24                	ja     8018a9 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801885:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80188a:	7f 33                	jg     8018bf <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80188c:	83 ec 04             	sub    $0x4,%esp
  80188f:	50                   	push   %eax
  801890:	68 00 50 80 00       	push   $0x805000
  801895:	ff 75 0c             	push   0xc(%ebp)
  801898:	e8 cb f0 ff ff       	call   800968 <memmove>
	return r;
  80189d:	83 c4 10             	add    $0x10,%esp
}
  8018a0:	89 d8                	mov    %ebx,%eax
  8018a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018a5:	5b                   	pop    %ebx
  8018a6:	5e                   	pop    %esi
  8018a7:	5d                   	pop    %ebp
  8018a8:	c3                   	ret    
	assert(r <= n);
  8018a9:	68 08 2b 80 00       	push   $0x802b08
  8018ae:	68 0f 2b 80 00       	push   $0x802b0f
  8018b3:	6a 7c                	push   $0x7c
  8018b5:	68 24 2b 80 00       	push   $0x802b24
  8018ba:	e8 e1 09 00 00       	call   8022a0 <_panic>
	assert(r <= PGSIZE);
  8018bf:	68 2f 2b 80 00       	push   $0x802b2f
  8018c4:	68 0f 2b 80 00       	push   $0x802b0f
  8018c9:	6a 7d                	push   $0x7d
  8018cb:	68 24 2b 80 00       	push   $0x802b24
  8018d0:	e8 cb 09 00 00       	call   8022a0 <_panic>

008018d5 <open>:
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	56                   	push   %esi
  8018d9:	53                   	push   %ebx
  8018da:	83 ec 1c             	sub    $0x1c,%esp
  8018dd:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8018e0:	56                   	push   %esi
  8018e1:	e8 b1 ee ff ff       	call   800797 <strlen>
  8018e6:	83 c4 10             	add    $0x10,%esp
  8018e9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018ee:	7f 6c                	jg     80195c <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8018f0:	83 ec 0c             	sub    $0xc,%esp
  8018f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f6:	50                   	push   %eax
  8018f7:	e8 bd f8 ff ff       	call   8011b9 <fd_alloc>
  8018fc:	89 c3                	mov    %eax,%ebx
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	85 c0                	test   %eax,%eax
  801903:	78 3c                	js     801941 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801905:	83 ec 08             	sub    $0x8,%esp
  801908:	56                   	push   %esi
  801909:	68 00 50 80 00       	push   $0x805000
  80190e:	e8 bf ee ff ff       	call   8007d2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801913:	8b 45 0c             	mov    0xc(%ebp),%eax
  801916:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80191b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80191e:	b8 01 00 00 00       	mov    $0x1,%eax
  801923:	e8 f6 fd ff ff       	call   80171e <fsipc>
  801928:	89 c3                	mov    %eax,%ebx
  80192a:	83 c4 10             	add    $0x10,%esp
  80192d:	85 c0                	test   %eax,%eax
  80192f:	78 19                	js     80194a <open+0x75>
	return fd2num(fd);
  801931:	83 ec 0c             	sub    $0xc,%esp
  801934:	ff 75 f4             	push   -0xc(%ebp)
  801937:	e8 56 f8 ff ff       	call   801192 <fd2num>
  80193c:	89 c3                	mov    %eax,%ebx
  80193e:	83 c4 10             	add    $0x10,%esp
}
  801941:	89 d8                	mov    %ebx,%eax
  801943:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801946:	5b                   	pop    %ebx
  801947:	5e                   	pop    %esi
  801948:	5d                   	pop    %ebp
  801949:	c3                   	ret    
		fd_close(fd, 0);
  80194a:	83 ec 08             	sub    $0x8,%esp
  80194d:	6a 00                	push   $0x0
  80194f:	ff 75 f4             	push   -0xc(%ebp)
  801952:	e8 58 f9 ff ff       	call   8012af <fd_close>
		return r;
  801957:	83 c4 10             	add    $0x10,%esp
  80195a:	eb e5                	jmp    801941 <open+0x6c>
		return -E_BAD_PATH;
  80195c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801961:	eb de                	jmp    801941 <open+0x6c>

00801963 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801963:	55                   	push   %ebp
  801964:	89 e5                	mov    %esp,%ebp
  801966:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801969:	ba 00 00 00 00       	mov    $0x0,%edx
  80196e:	b8 08 00 00 00       	mov    $0x8,%eax
  801973:	e8 a6 fd ff ff       	call   80171e <fsipc>
}
  801978:	c9                   	leave  
  801979:	c3                   	ret    

0080197a <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80197a:	55                   	push   %ebp
  80197b:	89 e5                	mov    %esp,%ebp
  80197d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801980:	68 3b 2b 80 00       	push   $0x802b3b
  801985:	ff 75 0c             	push   0xc(%ebp)
  801988:	e8 45 ee ff ff       	call   8007d2 <strcpy>
	return 0;
}
  80198d:	b8 00 00 00 00       	mov    $0x0,%eax
  801992:	c9                   	leave  
  801993:	c3                   	ret    

00801994 <devsock_close>:
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	53                   	push   %ebx
  801998:	83 ec 10             	sub    $0x10,%esp
  80199b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80199e:	53                   	push   %ebx
  80199f:	e8 de 09 00 00       	call   802382 <pageref>
  8019a4:	89 c2                	mov    %eax,%edx
  8019a6:	83 c4 10             	add    $0x10,%esp
		return 0;
  8019a9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8019ae:	83 fa 01             	cmp    $0x1,%edx
  8019b1:	74 05                	je     8019b8 <devsock_close+0x24>
}
  8019b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019b6:	c9                   	leave  
  8019b7:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8019b8:	83 ec 0c             	sub    $0xc,%esp
  8019bb:	ff 73 0c             	push   0xc(%ebx)
  8019be:	e8 b7 02 00 00       	call   801c7a <nsipc_close>
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	eb eb                	jmp    8019b3 <devsock_close+0x1f>

008019c8 <devsock_write>:
{
  8019c8:	55                   	push   %ebp
  8019c9:	89 e5                	mov    %esp,%ebp
  8019cb:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019ce:	6a 00                	push   $0x0
  8019d0:	ff 75 10             	push   0x10(%ebp)
  8019d3:	ff 75 0c             	push   0xc(%ebp)
  8019d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d9:	ff 70 0c             	push   0xc(%eax)
  8019dc:	e8 79 03 00 00       	call   801d5a <nsipc_send>
}
  8019e1:	c9                   	leave  
  8019e2:	c3                   	ret    

008019e3 <devsock_read>:
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019e9:	6a 00                	push   $0x0
  8019eb:	ff 75 10             	push   0x10(%ebp)
  8019ee:	ff 75 0c             	push   0xc(%ebp)
  8019f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f4:	ff 70 0c             	push   0xc(%eax)
  8019f7:	e8 ef 02 00 00       	call   801ceb <nsipc_recv>
}
  8019fc:	c9                   	leave  
  8019fd:	c3                   	ret    

008019fe <fd2sockid>:
{
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a04:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a07:	52                   	push   %edx
  801a08:	50                   	push   %eax
  801a09:	e8 fb f7 ff ff       	call   801209 <fd_lookup>
  801a0e:	83 c4 10             	add    $0x10,%esp
  801a11:	85 c0                	test   %eax,%eax
  801a13:	78 10                	js     801a25 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801a15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a18:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a1e:	39 08                	cmp    %ecx,(%eax)
  801a20:	75 05                	jne    801a27 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801a22:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801a25:	c9                   	leave  
  801a26:	c3                   	ret    
		return -E_NOT_SUPP;
  801a27:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a2c:	eb f7                	jmp    801a25 <fd2sockid+0x27>

00801a2e <alloc_sockfd>:
{
  801a2e:	55                   	push   %ebp
  801a2f:	89 e5                	mov    %esp,%ebp
  801a31:	56                   	push   %esi
  801a32:	53                   	push   %ebx
  801a33:	83 ec 1c             	sub    $0x1c,%esp
  801a36:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801a38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a3b:	50                   	push   %eax
  801a3c:	e8 78 f7 ff ff       	call   8011b9 <fd_alloc>
  801a41:	89 c3                	mov    %eax,%ebx
  801a43:	83 c4 10             	add    $0x10,%esp
  801a46:	85 c0                	test   %eax,%eax
  801a48:	78 43                	js     801a8d <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a4a:	83 ec 04             	sub    $0x4,%esp
  801a4d:	68 07 04 00 00       	push   $0x407
  801a52:	ff 75 f4             	push   -0xc(%ebp)
  801a55:	6a 00                	push   $0x0
  801a57:	e8 72 f1 ff ff       	call   800bce <sys_page_alloc>
  801a5c:	89 c3                	mov    %eax,%ebx
  801a5e:	83 c4 10             	add    $0x10,%esp
  801a61:	85 c0                	test   %eax,%eax
  801a63:	78 28                	js     801a8d <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a68:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a6e:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a73:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a7a:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a7d:	83 ec 0c             	sub    $0xc,%esp
  801a80:	50                   	push   %eax
  801a81:	e8 0c f7 ff ff       	call   801192 <fd2num>
  801a86:	89 c3                	mov    %eax,%ebx
  801a88:	83 c4 10             	add    $0x10,%esp
  801a8b:	eb 0c                	jmp    801a99 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801a8d:	83 ec 0c             	sub    $0xc,%esp
  801a90:	56                   	push   %esi
  801a91:	e8 e4 01 00 00       	call   801c7a <nsipc_close>
		return r;
  801a96:	83 c4 10             	add    $0x10,%esp
}
  801a99:	89 d8                	mov    %ebx,%eax
  801a9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9e:	5b                   	pop    %ebx
  801a9f:	5e                   	pop    %esi
  801aa0:	5d                   	pop    %ebp
  801aa1:	c3                   	ret    

00801aa2 <accept>:
{
  801aa2:	55                   	push   %ebp
  801aa3:	89 e5                	mov    %esp,%ebp
  801aa5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801aa8:	8b 45 08             	mov    0x8(%ebp),%eax
  801aab:	e8 4e ff ff ff       	call   8019fe <fd2sockid>
  801ab0:	85 c0                	test   %eax,%eax
  801ab2:	78 1b                	js     801acf <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ab4:	83 ec 04             	sub    $0x4,%esp
  801ab7:	ff 75 10             	push   0x10(%ebp)
  801aba:	ff 75 0c             	push   0xc(%ebp)
  801abd:	50                   	push   %eax
  801abe:	e8 0e 01 00 00       	call   801bd1 <nsipc_accept>
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	78 05                	js     801acf <accept+0x2d>
	return alloc_sockfd(r);
  801aca:	e8 5f ff ff ff       	call   801a2e <alloc_sockfd>
}
  801acf:	c9                   	leave  
  801ad0:	c3                   	ret    

00801ad1 <bind>:
{
  801ad1:	55                   	push   %ebp
  801ad2:	89 e5                	mov    %esp,%ebp
  801ad4:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  801ada:	e8 1f ff ff ff       	call   8019fe <fd2sockid>
  801adf:	85 c0                	test   %eax,%eax
  801ae1:	78 12                	js     801af5 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801ae3:	83 ec 04             	sub    $0x4,%esp
  801ae6:	ff 75 10             	push   0x10(%ebp)
  801ae9:	ff 75 0c             	push   0xc(%ebp)
  801aec:	50                   	push   %eax
  801aed:	e8 31 01 00 00       	call   801c23 <nsipc_bind>
  801af2:	83 c4 10             	add    $0x10,%esp
}
  801af5:	c9                   	leave  
  801af6:	c3                   	ret    

00801af7 <shutdown>:
{
  801af7:	55                   	push   %ebp
  801af8:	89 e5                	mov    %esp,%ebp
  801afa:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801afd:	8b 45 08             	mov    0x8(%ebp),%eax
  801b00:	e8 f9 fe ff ff       	call   8019fe <fd2sockid>
  801b05:	85 c0                	test   %eax,%eax
  801b07:	78 0f                	js     801b18 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801b09:	83 ec 08             	sub    $0x8,%esp
  801b0c:	ff 75 0c             	push   0xc(%ebp)
  801b0f:	50                   	push   %eax
  801b10:	e8 43 01 00 00       	call   801c58 <nsipc_shutdown>
  801b15:	83 c4 10             	add    $0x10,%esp
}
  801b18:	c9                   	leave  
  801b19:	c3                   	ret    

00801b1a <connect>:
{
  801b1a:	55                   	push   %ebp
  801b1b:	89 e5                	mov    %esp,%ebp
  801b1d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b20:	8b 45 08             	mov    0x8(%ebp),%eax
  801b23:	e8 d6 fe ff ff       	call   8019fe <fd2sockid>
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	78 12                	js     801b3e <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801b2c:	83 ec 04             	sub    $0x4,%esp
  801b2f:	ff 75 10             	push   0x10(%ebp)
  801b32:	ff 75 0c             	push   0xc(%ebp)
  801b35:	50                   	push   %eax
  801b36:	e8 59 01 00 00       	call   801c94 <nsipc_connect>
  801b3b:	83 c4 10             	add    $0x10,%esp
}
  801b3e:	c9                   	leave  
  801b3f:	c3                   	ret    

00801b40 <listen>:
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801b46:	8b 45 08             	mov    0x8(%ebp),%eax
  801b49:	e8 b0 fe ff ff       	call   8019fe <fd2sockid>
  801b4e:	85 c0                	test   %eax,%eax
  801b50:	78 0f                	js     801b61 <listen+0x21>
	return nsipc_listen(r, backlog);
  801b52:	83 ec 08             	sub    $0x8,%esp
  801b55:	ff 75 0c             	push   0xc(%ebp)
  801b58:	50                   	push   %eax
  801b59:	e8 6b 01 00 00       	call   801cc9 <nsipc_listen>
  801b5e:	83 c4 10             	add    $0x10,%esp
}
  801b61:	c9                   	leave  
  801b62:	c3                   	ret    

00801b63 <socket>:

int
socket(int domain, int type, int protocol)
{
  801b63:	55                   	push   %ebp
  801b64:	89 e5                	mov    %esp,%ebp
  801b66:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b69:	ff 75 10             	push   0x10(%ebp)
  801b6c:	ff 75 0c             	push   0xc(%ebp)
  801b6f:	ff 75 08             	push   0x8(%ebp)
  801b72:	e8 41 02 00 00       	call   801db8 <nsipc_socket>
  801b77:	83 c4 10             	add    $0x10,%esp
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	78 05                	js     801b83 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b7e:	e8 ab fe ff ff       	call   801a2e <alloc_sockfd>
}
  801b83:	c9                   	leave  
  801b84:	c3                   	ret    

00801b85 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b85:	55                   	push   %ebp
  801b86:	89 e5                	mov    %esp,%ebp
  801b88:	53                   	push   %ebx
  801b89:	83 ec 04             	sub    $0x4,%esp
  801b8c:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b8e:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801b95:	74 26                	je     801bbd <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b97:	6a 07                	push   $0x7
  801b99:	68 00 70 80 00       	push   $0x807000
  801b9e:	53                   	push   %ebx
  801b9f:	ff 35 00 80 80 00    	push   0x808000
  801ba5:	e8 5b f5 ff ff       	call   801105 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801baa:	83 c4 0c             	add    $0xc,%esp
  801bad:	6a 00                	push   $0x0
  801baf:	6a 00                	push   $0x0
  801bb1:	6a 00                	push   $0x0
  801bb3:	e8 e6 f4 ff ff       	call   80109e <ipc_recv>
}
  801bb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bbb:	c9                   	leave  
  801bbc:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bbd:	83 ec 0c             	sub    $0xc,%esp
  801bc0:	6a 02                	push   $0x2
  801bc2:	e8 92 f5 ff ff       	call   801159 <ipc_find_env>
  801bc7:	a3 00 80 80 00       	mov    %eax,0x808000
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	eb c6                	jmp    801b97 <nsipc+0x12>

00801bd1 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	56                   	push   %esi
  801bd5:	53                   	push   %ebx
  801bd6:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801bd9:	8b 45 08             	mov    0x8(%ebp),%eax
  801bdc:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801be1:	8b 06                	mov    (%esi),%eax
  801be3:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801be8:	b8 01 00 00 00       	mov    $0x1,%eax
  801bed:	e8 93 ff ff ff       	call   801b85 <nsipc>
  801bf2:	89 c3                	mov    %eax,%ebx
  801bf4:	85 c0                	test   %eax,%eax
  801bf6:	79 09                	jns    801c01 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801bf8:	89 d8                	mov    %ebx,%eax
  801bfa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bfd:	5b                   	pop    %ebx
  801bfe:	5e                   	pop    %esi
  801bff:	5d                   	pop    %ebp
  801c00:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c01:	83 ec 04             	sub    $0x4,%esp
  801c04:	ff 35 10 70 80 00    	push   0x807010
  801c0a:	68 00 70 80 00       	push   $0x807000
  801c0f:	ff 75 0c             	push   0xc(%ebp)
  801c12:	e8 51 ed ff ff       	call   800968 <memmove>
		*addrlen = ret->ret_addrlen;
  801c17:	a1 10 70 80 00       	mov    0x807010,%eax
  801c1c:	89 06                	mov    %eax,(%esi)
  801c1e:	83 c4 10             	add    $0x10,%esp
	return r;
  801c21:	eb d5                	jmp    801bf8 <nsipc_accept+0x27>

00801c23 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c23:	55                   	push   %ebp
  801c24:	89 e5                	mov    %esp,%ebp
  801c26:	53                   	push   %ebx
  801c27:	83 ec 08             	sub    $0x8,%esp
  801c2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c30:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c35:	53                   	push   %ebx
  801c36:	ff 75 0c             	push   0xc(%ebp)
  801c39:	68 04 70 80 00       	push   $0x807004
  801c3e:	e8 25 ed ff ff       	call   800968 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c43:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801c49:	b8 02 00 00 00       	mov    $0x2,%eax
  801c4e:	e8 32 ff ff ff       	call   801b85 <nsipc>
}
  801c53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c56:	c9                   	leave  
  801c57:	c3                   	ret    

00801c58 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c5e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c61:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801c66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c69:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801c6e:	b8 03 00 00 00       	mov    $0x3,%eax
  801c73:	e8 0d ff ff ff       	call   801b85 <nsipc>
}
  801c78:	c9                   	leave  
  801c79:	c3                   	ret    

00801c7a <nsipc_close>:

int
nsipc_close(int s)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c80:	8b 45 08             	mov    0x8(%ebp),%eax
  801c83:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801c88:	b8 04 00 00 00       	mov    $0x4,%eax
  801c8d:	e8 f3 fe ff ff       	call   801b85 <nsipc>
}
  801c92:	c9                   	leave  
  801c93:	c3                   	ret    

00801c94 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c94:	55                   	push   %ebp
  801c95:	89 e5                	mov    %esp,%ebp
  801c97:	53                   	push   %ebx
  801c98:	83 ec 08             	sub    $0x8,%esp
  801c9b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca1:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ca6:	53                   	push   %ebx
  801ca7:	ff 75 0c             	push   0xc(%ebp)
  801caa:	68 04 70 80 00       	push   $0x807004
  801caf:	e8 b4 ec ff ff       	call   800968 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cb4:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801cba:	b8 05 00 00 00       	mov    $0x5,%eax
  801cbf:	e8 c1 fe ff ff       	call   801b85 <nsipc>
}
  801cc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cc7:	c9                   	leave  
  801cc8:	c3                   	ret    

00801cc9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cc9:	55                   	push   %ebp
  801cca:	89 e5                	mov    %esp,%ebp
  801ccc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ccf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801cd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cda:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801cdf:	b8 06 00 00 00       	mov    $0x6,%eax
  801ce4:	e8 9c fe ff ff       	call   801b85 <nsipc>
}
  801ce9:	c9                   	leave  
  801cea:	c3                   	ret    

00801ceb <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ceb:	55                   	push   %ebp
  801cec:	89 e5                	mov    %esp,%ebp
  801cee:	56                   	push   %esi
  801cef:	53                   	push   %ebx
  801cf0:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801cf3:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf6:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801cfb:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801d01:	8b 45 14             	mov    0x14(%ebp),%eax
  801d04:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d09:	b8 07 00 00 00       	mov    $0x7,%eax
  801d0e:	e8 72 fe ff ff       	call   801b85 <nsipc>
  801d13:	89 c3                	mov    %eax,%ebx
  801d15:	85 c0                	test   %eax,%eax
  801d17:	78 22                	js     801d3b <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801d19:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801d1e:	39 c6                	cmp    %eax,%esi
  801d20:	0f 4e c6             	cmovle %esi,%eax
  801d23:	39 c3                	cmp    %eax,%ebx
  801d25:	7f 1d                	jg     801d44 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d27:	83 ec 04             	sub    $0x4,%esp
  801d2a:	53                   	push   %ebx
  801d2b:	68 00 70 80 00       	push   $0x807000
  801d30:	ff 75 0c             	push   0xc(%ebp)
  801d33:	e8 30 ec ff ff       	call   800968 <memmove>
  801d38:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d3b:	89 d8                	mov    %ebx,%eax
  801d3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d40:	5b                   	pop    %ebx
  801d41:	5e                   	pop    %esi
  801d42:	5d                   	pop    %ebp
  801d43:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801d44:	68 47 2b 80 00       	push   $0x802b47
  801d49:	68 0f 2b 80 00       	push   $0x802b0f
  801d4e:	6a 62                	push   $0x62
  801d50:	68 5c 2b 80 00       	push   $0x802b5c
  801d55:	e8 46 05 00 00       	call   8022a0 <_panic>

00801d5a <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d5a:	55                   	push   %ebp
  801d5b:	89 e5                	mov    %esp,%ebp
  801d5d:	53                   	push   %ebx
  801d5e:	83 ec 04             	sub    $0x4,%esp
  801d61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d64:	8b 45 08             	mov    0x8(%ebp),%eax
  801d67:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801d6c:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d72:	7f 2e                	jg     801da2 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d74:	83 ec 04             	sub    $0x4,%esp
  801d77:	53                   	push   %ebx
  801d78:	ff 75 0c             	push   0xc(%ebp)
  801d7b:	68 0c 70 80 00       	push   $0x80700c
  801d80:	e8 e3 eb ff ff       	call   800968 <memmove>
	nsipcbuf.send.req_size = size;
  801d85:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801d8b:	8b 45 14             	mov    0x14(%ebp),%eax
  801d8e:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801d93:	b8 08 00 00 00       	mov    $0x8,%eax
  801d98:	e8 e8 fd ff ff       	call   801b85 <nsipc>
}
  801d9d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801da0:	c9                   	leave  
  801da1:	c3                   	ret    
	assert(size < 1600);
  801da2:	68 68 2b 80 00       	push   $0x802b68
  801da7:	68 0f 2b 80 00       	push   $0x802b0f
  801dac:	6a 6d                	push   $0x6d
  801dae:	68 5c 2b 80 00       	push   $0x802b5c
  801db3:	e8 e8 04 00 00       	call   8022a0 <_panic>

00801db8 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801db8:	55                   	push   %ebp
  801db9:	89 e5                	mov    %esp,%ebp
  801dbb:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc1:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801dc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc9:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801dce:	8b 45 10             	mov    0x10(%ebp),%eax
  801dd1:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801dd6:	b8 09 00 00 00       	mov    $0x9,%eax
  801ddb:	e8 a5 fd ff ff       	call   801b85 <nsipc>
}
  801de0:	c9                   	leave  
  801de1:	c3                   	ret    

00801de2 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	56                   	push   %esi
  801de6:	53                   	push   %ebx
  801de7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801dea:	83 ec 0c             	sub    $0xc,%esp
  801ded:	ff 75 08             	push   0x8(%ebp)
  801df0:	e8 ad f3 ff ff       	call   8011a2 <fd2data>
  801df5:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801df7:	83 c4 08             	add    $0x8,%esp
  801dfa:	68 74 2b 80 00       	push   $0x802b74
  801dff:	53                   	push   %ebx
  801e00:	e8 cd e9 ff ff       	call   8007d2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e05:	8b 46 04             	mov    0x4(%esi),%eax
  801e08:	2b 06                	sub    (%esi),%eax
  801e0a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e10:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e17:	00 00 00 
	stat->st_dev = &devpipe;
  801e1a:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e21:	30 80 00 
	return 0;
}
  801e24:	b8 00 00 00 00       	mov    $0x0,%eax
  801e29:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e2c:	5b                   	pop    %ebx
  801e2d:	5e                   	pop    %esi
  801e2e:	5d                   	pop    %ebp
  801e2f:	c3                   	ret    

00801e30 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	53                   	push   %ebx
  801e34:	83 ec 0c             	sub    $0xc,%esp
  801e37:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e3a:	53                   	push   %ebx
  801e3b:	6a 00                	push   $0x0
  801e3d:	e8 11 ee ff ff       	call   800c53 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e42:	89 1c 24             	mov    %ebx,(%esp)
  801e45:	e8 58 f3 ff ff       	call   8011a2 <fd2data>
  801e4a:	83 c4 08             	add    $0x8,%esp
  801e4d:	50                   	push   %eax
  801e4e:	6a 00                	push   $0x0
  801e50:	e8 fe ed ff ff       	call   800c53 <sys_page_unmap>
}
  801e55:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e58:	c9                   	leave  
  801e59:	c3                   	ret    

00801e5a <_pipeisclosed>:
{
  801e5a:	55                   	push   %ebp
  801e5b:	89 e5                	mov    %esp,%ebp
  801e5d:	57                   	push   %edi
  801e5e:	56                   	push   %esi
  801e5f:	53                   	push   %ebx
  801e60:	83 ec 1c             	sub    $0x1c,%esp
  801e63:	89 c7                	mov    %eax,%edi
  801e65:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801e67:	a1 04 40 80 00       	mov    0x804004,%eax
  801e6c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801e6f:	83 ec 0c             	sub    $0xc,%esp
  801e72:	57                   	push   %edi
  801e73:	e8 0a 05 00 00       	call   802382 <pageref>
  801e78:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801e7b:	89 34 24             	mov    %esi,(%esp)
  801e7e:	e8 ff 04 00 00       	call   802382 <pageref>
		nn = thisenv->env_runs;
  801e83:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801e89:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801e8c:	83 c4 10             	add    $0x10,%esp
  801e8f:	39 cb                	cmp    %ecx,%ebx
  801e91:	74 1b                	je     801eae <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801e93:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e96:	75 cf                	jne    801e67 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e98:	8b 42 58             	mov    0x58(%edx),%eax
  801e9b:	6a 01                	push   $0x1
  801e9d:	50                   	push   %eax
  801e9e:	53                   	push   %ebx
  801e9f:	68 7b 2b 80 00       	push   $0x802b7b
  801ea4:	e8 4f e3 ff ff       	call   8001f8 <cprintf>
  801ea9:	83 c4 10             	add    $0x10,%esp
  801eac:	eb b9                	jmp    801e67 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801eae:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801eb1:	0f 94 c0             	sete   %al
  801eb4:	0f b6 c0             	movzbl %al,%eax
}
  801eb7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eba:	5b                   	pop    %ebx
  801ebb:	5e                   	pop    %esi
  801ebc:	5f                   	pop    %edi
  801ebd:	5d                   	pop    %ebp
  801ebe:	c3                   	ret    

00801ebf <devpipe_write>:
{
  801ebf:	55                   	push   %ebp
  801ec0:	89 e5                	mov    %esp,%ebp
  801ec2:	57                   	push   %edi
  801ec3:	56                   	push   %esi
  801ec4:	53                   	push   %ebx
  801ec5:	83 ec 28             	sub    $0x28,%esp
  801ec8:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801ecb:	56                   	push   %esi
  801ecc:	e8 d1 f2 ff ff       	call   8011a2 <fd2data>
  801ed1:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ed3:	83 c4 10             	add    $0x10,%esp
  801ed6:	bf 00 00 00 00       	mov    $0x0,%edi
  801edb:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ede:	75 09                	jne    801ee9 <devpipe_write+0x2a>
	return i;
  801ee0:	89 f8                	mov    %edi,%eax
  801ee2:	eb 23                	jmp    801f07 <devpipe_write+0x48>
			sys_yield();
  801ee4:	e8 c6 ec ff ff       	call   800baf <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ee9:	8b 43 04             	mov    0x4(%ebx),%eax
  801eec:	8b 0b                	mov    (%ebx),%ecx
  801eee:	8d 51 20             	lea    0x20(%ecx),%edx
  801ef1:	39 d0                	cmp    %edx,%eax
  801ef3:	72 1a                	jb     801f0f <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801ef5:	89 da                	mov    %ebx,%edx
  801ef7:	89 f0                	mov    %esi,%eax
  801ef9:	e8 5c ff ff ff       	call   801e5a <_pipeisclosed>
  801efe:	85 c0                	test   %eax,%eax
  801f00:	74 e2                	je     801ee4 <devpipe_write+0x25>
				return 0;
  801f02:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801f07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f0a:	5b                   	pop    %ebx
  801f0b:	5e                   	pop    %esi
  801f0c:	5f                   	pop    %edi
  801f0d:	5d                   	pop    %ebp
  801f0e:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f12:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f16:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f19:	89 c2                	mov    %eax,%edx
  801f1b:	c1 fa 1f             	sar    $0x1f,%edx
  801f1e:	89 d1                	mov    %edx,%ecx
  801f20:	c1 e9 1b             	shr    $0x1b,%ecx
  801f23:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f26:	83 e2 1f             	and    $0x1f,%edx
  801f29:	29 ca                	sub    %ecx,%edx
  801f2b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f2f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f33:	83 c0 01             	add    $0x1,%eax
  801f36:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801f39:	83 c7 01             	add    $0x1,%edi
  801f3c:	eb 9d                	jmp    801edb <devpipe_write+0x1c>

00801f3e <devpipe_read>:
{
  801f3e:	55                   	push   %ebp
  801f3f:	89 e5                	mov    %esp,%ebp
  801f41:	57                   	push   %edi
  801f42:	56                   	push   %esi
  801f43:	53                   	push   %ebx
  801f44:	83 ec 18             	sub    $0x18,%esp
  801f47:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801f4a:	57                   	push   %edi
  801f4b:	e8 52 f2 ff ff       	call   8011a2 <fd2data>
  801f50:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f52:	83 c4 10             	add    $0x10,%esp
  801f55:	be 00 00 00 00       	mov    $0x0,%esi
  801f5a:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f5d:	75 13                	jne    801f72 <devpipe_read+0x34>
	return i;
  801f5f:	89 f0                	mov    %esi,%eax
  801f61:	eb 02                	jmp    801f65 <devpipe_read+0x27>
				return i;
  801f63:	89 f0                	mov    %esi,%eax
}
  801f65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f68:	5b                   	pop    %ebx
  801f69:	5e                   	pop    %esi
  801f6a:	5f                   	pop    %edi
  801f6b:	5d                   	pop    %ebp
  801f6c:	c3                   	ret    
			sys_yield();
  801f6d:	e8 3d ec ff ff       	call   800baf <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801f72:	8b 03                	mov    (%ebx),%eax
  801f74:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f77:	75 18                	jne    801f91 <devpipe_read+0x53>
			if (i > 0)
  801f79:	85 f6                	test   %esi,%esi
  801f7b:	75 e6                	jne    801f63 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801f7d:	89 da                	mov    %ebx,%edx
  801f7f:	89 f8                	mov    %edi,%eax
  801f81:	e8 d4 fe ff ff       	call   801e5a <_pipeisclosed>
  801f86:	85 c0                	test   %eax,%eax
  801f88:	74 e3                	je     801f6d <devpipe_read+0x2f>
				return 0;
  801f8a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f8f:	eb d4                	jmp    801f65 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f91:	99                   	cltd   
  801f92:	c1 ea 1b             	shr    $0x1b,%edx
  801f95:	01 d0                	add    %edx,%eax
  801f97:	83 e0 1f             	and    $0x1f,%eax
  801f9a:	29 d0                	sub    %edx,%eax
  801f9c:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801fa1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fa4:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801fa7:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801faa:	83 c6 01             	add    $0x1,%esi
  801fad:	eb ab                	jmp    801f5a <devpipe_read+0x1c>

00801faf <pipe>:
{
  801faf:	55                   	push   %ebp
  801fb0:	89 e5                	mov    %esp,%ebp
  801fb2:	56                   	push   %esi
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801fb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fba:	50                   	push   %eax
  801fbb:	e8 f9 f1 ff ff       	call   8011b9 <fd_alloc>
  801fc0:	89 c3                	mov    %eax,%ebx
  801fc2:	83 c4 10             	add    $0x10,%esp
  801fc5:	85 c0                	test   %eax,%eax
  801fc7:	0f 88 23 01 00 00    	js     8020f0 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fcd:	83 ec 04             	sub    $0x4,%esp
  801fd0:	68 07 04 00 00       	push   $0x407
  801fd5:	ff 75 f4             	push   -0xc(%ebp)
  801fd8:	6a 00                	push   $0x0
  801fda:	e8 ef eb ff ff       	call   800bce <sys_page_alloc>
  801fdf:	89 c3                	mov    %eax,%ebx
  801fe1:	83 c4 10             	add    $0x10,%esp
  801fe4:	85 c0                	test   %eax,%eax
  801fe6:	0f 88 04 01 00 00    	js     8020f0 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801fec:	83 ec 0c             	sub    $0xc,%esp
  801fef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ff2:	50                   	push   %eax
  801ff3:	e8 c1 f1 ff ff       	call   8011b9 <fd_alloc>
  801ff8:	89 c3                	mov    %eax,%ebx
  801ffa:	83 c4 10             	add    $0x10,%esp
  801ffd:	85 c0                	test   %eax,%eax
  801fff:	0f 88 db 00 00 00    	js     8020e0 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802005:	83 ec 04             	sub    $0x4,%esp
  802008:	68 07 04 00 00       	push   $0x407
  80200d:	ff 75 f0             	push   -0x10(%ebp)
  802010:	6a 00                	push   $0x0
  802012:	e8 b7 eb ff ff       	call   800bce <sys_page_alloc>
  802017:	89 c3                	mov    %eax,%ebx
  802019:	83 c4 10             	add    $0x10,%esp
  80201c:	85 c0                	test   %eax,%eax
  80201e:	0f 88 bc 00 00 00    	js     8020e0 <pipe+0x131>
	va = fd2data(fd0);
  802024:	83 ec 0c             	sub    $0xc,%esp
  802027:	ff 75 f4             	push   -0xc(%ebp)
  80202a:	e8 73 f1 ff ff       	call   8011a2 <fd2data>
  80202f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802031:	83 c4 0c             	add    $0xc,%esp
  802034:	68 07 04 00 00       	push   $0x407
  802039:	50                   	push   %eax
  80203a:	6a 00                	push   $0x0
  80203c:	e8 8d eb ff ff       	call   800bce <sys_page_alloc>
  802041:	89 c3                	mov    %eax,%ebx
  802043:	83 c4 10             	add    $0x10,%esp
  802046:	85 c0                	test   %eax,%eax
  802048:	0f 88 82 00 00 00    	js     8020d0 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80204e:	83 ec 0c             	sub    $0xc,%esp
  802051:	ff 75 f0             	push   -0x10(%ebp)
  802054:	e8 49 f1 ff ff       	call   8011a2 <fd2data>
  802059:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802060:	50                   	push   %eax
  802061:	6a 00                	push   $0x0
  802063:	56                   	push   %esi
  802064:	6a 00                	push   $0x0
  802066:	e8 a6 eb ff ff       	call   800c11 <sys_page_map>
  80206b:	89 c3                	mov    %eax,%ebx
  80206d:	83 c4 20             	add    $0x20,%esp
  802070:	85 c0                	test   %eax,%eax
  802072:	78 4e                	js     8020c2 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  802074:	a1 3c 30 80 00       	mov    0x80303c,%eax
  802079:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80207c:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80207e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802081:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802088:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80208b:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80208d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802090:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802097:	83 ec 0c             	sub    $0xc,%esp
  80209a:	ff 75 f4             	push   -0xc(%ebp)
  80209d:	e8 f0 f0 ff ff       	call   801192 <fd2num>
  8020a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020a5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020a7:	83 c4 04             	add    $0x4,%esp
  8020aa:	ff 75 f0             	push   -0x10(%ebp)
  8020ad:	e8 e0 f0 ff ff       	call   801192 <fd2num>
  8020b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020b5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020b8:	83 c4 10             	add    $0x10,%esp
  8020bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020c0:	eb 2e                	jmp    8020f0 <pipe+0x141>
	sys_page_unmap(0, va);
  8020c2:	83 ec 08             	sub    $0x8,%esp
  8020c5:	56                   	push   %esi
  8020c6:	6a 00                	push   $0x0
  8020c8:	e8 86 eb ff ff       	call   800c53 <sys_page_unmap>
  8020cd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8020d0:	83 ec 08             	sub    $0x8,%esp
  8020d3:	ff 75 f0             	push   -0x10(%ebp)
  8020d6:	6a 00                	push   $0x0
  8020d8:	e8 76 eb ff ff       	call   800c53 <sys_page_unmap>
  8020dd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8020e0:	83 ec 08             	sub    $0x8,%esp
  8020e3:	ff 75 f4             	push   -0xc(%ebp)
  8020e6:	6a 00                	push   $0x0
  8020e8:	e8 66 eb ff ff       	call   800c53 <sys_page_unmap>
  8020ed:	83 c4 10             	add    $0x10,%esp
}
  8020f0:	89 d8                	mov    %ebx,%eax
  8020f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020f5:	5b                   	pop    %ebx
  8020f6:	5e                   	pop    %esi
  8020f7:	5d                   	pop    %ebp
  8020f8:	c3                   	ret    

008020f9 <pipeisclosed>:
{
  8020f9:	55                   	push   %ebp
  8020fa:	89 e5                	mov    %esp,%ebp
  8020fc:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802102:	50                   	push   %eax
  802103:	ff 75 08             	push   0x8(%ebp)
  802106:	e8 fe f0 ff ff       	call   801209 <fd_lookup>
  80210b:	83 c4 10             	add    $0x10,%esp
  80210e:	85 c0                	test   %eax,%eax
  802110:	78 18                	js     80212a <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802112:	83 ec 0c             	sub    $0xc,%esp
  802115:	ff 75 f4             	push   -0xc(%ebp)
  802118:	e8 85 f0 ff ff       	call   8011a2 <fd2data>
  80211d:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80211f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802122:	e8 33 fd ff ff       	call   801e5a <_pipeisclosed>
  802127:	83 c4 10             	add    $0x10,%esp
}
  80212a:	c9                   	leave  
  80212b:	c3                   	ret    

0080212c <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80212c:	b8 00 00 00 00       	mov    $0x0,%eax
  802131:	c3                   	ret    

00802132 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802132:	55                   	push   %ebp
  802133:	89 e5                	mov    %esp,%ebp
  802135:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802138:	68 93 2b 80 00       	push   $0x802b93
  80213d:	ff 75 0c             	push   0xc(%ebp)
  802140:	e8 8d e6 ff ff       	call   8007d2 <strcpy>
	return 0;
}
  802145:	b8 00 00 00 00       	mov    $0x0,%eax
  80214a:	c9                   	leave  
  80214b:	c3                   	ret    

0080214c <devcons_write>:
{
  80214c:	55                   	push   %ebp
  80214d:	89 e5                	mov    %esp,%ebp
  80214f:	57                   	push   %edi
  802150:	56                   	push   %esi
  802151:	53                   	push   %ebx
  802152:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802158:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80215d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802163:	eb 2e                	jmp    802193 <devcons_write+0x47>
		m = n - tot;
  802165:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802168:	29 f3                	sub    %esi,%ebx
  80216a:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80216f:	39 c3                	cmp    %eax,%ebx
  802171:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802174:	83 ec 04             	sub    $0x4,%esp
  802177:	53                   	push   %ebx
  802178:	89 f0                	mov    %esi,%eax
  80217a:	03 45 0c             	add    0xc(%ebp),%eax
  80217d:	50                   	push   %eax
  80217e:	57                   	push   %edi
  80217f:	e8 e4 e7 ff ff       	call   800968 <memmove>
		sys_cputs(buf, m);
  802184:	83 c4 08             	add    $0x8,%esp
  802187:	53                   	push   %ebx
  802188:	57                   	push   %edi
  802189:	e8 84 e9 ff ff       	call   800b12 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80218e:	01 de                	add    %ebx,%esi
  802190:	83 c4 10             	add    $0x10,%esp
  802193:	3b 75 10             	cmp    0x10(%ebp),%esi
  802196:	72 cd                	jb     802165 <devcons_write+0x19>
}
  802198:	89 f0                	mov    %esi,%eax
  80219a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80219d:	5b                   	pop    %ebx
  80219e:	5e                   	pop    %esi
  80219f:	5f                   	pop    %edi
  8021a0:	5d                   	pop    %ebp
  8021a1:	c3                   	ret    

008021a2 <devcons_read>:
{
  8021a2:	55                   	push   %ebp
  8021a3:	89 e5                	mov    %esp,%ebp
  8021a5:	83 ec 08             	sub    $0x8,%esp
  8021a8:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8021ad:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021b1:	75 07                	jne    8021ba <devcons_read+0x18>
  8021b3:	eb 1f                	jmp    8021d4 <devcons_read+0x32>
		sys_yield();
  8021b5:	e8 f5 e9 ff ff       	call   800baf <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8021ba:	e8 71 e9 ff ff       	call   800b30 <sys_cgetc>
  8021bf:	85 c0                	test   %eax,%eax
  8021c1:	74 f2                	je     8021b5 <devcons_read+0x13>
	if (c < 0)
  8021c3:	78 0f                	js     8021d4 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8021c5:	83 f8 04             	cmp    $0x4,%eax
  8021c8:	74 0c                	je     8021d6 <devcons_read+0x34>
	*(char*)vbuf = c;
  8021ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021cd:	88 02                	mov    %al,(%edx)
	return 1;
  8021cf:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8021d4:	c9                   	leave  
  8021d5:	c3                   	ret    
		return 0;
  8021d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8021db:	eb f7                	jmp    8021d4 <devcons_read+0x32>

008021dd <cputchar>:
{
  8021dd:	55                   	push   %ebp
  8021de:	89 e5                	mov    %esp,%ebp
  8021e0:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8021e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e6:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8021e9:	6a 01                	push   $0x1
  8021eb:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8021ee:	50                   	push   %eax
  8021ef:	e8 1e e9 ff ff       	call   800b12 <sys_cputs>
}
  8021f4:	83 c4 10             	add    $0x10,%esp
  8021f7:	c9                   	leave  
  8021f8:	c3                   	ret    

008021f9 <getchar>:
{
  8021f9:	55                   	push   %ebp
  8021fa:	89 e5                	mov    %esp,%ebp
  8021fc:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8021ff:	6a 01                	push   $0x1
  802201:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802204:	50                   	push   %eax
  802205:	6a 00                	push   $0x0
  802207:	e8 66 f2 ff ff       	call   801472 <read>
	if (r < 0)
  80220c:	83 c4 10             	add    $0x10,%esp
  80220f:	85 c0                	test   %eax,%eax
  802211:	78 06                	js     802219 <getchar+0x20>
	if (r < 1)
  802213:	74 06                	je     80221b <getchar+0x22>
	return c;
  802215:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802219:	c9                   	leave  
  80221a:	c3                   	ret    
		return -E_EOF;
  80221b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802220:	eb f7                	jmp    802219 <getchar+0x20>

00802222 <iscons>:
{
  802222:	55                   	push   %ebp
  802223:	89 e5                	mov    %esp,%ebp
  802225:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802228:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80222b:	50                   	push   %eax
  80222c:	ff 75 08             	push   0x8(%ebp)
  80222f:	e8 d5 ef ff ff       	call   801209 <fd_lookup>
  802234:	83 c4 10             	add    $0x10,%esp
  802237:	85 c0                	test   %eax,%eax
  802239:	78 11                	js     80224c <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80223b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80223e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802244:	39 10                	cmp    %edx,(%eax)
  802246:	0f 94 c0             	sete   %al
  802249:	0f b6 c0             	movzbl %al,%eax
}
  80224c:	c9                   	leave  
  80224d:	c3                   	ret    

0080224e <opencons>:
{
  80224e:	55                   	push   %ebp
  80224f:	89 e5                	mov    %esp,%ebp
  802251:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802254:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802257:	50                   	push   %eax
  802258:	e8 5c ef ff ff       	call   8011b9 <fd_alloc>
  80225d:	83 c4 10             	add    $0x10,%esp
  802260:	85 c0                	test   %eax,%eax
  802262:	78 3a                	js     80229e <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802264:	83 ec 04             	sub    $0x4,%esp
  802267:	68 07 04 00 00       	push   $0x407
  80226c:	ff 75 f4             	push   -0xc(%ebp)
  80226f:	6a 00                	push   $0x0
  802271:	e8 58 e9 ff ff       	call   800bce <sys_page_alloc>
  802276:	83 c4 10             	add    $0x10,%esp
  802279:	85 c0                	test   %eax,%eax
  80227b:	78 21                	js     80229e <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80227d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802280:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802286:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802288:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80228b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802292:	83 ec 0c             	sub    $0xc,%esp
  802295:	50                   	push   %eax
  802296:	e8 f7 ee ff ff       	call   801192 <fd2num>
  80229b:	83 c4 10             	add    $0x10,%esp
}
  80229e:	c9                   	leave  
  80229f:	c3                   	ret    

008022a0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8022a0:	55                   	push   %ebp
  8022a1:	89 e5                	mov    %esp,%ebp
  8022a3:	56                   	push   %esi
  8022a4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8022a5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8022a8:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8022ae:	e8 dd e8 ff ff       	call   800b90 <sys_getenvid>
  8022b3:	83 ec 0c             	sub    $0xc,%esp
  8022b6:	ff 75 0c             	push   0xc(%ebp)
  8022b9:	ff 75 08             	push   0x8(%ebp)
  8022bc:	56                   	push   %esi
  8022bd:	50                   	push   %eax
  8022be:	68 a0 2b 80 00       	push   $0x802ba0
  8022c3:	e8 30 df ff ff       	call   8001f8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8022c8:	83 c4 18             	add    $0x18,%esp
  8022cb:	53                   	push   %ebx
  8022cc:	ff 75 10             	push   0x10(%ebp)
  8022cf:	e8 d3 de ff ff       	call   8001a7 <vcprintf>
	cprintf("\n");
  8022d4:	c7 04 24 8c 2b 80 00 	movl   $0x802b8c,(%esp)
  8022db:	e8 18 df ff ff       	call   8001f8 <cprintf>
  8022e0:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8022e3:	cc                   	int3   
  8022e4:	eb fd                	jmp    8022e3 <_panic+0x43>

008022e6 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8022e6:	55                   	push   %ebp
  8022e7:	89 e5                	mov    %esp,%ebp
  8022e9:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  8022ec:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  8022f3:	74 0a                	je     8022ff <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8022f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f8:	a3 04 80 80 00       	mov    %eax,0x808004
}
  8022fd:	c9                   	leave  
  8022fe:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  8022ff:	e8 8c e8 ff ff       	call   800b90 <sys_getenvid>
  802304:	83 ec 04             	sub    $0x4,%esp
  802307:	68 07 0e 00 00       	push   $0xe07
  80230c:	68 00 f0 bf ee       	push   $0xeebff000
  802311:	50                   	push   %eax
  802312:	e8 b7 e8 ff ff       	call   800bce <sys_page_alloc>
		if (r < 0) {
  802317:	83 c4 10             	add    $0x10,%esp
  80231a:	85 c0                	test   %eax,%eax
  80231c:	78 2c                	js     80234a <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80231e:	e8 6d e8 ff ff       	call   800b90 <sys_getenvid>
  802323:	83 ec 08             	sub    $0x8,%esp
  802326:	68 5c 23 80 00       	push   $0x80235c
  80232b:	50                   	push   %eax
  80232c:	e8 e8 e9 ff ff       	call   800d19 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802331:	83 c4 10             	add    $0x10,%esp
  802334:	85 c0                	test   %eax,%eax
  802336:	79 bd                	jns    8022f5 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  802338:	50                   	push   %eax
  802339:	68 04 2c 80 00       	push   $0x802c04
  80233e:	6a 28                	push   $0x28
  802340:	68 3a 2c 80 00       	push   $0x802c3a
  802345:	e8 56 ff ff ff       	call   8022a0 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  80234a:	50                   	push   %eax
  80234b:	68 c4 2b 80 00       	push   $0x802bc4
  802350:	6a 23                	push   $0x23
  802352:	68 3a 2c 80 00       	push   $0x802c3a
  802357:	e8 44 ff ff ff       	call   8022a0 <_panic>

0080235c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80235c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80235d:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  802362:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802364:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802367:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  80236b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  80236e:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802372:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802376:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  802378:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  80237b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  80237c:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  80237f:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  802380:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  802381:	c3                   	ret    

00802382 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802382:	55                   	push   %ebp
  802383:	89 e5                	mov    %esp,%ebp
  802385:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802388:	89 c2                	mov    %eax,%edx
  80238a:	c1 ea 16             	shr    $0x16,%edx
  80238d:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802394:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802399:	f6 c1 01             	test   $0x1,%cl
  80239c:	74 1c                	je     8023ba <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  80239e:	c1 e8 0c             	shr    $0xc,%eax
  8023a1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8023a8:	a8 01                	test   $0x1,%al
  8023aa:	74 0e                	je     8023ba <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023ac:	c1 e8 0c             	shr    $0xc,%eax
  8023af:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8023b6:	ef 
  8023b7:	0f b7 d2             	movzwl %dx,%edx
}
  8023ba:	89 d0                	mov    %edx,%eax
  8023bc:	5d                   	pop    %ebp
  8023bd:	c3                   	ret    
  8023be:	66 90                	xchg   %ax,%ax

008023c0 <__udivdi3>:
  8023c0:	f3 0f 1e fb          	endbr32 
  8023c4:	55                   	push   %ebp
  8023c5:	57                   	push   %edi
  8023c6:	56                   	push   %esi
  8023c7:	53                   	push   %ebx
  8023c8:	83 ec 1c             	sub    $0x1c,%esp
  8023cb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8023cf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8023d3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023d7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8023db:	85 c0                	test   %eax,%eax
  8023dd:	75 19                	jne    8023f8 <__udivdi3+0x38>
  8023df:	39 f3                	cmp    %esi,%ebx
  8023e1:	76 4d                	jbe    802430 <__udivdi3+0x70>
  8023e3:	31 ff                	xor    %edi,%edi
  8023e5:	89 e8                	mov    %ebp,%eax
  8023e7:	89 f2                	mov    %esi,%edx
  8023e9:	f7 f3                	div    %ebx
  8023eb:	89 fa                	mov    %edi,%edx
  8023ed:	83 c4 1c             	add    $0x1c,%esp
  8023f0:	5b                   	pop    %ebx
  8023f1:	5e                   	pop    %esi
  8023f2:	5f                   	pop    %edi
  8023f3:	5d                   	pop    %ebp
  8023f4:	c3                   	ret    
  8023f5:	8d 76 00             	lea    0x0(%esi),%esi
  8023f8:	39 f0                	cmp    %esi,%eax
  8023fa:	76 14                	jbe    802410 <__udivdi3+0x50>
  8023fc:	31 ff                	xor    %edi,%edi
  8023fe:	31 c0                	xor    %eax,%eax
  802400:	89 fa                	mov    %edi,%edx
  802402:	83 c4 1c             	add    $0x1c,%esp
  802405:	5b                   	pop    %ebx
  802406:	5e                   	pop    %esi
  802407:	5f                   	pop    %edi
  802408:	5d                   	pop    %ebp
  802409:	c3                   	ret    
  80240a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802410:	0f bd f8             	bsr    %eax,%edi
  802413:	83 f7 1f             	xor    $0x1f,%edi
  802416:	75 48                	jne    802460 <__udivdi3+0xa0>
  802418:	39 f0                	cmp    %esi,%eax
  80241a:	72 06                	jb     802422 <__udivdi3+0x62>
  80241c:	31 c0                	xor    %eax,%eax
  80241e:	39 eb                	cmp    %ebp,%ebx
  802420:	77 de                	ja     802400 <__udivdi3+0x40>
  802422:	b8 01 00 00 00       	mov    $0x1,%eax
  802427:	eb d7                	jmp    802400 <__udivdi3+0x40>
  802429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802430:	89 d9                	mov    %ebx,%ecx
  802432:	85 db                	test   %ebx,%ebx
  802434:	75 0b                	jne    802441 <__udivdi3+0x81>
  802436:	b8 01 00 00 00       	mov    $0x1,%eax
  80243b:	31 d2                	xor    %edx,%edx
  80243d:	f7 f3                	div    %ebx
  80243f:	89 c1                	mov    %eax,%ecx
  802441:	31 d2                	xor    %edx,%edx
  802443:	89 f0                	mov    %esi,%eax
  802445:	f7 f1                	div    %ecx
  802447:	89 c6                	mov    %eax,%esi
  802449:	89 e8                	mov    %ebp,%eax
  80244b:	89 f7                	mov    %esi,%edi
  80244d:	f7 f1                	div    %ecx
  80244f:	89 fa                	mov    %edi,%edx
  802451:	83 c4 1c             	add    $0x1c,%esp
  802454:	5b                   	pop    %ebx
  802455:	5e                   	pop    %esi
  802456:	5f                   	pop    %edi
  802457:	5d                   	pop    %ebp
  802458:	c3                   	ret    
  802459:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802460:	89 f9                	mov    %edi,%ecx
  802462:	ba 20 00 00 00       	mov    $0x20,%edx
  802467:	29 fa                	sub    %edi,%edx
  802469:	d3 e0                	shl    %cl,%eax
  80246b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80246f:	89 d1                	mov    %edx,%ecx
  802471:	89 d8                	mov    %ebx,%eax
  802473:	d3 e8                	shr    %cl,%eax
  802475:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802479:	09 c1                	or     %eax,%ecx
  80247b:	89 f0                	mov    %esi,%eax
  80247d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802481:	89 f9                	mov    %edi,%ecx
  802483:	d3 e3                	shl    %cl,%ebx
  802485:	89 d1                	mov    %edx,%ecx
  802487:	d3 e8                	shr    %cl,%eax
  802489:	89 f9                	mov    %edi,%ecx
  80248b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80248f:	89 eb                	mov    %ebp,%ebx
  802491:	d3 e6                	shl    %cl,%esi
  802493:	89 d1                	mov    %edx,%ecx
  802495:	d3 eb                	shr    %cl,%ebx
  802497:	09 f3                	or     %esi,%ebx
  802499:	89 c6                	mov    %eax,%esi
  80249b:	89 f2                	mov    %esi,%edx
  80249d:	89 d8                	mov    %ebx,%eax
  80249f:	f7 74 24 08          	divl   0x8(%esp)
  8024a3:	89 d6                	mov    %edx,%esi
  8024a5:	89 c3                	mov    %eax,%ebx
  8024a7:	f7 64 24 0c          	mull   0xc(%esp)
  8024ab:	39 d6                	cmp    %edx,%esi
  8024ad:	72 19                	jb     8024c8 <__udivdi3+0x108>
  8024af:	89 f9                	mov    %edi,%ecx
  8024b1:	d3 e5                	shl    %cl,%ebp
  8024b3:	39 c5                	cmp    %eax,%ebp
  8024b5:	73 04                	jae    8024bb <__udivdi3+0xfb>
  8024b7:	39 d6                	cmp    %edx,%esi
  8024b9:	74 0d                	je     8024c8 <__udivdi3+0x108>
  8024bb:	89 d8                	mov    %ebx,%eax
  8024bd:	31 ff                	xor    %edi,%edi
  8024bf:	e9 3c ff ff ff       	jmp    802400 <__udivdi3+0x40>
  8024c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024c8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8024cb:	31 ff                	xor    %edi,%edi
  8024cd:	e9 2e ff ff ff       	jmp    802400 <__udivdi3+0x40>
  8024d2:	66 90                	xchg   %ax,%ax
  8024d4:	66 90                	xchg   %ax,%ax
  8024d6:	66 90                	xchg   %ax,%ax
  8024d8:	66 90                	xchg   %ax,%ax
  8024da:	66 90                	xchg   %ax,%ax
  8024dc:	66 90                	xchg   %ax,%ax
  8024de:	66 90                	xchg   %ax,%ax

008024e0 <__umoddi3>:
  8024e0:	f3 0f 1e fb          	endbr32 
  8024e4:	55                   	push   %ebp
  8024e5:	57                   	push   %edi
  8024e6:	56                   	push   %esi
  8024e7:	53                   	push   %ebx
  8024e8:	83 ec 1c             	sub    $0x1c,%esp
  8024eb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8024ef:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8024f3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8024f7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8024fb:	89 f0                	mov    %esi,%eax
  8024fd:	89 da                	mov    %ebx,%edx
  8024ff:	85 ff                	test   %edi,%edi
  802501:	75 15                	jne    802518 <__umoddi3+0x38>
  802503:	39 dd                	cmp    %ebx,%ebp
  802505:	76 39                	jbe    802540 <__umoddi3+0x60>
  802507:	f7 f5                	div    %ebp
  802509:	89 d0                	mov    %edx,%eax
  80250b:	31 d2                	xor    %edx,%edx
  80250d:	83 c4 1c             	add    $0x1c,%esp
  802510:	5b                   	pop    %ebx
  802511:	5e                   	pop    %esi
  802512:	5f                   	pop    %edi
  802513:	5d                   	pop    %ebp
  802514:	c3                   	ret    
  802515:	8d 76 00             	lea    0x0(%esi),%esi
  802518:	39 df                	cmp    %ebx,%edi
  80251a:	77 f1                	ja     80250d <__umoddi3+0x2d>
  80251c:	0f bd cf             	bsr    %edi,%ecx
  80251f:	83 f1 1f             	xor    $0x1f,%ecx
  802522:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802526:	75 40                	jne    802568 <__umoddi3+0x88>
  802528:	39 df                	cmp    %ebx,%edi
  80252a:	72 04                	jb     802530 <__umoddi3+0x50>
  80252c:	39 f5                	cmp    %esi,%ebp
  80252e:	77 dd                	ja     80250d <__umoddi3+0x2d>
  802530:	89 da                	mov    %ebx,%edx
  802532:	89 f0                	mov    %esi,%eax
  802534:	29 e8                	sub    %ebp,%eax
  802536:	19 fa                	sbb    %edi,%edx
  802538:	eb d3                	jmp    80250d <__umoddi3+0x2d>
  80253a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802540:	89 e9                	mov    %ebp,%ecx
  802542:	85 ed                	test   %ebp,%ebp
  802544:	75 0b                	jne    802551 <__umoddi3+0x71>
  802546:	b8 01 00 00 00       	mov    $0x1,%eax
  80254b:	31 d2                	xor    %edx,%edx
  80254d:	f7 f5                	div    %ebp
  80254f:	89 c1                	mov    %eax,%ecx
  802551:	89 d8                	mov    %ebx,%eax
  802553:	31 d2                	xor    %edx,%edx
  802555:	f7 f1                	div    %ecx
  802557:	89 f0                	mov    %esi,%eax
  802559:	f7 f1                	div    %ecx
  80255b:	89 d0                	mov    %edx,%eax
  80255d:	31 d2                	xor    %edx,%edx
  80255f:	eb ac                	jmp    80250d <__umoddi3+0x2d>
  802561:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802568:	8b 44 24 04          	mov    0x4(%esp),%eax
  80256c:	ba 20 00 00 00       	mov    $0x20,%edx
  802571:	29 c2                	sub    %eax,%edx
  802573:	89 c1                	mov    %eax,%ecx
  802575:	89 e8                	mov    %ebp,%eax
  802577:	d3 e7                	shl    %cl,%edi
  802579:	89 d1                	mov    %edx,%ecx
  80257b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80257f:	d3 e8                	shr    %cl,%eax
  802581:	89 c1                	mov    %eax,%ecx
  802583:	8b 44 24 04          	mov    0x4(%esp),%eax
  802587:	09 f9                	or     %edi,%ecx
  802589:	89 df                	mov    %ebx,%edi
  80258b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80258f:	89 c1                	mov    %eax,%ecx
  802591:	d3 e5                	shl    %cl,%ebp
  802593:	89 d1                	mov    %edx,%ecx
  802595:	d3 ef                	shr    %cl,%edi
  802597:	89 c1                	mov    %eax,%ecx
  802599:	89 f0                	mov    %esi,%eax
  80259b:	d3 e3                	shl    %cl,%ebx
  80259d:	89 d1                	mov    %edx,%ecx
  80259f:	89 fa                	mov    %edi,%edx
  8025a1:	d3 e8                	shr    %cl,%eax
  8025a3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8025a8:	09 d8                	or     %ebx,%eax
  8025aa:	f7 74 24 08          	divl   0x8(%esp)
  8025ae:	89 d3                	mov    %edx,%ebx
  8025b0:	d3 e6                	shl    %cl,%esi
  8025b2:	f7 e5                	mul    %ebp
  8025b4:	89 c7                	mov    %eax,%edi
  8025b6:	89 d1                	mov    %edx,%ecx
  8025b8:	39 d3                	cmp    %edx,%ebx
  8025ba:	72 06                	jb     8025c2 <__umoddi3+0xe2>
  8025bc:	75 0e                	jne    8025cc <__umoddi3+0xec>
  8025be:	39 c6                	cmp    %eax,%esi
  8025c0:	73 0a                	jae    8025cc <__umoddi3+0xec>
  8025c2:	29 e8                	sub    %ebp,%eax
  8025c4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8025c8:	89 d1                	mov    %edx,%ecx
  8025ca:	89 c7                	mov    %eax,%edi
  8025cc:	89 f5                	mov    %esi,%ebp
  8025ce:	8b 74 24 04          	mov    0x4(%esp),%esi
  8025d2:	29 fd                	sub    %edi,%ebp
  8025d4:	19 cb                	sbb    %ecx,%ebx
  8025d6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8025db:	89 d8                	mov    %ebx,%eax
  8025dd:	d3 e0                	shl    %cl,%eax
  8025df:	89 f1                	mov    %esi,%ecx
  8025e1:	d3 ed                	shr    %cl,%ebp
  8025e3:	d3 eb                	shr    %cl,%ebx
  8025e5:	09 e8                	or     %ebp,%eax
  8025e7:	89 da                	mov    %ebx,%edx
  8025e9:	83 c4 1c             	add    $0x1c,%esp
  8025ec:	5b                   	pop    %ebx
  8025ed:	5e                   	pop    %esi
  8025ee:	5f                   	pop    %edi
  8025ef:	5d                   	pop    %ebp
  8025f0:	c3                   	ret    
