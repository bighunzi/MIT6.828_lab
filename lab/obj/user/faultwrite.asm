
obj/user/faultwrite：     文件格式 elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	*(unsigned*)0 = 0;
  800033:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003a:	00 00 00 
}
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	53                   	push   %ebx
  800042:	83 ec 04             	sub    $0x4,%esp
  800045:	e8 39 00 00 00       	call   800083 <__x86.get_pc_thunk.bx>
  80004a:	81 c3 b6 1f 00 00    	add    $0x1fb6,%ebx
  800050:	8b 45 08             	mov    0x8(%ebp),%eax
  800053:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800056:	c7 83 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
  80005d:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 c0                	test   %eax,%eax
  800062:	7e 08                	jle    80006c <libmain+0x2e>
		binaryname = argv[0];
  800064:	8b 0a                	mov    (%edx),%ecx
  800066:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  80006c:	83 ec 08             	sub    $0x8,%esp
  80006f:	52                   	push   %edx
  800070:	50                   	push   %eax
  800071:	e8 bd ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800076:	e8 0c 00 00 00       	call   800087 <exit>
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800081:	c9                   	leave  
  800082:	c3                   	ret    

00800083 <__x86.get_pc_thunk.bx>:
  800083:	8b 1c 24             	mov    (%esp),%ebx
  800086:	c3                   	ret    

00800087 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800087:	55                   	push   %ebp
  800088:	89 e5                	mov    %esp,%ebp
  80008a:	53                   	push   %ebx
  80008b:	83 ec 10             	sub    $0x10,%esp
  80008e:	e8 f0 ff ff ff       	call   800083 <__x86.get_pc_thunk.bx>
  800093:	81 c3 6d 1f 00 00    	add    $0x1f6d,%ebx
	sys_env_destroy(0);
  800099:	6a 00                	push   $0x0
  80009b:	e8 45 00 00 00       	call   8000e5 <sys_env_destroy>
}
  8000a0:	83 c4 10             	add    $0x10,%esp
  8000a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	57                   	push   %edi
  8000ac:	56                   	push   %esi
  8000ad:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b9:	89 c3                	mov    %eax,%ebx
  8000bb:	89 c7                	mov    %eax,%edi
  8000bd:	89 c6                	mov    %eax,%esi
  8000bf:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c1:	5b                   	pop    %ebx
  8000c2:	5e                   	pop    %esi
  8000c3:	5f                   	pop    %edi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	57                   	push   %edi
  8000ca:	56                   	push   %esi
  8000cb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d6:	89 d1                	mov    %edx,%ecx
  8000d8:	89 d3                	mov    %edx,%ebx
  8000da:	89 d7                	mov    %edx,%edi
  8000dc:	89 d6                	mov    %edx,%esi
  8000de:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e0:	5b                   	pop    %ebx
  8000e1:	5e                   	pop    %esi
  8000e2:	5f                   	pop    %edi
  8000e3:	5d                   	pop    %ebp
  8000e4:	c3                   	ret    

008000e5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e5:	55                   	push   %ebp
  8000e6:	89 e5                	mov    %esp,%ebp
  8000e8:	57                   	push   %edi
  8000e9:	56                   	push   %esi
  8000ea:	53                   	push   %ebx
  8000eb:	83 ec 1c             	sub    $0x1c,%esp
  8000ee:	e8 66 00 00 00       	call   800159 <__x86.get_pc_thunk.ax>
  8000f3:	05 0d 1f 00 00       	add    $0x1f0d,%eax
  8000f8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  8000fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800100:	8b 55 08             	mov    0x8(%ebp),%edx
  800103:	b8 03 00 00 00       	mov    $0x3,%eax
  800108:	89 cb                	mov    %ecx,%ebx
  80010a:	89 cf                	mov    %ecx,%edi
  80010c:	89 ce                	mov    %ecx,%esi
  80010e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800110:	85 c0                	test   %eax,%eax
  800112:	7f 08                	jg     80011c <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5f                   	pop    %edi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80011c:	83 ec 0c             	sub    $0xc,%esp
  80011f:	50                   	push   %eax
  800120:	6a 03                	push   $0x3
  800122:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800125:	8d 83 5e ee ff ff    	lea    -0x11a2(%ebx),%eax
  80012b:	50                   	push   %eax
  80012c:	6a 23                	push   $0x23
  80012e:	8d 83 7b ee ff ff    	lea    -0x1185(%ebx),%eax
  800134:	50                   	push   %eax
  800135:	e8 23 00 00 00       	call   80015d <_panic>

0080013a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	57                   	push   %edi
  80013e:	56                   	push   %esi
  80013f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800140:	ba 00 00 00 00       	mov    $0x0,%edx
  800145:	b8 02 00 00 00       	mov    $0x2,%eax
  80014a:	89 d1                	mov    %edx,%ecx
  80014c:	89 d3                	mov    %edx,%ebx
  80014e:	89 d7                	mov    %edx,%edi
  800150:	89 d6                	mov    %edx,%esi
  800152:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800154:	5b                   	pop    %ebx
  800155:	5e                   	pop    %esi
  800156:	5f                   	pop    %edi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    

00800159 <__x86.get_pc_thunk.ax>:
  800159:	8b 04 24             	mov    (%esp),%eax
  80015c:	c3                   	ret    

0080015d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	57                   	push   %edi
  800161:	56                   	push   %esi
  800162:	53                   	push   %ebx
  800163:	83 ec 0c             	sub    $0xc,%esp
  800166:	e8 18 ff ff ff       	call   800083 <__x86.get_pc_thunk.bx>
  80016b:	81 c3 95 1e 00 00    	add    $0x1e95,%ebx
	va_list ap;

	va_start(ap, fmt);
  800171:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800174:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  80017a:	8b 38                	mov    (%eax),%edi
  80017c:	e8 b9 ff ff ff       	call   80013a <sys_getenvid>
  800181:	83 ec 0c             	sub    $0xc,%esp
  800184:	ff 75 0c             	push   0xc(%ebp)
  800187:	ff 75 08             	push   0x8(%ebp)
  80018a:	57                   	push   %edi
  80018b:	50                   	push   %eax
  80018c:	8d 83 8c ee ff ff    	lea    -0x1174(%ebx),%eax
  800192:	50                   	push   %eax
  800193:	e8 d1 00 00 00       	call   800269 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800198:	83 c4 18             	add    $0x18,%esp
  80019b:	56                   	push   %esi
  80019c:	ff 75 10             	push   0x10(%ebp)
  80019f:	e8 63 00 00 00       	call   800207 <vcprintf>
	cprintf("\n");
  8001a4:	8d 83 af ee ff ff    	lea    -0x1151(%ebx),%eax
  8001aa:	89 04 24             	mov    %eax,(%esp)
  8001ad:	e8 b7 00 00 00       	call   800269 <cprintf>
  8001b2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b5:	cc                   	int3   
  8001b6:	eb fd                	jmp    8001b5 <_panic+0x58>

008001b8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	e8 c1 fe ff ff       	call   800083 <__x86.get_pc_thunk.bx>
  8001c2:	81 c3 3e 1e 00 00    	add    $0x1e3e,%ebx
  8001c8:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001cb:	8b 16                	mov    (%esi),%edx
  8001cd:	8d 42 01             	lea    0x1(%edx),%eax
  8001d0:	89 06                	mov    %eax,(%esi)
  8001d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d5:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001d9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001de:	74 0b                	je     8001eb <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001e0:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001e7:	5b                   	pop    %ebx
  8001e8:	5e                   	pop    %esi
  8001e9:	5d                   	pop    %ebp
  8001ea:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	68 ff 00 00 00       	push   $0xff
  8001f3:	8d 46 08             	lea    0x8(%esi),%eax
  8001f6:	50                   	push   %eax
  8001f7:	e8 ac fe ff ff       	call   8000a8 <sys_cputs>
		b->idx = 0;
  8001fc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  800202:	83 c4 10             	add    $0x10,%esp
  800205:	eb d9                	jmp    8001e0 <putch+0x28>

