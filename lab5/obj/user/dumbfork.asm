
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
  80002c:	e8 9a 01 00 00       	call   8001cb <libmain>
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
  800045:	e8 92 0c 00 00       	call   800cdc <sys_page_alloc>
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
  80005f:	e8 bb 0c 00 00       	call   800d1f <sys_page_map>
  800064:	83 c4 20             	add    $0x20,%esp
  800067:	85 c0                	test   %eax,%eax
  800069:	78 42                	js     8000ad <duppage+0x7a>
		panic("sys_page_map: %e", r);
	memmove(UTEMP, addr, PGSIZE);
  80006b:	83 ec 04             	sub    $0x4,%esp
  80006e:	68 00 10 00 00       	push   $0x1000
  800073:	53                   	push   %ebx
  800074:	68 00 00 40 00       	push   $0x400000
  800079:	e8 f8 09 00 00       	call   800a76 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80007e:	83 c4 08             	add    $0x8,%esp
  800081:	68 00 00 40 00       	push   $0x400000
  800086:	6a 00                	push   $0x0
  800088:	e8 d4 0c 00 00       	call   800d61 <sys_page_unmap>
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
  80009c:	68 e0 1e 80 00       	push   $0x801ee0
  8000a1:	6a 20                	push   $0x20
  8000a3:	68 f3 1e 80 00       	push   $0x801ef3
  8000a8:	e8 7e 01 00 00       	call   80022b <_panic>
		panic("sys_page_map: %e", r);
  8000ad:	50                   	push   %eax
  8000ae:	68 03 1f 80 00       	push   $0x801f03
  8000b3:	6a 22                	push   $0x22
  8000b5:	68 f3 1e 80 00       	push   $0x801ef3
  8000ba:	e8 6c 01 00 00       	call   80022b <_panic>
		panic("sys_page_unmap: %e", r);
  8000bf:	50                   	push   %eax
  8000c0:	68 14 1f 80 00       	push   $0x801f14
  8000c5:	6a 25                	push   $0x25
  8000c7:	68 f3 1e 80 00       	push   $0x801ef3
  8000cc:	e8 5a 01 00 00       	call   80022b <_panic>

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
  8000e3:	78 20                	js     800105 <dumbfork+0x34>
  8000e5:	ba 00 00 80 00       	mov    $0x800000,%edx
		panic("sys_exofork: %e", envid);
	if (envid == 0) {
  8000ea:	75 41                	jne    80012d <dumbfork+0x5c>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  8000ec:	e8 ad 0b 00 00       	call   800c9e <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 00 40 80 00       	mov    %eax,0x804000
		return 0;
  800103:	eb 57                	jmp    80015c <dumbfork+0x8b>
		panic("sys_exofork: %e", envid);
  800105:	50                   	push   %eax
  800106:	68 27 1f 80 00       	push   $0x801f27
  80010b:	6a 37                	push   $0x37
  80010d:	68 f3 1e 80 00       	push   $0x801ef3
  800112:	e8 14 01 00 00       	call   80022b <_panic>

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
		duppage(envid, addr);
  800117:	83 ec 08             	sub    $0x8,%esp
  80011a:	52                   	push   %edx
  80011b:	53                   	push   %ebx
  80011c:	e8 12 ff ff ff       	call   800033 <duppage>
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  800121:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800124:	8d 90 00 10 00 00    	lea    0x1000(%eax),%edx
  80012a:	83 c4 10             	add    $0x10,%esp
  80012d:	89 55 f4             	mov    %edx,-0xc(%ebp)
  800130:	81 fa 04 60 80 00    	cmp    $0x806004,%edx
  800136:	72 df                	jb     800117 <dumbfork+0x46>

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  800138:	83 ec 08             	sub    $0x8,%esp
  80013b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80013e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800143:	50                   	push   %eax
  800144:	53                   	push   %ebx
  800145:	e8 e9 fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80014a:	83 c4 08             	add    $0x8,%esp
  80014d:	6a 02                	push   $0x2
  80014f:	53                   	push   %ebx
  800150:	e8 4e 0c 00 00       	call   800da3 <sys_env_set_status>
  800155:	83 c4 10             	add    $0x10,%esp
  800158:	85 c0                	test   %eax,%eax
  80015a:	78 07                	js     800163 <dumbfork+0x92>
		panic("sys_env_set_status: %e", r);

	return envid;
}
  80015c:	89 d8                	mov    %ebx,%eax
  80015e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800161:	c9                   	leave  
  800162:	c3                   	ret    
		panic("sys_env_set_status: %e", r);
  800163:	50                   	push   %eax
  800164:	68 37 1f 80 00       	push   $0x801f37
  800169:	6a 4c                	push   $0x4c
  80016b:	68 f3 1e 80 00       	push   $0x801ef3
  800170:	e8 b6 00 00 00       	call   80022b <_panic>

00800175 <umain>:
{
  800175:	55                   	push   %ebp
  800176:	89 e5                	mov    %esp,%ebp
  800178:	57                   	push   %edi
  800179:	56                   	push   %esi
  80017a:	53                   	push   %ebx
  80017b:	83 ec 0c             	sub    $0xc,%esp
	who = dumbfork();
  80017e:	e8 4e ff ff ff       	call   8000d1 <dumbfork>
  800183:	89 c6                	mov    %eax,%esi
  800185:	85 c0                	test   %eax,%eax
  800187:	bf 4e 1f 80 00       	mov    $0x801f4e,%edi
  80018c:	b8 55 1f 80 00       	mov    $0x801f55,%eax
  800191:	0f 44 f8             	cmove  %eax,%edi
	for (i = 0; i < (who ? 10 : 20); i++) {
  800194:	bb 00 00 00 00       	mov    $0x0,%ebx
  800199:	eb 1f                	jmp    8001ba <umain+0x45>
  80019b:	83 fb 13             	cmp    $0x13,%ebx
  80019e:	7f 23                	jg     8001c3 <umain+0x4e>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  8001a0:	83 ec 04             	sub    $0x4,%esp
  8001a3:	57                   	push   %edi
  8001a4:	53                   	push   %ebx
  8001a5:	68 5b 1f 80 00       	push   $0x801f5b
  8001aa:	e8 57 01 00 00       	call   800306 <cprintf>
		sys_yield();
  8001af:	e8 09 0b 00 00       	call   800cbd <sys_yield>
	for (i = 0; i < (who ? 10 : 20); i++) {
  8001b4:	83 c3 01             	add    $0x1,%ebx
  8001b7:	83 c4 10             	add    $0x10,%esp
  8001ba:	85 f6                	test   %esi,%esi
  8001bc:	74 dd                	je     80019b <umain+0x26>
  8001be:	83 fb 09             	cmp    $0x9,%ebx
  8001c1:	7e dd                	jle    8001a0 <umain+0x2b>
}
  8001c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c6:	5b                   	pop    %ebx
  8001c7:	5e                   	pop    %esi
  8001c8:	5f                   	pop    %edi
  8001c9:	5d                   	pop    %ebp
  8001ca:	c3                   	ret    

008001cb <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001cb:	55                   	push   %ebp
  8001cc:	89 e5                	mov    %esp,%ebp
  8001ce:	56                   	push   %esi
  8001cf:	53                   	push   %ebx
  8001d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001d3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  8001d6:	e8 c3 0a 00 00       	call   800c9e <sys_getenvid>
  8001db:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e8:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ed:	85 db                	test   %ebx,%ebx
  8001ef:	7e 07                	jle    8001f8 <libmain+0x2d>
		binaryname = argv[0];
  8001f1:	8b 06                	mov    (%esi),%eax
  8001f3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8001f8:	83 ec 08             	sub    $0x8,%esp
  8001fb:	56                   	push   %esi
  8001fc:	53                   	push   %ebx
  8001fd:	e8 73 ff ff ff       	call   800175 <umain>

	// exit gracefully
	exit();
  800202:	e8 0a 00 00 00       	call   800211 <exit>
}
  800207:	83 c4 10             	add    $0x10,%esp
  80020a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80020d:	5b                   	pop    %ebx
  80020e:	5e                   	pop    %esi
  80020f:	5d                   	pop    %ebp
  800210:	c3                   	ret    

00800211 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800211:	55                   	push   %ebp
  800212:	89 e5                	mov    %esp,%ebp
  800214:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800217:	e8 7d 0e 00 00       	call   801099 <close_all>
	sys_env_destroy(0);
  80021c:	83 ec 0c             	sub    $0xc,%esp
  80021f:	6a 00                	push   $0x0
  800221:	e8 37 0a 00 00       	call   800c5d <sys_env_destroy>
}
  800226:	83 c4 10             	add    $0x10,%esp
  800229:	c9                   	leave  
  80022a:	c3                   	ret    

0080022b <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80022b:	55                   	push   %ebp
  80022c:	89 e5                	mov    %esp,%ebp
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800230:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800233:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800239:	e8 60 0a 00 00       	call   800c9e <sys_getenvid>
  80023e:	83 ec 0c             	sub    $0xc,%esp
  800241:	ff 75 0c             	push   0xc(%ebp)
  800244:	ff 75 08             	push   0x8(%ebp)
  800247:	56                   	push   %esi
  800248:	50                   	push   %eax
  800249:	68 78 1f 80 00       	push   $0x801f78
  80024e:	e8 b3 00 00 00       	call   800306 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800253:	83 c4 18             	add    $0x18,%esp
  800256:	53                   	push   %ebx
  800257:	ff 75 10             	push   0x10(%ebp)
  80025a:	e8 56 00 00 00       	call   8002b5 <vcprintf>
	cprintf("\n");
  80025f:	c7 04 24 6b 1f 80 00 	movl   $0x801f6b,(%esp)
  800266:	e8 9b 00 00 00       	call   800306 <cprintf>
  80026b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80026e:	cc                   	int3   
  80026f:	eb fd                	jmp    80026e <_panic+0x43>

00800271 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	53                   	push   %ebx
  800275:	83 ec 04             	sub    $0x4,%esp
  800278:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80027b:	8b 13                	mov    (%ebx),%edx
  80027d:	8d 42 01             	lea    0x1(%edx),%eax
  800280:	89 03                	mov    %eax,(%ebx)
  800282:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800285:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800289:	3d ff 00 00 00       	cmp    $0xff,%eax
  80028e:	74 09                	je     800299 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800290:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800294:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800297:	c9                   	leave  
  800298:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800299:	83 ec 08             	sub    $0x8,%esp
  80029c:	68 ff 00 00 00       	push   $0xff
  8002a1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002a4:	50                   	push   %eax
  8002a5:	e8 76 09 00 00       	call   800c20 <sys_cputs>
		b->idx = 0;
  8002aa:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002b0:	83 c4 10             	add    $0x10,%esp
  8002b3:	eb db                	jmp    800290 <putch+0x1f>

008002b5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002be:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002c5:	00 00 00 
	b.cnt = 0;
  8002c8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002cf:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002d2:	ff 75 0c             	push   0xc(%ebp)
  8002d5:	ff 75 08             	push   0x8(%ebp)
  8002d8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002de:	50                   	push   %eax
  8002df:	68 71 02 80 00       	push   $0x800271
  8002e4:	e8 14 01 00 00       	call   8003fd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002e9:	83 c4 08             	add    $0x8,%esp
  8002ec:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8002f2:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002f8:	50                   	push   %eax
  8002f9:	e8 22 09 00 00       	call   800c20 <sys_cputs>

	return b.cnt;
}
  8002fe:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800304:	c9                   	leave  
  800305:	c3                   	ret    

00800306 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800306:	55                   	push   %ebp
  800307:	89 e5                	mov    %esp,%ebp
  800309:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80030c:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80030f:	50                   	push   %eax
  800310:	ff 75 08             	push   0x8(%ebp)
  800313:	e8 9d ff ff ff       	call   8002b5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800318:	c9                   	leave  
  800319:	c3                   	ret    

0080031a <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 1c             	sub    $0x1c,%esp
  800323:	89 c7                	mov    %eax,%edi
  800325:	89 d6                	mov    %edx,%esi
  800327:	8b 45 08             	mov    0x8(%ebp),%eax
  80032a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80032d:	89 d1                	mov    %edx,%ecx
  80032f:	89 c2                	mov    %eax,%edx
  800331:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800334:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800337:	8b 45 10             	mov    0x10(%ebp),%eax
  80033a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80033d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800340:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800347:	39 c2                	cmp    %eax,%edx
  800349:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80034c:	72 3e                	jb     80038c <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80034e:	83 ec 0c             	sub    $0xc,%esp
  800351:	ff 75 18             	push   0x18(%ebp)
  800354:	83 eb 01             	sub    $0x1,%ebx
  800357:	53                   	push   %ebx
  800358:	50                   	push   %eax
  800359:	83 ec 08             	sub    $0x8,%esp
  80035c:	ff 75 e4             	push   -0x1c(%ebp)
  80035f:	ff 75 e0             	push   -0x20(%ebp)
  800362:	ff 75 dc             	push   -0x24(%ebp)
  800365:	ff 75 d8             	push   -0x28(%ebp)
  800368:	e8 33 19 00 00       	call   801ca0 <__udivdi3>
  80036d:	83 c4 18             	add    $0x18,%esp
  800370:	52                   	push   %edx
  800371:	50                   	push   %eax
  800372:	89 f2                	mov    %esi,%edx
  800374:	89 f8                	mov    %edi,%eax
  800376:	e8 9f ff ff ff       	call   80031a <printnum>
  80037b:	83 c4 20             	add    $0x20,%esp
  80037e:	eb 13                	jmp    800393 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800380:	83 ec 08             	sub    $0x8,%esp
  800383:	56                   	push   %esi
  800384:	ff 75 18             	push   0x18(%ebp)
  800387:	ff d7                	call   *%edi
  800389:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80038c:	83 eb 01             	sub    $0x1,%ebx
  80038f:	85 db                	test   %ebx,%ebx
  800391:	7f ed                	jg     800380 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800393:	83 ec 08             	sub    $0x8,%esp
  800396:	56                   	push   %esi
  800397:	83 ec 04             	sub    $0x4,%esp
  80039a:	ff 75 e4             	push   -0x1c(%ebp)
  80039d:	ff 75 e0             	push   -0x20(%ebp)
  8003a0:	ff 75 dc             	push   -0x24(%ebp)
  8003a3:	ff 75 d8             	push   -0x28(%ebp)
  8003a6:	e8 15 1a 00 00       	call   801dc0 <__umoddi3>
  8003ab:	83 c4 14             	add    $0x14,%esp
  8003ae:	0f be 80 9b 1f 80 00 	movsbl 0x801f9b(%eax),%eax
  8003b5:	50                   	push   %eax
  8003b6:	ff d7                	call   *%edi
}
  8003b8:	83 c4 10             	add    $0x10,%esp
  8003bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003be:	5b                   	pop    %ebx
  8003bf:	5e                   	pop    %esi
  8003c0:	5f                   	pop    %edi
  8003c1:	5d                   	pop    %ebp
  8003c2:	c3                   	ret    

008003c3 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003cd:	8b 10                	mov    (%eax),%edx
  8003cf:	3b 50 04             	cmp    0x4(%eax),%edx
  8003d2:	73 0a                	jae    8003de <sprintputch+0x1b>
		*b->buf++ = ch;
  8003d4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003d7:	89 08                	mov    %ecx,(%eax)
  8003d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003dc:	88 02                	mov    %al,(%edx)
}
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <printfmt>:
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003e6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e9:	50                   	push   %eax
  8003ea:	ff 75 10             	push   0x10(%ebp)
  8003ed:	ff 75 0c             	push   0xc(%ebp)
  8003f0:	ff 75 08             	push   0x8(%ebp)
  8003f3:	e8 05 00 00 00       	call   8003fd <vprintfmt>
}
  8003f8:	83 c4 10             	add    $0x10,%esp
  8003fb:	c9                   	leave  
  8003fc:	c3                   	ret    

