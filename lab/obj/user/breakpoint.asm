
obj/user/breakpoint：     文件格式 elf32-i386


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
  80002c:	e8 04 00 00 00       	call   800035 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	asm volatile("int $3");
  800033:	cc                   	int3   
}
  800034:	c3                   	ret    

00800035 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800035:	55                   	push   %ebp
  800036:	89 e5                	mov    %esp,%ebp
  800038:	53                   	push   %ebx
  800039:	83 ec 04             	sub    $0x4,%esp
  80003c:	e8 39 00 00 00       	call   80007a <__x86.get_pc_thunk.bx>
  800041:	81 c3 bf 1f 00 00    	add    $0x1fbf,%ebx
  800047:	8b 45 08             	mov    0x8(%ebp),%eax
  80004a:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004d:	c7 83 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
  800054:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800057:	85 c0                	test   %eax,%eax
  800059:	7e 08                	jle    800063 <libmain+0x2e>
		binaryname = argv[0];
  80005b:	8b 0a                	mov    (%edx),%ecx
  80005d:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	52                   	push   %edx
  800067:	50                   	push   %eax
  800068:	e8 c6 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80006d:	e8 0c 00 00 00       	call   80007e <exit>
}
  800072:	83 c4 10             	add    $0x10,%esp
  800075:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800078:	c9                   	leave  
  800079:	c3                   	ret    

0080007a <__x86.get_pc_thunk.bx>:
  80007a:	8b 1c 24             	mov    (%esp),%ebx
  80007d:	c3                   	ret    

0080007e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	53                   	push   %ebx
  800082:	83 ec 10             	sub    $0x10,%esp
  800085:	e8 f0 ff ff ff       	call   80007a <__x86.get_pc_thunk.bx>
  80008a:	81 c3 76 1f 00 00    	add    $0x1f76,%ebx
	sys_env_destroy(0);
  800090:	6a 00                	push   $0x0
  800092:	e8 45 00 00 00       	call   8000dc <sys_env_destroy>
}
  800097:	83 c4 10             	add    $0x10,%esp
  80009a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    

0080009f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009f:	55                   	push   %ebp
  8000a0:	89 e5                	mov    %esp,%ebp
  8000a2:	57                   	push   %edi
  8000a3:	56                   	push   %esi
  8000a4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	89 c3                	mov    %eax,%ebx
  8000b2:	89 c7                	mov    %eax,%edi
  8000b4:	89 c6                	mov    %eax,%esi
  8000b6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b8:	5b                   	pop    %ebx
  8000b9:	5e                   	pop    %esi
  8000ba:	5f                   	pop    %edi
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    

008000bd <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cd:	89 d1                	mov    %edx,%ecx
  8000cf:	89 d3                	mov    %edx,%ebx
  8000d1:	89 d7                	mov    %edx,%edi
  8000d3:	89 d6                	mov    %edx,%esi
  8000d5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5f                   	pop    %edi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	57                   	push   %edi
  8000e0:	56                   	push   %esi
  8000e1:	53                   	push   %ebx
  8000e2:	83 ec 1c             	sub    $0x1c,%esp
  8000e5:	e8 66 00 00 00       	call   800150 <__x86.get_pc_thunk.ax>
  8000ea:	05 16 1f 00 00       	add    $0x1f16,%eax
  8000ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7f 08                	jg     800113 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80011c:	8d 83 4e ee ff ff    	lea    -0x11b2(%ebx),%eax
  800122:	50                   	push   %eax
  800123:	6a 23                	push   $0x23
  800125:	8d 83 6b ee ff ff    	lea    -0x1195(%ebx),%eax
  80012b:	50                   	push   %eax
  80012c:	e8 23 00 00 00       	call   800154 <_panic>

00800131 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800131:	55                   	push   %ebp
  800132:	89 e5                	mov    %esp,%ebp
  800134:	57                   	push   %edi
  800135:	56                   	push   %esi
  800136:	53                   	push   %ebx
	asm volatile("int %1\n"
  800137:	ba 00 00 00 00       	mov    $0x0,%edx
  80013c:	b8 02 00 00 00       	mov    $0x2,%eax
  800141:	89 d1                	mov    %edx,%ecx
  800143:	89 d3                	mov    %edx,%ebx
  800145:	89 d7                	mov    %edx,%edi
  800147:	89 d6                	mov    %edx,%esi
  800149:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014b:	5b                   	pop    %ebx
  80014c:	5e                   	pop    %esi
  80014d:	5f                   	pop    %edi
  80014e:	5d                   	pop    %ebp
  80014f:	c3                   	ret    

00800150 <__x86.get_pc_thunk.ax>:
  800150:	8b 04 24             	mov    (%esp),%eax
  800153:	c3                   	ret    

00800154 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	57                   	push   %edi
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
  80015a:	83 ec 0c             	sub    $0xc,%esp
  80015d:	e8 18 ff ff ff       	call   80007a <__x86.get_pc_thunk.bx>
  800162:	81 c3 9e 1e 00 00    	add    $0x1e9e,%ebx
	va_list ap;

	va_start(ap, fmt);
  800168:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016b:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800171:	8b 38                	mov    (%eax),%edi
  800173:	e8 b9 ff ff ff       	call   800131 <sys_getenvid>
  800178:	83 ec 0c             	sub    $0xc,%esp
  80017b:	ff 75 0c             	push   0xc(%ebp)
  80017e:	ff 75 08             	push   0x8(%ebp)
  800181:	57                   	push   %edi
  800182:	50                   	push   %eax
  800183:	8d 83 7c ee ff ff    	lea    -0x1184(%ebx),%eax
  800189:	50                   	push   %eax
  80018a:	e8 d1 00 00 00       	call   800260 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80018f:	83 c4 18             	add    $0x18,%esp
  800192:	56                   	push   %esi
  800193:	ff 75 10             	push   0x10(%ebp)
  800196:	e8 63 00 00 00       	call   8001fe <vcprintf>
	cprintf("\n");
  80019b:	8d 83 9f ee ff ff    	lea    -0x1161(%ebx),%eax
  8001a1:	89 04 24             	mov    %eax,(%esp)
  8001a4:	e8 b7 00 00 00       	call   800260 <cprintf>
  8001a9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ac:	cc                   	int3   
  8001ad:	eb fd                	jmp    8001ac <_panic+0x58>

008001af <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	56                   	push   %esi
  8001b3:	53                   	push   %ebx
  8001b4:	e8 c1 fe ff ff       	call   80007a <__x86.get_pc_thunk.bx>
  8001b9:	81 c3 47 1e 00 00    	add    $0x1e47,%ebx
  8001bf:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001c2:	8b 16                	mov    (%esi),%edx
  8001c4:	8d 42 01             	lea    0x1(%edx),%eax
  8001c7:	89 06                	mov    %eax,(%esi)
  8001c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001cc:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001d0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d5:	74 0b                	je     8001e2 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001d7:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5d                   	pop    %ebp
  8001e1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001e2:	83 ec 08             	sub    $0x8,%esp
  8001e5:	68 ff 00 00 00       	push   $0xff
  8001ea:	8d 46 08             	lea    0x8(%esi),%eax
  8001ed:	50                   	push   %eax
  8001ee:	e8 ac fe ff ff       	call   80009f <sys_cputs>
		b->idx = 0;
  8001f3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	eb d9                	jmp    8001d7 <putch+0x28>

008001fe <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	53                   	push   %ebx
  800202:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800208:	e8 6d fe ff ff       	call   80007a <__x86.get_pc_thunk.bx>
  80020d:	81 c3 f3 1d 00 00    	add    $0x1df3,%ebx
	struct printbuf b;

	b.idx = 0;
  800213:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021a:	00 00 00 
	b.cnt = 0;
  80021d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800224:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800227:	ff 75 0c             	push   0xc(%ebp)
  80022a:	ff 75 08             	push   0x8(%ebp)
  80022d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800233:	50                   	push   %eax
  800234:	8d 83 af e1 ff ff    	lea    -0x1e51(%ebx),%eax
  80023a:	50                   	push   %eax
  80023b:	e8 2c 01 00 00       	call   80036c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800240:	83 c4 08             	add    $0x8,%esp
  800243:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800249:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80024f:	50                   	push   %eax
  800250:	e8 4a fe ff ff       	call   80009f <sys_cputs>

	return b.cnt;
}
  800255:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80025b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80025e:	c9                   	leave  
  80025f:	c3                   	ret    

