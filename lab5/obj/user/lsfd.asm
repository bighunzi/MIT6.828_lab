
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
  800039:	68 a0 20 80 00       	push   $0x8020a0
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
  800067:	e8 61 0d 00 00       	call   800dcd <argstart>
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
  800083:	e8 75 0d 00 00       	call   800dfd <argnext>
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
  8000bd:	68 b4 20 80 00       	push   $0x8020b4
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
  8000d7:	e8 13 13 00 00       	call   8013ef <fstat>
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
  8000f8:	68 b4 20 80 00       	push   $0x8020b4
  8000fd:	6a 01                	push   $0x1
  8000ff:	e8 e1 16 00 00       	call   8017e5 <fprintf>
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
  80015d:	e8 86 0f 00 00       	call   8010e8 <close_all>
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
  800268:	e8 e3 1b 00 00       	call   801e50 <__udivdi3>
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
  8002a6:	e8 c5 1c 00 00       	call   801f70 <__umoddi3>
  8002ab:	83 c4 14             	add    $0x14,%esp
  8002ae:	0f be 80 e6 20 80 00 	movsbl 0x8020e6(%eax),%eax
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
  800368:	ff 24 85 20 22 80 00 	jmp    *0x802220(,%eax,4)
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
  800436:	8b 14 85 80 23 80 00 	mov    0x802380(,%eax,4),%edx
  80043d:	85 d2                	test   %edx,%edx
  80043f:	74 18                	je     800459 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800441:	52                   	push   %edx
  800442:	68 b1 24 80 00       	push   $0x8024b1
  800447:	53                   	push   %ebx
  800448:	56                   	push   %esi
  800449:	e8 92 fe ff ff       	call   8002e0 <printfmt>
  80044e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800451:	89 7d 14             	mov    %edi,0x14(%ebp)
  800454:	e9 66 02 00 00       	jmp    8006bf <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800459:	50                   	push   %eax
  80045a:	68 fe 20 80 00       	push   $0x8020fe
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
  800481:	b8 f7 20 80 00       	mov    $0x8020f7,%eax
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
  800b8d:	68 df 23 80 00       	push   $0x8023df
  800b92:	6a 2a                	push   $0x2a
  800b94:	68 fc 23 80 00       	push   $0x8023fc
  800b99:	e8 32 11 00 00       	call   801cd0 <_panic>

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
  800c0e:	68 df 23 80 00       	push   $0x8023df
  800c13:	6a 2a                	push   $0x2a
  800c15:	68 fc 23 80 00       	push   $0x8023fc
  800c1a:	e8 b1 10 00 00       	call   801cd0 <_panic>

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
  800c50:	68 df 23 80 00       	push   $0x8023df
  800c55:	6a 2a                	push   $0x2a
  800c57:	68 fc 23 80 00       	push   $0x8023fc
  800c5c:	e8 6f 10 00 00       	call   801cd0 <_panic>

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
  800c92:	68 df 23 80 00       	push   $0x8023df
  800c97:	6a 2a                	push   $0x2a
  800c99:	68 fc 23 80 00       	push   $0x8023fc
  800c9e:	e8 2d 10 00 00       	call   801cd0 <_panic>

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
  800cd4:	68 df 23 80 00       	push   $0x8023df
  800cd9:	6a 2a                	push   $0x2a
  800cdb:	68 fc 23 80 00       	push   $0x8023fc
  800ce0:	e8 eb 0f 00 00       	call   801cd0 <_panic>

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
  800d16:	68 df 23 80 00       	push   $0x8023df
  800d1b:	6a 2a                	push   $0x2a
  800d1d:	68 fc 23 80 00       	push   $0x8023fc
  800d22:	e8 a9 0f 00 00       	call   801cd0 <_panic>

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
  800d58:	68 df 23 80 00       	push   $0x8023df
  800d5d:	6a 2a                	push   $0x2a
  800d5f:	68 fc 23 80 00       	push   $0x8023fc
  800d64:	e8 67 0f 00 00       	call   801cd0 <_panic>

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
  800dbc:	68 df 23 80 00       	push   $0x8023df
  800dc1:	6a 2a                	push   $0x2a
  800dc3:	68 fc 23 80 00       	push   $0x8023fc
  800dc8:	e8 03 0f 00 00       	call   801cd0 <_panic>

00800dcd <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  800dcd:	55                   	push   %ebp
  800dce:	89 e5                	mov    %esp,%ebp
  800dd0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd6:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  800dd9:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  800ddb:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  800dde:	83 3a 01             	cmpl   $0x1,(%edx)
  800de1:	7e 09                	jle    800dec <argstart+0x1f>
  800de3:	ba b1 20 80 00       	mov    $0x8020b1,%edx
  800de8:	85 c9                	test   %ecx,%ecx
  800dea:	75 05                	jne    800df1 <argstart+0x24>
  800dec:	ba 00 00 00 00       	mov    $0x0,%edx
  800df1:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  800df4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <argnext>:

int
argnext(struct Argstate *args)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	53                   	push   %ebx
  800e01:	83 ec 04             	sub    $0x4,%esp
  800e04:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  800e07:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  800e0e:	8b 43 08             	mov    0x8(%ebx),%eax
  800e11:	85 c0                	test   %eax,%eax
  800e13:	74 74                	je     800e89 <argnext+0x8c>
		return -1;

	if (!*args->curarg) {
  800e15:	80 38 00             	cmpb   $0x0,(%eax)
  800e18:	75 48                	jne    800e62 <argnext+0x65>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  800e1a:	8b 0b                	mov    (%ebx),%ecx
  800e1c:	83 39 01             	cmpl   $0x1,(%ecx)
  800e1f:	74 5a                	je     800e7b <argnext+0x7e>
		    || args->argv[1][0] != '-'
  800e21:	8b 53 04             	mov    0x4(%ebx),%edx
  800e24:	8b 42 04             	mov    0x4(%edx),%eax
  800e27:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e2a:	75 4f                	jne    800e7b <argnext+0x7e>
		    || args->argv[1][1] == '\0')
  800e2c:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e30:	74 49                	je     800e7b <argnext+0x7e>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  800e32:	83 c0 01             	add    $0x1,%eax
  800e35:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800e38:	83 ec 04             	sub    $0x4,%esp
  800e3b:	8b 01                	mov    (%ecx),%eax
  800e3d:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  800e44:	50                   	push   %eax
  800e45:	8d 42 08             	lea    0x8(%edx),%eax
  800e48:	50                   	push   %eax
  800e49:	83 c2 04             	add    $0x4,%edx
  800e4c:	52                   	push   %edx
  800e4d:	e8 24 fb ff ff       	call   800976 <memmove>
		(*args->argc)--;
  800e52:	8b 03                	mov    (%ebx),%eax
  800e54:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800e57:	8b 43 08             	mov    0x8(%ebx),%eax
  800e5a:	83 c4 10             	add    $0x10,%esp
  800e5d:	80 38 2d             	cmpb   $0x2d,(%eax)
  800e60:	74 13                	je     800e75 <argnext+0x78>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  800e62:	8b 43 08             	mov    0x8(%ebx),%eax
  800e65:	0f b6 10             	movzbl (%eax),%edx
	args->curarg++;
  800e68:	83 c0 01             	add    $0x1,%eax
  800e6b:	89 43 08             	mov    %eax,0x8(%ebx)
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  800e6e:	89 d0                	mov    %edx,%eax
  800e70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e73:	c9                   	leave  
  800e74:	c3                   	ret    
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  800e75:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  800e79:	75 e7                	jne    800e62 <argnext+0x65>
	args->curarg = 0;
  800e7b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  800e82:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800e87:	eb e5                	jmp    800e6e <argnext+0x71>
		return -1;
  800e89:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  800e8e:	eb de                	jmp    800e6e <argnext+0x71>

00800e90 <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	53                   	push   %ebx
  800e94:	83 ec 04             	sub    $0x4,%esp
  800e97:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  800e9a:	8b 43 08             	mov    0x8(%ebx),%eax
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	74 12                	je     800eb3 <argnextvalue+0x23>
		return 0;
	if (*args->curarg) {
  800ea1:	80 38 00             	cmpb   $0x0,(%eax)
  800ea4:	74 12                	je     800eb8 <argnextvalue+0x28>
		args->argvalue = args->curarg;
  800ea6:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  800ea9:	c7 43 08 b1 20 80 00 	movl   $0x8020b1,0x8(%ebx)
		(*args->argc)--;
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
  800eb0:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  800eb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eb6:	c9                   	leave  
  800eb7:	c3                   	ret    
	} else if (*args->argc > 1) {
  800eb8:	8b 13                	mov    (%ebx),%edx
  800eba:	83 3a 01             	cmpl   $0x1,(%edx)
  800ebd:	7f 10                	jg     800ecf <argnextvalue+0x3f>
		args->argvalue = 0;
  800ebf:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  800ec6:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  800ecd:	eb e1                	jmp    800eb0 <argnextvalue+0x20>
		args->argvalue = args->argv[1];
  800ecf:	8b 43 04             	mov    0x4(%ebx),%eax
  800ed2:	8b 48 04             	mov    0x4(%eax),%ecx
  800ed5:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  800ed8:	83 ec 04             	sub    $0x4,%esp
  800edb:	8b 12                	mov    (%edx),%edx
  800edd:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  800ee4:	52                   	push   %edx
  800ee5:	8d 50 08             	lea    0x8(%eax),%edx
  800ee8:	52                   	push   %edx
  800ee9:	83 c0 04             	add    $0x4,%eax
  800eec:	50                   	push   %eax
  800eed:	e8 84 fa ff ff       	call   800976 <memmove>
		(*args->argc)--;
  800ef2:	8b 03                	mov    (%ebx),%eax
  800ef4:	83 28 01             	subl   $0x1,(%eax)
  800ef7:	83 c4 10             	add    $0x10,%esp
  800efa:	eb b4                	jmp    800eb0 <argnextvalue+0x20>

00800efc <argvalue>:
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	83 ec 08             	sub    $0x8,%esp
  800f02:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f05:	8b 42 0c             	mov    0xc(%edx),%eax
  800f08:	85 c0                	test   %eax,%eax
  800f0a:	74 02                	je     800f0e <argvalue+0x12>
}
  800f0c:	c9                   	leave  
  800f0d:	c3                   	ret    
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  800f0e:	83 ec 0c             	sub    $0xc,%esp
  800f11:	52                   	push   %edx
  800f12:	e8 79 ff ff ff       	call   800e90 <argnextvalue>
  800f17:	83 c4 10             	add    $0x10,%esp
  800f1a:	eb f0                	jmp    800f0c <argvalue+0x10>

00800f1c <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f1c:	55                   	push   %ebp
  800f1d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f22:	05 00 00 00 30       	add    $0x30000000,%eax
  800f27:	c1 e8 0c             	shr    $0xc,%eax
}
  800f2a:	5d                   	pop    %ebp
  800f2b:	c3                   	ret    

00800f2c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f32:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800f37:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f3c:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    