00800207 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800207:	55                   	push   %ebp
  800208:	89 e5                	mov    %esp,%ebp
  80020a:	53                   	push   %ebx
  80020b:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800211:	e8 6d fe ff ff       	call   800083 <__x86.get_pc_thunk.bx>
  800216:	81 c3 ea 1d 00 00    	add    $0x1dea,%ebx
	struct printbuf b;

	b.idx = 0;
  80021c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800223:	00 00 00 
	b.cnt = 0;
  800226:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80022d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800230:	ff 75 0c             	push   0xc(%ebp)
  800233:	ff 75 08             	push   0x8(%ebp)
  800236:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80023c:	50                   	push   %eax
  80023d:	8d 83 b8 e1 ff ff    	lea    -0x1e48(%ebx),%eax
  800243:	50                   	push   %eax
  800244:	e8 2c 01 00 00       	call   800375 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800249:	83 c4 08             	add    $0x8,%esp
  80024c:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800252:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800258:	50                   	push   %eax
  800259:	e8 4a fe ff ff       	call   8000a8 <sys_cputs>

	return b.cnt;
}
  80025e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800264:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800267:	c9                   	leave  
  800268:	c3                   	ret    

00800269 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80026f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800272:	50                   	push   %eax
  800273:	ff 75 08             	push   0x8(%ebp)
  800276:	e8 8c ff ff ff       	call   800207 <vcprintf>
	va_end(ap);

	return cnt;
}
  80027b:	c9                   	leave  
  80027c:	c3                   	ret    

0080027d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80027d:	55                   	push   %ebp
  80027e:	89 e5                	mov    %esp,%ebp
  800280:	57                   	push   %edi
  800281:	56                   	push   %esi
  800282:	53                   	push   %ebx
  800283:	83 ec 2c             	sub    $0x2c,%esp
  800286:	e8 07 06 00 00       	call   800892 <__x86.get_pc_thunk.cx>
  80028b:	81 c1 75 1d 00 00    	add    $0x1d75,%ecx
  800291:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800294:	89 c7                	mov    %eax,%edi
  800296:	89 d6                	mov    %edx,%esi
  800298:	8b 45 08             	mov    0x8(%ebp),%eax
  80029b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80029e:	89 d1                	mov    %edx,%ecx
  8002a0:	89 c2                	mov    %eax,%edx
  8002a2:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002a5:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ab:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002b1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002b8:	39 c2                	cmp    %eax,%edx
  8002ba:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002bd:	72 41                	jb     800300 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002bf:	83 ec 0c             	sub    $0xc,%esp
  8002c2:	ff 75 18             	push   0x18(%ebp)
  8002c5:	83 eb 01             	sub    $0x1,%ebx
  8002c8:	53                   	push   %ebx
  8002c9:	50                   	push   %eax
  8002ca:	83 ec 08             	sub    $0x8,%esp
  8002cd:	ff 75 e4             	push   -0x1c(%ebp)
  8002d0:	ff 75 e0             	push   -0x20(%ebp)
  8002d3:	ff 75 d4             	push   -0x2c(%ebp)
  8002d6:	ff 75 d0             	push   -0x30(%ebp)
  8002d9:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002dc:	e8 3f 09 00 00       	call   800c20 <__udivdi3>
  8002e1:	83 c4 18             	add    $0x18,%esp
  8002e4:	52                   	push   %edx
  8002e5:	50                   	push   %eax
  8002e6:	89 f2                	mov    %esi,%edx
  8002e8:	89 f8                	mov    %edi,%eax
  8002ea:	e8 8e ff ff ff       	call   80027d <printnum>
  8002ef:	83 c4 20             	add    $0x20,%esp
  8002f2:	eb 13                	jmp    800307 <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002f4:	83 ec 08             	sub    $0x8,%esp
  8002f7:	56                   	push   %esi
  8002f8:	ff 75 18             	push   0x18(%ebp)
  8002fb:	ff d7                	call   *%edi
  8002fd:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800300:	83 eb 01             	sub    $0x1,%ebx
  800303:	85 db                	test   %ebx,%ebx
  800305:	7f ed                	jg     8002f4 <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800307:	83 ec 08             	sub    $0x8,%esp
  80030a:	56                   	push   %esi
  80030b:	83 ec 04             	sub    $0x4,%esp
  80030e:	ff 75 e4             	push   -0x1c(%ebp)
  800311:	ff 75 e0             	push   -0x20(%ebp)
  800314:	ff 75 d4             	push   -0x2c(%ebp)
  800317:	ff 75 d0             	push   -0x30(%ebp)
  80031a:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80031d:	e8 1e 0a 00 00       	call   800d40 <__umoddi3>
  800322:	83 c4 14             	add    $0x14,%esp
  800325:	0f be 84 03 b1 ee ff 	movsbl -0x114f(%ebx,%eax,1),%eax
  80032c:	ff 
  80032d:	50                   	push   %eax
  80032e:	ff d7                	call   *%edi
}
  800330:	83 c4 10             	add    $0x10,%esp
  800333:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800336:	5b                   	pop    %ebx
  800337:	5e                   	pop    %esi
  800338:	5f                   	pop    %edi
  800339:	5d                   	pop    %ebp
  80033a:	c3                   	ret    

0080033b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800341:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800345:	8b 10                	mov    (%eax),%edx
  800347:	3b 50 04             	cmp    0x4(%eax),%edx
  80034a:	73 0a                	jae    800356 <sprintputch+0x1b>
		*b->buf++ = ch;
  80034c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80034f:	89 08                	mov    %ecx,(%eax)
  800351:	8b 45 08             	mov    0x8(%ebp),%eax
  800354:	88 02                	mov    %al,(%edx)
}
  800356:	5d                   	pop    %ebp
  800357:	c3                   	ret    

00800358 <printfmt>:
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80035e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800361:	50                   	push   %eax
  800362:	ff 75 10             	push   0x10(%ebp)
  800365:	ff 75 0c             	push   0xc(%ebp)
  800368:	ff 75 08             	push   0x8(%ebp)
  80036b:	e8 05 00 00 00       	call   800375 <vprintfmt>
}
  800370:	83 c4 10             	add    $0x10,%esp
  800373:	c9                   	leave  
  800374:	c3                   	ret    

00800375 <vprintfmt>:
{
  800375:	55                   	push   %ebp
  800376:	89 e5                	mov    %esp,%ebp
  800378:	57                   	push   %edi
  800379:	56                   	push   %esi
  80037a:	53                   	push   %ebx
  80037b:	83 ec 3c             	sub    $0x3c,%esp
  80037e:	e8 d6 fd ff ff       	call   800159 <__x86.get_pc_thunk.ax>
  800383:	05 7d 1c 00 00       	add    $0x1c7d,%eax
  800388:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80038b:	8b 75 08             	mov    0x8(%ebp),%esi
  80038e:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800391:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800394:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  80039a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80039d:	eb 0a                	jmp    8003a9 <vprintfmt+0x34>
			putch(ch, putdat);
  80039f:	83 ec 08             	sub    $0x8,%esp
  8003a2:	57                   	push   %edi
  8003a3:	50                   	push   %eax
  8003a4:	ff d6                	call   *%esi
  8003a6:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a9:	83 c3 01             	add    $0x1,%ebx
  8003ac:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003b0:	83 f8 25             	cmp    $0x25,%eax
  8003b3:	74 0c                	je     8003c1 <vprintfmt+0x4c>
			if (ch == '\0')
  8003b5:	85 c0                	test   %eax,%eax
  8003b7:	75 e6                	jne    80039f <vprintfmt+0x2a>
}
  8003b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003bc:	5b                   	pop    %ebx
  8003bd:	5e                   	pop    %esi
  8003be:	5f                   	pop    %edi
  8003bf:	5d                   	pop    %ebp
  8003c0:	c3                   	ret    
		padc = ' ';
  8003c1:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003c5:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  8003cc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003d3:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  8003da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003df:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003e2:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003e5:	8d 43 01             	lea    0x1(%ebx),%eax
  8003e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003eb:	0f b6 13             	movzbl (%ebx),%edx
  8003ee:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003f1:	3c 55                	cmp    $0x55,%al
  8003f3:	0f 87 fd 03 00 00    	ja     8007f6 <.L20>
  8003f9:	0f b6 c0             	movzbl %al,%eax
  8003fc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003ff:	89 ce                	mov    %ecx,%esi
  800401:	03 b4 81 40 ef ff ff 	add    -0x10c0(%ecx,%eax,4),%esi
  800408:	ff e6                	jmp    *%esi

