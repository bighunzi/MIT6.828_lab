
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
  800047:	68 20 21 80 00       	push   $0x802120
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
  80009c:	68 31 21 80 00       	push   $0x802131
  8000a1:	6a 04                	push   $0x4
  8000a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a6:	50                   	push   %eax
  8000a7:	e8 b1 06 00 00       	call   80075d <snprintf>
	if (fork() == 0) {
  8000ac:	83 c4 20             	add    $0x20,%esp
  8000af:	e8 e9 0d 00 00       	call   800e9d <fork>
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
  8000d4:	68 30 21 80 00       	push   $0x802130
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
  80012f:	e8 b5 10 00 00       	call   8011e9 <close_all>
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
  80023a:	e8 91 1c 00 00       	call   801ed0 <__udivdi3>
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
  800278:	e8 73 1d 00 00       	call   801ff0 <__umoddi3>
  80027d:	83 c4 14             	add    $0x14,%esp
  800280:	0f be 80 40 21 80 00 	movsbl 0x802140(%eax),%eax
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
  80033a:	ff 24 85 80 22 80 00 	jmp    *0x802280(,%eax,4)
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
  800408:	8b 14 85 e0 23 80 00 	mov    0x8023e0(,%eax,4),%edx
  80040f:	85 d2                	test   %edx,%edx
  800411:	74 18                	je     80042b <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800413:	52                   	push   %edx
  800414:	68 dd 25 80 00       	push   $0x8025dd
  800419:	53                   	push   %ebx
  80041a:	56                   	push   %esi
  80041b:	e8 92 fe ff ff       	call   8002b2 <printfmt>
  800420:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800423:	89 7d 14             	mov    %edi,0x14(%ebp)
  800426:	e9 66 02 00 00       	jmp    800691 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80042b:	50                   	push   %eax
  80042c:	68 58 21 80 00       	push   $0x802158
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
  800453:	b8 51 21 80 00       	mov    $0x802151,%eax
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
  800b5f:	68 3f 24 80 00       	push   $0x80243f
  800b64:	6a 2a                	push   $0x2a
  800b66:	68 5c 24 80 00       	push   $0x80245c
  800b6b:	e8 4e 11 00 00       	call   801cbe <_panic>

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
  800be0:	68 3f 24 80 00       	push   $0x80243f
  800be5:	6a 2a                	push   $0x2a
  800be7:	68 5c 24 80 00       	push   $0x80245c
  800bec:	e8 cd 10 00 00       	call   801cbe <_panic>

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
  800c22:	68 3f 24 80 00       	push   $0x80243f
  800c27:	6a 2a                	push   $0x2a
  800c29:	68 5c 24 80 00       	push   $0x80245c
  800c2e:	e8 8b 10 00 00       	call   801cbe <_panic>

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
  800c64:	68 3f 24 80 00       	push   $0x80243f
  800c69:	6a 2a                	push   $0x2a
  800c6b:	68 5c 24 80 00       	push   $0x80245c
  800c70:	e8 49 10 00 00       	call   801cbe <_panic>

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
  800ca6:	68 3f 24 80 00       	push   $0x80243f
  800cab:	6a 2a                	push   $0x2a
  800cad:	68 5c 24 80 00       	push   $0x80245c
  800cb2:	e8 07 10 00 00       	call   801cbe <_panic>

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
  800ce8:	68 3f 24 80 00       	push   $0x80243f
  800ced:	6a 2a                	push   $0x2a
  800cef:	68 5c 24 80 00       	push   $0x80245c
  800cf4:	e8 c5 0f 00 00       	call   801cbe <_panic>

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
  800d2a:	68 3f 24 80 00       	push   $0x80243f
  800d2f:	6a 2a                	push   $0x2a
  800d31:	68 5c 24 80 00       	push   $0x80245c
  800d36:	e8 83 0f 00 00       	call   801cbe <_panic>

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
  800d8e:	68 3f 24 80 00       	push   $0x80243f
  800d93:	6a 2a                	push   $0x2a
  800d95:	68 5c 24 80 00       	push   $0x80245c
  800d9a:	e8 1f 0f 00 00       	call   801cbe <_panic>

00800d9f <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	56                   	push   %esi
  800da3:	53                   	push   %ebx
  800da4:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800da7:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800da9:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800dad:	0f 84 8e 00 00 00    	je     800e41 <pgfault+0xa2>
  800db3:	89 f0                	mov    %esi,%eax
  800db5:	c1 e8 0c             	shr    $0xc,%eax
  800db8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800dbf:	f6 c4 08             	test   $0x8,%ah
  800dc2:	74 7d                	je     800e41 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800dc4:	e8 a7 fd ff ff       	call   800b70 <sys_getenvid>
  800dc9:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800dcb:	83 ec 04             	sub    $0x4,%esp
  800dce:	6a 07                	push   $0x7
  800dd0:	68 00 f0 7f 00       	push   $0x7ff000
  800dd5:	50                   	push   %eax
  800dd6:	e8 d3 fd ff ff       	call   800bae <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800ddb:	83 c4 10             	add    $0x10,%esp
  800dde:	85 c0                	test   %eax,%eax
  800de0:	78 73                	js     800e55 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800de2:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800de8:	83 ec 04             	sub    $0x4,%esp
  800deb:	68 00 10 00 00       	push   $0x1000
  800df0:	56                   	push   %esi
  800df1:	68 00 f0 7f 00       	push   $0x7ff000
  800df6:	e8 4d fb ff ff       	call   800948 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800dfb:	83 c4 08             	add    $0x8,%esp
  800dfe:	56                   	push   %esi
  800dff:	53                   	push   %ebx
  800e00:	e8 2e fe ff ff       	call   800c33 <sys_page_unmap>
  800e05:	83 c4 10             	add    $0x10,%esp
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	78 5b                	js     800e67 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800e0c:	83 ec 0c             	sub    $0xc,%esp
  800e0f:	6a 07                	push   $0x7
  800e11:	56                   	push   %esi
  800e12:	53                   	push   %ebx
  800e13:	68 00 f0 7f 00       	push   $0x7ff000
  800e18:	53                   	push   %ebx
  800e19:	e8 d3 fd ff ff       	call   800bf1 <sys_page_map>
  800e1e:	83 c4 20             	add    $0x20,%esp
  800e21:	85 c0                	test   %eax,%eax
  800e23:	78 54                	js     800e79 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800e25:	83 ec 08             	sub    $0x8,%esp
  800e28:	68 00 f0 7f 00       	push   $0x7ff000
  800e2d:	53                   	push   %ebx
  800e2e:	e8 00 fe ff ff       	call   800c33 <sys_page_unmap>
  800e33:	83 c4 10             	add    $0x10,%esp
  800e36:	85 c0                	test   %eax,%eax
  800e38:	78 51                	js     800e8b <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800e3a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800e41:	83 ec 04             	sub    $0x4,%esp
  800e44:	68 6c 24 80 00       	push   $0x80246c
  800e49:	6a 1d                	push   $0x1d
  800e4b:	68 e8 24 80 00       	push   $0x8024e8
  800e50:	e8 69 0e 00 00       	call   801cbe <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800e55:	50                   	push   %eax
  800e56:	68 a4 24 80 00       	push   $0x8024a4
  800e5b:	6a 29                	push   $0x29
  800e5d:	68 e8 24 80 00       	push   $0x8024e8
  800e62:	e8 57 0e 00 00       	call   801cbe <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800e67:	50                   	push   %eax
  800e68:	68 c8 24 80 00       	push   $0x8024c8
  800e6d:	6a 2e                	push   $0x2e
  800e6f:	68 e8 24 80 00       	push   $0x8024e8
  800e74:	e8 45 0e 00 00       	call   801cbe <_panic>
		panic("pgfault: page map failed (%e)", r);
  800e79:	50                   	push   %eax
  800e7a:	68 f3 24 80 00       	push   $0x8024f3
  800e7f:	6a 30                	push   $0x30
  800e81:	68 e8 24 80 00       	push   $0x8024e8
  800e86:	e8 33 0e 00 00       	call   801cbe <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800e8b:	50                   	push   %eax
  800e8c:	68 c8 24 80 00       	push   $0x8024c8
  800e91:	6a 32                	push   $0x32
  800e93:	68 e8 24 80 00       	push   $0x8024e8
  800e98:	e8 21 0e 00 00       	call   801cbe <_panic>

00800e9d <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	57                   	push   %edi
  800ea1:	56                   	push   %esi
  800ea2:	53                   	push   %ebx
  800ea3:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800ea6:	68 9f 0d 80 00       	push   $0x800d9f
  800eab:	e8 54 0e 00 00       	call   801d04 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800eb0:	b8 07 00 00 00       	mov    $0x7,%eax
  800eb5:	cd 30                	int    $0x30
  800eb7:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800eba:	83 c4 10             	add    $0x10,%esp
  800ebd:	85 c0                	test   %eax,%eax
  800ebf:	78 2d                	js     800eee <fork+0x51>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800ec1:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800ec6:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800eca:	75 73                	jne    800f3f <fork+0xa2>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ecc:	e8 9f fc ff ff       	call   800b70 <sys_getenvid>
  800ed1:	25 ff 03 00 00       	and    $0x3ff,%eax
  800ed6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800ed9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800ede:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  800ee3:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800ee6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee9:	5b                   	pop    %ebx
  800eea:	5e                   	pop    %esi
  800eeb:	5f                   	pop    %edi
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  800eee:	50                   	push   %eax
  800eef:	68 11 25 80 00       	push   $0x802511
  800ef4:	6a 78                	push   $0x78
  800ef6:	68 e8 24 80 00       	push   $0x8024e8
  800efb:	e8 be 0d 00 00       	call   801cbe <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  800f00:	83 ec 0c             	sub    $0xc,%esp
  800f03:	ff 75 e4             	push   -0x1c(%ebp)
  800f06:	57                   	push   %edi
  800f07:	ff 75 dc             	push   -0x24(%ebp)
  800f0a:	57                   	push   %edi
  800f0b:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800f0e:	56                   	push   %esi
  800f0f:	e8 dd fc ff ff       	call   800bf1 <sys_page_map>
	if(r<0) return r;
  800f14:	83 c4 20             	add    $0x20,%esp
  800f17:	85 c0                	test   %eax,%eax
  800f19:	78 cb                	js     800ee6 <fork+0x49>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  800f1b:	83 ec 0c             	sub    $0xc,%esp
  800f1e:	ff 75 e4             	push   -0x1c(%ebp)
  800f21:	57                   	push   %edi
  800f22:	56                   	push   %esi
  800f23:	57                   	push   %edi
  800f24:	56                   	push   %esi
  800f25:	e8 c7 fc ff ff       	call   800bf1 <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  800f2a:	83 c4 20             	add    $0x20,%esp
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	78 76                	js     800fa7 <fork+0x10a>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800f31:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  800f37:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  800f3d:	74 75                	je     800fb4 <fork+0x117>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  800f3f:	89 d8                	mov    %ebx,%eax
  800f41:	c1 e8 16             	shr    $0x16,%eax
  800f44:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f4b:	a8 01                	test   $0x1,%al
  800f4d:	74 e2                	je     800f31 <fork+0x94>
  800f4f:	89 de                	mov    %ebx,%esi
  800f51:	c1 ee 0c             	shr    $0xc,%esi
  800f54:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f5b:	a8 01                	test   $0x1,%al
  800f5d:	74 d2                	je     800f31 <fork+0x94>
	envid_t this_envid = sys_getenvid();//父进程号
  800f5f:	e8 0c fc ff ff       	call   800b70 <sys_getenvid>
  800f64:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  800f67:	89 f7                	mov    %esi,%edi
  800f69:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  800f6c:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  800f73:	89 c1                	mov    %eax,%ecx
  800f75:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  800f7b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  800f7e:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  800f85:	f6 c6 04             	test   $0x4,%dh
  800f88:	0f 85 72 ff ff ff    	jne    800f00 <fork+0x63>
		perm &= ~PTE_W;
  800f8e:	25 05 0e 00 00       	and    $0xe05,%eax
  800f93:	80 cc 08             	or     $0x8,%ah
  800f96:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  800f9c:	0f 44 c1             	cmove  %ecx,%eax
  800f9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800fa2:	e9 59 ff ff ff       	jmp    800f00 <fork+0x63>
  800fa7:	ba 00 00 00 00       	mov    $0x0,%edx
  800fac:	0f 4f c2             	cmovg  %edx,%eax
  800faf:	e9 32 ff ff ff       	jmp    800ee6 <fork+0x49>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  800fb4:	83 ec 04             	sub    $0x4,%esp
  800fb7:	6a 07                	push   $0x7
  800fb9:	68 00 f0 bf ee       	push   $0xeebff000
  800fbe:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800fc1:	57                   	push   %edi
  800fc2:	e8 e7 fb ff ff       	call   800bae <sys_page_alloc>
	if(r<0) return r;
  800fc7:	83 c4 10             	add    $0x10,%esp
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	0f 88 14 ff ff ff    	js     800ee6 <fork+0x49>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  800fd2:	83 ec 08             	sub    $0x8,%esp
  800fd5:	68 7a 1d 80 00       	push   $0x801d7a
  800fda:	57                   	push   %edi
  800fdb:	e8 19 fd ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  800fe0:	83 c4 10             	add    $0x10,%esp
  800fe3:	85 c0                	test   %eax,%eax
  800fe5:	0f 88 fb fe ff ff    	js     800ee6 <fork+0x49>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  800feb:	83 ec 08             	sub    $0x8,%esp
  800fee:	6a 02                	push   $0x2
  800ff0:	57                   	push   %edi
  800ff1:	e8 7f fc ff ff       	call   800c75 <sys_env_set_status>
	if(r<0) return r;
  800ff6:	83 c4 10             	add    $0x10,%esp
	return envid;
  800ff9:	85 c0                	test   %eax,%eax
  800ffb:	0f 49 c7             	cmovns %edi,%eax
  800ffe:	e9 e3 fe ff ff       	jmp    800ee6 <fork+0x49>

00801003 <sfork>:

// Challenge!
int
sfork(void)
{
  801003:	55                   	push   %ebp
  801004:	89 e5                	mov    %esp,%ebp
  801006:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801009:	68 21 25 80 00       	push   $0x802521
  80100e:	68 a1 00 00 00       	push   $0xa1
  801013:	68 e8 24 80 00       	push   $0x8024e8
  801018:	e8 a1 0c 00 00       	call   801cbe <_panic>

0080101d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801020:	8b 45 08             	mov    0x8(%ebp),%eax
  801023:	05 00 00 00 30       	add    $0x30000000,%eax
  801028:	c1 e8 0c             	shr    $0xc,%eax
}
  80102b:	5d                   	pop    %ebp
  80102c:	c3                   	ret    

0080102d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80102d:	55                   	push   %ebp
  80102e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801030:	8b 45 08             	mov    0x8(%ebp),%eax
  801033:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  801038:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80103d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801042:	5d                   	pop    %ebp
  801043:	c3                   	ret    

00801044 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80104c:	89 c2                	mov    %eax,%edx
  80104e:	c1 ea 16             	shr    $0x16,%edx
  801051:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801058:	f6 c2 01             	test   $0x1,%dl
  80105b:	74 29                	je     801086 <fd_alloc+0x42>
  80105d:	89 c2                	mov    %eax,%edx
  80105f:	c1 ea 0c             	shr    $0xc,%edx
  801062:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801069:	f6 c2 01             	test   $0x1,%dl
  80106c:	74 18                	je     801086 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  80106e:	05 00 10 00 00       	add    $0x1000,%eax
  801073:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801078:	75 d2                	jne    80104c <fd_alloc+0x8>
  80107a:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80107f:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801084:	eb 05                	jmp    80108b <fd_alloc+0x47>
			return 0;
  801086:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80108b:	8b 55 08             	mov    0x8(%ebp),%edx
  80108e:	89 02                	mov    %eax,(%edx)
}
  801090:	89 c8                	mov    %ecx,%eax
  801092:	5d                   	pop    %ebp
  801093:	c3                   	ret    