00800f43 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f4b:	89 c2                	mov    %eax,%edx
  800f4d:	c1 ea 16             	shr    $0x16,%edx
  800f50:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f57:	f6 c2 01             	test   $0x1,%dl
  800f5a:	74 29                	je     800f85 <fd_alloc+0x42>
  800f5c:	89 c2                	mov    %eax,%edx
  800f5e:	c1 ea 0c             	shr    $0xc,%edx
  800f61:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f68:	f6 c2 01             	test   $0x1,%dl
  800f6b:	74 18                	je     800f85 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800f6d:	05 00 10 00 00       	add    $0x1000,%eax
  800f72:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f77:	75 d2                	jne    800f4b <fd_alloc+0x8>
  800f79:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800f7e:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800f83:	eb 05                	jmp    800f8a <fd_alloc+0x47>
			return 0;
  800f85:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800f8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800f8d:	89 02                	mov    %eax,(%edx)
}
  800f8f:	89 c8                	mov    %ecx,%eax
  800f91:	5d                   	pop    %ebp
  800f92:	c3                   	ret    

00800f93 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f99:	83 f8 1f             	cmp    $0x1f,%eax
  800f9c:	77 30                	ja     800fce <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f9e:	c1 e0 0c             	shl    $0xc,%eax
  800fa1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fa6:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800fac:	f6 c2 01             	test   $0x1,%dl
  800faf:	74 24                	je     800fd5 <fd_lookup+0x42>
  800fb1:	89 c2                	mov    %eax,%edx
  800fb3:	c1 ea 0c             	shr    $0xc,%edx
  800fb6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fbd:	f6 c2 01             	test   $0x1,%dl
  800fc0:	74 1a                	je     800fdc <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fc2:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fc5:	89 02                	mov    %eax,(%edx)
	return 0;
  800fc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    
		return -E_INVAL;
  800fce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fd3:	eb f7                	jmp    800fcc <fd_lookup+0x39>
		return -E_INVAL;
  800fd5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fda:	eb f0                	jmp    800fcc <fd_lookup+0x39>
  800fdc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fe1:	eb e9                	jmp    800fcc <fd_lookup+0x39>

00800fe3 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	53                   	push   %ebx
  800fe7:	83 ec 04             	sub    $0x4,%esp
  800fea:	8b 55 08             	mov    0x8(%ebp),%edx
  800fed:	b8 88 24 80 00       	mov    $0x802488,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800ff2:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800ff7:	39 13                	cmp    %edx,(%ebx)
  800ff9:	74 32                	je     80102d <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800ffb:	83 c0 04             	add    $0x4,%eax
  800ffe:	8b 18                	mov    (%eax),%ebx
  801000:	85 db                	test   %ebx,%ebx
  801002:	75 f3                	jne    800ff7 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801004:	a1 00 40 80 00       	mov    0x804000,%eax
  801009:	8b 40 48             	mov    0x48(%eax),%eax
  80100c:	83 ec 04             	sub    $0x4,%esp
  80100f:	52                   	push   %edx
  801010:	50                   	push   %eax
  801011:	68 0c 24 80 00       	push   $0x80240c
  801016:	e8 eb f1 ff ff       	call   800206 <cprintf>
	*dev = 0;
	return -E_INVAL;
  80101b:	83 c4 10             	add    $0x10,%esp
  80101e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801023:	8b 55 0c             	mov    0xc(%ebp),%edx
  801026:	89 1a                	mov    %ebx,(%edx)
}
  801028:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80102b:	c9                   	leave  
  80102c:	c3                   	ret    
			return 0;
  80102d:	b8 00 00 00 00       	mov    $0x0,%eax
  801032:	eb ef                	jmp    801023 <dev_lookup+0x40>

00801034 <fd_close>:
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	57                   	push   %edi
  801038:	56                   	push   %esi
  801039:	53                   	push   %ebx
  80103a:	83 ec 24             	sub    $0x24,%esp
  80103d:	8b 75 08             	mov    0x8(%ebp),%esi
  801040:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801043:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801046:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801047:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80104d:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801050:	50                   	push   %eax
  801051:	e8 3d ff ff ff       	call   800f93 <fd_lookup>
  801056:	89 c3                	mov    %eax,%ebx
  801058:	83 c4 10             	add    $0x10,%esp
  80105b:	85 c0                	test   %eax,%eax
  80105d:	78 05                	js     801064 <fd_close+0x30>
	    || fd != fd2)
  80105f:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801062:	74 16                	je     80107a <fd_close+0x46>
		return (must_exist ? r : 0);
  801064:	89 f8                	mov    %edi,%eax
  801066:	84 c0                	test   %al,%al
  801068:	b8 00 00 00 00       	mov    $0x0,%eax
  80106d:	0f 44 d8             	cmove  %eax,%ebx
}
  801070:	89 d8                	mov    %ebx,%eax
  801072:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801075:	5b                   	pop    %ebx
  801076:	5e                   	pop    %esi
  801077:	5f                   	pop    %edi
  801078:	5d                   	pop    %ebp
  801079:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80107a:	83 ec 08             	sub    $0x8,%esp
  80107d:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801080:	50                   	push   %eax
  801081:	ff 36                	push   (%esi)
  801083:	e8 5b ff ff ff       	call   800fe3 <dev_lookup>
  801088:	89 c3                	mov    %eax,%ebx
  80108a:	83 c4 10             	add    $0x10,%esp
  80108d:	85 c0                	test   %eax,%eax
  80108f:	78 1a                	js     8010ab <fd_close+0x77>
		if (dev->dev_close)
  801091:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801094:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801097:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80109c:	85 c0                	test   %eax,%eax
  80109e:	74 0b                	je     8010ab <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8010a0:	83 ec 0c             	sub    $0xc,%esp
  8010a3:	56                   	push   %esi
  8010a4:	ff d0                	call   *%eax
  8010a6:	89 c3                	mov    %eax,%ebx
  8010a8:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8010ab:	83 ec 08             	sub    $0x8,%esp
  8010ae:	56                   	push   %esi
  8010af:	6a 00                	push   $0x0
  8010b1:	e8 ab fb ff ff       	call   800c61 <sys_page_unmap>
	return r;
  8010b6:	83 c4 10             	add    $0x10,%esp
  8010b9:	eb b5                	jmp    801070 <fd_close+0x3c>

008010bb <close>:

int
close(int fdnum)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c4:	50                   	push   %eax
  8010c5:	ff 75 08             	push   0x8(%ebp)
  8010c8:	e8 c6 fe ff ff       	call   800f93 <fd_lookup>
  8010cd:	83 c4 10             	add    $0x10,%esp
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	79 02                	jns    8010d6 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8010d4:	c9                   	leave  
  8010d5:	c3                   	ret    
		return fd_close(fd, 1);
  8010d6:	83 ec 08             	sub    $0x8,%esp
  8010d9:	6a 01                	push   $0x1
  8010db:	ff 75 f4             	push   -0xc(%ebp)
  8010de:	e8 51 ff ff ff       	call   801034 <fd_close>
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	eb ec                	jmp    8010d4 <close+0x19>

008010e8 <close_all>:

void
close_all(void)
{
  8010e8:	55                   	push   %ebp
  8010e9:	89 e5                	mov    %esp,%ebp
  8010eb:	53                   	push   %ebx
  8010ec:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010ef:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010f4:	83 ec 0c             	sub    $0xc,%esp
  8010f7:	53                   	push   %ebx
  8010f8:	e8 be ff ff ff       	call   8010bb <close>
	for (i = 0; i < MAXFD; i++)
  8010fd:	83 c3 01             	add    $0x1,%ebx
  801100:	83 c4 10             	add    $0x10,%esp
  801103:	83 fb 20             	cmp    $0x20,%ebx
  801106:	75 ec                	jne    8010f4 <close_all+0xc>
}
  801108:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80110b:	c9                   	leave  
  80110c:	c3                   	ret    

0080110d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	57                   	push   %edi
  801111:	56                   	push   %esi
  801112:	53                   	push   %ebx
  801113:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801116:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801119:	50                   	push   %eax
  80111a:	ff 75 08             	push   0x8(%ebp)
  80111d:	e8 71 fe ff ff       	call   800f93 <fd_lookup>
  801122:	89 c3                	mov    %eax,%ebx
  801124:	83 c4 10             	add    $0x10,%esp
  801127:	85 c0                	test   %eax,%eax
  801129:	78 7f                	js     8011aa <dup+0x9d>
		return r;
	close(newfdnum);
  80112b:	83 ec 0c             	sub    $0xc,%esp
  80112e:	ff 75 0c             	push   0xc(%ebp)
  801131:	e8 85 ff ff ff       	call   8010bb <close>

	newfd = INDEX2FD(newfdnum);
  801136:	8b 75 0c             	mov    0xc(%ebp),%esi
  801139:	c1 e6 0c             	shl    $0xc,%esi
  80113c:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801142:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801145:	89 3c 24             	mov    %edi,(%esp)
  801148:	e8 df fd ff ff       	call   800f2c <fd2data>
  80114d:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80114f:	89 34 24             	mov    %esi,(%esp)
  801152:	e8 d5 fd ff ff       	call   800f2c <fd2data>
  801157:	83 c4 10             	add    $0x10,%esp
  80115a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80115d:	89 d8                	mov    %ebx,%eax
  80115f:	c1 e8 16             	shr    $0x16,%eax
  801162:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801169:	a8 01                	test   $0x1,%al
  80116b:	74 11                	je     80117e <dup+0x71>
  80116d:	89 d8                	mov    %ebx,%eax
  80116f:	c1 e8 0c             	shr    $0xc,%eax
  801172:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801179:	f6 c2 01             	test   $0x1,%dl
  80117c:	75 36                	jne    8011b4 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80117e:	89 f8                	mov    %edi,%eax
  801180:	c1 e8 0c             	shr    $0xc,%eax
  801183:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80118a:	83 ec 0c             	sub    $0xc,%esp
  80118d:	25 07 0e 00 00       	and    $0xe07,%eax
  801192:	50                   	push   %eax
  801193:	56                   	push   %esi
  801194:	6a 00                	push   $0x0
  801196:	57                   	push   %edi
  801197:	6a 00                	push   $0x0
  801199:	e8 81 fa ff ff       	call   800c1f <sys_page_map>
  80119e:	89 c3                	mov    %eax,%ebx
  8011a0:	83 c4 20             	add    $0x20,%esp
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	78 33                	js     8011da <dup+0xcd>
		goto err;

	return newfdnum;
  8011a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011aa:	89 d8                	mov    %ebx,%eax
  8011ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011af:	5b                   	pop    %ebx
  8011b0:	5e                   	pop    %esi
  8011b1:	5f                   	pop    %edi
  8011b2:	5d                   	pop    %ebp
  8011b3:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011b4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011bb:	83 ec 0c             	sub    $0xc,%esp
  8011be:	25 07 0e 00 00       	and    $0xe07,%eax
  8011c3:	50                   	push   %eax
  8011c4:	ff 75 d4             	push   -0x2c(%ebp)
  8011c7:	6a 00                	push   $0x0
  8011c9:	53                   	push   %ebx
  8011ca:	6a 00                	push   $0x0
  8011cc:	e8 4e fa ff ff       	call   800c1f <sys_page_map>
  8011d1:	89 c3                	mov    %eax,%ebx
  8011d3:	83 c4 20             	add    $0x20,%esp
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	79 a4                	jns    80117e <dup+0x71>
	sys_page_unmap(0, newfd);
  8011da:	83 ec 08             	sub    $0x8,%esp
  8011dd:	56                   	push   %esi
  8011de:	6a 00                	push   $0x0
  8011e0:	e8 7c fa ff ff       	call   800c61 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011e5:	83 c4 08             	add    $0x8,%esp
  8011e8:	ff 75 d4             	push   -0x2c(%ebp)
  8011eb:	6a 00                	push   $0x0
  8011ed:	e8 6f fa ff ff       	call   800c61 <sys_page_unmap>
	return r;
  8011f2:	83 c4 10             	add    $0x10,%esp
  8011f5:	eb b3                	jmp    8011aa <dup+0x9d>

