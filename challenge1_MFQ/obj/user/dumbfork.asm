
obj/user/dumbfork.debug：     文件格式 elf32-i386


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
  80002c:	e8 9d 01 00 00       	call   8001ce <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	8b 75 08             	mov    0x8(%ebp),%esi
  80003b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  80003e:	83 ec 04             	sub    $0x4,%esp
  800041:	6a 07                	push   $0x7
  800043:	53                   	push   %ebx
  800044:	56                   	push   %esi
  800045:	e8 98 0c 00 00       	call   800ce2 <sys_page_alloc>
  80004a:	83 c4 10             	add    $0x10,%esp
  80004d:	85 c0                	test   %eax,%eax
  80004f:	78 4a                	js     80009b <duppage+0x68>
		panic("sys_page_alloc: %e", r);
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800051:	83 ec 0c             	sub    $0xc,%esp
  800054:	6a 07                	push   $0x7
  800056:	68 00 00 40 00       	push   $0x400000
  80005b:	6a 00                	push   $0x0
  80005d:	53                   	push   %ebx
  80005e:	56                   	push   %esi
  80005f:	e8 c1 0c 00 00       	call   800d25 <sys_page_map>
  800064:	83 c4 20             	add    $0x20,%esp
  800067:	85 c0                	test   %eax,%eax
  800069:	78 42                	js     8000ad <duppage+0x7a>
		panic("sys_page_map: %e", r);
	memmove(UTEMP, addr, PGSIZE);
  80006b:	83 ec 04             	sub    $0x4,%esp
  80006e:	68 00 10 00 00       	push   $0x1000
  800073:	53                   	push   %ebx
  800074:	68 00 00 40 00       	push   $0x400000
  800079:	e8 fe 09 00 00       	call   800a7c <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80007e:	83 c4 08             	add    $0x8,%esp
  800081:	68 00 00 40 00       	push   $0x400000
  800086:	6a 00                	push   $0x0
  800088:	e8 da 0c 00 00       	call   800d67 <sys_page_unmap>
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	85 c0                	test   %eax,%eax
  800092:	78 2b                	js     8000bf <duppage+0x8c>
		panic("sys_page_unmap: %e", r);
}
  800094:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800097:	5b                   	pop    %ebx
  800098:	5e                   	pop    %esi
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    
		panic("sys_page_alloc: %e", r);
  80009b:	50                   	push   %eax
  80009c:	68 e0 23 80 00       	push   $0x8023e0
  8000a1:	6a 20                	push   $0x20
  8000a3:	68 f3 23 80 00       	push   $0x8023f3
  8000a8:	e8 84 01 00 00       	call   800231 <_panic>
		panic("sys_page_map: %e", r);
  8000ad:	50                   	push   %eax
  8000ae:	68 03 24 80 00       	push   $0x802403
  8000b3:	6a 22                	push   $0x22
  8000b5:	68 f3 23 80 00       	push   $0x8023f3
  8000ba:	e8 72 01 00 00       	call   800231 <_panic>
		panic("sys_page_unmap: %e", r);
  8000bf:	50                   	push   %eax
  8000c0:	68 14 24 80 00       	push   $0x802414
  8000c5:	6a 25                	push   $0x25
  8000c7:	68 f3 23 80 00       	push   $0x8023f3
  8000cc:	e8 60 01 00 00       	call   800231 <_panic>

008000d1 <dumbfork>:

envid_t
dumbfork(void)
{
  8000d1:	55                   	push   %ebp
  8000d2:	89 e5                	mov    %esp,%ebp
  8000d4:	53                   	push   %ebx
  8000d5:	83 ec 14             	sub    $0x14,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8000d8:	b8 07 00 00 00       	mov    $0x7,%eax
  8000dd:	cd 30                	int    $0x30
  8000df:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	78 23                	js     800108 <dumbfork+0x37>
  8000e5:	ba 00 00 80 00       	mov    $0x800000,%edx
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  8000ea:	75 44                	jne    800130 <dumbfork+0x5f>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000ec:	e8 b3 0b 00 00       	call   800ca4 <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8000fc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800101:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  800106:	eb 57                	jmp    80015f <dumbfork+0x8e>
		panic("sys_exofork: %e", envid);
  800108:	50                   	push   %eax
  800109:	68 27 24 80 00       	push   $0x802427
  80010e:	6a 37                	push   $0x37
  800110:	68 f3 23 80 00       	push   $0x8023f3
  800115:	e8 17 01 00 00       	call   800231 <_panic>

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
		duppage(envid, addr);
  80011a:	83 ec 08             	sub    $0x8,%esp
  80011d:	52                   	push   %edx
  80011e:	53                   	push   %ebx
  80011f:	e8 0f ff ff ff       	call   800033 <duppage>
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800124:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800127:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  80012d:	83 c4 10             	add    $0x10,%esp
  800130:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800133:	81 fa 04 80 80 00    	cmp    $0x808004,%edx
  800139:	72 df                	jb     80011a <dumbfork+0x49>

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  80013b:	83 ec 08             	sub    $0x8,%esp
  80013e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800141:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800146:	50                   	push   %eax
  800147:	53                   	push   %ebx
  800148:	e8 e6 fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80014d:	83 c4 08             	add    $0x8,%esp
  800150:	6a 02                	push   $0x2
  800152:	53                   	push   %ebx
  800153:	e8 51 0c 00 00       	call   800da9 <sys_env_set_status>
  800158:	83 c4 10             	add    $0x10,%esp
  80015b:	85 c0                	test   %eax,%eax
  80015d:	78 07                	js     800166 <dumbfork+0x95>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  80015f:	89 d8                	mov    %ebx,%eax
  800161:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800164:	c9                   	leave  
  800165:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  800166:	50                   	push   %eax
  800167:	68 37 24 80 00       	push   $0x802437
  80016c:	6a 4c                	push   $0x4c
  80016e:	68 f3 23 80 00       	push   $0x8023f3
  800173:	e8 b9 00 00 00       	call   800231 <_panic>

00800178 <umain>:
{
  800178:	55                   	push   %ebp
  800179:	89 e5                	mov    %esp,%ebp
  80017b:	57                   	push   %edi
  80017c:	56                   	push   %esi
  80017d:	53                   	push   %ebx
  80017e:	83 ec 0c             	sub    $0xc,%esp
	who = dumbfork();
  800181:	e8 4b ff ff ff       	call   8000d1 <dumbfork>
  800186:	89 c6                	mov    %eax,%esi
  800188:	85 c0                	test   %eax,%eax
  80018a:	bf 4e 24 80 00       	mov    $0x80244e,%edi
  80018f:	b8 55 24 80 00       	mov    $0x802455,%eax
  800194:	0f 44 f8             	cmove  %eax,%edi
	for (i = 0; i < (who ? 10 : 20); i++) {
  800197:	bb 00 00 00 00       	mov    $0x0,%ebx
  80019c:	eb 1f                	jmp    8001bd <umain+0x45>
  80019e:	83 fb 13             	cmp    $0x13,%ebx
  8001a1:	7f 23                	jg     8001c6 <umain+0x4e>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001a3:	83 ec 04             	sub    $0x4,%esp
  8001a6:	57                   	push   %edi
  8001a7:	53                   	push   %ebx
  8001a8:	68 5b 24 80 00       	push   $0x80245b
  8001ad:	e8 5a 01 00 00       	call   80030c <cprintf>
		sys_yield();
  8001b2:	e8 0c 0b 00 00       	call   800cc3 <sys_yield>
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001b7:	83 c3 01             	add    $0x1,%ebx
  8001ba:	83 c4 10             	add    $0x10,%esp
  8001bd:	85 f6                	test   %esi,%esi
  8001bf:	74 dd                	je     80019e <umain+0x26>
  8001c1:	83 fb 09             	cmp    $0x9,%ebx
  8001c4:	7e dd                	jle    8001a3 <umain+0x2b>
}
  8001c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c9:	5b                   	pop    %ebx
  8001ca:	5e                   	pop    %esi
  8001cb:	5f                   	pop    %edi
  8001cc:	5d                   	pop    %ebp
  8001cd:	c3                   	ret    

008001ce <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001ce:	55                   	push   %ebp
  8001cf:	89 e5                	mov    %esp,%ebp
  8001d1:	56                   	push   %esi
  8001d2:	53                   	push   %ebx
  8001d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001d6:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8001d9:	e8 c6 0a 00 00       	call   800ca4 <sys_getenvid>
  8001de:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e3:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  8001e9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001ee:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001f3:	85 db                	test   %ebx,%ebx
  8001f5:	7e 07                	jle    8001fe <libmain+0x30>
		binaryname = argv[0];
  8001f7:	8b 06                	mov    (%esi),%eax
  8001f9:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001fe:	83 ec 08             	sub    $0x8,%esp
  800201:	56                   	push   %esi
  800202:	53                   	push   %ebx
  800203:	e8 70 ff ff ff       	call   800178 <umain>

	// exit gracefully
	exit();
  800208:	e8 0a 00 00 00       	call   800217 <exit>
}
  80020d:	83 c4 10             	add    $0x10,%esp
  800210:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800213:	5b                   	pop    %ebx
  800214:	5e                   	pop    %esi
  800215:	5d                   	pop    %ebp
  800216:	c3                   	ret    

00800217 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800217:	55                   	push   %ebp
  800218:	89 e5                	mov    %esp,%ebp
  80021a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80021d:	e8 e3 0e 00 00       	call   801105 <close_all>
	sys_env_destroy(0);
  800222:	83 ec 0c             	sub    $0xc,%esp
  800225:	6a 00                	push   $0x0
  800227:	e8 37 0a 00 00       	call   800c63 <sys_env_destroy>
}
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	c9                   	leave  
  800230:	c3                   	ret    

00800231 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800236:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800239:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80023f:	e8 60 0a 00 00       	call   800ca4 <sys_getenvid>
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	ff 75 0c             	push   0xc(%ebp)
  80024a:	ff 75 08             	push   0x8(%ebp)
  80024d:	56                   	push   %esi
  80024e:	50                   	push   %eax
  80024f:	68 78 24 80 00       	push   $0x802478
  800254:	e8 b3 00 00 00       	call   80030c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800259:	83 c4 18             	add    $0x18,%esp
  80025c:	53                   	push   %ebx
  80025d:	ff 75 10             	push   0x10(%ebp)
  800260:	e8 56 00 00 00       	call   8002bb <vcprintf>
	cprintf("\n");
  800265:	c7 04 24 6b 24 80 00 	movl   $0x80246b,(%esp)
  80026c:	e8 9b 00 00 00       	call   80030c <cprintf>
  800271:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800274:	cc                   	int3   
  800275:	eb fd                	jmp    800274 <_panic+0x43>

00800277 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	53                   	push   %ebx
  80027b:	83 ec 04             	sub    $0x4,%esp
  80027e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800281:	8b 13                	mov    (%ebx),%edx
  800283:	8d 42 01             	lea    0x1(%edx),%eax
  800286:	89 03                	mov    %eax,(%ebx)
  800288:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80028b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80028f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800294:	74 09                	je     80029f <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800296:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80029a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80029d:	c9                   	leave  
  80029e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80029f:	83 ec 08             	sub    $0x8,%esp
  8002a2:	68 ff 00 00 00       	push   $0xff
  8002a7:	8d 43 08             	lea    0x8(%ebx),%eax
  8002aa:	50                   	push   %eax
  8002ab:	e8 76 09 00 00       	call   800c26 <sys_cputs>
		b->idx = 0;
  8002b0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b6:	83 c4 10             	add    $0x10,%esp
  8002b9:	eb db                	jmp    800296 <putch+0x1f>

008002bb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002c4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002cb:	00 00 00 
	b.cnt = 0;
  8002ce:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002d5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d8:	ff 75 0c             	push   0xc(%ebp)
  8002db:	ff 75 08             	push   0x8(%ebp)
  8002de:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002e4:	50                   	push   %eax
  8002e5:	68 77 02 80 00       	push   $0x800277
  8002ea:	e8 14 01 00 00       	call   800403 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002ef:	83 c4 08             	add    $0x8,%esp
  8002f2:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8002f8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002fe:	50                   	push   %eax
  8002ff:	e8 22 09 00 00       	call   800c26 <sys_cputs>

	return b.cnt;
}
  800304:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80030a:	c9                   	leave  
  80030b:	c3                   	ret    

0080030c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
  80030f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800312:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800315:	50                   	push   %eax
  800316:	ff 75 08             	push   0x8(%ebp)
  800319:	e8 9d ff ff ff       	call   8002bb <vcprintf>
	va_end(ap);

	return cnt;
}
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 1c             	sub    $0x1c,%esp
  800329:	89 c7                	mov    %eax,%edi
  80032b:	89 d6                	mov    %edx,%esi
  80032d:	8b 45 08             	mov    0x8(%ebp),%eax
  800330:	8b 55 0c             	mov    0xc(%ebp),%edx
  800333:	89 d1                	mov    %edx,%ecx
  800335:	89 c2                	mov    %eax,%edx
  800337:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80033a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80033d:	8b 45 10             	mov    0x10(%ebp),%eax
  800340:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800343:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800346:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80034d:	39 c2                	cmp    %eax,%edx
  80034f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800352:	72 3e                	jb     800392 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800354:	83 ec 0c             	sub    $0xc,%esp
  800357:	ff 75 18             	push   0x18(%ebp)
  80035a:	83 eb 01             	sub    $0x1,%ebx
  80035d:	53                   	push   %ebx
  80035e:	50                   	push   %eax
  80035f:	83 ec 08             	sub    $0x8,%esp
  800362:	ff 75 e4             	push   -0x1c(%ebp)
  800365:	ff 75 e0             	push   -0x20(%ebp)
  800368:	ff 75 dc             	push   -0x24(%ebp)
  80036b:	ff 75 d8             	push   -0x28(%ebp)
  80036e:	e8 1d 1e 00 00       	call   802190 <__udivdi3>
  800373:	83 c4 18             	add    $0x18,%esp
  800376:	52                   	push   %edx
  800377:	50                   	push   %eax
  800378:	89 f2                	mov    %esi,%edx
  80037a:	89 f8                	mov    %edi,%eax
  80037c:	e8 9f ff ff ff       	call   800320 <printnum>
  800381:	83 c4 20             	add    $0x20,%esp
  800384:	eb 13                	jmp    800399 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800386:	83 ec 08             	sub    $0x8,%esp
  800389:	56                   	push   %esi
  80038a:	ff 75 18             	push   0x18(%ebp)
  80038d:	ff d7                	call   *%edi
  80038f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800392:	83 eb 01             	sub    $0x1,%ebx
  800395:	85 db                	test   %ebx,%ebx
  800397:	7f ed                	jg     800386 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800399:	83 ec 08             	sub    $0x8,%esp
  80039c:	56                   	push   %esi
  80039d:	83 ec 04             	sub    $0x4,%esp
  8003a0:	ff 75 e4             	push   -0x1c(%ebp)
  8003a3:	ff 75 e0             	push   -0x20(%ebp)
  8003a6:	ff 75 dc             	push   -0x24(%ebp)
  8003a9:	ff 75 d8             	push   -0x28(%ebp)
  8003ac:	e8 ff 1e 00 00       	call   8022b0 <__umoddi3>
  8003b1:	83 c4 14             	add    $0x14,%esp
  8003b4:	0f be 80 9b 24 80 00 	movsbl 0x80249b(%eax),%eax
  8003bb:	50                   	push   %eax
  8003bc:	ff d7                	call   *%edi
}
  8003be:	83 c4 10             	add    $0x10,%esp
  8003c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003c4:	5b                   	pop    %ebx
  8003c5:	5e                   	pop    %esi
  8003c6:	5f                   	pop    %edi
  8003c7:	5d                   	pop    %ebp
  8003c8:	c3                   	ret    

008003c9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003c9:	55                   	push   %ebp
  8003ca:	89 e5                	mov    %esp,%ebp
  8003cc:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003cf:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003d3:	8b 10                	mov    (%eax),%edx
  8003d5:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d8:	73 0a                	jae    8003e4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003da:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003dd:	89 08                	mov    %ecx,(%eax)
  8003df:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e2:	88 02                	mov    %al,(%edx)
}
  8003e4:	5d                   	pop    %ebp
  8003e5:	c3                   	ret    

008003e6 <printfmt>:
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
  8003e9:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003ec:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003ef:	50                   	push   %eax
  8003f0:	ff 75 10             	push   0x10(%ebp)
  8003f3:	ff 75 0c             	push   0xc(%ebp)
  8003f6:	ff 75 08             	push   0x8(%ebp)
  8003f9:	e8 05 00 00 00       	call   800403 <vprintfmt>
}
  8003fe:	83 c4 10             	add    $0x10,%esp
  800401:	c9                   	leave  
  800402:	c3                   	ret    

