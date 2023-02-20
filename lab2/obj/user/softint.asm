
obj/user/softint：     文件格式 elf32-i386


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
  80002c:	e8 05 00 00 00       	call   800036 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	asm volatile("int $14");	// page fault
  800033:	cd 0e                	int    $0xe
}
  800035:	c3                   	ret    

00800036 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800036:	55                   	push   %ebp
  800037:	89 e5                	mov    %esp,%ebp
  800039:	53                   	push   %ebx
  80003a:	83 ec 04             	sub    $0x4,%esp
  80003d:	e8 39 00 00 00       	call   80007b <__x86.get_pc_thunk.bx>
  800042:	81 c3 be 1f 00 00    	add    $0x1fbe,%ebx
  800048:	8b 45 08             	mov    0x8(%ebp),%eax
  80004b:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004e:	c7 83 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
  800055:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800058:	85 c0                	test   %eax,%eax
  80005a:	7e 08                	jle    800064 <libmain+0x2e>
		binaryname = argv[0];
  80005c:	8b 0a                	mov    (%edx),%ecx
  80005e:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800064:	83 ec 08             	sub    $0x8,%esp
  800067:	52                   	push   %edx
  800068:	50                   	push   %eax
  800069:	e8 c5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80006e:	e8 0c 00 00 00       	call   80007f <exit>
}
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800079:	c9                   	leave  
  80007a:	c3                   	ret    

0080007b <__x86.get_pc_thunk.bx>:
  80007b:	8b 1c 24             	mov    (%esp),%ebx
  80007e:	c3                   	ret    

0080007f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007f:	55                   	push   %ebp
  800080:	89 e5                	mov    %esp,%ebp
  800082:	53                   	push   %ebx
  800083:	83 ec 10             	sub    $0x10,%esp
  800086:	e8 f0 ff ff ff       	call   80007b <__x86.get_pc_thunk.bx>
  80008b:	81 c3 75 1f 00 00    	add    $0x1f75,%ebx
	sys_env_destroy(0);
  800091:	6a 00                	push   $0x0
  800093:	e8 45 00 00 00       	call   8000dd <sys_env_destroy>
}
  800098:	83 c4 10             	add    $0x10,%esp
  80009b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b1:	89 c3                	mov    %eax,%ebx
  8000b3:	89 c7                	mov    %eax,%edi
  8000b5:	89 c6                	mov    %eax,%esi
  8000b7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <sys_cgetc>:

int
sys_cgetc(void)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	57                   	push   %edi
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ce:	89 d1                	mov    %edx,%ecx
  8000d0:	89 d3                	mov    %edx,%ebx
  8000d2:	89 d7                	mov    %edx,%edi
  8000d4:	89 d6                	mov    %edx,%esi
  8000d6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d8:	5b                   	pop    %ebx
  8000d9:	5e                   	pop    %esi
  8000da:	5f                   	pop    %edi
  8000db:	5d                   	pop    %ebp
  8000dc:	c3                   	ret    

008000dd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dd:	55                   	push   %ebp
  8000de:	89 e5                	mov    %esp,%ebp
  8000e0:	57                   	push   %edi
  8000e1:	56                   	push   %esi
  8000e2:	53                   	push   %ebx
  8000e3:	83 ec 1c             	sub    $0x1c,%esp
  8000e6:	e8 66 00 00 00       	call   800151 <__x86.get_pc_thunk.ax>
  8000eb:	05 15 1f 00 00       	add    $0x1f15,%eax
  8000f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8000f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fb:	b8 03 00 00 00       	mov    $0x3,%eax
  800100:	89 cb                	mov    %ecx,%ebx
  800102:	89 cf                	mov    %ecx,%edi
  800104:	89 ce                	mov    %ecx,%esi
  800106:	cd 30                	int    $0x30
	if(check && ret > 0)
  800108:	85 c0                	test   %eax,%eax
  80010a:	7f 08                	jg     800114 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5f                   	pop    %edi
  800112:	5d                   	pop    %ebp
  800113:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	50                   	push   %eax
  800118:	6a 03                	push   $0x3
  80011a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80011d:	8d 83 4e ee ff ff    	lea    -0x11b2(%ebx),%eax
  800123:	50                   	push   %eax
  800124:	6a 23                	push   $0x23
  800126:	8d 83 6b ee ff ff    	lea    -0x1195(%ebx),%eax
  80012c:	50                   	push   %eax
  80012d:	e8 23 00 00 00       	call   800155 <_panic>

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <__x86.get_pc_thunk.ax>:
  800151:	8b 04 24             	mov    (%esp),%eax
  800154:	c3                   	ret    

00800155 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	e8 18 ff ff ff       	call   80007b <__x86.get_pc_thunk.bx>
  800163:	81 c3 9d 1e 00 00    	add    $0x1e9d,%ebx
	va_list ap;

	va_start(ap, fmt);
  800169:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016c:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800172:	8b 38                	mov    (%eax),%edi
  800174:	e8 b9 ff ff ff       	call   800132 <sys_getenvid>
  800179:	83 ec 0c             	sub    $0xc,%esp
  80017c:	ff 75 0c             	push   0xc(%ebp)
  80017f:	ff 75 08             	push   0x8(%ebp)
  800182:	57                   	push   %edi
  800183:	50                   	push   %eax
  800184:	8d 83 7c ee ff ff    	lea    -0x1184(%ebx),%eax
  80018a:	50                   	push   %eax
  80018b:	e8 d1 00 00 00       	call   800261 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800190:	83 c4 18             	add    $0x18,%esp
  800193:	56                   	push   %esi
  800194:	ff 75 10             	push   0x10(%ebp)
  800197:	e8 63 00 00 00       	call   8001ff <vcprintf>
	cprintf("\n");
  80019c:	8d 83 9f ee ff ff    	lea    -0x1161(%ebx),%eax
  8001a2:	89 04 24             	mov    %eax,(%esp)
  8001a5:	e8 b7 00 00 00       	call   800261 <cprintf>
  8001aa:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001ad:	cc                   	int3   
  8001ae:	eb fd                	jmp    8001ad <_panic+0x58>