008003fd <vprintfmt>:
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	57                   	push   %edi
  800401:	56                   	push   %esi
  800402:	53                   	push   %ebx
  800403:	83 ec 3c             	sub    $0x3c,%esp
  800406:	8b 75 08             	mov    0x8(%ebp),%esi
  800409:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80040c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80040f:	eb 0a                	jmp    80041b <vprintfmt+0x1e>
			putch(ch, putdat);
  800411:	83 ec 08             	sub    $0x8,%esp
  800414:	53                   	push   %ebx
  800415:	50                   	push   %eax
  800416:	ff d6                	call   *%esi
  800418:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80041b:	83 c7 01             	add    $0x1,%edi
  80041e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800422:	83 f8 25             	cmp    $0x25,%eax
  800425:	74 0c                	je     800433 <vprintfmt+0x36>
			if (ch == '\0')
  800427:	85 c0                	test   %eax,%eax
  800429:	75 e6                	jne    800411 <vprintfmt+0x14>
}
  80042b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80042e:	5b                   	pop    %ebx
  80042f:	5e                   	pop    %esi
  800430:	5f                   	pop    %edi
  800431:	5d                   	pop    %ebp
  800432:	c3                   	ret    
		padc = ' ';
  800433:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800437:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80043e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800445:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80044c:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800451:	8d 47 01             	lea    0x1(%edi),%eax
  800454:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800457:	0f b6 17             	movzbl (%edi),%edx
  80045a:	8d 42 dd             	lea    -0x23(%edx),%eax
  80045d:	3c 55                	cmp    $0x55,%al
  80045f:	0f 87 bb 03 00 00    	ja     800820 <vprintfmt+0x423>
  800465:	0f b6 c0             	movzbl %al,%eax
  800468:	ff 24 85 e0 20 80 00 	jmp    *0x8020e0(,%eax,4)
  80046f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800472:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800476:	eb d9                	jmp    800451 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80047b:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80047f:	eb d0                	jmp    800451 <vprintfmt+0x54>
  800481:	0f b6 d2             	movzbl %dl,%edx
  800484:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800487:	b8 00 00 00 00       	mov    $0x0,%eax
  80048c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80048f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800492:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800496:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800499:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80049c:	83 f9 09             	cmp    $0x9,%ecx
  80049f:	77 55                	ja     8004f6 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8004a1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004a4:	eb e9                	jmp    80048f <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8004a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a9:	8b 00                	mov    (%eax),%eax
  8004ab:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b1:	8d 40 04             	lea    0x4(%eax),%eax
  8004b4:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004ba:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004be:	79 91                	jns    800451 <vprintfmt+0x54>
				width = precision, precision = -1;
  8004c0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004c6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004cd:	eb 82                	jmp    800451 <vprintfmt+0x54>
  8004cf:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004d2:	85 d2                	test   %edx,%edx
  8004d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d9:	0f 49 c2             	cmovns %edx,%eax
  8004dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004e2:	e9 6a ff ff ff       	jmp    800451 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8004e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004ea:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004f1:	e9 5b ff ff ff       	jmp    800451 <vprintfmt+0x54>
  8004f6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004f9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fc:	eb bc                	jmp    8004ba <vprintfmt+0xbd>
			lflag++;
  8004fe:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800501:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800504:	e9 48 ff ff ff       	jmp    800451 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800509:	8b 45 14             	mov    0x14(%ebp),%eax
  80050c:	8d 78 04             	lea    0x4(%eax),%edi
  80050f:	83 ec 08             	sub    $0x8,%esp
  800512:	53                   	push   %ebx
  800513:	ff 30                	push   (%eax)
  800515:	ff d6                	call   *%esi
			break;
  800517:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80051a:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80051d:	e9 9d 02 00 00       	jmp    8007bf <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800522:	8b 45 14             	mov    0x14(%ebp),%eax
  800525:	8d 78 04             	lea    0x4(%eax),%edi
  800528:	8b 10                	mov    (%eax),%edx
  80052a:	89 d0                	mov    %edx,%eax
  80052c:	f7 d8                	neg    %eax
  80052e:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800531:	83 f8 0f             	cmp    $0xf,%eax
  800534:	7f 23                	jg     800559 <vprintfmt+0x15c>
  800536:	8b 14 85 40 22 80 00 	mov    0x802240(,%eax,4),%edx
  80053d:	85 d2                	test   %edx,%edx
  80053f:	74 18                	je     800559 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800541:	52                   	push   %edx
  800542:	68 71 23 80 00       	push   $0x802371
  800547:	53                   	push   %ebx
  800548:	56                   	push   %esi
  800549:	e8 92 fe ff ff       	call   8003e0 <printfmt>
  80054e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800551:	89 7d 14             	mov    %edi,0x14(%ebp)
  800554:	e9 66 02 00 00       	jmp    8007bf <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800559:	50                   	push   %eax
  80055a:	68 b3 1f 80 00       	push   $0x801fb3
  80055f:	53                   	push   %ebx
  800560:	56                   	push   %esi
  800561:	e8 7a fe ff ff       	call   8003e0 <printfmt>
  800566:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800569:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80056c:	e9 4e 02 00 00       	jmp    8007bf <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	83 c0 04             	add    $0x4,%eax
  800577:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80057a:	8b 45 14             	mov    0x14(%ebp),%eax
  80057d:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80057f:	85 d2                	test   %edx,%edx
  800581:	b8 ac 1f 80 00       	mov    $0x801fac,%eax
  800586:	0f 45 c2             	cmovne %edx,%eax
  800589:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80058c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800590:	7e 06                	jle    800598 <vprintfmt+0x19b>
  800592:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800596:	75 0d                	jne    8005a5 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800598:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80059b:	89 c7                	mov    %eax,%edi
  80059d:	03 45 e0             	add    -0x20(%ebp),%eax
  8005a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a3:	eb 55                	jmp    8005fa <vprintfmt+0x1fd>
  8005a5:	83 ec 08             	sub    $0x8,%esp
  8005a8:	ff 75 d8             	push   -0x28(%ebp)
  8005ab:	ff 75 cc             	push   -0x34(%ebp)
  8005ae:	e8 0a 03 00 00       	call   8008bd <strnlen>
  8005b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005b6:	29 c1                	sub    %eax,%ecx
  8005b8:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8005bb:	83 c4 10             	add    $0x10,%esp
  8005be:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8005c0:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c7:	eb 0f                	jmp    8005d8 <vprintfmt+0x1db>
					putch(padc, putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	53                   	push   %ebx
  8005cd:	ff 75 e0             	push   -0x20(%ebp)
  8005d0:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d2:	83 ef 01             	sub    $0x1,%edi
  8005d5:	83 c4 10             	add    $0x10,%esp
  8005d8:	85 ff                	test   %edi,%edi
  8005da:	7f ed                	jg     8005c9 <vprintfmt+0x1cc>
  8005dc:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005df:	85 d2                	test   %edx,%edx
  8005e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e6:	0f 49 c2             	cmovns %edx,%eax
  8005e9:	29 c2                	sub    %eax,%edx
  8005eb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005ee:	eb a8                	jmp    800598 <vprintfmt+0x19b>
					putch(ch, putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	53                   	push   %ebx
  8005f4:	52                   	push   %edx
  8005f5:	ff d6                	call   *%esi
  8005f7:	83 c4 10             	add    $0x10,%esp
  8005fa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005fd:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ff:	83 c7 01             	add    $0x1,%edi
  800602:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800606:	0f be d0             	movsbl %al,%edx
  800609:	85 d2                	test   %edx,%edx
  80060b:	74 4b                	je     800658 <vprintfmt+0x25b>
  80060d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800611:	78 06                	js     800619 <vprintfmt+0x21c>
  800613:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800617:	78 1e                	js     800637 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800619:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80061d:	74 d1                	je     8005f0 <vprintfmt+0x1f3>
  80061f:	0f be c0             	movsbl %al,%eax
  800622:	83 e8 20             	sub    $0x20,%eax
  800625:	83 f8 5e             	cmp    $0x5e,%eax
  800628:	76 c6                	jbe    8005f0 <vprintfmt+0x1f3>
					putch('?', putdat);
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	53                   	push   %ebx
  80062e:	6a 3f                	push   $0x3f
  800630:	ff d6                	call   *%esi
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	eb c3                	jmp    8005fa <vprintfmt+0x1fd>
  800637:	89 cf                	mov    %ecx,%edi
  800639:	eb 0e                	jmp    800649 <vprintfmt+0x24c>
				putch(' ', putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	53                   	push   %ebx
  80063f:	6a 20                	push   $0x20
  800641:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800643:	83 ef 01             	sub    $0x1,%edi
  800646:	83 c4 10             	add    $0x10,%esp
  800649:	85 ff                	test   %edi,%edi
  80064b:	7f ee                	jg     80063b <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80064d:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800650:	89 45 14             	mov    %eax,0x14(%ebp)
  800653:	e9 67 01 00 00       	jmp    8007bf <vprintfmt+0x3c2>
  800658:	89 cf                	mov    %ecx,%edi
  80065a:	eb ed                	jmp    800649 <vprintfmt+0x24c>
	if (lflag >= 2)
  80065c:	83 f9 01             	cmp    $0x1,%ecx
  80065f:	7f 1b                	jg     80067c <vprintfmt+0x27f>
	else if (lflag)
  800661:	85 c9                	test   %ecx,%ecx
  800663:	74 63                	je     8006c8 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800665:	8b 45 14             	mov    0x14(%ebp),%eax
  800668:	8b 00                	mov    (%eax),%eax
  80066a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066d:	99                   	cltd   
  80066e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800671:	8b 45 14             	mov    0x14(%ebp),%eax
  800674:	8d 40 04             	lea    0x4(%eax),%eax
  800677:	89 45 14             	mov    %eax,0x14(%ebp)
  80067a:	eb 17                	jmp    800693 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80067c:	8b 45 14             	mov    0x14(%ebp),%eax
  80067f:	8b 50 04             	mov    0x4(%eax),%edx
  800682:	8b 00                	mov    (%eax),%eax
  800684:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800687:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8d 40 08             	lea    0x8(%eax),%eax
  800690:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800693:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800696:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800699:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80069e:	85 c9                	test   %ecx,%ecx
  8006a0:	0f 89 ff 00 00 00    	jns    8007a5 <vprintfmt+0x3a8>
				putch('-', putdat);
  8006a6:	83 ec 08             	sub    $0x8,%esp
  8006a9:	53                   	push   %ebx
  8006aa:	6a 2d                	push   $0x2d
  8006ac:	ff d6                	call   *%esi
				num = -(long long) num;
  8006ae:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006b1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006b4:	f7 da                	neg    %edx
  8006b6:	83 d1 00             	adc    $0x0,%ecx
  8006b9:	f7 d9                	neg    %ecx
  8006bb:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006be:	bf 0a 00 00 00       	mov    $0xa,%edi
  8006c3:	e9 dd 00 00 00       	jmp    8007a5 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8006c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cb:	8b 00                	mov    (%eax),%eax
  8006cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006d0:	99                   	cltd   
  8006d1:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d7:	8d 40 04             	lea    0x4(%eax),%eax
  8006da:	89 45 14             	mov    %eax,0x14(%ebp)
  8006dd:	eb b4                	jmp    800693 <vprintfmt+0x296>
	if (lflag >= 2)
  8006df:	83 f9 01             	cmp    $0x1,%ecx
  8006e2:	7f 1e                	jg     800702 <vprintfmt+0x305>
	else if (lflag)
  8006e4:	85 c9                	test   %ecx,%ecx
  8006e6:	74 32                	je     80071a <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8006e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006eb:	8b 10                	mov    (%eax),%edx
  8006ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f2:	8d 40 04             	lea    0x4(%eax),%eax
  8006f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006f8:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8006fd:	e9 a3 00 00 00       	jmp    8007a5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800702:	8b 45 14             	mov    0x14(%ebp),%eax
  800705:	8b 10                	mov    (%eax),%edx
  800707:	8b 48 04             	mov    0x4(%eax),%ecx
  80070a:	8d 40 08             	lea    0x8(%eax),%eax
  80070d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800710:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800715:	e9 8b 00 00 00       	jmp    8007a5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8b 10                	mov    (%eax),%edx
  80071f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800724:	8d 40 04             	lea    0x4(%eax),%eax
  800727:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80072a:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80072f:	eb 74                	jmp    8007a5 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800731:	83 f9 01             	cmp    $0x1,%ecx
  800734:	7f 1b                	jg     800751 <vprintfmt+0x354>
	else if (lflag)
  800736:	85 c9                	test   %ecx,%ecx
  800738:	74 2c                	je     800766 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80073a:	8b 45 14             	mov    0x14(%ebp),%eax
  80073d:	8b 10                	mov    (%eax),%edx
  80073f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800744:	8d 40 04             	lea    0x4(%eax),%eax
  800747:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80074a:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80074f:	eb 54                	jmp    8007a5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800751:	8b 45 14             	mov    0x14(%ebp),%eax
  800754:	8b 10                	mov    (%eax),%edx
  800756:	8b 48 04             	mov    0x4(%eax),%ecx
  800759:	8d 40 08             	lea    0x8(%eax),%eax
  80075c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80075f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800764:	eb 3f                	jmp    8007a5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800766:	8b 45 14             	mov    0x14(%ebp),%eax
  800769:	8b 10                	mov    (%eax),%edx
  80076b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800770:	8d 40 04             	lea    0x4(%eax),%eax
  800773:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800776:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80077b:	eb 28                	jmp    8007a5 <vprintfmt+0x3a8>
			putch('0', putdat);
  80077d:	83 ec 08             	sub    $0x8,%esp
  800780:	53                   	push   %ebx
  800781:	6a 30                	push   $0x30
  800783:	ff d6                	call   *%esi
			putch('x', putdat);
  800785:	83 c4 08             	add    $0x8,%esp
  800788:	53                   	push   %ebx
  800789:	6a 78                	push   $0x78
  80078b:	ff d6                	call   *%esi
			num = (unsigned long long)
  80078d:	8b 45 14             	mov    0x14(%ebp),%eax
  800790:	8b 10                	mov    (%eax),%edx
  800792:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800797:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80079a:	8d 40 04             	lea    0x4(%eax),%eax
  80079d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007a0:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8007a5:	83 ec 0c             	sub    $0xc,%esp
  8007a8:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8007ac:	50                   	push   %eax
  8007ad:	ff 75 e0             	push   -0x20(%ebp)
  8007b0:	57                   	push   %edi
  8007b1:	51                   	push   %ecx
  8007b2:	52                   	push   %edx
  8007b3:	89 da                	mov    %ebx,%edx
  8007b5:	89 f0                	mov    %esi,%eax
  8007b7:	e8 5e fb ff ff       	call   80031a <printnum>
			break;
  8007bc:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007bf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007c2:	e9 54 fc ff ff       	jmp    80041b <vprintfmt+0x1e>
	if (lflag >= 2)
  8007c7:	83 f9 01             	cmp    $0x1,%ecx
  8007ca:	7f 1b                	jg     8007e7 <vprintfmt+0x3ea>
	else if (lflag)
  8007cc:	85 c9                	test   %ecx,%ecx
  8007ce:	74 2c                	je     8007fc <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8007d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d3:	8b 10                	mov    (%eax),%edx
  8007d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007da:	8d 40 04             	lea    0x4(%eax),%eax
  8007dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007e0:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8007e5:	eb be                	jmp    8007a5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ea:	8b 10                	mov    (%eax),%edx
  8007ec:	8b 48 04             	mov    0x4(%eax),%ecx
  8007ef:	8d 40 08             	lea    0x8(%eax),%eax
  8007f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007f5:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8007fa:	eb a9                	jmp    8007a5 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ff:	8b 10                	mov    (%eax),%edx
  800801:	b9 00 00 00 00       	mov    $0x0,%ecx
  800806:	8d 40 04             	lea    0x4(%eax),%eax
  800809:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80080c:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800811:	eb 92                	jmp    8007a5 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800813:	83 ec 08             	sub    $0x8,%esp
  800816:	53                   	push   %ebx
  800817:	6a 25                	push   $0x25
  800819:	ff d6                	call   *%esi
			break;
  80081b:	83 c4 10             	add    $0x10,%esp
  80081e:	eb 9f                	jmp    8007bf <vprintfmt+0x3c2>
			putch('%', putdat);
  800820:	83 ec 08             	sub    $0x8,%esp
  800823:	53                   	push   %ebx
  800824:	6a 25                	push   $0x25
  800826:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800828:	83 c4 10             	add    $0x10,%esp
  80082b:	89 f8                	mov    %edi,%eax
  80082d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800831:	74 05                	je     800838 <vprintfmt+0x43b>
  800833:	83 e8 01             	sub    $0x1,%eax
  800836:	eb f5                	jmp    80082d <vprintfmt+0x430>
  800838:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80083b:	eb 82                	jmp    8007bf <vprintfmt+0x3c2>

0080083d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	83 ec 18             	sub    $0x18,%esp
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800849:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084c:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800850:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800853:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80085a:	85 c0                	test   %eax,%eax
  80085c:	74 26                	je     800884 <vsnprintf+0x47>
  80085e:	85 d2                	test   %edx,%edx
  800860:	7e 22                	jle    800884 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800862:	ff 75 14             	push   0x14(%ebp)
  800865:	ff 75 10             	push   0x10(%ebp)
  800868:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086b:	50                   	push   %eax
  80086c:	68 c3 03 80 00       	push   $0x8003c3
  800871:	e8 87 fb ff ff       	call   8003fd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800876:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800879:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80087c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087f:	83 c4 10             	add    $0x10,%esp
}
  800882:	c9                   	leave  
  800883:	c3                   	ret    
		return -E_INVAL;
  800884:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800889:	eb f7                	jmp    800882 <vsnprintf+0x45>

0080088b <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800891:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800894:	50                   	push   %eax
  800895:	ff 75 10             	push   0x10(%ebp)
  800898:	ff 75 0c             	push   0xc(%ebp)
  80089b:	ff 75 08             	push   0x8(%ebp)
  80089e:	e8 9a ff ff ff       	call   80083d <vsnprintf>
	va_end(ap);

	return rc;
}
  8008a3:	c9                   	leave  
  8008a4:	c3                   	ret    

008008a5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b0:	eb 03                	jmp    8008b5 <strlen+0x10>
		n++;
  8008b2:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008b5:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b9:	75 f7                	jne    8008b2 <strlen+0xd>
	return n;
}
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008c3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cb:	eb 03                	jmp    8008d0 <strnlen+0x13>
		n++;
  8008cd:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d0:	39 d0                	cmp    %edx,%eax
  8008d2:	74 08                	je     8008dc <strnlen+0x1f>
  8008d4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008d8:	75 f3                	jne    8008cd <strnlen+0x10>
  8008da:	89 c2                	mov    %eax,%edx
	return n;
}
  8008dc:	89 d0                	mov    %edx,%eax
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	53                   	push   %ebx
  8008e4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ef:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008f3:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008f6:	83 c0 01             	add    $0x1,%eax
  8008f9:	84 d2                	test   %dl,%dl
  8008fb:	75 f2                	jne    8008ef <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008fd:	89 c8                	mov    %ecx,%eax
  8008ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800902:	c9                   	leave  
  800903:	c3                   	ret    