00800260 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800266:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800269:	50                   	push   %eax
  80026a:	ff 75 08             	push   0x8(%ebp)
  80026d:	e8 8c ff ff ff       	call   8001fe <vcprintf>
	va_end(ap);

	return cnt;
}
  800272:	c9                   	leave  
  800273:	c3                   	ret    

00800274 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	57                   	push   %edi
  800278:	56                   	push   %esi
  800279:	53                   	push   %ebx
  80027a:	83 ec 2c             	sub    $0x2c,%esp
  80027d:	e8 07 06 00 00       	call   800889 <__x86.get_pc_thunk.cx>
  800282:	81 c1 7e 1d 00 00    	add    $0x1d7e,%ecx
  800288:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80028b:	89 c7                	mov    %eax,%edi
  80028d:	89 d6                	mov    %edx,%esi
  80028f:	8b 45 08             	mov    0x8(%ebp),%eax
  800292:	8b 55 0c             	mov    0xc(%ebp),%edx
  800295:	89 d1                	mov    %edx,%ecx
  800297:	89 c2                	mov    %eax,%edx
  800299:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80029c:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  80029f:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002af:	39 c2                	cmp    %eax,%edx
  8002b1:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002b4:	72 41                	jb     8002f7 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b6:	83 ec 0c             	sub    $0xc,%esp
  8002b9:	ff 75 18             	push   0x18(%ebp)
  8002bc:	83 eb 01             	sub    $0x1,%ebx
  8002bf:	53                   	push   %ebx
  8002c0:	50                   	push   %eax
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	ff 75 e4             	push   -0x1c(%ebp)
  8002c7:	ff 75 e0             	push   -0x20(%ebp)
  8002ca:	ff 75 d4             	push   -0x2c(%ebp)
  8002cd:	ff 75 d0             	push   -0x30(%ebp)
  8002d0:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002d3:	e8 38 09 00 00       	call   800c10 <__udivdi3>
  8002d8:	83 c4 18             	add    $0x18,%esp
  8002db:	52                   	push   %edx
  8002dc:	50                   	push   %eax
  8002dd:	89 f2                	mov    %esi,%edx
  8002df:	89 f8                	mov    %edi,%eax
  8002e1:	e8 8e ff ff ff       	call   800274 <printnum>
  8002e6:	83 c4 20             	add    $0x20,%esp
  8002e9:	eb 13                	jmp    8002fe <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002eb:	83 ec 08             	sub    $0x8,%esp
  8002ee:	56                   	push   %esi
  8002ef:	ff 75 18             	push   0x18(%ebp)
  8002f2:	ff d7                	call   *%edi
  8002f4:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002f7:	83 eb 01             	sub    $0x1,%ebx
  8002fa:	85 db                	test   %ebx,%ebx
  8002fc:	7f ed                	jg     8002eb <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002fe:	83 ec 08             	sub    $0x8,%esp
  800301:	56                   	push   %esi
  800302:	83 ec 04             	sub    $0x4,%esp
  800305:	ff 75 e4             	push   -0x1c(%ebp)
  800308:	ff 75 e0             	push   -0x20(%ebp)
  80030b:	ff 75 d4             	push   -0x2c(%ebp)
  80030e:	ff 75 d0             	push   -0x30(%ebp)
  800311:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800314:	e8 17 0a 00 00       	call   800d30 <__umoddi3>
  800319:	83 c4 14             	add    $0x14,%esp
  80031c:	0f be 84 03 a1 ee ff 	movsbl -0x115f(%ebx,%eax,1),%eax
  800323:	ff 
  800324:	50                   	push   %eax
  800325:	ff d7                	call   *%edi
}
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032d:	5b                   	pop    %ebx
  80032e:	5e                   	pop    %esi
  80032f:	5f                   	pop    %edi
  800330:	5d                   	pop    %ebp
  800331:	c3                   	ret    

00800332 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800332:	55                   	push   %ebp
  800333:	89 e5                	mov    %esp,%ebp
  800335:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800338:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033c:	8b 10                	mov    (%eax),%edx
  80033e:	3b 50 04             	cmp    0x4(%eax),%edx
  800341:	73 0a                	jae    80034d <sprintputch+0x1b>
		*b->buf++ = ch;
  800343:	8d 4a 01             	lea    0x1(%edx),%ecx
  800346:	89 08                	mov    %ecx,(%eax)
  800348:	8b 45 08             	mov    0x8(%ebp),%eax
  80034b:	88 02                	mov    %al,(%edx)
}
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <printfmt>:
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
  800352:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800355:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800358:	50                   	push   %eax
  800359:	ff 75 10             	push   0x10(%ebp)
  80035c:	ff 75 0c             	push   0xc(%ebp)
  80035f:	ff 75 08             	push   0x8(%ebp)
  800362:	e8 05 00 00 00       	call   80036c <vprintfmt>
}
  800367:	83 c4 10             	add    $0x10,%esp
  80036a:	c9                   	leave  
  80036b:	c3                   	ret    