00800403 <vprintfmt>:
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	57                   	push   %edi
  800407:	56                   	push   %esi
  800408:	53                   	push   %ebx
  800409:	83 ec 3c             	sub    $0x3c,%esp
  80040c:	8b 75 08             	mov    0x8(%ebp),%esi
  80040f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800412:	8b 7d 10             	mov    0x10(%ebp),%edi
  800415:	eb 0a                	jmp    800421 <vprintfmt+0x1e>
			putch(ch, putdat);
  800417:	83 ec 08             	sub    $0x8,%esp
  80041a:	53                   	push   %ebx
  80041b:	50                   	push   %eax
  80041c:	ff d6                	call   *%esi
  80041e:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800421:	83 c7 01             	add    $0x1,%edi
  800424:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800428:	83 f8 25             	cmp    $0x25,%eax
  80042b:	74 0c                	je     800439 <vprintfmt+0x36>
			if (ch == '\0')
  80042d:	85 c0                	test   %eax,%eax
  80042f:	75 e6                	jne    800417 <vprintfmt+0x14>
}
  800431:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800434:	5b                   	pop    %ebx
  800435:	5e                   	pop    %esi
  800436:	5f                   	pop    %edi
  800437:	5d                   	pop    %ebp
  800438:	c3                   	ret    
		padc = ' ';
  800439:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80043d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800444:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80044b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800452:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800457:	8d 47 01             	lea    0x1(%edi),%eax
  80045a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80045d:	0f b6 17             	movzbl (%edi),%edx
  800460:	8d 42 dd             	lea    -0x23(%edx),%eax
  800463:	3c 55                	cmp    $0x55,%al
  800465:	0f 87 bb 03 00 00    	ja     800826 <vprintfmt+0x423>
  80046b:	0f b6 c0             	movzbl %al,%eax
  80046e:	ff 24 85 e0 25 80 00 	jmp    *0x8025e0(,%eax,4)
  800475:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800478:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80047c:	eb d9                	jmp    800457 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80047e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800481:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800485:	eb d0                	jmp    800457 <vprintfmt+0x54>
  800487:	0f b6 d2             	movzbl %dl,%edx
  80048a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80048d:	b8 00 00 00 00       	mov    $0x0,%eax
  800492:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800495:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800498:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80049c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80049f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004a2:	83 f9 09             	cmp    $0x9,%ecx
  8004a5:	77 55                	ja     8004fc <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8004a7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004aa:	eb e9                	jmp    800495 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8004ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8004af:	8b 00                	mov    (%eax),%eax
  8004b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b7:	8d 40 04             	lea    0x4(%eax),%eax
  8004ba:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004c0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c4:	79 91                	jns    800457 <vprintfmt+0x54>
				width = precision, precision = -1;
  8004c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004cc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004d3:	eb 82                	jmp    800457 <vprintfmt+0x54>
  8004d5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004d8:	85 d2                	test   %edx,%edx
  8004da:	b8 00 00 00 00       	mov    $0x0,%eax
  8004df:	0f 49 c2             	cmovns %edx,%eax
  8004e2:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004e8:	e9 6a ff ff ff       	jmp    800457 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8004ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004f0:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004f7:	e9 5b ff ff ff       	jmp    800457 <vprintfmt+0x54>
  8004fc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800502:	eb bc                	jmp    8004c0 <vprintfmt+0xbd>
			lflag++;
  800504:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80050a:	e9 48 ff ff ff       	jmp    800457 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80050f:	8b 45 14             	mov    0x14(%ebp),%eax
  800512:	8d 78 04             	lea    0x4(%eax),%edi
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	53                   	push   %ebx
  800519:	ff 30                	push   (%eax)
  80051b:	ff d6                	call   *%esi
			break;
  80051d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800520:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800523:	e9 9d 02 00 00       	jmp    8007c5 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8d 78 04             	lea    0x4(%eax),%edi
  80052e:	8b 10                	mov    (%eax),%edx
  800530:	89 d0                	mov    %edx,%eax
  800532:	f7 d8                	neg    %eax
  800534:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800537:	83 f8 0f             	cmp    $0xf,%eax
  80053a:	7f 23                	jg     80055f <vprintfmt+0x15c>
  80053c:	8b 14 85 40 27 80 00 	mov    0x802740(,%eax,4),%edx
  800543:	85 d2                	test   %edx,%edx
  800545:	74 18                	je     80055f <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800547:	52                   	push   %edx
  800548:	68 75 28 80 00       	push   $0x802875
  80054d:	53                   	push   %ebx
  80054e:	56                   	push   %esi
  80054f:	e8 92 fe ff ff       	call   8003e6 <printfmt>
  800554:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800557:	89 7d 14             	mov    %edi,0x14(%ebp)
  80055a:	e9 66 02 00 00       	jmp    8007c5 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80055f:	50                   	push   %eax
  800560:	68 b3 24 80 00       	push   $0x8024b3
  800565:	53                   	push   %ebx
  800566:	56                   	push   %esi
  800567:	e8 7a fe ff ff       	call   8003e6 <printfmt>
  80056c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80056f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800572:	e9 4e 02 00 00       	jmp    8007c5 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800577:	8b 45 14             	mov    0x14(%ebp),%eax
  80057a:	83 c0 04             	add    $0x4,%eax
  80057d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800585:	85 d2                	test   %edx,%edx
  800587:	b8 ac 24 80 00       	mov    $0x8024ac,%eax
  80058c:	0f 45 c2             	cmovne %edx,%eax
  80058f:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800592:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800596:	7e 06                	jle    80059e <vprintfmt+0x19b>
  800598:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80059c:	75 0d                	jne    8005ab <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80059e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8005a1:	89 c7                	mov    %eax,%edi
  8005a3:	03 45 e0             	add    -0x20(%ebp),%eax
  8005a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a9:	eb 55                	jmp    800600 <vprintfmt+0x1fd>
  8005ab:	83 ec 08             	sub    $0x8,%esp
  8005ae:	ff 75 d8             	push   -0x28(%ebp)
  8005b1:	ff 75 cc             	push   -0x34(%ebp)
  8005b4:	e8 0a 03 00 00       	call   8008c3 <strnlen>
  8005b9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005bc:	29 c1                	sub    %eax,%ecx
  8005be:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8005c1:	83 c4 10             	add    $0x10,%esp
  8005c4:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8005c6:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cd:	eb 0f                	jmp    8005de <vprintfmt+0x1db>
					putch(padc, putdat);
  8005cf:	83 ec 08             	sub    $0x8,%esp
  8005d2:	53                   	push   %ebx
  8005d3:	ff 75 e0             	push   -0x20(%ebp)
  8005d6:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d8:	83 ef 01             	sub    $0x1,%edi
  8005db:	83 c4 10             	add    $0x10,%esp
  8005de:	85 ff                	test   %edi,%edi
  8005e0:	7f ed                	jg     8005cf <vprintfmt+0x1cc>
  8005e2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005e5:	85 d2                	test   %edx,%edx
  8005e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ec:	0f 49 c2             	cmovns %edx,%eax
  8005ef:	29 c2                	sub    %eax,%edx
  8005f1:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005f4:	eb a8                	jmp    80059e <vprintfmt+0x19b>
					putch(ch, putdat);
  8005f6:	83 ec 08             	sub    $0x8,%esp
  8005f9:	53                   	push   %ebx
  8005fa:	52                   	push   %edx
  8005fb:	ff d6                	call   *%esi
  8005fd:	83 c4 10             	add    $0x10,%esp
  800600:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800603:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800605:	83 c7 01             	add    $0x1,%edi
  800608:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80060c:	0f be d0             	movsbl %al,%edx
  80060f:	85 d2                	test   %edx,%edx
  800611:	74 4b                	je     80065e <vprintfmt+0x25b>
  800613:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800617:	78 06                	js     80061f <vprintfmt+0x21c>
  800619:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80061d:	78 1e                	js     80063d <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80061f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800623:	74 d1                	je     8005f6 <vprintfmt+0x1f3>
  800625:	0f be c0             	movsbl %al,%eax
  800628:	83 e8 20             	sub    $0x20,%eax
  80062b:	83 f8 5e             	cmp    $0x5e,%eax
  80062e:	76 c6                	jbe    8005f6 <vprintfmt+0x1f3>
					putch('?', putdat);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	53                   	push   %ebx
  800634:	6a 3f                	push   $0x3f
  800636:	ff d6                	call   *%esi
  800638:	83 c4 10             	add    $0x10,%esp
  80063b:	eb c3                	jmp    800600 <vprintfmt+0x1fd>
  80063d:	89 cf                	mov    %ecx,%edi
  80063f:	eb 0e                	jmp    80064f <vprintfmt+0x24c>
				putch(' ', putdat);
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	53                   	push   %ebx
  800645:	6a 20                	push   $0x20
  800647:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800649:	83 ef 01             	sub    $0x1,%edi
  80064c:	83 c4 10             	add    $0x10,%esp
  80064f:	85 ff                	test   %edi,%edi
  800651:	7f ee                	jg     800641 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800653:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800656:	89 45 14             	mov    %eax,0x14(%ebp)
  800659:	e9 67 01 00 00       	jmp    8007c5 <vprintfmt+0x3c2>
  80065e:	89 cf                	mov    %ecx,%edi
  800660:	eb ed                	jmp    80064f <vprintfmt+0x24c>
	if (lflag >= 2)
  800662:	83 f9 01             	cmp    $0x1,%ecx
  800665:	7f 1b                	jg     800682 <vprintfmt+0x27f>
	else if (lflag)
  800667:	85 c9                	test   %ecx,%ecx
  800669:	74 63                	je     8006ce <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80066b:	8b 45 14             	mov    0x14(%ebp),%eax
  80066e:	8b 00                	mov    (%eax),%eax
  800670:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800673:	99                   	cltd   
  800674:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8d 40 04             	lea    0x4(%eax),%eax
  80067d:	89 45 14             	mov    %eax,0x14(%ebp)
  800680:	eb 17                	jmp    800699 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8b 50 04             	mov    0x4(%eax),%edx
  800688:	8b 00                	mov    (%eax),%eax
  80068a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80068d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800690:	8b 45 14             	mov    0x14(%ebp),%eax
  800693:	8d 40 08             	lea    0x8(%eax),%eax
  800696:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800699:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80069c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80069f:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8006a4:	85 c9                	test   %ecx,%ecx
  8006a6:	0f 89 ff 00 00 00    	jns    8007ab <vprintfmt+0x3a8>
				putch('-', putdat);
  8006ac:	83 ec 08             	sub    $0x8,%esp
  8006af:	53                   	push   %ebx
  8006b0:	6a 2d                	push   $0x2d
  8006b2:	ff d6                	call   *%esi
				num = -(long long) num;
  8006b4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006b7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006ba:	f7 da                	neg    %edx
  8006bc:	83 d1 00             	adc    $0x0,%ecx
  8006bf:	f7 d9                	neg    %ecx
  8006c1:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006c4:	bf 0a 00 00 00       	mov    $0xa,%edi
  8006c9:	e9 dd 00 00 00       	jmp    8007ab <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8006ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d1:	8b 00                	mov    (%eax),%eax
  8006d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d6:	99                   	cltd   
  8006d7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006da:	8b 45 14             	mov    0x14(%ebp),%eax
  8006dd:	8d 40 04             	lea    0x4(%eax),%eax
  8006e0:	89 45 14             	mov    %eax,0x14(%ebp)
  8006e3:	eb b4                	jmp    800699 <vprintfmt+0x296>
	if (lflag >= 2)
  8006e5:	83 f9 01             	cmp    $0x1,%ecx
  8006e8:	7f 1e                	jg     800708 <vprintfmt+0x305>
	else if (lflag)
  8006ea:	85 c9                	test   %ecx,%ecx
  8006ec:	74 32                	je     800720 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8006ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f1:	8b 10                	mov    (%eax),%edx
  8006f3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f8:	8d 40 04             	lea    0x4(%eax),%eax
  8006fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006fe:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  800703:	e9 a3 00 00 00       	jmp    8007ab <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800708:	8b 45 14             	mov    0x14(%ebp),%eax
  80070b:	8b 10                	mov    (%eax),%edx
  80070d:	8b 48 04             	mov    0x4(%eax),%ecx
  800710:	8d 40 08             	lea    0x8(%eax),%eax
  800713:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800716:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80071b:	e9 8b 00 00 00       	jmp    8007ab <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800720:	8b 45 14             	mov    0x14(%ebp),%eax
  800723:	8b 10                	mov    (%eax),%edx
  800725:	b9 00 00 00 00       	mov    $0x0,%ecx
  80072a:	8d 40 04             	lea    0x4(%eax),%eax
  80072d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800730:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800735:	eb 74                	jmp    8007ab <vprintfmt+0x3a8>
	if (lflag >= 2)
  800737:	83 f9 01             	cmp    $0x1,%ecx
  80073a:	7f 1b                	jg     800757 <vprintfmt+0x354>
	else if (lflag)
  80073c:	85 c9                	test   %ecx,%ecx
  80073e:	74 2c                	je     80076c <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800740:	8b 45 14             	mov    0x14(%ebp),%eax
  800743:	8b 10                	mov    (%eax),%edx
  800745:	b9 00 00 00 00       	mov    $0x0,%ecx
  80074a:	8d 40 04             	lea    0x4(%eax),%eax
  80074d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800750:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800755:	eb 54                	jmp    8007ab <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8b 10                	mov    (%eax),%edx
  80075c:	8b 48 04             	mov    0x4(%eax),%ecx
  80075f:	8d 40 08             	lea    0x8(%eax),%eax
  800762:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800765:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80076a:	eb 3f                	jmp    8007ab <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8b 10                	mov    (%eax),%edx
  800771:	b9 00 00 00 00       	mov    $0x0,%ecx
  800776:	8d 40 04             	lea    0x4(%eax),%eax
  800779:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80077c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800781:	eb 28                	jmp    8007ab <vprintfmt+0x3a8>
			putch('0', putdat);
  800783:	83 ec 08             	sub    $0x8,%esp
  800786:	53                   	push   %ebx
  800787:	6a 30                	push   $0x30
  800789:	ff d6                	call   *%esi
			putch('x', putdat);
  80078b:	83 c4 08             	add    $0x8,%esp
  80078e:	53                   	push   %ebx
  80078f:	6a 78                	push   $0x78
  800791:	ff d6                	call   *%esi
			num = (unsigned long long)
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	8b 10                	mov    (%eax),%edx
  800798:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80079d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8007a0:	8d 40 04             	lea    0x4(%eax),%eax
  8007a3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a6:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8007ab:	83 ec 0c             	sub    $0xc,%esp
  8007ae:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8007b2:	50                   	push   %eax
  8007b3:	ff 75 e0             	push   -0x20(%ebp)
  8007b6:	57                   	push   %edi
  8007b7:	51                   	push   %ecx
  8007b8:	52                   	push   %edx
  8007b9:	89 da                	mov    %ebx,%edx
  8007bb:	89 f0                	mov    %esi,%eax
  8007bd:	e8 5e fb ff ff       	call   800320 <printnum>
			break;
  8007c2:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007c8:	e9 54 fc ff ff       	jmp    800421 <vprintfmt+0x1e>
	if (lflag >= 2)
  8007cd:	83 f9 01             	cmp    $0x1,%ecx
  8007d0:	7f 1b                	jg     8007ed <vprintfmt+0x3ea>
	else if (lflag)
  8007d2:	85 c9                	test   %ecx,%ecx
  8007d4:	74 2c                	je     800802 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8007d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d9:	8b 10                	mov    (%eax),%edx
  8007db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007e0:	8d 40 04             	lea    0x4(%eax),%eax
  8007e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007e6:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8007eb:	eb be                	jmp    8007ab <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f0:	8b 10                	mov    (%eax),%edx
  8007f2:	8b 48 04             	mov    0x4(%eax),%ecx
  8007f5:	8d 40 08             	lea    0x8(%eax),%eax
  8007f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007fb:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  800800:	eb a9                	jmp    8007ab <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800802:	8b 45 14             	mov    0x14(%ebp),%eax
  800805:	8b 10                	mov    (%eax),%edx
  800807:	b9 00 00 00 00       	mov    $0x0,%ecx
  80080c:	8d 40 04             	lea    0x4(%eax),%eax
  80080f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800812:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800817:	eb 92                	jmp    8007ab <vprintfmt+0x3a8>
			putch(ch, putdat);
  800819:	83 ec 08             	sub    $0x8,%esp
  80081c:	53                   	push   %ebx
  80081d:	6a 25                	push   $0x25
  80081f:	ff d6                	call   *%esi
			break;
  800821:	83 c4 10             	add    $0x10,%esp
  800824:	eb 9f                	jmp    8007c5 <vprintfmt+0x3c2>
			putch('%', putdat);
  800826:	83 ec 08             	sub    $0x8,%esp
  800829:	53                   	push   %ebx
  80082a:	6a 25                	push   $0x25
  80082c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	89 f8                	mov    %edi,%eax
  800833:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800837:	74 05                	je     80083e <vprintfmt+0x43b>
  800839:	83 e8 01             	sub    $0x1,%eax
  80083c:	eb f5                	jmp    800833 <vprintfmt+0x430>
  80083e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800841:	eb 82                	jmp    8007c5 <vprintfmt+0x3c2>

00800843 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	83 ec 18             	sub    $0x18,%esp
  800849:	8b 45 08             	mov    0x8(%ebp),%eax
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80084f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800852:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800856:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800859:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800860:	85 c0                	test   %eax,%eax
  800862:	74 26                	je     80088a <vsnprintf+0x47>
  800864:	85 d2                	test   %edx,%edx
  800866:	7e 22                	jle    80088a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800868:	ff 75 14             	push   0x14(%ebp)
  80086b:	ff 75 10             	push   0x10(%ebp)
  80086e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800871:	50                   	push   %eax
  800872:	68 c9 03 80 00       	push   $0x8003c9
  800877:	e8 87 fb ff ff       	call   800403 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80087c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800882:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800885:	83 c4 10             	add    $0x10,%esp
}
  800888:	c9                   	leave  
  800889:	c3                   	ret    
		return -E_INVAL;
  80088a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088f:	eb f7                	jmp    800888 <vsnprintf+0x45>

00800891 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800897:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80089a:	50                   	push   %eax
  80089b:	ff 75 10             	push   0x10(%ebp)
  80089e:	ff 75 0c             	push   0xc(%ebp)
  8008a1:	ff 75 08             	push   0x8(%ebp)
  8008a4:	e8 9a ff ff ff       	call   800843 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a9:	c9                   	leave  
  8008aa:	c3                   	ret    

008008ab <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b6:	eb 03                	jmp    8008bb <strlen+0x10>
		n++;
  8008b8:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008bb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008bf:	75 f7                	jne    8008b8 <strlen+0xd>
	return n;
}
  8008c1:	5d                   	pop    %ebp
  8008c2:	c3                   	ret    

008008c3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c9:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008d1:	eb 03                	jmp    8008d6 <strnlen+0x13>
		n++;
  8008d3:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d6:	39 d0                	cmp    %edx,%eax
  8008d8:	74 08                	je     8008e2 <strnlen+0x1f>
  8008da:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008de:	75 f3                	jne    8008d3 <strnlen+0x10>
  8008e0:	89 c2                	mov    %eax,%edx
	return n;
}
  8008e2:	89 d0                	mov    %edx,%eax
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	53                   	push   %ebx
  8008ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8008f5:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008f9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008fc:	83 c0 01             	add    $0x1,%eax
  8008ff:	84 d2                	test   %dl,%dl
  800901:	75 f2                	jne    8008f5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800903:	89 c8                	mov    %ecx,%eax
  800905:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800908:	c9                   	leave  
  800909:	c3                   	ret    

0080090a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	53                   	push   %ebx
  80090e:	83 ec 10             	sub    $0x10,%esp
  800911:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800914:	53                   	push   %ebx
  800915:	e8 91 ff ff ff       	call   8008ab <strlen>
  80091a:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80091d:	ff 75 0c             	push   0xc(%ebp)
  800920:	01 d8                	add    %ebx,%eax
  800922:	50                   	push   %eax
  800923:	e8 be ff ff ff       	call   8008e6 <strcpy>
	return dst;
}
  800928:	89 d8                	mov    %ebx,%eax
  80092a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80092d:	c9                   	leave  
  80092e:	c3                   	ret    

0080092f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	56                   	push   %esi
  800933:	53                   	push   %ebx
  800934:	8b 75 08             	mov    0x8(%ebp),%esi
  800937:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093a:	89 f3                	mov    %esi,%ebx
  80093c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80093f:	89 f0                	mov    %esi,%eax
  800941:	eb 0f                	jmp    800952 <strncpy+0x23>
		*dst++ = *src;
  800943:	83 c0 01             	add    $0x1,%eax
  800946:	0f b6 0a             	movzbl (%edx),%ecx
  800949:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80094c:	80 f9 01             	cmp    $0x1,%cl
  80094f:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800952:	39 d8                	cmp    %ebx,%eax
  800954:	75 ed                	jne    800943 <strncpy+0x14>
	}
	return ret;
}
  800956:	89 f0                	mov    %esi,%eax
  800958:	5b                   	pop    %ebx
  800959:	5e                   	pop    %esi
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80095c:	55                   	push   %ebp
  80095d:	89 e5                	mov    %esp,%ebp
  80095f:	56                   	push   %esi
  800960:	53                   	push   %ebx
  800961:	8b 75 08             	mov    0x8(%ebp),%esi
  800964:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800967:	8b 55 10             	mov    0x10(%ebp),%edx
  80096a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80096c:	85 d2                	test   %edx,%edx
  80096e:	74 21                	je     800991 <strlcpy+0x35>
  800970:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800974:	89 f2                	mov    %esi,%edx
  800976:	eb 09                	jmp    800981 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800978:	83 c1 01             	add    $0x1,%ecx
  80097b:	83 c2 01             	add    $0x1,%edx
  80097e:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800981:	39 c2                	cmp    %eax,%edx
  800983:	74 09                	je     80098e <strlcpy+0x32>
  800985:	0f b6 19             	movzbl (%ecx),%ebx
  800988:	84 db                	test   %bl,%bl
  80098a:	75 ec                	jne    800978 <strlcpy+0x1c>
  80098c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80098e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800991:	29 f0                	sub    %esi,%eax
}
  800993:	5b                   	pop    %ebx
  800994:	5e                   	pop    %esi
  800995:	5d                   	pop    %ebp
  800996:	c3                   	ret    