00801094 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801094:	55                   	push   %ebp
  801095:	89 e5                	mov    %esp,%ebp
  801097:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80109a:	83 f8 1f             	cmp    $0x1f,%eax
  80109d:	77 30                	ja     8010cf <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80109f:	c1 e0 0c             	shl    $0xc,%eax
  8010a2:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010a7:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8010ad:	f6 c2 01             	test   $0x1,%dl
  8010b0:	74 24                	je     8010d6 <fd_lookup+0x42>
  8010b2:	89 c2                	mov    %eax,%edx
  8010b4:	c1 ea 0c             	shr    $0xc,%edx
  8010b7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010be:	f6 c2 01             	test   $0x1,%dl
  8010c1:	74 1a                	je     8010dd <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010c6:	89 02                	mov    %eax,(%edx)
	return 0;
  8010c8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010cd:	5d                   	pop    %ebp
  8010ce:	c3                   	ret    
		return -E_INVAL;
  8010cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010d4:	eb f7                	jmp    8010cd <fd_lookup+0x39>
		return -E_INVAL;
  8010d6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010db:	eb f0                	jmp    8010cd <fd_lookup+0x39>
  8010dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010e2:	eb e9                	jmp    8010cd <fd_lookup+0x39>

008010e4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	53                   	push   %ebx
  8010e8:	83 ec 04             	sub    $0x4,%esp
  8010eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ee:	b8 b4 25 80 00       	mov    $0x8025b4,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  8010f3:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8010f8:	39 13                	cmp    %edx,(%ebx)
  8010fa:	74 32                	je     80112e <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  8010fc:	83 c0 04             	add    $0x4,%eax
  8010ff:	8b 18                	mov    (%eax),%ebx
  801101:	85 db                	test   %ebx,%ebx
  801103:	75 f3                	jne    8010f8 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801105:	a1 00 40 80 00       	mov    0x804000,%eax
  80110a:	8b 40 48             	mov    0x48(%eax),%eax
  80110d:	83 ec 04             	sub    $0x4,%esp
  801110:	52                   	push   %edx
  801111:	50                   	push   %eax
  801112:	68 38 25 80 00       	push   $0x802538
  801117:	e8 bc f0 ff ff       	call   8001d8 <cprintf>
	*dev = 0;
	return -E_INVAL;
  80111c:	83 c4 10             	add    $0x10,%esp
  80111f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801124:	8b 55 0c             	mov    0xc(%ebp),%edx
  801127:	89 1a                	mov    %ebx,(%edx)
}
  801129:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80112c:	c9                   	leave  
  80112d:	c3                   	ret    
			return 0;
  80112e:	b8 00 00 00 00       	mov    $0x0,%eax
  801133:	eb ef                	jmp    801124 <dev_lookup+0x40>

00801135 <fd_close>:
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	57                   	push   %edi
  801139:	56                   	push   %esi
  80113a:	53                   	push   %ebx
  80113b:	83 ec 24             	sub    $0x24,%esp
  80113e:	8b 75 08             	mov    0x8(%ebp),%esi
  801141:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801144:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801147:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801148:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80114e:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801151:	50                   	push   %eax
  801152:	e8 3d ff ff ff       	call   801094 <fd_lookup>
  801157:	89 c3                	mov    %eax,%ebx
  801159:	83 c4 10             	add    $0x10,%esp
  80115c:	85 c0                	test   %eax,%eax
  80115e:	78 05                	js     801165 <fd_close+0x30>
	    || fd != fd2)
  801160:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801163:	74 16                	je     80117b <fd_close+0x46>
		return (must_exist ? r : 0);
  801165:	89 f8                	mov    %edi,%eax
  801167:	84 c0                	test   %al,%al
  801169:	b8 00 00 00 00       	mov    $0x0,%eax
  80116e:	0f 44 d8             	cmove  %eax,%ebx
}
  801171:	89 d8                	mov    %ebx,%eax
  801173:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801176:	5b                   	pop    %ebx
  801177:	5e                   	pop    %esi
  801178:	5f                   	pop    %edi
  801179:	5d                   	pop    %ebp
  80117a:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80117b:	83 ec 08             	sub    $0x8,%esp
  80117e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801181:	50                   	push   %eax
  801182:	ff 36                	push   (%esi)
  801184:	e8 5b ff ff ff       	call   8010e4 <dev_lookup>
  801189:	89 c3                	mov    %eax,%ebx
  80118b:	83 c4 10             	add    $0x10,%esp
  80118e:	85 c0                	test   %eax,%eax
  801190:	78 1a                	js     8011ac <fd_close+0x77>
		if (dev->dev_close)
  801192:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801195:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801198:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80119d:	85 c0                	test   %eax,%eax
  80119f:	74 0b                	je     8011ac <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8011a1:	83 ec 0c             	sub    $0xc,%esp
  8011a4:	56                   	push   %esi
  8011a5:	ff d0                	call   *%eax
  8011a7:	89 c3                	mov    %eax,%ebx
  8011a9:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8011ac:	83 ec 08             	sub    $0x8,%esp
  8011af:	56                   	push   %esi
  8011b0:	6a 00                	push   $0x0
  8011b2:	e8 7c fa ff ff       	call   800c33 <sys_page_unmap>
	return r;
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	eb b5                	jmp    801171 <fd_close+0x3c>

008011bc <close>:

int
close(int fdnum)
{
  8011bc:	55                   	push   %ebp
  8011bd:	89 e5                	mov    %esp,%ebp
  8011bf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c5:	50                   	push   %eax
  8011c6:	ff 75 08             	push   0x8(%ebp)
  8011c9:	e8 c6 fe ff ff       	call   801094 <fd_lookup>
  8011ce:	83 c4 10             	add    $0x10,%esp
  8011d1:	85 c0                	test   %eax,%eax
  8011d3:	79 02                	jns    8011d7 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8011d5:	c9                   	leave  
  8011d6:	c3                   	ret    
		return fd_close(fd, 1);
  8011d7:	83 ec 08             	sub    $0x8,%esp
  8011da:	6a 01                	push   $0x1
  8011dc:	ff 75 f4             	push   -0xc(%ebp)
  8011df:	e8 51 ff ff ff       	call   801135 <fd_close>
  8011e4:	83 c4 10             	add    $0x10,%esp
  8011e7:	eb ec                	jmp    8011d5 <close+0x19>

008011e9 <close_all>:

void
close_all(void)
{
  8011e9:	55                   	push   %ebp
  8011ea:	89 e5                	mov    %esp,%ebp
  8011ec:	53                   	push   %ebx
  8011ed:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011f0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011f5:	83 ec 0c             	sub    $0xc,%esp
  8011f8:	53                   	push   %ebx
  8011f9:	e8 be ff ff ff       	call   8011bc <close>
	for (i = 0; i < MAXFD; i++)
  8011fe:	83 c3 01             	add    $0x1,%ebx
  801201:	83 c4 10             	add    $0x10,%esp
  801204:	83 fb 20             	cmp    $0x20,%ebx
  801207:	75 ec                	jne    8011f5 <close_all+0xc>
}
  801209:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80120c:	c9                   	leave  
  80120d:	c3                   	ret    

0080120e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	57                   	push   %edi
  801212:	56                   	push   %esi
  801213:	53                   	push   %ebx
  801214:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801217:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80121a:	50                   	push   %eax
  80121b:	ff 75 08             	push   0x8(%ebp)
  80121e:	e8 71 fe ff ff       	call   801094 <fd_lookup>
  801223:	89 c3                	mov    %eax,%ebx
  801225:	83 c4 10             	add    $0x10,%esp
  801228:	85 c0                	test   %eax,%eax
  80122a:	78 7f                	js     8012ab <dup+0x9d>
		return r;
	close(newfdnum);
  80122c:	83 ec 0c             	sub    $0xc,%esp
  80122f:	ff 75 0c             	push   0xc(%ebp)
  801232:	e8 85 ff ff ff       	call   8011bc <close>

	newfd = INDEX2FD(newfdnum);
  801237:	8b 75 0c             	mov    0xc(%ebp),%esi
  80123a:	c1 e6 0c             	shl    $0xc,%esi
  80123d:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801243:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801246:	89 3c 24             	mov    %edi,(%esp)
  801249:	e8 df fd ff ff       	call   80102d <fd2data>
  80124e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801250:	89 34 24             	mov    %esi,(%esp)
  801253:	e8 d5 fd ff ff       	call   80102d <fd2data>
  801258:	83 c4 10             	add    $0x10,%esp
  80125b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80125e:	89 d8                	mov    %ebx,%eax
  801260:	c1 e8 16             	shr    $0x16,%eax
  801263:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80126a:	a8 01                	test   $0x1,%al
  80126c:	74 11                	je     80127f <dup+0x71>
  80126e:	89 d8                	mov    %ebx,%eax
  801270:	c1 e8 0c             	shr    $0xc,%eax
  801273:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80127a:	f6 c2 01             	test   $0x1,%dl
  80127d:	75 36                	jne    8012b5 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80127f:	89 f8                	mov    %edi,%eax
  801281:	c1 e8 0c             	shr    $0xc,%eax
  801284:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80128b:	83 ec 0c             	sub    $0xc,%esp
  80128e:	25 07 0e 00 00       	and    $0xe07,%eax
  801293:	50                   	push   %eax
  801294:	56                   	push   %esi
  801295:	6a 00                	push   $0x0
  801297:	57                   	push   %edi
  801298:	6a 00                	push   $0x0
  80129a:	e8 52 f9 ff ff       	call   800bf1 <sys_page_map>
  80129f:	89 c3                	mov    %eax,%ebx
  8012a1:	83 c4 20             	add    $0x20,%esp
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	78 33                	js     8012db <dup+0xcd>
		goto err;

	return newfdnum;
  8012a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8012ab:	89 d8                	mov    %ebx,%eax
  8012ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012b0:	5b                   	pop    %ebx
  8012b1:	5e                   	pop    %esi
  8012b2:	5f                   	pop    %edi
  8012b3:	5d                   	pop    %ebp
  8012b4:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012b5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012bc:	83 ec 0c             	sub    $0xc,%esp
  8012bf:	25 07 0e 00 00       	and    $0xe07,%eax
  8012c4:	50                   	push   %eax
  8012c5:	ff 75 d4             	push   -0x2c(%ebp)
  8012c8:	6a 00                	push   $0x0
  8012ca:	53                   	push   %ebx
  8012cb:	6a 00                	push   $0x0
  8012cd:	e8 1f f9 ff ff       	call   800bf1 <sys_page_map>
  8012d2:	89 c3                	mov    %eax,%ebx
  8012d4:	83 c4 20             	add    $0x20,%esp
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	79 a4                	jns    80127f <dup+0x71>
	sys_page_unmap(0, newfd);
  8012db:	83 ec 08             	sub    $0x8,%esp
  8012de:	56                   	push   %esi
  8012df:	6a 00                	push   $0x0
  8012e1:	e8 4d f9 ff ff       	call   800c33 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012e6:	83 c4 08             	add    $0x8,%esp
  8012e9:	ff 75 d4             	push   -0x2c(%ebp)
  8012ec:	6a 00                	push   $0x0
  8012ee:	e8 40 f9 ff ff       	call   800c33 <sys_page_unmap>
	return r;
  8012f3:	83 c4 10             	add    $0x10,%esp
  8012f6:	eb b3                	jmp    8012ab <dup+0x9d>

008012f8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	56                   	push   %esi
  8012fc:	53                   	push   %ebx
  8012fd:	83 ec 18             	sub    $0x18,%esp
  801300:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801303:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801306:	50                   	push   %eax
  801307:	56                   	push   %esi
  801308:	e8 87 fd ff ff       	call   801094 <fd_lookup>
  80130d:	83 c4 10             	add    $0x10,%esp
  801310:	85 c0                	test   %eax,%eax
  801312:	78 3c                	js     801350 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801314:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801317:	83 ec 08             	sub    $0x8,%esp
  80131a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131d:	50                   	push   %eax
  80131e:	ff 33                	push   (%ebx)
  801320:	e8 bf fd ff ff       	call   8010e4 <dev_lookup>
  801325:	83 c4 10             	add    $0x10,%esp
  801328:	85 c0                	test   %eax,%eax
  80132a:	78 24                	js     801350 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80132c:	8b 43 08             	mov    0x8(%ebx),%eax
  80132f:	83 e0 03             	and    $0x3,%eax
  801332:	83 f8 01             	cmp    $0x1,%eax
  801335:	74 20                	je     801357 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801337:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133a:	8b 40 08             	mov    0x8(%eax),%eax
  80133d:	85 c0                	test   %eax,%eax
  80133f:	74 37                	je     801378 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801341:	83 ec 04             	sub    $0x4,%esp
  801344:	ff 75 10             	push   0x10(%ebp)
  801347:	ff 75 0c             	push   0xc(%ebp)
  80134a:	53                   	push   %ebx
  80134b:	ff d0                	call   *%eax
  80134d:	83 c4 10             	add    $0x10,%esp
}
  801350:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801353:	5b                   	pop    %ebx
  801354:	5e                   	pop    %esi
  801355:	5d                   	pop    %ebp
  801356:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801357:	a1 00 40 80 00       	mov    0x804000,%eax
  80135c:	8b 40 48             	mov    0x48(%eax),%eax
  80135f:	83 ec 04             	sub    $0x4,%esp
  801362:	56                   	push   %esi
  801363:	50                   	push   %eax
  801364:	68 79 25 80 00       	push   $0x802579
  801369:	e8 6a ee ff ff       	call   8001d8 <cprintf>
		return -E_INVAL;
  80136e:	83 c4 10             	add    $0x10,%esp
  801371:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801376:	eb d8                	jmp    801350 <read+0x58>
		return -E_NOT_SUPP;
  801378:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80137d:	eb d1                	jmp    801350 <read+0x58>

0080137f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80137f:	55                   	push   %ebp
  801380:	89 e5                	mov    %esp,%ebp
  801382:	57                   	push   %edi
  801383:	56                   	push   %esi
  801384:	53                   	push   %ebx
  801385:	83 ec 0c             	sub    $0xc,%esp
  801388:	8b 7d 08             	mov    0x8(%ebp),%edi
  80138b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80138e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801393:	eb 02                	jmp    801397 <readn+0x18>
  801395:	01 c3                	add    %eax,%ebx
  801397:	39 f3                	cmp    %esi,%ebx
  801399:	73 21                	jae    8013bc <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80139b:	83 ec 04             	sub    $0x4,%esp
  80139e:	89 f0                	mov    %esi,%eax
  8013a0:	29 d8                	sub    %ebx,%eax
  8013a2:	50                   	push   %eax
  8013a3:	89 d8                	mov    %ebx,%eax
  8013a5:	03 45 0c             	add    0xc(%ebp),%eax
  8013a8:	50                   	push   %eax
  8013a9:	57                   	push   %edi
  8013aa:	e8 49 ff ff ff       	call   8012f8 <read>
		if (m < 0)
  8013af:	83 c4 10             	add    $0x10,%esp
  8013b2:	85 c0                	test   %eax,%eax
  8013b4:	78 04                	js     8013ba <readn+0x3b>
			return m;
		if (m == 0)
  8013b6:	75 dd                	jne    801395 <readn+0x16>
  8013b8:	eb 02                	jmp    8013bc <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013ba:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8013bc:	89 d8                	mov    %ebx,%eax
  8013be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c1:	5b                   	pop    %ebx
  8013c2:	5e                   	pop    %esi
  8013c3:	5f                   	pop    %edi
  8013c4:	5d                   	pop    %ebp
  8013c5:	c3                   	ret    

008013c6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013c6:	55                   	push   %ebp
  8013c7:	89 e5                	mov    %esp,%ebp
  8013c9:	56                   	push   %esi
  8013ca:	53                   	push   %ebx
  8013cb:	83 ec 18             	sub    $0x18,%esp
  8013ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d4:	50                   	push   %eax
  8013d5:	53                   	push   %ebx
  8013d6:	e8 b9 fc ff ff       	call   801094 <fd_lookup>
  8013db:	83 c4 10             	add    $0x10,%esp
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	78 37                	js     801419 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8013e5:	83 ec 08             	sub    $0x8,%esp
  8013e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013eb:	50                   	push   %eax
  8013ec:	ff 36                	push   (%esi)
  8013ee:	e8 f1 fc ff ff       	call   8010e4 <dev_lookup>
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	85 c0                	test   %eax,%eax
  8013f8:	78 1f                	js     801419 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013fa:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8013fe:	74 20                	je     801420 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801400:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801403:	8b 40 0c             	mov    0xc(%eax),%eax
  801406:	85 c0                	test   %eax,%eax
  801408:	74 37                	je     801441 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80140a:	83 ec 04             	sub    $0x4,%esp
  80140d:	ff 75 10             	push   0x10(%ebp)
  801410:	ff 75 0c             	push   0xc(%ebp)
  801413:	56                   	push   %esi
  801414:	ff d0                	call   *%eax
  801416:	83 c4 10             	add    $0x10,%esp
}
  801419:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80141c:	5b                   	pop    %ebx
  80141d:	5e                   	pop    %esi
  80141e:	5d                   	pop    %ebp
  80141f:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801420:	a1 00 40 80 00       	mov    0x804000,%eax
  801425:	8b 40 48             	mov    0x48(%eax),%eax
  801428:	83 ec 04             	sub    $0x4,%esp
  80142b:	53                   	push   %ebx
  80142c:	50                   	push   %eax
  80142d:	68 95 25 80 00       	push   $0x802595
  801432:	e8 a1 ed ff ff       	call   8001d8 <cprintf>
		return -E_INVAL;
  801437:	83 c4 10             	add    $0x10,%esp
  80143a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80143f:	eb d8                	jmp    801419 <write+0x53>
		return -E_NOT_SUPP;
  801441:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801446:	eb d1                	jmp    801419 <write+0x53>

00801448 <seek>:

int
seek(int fdnum, off_t offset)
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80144e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801451:	50                   	push   %eax
  801452:	ff 75 08             	push   0x8(%ebp)
  801455:	e8 3a fc ff ff       	call   801094 <fd_lookup>
  80145a:	83 c4 10             	add    $0x10,%esp
  80145d:	85 c0                	test   %eax,%eax
  80145f:	78 0e                	js     80146f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801461:	8b 55 0c             	mov    0xc(%ebp),%edx
  801464:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801467:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80146a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80146f:	c9                   	leave  
  801470:	c3                   	ret    

