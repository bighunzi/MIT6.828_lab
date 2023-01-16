
obj/user/badsegment：     文件格式 elf32-i386


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
	call libmain
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void
umain(int argc, char **argv)
{
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800033:	66 b8 28 00          	mov    $0x28,%ax
  800037:	8e d8                	mov    %eax,%ds
}
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	53                   	push   %ebx
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	e8 39 00 00 00       	call   80007f <__x86.get_pc_thunk.bx>
  800046:	81 c3 ba 1f 00 00    	add    $0x1fba,%ebx
  80004c:	8b 45 08             	mov    0x8(%ebp),%eax
  80004f:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800052:	c7 83 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
  800059:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 c0                	test   %eax,%eax
  80005e:	7e 08                	jle    800068 <libmain+0x2e>
		binaryname = argv[0];
  800060:	8b 0a                	mov    (%edx),%ecx
  800062:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800068:	83 ec 08             	sub    $0x8,%esp
  80006b:	52                   	push   %edx
  80006c:	50                   	push   %eax
  80006d:	e8 c1 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800072:	e8 0c 00 00 00       	call   800083 <exit>
}
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007d:	c9                   	leave  
  80007e:	c3                   	ret    

0080007f <__x86.get_pc_thunk.bx>:
  80007f:	8b 1c 24             	mov    (%esp),%ebx
  800082:	c3                   	ret    

00800083 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800083:	55                   	push   %ebp
  800084:	89 e5                	mov    %esp,%ebp
  800086:	53                   	push   %ebx
  800087:	83 ec 10             	sub    $0x10,%esp
  80008a:	e8 f0 ff ff ff       	call   80007f <__x86.get_pc_thunk.bx>
  80008f:	81 c3 71 1f 00 00    	add    $0x1f71,%ebx
	sys_env_destroy(0);
  800095:	6a 00                	push   $0x0
  800097:	e8 45 00 00 00       	call   8000e1 <sys_env_destroy>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a2:	c9                   	leave  
  8000a3:	c3                   	ret    

008000a4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	57                   	push   %edi
  8000a8:	56                   	push   %esi
  8000a9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8000af:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	89 c3                	mov    %eax,%ebx
  8000b7:	89 c7                	mov    %eax,%edi
  8000b9:	89 c6                	mov    %eax,%esi
  8000bb:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5f                   	pop    %edi
  8000c0:	5d                   	pop    %ebp
  8000c1:	c3                   	ret    

008000c2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c2:	55                   	push   %ebp
  8000c3:	89 e5                	mov    %esp,%ebp
  8000c5:	57                   	push   %edi
  8000c6:	56                   	push   %esi
  8000c7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d2:	89 d1                	mov    %edx,%ecx
  8000d4:	89 d3                	mov    %edx,%ebx
  8000d6:	89 d7                	mov    %edx,%edi
  8000d8:	89 d6                	mov    %edx,%esi
  8000da:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000dc:	5b                   	pop    %ebx
  8000dd:	5e                   	pop    %esi
  8000de:	5f                   	pop    %edi
  8000df:	5d                   	pop    %ebp
  8000e0:	c3                   	ret    

008000e1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e1:	55                   	push   %ebp
  8000e2:	89 e5                	mov    %esp,%ebp
  8000e4:	57                   	push   %edi
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	83 ec 1c             	sub    $0x1c,%esp
  8000ea:	e8 66 00 00 00       	call   800155 <__x86.get_pc_thunk.ax>
  8000ef:	05 11 1f 00 00       	add    $0x1f11,%eax
  8000f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8000f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ff:	b8 03 00 00 00       	mov    $0x3,%eax
  800104:	89 cb                	mov    %ecx,%ebx
  800106:	89 cf                	mov    %ecx,%edi
  800108:	89 ce                	mov    %ecx,%esi
  80010a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010c:	85 c0                	test   %eax,%eax
  80010e:	7f 08                	jg     800118 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800113:	5b                   	pop    %ebx
  800114:	5e                   	pop    %esi
  800115:	5f                   	pop    %edi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800118:	83 ec 0c             	sub    $0xc,%esp
  80011b:	50                   	push   %eax
  80011c:	6a 03                	push   $0x3
  80011e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800121:	8d 83 4e ee ff ff    	lea    -0x11b2(%ebx),%eax
  800127:	50                   	push   %eax
  800128:	6a 23                	push   $0x23
  80012a:	8d 83 6b ee ff ff    	lea    -0x1195(%ebx),%eax
  800130:	50                   	push   %eax
  800131:	e8 23 00 00 00       	call   800159 <_panic>

00800136 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800136:	55                   	push   %ebp
  800137:	89 e5                	mov    %esp,%ebp
  800139:	57                   	push   %edi
  80013a:	56                   	push   %esi
  80013b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013c:	ba 00 00 00 00       	mov    $0x0,%edx
  800141:	b8 02 00 00 00       	mov    $0x2,%eax
  800146:	89 d1                	mov    %edx,%ecx
  800148:	89 d3                	mov    %edx,%ebx
  80014a:	89 d7                	mov    %edx,%edi
  80014c:	89 d6                	mov    %edx,%esi
  80014e:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800150:	5b                   	pop    %ebx
  800151:	5e                   	pop    %esi
  800152:	5f                   	pop    %edi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <__x86.get_pc_thunk.ax>:
  800155:	8b 04 24             	mov    (%esp),%eax
  800158:	c3                   	ret    

00800159 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	57                   	push   %edi
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
  80015f:	83 ec 0c             	sub    $0xc,%esp
  800162:	e8 18 ff ff ff       	call   80007f <__x86.get_pc_thunk.bx>
  800167:	81 c3 99 1e 00 00    	add    $0x1e99,%ebx
	va_list ap;

	va_start(ap, fmt);
  80016d:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800170:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800176:	8b 38                	mov    (%eax),%edi
  800178:	e8 b9 ff ff ff       	call   800136 <sys_getenvid>
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	ff 75 0c             	push   0xc(%ebp)
  800183:	ff 75 08             	push   0x8(%ebp)
  800186:	57                   	push   %edi
  800187:	50                   	push   %eax
  800188:	8d 83 7c ee ff ff    	lea    -0x1184(%ebx),%eax
  80018e:	50                   	push   %eax
  80018f:	e8 d1 00 00 00       	call   800265 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800194:	83 c4 18             	add    $0x18,%esp
  800197:	56                   	push   %esi
  800198:	ff 75 10             	push   0x10(%ebp)
  80019b:	e8 63 00 00 00       	call   800203 <vcprintf>
	cprintf("\n");
  8001a0:	8d 83 9f ee ff ff    	lea    -0x1161(%ebx),%eax
  8001a6:	89 04 24             	mov    %eax,(%esp)
  8001a9:	e8 b7 00 00 00       	call   800265 <cprintf>
  8001ae:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b1:	cc                   	int3   
  8001b2:	eb fd                	jmp    8001b1 <_panic+0x58>

008001b4 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	e8 c1 fe ff ff       	call   80007f <__x86.get_pc_thunk.bx>
  8001be:	81 c3 42 1e 00 00    	add    $0x1e42,%ebx
  8001c4:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001c7:	8b 16                	mov    (%esi),%edx
  8001c9:	8d 42 01             	lea    0x1(%edx),%eax
  8001cc:	89 06                	mov    %eax,(%esi)
  8001ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d1:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001d5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001da:	74 0b                	je     8001e7 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001dc:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5d                   	pop    %ebp
  8001e6:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001e7:	83 ec 08             	sub    $0x8,%esp
  8001ea:	68 ff 00 00 00       	push   $0xff
  8001ef:	8d 46 08             	lea    0x8(%esi),%eax
  8001f2:	50                   	push   %eax
  8001f3:	e8 ac fe ff ff       	call   8000a4 <sys_cputs>
		b->idx = 0;
  8001f8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8001fe:	83 c4 10             	add    $0x10,%esp
  800201:	eb d9                	jmp    8001dc <putch+0x28>

