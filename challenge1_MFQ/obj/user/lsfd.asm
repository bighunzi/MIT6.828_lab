
obj/user/lsfd.debug：     文件格式 elf32-i386


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
  80002c:	e8 e0 00 00 00       	call   800111 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <usage>:
#include <inc/lib.h>

void
usage(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: lsfd [-1]\n");
  800039:	68 80 25 80 00       	push   $0x802580
  80003e:	e8 c6 01 00 00       	call   800209 <cprintf>
	exit();
  800043:	e8 12 01 00 00       	call   80015a <exit>
}
  800048:	83 c4 10             	add    $0x10,%esp
  80004b:	c9                   	leave  
  80004c:	c3                   	ret    

0080004d <umain>:

void
umain(int argc, char **argv)
{
  80004d:	55                   	push   %ebp
  80004e:	89 e5                	mov    %esp,%ebp
  800050:	57                   	push   %edi
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	81 ec b0 00 00 00    	sub    $0xb0,%esp
	int i, usefprint = 0;
	struct Stat st;
	struct Argstate args;

	argstart(&argc, argv, &args);
  800059:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80005f:	50                   	push   %eax
  800060:	ff 75 0c             	push   0xc(%ebp)
  800063:	8d 45 08             	lea    0x8(%ebp),%eax
  800066:	50                   	push   %eax
  800067:	e8 c5 0d 00 00       	call   800e31 <argstart>
	while ((i = argnext(&args)) >= 0)
  80006c:	83 c4 10             	add    $0x10,%esp
	int i, usefprint = 0;
  80006f:	be 00 00 00 00       	mov    $0x0,%esi
	while ((i = argnext(&args)) >= 0)
  800074:	8d 9d 4c ff ff ff    	lea    -0xb4(%ebp),%ebx
		if (i == '1')
			usefprint = 1;
  80007a:	bf 01 00 00 00       	mov    $0x1,%edi
	while ((i = argnext(&args)) >= 0)
  80007f:	83 ec 0c             	sub    $0xc,%esp
  800082:	53                   	push   %ebx
  800083:	e8 d9 0d 00 00       	call   800e61 <argnext>
  800088:	83 c4 10             	add    $0x10,%esp
  80008b:	85 c0                	test   %eax,%eax
  80008d:	78 10                	js     80009f <umain+0x52>
		if (i == '1')
  80008f:	83 f8 31             	cmp    $0x31,%eax
  800092:	75 04                	jne    800098 <umain+0x4b>
			usefprint = 1;
  800094:	89 fe                	mov    %edi,%esi
  800096:	eb e7                	jmp    80007f <umain+0x32>
		else
			usage();
  800098:	e8 96 ff ff ff       	call   800033 <usage>
  80009d:	eb e0                	jmp    80007f <umain+0x32>

	for (i = 0; i < 32; i++)
  80009f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fstat(i, &st) >= 0) {
  8000a4:	8d bd 5c ff ff ff    	lea    -0xa4(%ebp),%edi
  8000aa:	eb 26                	jmp    8000d2 <umain+0x85>
			if (usefprint)
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
			else
				cprintf("fd %d: name %s isdir %d size %d dev %s\n",
  8000ac:	83 ec 08             	sub    $0x8,%esp
  8000af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000b2:	ff 70 04             	push   0x4(%eax)
  8000b5:	ff 75 dc             	push   -0x24(%ebp)
  8000b8:	ff 75 e0             	push   -0x20(%ebp)
  8000bb:	57                   	push   %edi
  8000bc:	53                   	push   %ebx
  8000bd:	68 94 25 80 00       	push   $0x802594
  8000c2:	e8 42 01 00 00       	call   800209 <cprintf>
  8000c7:	83 c4 20             	add    $0x20,%esp
	for (i = 0; i < 32; i++)
  8000ca:	83 c3 01             	add    $0x1,%ebx
  8000cd:	83 fb 20             	cmp    $0x20,%ebx
  8000d0:	74 37                	je     800109 <umain+0xbc>
		if (fstat(i, &st) >= 0) {
  8000d2:	83 ec 08             	sub    $0x8,%esp
  8000d5:	57                   	push   %edi
  8000d6:	53                   	push   %ebx
  8000d7:	e8 7c 13 00 00       	call   801458 <fstat>
  8000dc:	83 c4 10             	add    $0x10,%esp
  8000df:	85 c0                	test   %eax,%eax
  8000e1:	78 e7                	js     8000ca <umain+0x7d>
			if (usefprint)
  8000e3:	85 f6                	test   %esi,%esi
  8000e5:	74 c5                	je     8000ac <umain+0x5f>
				fprintf(1, "fd %d: name %s isdir %d size %d dev %s\n",
  8000e7:	83 ec 04             	sub    $0x4,%esp
  8000ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000ed:	ff 70 04             	push   0x4(%eax)
  8000f0:	ff 75 dc             	push   -0x24(%ebp)
  8000f3:	ff 75 e0             	push   -0x20(%ebp)
  8000f6:	57                   	push   %edi
  8000f7:	53                   	push   %ebx
  8000f8:	68 94 25 80 00       	push   $0x802594
  8000fd:	6a 01                	push   $0x1
  8000ff:	e8 4a 17 00 00       	call   80184e <fprintf>
  800104:	83 c4 20             	add    $0x20,%esp
  800107:	eb c1                	jmp    8000ca <umain+0x7d>
					i, st.st_name, st.st_isdir,
					st.st_size, st.st_dev->dev_name);
		}
}
  800109:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5f                   	pop    %edi
  80010f:	5d                   	pop    %ebp
  800110:	c3                   	ret    

00800111 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800111:	55                   	push   %ebp
  800112:	89 e5                	mov    %esp,%ebp
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
  800116:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800119:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  80011c:	e8 80 0a 00 00       	call   800ba1 <sys_getenvid>
  800121:	25 ff 03 00 00       	and    $0x3ff,%eax
  800126:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80012c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800131:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800136:	85 db                	test   %ebx,%ebx
  800138:	7e 07                	jle    800141 <libmain+0x30>
		binaryname = argv[0];
  80013a:	8b 06                	mov    (%esi),%eax
  80013c:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800141:	83 ec 08             	sub    $0x8,%esp
  800144:	56                   	push   %esi
  800145:	53                   	push   %ebx
  800146:	e8 02 ff ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  80014b:	e8 0a 00 00 00       	call   80015a <exit>
}
  800150:	83 c4 10             	add    $0x10,%esp
  800153:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800160:	e8 ec 0f 00 00       	call   801151 <close_all>
	sys_env_destroy(0);
  800165:	83 ec 0c             	sub    $0xc,%esp
  800168:	6a 00                	push   $0x0
  80016a:	e8 f1 09 00 00       	call   800b60 <sys_env_destroy>
}
  80016f:	83 c4 10             	add    $0x10,%esp
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	53                   	push   %ebx
  800178:	83 ec 04             	sub    $0x4,%esp
  80017b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017e:	8b 13                	mov    (%ebx),%edx
  800180:	8d 42 01             	lea    0x1(%edx),%eax
  800183:	89 03                	mov    %eax,(%ebx)
  800185:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800188:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800191:	74 09                	je     80019c <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800193:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800197:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019a:	c9                   	leave  
  80019b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80019c:	83 ec 08             	sub    $0x8,%esp
  80019f:	68 ff 00 00 00       	push   $0xff
  8001a4:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a7:	50                   	push   %eax
  8001a8:	e8 76 09 00 00       	call   800b23 <sys_cputs>
		b->idx = 0;
  8001ad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	eb db                	jmp    800193 <putch+0x1f>

008001b8 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c8:	00 00 00 
	b.cnt = 0;
  8001cb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d5:	ff 75 0c             	push   0xc(%ebp)
  8001d8:	ff 75 08             	push   0x8(%ebp)
  8001db:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e1:	50                   	push   %eax
  8001e2:	68 74 01 80 00       	push   $0x800174
  8001e7:	e8 14 01 00 00       	call   800300 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001ec:	83 c4 08             	add    $0x8,%esp
  8001ef:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001f5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001fb:	50                   	push   %eax
  8001fc:	e8 22 09 00 00       	call   800b23 <sys_cputs>

	return b.cnt;
}
  800201:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800212:	50                   	push   %eax
  800213:	ff 75 08             	push   0x8(%ebp)
  800216:	e8 9d ff ff ff       	call   8001b8 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021b:	c9                   	leave  
  80021c:	c3                   	ret    

0080021d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021d:	55                   	push   %ebp
  80021e:	89 e5                	mov    %esp,%ebp
  800220:	57                   	push   %edi
  800221:	56                   	push   %esi
  800222:	53                   	push   %ebx
  800223:	83 ec 1c             	sub    $0x1c,%esp
  800226:	89 c7                	mov    %eax,%edi
  800228:	89 d6                	mov    %edx,%esi
  80022a:	8b 45 08             	mov    0x8(%ebp),%eax
  80022d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800230:	89 d1                	mov    %edx,%ecx
  800232:	89 c2                	mov    %eax,%edx
  800234:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800237:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80023a:	8b 45 10             	mov    0x10(%ebp),%eax
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800240:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800243:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80024a:	39 c2                	cmp    %eax,%edx
  80024c:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80024f:	72 3e                	jb     80028f <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800251:	83 ec 0c             	sub    $0xc,%esp
  800254:	ff 75 18             	push   0x18(%ebp)
  800257:	83 eb 01             	sub    $0x1,%ebx
  80025a:	53                   	push   %ebx
  80025b:	50                   	push   %eax
  80025c:	83 ec 08             	sub    $0x8,%esp
  80025f:	ff 75 e4             	push   -0x1c(%ebp)
  800262:	ff 75 e0             	push   -0x20(%ebp)
  800265:	ff 75 dc             	push   -0x24(%ebp)
  800268:	ff 75 d8             	push   -0x28(%ebp)
  80026b:	e8 c0 20 00 00       	call   802330 <__udivdi3>
  800270:	83 c4 18             	add    $0x18,%esp
  800273:	52                   	push   %edx
  800274:	50                   	push   %eax
  800275:	89 f2                	mov    %esi,%edx
  800277:	89 f8                	mov    %edi,%eax
  800279:	e8 9f ff ff ff       	call   80021d <printnum>
  80027e:	83 c4 20             	add    $0x20,%esp
  800281:	eb 13                	jmp    800296 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800283:	83 ec 08             	sub    $0x8,%esp
  800286:	56                   	push   %esi
  800287:	ff 75 18             	push   0x18(%ebp)
  80028a:	ff d7                	call   *%edi
  80028c:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80028f:	83 eb 01             	sub    $0x1,%ebx
  800292:	85 db                	test   %ebx,%ebx
  800294:	7f ed                	jg     800283 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800296:	83 ec 08             	sub    $0x8,%esp
  800299:	56                   	push   %esi
  80029a:	83 ec 04             	sub    $0x4,%esp
  80029d:	ff 75 e4             	push   -0x1c(%ebp)
  8002a0:	ff 75 e0             	push   -0x20(%ebp)
  8002a3:	ff 75 dc             	push   -0x24(%ebp)
  8002a6:	ff 75 d8             	push   -0x28(%ebp)
  8002a9:	e8 a2 21 00 00       	call   802450 <__umoddi3>
  8002ae:	83 c4 14             	add    $0x14,%esp
  8002b1:	0f be 80 c6 25 80 00 	movsbl 0x8025c6(%eax),%eax
  8002b8:	50                   	push   %eax
  8002b9:	ff d7                	call   *%edi
}
  8002bb:	83 c4 10             	add    $0x10,%esp
  8002be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
  8002c9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002cc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d5:	73 0a                	jae    8002e1 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d7:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002da:	89 08                	mov    %ecx,(%eax)
  8002dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8002df:	88 02                	mov    %al,(%edx)
}
  8002e1:	5d                   	pop    %ebp
  8002e2:	c3                   	ret    

008002e3 <printfmt>:
{
  8002e3:	55                   	push   %ebp
  8002e4:	89 e5                	mov    %esp,%ebp
  8002e6:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002e9:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002ec:	50                   	push   %eax
  8002ed:	ff 75 10             	push   0x10(%ebp)
  8002f0:	ff 75 0c             	push   0xc(%ebp)
  8002f3:	ff 75 08             	push   0x8(%ebp)
  8002f6:	e8 05 00 00 00       	call   800300 <vprintfmt>
}
  8002fb:	83 c4 10             	add    $0x10,%esp
  8002fe:	c9                   	leave  
  8002ff:	c3                   	ret    

