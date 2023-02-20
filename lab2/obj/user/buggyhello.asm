
obj/user/buggyhello：     文件格式 elf32-i386


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
  80002c:	e8 29 00 00 00       	call   80005a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	e8 17 00 00 00       	call   800056 <__x86.get_pc_thunk.bx>
  80003f:	81 c3 c1 1f 00 00    	add    $0x1fc1,%ebx
	sys_cputs((char*)1, 1);
  800045:	6a 01                	push   $0x1
  800047:	6a 01                	push   $0x1
  800049:	e8 72 00 00 00       	call   8000c0 <sys_cputs>
}
  80004e:	83 c4 10             	add    $0x10,%esp
  800051:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800054:	c9                   	leave  
  800055:	c3                   	ret    

00800056 <__x86.get_pc_thunk.bx>:
  800056:	8b 1c 24             	mov    (%esp),%ebx
  800059:	c3                   	ret    

0080005a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005a:	55                   	push   %ebp
  80005b:	89 e5                	mov    %esp,%ebp
  80005d:	53                   	push   %ebx
  80005e:	83 ec 04             	sub    $0x4,%esp
  800061:	e8 f0 ff ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800066:	81 c3 9a 1f 00 00    	add    $0x1f9a,%ebx
  80006c:	8b 45 08             	mov    0x8(%ebp),%eax
  80006f:	8b 55 0c             	mov    0xc(%ebp),%edx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800072:	c7 83 2c 00 00 00 00 	movl   $0x0,0x2c(%ebx)
  800079:	00 00 00 

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007c:	85 c0                	test   %eax,%eax
  80007e:	7e 08                	jle    800088 <libmain+0x2e>
		binaryname = argv[0];
  800080:	8b 0a                	mov    (%edx),%ecx
  800082:	89 8b 0c 00 00 00    	mov    %ecx,0xc(%ebx)

	// call user main routine
	umain(argc, argv);
  800088:	83 ec 08             	sub    $0x8,%esp
  80008b:	52                   	push   %edx
  80008c:	50                   	push   %eax
  80008d:	e8 a1 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800092:	e8 08 00 00 00       	call   80009f <exit>
}
  800097:	83 c4 10             	add    $0x10,%esp
  80009a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    

0080009f <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009f:	55                   	push   %ebp
  8000a0:	89 e5                	mov    %esp,%ebp
  8000a2:	53                   	push   %ebx
  8000a3:	83 ec 10             	sub    $0x10,%esp
  8000a6:	e8 ab ff ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8000ab:	81 c3 55 1f 00 00    	add    $0x1f55,%ebx
	sys_env_destroy(0);
  8000b1:	6a 00                	push   $0x0
  8000b3:	e8 45 00 00 00       	call   8000fd <sys_env_destroy>
}
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8000cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d1:	89 c3                	mov    %eax,%ebx
  8000d3:	89 c7                	mov    %eax,%edi
  8000d5:	89 c6                	mov    %eax,%esi
  8000d7:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d9:	5b                   	pop    %ebx
  8000da:	5e                   	pop    %esi
  8000db:	5f                   	pop    %edi
  8000dc:	5d                   	pop    %ebp
  8000dd:	c3                   	ret    

008000de <sys_cgetc>:

