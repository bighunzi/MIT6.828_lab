
obj/user/MFQtest.debug：     文件格式 elf32-i386


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
  80002c:	e8 07 01 00 00       	call   800138 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sleep>:
//该文件用来测试MFQ算法是否部署完成
#include <inc/lib.h>

void static
sleep(int msec)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	89 c3                	mov    %eax,%ebx
    int now = sys_time_msec();
  80003a:	e8 fe 0d 00 00       	call   800e3d <sys_time_msec>
  80003f:	89 c6                	mov    %eax,%esi

    while (msec>0){//使进程运行指定时间。 
  800041:	eb 0d                	jmp    800050 <sleep+0x1d>
		int pre=now;
		now=sys_time_msec();
  800043:	e8 f5 0d 00 00       	call   800e3d <sys_time_msec>
		msec-= now-pre;
  800048:	89 c2                	mov    %eax,%edx
  80004a:	29 f2                	sub    %esi,%edx
  80004c:	29 d3                	sub    %edx,%ebx
		now=sys_time_msec();
  80004e:	89 c6                	mov    %eax,%esi
    while (msec>0){//使进程运行指定时间。 
  800050:	85 db                	test   %ebx,%ebx
  800052:	7f ef                	jg     800043 <sleep+0x10>
	}   
}
  800054:	5b                   	pop    %ebx
  800055:	5e                   	pop    %esi
  800056:	5d                   	pop    %ebp
  800057:	c3                   	ret    

00800058 <umain>:
void
umain(int argc, char **argv)
{
  800058:	55                   	push   %ebp
  800059:	89 e5                	mov    %esp,%ebp
  80005b:	83 ec 10             	sub    $0x10,%esp
	cprintf("新环境 %08x开始...............\n",thisenv->env_id);
  80005e:	a1 00 40 80 00       	mov    0x804000,%eax
  800063:	8b 40 58             	mov    0x58(%eax),%eax
  800066:	50                   	push   %eax
  800067:	68 60 26 80 00       	push   $0x802660
  80006c:	e8 05 02 00 00       	call   800276 <cprintf>
	int i;
	
	sleep(50);//该进程先跑50ms。
  800071:	b8 32 00 00 00       	mov    $0x32,%eax
  800076:	e8 b8 ff ff ff       	call   800033 <sleep>
	//然后再fork两个子进程，之后通过打印信息来观察这三个进程的调度顺序
	envid_t eid=fork();
  80007b:	e8 1c 0f 00 00       	call   800f9c <fork>

	if(eid<0){
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	85 c0                	test   %eax,%eax
  800085:	78 4b                	js     8000d2 <umain+0x7a>
		panic("fork fail");
	}else if(eid==0){ //子进程
  800087:	75 71                	jne    8000fa <umain+0xa2>
		cprintf("我是子进程， 新环境%08x开始...............\n",thisenv->env_id);
  800089:	a1 00 40 80 00       	mov    0x804000,%eax
  80008e:	8b 40 58             	mov    0x58(%eax),%eax
  800091:	83 ec 08             	sub    $0x8,%esp
  800094:	50                   	push   %eax
  800095:	68 88 26 80 00       	push   $0x802688
  80009a:	e8 d7 01 00 00       	call   800276 <cprintf>

		sleep(50);//该进程先跑50ms。
  80009f:	b8 32 00 00 00       	mov    $0x32,%eax
  8000a4:	e8 8a ff ff ff       	call   800033 <sleep>
		eid=fork();//再创建子子进程
  8000a9:	e8 ee 0e 00 00       	call   800f9c <fork>

		if(eid<0){
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	85 c0                	test   %eax,%eax
  8000b3:	78 31                	js     8000e6 <umain+0x8e>
			panic("fork fail");
		}else if(eid==0){ //子进程
  8000b5:	75 5c                	jne    800113 <umain+0xbb>
			cprintf("我是子子进程，新环境%08x开始...............\n",thisenv->env_id);
  8000b7:	a1 00 40 80 00       	mov    0x804000,%eax
  8000bc:	8b 40 58             	mov    0x58(%eax),%eax
  8000bf:	83 ec 08             	sub    $0x8,%esp
  8000c2:	50                   	push   %eax
  8000c3:	68 c0 26 80 00       	push   $0x8026c0
  8000c8:	e8 a9 01 00 00       	call   800276 <cprintf>
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	eb 41                	jmp    800113 <umain+0xbb>
		panic("fork fail");
  8000d2:	83 ec 04             	sub    $0x4,%esp
  8000d5:	68 59 27 80 00       	push   $0x802759
  8000da:	6a 1a                	push   $0x1a
  8000dc:	68 63 27 80 00       	push   $0x802763
  8000e1:	e8 b5 00 00 00       	call   80019b <_panic>
			panic("fork fail");
  8000e6:	83 ec 04             	sub    $0x4,%esp
  8000e9:	68 59 27 80 00       	push   $0x802759
  8000ee:	6a 22                	push   $0x22
  8000f0:	68 63 27 80 00       	push   $0x802763
  8000f5:	e8 a1 00 00 00       	call   80019b <_panic>
		}else{//父进程
		}

	}else{//父进程
		cprintf("我是父进程，新环境%08x继续执行...............\n",thisenv->env_id);
  8000fa:	a1 00 40 80 00       	mov    0x804000,%eax
  8000ff:	8b 40 58             	mov    0x58(%eax),%eax
  800102:	83 ec 08             	sub    $0x8,%esp
  800105:	50                   	push   %eax
  800106:	68 fc 26 80 00       	push   $0x8026fc
  80010b:	e8 66 01 00 00       	call   800276 <cprintf>
  800110:	83 c4 10             	add    $0x10,%esp
	}

	//父子，子子进程全都进行1s
	sleep(1000);//进程进行1s
  800113:	b8 e8 03 00 00       	mov    $0x3e8,%eax
  800118:	e8 16 ff ff ff       	call   800033 <sleep>
	cprintf("环境%08x结束...............\n",thisenv->env_id);
  80011d:	a1 00 40 80 00       	mov    0x804000,%eax
  800122:	8b 40 58             	mov    0x58(%eax),%eax
  800125:	83 ec 08             	sub    $0x8,%esp
  800128:	50                   	push   %eax
  800129:	68 38 27 80 00       	push   $0x802738
  80012e:	e8 43 01 00 00       	call   800276 <cprintf>
}
  800133:	83 c4 10             	add    $0x10,%esp
  800136:	c9                   	leave  
  800137:	c3                   	ret    

00800138 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	56                   	push   %esi
  80013c:	53                   	push   %ebx
  80013d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800140:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800143:	e8 c6 0a 00 00       	call   800c0e <sys_getenvid>
  800148:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014d:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800153:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800158:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80015d:	85 db                	test   %ebx,%ebx
  80015f:	7e 07                	jle    800168 <libmain+0x30>
		binaryname = argv[0];
  800161:	8b 06                	mov    (%esi),%eax
  800163:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800168:	83 ec 08             	sub    $0x8,%esp
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	e8 e6 fe ff ff       	call   800058 <umain>

	// exit gracefully
	exit();
  800172:	e8 0a 00 00 00       	call   800181 <exit>
}
  800177:	83 c4 10             	add    $0x10,%esp
  80017a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017d:	5b                   	pop    %ebx
  80017e:	5e                   	pop    %esi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800187:	e8 64 11 00 00       	call   8012f0 <close_all>
	sys_env_destroy(0);
  80018c:	83 ec 0c             	sub    $0xc,%esp
  80018f:	6a 00                	push   $0x0
  800191:	e8 37 0a 00 00       	call   800bcd <sys_env_destroy>
}
  800196:	83 c4 10             	add    $0x10,%esp
  800199:	c9                   	leave  
  80019a:	c3                   	ret    

0080019b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	56                   	push   %esi
  80019f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001a0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001a3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001a9:	e8 60 0a 00 00       	call   800c0e <sys_getenvid>
  8001ae:	83 ec 0c             	sub    $0xc,%esp
  8001b1:	ff 75 0c             	push   0xc(%ebp)
  8001b4:	ff 75 08             	push   0x8(%ebp)
  8001b7:	56                   	push   %esi
  8001b8:	50                   	push   %eax
  8001b9:	68 7c 27 80 00       	push   $0x80277c
  8001be:	e8 b3 00 00 00       	call   800276 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c3:	83 c4 18             	add    $0x18,%esp
  8001c6:	53                   	push   %ebx
  8001c7:	ff 75 10             	push   0x10(%ebp)
  8001ca:	e8 56 00 00 00       	call   800225 <vcprintf>
	cprintf("\n");
  8001cf:	c7 04 24 ac 2c 80 00 	movl   $0x802cac,(%esp)
  8001d6:	e8 9b 00 00 00       	call   800276 <cprintf>
  8001db:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001de:	cc                   	int3   
  8001df:	eb fd                	jmp    8001de <_panic+0x43>

008001e1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001e1:	55                   	push   %ebp
  8001e2:	89 e5                	mov    %esp,%ebp
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 04             	sub    $0x4,%esp
  8001e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001eb:	8b 13                	mov    (%ebx),%edx
  8001ed:	8d 42 01             	lea    0x1(%edx),%eax
  8001f0:	89 03                	mov    %eax,(%ebx)
  8001f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001f5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001f9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001fe:	74 09                	je     800209 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800200:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800204:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800207:	c9                   	leave  
  800208:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800209:	83 ec 08             	sub    $0x8,%esp
  80020c:	68 ff 00 00 00       	push   $0xff
  800211:	8d 43 08             	lea    0x8(%ebx),%eax
  800214:	50                   	push   %eax
  800215:	e8 76 09 00 00       	call   800b90 <sys_cputs>
		b->idx = 0;
  80021a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800220:	83 c4 10             	add    $0x10,%esp
  800223:	eb db                	jmp    800200 <putch+0x1f>

00800225 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80022e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800235:	00 00 00 
	b.cnt = 0;
  800238:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80023f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800242:	ff 75 0c             	push   0xc(%ebp)
  800245:	ff 75 08             	push   0x8(%ebp)
  800248:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80024e:	50                   	push   %eax
  80024f:	68 e1 01 80 00       	push   $0x8001e1
  800254:	e8 14 01 00 00       	call   80036d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800259:	83 c4 08             	add    $0x8,%esp
  80025c:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800262:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800268:	50                   	push   %eax
  800269:	e8 22 09 00 00       	call   800b90 <sys_cputs>

	return b.cnt;
}
  80026e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800274:	c9                   	leave  
  800275:	c3                   	ret    

00800276 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
  800279:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80027c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80027f:	50                   	push   %eax
  800280:	ff 75 08             	push   0x8(%ebp)
  800283:	e8 9d ff ff ff       	call   800225 <vcprintf>
	va_end(ap);

	return cnt;
}
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 1c             	sub    $0x1c,%esp
  800293:	89 c7                	mov    %eax,%edi
  800295:	89 d6                	mov    %edx,%esi
  800297:	8b 45 08             	mov    0x8(%ebp),%eax
  80029a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80029d:	89 d1                	mov    %edx,%ecx
  80029f:	89 c2                	mov    %eax,%edx
  8002a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002a4:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002a7:	8b 45 10             	mov    0x10(%ebp),%eax
  8002aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002b0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002b7:	39 c2                	cmp    %eax,%edx
  8002b9:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002bc:	72 3e                	jb     8002fc <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002be:	83 ec 0c             	sub    $0xc,%esp
  8002c1:	ff 75 18             	push   0x18(%ebp)
  8002c4:	83 eb 01             	sub    $0x1,%ebx
  8002c7:	53                   	push   %ebx
  8002c8:	50                   	push   %eax
  8002c9:	83 ec 08             	sub    $0x8,%esp
  8002cc:	ff 75 e4             	push   -0x1c(%ebp)
  8002cf:	ff 75 e0             	push   -0x20(%ebp)
  8002d2:	ff 75 dc             	push   -0x24(%ebp)
  8002d5:	ff 75 d8             	push   -0x28(%ebp)
  8002d8:	e8 33 21 00 00       	call   802410 <__udivdi3>
  8002dd:	83 c4 18             	add    $0x18,%esp
  8002e0:	52                   	push   %edx
  8002e1:	50                   	push   %eax
  8002e2:	89 f2                	mov    %esi,%edx
  8002e4:	89 f8                	mov    %edi,%eax
  8002e6:	e8 9f ff ff ff       	call   80028a <printnum>
  8002eb:	83 c4 20             	add    $0x20,%esp
  8002ee:	eb 13                	jmp    800303 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f0:	83 ec 08             	sub    $0x8,%esp
  8002f3:	56                   	push   %esi
  8002f4:	ff 75 18             	push   0x18(%ebp)
  8002f7:	ff d7                	call   *%edi
  8002f9:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002fc:	83 eb 01             	sub    $0x1,%ebx
  8002ff:	85 db                	test   %ebx,%ebx
  800301:	7f ed                	jg     8002f0 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800303:	83 ec 08             	sub    $0x8,%esp
  800306:	56                   	push   %esi
  800307:	83 ec 04             	sub    $0x4,%esp
  80030a:	ff 75 e4             	push   -0x1c(%ebp)
  80030d:	ff 75 e0             	push   -0x20(%ebp)
  800310:	ff 75 dc             	push   -0x24(%ebp)
  800313:	ff 75 d8             	push   -0x28(%ebp)
  800316:	e8 15 22 00 00       	call   802530 <__umoddi3>
  80031b:	83 c4 14             	add    $0x14,%esp
  80031e:	0f be 80 9f 27 80 00 	movsbl 0x80279f(%eax),%eax
  800325:	50                   	push   %eax
  800326:	ff d7                	call   *%edi
}
  800328:	83 c4 10             	add    $0x10,%esp
  80032b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032e:	5b                   	pop    %ebx
  80032f:	5e                   	pop    %esi
  800330:	5f                   	pop    %edi
  800331:	5d                   	pop    %ebp
  800332:	c3                   	ret    

00800333 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800333:	55                   	push   %ebp
  800334:	89 e5                	mov    %esp,%ebp
  800336:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800339:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033d:	8b 10                	mov    (%eax),%edx
  80033f:	3b 50 04             	cmp    0x4(%eax),%edx
  800342:	73 0a                	jae    80034e <sprintputch+0x1b>
		*b->buf++ = ch;
  800344:	8d 4a 01             	lea    0x1(%edx),%ecx
  800347:	89 08                	mov    %ecx,(%eax)
  800349:	8b 45 08             	mov    0x8(%ebp),%eax
  80034c:	88 02                	mov    %al,(%edx)
}
  80034e:	5d                   	pop    %ebp
  80034f:	c3                   	ret    

00800350 <printfmt>:
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800356:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800359:	50                   	push   %eax
  80035a:	ff 75 10             	push   0x10(%ebp)
  80035d:	ff 75 0c             	push   0xc(%ebp)
  800360:	ff 75 08             	push   0x8(%ebp)
  800363:	e8 05 00 00 00       	call   80036d <vprintfmt>
}
  800368:	83 c4 10             	add    $0x10,%esp
  80036b:	c9                   	leave  
  80036c:	c3                   	ret    