00800300 <vprintfmt>:
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	57                   	push   %edi
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
  800306:	83 ec 3c             	sub    $0x3c,%esp
  800309:	8b 75 08             	mov    0x8(%ebp),%esi
  80030c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80030f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800312:	eb 0a                	jmp    80031e <vprintfmt+0x1e>
			putch(ch, putdat);
  800314:	83 ec 08             	sub    $0x8,%esp
  800317:	53                   	push   %ebx
  800318:	50                   	push   %eax
  800319:	ff d6                	call   *%esi
  80031b:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80031e:	83 c7 01             	add    $0x1,%edi
  800321:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800325:	83 f8 25             	cmp    $0x25,%eax
  800328:	74 0c                	je     800336 <vprintfmt+0x36>
			if (ch == '\0')
  80032a:	85 c0                	test   %eax,%eax
  80032c:	75 e6                	jne    800314 <vprintfmt+0x14>
}
  80032e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800331:	5b                   	pop    %ebx
  800332:	5e                   	pop    %esi
  800333:	5f                   	pop    %edi
  800334:	5d                   	pop    %ebp
  800335:	c3                   	ret    
		padc = ' ';
  800336:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80033a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800341:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800348:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80034f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800354:	8d 47 01             	lea    0x1(%edi),%eax
  800357:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80035a:	0f b6 17             	movzbl (%edi),%edx
  80035d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800360:	3c 55                	cmp    $0x55,%al
  800362:	0f 87 bb 03 00 00    	ja     800723 <vprintfmt+0x423>
  800368:	0f b6 c0             	movzbl %al,%eax
  80036b:	ff 24 85 00 27 80 00 	jmp    *0x802700(,%eax,4)
  800372:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800375:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800379:	eb d9                	jmp    800354 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80037b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037e:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800382:	eb d0                	jmp    800354 <vprintfmt+0x54>
  800384:	0f b6 d2             	movzbl %dl,%edx
  800387:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80038a:	b8 00 00 00 00       	mov    $0x0,%eax
  80038f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800392:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800395:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800399:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80039c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80039f:	83 f9 09             	cmp    $0x9,%ecx
  8003a2:	77 55                	ja     8003f9 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8003a4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003a7:	eb e9                	jmp    800392 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ac:	8b 00                	mov    (%eax),%eax
  8003ae:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b4:	8d 40 04             	lea    0x4(%eax),%eax
  8003b7:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003bd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003c1:	79 91                	jns    800354 <vprintfmt+0x54>
				width = precision, precision = -1;
  8003c3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003d0:	eb 82                	jmp    800354 <vprintfmt+0x54>
  8003d2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003d5:	85 d2                	test   %edx,%edx
  8003d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003dc:	0f 49 c2             	cmovns %edx,%eax
  8003df:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003e5:	e9 6a ff ff ff       	jmp    800354 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003ed:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003f4:	e9 5b ff ff ff       	jmp    800354 <vprintfmt+0x54>
  8003f9:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ff:	eb bc                	jmp    8003bd <vprintfmt+0xbd>
			lflag++;
  800401:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800404:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800407:	e9 48 ff ff ff       	jmp    800354 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80040c:	8b 45 14             	mov    0x14(%ebp),%eax
  80040f:	8d 78 04             	lea    0x4(%eax),%edi
  800412:	83 ec 08             	sub    $0x8,%esp
  800415:	53                   	push   %ebx
  800416:	ff 30                	push   (%eax)
  800418:	ff d6                	call   *%esi
			break;
  80041a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80041d:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800420:	e9 9d 02 00 00       	jmp    8006c2 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800425:	8b 45 14             	mov    0x14(%ebp),%eax
  800428:	8d 78 04             	lea    0x4(%eax),%edi
  80042b:	8b 10                	mov    (%eax),%edx
  80042d:	89 d0                	mov    %edx,%eax
  80042f:	f7 d8                	neg    %eax
  800431:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800434:	83 f8 0f             	cmp    $0xf,%eax
  800437:	7f 23                	jg     80045c <vprintfmt+0x15c>
  800439:	8b 14 85 60 28 80 00 	mov    0x802860(,%eax,4),%edx
  800440:	85 d2                	test   %edx,%edx
  800442:	74 18                	je     80045c <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800444:	52                   	push   %edx
  800445:	68 95 29 80 00       	push   $0x802995
  80044a:	53                   	push   %ebx
  80044b:	56                   	push   %esi
  80044c:	e8 92 fe ff ff       	call   8002e3 <printfmt>
  800451:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800454:	89 7d 14             	mov    %edi,0x14(%ebp)
  800457:	e9 66 02 00 00       	jmp    8006c2 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80045c:	50                   	push   %eax
  80045d:	68 de 25 80 00       	push   $0x8025de
  800462:	53                   	push   %ebx
  800463:	56                   	push   %esi
  800464:	e8 7a fe ff ff       	call   8002e3 <printfmt>
  800469:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80046c:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80046f:	e9 4e 02 00 00       	jmp    8006c2 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800474:	8b 45 14             	mov    0x14(%ebp),%eax
  800477:	83 c0 04             	add    $0x4,%eax
  80047a:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80047d:	8b 45 14             	mov    0x14(%ebp),%eax
  800480:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800482:	85 d2                	test   %edx,%edx
  800484:	b8 d7 25 80 00       	mov    $0x8025d7,%eax
  800489:	0f 45 c2             	cmovne %edx,%eax
  80048c:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80048f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800493:	7e 06                	jle    80049b <vprintfmt+0x19b>
  800495:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800499:	75 0d                	jne    8004a8 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80049b:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80049e:	89 c7                	mov    %eax,%edi
  8004a0:	03 45 e0             	add    -0x20(%ebp),%eax
  8004a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a6:	eb 55                	jmp    8004fd <vprintfmt+0x1fd>
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	ff 75 d8             	push   -0x28(%ebp)
  8004ae:	ff 75 cc             	push   -0x34(%ebp)
  8004b1:	e8 0a 03 00 00       	call   8007c0 <strnlen>
  8004b6:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b9:	29 c1                	sub    %eax,%ecx
  8004bb:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004be:	83 c4 10             	add    $0x10,%esp
  8004c1:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004c3:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ca:	eb 0f                	jmp    8004db <vprintfmt+0x1db>
					putch(padc, putdat);
  8004cc:	83 ec 08             	sub    $0x8,%esp
  8004cf:	53                   	push   %ebx
  8004d0:	ff 75 e0             	push   -0x20(%ebp)
  8004d3:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	83 ef 01             	sub    $0x1,%edi
  8004d8:	83 c4 10             	add    $0x10,%esp
  8004db:	85 ff                	test   %edi,%edi
  8004dd:	7f ed                	jg     8004cc <vprintfmt+0x1cc>
  8004df:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004e2:	85 d2                	test   %edx,%edx
  8004e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e9:	0f 49 c2             	cmovns %edx,%eax
  8004ec:	29 c2                	sub    %eax,%edx
  8004ee:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004f1:	eb a8                	jmp    80049b <vprintfmt+0x19b>
					putch(ch, putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	53                   	push   %ebx
  8004f7:	52                   	push   %edx
  8004f8:	ff d6                	call   *%esi
  8004fa:	83 c4 10             	add    $0x10,%esp
  8004fd:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800500:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800502:	83 c7 01             	add    $0x1,%edi
  800505:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800509:	0f be d0             	movsbl %al,%edx
  80050c:	85 d2                	test   %edx,%edx
  80050e:	74 4b                	je     80055b <vprintfmt+0x25b>
  800510:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800514:	78 06                	js     80051c <vprintfmt+0x21c>
  800516:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80051a:	78 1e                	js     80053a <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80051c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800520:	74 d1                	je     8004f3 <vprintfmt+0x1f3>
  800522:	0f be c0             	movsbl %al,%eax
  800525:	83 e8 20             	sub    $0x20,%eax
  800528:	83 f8 5e             	cmp    $0x5e,%eax
  80052b:	76 c6                	jbe    8004f3 <vprintfmt+0x1f3>
					putch('?', putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	53                   	push   %ebx
  800531:	6a 3f                	push   $0x3f
  800533:	ff d6                	call   *%esi
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	eb c3                	jmp    8004fd <vprintfmt+0x1fd>
  80053a:	89 cf                	mov    %ecx,%edi
  80053c:	eb 0e                	jmp    80054c <vprintfmt+0x24c>
				putch(' ', putdat);
  80053e:	83 ec 08             	sub    $0x8,%esp
  800541:	53                   	push   %ebx
  800542:	6a 20                	push   $0x20
  800544:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800546:	83 ef 01             	sub    $0x1,%edi
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	85 ff                	test   %edi,%edi
  80054e:	7f ee                	jg     80053e <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800550:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800553:	89 45 14             	mov    %eax,0x14(%ebp)
  800556:	e9 67 01 00 00       	jmp    8006c2 <vprintfmt+0x3c2>
  80055b:	89 cf                	mov    %ecx,%edi
  80055d:	eb ed                	jmp    80054c <vprintfmt+0x24c>
	if (lflag >= 2)
  80055f:	83 f9 01             	cmp    $0x1,%ecx
  800562:	7f 1b                	jg     80057f <vprintfmt+0x27f>
	else if (lflag)
  800564:	85 c9                	test   %ecx,%ecx
  800566:	74 63                	je     8005cb <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800568:	8b 45 14             	mov    0x14(%ebp),%eax
  80056b:	8b 00                	mov    (%eax),%eax
  80056d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800570:	99                   	cltd   
  800571:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800574:	8b 45 14             	mov    0x14(%ebp),%eax
  800577:	8d 40 04             	lea    0x4(%eax),%eax
  80057a:	89 45 14             	mov    %eax,0x14(%ebp)
  80057d:	eb 17                	jmp    800596 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80057f:	8b 45 14             	mov    0x14(%ebp),%eax
  800582:	8b 50 04             	mov    0x4(%eax),%edx
  800585:	8b 00                	mov    (%eax),%eax
  800587:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8d 40 08             	lea    0x8(%eax),%eax
  800593:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800596:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800599:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80059c:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8005a1:	85 c9                	test   %ecx,%ecx
  8005a3:	0f 89 ff 00 00 00    	jns    8006a8 <vprintfmt+0x3a8>
				putch('-', putdat);
  8005a9:	83 ec 08             	sub    $0x8,%esp
  8005ac:	53                   	push   %ebx
  8005ad:	6a 2d                	push   $0x2d
  8005af:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005b7:	f7 da                	neg    %edx
  8005b9:	83 d1 00             	adc    $0x0,%ecx
  8005bc:	f7 d9                	neg    %ecx
  8005be:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005c1:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005c6:	e9 dd 00 00 00       	jmp    8006a8 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8b 00                	mov    (%eax),%eax
  8005d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d3:	99                   	cltd   
  8005d4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8d 40 04             	lea    0x4(%eax),%eax
  8005dd:	89 45 14             	mov    %eax,0x14(%ebp)
  8005e0:	eb b4                	jmp    800596 <vprintfmt+0x296>
	if (lflag >= 2)
  8005e2:	83 f9 01             	cmp    $0x1,%ecx
  8005e5:	7f 1e                	jg     800605 <vprintfmt+0x305>
	else if (lflag)
  8005e7:	85 c9                	test   %ecx,%ecx
  8005e9:	74 32                	je     80061d <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8b 10                	mov    (%eax),%edx
  8005f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f5:	8d 40 04             	lea    0x4(%eax),%eax
  8005f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fb:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800600:	e9 a3 00 00 00       	jmp    8006a8 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800605:	8b 45 14             	mov    0x14(%ebp),%eax
  800608:	8b 10                	mov    (%eax),%edx
  80060a:	8b 48 04             	mov    0x4(%eax),%ecx
  80060d:	8d 40 08             	lea    0x8(%eax),%eax
  800610:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800613:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800618:	e9 8b 00 00 00       	jmp    8006a8 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80061d:	8b 45 14             	mov    0x14(%ebp),%eax
  800620:	8b 10                	mov    (%eax),%edx
  800622:	b9 00 00 00 00       	mov    $0x0,%ecx
  800627:	8d 40 04             	lea    0x4(%eax),%eax
  80062a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80062d:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800632:	eb 74                	jmp    8006a8 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800634:	83 f9 01             	cmp    $0x1,%ecx
  800637:	7f 1b                	jg     800654 <vprintfmt+0x354>
	else if (lflag)
  800639:	85 c9                	test   %ecx,%ecx
  80063b:	74 2c                	je     800669 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80063d:	8b 45 14             	mov    0x14(%ebp),%eax
  800640:	8b 10                	mov    (%eax),%edx
  800642:	b9 00 00 00 00       	mov    $0x0,%ecx
  800647:	8d 40 04             	lea    0x4(%eax),%eax
  80064a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80064d:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800652:	eb 54                	jmp    8006a8 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800654:	8b 45 14             	mov    0x14(%ebp),%eax
  800657:	8b 10                	mov    (%eax),%edx
  800659:	8b 48 04             	mov    0x4(%eax),%ecx
  80065c:	8d 40 08             	lea    0x8(%eax),%eax
  80065f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800662:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800667:	eb 3f                	jmp    8006a8 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8b 10                	mov    (%eax),%edx
  80066e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800673:	8d 40 04             	lea    0x4(%eax),%eax
  800676:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800679:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80067e:	eb 28                	jmp    8006a8 <vprintfmt+0x3a8>
			putch('0', putdat);
  800680:	83 ec 08             	sub    $0x8,%esp
  800683:	53                   	push   %ebx
  800684:	6a 30                	push   $0x30
  800686:	ff d6                	call   *%esi
			putch('x', putdat);
  800688:	83 c4 08             	add    $0x8,%esp
  80068b:	53                   	push   %ebx
  80068c:	6a 78                	push   $0x78
  80068e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8b 10                	mov    (%eax),%edx
  800695:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80069a:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80069d:	8d 40 04             	lea    0x4(%eax),%eax
  8006a0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a3:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8006a8:	83 ec 0c             	sub    $0xc,%esp
  8006ab:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006af:	50                   	push   %eax
  8006b0:	ff 75 e0             	push   -0x20(%ebp)
  8006b3:	57                   	push   %edi
  8006b4:	51                   	push   %ecx
  8006b5:	52                   	push   %edx
  8006b6:	89 da                	mov    %ebx,%edx
  8006b8:	89 f0                	mov    %esi,%eax
  8006ba:	e8 5e fb ff ff       	call   80021d <printnum>
			break;
  8006bf:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006c5:	e9 54 fc ff ff       	jmp    80031e <vprintfmt+0x1e>
	if (lflag >= 2)
  8006ca:	83 f9 01             	cmp    $0x1,%ecx
  8006cd:	7f 1b                	jg     8006ea <vprintfmt+0x3ea>
	else if (lflag)
  8006cf:	85 c9                	test   %ecx,%ecx
  8006d1:	74 2c                	je     8006ff <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8b 10                	mov    (%eax),%edx
  8006d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006dd:	8d 40 04             	lea    0x4(%eax),%eax
  8006e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e3:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8006e8:	eb be                	jmp    8006a8 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ed:	8b 10                	mov    (%eax),%edx
  8006ef:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f2:	8d 40 08             	lea    0x8(%eax),%eax
  8006f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f8:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8006fd:	eb a9                	jmp    8006a8 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800702:	8b 10                	mov    (%eax),%edx
  800704:	b9 00 00 00 00       	mov    $0x0,%ecx
  800709:	8d 40 04             	lea    0x4(%eax),%eax
  80070c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070f:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800714:	eb 92                	jmp    8006a8 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800716:	83 ec 08             	sub    $0x8,%esp
  800719:	53                   	push   %ebx
  80071a:	6a 25                	push   $0x25
  80071c:	ff d6                	call   *%esi
			break;
  80071e:	83 c4 10             	add    $0x10,%esp
  800721:	eb 9f                	jmp    8006c2 <vprintfmt+0x3c2>
			putch('%', putdat);
  800723:	83 ec 08             	sub    $0x8,%esp
  800726:	53                   	push   %ebx
  800727:	6a 25                	push   $0x25
  800729:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80072b:	83 c4 10             	add    $0x10,%esp
  80072e:	89 f8                	mov    %edi,%eax
  800730:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800734:	74 05                	je     80073b <vprintfmt+0x43b>
  800736:	83 e8 01             	sub    $0x1,%eax
  800739:	eb f5                	jmp    800730 <vprintfmt+0x430>
  80073b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80073e:	eb 82                	jmp    8006c2 <vprintfmt+0x3c2>

00800740 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800740:	55                   	push   %ebp
  800741:	89 e5                	mov    %esp,%ebp
  800743:	83 ec 18             	sub    $0x18,%esp
  800746:	8b 45 08             	mov    0x8(%ebp),%eax
  800749:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800753:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800756:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80075d:	85 c0                	test   %eax,%eax
  80075f:	74 26                	je     800787 <vsnprintf+0x47>
  800761:	85 d2                	test   %edx,%edx
  800763:	7e 22                	jle    800787 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800765:	ff 75 14             	push   0x14(%ebp)
  800768:	ff 75 10             	push   0x10(%ebp)
  80076b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076e:	50                   	push   %eax
  80076f:	68 c6 02 80 00       	push   $0x8002c6
  800774:	e8 87 fb ff ff       	call   800300 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800779:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800782:	83 c4 10             	add    $0x10,%esp
}
  800785:	c9                   	leave  
  800786:	c3                   	ret    
		return -E_INVAL;
  800787:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80078c:	eb f7                	jmp    800785 <vsnprintf+0x45>

0080078e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800794:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800797:	50                   	push   %eax
  800798:	ff 75 10             	push   0x10(%ebp)
  80079b:	ff 75 0c             	push   0xc(%ebp)
  80079e:	ff 75 08             	push   0x8(%ebp)
  8007a1:	e8 9a ff ff ff       	call   800740 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a6:	c9                   	leave  
  8007a7:	c3                   	ret    

008007a8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b3:	eb 03                	jmp    8007b8 <strlen+0x10>
		n++;
  8007b5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007b8:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007bc:	75 f7                	jne    8007b5 <strlen+0xd>
	return n;
}
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    

008007c0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c6:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ce:	eb 03                	jmp    8007d3 <strnlen+0x13>
		n++;
  8007d0:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d3:	39 d0                	cmp    %edx,%eax
  8007d5:	74 08                	je     8007df <strnlen+0x1f>
  8007d7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007db:	75 f3                	jne    8007d0 <strnlen+0x10>
  8007dd:	89 c2                	mov    %eax,%edx
	return n;
}
  8007df:	89 d0                	mov    %edx,%eax
  8007e1:	5d                   	pop    %ebp
  8007e2:	c3                   	ret    

008007e3 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e3:	55                   	push   %ebp
  8007e4:	89 e5                	mov    %esp,%ebp
  8007e6:	53                   	push   %ebx
  8007e7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007ea:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f2:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007f6:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007f9:	83 c0 01             	add    $0x1,%eax
  8007fc:	84 d2                	test   %dl,%dl
  8007fe:	75 f2                	jne    8007f2 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800800:	89 c8                	mov    %ecx,%eax
  800802:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800805:	c9                   	leave  
  800806:	c3                   	ret    

00800807 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800807:	55                   	push   %ebp
  800808:	89 e5                	mov    %esp,%ebp
  80080a:	53                   	push   %ebx
  80080b:	83 ec 10             	sub    $0x10,%esp
  80080e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800811:	53                   	push   %ebx
  800812:	e8 91 ff ff ff       	call   8007a8 <strlen>
  800817:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80081a:	ff 75 0c             	push   0xc(%ebp)
  80081d:	01 d8                	add    %ebx,%eax
  80081f:	50                   	push   %eax
  800820:	e8 be ff ff ff       	call   8007e3 <strcpy>
	return dst;
}
  800825:	89 d8                	mov    %ebx,%eax
  800827:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80082a:	c9                   	leave  
  80082b:	c3                   	ret    

0080082c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	56                   	push   %esi
  800830:	53                   	push   %ebx
  800831:	8b 75 08             	mov    0x8(%ebp),%esi
  800834:	8b 55 0c             	mov    0xc(%ebp),%edx
  800837:	89 f3                	mov    %esi,%ebx
  800839:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80083c:	89 f0                	mov    %esi,%eax
  80083e:	eb 0f                	jmp    80084f <strncpy+0x23>
		*dst++ = *src;
  800840:	83 c0 01             	add    $0x1,%eax
  800843:	0f b6 0a             	movzbl (%edx),%ecx
  800846:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800849:	80 f9 01             	cmp    $0x1,%cl
  80084c:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80084f:	39 d8                	cmp    %ebx,%eax
  800851:	75 ed                	jne    800840 <strncpy+0x14>
	}
	return ret;
}
  800853:	89 f0                	mov    %esi,%eax
  800855:	5b                   	pop    %ebx
  800856:	5e                   	pop    %esi
  800857:	5d                   	pop    %ebp
  800858:	c3                   	ret    

00800859 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800859:	55                   	push   %ebp
  80085a:	89 e5                	mov    %esp,%ebp
  80085c:	56                   	push   %esi
  80085d:	53                   	push   %ebx
  80085e:	8b 75 08             	mov    0x8(%ebp),%esi
  800861:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800864:	8b 55 10             	mov    0x10(%ebp),%edx
  800867:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800869:	85 d2                	test   %edx,%edx
  80086b:	74 21                	je     80088e <strlcpy+0x35>
  80086d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800871:	89 f2                	mov    %esi,%edx
  800873:	eb 09                	jmp    80087e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800875:	83 c1 01             	add    $0x1,%ecx
  800878:	83 c2 01             	add    $0x1,%edx
  80087b:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80087e:	39 c2                	cmp    %eax,%edx
  800880:	74 09                	je     80088b <strlcpy+0x32>
  800882:	0f b6 19             	movzbl (%ecx),%ebx
  800885:	84 db                	test   %bl,%bl
  800887:	75 ec                	jne    800875 <strlcpy+0x1c>
  800889:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80088b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80088e:	29 f0                	sub    %esi,%eax
}
  800890:	5b                   	pop    %ebx
  800891:	5e                   	pop    %esi
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80089a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089d:	eb 06                	jmp    8008a5 <strcmp+0x11>
		p++, q++;
  80089f:	83 c1 01             	add    $0x1,%ecx
  8008a2:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008a5:	0f b6 01             	movzbl (%ecx),%eax
  8008a8:	84 c0                	test   %al,%al
  8008aa:	74 04                	je     8008b0 <strcmp+0x1c>
  8008ac:	3a 02                	cmp    (%edx),%al
  8008ae:	74 ef                	je     80089f <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b0:	0f b6 c0             	movzbl %al,%eax
  8008b3:	0f b6 12             	movzbl (%edx),%edx
  8008b6:	29 d0                	sub    %edx,%eax
}
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	53                   	push   %ebx
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c4:	89 c3                	mov    %eax,%ebx
  8008c6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c9:	eb 06                	jmp    8008d1 <strncmp+0x17>
		n--, p++, q++;
  8008cb:	83 c0 01             	add    $0x1,%eax
  8008ce:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008d1:	39 d8                	cmp    %ebx,%eax
  8008d3:	74 18                	je     8008ed <strncmp+0x33>
  8008d5:	0f b6 08             	movzbl (%eax),%ecx
  8008d8:	84 c9                	test   %cl,%cl
  8008da:	74 04                	je     8008e0 <strncmp+0x26>
  8008dc:	3a 0a                	cmp    (%edx),%cl
  8008de:	74 eb                	je     8008cb <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008e0:	0f b6 00             	movzbl (%eax),%eax
  8008e3:	0f b6 12             	movzbl (%edx),%edx
  8008e6:	29 d0                	sub    %edx,%eax
}
  8008e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008eb:	c9                   	leave  
  8008ec:	c3                   	ret    
		return 0;
  8008ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f2:	eb f4                	jmp    8008e8 <strncmp+0x2e>

008008f4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fa:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fe:	eb 03                	jmp    800903 <strchr+0xf>
  800900:	83 c0 01             	add    $0x1,%eax
  800903:	0f b6 10             	movzbl (%eax),%edx
  800906:	84 d2                	test   %dl,%dl
  800908:	74 06                	je     800910 <strchr+0x1c>
		if (*s == c)
  80090a:	38 ca                	cmp    %cl,%dl
  80090c:	75 f2                	jne    800900 <strchr+0xc>
  80090e:	eb 05                	jmp    800915 <strchr+0x21>
			return (char *) s;
	return 0;
  800910:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    

00800917 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	8b 45 08             	mov    0x8(%ebp),%eax
  80091d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800921:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800924:	38 ca                	cmp    %cl,%dl
  800926:	74 09                	je     800931 <strfind+0x1a>
  800928:	84 d2                	test   %dl,%dl
  80092a:	74 05                	je     800931 <strfind+0x1a>
	for (; *s; s++)
  80092c:	83 c0 01             	add    $0x1,%eax
  80092f:	eb f0                	jmp    800921 <strfind+0xa>
			break;
	return (char *) s;
}
  800931:	5d                   	pop    %ebp
  800932:	c3                   	ret    

00800933 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	57                   	push   %edi
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	8b 7d 08             	mov    0x8(%ebp),%edi
  80093c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093f:	85 c9                	test   %ecx,%ecx
  800941:	74 2f                	je     800972 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800943:	89 f8                	mov    %edi,%eax
  800945:	09 c8                	or     %ecx,%eax
  800947:	a8 03                	test   $0x3,%al
  800949:	75 21                	jne    80096c <memset+0x39>
		c &= 0xFF;
  80094b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094f:	89 d0                	mov    %edx,%eax
  800951:	c1 e0 08             	shl    $0x8,%eax
  800954:	89 d3                	mov    %edx,%ebx
  800956:	c1 e3 18             	shl    $0x18,%ebx
  800959:	89 d6                	mov    %edx,%esi
  80095b:	c1 e6 10             	shl    $0x10,%esi
  80095e:	09 f3                	or     %esi,%ebx
  800960:	09 da                	or     %ebx,%edx
  800962:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800964:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800967:	fc                   	cld    
  800968:	f3 ab                	rep stos %eax,%es:(%edi)
  80096a:	eb 06                	jmp    800972 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80096c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096f:	fc                   	cld    
  800970:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800972:	89 f8                	mov    %edi,%eax
  800974:	5b                   	pop    %ebx
  800975:	5e                   	pop    %esi
  800976:	5f                   	pop    %edi
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	57                   	push   %edi
  80097d:	56                   	push   %esi
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 75 0c             	mov    0xc(%ebp),%esi
  800984:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800987:	39 c6                	cmp    %eax,%esi
  800989:	73 32                	jae    8009bd <memmove+0x44>
  80098b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80098e:	39 c2                	cmp    %eax,%edx
  800990:	76 2b                	jbe    8009bd <memmove+0x44>
		s += n;
		d += n;
  800992:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800995:	89 d6                	mov    %edx,%esi
  800997:	09 fe                	or     %edi,%esi
  800999:	09 ce                	or     %ecx,%esi
  80099b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009a1:	75 0e                	jne    8009b1 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a3:	83 ef 04             	sub    $0x4,%edi
  8009a6:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a9:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009ac:	fd                   	std    
  8009ad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009af:	eb 09                	jmp    8009ba <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009b1:	83 ef 01             	sub    $0x1,%edi
  8009b4:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009b7:	fd                   	std    
  8009b8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ba:	fc                   	cld    
  8009bb:	eb 1a                	jmp    8009d7 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009bd:	89 f2                	mov    %esi,%edx
  8009bf:	09 c2                	or     %eax,%edx
  8009c1:	09 ca                	or     %ecx,%edx
  8009c3:	f6 c2 03             	test   $0x3,%dl
  8009c6:	75 0a                	jne    8009d2 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009cb:	89 c7                	mov    %eax,%edi
  8009cd:	fc                   	cld    
  8009ce:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009d0:	eb 05                	jmp    8009d7 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009d2:	89 c7                	mov    %eax,%edi
  8009d4:	fc                   	cld    
  8009d5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d7:	5e                   	pop    %esi
  8009d8:	5f                   	pop    %edi
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009e1:	ff 75 10             	push   0x10(%ebp)
  8009e4:	ff 75 0c             	push   0xc(%ebp)
  8009e7:	ff 75 08             	push   0x8(%ebp)
  8009ea:	e8 8a ff ff ff       	call   800979 <memmove>
}
  8009ef:	c9                   	leave  
  8009f0:	c3                   	ret    

