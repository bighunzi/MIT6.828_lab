
obj/user/forktree.debug：     文件格式 elf32-i386


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
  80002c:	e8 b2 00 00 00       	call   8000e3 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <forktree>:
	}
}

void
forktree(const char *cur)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 04             	sub    $0x4,%esp
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("%04x: I am '%s'\n", sys_getenvid(), cur);
  80003d:	e8 31 0b 00 00       	call   800b73 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 00 26 80 00       	push   $0x802600
  80004c:	e8 8a 01 00 00       	call   8001db <cprintf>

	forkchild(cur, '0');
  800051:	83 c4 08             	add    $0x8,%esp
  800054:	6a 30                	push   $0x30
  800056:	53                   	push   %ebx
  800057:	e8 13 00 00 00       	call   80006f <forkchild>
	forkchild(cur, '1');
  80005c:	83 c4 08             	add    $0x8,%esp
  80005f:	6a 31                	push   $0x31
  800061:	53                   	push   %ebx
  800062:	e8 08 00 00 00       	call   80006f <forkchild>
}
  800067:	83 c4 10             	add    $0x10,%esp
  80006a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <forkchild>:
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	83 ec 1c             	sub    $0x1c,%esp
  800077:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80007a:	8b 75 0c             	mov    0xc(%ebp),%esi
	if (strlen(cur) >= DEPTH)
  80007d:	53                   	push   %ebx
  80007e:	e8 f7 06 00 00       	call   80077a <strlen>
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	83 f8 02             	cmp    $0x2,%eax
  800089:	7e 07                	jle    800092 <forkchild+0x23>
}
  80008b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008e:	5b                   	pop    %ebx
  80008f:	5e                   	pop    %esi
  800090:	5d                   	pop    %ebp
  800091:	c3                   	ret    
	snprintf(nxt, DEPTH+1, "%s%c", cur, branch);
  800092:	83 ec 0c             	sub    $0xc,%esp
  800095:	89 f0                	mov    %esi,%eax
  800097:	0f be f0             	movsbl %al,%esi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
  80009c:	68 11 26 80 00       	push   $0x802611
  8000a1:	6a 04                	push   $0x4
  8000a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a6:	50                   	push   %eax
  8000a7:	e8 b4 06 00 00       	call   800760 <snprintf>
	if (fork() == 0) {
  8000ac:	83 c4 20             	add    $0x20,%esp
  8000af:	e8 4d 0e 00 00       	call   800f01 <fork>
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	75 d3                	jne    80008b <forkchild+0x1c>
		forktree(nxt);
  8000b8:	83 ec 0c             	sub    $0xc,%esp
  8000bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000be:	50                   	push   %eax
  8000bf:	e8 6f ff ff ff       	call   800033 <forktree>
		exit();
  8000c4:	e8 63 00 00 00       	call   80012c <exit>
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	eb bd                	jmp    80008b <forkchild+0x1c>

008000ce <umain>:

void
umain(int argc, char **argv)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	83 ec 14             	sub    $0x14,%esp
	forktree("");
  8000d4:	68 10 26 80 00       	push   $0x802610
  8000d9:	e8 55 ff ff ff       	call   800033 <forktree>
}
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	c9                   	leave  
  8000e2:	c3                   	ret    

008000e3 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	56                   	push   %esi
  8000e7:	53                   	push   %ebx
  8000e8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000eb:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ee:	e8 80 0a 00 00       	call   800b73 <sys_getenvid>
  8000f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f8:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8000fe:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800103:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800108:	85 db                	test   %ebx,%ebx
  80010a:	7e 07                	jle    800113 <libmain+0x30>
		binaryname = argv[0];
  80010c:	8b 06                	mov    (%esi),%eax
  80010e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800113:	83 ec 08             	sub    $0x8,%esp
  800116:	56                   	push   %esi
  800117:	53                   	push   %ebx
  800118:	e8 b1 ff ff ff       	call   8000ce <umain>

	// exit gracefully
	exit();
  80011d:	e8 0a 00 00 00       	call   80012c <exit>
}
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800128:	5b                   	pop    %ebx
  800129:	5e                   	pop    %esi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800132:	e8 1e 11 00 00       	call   801255 <close_all>
	sys_env_destroy(0);
  800137:	83 ec 0c             	sub    $0xc,%esp
  80013a:	6a 00                	push   $0x0
  80013c:	e8 f1 09 00 00       	call   800b32 <sys_env_destroy>
}
  800141:	83 c4 10             	add    $0x10,%esp
  800144:	c9                   	leave  
  800145:	c3                   	ret    

00800146 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	53                   	push   %ebx
  80014a:	83 ec 04             	sub    $0x4,%esp
  80014d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800150:	8b 13                	mov    (%ebx),%edx
  800152:	8d 42 01             	lea    0x1(%edx),%eax
  800155:	89 03                	mov    %eax,(%ebx)
  800157:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80015e:	3d ff 00 00 00       	cmp    $0xff,%eax
  800163:	74 09                	je     80016e <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800165:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800169:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80016c:	c9                   	leave  
  80016d:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80016e:	83 ec 08             	sub    $0x8,%esp
  800171:	68 ff 00 00 00       	push   $0xff
  800176:	8d 43 08             	lea    0x8(%ebx),%eax
  800179:	50                   	push   %eax
  80017a:	e8 76 09 00 00       	call   800af5 <sys_cputs>
		b->idx = 0;
  80017f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	eb db                	jmp    800165 <putch+0x1f>

0080018a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800193:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80019a:	00 00 00 
	b.cnt = 0;
  80019d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a7:	ff 75 0c             	push   0xc(%ebp)
  8001aa:	ff 75 08             	push   0x8(%ebp)
  8001ad:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b3:	50                   	push   %eax
  8001b4:	68 46 01 80 00       	push   $0x800146
  8001b9:	e8 14 01 00 00       	call   8002d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001be:	83 c4 08             	add    $0x8,%esp
  8001c1:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001c7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001cd:	50                   	push   %eax
  8001ce:	e8 22 09 00 00       	call   800af5 <sys_cputs>

	return b.cnt;
}
  8001d3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d9:	c9                   	leave  
  8001da:	c3                   	ret    

008001db <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001db:	55                   	push   %ebp
  8001dc:	89 e5                	mov    %esp,%ebp
  8001de:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001e1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e4:	50                   	push   %eax
  8001e5:	ff 75 08             	push   0x8(%ebp)
  8001e8:	e8 9d ff ff ff       	call   80018a <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ed:	c9                   	leave  
  8001ee:	c3                   	ret    

008001ef <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 1c             	sub    $0x1c,%esp
  8001f8:	89 c7                	mov    %eax,%edi
  8001fa:	89 d6                	mov    %edx,%esi
  8001fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800202:	89 d1                	mov    %edx,%ecx
  800204:	89 c2                	mov    %eax,%edx
  800206:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800209:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80020c:	8b 45 10             	mov    0x10(%ebp),%eax
  80020f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800212:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800215:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80021c:	39 c2                	cmp    %eax,%edx
  80021e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800221:	72 3e                	jb     800261 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800223:	83 ec 0c             	sub    $0xc,%esp
  800226:	ff 75 18             	push   0x18(%ebp)
  800229:	83 eb 01             	sub    $0x1,%ebx
  80022c:	53                   	push   %ebx
  80022d:	50                   	push   %eax
  80022e:	83 ec 08             	sub    $0x8,%esp
  800231:	ff 75 e4             	push   -0x1c(%ebp)
  800234:	ff 75 e0             	push   -0x20(%ebp)
  800237:	ff 75 dc             	push   -0x24(%ebp)
  80023a:	ff 75 d8             	push   -0x28(%ebp)
  80023d:	e8 7e 21 00 00       	call   8023c0 <__udivdi3>
  800242:	83 c4 18             	add    $0x18,%esp
  800245:	52                   	push   %edx
  800246:	50                   	push   %eax
  800247:	89 f2                	mov    %esi,%edx
  800249:	89 f8                	mov    %edi,%eax
  80024b:	e8 9f ff ff ff       	call   8001ef <printnum>
  800250:	83 c4 20             	add    $0x20,%esp
  800253:	eb 13                	jmp    800268 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800255:	83 ec 08             	sub    $0x8,%esp
  800258:	56                   	push   %esi
  800259:	ff 75 18             	push   0x18(%ebp)
  80025c:	ff d7                	call   *%edi
  80025e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800261:	83 eb 01             	sub    $0x1,%ebx
  800264:	85 db                	test   %ebx,%ebx
  800266:	7f ed                	jg     800255 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800268:	83 ec 08             	sub    $0x8,%esp
  80026b:	56                   	push   %esi
  80026c:	83 ec 04             	sub    $0x4,%esp
  80026f:	ff 75 e4             	push   -0x1c(%ebp)
  800272:	ff 75 e0             	push   -0x20(%ebp)
  800275:	ff 75 dc             	push   -0x24(%ebp)
  800278:	ff 75 d8             	push   -0x28(%ebp)
  80027b:	e8 60 22 00 00       	call   8024e0 <__umoddi3>
  800280:	83 c4 14             	add    $0x14,%esp
  800283:	0f be 80 20 26 80 00 	movsbl 0x802620(%eax),%eax
  80028a:	50                   	push   %eax
  80028b:	ff d7                	call   *%edi
}
  80028d:	83 c4 10             	add    $0x10,%esp
  800290:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800293:	5b                   	pop    %ebx
  800294:	5e                   	pop    %esi
  800295:	5f                   	pop    %edi
  800296:	5d                   	pop    %ebp
  800297:	c3                   	ret    

00800298 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002a2:	8b 10                	mov    (%eax),%edx
  8002a4:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a7:	73 0a                	jae    8002b3 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a9:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002ac:	89 08                	mov    %ecx,(%eax)
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	88 02                	mov    %al,(%edx)
}
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <printfmt>:
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002bb:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002be:	50                   	push   %eax
  8002bf:	ff 75 10             	push   0x10(%ebp)
  8002c2:	ff 75 0c             	push   0xc(%ebp)
  8002c5:	ff 75 08             	push   0x8(%ebp)
  8002c8:	e8 05 00 00 00       	call   8002d2 <vprintfmt>
}
  8002cd:	83 c4 10             	add    $0x10,%esp
  8002d0:	c9                   	leave  
  8002d1:	c3                   	ret    

008002d2 <vprintfmt>:
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	57                   	push   %edi
  8002d6:	56                   	push   %esi
  8002d7:	53                   	push   %ebx
  8002d8:	83 ec 3c             	sub    $0x3c,%esp
  8002db:	8b 75 08             	mov    0x8(%ebp),%esi
  8002de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002e1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e4:	eb 0a                	jmp    8002f0 <vprintfmt+0x1e>
			putch(ch, putdat);
  8002e6:	83 ec 08             	sub    $0x8,%esp
  8002e9:	53                   	push   %ebx
  8002ea:	50                   	push   %eax
  8002eb:	ff d6                	call   *%esi
  8002ed:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f0:	83 c7 01             	add    $0x1,%edi
  8002f3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f7:	83 f8 25             	cmp    $0x25,%eax
  8002fa:	74 0c                	je     800308 <vprintfmt+0x36>
			if (ch == '\0')
  8002fc:	85 c0                	test   %eax,%eax
  8002fe:	75 e6                	jne    8002e6 <vprintfmt+0x14>
}
  800300:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800303:	5b                   	pop    %ebx
  800304:	5e                   	pop    %esi
  800305:	5f                   	pop    %edi
  800306:	5d                   	pop    %ebp
  800307:	c3                   	ret    
		padc = ' ';
  800308:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80030c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800313:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80031a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800321:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8d 47 01             	lea    0x1(%edi),%eax
  800329:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80032c:	0f b6 17             	movzbl (%edi),%edx
  80032f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800332:	3c 55                	cmp    $0x55,%al
  800334:	0f 87 bb 03 00 00    	ja     8006f5 <vprintfmt+0x423>
  80033a:	0f b6 c0             	movzbl %al,%eax
  80033d:	ff 24 85 60 27 80 00 	jmp    *0x802760(,%eax,4)
  800344:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800347:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80034b:	eb d9                	jmp    800326 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80034d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800350:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800354:	eb d0                	jmp    800326 <vprintfmt+0x54>
  800356:	0f b6 d2             	movzbl %dl,%edx
  800359:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80035c:	b8 00 00 00 00       	mov    $0x0,%eax
  800361:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800364:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800367:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80036b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80036e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800371:	83 f9 09             	cmp    $0x9,%ecx
  800374:	77 55                	ja     8003cb <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800376:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800379:	eb e9                	jmp    800364 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80037b:	8b 45 14             	mov    0x14(%ebp),%eax
  80037e:	8b 00                	mov    (%eax),%eax
  800380:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800383:	8b 45 14             	mov    0x14(%ebp),%eax
  800386:	8d 40 04             	lea    0x4(%eax),%eax
  800389:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80038f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800393:	79 91                	jns    800326 <vprintfmt+0x54>
				width = precision, precision = -1;
  800395:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800398:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003a2:	eb 82                	jmp    800326 <vprintfmt+0x54>
  8003a4:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003a7:	85 d2                	test   %edx,%edx
  8003a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ae:	0f 49 c2             	cmovns %edx,%eax
  8003b1:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b7:	e9 6a ff ff ff       	jmp    800326 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003bf:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003c6:	e9 5b ff ff ff       	jmp    800326 <vprintfmt+0x54>
  8003cb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d1:	eb bc                	jmp    80038f <vprintfmt+0xbd>
			lflag++;
  8003d3:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003d9:	e9 48 ff ff ff       	jmp    800326 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003de:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e1:	8d 78 04             	lea    0x4(%eax),%edi
  8003e4:	83 ec 08             	sub    $0x8,%esp
  8003e7:	53                   	push   %ebx
  8003e8:	ff 30                	push   (%eax)
  8003ea:	ff d6                	call   *%esi
			break;
  8003ec:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003ef:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003f2:	e9 9d 02 00 00       	jmp    800694 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8003f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fa:	8d 78 04             	lea    0x4(%eax),%edi
  8003fd:	8b 10                	mov    (%eax),%edx
  8003ff:	89 d0                	mov    %edx,%eax
  800401:	f7 d8                	neg    %eax
  800403:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800406:	83 f8 0f             	cmp    $0xf,%eax
  800409:	7f 23                	jg     80042e <vprintfmt+0x15c>
  80040b:	8b 14 85 c0 28 80 00 	mov    0x8028c0(,%eax,4),%edx
  800412:	85 d2                	test   %edx,%edx
  800414:	74 18                	je     80042e <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800416:	52                   	push   %edx
  800417:	68 c1 2a 80 00       	push   $0x802ac1
  80041c:	53                   	push   %ebx
  80041d:	56                   	push   %esi
  80041e:	e8 92 fe ff ff       	call   8002b5 <printfmt>
  800423:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800426:	89 7d 14             	mov    %edi,0x14(%ebp)
  800429:	e9 66 02 00 00       	jmp    800694 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80042e:	50                   	push   %eax
  80042f:	68 38 26 80 00       	push   $0x802638
  800434:	53                   	push   %ebx
  800435:	56                   	push   %esi
  800436:	e8 7a fe ff ff       	call   8002b5 <printfmt>
  80043b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043e:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800441:	e9 4e 02 00 00       	jmp    800694 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800446:	8b 45 14             	mov    0x14(%ebp),%eax
  800449:	83 c0 04             	add    $0x4,%eax
  80044c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80044f:	8b 45 14             	mov    0x14(%ebp),%eax
  800452:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800454:	85 d2                	test   %edx,%edx
  800456:	b8 31 26 80 00       	mov    $0x802631,%eax
  80045b:	0f 45 c2             	cmovne %edx,%eax
  80045e:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800461:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800465:	7e 06                	jle    80046d <vprintfmt+0x19b>
  800467:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80046b:	75 0d                	jne    80047a <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80046d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800470:	89 c7                	mov    %eax,%edi
  800472:	03 45 e0             	add    -0x20(%ebp),%eax
  800475:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800478:	eb 55                	jmp    8004cf <vprintfmt+0x1fd>
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	ff 75 d8             	push   -0x28(%ebp)
  800480:	ff 75 cc             	push   -0x34(%ebp)
  800483:	e8 0a 03 00 00       	call   800792 <strnlen>
  800488:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80048b:	29 c1                	sub    %eax,%ecx
  80048d:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800495:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800499:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80049c:	eb 0f                	jmp    8004ad <vprintfmt+0x1db>
					putch(padc, putdat);
  80049e:	83 ec 08             	sub    $0x8,%esp
  8004a1:	53                   	push   %ebx
  8004a2:	ff 75 e0             	push   -0x20(%ebp)
  8004a5:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a7:	83 ef 01             	sub    $0x1,%edi
  8004aa:	83 c4 10             	add    $0x10,%esp
  8004ad:	85 ff                	test   %edi,%edi
  8004af:	7f ed                	jg     80049e <vprintfmt+0x1cc>
  8004b1:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004b4:	85 d2                	test   %edx,%edx
  8004b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bb:	0f 49 c2             	cmovns %edx,%eax
  8004be:	29 c2                	sub    %eax,%edx
  8004c0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004c3:	eb a8                	jmp    80046d <vprintfmt+0x19b>
					putch(ch, putdat);
  8004c5:	83 ec 08             	sub    $0x8,%esp
  8004c8:	53                   	push   %ebx
  8004c9:	52                   	push   %edx
  8004ca:	ff d6                	call   *%esi
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d2:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d4:	83 c7 01             	add    $0x1,%edi
  8004d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004db:	0f be d0             	movsbl %al,%edx
  8004de:	85 d2                	test   %edx,%edx
  8004e0:	74 4b                	je     80052d <vprintfmt+0x25b>
  8004e2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e6:	78 06                	js     8004ee <vprintfmt+0x21c>
  8004e8:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004ec:	78 1e                	js     80050c <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ee:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004f2:	74 d1                	je     8004c5 <vprintfmt+0x1f3>
  8004f4:	0f be c0             	movsbl %al,%eax
  8004f7:	83 e8 20             	sub    $0x20,%eax
  8004fa:	83 f8 5e             	cmp    $0x5e,%eax
  8004fd:	76 c6                	jbe    8004c5 <vprintfmt+0x1f3>
					putch('?', putdat);
  8004ff:	83 ec 08             	sub    $0x8,%esp
  800502:	53                   	push   %ebx
  800503:	6a 3f                	push   $0x3f
  800505:	ff d6                	call   *%esi
  800507:	83 c4 10             	add    $0x10,%esp
  80050a:	eb c3                	jmp    8004cf <vprintfmt+0x1fd>
  80050c:	89 cf                	mov    %ecx,%edi
  80050e:	eb 0e                	jmp    80051e <vprintfmt+0x24c>
				putch(' ', putdat);
  800510:	83 ec 08             	sub    $0x8,%esp
  800513:	53                   	push   %ebx
  800514:	6a 20                	push   $0x20
  800516:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800518:	83 ef 01             	sub    $0x1,%edi
  80051b:	83 c4 10             	add    $0x10,%esp
  80051e:	85 ff                	test   %edi,%edi
  800520:	7f ee                	jg     800510 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800522:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800525:	89 45 14             	mov    %eax,0x14(%ebp)
  800528:	e9 67 01 00 00       	jmp    800694 <vprintfmt+0x3c2>
  80052d:	89 cf                	mov    %ecx,%edi
  80052f:	eb ed                	jmp    80051e <vprintfmt+0x24c>
	if (lflag >= 2)
  800531:	83 f9 01             	cmp    $0x1,%ecx
  800534:	7f 1b                	jg     800551 <vprintfmt+0x27f>
	else if (lflag)
  800536:	85 c9                	test   %ecx,%ecx
  800538:	74 63                	je     80059d <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	8b 00                	mov    (%eax),%eax
  80053f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800542:	99                   	cltd   
  800543:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800546:	8b 45 14             	mov    0x14(%ebp),%eax
  800549:	8d 40 04             	lea    0x4(%eax),%eax
  80054c:	89 45 14             	mov    %eax,0x14(%ebp)
  80054f:	eb 17                	jmp    800568 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8b 50 04             	mov    0x4(%eax),%edx
  800557:	8b 00                	mov    (%eax),%eax
  800559:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80055c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80055f:	8b 45 14             	mov    0x14(%ebp),%eax
  800562:	8d 40 08             	lea    0x8(%eax),%eax
  800565:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800568:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80056b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80056e:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800573:	85 c9                	test   %ecx,%ecx
  800575:	0f 89 ff 00 00 00    	jns    80067a <vprintfmt+0x3a8>
				putch('-', putdat);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	53                   	push   %ebx
  80057f:	6a 2d                	push   $0x2d
  800581:	ff d6                	call   *%esi
				num = -(long long) num;
  800583:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800586:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800589:	f7 da                	neg    %edx
  80058b:	83 d1 00             	adc    $0x0,%ecx
  80058e:	f7 d9                	neg    %ecx
  800590:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800593:	bf 0a 00 00 00       	mov    $0xa,%edi
  800598:	e9 dd 00 00 00       	jmp    80067a <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80059d:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a0:	8b 00                	mov    (%eax),%eax
  8005a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a5:	99                   	cltd   
  8005a6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ac:	8d 40 04             	lea    0x4(%eax),%eax
  8005af:	89 45 14             	mov    %eax,0x14(%ebp)
  8005b2:	eb b4                	jmp    800568 <vprintfmt+0x296>
	if (lflag >= 2)
  8005b4:	83 f9 01             	cmp    $0x1,%ecx
  8005b7:	7f 1e                	jg     8005d7 <vprintfmt+0x305>
	else if (lflag)
  8005b9:	85 c9                	test   %ecx,%ecx
  8005bb:	74 32                	je     8005ef <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8005bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c0:	8b 10                	mov    (%eax),%edx
  8005c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c7:	8d 40 04             	lea    0x4(%eax),%eax
  8005ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005cd:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8005d2:	e9 a3 00 00 00       	jmp    80067a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005da:	8b 10                	mov    (%eax),%edx
  8005dc:	8b 48 04             	mov    0x4(%eax),%ecx
  8005df:	8d 40 08             	lea    0x8(%eax),%eax
  8005e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e5:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8005ea:	e9 8b 00 00 00       	jmp    80067a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8b 10                	mov    (%eax),%edx
  8005f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f9:	8d 40 04             	lea    0x4(%eax),%eax
  8005fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ff:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800604:	eb 74                	jmp    80067a <vprintfmt+0x3a8>
	if (lflag >= 2)
  800606:	83 f9 01             	cmp    $0x1,%ecx
  800609:	7f 1b                	jg     800626 <vprintfmt+0x354>
	else if (lflag)
  80060b:	85 c9                	test   %ecx,%ecx
  80060d:	74 2c                	je     80063b <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8b 10                	mov    (%eax),%edx
  800614:	b9 00 00 00 00       	mov    $0x0,%ecx
  800619:	8d 40 04             	lea    0x4(%eax),%eax
  80061c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80061f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800624:	eb 54                	jmp    80067a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8b 10                	mov    (%eax),%edx
  80062b:	8b 48 04             	mov    0x4(%eax),%ecx
  80062e:	8d 40 08             	lea    0x8(%eax),%eax
  800631:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800634:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800639:	eb 3f                	jmp    80067a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8b 10                	mov    (%eax),%edx
  800640:	b9 00 00 00 00       	mov    $0x0,%ecx
  800645:	8d 40 04             	lea    0x4(%eax),%eax
  800648:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80064b:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800650:	eb 28                	jmp    80067a <vprintfmt+0x3a8>
			putch('0', putdat);
  800652:	83 ec 08             	sub    $0x8,%esp
  800655:	53                   	push   %ebx
  800656:	6a 30                	push   $0x30
  800658:	ff d6                	call   *%esi
			putch('x', putdat);
  80065a:	83 c4 08             	add    $0x8,%esp
  80065d:	53                   	push   %ebx
  80065e:	6a 78                	push   $0x78
  800660:	ff d6                	call   *%esi
			num = (unsigned long long)
  800662:	8b 45 14             	mov    0x14(%ebp),%eax
  800665:	8b 10                	mov    (%eax),%edx
  800667:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80066c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80066f:	8d 40 04             	lea    0x4(%eax),%eax
  800672:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800675:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80067a:	83 ec 0c             	sub    $0xc,%esp
  80067d:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800681:	50                   	push   %eax
  800682:	ff 75 e0             	push   -0x20(%ebp)
  800685:	57                   	push   %edi
  800686:	51                   	push   %ecx
  800687:	52                   	push   %edx
  800688:	89 da                	mov    %ebx,%edx
  80068a:	89 f0                	mov    %esi,%eax
  80068c:	e8 5e fb ff ff       	call   8001ef <printnum>
			break;
  800691:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800694:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800697:	e9 54 fc ff ff       	jmp    8002f0 <vprintfmt+0x1e>
	if (lflag >= 2)
  80069c:	83 f9 01             	cmp    $0x1,%ecx
  80069f:	7f 1b                	jg     8006bc <vprintfmt+0x3ea>
	else if (lflag)
  8006a1:	85 c9                	test   %ecx,%ecx
  8006a3:	74 2c                	je     8006d1 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a8:	8b 10                	mov    (%eax),%edx
  8006aa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006af:	8d 40 04             	lea    0x4(%eax),%eax
  8006b2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b5:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8006ba:	eb be                	jmp    80067a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bf:	8b 10                	mov    (%eax),%edx
  8006c1:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c4:	8d 40 08             	lea    0x8(%eax),%eax
  8006c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006ca:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8006cf:	eb a9                	jmp    80067a <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d4:	8b 10                	mov    (%eax),%edx
  8006d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006db:	8d 40 04             	lea    0x4(%eax),%eax
  8006de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006e1:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8006e6:	eb 92                	jmp    80067a <vprintfmt+0x3a8>
			putch(ch, putdat);
  8006e8:	83 ec 08             	sub    $0x8,%esp
  8006eb:	53                   	push   %ebx
  8006ec:	6a 25                	push   $0x25
  8006ee:	ff d6                	call   *%esi
			break;
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	eb 9f                	jmp    800694 <vprintfmt+0x3c2>
			putch('%', putdat);
  8006f5:	83 ec 08             	sub    $0x8,%esp
  8006f8:	53                   	push   %ebx
  8006f9:	6a 25                	push   $0x25
  8006fb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fd:	83 c4 10             	add    $0x10,%esp
  800700:	89 f8                	mov    %edi,%eax
  800702:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800706:	74 05                	je     80070d <vprintfmt+0x43b>
  800708:	83 e8 01             	sub    $0x1,%eax
  80070b:	eb f5                	jmp    800702 <vprintfmt+0x430>
  80070d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800710:	eb 82                	jmp    800694 <vprintfmt+0x3c2>