00801471 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801471:	55                   	push   %ebp
  801472:	89 e5                	mov    %esp,%ebp
  801474:	56                   	push   %esi
  801475:	53                   	push   %ebx
  801476:	83 ec 18             	sub    $0x18,%esp
  801479:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80147c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80147f:	50                   	push   %eax
  801480:	53                   	push   %ebx
  801481:	e8 0e fc ff ff       	call   801094 <fd_lookup>
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	85 c0                	test   %eax,%eax
  80148b:	78 34                	js     8014c1 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80148d:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801490:	83 ec 08             	sub    $0x8,%esp
  801493:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801496:	50                   	push   %eax
  801497:	ff 36                	push   (%esi)
  801499:	e8 46 fc ff ff       	call   8010e4 <dev_lookup>
  80149e:	83 c4 10             	add    $0x10,%esp
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	78 1c                	js     8014c1 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014a5:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8014a9:	74 1d                	je     8014c8 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8014ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ae:	8b 40 18             	mov    0x18(%eax),%eax
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	74 34                	je     8014e9 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014b5:	83 ec 08             	sub    $0x8,%esp
  8014b8:	ff 75 0c             	push   0xc(%ebp)
  8014bb:	56                   	push   %esi
  8014bc:	ff d0                	call   *%eax
  8014be:	83 c4 10             	add    $0x10,%esp
}
  8014c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014c4:	5b                   	pop    %ebx
  8014c5:	5e                   	pop    %esi
  8014c6:	5d                   	pop    %ebp
  8014c7:	c3                   	ret    
			thisenv->env_id, fdnum);
  8014c8:	a1 00 40 80 00       	mov    0x804000,%eax
  8014cd:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014d0:	83 ec 04             	sub    $0x4,%esp
  8014d3:	53                   	push   %ebx
  8014d4:	50                   	push   %eax
  8014d5:	68 58 25 80 00       	push   $0x802558
  8014da:	e8 f9 ec ff ff       	call   8001d8 <cprintf>
		return -E_INVAL;
  8014df:	83 c4 10             	add    $0x10,%esp
  8014e2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014e7:	eb d8                	jmp    8014c1 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8014e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014ee:	eb d1                	jmp    8014c1 <ftruncate+0x50>

008014f0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8014f0:	55                   	push   %ebp
  8014f1:	89 e5                	mov    %esp,%ebp
  8014f3:	56                   	push   %esi
  8014f4:	53                   	push   %ebx
  8014f5:	83 ec 18             	sub    $0x18,%esp
  8014f8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014fb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014fe:	50                   	push   %eax
  8014ff:	ff 75 08             	push   0x8(%ebp)
  801502:	e8 8d fb ff ff       	call   801094 <fd_lookup>
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	85 c0                	test   %eax,%eax
  80150c:	78 49                	js     801557 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80150e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801511:	83 ec 08             	sub    $0x8,%esp
  801514:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801517:	50                   	push   %eax
  801518:	ff 36                	push   (%esi)
  80151a:	e8 c5 fb ff ff       	call   8010e4 <dev_lookup>
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	85 c0                	test   %eax,%eax
  801524:	78 31                	js     801557 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801526:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801529:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80152d:	74 2f                	je     80155e <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80152f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801532:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801539:	00 00 00 
	stat->st_isdir = 0;
  80153c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801543:	00 00 00 
	stat->st_dev = dev;
  801546:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80154c:	83 ec 08             	sub    $0x8,%esp
  80154f:	53                   	push   %ebx
  801550:	56                   	push   %esi
  801551:	ff 50 14             	call   *0x14(%eax)
  801554:	83 c4 10             	add    $0x10,%esp
}
  801557:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80155a:	5b                   	pop    %ebx
  80155b:	5e                   	pop    %esi
  80155c:	5d                   	pop    %ebp
  80155d:	c3                   	ret    
		return -E_NOT_SUPP;
  80155e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801563:	eb f2                	jmp    801557 <fstat+0x67>

00801565 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801565:	55                   	push   %ebp
  801566:	89 e5                	mov    %esp,%ebp
  801568:	56                   	push   %esi
  801569:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80156a:	83 ec 08             	sub    $0x8,%esp
  80156d:	6a 00                	push   $0x0
  80156f:	ff 75 08             	push   0x8(%ebp)
  801572:	e8 e4 01 00 00       	call   80175b <open>
  801577:	89 c3                	mov    %eax,%ebx
  801579:	83 c4 10             	add    $0x10,%esp
  80157c:	85 c0                	test   %eax,%eax
  80157e:	78 1b                	js     80159b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801580:	83 ec 08             	sub    $0x8,%esp
  801583:	ff 75 0c             	push   0xc(%ebp)
  801586:	50                   	push   %eax
  801587:	e8 64 ff ff ff       	call   8014f0 <fstat>
  80158c:	89 c6                	mov    %eax,%esi
	close(fd);
  80158e:	89 1c 24             	mov    %ebx,(%esp)
  801591:	e8 26 fc ff ff       	call   8011bc <close>
	return r;
  801596:	83 c4 10             	add    $0x10,%esp
  801599:	89 f3                	mov    %esi,%ebx
}
  80159b:	89 d8                	mov    %ebx,%eax
  80159d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a0:	5b                   	pop    %ebx
  8015a1:	5e                   	pop    %esi
  8015a2:	5d                   	pop    %ebp
  8015a3:	c3                   	ret    

008015a4 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	56                   	push   %esi
  8015a8:	53                   	push   %ebx
  8015a9:	89 c6                	mov    %eax,%esi
  8015ab:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015ad:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8015b4:	74 27                	je     8015dd <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015b6:	6a 07                	push   $0x7
  8015b8:	68 00 50 80 00       	push   $0x805000
  8015bd:	56                   	push   %esi
  8015be:	ff 35 00 60 80 00    	push   0x806000
  8015c4:	e8 3e 08 00 00       	call   801e07 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015c9:	83 c4 0c             	add    $0xc,%esp
  8015cc:	6a 00                	push   $0x0
  8015ce:	53                   	push   %ebx
  8015cf:	6a 00                	push   $0x0
  8015d1:	e8 ca 07 00 00       	call   801da0 <ipc_recv>
}
  8015d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d9:	5b                   	pop    %ebx
  8015da:	5e                   	pop    %esi
  8015db:	5d                   	pop    %ebp
  8015dc:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8015dd:	83 ec 0c             	sub    $0xc,%esp
  8015e0:	6a 01                	push   $0x1
  8015e2:	e8 74 08 00 00       	call   801e5b <ipc_find_env>
  8015e7:	a3 00 60 80 00       	mov    %eax,0x806000
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	eb c5                	jmp    8015b6 <fsipc+0x12>

008015f1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8015f1:	55                   	push   %ebp
  8015f2:	89 e5                	mov    %esp,%ebp
  8015f4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8015f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8015fd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801602:	8b 45 0c             	mov    0xc(%ebp),%eax
  801605:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80160a:	ba 00 00 00 00       	mov    $0x0,%edx
  80160f:	b8 02 00 00 00       	mov    $0x2,%eax
  801614:	e8 8b ff ff ff       	call   8015a4 <fsipc>
}
  801619:	c9                   	leave  
  80161a:	c3                   	ret    

0080161b <devfile_flush>:
{
  80161b:	55                   	push   %ebp
  80161c:	89 e5                	mov    %esp,%ebp
  80161e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801621:	8b 45 08             	mov    0x8(%ebp),%eax
  801624:	8b 40 0c             	mov    0xc(%eax),%eax
  801627:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80162c:	ba 00 00 00 00       	mov    $0x0,%edx
  801631:	b8 06 00 00 00       	mov    $0x6,%eax
  801636:	e8 69 ff ff ff       	call   8015a4 <fsipc>
}
  80163b:	c9                   	leave  
  80163c:	c3                   	ret    

0080163d <devfile_stat>:
{
  80163d:	55                   	push   %ebp
  80163e:	89 e5                	mov    %esp,%ebp
  801640:	53                   	push   %ebx
  801641:	83 ec 04             	sub    $0x4,%esp
  801644:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801647:	8b 45 08             	mov    0x8(%ebp),%eax
  80164a:	8b 40 0c             	mov    0xc(%eax),%eax
  80164d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801652:	ba 00 00 00 00       	mov    $0x0,%edx
  801657:	b8 05 00 00 00       	mov    $0x5,%eax
  80165c:	e8 43 ff ff ff       	call   8015a4 <fsipc>
  801661:	85 c0                	test   %eax,%eax
  801663:	78 2c                	js     801691 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801665:	83 ec 08             	sub    $0x8,%esp
  801668:	68 00 50 80 00       	push   $0x805000
  80166d:	53                   	push   %ebx
  80166e:	e8 3f f1 ff ff       	call   8007b2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801673:	a1 80 50 80 00       	mov    0x805080,%eax
  801678:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80167e:	a1 84 50 80 00       	mov    0x805084,%eax
  801683:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801689:	83 c4 10             	add    $0x10,%esp
  80168c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801691:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801694:	c9                   	leave  
  801695:	c3                   	ret    

00801696 <devfile_write>:
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	83 ec 0c             	sub    $0xc,%esp
  80169c:	8b 45 10             	mov    0x10(%ebp),%eax
  80169f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8016a4:	39 d0                	cmp    %edx,%eax
  8016a6:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8016ac:	8b 52 0c             	mov    0xc(%edx),%edx
  8016af:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8016b5:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8016ba:	50                   	push   %eax
  8016bb:	ff 75 0c             	push   0xc(%ebp)
  8016be:	68 08 50 80 00       	push   $0x805008
  8016c3:	e8 80 f2 ff ff       	call   800948 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8016c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cd:	b8 04 00 00 00       	mov    $0x4,%eax
  8016d2:	e8 cd fe ff ff       	call   8015a4 <fsipc>
}
  8016d7:	c9                   	leave  
  8016d8:	c3                   	ret    

008016d9 <devfile_read>:
{
  8016d9:	55                   	push   %ebp
  8016da:	89 e5                	mov    %esp,%ebp
  8016dc:	56                   	push   %esi
  8016dd:	53                   	push   %ebx
  8016de:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8016e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8016ec:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8016f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8016fc:	e8 a3 fe ff ff       	call   8015a4 <fsipc>
  801701:	89 c3                	mov    %eax,%ebx
  801703:	85 c0                	test   %eax,%eax
  801705:	78 1f                	js     801726 <devfile_read+0x4d>
	assert(r <= n);
  801707:	39 f0                	cmp    %esi,%eax
  801709:	77 24                	ja     80172f <devfile_read+0x56>
	assert(r <= PGSIZE);
  80170b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801710:	7f 33                	jg     801745 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801712:	83 ec 04             	sub    $0x4,%esp
  801715:	50                   	push   %eax
  801716:	68 00 50 80 00       	push   $0x805000
  80171b:	ff 75 0c             	push   0xc(%ebp)
  80171e:	e8 25 f2 ff ff       	call   800948 <memmove>
	return r;
  801723:	83 c4 10             	add    $0x10,%esp
}
  801726:	89 d8                	mov    %ebx,%eax
  801728:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80172b:	5b                   	pop    %ebx
  80172c:	5e                   	pop    %esi
  80172d:	5d                   	pop    %ebp
  80172e:	c3                   	ret    
	assert(r <= n);
  80172f:	68 c4 25 80 00       	push   $0x8025c4
  801734:	68 cb 25 80 00       	push   $0x8025cb
  801739:	6a 7c                	push   $0x7c
  80173b:	68 e0 25 80 00       	push   $0x8025e0
  801740:	e8 79 05 00 00       	call   801cbe <_panic>
	assert(r <= PGSIZE);
  801745:	68 eb 25 80 00       	push   $0x8025eb
  80174a:	68 cb 25 80 00       	push   $0x8025cb
  80174f:	6a 7d                	push   $0x7d
  801751:	68 e0 25 80 00       	push   $0x8025e0
  801756:	e8 63 05 00 00       	call   801cbe <_panic>