00800203 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800203:	55                   	push   %ebp
  800204:	89 e5                	mov    %esp,%ebp
  800206:	53                   	push   %ebx
  800207:	81 ec 14 01 00 00    	sub    $0x114,%esp
  80020d:	e8 6d fe ff ff       	call   80007f <__x86.get_pc_thunk.bx>
  800212:	81 c3 ee 1d 00 00    	add    $0x1dee,%ebx
	struct printbuf b;

	b.idx = 0;
  800218:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021f:	00 00 00 
	b.cnt = 0;
  800222:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800229:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022c:	ff 75 0c             	push   0xc(%ebp)
  80022f:	ff 75 08             	push   0x8(%ebp)
  800232:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800238:	50                   	push   %eax
  800239:	8d 83 b4 e1 ff ff    	lea    -0x1e4c(%ebx),%eax
  80023f:	50                   	push   %eax
  800240:	e8 2c 01 00 00       	call   800371 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800245:	83 c4 08             	add    $0x8,%esp
  800248:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80024e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800254:	50                   	push   %eax
  800255:	e8 4a fe ff ff       	call   8000a4 <sys_cputs>

	return b.cnt;
}
  80025a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800260:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800263:	c9                   	leave  
  800264:	c3                   	ret    

00800265 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026b:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80026e:	50                   	push   %eax
  80026f:	ff 75 08             	push   0x8(%ebp)
  800272:	e8 8c ff ff ff       	call   800203 <vcprintf>
	va_end(ap);

	return cnt;
}
  800277:	c9                   	leave  
  800278:	c3                   	ret    

00800279 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 2c             	sub    $0x2c,%esp
  800282:	e8 07 06 00 00       	call   80088e <__x86.get_pc_thunk.cx>
  800287:	81 c1 79 1d 00 00    	add    $0x1d79,%ecx
  80028d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800290:	89 c7                	mov    %eax,%edi
  800292:	89 d6                	mov    %edx,%esi
  800294:	8b 45 08             	mov    0x8(%ebp),%eax
  800297:	8b 55 0c             	mov    0xc(%ebp),%edx
  80029a:	89 d1                	mov    %edx,%ecx
  80029c:	89 c2                	mov    %eax,%edx
  80029e:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002a1:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002ad:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002b4:	39 c2                	cmp    %eax,%edx
  8002b6:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002b9:	72 41                	jb     8002fc <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002bb:	83 ec 0c             	sub    $0xc,%esp
  8002be:	ff 75 18             	push   0x18(%ebp)
  8002c1:	83 eb 01             	sub    $0x1,%ebx
  8002c4:	53                   	push   %ebx
  8002c5:	50                   	push   %eax
  8002c6:	83 ec 08             	sub    $0x8,%esp
  8002c9:	ff 75 e4             	push   -0x1c(%ebp)
  8002cc:	ff 75 e0             	push   -0x20(%ebp)
  8002cf:	ff 75 d4             	push   -0x2c(%ebp)
  8002d2:	ff 75 d0             	push   -0x30(%ebp)
  8002d5:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002d8:	e8 33 09 00 00       	call   800c10 <__udivdi3>
  8002dd:	83 c4 18             	add    $0x18,%esp
  8002e0:	52                   	push   %edx
  8002e1:	50                   	push   %eax
  8002e2:	89 f2                	mov    %esi,%edx
  8002e4:	89 f8                	mov    %edi,%eax
  8002e6:	e8 8e ff ff ff       	call   800279 <printnum>
  8002eb:	83 c4 20             	add    $0x20,%esp
  8002ee:	eb 13                	jmp    800303 <printnum+0x8a>
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
  800301:	7f ed                	jg     8002f0 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800303:	83 ec 08             	sub    $0x8,%esp
  800306:	56                   	push   %esi
  800307:	83 ec 04             	sub    $0x4,%esp
  80030a:	ff 75 e4             	push   -0x1c(%ebp)
  80030d:	ff 75 e0             	push   -0x20(%ebp)
  800310:	ff 75 d4             	push   -0x2c(%ebp)
  800313:	ff 75 d0             	push   -0x30(%ebp)
  800316:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800319:	e8 12 0a 00 00       	call   800d30 <__umoddi3>
  80031e:	83 c4 14             	add    $0x14,%esp
  800321:	0f be 84 03 a1 ee ff 	movsbl -0x115f(%ebx,%eax,1),%eax
  800328:	ff 
  800329:	50                   	push   %eax
  80032a:	ff d7                	call   *%edi
}
  80032c:	83 c4 10             	add    $0x10,%esp
  80032f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800332:	5b                   	pop    %ebx
  800333:	5e                   	pop    %esi
  800334:	5f                   	pop    %edi
  800335:	5d                   	pop    %ebp
  800336:	c3                   	ret    

00800337 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800341:	8b 10                	mov    (%eax),%edx
  800343:	3b 50 04             	cmp    0x4(%eax),%edx
  800346:	73 0a                	jae    800352 <sprintputch+0x1b>
		*b->buf++ = ch;
  800348:	8d 4a 01             	lea    0x1(%edx),%ecx
  80034b:	89 08                	mov    %ecx,(%eax)
  80034d:	8b 45 08             	mov    0x8(%ebp),%eax
  800350:	88 02                	mov    %al,(%edx)
}
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <printfmt>:
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80035a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035d:	50                   	push   %eax
  80035e:	ff 75 10             	push   0x10(%ebp)
  800361:	ff 75 0c             	push   0xc(%ebp)
  800364:	ff 75 08             	push   0x8(%ebp)
  800367:	e8 05 00 00 00       	call   800371 <vprintfmt>
}
  80036c:	83 c4 10             	add    $0x10,%esp
  80036f:	c9                   	leave  
  800370:	c3                   	ret    

00800371 <vprintfmt>:
{
  800371:	55                   	push   %ebp
  800372:	89 e5                	mov    %esp,%ebp
  800374:	57                   	push   %edi
  800375:	56                   	push   %esi
  800376:	53                   	push   %ebx
  800377:	83 ec 3c             	sub    $0x3c,%esp
  80037a:	e8 d6 fd ff ff       	call   800155 <__x86.get_pc_thunk.ax>
  80037f:	05 81 1c 00 00       	add    $0x1c81,%eax
  800384:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800387:	8b 75 08             	mov    0x8(%ebp),%esi
  80038a:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80038d:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800390:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  800396:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800399:	eb 0a                	jmp    8003a5 <vprintfmt+0x34>
			putch(ch, putdat);
  80039b:	83 ec 08             	sub    $0x8,%esp
  80039e:	57                   	push   %edi
  80039f:	50                   	push   %eax
  8003a0:	ff d6                	call   *%esi
  8003a2:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a5:	83 c3 01             	add    $0x1,%ebx
  8003a8:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003ac:	83 f8 25             	cmp    $0x25,%eax
  8003af:	74 0c                	je     8003bd <vprintfmt+0x4c>
			if (ch == '\0')
  8003b1:	85 c0                	test   %eax,%eax
  8003b3:	75 e6                	jne    80039b <vprintfmt+0x2a>
}
  8003b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b8:	5b                   	pop    %ebx
  8003b9:	5e                   	pop    %esi
  8003ba:	5f                   	pop    %edi
  8003bb:	5d                   	pop    %ebp
  8003bc:	c3                   	ret    
		padc = ' ';
  8003bd:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003c1:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  8003c8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003cf:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  8003d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003db:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003de:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e1:	8d 43 01             	lea    0x1(%ebx),%eax
  8003e4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e7:	0f b6 13             	movzbl (%ebx),%edx
  8003ea:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003ed:	3c 55                	cmp    $0x55,%al
  8003ef:	0f 87 fd 03 00 00    	ja     8007f2 <.L20>
  8003f5:	0f b6 c0             	movzbl %al,%eax
  8003f8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003fb:	89 ce                	mov    %ecx,%esi
  8003fd:	03 b4 81 30 ef ff ff 	add    -0x10d0(%ecx,%eax,4),%esi
  800404:	ff e6                	jmp    *%esi