00800712 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	83 ec 18             	sub    $0x18,%esp
  800718:	8b 45 08             	mov    0x8(%ebp),%eax
  80071b:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800721:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800725:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800728:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072f:	85 c0                	test   %eax,%eax
  800731:	74 26                	je     800759 <vsnprintf+0x47>
  800733:	85 d2                	test   %edx,%edx
  800735:	7e 22                	jle    800759 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800737:	ff 75 14             	push   0x14(%ebp)
  80073a:	ff 75 10             	push   0x10(%ebp)
  80073d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800740:	50                   	push   %eax
  800741:	68 98 02 80 00       	push   $0x800298
  800746:	e8 87 fb ff ff       	call   8002d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80074e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800751:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800754:	83 c4 10             	add    $0x10,%esp
}
  800757:	c9                   	leave  
  800758:	c3                   	ret    
		return -E_INVAL;
  800759:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075e:	eb f7                	jmp    800757 <vsnprintf+0x45>

00800760 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800766:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800769:	50                   	push   %eax
  80076a:	ff 75 10             	push   0x10(%ebp)
  80076d:	ff 75 0c             	push   0xc(%ebp)
  800770:	ff 75 08             	push   0x8(%ebp)
  800773:	e8 9a ff ff ff       	call   800712 <vsnprintf>
	va_end(ap);

	return rc;
}
  800778:	c9                   	leave  
  800779:	c3                   	ret    

0080077a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077a:	55                   	push   %ebp
  80077b:	89 e5                	mov    %esp,%ebp
  80077d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800780:	b8 00 00 00 00       	mov    $0x0,%eax
  800785:	eb 03                	jmp    80078a <strlen+0x10>
		n++;
  800787:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80078a:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80078e:	75 f7                	jne    800787 <strlen+0xd>
	return n;
}
  800790:	5d                   	pop    %ebp
  800791:	c3                   	ret    

00800792 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800798:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079b:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a0:	eb 03                	jmp    8007a5 <strnlen+0x13>
		n++;
  8007a2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a5:	39 d0                	cmp    %edx,%eax
  8007a7:	74 08                	je     8007b1 <strnlen+0x1f>
  8007a9:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007ad:	75 f3                	jne    8007a2 <strnlen+0x10>
  8007af:	89 c2                	mov    %eax,%edx
	return n;
}
  8007b1:	89 d0                	mov    %edx,%eax
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	53                   	push   %ebx
  8007b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c4:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007c8:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007cb:	83 c0 01             	add    $0x1,%eax
  8007ce:	84 d2                	test   %dl,%dl
  8007d0:	75 f2                	jne    8007c4 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007d2:	89 c8                	mov    %ecx,%eax
  8007d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d7:	c9                   	leave  
  8007d8:	c3                   	ret    

008007d9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d9:	55                   	push   %ebp
  8007da:	89 e5                	mov    %esp,%ebp
  8007dc:	53                   	push   %ebx
  8007dd:	83 ec 10             	sub    $0x10,%esp
  8007e0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e3:	53                   	push   %ebx
  8007e4:	e8 91 ff ff ff       	call   80077a <strlen>
  8007e9:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007ec:	ff 75 0c             	push   0xc(%ebp)
  8007ef:	01 d8                	add    %ebx,%eax
  8007f1:	50                   	push   %eax
  8007f2:	e8 be ff ff ff       	call   8007b5 <strcpy>
	return dst;
}
  8007f7:	89 d8                	mov    %ebx,%eax
  8007f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	56                   	push   %esi
  800802:	53                   	push   %ebx
  800803:	8b 75 08             	mov    0x8(%ebp),%esi
  800806:	8b 55 0c             	mov    0xc(%ebp),%edx
  800809:	89 f3                	mov    %esi,%ebx
  80080b:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080e:	89 f0                	mov    %esi,%eax
  800810:	eb 0f                	jmp    800821 <strncpy+0x23>
		*dst++ = *src;
  800812:	83 c0 01             	add    $0x1,%eax
  800815:	0f b6 0a             	movzbl (%edx),%ecx
  800818:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80081b:	80 f9 01             	cmp    $0x1,%cl
  80081e:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800821:	39 d8                	cmp    %ebx,%eax
  800823:	75 ed                	jne    800812 <strncpy+0x14>
	}
	return ret;
}
  800825:	89 f0                	mov    %esi,%eax
  800827:	5b                   	pop    %ebx
  800828:	5e                   	pop    %esi
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	56                   	push   %esi
  80082f:	53                   	push   %ebx
  800830:	8b 75 08             	mov    0x8(%ebp),%esi
  800833:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800836:	8b 55 10             	mov    0x10(%ebp),%edx
  800839:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80083b:	85 d2                	test   %edx,%edx
  80083d:	74 21                	je     800860 <strlcpy+0x35>
  80083f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800843:	89 f2                	mov    %esi,%edx
  800845:	eb 09                	jmp    800850 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800847:	83 c1 01             	add    $0x1,%ecx
  80084a:	83 c2 01             	add    $0x1,%edx
  80084d:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800850:	39 c2                	cmp    %eax,%edx
  800852:	74 09                	je     80085d <strlcpy+0x32>
  800854:	0f b6 19             	movzbl (%ecx),%ebx
  800857:	84 db                	test   %bl,%bl
  800859:	75 ec                	jne    800847 <strlcpy+0x1c>
  80085b:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80085d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800860:	29 f0                	sub    %esi,%eax
}
  800862:	5b                   	pop    %ebx
  800863:	5e                   	pop    %esi
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086f:	eb 06                	jmp    800877 <strcmp+0x11>
		p++, q++;
  800871:	83 c1 01             	add    $0x1,%ecx
  800874:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800877:	0f b6 01             	movzbl (%ecx),%eax
  80087a:	84 c0                	test   %al,%al
  80087c:	74 04                	je     800882 <strcmp+0x1c>
  80087e:	3a 02                	cmp    (%edx),%al
  800880:	74 ef                	je     800871 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800882:	0f b6 c0             	movzbl %al,%eax
  800885:	0f b6 12             	movzbl (%edx),%edx
  800888:	29 d0                	sub    %edx,%eax
}
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    

0080088c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	53                   	push   %ebx
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	8b 55 0c             	mov    0xc(%ebp),%edx
  800896:	89 c3                	mov    %eax,%ebx
  800898:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80089b:	eb 06                	jmp    8008a3 <strncmp+0x17>
		n--, p++, q++;
  80089d:	83 c0 01             	add    $0x1,%eax
  8008a0:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008a3:	39 d8                	cmp    %ebx,%eax
  8008a5:	74 18                	je     8008bf <strncmp+0x33>
  8008a7:	0f b6 08             	movzbl (%eax),%ecx
  8008aa:	84 c9                	test   %cl,%cl
  8008ac:	74 04                	je     8008b2 <strncmp+0x26>
  8008ae:	3a 0a                	cmp    (%edx),%cl
  8008b0:	74 eb                	je     80089d <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b2:	0f b6 00             	movzbl (%eax),%eax
  8008b5:	0f b6 12             	movzbl (%edx),%edx
  8008b8:	29 d0                	sub    %edx,%eax
}
  8008ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bd:	c9                   	leave  
  8008be:	c3                   	ret    
		return 0;
  8008bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c4:	eb f4                	jmp    8008ba <strncmp+0x2e>

008008c6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d0:	eb 03                	jmp    8008d5 <strchr+0xf>
  8008d2:	83 c0 01             	add    $0x1,%eax
  8008d5:	0f b6 10             	movzbl (%eax),%edx
  8008d8:	84 d2                	test   %dl,%dl
  8008da:	74 06                	je     8008e2 <strchr+0x1c>
		if (*s == c)
  8008dc:	38 ca                	cmp    %cl,%dl
  8008de:	75 f2                	jne    8008d2 <strchr+0xc>
  8008e0:	eb 05                	jmp    8008e7 <strchr+0x21>
			return (char *) s;
	return 0;
  8008e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f3:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f6:	38 ca                	cmp    %cl,%dl
  8008f8:	74 09                	je     800903 <strfind+0x1a>
  8008fa:	84 d2                	test   %dl,%dl
  8008fc:	74 05                	je     800903 <strfind+0x1a>
	for (; *s; s++)
  8008fe:	83 c0 01             	add    $0x1,%eax
  800901:	eb f0                	jmp    8008f3 <strfind+0xa>
			break;
	return (char *) s;
}
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	57                   	push   %edi
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800911:	85 c9                	test   %ecx,%ecx
  800913:	74 2f                	je     800944 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800915:	89 f8                	mov    %edi,%eax
  800917:	09 c8                	or     %ecx,%eax
  800919:	a8 03                	test   $0x3,%al
  80091b:	75 21                	jne    80093e <memset+0x39>
		c &= 0xFF;
  80091d:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800921:	89 d0                	mov    %edx,%eax
  800923:	c1 e0 08             	shl    $0x8,%eax
  800926:	89 d3                	mov    %edx,%ebx
  800928:	c1 e3 18             	shl    $0x18,%ebx
  80092b:	89 d6                	mov    %edx,%esi
  80092d:	c1 e6 10             	shl    $0x10,%esi
  800930:	09 f3                	or     %esi,%ebx
  800932:	09 da                	or     %ebx,%edx
  800934:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800936:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800939:	fc                   	cld    
  80093a:	f3 ab                	rep stos %eax,%es:(%edi)
  80093c:	eb 06                	jmp    800944 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800941:	fc                   	cld    
  800942:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800944:	89 f8                	mov    %edi,%eax
  800946:	5b                   	pop    %ebx
  800947:	5e                   	pop    %esi
  800948:	5f                   	pop    %edi
  800949:	5d                   	pop    %ebp
  80094a:	c3                   	ret    