int
sys_cgetc(void)
{
  8000de:	55                   	push   %ebp
  8000df:	89 e5                	mov    %esp,%ebp
  8000e1:	57                   	push   %edi
  8000e2:	56                   	push   %esi
  8000e3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e9:	b8 01 00 00 00       	mov    $0x1,%eax
  8000ee:	89 d1                	mov    %edx,%ecx
  8000f0:	89 d3                	mov    %edx,%ebx
  8000f2:	89 d7                	mov    %edx,%edi
  8000f4:	89 d6                	mov    %edx,%esi
  8000f6:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	5d                   	pop    %ebp
  8000fc:	c3                   	ret    

008000fd <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fd:	55                   	push   %ebp
  8000fe:	89 e5                	mov    %esp,%ebp
  800100:	57                   	push   %edi
  800101:	56                   	push   %esi
  800102:	53                   	push   %ebx
  800103:	83 ec 1c             	sub    $0x1c,%esp
  800106:	e8 66 00 00 00       	call   800171 <__x86.get_pc_thunk.ax>
  80010b:	05 f5 1e 00 00       	add    $0x1ef5,%eax
  800110:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	asm volatile("int %1\n"
  800113:	b9 00 00 00 00       	mov    $0x0,%ecx
  800118:	8b 55 08             	mov    0x8(%ebp),%edx
  80011b:	b8 03 00 00 00       	mov    $0x3,%eax
  800120:	89 cb                	mov    %ecx,%ebx
  800122:	89 cf                	mov    %ecx,%edi
  800124:	89 ce                	mov    %ecx,%esi
  800126:	cd 30                	int    $0x30
	if(check && ret > 0)
  800128:	85 c0                	test   %eax,%eax
  80012a:	7f 08                	jg     800134 <sys_env_destroy+0x37>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80012c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012f:	5b                   	pop    %ebx
  800130:	5e                   	pop    %esi
  800131:	5f                   	pop    %edi
  800132:	5d                   	pop    %ebp
  800133:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800134:	83 ec 0c             	sub    $0xc,%esp
  800137:	50                   	push   %eax
  800138:	6a 03                	push   $0x3
  80013a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80013d:	8d 83 6e ee ff ff    	lea    -0x1192(%ebx),%eax
  800143:	50                   	push   %eax
  800144:	6a 23                	push   $0x23
  800146:	8d 83 8b ee ff ff    	lea    -0x1175(%ebx),%eax
  80014c:	50                   	push   %eax
  80014d:	e8 23 00 00 00       	call   800175 <_panic>

00800152 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800152:	55                   	push   %ebp
  800153:	89 e5                	mov    %esp,%ebp
  800155:	57                   	push   %edi
  800156:	56                   	push   %esi
  800157:	53                   	push   %ebx
	asm volatile("int %1\n"
  800158:	ba 00 00 00 00       	mov    $0x0,%edx
  80015d:	b8 02 00 00 00       	mov    $0x2,%eax
  800162:	89 d1                	mov    %edx,%ecx
  800164:	89 d3                	mov    %edx,%ebx
  800166:	89 d7                	mov    %edx,%edi
  800168:	89 d6                	mov    %edx,%esi
  80016a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80016c:	5b                   	pop    %ebx
  80016d:	5e                   	pop    %esi
  80016e:	5f                   	pop    %edi
  80016f:	5d                   	pop    %ebp
  800170:	c3                   	ret    

00800171 <__x86.get_pc_thunk.ax>:
  800171:	8b 04 24             	mov    (%esp),%eax
  800174:	c3                   	ret    

00800175 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	57                   	push   %edi
  800179:	56                   	push   %esi
  80017a:	53                   	push   %ebx
  80017b:	83 ec 0c             	sub    $0xc,%esp
  80017e:	e8 d3 fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  800183:	81 c3 7d 1e 00 00    	add    $0x1e7d,%ebx
	va_list ap;

	va_start(ap, fmt);
  800189:	8d 75 14             	lea    0x14(%ebp),%esi

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80018c:	c7 c0 0c 20 80 00    	mov    $0x80200c,%eax
  800192:	8b 38                	mov    (%eax),%edi
  800194:	e8 b9 ff ff ff       	call   800152 <sys_getenvid>
  800199:	83 ec 0c             	sub    $0xc,%esp
  80019c:	ff 75 0c             	push   0xc(%ebp)
  80019f:	ff 75 08             	push   0x8(%ebp)
  8001a2:	57                   	push   %edi
  8001a3:	50                   	push   %eax
  8001a4:	8d 83 9c ee ff ff    	lea    -0x1164(%ebx),%eax
  8001aa:	50                   	push   %eax
  8001ab:	e8 d1 00 00 00       	call   800281 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001b0:	83 c4 18             	add    $0x18,%esp
  8001b3:	56                   	push   %esi
  8001b4:	ff 75 10             	push   0x10(%ebp)
  8001b7:	e8 63 00 00 00       	call   80021f <vcprintf>
	cprintf("\n");
  8001bc:	8d 83 bf ee ff ff    	lea    -0x1141(%ebx),%eax
  8001c2:	89 04 24             	mov    %eax,(%esp)
  8001c5:	e8 b7 00 00 00       	call   800281 <cprintf>
  8001ca:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001cd:	cc                   	int3   
  8001ce:	eb fd                	jmp    8001cd <_panic+0x58>

008001d0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	56                   	push   %esi
  8001d4:	53                   	push   %ebx
  8001d5:	e8 7c fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  8001da:	81 c3 26 1e 00 00    	add    $0x1e26,%ebx
  8001e0:	8b 75 0c             	mov    0xc(%ebp),%esi
	b->buf[b->idx++] = ch;
  8001e3:	8b 16                	mov    (%esi),%edx
  8001e5:	8d 42 01             	lea    0x1(%edx),%eax
  8001e8:	89 06                	mov    %eax,(%esi)
  8001ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001ed:	88 4c 16 08          	mov    %cl,0x8(%esi,%edx,1)
	if (b->idx == 256-1) {
  8001f1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001f6:	74 0b                	je     800203 <putch+0x33>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001f8:	83 46 04 01          	addl   $0x1,0x4(%esi)
}
  8001fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001ff:	5b                   	pop    %ebx
  800200:	5e                   	pop    %esi
  800201:	5d                   	pop    %ebp
  800202:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800203:	83 ec 08             	sub    $0x8,%esp
  800206:	68 ff 00 00 00       	push   $0xff
  80020b:	8d 46 08             	lea    0x8(%esi),%eax
  80020e:	50                   	push   %eax
  80020f:	e8 ac fe ff ff       	call   8000c0 <sys_cputs>
		b->idx = 0;
  800214:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  80021a:	83 c4 10             	add    $0x10,%esp
  80021d:	eb d9                	jmp    8001f8 <putch+0x28>

0080021f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80021f:	55                   	push   %ebp
  800220:	89 e5                	mov    %esp,%ebp
  800222:	53                   	push   %ebx
  800223:	81 ec 14 01 00 00    	sub    $0x114,%esp
  800229:	e8 28 fe ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  80022e:	81 c3 d2 1d 00 00    	add    $0x1dd2,%ebx
	struct printbuf b;

	b.idx = 0;
  800234:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80023b:	00 00 00 
	b.cnt = 0;
  80023e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800245:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800248:	ff 75 0c             	push   0xc(%ebp)
  80024b:	ff 75 08             	push   0x8(%ebp)
  80024e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800254:	50                   	push   %eax
  800255:	8d 83 d0 e1 ff ff    	lea    -0x1e30(%ebx),%eax
  80025b:	50                   	push   %eax
  80025c:	e8 2c 01 00 00       	call   80038d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800261:	83 c4 08             	add    $0x8,%esp
  800264:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80026a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800270:	50                   	push   %eax
  800271:	e8 4a fe ff ff       	call   8000c0 <sys_cputs>

	return b.cnt;
}
  800276:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80027c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80027f:	c9                   	leave  
  800280:	c3                   	ret    

00800281 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800281:	55                   	push   %ebp
  800282:	89 e5                	mov    %esp,%ebp
  800284:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800287:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80028a:	50                   	push   %eax
  80028b:	ff 75 08             	push   0x8(%ebp)
  80028e:	e8 8c ff ff ff       	call   80021f <vcprintf>
	va_end(ap);

	return cnt;
}
  800293:	c9                   	leave  
  800294:	c3                   	ret    

00800295 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800295:	55                   	push   %ebp
  800296:	89 e5                	mov    %esp,%ebp
  800298:	57                   	push   %edi
  800299:	56                   	push   %esi
  80029a:	53                   	push   %ebx
  80029b:	83 ec 2c             	sub    $0x2c,%esp
  80029e:	e8 07 06 00 00       	call   8008aa <__x86.get_pc_thunk.cx>
  8002a3:	81 c1 5d 1d 00 00    	add    $0x1d5d,%ecx
  8002a9:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002ac:	89 c7                	mov    %eax,%edi
  8002ae:	89 d6                	mov    %edx,%esi
  8002b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b6:	89 d1                	mov    %edx,%ecx
  8002b8:	89 c2                	mov    %eax,%edx
  8002ba:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002bd:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8002c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002c9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002d0:	39 c2                	cmp    %eax,%edx
  8002d2:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002d5:	72 41                	jb     800318 <printnum+0x83>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d7:	83 ec 0c             	sub    $0xc,%esp
  8002da:	ff 75 18             	push   0x18(%ebp)
  8002dd:	83 eb 01             	sub    $0x1,%ebx
  8002e0:	53                   	push   %ebx
  8002e1:	50                   	push   %eax
  8002e2:	83 ec 08             	sub    $0x8,%esp
  8002e5:	ff 75 e4             	push   -0x1c(%ebp)
  8002e8:	ff 75 e0             	push   -0x20(%ebp)
  8002eb:	ff 75 d4             	push   -0x2c(%ebp)
  8002ee:	ff 75 d0             	push   -0x30(%ebp)
  8002f1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002f4:	e8 37 09 00 00       	call   800c30 <__udivdi3>
  8002f9:	83 c4 18             	add    $0x18,%esp
  8002fc:	52                   	push   %edx
  8002fd:	50                   	push   %eax
  8002fe:	89 f2                	mov    %esi,%edx
  800300:	89 f8                	mov    %edi,%eax
  800302:	e8 8e ff ff ff       	call   800295 <printnum>
  800307:	83 c4 20             	add    $0x20,%esp
  80030a:	eb 13                	jmp    80031f <printnum+0x8a>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80030c:	83 ec 08             	sub    $0x8,%esp
  80030f:	56                   	push   %esi
  800310:	ff 75 18             	push   0x18(%ebp)
  800313:	ff d7                	call   *%edi
  800315:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	85 db                	test   %ebx,%ebx
  80031d:	7f ed                	jg     80030c <printnum+0x77>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031f:	83 ec 08             	sub    $0x8,%esp
  800322:	56                   	push   %esi
  800323:	83 ec 04             	sub    $0x4,%esp
  800326:	ff 75 e4             	push   -0x1c(%ebp)
  800329:	ff 75 e0             	push   -0x20(%ebp)
  80032c:	ff 75 d4             	push   -0x2c(%ebp)
  80032f:	ff 75 d0             	push   -0x30(%ebp)
  800332:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800335:	e8 16 0a 00 00       	call   800d50 <__umoddi3>
  80033a:	83 c4 14             	add    $0x14,%esp
  80033d:	0f be 84 03 c1 ee ff 	movsbl -0x113f(%ebx,%eax,1),%eax
  800344:	ff 
  800345:	50                   	push   %eax
  800346:	ff d7                	call   *%edi
}
  800348:	83 c4 10             	add    $0x10,%esp
  80034b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034e:	5b                   	pop    %ebx
  80034f:	5e                   	pop    %esi
  800350:	5f                   	pop    %edi
  800351:	5d                   	pop    %ebp
  800352:	c3                   	ret    

00800353 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800359:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80035d:	8b 10                	mov    (%eax),%edx
  80035f:	3b 50 04             	cmp    0x4(%eax),%edx
  800362:	73 0a                	jae    80036e <sprintputch+0x1b>
		*b->buf++ = ch;
  800364:	8d 4a 01             	lea    0x1(%edx),%ecx
  800367:	89 08                	mov    %ecx,(%eax)
  800369:	8b 45 08             	mov    0x8(%ebp),%eax
  80036c:	88 02                	mov    %al,(%edx)
}
  80036e:	5d                   	pop    %ebp
  80036f:	c3                   	ret    

00800370 <printfmt>:
{
  800370:	55                   	push   %ebp
  800371:	89 e5                	mov    %esp,%ebp
  800373:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800376:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800379:	50                   	push   %eax
  80037a:	ff 75 10             	push   0x10(%ebp)
  80037d:	ff 75 0c             	push   0xc(%ebp)
  800380:	ff 75 08             	push   0x8(%ebp)
  800383:	e8 05 00 00 00       	call   80038d <vprintfmt>
}
  800388:	83 c4 10             	add    $0x10,%esp
  80038b:	c9                   	leave  
  80038c:	c3                   	ret    