00800406 <.L68>:
  800406:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800409:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  80040d:	eb d2                	jmp    8003e1 <vprintfmt+0x70>

0080040f <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  80040f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800412:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800416:	eb c9                	jmp    8003e1 <vprintfmt+0x70>

00800418 <.L31>:
  800418:	0f b6 d2             	movzbl %dl,%edx
  80041b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  80041e:	b8 00 00 00 00       	mov    $0x0,%eax
  800423:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800426:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800429:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80042d:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800430:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800433:	83 f9 09             	cmp    $0x9,%ecx
  800436:	77 58                	ja     800490 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800438:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  80043b:	eb e9                	jmp    800426 <.L31+0xe>

0080043d <.L34>:
			precision = va_arg(ap, int);
  80043d:	8b 45 14             	mov    0x14(%ebp),%eax
  800440:	8b 00                	mov    (%eax),%eax
  800442:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800445:	8b 45 14             	mov    0x14(%ebp),%eax
  800448:	8d 40 04             	lea    0x4(%eax),%eax
  80044b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80044e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800451:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800455:	79 8a                	jns    8003e1 <vprintfmt+0x70>
				width = precision, precision = -1;
  800457:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80045a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80045d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800464:	e9 78 ff ff ff       	jmp    8003e1 <vprintfmt+0x70>

00800469 <.L33>:
  800469:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80046c:	85 d2                	test   %edx,%edx
  80046e:	b8 00 00 00 00       	mov    $0x0,%eax
  800473:	0f 49 c2             	cmovns %edx,%eax
  800476:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800479:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  80047c:	e9 60 ff ff ff       	jmp    8003e1 <vprintfmt+0x70>

00800481 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  800484:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  80048b:	e9 51 ff ff ff       	jmp    8003e1 <vprintfmt+0x70>
  800490:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800493:	89 75 08             	mov    %esi,0x8(%ebp)
  800496:	eb b9                	jmp    800451 <.L34+0x14>

00800498 <.L27>:
			lflag++;
  800498:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80049c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  80049f:	e9 3d ff ff ff       	jmp    8003e1 <vprintfmt+0x70>

008004a4 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004aa:	8d 58 04             	lea    0x4(%eax),%ebx
  8004ad:	83 ec 08             	sub    $0x8,%esp
  8004b0:	57                   	push   %edi
  8004b1:	ff 30                	push   (%eax)
  8004b3:	ff d6                	call   *%esi
			break;
  8004b5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004b8:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004bb:	e9 c8 02 00 00       	jmp    800788 <.L25+0x45>

008004c0 <.L28>:
			err = va_arg(ap, int);
  8004c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c6:	8d 58 04             	lea    0x4(%eax),%ebx
  8004c9:	8b 10                	mov    (%eax),%edx
  8004cb:	89 d0                	mov    %edx,%eax
  8004cd:	f7 d8                	neg    %eax
  8004cf:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d2:	83 f8 06             	cmp    $0x6,%eax
  8004d5:	7f 27                	jg     8004fe <.L28+0x3e>
  8004d7:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004da:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004dd:	85 d2                	test   %edx,%edx
  8004df:	74 1d                	je     8004fe <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8004e1:	52                   	push   %edx
  8004e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e5:	8d 80 c2 ee ff ff    	lea    -0x113e(%eax),%eax
  8004eb:	50                   	push   %eax
  8004ec:	57                   	push   %edi
  8004ed:	56                   	push   %esi
  8004ee:	e8 61 fe ff ff       	call   800354 <printfmt>
  8004f3:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004f6:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004f9:	e9 8a 02 00 00       	jmp    800788 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004fe:	50                   	push   %eax
  8004ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800502:	8d 80 b9 ee ff ff    	lea    -0x1147(%eax),%eax
  800508:	50                   	push   %eax
  800509:	57                   	push   %edi
  80050a:	56                   	push   %esi
  80050b:	e8 44 fe ff ff       	call   800354 <printfmt>
  800510:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800513:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800516:	e9 6d 02 00 00       	jmp    800788 <.L25+0x45>