00800997 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009a0:	eb 06                	jmp    8009a8 <strcmp+0x11>
		p++, q++;
  8009a2:	83 c1 01             	add    $0x1,%ecx
  8009a5:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009a8:	0f b6 01             	movzbl (%ecx),%eax
  8009ab:	84 c0                	test   %al,%al
  8009ad:	74 04                	je     8009b3 <strcmp+0x1c>
  8009af:	3a 02                	cmp    (%edx),%al
  8009b1:	74 ef                	je     8009a2 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009b3:	0f b6 c0             	movzbl %al,%eax
  8009b6:	0f b6 12             	movzbl (%edx),%edx
  8009b9:	29 d0                	sub    %edx,%eax
}
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	53                   	push   %ebx
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c7:	89 c3                	mov    %eax,%ebx
  8009c9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009cc:	eb 06                	jmp    8009d4 <strncmp+0x17>
		n--, p++, q++;
  8009ce:	83 c0 01             	add    $0x1,%eax
  8009d1:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009d4:	39 d8                	cmp    %ebx,%eax
  8009d6:	74 18                	je     8009f0 <strncmp+0x33>
  8009d8:	0f b6 08             	movzbl (%eax),%ecx
  8009db:	84 c9                	test   %cl,%cl
  8009dd:	74 04                	je     8009e3 <strncmp+0x26>
  8009df:	3a 0a                	cmp    (%edx),%cl
  8009e1:	74 eb                	je     8009ce <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e3:	0f b6 00             	movzbl (%eax),%eax
  8009e6:	0f b6 12             	movzbl (%edx),%edx
  8009e9:	29 d0                	sub    %edx,%eax
}
  8009eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ee:	c9                   	leave  
  8009ef:	c3                   	ret    
		return 0;
  8009f0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009f5:	eb f4                	jmp    8009eb <strncmp+0x2e>

008009f7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f7:	55                   	push   %ebp
  8009f8:	89 e5                	mov    %esp,%ebp
  8009fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a01:	eb 03                	jmp    800a06 <strchr+0xf>
  800a03:	83 c0 01             	add    $0x1,%eax
  800a06:	0f b6 10             	movzbl (%eax),%edx
  800a09:	84 d2                	test   %dl,%dl
  800a0b:	74 06                	je     800a13 <strchr+0x1c>
		if (*s == c)
  800a0d:	38 ca                	cmp    %cl,%dl
  800a0f:	75 f2                	jne    800a03 <strchr+0xc>
  800a11:	eb 05                	jmp    800a18 <strchr+0x21>
			return (char *) s;
	return 0;
  800a13:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a18:	5d                   	pop    %ebp
  800a19:	c3                   	ret    

00800a1a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1a:	55                   	push   %ebp
  800a1b:	89 e5                	mov    %esp,%ebp
  800a1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a20:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a24:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a27:	38 ca                	cmp    %cl,%dl
  800a29:	74 09                	je     800a34 <strfind+0x1a>
  800a2b:	84 d2                	test   %dl,%dl
  800a2d:	74 05                	je     800a34 <strfind+0x1a>
	for (; *s; s++)
  800a2f:	83 c0 01             	add    $0x1,%eax
  800a32:	eb f0                	jmp    800a24 <strfind+0xa>
			break;
	return (char *) s;
}
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	57                   	push   %edi
  800a3a:	56                   	push   %esi
  800a3b:	53                   	push   %ebx
  800a3c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a42:	85 c9                	test   %ecx,%ecx
  800a44:	74 2f                	je     800a75 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a46:	89 f8                	mov    %edi,%eax
  800a48:	09 c8                	or     %ecx,%eax
  800a4a:	a8 03                	test   $0x3,%al
  800a4c:	75 21                	jne    800a6f <memset+0x39>
		c &= 0xFF;
  800a4e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a52:	89 d0                	mov    %edx,%eax
  800a54:	c1 e0 08             	shl    $0x8,%eax
  800a57:	89 d3                	mov    %edx,%ebx
  800a59:	c1 e3 18             	shl    $0x18,%ebx
  800a5c:	89 d6                	mov    %edx,%esi
  800a5e:	c1 e6 10             	shl    $0x10,%esi
  800a61:	09 f3                	or     %esi,%ebx
  800a63:	09 da                	or     %ebx,%edx
  800a65:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a67:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a6a:	fc                   	cld    
  800a6b:	f3 ab                	rep stos %eax,%es:(%edi)
  800a6d:	eb 06                	jmp    800a75 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a72:	fc                   	cld    
  800a73:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a75:	89 f8                	mov    %edi,%eax
  800a77:	5b                   	pop    %ebx
  800a78:	5e                   	pop    %esi
  800a79:	5f                   	pop    %edi
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a7c:	55                   	push   %ebp
  800a7d:	89 e5                	mov    %esp,%ebp
  800a7f:	57                   	push   %edi
  800a80:	56                   	push   %esi
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
  800a84:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a87:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a8a:	39 c6                	cmp    %eax,%esi
  800a8c:	73 32                	jae    800ac0 <memmove+0x44>
  800a8e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a91:	39 c2                	cmp    %eax,%edx
  800a93:	76 2b                	jbe    800ac0 <memmove+0x44>
		s += n;
		d += n;
  800a95:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a98:	89 d6                	mov    %edx,%esi
  800a9a:	09 fe                	or     %edi,%esi
  800a9c:	09 ce                	or     %ecx,%esi
  800a9e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aa4:	75 0e                	jne    800ab4 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aa6:	83 ef 04             	sub    $0x4,%edi
  800aa9:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aac:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800aaf:	fd                   	std    
  800ab0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ab2:	eb 09                	jmp    800abd <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800ab4:	83 ef 01             	sub    $0x1,%edi
  800ab7:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aba:	fd                   	std    
  800abb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800abd:	fc                   	cld    
  800abe:	eb 1a                	jmp    800ada <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac0:	89 f2                	mov    %esi,%edx
  800ac2:	09 c2                	or     %eax,%edx
  800ac4:	09 ca                	or     %ecx,%edx
  800ac6:	f6 c2 03             	test   $0x3,%dl
  800ac9:	75 0a                	jne    800ad5 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800acb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ace:	89 c7                	mov    %eax,%edi
  800ad0:	fc                   	cld    
  800ad1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ad3:	eb 05                	jmp    800ada <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800ad5:	89 c7                	mov    %eax,%edi
  800ad7:	fc                   	cld    
  800ad8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ada:	5e                   	pop    %esi
  800adb:	5f                   	pop    %edi
  800adc:	5d                   	pop    %ebp
  800add:	c3                   	ret    

00800ade <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ade:	55                   	push   %ebp
  800adf:	89 e5                	mov    %esp,%ebp
  800ae1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ae4:	ff 75 10             	push   0x10(%ebp)
  800ae7:	ff 75 0c             	push   0xc(%ebp)
  800aea:	ff 75 08             	push   0x8(%ebp)
  800aed:	e8 8a ff ff ff       	call   800a7c <memmove>
}
  800af2:	c9                   	leave  
  800af3:	c3                   	ret    

00800af4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af4:	55                   	push   %ebp
  800af5:	89 e5                	mov    %esp,%ebp
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
  800af9:	8b 45 08             	mov    0x8(%ebp),%eax
  800afc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aff:	89 c6                	mov    %eax,%esi
  800b01:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b04:	eb 06                	jmp    800b0c <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b06:	83 c0 01             	add    $0x1,%eax
  800b09:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800b0c:	39 f0                	cmp    %esi,%eax
  800b0e:	74 14                	je     800b24 <memcmp+0x30>
		if (*s1 != *s2)
  800b10:	0f b6 08             	movzbl (%eax),%ecx
  800b13:	0f b6 1a             	movzbl (%edx),%ebx
  800b16:	38 d9                	cmp    %bl,%cl
  800b18:	74 ec                	je     800b06 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b1a:	0f b6 c1             	movzbl %cl,%eax
  800b1d:	0f b6 db             	movzbl %bl,%ebx
  800b20:	29 d8                	sub    %ebx,%eax
  800b22:	eb 05                	jmp    800b29 <memcmp+0x35>
	}

	return 0;
  800b24:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b29:	5b                   	pop    %ebx
  800b2a:	5e                   	pop    %esi
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	8b 45 08             	mov    0x8(%ebp),%eax
  800b33:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b36:	89 c2                	mov    %eax,%edx
  800b38:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b3b:	eb 03                	jmp    800b40 <memfind+0x13>
  800b3d:	83 c0 01             	add    $0x1,%eax
  800b40:	39 d0                	cmp    %edx,%eax
  800b42:	73 04                	jae    800b48 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b44:	38 08                	cmp    %cl,(%eax)
  800b46:	75 f5                	jne    800b3d <memfind+0x10>
			break;
	return (void *) s;
}
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	57                   	push   %edi
  800b4e:	56                   	push   %esi
  800b4f:	53                   	push   %ebx
  800b50:	8b 55 08             	mov    0x8(%ebp),%edx
  800b53:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b56:	eb 03                	jmp    800b5b <strtol+0x11>
		s++;
  800b58:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b5b:	0f b6 02             	movzbl (%edx),%eax
  800b5e:	3c 20                	cmp    $0x20,%al
  800b60:	74 f6                	je     800b58 <strtol+0xe>
  800b62:	3c 09                	cmp    $0x9,%al
  800b64:	74 f2                	je     800b58 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b66:	3c 2b                	cmp    $0x2b,%al
  800b68:	74 2a                	je     800b94 <strtol+0x4a>
	int neg = 0;
  800b6a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b6f:	3c 2d                	cmp    $0x2d,%al
  800b71:	74 2b                	je     800b9e <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b73:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b79:	75 0f                	jne    800b8a <strtol+0x40>
  800b7b:	80 3a 30             	cmpb   $0x30,(%edx)
  800b7e:	74 28                	je     800ba8 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b80:	85 db                	test   %ebx,%ebx
  800b82:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b87:	0f 44 d8             	cmove  %eax,%ebx
  800b8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b92:	eb 46                	jmp    800bda <strtol+0x90>
		s++;
  800b94:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b97:	bf 00 00 00 00       	mov    $0x0,%edi
  800b9c:	eb d5                	jmp    800b73 <strtol+0x29>
		s++, neg = 1;
  800b9e:	83 c2 01             	add    $0x1,%edx
  800ba1:	bf 01 00 00 00       	mov    $0x1,%edi
  800ba6:	eb cb                	jmp    800b73 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba8:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bac:	74 0e                	je     800bbc <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800bae:	85 db                	test   %ebx,%ebx
  800bb0:	75 d8                	jne    800b8a <strtol+0x40>
		s++, base = 8;
  800bb2:	83 c2 01             	add    $0x1,%edx
  800bb5:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bba:	eb ce                	jmp    800b8a <strtol+0x40>
		s += 2, base = 16;
  800bbc:	83 c2 02             	add    $0x2,%edx
  800bbf:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bc4:	eb c4                	jmp    800b8a <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bc6:	0f be c0             	movsbl %al,%eax
  800bc9:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bcc:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bcf:	7d 3a                	jge    800c0b <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bd1:	83 c2 01             	add    $0x1,%edx
  800bd4:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bd8:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800bda:	0f b6 02             	movzbl (%edx),%eax
  800bdd:	8d 70 d0             	lea    -0x30(%eax),%esi
  800be0:	89 f3                	mov    %esi,%ebx
  800be2:	80 fb 09             	cmp    $0x9,%bl
  800be5:	76 df                	jbe    800bc6 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800be7:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bea:	89 f3                	mov    %esi,%ebx
  800bec:	80 fb 19             	cmp    $0x19,%bl
  800bef:	77 08                	ja     800bf9 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800bf1:	0f be c0             	movsbl %al,%eax
  800bf4:	83 e8 57             	sub    $0x57,%eax
  800bf7:	eb d3                	jmp    800bcc <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bf9:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bfc:	89 f3                	mov    %esi,%ebx
  800bfe:	80 fb 19             	cmp    $0x19,%bl
  800c01:	77 08                	ja     800c0b <strtol+0xc1>
			dig = *s - 'A' + 10;
  800c03:	0f be c0             	movsbl %al,%eax
  800c06:	83 e8 37             	sub    $0x37,%eax
  800c09:	eb c1                	jmp    800bcc <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c0b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c0f:	74 05                	je     800c16 <strtol+0xcc>
		*endptr = (char *) s;
  800c11:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c14:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c16:	89 c8                	mov    %ecx,%eax
  800c18:	f7 d8                	neg    %eax
  800c1a:	85 ff                	test   %edi,%edi
  800c1c:	0f 45 c8             	cmovne %eax,%ecx
}
  800c1f:	89 c8                	mov    %ecx,%eax
  800c21:	5b                   	pop    %ebx
  800c22:	5e                   	pop    %esi
  800c23:	5f                   	pop    %edi
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800c31:	8b 55 08             	mov    0x8(%ebp),%edx
  800c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c37:	89 c3                	mov    %eax,%ebx
  800c39:	89 c7                	mov    %eax,%edi
  800c3b:	89 c6                	mov    %eax,%esi
  800c3d:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c3f:	5b                   	pop    %ebx
  800c40:	5e                   	pop    %esi
  800c41:	5f                   	pop    %edi
  800c42:	5d                   	pop    %ebp
  800c43:	c3                   	ret    

00800c44 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c44:	55                   	push   %ebp
  800c45:	89 e5                	mov    %esp,%ebp
  800c47:	57                   	push   %edi
  800c48:	56                   	push   %esi
  800c49:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c4a:	ba 00 00 00 00       	mov    $0x0,%edx
  800c4f:	b8 01 00 00 00       	mov    $0x1,%eax
  800c54:	89 d1                	mov    %edx,%ecx
  800c56:	89 d3                	mov    %edx,%ebx
  800c58:	89 d7                	mov    %edx,%edi
  800c5a:	89 d6                	mov    %edx,%esi
  800c5c:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c6c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c71:	8b 55 08             	mov    0x8(%ebp),%edx
  800c74:	b8 03 00 00 00       	mov    $0x3,%eax
  800c79:	89 cb                	mov    %ecx,%ebx
  800c7b:	89 cf                	mov    %ecx,%edi
  800c7d:	89 ce                	mov    %ecx,%esi
  800c7f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c81:	85 c0                	test   %eax,%eax
  800c83:	7f 08                	jg     800c8d <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c85:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c88:	5b                   	pop    %ebx
  800c89:	5e                   	pop    %esi
  800c8a:	5f                   	pop    %edi
  800c8b:	5d                   	pop    %ebp
  800c8c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8d:	83 ec 0c             	sub    $0xc,%esp
  800c90:	50                   	push   %eax
  800c91:	6a 03                	push   $0x3
  800c93:	68 9f 27 80 00       	push   $0x80279f
  800c98:	6a 2a                	push   $0x2a
  800c9a:	68 bc 27 80 00       	push   $0x8027bc
  800c9f:	e8 8d f5 ff ff       	call   800231 <_panic>