00800904 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	53                   	push   %ebx
  800908:	83 ec 10             	sub    $0x10,%esp
  80090b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80090e:	53                   	push   %ebx
  80090f:	e8 91 ff ff ff       	call   8008a5 <strlen>
  800914:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800917:	ff 75 0c             	push   0xc(%ebp)
  80091a:	01 d8                	add    %ebx,%eax
  80091c:	50                   	push   %eax
  80091d:	e8 be ff ff ff       	call   8008e0 <strcpy>
	return dst;
}
  800922:	89 d8                	mov    %ebx,%eax
  800924:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800927:	c9                   	leave  
  800928:	c3                   	ret    

00800929 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800929:	55                   	push   %ebp
  80092a:	89 e5                	mov    %esp,%ebp
  80092c:	56                   	push   %esi
  80092d:	53                   	push   %ebx
  80092e:	8b 75 08             	mov    0x8(%ebp),%esi
  800931:	8b 55 0c             	mov    0xc(%ebp),%edx
  800934:	89 f3                	mov    %esi,%ebx
  800936:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800939:	89 f0                	mov    %esi,%eax
  80093b:	eb 0f                	jmp    80094c <strncpy+0x23>
		*dst++ = *src;
  80093d:	83 c0 01             	add    $0x1,%eax
  800940:	0f b6 0a             	movzbl (%edx),%ecx
  800943:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800946:	80 f9 01             	cmp    $0x1,%cl
  800949:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80094c:	39 d8                	cmp    %ebx,%eax
  80094e:	75 ed                	jne    80093d <strncpy+0x14>
	}
	return ret;
}
  800950:	89 f0                	mov    %esi,%eax
  800952:	5b                   	pop    %ebx
  800953:	5e                   	pop    %esi
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	56                   	push   %esi
  80095a:	53                   	push   %ebx
  80095b:	8b 75 08             	mov    0x8(%ebp),%esi
  80095e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800961:	8b 55 10             	mov    0x10(%ebp),%edx
  800964:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800966:	85 d2                	test   %edx,%edx
  800968:	74 21                	je     80098b <strlcpy+0x35>
  80096a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80096e:	89 f2                	mov    %esi,%edx
  800970:	eb 09                	jmp    80097b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800972:	83 c1 01             	add    $0x1,%ecx
  800975:	83 c2 01             	add    $0x1,%edx
  800978:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80097b:	39 c2                	cmp    %eax,%edx
  80097d:	74 09                	je     800988 <strlcpy+0x32>
  80097f:	0f b6 19             	movzbl (%ecx),%ebx
  800982:	84 db                	test   %bl,%bl
  800984:	75 ec                	jne    800972 <strlcpy+0x1c>
  800986:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800988:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80098b:	29 f0                	sub    %esi,%eax
}
  80098d:	5b                   	pop    %ebx
  80098e:	5e                   	pop    %esi
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800997:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80099a:	eb 06                	jmp    8009a2 <strcmp+0x11>
		p++, q++;
  80099c:	83 c1 01             	add    $0x1,%ecx
  80099f:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  8009a2:	0f b6 01             	movzbl (%ecx),%eax
  8009a5:	84 c0                	test   %al,%al
  8009a7:	74 04                	je     8009ad <strcmp+0x1c>
  8009a9:	3a 02                	cmp    (%edx),%al
  8009ab:	74 ef                	je     80099c <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009ad:	0f b6 c0             	movzbl %al,%eax
  8009b0:	0f b6 12             	movzbl (%edx),%edx
  8009b3:	29 d0                	sub    %edx,%eax
}
  8009b5:	5d                   	pop    %ebp
  8009b6:	c3                   	ret    

008009b7 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	53                   	push   %ebx
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c1:	89 c3                	mov    %eax,%ebx
  8009c3:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009c6:	eb 06                	jmp    8009ce <strncmp+0x17>
		n--, p++, q++;
  8009c8:	83 c0 01             	add    $0x1,%eax
  8009cb:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009ce:	39 d8                	cmp    %ebx,%eax
  8009d0:	74 18                	je     8009ea <strncmp+0x33>
  8009d2:	0f b6 08             	movzbl (%eax),%ecx
  8009d5:	84 c9                	test   %cl,%cl
  8009d7:	74 04                	je     8009dd <strncmp+0x26>
  8009d9:	3a 0a                	cmp    (%edx),%cl
  8009db:	74 eb                	je     8009c8 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009dd:	0f b6 00             	movzbl (%eax),%eax
  8009e0:	0f b6 12             	movzbl (%edx),%edx
  8009e3:	29 d0                	sub    %edx,%eax
}
  8009e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    
		return 0;
  8009ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ef:	eb f4                	jmp    8009e5 <strncmp+0x2e>

008009f1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009f1:	55                   	push   %ebp
  8009f2:	89 e5                	mov    %esp,%ebp
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009fb:	eb 03                	jmp    800a00 <strchr+0xf>
  8009fd:	83 c0 01             	add    $0x1,%eax
  800a00:	0f b6 10             	movzbl (%eax),%edx
  800a03:	84 d2                	test   %dl,%dl
  800a05:	74 06                	je     800a0d <strchr+0x1c>
		if (*s == c)
  800a07:	38 ca                	cmp    %cl,%dl
  800a09:	75 f2                	jne    8009fd <strchr+0xc>
  800a0b:	eb 05                	jmp    800a12 <strchr+0x21>
			return (char *) s;
	return 0;
  800a0d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a1e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a21:	38 ca                	cmp    %cl,%dl
  800a23:	74 09                	je     800a2e <strfind+0x1a>
  800a25:	84 d2                	test   %dl,%dl
  800a27:	74 05                	je     800a2e <strfind+0x1a>
	for (; *s; s++)
  800a29:	83 c0 01             	add    $0x1,%eax
  800a2c:	eb f0                	jmp    800a1e <strfind+0xa>
			break;
	return (char *) s;
}
  800a2e:	5d                   	pop    %ebp
  800a2f:	c3                   	ret    

00800a30 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a30:	55                   	push   %ebp
  800a31:	89 e5                	mov    %esp,%ebp
  800a33:	57                   	push   %edi
  800a34:	56                   	push   %esi
  800a35:	53                   	push   %ebx
  800a36:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a39:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a3c:	85 c9                	test   %ecx,%ecx
  800a3e:	74 2f                	je     800a6f <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a40:	89 f8                	mov    %edi,%eax
  800a42:	09 c8                	or     %ecx,%eax
  800a44:	a8 03                	test   $0x3,%al
  800a46:	75 21                	jne    800a69 <memset+0x39>
		c &= 0xFF;
  800a48:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a4c:	89 d0                	mov    %edx,%eax
  800a4e:	c1 e0 08             	shl    $0x8,%eax
  800a51:	89 d3                	mov    %edx,%ebx
  800a53:	c1 e3 18             	shl    $0x18,%ebx
  800a56:	89 d6                	mov    %edx,%esi
  800a58:	c1 e6 10             	shl    $0x10,%esi
  800a5b:	09 f3                	or     %esi,%ebx
  800a5d:	09 da                	or     %ebx,%edx
  800a5f:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a61:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a64:	fc                   	cld    
  800a65:	f3 ab                	rep stos %eax,%es:(%edi)
  800a67:	eb 06                	jmp    800a6f <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6c:	fc                   	cld    
  800a6d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a6f:	89 f8                	mov    %edi,%eax
  800a71:	5b                   	pop    %ebx
  800a72:	5e                   	pop    %esi
  800a73:	5f                   	pop    %edi
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	57                   	push   %edi
  800a7a:	56                   	push   %esi
  800a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a7e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a81:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a84:	39 c6                	cmp    %eax,%esi
  800a86:	73 32                	jae    800aba <memmove+0x44>
  800a88:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a8b:	39 c2                	cmp    %eax,%edx
  800a8d:	76 2b                	jbe    800aba <memmove+0x44>
		s += n;
		d += n;
  800a8f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a92:	89 d6                	mov    %edx,%esi
  800a94:	09 fe                	or     %edi,%esi
  800a96:	09 ce                	or     %ecx,%esi
  800a98:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a9e:	75 0e                	jne    800aae <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800aa0:	83 ef 04             	sub    $0x4,%edi
  800aa3:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa6:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800aa9:	fd                   	std    
  800aaa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aac:	eb 09                	jmp    800ab7 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aae:	83 ef 01             	sub    $0x1,%edi
  800ab1:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800ab4:	fd                   	std    
  800ab5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab7:	fc                   	cld    
  800ab8:	eb 1a                	jmp    800ad4 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aba:	89 f2                	mov    %esi,%edx
  800abc:	09 c2                	or     %eax,%edx
  800abe:	09 ca                	or     %ecx,%edx
  800ac0:	f6 c2 03             	test   $0x3,%dl
  800ac3:	75 0a                	jne    800acf <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ac5:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ac8:	89 c7                	mov    %eax,%edi
  800aca:	fc                   	cld    
  800acb:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800acd:	eb 05                	jmp    800ad4 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800acf:	89 c7                	mov    %eax,%edi
  800ad1:	fc                   	cld    
  800ad2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad4:	5e                   	pop    %esi
  800ad5:	5f                   	pop    %edi
  800ad6:	5d                   	pop    %ebp
  800ad7:	c3                   	ret    

00800ad8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad8:	55                   	push   %ebp
  800ad9:	89 e5                	mov    %esp,%ebp
  800adb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ade:	ff 75 10             	push   0x10(%ebp)
  800ae1:	ff 75 0c             	push   0xc(%ebp)
  800ae4:	ff 75 08             	push   0x8(%ebp)
  800ae7:	e8 8a ff ff ff       	call   800a76 <memmove>
}
  800aec:	c9                   	leave  
  800aed:	c3                   	ret    

00800aee <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
  800af3:	8b 45 08             	mov    0x8(%ebp),%eax
  800af6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af9:	89 c6                	mov    %eax,%esi
  800afb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800afe:	eb 06                	jmp    800b06 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b00:	83 c0 01             	add    $0x1,%eax
  800b03:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800b06:	39 f0                	cmp    %esi,%eax
  800b08:	74 14                	je     800b1e <memcmp+0x30>
		if (*s1 != *s2)
  800b0a:	0f b6 08             	movzbl (%eax),%ecx
  800b0d:	0f b6 1a             	movzbl (%edx),%ebx
  800b10:	38 d9                	cmp    %bl,%cl
  800b12:	74 ec                	je     800b00 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b14:	0f b6 c1             	movzbl %cl,%eax
  800b17:	0f b6 db             	movzbl %bl,%ebx
  800b1a:	29 d8                	sub    %ebx,%eax
  800b1c:	eb 05                	jmp    800b23 <memcmp+0x35>
	}

	return 0;
  800b1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b23:	5b                   	pop    %ebx
  800b24:	5e                   	pop    %esi
  800b25:	5d                   	pop    %ebp
  800b26:	c3                   	ret    

00800b27 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b30:	89 c2                	mov    %eax,%edx
  800b32:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b35:	eb 03                	jmp    800b3a <memfind+0x13>
  800b37:	83 c0 01             	add    $0x1,%eax
  800b3a:	39 d0                	cmp    %edx,%eax
  800b3c:	73 04                	jae    800b42 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b3e:	38 08                	cmp    %cl,(%eax)
  800b40:	75 f5                	jne    800b37 <memfind+0x10>
			break;
	return (void *) s;
}
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	57                   	push   %edi
  800b48:	56                   	push   %esi
  800b49:	53                   	push   %ebx
  800b4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b50:	eb 03                	jmp    800b55 <strtol+0x11>
		s++;
  800b52:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b55:	0f b6 02             	movzbl (%edx),%eax
  800b58:	3c 20                	cmp    $0x20,%al
  800b5a:	74 f6                	je     800b52 <strtol+0xe>
  800b5c:	3c 09                	cmp    $0x9,%al
  800b5e:	74 f2                	je     800b52 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b60:	3c 2b                	cmp    $0x2b,%al
  800b62:	74 2a                	je     800b8e <strtol+0x4a>
	int neg = 0;
  800b64:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b69:	3c 2d                	cmp    $0x2d,%al
  800b6b:	74 2b                	je     800b98 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b6d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b73:	75 0f                	jne    800b84 <strtol+0x40>
  800b75:	80 3a 30             	cmpb   $0x30,(%edx)
  800b78:	74 28                	je     800ba2 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b7a:	85 db                	test   %ebx,%ebx
  800b7c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b81:	0f 44 d8             	cmove  %eax,%ebx
  800b84:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b89:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b8c:	eb 46                	jmp    800bd4 <strtol+0x90>
		s++;
  800b8e:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b91:	bf 00 00 00 00       	mov    $0x0,%edi
  800b96:	eb d5                	jmp    800b6d <strtol+0x29>
		s++, neg = 1;
  800b98:	83 c2 01             	add    $0x1,%edx
  800b9b:	bf 01 00 00 00       	mov    $0x1,%edi
  800ba0:	eb cb                	jmp    800b6d <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba2:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ba6:	74 0e                	je     800bb6 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ba8:	85 db                	test   %ebx,%ebx
  800baa:	75 d8                	jne    800b84 <strtol+0x40>
		s++, base = 8;
  800bac:	83 c2 01             	add    $0x1,%edx
  800baf:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bb4:	eb ce                	jmp    800b84 <strtol+0x40>
		s += 2, base = 16;
  800bb6:	83 c2 02             	add    $0x2,%edx
  800bb9:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bbe:	eb c4                	jmp    800b84 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bc0:	0f be c0             	movsbl %al,%eax
  800bc3:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bc6:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bc9:	7d 3a                	jge    800c05 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bcb:	83 c2 01             	add    $0x1,%edx
  800bce:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bd2:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800bd4:	0f b6 02             	movzbl (%edx),%eax
  800bd7:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bda:	89 f3                	mov    %esi,%ebx
  800bdc:	80 fb 09             	cmp    $0x9,%bl
  800bdf:	76 df                	jbe    800bc0 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800be1:	8d 70 9f             	lea    -0x61(%eax),%esi
  800be4:	89 f3                	mov    %esi,%ebx
  800be6:	80 fb 19             	cmp    $0x19,%bl
  800be9:	77 08                	ja     800bf3 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800beb:	0f be c0             	movsbl %al,%eax
  800bee:	83 e8 57             	sub    $0x57,%eax
  800bf1:	eb d3                	jmp    800bc6 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800bf3:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bf6:	89 f3                	mov    %esi,%ebx
  800bf8:	80 fb 19             	cmp    $0x19,%bl
  800bfb:	77 08                	ja     800c05 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bfd:	0f be c0             	movsbl %al,%eax
  800c00:	83 e8 37             	sub    $0x37,%eax
  800c03:	eb c1                	jmp    800bc6 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c05:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c09:	74 05                	je     800c10 <strtol+0xcc>
		*endptr = (char *) s;
  800c0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c0e:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c10:	89 c8                	mov    %ecx,%eax
  800c12:	f7 d8                	neg    %eax
  800c14:	85 ff                	test   %edi,%edi
  800c16:	0f 45 c8             	cmovne %eax,%ecx
}
  800c19:	89 c8                	mov    %ecx,%eax
  800c1b:	5b                   	pop    %ebx
  800c1c:	5e                   	pop    %esi
  800c1d:	5f                   	pop    %edi
  800c1e:	5d                   	pop    %ebp
  800c1f:	c3                   	ret    