0080051b <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  80051b:	8b 75 08             	mov    0x8(%ebp),%esi
  80051e:	8b 45 14             	mov    0x14(%ebp),%eax
  800521:	83 c0 04             	add    $0x4,%eax
  800524:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800527:	8b 45 14             	mov    0x14(%ebp),%eax
  80052a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80052c:	85 d2                	test   %edx,%edx
  80052e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800531:	8d 80 b2 ee ff ff    	lea    -0x114e(%eax),%eax
  800537:	0f 45 c2             	cmovne %edx,%eax
  80053a:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  80053d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800541:	7e 06                	jle    800549 <.L24+0x2e>
  800543:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800547:	75 0d                	jne    800556 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800549:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80054c:	89 c3                	mov    %eax,%ebx
  80054e:	03 45 d4             	add    -0x2c(%ebp),%eax
  800551:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800554:	eb 58                	jmp    8005ae <.L24+0x93>
  800556:	83 ec 08             	sub    $0x8,%esp
  800559:	ff 75 d8             	push   -0x28(%ebp)
  80055c:	ff 75 c8             	push   -0x38(%ebp)
  80055f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800562:	e8 43 03 00 00       	call   8008aa <strnlen>
  800567:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80056a:	29 c2                	sub    %eax,%edx
  80056c:	89 55 bc             	mov    %edx,-0x44(%ebp)
  80056f:	83 c4 10             	add    $0x10,%esp
  800572:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  800574:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800578:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80057b:	eb 0f                	jmp    80058c <.L24+0x71>
					putch(padc, putdat);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	57                   	push   %edi
  800581:	ff 75 d4             	push   -0x2c(%ebp)
  800584:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800586:	83 eb 01             	sub    $0x1,%ebx
  800589:	83 c4 10             	add    $0x10,%esp
  80058c:	85 db                	test   %ebx,%ebx
  80058e:	7f ed                	jg     80057d <.L24+0x62>
  800590:	8b 55 bc             	mov    -0x44(%ebp),%edx
  800593:	85 d2                	test   %edx,%edx
  800595:	b8 00 00 00 00       	mov    $0x0,%eax
  80059a:	0f 49 c2             	cmovns %edx,%eax
  80059d:	29 c2                	sub    %eax,%edx
  80059f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005a2:	eb a5                	jmp    800549 <.L24+0x2e>
					putch(ch, putdat);
  8005a4:	83 ec 08             	sub    $0x8,%esp
  8005a7:	57                   	push   %edi
  8005a8:	52                   	push   %edx
  8005a9:	ff d6                	call   *%esi
  8005ab:	83 c4 10             	add    $0x10,%esp
  8005ae:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005b1:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b3:	83 c3 01             	add    $0x1,%ebx
  8005b6:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005ba:	0f be d0             	movsbl %al,%edx
  8005bd:	85 d2                	test   %edx,%edx
  8005bf:	74 4b                	je     80060c <.L24+0xf1>
  8005c1:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c5:	78 06                	js     8005cd <.L24+0xb2>
  8005c7:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005cb:	78 1e                	js     8005eb <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005cd:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005d1:	74 d1                	je     8005a4 <.L24+0x89>
  8005d3:	0f be c0             	movsbl %al,%eax
  8005d6:	83 e8 20             	sub    $0x20,%eax
  8005d9:	83 f8 5e             	cmp    $0x5e,%eax
  8005dc:	76 c6                	jbe    8005a4 <.L24+0x89>
					putch('?', putdat);
  8005de:	83 ec 08             	sub    $0x8,%esp
  8005e1:	57                   	push   %edi
  8005e2:	6a 3f                	push   $0x3f
  8005e4:	ff d6                	call   *%esi
  8005e6:	83 c4 10             	add    $0x10,%esp
  8005e9:	eb c3                	jmp    8005ae <.L24+0x93>
  8005eb:	89 cb                	mov    %ecx,%ebx
  8005ed:	eb 0e                	jmp    8005fd <.L24+0xe2>
				putch(' ', putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	57                   	push   %edi
  8005f3:	6a 20                	push   $0x20
  8005f5:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005f7:	83 eb 01             	sub    $0x1,%ebx
  8005fa:	83 c4 10             	add    $0x10,%esp
  8005fd:	85 db                	test   %ebx,%ebx
  8005ff:	7f ee                	jg     8005ef <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  800601:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800604:	89 45 14             	mov    %eax,0x14(%ebp)
  800607:	e9 7c 01 00 00       	jmp    800788 <.L25+0x45>
  80060c:	89 cb                	mov    %ecx,%ebx
  80060e:	eb ed                	jmp    8005fd <.L24+0xe2>

00800610 <.L29>:
	if (lflag >= 2)
  800610:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800613:	8b 75 08             	mov    0x8(%ebp),%esi
  800616:	83 f9 01             	cmp    $0x1,%ecx
  800619:	7f 1b                	jg     800636 <.L29+0x26>
	else if (lflag)
  80061b:	85 c9                	test   %ecx,%ecx
  80061d:	74 63                	je     800682 <.L29+0x72>
		return va_arg(*ap, long);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8b 00                	mov    (%eax),%eax
  800624:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800627:	99                   	cltd   
  800628:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8d 40 04             	lea    0x4(%eax),%eax
  800631:	89 45 14             	mov    %eax,0x14(%ebp)
  800634:	eb 17                	jmp    80064d <.L29+0x3d>
		return va_arg(*ap, long long);
  800636:	8b 45 14             	mov    0x14(%ebp),%eax
  800639:	8b 50 04             	mov    0x4(%eax),%edx
  80063c:	8b 00                	mov    (%eax),%eax
  80063e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800641:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800644:	8b 45 14             	mov    0x14(%ebp),%eax
  800647:	8d 40 08             	lea    0x8(%eax),%eax
  80064a:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80064d:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800650:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  800653:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800658:	85 db                	test   %ebx,%ebx
  80065a:	0f 89 0e 01 00 00    	jns    80076e <.L25+0x2b>
				putch('-', putdat);
  800660:	83 ec 08             	sub    $0x8,%esp
  800663:	57                   	push   %edi
  800664:	6a 2d                	push   $0x2d
  800666:	ff d6                	call   *%esi
				num = -(long long) num;
  800668:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80066b:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80066e:	f7 d9                	neg    %ecx
  800670:	83 d3 00             	adc    $0x0,%ebx
  800673:	f7 db                	neg    %ebx
  800675:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800678:	ba 0a 00 00 00       	mov    $0xa,%edx
  80067d:	e9 ec 00 00 00       	jmp    80076e <.L25+0x2b>
		return va_arg(*ap, int);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8b 00                	mov    (%eax),%eax
  800687:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068a:	99                   	cltd   
  80068b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068e:	8b 45 14             	mov    0x14(%ebp),%eax
  800691:	8d 40 04             	lea    0x4(%eax),%eax
  800694:	89 45 14             	mov    %eax,0x14(%ebp)
  800697:	eb b4                	jmp    80064d <.L29+0x3d>

00800699 <.L23>:
	if (lflag >= 2)
  800699:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80069c:	8b 75 08             	mov    0x8(%ebp),%esi
  80069f:	83 f9 01             	cmp    $0x1,%ecx
  8006a2:	7f 1e                	jg     8006c2 <.L23+0x29>
	else if (lflag)
  8006a4:	85 c9                	test   %ecx,%ecx
  8006a6:	74 32                	je     8006da <.L23+0x41>
		return va_arg(*ap, unsigned long);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8b 08                	mov    (%eax),%ecx
  8006ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006b2:	8d 40 04             	lea    0x4(%eax),%eax
  8006b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006b8:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006bd:	e9 ac 00 00 00       	jmp    80076e <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8b 08                	mov    (%eax),%ecx
  8006c7:	8b 58 04             	mov    0x4(%eax),%ebx
  8006ca:	8d 40 08             	lea    0x8(%eax),%eax
  8006cd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d0:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006d5:	e9 94 00 00 00       	jmp    80076e <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006da:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dd:	8b 08                	mov    (%eax),%ecx
  8006df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e4:	8d 40 04             	lea    0x4(%eax),%eax
  8006e7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ea:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  8006ef:	eb 7d                	jmp    80076e <.L25+0x2b>

008006f1 <.L26>:
	if (lflag >= 2)
  8006f1:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006f4:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f7:	83 f9 01             	cmp    $0x1,%ecx
  8006fa:	7f 1b                	jg     800717 <.L26+0x26>
	else if (lflag)
  8006fc:	85 c9                	test   %ecx,%ecx
  8006fe:	74 2c                	je     80072c <.L26+0x3b>
		return va_arg(*ap, unsigned long);
  800700:	8b 45 14             	mov    0x14(%ebp),%eax
  800703:	8b 08                	mov    (%eax),%ecx
  800705:	bb 00 00 00 00       	mov    $0x0,%ebx
  80070a:	8d 40 04             	lea    0x4(%eax),%eax
  80070d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800710:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
  800715:	eb 57                	jmp    80076e <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  800717:	8b 45 14             	mov    0x14(%ebp),%eax
  80071a:	8b 08                	mov    (%eax),%ecx
  80071c:	8b 58 04             	mov    0x4(%eax),%ebx
  80071f:	8d 40 08             	lea    0x8(%eax),%eax
  800722:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800725:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
  80072a:	eb 42                	jmp    80076e <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  80072c:	8b 45 14             	mov    0x14(%ebp),%eax
  80072f:	8b 08                	mov    (%eax),%ecx
  800731:	bb 00 00 00 00       	mov    $0x0,%ebx
  800736:	8d 40 04             	lea    0x4(%eax),%eax
  800739:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80073c:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
  800741:	eb 2b                	jmp    80076e <.L25+0x2b>

00800743 <.L25>:
			putch('0', putdat);
  800743:	8b 75 08             	mov    0x8(%ebp),%esi
  800746:	83 ec 08             	sub    $0x8,%esp
  800749:	57                   	push   %edi
  80074a:	6a 30                	push   $0x30
  80074c:	ff d6                	call   *%esi
			putch('x', putdat);
  80074e:	83 c4 08             	add    $0x8,%esp
  800751:	57                   	push   %edi
  800752:	6a 78                	push   $0x78
  800754:	ff d6                	call   *%esi
			num = (unsigned long long)
  800756:	8b 45 14             	mov    0x14(%ebp),%eax
  800759:	8b 08                	mov    (%eax),%ecx
  80075b:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800760:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800763:	8d 40 04             	lea    0x4(%eax),%eax
  800766:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800769:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  80076e:	83 ec 0c             	sub    $0xc,%esp
  800771:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800775:	50                   	push   %eax
  800776:	ff 75 d4             	push   -0x2c(%ebp)
  800779:	52                   	push   %edx
  80077a:	53                   	push   %ebx
  80077b:	51                   	push   %ecx
  80077c:	89 fa                	mov    %edi,%edx
  80077e:	89 f0                	mov    %esi,%eax
  800780:	e8 f4 fa ff ff       	call   800279 <printnum>
			break;
  800785:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800788:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80078b:	e9 15 fc ff ff       	jmp    8003a5 <vprintfmt+0x34>

00800790 <.L21>:
	if (lflag >= 2)
  800790:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800793:	8b 75 08             	mov    0x8(%ebp),%esi
  800796:	83 f9 01             	cmp    $0x1,%ecx
  800799:	7f 1b                	jg     8007b6 <.L21+0x26>
	else if (lflag)
  80079b:	85 c9                	test   %ecx,%ecx
  80079d:	74 2c                	je     8007cb <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  80079f:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a2:	8b 08                	mov    (%eax),%ecx
  8007a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007a9:	8d 40 04             	lea    0x4(%eax),%eax
  8007ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007af:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  8007b4:	eb b8                	jmp    80076e <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8007b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b9:	8b 08                	mov    (%eax),%ecx
  8007bb:	8b 58 04             	mov    0x4(%eax),%ebx
  8007be:	8d 40 08             	lea    0x8(%eax),%eax
  8007c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c4:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8007c9:	eb a3                	jmp    80076e <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8b 08                	mov    (%eax),%ecx
  8007d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007d5:	8d 40 04             	lea    0x4(%eax),%eax
  8007d8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007db:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007e0:	eb 8c                	jmp    80076e <.L25+0x2b>

008007e2 <.L35>:
			putch(ch, putdat);
  8007e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e5:	83 ec 08             	sub    $0x8,%esp
  8007e8:	57                   	push   %edi
  8007e9:	6a 25                	push   $0x25
  8007eb:	ff d6                	call   *%esi
			break;
  8007ed:	83 c4 10             	add    $0x10,%esp
  8007f0:	eb 96                	jmp    800788 <.L25+0x45>

008007f2 <.L20>:
			putch('%', putdat);
  8007f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f5:	83 ec 08             	sub    $0x8,%esp
  8007f8:	57                   	push   %edi
  8007f9:	6a 25                	push   $0x25
  8007fb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007fd:	83 c4 10             	add    $0x10,%esp
  800800:	89 d8                	mov    %ebx,%eax
  800802:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800806:	74 05                	je     80080d <.L20+0x1b>
  800808:	83 e8 01             	sub    $0x1,%eax
  80080b:	eb f5                	jmp    800802 <.L20+0x10>
  80080d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800810:	e9 73 ff ff ff       	jmp    800788 <.L25+0x45>

00800815 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	53                   	push   %ebx
  800819:	83 ec 14             	sub    $0x14,%esp
  80081c:	e8 5e f8 ff ff       	call   80007f <__x86.get_pc_thunk.bx>
  800821:	81 c3 df 17 00 00    	add    $0x17df,%ebx
  800827:	8b 45 08             	mov    0x8(%ebp),%eax
  80082a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80082d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800830:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800834:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800837:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083e:	85 c0                	test   %eax,%eax
  800840:	74 2b                	je     80086d <vsnprintf+0x58>
  800842:	85 d2                	test   %edx,%edx
  800844:	7e 27                	jle    80086d <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800846:	ff 75 14             	push   0x14(%ebp)
  800849:	ff 75 10             	push   0x10(%ebp)
  80084c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084f:	50                   	push   %eax
  800850:	8d 83 37 e3 ff ff    	lea    -0x1cc9(%ebx),%eax
  800856:	50                   	push   %eax
  800857:	e8 15 fb ff ff       	call   800371 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80085c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800862:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800865:	83 c4 10             	add    $0x10,%esp
}
  800868:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086b:	c9                   	leave  
  80086c:	c3                   	ret    
		return -E_INVAL;
  80086d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800872:	eb f4                	jmp    800868 <vsnprintf+0x53>