0080036d <vprintfmt>:
{
  80036d:	55                   	push   %ebp
  80036e:	89 e5                	mov    %esp,%ebp
  800370:	57                   	push   %edi
  800371:	56                   	push   %esi
  800372:	53                   	push   %ebx
  800373:	83 ec 3c             	sub    $0x3c,%esp
  800376:	8b 75 08             	mov    0x8(%ebp),%esi
  800379:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80037c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80037f:	eb 0a                	jmp    80038b <vprintfmt+0x1e>
			putch(ch, putdat);
  800381:	83 ec 08             	sub    $0x8,%esp
  800384:	53                   	push   %ebx
  800385:	50                   	push   %eax
  800386:	ff d6                	call   *%esi
  800388:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80038b:	83 c7 01             	add    $0x1,%edi
  80038e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800392:	83 f8 25             	cmp    $0x25,%eax
  800395:	74 0c                	je     8003a3 <vprintfmt+0x36>
			if (ch == '\0')
  800397:	85 c0                	test   %eax,%eax
  800399:	75 e6                	jne    800381 <vprintfmt+0x14>
}
  80039b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039e:	5b                   	pop    %ebx
  80039f:	5e                   	pop    %esi
  8003a0:	5f                   	pop    %edi
  8003a1:	5d                   	pop    %ebp
  8003a2:	c3                   	ret    
		padc = ' ';
  8003a3:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003a7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003ae:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003b5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003bc:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8d 47 01             	lea    0x1(%edi),%eax
  8003c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c7:	0f b6 17             	movzbl (%edi),%edx
  8003ca:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003cd:	3c 55                	cmp    $0x55,%al
  8003cf:	0f 87 bb 03 00 00    	ja     800790 <vprintfmt+0x423>
  8003d5:	0f b6 c0             	movzbl %al,%eax
  8003d8:	ff 24 85 e0 28 80 00 	jmp    *0x8028e0(,%eax,4)
  8003df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003e2:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003e6:	eb d9                	jmp    8003c1 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8003e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003eb:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003ef:	eb d0                	jmp    8003c1 <vprintfmt+0x54>
  8003f1:	0f b6 d2             	movzbl %dl,%edx
  8003f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003ff:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800402:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800406:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800409:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80040c:	83 f9 09             	cmp    $0x9,%ecx
  80040f:	77 55                	ja     800466 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800411:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800414:	eb e9                	jmp    8003ff <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800416:	8b 45 14             	mov    0x14(%ebp),%eax
  800419:	8b 00                	mov    (%eax),%eax
  80041b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80041e:	8b 45 14             	mov    0x14(%ebp),%eax
  800421:	8d 40 04             	lea    0x4(%eax),%eax
  800424:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80042a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042e:	79 91                	jns    8003c1 <vprintfmt+0x54>
				width = precision, precision = -1;
  800430:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800433:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800436:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80043d:	eb 82                	jmp    8003c1 <vprintfmt+0x54>
  80043f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800442:	85 d2                	test   %edx,%edx
  800444:	b8 00 00 00 00       	mov    $0x0,%eax
  800449:	0f 49 c2             	cmovns %edx,%eax
  80044c:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800452:	e9 6a ff ff ff       	jmp    8003c1 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80045a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800461:	e9 5b ff ff ff       	jmp    8003c1 <vprintfmt+0x54>
  800466:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800469:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80046c:	eb bc                	jmp    80042a <vprintfmt+0xbd>
			lflag++;
  80046e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800471:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800474:	e9 48 ff ff ff       	jmp    8003c1 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800479:	8b 45 14             	mov    0x14(%ebp),%eax
  80047c:	8d 78 04             	lea    0x4(%eax),%edi
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	53                   	push   %ebx
  800483:	ff 30                	push   (%eax)
  800485:	ff d6                	call   *%esi
			break;
  800487:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80048a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80048d:	e9 9d 02 00 00       	jmp    80072f <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800492:	8b 45 14             	mov    0x14(%ebp),%eax
  800495:	8d 78 04             	lea    0x4(%eax),%edi
  800498:	8b 10                	mov    (%eax),%edx
  80049a:	89 d0                	mov    %edx,%eax
  80049c:	f7 d8                	neg    %eax
  80049e:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a1:	83 f8 0f             	cmp    $0xf,%eax
  8004a4:	7f 23                	jg     8004c9 <vprintfmt+0x15c>
  8004a6:	8b 14 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%edx
  8004ad:	85 d2                	test   %edx,%edx
  8004af:	74 18                	je     8004c9 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8004b1:	52                   	push   %edx
  8004b2:	68 41 2c 80 00       	push   $0x802c41
  8004b7:	53                   	push   %ebx
  8004b8:	56                   	push   %esi
  8004b9:	e8 92 fe ff ff       	call   800350 <printfmt>
  8004be:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004c1:	89 7d 14             	mov    %edi,0x14(%ebp)
  8004c4:	e9 66 02 00 00       	jmp    80072f <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8004c9:	50                   	push   %eax
  8004ca:	68 b7 27 80 00       	push   $0x8027b7
  8004cf:	53                   	push   %ebx
  8004d0:	56                   	push   %esi
  8004d1:	e8 7a fe ff ff       	call   800350 <printfmt>
  8004d6:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004d9:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8004dc:	e9 4e 02 00 00       	jmp    80072f <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8004e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e4:	83 c0 04             	add    $0x4,%eax
  8004e7:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8004ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ed:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  8004ef:	85 d2                	test   %edx,%edx
  8004f1:	b8 b0 27 80 00       	mov    $0x8027b0,%eax
  8004f6:	0f 45 c2             	cmovne %edx,%eax
  8004f9:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004fc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800500:	7e 06                	jle    800508 <vprintfmt+0x19b>
  800502:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800506:	75 0d                	jne    800515 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800508:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80050b:	89 c7                	mov    %eax,%edi
  80050d:	03 45 e0             	add    -0x20(%ebp),%eax
  800510:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800513:	eb 55                	jmp    80056a <vprintfmt+0x1fd>
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	ff 75 d8             	push   -0x28(%ebp)
  80051b:	ff 75 cc             	push   -0x34(%ebp)
  80051e:	e8 0a 03 00 00       	call   80082d <strnlen>
  800523:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800526:	29 c1                	sub    %eax,%ecx
  800528:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80052b:	83 c4 10             	add    $0x10,%esp
  80052e:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800530:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800534:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800537:	eb 0f                	jmp    800548 <vprintfmt+0x1db>
					putch(padc, putdat);
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	53                   	push   %ebx
  80053d:	ff 75 e0             	push   -0x20(%ebp)
  800540:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800542:	83 ef 01             	sub    $0x1,%edi
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	85 ff                	test   %edi,%edi
  80054a:	7f ed                	jg     800539 <vprintfmt+0x1cc>
  80054c:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80054f:	85 d2                	test   %edx,%edx
  800551:	b8 00 00 00 00       	mov    $0x0,%eax
  800556:	0f 49 c2             	cmovns %edx,%eax
  800559:	29 c2                	sub    %eax,%edx
  80055b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80055e:	eb a8                	jmp    800508 <vprintfmt+0x19b>
					putch(ch, putdat);
  800560:	83 ec 08             	sub    $0x8,%esp
  800563:	53                   	push   %ebx
  800564:	52                   	push   %edx
  800565:	ff d6                	call   *%esi
  800567:	83 c4 10             	add    $0x10,%esp
  80056a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80056d:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056f:	83 c7 01             	add    $0x1,%edi
  800572:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800576:	0f be d0             	movsbl %al,%edx
  800579:	85 d2                	test   %edx,%edx
  80057b:	74 4b                	je     8005c8 <vprintfmt+0x25b>
  80057d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800581:	78 06                	js     800589 <vprintfmt+0x21c>
  800583:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800587:	78 1e                	js     8005a7 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800589:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80058d:	74 d1                	je     800560 <vprintfmt+0x1f3>
  80058f:	0f be c0             	movsbl %al,%eax
  800592:	83 e8 20             	sub    $0x20,%eax
  800595:	83 f8 5e             	cmp    $0x5e,%eax
  800598:	76 c6                	jbe    800560 <vprintfmt+0x1f3>
					putch('?', putdat);
  80059a:	83 ec 08             	sub    $0x8,%esp
  80059d:	53                   	push   %ebx
  80059e:	6a 3f                	push   $0x3f
  8005a0:	ff d6                	call   *%esi
  8005a2:	83 c4 10             	add    $0x10,%esp
  8005a5:	eb c3                	jmp    80056a <vprintfmt+0x1fd>
  8005a7:	89 cf                	mov    %ecx,%edi
  8005a9:	eb 0e                	jmp    8005b9 <vprintfmt+0x24c>
				putch(' ', putdat);
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	53                   	push   %ebx
  8005af:	6a 20                	push   $0x20
  8005b1:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005b3:	83 ef 01             	sub    $0x1,%edi
  8005b6:	83 c4 10             	add    $0x10,%esp
  8005b9:	85 ff                	test   %edi,%edi
  8005bb:	7f ee                	jg     8005ab <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8005bd:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005c0:	89 45 14             	mov    %eax,0x14(%ebp)
  8005c3:	e9 67 01 00 00       	jmp    80072f <vprintfmt+0x3c2>
  8005c8:	89 cf                	mov    %ecx,%edi
  8005ca:	eb ed                	jmp    8005b9 <vprintfmt+0x24c>
	if (lflag >= 2)
  8005cc:	83 f9 01             	cmp    $0x1,%ecx
  8005cf:	7f 1b                	jg     8005ec <vprintfmt+0x27f>
	else if (lflag)
  8005d1:	85 c9                	test   %ecx,%ecx
  8005d3:	74 63                	je     800638 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8005d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d8:	8b 00                	mov    (%eax),%eax
  8005da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005dd:	99                   	cltd   
  8005de:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8d 40 04             	lea    0x4(%eax),%eax
  8005e7:	89 45 14             	mov    %eax,0x14(%ebp)
  8005ea:	eb 17                	jmp    800603 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8b 50 04             	mov    0x4(%eax),%edx
  8005f2:	8b 00                	mov    (%eax),%eax
  8005f4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8005fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fd:	8d 40 08             	lea    0x8(%eax),%eax
  800600:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800603:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800606:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800609:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80060e:	85 c9                	test   %ecx,%ecx
  800610:	0f 89 ff 00 00 00    	jns    800715 <vprintfmt+0x3a8>
				putch('-', putdat);
  800616:	83 ec 08             	sub    $0x8,%esp
  800619:	53                   	push   %ebx
  80061a:	6a 2d                	push   $0x2d
  80061c:	ff d6                	call   *%esi
				num = -(long long) num;
  80061e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800621:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800624:	f7 da                	neg    %edx
  800626:	83 d1 00             	adc    $0x0,%ecx
  800629:	f7 d9                	neg    %ecx
  80062b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80062e:	bf 0a 00 00 00       	mov    $0xa,%edi
  800633:	e9 dd 00 00 00       	jmp    800715 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8b 00                	mov    (%eax),%eax
  80063d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800640:	99                   	cltd   
  800641:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 40 04             	lea    0x4(%eax),%eax
  80064a:	89 45 14             	mov    %eax,0x14(%ebp)
  80064d:	eb b4                	jmp    800603 <vprintfmt+0x296>
	if (lflag >= 2)
  80064f:	83 f9 01             	cmp    $0x1,%ecx
  800652:	7f 1e                	jg     800672 <vprintfmt+0x305>
	else if (lflag)
  800654:	85 c9                	test   %ecx,%ecx
  800656:	74 32                	je     80068a <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  800658:	8b 45 14             	mov    0x14(%ebp),%eax
  80065b:	8b 10                	mov    (%eax),%edx
  80065d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800662:	8d 40 04             	lea    0x4(%eax),%eax
  800665:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800668:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80066d:	e9 a3 00 00 00       	jmp    800715 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8b 10                	mov    (%eax),%edx
  800677:	8b 48 04             	mov    0x4(%eax),%ecx
  80067a:	8d 40 08             	lea    0x8(%eax),%eax
  80067d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800680:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800685:	e9 8b 00 00 00       	jmp    800715 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8b 10                	mov    (%eax),%edx
  80068f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800694:	8d 40 04             	lea    0x4(%eax),%eax
  800697:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80069a:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80069f:	eb 74                	jmp    800715 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8006a1:	83 f9 01             	cmp    $0x1,%ecx
  8006a4:	7f 1b                	jg     8006c1 <vprintfmt+0x354>
	else if (lflag)
  8006a6:	85 c9                	test   %ecx,%ecx
  8006a8:	74 2c                	je     8006d6 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	8b 10                	mov    (%eax),%edx
  8006af:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b4:	8d 40 04             	lea    0x4(%eax),%eax
  8006b7:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006ba:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8006bf:	eb 54                	jmp    800715 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8b 10                	mov    (%eax),%edx
  8006c6:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c9:	8d 40 08             	lea    0x8(%eax),%eax
  8006cc:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006cf:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8006d4:	eb 3f                	jmp    800715 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8b 10                	mov    (%eax),%edx
  8006db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006e0:	8d 40 04             	lea    0x4(%eax),%eax
  8006e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8006e6:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  8006eb:	eb 28                	jmp    800715 <vprintfmt+0x3a8>
			putch('0', putdat);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	53                   	push   %ebx
  8006f1:	6a 30                	push   $0x30
  8006f3:	ff d6                	call   *%esi
			putch('x', putdat);
  8006f5:	83 c4 08             	add    $0x8,%esp
  8006f8:	53                   	push   %ebx
  8006f9:	6a 78                	push   $0x78
  8006fb:	ff d6                	call   *%esi
			num = (unsigned long long)
  8006fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800700:	8b 10                	mov    (%eax),%edx
  800702:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800707:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80070a:	8d 40 04             	lea    0x4(%eax),%eax
  80070d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800710:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800715:	83 ec 0c             	sub    $0xc,%esp
  800718:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80071c:	50                   	push   %eax
  80071d:	ff 75 e0             	push   -0x20(%ebp)
  800720:	57                   	push   %edi
  800721:	51                   	push   %ecx
  800722:	52                   	push   %edx
  800723:	89 da                	mov    %ebx,%edx
  800725:	89 f0                	mov    %esi,%eax
  800727:	e8 5e fb ff ff       	call   80028a <printnum>
			break;
  80072c:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80072f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800732:	e9 54 fc ff ff       	jmp    80038b <vprintfmt+0x1e>
	if (lflag >= 2)
  800737:	83 f9 01             	cmp    $0x1,%ecx
  80073a:	7f 1b                	jg     800757 <vprintfmt+0x3ea>
	else if (lflag)
  80073c:	85 c9                	test   %ecx,%ecx
  80073e:	74 2c                	je     80076c <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  800740:	8b 45 14             	mov    0x14(%ebp),%eax
  800743:	8b 10                	mov    (%eax),%edx
  800745:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074a:	8d 40 04             	lea    0x4(%eax),%eax
  80074d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800750:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  800755:	eb be                	jmp    800715 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8b 10                	mov    (%eax),%edx
  80075c:	8b 48 04             	mov    0x4(%eax),%ecx
  80075f:	8d 40 08             	lea    0x8(%eax),%eax
  800762:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800765:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80076a:	eb a9                	jmp    800715 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8b 10                	mov    (%eax),%edx
  800771:	b9 00 00 00 00       	mov    $0x0,%ecx
  800776:	8d 40 04             	lea    0x4(%eax),%eax
  800779:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80077c:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800781:	eb 92                	jmp    800715 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800783:	83 ec 08             	sub    $0x8,%esp
  800786:	53                   	push   %ebx
  800787:	6a 25                	push   $0x25
  800789:	ff d6                	call   *%esi
			break;
  80078b:	83 c4 10             	add    $0x10,%esp
  80078e:	eb 9f                	jmp    80072f <vprintfmt+0x3c2>
			putch('%', putdat);
  800790:	83 ec 08             	sub    $0x8,%esp
  800793:	53                   	push   %ebx
  800794:	6a 25                	push   $0x25
  800796:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800798:	83 c4 10             	add    $0x10,%esp
  80079b:	89 f8                	mov    %edi,%eax
  80079d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8007a1:	74 05                	je     8007a8 <vprintfmt+0x43b>
  8007a3:	83 e8 01             	sub    $0x1,%eax
  8007a6:	eb f5                	jmp    80079d <vprintfmt+0x430>
  8007a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007ab:	eb 82                	jmp    80072f <vprintfmt+0x3c2>

008007ad <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ad:	55                   	push   %ebp
  8007ae:	89 e5                	mov    %esp,%ebp
  8007b0:	83 ec 18             	sub    $0x18,%esp
  8007b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b6:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007bc:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8007c0:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8007c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8007ca:	85 c0                	test   %eax,%eax
  8007cc:	74 26                	je     8007f4 <vsnprintf+0x47>
  8007ce:	85 d2                	test   %edx,%edx
  8007d0:	7e 22                	jle    8007f4 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007d2:	ff 75 14             	push   0x14(%ebp)
  8007d5:	ff 75 10             	push   0x10(%ebp)
  8007d8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007db:	50                   	push   %eax
  8007dc:	68 33 03 80 00       	push   $0x800333
  8007e1:	e8 87 fb ff ff       	call   80036d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007e6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007e9:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ef:	83 c4 10             	add    $0x10,%esp
}
  8007f2:	c9                   	leave  
  8007f3:	c3                   	ret    
		return -E_INVAL;
  8007f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007f9:	eb f7                	jmp    8007f2 <vsnprintf+0x45>

008007fb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007fb:	55                   	push   %ebp
  8007fc:	89 e5                	mov    %esp,%ebp
  8007fe:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800801:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800804:	50                   	push   %eax
  800805:	ff 75 10             	push   0x10(%ebp)
  800808:	ff 75 0c             	push   0xc(%ebp)
  80080b:	ff 75 08             	push   0x8(%ebp)
  80080e:	e8 9a ff ff ff       	call   8007ad <vsnprintf>
	va_end(ap);

	return rc;
}
  800813:	c9                   	leave  
  800814:	c3                   	ret    

00800815 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80081b:	b8 00 00 00 00       	mov    $0x0,%eax
  800820:	eb 03                	jmp    800825 <strlen+0x10>
		n++;
  800822:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800825:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800829:	75 f7                	jne    800822 <strlen+0xd>
	return n;
}
  80082b:	5d                   	pop    %ebp
  80082c:	c3                   	ret    

0080082d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80082d:	55                   	push   %ebp
  80082e:	89 e5                	mov    %esp,%ebp
  800830:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800833:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
  80083b:	eb 03                	jmp    800840 <strnlen+0x13>
		n++;
  80083d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800840:	39 d0                	cmp    %edx,%eax
  800842:	74 08                	je     80084c <strnlen+0x1f>
  800844:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800848:	75 f3                	jne    80083d <strnlen+0x10>
  80084a:	89 c2                	mov    %eax,%edx
	return n;
}
  80084c:	89 d0                	mov    %edx,%eax
  80084e:	5d                   	pop    %ebp
  80084f:	c3                   	ret    

00800850 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	53                   	push   %ebx
  800854:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800857:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80085a:	b8 00 00 00 00       	mov    $0x0,%eax
  80085f:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800863:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800866:	83 c0 01             	add    $0x1,%eax
  800869:	84 d2                	test   %dl,%dl
  80086b:	75 f2                	jne    80085f <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  80086d:	89 c8                	mov    %ecx,%eax
  80086f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800872:	c9                   	leave  
  800873:	c3                   	ret    

00800874 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	53                   	push   %ebx
  800878:	83 ec 10             	sub    $0x10,%esp
  80087b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80087e:	53                   	push   %ebx
  80087f:	e8 91 ff ff ff       	call   800815 <strlen>
  800884:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800887:	ff 75 0c             	push   0xc(%ebp)
  80088a:	01 d8                	add    %ebx,%eax
  80088c:	50                   	push   %eax
  80088d:	e8 be ff ff ff       	call   800850 <strcpy>
	return dst;
}
  800892:	89 d8                	mov    %ebx,%eax
  800894:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800897:	c9                   	leave  
  800898:	c3                   	ret    

00800899 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	56                   	push   %esi
  80089d:	53                   	push   %ebx
  80089e:	8b 75 08             	mov    0x8(%ebp),%esi
  8008a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a4:	89 f3                	mov    %esi,%ebx
  8008a6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a9:	89 f0                	mov    %esi,%eax
  8008ab:	eb 0f                	jmp    8008bc <strncpy+0x23>
		*dst++ = *src;
  8008ad:	83 c0 01             	add    $0x1,%eax
  8008b0:	0f b6 0a             	movzbl (%edx),%ecx
  8008b3:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b6:	80 f9 01             	cmp    $0x1,%cl
  8008b9:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  8008bc:	39 d8                	cmp    %ebx,%eax
  8008be:	75 ed                	jne    8008ad <strncpy+0x14>
	}
	return ret;
}
  8008c0:	89 f0                	mov    %esi,%eax
  8008c2:	5b                   	pop    %ebx
  8008c3:	5e                   	pop    %esi
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
  8008cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008d1:	8b 55 10             	mov    0x10(%ebp),%edx
  8008d4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d6:	85 d2                	test   %edx,%edx
  8008d8:	74 21                	je     8008fb <strlcpy+0x35>
  8008da:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008de:	89 f2                	mov    %esi,%edx
  8008e0:	eb 09                	jmp    8008eb <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8008e2:	83 c1 01             	add    $0x1,%ecx
  8008e5:	83 c2 01             	add    $0x1,%edx
  8008e8:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  8008eb:	39 c2                	cmp    %eax,%edx
  8008ed:	74 09                	je     8008f8 <strlcpy+0x32>
  8008ef:	0f b6 19             	movzbl (%ecx),%ebx
  8008f2:	84 db                	test   %bl,%bl
  8008f4:	75 ec                	jne    8008e2 <strlcpy+0x1c>
  8008f6:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008f8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008fb:	29 f0                	sub    %esi,%eax
}
  8008fd:	5b                   	pop    %ebx
  8008fe:	5e                   	pop    %esi
  8008ff:	5d                   	pop    %ebp
  800900:	c3                   	ret    

00800901 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800907:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80090a:	eb 06                	jmp    800912 <strcmp+0x11>
		p++, q++;
  80090c:	83 c1 01             	add    $0x1,%ecx
  80090f:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800912:	0f b6 01             	movzbl (%ecx),%eax
  800915:	84 c0                	test   %al,%al
  800917:	74 04                	je     80091d <strcmp+0x1c>
  800919:	3a 02                	cmp    (%edx),%al
  80091b:	74 ef                	je     80090c <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80091d:	0f b6 c0             	movzbl %al,%eax
  800920:	0f b6 12             	movzbl (%edx),%edx
  800923:	29 d0                	sub    %edx,%eax
}
  800925:	5d                   	pop    %ebp
  800926:	c3                   	ret    

00800927 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800927:	55                   	push   %ebp
  800928:	89 e5                	mov    %esp,%ebp
  80092a:	53                   	push   %ebx
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800931:	89 c3                	mov    %eax,%ebx
  800933:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800936:	eb 06                	jmp    80093e <strncmp+0x17>
		n--, p++, q++;
  800938:	83 c0 01             	add    $0x1,%eax
  80093b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80093e:	39 d8                	cmp    %ebx,%eax
  800940:	74 18                	je     80095a <strncmp+0x33>
  800942:	0f b6 08             	movzbl (%eax),%ecx
  800945:	84 c9                	test   %cl,%cl
  800947:	74 04                	je     80094d <strncmp+0x26>
  800949:	3a 0a                	cmp    (%edx),%cl
  80094b:	74 eb                	je     800938 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80094d:	0f b6 00             	movzbl (%eax),%eax
  800950:	0f b6 12             	movzbl (%edx),%edx
  800953:	29 d0                	sub    %edx,%eax
}
  800955:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800958:	c9                   	leave  
  800959:	c3                   	ret    
		return 0;
  80095a:	b8 00 00 00 00       	mov    $0x0,%eax
  80095f:	eb f4                	jmp    800955 <strncmp+0x2e>

00800961 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80096b:	eb 03                	jmp    800970 <strchr+0xf>
  80096d:	83 c0 01             	add    $0x1,%eax
  800970:	0f b6 10             	movzbl (%eax),%edx
  800973:	84 d2                	test   %dl,%dl
  800975:	74 06                	je     80097d <strchr+0x1c>
		if (*s == c)
  800977:	38 ca                	cmp    %cl,%dl
  800979:	75 f2                	jne    80096d <strchr+0xc>
  80097b:	eb 05                	jmp    800982 <strchr+0x21>
			return (char *) s;
	return 0;
  80097d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	8b 45 08             	mov    0x8(%ebp),%eax
  80098a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80098e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800991:	38 ca                	cmp    %cl,%dl
  800993:	74 09                	je     80099e <strfind+0x1a>
  800995:	84 d2                	test   %dl,%dl
  800997:	74 05                	je     80099e <strfind+0x1a>
	for (; *s; s++)
  800999:	83 c0 01             	add    $0x1,%eax
  80099c:	eb f0                	jmp    80098e <strfind+0xa>
			break;
	return (char *) s;
}
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	57                   	push   %edi
  8009a4:	56                   	push   %esi
  8009a5:	53                   	push   %ebx
  8009a6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009a9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009ac:	85 c9                	test   %ecx,%ecx
  8009ae:	74 2f                	je     8009df <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b0:	89 f8                	mov    %edi,%eax
  8009b2:	09 c8                	or     %ecx,%eax
  8009b4:	a8 03                	test   $0x3,%al
  8009b6:	75 21                	jne    8009d9 <memset+0x39>
		c &= 0xFF;
  8009b8:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009bc:	89 d0                	mov    %edx,%eax
  8009be:	c1 e0 08             	shl    $0x8,%eax
  8009c1:	89 d3                	mov    %edx,%ebx
  8009c3:	c1 e3 18             	shl    $0x18,%ebx
  8009c6:	89 d6                	mov    %edx,%esi
  8009c8:	c1 e6 10             	shl    $0x10,%esi
  8009cb:	09 f3                	or     %esi,%ebx
  8009cd:	09 da                	or     %ebx,%edx
  8009cf:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  8009d1:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  8009d4:	fc                   	cld    
  8009d5:	f3 ab                	rep stos %eax,%es:(%edi)
  8009d7:	eb 06                	jmp    8009df <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009dc:	fc                   	cld    
  8009dd:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009df:	89 f8                	mov    %edi,%eax
  8009e1:	5b                   	pop    %ebx
  8009e2:	5e                   	pop    %esi
  8009e3:	5f                   	pop    %edi
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	57                   	push   %edi
  8009ea:	56                   	push   %esi
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f4:	39 c6                	cmp    %eax,%esi
  8009f6:	73 32                	jae    800a2a <memmove+0x44>
  8009f8:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009fb:	39 c2                	cmp    %eax,%edx
  8009fd:	76 2b                	jbe    800a2a <memmove+0x44>
		s += n;
		d += n;
  8009ff:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a02:	89 d6                	mov    %edx,%esi
  800a04:	09 fe                	or     %edi,%esi
  800a06:	09 ce                	or     %ecx,%esi
  800a08:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a0e:	75 0e                	jne    800a1e <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a10:	83 ef 04             	sub    $0x4,%edi
  800a13:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a16:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a19:	fd                   	std    
  800a1a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a1c:	eb 09                	jmp    800a27 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a1e:	83 ef 01             	sub    $0x1,%edi
  800a21:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a24:	fd                   	std    
  800a25:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a27:	fc                   	cld    
  800a28:	eb 1a                	jmp    800a44 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2a:	89 f2                	mov    %esi,%edx
  800a2c:	09 c2                	or     %eax,%edx
  800a2e:	09 ca                	or     %ecx,%edx
  800a30:	f6 c2 03             	test   $0x3,%dl
  800a33:	75 0a                	jne    800a3f <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a35:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a38:	89 c7                	mov    %eax,%edi
  800a3a:	fc                   	cld    
  800a3b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3d:	eb 05                	jmp    800a44 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800a3f:	89 c7                	mov    %eax,%edi
  800a41:	fc                   	cld    
  800a42:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a44:	5e                   	pop    %esi
  800a45:	5f                   	pop    %edi
  800a46:	5d                   	pop    %ebp
  800a47:	c3                   	ret    