0080038d <vprintfmt>:
{
  80038d:	55                   	push   %ebp
  80038e:	89 e5                	mov    %esp,%ebp
  800390:	57                   	push   %edi
  800391:	56                   	push   %esi
  800392:	53                   	push   %ebx
  800393:	83 ec 3c             	sub    $0x3c,%esp
  800396:	e8 d6 fd ff ff       	call   800171 <__x86.get_pc_thunk.ax>
  80039b:	05 65 1c 00 00       	add    $0x1c65,%eax
  8003a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a3:	8b 75 08             	mov    0x8(%ebp),%esi
  8003a6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8003a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003ac:	8d 80 10 00 00 00    	lea    0x10(%eax),%eax
  8003b2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8003b5:	eb 0a                	jmp    8003c1 <vprintfmt+0x34>
			putch(ch, putdat);
  8003b7:	83 ec 08             	sub    $0x8,%esp
  8003ba:	57                   	push   %edi
  8003bb:	50                   	push   %eax
  8003bc:	ff d6                	call   *%esi
  8003be:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003c1:	83 c3 01             	add    $0x1,%ebx
  8003c4:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8003c8:	83 f8 25             	cmp    $0x25,%eax
  8003cb:	74 0c                	je     8003d9 <vprintfmt+0x4c>
			if (ch == '\0')
  8003cd:	85 c0                	test   %eax,%eax
  8003cf:	75 e6                	jne    8003b7 <vprintfmt+0x2a>
}
  8003d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003d4:	5b                   	pop    %ebx
  8003d5:	5e                   	pop    %esi
  8003d6:	5f                   	pop    %edi
  8003d7:	5d                   	pop    %ebp
  8003d8:	c3                   	ret    
		padc = ' ';
  8003d9:	c6 45 cf 20          	movb   $0x20,-0x31(%ebp)
		altflag = 0;
  8003dd:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
		precision = -1;
  8003e4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003eb:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
		lflag = 0;
  8003f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f7:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003fa:	89 75 08             	mov    %esi,0x8(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8d 43 01             	lea    0x1(%ebx),%eax
  800400:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800403:	0f b6 13             	movzbl (%ebx),%edx
  800406:	8d 42 dd             	lea    -0x23(%edx),%eax
  800409:	3c 55                	cmp    $0x55,%al
  80040b:	0f 87 fd 03 00 00    	ja     80080e <.L20>
  800411:	0f b6 c0             	movzbl %al,%eax
  800414:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800417:	89 ce                	mov    %ecx,%esi
  800419:	03 b4 81 50 ef ff ff 	add    -0x10b0(%ecx,%eax,4),%esi
  800420:	ff e6                	jmp    *%esi

00800422 <.L68>:
  800422:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			padc = '-';
  800425:	c6 45 cf 2d          	movb   $0x2d,-0x31(%ebp)
  800429:	eb d2                	jmp    8003fd <vprintfmt+0x70>

0080042b <.L32>:
		switch (ch = *(unsigned char *) fmt++) {
  80042b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80042e:	c6 45 cf 30          	movb   $0x30,-0x31(%ebp)
  800432:	eb c9                	jmp    8003fd <vprintfmt+0x70>

00800434 <.L31>:
  800434:	0f b6 d2             	movzbl %dl,%edx
  800437:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			for (precision = 0; ; ++fmt) {
  80043a:	b8 00 00 00 00       	mov    $0x0,%eax
  80043f:	8b 75 08             	mov    0x8(%ebp),%esi
				precision = precision * 10 + ch - '0';
  800442:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800445:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800449:	0f be 13             	movsbl (%ebx),%edx
				if (ch < '0' || ch > '9')
  80044c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80044f:	83 f9 09             	cmp    $0x9,%ecx
  800452:	77 58                	ja     8004ac <.L36+0xf>
			for (precision = 0; ; ++fmt) {
  800454:	83 c3 01             	add    $0x1,%ebx
				precision = precision * 10 + ch - '0';
  800457:	eb e9                	jmp    800442 <.L31+0xe>

00800459 <.L34>:
			precision = va_arg(ap, int);
  800459:	8b 45 14             	mov    0x14(%ebp),%eax
  80045c:	8b 00                	mov    (%eax),%eax
  80045e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800461:	8b 45 14             	mov    0x14(%ebp),%eax
  800464:	8d 40 04             	lea    0x4(%eax),%eax
  800467:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			if (width < 0)
  80046d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800471:	79 8a                	jns    8003fd <vprintfmt+0x70>
				width = precision, precision = -1;
  800473:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800476:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800479:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800480:	e9 78 ff ff ff       	jmp    8003fd <vprintfmt+0x70>

00800485 <.L33>:
  800485:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800488:	85 d2                	test   %edx,%edx
  80048a:	b8 00 00 00 00       	mov    $0x0,%eax
  80048f:	0f 49 c2             	cmovns %edx,%eax
  800492:	89 45 d4             	mov    %eax,-0x2c(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800495:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  800498:	e9 60 ff ff ff       	jmp    8003fd <vprintfmt+0x70>

0080049d <.L36>:
		switch (ch = *(unsigned char *) fmt++) {
  80049d:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			altflag = 1;
  8004a0:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
			goto reswitch;
  8004a7:	e9 51 ff ff ff       	jmp    8003fd <vprintfmt+0x70>
  8004ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004af:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b2:	eb b9                	jmp    80046d <.L34+0x14>

008004b4 <.L27>:
			lflag++;
  8004b4:	83 45 c8 01          	addl   $0x1,-0x38(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004b8:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
			goto reswitch;
  8004bb:	e9 3d ff ff ff       	jmp    8003fd <vprintfmt+0x70>

008004c0 <.L30>:
			putch(va_arg(ap, int), putdat);
  8004c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c6:	8d 58 04             	lea    0x4(%eax),%ebx
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	57                   	push   %edi
  8004cd:	ff 30                	push   (%eax)
  8004cf:	ff d6                	call   *%esi
			break;
  8004d1:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8004d4:	89 5d 14             	mov    %ebx,0x14(%ebp)
			break;
  8004d7:	e9 c8 02 00 00       	jmp    8007a4 <.L25+0x45>

008004dc <.L28>:
			err = va_arg(ap, int);
  8004dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004df:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e2:	8d 58 04             	lea    0x4(%eax),%ebx
  8004e5:	8b 10                	mov    (%eax),%edx
  8004e7:	89 d0                	mov    %edx,%eax
  8004e9:	f7 d8                	neg    %eax
  8004eb:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ee:	83 f8 06             	cmp    $0x6,%eax
  8004f1:	7f 27                	jg     80051a <.L28+0x3e>
  8004f3:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004f6:	8b 14 82             	mov    (%edx,%eax,4),%edx
  8004f9:	85 d2                	test   %edx,%edx
  8004fb:	74 1d                	je     80051a <.L28+0x3e>
				printfmt(putch, putdat, "%s", p);
  8004fd:	52                   	push   %edx
  8004fe:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800501:	8d 80 e2 ee ff ff    	lea    -0x111e(%eax),%eax
  800507:	50                   	push   %eax
  800508:	57                   	push   %edi
  800509:	56                   	push   %esi
  80050a:	e8 61 fe ff ff       	call   800370 <printfmt>
  80050f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800512:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800515:	e9 8a 02 00 00       	jmp    8007a4 <.L25+0x45>
				printfmt(putch, putdat, "error %d", err);
  80051a:	50                   	push   %eax
  80051b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80051e:	8d 80 d9 ee ff ff    	lea    -0x1127(%eax),%eax
  800524:	50                   	push   %eax
  800525:	57                   	push   %edi
  800526:	56                   	push   %esi
  800527:	e8 44 fe ff ff       	call   800370 <printfmt>
  80052c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80052f:	89 5d 14             	mov    %ebx,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800532:	e9 6d 02 00 00       	jmp    8007a4 <.L25+0x45>

00800537 <.L24>:
			if ((p = va_arg(ap, char *)) == NULL)
  800537:	8b 75 08             	mov    0x8(%ebp),%esi
  80053a:	8b 45 14             	mov    0x14(%ebp),%eax
  80053d:	83 c0 04             	add    $0x4,%eax
  800540:	89 45 c0             	mov    %eax,-0x40(%ebp)
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800548:	85 d2                	test   %edx,%edx
  80054a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80054d:	8d 80 d2 ee ff ff    	lea    -0x112e(%eax),%eax
  800553:	0f 45 c2             	cmovne %edx,%eax
  800556:	89 45 c8             	mov    %eax,-0x38(%ebp)
			if (width > 0 && padc != '-')
  800559:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80055d:	7e 06                	jle    800565 <.L24+0x2e>
  80055f:	80 7d cf 2d          	cmpb   $0x2d,-0x31(%ebp)
  800563:	75 0d                	jne    800572 <.L24+0x3b>
				for (width -= strnlen(p, precision); width > 0; width--)
  800565:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800568:	89 c3                	mov    %eax,%ebx
  80056a:	03 45 d4             	add    -0x2c(%ebp),%eax
  80056d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800570:	eb 58                	jmp    8005ca <.L24+0x93>
  800572:	83 ec 08             	sub    $0x8,%esp
  800575:	ff 75 d8             	push   -0x28(%ebp)
  800578:	ff 75 c8             	push   -0x38(%ebp)
  80057b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057e:	e8 43 03 00 00       	call   8008c6 <strnlen>
  800583:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  800586:	29 c2                	sub    %eax,%edx
  800588:	89 55 bc             	mov    %edx,-0x44(%ebp)
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	89 d3                	mov    %edx,%ebx
					putch(padc, putdat);
  800590:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800594:	89 45 d4             	mov    %eax,-0x2c(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800597:	eb 0f                	jmp    8005a8 <.L24+0x71>
					putch(padc, putdat);
  800599:	83 ec 08             	sub    $0x8,%esp
  80059c:	57                   	push   %edi
  80059d:	ff 75 d4             	push   -0x2c(%ebp)
  8005a0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005a2:	83 eb 01             	sub    $0x1,%ebx
  8005a5:	83 c4 10             	add    $0x10,%esp
  8005a8:	85 db                	test   %ebx,%ebx
  8005aa:	7f ed                	jg     800599 <.L24+0x62>
  8005ac:	8b 55 bc             	mov    -0x44(%ebp),%edx
  8005af:	85 d2                	test   %edx,%edx
  8005b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b6:	0f 49 c2             	cmovns %edx,%eax
  8005b9:	29 c2                	sub    %eax,%edx
  8005bb:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005be:	eb a5                	jmp    800565 <.L24+0x2e>
					putch(ch, putdat);
  8005c0:	83 ec 08             	sub    $0x8,%esp
  8005c3:	57                   	push   %edi
  8005c4:	52                   	push   %edx
  8005c5:	ff d6                	call   *%esi
  8005c7:	83 c4 10             	add    $0x10,%esp
  8005ca:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8005cd:	29 d9                	sub    %ebx,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005cf:	83 c3 01             	add    $0x1,%ebx
  8005d2:	0f b6 43 ff          	movzbl -0x1(%ebx),%eax
  8005d6:	0f be d0             	movsbl %al,%edx
  8005d9:	85 d2                	test   %edx,%edx
  8005db:	74 4b                	je     800628 <.L24+0xf1>
  8005dd:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005e1:	78 06                	js     8005e9 <.L24+0xb2>
  8005e3:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005e7:	78 1e                	js     800607 <.L24+0xd0>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e9:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005ed:	74 d1                	je     8005c0 <.L24+0x89>
  8005ef:	0f be c0             	movsbl %al,%eax
  8005f2:	83 e8 20             	sub    $0x20,%eax
  8005f5:	83 f8 5e             	cmp    $0x5e,%eax
  8005f8:	76 c6                	jbe    8005c0 <.L24+0x89>
					putch('?', putdat);
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	57                   	push   %edi
  8005fe:	6a 3f                	push   $0x3f
  800600:	ff d6                	call   *%esi
  800602:	83 c4 10             	add    $0x10,%esp
  800605:	eb c3                	jmp    8005ca <.L24+0x93>
  800607:	89 cb                	mov    %ecx,%ebx
  800609:	eb 0e                	jmp    800619 <.L24+0xe2>
				putch(' ', putdat);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	57                   	push   %edi
  80060f:	6a 20                	push   $0x20
  800611:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800613:	83 eb 01             	sub    $0x1,%ebx
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	85 db                	test   %ebx,%ebx
  80061b:	7f ee                	jg     80060b <.L24+0xd4>
			if ((p = va_arg(ap, char *)) == NULL)
  80061d:	8b 45 c0             	mov    -0x40(%ebp),%eax
  800620:	89 45 14             	mov    %eax,0x14(%ebp)
  800623:	e9 7c 01 00 00       	jmp    8007a4 <.L25+0x45>
  800628:	89 cb                	mov    %ecx,%ebx
  80062a:	eb ed                	jmp    800619 <.L24+0xe2>

0080062c <.L29>:
	if (lflag >= 2)
  80062c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80062f:	8b 75 08             	mov    0x8(%ebp),%esi
  800632:	83 f9 01             	cmp    $0x1,%ecx
  800635:	7f 1b                	jg     800652 <.L29+0x26>
	else if (lflag)
  800637:	85 c9                	test   %ecx,%ecx
  800639:	74 63                	je     80069e <.L29+0x72>
		return va_arg(*ap, long);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8b 00                	mov    (%eax),%eax
  800640:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800643:	99                   	cltd   
  800644:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8d 40 04             	lea    0x4(%eax),%eax
  80064d:	89 45 14             	mov    %eax,0x14(%ebp)
  800650:	eb 17                	jmp    800669 <.L29+0x3d>
		return va_arg(*ap, long long);
  800652:	8b 45 14             	mov    0x14(%ebp),%eax
  800655:	8b 50 04             	mov    0x4(%eax),%edx
  800658:	8b 00                	mov    (%eax),%eax
  80065a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80065d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800660:	8b 45 14             	mov    0x14(%ebp),%eax
  800663:	8d 40 08             	lea    0x8(%eax),%eax
  800666:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800669:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80066c:	8b 5d dc             	mov    -0x24(%ebp),%ebx
			base = 10;
  80066f:	ba 0a 00 00 00       	mov    $0xa,%edx
			if ((long long) num < 0) {
  800674:	85 db                	test   %ebx,%ebx
  800676:	0f 89 0e 01 00 00    	jns    80078a <.L25+0x2b>
				putch('-', putdat);
  80067c:	83 ec 08             	sub    $0x8,%esp
  80067f:	57                   	push   %edi
  800680:	6a 2d                	push   $0x2d
  800682:	ff d6                	call   *%esi
				num = -(long long) num;
  800684:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  800687:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  80068a:	f7 d9                	neg    %ecx
  80068c:	83 d3 00             	adc    $0x0,%ebx
  80068f:	f7 db                	neg    %ebx
  800691:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800694:	ba 0a 00 00 00       	mov    $0xa,%edx
  800699:	e9 ec 00 00 00       	jmp    80078a <.L25+0x2b>
		return va_arg(*ap, int);
  80069e:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a1:	8b 00                	mov    (%eax),%eax
  8006a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006a6:	99                   	cltd   
  8006a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ad:	8d 40 04             	lea    0x4(%eax),%eax
  8006b0:	89 45 14             	mov    %eax,0x14(%ebp)
  8006b3:	eb b4                	jmp    800669 <.L29+0x3d>

008006b5 <.L23>:
	if (lflag >= 2)
  8006b5:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006b8:	8b 75 08             	mov    0x8(%ebp),%esi
  8006bb:	83 f9 01             	cmp    $0x1,%ecx
  8006be:	7f 1e                	jg     8006de <.L23+0x29>
	else if (lflag)
  8006c0:	85 c9                	test   %ecx,%ecx
  8006c2:	74 32                	je     8006f6 <.L23+0x41>
		return va_arg(*ap, unsigned long);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8b 08                	mov    (%eax),%ecx
  8006c9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ce:	8d 40 04             	lea    0x4(%eax),%eax
  8006d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006d4:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long);
  8006d9:	e9 ac 00 00 00       	jmp    80078a <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8b 08                	mov    (%eax),%ecx
  8006e3:	8b 58 04             	mov    0x4(%eax),%ebx
  8006e6:	8d 40 08             	lea    0x8(%eax),%eax
  8006e9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006ec:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned long long);
  8006f1:	e9 94 00 00 00       	jmp    80078a <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8b 08                	mov    (%eax),%ecx
  8006fb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800700:	8d 40 04             	lea    0x4(%eax),%eax
  800703:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800706:	ba 0a 00 00 00       	mov    $0xa,%edx
		return va_arg(*ap, unsigned int);
  80070b:	eb 7d                	jmp    80078a <.L25+0x2b>

0080070d <.L26>:
	if (lflag >= 2)
  80070d:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800710:	8b 75 08             	mov    0x8(%ebp),%esi
  800713:	83 f9 01             	cmp    $0x1,%ecx
  800716:	7f 1b                	jg     800733 <.L26+0x26>
	else if (lflag)
  800718:	85 c9                	test   %ecx,%ecx
  80071a:	74 2c                	je     800748 <.L26+0x3b>
		return va_arg(*ap, unsigned long);
  80071c:	8b 45 14             	mov    0x14(%ebp),%eax
  80071f:	8b 08                	mov    (%eax),%ecx
  800721:	bb 00 00 00 00       	mov    $0x0,%ebx
  800726:	8d 40 04             	lea    0x4(%eax),%eax
  800729:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80072c:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long);
  800731:	eb 57                	jmp    80078a <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  800733:	8b 45 14             	mov    0x14(%ebp),%eax
  800736:	8b 08                	mov    (%eax),%ecx
  800738:	8b 58 04             	mov    0x4(%eax),%ebx
  80073b:	8d 40 08             	lea    0x8(%eax),%eax
  80073e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800741:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned long long);
  800746:	eb 42                	jmp    80078a <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  800748:	8b 45 14             	mov    0x14(%ebp),%eax
  80074b:	8b 08                	mov    (%eax),%ecx
  80074d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800752:	8d 40 04             	lea    0x4(%eax),%eax
  800755:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800758:	ba 08 00 00 00       	mov    $0x8,%edx
		return va_arg(*ap, unsigned int);
  80075d:	eb 2b                	jmp    80078a <.L25+0x2b>

0080075f <.L25>:
			putch('0', putdat);
  80075f:	8b 75 08             	mov    0x8(%ebp),%esi
  800762:	83 ec 08             	sub    $0x8,%esp
  800765:	57                   	push   %edi
  800766:	6a 30                	push   $0x30
  800768:	ff d6                	call   *%esi
			putch('x', putdat);
  80076a:	83 c4 08             	add    $0x8,%esp
  80076d:	57                   	push   %edi
  80076e:	6a 78                	push   $0x78
  800770:	ff d6                	call   *%esi
			num = (unsigned long long)
  800772:	8b 45 14             	mov    0x14(%ebp),%eax
  800775:	8b 08                	mov    (%eax),%ecx
  800777:	bb 00 00 00 00       	mov    $0x0,%ebx
			goto number;
  80077c:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80077f:	8d 40 04             	lea    0x4(%eax),%eax
  800782:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800785:	ba 10 00 00 00       	mov    $0x10,%edx
			printnum(putch, putdat, num, base, width, padc);
  80078a:	83 ec 0c             	sub    $0xc,%esp
  80078d:	0f be 45 cf          	movsbl -0x31(%ebp),%eax
  800791:	50                   	push   %eax
  800792:	ff 75 d4             	push   -0x2c(%ebp)
  800795:	52                   	push   %edx
  800796:	53                   	push   %ebx
  800797:	51                   	push   %ecx
  800798:	89 fa                	mov    %edi,%edx
  80079a:	89 f0                	mov    %esi,%eax
  80079c:	e8 f4 fa ff ff       	call   800295 <printnum>
			break;
  8007a1:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007a4:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007a7:	e9 15 fc ff ff       	jmp    8003c1 <vprintfmt+0x34>

008007ac <.L21>:
	if (lflag >= 2)
  8007ac:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8007af:	8b 75 08             	mov    0x8(%ebp),%esi
  8007b2:	83 f9 01             	cmp    $0x1,%ecx
  8007b5:	7f 1b                	jg     8007d2 <.L21+0x26>
	else if (lflag)
  8007b7:	85 c9                	test   %ecx,%ecx
  8007b9:	74 2c                	je     8007e7 <.L21+0x3b>
		return va_arg(*ap, unsigned long);
  8007bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007be:	8b 08                	mov    (%eax),%ecx
  8007c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007c5:	8d 40 04             	lea    0x4(%eax),%eax
  8007c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007cb:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long);
  8007d0:	eb b8                	jmp    80078a <.L25+0x2b>
		return va_arg(*ap, unsigned long long);
  8007d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d5:	8b 08                	mov    (%eax),%ecx
  8007d7:	8b 58 04             	mov    0x4(%eax),%ebx
  8007da:	8d 40 08             	lea    0x8(%eax),%eax
  8007dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007e0:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned long long);
  8007e5:	eb a3                	jmp    80078a <.L25+0x2b>
		return va_arg(*ap, unsigned int);
  8007e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ea:	8b 08                	mov    (%eax),%ecx
  8007ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007f1:	8d 40 04             	lea    0x4(%eax),%eax
  8007f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f7:	ba 10 00 00 00       	mov    $0x10,%edx
		return va_arg(*ap, unsigned int);
  8007fc:	eb 8c                	jmp    80078a <.L25+0x2b>

008007fe <.L35>:
			putch(ch, putdat);
  8007fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800801:	83 ec 08             	sub    $0x8,%esp
  800804:	57                   	push   %edi
  800805:	6a 25                	push   $0x25
  800807:	ff d6                	call   *%esi
			break;
  800809:	83 c4 10             	add    $0x10,%esp
  80080c:	eb 96                	jmp    8007a4 <.L25+0x45>

0080080e <.L20>:
			putch('%', putdat);
  80080e:	8b 75 08             	mov    0x8(%ebp),%esi
  800811:	83 ec 08             	sub    $0x8,%esp
  800814:	57                   	push   %edi
  800815:	6a 25                	push   $0x25
  800817:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	89 d8                	mov    %ebx,%eax
  80081e:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800822:	74 05                	je     800829 <.L20+0x1b>
  800824:	83 e8 01             	sub    $0x1,%eax
  800827:	eb f5                	jmp    80081e <.L20+0x10>
  800829:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80082c:	e9 73 ff ff ff       	jmp    8007a4 <.L25+0x45>

00800831 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800831:	55                   	push   %ebp
  800832:	89 e5                	mov    %esp,%ebp
  800834:	53                   	push   %ebx
  800835:	83 ec 14             	sub    $0x14,%esp
  800838:	e8 19 f8 ff ff       	call   800056 <__x86.get_pc_thunk.bx>
  80083d:	81 c3 c3 17 00 00    	add    $0x17c3,%ebx
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800849:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800850:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800853:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80085a:	85 c0                	test   %eax,%eax
  80085c:	74 2b                	je     800889 <vsnprintf+0x58>
  80085e:	85 d2                	test   %edx,%edx
  800860:	7e 27                	jle    800889 <vsnprintf+0x58>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800862:	ff 75 14             	push   0x14(%ebp)
  800865:	ff 75 10             	push   0x10(%ebp)
  800868:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086b:	50                   	push   %eax
  80086c:	8d 83 53 e3 ff ff    	lea    -0x1cad(%ebx),%eax
  800872:	50                   	push   %eax
  800873:	e8 15 fb ff ff       	call   80038d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800878:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800881:	83 c4 10             	add    $0x10,%esp
}
  800884:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800887:	c9                   	leave  
  800888:	c3                   	ret    
		return -E_INVAL;
  800889:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088e:	eb f4                	jmp    800884 <vsnprintf+0x53>

00800890 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800896:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800899:	50                   	push   %eax
  80089a:	ff 75 10             	push   0x10(%ebp)
  80089d:	ff 75 0c             	push   0xc(%ebp)
  8008a0:	ff 75 08             	push   0x8(%ebp)
  8008a3:	e8 89 ff ff ff       	call   800831 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a8:	c9                   	leave  
  8008a9:	c3                   	ret    

008008aa <__x86.get_pc_thunk.cx>:
  8008aa:	8b 0c 24             	mov    (%esp),%ecx
  8008ad:	c3                   	ret    

008008ae <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b9:	eb 03                	jmp    8008be <strlen+0x10>
		n++;
  8008bb:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008be:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c2:	75 f7                	jne    8008bb <strlen+0xd>
	return n;
}
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d4:	eb 03                	jmp    8008d9 <strnlen+0x13>
		n++;
  8008d6:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d9:	39 d0                	cmp    %edx,%eax
  8008db:	74 08                	je     8008e5 <strnlen+0x1f>
  8008dd:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008e1:	75 f3                	jne    8008d6 <strnlen+0x10>
  8008e3:	89 c2                	mov    %eax,%edx
	return n;
}
  8008e5:	89 d0                	mov    %edx,%eax
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	53                   	push   %ebx
  8008ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008fc:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008ff:	83 c0 01             	add    $0x1,%eax
  800902:	84 d2                	test   %dl,%dl
  800904:	75 f2                	jne    8008f8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800906:	89 c8                	mov    %ecx,%eax
  800908:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80090b:	c9                   	leave  
  80090c:	c3                   	ret    