00800874 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800874:	55                   	push   %ebp
  800875:	89 e5                	mov    %esp,%ebp
  800877:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80087a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80087d:	50                   	push   %eax
  80087e:	ff 75 10             	push   0x10(%ebp)
  800881:	ff 75 0c             	push   0xc(%ebp)
  800884:	ff 75 08             	push   0x8(%ebp)
  800887:	e8 89 ff ff ff       	call   800815 <vsnprintf>
	va_end(ap);

	return rc;
}
  80088c:	c9                   	leave  
  80088d:	c3                   	ret    

0080088e <__x86.get_pc_thunk.cx>:
  80088e:	8b 0c 24             	mov    (%esp),%ecx
  800891:	c3                   	ret    

00800892 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800892:	55                   	push   %ebp
  800893:	89 e5                	mov    %esp,%ebp
  800895:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800898:	b8 00 00 00 00       	mov    $0x0,%eax
  80089d:	eb 03                	jmp    8008a2 <strlen+0x10>
		n++;
  80089f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008a2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a6:	75 f7                	jne    80089f <strlen+0xd>
	return n;
}
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b8:	eb 03                	jmp    8008bd <strnlen+0x13>
		n++;
  8008ba:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008bd:	39 d0                	cmp    %edx,%eax
  8008bf:	74 08                	je     8008c9 <strnlen+0x1f>
  8008c1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008c5:	75 f3                	jne    8008ba <strnlen+0x10>
  8008c7:	89 c2                	mov    %eax,%edx
	return n;
}
  8008c9:	89 d0                	mov    %edx,%eax
  8008cb:	5d                   	pop    %ebp
  8008cc:	c3                   	ret    

008008cd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	53                   	push   %ebx
  8008d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008dc:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008e0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008e3:	83 c0 01             	add    $0x1,%eax
  8008e6:	84 d2                	test   %dl,%dl
  8008e8:	75 f2                	jne    8008dc <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008ea:	89 c8                	mov    %ecx,%eax
  8008ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ef:	c9                   	leave  
  8008f0:	c3                   	ret    

008008f1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	53                   	push   %ebx
  8008f5:	83 ec 10             	sub    $0x10,%esp
  8008f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008fb:	53                   	push   %ebx
  8008fc:	e8 91 ff ff ff       	call   800892 <strlen>
  800901:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800904:	ff 75 0c             	push   0xc(%ebp)
  800907:	01 d8                	add    %ebx,%eax
  800909:	50                   	push   %eax
  80090a:	e8 be ff ff ff       	call   8008cd <strcpy>
	return dst;
}
  80090f:	89 d8                	mov    %ebx,%eax
  800911:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800914:	c9                   	leave  
  800915:	c3                   	ret    

00800916 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
  80091b:	8b 75 08             	mov    0x8(%ebp),%esi
  80091e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800921:	89 f3                	mov    %esi,%ebx
  800923:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800926:	89 f0                	mov    %esi,%eax
  800928:	eb 0f                	jmp    800939 <strncpy+0x23>
		*dst++ = *src;
  80092a:	83 c0 01             	add    $0x1,%eax
  80092d:	0f b6 0a             	movzbl (%edx),%ecx
  800930:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800933:	80 f9 01             	cmp    $0x1,%cl
  800936:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800939:	39 d8                	cmp    %ebx,%eax
  80093b:	75 ed                	jne    80092a <strncpy+0x14>
	}
	return ret;
}
  80093d:	89 f0                	mov    %esi,%eax
  80093f:	5b                   	pop    %ebx
  800940:	5e                   	pop    %esi
  800941:	5d                   	pop    %ebp
  800942:	c3                   	ret    

00800943 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	56                   	push   %esi
  800947:	53                   	push   %ebx
  800948:	8b 75 08             	mov    0x8(%ebp),%esi
  80094b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094e:	8b 55 10             	mov    0x10(%ebp),%edx
  800951:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800953:	85 d2                	test   %edx,%edx
  800955:	74 21                	je     800978 <strlcpy+0x35>
  800957:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80095b:	89 f2                	mov    %esi,%edx
  80095d:	eb 09                	jmp    800968 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80095f:	83 c1 01             	add    $0x1,%ecx
  800962:	83 c2 01             	add    $0x1,%edx
  800965:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800968:	39 c2                	cmp    %eax,%edx
  80096a:	74 09                	je     800975 <strlcpy+0x32>
  80096c:	0f b6 19             	movzbl (%ecx),%ebx
  80096f:	84 db                	test   %bl,%bl
  800971:	75 ec                	jne    80095f <strlcpy+0x1c>
  800973:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800975:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800978:	29 f0                	sub    %esi,%eax
}
  80097a:	5b                   	pop    %ebx
  80097b:	5e                   	pop    %esi
  80097c:	5d                   	pop    %ebp
  80097d:	c3                   	ret    