00800ca4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800ca4:	55                   	push   %ebp
  800ca5:	89 e5                	mov    %esp,%ebp
  800ca7:	57                   	push   %edi
  800ca8:	56                   	push   %esi
  800ca9:	53                   	push   %ebx
	asm volatile("int %1\n"
  800caa:	ba 00 00 00 00       	mov    $0x0,%edx
  800caf:	b8 02 00 00 00       	mov    $0x2,%eax
  800cb4:	89 d1                	mov    %edx,%ecx
  800cb6:	89 d3                	mov    %edx,%ebx
  800cb8:	89 d7                	mov    %edx,%edi
  800cba:	89 d6                	mov    %edx,%esi
  800cbc:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <sys_yield>:

void
sys_yield(void)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cce:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd3:	89 d1                	mov    %edx,%ecx
  800cd5:	89 d3                	mov    %edx,%ebx
  800cd7:	89 d7                	mov    %edx,%edi
  800cd9:	89 d6                	mov    %edx,%esi
  800cdb:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cdd:	5b                   	pop    %ebx
  800cde:	5e                   	pop    %esi
  800cdf:	5f                   	pop    %edi
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
  800ce8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ceb:	be 00 00 00 00       	mov    $0x0,%esi
  800cf0:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf6:	b8 04 00 00 00       	mov    $0x4,%eax
  800cfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfe:	89 f7                	mov    %esi,%edi
  800d00:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d02:	85 c0                	test   %eax,%eax
  800d04:	7f 08                	jg     800d0e <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d09:	5b                   	pop    %ebx
  800d0a:	5e                   	pop    %esi
  800d0b:	5f                   	pop    %edi
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0e:	83 ec 0c             	sub    $0xc,%esp
  800d11:	50                   	push   %eax
  800d12:	6a 04                	push   $0x4
  800d14:	68 9f 27 80 00       	push   $0x80279f
  800d19:	6a 2a                	push   $0x2a
  800d1b:	68 bc 27 80 00       	push   $0x8027bc
  800d20:	e8 0c f5 ff ff       	call   800231 <_panic>

00800d25 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	57                   	push   %edi
  800d29:	56                   	push   %esi
  800d2a:	53                   	push   %ebx
  800d2b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d2e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d31:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d34:	b8 05 00 00 00       	mov    $0x5,%eax
  800d39:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d3c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d3f:	8b 75 18             	mov    0x18(%ebp),%esi
  800d42:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d44:	85 c0                	test   %eax,%eax
  800d46:	7f 08                	jg     800d50 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d4b:	5b                   	pop    %ebx
  800d4c:	5e                   	pop    %esi
  800d4d:	5f                   	pop    %edi
  800d4e:	5d                   	pop    %ebp
  800d4f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d50:	83 ec 0c             	sub    $0xc,%esp
  800d53:	50                   	push   %eax
  800d54:	6a 05                	push   $0x5
  800d56:	68 9f 27 80 00       	push   $0x80279f
  800d5b:	6a 2a                	push   $0x2a
  800d5d:	68 bc 27 80 00       	push   $0x8027bc
  800d62:	e8 ca f4 ff ff       	call   800231 <_panic>

00800d67 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d67:	55                   	push   %ebp
  800d68:	89 e5                	mov    %esp,%ebp
  800d6a:	57                   	push   %edi
  800d6b:	56                   	push   %esi
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d70:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d75:	8b 55 08             	mov    0x8(%ebp),%edx
  800d78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d7b:	b8 06 00 00 00       	mov    $0x6,%eax
  800d80:	89 df                	mov    %ebx,%edi
  800d82:	89 de                	mov    %ebx,%esi
  800d84:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d86:	85 c0                	test   %eax,%eax
  800d88:	7f 08                	jg     800d92 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d8d:	5b                   	pop    %ebx
  800d8e:	5e                   	pop    %esi
  800d8f:	5f                   	pop    %edi
  800d90:	5d                   	pop    %ebp
  800d91:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d92:	83 ec 0c             	sub    $0xc,%esp
  800d95:	50                   	push   %eax
  800d96:	6a 06                	push   $0x6
  800d98:	68 9f 27 80 00       	push   $0x80279f
  800d9d:	6a 2a                	push   $0x2a
  800d9f:	68 bc 27 80 00       	push   $0x8027bc
  800da4:	e8 88 f4 ff ff       	call   800231 <_panic>

00800da9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	57                   	push   %edi
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
  800daf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800db2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db7:	8b 55 08             	mov    0x8(%ebp),%edx
  800dba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dbd:	b8 08 00 00 00       	mov    $0x8,%eax
  800dc2:	89 df                	mov    %ebx,%edi
  800dc4:	89 de                	mov    %ebx,%esi
  800dc6:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7f 08                	jg     800dd4 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	50                   	push   %eax
  800dd8:	6a 08                	push   $0x8
  800dda:	68 9f 27 80 00       	push   $0x80279f
  800ddf:	6a 2a                	push   $0x2a
  800de1:	68 bc 27 80 00       	push   $0x8027bc
  800de6:	e8 46 f4 ff ff       	call   800231 <_panic>

00800deb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
  800dee:	57                   	push   %edi
  800def:	56                   	push   %esi
  800df0:	53                   	push   %ebx
  800df1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800df4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dff:	b8 09 00 00 00       	mov    $0x9,%eax
  800e04:	89 df                	mov    %ebx,%edi
  800e06:	89 de                	mov    %ebx,%esi
  800e08:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e0a:	85 c0                	test   %eax,%eax
  800e0c:	7f 08                	jg     800e16 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5f                   	pop    %edi
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e16:	83 ec 0c             	sub    $0xc,%esp
  800e19:	50                   	push   %eax
  800e1a:	6a 09                	push   $0x9
  800e1c:	68 9f 27 80 00       	push   $0x80279f
  800e21:	6a 2a                	push   $0x2a
  800e23:	68 bc 27 80 00       	push   $0x8027bc
  800e28:	e8 04 f4 ff ff       	call   800231 <_panic>

00800e2d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e2d:	55                   	push   %ebp
  800e2e:	89 e5                	mov    %esp,%ebp
  800e30:	57                   	push   %edi
  800e31:	56                   	push   %esi
  800e32:	53                   	push   %ebx
  800e33:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e3e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e41:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e46:	89 df                	mov    %ebx,%edi
  800e48:	89 de                	mov    %ebx,%esi
  800e4a:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e4c:	85 c0                	test   %eax,%eax
  800e4e:	7f 08                	jg     800e58 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e53:	5b                   	pop    %ebx
  800e54:	5e                   	pop    %esi
  800e55:	5f                   	pop    %edi
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e58:	83 ec 0c             	sub    $0xc,%esp
  800e5b:	50                   	push   %eax
  800e5c:	6a 0a                	push   $0xa
  800e5e:	68 9f 27 80 00       	push   $0x80279f
  800e63:	6a 2a                	push   $0x2a
  800e65:	68 bc 27 80 00       	push   $0x8027bc
  800e6a:	e8 c2 f3 ff ff       	call   800231 <_panic>

00800e6f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	57                   	push   %edi
  800e73:	56                   	push   %esi
  800e74:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e75:	8b 55 08             	mov    0x8(%ebp),%edx
  800e78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e80:	be 00 00 00 00       	mov    $0x0,%esi
  800e85:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e88:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e8b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e8d:	5b                   	pop    %ebx
  800e8e:	5e                   	pop    %esi
  800e8f:	5f                   	pop    %edi
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    

00800e92 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	57                   	push   %edi
  800e96:	56                   	push   %esi
  800e97:	53                   	push   %ebx
  800e98:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e9b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea3:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ea8:	89 cb                	mov    %ecx,%ebx
  800eaa:	89 cf                	mov    %ecx,%edi
  800eac:	89 ce                	mov    %ecx,%esi
  800eae:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eb0:	85 c0                	test   %eax,%eax
  800eb2:	7f 08                	jg     800ebc <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb7:	5b                   	pop    %ebx
  800eb8:	5e                   	pop    %esi
  800eb9:	5f                   	pop    %edi
  800eba:	5d                   	pop    %ebp
  800ebb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebc:	83 ec 0c             	sub    $0xc,%esp
  800ebf:	50                   	push   %eax
  800ec0:	6a 0d                	push   $0xd
  800ec2:	68 9f 27 80 00       	push   $0x80279f
  800ec7:	6a 2a                	push   $0x2a
  800ec9:	68 bc 27 80 00       	push   $0x8027bc
  800ece:	e8 5e f3 ff ff       	call   800231 <_panic>

00800ed3 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	57                   	push   %edi
  800ed7:	56                   	push   %esi
  800ed8:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ed9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ede:	b8 0e 00 00 00       	mov    $0xe,%eax
  800ee3:	89 d1                	mov    %edx,%ecx
  800ee5:	89 d3                	mov    %edx,%ebx
  800ee7:	89 d7                	mov    %edx,%edi
  800ee9:	89 d6                	mov    %edx,%esi
  800eeb:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800eed:	5b                   	pop    %ebx
  800eee:	5e                   	pop    %esi
  800eef:	5f                   	pop    %edi
  800ef0:	5d                   	pop    %ebp
  800ef1:	c3                   	ret    

00800ef2 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	57                   	push   %edi
  800ef6:	56                   	push   %esi
  800ef7:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ef8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800efd:	8b 55 08             	mov    0x8(%ebp),%edx
  800f00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f03:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f08:	89 df                	mov    %ebx,%edi
  800f0a:	89 de                	mov    %ebx,%esi
  800f0c:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800f0e:	5b                   	pop    %ebx
  800f0f:	5e                   	pop    %esi
  800f10:	5f                   	pop    %edi
  800f11:	5d                   	pop    %ebp
  800f12:	c3                   	ret    

00800f13 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800f13:	55                   	push   %ebp
  800f14:	89 e5                	mov    %esp,%ebp
  800f16:	57                   	push   %edi
  800f17:	56                   	push   %esi
  800f18:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f19:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f21:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f24:	b8 10 00 00 00       	mov    $0x10,%eax
  800f29:	89 df                	mov    %ebx,%edi
  800f2b:	89 de                	mov    %ebx,%esi
  800f2d:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800f2f:	5b                   	pop    %ebx
  800f30:	5e                   	pop    %esi
  800f31:	5f                   	pop    %edi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    

00800f34 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f37:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3a:	05 00 00 00 30       	add    $0x30000000,%eax
  800f3f:	c1 e8 0c             	shr    $0xc,%eax
}
  800f42:	5d                   	pop    %ebp
  800f43:	c3                   	ret    

00800f44 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f47:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4a:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800f4f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f54:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f59:	5d                   	pop    %ebp
  800f5a:	c3                   	ret    

00800f5b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f63:	89 c2                	mov    %eax,%edx
  800f65:	c1 ea 16             	shr    $0x16,%edx
  800f68:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f6f:	f6 c2 01             	test   $0x1,%dl
  800f72:	74 29                	je     800f9d <fd_alloc+0x42>
  800f74:	89 c2                	mov    %eax,%edx
  800f76:	c1 ea 0c             	shr    $0xc,%edx
  800f79:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f80:	f6 c2 01             	test   $0x1,%dl
  800f83:	74 18                	je     800f9d <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800f85:	05 00 10 00 00       	add    $0x1000,%eax
  800f8a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f8f:	75 d2                	jne    800f63 <fd_alloc+0x8>
  800f91:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800f96:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800f9b:	eb 05                	jmp    800fa2 <fd_alloc+0x47>
			return 0;
  800f9d:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800fa2:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa5:	89 02                	mov    %eax,(%edx)
}
  800fa7:	89 c8                	mov    %ecx,%eax
  800fa9:	5d                   	pop    %ebp
  800faa:	c3                   	ret    

00800fab <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fb1:	83 f8 1f             	cmp    $0x1f,%eax
  800fb4:	77 30                	ja     800fe6 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fb6:	c1 e0 0c             	shl    $0xc,%eax
  800fb9:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fbe:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800fc4:	f6 c2 01             	test   $0x1,%dl
  800fc7:	74 24                	je     800fed <fd_lookup+0x42>
  800fc9:	89 c2                	mov    %eax,%edx
  800fcb:	c1 ea 0c             	shr    $0xc,%edx
  800fce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fd5:	f6 c2 01             	test   $0x1,%dl
  800fd8:	74 1a                	je     800ff4 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fda:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fdd:	89 02                	mov    %eax,(%edx)
	return 0;
  800fdf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fe4:	5d                   	pop    %ebp
  800fe5:	c3                   	ret    
		return -E_INVAL;
  800fe6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800feb:	eb f7                	jmp    800fe4 <fd_lookup+0x39>
		return -E_INVAL;
  800fed:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ff2:	eb f0                	jmp    800fe4 <fd_lookup+0x39>
  800ff4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ff9:	eb e9                	jmp    800fe4 <fd_lookup+0x39>

00800ffb <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	53                   	push   %ebx
  800fff:	83 ec 04             	sub    $0x4,%esp
  801002:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801005:	b8 00 00 00 00       	mov    $0x0,%eax
  80100a:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80100f:	39 13                	cmp    %edx,(%ebx)
  801011:	74 37                	je     80104a <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  801013:	83 c0 01             	add    $0x1,%eax
  801016:	8b 1c 85 48 28 80 00 	mov    0x802848(,%eax,4),%ebx
  80101d:	85 db                	test   %ebx,%ebx
  80101f:	75 ee                	jne    80100f <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801021:	a1 00 40 80 00       	mov    0x804000,%eax
  801026:	8b 40 58             	mov    0x58(%eax),%eax
  801029:	83 ec 04             	sub    $0x4,%esp
  80102c:	52                   	push   %edx
  80102d:	50                   	push   %eax
  80102e:	68 cc 27 80 00       	push   $0x8027cc
  801033:	e8 d4 f2 ff ff       	call   80030c <cprintf>
	*dev = 0;
	return -E_INVAL;
  801038:	83 c4 10             	add    $0x10,%esp
  80103b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  801040:	8b 55 0c             	mov    0xc(%ebp),%edx
  801043:	89 1a                	mov    %ebx,(%edx)
}
  801045:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801048:	c9                   	leave  
  801049:	c3                   	ret    
			return 0;
  80104a:	b8 00 00 00 00       	mov    $0x0,%eax
  80104f:	eb ef                	jmp    801040 <dev_lookup+0x45>

00801051 <fd_close>:
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	57                   	push   %edi
  801055:	56                   	push   %esi
  801056:	53                   	push   %ebx
  801057:	83 ec 24             	sub    $0x24,%esp
  80105a:	8b 75 08             	mov    0x8(%ebp),%esi
  80105d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801060:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801063:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801064:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80106a:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80106d:	50                   	push   %eax
  80106e:	e8 38 ff ff ff       	call   800fab <fd_lookup>
  801073:	89 c3                	mov    %eax,%ebx
  801075:	83 c4 10             	add    $0x10,%esp
  801078:	85 c0                	test   %eax,%eax
  80107a:	78 05                	js     801081 <fd_close+0x30>
	    || fd != fd2)
  80107c:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80107f:	74 16                	je     801097 <fd_close+0x46>
		return (must_exist ? r : 0);
  801081:	89 f8                	mov    %edi,%eax
  801083:	84 c0                	test   %al,%al
  801085:	b8 00 00 00 00       	mov    $0x0,%eax
  80108a:	0f 44 d8             	cmove  %eax,%ebx
}
  80108d:	89 d8                	mov    %ebx,%eax
  80108f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801092:	5b                   	pop    %ebx
  801093:	5e                   	pop    %esi
  801094:	5f                   	pop    %edi
  801095:	5d                   	pop    %ebp
  801096:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801097:	83 ec 08             	sub    $0x8,%esp
  80109a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80109d:	50                   	push   %eax
  80109e:	ff 36                	push   (%esi)
  8010a0:	e8 56 ff ff ff       	call   800ffb <dev_lookup>
  8010a5:	89 c3                	mov    %eax,%ebx
  8010a7:	83 c4 10             	add    $0x10,%esp
  8010aa:	85 c0                	test   %eax,%eax
  8010ac:	78 1a                	js     8010c8 <fd_close+0x77>
		if (dev->dev_close)
  8010ae:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010b1:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8010b4:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	74 0b                	je     8010c8 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8010bd:	83 ec 0c             	sub    $0xc,%esp
  8010c0:	56                   	push   %esi
  8010c1:	ff d0                	call   *%eax
  8010c3:	89 c3                	mov    %eax,%ebx
  8010c5:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8010c8:	83 ec 08             	sub    $0x8,%esp
  8010cb:	56                   	push   %esi
  8010cc:	6a 00                	push   $0x0
  8010ce:	e8 94 fc ff ff       	call   800d67 <sys_page_unmap>
	return r;
  8010d3:	83 c4 10             	add    $0x10,%esp
  8010d6:	eb b5                	jmp    80108d <fd_close+0x3c>

008010d8 <close>:

int
close(int fdnum)
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e1:	50                   	push   %eax
  8010e2:	ff 75 08             	push   0x8(%ebp)
  8010e5:	e8 c1 fe ff ff       	call   800fab <fd_lookup>
  8010ea:	83 c4 10             	add    $0x10,%esp
  8010ed:	85 c0                	test   %eax,%eax
  8010ef:	79 02                	jns    8010f3 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8010f1:	c9                   	leave  
  8010f2:	c3                   	ret    
		return fd_close(fd, 1);
  8010f3:	83 ec 08             	sub    $0x8,%esp
  8010f6:	6a 01                	push   $0x1
  8010f8:	ff 75 f4             	push   -0xc(%ebp)
  8010fb:	e8 51 ff ff ff       	call   801051 <fd_close>
  801100:	83 c4 10             	add    $0x10,%esp
  801103:	eb ec                	jmp    8010f1 <close+0x19>

00801105 <close_all>:

void
close_all(void)
{
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	53                   	push   %ebx
  801109:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80110c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801111:	83 ec 0c             	sub    $0xc,%esp
  801114:	53                   	push   %ebx
  801115:	e8 be ff ff ff       	call   8010d8 <close>
	for (i = 0; i < MAXFD; i++)
  80111a:	83 c3 01             	add    $0x1,%ebx
  80111d:	83 c4 10             	add    $0x10,%esp
  801120:	83 fb 20             	cmp    $0x20,%ebx
  801123:	75 ec                	jne    801111 <close_all+0xc>
}
  801125:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801128:	c9                   	leave  
  801129:	c3                   	ret    

0080112a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	57                   	push   %edi
  80112e:	56                   	push   %esi
  80112f:	53                   	push   %ebx
  801130:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801133:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801136:	50                   	push   %eax
  801137:	ff 75 08             	push   0x8(%ebp)
  80113a:	e8 6c fe ff ff       	call   800fab <fd_lookup>
  80113f:	89 c3                	mov    %eax,%ebx
  801141:	83 c4 10             	add    $0x10,%esp
  801144:	85 c0                	test   %eax,%eax
  801146:	78 7f                	js     8011c7 <dup+0x9d>
		return r;
	close(newfdnum);
  801148:	83 ec 0c             	sub    $0xc,%esp
  80114b:	ff 75 0c             	push   0xc(%ebp)
  80114e:	e8 85 ff ff ff       	call   8010d8 <close>

	newfd = INDEX2FD(newfdnum);
  801153:	8b 75 0c             	mov    0xc(%ebp),%esi
  801156:	c1 e6 0c             	shl    $0xc,%esi
  801159:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80115f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801162:	89 3c 24             	mov    %edi,(%esp)
  801165:	e8 da fd ff ff       	call   800f44 <fd2data>
  80116a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80116c:	89 34 24             	mov    %esi,(%esp)
  80116f:	e8 d0 fd ff ff       	call   800f44 <fd2data>
  801174:	83 c4 10             	add    $0x10,%esp
  801177:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80117a:	89 d8                	mov    %ebx,%eax
  80117c:	c1 e8 16             	shr    $0x16,%eax
  80117f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801186:	a8 01                	test   $0x1,%al
  801188:	74 11                	je     80119b <dup+0x71>
  80118a:	89 d8                	mov    %ebx,%eax
  80118c:	c1 e8 0c             	shr    $0xc,%eax
  80118f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801196:	f6 c2 01             	test   $0x1,%dl
  801199:	75 36                	jne    8011d1 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80119b:	89 f8                	mov    %edi,%eax
  80119d:	c1 e8 0c             	shr    $0xc,%eax
  8011a0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011a7:	83 ec 0c             	sub    $0xc,%esp
  8011aa:	25 07 0e 00 00       	and    $0xe07,%eax
  8011af:	50                   	push   %eax
  8011b0:	56                   	push   %esi
  8011b1:	6a 00                	push   $0x0
  8011b3:	57                   	push   %edi
  8011b4:	6a 00                	push   $0x0
  8011b6:	e8 6a fb ff ff       	call   800d25 <sys_page_map>
  8011bb:	89 c3                	mov    %eax,%ebx
  8011bd:	83 c4 20             	add    $0x20,%esp
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	78 33                	js     8011f7 <dup+0xcd>
		goto err;

	return newfdnum;
  8011c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011c7:	89 d8                	mov    %ebx,%eax
  8011c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011cc:	5b                   	pop    %ebx
  8011cd:	5e                   	pop    %esi
  8011ce:	5f                   	pop    %edi
  8011cf:	5d                   	pop    %ebp
  8011d0:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011d1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011d8:	83 ec 0c             	sub    $0xc,%esp
  8011db:	25 07 0e 00 00       	and    $0xe07,%eax
  8011e0:	50                   	push   %eax
  8011e1:	ff 75 d4             	push   -0x2c(%ebp)
  8011e4:	6a 00                	push   $0x0
  8011e6:	53                   	push   %ebx
  8011e7:	6a 00                	push   $0x0
  8011e9:	e8 37 fb ff ff       	call   800d25 <sys_page_map>
  8011ee:	89 c3                	mov    %eax,%ebx
  8011f0:	83 c4 20             	add    $0x20,%esp
  8011f3:	85 c0                	test   %eax,%eax
  8011f5:	79 a4                	jns    80119b <dup+0x71>
	sys_page_unmap(0, newfd);
  8011f7:	83 ec 08             	sub    $0x8,%esp
  8011fa:	56                   	push   %esi
  8011fb:	6a 00                	push   $0x0
  8011fd:	e8 65 fb ff ff       	call   800d67 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801202:	83 c4 08             	add    $0x8,%esp
  801205:	ff 75 d4             	push   -0x2c(%ebp)
  801208:	6a 00                	push   $0x0
  80120a:	e8 58 fb ff ff       	call   800d67 <sys_page_unmap>
	return r;
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	eb b3                	jmp    8011c7 <dup+0x9d>

00801214 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	56                   	push   %esi
  801218:	53                   	push   %ebx
  801219:	83 ec 18             	sub    $0x18,%esp
  80121c:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80121f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801222:	50                   	push   %eax
  801223:	56                   	push   %esi
  801224:	e8 82 fd ff ff       	call   800fab <fd_lookup>
  801229:	83 c4 10             	add    $0x10,%esp
  80122c:	85 c0                	test   %eax,%eax
  80122e:	78 3c                	js     80126c <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801230:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  801233:	83 ec 08             	sub    $0x8,%esp
  801236:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801239:	50                   	push   %eax
  80123a:	ff 33                	push   (%ebx)
  80123c:	e8 ba fd ff ff       	call   800ffb <dev_lookup>
  801241:	83 c4 10             	add    $0x10,%esp
  801244:	85 c0                	test   %eax,%eax
  801246:	78 24                	js     80126c <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801248:	8b 43 08             	mov    0x8(%ebx),%eax
  80124b:	83 e0 03             	and    $0x3,%eax
  80124e:	83 f8 01             	cmp    $0x1,%eax
  801251:	74 20                	je     801273 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801253:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801256:	8b 40 08             	mov    0x8(%eax),%eax
  801259:	85 c0                	test   %eax,%eax
  80125b:	74 37                	je     801294 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80125d:	83 ec 04             	sub    $0x4,%esp
  801260:	ff 75 10             	push   0x10(%ebp)
  801263:	ff 75 0c             	push   0xc(%ebp)
  801266:	53                   	push   %ebx
  801267:	ff d0                	call   *%eax
  801269:	83 c4 10             	add    $0x10,%esp
}
  80126c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80126f:	5b                   	pop    %ebx
  801270:	5e                   	pop    %esi
  801271:	5d                   	pop    %ebp
  801272:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801273:	a1 00 40 80 00       	mov    0x804000,%eax
  801278:	8b 40 58             	mov    0x58(%eax),%eax
  80127b:	83 ec 04             	sub    $0x4,%esp
  80127e:	56                   	push   %esi
  80127f:	50                   	push   %eax
  801280:	68 0d 28 80 00       	push   $0x80280d
  801285:	e8 82 f0 ff ff       	call   80030c <cprintf>
		return -E_INVAL;
  80128a:	83 c4 10             	add    $0x10,%esp
  80128d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801292:	eb d8                	jmp    80126c <read+0x58>
		return -E_NOT_SUPP;
  801294:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801299:	eb d1                	jmp    80126c <read+0x58>