008009f1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	56                   	push   %esi
  8009f5:	53                   	push   %ebx
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009fc:	89 c6                	mov    %eax,%esi
  8009fe:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a01:	eb 06                	jmp    800a09 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a03:	83 c0 01             	add    $0x1,%eax
  800a06:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a09:	39 f0                	cmp    %esi,%eax
  800a0b:	74 14                	je     800a21 <memcmp+0x30>
		if (*s1 != *s2)
  800a0d:	0f b6 08             	movzbl (%eax),%ecx
  800a10:	0f b6 1a             	movzbl (%edx),%ebx
  800a13:	38 d9                	cmp    %bl,%cl
  800a15:	74 ec                	je     800a03 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a17:	0f b6 c1             	movzbl %cl,%eax
  800a1a:	0f b6 db             	movzbl %bl,%ebx
  800a1d:	29 d8                	sub    %ebx,%eax
  800a1f:	eb 05                	jmp    800a26 <memcmp+0x35>
	}

	return 0;
  800a21:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a26:	5b                   	pop    %ebx
  800a27:	5e                   	pop    %esi
  800a28:	5d                   	pop    %ebp
  800a29:	c3                   	ret    

00800a2a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a2a:	55                   	push   %ebp
  800a2b:	89 e5                	mov    %esp,%ebp
  800a2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a33:	89 c2                	mov    %eax,%edx
  800a35:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a38:	eb 03                	jmp    800a3d <memfind+0x13>
  800a3a:	83 c0 01             	add    $0x1,%eax
  800a3d:	39 d0                	cmp    %edx,%eax
  800a3f:	73 04                	jae    800a45 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a41:	38 08                	cmp    %cl,(%eax)
  800a43:	75 f5                	jne    800a3a <memfind+0x10>
			break;
	return (void *) s;
}
  800a45:	5d                   	pop    %ebp
  800a46:	c3                   	ret    

00800a47 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a47:	55                   	push   %ebp
  800a48:	89 e5                	mov    %esp,%ebp
  800a4a:	57                   	push   %edi
  800a4b:	56                   	push   %esi
  800a4c:	53                   	push   %ebx
  800a4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a50:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a53:	eb 03                	jmp    800a58 <strtol+0x11>
		s++;
  800a55:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a58:	0f b6 02             	movzbl (%edx),%eax
  800a5b:	3c 20                	cmp    $0x20,%al
  800a5d:	74 f6                	je     800a55 <strtol+0xe>
  800a5f:	3c 09                	cmp    $0x9,%al
  800a61:	74 f2                	je     800a55 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a63:	3c 2b                	cmp    $0x2b,%al
  800a65:	74 2a                	je     800a91 <strtol+0x4a>
	int neg = 0;
  800a67:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a6c:	3c 2d                	cmp    $0x2d,%al
  800a6e:	74 2b                	je     800a9b <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a70:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a76:	75 0f                	jne    800a87 <strtol+0x40>
  800a78:	80 3a 30             	cmpb   $0x30,(%edx)
  800a7b:	74 28                	je     800aa5 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7d:	85 db                	test   %ebx,%ebx
  800a7f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a84:	0f 44 d8             	cmove  %eax,%ebx
  800a87:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a8c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a8f:	eb 46                	jmp    800ad7 <strtol+0x90>
		s++;
  800a91:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a94:	bf 00 00 00 00       	mov    $0x0,%edi
  800a99:	eb d5                	jmp    800a70 <strtol+0x29>
		s++, neg = 1;
  800a9b:	83 c2 01             	add    $0x1,%edx
  800a9e:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa3:	eb cb                	jmp    800a70 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa5:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aa9:	74 0e                	je     800ab9 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800aab:	85 db                	test   %ebx,%ebx
  800aad:	75 d8                	jne    800a87 <strtol+0x40>
		s++, base = 8;
  800aaf:	83 c2 01             	add    $0x1,%edx
  800ab2:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ab7:	eb ce                	jmp    800a87 <strtol+0x40>
		s += 2, base = 16;
  800ab9:	83 c2 02             	add    $0x2,%edx
  800abc:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ac1:	eb c4                	jmp    800a87 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ac3:	0f be c0             	movsbl %al,%eax
  800ac6:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac9:	3b 45 10             	cmp    0x10(%ebp),%eax
  800acc:	7d 3a                	jge    800b08 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ace:	83 c2 01             	add    $0x1,%edx
  800ad1:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ad5:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ad7:	0f b6 02             	movzbl (%edx),%eax
  800ada:	8d 70 d0             	lea    -0x30(%eax),%esi
  800add:	89 f3                	mov    %esi,%ebx
  800adf:	80 fb 09             	cmp    $0x9,%bl
  800ae2:	76 df                	jbe    800ac3 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ae4:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ae7:	89 f3                	mov    %esi,%ebx
  800ae9:	80 fb 19             	cmp    $0x19,%bl
  800aec:	77 08                	ja     800af6 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800aee:	0f be c0             	movsbl %al,%eax
  800af1:	83 e8 57             	sub    $0x57,%eax
  800af4:	eb d3                	jmp    800ac9 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800af6:	8d 70 bf             	lea    -0x41(%eax),%esi
  800af9:	89 f3                	mov    %esi,%ebx
  800afb:	80 fb 19             	cmp    $0x19,%bl
  800afe:	77 08                	ja     800b08 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b00:	0f be c0             	movsbl %al,%eax
  800b03:	83 e8 37             	sub    $0x37,%eax
  800b06:	eb c1                	jmp    800ac9 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b08:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b0c:	74 05                	je     800b13 <strtol+0xcc>
		*endptr = (char *) s;
  800b0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b11:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b13:	89 c8                	mov    %ecx,%eax
  800b15:	f7 d8                	neg    %eax
  800b17:	85 ff                	test   %edi,%edi
  800b19:	0f 45 c8             	cmovne %eax,%ecx
}
  800b1c:	89 c8                	mov    %ecx,%eax
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5f                   	pop    %edi
  800b21:	5d                   	pop    %ebp
  800b22:	c3                   	ret    

00800b23 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	57                   	push   %edi
  800b27:	56                   	push   %esi
  800b28:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b29:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b34:	89 c3                	mov    %eax,%ebx
  800b36:	89 c7                	mov    %eax,%edi
  800b38:	89 c6                	mov    %eax,%esi
  800b3a:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5f                   	pop    %edi
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	57                   	push   %edi
  800b45:	56                   	push   %esi
  800b46:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b47:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b51:	89 d1                	mov    %edx,%ecx
  800b53:	89 d3                	mov    %edx,%ebx
  800b55:	89 d7                	mov    %edx,%edi
  800b57:	89 d6                	mov    %edx,%esi
  800b59:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b5b:	5b                   	pop    %ebx
  800b5c:	5e                   	pop    %esi
  800b5d:	5f                   	pop    %edi
  800b5e:	5d                   	pop    %ebp
  800b5f:	c3                   	ret    

00800b60 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b60:	55                   	push   %ebp
  800b61:	89 e5                	mov    %esp,%ebp
  800b63:	57                   	push   %edi
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
  800b66:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b69:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b71:	b8 03 00 00 00       	mov    $0x3,%eax
  800b76:	89 cb                	mov    %ecx,%ebx
  800b78:	89 cf                	mov    %ecx,%edi
  800b7a:	89 ce                	mov    %ecx,%esi
  800b7c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b7e:	85 c0                	test   %eax,%eax
  800b80:	7f 08                	jg     800b8a <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b85:	5b                   	pop    %ebx
  800b86:	5e                   	pop    %esi
  800b87:	5f                   	pop    %edi
  800b88:	5d                   	pop    %ebp
  800b89:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8a:	83 ec 0c             	sub    $0xc,%esp
  800b8d:	50                   	push   %eax
  800b8e:	6a 03                	push   $0x3
  800b90:	68 bf 28 80 00       	push   $0x8028bf
  800b95:	6a 2a                	push   $0x2a
  800b97:	68 dc 28 80 00       	push   $0x8028dc
  800b9c:	e8 00 16 00 00       	call   8021a1 <_panic>

00800ba1 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	57                   	push   %edi
  800ba5:	56                   	push   %esi
  800ba6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba7:	ba 00 00 00 00       	mov    $0x0,%edx
  800bac:	b8 02 00 00 00       	mov    $0x2,%eax
  800bb1:	89 d1                	mov    %edx,%ecx
  800bb3:	89 d3                	mov    %edx,%ebx
  800bb5:	89 d7                	mov    %edx,%edi
  800bb7:	89 d6                	mov    %edx,%esi
  800bb9:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bbb:	5b                   	pop    %ebx
  800bbc:	5e                   	pop    %esi
  800bbd:	5f                   	pop    %edi
  800bbe:	5d                   	pop    %ebp
  800bbf:	c3                   	ret    

00800bc0 <sys_yield>:

void
sys_yield(void)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	57                   	push   %edi
  800bc4:	56                   	push   %esi
  800bc5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcb:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bd0:	89 d1                	mov    %edx,%ecx
  800bd2:	89 d3                	mov    %edx,%ebx
  800bd4:	89 d7                	mov    %edx,%edi
  800bd6:	89 d6                	mov    %edx,%esi
  800bd8:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
  800be5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800be8:	be 00 00 00 00       	mov    $0x0,%esi
  800bed:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf3:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bfb:	89 f7                	mov    %esi,%edi
  800bfd:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bff:	85 c0                	test   %eax,%eax
  800c01:	7f 08                	jg     800c0b <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c06:	5b                   	pop    %ebx
  800c07:	5e                   	pop    %esi
  800c08:	5f                   	pop    %edi
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0b:	83 ec 0c             	sub    $0xc,%esp
  800c0e:	50                   	push   %eax
  800c0f:	6a 04                	push   $0x4
  800c11:	68 bf 28 80 00       	push   $0x8028bf
  800c16:	6a 2a                	push   $0x2a
  800c18:	68 dc 28 80 00       	push   $0x8028dc
  800c1d:	e8 7f 15 00 00       	call   8021a1 <_panic>

00800c22 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c31:	b8 05 00 00 00       	mov    $0x5,%eax
  800c36:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c39:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c3c:	8b 75 18             	mov    0x18(%ebp),%esi
  800c3f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c41:	85 c0                	test   %eax,%eax
  800c43:	7f 08                	jg     800c4d <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c45:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c48:	5b                   	pop    %ebx
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4d:	83 ec 0c             	sub    $0xc,%esp
  800c50:	50                   	push   %eax
  800c51:	6a 05                	push   $0x5
  800c53:	68 bf 28 80 00       	push   $0x8028bf
  800c58:	6a 2a                	push   $0x2a
  800c5a:	68 dc 28 80 00       	push   $0x8028dc
  800c5f:	e8 3d 15 00 00       	call   8021a1 <_panic>

00800c64 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	57                   	push   %edi
  800c68:	56                   	push   %esi
  800c69:	53                   	push   %ebx
  800c6a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c72:	8b 55 08             	mov    0x8(%ebp),%edx
  800c75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c78:	b8 06 00 00 00       	mov    $0x6,%eax
  800c7d:	89 df                	mov    %ebx,%edi
  800c7f:	89 de                	mov    %ebx,%esi
  800c81:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c83:	85 c0                	test   %eax,%eax
  800c85:	7f 08                	jg     800c8f <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c87:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8a:	5b                   	pop    %ebx
  800c8b:	5e                   	pop    %esi
  800c8c:	5f                   	pop    %edi
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8f:	83 ec 0c             	sub    $0xc,%esp
  800c92:	50                   	push   %eax
  800c93:	6a 06                	push   $0x6
  800c95:	68 bf 28 80 00       	push   $0x8028bf
  800c9a:	6a 2a                	push   $0x2a
  800c9c:	68 dc 28 80 00       	push   $0x8028dc
  800ca1:	e8 fb 14 00 00       	call   8021a1 <_panic>

00800ca6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	57                   	push   %edi
  800caa:	56                   	push   %esi
  800cab:	53                   	push   %ebx
  800cac:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800caf:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cba:	b8 08 00 00 00       	mov    $0x8,%eax
  800cbf:	89 df                	mov    %ebx,%edi
  800cc1:	89 de                	mov    %ebx,%esi
  800cc3:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	7f 08                	jg     800cd1 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ccc:	5b                   	pop    %ebx
  800ccd:	5e                   	pop    %esi
  800cce:	5f                   	pop    %edi
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd1:	83 ec 0c             	sub    $0xc,%esp
  800cd4:	50                   	push   %eax
  800cd5:	6a 08                	push   $0x8
  800cd7:	68 bf 28 80 00       	push   $0x8028bf
  800cdc:	6a 2a                	push   $0x2a
  800cde:	68 dc 28 80 00       	push   $0x8028dc
  800ce3:	e8 b9 14 00 00       	call   8021a1 <_panic>

00800ce8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	57                   	push   %edi
  800cec:	56                   	push   %esi
  800ced:	53                   	push   %ebx
  800cee:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cf1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf6:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfc:	b8 09 00 00 00       	mov    $0x9,%eax
  800d01:	89 df                	mov    %ebx,%edi
  800d03:	89 de                	mov    %ebx,%esi
  800d05:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d07:	85 c0                	test   %eax,%eax
  800d09:	7f 08                	jg     800d13 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d13:	83 ec 0c             	sub    $0xc,%esp
  800d16:	50                   	push   %eax
  800d17:	6a 09                	push   $0x9
  800d19:	68 bf 28 80 00       	push   $0x8028bf
  800d1e:	6a 2a                	push   $0x2a
  800d20:	68 dc 28 80 00       	push   $0x8028dc
  800d25:	e8 77 14 00 00       	call   8021a1 <_panic>

00800d2a <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d33:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d38:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d43:	89 df                	mov    %ebx,%edi
  800d45:	89 de                	mov    %ebx,%esi
  800d47:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	7f 08                	jg     800d55 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d55:	83 ec 0c             	sub    $0xc,%esp
  800d58:	50                   	push   %eax
  800d59:	6a 0a                	push   $0xa
  800d5b:	68 bf 28 80 00       	push   $0x8028bf
  800d60:	6a 2a                	push   $0x2a
  800d62:	68 dc 28 80 00       	push   $0x8028dc
  800d67:	e8 35 14 00 00       	call   8021a1 <_panic>

00800d6c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	57                   	push   %edi
  800d70:	56                   	push   %esi
  800d71:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d78:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d7d:	be 00 00 00 00       	mov    $0x0,%esi
  800d82:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d85:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d88:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d8a:	5b                   	pop    %ebx
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d8f:	55                   	push   %ebp
  800d90:	89 e5                	mov    %esp,%ebp
  800d92:	57                   	push   %edi
  800d93:	56                   	push   %esi
  800d94:	53                   	push   %ebx
  800d95:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d98:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800da0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800da5:	89 cb                	mov    %ecx,%ebx
  800da7:	89 cf                	mov    %ecx,%edi
  800da9:	89 ce                	mov    %ecx,%esi
  800dab:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dad:	85 c0                	test   %eax,%eax
  800daf:	7f 08                	jg     800db9 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800db1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800db4:	5b                   	pop    %ebx
  800db5:	5e                   	pop    %esi
  800db6:	5f                   	pop    %edi
  800db7:	5d                   	pop    %ebp
  800db8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800db9:	83 ec 0c             	sub    $0xc,%esp
  800dbc:	50                   	push   %eax
  800dbd:	6a 0d                	push   $0xd
  800dbf:	68 bf 28 80 00       	push   $0x8028bf
  800dc4:	6a 2a                	push   $0x2a
  800dc6:	68 dc 28 80 00       	push   $0x8028dc
  800dcb:	e8 d1 13 00 00       	call   8021a1 <_panic>

00800dd0 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dd0:	55                   	push   %ebp
  800dd1:	89 e5                	mov    %esp,%ebp
  800dd3:	57                   	push   %edi
  800dd4:	56                   	push   %esi
  800dd5:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dd6:	ba 00 00 00 00       	mov    $0x0,%edx
  800ddb:	b8 0e 00 00 00       	mov    $0xe,%eax
  800de0:	89 d1                	mov    %edx,%ecx
  800de2:	89 d3                	mov    %edx,%ebx
  800de4:	89 d7                	mov    %edx,%edi
  800de6:	89 d6                	mov    %edx,%esi
  800de8:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dea:	5b                   	pop    %ebx
  800deb:	5e                   	pop    %esi
  800dec:	5f                   	pop    %edi
  800ded:	5d                   	pop    %ebp
  800dee:	c3                   	ret    

00800def <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	57                   	push   %edi
  800df3:	56                   	push   %esi
  800df4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e00:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e05:	89 df                	mov    %ebx,%edi
  800e07:	89 de                	mov    %ebx,%esi
  800e09:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5f                   	pop    %edi
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	57                   	push   %edi
  800e14:	56                   	push   %esi
  800e15:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e16:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e21:	b8 10 00 00 00       	mov    $0x10,%eax
  800e26:	89 df                	mov    %ebx,%edi
  800e28:	89 de                	mov    %ebx,%esi
  800e2a:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800e2c:	5b                   	pop    %ebx
  800e2d:	5e                   	pop    %esi
  800e2e:	5f                   	pop    %edi
  800e2f:	5d                   	pop    %ebp
  800e30:	c3                   	ret    

00800e31 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	8b 55 08             	mov    0x8(%ebp),%edx
  800e37:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3a:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800e3d:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800e3f:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800e42:	83 3a 01             	cmpl   $0x1,(%edx)
  800e45:	7e 09                	jle    800e50 <argstart+0x1f>
  800e47:	ba 91 25 80 00       	mov    $0x802591,%edx
  800e4c:	85 c9                	test   %ecx,%ecx
  800e4e:	75 05                	jne    800e55 <argstart+0x24>
  800e50:	ba 00 00 00 00       	mov    $0x0,%edx
  800e55:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800e58:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <argnext>:

int
argnext(struct Argstate *args)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	53                   	push   %ebx
  800e65:	83 ec 04             	sub    $0x4,%esp
  800e68:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800e6b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800e72:	8b 43 08             	mov    0x8(%ebx),%eax
  800e75:	85 c0                	test   %eax,%eax
  800e77:	74 74                	je     800eed <argnext+0x8c>
		return -1;

	if (!*args->curarg) {
  800e79:	80 38 00             	cmpb   $0x0,(%eax)
  800e7c:	75 48                	jne    800ec6 <argnext+0x65>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800e7e:	8b 0b                	mov    (%ebx),%ecx
  800e80:	83 39 01             	cmpl   $0x1,(%ecx)
  800e83:	74 5a                	je     800edf <argnext+0x7e>
		    || args->argv[1][0] != '-'
  800e85:	8b 53 04             	mov    0x4(%ebx),%edx
  800e88:	8b 42 04             	mov    0x4(%edx),%eax
  800e8b:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e8e:	75 4f                	jne    800edf <argnext+0x7e>
		    || args->argv[1][1] == '\0')
  800e90:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e94:	74 49                	je     800edf <argnext+0x7e>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800e96:	83 c0 01             	add    $0x1,%eax
  800e99:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e9c:	83 ec 04             	sub    $0x4,%esp
  800e9f:	8b 01                	mov    (%ecx),%eax
  800ea1:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800ea8:	50                   	push   %eax
  800ea9:	8d 42 08             	lea    0x8(%edx),%eax
  800eac:	50                   	push   %eax
  800ead:	83 c2 04             	add    $0x4,%edx
  800eb0:	52                   	push   %edx
  800eb1:	e8 c3 fa ff ff       	call   800979 <memmove>
		(*args->argc)--;
  800eb6:	8b 03                	mov    (%ebx),%eax
  800eb8:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800ebb:	8b 43 08             	mov    0x8(%ebx),%eax
  800ebe:	83 c4 10             	add    $0x10,%esp
  800ec1:	80 38 2d             	cmpb   $0x2d,(%eax)
  800ec4:	74 13                	je     800ed9 <argnext+0x78>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800ec6:	8b 43 08             	mov    0x8(%ebx),%eax
  800ec9:	0f b6 10             	movzbl (%eax),%edx
	args->curarg++;
  800ecc:	83 c0 01             	add    $0x1,%eax
  800ecf:	89 43 08             	mov    %eax,0x8(%ebx)
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800ed2:	89 d0                	mov    %edx,%eax
  800ed4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed7:	c9                   	leave  
  800ed8:	c3                   	ret    
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800ed9:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800edd:	75 e7                	jne    800ec6 <argnext+0x65>
	args->curarg = 0;
  800edf:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800ee6:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800eeb:	eb e5                	jmp    800ed2 <argnext+0x71>
		return -1;
  800eed:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800ef2:	eb de                	jmp    800ed2 <argnext+0x71>