0080036c <vprintfmt>:
{
  80036c:	55                   	push   %ebp
  80036d:	89 e5                	mov    %esp,%ebp
  80036f:	57                   	push   %edi
  800370:	56                   	push   %esi
  800371:	53                   	push   %ebx
  800372:	83 ec 3c             	sub    $0x3c,%esp
  800375:	e8 d6 fd ff ff       	call   800150 <__x86.get_pc_thunk.ax>
  80037a:	05 86 1c 00 00       	add    $0x1c86,%eax
  80037f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800382:	8b 75 08             	mov    0x8(%ebp),%esi
  800385:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800388:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80038b:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  800391:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800394:	eb 0a                	jmp    8003a0 <vprintfmt+0x34>
			putch(ch, putdat);
  800396:	83 ec 08             	sub    $0x8,%esp
  800399:	57                   	push   %edi
  80039a:	50                   	push   %eax
  80039b:	ff d6                	call   *%esi
  80039d:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a0:	83 c3 01             	add    $0x1,%ebx
  8003a3:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003a7:	83 f8 25             	cmp    $0x25,%eax
  8003aa:	74 0c                	je     8003b8 <vprintfmt+0x4c>
			if (ch == '\0')
  8003ac:	85 c0                	test   %eax,%eax
  8003ae:	75 e6                	jne    800396 <vprintfmt+0x2a>
}
  8003b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b3:	5b                   	pop    %ebx
  8003b4:	5e                   	pop    %esi
  8003b5:	5f                   	pop    %edi
  8003b6:	5d                   	pop    %ebp
  8003b7:	c3                   	ret    
		padc = ' ';
  8003b8:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003bc:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  8003c3:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003ca:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  8003d1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003d9:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003dc:	8d 43 01             	lea    0x1(%ebx),%eax
  8003df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e2:	0f b6 13             	movzbl (%ebx),%edx
  8003e5:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003e8:	3c 55                	cmp    $0x55,%al
  8003ea:	0f 87 fd 03 00 00    	ja     8007ed <.L20>
  8003f0:	0f b6 c0             	movzbl %al,%eax
  8003f3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003f6:	89 ce                	mov    %ecx,%esi
  8003f8:	03 b4 81 30 ef ff ff 	add    -0x10d0(%ecx,%eax,4),%esi
  8003ff:	ff e6                	jmp    *%esi

00800401 <.L68>:
  800401:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800404:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800408:	eb d2                	jmp    8003dc <vprintfmt+0x70>

0080040a <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80040d:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800411:	eb c9                	jmp    8003dc <vprintfmt+0x70>

00800413 <.L31>:
  800413:	0f b6 d2             	movzbl %dl,%edx
  800416:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800419:	b8 00 00 00 00       	mov    $0x0,%eax
  80041e:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800421:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800424:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800428:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80042b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80042e:	83 f9 09             	cmp    $0x9,%ecx
  800431:	77 58                	ja     80048b <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800433:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800436:	eb e9                	jmp    800421 <.L31+0xe>

00800438 <.L34>:
			precision = va_arg(ap, int);
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8b 00                	mov    (%eax),%eax
  80043d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800440:	8b 45 14             	mov    0x14(%ebp),%eax
  800443:	8d 40 04             	lea    0x4(%eax),%eax
  800446:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80044c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800450:	79 8a                	jns    8003dc <vprintfmt+0x70>
				width = precision, precision = -1;
  800452:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800455:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800458:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80045f:	e9 78 ff ff ff       	jmp    8003dc <vprintfmt+0x70>

00800464 <.L33>:
  800464:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800467:	85 d2                	test   %edx,%edx
  800469:	b8 00 00 00 00       	mov    $0x0,%eax
  80046e:	0f 49 c2             	cmovns %edx,%eax
  800471:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800474:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800477:	e9 60 ff ff ff       	jmp    8003dc <vprintfmt+0x70>

0080047c <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  80047c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  80047f:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800486:	e9 51 ff ff ff       	jmp    8003dc <vprintfmt+0x70>
  80048b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80048e:	89 75 08             	mov    %esi,0x8(%ebp)
  800491:	eb b9                	jmp    80044c <.L34+0x14>

00800493 <.L27>:
			lflag++;
  800493:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800497:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  80049a:	e9 3d ff ff ff       	jmp    8003dc <vprintfmt+0x70>

0080049f <.L30>:
			putch(va_arg(ap, int), putdat);
  80049f:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a5:	8d 58 04             	lea    0x4(%eax),%ebx
  8004a8:	83 ec 08             	sub    $0x8,%esp
  8004ab:	57                   	push   %edi
  8004ac:	ff 30                	push   (%eax)
  8004ae:	ff d6                	call   *%esi
			break;
  8004b0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004b3:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004b6:	e9 c8 02 00 00       	jmp    800783 <.L25+0x45>

008004bb <.L28>:
			err = va_arg(ap, int);
  8004bb:	8b 75 08             	mov    0x8(%ebp),%esi
  8004be:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c1:	8d 58 04             	lea    0x4(%eax),%ebx
  8004c4:	8b 10                	mov    (%eax),%edx
  8004c6:	89 d0                	mov    %edx,%eax
  8004c8:	f7 d8                	neg    %eax
  8004ca:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004cd:	83 f8 06             	cmp    $0x6,%eax
  8004d0:	7f 27                	jg     8004f9 <.L28+0x3e>
  8004d2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004d5:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004d8:	85 d2                	test   %edx,%edx
  8004da:	74 1d                	je     8004f9 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8004dc:	52                   	push   %edx
  8004dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e0:	8d 80 c2 ee ff ff    	lea    -0x113e(%eax),%eax
  8004e6:	50                   	push   %eax
  8004e7:	57                   	push   %edi
  8004e8:	56                   	push   %esi
  8004e9:	e8 61 fe ff ff       	call   80034f <printfmt>
  8004ee:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004f1:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004f4:	e9 8a 02 00 00       	jmp    800783 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004f9:	50                   	push   %eax
  8004fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004fd:	8d 80 b9 ee ff ff    	lea    -0x1147(%eax),%eax
  800503:	50                   	push   %eax
  800504:	57                   	push   %edi
  800505:	56                   	push   %esi
  800506:	e8 44 fe ff ff       	call   80034f <printfmt>
  80050b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80050e:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800511:	e9 6d 02 00 00       	jmp    800783 <.L25+0x45>