0080090d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80090d:	55                   	push   %ebp
  80090e:	89 e5                	mov    %esp,%ebp
  800910:	53                   	push   %ebx
  800911:	83 ec 10             	sub    $0x10,%esp
  800914:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800917:	53                   	push   %ebx
  800918:	e8 91 ff ff ff       	call   8008ae <strlen>
  80091d:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800920:	ff 75 0c             	push   0xc(%ebp)
  800923:	01 d8                	add    %ebx,%eax
  800925:	50                   	push   %eax
  800926:	e8 be ff ff ff       	call   8008e9 <strcpy>
	return dst;
}
  80092b:	89 d8                	mov    %ebx,%eax
  80092d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800930:	c9                   	leave  
  800931:	c3                   	ret    

00800932 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	56                   	push   %esi
  800936:	53                   	push   %ebx
  800937:	8b 75 08             	mov    0x8(%ebp),%esi
  80093a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093d:	89 f3                	mov    %esi,%ebx
  80093f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800942:	89 f0                	mov    %esi,%eax
  800944:	eb 0f                	jmp    800955 <strncpy+0x23>
		*dst++ = *src;
  800946:	83 c0 01             	add    $0x1,%eax
  800949:	0f b6 0a             	movzbl (%edx),%ecx
  80094c:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80094f:	80 f9 01             	cmp    $0x1,%cl
  800952:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800955:	39 d8                	cmp    %ebx,%eax
  800957:	75 ed                	jne    800946 <strncpy+0x14>
	}
	return ret;
}
  800959:	89 f0                	mov    %esi,%eax
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	56                   	push   %esi
  800963:	53                   	push   %ebx
  800964:	8b 75 08             	mov    0x8(%ebp),%esi
  800967:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096a:	8b 55 10             	mov    0x10(%ebp),%edx
  80096d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80096f:	85 d2                	test   %edx,%edx
  800971:	74 21                	je     800994 <strlcpy+0x35>
  800973:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800977:	89 f2                	mov    %esi,%edx
  800979:	eb 09                	jmp    800984 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80097b:	83 c1 01             	add    $0x1,%ecx
  80097e:	83 c2 01             	add    $0x1,%edx
  800981:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800984:	39 c2                	cmp    %eax,%edx
  800986:	74 09                	je     800991 <strlcpy+0x32>
  800988:	0f b6 19             	movzbl (%ecx),%ebx
  80098b:	84 db                	test   %bl,%bl
  80098d:	75 ec                	jne    80097b <strlcpy+0x1c>
  80098f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800991:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800994:	29 f0                	sub    %esi,%eax
}
  800996:	5b                   	pop    %ebx
  800997:	5e                   	pop    %esi
  800998:	5d                   	pop    %ebp
  800999:	c3                   	ret    