00800ef4 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	53                   	push   %ebx
  800ef8:	83 ec 04             	sub    $0x4,%esp
  800efb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800efe:	8b 43 08             	mov    0x8(%ebx),%eax
  800f01:	85 c0                	test   %eax,%eax
  800f03:	74 12                	je     800f17 <argnextvalue+0x23>
		return 0;
	if (*args->curarg) {
  800f05:	80 38 00             	cmpb   $0x0,(%eax)
  800f08:	74 12                	je     800f1c <argnextvalue+0x28>
		args->argvalue = args->curarg;
  800f0a:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800f0d:	c7 43 08 91 25 80 00 	movl   $0x802591,0x8(%ebx)
		(*args->argc)--;
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
  800f14:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  800f17:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1a:	c9                   	leave  
  800f1b:	c3                   	ret    
	} else if (*args->argc > 1) {
  800f1c:	8b 13                	mov    (%ebx),%edx
  800f1e:	83 3a 01             	cmpl   $0x1,(%edx)
  800f21:	7f 10                	jg     800f33 <argnextvalue+0x3f>
		args->argvalue = 0;
  800f23:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800f2a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  800f31:	eb e1                	jmp    800f14 <argnextvalue+0x20>
		args->argvalue = args->argv[1];
  800f33:	8b 43 04             	mov    0x4(%ebx),%eax
  800f36:	8b 48 04             	mov    0x4(%eax),%ecx
  800f39:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800f3c:	83 ec 04             	sub    $0x4,%esp
  800f3f:	8b 12                	mov    (%edx),%edx
  800f41:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800f48:	52                   	push   %edx
  800f49:	8d 50 08             	lea    0x8(%eax),%edx
  800f4c:	52                   	push   %edx
  800f4d:	83 c0 04             	add    $0x4,%eax
  800f50:	50                   	push   %eax
  800f51:	e8 23 fa ff ff       	call   800979 <memmove>
		(*args->argc)--;
  800f56:	8b 03                	mov    (%ebx),%eax
  800f58:	83 28 01             	subl   $0x1,(%eax)
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	eb b4                	jmp    800f14 <argnextvalue+0x20>

00800f60 <argvalue>:
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	83 ec 08             	sub    $0x8,%esp
  800f66:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f69:	8b 42 0c             	mov    0xc(%edx),%eax
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	74 02                	je     800f72 <argvalue+0x12>
}
  800f70:	c9                   	leave  
  800f71:	c3                   	ret    
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f72:	83 ec 0c             	sub    $0xc,%esp
  800f75:	52                   	push   %edx
  800f76:	e8 79 ff ff ff       	call   800ef4 <argnextvalue>
  800f7b:	83 c4 10             	add    $0x10,%esp
  800f7e:	eb f0                	jmp    800f70 <argvalue+0x10>

00800f80 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f83:	8b 45 08             	mov    0x8(%ebp),%eax
  800f86:	05 00 00 00 30       	add    $0x30000000,%eax
  800f8b:	c1 e8 0c             	shr    $0xc,%eax
}
  800f8e:	5d                   	pop    %ebp
  800f8f:	c3                   	ret    

00800f90 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f90:	55                   	push   %ebp
  800f91:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f93:	8b 45 08             	mov    0x8(%ebp),%eax
  800f96:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800f9b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800fa0:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800fa5:	5d                   	pop    %ebp
  800fa6:	c3                   	ret    

00800fa7 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800faf:	89 c2                	mov    %eax,%edx
  800fb1:	c1 ea 16             	shr    $0x16,%edx
  800fb4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fbb:	f6 c2 01             	test   $0x1,%dl
  800fbe:	74 29                	je     800fe9 <fd_alloc+0x42>
  800fc0:	89 c2                	mov    %eax,%edx
  800fc2:	c1 ea 0c             	shr    $0xc,%edx
  800fc5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fcc:	f6 c2 01             	test   $0x1,%dl
  800fcf:	74 18                	je     800fe9 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800fd1:	05 00 10 00 00       	add    $0x1000,%eax
  800fd6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fdb:	75 d2                	jne    800faf <fd_alloc+0x8>
  800fdd:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800fe2:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800fe7:	eb 05                	jmp    800fee <fd_alloc+0x47>
			return 0;
  800fe9:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800fee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff1:	89 02                	mov    %eax,(%edx)
}
  800ff3:	89 c8                	mov    %ecx,%eax
  800ff5:	5d                   	pop    %ebp
  800ff6:	c3                   	ret    

00800ff7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ffd:	83 f8 1f             	cmp    $0x1f,%eax
  801000:	77 30                	ja     801032 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801002:	c1 e0 0c             	shl    $0xc,%eax
  801005:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80100a:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801010:	f6 c2 01             	test   $0x1,%dl
  801013:	74 24                	je     801039 <fd_lookup+0x42>
  801015:	89 c2                	mov    %eax,%edx
  801017:	c1 ea 0c             	shr    $0xc,%edx
  80101a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801021:	f6 c2 01             	test   $0x1,%dl
  801024:	74 1a                	je     801040 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801026:	8b 55 0c             	mov    0xc(%ebp),%edx
  801029:	89 02                	mov    %eax,(%edx)
	return 0;
  80102b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801030:	5d                   	pop    %ebp
  801031:	c3                   	ret    
		return -E_INVAL;
  801032:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801037:	eb f7                	jmp    801030 <fd_lookup+0x39>
		return -E_INVAL;
  801039:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80103e:	eb f0                	jmp    801030 <fd_lookup+0x39>
  801040:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801045:	eb e9                	jmp    801030 <fd_lookup+0x39>

00801047 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801047:	55                   	push   %ebp
  801048:	89 e5                	mov    %esp,%ebp
  80104a:	53                   	push   %ebx
  80104b:	83 ec 04             	sub    $0x4,%esp
  80104e:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801051:	b8 00 00 00 00       	mov    $0x0,%eax
  801056:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80105b:	39 13                	cmp    %edx,(%ebx)
  80105d:	74 37                	je     801096 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  80105f:	83 c0 01             	add    $0x1,%eax
  801062:	8b 1c 85 68 29 80 00 	mov    0x802968(,%eax,4),%ebx
  801069:	85 db                	test   %ebx,%ebx
  80106b:	75 ee                	jne    80105b <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80106d:	a1 00 40 80 00       	mov    0x804000,%eax
  801072:	8b 40 58             	mov    0x58(%eax),%eax
  801075:	83 ec 04             	sub    $0x4,%esp
  801078:	52                   	push   %edx
  801079:	50                   	push   %eax
  80107a:	68 ec 28 80 00       	push   $0x8028ec
  80107f:	e8 85 f1 ff ff       	call   800209 <cprintf>
	*dev = 0;
	return -E_INVAL;
  801084:	83 c4 10             	add    $0x10,%esp
  801087:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  80108c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80108f:	89 1a                	mov    %ebx,(%edx)
}
  801091:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801094:	c9                   	leave  
  801095:	c3                   	ret    
			return 0;
  801096:	b8 00 00 00 00       	mov    $0x0,%eax
  80109b:	eb ef                	jmp    80108c <dev_lookup+0x45>

0080109d <fd_close>:
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	57                   	push   %edi
  8010a1:	56                   	push   %esi
  8010a2:	53                   	push   %ebx
  8010a3:	83 ec 24             	sub    $0x24,%esp
  8010a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8010a9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010ac:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010af:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010b0:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8010b6:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010b9:	50                   	push   %eax
  8010ba:	e8 38 ff ff ff       	call   800ff7 <fd_lookup>
  8010bf:	89 c3                	mov    %eax,%ebx
  8010c1:	83 c4 10             	add    $0x10,%esp
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	78 05                	js     8010cd <fd_close+0x30>
	    || fd != fd2)
  8010c8:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8010cb:	74 16                	je     8010e3 <fd_close+0x46>
		return (must_exist ? r : 0);
  8010cd:	89 f8                	mov    %edi,%eax
  8010cf:	84 c0                	test   %al,%al
  8010d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d6:	0f 44 d8             	cmove  %eax,%ebx
}
  8010d9:	89 d8                	mov    %ebx,%eax
  8010db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010de:	5b                   	pop    %ebx
  8010df:	5e                   	pop    %esi
  8010e0:	5f                   	pop    %edi
  8010e1:	5d                   	pop    %ebp
  8010e2:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010e3:	83 ec 08             	sub    $0x8,%esp
  8010e6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8010e9:	50                   	push   %eax
  8010ea:	ff 36                	push   (%esi)
  8010ec:	e8 56 ff ff ff       	call   801047 <dev_lookup>
  8010f1:	89 c3                	mov    %eax,%ebx
  8010f3:	83 c4 10             	add    $0x10,%esp
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	78 1a                	js     801114 <fd_close+0x77>
		if (dev->dev_close)
  8010fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010fd:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801100:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801105:	85 c0                	test   %eax,%eax
  801107:	74 0b                	je     801114 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801109:	83 ec 0c             	sub    $0xc,%esp
  80110c:	56                   	push   %esi
  80110d:	ff d0                	call   *%eax
  80110f:	89 c3                	mov    %eax,%ebx
  801111:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801114:	83 ec 08             	sub    $0x8,%esp
  801117:	56                   	push   %esi
  801118:	6a 00                	push   $0x0
  80111a:	e8 45 fb ff ff       	call   800c64 <sys_page_unmap>
	return r;
  80111f:	83 c4 10             	add    $0x10,%esp
  801122:	eb b5                	jmp    8010d9 <fd_close+0x3c>

00801124 <close>:

int
close(int fdnum)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80112a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80112d:	50                   	push   %eax
  80112e:	ff 75 08             	push   0x8(%ebp)
  801131:	e8 c1 fe ff ff       	call   800ff7 <fd_lookup>
  801136:	83 c4 10             	add    $0x10,%esp
  801139:	85 c0                	test   %eax,%eax
  80113b:	79 02                	jns    80113f <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80113d:	c9                   	leave  
  80113e:	c3                   	ret    
		return fd_close(fd, 1);
  80113f:	83 ec 08             	sub    $0x8,%esp
  801142:	6a 01                	push   $0x1
  801144:	ff 75 f4             	push   -0xc(%ebp)
  801147:	e8 51 ff ff ff       	call   80109d <fd_close>
  80114c:	83 c4 10             	add    $0x10,%esp
  80114f:	eb ec                	jmp    80113d <close+0x19>

00801151 <close_all>:

void
close_all(void)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	53                   	push   %ebx
  801155:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801158:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80115d:	83 ec 0c             	sub    $0xc,%esp
  801160:	53                   	push   %ebx
  801161:	e8 be ff ff ff       	call   801124 <close>
	for (i = 0; i < MAXFD; i++)
  801166:	83 c3 01             	add    $0x1,%ebx
  801169:	83 c4 10             	add    $0x10,%esp
  80116c:	83 fb 20             	cmp    $0x20,%ebx
  80116f:	75 ec                	jne    80115d <close_all+0xc>
}
  801171:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801174:	c9                   	leave  
  801175:	c3                   	ret    

00801176 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801176:	55                   	push   %ebp
  801177:	89 e5                	mov    %esp,%ebp
  801179:	57                   	push   %edi
  80117a:	56                   	push   %esi
  80117b:	53                   	push   %ebx
  80117c:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80117f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801182:	50                   	push   %eax
  801183:	ff 75 08             	push   0x8(%ebp)
  801186:	e8 6c fe ff ff       	call   800ff7 <fd_lookup>
  80118b:	89 c3                	mov    %eax,%ebx
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	85 c0                	test   %eax,%eax
  801192:	78 7f                	js     801213 <dup+0x9d>
		return r;
	close(newfdnum);
  801194:	83 ec 0c             	sub    $0xc,%esp
  801197:	ff 75 0c             	push   0xc(%ebp)
  80119a:	e8 85 ff ff ff       	call   801124 <close>

	newfd = INDEX2FD(newfdnum);
  80119f:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011a2:	c1 e6 0c             	shl    $0xc,%esi
  8011a5:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8011ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8011ae:	89 3c 24             	mov    %edi,(%esp)
  8011b1:	e8 da fd ff ff       	call   800f90 <fd2data>
  8011b6:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8011b8:	89 34 24             	mov    %esi,(%esp)
  8011bb:	e8 d0 fd ff ff       	call   800f90 <fd2data>
  8011c0:	83 c4 10             	add    $0x10,%esp
  8011c3:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011c6:	89 d8                	mov    %ebx,%eax
  8011c8:	c1 e8 16             	shr    $0x16,%eax
  8011cb:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011d2:	a8 01                	test   $0x1,%al
  8011d4:	74 11                	je     8011e7 <dup+0x71>
  8011d6:	89 d8                	mov    %ebx,%eax
  8011d8:	c1 e8 0c             	shr    $0xc,%eax
  8011db:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011e2:	f6 c2 01             	test   $0x1,%dl
  8011e5:	75 36                	jne    80121d <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011e7:	89 f8                	mov    %edi,%eax
  8011e9:	c1 e8 0c             	shr    $0xc,%eax
  8011ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011f3:	83 ec 0c             	sub    $0xc,%esp
  8011f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8011fb:	50                   	push   %eax
  8011fc:	56                   	push   %esi
  8011fd:	6a 00                	push   $0x0
  8011ff:	57                   	push   %edi
  801200:	6a 00                	push   $0x0
  801202:	e8 1b fa ff ff       	call   800c22 <sys_page_map>
  801207:	89 c3                	mov    %eax,%ebx
  801209:	83 c4 20             	add    $0x20,%esp
  80120c:	85 c0                	test   %eax,%eax
  80120e:	78 33                	js     801243 <dup+0xcd>
		goto err;

	return newfdnum;
  801210:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801213:	89 d8                	mov    %ebx,%eax
  801215:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801218:	5b                   	pop    %ebx
  801219:	5e                   	pop    %esi
  80121a:	5f                   	pop    %edi
  80121b:	5d                   	pop    %ebp
  80121c:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80121d:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801224:	83 ec 0c             	sub    $0xc,%esp
  801227:	25 07 0e 00 00       	and    $0xe07,%eax
  80122c:	50                   	push   %eax
  80122d:	ff 75 d4             	push   -0x2c(%ebp)
  801230:	6a 00                	push   $0x0
  801232:	53                   	push   %ebx
  801233:	6a 00                	push   $0x0
  801235:	e8 e8 f9 ff ff       	call   800c22 <sys_page_map>
  80123a:	89 c3                	mov    %eax,%ebx
  80123c:	83 c4 20             	add    $0x20,%esp
  80123f:	85 c0                	test   %eax,%eax
  801241:	79 a4                	jns    8011e7 <dup+0x71>
	sys_page_unmap(0, newfd);
  801243:	83 ec 08             	sub    $0x8,%esp
  801246:	56                   	push   %esi
  801247:	6a 00                	push   $0x0
  801249:	e8 16 fa ff ff       	call   800c64 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80124e:	83 c4 08             	add    $0x8,%esp
  801251:	ff 75 d4             	push   -0x2c(%ebp)
  801254:	6a 00                	push   $0x0
  801256:	e8 09 fa ff ff       	call   800c64 <sys_page_unmap>
	return r;
  80125b:	83 c4 10             	add    $0x10,%esp
  80125e:	eb b3                	jmp    801213 <dup+0x9d>

00801260 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801260:	55                   	push   %ebp
  801261:	89 e5                	mov    %esp,%ebp
  801263:	56                   	push   %esi
  801264:	53                   	push   %ebx
  801265:	83 ec 18             	sub    $0x18,%esp
  801268:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80126b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126e:	50                   	push   %eax
  80126f:	56                   	push   %esi
  801270:	e8 82 fd ff ff       	call   800ff7 <fd_lookup>
  801275:	83 c4 10             	add    $0x10,%esp
  801278:	85 c0                	test   %eax,%eax
  80127a:	78 3c                	js     8012b8 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127c:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80127f:	83 ec 08             	sub    $0x8,%esp
  801282:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801285:	50                   	push   %eax
  801286:	ff 33                	push   (%ebx)
  801288:	e8 ba fd ff ff       	call   801047 <dev_lookup>
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	85 c0                	test   %eax,%eax
  801292:	78 24                	js     8012b8 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801294:	8b 43 08             	mov    0x8(%ebx),%eax
  801297:	83 e0 03             	and    $0x3,%eax
  80129a:	83 f8 01             	cmp    $0x1,%eax
  80129d:	74 20                	je     8012bf <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80129f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a2:	8b 40 08             	mov    0x8(%eax),%eax
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	74 37                	je     8012e0 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012a9:	83 ec 04             	sub    $0x4,%esp
  8012ac:	ff 75 10             	push   0x10(%ebp)
  8012af:	ff 75 0c             	push   0xc(%ebp)
  8012b2:	53                   	push   %ebx
  8012b3:	ff d0                	call   *%eax
  8012b5:	83 c4 10             	add    $0x10,%esp
}
  8012b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012bb:	5b                   	pop    %ebx
  8012bc:	5e                   	pop    %esi
  8012bd:	5d                   	pop    %ebp
  8012be:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012bf:	a1 00 40 80 00       	mov    0x804000,%eax
  8012c4:	8b 40 58             	mov    0x58(%eax),%eax
  8012c7:	83 ec 04             	sub    $0x4,%esp
  8012ca:	56                   	push   %esi
  8012cb:	50                   	push   %eax
  8012cc:	68 2d 29 80 00       	push   $0x80292d
  8012d1:	e8 33 ef ff ff       	call   800209 <cprintf>
		return -E_INVAL;
  8012d6:	83 c4 10             	add    $0x10,%esp
  8012d9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012de:	eb d8                	jmp    8012b8 <read+0x58>
		return -E_NOT_SUPP;
  8012e0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012e5:	eb d1                	jmp    8012b8 <read+0x58>

008012e7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	57                   	push   %edi
  8012eb:	56                   	push   %esi
  8012ec:	53                   	push   %ebx
  8012ed:	83 ec 0c             	sub    $0xc,%esp
  8012f0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012f3:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012fb:	eb 02                	jmp    8012ff <readn+0x18>
  8012fd:	01 c3                	add    %eax,%ebx
  8012ff:	39 f3                	cmp    %esi,%ebx
  801301:	73 21                	jae    801324 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801303:	83 ec 04             	sub    $0x4,%esp
  801306:	89 f0                	mov    %esi,%eax
  801308:	29 d8                	sub    %ebx,%eax
  80130a:	50                   	push   %eax
  80130b:	89 d8                	mov    %ebx,%eax
  80130d:	03 45 0c             	add    0xc(%ebp),%eax
  801310:	50                   	push   %eax
  801311:	57                   	push   %edi
  801312:	e8 49 ff ff ff       	call   801260 <read>
		if (m < 0)
  801317:	83 c4 10             	add    $0x10,%esp
  80131a:	85 c0                	test   %eax,%eax
  80131c:	78 04                	js     801322 <readn+0x3b>
			return m;
		if (m == 0)
  80131e:	75 dd                	jne    8012fd <readn+0x16>
  801320:	eb 02                	jmp    801324 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801322:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801324:	89 d8                	mov    %ebx,%eax
  801326:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801329:	5b                   	pop    %ebx
  80132a:	5e                   	pop    %esi
  80132b:	5f                   	pop    %edi
  80132c:	5d                   	pop    %ebp
  80132d:	c3                   	ret    