008001b0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b0:	55                   	push   %ebp
  8001b1:	89 e5                	mov    %esp,%ebp
  8001b3:	56                   	push   %esi
  8001b4:	53                   	push   %ebx
  8001b5:	e8 c1 fe ff ff       	call   80007b <__x86.get_pc_thunk.bx>
  8001ba:	81 c3 46 1e 00 00    	add    $0x1e46,%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001c3:	8b 16                	mov    (%esi),%edx
  8001c5:	8d 42 01             	lea    0x1(%edx),%eax
  8001c8:	89 06                	mov    %eax,(%esi)
  8001ca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001cd:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001d1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001d6:	74 0b                	je     8001e3 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001d8:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001df:	5b                   	pop    %ebx
  8001e0:	5e                   	pop    %esi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001e3:	83 ec 08             	sub    $0x8,%esp
  8001e6:	68 ff 00 00 00       	push   $0xff
  8001eb:	8d 46 08             	lea    0x8(%esi),%eax
  8001ee:	50                   	push   %eax
  8001ef:	e8 ac fe ff ff       	call   8000a0 <sys_cputs>
		b->idx = 0;
  8001f4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	eb d9                	jmp    8001d8 <putch+0x28>

008001ff <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001ff:	55                   	push   %ebp
  800200:	89 e5                	mov    %esp,%ebp
  800202:	53                   	push   %ebx
  800203:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800209:	e8 6d fe ff ff       	call   80007b <__x86.get_pc_thunk.bx>
  80020e:	81 c3 f2 1d 00 00    	add    $0x1df2,%ebx
	struct printbuf b;

	b.idx = 0;
  800214:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021b:	00 00 00 
	b.cnt = 0;
  80021e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800225:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800228:	ff 75 0c             	push   0xc(%ebp)
  80022b:	ff 75 08             	push   0x8(%ebp)
  80022e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800234:	50                   	push   %eax
  800235:	8d 83 b0 e1 ff ff    	lea    -0x1e50(%ebx),%eax
  80023b:	50                   	push   %eax
  80023c:	e8 2c 01 00 00       	call   80036d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800241:	83 c4 08             	add    $0x8,%esp
  800244:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80024a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800250:	50                   	push   %eax
  800251:	e8 4a fe ff ff       	call   8000a0 <sys_cputs>

	return b.cnt;
}
  800256:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80025c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80025f:	c9                   	leave  
  800260:	c3                   	ret    

00800261 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800261:	55                   	push   %ebp
  800262:	89 e5                	mov    %esp,%ebp
  800264:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800267:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80026a:	50                   	push   %eax
  80026b:	ff 75 08             	push   0x8(%ebp)
  80026e:	e8 8c ff ff ff       	call   8001ff <vcprintf>
	va_end(ap);

	return cnt;
}
  800273:	c9                   	leave  
  800274:	c3                   	ret    

00800275 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800275:	55                   	push   %ebp
  800276:	89 e5                	mov    %esp,%ebp
  800278:	57                   	push   %edi
  800279:	56                   	push   %esi
  80027a:	53                   	push   %ebx
  80027b:	83 ec 2c             	sub    $0x2c,%esp
  80027e:	e8 07 06 00 00       	call   80088a <__x86.get_pc_thunk.cx>
  800283:	81 c1 7d 1d 00 00    	add    $0x1d7d,%ecx
  800289:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80028c:	89 c7                	mov    %eax,%edi
  80028e:	89 d6                	mov    %edx,%esi
  800290:	8b 45 08             	mov    0x8(%ebp),%eax
  800293:	8b 55 0c             	mov    0xc(%ebp),%edx
  800296:	89 d1                	mov    %edx,%ecx
  800298:	89 c2                	mov    %eax,%edx
  80029a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80029d:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002a3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002a9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002b0:	39 c2                	cmp    %eax,%edx
  8002b2:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002b5:	72 41                	jb     8002f8 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002b7:	83 ec 0c             	sub    $0xc,%esp
  8002ba:	ff 75 18             	push   0x18(%ebp)
  8002bd:	83 eb 01             	sub    $0x1,%ebx
  8002c0:	53                   	push   %ebx
  8002c1:	50                   	push   %eax
  8002c2:	83 ec 08             	sub    $0x8,%esp
  8002c5:	ff 75 e4             	push   -0x1c(%ebp)
  8002c8:	ff 75 e0             	push   -0x20(%ebp)
  8002cb:	ff 75 d4             	push   -0x2c(%ebp)
  8002ce:	ff 75 d0             	push   -0x30(%ebp)
  8002d1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002d4:	e8 37 09 00 00       	call   800c10 <__udivdi3>
  8002d9:	83 c4 18             	add    $0x18,%esp
  8002dc:	52                   	push   %edx
  8002dd:	50                   	push   %eax
  8002de:	89 f2                	mov    %esi,%edx
  8002e0:	89 f8                	mov    %edi,%eax
  8002e2:	e8 8e ff ff ff       	call   800275 <printnum>
  8002e7:	83 c4 20             	add    $0x20,%esp
  8002ea:	eb 13                	jmp    8002ff <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002ec:	83 ec 08             	sub    $0x8,%esp
  8002ef:	56                   	push   %esi
  8002f0:	ff 75 18             	push   0x18(%ebp)
  8002f3:	ff d7                	call   *%edi
  8002f5:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002f8:	83 eb 01             	sub    $0x1,%ebx
  8002fb:	85 db                	test   %ebx,%ebx
  8002fd:	7f ed                	jg     8002ec <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002ff:	83 ec 08             	sub    $0x8,%esp
  800302:	56                   	push   %esi
  800303:	83 ec 04             	sub    $0x4,%esp
  800306:	ff 75 e4             	push   -0x1c(%ebp)
  800309:	ff 75 e0             	push   -0x20(%ebp)
  80030c:	ff 75 d4             	push   -0x2c(%ebp)
  80030f:	ff 75 d0             	push   -0x30(%ebp)
  800312:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800315:	e8 16 0a 00 00       	call   800d30 <__umoddi3>
  80031a:	83 c4 14             	add    $0x14,%esp
  80031d:	0f be 84 03 a1 ee ff 	movsbl -0x115f(%ebx,%eax,1),%eax
  800324:	ff 
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
  800376:	e8 d6 fd ff ff       	call   800151 <__x86.get_pc_thunk.ax>
  80037b:	05 85 1c 00 00       	add    $0x1c85,%eax
  800380:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800383:	8b 75 08             	mov    0x8(%ebp),%esi
  800386:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800389:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80038c:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  800392:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800395:	eb 0a                	jmp    8003a1 <vprintfmt+0x34>
			putch(ch, putdat);
  800397:	83 ec 08             	sub    $0x8,%esp
  80039a:	57                   	push   %edi
  80039b:	50                   	push   %eax
  80039c:	ff d6                	call   *%esi
  80039e:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a1:	83 c3 01             	add    $0x1,%ebx
  8003a4:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003a8:	83 f8 25             	cmp    $0x25,%eax
  8003ab:	74 0c                	je     8003b9 <vprintfmt+0x4c>
			if (ch == '\0')
  8003ad:	85 c0                	test   %eax,%eax
  8003af:	75 e6                	jne    800397 <vprintfmt+0x2a>
}
  8003b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b4:	5b                   	pop    %ebx
  8003b5:	5e                   	pop    %esi
  8003b6:	5f                   	pop    %edi
  8003b7:	5d                   	pop    %ebp
  8003b8:	c3                   	ret    
		padc = ' ';
  8003b9:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003bd:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  8003c4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003cb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  8003d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003d7:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003da:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003dd:	8d 43 01             	lea    0x1(%ebx),%eax
  8003e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003e3:	0f b6 13             	movzbl (%ebx),%edx
  8003e6:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003e9:	3c 55                	cmp    $0x55,%al
  8003eb:	0f 87 fd 03 00 00    	ja     8007ee <.L20>
  8003f1:	0f b6 c0             	movzbl %al,%eax
  8003f4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003f7:	89 ce                	mov    %ecx,%esi
  8003f9:	03 b4 81 30 ef ff ff 	add    -0x10d0(%ecx,%eax,4),%esi
  800400:	ff e6                	jmp    *%esi