008011f7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011f7:	55                   	push   %ebp
  8011f8:	89 e5                	mov    %esp,%ebp
  8011fa:	56                   	push   %esi
  8011fb:	53                   	push   %ebx
  8011fc:	83 ec 18             	sub    $0x18,%esp
  8011ff:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801202:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801205:	50                   	push   %eax
  801206:	56                   	push   %esi
  801207:	e8 87 fd ff ff       	call   800f93 <fd_lookup>
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	85 c0                	test   %eax,%eax
  801211:	78 3c                	js     80124f <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801213:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801216:	83 ec 08             	sub    $0x8,%esp
  801219:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80121c:	50                   	push   %eax
  80121d:	ff 33                	push   (%ebx)
  80121f:	e8 bf fd ff ff       	call   800fe3 <dev_lookup>
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	78 24                	js     80124f <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80122b:	8b 43 08             	mov    0x8(%ebx),%eax
  80122e:	83 e0 03             	and    $0x3,%eax
  801231:	83 f8 01             	cmp    $0x1,%eax
  801234:	74 20                	je     801256 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801236:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801239:	8b 40 08             	mov    0x8(%eax),%eax
  80123c:	85 c0                	test   %eax,%eax
  80123e:	74 37                	je     801277 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801240:	83 ec 04             	sub    $0x4,%esp
  801243:	ff 75 10             	push   0x10(%ebp)
  801246:	ff 75 0c             	push   0xc(%ebp)
  801249:	53                   	push   %ebx
  80124a:	ff d0                	call   *%eax
  80124c:	83 c4 10             	add    $0x10,%esp
}
  80124f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801252:	5b                   	pop    %ebx
  801253:	5e                   	pop    %esi
  801254:	5d                   	pop    %ebp
  801255:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801256:	a1 00 40 80 00       	mov    0x804000,%eax
  80125b:	8b 40 48             	mov    0x48(%eax),%eax
  80125e:	83 ec 04             	sub    $0x4,%esp
  801261:	56                   	push   %esi
  801262:	50                   	push   %eax
  801263:	68 4d 24 80 00       	push   $0x80244d
  801268:	e8 99 ef ff ff       	call   800206 <cprintf>
		return -E_INVAL;
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801275:	eb d8                	jmp    80124f <read+0x58>
		return -E_NOT_SUPP;
  801277:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80127c:	eb d1                	jmp    80124f <read+0x58>

0080127e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	57                   	push   %edi
  801282:	56                   	push   %esi
  801283:	53                   	push   %ebx
  801284:	83 ec 0c             	sub    $0xc,%esp
  801287:	8b 7d 08             	mov    0x8(%ebp),%edi
  80128a:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80128d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801292:	eb 02                	jmp    801296 <readn+0x18>
  801294:	01 c3                	add    %eax,%ebx
  801296:	39 f3                	cmp    %esi,%ebx
  801298:	73 21                	jae    8012bb <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80129a:	83 ec 04             	sub    $0x4,%esp
  80129d:	89 f0                	mov    %esi,%eax
  80129f:	29 d8                	sub    %ebx,%eax
  8012a1:	50                   	push   %eax
  8012a2:	89 d8                	mov    %ebx,%eax
  8012a4:	03 45 0c             	add    0xc(%ebp),%eax
  8012a7:	50                   	push   %eax
  8012a8:	57                   	push   %edi
  8012a9:	e8 49 ff ff ff       	call   8011f7 <read>
		if (m < 0)
  8012ae:	83 c4 10             	add    $0x10,%esp
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	78 04                	js     8012b9 <readn+0x3b>
			return m;
		if (m == 0)
  8012b5:	75 dd                	jne    801294 <readn+0x16>
  8012b7:	eb 02                	jmp    8012bb <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012b9:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8012bb:	89 d8                	mov    %ebx,%eax
  8012bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c0:	5b                   	pop    %ebx
  8012c1:	5e                   	pop    %esi
  8012c2:	5f                   	pop    %edi
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    

008012c5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012c5:	55                   	push   %ebp
  8012c6:	89 e5                	mov    %esp,%ebp
  8012c8:	56                   	push   %esi
  8012c9:	53                   	push   %ebx
  8012ca:	83 ec 18             	sub    $0x18,%esp
  8012cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d3:	50                   	push   %eax
  8012d4:	53                   	push   %ebx
  8012d5:	e8 b9 fc ff ff       	call   800f93 <fd_lookup>
  8012da:	83 c4 10             	add    $0x10,%esp
  8012dd:	85 c0                	test   %eax,%eax
  8012df:	78 37                	js     801318 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e1:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012e4:	83 ec 08             	sub    $0x8,%esp
  8012e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ea:	50                   	push   %eax
  8012eb:	ff 36                	push   (%esi)
  8012ed:	e8 f1 fc ff ff       	call   800fe3 <dev_lookup>
  8012f2:	83 c4 10             	add    $0x10,%esp
  8012f5:	85 c0                	test   %eax,%eax
  8012f7:	78 1f                	js     801318 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012f9:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8012fd:	74 20                	je     80131f <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801302:	8b 40 0c             	mov    0xc(%eax),%eax
  801305:	85 c0                	test   %eax,%eax
  801307:	74 37                	je     801340 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801309:	83 ec 04             	sub    $0x4,%esp
  80130c:	ff 75 10             	push   0x10(%ebp)
  80130f:	ff 75 0c             	push   0xc(%ebp)
  801312:	56                   	push   %esi
  801313:	ff d0                	call   *%eax
  801315:	83 c4 10             	add    $0x10,%esp
}
  801318:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131b:	5b                   	pop    %ebx
  80131c:	5e                   	pop    %esi
  80131d:	5d                   	pop    %ebp
  80131e:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80131f:	a1 00 40 80 00       	mov    0x804000,%eax
  801324:	8b 40 48             	mov    0x48(%eax),%eax
  801327:	83 ec 04             	sub    $0x4,%esp
  80132a:	53                   	push   %ebx
  80132b:	50                   	push   %eax
  80132c:	68 69 24 80 00       	push   $0x802469
  801331:	e8 d0 ee ff ff       	call   800206 <cprintf>
		return -E_INVAL;
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80133e:	eb d8                	jmp    801318 <write+0x53>
		return -E_NOT_SUPP;
  801340:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801345:	eb d1                	jmp    801318 <write+0x53>

00801347 <seek>:

int
seek(int fdnum, off_t offset)
{
  801347:	55                   	push   %ebp
  801348:	89 e5                	mov    %esp,%ebp
  80134a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80134d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801350:	50                   	push   %eax
  801351:	ff 75 08             	push   0x8(%ebp)
  801354:	e8 3a fc ff ff       	call   800f93 <fd_lookup>
  801359:	83 c4 10             	add    $0x10,%esp
  80135c:	85 c0                	test   %eax,%eax
  80135e:	78 0e                	js     80136e <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801360:	8b 55 0c             	mov    0xc(%ebp),%edx
  801363:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801366:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801369:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80136e:	c9                   	leave  
  80136f:	c3                   	ret    

00801370 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801370:	55                   	push   %ebp
  801371:	89 e5                	mov    %esp,%ebp
  801373:	56                   	push   %esi
  801374:	53                   	push   %ebx
  801375:	83 ec 18             	sub    $0x18,%esp
  801378:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80137b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80137e:	50                   	push   %eax
  80137f:	53                   	push   %ebx
  801380:	e8 0e fc ff ff       	call   800f93 <fd_lookup>
  801385:	83 c4 10             	add    $0x10,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	78 34                	js     8013c0 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80138c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80138f:	83 ec 08             	sub    $0x8,%esp
  801392:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801395:	50                   	push   %eax
  801396:	ff 36                	push   (%esi)
  801398:	e8 46 fc ff ff       	call   800fe3 <dev_lookup>
  80139d:	83 c4 10             	add    $0x10,%esp
  8013a0:	85 c0                	test   %eax,%eax
  8013a2:	78 1c                	js     8013c0 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013a4:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8013a8:	74 1d                	je     8013c7 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8013aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ad:	8b 40 18             	mov    0x18(%eax),%eax
  8013b0:	85 c0                	test   %eax,%eax
  8013b2:	74 34                	je     8013e8 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013b4:	83 ec 08             	sub    $0x8,%esp
  8013b7:	ff 75 0c             	push   0xc(%ebp)
  8013ba:	56                   	push   %esi
  8013bb:	ff d0                	call   *%eax
  8013bd:	83 c4 10             	add    $0x10,%esp
}
  8013c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c3:	5b                   	pop    %ebx
  8013c4:	5e                   	pop    %esi
  8013c5:	5d                   	pop    %ebp
  8013c6:	c3                   	ret    
			thisenv->env_id, fdnum);
  8013c7:	a1 00 40 80 00       	mov    0x804000,%eax
  8013cc:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013cf:	83 ec 04             	sub    $0x4,%esp
  8013d2:	53                   	push   %ebx
  8013d3:	50                   	push   %eax
  8013d4:	68 2c 24 80 00       	push   $0x80242c
  8013d9:	e8 28 ee ff ff       	call   800206 <cprintf>
		return -E_INVAL;
  8013de:	83 c4 10             	add    $0x10,%esp
  8013e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e6:	eb d8                	jmp    8013c0 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8013e8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013ed:	eb d1                	jmp    8013c0 <ftruncate+0x50>

008013ef <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	56                   	push   %esi
  8013f3:	53                   	push   %ebx
  8013f4:	83 ec 18             	sub    $0x18,%esp
  8013f7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013fd:	50                   	push   %eax
  8013fe:	ff 75 08             	push   0x8(%ebp)
  801401:	e8 8d fb ff ff       	call   800f93 <fd_lookup>
  801406:	83 c4 10             	add    $0x10,%esp
  801409:	85 c0                	test   %eax,%eax
  80140b:	78 49                	js     801456 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80140d:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801410:	83 ec 08             	sub    $0x8,%esp
  801413:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801416:	50                   	push   %eax
  801417:	ff 36                	push   (%esi)
  801419:	e8 c5 fb ff ff       	call   800fe3 <dev_lookup>
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	85 c0                	test   %eax,%eax
  801423:	78 31                	js     801456 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801425:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801428:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80142c:	74 2f                	je     80145d <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80142e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801431:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801438:	00 00 00 
	stat->st_isdir = 0;
  80143b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801442:	00 00 00 
	stat->st_dev = dev;
  801445:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	53                   	push   %ebx
  80144f:	56                   	push   %esi
  801450:	ff 50 14             	call   *0x14(%eax)
  801453:	83 c4 10             	add    $0x10,%esp
}
  801456:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801459:	5b                   	pop    %ebx
  80145a:	5e                   	pop    %esi
  80145b:	5d                   	pop    %ebp
  80145c:	c3                   	ret    
		return -E_NOT_SUPP;
  80145d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801462:	eb f2                	jmp    801456 <fstat+0x67>

