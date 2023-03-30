
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
  80003d:	e8 2e 0b 00 00       	call   800b70 <sys_getenvid>
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	53                   	push   %ebx
  800046:	50                   	push   %eax
  800047:	68 e0 25 80 00       	push   $0x8025e0
  80004c:	e8 87 01 00 00       	call   8001d8 <cprintf>

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
  80007e:	e8 f4 06 00 00       	call   800777 <strlen>
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
  80009c:	68 f1 25 80 00       	push   $0x8025f1
  8000a1:	6a 04                	push   $0x4
  8000a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a6:	50                   	push   %eax
  8000a7:	e8 b1 06 00 00       	call   80075d <snprintf>
	if (fork() == 0) {
  8000ac:	83 c4 20             	add    $0x20,%esp
  8000af:	e8 4a 0e 00 00       	call   800efe <fork>
  8000b4:	85 c0                	test   %eax,%eax
  8000b6:	75 d3                	jne    80008b <forkchild+0x1c>
		forktree(nxt);
  8000b8:	83 ec 0c             	sub    $0xc,%esp
  8000bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000be:	50                   	push   %eax
  8000bf:	e8 6f ff ff ff       	call   800033 <forktree>
		exit();
  8000c4:	e8 60 00 00 00       	call   800129 <exit>
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
  8000d4:	68 f0 25 80 00       	push   $0x8025f0
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
  8000ee:	e8 7d 0a 00 00       	call   800b70 <sys_getenvid>
  8000f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800100:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800105:	85 db                	test   %ebx,%ebx
  800107:	7e 07                	jle    800110 <libmain+0x2d>
		binaryname = argv[0];
  800109:	8b 06                	mov    (%esi),%eax
  80010b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800110:	83 ec 08             	sub    $0x8,%esp
  800113:	56                   	push   %esi
  800114:	53                   	push   %ebx
  800115:	e8 b4 ff ff ff       	call   8000ce <umain>

	// exit gracefully
	exit();
  80011a:	e8 0a 00 00 00       	call   800129 <exit>
}
  80011f:	83 c4 10             	add    $0x10,%esp
  800122:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5d                   	pop    %ebp
  800128:	c3                   	ret    

00800129 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800129:	55                   	push   %ebp
  80012a:	89 e5                	mov    %esp,%ebp
  80012c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012f:	e8 1b 11 00 00       	call   80124f <close_all>
	sys_env_destroy(0);
  800134:	83 ec 0c             	sub    $0xc,%esp
  800137:	6a 00                	push   $0x0
  800139:	e8 f1 09 00 00       	call   800b2f <sys_env_destroy>
}
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	53                   	push   %ebx
  800147:	83 ec 04             	sub    $0x4,%esp
  80014a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80014d:	8b 13                	mov    (%ebx),%edx
  80014f:	8d 42 01             	lea    0x1(%edx),%eax
  800152:	89 03                	mov    %eax,(%ebx)
  800154:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800157:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80015b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800160:	74 09                	je     80016b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800162:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800166:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800169:	c9                   	leave  
  80016a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80016b:	83 ec 08             	sub    $0x8,%esp
  80016e:	68 ff 00 00 00       	push   $0xff
  800173:	8d 43 08             	lea    0x8(%ebx),%eax
  800176:	50                   	push   %eax
  800177:	e8 76 09 00 00       	call   800af2 <sys_cputs>
		b->idx = 0;
  80017c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800182:	83 c4 10             	add    $0x10,%esp
  800185:	eb db                	jmp    800162 <putch+0x1f>

00800187 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800190:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800197:	00 00 00 
	b.cnt = 0;
  80019a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001a4:	ff 75 0c             	push   0xc(%ebp)
  8001a7:	ff 75 08             	push   0x8(%ebp)
  8001aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001b0:	50                   	push   %eax
  8001b1:	68 43 01 80 00       	push   $0x800143
  8001b6:	e8 14 01 00 00       	call   8002cf <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001bb:	83 c4 08             	add    $0x8,%esp
  8001be:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8001c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001ca:	50                   	push   %eax
  8001cb:	e8 22 09 00 00       	call   800af2 <sys_cputs>

	return b.cnt;
}
  8001d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001d6:	c9                   	leave  
  8001d7:	c3                   	ret    

008001d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001d8:	55                   	push   %ebp
  8001d9:	89 e5                	mov    %esp,%ebp
  8001db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001e1:	50                   	push   %eax
  8001e2:	ff 75 08             	push   0x8(%ebp)
  8001e5:	e8 9d ff ff ff       	call   800187 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ea:	c9                   	leave  
  8001eb:	c3                   	ret    

008001ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001ec:	55                   	push   %ebp
  8001ed:	89 e5                	mov    %esp,%ebp
  8001ef:	57                   	push   %edi
  8001f0:	56                   	push   %esi
  8001f1:	53                   	push   %ebx
  8001f2:	83 ec 1c             	sub    $0x1c,%esp
  8001f5:	89 c7                	mov    %eax,%edi
  8001f7:	89 d6                	mov    %edx,%esi
  8001f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ff:	89 d1                	mov    %edx,%ecx
  800201:	89 c2                	mov    %eax,%edx
  800203:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800206:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800209:	8b 45 10             	mov    0x10(%ebp),%eax
  80020c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80020f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800212:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800219:	39 c2                	cmp    %eax,%edx
  80021b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80021e:	72 3e                	jb     80025e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800220:	83 ec 0c             	sub    $0xc,%esp
  800223:	ff 75 18             	push   0x18(%ebp)
  800226:	83 eb 01             	sub    $0x1,%ebx
  800229:	53                   	push   %ebx
  80022a:	50                   	push   %eax
  80022b:	83 ec 08             	sub    $0x8,%esp
  80022e:	ff 75 e4             	push   -0x1c(%ebp)
  800231:	ff 75 e0             	push   -0x20(%ebp)
  800234:	ff 75 dc             	push   -0x24(%ebp)
  800237:	ff 75 d8             	push   -0x28(%ebp)
  80023a:	e8 61 21 00 00       	call   8023a0 <__udivdi3>
  80023f:	83 c4 18             	add    $0x18,%esp
  800242:	52                   	push   %edx
  800243:	50                   	push   %eax
  800244:	89 f2                	mov    %esi,%edx
  800246:	89 f8                	mov    %edi,%eax
  800248:	e8 9f ff ff ff       	call   8001ec <printnum>
  80024d:	83 c4 20             	add    $0x20,%esp
  800250:	eb 13                	jmp    800265 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800252:	83 ec 08             	sub    $0x8,%esp
  800255:	56                   	push   %esi
  800256:	ff 75 18             	push   0x18(%ebp)
  800259:	ff d7                	call   *%edi
  80025b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80025e:	83 eb 01             	sub    $0x1,%ebx
  800261:	85 db                	test   %ebx,%ebx
  800263:	7f ed                	jg     800252 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800265:	83 ec 08             	sub    $0x8,%esp
  800268:	56                   	push   %esi
  800269:	83 ec 04             	sub    $0x4,%esp
  80026c:	ff 75 e4             	push   -0x1c(%ebp)
  80026f:	ff 75 e0             	push   -0x20(%ebp)
  800272:	ff 75 dc             	push   -0x24(%ebp)
  800275:	ff 75 d8             	push   -0x28(%ebp)
  800278:	e8 43 22 00 00       	call   8024c0 <__umoddi3>
  80027d:	83 c4 14             	add    $0x14,%esp
  800280:	0f be 80 00 26 80 00 	movsbl 0x802600(%eax),%eax
  800287:	50                   	push   %eax
  800288:	ff d7                	call   *%edi
}
  80028a:	83 c4 10             	add    $0x10,%esp
  80028d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800290:	5b                   	pop    %ebx
  800291:	5e                   	pop    %esi
  800292:	5f                   	pop    %edi
  800293:	5d                   	pop    %ebp
  800294:	c3                   	ret    

00800295 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80029b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80029f:	8b 10                	mov    (%eax),%edx
  8002a1:	3b 50 04             	cmp    0x4(%eax),%edx
  8002a4:	73 0a                	jae    8002b0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8002a6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002a9:	89 08                	mov    %ecx,(%eax)
  8002ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ae:	88 02                	mov    %al,(%edx)
}
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <printfmt>:
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002b8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002bb:	50                   	push   %eax
  8002bc:	ff 75 10             	push   0x10(%ebp)
  8002bf:	ff 75 0c             	push   0xc(%ebp)
  8002c2:	ff 75 08             	push   0x8(%ebp)
  8002c5:	e8 05 00 00 00       	call   8002cf <vprintfmt>
}
  8002ca:	83 c4 10             	add    $0x10,%esp
  8002cd:	c9                   	leave  
  8002ce:	c3                   	ret    

008002cf <vprintfmt>:
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	57                   	push   %edi
  8002d3:	56                   	push   %esi
  8002d4:	53                   	push   %ebx
  8002d5:	83 ec 3c             	sub    $0x3c,%esp
  8002d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8002db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002de:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002e1:	eb 0a                	jmp    8002ed <vprintfmt+0x1e>
			putch(ch, putdat);
  8002e3:	83 ec 08             	sub    $0x8,%esp
  8002e6:	53                   	push   %ebx
  8002e7:	50                   	push   %eax
  8002e8:	ff d6                	call   *%esi
  8002ea:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002ed:	83 c7 01             	add    $0x1,%edi
  8002f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002f4:	83 f8 25             	cmp    $0x25,%eax
  8002f7:	74 0c                	je     800305 <vprintfmt+0x36>
			if (ch == '\0')
  8002f9:	85 c0                	test   %eax,%eax
  8002fb:	75 e6                	jne    8002e3 <vprintfmt+0x14>
}
  8002fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800300:	5b                   	pop    %ebx
  800301:	5e                   	pop    %esi
  800302:	5f                   	pop    %edi
  800303:	5d                   	pop    %ebp
  800304:	c3                   	ret    
		padc = ' ';
  800305:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800309:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800310:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800317:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80031e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800323:	8d 47 01             	lea    0x1(%edi),%eax
  800326:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800329:	0f b6 17             	movzbl (%edi),%edx
  80032c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80032f:	3c 55                	cmp    $0x55,%al
  800331:	0f 87 bb 03 00 00    	ja     8006f2 <vprintfmt+0x423>
  800337:	0f b6 c0             	movzbl %al,%eax
  80033a:	ff 24 85 40 27 80 00 	jmp    *0x802740(,%eax,4)
  800341:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800344:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800348:	eb d9                	jmp    800323 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80034d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800351:	eb d0                	jmp    800323 <vprintfmt+0x54>
  800353:	0f b6 d2             	movzbl %dl,%edx
  800356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800359:	b8 00 00 00 00       	mov    $0x0,%eax
  80035e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800361:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800364:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800368:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80036b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80036e:	83 f9 09             	cmp    $0x9,%ecx
  800371:	77 55                	ja     8003c8 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800373:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800376:	eb e9                	jmp    800361 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800378:	8b 45 14             	mov    0x14(%ebp),%eax
  80037b:	8b 00                	mov    (%eax),%eax
  80037d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800380:	8b 45 14             	mov    0x14(%ebp),%eax
  800383:	8d 40 04             	lea    0x4(%eax),%eax
  800386:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80038c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800390:	79 91                	jns    800323 <vprintfmt+0x54>
				width = precision, precision = -1;
  800392:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800395:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800398:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80039f:	eb 82                	jmp    800323 <vprintfmt+0x54>
  8003a1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003a4:	85 d2                	test   %edx,%edx
  8003a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ab:	0f 49 c2             	cmovns %edx,%eax
  8003ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b4:	e9 6a ff ff ff       	jmp    800323 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003bc:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003c3:	e9 5b ff ff ff       	jmp    800323 <vprintfmt+0x54>
  8003c8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003ce:	eb bc                	jmp    80038c <vprintfmt+0xbd>
			lflag++;
  8003d0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003d6:	e9 48 ff ff ff       	jmp    800323 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8003db:	8b 45 14             	mov    0x14(%ebp),%eax
  8003de:	8d 78 04             	lea    0x4(%eax),%edi
  8003e1:	83 ec 08             	sub    $0x8,%esp
  8003e4:	53                   	push   %ebx
  8003e5:	ff 30                	push   (%eax)
  8003e7:	ff d6                	call   *%esi
			break;
  8003e9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8003ec:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8003ef:	e9 9d 02 00 00       	jmp    800691 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8003f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f7:	8d 78 04             	lea    0x4(%eax),%edi
  8003fa:	8b 10                	mov    (%eax),%edx
  8003fc:	89 d0                	mov    %edx,%eax
  8003fe:	f7 d8                	neg    %eax
  800400:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800403:	83 f8 0f             	cmp    $0xf,%eax
  800406:	7f 23                	jg     80042b <vprintfmt+0x15c>
  800408:	8b 14 85 a0 28 80 00 	mov    0x8028a0(,%eax,4),%edx
  80040f:	85 d2                	test   %edx,%edx
  800411:	74 18                	je     80042b <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800413:	52                   	push   %edx
  800414:	68 a1 2a 80 00       	push   $0x802aa1
  800419:	53                   	push   %ebx
  80041a:	56                   	push   %esi
  80041b:	e8 92 fe ff ff       	call   8002b2 <printfmt>
  800420:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800423:	89 7d 14             	mov    %edi,0x14(%ebp)
  800426:	e9 66 02 00 00       	jmp    800691 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80042b:	50                   	push   %eax
  80042c:	68 18 26 80 00       	push   $0x802618
  800431:	53                   	push   %ebx
  800432:	56                   	push   %esi
  800433:	e8 7a fe ff ff       	call   8002b2 <printfmt>
  800438:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80043b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80043e:	e9 4e 02 00 00       	jmp    800691 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	83 c0 04             	add    $0x4,%eax
  800449:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80044c:	8b 45 14             	mov    0x14(%ebp),%eax
  80044f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800451:	85 d2                	test   %edx,%edx
  800453:	b8 11 26 80 00       	mov    $0x802611,%eax
  800458:	0f 45 c2             	cmovne %edx,%eax
  80045b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80045e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800462:	7e 06                	jle    80046a <vprintfmt+0x19b>
  800464:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800468:	75 0d                	jne    800477 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80046a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80046d:	89 c7                	mov    %eax,%edi
  80046f:	03 45 e0             	add    -0x20(%ebp),%eax
  800472:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800475:	eb 55                	jmp    8004cc <vprintfmt+0x1fd>
  800477:	83 ec 08             	sub    $0x8,%esp
  80047a:	ff 75 d8             	push   -0x28(%ebp)
  80047d:	ff 75 cc             	push   -0x34(%ebp)
  800480:	e8 0a 03 00 00       	call   80078f <strnlen>
  800485:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800488:	29 c1                	sub    %eax,%ecx
  80048a:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80048d:	83 c4 10             	add    $0x10,%esp
  800490:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800492:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800496:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800499:	eb 0f                	jmp    8004aa <vprintfmt+0x1db>
					putch(padc, putdat);
  80049b:	83 ec 08             	sub    $0x8,%esp
  80049e:	53                   	push   %ebx
  80049f:	ff 75 e0             	push   -0x20(%ebp)
  8004a2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a4:	83 ef 01             	sub    $0x1,%edi
  8004a7:	83 c4 10             	add    $0x10,%esp
  8004aa:	85 ff                	test   %edi,%edi
  8004ac:	7f ed                	jg     80049b <vprintfmt+0x1cc>
  8004ae:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004b1:	85 d2                	test   %edx,%edx
  8004b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b8:	0f 49 c2             	cmovns %edx,%eax
  8004bb:	29 c2                	sub    %eax,%edx
  8004bd:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004c0:	eb a8                	jmp    80046a <vprintfmt+0x19b>
					putch(ch, putdat);
  8004c2:	83 ec 08             	sub    $0x8,%esp
  8004c5:	53                   	push   %ebx
  8004c6:	52                   	push   %edx
  8004c7:	ff d6                	call   *%esi
  8004c9:	83 c4 10             	add    $0x10,%esp
  8004cc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004cf:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d1:	83 c7 01             	add    $0x1,%edi
  8004d4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d8:	0f be d0             	movsbl %al,%edx
  8004db:	85 d2                	test   %edx,%edx
  8004dd:	74 4b                	je     80052a <vprintfmt+0x25b>
  8004df:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e3:	78 06                	js     8004eb <vprintfmt+0x21c>
  8004e5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004e9:	78 1e                	js     800509 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8004eb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004ef:	74 d1                	je     8004c2 <vprintfmt+0x1f3>
  8004f1:	0f be c0             	movsbl %al,%eax
  8004f4:	83 e8 20             	sub    $0x20,%eax
  8004f7:	83 f8 5e             	cmp    $0x5e,%eax
  8004fa:	76 c6                	jbe    8004c2 <vprintfmt+0x1f3>
					putch('?', putdat);
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	53                   	push   %ebx
  800500:	6a 3f                	push   $0x3f
  800502:	ff d6                	call   *%esi
  800504:	83 c4 10             	add    $0x10,%esp
  800507:	eb c3                	jmp    8004cc <vprintfmt+0x1fd>
  800509:	89 cf                	mov    %ecx,%edi
  80050b:	eb 0e                	jmp    80051b <vprintfmt+0x24c>
				putch(' ', putdat);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	53                   	push   %ebx
  800511:	6a 20                	push   $0x20
  800513:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800515:	83 ef 01             	sub    $0x1,%edi
  800518:	83 c4 10             	add    $0x10,%esp
  80051b:	85 ff                	test   %edi,%edi
  80051d:	7f ee                	jg     80050d <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80051f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800522:	89 45 14             	mov    %eax,0x14(%ebp)
  800525:	e9 67 01 00 00       	jmp    800691 <vprintfmt+0x3c2>
  80052a:	89 cf                	mov    %ecx,%edi
  80052c:	eb ed                	jmp    80051b <vprintfmt+0x24c>
	if (lflag >= 2)
  80052e:	83 f9 01             	cmp    $0x1,%ecx
  800531:	7f 1b                	jg     80054e <vprintfmt+0x27f>
	else if (lflag)
  800533:	85 c9                	test   %ecx,%ecx
  800535:	74 63                	je     80059a <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800537:	8b 45 14             	mov    0x14(%ebp),%eax
  80053a:	8b 00                	mov    (%eax),%eax
  80053c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80053f:	99                   	cltd   
  800540:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8d 40 04             	lea    0x4(%eax),%eax
  800549:	89 45 14             	mov    %eax,0x14(%ebp)
  80054c:	eb 17                	jmp    800565 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8b 50 04             	mov    0x4(%eax),%edx
  800554:	8b 00                	mov    (%eax),%eax
  800556:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800559:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80055c:	8b 45 14             	mov    0x14(%ebp),%eax
  80055f:	8d 40 08             	lea    0x8(%eax),%eax
  800562:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800565:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800568:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80056b:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800570:	85 c9                	test   %ecx,%ecx
  800572:	0f 89 ff 00 00 00    	jns    800677 <vprintfmt+0x3a8>
				putch('-', putdat);
  800578:	83 ec 08             	sub    $0x8,%esp
  80057b:	53                   	push   %ebx
  80057c:	6a 2d                	push   $0x2d
  80057e:	ff d6                	call   *%esi
				num = -(long long) num;
  800580:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800583:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800586:	f7 da                	neg    %edx
  800588:	83 d1 00             	adc    $0x0,%ecx
  80058b:	f7 d9                	neg    %ecx
  80058d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800590:	bf 0a 00 00 00       	mov    $0xa,%edi
  800595:	e9 dd 00 00 00       	jmp    800677 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80059a:	8b 45 14             	mov    0x14(%ebp),%eax
  80059d:	8b 00                	mov    (%eax),%eax
  80059f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a2:	99                   	cltd   
  8005a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a9:	8d 40 04             	lea    0x4(%eax),%eax
  8005ac:	89 45 14             	mov    %eax,0x14(%ebp)
  8005af:	eb b4                	jmp    800565 <vprintfmt+0x296>
	if (lflag >= 2)
  8005b1:	83 f9 01             	cmp    $0x1,%ecx
  8005b4:	7f 1e                	jg     8005d4 <vprintfmt+0x305>
	else if (lflag)
  8005b6:	85 c9                	test   %ecx,%ecx
  8005b8:	74 32                	je     8005ec <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8005ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bd:	8b 10                	mov    (%eax),%edx
  8005bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c4:	8d 40 04             	lea    0x4(%eax),%eax
  8005c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005ca:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8005cf:	e9 a3 00 00 00       	jmp    800677 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8b 10                	mov    (%eax),%edx
  8005d9:	8b 48 04             	mov    0x4(%eax),%ecx
  8005dc:	8d 40 08             	lea    0x8(%eax),%eax
  8005df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005e2:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8005e7:	e9 8b 00 00 00       	jmp    800677 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8b 10                	mov    (%eax),%edx
  8005f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f6:	8d 40 04             	lea    0x4(%eax),%eax
  8005f9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8005fc:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800601:	eb 74                	jmp    800677 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800603:	83 f9 01             	cmp    $0x1,%ecx
  800606:	7f 1b                	jg     800623 <vprintfmt+0x354>
	else if (lflag)
  800608:	85 c9                	test   %ecx,%ecx
  80060a:	74 2c                	je     800638 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8b 10                	mov    (%eax),%edx
  800611:	b9 00 00 00 00       	mov    $0x0,%ecx
  800616:	8d 40 04             	lea    0x4(%eax),%eax
  800619:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80061c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800621:	eb 54                	jmp    800677 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8b 10                	mov    (%eax),%edx
  800628:	8b 48 04             	mov    0x4(%eax),%ecx
  80062b:	8d 40 08             	lea    0x8(%eax),%eax
  80062e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800631:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800636:	eb 3f                	jmp    800677 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8b 10                	mov    (%eax),%edx
  80063d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800642:	8d 40 04             	lea    0x4(%eax),%eax
  800645:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800648:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80064d:	eb 28                	jmp    800677 <vprintfmt+0x3a8>
			putch('0', putdat);
  80064f:	83 ec 08             	sub    $0x8,%esp
  800652:	53                   	push   %ebx
  800653:	6a 30                	push   $0x30
  800655:	ff d6                	call   *%esi
			putch('x', putdat);
  800657:	83 c4 08             	add    $0x8,%esp
  80065a:	53                   	push   %ebx
  80065b:	6a 78                	push   $0x78
  80065d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8b 10                	mov    (%eax),%edx
  800664:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800669:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80066c:	8d 40 04             	lea    0x4(%eax),%eax
  80066f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800672:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800677:	83 ec 0c             	sub    $0xc,%esp
  80067a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80067e:	50                   	push   %eax
  80067f:	ff 75 e0             	push   -0x20(%ebp)
  800682:	57                   	push   %edi
  800683:	51                   	push   %ecx
  800684:	52                   	push   %edx
  800685:	89 da                	mov    %ebx,%edx
  800687:	89 f0                	mov    %esi,%eax
  800689:	e8 5e fb ff ff       	call   8001ec <printnum>
			break;
  80068e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800691:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800694:	e9 54 fc ff ff       	jmp    8002ed <vprintfmt+0x1e>
	if (lflag >= 2)
  800699:	83 f9 01             	cmp    $0x1,%ecx
  80069c:	7f 1b                	jg     8006b9 <vprintfmt+0x3ea>
	else if (lflag)
  80069e:	85 c9                	test   %ecx,%ecx
  8006a0:	74 2c                	je     8006ce <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8006a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a5:	8b 10                	mov    (%eax),%edx
  8006a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ac:	8d 40 04             	lea    0x4(%eax),%eax
  8006af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006b2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8006b7:	eb be                	jmp    800677 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bc:	8b 10                	mov    (%eax),%edx
  8006be:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c1:	8d 40 08             	lea    0x8(%eax),%eax
  8006c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006c7:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8006cc:	eb a9                	jmp    800677 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8b 10                	mov    (%eax),%edx
  8006d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006d8:	8d 40 04             	lea    0x4(%eax),%eax
  8006db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8006de:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8006e3:	eb 92                	jmp    800677 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8006e5:	83 ec 08             	sub    $0x8,%esp
  8006e8:	53                   	push   %ebx
  8006e9:	6a 25                	push   $0x25
  8006eb:	ff d6                	call   *%esi
			break;
  8006ed:	83 c4 10             	add    $0x10,%esp
  8006f0:	eb 9f                	jmp    800691 <vprintfmt+0x3c2>
			putch('%', putdat);
  8006f2:	83 ec 08             	sub    $0x8,%esp
  8006f5:	53                   	push   %ebx
  8006f6:	6a 25                	push   $0x25
  8006f8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	89 f8                	mov    %edi,%eax
  8006ff:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800703:	74 05                	je     80070a <vprintfmt+0x43b>
  800705:	83 e8 01             	sub    $0x1,%eax
  800708:	eb f5                	jmp    8006ff <vprintfmt+0x430>
  80070a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80070d:	eb 82                	jmp    800691 <vprintfmt+0x3c2>