00800402 <.L68>:
  800402:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800405:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800409:	eb d2                	jmp    8003dd <vprintfmt+0x70>

0080040b <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  80040b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80040e:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800412:	eb c9                	jmp    8003dd <vprintfmt+0x70>

00800414 <.L31>:
  800414:	0f b6 d2             	movzbl %dl,%edx
  800417:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  80041a:	b8 00 00 00 00       	mov    $0x0,%eax
  80041f:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800422:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800425:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800429:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80042c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80042f:	83 f9 09             	cmp    $0x9,%ecx
  800432:	77 58                	ja     80048c <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800434:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800437:	eb e9                	jmp    800422 <.L31+0xe>

00800439 <.L34>:
			precision = va_arg(ap, int);
  800439:	8b 45 14             	mov    0x14(%ebp),%eax
  80043c:	8b 00                	mov    (%eax),%eax
  80043e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800441:	8b 45 14             	mov    0x14(%ebp),%eax
  800444:	8d 40 04             	lea    0x4(%eax),%eax
  800447:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80044d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800451:	79 8a                	jns    8003dd <vprintfmt+0x70>
				width = precision, precision = -1;
  800453:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800456:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800459:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800460:	e9 78 ff ff ff       	jmp    8003dd <vprintfmt+0x70>

00800465 <.L33>:
  800465:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800468:	85 d2                	test   %edx,%edx
  80046a:	b8 00 00 00 00       	mov    $0x0,%eax
  80046f:	0f 49 c2             	cmovns %edx,%eax
  800472:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800475:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800478:	e9 60 ff ff ff       	jmp    8003dd <vprintfmt+0x70>

0080047d <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  800480:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  800487:	e9 51 ff ff ff       	jmp    8003dd <vprintfmt+0x70>
  80048c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80048f:	89 75 08             	mov    %esi,0x8(%ebp)
  800492:	eb b9                	jmp    80044d <.L34+0x14>

00800494 <.L27>:
			lflag++;
  800494:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800498:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  80049b:	e9 3d ff ff ff       	jmp    8003dd <vprintfmt+0x70>

008004a0 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a6:	8d 58 04             	lea    0x4(%eax),%ebx
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	57                   	push   %edi
  8004ad:	ff 30                	push   (%eax)
  8004af:	ff d6                	call   *%esi
			break;
  8004b1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004b4:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004b7:	e9 c8 02 00 00       	jmp    800784 <.L25+0x45>

008004bc <.L28>:
			err = va_arg(ap, int);
  8004bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c2:	8d 58 04             	lea    0x4(%eax),%ebx
  8004c5:	8b 10                	mov    (%eax),%edx
  8004c7:	89 d0                	mov    %edx,%eax
  8004c9:	f7 d8                	neg    %eax
  8004cb:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ce:	83 f8 06             	cmp    $0x6,%eax
  8004d1:	7f 27                	jg     8004fa <.L28+0x3e>
  8004d3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004d6:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004d9:	85 d2                	test   %edx,%edx
  8004db:	74 1d                	je     8004fa <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8004dd:	52                   	push   %edx
  8004de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e1:	8d 80 c2 ee ff ff    	lea    -0x113e(%eax),%eax
  8004e7:	50                   	push   %eax
  8004e8:	57                   	push   %edi
  8004e9:	56                   	push   %esi
  8004ea:	e8 61 fe ff ff       	call   800350 <printfmt>
  8004ef:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004f2:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004f5:	e9 8a 02 00 00       	jmp    800784 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  8004fa:	50                   	push   %eax
  8004fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004fe:	8d 80 b9 ee ff ff    	lea    -0x1147(%eax),%eax
  800504:	50                   	push   %eax
  800505:	57                   	push   %edi
  800506:	56                   	push   %esi
  800507:	e8 44 fe ff ff       	call   800350 <printfmt>
  80050c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80050f:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800512:	e9 6d 02 00 00       	jmp    800784 <.L25+0x45>

