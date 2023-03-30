
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
  800039:	68 60 25 80 00       	push   $0x802560
  80003e:	e8 c3 01 00 00       	call   800206 <cprintf>
	exit();
  800043:	e8 0f 01 00 00       	call   800157 <exit>
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
  800067:	e8 c2 0d 00 00       	call   800e2e <argstart>
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
  800083:	e8 d6 0d 00 00       	call   800e5e <argnext>
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
  8000bd:	68 74 25 80 00       	push   $0x802574
  8000c2:	e8 3f 01 00 00       	call   800206 <cprintf>
  8000c7:	83 c4 20             	add    $0x20,%esp
	for (i = 0; i < 32; i++)
  8000ca:	83 c3 01             	add    $0x1,%ebx
  8000cd:	83 fb 20             	cmp    $0x20,%ebx
  8000d0:	74 37                	je     800109 <umain+0xbc>
		if (fstat(i, &st) >= 0) {
  8000d2:	83 ec 08             	sub    $0x8,%esp
  8000d5:	57                   	push   %edi
  8000d6:	53                   	push   %ebx
  8000d7:	e8 79 13 00 00       	call   801455 <fstat>
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
  8000f8:	68 74 25 80 00       	push   $0x802574
  8000fd:	6a 01                	push   $0x1
  8000ff:	e8 47 17 00 00       	call   80184b <fprintf>
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
  80011c:	e8 7d 0a 00 00       	call   800b9e <sys_getenvid>
  800121:	25 ff 03 00 00       	and    $0x3ff,%eax
  800126:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800129:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012e:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800133:	85 db                	test   %ebx,%ebx
  800135:	7e 07                	jle    80013e <libmain+0x2d>
		binaryname = argv[0];
  800137:	8b 06                	mov    (%esi),%eax
  800139:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013e:	83 ec 08             	sub    $0x8,%esp
  800141:	56                   	push   %esi
  800142:	53                   	push   %ebx
  800143:	e8 05 ff ff ff       	call   80004d <umain>

	// exit gracefully
	exit();
  800148:	e8 0a 00 00 00       	call   800157 <exit>
}
  80014d:	83 c4 10             	add    $0x10,%esp
  800150:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800153:	5b                   	pop    %ebx
  800154:	5e                   	pop    %esi
  800155:	5d                   	pop    %ebp
  800156:	c3                   	ret    

00800157 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80015d:	e8 ec 0f 00 00       	call   80114e <close_all>
	sys_env_destroy(0);
  800162:	83 ec 0c             	sub    $0xc,%esp
  800165:	6a 00                	push   $0x0
  800167:	e8 f1 09 00 00       	call   800b5d <sys_env_destroy>
}
  80016c:	83 c4 10             	add    $0x10,%esp
  80016f:	c9                   	leave  
  800170:	c3                   	ret    

00800171 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800171:	55                   	push   %ebp
  800172:	89 e5                	mov    %esp,%ebp
  800174:	53                   	push   %ebx
  800175:	83 ec 04             	sub    $0x4,%esp
  800178:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80017b:	8b 13                	mov    (%ebx),%edx
  80017d:	8d 42 01             	lea    0x1(%edx),%eax
  800180:	89 03                	mov    %eax,(%ebx)
  800182:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800185:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800189:	3d ff 00 00 00       	cmp    $0xff,%eax
  80018e:	74 09                	je     800199 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800190:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800194:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800197:	c9                   	leave  
  800198:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800199:	83 ec 08             	sub    $0x8,%esp
  80019c:	68 ff 00 00 00       	push   $0xff
  8001a1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a4:	50                   	push   %eax
  8001a5:	e8 76 09 00 00       	call   800b20 <sys_cputs>
		b->idx = 0;
  8001aa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b0:	83 c4 10             	add    $0x10,%esp
  8001b3:	eb db                	jmp    800190 <putch+0x1f>

008001b5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001b5:	55                   	push   %ebp
  8001b6:	89 e5                	mov    %esp,%ebp
  8001b8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001be:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c5:	00 00 00 
	b.cnt = 0;
  8001c8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001cf:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d2:	ff 75 0c             	push   0xc(%ebp)
  8001d5:	ff 75 08             	push   0x8(%ebp)
  8001d8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001de:	50                   	push   %eax
  8001df:	68 71 01 80 00       	push   $0x800171
  8001e4:	e8 14 01 00 00       	call   8002fd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e9:	83 c4 08             	add    $0x8,%esp
  8001ec:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001f2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f8:	50                   	push   %eax
  8001f9:	e8 22 09 00 00       	call   800b20 <sys_cputs>

	return b.cnt;
}
  8001fe:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800204:	c9                   	leave  
  800205:	c3                   	ret    

00800206 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80020c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80020f:	50                   	push   %eax
  800210:	ff 75 08             	push   0x8(%ebp)
  800213:	e8 9d ff ff ff       	call   8001b5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	57                   	push   %edi
  80021e:	56                   	push   %esi
  80021f:	53                   	push   %ebx
  800220:	83 ec 1c             	sub    $0x1c,%esp
  800223:	89 c7                	mov    %eax,%edi
  800225:	89 d6                	mov    %edx,%esi
  800227:	8b 45 08             	mov    0x8(%ebp),%eax
  80022a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80022d:	89 d1                	mov    %edx,%ecx
  80022f:	89 c2                	mov    %eax,%edx
  800231:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800234:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800237:	8b 45 10             	mov    0x10(%ebp),%eax
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80023d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800240:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800247:	39 c2                	cmp    %eax,%edx
  800249:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80024c:	72 3e                	jb     80028c <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	ff 75 18             	push   0x18(%ebp)
  800254:	83 eb 01             	sub    $0x1,%ebx
  800257:	53                   	push   %ebx
  800258:	50                   	push   %eax
  800259:	83 ec 08             	sub    $0x8,%esp
  80025c:	ff 75 e4             	push   -0x1c(%ebp)
  80025f:	ff 75 e0             	push   -0x20(%ebp)
  800262:	ff 75 dc             	push   -0x24(%ebp)
  800265:	ff 75 d8             	push   -0x28(%ebp)
  800268:	e8 b3 20 00 00       	call   802320 <__udivdi3>
  80026d:	83 c4 18             	add    $0x18,%esp
  800270:	52                   	push   %edx
  800271:	50                   	push   %eax
  800272:	89 f2                	mov    %esi,%edx
  800274:	89 f8                	mov    %edi,%eax
  800276:	e8 9f ff ff ff       	call   80021a <printnum>
  80027b:	83 c4 20             	add    $0x20,%esp
  80027e:	eb 13                	jmp    800293 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800280:	83 ec 08             	sub    $0x8,%esp
  800283:	56                   	push   %esi
  800284:	ff 75 18             	push   0x18(%ebp)
  800287:	ff d7                	call   *%edi
  800289:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80028c:	83 eb 01             	sub    $0x1,%ebx
  80028f:	85 db                	test   %ebx,%ebx
  800291:	7f ed                	jg     800280 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800293:	83 ec 08             	sub    $0x8,%esp
  800296:	56                   	push   %esi
  800297:	83 ec 04             	sub    $0x4,%esp
  80029a:	ff 75 e4             	push   -0x1c(%ebp)
  80029d:	ff 75 e0             	push   -0x20(%ebp)
  8002a0:	ff 75 dc             	push   -0x24(%ebp)
  8002a3:	ff 75 d8             	push   -0x28(%ebp)
  8002a6:	e8 95 21 00 00       	call   802440 <__umoddi3>
  8002ab:	83 c4 14             	add    $0x14,%esp
  8002ae:	0f be 80 a6 25 80 00 	movsbl 0x8025a6(%eax),%eax
  8002b5:	50                   	push   %eax
  8002b6:	ff d7                	call   *%edi
}
  8002b8:	83 c4 10             	add    $0x10,%esp
  8002bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002be:	5b                   	pop    %ebx
  8002bf:	5e                   	pop    %esi
  8002c0:	5f                   	pop    %edi
  8002c1:	5d                   	pop    %ebp
  8002c2:	c3                   	ret    

008002c3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c3:	55                   	push   %ebp
  8002c4:	89 e5                	mov    %esp,%ebp
  8002c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002cd:	8b 10                	mov    (%eax),%edx
  8002cf:	3b 50 04             	cmp    0x4(%eax),%edx
  8002d2:	73 0a                	jae    8002de <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002d7:	89 08                	mov    %ecx,(%eax)
  8002d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002dc:	88 02                	mov    %al,(%edx)
}
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    

008002e0 <printfmt>:
{
  8002e0:	55                   	push   %ebp
  8002e1:	89 e5                	mov    %esp,%ebp
  8002e3:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002e6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002e9:	50                   	push   %eax
  8002ea:	ff 75 10             	push   0x10(%ebp)
  8002ed:	ff 75 0c             	push   0xc(%ebp)
  8002f0:	ff 75 08             	push   0x8(%ebp)
  8002f3:	e8 05 00 00 00       	call   8002fd <vprintfmt>
}
  8002f8:	83 c4 10             	add    $0x10,%esp
  8002fb:	c9                   	leave  
  8002fc:	c3                   	ret    

008002fd <vprintfmt>:
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
  800303:	83 ec 3c             	sub    $0x3c,%esp
  800306:	8b 75 08             	mov    0x8(%ebp),%esi
  800309:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80030c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80030f:	eb 0a                	jmp    80031b <vprintfmt+0x1e>
			putch(ch, putdat);
  800311:	83 ec 08             	sub    $0x8,%esp
  800314:	53                   	push   %ebx
  800315:	50                   	push   %eax
  800316:	ff d6                	call   *%esi
  800318:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80031b:	83 c7 01             	add    $0x1,%edi
  80031e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800322:	83 f8 25             	cmp    $0x25,%eax
  800325:	74 0c                	je     800333 <vprintfmt+0x36>
			if (ch == '\0')
  800327:	85 c0                	test   %eax,%eax
  800329:	75 e6                	jne    800311 <vprintfmt+0x14>
}
  80032b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032e:	5b                   	pop    %ebx
  80032f:	5e                   	pop    %esi
  800330:	5f                   	pop    %edi
  800331:	5d                   	pop    %ebp
  800332:	c3                   	ret    
		padc = ' ';
  800333:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800337:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80033e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800345:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80034c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800351:	8d 47 01             	lea    0x1(%edi),%eax
  800354:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800357:	0f b6 17             	movzbl (%edi),%edx
  80035a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80035d:	3c 55                	cmp    $0x55,%al
  80035f:	0f 87 bb 03 00 00    	ja     800720 <vprintfmt+0x423>
  800365:	0f b6 c0             	movzbl %al,%eax
  800368:	ff 24 85 e0 26 80 00 	jmp    *0x8026e0(,%eax,4)
  80036f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800372:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800376:	eb d9                	jmp    800351 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800378:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037b:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80037f:	eb d0                	jmp    800351 <vprintfmt+0x54>
  800381:	0f b6 d2             	movzbl %dl,%edx
  800384:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800387:	b8 00 00 00 00       	mov    $0x0,%eax
  80038c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80038f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800392:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800396:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800399:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80039c:	83 f9 09             	cmp    $0x9,%ecx
  80039f:	77 55                	ja     8003f6 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8003a1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003a4:	eb e9                	jmp    80038f <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8003a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003a9:	8b 00                	mov    (%eax),%eax
  8003ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b1:	8d 40 04             	lea    0x4(%eax),%eax
  8003b4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003ba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003be:	79 91                	jns    800351 <vprintfmt+0x54>
				width = precision, precision = -1;
  8003c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003c6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003cd:	eb 82                	jmp    800351 <vprintfmt+0x54>
  8003cf:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003d2:	85 d2                	test   %edx,%edx
  8003d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8003d9:	0f 49 c2             	cmovns %edx,%eax
  8003dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003e2:	e9 6a ff ff ff       	jmp    800351 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003ea:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003f1:	e9 5b ff ff ff       	jmp    800351 <vprintfmt+0x54>
  8003f6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003fc:	eb bc                	jmp    8003ba <vprintfmt+0xbd>
			lflag++;
  8003fe:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800401:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800404:	e9 48 ff ff ff       	jmp    800351 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800409:	8b 45 14             	mov    0x14(%ebp),%eax
  80040c:	8d 78 04             	lea    0x4(%eax),%edi
  80040f:	83 ec 08             	sub    $0x8,%esp
  800412:	53                   	push   %ebx
  800413:	ff 30                	push   (%eax)
  800415:	ff d6                	call   *%esi
			break;
  800417:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80041a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80041d:	e9 9d 02 00 00       	jmp    8006bf <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800422:	8b 45 14             	mov    0x14(%ebp),%eax
  800425:	8d 78 04             	lea    0x4(%eax),%edi
  800428:	8b 10                	mov    (%eax),%edx
  80042a:	89 d0                	mov    %edx,%eax
  80042c:	f7 d8                	neg    %eax
  80042e:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800431:	83 f8 0f             	cmp    $0xf,%eax
  800434:	7f 23                	jg     800459 <vprintfmt+0x15c>
  800436:	8b 14 85 40 28 80 00 	mov    0x802840(,%eax,4),%edx
  80043d:	85 d2                	test   %edx,%edx
  80043f:	74 18                	je     800459 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800441:	52                   	push   %edx
  800442:	68 75 29 80 00       	push   $0x802975
  800447:	53                   	push   %ebx
  800448:	56                   	push   %esi
  800449:	e8 92 fe ff ff       	call   8002e0 <printfmt>
  80044e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800451:	89 7d 14             	mov    %edi,0x14(%ebp)
  800454:	e9 66 02 00 00       	jmp    8006bf <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800459:	50                   	push   %eax
  80045a:	68 be 25 80 00       	push   $0x8025be
  80045f:	53                   	push   %ebx
  800460:	56                   	push   %esi
  800461:	e8 7a fe ff ff       	call   8002e0 <printfmt>
  800466:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800469:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80046c:	e9 4e 02 00 00       	jmp    8006bf <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800471:	8b 45 14             	mov    0x14(%ebp),%eax
  800474:	83 c0 04             	add    $0x4,%eax
  800477:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80047a:	8b 45 14             	mov    0x14(%ebp),%eax
  80047d:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80047f:	85 d2                	test   %edx,%edx
  800481:	b8 b7 25 80 00       	mov    $0x8025b7,%eax
  800486:	0f 45 c2             	cmovne %edx,%eax
  800489:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80048c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800490:	7e 06                	jle    800498 <vprintfmt+0x19b>
  800492:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800496:	75 0d                	jne    8004a5 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800498:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80049b:	89 c7                	mov    %eax,%edi
  80049d:	03 45 e0             	add    -0x20(%ebp),%eax
  8004a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a3:	eb 55                	jmp    8004fa <vprintfmt+0x1fd>
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	ff 75 d8             	push   -0x28(%ebp)
  8004ab:	ff 75 cc             	push   -0x34(%ebp)
  8004ae:	e8 0a 03 00 00       	call   8007bd <strnlen>
  8004b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b6:	29 c1                	sub    %eax,%ecx
  8004b8:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8004bb:	83 c4 10             	add    $0x10,%esp
  8004be:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8004c0:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8004c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004c7:	eb 0f                	jmp    8004d8 <vprintfmt+0x1db>
					putch(padc, putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	53                   	push   %ebx
  8004cd:	ff 75 e0             	push   -0x20(%ebp)
  8004d0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d2:	83 ef 01             	sub    $0x1,%edi
  8004d5:	83 c4 10             	add    $0x10,%esp
  8004d8:	85 ff                	test   %edi,%edi
  8004da:	7f ed                	jg     8004c9 <vprintfmt+0x1cc>
  8004dc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004df:	85 d2                	test   %edx,%edx
  8004e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004e6:	0f 49 c2             	cmovns %edx,%eax
  8004e9:	29 c2                	sub    %eax,%edx
  8004eb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004ee:	eb a8                	jmp    800498 <vprintfmt+0x19b>
					putch(ch, putdat);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	53                   	push   %ebx
  8004f4:	52                   	push   %edx
  8004f5:	ff d6                	call   *%esi
  8004f7:	83 c4 10             	add    $0x10,%esp
  8004fa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004fd:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004ff:	83 c7 01             	add    $0x1,%edi
  800502:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800506:	0f be d0             	movsbl %al,%edx
  800509:	85 d2                	test   %edx,%edx
  80050b:	74 4b                	je     800558 <vprintfmt+0x25b>
  80050d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800511:	78 06                	js     800519 <vprintfmt+0x21c>
  800513:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800517:	78 1e                	js     800537 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800519:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80051d:	74 d1                	je     8004f0 <vprintfmt+0x1f3>
  80051f:	0f be c0             	movsbl %al,%eax
  800522:	83 e8 20             	sub    $0x20,%eax
  800525:	83 f8 5e             	cmp    $0x5e,%eax
  800528:	76 c6                	jbe    8004f0 <vprintfmt+0x1f3>
					putch('?', putdat);
  80052a:	83 ec 08             	sub    $0x8,%esp
  80052d:	53                   	push   %ebx
  80052e:	6a 3f                	push   $0x3f
  800530:	ff d6                	call   *%esi
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	eb c3                	jmp    8004fa <vprintfmt+0x1fd>
  800537:	89 cf                	mov    %ecx,%edi
  800539:	eb 0e                	jmp    800549 <vprintfmt+0x24c>
				putch(' ', putdat);
  80053b:	83 ec 08             	sub    $0x8,%esp
  80053e:	53                   	push   %ebx
  80053f:	6a 20                	push   $0x20
  800541:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800543:	83 ef 01             	sub    $0x1,%edi
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	85 ff                	test   %edi,%edi
  80054b:	7f ee                	jg     80053b <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80054d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800550:	89 45 14             	mov    %eax,0x14(%ebp)
  800553:	e9 67 01 00 00       	jmp    8006bf <vprintfmt+0x3c2>
  800558:	89 cf                	mov    %ecx,%edi
  80055a:	eb ed                	jmp    800549 <vprintfmt+0x24c>
	if (lflag >= 2)
  80055c:	83 f9 01             	cmp    $0x1,%ecx
  80055f:	7f 1b                	jg     80057c <vprintfmt+0x27f>
	else if (lflag)
  800561:	85 c9                	test   %ecx,%ecx
  800563:	74 63                	je     8005c8 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800565:	8b 45 14             	mov    0x14(%ebp),%eax
  800568:	8b 00                	mov    (%eax),%eax
  80056a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056d:	99                   	cltd   
  80056e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 40 04             	lea    0x4(%eax),%eax
  800577:	89 45 14             	mov    %eax,0x14(%ebp)
  80057a:	eb 17                	jmp    800593 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8b 50 04             	mov    0x4(%eax),%edx
  800582:	8b 00                	mov    (%eax),%eax
  800584:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800587:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80058a:	8b 45 14             	mov    0x14(%ebp),%eax
  80058d:	8d 40 08             	lea    0x8(%eax),%eax
  800590:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800593:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800596:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800599:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80059e:	85 c9                	test   %ecx,%ecx
  8005a0:	0f 89 ff 00 00 00    	jns    8006a5 <vprintfmt+0x3a8>
				putch('-', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	53                   	push   %ebx
  8005aa:	6a 2d                	push   $0x2d
  8005ac:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ae:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005b4:	f7 da                	neg    %edx
  8005b6:	83 d1 00             	adc    $0x0,%ecx
  8005b9:	f7 d9                	neg    %ecx
  8005bb:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005be:	bf 0a 00 00 00       	mov    $0xa,%edi
  8005c3:	e9 dd 00 00 00       	jmp    8006a5 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8005c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005cb:	8b 00                	mov    (%eax),%eax
  8005cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d0:	99                   	cltd   
  8005d1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 40 04             	lea    0x4(%eax),%eax
  8005da:	89 45 14             	mov    %eax,0x14(%ebp)
  8005dd:	eb b4                	jmp    800593 <vprintfmt+0x296>
	if (lflag >= 2)
  8005df:	83 f9 01             	cmp    $0x1,%ecx
  8005e2:	7f 1e                	jg     800602 <vprintfmt+0x305>
	else if (lflag)
  8005e4:	85 c9                	test   %ecx,%ecx
  8005e6:	74 32                	je     80061a <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8b 10                	mov    (%eax),%edx
  8005ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f2:	8d 40 04             	lea    0x4(%eax),%eax
  8005f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005f8:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8005fd:	e9 a3 00 00 00       	jmp    8006a5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8b 10                	mov    (%eax),%edx
  800607:	8b 48 04             	mov    0x4(%eax),%ecx
  80060a:	8d 40 08             	lea    0x8(%eax),%eax
  80060d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800610:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800615:	e9 8b 00 00 00       	jmp    8006a5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8b 10                	mov    (%eax),%edx
  80061f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800624:	8d 40 04             	lea    0x4(%eax),%eax
  800627:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80062a:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80062f:	eb 74                	jmp    8006a5 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800631:	83 f9 01             	cmp    $0x1,%ecx
  800634:	7f 1b                	jg     800651 <vprintfmt+0x354>
	else if (lflag)
  800636:	85 c9                	test   %ecx,%ecx
  800638:	74 2c                	je     800666 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8b 10                	mov    (%eax),%edx
  80063f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800644:	8d 40 04             	lea    0x4(%eax),%eax
  800647:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80064a:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80064f:	eb 54                	jmp    8006a5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800651:	8b 45 14             	mov    0x14(%ebp),%eax
  800654:	8b 10                	mov    (%eax),%edx
  800656:	8b 48 04             	mov    0x4(%eax),%ecx
  800659:	8d 40 08             	lea    0x8(%eax),%eax
  80065c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80065f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800664:	eb 3f                	jmp    8006a5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800666:	8b 45 14             	mov    0x14(%ebp),%eax
  800669:	8b 10                	mov    (%eax),%edx
  80066b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800670:	8d 40 04             	lea    0x4(%eax),%eax
  800673:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800676:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80067b:	eb 28                	jmp    8006a5 <vprintfmt+0x3a8>
			putch('0', putdat);
  80067d:	83 ec 08             	sub    $0x8,%esp
  800680:	53                   	push   %ebx
  800681:	6a 30                	push   $0x30
  800683:	ff d6                	call   *%esi
			putch('x', putdat);
  800685:	83 c4 08             	add    $0x8,%esp
  800688:	53                   	push   %ebx
  800689:	6a 78                	push   $0x78
  80068b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80068d:	8b 45 14             	mov    0x14(%ebp),%eax
  800690:	8b 10                	mov    (%eax),%edx
  800692:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800697:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80069a:	8d 40 04             	lea    0x4(%eax),%eax
  80069d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006a0:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8006a5:	83 ec 0c             	sub    $0xc,%esp
  8006a8:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006ac:	50                   	push   %eax
  8006ad:	ff 75 e0             	push   -0x20(%ebp)
  8006b0:	57                   	push   %edi
  8006b1:	51                   	push   %ecx
  8006b2:	52                   	push   %edx
  8006b3:	89 da                	mov    %ebx,%edx
  8006b5:	89 f0                	mov    %esi,%eax
  8006b7:	e8 5e fb ff ff       	call   80021a <printnum>
			break;
  8006bc:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8006bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006c2:	e9 54 fc ff ff       	jmp    80031b <vprintfmt+0x1e>
	if (lflag >= 2)
  8006c7:	83 f9 01             	cmp    $0x1,%ecx
  8006ca:	7f 1b                	jg     8006e7 <vprintfmt+0x3ea>
	else if (lflag)
  8006cc:	85 c9                	test   %ecx,%ecx
  8006ce:	74 2c                	je     8006fc <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d3:	8b 10                	mov    (%eax),%edx
  8006d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006da:	8d 40 04             	lea    0x4(%eax),%eax
  8006dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e0:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8006e5:	eb be                	jmp    8006a5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ea:	8b 10                	mov    (%eax),%edx
  8006ec:	8b 48 04             	mov    0x4(%eax),%ecx
  8006ef:	8d 40 08             	lea    0x8(%eax),%eax
  8006f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006f5:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8006fa:	eb a9                	jmp    8006a5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8b 10                	mov    (%eax),%edx
  800701:	b9 00 00 00 00       	mov    $0x0,%ecx
  800706:	8d 40 04             	lea    0x4(%eax),%eax
  800709:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80070c:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800711:	eb 92                	jmp    8006a5 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800713:	83 ec 08             	sub    $0x8,%esp
  800716:	53                   	push   %ebx
  800717:	6a 25                	push   $0x25
  800719:	ff d6                	call   *%esi
			break;
  80071b:	83 c4 10             	add    $0x10,%esp
  80071e:	eb 9f                	jmp    8006bf <vprintfmt+0x3c2>
			putch('%', putdat);
  800720:	83 ec 08             	sub    $0x8,%esp
  800723:	53                   	push   %ebx
  800724:	6a 25                	push   $0x25
  800726:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	89 f8                	mov    %edi,%eax
  80072d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800731:	74 05                	je     800738 <vprintfmt+0x43b>
  800733:	83 e8 01             	sub    $0x1,%eax
  800736:	eb f5                	jmp    80072d <vprintfmt+0x430>
  800738:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80073b:	eb 82                	jmp    8006bf <vprintfmt+0x3c2>

0080073d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	83 ec 18             	sub    $0x18,%esp
  800743:	8b 45 08             	mov    0x8(%ebp),%eax
  800746:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800749:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80074c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800750:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800753:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80075a:	85 c0                	test   %eax,%eax
  80075c:	74 26                	je     800784 <vsnprintf+0x47>
  80075e:	85 d2                	test   %edx,%edx
  800760:	7e 22                	jle    800784 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800762:	ff 75 14             	push   0x14(%ebp)
  800765:	ff 75 10             	push   0x10(%ebp)
  800768:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80076b:	50                   	push   %eax
  80076c:	68 c3 02 80 00       	push   $0x8002c3
  800771:	e8 87 fb ff ff       	call   8002fd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800776:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800779:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80077c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80077f:	83 c4 10             	add    $0x10,%esp
}
  800782:	c9                   	leave  
  800783:	c3                   	ret    
		return -E_INVAL;
  800784:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800789:	eb f7                	jmp    800782 <vsnprintf+0x45>

0080078b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800791:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800794:	50                   	push   %eax
  800795:	ff 75 10             	push   0x10(%ebp)
  800798:	ff 75 0c             	push   0xc(%ebp)
  80079b:	ff 75 08             	push   0x8(%ebp)
  80079e:	e8 9a ff ff ff       	call   80073d <vsnprintf>
	va_end(ap);

	return rc;
}
  8007a3:	c9                   	leave  
  8007a4:	c3                   	ret    