00800c20 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c20:	55                   	push   %ebp
  800c21:	89 e5                	mov    %esp,%ebp
  800c23:	57                   	push   %edi
  800c24:	56                   	push   %esi
  800c25:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c26:	b8 00 00 00 00       	mov    $0x0,%eax
  800c2b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c31:	89 c3                	mov    %eax,%ebx
  800c33:	89 c7                	mov    %eax,%edi
  800c35:	89 c6                	mov    %eax,%esi
  800c37:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c39:	5b                   	pop    %ebx
  800c3a:	5e                   	pop    %esi
  800c3b:	5f                   	pop    %edi
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <sys_cgetc>:

int
sys_cgetc(void)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	57                   	push   %edi
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c44:	ba 00 00 00 00       	mov    $0x0,%edx
  800c49:	b8 01 00 00 00       	mov    $0x1,%eax
  800c4e:	89 d1                	mov    %edx,%ecx
  800c50:	89 d3                	mov    %edx,%ebx
  800c52:	89 d7                	mov    %edx,%edi
  800c54:	89 d6                	mov    %edx,%esi
  800c56:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c58:	5b                   	pop    %ebx
  800c59:	5e                   	pop    %esi
  800c5a:	5f                   	pop    %edi
  800c5b:	5d                   	pop    %ebp
  800c5c:	c3                   	ret    

00800c5d <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	57                   	push   %edi
  800c61:	56                   	push   %esi
  800c62:	53                   	push   %ebx
  800c63:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c66:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c6b:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c73:	89 cb                	mov    %ecx,%ebx
  800c75:	89 cf                	mov    %ecx,%edi
  800c77:	89 ce                	mov    %ecx,%esi
  800c79:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c7b:	85 c0                	test   %eax,%eax
  800c7d:	7f 08                	jg     800c87 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c82:	5b                   	pop    %ebx
  800c83:	5e                   	pop    %esi
  800c84:	5f                   	pop    %edi
  800c85:	5d                   	pop    %ebp
  800c86:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c87:	83 ec 0c             	sub    $0xc,%esp
  800c8a:	50                   	push   %eax
  800c8b:	6a 03                	push   $0x3
  800c8d:	68 9f 22 80 00       	push   $0x80229f
  800c92:	6a 2a                	push   $0x2a
  800c94:	68 bc 22 80 00       	push   $0x8022bc
  800c99:	e8 8d f5 ff ff       	call   80022b <_panic>

00800c9e <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	57                   	push   %edi
  800ca2:	56                   	push   %esi
  800ca3:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ca4:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca9:	b8 02 00 00 00       	mov    $0x2,%eax
  800cae:	89 d1                	mov    %edx,%ecx
  800cb0:	89 d3                	mov    %edx,%ebx
  800cb2:	89 d7                	mov    %edx,%edi
  800cb4:	89 d6                	mov    %edx,%esi
  800cb6:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cb8:	5b                   	pop    %ebx
  800cb9:	5e                   	pop    %esi
  800cba:	5f                   	pop    %edi
  800cbb:	5d                   	pop    %ebp
  800cbc:	c3                   	ret    

00800cbd <sys_yield>:

void
sys_yield(void)
{
  800cbd:	55                   	push   %ebp
  800cbe:	89 e5                	mov    %esp,%ebp
  800cc0:	57                   	push   %edi
  800cc1:	56                   	push   %esi
  800cc2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cc3:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ccd:	89 d1                	mov    %edx,%ecx
  800ccf:	89 d3                	mov    %edx,%ebx
  800cd1:	89 d7                	mov    %edx,%edi
  800cd3:	89 d6                	mov    %edx,%esi
  800cd5:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800cd7:	5b                   	pop    %ebx
  800cd8:	5e                   	pop    %esi
  800cd9:	5f                   	pop    %edi
  800cda:	5d                   	pop    %ebp
  800cdb:	c3                   	ret    

00800cdc <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cdc:	55                   	push   %ebp
  800cdd:	89 e5                	mov    %esp,%ebp
  800cdf:	57                   	push   %edi
  800ce0:	56                   	push   %esi
  800ce1:	53                   	push   %ebx
  800ce2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800ce5:	be 00 00 00 00       	mov    $0x0,%esi
  800cea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	b8 04 00 00 00       	mov    $0x4,%eax
  800cf5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf8:	89 f7                	mov    %esi,%edi
  800cfa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cfc:	85 c0                	test   %eax,%eax
  800cfe:	7f 08                	jg     800d08 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d08:	83 ec 0c             	sub    $0xc,%esp
  800d0b:	50                   	push   %eax
  800d0c:	6a 04                	push   $0x4
  800d0e:	68 9f 22 80 00       	push   $0x80229f
  800d13:	6a 2a                	push   $0x2a
  800d15:	68 bc 22 80 00       	push   $0x8022bc
  800d1a:	e8 0c f5 ff ff       	call   80022b <_panic>

00800d1f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d1f:	55                   	push   %ebp
  800d20:	89 e5                	mov    %esp,%ebp
  800d22:	57                   	push   %edi
  800d23:	56                   	push   %esi
  800d24:	53                   	push   %ebx
  800d25:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d28:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2e:	b8 05 00 00 00       	mov    $0x5,%eax
  800d33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d36:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d39:	8b 75 18             	mov    0x18(%ebp),%esi
  800d3c:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d3e:	85 c0                	test   %eax,%eax
  800d40:	7f 08                	jg     800d4a <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d42:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4a:	83 ec 0c             	sub    $0xc,%esp
  800d4d:	50                   	push   %eax
  800d4e:	6a 05                	push   $0x5
  800d50:	68 9f 22 80 00       	push   $0x80229f
  800d55:	6a 2a                	push   $0x2a
  800d57:	68 bc 22 80 00       	push   $0x8022bc
  800d5c:	e8 ca f4 ff ff       	call   80022b <_panic>

00800d61 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	57                   	push   %edi
  800d65:	56                   	push   %esi
  800d66:	53                   	push   %ebx
  800d67:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d75:	b8 06 00 00 00       	mov    $0x6,%eax
  800d7a:	89 df                	mov    %ebx,%edi
  800d7c:	89 de                	mov    %ebx,%esi
  800d7e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d80:	85 c0                	test   %eax,%eax
  800d82:	7f 08                	jg     800d8c <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d84:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d87:	5b                   	pop    %ebx
  800d88:	5e                   	pop    %esi
  800d89:	5f                   	pop    %edi
  800d8a:	5d                   	pop    %ebp
  800d8b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8c:	83 ec 0c             	sub    $0xc,%esp
  800d8f:	50                   	push   %eax
  800d90:	6a 06                	push   $0x6
  800d92:	68 9f 22 80 00       	push   $0x80229f
  800d97:	6a 2a                	push   $0x2a
  800d99:	68 bc 22 80 00       	push   $0x8022bc
  800d9e:	e8 88 f4 ff ff       	call   80022b <_panic>

00800da3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
  800da9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db1:	8b 55 08             	mov    0x8(%ebp),%edx
  800db4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db7:	b8 08 00 00 00       	mov    $0x8,%eax
  800dbc:	89 df                	mov    %ebx,%edi
  800dbe:	89 de                	mov    %ebx,%esi
  800dc0:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	7f 08                	jg     800dce <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc9:	5b                   	pop    %ebx
  800dca:	5e                   	pop    %esi
  800dcb:	5f                   	pop    %edi
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dce:	83 ec 0c             	sub    $0xc,%esp
  800dd1:	50                   	push   %eax
  800dd2:	6a 08                	push   $0x8
  800dd4:	68 9f 22 80 00       	push   $0x80229f
  800dd9:	6a 2a                	push   $0x2a
  800ddb:	68 bc 22 80 00       	push   $0x8022bc
  800de0:	e8 46 f4 ff ff       	call   80022b <_panic>

00800de5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	57                   	push   %edi
  800de9:	56                   	push   %esi
  800dea:	53                   	push   %ebx
  800deb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800dee:	bb 00 00 00 00       	mov    $0x0,%ebx
  800df3:	8b 55 08             	mov    0x8(%ebp),%edx
  800df6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df9:	b8 09 00 00 00       	mov    $0x9,%eax
  800dfe:	89 df                	mov    %ebx,%edi
  800e00:	89 de                	mov    %ebx,%esi
  800e02:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e04:	85 c0                	test   %eax,%eax
  800e06:	7f 08                	jg     800e10 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800e08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5f                   	pop    %edi
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e10:	83 ec 0c             	sub    $0xc,%esp
  800e13:	50                   	push   %eax
  800e14:	6a 09                	push   $0x9
  800e16:	68 9f 22 80 00       	push   $0x80229f
  800e1b:	6a 2a                	push   $0x2a
  800e1d:	68 bc 22 80 00       	push   $0x8022bc
  800e22:	e8 04 f4 ff ff       	call   80022b <_panic>

00800e27 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e27:	55                   	push   %ebp
  800e28:	89 e5                	mov    %esp,%ebp
  800e2a:	57                   	push   %edi
  800e2b:	56                   	push   %esi
  800e2c:	53                   	push   %ebx
  800e2d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e30:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e35:	8b 55 08             	mov    0x8(%ebp),%edx
  800e38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e40:	89 df                	mov    %ebx,%edi
  800e42:	89 de                	mov    %ebx,%esi
  800e44:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e46:	85 c0                	test   %eax,%eax
  800e48:	7f 08                	jg     800e52 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e4d:	5b                   	pop    %ebx
  800e4e:	5e                   	pop    %esi
  800e4f:	5f                   	pop    %edi
  800e50:	5d                   	pop    %ebp
  800e51:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e52:	83 ec 0c             	sub    $0xc,%esp
  800e55:	50                   	push   %eax
  800e56:	6a 0a                	push   $0xa
  800e58:	68 9f 22 80 00       	push   $0x80229f
  800e5d:	6a 2a                	push   $0x2a
  800e5f:	68 bc 22 80 00       	push   $0x8022bc
  800e64:	e8 c2 f3 ff ff       	call   80022b <_panic>

00800e69 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	57                   	push   %edi
  800e6d:	56                   	push   %esi
  800e6e:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e6f:	8b 55 08             	mov    0x8(%ebp),%edx
  800e72:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e75:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e7a:	be 00 00 00 00       	mov    $0x0,%esi
  800e7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e82:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e85:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e87:	5b                   	pop    %ebx
  800e88:	5e                   	pop    %esi
  800e89:	5f                   	pop    %edi
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	57                   	push   %edi
  800e90:	56                   	push   %esi
  800e91:	53                   	push   %ebx
  800e92:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e95:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ea2:	89 cb                	mov    %ecx,%ebx
  800ea4:	89 cf                	mov    %ecx,%edi
  800ea6:	89 ce                	mov    %ecx,%esi
  800ea8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800eaa:	85 c0                	test   %eax,%eax
  800eac:	7f 08                	jg     800eb6 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800eae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb1:	5b                   	pop    %ebx
  800eb2:	5e                   	pop    %esi
  800eb3:	5f                   	pop    %edi
  800eb4:	5d                   	pop    %ebp
  800eb5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800eb6:	83 ec 0c             	sub    $0xc,%esp
  800eb9:	50                   	push   %eax
  800eba:	6a 0d                	push   $0xd
  800ebc:	68 9f 22 80 00       	push   $0x80229f
  800ec1:	6a 2a                	push   $0x2a
  800ec3:	68 bc 22 80 00       	push   $0x8022bc
  800ec8:	e8 5e f3 ff ff       	call   80022b <_panic>

00800ecd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ed0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed3:	05 00 00 00 30       	add    $0x30000000,%eax
  800ed8:	c1 e8 0c             	shr    $0xc,%eax
}
  800edb:	5d                   	pop    %ebp
  800edc:	c3                   	ret    

00800edd <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ee0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee3:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800ee8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800eed:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800ef2:	5d                   	pop    %ebp
  800ef3:	c3                   	ret    

00800ef4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800efc:	89 c2                	mov    %eax,%edx
  800efe:	c1 ea 16             	shr    $0x16,%edx
  800f01:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f08:	f6 c2 01             	test   $0x1,%dl
  800f0b:	74 29                	je     800f36 <fd_alloc+0x42>
  800f0d:	89 c2                	mov    %eax,%edx
  800f0f:	c1 ea 0c             	shr    $0xc,%edx
  800f12:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f19:	f6 c2 01             	test   $0x1,%dl
  800f1c:	74 18                	je     800f36 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800f1e:	05 00 10 00 00       	add    $0x1000,%eax
  800f23:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f28:	75 d2                	jne    800efc <fd_alloc+0x8>
  800f2a:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800f2f:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800f34:	eb 05                	jmp    800f3b <fd_alloc+0x47>
			return 0;
  800f36:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800f3b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f3e:	89 02                	mov    %eax,(%edx)
}
  800f40:	89 c8                	mov    %ecx,%eax
  800f42:	5d                   	pop    %ebp
  800f43:	c3                   	ret    

00800f44 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800f4a:	83 f8 1f             	cmp    $0x1f,%eax
  800f4d:	77 30                	ja     800f7f <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800f4f:	c1 e0 0c             	shl    $0xc,%eax
  800f52:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800f57:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800f5d:	f6 c2 01             	test   $0x1,%dl
  800f60:	74 24                	je     800f86 <fd_lookup+0x42>
  800f62:	89 c2                	mov    %eax,%edx
  800f64:	c1 ea 0c             	shr    $0xc,%edx
  800f67:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f6e:	f6 c2 01             	test   $0x1,%dl
  800f71:	74 1a                	je     800f8d <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800f73:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f76:	89 02                	mov    %eax,(%edx)
	return 0;
  800f78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f7d:	5d                   	pop    %ebp
  800f7e:	c3                   	ret    
		return -E_INVAL;
  800f7f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f84:	eb f7                	jmp    800f7d <fd_lookup+0x39>
		return -E_INVAL;
  800f86:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f8b:	eb f0                	jmp    800f7d <fd_lookup+0x39>
  800f8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800f92:	eb e9                	jmp    800f7d <fd_lookup+0x39>

00800f94 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800f94:	55                   	push   %ebp
  800f95:	89 e5                	mov    %esp,%ebp
  800f97:	53                   	push   %ebx
  800f98:	83 ec 04             	sub    $0x4,%esp
  800f9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9e:	b8 48 23 80 00       	mov    $0x802348,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800fa3:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800fa8:	39 13                	cmp    %edx,(%ebx)
  800faa:	74 32                	je     800fde <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800fac:	83 c0 04             	add    $0x4,%eax
  800faf:	8b 18                	mov    (%eax),%ebx
  800fb1:	85 db                	test   %ebx,%ebx
  800fb3:	75 f3                	jne    800fa8 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800fb5:	a1 00 40 80 00       	mov    0x804000,%eax
  800fba:	8b 40 48             	mov    0x48(%eax),%eax
  800fbd:	83 ec 04             	sub    $0x4,%esp
  800fc0:	52                   	push   %edx
  800fc1:	50                   	push   %eax
  800fc2:	68 cc 22 80 00       	push   $0x8022cc
  800fc7:	e8 3a f3 ff ff       	call   800306 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800fcc:	83 c4 10             	add    $0x10,%esp
  800fcf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800fd4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fd7:	89 1a                	mov    %ebx,(%edx)
}
  800fd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fdc:	c9                   	leave  
  800fdd:	c3                   	ret    
			return 0;
  800fde:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe3:	eb ef                	jmp    800fd4 <dev_lookup+0x40>

00800fe5 <fd_close>:
{
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	57                   	push   %edi
  800fe9:	56                   	push   %esi
  800fea:	53                   	push   %ebx
  800feb:	83 ec 24             	sub    $0x24,%esp
  800fee:	8b 75 08             	mov    0x8(%ebp),%esi
  800ff1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ff4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ff7:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ff8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ffe:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801001:	50                   	push   %eax
  801002:	e8 3d ff ff ff       	call   800f44 <fd_lookup>
  801007:	89 c3                	mov    %eax,%ebx
  801009:	83 c4 10             	add    $0x10,%esp
  80100c:	85 c0                	test   %eax,%eax
  80100e:	78 05                	js     801015 <fd_close+0x30>
	    || fd != fd2)
  801010:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801013:	74 16                	je     80102b <fd_close+0x46>
		return (must_exist ? r : 0);
  801015:	89 f8                	mov    %edi,%eax
  801017:	84 c0                	test   %al,%al
  801019:	b8 00 00 00 00       	mov    $0x0,%eax
  80101e:	0f 44 d8             	cmove  %eax,%ebx
}
  801021:	89 d8                	mov    %ebx,%eax
  801023:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801026:	5b                   	pop    %ebx
  801027:	5e                   	pop    %esi
  801028:	5f                   	pop    %edi
  801029:	5d                   	pop    %ebp
  80102a:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80102b:	83 ec 08             	sub    $0x8,%esp
  80102e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801031:	50                   	push   %eax
  801032:	ff 36                	push   (%esi)
  801034:	e8 5b ff ff ff       	call   800f94 <dev_lookup>
  801039:	89 c3                	mov    %eax,%ebx
  80103b:	83 c4 10             	add    $0x10,%esp
  80103e:	85 c0                	test   %eax,%eax
  801040:	78 1a                	js     80105c <fd_close+0x77>
		if (dev->dev_close)
  801042:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801045:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801048:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80104d:	85 c0                	test   %eax,%eax
  80104f:	74 0b                	je     80105c <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  801051:	83 ec 0c             	sub    $0xc,%esp
  801054:	56                   	push   %esi
  801055:	ff d0                	call   *%eax
  801057:	89 c3                	mov    %eax,%ebx
  801059:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80105c:	83 ec 08             	sub    $0x8,%esp
  80105f:	56                   	push   %esi
  801060:	6a 00                	push   $0x0
  801062:	e8 fa fc ff ff       	call   800d61 <sys_page_unmap>
	return r;
  801067:	83 c4 10             	add    $0x10,%esp
  80106a:	eb b5                	jmp    801021 <fd_close+0x3c>