00800516 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800516:	8b 75 08             	mov    0x8(%ebp),%esi
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	83 c0 04             	add    $0x4,%eax
  80051f:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800527:	85 d2                	test   %edx,%edx
  800529:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052c:	8d 80 b2 ee ff ff    	lea    -0x114e(%eax),%eax
  800532:	0f 45 c2             	cmovne %edx,%eax
  800535:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800538:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80053c:	7e 06                	jle    800544 <.L24+0x2e>
  80053e:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800542:	75 0d                	jne    800551 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800544:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800547:	89 c3                	mov    %eax,%ebx
  800549:	03 45 d4             	add    -0x2c(%ebp),%eax
  80054c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  80054f:	eb 58                	jmp    8005a9 <.L24+0x93>
  800551:	83 ec 08             	sub    $0x8,%esp
  800554:	ff 75 d8             	push   -0x28(%ebp)
  800557:	ff 75 c8             	push   -0x38(%ebp)
  80055a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055d:	e8 43 03 00 00       	call   8008a5 <strnlen>
  800562:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800565:	29 c2                	sub    %eax,%edx
  800567:	89 55 bc             	mov    %edx,-0x44(%ebp)
  80056a:	83 c4 10             	add    $0x10,%esp
  80056d:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  80056f:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800573:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800576:	eb 0f                	jmp    800587 <.L24+0x71>
					putch(padc, putdat);
  800578:	83 ec 08             	sub    $0x8,%esp
  80057b:	57                   	push   %edi
  80057c:	ff 75 d4             	push   -0x2c(%ebp)
  80057f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800581:	83 eb 01             	sub    $0x1,%ebx
  800584:	83 c4 10             	add    $0x10,%esp
  800587:	85 db                	test   %ebx,%ebx
  800589:	7f ed                	jg     800578 <.L24+0x62>
  80058b:	8b 55 bc             	mov    -0x44(%ebp),%edx
  80058e:	85 d2                	test   %edx,%edx
  800590:	b8 00 00 00 00       	mov    $0x0,%eax
  800595:	0f 49 c2             	cmovns %edx,%eax
  800598:	29 c2                	sub    %eax,%edx
  80059a:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80059d:	eb a5                	jmp    800544 <.L24+0x2e>
					putch(ch, putdat);
  80059f:	83 ec 08             	sub    $0x8,%esp
  8005a2:	57                   	push   %edi
  8005a3:	52                   	push   %edx
  8005a4:	ff d6                	call   *%esi
  8005a6:	83 c4 10             	add    $0x10,%esp
  8005a9:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005ac:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ae:	83 c3 01             	add    $0x1,%ebx
  8005b1:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005b5:	0f be d0             	movsbl %al,%edx
  8005b8:	85 d2                	test   %edx,%edx
  8005ba:	74 4b                	je     800607 <.L24+0xf1>
  8005bc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c0:	78 06                	js     8005c8 <.L24+0xb2>
  8005c2:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005c6:	78 1e                	js     8005e6 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005c8:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005cc:	74 d1                	je     80059f <.L24+0x89>
  8005ce:	0f be c0             	movsbl %al,%eax
  8005d1:	83 e8 20             	sub    $0x20,%eax
  8005d4:	83 f8 5e             	cmp    $0x5e,%eax
  8005d7:	76 c6                	jbe    80059f <.L24+0x89>
					putch('?', putdat);
  8005d9:	83 ec 08             	sub    $0x8,%esp
  8005dc:	57                   	push   %edi
  8005dd:	6a 3f                	push   $0x3f
  8005df:	ff d6                	call   *%esi
  8005e1:	83 c4 10             	add    $0x10,%esp
  8005e4:	eb c3                	jmp    8005a9 <.L24+0x93>
  8005e6:	89 cb                	mov    %ecx,%ebx
  8005e8:	eb 0e                	jmp    8005f8 <.L24+0xe2>
				putch(' ', putdat);
  8005ea:	83 ec 08             	sub    $0x8,%esp
  8005ed:	57                   	push   %edi
  8005ee:	6a 20                	push   $0x20
  8005f0:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005f2:	83 eb 01             	sub    $0x1,%ebx
  8005f5:	83 c4 10             	add    $0x10,%esp
  8005f8:	85 db                	test   %ebx,%ebx
  8005fa:	7f ee                	jg     8005ea <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  8005fc:	8b 45 c0             	mov    -0x40(%ebp),%eax
  8005ff:	89 45 14             	mov    %eax,0x14(%ebp)
  800602:	e9 7c 01 00 00       	jmp    800783 <.L25+0x45>
  800607:	89 cb                	mov    %ecx,%ebx
  800609:	eb ed                	jmp    8005f8 <.L24+0xe2>

0080060b <.L29>:
	if (lflag >= 2)
  80060b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80060e:	8b 75 08             	mov    0x8(%ebp),%esi
  800611:	83 f9 01             	cmp    $0x1,%ecx
  800614:	7f 1b                	jg     800631 <.L29+0x26>
	else if (lflag)
  800616:	85 c9                	test   %ecx,%ecx
  800618:	74 63                	je     80067d <.L29+0x72>
		return va_arg(*ap, long);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8b 00                	mov    (%eax),%eax
  80061f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800622:	99                   	cltd   
  800623:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800626:	8b 45 14             	mov    0x14(%ebp),%eax
  800629:	8d 40 04             	lea    0x4(%eax),%eax
  80062c:	89 45 14             	mov    %eax,0x14(%ebp)
  80062f:	eb 17                	jmp    800648 <.L29+0x3d>
		return va_arg(*ap, long long);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8b 50 04             	mov    0x4(%eax),%edx
  800637:	8b 00                	mov    (%eax),%eax
  800639:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80063f:	8b 45 14             	mov    0x14(%ebp),%eax
  800642:	8d 40 08             	lea    0x8(%eax),%eax
  800645:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800648:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80064b:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  80064e:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800653:	85 db                	test   %ebx,%ebx
  800655:	0f 89 0e 01 00 00    	jns    800769 <.L25+0x2b>
				putch('-', putdat);
  80065b:	83 ec 08             	sub    $0x8,%esp
  80065e:	57                   	push   %edi
  80065f:	6a 2d                	push   $0x2d
  800661:	ff d6                	call   *%esi
				num = -(long long) num;
  800663:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800666:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800669:	f7 d9                	neg    %ecx
  80066b:	83 d3 00             	adc    $0x0,%ebx
  80066e:	f7 db                	neg    %ebx
  800670:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800673:	ba 0a 00 00 00       	mov    $0xa,%edx
  800678:	e9 ec 00 00 00       	jmp    800769 <.L25+0x2b>
		return va_arg(*ap, int);
  80067d:	8b 45 14             	mov    0x14(%ebp),%eax
  800680:	8b 00                	mov    (%eax),%eax
  800682:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800685:	99                   	cltd   
  800686:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800689:	8b 45 14             	mov    0x14(%ebp),%eax
  80068c:	8d 40 04             	lea    0x4(%eax),%eax
  80068f:	89 45 14             	mov    %eax,0x14(%ebp)
  800692:	eb b4                	jmp    800648 <.L29+0x3d>