00800a48 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a48:	55                   	push   %ebp
  800a49:	89 e5                	mov    %esp,%ebp
  800a4b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a4e:	ff 75 10             	push   0x10(%ebp)
  800a51:	ff 75 0c             	push   0xc(%ebp)
  800a54:	ff 75 08             	push   0x8(%ebp)
  800a57:	e8 8a ff ff ff       	call   8009e6 <memmove>
}
  800a5c:	c9                   	leave  
  800a5d:	c3                   	ret    

00800a5e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
  800a63:	8b 45 08             	mov    0x8(%ebp),%eax
  800a66:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a69:	89 c6                	mov    %eax,%esi
  800a6b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a6e:	eb 06                	jmp    800a76 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a70:	83 c0 01             	add    $0x1,%eax
  800a73:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800a76:	39 f0                	cmp    %esi,%eax
  800a78:	74 14                	je     800a8e <memcmp+0x30>
		if (*s1 != *s2)
  800a7a:	0f b6 08             	movzbl (%eax),%ecx
  800a7d:	0f b6 1a             	movzbl (%edx),%ebx
  800a80:	38 d9                	cmp    %bl,%cl
  800a82:	74 ec                	je     800a70 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800a84:	0f b6 c1             	movzbl %cl,%eax
  800a87:	0f b6 db             	movzbl %bl,%ebx
  800a8a:	29 d8                	sub    %ebx,%eax
  800a8c:	eb 05                	jmp    800a93 <memcmp+0x35>
	}

	return 0;
  800a8e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a93:	5b                   	pop    %ebx
  800a94:	5e                   	pop    %esi
  800a95:	5d                   	pop    %ebp
  800a96:	c3                   	ret    