00800517 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800517:	8b 75 08             	mov    0x8(%ebp),%esi
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	83 c0 04             	add    $0x4,%eax
  800520:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800528:	85 d2                	test   %edx,%edx
  80052a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052d:	8d 80 b2 ee ff ff    	lea    -0x114e(%eax),%eax
  800533:	0f 45 c2             	cmovne %edx,%eax
  800536:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800539:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80053d:	7e 06                	jle    800545 <.L24+0x2e>
  80053f:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800543:	75 0d                	jne    800552 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800545:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800548:	89 c3                	mov    %eax,%ebx
  80054a:	03 45 d4             	add    -0x2c(%ebp),%eax
  80054d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800550:	eb 58                	jmp    8005aa <.L24+0x93>
  800552:	83 ec 08             	sub    $0x8,%esp
  800555:	ff 75 d8             	push   -0x28(%ebp)
  800558:	ff 75 c8             	push   -0x38(%ebp)
  80055b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055e:	e8 43 03 00 00       	call   8008a6 <strnlen>
  800563:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800566:	29 c2                	sub    %eax,%edx
  800568:	89 55 bc             	mov    %edx,-0x44(%ebp)
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  800570:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800574:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800577:	eb 0f                	jmp    800588 <.L24+0x71>
					putch(padc, putdat);
  800579:	83 ec 08             	sub    $0x8,%esp
  80057c:	57                   	push   %edi
  80057d:	ff 75 d4             	push   -0x2c(%ebp)
  800580:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  800582:	83 eb 01             	sub    $0x1,%ebx
  800585:	83 c4 10             	add    $0x10,%esp
  800588:	85 db                	test   %ebx,%ebx
  80058a:	7f ed                	jg     800579 <.L24+0x62>
  80058c:	8b 55 bc             	mov    -0x44(%ebp),%edx
  80058f:	85 d2                	test   %edx,%edx
  800591:	b8 00 00 00 00       	mov    $0x0,%eax
  800596:	0f 49 c2             	cmovns %edx,%eax
  800599:	29 c2                	sub    %eax,%edx
  80059b:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80059e:	eb a5                	jmp    800545 <.L24+0x2e>
					putch(ch, putdat);
  8005a0:	83 ec 08             	sub    $0x8,%esp
  8005a3:	57                   	push   %edi
  8005a4:	52                   	push   %edx
  8005a5:	ff d6                	call   *%esi
  8005a7:	83 c4 10             	add    $0x10,%esp
  8005aa:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005ad:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005af:	83 c3 01             	add    $0x1,%ebx
  8005b2:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005b6:	0f be d0             	movsbl %al,%edx
  8005b9:	85 d2                	test   %edx,%edx
  8005bb:	74 4b                	je     800608 <.L24+0xf1>
  8005bd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c1:	78 06                	js     8005c9 <.L24+0xb2>
  8005c3:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005c7:	78 1e                	js     8005e7 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005c9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005cd:	74 d1                	je     8005a0 <.L24+0x89>
  8005cf:	0f be c0             	movsbl %al,%eax
  8005d2:	83 e8 20             	sub    $0x20,%eax
  8005d5:	83 f8 5e             	cmp    $0x5e,%eax
  8005d8:	76 c6                	jbe    8005a0 <.L24+0x89>
					putch('?', putdat);
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	57                   	push   %edi
  8005de:	6a 3f                	push   $0x3f
  8005e0:	ff d6                	call   *%esi
  8005e2:	83 c4 10             	add    $0x10,%esp
  8005e5:	eb c3                	jmp    8005aa <.L24+0x93>
  8005e7:	89 cb                	mov    %ecx,%ebx
  8005e9:	eb 0e                	jmp    8005f9 <.L24+0xe2>
				putch(' ', putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	57                   	push   %edi
  8005ef:	6a 20                	push   $0x20
  8005f1:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005f3:	83 eb 01             	sub    $0x1,%ebx
  8005f6:	83 c4 10             	add    $0x10,%esp
  8005f9:	85 db                	test   %ebx,%ebx
  8005fb:	7f ee                	jg     8005eb <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  8005fd:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800600:	89 45 14             	mov    %eax,0x14(%ebp)
  800603:	e9 7c 01 00 00       	jmp    800784 <.L25+0x45>
  800608:	89 cb                	mov    %ecx,%ebx
  80060a:	eb ed                	jmp    8005f9 <.L24+0xe2>

0080060c <.L29>:
	if (lflag >= 2)
  80060c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80060f:	8b 75 08             	mov    0x8(%ebp),%esi
  800612:	83 f9 01             	cmp    $0x1,%ecx
  800615:	7f 1b                	jg     800632 <.L29+0x26>
	else if (lflag)
  800617:	85 c9                	test   %ecx,%ecx
  800619:	74 63                	je     80067e <.L29+0x72>
		return va_arg(*ap, long);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8b 00                	mov    (%eax),%eax
  800620:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800623:	99                   	cltd   
  800624:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8d 40 04             	lea    0x4(%eax),%eax
  80062d:	89 45 14             	mov    %eax,0x14(%ebp)
  800630:	eb 17                	jmp    800649 <.L29+0x3d>
		return va_arg(*ap, long long);
  800632:	8b 45 14             	mov    0x14(%ebp),%eax
  800635:	8b 50 04             	mov    0x4(%eax),%edx
  800638:	8b 00                	mov    (%eax),%eax
  80063a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80063d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8d 40 08             	lea    0x8(%eax),%eax
  800646:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800649:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80064c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  80064f:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800654:	85 db                	test   %ebx,%ebx
  800656:	0f 89 0e 01 00 00    	jns    80076a <.L25+0x2b>
				putch('-', putdat);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	57                   	push   %edi
  800660:	6a 2d                	push   $0x2d
  800662:	ff d6                	call   *%esi
				num = -(long long) num;
  800664:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800667:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80066a:	f7 d9                	neg    %ecx
  80066c:	83 d3 00             	adc    $0x0,%ebx
  80066f:	f7 db                	neg    %ebx
  800671:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800674:	ba 0a 00 00 00       	mov    $0xa,%edx
  800679:	e9 ec 00 00 00       	jmp    80076a <.L25+0x2b>
		return va_arg(*ap, int);
  80067e:	8b 45 14             	mov    0x14(%ebp),%eax
  800681:	8b 00                	mov    (%eax),%eax
  800683:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800686:	99                   	cltd   
  800687:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8d 40 04             	lea    0x4(%eax),%eax
  800690:	89 45 14             	mov    %eax,0x14(%ebp)
  800693:	eb b4                	jmp    800649 <.L29+0x3d>

00800695 <.L23>:
	if (lflag >= 2)
  800695:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800698:	8b 75 08             	mov    0x8(%ebp),%esi
  80069b:	83 f9 01             	cmp    $0x1,%ecx
  80069e:	7f 1e                	jg     8006be <.L23+0x29>
	else if (lflag)
  8006a0:	85 c9                	test   %ecx,%ecx
  8006a2:	74 32                	je     8006d6 <.L23+0x41>
		return va_arg(*ap, unsigned long);
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8b 08                	mov    (%eax),%ecx
  8006a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ae:	8d 40 04             	lea    0x4(%eax),%eax
  8006b1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006b4:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006b9:	e9 ac 00 00 00       	jmp    80076a <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006be:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c1:	8b 08                	mov    (%eax),%ecx
  8006c3:	8b 58 04             	mov    0x4(%eax),%ebx
  8006c6:	8d 40 08             	lea    0x8(%eax),%eax
  8006c9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006cc:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006d1:	e9 94 00 00 00       	jmp    80076a <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8b 08                	mov    (%eax),%ecx
  8006db:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e0:	8d 40 04             	lea    0x4(%eax),%eax
  8006e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006e6:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  8006eb:	eb 7d                	jmp    80076a <.L25+0x2b>

008006ed <.L26>:
	if (lflag >= 2)
  8006ed:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8006f3:	83 f9 01             	cmp    $0x1,%ecx
  8006f6:	7f 1b                	jg     800713 <.L26+0x26>
	else if (lflag)
  8006f8:	85 c9                	test   %ecx,%ecx
  8006fa:	74 2c                	je     800728 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8b 08                	mov    (%eax),%ecx
  800701:	bb 00 00 00 00       	mov    $0x0,%ebx
  800706:	8d 40 04             	lea    0x4(%eax),%eax
  800709:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80070c:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
  800711:	eb 57                	jmp    80076a <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  800713:	8b 45 14             	mov    0x14(%ebp),%eax
  800716:	8b 08                	mov    (%eax),%ecx
  800718:	8b 58 04             	mov    0x4(%eax),%ebx
  80071b:	8d 40 08             	lea    0x8(%eax),%eax
  80071e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800721:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
  800726:	eb 42                	jmp    80076a <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  800728:	8b 45 14             	mov    0x14(%ebp),%eax
  80072b:	8b 08                	mov    (%eax),%ecx
  80072d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800732:	8d 40 04             	lea    0x4(%eax),%eax
  800735:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800738:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
  80073d:	eb 2b                	jmp    80076a <.L25+0x2b>

0080073f <.L25>:
			putch('0', putdat);
  80073f:	8b 75 08             	mov    0x8(%ebp),%esi
  800742:	83 ec 08             	sub    $0x8,%esp
  800745:	57                   	push   %edi
  800746:	6a 30                	push   $0x30
  800748:	ff d6                	call   *%esi
			putch('x', putdat);
  80074a:	83 c4 08             	add    $0x8,%esp
  80074d:	57                   	push   %edi
  80074e:	6a 78                	push   $0x78
  800750:	ff d6                	call   *%esi
			num = (unsigned long long)
  800752:	8b 45 14             	mov    0x14(%ebp),%eax
  800755:	8b 08                	mov    (%eax),%ecx
  800757:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  80075c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80075f:	8d 40 04             	lea    0x4(%eax),%eax
  800762:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800765:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  80076a:	83 ec 0c             	sub    $0xc,%esp
  80076d:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800771:	50                   	push   %eax
  800772:	ff 75 d4             	push   -0x2c(%ebp)
  800775:	52                   	push   %edx
  800776:	53                   	push   %ebx
  800777:	51                   	push   %ecx
  800778:	89 fa                	mov    %edi,%edx
  80077a:	89 f0                	mov    %esi,%eax
  80077c:	e8 f4 fa ff ff       	call   800275 <printnum>
			break;
  800781:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800784:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800787:	e9 15 fc ff ff       	jmp    8003a1 <vprintfmt+0x34>

0080078c <.L21>:
	if (lflag >= 2)
  80078c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80078f:	8b 75 08             	mov    0x8(%ebp),%esi
  800792:	83 f9 01             	cmp    $0x1,%ecx
  800795:	7f 1b                	jg     8007b2 <.L21+0x26>
	else if (lflag)
  800797:	85 c9                	test   %ecx,%ecx
  800799:	74 2c                	je     8007c7 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  80079b:	8b 45 14             	mov    0x14(%ebp),%eax
  80079e:	8b 08                	mov    (%eax),%ecx
  8007a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007a5:	8d 40 04             	lea    0x4(%eax),%eax
  8007a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ab:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  8007b0:	eb b8                	jmp    80076a <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8007b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b5:	8b 08                	mov    (%eax),%ecx
  8007b7:	8b 58 04             	mov    0x4(%eax),%ebx
  8007ba:	8d 40 08             	lea    0x8(%eax),%eax
  8007bd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c0:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8007c5:	eb a3                	jmp    80076a <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8007c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ca:	8b 08                	mov    (%eax),%ecx
  8007cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007d1:	8d 40 04             	lea    0x4(%eax),%eax
  8007d4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d7:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007dc:	eb 8c                	jmp    80076a <.L25+0x2b>

008007de <.L35>:
			putch(ch, putdat);
  8007de:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e1:	83 ec 08             	sub    $0x8,%esp
  8007e4:	57                   	push   %edi
  8007e5:	6a 25                	push   $0x25
  8007e7:	ff d6                	call   *%esi
			break;
  8007e9:	83 c4 10             	add    $0x10,%esp
  8007ec:	eb 96                	jmp    800784 <.L25+0x45>

008007ee <.L20>:
			putch('%', putdat);
  8007ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f1:	83 ec 08             	sub    $0x8,%esp
  8007f4:	57                   	push   %edi
  8007f5:	6a 25                	push   $0x25
  8007f7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f9:	83 c4 10             	add    $0x10,%esp
  8007fc:	89 d8                	mov    %ebx,%eax
  8007fe:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800802:	74 05                	je     800809 <.L20+0x1b>
  800804:	83 e8 01             	sub    $0x1,%eax
  800807:	eb f5                	jmp    8007fe <.L20+0x10>
  800809:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80080c:	e9 73 ff ff ff       	jmp    800784 <.L25+0x45>

00800811 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	53                   	push   %ebx
  800815:	83 ec 14             	sub    $0x14,%esp
  800818:	e8 5e f8 ff ff       	call   80007b <__x86.get_pc_thunk.bx>
  80081d:	81 c3 e3 17 00 00    	add    $0x17e3,%ebx
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800829:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80082c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800830:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800833:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80083a:	85 c0                	test   %eax,%eax
  80083c:	74 2b                	je     800869 <vsnprintf+0x58>
  80083e:	85 d2                	test   %edx,%edx
  800840:	7e 27                	jle    800869 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800842:	ff 75 14             	push   0x14(%ebp)
  800845:	ff 75 10             	push   0x10(%ebp)
  800848:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084b:	50                   	push   %eax
  80084c:	8d 83 33 e3 ff ff    	lea    -0x1ccd(%ebx),%eax
  800852:	50                   	push   %eax
  800853:	e8 15 fb ff ff       	call   80036d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800858:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80085e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800861:	83 c4 10             	add    $0x10,%esp
}
  800864:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800867:	c9                   	leave  
  800868:	c3                   	ret    
		return -E_INVAL;
  800869:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80086e:	eb f4                	jmp    800864 <vsnprintf+0x53>