0080132e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80132e:	55                   	push   %ebp
  80132f:	89 e5                	mov    %esp,%ebp
  801331:	56                   	push   %esi
  801332:	53                   	push   %ebx
  801333:	83 ec 18             	sub    $0x18,%esp
  801336:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801339:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80133c:	50                   	push   %eax
  80133d:	53                   	push   %ebx
  80133e:	e8 b4 fc ff ff       	call   800ff7 <fd_lookup>
  801343:	83 c4 10             	add    $0x10,%esp
  801346:	85 c0                	test   %eax,%eax
  801348:	78 37                	js     801381 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80134d:	83 ec 08             	sub    $0x8,%esp
  801350:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801353:	50                   	push   %eax
  801354:	ff 36                	push   (%esi)
  801356:	e8 ec fc ff ff       	call   801047 <dev_lookup>
  80135b:	83 c4 10             	add    $0x10,%esp
  80135e:	85 c0                	test   %eax,%eax
  801360:	78 1f                	js     801381 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801362:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801366:	74 20                	je     801388 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801368:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136b:	8b 40 0c             	mov    0xc(%eax),%eax
  80136e:	85 c0                	test   %eax,%eax
  801370:	74 37                	je     8013a9 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801372:	83 ec 04             	sub    $0x4,%esp
  801375:	ff 75 10             	push   0x10(%ebp)
  801378:	ff 75 0c             	push   0xc(%ebp)
  80137b:	56                   	push   %esi
  80137c:	ff d0                	call   *%eax
  80137e:	83 c4 10             	add    $0x10,%esp
}
  801381:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801384:	5b                   	pop    %ebx
  801385:	5e                   	pop    %esi
  801386:	5d                   	pop    %ebp
  801387:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801388:	a1 00 40 80 00       	mov    0x804000,%eax
  80138d:	8b 40 58             	mov    0x58(%eax),%eax
  801390:	83 ec 04             	sub    $0x4,%esp
  801393:	53                   	push   %ebx
  801394:	50                   	push   %eax
  801395:	68 49 29 80 00       	push   $0x802949
  80139a:	e8 6a ee ff ff       	call   800209 <cprintf>
		return -E_INVAL;
  80139f:	83 c4 10             	add    $0x10,%esp
  8013a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a7:	eb d8                	jmp    801381 <write+0x53>
		return -E_NOT_SUPP;
  8013a9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013ae:	eb d1                	jmp    801381 <write+0x53>

008013b0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8013b0:	55                   	push   %ebp
  8013b1:	89 e5                	mov    %esp,%ebp
  8013b3:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b9:	50                   	push   %eax
  8013ba:	ff 75 08             	push   0x8(%ebp)
  8013bd:	e8 35 fc ff ff       	call   800ff7 <fd_lookup>
  8013c2:	83 c4 10             	add    $0x10,%esp
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	78 0e                	js     8013d7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8013c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cf:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013d7:	c9                   	leave  
  8013d8:	c3                   	ret    

008013d9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013d9:	55                   	push   %ebp
  8013da:	89 e5                	mov    %esp,%ebp
  8013dc:	56                   	push   %esi
  8013dd:	53                   	push   %ebx
  8013de:	83 ec 18             	sub    $0x18,%esp
  8013e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e7:	50                   	push   %eax
  8013e8:	53                   	push   %ebx
  8013e9:	e8 09 fc ff ff       	call   800ff7 <fd_lookup>
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	78 34                	js     801429 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f5:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8013f8:	83 ec 08             	sub    $0x8,%esp
  8013fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fe:	50                   	push   %eax
  8013ff:	ff 36                	push   (%esi)
  801401:	e8 41 fc ff ff       	call   801047 <dev_lookup>
  801406:	83 c4 10             	add    $0x10,%esp
  801409:	85 c0                	test   %eax,%eax
  80140b:	78 1c                	js     801429 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80140d:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801411:	74 1d                	je     801430 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801413:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801416:	8b 40 18             	mov    0x18(%eax),%eax
  801419:	85 c0                	test   %eax,%eax
  80141b:	74 34                	je     801451 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80141d:	83 ec 08             	sub    $0x8,%esp
  801420:	ff 75 0c             	push   0xc(%ebp)
  801423:	56                   	push   %esi
  801424:	ff d0                	call   *%eax
  801426:	83 c4 10             	add    $0x10,%esp
}
  801429:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142c:	5b                   	pop    %ebx
  80142d:	5e                   	pop    %esi
  80142e:	5d                   	pop    %ebp
  80142f:	c3                   	ret    
			thisenv->env_id, fdnum);
  801430:	a1 00 40 80 00       	mov    0x804000,%eax
  801435:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801438:	83 ec 04             	sub    $0x4,%esp
  80143b:	53                   	push   %ebx
  80143c:	50                   	push   %eax
  80143d:	68 0c 29 80 00       	push   $0x80290c
  801442:	e8 c2 ed ff ff       	call   800209 <cprintf>
		return -E_INVAL;
  801447:	83 c4 10             	add    $0x10,%esp
  80144a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80144f:	eb d8                	jmp    801429 <ftruncate+0x50>
		return -E_NOT_SUPP;
  801451:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801456:	eb d1                	jmp    801429 <ftruncate+0x50>

00801458 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801458:	55                   	push   %ebp
  801459:	89 e5                	mov    %esp,%ebp
  80145b:	56                   	push   %esi
  80145c:	53                   	push   %ebx
  80145d:	83 ec 18             	sub    $0x18,%esp
  801460:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801463:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801466:	50                   	push   %eax
  801467:	ff 75 08             	push   0x8(%ebp)
  80146a:	e8 88 fb ff ff       	call   800ff7 <fd_lookup>
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	85 c0                	test   %eax,%eax
  801474:	78 49                	js     8014bf <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801476:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801479:	83 ec 08             	sub    $0x8,%esp
  80147c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147f:	50                   	push   %eax
  801480:	ff 36                	push   (%esi)
  801482:	e8 c0 fb ff ff       	call   801047 <dev_lookup>
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 31                	js     8014bf <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80148e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801491:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801495:	74 2f                	je     8014c6 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801497:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80149a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8014a1:	00 00 00 
	stat->st_isdir = 0;
  8014a4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014ab:	00 00 00 
	stat->st_dev = dev;
  8014ae:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014b4:	83 ec 08             	sub    $0x8,%esp
  8014b7:	53                   	push   %ebx
  8014b8:	56                   	push   %esi
  8014b9:	ff 50 14             	call   *0x14(%eax)
  8014bc:	83 c4 10             	add    $0x10,%esp
}
  8014bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014c2:	5b                   	pop    %ebx
  8014c3:	5e                   	pop    %esi
  8014c4:	5d                   	pop    %ebp
  8014c5:	c3                   	ret    
		return -E_NOT_SUPP;
  8014c6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014cb:	eb f2                	jmp    8014bf <fstat+0x67>

008014cd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	56                   	push   %esi
  8014d1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014d2:	83 ec 08             	sub    $0x8,%esp
  8014d5:	6a 00                	push   $0x0
  8014d7:	ff 75 08             	push   0x8(%ebp)
  8014da:	e8 e4 01 00 00       	call   8016c3 <open>
  8014df:	89 c3                	mov    %eax,%ebx
  8014e1:	83 c4 10             	add    $0x10,%esp
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	78 1b                	js     801503 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014e8:	83 ec 08             	sub    $0x8,%esp
  8014eb:	ff 75 0c             	push   0xc(%ebp)
  8014ee:	50                   	push   %eax
  8014ef:	e8 64 ff ff ff       	call   801458 <fstat>
  8014f4:	89 c6                	mov    %eax,%esi
	close(fd);
  8014f6:	89 1c 24             	mov    %ebx,(%esp)
  8014f9:	e8 26 fc ff ff       	call   801124 <close>
	return r;
  8014fe:	83 c4 10             	add    $0x10,%esp
  801501:	89 f3                	mov    %esi,%ebx
}
  801503:	89 d8                	mov    %ebx,%eax
  801505:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801508:	5b                   	pop    %ebx
  801509:	5e                   	pop    %esi
  80150a:	5d                   	pop    %ebp
  80150b:	c3                   	ret    

0080150c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	56                   	push   %esi
  801510:	53                   	push   %ebx
  801511:	89 c6                	mov    %eax,%esi
  801513:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801515:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80151c:	74 27                	je     801545 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80151e:	6a 07                	push   $0x7
  801520:	68 00 50 80 00       	push   $0x805000
  801525:	56                   	push   %esi
  801526:	ff 35 00 60 80 00    	push   0x806000
  80152c:	e8 26 0d 00 00       	call   802257 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801531:	83 c4 0c             	add    $0xc,%esp
  801534:	6a 00                	push   $0x0
  801536:	53                   	push   %ebx
  801537:	6a 00                	push   $0x0
  801539:	e8 a9 0c 00 00       	call   8021e7 <ipc_recv>
}
  80153e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801541:	5b                   	pop    %ebx
  801542:	5e                   	pop    %esi
  801543:	5d                   	pop    %ebp
  801544:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801545:	83 ec 0c             	sub    $0xc,%esp
  801548:	6a 01                	push   $0x1
  80154a:	e8 5c 0d 00 00       	call   8022ab <ipc_find_env>
  80154f:	a3 00 60 80 00       	mov    %eax,0x806000
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	eb c5                	jmp    80151e <fsipc+0x12>

00801559 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80155f:	8b 45 08             	mov    0x8(%ebp),%eax
  801562:	8b 40 0c             	mov    0xc(%eax),%eax
  801565:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80156a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80156d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801572:	ba 00 00 00 00       	mov    $0x0,%edx
  801577:	b8 02 00 00 00       	mov    $0x2,%eax
  80157c:	e8 8b ff ff ff       	call   80150c <fsipc>
}
  801581:	c9                   	leave  
  801582:	c3                   	ret    

00801583 <devfile_flush>:
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801589:	8b 45 08             	mov    0x8(%ebp),%eax
  80158c:	8b 40 0c             	mov    0xc(%eax),%eax
  80158f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801594:	ba 00 00 00 00       	mov    $0x0,%edx
  801599:	b8 06 00 00 00       	mov    $0x6,%eax
  80159e:	e8 69 ff ff ff       	call   80150c <fsipc>
}
  8015a3:	c9                   	leave  
  8015a4:	c3                   	ret    

008015a5 <devfile_stat>:
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	53                   	push   %ebx
  8015a9:	83 ec 04             	sub    $0x4,%esp
  8015ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015af:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bf:	b8 05 00 00 00       	mov    $0x5,%eax
  8015c4:	e8 43 ff ff ff       	call   80150c <fsipc>
  8015c9:	85 c0                	test   %eax,%eax
  8015cb:	78 2c                	js     8015f9 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015cd:	83 ec 08             	sub    $0x8,%esp
  8015d0:	68 00 50 80 00       	push   $0x805000
  8015d5:	53                   	push   %ebx
  8015d6:	e8 08 f2 ff ff       	call   8007e3 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015db:	a1 80 50 80 00       	mov    0x805080,%eax
  8015e0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015e6:	a1 84 50 80 00       	mov    0x805084,%eax
  8015eb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015f1:	83 c4 10             	add    $0x10,%esp
  8015f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015fc:	c9                   	leave  
  8015fd:	c3                   	ret    

008015fe <devfile_write>:
{
  8015fe:	55                   	push   %ebp
  8015ff:	89 e5                	mov    %esp,%ebp
  801601:	83 ec 0c             	sub    $0xc,%esp
  801604:	8b 45 10             	mov    0x10(%ebp),%eax
  801607:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80160c:	39 d0                	cmp    %edx,%eax
  80160e:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801611:	8b 55 08             	mov    0x8(%ebp),%edx
  801614:	8b 52 0c             	mov    0xc(%edx),%edx
  801617:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80161d:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801622:	50                   	push   %eax
  801623:	ff 75 0c             	push   0xc(%ebp)
  801626:	68 08 50 80 00       	push   $0x805008
  80162b:	e8 49 f3 ff ff       	call   800979 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801630:	ba 00 00 00 00       	mov    $0x0,%edx
  801635:	b8 04 00 00 00       	mov    $0x4,%eax
  80163a:	e8 cd fe ff ff       	call   80150c <fsipc>
}
  80163f:	c9                   	leave  
  801640:	c3                   	ret    

00801641 <devfile_read>:
{
  801641:	55                   	push   %ebp
  801642:	89 e5                	mov    %esp,%ebp
  801644:	56                   	push   %esi
  801645:	53                   	push   %ebx
  801646:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801649:	8b 45 08             	mov    0x8(%ebp),%eax
  80164c:	8b 40 0c             	mov    0xc(%eax),%eax
  80164f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801654:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80165a:	ba 00 00 00 00       	mov    $0x0,%edx
  80165f:	b8 03 00 00 00       	mov    $0x3,%eax
  801664:	e8 a3 fe ff ff       	call   80150c <fsipc>
  801669:	89 c3                	mov    %eax,%ebx
  80166b:	85 c0                	test   %eax,%eax
  80166d:	78 1f                	js     80168e <devfile_read+0x4d>
	assert(r <= n);
  80166f:	39 f0                	cmp    %esi,%eax
  801671:	77 24                	ja     801697 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801673:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801678:	7f 33                	jg     8016ad <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80167a:	83 ec 04             	sub    $0x4,%esp
  80167d:	50                   	push   %eax
  80167e:	68 00 50 80 00       	push   $0x805000
  801683:	ff 75 0c             	push   0xc(%ebp)
  801686:	e8 ee f2 ff ff       	call   800979 <memmove>
	return r;
  80168b:	83 c4 10             	add    $0x10,%esp
}
  80168e:	89 d8                	mov    %ebx,%eax
  801690:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801693:	5b                   	pop    %ebx
  801694:	5e                   	pop    %esi
  801695:	5d                   	pop    %ebp
  801696:	c3                   	ret    
	assert(r <= n);
  801697:	68 7c 29 80 00       	push   $0x80297c
  80169c:	68 83 29 80 00       	push   $0x802983
  8016a1:	6a 7c                	push   $0x7c
  8016a3:	68 98 29 80 00       	push   $0x802998
  8016a8:	e8 f4 0a 00 00       	call   8021a1 <_panic>
	assert(r <= PGSIZE);
  8016ad:	68 a3 29 80 00       	push   $0x8029a3
  8016b2:	68 83 29 80 00       	push   $0x802983
  8016b7:	6a 7d                	push   $0x7d
  8016b9:	68 98 29 80 00       	push   $0x802998
  8016be:	e8 de 0a 00 00       	call   8021a1 <_panic>

008016c3 <open>:
{
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	56                   	push   %esi
  8016c7:	53                   	push   %ebx
  8016c8:	83 ec 1c             	sub    $0x1c,%esp
  8016cb:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8016ce:	56                   	push   %esi
  8016cf:	e8 d4 f0 ff ff       	call   8007a8 <strlen>
  8016d4:	83 c4 10             	add    $0x10,%esp
  8016d7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016dc:	7f 6c                	jg     80174a <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8016de:	83 ec 0c             	sub    $0xc,%esp
  8016e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e4:	50                   	push   %eax
  8016e5:	e8 bd f8 ff ff       	call   800fa7 <fd_alloc>
  8016ea:	89 c3                	mov    %eax,%ebx
  8016ec:	83 c4 10             	add    $0x10,%esp
  8016ef:	85 c0                	test   %eax,%eax
  8016f1:	78 3c                	js     80172f <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8016f3:	83 ec 08             	sub    $0x8,%esp
  8016f6:	56                   	push   %esi
  8016f7:	68 00 50 80 00       	push   $0x805000
  8016fc:	e8 e2 f0 ff ff       	call   8007e3 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801701:	8b 45 0c             	mov    0xc(%ebp),%eax
  801704:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801709:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80170c:	b8 01 00 00 00       	mov    $0x1,%eax
  801711:	e8 f6 fd ff ff       	call   80150c <fsipc>
  801716:	89 c3                	mov    %eax,%ebx
  801718:	83 c4 10             	add    $0x10,%esp
  80171b:	85 c0                	test   %eax,%eax
  80171d:	78 19                	js     801738 <open+0x75>
	return fd2num(fd);
  80171f:	83 ec 0c             	sub    $0xc,%esp
  801722:	ff 75 f4             	push   -0xc(%ebp)
  801725:	e8 56 f8 ff ff       	call   800f80 <fd2num>
  80172a:	89 c3                	mov    %eax,%ebx
  80172c:	83 c4 10             	add    $0x10,%esp
}
  80172f:	89 d8                	mov    %ebx,%eax
  801731:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801734:	5b                   	pop    %ebx
  801735:	5e                   	pop    %esi
  801736:	5d                   	pop    %ebp
  801737:	c3                   	ret    
		fd_close(fd, 0);
  801738:	83 ec 08             	sub    $0x8,%esp
  80173b:	6a 00                	push   $0x0
  80173d:	ff 75 f4             	push   -0xc(%ebp)
  801740:	e8 58 f9 ff ff       	call   80109d <fd_close>
		return r;
  801745:	83 c4 10             	add    $0x10,%esp
  801748:	eb e5                	jmp    80172f <open+0x6c>
		return -E_BAD_PATH;
  80174a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80174f:	eb de                	jmp    80172f <open+0x6c>

00801751 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801757:	ba 00 00 00 00       	mov    $0x0,%edx
  80175c:	b8 08 00 00 00       	mov    $0x8,%eax
  801761:	e8 a6 fd ff ff       	call   80150c <fsipc>
}
  801766:	c9                   	leave  
  801767:	c3                   	ret    

00801768 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801768:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  80176c:	7f 01                	jg     80176f <writebuf+0x7>
  80176e:	c3                   	ret    
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	53                   	push   %ebx
  801773:	83 ec 08             	sub    $0x8,%esp
  801776:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  801778:	ff 70 04             	push   0x4(%eax)
  80177b:	8d 40 10             	lea    0x10(%eax),%eax
  80177e:	50                   	push   %eax
  80177f:	ff 33                	push   (%ebx)
  801781:	e8 a8 fb ff ff       	call   80132e <write>
		if (result > 0)
  801786:	83 c4 10             	add    $0x10,%esp
  801789:	85 c0                	test   %eax,%eax
  80178b:	7e 03                	jle    801790 <writebuf+0x28>
			b->result += result;
  80178d:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801790:	39 43 04             	cmp    %eax,0x4(%ebx)
  801793:	74 0d                	je     8017a2 <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  801795:	85 c0                	test   %eax,%eax
  801797:	ba 00 00 00 00       	mov    $0x0,%edx
  80179c:	0f 4f c2             	cmovg  %edx,%eax
  80179f:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8017a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a5:	c9                   	leave  
  8017a6:	c3                   	ret    

008017a7 <putch>:

static void
putch(int ch, void *thunk)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	53                   	push   %ebx
  8017ab:	83 ec 04             	sub    $0x4,%esp
  8017ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8017b1:	8b 53 04             	mov    0x4(%ebx),%edx
  8017b4:	8d 42 01             	lea    0x1(%edx),%eax
  8017b7:	89 43 04             	mov    %eax,0x4(%ebx)
  8017ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017bd:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8017c1:	3d 00 01 00 00       	cmp    $0x100,%eax
  8017c6:	74 05                	je     8017cd <putch+0x26>
		writebuf(b);
		b->idx = 0;
	}
}
  8017c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017cb:	c9                   	leave  
  8017cc:	c3                   	ret    
		writebuf(b);
  8017cd:	89 d8                	mov    %ebx,%eax
  8017cf:	e8 94 ff ff ff       	call   801768 <writebuf>
		b->idx = 0;
  8017d4:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  8017db:	eb eb                	jmp    8017c8 <putch+0x21>

008017dd <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8017dd:	55                   	push   %ebp
  8017de:	89 e5                	mov    %esp,%ebp
  8017e0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8017e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e9:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8017ef:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8017f6:	00 00 00 
	b.result = 0;
  8017f9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801800:	00 00 00 
	b.error = 1;
  801803:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  80180a:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80180d:	ff 75 10             	push   0x10(%ebp)
  801810:	ff 75 0c             	push   0xc(%ebp)
  801813:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801819:	50                   	push   %eax
  80181a:	68 a7 17 80 00       	push   $0x8017a7
  80181f:	e8 dc ea ff ff       	call   800300 <vprintfmt>
	if (b.idx > 0)
  801824:	83 c4 10             	add    $0x10,%esp
  801827:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80182e:	7f 11                	jg     801841 <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  801830:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801836:	85 c0                	test   %eax,%eax
  801838:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80183f:	c9                   	leave  
  801840:	c3                   	ret    
		writebuf(&b);
  801841:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801847:	e8 1c ff ff ff       	call   801768 <writebuf>
  80184c:	eb e2                	jmp    801830 <vfprintf+0x53>