00800694 <.L23>:
	if (lflag >= 2)
  800694:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800697:	8b 75 08             	mov    0x8(%ebp),%esi
  80069a:	83 f9 01             	cmp    $0x1,%ecx
  80069d:	7f 1e                	jg     8006bd <.L23+0x29>
	else if (lflag)
  80069f:	85 c9                	test   %ecx,%ecx
  8006a1:	74 32                	je     8006d5 <.L23+0x41>
		return va_arg(*ap, unsigned long);
  8006a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a6:	8b 08                	mov    (%eax),%ecx
  8006a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ad:	8d 40 04             	lea    0x4(%eax),%eax
  8006b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006b3:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006b8:	e9 ac 00 00 00       	jmp    800769 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c0:	8b 08                	mov    (%eax),%ecx
  8006c2:	8b 58 04             	mov    0x4(%eax),%ebx
  8006c5:	8d 40 08             	lea    0x8(%eax),%eax
  8006c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006cb:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006d0:	e9 94 00 00 00       	jmp    800769 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8b 08                	mov    (%eax),%ecx
  8006da:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006df:	8d 40 04             	lea    0x4(%eax),%eax
  8006e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e5:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  8006ea:	eb 7d                	jmp    800769 <.L25+0x2b>

008006ec <.L26>:
	if (lflag >= 2)
  8006ec:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f2:	83 f9 01             	cmp    $0x1,%ecx
  8006f5:	7f 1b                	jg     800712 <.L26+0x26>
	else if (lflag)
  8006f7:	85 c9                	test   %ecx,%ecx
  8006f9:	74 2c                	je     800727 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
  8006fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fe:	8b 08                	mov    (%eax),%ecx
  800700:	bb 00 00 00 00       	mov    $0x0,%ebx
  800705:	8d 40 04             	lea    0x4(%eax),%eax
  800708:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80070b:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
  800710:	eb 57                	jmp    800769 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8b 08                	mov    (%eax),%ecx
  800717:	8b 58 04             	mov    0x4(%eax),%ebx
  80071a:	8d 40 08             	lea    0x8(%eax),%eax
  80071d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800720:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
  800725:	eb 42                	jmp    800769 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  800727:	8b 45 14             	mov    0x14(%ebp),%eax
  80072a:	8b 08                	mov    (%eax),%ecx
  80072c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800731:	8d 40 04             	lea    0x4(%eax),%eax
  800734:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800737:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
  80073c:	eb 2b                	jmp    800769 <.L25+0x2b>

0080073e <.L25>:
			putch('0', putdat);
  80073e:	8b 75 08             	mov    0x8(%ebp),%esi
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	57                   	push   %edi
  800745:	6a 30                	push   $0x30
  800747:	ff d6                	call   *%esi
			putch('x', putdat);
  800749:	83 c4 08             	add    $0x8,%esp
  80074c:	57                   	push   %edi
  80074d:	6a 78                	push   $0x78
  80074f:	ff d6                	call   *%esi
			num = (unsigned long long)
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	8b 08                	mov    (%eax),%ecx
  800756:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  80075b:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80075e:	8d 40 04             	lea    0x4(%eax),%eax
  800761:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800764:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800769:	83 ec 0c             	sub    $0xc,%esp
  80076c:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800770:	50                   	push   %eax
  800771:	ff 75 d4             	push   -0x2c(%ebp)
  800774:	52                   	push   %edx
  800775:	53                   	push   %ebx
  800776:	51                   	push   %ecx
  800777:	89 fa                	mov    %edi,%edx
  800779:	89 f0                	mov    %esi,%eax
  80077b:	e8 f4 fa ff ff       	call   800274 <printnum>
			break;
  800780:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800783:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800786:	e9 15 fc ff ff       	jmp    8003a0 <vprintfmt+0x34>

0080078b <.L21>:
	if (lflag >= 2)
  80078b:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80078e:	8b 75 08             	mov    0x8(%ebp),%esi
  800791:	83 f9 01             	cmp    $0x1,%ecx
  800794:	7f 1b                	jg     8007b1 <.L21+0x26>
	else if (lflag)
  800796:	85 c9                	test   %ecx,%ecx
  800798:	74 2c                	je     8007c6 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  80079a:	8b 45 14             	mov    0x14(%ebp),%eax
  80079d:	8b 08                	mov    (%eax),%ecx
  80079f:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007a4:	8d 40 04             	lea    0x4(%eax),%eax
  8007a7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007aa:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  8007af:	eb b8                	jmp    800769 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8007b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b4:	8b 08                	mov    (%eax),%ecx
  8007b6:	8b 58 04             	mov    0x4(%eax),%ebx
  8007b9:	8d 40 08             	lea    0x8(%eax),%eax
  8007bc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007bf:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8007c4:	eb a3                	jmp    800769 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8007c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c9:	8b 08                	mov    (%eax),%ecx
  8007cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007d0:	8d 40 04             	lea    0x4(%eax),%eax
  8007d3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d6:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007db:	eb 8c                	jmp    800769 <.L25+0x2b>

008007dd <.L35>:
			putch(ch, putdat);
  8007dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e0:	83 ec 08             	sub    $0x8,%esp
  8007e3:	57                   	push   %edi
  8007e4:	6a 25                	push   $0x25
  8007e6:	ff d6                	call   *%esi
			break;
  8007e8:	83 c4 10             	add    $0x10,%esp
  8007eb:	eb 96                	jmp    800783 <.L25+0x45>

008007ed <.L20>:
			putch('%', putdat);
  8007ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f0:	83 ec 08             	sub    $0x8,%esp
  8007f3:	57                   	push   %edi
  8007f4:	6a 25                	push   $0x25
  8007f6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f8:	83 c4 10             	add    $0x10,%esp
  8007fb:	89 d8                	mov    %ebx,%eax
  8007fd:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800801:	74 05                	je     800808 <.L20+0x1b>
  800803:	83 e8 01             	sub    $0x1,%eax
  800806:	eb f5                	jmp    8007fd <.L20+0x10>
  800808:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80080b:	e9 73 ff ff ff       	jmp    800783 <.L25+0x45>