0080129b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80129b:	55                   	push   %ebp
  80129c:	89 e5                	mov    %esp,%ebp
  80129e:	57                   	push   %edi
  80129f:	56                   	push   %esi
  8012a0:	53                   	push   %ebx
  8012a1:	83 ec 0c             	sub    $0xc,%esp
  8012a4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012a7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012af:	eb 02                	jmp    8012b3 <readn+0x18>
  8012b1:	01 c3                	add    %eax,%ebx
  8012b3:	39 f3                	cmp    %esi,%ebx
  8012b5:	73 21                	jae    8012d8 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012b7:	83 ec 04             	sub    $0x4,%esp
  8012ba:	89 f0                	mov    %esi,%eax
  8012bc:	29 d8                	sub    %ebx,%eax
  8012be:	50                   	push   %eax
  8012bf:	89 d8                	mov    %ebx,%eax
  8012c1:	03 45 0c             	add    0xc(%ebp),%eax
  8012c4:	50                   	push   %eax
  8012c5:	57                   	push   %edi
  8012c6:	e8 49 ff ff ff       	call   801214 <read>
		if (m < 0)
  8012cb:	83 c4 10             	add    $0x10,%esp
  8012ce:	85 c0                	test   %eax,%eax
  8012d0:	78 04                	js     8012d6 <readn+0x3b>
			return m;
		if (m == 0)
  8012d2:	75 dd                	jne    8012b1 <readn+0x16>
  8012d4:	eb 02                	jmp    8012d8 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012d6:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8012d8:	89 d8                	mov    %ebx,%eax
  8012da:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012dd:	5b                   	pop    %ebx
  8012de:	5e                   	pop    %esi
  8012df:	5f                   	pop    %edi
  8012e0:	5d                   	pop    %ebp
  8012e1:	c3                   	ret    

008012e2 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012e2:	55                   	push   %ebp
  8012e3:	89 e5                	mov    %esp,%ebp
  8012e5:	56                   	push   %esi
  8012e6:	53                   	push   %ebx
  8012e7:	83 ec 18             	sub    $0x18,%esp
  8012ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f0:	50                   	push   %eax
  8012f1:	53                   	push   %ebx
  8012f2:	e8 b4 fc ff ff       	call   800fab <fd_lookup>
  8012f7:	83 c4 10             	add    $0x10,%esp
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 37                	js     801335 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012fe:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801301:	83 ec 08             	sub    $0x8,%esp
  801304:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801307:	50                   	push   %eax
  801308:	ff 36                	push   (%esi)
  80130a:	e8 ec fc ff ff       	call   800ffb <dev_lookup>
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	85 c0                	test   %eax,%eax
  801314:	78 1f                	js     801335 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801316:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80131a:	74 20                	je     80133c <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80131c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131f:	8b 40 0c             	mov    0xc(%eax),%eax
  801322:	85 c0                	test   %eax,%eax
  801324:	74 37                	je     80135d <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801326:	83 ec 04             	sub    $0x4,%esp
  801329:	ff 75 10             	push   0x10(%ebp)
  80132c:	ff 75 0c             	push   0xc(%ebp)
  80132f:	56                   	push   %esi
  801330:	ff d0                	call   *%eax
  801332:	83 c4 10             	add    $0x10,%esp
}
  801335:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801338:	5b                   	pop    %ebx
  801339:	5e                   	pop    %esi
  80133a:	5d                   	pop    %ebp
  80133b:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80133c:	a1 00 40 80 00       	mov    0x804000,%eax
  801341:	8b 40 58             	mov    0x58(%eax),%eax
  801344:	83 ec 04             	sub    $0x4,%esp
  801347:	53                   	push   %ebx
  801348:	50                   	push   %eax
  801349:	68 29 28 80 00       	push   $0x802829
  80134e:	e8 b9 ef ff ff       	call   80030c <cprintf>
		return -E_INVAL;
  801353:	83 c4 10             	add    $0x10,%esp
  801356:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80135b:	eb d8                	jmp    801335 <write+0x53>
		return -E_NOT_SUPP;
  80135d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801362:	eb d1                	jmp    801335 <write+0x53>

00801364 <seek>:

int
seek(int fdnum, off_t offset)
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
  801367:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80136a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80136d:	50                   	push   %eax
  80136e:	ff 75 08             	push   0x8(%ebp)
  801371:	e8 35 fc ff ff       	call   800fab <fd_lookup>
  801376:	83 c4 10             	add    $0x10,%esp
  801379:	85 c0                	test   %eax,%eax
  80137b:	78 0e                	js     80138b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80137d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801380:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801383:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801386:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80138b:	c9                   	leave  
  80138c:	c3                   	ret    

0080138d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	56                   	push   %esi
  801391:	53                   	push   %ebx
  801392:	83 ec 18             	sub    $0x18,%esp
  801395:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801398:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139b:	50                   	push   %eax
  80139c:	53                   	push   %ebx
  80139d:	e8 09 fc ff ff       	call   800fab <fd_lookup>
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	85 c0                	test   %eax,%eax
  8013a7:	78 34                	js     8013dd <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a9:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8013ac:	83 ec 08             	sub    $0x8,%esp
  8013af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b2:	50                   	push   %eax
  8013b3:	ff 36                	push   (%esi)
  8013b5:	e8 41 fc ff ff       	call   800ffb <dev_lookup>
  8013ba:	83 c4 10             	add    $0x10,%esp
  8013bd:	85 c0                	test   %eax,%eax
  8013bf:	78 1c                	js     8013dd <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013c1:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8013c5:	74 1d                	je     8013e4 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8013c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ca:	8b 40 18             	mov    0x18(%eax),%eax
  8013cd:	85 c0                	test   %eax,%eax
  8013cf:	74 34                	je     801405 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013d1:	83 ec 08             	sub    $0x8,%esp
  8013d4:	ff 75 0c             	push   0xc(%ebp)
  8013d7:	56                   	push   %esi
  8013d8:	ff d0                	call   *%eax
  8013da:	83 c4 10             	add    $0x10,%esp
}
  8013dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e0:	5b                   	pop    %ebx
  8013e1:	5e                   	pop    %esi
  8013e2:	5d                   	pop    %ebp
  8013e3:	c3                   	ret    
			thisenv->env_id, fdnum);
  8013e4:	a1 00 40 80 00       	mov    0x804000,%eax
  8013e9:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013ec:	83 ec 04             	sub    $0x4,%esp
  8013ef:	53                   	push   %ebx
  8013f0:	50                   	push   %eax
  8013f1:	68 ec 27 80 00       	push   $0x8027ec
  8013f6:	e8 11 ef ff ff       	call   80030c <cprintf>
		return -E_INVAL;
  8013fb:	83 c4 10             	add    $0x10,%esp
  8013fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801403:	eb d8                	jmp    8013dd <ftruncate+0x50>
		return -E_NOT_SUPP;
  801405:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80140a:	eb d1                	jmp    8013dd <ftruncate+0x50>

0080140c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	56                   	push   %esi
  801410:	53                   	push   %ebx
  801411:	83 ec 18             	sub    $0x18,%esp
  801414:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801417:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80141a:	50                   	push   %eax
  80141b:	ff 75 08             	push   0x8(%ebp)
  80141e:	e8 88 fb ff ff       	call   800fab <fd_lookup>
  801423:	83 c4 10             	add    $0x10,%esp
  801426:	85 c0                	test   %eax,%eax
  801428:	78 49                	js     801473 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80142a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80142d:	83 ec 08             	sub    $0x8,%esp
  801430:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801433:	50                   	push   %eax
  801434:	ff 36                	push   (%esi)
  801436:	e8 c0 fb ff ff       	call   800ffb <dev_lookup>
  80143b:	83 c4 10             	add    $0x10,%esp
  80143e:	85 c0                	test   %eax,%eax
  801440:	78 31                	js     801473 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  801442:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801445:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801449:	74 2f                	je     80147a <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80144b:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80144e:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801455:	00 00 00 
	stat->st_isdir = 0;
  801458:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80145f:	00 00 00 
	stat->st_dev = dev;
  801462:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801468:	83 ec 08             	sub    $0x8,%esp
  80146b:	53                   	push   %ebx
  80146c:	56                   	push   %esi
  80146d:	ff 50 14             	call   *0x14(%eax)
  801470:	83 c4 10             	add    $0x10,%esp
}
  801473:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801476:	5b                   	pop    %ebx
  801477:	5e                   	pop    %esi
  801478:	5d                   	pop    %ebp
  801479:	c3                   	ret    
		return -E_NOT_SUPP;
  80147a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80147f:	eb f2                	jmp    801473 <fstat+0x67>

00801481 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	56                   	push   %esi
  801485:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801486:	83 ec 08             	sub    $0x8,%esp
  801489:	6a 00                	push   $0x0
  80148b:	ff 75 08             	push   0x8(%ebp)
  80148e:	e8 e4 01 00 00       	call   801677 <open>
  801493:	89 c3                	mov    %eax,%ebx
  801495:	83 c4 10             	add    $0x10,%esp
  801498:	85 c0                	test   %eax,%eax
  80149a:	78 1b                	js     8014b7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80149c:	83 ec 08             	sub    $0x8,%esp
  80149f:	ff 75 0c             	push   0xc(%ebp)
  8014a2:	50                   	push   %eax
  8014a3:	e8 64 ff ff ff       	call   80140c <fstat>
  8014a8:	89 c6                	mov    %eax,%esi
	close(fd);
  8014aa:	89 1c 24             	mov    %ebx,(%esp)
  8014ad:	e8 26 fc ff ff       	call   8010d8 <close>
	return r;
  8014b2:	83 c4 10             	add    $0x10,%esp
  8014b5:	89 f3                	mov    %esi,%ebx
}
  8014b7:	89 d8                	mov    %ebx,%eax
  8014b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014bc:	5b                   	pop    %ebx
  8014bd:	5e                   	pop    %esi
  8014be:	5d                   	pop    %ebp
  8014bf:	c3                   	ret    

008014c0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	56                   	push   %esi
  8014c4:	53                   	push   %ebx
  8014c5:	89 c6                	mov    %eax,%esi
  8014c7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014c9:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8014d0:	74 27                	je     8014f9 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014d2:	6a 07                	push   $0x7
  8014d4:	68 00 50 80 00       	push   $0x805000
  8014d9:	56                   	push   %esi
  8014da:	ff 35 00 60 80 00    	push   0x806000
  8014e0:	e8 cd 0b 00 00       	call   8020b2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014e5:	83 c4 0c             	add    $0xc,%esp
  8014e8:	6a 00                	push   $0x0
  8014ea:	53                   	push   %ebx
  8014eb:	6a 00                	push   $0x0
  8014ed:	e8 50 0b 00 00       	call   802042 <ipc_recv>
}
  8014f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014f5:	5b                   	pop    %ebx
  8014f6:	5e                   	pop    %esi
  8014f7:	5d                   	pop    %ebp
  8014f8:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014f9:	83 ec 0c             	sub    $0xc,%esp
  8014fc:	6a 01                	push   $0x1
  8014fe:	e8 03 0c 00 00       	call   802106 <ipc_find_env>
  801503:	a3 00 60 80 00       	mov    %eax,0x806000
  801508:	83 c4 10             	add    $0x10,%esp
  80150b:	eb c5                	jmp    8014d2 <fsipc+0x12>

0080150d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80150d:	55                   	push   %ebp
  80150e:	89 e5                	mov    %esp,%ebp
  801510:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801513:	8b 45 08             	mov    0x8(%ebp),%eax
  801516:	8b 40 0c             	mov    0xc(%eax),%eax
  801519:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80151e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801521:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801526:	ba 00 00 00 00       	mov    $0x0,%edx
  80152b:	b8 02 00 00 00       	mov    $0x2,%eax
  801530:	e8 8b ff ff ff       	call   8014c0 <fsipc>
}
  801535:	c9                   	leave  
  801536:	c3                   	ret    

00801537 <devfile_flush>:
{
  801537:	55                   	push   %ebp
  801538:	89 e5                	mov    %esp,%ebp
  80153a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80153d:	8b 45 08             	mov    0x8(%ebp),%eax
  801540:	8b 40 0c             	mov    0xc(%eax),%eax
  801543:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801548:	ba 00 00 00 00       	mov    $0x0,%edx
  80154d:	b8 06 00 00 00       	mov    $0x6,%eax
  801552:	e8 69 ff ff ff       	call   8014c0 <fsipc>
}
  801557:	c9                   	leave  
  801558:	c3                   	ret    

00801559 <devfile_stat>:
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	53                   	push   %ebx
  80155d:	83 ec 04             	sub    $0x4,%esp
  801560:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801563:	8b 45 08             	mov    0x8(%ebp),%eax
  801566:	8b 40 0c             	mov    0xc(%eax),%eax
  801569:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80156e:	ba 00 00 00 00       	mov    $0x0,%edx
  801573:	b8 05 00 00 00       	mov    $0x5,%eax
  801578:	e8 43 ff ff ff       	call   8014c0 <fsipc>
  80157d:	85 c0                	test   %eax,%eax
  80157f:	78 2c                	js     8015ad <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801581:	83 ec 08             	sub    $0x8,%esp
  801584:	68 00 50 80 00       	push   $0x805000
  801589:	53                   	push   %ebx
  80158a:	e8 57 f3 ff ff       	call   8008e6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80158f:	a1 80 50 80 00       	mov    0x805080,%eax
  801594:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80159a:	a1 84 50 80 00       	mov    0x805084,%eax
  80159f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015b0:	c9                   	leave  
  8015b1:	c3                   	ret    

008015b2 <devfile_write>:
{
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
  8015b5:	83 ec 0c             	sub    $0xc,%esp
  8015b8:	8b 45 10             	mov    0x10(%ebp),%eax
  8015bb:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8015c0:	39 d0                	cmp    %edx,%eax
  8015c2:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8015c8:	8b 52 0c             	mov    0xc(%edx),%edx
  8015cb:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8015d1:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8015d6:	50                   	push   %eax
  8015d7:	ff 75 0c             	push   0xc(%ebp)
  8015da:	68 08 50 80 00       	push   $0x805008
  8015df:	e8 98 f4 ff ff       	call   800a7c <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8015e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e9:	b8 04 00 00 00       	mov    $0x4,%eax
  8015ee:	e8 cd fe ff ff       	call   8014c0 <fsipc>
}
  8015f3:	c9                   	leave  
  8015f4:	c3                   	ret    

008015f5 <devfile_read>:
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	56                   	push   %esi
  8015f9:	53                   	push   %ebx
  8015fa:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015fd:	8b 45 08             	mov    0x8(%ebp),%eax
  801600:	8b 40 0c             	mov    0xc(%eax),%eax
  801603:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801608:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80160e:	ba 00 00 00 00       	mov    $0x0,%edx
  801613:	b8 03 00 00 00       	mov    $0x3,%eax
  801618:	e8 a3 fe ff ff       	call   8014c0 <fsipc>
  80161d:	89 c3                	mov    %eax,%ebx
  80161f:	85 c0                	test   %eax,%eax
  801621:	78 1f                	js     801642 <devfile_read+0x4d>
	assert(r <= n);
  801623:	39 f0                	cmp    %esi,%eax
  801625:	77 24                	ja     80164b <devfile_read+0x56>
	assert(r <= PGSIZE);
  801627:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80162c:	7f 33                	jg     801661 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80162e:	83 ec 04             	sub    $0x4,%esp
  801631:	50                   	push   %eax
  801632:	68 00 50 80 00       	push   $0x805000
  801637:	ff 75 0c             	push   0xc(%ebp)
  80163a:	e8 3d f4 ff ff       	call   800a7c <memmove>
	return r;
  80163f:	83 c4 10             	add    $0x10,%esp
}
  801642:	89 d8                	mov    %ebx,%eax
  801644:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801647:	5b                   	pop    %ebx
  801648:	5e                   	pop    %esi
  801649:	5d                   	pop    %ebp
  80164a:	c3                   	ret    
	assert(r <= n);
  80164b:	68 5c 28 80 00       	push   $0x80285c
  801650:	68 63 28 80 00       	push   $0x802863
  801655:	6a 7c                	push   $0x7c
  801657:	68 78 28 80 00       	push   $0x802878
  80165c:	e8 d0 eb ff ff       	call   800231 <_panic>
	assert(r <= PGSIZE);
  801661:	68 83 28 80 00       	push   $0x802883
  801666:	68 63 28 80 00       	push   $0x802863
  80166b:	6a 7d                	push   $0x7d
  80166d:	68 78 28 80 00       	push   $0x802878
  801672:	e8 ba eb ff ff       	call   800231 <_panic>

00801677 <open>:
{
  801677:	55                   	push   %ebp
  801678:	89 e5                	mov    %esp,%ebp
  80167a:	56                   	push   %esi
  80167b:	53                   	push   %ebx
  80167c:	83 ec 1c             	sub    $0x1c,%esp
  80167f:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801682:	56                   	push   %esi
  801683:	e8 23 f2 ff ff       	call   8008ab <strlen>
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801690:	7f 6c                	jg     8016fe <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801692:	83 ec 0c             	sub    $0xc,%esp
  801695:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801698:	50                   	push   %eax
  801699:	e8 bd f8 ff ff       	call   800f5b <fd_alloc>
  80169e:	89 c3                	mov    %eax,%ebx
  8016a0:	83 c4 10             	add    $0x10,%esp
  8016a3:	85 c0                	test   %eax,%eax
  8016a5:	78 3c                	js     8016e3 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8016a7:	83 ec 08             	sub    $0x8,%esp
  8016aa:	56                   	push   %esi
  8016ab:	68 00 50 80 00       	push   $0x805000
  8016b0:	e8 31 f2 ff ff       	call   8008e6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016b5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b8:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8016c5:	e8 f6 fd ff ff       	call   8014c0 <fsipc>
  8016ca:	89 c3                	mov    %eax,%ebx
  8016cc:	83 c4 10             	add    $0x10,%esp
  8016cf:	85 c0                	test   %eax,%eax
  8016d1:	78 19                	js     8016ec <open+0x75>
	return fd2num(fd);
  8016d3:	83 ec 0c             	sub    $0xc,%esp
  8016d6:	ff 75 f4             	push   -0xc(%ebp)
  8016d9:	e8 56 f8 ff ff       	call   800f34 <fd2num>
  8016de:	89 c3                	mov    %eax,%ebx
  8016e0:	83 c4 10             	add    $0x10,%esp
}
  8016e3:	89 d8                	mov    %ebx,%eax
  8016e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e8:	5b                   	pop    %ebx
  8016e9:	5e                   	pop    %esi
  8016ea:	5d                   	pop    %ebp
  8016eb:	c3                   	ret    
		fd_close(fd, 0);
  8016ec:	83 ec 08             	sub    $0x8,%esp
  8016ef:	6a 00                	push   $0x0
  8016f1:	ff 75 f4             	push   -0xc(%ebp)
  8016f4:	e8 58 f9 ff ff       	call   801051 <fd_close>
		return r;
  8016f9:	83 c4 10             	add    $0x10,%esp
  8016fc:	eb e5                	jmp    8016e3 <open+0x6c>
		return -E_BAD_PATH;
  8016fe:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801703:	eb de                	jmp    8016e3 <open+0x6c>

00801705 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80170b:	ba 00 00 00 00       	mov    $0x0,%edx
  801710:	b8 08 00 00 00       	mov    $0x8,%eax
  801715:	e8 a6 fd ff ff       	call   8014c0 <fsipc>
}
  80171a:	c9                   	leave  
  80171b:	c3                   	ret    