0080097e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80097e:	55                   	push   %ebp
  80097f:	89 e5                	mov    %esp,%ebp
  800981:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800984:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800987:	eb 06                	jmp    80098f <strcmp+0x11>
		p++, q++;
  800989:	83 c1 01             	add    $0x1,%ecx
  80098c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80098f:	0f b6 01             	movzbl (%ecx),%eax
  800992:	84 c0                	test   %al,%al
  800994:	74 04                	je     80099a <strcmp+0x1c>
  800996:	3a 02                	cmp    (%edx),%al
  800998:	74 ef                	je     800989 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80099a:	0f b6 c0             	movzbl %al,%eax
  80099d:	0f b6 12             	movzbl (%edx),%edx
  8009a0:	29 d0                	sub    %edx,%eax
}
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	53                   	push   %ebx
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ae:	89 c3                	mov    %eax,%ebx
  8009b0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009b3:	eb 06                	jmp    8009bb <strncmp+0x17>
		n--, p++, q++;
  8009b5:	83 c0 01             	add    $0x1,%eax
  8009b8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009bb:	39 d8                	cmp    %ebx,%eax
  8009bd:	74 18                	je     8009d7 <strncmp+0x33>
  8009bf:	0f b6 08             	movzbl (%eax),%ecx
  8009c2:	84 c9                	test   %cl,%cl
  8009c4:	74 04                	je     8009ca <strncmp+0x26>
  8009c6:	3a 0a                	cmp    (%edx),%cl
  8009c8:	74 eb                	je     8009b5 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ca:	0f b6 00             	movzbl (%eax),%eax
  8009cd:	0f b6 12             	movzbl (%edx),%edx
  8009d0:	29 d0                	sub    %edx,%eax
}
  8009d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d5:	c9                   	leave  
  8009d6:	c3                   	ret    
		return 0;
  8009d7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009dc:	eb f4                	jmp    8009d2 <strncmp+0x2e>

008009de <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e8:	eb 03                	jmp    8009ed <strchr+0xf>
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	0f b6 10             	movzbl (%eax),%edx
  8009f0:	84 d2                	test   %dl,%dl
  8009f2:	74 06                	je     8009fa <strchr+0x1c>
		if (*s == c)
  8009f4:	38 ca                	cmp    %cl,%dl
  8009f6:	75 f2                	jne    8009ea <strchr+0xc>
  8009f8:	eb 05                	jmp    8009ff <strchr+0x21>
			return (char *) s;
	return 0;
  8009fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ff:	5d                   	pop    %ebp
  800a00:	c3                   	ret    

00800a01 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	8b 45 08             	mov    0x8(%ebp),%eax
  800a07:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a0b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a0e:	38 ca                	cmp    %cl,%dl
  800a10:	74 09                	je     800a1b <strfind+0x1a>
  800a12:	84 d2                	test   %dl,%dl
  800a14:	74 05                	je     800a1b <strfind+0x1a>
	for (; *s; s++)
  800a16:	83 c0 01             	add    $0x1,%eax
  800a19:	eb f0                	jmp    800a0b <strfind+0xa>
			break;
	return (char *) s;
}
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	57                   	push   %edi
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a26:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a29:	85 c9                	test   %ecx,%ecx
  800a2b:	74 2f                	je     800a5c <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a2d:	89 f8                	mov    %edi,%eax
  800a2f:	09 c8                	or     %ecx,%eax
  800a31:	a8 03                	test   $0x3,%al
  800a33:	75 21                	jne    800a56 <memset+0x39>
		c &= 0xFF;
  800a35:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a39:	89 d0                	mov    %edx,%eax
  800a3b:	c1 e0 08             	shl    $0x8,%eax
  800a3e:	89 d3                	mov    %edx,%ebx
  800a40:	c1 e3 18             	shl    $0x18,%ebx
  800a43:	89 d6                	mov    %edx,%esi
  800a45:	c1 e6 10             	shl    $0x10,%esi
  800a48:	09 f3                	or     %esi,%ebx
  800a4a:	09 da                	or     %ebx,%edx
  800a4c:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a4e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a51:	fc                   	cld    
  800a52:	f3 ab                	rep stos %eax,%es:(%edi)
  800a54:	eb 06                	jmp    800a5c <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a59:	fc                   	cld    
  800a5a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a5c:	89 f8                	mov    %edi,%eax
  800a5e:	5b                   	pop    %ebx
  800a5f:	5e                   	pop    %esi
  800a60:	5f                   	pop    %edi
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	57                   	push   %edi
  800a67:	56                   	push   %esi
  800a68:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a71:	39 c6                	cmp    %eax,%esi
  800a73:	73 32                	jae    800aa7 <memmove+0x44>
  800a75:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a78:	39 c2                	cmp    %eax,%edx
  800a7a:	76 2b                	jbe    800aa7 <memmove+0x44>
		s += n;
		d += n;
  800a7c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7f:	89 d6                	mov    %edx,%esi
  800a81:	09 fe                	or     %edi,%esi
  800a83:	09 ce                	or     %ecx,%esi
  800a85:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a8b:	75 0e                	jne    800a9b <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a8d:	83 ef 04             	sub    $0x4,%edi
  800a90:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a93:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a96:	fd                   	std    
  800a97:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a99:	eb 09                	jmp    800aa4 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a9b:	83 ef 01             	sub    $0x1,%edi
  800a9e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aa1:	fd                   	std    
  800aa2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa4:	fc                   	cld    
  800aa5:	eb 1a                	jmp    800ac1 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa7:	89 f2                	mov    %esi,%edx
  800aa9:	09 c2                	or     %eax,%edx
  800aab:	09 ca                	or     %ecx,%edx
  800aad:	f6 c2 03             	test   $0x3,%dl
  800ab0:	75 0a                	jne    800abc <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ab2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ab5:	89 c7                	mov    %eax,%edi
  800ab7:	fc                   	cld    
  800ab8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aba:	eb 05                	jmp    800ac1 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800abc:	89 c7                	mov    %eax,%edi
  800abe:	fc                   	cld    
  800abf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac1:	5e                   	pop    %esi
  800ac2:	5f                   	pop    %edi
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800acb:	ff 75 10             	push   0x10(%ebp)
  800ace:	ff 75 0c             	push   0xc(%ebp)
  800ad1:	ff 75 08             	push   0x8(%ebp)
  800ad4:	e8 8a ff ff ff       	call   800a63 <memmove>
}
  800ad9:	c9                   	leave  
  800ada:	c3                   	ret    