0080070f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070f:	55                   	push   %ebp
  800710:	89 e5                	mov    %esp,%ebp
  800712:	83 ec 18             	sub    $0x18,%esp
  800715:	8b 45 08             	mov    0x8(%ebp),%eax
  800718:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80071b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800722:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800725:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80072c:	85 c0                	test   %eax,%eax
  80072e:	74 26                	je     800756 <vsnprintf+0x47>
  800730:	85 d2                	test   %edx,%edx
  800732:	7e 22                	jle    800756 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800734:	ff 75 14             	push   0x14(%ebp)
  800737:	ff 75 10             	push   0x10(%ebp)
  80073a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80073d:	50                   	push   %eax
  80073e:	68 95 02 80 00       	push   $0x800295
  800743:	e8 87 fb ff ff       	call   8002cf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800748:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80074b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800751:	83 c4 10             	add    $0x10,%esp
}
  800754:	c9                   	leave  
  800755:	c3                   	ret    
		return -E_INVAL;
  800756:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075b:	eb f7                	jmp    800754 <vsnprintf+0x45>

0080075d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80075d:	55                   	push   %ebp
  80075e:	89 e5                	mov    %esp,%ebp
  800760:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800763:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800766:	50                   	push   %eax
  800767:	ff 75 10             	push   0x10(%ebp)
  80076a:	ff 75 0c             	push   0xc(%ebp)
  80076d:	ff 75 08             	push   0x8(%ebp)
  800770:	e8 9a ff ff ff       	call   80070f <vsnprintf>
	va_end(ap);

	return rc;
}
  800775:	c9                   	leave  
  800776:	c3                   	ret    

00800777 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80077d:	b8 00 00 00 00       	mov    $0x0,%eax
  800782:	eb 03                	jmp    800787 <strlen+0x10>
		n++;
  800784:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800787:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80078b:	75 f7                	jne    800784 <strlen+0xd>
	return n;
}
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078f:	55                   	push   %ebp
  800790:	89 e5                	mov    %esp,%ebp
  800792:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800795:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800798:	b8 00 00 00 00       	mov    $0x0,%eax
  80079d:	eb 03                	jmp    8007a2 <strnlen+0x13>
		n++;
  80079f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a2:	39 d0                	cmp    %edx,%eax
  8007a4:	74 08                	je     8007ae <strnlen+0x1f>
  8007a6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007aa:	75 f3                	jne    80079f <strnlen+0x10>
  8007ac:	89 c2                	mov    %eax,%edx
	return n;
}
  8007ae:	89 d0                	mov    %edx,%eax
  8007b0:	5d                   	pop    %ebp
  8007b1:	c3                   	ret    

008007b2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	53                   	push   %ebx
  8007b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007c5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007c8:	83 c0 01             	add    $0x1,%eax
  8007cb:	84 d2                	test   %dl,%dl
  8007cd:	75 f2                	jne    8007c1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8007cf:	89 c8                	mov    %ecx,%eax
  8007d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d4:	c9                   	leave  
  8007d5:	c3                   	ret    

008007d6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	53                   	push   %ebx
  8007da:	83 ec 10             	sub    $0x10,%esp
  8007dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007e0:	53                   	push   %ebx
  8007e1:	e8 91 ff ff ff       	call   800777 <strlen>
  8007e6:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007e9:	ff 75 0c             	push   0xc(%ebp)
  8007ec:	01 d8                	add    %ebx,%eax
  8007ee:	50                   	push   %eax
  8007ef:	e8 be ff ff ff       	call   8007b2 <strcpy>
	return dst;
}
  8007f4:	89 d8                	mov    %ebx,%eax
  8007f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f9:	c9                   	leave  
  8007fa:	c3                   	ret    

008007fb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	56                   	push   %esi
  8007ff:	53                   	push   %ebx
  800800:	8b 75 08             	mov    0x8(%ebp),%esi
  800803:	8b 55 0c             	mov    0xc(%ebp),%edx
  800806:	89 f3                	mov    %esi,%ebx
  800808:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080b:	89 f0                	mov    %esi,%eax
  80080d:	eb 0f                	jmp    80081e <strncpy+0x23>
		*dst++ = *src;
  80080f:	83 c0 01             	add    $0x1,%eax
  800812:	0f b6 0a             	movzbl (%edx),%ecx
  800815:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800818:	80 f9 01             	cmp    $0x1,%cl
  80081b:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80081e:	39 d8                	cmp    %ebx,%eax
  800820:	75 ed                	jne    80080f <strncpy+0x14>
	}
	return ret;
}
  800822:	89 f0                	mov    %esi,%eax
  800824:	5b                   	pop    %ebx
  800825:	5e                   	pop    %esi
  800826:	5d                   	pop    %ebp
  800827:	c3                   	ret    

00800828 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	56                   	push   %esi
  80082c:	53                   	push   %ebx
  80082d:	8b 75 08             	mov    0x8(%ebp),%esi
  800830:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800833:	8b 55 10             	mov    0x10(%ebp),%edx
  800836:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800838:	85 d2                	test   %edx,%edx
  80083a:	74 21                	je     80085d <strlcpy+0x35>
  80083c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800840:	89 f2                	mov    %esi,%edx
  800842:	eb 09                	jmp    80084d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800844:	83 c1 01             	add    $0x1,%ecx
  800847:	83 c2 01             	add    $0x1,%edx
  80084a:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80084d:	39 c2                	cmp    %eax,%edx
  80084f:	74 09                	je     80085a <strlcpy+0x32>
  800851:	0f b6 19             	movzbl (%ecx),%ebx
  800854:	84 db                	test   %bl,%bl
  800856:	75 ec                	jne    800844 <strlcpy+0x1c>
  800858:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80085a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085d:	29 f0                	sub    %esi,%eax
}
  80085f:	5b                   	pop    %ebx
  800860:	5e                   	pop    %esi
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800863:	55                   	push   %ebp
  800864:	89 e5                	mov    %esp,%ebp
  800866:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086c:	eb 06                	jmp    800874 <strcmp+0x11>
		p++, q++;
  80086e:	83 c1 01             	add    $0x1,%ecx
  800871:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800874:	0f b6 01             	movzbl (%ecx),%eax
  800877:	84 c0                	test   %al,%al
  800879:	74 04                	je     80087f <strcmp+0x1c>
  80087b:	3a 02                	cmp    (%edx),%al
  80087d:	74 ef                	je     80086e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087f:	0f b6 c0             	movzbl %al,%eax
  800882:	0f b6 12             	movzbl (%edx),%edx
  800885:	29 d0                	sub    %edx,%eax
}
  800887:	5d                   	pop    %ebp
  800888:	c3                   	ret    

00800889 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800889:	55                   	push   %ebp
  80088a:	89 e5                	mov    %esp,%ebp
  80088c:	53                   	push   %ebx
  80088d:	8b 45 08             	mov    0x8(%ebp),%eax
  800890:	8b 55 0c             	mov    0xc(%ebp),%edx
  800893:	89 c3                	mov    %eax,%ebx
  800895:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800898:	eb 06                	jmp    8008a0 <strncmp+0x17>
		n--, p++, q++;
  80089a:	83 c0 01             	add    $0x1,%eax
  80089d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008a0:	39 d8                	cmp    %ebx,%eax
  8008a2:	74 18                	je     8008bc <strncmp+0x33>
  8008a4:	0f b6 08             	movzbl (%eax),%ecx
  8008a7:	84 c9                	test   %cl,%cl
  8008a9:	74 04                	je     8008af <strncmp+0x26>
  8008ab:	3a 0a                	cmp    (%edx),%cl
  8008ad:	74 eb                	je     80089a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008af:	0f b6 00             	movzbl (%eax),%eax
  8008b2:	0f b6 12             	movzbl (%edx),%edx
  8008b5:	29 d0                	sub    %edx,%eax
}
  8008b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ba:	c9                   	leave  
  8008bb:	c3                   	ret    
		return 0;
  8008bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c1:	eb f4                	jmp    8008b7 <strncmp+0x2e>

008008c3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008cd:	eb 03                	jmp    8008d2 <strchr+0xf>
  8008cf:	83 c0 01             	add    $0x1,%eax
  8008d2:	0f b6 10             	movzbl (%eax),%edx
  8008d5:	84 d2                	test   %dl,%dl
  8008d7:	74 06                	je     8008df <strchr+0x1c>
		if (*s == c)
  8008d9:	38 ca                	cmp    %cl,%dl
  8008db:	75 f2                	jne    8008cf <strchr+0xc>
  8008dd:	eb 05                	jmp    8008e4 <strchr+0x21>
			return (char *) s;
	return 0;
  8008df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008f0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f3:	38 ca                	cmp    %cl,%dl
  8008f5:	74 09                	je     800900 <strfind+0x1a>
  8008f7:	84 d2                	test   %dl,%dl
  8008f9:	74 05                	je     800900 <strfind+0x1a>
	for (; *s; s++)
  8008fb:	83 c0 01             	add    $0x1,%eax
  8008fe:	eb f0                	jmp    8008f0 <strfind+0xa>
			break;
	return (char *) s;
}
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    

00800902 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800902:	55                   	push   %ebp
  800903:	89 e5                	mov    %esp,%ebp
  800905:	57                   	push   %edi
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	8b 7d 08             	mov    0x8(%ebp),%edi
  80090b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80090e:	85 c9                	test   %ecx,%ecx
  800910:	74 2f                	je     800941 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800912:	89 f8                	mov    %edi,%eax
  800914:	09 c8                	or     %ecx,%eax
  800916:	a8 03                	test   $0x3,%al
  800918:	75 21                	jne    80093b <memset+0x39>
		c &= 0xFF;
  80091a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091e:	89 d0                	mov    %edx,%eax
  800920:	c1 e0 08             	shl    $0x8,%eax
  800923:	89 d3                	mov    %edx,%ebx
  800925:	c1 e3 18             	shl    $0x18,%ebx
  800928:	89 d6                	mov    %edx,%esi
  80092a:	c1 e6 10             	shl    $0x10,%esi
  80092d:	09 f3                	or     %esi,%ebx
  80092f:	09 da                	or     %ebx,%edx
  800931:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800933:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800936:	fc                   	cld    
  800937:	f3 ab                	rep stos %eax,%es:(%edi)
  800939:	eb 06                	jmp    800941 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093e:	fc                   	cld    
  80093f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800941:	89 f8                	mov    %edi,%eax
  800943:	5b                   	pop    %ebx
  800944:	5e                   	pop    %esi
  800945:	5f                   	pop    %edi
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	57                   	push   %edi
  80094c:	56                   	push   %esi
  80094d:	8b 45 08             	mov    0x8(%ebp),%eax
  800950:	8b 75 0c             	mov    0xc(%ebp),%esi
  800953:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800956:	39 c6                	cmp    %eax,%esi
  800958:	73 32                	jae    80098c <memmove+0x44>
  80095a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095d:	39 c2                	cmp    %eax,%edx
  80095f:	76 2b                	jbe    80098c <memmove+0x44>
		s += n;
		d += n;
  800961:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800964:	89 d6                	mov    %edx,%esi
  800966:	09 fe                	or     %edi,%esi
  800968:	09 ce                	or     %ecx,%esi
  80096a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800970:	75 0e                	jne    800980 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800972:	83 ef 04             	sub    $0x4,%edi
  800975:	8d 72 fc             	lea    -0x4(%edx),%esi
  800978:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80097b:	fd                   	std    
  80097c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80097e:	eb 09                	jmp    800989 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800980:	83 ef 01             	sub    $0x1,%edi
  800983:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800986:	fd                   	std    
  800987:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800989:	fc                   	cld    
  80098a:	eb 1a                	jmp    8009a6 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098c:	89 f2                	mov    %esi,%edx
  80098e:	09 c2                	or     %eax,%edx
  800990:	09 ca                	or     %ecx,%edx
  800992:	f6 c2 03             	test   $0x3,%dl
  800995:	75 0a                	jne    8009a1 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800997:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80099a:	89 c7                	mov    %eax,%edi
  80099c:	fc                   	cld    
  80099d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099f:	eb 05                	jmp    8009a6 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8009a1:	89 c7                	mov    %eax,%edi
  8009a3:	fc                   	cld    
  8009a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a6:	5e                   	pop    %esi
  8009a7:	5f                   	pop    %edi
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009b0:	ff 75 10             	push   0x10(%ebp)
  8009b3:	ff 75 0c             	push   0xc(%ebp)
  8009b6:	ff 75 08             	push   0x8(%ebp)
  8009b9:	e8 8a ff ff ff       	call   800948 <memmove>
}
  8009be:	c9                   	leave  
  8009bf:	c3                   	ret    

008009c0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	56                   	push   %esi
  8009c4:	53                   	push   %ebx
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cb:	89 c6                	mov    %eax,%esi
  8009cd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d0:	eb 06                	jmp    8009d8 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009d2:	83 c0 01             	add    $0x1,%eax
  8009d5:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8009d8:	39 f0                	cmp    %esi,%eax
  8009da:	74 14                	je     8009f0 <memcmp+0x30>
		if (*s1 != *s2)
  8009dc:	0f b6 08             	movzbl (%eax),%ecx
  8009df:	0f b6 1a             	movzbl (%edx),%ebx
  8009e2:	38 d9                	cmp    %bl,%cl
  8009e4:	74 ec                	je     8009d2 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8009e6:	0f b6 c1             	movzbl %cl,%eax
  8009e9:	0f b6 db             	movzbl %bl,%ebx
  8009ec:	29 d8                	sub    %ebx,%eax
  8009ee:	eb 05                	jmp    8009f5 <memcmp+0x35>
	}

	return 0;
  8009f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f5:	5b                   	pop    %ebx
  8009f6:	5e                   	pop    %esi
  8009f7:	5d                   	pop    %ebp
  8009f8:	c3                   	ret    

008009f9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f9:	55                   	push   %ebp
  8009fa:	89 e5                	mov    %esp,%ebp
  8009fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a02:	89 c2                	mov    %eax,%edx
  800a04:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a07:	eb 03                	jmp    800a0c <memfind+0x13>
  800a09:	83 c0 01             	add    $0x1,%eax
  800a0c:	39 d0                	cmp    %edx,%eax
  800a0e:	73 04                	jae    800a14 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a10:	38 08                	cmp    %cl,(%eax)
  800a12:	75 f5                	jne    800a09 <memfind+0x10>
			break;
	return (void *) s;
}
  800a14:	5d                   	pop    %ebp
  800a15:	c3                   	ret    