00800a97 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aa0:	89 c2                	mov    %eax,%edx
  800aa2:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aa5:	eb 03                	jmp    800aaa <memfind+0x13>
  800aa7:	83 c0 01             	add    $0x1,%eax
  800aaa:	39 d0                	cmp    %edx,%eax
  800aac:	73 04                	jae    800ab2 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800aae:	38 08                	cmp    %cl,(%eax)
  800ab0:	75 f5                	jne    800aa7 <memfind+0x10>
			break;
	return (void *) s;
}
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	57                   	push   %edi
  800ab8:	56                   	push   %esi
  800ab9:	53                   	push   %ebx
  800aba:	8b 55 08             	mov    0x8(%ebp),%edx
  800abd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800ac0:	eb 03                	jmp    800ac5 <strtol+0x11>
		s++;
  800ac2:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800ac5:	0f b6 02             	movzbl (%edx),%eax
  800ac8:	3c 20                	cmp    $0x20,%al
  800aca:	74 f6                	je     800ac2 <strtol+0xe>
  800acc:	3c 09                	cmp    $0x9,%al
  800ace:	74 f2                	je     800ac2 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800ad0:	3c 2b                	cmp    $0x2b,%al
  800ad2:	74 2a                	je     800afe <strtol+0x4a>
	int neg = 0;
  800ad4:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ad9:	3c 2d                	cmp    $0x2d,%al
  800adb:	74 2b                	je     800b08 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800add:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800ae3:	75 0f                	jne    800af4 <strtol+0x40>
  800ae5:	80 3a 30             	cmpb   $0x30,(%edx)
  800ae8:	74 28                	je     800b12 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800aea:	85 db                	test   %ebx,%ebx
  800aec:	b8 0a 00 00 00       	mov    $0xa,%eax
  800af1:	0f 44 d8             	cmove  %eax,%ebx
  800af4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af9:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800afc:	eb 46                	jmp    800b44 <strtol+0x90>
		s++;
  800afe:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b01:	bf 00 00 00 00       	mov    $0x0,%edi
  800b06:	eb d5                	jmp    800add <strtol+0x29>
		s++, neg = 1;
  800b08:	83 c2 01             	add    $0x1,%edx
  800b0b:	bf 01 00 00 00       	mov    $0x1,%edi
  800b10:	eb cb                	jmp    800add <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b12:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b16:	74 0e                	je     800b26 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b18:	85 db                	test   %ebx,%ebx
  800b1a:	75 d8                	jne    800af4 <strtol+0x40>
		s++, base = 8;
  800b1c:	83 c2 01             	add    $0x1,%edx
  800b1f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b24:	eb ce                	jmp    800af4 <strtol+0x40>
		s += 2, base = 16;
  800b26:	83 c2 02             	add    $0x2,%edx
  800b29:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b2e:	eb c4                	jmp    800af4 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b30:	0f be c0             	movsbl %al,%eax
  800b33:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b36:	3b 45 10             	cmp    0x10(%ebp),%eax
  800b39:	7d 3a                	jge    800b75 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800b3b:	83 c2 01             	add    $0x1,%edx
  800b3e:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800b42:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800b44:	0f b6 02             	movzbl (%edx),%eax
  800b47:	8d 70 d0             	lea    -0x30(%eax),%esi
  800b4a:	89 f3                	mov    %esi,%ebx
  800b4c:	80 fb 09             	cmp    $0x9,%bl
  800b4f:	76 df                	jbe    800b30 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800b51:	8d 70 9f             	lea    -0x61(%eax),%esi
  800b54:	89 f3                	mov    %esi,%ebx
  800b56:	80 fb 19             	cmp    $0x19,%bl
  800b59:	77 08                	ja     800b63 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800b5b:	0f be c0             	movsbl %al,%eax
  800b5e:	83 e8 57             	sub    $0x57,%eax
  800b61:	eb d3                	jmp    800b36 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800b63:	8d 70 bf             	lea    -0x41(%eax),%esi
  800b66:	89 f3                	mov    %esi,%ebx
  800b68:	80 fb 19             	cmp    $0x19,%bl
  800b6b:	77 08                	ja     800b75 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800b6d:	0f be c0             	movsbl %al,%eax
  800b70:	83 e8 37             	sub    $0x37,%eax
  800b73:	eb c1                	jmp    800b36 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b75:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b79:	74 05                	je     800b80 <strtol+0xcc>
		*endptr = (char *) s;
  800b7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7e:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800b80:	89 c8                	mov    %ecx,%eax
  800b82:	f7 d8                	neg    %eax
  800b84:	85 ff                	test   %edi,%edi
  800b86:	0f 45 c8             	cmovne %eax,%ecx
}
  800b89:	89 c8                	mov    %ecx,%eax
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
	asm volatile("int %1\n"
  800b96:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ba1:	89 c3                	mov    %eax,%ebx
  800ba3:	89 c7                	mov    %eax,%edi
  800ba5:	89 c6                	mov    %eax,%esi
  800ba7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <sys_cgetc>:

int
sys_cgetc(void)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	57                   	push   %edi
  800bb2:	56                   	push   %esi
  800bb3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800bb4:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb9:	b8 01 00 00 00       	mov    $0x1,%eax
  800bbe:	89 d1                	mov    %edx,%ecx
  800bc0:	89 d3                	mov    %edx,%ebx
  800bc2:	89 d7                	mov    %edx,%edi
  800bc4:	89 d6                	mov    %edx,%esi
  800bc6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800bd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bde:	b8 03 00 00 00       	mov    $0x3,%eax
  800be3:	89 cb                	mov    %ecx,%ebx
  800be5:	89 cf                	mov    %ecx,%edi
  800be7:	89 ce                	mov    %ecx,%esi
  800be9:	cd 30                	int    $0x30
	if(check && ret > 0)
  800beb:	85 c0                	test   %eax,%eax
  800bed:	7f 08                	jg     800bf7 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800bef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf2:	5b                   	pop    %ebx
  800bf3:	5e                   	pop    %esi
  800bf4:	5f                   	pop    %edi
  800bf5:	5d                   	pop    %ebp
  800bf6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf7:	83 ec 0c             	sub    $0xc,%esp
  800bfa:	50                   	push   %eax
  800bfb:	6a 03                	push   $0x3
  800bfd:	68 9f 2a 80 00       	push   $0x802a9f
  800c02:	6a 2a                	push   $0x2a
  800c04:	68 bc 2a 80 00       	push   $0x802abc
  800c09:	e8 8d f5 ff ff       	call   80019b <_panic>

00800c0e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	57                   	push   %edi
  800c12:	56                   	push   %esi
  800c13:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c14:	ba 00 00 00 00       	mov    $0x0,%edx
  800c19:	b8 02 00 00 00       	mov    $0x2,%eax
  800c1e:	89 d1                	mov    %edx,%ecx
  800c20:	89 d3                	mov    %edx,%ebx
  800c22:	89 d7                	mov    %edx,%edi
  800c24:	89 d6                	mov    %edx,%esi
  800c26:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800c28:	5b                   	pop    %ebx
  800c29:	5e                   	pop    %esi
  800c2a:	5f                   	pop    %edi
  800c2b:	5d                   	pop    %ebp
  800c2c:	c3                   	ret    

00800c2d <sys_yield>:

void
sys_yield(void)
{
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c33:	ba 00 00 00 00       	mov    $0x0,%edx
  800c38:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c3d:	89 d1                	mov    %edx,%ecx
  800c3f:	89 d3                	mov    %edx,%ebx
  800c41:	89 d7                	mov    %edx,%edi
  800c43:	89 d6                	mov    %edx,%esi
  800c45:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800c47:	5b                   	pop    %ebx
  800c48:	5e                   	pop    %esi
  800c49:	5f                   	pop    %edi
  800c4a:	5d                   	pop    %ebp
  800c4b:	c3                   	ret    

00800c4c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	57                   	push   %edi
  800c50:	56                   	push   %esi
  800c51:	53                   	push   %ebx
  800c52:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c55:	be 00 00 00 00       	mov    $0x0,%esi
  800c5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c60:	b8 04 00 00 00       	mov    $0x4,%eax
  800c65:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c68:	89 f7                	mov    %esi,%edi
  800c6a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	7f 08                	jg     800c78 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800c70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c73:	5b                   	pop    %ebx
  800c74:	5e                   	pop    %esi
  800c75:	5f                   	pop    %edi
  800c76:	5d                   	pop    %ebp
  800c77:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c78:	83 ec 0c             	sub    $0xc,%esp
  800c7b:	50                   	push   %eax
  800c7c:	6a 04                	push   $0x4
  800c7e:	68 9f 2a 80 00       	push   $0x802a9f
  800c83:	6a 2a                	push   $0x2a
  800c85:	68 bc 2a 80 00       	push   $0x802abc
  800c8a:	e8 0c f5 ff ff       	call   80019b <_panic>

00800c8f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	57                   	push   %edi
  800c93:	56                   	push   %esi
  800c94:	53                   	push   %ebx
  800c95:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9e:	b8 05 00 00 00       	mov    $0x5,%eax
  800ca3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ca6:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ca9:	8b 75 18             	mov    0x18(%ebp),%esi
  800cac:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cae:	85 c0                	test   %eax,%eax
  800cb0:	7f 08                	jg     800cba <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800cb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cba:	83 ec 0c             	sub    $0xc,%esp
  800cbd:	50                   	push   %eax
  800cbe:	6a 05                	push   $0x5
  800cc0:	68 9f 2a 80 00       	push   $0x802a9f
  800cc5:	6a 2a                	push   $0x2a
  800cc7:	68 bc 2a 80 00       	push   $0x802abc
  800ccc:	e8 ca f4 ff ff       	call   80019b <_panic>

00800cd1 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce5:	b8 06 00 00 00       	mov    $0x6,%eax
  800cea:	89 df                	mov    %ebx,%edi
  800cec:	89 de                	mov    %ebx,%esi
  800cee:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	7f 08                	jg     800cfc <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800cf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800cfc:	83 ec 0c             	sub    $0xc,%esp
  800cff:	50                   	push   %eax
  800d00:	6a 06                	push   $0x6
  800d02:	68 9f 2a 80 00       	push   $0x802a9f
  800d07:	6a 2a                	push   $0x2a
  800d09:	68 bc 2a 80 00       	push   $0x802abc
  800d0e:	e8 88 f4 ff ff       	call   80019b <_panic>

00800d13 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d13:	55                   	push   %ebp
  800d14:	89 e5                	mov    %esp,%ebp
  800d16:	57                   	push   %edi
  800d17:	56                   	push   %esi
  800d18:	53                   	push   %ebx
  800d19:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d1c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d21:	8b 55 08             	mov    0x8(%ebp),%edx
  800d24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d27:	b8 08 00 00 00       	mov    $0x8,%eax
  800d2c:	89 df                	mov    %ebx,%edi
  800d2e:	89 de                	mov    %ebx,%esi
  800d30:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d32:	85 c0                	test   %eax,%eax
  800d34:	7f 08                	jg     800d3e <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800d36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d39:	5b                   	pop    %ebx
  800d3a:	5e                   	pop    %esi
  800d3b:	5f                   	pop    %edi
  800d3c:	5d                   	pop    %ebp
  800d3d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d3e:	83 ec 0c             	sub    $0xc,%esp
  800d41:	50                   	push   %eax
  800d42:	6a 08                	push   $0x8
  800d44:	68 9f 2a 80 00       	push   $0x802a9f
  800d49:	6a 2a                	push   $0x2a
  800d4b:	68 bc 2a 80 00       	push   $0x802abc
  800d50:	e8 46 f4 ff ff       	call   80019b <_panic>

00800d55 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	57                   	push   %edi
  800d59:	56                   	push   %esi
  800d5a:	53                   	push   %ebx
  800d5b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d5e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d63:	8b 55 08             	mov    0x8(%ebp),%edx
  800d66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d69:	b8 09 00 00 00       	mov    $0x9,%eax
  800d6e:	89 df                	mov    %ebx,%edi
  800d70:	89 de                	mov    %ebx,%esi
  800d72:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d74:	85 c0                	test   %eax,%eax
  800d76:	7f 08                	jg     800d80 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800d78:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7b:	5b                   	pop    %ebx
  800d7c:	5e                   	pop    %esi
  800d7d:	5f                   	pop    %edi
  800d7e:	5d                   	pop    %ebp
  800d7f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	50                   	push   %eax
  800d84:	6a 09                	push   $0x9
  800d86:	68 9f 2a 80 00       	push   $0x802a9f
  800d8b:	6a 2a                	push   $0x2a
  800d8d:	68 bc 2a 80 00       	push   $0x802abc
  800d92:	e8 04 f4 ff ff       	call   80019b <_panic>

00800d97 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	57                   	push   %edi
  800d9b:	56                   	push   %esi
  800d9c:	53                   	push   %ebx
  800d9d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da0:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da5:	8b 55 08             	mov    0x8(%ebp),%edx
  800da8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dab:	b8 0a 00 00 00       	mov    $0xa,%eax
  800db0:	89 df                	mov    %ebx,%edi
  800db2:	89 de                	mov    %ebx,%esi
  800db4:	cd 30                	int    $0x30
	if(check && ret > 0)
  800db6:	85 c0                	test   %eax,%eax
  800db8:	7f 08                	jg     800dc2 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800dba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dbd:	5b                   	pop    %ebx
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc2:	83 ec 0c             	sub    $0xc,%esp
  800dc5:	50                   	push   %eax
  800dc6:	6a 0a                	push   $0xa
  800dc8:	68 9f 2a 80 00       	push   $0x802a9f
  800dcd:	6a 2a                	push   $0x2a
  800dcf:	68 bc 2a 80 00       	push   $0x802abc
  800dd4:	e8 c2 f3 ff ff       	call   80019b <_panic>

00800dd9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	57                   	push   %edi
  800ddd:	56                   	push   %esi
  800dde:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ddf:	8b 55 08             	mov    0x8(%ebp),%edx
  800de2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dea:	be 00 00 00 00       	mov    $0x0,%esi
  800def:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800df2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800df5:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800df7:	5b                   	pop    %ebx
  800df8:	5e                   	pop    %esi
  800df9:	5f                   	pop    %edi
  800dfa:	5d                   	pop    %ebp
  800dfb:	c3                   	ret    

00800dfc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	57                   	push   %edi
  800e00:	56                   	push   %esi
  800e01:	53                   	push   %ebx
  800e02:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e05:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e12:	89 cb                	mov    %ecx,%ebx
  800e14:	89 cf                	mov    %ecx,%edi
  800e16:	89 ce                	mov    %ecx,%esi
  800e18:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e1a:	85 c0                	test   %eax,%eax
  800e1c:	7f 08                	jg     800e26 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e1e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e21:	5b                   	pop    %ebx
  800e22:	5e                   	pop    %esi
  800e23:	5f                   	pop    %edi
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e26:	83 ec 0c             	sub    $0xc,%esp
  800e29:	50                   	push   %eax
  800e2a:	6a 0d                	push   $0xd
  800e2c:	68 9f 2a 80 00       	push   $0x802a9f
  800e31:	6a 2a                	push   $0x2a
  800e33:	68 bc 2a 80 00       	push   $0x802abc
  800e38:	e8 5e f3 ff ff       	call   80019b <_panic>

00800e3d <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	57                   	push   %edi
  800e41:	56                   	push   %esi
  800e42:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e43:	ba 00 00 00 00       	mov    $0x0,%edx
  800e48:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e4d:	89 d1                	mov    %edx,%ecx
  800e4f:	89 d3                	mov    %edx,%ebx
  800e51:	89 d7                	mov    %edx,%edi
  800e53:	89 d6                	mov    %edx,%esi
  800e55:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800e57:	5b                   	pop    %ebx
  800e58:	5e                   	pop    %esi
  800e59:	5f                   	pop    %edi
  800e5a:	5d                   	pop    %ebp
  800e5b:	c3                   	ret    

00800e5c <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	57                   	push   %edi
  800e60:	56                   	push   %esi
  800e61:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e62:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e67:	8b 55 08             	mov    0x8(%ebp),%edx
  800e6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6d:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e72:	89 df                	mov    %ebx,%edi
  800e74:	89 de                	mov    %ebx,%esi
  800e76:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800e78:	5b                   	pop    %ebx
  800e79:	5e                   	pop    %esi
  800e7a:	5f                   	pop    %edi
  800e7b:	5d                   	pop    %ebp
  800e7c:	c3                   	ret    

00800e7d <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800e7d:	55                   	push   %ebp
  800e7e:	89 e5                	mov    %esp,%ebp
  800e80:	57                   	push   %edi
  800e81:	56                   	push   %esi
  800e82:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e88:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8e:	b8 10 00 00 00       	mov    $0x10,%eax
  800e93:	89 df                	mov    %ebx,%edi
  800e95:	89 de                	mov    %ebx,%esi
  800e97:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800e99:	5b                   	pop    %ebx
  800e9a:	5e                   	pop    %esi
  800e9b:	5f                   	pop    %edi
  800e9c:	5d                   	pop    %ebp
  800e9d:	c3                   	ret    

00800e9e <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800e9e:	55                   	push   %ebp
  800e9f:	89 e5                	mov    %esp,%ebp
  800ea1:	56                   	push   %esi
  800ea2:	53                   	push   %ebx
  800ea3:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ea6:	8b 30                	mov    (%eax),%esi
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	//2.
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800ea8:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800eac:	0f 84 8e 00 00 00    	je     800f40 <pgfault+0xa2>
  800eb2:	89 f0                	mov    %esi,%eax
  800eb4:	c1 e8 0c             	shr    $0xc,%eax
  800eb7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ebe:	f6 c4 08             	test   $0x8,%ah
  800ec1:	74 7d                	je     800f40 <pgfault+0xa2>
	//   You should make three system calls.

	// LAB 4: Your code here.
	//panic("pgfault not implemented");
	//3.
	envid_t envid = sys_getenvid();
  800ec3:	e8 46 fd ff ff       	call   800c0e <sys_getenvid>
  800ec8:	89 c3                	mov    %eax,%ebx
	r = sys_page_alloc(envid, (void *)PFTEMP, PTE_P | PTE_W | PTE_U);
  800eca:	83 ec 04             	sub    $0x4,%esp
  800ecd:	6a 07                	push   $0x7
  800ecf:	68 00 f0 7f 00       	push   $0x7ff000
  800ed4:	50                   	push   %eax
  800ed5:	e8 72 fd ff ff       	call   800c4c <sys_page_alloc>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800eda:	83 c4 10             	add    $0x10,%esp
  800edd:	85 c0                	test   %eax,%eax
  800edf:	78 73                	js     800f54 <pgfault+0xb6>
        
        addr = ROUNDDOWN(addr, PGSIZE);
  800ee1:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
        memmove(PFTEMP, addr, PGSIZE);
  800ee7:	83 ec 04             	sub    $0x4,%esp
  800eea:	68 00 10 00 00       	push   $0x1000
  800eef:	56                   	push   %esi
  800ef0:	68 00 f0 7f 00       	push   $0x7ff000
  800ef5:	e8 ec fa ff ff       	call   8009e6 <memmove>
	if ((r = sys_page_unmap(envid, addr)) < 0)
  800efa:	83 c4 08             	add    $0x8,%esp
  800efd:	56                   	push   %esi
  800efe:	53                   	push   %ebx
  800eff:	e8 cd fd ff ff       	call   800cd1 <sys_page_unmap>
  800f04:	83 c4 10             	add    $0x10,%esp
  800f07:	85 c0                	test   %eax,%eax
  800f09:	78 5b                	js     800f66 <pgfault+0xc8>
		panic("pgfault: page unmap failed (%e)", r);
	if ((r = sys_page_map(envid, PFTEMP, envid, addr, PTE_P | PTE_W |PTE_U)) < 0)
  800f0b:	83 ec 0c             	sub    $0xc,%esp
  800f0e:	6a 07                	push   $0x7
  800f10:	56                   	push   %esi
  800f11:	53                   	push   %ebx
  800f12:	68 00 f0 7f 00       	push   $0x7ff000
  800f17:	53                   	push   %ebx
  800f18:	e8 72 fd ff ff       	call   800c8f <sys_page_map>
  800f1d:	83 c4 20             	add    $0x20,%esp
  800f20:	85 c0                	test   %eax,%eax
  800f22:	78 54                	js     800f78 <pgfault+0xda>
		panic("pgfault: page map failed (%e)", r);
	if ((r = sys_page_unmap(envid, PFTEMP)) < 0)
  800f24:	83 ec 08             	sub    $0x8,%esp
  800f27:	68 00 f0 7f 00       	push   $0x7ff000
  800f2c:	53                   	push   %ebx
  800f2d:	e8 9f fd ff ff       	call   800cd1 <sys_page_unmap>
  800f32:	83 c4 10             	add    $0x10,%esp
  800f35:	85 c0                	test   %eax,%eax
  800f37:	78 51                	js     800f8a <pgfault+0xec>
		panic("pgfault: page unmap failed (%e)", r);
}	
  800f39:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f3c:	5b                   	pop    %ebx
  800f3d:	5e                   	pop    %esi
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    
	if( (err & FEC_WR)==0 || (uvpt[PGNUM(addr)] & PTE_COW)==0 ) panic("pgfault: invalid user trap frame(not a write or to COW)");
  800f40:	83 ec 04             	sub    $0x4,%esp
  800f43:	68 cc 2a 80 00       	push   $0x802acc
  800f48:	6a 1d                	push   $0x1d
  800f4a:	68 48 2b 80 00       	push   $0x802b48
  800f4f:	e8 47 f2 ff ff       	call   80019b <_panic>
        if(r<0) panic("pgfault: page allocation failed %e", r);
  800f54:	50                   	push   %eax
  800f55:	68 04 2b 80 00       	push   $0x802b04
  800f5a:	6a 29                	push   $0x29
  800f5c:	68 48 2b 80 00       	push   $0x802b48
  800f61:	e8 35 f2 ff ff       	call   80019b <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800f66:	50                   	push   %eax
  800f67:	68 28 2b 80 00       	push   $0x802b28
  800f6c:	6a 2e                	push   $0x2e
  800f6e:	68 48 2b 80 00       	push   $0x802b48
  800f73:	e8 23 f2 ff ff       	call   80019b <_panic>
		panic("pgfault: page map failed (%e)", r);
  800f78:	50                   	push   %eax
  800f79:	68 53 2b 80 00       	push   $0x802b53
  800f7e:	6a 30                	push   $0x30
  800f80:	68 48 2b 80 00       	push   $0x802b48
  800f85:	e8 11 f2 ff ff       	call   80019b <_panic>
		panic("pgfault: page unmap failed (%e)", r);
  800f8a:	50                   	push   %eax
  800f8b:	68 28 2b 80 00       	push   $0x802b28
  800f90:	6a 32                	push   $0x32
  800f92:	68 48 2b 80 00       	push   $0x802b48
  800f97:	e8 ff f1 ff ff       	call   80019b <_panic>

00800f9c <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800f9c:	55                   	push   %ebp
  800f9d:	89 e5                	mov    %esp,%ebp
  800f9f:	57                   	push   %edi
  800fa0:	56                   	push   %esi
  800fa1:	53                   	push   %ebx
  800fa2:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	//panic("fork not implemented");
	//仿照dumbfork.c中的dumbfork()写
	//1.
	set_pgfault_handler(pgfault);
  800fa5:	68 9e 0e 80 00       	push   $0x800e9e
  800faa:	e8 7e 12 00 00       	call   80222d <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800faf:	b8 07 00 00 00       	mov    $0x7,%eax
  800fb4:	cd 30                	int    $0x30
  800fb6:	89 45 dc             	mov    %eax,-0x24(%ebp)
	//2.
	envid_t envid=sys_exofork();
	if (envid < 0)
  800fb9:	83 c4 10             	add    $0x10,%esp
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	78 30                	js     800ff0 <fork+0x54>
	
	//3.
	// We're the parent.
	// 此处与dumbfork()不同, uvpt,uvpd用法见于 memlayout.h 与lib/entry.S
	int r;
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  800fc0:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800fc5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800fc9:	75 76                	jne    801041 <fork+0xa5>
		thisenv = &envs[ENVX(sys_getenvid())];
  800fcb:	e8 3e fc ff ff       	call   800c0e <sys_getenvid>
  800fd0:	25 ff 03 00 00       	and    $0x3ff,%eax
  800fd5:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800fdb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800fe0:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  800fe5:	8b 45 dc             	mov    -0x24(%ebp),%eax
	//5.
	r = sys_env_set_status(envid, ENV_RUNNABLE);
	if(r<0) return r;
	
	return envid;
}
  800fe8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800feb:	5b                   	pop    %ebx
  800fec:	5e                   	pop    %esi
  800fed:	5f                   	pop    %edi
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    
		panic("sys_exofork: %e", envid);
  800ff0:	50                   	push   %eax
  800ff1:	68 71 2b 80 00       	push   $0x802b71
  800ff6:	6a 78                	push   $0x78
  800ff8:	68 48 2b 80 00       	push   $0x802b48
  800ffd:	e8 99 f1 ff ff       	call   80019b <_panic>
	r=sys_page_map(this_envid, va, envid, va, perm);//一定要用系统调用， 因为权限！！
  801002:	83 ec 0c             	sub    $0xc,%esp
  801005:	ff 75 e4             	push   -0x1c(%ebp)
  801008:	57                   	push   %edi
  801009:	ff 75 dc             	push   -0x24(%ebp)
  80100c:	57                   	push   %edi
  80100d:	8b 75 e0             	mov    -0x20(%ebp),%esi
  801010:	56                   	push   %esi
  801011:	e8 79 fc ff ff       	call   800c8f <sys_page_map>
	if(r<0) return r;
  801016:	83 c4 20             	add    $0x20,%esp
  801019:	85 c0                	test   %eax,%eax
  80101b:	78 cb                	js     800fe8 <fork+0x4c>
	r=sys_page_map(this_envid, va, this_envid, va, perm);
  80101d:	83 ec 0c             	sub    $0xc,%esp
  801020:	ff 75 e4             	push   -0x1c(%ebp)
  801023:	57                   	push   %edi
  801024:	56                   	push   %esi
  801025:	57                   	push   %edi
  801026:	56                   	push   %esi
  801027:	e8 63 fc ff ff       	call   800c8f <sys_page_map>
		    if( ( r=duppage( envid, PGNUM(addr) ) )< 0 ) return r;
  80102c:	83 c4 20             	add    $0x20,%esp
  80102f:	85 c0                	test   %eax,%eax
  801031:	78 76                	js     8010a9 <fork+0x10d>
	for (uintptr_t addr = UTEXT; addr < USTACKTOP; addr += PGSIZE) {/*UTEXT: Where user programs generally begin*/
  801033:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801039:	81 fb 00 e0 bf ee    	cmp    $0xeebfe000,%ebx
  80103f:	74 75                	je     8010b6 <fork+0x11a>
		if ( (uvpd[PDX(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_P) ) {
  801041:	89 d8                	mov    %ebx,%eax
  801043:	c1 e8 16             	shr    $0x16,%eax
  801046:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80104d:	a8 01                	test   $0x1,%al
  80104f:	74 e2                	je     801033 <fork+0x97>
  801051:	89 de                	mov    %ebx,%esi
  801053:	c1 ee 0c             	shr    $0xc,%esi
  801056:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  80105d:	a8 01                	test   $0x1,%al
  80105f:	74 d2                	je     801033 <fork+0x97>
	envid_t this_envid = sys_getenvid();//父进程号
  801061:	e8 a8 fb ff ff       	call   800c0e <sys_getenvid>
  801066:	89 45 e0             	mov    %eax,-0x20(%ebp)
	void * va = (void *)(pn * PGSIZE);
  801069:	89 f7                	mov    %esi,%edi
  80106b:	c1 e7 0c             	shl    $0xc,%edi
	int perm = uvpt[pn] & PTE_SYSCALL;
  80106e:	8b 04 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%eax
  801075:	89 c1                	mov    %eax,%ecx
  801077:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  80107d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
	if ( uvpt[pn] & PTE_SHARE ){/* lab5 exercise8 */
  801080:	8b 14 b5 00 00 40 ef 	mov    -0x10c00000(,%esi,4),%edx
  801087:	f6 c6 04             	test   $0x4,%dh
  80108a:	0f 85 72 ff ff ff    	jne    801002 <fork+0x66>
		perm &= ~PTE_W;
  801090:	25 05 0e 00 00       	and    $0xe05,%eax
  801095:	80 cc 08             	or     $0x8,%ah
  801098:	f7 c1 02 08 00 00    	test   $0x802,%ecx
  80109e:	0f 44 c1             	cmove  %ecx,%eax
  8010a1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010a4:	e9 59 ff ff ff       	jmp    801002 <fork+0x66>
  8010a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8010ae:	0f 4f c2             	cmovg  %edx,%eax
  8010b1:	e9 32 ff ff ff       	jmp    800fe8 <fork+0x4c>
	r=sys_page_alloc(envid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_W | PTE_P);
  8010b6:	83 ec 04             	sub    $0x4,%esp
  8010b9:	6a 07                	push   $0x7
  8010bb:	68 00 f0 bf ee       	push   $0xeebff000
  8010c0:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8010c3:	57                   	push   %edi
  8010c4:	e8 83 fb ff ff       	call   800c4c <sys_page_alloc>
	if(r<0) return r;
  8010c9:	83 c4 10             	add    $0x10,%esp
  8010cc:	85 c0                	test   %eax,%eax
  8010ce:	0f 88 14 ff ff ff    	js     800fe8 <fork+0x4c>
	r=sys_env_set_pgfault_upcall(envid, _pgfault_upcall);
  8010d4:	83 ec 08             	sub    $0x8,%esp
  8010d7:	68 a3 22 80 00       	push   $0x8022a3
  8010dc:	57                   	push   %edi
  8010dd:	e8 b5 fc ff ff       	call   800d97 <sys_env_set_pgfault_upcall>
	if(r<0) return r;
  8010e2:	83 c4 10             	add    $0x10,%esp
  8010e5:	85 c0                	test   %eax,%eax
  8010e7:	0f 88 fb fe ff ff    	js     800fe8 <fork+0x4c>
	r = sys_env_set_status(envid, ENV_RUNNABLE);
  8010ed:	83 ec 08             	sub    $0x8,%esp
  8010f0:	6a 02                	push   $0x2
  8010f2:	57                   	push   %edi
  8010f3:	e8 1b fc ff ff       	call   800d13 <sys_env_set_status>
	if(r<0) return r;
  8010f8:	83 c4 10             	add    $0x10,%esp
	return envid;
  8010fb:	85 c0                	test   %eax,%eax
  8010fd:	0f 49 c7             	cmovns %edi,%eax
  801100:	e9 e3 fe ff ff       	jmp    800fe8 <fork+0x4c>

00801105 <sfork>:

// Challenge!
int
sfork(void)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80110b:	68 81 2b 80 00       	push   $0x802b81
  801110:	68 a1 00 00 00       	push   $0xa1
  801115:	68 48 2b 80 00       	push   $0x802b48
  80111a:	e8 7c f0 ff ff       	call   80019b <_panic>

0080111f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801122:	8b 45 08             	mov    0x8(%ebp),%eax
  801125:	05 00 00 00 30       	add    $0x30000000,%eax
  80112a:	c1 e8 0c             	shr    $0xc,%eax
}
  80112d:	5d                   	pop    %ebp
  80112e:	c3                   	ret    

0080112f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801132:	8b 45 08             	mov    0x8(%ebp),%eax
  801135:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80113a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80113f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801144:	5d                   	pop    %ebp
  801145:	c3                   	ret    

00801146 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801146:	55                   	push   %ebp
  801147:	89 e5                	mov    %esp,%ebp
  801149:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80114e:	89 c2                	mov    %eax,%edx
  801150:	c1 ea 16             	shr    $0x16,%edx
  801153:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80115a:	f6 c2 01             	test   $0x1,%dl
  80115d:	74 29                	je     801188 <fd_alloc+0x42>
  80115f:	89 c2                	mov    %eax,%edx
  801161:	c1 ea 0c             	shr    $0xc,%edx
  801164:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80116b:	f6 c2 01             	test   $0x1,%dl
  80116e:	74 18                	je     801188 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  801170:	05 00 10 00 00       	add    $0x1000,%eax
  801175:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80117a:	75 d2                	jne    80114e <fd_alloc+0x8>
  80117c:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  801181:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  801186:	eb 05                	jmp    80118d <fd_alloc+0x47>
			return 0;
  801188:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80118d:	8b 55 08             	mov    0x8(%ebp),%edx
  801190:	89 02                	mov    %eax,(%edx)
}
  801192:	89 c8                	mov    %ecx,%eax
  801194:	5d                   	pop    %ebp
  801195:	c3                   	ret    

00801196 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801196:	55                   	push   %ebp
  801197:	89 e5                	mov    %esp,%ebp
  801199:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80119c:	83 f8 1f             	cmp    $0x1f,%eax
  80119f:	77 30                	ja     8011d1 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011a1:	c1 e0 0c             	shl    $0xc,%eax
  8011a4:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8011a9:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8011af:	f6 c2 01             	test   $0x1,%dl
  8011b2:	74 24                	je     8011d8 <fd_lookup+0x42>
  8011b4:	89 c2                	mov    %eax,%edx
  8011b6:	c1 ea 0c             	shr    $0xc,%edx
  8011b9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011c0:	f6 c2 01             	test   $0x1,%dl
  8011c3:	74 1a                	je     8011df <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8011c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c8:	89 02                	mov    %eax,(%edx)
	return 0;
  8011ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    
		return -E_INVAL;
  8011d1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011d6:	eb f7                	jmp    8011cf <fd_lookup+0x39>
		return -E_INVAL;
  8011d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011dd:	eb f0                	jmp    8011cf <fd_lookup+0x39>
  8011df:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011e4:	eb e9                	jmp    8011cf <fd_lookup+0x39>

008011e6 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011e6:	55                   	push   %ebp
  8011e7:	89 e5                	mov    %esp,%ebp
  8011e9:	53                   	push   %ebx
  8011ea:	83 ec 04             	sub    $0x4,%esp
  8011ed:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8011f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f5:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8011fa:	39 13                	cmp    %edx,(%ebx)
  8011fc:	74 37                	je     801235 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8011fe:	83 c0 01             	add    $0x1,%eax
  801201:	8b 1c 85 14 2c 80 00 	mov    0x802c14(,%eax,4),%ebx
  801208:	85 db                	test   %ebx,%ebx
  80120a:	75 ee                	jne    8011fa <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80120c:	a1 00 40 80 00       	mov    0x804000,%eax
  801211:	8b 40 58             	mov    0x58(%eax),%eax
  801214:	83 ec 04             	sub    $0x4,%esp
  801217:	52                   	push   %edx
  801218:	50                   	push   %eax
  801219:	68 98 2b 80 00       	push   $0x802b98
  80121e:	e8 53 f0 ff ff       	call   800276 <cprintf>
	*dev = 0;
	return -E_INVAL;
  801223:	83 c4 10             	add    $0x10,%esp
  801226:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  80122b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122e:	89 1a                	mov    %ebx,(%edx)
}
  801230:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801233:	c9                   	leave  
  801234:	c3                   	ret    
			return 0;
  801235:	b8 00 00 00 00       	mov    $0x0,%eax
  80123a:	eb ef                	jmp    80122b <dev_lookup+0x45>

0080123c <fd_close>:
{
  80123c:	55                   	push   %ebp
  80123d:	89 e5                	mov    %esp,%ebp
  80123f:	57                   	push   %edi
  801240:	56                   	push   %esi
  801241:	53                   	push   %ebx
  801242:	83 ec 24             	sub    $0x24,%esp
  801245:	8b 75 08             	mov    0x8(%ebp),%esi
  801248:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80124b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80124e:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80124f:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801255:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801258:	50                   	push   %eax
  801259:	e8 38 ff ff ff       	call   801196 <fd_lookup>
  80125e:	89 c3                	mov    %eax,%ebx
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	85 c0                	test   %eax,%eax
  801265:	78 05                	js     80126c <fd_close+0x30>
	    || fd != fd2)
  801267:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80126a:	74 16                	je     801282 <fd_close+0x46>
		return (must_exist ? r : 0);
  80126c:	89 f8                	mov    %edi,%eax
  80126e:	84 c0                	test   %al,%al
  801270:	b8 00 00 00 00       	mov    $0x0,%eax
  801275:	0f 44 d8             	cmove  %eax,%ebx
}
  801278:	89 d8                	mov    %ebx,%eax
  80127a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80127d:	5b                   	pop    %ebx
  80127e:	5e                   	pop    %esi
  80127f:	5f                   	pop    %edi
  801280:	5d                   	pop    %ebp
  801281:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801282:	83 ec 08             	sub    $0x8,%esp
  801285:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801288:	50                   	push   %eax
  801289:	ff 36                	push   (%esi)
  80128b:	e8 56 ff ff ff       	call   8011e6 <dev_lookup>
  801290:	89 c3                	mov    %eax,%ebx
  801292:	83 c4 10             	add    $0x10,%esp
  801295:	85 c0                	test   %eax,%eax
  801297:	78 1a                	js     8012b3 <fd_close+0x77>
		if (dev->dev_close)
  801299:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80129c:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80129f:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8012a4:	85 c0                	test   %eax,%eax
  8012a6:	74 0b                	je     8012b3 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8012a8:	83 ec 0c             	sub    $0xc,%esp
  8012ab:	56                   	push   %esi
  8012ac:	ff d0                	call   *%eax
  8012ae:	89 c3                	mov    %eax,%ebx
  8012b0:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8012b3:	83 ec 08             	sub    $0x8,%esp
  8012b6:	56                   	push   %esi
  8012b7:	6a 00                	push   $0x0
  8012b9:	e8 13 fa ff ff       	call   800cd1 <sys_page_unmap>
	return r;
  8012be:	83 c4 10             	add    $0x10,%esp
  8012c1:	eb b5                	jmp    801278 <fd_close+0x3c>

008012c3 <close>:

int
close(int fdnum)
{
  8012c3:	55                   	push   %ebp
  8012c4:	89 e5                	mov    %esp,%ebp
  8012c6:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012cc:	50                   	push   %eax
  8012cd:	ff 75 08             	push   0x8(%ebp)
  8012d0:	e8 c1 fe ff ff       	call   801196 <fd_lookup>
  8012d5:	83 c4 10             	add    $0x10,%esp
  8012d8:	85 c0                	test   %eax,%eax
  8012da:	79 02                	jns    8012de <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8012dc:	c9                   	leave  
  8012dd:	c3                   	ret    
		return fd_close(fd, 1);
  8012de:	83 ec 08             	sub    $0x8,%esp
  8012e1:	6a 01                	push   $0x1
  8012e3:	ff 75 f4             	push   -0xc(%ebp)
  8012e6:	e8 51 ff ff ff       	call   80123c <fd_close>
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	eb ec                	jmp    8012dc <close+0x19>

008012f0 <close_all>:

void
close_all(void)
{
  8012f0:	55                   	push   %ebp
  8012f1:	89 e5                	mov    %esp,%ebp
  8012f3:	53                   	push   %ebx
  8012f4:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8012f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8012fc:	83 ec 0c             	sub    $0xc,%esp
  8012ff:	53                   	push   %ebx
  801300:	e8 be ff ff ff       	call   8012c3 <close>
	for (i = 0; i < MAXFD; i++)
  801305:	83 c3 01             	add    $0x1,%ebx
  801308:	83 c4 10             	add    $0x10,%esp
  80130b:	83 fb 20             	cmp    $0x20,%ebx
  80130e:	75 ec                	jne    8012fc <close_all+0xc>
}
  801310:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801313:	c9                   	leave  
  801314:	c3                   	ret    

00801315 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801315:	55                   	push   %ebp
  801316:	89 e5                	mov    %esp,%ebp
  801318:	57                   	push   %edi
  801319:	56                   	push   %esi
  80131a:	53                   	push   %ebx
  80131b:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80131e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801321:	50                   	push   %eax
  801322:	ff 75 08             	push   0x8(%ebp)
  801325:	e8 6c fe ff ff       	call   801196 <fd_lookup>
  80132a:	89 c3                	mov    %eax,%ebx
  80132c:	83 c4 10             	add    $0x10,%esp
  80132f:	85 c0                	test   %eax,%eax
  801331:	78 7f                	js     8013b2 <dup+0x9d>
		return r;
	close(newfdnum);
  801333:	83 ec 0c             	sub    $0xc,%esp
  801336:	ff 75 0c             	push   0xc(%ebp)
  801339:	e8 85 ff ff ff       	call   8012c3 <close>

	newfd = INDEX2FD(newfdnum);
  80133e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801341:	c1 e6 0c             	shl    $0xc,%esi
  801344:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80134a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80134d:	89 3c 24             	mov    %edi,(%esp)
  801350:	e8 da fd ff ff       	call   80112f <fd2data>
  801355:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801357:	89 34 24             	mov    %esi,(%esp)
  80135a:	e8 d0 fd ff ff       	call   80112f <fd2data>
  80135f:	83 c4 10             	add    $0x10,%esp
  801362:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801365:	89 d8                	mov    %ebx,%eax
  801367:	c1 e8 16             	shr    $0x16,%eax
  80136a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801371:	a8 01                	test   $0x1,%al
  801373:	74 11                	je     801386 <dup+0x71>
  801375:	89 d8                	mov    %ebx,%eax
  801377:	c1 e8 0c             	shr    $0xc,%eax
  80137a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801381:	f6 c2 01             	test   $0x1,%dl
  801384:	75 36                	jne    8013bc <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801386:	89 f8                	mov    %edi,%eax
  801388:	c1 e8 0c             	shr    $0xc,%eax
  80138b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801392:	83 ec 0c             	sub    $0xc,%esp
  801395:	25 07 0e 00 00       	and    $0xe07,%eax
  80139a:	50                   	push   %eax
  80139b:	56                   	push   %esi
  80139c:	6a 00                	push   $0x0
  80139e:	57                   	push   %edi
  80139f:	6a 00                	push   $0x0
  8013a1:	e8 e9 f8 ff ff       	call   800c8f <sys_page_map>
  8013a6:	89 c3                	mov    %eax,%ebx
  8013a8:	83 c4 20             	add    $0x20,%esp
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	78 33                	js     8013e2 <dup+0xcd>
		goto err;

	return newfdnum;
  8013af:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8013b2:	89 d8                	mov    %ebx,%eax
  8013b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b7:	5b                   	pop    %ebx
  8013b8:	5e                   	pop    %esi
  8013b9:	5f                   	pop    %edi
  8013ba:	5d                   	pop    %ebp
  8013bb:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013bc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013c3:	83 ec 0c             	sub    $0xc,%esp
  8013c6:	25 07 0e 00 00       	and    $0xe07,%eax
  8013cb:	50                   	push   %eax
  8013cc:	ff 75 d4             	push   -0x2c(%ebp)
  8013cf:	6a 00                	push   $0x0
  8013d1:	53                   	push   %ebx
  8013d2:	6a 00                	push   $0x0
  8013d4:	e8 b6 f8 ff ff       	call   800c8f <sys_page_map>
  8013d9:	89 c3                	mov    %eax,%ebx
  8013db:	83 c4 20             	add    $0x20,%esp
  8013de:	85 c0                	test   %eax,%eax
  8013e0:	79 a4                	jns    801386 <dup+0x71>
	sys_page_unmap(0, newfd);
  8013e2:	83 ec 08             	sub    $0x8,%esp
  8013e5:	56                   	push   %esi
  8013e6:	6a 00                	push   $0x0
  8013e8:	e8 e4 f8 ff ff       	call   800cd1 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8013ed:	83 c4 08             	add    $0x8,%esp
  8013f0:	ff 75 d4             	push   -0x2c(%ebp)
  8013f3:	6a 00                	push   $0x0
  8013f5:	e8 d7 f8 ff ff       	call   800cd1 <sys_page_unmap>
	return r;
  8013fa:	83 c4 10             	add    $0x10,%esp
  8013fd:	eb b3                	jmp    8013b2 <dup+0x9d>

008013ff <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013ff:	55                   	push   %ebp
  801400:	89 e5                	mov    %esp,%ebp
  801402:	56                   	push   %esi
  801403:	53                   	push   %ebx
  801404:	83 ec 18             	sub    $0x18,%esp
  801407:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80140a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80140d:	50                   	push   %eax
  80140e:	56                   	push   %esi
  80140f:	e8 82 fd ff ff       	call   801196 <fd_lookup>
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	85 c0                	test   %eax,%eax
  801419:	78 3c                	js     801457 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80141b:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80141e:	83 ec 08             	sub    $0x8,%esp
  801421:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801424:	50                   	push   %eax
  801425:	ff 33                	push   (%ebx)
  801427:	e8 ba fd ff ff       	call   8011e6 <dev_lookup>
  80142c:	83 c4 10             	add    $0x10,%esp
  80142f:	85 c0                	test   %eax,%eax
  801431:	78 24                	js     801457 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801433:	8b 43 08             	mov    0x8(%ebx),%eax
  801436:	83 e0 03             	and    $0x3,%eax
  801439:	83 f8 01             	cmp    $0x1,%eax
  80143c:	74 20                	je     80145e <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80143e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801441:	8b 40 08             	mov    0x8(%eax),%eax
  801444:	85 c0                	test   %eax,%eax
  801446:	74 37                	je     80147f <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801448:	83 ec 04             	sub    $0x4,%esp
  80144b:	ff 75 10             	push   0x10(%ebp)
  80144e:	ff 75 0c             	push   0xc(%ebp)
  801451:	53                   	push   %ebx
  801452:	ff d0                	call   *%eax
  801454:	83 c4 10             	add    $0x10,%esp
}
  801457:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80145a:	5b                   	pop    %ebx
  80145b:	5e                   	pop    %esi
  80145c:	5d                   	pop    %ebp
  80145d:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80145e:	a1 00 40 80 00       	mov    0x804000,%eax
  801463:	8b 40 58             	mov    0x58(%eax),%eax
  801466:	83 ec 04             	sub    $0x4,%esp
  801469:	56                   	push   %esi
  80146a:	50                   	push   %eax
  80146b:	68 d9 2b 80 00       	push   $0x802bd9
  801470:	e8 01 ee ff ff       	call   800276 <cprintf>
		return -E_INVAL;
  801475:	83 c4 10             	add    $0x10,%esp
  801478:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80147d:	eb d8                	jmp    801457 <read+0x58>
		return -E_NOT_SUPP;
  80147f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801484:	eb d1                	jmp    801457 <read+0x58>

00801486 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801486:	55                   	push   %ebp
  801487:	89 e5                	mov    %esp,%ebp
  801489:	57                   	push   %edi
  80148a:	56                   	push   %esi
  80148b:	53                   	push   %ebx
  80148c:	83 ec 0c             	sub    $0xc,%esp
  80148f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801492:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801495:	bb 00 00 00 00       	mov    $0x0,%ebx
  80149a:	eb 02                	jmp    80149e <readn+0x18>
  80149c:	01 c3                	add    %eax,%ebx
  80149e:	39 f3                	cmp    %esi,%ebx
  8014a0:	73 21                	jae    8014c3 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014a2:	83 ec 04             	sub    $0x4,%esp
  8014a5:	89 f0                	mov    %esi,%eax
  8014a7:	29 d8                	sub    %ebx,%eax
  8014a9:	50                   	push   %eax
  8014aa:	89 d8                	mov    %ebx,%eax
  8014ac:	03 45 0c             	add    0xc(%ebp),%eax
  8014af:	50                   	push   %eax
  8014b0:	57                   	push   %edi
  8014b1:	e8 49 ff ff ff       	call   8013ff <read>
		if (m < 0)
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	78 04                	js     8014c1 <readn+0x3b>
			return m;
		if (m == 0)
  8014bd:	75 dd                	jne    80149c <readn+0x16>
  8014bf:	eb 02                	jmp    8014c3 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014c1:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8014c3:	89 d8                	mov    %ebx,%eax
  8014c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014c8:	5b                   	pop    %ebx
  8014c9:	5e                   	pop    %esi
  8014ca:	5f                   	pop    %edi
  8014cb:	5d                   	pop    %ebp
  8014cc:	c3                   	ret    

008014cd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	56                   	push   %esi
  8014d1:	53                   	push   %ebx
  8014d2:	83 ec 18             	sub    $0x18,%esp
  8014d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014db:	50                   	push   %eax
  8014dc:	53                   	push   %ebx
  8014dd:	e8 b4 fc ff ff       	call   801196 <fd_lookup>
  8014e2:	83 c4 10             	add    $0x10,%esp
  8014e5:	85 c0                	test   %eax,%eax
  8014e7:	78 37                	js     801520 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014e9:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8014ec:	83 ec 08             	sub    $0x8,%esp
  8014ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014f2:	50                   	push   %eax
  8014f3:	ff 36                	push   (%esi)
  8014f5:	e8 ec fc ff ff       	call   8011e6 <dev_lookup>
  8014fa:	83 c4 10             	add    $0x10,%esp
  8014fd:	85 c0                	test   %eax,%eax
  8014ff:	78 1f                	js     801520 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801501:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801505:	74 20                	je     801527 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801507:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80150a:	8b 40 0c             	mov    0xc(%eax),%eax
  80150d:	85 c0                	test   %eax,%eax
  80150f:	74 37                	je     801548 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801511:	83 ec 04             	sub    $0x4,%esp
  801514:	ff 75 10             	push   0x10(%ebp)
  801517:	ff 75 0c             	push   0xc(%ebp)
  80151a:	56                   	push   %esi
  80151b:	ff d0                	call   *%eax
  80151d:	83 c4 10             	add    $0x10,%esp
}
  801520:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801523:	5b                   	pop    %ebx
  801524:	5e                   	pop    %esi
  801525:	5d                   	pop    %ebp
  801526:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801527:	a1 00 40 80 00       	mov    0x804000,%eax
  80152c:	8b 40 58             	mov    0x58(%eax),%eax
  80152f:	83 ec 04             	sub    $0x4,%esp
  801532:	53                   	push   %ebx
  801533:	50                   	push   %eax
  801534:	68 f5 2b 80 00       	push   $0x802bf5
  801539:	e8 38 ed ff ff       	call   800276 <cprintf>
		return -E_INVAL;
  80153e:	83 c4 10             	add    $0x10,%esp
  801541:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801546:	eb d8                	jmp    801520 <write+0x53>
		return -E_NOT_SUPP;
  801548:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80154d:	eb d1                	jmp    801520 <write+0x53>