00800870 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800876:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800879:	50                   	push   %eax
  80087a:	ff 75 10             	push   0x10(%ebp)
  80087d:	ff 75 0c             	push   0xc(%ebp)
  800880:	ff 75 08             	push   0x8(%ebp)
  800883:	e8 89 ff ff ff       	call   800811 <vsnprintf>
	va_end(ap);

	return rc;
}
  800888:	c9                   	leave  
  800889:	c3                   	ret    

0080088a <__x86.get_pc_thunk.cx>:
  80088a:	8b 0c 24             	mov    (%esp),%ecx
  80088d:	c3                   	ret    

0080088e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800894:	b8 00 00 00 00       	mov    $0x0,%eax
  800899:	eb 03                	jmp    80089e <strlen+0x10>
		n++;
  80089b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80089e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a2:	75 f7                	jne    80089b <strlen+0xd>
	return n;
}
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ac:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008af:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b4:	eb 03                	jmp    8008b9 <strnlen+0x13>
		n++;
  8008b6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b9:	39 d0                	cmp    %edx,%eax
  8008bb:	74 08                	je     8008c5 <strnlen+0x1f>
  8008bd:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008c1:	75 f3                	jne    8008b6 <strnlen+0x10>
  8008c3:	89 c2                	mov    %eax,%edx
	return n;
}
  8008c5:	89 d0                	mov    %edx,%eax
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	53                   	push   %ebx
  8008cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008dc:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008df:	83 c0 01             	add    $0x1,%eax
  8008e2:	84 d2                	test   %dl,%dl
  8008e4:	75 f2                	jne    8008d8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008e6:	89 c8                	mov    %ecx,%eax
  8008e8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008eb:	c9                   	leave  
  8008ec:	c3                   	ret    