00800a16 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	57                   	push   %edi
  800a1a:	56                   	push   %esi
  800a1b:	53                   	push   %ebx
  800a1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a22:	eb 03                	jmp    800a27 <strtol+0x11>
		s++;
  800a24:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800a27:	0f b6 02             	movzbl (%edx),%eax
  800a2a:	3c 20                	cmp    $0x20,%al
  800a2c:	74 f6                	je     800a24 <strtol+0xe>
  800a2e:	3c 09                	cmp    $0x9,%al
  800a30:	74 f2                	je     800a24 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800a32:	3c 2b                	cmp    $0x2b,%al
  800a34:	74 2a                	je     800a60 <strtol+0x4a>
	int neg = 0;
  800a36:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a3b:	3c 2d                	cmp    $0x2d,%al
  800a3d:	74 2b                	je     800a6a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a45:	75 0f                	jne    800a56 <strtol+0x40>
  800a47:	80 3a 30             	cmpb   $0x30,(%edx)
  800a4a:	74 28                	je     800a74 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4c:	85 db                	test   %ebx,%ebx
  800a4e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a53:	0f 44 d8             	cmove  %eax,%ebx
  800a56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800a5b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a5e:	eb 46                	jmp    800aa6 <strtol+0x90>
		s++;
  800a60:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800a63:	bf 00 00 00 00       	mov    $0x0,%edi
  800a68:	eb d5                	jmp    800a3f <strtol+0x29>
		s++, neg = 1;
  800a6a:	83 c2 01             	add    $0x1,%edx
  800a6d:	bf 01 00 00 00       	mov    $0x1,%edi
  800a72:	eb cb                	jmp    800a3f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a74:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800a78:	74 0e                	je     800a88 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800a7a:	85 db                	test   %ebx,%ebx
  800a7c:	75 d8                	jne    800a56 <strtol+0x40>
		s++, base = 8;
  800a7e:	83 c2 01             	add    $0x1,%edx
  800a81:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a86:	eb ce                	jmp    800a56 <strtol+0x40>
		s += 2, base = 16;
  800a88:	83 c2 02             	add    $0x2,%edx
  800a8b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a90:	eb c4                	jmp    800a56 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a92:	0f be c0             	movsbl %al,%eax
  800a95:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a98:	3b 45 10             	cmp    0x10(%ebp),%eax
  800a9b:	7d 3a                	jge    800ad7 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800a9d:	83 c2 01             	add    $0x1,%edx
  800aa0:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800aa4:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800aa6:	0f b6 02             	movzbl (%edx),%eax
  800aa9:	8d 70 d0             	lea    -0x30(%eax),%esi
  800aac:	89 f3                	mov    %esi,%ebx
  800aae:	80 fb 09             	cmp    $0x9,%bl
  800ab1:	76 df                	jbe    800a92 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800ab3:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ab6:	89 f3                	mov    %esi,%ebx
  800ab8:	80 fb 19             	cmp    $0x19,%bl
  800abb:	77 08                	ja     800ac5 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800abd:	0f be c0             	movsbl %al,%eax
  800ac0:	83 e8 57             	sub    $0x57,%eax
  800ac3:	eb d3                	jmp    800a98 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800ac5:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ac8:	89 f3                	mov    %esi,%ebx
  800aca:	80 fb 19             	cmp    $0x19,%bl
  800acd:	77 08                	ja     800ad7 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800acf:	0f be c0             	movsbl %al,%eax
  800ad2:	83 e8 37             	sub    $0x37,%eax
  800ad5:	eb c1                	jmp    800a98 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800adb:	74 05                	je     800ae2 <strtol+0xcc>
		*endptr = (char *) s;
  800add:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae0:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ae2:	89 c8                	mov    %ecx,%eax
  800ae4:	f7 d8                	neg    %eax
  800ae6:	85 ff                	test   %edi,%edi
  800ae8:	0f 45 c8             	cmovne %eax,%ecx
}
  800aeb:	89 c8                	mov    %ecx,%eax
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5f                   	pop    %edi
  800af0:	5d                   	pop    %ebp
  800af1:	c3                   	ret    

00800af2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800af8:	b8 00 00 00 00       	mov    $0x0,%eax
  800afd:	8b 55 08             	mov    0x8(%ebp),%edx
  800b00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b03:	89 c3                	mov    %eax,%ebx
  800b05:	89 c7                	mov    %eax,%edi
  800b07:	89 c6                	mov    %eax,%esi
  800b09:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5f                   	pop    %edi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	57                   	push   %edi
  800b14:	56                   	push   %esi
  800b15:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b16:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1b:	b8 01 00 00 00       	mov    $0x1,%eax
  800b20:	89 d1                	mov    %edx,%ecx
  800b22:	89 d3                	mov    %edx,%ebx
  800b24:	89 d7                	mov    %edx,%edi
  800b26:	89 d6                	mov    %edx,%esi
  800b28:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2a:	5b                   	pop    %ebx
  800b2b:	5e                   	pop    %esi
  800b2c:	5f                   	pop    %edi
  800b2d:	5d                   	pop    %ebp
  800b2e:	c3                   	ret    

00800b2f <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b2f:	55                   	push   %ebp
  800b30:	89 e5                	mov    %esp,%ebp
  800b32:	57                   	push   %edi
  800b33:	56                   	push   %esi
  800b34:	53                   	push   %ebx
  800b35:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800b38:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b40:	b8 03 00 00 00       	mov    $0x3,%eax
  800b45:	89 cb                	mov    %ecx,%ebx
  800b47:	89 cf                	mov    %ecx,%edi
  800b49:	89 ce                	mov    %ecx,%esi
  800b4b:	cd 30                	int    $0x30
	if(check && ret > 0)
  800b4d:	85 c0                	test   %eax,%eax
  800b4f:	7f 08                	jg     800b59 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b54:	5b                   	pop    %ebx
  800b55:	5e                   	pop    %esi
  800b56:	5f                   	pop    %edi
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b59:	83 ec 0c             	sub    $0xc,%esp
  800b5c:	50                   	push   %eax
  800b5d:	6a 03                	push   $0x3
  800b5f:	68 ff 28 80 00       	push   $0x8028ff
  800b64:	6a 2a                	push   $0x2a
  800b66:	68 1c 29 80 00       	push   $0x80291c
  800b6b:	e8 1c 16 00 00       	call   80218c <_panic>

00800b70 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	57                   	push   %edi
  800b74:	56                   	push   %esi
  800b75:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b76:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7b:	b8 02 00 00 00       	mov    $0x2,%eax
  800b80:	89 d1                	mov    %edx,%ecx
  800b82:	89 d3                	mov    %edx,%ebx
  800b84:	89 d7                	mov    %edx,%edi
  800b86:	89 d6                	mov    %edx,%esi
  800b88:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5f                   	pop    %edi
  800b8d:	5d                   	pop    %ebp
  800b8e:	c3                   	ret    

00800b8f <sys_yield>:

void
sys_yield(void)
{
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	57                   	push   %edi
  800b93:	56                   	push   %esi
  800b94:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b95:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9a:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b9f:	89 d1                	mov    %edx,%ecx
  800ba1:	89 d3                	mov    %edx,%ebx
  800ba3:	89 d7                	mov    %edx,%edi
  800ba5:	89 d6                	mov    %edx,%esi
  800ba7:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
  800bb4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bb7:	be 00 00 00 00       	mov    $0x0,%esi
  800bbc:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc2:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bca:	89 f7                	mov    %esi,%edi
  800bcc:	cd 30                	int    $0x30
	if(check && ret > 0)
  800bce:	85 c0                	test   %eax,%eax
  800bd0:	7f 08                	jg     800bda <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd5:	5b                   	pop    %ebx
  800bd6:	5e                   	pop    %esi
  800bd7:	5f                   	pop    %edi
  800bd8:	5d                   	pop    %ebp
  800bd9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bda:	83 ec 0c             	sub    $0xc,%esp
  800bdd:	50                   	push   %eax
  800bde:	6a 04                	push   $0x4
  800be0:	68 ff 28 80 00       	push   $0x8028ff
  800be5:	6a 2a                	push   $0x2a
  800be7:	68 1c 29 80 00       	push   $0x80291c
  800bec:	e8 9b 15 00 00       	call   80218c <_panic>

00800bf1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf1:	55                   	push   %ebp
  800bf2:	89 e5                	mov    %esp,%ebp
  800bf4:	57                   	push   %edi
  800bf5:	56                   	push   %esi
  800bf6:	53                   	push   %ebx
  800bf7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c00:	b8 05 00 00 00       	mov    $0x5,%eax
  800c05:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c08:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0b:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c10:	85 c0                	test   %eax,%eax
  800c12:	7f 08                	jg     800c1c <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c17:	5b                   	pop    %ebx
  800c18:	5e                   	pop    %esi
  800c19:	5f                   	pop    %edi
  800c1a:	5d                   	pop    %ebp
  800c1b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1c:	83 ec 0c             	sub    $0xc,%esp
  800c1f:	50                   	push   %eax
  800c20:	6a 05                	push   $0x5
  800c22:	68 ff 28 80 00       	push   $0x8028ff
  800c27:	6a 2a                	push   $0x2a
  800c29:	68 1c 29 80 00       	push   $0x80291c
  800c2e:	e8 59 15 00 00       	call   80218c <_panic>

00800c33 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c3c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c41:	8b 55 08             	mov    0x8(%ebp),%edx
  800c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c47:	b8 06 00 00 00       	mov    $0x6,%eax
  800c4c:	89 df                	mov    %ebx,%edi
  800c4e:	89 de                	mov    %ebx,%esi
  800c50:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c52:	85 c0                	test   %eax,%eax
  800c54:	7f 08                	jg     800c5e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c59:	5b                   	pop    %ebx
  800c5a:	5e                   	pop    %esi
  800c5b:	5f                   	pop    %edi
  800c5c:	5d                   	pop    %ebp
  800c5d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c5e:	83 ec 0c             	sub    $0xc,%esp
  800c61:	50                   	push   %eax
  800c62:	6a 06                	push   $0x6
  800c64:	68 ff 28 80 00       	push   $0x8028ff
  800c69:	6a 2a                	push   $0x2a
  800c6b:	68 1c 29 80 00       	push   $0x80291c
  800c70:	e8 17 15 00 00       	call   80218c <_panic>

00800c75 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c75:	55                   	push   %ebp
  800c76:	89 e5                	mov    %esp,%ebp
  800c78:	57                   	push   %edi
  800c79:	56                   	push   %esi
  800c7a:	53                   	push   %ebx
  800c7b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c83:	8b 55 08             	mov    0x8(%ebp),%edx
  800c86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c89:	b8 08 00 00 00       	mov    $0x8,%eax
  800c8e:	89 df                	mov    %ebx,%edi
  800c90:	89 de                	mov    %ebx,%esi
  800c92:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c94:	85 c0                	test   %eax,%eax
  800c96:	7f 08                	jg     800ca0 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9b:	5b                   	pop    %ebx
  800c9c:	5e                   	pop    %esi
  800c9d:	5f                   	pop    %edi
  800c9e:	5d                   	pop    %ebp
  800c9f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca0:	83 ec 0c             	sub    $0xc,%esp
  800ca3:	50                   	push   %eax
  800ca4:	6a 08                	push   $0x8
  800ca6:	68 ff 28 80 00       	push   $0x8028ff
  800cab:	6a 2a                	push   $0x2a
  800cad:	68 1c 29 80 00       	push   $0x80291c
  800cb2:	e8 d5 14 00 00       	call   80218c <_panic>

00800cb7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cc0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800cc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ccb:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd0:	89 df                	mov    %ebx,%edi
  800cd2:	89 de                	mov    %ebx,%esi
  800cd4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	7f 08                	jg     800ce2 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cda:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce2:	83 ec 0c             	sub    $0xc,%esp
  800ce5:	50                   	push   %eax
  800ce6:	6a 09                	push   $0x9
  800ce8:	68 ff 28 80 00       	push   $0x8028ff
  800ced:	6a 2a                	push   $0x2a
  800cef:	68 1c 29 80 00       	push   $0x80291c
  800cf4:	e8 93 14 00 00       	call   80218c <_panic>

00800cf9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf9:	55                   	push   %ebp
  800cfa:	89 e5                	mov    %esp,%ebp
  800cfc:	57                   	push   %edi
  800cfd:	56                   	push   %esi
  800cfe:	53                   	push   %ebx
  800cff:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d02:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d12:	89 df                	mov    %ebx,%edi
  800d14:	89 de                	mov    %ebx,%esi
  800d16:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d18:	85 c0                	test   %eax,%eax
  800d1a:	7f 08                	jg     800d24 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d1f:	5b                   	pop    %ebx
  800d20:	5e                   	pop    %esi
  800d21:	5f                   	pop    %edi
  800d22:	5d                   	pop    %ebp
  800d23:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d24:	83 ec 0c             	sub    $0xc,%esp
  800d27:	50                   	push   %eax
  800d28:	6a 0a                	push   $0xa
  800d2a:	68 ff 28 80 00       	push   $0x8028ff
  800d2f:	6a 2a                	push   $0x2a
  800d31:	68 1c 29 80 00       	push   $0x80291c
  800d36:	e8 51 14 00 00       	call   80218c <_panic>

00800d3b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	57                   	push   %edi
  800d3f:	56                   	push   %esi
  800d40:	53                   	push   %ebx
	asm volatile("int %1\n"
  800d41:	8b 55 08             	mov    0x8(%ebp),%edx
  800d44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d47:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4c:	be 00 00 00 00       	mov    $0x0,%esi
  800d51:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d54:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d57:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d59:	5b                   	pop    %ebx
  800d5a:	5e                   	pop    %esi
  800d5b:	5f                   	pop    %edi
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	57                   	push   %edi
  800d62:	56                   	push   %esi
  800d63:	53                   	push   %ebx
  800d64:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d74:	89 cb                	mov    %ecx,%ebx
  800d76:	89 cf                	mov    %ecx,%edi
  800d78:	89 ce                	mov    %ecx,%esi
  800d7a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	7f 08                	jg     800d88 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d88:	83 ec 0c             	sub    $0xc,%esp
  800d8b:	50                   	push   %eax
  800d8c:	6a 0d                	push   $0xd
  800d8e:	68 ff 28 80 00       	push   $0x8028ff
  800d93:	6a 2a                	push   $0x2a
  800d95:	68 1c 29 80 00       	push   $0x80291c
  800d9a:	e8 ed 13 00 00       	call   80218c <_panic>

00800d9f <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	57                   	push   %edi
  800da3:	56                   	push   %esi
  800da4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800da5:	ba 00 00 00 00       	mov    $0x0,%edx
  800daa:	b8 0e 00 00 00       	mov    $0xe,%eax
  800daf:	89 d1                	mov    %edx,%ecx
  800db1:	89 d3                	mov    %edx,%ebx
  800db3:	89 d7                	mov    %edx,%edi
  800db5:	89 d6                	mov    %edx,%esi
  800db7:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800db9:	5b                   	pop    %ebx
  800dba:	5e                   	pop    %esi
  800dbb:	5f                   	pop    %edi
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    

00800dbe <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	57                   	push   %edi
  800dc2:	56                   	push   %esi
  800dc3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800dc4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dcf:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dd4:	89 df                	mov    %ebx,%edi
  800dd6:	89 de                	mov    %ebx,%esi
  800dd8:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800dda:	5b                   	pop    %ebx
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	57                   	push   %edi
  800de3:	56                   	push   %esi
  800de4:	53                   	push   %ebx
	asm volatile("int %1\n"
  800de5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ded:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df0:	b8 10 00 00 00       	mov    $0x10,%eax
  800df5:	89 df                	mov    %ebx,%edi
  800df7:	89 de                	mov    %ebx,%esi
  800df9:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800dfb:	5b                   	pop    %ebx
  800dfc:	5e                   	pop    %esi
  800dfd:	5f                   	pop    %edi
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	56                   	push   %esi
  800e04:	53                   	push   %ebx
  800e05:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800e08:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e0a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800e0e:	0f 84 8e 00 00 00    	je     800ea2 <pgfault+0xa2>
  800e14:	89 f0                	mov    %esi,%eax
  800e16:	c1 e8 0c             	shr    $0xc,%eax
  800e19:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800e20:	f6 c4 08             	test   $0x8,%ah
  800e23:	74 7d                	je     800ea2 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800e25:	e8 46 fd ff ff       	call   800b70 <sys_getenvid>
  800e2a:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800e2c:	83 ec 04             	sub    $0x4,%esp
  800e2f:	6a 07                	push   $0x7
  800e31:	68 00 f0 7f 00       	push   $0x7ff000
  800e36:	50                   	push   %eax
  800e37:	e8 72 fd ff ff       	call   800bae <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e3c:	83 c4 10             	add    $0x10,%esp
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	78 73                	js     800eb6 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800e43:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800e49:	83 ec 04             	sub    $0x4,%esp
  800e4c:	68 00 10 00 00       	push   $0x1000
  800e51:	56                   	push   %esi
  800e52:	68 00 f0 7f 00       	push   $0x7ff000
  800e57:	e8 ec fa ff ff       	call   800948 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800e5c:	83 c4 08             	add    $0x8,%esp
  800e5f:	56                   	push   %esi
  800e60:	53                   	push   %ebx
  800e61:	e8 cd fd ff ff       	call   800c33 <sys_page_unmap>
  800e66:	83 c4 10             	add    $0x10,%esp
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	78 5b                	js     800ec8 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800e6d:	83 ec 0c             	sub    $0xc,%esp
  800e70:	6a 07                	push   $0x7
  800e72:	56                   	push   %esi
  800e73:	53                   	push   %ebx
  800e74:	68 00 f0 7f 00       	push   $0x7ff000
  800e79:	53                   	push   %ebx
  800e7a:	e8 72 fd ff ff       	call   800bf1 <sys_page_map>
  800e7f:	83 c4 20             	add    $0x20,%esp
  800e82:	85 c0                	test   %eax,%eax
  800e84:	78 54                	js     800eda <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800e86:	83 ec 08             	sub    $0x8,%esp
  800e89:	68 00 f0 7f 00       	push   $0x7ff000
  800e8e:	53                   	push   %ebx
  800e8f:	e8 9f fd ff ff       	call   800c33 <sys_page_unmap>
  800e94:	83 c4 10             	add    $0x10,%esp
  800e97:	85 c0                	test   %eax,%eax
  800e99:	78 51                	js     800eec <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800e9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e9e:	5b                   	pop    %ebx
  800e9f:	5e                   	pop    %esi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800ea2:	83 ec 04             	sub    $0x4,%esp
  800ea5:	68 2c 29 80 00       	push   $0x80292c
  800eaa:	6a 1d                	push   $0x1d
  800eac:	68 a8 29 80 00       	push   $0x8029a8
  800eb1:	e8 d6 12 00 00       	call   80218c <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800eb6:	50                   	push   %eax
  800eb7:	68 64 29 80 00       	push   $0x802964
  800ebc:	6a 29                	push   $0x29
  800ebe:	68 a8 29 80 00       	push   $0x8029a8
  800ec3:	e8 c4 12 00 00       	call   80218c <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800ec8:	50                   	push   %eax
  800ec9:	68 88 29 80 00       	push   $0x802988
  800ece:	6a 2e                	push   $0x2e
  800ed0:	68 a8 29 80 00       	push   $0x8029a8
  800ed5:	e8 b2 12 00 00       	call   80218c <_panic>
		panic("pgfault: page map failed (%e)", r);
  800eda:	50                   	push   %eax
  800edb:	68 b3 29 80 00       	push   $0x8029b3
  800ee0:	6a 30                	push   $0x30
  800ee2:	68 a8 29 80 00       	push   $0x8029a8
  800ee7:	e8 a0 12 00 00       	call   80218c <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800eec:	50                   	push   %eax
  800eed:	68 88 29 80 00       	push   $0x802988
  800ef2:	6a 32                	push   $0x32
  800ef4:	68 a8 29 80 00       	push   $0x8029a8
  800ef9:	e8 8e 12 00 00       	call   80218c <_panic>

00800efe <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	57                   	push   %edi
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800f07:	68 00 0e 80 00       	push   $0x800e00
  800f0c:	e8 c1 12 00 00       	call   8021d2 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800f11:	b8 07 00 00 00       	mov    $0x7,%eax
  800f16:	cd 30                	int    $0x30
  800f18:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800f1b:	83 c4 10             	add    $0x10,%esp
  800f1e:	85 c0                	test   %eax,%eax
  800f20:	78 2d                	js     800f4f <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f22:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800f27:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800f2b:	75 73                	jne    800fa0 <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  800f2d:	e8 3e fc ff ff       	call   800b70 <sys_getenvid>
  800f32:	25 ff 03 00 00       	and    $0x3ff,%eax
  800f37:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800f3a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800f3f:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  800f44:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800f47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f4a:	5b                   	pop    %ebx
  800f4b:	5e                   	pop    %esi
  800f4c:	5f                   	pop    %edi
  800f4d:	5d                   	pop    %ebp
  800f4e:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  800f4f:	50                   	push   %eax
  800f50:	68 d1 29 80 00       	push   $0x8029d1
  800f55:	6a 78                	push   $0x78
  800f57:	68 a8 29 80 00       	push   $0x8029a8
  800f5c:	e8 2b 12 00 00       	call   80218c <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  800f61:	83 ec 0c             	sub    $0xc,%esp
  800f64:	ff 75 e4             	push   -0x1c(%ebp)
  800f67:	57                   	push   %edi
  800f68:	ff 75 dc             	push   -0x24(%ebp)
  800f6b:	57                   	push   %edi
  800f6c:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800f6f:	56                   	push   %esi
  800f70:	e8 7c fc ff ff       	call   800bf1 <sys_page_map>
	if(r<0) return r;
  800f75:	83 c4 20             	add    $0x20,%esp
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	78 cb                	js     800f47 <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  800f7c:	83 ec 0c             	sub    $0xc,%esp
  800f7f:	ff 75 e4             	push   -0x1c(%ebp)
  800f82:	57                   	push   %edi
  800f83:	56                   	push   %esi
  800f84:	57                   	push   %edi
  800f85:	56                   	push   %esi
  800f86:	e8 66 fc ff ff       	call   800bf1 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800f8b:	83 c4 20             	add    $0x20,%esp
  800f8e:	85 c0                	test   %eax,%eax
  800f90:	78 76                	js     801008 <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f92:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f98:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f9e:	74 75                	je     801015 <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800fa0:	89 d8                	mov    %ebx,%eax
  800fa2:	c1 e8 16             	shr    $0x16,%eax
  800fa5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fac:	a8 01                	test   $0x1,%al
  800fae:	74 e2                	je     800f92 <fork+0x94>
  800fb0:	89 de                	mov    %ebx,%esi
  800fb2:	c1 ee 0c             	shr    $0xc,%esi
  800fb5:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fbc:	a8 01                	test   $0x1,%al
  800fbe:	74 d2                	je     800f92 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  800fc0:	e8 ab fb ff ff       	call   800b70 <sys_getenvid>
  800fc5:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  800fc8:	89 f7                	mov    %esi,%edi
  800fca:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  800fcd:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800fd4:	89 c1                	mov    %eax,%ecx
  800fd6:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  800fdc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  800fdf:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  800fe6:	f6 c6 04             	test   $0x4,%dh
  800fe9:	0f 85 72 ff ff ff    	jne    800f61 <fork+0x63>
		perm &= ~PTE_W;
  800fef:	25 05 0e 00 00       	and    $0xe05,%eax
  800ff4:	80 cc 08             	or     $0x8,%ah
  800ff7:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  800ffd:	0f 44 c1             	cmove  %ecx,%eax
  801000:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801003:	e9 59 ff ff ff       	jmp    800f61 <fork+0x63>
  801008:	ba 00 00 00 00       	mov    $0x0,%edx
  80100d:	0f 4f c2             	cmovg  %edx,%eax
  801010:	e9 32 ff ff ff       	jmp    800f47 <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  801015:	83 ec 04             	sub    $0x4,%esp
  801018:	6a 07                	push   $0x7
  80101a:	68 00 f0 bf ee       	push   $0xeebff000
  80101f:	8b 7d dc             	mov    -0x24(%ebp),%edi
  801022:	57                   	push   %edi
  801023:	e8 86 fb ff ff       	call   800bae <sys_page_alloc>
	if(r<0) return r;
  801028:	83 c4 10             	add    $0x10,%esp
  80102b:	85 c0                	test   %eax,%eax
  80102d:	0f 88 14 ff ff ff    	js     800f47 <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  801033:	83 ec 08             	sub    $0x8,%esp
  801036:	68 48 22 80 00       	push   $0x802248
  80103b:	57                   	push   %edi
  80103c:	e8 b8 fc ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  801041:	83 c4 10             	add    $0x10,%esp
  801044:	85 c0                	test   %eax,%eax
  801046:	0f 88 fb fe ff ff    	js     800f47 <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  80104c:	83 ec 08             	sub    $0x8,%esp
  80104f:	6a 02                	push   $0x2
  801051:	57                   	push   %edi
  801052:	e8 1e fc ff ff       	call   800c75 <sys_env_set_status>
	if(r<0) return r;
  801057:	83 c4 10             	add    $0x10,%esp
	return envid;
  80105a:	85 c0                	test   %eax,%eax
  80105c:	0f 49 c7             	cmovns %edi,%eax
  80105f:	e9 e3 fe ff ff       	jmp    800f47 <fork+0x49>

00801064 <sfork>:

// Challenge!
int
sfork(void)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80106a:	68 e1 29 80 00       	push   $0x8029e1
  80106f:	68 a1 00 00 00       	push   $0xa1
  801074:	68 a8 29 80 00       	push   $0x8029a8
  801079:	e8 0e 11 00 00       	call   80218c <_panic>

0080107e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801081:	8b 45 08             	mov    0x8(%ebp),%eax
  801084:	05 00 00 00 30       	add    $0x30000000,%eax
  801089:	c1 e8 0c             	shr    $0xc,%eax
}
  80108c:	5d                   	pop    %ebp
  80108d:	c3                   	ret    

0080108e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80108e:	55                   	push   %ebp
  80108f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801091:	8b 45 08             	mov    0x8(%ebp),%eax
  801094:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801099:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80109e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010a3:	5d                   	pop    %ebp
  8010a4:	c3                   	ret    

008010a5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010ad:	89 c2                	mov    %eax,%edx
  8010af:	c1 ea 16             	shr    $0x16,%edx
  8010b2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010b9:	f6 c2 01             	test   $0x1,%dl
  8010bc:	74 29                	je     8010e7 <fd_alloc+0x42>
  8010be:	89 c2                	mov    %eax,%edx
  8010c0:	c1 ea 0c             	shr    $0xc,%edx
  8010c3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010ca:	f6 c2 01             	test   $0x1,%dl
  8010cd:	74 18                	je     8010e7 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8010cf:	05 00 10 00 00       	add    $0x1000,%eax
  8010d4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010d9:	75 d2                	jne    8010ad <fd_alloc+0x8>
  8010db:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8010e0:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8010e5:	eb 05                	jmp    8010ec <fd_alloc+0x47>
			return 0;
  8010e7:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8010ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ef:	89 02                	mov    %eax,(%edx)
}
  8010f1:	89 c8                	mov    %ecx,%eax
  8010f3:	5d                   	pop    %ebp
  8010f4:	c3                   	ret    

008010f5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010fb:	83 f8 1f             	cmp    $0x1f,%eax
  8010fe:	77 30                	ja     801130 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801100:	c1 e0 0c             	shl    $0xc,%eax
  801103:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801108:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80110e:	f6 c2 01             	test   $0x1,%dl
  801111:	74 24                	je     801137 <fd_lookup+0x42>
  801113:	89 c2                	mov    %eax,%edx
  801115:	c1 ea 0c             	shr    $0xc,%edx
  801118:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80111f:	f6 c2 01             	test   $0x1,%dl
  801122:	74 1a                	je     80113e <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801124:	8b 55 0c             	mov    0xc(%ebp),%edx
  801127:	89 02                	mov    %eax,(%edx)
	return 0;
  801129:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80112e:	5d                   	pop    %ebp
  80112f:	c3                   	ret    
		return -E_INVAL;
  801130:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801135:	eb f7                	jmp    80112e <fd_lookup+0x39>
		return -E_INVAL;
  801137:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80113c:	eb f0                	jmp    80112e <fd_lookup+0x39>
  80113e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801143:	eb e9                	jmp    80112e <fd_lookup+0x39>

00801145 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	53                   	push   %ebx
  801149:	83 ec 04             	sub    $0x4,%esp
  80114c:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80114f:	b8 00 00 00 00       	mov    $0x0,%eax
  801154:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801159:	39 13                	cmp    %edx,(%ebx)
  80115b:	74 37                	je     801194 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  80115d:	83 c0 01             	add    $0x1,%eax
  801160:	8b 1c 85 74 2a 80 00 	mov    0x802a74(,%eax,4),%ebx
  801167:	85 db                	test   %ebx,%ebx
  801169:	75 ee                	jne    801159 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80116b:	a1 00 40 80 00       	mov    0x804000,%eax
  801170:	8b 40 48             	mov    0x48(%eax),%eax
  801173:	83 ec 04             	sub    $0x4,%esp
  801176:	52                   	push   %edx
  801177:	50                   	push   %eax
  801178:	68 f8 29 80 00       	push   $0x8029f8
  80117d:	e8 56 f0 ff ff       	call   8001d8 <cprintf>
	*dev = 0;
	return -E_INVAL;
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  80118a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80118d:	89 1a                	mov    %ebx,(%edx)
}
  80118f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801192:	c9                   	leave  
  801193:	c3                   	ret    
			return 0;
  801194:	b8 00 00 00 00       	mov    $0x0,%eax
  801199:	eb ef                	jmp    80118a <dev_lookup+0x45>