0080171c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801722:	68 8f 28 80 00       	push   $0x80288f
  801727:	ff 75 0c             	push   0xc(%ebp)
  80172a:	e8 b7 f1 ff ff       	call   8008e6 <strcpy>
	return 0;
}
  80172f:	b8 00 00 00 00       	mov    $0x0,%eax
  801734:	c9                   	leave  
  801735:	c3                   	ret    

00801736 <devsock_close>:
{
  801736:	55                   	push   %ebp
  801737:	89 e5                	mov    %esp,%ebp
  801739:	53                   	push   %ebx
  80173a:	83 ec 10             	sub    $0x10,%esp
  80173d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801740:	53                   	push   %ebx
  801741:	e8 ff 09 00 00       	call   802145 <pageref>
  801746:	89 c2                	mov    %eax,%edx
  801748:	83 c4 10             	add    $0x10,%esp
		return 0;
  80174b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  801750:	83 fa 01             	cmp    $0x1,%edx
  801753:	74 05                	je     80175a <devsock_close+0x24>
}
  801755:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801758:	c9                   	leave  
  801759:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  80175a:	83 ec 0c             	sub    $0xc,%esp
  80175d:	ff 73 0c             	push   0xc(%ebx)
  801760:	e8 b7 02 00 00       	call   801a1c <nsipc_close>
  801765:	83 c4 10             	add    $0x10,%esp
  801768:	eb eb                	jmp    801755 <devsock_close+0x1f>

0080176a <devsock_write>:
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801770:	6a 00                	push   $0x0
  801772:	ff 75 10             	push   0x10(%ebp)
  801775:	ff 75 0c             	push   0xc(%ebp)
  801778:	8b 45 08             	mov    0x8(%ebp),%eax
  80177b:	ff 70 0c             	push   0xc(%eax)
  80177e:	e8 79 03 00 00       	call   801afc <nsipc_send>
}
  801783:	c9                   	leave  
  801784:	c3                   	ret    

00801785 <devsock_read>:
{
  801785:	55                   	push   %ebp
  801786:	89 e5                	mov    %esp,%ebp
  801788:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  80178b:	6a 00                	push   $0x0
  80178d:	ff 75 10             	push   0x10(%ebp)
  801790:	ff 75 0c             	push   0xc(%ebp)
  801793:	8b 45 08             	mov    0x8(%ebp),%eax
  801796:	ff 70 0c             	push   0xc(%eax)
  801799:	e8 ef 02 00 00       	call   801a8d <nsipc_recv>
}
  80179e:	c9                   	leave  
  80179f:	c3                   	ret    

008017a0 <fd2sockid>:
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8017a6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8017a9:	52                   	push   %edx
  8017aa:	50                   	push   %eax
  8017ab:	e8 fb f7 ff ff       	call   800fab <fd_lookup>
  8017b0:	83 c4 10             	add    $0x10,%esp
  8017b3:	85 c0                	test   %eax,%eax
  8017b5:	78 10                	js     8017c7 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8017b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ba:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8017c0:	39 08                	cmp    %ecx,(%eax)
  8017c2:	75 05                	jne    8017c9 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8017c4:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8017c7:	c9                   	leave  
  8017c8:	c3                   	ret    
		return -E_NOT_SUPP;
  8017c9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017ce:	eb f7                	jmp    8017c7 <fd2sockid+0x27>

008017d0 <alloc_sockfd>:
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	56                   	push   %esi
  8017d4:	53                   	push   %ebx
  8017d5:	83 ec 1c             	sub    $0x1c,%esp
  8017d8:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8017da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017dd:	50                   	push   %eax
  8017de:	e8 78 f7 ff ff       	call   800f5b <fd_alloc>
  8017e3:	89 c3                	mov    %eax,%ebx
  8017e5:	83 c4 10             	add    $0x10,%esp
  8017e8:	85 c0                	test   %eax,%eax
  8017ea:	78 43                	js     80182f <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8017ec:	83 ec 04             	sub    $0x4,%esp
  8017ef:	68 07 04 00 00       	push   $0x407
  8017f4:	ff 75 f4             	push   -0xc(%ebp)
  8017f7:	6a 00                	push   $0x0
  8017f9:	e8 e4 f4 ff ff       	call   800ce2 <sys_page_alloc>
  8017fe:	89 c3                	mov    %eax,%ebx
  801800:	83 c4 10             	add    $0x10,%esp
  801803:	85 c0                	test   %eax,%eax
  801805:	78 28                	js     80182f <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801807:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80180a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801810:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801812:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801815:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80181c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80181f:	83 ec 0c             	sub    $0xc,%esp
  801822:	50                   	push   %eax
  801823:	e8 0c f7 ff ff       	call   800f34 <fd2num>
  801828:	89 c3                	mov    %eax,%ebx
  80182a:	83 c4 10             	add    $0x10,%esp
  80182d:	eb 0c                	jmp    80183b <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  80182f:	83 ec 0c             	sub    $0xc,%esp
  801832:	56                   	push   %esi
  801833:	e8 e4 01 00 00       	call   801a1c <nsipc_close>
		return r;
  801838:	83 c4 10             	add    $0x10,%esp
}
  80183b:	89 d8                	mov    %ebx,%eax
  80183d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801840:	5b                   	pop    %ebx
  801841:	5e                   	pop    %esi
  801842:	5d                   	pop    %ebp
  801843:	c3                   	ret    

00801844 <accept>:
{
  801844:	55                   	push   %ebp
  801845:	89 e5                	mov    %esp,%ebp
  801847:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80184a:	8b 45 08             	mov    0x8(%ebp),%eax
  80184d:	e8 4e ff ff ff       	call   8017a0 <fd2sockid>
  801852:	85 c0                	test   %eax,%eax
  801854:	78 1b                	js     801871 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801856:	83 ec 04             	sub    $0x4,%esp
  801859:	ff 75 10             	push   0x10(%ebp)
  80185c:	ff 75 0c             	push   0xc(%ebp)
  80185f:	50                   	push   %eax
  801860:	e8 0e 01 00 00       	call   801973 <nsipc_accept>
  801865:	83 c4 10             	add    $0x10,%esp
  801868:	85 c0                	test   %eax,%eax
  80186a:	78 05                	js     801871 <accept+0x2d>
	return alloc_sockfd(r);
  80186c:	e8 5f ff ff ff       	call   8017d0 <alloc_sockfd>
}
  801871:	c9                   	leave  
  801872:	c3                   	ret    

00801873 <bind>:
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801879:	8b 45 08             	mov    0x8(%ebp),%eax
  80187c:	e8 1f ff ff ff       	call   8017a0 <fd2sockid>
  801881:	85 c0                	test   %eax,%eax
  801883:	78 12                	js     801897 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  801885:	83 ec 04             	sub    $0x4,%esp
  801888:	ff 75 10             	push   0x10(%ebp)
  80188b:	ff 75 0c             	push   0xc(%ebp)
  80188e:	50                   	push   %eax
  80188f:	e8 31 01 00 00       	call   8019c5 <nsipc_bind>
  801894:	83 c4 10             	add    $0x10,%esp
}
  801897:	c9                   	leave  
  801898:	c3                   	ret    

00801899 <shutdown>:
{
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  80189f:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a2:	e8 f9 fe ff ff       	call   8017a0 <fd2sockid>
  8018a7:	85 c0                	test   %eax,%eax
  8018a9:	78 0f                	js     8018ba <shutdown+0x21>
	return nsipc_shutdown(r, how);
  8018ab:	83 ec 08             	sub    $0x8,%esp
  8018ae:	ff 75 0c             	push   0xc(%ebp)
  8018b1:	50                   	push   %eax
  8018b2:	e8 43 01 00 00       	call   8019fa <nsipc_shutdown>
  8018b7:	83 c4 10             	add    $0x10,%esp
}
  8018ba:	c9                   	leave  
  8018bb:	c3                   	ret    

008018bc <connect>:
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8018c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c5:	e8 d6 fe ff ff       	call   8017a0 <fd2sockid>
  8018ca:	85 c0                	test   %eax,%eax
  8018cc:	78 12                	js     8018e0 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  8018ce:	83 ec 04             	sub    $0x4,%esp
  8018d1:	ff 75 10             	push   0x10(%ebp)
  8018d4:	ff 75 0c             	push   0xc(%ebp)
  8018d7:	50                   	push   %eax
  8018d8:	e8 59 01 00 00       	call   801a36 <nsipc_connect>
  8018dd:	83 c4 10             	add    $0x10,%esp
}
  8018e0:	c9                   	leave  
  8018e1:	c3                   	ret    

008018e2 <listen>:
{
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8018e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018eb:	e8 b0 fe ff ff       	call   8017a0 <fd2sockid>
  8018f0:	85 c0                	test   %eax,%eax
  8018f2:	78 0f                	js     801903 <listen+0x21>
	return nsipc_listen(r, backlog);
  8018f4:	83 ec 08             	sub    $0x8,%esp
  8018f7:	ff 75 0c             	push   0xc(%ebp)
  8018fa:	50                   	push   %eax
  8018fb:	e8 6b 01 00 00       	call   801a6b <nsipc_listen>
  801900:	83 c4 10             	add    $0x10,%esp
}
  801903:	c9                   	leave  
  801904:	c3                   	ret    

00801905 <socket>:

int
socket(int domain, int type, int protocol)
{
  801905:	55                   	push   %ebp
  801906:	89 e5                	mov    %esp,%ebp
  801908:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80190b:	ff 75 10             	push   0x10(%ebp)
  80190e:	ff 75 0c             	push   0xc(%ebp)
  801911:	ff 75 08             	push   0x8(%ebp)
  801914:	e8 41 02 00 00       	call   801b5a <nsipc_socket>
  801919:	83 c4 10             	add    $0x10,%esp
  80191c:	85 c0                	test   %eax,%eax
  80191e:	78 05                	js     801925 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801920:	e8 ab fe ff ff       	call   8017d0 <alloc_sockfd>
}
  801925:	c9                   	leave  
  801926:	c3                   	ret    

00801927 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801927:	55                   	push   %ebp
  801928:	89 e5                	mov    %esp,%ebp
  80192a:	53                   	push   %ebx
  80192b:	83 ec 04             	sub    $0x4,%esp
  80192e:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801930:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801937:	74 26                	je     80195f <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801939:	6a 07                	push   $0x7
  80193b:	68 00 70 80 00       	push   $0x807000
  801940:	53                   	push   %ebx
  801941:	ff 35 00 80 80 00    	push   0x808000
  801947:	e8 66 07 00 00       	call   8020b2 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  80194c:	83 c4 0c             	add    $0xc,%esp
  80194f:	6a 00                	push   $0x0
  801951:	6a 00                	push   $0x0
  801953:	6a 00                	push   $0x0
  801955:	e8 e8 06 00 00       	call   802042 <ipc_recv>
}
  80195a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80195d:	c9                   	leave  
  80195e:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80195f:	83 ec 0c             	sub    $0xc,%esp
  801962:	6a 02                	push   $0x2
  801964:	e8 9d 07 00 00       	call   802106 <ipc_find_env>
  801969:	a3 00 80 80 00       	mov    %eax,0x808000
  80196e:	83 c4 10             	add    $0x10,%esp
  801971:	eb c6                	jmp    801939 <nsipc+0x12>

00801973 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	56                   	push   %esi
  801977:	53                   	push   %ebx
  801978:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80197b:	8b 45 08             	mov    0x8(%ebp),%eax
  80197e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801983:	8b 06                	mov    (%esi),%eax
  801985:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  80198a:	b8 01 00 00 00       	mov    $0x1,%eax
  80198f:	e8 93 ff ff ff       	call   801927 <nsipc>
  801994:	89 c3                	mov    %eax,%ebx
  801996:	85 c0                	test   %eax,%eax
  801998:	79 09                	jns    8019a3 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  80199a:	89 d8                	mov    %ebx,%eax
  80199c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199f:	5b                   	pop    %ebx
  8019a0:	5e                   	pop    %esi
  8019a1:	5d                   	pop    %ebp
  8019a2:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8019a3:	83 ec 04             	sub    $0x4,%esp
  8019a6:	ff 35 10 70 80 00    	push   0x807010
  8019ac:	68 00 70 80 00       	push   $0x807000
  8019b1:	ff 75 0c             	push   0xc(%ebp)
  8019b4:	e8 c3 f0 ff ff       	call   800a7c <memmove>
		*addrlen = ret->ret_addrlen;
  8019b9:	a1 10 70 80 00       	mov    0x807010,%eax
  8019be:	89 06                	mov    %eax,(%esi)
  8019c0:	83 c4 10             	add    $0x10,%esp
	return r;
  8019c3:	eb d5                	jmp    80199a <nsipc_accept+0x27>

008019c5 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019c5:	55                   	push   %ebp
  8019c6:	89 e5                	mov    %esp,%ebp
  8019c8:	53                   	push   %ebx
  8019c9:	83 ec 08             	sub    $0x8,%esp
  8019cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8019cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d2:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8019d7:	53                   	push   %ebx
  8019d8:	ff 75 0c             	push   0xc(%ebp)
  8019db:	68 04 70 80 00       	push   $0x807004
  8019e0:	e8 97 f0 ff ff       	call   800a7c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8019e5:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8019eb:	b8 02 00 00 00       	mov    $0x2,%eax
  8019f0:	e8 32 ff ff ff       	call   801927 <nsipc>
}
  8019f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f8:	c9                   	leave  
  8019f9:	c3                   	ret    

008019fa <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801a00:	8b 45 08             	mov    0x8(%ebp),%eax
  801a03:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0b:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801a10:	b8 03 00 00 00       	mov    $0x3,%eax
  801a15:	e8 0d ff ff ff       	call   801927 <nsipc>
}
  801a1a:	c9                   	leave  
  801a1b:	c3                   	ret    

00801a1c <nsipc_close>:

int
nsipc_close(int s)
{
  801a1c:	55                   	push   %ebp
  801a1d:	89 e5                	mov    %esp,%ebp
  801a1f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801a22:	8b 45 08             	mov    0x8(%ebp),%eax
  801a25:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801a2a:	b8 04 00 00 00       	mov    $0x4,%eax
  801a2f:	e8 f3 fe ff ff       	call   801927 <nsipc>
}
  801a34:	c9                   	leave  
  801a35:	c3                   	ret    

00801a36 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a36:	55                   	push   %ebp
  801a37:	89 e5                	mov    %esp,%ebp
  801a39:	53                   	push   %ebx
  801a3a:	83 ec 08             	sub    $0x8,%esp
  801a3d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801a40:	8b 45 08             	mov    0x8(%ebp),%eax
  801a43:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801a48:	53                   	push   %ebx
  801a49:	ff 75 0c             	push   0xc(%ebp)
  801a4c:	68 04 70 80 00       	push   $0x807004
  801a51:	e8 26 f0 ff ff       	call   800a7c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a56:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801a5c:	b8 05 00 00 00       	mov    $0x5,%eax
  801a61:	e8 c1 fe ff ff       	call   801927 <nsipc>
}
  801a66:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a69:	c9                   	leave  
  801a6a:	c3                   	ret    

00801a6b <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a6b:	55                   	push   %ebp
  801a6c:	89 e5                	mov    %esp,%ebp
  801a6e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a71:	8b 45 08             	mov    0x8(%ebp),%eax
  801a74:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801a79:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7c:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801a81:	b8 06 00 00 00       	mov    $0x6,%eax
  801a86:	e8 9c fe ff ff       	call   801927 <nsipc>
}
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    

00801a8d <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	56                   	push   %esi
  801a91:	53                   	push   %ebx
  801a92:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a95:	8b 45 08             	mov    0x8(%ebp),%eax
  801a98:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801a9d:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801aa3:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa6:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801aab:	b8 07 00 00 00       	mov    $0x7,%eax
  801ab0:	e8 72 fe ff ff       	call   801927 <nsipc>
  801ab5:	89 c3                	mov    %eax,%ebx
  801ab7:	85 c0                	test   %eax,%eax
  801ab9:	78 22                	js     801add <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801abb:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801ac0:	39 c6                	cmp    %eax,%esi
  801ac2:	0f 4e c6             	cmovle %esi,%eax
  801ac5:	39 c3                	cmp    %eax,%ebx
  801ac7:	7f 1d                	jg     801ae6 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ac9:	83 ec 04             	sub    $0x4,%esp
  801acc:	53                   	push   %ebx
  801acd:	68 00 70 80 00       	push   $0x807000
  801ad2:	ff 75 0c             	push   0xc(%ebp)
  801ad5:	e8 a2 ef ff ff       	call   800a7c <memmove>
  801ada:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801add:	89 d8                	mov    %ebx,%eax
  801adf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae2:	5b                   	pop    %ebx
  801ae3:	5e                   	pop    %esi
  801ae4:	5d                   	pop    %ebp
  801ae5:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801ae6:	68 9b 28 80 00       	push   $0x80289b
  801aeb:	68 63 28 80 00       	push   $0x802863
  801af0:	6a 62                	push   $0x62
  801af2:	68 b0 28 80 00       	push   $0x8028b0
  801af7:	e8 35 e7 ff ff       	call   800231 <_panic>

00801afc <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	53                   	push   %ebx
  801b00:	83 ec 04             	sub    $0x4,%esp
  801b03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801b06:	8b 45 08             	mov    0x8(%ebp),%eax
  801b09:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801b0e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801b14:	7f 2e                	jg     801b44 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801b16:	83 ec 04             	sub    $0x4,%esp
  801b19:	53                   	push   %ebx
  801b1a:	ff 75 0c             	push   0xc(%ebp)
  801b1d:	68 0c 70 80 00       	push   $0x80700c
  801b22:	e8 55 ef ff ff       	call   800a7c <memmove>
	nsipcbuf.send.req_size = size;
  801b27:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801b2d:	8b 45 14             	mov    0x14(%ebp),%eax
  801b30:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801b35:	b8 08 00 00 00       	mov    $0x8,%eax
  801b3a:	e8 e8 fd ff ff       	call   801927 <nsipc>
}
  801b3f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b42:	c9                   	leave  
  801b43:	c3                   	ret    
	assert(size < 1600);
  801b44:	68 bc 28 80 00       	push   $0x8028bc
  801b49:	68 63 28 80 00       	push   $0x802863
  801b4e:	6a 6d                	push   $0x6d
  801b50:	68 b0 28 80 00       	push   $0x8028b0
  801b55:	e8 d7 e6 ff ff       	call   800231 <_panic>

00801b5a <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b5a:	55                   	push   %ebp
  801b5b:	89 e5                	mov    %esp,%ebp
  801b5d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b60:	8b 45 08             	mov    0x8(%ebp),%eax
  801b63:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801b68:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b6b:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801b70:	8b 45 10             	mov    0x10(%ebp),%eax
  801b73:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801b78:	b8 09 00 00 00       	mov    $0x9,%eax
  801b7d:	e8 a5 fd ff ff       	call   801927 <nsipc>
}
  801b82:	c9                   	leave  
  801b83:	c3                   	ret    

00801b84 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b84:	55                   	push   %ebp
  801b85:	89 e5                	mov    %esp,%ebp
  801b87:	56                   	push   %esi
  801b88:	53                   	push   %ebx
  801b89:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b8c:	83 ec 0c             	sub    $0xc,%esp
  801b8f:	ff 75 08             	push   0x8(%ebp)
  801b92:	e8 ad f3 ff ff       	call   800f44 <fd2data>
  801b97:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b99:	83 c4 08             	add    $0x8,%esp
  801b9c:	68 c8 28 80 00       	push   $0x8028c8
  801ba1:	53                   	push   %ebx
  801ba2:	e8 3f ed ff ff       	call   8008e6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ba7:	8b 46 04             	mov    0x4(%esi),%eax
  801baa:	2b 06                	sub    (%esi),%eax
  801bac:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bb2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bb9:	00 00 00 
	stat->st_dev = &devpipe;
  801bbc:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801bc3:	30 80 00 
	return 0;
}
  801bc6:	b8 00 00 00 00       	mov    $0x0,%eax
  801bcb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bce:	5b                   	pop    %ebx
  801bcf:	5e                   	pop    %esi
  801bd0:	5d                   	pop    %ebp
  801bd1:	c3                   	ret    