008008ed <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ed:	55                   	push   %ebp
  8008ee:	89 e5                	mov    %esp,%ebp
  8008f0:	53                   	push   %ebx
  8008f1:	83 ec 10             	sub    $0x10,%esp
  8008f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008f7:	53                   	push   %ebx
  8008f8:	e8 91 ff ff ff       	call   80088e <strlen>
  8008fd:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800900:	ff 75 0c             	push   0xc(%ebp)
  800903:	01 d8                	add    %ebx,%eax
  800905:	50                   	push   %eax
  800906:	e8 be ff ff ff       	call   8008c9 <strcpy>
	return dst;
}
  80090b:	89 d8                	mov    %ebx,%eax
  80090d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800910:	c9                   	leave  
  800911:	c3                   	ret    

00800912 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	56                   	push   %esi
  800916:	53                   	push   %ebx
  800917:	8b 75 08             	mov    0x8(%ebp),%esi
  80091a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091d:	89 f3                	mov    %esi,%ebx
  80091f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800922:	89 f0                	mov    %esi,%eax
  800924:	eb 0f                	jmp    800935 <strncpy+0x23>
		*dst++ = *src;
  800926:	83 c0 01             	add    $0x1,%eax
  800929:	0f b6 0a             	movzbl (%edx),%ecx
  80092c:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80092f:	80 f9 01             	cmp    $0x1,%cl
  800932:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800935:	39 d8                	cmp    %ebx,%eax
  800937:	75 ed                	jne    800926 <strncpy+0x14>
	}
	return ret;
}
  800939:	89 f0                	mov    %esi,%eax
  80093b:	5b                   	pop    %ebx
  80093c:	5e                   	pop    %esi
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
  800942:	56                   	push   %esi
  800943:	53                   	push   %ebx
  800944:	8b 75 08             	mov    0x8(%ebp),%esi
  800947:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094a:	8b 55 10             	mov    0x10(%ebp),%edx
  80094d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80094f:	85 d2                	test   %edx,%edx
  800951:	74 21                	je     800974 <strlcpy+0x35>
  800953:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800957:	89 f2                	mov    %esi,%edx
  800959:	eb 09                	jmp    800964 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80095b:	83 c1 01             	add    $0x1,%ecx
  80095e:	83 c2 01             	add    $0x1,%edx
  800961:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800964:	39 c2                	cmp    %eax,%edx
  800966:	74 09                	je     800971 <strlcpy+0x32>
  800968:	0f b6 19             	movzbl (%ecx),%ebx
  80096b:	84 db                	test   %bl,%bl
  80096d:	75 ec                	jne    80095b <strlcpy+0x1c>
  80096f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800971:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800974:	29 f0                	sub    %esi,%eax
}
  800976:	5b                   	pop    %ebx
  800977:	5e                   	pop    %esi
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800980:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800983:	eb 06                	jmp    80098b <strcmp+0x11>
		p++, q++;
  800985:	83 c1 01             	add    $0x1,%ecx
  800988:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80098b:	0f b6 01             	movzbl (%ecx),%eax
  80098e:	84 c0                	test   %al,%al
  800990:	74 04                	je     800996 <strcmp+0x1c>
  800992:	3a 02                	cmp    (%edx),%al
  800994:	74 ef                	je     800985 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800996:	0f b6 c0             	movzbl %al,%eax
  800999:	0f b6 12             	movzbl (%edx),%edx
  80099c:	29 d0                	sub    %edx,%eax
}
  80099e:	5d                   	pop    %ebp
  80099f:	c3                   	ret    