008007a5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007a5:	55                   	push   %ebp
  8007a6:	89 e5                	mov    %esp,%ebp
  8007a8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b0:	eb 03                	jmp    8007b5 <strlen+0x10>
		n++;
  8007b2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8007b5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007b9:	75 f7                	jne    8007b2 <strlen+0xd>
	return n;
}
  8007bb:	5d                   	pop    %ebp
  8007bc:	c3                   	ret    

008007bd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007bd:	55                   	push   %ebp
  8007be:	89 e5                	mov    %esp,%ebp
  8007c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cb:	eb 03                	jmp    8007d0 <strnlen+0x13>
		n++;
  8007cd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d0:	39 d0                	cmp    %edx,%eax
  8007d2:	74 08                	je     8007dc <strnlen+0x1f>
  8007d4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007d8:	75 f3                	jne    8007cd <strnlen+0x10>
  8007da:	89 c2                	mov    %eax,%edx
	return n;
}
  8007dc:	89 d0                	mov    %edx,%eax
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	53                   	push   %ebx
  8007e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8007ef:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007f3:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007f6:	83 c0 01             	add    $0x1,%eax
  8007f9:	84 d2                	test   %dl,%dl
  8007fb:	75 f2                	jne    8007ef <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007fd:	89 c8                	mov    %ecx,%eax
  8007ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800802:	c9                   	leave  
  800803:	c3                   	ret    

00800804 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	53                   	push   %ebx
  800808:	83 ec 10             	sub    $0x10,%esp
  80080b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80080e:	53                   	push   %ebx
  80080f:	e8 91 ff ff ff       	call   8007a5 <strlen>
  800814:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800817:	ff 75 0c             	push   0xc(%ebp)
  80081a:	01 d8                	add    %ebx,%eax
  80081c:	50                   	push   %eax
  80081d:	e8 be ff ff ff       	call   8007e0 <strcpy>
	return dst;
}
  800822:	89 d8                	mov    %ebx,%eax
  800824:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800827:	c9                   	leave  
  800828:	c3                   	ret    

00800829 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800829:	55                   	push   %ebp
  80082a:	89 e5                	mov    %esp,%ebp
  80082c:	56                   	push   %esi
  80082d:	53                   	push   %ebx
  80082e:	8b 75 08             	mov    0x8(%ebp),%esi
  800831:	8b 55 0c             	mov    0xc(%ebp),%edx
  800834:	89 f3                	mov    %esi,%ebx
  800836:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800839:	89 f0                	mov    %esi,%eax
  80083b:	eb 0f                	jmp    80084c <strncpy+0x23>
		*dst++ = *src;
  80083d:	83 c0 01             	add    $0x1,%eax
  800840:	0f b6 0a             	movzbl (%edx),%ecx
  800843:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800846:	80 f9 01             	cmp    $0x1,%cl
  800849:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80084c:	39 d8                	cmp    %ebx,%eax
  80084e:	75 ed                	jne    80083d <strncpy+0x14>
	}
	return ret;
}
  800850:	89 f0                	mov    %esi,%eax
  800852:	5b                   	pop    %ebx
  800853:	5e                   	pop    %esi
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	56                   	push   %esi
  80085a:	53                   	push   %ebx
  80085b:	8b 75 08             	mov    0x8(%ebp),%esi
  80085e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800861:	8b 55 10             	mov    0x10(%ebp),%edx
  800864:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800866:	85 d2                	test   %edx,%edx
  800868:	74 21                	je     80088b <strlcpy+0x35>
  80086a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80086e:	89 f2                	mov    %esi,%edx
  800870:	eb 09                	jmp    80087b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800872:	83 c1 01             	add    $0x1,%ecx
  800875:	83 c2 01             	add    $0x1,%edx
  800878:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80087b:	39 c2                	cmp    %eax,%edx
  80087d:	74 09                	je     800888 <strlcpy+0x32>
  80087f:	0f b6 19             	movzbl (%ecx),%ebx
  800882:	84 db                	test   %bl,%bl
  800884:	75 ec                	jne    800872 <strlcpy+0x1c>
  800886:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800888:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80088b:	29 f0                	sub    %esi,%eax
}
  80088d:	5b                   	pop    %ebx
  80088e:	5e                   	pop    %esi
  80088f:	5d                   	pop    %ebp
  800890:	c3                   	ret    

00800891 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800897:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80089a:	eb 06                	jmp    8008a2 <strcmp+0x11>
		p++, q++;
  80089c:	83 c1 01             	add    $0x1,%ecx
  80089f:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8008a2:	0f b6 01             	movzbl (%ecx),%eax
  8008a5:	84 c0                	test   %al,%al
  8008a7:	74 04                	je     8008ad <strcmp+0x1c>
  8008a9:	3a 02                	cmp    (%edx),%al
  8008ab:	74 ef                	je     80089c <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ad:	0f b6 c0             	movzbl %al,%eax
  8008b0:	0f b6 12             	movzbl (%edx),%edx
  8008b3:	29 d0                	sub    %edx,%eax
}
  8008b5:	5d                   	pop    %ebp
  8008b6:	c3                   	ret    

008008b7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	53                   	push   %ebx
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c1:	89 c3                	mov    %eax,%ebx
  8008c3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008c6:	eb 06                	jmp    8008ce <strncmp+0x17>
		n--, p++, q++;
  8008c8:	83 c0 01             	add    $0x1,%eax
  8008cb:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008ce:	39 d8                	cmp    %ebx,%eax
  8008d0:	74 18                	je     8008ea <strncmp+0x33>
  8008d2:	0f b6 08             	movzbl (%eax),%ecx
  8008d5:	84 c9                	test   %cl,%cl
  8008d7:	74 04                	je     8008dd <strncmp+0x26>
  8008d9:	3a 0a                	cmp    (%edx),%cl
  8008db:	74 eb                	je     8008c8 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008dd:	0f b6 00             	movzbl (%eax),%eax
  8008e0:	0f b6 12             	movzbl (%edx),%edx
  8008e3:	29 d0                	sub    %edx,%eax
}
  8008e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e8:	c9                   	leave  
  8008e9:	c3                   	ret    
		return 0;
  8008ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ef:	eb f4                	jmp    8008e5 <strncmp+0x2e>

008008f1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fb:	eb 03                	jmp    800900 <strchr+0xf>
  8008fd:	83 c0 01             	add    $0x1,%eax
  800900:	0f b6 10             	movzbl (%eax),%edx
  800903:	84 d2                	test   %dl,%dl
  800905:	74 06                	je     80090d <strchr+0x1c>
		if (*s == c)
  800907:	38 ca                	cmp    %cl,%dl
  800909:	75 f2                	jne    8008fd <strchr+0xc>
  80090b:	eb 05                	jmp    800912 <strchr+0x21>
			return (char *) s;
	return 0;
  80090d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80091e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800921:	38 ca                	cmp    %cl,%dl
  800923:	74 09                	je     80092e <strfind+0x1a>
  800925:	84 d2                	test   %dl,%dl
  800927:	74 05                	je     80092e <strfind+0x1a>
	for (; *s; s++)
  800929:	83 c0 01             	add    $0x1,%eax
  80092c:	eb f0                	jmp    80091e <strfind+0xa>
			break;
	return (char *) s;
}
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	57                   	push   %edi
  800934:	56                   	push   %esi
  800935:	53                   	push   %ebx
  800936:	8b 7d 08             	mov    0x8(%ebp),%edi
  800939:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80093c:	85 c9                	test   %ecx,%ecx
  80093e:	74 2f                	je     80096f <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800940:	89 f8                	mov    %edi,%eax
  800942:	09 c8                	or     %ecx,%eax
  800944:	a8 03                	test   $0x3,%al
  800946:	75 21                	jne    800969 <memset+0x39>
		c &= 0xFF;
  800948:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80094c:	89 d0                	mov    %edx,%eax
  80094e:	c1 e0 08             	shl    $0x8,%eax
  800951:	89 d3                	mov    %edx,%ebx
  800953:	c1 e3 18             	shl    $0x18,%ebx
  800956:	89 d6                	mov    %edx,%esi
  800958:	c1 e6 10             	shl    $0x10,%esi
  80095b:	09 f3                	or     %esi,%ebx
  80095d:	09 da                	or     %ebx,%edx
  80095f:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800961:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800964:	fc                   	cld    
  800965:	f3 ab                	rep stos %eax,%es:(%edi)
  800967:	eb 06                	jmp    80096f <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800969:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096c:	fc                   	cld    
  80096d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80096f:	89 f8                	mov    %edi,%eax
  800971:	5b                   	pop    %ebx
  800972:	5e                   	pop    %esi
  800973:	5f                   	pop    %edi
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	57                   	push   %edi
  80097a:	56                   	push   %esi
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800981:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800984:	39 c6                	cmp    %eax,%esi
  800986:	73 32                	jae    8009ba <memmove+0x44>
  800988:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80098b:	39 c2                	cmp    %eax,%edx
  80098d:	76 2b                	jbe    8009ba <memmove+0x44>
		s += n;
		d += n;
  80098f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800992:	89 d6                	mov    %edx,%esi
  800994:	09 fe                	or     %edi,%esi
  800996:	09 ce                	or     %ecx,%esi
  800998:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80099e:	75 0e                	jne    8009ae <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009a0:	83 ef 04             	sub    $0x4,%edi
  8009a3:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009a6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009a9:	fd                   	std    
  8009aa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009ac:	eb 09                	jmp    8009b7 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009ae:	83 ef 01             	sub    $0x1,%edi
  8009b1:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009b4:	fd                   	std    
  8009b5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009b7:	fc                   	cld    
  8009b8:	eb 1a                	jmp    8009d4 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ba:	89 f2                	mov    %esi,%edx
  8009bc:	09 c2                	or     %eax,%edx
  8009be:	09 ca                	or     %ecx,%edx
  8009c0:	f6 c2 03             	test   $0x3,%dl
  8009c3:	75 0a                	jne    8009cf <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009c5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009c8:	89 c7                	mov    %eax,%edi
  8009ca:	fc                   	cld    
  8009cb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009cd:	eb 05                	jmp    8009d4 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009cf:	89 c7                	mov    %eax,%edi
  8009d1:	fc                   	cld    
  8009d2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009d4:	5e                   	pop    %esi
  8009d5:	5f                   	pop    %edi
  8009d6:	5d                   	pop    %ebp
  8009d7:	c3                   	ret    

008009d8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009d8:	55                   	push   %ebp
  8009d9:	89 e5                	mov    %esp,%ebp
  8009db:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009de:	ff 75 10             	push   0x10(%ebp)
  8009e1:	ff 75 0c             	push   0xc(%ebp)
  8009e4:	ff 75 08             	push   0x8(%ebp)
  8009e7:	e8 8a ff ff ff       	call   800976 <memmove>
}
  8009ec:	c9                   	leave  
  8009ed:	c3                   	ret    

008009ee <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	56                   	push   %esi
  8009f2:	53                   	push   %ebx
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f9:	89 c6                	mov    %eax,%esi
  8009fb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009fe:	eb 06                	jmp    800a06 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a00:	83 c0 01             	add    $0x1,%eax
  800a03:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a06:	39 f0                	cmp    %esi,%eax
  800a08:	74 14                	je     800a1e <memcmp+0x30>
		if (*s1 != *s2)
  800a0a:	0f b6 08             	movzbl (%eax),%ecx
  800a0d:	0f b6 1a             	movzbl (%edx),%ebx
  800a10:	38 d9                	cmp    %bl,%cl
  800a12:	74 ec                	je     800a00 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a14:	0f b6 c1             	movzbl %cl,%eax
  800a17:	0f b6 db             	movzbl %bl,%ebx
  800a1a:	29 d8                	sub    %ebx,%eax
  800a1c:	eb 05                	jmp    800a23 <memcmp+0x35>
	}

	return 0;
  800a1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a23:	5b                   	pop    %ebx
  800a24:	5e                   	pop    %esi
  800a25:	5d                   	pop    %ebp
  800a26:	c3                   	ret    