00800810 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	53                   	push   %ebx
  800814:	83 ec 14             	sub    $0x14,%esp
  800817:	e8 5e f8 ff ff       	call   80007a <__x86.get_pc_thunk.bx>
  80081c:	81 c3 e4 17 00 00    	add    $0x17e4,%ebx
  800822:	8b 45 08             	mov    0x8(%ebp),%eax
  800825:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800828:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80082b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80082f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800832:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800839:	85 c0                	test   %eax,%eax
  80083b:	74 2b                	je     800868 <vsnprintf+0x58>
  80083d:	85 d2                	test   %edx,%edx
  80083f:	7e 27                	jle    800868 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800841:	ff 75 14             	push   0x14(%ebp)
  800844:	ff 75 10             	push   0x10(%ebp)
  800847:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084a:	50                   	push   %eax
  80084b:	8d 83 32 e3 ff ff    	lea    -0x1cce(%ebx),%eax
  800851:	50                   	push   %eax
  800852:	e8 15 fb ff ff       	call   80036c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800857:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80085d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800860:	83 c4 10             	add    $0x10,%esp
}
  800863:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800866:	c9                   	leave  
  800867:	c3                   	ret    
		return -E_INVAL;
  800868:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80086d:	eb f4                	jmp    800863 <vsnprintf+0x53>

0080086f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80086f:	55                   	push   %ebp
  800870:	89 e5                	mov    %esp,%ebp
  800872:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800875:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800878:	50                   	push   %eax
  800879:	ff 75 10             	push   0x10(%ebp)
  80087c:	ff 75 0c             	push   0xc(%ebp)
  80087f:	ff 75 08             	push   0x8(%ebp)
  800882:	e8 89 ff ff ff       	call   800810 <vsnprintf>
	va_end(ap);

	return rc;
}
  800887:	c9                   	leave  
  800888:	c3                   	ret    

00800889 <__x86.get_pc_thunk.cx>:
  800889:	8b 0c 24             	mov    (%esp),%ecx
  80088c:	c3                   	ret    

0080088d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800893:	b8 00 00 00 00       	mov    $0x0,%eax
  800898:	eb 03                	jmp    80089d <strlen+0x10>
		n++;
  80089a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80089d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a1:	75 f7                	jne    80089a <strlen+0xd>
	return n;
}
  8008a3:	5d                   	pop    %ebp
  8008a4:	c3                   	ret    

008008a5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b3:	eb 03                	jmp    8008b8 <strnlen+0x13>
		n++;
  8008b5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b8:	39 d0                	cmp    %edx,%eax
  8008ba:	74 08                	je     8008c4 <strnlen+0x1f>
  8008bc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008c0:	75 f3                	jne    8008b5 <strnlen+0x10>
  8008c2:	89 c2                	mov    %eax,%edx
	return n;
}
  8008c4:	89 d0                	mov    %edx,%eax
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    

008008c8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	53                   	push   %ebx
  8008cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d7:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008db:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008de:	83 c0 01             	add    $0x1,%eax
  8008e1:	84 d2                	test   %dl,%dl
  8008e3:	75 f2                	jne    8008d7 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008e5:	89 c8                	mov    %ecx,%eax
  8008e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ea:	c9                   	leave  
  8008eb:	c3                   	ret    

008008ec <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ec:	55                   	push   %ebp
  8008ed:	89 e5                	mov    %esp,%ebp
  8008ef:	53                   	push   %ebx
  8008f0:	83 ec 10             	sub    $0x10,%esp
  8008f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008f6:	53                   	push   %ebx
  8008f7:	e8 91 ff ff ff       	call   80088d <strlen>
  8008fc:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8008ff:	ff 75 0c             	push   0xc(%ebp)
  800902:	01 d8                	add    %ebx,%eax
  800904:	50                   	push   %eax
  800905:	e8 be ff ff ff       	call   8008c8 <strcpy>
	return dst;
}
  80090a:	89 d8                	mov    %ebx,%eax
  80090c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80090f:	c9                   	leave  
  800910:	c3                   	ret    

00800911 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800911:	55                   	push   %ebp
  800912:	89 e5                	mov    %esp,%ebp
  800914:	56                   	push   %esi
  800915:	53                   	push   %ebx
  800916:	8b 75 08             	mov    0x8(%ebp),%esi
  800919:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091c:	89 f3                	mov    %esi,%ebx
  80091e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800921:	89 f0                	mov    %esi,%eax
  800923:	eb 0f                	jmp    800934 <strncpy+0x23>
		*dst++ = *src;
  800925:	83 c0 01             	add    $0x1,%eax
  800928:	0f b6 0a             	movzbl (%edx),%ecx
  80092b:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80092e:	80 f9 01             	cmp    $0x1,%cl
  800931:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800934:	39 d8                	cmp    %ebx,%eax
  800936:	75 ed                	jne    800925 <strncpy+0x14>
	}
	return ret;
}
  800938:	89 f0                	mov    %esi,%eax
  80093a:	5b                   	pop    %ebx
  80093b:	5e                   	pop    %esi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	56                   	push   %esi
  800942:	53                   	push   %ebx
  800943:	8b 75 08             	mov    0x8(%ebp),%esi
  800946:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800949:	8b 55 10             	mov    0x10(%ebp),%edx
  80094c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80094e:	85 d2                	test   %edx,%edx
  800950:	74 21                	je     800973 <strlcpy+0x35>
  800952:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800956:	89 f2                	mov    %esi,%edx
  800958:	eb 09                	jmp    800963 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80095a:	83 c1 01             	add    $0x1,%ecx
  80095d:	83 c2 01             	add    $0x1,%edx
  800960:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800963:	39 c2                	cmp    %eax,%edx
  800965:	74 09                	je     800970 <strlcpy+0x32>
  800967:	0f b6 19             	movzbl (%ecx),%ebx
  80096a:	84 db                	test   %bl,%bl
  80096c:	75 ec                	jne    80095a <strlcpy+0x1c>
  80096e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800970:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800973:	29 f0                	sub    %esi,%eax
}
  800975:	5b                   	pop    %ebx
  800976:	5e                   	pop    %esi
  800977:	5d                   	pop    %ebp
  800978:	c3                   	ret    