008009a0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009a0:	55                   	push   %ebp
  8009a1:	89 e5                	mov    %esp,%ebp
  8009a3:	53                   	push   %ebx
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009aa:	89 c3                	mov    %eax,%ebx
  8009ac:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009af:	eb 06                	jmp    8009b7 <strncmp+0x17>
		n--, p++, q++;
  8009b1:	83 c0 01             	add    $0x1,%eax
  8009b4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009b7:	39 d8                	cmp    %ebx,%eax
  8009b9:	74 18                	je     8009d3 <strncmp+0x33>
  8009bb:	0f b6 08             	movzbl (%eax),%ecx
  8009be:	84 c9                	test   %cl,%cl
  8009c0:	74 04                	je     8009c6 <strncmp+0x26>
  8009c2:	3a 0a                	cmp    (%edx),%cl
  8009c4:	74 eb                	je     8009b1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c6:	0f b6 00             	movzbl (%eax),%eax
  8009c9:	0f b6 12             	movzbl (%edx),%edx
  8009cc:	29 d0                	sub    %edx,%eax
}
  8009ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d1:	c9                   	leave  
  8009d2:	c3                   	ret    
		return 0;
  8009d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d8:	eb f4                	jmp    8009ce <strncmp+0x2e>

008009da <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e4:	eb 03                	jmp    8009e9 <strchr+0xf>
  8009e6:	83 c0 01             	add    $0x1,%eax
  8009e9:	0f b6 10             	movzbl (%eax),%edx
  8009ec:	84 d2                	test   %dl,%dl
  8009ee:	74 06                	je     8009f6 <strchr+0x1c>
		if (*s == c)
  8009f0:	38 ca                	cmp    %cl,%dl
  8009f2:	75 f2                	jne    8009e6 <strchr+0xc>
  8009f4:	eb 05                	jmp    8009fb <strchr+0x21>
			return (char *) s;
	return 0;
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fb:	5d                   	pop    %ebp
  8009fc:	c3                   	ret    

008009fd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009fd:	55                   	push   %ebp
  8009fe:	89 e5                	mov    %esp,%ebp
  800a00:	8b 45 08             	mov    0x8(%ebp),%eax
  800a03:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a07:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a0a:	38 ca                	cmp    %cl,%dl
  800a0c:	74 09                	je     800a17 <strfind+0x1a>
  800a0e:	84 d2                	test   %dl,%dl
  800a10:	74 05                	je     800a17 <strfind+0x1a>
	for (; *s; s++)
  800a12:	83 c0 01             	add    $0x1,%eax
  800a15:	eb f0                	jmp    800a07 <strfind+0xa>
			break;
	return (char *) s;
}
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a19:	55                   	push   %ebp
  800a1a:	89 e5                	mov    %esp,%ebp
  800a1c:	57                   	push   %edi
  800a1d:	56                   	push   %esi
  800a1e:	53                   	push   %ebx
  800a1f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a22:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a25:	85 c9                	test   %ecx,%ecx
  800a27:	74 2f                	je     800a58 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a29:	89 f8                	mov    %edi,%eax
  800a2b:	09 c8                	or     %ecx,%eax
  800a2d:	a8 03                	test   $0x3,%al
  800a2f:	75 21                	jne    800a52 <memset+0x39>
		c &= 0xFF;
  800a31:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a35:	89 d0                	mov    %edx,%eax
  800a37:	c1 e0 08             	shl    $0x8,%eax
  800a3a:	89 d3                	mov    %edx,%ebx
  800a3c:	c1 e3 18             	shl    $0x18,%ebx
  800a3f:	89 d6                	mov    %edx,%esi
  800a41:	c1 e6 10             	shl    $0x10,%esi
  800a44:	09 f3                	or     %esi,%ebx
  800a46:	09 da                	or     %ebx,%edx
  800a48:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a4a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a4d:	fc                   	cld    
  800a4e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a50:	eb 06                	jmp    800a58 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a55:	fc                   	cld    
  800a56:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a58:	89 f8                	mov    %edi,%eax
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5f                   	pop    %edi
  800a5d:	5d                   	pop    %ebp
  800a5e:	c3                   	ret    

00800a5f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a5f:	55                   	push   %ebp
  800a60:	89 e5                	mov    %esp,%ebp
  800a62:	57                   	push   %edi
  800a63:	56                   	push   %esi
  800a64:	8b 45 08             	mov    0x8(%ebp),%eax
  800a67:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a6a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a6d:	39 c6                	cmp    %eax,%esi
  800a6f:	73 32                	jae    800aa3 <memmove+0x44>
  800a71:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a74:	39 c2                	cmp    %eax,%edx
  800a76:	76 2b                	jbe    800aa3 <memmove+0x44>
		s += n;
		d += n;
  800a78:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7b:	89 d6                	mov    %edx,%esi
  800a7d:	09 fe                	or     %edi,%esi
  800a7f:	09 ce                	or     %ecx,%esi
  800a81:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a87:	75 0e                	jne    800a97 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a89:	83 ef 04             	sub    $0x4,%edi
  800a8c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a8f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a92:	fd                   	std    
  800a93:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a95:	eb 09                	jmp    800aa0 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a97:	83 ef 01             	sub    $0x1,%edi
  800a9a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a9d:	fd                   	std    
  800a9e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa0:	fc                   	cld    
  800aa1:	eb 1a                	jmp    800abd <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa3:	89 f2                	mov    %esi,%edx
  800aa5:	09 c2                	or     %eax,%edx
  800aa7:	09 ca                	or     %ecx,%edx
  800aa9:	f6 c2 03             	test   $0x3,%dl
  800aac:	75 0a                	jne    800ab8 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800aae:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ab1:	89 c7                	mov    %eax,%edi
  800ab3:	fc                   	cld    
  800ab4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab6:	eb 05                	jmp    800abd <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800ab8:	89 c7                	mov    %eax,%edi
  800aba:	fc                   	cld    
  800abb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800abd:	5e                   	pop    %esi
  800abe:	5f                   	pop    %edi
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ac7:	ff 75 10             	push   0x10(%ebp)
  800aca:	ff 75 0c             	push   0xc(%ebp)
  800acd:	ff 75 08             	push   0x8(%ebp)
  800ad0:	e8 8a ff ff ff       	call   800a5f <memmove>
}
  800ad5:	c9                   	leave  
  800ad6:	c3                   	ret    