0080154f <seek>:

int
seek(int fdnum, off_t offset)
{
  80154f:	55                   	push   %ebp
  801550:	89 e5                	mov    %esp,%ebp
  801552:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801555:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801558:	50                   	push   %eax
  801559:	ff 75 08             	push   0x8(%ebp)
  80155c:	e8 35 fc ff ff       	call   801196 <fd_lookup>
  801561:	83 c4 10             	add    $0x10,%esp
  801564:	85 c0                	test   %eax,%eax
  801566:	78 0e                	js     801576 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801568:	8b 55 0c             	mov    0xc(%ebp),%edx
  80156b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80156e:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801571:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801576:	c9                   	leave  
  801577:	c3                   	ret    

00801578 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801578:	55                   	push   %ebp
  801579:	89 e5                	mov    %esp,%ebp
  80157b:	56                   	push   %esi
  80157c:	53                   	push   %ebx
  80157d:	83 ec 18             	sub    $0x18,%esp
  801580:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801583:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801586:	50                   	push   %eax
  801587:	53                   	push   %ebx
  801588:	e8 09 fc ff ff       	call   801196 <fd_lookup>
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	85 c0                	test   %eax,%eax
  801592:	78 34                	js     8015c8 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801594:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801597:	83 ec 08             	sub    $0x8,%esp
  80159a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159d:	50                   	push   %eax
  80159e:	ff 36                	push   (%esi)
  8015a0:	e8 41 fc ff ff       	call   8011e6 <dev_lookup>
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	78 1c                	js     8015c8 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8015ac:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8015b0:	74 1d                	je     8015cf <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8015b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015b5:	8b 40 18             	mov    0x18(%eax),%eax
  8015b8:	85 c0                	test   %eax,%eax
  8015ba:	74 34                	je     8015f0 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8015bc:	83 ec 08             	sub    $0x8,%esp
  8015bf:	ff 75 0c             	push   0xc(%ebp)
  8015c2:	56                   	push   %esi
  8015c3:	ff d0                	call   *%eax
  8015c5:	83 c4 10             	add    $0x10,%esp
}
  8015c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015cb:	5b                   	pop    %ebx
  8015cc:	5e                   	pop    %esi
  8015cd:	5d                   	pop    %ebp
  8015ce:	c3                   	ret    
			thisenv->env_id, fdnum);
  8015cf:	a1 00 40 80 00       	mov    0x804000,%eax
  8015d4:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8015d7:	83 ec 04             	sub    $0x4,%esp
  8015da:	53                   	push   %ebx
  8015db:	50                   	push   %eax
  8015dc:	68 b8 2b 80 00       	push   $0x802bb8
  8015e1:	e8 90 ec ff ff       	call   800276 <cprintf>
		return -E_INVAL;
  8015e6:	83 c4 10             	add    $0x10,%esp
  8015e9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8015ee:	eb d8                	jmp    8015c8 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8015f0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015f5:	eb d1                	jmp    8015c8 <ftruncate+0x50>

008015f7 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8015f7:	55                   	push   %ebp
  8015f8:	89 e5                	mov    %esp,%ebp
  8015fa:	56                   	push   %esi
  8015fb:	53                   	push   %ebx
  8015fc:	83 ec 18             	sub    $0x18,%esp
  8015ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801602:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801605:	50                   	push   %eax
  801606:	ff 75 08             	push   0x8(%ebp)
  801609:	e8 88 fb ff ff       	call   801196 <fd_lookup>
  80160e:	83 c4 10             	add    $0x10,%esp
  801611:	85 c0                	test   %eax,%eax
  801613:	78 49                	js     80165e <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801615:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801618:	83 ec 08             	sub    $0x8,%esp
  80161b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80161e:	50                   	push   %eax
  80161f:	ff 36                	push   (%esi)
  801621:	e8 c0 fb ff ff       	call   8011e6 <dev_lookup>
  801626:	83 c4 10             	add    $0x10,%esp
  801629:	85 c0                	test   %eax,%eax
  80162b:	78 31                	js     80165e <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80162d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801630:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801634:	74 2f                	je     801665 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801636:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801639:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801640:	00 00 00 
	stat->st_isdir = 0;
  801643:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80164a:	00 00 00 
	stat->st_dev = dev;
  80164d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801653:	83 ec 08             	sub    $0x8,%esp
  801656:	53                   	push   %ebx
  801657:	56                   	push   %esi
  801658:	ff 50 14             	call   *0x14(%eax)
  80165b:	83 c4 10             	add    $0x10,%esp
}
  80165e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801661:	5b                   	pop    %ebx
  801662:	5e                   	pop    %esi
  801663:	5d                   	pop    %ebp
  801664:	c3                   	ret    
		return -E_NOT_SUPP;
  801665:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80166a:	eb f2                	jmp    80165e <fstat+0x67>

0080166c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	56                   	push   %esi
  801670:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801671:	83 ec 08             	sub    $0x8,%esp
  801674:	6a 00                	push   $0x0
  801676:	ff 75 08             	push   0x8(%ebp)
  801679:	e8 e4 01 00 00       	call   801862 <open>
  80167e:	89 c3                	mov    %eax,%ebx
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	85 c0                	test   %eax,%eax
  801685:	78 1b                	js     8016a2 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801687:	83 ec 08             	sub    $0x8,%esp
  80168a:	ff 75 0c             	push   0xc(%ebp)
  80168d:	50                   	push   %eax
  80168e:	e8 64 ff ff ff       	call   8015f7 <fstat>
  801693:	89 c6                	mov    %eax,%esi
	close(fd);
  801695:	89 1c 24             	mov    %ebx,(%esp)
  801698:	e8 26 fc ff ff       	call   8012c3 <close>
	return r;
  80169d:	83 c4 10             	add    $0x10,%esp
  8016a0:	89 f3                	mov    %esi,%ebx
}
  8016a2:	89 d8                	mov    %ebx,%eax
  8016a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a7:	5b                   	pop    %ebx
  8016a8:	5e                   	pop    %esi
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    

008016ab <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	56                   	push   %esi
  8016af:	53                   	push   %ebx
  8016b0:	89 c6                	mov    %eax,%esi
  8016b2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8016b4:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8016bb:	74 27                	je     8016e4 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016bd:	6a 07                	push   $0x7
  8016bf:	68 00 50 80 00       	push   $0x805000
  8016c4:	56                   	push   %esi
  8016c5:	ff 35 00 60 80 00    	push   0x806000
  8016cb:	e8 69 0c 00 00       	call   802339 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016d0:	83 c4 0c             	add    $0xc,%esp
  8016d3:	6a 00                	push   $0x0
  8016d5:	53                   	push   %ebx
  8016d6:	6a 00                	push   $0x0
  8016d8:	e8 ec 0b 00 00       	call   8022c9 <ipc_recv>
}
  8016dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e0:	5b                   	pop    %ebx
  8016e1:	5e                   	pop    %esi
  8016e2:	5d                   	pop    %ebp
  8016e3:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016e4:	83 ec 0c             	sub    $0xc,%esp
  8016e7:	6a 01                	push   $0x1
  8016e9:	e8 9f 0c 00 00       	call   80238d <ipc_find_env>
  8016ee:	a3 00 60 80 00       	mov    %eax,0x806000
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	eb c5                	jmp    8016bd <fsipc+0x12>

008016f8 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801701:	8b 40 0c             	mov    0xc(%eax),%eax
  801704:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801709:	8b 45 0c             	mov    0xc(%ebp),%eax
  80170c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801711:	ba 00 00 00 00       	mov    $0x0,%edx
  801716:	b8 02 00 00 00       	mov    $0x2,%eax
  80171b:	e8 8b ff ff ff       	call   8016ab <fsipc>
}
  801720:	c9                   	leave  
  801721:	c3                   	ret    

00801722 <devfile_flush>:
{
  801722:	55                   	push   %ebp
  801723:	89 e5                	mov    %esp,%ebp
  801725:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801728:	8b 45 08             	mov    0x8(%ebp),%eax
  80172b:	8b 40 0c             	mov    0xc(%eax),%eax
  80172e:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801733:	ba 00 00 00 00       	mov    $0x0,%edx
  801738:	b8 06 00 00 00       	mov    $0x6,%eax
  80173d:	e8 69 ff ff ff       	call   8016ab <fsipc>
}
  801742:	c9                   	leave  
  801743:	c3                   	ret    

00801744 <devfile_stat>:
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	53                   	push   %ebx
  801748:	83 ec 04             	sub    $0x4,%esp
  80174b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80174e:	8b 45 08             	mov    0x8(%ebp),%eax
  801751:	8b 40 0c             	mov    0xc(%eax),%eax
  801754:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801759:	ba 00 00 00 00       	mov    $0x0,%edx
  80175e:	b8 05 00 00 00       	mov    $0x5,%eax
  801763:	e8 43 ff ff ff       	call   8016ab <fsipc>
  801768:	85 c0                	test   %eax,%eax
  80176a:	78 2c                	js     801798 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80176c:	83 ec 08             	sub    $0x8,%esp
  80176f:	68 00 50 80 00       	push   $0x805000
  801774:	53                   	push   %ebx
  801775:	e8 d6 f0 ff ff       	call   800850 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80177a:	a1 80 50 80 00       	mov    0x805080,%eax
  80177f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801785:	a1 84 50 80 00       	mov    0x805084,%eax
  80178a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801790:	83 c4 10             	add    $0x10,%esp
  801793:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801798:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179b:	c9                   	leave  
  80179c:	c3                   	ret    

0080179d <devfile_write>:
{
  80179d:	55                   	push   %ebp
  80179e:	89 e5                	mov    %esp,%ebp
  8017a0:	83 ec 0c             	sub    $0xc,%esp
  8017a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017ab:	39 d0                	cmp    %edx,%eax
  8017ad:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8017b3:	8b 52 0c             	mov    0xc(%edx),%edx
  8017b6:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8017bc:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8017c1:	50                   	push   %eax
  8017c2:	ff 75 0c             	push   0xc(%ebp)
  8017c5:	68 08 50 80 00       	push   $0x805008
  8017ca:	e8 17 f2 ff ff       	call   8009e6 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8017cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d4:	b8 04 00 00 00       	mov    $0x4,%eax
  8017d9:	e8 cd fe ff ff       	call   8016ab <fsipc>
}
  8017de:	c9                   	leave  
  8017df:	c3                   	ret    

008017e0 <devfile_read>:
{
  8017e0:	55                   	push   %ebp
  8017e1:	89 e5                	mov    %esp,%ebp
  8017e3:	56                   	push   %esi
  8017e4:	53                   	push   %ebx
  8017e5:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017eb:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ee:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8017f3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8017fe:	b8 03 00 00 00       	mov    $0x3,%eax
  801803:	e8 a3 fe ff ff       	call   8016ab <fsipc>
  801808:	89 c3                	mov    %eax,%ebx
  80180a:	85 c0                	test   %eax,%eax
  80180c:	78 1f                	js     80182d <devfile_read+0x4d>
	assert(r <= n);
  80180e:	39 f0                	cmp    %esi,%eax
  801810:	77 24                	ja     801836 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801812:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801817:	7f 33                	jg     80184c <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801819:	83 ec 04             	sub    $0x4,%esp
  80181c:	50                   	push   %eax
  80181d:	68 00 50 80 00       	push   $0x805000
  801822:	ff 75 0c             	push   0xc(%ebp)
  801825:	e8 bc f1 ff ff       	call   8009e6 <memmove>
	return r;
  80182a:	83 c4 10             	add    $0x10,%esp
}
  80182d:	89 d8                	mov    %ebx,%eax
  80182f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801832:	5b                   	pop    %ebx
  801833:	5e                   	pop    %esi
  801834:	5d                   	pop    %ebp
  801835:	c3                   	ret    
	assert(r <= n);
  801836:	68 28 2c 80 00       	push   $0x802c28
  80183b:	68 2f 2c 80 00       	push   $0x802c2f
  801840:	6a 7c                	push   $0x7c
  801842:	68 44 2c 80 00       	push   $0x802c44
  801847:	e8 4f e9 ff ff       	call   80019b <_panic>
	assert(r <= PGSIZE);
  80184c:	68 4f 2c 80 00       	push   $0x802c4f
  801851:	68 2f 2c 80 00       	push   $0x802c2f
  801856:	6a 7d                	push   $0x7d
  801858:	68 44 2c 80 00       	push   $0x802c44
  80185d:	e8 39 e9 ff ff       	call   80019b <_panic>