0080119b <fd_close>:
{
  80119b:	55                   	push   %ebp
  80119c:	89 e5                	mov    %esp,%ebp
  80119e:	57                   	push   %edi
  80119f:	56                   	push   %esi
  8011a0:	53                   	push   %ebx
  8011a1:	83 ec 24             	sub    $0x24,%esp
  8011a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8011a7:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011aa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8011ad:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8011ae:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011b4:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011b7:	50                   	push   %eax
  8011b8:	e8 38 ff ff ff       	call   8010f5 <fd_lookup>
  8011bd:	89 c3                	mov    %eax,%ebx
  8011bf:	83 c4 10             	add    $0x10,%esp
  8011c2:	85 c0                	test   %eax,%eax
  8011c4:	78 05                	js     8011cb <fd_close+0x30>
	    || fd != fd2)
  8011c6:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8011c9:	74 16                	je     8011e1 <fd_close+0x46>
		return (must_exist ? r : 0);
  8011cb:	89 f8                	mov    %edi,%eax
  8011cd:	84 c0                	test   %al,%al
  8011cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d4:	0f 44 d8             	cmove  %eax,%ebx
}
  8011d7:	89 d8                	mov    %ebx,%eax
  8011d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011dc:	5b                   	pop    %ebx
  8011dd:	5e                   	pop    %esi
  8011de:	5f                   	pop    %edi
  8011df:	5d                   	pop    %ebp
  8011e0:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011e1:	83 ec 08             	sub    $0x8,%esp
  8011e4:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8011e7:	50                   	push   %eax
  8011e8:	ff 36                	push   (%esi)
  8011ea:	e8 56 ff ff ff       	call   801145 <dev_lookup>
  8011ef:	89 c3                	mov    %eax,%ebx
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	78 1a                	js     801212 <fd_close+0x77>
		if (dev->dev_close)
  8011f8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011fb:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8011fe:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801203:	85 c0                	test   %eax,%eax
  801205:	74 0b                	je     801212 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801207:	83 ec 0c             	sub    $0xc,%esp
  80120a:	56                   	push   %esi
  80120b:	ff d0                	call   *%eax
  80120d:	89 c3                	mov    %eax,%ebx
  80120f:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801212:	83 ec 08             	sub    $0x8,%esp
  801215:	56                   	push   %esi
  801216:	6a 00                	push   $0x0
  801218:	e8 16 fa ff ff       	call   800c33 <sys_page_unmap>
	return r;
  80121d:	83 c4 10             	add    $0x10,%esp
  801220:	eb b5                	jmp    8011d7 <fd_close+0x3c>

00801222 <close>:

int
close(int fdnum)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
  801225:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801228:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122b:	50                   	push   %eax
  80122c:	ff 75 08             	push   0x8(%ebp)
  80122f:	e8 c1 fe ff ff       	call   8010f5 <fd_lookup>
  801234:	83 c4 10             	add    $0x10,%esp
  801237:	85 c0                	test   %eax,%eax
  801239:	79 02                	jns    80123d <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80123b:	c9                   	leave  
  80123c:	c3                   	ret    
		return fd_close(fd, 1);
  80123d:	83 ec 08             	sub    $0x8,%esp
  801240:	6a 01                	push   $0x1
  801242:	ff 75 f4             	push   -0xc(%ebp)
  801245:	e8 51 ff ff ff       	call   80119b <fd_close>
  80124a:	83 c4 10             	add    $0x10,%esp
  80124d:	eb ec                	jmp    80123b <close+0x19>

0080124f <close_all>:

void
close_all(void)
{
  80124f:	55                   	push   %ebp
  801250:	89 e5                	mov    %esp,%ebp
  801252:	53                   	push   %ebx
  801253:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801256:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80125b:	83 ec 0c             	sub    $0xc,%esp
  80125e:	53                   	push   %ebx
  80125f:	e8 be ff ff ff       	call   801222 <close>
	for (i = 0; i < MAXFD; i++)
  801264:	83 c3 01             	add    $0x1,%ebx
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	83 fb 20             	cmp    $0x20,%ebx
  80126d:	75 ec                	jne    80125b <close_all+0xc>
}
  80126f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801272:	c9                   	leave  
  801273:	c3                   	ret    

00801274 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801274:	55                   	push   %ebp
  801275:	89 e5                	mov    %esp,%ebp
  801277:	57                   	push   %edi
  801278:	56                   	push   %esi
  801279:	53                   	push   %ebx
  80127a:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80127d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801280:	50                   	push   %eax
  801281:	ff 75 08             	push   0x8(%ebp)
  801284:	e8 6c fe ff ff       	call   8010f5 <fd_lookup>
  801289:	89 c3                	mov    %eax,%ebx
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	85 c0                	test   %eax,%eax
  801290:	78 7f                	js     801311 <dup+0x9d>
		return r;
	close(newfdnum);
  801292:	83 ec 0c             	sub    $0xc,%esp
  801295:	ff 75 0c             	push   0xc(%ebp)
  801298:	e8 85 ff ff ff       	call   801222 <close>

	newfd = INDEX2FD(newfdnum);
  80129d:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012a0:	c1 e6 0c             	shl    $0xc,%esi
  8012a3:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8012a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012ac:	89 3c 24             	mov    %edi,(%esp)
  8012af:	e8 da fd ff ff       	call   80108e <fd2data>
  8012b4:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012b6:	89 34 24             	mov    %esi,(%esp)
  8012b9:	e8 d0 fd ff ff       	call   80108e <fd2data>
  8012be:	83 c4 10             	add    $0x10,%esp
  8012c1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012c4:	89 d8                	mov    %ebx,%eax
  8012c6:	c1 e8 16             	shr    $0x16,%eax
  8012c9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012d0:	a8 01                	test   $0x1,%al
  8012d2:	74 11                	je     8012e5 <dup+0x71>
  8012d4:	89 d8                	mov    %ebx,%eax
  8012d6:	c1 e8 0c             	shr    $0xc,%eax
  8012d9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012e0:	f6 c2 01             	test   $0x1,%dl
  8012e3:	75 36                	jne    80131b <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012e5:	89 f8                	mov    %edi,%eax
  8012e7:	c1 e8 0c             	shr    $0xc,%eax
  8012ea:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012f1:	83 ec 0c             	sub    $0xc,%esp
  8012f4:	25 07 0e 00 00       	and    $0xe07,%eax
  8012f9:	50                   	push   %eax
  8012fa:	56                   	push   %esi
  8012fb:	6a 00                	push   $0x0
  8012fd:	57                   	push   %edi
  8012fe:	6a 00                	push   $0x0
  801300:	e8 ec f8 ff ff       	call   800bf1 <sys_page_map>
  801305:	89 c3                	mov    %eax,%ebx
  801307:	83 c4 20             	add    $0x20,%esp
  80130a:	85 c0                	test   %eax,%eax
  80130c:	78 33                	js     801341 <dup+0xcd>
		goto err;

	return newfdnum;
  80130e:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801311:	89 d8                	mov    %ebx,%eax
  801313:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801316:	5b                   	pop    %ebx
  801317:	5e                   	pop    %esi
  801318:	5f                   	pop    %edi
  801319:	5d                   	pop    %ebp
  80131a:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80131b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801322:	83 ec 0c             	sub    $0xc,%esp
  801325:	25 07 0e 00 00       	and    $0xe07,%eax
  80132a:	50                   	push   %eax
  80132b:	ff 75 d4             	push   -0x2c(%ebp)
  80132e:	6a 00                	push   $0x0
  801330:	53                   	push   %ebx
  801331:	6a 00                	push   $0x0
  801333:	e8 b9 f8 ff ff       	call   800bf1 <sys_page_map>
  801338:	89 c3                	mov    %eax,%ebx
  80133a:	83 c4 20             	add    $0x20,%esp
  80133d:	85 c0                	test   %eax,%eax
  80133f:	79 a4                	jns    8012e5 <dup+0x71>
	sys_page_unmap(0, newfd);
  801341:	83 ec 08             	sub    $0x8,%esp
  801344:	56                   	push   %esi
  801345:	6a 00                	push   $0x0
  801347:	e8 e7 f8 ff ff       	call   800c33 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80134c:	83 c4 08             	add    $0x8,%esp
  80134f:	ff 75 d4             	push   -0x2c(%ebp)
  801352:	6a 00                	push   $0x0
  801354:	e8 da f8 ff ff       	call   800c33 <sys_page_unmap>
	return r;
  801359:	83 c4 10             	add    $0x10,%esp
  80135c:	eb b3                	jmp    801311 <dup+0x9d>

0080135e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	56                   	push   %esi
  801362:	53                   	push   %ebx
  801363:	83 ec 18             	sub    $0x18,%esp
  801366:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801369:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80136c:	50                   	push   %eax
  80136d:	56                   	push   %esi
  80136e:	e8 82 fd ff ff       	call   8010f5 <fd_lookup>
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	85 c0                	test   %eax,%eax
  801378:	78 3c                	js     8013b6 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80137a:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80137d:	83 ec 08             	sub    $0x8,%esp
  801380:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801383:	50                   	push   %eax
  801384:	ff 33                	push   (%ebx)
  801386:	e8 ba fd ff ff       	call   801145 <dev_lookup>
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	85 c0                	test   %eax,%eax
  801390:	78 24                	js     8013b6 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801392:	8b 43 08             	mov    0x8(%ebx),%eax
  801395:	83 e0 03             	and    $0x3,%eax
  801398:	83 f8 01             	cmp    $0x1,%eax
  80139b:	74 20                	je     8013bd <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80139d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013a0:	8b 40 08             	mov    0x8(%eax),%eax
  8013a3:	85 c0                	test   %eax,%eax
  8013a5:	74 37                	je     8013de <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013a7:	83 ec 04             	sub    $0x4,%esp
  8013aa:	ff 75 10             	push   0x10(%ebp)
  8013ad:	ff 75 0c             	push   0xc(%ebp)
  8013b0:	53                   	push   %ebx
  8013b1:	ff d0                	call   *%eax
  8013b3:	83 c4 10             	add    $0x10,%esp
}
  8013b6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013b9:	5b                   	pop    %ebx
  8013ba:	5e                   	pop    %esi
  8013bb:	5d                   	pop    %ebp
  8013bc:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013bd:	a1 00 40 80 00       	mov    0x804000,%eax
  8013c2:	8b 40 48             	mov    0x48(%eax),%eax
  8013c5:	83 ec 04             	sub    $0x4,%esp
  8013c8:	56                   	push   %esi
  8013c9:	50                   	push   %eax
  8013ca:	68 39 2a 80 00       	push   $0x802a39
  8013cf:	e8 04 ee ff ff       	call   8001d8 <cprintf>
		return -E_INVAL;
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013dc:	eb d8                	jmp    8013b6 <read+0x58>
		return -E_NOT_SUPP;
  8013de:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013e3:	eb d1                	jmp    8013b6 <read+0x58>

008013e5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	57                   	push   %edi
  8013e9:	56                   	push   %esi
  8013ea:	53                   	push   %ebx
  8013eb:	83 ec 0c             	sub    $0xc,%esp
  8013ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013f1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013f9:	eb 02                	jmp    8013fd <readn+0x18>
  8013fb:	01 c3                	add    %eax,%ebx
  8013fd:	39 f3                	cmp    %esi,%ebx
  8013ff:	73 21                	jae    801422 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801401:	83 ec 04             	sub    $0x4,%esp
  801404:	89 f0                	mov    %esi,%eax
  801406:	29 d8                	sub    %ebx,%eax
  801408:	50                   	push   %eax
  801409:	89 d8                	mov    %ebx,%eax
  80140b:	03 45 0c             	add    0xc(%ebp),%eax
  80140e:	50                   	push   %eax
  80140f:	57                   	push   %edi
  801410:	e8 49 ff ff ff       	call   80135e <read>
		if (m < 0)
  801415:	83 c4 10             	add    $0x10,%esp
  801418:	85 c0                	test   %eax,%eax
  80141a:	78 04                	js     801420 <readn+0x3b>
			return m;
		if (m == 0)
  80141c:	75 dd                	jne    8013fb <readn+0x16>
  80141e:	eb 02                	jmp    801422 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801420:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801422:	89 d8                	mov    %ebx,%eax
  801424:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801427:	5b                   	pop    %ebx
  801428:	5e                   	pop    %esi
  801429:	5f                   	pop    %edi
  80142a:	5d                   	pop    %ebp
  80142b:	c3                   	ret    