00800ad7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad7:	55                   	push   %ebp
  800ad8:	89 e5                	mov    %esp,%ebp
  800ada:	56                   	push   %esi
  800adb:	53                   	push   %ebx
  800adc:	8b 45 08             	mov    0x8(%ebp),%eax
  800adf:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ae2:	89 c6                	mov    %eax,%esi
  800ae4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae7:	eb 06                	jmp    800aef <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800ae9:	83 c0 01             	add    $0x1,%eax
  800aec:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800aef:	39 f0                	cmp    %esi,%eax
  800af1:	74 14                	je     800b07 <memcmp+0x30>
		if (*s1 != *s2)
  800af3:	0f b6 08             	movzbl (%eax),%ecx
  800af6:	0f b6 1a             	movzbl (%edx),%ebx
  800af9:	38 d9                	cmp    %bl,%cl
  800afb:	74 ec                	je     800ae9 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800afd:	0f b6 c1             	movzbl %cl,%eax
  800b00:	0f b6 db             	movzbl %bl,%ebx
  800b03:	29 d8                	sub    %ebx,%eax
  800b05:	eb 05                	jmp    800b0c <memcmp+0x35>
	}

	return 0;
  800b07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5d                   	pop    %ebp
  800b0f:	c3                   	ret    

00800b10 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b10:	55                   	push   %ebp
  800b11:	89 e5                	mov    %esp,%ebp
  800b13:	8b 45 08             	mov    0x8(%ebp),%eax
  800b16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b19:	89 c2                	mov    %eax,%edx
  800b1b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b1e:	eb 03                	jmp    800b23 <memfind+0x13>
  800b20:	83 c0 01             	add    $0x1,%eax
  800b23:	39 d0                	cmp    %edx,%eax
  800b25:	73 04                	jae    800b2b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b27:	38 08                	cmp    %cl,(%eax)
  800b29:	75 f5                	jne    800b20 <memfind+0x10>
			break;
	return (void *) s;
}
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	8b 55 08             	mov    0x8(%ebp),%edx
  800b36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b39:	eb 03                	jmp    800b3e <strtol+0x11>
		s++;
  800b3b:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b3e:	0f b6 02             	movzbl (%edx),%eax
  800b41:	3c 20                	cmp    $0x20,%al
  800b43:	74 f6                	je     800b3b <strtol+0xe>
  800b45:	3c 09                	cmp    $0x9,%al
  800b47:	74 f2                	je     800b3b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b49:	3c 2b                	cmp    $0x2b,%al
  800b4b:	74 2a                	je     800b77 <strtol+0x4a>
	int neg = 0;
  800b4d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b52:	3c 2d                	cmp    $0x2d,%al
  800b54:	74 2b                	je     800b81 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b56:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b5c:	75 0f                	jne    800b6d <strtol+0x40>
  800b5e:	80 3a 30             	cmpb   $0x30,(%edx)
  800b61:	74 28                	je     800b8b <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b63:	85 db                	test   %ebx,%ebx
  800b65:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b6a:	0f 44 d8             	cmove  %eax,%ebx
  800b6d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b72:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b75:	eb 46                	jmp    800bbd <strtol+0x90>
		s++;
  800b77:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b7a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b7f:	eb d5                	jmp    800b56 <strtol+0x29>
		s++, neg = 1;
  800b81:	83 c2 01             	add    $0x1,%edx
  800b84:	bf 01 00 00 00       	mov    $0x1,%edi
  800b89:	eb cb                	jmp    800b56 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b8b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b8f:	74 0e                	je     800b9f <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b91:	85 db                	test   %ebx,%ebx
  800b93:	75 d8                	jne    800b6d <strtol+0x40>
		s++, base = 8;
  800b95:	83 c2 01             	add    $0x1,%edx
  800b98:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b9d:	eb ce                	jmp    800b6d <strtol+0x40>
		s += 2, base = 16;
  800b9f:	83 c2 02             	add    $0x2,%edx
  800ba2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ba7:	eb c4                	jmp    800b6d <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ba9:	0f be c0             	movsbl %al,%eax
  800bac:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800baf:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bb2:	7d 3a                	jge    800bee <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bb4:	83 c2 01             	add    $0x1,%edx
  800bb7:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bbb:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800bbd:	0f b6 02             	movzbl (%edx),%eax
  800bc0:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bc3:	89 f3                	mov    %esi,%ebx
  800bc5:	80 fb 09             	cmp    $0x9,%bl
  800bc8:	76 df                	jbe    800ba9 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bca:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bcd:	89 f3                	mov    %esi,%ebx
  800bcf:	80 fb 19             	cmp    $0x19,%bl
  800bd2:	77 08                	ja     800bdc <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bd4:	0f be c0             	movsbl %al,%eax
  800bd7:	83 e8 57             	sub    $0x57,%eax
  800bda:	eb d3                	jmp    800baf <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bdc:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bdf:	89 f3                	mov    %esi,%ebx
  800be1:	80 fb 19             	cmp    $0x19,%bl
  800be4:	77 08                	ja     800bee <strtol+0xc1>
			dig = *s - 'A' + 10;
  800be6:	0f be c0             	movsbl %al,%eax
  800be9:	83 e8 37             	sub    $0x37,%eax
  800bec:	eb c1                	jmp    800baf <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf2:	74 05                	je     800bf9 <strtol+0xcc>
		*endptr = (char *) s;
  800bf4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bf7:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800bf9:	89 c8                	mov    %ecx,%eax
  800bfb:	f7 d8                	neg    %eax
  800bfd:	85 ff                	test   %edi,%edi
  800bff:	0f 45 c8             	cmovne %eax,%ecx
}
  800c02:	89 c8                	mov    %ecx,%eax
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5f                   	pop    %edi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    
  800c09:	66 90                	xchg   %ax,%ax
  800c0b:	66 90                	xchg   %ax,%ax
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