00801862 <open>:
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	56                   	push   %esi
  801866:	53                   	push   %ebx
  801867:	83 ec 1c             	sub    $0x1c,%esp
  80186a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80186d:	56                   	push   %esi
  80186e:	e8 a2 ef ff ff       	call   800815 <strlen>
  801873:	83 c4 10             	add    $0x10,%esp
  801876:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80187b:	7f 6c                	jg     8018e9 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80187d:	83 ec 0c             	sub    $0xc,%esp
  801880:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801883:	50                   	push   %eax
  801884:	e8 bd f8 ff ff       	call   801146 <fd_alloc>
  801889:	89 c3                	mov    %eax,%ebx
  80188b:	83 c4 10             	add    $0x10,%esp
  80188e:	85 c0                	test   %eax,%eax
  801890:	78 3c                	js     8018ce <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  801892:	83 ec 08             	sub    $0x8,%esp
  801895:	56                   	push   %esi
  801896:	68 00 50 80 00       	push   $0x805000
  80189b:	e8 b0 ef ff ff       	call   800850 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8018a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018a3:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8018a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018ab:	b8 01 00 00 00       	mov    $0x1,%eax
  8018b0:	e8 f6 fd ff ff       	call   8016ab <fsipc>
  8018b5:	89 c3                	mov    %eax,%ebx
  8018b7:	83 c4 10             	add    $0x10,%esp
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	78 19                	js     8018d7 <open+0x75>
	return fd2num(fd);
  8018be:	83 ec 0c             	sub    $0xc,%esp
  8018c1:	ff 75 f4             	push   -0xc(%ebp)
  8018c4:	e8 56 f8 ff ff       	call   80111f <fd2num>
  8018c9:	89 c3                	mov    %eax,%ebx
  8018cb:	83 c4 10             	add    $0x10,%esp
}
  8018ce:	89 d8                	mov    %ebx,%eax
  8018d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018d3:	5b                   	pop    %ebx
  8018d4:	5e                   	pop    %esi
  8018d5:	5d                   	pop    %ebp
  8018d6:	c3                   	ret    
		fd_close(fd, 0);
  8018d7:	83 ec 08             	sub    $0x8,%esp
  8018da:	6a 00                	push   $0x0
  8018dc:	ff 75 f4             	push   -0xc(%ebp)
  8018df:	e8 58 f9 ff ff       	call   80123c <fd_close>
		return r;
  8018e4:	83 c4 10             	add    $0x10,%esp
  8018e7:	eb e5                	jmp    8018ce <open+0x6c>
		return -E_BAD_PATH;
  8018e9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8018ee:	eb de                	jmp    8018ce <open+0x6c>

008018f0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fb:	b8 08 00 00 00       	mov    $0x8,%eax
  801900:	e8 a6 fd ff ff       	call   8016ab <fsipc>
}
  801905:	c9                   	leave  
  801906:	c3                   	ret    

00801907 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80190d:	68 5b 2c 80 00       	push   $0x802c5b
  801912:	ff 75 0c             	push   0xc(%ebp)
  801915:	e8 36 ef ff ff       	call   800850 <strcpy>
	return 0;
}
  80191a:	b8 00 00 00 00       	mov    $0x0,%eax
  80191f:	c9                   	leave  
  801920:	c3                   	ret    

00801921 <devsock_close>:
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	53                   	push   %ebx
  801925:	83 ec 10             	sub    $0x10,%esp
  801928:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80192b:	53                   	push   %ebx
  80192c:	e8 9b 0a 00 00       	call   8023cc <pageref>
  801931:	89 c2                	mov    %eax,%edx
  801933:	83 c4 10             	add    $0x10,%esp
		return 0;
  801936:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  80193b:	83 fa 01             	cmp    $0x1,%edx
  80193e:	74 05                	je     801945 <devsock_close+0x24>
}
  801940:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801943:	c9                   	leave  
  801944:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801945:	83 ec 0c             	sub    $0xc,%esp
  801948:	ff 73 0c             	push   0xc(%ebx)
  80194b:	e8 b7 02 00 00       	call   801c07 <nsipc_close>
  801950:	83 c4 10             	add    $0x10,%esp
  801953:	eb eb                	jmp    801940 <devsock_close+0x1f>

00801955 <devsock_write>:
{
  801955:	55                   	push   %ebp
  801956:	89 e5                	mov    %esp,%ebp
  801958:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80195b:	6a 00                	push   $0x0
  80195d:	ff 75 10             	push   0x10(%ebp)
  801960:	ff 75 0c             	push   0xc(%ebp)
  801963:	8b 45 08             	mov    0x8(%ebp),%eax
  801966:	ff 70 0c             	push   0xc(%eax)
  801969:	e8 79 03 00 00       	call   801ce7 <nsipc_send>
}
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <devsock_read>:
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801976:	6a 00                	push   $0x0
  801978:	ff 75 10             	push   0x10(%ebp)
  80197b:	ff 75 0c             	push   0xc(%ebp)
  80197e:	8b 45 08             	mov    0x8(%ebp),%eax
  801981:	ff 70 0c             	push   0xc(%eax)
  801984:	e8 ef 02 00 00       	call   801c78 <nsipc_recv>
}
  801989:	c9                   	leave  
  80198a:	c3                   	ret    

0080198b <fd2sockid>:
{
  80198b:	55                   	push   %ebp
  80198c:	89 e5                	mov    %esp,%ebp
  80198e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  801991:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801994:	52                   	push   %edx
  801995:	50                   	push   %eax
  801996:	e8 fb f7 ff ff       	call   801196 <fd_lookup>
  80199b:	83 c4 10             	add    $0x10,%esp
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	78 10                	js     8019b2 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8019a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a5:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8019ab:	39 08                	cmp    %ecx,(%eax)
  8019ad:	75 05                	jne    8019b4 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8019af:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8019b2:	c9                   	leave  
  8019b3:	c3                   	ret    
		return -E_NOT_SUPP;
  8019b4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019b9:	eb f7                	jmp    8019b2 <fd2sockid+0x27>

008019bb <alloc_sockfd>:
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	56                   	push   %esi
  8019bf:	53                   	push   %ebx
  8019c0:	83 ec 1c             	sub    $0x1c,%esp
  8019c3:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8019c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c8:	50                   	push   %eax
  8019c9:	e8 78 f7 ff ff       	call   801146 <fd_alloc>
  8019ce:	89 c3                	mov    %eax,%ebx
  8019d0:	83 c4 10             	add    $0x10,%esp
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	78 43                	js     801a1a <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8019d7:	83 ec 04             	sub    $0x4,%esp
  8019da:	68 07 04 00 00       	push   $0x407
  8019df:	ff 75 f4             	push   -0xc(%ebp)
  8019e2:	6a 00                	push   $0x0
  8019e4:	e8 63 f2 ff ff       	call   800c4c <sys_page_alloc>
  8019e9:	89 c3                	mov    %eax,%ebx
  8019eb:	83 c4 10             	add    $0x10,%esp
  8019ee:	85 c0                	test   %eax,%eax
  8019f0:	78 28                	js     801a1a <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  8019f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8019fb:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8019fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a00:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a07:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a0a:	83 ec 0c             	sub    $0xc,%esp
  801a0d:	50                   	push   %eax
  801a0e:	e8 0c f7 ff ff       	call   80111f <fd2num>
  801a13:	89 c3                	mov    %eax,%ebx
  801a15:	83 c4 10             	add    $0x10,%esp
  801a18:	eb 0c                	jmp    801a26 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801a1a:	83 ec 0c             	sub    $0xc,%esp
  801a1d:	56                   	push   %esi
  801a1e:	e8 e4 01 00 00       	call   801c07 <nsipc_close>
		return r;
  801a23:	83 c4 10             	add    $0x10,%esp
}
  801a26:	89 d8                	mov    %ebx,%eax
  801a28:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a2b:	5b                   	pop    %ebx
  801a2c:	5e                   	pop    %esi
  801a2d:	5d                   	pop    %ebp
  801a2e:	c3                   	ret    

00801a2f <accept>:
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a35:	8b 45 08             	mov    0x8(%ebp),%eax
  801a38:	e8 4e ff ff ff       	call   80198b <fd2sockid>
  801a3d:	85 c0                	test   %eax,%eax
  801a3f:	78 1b                	js     801a5c <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801a41:	83 ec 04             	sub    $0x4,%esp
  801a44:	ff 75 10             	push   0x10(%ebp)
  801a47:	ff 75 0c             	push   0xc(%ebp)
  801a4a:	50                   	push   %eax
  801a4b:	e8 0e 01 00 00       	call   801b5e <nsipc_accept>
  801a50:	83 c4 10             	add    $0x10,%esp
  801a53:	85 c0                	test   %eax,%eax
  801a55:	78 05                	js     801a5c <accept+0x2d>
	return alloc_sockfd(r);
  801a57:	e8 5f ff ff ff       	call   8019bb <alloc_sockfd>
}
  801a5c:	c9                   	leave  
  801a5d:	c3                   	ret    

00801a5e <bind>:
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a64:	8b 45 08             	mov    0x8(%ebp),%eax
  801a67:	e8 1f ff ff ff       	call   80198b <fd2sockid>
  801a6c:	85 c0                	test   %eax,%eax
  801a6e:	78 12                	js     801a82 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801a70:	83 ec 04             	sub    $0x4,%esp
  801a73:	ff 75 10             	push   0x10(%ebp)
  801a76:	ff 75 0c             	push   0xc(%ebp)
  801a79:	50                   	push   %eax
  801a7a:	e8 31 01 00 00       	call   801bb0 <nsipc_bind>
  801a7f:	83 c4 10             	add    $0x10,%esp
}
  801a82:	c9                   	leave  
  801a83:	c3                   	ret    

00801a84 <shutdown>:
{
  801a84:	55                   	push   %ebp
  801a85:	89 e5                	mov    %esp,%ebp
  801a87:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801a8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8d:	e8 f9 fe ff ff       	call   80198b <fd2sockid>
  801a92:	85 c0                	test   %eax,%eax
  801a94:	78 0f                	js     801aa5 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  801a96:	83 ec 08             	sub    $0x8,%esp
  801a99:	ff 75 0c             	push   0xc(%ebp)
  801a9c:	50                   	push   %eax
  801a9d:	e8 43 01 00 00       	call   801be5 <nsipc_shutdown>
  801aa2:	83 c4 10             	add    $0x10,%esp
}
  801aa5:	c9                   	leave  
  801aa6:	c3                   	ret    

00801aa7 <connect>:
{
  801aa7:	55                   	push   %ebp
  801aa8:	89 e5                	mov    %esp,%ebp
  801aaa:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801aad:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab0:	e8 d6 fe ff ff       	call   80198b <fd2sockid>
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	78 12                	js     801acb <connect+0x24>
	return nsipc_connect(r, name, namelen);
  801ab9:	83 ec 04             	sub    $0x4,%esp
  801abc:	ff 75 10             	push   0x10(%ebp)
  801abf:	ff 75 0c             	push   0xc(%ebp)
  801ac2:	50                   	push   %eax
  801ac3:	e8 59 01 00 00       	call   801c21 <nsipc_connect>
  801ac8:	83 c4 10             	add    $0x10,%esp
}
  801acb:	c9                   	leave  
  801acc:	c3                   	ret    

00801acd <listen>:
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad6:	e8 b0 fe ff ff       	call   80198b <fd2sockid>
  801adb:	85 c0                	test   %eax,%eax
  801add:	78 0f                	js     801aee <listen+0x21>
	return nsipc_listen(r, backlog);
  801adf:	83 ec 08             	sub    $0x8,%esp
  801ae2:	ff 75 0c             	push   0xc(%ebp)
  801ae5:	50                   	push   %eax
  801ae6:	e8 6b 01 00 00       	call   801c56 <nsipc_listen>
  801aeb:	83 c4 10             	add    $0x10,%esp
}
  801aee:	c9                   	leave  
  801aef:	c3                   	ret    

00801af0 <socket>:

int
socket(int domain, int type, int protocol)
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801af6:	ff 75 10             	push   0x10(%ebp)
  801af9:	ff 75 0c             	push   0xc(%ebp)
  801afc:	ff 75 08             	push   0x8(%ebp)
  801aff:	e8 41 02 00 00       	call   801d45 <nsipc_socket>
  801b04:	83 c4 10             	add    $0x10,%esp
  801b07:	85 c0                	test   %eax,%eax
  801b09:	78 05                	js     801b10 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b0b:	e8 ab fe ff ff       	call   8019bb <alloc_sockfd>
}
  801b10:	c9                   	leave  
  801b11:	c3                   	ret    

00801b12 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	53                   	push   %ebx
  801b16:	83 ec 04             	sub    $0x4,%esp
  801b19:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b1b:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801b22:	74 26                	je     801b4a <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801b24:	6a 07                	push   $0x7
  801b26:	68 00 70 80 00       	push   $0x807000
  801b2b:	53                   	push   %ebx
  801b2c:	ff 35 00 80 80 00    	push   0x808000
  801b32:	e8 02 08 00 00       	call   802339 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801b37:	83 c4 0c             	add    $0xc,%esp
  801b3a:	6a 00                	push   $0x0
  801b3c:	6a 00                	push   $0x0
  801b3e:	6a 00                	push   $0x0
  801b40:	e8 84 07 00 00       	call   8022c9 <ipc_recv>
}
  801b45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b48:	c9                   	leave  
  801b49:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801b4a:	83 ec 0c             	sub    $0xc,%esp
  801b4d:	6a 02                	push   $0x2
  801b4f:	e8 39 08 00 00       	call   80238d <ipc_find_env>
  801b54:	a3 00 80 80 00       	mov    %eax,0x808000
  801b59:	83 c4 10             	add    $0x10,%esp
  801b5c:	eb c6                	jmp    801b24 <nsipc+0x12>

00801b5e <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	56                   	push   %esi
  801b62:	53                   	push   %ebx
  801b63:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801b66:	8b 45 08             	mov    0x8(%ebp),%eax
  801b69:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801b6e:	8b 06                	mov    (%esi),%eax
  801b70:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801b75:	b8 01 00 00 00       	mov    $0x1,%eax
  801b7a:	e8 93 ff ff ff       	call   801b12 <nsipc>
  801b7f:	89 c3                	mov    %eax,%ebx
  801b81:	85 c0                	test   %eax,%eax
  801b83:	79 09                	jns    801b8e <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801b85:	89 d8                	mov    %ebx,%eax
  801b87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b8a:	5b                   	pop    %ebx
  801b8b:	5e                   	pop    %esi
  801b8c:	5d                   	pop    %ebp
  801b8d:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b8e:	83 ec 04             	sub    $0x4,%esp
  801b91:	ff 35 10 70 80 00    	push   0x807010
  801b97:	68 00 70 80 00       	push   $0x807000
  801b9c:	ff 75 0c             	push   0xc(%ebp)
  801b9f:	e8 42 ee ff ff       	call   8009e6 <memmove>
		*addrlen = ret->ret_addrlen;
  801ba4:	a1 10 70 80 00       	mov    0x807010,%eax
  801ba9:	89 06                	mov    %eax,(%esi)
  801bab:	83 c4 10             	add    $0x10,%esp
	return r;
  801bae:	eb d5                	jmp    801b85 <nsipc_accept+0x27>

00801bb0 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	53                   	push   %ebx
  801bb4:	83 ec 08             	sub    $0x8,%esp
  801bb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801bba:	8b 45 08             	mov    0x8(%ebp),%eax
  801bbd:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801bc2:	53                   	push   %ebx
  801bc3:	ff 75 0c             	push   0xc(%ebp)
  801bc6:	68 04 70 80 00       	push   $0x807004
  801bcb:	e8 16 ee ff ff       	call   8009e6 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801bd0:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801bd6:	b8 02 00 00 00       	mov    $0x2,%eax
  801bdb:	e8 32 ff ff ff       	call   801b12 <nsipc>
}
  801be0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be3:	c9                   	leave  
  801be4:	c3                   	ret    

00801be5 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801beb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bee:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801bf3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bf6:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801bfb:	b8 03 00 00 00       	mov    $0x3,%eax
  801c00:	e8 0d ff ff ff       	call   801b12 <nsipc>
}
  801c05:	c9                   	leave  
  801c06:	c3                   	ret    

00801c07 <nsipc_close>:

int
nsipc_close(int s)
{
  801c07:	55                   	push   %ebp
  801c08:	89 e5                	mov    %esp,%ebp
  801c0a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c0d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c10:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801c15:	b8 04 00 00 00       	mov    $0x4,%eax
  801c1a:	e8 f3 fe ff ff       	call   801b12 <nsipc>
}
  801c1f:	c9                   	leave  
  801c20:	c3                   	ret    

00801c21 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c21:	55                   	push   %ebp
  801c22:	89 e5                	mov    %esp,%ebp
  801c24:	53                   	push   %ebx
  801c25:	83 ec 08             	sub    $0x8,%esp
  801c28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801c2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c2e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801c33:	53                   	push   %ebx
  801c34:	ff 75 0c             	push   0xc(%ebp)
  801c37:	68 04 70 80 00       	push   $0x807004
  801c3c:	e8 a5 ed ff ff       	call   8009e6 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801c41:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801c47:	b8 05 00 00 00       	mov    $0x5,%eax
  801c4c:	e8 c1 fe ff ff       	call   801b12 <nsipc>
}
  801c51:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c54:	c9                   	leave  
  801c55:	c3                   	ret    

00801c56 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801c64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c67:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801c6c:	b8 06 00 00 00       	mov    $0x6,%eax
  801c71:	e8 9c fe ff ff       	call   801b12 <nsipc>
}
  801c76:	c9                   	leave  
  801c77:	c3                   	ret    

00801c78 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801c78:	55                   	push   %ebp
  801c79:	89 e5                	mov    %esp,%ebp
  801c7b:	56                   	push   %esi
  801c7c:	53                   	push   %ebx
  801c7d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c80:	8b 45 08             	mov    0x8(%ebp),%eax
  801c83:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801c88:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801c8e:	8b 45 14             	mov    0x14(%ebp),%eax
  801c91:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c96:	b8 07 00 00 00       	mov    $0x7,%eax
  801c9b:	e8 72 fe ff ff       	call   801b12 <nsipc>
  801ca0:	89 c3                	mov    %eax,%ebx
  801ca2:	85 c0                	test   %eax,%eax
  801ca4:	78 22                	js     801cc8 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801ca6:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801cab:	39 c6                	cmp    %eax,%esi
  801cad:	0f 4e c6             	cmovle %esi,%eax
  801cb0:	39 c3                	cmp    %eax,%ebx
  801cb2:	7f 1d                	jg     801cd1 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801cb4:	83 ec 04             	sub    $0x4,%esp
  801cb7:	53                   	push   %ebx
  801cb8:	68 00 70 80 00       	push   $0x807000
  801cbd:	ff 75 0c             	push   0xc(%ebp)
  801cc0:	e8 21 ed ff ff       	call   8009e6 <memmove>
  801cc5:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801cc8:	89 d8                	mov    %ebx,%eax
  801cca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ccd:	5b                   	pop    %ebx
  801cce:	5e                   	pop    %esi
  801ccf:	5d                   	pop    %ebp
  801cd0:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801cd1:	68 67 2c 80 00       	push   $0x802c67
  801cd6:	68 2f 2c 80 00       	push   $0x802c2f
  801cdb:	6a 62                	push   $0x62
  801cdd:	68 7c 2c 80 00       	push   $0x802c7c
  801ce2:	e8 b4 e4 ff ff       	call   80019b <_panic>

00801ce7 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	53                   	push   %ebx
  801ceb:	83 ec 04             	sub    $0x4,%esp
  801cee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801cf1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf4:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801cf9:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801cff:	7f 2e                	jg     801d2f <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d01:	83 ec 04             	sub    $0x4,%esp
  801d04:	53                   	push   %ebx
  801d05:	ff 75 0c             	push   0xc(%ebp)
  801d08:	68 0c 70 80 00       	push   $0x80700c
  801d0d:	e8 d4 ec ff ff       	call   8009e6 <memmove>
	nsipcbuf.send.req_size = size;
  801d12:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801d18:	8b 45 14             	mov    0x14(%ebp),%eax
  801d1b:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801d20:	b8 08 00 00 00       	mov    $0x8,%eax
  801d25:	e8 e8 fd ff ff       	call   801b12 <nsipc>
}
  801d2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d2d:	c9                   	leave  
  801d2e:	c3                   	ret    
	assert(size < 1600);
  801d2f:	68 88 2c 80 00       	push   $0x802c88
  801d34:	68 2f 2c 80 00       	push   $0x802c2f
  801d39:	6a 6d                	push   $0x6d
  801d3b:	68 7c 2c 80 00       	push   $0x802c7c
  801d40:	e8 56 e4 ff ff       	call   80019b <_panic>

00801d45 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801d45:	55                   	push   %ebp
  801d46:	89 e5                	mov    %esp,%ebp
  801d48:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801d53:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d56:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801d5b:	8b 45 10             	mov    0x10(%ebp),%eax
  801d5e:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801d63:	b8 09 00 00 00       	mov    $0x9,%eax
  801d68:	e8 a5 fd ff ff       	call   801b12 <nsipc>
}
  801d6d:	c9                   	leave  
  801d6e:	c3                   	ret    