00800979 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800979:	55                   	push   %ebp
  80097a:	89 e5                	mov    %esp,%ebp
  80097c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800982:	eb 06                	jmp    80098a <strcmp+0x11>
		p++, q++;
  800984:	83 c1 01             	add    $0x1,%ecx
  800987:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80098a:	0f b6 01             	movzbl (%ecx),%eax
  80098d:	84 c0                	test   %al,%al
  80098f:	74 04                	je     800995 <strcmp+0x1c>
  800991:	3a 02                	cmp    (%edx),%al
  800993:	74 ef                	je     800984 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800995:	0f b6 c0             	movzbl %al,%eax
  800998:	0f b6 12             	movzbl (%edx),%edx
  80099b:	29 d0                	sub    %edx,%eax
}
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	53                   	push   %ebx
  8009a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009a9:	89 c3                	mov    %eax,%ebx
  8009ab:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009ae:	eb 06                	jmp    8009b6 <strncmp+0x17>
		n--, p++, q++;
  8009b0:	83 c0 01             	add    $0x1,%eax
  8009b3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009b6:	39 d8                	cmp    %ebx,%eax
  8009b8:	74 18                	je     8009d2 <strncmp+0x33>
  8009ba:	0f b6 08             	movzbl (%eax),%ecx
  8009bd:	84 c9                	test   %cl,%cl
  8009bf:	74 04                	je     8009c5 <strncmp+0x26>
  8009c1:	3a 0a                	cmp    (%edx),%cl
  8009c3:	74 eb                	je     8009b0 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c5:	0f b6 00             	movzbl (%eax),%eax
  8009c8:	0f b6 12             	movzbl (%edx),%edx
  8009cb:	29 d0                	sub    %edx,%eax
}
  8009cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d0:	c9                   	leave  
  8009d1:	c3                   	ret    
		return 0;
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d7:	eb f4                	jmp    8009cd <strncmp+0x2e>

008009d9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e3:	eb 03                	jmp    8009e8 <strchr+0xf>
  8009e5:	83 c0 01             	add    $0x1,%eax
  8009e8:	0f b6 10             	movzbl (%eax),%edx
  8009eb:	84 d2                	test   %dl,%dl
  8009ed:	74 06                	je     8009f5 <strchr+0x1c>
		if (*s == c)
  8009ef:	38 ca                	cmp    %cl,%dl
  8009f1:	75 f2                	jne    8009e5 <strchr+0xc>
  8009f3:	eb 05                	jmp    8009fa <strchr+0x21>
			return (char *) s;
	return 0;
  8009f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fa:	5d                   	pop    %ebp
  8009fb:	c3                   	ret    

008009fc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009fc:	55                   	push   %ebp
  8009fd:	89 e5                	mov    %esp,%ebp
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
  800a02:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a06:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a09:	38 ca                	cmp    %cl,%dl
  800a0b:	74 09                	je     800a16 <strfind+0x1a>
  800a0d:	84 d2                	test   %dl,%dl
  800a0f:	74 05                	je     800a16 <strfind+0x1a>
	for (; *s; s++)
  800a11:	83 c0 01             	add    $0x1,%eax
  800a14:	eb f0                	jmp    800a06 <strfind+0xa>
			break;
	return (char *) s;
}
  800a16:	5d                   	pop    %ebp
  800a17:	c3                   	ret    

00800a18 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	57                   	push   %edi
  800a1c:	56                   	push   %esi
  800a1d:	53                   	push   %ebx
  800a1e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a21:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a24:	85 c9                	test   %ecx,%ecx
  800a26:	74 2f                	je     800a57 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a28:	89 f8                	mov    %edi,%eax
  800a2a:	09 c8                	or     %ecx,%eax
  800a2c:	a8 03                	test   $0x3,%al
  800a2e:	75 21                	jne    800a51 <memset+0x39>
		c &= 0xFF;
  800a30:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a34:	89 d0                	mov    %edx,%eax
  800a36:	c1 e0 08             	shl    $0x8,%eax
  800a39:	89 d3                	mov    %edx,%ebx
  800a3b:	c1 e3 18             	shl    $0x18,%ebx
  800a3e:	89 d6                	mov    %edx,%esi
  800a40:	c1 e6 10             	shl    $0x10,%esi
  800a43:	09 f3                	or     %esi,%ebx
  800a45:	09 da                	or     %ebx,%edx
  800a47:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a49:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a4c:	fc                   	cld    
  800a4d:	f3 ab                	rep stos %eax,%es:(%edi)
  800a4f:	eb 06                	jmp    800a57 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a54:	fc                   	cld    
  800a55:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a57:	89 f8                	mov    %edi,%eax
  800a59:	5b                   	pop    %ebx
  800a5a:	5e                   	pop    %esi
  800a5b:	5f                   	pop    %edi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	57                   	push   %edi
  800a62:	56                   	push   %esi
  800a63:	8b 45 08             	mov    0x8(%ebp),%eax
  800a66:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a69:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a6c:	39 c6                	cmp    %eax,%esi
  800a6e:	73 32                	jae    800aa2 <memmove+0x44>
  800a70:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a73:	39 c2                	cmp    %eax,%edx
  800a75:	76 2b                	jbe    800aa2 <memmove+0x44>
		s += n;
		d += n;
  800a77:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7a:	89 d6                	mov    %edx,%esi
  800a7c:	09 fe                	or     %edi,%esi
  800a7e:	09 ce                	or     %ecx,%esi
  800a80:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a86:	75 0e                	jne    800a96 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a88:	83 ef 04             	sub    $0x4,%edi
  800a8b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a8e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a91:	fd                   	std    
  800a92:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a94:	eb 09                	jmp    800a9f <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a96:	83 ef 01             	sub    $0x1,%edi
  800a99:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a9c:	fd                   	std    
  800a9d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a9f:	fc                   	cld    
  800aa0:	eb 1a                	jmp    800abc <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa2:	89 f2                	mov    %esi,%edx
  800aa4:	09 c2                	or     %eax,%edx
  800aa6:	09 ca                	or     %ecx,%edx
  800aa8:	f6 c2 03             	test   $0x3,%dl
  800aab:	75 0a                	jne    800ab7 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aad:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ab0:	89 c7                	mov    %eax,%edi
  800ab2:	fc                   	cld    
  800ab3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab5:	eb 05                	jmp    800abc <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800ab7:	89 c7                	mov    %eax,%edi
  800ab9:	fc                   	cld    
  800aba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800abc:	5e                   	pop    %esi
  800abd:	5f                   	pop    %edi
  800abe:	5d                   	pop    %ebp
  800abf:	c3                   	ret    