0080184e <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801854:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801857:	50                   	push   %eax
  801858:	ff 75 0c             	push   0xc(%ebp)
  80185b:	ff 75 08             	push   0x8(%ebp)
  80185e:	e8 7a ff ff ff       	call   8017dd <vfprintf>
	va_end(ap);

	return cnt;
}
  801863:	c9                   	leave  
  801864:	c3                   	ret    

00801865 <printf>:

int
printf(const char *fmt, ...)
{
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80186b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80186e:	50                   	push   %eax
  80186f:	ff 75 08             	push   0x8(%ebp)
  801872:	6a 01                	push   $0x1
  801874:	e8 64 ff ff ff       	call   8017dd <vfprintf>
	va_end(ap);

	return cnt;
}
  801879:	c9                   	leave  
  80187a:	c3                   	ret    

0080187b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80187b:	55                   	push   %ebp
  80187c:	89 e5                	mov    %esp,%ebp
  80187e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801881:	68 af 29 80 00       	push   $0x8029af
  801886:	ff 75 0c             	push   0xc(%ebp)
  801889:	e8 55 ef ff ff       	call   8007e3 <strcpy>
	return 0;
}
  80188e:	b8 00 00 00 00       	mov    $0x0,%eax
  801893:	c9                   	leave  
  801894:	c3                   	ret    

00801895 <devsock_close>:
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
  801898:	53                   	push   %ebx
  801899:	83 ec 10             	sub    $0x10,%esp
  80189c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80189f:	53                   	push   %ebx
  8018a0:	e8 45 0a 00 00       	call   8022ea <pageref>
  8018a5:	89 c2                	mov    %eax,%edx
  8018a7:	83 c4 10             	add    $0x10,%esp
		return 0;
  8018aa:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8018af:	83 fa 01             	cmp    $0x1,%edx
  8018b2:	74 05                	je     8018b9 <devsock_close+0x24>
}
  8018b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b7:	c9                   	leave  
  8018b8:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8018b9:	83 ec 0c             	sub    $0xc,%esp
  8018bc:	ff 73 0c             	push   0xc(%ebx)
  8018bf:	e8 b7 02 00 00       	call   801b7b <nsipc_close>
  8018c4:	83 c4 10             	add    $0x10,%esp
  8018c7:	eb eb                	jmp    8018b4 <devsock_close+0x1f>

008018c9 <devsock_write>:
{
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
  8018cc:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8018cf:	6a 00                	push   $0x0
  8018d1:	ff 75 10             	push   0x10(%ebp)
  8018d4:	ff 75 0c             	push   0xc(%ebp)
  8018d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018da:	ff 70 0c             	push   0xc(%eax)
  8018dd:	e8 79 03 00 00       	call   801c5b <nsipc_send>
}
  8018e2:	c9                   	leave  
  8018e3:	c3                   	ret    

008018e4 <devsock_read>:
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018ea:	6a 00                	push   $0x0
  8018ec:	ff 75 10             	push   0x10(%ebp)
  8018ef:	ff 75 0c             	push   0xc(%ebp)
  8018f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f5:	ff 70 0c             	push   0xc(%eax)
  8018f8:	e8 ef 02 00 00       	call   801bec <nsipc_recv>
}
  8018fd:	c9                   	leave  
  8018fe:	c3                   	ret    

008018ff <fd2sockid>:
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801905:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801908:	52                   	push   %edx
  801909:	50                   	push   %eax
  80190a:	e8 e8 f6 ff ff       	call   800ff7 <fd_lookup>
  80190f:	83 c4 10             	add    $0x10,%esp
  801912:	85 c0                	test   %eax,%eax
  801914:	78 10                	js     801926 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801916:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801919:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80191f:	39 08                	cmp    %ecx,(%eax)
  801921:	75 05                	jne    801928 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801923:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801926:	c9                   	leave  
  801927:	c3                   	ret    
		return -E_NOT_SUPP;
  801928:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80192d:	eb f7                	jmp    801926 <fd2sockid+0x27>

0080192f <alloc_sockfd>:
{
  80192f:	55                   	push   %ebp
  801930:	89 e5                	mov    %esp,%ebp
  801932:	56                   	push   %esi
  801933:	53                   	push   %ebx
  801934:	83 ec 1c             	sub    $0x1c,%esp
  801937:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801939:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193c:	50                   	push   %eax
  80193d:	e8 65 f6 ff ff       	call   800fa7 <fd_alloc>
  801942:	89 c3                	mov    %eax,%ebx
  801944:	83 c4 10             	add    $0x10,%esp
  801947:	85 c0                	test   %eax,%eax
  801949:	78 43                	js     80198e <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80194b:	83 ec 04             	sub    $0x4,%esp
  80194e:	68 07 04 00 00       	push   $0x407
  801953:	ff 75 f4             	push   -0xc(%ebp)
  801956:	6a 00                	push   $0x0
  801958:	e8 82 f2 ff ff       	call   800bdf <sys_page_alloc>
  80195d:	89 c3                	mov    %eax,%ebx
  80195f:	83 c4 10             	add    $0x10,%esp
  801962:	85 c0                	test   %eax,%eax
  801964:	78 28                	js     80198e <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801966:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801969:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80196f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801971:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801974:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80197b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80197e:	83 ec 0c             	sub    $0xc,%esp
  801981:	50                   	push   %eax
  801982:	e8 f9 f5 ff ff       	call   800f80 <fd2num>
  801987:	89 c3                	mov    %eax,%ebx
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	eb 0c                	jmp    80199a <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  80198e:	83 ec 0c             	sub    $0xc,%esp
  801991:	56                   	push   %esi
  801992:	e8 e4 01 00 00       	call   801b7b <nsipc_close>
		return r;
  801997:	83 c4 10             	add    $0x10,%esp
}
  80199a:	89 d8                	mov    %ebx,%eax
  80199c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199f:	5b                   	pop    %ebx
  8019a0:	5e                   	pop    %esi
  8019a1:	5d                   	pop    %ebp
  8019a2:	c3                   	ret    

008019a3 <accept>:
{
  8019a3:	55                   	push   %ebp
  8019a4:	89 e5                	mov    %esp,%ebp
  8019a6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ac:	e8 4e ff ff ff       	call   8018ff <fd2sockid>
  8019b1:	85 c0                	test   %eax,%eax
  8019b3:	78 1b                	js     8019d0 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019b5:	83 ec 04             	sub    $0x4,%esp
  8019b8:	ff 75 10             	push   0x10(%ebp)
  8019bb:	ff 75 0c             	push   0xc(%ebp)
  8019be:	50                   	push   %eax
  8019bf:	e8 0e 01 00 00       	call   801ad2 <nsipc_accept>
  8019c4:	83 c4 10             	add    $0x10,%esp
  8019c7:	85 c0                	test   %eax,%eax
  8019c9:	78 05                	js     8019d0 <accept+0x2d>
	return alloc_sockfd(r);
  8019cb:	e8 5f ff ff ff       	call   80192f <alloc_sockfd>
}
  8019d0:	c9                   	leave  
  8019d1:	c3                   	ret    

008019d2 <bind>:
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019db:	e8 1f ff ff ff       	call   8018ff <fd2sockid>
  8019e0:	85 c0                	test   %eax,%eax
  8019e2:	78 12                	js     8019f6 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8019e4:	83 ec 04             	sub    $0x4,%esp
  8019e7:	ff 75 10             	push   0x10(%ebp)
  8019ea:	ff 75 0c             	push   0xc(%ebp)
  8019ed:	50                   	push   %eax
  8019ee:	e8 31 01 00 00       	call   801b24 <nsipc_bind>
  8019f3:	83 c4 10             	add    $0x10,%esp
}
  8019f6:	c9                   	leave  
  8019f7:	c3                   	ret    

008019f8 <shutdown>:
{
  8019f8:	55                   	push   %ebp
  8019f9:	89 e5                	mov    %esp,%ebp
  8019fb:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801a01:	e8 f9 fe ff ff       	call   8018ff <fd2sockid>
  801a06:	85 c0                	test   %eax,%eax
  801a08:	78 0f                	js     801a19 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801a0a:	83 ec 08             	sub    $0x8,%esp
  801a0d:	ff 75 0c             	push   0xc(%ebp)
  801a10:	50                   	push   %eax
  801a11:	e8 43 01 00 00       	call   801b59 <nsipc_shutdown>
  801a16:	83 c4 10             	add    $0x10,%esp
}
  801a19:	c9                   	leave  
  801a1a:	c3                   	ret    

00801a1b <connect>:
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a21:	8b 45 08             	mov    0x8(%ebp),%eax
  801a24:	e8 d6 fe ff ff       	call   8018ff <fd2sockid>
  801a29:	85 c0                	test   %eax,%eax
  801a2b:	78 12                	js     801a3f <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801a2d:	83 ec 04             	sub    $0x4,%esp
  801a30:	ff 75 10             	push   0x10(%ebp)
  801a33:	ff 75 0c             	push   0xc(%ebp)
  801a36:	50                   	push   %eax
  801a37:	e8 59 01 00 00       	call   801b95 <nsipc_connect>
  801a3c:	83 c4 10             	add    $0x10,%esp
}
  801a3f:	c9                   	leave  
  801a40:	c3                   	ret    

00801a41 <listen>:
{
  801a41:	55                   	push   %ebp
  801a42:	89 e5                	mov    %esp,%ebp
  801a44:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a47:	8b 45 08             	mov    0x8(%ebp),%eax
  801a4a:	e8 b0 fe ff ff       	call   8018ff <fd2sockid>
  801a4f:	85 c0                	test   %eax,%eax
  801a51:	78 0f                	js     801a62 <listen+0x21>
	return nsipc_listen(r, backlog);
  801a53:	83 ec 08             	sub    $0x8,%esp
  801a56:	ff 75 0c             	push   0xc(%ebp)
  801a59:	50                   	push   %eax
  801a5a:	e8 6b 01 00 00       	call   801bca <nsipc_listen>
  801a5f:	83 c4 10             	add    $0x10,%esp
}
  801a62:	c9                   	leave  
  801a63:	c3                   	ret    

00801a64 <socket>:

int
socket(int domain, int type, int protocol)
{
  801a64:	55                   	push   %ebp
  801a65:	89 e5                	mov    %esp,%ebp
  801a67:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a6a:	ff 75 10             	push   0x10(%ebp)
  801a6d:	ff 75 0c             	push   0xc(%ebp)
  801a70:	ff 75 08             	push   0x8(%ebp)
  801a73:	e8 41 02 00 00       	call   801cb9 <nsipc_socket>
  801a78:	83 c4 10             	add    $0x10,%esp
  801a7b:	85 c0                	test   %eax,%eax
  801a7d:	78 05                	js     801a84 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a7f:	e8 ab fe ff ff       	call   80192f <alloc_sockfd>
}
  801a84:	c9                   	leave  
  801a85:	c3                   	ret    

00801a86 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a86:	55                   	push   %ebp
  801a87:	89 e5                	mov    %esp,%ebp
  801a89:	53                   	push   %ebx
  801a8a:	83 ec 04             	sub    $0x4,%esp
  801a8d:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a8f:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801a96:	74 26                	je     801abe <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a98:	6a 07                	push   $0x7
  801a9a:	68 00 70 80 00       	push   $0x807000
  801a9f:	53                   	push   %ebx
  801aa0:	ff 35 00 80 80 00    	push   0x808000
  801aa6:	e8 ac 07 00 00       	call   802257 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801aab:	83 c4 0c             	add    $0xc,%esp
  801aae:	6a 00                	push   $0x0
  801ab0:	6a 00                	push   $0x0
  801ab2:	6a 00                	push   $0x0
  801ab4:	e8 2e 07 00 00       	call   8021e7 <ipc_recv>
}
  801ab9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801abc:	c9                   	leave  
  801abd:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801abe:	83 ec 0c             	sub    $0xc,%esp
  801ac1:	6a 02                	push   $0x2
  801ac3:	e8 e3 07 00 00       	call   8022ab <ipc_find_env>
  801ac8:	a3 00 80 80 00       	mov    %eax,0x808000
  801acd:	83 c4 10             	add    $0x10,%esp
  801ad0:	eb c6                	jmp    801a98 <nsipc+0x12>

00801ad2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ad2:	55                   	push   %ebp
  801ad3:	89 e5                	mov    %esp,%ebp
  801ad5:	56                   	push   %esi
  801ad6:	53                   	push   %ebx
  801ad7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ada:	8b 45 08             	mov    0x8(%ebp),%eax
  801add:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ae2:	8b 06                	mov    (%esi),%eax
  801ae4:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ae9:	b8 01 00 00 00       	mov    $0x1,%eax
  801aee:	e8 93 ff ff ff       	call   801a86 <nsipc>
  801af3:	89 c3                	mov    %eax,%ebx
  801af5:	85 c0                	test   %eax,%eax
  801af7:	79 09                	jns    801b02 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801af9:	89 d8                	mov    %ebx,%eax
  801afb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801afe:	5b                   	pop    %ebx
  801aff:	5e                   	pop    %esi
  801b00:	5d                   	pop    %ebp
  801b01:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b02:	83 ec 04             	sub    $0x4,%esp
  801b05:	ff 35 10 70 80 00    	push   0x807010
  801b0b:	68 00 70 80 00       	push   $0x807000
  801b10:	ff 75 0c             	push   0xc(%ebp)
  801b13:	e8 61 ee ff ff       	call   800979 <memmove>
		*addrlen = ret->ret_addrlen;
  801b18:	a1 10 70 80 00       	mov    0x807010,%eax
  801b1d:	89 06                	mov    %eax,(%esi)
  801b1f:	83 c4 10             	add    $0x10,%esp
	return r;
  801b22:	eb d5                	jmp    801af9 <nsipc_accept+0x27>

00801b24 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	53                   	push   %ebx
  801b28:	83 ec 08             	sub    $0x8,%esp
  801b2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b31:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b36:	53                   	push   %ebx
  801b37:	ff 75 0c             	push   0xc(%ebp)
  801b3a:	68 04 70 80 00       	push   $0x807004
  801b3f:	e8 35 ee ff ff       	call   800979 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b44:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801b4a:	b8 02 00 00 00       	mov    $0x2,%eax
  801b4f:	e8 32 ff ff ff       	call   801a86 <nsipc>
}
  801b54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b57:	c9                   	leave  
  801b58:	c3                   	ret    

00801b59 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b62:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801b67:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6a:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801b6f:	b8 03 00 00 00       	mov    $0x3,%eax
  801b74:	e8 0d ff ff ff       	call   801a86 <nsipc>
}
  801b79:	c9                   	leave  
  801b7a:	c3                   	ret    

00801b7b <nsipc_close>:

int
nsipc_close(int s)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b81:	8b 45 08             	mov    0x8(%ebp),%eax
  801b84:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801b89:	b8 04 00 00 00       	mov    $0x4,%eax
  801b8e:	e8 f3 fe ff ff       	call   801a86 <nsipc>
}
  801b93:	c9                   	leave  
  801b94:	c3                   	ret    

00801b95 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	53                   	push   %ebx
  801b99:	83 ec 08             	sub    $0x8,%esp
  801b9c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b9f:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba2:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ba7:	53                   	push   %ebx
  801ba8:	ff 75 0c             	push   0xc(%ebp)
  801bab:	68 04 70 80 00       	push   $0x807004
  801bb0:	e8 c4 ed ff ff       	call   800979 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801bb5:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801bbb:	b8 05 00 00 00       	mov    $0x5,%eax
  801bc0:	e8 c1 fe ff ff       	call   801a86 <nsipc>
}
  801bc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc8:	c9                   	leave  
  801bc9:	c3                   	ret    

00801bca <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801bca:	55                   	push   %ebp
  801bcb:	89 e5                	mov    %esp,%ebp
  801bcd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801bd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd3:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801bd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bdb:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801be0:	b8 06 00 00 00       	mov    $0x6,%eax
  801be5:	e8 9c fe ff ff       	call   801a86 <nsipc>
}
  801bea:	c9                   	leave  
  801beb:	c3                   	ret    

00801bec <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801bec:	55                   	push   %ebp
  801bed:	89 e5                	mov    %esp,%ebp
  801bef:	56                   	push   %esi
  801bf0:	53                   	push   %ebx
  801bf1:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801bf4:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801bfc:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801c02:	8b 45 14             	mov    0x14(%ebp),%eax
  801c05:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c0a:	b8 07 00 00 00       	mov    $0x7,%eax
  801c0f:	e8 72 fe ff ff       	call   801a86 <nsipc>
  801c14:	89 c3                	mov    %eax,%ebx
  801c16:	85 c0                	test   %eax,%eax
  801c18:	78 22                	js     801c3c <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801c1a:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801c1f:	39 c6                	cmp    %eax,%esi
  801c21:	0f 4e c6             	cmovle %esi,%eax
  801c24:	39 c3                	cmp    %eax,%ebx
  801c26:	7f 1d                	jg     801c45 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c28:	83 ec 04             	sub    $0x4,%esp
  801c2b:	53                   	push   %ebx
  801c2c:	68 00 70 80 00       	push   $0x807000
  801c31:	ff 75 0c             	push   0xc(%ebp)
  801c34:	e8 40 ed ff ff       	call   800979 <memmove>
  801c39:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c3c:	89 d8                	mov    %ebx,%eax
  801c3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c41:	5b                   	pop    %ebx
  801c42:	5e                   	pop    %esi
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801c45:	68 bb 29 80 00       	push   $0x8029bb
  801c4a:	68 83 29 80 00       	push   $0x802983
  801c4f:	6a 62                	push   $0x62
  801c51:	68 d0 29 80 00       	push   $0x8029d0
  801c56:	e8 46 05 00 00       	call   8021a1 <_panic>

00801c5b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	53                   	push   %ebx
  801c5f:	83 ec 04             	sub    $0x4,%esp
  801c62:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c65:	8b 45 08             	mov    0x8(%ebp),%eax
  801c68:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801c6d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c73:	7f 2e                	jg     801ca3 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c75:	83 ec 04             	sub    $0x4,%esp
  801c78:	53                   	push   %ebx
  801c79:	ff 75 0c             	push   0xc(%ebp)
  801c7c:	68 0c 70 80 00       	push   $0x80700c
  801c81:	e8 f3 ec ff ff       	call   800979 <memmove>
	nsipcbuf.send.req_size = size;
  801c86:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801c8c:	8b 45 14             	mov    0x14(%ebp),%eax
  801c8f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801c94:	b8 08 00 00 00       	mov    $0x8,%eax
  801c99:	e8 e8 fd ff ff       	call   801a86 <nsipc>
}
  801c9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ca1:	c9                   	leave  
  801ca2:	c3                   	ret    
	assert(size < 1600);
  801ca3:	68 dc 29 80 00       	push   $0x8029dc
  801ca8:	68 83 29 80 00       	push   $0x802983
  801cad:	6a 6d                	push   $0x6d
  801caf:	68 d0 29 80 00       	push   $0x8029d0
  801cb4:	e8 e8 04 00 00       	call   8021a1 <_panic>

00801cb9 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801cb9:	55                   	push   %ebp
  801cba:	89 e5                	mov    %esp,%ebp
  801cbc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801cc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cca:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801ccf:	8b 45 10             	mov    0x10(%ebp),%eax
  801cd2:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801cd7:	b8 09 00 00 00       	mov    $0x9,%eax
  801cdc:	e8 a5 fd ff ff       	call   801a86 <nsipc>
}
  801ce1:	c9                   	leave  
  801ce2:	c3                   	ret    