0080040a <.L68>:
  80040a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  80040d:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800411:	eb d2                	jmp    8003e5 <vprintfmt+0x70>

00800413 <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  800413:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  800416:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  80041a:	eb c9                	jmp    8003e5 <vprintfmt+0x70>

0080041c <.L31>:
  80041c:	0f b6 d2             	movzbl %dl,%edx
  80041f:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  800422:	b8 00 00 00 00       	mov    $0x0,%eax
  800427:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  80042a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80042d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800431:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  800434:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800437:	83 f9 09             	cmp    $0x9,%ecx
  80043a:	77 58                	ja     800494 <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  80043c:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  80043f:	eb e9                	jmp    80042a <.L31+0xe>

00800441 <.L34>:
			precision = va_arg(ap, int);
  800441:	8b 45 14             	mov    0x14(%ebp),%eax
  800444:	8b 00                	mov    (%eax),%eax
  800446:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800449:	8b 45 14             	mov    0x14(%ebp),%eax
  80044c:	8d 40 04             	lea    0x4(%eax),%eax
  80044f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800452:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  800455:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800459:	79 8a                	jns    8003e5 <vprintfmt+0x70>
				width = precision, precision = -1;
  80045b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80045e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800461:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800468:	e9 78 ff ff ff       	jmp    8003e5 <vprintfmt+0x70>

0080046d <.L33>:
  80046d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800470:	85 d2                	test   %edx,%edx
  800472:	b8 00 00 00 00       	mov    $0x0,%eax
  800477:	0f 49 c2             	cmovns %edx,%eax
  80047a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80047d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800480:	e9 60 ff ff ff       	jmp    8003e5 <vprintfmt+0x70>

00800485 <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  800485:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  800488:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  80048f:	e9 51 ff ff ff       	jmp    8003e5 <vprintfmt+0x70>
  800494:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800497:	89 75 08             	mov    %esi,0x8(%ebp)
  80049a:	eb b9                	jmp    800455 <.L34+0x14>

0080049c <.L27>:
			lflag++;
  80049c:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004a0:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004a3:	e9 3d ff ff ff       	jmp    8003e5 <vprintfmt+0x70>

008004a8 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ae:	8d 58 04             	lea    0x4(%eax),%ebx
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	57                   	push   %edi
  8004b5:	ff 30                	push   (%eax)
  8004b7:	ff d6                	call   *%esi
			break;
  8004b9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004bc:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004bf:	e9 c8 02 00 00       	jmp    80078c <.L25+0x45>

008004c4 <.L28>:
			err = va_arg(ap, int);
  8004c4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ca:	8d 58 04             	lea    0x4(%eax),%ebx
  8004cd:	8b 10                	mov    (%eax),%edx
  8004cf:	89 d0                	mov    %edx,%eax
  8004d1:	f7 d8                	neg    %eax
  8004d3:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004d6:	83 f8 06             	cmp    $0x6,%eax
  8004d9:	7f 27                	jg     800502 <.L28+0x3e>
  8004db:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004de:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004e1:	85 d2                	test   %edx,%edx
  8004e3:	74 1d                	je     800502 <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8004e5:	52                   	push   %edx
  8004e6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004e9:	8d 80 d2 ee ff ff    	lea    -0x112e(%eax),%eax
  8004ef:	50                   	push   %eax
  8004f0:	57                   	push   %edi
  8004f1:	56                   	push   %esi
  8004f2:	e8 61 fe ff ff       	call   800358 <printfmt>
  8004f7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8004fa:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004fd:	e9 8a 02 00 00       	jmp    80078c <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  800502:	50                   	push   %eax
  800503:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800506:	8d 80 c9 ee ff ff    	lea    -0x1137(%eax),%eax
  80050c:	50                   	push   %eax
  80050d:	57                   	push   %edi
  80050e:	56                   	push   %esi
  80050f:	e8 44 fe ff ff       	call   800358 <printfmt>
  800514:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800517:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80051a:	e9 6d 02 00 00       	jmp    80078c <.L25+0x45>

0080051f <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  80051f:	8b 75 08             	mov    0x8(%ebp),%esi
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	83 c0 04             	add    $0x4,%eax
  800528:	89 45 c0             	mov    %eax,-0x40(%ebp)
  80052b:	8b 45 14             	mov    0x14(%ebp),%eax
  80052e:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800530:	85 d2                	test   %edx,%edx
  800532:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800535:	8d 80 c2 ee ff ff    	lea    -0x113e(%eax),%eax
  80053b:	0f 45 c2             	cmovne %edx,%eax
  80053e:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800541:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800545:	7e 06                	jle    80054d <.L24+0x2e>
  800547:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  80054b:	75 0d                	jne    80055a <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  80054d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800550:	89 c3                	mov    %eax,%ebx
  800552:	03 45 d4             	add    -0x2c(%ebp),%eax
  800555:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800558:	eb 58                	jmp    8005b2 <.L24+0x93>
  80055a:	83 ec 08             	sub    $0x8,%esp
  80055d:	ff 75 d8             	push   -0x28(%ebp)
  800560:	ff 75 c8             	push   -0x38(%ebp)
  800563:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800566:	e8 43 03 00 00       	call   8008ae <strnlen>
  80056b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  80056e:	29 c2                	sub    %eax,%edx
  800570:	89 55 bc             	mov    %edx,-0x44(%ebp)
  800573:	83 c4 10             	add    $0x10,%esp
  800576:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  800578:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  80057c:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80057f:	eb 0f                	jmp    800590 <.L24+0x71>
					putch(padc, putdat);
  800581:	83 ec 08             	sub    $0x8,%esp
  800584:	57                   	push   %edi
  800585:	ff 75 d4             	push   -0x2c(%ebp)
  800588:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80058a:	83 eb 01             	sub    $0x1,%ebx
  80058d:	83 c4 10             	add    $0x10,%esp
  800590:	85 db                	test   %ebx,%ebx
  800592:	7f ed                	jg     800581 <.L24+0x62>
  800594:	8b 55 bc             	mov    -0x44(%ebp),%edx
  800597:	85 d2                	test   %edx,%edx
  800599:	b8 00 00 00 00       	mov    $0x0,%eax
  80059e:	0f 49 c2             	cmovns %edx,%eax
  8005a1:	29 c2                	sub    %eax,%edx
  8005a3:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005a6:	eb a5                	jmp    80054d <.L24+0x2e>
					putch(ch, putdat);
  8005a8:	83 ec 08             	sub    $0x8,%esp
  8005ab:	57                   	push   %edi
  8005ac:	52                   	push   %edx
  8005ad:	ff d6                	call   *%esi
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005b5:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b7:	83 c3 01             	add    $0x1,%ebx
  8005ba:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005be:	0f be d0             	movsbl %al,%edx
  8005c1:	85 d2                	test   %edx,%edx
  8005c3:	74 4b                	je     800610 <.L24+0xf1>
  8005c5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005c9:	78 06                	js     8005d1 <.L24+0xb2>
  8005cb:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005cf:	78 1e                	js     8005ef <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005d1:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005d5:	74 d1                	je     8005a8 <.L24+0x89>
  8005d7:	0f be c0             	movsbl %al,%eax
  8005da:	83 e8 20             	sub    $0x20,%eax
  8005dd:	83 f8 5e             	cmp    $0x5e,%eax
  8005e0:	76 c6                	jbe    8005a8 <.L24+0x89>
					putch('?', putdat);
  8005e2:	83 ec 08             	sub    $0x8,%esp
  8005e5:	57                   	push   %edi
  8005e6:	6a 3f                	push   $0x3f
  8005e8:	ff d6                	call   *%esi
  8005ea:	83 c4 10             	add    $0x10,%esp
  8005ed:	eb c3                	jmp    8005b2 <.L24+0x93>
  8005ef:	89 cb                	mov    %ecx,%ebx
  8005f1:	eb 0e                	jmp    800601 <.L24+0xe2>
				putch(' ', putdat);
  8005f3:	83 ec 08             	sub    $0x8,%esp
  8005f6:	57                   	push   %edi
  8005f7:	6a 20                	push   $0x20
  8005f9:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8005fb:	83 eb 01             	sub    $0x1,%ebx
  8005fe:	83 c4 10             	add    $0x10,%esp
  800601:	85 db                	test   %ebx,%ebx
  800603:	7f ee                	jg     8005f3 <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  800605:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800608:	89 45 14             	mov    %eax,0x14(%ebp)
  80060b:	e9 7c 01 00 00       	jmp    80078c <.L25+0x45>
  800610:	89 cb                	mov    %ecx,%ebx
  800612:	eb ed                	jmp    800601 <.L24+0xe2>