00800ac0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ac0:	55                   	push   %ebp
  800ac1:	89 e5                	mov    %esp,%ebp
  800ac3:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ac6:	ff 75 10             	push   0x10(%ebp)
  800ac9:	ff 75 0c             	push   0xc(%ebp)
  800acc:	ff 75 08             	push   0x8(%ebp)
  800acf:	e8 8a ff ff ff       	call   800a5e <memmove>
}
  800ad4:	c9                   	leave  
  800ad5:	c3                   	ret    

00800ad6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad6:	55                   	push   %ebp
  800ad7:	89 e5                	mov    %esp,%ebp
  800ad9:	56                   	push   %esi
  800ada:	53                   	push   %ebx
  800adb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ade:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae1:	89 c6                	mov    %eax,%esi
  800ae3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae6:	eb 06                	jmp    800aee <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ae8:	83 c0 01             	add    $0x1,%eax
  800aeb:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800aee:	39 f0                	cmp    %esi,%eax
  800af0:	74 14                	je     800b06 <memcmp+0x30>
		if (*s1 != *s2)
  800af2:	0f b6 08             	movzbl (%eax),%ecx
  800af5:	0f b6 1a             	movzbl (%edx),%ebx
  800af8:	38 d9                	cmp    %bl,%cl
  800afa:	74 ec                	je     800ae8 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800afc:	0f b6 c1             	movzbl %cl,%eax
  800aff:	0f b6 db             	movzbl %bl,%ebx
  800b02:	29 d8                	sub    %ebx,%eax
  800b04:	eb 05                	jmp    800b0b <memcmp+0x35>
	}

	return 0;
  800b06:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0b:	5b                   	pop    %ebx
  800b0c:	5e                   	pop    %esi
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	8b 45 08             	mov    0x8(%ebp),%eax
  800b15:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b18:	89 c2                	mov    %eax,%edx
  800b1a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b1d:	eb 03                	jmp    800b22 <memfind+0x13>
  800b1f:	83 c0 01             	add    $0x1,%eax
  800b22:	39 d0                	cmp    %edx,%eax
  800b24:	73 04                	jae    800b2a <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b26:	38 08                	cmp    %cl,(%eax)
  800b28:	75 f5                	jne    800b1f <memfind+0x10>
			break;
	return (void *) s;
}
  800b2a:	5d                   	pop    %ebp
  800b2b:	c3                   	ret    

00800b2c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b2c:	55                   	push   %ebp
  800b2d:	89 e5                	mov    %esp,%ebp
  800b2f:	57                   	push   %edi
  800b30:	56                   	push   %esi
  800b31:	53                   	push   %ebx
  800b32:	8b 55 08             	mov    0x8(%ebp),%edx
  800b35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b38:	eb 03                	jmp    800b3d <strtol+0x11>
		s++;
  800b3a:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b3d:	0f b6 02             	movzbl (%edx),%eax
  800b40:	3c 20                	cmp    $0x20,%al
  800b42:	74 f6                	je     800b3a <strtol+0xe>
  800b44:	3c 09                	cmp    $0x9,%al
  800b46:	74 f2                	je     800b3a <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b48:	3c 2b                	cmp    $0x2b,%al
  800b4a:	74 2a                	je     800b76 <strtol+0x4a>
	int neg = 0;
  800b4c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b51:	3c 2d                	cmp    $0x2d,%al
  800b53:	74 2b                	je     800b80 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b55:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b5b:	75 0f                	jne    800b6c <strtol+0x40>
  800b5d:	80 3a 30             	cmpb   $0x30,(%edx)
  800b60:	74 28                	je     800b8a <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b62:	85 db                	test   %ebx,%ebx
  800b64:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b69:	0f 44 d8             	cmove  %eax,%ebx
  800b6c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b71:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b74:	eb 46                	jmp    800bbc <strtol+0x90>
		s++;
  800b76:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b79:	bf 00 00 00 00       	mov    $0x0,%edi
  800b7e:	eb d5                	jmp    800b55 <strtol+0x29>
		s++, neg = 1;
  800b80:	83 c2 01             	add    $0x1,%edx
  800b83:	bf 01 00 00 00       	mov    $0x1,%edi
  800b88:	eb cb                	jmp    800b55 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b8a:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b8e:	74 0e                	je     800b9e <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b90:	85 db                	test   %ebx,%ebx
  800b92:	75 d8                	jne    800b6c <strtol+0x40>
		s++, base = 8;
  800b94:	83 c2 01             	add    $0x1,%edx
  800b97:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b9c:	eb ce                	jmp    800b6c <strtol+0x40>
		s += 2, base = 16;
  800b9e:	83 c2 02             	add    $0x2,%edx
  800ba1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ba6:	eb c4                	jmp    800b6c <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ba8:	0f be c0             	movsbl %al,%eax
  800bab:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bae:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bb1:	7d 3a                	jge    800bed <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bb3:	83 c2 01             	add    $0x1,%edx
  800bb6:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bba:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800bbc:	0f b6 02             	movzbl (%edx),%eax
  800bbf:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bc2:	89 f3                	mov    %esi,%ebx
  800bc4:	80 fb 09             	cmp    $0x9,%bl
  800bc7:	76 df                	jbe    800ba8 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bc9:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bcc:	89 f3                	mov    %esi,%ebx
  800bce:	80 fb 19             	cmp    $0x19,%bl
  800bd1:	77 08                	ja     800bdb <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bd3:	0f be c0             	movsbl %al,%eax
  800bd6:	83 e8 57             	sub    $0x57,%eax
  800bd9:	eb d3                	jmp    800bae <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bdb:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bde:	89 f3                	mov    %esi,%ebx
  800be0:	80 fb 19             	cmp    $0x19,%bl
  800be3:	77 08                	ja     800bed <strtol+0xc1>
			dig = *s - 'A' + 10;
  800be5:	0f be c0             	movsbl %al,%eax
  800be8:	83 e8 37             	sub    $0x37,%eax
  800beb:	eb c1                	jmp    800bae <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bed:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf1:	74 05                	je     800bf8 <strtol+0xcc>
		*endptr = (char *) s;
  800bf3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf6:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800bf8:	89 c8                	mov    %ecx,%eax
  800bfa:	f7 d8                	neg    %eax
  800bfc:	85 ff                	test   %edi,%edi
  800bfe:	0f 45 c8             	cmovne %eax,%ecx
}
  800c01:	89 c8                	mov    %ecx,%eax
  800c03:	5b                   	pop    %ebx
  800c04:	5e                   	pop    %esi
  800c05:	5f                   	pop    %edi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    
  800c08:	66 90                	xchg   %ax,%ax
  800c0a:	66 90                	xchg   %ax,%ax
  800c0c:	66 90                	xchg   %ax,%ax
  800c0e:	66 90                	xchg   %ax,%ax

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