0080094b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	57                   	push   %edi
  80094f:	56                   	push   %esi
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	8b 75 0c             	mov    0xc(%ebp),%esi
  800956:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800959:	39 c6                	cmp    %eax,%esi
  80095b:	73 32                	jae    80098f <memmove+0x44>
  80095d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800960:	39 c2                	cmp    %eax,%edx
  800962:	76 2b                	jbe    80098f <memmove+0x44>
		s += n;
		d += n;
  800964:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800967:	89 d6                	mov    %edx,%esi
  800969:	09 fe                	or     %edi,%esi
  80096b:	09 ce                	or     %ecx,%esi
  80096d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800973:	75 0e                	jne    800983 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800975:	83 ef 04             	sub    $0x4,%edi
  800978:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80097e:	fd                   	std    
  80097f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800981:	eb 09                	jmp    80098c <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800983:	83 ef 01             	sub    $0x1,%edi
  800986:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800989:	fd                   	std    
  80098a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098c:	fc                   	cld    
  80098d:	eb 1a                	jmp    8009a9 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098f:	89 f2                	mov    %esi,%edx
  800991:	09 c2                	or     %eax,%edx
  800993:	09 ca                	or     %ecx,%edx
  800995:	f6 c2 03             	test   $0x3,%dl
  800998:	75 0a                	jne    8009a4 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80099a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80099d:	89 c7                	mov    %eax,%edi
  80099f:	fc                   	cld    
  8009a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a2:	eb 05                	jmp    8009a9 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009a4:	89 c7                	mov    %eax,%edi
  8009a6:	fc                   	cld    
  8009a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a9:	5e                   	pop    %esi
  8009aa:	5f                   	pop    %edi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009b3:	ff 75 10             	push   0x10(%ebp)
  8009b6:	ff 75 0c             	push   0xc(%ebp)
  8009b9:	ff 75 08             	push   0x8(%ebp)
  8009bc:	e8 8a ff ff ff       	call   80094b <memmove>
}
  8009c1:	c9                   	leave  
  8009c2:	c3                   	ret    

008009c3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c3:	55                   	push   %ebp
  8009c4:	89 e5                	mov    %esp,%ebp
  8009c6:	56                   	push   %esi
  8009c7:	53                   	push   %ebx
  8009c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ce:	89 c6                	mov    %eax,%esi
  8009d0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d3:	eb 06                	jmp    8009db <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009d5:	83 c0 01             	add    $0x1,%eax
  8009d8:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009db:	39 f0                	cmp    %esi,%eax
  8009dd:	74 14                	je     8009f3 <memcmp+0x30>
		if (*s1 != *s2)
  8009df:	0f b6 08             	movzbl (%eax),%ecx
  8009e2:	0f b6 1a             	movzbl (%edx),%ebx
  8009e5:	38 d9                	cmp    %bl,%cl
  8009e7:	74 ec                	je     8009d5 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009e9:	0f b6 c1             	movzbl %cl,%eax
  8009ec:	0f b6 db             	movzbl %bl,%ebx
  8009ef:	29 d8                	sub    %ebx,%eax
  8009f1:	eb 05                	jmp    8009f8 <memcmp+0x35>
	}

	return 0;
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f8:	5b                   	pop    %ebx
  8009f9:	5e                   	pop    %esi
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800a02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a05:	89 c2                	mov    %eax,%edx
  800a07:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a0a:	eb 03                	jmp    800a0f <memfind+0x13>
  800a0c:	83 c0 01             	add    $0x1,%eax
  800a0f:	39 d0                	cmp    %edx,%eax
  800a11:	73 04                	jae    800a17 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a13:	38 08                	cmp    %cl,(%eax)
  800a15:	75 f5                	jne    800a0c <memfind+0x10>
			break;
	return (void *) s;
}
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	57                   	push   %edi
  800a1d:	56                   	push   %esi
  800a1e:	53                   	push   %ebx
  800a1f:	8b 55 08             	mov    0x8(%ebp),%edx
  800a22:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a25:	eb 03                	jmp    800a2a <strtol+0x11>
		s++;
  800a27:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a2a:	0f b6 02             	movzbl (%edx),%eax
  800a2d:	3c 20                	cmp    $0x20,%al
  800a2f:	74 f6                	je     800a27 <strtol+0xe>
  800a31:	3c 09                	cmp    $0x9,%al
  800a33:	74 f2                	je     800a27 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a35:	3c 2b                	cmp    $0x2b,%al
  800a37:	74 2a                	je     800a63 <strtol+0x4a>
	int neg = 0;
  800a39:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a3e:	3c 2d                	cmp    $0x2d,%al
  800a40:	74 2b                	je     800a6d <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a42:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a48:	75 0f                	jne    800a59 <strtol+0x40>
  800a4a:	80 3a 30             	cmpb   $0x30,(%edx)
  800a4d:	74 28                	je     800a77 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4f:	85 db                	test   %ebx,%ebx
  800a51:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a56:	0f 44 d8             	cmove  %eax,%ebx
  800a59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a5e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a61:	eb 46                	jmp    800aa9 <strtol+0x90>
		s++;
  800a63:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a66:	bf 00 00 00 00       	mov    $0x0,%edi
  800a6b:	eb d5                	jmp    800a42 <strtol+0x29>
		s++, neg = 1;
  800a6d:	83 c2 01             	add    $0x1,%edx
  800a70:	bf 01 00 00 00       	mov    $0x1,%edi
  800a75:	eb cb                	jmp    800a42 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a77:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a7b:	74 0e                	je     800a8b <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a7d:	85 db                	test   %ebx,%ebx
  800a7f:	75 d8                	jne    800a59 <strtol+0x40>
		s++, base = 8;
  800a81:	83 c2 01             	add    $0x1,%edx
  800a84:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a89:	eb ce                	jmp    800a59 <strtol+0x40>
		s += 2, base = 16;
  800a8b:	83 c2 02             	add    $0x2,%edx
  800a8e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a93:	eb c4                	jmp    800a59 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a95:	0f be c0             	movsbl %al,%eax
  800a98:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a9b:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a9e:	7d 3a                	jge    800ada <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800aa0:	83 c2 01             	add    $0x1,%edx
  800aa3:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800aa7:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800aa9:	0f b6 02             	movzbl (%edx),%eax
  800aac:	8d 70 d0             	lea    -0x30(%eax),%esi
  800aaf:	89 f3                	mov    %esi,%ebx
  800ab1:	80 fb 09             	cmp    $0x9,%bl
  800ab4:	76 df                	jbe    800a95 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ab6:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ab9:	89 f3                	mov    %esi,%ebx
  800abb:	80 fb 19             	cmp    $0x19,%bl
  800abe:	77 08                	ja     800ac8 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ac0:	0f be c0             	movsbl %al,%eax
  800ac3:	83 e8 57             	sub    $0x57,%eax
  800ac6:	eb d3                	jmp    800a9b <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800ac8:	8d 70 bf             	lea    -0x41(%eax),%esi
  800acb:	89 f3                	mov    %esi,%ebx
  800acd:	80 fb 19             	cmp    $0x19,%bl
  800ad0:	77 08                	ja     800ada <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ad2:	0f be c0             	movsbl %al,%eax
  800ad5:	83 e8 37             	sub    $0x37,%eax
  800ad8:	eb c1                	jmp    800a9b <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ada:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ade:	74 05                	je     800ae5 <strtol+0xcc>
		*endptr = (char *) s;
  800ae0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae3:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ae5:	89 c8                	mov    %ecx,%eax
  800ae7:	f7 d8                	neg    %eax
  800ae9:	85 ff                	test   %edi,%edi
  800aeb:	0f 45 c8             	cmovne %eax,%ecx
}
  800aee:	89 c8                	mov    %ecx,%eax
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5f                   	pop    %edi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	57                   	push   %edi
  800af9:	56                   	push   %esi
  800afa:	53                   	push   %ebx
	asm volatile("int %1\n"
  800afb:	b8 00 00 00 00       	mov    $0x0,%eax
  800b00:	8b 55 08             	mov    0x8(%ebp),%edx
  800b03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b06:	89 c3                	mov    %eax,%ebx
  800b08:	89 c7                	mov    %eax,%edi
  800b0a:	89 c6                	mov    %eax,%esi
  800b0c:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0e:	5b                   	pop    %ebx
  800b0f:	5e                   	pop    %esi
  800b10:	5f                   	pop    %edi
  800b11:	5d                   	pop    %ebp
  800b12:	c3                   	ret    

00800b13 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b13:	55                   	push   %ebp
  800b14:	89 e5                	mov    %esp,%ebp
  800b16:	57                   	push   %edi
  800b17:	56                   	push   %esi
  800b18:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b19:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b23:	89 d1                	mov    %edx,%ecx
  800b25:	89 d3                	mov    %edx,%ebx
  800b27:	89 d7                	mov    %edx,%edi
  800b29:	89 d6                	mov    %edx,%esi
  800b2b:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2d:	5b                   	pop    %ebx
  800b2e:	5e                   	pop    %esi
  800b2f:	5f                   	pop    %edi
  800b30:	5d                   	pop    %ebp
  800b31:	c3                   	ret    

00800b32 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	57                   	push   %edi
  800b36:	56                   	push   %esi
  800b37:	53                   	push   %ebx
  800b38:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b3b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b40:	8b 55 08             	mov    0x8(%ebp),%edx
  800b43:	b8 03 00 00 00       	mov    $0x3,%eax
  800b48:	89 cb                	mov    %ecx,%ebx
  800b4a:	89 cf                	mov    %ecx,%edi
  800b4c:	89 ce                	mov    %ecx,%esi
  800b4e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b50:	85 c0                	test   %eax,%eax
  800b52:	7f 08                	jg     800b5c <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b54:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5f                   	pop    %edi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5c:	83 ec 0c             	sub    $0xc,%esp
  800b5f:	50                   	push   %eax
  800b60:	6a 03                	push   $0x3
  800b62:	68 1f 29 80 00       	push   $0x80291f
  800b67:	6a 2a                	push   $0x2a
  800b69:	68 3c 29 80 00       	push   $0x80293c
  800b6e:	e8 1f 16 00 00       	call   802192 <_panic>

00800b73 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b79:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7e:	b8 02 00 00 00       	mov    $0x2,%eax
  800b83:	89 d1                	mov    %edx,%ecx
  800b85:	89 d3                	mov    %edx,%ebx
  800b87:	89 d7                	mov    %edx,%edi
  800b89:	89 d6                	mov    %edx,%esi
  800b8b:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8d:	5b                   	pop    %ebx
  800b8e:	5e                   	pop    %esi
  800b8f:	5f                   	pop    %edi
  800b90:	5d                   	pop    %ebp
  800b91:	c3                   	ret    

00800b92 <sys_yield>:

void
sys_yield(void)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b98:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ba2:	89 d1                	mov    %edx,%ecx
  800ba4:	89 d3                	mov    %edx,%ebx
  800ba6:	89 d7                	mov    %edx,%edi
  800ba8:	89 d6                	mov    %edx,%esi
  800baa:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bac:	5b                   	pop    %ebx
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb1:	55                   	push   %ebp
  800bb2:	89 e5                	mov    %esp,%ebp
  800bb4:	57                   	push   %edi
  800bb5:	56                   	push   %esi
  800bb6:	53                   	push   %ebx
  800bb7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bba:	be 00 00 00 00       	mov    $0x0,%esi
  800bbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc5:	b8 04 00 00 00       	mov    $0x4,%eax
  800bca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bcd:	89 f7                	mov    %esi,%edi
  800bcf:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bd1:	85 c0                	test   %eax,%eax
  800bd3:	7f 08                	jg     800bdd <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdd:	83 ec 0c             	sub    $0xc,%esp
  800be0:	50                   	push   %eax
  800be1:	6a 04                	push   $0x4
  800be3:	68 1f 29 80 00       	push   $0x80291f
  800be8:	6a 2a                	push   $0x2a
  800bea:	68 3c 29 80 00       	push   $0x80293c
  800bef:	e8 9e 15 00 00       	call   802192 <_panic>

00800bf4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfd:	8b 55 08             	mov    0x8(%ebp),%edx
  800c00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c03:	b8 05 00 00 00       	mov    $0x5,%eax
  800c08:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c0b:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0e:	8b 75 18             	mov    0x18(%ebp),%esi
  800c11:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c13:	85 c0                	test   %eax,%eax
  800c15:	7f 08                	jg     800c1f <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5f                   	pop    %edi
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1f:	83 ec 0c             	sub    $0xc,%esp
  800c22:	50                   	push   %eax
  800c23:	6a 05                	push   $0x5
  800c25:	68 1f 29 80 00       	push   $0x80291f
  800c2a:	6a 2a                	push   $0x2a
  800c2c:	68 3c 29 80 00       	push   $0x80293c
  800c31:	e8 5c 15 00 00       	call   802192 <_panic>

00800c36 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4a:	b8 06 00 00 00       	mov    $0x6,%eax
  800c4f:	89 df                	mov    %ebx,%edi
  800c51:	89 de                	mov    %ebx,%esi
  800c53:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c55:	85 c0                	test   %eax,%eax
  800c57:	7f 08                	jg     800c61 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c61:	83 ec 0c             	sub    $0xc,%esp
  800c64:	50                   	push   %eax
  800c65:	6a 06                	push   $0x6
  800c67:	68 1f 29 80 00       	push   $0x80291f
  800c6c:	6a 2a                	push   $0x2a
  800c6e:	68 3c 29 80 00       	push   $0x80293c
  800c73:	e8 1a 15 00 00       	call   802192 <_panic>

00800c78 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	57                   	push   %edi
  800c7c:	56                   	push   %esi
  800c7d:	53                   	push   %ebx
  800c7e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c81:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c86:	8b 55 08             	mov    0x8(%ebp),%edx
  800c89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c91:	89 df                	mov    %ebx,%edi
  800c93:	89 de                	mov    %ebx,%esi
  800c95:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c97:	85 c0                	test   %eax,%eax
  800c99:	7f 08                	jg     800ca3 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	6a 08                	push   $0x8
  800ca9:	68 1f 29 80 00       	push   $0x80291f
  800cae:	6a 2a                	push   $0x2a
  800cb0:	68 3c 29 80 00       	push   $0x80293c
  800cb5:	e8 d8 14 00 00       	call   802192 <_panic>

00800cba <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cba:	55                   	push   %ebp
  800cbb:	89 e5                	mov    %esp,%ebp
  800cbd:	57                   	push   %edi
  800cbe:	56                   	push   %esi
  800cbf:	53                   	push   %ebx
  800cc0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cce:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd3:	89 df                	mov    %ebx,%edi
  800cd5:	89 de                	mov    %ebx,%esi
  800cd7:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd9:	85 c0                	test   %eax,%eax
  800cdb:	7f 08                	jg     800ce5 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce5:	83 ec 0c             	sub    $0xc,%esp
  800ce8:	50                   	push   %eax
  800ce9:	6a 09                	push   $0x9
  800ceb:	68 1f 29 80 00       	push   $0x80291f
  800cf0:	6a 2a                	push   $0x2a
  800cf2:	68 3c 29 80 00       	push   $0x80293c
  800cf7:	e8 96 14 00 00       	call   802192 <_panic>

00800cfc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	57                   	push   %edi
  800d00:	56                   	push   %esi
  800d01:	53                   	push   %ebx
  800d02:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d10:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d15:	89 df                	mov    %ebx,%edi
  800d17:	89 de                	mov    %ebx,%esi
  800d19:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d1b:	85 c0                	test   %eax,%eax
  800d1d:	7f 08                	jg     800d27 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d1f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d22:	5b                   	pop    %ebx
  800d23:	5e                   	pop    %esi
  800d24:	5f                   	pop    %edi
  800d25:	5d                   	pop    %ebp
  800d26:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d27:	83 ec 0c             	sub    $0xc,%esp
  800d2a:	50                   	push   %eax
  800d2b:	6a 0a                	push   $0xa
  800d2d:	68 1f 29 80 00       	push   $0x80291f
  800d32:	6a 2a                	push   $0x2a
  800d34:	68 3c 29 80 00       	push   $0x80293c
  800d39:	e8 54 14 00 00       	call   802192 <_panic>

00800d3e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
  800d41:	57                   	push   %edi
  800d42:	56                   	push   %esi
  800d43:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4f:	be 00 00 00 00       	mov    $0x0,%esi
  800d54:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d57:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d5a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d5c:	5b                   	pop    %ebx
  800d5d:	5e                   	pop    %esi
  800d5e:	5f                   	pop    %edi
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    

00800d61 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	57                   	push   %edi
  800d65:	56                   	push   %esi
  800d66:	53                   	push   %ebx
  800d67:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d77:	89 cb                	mov    %ecx,%ebx
  800d79:	89 cf                	mov    %ecx,%edi
  800d7b:	89 ce                	mov    %ecx,%esi
  800d7d:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	7f 08                	jg     800d8b <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d86:	5b                   	pop    %ebx
  800d87:	5e                   	pop    %esi
  800d88:	5f                   	pop    %edi
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8b:	83 ec 0c             	sub    $0xc,%esp
  800d8e:	50                   	push   %eax
  800d8f:	6a 0d                	push   $0xd
  800d91:	68 1f 29 80 00       	push   $0x80291f
  800d96:	6a 2a                	push   $0x2a
  800d98:	68 3c 29 80 00       	push   $0x80293c
  800d9d:	e8 f0 13 00 00       	call   802192 <_panic>

00800da2 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800da2:	55                   	push   %ebp
  800da3:	89 e5                	mov    %esp,%ebp
  800da5:	57                   	push   %edi
  800da6:	56                   	push   %esi
  800da7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da8:	ba 00 00 00 00       	mov    $0x0,%edx
  800dad:	b8 0e 00 00 00       	mov    $0xe,%eax
  800db2:	89 d1                	mov    %edx,%ecx
  800db4:	89 d3                	mov    %edx,%ebx
  800db6:	89 d7                	mov    %edx,%edi
  800db8:	89 d6                	mov    %edx,%esi
  800dba:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dbc:	5b                   	pop    %ebx
  800dbd:	5e                   	pop    %esi
  800dbe:	5f                   	pop    %edi
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	57                   	push   %edi
  800dc5:	56                   	push   %esi
  800dc6:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc7:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dcc:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd2:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dd7:	89 df                	mov    %ebx,%edi
  800dd9:	89 de                	mov    %ebx,%esi
  800ddb:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800ddd:	5b                   	pop    %ebx
  800dde:	5e                   	pop    %esi
  800ddf:	5f                   	pop    %edi
  800de0:	5d                   	pop    %ebp
  800de1:	c3                   	ret    

00800de2 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800de8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ded:	8b 55 08             	mov    0x8(%ebp),%edx
  800df0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df3:	b8 10 00 00 00       	mov    $0x10,%eax
  800df8:	89 df                	mov    %ebx,%edi
  800dfa:	89 de                	mov    %ebx,%esi
  800dfc:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800dfe:	5b                   	pop    %ebx
  800dff:	5e                   	pop    %esi
  800e00:	5f                   	pop    %edi
  800e01:	5d                   	pop    %ebp
  800e02:	c3                   	ret    

00800e03 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e03:	55                   	push   %ebp
  800e04:	89 e5                	mov    %esp,%ebp
  800e06:	56                   	push   %esi
  800e07:	53                   	push   %ebx
  800e08:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e0b:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e0d:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e11:	0f 84 8e 00 00 00    	je     800ea5 <pgfault+0xa2>
  800e17:	89 f0                	mov    %esi,%eax
  800e19:	c1 e8 0c             	shr    $0xc,%eax
  800e1c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e23:	f6 c4 08             	test   $0x8,%ah
  800e26:	74 7d                	je     800ea5 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800e28:	e8 46 fd ff ff       	call   800b73 <sys_getenvid>
  800e2d:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800e2f:	83 ec 04             	sub    $0x4,%esp
  800e32:	6a 07                	push   $0x7
  800e34:	68 00 f0 7f 00       	push   $0x7ff000
  800e39:	50                   	push   %eax
  800e3a:	e8 72 fd ff ff       	call   800bb1 <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e3f:	83 c4 10             	add    $0x10,%esp
  800e42:	85 c0                	test   %eax,%eax
  800e44:	78 73                	js     800eb9 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800e46:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800e4c:	83 ec 04             	sub    $0x4,%esp
  800e4f:	68 00 10 00 00       	push   $0x1000
  800e54:	56                   	push   %esi
  800e55:	68 00 f0 7f 00       	push   $0x7ff000
  800e5a:	e8 ec fa ff ff       	call   80094b <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800e5f:	83 c4 08             	add    $0x8,%esp
  800e62:	56                   	push   %esi
  800e63:	53                   	push   %ebx
  800e64:	e8 cd fd ff ff       	call   800c36 <sys_page_unmap>
  800e69:	83 c4 10             	add    $0x10,%esp
  800e6c:	85 c0                	test   %eax,%eax
  800e6e:	78 5b                	js     800ecb <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800e70:	83 ec 0c             	sub    $0xc,%esp
  800e73:	6a 07                	push   $0x7
  800e75:	56                   	push   %esi
  800e76:	53                   	push   %ebx
  800e77:	68 00 f0 7f 00       	push   $0x7ff000
  800e7c:	53                   	push   %ebx
  800e7d:	e8 72 fd ff ff       	call   800bf4 <sys_page_map>
  800e82:	83 c4 20             	add    $0x20,%esp
  800e85:	85 c0                	test   %eax,%eax
  800e87:	78 54                	js     800edd <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800e89:	83 ec 08             	sub    $0x8,%esp
  800e8c:	68 00 f0 7f 00       	push   $0x7ff000
  800e91:	53                   	push   %ebx
  800e92:	e8 9f fd ff ff       	call   800c36 <sys_page_unmap>
  800e97:	83 c4 10             	add    $0x10,%esp
  800e9a:	85 c0                	test   %eax,%eax
  800e9c:	78 51                	js     800eef <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800e9e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ea1:	5b                   	pop    %ebx
  800ea2:	5e                   	pop    %esi
  800ea3:	5d                   	pop    %ebp
  800ea4:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800ea5:	83 ec 04             	sub    $0x4,%esp
  800ea8:	68 4c 29 80 00       	push   $0x80294c
  800ead:	6a 1d                	push   $0x1d
  800eaf:	68 c8 29 80 00       	push   $0x8029c8
  800eb4:	e8 d9 12 00 00       	call   802192 <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800eb9:	50                   	push   %eax
  800eba:	68 84 29 80 00       	push   $0x802984
  800ebf:	6a 29                	push   $0x29
  800ec1:	68 c8 29 80 00       	push   $0x8029c8
  800ec6:	e8 c7 12 00 00       	call   802192 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800ecb:	50                   	push   %eax
  800ecc:	68 a8 29 80 00       	push   $0x8029a8
  800ed1:	6a 2e                	push   $0x2e
  800ed3:	68 c8 29 80 00       	push   $0x8029c8
  800ed8:	e8 b5 12 00 00       	call   802192 <_panic>
		panic("pgfault: page map failed (%e)", r);
  800edd:	50                   	push   %eax
  800ede:	68 d3 29 80 00       	push   $0x8029d3
  800ee3:	6a 30                	push   $0x30
  800ee5:	68 c8 29 80 00       	push   $0x8029c8
  800eea:	e8 a3 12 00 00       	call   802192 <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800eef:	50                   	push   %eax
  800ef0:	68 a8 29 80 00       	push   $0x8029a8
  800ef5:	6a 32                	push   $0x32
  800ef7:	68 c8 29 80 00       	push   $0x8029c8
  800efc:	e8 91 12 00 00       	call   802192 <_panic>

00800f01 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	57                   	push   %edi
  800f05:	56                   	push   %esi
  800f06:	53                   	push   %ebx
  800f07:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800f0a:	68 03 0e 80 00       	push   $0x800e03
  800f0f:	e8 c4 12 00 00       	call   8021d8 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f14:	b8 07 00 00 00       	mov    $0x7,%eax
  800f19:	cd 30                	int    $0x30
  800f1b:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800f1e:	83 c4 10             	add    $0x10,%esp
  800f21:	85 c0                	test   %eax,%eax
  800f23:	78 30                	js     800f55 <fork+0x54>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f25:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800f2a:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f2e:	75 76                	jne    800fa6 <fork+0xa5>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f30:	e8 3e fc ff ff       	call   800b73 <sys_getenvid>
  800f35:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f3a:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800f40:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f45:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  800f4a:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800f4d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f50:	5b                   	pop    %ebx
  800f51:	5e                   	pop    %esi
  800f52:	5f                   	pop    %edi
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  800f55:	50                   	push   %eax
  800f56:	68 f1 29 80 00       	push   $0x8029f1
  800f5b:	6a 78                	push   $0x78
  800f5d:	68 c8 29 80 00       	push   $0x8029c8
  800f62:	e8 2b 12 00 00       	call   802192 <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  800f67:	83 ec 0c             	sub    $0xc,%esp
  800f6a:	ff 75 e4             	push   -0x1c(%ebp)
  800f6d:	57                   	push   %edi
  800f6e:	ff 75 dc             	push   -0x24(%ebp)
  800f71:	57                   	push   %edi
  800f72:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800f75:	56                   	push   %esi
  800f76:	e8 79 fc ff ff       	call   800bf4 <sys_page_map>
	if(r<0) return r;
  800f7b:	83 c4 20             	add    $0x20,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	78 cb                	js     800f4d <fork+0x4c>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  800f82:	83 ec 0c             	sub    $0xc,%esp
  800f85:	ff 75 e4             	push   -0x1c(%ebp)
  800f88:	57                   	push   %edi
  800f89:	56                   	push   %esi
  800f8a:	57                   	push   %edi
  800f8b:	56                   	push   %esi
  800f8c:	e8 63 fc ff ff       	call   800bf4 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800f91:	83 c4 20             	add    $0x20,%esp
  800f94:	85 c0                	test   %eax,%eax
  800f96:	78 76                	js     80100e <fork+0x10d>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f98:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f9e:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800fa4:	74 75                	je     80101b <fork+0x11a>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800fa6:	89 d8                	mov    %ebx,%eax
  800fa8:	c1 e8 16             	shr    $0x16,%eax
  800fab:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fb2:	a8 01                	test   $0x1,%al
  800fb4:	74 e2                	je     800f98 <fork+0x97>
  800fb6:	89 de                	mov    %ebx,%esi
  800fb8:	c1 ee 0c             	shr    $0xc,%esi
  800fbb:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fc2:	a8 01                	test   $0x1,%al
  800fc4:	74 d2                	je     800f98 <fork+0x97>
	envid_t this_envid = sys_getenvid();//父进程号
  800fc6:	e8 a8 fb ff ff       	call   800b73 <sys_getenvid>
  800fcb:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  800fce:	89 f7                	mov    %esi,%edi
  800fd0:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  800fd3:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fda:	89 c1                	mov    %eax,%ecx
  800fdc:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  800fe2:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  800fe5:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  800fec:	f6 c6 04             	test   $0x4,%dh
  800fef:	0f 85 72 ff ff ff    	jne    800f67 <fork+0x66>
		perm &= ~PTE_W;
  800ff5:	25 05 0e 00 00       	and    $0xe05,%eax
  800ffa:	80 cc 08             	or     $0x8,%ah
  800ffd:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  801003:	0f 44 c1             	cmove  %ecx,%eax
  801006:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801009:	e9 59 ff ff ff       	jmp    800f67 <fork+0x66>
  80100e:	ba 00 00 00 00       	mov    $0x0,%edx
  801013:	0f 4f c2             	cmovg  %edx,%eax
  801016:	e9 32 ff ff ff       	jmp    800f4d <fork+0x4c>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  80101b:	83 ec 04             	sub    $0x4,%esp
  80101e:	6a 07                	push   $0x7
  801020:	68 00 f0 bf ee       	push   $0xeebff000
  801025:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801028:	57                   	push   %edi
  801029:	e8 83 fb ff ff       	call   800bb1 <sys_page_alloc>
	if(r<0) return r;
  80102e:	83 c4 10             	add    $0x10,%esp
  801031:	85 c0                	test   %eax,%eax
  801033:	0f 88 14 ff ff ff    	js     800f4d <fork+0x4c>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801039:	83 ec 08             	sub    $0x8,%esp
  80103c:	68 4e 22 80 00       	push   $0x80224e
  801041:	57                   	push   %edi
  801042:	e8 b5 fc ff ff       	call   800cfc <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801047:	83 c4 10             	add    $0x10,%esp
  80104a:	85 c0                	test   %eax,%eax
  80104c:	0f 88 fb fe ff ff    	js     800f4d <fork+0x4c>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  801052:	83 ec 08             	sub    $0x8,%esp
  801055:	6a 02                	push   $0x2
  801057:	57                   	push   %edi
  801058:	e8 1b fc ff ff       	call   800c78 <sys_env_set_status>
	if(r<0) return r;
  80105d:	83 c4 10             	add    $0x10,%esp
	return envid;
  801060:	85 c0                	test   %eax,%eax
  801062:	0f 49 c7             	cmovns %edi,%eax
  801065:	e9 e3 fe ff ff       	jmp    800f4d <fork+0x4c>

0080106a <sfork>:

// Challenge!
int
sfork(void)
{
  80106a:	55                   	push   %ebp
  80106b:	89 e5                	mov    %esp,%ebp
  80106d:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801070:	68 01 2a 80 00       	push   $0x802a01
  801075:	68 a1 00 00 00       	push   $0xa1
  80107a:	68 c8 29 80 00       	push   $0x8029c8
  80107f:	e8 0e 11 00 00       	call   802192 <_panic>

00801084 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801087:	8b 45 08             	mov    0x8(%ebp),%eax
  80108a:	05 00 00 00 30       	add    $0x30000000,%eax
  80108f:	c1 e8 0c             	shr    $0xc,%eax
}
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801097:	8b 45 08             	mov    0x8(%ebp),%eax
  80109a:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80109f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8010a4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010a9:	5d                   	pop    %ebp
  8010aa:	c3                   	ret    

008010ab <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010ab:	55                   	push   %ebp
  8010ac:	89 e5                	mov    %esp,%ebp
  8010ae:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010b3:	89 c2                	mov    %eax,%edx
  8010b5:	c1 ea 16             	shr    $0x16,%edx
  8010b8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010bf:	f6 c2 01             	test   $0x1,%dl
  8010c2:	74 29                	je     8010ed <fd_alloc+0x42>
  8010c4:	89 c2                	mov    %eax,%edx
  8010c6:	c1 ea 0c             	shr    $0xc,%edx
  8010c9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010d0:	f6 c2 01             	test   $0x1,%dl
  8010d3:	74 18                	je     8010ed <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8010d5:	05 00 10 00 00       	add    $0x1000,%eax
  8010da:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010df:	75 d2                	jne    8010b3 <fd_alloc+0x8>
  8010e1:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8010e6:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8010eb:	eb 05                	jmp    8010f2 <fd_alloc+0x47>
			return 0;
  8010ed:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8010f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f5:	89 02                	mov    %eax,(%edx)
}
  8010f7:	89 c8                	mov    %ecx,%eax
  8010f9:	5d                   	pop    %ebp
  8010fa:	c3                   	ret    