0080099a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a3:	eb 06                	jmp    8009ab <strcmp+0x11>
		p++, q++;
  8009a5:	83 c1 01             	add    $0x1,%ecx
  8009a8:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009ab:	0f b6 01             	movzbl (%ecx),%eax
  8009ae:	84 c0                	test   %al,%al
  8009b0:	74 04                	je     8009b6 <strcmp+0x1c>
  8009b2:	3a 02                	cmp    (%edx),%al
  8009b4:	74 ef                	je     8009a5 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b6:	0f b6 c0             	movzbl %al,%eax
  8009b9:	0f b6 12             	movzbl (%edx),%edx
  8009bc:	29 d0                	sub    %edx,%eax
}
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	53                   	push   %ebx
  8009c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ca:	89 c3                	mov    %eax,%ebx
  8009cc:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009cf:	eb 06                	jmp    8009d7 <strncmp+0x17>
		n--, p++, q++;
  8009d1:	83 c0 01             	add    $0x1,%eax
  8009d4:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009d7:	39 d8                	cmp    %ebx,%eax
  8009d9:	74 18                	je     8009f3 <strncmp+0x33>
  8009db:	0f b6 08             	movzbl (%eax),%ecx
  8009de:	84 c9                	test   %cl,%cl
  8009e0:	74 04                	je     8009e6 <strncmp+0x26>
  8009e2:	3a 0a                	cmp    (%edx),%cl
  8009e4:	74 eb                	je     8009d1 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e6:	0f b6 00             	movzbl (%eax),%eax
  8009e9:	0f b6 12             	movzbl (%edx),%edx
  8009ec:	29 d0                	sub    %edx,%eax
}
  8009ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    
		return 0;
  8009f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f8:	eb f4                	jmp    8009ee <strncmp+0x2e>