00801464 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801464:	55                   	push   %ebp
  801465:	89 e5                	mov    %esp,%ebp
  801467:	56                   	push   %esi
  801468:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801469:	83 ec 08             	sub    $0x8,%esp
  80146c:	6a 00                	push   $0x0
  80146e:	ff 75 08             	push   0x8(%ebp)
  801471:	e8 e4 01 00 00       	call   80165a <open>
  801476:	89 c3                	mov    %eax,%ebx
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	85 c0                	test   %eax,%eax
  80147d:	78 1b                	js     80149a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80147f:	83 ec 08             	sub    $0x8,%esp
  801482:	ff 75 0c             	push   0xc(%ebp)
  801485:	50                   	push   %eax
  801486:	e8 64 ff ff ff       	call   8013ef <fstat>
  80148b:	89 c6                	mov    %eax,%esi
	close(fd);
  80148d:	89 1c 24             	mov    %ebx,(%esp)
  801490:	e8 26 fc ff ff       	call   8010bb <close>
	return r;
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	89 f3                	mov    %esi,%ebx
}
  80149a:	89 d8                	mov    %ebx,%eax
  80149c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80149f:	5b                   	pop    %ebx
  8014a0:	5e                   	pop    %esi
  8014a1:	5d                   	pop    %ebp
  8014a2:	c3                   	ret    

008014a3 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	56                   	push   %esi
  8014a7:	53                   	push   %ebx
  8014a8:	89 c6                	mov    %eax,%esi
  8014aa:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014ac:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8014b3:	74 27                	je     8014dc <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014b5:	6a 07                	push   $0x7
  8014b7:	68 00 50 80 00       	push   $0x805000
  8014bc:	56                   	push   %esi
  8014bd:	ff 35 00 60 80 00    	push   0x806000
  8014c3:	e8 b5 08 00 00       	call   801d7d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014c8:	83 c4 0c             	add    $0xc,%esp
  8014cb:	6a 00                	push   $0x0
  8014cd:	53                   	push   %ebx
  8014ce:	6a 00                	push   $0x0
  8014d0:	e8 41 08 00 00       	call   801d16 <ipc_recv>
}
  8014d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d8:	5b                   	pop    %ebx
  8014d9:	5e                   	pop    %esi
  8014da:	5d                   	pop    %ebp
  8014db:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014dc:	83 ec 0c             	sub    $0xc,%esp
  8014df:	6a 01                	push   $0x1
  8014e1:	e8 eb 08 00 00       	call   801dd1 <ipc_find_env>
  8014e6:	a3 00 60 80 00       	mov    %eax,0x806000
  8014eb:	83 c4 10             	add    $0x10,%esp
  8014ee:	eb c5                	jmp    8014b5 <fsipc+0x12>

008014f0 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014f9:	8b 40 0c             	mov    0xc(%eax),%eax
  8014fc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801501:	8b 45 0c             	mov    0xc(%ebp),%eax
  801504:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801509:	ba 00 00 00 00       	mov    $0x0,%edx
  80150e:	b8 02 00 00 00       	mov    $0x2,%eax
  801513:	e8 8b ff ff ff       	call   8014a3 <fsipc>
}
  801518:	c9                   	leave  
  801519:	c3                   	ret    

0080151a <devfile_flush>:
{
  80151a:	55                   	push   %ebp
  80151b:	89 e5                	mov    %esp,%ebp
  80151d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801520:	8b 45 08             	mov    0x8(%ebp),%eax
  801523:	8b 40 0c             	mov    0xc(%eax),%eax
  801526:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80152b:	ba 00 00 00 00       	mov    $0x0,%edx
  801530:	b8 06 00 00 00       	mov    $0x6,%eax
  801535:	e8 69 ff ff ff       	call   8014a3 <fsipc>
}
  80153a:	c9                   	leave  
  80153b:	c3                   	ret    

0080153c <devfile_stat>:
{
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	53                   	push   %ebx
  801540:	83 ec 04             	sub    $0x4,%esp
  801543:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801546:	8b 45 08             	mov    0x8(%ebp),%eax
  801549:	8b 40 0c             	mov    0xc(%eax),%eax
  80154c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801551:	ba 00 00 00 00       	mov    $0x0,%edx
  801556:	b8 05 00 00 00       	mov    $0x5,%eax
  80155b:	e8 43 ff ff ff       	call   8014a3 <fsipc>
  801560:	85 c0                	test   %eax,%eax
  801562:	78 2c                	js     801590 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801564:	83 ec 08             	sub    $0x8,%esp
  801567:	68 00 50 80 00       	push   $0x805000
  80156c:	53                   	push   %ebx
  80156d:	e8 6e f2 ff ff       	call   8007e0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801572:	a1 80 50 80 00       	mov    0x805080,%eax
  801577:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80157d:	a1 84 50 80 00       	mov    0x805084,%eax
  801582:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801590:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801593:	c9                   	leave  
  801594:	c3                   	ret    

00801595 <devfile_write>:
{
  801595:	55                   	push   %ebp
  801596:	89 e5                	mov    %esp,%ebp
  801598:	83 ec 0c             	sub    $0xc,%esp
  80159b:	8b 45 10             	mov    0x10(%ebp),%eax
  80159e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8015a3:	39 d0                	cmp    %edx,%eax
  8015a5:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8015ab:	8b 52 0c             	mov    0xc(%edx),%edx
  8015ae:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8015b4:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8015b9:	50                   	push   %eax
  8015ba:	ff 75 0c             	push   0xc(%ebp)
  8015bd:	68 08 50 80 00       	push   $0x805008
  8015c2:	e8 af f3 ff ff       	call   800976 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8015c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015cc:	b8 04 00 00 00       	mov    $0x4,%eax
  8015d1:	e8 cd fe ff ff       	call   8014a3 <fsipc>
}
  8015d6:	c9                   	leave  
  8015d7:	c3                   	ret    

008015d8 <devfile_read>:
{
  8015d8:	55                   	push   %ebp
  8015d9:	89 e5                	mov    %esp,%ebp
  8015db:	56                   	push   %esi
  8015dc:	53                   	push   %ebx
  8015dd:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e3:	8b 40 0c             	mov    0xc(%eax),%eax
  8015e6:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8015eb:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f6:	b8 03 00 00 00       	mov    $0x3,%eax
  8015fb:	e8 a3 fe ff ff       	call   8014a3 <fsipc>
  801600:	89 c3                	mov    %eax,%ebx
  801602:	85 c0                	test   %eax,%eax
  801604:	78 1f                	js     801625 <devfile_read+0x4d>
	assert(r <= n);
  801606:	39 f0                	cmp    %esi,%eax
  801608:	77 24                	ja     80162e <devfile_read+0x56>
	assert(r <= PGSIZE);
  80160a:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80160f:	7f 33                	jg     801644 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801611:	83 ec 04             	sub    $0x4,%esp
  801614:	50                   	push   %eax
  801615:	68 00 50 80 00       	push   $0x805000
  80161a:	ff 75 0c             	push   0xc(%ebp)
  80161d:	e8 54 f3 ff ff       	call   800976 <memmove>
	return r;
  801622:	83 c4 10             	add    $0x10,%esp
}
  801625:	89 d8                	mov    %ebx,%eax
  801627:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162a:	5b                   	pop    %ebx
  80162b:	5e                   	pop    %esi
  80162c:	5d                   	pop    %ebp
  80162d:	c3                   	ret    
	assert(r <= n);
  80162e:	68 98 24 80 00       	push   $0x802498
  801633:	68 9f 24 80 00       	push   $0x80249f
  801638:	6a 7c                	push   $0x7c
  80163a:	68 b4 24 80 00       	push   $0x8024b4
  80163f:	e8 8c 06 00 00       	call   801cd0 <_panic>
	assert(r <= PGSIZE);
  801644:	68 bf 24 80 00       	push   $0x8024bf
  801649:	68 9f 24 80 00       	push   $0x80249f
  80164e:	6a 7d                	push   $0x7d
  801650:	68 b4 24 80 00       	push   $0x8024b4
  801655:	e8 76 06 00 00       	call   801cd0 <_panic>

0080165a <open>:
{
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	56                   	push   %esi
  80165e:	53                   	push   %ebx
  80165f:	83 ec 1c             	sub    $0x1c,%esp
  801662:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801665:	56                   	push   %esi
  801666:	e8 3a f1 ff ff       	call   8007a5 <strlen>
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801673:	7f 6c                	jg     8016e1 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801675:	83 ec 0c             	sub    $0xc,%esp
  801678:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80167b:	50                   	push   %eax
  80167c:	e8 c2 f8 ff ff       	call   800f43 <fd_alloc>
  801681:	89 c3                	mov    %eax,%ebx
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	85 c0                	test   %eax,%eax
  801688:	78 3c                	js     8016c6 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80168a:	83 ec 08             	sub    $0x8,%esp
  80168d:	56                   	push   %esi
  80168e:	68 00 50 80 00       	push   $0x805000
  801693:	e8 48 f1 ff ff       	call   8007e0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801698:	8b 45 0c             	mov    0xc(%ebp),%eax
  80169b:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016a0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8016a8:	e8 f6 fd ff ff       	call   8014a3 <fsipc>
  8016ad:	89 c3                	mov    %eax,%ebx
  8016af:	83 c4 10             	add    $0x10,%esp
  8016b2:	85 c0                	test   %eax,%eax
  8016b4:	78 19                	js     8016cf <open+0x75>
	return fd2num(fd);
  8016b6:	83 ec 0c             	sub    $0xc,%esp
  8016b9:	ff 75 f4             	push   -0xc(%ebp)
  8016bc:	e8 5b f8 ff ff       	call   800f1c <fd2num>
  8016c1:	89 c3                	mov    %eax,%ebx
  8016c3:	83 c4 10             	add    $0x10,%esp
}
  8016c6:	89 d8                	mov    %ebx,%eax
  8016c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016cb:	5b                   	pop    %ebx
  8016cc:	5e                   	pop    %esi
  8016cd:	5d                   	pop    %ebp
  8016ce:	c3                   	ret    
		fd_close(fd, 0);
  8016cf:	83 ec 08             	sub    $0x8,%esp
  8016d2:	6a 00                	push   $0x0
  8016d4:	ff 75 f4             	push   -0xc(%ebp)
  8016d7:	e8 58 f9 ff ff       	call   801034 <fd_close>
		return r;
  8016dc:	83 c4 10             	add    $0x10,%esp
  8016df:	eb e5                	jmp    8016c6 <open+0x6c>
		return -E_BAD_PATH;
  8016e1:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8016e6:	eb de                	jmp    8016c6 <open+0x6c>

008016e8 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f3:	b8 08 00 00 00       	mov    $0x8,%eax
  8016f8:	e8 a6 fd ff ff       	call   8014a3 <fsipc>
}
  8016fd:	c9                   	leave  
  8016fe:	c3                   	ret    