00800614 <.L29>:
	if (lflag >= 2)
  800614:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800617:	8b 75 08             	mov    0x8(%ebp),%esi
  80061a:	83 f9 01             	cmp    $0x1,%ecx
  80061d:	7f 1b                	jg     80063a <.L29+0x26>
	else if (lflag)
  80061f:	85 c9                	test   %ecx,%ecx
  800621:	74 63                	je     800686 <.L29+0x72>
		return va_arg(*ap, long);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8b 00                	mov    (%eax),%eax
  800628:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062b:	99                   	cltd   
  80062c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80062f:	8b 45 14             	mov    0x14(%ebp),%eax
  800632:	8d 40 04             	lea    0x4(%eax),%eax
  800635:	89 45 14             	mov    %eax,0x14(%ebp)
  800638:	eb 17                	jmp    800651 <.L29+0x3d>
		return va_arg(*ap, long long);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8b 50 04             	mov    0x4(%eax),%edx
  800640:	8b 00                	mov    (%eax),%eax
  800642:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800645:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8d 40 08             	lea    0x8(%eax),%eax
  80064e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800651:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800654:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  800657:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  80065c:	85 db                	test   %ebx,%ebx
  80065e:	0f 89 0e 01 00 00    	jns    800772 <.L25+0x2b>
				putch('-', putdat);
  800664:	83 ec 08             	sub    $0x8,%esp
  800667:	57                   	push   %edi
  800668:	6a 2d                	push   $0x2d
  80066a:	ff d6                	call   *%esi
				num = -(long long) num;
  80066c:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80066f:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800672:	f7 d9                	neg    %ecx
  800674:	83 d3 00             	adc    $0x0,%ebx
  800677:	f7 db                	neg    %ebx
  800679:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80067c:	ba 0a 00 00 00       	mov    $0xa,%edx
  800681:	e9 ec 00 00 00       	jmp    800772 <.L25+0x2b>
		return va_arg(*ap, int);
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8b 00                	mov    (%eax),%eax
  80068b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068e:	99                   	cltd   
  80068f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8d 40 04             	lea    0x4(%eax),%eax
  800698:	89 45 14             	mov    %eax,0x14(%ebp)
  80069b:	eb b4                	jmp    800651 <.L29+0x3d>

0080069d <.L23>:
	if (lflag >= 2)
  80069d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8006a3:	83 f9 01             	cmp    $0x1,%ecx
  8006a6:	7f 1e                	jg     8006c6 <.L23+0x29>
	else if (lflag)
  8006a8:	85 c9                	test   %ecx,%ecx
  8006aa:	74 32                	je     8006de <.L23+0x41>
		return va_arg(*ap, unsigned long);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8b 08                	mov    (%eax),%ecx
  8006b1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006b6:	8d 40 04             	lea    0x4(%eax),%eax
  8006b9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006bc:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006c1:	e9 ac 00 00 00       	jmp    800772 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8b 08                	mov    (%eax),%ecx
  8006cb:	8b 58 04             	mov    0x4(%eax),%ebx
  8006ce:	8d 40 08             	lea    0x8(%eax),%eax
  8006d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d4:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006d9:	e9 94 00 00 00       	jmp    800772 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8b 08                	mov    (%eax),%ecx
  8006e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e8:	8d 40 04             	lea    0x4(%eax),%eax
  8006eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ee:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  8006f3:	eb 7d                	jmp    800772 <.L25+0x2b>

008006f5 <.L26>:
	if (lflag >= 2)
  8006f5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006f8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006fb:	83 f9 01             	cmp    $0x1,%ecx
  8006fe:	7f 1b                	jg     80071b <.L26+0x26>
	else if (lflag)
  800700:	85 c9                	test   %ecx,%ecx
  800702:	74 2c                	je     800730 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
  800704:	8b 45 14             	mov    0x14(%ebp),%eax
  800707:	8b 08                	mov    (%eax),%ecx
  800709:	bb 00 00 00 00       	mov    $0x0,%ebx
  80070e:	8d 40 04             	lea    0x4(%eax),%eax
  800711:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800714:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
  800719:	eb 57                	jmp    800772 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  80071b:	8b 45 14             	mov    0x14(%ebp),%eax
  80071e:	8b 08                	mov    (%eax),%ecx
  800720:	8b 58 04             	mov    0x4(%eax),%ebx
  800723:	8d 40 08             	lea    0x8(%eax),%eax
  800726:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800729:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
  80072e:	eb 42                	jmp    800772 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  800730:	8b 45 14             	mov    0x14(%ebp),%eax
  800733:	8b 08                	mov    (%eax),%ecx
  800735:	bb 00 00 00 00       	mov    $0x0,%ebx
  80073a:	8d 40 04             	lea    0x4(%eax),%eax
  80073d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800740:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
  800745:	eb 2b                	jmp    800772 <.L25+0x2b>

00800747 <.L25>:
			putch('0', putdat);
  800747:	8b 75 08             	mov    0x8(%ebp),%esi
  80074a:	83 ec 08             	sub    $0x8,%esp
  80074d:	57                   	push   %edi
  80074e:	6a 30                	push   $0x30
  800750:	ff d6                	call   *%esi
			putch('x', putdat);
  800752:	83 c4 08             	add    $0x8,%esp
  800755:	57                   	push   %edi
  800756:	6a 78                	push   $0x78
  800758:	ff d6                	call   *%esi
			num = (unsigned long long)
  80075a:	8b 45 14             	mov    0x14(%ebp),%eax
  80075d:	8b 08                	mov    (%eax),%ecx
  80075f:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  800764:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800767:	8d 40 04             	lea    0x4(%eax),%eax
  80076a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80076d:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  800772:	83 ec 0c             	sub    $0xc,%esp
  800775:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800779:	50                   	push   %eax
  80077a:	ff 75 d4             	push   -0x2c(%ebp)
  80077d:	52                   	push   %edx
  80077e:	53                   	push   %ebx
  80077f:	51                   	push   %ecx
  800780:	89 fa                	mov    %edi,%edx
  800782:	89 f0                	mov    %esi,%eax
  800784:	e8 f4 fa ff ff       	call   80027d <printnum>
			break;
  800789:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80078c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80078f:	e9 15 fc ff ff       	jmp    8003a9 <vprintfmt+0x34>

00800794 <.L21>:
	if (lflag >= 2)
  800794:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800797:	8b 75 08             	mov    0x8(%ebp),%esi
  80079a:	83 f9 01             	cmp    $0x1,%ecx
  80079d:	7f 1b                	jg     8007ba <.L21+0x26>
	else if (lflag)
  80079f:	85 c9                	test   %ecx,%ecx
  8007a1:	74 2c                	je     8007cf <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  8007a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a6:	8b 08                	mov    (%eax),%ecx
  8007a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007ad:	8d 40 04             	lea    0x4(%eax),%eax
  8007b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007b3:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  8007b8:	eb b8                	jmp    800772 <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8007ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bd:	8b 08                	mov    (%eax),%ecx
  8007bf:	8b 58 04             	mov    0x4(%eax),%ebx
  8007c2:	8d 40 08             	lea    0x8(%eax),%eax
  8007c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007c8:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8007cd:	eb a3                	jmp    800772 <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8b 08                	mov    (%eax),%ecx
  8007d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007d9:	8d 40 04             	lea    0x4(%eax),%eax
  8007dc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007df:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007e4:	eb 8c                	jmp    800772 <.L25+0x2b>