00800a27 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a30:	89 c2                	mov    %eax,%edx
  800a32:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a35:	eb 03                	jmp    800a3a <memfind+0x13>
  800a37:	83 c0 01             	add    $0x1,%eax
  800a3a:	39 d0                	cmp    %edx,%eax
  800a3c:	73 04                	jae    800a42 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a3e:	38 08                	cmp    %cl,(%eax)
  800a40:	75 f5                	jne    800a37 <memfind+0x10>
			break;
	return (void *) s;
}
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	57                   	push   %edi
  800a48:	56                   	push   %esi
  800a49:	53                   	push   %ebx
  800a4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a50:	eb 03                	jmp    800a55 <strtol+0x11>
		s++;
  800a52:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a55:	0f b6 02             	movzbl (%edx),%eax
  800a58:	3c 20                	cmp    $0x20,%al
  800a5a:	74 f6                	je     800a52 <strtol+0xe>
  800a5c:	3c 09                	cmp    $0x9,%al
  800a5e:	74 f2                	je     800a52 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a60:	3c 2b                	cmp    $0x2b,%al
  800a62:	74 2a                	je     800a8e <strtol+0x4a>
	int neg = 0;
  800a64:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a69:	3c 2d                	cmp    $0x2d,%al
  800a6b:	74 2b                	je     800a98 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a6d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a73:	75 0f                	jne    800a84 <strtol+0x40>
  800a75:	80 3a 30             	cmpb   $0x30,(%edx)
  800a78:	74 28                	je     800aa2 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7a:	85 db                	test   %ebx,%ebx
  800a7c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a81:	0f 44 d8             	cmove  %eax,%ebx
  800a84:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a89:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a8c:	eb 46                	jmp    800ad4 <strtol+0x90>
		s++;
  800a8e:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a91:	bf 00 00 00 00       	mov    $0x0,%edi
  800a96:	eb d5                	jmp    800a6d <strtol+0x29>
		s++, neg = 1;
  800a98:	83 c2 01             	add    $0x1,%edx
  800a9b:	bf 01 00 00 00       	mov    $0x1,%edi
  800aa0:	eb cb                	jmp    800a6d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aa2:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800aa6:	74 0e                	je     800ab6 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800aa8:	85 db                	test   %ebx,%ebx
  800aaa:	75 d8                	jne    800a84 <strtol+0x40>
		s++, base = 8;
  800aac:	83 c2 01             	add    $0x1,%edx
  800aaf:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ab4:	eb ce                	jmp    800a84 <strtol+0x40>
		s += 2, base = 16;
  800ab6:	83 c2 02             	add    $0x2,%edx
  800ab9:	bb 10 00 00 00       	mov    $0x10,%ebx
  800abe:	eb c4                	jmp    800a84 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ac0:	0f be c0             	movsbl %al,%eax
  800ac3:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac6:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ac9:	7d 3a                	jge    800b05 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800acb:	83 c2 01             	add    $0x1,%edx
  800ace:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ad2:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ad4:	0f b6 02             	movzbl (%edx),%eax
  800ad7:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ada:	89 f3                	mov    %esi,%ebx
  800adc:	80 fb 09             	cmp    $0x9,%bl
  800adf:	76 df                	jbe    800ac0 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ae1:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ae4:	89 f3                	mov    %esi,%ebx
  800ae6:	80 fb 19             	cmp    $0x19,%bl
  800ae9:	77 08                	ja     800af3 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800aeb:	0f be c0             	movsbl %al,%eax
  800aee:	83 e8 57             	sub    $0x57,%eax
  800af1:	eb d3                	jmp    800ac6 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800af3:	8d 70 bf             	lea    -0x41(%eax),%esi
  800af6:	89 f3                	mov    %esi,%ebx
  800af8:	80 fb 19             	cmp    $0x19,%bl
  800afb:	77 08                	ja     800b05 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800afd:	0f be c0             	movsbl %al,%eax
  800b00:	83 e8 37             	sub    $0x37,%eax
  800b03:	eb c1                	jmp    800ac6 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b05:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b09:	74 05                	je     800b10 <strtol+0xcc>
		*endptr = (char *) s;
  800b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0e:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b10:	89 c8                	mov    %ecx,%eax
  800b12:	f7 d8                	neg    %eax
  800b14:	85 ff                	test   %edi,%edi
  800b16:	0f 45 c8             	cmovne %eax,%ecx
}
  800b19:	89 c8                	mov    %ecx,%eax
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5f                   	pop    %edi
  800b1e:	5d                   	pop    %ebp
  800b1f:	c3                   	ret    

00800b20 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b20:	55                   	push   %ebp
  800b21:	89 e5                	mov    %esp,%ebp
  800b23:	57                   	push   %edi
  800b24:	56                   	push   %esi
  800b25:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b26:	b8 00 00 00 00       	mov    $0x0,%eax
  800b2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b31:	89 c3                	mov    %eax,%ebx
  800b33:	89 c7                	mov    %eax,%edi
  800b35:	89 c6                	mov    %eax,%esi
  800b37:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b39:	5b                   	pop    %ebx
  800b3a:	5e                   	pop    %esi
  800b3b:	5f                   	pop    %edi
  800b3c:	5d                   	pop    %ebp
  800b3d:	c3                   	ret    

00800b3e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	57                   	push   %edi
  800b42:	56                   	push   %esi
  800b43:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4e:	89 d1                	mov    %edx,%ecx
  800b50:	89 d3                	mov    %edx,%ebx
  800b52:	89 d7                	mov    %edx,%edi
  800b54:	89 d6                	mov    %edx,%esi
  800b56:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5f                   	pop    %edi
  800b5b:	5d                   	pop    %ebp
  800b5c:	c3                   	ret    

00800b5d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	57                   	push   %edi
  800b61:	56                   	push   %esi
  800b62:	53                   	push   %ebx
  800b63:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b66:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b6e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b73:	89 cb                	mov    %ecx,%ebx
  800b75:	89 cf                	mov    %ecx,%edi
  800b77:	89 ce                	mov    %ecx,%esi
  800b79:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b7b:	85 c0                	test   %eax,%eax
  800b7d:	7f 08                	jg     800b87 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b82:	5b                   	pop    %ebx
  800b83:	5e                   	pop    %esi
  800b84:	5f                   	pop    %edi
  800b85:	5d                   	pop    %ebp
  800b86:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b87:	83 ec 0c             	sub    $0xc,%esp
  800b8a:	50                   	push   %eax
  800b8b:	6a 03                	push   $0x3
  800b8d:	68 9f 28 80 00       	push   $0x80289f
  800b92:	6a 2a                	push   $0x2a
  800b94:	68 bc 28 80 00       	push   $0x8028bc
  800b99:	e8 00 16 00 00       	call   80219e <_panic>

00800b9e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ba4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba9:	b8 02 00 00 00       	mov    $0x2,%eax
  800bae:	89 d1                	mov    %edx,%ecx
  800bb0:	89 d3                	mov    %edx,%ebx
  800bb2:	89 d7                	mov    %edx,%edi
  800bb4:	89 d6                	mov    %edx,%esi
  800bb6:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_yield>:

void
sys_yield(void)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bc3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bcd:	89 d1                	mov    %edx,%ecx
  800bcf:	89 d3                	mov    %edx,%ebx
  800bd1:	89 d7                	mov    %edx,%edi
  800bd3:	89 d6                	mov    %edx,%esi
  800bd5:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bd7:	5b                   	pop    %ebx
  800bd8:	5e                   	pop    %esi
  800bd9:	5f                   	pop    %edi
  800bda:	5d                   	pop    %ebp
  800bdb:	c3                   	ret    

00800bdc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	57                   	push   %edi
  800be0:	56                   	push   %esi
  800be1:	53                   	push   %ebx
  800be2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800be5:	be 00 00 00 00       	mov    $0x0,%esi
  800bea:	8b 55 08             	mov    0x8(%ebp),%edx
  800bed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf0:	b8 04 00 00 00       	mov    $0x4,%eax
  800bf5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bf8:	89 f7                	mov    %esi,%edi
  800bfa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bfc:	85 c0                	test   %eax,%eax
  800bfe:	7f 08                	jg     800c08 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c08:	83 ec 0c             	sub    $0xc,%esp
  800c0b:	50                   	push   %eax
  800c0c:	6a 04                	push   $0x4
  800c0e:	68 9f 28 80 00       	push   $0x80289f
  800c13:	6a 2a                	push   $0x2a
  800c15:	68 bc 28 80 00       	push   $0x8028bc
  800c1a:	e8 7f 15 00 00       	call   80219e <_panic>

00800c1f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
  800c25:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c28:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c2e:	b8 05 00 00 00       	mov    $0x5,%eax
  800c33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c36:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c39:	8b 75 18             	mov    0x18(%ebp),%esi
  800c3c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	7f 08                	jg     800c4a <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c4a:	83 ec 0c             	sub    $0xc,%esp
  800c4d:	50                   	push   %eax
  800c4e:	6a 05                	push   $0x5
  800c50:	68 9f 28 80 00       	push   $0x80289f
  800c55:	6a 2a                	push   $0x2a
  800c57:	68 bc 28 80 00       	push   $0x8028bc
  800c5c:	e8 3d 15 00 00       	call   80219e <_panic>

00800c61 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c75:	b8 06 00 00 00       	mov    $0x6,%eax
  800c7a:	89 df                	mov    %ebx,%edi
  800c7c:	89 de                	mov    %ebx,%esi
  800c7e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7f 08                	jg     800c8c <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c87:	5b                   	pop    %ebx
  800c88:	5e                   	pop    %esi
  800c89:	5f                   	pop    %edi
  800c8a:	5d                   	pop    %ebp
  800c8b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8c:	83 ec 0c             	sub    $0xc,%esp
  800c8f:	50                   	push   %eax
  800c90:	6a 06                	push   $0x6
  800c92:	68 9f 28 80 00       	push   $0x80289f
  800c97:	6a 2a                	push   $0x2a
  800c99:	68 bc 28 80 00       	push   $0x8028bc
  800c9e:	e8 fb 14 00 00       	call   80219e <_panic>

00800ca3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb1:	8b 55 08             	mov    0x8(%ebp),%edx
  800cb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb7:	b8 08 00 00 00       	mov    $0x8,%eax
  800cbc:	89 df                	mov    %ebx,%edi
  800cbe:	89 de                	mov    %ebx,%esi
  800cc0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	7f 08                	jg     800cce <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc9:	5b                   	pop    %ebx
  800cca:	5e                   	pop    %esi
  800ccb:	5f                   	pop    %edi
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cce:	83 ec 0c             	sub    $0xc,%esp
  800cd1:	50                   	push   %eax
  800cd2:	6a 08                	push   $0x8
  800cd4:	68 9f 28 80 00       	push   $0x80289f
  800cd9:	6a 2a                	push   $0x2a
  800cdb:	68 bc 28 80 00       	push   $0x8028bc
  800ce0:	e8 b9 14 00 00       	call   80219e <_panic>

00800ce5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
  800ceb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf9:	b8 09 00 00 00       	mov    $0x9,%eax
  800cfe:	89 df                	mov    %ebx,%edi
  800d00:	89 de                	mov    %ebx,%esi
  800d02:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d04:	85 c0                	test   %eax,%eax
  800d06:	7f 08                	jg     800d10 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0b:	5b                   	pop    %ebx
  800d0c:	5e                   	pop    %esi
  800d0d:	5f                   	pop    %edi
  800d0e:	5d                   	pop    %ebp
  800d0f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d10:	83 ec 0c             	sub    $0xc,%esp
  800d13:	50                   	push   %eax
  800d14:	6a 09                	push   $0x9
  800d16:	68 9f 28 80 00       	push   $0x80289f
  800d1b:	6a 2a                	push   $0x2a
  800d1d:	68 bc 28 80 00       	push   $0x8028bc
  800d22:	e8 77 14 00 00       	call   80219e <_panic>

00800d27 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	57                   	push   %edi
  800d2b:	56                   	push   %esi
  800d2c:	53                   	push   %ebx
  800d2d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d35:	8b 55 08             	mov    0x8(%ebp),%edx
  800d38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d3b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d40:	89 df                	mov    %ebx,%edi
  800d42:	89 de                	mov    %ebx,%esi
  800d44:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d46:	85 c0                	test   %eax,%eax
  800d48:	7f 08                	jg     800d52 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4d:	5b                   	pop    %ebx
  800d4e:	5e                   	pop    %esi
  800d4f:	5f                   	pop    %edi
  800d50:	5d                   	pop    %ebp
  800d51:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d52:	83 ec 0c             	sub    $0xc,%esp
  800d55:	50                   	push   %eax
  800d56:	6a 0a                	push   $0xa
  800d58:	68 9f 28 80 00       	push   $0x80289f
  800d5d:	6a 2a                	push   $0x2a
  800d5f:	68 bc 28 80 00       	push   $0x8028bc
  800d64:	e8 35 14 00 00       	call   80219e <_panic>

00800d69 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	57                   	push   %edi
  800d6d:	56                   	push   %esi
  800d6e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d75:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d7a:	be 00 00 00 00       	mov    $0x0,%esi
  800d7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d82:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d85:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    

00800d8c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d8c:	55                   	push   %ebp
  800d8d:	89 e5                	mov    %esp,%ebp
  800d8f:	57                   	push   %edi
  800d90:	56                   	push   %esi
  800d91:	53                   	push   %ebx
  800d92:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800da2:	89 cb                	mov    %ecx,%ebx
  800da4:	89 cf                	mov    %ecx,%edi
  800da6:	89 ce                	mov    %ecx,%esi
  800da8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800daa:	85 c0                	test   %eax,%eax
  800dac:	7f 08                	jg     800db6 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
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
  800dba:	6a 0d                	push   $0xd
  800dbc:	68 9f 28 80 00       	push   $0x80289f
  800dc1:	6a 2a                	push   $0x2a
  800dc3:	68 bc 28 80 00       	push   $0x8028bc
  800dc8:	e8 d1 13 00 00       	call   80219e <_panic>

00800dcd <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	57                   	push   %edi
  800dd1:	56                   	push   %esi
  800dd2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ddd:	89 d1                	mov    %edx,%ecx
  800ddf:	89 d3                	mov    %edx,%ebx
  800de1:	89 d7                	mov    %edx,%edi
  800de3:	89 d6                	mov    %edx,%esi
  800de5:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800de7:	5b                   	pop    %ebx
  800de8:	5e                   	pop    %esi
  800de9:	5f                   	pop    %edi
  800dea:	5d                   	pop    %ebp
  800deb:	c3                   	ret    

00800dec <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	57                   	push   %edi
  800df0:	56                   	push   %esi
  800df1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800df2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dfd:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e02:	89 df                	mov    %ebx,%edi
  800e04:	89 de                	mov    %ebx,%esi
  800e06:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800e08:	5b                   	pop    %ebx
  800e09:	5e                   	pop    %esi
  800e0a:	5f                   	pop    %edi
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	57                   	push   %edi
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	8b 55 08             	mov    0x8(%ebp),%edx
  800e1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1e:	b8 10 00 00 00       	mov    $0x10,%eax
  800e23:	89 df                	mov    %ebx,%edi
  800e25:	89 de                	mov    %ebx,%esi
  800e27:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800e29:	5b                   	pop    %ebx
  800e2a:	5e                   	pop    %esi
  800e2b:	5f                   	pop    %edi
  800e2c:	5d                   	pop    %ebp
  800e2d:	c3                   	ret    

00800e2e <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800e2e:	55                   	push   %ebp
  800e2f:	89 e5                	mov    %esp,%ebp
  800e31:	8b 55 08             	mov    0x8(%ebp),%edx
  800e34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e37:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800e3a:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800e3c:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800e3f:	83 3a 01             	cmpl   $0x1,(%edx)
  800e42:	7e 09                	jle    800e4d <argstart+0x1f>
  800e44:	ba 71 25 80 00       	mov    $0x802571,%edx
  800e49:	85 c9                	test   %ecx,%ecx
  800e4b:	75 05                	jne    800e52 <argstart+0x24>
  800e4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e52:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800e55:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800e5c:	5d                   	pop    %ebp
  800e5d:	c3                   	ret    

00800e5e <argnext>:

int
argnext(struct Argstate *args)
{
  800e5e:	55                   	push   %ebp
  800e5f:	89 e5                	mov    %esp,%ebp
  800e61:	53                   	push   %ebx
  800e62:	83 ec 04             	sub    $0x4,%esp
  800e65:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800e68:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800e6f:	8b 43 08             	mov    0x8(%ebx),%eax
  800e72:	85 c0                	test   %eax,%eax
  800e74:	74 74                	je     800eea <argnext+0x8c>
		return -1;

	if (!*args->curarg) {
  800e76:	80 38 00             	cmpb   $0x0,(%eax)
  800e79:	75 48                	jne    800ec3 <argnext+0x65>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800e7b:	8b 0b                	mov    (%ebx),%ecx
  800e7d:	83 39 01             	cmpl   $0x1,(%ecx)
  800e80:	74 5a                	je     800edc <argnext+0x7e>
		    || args->argv[1][0] != '-'
  800e82:	8b 53 04             	mov    0x4(%ebx),%edx
  800e85:	8b 42 04             	mov    0x4(%edx),%eax
  800e88:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e8b:	75 4f                	jne    800edc <argnext+0x7e>
		    || args->argv[1][1] == '\0')
  800e8d:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e91:	74 49                	je     800edc <argnext+0x7e>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800e93:	83 c0 01             	add    $0x1,%eax
  800e96:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e99:	83 ec 04             	sub    $0x4,%esp
  800e9c:	8b 01                	mov    (%ecx),%eax
  800e9e:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800ea5:	50                   	push   %eax
  800ea6:	8d 42 08             	lea    0x8(%edx),%eax
  800ea9:	50                   	push   %eax
  800eaa:	83 c2 04             	add    $0x4,%edx
  800ead:	52                   	push   %edx
  800eae:	e8 c3 fa ff ff       	call   800976 <memmove>
		(*args->argc)--;
  800eb3:	8b 03                	mov    (%ebx),%eax
  800eb5:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800eb8:	8b 43 08             	mov    0x8(%ebx),%eax
  800ebb:	83 c4 10             	add    $0x10,%esp
  800ebe:	80 38 2d             	cmpb   $0x2d,(%eax)
  800ec1:	74 13                	je     800ed6 <argnext+0x78>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800ec3:	8b 43 08             	mov    0x8(%ebx),%eax
  800ec6:	0f b6 10             	movzbl (%eax),%edx
	args->curarg++;
  800ec9:	83 c0 01             	add    $0x1,%eax
  800ecc:	89 43 08             	mov    %eax,0x8(%ebx)
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800ecf:	89 d0                	mov    %edx,%eax
  800ed1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed4:	c9                   	leave  
  800ed5:	c3                   	ret    
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800ed6:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800eda:	75 e7                	jne    800ec3 <argnext+0x65>
	args->curarg = 0;
  800edc:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800ee3:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800ee8:	eb e5                	jmp    800ecf <argnext+0x71>
		return -1;
  800eea:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800eef:	eb de                	jmp    800ecf <argnext+0x71>

00800ef1 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	53                   	push   %ebx
  800ef5:	83 ec 04             	sub    $0x4,%esp
  800ef8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800efb:	8b 43 08             	mov    0x8(%ebx),%eax
  800efe:	85 c0                	test   %eax,%eax
  800f00:	74 12                	je     800f14 <argnextvalue+0x23>
		return 0;
	if (*args->curarg) {
  800f02:	80 38 00             	cmpb   $0x0,(%eax)
  800f05:	74 12                	je     800f19 <argnextvalue+0x28>
		args->argvalue = args->curarg;
  800f07:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800f0a:	c7 43 08 71 25 80 00 	movl   $0x802571,0x8(%ebx)
		(*args->argc)--;
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
  800f11:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  800f14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f17:	c9                   	leave  
  800f18:	c3                   	ret    
	} else if (*args->argc > 1) {
  800f19:	8b 13                	mov    (%ebx),%edx
  800f1b:	83 3a 01             	cmpl   $0x1,(%edx)
  800f1e:	7f 10                	jg     800f30 <argnextvalue+0x3f>
		args->argvalue = 0;
  800f20:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800f27:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  800f2e:	eb e1                	jmp    800f11 <argnextvalue+0x20>
		args->argvalue = args->argv[1];
  800f30:	8b 43 04             	mov    0x4(%ebx),%eax
  800f33:	8b 48 04             	mov    0x4(%eax),%ecx
  800f36:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800f39:	83 ec 04             	sub    $0x4,%esp
  800f3c:	8b 12                	mov    (%edx),%edx
  800f3e:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800f45:	52                   	push   %edx
  800f46:	8d 50 08             	lea    0x8(%eax),%edx
  800f49:	52                   	push   %edx
  800f4a:	83 c0 04             	add    $0x4,%eax
  800f4d:	50                   	push   %eax
  800f4e:	e8 23 fa ff ff       	call   800976 <memmove>
		(*args->argc)--;
  800f53:	8b 03                	mov    (%ebx),%eax
  800f55:	83 28 01             	subl   $0x1,(%eax)
  800f58:	83 c4 10             	add    $0x10,%esp
  800f5b:	eb b4                	jmp    800f11 <argnextvalue+0x20>

00800f5d <argvalue>:
{
  800f5d:	55                   	push   %ebp
  800f5e:	89 e5                	mov    %esp,%ebp
  800f60:	83 ec 08             	sub    $0x8,%esp
  800f63:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f66:	8b 42 0c             	mov    0xc(%edx),%eax
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	74 02                	je     800f6f <argvalue+0x12>
}
  800f6d:	c9                   	leave  
  800f6e:	c3                   	ret    
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f6f:	83 ec 0c             	sub    $0xc,%esp
  800f72:	52                   	push   %edx
  800f73:	e8 79 ff ff ff       	call   800ef1 <argnextvalue>
  800f78:	83 c4 10             	add    $0x10,%esp
  800f7b:	eb f0                	jmp    800f6d <argvalue+0x10>

00800f7d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f80:	8b 45 08             	mov    0x8(%ebp),%eax
  800f83:	05 00 00 00 30       	add    $0x30000000,%eax
  800f88:	c1 e8 0c             	shr    $0xc,%eax
}
  800f8b:	5d                   	pop    %ebp
  800f8c:	c3                   	ret    

00800f8d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f90:	8b 45 08             	mov    0x8(%ebp),%eax
  800f93:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800f98:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f9d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    

00800fa4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800fac:	89 c2                	mov    %eax,%edx
  800fae:	c1 ea 16             	shr    $0x16,%edx
  800fb1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800fb8:	f6 c2 01             	test   $0x1,%dl
  800fbb:	74 29                	je     800fe6 <fd_alloc+0x42>
  800fbd:	89 c2                	mov    %eax,%edx
  800fbf:	c1 ea 0c             	shr    $0xc,%edx
  800fc2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fc9:	f6 c2 01             	test   $0x1,%dl
  800fcc:	74 18                	je     800fe6 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800fce:	05 00 10 00 00       	add    $0x1000,%eax
  800fd3:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800fd8:	75 d2                	jne    800fac <fd_alloc+0x8>
  800fda:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800fdf:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800fe4:	eb 05                	jmp    800feb <fd_alloc+0x47>
			return 0;
  800fe6:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800feb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fee:	89 02                	mov    %eax,(%edx)
}
  800ff0:	89 c8                	mov    %ecx,%eax
  800ff2:	5d                   	pop    %ebp
  800ff3:	c3                   	ret    