008010fb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010fb:	55                   	push   %ebp
  8010fc:	89 e5                	mov    %esp,%ebp
  8010fe:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801101:	83 f8 1f             	cmp    $0x1f,%eax
  801104:	77 30                	ja     801136 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801106:	c1 e0 0c             	shl    $0xc,%eax
  801109:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80110e:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801114:	f6 c2 01             	test   $0x1,%dl
  801117:	74 24                	je     80113d <fd_lookup+0x42>
  801119:	89 c2                	mov    %eax,%edx
  80111b:	c1 ea 0c             	shr    $0xc,%edx
  80111e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801125:	f6 c2 01             	test   $0x1,%dl
  801128:	74 1a                	je     801144 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80112a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80112d:	89 02                	mov    %eax,(%edx)
	return 0;
  80112f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801134:	5d                   	pop    %ebp
  801135:	c3                   	ret    
		return -E_INVAL;
  801136:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80113b:	eb f7                	jmp    801134 <fd_lookup+0x39>
		return -E_INVAL;
  80113d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801142:	eb f0                	jmp    801134 <fd_lookup+0x39>
  801144:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801149:	eb e9                	jmp    801134 <fd_lookup+0x39>

0080114b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80114b:	55                   	push   %ebp
  80114c:	89 e5                	mov    %esp,%ebp
  80114e:	53                   	push   %ebx
  80114f:	83 ec 04             	sub    $0x4,%esp
  801152:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801155:	b8 00 00 00 00       	mov    $0x0,%eax
  80115a:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80115f:	39 13                	cmp    %edx,(%ebx)
  801161:	74 37                	je     80119a <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  801163:	83 c0 01             	add    $0x1,%eax
  801166:	8b 1c 85 94 2a 80 00 	mov    0x802a94(,%eax,4),%ebx
  80116d:	85 db                	test   %ebx,%ebx
  80116f:	75 ee                	jne    80115f <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801171:	a1 00 40 80 00       	mov    0x804000,%eax
  801176:	8b 40 58             	mov    0x58(%eax),%eax
  801179:	83 ec 04             	sub    $0x4,%esp
  80117c:	52                   	push   %edx
  80117d:	50                   	push   %eax
  80117e:	68 18 2a 80 00       	push   $0x802a18
  801183:	e8 53 f0 ff ff       	call   8001db <cprintf>
	*dev = 0;
	return -E_INVAL;
  801188:	83 c4 10             	add    $0x10,%esp
  80118b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801190:	8b 55 0c             	mov    0xc(%ebp),%edx
  801193:	89 1a                	mov    %ebx,(%edx)
}
  801195:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801198:	c9                   	leave  
  801199:	c3                   	ret    
			return 0;
  80119a:	b8 00 00 00 00       	mov    $0x0,%eax
  80119f:	eb ef                	jmp    801190 <dev_lookup+0x45>

008011a1 <fd_close>:
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	57                   	push   %edi
  8011a5:	56                   	push   %esi
  8011a6:	53                   	push   %ebx
  8011a7:	83 ec 24             	sub    $0x24,%esp
  8011aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ad:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011b0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011b3:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011b4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011ba:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011bd:	50                   	push   %eax
  8011be:	e8 38 ff ff ff       	call   8010fb <fd_lookup>
  8011c3:	89 c3                	mov    %eax,%ebx
  8011c5:	83 c4 10             	add    $0x10,%esp
  8011c8:	85 c0                	test   %eax,%eax
  8011ca:	78 05                	js     8011d1 <fd_close+0x30>
	    || fd != fd2)
  8011cc:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8011cf:	74 16                	je     8011e7 <fd_close+0x46>
		return (must_exist ? r : 0);
  8011d1:	89 f8                	mov    %edi,%eax
  8011d3:	84 c0                	test   %al,%al
  8011d5:	b8 00 00 00 00       	mov    $0x0,%eax
  8011da:	0f 44 d8             	cmove  %eax,%ebx
}
  8011dd:	89 d8                	mov    %ebx,%eax
  8011df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e2:	5b                   	pop    %ebx
  8011e3:	5e                   	pop    %esi
  8011e4:	5f                   	pop    %edi
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011e7:	83 ec 08             	sub    $0x8,%esp
  8011ea:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8011ed:	50                   	push   %eax
  8011ee:	ff 36                	push   (%esi)
  8011f0:	e8 56 ff ff ff       	call   80114b <dev_lookup>
  8011f5:	89 c3                	mov    %eax,%ebx
  8011f7:	83 c4 10             	add    $0x10,%esp
  8011fa:	85 c0                	test   %eax,%eax
  8011fc:	78 1a                	js     801218 <fd_close+0x77>
		if (dev->dev_close)
  8011fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801201:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801204:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801209:	85 c0                	test   %eax,%eax
  80120b:	74 0b                	je     801218 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80120d:	83 ec 0c             	sub    $0xc,%esp
  801210:	56                   	push   %esi
  801211:	ff d0                	call   *%eax
  801213:	89 c3                	mov    %eax,%ebx
  801215:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801218:	83 ec 08             	sub    $0x8,%esp
  80121b:	56                   	push   %esi
  80121c:	6a 00                	push   $0x0
  80121e:	e8 13 fa ff ff       	call   800c36 <sys_page_unmap>
	return r;
  801223:	83 c4 10             	add    $0x10,%esp
  801226:	eb b5                	jmp    8011dd <fd_close+0x3c>

00801228 <close>:

int
close(int fdnum)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80122e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801231:	50                   	push   %eax
  801232:	ff 75 08             	push   0x8(%ebp)
  801235:	e8 c1 fe ff ff       	call   8010fb <fd_lookup>
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	85 c0                	test   %eax,%eax
  80123f:	79 02                	jns    801243 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801241:	c9                   	leave  
  801242:	c3                   	ret    
		return fd_close(fd, 1);
  801243:	83 ec 08             	sub    $0x8,%esp
  801246:	6a 01                	push   $0x1
  801248:	ff 75 f4             	push   -0xc(%ebp)
  80124b:	e8 51 ff ff ff       	call   8011a1 <fd_close>
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	eb ec                	jmp    801241 <close+0x19>

00801255 <close_all>:

void
close_all(void)
{
  801255:	55                   	push   %ebp
  801256:	89 e5                	mov    %esp,%ebp
  801258:	53                   	push   %ebx
  801259:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80125c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801261:	83 ec 0c             	sub    $0xc,%esp
  801264:	53                   	push   %ebx
  801265:	e8 be ff ff ff       	call   801228 <close>
	for (i = 0; i < MAXFD; i++)
  80126a:	83 c3 01             	add    $0x1,%ebx
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	83 fb 20             	cmp    $0x20,%ebx
  801273:	75 ec                	jne    801261 <close_all+0xc>
}
  801275:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801278:	c9                   	leave  
  801279:	c3                   	ret    