00800adb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	56                   	push   %esi
  800adf:	53                   	push   %ebx
  800ae0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae6:	89 c6                	mov    %eax,%esi
  800ae8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aeb:	eb 06                	jmp    800af3 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800aed:	83 c0 01             	add    $0x1,%eax
  800af0:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800af3:	39 f0                	cmp    %esi,%eax
  800af5:	74 14                	je     800b0b <memcmp+0x30>
		if (*s1 != *s2)
  800af7:	0f b6 08             	movzbl (%eax),%ecx
  800afa:	0f b6 1a             	movzbl (%edx),%ebx
  800afd:	38 d9                	cmp    %bl,%cl
  800aff:	74 ec                	je     800aed <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b01:	0f b6 c1             	movzbl %cl,%eax
  800b04:	0f b6 db             	movzbl %bl,%ebx
  800b07:	29 d8                	sub    %ebx,%eax
  800b09:	eb 05                	jmp    800b10 <memcmp+0x35>
	}

	return 0;
  800b0b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b10:	5b                   	pop    %ebx
  800b11:	5e                   	pop    %esi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b1d:	89 c2                	mov    %eax,%edx
  800b1f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b22:	eb 03                	jmp    800b27 <memfind+0x13>
  800b24:	83 c0 01             	add    $0x1,%eax
  800b27:	39 d0                	cmp    %edx,%eax
  800b29:	73 04                	jae    800b2f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b2b:	38 08                	cmp    %cl,(%eax)
  800b2d:	75 f5                	jne    800b24 <memfind+0x10>
			break;
	return (void *) s;
}
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	57                   	push   %edi
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
  800b37:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b3d:	eb 03                	jmp    800b42 <strtol+0x11>
		s++;
  800b3f:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b42:	0f b6 02             	movzbl (%edx),%eax
  800b45:	3c 20                	cmp    $0x20,%al
  800b47:	74 f6                	je     800b3f <strtol+0xe>
  800b49:	3c 09                	cmp    $0x9,%al
  800b4b:	74 f2                	je     800b3f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b4d:	3c 2b                	cmp    $0x2b,%al
  800b4f:	74 2a                	je     800b7b <strtol+0x4a>
	int neg = 0;
  800b51:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b56:	3c 2d                	cmp    $0x2d,%al
  800b58:	74 2b                	je     800b85 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b5a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b60:	75 0f                	jne    800b71 <strtol+0x40>
  800b62:	80 3a 30             	cmpb   $0x30,(%edx)
  800b65:	74 28                	je     800b8f <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b67:	85 db                	test   %ebx,%ebx
  800b69:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b6e:	0f 44 d8             	cmove  %eax,%ebx
  800b71:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b76:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b79:	eb 46                	jmp    800bc1 <strtol+0x90>
		s++;
  800b7b:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b7e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b83:	eb d5                	jmp    800b5a <strtol+0x29>
		s++, neg = 1;
  800b85:	83 c2 01             	add    $0x1,%edx
  800b88:	bf 01 00 00 00       	mov    $0x1,%edi
  800b8d:	eb cb                	jmp    800b5a <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b8f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b93:	74 0e                	je     800ba3 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b95:	85 db                	test   %ebx,%ebx
  800b97:	75 d8                	jne    800b71 <strtol+0x40>
		s++, base = 8;
  800b99:	83 c2 01             	add    $0x1,%edx
  800b9c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ba1:	eb ce                	jmp    800b71 <strtol+0x40>
		s += 2, base = 16;
  800ba3:	83 c2 02             	add    $0x2,%edx
  800ba6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bab:	eb c4                	jmp    800b71 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bad:	0f be c0             	movsbl %al,%eax
  800bb0:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bb3:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bb6:	7d 3a                	jge    800bf2 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bb8:	83 c2 01             	add    $0x1,%edx
  800bbb:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bbf:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800bc1:	0f b6 02             	movzbl (%edx),%eax
  800bc4:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bc7:	89 f3                	mov    %esi,%ebx
  800bc9:	80 fb 09             	cmp    $0x9,%bl
  800bcc:	76 df                	jbe    800bad <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bce:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bd1:	89 f3                	mov    %esi,%ebx
  800bd3:	80 fb 19             	cmp    $0x19,%bl
  800bd6:	77 08                	ja     800be0 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bd8:	0f be c0             	movsbl %al,%eax
  800bdb:	83 e8 57             	sub    $0x57,%eax
  800bde:	eb d3                	jmp    800bb3 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800be0:	8d 70 bf             	lea    -0x41(%eax),%esi
  800be3:	89 f3                	mov    %esi,%ebx
  800be5:	80 fb 19             	cmp    $0x19,%bl
  800be8:	77 08                	ja     800bf2 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bea:	0f be c0             	movsbl %al,%eax
  800bed:	83 e8 37             	sub    $0x37,%eax
  800bf0:	eb c1                	jmp    800bb3 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bf2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf6:	74 05                	je     800bfd <strtol+0xcc>
		*endptr = (char *) s;
  800bf8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfb:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800bfd:	89 c8                	mov    %ecx,%eax
  800bff:	f7 d8                	neg    %eax
  800c01:	85 ff                	test   %edi,%edi
  800c03:	0f 45 c8             	cmovne %eax,%ecx
}
  800c06:	89 c8                	mov    %ecx,%eax
  800c08:	5b                   	pop    %ebx
  800c09:	5e                   	pop    %esi
  800c0a:	5f                   	pop    %edi
  800c0b:	5d                   	pop    %ebp
  800c0c:	c3                   	ret    
  800c0d:	66 90                	xchg   %ax,%ax
  800c0f:	90                   	nop

00800c10 <__udivdi3>:
  800c10:	f3 0f 1e fb          	endbr32 
  800c14:	55                   	push   %ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	83 ec 1c             	sub    $0x1c,%esp
  800c1b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c1f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c23:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c27:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c2b:	85 c0                	test   %eax,%eax
  800c2d:	75 19                	jne    800c48 <__udivdi3+0x38>
  800c2f:	39 f3                	cmp    %esi,%ebx
  800c31:	76 4d                	jbe    800c80 <__udivdi3+0x70>
  800c33:	31 ff                	xor    %edi,%edi
  800c35:	89 e8                	mov    %ebp,%eax
  800c37:	89 f2                	mov    %esi,%edx
  800c39:	f7 f3                	div    %ebx
  800c3b:	89 fa                	mov    %edi,%edx
  800c3d:	83 c4 1c             	add    $0x1c,%esp
  800c40:	5b                   	pop    %ebx
  800c41:	5e                   	pop    %esi
  800c42:	5f                   	pop    %edi
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    
  800c45:	8d 76 00             	lea    0x0(%esi),%esi
  800c48:	39 f0                	cmp    %esi,%eax
  800c4a:	76 14                	jbe    800c60 <__udivdi3+0x50>
  800c4c:	31 ff                	xor    %edi,%edi
  800c4e:	31 c0                	xor    %eax,%eax
  800c50:	89 fa                	mov    %edi,%edx
  800c52:	83 c4 1c             	add    $0x1c,%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    
  800c5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c60:	0f bd f8             	bsr    %eax,%edi
  800c63:	83 f7 1f             	xor    $0x1f,%edi
  800c66:	75 48                	jne    800cb0 <__udivdi3+0xa0>
  800c68:	39 f0                	cmp    %esi,%eax
  800c6a:	72 06                	jb     800c72 <__udivdi3+0x62>
  800c6c:	31 c0                	xor    %eax,%eax
  800c6e:	39 eb                	cmp    %ebp,%ebx
  800c70:	77 de                	ja     800c50 <__udivdi3+0x40>
  800c72:	b8 01 00 00 00       	mov    $0x1,%eax
  800c77:	eb d7                	jmp    800c50 <__udivdi3+0x40>
  800c79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c80:	89 d9                	mov    %ebx,%ecx
  800c82:	85 db                	test   %ebx,%ebx
  800c84:	75 0b                	jne    800c91 <__udivdi3+0x81>
  800c86:	b8 01 00 00 00       	mov    $0x1,%eax
  800c8b:	31 d2                	xor    %edx,%edx
  800c8d:	f7 f3                	div    %ebx
  800c8f:	89 c1                	mov    %eax,%ecx
  800c91:	31 d2                	xor    %edx,%edx
  800c93:	89 f0                	mov    %esi,%eax
  800c95:	f7 f1                	div    %ecx
  800c97:	89 c6                	mov    %eax,%esi
  800c99:	89 e8                	mov    %ebp,%eax
  800c9b:	89 f7                	mov    %esi,%edi
  800c9d:	f7 f1                	div    %ecx
  800c9f:	89 fa                	mov    %edi,%edx
  800ca1:	83 c4 1c             	add    $0x1c,%esp
  800ca4:	5b                   	pop    %ebx
  800ca5:	5e                   	pop    %esi
  800ca6:	5f                   	pop    %edi
  800ca7:	5d                   	pop    %ebp
  800ca8:	c3                   	ret    
  800ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cb0:	89 f9                	mov    %edi,%ecx
  800cb2:	ba 20 00 00 00       	mov    $0x20,%edx
  800cb7:	29 fa                	sub    %edi,%edx
  800cb9:	d3 e0                	shl    %cl,%eax
  800cbb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cbf:	89 d1                	mov    %edx,%ecx
  800cc1:	89 d8                	mov    %ebx,%eax
  800cc3:	d3 e8                	shr    %cl,%eax
  800cc5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cc9:	09 c1                	or     %eax,%ecx
  800ccb:	89 f0                	mov    %esi,%eax
  800ccd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cd1:	89 f9                	mov    %edi,%ecx
  800cd3:	d3 e3                	shl    %cl,%ebx
  800cd5:	89 d1                	mov    %edx,%ecx
  800cd7:	d3 e8                	shr    %cl,%eax
  800cd9:	89 f9                	mov    %edi,%ecx
  800cdb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cdf:	89 eb                	mov    %ebp,%ebx
  800ce1:	d3 e6                	shl    %cl,%esi
  800ce3:	89 d1                	mov    %edx,%ecx
  800ce5:	d3 eb                	shr    %cl,%ebx
  800ce7:	09 f3                	or     %esi,%ebx
  800ce9:	89 c6                	mov    %eax,%esi
  800ceb:	89 f2                	mov    %esi,%edx
  800ced:	89 d8                	mov    %ebx,%eax
  800cef:	f7 74 24 08          	divl   0x8(%esp)
  800cf3:	89 d6                	mov    %edx,%esi
  800cf5:	89 c3                	mov    %eax,%ebx
  800cf7:	f7 64 24 0c          	mull   0xc(%esp)
  800cfb:	39 d6                	cmp    %edx,%esi
  800cfd:	72 19                	jb     800d18 <__udivdi3+0x108>
  800cff:	89 f9                	mov    %edi,%ecx
  800d01:	d3 e5                	shl    %cl,%ebp
  800d03:	39 c5                	cmp    %eax,%ebp
  800d05:	73 04                	jae    800d0b <__udivdi3+0xfb>
  800d07:	39 d6                	cmp    %edx,%esi
  800d09:	74 0d                	je     800d18 <__udivdi3+0x108>
  800d0b:	89 d8                	mov    %ebx,%eax
  800d0d:	31 ff                	xor    %edi,%edi
  800d0f:	e9 3c ff ff ff       	jmp    800c50 <__udivdi3+0x40>
  800d14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d18:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d1b:	31 ff                	xor    %edi,%edi
  800d1d:	e9 2e ff ff ff       	jmp    800c50 <__udivdi3+0x40>
  800d22:	66 90                	xchg   %ax,%ax
  800d24:	66 90                	xchg   %ax,%ax
  800d26:	66 90                	xchg   %ax,%ax
  800d28:	66 90                	xchg   %ax,%ax
  800d2a:	66 90                	xchg   %ax,%ax
  800d2c:	66 90                	xchg   %ax,%ax
  800d2e:	66 90                	xchg   %ax,%ax