00801d6f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801d6f:	55                   	push   %ebp
  801d70:	89 e5                	mov    %esp,%ebp
  801d72:	56                   	push   %esi
  801d73:	53                   	push   %ebx
  801d74:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801d77:	83 ec 0c             	sub    $0xc,%esp
  801d7a:	ff 75 08             	push   0x8(%ebp)
  801d7d:	e8 ad f3 ff ff       	call   80112f <fd2data>
  801d82:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d84:	83 c4 08             	add    $0x8,%esp
  801d87:	68 94 2c 80 00       	push   $0x802c94
  801d8c:	53                   	push   %ebx
  801d8d:	e8 be ea ff ff       	call   800850 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d92:	8b 46 04             	mov    0x4(%esi),%eax
  801d95:	2b 06                	sub    (%esi),%eax
  801d97:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d9d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801da4:	00 00 00 
	stat->st_dev = &devpipe;
  801da7:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801dae:	30 80 00 
	return 0;
}
  801db1:	b8 00 00 00 00       	mov    $0x0,%eax
  801db6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db9:	5b                   	pop    %ebx
  801dba:	5e                   	pop    %esi
  801dbb:	5d                   	pop    %ebp
  801dbc:	c3                   	ret    

00801dbd <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801dbd:	55                   	push   %ebp
  801dbe:	89 e5                	mov    %esp,%ebp
  801dc0:	53                   	push   %ebx
  801dc1:	83 ec 0c             	sub    $0xc,%esp
  801dc4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801dc7:	53                   	push   %ebx
  801dc8:	6a 00                	push   $0x0
  801dca:	e8 02 ef ff ff       	call   800cd1 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801dcf:	89 1c 24             	mov    %ebx,(%esp)
  801dd2:	e8 58 f3 ff ff       	call   80112f <fd2data>
  801dd7:	83 c4 08             	add    $0x8,%esp
  801dda:	50                   	push   %eax
  801ddb:	6a 00                	push   $0x0
  801ddd:	e8 ef ee ff ff       	call   800cd1 <sys_page_unmap>
}
  801de2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801de5:	c9                   	leave  
  801de6:	c3                   	ret    

00801de7 <_pipeisclosed>:
{
  801de7:	55                   	push   %ebp
  801de8:	89 e5                	mov    %esp,%ebp
  801dea:	57                   	push   %edi
  801deb:	56                   	push   %esi
  801dec:	53                   	push   %ebx
  801ded:	83 ec 1c             	sub    $0x1c,%esp
  801df0:	89 c7                	mov    %eax,%edi
  801df2:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801df4:	a1 00 40 80 00       	mov    0x804000,%eax
  801df9:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801dfc:	83 ec 0c             	sub    $0xc,%esp
  801dff:	57                   	push   %edi
  801e00:	e8 c7 05 00 00       	call   8023cc <pageref>
  801e05:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801e08:	89 34 24             	mov    %esi,(%esp)
  801e0b:	e8 bc 05 00 00       	call   8023cc <pageref>
		nn = thisenv->env_runs;
  801e10:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801e16:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801e19:	83 c4 10             	add    $0x10,%esp
  801e1c:	39 cb                	cmp    %ecx,%ebx
  801e1e:	74 1b                	je     801e3b <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801e20:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e23:	75 cf                	jne    801df4 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801e25:	8b 42 68             	mov    0x68(%edx),%eax
  801e28:	6a 01                	push   $0x1
  801e2a:	50                   	push   %eax
  801e2b:	53                   	push   %ebx
  801e2c:	68 9b 2c 80 00       	push   $0x802c9b
  801e31:	e8 40 e4 ff ff       	call   800276 <cprintf>
  801e36:	83 c4 10             	add    $0x10,%esp
  801e39:	eb b9                	jmp    801df4 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801e3b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801e3e:	0f 94 c0             	sete   %al
  801e41:	0f b6 c0             	movzbl %al,%eax
}
  801e44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e47:	5b                   	pop    %ebx
  801e48:	5e                   	pop    %esi
  801e49:	5f                   	pop    %edi
  801e4a:	5d                   	pop    %ebp
  801e4b:	c3                   	ret    

00801e4c <devpipe_write>:
{
  801e4c:	55                   	push   %ebp
  801e4d:	89 e5                	mov    %esp,%ebp
  801e4f:	57                   	push   %edi
  801e50:	56                   	push   %esi
  801e51:	53                   	push   %ebx
  801e52:	83 ec 28             	sub    $0x28,%esp
  801e55:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801e58:	56                   	push   %esi
  801e59:	e8 d1 f2 ff ff       	call   80112f <fd2data>
  801e5e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e60:	83 c4 10             	add    $0x10,%esp
  801e63:	bf 00 00 00 00       	mov    $0x0,%edi
  801e68:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e6b:	75 09                	jne    801e76 <devpipe_write+0x2a>
	return i;
  801e6d:	89 f8                	mov    %edi,%eax
  801e6f:	eb 23                	jmp    801e94 <devpipe_write+0x48>
			sys_yield();
  801e71:	e8 b7 ed ff ff       	call   800c2d <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e76:	8b 43 04             	mov    0x4(%ebx),%eax
  801e79:	8b 0b                	mov    (%ebx),%ecx
  801e7b:	8d 51 20             	lea    0x20(%ecx),%edx
  801e7e:	39 d0                	cmp    %edx,%eax
  801e80:	72 1a                	jb     801e9c <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801e82:	89 da                	mov    %ebx,%edx
  801e84:	89 f0                	mov    %esi,%eax
  801e86:	e8 5c ff ff ff       	call   801de7 <_pipeisclosed>
  801e8b:	85 c0                	test   %eax,%eax
  801e8d:	74 e2                	je     801e71 <devpipe_write+0x25>
				return 0;
  801e8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e94:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e97:	5b                   	pop    %ebx
  801e98:	5e                   	pop    %esi
  801e99:	5f                   	pop    %edi
  801e9a:	5d                   	pop    %ebp
  801e9b:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e9c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e9f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801ea3:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801ea6:	89 c2                	mov    %eax,%edx
  801ea8:	c1 fa 1f             	sar    $0x1f,%edx
  801eab:	89 d1                	mov    %edx,%ecx
  801ead:	c1 e9 1b             	shr    $0x1b,%ecx
  801eb0:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801eb3:	83 e2 1f             	and    $0x1f,%edx
  801eb6:	29 ca                	sub    %ecx,%edx
  801eb8:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ebc:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ec0:	83 c0 01             	add    $0x1,%eax
  801ec3:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801ec6:	83 c7 01             	add    $0x1,%edi
  801ec9:	eb 9d                	jmp    801e68 <devpipe_write+0x1c>

00801ecb <devpipe_read>:
{
  801ecb:	55                   	push   %ebp
  801ecc:	89 e5                	mov    %esp,%ebp
  801ece:	57                   	push   %edi
  801ecf:	56                   	push   %esi
  801ed0:	53                   	push   %ebx
  801ed1:	83 ec 18             	sub    $0x18,%esp
  801ed4:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801ed7:	57                   	push   %edi
  801ed8:	e8 52 f2 ff ff       	call   80112f <fd2data>
  801edd:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801edf:	83 c4 10             	add    $0x10,%esp
  801ee2:	be 00 00 00 00       	mov    $0x0,%esi
  801ee7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801eea:	75 13                	jne    801eff <devpipe_read+0x34>
	return i;
  801eec:	89 f0                	mov    %esi,%eax
  801eee:	eb 02                	jmp    801ef2 <devpipe_read+0x27>
				return i;
  801ef0:	89 f0                	mov    %esi,%eax
}
  801ef2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ef5:	5b                   	pop    %ebx
  801ef6:	5e                   	pop    %esi
  801ef7:	5f                   	pop    %edi
  801ef8:	5d                   	pop    %ebp
  801ef9:	c3                   	ret    
			sys_yield();
  801efa:	e8 2e ed ff ff       	call   800c2d <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801eff:	8b 03                	mov    (%ebx),%eax
  801f01:	3b 43 04             	cmp    0x4(%ebx),%eax
  801f04:	75 18                	jne    801f1e <devpipe_read+0x53>
			if (i > 0)
  801f06:	85 f6                	test   %esi,%esi
  801f08:	75 e6                	jne    801ef0 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801f0a:	89 da                	mov    %ebx,%edx
  801f0c:	89 f8                	mov    %edi,%eax
  801f0e:	e8 d4 fe ff ff       	call   801de7 <_pipeisclosed>
  801f13:	85 c0                	test   %eax,%eax
  801f15:	74 e3                	je     801efa <devpipe_read+0x2f>
				return 0;
  801f17:	b8 00 00 00 00       	mov    $0x0,%eax
  801f1c:	eb d4                	jmp    801ef2 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f1e:	99                   	cltd   
  801f1f:	c1 ea 1b             	shr    $0x1b,%edx
  801f22:	01 d0                	add    %edx,%eax
  801f24:	83 e0 1f             	and    $0x1f,%eax
  801f27:	29 d0                	sub    %edx,%eax
  801f29:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801f2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f31:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801f34:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801f37:	83 c6 01             	add    $0x1,%esi
  801f3a:	eb ab                	jmp    801ee7 <devpipe_read+0x1c>

00801f3c <pipe>:
{
  801f3c:	55                   	push   %ebp
  801f3d:	89 e5                	mov    %esp,%ebp
  801f3f:	56                   	push   %esi
  801f40:	53                   	push   %ebx
  801f41:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801f44:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f47:	50                   	push   %eax
  801f48:	e8 f9 f1 ff ff       	call   801146 <fd_alloc>
  801f4d:	89 c3                	mov    %eax,%ebx
  801f4f:	83 c4 10             	add    $0x10,%esp
  801f52:	85 c0                	test   %eax,%eax
  801f54:	0f 88 23 01 00 00    	js     80207d <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f5a:	83 ec 04             	sub    $0x4,%esp
  801f5d:	68 07 04 00 00       	push   $0x407
  801f62:	ff 75 f4             	push   -0xc(%ebp)
  801f65:	6a 00                	push   $0x0
  801f67:	e8 e0 ec ff ff       	call   800c4c <sys_page_alloc>
  801f6c:	89 c3                	mov    %eax,%ebx
  801f6e:	83 c4 10             	add    $0x10,%esp
  801f71:	85 c0                	test   %eax,%eax
  801f73:	0f 88 04 01 00 00    	js     80207d <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801f79:	83 ec 0c             	sub    $0xc,%esp
  801f7c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f7f:	50                   	push   %eax
  801f80:	e8 c1 f1 ff ff       	call   801146 <fd_alloc>
  801f85:	89 c3                	mov    %eax,%ebx
  801f87:	83 c4 10             	add    $0x10,%esp
  801f8a:	85 c0                	test   %eax,%eax
  801f8c:	0f 88 db 00 00 00    	js     80206d <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f92:	83 ec 04             	sub    $0x4,%esp
  801f95:	68 07 04 00 00       	push   $0x407
  801f9a:	ff 75 f0             	push   -0x10(%ebp)
  801f9d:	6a 00                	push   $0x0
  801f9f:	e8 a8 ec ff ff       	call   800c4c <sys_page_alloc>
  801fa4:	89 c3                	mov    %eax,%ebx
  801fa6:	83 c4 10             	add    $0x10,%esp
  801fa9:	85 c0                	test   %eax,%eax
  801fab:	0f 88 bc 00 00 00    	js     80206d <pipe+0x131>
	va = fd2data(fd0);
  801fb1:	83 ec 0c             	sub    $0xc,%esp
  801fb4:	ff 75 f4             	push   -0xc(%ebp)
  801fb7:	e8 73 f1 ff ff       	call   80112f <fd2data>
  801fbc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fbe:	83 c4 0c             	add    $0xc,%esp
  801fc1:	68 07 04 00 00       	push   $0x407
  801fc6:	50                   	push   %eax
  801fc7:	6a 00                	push   $0x0
  801fc9:	e8 7e ec ff ff       	call   800c4c <sys_page_alloc>
  801fce:	89 c3                	mov    %eax,%ebx
  801fd0:	83 c4 10             	add    $0x10,%esp
  801fd3:	85 c0                	test   %eax,%eax
  801fd5:	0f 88 82 00 00 00    	js     80205d <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fdb:	83 ec 0c             	sub    $0xc,%esp
  801fde:	ff 75 f0             	push   -0x10(%ebp)
  801fe1:	e8 49 f1 ff ff       	call   80112f <fd2data>
  801fe6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801fed:	50                   	push   %eax
  801fee:	6a 00                	push   $0x0
  801ff0:	56                   	push   %esi
  801ff1:	6a 00                	push   $0x0
  801ff3:	e8 97 ec ff ff       	call   800c8f <sys_page_map>
  801ff8:	89 c3                	mov    %eax,%ebx
  801ffa:	83 c4 20             	add    $0x20,%esp
  801ffd:	85 c0                	test   %eax,%eax
  801fff:	78 4e                	js     80204f <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  802001:	a1 3c 30 80 00       	mov    0x80303c,%eax
  802006:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802009:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80200b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80200e:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802015:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802018:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80201a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80201d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802024:	83 ec 0c             	sub    $0xc,%esp
  802027:	ff 75 f4             	push   -0xc(%ebp)
  80202a:	e8 f0 f0 ff ff       	call   80111f <fd2num>
  80202f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802032:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802034:	83 c4 04             	add    $0x4,%esp
  802037:	ff 75 f0             	push   -0x10(%ebp)
  80203a:	e8 e0 f0 ff ff       	call   80111f <fd2num>
  80203f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802042:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802045:	83 c4 10             	add    $0x10,%esp
  802048:	bb 00 00 00 00       	mov    $0x0,%ebx
  80204d:	eb 2e                	jmp    80207d <pipe+0x141>
	sys_page_unmap(0, va);
  80204f:	83 ec 08             	sub    $0x8,%esp
  802052:	56                   	push   %esi
  802053:	6a 00                	push   $0x0
  802055:	e8 77 ec ff ff       	call   800cd1 <sys_page_unmap>
  80205a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80205d:	83 ec 08             	sub    $0x8,%esp
  802060:	ff 75 f0             	push   -0x10(%ebp)
  802063:	6a 00                	push   $0x0
  802065:	e8 67 ec ff ff       	call   800cd1 <sys_page_unmap>
  80206a:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80206d:	83 ec 08             	sub    $0x8,%esp
  802070:	ff 75 f4             	push   -0xc(%ebp)
  802073:	6a 00                	push   $0x0
  802075:	e8 57 ec ff ff       	call   800cd1 <sys_page_unmap>
  80207a:	83 c4 10             	add    $0x10,%esp
}
  80207d:	89 d8                	mov    %ebx,%eax
  80207f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802082:	5b                   	pop    %ebx
  802083:	5e                   	pop    %esi
  802084:	5d                   	pop    %ebp
  802085:	c3                   	ret    

00802086 <pipeisclosed>:
{
  802086:	55                   	push   %ebp
  802087:	89 e5                	mov    %esp,%ebp
  802089:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80208c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80208f:	50                   	push   %eax
  802090:	ff 75 08             	push   0x8(%ebp)
  802093:	e8 fe f0 ff ff       	call   801196 <fd_lookup>
  802098:	83 c4 10             	add    $0x10,%esp
  80209b:	85 c0                	test   %eax,%eax
  80209d:	78 18                	js     8020b7 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80209f:	83 ec 0c             	sub    $0xc,%esp
  8020a2:	ff 75 f4             	push   -0xc(%ebp)
  8020a5:	e8 85 f0 ff ff       	call   80112f <fd2data>
  8020aa:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8020ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020af:	e8 33 fd ff ff       	call   801de7 <_pipeisclosed>
  8020b4:	83 c4 10             	add    $0x10,%esp
}
  8020b7:	c9                   	leave  
  8020b8:	c3                   	ret    

008020b9 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  8020b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8020be:	c3                   	ret    

008020bf <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020bf:	55                   	push   %ebp
  8020c0:	89 e5                	mov    %esp,%ebp
  8020c2:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8020c5:	68 b3 2c 80 00       	push   $0x802cb3
  8020ca:	ff 75 0c             	push   0xc(%ebp)
  8020cd:	e8 7e e7 ff ff       	call   800850 <strcpy>
	return 0;
}
  8020d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8020d7:	c9                   	leave  
  8020d8:	c3                   	ret    

008020d9 <devcons_write>:
{
  8020d9:	55                   	push   %ebp
  8020da:	89 e5                	mov    %esp,%ebp
  8020dc:	57                   	push   %edi
  8020dd:	56                   	push   %esi
  8020de:	53                   	push   %ebx
  8020df:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8020e5:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8020ea:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8020f0:	eb 2e                	jmp    802120 <devcons_write+0x47>
		m = n - tot;
  8020f2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020f5:	29 f3                	sub    %esi,%ebx
  8020f7:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8020fc:	39 c3                	cmp    %eax,%ebx
  8020fe:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802101:	83 ec 04             	sub    $0x4,%esp
  802104:	53                   	push   %ebx
  802105:	89 f0                	mov    %esi,%eax
  802107:	03 45 0c             	add    0xc(%ebp),%eax
  80210a:	50                   	push   %eax
  80210b:	57                   	push   %edi
  80210c:	e8 d5 e8 ff ff       	call   8009e6 <memmove>
		sys_cputs(buf, m);
  802111:	83 c4 08             	add    $0x8,%esp
  802114:	53                   	push   %ebx
  802115:	57                   	push   %edi
  802116:	e8 75 ea ff ff       	call   800b90 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80211b:	01 de                	add    %ebx,%esi
  80211d:	83 c4 10             	add    $0x10,%esp
  802120:	3b 75 10             	cmp    0x10(%ebp),%esi
  802123:	72 cd                	jb     8020f2 <devcons_write+0x19>
}
  802125:	89 f0                	mov    %esi,%eax
  802127:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80212a:	5b                   	pop    %ebx
  80212b:	5e                   	pop    %esi
  80212c:	5f                   	pop    %edi
  80212d:	5d                   	pop    %ebp
  80212e:	c3                   	ret    