00801bd2 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	53                   	push   %ebx
  801bd6:	83 ec 0c             	sub    $0xc,%esp
  801bd9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bdc:	53                   	push   %ebx
  801bdd:	6a 00                	push   $0x0
  801bdf:	e8 83 f1 ff ff       	call   800d67 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801be4:	89 1c 24             	mov    %ebx,(%esp)
  801be7:	e8 58 f3 ff ff       	call   800f44 <fd2data>
  801bec:	83 c4 08             	add    $0x8,%esp
  801bef:	50                   	push   %eax
  801bf0:	6a 00                	push   $0x0
  801bf2:	e8 70 f1 ff ff       	call   800d67 <sys_page_unmap>
}
  801bf7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bfa:	c9                   	leave  
  801bfb:	c3                   	ret    

00801bfc <_pipeisclosed>:
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	57                   	push   %edi
  801c00:	56                   	push   %esi
  801c01:	53                   	push   %ebx
  801c02:	83 ec 1c             	sub    $0x1c,%esp
  801c05:	89 c7                	mov    %eax,%edi
  801c07:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801c09:	a1 00 40 80 00       	mov    0x804000,%eax
  801c0e:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c11:	83 ec 0c             	sub    $0xc,%esp
  801c14:	57                   	push   %edi
  801c15:	e8 2b 05 00 00       	call   802145 <pageref>
  801c1a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c1d:	89 34 24             	mov    %esi,(%esp)
  801c20:	e8 20 05 00 00       	call   802145 <pageref>
		nn = thisenv->env_runs;
  801c25:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801c2b:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  801c2e:	83 c4 10             	add    $0x10,%esp
  801c31:	39 cb                	cmp    %ecx,%ebx
  801c33:	74 1b                	je     801c50 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801c35:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c38:	75 cf                	jne    801c09 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c3a:	8b 42 68             	mov    0x68(%edx),%eax
  801c3d:	6a 01                	push   $0x1
  801c3f:	50                   	push   %eax
  801c40:	53                   	push   %ebx
  801c41:	68 cf 28 80 00       	push   $0x8028cf
  801c46:	e8 c1 e6 ff ff       	call   80030c <cprintf>
  801c4b:	83 c4 10             	add    $0x10,%esp
  801c4e:	eb b9                	jmp    801c09 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c50:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c53:	0f 94 c0             	sete   %al
  801c56:	0f b6 c0             	movzbl %al,%eax
}
  801c59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c5c:	5b                   	pop    %ebx
  801c5d:	5e                   	pop    %esi
  801c5e:	5f                   	pop    %edi
  801c5f:	5d                   	pop    %ebp
  801c60:	c3                   	ret    

00801c61 <devpipe_write>:
{
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	57                   	push   %edi
  801c65:	56                   	push   %esi
  801c66:	53                   	push   %ebx
  801c67:	83 ec 28             	sub    $0x28,%esp
  801c6a:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c6d:	56                   	push   %esi
  801c6e:	e8 d1 f2 ff ff       	call   800f44 <fd2data>
  801c73:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c75:	83 c4 10             	add    $0x10,%esp
  801c78:	bf 00 00 00 00       	mov    $0x0,%edi
  801c7d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c80:	75 09                	jne    801c8b <devpipe_write+0x2a>
	return i;
  801c82:	89 f8                	mov    %edi,%eax
  801c84:	eb 23                	jmp    801ca9 <devpipe_write+0x48>
			sys_yield();
  801c86:	e8 38 f0 ff ff       	call   800cc3 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c8b:	8b 43 04             	mov    0x4(%ebx),%eax
  801c8e:	8b 0b                	mov    (%ebx),%ecx
  801c90:	8d 51 20             	lea    0x20(%ecx),%edx
  801c93:	39 d0                	cmp    %edx,%eax
  801c95:	72 1a                	jb     801cb1 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801c97:	89 da                	mov    %ebx,%edx
  801c99:	89 f0                	mov    %esi,%eax
  801c9b:	e8 5c ff ff ff       	call   801bfc <_pipeisclosed>
  801ca0:	85 c0                	test   %eax,%eax
  801ca2:	74 e2                	je     801c86 <devpipe_write+0x25>
				return 0;
  801ca4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ca9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cac:	5b                   	pop    %ebx
  801cad:	5e                   	pop    %esi
  801cae:	5f                   	pop    %edi
  801caf:	5d                   	pop    %ebp
  801cb0:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cb1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cb4:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cb8:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cbb:	89 c2                	mov    %eax,%edx
  801cbd:	c1 fa 1f             	sar    $0x1f,%edx
  801cc0:	89 d1                	mov    %edx,%ecx
  801cc2:	c1 e9 1b             	shr    $0x1b,%ecx
  801cc5:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cc8:	83 e2 1f             	and    $0x1f,%edx
  801ccb:	29 ca                	sub    %ecx,%edx
  801ccd:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801cd1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801cd5:	83 c0 01             	add    $0x1,%eax
  801cd8:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801cdb:	83 c7 01             	add    $0x1,%edi
  801cde:	eb 9d                	jmp    801c7d <devpipe_write+0x1c>

00801ce0 <devpipe_read>:
{
  801ce0:	55                   	push   %ebp
  801ce1:	89 e5                	mov    %esp,%ebp
  801ce3:	57                   	push   %edi
  801ce4:	56                   	push   %esi
  801ce5:	53                   	push   %ebx
  801ce6:	83 ec 18             	sub    $0x18,%esp
  801ce9:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801cec:	57                   	push   %edi
  801ced:	e8 52 f2 ff ff       	call   800f44 <fd2data>
  801cf2:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801cf4:	83 c4 10             	add    $0x10,%esp
  801cf7:	be 00 00 00 00       	mov    $0x0,%esi
  801cfc:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cff:	75 13                	jne    801d14 <devpipe_read+0x34>
	return i;
  801d01:	89 f0                	mov    %esi,%eax
  801d03:	eb 02                	jmp    801d07 <devpipe_read+0x27>
				return i;
  801d05:	89 f0                	mov    %esi,%eax
}
  801d07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d0a:	5b                   	pop    %ebx
  801d0b:	5e                   	pop    %esi
  801d0c:	5f                   	pop    %edi
  801d0d:	5d                   	pop    %ebp
  801d0e:	c3                   	ret    
			sys_yield();
  801d0f:	e8 af ef ff ff       	call   800cc3 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801d14:	8b 03                	mov    (%ebx),%eax
  801d16:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d19:	75 18                	jne    801d33 <devpipe_read+0x53>
			if (i > 0)
  801d1b:	85 f6                	test   %esi,%esi
  801d1d:	75 e6                	jne    801d05 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801d1f:	89 da                	mov    %ebx,%edx
  801d21:	89 f8                	mov    %edi,%eax
  801d23:	e8 d4 fe ff ff       	call   801bfc <_pipeisclosed>
  801d28:	85 c0                	test   %eax,%eax
  801d2a:	74 e3                	je     801d0f <devpipe_read+0x2f>
				return 0;
  801d2c:	b8 00 00 00 00       	mov    $0x0,%eax
  801d31:	eb d4                	jmp    801d07 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d33:	99                   	cltd   
  801d34:	c1 ea 1b             	shr    $0x1b,%edx
  801d37:	01 d0                	add    %edx,%eax
  801d39:	83 e0 1f             	and    $0x1f,%eax
  801d3c:	29 d0                	sub    %edx,%eax
  801d3e:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d46:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d49:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d4c:	83 c6 01             	add    $0x1,%esi
  801d4f:	eb ab                	jmp    801cfc <devpipe_read+0x1c>

00801d51 <pipe>:
{
  801d51:	55                   	push   %ebp
  801d52:	89 e5                	mov    %esp,%ebp
  801d54:	56                   	push   %esi
  801d55:	53                   	push   %ebx
  801d56:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d5c:	50                   	push   %eax
  801d5d:	e8 f9 f1 ff ff       	call   800f5b <fd_alloc>
  801d62:	89 c3                	mov    %eax,%ebx
  801d64:	83 c4 10             	add    $0x10,%esp
  801d67:	85 c0                	test   %eax,%eax
  801d69:	0f 88 23 01 00 00    	js     801e92 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d6f:	83 ec 04             	sub    $0x4,%esp
  801d72:	68 07 04 00 00       	push   $0x407
  801d77:	ff 75 f4             	push   -0xc(%ebp)
  801d7a:	6a 00                	push   $0x0
  801d7c:	e8 61 ef ff ff       	call   800ce2 <sys_page_alloc>
  801d81:	89 c3                	mov    %eax,%ebx
  801d83:	83 c4 10             	add    $0x10,%esp
  801d86:	85 c0                	test   %eax,%eax
  801d88:	0f 88 04 01 00 00    	js     801e92 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801d8e:	83 ec 0c             	sub    $0xc,%esp
  801d91:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d94:	50                   	push   %eax
  801d95:	e8 c1 f1 ff ff       	call   800f5b <fd_alloc>
  801d9a:	89 c3                	mov    %eax,%ebx
  801d9c:	83 c4 10             	add    $0x10,%esp
  801d9f:	85 c0                	test   %eax,%eax
  801da1:	0f 88 db 00 00 00    	js     801e82 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da7:	83 ec 04             	sub    $0x4,%esp
  801daa:	68 07 04 00 00       	push   $0x407
  801daf:	ff 75 f0             	push   -0x10(%ebp)
  801db2:	6a 00                	push   $0x0
  801db4:	e8 29 ef ff ff       	call   800ce2 <sys_page_alloc>
  801db9:	89 c3                	mov    %eax,%ebx
  801dbb:	83 c4 10             	add    $0x10,%esp
  801dbe:	85 c0                	test   %eax,%eax
  801dc0:	0f 88 bc 00 00 00    	js     801e82 <pipe+0x131>
	va = fd2data(fd0);
  801dc6:	83 ec 0c             	sub    $0xc,%esp
  801dc9:	ff 75 f4             	push   -0xc(%ebp)
  801dcc:	e8 73 f1 ff ff       	call   800f44 <fd2data>
  801dd1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dd3:	83 c4 0c             	add    $0xc,%esp
  801dd6:	68 07 04 00 00       	push   $0x407
  801ddb:	50                   	push   %eax
  801ddc:	6a 00                	push   $0x0
  801dde:	e8 ff ee ff ff       	call   800ce2 <sys_page_alloc>
  801de3:	89 c3                	mov    %eax,%ebx
  801de5:	83 c4 10             	add    $0x10,%esp
  801de8:	85 c0                	test   %eax,%eax
  801dea:	0f 88 82 00 00 00    	js     801e72 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801df0:	83 ec 0c             	sub    $0xc,%esp
  801df3:	ff 75 f0             	push   -0x10(%ebp)
  801df6:	e8 49 f1 ff ff       	call   800f44 <fd2data>
  801dfb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e02:	50                   	push   %eax
  801e03:	6a 00                	push   $0x0
  801e05:	56                   	push   %esi
  801e06:	6a 00                	push   $0x0
  801e08:	e8 18 ef ff ff       	call   800d25 <sys_page_map>
  801e0d:	89 c3                	mov    %eax,%ebx
  801e0f:	83 c4 20             	add    $0x20,%esp
  801e12:	85 c0                	test   %eax,%eax
  801e14:	78 4e                	js     801e64 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801e16:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801e1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e1e:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801e20:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e23:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801e2a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e2d:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801e2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e32:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e39:	83 ec 0c             	sub    $0xc,%esp
  801e3c:	ff 75 f4             	push   -0xc(%ebp)
  801e3f:	e8 f0 f0 ff ff       	call   800f34 <fd2num>
  801e44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e47:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e49:	83 c4 04             	add    $0x4,%esp
  801e4c:	ff 75 f0             	push   -0x10(%ebp)
  801e4f:	e8 e0 f0 ff ff       	call   800f34 <fd2num>
  801e54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e57:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e5a:	83 c4 10             	add    $0x10,%esp
  801e5d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e62:	eb 2e                	jmp    801e92 <pipe+0x141>
	sys_page_unmap(0, va);
  801e64:	83 ec 08             	sub    $0x8,%esp
  801e67:	56                   	push   %esi
  801e68:	6a 00                	push   $0x0
  801e6a:	e8 f8 ee ff ff       	call   800d67 <sys_page_unmap>
  801e6f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e72:	83 ec 08             	sub    $0x8,%esp
  801e75:	ff 75 f0             	push   -0x10(%ebp)
  801e78:	6a 00                	push   $0x0
  801e7a:	e8 e8 ee ff ff       	call   800d67 <sys_page_unmap>
  801e7f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801e82:	83 ec 08             	sub    $0x8,%esp
  801e85:	ff 75 f4             	push   -0xc(%ebp)
  801e88:	6a 00                	push   $0x0
  801e8a:	e8 d8 ee ff ff       	call   800d67 <sys_page_unmap>
  801e8f:	83 c4 10             	add    $0x10,%esp
}
  801e92:	89 d8                	mov    %ebx,%eax
  801e94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e97:	5b                   	pop    %ebx
  801e98:	5e                   	pop    %esi
  801e99:	5d                   	pop    %ebp
  801e9a:	c3                   	ret    

00801e9b <pipeisclosed>:
{
  801e9b:	55                   	push   %ebp
  801e9c:	89 e5                	mov    %esp,%ebp
  801e9e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ea1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ea4:	50                   	push   %eax
  801ea5:	ff 75 08             	push   0x8(%ebp)
  801ea8:	e8 fe f0 ff ff       	call   800fab <fd_lookup>
  801ead:	83 c4 10             	add    $0x10,%esp
  801eb0:	85 c0                	test   %eax,%eax
  801eb2:	78 18                	js     801ecc <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801eb4:	83 ec 0c             	sub    $0xc,%esp
  801eb7:	ff 75 f4             	push   -0xc(%ebp)
  801eba:	e8 85 f0 ff ff       	call   800f44 <fd2data>
  801ebf:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801ec1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec4:	e8 33 fd ff ff       	call   801bfc <_pipeisclosed>
  801ec9:	83 c4 10             	add    $0x10,%esp
}
  801ecc:	c9                   	leave  
  801ecd:	c3                   	ret    

00801ece <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801ece:	b8 00 00 00 00       	mov    $0x0,%eax
  801ed3:	c3                   	ret    

00801ed4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ed4:	55                   	push   %ebp
  801ed5:	89 e5                	mov    %esp,%ebp
  801ed7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801eda:	68 e7 28 80 00       	push   $0x8028e7
  801edf:	ff 75 0c             	push   0xc(%ebp)
  801ee2:	e8 ff e9 ff ff       	call   8008e6 <strcpy>
	return 0;
}
  801ee7:	b8 00 00 00 00       	mov    $0x0,%eax
  801eec:	c9                   	leave  
  801eed:	c3                   	ret    

00801eee <devcons_write>:
{
  801eee:	55                   	push   %ebp
  801eef:	89 e5                	mov    %esp,%ebp
  801ef1:	57                   	push   %edi
  801ef2:	56                   	push   %esi
  801ef3:	53                   	push   %ebx
  801ef4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801efa:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801eff:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f05:	eb 2e                	jmp    801f35 <devcons_write+0x47>
		m = n - tot;
  801f07:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f0a:	29 f3                	sub    %esi,%ebx
  801f0c:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801f11:	39 c3                	cmp    %eax,%ebx
  801f13:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f16:	83 ec 04             	sub    $0x4,%esp
  801f19:	53                   	push   %ebx
  801f1a:	89 f0                	mov    %esi,%eax
  801f1c:	03 45 0c             	add    0xc(%ebp),%eax
  801f1f:	50                   	push   %eax
  801f20:	57                   	push   %edi
  801f21:	e8 56 eb ff ff       	call   800a7c <memmove>
		sys_cputs(buf, m);
  801f26:	83 c4 08             	add    $0x8,%esp
  801f29:	53                   	push   %ebx
  801f2a:	57                   	push   %edi
  801f2b:	e8 f6 ec ff ff       	call   800c26 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f30:	01 de                	add    %ebx,%esi
  801f32:	83 c4 10             	add    $0x10,%esp
  801f35:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f38:	72 cd                	jb     801f07 <devcons_write+0x19>
}
  801f3a:	89 f0                	mov    %esi,%eax
  801f3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f3f:	5b                   	pop    %ebx
  801f40:	5e                   	pop    %esi
  801f41:	5f                   	pop    %edi
  801f42:	5d                   	pop    %ebp
  801f43:	c3                   	ret    

00801f44 <devcons_read>:
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	83 ec 08             	sub    $0x8,%esp
  801f4a:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f4f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f53:	75 07                	jne    801f5c <devcons_read+0x18>
  801f55:	eb 1f                	jmp    801f76 <devcons_read+0x32>
		sys_yield();
  801f57:	e8 67 ed ff ff       	call   800cc3 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801f5c:	e8 e3 ec ff ff       	call   800c44 <sys_cgetc>
  801f61:	85 c0                	test   %eax,%eax
  801f63:	74 f2                	je     801f57 <devcons_read+0x13>
	if (c < 0)
  801f65:	78 0f                	js     801f76 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801f67:	83 f8 04             	cmp    $0x4,%eax
  801f6a:	74 0c                	je     801f78 <devcons_read+0x34>
	*(char*)vbuf = c;
  801f6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f6f:	88 02                	mov    %al,(%edx)
	return 1;
  801f71:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801f76:	c9                   	leave  
  801f77:	c3                   	ret    
		return 0;
  801f78:	b8 00 00 00 00       	mov    $0x0,%eax
  801f7d:	eb f7                	jmp    801f76 <devcons_read+0x32>

00801f7f <cputchar>:
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f85:	8b 45 08             	mov    0x8(%ebp),%eax
  801f88:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f8b:	6a 01                	push   $0x1
  801f8d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f90:	50                   	push   %eax
  801f91:	e8 90 ec ff ff       	call   800c26 <sys_cputs>
}
  801f96:	83 c4 10             	add    $0x10,%esp
  801f99:	c9                   	leave  
  801f9a:	c3                   	ret    