0080142c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80142c:	55                   	push   %ebp
  80142d:	89 e5                	mov    %esp,%ebp
  80142f:	56                   	push   %esi
  801430:	53                   	push   %ebx
  801431:	83 ec 18             	sub    $0x18,%esp
  801434:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801437:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80143a:	50                   	push   %eax
  80143b:	53                   	push   %ebx
  80143c:	e8 b4 fc ff ff       	call   8010f5 <fd_lookup>
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	85 c0                	test   %eax,%eax
  801446:	78 37                	js     80147f <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801448:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801451:	50                   	push   %eax
  801452:	ff 36                	push   (%esi)
  801454:	e8 ec fc ff ff       	call   801145 <dev_lookup>
  801459:	83 c4 10             	add    $0x10,%esp
  80145c:	85 c0                	test   %eax,%eax
  80145e:	78 1f                	js     80147f <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801460:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801464:	74 20                	je     801486 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801466:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801469:	8b 40 0c             	mov    0xc(%eax),%eax
  80146c:	85 c0                	test   %eax,%eax
  80146e:	74 37                	je     8014a7 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801470:	83 ec 04             	sub    $0x4,%esp
  801473:	ff 75 10             	push   0x10(%ebp)
  801476:	ff 75 0c             	push   0xc(%ebp)
  801479:	56                   	push   %esi
  80147a:	ff d0                	call   *%eax
  80147c:	83 c4 10             	add    $0x10,%esp
}
  80147f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801482:	5b                   	pop    %ebx
  801483:	5e                   	pop    %esi
  801484:	5d                   	pop    %ebp
  801485:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801486:	a1 00 40 80 00       	mov    0x804000,%eax
  80148b:	8b 40 48             	mov    0x48(%eax),%eax
  80148e:	83 ec 04             	sub    $0x4,%esp
  801491:	53                   	push   %ebx
  801492:	50                   	push   %eax
  801493:	68 55 2a 80 00       	push   $0x802a55
  801498:	e8 3b ed ff ff       	call   8001d8 <cprintf>
		return -E_INVAL;
  80149d:	83 c4 10             	add    $0x10,%esp
  8014a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a5:	eb d8                	jmp    80147f <write+0x53>
		return -E_NOT_SUPP;
  8014a7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014ac:	eb d1                	jmp    80147f <write+0x53>

008014ae <seek>:

int
seek(int fdnum, off_t offset)
{
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b7:	50                   	push   %eax
  8014b8:	ff 75 08             	push   0x8(%ebp)
  8014bb:	e8 35 fc ff ff       	call   8010f5 <fd_lookup>
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	78 0e                	js     8014d5 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d5:	c9                   	leave  
  8014d6:	c3                   	ret    

008014d7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014d7:	55                   	push   %ebp
  8014d8:	89 e5                	mov    %esp,%ebp
  8014da:	56                   	push   %esi
  8014db:	53                   	push   %ebx
  8014dc:	83 ec 18             	sub    $0x18,%esp
  8014df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e5:	50                   	push   %eax
  8014e6:	53                   	push   %ebx
  8014e7:	e8 09 fc ff ff       	call   8010f5 <fd_lookup>
  8014ec:	83 c4 10             	add    $0x10,%esp
  8014ef:	85 c0                	test   %eax,%eax
  8014f1:	78 34                	js     801527 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f3:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8014f6:	83 ec 08             	sub    $0x8,%esp
  8014f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fc:	50                   	push   %eax
  8014fd:	ff 36                	push   (%esi)
  8014ff:	e8 41 fc ff ff       	call   801145 <dev_lookup>
  801504:	83 c4 10             	add    $0x10,%esp
  801507:	85 c0                	test   %eax,%eax
  801509:	78 1c                	js     801527 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80150b:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80150f:	74 1d                	je     80152e <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801511:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801514:	8b 40 18             	mov    0x18(%eax),%eax
  801517:	85 c0                	test   %eax,%eax
  801519:	74 34                	je     80154f <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80151b:	83 ec 08             	sub    $0x8,%esp
  80151e:	ff 75 0c             	push   0xc(%ebp)
  801521:	56                   	push   %esi
  801522:	ff d0                	call   *%eax
  801524:	83 c4 10             	add    $0x10,%esp
}
  801527:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80152a:	5b                   	pop    %ebx
  80152b:	5e                   	pop    %esi
  80152c:	5d                   	pop    %ebp
  80152d:	c3                   	ret    
			thisenv->env_id, fdnum);
  80152e:	a1 00 40 80 00       	mov    0x804000,%eax
  801533:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801536:	83 ec 04             	sub    $0x4,%esp
  801539:	53                   	push   %ebx
  80153a:	50                   	push   %eax
  80153b:	68 18 2a 80 00       	push   $0x802a18
  801540:	e8 93 ec ff ff       	call   8001d8 <cprintf>
		return -E_INVAL;
  801545:	83 c4 10             	add    $0x10,%esp
  801548:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80154d:	eb d8                	jmp    801527 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80154f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801554:	eb d1                	jmp    801527 <ftruncate+0x50>

00801556 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	56                   	push   %esi
  80155a:	53                   	push   %ebx
  80155b:	83 ec 18             	sub    $0x18,%esp
  80155e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801561:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801564:	50                   	push   %eax
  801565:	ff 75 08             	push   0x8(%ebp)
  801568:	e8 88 fb ff ff       	call   8010f5 <fd_lookup>
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	85 c0                	test   %eax,%eax
  801572:	78 49                	js     8015bd <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801574:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801577:	83 ec 08             	sub    $0x8,%esp
  80157a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157d:	50                   	push   %eax
  80157e:	ff 36                	push   (%esi)
  801580:	e8 c0 fb ff ff       	call   801145 <dev_lookup>
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	85 c0                	test   %eax,%eax
  80158a:	78 31                	js     8015bd <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80158c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80158f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801593:	74 2f                	je     8015c4 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801595:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801598:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80159f:	00 00 00 
	stat->st_isdir = 0;
  8015a2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015a9:	00 00 00 
	stat->st_dev = dev;
  8015ac:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015b2:	83 ec 08             	sub    $0x8,%esp
  8015b5:	53                   	push   %ebx
  8015b6:	56                   	push   %esi
  8015b7:	ff 50 14             	call   *0x14(%eax)
  8015ba:	83 c4 10             	add    $0x10,%esp
}
  8015bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c0:	5b                   	pop    %ebx
  8015c1:	5e                   	pop    %esi
  8015c2:	5d                   	pop    %ebp
  8015c3:	c3                   	ret    
		return -E_NOT_SUPP;
  8015c4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015c9:	eb f2                	jmp    8015bd <fstat+0x67>

008015cb <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015cb:	55                   	push   %ebp
  8015cc:	89 e5                	mov    %esp,%ebp
  8015ce:	56                   	push   %esi
  8015cf:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015d0:	83 ec 08             	sub    $0x8,%esp
  8015d3:	6a 00                	push   $0x0
  8015d5:	ff 75 08             	push   0x8(%ebp)
  8015d8:	e8 e4 01 00 00       	call   8017c1 <open>
  8015dd:	89 c3                	mov    %eax,%ebx
  8015df:	83 c4 10             	add    $0x10,%esp
  8015e2:	85 c0                	test   %eax,%eax
  8015e4:	78 1b                	js     801601 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	ff 75 0c             	push   0xc(%ebp)
  8015ec:	50                   	push   %eax
  8015ed:	e8 64 ff ff ff       	call   801556 <fstat>
  8015f2:	89 c6                	mov    %eax,%esi
	close(fd);
  8015f4:	89 1c 24             	mov    %ebx,(%esp)
  8015f7:	e8 26 fc ff ff       	call   801222 <close>
	return r;
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	89 f3                	mov    %esi,%ebx
}
  801601:	89 d8                	mov    %ebx,%eax
  801603:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801606:	5b                   	pop    %ebx
  801607:	5e                   	pop    %esi
  801608:	5d                   	pop    %ebp
  801609:	c3                   	ret    

0080160a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	56                   	push   %esi
  80160e:	53                   	push   %ebx
  80160f:	89 c6                	mov    %eax,%esi
  801611:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801613:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80161a:	74 27                	je     801643 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80161c:	6a 07                	push   $0x7
  80161e:	68 00 50 80 00       	push   $0x805000
  801623:	56                   	push   %esi
  801624:	ff 35 00 60 80 00    	push   0x806000
  80162a:	e8 a6 0c 00 00       	call   8022d5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80162f:	83 c4 0c             	add    $0xc,%esp
  801632:	6a 00                	push   $0x0
  801634:	53                   	push   %ebx
  801635:	6a 00                	push   $0x0
  801637:	e8 32 0c 00 00       	call   80226e <ipc_recv>
}
  80163c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80163f:	5b                   	pop    %ebx
  801640:	5e                   	pop    %esi
  801641:	5d                   	pop    %ebp
  801642:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801643:	83 ec 0c             	sub    $0xc,%esp
  801646:	6a 01                	push   $0x1
  801648:	e8 dc 0c 00 00       	call   802329 <ipc_find_env>
  80164d:	a3 00 60 80 00       	mov    %eax,0x806000
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	eb c5                	jmp    80161c <fsipc+0x12>

00801657 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801657:	55                   	push   %ebp
  801658:	89 e5                	mov    %esp,%ebp
  80165a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80165d:	8b 45 08             	mov    0x8(%ebp),%eax
  801660:	8b 40 0c             	mov    0xc(%eax),%eax
  801663:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801668:	8b 45 0c             	mov    0xc(%ebp),%eax
  80166b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801670:	ba 00 00 00 00       	mov    $0x0,%edx
  801675:	b8 02 00 00 00       	mov    $0x2,%eax
  80167a:	e8 8b ff ff ff       	call   80160a <fsipc>
}
  80167f:	c9                   	leave  
  801680:	c3                   	ret    

00801681 <devfile_flush>:
{
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801687:	8b 45 08             	mov    0x8(%ebp),%eax
  80168a:	8b 40 0c             	mov    0xc(%eax),%eax
  80168d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801692:	ba 00 00 00 00       	mov    $0x0,%edx
  801697:	b8 06 00 00 00       	mov    $0x6,%eax
  80169c:	e8 69 ff ff ff       	call   80160a <fsipc>
}
  8016a1:	c9                   	leave  
  8016a2:	c3                   	ret    

008016a3 <devfile_stat>:
{
  8016a3:	55                   	push   %ebp
  8016a4:	89 e5                	mov    %esp,%ebp
  8016a6:	53                   	push   %ebx
  8016a7:	83 ec 04             	sub    $0x4,%esp
  8016aa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8016b3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016bd:	b8 05 00 00 00       	mov    $0x5,%eax
  8016c2:	e8 43 ff ff ff       	call   80160a <fsipc>
  8016c7:	85 c0                	test   %eax,%eax
  8016c9:	78 2c                	js     8016f7 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016cb:	83 ec 08             	sub    $0x8,%esp
  8016ce:	68 00 50 80 00       	push   $0x805000
  8016d3:	53                   	push   %ebx
  8016d4:	e8 d9 f0 ff ff       	call   8007b2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016d9:	a1 80 50 80 00       	mov    0x805080,%eax
  8016de:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016e4:	a1 84 50 80 00       	mov    0x805084,%eax
  8016e9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016ef:	83 c4 10             	add    $0x10,%esp
  8016f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016fa:	c9                   	leave  
  8016fb:	c3                   	ret    

008016fc <devfile_write>:
{
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	83 ec 0c             	sub    $0xc,%esp
  801702:	8b 45 10             	mov    0x10(%ebp),%eax
  801705:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80170a:	39 d0                	cmp    %edx,%eax
  80170c:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80170f:	8b 55 08             	mov    0x8(%ebp),%edx
  801712:	8b 52 0c             	mov    0xc(%edx),%edx
  801715:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80171b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801720:	50                   	push   %eax
  801721:	ff 75 0c             	push   0xc(%ebp)
  801724:	68 08 50 80 00       	push   $0x805008
  801729:	e8 1a f2 ff ff       	call   800948 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  80172e:	ba 00 00 00 00       	mov    $0x0,%edx
  801733:	b8 04 00 00 00       	mov    $0x4,%eax
  801738:	e8 cd fe ff ff       	call   80160a <fsipc>
}
  80173d:	c9                   	leave  
  80173e:	c3                   	ret    

0080173f <devfile_read>:
{
  80173f:	55                   	push   %ebp
  801740:	89 e5                	mov    %esp,%ebp
  801742:	56                   	push   %esi
  801743:	53                   	push   %ebx
  801744:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801747:	8b 45 08             	mov    0x8(%ebp),%eax
  80174a:	8b 40 0c             	mov    0xc(%eax),%eax
  80174d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801752:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801758:	ba 00 00 00 00       	mov    $0x0,%edx
  80175d:	b8 03 00 00 00       	mov    $0x3,%eax
  801762:	e8 a3 fe ff ff       	call   80160a <fsipc>
  801767:	89 c3                	mov    %eax,%ebx
  801769:	85 c0                	test   %eax,%eax
  80176b:	78 1f                	js     80178c <devfile_read+0x4d>
	assert(r <= n);
  80176d:	39 f0                	cmp    %esi,%eax
  80176f:	77 24                	ja     801795 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801771:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801776:	7f 33                	jg     8017ab <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801778:	83 ec 04             	sub    $0x4,%esp
  80177b:	50                   	push   %eax
  80177c:	68 00 50 80 00       	push   $0x805000
  801781:	ff 75 0c             	push   0xc(%ebp)
  801784:	e8 bf f1 ff ff       	call   800948 <memmove>
	return r;
  801789:	83 c4 10             	add    $0x10,%esp
}
  80178c:	89 d8                	mov    %ebx,%eax
  80178e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801791:	5b                   	pop    %ebx
  801792:	5e                   	pop    %esi
  801793:	5d                   	pop    %ebp
  801794:	c3                   	ret    
	assert(r <= n);
  801795:	68 88 2a 80 00       	push   $0x802a88
  80179a:	68 8f 2a 80 00       	push   $0x802a8f
  80179f:	6a 7c                	push   $0x7c
  8017a1:	68 a4 2a 80 00       	push   $0x802aa4
  8017a6:	e8 e1 09 00 00       	call   80218c <_panic>
	assert(r <= PGSIZE);
  8017ab:	68 af 2a 80 00       	push   $0x802aaf
  8017b0:	68 8f 2a 80 00       	push   $0x802a8f
  8017b5:	6a 7d                	push   $0x7d
  8017b7:	68 a4 2a 80 00       	push   $0x802aa4
  8017bc:	e8 cb 09 00 00       	call   80218c <_panic>

008017c1 <open>:
{
  8017c1:	55                   	push   %ebp
  8017c2:	89 e5                	mov    %esp,%ebp
  8017c4:	56                   	push   %esi
  8017c5:	53                   	push   %ebx
  8017c6:	83 ec 1c             	sub    $0x1c,%esp
  8017c9:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8017cc:	56                   	push   %esi
  8017cd:	e8 a5 ef ff ff       	call   800777 <strlen>
  8017d2:	83 c4 10             	add    $0x10,%esp
  8017d5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017da:	7f 6c                	jg     801848 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  8017dc:	83 ec 0c             	sub    $0xc,%esp
  8017df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e2:	50                   	push   %eax
  8017e3:	e8 bd f8 ff ff       	call   8010a5 <fd_alloc>
  8017e8:	89 c3                	mov    %eax,%ebx
  8017ea:	83 c4 10             	add    $0x10,%esp
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	78 3c                	js     80182d <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8017f1:	83 ec 08             	sub    $0x8,%esp
  8017f4:	56                   	push   %esi
  8017f5:	68 00 50 80 00       	push   $0x805000
  8017fa:	e8 b3 ef ff ff       	call   8007b2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  801802:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801807:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80180a:	b8 01 00 00 00       	mov    $0x1,%eax
  80180f:	e8 f6 fd ff ff       	call   80160a <fsipc>
  801814:	89 c3                	mov    %eax,%ebx
  801816:	83 c4 10             	add    $0x10,%esp
  801819:	85 c0                	test   %eax,%eax
  80181b:	78 19                	js     801836 <open+0x75>
	return fd2num(fd);
  80181d:	83 ec 0c             	sub    $0xc,%esp
  801820:	ff 75 f4             	push   -0xc(%ebp)
  801823:	e8 56 f8 ff ff       	call   80107e <fd2num>
  801828:	89 c3                	mov    %eax,%ebx
  80182a:	83 c4 10             	add    $0x10,%esp
}
  80182d:	89 d8                	mov    %ebx,%eax
  80182f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801832:	5b                   	pop    %ebx
  801833:	5e                   	pop    %esi
  801834:	5d                   	pop    %ebp
  801835:	c3                   	ret    
		fd_close(fd, 0);
  801836:	83 ec 08             	sub    $0x8,%esp
  801839:	6a 00                	push   $0x0
  80183b:	ff 75 f4             	push   -0xc(%ebp)
  80183e:	e8 58 f9 ff ff       	call   80119b <fd_close>
		return r;
  801843:	83 c4 10             	add    $0x10,%esp
  801846:	eb e5                	jmp    80182d <open+0x6c>
		return -E_BAD_PATH;
  801848:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  80184d:	eb de                	jmp    80182d <open+0x6c>

0080184f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80184f:	55                   	push   %ebp
  801850:	89 e5                	mov    %esp,%ebp
  801852:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801855:	ba 00 00 00 00       	mov    $0x0,%edx
  80185a:	b8 08 00 00 00       	mov    $0x8,%eax
  80185f:	e8 a6 fd ff ff       	call   80160a <fsipc>
}
  801864:	c9                   	leave  
  801865:	c3                   	ret    

00801866 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801866:	55                   	push   %ebp
  801867:	89 e5                	mov    %esp,%ebp
  801869:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80186c:	68 bb 2a 80 00       	push   $0x802abb
  801871:	ff 75 0c             	push   0xc(%ebp)
  801874:	e8 39 ef ff ff       	call   8007b2 <strcpy>
	return 0;
}
  801879:	b8 00 00 00 00       	mov    $0x0,%eax
  80187e:	c9                   	leave  
  80187f:	c3                   	ret    

00801880 <devsock_close>:
{
  801880:	55                   	push   %ebp
  801881:	89 e5                	mov    %esp,%ebp
  801883:	53                   	push   %ebx
  801884:	83 ec 10             	sub    $0x10,%esp
  801887:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80188a:	53                   	push   %ebx
  80188b:	e8 d2 0a 00 00       	call   802362 <pageref>
  801890:	89 c2                	mov    %eax,%edx
  801892:	83 c4 10             	add    $0x10,%esp
		return 0;
  801895:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  80189a:	83 fa 01             	cmp    $0x1,%edx
  80189d:	74 05                	je     8018a4 <devsock_close+0x24>
}
  80189f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018a2:	c9                   	leave  
  8018a3:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  8018a4:	83 ec 0c             	sub    $0xc,%esp
  8018a7:	ff 73 0c             	push   0xc(%ebx)
  8018aa:	e8 b7 02 00 00       	call   801b66 <nsipc_close>
  8018af:	83 c4 10             	add    $0x10,%esp
  8018b2:	eb eb                	jmp    80189f <devsock_close+0x1f>