0080106c <close>:

int
close(int fdnum)
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801072:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801075:	50                   	push   %eax
  801076:	ff 75 08             	push   0x8(%ebp)
  801079:	e8 c6 fe ff ff       	call   800f44 <fd_lookup>
  80107e:	83 c4 10             	add    $0x10,%esp
  801081:	85 c0                	test   %eax,%eax
  801083:	79 02                	jns    801087 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  801085:	c9                   	leave  
  801086:	c3                   	ret    
		return fd_close(fd, 1);
  801087:	83 ec 08             	sub    $0x8,%esp
  80108a:	6a 01                	push   $0x1
  80108c:	ff 75 f4             	push   -0xc(%ebp)
  80108f:	e8 51 ff ff ff       	call   800fe5 <fd_close>
  801094:	83 c4 10             	add    $0x10,%esp
  801097:	eb ec                	jmp    801085 <close+0x19>

00801099 <close_all>:

void
close_all(void)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	53                   	push   %ebx
  80109d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8010a0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8010a5:	83 ec 0c             	sub    $0xc,%esp
  8010a8:	53                   	push   %ebx
  8010a9:	e8 be ff ff ff       	call   80106c <close>
	for (i = 0; i < MAXFD; i++)
  8010ae:	83 c3 01             	add    $0x1,%ebx
  8010b1:	83 c4 10             	add    $0x10,%esp
  8010b4:	83 fb 20             	cmp    $0x20,%ebx
  8010b7:	75 ec                	jne    8010a5 <close_all+0xc>
}
  8010b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010bc:	c9                   	leave  
  8010bd:	c3                   	ret    

008010be <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	57                   	push   %edi
  8010c2:	56                   	push   %esi
  8010c3:	53                   	push   %ebx
  8010c4:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8010c7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8010ca:	50                   	push   %eax
  8010cb:	ff 75 08             	push   0x8(%ebp)
  8010ce:	e8 71 fe ff ff       	call   800f44 <fd_lookup>
  8010d3:	89 c3                	mov    %eax,%ebx
  8010d5:	83 c4 10             	add    $0x10,%esp
  8010d8:	85 c0                	test   %eax,%eax
  8010da:	78 7f                	js     80115b <dup+0x9d>
		return r;
	close(newfdnum);
  8010dc:	83 ec 0c             	sub    $0xc,%esp
  8010df:	ff 75 0c             	push   0xc(%ebp)
  8010e2:	e8 85 ff ff ff       	call   80106c <close>

	newfd = INDEX2FD(newfdnum);
  8010e7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010ea:	c1 e6 0c             	shl    $0xc,%esi
  8010ed:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8010f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8010f6:	89 3c 24             	mov    %edi,(%esp)
  8010f9:	e8 df fd ff ff       	call   800edd <fd2data>
  8010fe:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801100:	89 34 24             	mov    %esi,(%esp)
  801103:	e8 d5 fd ff ff       	call   800edd <fd2data>
  801108:	83 c4 10             	add    $0x10,%esp
  80110b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80110e:	89 d8                	mov    %ebx,%eax
  801110:	c1 e8 16             	shr    $0x16,%eax
  801113:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80111a:	a8 01                	test   $0x1,%al
  80111c:	74 11                	je     80112f <dup+0x71>
  80111e:	89 d8                	mov    %ebx,%eax
  801120:	c1 e8 0c             	shr    $0xc,%eax
  801123:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80112a:	f6 c2 01             	test   $0x1,%dl
  80112d:	75 36                	jne    801165 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80112f:	89 f8                	mov    %edi,%eax
  801131:	c1 e8 0c             	shr    $0xc,%eax
  801134:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80113b:	83 ec 0c             	sub    $0xc,%esp
  80113e:	25 07 0e 00 00       	and    $0xe07,%eax
  801143:	50                   	push   %eax
  801144:	56                   	push   %esi
  801145:	6a 00                	push   $0x0
  801147:	57                   	push   %edi
  801148:	6a 00                	push   $0x0
  80114a:	e8 d0 fb ff ff       	call   800d1f <sys_page_map>
  80114f:	89 c3                	mov    %eax,%ebx
  801151:	83 c4 20             	add    $0x20,%esp
  801154:	85 c0                	test   %eax,%eax
  801156:	78 33                	js     80118b <dup+0xcd>
		goto err;

	return newfdnum;
  801158:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80115b:	89 d8                	mov    %ebx,%eax
  80115d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801160:	5b                   	pop    %ebx
  801161:	5e                   	pop    %esi
  801162:	5f                   	pop    %edi
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801165:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80116c:	83 ec 0c             	sub    $0xc,%esp
  80116f:	25 07 0e 00 00       	and    $0xe07,%eax
  801174:	50                   	push   %eax
  801175:	ff 75 d4             	push   -0x2c(%ebp)
  801178:	6a 00                	push   $0x0
  80117a:	53                   	push   %ebx
  80117b:	6a 00                	push   $0x0
  80117d:	e8 9d fb ff ff       	call   800d1f <sys_page_map>
  801182:	89 c3                	mov    %eax,%ebx
  801184:	83 c4 20             	add    $0x20,%esp
  801187:	85 c0                	test   %eax,%eax
  801189:	79 a4                	jns    80112f <dup+0x71>
	sys_page_unmap(0, newfd);
  80118b:	83 ec 08             	sub    $0x8,%esp
  80118e:	56                   	push   %esi
  80118f:	6a 00                	push   $0x0
  801191:	e8 cb fb ff ff       	call   800d61 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801196:	83 c4 08             	add    $0x8,%esp
  801199:	ff 75 d4             	push   -0x2c(%ebp)
  80119c:	6a 00                	push   $0x0
  80119e:	e8 be fb ff ff       	call   800d61 <sys_page_unmap>
	return r;
  8011a3:	83 c4 10             	add    $0x10,%esp
  8011a6:	eb b3                	jmp    80115b <dup+0x9d>

008011a8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	56                   	push   %esi
  8011ac:	53                   	push   %ebx
  8011ad:	83 ec 18             	sub    $0x18,%esp
  8011b0:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b6:	50                   	push   %eax
  8011b7:	56                   	push   %esi
  8011b8:	e8 87 fd ff ff       	call   800f44 <fd_lookup>
  8011bd:	83 c4 10             	add    $0x10,%esp
  8011c0:	85 c0                	test   %eax,%eax
  8011c2:	78 3c                	js     801200 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c4:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8011c7:	83 ec 08             	sub    $0x8,%esp
  8011ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cd:	50                   	push   %eax
  8011ce:	ff 33                	push   (%ebx)
  8011d0:	e8 bf fd ff ff       	call   800f94 <dev_lookup>
  8011d5:	83 c4 10             	add    $0x10,%esp
  8011d8:	85 c0                	test   %eax,%eax
  8011da:	78 24                	js     801200 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8011dc:	8b 43 08             	mov    0x8(%ebx),%eax
  8011df:	83 e0 03             	and    $0x3,%eax
  8011e2:	83 f8 01             	cmp    $0x1,%eax
  8011e5:	74 20                	je     801207 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8011e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ea:	8b 40 08             	mov    0x8(%eax),%eax
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	74 37                	je     801228 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8011f1:	83 ec 04             	sub    $0x4,%esp
  8011f4:	ff 75 10             	push   0x10(%ebp)
  8011f7:	ff 75 0c             	push   0xc(%ebp)
  8011fa:	53                   	push   %ebx
  8011fb:	ff d0                	call   *%eax
  8011fd:	83 c4 10             	add    $0x10,%esp
}
  801200:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801203:	5b                   	pop    %ebx
  801204:	5e                   	pop    %esi
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801207:	a1 00 40 80 00       	mov    0x804000,%eax
  80120c:	8b 40 48             	mov    0x48(%eax),%eax
  80120f:	83 ec 04             	sub    $0x4,%esp
  801212:	56                   	push   %esi
  801213:	50                   	push   %eax
  801214:	68 0d 23 80 00       	push   $0x80230d
  801219:	e8 e8 f0 ff ff       	call   800306 <cprintf>
		return -E_INVAL;
  80121e:	83 c4 10             	add    $0x10,%esp
  801221:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801226:	eb d8                	jmp    801200 <read+0x58>
		return -E_NOT_SUPP;
  801228:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80122d:	eb d1                	jmp    801200 <read+0x58>

0080122f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	57                   	push   %edi
  801233:	56                   	push   %esi
  801234:	53                   	push   %ebx
  801235:	83 ec 0c             	sub    $0xc,%esp
  801238:	8b 7d 08             	mov    0x8(%ebp),%edi
  80123b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80123e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801243:	eb 02                	jmp    801247 <readn+0x18>
  801245:	01 c3                	add    %eax,%ebx
  801247:	39 f3                	cmp    %esi,%ebx
  801249:	73 21                	jae    80126c <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80124b:	83 ec 04             	sub    $0x4,%esp
  80124e:	89 f0                	mov    %esi,%eax
  801250:	29 d8                	sub    %ebx,%eax
  801252:	50                   	push   %eax
  801253:	89 d8                	mov    %ebx,%eax
  801255:	03 45 0c             	add    0xc(%ebp),%eax
  801258:	50                   	push   %eax
  801259:	57                   	push   %edi
  80125a:	e8 49 ff ff ff       	call   8011a8 <read>
		if (m < 0)
  80125f:	83 c4 10             	add    $0x10,%esp
  801262:	85 c0                	test   %eax,%eax
  801264:	78 04                	js     80126a <readn+0x3b>
			return m;
		if (m == 0)
  801266:	75 dd                	jne    801245 <readn+0x16>
  801268:	eb 02                	jmp    80126c <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80126a:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80126c:	89 d8                	mov    %ebx,%eax
  80126e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801271:	5b                   	pop    %ebx
  801272:	5e                   	pop    %esi
  801273:	5f                   	pop    %edi
  801274:	5d                   	pop    %ebp
  801275:	c3                   	ret    

00801276 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801276:	55                   	push   %ebp
  801277:	89 e5                	mov    %esp,%ebp
  801279:	56                   	push   %esi
  80127a:	53                   	push   %ebx
  80127b:	83 ec 18             	sub    $0x18,%esp
  80127e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801281:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801284:	50                   	push   %eax
  801285:	53                   	push   %ebx
  801286:	e8 b9 fc ff ff       	call   800f44 <fd_lookup>
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	85 c0                	test   %eax,%eax
  801290:	78 37                	js     8012c9 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801292:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801295:	83 ec 08             	sub    $0x8,%esp
  801298:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129b:	50                   	push   %eax
  80129c:	ff 36                	push   (%esi)
  80129e:	e8 f1 fc ff ff       	call   800f94 <dev_lookup>
  8012a3:	83 c4 10             	add    $0x10,%esp
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	78 1f                	js     8012c9 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012aa:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8012ae:	74 20                	je     8012d0 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b3:	8b 40 0c             	mov    0xc(%eax),%eax
  8012b6:	85 c0                	test   %eax,%eax
  8012b8:	74 37                	je     8012f1 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012ba:	83 ec 04             	sub    $0x4,%esp
  8012bd:	ff 75 10             	push   0x10(%ebp)
  8012c0:	ff 75 0c             	push   0xc(%ebp)
  8012c3:	56                   	push   %esi
  8012c4:	ff d0                	call   *%eax
  8012c6:	83 c4 10             	add    $0x10,%esp
}
  8012c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012cc:	5b                   	pop    %ebx
  8012cd:	5e                   	pop    %esi
  8012ce:	5d                   	pop    %ebp
  8012cf:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012d0:	a1 00 40 80 00       	mov    0x804000,%eax
  8012d5:	8b 40 48             	mov    0x48(%eax),%eax
  8012d8:	83 ec 04             	sub    $0x4,%esp
  8012db:	53                   	push   %ebx
  8012dc:	50                   	push   %eax
  8012dd:	68 29 23 80 00       	push   $0x802329
  8012e2:	e8 1f f0 ff ff       	call   800306 <cprintf>
		return -E_INVAL;
  8012e7:	83 c4 10             	add    $0x10,%esp
  8012ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012ef:	eb d8                	jmp    8012c9 <write+0x53>
		return -E_NOT_SUPP;
  8012f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012f6:	eb d1                	jmp    8012c9 <write+0x53>

008012f8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801301:	50                   	push   %eax
  801302:	ff 75 08             	push   0x8(%ebp)
  801305:	e8 3a fc ff ff       	call   800f44 <fd_lookup>
  80130a:	83 c4 10             	add    $0x10,%esp
  80130d:	85 c0                	test   %eax,%eax
  80130f:	78 0e                	js     80131f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801311:	8b 55 0c             	mov    0xc(%ebp),%edx
  801314:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801317:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80131a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80131f:	c9                   	leave  
  801320:	c3                   	ret    

00801321 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801321:	55                   	push   %ebp
  801322:	89 e5                	mov    %esp,%ebp
  801324:	56                   	push   %esi
  801325:	53                   	push   %ebx
  801326:	83 ec 18             	sub    $0x18,%esp
  801329:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80132f:	50                   	push   %eax
  801330:	53                   	push   %ebx
  801331:	e8 0e fc ff ff       	call   800f44 <fd_lookup>
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	85 c0                	test   %eax,%eax
  80133b:	78 34                	js     801371 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80133d:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801340:	83 ec 08             	sub    $0x8,%esp
  801343:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801346:	50                   	push   %eax
  801347:	ff 36                	push   (%esi)
  801349:	e8 46 fc ff ff       	call   800f94 <dev_lookup>
  80134e:	83 c4 10             	add    $0x10,%esp
  801351:	85 c0                	test   %eax,%eax
  801353:	78 1c                	js     801371 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801355:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801359:	74 1d                	je     801378 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80135b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135e:	8b 40 18             	mov    0x18(%eax),%eax
  801361:	85 c0                	test   %eax,%eax
  801363:	74 34                	je     801399 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801365:	83 ec 08             	sub    $0x8,%esp
  801368:	ff 75 0c             	push   0xc(%ebp)
  80136b:	56                   	push   %esi
  80136c:	ff d0                	call   *%eax
  80136e:	83 c4 10             	add    $0x10,%esp
}
  801371:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801374:	5b                   	pop    %ebx
  801375:	5e                   	pop    %esi
  801376:	5d                   	pop    %ebp
  801377:	c3                   	ret    
			thisenv->env_id, fdnum);
  801378:	a1 00 40 80 00       	mov    0x804000,%eax
  80137d:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801380:	83 ec 04             	sub    $0x4,%esp
  801383:	53                   	push   %ebx
  801384:	50                   	push   %eax
  801385:	68 ec 22 80 00       	push   $0x8022ec
  80138a:	e8 77 ef ff ff       	call   800306 <cprintf>
		return -E_INVAL;
  80138f:	83 c4 10             	add    $0x10,%esp
  801392:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801397:	eb d8                	jmp    801371 <ftruncate+0x50>
		return -E_NOT_SUPP;
  801399:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80139e:	eb d1                	jmp    801371 <ftruncate+0x50>

008013a0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8013a0:	55                   	push   %ebp
  8013a1:	89 e5                	mov    %esp,%ebp
  8013a3:	56                   	push   %esi
  8013a4:	53                   	push   %ebx
  8013a5:	83 ec 18             	sub    $0x18,%esp
  8013a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ae:	50                   	push   %eax
  8013af:	ff 75 08             	push   0x8(%ebp)
  8013b2:	e8 8d fb ff ff       	call   800f44 <fd_lookup>
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	78 49                	js     801407 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013be:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8013c1:	83 ec 08             	sub    $0x8,%esp
  8013c4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c7:	50                   	push   %eax
  8013c8:	ff 36                	push   (%esi)
  8013ca:	e8 c5 fb ff ff       	call   800f94 <dev_lookup>
  8013cf:	83 c4 10             	add    $0x10,%esp
  8013d2:	85 c0                	test   %eax,%eax
  8013d4:	78 31                	js     801407 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8013d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013d9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8013dd:	74 2f                	je     80140e <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013df:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013e2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013e9:	00 00 00 
	stat->st_isdir = 0;
  8013ec:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013f3:	00 00 00 
	stat->st_dev = dev;
  8013f6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013fc:	83 ec 08             	sub    $0x8,%esp
  8013ff:	53                   	push   %ebx
  801400:	56                   	push   %esi
  801401:	ff 50 14             	call   *0x14(%eax)
  801404:	83 c4 10             	add    $0x10,%esp
}
  801407:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80140a:	5b                   	pop    %ebx
  80140b:	5e                   	pop    %esi
  80140c:	5d                   	pop    %ebp
  80140d:	c3                   	ret    
		return -E_NOT_SUPP;
  80140e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801413:	eb f2                	jmp    801407 <fstat+0x67>