00800ff4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ffa:	83 f8 1f             	cmp    $0x1f,%eax
  800ffd:	77 30                	ja     80102f <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fff:	c1 e0 0c             	shl    $0xc,%eax
  801002:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801007:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80100d:	f6 c2 01             	test   $0x1,%dl
  801010:	74 24                	je     801036 <fd_lookup+0x42>
  801012:	89 c2                	mov    %eax,%edx
  801014:	c1 ea 0c             	shr    $0xc,%edx
  801017:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80101e:	f6 c2 01             	test   $0x1,%dl
  801021:	74 1a                	je     80103d <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801023:	8b 55 0c             	mov    0xc(%ebp),%edx
  801026:	89 02                	mov    %eax,(%edx)
	return 0;
  801028:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80102d:	5d                   	pop    %ebp
  80102e:	c3                   	ret    
		return -E_INVAL;
  80102f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801034:	eb f7                	jmp    80102d <fd_lookup+0x39>
		return -E_INVAL;
  801036:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80103b:	eb f0                	jmp    80102d <fd_lookup+0x39>
  80103d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801042:	eb e9                	jmp    80102d <fd_lookup+0x39>

00801044 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	53                   	push   %ebx
  801048:	83 ec 04             	sub    $0x4,%esp
  80104b:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80104e:	b8 00 00 00 00       	mov    $0x0,%eax
  801053:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801058:	39 13                	cmp    %edx,(%ebx)
  80105a:	74 37                	je     801093 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  80105c:	83 c0 01             	add    $0x1,%eax
  80105f:	8b 1c 85 48 29 80 00 	mov    0x802948(,%eax,4),%ebx
  801066:	85 db                	test   %ebx,%ebx
  801068:	75 ee                	jne    801058 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80106a:	a1 00 40 80 00       	mov    0x804000,%eax
  80106f:	8b 40 48             	mov    0x48(%eax),%eax
  801072:	83 ec 04             	sub    $0x4,%esp
  801075:	52                   	push   %edx
  801076:	50                   	push   %eax
  801077:	68 cc 28 80 00       	push   $0x8028cc
  80107c:	e8 85 f1 ff ff       	call   800206 <cprintf>
	*dev = 0;
	return -E_INVAL;
  801081:	83 c4 10             	add    $0x10,%esp
  801084:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801089:	8b 55 0c             	mov    0xc(%ebp),%edx
  80108c:	89 1a                	mov    %ebx,(%edx)
}
  80108e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801091:	c9                   	leave  
  801092:	c3                   	ret    
			return 0;
  801093:	b8 00 00 00 00       	mov    $0x0,%eax
  801098:	eb ef                	jmp    801089 <dev_lookup+0x45>

0080109a <fd_close>:
{
  80109a:	55                   	push   %ebp
  80109b:	89 e5                	mov    %esp,%ebp
  80109d:	57                   	push   %edi
  80109e:	56                   	push   %esi
  80109f:	53                   	push   %ebx
  8010a0:	83 ec 24             	sub    $0x24,%esp
  8010a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8010a6:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010a9:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010ac:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8010ad:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8010b3:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8010b6:	50                   	push   %eax
  8010b7:	e8 38 ff ff ff       	call   800ff4 <fd_lookup>
  8010bc:	89 c3                	mov    %eax,%ebx
  8010be:	83 c4 10             	add    $0x10,%esp
  8010c1:	85 c0                	test   %eax,%eax
  8010c3:	78 05                	js     8010ca <fd_close+0x30>
	    || fd != fd2)
  8010c5:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8010c8:	74 16                	je     8010e0 <fd_close+0x46>
		return (must_exist ? r : 0);
  8010ca:	89 f8                	mov    %edi,%eax
  8010cc:	84 c0                	test   %al,%al
  8010ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d3:	0f 44 d8             	cmove  %eax,%ebx
}
  8010d6:	89 d8                	mov    %ebx,%eax
  8010d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010db:	5b                   	pop    %ebx
  8010dc:	5e                   	pop    %esi
  8010dd:	5f                   	pop    %edi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8010e0:	83 ec 08             	sub    $0x8,%esp
  8010e3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8010e6:	50                   	push   %eax
  8010e7:	ff 36                	push   (%esi)
  8010e9:	e8 56 ff ff ff       	call   801044 <dev_lookup>
  8010ee:	89 c3                	mov    %eax,%ebx
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	85 c0                	test   %eax,%eax
  8010f5:	78 1a                	js     801111 <fd_close+0x77>
		if (dev->dev_close)
  8010f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010fa:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8010fd:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801102:	85 c0                	test   %eax,%eax
  801104:	74 0b                	je     801111 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801106:	83 ec 0c             	sub    $0xc,%esp
  801109:	56                   	push   %esi
  80110a:	ff d0                	call   *%eax
  80110c:	89 c3                	mov    %eax,%ebx
  80110e:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801111:	83 ec 08             	sub    $0x8,%esp
  801114:	56                   	push   %esi
  801115:	6a 00                	push   $0x0
  801117:	e8 45 fb ff ff       	call   800c61 <sys_page_unmap>
	return r;
  80111c:	83 c4 10             	add    $0x10,%esp
  80111f:	eb b5                	jmp    8010d6 <fd_close+0x3c>

00801121 <close>:

int
close(int fdnum)
{
  801121:	55                   	push   %ebp
  801122:	89 e5                	mov    %esp,%ebp
  801124:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801127:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80112a:	50                   	push   %eax
  80112b:	ff 75 08             	push   0x8(%ebp)
  80112e:	e8 c1 fe ff ff       	call   800ff4 <fd_lookup>
  801133:	83 c4 10             	add    $0x10,%esp
  801136:	85 c0                	test   %eax,%eax
  801138:	79 02                	jns    80113c <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80113a:	c9                   	leave  
  80113b:	c3                   	ret    
		return fd_close(fd, 1);
  80113c:	83 ec 08             	sub    $0x8,%esp
  80113f:	6a 01                	push   $0x1
  801141:	ff 75 f4             	push   -0xc(%ebp)
  801144:	e8 51 ff ff ff       	call   80109a <fd_close>
  801149:	83 c4 10             	add    $0x10,%esp
  80114c:	eb ec                	jmp    80113a <close+0x19>

0080114e <close_all>:

void
close_all(void)
{
  80114e:	55                   	push   %ebp
  80114f:	89 e5                	mov    %esp,%ebp
  801151:	53                   	push   %ebx
  801152:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801155:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80115a:	83 ec 0c             	sub    $0xc,%esp
  80115d:	53                   	push   %ebx
  80115e:	e8 be ff ff ff       	call   801121 <close>
	for (i = 0; i < MAXFD; i++)
  801163:	83 c3 01             	add    $0x1,%ebx
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	83 fb 20             	cmp    $0x20,%ebx
  80116c:	75 ec                	jne    80115a <close_all+0xc>
}
  80116e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801171:	c9                   	leave  
  801172:	c3                   	ret    

00801173 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801173:	55                   	push   %ebp
  801174:	89 e5                	mov    %esp,%ebp
  801176:	57                   	push   %edi
  801177:	56                   	push   %esi
  801178:	53                   	push   %ebx
  801179:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80117c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80117f:	50                   	push   %eax
  801180:	ff 75 08             	push   0x8(%ebp)
  801183:	e8 6c fe ff ff       	call   800ff4 <fd_lookup>
  801188:	89 c3                	mov    %eax,%ebx
  80118a:	83 c4 10             	add    $0x10,%esp
  80118d:	85 c0                	test   %eax,%eax
  80118f:	78 7f                	js     801210 <dup+0x9d>
		return r;
	close(newfdnum);
  801191:	83 ec 0c             	sub    $0xc,%esp
  801194:	ff 75 0c             	push   0xc(%ebp)
  801197:	e8 85 ff ff ff       	call   801121 <close>

	newfd = INDEX2FD(newfdnum);
  80119c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80119f:	c1 e6 0c             	shl    $0xc,%esi
  8011a2:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8011a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8011ab:	89 3c 24             	mov    %edi,(%esp)
  8011ae:	e8 da fd ff ff       	call   800f8d <fd2data>
  8011b3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8011b5:	89 34 24             	mov    %esi,(%esp)
  8011b8:	e8 d0 fd ff ff       	call   800f8d <fd2data>
  8011bd:	83 c4 10             	add    $0x10,%esp
  8011c0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8011c3:	89 d8                	mov    %ebx,%eax
  8011c5:	c1 e8 16             	shr    $0x16,%eax
  8011c8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8011cf:	a8 01                	test   $0x1,%al
  8011d1:	74 11                	je     8011e4 <dup+0x71>
  8011d3:	89 d8                	mov    %ebx,%eax
  8011d5:	c1 e8 0c             	shr    $0xc,%eax
  8011d8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8011df:	f6 c2 01             	test   $0x1,%dl
  8011e2:	75 36                	jne    80121a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8011e4:	89 f8                	mov    %edi,%eax
  8011e6:	c1 e8 0c             	shr    $0xc,%eax
  8011e9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011f0:	83 ec 0c             	sub    $0xc,%esp
  8011f3:	25 07 0e 00 00       	and    $0xe07,%eax
  8011f8:	50                   	push   %eax
  8011f9:	56                   	push   %esi
  8011fa:	6a 00                	push   $0x0
  8011fc:	57                   	push   %edi
  8011fd:	6a 00                	push   $0x0
  8011ff:	e8 1b fa ff ff       	call   800c1f <sys_page_map>
  801204:	89 c3                	mov    %eax,%ebx
  801206:	83 c4 20             	add    $0x20,%esp
  801209:	85 c0                	test   %eax,%eax
  80120b:	78 33                	js     801240 <dup+0xcd>
		goto err;

	return newfdnum;
  80120d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801210:	89 d8                	mov    %ebx,%eax
  801212:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801215:	5b                   	pop    %ebx
  801216:	5e                   	pop    %esi
  801217:	5f                   	pop    %edi
  801218:	5d                   	pop    %ebp
  801219:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80121a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801221:	83 ec 0c             	sub    $0xc,%esp
  801224:	25 07 0e 00 00       	and    $0xe07,%eax
  801229:	50                   	push   %eax
  80122a:	ff 75 d4             	push   -0x2c(%ebp)
  80122d:	6a 00                	push   $0x0
  80122f:	53                   	push   %ebx
  801230:	6a 00                	push   $0x0
  801232:	e8 e8 f9 ff ff       	call   800c1f <sys_page_map>
  801237:	89 c3                	mov    %eax,%ebx
  801239:	83 c4 20             	add    $0x20,%esp
  80123c:	85 c0                	test   %eax,%eax
  80123e:	79 a4                	jns    8011e4 <dup+0x71>
	sys_page_unmap(0, newfd);
  801240:	83 ec 08             	sub    $0x8,%esp
  801243:	56                   	push   %esi
  801244:	6a 00                	push   $0x0
  801246:	e8 16 fa ff ff       	call   800c61 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80124b:	83 c4 08             	add    $0x8,%esp
  80124e:	ff 75 d4             	push   -0x2c(%ebp)
  801251:	6a 00                	push   $0x0
  801253:	e8 09 fa ff ff       	call   800c61 <sys_page_unmap>
	return r;
  801258:	83 c4 10             	add    $0x10,%esp
  80125b:	eb b3                	jmp    801210 <dup+0x9d>

0080125d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	56                   	push   %esi
  801261:	53                   	push   %ebx
  801262:	83 ec 18             	sub    $0x18,%esp
  801265:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801268:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126b:	50                   	push   %eax
  80126c:	56                   	push   %esi
  80126d:	e8 82 fd ff ff       	call   800ff4 <fd_lookup>
  801272:	83 c4 10             	add    $0x10,%esp
  801275:	85 c0                	test   %eax,%eax
  801277:	78 3c                	js     8012b5 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801279:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80127c:	83 ec 08             	sub    $0x8,%esp
  80127f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801282:	50                   	push   %eax
  801283:	ff 33                	push   (%ebx)
  801285:	e8 ba fd ff ff       	call   801044 <dev_lookup>
  80128a:	83 c4 10             	add    $0x10,%esp
  80128d:	85 c0                	test   %eax,%eax
  80128f:	78 24                	js     8012b5 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801291:	8b 43 08             	mov    0x8(%ebx),%eax
  801294:	83 e0 03             	and    $0x3,%eax
  801297:	83 f8 01             	cmp    $0x1,%eax
  80129a:	74 20                	je     8012bc <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80129c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129f:	8b 40 08             	mov    0x8(%eax),%eax
  8012a2:	85 c0                	test   %eax,%eax
  8012a4:	74 37                	je     8012dd <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8012a6:	83 ec 04             	sub    $0x4,%esp
  8012a9:	ff 75 10             	push   0x10(%ebp)
  8012ac:	ff 75 0c             	push   0xc(%ebp)
  8012af:	53                   	push   %ebx
  8012b0:	ff d0                	call   *%eax
  8012b2:	83 c4 10             	add    $0x10,%esp
}
  8012b5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012b8:	5b                   	pop    %ebx
  8012b9:	5e                   	pop    %esi
  8012ba:	5d                   	pop    %ebp
  8012bb:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8012bc:	a1 00 40 80 00       	mov    0x804000,%eax
  8012c1:	8b 40 48             	mov    0x48(%eax),%eax
  8012c4:	83 ec 04             	sub    $0x4,%esp
  8012c7:	56                   	push   %esi
  8012c8:	50                   	push   %eax
  8012c9:	68 0d 29 80 00       	push   $0x80290d
  8012ce:	e8 33 ef ff ff       	call   800206 <cprintf>
		return -E_INVAL;
  8012d3:	83 c4 10             	add    $0x10,%esp
  8012d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012db:	eb d8                	jmp    8012b5 <read+0x58>
		return -E_NOT_SUPP;
  8012dd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012e2:	eb d1                	jmp    8012b5 <read+0x58>

008012e4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8012e4:	55                   	push   %ebp
  8012e5:	89 e5                	mov    %esp,%ebp
  8012e7:	57                   	push   %edi
  8012e8:	56                   	push   %esi
  8012e9:	53                   	push   %ebx
  8012ea:	83 ec 0c             	sub    $0xc,%esp
  8012ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012f0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012f3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012f8:	eb 02                	jmp    8012fc <readn+0x18>
  8012fa:	01 c3                	add    %eax,%ebx
  8012fc:	39 f3                	cmp    %esi,%ebx
  8012fe:	73 21                	jae    801321 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801300:	83 ec 04             	sub    $0x4,%esp
  801303:	89 f0                	mov    %esi,%eax
  801305:	29 d8                	sub    %ebx,%eax
  801307:	50                   	push   %eax
  801308:	89 d8                	mov    %ebx,%eax
  80130a:	03 45 0c             	add    0xc(%ebp),%eax
  80130d:	50                   	push   %eax
  80130e:	57                   	push   %edi
  80130f:	e8 49 ff ff ff       	call   80125d <read>
		if (m < 0)
  801314:	83 c4 10             	add    $0x10,%esp
  801317:	85 c0                	test   %eax,%eax
  801319:	78 04                	js     80131f <readn+0x3b>
			return m;
		if (m == 0)
  80131b:	75 dd                	jne    8012fa <readn+0x16>
  80131d:	eb 02                	jmp    801321 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80131f:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801321:	89 d8                	mov    %ebx,%eax
  801323:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801326:	5b                   	pop    %ebx
  801327:	5e                   	pop    %esi
  801328:	5f                   	pop    %edi
  801329:	5d                   	pop    %ebp
  80132a:	c3                   	ret    

0080132b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80132b:	55                   	push   %ebp
  80132c:	89 e5                	mov    %esp,%ebp
  80132e:	56                   	push   %esi
  80132f:	53                   	push   %ebx
  801330:	83 ec 18             	sub    $0x18,%esp
  801333:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801336:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801339:	50                   	push   %eax
  80133a:	53                   	push   %ebx
  80133b:	e8 b4 fc ff ff       	call   800ff4 <fd_lookup>
  801340:	83 c4 10             	add    $0x10,%esp
  801343:	85 c0                	test   %eax,%eax
  801345:	78 37                	js     80137e <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801347:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80134a:	83 ec 08             	sub    $0x8,%esp
  80134d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801350:	50                   	push   %eax
  801351:	ff 36                	push   (%esi)
  801353:	e8 ec fc ff ff       	call   801044 <dev_lookup>
  801358:	83 c4 10             	add    $0x10,%esp
  80135b:	85 c0                	test   %eax,%eax
  80135d:	78 1f                	js     80137e <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80135f:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801363:	74 20                	je     801385 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801365:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801368:	8b 40 0c             	mov    0xc(%eax),%eax
  80136b:	85 c0                	test   %eax,%eax
  80136d:	74 37                	je     8013a6 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80136f:	83 ec 04             	sub    $0x4,%esp
  801372:	ff 75 10             	push   0x10(%ebp)
  801375:	ff 75 0c             	push   0xc(%ebp)
  801378:	56                   	push   %esi
  801379:	ff d0                	call   *%eax
  80137b:	83 c4 10             	add    $0x10,%esp
}
  80137e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801381:	5b                   	pop    %ebx
  801382:	5e                   	pop    %esi
  801383:	5d                   	pop    %ebp
  801384:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801385:	a1 00 40 80 00       	mov    0x804000,%eax
  80138a:	8b 40 48             	mov    0x48(%eax),%eax
  80138d:	83 ec 04             	sub    $0x4,%esp
  801390:	53                   	push   %ebx
  801391:	50                   	push   %eax
  801392:	68 29 29 80 00       	push   $0x802929
  801397:	e8 6a ee ff ff       	call   800206 <cprintf>
		return -E_INVAL;
  80139c:	83 c4 10             	add    $0x10,%esp
  80139f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013a4:	eb d8                	jmp    80137e <write+0x53>
		return -E_NOT_SUPP;
  8013a6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013ab:	eb d1                	jmp    80137e <write+0x53>