008007e6 <.L35>:
			putch(ch, putdat);
  8007e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007e9:	83 ec 08             	sub    $0x8,%esp
  8007ec:	57                   	push   %edi
  8007ed:	6a 25                	push   $0x25
  8007ef:	ff d6                	call   *%esi
			break;
  8007f1:	83 c4 10             	add    $0x10,%esp
  8007f4:	eb 96                	jmp    80078c <.L25+0x45>

008007f6 <.L20>:
			putch('%', putdat);
  8007f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f9:	83 ec 08             	sub    $0x8,%esp
  8007fc:	57                   	push   %edi
  8007fd:	6a 25                	push   $0x25
  8007ff:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800801:	83 c4 10             	add    $0x10,%esp
  800804:	89 d8                	mov    %ebx,%eax
  800806:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80080a:	74 05                	je     800811 <.L20+0x1b>
  80080c:	83 e8 01             	sub    $0x1,%eax
  80080f:	eb f5                	jmp    800806 <.L20+0x10>
  800811:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800814:	e9 73 ff ff ff       	jmp    80078c <.L25+0x45>

00800819 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800819:	55                   	push   %ebp
  80081a:	89 e5                	mov    %esp,%ebp
  80081c:	53                   	push   %ebx
  80081d:	83 ec 14             	sub    $0x14,%esp
  800820:	e8 5e f8 ff ff       	call   800083 <__x86.get_pc_thunk.bx>
  800825:	81 c3 db 17 00 00    	add    $0x17db,%ebx
  80082b:	8b 45 08             	mov    0x8(%ebp),%eax
  80082e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800831:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800834:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800838:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80083b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800842:	85 c0                	test   %eax,%eax
  800844:	74 2b                	je     800871 <vsnprintf+0x58>
  800846:	85 d2                	test   %edx,%edx
  800848:	7e 27                	jle    800871 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80084a:	ff 75 14             	push   0x14(%ebp)
  80084d:	ff 75 10             	push   0x10(%ebp)
  800850:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800853:	50                   	push   %eax
  800854:	8d 83 3b e3 ff ff    	lea    -0x1cc5(%ebx),%eax
  80085a:	50                   	push   %eax
  80085b:	e8 15 fb ff ff       	call   800375 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800860:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800863:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800866:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800869:	83 c4 10             	add    $0x10,%esp
}
  80086c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80086f:	c9                   	leave  
  800870:	c3                   	ret    
		return -E_INVAL;
  800871:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800876:	eb f4                	jmp    80086c <vsnprintf+0x53>

00800878 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800878:	55                   	push   %ebp
  800879:	89 e5                	mov    %esp,%ebp
  80087b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80087e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800881:	50                   	push   %eax
  800882:	ff 75 10             	push   0x10(%ebp)
  800885:	ff 75 0c             	push   0xc(%ebp)
  800888:	ff 75 08             	push   0x8(%ebp)
  80088b:	e8 89 ff ff ff       	call   800819 <vsnprintf>
	va_end(ap);

	return rc;
}
  800890:	c9                   	leave  
  800891:	c3                   	ret    

00800892 <__x86.get_pc_thunk.cx>:
  800892:	8b 0c 24             	mov    (%esp),%ecx
  800895:	c3                   	ret    

00800896 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80089c:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a1:	eb 03                	jmp    8008a6 <strlen+0x10>
		n++;
  8008a3:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008a6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008aa:	75 f7                	jne    8008a3 <strlen+0xd>
	return n;
}
  8008ac:	5d                   	pop    %ebp
  8008ad:	c3                   	ret    

008008ae <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008b4:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8008bc:	eb 03                	jmp    8008c1 <strnlen+0x13>
		n++;
  8008be:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c1:	39 d0                	cmp    %edx,%eax
  8008c3:	74 08                	je     8008cd <strnlen+0x1f>
  8008c5:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008c9:	75 f3                	jne    8008be <strnlen+0x10>
  8008cb:	89 c2                	mov    %eax,%edx
	return n;
}
  8008cd:	89 d0                	mov    %edx,%eax
  8008cf:	5d                   	pop    %ebp
  8008d0:	c3                   	ret    

008008d1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d1:	55                   	push   %ebp
  8008d2:	89 e5                	mov    %esp,%ebp
  8008d4:	53                   	push   %ebx
  8008d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008db:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e0:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008e4:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008e7:	83 c0 01             	add    $0x1,%eax
  8008ea:	84 d2                	test   %dl,%dl
  8008ec:	75 f2                	jne    8008e0 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008ee:	89 c8                	mov    %ecx,%eax
  8008f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008f3:	c9                   	leave  
  8008f4:	c3                   	ret    

008008f5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008f5:	55                   	push   %ebp
  8008f6:	89 e5                	mov    %esp,%ebp
  8008f8:	53                   	push   %ebx
  8008f9:	83 ec 10             	sub    $0x10,%esp
  8008fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008ff:	53                   	push   %ebx
  800900:	e8 91 ff ff ff       	call   800896 <strlen>
  800905:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800908:	ff 75 0c             	push   0xc(%ebp)
  80090b:	01 d8                	add    %ebx,%eax
  80090d:	50                   	push   %eax
  80090e:	e8 be ff ff ff       	call   8008d1 <strcpy>
	return dst;
}
  800913:	89 d8                	mov    %ebx,%eax
  800915:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800918:	c9                   	leave  
  800919:	c3                   	ret    

0080091a <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	56                   	push   %esi
  80091e:	53                   	push   %ebx
  80091f:	8b 75 08             	mov    0x8(%ebp),%esi
  800922:	8b 55 0c             	mov    0xc(%ebp),%edx
  800925:	89 f3                	mov    %esi,%ebx
  800927:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80092a:	89 f0                	mov    %esi,%eax
  80092c:	eb 0f                	jmp    80093d <strncpy+0x23>
		*dst++ = *src;
  80092e:	83 c0 01             	add    $0x1,%eax
  800931:	0f b6 0a             	movzbl (%edx),%ecx
  800934:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800937:	80 f9 01             	cmp    $0x1,%cl
  80093a:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80093d:	39 d8                	cmp    %ebx,%eax
  80093f:	75 ed                	jne    80092e <strncpy+0x14>
	}
	return ret;
}
  800941:	89 f0                	mov    %esi,%eax
  800943:	5b                   	pop    %ebx
  800944:	5e                   	pop    %esi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	56                   	push   %esi
  80094b:	53                   	push   %ebx
  80094c:	8b 75 08             	mov    0x8(%ebp),%esi
  80094f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800952:	8b 55 10             	mov    0x10(%ebp),%edx
  800955:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800957:	85 d2                	test   %edx,%edx
  800959:	74 21                	je     80097c <strlcpy+0x35>
  80095b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80095f:	89 f2                	mov    %esi,%edx
  800961:	eb 09                	jmp    80096c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800963:	83 c1 01             	add    $0x1,%ecx
  800966:	83 c2 01             	add    $0x1,%edx
  800969:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80096c:	39 c2                	cmp    %eax,%edx
  80096e:	74 09                	je     800979 <strlcpy+0x32>
  800970:	0f b6 19             	movzbl (%ecx),%ebx
  800973:	84 db                	test   %bl,%bl
  800975:	75 ec                	jne    800963 <strlcpy+0x1c>
  800977:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800979:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80097c:	29 f0                	sub    %esi,%eax
}
  80097e:	5b                   	pop    %ebx
  80097f:	5e                   	pop    %esi
  800980:	5d                   	pop    %ebp
  800981:	c3                   	ret    

00800982 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800982:	55                   	push   %ebp
  800983:	89 e5                	mov    %esp,%ebp
  800985:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800988:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80098b:	eb 06                	jmp    800993 <strcmp+0x11>
		p++, q++;
  80098d:	83 c1 01             	add    $0x1,%ecx
  800990:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800993:	0f b6 01             	movzbl (%ecx),%eax
  800996:	84 c0                	test   %al,%al
  800998:	74 04                	je     80099e <strcmp+0x1c>
  80099a:	3a 02                	cmp    (%edx),%al
  80099c:	74 ef                	je     80098d <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80099e:	0f b6 c0             	movzbl %al,%eax
  8009a1:	0f b6 12             	movzbl (%edx),%edx
  8009a4:	29 d0                	sub    %edx,%eax
}
  8009a6:	5d                   	pop    %ebp
  8009a7:	c3                   	ret    