0080127a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	57                   	push   %edi
  80127e:	56                   	push   %esi
  80127f:	53                   	push   %ebx
  801280:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801283:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801286:	50                   	push   %eax
  801287:	ff 75 08             	push   0x8(%ebp)
  80128a:	e8 6c fe ff ff       	call   8010fb <fd_lookup>
  80128f:	89 c3                	mov    %eax,%ebx
  801291:	83 c4 10             	add    $0x10,%esp
  801294:	85 c0                	test   %eax,%eax
  801296:	78 7f                	js     801317 <dup+0x9d>
		return r;
	close(newfdnum);
  801298:	83 ec 0c             	sub    $0xc,%esp
  80129b:	ff 75 0c             	push   0xc(%ebp)
  80129e:	e8 85 ff ff ff       	call   801228 <close>

	newfd = INDEX2FD(newfdnum);
  8012a3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012a6:	c1 e6 0c             	shl    $0xc,%esi
  8012a9:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8012af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012b2:	89 3c 24             	mov    %edi,(%esp)
  8012b5:	e8 da fd ff ff       	call   801094 <fd2data>
  8012ba:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012bc:	89 34 24             	mov    %esi,(%esp)
  8012bf:	e8 d0 fd ff ff       	call   801094 <fd2data>
  8012c4:	83 c4 10             	add    $0x10,%esp
  8012c7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012ca:	89 d8                	mov    %ebx,%eax
  8012cc:	c1 e8 16             	shr    $0x16,%eax
  8012cf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012d6:	a8 01                	test   $0x1,%al
  8012d8:	74 11                	je     8012eb <dup+0x71>
  8012da:	89 d8                	mov    %ebx,%eax
  8012dc:	c1 e8 0c             	shr    $0xc,%eax
  8012df:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012e6:	f6 c2 01             	test   $0x1,%dl
  8012e9:	75 36                	jne    801321 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012eb:	89 f8                	mov    %edi,%eax
  8012ed:	c1 e8 0c             	shr    $0xc,%eax
  8012f0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012f7:	83 ec 0c             	sub    $0xc,%esp
  8012fa:	25 07 0e 00 00       	and    $0xe07,%eax
  8012ff:	50                   	push   %eax
  801300:	56                   	push   %esi
  801301:	6a 00                	push   $0x0
  801303:	57                   	push   %edi
  801304:	6a 00                	push   $0x0
  801306:	e8 e9 f8 ff ff       	call   800bf4 <sys_page_map>
  80130b:	89 c3                	mov    %eax,%ebx
  80130d:	83 c4 20             	add    $0x20,%esp
  801310:	85 c0                	test   %eax,%eax
  801312:	78 33                	js     801347 <dup+0xcd>
		goto err;

	return newfdnum;
  801314:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801317:	89 d8                	mov    %ebx,%eax
  801319:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80131c:	5b                   	pop    %ebx
  80131d:	5e                   	pop    %esi
  80131e:	5f                   	pop    %edi
  80131f:	5d                   	pop    %ebp
  801320:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801321:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801328:	83 ec 0c             	sub    $0xc,%esp
  80132b:	25 07 0e 00 00       	and    $0xe07,%eax
  801330:	50                   	push   %eax
  801331:	ff 75 d4             	push   -0x2c(%ebp)
  801334:	6a 00                	push   $0x0
  801336:	53                   	push   %ebx
  801337:	6a 00                	push   $0x0
  801339:	e8 b6 f8 ff ff       	call   800bf4 <sys_page_map>
  80133e:	89 c3                	mov    %eax,%ebx
  801340:	83 c4 20             	add    $0x20,%esp
  801343:	85 c0                	test   %eax,%eax
  801345:	79 a4                	jns    8012eb <dup+0x71>
	sys_page_unmap(0, newfd);
  801347:	83 ec 08             	sub    $0x8,%esp
  80134a:	56                   	push   %esi
  80134b:	6a 00                	push   $0x0
  80134d:	e8 e4 f8 ff ff       	call   800c36 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801352:	83 c4 08             	add    $0x8,%esp
  801355:	ff 75 d4             	push   -0x2c(%ebp)
  801358:	6a 00                	push   $0x0
  80135a:	e8 d7 f8 ff ff       	call   800c36 <sys_page_unmap>
	return r;
  80135f:	83 c4 10             	add    $0x10,%esp
  801362:	eb b3                	jmp    801317 <dup+0x9d>

00801364 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
  801367:	56                   	push   %esi
  801368:	53                   	push   %ebx
  801369:	83 ec 18             	sub    $0x18,%esp
  80136c:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80136f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801372:	50                   	push   %eax
  801373:	56                   	push   %esi
  801374:	e8 82 fd ff ff       	call   8010fb <fd_lookup>
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	85 c0                	test   %eax,%eax
  80137e:	78 3c                	js     8013bc <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801380:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801383:	83 ec 08             	sub    $0x8,%esp
  801386:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801389:	50                   	push   %eax
  80138a:	ff 33                	push   (%ebx)
  80138c:	e8 ba fd ff ff       	call   80114b <dev_lookup>
  801391:	83 c4 10             	add    $0x10,%esp
  801394:	85 c0                	test   %eax,%eax
  801396:	78 24                	js     8013bc <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801398:	8b 43 08             	mov    0x8(%ebx),%eax
  80139b:	83 e0 03             	and    $0x3,%eax
  80139e:	83 f8 01             	cmp    $0x1,%eax
  8013a1:	74 20                	je     8013c3 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8013a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a6:	8b 40 08             	mov    0x8(%eax),%eax
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	74 37                	je     8013e4 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013ad:	83 ec 04             	sub    $0x4,%esp
  8013b0:	ff 75 10             	push   0x10(%ebp)
  8013b3:	ff 75 0c             	push   0xc(%ebp)
  8013b6:	53                   	push   %ebx
  8013b7:	ff d0                	call   *%eax
  8013b9:	83 c4 10             	add    $0x10,%esp
}
  8013bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013bf:	5b                   	pop    %ebx
  8013c0:	5e                   	pop    %esi
  8013c1:	5d                   	pop    %ebp
  8013c2:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013c3:	a1 00 40 80 00       	mov    0x804000,%eax
  8013c8:	8b 40 58             	mov    0x58(%eax),%eax
  8013cb:	83 ec 04             	sub    $0x4,%esp
  8013ce:	56                   	push   %esi
  8013cf:	50                   	push   %eax
  8013d0:	68 59 2a 80 00       	push   $0x802a59
  8013d5:	e8 01 ee ff ff       	call   8001db <cprintf>
		return -E_INVAL;
  8013da:	83 c4 10             	add    $0x10,%esp
  8013dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013e2:	eb d8                	jmp    8013bc <read+0x58>
		return -E_NOT_SUPP;
  8013e4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013e9:	eb d1                	jmp    8013bc <read+0x58>

008013eb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	57                   	push   %edi
  8013ef:	56                   	push   %esi
  8013f0:	53                   	push   %ebx
  8013f1:	83 ec 0c             	sub    $0xc,%esp
  8013f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013f7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013ff:	eb 02                	jmp    801403 <readn+0x18>
  801401:	01 c3                	add    %eax,%ebx
  801403:	39 f3                	cmp    %esi,%ebx
  801405:	73 21                	jae    801428 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801407:	83 ec 04             	sub    $0x4,%esp
  80140a:	89 f0                	mov    %esi,%eax
  80140c:	29 d8                	sub    %ebx,%eax
  80140e:	50                   	push   %eax
  80140f:	89 d8                	mov    %ebx,%eax
  801411:	03 45 0c             	add    0xc(%ebp),%eax
  801414:	50                   	push   %eax
  801415:	57                   	push   %edi
  801416:	e8 49 ff ff ff       	call   801364 <read>
		if (m < 0)
  80141b:	83 c4 10             	add    $0x10,%esp
  80141e:	85 c0                	test   %eax,%eax
  801420:	78 04                	js     801426 <readn+0x3b>
			return m;
		if (m == 0)
  801422:	75 dd                	jne    801401 <readn+0x16>
  801424:	eb 02                	jmp    801428 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801426:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801428:	89 d8                	mov    %ebx,%eax
  80142a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80142d:	5b                   	pop    %ebx
  80142e:	5e                   	pop    %esi
  80142f:	5f                   	pop    %edi
  801430:	5d                   	pop    %ebp
  801431:	c3                   	ret    

00801432 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801432:	55                   	push   %ebp
  801433:	89 e5                	mov    %esp,%ebp
  801435:	56                   	push   %esi
  801436:	53                   	push   %ebx
  801437:	83 ec 18             	sub    $0x18,%esp
  80143a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80143d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801440:	50                   	push   %eax
  801441:	53                   	push   %ebx
  801442:	e8 b4 fc ff ff       	call   8010fb <fd_lookup>
  801447:	83 c4 10             	add    $0x10,%esp
  80144a:	85 c0                	test   %eax,%eax
  80144c:	78 37                	js     801485 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80144e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801451:	83 ec 08             	sub    $0x8,%esp
  801454:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801457:	50                   	push   %eax
  801458:	ff 36                	push   (%esi)
  80145a:	e8 ec fc ff ff       	call   80114b <dev_lookup>
  80145f:	83 c4 10             	add    $0x10,%esp
  801462:	85 c0                	test   %eax,%eax
  801464:	78 1f                	js     801485 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801466:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80146a:	74 20                	je     80148c <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80146c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146f:	8b 40 0c             	mov    0xc(%eax),%eax
  801472:	85 c0                	test   %eax,%eax
  801474:	74 37                	je     8014ad <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801476:	83 ec 04             	sub    $0x4,%esp
  801479:	ff 75 10             	push   0x10(%ebp)
  80147c:	ff 75 0c             	push   0xc(%ebp)
  80147f:	56                   	push   %esi
  801480:	ff d0                	call   *%eax
  801482:	83 c4 10             	add    $0x10,%esp
}
  801485:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801488:	5b                   	pop    %ebx
  801489:	5e                   	pop    %esi
  80148a:	5d                   	pop    %ebp
  80148b:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80148c:	a1 00 40 80 00       	mov    0x804000,%eax
  801491:	8b 40 58             	mov    0x58(%eax),%eax
  801494:	83 ec 04             	sub    $0x4,%esp
  801497:	53                   	push   %ebx
  801498:	50                   	push   %eax
  801499:	68 75 2a 80 00       	push   $0x802a75
  80149e:	e8 38 ed ff ff       	call   8001db <cprintf>
		return -E_INVAL;
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ab:	eb d8                	jmp    801485 <write+0x53>
		return -E_NOT_SUPP;
  8014ad:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014b2:	eb d1                	jmp    801485 <write+0x53>

008014b4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014b4:	55                   	push   %ebp
  8014b5:	89 e5                	mov    %esp,%ebp
  8014b7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014bd:	50                   	push   %eax
  8014be:	ff 75 08             	push   0x8(%ebp)
  8014c1:	e8 35 fc ff ff       	call   8010fb <fd_lookup>
  8014c6:	83 c4 10             	add    $0x10,%esp
  8014c9:	85 c0                	test   %eax,%eax
  8014cb:	78 0e                	js     8014db <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014db:	c9                   	leave  
  8014dc:	c3                   	ret    

008014dd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014dd:	55                   	push   %ebp
  8014de:	89 e5                	mov    %esp,%ebp
  8014e0:	56                   	push   %esi
  8014e1:	53                   	push   %ebx
  8014e2:	83 ec 18             	sub    $0x18,%esp
  8014e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014eb:	50                   	push   %eax
  8014ec:	53                   	push   %ebx
  8014ed:	e8 09 fc ff ff       	call   8010fb <fd_lookup>
  8014f2:	83 c4 10             	add    $0x10,%esp
  8014f5:	85 c0                	test   %eax,%eax
  8014f7:	78 34                	js     80152d <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f9:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8014fc:	83 ec 08             	sub    $0x8,%esp
  8014ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801502:	50                   	push   %eax
  801503:	ff 36                	push   (%esi)
  801505:	e8 41 fc ff ff       	call   80114b <dev_lookup>
  80150a:	83 c4 10             	add    $0x10,%esp
  80150d:	85 c0                	test   %eax,%eax
  80150f:	78 1c                	js     80152d <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801511:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801515:	74 1d                	je     801534 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801517:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80151a:	8b 40 18             	mov    0x18(%eax),%eax
  80151d:	85 c0                	test   %eax,%eax
  80151f:	74 34                	je     801555 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801521:	83 ec 08             	sub    $0x8,%esp
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
			thisenv->env_id, fdnum);
  801534:	a1 00 40 80 00       	mov    0x804000,%eax
  801539:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80153c:	83 ec 04             	sub    $0x4,%esp
  80153f:	53                   	push   %ebx
  801540:	50                   	push   %eax
  801541:	68 38 2a 80 00       	push   $0x802a38
  801546:	e8 90 ec ff ff       	call   8001db <cprintf>
		return -E_INVAL;
  80154b:	83 c4 10             	add    $0x10,%esp
  80154e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801553:	eb d8                	jmp    80152d <ftruncate+0x50>
		return -E_NOT_SUPP;
  801555:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80155a:	eb d1                	jmp    80152d <ftruncate+0x50>

0080155c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	56                   	push   %esi
  801560:	53                   	push   %ebx
  801561:	83 ec 18             	sub    $0x18,%esp
  801564:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801567:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156a:	50                   	push   %eax
  80156b:	ff 75 08             	push   0x8(%ebp)
  80156e:	e8 88 fb ff ff       	call   8010fb <fd_lookup>
  801573:	83 c4 10             	add    $0x10,%esp
  801576:	85 c0                	test   %eax,%eax
  801578:	78 49                	js     8015c3 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80157d:	83 ec 08             	sub    $0x8,%esp
  801580:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801583:	50                   	push   %eax
  801584:	ff 36                	push   (%esi)
  801586:	e8 c0 fb ff ff       	call   80114b <dev_lookup>
  80158b:	83 c4 10             	add    $0x10,%esp
  80158e:	85 c0                	test   %eax,%eax
  801590:	78 31                	js     8015c3 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801592:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801595:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801599:	74 2f                	je     8015ca <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80159b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80159e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015a5:	00 00 00 
	stat->st_isdir = 0;
  8015a8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015af:	00 00 00 
	stat->st_dev = dev;
  8015b2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015b8:	83 ec 08             	sub    $0x8,%esp
  8015bb:	53                   	push   %ebx
  8015bc:	56                   	push   %esi
  8015bd:	ff 50 14             	call   *0x14(%eax)
  8015c0:	83 c4 10             	add    $0x10,%esp
}
  8015c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c6:	5b                   	pop    %ebx
  8015c7:	5e                   	pop    %esi
  8015c8:	5d                   	pop    %ebp
  8015c9:	c3                   	ret    
		return -E_NOT_SUPP;
  8015ca:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015cf:	eb f2                	jmp    8015c3 <fstat+0x67>

008015d1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	56                   	push   %esi
  8015d5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015d6:	83 ec 08             	sub    $0x8,%esp
  8015d9:	6a 00                	push   $0x0
  8015db:	ff 75 08             	push   0x8(%ebp)
  8015de:	e8 e4 01 00 00       	call   8017c7 <open>
  8015e3:	89 c3                	mov    %eax,%ebx
  8015e5:	83 c4 10             	add    $0x10,%esp
  8015e8:	85 c0                	test   %eax,%eax
  8015ea:	78 1b                	js     801607 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015ec:	83 ec 08             	sub    $0x8,%esp
  8015ef:	ff 75 0c             	push   0xc(%ebp)
  8015f2:	50                   	push   %eax
  8015f3:	e8 64 ff ff ff       	call   80155c <fstat>
  8015f8:	89 c6                	mov    %eax,%esi
	close(fd);
  8015fa:	89 1c 24             	mov    %ebx,(%esp)
  8015fd:	e8 26 fc ff ff       	call   801228 <close>
	return r;
  801602:	83 c4 10             	add    $0x10,%esp
  801605:	89 f3                	mov    %esi,%ebx
}
  801607:	89 d8                	mov    %ebx,%eax
  801609:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80160c:	5b                   	pop    %ebx
  80160d:	5e                   	pop    %esi
  80160e:	5d                   	pop    %ebp
  80160f:	c3                   	ret    

00801610 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801610:	55                   	push   %ebp
  801611:	89 e5                	mov    %esp,%ebp
  801613:	56                   	push   %esi
  801614:	53                   	push   %ebx
  801615:	89 c6                	mov    %eax,%esi
  801617:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801619:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801620:	74 27                	je     801649 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801622:	6a 07                	push   $0x7
  801624:	68 00 50 80 00       	push   $0x805000
  801629:	56                   	push   %esi
  80162a:	ff 35 00 60 80 00    	push   0x806000
  801630:	e8 af 0c 00 00       	call   8022e4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801635:	83 c4 0c             	add    $0xc,%esp
  801638:	6a 00                	push   $0x0
  80163a:	53                   	push   %ebx
  80163b:	6a 00                	push   $0x0
  80163d:	e8 32 0c 00 00       	call   802274 <ipc_recv>
}
  801642:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801645:	5b                   	pop    %ebx
  801646:	5e                   	pop    %esi
  801647:	5d                   	pop    %ebp
  801648:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801649:	83 ec 0c             	sub    $0xc,%esp
  80164c:	6a 01                	push   $0x1
  80164e:	e8 e5 0c 00 00       	call   802338 <ipc_find_env>
  801653:	a3 00 60 80 00       	mov    %eax,0x806000
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	eb c5                	jmp    801622 <fsipc+0x12>

0080165d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80165d:	55                   	push   %ebp
  80165e:	89 e5                	mov    %esp,%ebp
  801660:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801663:	8b 45 08             	mov    0x8(%ebp),%eax
  801666:	8b 40 0c             	mov    0xc(%eax),%eax
  801669:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80166e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801671:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801676:	ba 00 00 00 00       	mov    $0x0,%edx
  80167b:	b8 02 00 00 00       	mov    $0x2,%eax
  801680:	e8 8b ff ff ff       	call   801610 <fsipc>
}
  801685:	c9                   	leave  
  801686:	c3                   	ret    

00801687 <devfile_flush>:
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80168d:	8b 45 08             	mov    0x8(%ebp),%eax
  801690:	8b 40 0c             	mov    0xc(%eax),%eax
  801693:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801698:	ba 00 00 00 00       	mov    $0x0,%edx
  80169d:	b8 06 00 00 00       	mov    $0x6,%eax
  8016a2:	e8 69 ff ff ff       	call   801610 <fsipc>
}
  8016a7:	c9                   	leave  
  8016a8:	c3                   	ret    