00800d30 <__umoddi3>:
  800d30:	f3 0f 1e fb          	endbr32 
  800d34:	55                   	push   %ebp
  800d35:	57                   	push   %edi
  800d36:	56                   	push   %esi
  800d37:	53                   	push   %ebx
  800d38:	83 ec 1c             	sub    $0x1c,%esp
  800d3b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d43:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800d47:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800d4b:	89 f0                	mov    %esi,%eax
  800d4d:	89 da                	mov    %ebx,%edx
  800d4f:	85 ff                	test   %edi,%edi
  800d51:	75 15                	jne    800d68 <__umoddi3+0x38>
  800d53:	39 dd                	cmp    %ebx,%ebp
  800d55:	76 39                	jbe    800d90 <__umoddi3+0x60>
  800d57:	f7 f5                	div    %ebp
  800d59:	89 d0                	mov    %edx,%eax
  800d5b:	31 d2                	xor    %edx,%edx
  800d5d:	83 c4 1c             	add    $0x1c,%esp
  800d60:	5b                   	pop    %ebx
  800d61:	5e                   	pop    %esi
  800d62:	5f                   	pop    %edi
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    
  800d65:	8d 76 00             	lea    0x0(%esi),%esi
  800d68:	39 df                	cmp    %ebx,%edi
  800d6a:	77 f1                	ja     800d5d <__umoddi3+0x2d>
  800d6c:	0f bd cf             	bsr    %edi,%ecx
  800d6f:	83 f1 1f             	xor    $0x1f,%ecx
  800d72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d76:	75 40                	jne    800db8 <__umoddi3+0x88>
  800d78:	39 df                	cmp    %ebx,%edi
  800d7a:	72 04                	jb     800d80 <__umoddi3+0x50>
  800d7c:	39 f5                	cmp    %esi,%ebp
  800d7e:	77 dd                	ja     800d5d <__umoddi3+0x2d>
  800d80:	89 da                	mov    %ebx,%edx
  800d82:	89 f0                	mov    %esi,%eax
  800d84:	29 e8                	sub    %ebp,%eax
  800d86:	19 fa                	sbb    %edi,%edx
  800d88:	eb d3                	jmp    800d5d <__umoddi3+0x2d>
  800d8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d90:	89 e9                	mov    %ebp,%ecx
  800d92:	85 ed                	test   %ebp,%ebp
  800d94:	75 0b                	jne    800da1 <__umoddi3+0x71>
  800d96:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9b:	31 d2                	xor    %edx,%edx
  800d9d:	f7 f5                	div    %ebp
  800d9f:	89 c1                	mov    %eax,%ecx
  800da1:	89 d8                	mov    %ebx,%eax
  800da3:	31 d2                	xor    %edx,%edx
  800da5:	f7 f1                	div    %ecx
  800da7:	89 f0                	mov    %esi,%eax
  800da9:	f7 f1                	div    %ecx
  800dab:	89 d0                	mov    %edx,%eax
  800dad:	31 d2                	xor    %edx,%edx
  800daf:	eb ac                	jmp    800d5d <__umoddi3+0x2d>
  800db1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800db8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dbc:	ba 20 00 00 00       	mov    $0x20,%edx
  800dc1:	29 c2                	sub    %eax,%edx
  800dc3:	89 c1                	mov    %eax,%ecx
  800dc5:	89 e8                	mov    %ebp,%eax
  800dc7:	d3 e7                	shl    %cl,%edi
  800dc9:	89 d1                	mov    %edx,%ecx
  800dcb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800dcf:	d3 e8                	shr    %cl,%eax
  800dd1:	89 c1                	mov    %eax,%ecx
  800dd3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dd7:	09 f9                	or     %edi,%ecx
  800dd9:	89 df                	mov    %ebx,%edi
  800ddb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ddf:	89 c1                	mov    %eax,%ecx
  800de1:	d3 e5                	shl    %cl,%ebp
  800de3:	89 d1                	mov    %edx,%ecx
  800de5:	d3 ef                	shr    %cl,%edi
  800de7:	89 c1                	mov    %eax,%ecx
  800de9:	89 f0                	mov    %esi,%eax
  800deb:	d3 e3                	shl    %cl,%ebx
  800ded:	89 d1                	mov    %edx,%ecx
  800def:	89 fa                	mov    %edi,%edx
  800df1:	d3 e8                	shr    %cl,%eax
  800df3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800df8:	09 d8                	or     %ebx,%eax
  800dfa:	f7 74 24 08          	divl   0x8(%esp)
  800dfe:	89 d3                	mov    %edx,%ebx
  800e00:	d3 e6                	shl    %cl,%esi
  800e02:	f7 e5                	mul    %ebp
  800e04:	89 c7                	mov    %eax,%edi
  800e06:	89 d1                	mov    %edx,%ecx
  800e08:	39 d3                	cmp    %edx,%ebx
  800e0a:	72 06                	jb     800e12 <__umoddi3+0xe2>
  800e0c:	75 0e                	jne    800e1c <__umoddi3+0xec>
  800e0e:	39 c6                	cmp    %eax,%esi
  800e10:	73 0a                	jae    800e1c <__umoddi3+0xec>
  800e12:	29 e8                	sub    %ebp,%eax
  800e14:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800e18:	89 d1                	mov    %edx,%ecx
  800e1a:	89 c7                	mov    %eax,%edi
  800e1c:	89 f5                	mov    %esi,%ebp
  800e1e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e22:	29 fd                	sub    %edi,%ebp
  800e24:	19 cb                	sbb    %ecx,%ebx
  800e26:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e2b:	89 d8                	mov    %ebx,%eax
  800e2d:	d3 e0                	shl    %cl,%eax
  800e2f:	89 f1                	mov    %esi,%ecx
  800e31:	d3 ed                	shr    %cl,%ebp
  800e33:	d3 eb                	shr    %cl,%ebx
  800e35:	09 e8                	or     %ebp,%eax
  800e37:	89 da                	mov    %ebx,%edx
  800e39:	83 c4 1c             	add    $0x1c,%esp
  800e3c:	5b                   	pop    %ebx
  800e3d:	5e                   	pop    %esi
  800e3e:	5f                   	pop    %edi
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    