00801415 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801415:	55                   	push   %ebp
  801416:	89 e5                	mov    %esp,%ebp
  801418:	56                   	push   %esi
  801419:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80141a:	83 ec 08             	sub    $0x8,%esp
  80141d:	6a 00                	push   $0x0
  80141f:	ff 75 08             	push   0x8(%ebp)
  801422:	e8 e4 01 00 00       	call   80160b <open>
  801427:	89 c3                	mov    %eax,%ebx
  801429:	83 c4 10             	add    $0x10,%esp
  80142c:	85 c0                	test   %eax,%eax
  80142e:	78 1b                	js     80144b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801430:	83 ec 08             	sub    $0x8,%esp
  801433:	ff 75 0c             	push   0xc(%ebp)
  801436:	50                   	push   %eax
  801437:	e8 64 ff ff ff       	call   8013a0 <fstat>
  80143c:	89 c6                	mov    %eax,%esi
	close(fd);
  80143e:	89 1c 24             	mov    %ebx,(%esp)
  801441:	e8 26 fc ff ff       	call   80106c <close>
	return r;
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	89 f3                	mov    %esi,%ebx
}
  80144b:	89 d8                	mov    %ebx,%eax
  80144d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801450:	5b                   	pop    %ebx
  801451:	5e                   	pop    %esi
  801452:	5d                   	pop    %ebp
  801453:	c3                   	ret    

00801454 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	56                   	push   %esi
  801458:	53                   	push   %ebx
  801459:	89 c6                	mov    %eax,%esi
  80145b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80145d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801464:	74 27                	je     80148d <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801466:	6a 07                	push   $0x7
  801468:	68 00 50 80 00       	push   $0x805000
  80146d:	56                   	push   %esi
  80146e:	ff 35 00 60 80 00    	push   0x806000
  801474:	e8 5c 07 00 00       	call   801bd5 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801479:	83 c4 0c             	add    $0xc,%esp
  80147c:	6a 00                	push   $0x0
  80147e:	53                   	push   %ebx
  80147f:	6a 00                	push   $0x0
  801481:	e8 e8 06 00 00       	call   801b6e <ipc_recv>
}
  801486:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801489:	5b                   	pop    %ebx
  80148a:	5e                   	pop    %esi
  80148b:	5d                   	pop    %ebp
  80148c:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80148d:	83 ec 0c             	sub    $0xc,%esp
  801490:	6a 01                	push   $0x1
  801492:	e8 92 07 00 00       	call   801c29 <ipc_find_env>
  801497:	a3 00 60 80 00       	mov    %eax,0x806000
  80149c:	83 c4 10             	add    $0x10,%esp
  80149f:	eb c5                	jmp    801466 <fsipc+0x12>

008014a1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8014a1:	55                   	push   %ebp
  8014a2:	89 e5                	mov    %esp,%ebp
  8014a4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8014a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ad:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8014b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8014ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8014bf:	b8 02 00 00 00       	mov    $0x2,%eax
  8014c4:	e8 8b ff ff ff       	call   801454 <fsipc>
}
  8014c9:	c9                   	leave  
  8014ca:	c3                   	ret    

008014cb <devfile_flush>:
{
  8014cb:	55                   	push   %ebp
  8014cc:	89 e5                	mov    %esp,%ebp
  8014ce:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8014d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014d7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8014dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e1:	b8 06 00 00 00       	mov    $0x6,%eax
  8014e6:	e8 69 ff ff ff       	call   801454 <fsipc>
}
  8014eb:	c9                   	leave  
  8014ec:	c3                   	ret    

008014ed <devfile_stat>:
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	53                   	push   %ebx
  8014f1:	83 ec 04             	sub    $0x4,%esp
  8014f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8014f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8014fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8014fd:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801502:	ba 00 00 00 00       	mov    $0x0,%edx
  801507:	b8 05 00 00 00       	mov    $0x5,%eax
  80150c:	e8 43 ff ff ff       	call   801454 <fsipc>
  801511:	85 c0                	test   %eax,%eax
  801513:	78 2c                	js     801541 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801515:	83 ec 08             	sub    $0x8,%esp
  801518:	68 00 50 80 00       	push   $0x805000
  80151d:	53                   	push   %ebx
  80151e:	e8 bd f3 ff ff       	call   8008e0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801523:	a1 80 50 80 00       	mov    0x805080,%eax
  801528:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80152e:	a1 84 50 80 00       	mov    0x805084,%eax
  801533:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801539:	83 c4 10             	add    $0x10,%esp
  80153c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801541:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801544:	c9                   	leave  
  801545:	c3                   	ret    

00801546 <devfile_write>:
{
  801546:	55                   	push   %ebp
  801547:	89 e5                	mov    %esp,%ebp
  801549:	83 ec 0c             	sub    $0xc,%esp
  80154c:	8b 45 10             	mov    0x10(%ebp),%eax
  80154f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801554:	39 d0                	cmp    %edx,%eax
  801556:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801559:	8b 55 08             	mov    0x8(%ebp),%edx
  80155c:	8b 52 0c             	mov    0xc(%edx),%edx
  80155f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801565:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80156a:	50                   	push   %eax
  80156b:	ff 75 0c             	push   0xc(%ebp)
  80156e:	68 08 50 80 00       	push   $0x805008
  801573:	e8 fe f4 ff ff       	call   800a76 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  801578:	ba 00 00 00 00       	mov    $0x0,%edx
  80157d:	b8 04 00 00 00       	mov    $0x4,%eax
  801582:	e8 cd fe ff ff       	call   801454 <fsipc>
}
  801587:	c9                   	leave  
  801588:	c3                   	ret    

00801589 <devfile_read>:
{
  801589:	55                   	push   %ebp
  80158a:	89 e5                	mov    %esp,%ebp
  80158c:	56                   	push   %esi
  80158d:	53                   	push   %ebx
  80158e:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801591:	8b 45 08             	mov    0x8(%ebp),%eax
  801594:	8b 40 0c             	mov    0xc(%eax),%eax
  801597:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80159c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8015a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a7:	b8 03 00 00 00       	mov    $0x3,%eax
  8015ac:	e8 a3 fe ff ff       	call   801454 <fsipc>
  8015b1:	89 c3                	mov    %eax,%ebx
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	78 1f                	js     8015d6 <devfile_read+0x4d>
	assert(r <= n);
  8015b7:	39 f0                	cmp    %esi,%eax
  8015b9:	77 24                	ja     8015df <devfile_read+0x56>
	assert(r <= PGSIZE);
  8015bb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8015c0:	7f 33                	jg     8015f5 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8015c2:	83 ec 04             	sub    $0x4,%esp
  8015c5:	50                   	push   %eax
  8015c6:	68 00 50 80 00       	push   $0x805000
  8015cb:	ff 75 0c             	push   0xc(%ebp)
  8015ce:	e8 a3 f4 ff ff       	call   800a76 <memmove>
	return r;
  8015d3:	83 c4 10             	add    $0x10,%esp
}
  8015d6:	89 d8                	mov    %ebx,%eax
  8015d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015db:	5b                   	pop    %ebx
  8015dc:	5e                   	pop    %esi
  8015dd:	5d                   	pop    %ebp
  8015de:	c3                   	ret    
	assert(r <= n);
  8015df:	68 58 23 80 00       	push   $0x802358
  8015e4:	68 5f 23 80 00       	push   $0x80235f
  8015e9:	6a 7c                	push   $0x7c
  8015eb:	68 74 23 80 00       	push   $0x802374
  8015f0:	e8 36 ec ff ff       	call   80022b <_panic>
	assert(r <= PGSIZE);
  8015f5:	68 7f 23 80 00       	push   $0x80237f
  8015fa:	68 5f 23 80 00       	push   $0x80235f
  8015ff:	6a 7d                	push   $0x7d
  801601:	68 74 23 80 00       	push   $0x802374
  801606:	e8 20 ec ff ff       	call   80022b <_panic>

0080160b <open>:
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	56                   	push   %esi
  80160f:	53                   	push   %ebx
  801610:	83 ec 1c             	sub    $0x1c,%esp
  801613:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801616:	56                   	push   %esi
  801617:	e8 89 f2 ff ff       	call   8008a5 <strlen>
  80161c:	83 c4 10             	add    $0x10,%esp
  80161f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801624:	7f 6c                	jg     801692 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  801626:	83 ec 0c             	sub    $0xc,%esp
  801629:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80162c:	50                   	push   %eax
  80162d:	e8 c2 f8 ff ff       	call   800ef4 <fd_alloc>
  801632:	89 c3                	mov    %eax,%ebx
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	85 c0                	test   %eax,%eax
  801639:	78 3c                	js     801677 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  80163b:	83 ec 08             	sub    $0x8,%esp
  80163e:	56                   	push   %esi
  80163f:	68 00 50 80 00       	push   $0x805000
  801644:	e8 97 f2 ff ff       	call   8008e0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801649:	8b 45 0c             	mov    0xc(%ebp),%eax
  80164c:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801651:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801654:	b8 01 00 00 00       	mov    $0x1,%eax
  801659:	e8 f6 fd ff ff       	call   801454 <fsipc>
  80165e:	89 c3                	mov    %eax,%ebx
  801660:	83 c4 10             	add    $0x10,%esp
  801663:	85 c0                	test   %eax,%eax
  801665:	78 19                	js     801680 <open+0x75>
	return fd2num(fd);
  801667:	83 ec 0c             	sub    $0xc,%esp
  80166a:	ff 75 f4             	push   -0xc(%ebp)
  80166d:	e8 5b f8 ff ff       	call   800ecd <fd2num>
  801672:	89 c3                	mov    %eax,%ebx
  801674:	83 c4 10             	add    $0x10,%esp
}
  801677:	89 d8                	mov    %ebx,%eax
  801679:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80167c:	5b                   	pop    %ebx
  80167d:	5e                   	pop    %esi
  80167e:	5d                   	pop    %ebp
  80167f:	c3                   	ret    
		fd_close(fd, 0);
  801680:	83 ec 08             	sub    $0x8,%esp
  801683:	6a 00                	push   $0x0
  801685:	ff 75 f4             	push   -0xc(%ebp)
  801688:	e8 58 f9 ff ff       	call   800fe5 <fd_close>
		return r;
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	eb e5                	jmp    801677 <open+0x6c>
		return -E_BAD_PATH;
  801692:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801697:	eb de                	jmp    801677 <open+0x6c>

00801699 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80169f:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a4:	b8 08 00 00 00       	mov    $0x8,%eax
  8016a9:	e8 a6 fd ff ff       	call   801454 <fsipc>
}
  8016ae:	c9                   	leave  
  8016af:	c3                   	ret    

008016b0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	56                   	push   %esi
  8016b4:	53                   	push   %ebx
  8016b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8016b8:	83 ec 0c             	sub    $0xc,%esp
  8016bb:	ff 75 08             	push   0x8(%ebp)
  8016be:	e8 1a f8 ff ff       	call   800edd <fd2data>
  8016c3:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8016c5:	83 c4 08             	add    $0x8,%esp
  8016c8:	68 8b 23 80 00       	push   $0x80238b
  8016cd:	53                   	push   %ebx
  8016ce:	e8 0d f2 ff ff       	call   8008e0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8016d3:	8b 46 04             	mov    0x4(%esi),%eax
  8016d6:	2b 06                	sub    (%esi),%eax
  8016d8:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  8016de:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016e5:	00 00 00 
	stat->st_dev = &devpipe;
  8016e8:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8016ef:	30 80 00 
	return 0;
}
  8016f2:	b8 00 00 00 00       	mov    $0x0,%eax
  8016f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016fa:	5b                   	pop    %ebx
  8016fb:	5e                   	pop    %esi
  8016fc:	5d                   	pop    %ebp
  8016fd:	c3                   	ret    

008016fe <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8016fe:	55                   	push   %ebp
  8016ff:	89 e5                	mov    %esp,%ebp
  801701:	53                   	push   %ebx
  801702:	83 ec 0c             	sub    $0xc,%esp
  801705:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801708:	53                   	push   %ebx
  801709:	6a 00                	push   $0x0
  80170b:	e8 51 f6 ff ff       	call   800d61 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801710:	89 1c 24             	mov    %ebx,(%esp)
  801713:	e8 c5 f7 ff ff       	call   800edd <fd2data>
  801718:	83 c4 08             	add    $0x8,%esp
  80171b:	50                   	push   %eax
  80171c:	6a 00                	push   $0x0
  80171e:	e8 3e f6 ff ff       	call   800d61 <sys_page_unmap>
}
  801723:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801726:	c9                   	leave  
  801727:	c3                   	ret    

00801728 <_pipeisclosed>:
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	57                   	push   %edi
  80172c:	56                   	push   %esi
  80172d:	53                   	push   %ebx
  80172e:	83 ec 1c             	sub    $0x1c,%esp
  801731:	89 c7                	mov    %eax,%edi
  801733:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801735:	a1 00 40 80 00       	mov    0x804000,%eax
  80173a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  80173d:	83 ec 0c             	sub    $0xc,%esp
  801740:	57                   	push   %edi
  801741:	e8 1c 05 00 00       	call   801c62 <pageref>
  801746:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801749:	89 34 24             	mov    %esi,(%esp)
  80174c:	e8 11 05 00 00       	call   801c62 <pageref>
		nn = thisenv->env_runs;
  801751:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801757:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	39 cb                	cmp    %ecx,%ebx
  80175f:	74 1b                	je     80177c <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801761:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801764:	75 cf                	jne    801735 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801766:	8b 42 58             	mov    0x58(%edx),%eax
  801769:	6a 01                	push   $0x1
  80176b:	50                   	push   %eax
  80176c:	53                   	push   %ebx
  80176d:	68 92 23 80 00       	push   $0x802392
  801772:	e8 8f eb ff ff       	call   800306 <cprintf>
  801777:	83 c4 10             	add    $0x10,%esp
  80177a:	eb b9                	jmp    801735 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  80177c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80177f:	0f 94 c0             	sete   %al
  801782:	0f b6 c0             	movzbl %al,%eax
}
  801785:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801788:	5b                   	pop    %ebx
  801789:	5e                   	pop    %esi
  80178a:	5f                   	pop    %edi
  80178b:	5d                   	pop    %ebp
  80178c:	c3                   	ret    

0080178d <devpipe_write>:
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	57                   	push   %edi
  801791:	56                   	push   %esi
  801792:	53                   	push   %ebx
  801793:	83 ec 28             	sub    $0x28,%esp
  801796:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801799:	56                   	push   %esi
  80179a:	e8 3e f7 ff ff       	call   800edd <fd2data>
  80179f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8017a1:	83 c4 10             	add    $0x10,%esp
  8017a4:	bf 00 00 00 00       	mov    $0x0,%edi
  8017a9:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8017ac:	75 09                	jne    8017b7 <devpipe_write+0x2a>
	return i;
  8017ae:	89 f8                	mov    %edi,%eax
  8017b0:	eb 23                	jmp    8017d5 <devpipe_write+0x48>
			sys_yield();
  8017b2:	e8 06 f5 ff ff       	call   800cbd <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8017b7:	8b 43 04             	mov    0x4(%ebx),%eax
  8017ba:	8b 0b                	mov    (%ebx),%ecx
  8017bc:	8d 51 20             	lea    0x20(%ecx),%edx
  8017bf:	39 d0                	cmp    %edx,%eax
  8017c1:	72 1a                	jb     8017dd <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  8017c3:	89 da                	mov    %ebx,%edx
  8017c5:	89 f0                	mov    %esi,%eax
  8017c7:	e8 5c ff ff ff       	call   801728 <_pipeisclosed>
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	74 e2                	je     8017b2 <devpipe_write+0x25>
				return 0;
  8017d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017d8:	5b                   	pop    %ebx
  8017d9:	5e                   	pop    %esi
  8017da:	5f                   	pop    %edi
  8017db:	5d                   	pop    %ebp
  8017dc:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8017dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017e0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  8017e4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  8017e7:	89 c2                	mov    %eax,%edx
  8017e9:	c1 fa 1f             	sar    $0x1f,%edx
  8017ec:	89 d1                	mov    %edx,%ecx
  8017ee:	c1 e9 1b             	shr    $0x1b,%ecx
  8017f1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  8017f4:	83 e2 1f             	and    $0x1f,%edx
  8017f7:	29 ca                	sub    %ecx,%edx
  8017f9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8017fd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801801:	83 c0 01             	add    $0x1,%eax
  801804:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801807:	83 c7 01             	add    $0x1,%edi
  80180a:	eb 9d                	jmp    8017a9 <devpipe_write+0x1c>