0080212f <devcons_read>:
{
  80212f:	55                   	push   %ebp
  802130:	89 e5                	mov    %esp,%ebp
  802132:	83 ec 08             	sub    $0x8,%esp
  802135:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80213a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80213e:	75 07                	jne    802147 <devcons_read+0x18>
  802140:	eb 1f                	jmp    802161 <devcons_read+0x32>
		sys_yield();
  802142:	e8 e6 ea ff ff       	call   800c2d <sys_yield>
	while ((c = sys_cgetc()) == 0)
  802147:	e8 62 ea ff ff       	call   800bae <sys_cgetc>
  80214c:	85 c0                	test   %eax,%eax
  80214e:	74 f2                	je     802142 <devcons_read+0x13>
	if (c < 0)
  802150:	78 0f                	js     802161 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  802152:	83 f8 04             	cmp    $0x4,%eax
  802155:	74 0c                	je     802163 <devcons_read+0x34>
	*(char*)vbuf = c;
  802157:	8b 55 0c             	mov    0xc(%ebp),%edx
  80215a:	88 02                	mov    %al,(%edx)
	return 1;
  80215c:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802161:	c9                   	leave  
  802162:	c3                   	ret    
		return 0;
  802163:	b8 00 00 00 00       	mov    $0x0,%eax
  802168:	eb f7                	jmp    802161 <devcons_read+0x32>

0080216a <cputchar>:
{
  80216a:	55                   	push   %ebp
  80216b:	89 e5                	mov    %esp,%ebp
  80216d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802170:	8b 45 08             	mov    0x8(%ebp),%eax
  802173:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802176:	6a 01                	push   $0x1
  802178:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80217b:	50                   	push   %eax
  80217c:	e8 0f ea ff ff       	call   800b90 <sys_cputs>
}
  802181:	83 c4 10             	add    $0x10,%esp
  802184:	c9                   	leave  
  802185:	c3                   	ret    

00802186 <getchar>:
{
  802186:	55                   	push   %ebp
  802187:	89 e5                	mov    %esp,%ebp
  802189:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80218c:	6a 01                	push   $0x1
  80218e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802191:	50                   	push   %eax
  802192:	6a 00                	push   $0x0
  802194:	e8 66 f2 ff ff       	call   8013ff <read>
	if (r < 0)
  802199:	83 c4 10             	add    $0x10,%esp
  80219c:	85 c0                	test   %eax,%eax
  80219e:	78 06                	js     8021a6 <getchar+0x20>
	if (r < 1)
  8021a0:	74 06                	je     8021a8 <getchar+0x22>
	return c;
  8021a2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8021a6:	c9                   	leave  
  8021a7:	c3                   	ret    
		return -E_EOF;
  8021a8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8021ad:	eb f7                	jmp    8021a6 <getchar+0x20>

008021af <iscons>:
{
  8021af:	55                   	push   %ebp
  8021b0:	89 e5                	mov    %esp,%ebp
  8021b2:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021b8:	50                   	push   %eax
  8021b9:	ff 75 08             	push   0x8(%ebp)
  8021bc:	e8 d5 ef ff ff       	call   801196 <fd_lookup>
  8021c1:	83 c4 10             	add    $0x10,%esp
  8021c4:	85 c0                	test   %eax,%eax
  8021c6:	78 11                	js     8021d9 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  8021c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021cb:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021d1:	39 10                	cmp    %edx,(%eax)
  8021d3:	0f 94 c0             	sete   %al
  8021d6:	0f b6 c0             	movzbl %al,%eax
}
  8021d9:	c9                   	leave  
  8021da:	c3                   	ret    

008021db <opencons>:
{
  8021db:	55                   	push   %ebp
  8021dc:	89 e5                	mov    %esp,%ebp
  8021de:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8021e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021e4:	50                   	push   %eax
  8021e5:	e8 5c ef ff ff       	call   801146 <fd_alloc>
  8021ea:	83 c4 10             	add    $0x10,%esp
  8021ed:	85 c0                	test   %eax,%eax
  8021ef:	78 3a                	js     80222b <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021f1:	83 ec 04             	sub    $0x4,%esp
  8021f4:	68 07 04 00 00       	push   $0x407
  8021f9:	ff 75 f4             	push   -0xc(%ebp)
  8021fc:	6a 00                	push   $0x0
  8021fe:	e8 49 ea ff ff       	call   800c4c <sys_page_alloc>
  802203:	83 c4 10             	add    $0x10,%esp
  802206:	85 c0                	test   %eax,%eax
  802208:	78 21                	js     80222b <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80220a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80220d:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802213:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802215:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802218:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80221f:	83 ec 0c             	sub    $0xc,%esp
  802222:	50                   	push   %eax
  802223:	e8 f7 ee ff ff       	call   80111f <fd2num>
  802228:	83 c4 10             	add    $0x10,%esp
}
  80222b:	c9                   	leave  
  80222c:	c3                   	ret    

0080222d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80222d:	55                   	push   %ebp
  80222e:	89 e5                	mov    %esp,%ebp
  802230:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  802233:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  80223a:	74 0a                	je     802246 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80223c:	8b 45 08             	mov    0x8(%ebp),%eax
  80223f:	a3 04 80 80 00       	mov    %eax,0x808004
}
  802244:	c9                   	leave  
  802245:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  802246:	e8 c3 e9 ff ff       	call   800c0e <sys_getenvid>
  80224b:	83 ec 04             	sub    $0x4,%esp
  80224e:	68 07 0e 00 00       	push   $0xe07
  802253:	68 00 f0 bf ee       	push   $0xeebff000
  802258:	50                   	push   %eax
  802259:	e8 ee e9 ff ff       	call   800c4c <sys_page_alloc>
		if (r < 0) {
  80225e:	83 c4 10             	add    $0x10,%esp
  802261:	85 c0                	test   %eax,%eax
  802263:	78 2c                	js     802291 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  802265:	e8 a4 e9 ff ff       	call   800c0e <sys_getenvid>
  80226a:	83 ec 08             	sub    $0x8,%esp
  80226d:	68 a3 22 80 00       	push   $0x8022a3
  802272:	50                   	push   %eax
  802273:	e8 1f eb ff ff       	call   800d97 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  802278:	83 c4 10             	add    $0x10,%esp
  80227b:	85 c0                	test   %eax,%eax
  80227d:	79 bd                	jns    80223c <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  80227f:	50                   	push   %eax
  802280:	68 00 2d 80 00       	push   $0x802d00
  802285:	6a 28                	push   $0x28
  802287:	68 36 2d 80 00       	push   $0x802d36
  80228c:	e8 0a df ff ff       	call   80019b <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  802291:	50                   	push   %eax
  802292:	68 c0 2c 80 00       	push   $0x802cc0
  802297:	6a 23                	push   $0x23
  802299:	68 36 2d 80 00       	push   $0x802d36
  80229e:	e8 f8 de ff ff       	call   80019b <_panic>

008022a3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8022a3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8022a4:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  8022a9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8022ab:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  8022ae:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  8022b2:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  8022b5:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  8022b9:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  8022bd:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  8022bf:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  8022c2:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  8022c3:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  8022c6:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  8022c7:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  8022c8:	c3                   	ret    

008022c9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022c9:	55                   	push   %ebp
  8022ca:	89 e5                	mov    %esp,%ebp
  8022cc:	56                   	push   %esi
  8022cd:	53                   	push   %ebx
  8022ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8022d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022d4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8022d7:	85 c0                	test   %eax,%eax
  8022d9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8022de:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8022e1:	83 ec 0c             	sub    $0xc,%esp
  8022e4:	50                   	push   %eax
  8022e5:	e8 12 eb ff ff       	call   800dfc <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8022ea:	83 c4 10             	add    $0x10,%esp
  8022ed:	85 f6                	test   %esi,%esi
  8022ef:	74 17                	je     802308 <ipc_recv+0x3f>
  8022f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8022f6:	85 c0                	test   %eax,%eax
  8022f8:	78 0c                	js     802306 <ipc_recv+0x3d>
  8022fa:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802300:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  802306:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802308:	85 db                	test   %ebx,%ebx
  80230a:	74 17                	je     802323 <ipc_recv+0x5a>
  80230c:	ba 00 00 00 00       	mov    $0x0,%edx
  802311:	85 c0                	test   %eax,%eax
  802313:	78 0c                	js     802321 <ipc_recv+0x58>
  802315:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80231b:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  802321:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802323:	85 c0                	test   %eax,%eax
  802325:	78 0b                	js     802332 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  802327:	a1 00 40 80 00       	mov    0x804000,%eax
  80232c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  802332:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802335:	5b                   	pop    %ebx
  802336:	5e                   	pop    %esi
  802337:	5d                   	pop    %ebp
  802338:	c3                   	ret    

00802339 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802339:	55                   	push   %ebp
  80233a:	89 e5                	mov    %esp,%ebp
  80233c:	57                   	push   %edi
  80233d:	56                   	push   %esi
  80233e:	53                   	push   %ebx
  80233f:	83 ec 0c             	sub    $0xc,%esp
  802342:	8b 7d 08             	mov    0x8(%ebp),%edi
  802345:	8b 75 0c             	mov    0xc(%ebp),%esi
  802348:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  80234b:	85 db                	test   %ebx,%ebx
  80234d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802352:	0f 44 d8             	cmove  %eax,%ebx
  802355:	eb 05                	jmp    80235c <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802357:	e8 d1 e8 ff ff       	call   800c2d <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  80235c:	ff 75 14             	push   0x14(%ebp)
  80235f:	53                   	push   %ebx
  802360:	56                   	push   %esi
  802361:	57                   	push   %edi
  802362:	e8 72 ea ff ff       	call   800dd9 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802367:	83 c4 10             	add    $0x10,%esp
  80236a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80236d:	74 e8                	je     802357 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80236f:	85 c0                	test   %eax,%eax
  802371:	78 08                	js     80237b <ipc_send+0x42>
	}while (r<0);

}
  802373:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802376:	5b                   	pop    %ebx
  802377:	5e                   	pop    %esi
  802378:	5f                   	pop    %edi
  802379:	5d                   	pop    %ebp
  80237a:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80237b:	50                   	push   %eax
  80237c:	68 44 2d 80 00       	push   $0x802d44
  802381:	6a 3d                	push   $0x3d
  802383:	68 58 2d 80 00       	push   $0x802d58
  802388:	e8 0e de ff ff       	call   80019b <_panic>

0080238d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80238d:	55                   	push   %ebp
  80238e:	89 e5                	mov    %esp,%ebp
  802390:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802393:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802398:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  80239e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023a4:	8b 52 60             	mov    0x60(%edx),%edx
  8023a7:	39 ca                	cmp    %ecx,%edx
  8023a9:	74 11                	je     8023bc <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  8023ab:	83 c0 01             	add    $0x1,%eax
  8023ae:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023b3:	75 e3                	jne    802398 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  8023b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8023ba:	eb 0e                	jmp    8023ca <ipc_find_env+0x3d>
			return envs[i].env_id;
  8023bc:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8023c2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023c7:	8b 40 58             	mov    0x58(%eax),%eax
}
  8023ca:	5d                   	pop    %ebp
  8023cb:	c3                   	ret    

008023cc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023cc:	55                   	push   %ebp
  8023cd:	89 e5                	mov    %esp,%ebp
  8023cf:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023d2:	89 c2                	mov    %eax,%edx
  8023d4:	c1 ea 16             	shr    $0x16,%edx
  8023d7:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8023de:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8023e3:	f6 c1 01             	test   $0x1,%cl
  8023e6:	74 1c                	je     802404 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  8023e8:	c1 e8 0c             	shr    $0xc,%eax
  8023eb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8023f2:	a8 01                	test   $0x1,%al
  8023f4:	74 0e                	je     802404 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023f6:	c1 e8 0c             	shr    $0xc,%eax
  8023f9:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802400:	ef 
  802401:	0f b7 d2             	movzwl %dx,%edx
}
  802404:	89 d0                	mov    %edx,%eax
  802406:	5d                   	pop    %ebp
  802407:	c3                   	ret    
  802408:	66 90                	xchg   %ax,%ax
  80240a:	66 90                	xchg   %ax,%ax
  80240c:	66 90                	xchg   %ax,%ax
  80240e:	66 90                	xchg   %ax,%ax

00802410 <__udivdi3>:
  802410:	f3 0f 1e fb          	endbr32 
  802414:	55                   	push   %ebp
  802415:	57                   	push   %edi
  802416:	56                   	push   %esi
  802417:	53                   	push   %ebx
  802418:	83 ec 1c             	sub    $0x1c,%esp
  80241b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80241f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802423:	8b 74 24 34          	mov    0x34(%esp),%esi
  802427:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80242b:	85 c0                	test   %eax,%eax
  80242d:	75 19                	jne    802448 <__udivdi3+0x38>
  80242f:	39 f3                	cmp    %esi,%ebx
  802431:	76 4d                	jbe    802480 <__udivdi3+0x70>
  802433:	31 ff                	xor    %edi,%edi
  802435:	89 e8                	mov    %ebp,%eax
  802437:	89 f2                	mov    %esi,%edx
  802439:	f7 f3                	div    %ebx
  80243b:	89 fa                	mov    %edi,%edx
  80243d:	83 c4 1c             	add    $0x1c,%esp
  802440:	5b                   	pop    %ebx
  802441:	5e                   	pop    %esi
  802442:	5f                   	pop    %edi
  802443:	5d                   	pop    %ebp
  802444:	c3                   	ret    
  802445:	8d 76 00             	lea    0x0(%esi),%esi
  802448:	39 f0                	cmp    %esi,%eax
  80244a:	76 14                	jbe    802460 <__udivdi3+0x50>
  80244c:	31 ff                	xor    %edi,%edi
  80244e:	31 c0                	xor    %eax,%eax
  802450:	89 fa                	mov    %edi,%edx
  802452:	83 c4 1c             	add    $0x1c,%esp
  802455:	5b                   	pop    %ebx
  802456:	5e                   	pop    %esi
  802457:	5f                   	pop    %edi
  802458:	5d                   	pop    %ebp
  802459:	c3                   	ret    
  80245a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802460:	0f bd f8             	bsr    %eax,%edi
  802463:	83 f7 1f             	xor    $0x1f,%edi
  802466:	75 48                	jne    8024b0 <__udivdi3+0xa0>
  802468:	39 f0                	cmp    %esi,%eax
  80246a:	72 06                	jb     802472 <__udivdi3+0x62>
  80246c:	31 c0                	xor    %eax,%eax
  80246e:	39 eb                	cmp    %ebp,%ebx
  802470:	77 de                	ja     802450 <__udivdi3+0x40>
  802472:	b8 01 00 00 00       	mov    $0x1,%eax
  802477:	eb d7                	jmp    802450 <__udivdi3+0x40>
  802479:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802480:	89 d9                	mov    %ebx,%ecx
  802482:	85 db                	test   %ebx,%ebx
  802484:	75 0b                	jne    802491 <__udivdi3+0x81>
  802486:	b8 01 00 00 00       	mov    $0x1,%eax
  80248b:	31 d2                	xor    %edx,%edx
  80248d:	f7 f3                	div    %ebx
  80248f:	89 c1                	mov    %eax,%ecx
  802491:	31 d2                	xor    %edx,%edx
  802493:	89 f0                	mov    %esi,%eax
  802495:	f7 f1                	div    %ecx
  802497:	89 c6                	mov    %eax,%esi
  802499:	89 e8                	mov    %ebp,%eax
  80249b:	89 f7                	mov    %esi,%edi
  80249d:	f7 f1                	div    %ecx
  80249f:	89 fa                	mov    %edi,%edx
  8024a1:	83 c4 1c             	add    $0x1c,%esp
  8024a4:	5b                   	pop    %ebx
  8024a5:	5e                   	pop    %esi
  8024a6:	5f                   	pop    %edi
  8024a7:	5d                   	pop    %ebp
  8024a8:	c3                   	ret    
  8024a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024b0:	89 f9                	mov    %edi,%ecx
  8024b2:	ba 20 00 00 00       	mov    $0x20,%edx
  8024b7:	29 fa                	sub    %edi,%edx
  8024b9:	d3 e0                	shl    %cl,%eax
  8024bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024bf:	89 d1                	mov    %edx,%ecx
  8024c1:	89 d8                	mov    %ebx,%eax
  8024c3:	d3 e8                	shr    %cl,%eax
  8024c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8024c9:	09 c1                	or     %eax,%ecx
  8024cb:	89 f0                	mov    %esi,%eax
  8024cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024d1:	89 f9                	mov    %edi,%ecx
  8024d3:	d3 e3                	shl    %cl,%ebx
  8024d5:	89 d1                	mov    %edx,%ecx
  8024d7:	d3 e8                	shr    %cl,%eax
  8024d9:	89 f9                	mov    %edi,%ecx
  8024db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8024df:	89 eb                	mov    %ebp,%ebx
  8024e1:	d3 e6                	shl    %cl,%esi
  8024e3:	89 d1                	mov    %edx,%ecx
  8024e5:	d3 eb                	shr    %cl,%ebx
  8024e7:	09 f3                	or     %esi,%ebx
  8024e9:	89 c6                	mov    %eax,%esi
  8024eb:	89 f2                	mov    %esi,%edx
  8024ed:	89 d8                	mov    %ebx,%eax
  8024ef:	f7 74 24 08          	divl   0x8(%esp)
  8024f3:	89 d6                	mov    %edx,%esi
  8024f5:	89 c3                	mov    %eax,%ebx
  8024f7:	f7 64 24 0c          	mull   0xc(%esp)
  8024fb:	39 d6                	cmp    %edx,%esi
  8024fd:	72 19                	jb     802518 <__udivdi3+0x108>
  8024ff:	89 f9                	mov    %edi,%ecx
  802501:	d3 e5                	shl    %cl,%ebp
  802503:	39 c5                	cmp    %eax,%ebp
  802505:	73 04                	jae    80250b <__udivdi3+0xfb>
  802507:	39 d6                	cmp    %edx,%esi
  802509:	74 0d                	je     802518 <__udivdi3+0x108>
  80250b:	89 d8                	mov    %ebx,%eax
  80250d:	31 ff                	xor    %edi,%edi
  80250f:	e9 3c ff ff ff       	jmp    802450 <__udivdi3+0x40>
  802514:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802518:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80251b:	31 ff                	xor    %edi,%edi
  80251d:	e9 2e ff ff ff       	jmp    802450 <__udivdi3+0x40>
  802522:	66 90                	xchg   %ax,%ax
  802524:	66 90                	xchg   %ax,%ax
  802526:	66 90                	xchg   %ax,%ax
  802528:	66 90                	xchg   %ax,%ax
  80252a:	66 90                	xchg   %ax,%ax
  80252c:	66 90                	xchg   %ax,%ax
  80252e:	66 90                	xchg   %ax,%ax

00802530 <__umoddi3>:
  802530:	f3 0f 1e fb          	endbr32 
  802534:	55                   	push   %ebp
  802535:	57                   	push   %edi
  802536:	56                   	push   %esi
  802537:	53                   	push   %ebx
  802538:	83 ec 1c             	sub    $0x1c,%esp
  80253b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80253f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802543:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802547:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80254b:	89 f0                	mov    %esi,%eax
  80254d:	89 da                	mov    %ebx,%edx
  80254f:	85 ff                	test   %edi,%edi
  802551:	75 15                	jne    802568 <__umoddi3+0x38>
  802553:	39 dd                	cmp    %ebx,%ebp
  802555:	76 39                	jbe    802590 <__umoddi3+0x60>
  802557:	f7 f5                	div    %ebp
  802559:	89 d0                	mov    %edx,%eax
  80255b:	31 d2                	xor    %edx,%edx
  80255d:	83 c4 1c             	add    $0x1c,%esp
  802560:	5b                   	pop    %ebx
  802561:	5e                   	pop    %esi
  802562:	5f                   	pop    %edi
  802563:	5d                   	pop    %ebp
  802564:	c3                   	ret    
  802565:	8d 76 00             	lea    0x0(%esi),%esi
  802568:	39 df                	cmp    %ebx,%edi
  80256a:	77 f1                	ja     80255d <__umoddi3+0x2d>
  80256c:	0f bd cf             	bsr    %edi,%ecx
  80256f:	83 f1 1f             	xor    $0x1f,%ecx
  802572:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802576:	75 40                	jne    8025b8 <__umoddi3+0x88>
  802578:	39 df                	cmp    %ebx,%edi
  80257a:	72 04                	jb     802580 <__umoddi3+0x50>
  80257c:	39 f5                	cmp    %esi,%ebp
  80257e:	77 dd                	ja     80255d <__umoddi3+0x2d>
  802580:	89 da                	mov    %ebx,%edx
  802582:	89 f0                	mov    %esi,%eax
  802584:	29 e8                	sub    %ebp,%eax
  802586:	19 fa                	sbb    %edi,%edx
  802588:	eb d3                	jmp    80255d <__umoddi3+0x2d>
  80258a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802590:	89 e9                	mov    %ebp,%ecx
  802592:	85 ed                	test   %ebp,%ebp
  802594:	75 0b                	jne    8025a1 <__umoddi3+0x71>
  802596:	b8 01 00 00 00       	mov    $0x1,%eax
  80259b:	31 d2                	xor    %edx,%edx
  80259d:	f7 f5                	div    %ebp
  80259f:	89 c1                	mov    %eax,%ecx
  8025a1:	89 d8                	mov    %ebx,%eax
  8025a3:	31 d2                	xor    %edx,%edx
  8025a5:	f7 f1                	div    %ecx
  8025a7:	89 f0                	mov    %esi,%eax
  8025a9:	f7 f1                	div    %ecx
  8025ab:	89 d0                	mov    %edx,%eax
  8025ad:	31 d2                	xor    %edx,%edx
  8025af:	eb ac                	jmp    80255d <__umoddi3+0x2d>
  8025b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025b8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8025bc:	ba 20 00 00 00       	mov    $0x20,%edx
  8025c1:	29 c2                	sub    %eax,%edx
  8025c3:	89 c1                	mov    %eax,%ecx
  8025c5:	89 e8                	mov    %ebp,%eax
  8025c7:	d3 e7                	shl    %cl,%edi
  8025c9:	89 d1                	mov    %edx,%ecx
  8025cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8025cf:	d3 e8                	shr    %cl,%eax
  8025d1:	89 c1                	mov    %eax,%ecx
  8025d3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8025d7:	09 f9                	or     %edi,%ecx
  8025d9:	89 df                	mov    %ebx,%edi
  8025db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025df:	89 c1                	mov    %eax,%ecx
  8025e1:	d3 e5                	shl    %cl,%ebp
  8025e3:	89 d1                	mov    %edx,%ecx
  8025e5:	d3 ef                	shr    %cl,%edi
  8025e7:	89 c1                	mov    %eax,%ecx
  8025e9:	89 f0                	mov    %esi,%eax
  8025eb:	d3 e3                	shl    %cl,%ebx
  8025ed:	89 d1                	mov    %edx,%ecx
  8025ef:	89 fa                	mov    %edi,%edx
  8025f1:	d3 e8                	shr    %cl,%eax
  8025f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8025f8:	09 d8                	or     %ebx,%eax
  8025fa:	f7 74 24 08          	divl   0x8(%esp)
  8025fe:	89 d3                	mov    %edx,%ebx
  802600:	d3 e6                	shl    %cl,%esi
  802602:	f7 e5                	mul    %ebp
  802604:	89 c7                	mov    %eax,%edi
  802606:	89 d1                	mov    %edx,%ecx
  802608:	39 d3                	cmp    %edx,%ebx
  80260a:	72 06                	jb     802612 <__umoddi3+0xe2>
  80260c:	75 0e                	jne    80261c <__umoddi3+0xec>
  80260e:	39 c6                	cmp    %eax,%esi
  802610:	73 0a                	jae    80261c <__umoddi3+0xec>
  802612:	29 e8                	sub    %ebp,%eax
  802614:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802618:	89 d1                	mov    %edx,%ecx
  80261a:	89 c7                	mov    %eax,%edi
  80261c:	89 f5                	mov    %esi,%ebp
  80261e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802622:	29 fd                	sub    %edi,%ebp
  802624:	19 cb                	sbb    %ecx,%ebx
  802626:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80262b:	89 d8                	mov    %ebx,%eax
  80262d:	d3 e0                	shl    %cl,%eax
  80262f:	89 f1                	mov    %esi,%ecx
  802631:	d3 ed                	shr    %cl,%ebp
  802633:	d3 eb                	shr    %cl,%ebx
  802635:	09 e8                	or     %ebp,%eax
  802637:	89 da                	mov    %ebx,%edx
  802639:	83 c4 1c             	add    $0x1c,%esp
  80263c:	5b                   	pop    %ebx
  80263d:	5e                   	pop    %esi
  80263e:	5f                   	pop    %edi
  80263f:	5d                   	pop    %ebp
  802640:	c3                   	ret    