008013ad <seek>:

int
seek(int fdnum, off_t offset)
{
  8013ad:	55                   	push   %ebp
  8013ae:	89 e5                	mov    %esp,%ebp
  8013b0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8013b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b6:	50                   	push   %eax
  8013b7:	ff 75 08             	push   0x8(%ebp)
  8013ba:	e8 35 fc ff ff       	call   800ff4 <fd_lookup>
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	78 0e                	js     8013d4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8013c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8013cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013d4:	c9                   	leave  
  8013d5:	c3                   	ret    

008013d6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8013d6:	55                   	push   %ebp
  8013d7:	89 e5                	mov    %esp,%ebp
  8013d9:	56                   	push   %esi
  8013da:	53                   	push   %ebx
  8013db:	83 ec 18             	sub    $0x18,%esp
  8013de:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e4:	50                   	push   %eax
  8013e5:	53                   	push   %ebx
  8013e6:	e8 09 fc ff ff       	call   800ff4 <fd_lookup>
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	85 c0                	test   %eax,%eax
  8013f0:	78 34                	js     801426 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fb:	50                   	push   %eax
  8013fc:	ff 36                	push   (%esi)
  8013fe:	e8 41 fc ff ff       	call   801044 <dev_lookup>
  801403:	83 c4 10             	add    $0x10,%esp
  801406:	85 c0                	test   %eax,%eax
  801408:	78 1c                	js     801426 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80140a:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80140e:	74 1d                	je     80142d <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801410:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801413:	8b 40 18             	mov    0x18(%eax),%eax
  801416:	85 c0                	test   %eax,%eax
  801418:	74 34                	je     80144e <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80141a:	83 ec 08             	sub    $0x8,%esp
  80141d:	ff 75 0c             	push   0xc(%ebp)
  801420:	56                   	push   %esi
  801421:	ff d0                	call   *%eax
  801423:	83 c4 10             	add    $0x10,%esp
}
  801426:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801429:	5b                   	pop    %ebx
  80142a:	5e                   	pop    %esi
  80142b:	5d                   	pop    %ebp
  80142c:	c3                   	ret    
			thisenv->env_id, fdnum);
  80142d:	a1 00 40 80 00       	mov    0x804000,%eax
  801432:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801435:	83 ec 04             	sub    $0x4,%esp
  801438:	53                   	push   %ebx
  801439:	50                   	push   %eax
  80143a:	68 ec 28 80 00       	push   $0x8028ec
  80143f:	e8 c2 ed ff ff       	call   800206 <cprintf>
		return -E_INVAL;
  801444:	83 c4 10             	add    $0x10,%esp
  801447:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80144c:	eb d8                	jmp    801426 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80144e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801453:	eb d1                	jmp    801426 <ftruncate+0x50>

00801455 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	56                   	push   %esi
  801459:	53                   	push   %ebx
  80145a:	83 ec 18             	sub    $0x18,%esp
  80145d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801460:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801463:	50                   	push   %eax
  801464:	ff 75 08             	push   0x8(%ebp)
  801467:	e8 88 fb ff ff       	call   800ff4 <fd_lookup>
  80146c:	83 c4 10             	add    $0x10,%esp
  80146f:	85 c0                	test   %eax,%eax
  801471:	78 49                	js     8014bc <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801473:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801476:	83 ec 08             	sub    $0x8,%esp
  801479:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147c:	50                   	push   %eax
  80147d:	ff 36                	push   (%esi)
  80147f:	e8 c0 fb ff ff       	call   801044 <dev_lookup>
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	85 c0                	test   %eax,%eax
  801489:	78 31                	js     8014bc <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80148b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80148e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801492:	74 2f                	je     8014c3 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801494:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801497:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80149e:	00 00 00 
	stat->st_isdir = 0;
  8014a1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8014a8:	00 00 00 
	stat->st_dev = dev;
  8014ab:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8014b1:	83 ec 08             	sub    $0x8,%esp
  8014b4:	53                   	push   %ebx
  8014b5:	56                   	push   %esi
  8014b6:	ff 50 14             	call   *0x14(%eax)
  8014b9:	83 c4 10             	add    $0x10,%esp
}
  8014bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014bf:	5b                   	pop    %ebx
  8014c0:	5e                   	pop    %esi
  8014c1:	5d                   	pop    %ebp
  8014c2:	c3                   	ret    
		return -E_NOT_SUPP;
  8014c3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014c8:	eb f2                	jmp    8014bc <fstat+0x67>

008014ca <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	56                   	push   %esi
  8014ce:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014cf:	83 ec 08             	sub    $0x8,%esp
  8014d2:	6a 00                	push   $0x0
  8014d4:	ff 75 08             	push   0x8(%ebp)
  8014d7:	e8 e4 01 00 00       	call   8016c0 <open>
  8014dc:	89 c3                	mov    %eax,%ebx
  8014de:	83 c4 10             	add    $0x10,%esp
  8014e1:	85 c0                	test   %eax,%eax
  8014e3:	78 1b                	js     801500 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8014e5:	83 ec 08             	sub    $0x8,%esp
  8014e8:	ff 75 0c             	push   0xc(%ebp)
  8014eb:	50                   	push   %eax
  8014ec:	e8 64 ff ff ff       	call   801455 <fstat>
  8014f1:	89 c6                	mov    %eax,%esi
	close(fd);
  8014f3:	89 1c 24             	mov    %ebx,(%esp)
  8014f6:	e8 26 fc ff ff       	call   801121 <close>
	return r;
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	89 f3                	mov    %esi,%ebx
}
  801500:	89 d8                	mov    %ebx,%eax
  801502:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801505:	5b                   	pop    %ebx
  801506:	5e                   	pop    %esi
  801507:	5d                   	pop    %ebp
  801508:	c3                   	ret    

00801509 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801509:	55                   	push   %ebp
  80150a:	89 e5                	mov    %esp,%ebp
  80150c:	56                   	push   %esi
  80150d:	53                   	push   %ebx
  80150e:	89 c6                	mov    %eax,%esi
  801510:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801512:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801519:	74 27                	je     801542 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80151b:	6a 07                	push   $0x7
  80151d:	68 00 50 80 00       	push   $0x805000
  801522:	56                   	push   %esi
  801523:	ff 35 00 60 80 00    	push   0x806000
  801529:	e8 1d 0d 00 00       	call   80224b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80152e:	83 c4 0c             	add    $0xc,%esp
  801531:	6a 00                	push   $0x0
  801533:	53                   	push   %ebx
  801534:	6a 00                	push   $0x0
  801536:	e8 a9 0c 00 00       	call   8021e4 <ipc_recv>
}
  80153b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80153e:	5b                   	pop    %ebx
  80153f:	5e                   	pop    %esi
  801540:	5d                   	pop    %ebp
  801541:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801542:	83 ec 0c             	sub    $0xc,%esp
  801545:	6a 01                	push   $0x1
  801547:	e8 53 0d 00 00       	call   80229f <ipc_find_env>
  80154c:	a3 00 60 80 00       	mov    %eax,0x806000
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	eb c5                	jmp    80151b <fsipc+0x12>

00801556 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80155c:	8b 45 08             	mov    0x8(%ebp),%eax
  80155f:	8b 40 0c             	mov    0xc(%eax),%eax
  801562:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801567:	8b 45 0c             	mov    0xc(%ebp),%eax
  80156a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80156f:	ba 00 00 00 00       	mov    $0x0,%edx
  801574:	b8 02 00 00 00       	mov    $0x2,%eax
  801579:	e8 8b ff ff ff       	call   801509 <fsipc>
}
  80157e:	c9                   	leave  
  80157f:	c3                   	ret    

00801580 <devfile_flush>:
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801586:	8b 45 08             	mov    0x8(%ebp),%eax
  801589:	8b 40 0c             	mov    0xc(%eax),%eax
  80158c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801591:	ba 00 00 00 00       	mov    $0x0,%edx
  801596:	b8 06 00 00 00       	mov    $0x6,%eax
  80159b:	e8 69 ff ff ff       	call   801509 <fsipc>
}
  8015a0:	c9                   	leave  
  8015a1:	c3                   	ret    

008015a2 <devfile_stat>:
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	53                   	push   %ebx
  8015a6:	83 ec 04             	sub    $0x4,%esp
  8015a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8015ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8015af:	8b 40 0c             	mov    0xc(%eax),%eax
  8015b2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8015b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8015c1:	e8 43 ff ff ff       	call   801509 <fsipc>
  8015c6:	85 c0                	test   %eax,%eax
  8015c8:	78 2c                	js     8015f6 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8015ca:	83 ec 08             	sub    $0x8,%esp
  8015cd:	68 00 50 80 00       	push   $0x805000
  8015d2:	53                   	push   %ebx
  8015d3:	e8 08 f2 ff ff       	call   8007e0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8015d8:	a1 80 50 80 00       	mov    0x805080,%eax
  8015dd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8015e3:	a1 84 50 80 00       	mov    0x805084,%eax
  8015e8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015ee:	83 c4 10             	add    $0x10,%esp
  8015f1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015f9:	c9                   	leave  
  8015fa:	c3                   	ret    

008015fb <devfile_write>:
{
  8015fb:	55                   	push   %ebp
  8015fc:	89 e5                	mov    %esp,%ebp
  8015fe:	83 ec 0c             	sub    $0xc,%esp
  801601:	8b 45 10             	mov    0x10(%ebp),%eax
  801604:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801609:	39 d0                	cmp    %edx,%eax
  80160b:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80160e:	8b 55 08             	mov    0x8(%ebp),%edx
  801611:	8b 52 0c             	mov    0xc(%edx),%edx
  801614:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80161a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80161f:	50                   	push   %eax
  801620:	ff 75 0c             	push   0xc(%ebp)
  801623:	68 08 50 80 00       	push   $0x805008
  801628:	e8 49 f3 ff ff       	call   800976 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80162d:	ba 00 00 00 00       	mov    $0x0,%edx
  801632:	b8 04 00 00 00       	mov    $0x4,%eax
  801637:	e8 cd fe ff ff       	call   801509 <fsipc>
}
  80163c:	c9                   	leave  
  80163d:	c3                   	ret    

0080163e <devfile_read>:
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	56                   	push   %esi
  801642:	53                   	push   %ebx
  801643:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801646:	8b 45 08             	mov    0x8(%ebp),%eax
  801649:	8b 40 0c             	mov    0xc(%eax),%eax
  80164c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801651:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801657:	ba 00 00 00 00       	mov    $0x0,%edx
  80165c:	b8 03 00 00 00       	mov    $0x3,%eax
  801661:	e8 a3 fe ff ff       	call   801509 <fsipc>
  801666:	89 c3                	mov    %eax,%ebx
  801668:	85 c0                	test   %eax,%eax
  80166a:	78 1f                	js     80168b <devfile_read+0x4d>
	assert(r <= n);
  80166c:	39 f0                	cmp    %esi,%eax
  80166e:	77 24                	ja     801694 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801670:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801675:	7f 33                	jg     8016aa <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801677:	83 ec 04             	sub    $0x4,%esp
  80167a:	50                   	push   %eax
  80167b:	68 00 50 80 00       	push   $0x805000
  801680:	ff 75 0c             	push   0xc(%ebp)
  801683:	e8 ee f2 ff ff       	call   800976 <memmove>
	return r;
  801688:	83 c4 10             	add    $0x10,%esp
}
  80168b:	89 d8                	mov    %ebx,%eax
  80168d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801690:	5b                   	pop    %ebx
  801691:	5e                   	pop    %esi
  801692:	5d                   	pop    %ebp
  801693:	c3                   	ret    
	assert(r <= n);
  801694:	68 5c 29 80 00       	push   $0x80295c
  801699:	68 63 29 80 00       	push   $0x802963
  80169e:	6a 7c                	push   $0x7c
  8016a0:	68 78 29 80 00       	push   $0x802978
  8016a5:	e8 f4 0a 00 00       	call   80219e <_panic>
	assert(r <= PGSIZE);
  8016aa:	68 83 29 80 00       	push   $0x802983
  8016af:	68 63 29 80 00       	push   $0x802963
  8016b4:	6a 7d                	push   $0x7d
  8016b6:	68 78 29 80 00       	push   $0x802978
  8016bb:	e8 de 0a 00 00       	call   80219e <_panic>

008016c0 <open>:
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	56                   	push   %esi
  8016c4:	53                   	push   %ebx
  8016c5:	83 ec 1c             	sub    $0x1c,%esp
  8016c8:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8016cb:	56                   	push   %esi
  8016cc:	e8 d4 f0 ff ff       	call   8007a5 <strlen>
  8016d1:	83 c4 10             	add    $0x10,%esp
  8016d4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8016d9:	7f 6c                	jg     801747 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8016db:	83 ec 0c             	sub    $0xc,%esp
  8016de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016e1:	50                   	push   %eax
  8016e2:	e8 bd f8 ff ff       	call   800fa4 <fd_alloc>
  8016e7:	89 c3                	mov    %eax,%ebx
  8016e9:	83 c4 10             	add    $0x10,%esp
  8016ec:	85 c0                	test   %eax,%eax
  8016ee:	78 3c                	js     80172c <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8016f0:	83 ec 08             	sub    $0x8,%esp
  8016f3:	56                   	push   %esi
  8016f4:	68 00 50 80 00       	push   $0x805000
  8016f9:	e8 e2 f0 ff ff       	call   8007e0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016fe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801701:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801706:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801709:	b8 01 00 00 00       	mov    $0x1,%eax
  80170e:	e8 f6 fd ff ff       	call   801509 <fsipc>
  801713:	89 c3                	mov    %eax,%ebx
  801715:	83 c4 10             	add    $0x10,%esp
  801718:	85 c0                	test   %eax,%eax
  80171a:	78 19                	js     801735 <open+0x75>
	return fd2num(fd);
  80171c:	83 ec 0c             	sub    $0xc,%esp
  80171f:	ff 75 f4             	push   -0xc(%ebp)
  801722:	e8 56 f8 ff ff       	call   800f7d <fd2num>
  801727:	89 c3                	mov    %eax,%ebx
  801729:	83 c4 10             	add    $0x10,%esp
}
  80172c:	89 d8                	mov    %ebx,%eax
  80172e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801731:	5b                   	pop    %ebx
  801732:	5e                   	pop    %esi
  801733:	5d                   	pop    %ebp
  801734:	c3                   	ret    
		fd_close(fd, 0);
  801735:	83 ec 08             	sub    $0x8,%esp
  801738:	6a 00                	push   $0x0
  80173a:	ff 75 f4             	push   -0xc(%ebp)
  80173d:	e8 58 f9 ff ff       	call   80109a <fd_close>
		return r;
  801742:	83 c4 10             	add    $0x10,%esp
  801745:	eb e5                	jmp    80172c <open+0x6c>
		return -E_BAD_PATH;
  801747:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80174c:	eb de                	jmp    80172c <open+0x6c>

0080174e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801754:	ba 00 00 00 00       	mov    $0x0,%edx
  801759:	b8 08 00 00 00       	mov    $0x8,%eax
  80175e:	e8 a6 fd ff ff       	call   801509 <fsipc>
}
  801763:	c9                   	leave  
  801764:	c3                   	ret    

00801765 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801765:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801769:	7f 01                	jg     80176c <writebuf+0x7>
  80176b:	c3                   	ret    
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	53                   	push   %ebx
  801770:	83 ec 08             	sub    $0x8,%esp
  801773:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  801775:	ff 70 04             	push   0x4(%eax)
  801778:	8d 40 10             	lea    0x10(%eax),%eax
  80177b:	50                   	push   %eax
  80177c:	ff 33                	push   (%ebx)
  80177e:	e8 a8 fb ff ff       	call   80132b <write>
		if (result > 0)
  801783:	83 c4 10             	add    $0x10,%esp
  801786:	85 c0                	test   %eax,%eax
  801788:	7e 03                	jle    80178d <writebuf+0x28>
			b->result += result;
  80178a:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80178d:	39 43 04             	cmp    %eax,0x4(%ebx)
  801790:	74 0d                	je     80179f <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  801792:	85 c0                	test   %eax,%eax
  801794:	ba 00 00 00 00       	mov    $0x0,%edx
  801799:	0f 4f c2             	cmovg  %edx,%eax
  80179c:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80179f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a2:	c9                   	leave  
  8017a3:	c3                   	ret    

008017a4 <putch>:

static void
putch(int ch, void *thunk)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	53                   	push   %ebx
  8017a8:	83 ec 04             	sub    $0x4,%esp
  8017ab:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8017ae:	8b 53 04             	mov    0x4(%ebx),%edx
  8017b1:	8d 42 01             	lea    0x1(%edx),%eax
  8017b4:	89 43 04             	mov    %eax,0x4(%ebx)
  8017b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ba:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8017be:	3d 00 01 00 00       	cmp    $0x100,%eax
  8017c3:	74 05                	je     8017ca <putch+0x26>
		writebuf(b);
		b->idx = 0;
	}
}
  8017c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017c8:	c9                   	leave  
  8017c9:	c3                   	ret    
		writebuf(b);
  8017ca:	89 d8                	mov    %ebx,%eax
  8017cc:	e8 94 ff ff ff       	call   801765 <writebuf>
		b->idx = 0;
  8017d1:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  8017d8:	eb eb                	jmp    8017c5 <putch+0x21>

008017da <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8017e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e6:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8017ec:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8017f3:	00 00 00 
	b.result = 0;
  8017f6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8017fd:	00 00 00 
	b.error = 1;
  801800:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  801807:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80180a:	ff 75 10             	push   0x10(%ebp)
  80180d:	ff 75 0c             	push   0xc(%ebp)
  801810:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801816:	50                   	push   %eax
  801817:	68 a4 17 80 00       	push   $0x8017a4
  80181c:	e8 dc ea ff ff       	call   8002fd <vprintfmt>
	if (b.idx > 0)
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80182b:	7f 11                	jg     80183e <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  80182d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801833:	85 c0                	test   %eax,%eax
  801835:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80183c:	c9                   	leave  
  80183d:	c3                   	ret    
		writebuf(&b);
  80183e:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  801844:	e8 1c ff ff ff       	call   801765 <writebuf>
  801849:	eb e2                	jmp    80182d <vfprintf+0x53>

0080184b <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80184b:	55                   	push   %ebp
  80184c:	89 e5                	mov    %esp,%ebp
  80184e:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801851:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801854:	50                   	push   %eax
  801855:	ff 75 0c             	push   0xc(%ebp)
  801858:	ff 75 08             	push   0x8(%ebp)
  80185b:	e8 7a ff ff ff       	call   8017da <vfprintf>
	va_end(ap);

	return cnt;
}
  801860:	c9                   	leave  
  801861:	c3                   	ret    

00801862 <printf>:

int
printf(const char *fmt, ...)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801868:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80186b:	50                   	push   %eax
  80186c:	ff 75 08             	push   0x8(%ebp)
  80186f:	6a 01                	push   $0x1
  801871:	e8 64 ff ff ff       	call   8017da <vfprintf>
	va_end(ap);

	return cnt;
}
  801876:	c9                   	leave  
  801877:	c3                   	ret    

00801878 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80187e:	68 8f 29 80 00       	push   $0x80298f
  801883:	ff 75 0c             	push   0xc(%ebp)
  801886:	e8 55 ef ff ff       	call   8007e0 <strcpy>
	return 0;
}
  80188b:	b8 00 00 00 00       	mov    $0x0,%eax
  801890:	c9                   	leave  
  801891:	c3                   	ret    