0080180c <devpipe_read>:
{
  80180c:	55                   	push   %ebp
  80180d:	89 e5                	mov    %esp,%ebp
  80180f:	57                   	push   %edi
  801810:	56                   	push   %esi
  801811:	53                   	push   %ebx
  801812:	83 ec 18             	sub    $0x18,%esp
  801815:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801818:	57                   	push   %edi
  801819:	e8 bf f6 ff ff       	call   800edd <fd2data>
  80181e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801820:	83 c4 10             	add    $0x10,%esp
  801823:	be 00 00 00 00       	mov    $0x0,%esi
  801828:	3b 75 10             	cmp    0x10(%ebp),%esi
  80182b:	75 13                	jne    801840 <devpipe_read+0x34>
	return i;
  80182d:	89 f0                	mov    %esi,%eax
  80182f:	eb 02                	jmp    801833 <devpipe_read+0x27>
				return i;
  801831:	89 f0                	mov    %esi,%eax
}
  801833:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801836:	5b                   	pop    %ebx
  801837:	5e                   	pop    %esi
  801838:	5f                   	pop    %edi
  801839:	5d                   	pop    %ebp
  80183a:	c3                   	ret    
			sys_yield();
  80183b:	e8 7d f4 ff ff       	call   800cbd <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801840:	8b 03                	mov    (%ebx),%eax
  801842:	3b 43 04             	cmp    0x4(%ebx),%eax
  801845:	75 18                	jne    80185f <devpipe_read+0x53>
			if (i > 0)
  801847:	85 f6                	test   %esi,%esi
  801849:	75 e6                	jne    801831 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  80184b:	89 da                	mov    %ebx,%edx
  80184d:	89 f8                	mov    %edi,%eax
  80184f:	e8 d4 fe ff ff       	call   801728 <_pipeisclosed>
  801854:	85 c0                	test   %eax,%eax
  801856:	74 e3                	je     80183b <devpipe_read+0x2f>
				return 0;
  801858:	b8 00 00 00 00       	mov    $0x0,%eax
  80185d:	eb d4                	jmp    801833 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80185f:	99                   	cltd   
  801860:	c1 ea 1b             	shr    $0x1b,%edx
  801863:	01 d0                	add    %edx,%eax
  801865:	83 e0 1f             	and    $0x1f,%eax
  801868:	29 d0                	sub    %edx,%eax
  80186a:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80186f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801872:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801875:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801878:	83 c6 01             	add    $0x1,%esi
  80187b:	eb ab                	jmp    801828 <devpipe_read+0x1c>

0080187d <pipe>:
{
  80187d:	55                   	push   %ebp
  80187e:	89 e5                	mov    %esp,%ebp
  801880:	56                   	push   %esi
  801881:	53                   	push   %ebx
  801882:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801885:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801888:	50                   	push   %eax
  801889:	e8 66 f6 ff ff       	call   800ef4 <fd_alloc>
  80188e:	89 c3                	mov    %eax,%ebx
  801890:	83 c4 10             	add    $0x10,%esp
  801893:	85 c0                	test   %eax,%eax
  801895:	0f 88 23 01 00 00    	js     8019be <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80189b:	83 ec 04             	sub    $0x4,%esp
  80189e:	68 07 04 00 00       	push   $0x407
  8018a3:	ff 75 f4             	push   -0xc(%ebp)
  8018a6:	6a 00                	push   $0x0
  8018a8:	e8 2f f4 ff ff       	call   800cdc <sys_page_alloc>
  8018ad:	89 c3                	mov    %eax,%ebx
  8018af:	83 c4 10             	add    $0x10,%esp
  8018b2:	85 c0                	test   %eax,%eax
  8018b4:	0f 88 04 01 00 00    	js     8019be <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  8018ba:	83 ec 0c             	sub    $0xc,%esp
  8018bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c0:	50                   	push   %eax
  8018c1:	e8 2e f6 ff ff       	call   800ef4 <fd_alloc>
  8018c6:	89 c3                	mov    %eax,%ebx
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	0f 88 db 00 00 00    	js     8019ae <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018d3:	83 ec 04             	sub    $0x4,%esp
  8018d6:	68 07 04 00 00       	push   $0x407
  8018db:	ff 75 f0             	push   -0x10(%ebp)
  8018de:	6a 00                	push   $0x0
  8018e0:	e8 f7 f3 ff ff       	call   800cdc <sys_page_alloc>
  8018e5:	89 c3                	mov    %eax,%ebx
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	85 c0                	test   %eax,%eax
  8018ec:	0f 88 bc 00 00 00    	js     8019ae <pipe+0x131>
	va = fd2data(fd0);
  8018f2:	83 ec 0c             	sub    $0xc,%esp
  8018f5:	ff 75 f4             	push   -0xc(%ebp)
  8018f8:	e8 e0 f5 ff ff       	call   800edd <fd2data>
  8018fd:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018ff:	83 c4 0c             	add    $0xc,%esp
  801902:	68 07 04 00 00       	push   $0x407
  801907:	50                   	push   %eax
  801908:	6a 00                	push   $0x0
  80190a:	e8 cd f3 ff ff       	call   800cdc <sys_page_alloc>
  80190f:	89 c3                	mov    %eax,%ebx
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	85 c0                	test   %eax,%eax
  801916:	0f 88 82 00 00 00    	js     80199e <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80191c:	83 ec 0c             	sub    $0xc,%esp
  80191f:	ff 75 f0             	push   -0x10(%ebp)
  801922:	e8 b6 f5 ff ff       	call   800edd <fd2data>
  801927:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80192e:	50                   	push   %eax
  80192f:	6a 00                	push   $0x0
  801931:	56                   	push   %esi
  801932:	6a 00                	push   $0x0
  801934:	e8 e6 f3 ff ff       	call   800d1f <sys_page_map>
  801939:	89 c3                	mov    %eax,%ebx
  80193b:	83 c4 20             	add    $0x20,%esp
  80193e:	85 c0                	test   %eax,%eax
  801940:	78 4e                	js     801990 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801942:	a1 20 30 80 00       	mov    0x803020,%eax
  801947:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80194a:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80194c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80194f:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801956:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801959:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80195b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801965:	83 ec 0c             	sub    $0xc,%esp
  801968:	ff 75 f4             	push   -0xc(%ebp)
  80196b:	e8 5d f5 ff ff       	call   800ecd <fd2num>
  801970:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801973:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801975:	83 c4 04             	add    $0x4,%esp
  801978:	ff 75 f0             	push   -0x10(%ebp)
  80197b:	e8 4d f5 ff ff       	call   800ecd <fd2num>
  801980:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801983:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801986:	83 c4 10             	add    $0x10,%esp
  801989:	bb 00 00 00 00       	mov    $0x0,%ebx
  80198e:	eb 2e                	jmp    8019be <pipe+0x141>
	sys_page_unmap(0, va);
  801990:	83 ec 08             	sub    $0x8,%esp
  801993:	56                   	push   %esi
  801994:	6a 00                	push   $0x0
  801996:	e8 c6 f3 ff ff       	call   800d61 <sys_page_unmap>
  80199b:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80199e:	83 ec 08             	sub    $0x8,%esp
  8019a1:	ff 75 f0             	push   -0x10(%ebp)
  8019a4:	6a 00                	push   $0x0
  8019a6:	e8 b6 f3 ff ff       	call   800d61 <sys_page_unmap>
  8019ab:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8019ae:	83 ec 08             	sub    $0x8,%esp
  8019b1:	ff 75 f4             	push   -0xc(%ebp)
  8019b4:	6a 00                	push   $0x0
  8019b6:	e8 a6 f3 ff ff       	call   800d61 <sys_page_unmap>
  8019bb:	83 c4 10             	add    $0x10,%esp
}
  8019be:	89 d8                	mov    %ebx,%eax
  8019c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019c3:	5b                   	pop    %ebx
  8019c4:	5e                   	pop    %esi
  8019c5:	5d                   	pop    %ebp
  8019c6:	c3                   	ret    

008019c7 <pipeisclosed>:
{
  8019c7:	55                   	push   %ebp
  8019c8:	89 e5                	mov    %esp,%ebp
  8019ca:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019d0:	50                   	push   %eax
  8019d1:	ff 75 08             	push   0x8(%ebp)
  8019d4:	e8 6b f5 ff ff       	call   800f44 <fd_lookup>
  8019d9:	83 c4 10             	add    $0x10,%esp
  8019dc:	85 c0                	test   %eax,%eax
  8019de:	78 18                	js     8019f8 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  8019e0:	83 ec 0c             	sub    $0xc,%esp
  8019e3:	ff 75 f4             	push   -0xc(%ebp)
  8019e6:	e8 f2 f4 ff ff       	call   800edd <fd2data>
  8019eb:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8019ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f0:	e8 33 fd ff ff       	call   801728 <_pipeisclosed>
  8019f5:	83 c4 10             	add    $0x10,%esp
}
  8019f8:	c9                   	leave  
  8019f9:	c3                   	ret    

008019fa <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  8019fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8019ff:	c3                   	ret    

00801a00 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801a06:	68 aa 23 80 00       	push   $0x8023aa
  801a0b:	ff 75 0c             	push   0xc(%ebp)
  801a0e:	e8 cd ee ff ff       	call   8008e0 <strcpy>
	return 0;
}
  801a13:	b8 00 00 00 00       	mov    $0x0,%eax
  801a18:	c9                   	leave  
  801a19:	c3                   	ret    

00801a1a <devcons_write>:
{
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	57                   	push   %edi
  801a1e:	56                   	push   %esi
  801a1f:	53                   	push   %ebx
  801a20:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801a26:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801a2b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801a31:	eb 2e                	jmp    801a61 <devcons_write+0x47>
		m = n - tot;
  801a33:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a36:	29 f3                	sub    %esi,%ebx
  801a38:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801a3d:	39 c3                	cmp    %eax,%ebx
  801a3f:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801a42:	83 ec 04             	sub    $0x4,%esp
  801a45:	53                   	push   %ebx
  801a46:	89 f0                	mov    %esi,%eax
  801a48:	03 45 0c             	add    0xc(%ebp),%eax
  801a4b:	50                   	push   %eax
  801a4c:	57                   	push   %edi
  801a4d:	e8 24 f0 ff ff       	call   800a76 <memmove>
		sys_cputs(buf, m);
  801a52:	83 c4 08             	add    $0x8,%esp
  801a55:	53                   	push   %ebx
  801a56:	57                   	push   %edi
  801a57:	e8 c4 f1 ff ff       	call   800c20 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801a5c:	01 de                	add    %ebx,%esi
  801a5e:	83 c4 10             	add    $0x10,%esp
  801a61:	3b 75 10             	cmp    0x10(%ebp),%esi
  801a64:	72 cd                	jb     801a33 <devcons_write+0x19>
}
  801a66:	89 f0                	mov    %esi,%eax
  801a68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a6b:	5b                   	pop    %ebx
  801a6c:	5e                   	pop    %esi
  801a6d:	5f                   	pop    %edi
  801a6e:	5d                   	pop    %ebp
  801a6f:	c3                   	ret    

00801a70 <devcons_read>:
{
  801a70:	55                   	push   %ebp
  801a71:	89 e5                	mov    %esp,%ebp
  801a73:	83 ec 08             	sub    $0x8,%esp
  801a76:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801a7b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a7f:	75 07                	jne    801a88 <devcons_read+0x18>
  801a81:	eb 1f                	jmp    801aa2 <devcons_read+0x32>
		sys_yield();
  801a83:	e8 35 f2 ff ff       	call   800cbd <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801a88:	e8 b1 f1 ff ff       	call   800c3e <sys_cgetc>
  801a8d:	85 c0                	test   %eax,%eax
  801a8f:	74 f2                	je     801a83 <devcons_read+0x13>
	if (c < 0)
  801a91:	78 0f                	js     801aa2 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801a93:	83 f8 04             	cmp    $0x4,%eax
  801a96:	74 0c                	je     801aa4 <devcons_read+0x34>
	*(char*)vbuf = c;
  801a98:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a9b:	88 02                	mov    %al,(%edx)
	return 1;
  801a9d:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801aa2:	c9                   	leave  
  801aa3:	c3                   	ret    
		return 0;
  801aa4:	b8 00 00 00 00       	mov    $0x0,%eax
  801aa9:	eb f7                	jmp    801aa2 <devcons_read+0x32>

00801aab <cputchar>:
{
  801aab:	55                   	push   %ebp
  801aac:	89 e5                	mov    %esp,%ebp
  801aae:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab4:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801ab7:	6a 01                	push   $0x1
  801ab9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801abc:	50                   	push   %eax
  801abd:	e8 5e f1 ff ff       	call   800c20 <sys_cputs>
}
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	c9                   	leave  
  801ac6:	c3                   	ret    

00801ac7 <getchar>:
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801acd:	6a 01                	push   $0x1
  801acf:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ad2:	50                   	push   %eax
  801ad3:	6a 00                	push   $0x0
  801ad5:	e8 ce f6 ff ff       	call   8011a8 <read>
	if (r < 0)
  801ada:	83 c4 10             	add    $0x10,%esp
  801add:	85 c0                	test   %eax,%eax
  801adf:	78 06                	js     801ae7 <getchar+0x20>
	if (r < 1)
  801ae1:	74 06                	je     801ae9 <getchar+0x22>
	return c;
  801ae3:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801ae7:	c9                   	leave  
  801ae8:	c3                   	ret    
		return -E_EOF;
  801ae9:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801aee:	eb f7                	jmp    801ae7 <getchar+0x20>

00801af0 <iscons>:
{
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801af6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801af9:	50                   	push   %eax
  801afa:	ff 75 08             	push   0x8(%ebp)
  801afd:	e8 42 f4 ff ff       	call   800f44 <fd_lookup>
  801b02:	83 c4 10             	add    $0x10,%esp
  801b05:	85 c0                	test   %eax,%eax
  801b07:	78 11                	js     801b1a <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801b09:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0c:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b12:	39 10                	cmp    %edx,(%eax)
  801b14:	0f 94 c0             	sete   %al
  801b17:	0f b6 c0             	movzbl %al,%eax
}
  801b1a:	c9                   	leave  
  801b1b:	c3                   	ret    

00801b1c <opencons>:
{
  801b1c:	55                   	push   %ebp
  801b1d:	89 e5                	mov    %esp,%ebp
  801b1f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801b22:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b25:	50                   	push   %eax
  801b26:	e8 c9 f3 ff ff       	call   800ef4 <fd_alloc>
  801b2b:	83 c4 10             	add    $0x10,%esp
  801b2e:	85 c0                	test   %eax,%eax
  801b30:	78 3a                	js     801b6c <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801b32:	83 ec 04             	sub    $0x4,%esp
  801b35:	68 07 04 00 00       	push   $0x407
  801b3a:	ff 75 f4             	push   -0xc(%ebp)
  801b3d:	6a 00                	push   $0x0
  801b3f:	e8 98 f1 ff ff       	call   800cdc <sys_page_alloc>
  801b44:	83 c4 10             	add    $0x10,%esp
  801b47:	85 c0                	test   %eax,%eax
  801b49:	78 21                	js     801b6c <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801b4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b54:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b59:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b60:	83 ec 0c             	sub    $0xc,%esp
  801b63:	50                   	push   %eax
  801b64:	e8 64 f3 ff ff       	call   800ecd <fd2num>
  801b69:	83 c4 10             	add    $0x10,%esp
}
  801b6c:	c9                   	leave  
  801b6d:	c3                   	ret    

00801b6e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	56                   	push   %esi
  801b72:	53                   	push   %ebx
  801b73:	8b 75 08             	mov    0x8(%ebp),%esi
  801b76:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b79:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801b7c:	85 c0                	test   %eax,%eax
  801b7e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b83:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801b86:	83 ec 0c             	sub    $0xc,%esp
  801b89:	50                   	push   %eax
  801b8a:	e8 fd f2 ff ff       	call   800e8c <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801b8f:	83 c4 10             	add    $0x10,%esp
  801b92:	85 f6                	test   %esi,%esi
  801b94:	74 14                	je     801baa <ipc_recv+0x3c>
  801b96:	ba 00 00 00 00       	mov    $0x0,%edx
  801b9b:	85 c0                	test   %eax,%eax
  801b9d:	78 09                	js     801ba8 <ipc_recv+0x3a>
  801b9f:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ba5:	8b 52 74             	mov    0x74(%edx),%edx
  801ba8:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801baa:	85 db                	test   %ebx,%ebx
  801bac:	74 14                	je     801bc2 <ipc_recv+0x54>
  801bae:	ba 00 00 00 00       	mov    $0x0,%edx
  801bb3:	85 c0                	test   %eax,%eax
  801bb5:	78 09                	js     801bc0 <ipc_recv+0x52>
  801bb7:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801bbd:	8b 52 78             	mov    0x78(%edx),%edx
  801bc0:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801bc2:	85 c0                	test   %eax,%eax
  801bc4:	78 08                	js     801bce <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801bc6:	a1 00 40 80 00       	mov    0x804000,%eax
  801bcb:	8b 40 70             	mov    0x70(%eax),%eax
}
  801bce:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bd1:	5b                   	pop    %ebx
  801bd2:	5e                   	pop    %esi
  801bd3:	5d                   	pop    %ebp
  801bd4:	c3                   	ret    