008016ff <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  8016ff:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801703:	7f 01                	jg     801706 <writebuf+0x7>
  801705:	c3                   	ret    
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	53                   	push   %ebx
  80170a:	83 ec 08             	sub    $0x8,%esp
  80170d:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  80170f:	ff 70 04             	push   0x4(%eax)
  801712:	8d 40 10             	lea    0x10(%eax),%eax
  801715:	50                   	push   %eax
  801716:	ff 33                	push   (%ebx)
  801718:	e8 a8 fb ff ff       	call   8012c5 <write>
		if (result > 0)
  80171d:	83 c4 10             	add    $0x10,%esp
  801720:	85 c0                	test   %eax,%eax
  801722:	7e 03                	jle    801727 <writebuf+0x28>
			b->result += result;
  801724:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  801727:	39 43 04             	cmp    %eax,0x4(%ebx)
  80172a:	74 0d                	je     801739 <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  80172c:	85 c0                	test   %eax,%eax
  80172e:	ba 00 00 00 00       	mov    $0x0,%edx
  801733:	0f 4f c2             	cmovg  %edx,%eax
  801736:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  801739:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173c:	c9                   	leave  
  80173d:	c3                   	ret    

0080173e <putch>:

static void
putch(int ch, void *thunk)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	53                   	push   %ebx
  801742:	83 ec 04             	sub    $0x4,%esp
  801745:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801748:	8b 53 04             	mov    0x4(%ebx),%edx
  80174b:	8d 42 01             	lea    0x1(%edx),%eax
  80174e:	89 43 04             	mov    %eax,0x4(%ebx)
  801751:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801754:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801758:	3d 00 01 00 00       	cmp    $0x100,%eax
  80175d:	74 05                	je     801764 <putch+0x26>
		writebuf(b);
		b->idx = 0;
	}
}
  80175f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801762:	c9                   	leave  
  801763:	c3                   	ret    
		writebuf(b);
  801764:	89 d8                	mov    %ebx,%eax
  801766:	e8 94 ff ff ff       	call   8016ff <writebuf>
		b->idx = 0;
  80176b:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  801772:	eb eb                	jmp    80175f <putch+0x21>

00801774 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  801774:	55                   	push   %ebp
  801775:	89 e5                	mov    %esp,%ebp
  801777:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80177d:	8b 45 08             	mov    0x8(%ebp),%eax
  801780:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801786:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80178d:	00 00 00 
	b.result = 0;
  801790:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801797:	00 00 00 
	b.error = 1;
  80179a:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8017a1:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8017a4:	ff 75 10             	push   0x10(%ebp)
  8017a7:	ff 75 0c             	push   0xc(%ebp)
  8017aa:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017b0:	50                   	push   %eax
  8017b1:	68 3e 17 80 00       	push   $0x80173e
  8017b6:	e8 42 eb ff ff       	call   8002fd <vprintfmt>
	if (b.idx > 0)
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8017c5:	7f 11                	jg     8017d8 <vfprintf+0x64>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  8017c7:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8017d6:	c9                   	leave  
  8017d7:	c3                   	ret    
		writebuf(&b);
  8017d8:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8017de:	e8 1c ff ff ff       	call   8016ff <writebuf>
  8017e3:	eb e2                	jmp    8017c7 <vfprintf+0x53>

008017e5 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8017eb:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  8017ee:	50                   	push   %eax
  8017ef:	ff 75 0c             	push   0xc(%ebp)
  8017f2:	ff 75 08             	push   0x8(%ebp)
  8017f5:	e8 7a ff ff ff       	call   801774 <vfprintf>
	va_end(ap);

	return cnt;
}
  8017fa:	c9                   	leave  
  8017fb:	c3                   	ret    

008017fc <printf>:

int
printf(const char *fmt, ...)
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801802:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801805:	50                   	push   %eax
  801806:	ff 75 08             	push   0x8(%ebp)
  801809:	6a 01                	push   $0x1
  80180b:	e8 64 ff ff ff       	call   801774 <vfprintf>
	va_end(ap);

	return cnt;
}
  801810:	c9                   	leave  
  801811:	c3                   	ret    

00801812 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	56                   	push   %esi
  801816:	53                   	push   %ebx
  801817:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80181a:	83 ec 0c             	sub    $0xc,%esp
  80181d:	ff 75 08             	push   0x8(%ebp)
  801820:	e8 07 f7 ff ff       	call   800f2c <fd2data>
  801825:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801827:	83 c4 08             	add    $0x8,%esp
  80182a:	68 cb 24 80 00       	push   $0x8024cb
  80182f:	53                   	push   %ebx
  801830:	e8 ab ef ff ff       	call   8007e0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801835:	8b 46 04             	mov    0x4(%esi),%eax
  801838:	2b 06                	sub    (%esi),%eax
  80183a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801840:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801847:	00 00 00 
	stat->st_dev = &devpipe;
  80184a:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801851:	30 80 00 
	return 0;
}
  801854:	b8 00 00 00 00       	mov    $0x0,%eax
  801859:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80185c:	5b                   	pop    %ebx
  80185d:	5e                   	pop    %esi
  80185e:	5d                   	pop    %ebp
  80185f:	c3                   	ret    

00801860 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	53                   	push   %ebx
  801864:	83 ec 0c             	sub    $0xc,%esp
  801867:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80186a:	53                   	push   %ebx
  80186b:	6a 00                	push   $0x0
  80186d:	e8 ef f3 ff ff       	call   800c61 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801872:	89 1c 24             	mov    %ebx,(%esp)
  801875:	e8 b2 f6 ff ff       	call   800f2c <fd2data>
  80187a:	83 c4 08             	add    $0x8,%esp
  80187d:	50                   	push   %eax
  80187e:	6a 00                	push   $0x0
  801880:	e8 dc f3 ff ff       	call   800c61 <sys_page_unmap>
}
  801885:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801888:	c9                   	leave  
  801889:	c3                   	ret    

0080188a <_pipeisclosed>:
{
  80188a:	55                   	push   %ebp
  80188b:	89 e5                	mov    %esp,%ebp
  80188d:	57                   	push   %edi
  80188e:	56                   	push   %esi
  80188f:	53                   	push   %ebx
  801890:	83 ec 1c             	sub    $0x1c,%esp
  801893:	89 c7                	mov    %eax,%edi
  801895:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801897:	a1 00 40 80 00       	mov    0x804000,%eax
  80189c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80189f:	83 ec 0c             	sub    $0xc,%esp
  8018a2:	57                   	push   %edi
  8018a3:	e8 62 05 00 00       	call   801e0a <pageref>
  8018a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8018ab:	89 34 24             	mov    %esi,(%esp)
  8018ae:	e8 57 05 00 00       	call   801e0a <pageref>
		nn = thisenv->env_runs;
  8018b3:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8018b9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018bc:	83 c4 10             	add    $0x10,%esp
  8018bf:	39 cb                	cmp    %ecx,%ebx
  8018c1:	74 1b                	je     8018de <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8018c3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8018c6:	75 cf                	jne    801897 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018c8:	8b 42 58             	mov    0x58(%edx),%eax
  8018cb:	6a 01                	push   $0x1
  8018cd:	50                   	push   %eax
  8018ce:	53                   	push   %ebx
  8018cf:	68 d2 24 80 00       	push   $0x8024d2
  8018d4:	e8 2d e9 ff ff       	call   800206 <cprintf>
  8018d9:	83 c4 10             	add    $0x10,%esp
  8018dc:	eb b9                	jmp    801897 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8018de:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8018e1:	0f 94 c0             	sete   %al
  8018e4:	0f b6 c0             	movzbl %al,%eax
}
  8018e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ea:	5b                   	pop    %ebx
  8018eb:	5e                   	pop    %esi
  8018ec:	5f                   	pop    %edi
  8018ed:	5d                   	pop    %ebp
  8018ee:	c3                   	ret    