0080175b <open>:
{
  80175b:	55                   	push   %ebp
  80175c:	89 e5                	mov    %esp,%ebp
  80175e:	56                   	push   %esi
  80175f:	53                   	push   %ebx
  801760:	83 ec 1c             	sub    $0x1c,%esp
  801763:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801766:	56                   	push   %esi
  801767:	e8 0b f0 ff ff       	call   800777 <strlen>
  80176c:	83 c4 10             	add    $0x10,%esp
  80176f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801774:	7f 6c                	jg     8017e2 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801776:	83 ec 0c             	sub    $0xc,%esp
  801779:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80177c:	50                   	push   %eax
  80177d:	e8 c2 f8 ff ff       	call   801044 <fd_alloc>
  801782:	89 c3                	mov    %eax,%ebx
  801784:	83 c4 10             	add    $0x10,%esp
  801787:	85 c0                	test   %eax,%eax
  801789:	78 3c                	js     8017c7 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80178b:	83 ec 08             	sub    $0x8,%esp
  80178e:	56                   	push   %esi
  80178f:	68 00 50 80 00       	push   $0x805000
  801794:	e8 19 f0 ff ff       	call   8007b2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801799:	8b 45 0c             	mov    0xc(%ebp),%eax
  80179c:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8017a9:	e8 f6 fd ff ff       	call   8015a4 <fsipc>
  8017ae:	89 c3                	mov    %eax,%ebx
  8017b0:	83 c4 10             	add    $0x10,%esp
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	78 19                	js     8017d0 <open+0x75>
	return fd2num(fd);
  8017b7:	83 ec 0c             	sub    $0xc,%esp
  8017ba:	ff 75 f4             	push   -0xc(%ebp)
  8017bd:	e8 5b f8 ff ff       	call   80101d <fd2num>
  8017c2:	89 c3                	mov    %eax,%ebx
  8017c4:	83 c4 10             	add    $0x10,%esp
}
  8017c7:	89 d8                	mov    %ebx,%eax
  8017c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017cc:	5b                   	pop    %ebx
  8017cd:	5e                   	pop    %esi
  8017ce:	5d                   	pop    %ebp
  8017cf:	c3                   	ret    
		fd_close(fd, 0);
  8017d0:	83 ec 08             	sub    $0x8,%esp
  8017d3:	6a 00                	push   $0x0
  8017d5:	ff 75 f4             	push   -0xc(%ebp)
  8017d8:	e8 58 f9 ff ff       	call   801135 <fd_close>
		return r;
  8017dd:	83 c4 10             	add    $0x10,%esp
  8017e0:	eb e5                	jmp    8017c7 <open+0x6c>
		return -E_BAD_PATH;
  8017e2:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8017e7:	eb de                	jmp    8017c7 <open+0x6c>

008017e9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f4:	b8 08 00 00 00       	mov    $0x8,%eax
  8017f9:	e8 a6 fd ff ff       	call   8015a4 <fsipc>
}
  8017fe:	c9                   	leave  
  8017ff:	c3                   	ret    

00801800 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	56                   	push   %esi
  801804:	53                   	push   %ebx
  801805:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801808:	83 ec 0c             	sub    $0xc,%esp
  80180b:	ff 75 08             	push   0x8(%ebp)
  80180e:	e8 1a f8 ff ff       	call   80102d <fd2data>
  801813:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801815:	83 c4 08             	add    $0x8,%esp
  801818:	68 f7 25 80 00       	push   $0x8025f7
  80181d:	53                   	push   %ebx
  80181e:	e8 8f ef ff ff       	call   8007b2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801823:	8b 46 04             	mov    0x4(%esi),%eax
  801826:	2b 06                	sub    (%esi),%eax
  801828:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80182e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801835:	00 00 00 
	stat->st_dev = &devpipe;
  801838:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80183f:	30 80 00 
	return 0;
}
  801842:	b8 00 00 00 00       	mov    $0x0,%eax
  801847:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80184a:	5b                   	pop    %ebx
  80184b:	5e                   	pop    %esi
  80184c:	5d                   	pop    %ebp
  80184d:	c3                   	ret    

0080184e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	53                   	push   %ebx
  801852:	83 ec 0c             	sub    $0xc,%esp
  801855:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801858:	53                   	push   %ebx
  801859:	6a 00                	push   $0x0
  80185b:	e8 d3 f3 ff ff       	call   800c33 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801860:	89 1c 24             	mov    %ebx,(%esp)
  801863:	e8 c5 f7 ff ff       	call   80102d <fd2data>
  801868:	83 c4 08             	add    $0x8,%esp
  80186b:	50                   	push   %eax
  80186c:	6a 00                	push   $0x0
  80186e:	e8 c0 f3 ff ff       	call   800c33 <sys_page_unmap>
}
  801873:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801876:	c9                   	leave  
  801877:	c3                   	ret    

00801878 <_pipeisclosed>:
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	57                   	push   %edi
  80187c:	56                   	push   %esi
  80187d:	53                   	push   %ebx
  80187e:	83 ec 1c             	sub    $0x1c,%esp
  801881:	89 c7                	mov    %eax,%edi
  801883:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801885:	a1 00 40 80 00       	mov    0x804000,%eax
  80188a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80188d:	83 ec 0c             	sub    $0xc,%esp
  801890:	57                   	push   %edi
  801891:	e8 fe 05 00 00       	call   801e94 <pageref>
  801896:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801899:	89 34 24             	mov    %esi,(%esp)
  80189c:	e8 f3 05 00 00       	call   801e94 <pageref>
		nn = thisenv->env_runs;
  8018a1:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8018a7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8018aa:	83 c4 10             	add    $0x10,%esp
  8018ad:	39 cb                	cmp    %ecx,%ebx
  8018af:	74 1b                	je     8018cc <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8018b1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8018b4:	75 cf                	jne    801885 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8018b6:	8b 42 58             	mov    0x58(%edx),%eax
  8018b9:	6a 01                	push   $0x1
  8018bb:	50                   	push   %eax
  8018bc:	53                   	push   %ebx
  8018bd:	68 fe 25 80 00       	push   $0x8025fe
  8018c2:	e8 11 e9 ff ff       	call   8001d8 <cprintf>
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	eb b9                	jmp    801885 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8018cc:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8018cf:	0f 94 c0             	sete   %al
  8018d2:	0f b6 c0             	movzbl %al,%eax
}
  8018d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018d8:	5b                   	pop    %ebx
  8018d9:	5e                   	pop    %esi
  8018da:	5f                   	pop    %edi
  8018db:	5d                   	pop    %ebp
  8018dc:	c3                   	ret    