008009a8 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009a8:	55                   	push   %ebp
  8009a9:	89 e5                	mov    %esp,%ebp
  8009ab:	53                   	push   %ebx
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b2:	89 c3                	mov    %eax,%ebx
  8009b4:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009b7:	eb 06                	jmp    8009bf <strncmp+0x17>
		n--, p++, q++;
  8009b9:	83 c0 01             	add    $0x1,%eax
  8009bc:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009bf:	39 d8                	cmp    %ebx,%eax
  8009c1:	74 18                	je     8009db <strncmp+0x33>
  8009c3:	0f b6 08             	movzbl (%eax),%ecx
  8009c6:	84 c9                	test   %cl,%cl
  8009c8:	74 04                	je     8009ce <strncmp+0x26>
  8009ca:	3a 0a                	cmp    (%edx),%cl
  8009cc:	74 eb                	je     8009b9 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ce:	0f b6 00             	movzbl (%eax),%eax
  8009d1:	0f b6 12             	movzbl (%edx),%edx
  8009d4:	29 d0                	sub    %edx,%eax
}
  8009d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d9:	c9                   	leave  
  8009da:	c3                   	ret    
		return 0;
  8009db:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e0:	eb f4                	jmp    8009d6 <strncmp+0x2e>

008009e2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e2:	55                   	push   %ebp
  8009e3:	89 e5                	mov    %esp,%ebp
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009ec:	eb 03                	jmp    8009f1 <strchr+0xf>
  8009ee:	83 c0 01             	add    $0x1,%eax
  8009f1:	0f b6 10             	movzbl (%eax),%edx
  8009f4:	84 d2                	test   %dl,%dl
  8009f6:	74 06                	je     8009fe <strchr+0x1c>
		if (*s == c)
  8009f8:	38 ca                	cmp    %cl,%dl
  8009fa:	75 f2                	jne    8009ee <strchr+0xc>
  8009fc:	eb 05                	jmp    800a03 <strchr+0x21>
			return (char *) s;
	return 0;
  8009fe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a0f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a12:	38 ca                	cmp    %cl,%dl
  800a14:	74 09                	je     800a1f <strfind+0x1a>
  800a16:	84 d2                	test   %dl,%dl
  800a18:	74 05                	je     800a1f <strfind+0x1a>
	for (; *s; s++)
  800a1a:	83 c0 01             	add    $0x1,%eax
  800a1d:	eb f0                	jmp    800a0f <strfind+0xa>
			break;
	return (char *) s;
}
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	57                   	push   %edi
  800a25:	56                   	push   %esi
  800a26:	53                   	push   %ebx
  800a27:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a2a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a2d:	85 c9                	test   %ecx,%ecx
  800a2f:	74 2f                	je     800a60 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a31:	89 f8                	mov    %edi,%eax
  800a33:	09 c8                	or     %ecx,%eax
  800a35:	a8 03                	test   $0x3,%al
  800a37:	75 21                	jne    800a5a <memset+0x39>
		c &= 0xFF;
  800a39:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a3d:	89 d0                	mov    %edx,%eax
  800a3f:	c1 e0 08             	shl    $0x8,%eax
  800a42:	89 d3                	mov    %edx,%ebx
  800a44:	c1 e3 18             	shl    $0x18,%ebx
  800a47:	89 d6                	mov    %edx,%esi
  800a49:	c1 e6 10             	shl    $0x10,%esi
  800a4c:	09 f3                	or     %esi,%ebx
  800a4e:	09 da                	or     %ebx,%edx
  800a50:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a52:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a55:	fc                   	cld    
  800a56:	f3 ab                	rep stos %eax,%es:(%edi)
  800a58:	eb 06                	jmp    800a60 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5d:	fc                   	cld    
  800a5e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a60:	89 f8                	mov    %edi,%eax
  800a62:	5b                   	pop    %ebx
  800a63:	5e                   	pop    %esi
  800a64:	5f                   	pop    %edi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	57                   	push   %edi
  800a6b:	56                   	push   %esi
  800a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a72:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a75:	39 c6                	cmp    %eax,%esi
  800a77:	73 32                	jae    800aab <memmove+0x44>
  800a79:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a7c:	39 c2                	cmp    %eax,%edx
  800a7e:	76 2b                	jbe    800aab <memmove+0x44>
		s += n;
		d += n;
  800a80:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a83:	89 d6                	mov    %edx,%esi
  800a85:	09 fe                	or     %edi,%esi
  800a87:	09 ce                	or     %ecx,%esi
  800a89:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a8f:	75 0e                	jne    800a9f <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a91:	83 ef 04             	sub    $0x4,%edi
  800a94:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a97:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a9a:	fd                   	std    
  800a9b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a9d:	eb 09                	jmp    800aa8 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a9f:	83 ef 01             	sub    $0x1,%edi
  800aa2:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aa5:	fd                   	std    
  800aa6:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa8:	fc                   	cld    
  800aa9:	eb 1a                	jmp    800ac5 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aab:	89 f2                	mov    %esi,%edx
  800aad:	09 c2                	or     %eax,%edx
  800aaf:	09 ca                	or     %ecx,%edx
  800ab1:	f6 c2 03             	test   $0x3,%dl
  800ab4:	75 0a                	jne    800ac0 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ab6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ab9:	89 c7                	mov    %eax,%edi
  800abb:	fc                   	cld    
  800abc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800abe:	eb 05                	jmp    800ac5 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800ac0:	89 c7                	mov    %eax,%edi
  800ac2:	fc                   	cld    
  800ac3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac5:	5e                   	pop    %esi
  800ac6:	5f                   	pop    %edi
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800acf:	ff 75 10             	push   0x10(%ebp)
  800ad2:	ff 75 0c             	push   0xc(%ebp)
  800ad5:	ff 75 08             	push   0x8(%ebp)
  800ad8:	e8 8a ff ff ff       	call   800a67 <memmove>
}
  800add:	c9                   	leave  
  800ade:	c3                   	ret    