008018ef <devpipe_write>:
{
  8018ef:	55                   	push   %ebp
  8018f0:	89 e5                	mov    %esp,%ebp
  8018f2:	57                   	push   %edi
  8018f3:	56                   	push   %esi
  8018f4:	53                   	push   %ebx
  8018f5:	83 ec 28             	sub    $0x28,%esp
  8018f8:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8018fb:	56                   	push   %esi
  8018fc:	e8 2b f6 ff ff       	call   800f2c <fd2data>
  801901:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801903:	83 c4 10             	add    $0x10,%esp
  801906:	bf 00 00 00 00       	mov    $0x0,%edi
  80190b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80190e:	75 09                	jne    801919 <devpipe_write+0x2a>
	return i;
  801910:	89 f8                	mov    %edi,%eax
  801912:	eb 23                	jmp    801937 <devpipe_write+0x48>
			sys_yield();
  801914:	e8 a4 f2 ff ff       	call   800bbd <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801919:	8b 43 04             	mov    0x4(%ebx),%eax
  80191c:	8b 0b                	mov    (%ebx),%ecx
  80191e:	8d 51 20             	lea    0x20(%ecx),%edx
  801921:	39 d0                	cmp    %edx,%eax
  801923:	72 1a                	jb     80193f <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801925:	89 da                	mov    %ebx,%edx
  801927:	89 f0                	mov    %esi,%eax
  801929:	e8 5c ff ff ff       	call   80188a <_pipeisclosed>
  80192e:	85 c0                	test   %eax,%eax
  801930:	74 e2                	je     801914 <devpipe_write+0x25>
				return 0;
  801932:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801937:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80193a:	5b                   	pop    %ebx
  80193b:	5e                   	pop    %esi
  80193c:	5f                   	pop    %edi
  80193d:	5d                   	pop    %ebp
  80193e:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80193f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801942:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801946:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801949:	89 c2                	mov    %eax,%edx
  80194b:	c1 fa 1f             	sar    $0x1f,%edx
  80194e:	89 d1                	mov    %edx,%ecx
  801950:	c1 e9 1b             	shr    $0x1b,%ecx
  801953:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801956:	83 e2 1f             	and    $0x1f,%edx
  801959:	29 ca                	sub    %ecx,%edx
  80195b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80195f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801963:	83 c0 01             	add    $0x1,%eax
  801966:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801969:	83 c7 01             	add    $0x1,%edi
  80196c:	eb 9d                	jmp    80190b <devpipe_write+0x1c>

0080196e <devpipe_read>:
{
  80196e:	55                   	push   %ebp
  80196f:	89 e5                	mov    %esp,%ebp
  801971:	57                   	push   %edi
  801972:	56                   	push   %esi
  801973:	53                   	push   %ebx
  801974:	83 ec 18             	sub    $0x18,%esp
  801977:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80197a:	57                   	push   %edi
  80197b:	e8 ac f5 ff ff       	call   800f2c <fd2data>
  801980:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801982:	83 c4 10             	add    $0x10,%esp
  801985:	be 00 00 00 00       	mov    $0x0,%esi
  80198a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80198d:	75 13                	jne    8019a2 <devpipe_read+0x34>
	return i;
  80198f:	89 f0                	mov    %esi,%eax
  801991:	eb 02                	jmp    801995 <devpipe_read+0x27>
				return i;
  801993:	89 f0                	mov    %esi,%eax
}
  801995:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801998:	5b                   	pop    %ebx
  801999:	5e                   	pop    %esi
  80199a:	5f                   	pop    %edi
  80199b:	5d                   	pop    %ebp
  80199c:	c3                   	ret    
			sys_yield();
  80199d:	e8 1b f2 ff ff       	call   800bbd <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8019a2:	8b 03                	mov    (%ebx),%eax
  8019a4:	3b 43 04             	cmp    0x4(%ebx),%eax
  8019a7:	75 18                	jne    8019c1 <devpipe_read+0x53>
			if (i > 0)
  8019a9:	85 f6                	test   %esi,%esi
  8019ab:	75 e6                	jne    801993 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8019ad:	89 da                	mov    %ebx,%edx
  8019af:	89 f8                	mov    %edi,%eax
  8019b1:	e8 d4 fe ff ff       	call   80188a <_pipeisclosed>
  8019b6:	85 c0                	test   %eax,%eax
  8019b8:	74 e3                	je     80199d <devpipe_read+0x2f>
				return 0;
  8019ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8019bf:	eb d4                	jmp    801995 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019c1:	99                   	cltd   
  8019c2:	c1 ea 1b             	shr    $0x1b,%edx
  8019c5:	01 d0                	add    %edx,%eax
  8019c7:	83 e0 1f             	and    $0x1f,%eax
  8019ca:	29 d0                	sub    %edx,%eax
  8019cc:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8019d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019d4:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8019d7:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8019da:	83 c6 01             	add    $0x1,%esi
  8019dd:	eb ab                	jmp    80198a <devpipe_read+0x1c>

008019df <pipe>:
{
  8019df:	55                   	push   %ebp
  8019e0:	89 e5                	mov    %esp,%ebp
  8019e2:	56                   	push   %esi
  8019e3:	53                   	push   %ebx
  8019e4:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8019e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019ea:	50                   	push   %eax
  8019eb:	e8 53 f5 ff ff       	call   800f43 <fd_alloc>
  8019f0:	89 c3                	mov    %eax,%ebx
  8019f2:	83 c4 10             	add    $0x10,%esp
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	0f 88 23 01 00 00    	js     801b20 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019fd:	83 ec 04             	sub    $0x4,%esp
  801a00:	68 07 04 00 00       	push   $0x407
  801a05:	ff 75 f4             	push   -0xc(%ebp)
  801a08:	6a 00                	push   $0x0
  801a0a:	e8 cd f1 ff ff       	call   800bdc <sys_page_alloc>
  801a0f:	89 c3                	mov    %eax,%ebx
  801a11:	83 c4 10             	add    $0x10,%esp
  801a14:	85 c0                	test   %eax,%eax
  801a16:	0f 88 04 01 00 00    	js     801b20 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801a1c:	83 ec 0c             	sub    $0xc,%esp
  801a1f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a22:	50                   	push   %eax
  801a23:	e8 1b f5 ff ff       	call   800f43 <fd_alloc>
  801a28:	89 c3                	mov    %eax,%ebx
  801a2a:	83 c4 10             	add    $0x10,%esp
  801a2d:	85 c0                	test   %eax,%eax
  801a2f:	0f 88 db 00 00 00    	js     801b10 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a35:	83 ec 04             	sub    $0x4,%esp
  801a38:	68 07 04 00 00       	push   $0x407
  801a3d:	ff 75 f0             	push   -0x10(%ebp)
  801a40:	6a 00                	push   $0x0
  801a42:	e8 95 f1 ff ff       	call   800bdc <sys_page_alloc>
  801a47:	89 c3                	mov    %eax,%ebx
  801a49:	83 c4 10             	add    $0x10,%esp
  801a4c:	85 c0                	test   %eax,%eax
  801a4e:	0f 88 bc 00 00 00    	js     801b10 <pipe+0x131>
	va = fd2data(fd0);
  801a54:	83 ec 0c             	sub    $0xc,%esp
  801a57:	ff 75 f4             	push   -0xc(%ebp)
  801a5a:	e8 cd f4 ff ff       	call   800f2c <fd2data>
  801a5f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a61:	83 c4 0c             	add    $0xc,%esp
  801a64:	68 07 04 00 00       	push   $0x407
  801a69:	50                   	push   %eax
  801a6a:	6a 00                	push   $0x0
  801a6c:	e8 6b f1 ff ff       	call   800bdc <sys_page_alloc>
  801a71:	89 c3                	mov    %eax,%ebx
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	85 c0                	test   %eax,%eax
  801a78:	0f 88 82 00 00 00    	js     801b00 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a7e:	83 ec 0c             	sub    $0xc,%esp
  801a81:	ff 75 f0             	push   -0x10(%ebp)
  801a84:	e8 a3 f4 ff ff       	call   800f2c <fd2data>
  801a89:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a90:	50                   	push   %eax
  801a91:	6a 00                	push   $0x0
  801a93:	56                   	push   %esi
  801a94:	6a 00                	push   $0x0
  801a96:	e8 84 f1 ff ff       	call   800c1f <sys_page_map>
  801a9b:	89 c3                	mov    %eax,%ebx
  801a9d:	83 c4 20             	add    $0x20,%esp
  801aa0:	85 c0                	test   %eax,%eax
  801aa2:	78 4e                	js     801af2 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801aa4:	a1 20 30 80 00       	mov    0x803020,%eax
  801aa9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aac:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801aae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ab1:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801ab8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801abb:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801abd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ac0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801ac7:	83 ec 0c             	sub    $0xc,%esp
  801aca:	ff 75 f4             	push   -0xc(%ebp)
  801acd:	e8 4a f4 ff ff       	call   800f1c <fd2num>
  801ad2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ad5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ad7:	83 c4 04             	add    $0x4,%esp
  801ada:	ff 75 f0             	push   -0x10(%ebp)
  801add:	e8 3a f4 ff ff       	call   800f1c <fd2num>
  801ae2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ae5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ae8:	83 c4 10             	add    $0x10,%esp
  801aeb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801af0:	eb 2e                	jmp    801b20 <pipe+0x141>
	sys_page_unmap(0, va);
  801af2:	83 ec 08             	sub    $0x8,%esp
  801af5:	56                   	push   %esi
  801af6:	6a 00                	push   $0x0
  801af8:	e8 64 f1 ff ff       	call   800c61 <sys_page_unmap>
  801afd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801b00:	83 ec 08             	sub    $0x8,%esp
  801b03:	ff 75 f0             	push   -0x10(%ebp)
  801b06:	6a 00                	push   $0x0
  801b08:	e8 54 f1 ff ff       	call   800c61 <sys_page_unmap>
  801b0d:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801b10:	83 ec 08             	sub    $0x8,%esp
  801b13:	ff 75 f4             	push   -0xc(%ebp)
  801b16:	6a 00                	push   $0x0
  801b18:	e8 44 f1 ff ff       	call   800c61 <sys_page_unmap>
  801b1d:	83 c4 10             	add    $0x10,%esp
}
  801b20:	89 d8                	mov    %ebx,%eax
  801b22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b25:	5b                   	pop    %ebx
  801b26:	5e                   	pop    %esi
  801b27:	5d                   	pop    %ebp
  801b28:	c3                   	ret    

00801b29 <pipeisclosed>:
{
  801b29:	55                   	push   %ebp
  801b2a:	89 e5                	mov    %esp,%ebp
  801b2c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b2f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b32:	50                   	push   %eax
  801b33:	ff 75 08             	push   0x8(%ebp)
  801b36:	e8 58 f4 ff ff       	call   800f93 <fd_lookup>
  801b3b:	83 c4 10             	add    $0x10,%esp
  801b3e:	85 c0                	test   %eax,%eax
  801b40:	78 18                	js     801b5a <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801b42:	83 ec 0c             	sub    $0xc,%esp
  801b45:	ff 75 f4             	push   -0xc(%ebp)
  801b48:	e8 df f3 ff ff       	call   800f2c <fd2data>
  801b4d:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801b4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b52:	e8 33 fd ff ff       	call   80188a <_pipeisclosed>
  801b57:	83 c4 10             	add    $0x10,%esp
}
  801b5a:	c9                   	leave  
  801b5b:	c3                   	ret    

00801b5c <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801b5c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b61:	c3                   	ret    

00801b62 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b68:	68 ea 24 80 00       	push   $0x8024ea
  801b6d:	ff 75 0c             	push   0xc(%ebp)
  801b70:	e8 6b ec ff ff       	call   8007e0 <strcpy>
	return 0;
}
  801b75:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7a:	c9                   	leave  
  801b7b:	c3                   	ret    

00801b7c <devcons_write>:
{
  801b7c:	55                   	push   %ebp
  801b7d:	89 e5                	mov    %esp,%ebp
  801b7f:	57                   	push   %edi
  801b80:	56                   	push   %esi
  801b81:	53                   	push   %ebx
  801b82:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801b88:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801b8d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801b93:	eb 2e                	jmp    801bc3 <devcons_write+0x47>
		m = n - tot;
  801b95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b98:	29 f3                	sub    %esi,%ebx
  801b9a:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801b9f:	39 c3                	cmp    %eax,%ebx
  801ba1:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ba4:	83 ec 04             	sub    $0x4,%esp
  801ba7:	53                   	push   %ebx
  801ba8:	89 f0                	mov    %esi,%eax
  801baa:	03 45 0c             	add    0xc(%ebp),%eax
  801bad:	50                   	push   %eax
  801bae:	57                   	push   %edi
  801baf:	e8 c2 ed ff ff       	call   800976 <memmove>
		sys_cputs(buf, m);
  801bb4:	83 c4 08             	add    $0x8,%esp
  801bb7:	53                   	push   %ebx
  801bb8:	57                   	push   %edi
  801bb9:	e8 62 ef ff ff       	call   800b20 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801bbe:	01 de                	add    %ebx,%esi
  801bc0:	83 c4 10             	add    $0x10,%esp
  801bc3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bc6:	72 cd                	jb     801b95 <devcons_write+0x19>
}
  801bc8:	89 f0                	mov    %esi,%eax
  801bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcd:	5b                   	pop    %ebx
  801bce:	5e                   	pop    %esi
  801bcf:	5f                   	pop    %edi
  801bd0:	5d                   	pop    %ebp
  801bd1:	c3                   	ret    

00801bd2 <devcons_read>:
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	83 ec 08             	sub    $0x8,%esp
  801bd8:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801bdd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801be1:	75 07                	jne    801bea <devcons_read+0x18>
  801be3:	eb 1f                	jmp    801c04 <devcons_read+0x32>
		sys_yield();
  801be5:	e8 d3 ef ff ff       	call   800bbd <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801bea:	e8 4f ef ff ff       	call   800b3e <sys_cgetc>
  801bef:	85 c0                	test   %eax,%eax
  801bf1:	74 f2                	je     801be5 <devcons_read+0x13>
	if (c < 0)
  801bf3:	78 0f                	js     801c04 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801bf5:	83 f8 04             	cmp    $0x4,%eax
  801bf8:	74 0c                	je     801c06 <devcons_read+0x34>
	*(char*)vbuf = c;
  801bfa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bfd:	88 02                	mov    %al,(%edx)
	return 1;
  801bff:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801c04:	c9                   	leave  
  801c05:	c3                   	ret    
		return 0;
  801c06:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0b:	eb f7                	jmp    801c04 <devcons_read+0x32>