008016a9 <devfile_stat>:
{
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	53                   	push   %ebx
  8016ad:	83 ec 04             	sub    $0x4,%esp
  8016b0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b6:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016be:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c3:	b8 05 00 00 00       	mov    $0x5,%eax
  8016c8:	e8 43 ff ff ff       	call   801610 <fsipc>
  8016cd:	85 c0                	test   %eax,%eax
  8016cf:	78 2c                	js     8016fd <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016d1:	83 ec 08             	sub    $0x8,%esp
  8016d4:	68 00 50 80 00       	push   $0x805000
  8016d9:	53                   	push   %ebx
  8016da:	e8 d6 f0 ff ff       	call   8007b5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016df:	a1 80 50 80 00       	mov    0x805080,%eax
  8016e4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016ea:	a1 84 50 80 00       	mov    0x805084,%eax
  8016ef:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801700:	c9                   	leave  
  801701:	c3                   	ret    

00801702 <devfile_write>:
{
  801702:	55                   	push   %ebp
  801703:	89 e5                	mov    %esp,%ebp
  801705:	83 ec 0c             	sub    $0xc,%esp
  801708:	8b 45 10             	mov    0x10(%ebp),%eax
  80170b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801710:	39 d0                	cmp    %edx,%eax
  801712:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801715:	8b 55 08             	mov    0x8(%ebp),%edx
  801718:	8b 52 0c             	mov    0xc(%edx),%edx
  80171b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801721:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801726:	50                   	push   %eax
  801727:	ff 75 0c             	push   0xc(%ebp)
  80172a:	68 08 50 80 00       	push   $0x805008
  80172f:	e8 17 f2 ff ff       	call   80094b <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801734:	ba 00 00 00 00       	mov    $0x0,%edx
  801739:	b8 04 00 00 00       	mov    $0x4,%eax
  80173e:	e8 cd fe ff ff       	call   801610 <fsipc>
}
  801743:	c9                   	leave  
  801744:	c3                   	ret    

00801745 <devfile_read>:
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	56                   	push   %esi
  801749:	53                   	push   %ebx
  80174a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80174d:	8b 45 08             	mov    0x8(%ebp),%eax
  801750:	8b 40 0c             	mov    0xc(%eax),%eax
  801753:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801758:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80175e:	ba 00 00 00 00       	mov    $0x0,%edx
  801763:	b8 03 00 00 00       	mov    $0x3,%eax
  801768:	e8 a3 fe ff ff       	call   801610 <fsipc>
  80176d:	89 c3                	mov    %eax,%ebx
  80176f:	85 c0                	test   %eax,%eax
  801771:	78 1f                	js     801792 <devfile_read+0x4d>
	assert(r <= n);
  801773:	39 f0                	cmp    %esi,%eax
  801775:	77 24                	ja     80179b <devfile_read+0x56>
	assert(r <= PGSIZE);
  801777:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80177c:	7f 33                	jg     8017b1 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80177e:	83 ec 04             	sub    $0x4,%esp
  801781:	50                   	push   %eax
  801782:	68 00 50 80 00       	push   $0x805000
  801787:	ff 75 0c             	push   0xc(%ebp)
  80178a:	e8 bc f1 ff ff       	call   80094b <memmove>
	return r;
  80178f:	83 c4 10             	add    $0x10,%esp
}
  801792:	89 d8                	mov    %ebx,%eax
  801794:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801797:	5b                   	pop    %ebx
  801798:	5e                   	pop    %esi
  801799:	5d                   	pop    %ebp
  80179a:	c3                   	ret    
	assert(r <= n);
  80179b:	68 a8 2a 80 00       	push   $0x802aa8
  8017a0:	68 af 2a 80 00       	push   $0x802aaf
  8017a5:	6a 7c                	push   $0x7c
  8017a7:	68 c4 2a 80 00       	push   $0x802ac4
  8017ac:	e8 e1 09 00 00       	call   802192 <_panic>
	assert(r <= PGSIZE);
  8017b1:	68 cf 2a 80 00       	push   $0x802acf
  8017b6:	68 af 2a 80 00       	push   $0x802aaf
  8017bb:	6a 7d                	push   $0x7d
  8017bd:	68 c4 2a 80 00       	push   $0x802ac4
  8017c2:	e8 cb 09 00 00       	call   802192 <_panic>

008017c7 <open>:
{
  8017c7:	55                   	push   %ebp
  8017c8:	89 e5                	mov    %esp,%ebp
  8017ca:	56                   	push   %esi
  8017cb:	53                   	push   %ebx
  8017cc:	83 ec 1c             	sub    $0x1c,%esp
  8017cf:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8017d2:	56                   	push   %esi
  8017d3:	e8 a2 ef ff ff       	call   80077a <strlen>
  8017d8:	83 c4 10             	add    $0x10,%esp
  8017db:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017e0:	7f 6c                	jg     80184e <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8017e2:	83 ec 0c             	sub    $0xc,%esp
  8017e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e8:	50                   	push   %eax
  8017e9:	e8 bd f8 ff ff       	call   8010ab <fd_alloc>
  8017ee:	89 c3                	mov    %eax,%ebx
  8017f0:	83 c4 10             	add    $0x10,%esp
  8017f3:	85 c0                	test   %eax,%eax
  8017f5:	78 3c                	js     801833 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8017f7:	83 ec 08             	sub    $0x8,%esp
  8017fa:	56                   	push   %esi
  8017fb:	68 00 50 80 00       	push   $0x805000
  801800:	e8 b0 ef ff ff       	call   8007b5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801805:	8b 45 0c             	mov    0xc(%ebp),%eax
  801808:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80180d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801810:	b8 01 00 00 00       	mov    $0x1,%eax
  801815:	e8 f6 fd ff ff       	call   801610 <fsipc>
  80181a:	89 c3                	mov    %eax,%ebx
  80181c:	83 c4 10             	add    $0x10,%esp
  80181f:	85 c0                	test   %eax,%eax
  801821:	78 19                	js     80183c <open+0x75>
	return fd2num(fd);
  801823:	83 ec 0c             	sub    $0xc,%esp
  801826:	ff 75 f4             	push   -0xc(%ebp)
  801829:	e8 56 f8 ff ff       	call   801084 <fd2num>
  80182e:	89 c3                	mov    %eax,%ebx
  801830:	83 c4 10             	add    $0x10,%esp
}
  801833:	89 d8                	mov    %ebx,%eax
  801835:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801838:	5b                   	pop    %ebx
  801839:	5e                   	pop    %esi
  80183a:	5d                   	pop    %ebp
  80183b:	c3                   	ret    
		fd_close(fd, 0);
  80183c:	83 ec 08             	sub    $0x8,%esp
  80183f:	6a 00                	push   $0x0
  801841:	ff 75 f4             	push   -0xc(%ebp)
  801844:	e8 58 f9 ff ff       	call   8011a1 <fd_close>
		return r;
  801849:	83 c4 10             	add    $0x10,%esp
  80184c:	eb e5                	jmp    801833 <open+0x6c>
		return -E_BAD_PATH;
  80184e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801853:	eb de                	jmp    801833 <open+0x6c>

00801855 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80185b:	ba 00 00 00 00       	mov    $0x0,%edx
  801860:	b8 08 00 00 00       	mov    $0x8,%eax
  801865:	e8 a6 fd ff ff       	call   801610 <fsipc>
}
  80186a:	c9                   	leave  
  80186b:	c3                   	ret    

0080186c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801872:	68 db 2a 80 00       	push   $0x802adb
  801877:	ff 75 0c             	push   0xc(%ebp)
  80187a:	e8 36 ef ff ff       	call   8007b5 <strcpy>
	return 0;
}
  80187f:	b8 00 00 00 00       	mov    $0x0,%eax
  801884:	c9                   	leave  
  801885:	c3                   	ret    

00801886 <devsock_close>:
{
  801886:	55                   	push   %ebp
  801887:	89 e5                	mov    %esp,%ebp
  801889:	53                   	push   %ebx
  80188a:	83 ec 10             	sub    $0x10,%esp
  80188d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801890:	53                   	push   %ebx
  801891:	e8 e1 0a 00 00       	call   802377 <pageref>
  801896:	89 c2                	mov    %eax,%edx
  801898:	83 c4 10             	add    $0x10,%esp
		return 0;
  80189b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  8018a0:	83 fa 01             	cmp    $0x1,%edx
  8018a3:	74 05                	je     8018aa <devsock_close+0x24>
}
  8018a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a8:	c9                   	leave  
  8018a9:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8018aa:	83 ec 0c             	sub    $0xc,%esp
  8018ad:	ff 73 0c             	push   0xc(%ebx)
  8018b0:	e8 b7 02 00 00       	call   801b6c <nsipc_close>
  8018b5:	83 c4 10             	add    $0x10,%esp
  8018b8:	eb eb                	jmp    8018a5 <devsock_close+0x1f>

008018ba <devsock_write>:
{
  8018ba:	55                   	push   %ebp
  8018bb:	89 e5                	mov    %esp,%ebp
  8018bd:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8018c0:	6a 00                	push   $0x0
  8018c2:	ff 75 10             	push   0x10(%ebp)
  8018c5:	ff 75 0c             	push   0xc(%ebp)
  8018c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cb:	ff 70 0c             	push   0xc(%eax)
  8018ce:	e8 79 03 00 00       	call   801c4c <nsipc_send>
}
  8018d3:	c9                   	leave  
  8018d4:	c3                   	ret    

008018d5 <devsock_read>:
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018db:	6a 00                	push   $0x0
  8018dd:	ff 75 10             	push   0x10(%ebp)
  8018e0:	ff 75 0c             	push   0xc(%ebp)
  8018e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e6:	ff 70 0c             	push   0xc(%eax)
  8018e9:	e8 ef 02 00 00       	call   801bdd <nsipc_recv>
}
  8018ee:	c9                   	leave  
  8018ef:	c3                   	ret    

008018f0 <fd2sockid>:
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8018f6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018f9:	52                   	push   %edx
  8018fa:	50                   	push   %eax
  8018fb:	e8 fb f7 ff ff       	call   8010fb <fd_lookup>
  801900:	83 c4 10             	add    $0x10,%esp
  801903:	85 c0                	test   %eax,%eax
  801905:	78 10                	js     801917 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801907:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190a:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801910:	39 08                	cmp    %ecx,(%eax)
  801912:	75 05                	jne    801919 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  801914:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801917:	c9                   	leave  
  801918:	c3                   	ret    
		return -E_NOT_SUPP;
  801919:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80191e:	eb f7                	jmp    801917 <fd2sockid+0x27>

00801920 <alloc_sockfd>:
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	56                   	push   %esi
  801924:	53                   	push   %ebx
  801925:	83 ec 1c             	sub    $0x1c,%esp
  801928:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  80192a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192d:	50                   	push   %eax
  80192e:	e8 78 f7 ff ff       	call   8010ab <fd_alloc>
  801933:	89 c3                	mov    %eax,%ebx
  801935:	83 c4 10             	add    $0x10,%esp
  801938:	85 c0                	test   %eax,%eax
  80193a:	78 43                	js     80197f <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80193c:	83 ec 04             	sub    $0x4,%esp
  80193f:	68 07 04 00 00       	push   $0x407
  801944:	ff 75 f4             	push   -0xc(%ebp)
  801947:	6a 00                	push   $0x0
  801949:	e8 63 f2 ff ff       	call   800bb1 <sys_page_alloc>
  80194e:	89 c3                	mov    %eax,%ebx
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	85 c0                	test   %eax,%eax
  801955:	78 28                	js     80197f <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801957:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801960:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801962:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801965:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80196c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80196f:	83 ec 0c             	sub    $0xc,%esp
  801972:	50                   	push   %eax
  801973:	e8 0c f7 ff ff       	call   801084 <fd2num>
  801978:	89 c3                	mov    %eax,%ebx
  80197a:	83 c4 10             	add    $0x10,%esp
  80197d:	eb 0c                	jmp    80198b <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  80197f:	83 ec 0c             	sub    $0xc,%esp
  801982:	56                   	push   %esi
  801983:	e8 e4 01 00 00       	call   801b6c <nsipc_close>
		return r;
  801988:	83 c4 10             	add    $0x10,%esp
}
  80198b:	89 d8                	mov    %ebx,%eax
  80198d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801990:	5b                   	pop    %ebx
  801991:	5e                   	pop    %esi
  801992:	5d                   	pop    %ebp
  801993:	c3                   	ret    

00801994 <accept>:
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80199a:	8b 45 08             	mov    0x8(%ebp),%eax
  80199d:	e8 4e ff ff ff       	call   8018f0 <fd2sockid>
  8019a2:	85 c0                	test   %eax,%eax
  8019a4:	78 1b                	js     8019c1 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019a6:	83 ec 04             	sub    $0x4,%esp
  8019a9:	ff 75 10             	push   0x10(%ebp)
  8019ac:	ff 75 0c             	push   0xc(%ebp)
  8019af:	50                   	push   %eax
  8019b0:	e8 0e 01 00 00       	call   801ac3 <nsipc_accept>
  8019b5:	83 c4 10             	add    $0x10,%esp
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	78 05                	js     8019c1 <accept+0x2d>
	return alloc_sockfd(r);
  8019bc:	e8 5f ff ff ff       	call   801920 <alloc_sockfd>
}
  8019c1:	c9                   	leave  
  8019c2:	c3                   	ret    

008019c3 <bind>:
{
  8019c3:	55                   	push   %ebp
  8019c4:	89 e5                	mov    %esp,%ebp
  8019c6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cc:	e8 1f ff ff ff       	call   8018f0 <fd2sockid>
  8019d1:	85 c0                	test   %eax,%eax
  8019d3:	78 12                	js     8019e7 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8019d5:	83 ec 04             	sub    $0x4,%esp
  8019d8:	ff 75 10             	push   0x10(%ebp)
  8019db:	ff 75 0c             	push   0xc(%ebp)
  8019de:	50                   	push   %eax
  8019df:	e8 31 01 00 00       	call   801b15 <nsipc_bind>
  8019e4:	83 c4 10             	add    $0x10,%esp
}
  8019e7:	c9                   	leave  
  8019e8:	c3                   	ret    

008019e9 <shutdown>:
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8019f2:	e8 f9 fe ff ff       	call   8018f0 <fd2sockid>
  8019f7:	85 c0                	test   %eax,%eax
  8019f9:	78 0f                	js     801a0a <shutdown+0x21>
	return nsipc_shutdown(r, how);
  8019fb:	83 ec 08             	sub    $0x8,%esp
  8019fe:	ff 75 0c             	push   0xc(%ebp)
  801a01:	50                   	push   %eax
  801a02:	e8 43 01 00 00       	call   801b4a <nsipc_shutdown>
  801a07:	83 c4 10             	add    $0x10,%esp
}
  801a0a:	c9                   	leave  
  801a0b:	c3                   	ret    

00801a0c <connect>:
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a12:	8b 45 08             	mov    0x8(%ebp),%eax
  801a15:	e8 d6 fe ff ff       	call   8018f0 <fd2sockid>
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 12                	js     801a30 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801a1e:	83 ec 04             	sub    $0x4,%esp
  801a21:	ff 75 10             	push   0x10(%ebp)
  801a24:	ff 75 0c             	push   0xc(%ebp)
  801a27:	50                   	push   %eax
  801a28:	e8 59 01 00 00       	call   801b86 <nsipc_connect>
  801a2d:	83 c4 10             	add    $0x10,%esp
}
  801a30:	c9                   	leave  
  801a31:	c3                   	ret    

00801a32 <listen>:
{
  801a32:	55                   	push   %ebp
  801a33:	89 e5                	mov    %esp,%ebp
  801a35:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a38:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3b:	e8 b0 fe ff ff       	call   8018f0 <fd2sockid>
  801a40:	85 c0                	test   %eax,%eax
  801a42:	78 0f                	js     801a53 <listen+0x21>
	return nsipc_listen(r, backlog);
  801a44:	83 ec 08             	sub    $0x8,%esp
  801a47:	ff 75 0c             	push   0xc(%ebp)
  801a4a:	50                   	push   %eax
  801a4b:	e8 6b 01 00 00       	call   801bbb <nsipc_listen>
  801a50:	83 c4 10             	add    $0x10,%esp
}
  801a53:	c9                   	leave  
  801a54:	c3                   	ret    

00801a55 <socket>:

int
socket(int domain, int type, int protocol)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a5b:	ff 75 10             	push   0x10(%ebp)
  801a5e:	ff 75 0c             	push   0xc(%ebp)
  801a61:	ff 75 08             	push   0x8(%ebp)
  801a64:	e8 41 02 00 00       	call   801caa <nsipc_socket>
  801a69:	83 c4 10             	add    $0x10,%esp
  801a6c:	85 c0                	test   %eax,%eax
  801a6e:	78 05                	js     801a75 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a70:	e8 ab fe ff ff       	call   801920 <alloc_sockfd>
}
  801a75:	c9                   	leave  
  801a76:	c3                   	ret    

00801a77 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a77:	55                   	push   %ebp
  801a78:	89 e5                	mov    %esp,%ebp
  801a7a:	53                   	push   %ebx
  801a7b:	83 ec 04             	sub    $0x4,%esp
  801a7e:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a80:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801a87:	74 26                	je     801aaf <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a89:	6a 07                	push   $0x7
  801a8b:	68 00 70 80 00       	push   $0x807000
  801a90:	53                   	push   %ebx
  801a91:	ff 35 00 80 80 00    	push   0x808000
  801a97:	e8 48 08 00 00       	call   8022e4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a9c:	83 c4 0c             	add    $0xc,%esp
  801a9f:	6a 00                	push   $0x0
  801aa1:	6a 00                	push   $0x0
  801aa3:	6a 00                	push   $0x0
  801aa5:	e8 ca 07 00 00       	call   802274 <ipc_recv>
}
  801aaa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aad:	c9                   	leave  
  801aae:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801aaf:	83 ec 0c             	sub    $0xc,%esp
  801ab2:	6a 02                	push   $0x2
  801ab4:	e8 7f 08 00 00       	call   802338 <ipc_find_env>
  801ab9:	a3 00 80 80 00       	mov    %eax,0x808000
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	eb c6                	jmp    801a89 <nsipc+0x12>

00801ac3 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	56                   	push   %esi
  801ac7:	53                   	push   %ebx
  801ac8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801acb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ace:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801ad3:	8b 06                	mov    (%esi),%eax
  801ad5:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ada:	b8 01 00 00 00       	mov    $0x1,%eax
  801adf:	e8 93 ff ff ff       	call   801a77 <nsipc>
  801ae4:	89 c3                	mov    %eax,%ebx
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	79 09                	jns    801af3 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801aea:	89 d8                	mov    %ebx,%eax
  801aec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aef:	5b                   	pop    %ebx
  801af0:	5e                   	pop    %esi
  801af1:	5d                   	pop    %ebp
  801af2:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801af3:	83 ec 04             	sub    $0x4,%esp
  801af6:	ff 35 10 70 80 00    	push   0x807010
  801afc:	68 00 70 80 00       	push   $0x807000
  801b01:	ff 75 0c             	push   0xc(%ebp)
  801b04:	e8 42 ee ff ff       	call   80094b <memmove>
		*addrlen = ret->ret_addrlen;
  801b09:	a1 10 70 80 00       	mov    0x807010,%eax
  801b0e:	89 06                	mov    %eax,(%esi)
  801b10:	83 c4 10             	add    $0x10,%esp
	return r;
  801b13:	eb d5                	jmp    801aea <nsipc_accept+0x27>