008018dd <devpipe_write>:
{
  8018dd:	55                   	push   %ebp
  8018de:	89 e5                	mov    %esp,%ebp
  8018e0:	57                   	push   %edi
  8018e1:	56                   	push   %esi
  8018e2:	53                   	push   %ebx
  8018e3:	83 ec 28             	sub    $0x28,%esp
  8018e6:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8018e9:	56                   	push   %esi
  8018ea:	e8 3e f7 ff ff       	call   80102d <fd2data>
  8018ef:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8018f1:	83 c4 10             	add    $0x10,%esp
  8018f4:	bf 00 00 00 00       	mov    $0x0,%edi
  8018f9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8018fc:	75 09                	jne    801907 <devpipe_write+0x2a>
	return i;
  8018fe:	89 f8                	mov    %edi,%eax
  801900:	eb 23                	jmp    801925 <devpipe_write+0x48>
			sys_yield();
  801902:	e8 88 f2 ff ff       	call   800b8f <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801907:	8b 43 04             	mov    0x4(%ebx),%eax
  80190a:	8b 0b                	mov    (%ebx),%ecx
  80190c:	8d 51 20             	lea    0x20(%ecx),%edx
  80190f:	39 d0                	cmp    %edx,%eax
  801911:	72 1a                	jb     80192d <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801913:	89 da                	mov    %ebx,%edx
  801915:	89 f0                	mov    %esi,%eax
  801917:	e8 5c ff ff ff       	call   801878 <_pipeisclosed>
  80191c:	85 c0                	test   %eax,%eax
  80191e:	74 e2                	je     801902 <devpipe_write+0x25>
				return 0;
  801920:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801925:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801928:	5b                   	pop    %ebx
  801929:	5e                   	pop    %esi
  80192a:	5f                   	pop    %edi
  80192b:	5d                   	pop    %ebp
  80192c:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80192d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801930:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801934:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801937:	89 c2                	mov    %eax,%edx
  801939:	c1 fa 1f             	sar    $0x1f,%edx
  80193c:	89 d1                	mov    %edx,%ecx
  80193e:	c1 e9 1b             	shr    $0x1b,%ecx
  801941:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801944:	83 e2 1f             	and    $0x1f,%edx
  801947:	29 ca                	sub    %ecx,%edx
  801949:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80194d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801951:	83 c0 01             	add    $0x1,%eax
  801954:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801957:	83 c7 01             	add    $0x1,%edi
  80195a:	eb 9d                	jmp    8018f9 <devpipe_write+0x1c>

0080195c <devpipe_read>:
{
  80195c:	55                   	push   %ebp
  80195d:	89 e5                	mov    %esp,%ebp
  80195f:	57                   	push   %edi
  801960:	56                   	push   %esi
  801961:	53                   	push   %ebx
  801962:	83 ec 18             	sub    $0x18,%esp
  801965:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801968:	57                   	push   %edi
  801969:	e8 bf f6 ff ff       	call   80102d <fd2data>
  80196e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801970:	83 c4 10             	add    $0x10,%esp
  801973:	be 00 00 00 00       	mov    $0x0,%esi
  801978:	3b 75 10             	cmp    0x10(%ebp),%esi
  80197b:	75 13                	jne    801990 <devpipe_read+0x34>
	return i;
  80197d:	89 f0                	mov    %esi,%eax
  80197f:	eb 02                	jmp    801983 <devpipe_read+0x27>
				return i;
  801981:	89 f0                	mov    %esi,%eax
}
  801983:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801986:	5b                   	pop    %ebx
  801987:	5e                   	pop    %esi
  801988:	5f                   	pop    %edi
  801989:	5d                   	pop    %ebp
  80198a:	c3                   	ret    
			sys_yield();
  80198b:	e8 ff f1 ff ff       	call   800b8f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801990:	8b 03                	mov    (%ebx),%eax
  801992:	3b 43 04             	cmp    0x4(%ebx),%eax
  801995:	75 18                	jne    8019af <devpipe_read+0x53>
			if (i > 0)
  801997:	85 f6                	test   %esi,%esi
  801999:	75 e6                	jne    801981 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  80199b:	89 da                	mov    %ebx,%edx
  80199d:	89 f8                	mov    %edi,%eax
  80199f:	e8 d4 fe ff ff       	call   801878 <_pipeisclosed>
  8019a4:	85 c0                	test   %eax,%eax
  8019a6:	74 e3                	je     80198b <devpipe_read+0x2f>
				return 0;
  8019a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ad:	eb d4                	jmp    801983 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019af:	99                   	cltd   
  8019b0:	c1 ea 1b             	shr    $0x1b,%edx
  8019b3:	01 d0                	add    %edx,%eax
  8019b5:	83 e0 1f             	and    $0x1f,%eax
  8019b8:	29 d0                	sub    %edx,%eax
  8019ba:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8019bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8019c2:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8019c5:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8019c8:	83 c6 01             	add    $0x1,%esi
  8019cb:	eb ab                	jmp    801978 <devpipe_read+0x1c>

008019cd <pipe>:
{
  8019cd:	55                   	push   %ebp
  8019ce:	89 e5                	mov    %esp,%ebp
  8019d0:	56                   	push   %esi
  8019d1:	53                   	push   %ebx
  8019d2:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8019d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d8:	50                   	push   %eax
  8019d9:	e8 66 f6 ff ff       	call   801044 <fd_alloc>
  8019de:	89 c3                	mov    %eax,%ebx
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	85 c0                	test   %eax,%eax
  8019e5:	0f 88 23 01 00 00    	js     801b0e <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019eb:	83 ec 04             	sub    $0x4,%esp
  8019ee:	68 07 04 00 00       	push   $0x407
  8019f3:	ff 75 f4             	push   -0xc(%ebp)
  8019f6:	6a 00                	push   $0x0
  8019f8:	e8 b1 f1 ff ff       	call   800bae <sys_page_alloc>
  8019fd:	89 c3                	mov    %eax,%ebx
  8019ff:	83 c4 10             	add    $0x10,%esp
  801a02:	85 c0                	test   %eax,%eax
  801a04:	0f 88 04 01 00 00    	js     801b0e <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801a0a:	83 ec 0c             	sub    $0xc,%esp
  801a0d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a10:	50                   	push   %eax
  801a11:	e8 2e f6 ff ff       	call   801044 <fd_alloc>
  801a16:	89 c3                	mov    %eax,%ebx
  801a18:	83 c4 10             	add    $0x10,%esp
  801a1b:	85 c0                	test   %eax,%eax
  801a1d:	0f 88 db 00 00 00    	js     801afe <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a23:	83 ec 04             	sub    $0x4,%esp
  801a26:	68 07 04 00 00       	push   $0x407
  801a2b:	ff 75 f0             	push   -0x10(%ebp)
  801a2e:	6a 00                	push   $0x0
  801a30:	e8 79 f1 ff ff       	call   800bae <sys_page_alloc>
  801a35:	89 c3                	mov    %eax,%ebx
  801a37:	83 c4 10             	add    $0x10,%esp
  801a3a:	85 c0                	test   %eax,%eax
  801a3c:	0f 88 bc 00 00 00    	js     801afe <pipe+0x131>
	va = fd2data(fd0);
  801a42:	83 ec 0c             	sub    $0xc,%esp
  801a45:	ff 75 f4             	push   -0xc(%ebp)
  801a48:	e8 e0 f5 ff ff       	call   80102d <fd2data>
  801a4d:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a4f:	83 c4 0c             	add    $0xc,%esp
  801a52:	68 07 04 00 00       	push   $0x407
  801a57:	50                   	push   %eax
  801a58:	6a 00                	push   $0x0
  801a5a:	e8 4f f1 ff ff       	call   800bae <sys_page_alloc>
  801a5f:	89 c3                	mov    %eax,%ebx
  801a61:	83 c4 10             	add    $0x10,%esp
  801a64:	85 c0                	test   %eax,%eax
  801a66:	0f 88 82 00 00 00    	js     801aee <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a6c:	83 ec 0c             	sub    $0xc,%esp
  801a6f:	ff 75 f0             	push   -0x10(%ebp)
  801a72:	e8 b6 f5 ff ff       	call   80102d <fd2data>
  801a77:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801a7e:	50                   	push   %eax
  801a7f:	6a 00                	push   $0x0
  801a81:	56                   	push   %esi
  801a82:	6a 00                	push   $0x0
  801a84:	e8 68 f1 ff ff       	call   800bf1 <sys_page_map>
  801a89:	89 c3                	mov    %eax,%ebx
  801a8b:	83 c4 20             	add    $0x20,%esp
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	78 4e                	js     801ae0 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801a92:	a1 20 30 80 00       	mov    0x803020,%eax
  801a97:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a9a:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801a9c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a9f:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801aa6:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801aa9:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801aab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801aae:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801ab5:	83 ec 0c             	sub    $0xc,%esp
  801ab8:	ff 75 f4             	push   -0xc(%ebp)
  801abb:	e8 5d f5 ff ff       	call   80101d <fd2num>
  801ac0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ac3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ac5:	83 c4 04             	add    $0x4,%esp
  801ac8:	ff 75 f0             	push   -0x10(%ebp)
  801acb:	e8 4d f5 ff ff       	call   80101d <fd2num>
  801ad0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ad3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ad6:	83 c4 10             	add    $0x10,%esp
  801ad9:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ade:	eb 2e                	jmp    801b0e <pipe+0x141>
	sys_page_unmap(0, va);
  801ae0:	83 ec 08             	sub    $0x8,%esp
  801ae3:	56                   	push   %esi
  801ae4:	6a 00                	push   $0x0
  801ae6:	e8 48 f1 ff ff       	call   800c33 <sys_page_unmap>
  801aeb:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801aee:	83 ec 08             	sub    $0x8,%esp
  801af1:	ff 75 f0             	push   -0x10(%ebp)
  801af4:	6a 00                	push   $0x0
  801af6:	e8 38 f1 ff ff       	call   800c33 <sys_page_unmap>
  801afb:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801afe:	83 ec 08             	sub    $0x8,%esp
  801b01:	ff 75 f4             	push   -0xc(%ebp)
  801b04:	6a 00                	push   $0x0
  801b06:	e8 28 f1 ff ff       	call   800c33 <sys_page_unmap>
  801b0b:	83 c4 10             	add    $0x10,%esp
}
  801b0e:	89 d8                	mov    %ebx,%eax
  801b10:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b13:	5b                   	pop    %ebx
  801b14:	5e                   	pop    %esi
  801b15:	5d                   	pop    %ebp
  801b16:	c3                   	ret    

00801b17 <pipeisclosed>:
{
  801b17:	55                   	push   %ebp
  801b18:	89 e5                	mov    %esp,%ebp
  801b1a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b20:	50                   	push   %eax
  801b21:	ff 75 08             	push   0x8(%ebp)
  801b24:	e8 6b f5 ff ff       	call   801094 <fd_lookup>
  801b29:	83 c4 10             	add    $0x10,%esp
  801b2c:	85 c0                	test   %eax,%eax
  801b2e:	78 18                	js     801b48 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801b30:	83 ec 0c             	sub    $0xc,%esp
  801b33:	ff 75 f4             	push   -0xc(%ebp)
  801b36:	e8 f2 f4 ff ff       	call   80102d <fd2data>
  801b3b:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b40:	e8 33 fd ff ff       	call   801878 <_pipeisclosed>
  801b45:	83 c4 10             	add    $0x10,%esp
}
  801b48:	c9                   	leave  
  801b49:	c3                   	ret    

00801b4a <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801b4a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4f:	c3                   	ret    

00801b50 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801b56:	68 16 26 80 00       	push   $0x802616
  801b5b:	ff 75 0c             	push   0xc(%ebp)
  801b5e:	e8 4f ec ff ff       	call   8007b2 <strcpy>
	return 0;
}
  801b63:	b8 00 00 00 00       	mov    $0x0,%eax
  801b68:	c9                   	leave  
  801b69:	c3                   	ret    

00801b6a <devcons_write>:
{
  801b6a:	55                   	push   %ebp
  801b6b:	89 e5                	mov    %esp,%ebp
  801b6d:	57                   	push   %edi
  801b6e:	56                   	push   %esi
  801b6f:	53                   	push   %ebx
  801b70:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801b76:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801b7b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801b81:	eb 2e                	jmp    801bb1 <devcons_write+0x47>
		m = n - tot;
  801b83:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b86:	29 f3                	sub    %esi,%ebx
  801b88:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801b8d:	39 c3                	cmp    %eax,%ebx
  801b8f:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801b92:	83 ec 04             	sub    $0x4,%esp
  801b95:	53                   	push   %ebx
  801b96:	89 f0                	mov    %esi,%eax
  801b98:	03 45 0c             	add    0xc(%ebp),%eax
  801b9b:	50                   	push   %eax
  801b9c:	57                   	push   %edi
  801b9d:	e8 a6 ed ff ff       	call   800948 <memmove>
		sys_cputs(buf, m);
  801ba2:	83 c4 08             	add    $0x8,%esp
  801ba5:	53                   	push   %ebx
  801ba6:	57                   	push   %edi
  801ba7:	e8 46 ef ff ff       	call   800af2 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801bac:	01 de                	add    %ebx,%esi
  801bae:	83 c4 10             	add    $0x10,%esp
  801bb1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801bb4:	72 cd                	jb     801b83 <devcons_write+0x19>
}
  801bb6:	89 f0                	mov    %esi,%eax
  801bb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bbb:	5b                   	pop    %ebx
  801bbc:	5e                   	pop    %esi
  801bbd:	5f                   	pop    %edi
  801bbe:	5d                   	pop    %ebp
  801bbf:	c3                   	ret    

00801bc0 <devcons_read>:
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	83 ec 08             	sub    $0x8,%esp
  801bc6:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801bcb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801bcf:	75 07                	jne    801bd8 <devcons_read+0x18>
  801bd1:	eb 1f                	jmp    801bf2 <devcons_read+0x32>
		sys_yield();
  801bd3:	e8 b7 ef ff ff       	call   800b8f <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801bd8:	e8 33 ef ff ff       	call   800b10 <sys_cgetc>
  801bdd:	85 c0                	test   %eax,%eax
  801bdf:	74 f2                	je     801bd3 <devcons_read+0x13>
	if (c < 0)
  801be1:	78 0f                	js     801bf2 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801be3:	83 f8 04             	cmp    $0x4,%eax
  801be6:	74 0c                	je     801bf4 <devcons_read+0x34>
	*(char*)vbuf = c;
  801be8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801beb:	88 02                	mov    %al,(%edx)
	return 1;
  801bed:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801bf2:	c9                   	leave  
  801bf3:	c3                   	ret    
		return 0;
  801bf4:	b8 00 00 00 00       	mov    $0x0,%eax
  801bf9:	eb f7                	jmp    801bf2 <devcons_read+0x32>

00801bfb <cputchar>:
{
  801bfb:	55                   	push   %ebp
  801bfc:	89 e5                	mov    %esp,%ebp
  801bfe:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c01:	8b 45 08             	mov    0x8(%ebp),%eax
  801c04:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801c07:	6a 01                	push   $0x1
  801c09:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c0c:	50                   	push   %eax
  801c0d:	e8 e0 ee ff ff       	call   800af2 <sys_cputs>
}
  801c12:	83 c4 10             	add    $0x10,%esp
  801c15:	c9                   	leave  
  801c16:	c3                   	ret    

00801c17 <getchar>:
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801c1d:	6a 01                	push   $0x1
  801c1f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c22:	50                   	push   %eax
  801c23:	6a 00                	push   $0x0
  801c25:	e8 ce f6 ff ff       	call   8012f8 <read>
	if (r < 0)
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	78 06                	js     801c37 <getchar+0x20>
	if (r < 1)
  801c31:	74 06                	je     801c39 <getchar+0x22>
	return c;
  801c33:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801c37:	c9                   	leave  
  801c38:	c3                   	ret    
		return -E_EOF;
  801c39:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801c3e:	eb f7                	jmp    801c37 <getchar+0x20>

00801c40 <iscons>:
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c49:	50                   	push   %eax
  801c4a:	ff 75 08             	push   0x8(%ebp)
  801c4d:	e8 42 f4 ff ff       	call   801094 <fd_lookup>
  801c52:	83 c4 10             	add    $0x10,%esp
  801c55:	85 c0                	test   %eax,%eax
  801c57:	78 11                	js     801c6a <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c5c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c62:	39 10                	cmp    %edx,(%eax)
  801c64:	0f 94 c0             	sete   %al
  801c67:	0f b6 c0             	movzbl %al,%eax
}
  801c6a:	c9                   	leave  
  801c6b:	c3                   	ret    