00801f9b <getchar>:
{
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801fa1:	6a 01                	push   $0x1
  801fa3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fa6:	50                   	push   %eax
  801fa7:	6a 00                	push   $0x0
  801fa9:	e8 66 f2 ff ff       	call   801214 <read>
	if (r < 0)
  801fae:	83 c4 10             	add    $0x10,%esp
  801fb1:	85 c0                	test   %eax,%eax
  801fb3:	78 06                	js     801fbb <getchar+0x20>
	if (r < 1)
  801fb5:	74 06                	je     801fbd <getchar+0x22>
	return c;
  801fb7:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801fbb:	c9                   	leave  
  801fbc:	c3                   	ret    
		return -E_EOF;
  801fbd:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801fc2:	eb f7                	jmp    801fbb <getchar+0x20>

00801fc4 <iscons>:
{
  801fc4:	55                   	push   %ebp
  801fc5:	89 e5                	mov    %esp,%ebp
  801fc7:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fcd:	50                   	push   %eax
  801fce:	ff 75 08             	push   0x8(%ebp)
  801fd1:	e8 d5 ef ff ff       	call   800fab <fd_lookup>
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	85 c0                	test   %eax,%eax
  801fdb:	78 11                	js     801fee <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe0:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801fe6:	39 10                	cmp    %edx,(%eax)
  801fe8:	0f 94 c0             	sete   %al
  801feb:	0f b6 c0             	movzbl %al,%eax
}
  801fee:	c9                   	leave  
  801fef:	c3                   	ret    

00801ff0 <opencons>:
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801ff6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff9:	50                   	push   %eax
  801ffa:	e8 5c ef ff ff       	call   800f5b <fd_alloc>
  801fff:	83 c4 10             	add    $0x10,%esp
  802002:	85 c0                	test   %eax,%eax
  802004:	78 3a                	js     802040 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802006:	83 ec 04             	sub    $0x4,%esp
  802009:	68 07 04 00 00       	push   $0x407
  80200e:	ff 75 f4             	push   -0xc(%ebp)
  802011:	6a 00                	push   $0x0
  802013:	e8 ca ec ff ff       	call   800ce2 <sys_page_alloc>
  802018:	83 c4 10             	add    $0x10,%esp
  80201b:	85 c0                	test   %eax,%eax
  80201d:	78 21                	js     802040 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80201f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802022:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802028:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80202a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80202d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802034:	83 ec 0c             	sub    $0xc,%esp
  802037:	50                   	push   %eax
  802038:	e8 f7 ee ff ff       	call   800f34 <fd2num>
  80203d:	83 c4 10             	add    $0x10,%esp
}
  802040:	c9                   	leave  
  802041:	c3                   	ret    

00802042 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802042:	55                   	push   %ebp
  802043:	89 e5                	mov    %esp,%ebp
  802045:	56                   	push   %esi
  802046:	53                   	push   %ebx
  802047:	8b 75 08             	mov    0x8(%ebp),%esi
  80204a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  802050:	85 c0                	test   %eax,%eax
  802052:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802057:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  80205a:	83 ec 0c             	sub    $0xc,%esp
  80205d:	50                   	push   %eax
  80205e:	e8 2f ee ff ff       	call   800e92 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  802063:	83 c4 10             	add    $0x10,%esp
  802066:	85 f6                	test   %esi,%esi
  802068:	74 17                	je     802081 <ipc_recv+0x3f>
  80206a:	ba 00 00 00 00       	mov    $0x0,%edx
  80206f:	85 c0                	test   %eax,%eax
  802071:	78 0c                	js     80207f <ipc_recv+0x3d>
  802073:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802079:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  80207f:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802081:	85 db                	test   %ebx,%ebx
  802083:	74 17                	je     80209c <ipc_recv+0x5a>
  802085:	ba 00 00 00 00       	mov    $0x0,%edx
  80208a:	85 c0                	test   %eax,%eax
  80208c:	78 0c                	js     80209a <ipc_recv+0x58>
  80208e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802094:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  80209a:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  80209c:	85 c0                	test   %eax,%eax
  80209e:	78 0b                	js     8020ab <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  8020a0:	a1 00 40 80 00       	mov    0x804000,%eax
  8020a5:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  8020ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020ae:	5b                   	pop    %ebx
  8020af:	5e                   	pop    %esi
  8020b0:	5d                   	pop    %ebp
  8020b1:	c3                   	ret    

008020b2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020b2:	55                   	push   %ebp
  8020b3:	89 e5                	mov    %esp,%ebp
  8020b5:	57                   	push   %edi
  8020b6:	56                   	push   %esi
  8020b7:	53                   	push   %ebx
  8020b8:	83 ec 0c             	sub    $0xc,%esp
  8020bb:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020be:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8020c4:	85 db                	test   %ebx,%ebx
  8020c6:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020cb:	0f 44 d8             	cmove  %eax,%ebx
  8020ce:	eb 05                	jmp    8020d5 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8020d0:	e8 ee eb ff ff       	call   800cc3 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8020d5:	ff 75 14             	push   0x14(%ebp)
  8020d8:	53                   	push   %ebx
  8020d9:	56                   	push   %esi
  8020da:	57                   	push   %edi
  8020db:	e8 8f ed ff ff       	call   800e6f <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8020e0:	83 c4 10             	add    $0x10,%esp
  8020e3:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020e6:	74 e8                	je     8020d0 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8020e8:	85 c0                	test   %eax,%eax
  8020ea:	78 08                	js     8020f4 <ipc_send+0x42>
	}while (r<0);

}
  8020ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020ef:	5b                   	pop    %ebx
  8020f0:	5e                   	pop    %esi
  8020f1:	5f                   	pop    %edi
  8020f2:	5d                   	pop    %ebp
  8020f3:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8020f4:	50                   	push   %eax
  8020f5:	68 f3 28 80 00       	push   $0x8028f3
  8020fa:	6a 3d                	push   $0x3d
  8020fc:	68 07 29 80 00       	push   $0x802907
  802101:	e8 2b e1 ff ff       	call   800231 <_panic>

00802106 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802106:	55                   	push   %ebp
  802107:	89 e5                	mov    %esp,%ebp
  802109:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80210c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802111:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  802117:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80211d:	8b 52 60             	mov    0x60(%edx),%edx
  802120:	39 ca                	cmp    %ecx,%edx
  802122:	74 11                	je     802135 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  802124:	83 c0 01             	add    $0x1,%eax
  802127:	3d 00 04 00 00       	cmp    $0x400,%eax
  80212c:	75 e3                	jne    802111 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80212e:	b8 00 00 00 00       	mov    $0x0,%eax
  802133:	eb 0e                	jmp    802143 <ipc_find_env+0x3d>
			return envs[i].env_id;
  802135:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80213b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802140:	8b 40 58             	mov    0x58(%eax),%eax
}
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    

00802145 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802145:	55                   	push   %ebp
  802146:	89 e5                	mov    %esp,%ebp
  802148:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80214b:	89 c2                	mov    %eax,%edx
  80214d:	c1 ea 16             	shr    $0x16,%edx
  802150:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802157:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80215c:	f6 c1 01             	test   $0x1,%cl
  80215f:	74 1c                	je     80217d <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802161:	c1 e8 0c             	shr    $0xc,%eax
  802164:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80216b:	a8 01                	test   $0x1,%al
  80216d:	74 0e                	je     80217d <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80216f:	c1 e8 0c             	shr    $0xc,%eax
  802172:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802179:	ef 
  80217a:	0f b7 d2             	movzwl %dx,%edx
}
  80217d:	89 d0                	mov    %edx,%eax
  80217f:	5d                   	pop    %ebp
  802180:	c3                   	ret    
  802181:	66 90                	xchg   %ax,%ax
  802183:	66 90                	xchg   %ax,%ax
  802185:	66 90                	xchg   %ax,%ax
  802187:	66 90                	xchg   %ax,%ax
  802189:	66 90                	xchg   %ax,%ax
  80218b:	66 90                	xchg   %ax,%ax
  80218d:	66 90                	xchg   %ax,%ax
  80218f:	90                   	nop

00802190 <__udivdi3>:
  802190:	f3 0f 1e fb          	endbr32 
  802194:	55                   	push   %ebp
  802195:	57                   	push   %edi
  802196:	56                   	push   %esi
  802197:	53                   	push   %ebx
  802198:	83 ec 1c             	sub    $0x1c,%esp
  80219b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80219f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8021a3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021a7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8021ab:	85 c0                	test   %eax,%eax
  8021ad:	75 19                	jne    8021c8 <__udivdi3+0x38>
  8021af:	39 f3                	cmp    %esi,%ebx
  8021b1:	76 4d                	jbe    802200 <__udivdi3+0x70>
  8021b3:	31 ff                	xor    %edi,%edi
  8021b5:	89 e8                	mov    %ebp,%eax
  8021b7:	89 f2                	mov    %esi,%edx
  8021b9:	f7 f3                	div    %ebx
  8021bb:	89 fa                	mov    %edi,%edx
  8021bd:	83 c4 1c             	add    $0x1c,%esp
  8021c0:	5b                   	pop    %ebx
  8021c1:	5e                   	pop    %esi
  8021c2:	5f                   	pop    %edi
  8021c3:	5d                   	pop    %ebp
  8021c4:	c3                   	ret    
  8021c5:	8d 76 00             	lea    0x0(%esi),%esi
  8021c8:	39 f0                	cmp    %esi,%eax
  8021ca:	76 14                	jbe    8021e0 <__udivdi3+0x50>
  8021cc:	31 ff                	xor    %edi,%edi
  8021ce:	31 c0                	xor    %eax,%eax
  8021d0:	89 fa                	mov    %edi,%edx
  8021d2:	83 c4 1c             	add    $0x1c,%esp
  8021d5:	5b                   	pop    %ebx
  8021d6:	5e                   	pop    %esi
  8021d7:	5f                   	pop    %edi
  8021d8:	5d                   	pop    %ebp
  8021d9:	c3                   	ret    
  8021da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021e0:	0f bd f8             	bsr    %eax,%edi
  8021e3:	83 f7 1f             	xor    $0x1f,%edi
  8021e6:	75 48                	jne    802230 <__udivdi3+0xa0>
  8021e8:	39 f0                	cmp    %esi,%eax
  8021ea:	72 06                	jb     8021f2 <__udivdi3+0x62>
  8021ec:	31 c0                	xor    %eax,%eax
  8021ee:	39 eb                	cmp    %ebp,%ebx
  8021f0:	77 de                	ja     8021d0 <__udivdi3+0x40>
  8021f2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f7:	eb d7                	jmp    8021d0 <__udivdi3+0x40>
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	89 d9                	mov    %ebx,%ecx
  802202:	85 db                	test   %ebx,%ebx
  802204:	75 0b                	jne    802211 <__udivdi3+0x81>
  802206:	b8 01 00 00 00       	mov    $0x1,%eax
  80220b:	31 d2                	xor    %edx,%edx
  80220d:	f7 f3                	div    %ebx
  80220f:	89 c1                	mov    %eax,%ecx
  802211:	31 d2                	xor    %edx,%edx
  802213:	89 f0                	mov    %esi,%eax
  802215:	f7 f1                	div    %ecx
  802217:	89 c6                	mov    %eax,%esi
  802219:	89 e8                	mov    %ebp,%eax
  80221b:	89 f7                	mov    %esi,%edi
  80221d:	f7 f1                	div    %ecx
  80221f:	89 fa                	mov    %edi,%edx
  802221:	83 c4 1c             	add    $0x1c,%esp
  802224:	5b                   	pop    %ebx
  802225:	5e                   	pop    %esi
  802226:	5f                   	pop    %edi
  802227:	5d                   	pop    %ebp
  802228:	c3                   	ret    
  802229:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802230:	89 f9                	mov    %edi,%ecx
  802232:	ba 20 00 00 00       	mov    $0x20,%edx
  802237:	29 fa                	sub    %edi,%edx
  802239:	d3 e0                	shl    %cl,%eax
  80223b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80223f:	89 d1                	mov    %edx,%ecx
  802241:	89 d8                	mov    %ebx,%eax
  802243:	d3 e8                	shr    %cl,%eax
  802245:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802249:	09 c1                	or     %eax,%ecx
  80224b:	89 f0                	mov    %esi,%eax
  80224d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802251:	89 f9                	mov    %edi,%ecx
  802253:	d3 e3                	shl    %cl,%ebx
  802255:	89 d1                	mov    %edx,%ecx
  802257:	d3 e8                	shr    %cl,%eax
  802259:	89 f9                	mov    %edi,%ecx
  80225b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80225f:	89 eb                	mov    %ebp,%ebx
  802261:	d3 e6                	shl    %cl,%esi
  802263:	89 d1                	mov    %edx,%ecx
  802265:	d3 eb                	shr    %cl,%ebx
  802267:	09 f3                	or     %esi,%ebx
  802269:	89 c6                	mov    %eax,%esi
  80226b:	89 f2                	mov    %esi,%edx
  80226d:	89 d8                	mov    %ebx,%eax
  80226f:	f7 74 24 08          	divl   0x8(%esp)
  802273:	89 d6                	mov    %edx,%esi
  802275:	89 c3                	mov    %eax,%ebx
  802277:	f7 64 24 0c          	mull   0xc(%esp)
  80227b:	39 d6                	cmp    %edx,%esi
  80227d:	72 19                	jb     802298 <__udivdi3+0x108>
  80227f:	89 f9                	mov    %edi,%ecx
  802281:	d3 e5                	shl    %cl,%ebp
  802283:	39 c5                	cmp    %eax,%ebp
  802285:	73 04                	jae    80228b <__udivdi3+0xfb>
  802287:	39 d6                	cmp    %edx,%esi
  802289:	74 0d                	je     802298 <__udivdi3+0x108>
  80228b:	89 d8                	mov    %ebx,%eax
  80228d:	31 ff                	xor    %edi,%edi
  80228f:	e9 3c ff ff ff       	jmp    8021d0 <__udivdi3+0x40>
  802294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802298:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80229b:	31 ff                	xor    %edi,%edi
  80229d:	e9 2e ff ff ff       	jmp    8021d0 <__udivdi3+0x40>
  8022a2:	66 90                	xchg   %ax,%ax
  8022a4:	66 90                	xchg   %ax,%ax
  8022a6:	66 90                	xchg   %ax,%ax
  8022a8:	66 90                	xchg   %ax,%ax
  8022aa:	66 90                	xchg   %ax,%ax
  8022ac:	66 90                	xchg   %ax,%ax
  8022ae:	66 90                	xchg   %ax,%ax

008022b0 <__umoddi3>:
  8022b0:	f3 0f 1e fb          	endbr32 
  8022b4:	55                   	push   %ebp
  8022b5:	57                   	push   %edi
  8022b6:	56                   	push   %esi
  8022b7:	53                   	push   %ebx
  8022b8:	83 ec 1c             	sub    $0x1c,%esp
  8022bb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8022bf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8022c3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8022c7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8022cb:	89 f0                	mov    %esi,%eax
  8022cd:	89 da                	mov    %ebx,%edx
  8022cf:	85 ff                	test   %edi,%edi
  8022d1:	75 15                	jne    8022e8 <__umoddi3+0x38>
  8022d3:	39 dd                	cmp    %ebx,%ebp
  8022d5:	76 39                	jbe    802310 <__umoddi3+0x60>
  8022d7:	f7 f5                	div    %ebp
  8022d9:	89 d0                	mov    %edx,%eax
  8022db:	31 d2                	xor    %edx,%edx
  8022dd:	83 c4 1c             	add    $0x1c,%esp
  8022e0:	5b                   	pop    %ebx
  8022e1:	5e                   	pop    %esi
  8022e2:	5f                   	pop    %edi
  8022e3:	5d                   	pop    %ebp
  8022e4:	c3                   	ret    
  8022e5:	8d 76 00             	lea    0x0(%esi),%esi
  8022e8:	39 df                	cmp    %ebx,%edi
  8022ea:	77 f1                	ja     8022dd <__umoddi3+0x2d>
  8022ec:	0f bd cf             	bsr    %edi,%ecx
  8022ef:	83 f1 1f             	xor    $0x1f,%ecx
  8022f2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8022f6:	75 40                	jne    802338 <__umoddi3+0x88>
  8022f8:	39 df                	cmp    %ebx,%edi
  8022fa:	72 04                	jb     802300 <__umoddi3+0x50>
  8022fc:	39 f5                	cmp    %esi,%ebp
  8022fe:	77 dd                	ja     8022dd <__umoddi3+0x2d>
  802300:	89 da                	mov    %ebx,%edx
  802302:	89 f0                	mov    %esi,%eax
  802304:	29 e8                	sub    %ebp,%eax
  802306:	19 fa                	sbb    %edi,%edx
  802308:	eb d3                	jmp    8022dd <__umoddi3+0x2d>
  80230a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802310:	89 e9                	mov    %ebp,%ecx
  802312:	85 ed                	test   %ebp,%ebp
  802314:	75 0b                	jne    802321 <__umoddi3+0x71>
  802316:	b8 01 00 00 00       	mov    $0x1,%eax
  80231b:	31 d2                	xor    %edx,%edx
  80231d:	f7 f5                	div    %ebp
  80231f:	89 c1                	mov    %eax,%ecx
  802321:	89 d8                	mov    %ebx,%eax
  802323:	31 d2                	xor    %edx,%edx
  802325:	f7 f1                	div    %ecx
  802327:	89 f0                	mov    %esi,%eax
  802329:	f7 f1                	div    %ecx
  80232b:	89 d0                	mov    %edx,%eax
  80232d:	31 d2                	xor    %edx,%edx
  80232f:	eb ac                	jmp    8022dd <__umoddi3+0x2d>
  802331:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802338:	8b 44 24 04          	mov    0x4(%esp),%eax
  80233c:	ba 20 00 00 00       	mov    $0x20,%edx
  802341:	29 c2                	sub    %eax,%edx
  802343:	89 c1                	mov    %eax,%ecx
  802345:	89 e8                	mov    %ebp,%eax
  802347:	d3 e7                	shl    %cl,%edi
  802349:	89 d1                	mov    %edx,%ecx
  80234b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80234f:	d3 e8                	shr    %cl,%eax
  802351:	89 c1                	mov    %eax,%ecx
  802353:	8b 44 24 04          	mov    0x4(%esp),%eax
  802357:	09 f9                	or     %edi,%ecx
  802359:	89 df                	mov    %ebx,%edi
  80235b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80235f:	89 c1                	mov    %eax,%ecx
  802361:	d3 e5                	shl    %cl,%ebp
  802363:	89 d1                	mov    %edx,%ecx
  802365:	d3 ef                	shr    %cl,%edi
  802367:	89 c1                	mov    %eax,%ecx
  802369:	89 f0                	mov    %esi,%eax
  80236b:	d3 e3                	shl    %cl,%ebx
  80236d:	89 d1                	mov    %edx,%ecx
  80236f:	89 fa                	mov    %edi,%edx
  802371:	d3 e8                	shr    %cl,%eax
  802373:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802378:	09 d8                	or     %ebx,%eax
  80237a:	f7 74 24 08          	divl   0x8(%esp)
  80237e:	89 d3                	mov    %edx,%ebx
  802380:	d3 e6                	shl    %cl,%esi
  802382:	f7 e5                	mul    %ebp
  802384:	89 c7                	mov    %eax,%edi
  802386:	89 d1                	mov    %edx,%ecx
  802388:	39 d3                	cmp    %edx,%ebx
  80238a:	72 06                	jb     802392 <__umoddi3+0xe2>
  80238c:	75 0e                	jne    80239c <__umoddi3+0xec>
  80238e:	39 c6                	cmp    %eax,%esi
  802390:	73 0a                	jae    80239c <__umoddi3+0xec>
  802392:	29 e8                	sub    %ebp,%eax
  802394:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802398:	89 d1                	mov    %edx,%ecx
  80239a:	89 c7                	mov    %eax,%edi
  80239c:	89 f5                	mov    %esi,%ebp
  80239e:	8b 74 24 04          	mov    0x4(%esp),%esi
  8023a2:	29 fd                	sub    %edi,%ebp
  8023a4:	19 cb                	sbb    %ecx,%ebx
  8023a6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8023ab:	89 d8                	mov    %ebx,%eax
  8023ad:	d3 e0                	shl    %cl,%eax
  8023af:	89 f1                	mov    %esi,%ecx
  8023b1:	d3 ed                	shr    %cl,%ebp
  8023b3:	d3 eb                	shr    %cl,%ebx
  8023b5:	09 e8                	or     %ebp,%eax
  8023b7:	89 da                	mov    %ebx,%edx
  8023b9:	83 c4 1c             	add    $0x1c,%esp
  8023bc:	5b                   	pop    %ebx
  8023bd:	5e                   	pop    %esi
  8023be:	5f                   	pop    %edi
  8023bf:	5d                   	pop    %ebp
  8023c0:	c3                   	ret    