00801892 <devsock_close>:
{
  801892:	55                   	push   %ebp
  801893:	89 e5                	mov    %esp,%ebp
  801895:	53                   	push   %ebx
  801896:	83 ec 10             	sub    $0x10,%esp
  801899:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80189c:	53                   	push   %ebx
  80189d:	e8 36 0a 00 00       	call   8022d8 <pageref>
  8018a2:	89 c2                	mov    %eax,%edx
  8018a4:	83 c4 10             	add    $0x10,%esp
		return 0;
  8018a7:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8018ac:	83 fa 01             	cmp    $0x1,%edx
  8018af:	74 05                	je     8018b6 <devsock_close+0x24>
}
  8018b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018b4:	c9                   	leave  
  8018b5:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8018b6:	83 ec 0c             	sub    $0xc,%esp
  8018b9:	ff 73 0c             	push   0xc(%ebx)
  8018bc:	e8 b7 02 00 00       	call   801b78 <nsipc_close>
  8018c1:	83 c4 10             	add    $0x10,%esp
  8018c4:	eb eb                	jmp    8018b1 <devsock_close+0x1f>

008018c6 <devsock_write>:
{
  8018c6:	55                   	push   %ebp
  8018c7:	89 e5                	mov    %esp,%ebp
  8018c9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8018cc:	6a 00                	push   $0x0
  8018ce:	ff 75 10             	push   0x10(%ebp)
  8018d1:	ff 75 0c             	push   0xc(%ebp)
  8018d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d7:	ff 70 0c             	push   0xc(%eax)
  8018da:	e8 79 03 00 00       	call   801c58 <nsipc_send>
}
  8018df:	c9                   	leave  
  8018e0:	c3                   	ret    

008018e1 <devsock_read>:
{
  8018e1:	55                   	push   %ebp
  8018e2:	89 e5                	mov    %esp,%ebp
  8018e4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018e7:	6a 00                	push   $0x0
  8018e9:	ff 75 10             	push   0x10(%ebp)
  8018ec:	ff 75 0c             	push   0xc(%ebp)
  8018ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f2:	ff 70 0c             	push   0xc(%eax)
  8018f5:	e8 ef 02 00 00       	call   801be9 <nsipc_recv>
}
  8018fa:	c9                   	leave  
  8018fb:	c3                   	ret    

008018fc <fd2sockid>:
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801902:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801905:	52                   	push   %edx
  801906:	50                   	push   %eax
  801907:	e8 e8 f6 ff ff       	call   800ff4 <fd_lookup>
  80190c:	83 c4 10             	add    $0x10,%esp
  80190f:	85 c0                	test   %eax,%eax
  801911:	78 10                	js     801923 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801913:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801916:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80191c:	39 08                	cmp    %ecx,(%eax)
  80191e:	75 05                	jne    801925 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801920:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801923:	c9                   	leave  
  801924:	c3                   	ret    
		return -E_NOT_SUPP;
  801925:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80192a:	eb f7                	jmp    801923 <fd2sockid+0x27>

0080192c <alloc_sockfd>:
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	56                   	push   %esi
  801930:	53                   	push   %ebx
  801931:	83 ec 1c             	sub    $0x1c,%esp
  801934:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801936:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801939:	50                   	push   %eax
  80193a:	e8 65 f6 ff ff       	call   800fa4 <fd_alloc>
  80193f:	89 c3                	mov    %eax,%ebx
  801941:	83 c4 10             	add    $0x10,%esp
  801944:	85 c0                	test   %eax,%eax
  801946:	78 43                	js     80198b <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801948:	83 ec 04             	sub    $0x4,%esp
  80194b:	68 07 04 00 00       	push   $0x407
  801950:	ff 75 f4             	push   -0xc(%ebp)
  801953:	6a 00                	push   $0x0
  801955:	e8 82 f2 ff ff       	call   800bdc <sys_page_alloc>
  80195a:	89 c3                	mov    %eax,%ebx
  80195c:	83 c4 10             	add    $0x10,%esp
  80195f:	85 c0                	test   %eax,%eax
  801961:	78 28                	js     80198b <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801963:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801966:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80196c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80196e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801971:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801978:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80197b:	83 ec 0c             	sub    $0xc,%esp
  80197e:	50                   	push   %eax
  80197f:	e8 f9 f5 ff ff       	call   800f7d <fd2num>
  801984:	89 c3                	mov    %eax,%ebx
  801986:	83 c4 10             	add    $0x10,%esp
  801989:	eb 0c                	jmp    801997 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  80198b:	83 ec 0c             	sub    $0xc,%esp
  80198e:	56                   	push   %esi
  80198f:	e8 e4 01 00 00       	call   801b78 <nsipc_close>
		return r;
  801994:	83 c4 10             	add    $0x10,%esp
}
  801997:	89 d8                	mov    %ebx,%eax
  801999:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199c:	5b                   	pop    %ebx
  80199d:	5e                   	pop    %esi
  80199e:	5d                   	pop    %ebp
  80199f:	c3                   	ret    

008019a0 <accept>:
{
  8019a0:	55                   	push   %ebp
  8019a1:	89 e5                	mov    %esp,%ebp
  8019a3:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019a9:	e8 4e ff ff ff       	call   8018fc <fd2sockid>
  8019ae:	85 c0                	test   %eax,%eax
  8019b0:	78 1b                	js     8019cd <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019b2:	83 ec 04             	sub    $0x4,%esp
  8019b5:	ff 75 10             	push   0x10(%ebp)
  8019b8:	ff 75 0c             	push   0xc(%ebp)
  8019bb:	50                   	push   %eax
  8019bc:	e8 0e 01 00 00       	call   801acf <nsipc_accept>
  8019c1:	83 c4 10             	add    $0x10,%esp
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	78 05                	js     8019cd <accept+0x2d>
	return alloc_sockfd(r);
  8019c8:	e8 5f ff ff ff       	call   80192c <alloc_sockfd>
}
  8019cd:	c9                   	leave  
  8019ce:	c3                   	ret    

008019cf <bind>:
{
  8019cf:	55                   	push   %ebp
  8019d0:	89 e5                	mov    %esp,%ebp
  8019d2:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d8:	e8 1f ff ff ff       	call   8018fc <fd2sockid>
  8019dd:	85 c0                	test   %eax,%eax
  8019df:	78 12                	js     8019f3 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8019e1:	83 ec 04             	sub    $0x4,%esp
  8019e4:	ff 75 10             	push   0x10(%ebp)
  8019e7:	ff 75 0c             	push   0xc(%ebp)
  8019ea:	50                   	push   %eax
  8019eb:	e8 31 01 00 00       	call   801b21 <nsipc_bind>
  8019f0:	83 c4 10             	add    $0x10,%esp
}
  8019f3:	c9                   	leave  
  8019f4:	c3                   	ret    

008019f5 <shutdown>:
{
  8019f5:	55                   	push   %ebp
  8019f6:	89 e5                	mov    %esp,%ebp
  8019f8:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fe:	e8 f9 fe ff ff       	call   8018fc <fd2sockid>
  801a03:	85 c0                	test   %eax,%eax
  801a05:	78 0f                	js     801a16 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801a07:	83 ec 08             	sub    $0x8,%esp
  801a0a:	ff 75 0c             	push   0xc(%ebp)
  801a0d:	50                   	push   %eax
  801a0e:	e8 43 01 00 00       	call   801b56 <nsipc_shutdown>
  801a13:	83 c4 10             	add    $0x10,%esp
}
  801a16:	c9                   	leave  
  801a17:	c3                   	ret    

00801a18 <connect>:
{
  801a18:	55                   	push   %ebp
  801a19:	89 e5                	mov    %esp,%ebp
  801a1b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a21:	e8 d6 fe ff ff       	call   8018fc <fd2sockid>
  801a26:	85 c0                	test   %eax,%eax
  801a28:	78 12                	js     801a3c <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801a2a:	83 ec 04             	sub    $0x4,%esp
  801a2d:	ff 75 10             	push   0x10(%ebp)
  801a30:	ff 75 0c             	push   0xc(%ebp)
  801a33:	50                   	push   %eax
  801a34:	e8 59 01 00 00       	call   801b92 <nsipc_connect>
  801a39:	83 c4 10             	add    $0x10,%esp
}
  801a3c:	c9                   	leave  
  801a3d:	c3                   	ret    

00801a3e <listen>:
{
  801a3e:	55                   	push   %ebp
  801a3f:	89 e5                	mov    %esp,%ebp
  801a41:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a44:	8b 45 08             	mov    0x8(%ebp),%eax
  801a47:	e8 b0 fe ff ff       	call   8018fc <fd2sockid>
  801a4c:	85 c0                	test   %eax,%eax
  801a4e:	78 0f                	js     801a5f <listen+0x21>
	return nsipc_listen(r, backlog);
  801a50:	83 ec 08             	sub    $0x8,%esp
  801a53:	ff 75 0c             	push   0xc(%ebp)
  801a56:	50                   	push   %eax
  801a57:	e8 6b 01 00 00       	call   801bc7 <nsipc_listen>
  801a5c:	83 c4 10             	add    $0x10,%esp
}
  801a5f:	c9                   	leave  
  801a60:	c3                   	ret    

00801a61 <socket>:

int
socket(int domain, int type, int protocol)
{
  801a61:	55                   	push   %ebp
  801a62:	89 e5                	mov    %esp,%ebp
  801a64:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a67:	ff 75 10             	push   0x10(%ebp)
  801a6a:	ff 75 0c             	push   0xc(%ebp)
  801a6d:	ff 75 08             	push   0x8(%ebp)
  801a70:	e8 41 02 00 00       	call   801cb6 <nsipc_socket>
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	85 c0                	test   %eax,%eax
  801a7a:	78 05                	js     801a81 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a7c:	e8 ab fe ff ff       	call   80192c <alloc_sockfd>
}
  801a81:	c9                   	leave  
  801a82:	c3                   	ret    

00801a83 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a83:	55                   	push   %ebp
  801a84:	89 e5                	mov    %esp,%ebp
  801a86:	53                   	push   %ebx
  801a87:	83 ec 04             	sub    $0x4,%esp
  801a8a:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a8c:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801a93:	74 26                	je     801abb <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a95:	6a 07                	push   $0x7
  801a97:	68 00 70 80 00       	push   $0x807000
  801a9c:	53                   	push   %ebx
  801a9d:	ff 35 00 80 80 00    	push   0x808000
  801aa3:	e8 a3 07 00 00       	call   80224b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801aa8:	83 c4 0c             	add    $0xc,%esp
  801aab:	6a 00                	push   $0x0
  801aad:	6a 00                	push   $0x0
  801aaf:	6a 00                	push   $0x0
  801ab1:	e8 2e 07 00 00       	call   8021e4 <ipc_recv>
}
  801ab6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab9:	c9                   	leave  
  801aba:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801abb:	83 ec 0c             	sub    $0xc,%esp
  801abe:	6a 02                	push   $0x2
  801ac0:	e8 da 07 00 00       	call   80229f <ipc_find_env>
  801ac5:	a3 00 80 80 00       	mov    %eax,0x808000
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	eb c6                	jmp    801a95 <nsipc+0x12>

00801acf <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801acf:	55                   	push   %ebp
  801ad0:	89 e5                	mov    %esp,%ebp
  801ad2:	56                   	push   %esi
  801ad3:	53                   	push   %ebx
  801ad4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ad7:	8b 45 08             	mov    0x8(%ebp),%eax
  801ada:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801adf:	8b 06                	mov    (%esi),%eax
  801ae1:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ae6:	b8 01 00 00 00       	mov    $0x1,%eax
  801aeb:	e8 93 ff ff ff       	call   801a83 <nsipc>
  801af0:	89 c3                	mov    %eax,%ebx
  801af2:	85 c0                	test   %eax,%eax
  801af4:	79 09                	jns    801aff <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801af6:	89 d8                	mov    %ebx,%eax
  801af8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801afb:	5b                   	pop    %ebx
  801afc:	5e                   	pop    %esi
  801afd:	5d                   	pop    %ebp
  801afe:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801aff:	83 ec 04             	sub    $0x4,%esp
  801b02:	ff 35 10 70 80 00    	push   0x807010
  801b08:	68 00 70 80 00       	push   $0x807000
  801b0d:	ff 75 0c             	push   0xc(%ebp)
  801b10:	e8 61 ee ff ff       	call   800976 <memmove>
		*addrlen = ret->ret_addrlen;
  801b15:	a1 10 70 80 00       	mov    0x807010,%eax
  801b1a:	89 06                	mov    %eax,(%esi)
  801b1c:	83 c4 10             	add    $0x10,%esp
	return r;
  801b1f:	eb d5                	jmp    801af6 <nsipc_accept+0x27>

00801b21 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b21:	55                   	push   %ebp
  801b22:	89 e5                	mov    %esp,%ebp
  801b24:	53                   	push   %ebx
  801b25:	83 ec 08             	sub    $0x8,%esp
  801b28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b33:	53                   	push   %ebx
  801b34:	ff 75 0c             	push   0xc(%ebp)
  801b37:	68 04 70 80 00       	push   $0x807004
  801b3c:	e8 35 ee ff ff       	call   800976 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b41:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801b47:	b8 02 00 00 00       	mov    $0x2,%eax
  801b4c:	e8 32 ff ff ff       	call   801a83 <nsipc>
}
  801b51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b54:	c9                   	leave  
  801b55:	c3                   	ret    

00801b56 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801b64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b67:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801b6c:	b8 03 00 00 00       	mov    $0x3,%eax
  801b71:	e8 0d ff ff ff       	call   801a83 <nsipc>
}
  801b76:	c9                   	leave  
  801b77:	c3                   	ret    

00801b78 <nsipc_close>:

int
nsipc_close(int s)
{
  801b78:	55                   	push   %ebp
  801b79:	89 e5                	mov    %esp,%ebp
  801b7b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b81:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801b86:	b8 04 00 00 00       	mov    $0x4,%eax
  801b8b:	e8 f3 fe ff ff       	call   801a83 <nsipc>
}
  801b90:	c9                   	leave  
  801b91:	c3                   	ret    

00801b92 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	53                   	push   %ebx
  801b96:	83 ec 08             	sub    $0x8,%esp
  801b99:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9f:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ba4:	53                   	push   %ebx
  801ba5:	ff 75 0c             	push   0xc(%ebp)
  801ba8:	68 04 70 80 00       	push   $0x807004
  801bad:	e8 c4 ed ff ff       	call   800976 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801bb2:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801bb8:	b8 05 00 00 00       	mov    $0x5,%eax
  801bbd:	e8 c1 fe ff ff       	call   801a83 <nsipc>
}
  801bc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc5:	c9                   	leave  
  801bc6:	c3                   	ret    

00801bc7 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801bc7:	55                   	push   %ebp
  801bc8:	89 e5                	mov    %esp,%ebp
  801bca:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801bcd:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801bd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bd8:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801bdd:	b8 06 00 00 00       	mov    $0x6,%eax
  801be2:	e8 9c fe ff ff       	call   801a83 <nsipc>
}
  801be7:	c9                   	leave  
  801be8:	c3                   	ret    

00801be9 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801be9:	55                   	push   %ebp
  801bea:	89 e5                	mov    %esp,%ebp
  801bec:	56                   	push   %esi
  801bed:	53                   	push   %ebx
  801bee:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801bf1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801bf9:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801bff:	8b 45 14             	mov    0x14(%ebp),%eax
  801c02:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c07:	b8 07 00 00 00       	mov    $0x7,%eax
  801c0c:	e8 72 fe ff ff       	call   801a83 <nsipc>
  801c11:	89 c3                	mov    %eax,%ebx
  801c13:	85 c0                	test   %eax,%eax
  801c15:	78 22                	js     801c39 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801c17:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801c1c:	39 c6                	cmp    %eax,%esi
  801c1e:	0f 4e c6             	cmovle %esi,%eax
  801c21:	39 c3                	cmp    %eax,%ebx
  801c23:	7f 1d                	jg     801c42 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c25:	83 ec 04             	sub    $0x4,%esp
  801c28:	53                   	push   %ebx
  801c29:	68 00 70 80 00       	push   $0x807000
  801c2e:	ff 75 0c             	push   0xc(%ebp)
  801c31:	e8 40 ed ff ff       	call   800976 <memmove>
  801c36:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c39:	89 d8                	mov    %ebx,%eax
  801c3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c3e:	5b                   	pop    %ebx
  801c3f:	5e                   	pop    %esi
  801c40:	5d                   	pop    %ebp
  801c41:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801c42:	68 9b 29 80 00       	push   $0x80299b
  801c47:	68 63 29 80 00       	push   $0x802963
  801c4c:	6a 62                	push   $0x62
  801c4e:	68 b0 29 80 00       	push   $0x8029b0
  801c53:	e8 46 05 00 00       	call   80219e <_panic>

00801c58 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	53                   	push   %ebx
  801c5c:	83 ec 04             	sub    $0x4,%esp
  801c5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c62:	8b 45 08             	mov    0x8(%ebp),%eax
  801c65:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801c6a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c70:	7f 2e                	jg     801ca0 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c72:	83 ec 04             	sub    $0x4,%esp
  801c75:	53                   	push   %ebx
  801c76:	ff 75 0c             	push   0xc(%ebp)
  801c79:	68 0c 70 80 00       	push   $0x80700c
  801c7e:	e8 f3 ec ff ff       	call   800976 <memmove>
	nsipcbuf.send.req_size = size;
  801c83:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801c89:	8b 45 14             	mov    0x14(%ebp),%eax
  801c8c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801c91:	b8 08 00 00 00       	mov    $0x8,%eax
  801c96:	e8 e8 fd ff ff       	call   801a83 <nsipc>
}
  801c9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c9e:	c9                   	leave  
  801c9f:	c3                   	ret    
	assert(size < 1600);
  801ca0:	68 bc 29 80 00       	push   $0x8029bc
  801ca5:	68 63 29 80 00       	push   $0x802963
  801caa:	6a 6d                	push   $0x6d
  801cac:	68 b0 29 80 00       	push   $0x8029b0
  801cb1:	e8 e8 04 00 00       	call   80219e <_panic>

00801cb6 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801cb6:	55                   	push   %ebp
  801cb7:	89 e5                	mov    %esp,%ebp
  801cb9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cbf:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801cc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc7:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801ccc:	8b 45 10             	mov    0x10(%ebp),%eax
  801ccf:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801cd4:	b8 09 00 00 00       	mov    $0x9,%eax
  801cd9:	e8 a5 fd ff ff       	call   801a83 <nsipc>
}
  801cde:	c9                   	leave  
  801cdf:	c3                   	ret    

00801ce0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	56                   	push   %esi
  801ce4:	53                   	push   %ebx
  801ce5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ce8:	83 ec 0c             	sub    $0xc,%esp
  801ceb:	ff 75 08             	push   0x8(%ebp)
  801cee:	e8 9a f2 ff ff       	call   800f8d <fd2data>
  801cf3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801cf5:	83 c4 08             	add    $0x8,%esp
  801cf8:	68 c8 29 80 00       	push   $0x8029c8
  801cfd:	53                   	push   %ebx
  801cfe:	e8 dd ea ff ff       	call   8007e0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d03:	8b 46 04             	mov    0x4(%esi),%eax
  801d06:	2b 06                	sub    (%esi),%eax
  801d08:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d0e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d15:	00 00 00 
	stat->st_dev = &devpipe;
  801d18:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801d1f:	30 80 00 
	return 0;
}
  801d22:	b8 00 00 00 00       	mov    $0x0,%eax
  801d27:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d2a:	5b                   	pop    %ebx
  801d2b:	5e                   	pop    %esi
  801d2c:	5d                   	pop    %ebp
  801d2d:	c3                   	ret    

00801d2e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
  801d31:	53                   	push   %ebx
  801d32:	83 ec 0c             	sub    $0xc,%esp
  801d35:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d38:	53                   	push   %ebx
  801d39:	6a 00                	push   $0x0
  801d3b:	e8 21 ef ff ff       	call   800c61 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d40:	89 1c 24             	mov    %ebx,(%esp)
  801d43:	e8 45 f2 ff ff       	call   800f8d <fd2data>
  801d48:	83 c4 08             	add    $0x8,%esp
  801d4b:	50                   	push   %eax
  801d4c:	6a 00                	push   $0x0
  801d4e:	e8 0e ef ff ff       	call   800c61 <sys_page_unmap>
}
  801d53:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d56:	c9                   	leave  
  801d57:	c3                   	ret    