00801c6c <opencons>:
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801c72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c75:	50                   	push   %eax
  801c76:	e8 c9 f3 ff ff       	call   801044 <fd_alloc>
  801c7b:	83 c4 10             	add    $0x10,%esp
  801c7e:	85 c0                	test   %eax,%eax
  801c80:	78 3a                	js     801cbc <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801c82:	83 ec 04             	sub    $0x4,%esp
  801c85:	68 07 04 00 00       	push   $0x407
  801c8a:	ff 75 f4             	push   -0xc(%ebp)
  801c8d:	6a 00                	push   $0x0
  801c8f:	e8 1a ef ff ff       	call   800bae <sys_page_alloc>
  801c94:	83 c4 10             	add    $0x10,%esp
  801c97:	85 c0                	test   %eax,%eax
  801c99:	78 21                	js     801cbc <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ca4:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801cb0:	83 ec 0c             	sub    $0xc,%esp
  801cb3:	50                   	push   %eax
  801cb4:	e8 64 f3 ff ff       	call   80101d <fd2num>
  801cb9:	83 c4 10             	add    $0x10,%esp
}
  801cbc:	c9                   	leave  
  801cbd:	c3                   	ret    

00801cbe <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801cbe:	55                   	push   %ebp
  801cbf:	89 e5                	mov    %esp,%ebp
  801cc1:	56                   	push   %esi
  801cc2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801cc3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801cc6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ccc:	e8 9f ee ff ff       	call   800b70 <sys_getenvid>
  801cd1:	83 ec 0c             	sub    $0xc,%esp
  801cd4:	ff 75 0c             	push   0xc(%ebp)
  801cd7:	ff 75 08             	push   0x8(%ebp)
  801cda:	56                   	push   %esi
  801cdb:	50                   	push   %eax
  801cdc:	68 24 26 80 00       	push   $0x802624
  801ce1:	e8 f2 e4 ff ff       	call   8001d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ce6:	83 c4 18             	add    $0x18,%esp
  801ce9:	53                   	push   %ebx
  801cea:	ff 75 10             	push   0x10(%ebp)
  801ced:	e8 95 e4 ff ff       	call   800187 <vcprintf>
	cprintf("\n");
  801cf2:	c7 04 24 2f 21 80 00 	movl   $0x80212f,(%esp)
  801cf9:	e8 da e4 ff ff       	call   8001d8 <cprintf>
  801cfe:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d01:	cc                   	int3   
  801d02:	eb fd                	jmp    801d01 <_panic+0x43>

00801d04 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d04:	55                   	push   %ebp
  801d05:	89 e5                	mov    %esp,%ebp
  801d07:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  801d0a:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  801d11:	74 0a                	je     801d1d <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801d13:	8b 45 08             	mov    0x8(%ebp),%eax
  801d16:	a3 04 60 80 00       	mov    %eax,0x806004
}
  801d1b:	c9                   	leave  
  801d1c:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  801d1d:	e8 4e ee ff ff       	call   800b70 <sys_getenvid>
  801d22:	83 ec 04             	sub    $0x4,%esp
  801d25:	68 07 0e 00 00       	push   $0xe07
  801d2a:	68 00 f0 bf ee       	push   $0xeebff000
  801d2f:	50                   	push   %eax
  801d30:	e8 79 ee ff ff       	call   800bae <sys_page_alloc>
		if (r < 0) {
  801d35:	83 c4 10             	add    $0x10,%esp
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	78 2c                	js     801d68 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801d3c:	e8 2f ee ff ff       	call   800b70 <sys_getenvid>
  801d41:	83 ec 08             	sub    $0x8,%esp
  801d44:	68 7a 1d 80 00       	push   $0x801d7a
  801d49:	50                   	push   %eax
  801d4a:	e8 aa ef ff ff       	call   800cf9 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801d4f:	83 c4 10             	add    $0x10,%esp
  801d52:	85 c0                	test   %eax,%eax
  801d54:	79 bd                	jns    801d13 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  801d56:	50                   	push   %eax
  801d57:	68 88 26 80 00       	push   $0x802688
  801d5c:	6a 28                	push   $0x28
  801d5e:	68 be 26 80 00       	push   $0x8026be
  801d63:	e8 56 ff ff ff       	call   801cbe <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  801d68:	50                   	push   %eax
  801d69:	68 48 26 80 00       	push   $0x802648
  801d6e:	6a 23                	push   $0x23
  801d70:	68 be 26 80 00       	push   $0x8026be
  801d75:	e8 44 ff ff ff       	call   801cbe <_panic>

00801d7a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801d7a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801d7b:	a1 04 60 80 00       	mov    0x806004,%eax
	call *%eax
  801d80:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801d82:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  801d85:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  801d89:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  801d8c:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  801d90:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  801d94:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  801d96:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  801d99:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  801d9a:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  801d9d:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  801d9e:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  801d9f:	c3                   	ret    

00801da0 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801da0:	55                   	push   %ebp
  801da1:	89 e5                	mov    %esp,%ebp
  801da3:	56                   	push   %esi
  801da4:	53                   	push   %ebx
  801da5:	8b 75 08             	mov    0x8(%ebp),%esi
  801da8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801dae:	85 c0                	test   %eax,%eax
  801db0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801db5:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801db8:	83 ec 0c             	sub    $0xc,%esp
  801dbb:	50                   	push   %eax
  801dbc:	e8 9d ef ff ff       	call   800d5e <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801dc1:	83 c4 10             	add    $0x10,%esp
  801dc4:	85 f6                	test   %esi,%esi
  801dc6:	74 14                	je     801ddc <ipc_recv+0x3c>
  801dc8:	ba 00 00 00 00       	mov    $0x0,%edx
  801dcd:	85 c0                	test   %eax,%eax
  801dcf:	78 09                	js     801dda <ipc_recv+0x3a>
  801dd1:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801dd7:	8b 52 74             	mov    0x74(%edx),%edx
  801dda:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801ddc:	85 db                	test   %ebx,%ebx
  801dde:	74 14                	je     801df4 <ipc_recv+0x54>
  801de0:	ba 00 00 00 00       	mov    $0x0,%edx
  801de5:	85 c0                	test   %eax,%eax
  801de7:	78 09                	js     801df2 <ipc_recv+0x52>
  801de9:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801def:	8b 52 78             	mov    0x78(%edx),%edx
  801df2:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801df4:	85 c0                	test   %eax,%eax
  801df6:	78 08                	js     801e00 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801df8:	a1 00 40 80 00       	mov    0x804000,%eax
  801dfd:	8b 40 70             	mov    0x70(%eax),%eax
}
  801e00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e03:	5b                   	pop    %ebx
  801e04:	5e                   	pop    %esi
  801e05:	5d                   	pop    %ebp
  801e06:	c3                   	ret    

00801e07 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e07:	55                   	push   %ebp
  801e08:	89 e5                	mov    %esp,%ebp
  801e0a:	57                   	push   %edi
  801e0b:	56                   	push   %esi
  801e0c:	53                   	push   %ebx
  801e0d:	83 ec 0c             	sub    $0xc,%esp
  801e10:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e13:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e16:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801e19:	85 db                	test   %ebx,%ebx
  801e1b:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801e20:	0f 44 d8             	cmove  %eax,%ebx
  801e23:	eb 05                	jmp    801e2a <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801e25:	e8 65 ed ff ff       	call   800b8f <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801e2a:	ff 75 14             	push   0x14(%ebp)
  801e2d:	53                   	push   %ebx
  801e2e:	56                   	push   %esi
  801e2f:	57                   	push   %edi
  801e30:	e8 06 ef ff ff       	call   800d3b <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801e35:	83 c4 10             	add    $0x10,%esp
  801e38:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e3b:	74 e8                	je     801e25 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801e3d:	85 c0                	test   %eax,%eax
  801e3f:	78 08                	js     801e49 <ipc_send+0x42>
	}while (r<0);

}
  801e41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e44:	5b                   	pop    %ebx
  801e45:	5e                   	pop    %esi
  801e46:	5f                   	pop    %edi
  801e47:	5d                   	pop    %ebp
  801e48:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801e49:	50                   	push   %eax
  801e4a:	68 cc 26 80 00       	push   $0x8026cc
  801e4f:	6a 3d                	push   $0x3d
  801e51:	68 e0 26 80 00       	push   $0x8026e0
  801e56:	e8 63 fe ff ff       	call   801cbe <_panic>

00801e5b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801e5b:	55                   	push   %ebp
  801e5c:	89 e5                	mov    %esp,%ebp
  801e5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801e61:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801e66:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801e69:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801e6f:	8b 52 50             	mov    0x50(%edx),%edx
  801e72:	39 ca                	cmp    %ecx,%edx
  801e74:	74 11                	je     801e87 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801e76:	83 c0 01             	add    $0x1,%eax
  801e79:	3d 00 04 00 00       	cmp    $0x400,%eax
  801e7e:	75 e6                	jne    801e66 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801e80:	b8 00 00 00 00       	mov    $0x0,%eax
  801e85:	eb 0b                	jmp    801e92 <ipc_find_env+0x37>
			return envs[i].env_id;
  801e87:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801e8a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801e8f:	8b 40 48             	mov    0x48(%eax),%eax
}
  801e92:	5d                   	pop    %ebp
  801e93:	c3                   	ret    

00801e94 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801e94:	55                   	push   %ebp
  801e95:	89 e5                	mov    %esp,%ebp
  801e97:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801e9a:	89 c2                	mov    %eax,%edx
  801e9c:	c1 ea 16             	shr    $0x16,%edx
  801e9f:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801ea6:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801eab:	f6 c1 01             	test   $0x1,%cl
  801eae:	74 1c                	je     801ecc <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801eb0:	c1 e8 0c             	shr    $0xc,%eax
  801eb3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801eba:	a8 01                	test   $0x1,%al
  801ebc:	74 0e                	je     801ecc <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ebe:	c1 e8 0c             	shr    $0xc,%eax
  801ec1:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801ec8:	ef 
  801ec9:	0f b7 d2             	movzwl %dx,%edx
}
  801ecc:	89 d0                	mov    %edx,%eax
  801ece:	5d                   	pop    %ebp
  801ecf:	c3                   	ret    