00801c0d <cputchar>:
{
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
  801c10:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c13:	8b 45 08             	mov    0x8(%ebp),%eax
  801c16:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801c19:	6a 01                	push   $0x1
  801c1b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c1e:	50                   	push   %eax
  801c1f:	e8 fc ee ff ff       	call   800b20 <sys_cputs>
}
  801c24:	83 c4 10             	add    $0x10,%esp
  801c27:	c9                   	leave  
  801c28:	c3                   	ret    

00801c29 <getchar>:
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801c2f:	6a 01                	push   $0x1
  801c31:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c34:	50                   	push   %eax
  801c35:	6a 00                	push   $0x0
  801c37:	e8 bb f5 ff ff       	call   8011f7 <read>
	if (r < 0)
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	78 06                	js     801c49 <getchar+0x20>
	if (r < 1)
  801c43:	74 06                	je     801c4b <getchar+0x22>
	return c;
  801c45:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801c49:	c9                   	leave  
  801c4a:	c3                   	ret    
		return -E_EOF;
  801c4b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801c50:	eb f7                	jmp    801c49 <getchar+0x20>

00801c52 <iscons>:
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c58:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c5b:	50                   	push   %eax
  801c5c:	ff 75 08             	push   0x8(%ebp)
  801c5f:	e8 2f f3 ff ff       	call   800f93 <fd_lookup>
  801c64:	83 c4 10             	add    $0x10,%esp
  801c67:	85 c0                	test   %eax,%eax
  801c69:	78 11                	js     801c7c <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c74:	39 10                	cmp    %edx,(%eax)
  801c76:	0f 94 c0             	sete   %al
  801c79:	0f b6 c0             	movzbl %al,%eax
}
  801c7c:	c9                   	leave  
  801c7d:	c3                   	ret    

00801c7e <opencons>:
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801c84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c87:	50                   	push   %eax
  801c88:	e8 b6 f2 ff ff       	call   800f43 <fd_alloc>
  801c8d:	83 c4 10             	add    $0x10,%esp
  801c90:	85 c0                	test   %eax,%eax
  801c92:	78 3a                	js     801cce <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c94:	83 ec 04             	sub    $0x4,%esp
  801c97:	68 07 04 00 00       	push   $0x407
  801c9c:	ff 75 f4             	push   -0xc(%ebp)
  801c9f:	6a 00                	push   $0x0
  801ca1:	e8 36 ef ff ff       	call   800bdc <sys_page_alloc>
  801ca6:	83 c4 10             	add    $0x10,%esp
  801ca9:	85 c0                	test   %eax,%eax
  801cab:	78 21                	js     801cce <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801cad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cb6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801cb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cbb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cc2:	83 ec 0c             	sub    $0xc,%esp
  801cc5:	50                   	push   %eax
  801cc6:	e8 51 f2 ff ff       	call   800f1c <fd2num>
  801ccb:	83 c4 10             	add    $0x10,%esp
}
  801cce:	c9                   	leave  
  801ccf:	c3                   	ret    

00801cd0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	56                   	push   %esi
  801cd4:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801cd5:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801cd8:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801cde:	e8 bb ee ff ff       	call   800b9e <sys_getenvid>
  801ce3:	83 ec 0c             	sub    $0xc,%esp
  801ce6:	ff 75 0c             	push   0xc(%ebp)
  801ce9:	ff 75 08             	push   0x8(%ebp)
  801cec:	56                   	push   %esi
  801ced:	50                   	push   %eax
  801cee:	68 f8 24 80 00       	push   $0x8024f8
  801cf3:	e8 0e e5 ff ff       	call   800206 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801cf8:	83 c4 18             	add    $0x18,%esp
  801cfb:	53                   	push   %ebx
  801cfc:	ff 75 10             	push   0x10(%ebp)
  801cff:	e8 b1 e4 ff ff       	call   8001b5 <vcprintf>
	cprintf("\n");
  801d04:	c7 04 24 b0 20 80 00 	movl   $0x8020b0,(%esp)
  801d0b:	e8 f6 e4 ff ff       	call   800206 <cprintf>
  801d10:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d13:	cc                   	int3   
  801d14:	eb fd                	jmp    801d13 <_panic+0x43>

00801d16 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801d16:	55                   	push   %ebp
  801d17:	89 e5                	mov    %esp,%ebp
  801d19:	56                   	push   %esi
  801d1a:	53                   	push   %ebx
  801d1b:	8b 75 08             	mov    0x8(%ebp),%esi
  801d1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d21:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801d24:	85 c0                	test   %eax,%eax
  801d26:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801d2b:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801d2e:	83 ec 0c             	sub    $0xc,%esp
  801d31:	50                   	push   %eax
  801d32:	e8 55 f0 ff ff       	call   800d8c <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801d37:	83 c4 10             	add    $0x10,%esp
  801d3a:	85 f6                	test   %esi,%esi
  801d3c:	74 14                	je     801d52 <ipc_recv+0x3c>
  801d3e:	ba 00 00 00 00       	mov    $0x0,%edx
  801d43:	85 c0                	test   %eax,%eax
  801d45:	78 09                	js     801d50 <ipc_recv+0x3a>
  801d47:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801d4d:	8b 52 74             	mov    0x74(%edx),%edx
  801d50:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801d52:	85 db                	test   %ebx,%ebx
  801d54:	74 14                	je     801d6a <ipc_recv+0x54>
  801d56:	ba 00 00 00 00       	mov    $0x0,%edx
  801d5b:	85 c0                	test   %eax,%eax
  801d5d:	78 09                	js     801d68 <ipc_recv+0x52>
  801d5f:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801d65:	8b 52 78             	mov    0x78(%edx),%edx
  801d68:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801d6a:	85 c0                	test   %eax,%eax
  801d6c:	78 08                	js     801d76 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801d6e:	a1 00 40 80 00       	mov    0x804000,%eax
  801d73:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d79:	5b                   	pop    %ebx
  801d7a:	5e                   	pop    %esi
  801d7b:	5d                   	pop    %ebp
  801d7c:	c3                   	ret    

00801d7d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d7d:	55                   	push   %ebp
  801d7e:	89 e5                	mov    %esp,%ebp
  801d80:	57                   	push   %edi
  801d81:	56                   	push   %esi
  801d82:	53                   	push   %ebx
  801d83:	83 ec 0c             	sub    $0xc,%esp
  801d86:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d89:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801d8f:	85 db                	test   %ebx,%ebx
  801d91:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801d96:	0f 44 d8             	cmove  %eax,%ebx
  801d99:	eb 05                	jmp    801da0 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801d9b:	e8 1d ee ff ff       	call   800bbd <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801da0:	ff 75 14             	push   0x14(%ebp)
  801da3:	53                   	push   %ebx
  801da4:	56                   	push   %esi
  801da5:	57                   	push   %edi
  801da6:	e8 be ef ff ff       	call   800d69 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801dab:	83 c4 10             	add    $0x10,%esp
  801dae:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801db1:	74 e8                	je     801d9b <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801db3:	85 c0                	test   %eax,%eax
  801db5:	78 08                	js     801dbf <ipc_send+0x42>
	}while (r<0);

}
  801db7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dba:	5b                   	pop    %ebx
  801dbb:	5e                   	pop    %esi
  801dbc:	5f                   	pop    %edi
  801dbd:	5d                   	pop    %ebp
  801dbe:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801dbf:	50                   	push   %eax
  801dc0:	68 1b 25 80 00       	push   $0x80251b
  801dc5:	6a 3d                	push   $0x3d
  801dc7:	68 2f 25 80 00       	push   $0x80252f
  801dcc:	e8 ff fe ff ff       	call   801cd0 <_panic>

00801dd1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801dd7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ddc:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ddf:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801de5:	8b 52 50             	mov    0x50(%edx),%edx
  801de8:	39 ca                	cmp    %ecx,%edx
  801dea:	74 11                	je     801dfd <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801dec:	83 c0 01             	add    $0x1,%eax
  801def:	3d 00 04 00 00       	cmp    $0x400,%eax
  801df4:	75 e6                	jne    801ddc <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801df6:	b8 00 00 00 00       	mov    $0x0,%eax
  801dfb:	eb 0b                	jmp    801e08 <ipc_find_env+0x37>
			return envs[i].env_id;
  801dfd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e00:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e05:	8b 40 48             	mov    0x48(%eax),%eax
}
  801e08:	5d                   	pop    %ebp
  801e09:	c3                   	ret    

00801e0a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e0a:	55                   	push   %ebp
  801e0b:	89 e5                	mov    %esp,%ebp
  801e0d:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e10:	89 c2                	mov    %eax,%edx
  801e12:	c1 ea 16             	shr    $0x16,%edx
  801e15:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801e1c:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801e21:	f6 c1 01             	test   $0x1,%cl
  801e24:	74 1c                	je     801e42 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801e26:	c1 e8 0c             	shr    $0xc,%eax
  801e29:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801e30:	a8 01                	test   $0x1,%al
  801e32:	74 0e                	je     801e42 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e34:	c1 e8 0c             	shr    $0xc,%eax
  801e37:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801e3e:	ef 
  801e3f:	0f b7 d2             	movzwl %dx,%edx
}
  801e42:	89 d0                	mov    %edx,%eax
  801e44:	5d                   	pop    %ebp
  801e45:	c3                   	ret    
  801e46:	66 90                	xchg   %ax,%ax
  801e48:	66 90                	xchg   %ax,%ax
  801e4a:	66 90                	xchg   %ax,%ax
  801e4c:	66 90                	xchg   %ax,%ax
  801e4e:	66 90                	xchg   %ax,%ax