008009fa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a04:	eb 03                	jmp    800a09 <strchr+0xf>
  800a06:	83 c0 01             	add    $0x1,%eax
  800a09:	0f b6 10             	movzbl (%eax),%edx
  800a0c:	84 d2                	test   %dl,%dl
  800a0e:	74 06                	je     800a16 <strchr+0x1c>
		if (*s == c)
  800a10:	38 ca                	cmp    %cl,%dl
  800a12:	75 f2                	jne    800a06 <strchr+0xc>
  800a14:	eb 05                	jmp    800a1b <strchr+0x21>
			return (char *) s;
	return 0;
  800a16:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1b:	5d                   	pop    %ebp
  800a1c:	c3                   	ret    

00800a1d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a27:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a2a:	38 ca                	cmp    %cl,%dl
  800a2c:	74 09                	je     800a37 <strfind+0x1a>
  800a2e:	84 d2                	test   %dl,%dl
  800a30:	74 05                	je     800a37 <strfind+0x1a>
	for (; *s; s++)
  800a32:	83 c0 01             	add    $0x1,%eax
  800a35:	eb f0                	jmp    800a27 <strfind+0xa>
			break;
	return (char *) s;
}
  800a37:	5d                   	pop    %ebp
  800a38:	c3                   	ret    

00800a39 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a39:	55                   	push   %ebp
  800a3a:	89 e5                	mov    %esp,%ebp
  800a3c:	57                   	push   %edi
  800a3d:	56                   	push   %esi
  800a3e:	53                   	push   %ebx
  800a3f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a42:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a45:	85 c9                	test   %ecx,%ecx
  800a47:	74 2f                	je     800a78 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a49:	89 f8                	mov    %edi,%eax
  800a4b:	09 c8                	or     %ecx,%eax
  800a4d:	a8 03                	test   $0x3,%al
  800a4f:	75 21                	jne    800a72 <memset+0x39>
		c &= 0xFF;
  800a51:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a55:	89 d0                	mov    %edx,%eax
  800a57:	c1 e0 08             	shl    $0x8,%eax
  800a5a:	89 d3                	mov    %edx,%ebx
  800a5c:	c1 e3 18             	shl    $0x18,%ebx
  800a5f:	89 d6                	mov    %edx,%esi
  800a61:	c1 e6 10             	shl    $0x10,%esi
  800a64:	09 f3                	or     %esi,%ebx
  800a66:	09 da                	or     %ebx,%edx
  800a68:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a6a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a6d:	fc                   	cld    
  800a6e:	f3 ab                	rep stos %eax,%es:(%edi)
  800a70:	eb 06                	jmp    800a78 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a75:	fc                   	cld    
  800a76:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a78:	89 f8                	mov    %edi,%eax
  800a7a:	5b                   	pop    %ebx
  800a7b:	5e                   	pop    %esi
  800a7c:	5f                   	pop    %edi
  800a7d:	5d                   	pop    %ebp
  800a7e:	c3                   	ret    

00800a7f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a7f:	55                   	push   %ebp
  800a80:	89 e5                	mov    %esp,%ebp
  800a82:	57                   	push   %edi
  800a83:	56                   	push   %esi
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a8d:	39 c6                	cmp    %eax,%esi
  800a8f:	73 32                	jae    800ac3 <memmove+0x44>
  800a91:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a94:	39 c2                	cmp    %eax,%edx
  800a96:	76 2b                	jbe    800ac3 <memmove+0x44>
		s += n;
		d += n;
  800a98:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a9b:	89 d6                	mov    %edx,%esi
  800a9d:	09 fe                	or     %edi,%esi
  800a9f:	09 ce                	or     %ecx,%esi
  800aa1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aa7:	75 0e                	jne    800ab7 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aa9:	83 ef 04             	sub    $0x4,%edi
  800aac:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aaf:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ab2:	fd                   	std    
  800ab3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab5:	eb 09                	jmp    800ac0 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ab7:	83 ef 01             	sub    $0x1,%edi
  800aba:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800abd:	fd                   	std    
  800abe:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ac0:	fc                   	cld    
  800ac1:	eb 1a                	jmp    800add <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac3:	89 f2                	mov    %esi,%edx
  800ac5:	09 c2                	or     %eax,%edx
  800ac7:	09 ca                	or     %ecx,%edx
  800ac9:	f6 c2 03             	test   $0x3,%dl
  800acc:	75 0a                	jne    800ad8 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ace:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ad1:	89 c7                	mov    %eax,%edi
  800ad3:	fc                   	cld    
  800ad4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad6:	eb 05                	jmp    800add <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800ad8:	89 c7                	mov    %eax,%edi
  800ada:	fc                   	cld    
  800adb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800add:	5e                   	pop    %esi
  800ade:	5f                   	pop    %edi
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ae7:	ff 75 10             	push   0x10(%ebp)
  800aea:	ff 75 0c             	push   0xc(%ebp)
  800aed:	ff 75 08             	push   0x8(%ebp)
  800af0:	e8 8a ff ff ff       	call   800a7f <memmove>
}
  800af5:	c9                   	leave  
  800af6:	c3                   	ret    

00800af7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	56                   	push   %esi
  800afb:	53                   	push   %ebx
  800afc:	8b 45 08             	mov    0x8(%ebp),%eax
  800aff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b02:	89 c6                	mov    %eax,%esi
  800b04:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b07:	eb 06                	jmp    800b0f <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b09:	83 c0 01             	add    $0x1,%eax
  800b0c:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800b0f:	39 f0                	cmp    %esi,%eax
  800b11:	74 14                	je     800b27 <memcmp+0x30>
		if (*s1 != *s2)
  800b13:	0f b6 08             	movzbl (%eax),%ecx
  800b16:	0f b6 1a             	movzbl (%edx),%ebx
  800b19:	38 d9                	cmp    %bl,%cl
  800b1b:	74 ec                	je     800b09 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b1d:	0f b6 c1             	movzbl %cl,%eax
  800b20:	0f b6 db             	movzbl %bl,%ebx
  800b23:	29 d8                	sub    %ebx,%eax
  800b25:	eb 05                	jmp    800b2c <memcmp+0x35>
	}

	return 0;
  800b27:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b2c:	5b                   	pop    %ebx
  800b2d:	5e                   	pop    %esi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	8b 45 08             	mov    0x8(%ebp),%eax
  800b36:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b39:	89 c2                	mov    %eax,%edx
  800b3b:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b3e:	eb 03                	jmp    800b43 <memfind+0x13>
  800b40:	83 c0 01             	add    $0x1,%eax
  800b43:	39 d0                	cmp    %edx,%eax
  800b45:	73 04                	jae    800b4b <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b47:	38 08                	cmp    %cl,(%eax)
  800b49:	75 f5                	jne    800b40 <memfind+0x10>
			break;
	return (void *) s;
}
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    