00801ed0 <__udivdi3>:
  801ed0:	f3 0f 1e fb          	endbr32 
  801ed4:	55                   	push   %ebp
  801ed5:	57                   	push   %edi
  801ed6:	56                   	push   %esi
  801ed7:	53                   	push   %ebx
  801ed8:	83 ec 1c             	sub    $0x1c,%esp
  801edb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801edf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801ee3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ee7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	75 19                	jne    801f08 <__udivdi3+0x38>
  801eef:	39 f3                	cmp    %esi,%ebx
  801ef1:	76 4d                	jbe    801f40 <__udivdi3+0x70>
  801ef3:	31 ff                	xor    %edi,%edi
  801ef5:	89 e8                	mov    %ebp,%eax
  801ef7:	89 f2                	mov    %esi,%edx
  801ef9:	f7 f3                	div    %ebx
  801efb:	89 fa                	mov    %edi,%edx
  801efd:	83 c4 1c             	add    $0x1c,%esp
  801f00:	5b                   	pop    %ebx
  801f01:	5e                   	pop    %esi
  801f02:	5f                   	pop    %edi
  801f03:	5d                   	pop    %ebp
  801f04:	c3                   	ret    
  801f05:	8d 76 00             	lea    0x0(%esi),%esi
  801f08:	39 f0                	cmp    %esi,%eax
  801f0a:	76 14                	jbe    801f20 <__udivdi3+0x50>
  801f0c:	31 ff                	xor    %edi,%edi
  801f0e:	31 c0                	xor    %eax,%eax
  801f10:	89 fa                	mov    %edi,%edx
  801f12:	83 c4 1c             	add    $0x1c,%esp
  801f15:	5b                   	pop    %ebx
  801f16:	5e                   	pop    %esi
  801f17:	5f                   	pop    %edi
  801f18:	5d                   	pop    %ebp
  801f19:	c3                   	ret    
  801f1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f20:	0f bd f8             	bsr    %eax,%edi
  801f23:	83 f7 1f             	xor    $0x1f,%edi
  801f26:	75 48                	jne    801f70 <__udivdi3+0xa0>
  801f28:	39 f0                	cmp    %esi,%eax
  801f2a:	72 06                	jb     801f32 <__udivdi3+0x62>
  801f2c:	31 c0                	xor    %eax,%eax
  801f2e:	39 eb                	cmp    %ebp,%ebx
  801f30:	77 de                	ja     801f10 <__udivdi3+0x40>
  801f32:	b8 01 00 00 00       	mov    $0x1,%eax
  801f37:	eb d7                	jmp    801f10 <__udivdi3+0x40>
  801f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f40:	89 d9                	mov    %ebx,%ecx
  801f42:	85 db                	test   %ebx,%ebx
  801f44:	75 0b                	jne    801f51 <__udivdi3+0x81>
  801f46:	b8 01 00 00 00       	mov    $0x1,%eax
  801f4b:	31 d2                	xor    %edx,%edx
  801f4d:	f7 f3                	div    %ebx
  801f4f:	89 c1                	mov    %eax,%ecx
  801f51:	31 d2                	xor    %edx,%edx
  801f53:	89 f0                	mov    %esi,%eax
  801f55:	f7 f1                	div    %ecx
  801f57:	89 c6                	mov    %eax,%esi
  801f59:	89 e8                	mov    %ebp,%eax
  801f5b:	89 f7                	mov    %esi,%edi
  801f5d:	f7 f1                	div    %ecx
  801f5f:	89 fa                	mov    %edi,%edx
  801f61:	83 c4 1c             	add    $0x1c,%esp
  801f64:	5b                   	pop    %ebx
  801f65:	5e                   	pop    %esi
  801f66:	5f                   	pop    %edi
  801f67:	5d                   	pop    %ebp
  801f68:	c3                   	ret    
  801f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f70:	89 f9                	mov    %edi,%ecx
  801f72:	ba 20 00 00 00       	mov    $0x20,%edx
  801f77:	29 fa                	sub    %edi,%edx
  801f79:	d3 e0                	shl    %cl,%eax
  801f7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f7f:	89 d1                	mov    %edx,%ecx
  801f81:	89 d8                	mov    %ebx,%eax
  801f83:	d3 e8                	shr    %cl,%eax
  801f85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801f89:	09 c1                	or     %eax,%ecx
  801f8b:	89 f0                	mov    %esi,%eax
  801f8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f91:	89 f9                	mov    %edi,%ecx
  801f93:	d3 e3                	shl    %cl,%ebx
  801f95:	89 d1                	mov    %edx,%ecx
  801f97:	d3 e8                	shr    %cl,%eax
  801f99:	89 f9                	mov    %edi,%ecx
  801f9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801f9f:	89 eb                	mov    %ebp,%ebx
  801fa1:	d3 e6                	shl    %cl,%esi
  801fa3:	89 d1                	mov    %edx,%ecx
  801fa5:	d3 eb                	shr    %cl,%ebx
  801fa7:	09 f3                	or     %esi,%ebx
  801fa9:	89 c6                	mov    %eax,%esi
  801fab:	89 f2                	mov    %esi,%edx
  801fad:	89 d8                	mov    %ebx,%eax
  801faf:	f7 74 24 08          	divl   0x8(%esp)
  801fb3:	89 d6                	mov    %edx,%esi
  801fb5:	89 c3                	mov    %eax,%ebx
  801fb7:	f7 64 24 0c          	mull   0xc(%esp)
  801fbb:	39 d6                	cmp    %edx,%esi
  801fbd:	72 19                	jb     801fd8 <__udivdi3+0x108>
  801fbf:	89 f9                	mov    %edi,%ecx
  801fc1:	d3 e5                	shl    %cl,%ebp
  801fc3:	39 c5                	cmp    %eax,%ebp
  801fc5:	73 04                	jae    801fcb <__udivdi3+0xfb>
  801fc7:	39 d6                	cmp    %edx,%esi
  801fc9:	74 0d                	je     801fd8 <__udivdi3+0x108>
  801fcb:	89 d8                	mov    %ebx,%eax
  801fcd:	31 ff                	xor    %edi,%edi
  801fcf:	e9 3c ff ff ff       	jmp    801f10 <__udivdi3+0x40>
  801fd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801fd8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801fdb:	31 ff                	xor    %edi,%edi
  801fdd:	e9 2e ff ff ff       	jmp    801f10 <__udivdi3+0x40>
  801fe2:	66 90                	xchg   %ax,%ax
  801fe4:	66 90                	xchg   %ax,%ax
  801fe6:	66 90                	xchg   %ax,%ax
  801fe8:	66 90                	xchg   %ax,%ax
  801fea:	66 90                	xchg   %ax,%ax
  801fec:	66 90                	xchg   %ax,%ax
  801fee:	66 90                	xchg   %ax,%ax

00801ff0 <__umoddi3>:
  801ff0:	f3 0f 1e fb          	endbr32 
  801ff4:	55                   	push   %ebp
  801ff5:	57                   	push   %edi
  801ff6:	56                   	push   %esi
  801ff7:	53                   	push   %ebx
  801ff8:	83 ec 1c             	sub    $0x1c,%esp
  801ffb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801fff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802003:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802007:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80200b:	89 f0                	mov    %esi,%eax
  80200d:	89 da                	mov    %ebx,%edx
  80200f:	85 ff                	test   %edi,%edi
  802011:	75 15                	jne    802028 <__umoddi3+0x38>
  802013:	39 dd                	cmp    %ebx,%ebp
  802015:	76 39                	jbe    802050 <__umoddi3+0x60>
  802017:	f7 f5                	div    %ebp
  802019:	89 d0                	mov    %edx,%eax
  80201b:	31 d2                	xor    %edx,%edx
  80201d:	83 c4 1c             	add    $0x1c,%esp
  802020:	5b                   	pop    %ebx
  802021:	5e                   	pop    %esi
  802022:	5f                   	pop    %edi
  802023:	5d                   	pop    %ebp
  802024:	c3                   	ret    
  802025:	8d 76 00             	lea    0x0(%esi),%esi
  802028:	39 df                	cmp    %ebx,%edi
  80202a:	77 f1                	ja     80201d <__umoddi3+0x2d>
  80202c:	0f bd cf             	bsr    %edi,%ecx
  80202f:	83 f1 1f             	xor    $0x1f,%ecx
  802032:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802036:	75 40                	jne    802078 <__umoddi3+0x88>
  802038:	39 df                	cmp    %ebx,%edi
  80203a:	72 04                	jb     802040 <__umoddi3+0x50>
  80203c:	39 f5                	cmp    %esi,%ebp
  80203e:	77 dd                	ja     80201d <__umoddi3+0x2d>
  802040:	89 da                	mov    %ebx,%edx
  802042:	89 f0                	mov    %esi,%eax
  802044:	29 e8                	sub    %ebp,%eax
  802046:	19 fa                	sbb    %edi,%edx
  802048:	eb d3                	jmp    80201d <__umoddi3+0x2d>
  80204a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802050:	89 e9                	mov    %ebp,%ecx
  802052:	85 ed                	test   %ebp,%ebp
  802054:	75 0b                	jne    802061 <__umoddi3+0x71>
  802056:	b8 01 00 00 00       	mov    $0x1,%eax
  80205b:	31 d2                	xor    %edx,%edx
  80205d:	f7 f5                	div    %ebp
  80205f:	89 c1                	mov    %eax,%ecx
  802061:	89 d8                	mov    %ebx,%eax
  802063:	31 d2                	xor    %edx,%edx
  802065:	f7 f1                	div    %ecx
  802067:	89 f0                	mov    %esi,%eax
  802069:	f7 f1                	div    %ecx
  80206b:	89 d0                	mov    %edx,%eax
  80206d:	31 d2                	xor    %edx,%edx
  80206f:	eb ac                	jmp    80201d <__umoddi3+0x2d>
  802071:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802078:	8b 44 24 04          	mov    0x4(%esp),%eax
  80207c:	ba 20 00 00 00       	mov    $0x20,%edx
  802081:	29 c2                	sub    %eax,%edx
  802083:	89 c1                	mov    %eax,%ecx
  802085:	89 e8                	mov    %ebp,%eax
  802087:	d3 e7                	shl    %cl,%edi
  802089:	89 d1                	mov    %edx,%ecx
  80208b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80208f:	d3 e8                	shr    %cl,%eax
  802091:	89 c1                	mov    %eax,%ecx
  802093:	8b 44 24 04          	mov    0x4(%esp),%eax
  802097:	09 f9                	or     %edi,%ecx
  802099:	89 df                	mov    %ebx,%edi
  80209b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80209f:	89 c1                	mov    %eax,%ecx
  8020a1:	d3 e5                	shl    %cl,%ebp
  8020a3:	89 d1                	mov    %edx,%ecx
  8020a5:	d3 ef                	shr    %cl,%edi
  8020a7:	89 c1                	mov    %eax,%ecx
  8020a9:	89 f0                	mov    %esi,%eax
  8020ab:	d3 e3                	shl    %cl,%ebx
  8020ad:	89 d1                	mov    %edx,%ecx
  8020af:	89 fa                	mov    %edi,%edx
  8020b1:	d3 e8                	shr    %cl,%eax
  8020b3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8020b8:	09 d8                	or     %ebx,%eax
  8020ba:	f7 74 24 08          	divl   0x8(%esp)
  8020be:	89 d3                	mov    %edx,%ebx
  8020c0:	d3 e6                	shl    %cl,%esi
  8020c2:	f7 e5                	mul    %ebp
  8020c4:	89 c7                	mov    %eax,%edi
  8020c6:	89 d1                	mov    %edx,%ecx
  8020c8:	39 d3                	cmp    %edx,%ebx
  8020ca:	72 06                	jb     8020d2 <__umoddi3+0xe2>
  8020cc:	75 0e                	jne    8020dc <__umoddi3+0xec>
  8020ce:	39 c6                	cmp    %eax,%esi
  8020d0:	73 0a                	jae    8020dc <__umoddi3+0xec>
  8020d2:	29 e8                	sub    %ebp,%eax
  8020d4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8020d8:	89 d1                	mov    %edx,%ecx
  8020da:	89 c7                	mov    %eax,%edi
  8020dc:	89 f5                	mov    %esi,%ebp
  8020de:	8b 74 24 04          	mov    0x4(%esp),%esi
  8020e2:	29 fd                	sub    %edi,%ebp
  8020e4:	19 cb                	sbb    %ecx,%ebx
  8020e6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8020eb:	89 d8                	mov    %ebx,%eax
  8020ed:	d3 e0                	shl    %cl,%eax
  8020ef:	89 f1                	mov    %esi,%ecx
  8020f1:	d3 ed                	shr    %cl,%ebp
  8020f3:	d3 eb                	shr    %cl,%ebx
  8020f5:	09 e8                	or     %ebp,%eax
  8020f7:	89 da                	mov    %ebx,%edx
  8020f9:	83 c4 1c             	add    $0x1c,%esp
  8020fc:	5b                   	pop    %ebx
  8020fd:	5e                   	pop    %esi
  8020fe:	5f                   	pop    %edi
  8020ff:	5d                   	pop    %ebp
  802100:	c3                   	ret    