00801b15 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	53                   	push   %ebx
  801b19:	83 ec 08             	sub    $0x8,%esp
  801b1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b1f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b22:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b27:	53                   	push   %ebx
  801b28:	ff 75 0c             	push   0xc(%ebp)
  801b2b:	68 04 70 80 00       	push   $0x807004
  801b30:	e8 16 ee ff ff       	call   80094b <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b35:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801b3b:	b8 02 00 00 00       	mov    $0x2,%eax
  801b40:	e8 32 ff ff ff       	call   801a77 <nsipc>
}
  801b45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b48:	c9                   	leave  
  801b49:	c3                   	ret    

00801b4a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b4a:	55                   	push   %ebp
  801b4b:	89 e5                	mov    %esp,%ebp
  801b4d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b50:	8b 45 08             	mov    0x8(%ebp),%eax
  801b53:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801b58:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b5b:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801b60:	b8 03 00 00 00       	mov    $0x3,%eax
  801b65:	e8 0d ff ff ff       	call   801a77 <nsipc>
}
  801b6a:	c9                   	leave  
  801b6b:	c3                   	ret    

00801b6c <nsipc_close>:

int
nsipc_close(int s)
{
  801b6c:	55                   	push   %ebp
  801b6d:	89 e5                	mov    %esp,%ebp
  801b6f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b72:	8b 45 08             	mov    0x8(%ebp),%eax
  801b75:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801b7a:	b8 04 00 00 00       	mov    $0x4,%eax
  801b7f:	e8 f3 fe ff ff       	call   801a77 <nsipc>
}
  801b84:	c9                   	leave  
  801b85:	c3                   	ret    

00801b86 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	53                   	push   %ebx
  801b8a:	83 ec 08             	sub    $0x8,%esp
  801b8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b90:	8b 45 08             	mov    0x8(%ebp),%eax
  801b93:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b98:	53                   	push   %ebx
  801b99:	ff 75 0c             	push   0xc(%ebp)
  801b9c:	68 04 70 80 00       	push   $0x807004
  801ba1:	e8 a5 ed ff ff       	call   80094b <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ba6:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801bac:	b8 05 00 00 00       	mov    $0x5,%eax
  801bb1:	e8 c1 fe ff ff       	call   801a77 <nsipc>
}
  801bb6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb9:	c9                   	leave  
  801bba:	c3                   	ret    

00801bbb <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801bc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bcc:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801bd1:	b8 06 00 00 00       	mov    $0x6,%eax
  801bd6:	e8 9c fe ff ff       	call   801a77 <nsipc>
}
  801bdb:	c9                   	leave  
  801bdc:	c3                   	ret    

00801bdd <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	56                   	push   %esi
  801be1:	53                   	push   %ebx
  801be2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801be5:	8b 45 08             	mov    0x8(%ebp),%eax
  801be8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801bed:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801bf3:	8b 45 14             	mov    0x14(%ebp),%eax
  801bf6:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801bfb:	b8 07 00 00 00       	mov    $0x7,%eax
  801c00:	e8 72 fe ff ff       	call   801a77 <nsipc>
  801c05:	89 c3                	mov    %eax,%ebx
  801c07:	85 c0                	test   %eax,%eax
  801c09:	78 22                	js     801c2d <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801c0b:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801c10:	39 c6                	cmp    %eax,%esi
  801c12:	0f 4e c6             	cmovle %esi,%eax
  801c15:	39 c3                	cmp    %eax,%ebx
  801c17:	7f 1d                	jg     801c36 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c19:	83 ec 04             	sub    $0x4,%esp
  801c1c:	53                   	push   %ebx
  801c1d:	68 00 70 80 00       	push   $0x807000
  801c22:	ff 75 0c             	push   0xc(%ebp)
  801c25:	e8 21 ed ff ff       	call   80094b <memmove>
  801c2a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c2d:	89 d8                	mov    %ebx,%eax
  801c2f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c32:	5b                   	pop    %ebx
  801c33:	5e                   	pop    %esi
  801c34:	5d                   	pop    %ebp
  801c35:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801c36:	68 e7 2a 80 00       	push   $0x802ae7
  801c3b:	68 af 2a 80 00       	push   $0x802aaf
  801c40:	6a 62                	push   $0x62
  801c42:	68 fc 2a 80 00       	push   $0x802afc
  801c47:	e8 46 05 00 00       	call   802192 <_panic>

00801c4c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	53                   	push   %ebx
  801c50:	83 ec 04             	sub    $0x4,%esp
  801c53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c56:	8b 45 08             	mov    0x8(%ebp),%eax
  801c59:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801c5e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c64:	7f 2e                	jg     801c94 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c66:	83 ec 04             	sub    $0x4,%esp
  801c69:	53                   	push   %ebx
  801c6a:	ff 75 0c             	push   0xc(%ebp)
  801c6d:	68 0c 70 80 00       	push   $0x80700c
  801c72:	e8 d4 ec ff ff       	call   80094b <memmove>
	nsipcbuf.send.req_size = size;
  801c77:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801c7d:	8b 45 14             	mov    0x14(%ebp),%eax
  801c80:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801c85:	b8 08 00 00 00       	mov    $0x8,%eax
  801c8a:	e8 e8 fd ff ff       	call   801a77 <nsipc>
}
  801c8f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c92:	c9                   	leave  
  801c93:	c3                   	ret    
	assert(size < 1600);
  801c94:	68 08 2b 80 00       	push   $0x802b08
  801c99:	68 af 2a 80 00       	push   $0x802aaf
  801c9e:	6a 6d                	push   $0x6d
  801ca0:	68 fc 2a 80 00       	push   $0x802afc
  801ca5:	e8 e8 04 00 00       	call   802192 <_panic>

00801caa <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801cb0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb3:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801cb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cbb:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801cc0:	8b 45 10             	mov    0x10(%ebp),%eax
  801cc3:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801cc8:	b8 09 00 00 00       	mov    $0x9,%eax
  801ccd:	e8 a5 fd ff ff       	call   801a77 <nsipc>
}
  801cd2:	c9                   	leave  
  801cd3:	c3                   	ret    

00801cd4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	56                   	push   %esi
  801cd8:	53                   	push   %ebx
  801cd9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cdc:	83 ec 0c             	sub    $0xc,%esp
  801cdf:	ff 75 08             	push   0x8(%ebp)
  801ce2:	e8 ad f3 ff ff       	call   801094 <fd2data>
  801ce7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ce9:	83 c4 08             	add    $0x8,%esp
  801cec:	68 14 2b 80 00       	push   $0x802b14
  801cf1:	53                   	push   %ebx
  801cf2:	e8 be ea ff ff       	call   8007b5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cf7:	8b 46 04             	mov    0x4(%esi),%eax
  801cfa:	2b 06                	sub    (%esi),%eax
  801cfc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d02:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d09:	00 00 00 
	stat->st_dev = &devpipe;
  801d0c:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801d13:	30 80 00 
	return 0;
}
  801d16:	b8 00 00 00 00       	mov    $0x0,%eax
  801d1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d1e:	5b                   	pop    %ebx
  801d1f:	5e                   	pop    %esi
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    

00801d22 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	53                   	push   %ebx
  801d26:	83 ec 0c             	sub    $0xc,%esp
  801d29:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d2c:	53                   	push   %ebx
  801d2d:	6a 00                	push   $0x0
  801d2f:	e8 02 ef ff ff       	call   800c36 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d34:	89 1c 24             	mov    %ebx,(%esp)
  801d37:	e8 58 f3 ff ff       	call   801094 <fd2data>
  801d3c:	83 c4 08             	add    $0x8,%esp
  801d3f:	50                   	push   %eax
  801d40:	6a 00                	push   $0x0
  801d42:	e8 ef ee ff ff       	call   800c36 <sys_page_unmap>
}
  801d47:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d4a:	c9                   	leave  
  801d4b:	c3                   	ret    

00801d4c <_pipeisclosed>:
{
  801d4c:	55                   	push   %ebp
  801d4d:	89 e5                	mov    %esp,%ebp
  801d4f:	57                   	push   %edi
  801d50:	56                   	push   %esi
  801d51:	53                   	push   %ebx
  801d52:	83 ec 1c             	sub    $0x1c,%esp
  801d55:	89 c7                	mov    %eax,%edi
  801d57:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801d59:	a1 00 40 80 00       	mov    0x804000,%eax
  801d5e:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d61:	83 ec 0c             	sub    $0xc,%esp
  801d64:	57                   	push   %edi
  801d65:	e8 0d 06 00 00       	call   802377 <pageref>
  801d6a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d6d:	89 34 24             	mov    %esi,(%esp)
  801d70:	e8 02 06 00 00       	call   802377 <pageref>
		nn = thisenv->env_runs;
  801d75:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801d7b:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801d7e:	83 c4 10             	add    $0x10,%esp
  801d81:	39 cb                	cmp    %ecx,%ebx
  801d83:	74 1b                	je     801da0 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801d85:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d88:	75 cf                	jne    801d59 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d8a:	8b 42 68             	mov    0x68(%edx),%eax
  801d8d:	6a 01                	push   $0x1
  801d8f:	50                   	push   %eax
  801d90:	53                   	push   %ebx
  801d91:	68 1b 2b 80 00       	push   $0x802b1b
  801d96:	e8 40 e4 ff ff       	call   8001db <cprintf>
  801d9b:	83 c4 10             	add    $0x10,%esp
  801d9e:	eb b9                	jmp    801d59 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801da0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801da3:	0f 94 c0             	sete   %al
  801da6:	0f b6 c0             	movzbl %al,%eax
}
  801da9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dac:	5b                   	pop    %ebx
  801dad:	5e                   	pop    %esi
  801dae:	5f                   	pop    %edi
  801daf:	5d                   	pop    %ebp
  801db0:	c3                   	ret    

00801db1 <devpipe_write>:
{
  801db1:	55                   	push   %ebp
  801db2:	89 e5                	mov    %esp,%ebp
  801db4:	57                   	push   %edi
  801db5:	56                   	push   %esi
  801db6:	53                   	push   %ebx
  801db7:	83 ec 28             	sub    $0x28,%esp
  801dba:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801dbd:	56                   	push   %esi
  801dbe:	e8 d1 f2 ff ff       	call   801094 <fd2data>
  801dc3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801dc5:	83 c4 10             	add    $0x10,%esp
  801dc8:	bf 00 00 00 00       	mov    $0x0,%edi
  801dcd:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801dd0:	75 09                	jne    801ddb <devpipe_write+0x2a>
	return i;
  801dd2:	89 f8                	mov    %edi,%eax
  801dd4:	eb 23                	jmp    801df9 <devpipe_write+0x48>
			sys_yield();
  801dd6:	e8 b7 ed ff ff       	call   800b92 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ddb:	8b 43 04             	mov    0x4(%ebx),%eax
  801dde:	8b 0b                	mov    (%ebx),%ecx
  801de0:	8d 51 20             	lea    0x20(%ecx),%edx
  801de3:	39 d0                	cmp    %edx,%eax
  801de5:	72 1a                	jb     801e01 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801de7:	89 da                	mov    %ebx,%edx
  801de9:	89 f0                	mov    %esi,%eax
  801deb:	e8 5c ff ff ff       	call   801d4c <_pipeisclosed>
  801df0:	85 c0                	test   %eax,%eax
  801df2:	74 e2                	je     801dd6 <devpipe_write+0x25>
				return 0;
  801df4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801df9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dfc:	5b                   	pop    %ebx
  801dfd:	5e                   	pop    %esi
  801dfe:	5f                   	pop    %edi
  801dff:	5d                   	pop    %ebp
  801e00:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e01:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e04:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e08:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e0b:	89 c2                	mov    %eax,%edx
  801e0d:	c1 fa 1f             	sar    $0x1f,%edx
  801e10:	89 d1                	mov    %edx,%ecx
  801e12:	c1 e9 1b             	shr    $0x1b,%ecx
  801e15:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e18:	83 e2 1f             	and    $0x1f,%edx
  801e1b:	29 ca                	sub    %ecx,%edx
  801e1d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e21:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e25:	83 c0 01             	add    $0x1,%eax
  801e28:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801e2b:	83 c7 01             	add    $0x1,%edi
  801e2e:	eb 9d                	jmp    801dcd <devpipe_write+0x1c>

00801e30 <devpipe_read>:
{
  801e30:	55                   	push   %ebp
  801e31:	89 e5                	mov    %esp,%ebp
  801e33:	57                   	push   %edi
  801e34:	56                   	push   %esi
  801e35:	53                   	push   %ebx
  801e36:	83 ec 18             	sub    $0x18,%esp
  801e39:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801e3c:	57                   	push   %edi
  801e3d:	e8 52 f2 ff ff       	call   801094 <fd2data>
  801e42:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e44:	83 c4 10             	add    $0x10,%esp
  801e47:	be 00 00 00 00       	mov    $0x0,%esi
  801e4c:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e4f:	75 13                	jne    801e64 <devpipe_read+0x34>
	return i;
  801e51:	89 f0                	mov    %esi,%eax
  801e53:	eb 02                	jmp    801e57 <devpipe_read+0x27>
				return i;
  801e55:	89 f0                	mov    %esi,%eax
}
  801e57:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e5a:	5b                   	pop    %ebx
  801e5b:	5e                   	pop    %esi
  801e5c:	5f                   	pop    %edi
  801e5d:	5d                   	pop    %ebp
  801e5e:	c3                   	ret    
			sys_yield();
  801e5f:	e8 2e ed ff ff       	call   800b92 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801e64:	8b 03                	mov    (%ebx),%eax
  801e66:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e69:	75 18                	jne    801e83 <devpipe_read+0x53>
			if (i > 0)
  801e6b:	85 f6                	test   %esi,%esi
  801e6d:	75 e6                	jne    801e55 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801e6f:	89 da                	mov    %ebx,%edx
  801e71:	89 f8                	mov    %edi,%eax
  801e73:	e8 d4 fe ff ff       	call   801d4c <_pipeisclosed>
  801e78:	85 c0                	test   %eax,%eax
  801e7a:	74 e3                	je     801e5f <devpipe_read+0x2f>
				return 0;
  801e7c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e81:	eb d4                	jmp    801e57 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e83:	99                   	cltd   
  801e84:	c1 ea 1b             	shr    $0x1b,%edx
  801e87:	01 d0                	add    %edx,%eax
  801e89:	83 e0 1f             	and    $0x1f,%eax
  801e8c:	29 d0                	sub    %edx,%eax
  801e8e:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e96:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e99:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e9c:	83 c6 01             	add    $0x1,%esi
  801e9f:	eb ab                	jmp    801e4c <devpipe_read+0x1c>

00801ea1 <pipe>:
{
  801ea1:	55                   	push   %ebp
  801ea2:	89 e5                	mov    %esp,%ebp
  801ea4:	56                   	push   %esi
  801ea5:	53                   	push   %ebx
  801ea6:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ea9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eac:	50                   	push   %eax
  801ead:	e8 f9 f1 ff ff       	call   8010ab <fd_alloc>
  801eb2:	89 c3                	mov    %eax,%ebx
  801eb4:	83 c4 10             	add    $0x10,%esp
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	0f 88 23 01 00 00    	js     801fe2 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ebf:	83 ec 04             	sub    $0x4,%esp
  801ec2:	68 07 04 00 00       	push   $0x407
  801ec7:	ff 75 f4             	push   -0xc(%ebp)
  801eca:	6a 00                	push   $0x0
  801ecc:	e8 e0 ec ff ff       	call   800bb1 <sys_page_alloc>
  801ed1:	89 c3                	mov    %eax,%ebx
  801ed3:	83 c4 10             	add    $0x10,%esp
  801ed6:	85 c0                	test   %eax,%eax
  801ed8:	0f 88 04 01 00 00    	js     801fe2 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801ede:	83 ec 0c             	sub    $0xc,%esp
  801ee1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ee4:	50                   	push   %eax
  801ee5:	e8 c1 f1 ff ff       	call   8010ab <fd_alloc>
  801eea:	89 c3                	mov    %eax,%ebx
  801eec:	83 c4 10             	add    $0x10,%esp
  801eef:	85 c0                	test   %eax,%eax
  801ef1:	0f 88 db 00 00 00    	js     801fd2 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ef7:	83 ec 04             	sub    $0x4,%esp
  801efa:	68 07 04 00 00       	push   $0x407
  801eff:	ff 75 f0             	push   -0x10(%ebp)
  801f02:	6a 00                	push   $0x0
  801f04:	e8 a8 ec ff ff       	call   800bb1 <sys_page_alloc>
  801f09:	89 c3                	mov    %eax,%ebx
  801f0b:	83 c4 10             	add    $0x10,%esp
  801f0e:	85 c0                	test   %eax,%eax
  801f10:	0f 88 bc 00 00 00    	js     801fd2 <pipe+0x131>
	va = fd2data(fd0);
  801f16:	83 ec 0c             	sub    $0xc,%esp
  801f19:	ff 75 f4             	push   -0xc(%ebp)
  801f1c:	e8 73 f1 ff ff       	call   801094 <fd2data>
  801f21:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f23:	83 c4 0c             	add    $0xc,%esp
  801f26:	68 07 04 00 00       	push   $0x407
  801f2b:	50                   	push   %eax
  801f2c:	6a 00                	push   $0x0
  801f2e:	e8 7e ec ff ff       	call   800bb1 <sys_page_alloc>
  801f33:	89 c3                	mov    %eax,%ebx
  801f35:	83 c4 10             	add    $0x10,%esp
  801f38:	85 c0                	test   %eax,%eax
  801f3a:	0f 88 82 00 00 00    	js     801fc2 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f40:	83 ec 0c             	sub    $0xc,%esp
  801f43:	ff 75 f0             	push   -0x10(%ebp)
  801f46:	e8 49 f1 ff ff       	call   801094 <fd2data>
  801f4b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f52:	50                   	push   %eax
  801f53:	6a 00                	push   $0x0
  801f55:	56                   	push   %esi
  801f56:	6a 00                	push   $0x0
  801f58:	e8 97 ec ff ff       	call   800bf4 <sys_page_map>
  801f5d:	89 c3                	mov    %eax,%ebx
  801f5f:	83 c4 20             	add    $0x20,%esp
  801f62:	85 c0                	test   %eax,%eax
  801f64:	78 4e                	js     801fb4 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801f66:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801f6b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f6e:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801f70:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f73:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801f7a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f7d:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801f7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f82:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f89:	83 ec 0c             	sub    $0xc,%esp
  801f8c:	ff 75 f4             	push   -0xc(%ebp)
  801f8f:	e8 f0 f0 ff ff       	call   801084 <fd2num>
  801f94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f97:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f99:	83 c4 04             	add    $0x4,%esp
  801f9c:	ff 75 f0             	push   -0x10(%ebp)
  801f9f:	e8 e0 f0 ff ff       	call   801084 <fd2num>
  801fa4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fa7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801faa:	83 c4 10             	add    $0x10,%esp
  801fad:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fb2:	eb 2e                	jmp    801fe2 <pipe+0x141>
	sys_page_unmap(0, va);
  801fb4:	83 ec 08             	sub    $0x8,%esp
  801fb7:	56                   	push   %esi
  801fb8:	6a 00                	push   $0x0
  801fba:	e8 77 ec ff ff       	call   800c36 <sys_page_unmap>
  801fbf:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801fc2:	83 ec 08             	sub    $0x8,%esp
  801fc5:	ff 75 f0             	push   -0x10(%ebp)
  801fc8:	6a 00                	push   $0x0
  801fca:	e8 67 ec ff ff       	call   800c36 <sys_page_unmap>
  801fcf:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801fd2:	83 ec 08             	sub    $0x8,%esp
  801fd5:	ff 75 f4             	push   -0xc(%ebp)
  801fd8:	6a 00                	push   $0x0
  801fda:	e8 57 ec ff ff       	call   800c36 <sys_page_unmap>
  801fdf:	83 c4 10             	add    $0x10,%esp
}
  801fe2:	89 d8                	mov    %ebx,%eax
  801fe4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fe7:	5b                   	pop    %ebx
  801fe8:	5e                   	pop    %esi
  801fe9:	5d                   	pop    %ebp
  801fea:	c3                   	ret    

00801feb <pipeisclosed>:
{
  801feb:	55                   	push   %ebp
  801fec:	89 e5                	mov    %esp,%ebp
  801fee:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ff1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff4:	50                   	push   %eax
  801ff5:	ff 75 08             	push   0x8(%ebp)
  801ff8:	e8 fe f0 ff ff       	call   8010fb <fd_lookup>
  801ffd:	83 c4 10             	add    $0x10,%esp
  802000:	85 c0                	test   %eax,%eax
  802002:	78 18                	js     80201c <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  802004:	83 ec 0c             	sub    $0xc,%esp
  802007:	ff 75 f4             	push   -0xc(%ebp)
  80200a:	e8 85 f0 ff ff       	call   801094 <fd2data>
  80200f:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802011:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802014:	e8 33 fd ff ff       	call   801d4c <_pipeisclosed>
  802019:	83 c4 10             	add    $0x10,%esp
}
  80201c:	c9                   	leave  
  80201d:	c3                   	ret    

0080201e <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80201e:	b8 00 00 00 00       	mov    $0x0,%eax
  802023:	c3                   	ret    

00802024 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802024:	55                   	push   %ebp
  802025:	89 e5                	mov    %esp,%ebp
  802027:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80202a:	68 33 2b 80 00       	push   $0x802b33
  80202f:	ff 75 0c             	push   0xc(%ebp)
  802032:	e8 7e e7 ff ff       	call   8007b5 <strcpy>
	return 0;
}
  802037:	b8 00 00 00 00       	mov    $0x0,%eax
  80203c:	c9                   	leave  
  80203d:	c3                   	ret    