00800adf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800adf:	55                   	push   %ebp
  800ae0:	89 e5                	mov    %esp,%ebp
  800ae2:	56                   	push   %esi
  800ae3:	53                   	push   %ebx
  800ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aea:	89 c6                	mov    %eax,%esi
  800aec:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aef:	eb 06                	jmp    800af7 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800af1:	83 c0 01             	add    $0x1,%eax
  800af4:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800af7:	39 f0                	cmp    %esi,%eax
  800af9:	74 14                	je     800b0f <memcmp+0x30>
		if (*s1 != *s2)
  800afb:	0f b6 08             	movzbl (%eax),%ecx
  800afe:	0f b6 1a             	movzbl (%edx),%ebx
  800b01:	38 d9                	cmp    %bl,%cl
  800b03:	74 ec                	je     800af1 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b05:	0f b6 c1             	movzbl %cl,%eax
  800b08:	0f b6 db             	movzbl %bl,%ebx
  800b0b:	29 d8                	sub    %ebx,%eax
  800b0d:	eb 05                	jmp    800b14 <memcmp+0x35>
	}

	return 0;
  800b0f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b14:	5b                   	pop    %ebx
  800b15:	5e                   	pop    %esi
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b21:	89 c2                	mov    %eax,%edx
  800b23:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b26:	eb 03                	jmp    800b2b <memfind+0x13>
  800b28:	83 c0 01             	add    $0x1,%eax
  800b2b:	39 d0                	cmp    %edx,%eax
  800b2d:	73 04                	jae    800b33 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b2f:	38 08                	cmp    %cl,(%eax)
  800b31:	75 f5                	jne    800b28 <memfind+0x10>
			break;
	return (void *) s;
}
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	57                   	push   %edi
  800b39:	56                   	push   %esi
  800b3a:	53                   	push   %ebx
  800b3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800b3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b41:	eb 03                	jmp    800b46 <strtol+0x11>
		s++;
  800b43:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b46:	0f b6 02             	movzbl (%edx),%eax
  800b49:	3c 20                	cmp    $0x20,%al
  800b4b:	74 f6                	je     800b43 <strtol+0xe>
  800b4d:	3c 09                	cmp    $0x9,%al
  800b4f:	74 f2                	je     800b43 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b51:	3c 2b                	cmp    $0x2b,%al
  800b53:	74 2a                	je     800b7f <strtol+0x4a>
	int neg = 0;
  800b55:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b5a:	3c 2d                	cmp    $0x2d,%al
  800b5c:	74 2b                	je     800b89 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b5e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b64:	75 0f                	jne    800b75 <strtol+0x40>
  800b66:	80 3a 30             	cmpb   $0x30,(%edx)
  800b69:	74 28                	je     800b93 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b6b:	85 db                	test   %ebx,%ebx
  800b6d:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b72:	0f 44 d8             	cmove  %eax,%ebx
  800b75:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b7a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b7d:	eb 46                	jmp    800bc5 <strtol+0x90>
		s++;
  800b7f:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b82:	bf 00 00 00 00       	mov    $0x0,%edi
  800b87:	eb d5                	jmp    800b5e <strtol+0x29>
		s++, neg = 1;
  800b89:	83 c2 01             	add    $0x1,%edx
  800b8c:	bf 01 00 00 00       	mov    $0x1,%edi
  800b91:	eb cb                	jmp    800b5e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b93:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b97:	74 0e                	je     800ba7 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800b99:	85 db                	test   %ebx,%ebx
  800b9b:	75 d8                	jne    800b75 <strtol+0x40>
		s++, base = 8;
  800b9d:	83 c2 01             	add    $0x1,%edx
  800ba0:	bb 08 00 00 00       	mov    $0x8,%ebx
  800ba5:	eb ce                	jmp    800b75 <strtol+0x40>
		s += 2, base = 16;
  800ba7:	83 c2 02             	add    $0x2,%edx
  800baa:	bb 10 00 00 00       	mov    $0x10,%ebx
  800baf:	eb c4                	jmp    800b75 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bb1:	0f be c0             	movsbl %al,%eax
  800bb4:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bb7:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bba:	7d 3a                	jge    800bf6 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bbc:	83 c2 01             	add    $0x1,%edx
  800bbf:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bc3:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800bc5:	0f b6 02             	movzbl (%edx),%eax
  800bc8:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bcb:	89 f3                	mov    %esi,%ebx
  800bcd:	80 fb 09             	cmp    $0x9,%bl
  800bd0:	76 df                	jbe    800bb1 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bd2:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bd5:	89 f3                	mov    %esi,%ebx
  800bd7:	80 fb 19             	cmp    $0x19,%bl
  800bda:	77 08                	ja     800be4 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bdc:	0f be c0             	movsbl %al,%eax
  800bdf:	83 e8 57             	sub    $0x57,%eax
  800be2:	eb d3                	jmp    800bb7 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800be4:	8d 70 bf             	lea    -0x41(%eax),%esi
  800be7:	89 f3                	mov    %esi,%ebx
  800be9:	80 fb 19             	cmp    $0x19,%bl
  800bec:	77 08                	ja     800bf6 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bee:	0f be c0             	movsbl %al,%eax
  800bf1:	83 e8 37             	sub    $0x37,%eax
  800bf4:	eb c1                	jmp    800bb7 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bf6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bfa:	74 05                	je     800c01 <strtol+0xcc>
		*endptr = (char *) s;
  800bfc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bff:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c01:	89 c8                	mov    %ecx,%eax
  800c03:	f7 d8                	neg    %eax
  800c05:	85 ff                	test   %edi,%edi
  800c07:	0f 45 c8             	cmovne %eax,%ecx
}
  800c0a:	89 c8                	mov    %ecx,%eax
  800c0c:	5b                   	pop    %ebx
  800c0d:	5e                   	pop    %esi
  800c0e:	5f                   	pop    %edi
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    
  800c11:	66 90                	xchg   %ax,%ax
  800c13:	66 90                	xchg   %ax,%ax
  800c15:	66 90                	xchg   %ax,%ax
  800c17:	66 90                	xchg   %ax,%ax
  800c19:	66 90                	xchg   %ax,%ax
  800c1b:	66 90                	xchg   %ax,%ax
  800c1d:	66 90                	xchg   %ax,%ax
  800c1f:	90                   	nop

00800c20 <__udivdi3>:
  800c20:	f3 0f 1e fb          	endbr32 
  800c24:	55                   	push   %ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	83 ec 1c             	sub    $0x1c,%esp
  800c2b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c2f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c33:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c37:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	75 19                	jne    800c58 <__udivdi3+0x38>
  800c3f:	39 f3                	cmp    %esi,%ebx
  800c41:	76 4d                	jbe    800c90 <__udivdi3+0x70>
  800c43:	31 ff                	xor    %edi,%edi
  800c45:	89 e8                	mov    %ebp,%eax
  800c47:	89 f2                	mov    %esi,%edx
  800c49:	f7 f3                	div    %ebx
  800c4b:	89 fa                	mov    %edi,%edx
  800c4d:	83 c4 1c             	add    $0x1c,%esp
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    
  800c55:	8d 76 00             	lea    0x0(%esi),%esi
  800c58:	39 f0                	cmp    %esi,%eax
  800c5a:	76 14                	jbe    800c70 <__udivdi3+0x50>
  800c5c:	31 ff                	xor    %edi,%edi
  800c5e:	31 c0                	xor    %eax,%eax
  800c60:	89 fa                	mov    %edi,%edx
  800c62:	83 c4 1c             	add    $0x1c,%esp
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    
  800c6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c70:	0f bd f8             	bsr    %eax,%edi
  800c73:	83 f7 1f             	xor    $0x1f,%edi
  800c76:	75 48                	jne    800cc0 <__udivdi3+0xa0>
  800c78:	39 f0                	cmp    %esi,%eax
  800c7a:	72 06                	jb     800c82 <__udivdi3+0x62>
  800c7c:	31 c0                	xor    %eax,%eax
  800c7e:	39 eb                	cmp    %ebp,%ebx
  800c80:	77 de                	ja     800c60 <__udivdi3+0x40>
  800c82:	b8 01 00 00 00       	mov    $0x1,%eax
  800c87:	eb d7                	jmp    800c60 <__udivdi3+0x40>
  800c89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800c90:	89 d9                	mov    %ebx,%ecx
  800c92:	85 db                	test   %ebx,%ebx
  800c94:	75 0b                	jne    800ca1 <__udivdi3+0x81>
  800c96:	b8 01 00 00 00       	mov    $0x1,%eax
  800c9b:	31 d2                	xor    %edx,%edx
  800c9d:	f7 f3                	div    %ebx
  800c9f:	89 c1                	mov    %eax,%ecx
  800ca1:	31 d2                	xor    %edx,%edx
  800ca3:	89 f0                	mov    %esi,%eax
  800ca5:	f7 f1                	div    %ecx
  800ca7:	89 c6                	mov    %eax,%esi
  800ca9:	89 e8                	mov    %ebp,%eax
  800cab:	89 f7                	mov    %esi,%edi
  800cad:	f7 f1                	div    %ecx
  800caf:	89 fa                	mov    %edi,%edx
  800cb1:	83 c4 1c             	add    $0x1c,%esp
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    
  800cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cc0:	89 f9                	mov    %edi,%ecx
  800cc2:	ba 20 00 00 00       	mov    $0x20,%edx
  800cc7:	29 fa                	sub    %edi,%edx
  800cc9:	d3 e0                	shl    %cl,%eax
  800ccb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ccf:	89 d1                	mov    %edx,%ecx
  800cd1:	89 d8                	mov    %ebx,%eax
  800cd3:	d3 e8                	shr    %cl,%eax
  800cd5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800cd9:	09 c1                	or     %eax,%ecx
  800cdb:	89 f0                	mov    %esi,%eax
  800cdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ce1:	89 f9                	mov    %edi,%ecx
  800ce3:	d3 e3                	shl    %cl,%ebx
  800ce5:	89 d1                	mov    %edx,%ecx
  800ce7:	d3 e8                	shr    %cl,%eax
  800ce9:	89 f9                	mov    %edi,%ecx
  800ceb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cef:	89 eb                	mov    %ebp,%ebx
  800cf1:	d3 e6                	shl    %cl,%esi
  800cf3:	89 d1                	mov    %edx,%ecx
  800cf5:	d3 eb                	shr    %cl,%ebx
  800cf7:	09 f3                	or     %esi,%ebx
  800cf9:	89 c6                	mov    %eax,%esi
  800cfb:	89 f2                	mov    %esi,%edx
  800cfd:	89 d8                	mov    %ebx,%eax
  800cff:	f7 74 24 08          	divl   0x8(%esp)
  800d03:	89 d6                	mov    %edx,%esi
  800d05:	89 c3                	mov    %eax,%ebx
  800d07:	f7 64 24 0c          	mull   0xc(%esp)
  800d0b:	39 d6                	cmp    %edx,%esi
  800d0d:	72 19                	jb     800d28 <__udivdi3+0x108>
  800d0f:	89 f9                	mov    %edi,%ecx
  800d11:	d3 e5                	shl    %cl,%ebp
  800d13:	39 c5                	cmp    %eax,%ebp
  800d15:	73 04                	jae    800d1b <__udivdi3+0xfb>
  800d17:	39 d6                	cmp    %edx,%esi
  800d19:	74 0d                	je     800d28 <__udivdi3+0x108>
  800d1b:	89 d8                	mov    %ebx,%eax
  800d1d:	31 ff                	xor    %edi,%edi
  800d1f:	e9 3c ff ff ff       	jmp    800c60 <__udivdi3+0x40>
  800d24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d28:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d2b:	31 ff                	xor    %edi,%edi
  800d2d:	e9 2e ff ff ff       	jmp    800c60 <__udivdi3+0x40>
  800d32:	66 90                	xchg   %ax,%ax
  800d34:	66 90                	xchg   %ax,%ax
  800d36:	66 90                	xchg   %ax,%ax
  800d38:	66 90                	xchg   %ax,%ax
  800d3a:	66 90                	xchg   %ax,%ax
  800d3c:	66 90                	xchg   %ax,%ax
  800d3e:	66 90                	xchg   %ax,%ax