00800b4d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b4d:	55                   	push   %ebp
  800b4e:	89 e5                	mov    %esp,%ebp
  800b50:	57                   	push   %edi
  800b51:	56                   	push   %esi
  800b52:	53                   	push   %ebx
  800b53:	8b 55 08             	mov    0x8(%ebp),%edx
  800b56:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b59:	eb 03                	jmp    800b5e <strtol+0x11>
		s++;
  800b5b:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b5e:	0f b6 02             	movzbl (%edx),%eax
  800b61:	3c 20                	cmp    $0x20,%al
  800b63:	74 f6                	je     800b5b <strtol+0xe>
  800b65:	3c 09                	cmp    $0x9,%al
  800b67:	74 f2                	je     800b5b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b69:	3c 2b                	cmp    $0x2b,%al
  800b6b:	74 2a                	je     800b97 <strtol+0x4a>
	int neg = 0;
  800b6d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b72:	3c 2d                	cmp    $0x2d,%al
  800b74:	74 2b                	je     800ba1 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b76:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b7c:	75 0f                	jne    800b8d <strtol+0x40>
  800b7e:	80 3a 30             	cmpb   $0x30,(%edx)
  800b81:	74 28                	je     800bab <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b83:	85 db                	test   %ebx,%ebx
  800b85:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b8a:	0f 44 d8             	cmove  %eax,%ebx
  800b8d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b92:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b95:	eb 46                	jmp    800bdd <strtol+0x90>
		s++;
  800b97:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b9a:	bf 00 00 00 00       	mov    $0x0,%edi
  800b9f:	eb d5                	jmp    800b76 <strtol+0x29>
		s++, neg = 1;
  800ba1:	83 c2 01             	add    $0x1,%edx
  800ba4:	bf 01 00 00 00       	mov    $0x1,%edi
  800ba9:	eb cb                	jmp    800b76 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bab:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800baf:	74 0e                	je     800bbf <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800bb1:	85 db                	test   %ebx,%ebx
  800bb3:	75 d8                	jne    800b8d <strtol+0x40>
		s++, base = 8;
  800bb5:	83 c2 01             	add    $0x1,%edx
  800bb8:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bbd:	eb ce                	jmp    800b8d <strtol+0x40>
		s += 2, base = 16;
  800bbf:	83 c2 02             	add    $0x2,%edx
  800bc2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bc7:	eb c4                	jmp    800b8d <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bc9:	0f be c0             	movsbl %al,%eax
  800bcc:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bcf:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bd2:	7d 3a                	jge    800c0e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bd4:	83 c2 01             	add    $0x1,%edx
  800bd7:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bdb:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800bdd:	0f b6 02             	movzbl (%edx),%eax
  800be0:	8d 70 d0             	lea    -0x30(%eax),%esi
  800be3:	89 f3                	mov    %esi,%ebx
  800be5:	80 fb 09             	cmp    $0x9,%bl
  800be8:	76 df                	jbe    800bc9 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bea:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bed:	89 f3                	mov    %esi,%ebx
  800bef:	80 fb 19             	cmp    $0x19,%bl
  800bf2:	77 08                	ja     800bfc <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bf4:	0f be c0             	movsbl %al,%eax
  800bf7:	83 e8 57             	sub    $0x57,%eax
  800bfa:	eb d3                	jmp    800bcf <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bfc:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bff:	89 f3                	mov    %esi,%ebx
  800c01:	80 fb 19             	cmp    $0x19,%bl
  800c04:	77 08                	ja     800c0e <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c06:	0f be c0             	movsbl %al,%eax
  800c09:	83 e8 37             	sub    $0x37,%eax
  800c0c:	eb c1                	jmp    800bcf <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c0e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c12:	74 05                	je     800c19 <strtol+0xcc>
		*endptr = (char *) s;
  800c14:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c17:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c19:	89 c8                	mov    %ecx,%eax
  800c1b:	f7 d8                	neg    %eax
  800c1d:	85 ff                	test   %edi,%edi
  800c1f:	0f 45 c8             	cmovne %eax,%ecx
}
  800c22:	89 c8                	mov    %ecx,%eax
  800c24:	5b                   	pop    %ebx
  800c25:	5e                   	pop    %esi
  800c26:	5f                   	pop    %edi
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    
  800c29:	66 90                	xchg   %ax,%ax
  800c2b:	66 90                	xchg   %ax,%ax
  800c2d:	66 90                	xchg   %ax,%ax
  800c2f:	90                   	nop

00800c30 <__udivdi3>:
  800c30:	f3 0f 1e fb          	endbr32 
  800c34:	55                   	push   %ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	83 ec 1c             	sub    $0x1c,%esp
  800c3b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800c3f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800c43:	8b 74 24 34          	mov    0x34(%esp),%esi
  800c47:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800c4b:	85 c0                	test   %eax,%eax
  800c4d:	75 19                	jne    800c68 <__udivdi3+0x38>
  800c4f:	39 f3                	cmp    %esi,%ebx
  800c51:	76 4d                	jbe    800ca0 <__udivdi3+0x70>
  800c53:	31 ff                	xor    %edi,%edi
  800c55:	89 e8                	mov    %ebp,%eax
  800c57:	89 f2                	mov    %esi,%edx
  800c59:	f7 f3                	div    %ebx
  800c5b:	89 fa                	mov    %edi,%edx
  800c5d:	83 c4 1c             	add    $0x1c,%esp
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5f                   	pop    %edi
  800c63:	5d                   	pop    %ebp
  800c64:	c3                   	ret    
  800c65:	8d 76 00             	lea    0x0(%esi),%esi
  800c68:	39 f0                	cmp    %esi,%eax
  800c6a:	76 14                	jbe    800c80 <__udivdi3+0x50>
  800c6c:	31 ff                	xor    %edi,%edi
  800c6e:	31 c0                	xor    %eax,%eax
  800c70:	89 fa                	mov    %edi,%edx
  800c72:	83 c4 1c             	add    $0x1c,%esp
  800c75:	5b                   	pop    %ebx
  800c76:	5e                   	pop    %esi
  800c77:	5f                   	pop    %edi
  800c78:	5d                   	pop    %ebp
  800c79:	c3                   	ret    
  800c7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800c80:	0f bd f8             	bsr    %eax,%edi
  800c83:	83 f7 1f             	xor    $0x1f,%edi
  800c86:	75 48                	jne    800cd0 <__udivdi3+0xa0>
  800c88:	39 f0                	cmp    %esi,%eax
  800c8a:	72 06                	jb     800c92 <__udivdi3+0x62>
  800c8c:	31 c0                	xor    %eax,%eax
  800c8e:	39 eb                	cmp    %ebp,%ebx
  800c90:	77 de                	ja     800c70 <__udivdi3+0x40>
  800c92:	b8 01 00 00 00       	mov    $0x1,%eax
  800c97:	eb d7                	jmp    800c70 <__udivdi3+0x40>
  800c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ca0:	89 d9                	mov    %ebx,%ecx
  800ca2:	85 db                	test   %ebx,%ebx
  800ca4:	75 0b                	jne    800cb1 <__udivdi3+0x81>
  800ca6:	b8 01 00 00 00       	mov    $0x1,%eax
  800cab:	31 d2                	xor    %edx,%edx
  800cad:	f7 f3                	div    %ebx
  800caf:	89 c1                	mov    %eax,%ecx
  800cb1:	31 d2                	xor    %edx,%edx
  800cb3:	89 f0                	mov    %esi,%eax
  800cb5:	f7 f1                	div    %ecx
  800cb7:	89 c6                	mov    %eax,%esi
  800cb9:	89 e8                	mov    %ebp,%eax
  800cbb:	89 f7                	mov    %esi,%edi
  800cbd:	f7 f1                	div    %ecx
  800cbf:	89 fa                	mov    %edi,%edx
  800cc1:	83 c4 1c             	add    $0x1c,%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    
  800cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800cd0:	89 f9                	mov    %edi,%ecx
  800cd2:	ba 20 00 00 00       	mov    $0x20,%edx
  800cd7:	29 fa                	sub    %edi,%edx
  800cd9:	d3 e0                	shl    %cl,%eax
  800cdb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cdf:	89 d1                	mov    %edx,%ecx
  800ce1:	89 d8                	mov    %ebx,%eax
  800ce3:	d3 e8                	shr    %cl,%eax
  800ce5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800ce9:	09 c1                	or     %eax,%ecx
  800ceb:	89 f0                	mov    %esi,%eax
  800ced:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800cf1:	89 f9                	mov    %edi,%ecx
  800cf3:	d3 e3                	shl    %cl,%ebx
  800cf5:	89 d1                	mov    %edx,%ecx
  800cf7:	d3 e8                	shr    %cl,%eax
  800cf9:	89 f9                	mov    %edi,%ecx
  800cfb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800cff:	89 eb                	mov    %ebp,%ebx
  800d01:	d3 e6                	shl    %cl,%esi
  800d03:	89 d1                	mov    %edx,%ecx
  800d05:	d3 eb                	shr    %cl,%ebx
  800d07:	09 f3                	or     %esi,%ebx
  800d09:	89 c6                	mov    %eax,%esi
  800d0b:	89 f2                	mov    %esi,%edx
  800d0d:	89 d8                	mov    %ebx,%eax
  800d0f:	f7 74 24 08          	divl   0x8(%esp)
  800d13:	89 d6                	mov    %edx,%esi
  800d15:	89 c3                	mov    %eax,%ebx
  800d17:	f7 64 24 0c          	mull   0xc(%esp)
  800d1b:	39 d6                	cmp    %edx,%esi
  800d1d:	72 19                	jb     800d38 <__udivdi3+0x108>
  800d1f:	89 f9                	mov    %edi,%ecx
  800d21:	d3 e5                	shl    %cl,%ebp
  800d23:	39 c5                	cmp    %eax,%ebp
  800d25:	73 04                	jae    800d2b <__udivdi3+0xfb>
  800d27:	39 d6                	cmp    %edx,%esi
  800d29:	74 0d                	je     800d38 <__udivdi3+0x108>
  800d2b:	89 d8                	mov    %ebx,%eax
  800d2d:	31 ff                	xor    %edi,%edi
  800d2f:	e9 3c ff ff ff       	jmp    800c70 <__udivdi3+0x40>
  800d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d38:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800d3b:	31 ff                	xor    %edi,%edi
  800d3d:	e9 2e ff ff ff       	jmp    800c70 <__udivdi3+0x40>
  800d42:	66 90                	xchg   %ax,%ax
  800d44:	66 90                	xchg   %ax,%ax
  800d46:	66 90                	xchg   %ax,%ax
  800d48:	66 90                	xchg   %ax,%ax
  800d4a:	66 90                	xchg   %ax,%ax
  800d4c:	66 90                	xchg   %ax,%ax
  800d4e:	66 90                	xchg   %ax,%ax