008018b4 <devsock_write>:
{
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8018ba:	6a 00                	push   $0x0
  8018bc:	ff 75 10             	push   0x10(%ebp)
  8018bf:	ff 75 0c             	push   0xc(%ebp)
  8018c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c5:	ff 70 0c             	push   0xc(%eax)
  8018c8:	e8 79 03 00 00       	call   801c46 <nsipc_send>
}
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <devsock_read>:
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018d5:	6a 00                	push   $0x0
  8018d7:	ff 75 10             	push   0x10(%ebp)
  8018da:	ff 75 0c             	push   0xc(%ebp)
  8018dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e0:	ff 70 0c             	push   0xc(%eax)
  8018e3:	e8 ef 02 00 00       	call   801bd7 <nsipc_recv>
}
  8018e8:	c9                   	leave  
  8018e9:	c3                   	ret    

008018ea <fd2sockid>:
{
  8018ea:	55                   	push   %ebp
  8018eb:	89 e5                	mov    %esp,%ebp
  8018ed:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8018f0:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018f3:	52                   	push   %edx
  8018f4:	50                   	push   %eax
  8018f5:	e8 fb f7 ff ff       	call   8010f5 <fd_lookup>
  8018fa:	83 c4 10             	add    $0x10,%esp
  8018fd:	85 c0                	test   %eax,%eax
  8018ff:	78 10                	js     801911 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  801901:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801904:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80190a:	39 08                	cmp    %ecx,(%eax)
  80190c:	75 05                	jne    801913 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  80190e:	8b 40 0c             	mov    0xc(%eax),%eax
}
  801911:	c9                   	leave  
  801912:	c3                   	ret    
		return -E_NOT_SUPP;
  801913:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801918:	eb f7                	jmp    801911 <fd2sockid+0x27>

0080191a <alloc_sockfd>:
{
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	56                   	push   %esi
  80191e:	53                   	push   %ebx
  80191f:	83 ec 1c             	sub    $0x1c,%esp
  801922:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  801924:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801927:	50                   	push   %eax
  801928:	e8 78 f7 ff ff       	call   8010a5 <fd_alloc>
  80192d:	89 c3                	mov    %eax,%ebx
  80192f:	83 c4 10             	add    $0x10,%esp
  801932:	85 c0                	test   %eax,%eax
  801934:	78 43                	js     801979 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801936:	83 ec 04             	sub    $0x4,%esp
  801939:	68 07 04 00 00       	push   $0x407
  80193e:	ff 75 f4             	push   -0xc(%ebp)
  801941:	6a 00                	push   $0x0
  801943:	e8 66 f2 ff ff       	call   800bae <sys_page_alloc>
  801948:	89 c3                	mov    %eax,%ebx
  80194a:	83 c4 10             	add    $0x10,%esp
  80194d:	85 c0                	test   %eax,%eax
  80194f:	78 28                	js     801979 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801951:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801954:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80195a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80195c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801966:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801969:	83 ec 0c             	sub    $0xc,%esp
  80196c:	50                   	push   %eax
  80196d:	e8 0c f7 ff ff       	call   80107e <fd2num>
  801972:	89 c3                	mov    %eax,%ebx
  801974:	83 c4 10             	add    $0x10,%esp
  801977:	eb 0c                	jmp    801985 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801979:	83 ec 0c             	sub    $0xc,%esp
  80197c:	56                   	push   %esi
  80197d:	e8 e4 01 00 00       	call   801b66 <nsipc_close>
		return r;
  801982:	83 c4 10             	add    $0x10,%esp
}
  801985:	89 d8                	mov    %ebx,%eax
  801987:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80198a:	5b                   	pop    %ebx
  80198b:	5e                   	pop    %esi
  80198c:	5d                   	pop    %ebp
  80198d:	c3                   	ret    

0080198e <accept>:
{
  80198e:	55                   	push   %ebp
  80198f:	89 e5                	mov    %esp,%ebp
  801991:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801994:	8b 45 08             	mov    0x8(%ebp),%eax
  801997:	e8 4e ff ff ff       	call   8018ea <fd2sockid>
  80199c:	85 c0                	test   %eax,%eax
  80199e:	78 1b                	js     8019bb <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019a0:	83 ec 04             	sub    $0x4,%esp
  8019a3:	ff 75 10             	push   0x10(%ebp)
  8019a6:	ff 75 0c             	push   0xc(%ebp)
  8019a9:	50                   	push   %eax
  8019aa:	e8 0e 01 00 00       	call   801abd <nsipc_accept>
  8019af:	83 c4 10             	add    $0x10,%esp
  8019b2:	85 c0                	test   %eax,%eax
  8019b4:	78 05                	js     8019bb <accept+0x2d>
	return alloc_sockfd(r);
  8019b6:	e8 5f ff ff ff       	call   80191a <alloc_sockfd>
}
  8019bb:	c9                   	leave  
  8019bc:	c3                   	ret    

008019bd <bind>:
{
  8019bd:	55                   	push   %ebp
  8019be:	89 e5                	mov    %esp,%ebp
  8019c0:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c6:	e8 1f ff ff ff       	call   8018ea <fd2sockid>
  8019cb:	85 c0                	test   %eax,%eax
  8019cd:	78 12                	js     8019e1 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  8019cf:	83 ec 04             	sub    $0x4,%esp
  8019d2:	ff 75 10             	push   0x10(%ebp)
  8019d5:	ff 75 0c             	push   0xc(%ebp)
  8019d8:	50                   	push   %eax
  8019d9:	e8 31 01 00 00       	call   801b0f <nsipc_bind>
  8019de:	83 c4 10             	add    $0x10,%esp
}
  8019e1:	c9                   	leave  
  8019e2:	c3                   	ret    

008019e3 <shutdown>:
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8019e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ec:	e8 f9 fe ff ff       	call   8018ea <fd2sockid>
  8019f1:	85 c0                	test   %eax,%eax
  8019f3:	78 0f                	js     801a04 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  8019f5:	83 ec 08             	sub    $0x8,%esp
  8019f8:	ff 75 0c             	push   0xc(%ebp)
  8019fb:	50                   	push   %eax
  8019fc:	e8 43 01 00 00       	call   801b44 <nsipc_shutdown>
  801a01:	83 c4 10             	add    $0x10,%esp
}
  801a04:	c9                   	leave  
  801a05:	c3                   	ret    

00801a06 <connect>:
{
  801a06:	55                   	push   %ebp
  801a07:	89 e5                	mov    %esp,%ebp
  801a09:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a0f:	e8 d6 fe ff ff       	call   8018ea <fd2sockid>
  801a14:	85 c0                	test   %eax,%eax
  801a16:	78 12                	js     801a2a <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801a18:	83 ec 04             	sub    $0x4,%esp
  801a1b:	ff 75 10             	push   0x10(%ebp)
  801a1e:	ff 75 0c             	push   0xc(%ebp)
  801a21:	50                   	push   %eax
  801a22:	e8 59 01 00 00       	call   801b80 <nsipc_connect>
  801a27:	83 c4 10             	add    $0x10,%esp
}
  801a2a:	c9                   	leave  
  801a2b:	c3                   	ret    

00801a2c <listen>:
{
  801a2c:	55                   	push   %ebp
  801a2d:	89 e5                	mov    %esp,%ebp
  801a2f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a32:	8b 45 08             	mov    0x8(%ebp),%eax
  801a35:	e8 b0 fe ff ff       	call   8018ea <fd2sockid>
  801a3a:	85 c0                	test   %eax,%eax
  801a3c:	78 0f                	js     801a4d <listen+0x21>
	return nsipc_listen(r, backlog);
  801a3e:	83 ec 08             	sub    $0x8,%esp
  801a41:	ff 75 0c             	push   0xc(%ebp)
  801a44:	50                   	push   %eax
  801a45:	e8 6b 01 00 00       	call   801bb5 <nsipc_listen>
  801a4a:	83 c4 10             	add    $0x10,%esp
}
  801a4d:	c9                   	leave  
  801a4e:	c3                   	ret    

00801a4f <socket>:

int
socket(int domain, int type, int protocol)
{
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a55:	ff 75 10             	push   0x10(%ebp)
  801a58:	ff 75 0c             	push   0xc(%ebp)
  801a5b:	ff 75 08             	push   0x8(%ebp)
  801a5e:	e8 41 02 00 00       	call   801ca4 <nsipc_socket>
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	85 c0                	test   %eax,%eax
  801a68:	78 05                	js     801a6f <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a6a:	e8 ab fe ff ff       	call   80191a <alloc_sockfd>
}
  801a6f:	c9                   	leave  
  801a70:	c3                   	ret    

00801a71 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	53                   	push   %ebx
  801a75:	83 ec 04             	sub    $0x4,%esp
  801a78:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801a7a:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801a81:	74 26                	je     801aa9 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801a83:	6a 07                	push   $0x7
  801a85:	68 00 70 80 00       	push   $0x807000
  801a8a:	53                   	push   %ebx
  801a8b:	ff 35 00 80 80 00    	push   0x808000
  801a91:	e8 3f 08 00 00       	call   8022d5 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801a96:	83 c4 0c             	add    $0xc,%esp
  801a99:	6a 00                	push   $0x0
  801a9b:	6a 00                	push   $0x0
  801a9d:	6a 00                	push   $0x0
  801a9f:	e8 ca 07 00 00       	call   80226e <ipc_recv>
}
  801aa4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aa7:	c9                   	leave  
  801aa8:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801aa9:	83 ec 0c             	sub    $0xc,%esp
  801aac:	6a 02                	push   $0x2
  801aae:	e8 76 08 00 00       	call   802329 <ipc_find_env>
  801ab3:	a3 00 80 80 00       	mov    %eax,0x808000
  801ab8:	83 c4 10             	add    $0x10,%esp
  801abb:	eb c6                	jmp    801a83 <nsipc+0x12>

00801abd <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	56                   	push   %esi
  801ac1:	53                   	push   %ebx
  801ac2:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801acd:	8b 06                	mov    (%esi),%eax
  801acf:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ad4:	b8 01 00 00 00       	mov    $0x1,%eax
  801ad9:	e8 93 ff ff ff       	call   801a71 <nsipc>
  801ade:	89 c3                	mov    %eax,%ebx
  801ae0:	85 c0                	test   %eax,%eax
  801ae2:	79 09                	jns    801aed <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801ae4:	89 d8                	mov    %ebx,%eax
  801ae6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae9:	5b                   	pop    %ebx
  801aea:	5e                   	pop    %esi
  801aeb:	5d                   	pop    %ebp
  801aec:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801aed:	83 ec 04             	sub    $0x4,%esp
  801af0:	ff 35 10 70 80 00    	push   0x807010
  801af6:	68 00 70 80 00       	push   $0x807000
  801afb:	ff 75 0c             	push   0xc(%ebp)
  801afe:	e8 45 ee ff ff       	call   800948 <memmove>
		*addrlen = ret->ret_addrlen;
  801b03:	a1 10 70 80 00       	mov    0x807010,%eax
  801b08:	89 06                	mov    %eax,(%esi)
  801b0a:	83 c4 10             	add    $0x10,%esp
	return r;
  801b0d:	eb d5                	jmp    801ae4 <nsipc_accept+0x27>

00801b0f <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	53                   	push   %ebx
  801b13:	83 ec 08             	sub    $0x8,%esp
  801b16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b19:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1c:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b21:	53                   	push   %ebx
  801b22:	ff 75 0c             	push   0xc(%ebp)
  801b25:	68 04 70 80 00       	push   $0x807004
  801b2a:	e8 19 ee ff ff       	call   800948 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b2f:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801b35:	b8 02 00 00 00       	mov    $0x2,%eax
  801b3a:	e8 32 ff ff ff       	call   801a71 <nsipc>
}
  801b3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b42:	c9                   	leave  
  801b43:	c3                   	ret    

00801b44 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b4a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b4d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801b52:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b55:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801b5a:	b8 03 00 00 00       	mov    $0x3,%eax
  801b5f:	e8 0d ff ff ff       	call   801a71 <nsipc>
}
  801b64:	c9                   	leave  
  801b65:	c3                   	ret    

00801b66 <nsipc_close>:

int
nsipc_close(int s)
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b6c:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6f:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801b74:	b8 04 00 00 00       	mov    $0x4,%eax
  801b79:	e8 f3 fe ff ff       	call   801a71 <nsipc>
}
  801b7e:	c9                   	leave  
  801b7f:	c3                   	ret    

00801b80 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b80:	55                   	push   %ebp
  801b81:	89 e5                	mov    %esp,%ebp
  801b83:	53                   	push   %ebx
  801b84:	83 ec 08             	sub    $0x8,%esp
  801b87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b8d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801b92:	53                   	push   %ebx
  801b93:	ff 75 0c             	push   0xc(%ebp)
  801b96:	68 04 70 80 00       	push   $0x807004
  801b9b:	e8 a8 ed ff ff       	call   800948 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ba0:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801ba6:	b8 05 00 00 00       	mov    $0x5,%eax
  801bab:	e8 c1 fe ff ff       	call   801a71 <nsipc>
}
  801bb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb3:	c9                   	leave  
  801bb4:	c3                   	ret    

00801bb5 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801bb5:	55                   	push   %ebp
  801bb6:	89 e5                	mov    %esp,%ebp
  801bb8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbe:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801bc3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bc6:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801bcb:	b8 06 00 00 00       	mov    $0x6,%eax
  801bd0:	e8 9c fe ff ff       	call   801a71 <nsipc>
}
  801bd5:	c9                   	leave  
  801bd6:	c3                   	ret    

00801bd7 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801bd7:	55                   	push   %ebp
  801bd8:	89 e5                	mov    %esp,%ebp
  801bda:	56                   	push   %esi
  801bdb:	53                   	push   %ebx
  801bdc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801be2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801be7:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801bed:	8b 45 14             	mov    0x14(%ebp),%eax
  801bf0:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801bf5:	b8 07 00 00 00       	mov    $0x7,%eax
  801bfa:	e8 72 fe ff ff       	call   801a71 <nsipc>
  801bff:	89 c3                	mov    %eax,%ebx
  801c01:	85 c0                	test   %eax,%eax
  801c03:	78 22                	js     801c27 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801c05:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801c0a:	39 c6                	cmp    %eax,%esi
  801c0c:	0f 4e c6             	cmovle %esi,%eax
  801c0f:	39 c3                	cmp    %eax,%ebx
  801c11:	7f 1d                	jg     801c30 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c13:	83 ec 04             	sub    $0x4,%esp
  801c16:	53                   	push   %ebx
  801c17:	68 00 70 80 00       	push   $0x807000
  801c1c:	ff 75 0c             	push   0xc(%ebp)
  801c1f:	e8 24 ed ff ff       	call   800948 <memmove>
  801c24:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c27:	89 d8                	mov    %ebx,%eax
  801c29:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c2c:	5b                   	pop    %ebx
  801c2d:	5e                   	pop    %esi
  801c2e:	5d                   	pop    %ebp
  801c2f:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801c30:	68 c7 2a 80 00       	push   $0x802ac7
  801c35:	68 8f 2a 80 00       	push   $0x802a8f
  801c3a:	6a 62                	push   $0x62
  801c3c:	68 dc 2a 80 00       	push   $0x802adc
  801c41:	e8 46 05 00 00       	call   80218c <_panic>

00801c46 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c46:	55                   	push   %ebp
  801c47:	89 e5                	mov    %esp,%ebp
  801c49:	53                   	push   %ebx
  801c4a:	83 ec 04             	sub    $0x4,%esp
  801c4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c50:	8b 45 08             	mov    0x8(%ebp),%eax
  801c53:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801c58:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c5e:	7f 2e                	jg     801c8e <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c60:	83 ec 04             	sub    $0x4,%esp
  801c63:	53                   	push   %ebx
  801c64:	ff 75 0c             	push   0xc(%ebp)
  801c67:	68 0c 70 80 00       	push   $0x80700c
  801c6c:	e8 d7 ec ff ff       	call   800948 <memmove>
	nsipcbuf.send.req_size = size;
  801c71:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801c77:	8b 45 14             	mov    0x14(%ebp),%eax
  801c7a:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801c7f:	b8 08 00 00 00       	mov    $0x8,%eax
  801c84:	e8 e8 fd ff ff       	call   801a71 <nsipc>
}
  801c89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c8c:	c9                   	leave  
  801c8d:	c3                   	ret    
	assert(size < 1600);
  801c8e:	68 e8 2a 80 00       	push   $0x802ae8
  801c93:	68 8f 2a 80 00       	push   $0x802a8f
  801c98:	6a 6d                	push   $0x6d
  801c9a:	68 dc 2a 80 00       	push   $0x802adc
  801c9f:	e8 e8 04 00 00       	call   80218c <_panic>

00801ca4 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801ca4:	55                   	push   %ebp
  801ca5:	89 e5                	mov    %esp,%ebp
  801ca7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801caa:	8b 45 08             	mov    0x8(%ebp),%eax
  801cad:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801cb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb5:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801cba:	8b 45 10             	mov    0x10(%ebp),%eax
  801cbd:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801cc2:	b8 09 00 00 00       	mov    $0x9,%eax
  801cc7:	e8 a5 fd ff ff       	call   801a71 <nsipc>
}
  801ccc:	c9                   	leave  
  801ccd:	c3                   	ret    

00801cce <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cce:	55                   	push   %ebp
  801ccf:	89 e5                	mov    %esp,%ebp
  801cd1:	56                   	push   %esi
  801cd2:	53                   	push   %ebx
  801cd3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cd6:	83 ec 0c             	sub    $0xc,%esp
  801cd9:	ff 75 08             	push   0x8(%ebp)
  801cdc:	e8 ad f3 ff ff       	call   80108e <fd2data>
  801ce1:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ce3:	83 c4 08             	add    $0x8,%esp
  801ce6:	68 f4 2a 80 00       	push   $0x802af4
  801ceb:	53                   	push   %ebx
  801cec:	e8 c1 ea ff ff       	call   8007b2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cf1:	8b 46 04             	mov    0x4(%esi),%eax
  801cf4:	2b 06                	sub    (%esi),%eax
  801cf6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cfc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d03:	00 00 00 
	stat->st_dev = &devpipe;
  801d06:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801d0d:	30 80 00 
	return 0;
}
  801d10:	b8 00 00 00 00       	mov    $0x0,%eax
  801d15:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d18:	5b                   	pop    %ebx
  801d19:	5e                   	pop    %esi
  801d1a:	5d                   	pop    %ebp
  801d1b:	c3                   	ret    

00801d1c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	53                   	push   %ebx
  801d20:	83 ec 0c             	sub    $0xc,%esp
  801d23:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d26:	53                   	push   %ebx
  801d27:	6a 00                	push   $0x0
  801d29:	e8 05 ef ff ff       	call   800c33 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d2e:	89 1c 24             	mov    %ebx,(%esp)
  801d31:	e8 58 f3 ff ff       	call   80108e <fd2data>
  801d36:	83 c4 08             	add    $0x8,%esp
  801d39:	50                   	push   %eax
  801d3a:	6a 00                	push   $0x0
  801d3c:	e8 f2 ee ff ff       	call   800c33 <sys_page_unmap>
}
  801d41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d44:	c9                   	leave  
  801d45:	c3                   	ret    

00801d46 <_pipeisclosed>:
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
  801d49:	57                   	push   %edi
  801d4a:	56                   	push   %esi
  801d4b:	53                   	push   %ebx
  801d4c:	83 ec 1c             	sub    $0x1c,%esp
  801d4f:	89 c7                	mov    %eax,%edi
  801d51:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801d53:	a1 00 40 80 00       	mov    0x804000,%eax
  801d58:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d5b:	83 ec 0c             	sub    $0xc,%esp
  801d5e:	57                   	push   %edi
  801d5f:	e8 fe 05 00 00       	call   802362 <pageref>
  801d64:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d67:	89 34 24             	mov    %esi,(%esp)
  801d6a:	e8 f3 05 00 00       	call   802362 <pageref>
		nn = thisenv->env_runs;
  801d6f:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801d75:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d78:	83 c4 10             	add    $0x10,%esp
  801d7b:	39 cb                	cmp    %ecx,%ebx
  801d7d:	74 1b                	je     801d9a <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801d7f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d82:	75 cf                	jne    801d53 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d84:	8b 42 58             	mov    0x58(%edx),%eax
  801d87:	6a 01                	push   $0x1
  801d89:	50                   	push   %eax
  801d8a:	53                   	push   %ebx
  801d8b:	68 fb 2a 80 00       	push   $0x802afb
  801d90:	e8 43 e4 ff ff       	call   8001d8 <cprintf>
  801d95:	83 c4 10             	add    $0x10,%esp
  801d98:	eb b9                	jmp    801d53 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801d9a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d9d:	0f 94 c0             	sete   %al
  801da0:	0f b6 c0             	movzbl %al,%eax
}
  801da3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801da6:	5b                   	pop    %ebx
  801da7:	5e                   	pop    %esi
  801da8:	5f                   	pop    %edi
  801da9:	5d                   	pop    %ebp
  801daa:	c3                   	ret    