00801d58 <_pipeisclosed>:
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
  801d5b:	57                   	push   %edi
  801d5c:	56                   	push   %esi
  801d5d:	53                   	push   %ebx
  801d5e:	83 ec 1c             	sub    $0x1c,%esp
  801d61:	89 c7                	mov    %eax,%edi
  801d63:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801d65:	a1 00 40 80 00       	mov    0x804000,%eax
  801d6a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d6d:	83 ec 0c             	sub    $0xc,%esp
  801d70:	57                   	push   %edi
  801d71:	e8 62 05 00 00       	call   8022d8 <pageref>
  801d76:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d79:	89 34 24             	mov    %esi,(%esp)
  801d7c:	e8 57 05 00 00       	call   8022d8 <pageref>
		nn = thisenv->env_runs;
  801d81:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801d87:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d8a:	83 c4 10             	add    $0x10,%esp
  801d8d:	39 cb                	cmp    %ecx,%ebx
  801d8f:	74 1b                	je     801dac <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801d91:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d94:	75 cf                	jne    801d65 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d96:	8b 42 58             	mov    0x58(%edx),%eax
  801d99:	6a 01                	push   $0x1
  801d9b:	50                   	push   %eax
  801d9c:	53                   	push   %ebx
  801d9d:	68 cf 29 80 00       	push   $0x8029cf
  801da2:	e8 5f e4 ff ff       	call   800206 <cprintf>
  801da7:	83 c4 10             	add    $0x10,%esp
  801daa:	eb b9                	jmp    801d65 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801dac:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801daf:	0f 94 c0             	sete   %al
  801db2:	0f b6 c0             	movzbl %al,%eax
}
  801db5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db8:	5b                   	pop    %ebx
  801db9:	5e                   	pop    %esi
  801dba:	5f                   	pop    %edi
  801dbb:	5d                   	pop    %ebp
  801dbc:	c3                   	ret    

00801dbd <devpipe_write>:
{
  801dbd:	55                   	push   %ebp
  801dbe:	89 e5                	mov    %esp,%ebp
  801dc0:	57                   	push   %edi
  801dc1:	56                   	push   %esi
  801dc2:	53                   	push   %ebx
  801dc3:	83 ec 28             	sub    $0x28,%esp
  801dc6:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801dc9:	56                   	push   %esi
  801dca:	e8 be f1 ff ff       	call   800f8d <fd2data>
  801dcf:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801dd1:	83 c4 10             	add    $0x10,%esp
  801dd4:	bf 00 00 00 00       	mov    $0x0,%edi
  801dd9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ddc:	75 09                	jne    801de7 <devpipe_write+0x2a>
	return i;
  801dde:	89 f8                	mov    %edi,%eax
  801de0:	eb 23                	jmp    801e05 <devpipe_write+0x48>
			sys_yield();
  801de2:	e8 d6 ed ff ff       	call   800bbd <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801de7:	8b 43 04             	mov    0x4(%ebx),%eax
  801dea:	8b 0b                	mov    (%ebx),%ecx
  801dec:	8d 51 20             	lea    0x20(%ecx),%edx
  801def:	39 d0                	cmp    %edx,%eax
  801df1:	72 1a                	jb     801e0d <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801df3:	89 da                	mov    %ebx,%edx
  801df5:	89 f0                	mov    %esi,%eax
  801df7:	e8 5c ff ff ff       	call   801d58 <_pipeisclosed>
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	74 e2                	je     801de2 <devpipe_write+0x25>
				return 0;
  801e00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e05:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e08:	5b                   	pop    %ebx
  801e09:	5e                   	pop    %esi
  801e0a:	5f                   	pop    %edi
  801e0b:	5d                   	pop    %ebp
  801e0c:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e10:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e14:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e17:	89 c2                	mov    %eax,%edx
  801e19:	c1 fa 1f             	sar    $0x1f,%edx
  801e1c:	89 d1                	mov    %edx,%ecx
  801e1e:	c1 e9 1b             	shr    $0x1b,%ecx
  801e21:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e24:	83 e2 1f             	and    $0x1f,%edx
  801e27:	29 ca                	sub    %ecx,%edx
  801e29:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e2d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e31:	83 c0 01             	add    $0x1,%eax
  801e34:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801e37:	83 c7 01             	add    $0x1,%edi
  801e3a:	eb 9d                	jmp    801dd9 <devpipe_write+0x1c>

00801e3c <devpipe_read>:
{
  801e3c:	55                   	push   %ebp
  801e3d:	89 e5                	mov    %esp,%ebp
  801e3f:	57                   	push   %edi
  801e40:	56                   	push   %esi
  801e41:	53                   	push   %ebx
  801e42:	83 ec 18             	sub    $0x18,%esp
  801e45:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801e48:	57                   	push   %edi
  801e49:	e8 3f f1 ff ff       	call   800f8d <fd2data>
  801e4e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e50:	83 c4 10             	add    $0x10,%esp
  801e53:	be 00 00 00 00       	mov    $0x0,%esi
  801e58:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e5b:	75 13                	jne    801e70 <devpipe_read+0x34>
	return i;
  801e5d:	89 f0                	mov    %esi,%eax
  801e5f:	eb 02                	jmp    801e63 <devpipe_read+0x27>
				return i;
  801e61:	89 f0                	mov    %esi,%eax
}
  801e63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e66:	5b                   	pop    %ebx
  801e67:	5e                   	pop    %esi
  801e68:	5f                   	pop    %edi
  801e69:	5d                   	pop    %ebp
  801e6a:	c3                   	ret    
			sys_yield();
  801e6b:	e8 4d ed ff ff       	call   800bbd <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801e70:	8b 03                	mov    (%ebx),%eax
  801e72:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e75:	75 18                	jne    801e8f <devpipe_read+0x53>
			if (i > 0)
  801e77:	85 f6                	test   %esi,%esi
  801e79:	75 e6                	jne    801e61 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801e7b:	89 da                	mov    %ebx,%edx
  801e7d:	89 f8                	mov    %edi,%eax
  801e7f:	e8 d4 fe ff ff       	call   801d58 <_pipeisclosed>
  801e84:	85 c0                	test   %eax,%eax
  801e86:	74 e3                	je     801e6b <devpipe_read+0x2f>
				return 0;
  801e88:	b8 00 00 00 00       	mov    $0x0,%eax
  801e8d:	eb d4                	jmp    801e63 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e8f:	99                   	cltd   
  801e90:	c1 ea 1b             	shr    $0x1b,%edx
  801e93:	01 d0                	add    %edx,%eax
  801e95:	83 e0 1f             	and    $0x1f,%eax
  801e98:	29 d0                	sub    %edx,%eax
  801e9a:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e9f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ea2:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ea5:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801ea8:	83 c6 01             	add    $0x1,%esi
  801eab:	eb ab                	jmp    801e58 <devpipe_read+0x1c>

00801ead <pipe>:
{
  801ead:	55                   	push   %ebp
  801eae:	89 e5                	mov    %esp,%ebp
  801eb0:	56                   	push   %esi
  801eb1:	53                   	push   %ebx
  801eb2:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801eb5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb8:	50                   	push   %eax
  801eb9:	e8 e6 f0 ff ff       	call   800fa4 <fd_alloc>
  801ebe:	89 c3                	mov    %eax,%ebx
  801ec0:	83 c4 10             	add    $0x10,%esp
  801ec3:	85 c0                	test   %eax,%eax
  801ec5:	0f 88 23 01 00 00    	js     801fee <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ecb:	83 ec 04             	sub    $0x4,%esp
  801ece:	68 07 04 00 00       	push   $0x407
  801ed3:	ff 75 f4             	push   -0xc(%ebp)
  801ed6:	6a 00                	push   $0x0
  801ed8:	e8 ff ec ff ff       	call   800bdc <sys_page_alloc>
  801edd:	89 c3                	mov    %eax,%ebx
  801edf:	83 c4 10             	add    $0x10,%esp
  801ee2:	85 c0                	test   %eax,%eax
  801ee4:	0f 88 04 01 00 00    	js     801fee <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801eea:	83 ec 0c             	sub    $0xc,%esp
  801eed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ef0:	50                   	push   %eax
  801ef1:	e8 ae f0 ff ff       	call   800fa4 <fd_alloc>
  801ef6:	89 c3                	mov    %eax,%ebx
  801ef8:	83 c4 10             	add    $0x10,%esp
  801efb:	85 c0                	test   %eax,%eax
  801efd:	0f 88 db 00 00 00    	js     801fde <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f03:	83 ec 04             	sub    $0x4,%esp
  801f06:	68 07 04 00 00       	push   $0x407
  801f0b:	ff 75 f0             	push   -0x10(%ebp)
  801f0e:	6a 00                	push   $0x0
  801f10:	e8 c7 ec ff ff       	call   800bdc <sys_page_alloc>
  801f15:	89 c3                	mov    %eax,%ebx
  801f17:	83 c4 10             	add    $0x10,%esp
  801f1a:	85 c0                	test   %eax,%eax
  801f1c:	0f 88 bc 00 00 00    	js     801fde <pipe+0x131>
	va = fd2data(fd0);
  801f22:	83 ec 0c             	sub    $0xc,%esp
  801f25:	ff 75 f4             	push   -0xc(%ebp)
  801f28:	e8 60 f0 ff ff       	call   800f8d <fd2data>
  801f2d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f2f:	83 c4 0c             	add    $0xc,%esp
  801f32:	68 07 04 00 00       	push   $0x407
  801f37:	50                   	push   %eax
  801f38:	6a 00                	push   $0x0
  801f3a:	e8 9d ec ff ff       	call   800bdc <sys_page_alloc>
  801f3f:	89 c3                	mov    %eax,%ebx
  801f41:	83 c4 10             	add    $0x10,%esp
  801f44:	85 c0                	test   %eax,%eax
  801f46:	0f 88 82 00 00 00    	js     801fce <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f4c:	83 ec 0c             	sub    $0xc,%esp
  801f4f:	ff 75 f0             	push   -0x10(%ebp)
  801f52:	e8 36 f0 ff ff       	call   800f8d <fd2data>
  801f57:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f5e:	50                   	push   %eax
  801f5f:	6a 00                	push   $0x0
  801f61:	56                   	push   %esi
  801f62:	6a 00                	push   $0x0
  801f64:	e8 b6 ec ff ff       	call   800c1f <sys_page_map>
  801f69:	89 c3                	mov    %eax,%ebx
  801f6b:	83 c4 20             	add    $0x20,%esp
  801f6e:	85 c0                	test   %eax,%eax
  801f70:	78 4e                	js     801fc0 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801f72:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801f77:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f7a:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801f7c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f7f:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801f86:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f89:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801f8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f8e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f95:	83 ec 0c             	sub    $0xc,%esp
  801f98:	ff 75 f4             	push   -0xc(%ebp)
  801f9b:	e8 dd ef ff ff       	call   800f7d <fd2num>
  801fa0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fa3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fa5:	83 c4 04             	add    $0x4,%esp
  801fa8:	ff 75 f0             	push   -0x10(%ebp)
  801fab:	e8 cd ef ff ff       	call   800f7d <fd2num>
  801fb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fb3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801fb6:	83 c4 10             	add    $0x10,%esp
  801fb9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fbe:	eb 2e                	jmp    801fee <pipe+0x141>
	sys_page_unmap(0, va);
  801fc0:	83 ec 08             	sub    $0x8,%esp
  801fc3:	56                   	push   %esi
  801fc4:	6a 00                	push   $0x0
  801fc6:	e8 96 ec ff ff       	call   800c61 <sys_page_unmap>
  801fcb:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801fce:	83 ec 08             	sub    $0x8,%esp
  801fd1:	ff 75 f0             	push   -0x10(%ebp)
  801fd4:	6a 00                	push   $0x0
  801fd6:	e8 86 ec ff ff       	call   800c61 <sys_page_unmap>
  801fdb:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801fde:	83 ec 08             	sub    $0x8,%esp
  801fe1:	ff 75 f4             	push   -0xc(%ebp)
  801fe4:	6a 00                	push   $0x0
  801fe6:	e8 76 ec ff ff       	call   800c61 <sys_page_unmap>
  801feb:	83 c4 10             	add    $0x10,%esp
}
  801fee:	89 d8                	mov    %ebx,%eax
  801ff0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ff3:	5b                   	pop    %ebx
  801ff4:	5e                   	pop    %esi
  801ff5:	5d                   	pop    %ebp
  801ff6:	c3                   	ret    

00801ff7 <pipeisclosed>:
{
  801ff7:	55                   	push   %ebp
  801ff8:	89 e5                	mov    %esp,%ebp
  801ffa:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ffd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802000:	50                   	push   %eax
  802001:	ff 75 08             	push   0x8(%ebp)
  802004:	e8 eb ef ff ff       	call   800ff4 <fd_lookup>
  802009:	83 c4 10             	add    $0x10,%esp
  80200c:	85 c0                	test   %eax,%eax
  80200e:	78 18                	js     802028 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802010:	83 ec 0c             	sub    $0xc,%esp
  802013:	ff 75 f4             	push   -0xc(%ebp)
  802016:	e8 72 ef ff ff       	call   800f8d <fd2data>
  80201b:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80201d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802020:	e8 33 fd ff ff       	call   801d58 <_pipeisclosed>
  802025:	83 c4 10             	add    $0x10,%esp
}
  802028:	c9                   	leave  
  802029:	c3                   	ret    

0080202a <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80202a:	b8 00 00 00 00       	mov    $0x0,%eax
  80202f:	c3                   	ret    

00802030 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802030:	55                   	push   %ebp
  802031:	89 e5                	mov    %esp,%ebp
  802033:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802036:	68 e7 29 80 00       	push   $0x8029e7
  80203b:	ff 75 0c             	push   0xc(%ebp)
  80203e:	e8 9d e7 ff ff       	call   8007e0 <strcpy>
	return 0;
}
  802043:	b8 00 00 00 00       	mov    $0x0,%eax
  802048:	c9                   	leave  
  802049:	c3                   	ret    

0080204a <devcons_write>:
{
  80204a:	55                   	push   %ebp
  80204b:	89 e5                	mov    %esp,%ebp
  80204d:	57                   	push   %edi
  80204e:	56                   	push   %esi
  80204f:	53                   	push   %ebx
  802050:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802056:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80205b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802061:	eb 2e                	jmp    802091 <devcons_write+0x47>
		m = n - tot;
  802063:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802066:	29 f3                	sub    %esi,%ebx
  802068:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80206d:	39 c3                	cmp    %eax,%ebx
  80206f:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802072:	83 ec 04             	sub    $0x4,%esp
  802075:	53                   	push   %ebx
  802076:	89 f0                	mov    %esi,%eax
  802078:	03 45 0c             	add    0xc(%ebp),%eax
  80207b:	50                   	push   %eax
  80207c:	57                   	push   %edi
  80207d:	e8 f4 e8 ff ff       	call   800976 <memmove>
		sys_cputs(buf, m);
  802082:	83 c4 08             	add    $0x8,%esp
  802085:	53                   	push   %ebx
  802086:	57                   	push   %edi
  802087:	e8 94 ea ff ff       	call   800b20 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80208c:	01 de                	add    %ebx,%esi
  80208e:	83 c4 10             	add    $0x10,%esp
  802091:	3b 75 10             	cmp    0x10(%ebp),%esi
  802094:	72 cd                	jb     802063 <devcons_write+0x19>
}
  802096:	89 f0                	mov    %esi,%eax
  802098:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80209b:	5b                   	pop    %ebx
  80209c:	5e                   	pop    %esi
  80209d:	5f                   	pop    %edi
  80209e:	5d                   	pop    %ebp
  80209f:	c3                   	ret    