00801bd5 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801bd5:	55                   	push   %ebp
  801bd6:	89 e5                	mov    %esp,%ebp
  801bd8:	57                   	push   %edi
  801bd9:	56                   	push   %esi
  801bda:	53                   	push   %ebx
  801bdb:	83 ec 0c             	sub    $0xc,%esp
  801bde:	8b 7d 08             	mov    0x8(%ebp),%edi
  801be1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801be4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801be7:	85 db                	test   %ebx,%ebx
  801be9:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801bee:	0f 44 d8             	cmove  %eax,%ebx
  801bf1:	eb 05                	jmp    801bf8 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801bf3:	e8 c5 f0 ff ff       	call   800cbd <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801bf8:	ff 75 14             	push   0x14(%ebp)
  801bfb:	53                   	push   %ebx
  801bfc:	56                   	push   %esi
  801bfd:	57                   	push   %edi
  801bfe:	e8 66 f2 ff ff       	call   800e69 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801c03:	83 c4 10             	add    $0x10,%esp
  801c06:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801c09:	74 e8                	je     801bf3 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801c0b:	85 c0                	test   %eax,%eax
  801c0d:	78 08                	js     801c17 <ipc_send+0x42>
	}while (r<0);

}
  801c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c12:	5b                   	pop    %ebx
  801c13:	5e                   	pop    %esi
  801c14:	5f                   	pop    %edi
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801c17:	50                   	push   %eax
  801c18:	68 b6 23 80 00       	push   $0x8023b6
  801c1d:	6a 3d                	push   $0x3d
  801c1f:	68 ca 23 80 00       	push   $0x8023ca
  801c24:	e8 02 e6 ff ff       	call   80022b <_panic>

00801c29 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801c29:	55                   	push   %ebp
  801c2a:	89 e5                	mov    %esp,%ebp
  801c2c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801c2f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c34:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c37:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c3d:	8b 52 50             	mov    0x50(%edx),%edx
  801c40:	39 ca                	cmp    %ecx,%edx
  801c42:	74 11                	je     801c55 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801c44:	83 c0 01             	add    $0x1,%eax
  801c47:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c4c:	75 e6                	jne    801c34 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801c4e:	b8 00 00 00 00       	mov    $0x0,%eax
  801c53:	eb 0b                	jmp    801c60 <ipc_find_env+0x37>
			return envs[i].env_id;
  801c55:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c58:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c5d:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    

00801c62 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c68:	89 c2                	mov    %eax,%edx
  801c6a:	c1 ea 16             	shr    $0x16,%edx
  801c6d:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c74:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c79:	f6 c1 01             	test   $0x1,%cl
  801c7c:	74 1c                	je     801c9a <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801c7e:	c1 e8 0c             	shr    $0xc,%eax
  801c81:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c88:	a8 01                	test   $0x1,%al
  801c8a:	74 0e                	je     801c9a <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c8c:	c1 e8 0c             	shr    $0xc,%eax
  801c8f:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c96:	ef 
  801c97:	0f b7 d2             	movzwl %dx,%edx
}
  801c9a:	89 d0                	mov    %edx,%eax
  801c9c:	5d                   	pop    %ebp
  801c9d:	c3                   	ret    
  801c9e:	66 90                	xchg   %ax,%ax

00801ca0 <__udivdi3>:
  801ca0:	f3 0f 1e fb          	endbr32 
  801ca4:	55                   	push   %ebp
  801ca5:	57                   	push   %edi
  801ca6:	56                   	push   %esi
  801ca7:	53                   	push   %ebx
  801ca8:	83 ec 1c             	sub    $0x1c,%esp
  801cab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801caf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801cb3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cb7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	75 19                	jne    801cd8 <__udivdi3+0x38>
  801cbf:	39 f3                	cmp    %esi,%ebx
  801cc1:	76 4d                	jbe    801d10 <__udivdi3+0x70>
  801cc3:	31 ff                	xor    %edi,%edi
  801cc5:	89 e8                	mov    %ebp,%eax
  801cc7:	89 f2                	mov    %esi,%edx
  801cc9:	f7 f3                	div    %ebx
  801ccb:	89 fa                	mov    %edi,%edx
  801ccd:	83 c4 1c             	add    $0x1c,%esp
  801cd0:	5b                   	pop    %ebx
  801cd1:	5e                   	pop    %esi
  801cd2:	5f                   	pop    %edi
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    
  801cd5:	8d 76 00             	lea    0x0(%esi),%esi
  801cd8:	39 f0                	cmp    %esi,%eax
  801cda:	76 14                	jbe    801cf0 <__udivdi3+0x50>
  801cdc:	31 ff                	xor    %edi,%edi
  801cde:	31 c0                	xor    %eax,%eax
  801ce0:	89 fa                	mov    %edi,%edx
  801ce2:	83 c4 1c             	add    $0x1c,%esp
  801ce5:	5b                   	pop    %ebx
  801ce6:	5e                   	pop    %esi
  801ce7:	5f                   	pop    %edi
  801ce8:	5d                   	pop    %ebp
  801ce9:	c3                   	ret    
  801cea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cf0:	0f bd f8             	bsr    %eax,%edi
  801cf3:	83 f7 1f             	xor    $0x1f,%edi
  801cf6:	75 48                	jne    801d40 <__udivdi3+0xa0>
  801cf8:	39 f0                	cmp    %esi,%eax
  801cfa:	72 06                	jb     801d02 <__udivdi3+0x62>
  801cfc:	31 c0                	xor    %eax,%eax
  801cfe:	39 eb                	cmp    %ebp,%ebx
  801d00:	77 de                	ja     801ce0 <__udivdi3+0x40>
  801d02:	b8 01 00 00 00       	mov    $0x1,%eax
  801d07:	eb d7                	jmp    801ce0 <__udivdi3+0x40>
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	89 d9                	mov    %ebx,%ecx
  801d12:	85 db                	test   %ebx,%ebx
  801d14:	75 0b                	jne    801d21 <__udivdi3+0x81>
  801d16:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1b:	31 d2                	xor    %edx,%edx
  801d1d:	f7 f3                	div    %ebx
  801d1f:	89 c1                	mov    %eax,%ecx
  801d21:	31 d2                	xor    %edx,%edx
  801d23:	89 f0                	mov    %esi,%eax
  801d25:	f7 f1                	div    %ecx
  801d27:	89 c6                	mov    %eax,%esi
  801d29:	89 e8                	mov    %ebp,%eax
  801d2b:	89 f7                	mov    %esi,%edi
  801d2d:	f7 f1                	div    %ecx
  801d2f:	89 fa                	mov    %edi,%edx
  801d31:	83 c4 1c             	add    $0x1c,%esp
  801d34:	5b                   	pop    %ebx
  801d35:	5e                   	pop    %esi
  801d36:	5f                   	pop    %edi
  801d37:	5d                   	pop    %ebp
  801d38:	c3                   	ret    
  801d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d40:	89 f9                	mov    %edi,%ecx
  801d42:	ba 20 00 00 00       	mov    $0x20,%edx
  801d47:	29 fa                	sub    %edi,%edx
  801d49:	d3 e0                	shl    %cl,%eax
  801d4b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d4f:	89 d1                	mov    %edx,%ecx
  801d51:	89 d8                	mov    %ebx,%eax
  801d53:	d3 e8                	shr    %cl,%eax
  801d55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d59:	09 c1                	or     %eax,%ecx
  801d5b:	89 f0                	mov    %esi,%eax
  801d5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d61:	89 f9                	mov    %edi,%ecx
  801d63:	d3 e3                	shl    %cl,%ebx
  801d65:	89 d1                	mov    %edx,%ecx
  801d67:	d3 e8                	shr    %cl,%eax
  801d69:	89 f9                	mov    %edi,%ecx
  801d6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d6f:	89 eb                	mov    %ebp,%ebx
  801d71:	d3 e6                	shl    %cl,%esi
  801d73:	89 d1                	mov    %edx,%ecx
  801d75:	d3 eb                	shr    %cl,%ebx
  801d77:	09 f3                	or     %esi,%ebx
  801d79:	89 c6                	mov    %eax,%esi
  801d7b:	89 f2                	mov    %esi,%edx
  801d7d:	89 d8                	mov    %ebx,%eax
  801d7f:	f7 74 24 08          	divl   0x8(%esp)
  801d83:	89 d6                	mov    %edx,%esi
  801d85:	89 c3                	mov    %eax,%ebx
  801d87:	f7 64 24 0c          	mull   0xc(%esp)
  801d8b:	39 d6                	cmp    %edx,%esi
  801d8d:	72 19                	jb     801da8 <__udivdi3+0x108>
  801d8f:	89 f9                	mov    %edi,%ecx
  801d91:	d3 e5                	shl    %cl,%ebp
  801d93:	39 c5                	cmp    %eax,%ebp
  801d95:	73 04                	jae    801d9b <__udivdi3+0xfb>
  801d97:	39 d6                	cmp    %edx,%esi
  801d99:	74 0d                	je     801da8 <__udivdi3+0x108>
  801d9b:	89 d8                	mov    %ebx,%eax
  801d9d:	31 ff                	xor    %edi,%edi
  801d9f:	e9 3c ff ff ff       	jmp    801ce0 <__udivdi3+0x40>
  801da4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801da8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801dab:	31 ff                	xor    %edi,%edi
  801dad:	e9 2e ff ff ff       	jmp    801ce0 <__udivdi3+0x40>
  801db2:	66 90                	xchg   %ax,%ax
  801db4:	66 90                	xchg   %ax,%ax
  801db6:	66 90                	xchg   %ax,%ax
  801db8:	66 90                	xchg   %ax,%ax
  801dba:	66 90                	xchg   %ax,%ax
  801dbc:	66 90                	xchg   %ax,%ax
  801dbe:	66 90                	xchg   %ax,%ax

00801dc0 <__umoddi3>:
  801dc0:	f3 0f 1e fb          	endbr32 
  801dc4:	55                   	push   %ebp
  801dc5:	57                   	push   %edi
  801dc6:	56                   	push   %esi
  801dc7:	53                   	push   %ebx
  801dc8:	83 ec 1c             	sub    $0x1c,%esp
  801dcb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801dcf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801dd3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801dd7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801ddb:	89 f0                	mov    %esi,%eax
  801ddd:	89 da                	mov    %ebx,%edx
  801ddf:	85 ff                	test   %edi,%edi
  801de1:	75 15                	jne    801df8 <__umoddi3+0x38>
  801de3:	39 dd                	cmp    %ebx,%ebp
  801de5:	76 39                	jbe    801e20 <__umoddi3+0x60>
  801de7:	f7 f5                	div    %ebp
  801de9:	89 d0                	mov    %edx,%eax
  801deb:	31 d2                	xor    %edx,%edx
  801ded:	83 c4 1c             	add    $0x1c,%esp
  801df0:	5b                   	pop    %ebx
  801df1:	5e                   	pop    %esi
  801df2:	5f                   	pop    %edi
  801df3:	5d                   	pop    %ebp
  801df4:	c3                   	ret    
  801df5:	8d 76 00             	lea    0x0(%esi),%esi
  801df8:	39 df                	cmp    %ebx,%edi
  801dfa:	77 f1                	ja     801ded <__umoddi3+0x2d>
  801dfc:	0f bd cf             	bsr    %edi,%ecx
  801dff:	83 f1 1f             	xor    $0x1f,%ecx
  801e02:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801e06:	75 40                	jne    801e48 <__umoddi3+0x88>
  801e08:	39 df                	cmp    %ebx,%edi
  801e0a:	72 04                	jb     801e10 <__umoddi3+0x50>
  801e0c:	39 f5                	cmp    %esi,%ebp
  801e0e:	77 dd                	ja     801ded <__umoddi3+0x2d>
  801e10:	89 da                	mov    %ebx,%edx
  801e12:	89 f0                	mov    %esi,%eax
  801e14:	29 e8                	sub    %ebp,%eax
  801e16:	19 fa                	sbb    %edi,%edx
  801e18:	eb d3                	jmp    801ded <__umoddi3+0x2d>
  801e1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e20:	89 e9                	mov    %ebp,%ecx
  801e22:	85 ed                	test   %ebp,%ebp
  801e24:	75 0b                	jne    801e31 <__umoddi3+0x71>
  801e26:	b8 01 00 00 00       	mov    $0x1,%eax
  801e2b:	31 d2                	xor    %edx,%edx
  801e2d:	f7 f5                	div    %ebp
  801e2f:	89 c1                	mov    %eax,%ecx
  801e31:	89 d8                	mov    %ebx,%eax
  801e33:	31 d2                	xor    %edx,%edx
  801e35:	f7 f1                	div    %ecx
  801e37:	89 f0                	mov    %esi,%eax
  801e39:	f7 f1                	div    %ecx
  801e3b:	89 d0                	mov    %edx,%eax
  801e3d:	31 d2                	xor    %edx,%edx
  801e3f:	eb ac                	jmp    801ded <__umoddi3+0x2d>
  801e41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e48:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e4c:	ba 20 00 00 00       	mov    $0x20,%edx
  801e51:	29 c2                	sub    %eax,%edx
  801e53:	89 c1                	mov    %eax,%ecx
  801e55:	89 e8                	mov    %ebp,%eax
  801e57:	d3 e7                	shl    %cl,%edi
  801e59:	89 d1                	mov    %edx,%ecx
  801e5b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801e5f:	d3 e8                	shr    %cl,%eax
  801e61:	89 c1                	mov    %eax,%ecx
  801e63:	8b 44 24 04          	mov    0x4(%esp),%eax
  801e67:	09 f9                	or     %edi,%ecx
  801e69:	89 df                	mov    %ebx,%edi
  801e6b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e6f:	89 c1                	mov    %eax,%ecx
  801e71:	d3 e5                	shl    %cl,%ebp
  801e73:	89 d1                	mov    %edx,%ecx
  801e75:	d3 ef                	shr    %cl,%edi
  801e77:	89 c1                	mov    %eax,%ecx
  801e79:	89 f0                	mov    %esi,%eax
  801e7b:	d3 e3                	shl    %cl,%ebx
  801e7d:	89 d1                	mov    %edx,%ecx
  801e7f:	89 fa                	mov    %edi,%edx
  801e81:	d3 e8                	shr    %cl,%eax
  801e83:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801e88:	09 d8                	or     %ebx,%eax
  801e8a:	f7 74 24 08          	divl   0x8(%esp)
  801e8e:	89 d3                	mov    %edx,%ebx
  801e90:	d3 e6                	shl    %cl,%esi
  801e92:	f7 e5                	mul    %ebp
  801e94:	89 c7                	mov    %eax,%edi
  801e96:	89 d1                	mov    %edx,%ecx
  801e98:	39 d3                	cmp    %edx,%ebx
  801e9a:	72 06                	jb     801ea2 <__umoddi3+0xe2>
  801e9c:	75 0e                	jne    801eac <__umoddi3+0xec>
  801e9e:	39 c6                	cmp    %eax,%esi
  801ea0:	73 0a                	jae    801eac <__umoddi3+0xec>
  801ea2:	29 e8                	sub    %ebp,%eax
  801ea4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801ea8:	89 d1                	mov    %edx,%ecx
  801eaa:	89 c7                	mov    %eax,%edi
  801eac:	89 f5                	mov    %esi,%ebp
  801eae:	8b 74 24 04          	mov    0x4(%esp),%esi
  801eb2:	29 fd                	sub    %edi,%ebp
  801eb4:	19 cb                	sbb    %ecx,%ebx
  801eb6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801ebb:	89 d8                	mov    %ebx,%eax
  801ebd:	d3 e0                	shl    %cl,%eax
  801ebf:	89 f1                	mov    %esi,%ecx
  801ec1:	d3 ed                	shr    %cl,%ebp
  801ec3:	d3 eb                	shr    %cl,%ebx
  801ec5:	09 e8                	or     %ebp,%eax
  801ec7:	89 da                	mov    %ebx,%edx
  801ec9:	83 c4 1c             	add    $0x1c,%esp
  801ecc:	5b                   	pop    %ebx
  801ecd:	5e                   	pop    %esi
  801ece:	5f                   	pop    %edi
  801ecf:	5d                   	pop    %ebp
  801ed0:	c3                   	ret    