00801ce3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
  801ce6:	56                   	push   %esi
  801ce7:	53                   	push   %ebx
  801ce8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ceb:	83 ec 0c             	sub    $0xc,%esp
  801cee:	ff 75 08             	push   0x8(%ebp)
  801cf1:	e8 9a f2 ff ff       	call   800f90 <fd2data>
  801cf6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cf8:	83 c4 08             	add    $0x8,%esp
  801cfb:	68 e8 29 80 00       	push   $0x8029e8
  801d00:	53                   	push   %ebx
  801d01:	e8 dd ea ff ff       	call   8007e3 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d06:	8b 46 04             	mov    0x4(%esi),%eax
  801d09:	2b 06                	sub    (%esi),%eax
  801d0b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d11:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d18:	00 00 00 
	stat->st_dev = &devpipe;
  801d1b:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801d22:	30 80 00 
	return 0;
}
  801d25:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5d                   	pop    %ebp
  801d30:	c3                   	ret    

00801d31 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d31:	55                   	push   %ebp
  801d32:	89 e5                	mov    %esp,%ebp
  801d34:	53                   	push   %ebx
  801d35:	83 ec 0c             	sub    $0xc,%esp
  801d38:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d3b:	53                   	push   %ebx
  801d3c:	6a 00                	push   $0x0
  801d3e:	e8 21 ef ff ff       	call   800c64 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d43:	89 1c 24             	mov    %ebx,(%esp)
  801d46:	e8 45 f2 ff ff       	call   800f90 <fd2data>
  801d4b:	83 c4 08             	add    $0x8,%esp
  801d4e:	50                   	push   %eax
  801d4f:	6a 00                	push   $0x0
  801d51:	e8 0e ef ff ff       	call   800c64 <sys_page_unmap>
}
  801d56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d59:	c9                   	leave  
  801d5a:	c3                   	ret    

00801d5b <_pipeisclosed>:
{
  801d5b:	55                   	push   %ebp
  801d5c:	89 e5                	mov    %esp,%ebp
  801d5e:	57                   	push   %edi
  801d5f:	56                   	push   %esi
  801d60:	53                   	push   %ebx
  801d61:	83 ec 1c             	sub    $0x1c,%esp
  801d64:	89 c7                	mov    %eax,%edi
  801d66:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801d68:	a1 00 40 80 00       	mov    0x804000,%eax
  801d6d:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d70:	83 ec 0c             	sub    $0xc,%esp
  801d73:	57                   	push   %edi
  801d74:	e8 71 05 00 00       	call   8022ea <pageref>
  801d79:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d7c:	89 34 24             	mov    %esi,(%esp)
  801d7f:	e8 66 05 00 00       	call   8022ea <pageref>
		nn = thisenv->env_runs;
  801d84:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801d8a:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801d8d:	83 c4 10             	add    $0x10,%esp
  801d90:	39 cb                	cmp    %ecx,%ebx
  801d92:	74 1b                	je     801daf <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801d94:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d97:	75 cf                	jne    801d68 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d99:	8b 42 68             	mov    0x68(%edx),%eax
  801d9c:	6a 01                	push   $0x1
  801d9e:	50                   	push   %eax
  801d9f:	53                   	push   %ebx
  801da0:	68 ef 29 80 00       	push   $0x8029ef
  801da5:	e8 5f e4 ff ff       	call   800209 <cprintf>
  801daa:	83 c4 10             	add    $0x10,%esp
  801dad:	eb b9                	jmp    801d68 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801daf:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801db2:	0f 94 c0             	sete   %al
  801db5:	0f b6 c0             	movzbl %al,%eax
}
  801db8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dbb:	5b                   	pop    %ebx
  801dbc:	5e                   	pop    %esi
  801dbd:	5f                   	pop    %edi
  801dbe:	5d                   	pop    %ebp
  801dbf:	c3                   	ret    

00801dc0 <devpipe_write>:
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	57                   	push   %edi
  801dc4:	56                   	push   %esi
  801dc5:	53                   	push   %ebx
  801dc6:	83 ec 28             	sub    $0x28,%esp
  801dc9:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801dcc:	56                   	push   %esi
  801dcd:	e8 be f1 ff ff       	call   800f90 <fd2data>
  801dd2:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801dd4:	83 c4 10             	add    $0x10,%esp
  801dd7:	bf 00 00 00 00       	mov    $0x0,%edi
  801ddc:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ddf:	75 09                	jne    801dea <devpipe_write+0x2a>
	return i;
  801de1:	89 f8                	mov    %edi,%eax
  801de3:	eb 23                	jmp    801e08 <devpipe_write+0x48>
			sys_yield();
  801de5:	e8 d6 ed ff ff       	call   800bc0 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801dea:	8b 43 04             	mov    0x4(%ebx),%eax
  801ded:	8b 0b                	mov    (%ebx),%ecx
  801def:	8d 51 20             	lea    0x20(%ecx),%edx
  801df2:	39 d0                	cmp    %edx,%eax
  801df4:	72 1a                	jb     801e10 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801df6:	89 da                	mov    %ebx,%edx
  801df8:	89 f0                	mov    %esi,%eax
  801dfa:	e8 5c ff ff ff       	call   801d5b <_pipeisclosed>
  801dff:	85 c0                	test   %eax,%eax
  801e01:	74 e2                	je     801de5 <devpipe_write+0x25>
				return 0;
  801e03:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e0b:	5b                   	pop    %ebx
  801e0c:	5e                   	pop    %esi
  801e0d:	5f                   	pop    %edi
  801e0e:	5d                   	pop    %ebp
  801e0f:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e13:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e17:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e1a:	89 c2                	mov    %eax,%edx
  801e1c:	c1 fa 1f             	sar    $0x1f,%edx
  801e1f:	89 d1                	mov    %edx,%ecx
  801e21:	c1 e9 1b             	shr    $0x1b,%ecx
  801e24:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e27:	83 e2 1f             	and    $0x1f,%edx
  801e2a:	29 ca                	sub    %ecx,%edx
  801e2c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e30:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e34:	83 c0 01             	add    $0x1,%eax
  801e37:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801e3a:	83 c7 01             	add    $0x1,%edi
  801e3d:	eb 9d                	jmp    801ddc <devpipe_write+0x1c>

00801e3f <devpipe_read>:
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
  801e42:	57                   	push   %edi
  801e43:	56                   	push   %esi
  801e44:	53                   	push   %ebx
  801e45:	83 ec 18             	sub    $0x18,%esp
  801e48:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801e4b:	57                   	push   %edi
  801e4c:	e8 3f f1 ff ff       	call   800f90 <fd2data>
  801e51:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e53:	83 c4 10             	add    $0x10,%esp
  801e56:	be 00 00 00 00       	mov    $0x0,%esi
  801e5b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e5e:	75 13                	jne    801e73 <devpipe_read+0x34>
	return i;
  801e60:	89 f0                	mov    %esi,%eax
  801e62:	eb 02                	jmp    801e66 <devpipe_read+0x27>
				return i;
  801e64:	89 f0                	mov    %esi,%eax
}
  801e66:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e69:	5b                   	pop    %ebx
  801e6a:	5e                   	pop    %esi
  801e6b:	5f                   	pop    %edi
  801e6c:	5d                   	pop    %ebp
  801e6d:	c3                   	ret    
			sys_yield();
  801e6e:	e8 4d ed ff ff       	call   800bc0 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801e73:	8b 03                	mov    (%ebx),%eax
  801e75:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e78:	75 18                	jne    801e92 <devpipe_read+0x53>
			if (i > 0)
  801e7a:	85 f6                	test   %esi,%esi
  801e7c:	75 e6                	jne    801e64 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801e7e:	89 da                	mov    %ebx,%edx
  801e80:	89 f8                	mov    %edi,%eax
  801e82:	e8 d4 fe ff ff       	call   801d5b <_pipeisclosed>
  801e87:	85 c0                	test   %eax,%eax
  801e89:	74 e3                	je     801e6e <devpipe_read+0x2f>
				return 0;
  801e8b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e90:	eb d4                	jmp    801e66 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e92:	99                   	cltd   
  801e93:	c1 ea 1b             	shr    $0x1b,%edx
  801e96:	01 d0                	add    %edx,%eax
  801e98:	83 e0 1f             	and    $0x1f,%eax
  801e9b:	29 d0                	sub    %edx,%eax
  801e9d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801ea2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ea5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ea8:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801eab:	83 c6 01             	add    $0x1,%esi
  801eae:	eb ab                	jmp    801e5b <devpipe_read+0x1c>

00801eb0 <pipe>:
{
  801eb0:	55                   	push   %ebp
  801eb1:	89 e5                	mov    %esp,%ebp
  801eb3:	56                   	push   %esi
  801eb4:	53                   	push   %ebx
  801eb5:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801eb8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ebb:	50                   	push   %eax
  801ebc:	e8 e6 f0 ff ff       	call   800fa7 <fd_alloc>
  801ec1:	89 c3                	mov    %eax,%ebx
  801ec3:	83 c4 10             	add    $0x10,%esp
  801ec6:	85 c0                	test   %eax,%eax
  801ec8:	0f 88 23 01 00 00    	js     801ff1 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ece:	83 ec 04             	sub    $0x4,%esp
  801ed1:	68 07 04 00 00       	push   $0x407
  801ed6:	ff 75 f4             	push   -0xc(%ebp)
  801ed9:	6a 00                	push   $0x0
  801edb:	e8 ff ec ff ff       	call   800bdf <sys_page_alloc>
  801ee0:	89 c3                	mov    %eax,%ebx
  801ee2:	83 c4 10             	add    $0x10,%esp
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	0f 88 04 01 00 00    	js     801ff1 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801eed:	83 ec 0c             	sub    $0xc,%esp
  801ef0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ef3:	50                   	push   %eax
  801ef4:	e8 ae f0 ff ff       	call   800fa7 <fd_alloc>
  801ef9:	89 c3                	mov    %eax,%ebx
  801efb:	83 c4 10             	add    $0x10,%esp
  801efe:	85 c0                	test   %eax,%eax
  801f00:	0f 88 db 00 00 00    	js     801fe1 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f06:	83 ec 04             	sub    $0x4,%esp
  801f09:	68 07 04 00 00       	push   $0x407
  801f0e:	ff 75 f0             	push   -0x10(%ebp)
  801f11:	6a 00                	push   $0x0
  801f13:	e8 c7 ec ff ff       	call   800bdf <sys_page_alloc>
  801f18:	89 c3                	mov    %eax,%ebx
  801f1a:	83 c4 10             	add    $0x10,%esp
  801f1d:	85 c0                	test   %eax,%eax
  801f1f:	0f 88 bc 00 00 00    	js     801fe1 <pipe+0x131>
	va = fd2data(fd0);
  801f25:	83 ec 0c             	sub    $0xc,%esp
  801f28:	ff 75 f4             	push   -0xc(%ebp)
  801f2b:	e8 60 f0 ff ff       	call   800f90 <fd2data>
  801f30:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f32:	83 c4 0c             	add    $0xc,%esp
  801f35:	68 07 04 00 00       	push   $0x407
  801f3a:	50                   	push   %eax
  801f3b:	6a 00                	push   $0x0
  801f3d:	e8 9d ec ff ff       	call   800bdf <sys_page_alloc>
  801f42:	89 c3                	mov    %eax,%ebx
  801f44:	83 c4 10             	add    $0x10,%esp
  801f47:	85 c0                	test   %eax,%eax
  801f49:	0f 88 82 00 00 00    	js     801fd1 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f4f:	83 ec 0c             	sub    $0xc,%esp
  801f52:	ff 75 f0             	push   -0x10(%ebp)
  801f55:	e8 36 f0 ff ff       	call   800f90 <fd2data>
  801f5a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f61:	50                   	push   %eax
  801f62:	6a 00                	push   $0x0
  801f64:	56                   	push   %esi
  801f65:	6a 00                	push   $0x0
  801f67:	e8 b6 ec ff ff       	call   800c22 <sys_page_map>
  801f6c:	89 c3                	mov    %eax,%ebx
  801f6e:	83 c4 20             	add    $0x20,%esp
  801f71:	85 c0                	test   %eax,%eax
  801f73:	78 4e                	js     801fc3 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801f75:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801f7a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f7d:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801f7f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f82:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801f89:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f8c:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801f8e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f91:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f98:	83 ec 0c             	sub    $0xc,%esp
  801f9b:	ff 75 f4             	push   -0xc(%ebp)
  801f9e:	e8 dd ef ff ff       	call   800f80 <fd2num>
  801fa3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fa6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fa8:	83 c4 04             	add    $0x4,%esp
  801fab:	ff 75 f0             	push   -0x10(%ebp)
  801fae:	e8 cd ef ff ff       	call   800f80 <fd2num>
  801fb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fb6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801fb9:	83 c4 10             	add    $0x10,%esp
  801fbc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fc1:	eb 2e                	jmp    801ff1 <pipe+0x141>
	sys_page_unmap(0, va);
  801fc3:	83 ec 08             	sub    $0x8,%esp
  801fc6:	56                   	push   %esi
  801fc7:	6a 00                	push   $0x0
  801fc9:	e8 96 ec ff ff       	call   800c64 <sys_page_unmap>
  801fce:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801fd1:	83 ec 08             	sub    $0x8,%esp
  801fd4:	ff 75 f0             	push   -0x10(%ebp)
  801fd7:	6a 00                	push   $0x0
  801fd9:	e8 86 ec ff ff       	call   800c64 <sys_page_unmap>
  801fde:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801fe1:	83 ec 08             	sub    $0x8,%esp
  801fe4:	ff 75 f4             	push   -0xc(%ebp)
  801fe7:	6a 00                	push   $0x0
  801fe9:	e8 76 ec ff ff       	call   800c64 <sys_page_unmap>
  801fee:	83 c4 10             	add    $0x10,%esp
}
  801ff1:	89 d8                	mov    %ebx,%eax
  801ff3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ff6:	5b                   	pop    %ebx
  801ff7:	5e                   	pop    %esi
  801ff8:	5d                   	pop    %ebp
  801ff9:	c3                   	ret    

00801ffa <pipeisclosed>:
{
  801ffa:	55                   	push   %ebp
  801ffb:	89 e5                	mov    %esp,%ebp
  801ffd:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802000:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802003:	50                   	push   %eax
  802004:	ff 75 08             	push   0x8(%ebp)
  802007:	e8 eb ef ff ff       	call   800ff7 <fd_lookup>
  80200c:	83 c4 10             	add    $0x10,%esp
  80200f:	85 c0                	test   %eax,%eax
  802011:	78 18                	js     80202b <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802013:	83 ec 0c             	sub    $0xc,%esp
  802016:	ff 75 f4             	push   -0xc(%ebp)
  802019:	e8 72 ef ff ff       	call   800f90 <fd2data>
  80201e:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802020:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802023:	e8 33 fd ff ff       	call   801d5b <_pipeisclosed>
  802028:	83 c4 10             	add    $0x10,%esp
}
  80202b:	c9                   	leave  
  80202c:	c3                   	ret    

0080202d <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80202d:	b8 00 00 00 00       	mov    $0x0,%eax
  802032:	c3                   	ret    

00802033 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802033:	55                   	push   %ebp
  802034:	89 e5                	mov    %esp,%ebp
  802036:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802039:	68 07 2a 80 00       	push   $0x802a07
  80203e:	ff 75 0c             	push   0xc(%ebp)
  802041:	e8 9d e7 ff ff       	call   8007e3 <strcpy>
	return 0;
}
  802046:	b8 00 00 00 00       	mov    $0x0,%eax
  80204b:	c9                   	leave  
  80204c:	c3                   	ret    

0080204d <devcons_write>:
{
  80204d:	55                   	push   %ebp
  80204e:	89 e5                	mov    %esp,%ebp
  802050:	57                   	push   %edi
  802051:	56                   	push   %esi
  802052:	53                   	push   %ebx
  802053:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802059:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80205e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802064:	eb 2e                	jmp    802094 <devcons_write+0x47>
		m = n - tot;
  802066:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802069:	29 f3                	sub    %esi,%ebx
  80206b:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802070:	39 c3                	cmp    %eax,%ebx
  802072:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802075:	83 ec 04             	sub    $0x4,%esp
  802078:	53                   	push   %ebx
  802079:	89 f0                	mov    %esi,%eax
  80207b:	03 45 0c             	add    0xc(%ebp),%eax
  80207e:	50                   	push   %eax
  80207f:	57                   	push   %edi
  802080:	e8 f4 e8 ff ff       	call   800979 <memmove>
		sys_cputs(buf, m);
  802085:	83 c4 08             	add    $0x8,%esp
  802088:	53                   	push   %ebx
  802089:	57                   	push   %edi
  80208a:	e8 94 ea ff ff       	call   800b23 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80208f:	01 de                	add    %ebx,%esi
  802091:	83 c4 10             	add    $0x10,%esp
  802094:	3b 75 10             	cmp    0x10(%ebp),%esi
  802097:	72 cd                	jb     802066 <devcons_write+0x19>
}
  802099:	89 f0                	mov    %esi,%eax
  80209b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80209e:	5b                   	pop    %ebx
  80209f:	5e                   	pop    %esi
  8020a0:	5f                   	pop    %edi
  8020a1:	5d                   	pop    %ebp
  8020a2:	c3                   	ret    