008020a0 <devcons_read>:
{
  8020a0:	55                   	push   %ebp
  8020a1:	89 e5                	mov    %esp,%ebp
  8020a3:	83 ec 08             	sub    $0x8,%esp
  8020a6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8020ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020af:	75 07                	jne    8020b8 <devcons_read+0x18>
  8020b1:	eb 1f                	jmp    8020d2 <devcons_read+0x32>
		sys_yield();
  8020b3:	e8 05 eb ff ff       	call   800bbd <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8020b8:	e8 81 ea ff ff       	call   800b3e <sys_cgetc>
  8020bd:	85 c0                	test   %eax,%eax
  8020bf:	74 f2                	je     8020b3 <devcons_read+0x13>
	if (c < 0)
  8020c1:	78 0f                	js     8020d2 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8020c3:	83 f8 04             	cmp    $0x4,%eax
  8020c6:	74 0c                	je     8020d4 <devcons_read+0x34>
	*(char*)vbuf = c;
  8020c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020cb:	88 02                	mov    %al,(%edx)
	return 1;
  8020cd:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8020d2:	c9                   	leave  
  8020d3:	c3                   	ret    
		return 0;
  8020d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8020d9:	eb f7                	jmp    8020d2 <devcons_read+0x32>

008020db <cputchar>:
{
  8020db:	55                   	push   %ebp
  8020dc:	89 e5                	mov    %esp,%ebp
  8020de:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e4:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8020e7:	6a 01                	push   $0x1
  8020e9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020ec:	50                   	push   %eax
  8020ed:	e8 2e ea ff ff       	call   800b20 <sys_cputs>
}
  8020f2:	83 c4 10             	add    $0x10,%esp
  8020f5:	c9                   	leave  
  8020f6:	c3                   	ret    

008020f7 <getchar>:
{
  8020f7:	55                   	push   %ebp
  8020f8:	89 e5                	mov    %esp,%ebp
  8020fa:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8020fd:	6a 01                	push   $0x1
  8020ff:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802102:	50                   	push   %eax
  802103:	6a 00                	push   $0x0
  802105:	e8 53 f1 ff ff       	call   80125d <read>
	if (r < 0)
  80210a:	83 c4 10             	add    $0x10,%esp
  80210d:	85 c0                	test   %eax,%eax
  80210f:	78 06                	js     802117 <getchar+0x20>
	if (r < 1)
  802111:	74 06                	je     802119 <getchar+0x22>
	return c;
  802113:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802117:	c9                   	leave  
  802118:	c3                   	ret    
		return -E_EOF;
  802119:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80211e:	eb f7                	jmp    802117 <getchar+0x20>

00802120 <iscons>:
{
  802120:	55                   	push   %ebp
  802121:	89 e5                	mov    %esp,%ebp
  802123:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802126:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802129:	50                   	push   %eax
  80212a:	ff 75 08             	push   0x8(%ebp)
  80212d:	e8 c2 ee ff ff       	call   800ff4 <fd_lookup>
  802132:	83 c4 10             	add    $0x10,%esp
  802135:	85 c0                	test   %eax,%eax
  802137:	78 11                	js     80214a <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802139:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80213c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802142:	39 10                	cmp    %edx,(%eax)
  802144:	0f 94 c0             	sete   %al
  802147:	0f b6 c0             	movzbl %al,%eax
}
  80214a:	c9                   	leave  
  80214b:	c3                   	ret    

0080214c <opencons>:
{
  80214c:	55                   	push   %ebp
  80214d:	89 e5                	mov    %esp,%ebp
  80214f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802152:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802155:	50                   	push   %eax
  802156:	e8 49 ee ff ff       	call   800fa4 <fd_alloc>
  80215b:	83 c4 10             	add    $0x10,%esp
  80215e:	85 c0                	test   %eax,%eax
  802160:	78 3a                	js     80219c <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802162:	83 ec 04             	sub    $0x4,%esp
  802165:	68 07 04 00 00       	push   $0x407
  80216a:	ff 75 f4             	push   -0xc(%ebp)
  80216d:	6a 00                	push   $0x0
  80216f:	e8 68 ea ff ff       	call   800bdc <sys_page_alloc>
  802174:	83 c4 10             	add    $0x10,%esp
  802177:	85 c0                	test   %eax,%eax
  802179:	78 21                	js     80219c <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80217b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80217e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802184:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802186:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802189:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802190:	83 ec 0c             	sub    $0xc,%esp
  802193:	50                   	push   %eax
  802194:	e8 e4 ed ff ff       	call   800f7d <fd2num>
  802199:	83 c4 10             	add    $0x10,%esp
}
  80219c:	c9                   	leave  
  80219d:	c3                   	ret    

0080219e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80219e:	55                   	push   %ebp
  80219f:	89 e5                	mov    %esp,%ebp
  8021a1:	56                   	push   %esi
  8021a2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8021a3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8021a6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8021ac:	e8 ed e9 ff ff       	call   800b9e <sys_getenvid>
  8021b1:	83 ec 0c             	sub    $0xc,%esp
  8021b4:	ff 75 0c             	push   0xc(%ebp)
  8021b7:	ff 75 08             	push   0x8(%ebp)
  8021ba:	56                   	push   %esi
  8021bb:	50                   	push   %eax
  8021bc:	68 f4 29 80 00       	push   $0x8029f4
  8021c1:	e8 40 e0 ff ff       	call   800206 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021c6:	83 c4 18             	add    $0x18,%esp
  8021c9:	53                   	push   %ebx
  8021ca:	ff 75 10             	push   0x10(%ebp)
  8021cd:	e8 e3 df ff ff       	call   8001b5 <vcprintf>
	cprintf("\n");
  8021d2:	c7 04 24 70 25 80 00 	movl   $0x802570,(%esp)
  8021d9:	e8 28 e0 ff ff       	call   800206 <cprintf>
  8021de:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8021e1:	cc                   	int3   
  8021e2:	eb fd                	jmp    8021e1 <_panic+0x43>

008021e4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021e4:	55                   	push   %ebp
  8021e5:	89 e5                	mov    %esp,%ebp
  8021e7:	56                   	push   %esi
  8021e8:	53                   	push   %ebx
  8021e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8021ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8021f2:	85 c0                	test   %eax,%eax
  8021f4:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8021f9:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8021fc:	83 ec 0c             	sub    $0xc,%esp
  8021ff:	50                   	push   %eax
  802200:	e8 87 eb ff ff       	call   800d8c <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802205:	83 c4 10             	add    $0x10,%esp
  802208:	85 f6                	test   %esi,%esi
  80220a:	74 14                	je     802220 <ipc_recv+0x3c>
  80220c:	ba 00 00 00 00       	mov    $0x0,%edx
  802211:	85 c0                	test   %eax,%eax
  802213:	78 09                	js     80221e <ipc_recv+0x3a>
  802215:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80221b:	8b 52 74             	mov    0x74(%edx),%edx
  80221e:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802220:	85 db                	test   %ebx,%ebx
  802222:	74 14                	je     802238 <ipc_recv+0x54>
  802224:	ba 00 00 00 00       	mov    $0x0,%edx
  802229:	85 c0                	test   %eax,%eax
  80222b:	78 09                	js     802236 <ipc_recv+0x52>
  80222d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802233:	8b 52 78             	mov    0x78(%edx),%edx
  802236:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802238:	85 c0                	test   %eax,%eax
  80223a:	78 08                	js     802244 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  80223c:	a1 00 40 80 00       	mov    0x804000,%eax
  802241:	8b 40 70             	mov    0x70(%eax),%eax
}
  802244:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802247:	5b                   	pop    %ebx
  802248:	5e                   	pop    %esi
  802249:	5d                   	pop    %ebp
  80224a:	c3                   	ret    

0080224b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80224b:	55                   	push   %ebp
  80224c:	89 e5                	mov    %esp,%ebp
  80224e:	57                   	push   %edi
  80224f:	56                   	push   %esi
  802250:	53                   	push   %ebx
  802251:	83 ec 0c             	sub    $0xc,%esp
  802254:	8b 7d 08             	mov    0x8(%ebp),%edi
  802257:	8b 75 0c             	mov    0xc(%ebp),%esi
  80225a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  80225d:	85 db                	test   %ebx,%ebx
  80225f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802264:	0f 44 d8             	cmove  %eax,%ebx
  802267:	eb 05                	jmp    80226e <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802269:	e8 4f e9 ff ff       	call   800bbd <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80226e:	ff 75 14             	push   0x14(%ebp)
  802271:	53                   	push   %ebx
  802272:	56                   	push   %esi
  802273:	57                   	push   %edi
  802274:	e8 f0 ea ff ff       	call   800d69 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802279:	83 c4 10             	add    $0x10,%esp
  80227c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80227f:	74 e8                	je     802269 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802281:	85 c0                	test   %eax,%eax
  802283:	78 08                	js     80228d <ipc_send+0x42>
	}while (r<0);

}
  802285:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802288:	5b                   	pop    %ebx
  802289:	5e                   	pop    %esi
  80228a:	5f                   	pop    %edi
  80228b:	5d                   	pop    %ebp
  80228c:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80228d:	50                   	push   %eax
  80228e:	68 17 2a 80 00       	push   $0x802a17
  802293:	6a 3d                	push   $0x3d
  802295:	68 2b 2a 80 00       	push   $0x802a2b
  80229a:	e8 ff fe ff ff       	call   80219e <_panic>

0080229f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80229f:	55                   	push   %ebp
  8022a0:	89 e5                	mov    %esp,%ebp
  8022a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022a5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022aa:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022ad:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022b3:	8b 52 50             	mov    0x50(%edx),%edx
  8022b6:	39 ca                	cmp    %ecx,%edx
  8022b8:	74 11                	je     8022cb <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  8022ba:	83 c0 01             	add    $0x1,%eax
  8022bd:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022c2:	75 e6                	jne    8022aa <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8022c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8022c9:	eb 0b                	jmp    8022d6 <ipc_find_env+0x37>
			return envs[i].env_id;
  8022cb:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022ce:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022d3:	8b 40 48             	mov    0x48(%eax),%eax
}
  8022d6:	5d                   	pop    %ebp
  8022d7:	c3                   	ret    

008022d8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022d8:	55                   	push   %ebp
  8022d9:	89 e5                	mov    %esp,%ebp
  8022db:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022de:	89 c2                	mov    %eax,%edx
  8022e0:	c1 ea 16             	shr    $0x16,%edx
  8022e3:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8022ea:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8022ef:	f6 c1 01             	test   $0x1,%cl
  8022f2:	74 1c                	je     802310 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8022f4:	c1 e8 0c             	shr    $0xc,%eax
  8022f7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8022fe:	a8 01                	test   $0x1,%al
  802300:	74 0e                	je     802310 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802302:	c1 e8 0c             	shr    $0xc,%eax
  802305:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80230c:	ef 
  80230d:	0f b7 d2             	movzwl %dx,%edx
}
  802310:	89 d0                	mov    %edx,%eax
  802312:	5d                   	pop    %ebp
  802313:	c3                   	ret    
  802314:	66 90                	xchg   %ax,%ax
  802316:	66 90                	xchg   %ax,%ax
  802318:	66 90                	xchg   %ax,%ax
  80231a:	66 90                	xchg   %ax,%ax
  80231c:	66 90                	xchg   %ax,%ax
  80231e:	66 90                	xchg   %ax,%ax

00802320 <__udivdi3>:
  802320:	f3 0f 1e fb          	endbr32 
  802324:	55                   	push   %ebp
  802325:	57                   	push   %edi
  802326:	56                   	push   %esi
  802327:	53                   	push   %ebx
  802328:	83 ec 1c             	sub    $0x1c,%esp
  80232b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80232f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802333:	8b 74 24 34          	mov    0x34(%esp),%esi
  802337:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80233b:	85 c0                	test   %eax,%eax
  80233d:	75 19                	jne    802358 <__udivdi3+0x38>
  80233f:	39 f3                	cmp    %esi,%ebx
  802341:	76 4d                	jbe    802390 <__udivdi3+0x70>
  802343:	31 ff                	xor    %edi,%edi
  802345:	89 e8                	mov    %ebp,%eax
  802347:	89 f2                	mov    %esi,%edx
  802349:	f7 f3                	div    %ebx
  80234b:	89 fa                	mov    %edi,%edx
  80234d:	83 c4 1c             	add    $0x1c,%esp
  802350:	5b                   	pop    %ebx
  802351:	5e                   	pop    %esi
  802352:	5f                   	pop    %edi
  802353:	5d                   	pop    %ebp
  802354:	c3                   	ret    
  802355:	8d 76 00             	lea    0x0(%esi),%esi
  802358:	39 f0                	cmp    %esi,%eax
  80235a:	76 14                	jbe    802370 <__udivdi3+0x50>
  80235c:	31 ff                	xor    %edi,%edi
  80235e:	31 c0                	xor    %eax,%eax
  802360:	89 fa                	mov    %edi,%edx
  802362:	83 c4 1c             	add    $0x1c,%esp
  802365:	5b                   	pop    %ebx
  802366:	5e                   	pop    %esi
  802367:	5f                   	pop    %edi
  802368:	5d                   	pop    %ebp
  802369:	c3                   	ret    
  80236a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802370:	0f bd f8             	bsr    %eax,%edi
  802373:	83 f7 1f             	xor    $0x1f,%edi
  802376:	75 48                	jne    8023c0 <__udivdi3+0xa0>
  802378:	39 f0                	cmp    %esi,%eax
  80237a:	72 06                	jb     802382 <__udivdi3+0x62>
  80237c:	31 c0                	xor    %eax,%eax
  80237e:	39 eb                	cmp    %ebp,%ebx
  802380:	77 de                	ja     802360 <__udivdi3+0x40>
  802382:	b8 01 00 00 00       	mov    $0x1,%eax
  802387:	eb d7                	jmp    802360 <__udivdi3+0x40>
  802389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802390:	89 d9                	mov    %ebx,%ecx
  802392:	85 db                	test   %ebx,%ebx
  802394:	75 0b                	jne    8023a1 <__udivdi3+0x81>
  802396:	b8 01 00 00 00       	mov    $0x1,%eax
  80239b:	31 d2                	xor    %edx,%edx
  80239d:	f7 f3                	div    %ebx
  80239f:	89 c1                	mov    %eax,%ecx
  8023a1:	31 d2                	xor    %edx,%edx
  8023a3:	89 f0                	mov    %esi,%eax
  8023a5:	f7 f1                	div    %ecx
  8023a7:	89 c6                	mov    %eax,%esi
  8023a9:	89 e8                	mov    %ebp,%eax
  8023ab:	89 f7                	mov    %esi,%edi
  8023ad:	f7 f1                	div    %ecx
  8023af:	89 fa                	mov    %edi,%edx
  8023b1:	83 c4 1c             	add    $0x1c,%esp
  8023b4:	5b                   	pop    %ebx
  8023b5:	5e                   	pop    %esi
  8023b6:	5f                   	pop    %edi
  8023b7:	5d                   	pop    %ebp
  8023b8:	c3                   	ret    
  8023b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	89 f9                	mov    %edi,%ecx
  8023c2:	ba 20 00 00 00       	mov    $0x20,%edx
  8023c7:	29 fa                	sub    %edi,%edx
  8023c9:	d3 e0                	shl    %cl,%eax
  8023cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023cf:	89 d1                	mov    %edx,%ecx
  8023d1:	89 d8                	mov    %ebx,%eax
  8023d3:	d3 e8                	shr    %cl,%eax
  8023d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8023d9:	09 c1                	or     %eax,%ecx
  8023db:	89 f0                	mov    %esi,%eax
  8023dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023e1:	89 f9                	mov    %edi,%ecx
  8023e3:	d3 e3                	shl    %cl,%ebx
  8023e5:	89 d1                	mov    %edx,%ecx
  8023e7:	d3 e8                	shr    %cl,%eax
  8023e9:	89 f9                	mov    %edi,%ecx
  8023eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8023ef:	89 eb                	mov    %ebp,%ebx
  8023f1:	d3 e6                	shl    %cl,%esi
  8023f3:	89 d1                	mov    %edx,%ecx
  8023f5:	d3 eb                	shr    %cl,%ebx
  8023f7:	09 f3                	or     %esi,%ebx
  8023f9:	89 c6                	mov    %eax,%esi
  8023fb:	89 f2                	mov    %esi,%edx
  8023fd:	89 d8                	mov    %ebx,%eax
  8023ff:	f7 74 24 08          	divl   0x8(%esp)
  802403:	89 d6                	mov    %edx,%esi
  802405:	89 c3                	mov    %eax,%ebx
  802407:	f7 64 24 0c          	mull   0xc(%esp)
  80240b:	39 d6                	cmp    %edx,%esi
  80240d:	72 19                	jb     802428 <__udivdi3+0x108>
  80240f:	89 f9                	mov    %edi,%ecx
  802411:	d3 e5                	shl    %cl,%ebp
  802413:	39 c5                	cmp    %eax,%ebp
  802415:	73 04                	jae    80241b <__udivdi3+0xfb>
  802417:	39 d6                	cmp    %edx,%esi
  802419:	74 0d                	je     802428 <__udivdi3+0x108>
  80241b:	89 d8                	mov    %ebx,%eax
  80241d:	31 ff                	xor    %edi,%edi
  80241f:	e9 3c ff ff ff       	jmp    802360 <__udivdi3+0x40>
  802424:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802428:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80242b:	31 ff                	xor    %edi,%edi
  80242d:	e9 2e ff ff ff       	jmp    802360 <__udivdi3+0x40>
  802432:	66 90                	xchg   %ax,%ax
  802434:	66 90                	xchg   %ax,%ax
  802436:	66 90                	xchg   %ax,%ax
  802438:	66 90                	xchg   %ax,%ax
  80243a:	66 90                	xchg   %ax,%ax
  80243c:	66 90                	xchg   %ax,%ax
  80243e:	66 90                	xchg   %ax,%ax

00802440 <__umoddi3>:
  802440:	f3 0f 1e fb          	endbr32 
  802444:	55                   	push   %ebp
  802445:	57                   	push   %edi
  802446:	56                   	push   %esi
  802447:	53                   	push   %ebx
  802448:	83 ec 1c             	sub    $0x1c,%esp
  80244b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80244f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802453:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802457:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80245b:	89 f0                	mov    %esi,%eax
  80245d:	89 da                	mov    %ebx,%edx
  80245f:	85 ff                	test   %edi,%edi
  802461:	75 15                	jne    802478 <__umoddi3+0x38>
  802463:	39 dd                	cmp    %ebx,%ebp
  802465:	76 39                	jbe    8024a0 <__umoddi3+0x60>
  802467:	f7 f5                	div    %ebp
  802469:	89 d0                	mov    %edx,%eax
  80246b:	31 d2                	xor    %edx,%edx
  80246d:	83 c4 1c             	add    $0x1c,%esp
  802470:	5b                   	pop    %ebx
  802471:	5e                   	pop    %esi
  802472:	5f                   	pop    %edi
  802473:	5d                   	pop    %ebp
  802474:	c3                   	ret    
  802475:	8d 76 00             	lea    0x0(%esi),%esi
  802478:	39 df                	cmp    %ebx,%edi
  80247a:	77 f1                	ja     80246d <__umoddi3+0x2d>
  80247c:	0f bd cf             	bsr    %edi,%ecx
  80247f:	83 f1 1f             	xor    $0x1f,%ecx
  802482:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802486:	75 40                	jne    8024c8 <__umoddi3+0x88>
  802488:	39 df                	cmp    %ebx,%edi
  80248a:	72 04                	jb     802490 <__umoddi3+0x50>
  80248c:	39 f5                	cmp    %esi,%ebp
  80248e:	77 dd                	ja     80246d <__umoddi3+0x2d>
  802490:	89 da                	mov    %ebx,%edx
  802492:	89 f0                	mov    %esi,%eax
  802494:	29 e8                	sub    %ebp,%eax
  802496:	19 fa                	sbb    %edi,%edx
  802498:	eb d3                	jmp    80246d <__umoddi3+0x2d>
  80249a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024a0:	89 e9                	mov    %ebp,%ecx
  8024a2:	85 ed                	test   %ebp,%ebp
  8024a4:	75 0b                	jne    8024b1 <__umoddi3+0x71>
  8024a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024ab:	31 d2                	xor    %edx,%edx
  8024ad:	f7 f5                	div    %ebp
  8024af:	89 c1                	mov    %eax,%ecx
  8024b1:	89 d8                	mov    %ebx,%eax
  8024b3:	31 d2                	xor    %edx,%edx
  8024b5:	f7 f1                	div    %ecx
  8024b7:	89 f0                	mov    %esi,%eax
  8024b9:	f7 f1                	div    %ecx
  8024bb:	89 d0                	mov    %edx,%eax
  8024bd:	31 d2                	xor    %edx,%edx
  8024bf:	eb ac                	jmp    80246d <__umoddi3+0x2d>
  8024c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024c8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8024cc:	ba 20 00 00 00       	mov    $0x20,%edx
  8024d1:	29 c2                	sub    %eax,%edx
  8024d3:	89 c1                	mov    %eax,%ecx
  8024d5:	89 e8                	mov    %ebp,%eax
  8024d7:	d3 e7                	shl    %cl,%edi
  8024d9:	89 d1                	mov    %edx,%ecx
  8024db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8024df:	d3 e8                	shr    %cl,%eax
  8024e1:	89 c1                	mov    %eax,%ecx
  8024e3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8024e7:	09 f9                	or     %edi,%ecx
  8024e9:	89 df                	mov    %ebx,%edi
  8024eb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024ef:	89 c1                	mov    %eax,%ecx
  8024f1:	d3 e5                	shl    %cl,%ebp
  8024f3:	89 d1                	mov    %edx,%ecx
  8024f5:	d3 ef                	shr    %cl,%edi
  8024f7:	89 c1                	mov    %eax,%ecx
  8024f9:	89 f0                	mov    %esi,%eax
  8024fb:	d3 e3                	shl    %cl,%ebx
  8024fd:	89 d1                	mov    %edx,%ecx
  8024ff:	89 fa                	mov    %edi,%edx
  802501:	d3 e8                	shr    %cl,%eax
  802503:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802508:	09 d8                	or     %ebx,%eax
  80250a:	f7 74 24 08          	divl   0x8(%esp)
  80250e:	89 d3                	mov    %edx,%ebx
  802510:	d3 e6                	shl    %cl,%esi
  802512:	f7 e5                	mul    %ebp
  802514:	89 c7                	mov    %eax,%edi
  802516:	89 d1                	mov    %edx,%ecx
  802518:	39 d3                	cmp    %edx,%ebx
  80251a:	72 06                	jb     802522 <__umoddi3+0xe2>
  80251c:	75 0e                	jne    80252c <__umoddi3+0xec>
  80251e:	39 c6                	cmp    %eax,%esi
  802520:	73 0a                	jae    80252c <__umoddi3+0xec>
  802522:	29 e8                	sub    %ebp,%eax
  802524:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802528:	89 d1                	mov    %edx,%ecx
  80252a:	89 c7                	mov    %eax,%edi
  80252c:	89 f5                	mov    %esi,%ebp
  80252e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802532:	29 fd                	sub    %edi,%ebp
  802534:	19 cb                	sbb    %ecx,%ebx
  802536:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80253b:	89 d8                	mov    %ebx,%eax
  80253d:	d3 e0                	shl    %cl,%eax
  80253f:	89 f1                	mov    %esi,%ecx
  802541:	d3 ed                	shr    %cl,%ebp
  802543:	d3 eb                	shr    %cl,%ebx
  802545:	09 e8                	or     %ebp,%eax
  802547:	89 da                	mov    %ebx,%edx
  802549:	83 c4 1c             	add    $0x1c,%esp
  80254c:	5b                   	pop    %ebx
  80254d:	5e                   	pop    %esi
  80254e:	5f                   	pop    %edi
  80254f:	5d                   	pop    %ebp
  802550:	c3                   	ret    