00800d40 <__umoddi3>:
  800d40:	f3 0f 1e fb          	endbr32 
  800d44:	55                   	push   %ebp
  800d45:	57                   	push   %edi
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	83 ec 1c             	sub    $0x1c,%esp
  800d4b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d4f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d53:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800d57:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800d5b:	89 f0                	mov    %esi,%eax
  800d5d:	89 da                	mov    %ebx,%edx
  800d5f:	85 ff                	test   %edi,%edi
  800d61:	75 15                	jne    800d78 <__umoddi3+0x38>
  800d63:	39 dd                	cmp    %ebx,%ebp
  800d65:	76 39                	jbe    800da0 <__umoddi3+0x60>
  800d67:	f7 f5                	div    %ebp
  800d69:	89 d0                	mov    %edx,%eax
  800d6b:	31 d2                	xor    %edx,%edx
  800d6d:	83 c4 1c             	add    $0x1c,%esp
  800d70:	5b                   	pop    %ebx
  800d71:	5e                   	pop    %esi
  800d72:	5f                   	pop    %edi
  800d73:	5d                   	pop    %ebp
  800d74:	c3                   	ret    
  800d75:	8d 76 00             	lea    0x0(%esi),%esi
  800d78:	39 df                	cmp    %ebx,%edi
  800d7a:	77 f1                	ja     800d6d <__umoddi3+0x2d>
  800d7c:	0f bd cf             	bsr    %edi,%ecx
  800d7f:	83 f1 1f             	xor    $0x1f,%ecx
  800d82:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d86:	75 40                	jne    800dc8 <__umoddi3+0x88>
  800d88:	39 df                	cmp    %ebx,%edi
  800d8a:	72 04                	jb     800d90 <__umoddi3+0x50>
  800d8c:	39 f5                	cmp    %esi,%ebp
  800d8e:	77 dd                	ja     800d6d <__umoddi3+0x2d>
  800d90:	89 da                	mov    %ebx,%edx
  800d92:	89 f0                	mov    %esi,%eax
  800d94:	29 e8                	sub    %ebp,%eax
  800d96:	19 fa                	sbb    %edi,%edx
  800d98:	eb d3                	jmp    800d6d <__umoddi3+0x2d>
  800d9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800da0:	89 e9                	mov    %ebp,%ecx
  800da2:	85 ed                	test   %ebp,%ebp
  800da4:	75 0b                	jne    800db1 <__umoddi3+0x71>
  800da6:	b8 01 00 00 00       	mov    $0x1,%eax
  800dab:	31 d2                	xor    %edx,%edx
  800dad:	f7 f5                	div    %ebp
  800daf:	89 c1                	mov    %eax,%ecx
  800db1:	89 d8                	mov    %ebx,%eax
  800db3:	31 d2                	xor    %edx,%edx
  800db5:	f7 f1                	div    %ecx
  800db7:	89 f0                	mov    %esi,%eax
  800db9:	f7 f1                	div    %ecx
  800dbb:	89 d0                	mov    %edx,%eax
  800dbd:	31 d2                	xor    %edx,%edx
  800dbf:	eb ac                	jmp    800d6d <__umoddi3+0x2d>
  800dc1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dc8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800dcc:	ba 20 00 00 00       	mov    $0x20,%edx
  800dd1:	29 c2                	sub    %eax,%edx
  800dd3:	89 c1                	mov    %eax,%ecx
  800dd5:	89 e8                	mov    %ebp,%eax
  800dd7:	d3 e7                	shl    %cl,%edi
  800dd9:	89 d1                	mov    %edx,%ecx
  800ddb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ddf:	d3 e8                	shr    %cl,%eax
  800de1:	89 c1                	mov    %eax,%ecx
  800de3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800de7:	09 f9                	or     %edi,%ecx
  800de9:	89 df                	mov    %ebx,%edi
  800deb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800def:	89 c1                	mov    %eax,%ecx
  800df1:	d3 e5                	shl    %cl,%ebp
  800df3:	89 d1                	mov    %edx,%ecx
  800df5:	d3 ef                	shr    %cl,%edi
  800df7:	89 c1                	mov    %eax,%ecx
  800df9:	89 f0                	mov    %esi,%eax
  800dfb:	d3 e3                	shl    %cl,%ebx
  800dfd:	89 d1                	mov    %edx,%ecx
  800dff:	89 fa                	mov    %edi,%edx
  800e01:	d3 e8                	shr    %cl,%eax
  800e03:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e08:	09 d8                	or     %ebx,%eax
  800e0a:	f7 74 24 08          	divl   0x8(%esp)
  800e0e:	89 d3                	mov    %edx,%ebx
  800e10:	d3 e6                	shl    %cl,%esi
  800e12:	f7 e5                	mul    %ebp
  800e14:	89 c7                	mov    %eax,%edi
  800e16:	89 d1                	mov    %edx,%ecx
  800e18:	39 d3                	cmp    %edx,%ebx
  800e1a:	72 06                	jb     800e22 <__umoddi3+0xe2>
  800e1c:	75 0e                	jne    800e2c <__umoddi3+0xec>
  800e1e:	39 c6                	cmp    %eax,%esi
  800e20:	73 0a                	jae    800e2c <__umoddi3+0xec>
  800e22:	29 e8                	sub    %ebp,%eax
  800e24:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800e28:	89 d1                	mov    %edx,%ecx
  800e2a:	89 c7                	mov    %eax,%edi
  800e2c:	89 f5                	mov    %esi,%ebp
  800e2e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e32:	29 fd                	sub    %edi,%ebp
  800e34:	19 cb                	sbb    %ecx,%ebx
  800e36:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e3b:	89 d8                	mov    %ebx,%eax
  800e3d:	d3 e0                	shl    %cl,%eax
  800e3f:	89 f1                	mov    %esi,%ecx
  800e41:	d3 ed                	shr    %cl,%ebp
  800e43:	d3 eb                	shr    %cl,%ebx
  800e45:	09 e8                	or     %ebp,%eax
  800e47:	89 da                	mov    %ebx,%edx
  800e49:	83 c4 1c             	add    $0x1c,%esp
  800e4c:	5b                   	pop    %ebx
  800e4d:	5e                   	pop    %esi
  800e4e:	5f                   	pop    %edi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    