008020a3 <devcons_read>:
{
  8020a3:	55                   	push   %ebp
  8020a4:	89 e5                	mov    %esp,%ebp
  8020a6:	83 ec 08             	sub    $0x8,%esp
  8020a9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8020ae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020b2:	75 07                	jne    8020bb <devcons_read+0x18>
  8020b4:	eb 1f                	jmp    8020d5 <devcons_read+0x32>
		sys_yield();
  8020b6:	e8 05 eb ff ff       	call   800bc0 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8020bb:	e8 81 ea ff ff       	call   800b41 <sys_cgetc>
  8020c0:	85 c0                	test   %eax,%eax
  8020c2:	74 f2                	je     8020b6 <devcons_read+0x13>
	if (c < 0)
  8020c4:	78 0f                	js     8020d5 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8020c6:	83 f8 04             	cmp    $0x4,%eax
  8020c9:	74 0c                	je     8020d7 <devcons_read+0x34>
	*(char*)vbuf = c;
  8020cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020ce:	88 02                	mov    %al,(%edx)
	return 1;
  8020d0:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8020d5:	c9                   	leave  
  8020d6:	c3                   	ret    
		return 0;
  8020d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8020dc:	eb f7                	jmp    8020d5 <devcons_read+0x32>

008020de <cputchar>:
{
  8020de:	55                   	push   %ebp
  8020df:	89 e5                	mov    %esp,%ebp
  8020e1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e7:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8020ea:	6a 01                	push   $0x1
  8020ec:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020ef:	50                   	push   %eax
  8020f0:	e8 2e ea ff ff       	call   800b23 <sys_cputs>
}
  8020f5:	83 c4 10             	add    $0x10,%esp
  8020f8:	c9                   	leave  
  8020f9:	c3                   	ret    

008020fa <getchar>:
{
  8020fa:	55                   	push   %ebp
  8020fb:	89 e5                	mov    %esp,%ebp
  8020fd:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802100:	6a 01                	push   $0x1
  802102:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802105:	50                   	push   %eax
  802106:	6a 00                	push   $0x0
  802108:	e8 53 f1 ff ff       	call   801260 <read>
	if (r < 0)
  80210d:	83 c4 10             	add    $0x10,%esp
  802110:	85 c0                	test   %eax,%eax
  802112:	78 06                	js     80211a <getchar+0x20>
	if (r < 1)
  802114:	74 06                	je     80211c <getchar+0x22>
	return c;
  802116:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80211a:	c9                   	leave  
  80211b:	c3                   	ret    
		return -E_EOF;
  80211c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802121:	eb f7                	jmp    80211a <getchar+0x20>

00802123 <iscons>:
{
  802123:	55                   	push   %ebp
  802124:	89 e5                	mov    %esp,%ebp
  802126:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802129:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80212c:	50                   	push   %eax
  80212d:	ff 75 08             	push   0x8(%ebp)
  802130:	e8 c2 ee ff ff       	call   800ff7 <fd_lookup>
  802135:	83 c4 10             	add    $0x10,%esp
  802138:	85 c0                	test   %eax,%eax
  80213a:	78 11                	js     80214d <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80213c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802145:	39 10                	cmp    %edx,(%eax)
  802147:	0f 94 c0             	sete   %al
  80214a:	0f b6 c0             	movzbl %al,%eax
}
  80214d:	c9                   	leave  
  80214e:	c3                   	ret    

0080214f <opencons>:
{
  80214f:	55                   	push   %ebp
  802150:	89 e5                	mov    %esp,%ebp
  802152:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802155:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802158:	50                   	push   %eax
  802159:	e8 49 ee ff ff       	call   800fa7 <fd_alloc>
  80215e:	83 c4 10             	add    $0x10,%esp
  802161:	85 c0                	test   %eax,%eax
  802163:	78 3a                	js     80219f <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802165:	83 ec 04             	sub    $0x4,%esp
  802168:	68 07 04 00 00       	push   $0x407
  80216d:	ff 75 f4             	push   -0xc(%ebp)
  802170:	6a 00                	push   $0x0
  802172:	e8 68 ea ff ff       	call   800bdf <sys_page_alloc>
  802177:	83 c4 10             	add    $0x10,%esp
  80217a:	85 c0                	test   %eax,%eax
  80217c:	78 21                	js     80219f <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80217e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802181:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802187:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802189:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80218c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802193:	83 ec 0c             	sub    $0xc,%esp
  802196:	50                   	push   %eax
  802197:	e8 e4 ed ff ff       	call   800f80 <fd2num>
  80219c:	83 c4 10             	add    $0x10,%esp
}
  80219f:	c9                   	leave  
  8021a0:	c3                   	ret    

008021a1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8021a1:	55                   	push   %ebp
  8021a2:	89 e5                	mov    %esp,%ebp
  8021a4:	56                   	push   %esi
  8021a5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8021a6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8021a9:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8021af:	e8 ed e9 ff ff       	call   800ba1 <sys_getenvid>
  8021b4:	83 ec 0c             	sub    $0xc,%esp
  8021b7:	ff 75 0c             	push   0xc(%ebp)
  8021ba:	ff 75 08             	push   0x8(%ebp)
  8021bd:	56                   	push   %esi
  8021be:	50                   	push   %eax
  8021bf:	68 14 2a 80 00       	push   $0x802a14
  8021c4:	e8 40 e0 ff ff       	call   800209 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021c9:	83 c4 18             	add    $0x18,%esp
  8021cc:	53                   	push   %ebx
  8021cd:	ff 75 10             	push   0x10(%ebp)
  8021d0:	e8 e3 df ff ff       	call   8001b8 <vcprintf>
	cprintf("\n");
  8021d5:	c7 04 24 90 25 80 00 	movl   $0x802590,(%esp)
  8021dc:	e8 28 e0 ff ff       	call   800209 <cprintf>
  8021e1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8021e4:	cc                   	int3   
  8021e5:	eb fd                	jmp    8021e4 <_panic+0x43>

008021e7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021e7:	55                   	push   %ebp
  8021e8:	89 e5                	mov    %esp,%ebp
  8021ea:	56                   	push   %esi
  8021eb:	53                   	push   %ebx
  8021ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8021ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8021f5:	85 c0                	test   %eax,%eax
  8021f7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8021fc:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8021ff:	83 ec 0c             	sub    $0xc,%esp
  802202:	50                   	push   %eax
  802203:	e8 87 eb ff ff       	call   800d8f <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802208:	83 c4 10             	add    $0x10,%esp
  80220b:	85 f6                	test   %esi,%esi
  80220d:	74 17                	je     802226 <ipc_recv+0x3f>
  80220f:	ba 00 00 00 00       	mov    $0x0,%edx
  802214:	85 c0                	test   %eax,%eax
  802216:	78 0c                	js     802224 <ipc_recv+0x3d>
  802218:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80221e:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  802224:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802226:	85 db                	test   %ebx,%ebx
  802228:	74 17                	je     802241 <ipc_recv+0x5a>
  80222a:	ba 00 00 00 00       	mov    $0x0,%edx
  80222f:	85 c0                	test   %eax,%eax
  802231:	78 0c                	js     80223f <ipc_recv+0x58>
  802233:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802239:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  80223f:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802241:	85 c0                	test   %eax,%eax
  802243:	78 0b                	js     802250 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  802245:	a1 00 40 80 00       	mov    0x804000,%eax
  80224a:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  802250:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802253:	5b                   	pop    %ebx
  802254:	5e                   	pop    %esi
  802255:	5d                   	pop    %ebp
  802256:	c3                   	ret    

00802257 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802257:	55                   	push   %ebp
  802258:	89 e5                	mov    %esp,%ebp
  80225a:	57                   	push   %edi
  80225b:	56                   	push   %esi
  80225c:	53                   	push   %ebx
  80225d:	83 ec 0c             	sub    $0xc,%esp
  802260:	8b 7d 08             	mov    0x8(%ebp),%edi
  802263:	8b 75 0c             	mov    0xc(%ebp),%esi
  802266:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  802269:	85 db                	test   %ebx,%ebx
  80226b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802270:	0f 44 d8             	cmove  %eax,%ebx
  802273:	eb 05                	jmp    80227a <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802275:	e8 46 e9 ff ff       	call   800bc0 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80227a:	ff 75 14             	push   0x14(%ebp)
  80227d:	53                   	push   %ebx
  80227e:	56                   	push   %esi
  80227f:	57                   	push   %edi
  802280:	e8 e7 ea ff ff       	call   800d6c <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802285:	83 c4 10             	add    $0x10,%esp
  802288:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80228b:	74 e8                	je     802275 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80228d:	85 c0                	test   %eax,%eax
  80228f:	78 08                	js     802299 <ipc_send+0x42>
	}while (r<0);

}
  802291:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802294:	5b                   	pop    %ebx
  802295:	5e                   	pop    %esi
  802296:	5f                   	pop    %edi
  802297:	5d                   	pop    %ebp
  802298:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802299:	50                   	push   %eax
  80229a:	68 37 2a 80 00       	push   $0x802a37
  80229f:	6a 3d                	push   $0x3d
  8022a1:	68 4b 2a 80 00       	push   $0x802a4b
  8022a6:	e8 f6 fe ff ff       	call   8021a1 <_panic>

008022ab <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8022ab:	55                   	push   %ebp
  8022ac:	89 e5                	mov    %esp,%ebp
  8022ae:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022b1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022b6:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  8022bc:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022c2:	8b 52 60             	mov    0x60(%edx),%edx
  8022c5:	39 ca                	cmp    %ecx,%edx
  8022c7:	74 11                	je     8022da <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  8022c9:	83 c0 01             	add    $0x1,%eax
  8022cc:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022d1:	75 e3                	jne    8022b6 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8022d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8022d8:	eb 0e                	jmp    8022e8 <ipc_find_env+0x3d>
			return envs[i].env_id;
  8022da:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8022e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022e5:	8b 40 58             	mov    0x58(%eax),%eax
}
  8022e8:	5d                   	pop    %ebp
  8022e9:	c3                   	ret    

008022ea <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022ea:	55                   	push   %ebp
  8022eb:	89 e5                	mov    %esp,%ebp
  8022ed:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022f0:	89 c2                	mov    %eax,%edx
  8022f2:	c1 ea 16             	shr    $0x16,%edx
  8022f5:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8022fc:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802301:	f6 c1 01             	test   $0x1,%cl
  802304:	74 1c                	je     802322 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802306:	c1 e8 0c             	shr    $0xc,%eax
  802309:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802310:	a8 01                	test   $0x1,%al
  802312:	74 0e                	je     802322 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802314:	c1 e8 0c             	shr    $0xc,%eax
  802317:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80231e:	ef 
  80231f:	0f b7 d2             	movzwl %dx,%edx
}
  802322:	89 d0                	mov    %edx,%eax
  802324:	5d                   	pop    %ebp
  802325:	c3                   	ret    
  802326:	66 90                	xchg   %ax,%ax
  802328:	66 90                	xchg   %ax,%ax
  80232a:	66 90                	xchg   %ax,%ax
  80232c:	66 90                	xchg   %ax,%ax
  80232e:	66 90                	xchg   %ax,%ax

00802330 <__udivdi3>:
  802330:	f3 0f 1e fb          	endbr32 
  802334:	55                   	push   %ebp
  802335:	57                   	push   %edi
  802336:	56                   	push   %esi
  802337:	53                   	push   %ebx
  802338:	83 ec 1c             	sub    $0x1c,%esp
  80233b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80233f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802343:	8b 74 24 34          	mov    0x34(%esp),%esi
  802347:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80234b:	85 c0                	test   %eax,%eax
  80234d:	75 19                	jne    802368 <__udivdi3+0x38>
  80234f:	39 f3                	cmp    %esi,%ebx
  802351:	76 4d                	jbe    8023a0 <__udivdi3+0x70>
  802353:	31 ff                	xor    %edi,%edi
  802355:	89 e8                	mov    %ebp,%eax
  802357:	89 f2                	mov    %esi,%edx
  802359:	f7 f3                	div    %ebx
  80235b:	89 fa                	mov    %edi,%edx
  80235d:	83 c4 1c             	add    $0x1c,%esp
  802360:	5b                   	pop    %ebx
  802361:	5e                   	pop    %esi
  802362:	5f                   	pop    %edi
  802363:	5d                   	pop    %ebp
  802364:	c3                   	ret    
  802365:	8d 76 00             	lea    0x0(%esi),%esi
  802368:	39 f0                	cmp    %esi,%eax
  80236a:	76 14                	jbe    802380 <__udivdi3+0x50>
  80236c:	31 ff                	xor    %edi,%edi
  80236e:	31 c0                	xor    %eax,%eax
  802370:	89 fa                	mov    %edi,%edx
  802372:	83 c4 1c             	add    $0x1c,%esp
  802375:	5b                   	pop    %ebx
  802376:	5e                   	pop    %esi
  802377:	5f                   	pop    %edi
  802378:	5d                   	pop    %ebp
  802379:	c3                   	ret    
  80237a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802380:	0f bd f8             	bsr    %eax,%edi
  802383:	83 f7 1f             	xor    $0x1f,%edi
  802386:	75 48                	jne    8023d0 <__udivdi3+0xa0>
  802388:	39 f0                	cmp    %esi,%eax
  80238a:	72 06                	jb     802392 <__udivdi3+0x62>
  80238c:	31 c0                	xor    %eax,%eax
  80238e:	39 eb                	cmp    %ebp,%ebx
  802390:	77 de                	ja     802370 <__udivdi3+0x40>
  802392:	b8 01 00 00 00       	mov    $0x1,%eax
  802397:	eb d7                	jmp    802370 <__udivdi3+0x40>
  802399:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023a0:	89 d9                	mov    %ebx,%ecx
  8023a2:	85 db                	test   %ebx,%ebx
  8023a4:	75 0b                	jne    8023b1 <__udivdi3+0x81>
  8023a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023ab:	31 d2                	xor    %edx,%edx
  8023ad:	f7 f3                	div    %ebx
  8023af:	89 c1                	mov    %eax,%ecx
  8023b1:	31 d2                	xor    %edx,%edx
  8023b3:	89 f0                	mov    %esi,%eax
  8023b5:	f7 f1                	div    %ecx
  8023b7:	89 c6                	mov    %eax,%esi
  8023b9:	89 e8                	mov    %ebp,%eax
  8023bb:	89 f7                	mov    %esi,%edi
  8023bd:	f7 f1                	div    %ecx
  8023bf:	89 fa                	mov    %edi,%edx
  8023c1:	83 c4 1c             	add    $0x1c,%esp
  8023c4:	5b                   	pop    %ebx
  8023c5:	5e                   	pop    %esi
  8023c6:	5f                   	pop    %edi
  8023c7:	5d                   	pop    %ebp
  8023c8:	c3                   	ret    
  8023c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023d0:	89 f9                	mov    %edi,%ecx
  8023d2:	ba 20 00 00 00       	mov    $0x20,%edx
  8023d7:	29 fa                	sub    %edi,%edx
  8023d9:	d3 e0                	shl    %cl,%eax
  8023db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023df:	89 d1                	mov    %edx,%ecx
  8023e1:	89 d8                	mov    %ebx,%eax
  8023e3:	d3 e8                	shr    %cl,%eax
  8023e5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8023e9:	09 c1                	or     %eax,%ecx
  8023eb:	89 f0                	mov    %esi,%eax
  8023ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023f1:	89 f9                	mov    %edi,%ecx
  8023f3:	d3 e3                	shl    %cl,%ebx
  8023f5:	89 d1                	mov    %edx,%ecx
  8023f7:	d3 e8                	shr    %cl,%eax
  8023f9:	89 f9                	mov    %edi,%ecx
  8023fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8023ff:	89 eb                	mov    %ebp,%ebx
  802401:	d3 e6                	shl    %cl,%esi
  802403:	89 d1                	mov    %edx,%ecx
  802405:	d3 eb                	shr    %cl,%ebx
  802407:	09 f3                	or     %esi,%ebx
  802409:	89 c6                	mov    %eax,%esi
  80240b:	89 f2                	mov    %esi,%edx
  80240d:	89 d8                	mov    %ebx,%eax
  80240f:	f7 74 24 08          	divl   0x8(%esp)
  802413:	89 d6                	mov    %edx,%esi
  802415:	89 c3                	mov    %eax,%ebx
  802417:	f7 64 24 0c          	mull   0xc(%esp)
  80241b:	39 d6                	cmp    %edx,%esi
  80241d:	72 19                	jb     802438 <__udivdi3+0x108>
  80241f:	89 f9                	mov    %edi,%ecx
  802421:	d3 e5                	shl    %cl,%ebp
  802423:	39 c5                	cmp    %eax,%ebp
  802425:	73 04                	jae    80242b <__udivdi3+0xfb>
  802427:	39 d6                	cmp    %edx,%esi
  802429:	74 0d                	je     802438 <__udivdi3+0x108>
  80242b:	89 d8                	mov    %ebx,%eax
  80242d:	31 ff                	xor    %edi,%edi
  80242f:	e9 3c ff ff ff       	jmp    802370 <__udivdi3+0x40>
  802434:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802438:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80243b:	31 ff                	xor    %edi,%edi
  80243d:	e9 2e ff ff ff       	jmp    802370 <__udivdi3+0x40>
  802442:	66 90                	xchg   %ax,%ax
  802444:	66 90                	xchg   %ax,%ax
  802446:	66 90                	xchg   %ax,%ax
  802448:	66 90                	xchg   %ax,%ax
  80244a:	66 90                	xchg   %ax,%ax
  80244c:	66 90                	xchg   %ax,%ax
  80244e:	66 90                	xchg   %ax,%ax

00802450 <__umoddi3>:
  802450:	f3 0f 1e fb          	endbr32 
  802454:	55                   	push   %ebp
  802455:	57                   	push   %edi
  802456:	56                   	push   %esi
  802457:	53                   	push   %ebx
  802458:	83 ec 1c             	sub    $0x1c,%esp
  80245b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80245f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802463:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802467:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80246b:	89 f0                	mov    %esi,%eax
  80246d:	89 da                	mov    %ebx,%edx
  80246f:	85 ff                	test   %edi,%edi
  802471:	75 15                	jne    802488 <__umoddi3+0x38>
  802473:	39 dd                	cmp    %ebx,%ebp
  802475:	76 39                	jbe    8024b0 <__umoddi3+0x60>
  802477:	f7 f5                	div    %ebp
  802479:	89 d0                	mov    %edx,%eax
  80247b:	31 d2                	xor    %edx,%edx
  80247d:	83 c4 1c             	add    $0x1c,%esp
  802480:	5b                   	pop    %ebx
  802481:	5e                   	pop    %esi
  802482:	5f                   	pop    %edi
  802483:	5d                   	pop    %ebp
  802484:	c3                   	ret    
  802485:	8d 76 00             	lea    0x0(%esi),%esi
  802488:	39 df                	cmp    %ebx,%edi
  80248a:	77 f1                	ja     80247d <__umoddi3+0x2d>
  80248c:	0f bd cf             	bsr    %edi,%ecx
  80248f:	83 f1 1f             	xor    $0x1f,%ecx
  802492:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802496:	75 40                	jne    8024d8 <__umoddi3+0x88>
  802498:	39 df                	cmp    %ebx,%edi
  80249a:	72 04                	jb     8024a0 <__umoddi3+0x50>
  80249c:	39 f5                	cmp    %esi,%ebp
  80249e:	77 dd                	ja     80247d <__umoddi3+0x2d>
  8024a0:	89 da                	mov    %ebx,%edx
  8024a2:	89 f0                	mov    %esi,%eax
  8024a4:	29 e8                	sub    %ebp,%eax
  8024a6:	19 fa                	sbb    %edi,%edx
  8024a8:	eb d3                	jmp    80247d <__umoddi3+0x2d>
  8024aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024b0:	89 e9                	mov    %ebp,%ecx
  8024b2:	85 ed                	test   %ebp,%ebp
  8024b4:	75 0b                	jne    8024c1 <__umoddi3+0x71>
  8024b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024bb:	31 d2                	xor    %edx,%edx
  8024bd:	f7 f5                	div    %ebp
  8024bf:	89 c1                	mov    %eax,%ecx
  8024c1:	89 d8                	mov    %ebx,%eax
  8024c3:	31 d2                	xor    %edx,%edx
  8024c5:	f7 f1                	div    %ecx
  8024c7:	89 f0                	mov    %esi,%eax
  8024c9:	f7 f1                	div    %ecx
  8024cb:	89 d0                	mov    %edx,%eax
  8024cd:	31 d2                	xor    %edx,%edx
  8024cf:	eb ac                	jmp    80247d <__umoddi3+0x2d>
  8024d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024d8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8024dc:	ba 20 00 00 00       	mov    $0x20,%edx
  8024e1:	29 c2                	sub    %eax,%edx
  8024e3:	89 c1                	mov    %eax,%ecx
  8024e5:	89 e8                	mov    %ebp,%eax
  8024e7:	d3 e7                	shl    %cl,%edi
  8024e9:	89 d1                	mov    %edx,%ecx
  8024eb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8024ef:	d3 e8                	shr    %cl,%eax
  8024f1:	89 c1                	mov    %eax,%ecx
  8024f3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8024f7:	09 f9                	or     %edi,%ecx
  8024f9:	89 df                	mov    %ebx,%edi
  8024fb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024ff:	89 c1                	mov    %eax,%ecx
  802501:	d3 e5                	shl    %cl,%ebp
  802503:	89 d1                	mov    %edx,%ecx
  802505:	d3 ef                	shr    %cl,%edi
  802507:	89 c1                	mov    %eax,%ecx
  802509:	89 f0                	mov    %esi,%eax
  80250b:	d3 e3                	shl    %cl,%ebx
  80250d:	89 d1                	mov    %edx,%ecx
  80250f:	89 fa                	mov    %edi,%edx
  802511:	d3 e8                	shr    %cl,%eax
  802513:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802518:	09 d8                	or     %ebx,%eax
  80251a:	f7 74 24 08          	divl   0x8(%esp)
  80251e:	89 d3                	mov    %edx,%ebx
  802520:	d3 e6                	shl    %cl,%esi
  802522:	f7 e5                	mul    %ebp
  802524:	89 c7                	mov    %eax,%edi
  802526:	89 d1                	mov    %edx,%ecx
  802528:	39 d3                	cmp    %edx,%ebx
  80252a:	72 06                	jb     802532 <__umoddi3+0xe2>
  80252c:	75 0e                	jne    80253c <__umoddi3+0xec>
  80252e:	39 c6                	cmp    %eax,%esi
  802530:	73 0a                	jae    80253c <__umoddi3+0xec>
  802532:	29 e8                	sub    %ebp,%eax
  802534:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802538:	89 d1                	mov    %edx,%ecx
  80253a:	89 c7                	mov    %eax,%edi
  80253c:	89 f5                	mov    %esi,%ebp
  80253e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802542:	29 fd                	sub    %edi,%ebp
  802544:	19 cb                	sbb    %ecx,%ebx
  802546:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80254b:	89 d8                	mov    %ebx,%eax
  80254d:	d3 e0                	shl    %cl,%eax
  80254f:	89 f1                	mov    %esi,%ecx
  802551:	d3 ed                	shr    %cl,%ebp
  802553:	d3 eb                	shr    %cl,%ebx
  802555:	09 e8                	or     %ebp,%eax
  802557:	89 da                	mov    %ebx,%edx
  802559:	83 c4 1c             	add    $0x1c,%esp
  80255c:	5b                   	pop    %ebx
  80255d:	5e                   	pop    %esi
  80255e:	5f                   	pop    %edi
  80255f:	5d                   	pop    %ebp
  802560:	c3                   	ret    