00801dab <devpipe_write>:
{
  801dab:	55                   	push   %ebp
  801dac:	89 e5                	mov    %esp,%ebp
  801dae:	57                   	push   %edi
  801daf:	56                   	push   %esi
  801db0:	53                   	push   %ebx
  801db1:	83 ec 28             	sub    $0x28,%esp
  801db4:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801db7:	56                   	push   %esi
  801db8:	e8 d1 f2 ff ff       	call   80108e <fd2data>
  801dbd:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801dbf:	83 c4 10             	add    $0x10,%esp
  801dc2:	bf 00 00 00 00       	mov    $0x0,%edi
  801dc7:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801dca:	75 09                	jne    801dd5 <devpipe_write+0x2a>
	return i;
  801dcc:	89 f8                	mov    %edi,%eax
  801dce:	eb 23                	jmp    801df3 <devpipe_write+0x48>
			sys_yield();
  801dd0:	e8 ba ed ff ff       	call   800b8f <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801dd5:	8b 43 04             	mov    0x4(%ebx),%eax
  801dd8:	8b 0b                	mov    (%ebx),%ecx
  801dda:	8d 51 20             	lea    0x20(%ecx),%edx
  801ddd:	39 d0                	cmp    %edx,%eax
  801ddf:	72 1a                	jb     801dfb <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801de1:	89 da                	mov    %ebx,%edx
  801de3:	89 f0                	mov    %esi,%eax
  801de5:	e8 5c ff ff ff       	call   801d46 <_pipeisclosed>
  801dea:	85 c0                	test   %eax,%eax
  801dec:	74 e2                	je     801dd0 <devpipe_write+0x25>
				return 0;
  801dee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801df3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df6:	5b                   	pop    %ebx
  801df7:	5e                   	pop    %esi
  801df8:	5f                   	pop    %edi
  801df9:	5d                   	pop    %ebp
  801dfa:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801dfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dfe:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e02:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e05:	89 c2                	mov    %eax,%edx
  801e07:	c1 fa 1f             	sar    $0x1f,%edx
  801e0a:	89 d1                	mov    %edx,%ecx
  801e0c:	c1 e9 1b             	shr    $0x1b,%ecx
  801e0f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e12:	83 e2 1f             	and    $0x1f,%edx
  801e15:	29 ca                	sub    %ecx,%edx
  801e17:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e1b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e1f:	83 c0 01             	add    $0x1,%eax
  801e22:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801e25:	83 c7 01             	add    $0x1,%edi
  801e28:	eb 9d                	jmp    801dc7 <devpipe_write+0x1c>

00801e2a <devpipe_read>:
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	57                   	push   %edi
  801e2e:	56                   	push   %esi
  801e2f:	53                   	push   %ebx
  801e30:	83 ec 18             	sub    $0x18,%esp
  801e33:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801e36:	57                   	push   %edi
  801e37:	e8 52 f2 ff ff       	call   80108e <fd2data>
  801e3c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e3e:	83 c4 10             	add    $0x10,%esp
  801e41:	be 00 00 00 00       	mov    $0x0,%esi
  801e46:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e49:	75 13                	jne    801e5e <devpipe_read+0x34>
	return i;
  801e4b:	89 f0                	mov    %esi,%eax
  801e4d:	eb 02                	jmp    801e51 <devpipe_read+0x27>
				return i;
  801e4f:	89 f0                	mov    %esi,%eax
}
  801e51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e54:	5b                   	pop    %ebx
  801e55:	5e                   	pop    %esi
  801e56:	5f                   	pop    %edi
  801e57:	5d                   	pop    %ebp
  801e58:	c3                   	ret    
			sys_yield();
  801e59:	e8 31 ed ff ff       	call   800b8f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801e5e:	8b 03                	mov    (%ebx),%eax
  801e60:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e63:	75 18                	jne    801e7d <devpipe_read+0x53>
			if (i > 0)
  801e65:	85 f6                	test   %esi,%esi
  801e67:	75 e6                	jne    801e4f <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801e69:	89 da                	mov    %ebx,%edx
  801e6b:	89 f8                	mov    %edi,%eax
  801e6d:	e8 d4 fe ff ff       	call   801d46 <_pipeisclosed>
  801e72:	85 c0                	test   %eax,%eax
  801e74:	74 e3                	je     801e59 <devpipe_read+0x2f>
				return 0;
  801e76:	b8 00 00 00 00       	mov    $0x0,%eax
  801e7b:	eb d4                	jmp    801e51 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e7d:	99                   	cltd   
  801e7e:	c1 ea 1b             	shr    $0x1b,%edx
  801e81:	01 d0                	add    %edx,%eax
  801e83:	83 e0 1f             	and    $0x1f,%eax
  801e86:	29 d0                	sub    %edx,%eax
  801e88:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e90:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e93:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e96:	83 c6 01             	add    $0x1,%esi
  801e99:	eb ab                	jmp    801e46 <devpipe_read+0x1c>

00801e9b <pipe>:
{
  801e9b:	55                   	push   %ebp
  801e9c:	89 e5                	mov    %esp,%ebp
  801e9e:	56                   	push   %esi
  801e9f:	53                   	push   %ebx
  801ea0:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ea3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea6:	50                   	push   %eax
  801ea7:	e8 f9 f1 ff ff       	call   8010a5 <fd_alloc>
  801eac:	89 c3                	mov    %eax,%ebx
  801eae:	83 c4 10             	add    $0x10,%esp
  801eb1:	85 c0                	test   %eax,%eax
  801eb3:	0f 88 23 01 00 00    	js     801fdc <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eb9:	83 ec 04             	sub    $0x4,%esp
  801ebc:	68 07 04 00 00       	push   $0x407
  801ec1:	ff 75 f4             	push   -0xc(%ebp)
  801ec4:	6a 00                	push   $0x0
  801ec6:	e8 e3 ec ff ff       	call   800bae <sys_page_alloc>
  801ecb:	89 c3                	mov    %eax,%ebx
  801ecd:	83 c4 10             	add    $0x10,%esp
  801ed0:	85 c0                	test   %eax,%eax
  801ed2:	0f 88 04 01 00 00    	js     801fdc <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801ed8:	83 ec 0c             	sub    $0xc,%esp
  801edb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ede:	50                   	push   %eax
  801edf:	e8 c1 f1 ff ff       	call   8010a5 <fd_alloc>
  801ee4:	89 c3                	mov    %eax,%ebx
  801ee6:	83 c4 10             	add    $0x10,%esp
  801ee9:	85 c0                	test   %eax,%eax
  801eeb:	0f 88 db 00 00 00    	js     801fcc <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ef1:	83 ec 04             	sub    $0x4,%esp
  801ef4:	68 07 04 00 00       	push   $0x407
  801ef9:	ff 75 f0             	push   -0x10(%ebp)
  801efc:	6a 00                	push   $0x0
  801efe:	e8 ab ec ff ff       	call   800bae <sys_page_alloc>
  801f03:	89 c3                	mov    %eax,%ebx
  801f05:	83 c4 10             	add    $0x10,%esp
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	0f 88 bc 00 00 00    	js     801fcc <pipe+0x131>
	va = fd2data(fd0);
  801f10:	83 ec 0c             	sub    $0xc,%esp
  801f13:	ff 75 f4             	push   -0xc(%ebp)
  801f16:	e8 73 f1 ff ff       	call   80108e <fd2data>
  801f1b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f1d:	83 c4 0c             	add    $0xc,%esp
  801f20:	68 07 04 00 00       	push   $0x407
  801f25:	50                   	push   %eax
  801f26:	6a 00                	push   $0x0
  801f28:	e8 81 ec ff ff       	call   800bae <sys_page_alloc>
  801f2d:	89 c3                	mov    %eax,%ebx
  801f2f:	83 c4 10             	add    $0x10,%esp
  801f32:	85 c0                	test   %eax,%eax
  801f34:	0f 88 82 00 00 00    	js     801fbc <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f3a:	83 ec 0c             	sub    $0xc,%esp
  801f3d:	ff 75 f0             	push   -0x10(%ebp)
  801f40:	e8 49 f1 ff ff       	call   80108e <fd2data>
  801f45:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f4c:	50                   	push   %eax
  801f4d:	6a 00                	push   $0x0
  801f4f:	56                   	push   %esi
  801f50:	6a 00                	push   $0x0
  801f52:	e8 9a ec ff ff       	call   800bf1 <sys_page_map>
  801f57:	89 c3                	mov    %eax,%ebx
  801f59:	83 c4 20             	add    $0x20,%esp
  801f5c:	85 c0                	test   %eax,%eax
  801f5e:	78 4e                	js     801fae <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801f60:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801f65:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f68:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801f6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f6d:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801f74:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f77:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801f79:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f7c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f83:	83 ec 0c             	sub    $0xc,%esp
  801f86:	ff 75 f4             	push   -0xc(%ebp)
  801f89:	e8 f0 f0 ff ff       	call   80107e <fd2num>
  801f8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f91:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f93:	83 c4 04             	add    $0x4,%esp
  801f96:	ff 75 f0             	push   -0x10(%ebp)
  801f99:	e8 e0 f0 ff ff       	call   80107e <fd2num>
  801f9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fa1:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801fa4:	83 c4 10             	add    $0x10,%esp
  801fa7:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fac:	eb 2e                	jmp    801fdc <pipe+0x141>
	sys_page_unmap(0, va);
  801fae:	83 ec 08             	sub    $0x8,%esp
  801fb1:	56                   	push   %esi
  801fb2:	6a 00                	push   $0x0
  801fb4:	e8 7a ec ff ff       	call   800c33 <sys_page_unmap>
  801fb9:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801fbc:	83 ec 08             	sub    $0x8,%esp
  801fbf:	ff 75 f0             	push   -0x10(%ebp)
  801fc2:	6a 00                	push   $0x0
  801fc4:	e8 6a ec ff ff       	call   800c33 <sys_page_unmap>
  801fc9:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801fcc:	83 ec 08             	sub    $0x8,%esp
  801fcf:	ff 75 f4             	push   -0xc(%ebp)
  801fd2:	6a 00                	push   $0x0
  801fd4:	e8 5a ec ff ff       	call   800c33 <sys_page_unmap>
  801fd9:	83 c4 10             	add    $0x10,%esp
}
  801fdc:	89 d8                	mov    %ebx,%eax
  801fde:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fe1:	5b                   	pop    %ebx
  801fe2:	5e                   	pop    %esi
  801fe3:	5d                   	pop    %ebp
  801fe4:	c3                   	ret    

00801fe5 <pipeisclosed>:
{
  801fe5:	55                   	push   %ebp
  801fe6:	89 e5                	mov    %esp,%ebp
  801fe8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801feb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fee:	50                   	push   %eax
  801fef:	ff 75 08             	push   0x8(%ebp)
  801ff2:	e8 fe f0 ff ff       	call   8010f5 <fd_lookup>
  801ff7:	83 c4 10             	add    $0x10,%esp
  801ffa:	85 c0                	test   %eax,%eax
  801ffc:	78 18                	js     802016 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801ffe:	83 ec 0c             	sub    $0xc,%esp
  802001:	ff 75 f4             	push   -0xc(%ebp)
  802004:	e8 85 f0 ff ff       	call   80108e <fd2data>
  802009:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80200b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80200e:	e8 33 fd ff ff       	call   801d46 <_pipeisclosed>
  802013:	83 c4 10             	add    $0x10,%esp
}
  802016:	c9                   	leave  
  802017:	c3                   	ret    

00802018 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  802018:	b8 00 00 00 00       	mov    $0x0,%eax
  80201d:	c3                   	ret    

0080201e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80201e:	55                   	push   %ebp
  80201f:	89 e5                	mov    %esp,%ebp
  802021:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802024:	68 13 2b 80 00       	push   $0x802b13
  802029:	ff 75 0c             	push   0xc(%ebp)
  80202c:	e8 81 e7 ff ff       	call   8007b2 <strcpy>
	return 0;
}
  802031:	b8 00 00 00 00       	mov    $0x0,%eax
  802036:	c9                   	leave  
  802037:	c3                   	ret    

00802038 <devcons_write>:
{
  802038:	55                   	push   %ebp
  802039:	89 e5                	mov    %esp,%ebp
  80203b:	57                   	push   %edi
  80203c:	56                   	push   %esi
  80203d:	53                   	push   %ebx
  80203e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802044:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802049:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80204f:	eb 2e                	jmp    80207f <devcons_write+0x47>
		m = n - tot;
  802051:	8b 5d 10             	mov    0x10(%ebp),%ebx
  802054:	29 f3                	sub    %esi,%ebx
  802056:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80205b:	39 c3                	cmp    %eax,%ebx
  80205d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802060:	83 ec 04             	sub    $0x4,%esp
  802063:	53                   	push   %ebx
  802064:	89 f0                	mov    %esi,%eax
  802066:	03 45 0c             	add    0xc(%ebp),%eax
  802069:	50                   	push   %eax
  80206a:	57                   	push   %edi
  80206b:	e8 d8 e8 ff ff       	call   800948 <memmove>
		sys_cputs(buf, m);
  802070:	83 c4 08             	add    $0x8,%esp
  802073:	53                   	push   %ebx
  802074:	57                   	push   %edi
  802075:	e8 78 ea ff ff       	call   800af2 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80207a:	01 de                	add    %ebx,%esi
  80207c:	83 c4 10             	add    $0x10,%esp
  80207f:	3b 75 10             	cmp    0x10(%ebp),%esi
  802082:	72 cd                	jb     802051 <devcons_write+0x19>
}
  802084:	89 f0                	mov    %esi,%eax
  802086:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802089:	5b                   	pop    %ebx
  80208a:	5e                   	pop    %esi
  80208b:	5f                   	pop    %edi
  80208c:	5d                   	pop    %ebp
  80208d:	c3                   	ret    

0080208e <devcons_read>:
{
  80208e:	55                   	push   %ebp
  80208f:	89 e5                	mov    %esp,%ebp
  802091:	83 ec 08             	sub    $0x8,%esp
  802094:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802099:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80209d:	75 07                	jne    8020a6 <devcons_read+0x18>
  80209f:	eb 1f                	jmp    8020c0 <devcons_read+0x32>
		sys_yield();
  8020a1:	e8 e9 ea ff ff       	call   800b8f <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8020a6:	e8 65 ea ff ff       	call   800b10 <sys_cgetc>
  8020ab:	85 c0                	test   %eax,%eax
  8020ad:	74 f2                	je     8020a1 <devcons_read+0x13>
	if (c < 0)
  8020af:	78 0f                	js     8020c0 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8020b1:	83 f8 04             	cmp    $0x4,%eax
  8020b4:	74 0c                	je     8020c2 <devcons_read+0x34>
	*(char*)vbuf = c;
  8020b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020b9:	88 02                	mov    %al,(%edx)
	return 1;
  8020bb:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8020c0:	c9                   	leave  
  8020c1:	c3                   	ret    
		return 0;
  8020c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c7:	eb f7                	jmp    8020c0 <devcons_read+0x32>

008020c9 <cputchar>:
{
  8020c9:	55                   	push   %ebp
  8020ca:	89 e5                	mov    %esp,%ebp
  8020cc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8020d2:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8020d5:	6a 01                	push   $0x1
  8020d7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020da:	50                   	push   %eax
  8020db:	e8 12 ea ff ff       	call   800af2 <sys_cputs>
}
  8020e0:	83 c4 10             	add    $0x10,%esp
  8020e3:	c9                   	leave  
  8020e4:	c3                   	ret    

008020e5 <getchar>:
{
  8020e5:	55                   	push   %ebp
  8020e6:	89 e5                	mov    %esp,%ebp
  8020e8:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8020eb:	6a 01                	push   $0x1
  8020ed:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020f0:	50                   	push   %eax
  8020f1:	6a 00                	push   $0x0
  8020f3:	e8 66 f2 ff ff       	call   80135e <read>
	if (r < 0)
  8020f8:	83 c4 10             	add    $0x10,%esp
  8020fb:	85 c0                	test   %eax,%eax
  8020fd:	78 06                	js     802105 <getchar+0x20>
	if (r < 1)
  8020ff:	74 06                	je     802107 <getchar+0x22>
	return c;
  802101:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802105:	c9                   	leave  
  802106:	c3                   	ret    
		return -E_EOF;
  802107:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80210c:	eb f7                	jmp    802105 <getchar+0x20>

0080210e <iscons>:
{
  80210e:	55                   	push   %ebp
  80210f:	89 e5                	mov    %esp,%ebp
  802111:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802114:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802117:	50                   	push   %eax
  802118:	ff 75 08             	push   0x8(%ebp)
  80211b:	e8 d5 ef ff ff       	call   8010f5 <fd_lookup>
  802120:	83 c4 10             	add    $0x10,%esp
  802123:	85 c0                	test   %eax,%eax
  802125:	78 11                	js     802138 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  802127:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80212a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802130:	39 10                	cmp    %edx,(%eax)
  802132:	0f 94 c0             	sete   %al
  802135:	0f b6 c0             	movzbl %al,%eax
}
  802138:	c9                   	leave  
  802139:	c3                   	ret    

0080213a <opencons>:
{
  80213a:	55                   	push   %ebp
  80213b:	89 e5                	mov    %esp,%ebp
  80213d:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802140:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802143:	50                   	push   %eax
  802144:	e8 5c ef ff ff       	call   8010a5 <fd_alloc>
  802149:	83 c4 10             	add    $0x10,%esp
  80214c:	85 c0                	test   %eax,%eax
  80214e:	78 3a                	js     80218a <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802150:	83 ec 04             	sub    $0x4,%esp
  802153:	68 07 04 00 00       	push   $0x407
  802158:	ff 75 f4             	push   -0xc(%ebp)
  80215b:	6a 00                	push   $0x0
  80215d:	e8 4c ea ff ff       	call   800bae <sys_page_alloc>
  802162:	83 c4 10             	add    $0x10,%esp
  802165:	85 c0                	test   %eax,%eax
  802167:	78 21                	js     80218a <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  802169:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80216c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802172:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802174:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802177:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80217e:	83 ec 0c             	sub    $0xc,%esp
  802181:	50                   	push   %eax
  802182:	e8 f7 ee ff ff       	call   80107e <fd2num>
  802187:	83 c4 10             	add    $0x10,%esp
}
  80218a:	c9                   	leave  
  80218b:	c3                   	ret    

0080218c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	56                   	push   %esi
  802190:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802191:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802194:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80219a:	e8 d1 e9 ff ff       	call   800b70 <sys_getenvid>
  80219f:	83 ec 0c             	sub    $0xc,%esp
  8021a2:	ff 75 0c             	push   0xc(%ebp)
  8021a5:	ff 75 08             	push   0x8(%ebp)
  8021a8:	56                   	push   %esi
  8021a9:	50                   	push   %eax
  8021aa:	68 20 2b 80 00       	push   $0x802b20
  8021af:	e8 24 e0 ff ff       	call   8001d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021b4:	83 c4 18             	add    $0x18,%esp
  8021b7:	53                   	push   %ebx
  8021b8:	ff 75 10             	push   0x10(%ebp)
  8021bb:	e8 c7 df ff ff       	call   800187 <vcprintf>
	cprintf("\n");
  8021c0:	c7 04 24 ef 25 80 00 	movl   $0x8025ef,(%esp)
  8021c7:	e8 0c e0 ff ff       	call   8001d8 <cprintf>
  8021cc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8021cf:	cc                   	int3   
  8021d0:	eb fd                	jmp    8021cf <_panic+0x43>

008021d2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021d2:	55                   	push   %ebp
  8021d3:	89 e5                	mov    %esp,%ebp
  8021d5:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  8021d8:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  8021df:	74 0a                	je     8021eb <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e4:	a3 04 80 80 00       	mov    %eax,0x808004
}
  8021e9:	c9                   	leave  
  8021ea:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  8021eb:	e8 80 e9 ff ff       	call   800b70 <sys_getenvid>
  8021f0:	83 ec 04             	sub    $0x4,%esp
  8021f3:	68 07 0e 00 00       	push   $0xe07
  8021f8:	68 00 f0 bf ee       	push   $0xeebff000
  8021fd:	50                   	push   %eax
  8021fe:	e8 ab e9 ff ff       	call   800bae <sys_page_alloc>
		if (r < 0) {
  802203:	83 c4 10             	add    $0x10,%esp
  802206:	85 c0                	test   %eax,%eax
  802208:	78 2c                	js     802236 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  80220a:	e8 61 e9 ff ff       	call   800b70 <sys_getenvid>
  80220f:	83 ec 08             	sub    $0x8,%esp
  802212:	68 48 22 80 00       	push   $0x802248
  802217:	50                   	push   %eax
  802218:	e8 dc ea ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  80221d:	83 c4 10             	add    $0x10,%esp
  802220:	85 c0                	test   %eax,%eax
  802222:	79 bd                	jns    8021e1 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  802224:	50                   	push   %eax
  802225:	68 84 2b 80 00       	push   $0x802b84
  80222a:	6a 28                	push   $0x28
  80222c:	68 ba 2b 80 00       	push   $0x802bba
  802231:	e8 56 ff ff ff       	call   80218c <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  802236:	50                   	push   %eax
  802237:	68 44 2b 80 00       	push   $0x802b44
  80223c:	6a 23                	push   $0x23
  80223e:	68 ba 2b 80 00       	push   $0x802bba
  802243:	e8 44 ff ff ff       	call   80218c <_panic>

00802248 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802248:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802249:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  80224e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802250:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  802253:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  802257:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  80225a:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  80225e:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  802262:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  802264:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  802267:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  802268:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  80226b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  80226c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  80226d:	c3                   	ret    

0080226e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80226e:	55                   	push   %ebp
  80226f:	89 e5                	mov    %esp,%ebp
  802271:	56                   	push   %esi
  802272:	53                   	push   %ebx
  802273:	8b 75 08             	mov    0x8(%ebp),%esi
  802276:	8b 45 0c             	mov    0xc(%ebp),%eax
  802279:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80227c:	85 c0                	test   %eax,%eax
  80227e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802283:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802286:	83 ec 0c             	sub    $0xc,%esp
  802289:	50                   	push   %eax
  80228a:	e8 cf ea ff ff       	call   800d5e <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  80228f:	83 c4 10             	add    $0x10,%esp
  802292:	85 f6                	test   %esi,%esi
  802294:	74 14                	je     8022aa <ipc_recv+0x3c>
  802296:	ba 00 00 00 00       	mov    $0x0,%edx
  80229b:	85 c0                	test   %eax,%eax
  80229d:	78 09                	js     8022a8 <ipc_recv+0x3a>
  80229f:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8022a5:	8b 52 74             	mov    0x74(%edx),%edx
  8022a8:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  8022aa:	85 db                	test   %ebx,%ebx
  8022ac:	74 14                	je     8022c2 <ipc_recv+0x54>
  8022ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8022b3:	85 c0                	test   %eax,%eax
  8022b5:	78 09                	js     8022c0 <ipc_recv+0x52>
  8022b7:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8022bd:	8b 52 78             	mov    0x78(%edx),%edx
  8022c0:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  8022c2:	85 c0                	test   %eax,%eax
  8022c4:	78 08                	js     8022ce <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  8022c6:	a1 00 40 80 00       	mov    0x804000,%eax
  8022cb:	8b 40 70             	mov    0x70(%eax),%eax
}
  8022ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022d1:	5b                   	pop    %ebx
  8022d2:	5e                   	pop    %esi
  8022d3:	5d                   	pop    %ebp
  8022d4:	c3                   	ret    

008022d5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022d5:	55                   	push   %ebp
  8022d6:	89 e5                	mov    %esp,%ebp
  8022d8:	57                   	push   %edi
  8022d9:	56                   	push   %esi
  8022da:	53                   	push   %ebx
  8022db:	83 ec 0c             	sub    $0xc,%esp
  8022de:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8022e7:	85 db                	test   %ebx,%ebx
  8022e9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8022ee:	0f 44 d8             	cmove  %eax,%ebx
  8022f1:	eb 05                	jmp    8022f8 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8022f3:	e8 97 e8 ff ff       	call   800b8f <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8022f8:	ff 75 14             	push   0x14(%ebp)
  8022fb:	53                   	push   %ebx
  8022fc:	56                   	push   %esi
  8022fd:	57                   	push   %edi
  8022fe:	e8 38 ea ff ff       	call   800d3b <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802303:	83 c4 10             	add    $0x10,%esp
  802306:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802309:	74 e8                	je     8022f3 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80230b:	85 c0                	test   %eax,%eax
  80230d:	78 08                	js     802317 <ipc_send+0x42>
	}while (r<0);

}
  80230f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802312:	5b                   	pop    %ebx
  802313:	5e                   	pop    %esi
  802314:	5f                   	pop    %edi
  802315:	5d                   	pop    %ebp
  802316:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802317:	50                   	push   %eax
  802318:	68 c8 2b 80 00       	push   $0x802bc8
  80231d:	6a 3d                	push   $0x3d
  80231f:	68 dc 2b 80 00       	push   $0x802bdc
  802324:	e8 63 fe ff ff       	call   80218c <_panic>