00800d50 <__umoddi3>:
  800d50:	f3 0f 1e fb          	endbr32 
  800d54:	55                   	push   %ebp
  800d55:	57                   	push   %edi
  800d56:	56                   	push   %esi
  800d57:	53                   	push   %ebx
  800d58:	83 ec 1c             	sub    $0x1c,%esp
  800d5b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800d5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800d63:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800d67:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800d6b:	89 f0                	mov    %esi,%eax
  800d6d:	89 da                	mov    %ebx,%edx
  800d6f:	85 ff                	test   %edi,%edi
  800d71:	75 15                	jne    800d88 <__umoddi3+0x38>
  800d73:	39 dd                	cmp    %ebx,%ebp
  800d75:	76 39                	jbe    800db0 <__umoddi3+0x60>
  800d77:	f7 f5                	div    %ebp
  800d79:	89 d0                	mov    %edx,%eax
  800d7b:	31 d2                	xor    %edx,%edx
  800d7d:	83 c4 1c             	add    $0x1c,%esp
  800d80:	5b                   	pop    %ebx
  800d81:	5e                   	pop    %esi
  800d82:	5f                   	pop    %edi
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    
  800d85:	8d 76 00             	lea    0x0(%esi),%esi
  800d88:	39 df                	cmp    %ebx,%edi
  800d8a:	77 f1                	ja     800d7d <__umoddi3+0x2d>
  800d8c:	0f bd cf             	bsr    %edi,%ecx
  800d8f:	83 f1 1f             	xor    $0x1f,%ecx
  800d92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800d96:	75 40                	jne    800dd8 <__umoddi3+0x88>
  800d98:	39 df                	cmp    %ebx,%edi
  800d9a:	72 04                	jb     800da0 <__umoddi3+0x50>
  800d9c:	39 f5                	cmp    %esi,%ebp
  800d9e:	77 dd                	ja     800d7d <__umoddi3+0x2d>
  800da0:	89 da                	mov    %ebx,%edx
  800da2:	89 f0                	mov    %esi,%eax
  800da4:	29 e8                	sub    %ebp,%eax
  800da6:	19 fa                	sbb    %edi,%edx
  800da8:	eb d3                	jmp    800d7d <__umoddi3+0x2d>
  800daa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800db0:	89 e9                	mov    %ebp,%ecx
  800db2:	85 ed                	test   %ebp,%ebp
  800db4:	75 0b                	jne    800dc1 <__umoddi3+0x71>
  800db6:	b8 01 00 00 00       	mov    $0x1,%eax
  800dbb:	31 d2                	xor    %edx,%edx
  800dbd:	f7 f5                	div    %ebp
  800dbf:	89 c1                	mov    %eax,%ecx
  800dc1:	89 d8                	mov    %ebx,%eax
  800dc3:	31 d2                	xor    %edx,%edx
  800dc5:	f7 f1                	div    %ecx
  800dc7:	89 f0                	mov    %esi,%eax
  800dc9:	f7 f1                	div    %ecx
  800dcb:	89 d0                	mov    %edx,%eax
  800dcd:	31 d2                	xor    %edx,%edx
  800dcf:	eb ac                	jmp    800d7d <__umoddi3+0x2d>
  800dd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dd8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ddc:	ba 20 00 00 00       	mov    $0x20,%edx
  800de1:	29 c2                	sub    %eax,%edx
  800de3:	89 c1                	mov    %eax,%ecx
  800de5:	89 e8                	mov    %ebp,%eax
  800de7:	d3 e7                	shl    %cl,%edi
  800de9:	89 d1                	mov    %edx,%ecx
  800deb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800def:	d3 e8                	shr    %cl,%eax
  800df1:	89 c1                	mov    %eax,%ecx
  800df3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800df7:	09 f9                	or     %edi,%ecx
  800df9:	89 df                	mov    %ebx,%edi
  800dfb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dff:	89 c1                	mov    %eax,%ecx
  800e01:	d3 e5                	shl    %cl,%ebp
  800e03:	89 d1                	mov    %edx,%ecx
  800e05:	d3 ef                	shr    %cl,%edi
  800e07:	89 c1                	mov    %eax,%ecx
  800e09:	89 f0                	mov    %esi,%eax
  800e0b:	d3 e3                	shl    %cl,%ebx
  800e0d:	89 d1                	mov    %edx,%ecx
  800e0f:	89 fa                	mov    %edi,%edx
  800e11:	d3 e8                	shr    %cl,%eax
  800e13:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800e18:	09 d8                	or     %ebx,%eax
  800e1a:	f7 74 24 08          	divl   0x8(%esp)
  800e1e:	89 d3                	mov    %edx,%ebx
  800e20:	d3 e6                	shl    %cl,%esi
  800e22:	f7 e5                	mul    %ebp
  800e24:	89 c7                	mov    %eax,%edi
  800e26:	89 d1                	mov    %edx,%ecx
  800e28:	39 d3                	cmp    %edx,%ebx
  800e2a:	72 06                	jb     800e32 <__umoddi3+0xe2>
  800e2c:	75 0e                	jne    800e3c <__umoddi3+0xec>
  800e2e:	39 c6                	cmp    %eax,%esi
  800e30:	73 0a                	jae    800e3c <__umoddi3+0xec>
  800e32:	29 e8                	sub    %ebp,%eax
  800e34:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800e38:	89 d1                	mov    %edx,%ecx
  800e3a:	89 c7                	mov    %eax,%edi
  800e3c:	89 f5                	mov    %esi,%ebp
  800e3e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e42:	29 fd                	sub    %edi,%ebp
  800e44:	19 cb                	sbb    %ecx,%ebx
  800e46:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800e4b:	89 d8                	mov    %ebx,%eax
  800e4d:	d3 e0                	shl    %cl,%eax
  800e4f:	89 f1                	mov    %esi,%ecx
  800e51:	d3 ed                	shr    %cl,%ebp
  800e53:	d3 eb                	shr    %cl,%ebx
  800e55:	09 e8                	or     %ebp,%eax
  800e57:	89 da                	mov    %ebx,%edx
  800e59:	83 c4 1c             	add    $0x1c,%esp
  800e5c:	5b                   	pop    %ebx
  800e5d:	5e                   	pop    %esi
  800e5e:	5f                   	pop    %edi
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    