0080203e <devcons_write>:
{
  80203e:	55                   	push   %ebp
  80203f:	89 e5                	mov    %esp,%ebp
  802041:	57                   	push   %edi
  802042:	56                   	push   %esi
  802043:	53                   	push   %ebx
  802044:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80204a:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80204f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802055:	eb 2e                	jmp    802085 <devcons_write+0x47>
		m = n - tot;
  802057:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80205a:	29 f3                	sub    %esi,%ebx
  80205c:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802061:	39 c3                	cmp    %eax,%ebx
  802063:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802066:	83 ec 04             	sub    $0x4,%esp
  802069:	53                   	push   %ebx
  80206a:	89 f0                	mov    %esi,%eax
  80206c:	03 45 0c             	add    0xc(%ebp),%eax
  80206f:	50                   	push   %eax
  802070:	57                   	push   %edi
  802071:	e8 d5 e8 ff ff       	call   80094b <memmove>
		sys_cputs(buf, m);
  802076:	83 c4 08             	add    $0x8,%esp
  802079:	53                   	push   %ebx
  80207a:	57                   	push   %edi
  80207b:	e8 75 ea ff ff       	call   800af5 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802080:	01 de                	add    %ebx,%esi
  802082:	83 c4 10             	add    $0x10,%esp
  802085:	3b 75 10             	cmp    0x10(%ebp),%esi
  802088:	72 cd                	jb     802057 <devcons_write+0x19>
}
  80208a:	89 f0                	mov    %esi,%eax
  80208c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80208f:	5b                   	pop    %ebx
  802090:	5e                   	pop    %esi
  802091:	5f                   	pop    %edi
  802092:	5d                   	pop    %ebp
  802093:	c3                   	ret    

00802094 <devcons_read>:
{
  802094:	55                   	push   %ebp
  802095:	89 e5                	mov    %esp,%ebp
  802097:	83 ec 08             	sub    $0x8,%esp
  80209a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80209f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020a3:	75 07                	jne    8020ac <devcons_read+0x18>
  8020a5:	eb 1f                	jmp    8020c6 <devcons_read+0x32>
		sys_yield();
  8020a7:	e8 e6 ea ff ff       	call   800b92 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8020ac:	e8 62 ea ff ff       	call   800b13 <sys_cgetc>
  8020b1:	85 c0                	test   %eax,%eax
  8020b3:	74 f2                	je     8020a7 <devcons_read+0x13>
	if (c < 0)
  8020b5:	78 0f                	js     8020c6 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8020b7:	83 f8 04             	cmp    $0x4,%eax
  8020ba:	74 0c                	je     8020c8 <devcons_read+0x34>
	*(char*)vbuf = c;
  8020bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020bf:	88 02                	mov    %al,(%edx)
	return 1;
  8020c1:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8020c6:	c9                   	leave  
  8020c7:	c3                   	ret    
		return 0;
  8020c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8020cd:	eb f7                	jmp    8020c6 <devcons_read+0x32>

008020cf <cputchar>:
{
  8020cf:	55                   	push   %ebp
  8020d0:	89 e5                	mov    %esp,%ebp
  8020d2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d8:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8020db:	6a 01                	push   $0x1
  8020dd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020e0:	50                   	push   %eax
  8020e1:	e8 0f ea ff ff       	call   800af5 <sys_cputs>
}
  8020e6:	83 c4 10             	add    $0x10,%esp
  8020e9:	c9                   	leave  
  8020ea:	c3                   	ret    

008020eb <getchar>:
{
  8020eb:	55                   	push   %ebp
  8020ec:	89 e5                	mov    %esp,%ebp
  8020ee:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8020f1:	6a 01                	push   $0x1
  8020f3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020f6:	50                   	push   %eax
  8020f7:	6a 00                	push   $0x0
  8020f9:	e8 66 f2 ff ff       	call   801364 <read>
	if (r < 0)
  8020fe:	83 c4 10             	add    $0x10,%esp
  802101:	85 c0                	test   %eax,%eax
  802103:	78 06                	js     80210b <getchar+0x20>
	if (r < 1)
  802105:	74 06                	je     80210d <getchar+0x22>
	return c;
  802107:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80210b:	c9                   	leave  
  80210c:	c3                   	ret    
		return -E_EOF;
  80210d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802112:	eb f7                	jmp    80210b <getchar+0x20>

00802114 <iscons>:
{
  802114:	55                   	push   %ebp
  802115:	89 e5                	mov    %esp,%ebp
  802117:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80211a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80211d:	50                   	push   %eax
  80211e:	ff 75 08             	push   0x8(%ebp)
  802121:	e8 d5 ef ff ff       	call   8010fb <fd_lookup>
  802126:	83 c4 10             	add    $0x10,%esp
  802129:	85 c0                	test   %eax,%eax
  80212b:	78 11                	js     80213e <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80212d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802130:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802136:	39 10                	cmp    %edx,(%eax)
  802138:	0f 94 c0             	sete   %al
  80213b:	0f b6 c0             	movzbl %al,%eax
}
  80213e:	c9                   	leave  
  80213f:	c3                   	ret    

00802140 <opencons>:
{
  802140:	55                   	push   %ebp
  802141:	89 e5                	mov    %esp,%ebp
  802143:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802146:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802149:	50                   	push   %eax
  80214a:	e8 5c ef ff ff       	call   8010ab <fd_alloc>
  80214f:	83 c4 10             	add    $0x10,%esp
  802152:	85 c0                	test   %eax,%eax
  802154:	78 3a                	js     802190 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802156:	83 ec 04             	sub    $0x4,%esp
  802159:	68 07 04 00 00       	push   $0x407
  80215e:	ff 75 f4             	push   -0xc(%ebp)
  802161:	6a 00                	push   $0x0
  802163:	e8 49 ea ff ff       	call   800bb1 <sys_page_alloc>
  802168:	83 c4 10             	add    $0x10,%esp
  80216b:	85 c0                	test   %eax,%eax
  80216d:	78 21                	js     802190 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80216f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802172:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802178:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80217a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80217d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802184:	83 ec 0c             	sub    $0xc,%esp
  802187:	50                   	push   %eax
  802188:	e8 f7 ee ff ff       	call   801084 <fd2num>
  80218d:	83 c4 10             	add    $0x10,%esp
}
  802190:	c9                   	leave  
  802191:	c3                   	ret    

00802192 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802192:	55                   	push   %ebp
  802193:	89 e5                	mov    %esp,%ebp
  802195:	56                   	push   %esi
  802196:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802197:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80219a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8021a0:	e8 ce e9 ff ff       	call   800b73 <sys_getenvid>
  8021a5:	83 ec 0c             	sub    $0xc,%esp
  8021a8:	ff 75 0c             	push   0xc(%ebp)
  8021ab:	ff 75 08             	push   0x8(%ebp)
  8021ae:	56                   	push   %esi
  8021af:	50                   	push   %eax
  8021b0:	68 40 2b 80 00       	push   $0x802b40
  8021b5:	e8 21 e0 ff ff       	call   8001db <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021ba:	83 c4 18             	add    $0x18,%esp
  8021bd:	53                   	push   %ebx
  8021be:	ff 75 10             	push   0x10(%ebp)
  8021c1:	e8 c4 df ff ff       	call   80018a <vcprintf>
	cprintf("\n");
  8021c6:	c7 04 24 0f 26 80 00 	movl   $0x80260f,(%esp)
  8021cd:	e8 09 e0 ff ff       	call   8001db <cprintf>
  8021d2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8021d5:	cc                   	int3   
  8021d6:	eb fd                	jmp    8021d5 <_panic+0x43>

008021d8 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021d8:	55                   	push   %ebp
  8021d9:	89 e5                	mov    %esp,%ebp
  8021db:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  8021de:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  8021e5:	74 0a                	je     8021f1 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8021ea:	a3 04 80 80 00       	mov    %eax,0x808004
}
  8021ef:	c9                   	leave  
  8021f0:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  8021f1:	e8 7d e9 ff ff       	call   800b73 <sys_getenvid>
  8021f6:	83 ec 04             	sub    $0x4,%esp
  8021f9:	68 07 0e 00 00       	push   $0xe07
  8021fe:	68 00 f0 bf ee       	push   $0xeebff000
  802203:	50                   	push   %eax
  802204:	e8 a8 e9 ff ff       	call   800bb1 <sys_page_alloc>
		if (r < 0) {
  802209:	83 c4 10             	add    $0x10,%esp
  80220c:	85 c0                	test   %eax,%eax
  80220e:	78 2c                	js     80223c <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802210:	e8 5e e9 ff ff       	call   800b73 <sys_getenvid>
  802215:	83 ec 08             	sub    $0x8,%esp
  802218:	68 4e 22 80 00       	push   $0x80224e
  80221d:	50                   	push   %eax
  80221e:	e8 d9 ea ff ff       	call   800cfc <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802223:	83 c4 10             	add    $0x10,%esp
  802226:	85 c0                	test   %eax,%eax
  802228:	79 bd                	jns    8021e7 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  80222a:	50                   	push   %eax
  80222b:	68 a4 2b 80 00       	push   $0x802ba4
  802230:	6a 28                	push   $0x28
  802232:	68 da 2b 80 00       	push   $0x802bda
  802237:	e8 56 ff ff ff       	call   802192 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  80223c:	50                   	push   %eax
  80223d:	68 64 2b 80 00       	push   $0x802b64
  802242:	6a 23                	push   $0x23
  802244:	68 da 2b 80 00       	push   $0x802bda
  802249:	e8 44 ff ff ff       	call   802192 <_panic>

0080224e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80224e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80224f:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  802254:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802256:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802259:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  80225d:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  802260:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  802264:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802268:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  80226a:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  80226d:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  80226e:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  802271:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  802272:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  802273:	c3                   	ret    

00802274 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802274:	55                   	push   %ebp
  802275:	89 e5                	mov    %esp,%ebp
  802277:	56                   	push   %esi
  802278:	53                   	push   %ebx
  802279:	8b 75 08             	mov    0x8(%ebp),%esi
  80227c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80227f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  802282:	85 c0                	test   %eax,%eax
  802284:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802289:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  80228c:	83 ec 0c             	sub    $0xc,%esp
  80228f:	50                   	push   %eax
  802290:	e8 cc ea ff ff       	call   800d61 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802295:	83 c4 10             	add    $0x10,%esp
  802298:	85 f6                	test   %esi,%esi
  80229a:	74 17                	je     8022b3 <ipc_recv+0x3f>
  80229c:	ba 00 00 00 00       	mov    $0x0,%edx
  8022a1:	85 c0                	test   %eax,%eax
  8022a3:	78 0c                	js     8022b1 <ipc_recv+0x3d>
  8022a5:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8022ab:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  8022b1:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8022b3:	85 db                	test   %ebx,%ebx
  8022b5:	74 17                	je     8022ce <ipc_recv+0x5a>
  8022b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8022bc:	85 c0                	test   %eax,%eax
  8022be:	78 0c                	js     8022cc <ipc_recv+0x58>
  8022c0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8022c6:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  8022cc:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8022ce:	85 c0                	test   %eax,%eax
  8022d0:	78 0b                	js     8022dd <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  8022d2:	a1 00 40 80 00       	mov    0x804000,%eax
  8022d7:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  8022dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022e0:	5b                   	pop    %ebx
  8022e1:	5e                   	pop    %esi
  8022e2:	5d                   	pop    %ebp
  8022e3:	c3                   	ret    

008022e4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022e4:	55                   	push   %ebp
  8022e5:	89 e5                	mov    %esp,%ebp
  8022e7:	57                   	push   %edi
  8022e8:	56                   	push   %esi
  8022e9:	53                   	push   %ebx
  8022ea:	83 ec 0c             	sub    $0xc,%esp
  8022ed:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022f0:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8022f6:	85 db                	test   %ebx,%ebx
  8022f8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8022fd:	0f 44 d8             	cmove  %eax,%ebx
  802300:	eb 05                	jmp    802307 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802302:	e8 8b e8 ff ff       	call   800b92 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  802307:	ff 75 14             	push   0x14(%ebp)
  80230a:	53                   	push   %ebx
  80230b:	56                   	push   %esi
  80230c:	57                   	push   %edi
  80230d:	e8 2c ea ff ff       	call   800d3e <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802312:	83 c4 10             	add    $0x10,%esp
  802315:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802318:	74 e8                	je     802302 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80231a:	85 c0                	test   %eax,%eax
  80231c:	78 08                	js     802326 <ipc_send+0x42>
	}while (r<0);

}
  80231e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802321:	5b                   	pop    %ebx
  802322:	5e                   	pop    %esi
  802323:	5f                   	pop    %edi
  802324:	5d                   	pop    %ebp
  802325:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802326:	50                   	push   %eax
  802327:	68 e8 2b 80 00       	push   $0x802be8
  80232c:	6a 3d                	push   $0x3d
  80232e:	68 fc 2b 80 00       	push   $0x802bfc
  802333:	e8 5a fe ff ff       	call   802192 <_panic>

00802338 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802338:	55                   	push   %ebp
  802339:	89 e5                	mov    %esp,%ebp
  80233b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80233e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802343:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  802349:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80234f:	8b 52 60             	mov    0x60(%edx),%edx
  802352:	39 ca                	cmp    %ecx,%edx
  802354:	74 11                	je     802367 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  802356:	83 c0 01             	add    $0x1,%eax
  802359:	3d 00 04 00 00       	cmp    $0x400,%eax
  80235e:	75 e3                	jne    802343 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802360:	b8 00 00 00 00       	mov    $0x0,%eax
  802365:	eb 0e                	jmp    802375 <ipc_find_env+0x3d>
			return envs[i].env_id;
  802367:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80236d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802372:	8b 40 58             	mov    0x58(%eax),%eax
}
  802375:	5d                   	pop    %ebp
  802376:	c3                   	ret    

00802377 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802377:	55                   	push   %ebp
  802378:	89 e5                	mov    %esp,%ebp
  80237a:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80237d:	89 c2                	mov    %eax,%edx
  80237f:	c1 ea 16             	shr    $0x16,%edx
  802382:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802389:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80238e:	f6 c1 01             	test   $0x1,%cl
  802391:	74 1c                	je     8023af <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802393:	c1 e8 0c             	shr    $0xc,%eax
  802396:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80239d:	a8 01                	test   $0x1,%al
  80239f:	74 0e                	je     8023af <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023a1:	c1 e8 0c             	shr    $0xc,%eax
  8023a4:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8023ab:	ef 
  8023ac:	0f b7 d2             	movzwl %dx,%edx
}
  8023af:	89 d0                	mov    %edx,%eax
  8023b1:	5d                   	pop    %ebp
  8023b2:	c3                   	ret    
  8023b3:	66 90                	xchg   %ax,%ax
  8023b5:	66 90                	xchg   %ax,%ax
  8023b7:	66 90                	xchg   %ax,%ax
  8023b9:	66 90                	xchg   %ax,%ax
  8023bb:	66 90                	xchg   %ax,%ax
  8023bd:	66 90                	xchg   %ax,%ax
  8023bf:	90                   	nop

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