00801e50 <__udivdi3>:
  801e50:	f3 0f 1e fb          	endbr32 
  801e54:	55                   	push   %ebp
  801e55:	57                   	push   %edi
  801e56:	56                   	push   %esi
  801e57:	53                   	push   %ebx
  801e58:	83 ec 1c             	sub    $0x1c,%esp
  801e5b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801e5f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801e63:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e67:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801e6b:	85 c0                	test   %eax,%eax
  801e6d:	75 19                	jne    801e88 <__udivdi3+0x38>
  801e6f:	39 f3                	cmp    %esi,%ebx
  801e71:	76 4d                	jbe    801ec0 <__udivdi3+0x70>
  801e73:	31 ff                	xor    %edi,%edi
  801e75:	89 e8                	mov    %ebp,%eax
  801e77:	89 f2                	mov    %esi,%edx
  801e79:	f7 f3                	div    %ebx
  801e7b:	89 fa                	mov    %edi,%edx
  801e7d:	83 c4 1c             	add    $0x1c,%esp
  801e80:	5b                   	pop    %ebx
  801e81:	5e                   	pop    %esi
  801e82:	5f                   	pop    %edi
  801e83:	5d                   	pop    %ebp
  801e84:	c3                   	ret    
  801e85:	8d 76 00             	lea    0x0(%esi),%esi
  801e88:	39 f0                	cmp    %esi,%eax
  801e8a:	76 14                	jbe    801ea0 <__udivdi3+0x50>
  801e8c:	31 ff                	xor    %edi,%edi
  801e8e:	31 c0                	xor    %eax,%eax
  801e90:	89 fa                	mov    %edi,%edx
  801e92:	83 c4 1c             	add    $0x1c,%esp
  801e95:	5b                   	pop    %ebx
  801e96:	5e                   	pop    %esi
  801e97:	5f                   	pop    %edi
  801e98:	5d                   	pop    %ebp
  801e99:	c3                   	ret    
  801e9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ea0:	0f bd f8             	bsr    %eax,%edi
  801ea3:	83 f7 1f             	xor    $0x1f,%edi
  801ea6:	75 48                	jne    801ef0 <__udivdi3+0xa0>
  801ea8:	39 f0                	cmp    %esi,%eax
  801eaa:	72 06                	jb     801eb2 <__udivdi3+0x62>
  801eac:	31 c0                	xor    %eax,%eax
  801eae:	39 eb                	cmp    %ebp,%ebx
  801eb0:	77 de                	ja     801e90 <__udivdi3+0x40>
  801eb2:	b8 01 00 00 00       	mov    $0x1,%eax
  801eb7:	eb d7                	jmp    801e90 <__udivdi3+0x40>
  801eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ec0:	89 d9                	mov    %ebx,%ecx
  801ec2:	85 db                	test   %ebx,%ebx
  801ec4:	75 0b                	jne    801ed1 <__udivdi3+0x81>
  801ec6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ecb:	31 d2                	xor    %edx,%edx
  801ecd:	f7 f3                	div    %ebx
  801ecf:	89 c1                	mov    %eax,%ecx
  801ed1:	31 d2                	xor    %edx,%edx
  801ed3:	89 f0                	mov    %esi,%eax
  801ed5:	f7 f1                	div    %ecx
  801ed7:	89 c6                	mov    %eax,%esi
  801ed9:	89 e8                	mov    %ebp,%eax
  801edb:	89 f7                	mov    %esi,%edi
  801edd:	f7 f1                	div    %ecx
  801edf:	89 fa                	mov    %edi,%edx
  801ee1:	83 c4 1c             	add    $0x1c,%esp
  801ee4:	5b                   	pop    %ebx
  801ee5:	5e                   	pop    %esi
  801ee6:	5f                   	pop    %edi
  801ee7:	5d                   	pop    %ebp
  801ee8:	c3                   	ret    
  801ee9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ef0:	89 f9                	mov    %edi,%ecx
  801ef2:	ba 20 00 00 00       	mov    $0x20,%edx
  801ef7:	29 fa                	sub    %edi,%edx
  801ef9:	d3 e0                	shl    %cl,%eax
  801efb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eff:	89 d1                	mov    %edx,%ecx
  801f01:	89 d8                	mov    %ebx,%eax
  801f03:	d3 e8                	shr    %cl,%eax
  801f05:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801f09:	09 c1                	or     %eax,%ecx
  801f0b:	89 f0                	mov    %esi,%eax
  801f0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f11:	89 f9                	mov    %edi,%ecx
  801f13:	d3 e3                	shl    %cl,%ebx
  801f15:	89 d1                	mov    %edx,%ecx
  801f17:	d3 e8                	shr    %cl,%eax
  801f19:	89 f9                	mov    %edi,%ecx
  801f1b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801f1f:	89 eb                	mov    %ebp,%ebx
  801f21:	d3 e6                	shl    %cl,%esi
  801f23:	89 d1                	mov    %edx,%ecx
  801f25:	d3 eb                	shr    %cl,%ebx
  801f27:	09 f3                	or     %esi,%ebx
  801f29:	89 c6                	mov    %eax,%esi
  801f2b:	89 f2                	mov    %esi,%edx
  801f2d:	89 d8                	mov    %ebx,%eax
  801f2f:	f7 74 24 08          	divl   0x8(%esp)
  801f33:	89 d6                	mov    %edx,%esi
  801f35:	89 c3                	mov    %eax,%ebx
  801f37:	f7 64 24 0c          	mull   0xc(%esp)
  801f3b:	39 d6                	cmp    %edx,%esi
  801f3d:	72 19                	jb     801f58 <__udivdi3+0x108>
  801f3f:	89 f9                	mov    %edi,%ecx
  801f41:	d3 e5                	shl    %cl,%ebp
  801f43:	39 c5                	cmp    %eax,%ebp
  801f45:	73 04                	jae    801f4b <__udivdi3+0xfb>
  801f47:	39 d6                	cmp    %edx,%esi
  801f49:	74 0d                	je     801f58 <__udivdi3+0x108>
  801f4b:	89 d8                	mov    %ebx,%eax
  801f4d:	31 ff                	xor    %edi,%edi
  801f4f:	e9 3c ff ff ff       	jmp    801e90 <__udivdi3+0x40>
  801f54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801f58:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801f5b:	31 ff                	xor    %edi,%edi
  801f5d:	e9 2e ff ff ff       	jmp    801e90 <__udivdi3+0x40>
  801f62:	66 90                	xchg   %ax,%ax
  801f64:	66 90                	xchg   %ax,%ax
  801f66:	66 90                	xchg   %ax,%ax
  801f68:	66 90                	xchg   %ax,%ax
  801f6a:	66 90                	xchg   %ax,%ax
  801f6c:	66 90                	xchg   %ax,%ax
  801f6e:	66 90                	xchg   %ax,%ax

00801f70 <__umoddi3>:
  801f70:	f3 0f 1e fb          	endbr32 
  801f74:	55                   	push   %ebp
  801f75:	57                   	push   %edi
  801f76:	56                   	push   %esi
  801f77:	53                   	push   %ebx
  801f78:	83 ec 1c             	sub    $0x1c,%esp
  801f7b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801f7f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801f83:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801f87:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801f8b:	89 f0                	mov    %esi,%eax
  801f8d:	89 da                	mov    %ebx,%edx
  801f8f:	85 ff                	test   %edi,%edi
  801f91:	75 15                	jne    801fa8 <__umoddi3+0x38>
  801f93:	39 dd                	cmp    %ebx,%ebp
  801f95:	76 39                	jbe    801fd0 <__umoddi3+0x60>
  801f97:	f7 f5                	div    %ebp
  801f99:	89 d0                	mov    %edx,%eax
  801f9b:	31 d2                	xor    %edx,%edx
  801f9d:	83 c4 1c             	add    $0x1c,%esp
  801fa0:	5b                   	pop    %ebx
  801fa1:	5e                   	pop    %esi
  801fa2:	5f                   	pop    %edi
  801fa3:	5d                   	pop    %ebp
  801fa4:	c3                   	ret    
  801fa5:	8d 76 00             	lea    0x0(%esi),%esi
  801fa8:	39 df                	cmp    %ebx,%edi
  801faa:	77 f1                	ja     801f9d <__umoddi3+0x2d>
  801fac:	0f bd cf             	bsr    %edi,%ecx
  801faf:	83 f1 1f             	xor    $0x1f,%ecx
  801fb2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801fb6:	75 40                	jne    801ff8 <__umoddi3+0x88>
  801fb8:	39 df                	cmp    %ebx,%edi
  801fba:	72 04                	jb     801fc0 <__umoddi3+0x50>
  801fbc:	39 f5                	cmp    %esi,%ebp
  801fbe:	77 dd                	ja     801f9d <__umoddi3+0x2d>
  801fc0:	89 da                	mov    %ebx,%edx
  801fc2:	89 f0                	mov    %esi,%eax
  801fc4:	29 e8                	sub    %ebp,%eax
  801fc6:	19 fa                	sbb    %edi,%edx
  801fc8:	eb d3                	jmp    801f9d <__umoddi3+0x2d>
  801fca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801fd0:	89 e9                	mov    %ebp,%ecx
  801fd2:	85 ed                	test   %ebp,%ebp
  801fd4:	75 0b                	jne    801fe1 <__umoddi3+0x71>
  801fd6:	b8 01 00 00 00       	mov    $0x1,%eax
  801fdb:	31 d2                	xor    %edx,%edx
  801fdd:	f7 f5                	div    %ebp
  801fdf:	89 c1                	mov    %eax,%ecx
  801fe1:	89 d8                	mov    %ebx,%eax
  801fe3:	31 d2                	xor    %edx,%edx
  801fe5:	f7 f1                	div    %ecx
  801fe7:	89 f0                	mov    %esi,%eax
  801fe9:	f7 f1                	div    %ecx
  801feb:	89 d0                	mov    %edx,%eax
  801fed:	31 d2                	xor    %edx,%edx
  801fef:	eb ac                	jmp    801f9d <__umoddi3+0x2d>
  801ff1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ff8:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ffc:	ba 20 00 00 00       	mov    $0x20,%edx
  802001:	29 c2                	sub    %eax,%edx
  802003:	89 c1                	mov    %eax,%ecx
  802005:	89 e8                	mov    %ebp,%eax
  802007:	d3 e7                	shl    %cl,%edi
  802009:	89 d1                	mov    %edx,%ecx
  80200b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80200f:	d3 e8                	shr    %cl,%eax
  802011:	89 c1                	mov    %eax,%ecx
  802013:	8b 44 24 04          	mov    0x4(%esp),%eax
  802017:	09 f9                	or     %edi,%ecx
  802019:	89 df                	mov    %ebx,%edi
  80201b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80201f:	89 c1                	mov    %eax,%ecx
  802021:	d3 e5                	shl    %cl,%ebp
  802023:	89 d1                	mov    %edx,%ecx
  802025:	d3 ef                	shr    %cl,%edi
  802027:	89 c1                	mov    %eax,%ecx
  802029:	89 f0                	mov    %esi,%eax
  80202b:	d3 e3                	shl    %cl,%ebx
  80202d:	89 d1                	mov    %edx,%ecx
  80202f:	89 fa                	mov    %edi,%edx
  802031:	d3 e8                	shr    %cl,%eax
  802033:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802038:	09 d8                	or     %ebx,%eax
  80203a:	f7 74 24 08          	divl   0x8(%esp)
  80203e:	89 d3                	mov    %edx,%ebx
  802040:	d3 e6                	shl    %cl,%esi
  802042:	f7 e5                	mul    %ebp
  802044:	89 c7                	mov    %eax,%edi
  802046:	89 d1                	mov    %edx,%ecx
  802048:	39 d3                	cmp    %edx,%ebx
  80204a:	72 06                	jb     802052 <__umoddi3+0xe2>
  80204c:	75 0e                	jne    80205c <__umoddi3+0xec>
  80204e:	39 c6                	cmp    %eax,%esi
  802050:	73 0a                	jae    80205c <__umoddi3+0xec>
  802052:	29 e8                	sub    %ebp,%eax
  802054:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802058:	89 d1                	mov    %edx,%ecx
  80205a:	89 c7                	mov    %eax,%edi
  80205c:	89 f5                	mov    %esi,%ebp
  80205e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802062:	29 fd                	sub    %edi,%ebp
  802064:	19 cb                	sbb    %ecx,%ebx
  802066:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80206b:	89 d8                	mov    %ebx,%eax
  80206d:	d3 e0                	shl    %cl,%eax
  80206f:	89 f1                	mov    %esi,%ecx
  802071:	d3 ed                	shr    %cl,%ebp
  802073:	d3 eb                	shr    %cl,%ebx
  802075:	09 e8                	or     %ebp,%eax
  802077:	89 da                	mov    %ebx,%edx
  802079:	83 c4 1c             	add    $0x1c,%esp
  80207c:	5b                   	pop    %ebx
  80207d:	5e                   	pop    %esi
  80207e:	5f                   	pop    %edi
  80207f:	5d                   	pop    %ebp
  802080:	c3                   	ret    