00802329 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802329:	55                   	push   %ebp
  80232a:	89 e5                	mov    %esp,%ebp
  80232c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80232f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802334:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802337:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80233d:	8b 52 50             	mov    0x50(%edx),%edx
  802340:	39 ca                	cmp    %ecx,%edx
  802342:	74 11                	je     802355 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802344:	83 c0 01             	add    $0x1,%eax
  802347:	3d 00 04 00 00       	cmp    $0x400,%eax
  80234c:	75 e6                	jne    802334 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80234e:	b8 00 00 00 00       	mov    $0x0,%eax
  802353:	eb 0b                	jmp    802360 <ipc_find_env+0x37>
			return envs[i].env_id;
  802355:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802358:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80235d:	8b 40 48             	mov    0x48(%eax),%eax
}
  802360:	5d                   	pop    %ebp
  802361:	c3                   	ret    

00802362 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802362:	55                   	push   %ebp
  802363:	89 e5                	mov    %esp,%ebp
  802365:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802368:	89 c2                	mov    %eax,%edx
  80236a:	c1 ea 16             	shr    $0x16,%edx
  80236d:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802374:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802379:	f6 c1 01             	test   $0x1,%cl
  80237c:	74 1c                	je     80239a <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  80237e:	c1 e8 0c             	shr    $0xc,%eax
  802381:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802388:	a8 01                	test   $0x1,%al
  80238a:	74 0e                	je     80239a <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80238c:	c1 e8 0c             	shr    $0xc,%eax
  80238f:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802396:	ef 
  802397:	0f b7 d2             	movzwl %dx,%edx
}
  80239a:	89 d0                	mov    %edx,%eax
  80239c:	5d                   	pop    %ebp
  80239d:	c3                   	ret    
  80239e:	66 90                	xchg   %ax,%ax

008023a0 <__udivdi3>:
  8023a0:	f3 0f 1e fb          	endbr32 
  8023a4:	55                   	push   %ebp
  8023a5:	57                   	push   %edi
  8023a6:	56                   	push   %esi
  8023a7:	53                   	push   %ebx
  8023a8:	83 ec 1c             	sub    $0x1c,%esp
  8023ab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8023af:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8023b3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023b7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8023bb:	85 c0                	test   %eax,%eax
  8023bd:	75 19                	jne    8023d8 <__udivdi3+0x38>
  8023bf:	39 f3                	cmp    %esi,%ebx
  8023c1:	76 4d                	jbe    802410 <__udivdi3+0x70>
  8023c3:	31 ff                	xor    %edi,%edi
  8023c5:	89 e8                	mov    %ebp,%eax
  8023c7:	89 f2                	mov    %esi,%edx
  8023c9:	f7 f3                	div    %ebx
  8023cb:	89 fa                	mov    %edi,%edx
  8023cd:	83 c4 1c             	add    $0x1c,%esp
  8023d0:	5b                   	pop    %ebx
  8023d1:	5e                   	pop    %esi
  8023d2:	5f                   	pop    %edi
  8023d3:	5d                   	pop    %ebp
  8023d4:	c3                   	ret    
  8023d5:	8d 76 00             	lea    0x0(%esi),%esi
  8023d8:	39 f0                	cmp    %esi,%eax
  8023da:	76 14                	jbe    8023f0 <__udivdi3+0x50>
  8023dc:	31 ff                	xor    %edi,%edi
  8023de:	31 c0                	xor    %eax,%eax
  8023e0:	89 fa                	mov    %edi,%edx
  8023e2:	83 c4 1c             	add    $0x1c,%esp
  8023e5:	5b                   	pop    %ebx
  8023e6:	5e                   	pop    %esi
  8023e7:	5f                   	pop    %edi
  8023e8:	5d                   	pop    %ebp
  8023e9:	c3                   	ret    
  8023ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023f0:	0f bd f8             	bsr    %eax,%edi
  8023f3:	83 f7 1f             	xor    $0x1f,%edi
  8023f6:	75 48                	jne    802440 <__udivdi3+0xa0>
  8023f8:	39 f0                	cmp    %esi,%eax
  8023fa:	72 06                	jb     802402 <__udivdi3+0x62>
  8023fc:	31 c0                	xor    %eax,%eax
  8023fe:	39 eb                	cmp    %ebp,%ebx
  802400:	77 de                	ja     8023e0 <__udivdi3+0x40>
  802402:	b8 01 00 00 00       	mov    $0x1,%eax
  802407:	eb d7                	jmp    8023e0 <__udivdi3+0x40>
  802409:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802410:	89 d9                	mov    %ebx,%ecx
  802412:	85 db                	test   %ebx,%ebx
  802414:	75 0b                	jne    802421 <__udivdi3+0x81>
  802416:	b8 01 00 00 00       	mov    $0x1,%eax
  80241b:	31 d2                	xor    %edx,%edx
  80241d:	f7 f3                	div    %ebx
  80241f:	89 c1                	mov    %eax,%ecx
  802421:	31 d2                	xor    %edx,%edx
  802423:	89 f0                	mov    %esi,%eax
  802425:	f7 f1                	div    %ecx
  802427:	89 c6                	mov    %eax,%esi
  802429:	89 e8                	mov    %ebp,%eax
  80242b:	89 f7                	mov    %esi,%edi
  80242d:	f7 f1                	div    %ecx
  80242f:	89 fa                	mov    %edi,%edx
  802431:	83 c4 1c             	add    $0x1c,%esp
  802434:	5b                   	pop    %ebx
  802435:	5e                   	pop    %esi
  802436:	5f                   	pop    %edi
  802437:	5d                   	pop    %ebp
  802438:	c3                   	ret    
  802439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802440:	89 f9                	mov    %edi,%ecx
  802442:	ba 20 00 00 00       	mov    $0x20,%edx
  802447:	29 fa                	sub    %edi,%edx
  802449:	d3 e0                	shl    %cl,%eax
  80244b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80244f:	89 d1                	mov    %edx,%ecx
  802451:	89 d8                	mov    %ebx,%eax
  802453:	d3 e8                	shr    %cl,%eax
  802455:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802459:	09 c1                	or     %eax,%ecx
  80245b:	89 f0                	mov    %esi,%eax
  80245d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802461:	89 f9                	mov    %edi,%ecx
  802463:	d3 e3                	shl    %cl,%ebx
  802465:	89 d1                	mov    %edx,%ecx
  802467:	d3 e8                	shr    %cl,%eax
  802469:	89 f9                	mov    %edi,%ecx
  80246b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80246f:	89 eb                	mov    %ebp,%ebx
  802471:	d3 e6                	shl    %cl,%esi
  802473:	89 d1                	mov    %edx,%ecx
  802475:	d3 eb                	shr    %cl,%ebx
  802477:	09 f3                	or     %esi,%ebx
  802479:	89 c6                	mov    %eax,%esi
  80247b:	89 f2                	mov    %esi,%edx
  80247d:	89 d8                	mov    %ebx,%eax
  80247f:	f7 74 24 08          	divl   0x8(%esp)
  802483:	89 d6                	mov    %edx,%esi
  802485:	89 c3                	mov    %eax,%ebx
  802487:	f7 64 24 0c          	mull   0xc(%esp)
  80248b:	39 d6                	cmp    %edx,%esi
  80248d:	72 19                	jb     8024a8 <__udivdi3+0x108>
  80248f:	89 f9                	mov    %edi,%ecx
  802491:	d3 e5                	shl    %cl,%ebp
  802493:	39 c5                	cmp    %eax,%ebp
  802495:	73 04                	jae    80249b <__udivdi3+0xfb>
  802497:	39 d6                	cmp    %edx,%esi
  802499:	74 0d                	je     8024a8 <__udivdi3+0x108>
  80249b:	89 d8                	mov    %ebx,%eax
  80249d:	31 ff                	xor    %edi,%edi
  80249f:	e9 3c ff ff ff       	jmp    8023e0 <__udivdi3+0x40>
  8024a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024a8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8024ab:	31 ff                	xor    %edi,%edi
  8024ad:	e9 2e ff ff ff       	jmp    8023e0 <__udivdi3+0x40>
  8024b2:	66 90                	xchg   %ax,%ax
  8024b4:	66 90                	xchg   %ax,%ax
  8024b6:	66 90                	xchg   %ax,%ax
  8024b8:	66 90                	xchg   %ax,%ax
  8024ba:	66 90                	xchg   %ax,%ax
  8024bc:	66 90                	xchg   %ax,%ax
  8024be:	66 90                	xchg   %ax,%ax

008024c0 <__umoddi3>:
  8024c0:	f3 0f 1e fb          	endbr32 
  8024c4:	55                   	push   %ebp
  8024c5:	57                   	push   %edi
  8024c6:	56                   	push   %esi
  8024c7:	53                   	push   %ebx
  8024c8:	83 ec 1c             	sub    $0x1c,%esp
  8024cb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8024cf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8024d3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8024d7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8024db:	89 f0                	mov    %esi,%eax
  8024dd:	89 da                	mov    %ebx,%edx
  8024df:	85 ff                	test   %edi,%edi
  8024e1:	75 15                	jne    8024f8 <__umoddi3+0x38>
  8024e3:	39 dd                	cmp    %ebx,%ebp
  8024e5:	76 39                	jbe    802520 <__umoddi3+0x60>
  8024e7:	f7 f5                	div    %ebp
  8024e9:	89 d0                	mov    %edx,%eax
  8024eb:	31 d2                	xor    %edx,%edx
  8024ed:	83 c4 1c             	add    $0x1c,%esp
  8024f0:	5b                   	pop    %ebx
  8024f1:	5e                   	pop    %esi
  8024f2:	5f                   	pop    %edi
  8024f3:	5d                   	pop    %ebp
  8024f4:	c3                   	ret    
  8024f5:	8d 76 00             	lea    0x0(%esi),%esi
  8024f8:	39 df                	cmp    %ebx,%edi
  8024fa:	77 f1                	ja     8024ed <__umoddi3+0x2d>
  8024fc:	0f bd cf             	bsr    %edi,%ecx
  8024ff:	83 f1 1f             	xor    $0x1f,%ecx
  802502:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802506:	75 40                	jne    802548 <__umoddi3+0x88>
  802508:	39 df                	cmp    %ebx,%edi
  80250a:	72 04                	jb     802510 <__umoddi3+0x50>
  80250c:	39 f5                	cmp    %esi,%ebp
  80250e:	77 dd                	ja     8024ed <__umoddi3+0x2d>
  802510:	89 da                	mov    %ebx,%edx
  802512:	89 f0                	mov    %esi,%eax
  802514:	29 e8                	sub    %ebp,%eax
  802516:	19 fa                	sbb    %edi,%edx
  802518:	eb d3                	jmp    8024ed <__umoddi3+0x2d>
  80251a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802520:	89 e9                	mov    %ebp,%ecx
  802522:	85 ed                	test   %ebp,%ebp
  802524:	75 0b                	jne    802531 <__umoddi3+0x71>
  802526:	b8 01 00 00 00       	mov    $0x1,%eax
  80252b:	31 d2                	xor    %edx,%edx
  80252d:	f7 f5                	div    %ebp
  80252f:	89 c1                	mov    %eax,%ecx
  802531:	89 d8                	mov    %ebx,%eax
  802533:	31 d2                	xor    %edx,%edx
  802535:	f7 f1                	div    %ecx
  802537:	89 f0                	mov    %esi,%eax
  802539:	f7 f1                	div    %ecx
  80253b:	89 d0                	mov    %edx,%eax
  80253d:	31 d2                	xor    %edx,%edx
  80253f:	eb ac                	jmp    8024ed <__umoddi3+0x2d>
  802541:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802548:	8b 44 24 04          	mov    0x4(%esp),%eax
  80254c:	ba 20 00 00 00       	mov    $0x20,%edx
  802551:	29 c2                	sub    %eax,%edx
  802553:	89 c1                	mov    %eax,%ecx
  802555:	89 e8                	mov    %ebp,%eax
  802557:	d3 e7                	shl    %cl,%edi
  802559:	89 d1                	mov    %edx,%ecx
  80255b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80255f:	d3 e8                	shr    %cl,%eax
  802561:	89 c1                	mov    %eax,%ecx
  802563:	8b 44 24 04          	mov    0x4(%esp),%eax
  802567:	09 f9                	or     %edi,%ecx
  802569:	89 df                	mov    %ebx,%edi
  80256b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80256f:	89 c1                	mov    %eax,%ecx
  802571:	d3 e5                	shl    %cl,%ebp
  802573:	89 d1                	mov    %edx,%ecx
  802575:	d3 ef                	shr    %cl,%edi
  802577:	89 c1                	mov    %eax,%ecx
  802579:	89 f0                	mov    %esi,%eax
  80257b:	d3 e3                	shl    %cl,%ebx
  80257d:	89 d1                	mov    %edx,%ecx
  80257f:	89 fa                	mov    %edi,%edx
  802581:	d3 e8                	shr    %cl,%eax
  802583:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802588:	09 d8                	or     %ebx,%eax
  80258a:	f7 74 24 08          	divl   0x8(%esp)
  80258e:	89 d3                	mov    %edx,%ebx
  802590:	d3 e6                	shl    %cl,%esi
  802592:	f7 e5                	mul    %ebp
  802594:	89 c7                	mov    %eax,%edi
  802596:	89 d1                	mov    %edx,%ecx
  802598:	39 d3                	cmp    %edx,%ebx
  80259a:	72 06                	jb     8025a2 <__umoddi3+0xe2>
  80259c:	75 0e                	jne    8025ac <__umoddi3+0xec>
  80259e:	39 c6                	cmp    %eax,%esi
  8025a0:	73 0a                	jae    8025ac <__umoddi3+0xec>
  8025a2:	29 e8                	sub    %ebp,%eax
  8025a4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8025a8:	89 d1                	mov    %edx,%ecx
  8025aa:	89 c7                	mov    %eax,%edi
  8025ac:	89 f5                	mov    %esi,%ebp
  8025ae:	8b 74 24 04          	mov    0x4(%esp),%esi
  8025b2:	29 fd                	sub    %edi,%ebp
  8025b4:	19 cb                	sbb    %ecx,%ebx
  8025b6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8025bb:	89 d8                	mov    %ebx,%eax
  8025bd:	d3 e0                	shl    %cl,%eax
  8025bf:	89 f1                	mov    %esi,%ecx
  8025c1:	d3 ed                	shr    %cl,%ebp
  8025c3:	d3 eb                	shr    %cl,%ebx
  8025c5:	09 e8                	or     %ebp,%eax
  8025c7:	89 da                	mov    %ebx,%edx
  8025c9:	83 c4 1c             	add    $0x1c,%esp
  8025cc:	5b                   	pop    %ebx
  8025cd:	5e                   	pop    %esi
  8025ce:	5f                   	pop    %edi
  8025cf:	5d                   	pop    %ebp
  8025d0:	c3                   	ret    
