
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
  80009c:	68 c0 23 80 00       	push   $0x8023c0
  8000a1:	6a 20                	push   $0x20
  8000a3:	68 d3 23 80 00       	push   $0x8023d3
  8000a8:	e8 7e 01 00 00       	call   80022b <_panic>
		panic("sys_page_map: %e", r);
  8000ad:	50                   	push   %eax
  8000ae:	68 e3 23 80 00       	push   $0x8023e3
  8000b3:	6a 22                	push   $0x22
  8000b5:	68 d3 23 80 00       	push   $0x8023d3
  8000ba:	e8 6c 01 00 00       	call   80022b <_panic>
		panic("sys_page_unmap: %e", r);
  8000bf:	50                   	push   %eax
  8000c0:	68 f4 23 80 00       	push   $0x8023f4
  8000c5:	6a 25                	push   $0x25
  8000c7:	68 d3 23 80 00       	push   $0x8023d3
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
  800106:	68 07 24 80 00       	push   $0x802407
  80010b:	6a 37                	push   $0x37
  80010d:	68 d3 23 80 00       	push   $0x8023d3
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
  800130:	81 fa 04 80 80 00    	cmp    $0x808004,%edx
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
  800164:	68 17 24 80 00       	push   $0x802417
  800169:	6a 4c                	push   $0x4c
  80016b:	68 d3 23 80 00       	push   $0x8023d3
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
  800187:	bf 2e 24 80 00       	mov    $0x80242e,%edi
  80018c:	b8 35 24 80 00       	mov    $0x802435,%eax
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
  8001a5:	68 3b 24 80 00       	push   $0x80243b
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
  800217:	e8 e3 0e 00 00       	call   8010ff <close_all>
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
  800249:	68 58 24 80 00       	push   $0x802458
  80024e:	e8 b3 00 00 00       	call   800306 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800253:	83 c4 18             	add    $0x18,%esp
  800256:	53                   	push   %ebx
  800257:	ff 75 10             	push   0x10(%ebp)
  80025a:	e8 56 00 00 00       	call   8002b5 <vcprintf>
	cprintf("\n");
  80025f:	c7 04 24 4b 24 80 00 	movl   $0x80244b,(%esp)
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
  800368:	e8 03 1e 00 00       	call   802170 <__udivdi3>
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
  8003a6:	e8 e5 1e 00 00       	call   802290 <__umoddi3>
  8003ab:	83 c4 14             	add    $0x14,%esp
  8003ae:	0f be 80 7b 24 80 00 	movsbl 0x80247b(%eax),%eax
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
  800468:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
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
  800536:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  80053d:	85 d2                	test   %edx,%edx
  80053f:	74 18                	je     800559 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800541:	52                   	push   %edx
  800542:	68 55 28 80 00       	push   $0x802855
  800547:	53                   	push   %ebx
  800548:	56                   	push   %esi
  800549:	e8 92 fe ff ff       	call   8003e0 <printfmt>
  80054e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800551:	89 7d 14             	mov    %edi,0x14(%ebp)
  800554:	e9 66 02 00 00       	jmp    8007bf <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800559:	50                   	push   %eax
  80055a:	68 93 24 80 00       	push   $0x802493
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
  800581:	b8 8c 24 80 00       	mov    $0x80248c,%eax
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
  800c8d:	68 7f 27 80 00       	push   $0x80277f
  800c92:	6a 2a                	push   $0x2a
  800c94:	68 9c 27 80 00       	push   $0x80279c
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
  800d0e:	68 7f 27 80 00       	push   $0x80277f
  800d13:	6a 2a                	push   $0x2a
  800d15:	68 9c 27 80 00       	push   $0x80279c
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
  800d50:	68 7f 27 80 00       	push   $0x80277f
  800d55:	6a 2a                	push   $0x2a
  800d57:	68 9c 27 80 00       	push   $0x80279c
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
  800d92:	68 7f 27 80 00       	push   $0x80277f
  800d97:	6a 2a                	push   $0x2a
  800d99:	68 9c 27 80 00       	push   $0x80279c
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
  800dd4:	68 7f 27 80 00       	push   $0x80277f
  800dd9:	6a 2a                	push   $0x2a
  800ddb:	68 9c 27 80 00       	push   $0x80279c
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
  800e16:	68 7f 27 80 00       	push   $0x80277f
  800e1b:	6a 2a                	push   $0x2a
  800e1d:	68 9c 27 80 00       	push   $0x80279c
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
  800e58:	68 7f 27 80 00       	push   $0x80277f
  800e5d:	6a 2a                	push   $0x2a
  800e5f:	68 9c 27 80 00       	push   $0x80279c
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
  800ebc:	68 7f 27 80 00       	push   $0x80277f
  800ec1:	6a 2a                	push   $0x2a
  800ec3:	68 9c 27 80 00       	push   $0x80279c
  800ec8:	e8 5e f3 ff ff       	call   80022b <_panic>

00800ecd <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	57                   	push   %edi
  800ed1:	56                   	push   %esi
  800ed2:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ed3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed8:	b8 0e 00 00 00       	mov    $0xe,%eax
  800edd:	89 d1                	mov    %edx,%ecx
  800edf:	89 d3                	mov    %edx,%ebx
  800ee1:	89 d7                	mov    %edx,%edi
  800ee3:	89 d6                	mov    %edx,%esi
  800ee5:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800ee7:	5b                   	pop    %ebx
  800ee8:	5e                   	pop    %esi
  800ee9:	5f                   	pop    %edi
  800eea:	5d                   	pop    %ebp
  800eeb:	c3                   	ret    

00800eec <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800eec:	55                   	push   %ebp
  800eed:	89 e5                	mov    %esp,%ebp
  800eef:	57                   	push   %edi
  800ef0:	56                   	push   %esi
  800ef1:	53                   	push   %ebx
	asm volatile("int %1\n"
  800ef2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef7:	8b 55 08             	mov    0x8(%ebp),%edx
  800efa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efd:	b8 0f 00 00 00       	mov    $0xf,%eax
  800f02:	89 df                	mov    %ebx,%edi
  800f04:	89 de                	mov    %ebx,%esi
  800f06:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800f08:	5b                   	pop    %ebx
  800f09:	5e                   	pop    %esi
  800f0a:	5f                   	pop    %edi
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    

00800f0d <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	57                   	push   %edi
  800f11:	56                   	push   %esi
  800f12:	53                   	push   %ebx
	asm volatile("int %1\n"
  800f13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f18:	8b 55 08             	mov    0x8(%ebp),%edx
  800f1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1e:	b8 10 00 00 00       	mov    $0x10,%eax
  800f23:	89 df                	mov    %ebx,%edi
  800f25:	89 de                	mov    %ebx,%esi
  800f27:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  800f29:	5b                   	pop    %ebx
  800f2a:	5e                   	pop    %esi
  800f2b:	5f                   	pop    %edi
  800f2c:	5d                   	pop    %ebp
  800f2d:	c3                   	ret    

00800f2e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800f2e:	55                   	push   %ebp
  800f2f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f31:	8b 45 08             	mov    0x8(%ebp),%eax
  800f34:	05 00 00 00 30       	add    $0x30000000,%eax
  800f39:	c1 e8 0c             	shr    $0xc,%eax
}
  800f3c:	5d                   	pop    %ebp
  800f3d:	c3                   	ret    

00800f3e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800f3e:	55                   	push   %ebp
  800f3f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800f41:	8b 45 08             	mov    0x8(%ebp),%eax
  800f44:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800f49:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800f4e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    

00800f55 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800f5d:	89 c2                	mov    %eax,%edx
  800f5f:	c1 ea 16             	shr    $0x16,%edx
  800f62:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800f69:	f6 c2 01             	test   $0x1,%dl
  800f6c:	74 29                	je     800f97 <fd_alloc+0x42>
  800f6e:	89 c2                	mov    %eax,%edx
  800f70:	c1 ea 0c             	shr    $0xc,%edx
  800f73:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800f7a:	f6 c2 01             	test   $0x1,%dl
  800f7d:	74 18                	je     800f97 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800f7f:	05 00 10 00 00       	add    $0x1000,%eax
  800f84:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800f89:	75 d2                	jne    800f5d <fd_alloc+0x8>
  800f8b:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800f90:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800f95:	eb 05                	jmp    800f9c <fd_alloc+0x47>
			return 0;
  800f97:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800f9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800f9f:	89 02                	mov    %eax,(%edx)
}
  800fa1:	89 c8                	mov    %ecx,%eax
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    

00800fa5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800fab:	83 f8 1f             	cmp    $0x1f,%eax
  800fae:	77 30                	ja     800fe0 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800fb0:	c1 e0 0c             	shl    $0xc,%eax
  800fb3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800fb8:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800fbe:	f6 c2 01             	test   $0x1,%dl
  800fc1:	74 24                	je     800fe7 <fd_lookup+0x42>
  800fc3:	89 c2                	mov    %eax,%edx
  800fc5:	c1 ea 0c             	shr    $0xc,%edx
  800fc8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800fcf:	f6 c2 01             	test   $0x1,%dl
  800fd2:	74 1a                	je     800fee <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800fd4:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fd7:	89 02                	mov    %eax,(%edx)
	return 0;
  800fd9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fde:	5d                   	pop    %ebp
  800fdf:	c3                   	ret    
		return -E_INVAL;
  800fe0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fe5:	eb f7                	jmp    800fde <fd_lookup+0x39>
		return -E_INVAL;
  800fe7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800fec:	eb f0                	jmp    800fde <fd_lookup+0x39>
  800fee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ff3:	eb e9                	jmp    800fde <fd_lookup+0x39>

00800ff5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	53                   	push   %ebx
  800ff9:	83 ec 04             	sub    $0x4,%esp
  800ffc:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800fff:	b8 00 00 00 00       	mov    $0x0,%eax
  801004:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  801009:	39 13                	cmp    %edx,(%ebx)
  80100b:	74 37                	je     801044 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  80100d:	83 c0 01             	add    $0x1,%eax
  801010:	8b 1c 85 28 28 80 00 	mov    0x802828(,%eax,4),%ebx
  801017:	85 db                	test   %ebx,%ebx
  801019:	75 ee                	jne    801009 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80101b:	a1 00 40 80 00       	mov    0x804000,%eax
  801020:	8b 40 48             	mov    0x48(%eax),%eax
  801023:	83 ec 04             	sub    $0x4,%esp
  801026:	52                   	push   %edx
  801027:	50                   	push   %eax
  801028:	68 ac 27 80 00       	push   $0x8027ac
  80102d:	e8 d4 f2 ff ff       	call   800306 <cprintf>
	*dev = 0;
	return -E_INVAL;
  801032:	83 c4 10             	add    $0x10,%esp
  801035:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  80103a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80103d:	89 1a                	mov    %ebx,(%edx)
}
  80103f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801042:	c9                   	leave  
  801043:	c3                   	ret    
			return 0;
  801044:	b8 00 00 00 00       	mov    $0x0,%eax
  801049:	eb ef                	jmp    80103a <dev_lookup+0x45>

0080104b <fd_close>:
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	57                   	push   %edi
  80104f:	56                   	push   %esi
  801050:	53                   	push   %ebx
  801051:	83 ec 24             	sub    $0x24,%esp
  801054:	8b 75 08             	mov    0x8(%ebp),%esi
  801057:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80105a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80105d:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80105e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801064:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801067:	50                   	push   %eax
  801068:	e8 38 ff ff ff       	call   800fa5 <fd_lookup>
  80106d:	89 c3                	mov    %eax,%ebx
  80106f:	83 c4 10             	add    $0x10,%esp
  801072:	85 c0                	test   %eax,%eax
  801074:	78 05                	js     80107b <fd_close+0x30>
	    || fd != fd2)
  801076:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801079:	74 16                	je     801091 <fd_close+0x46>
		return (must_exist ? r : 0);
  80107b:	89 f8                	mov    %edi,%eax
  80107d:	84 c0                	test   %al,%al
  80107f:	b8 00 00 00 00       	mov    $0x0,%eax
  801084:	0f 44 d8             	cmove  %eax,%ebx
}
  801087:	89 d8                	mov    %ebx,%eax
  801089:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108c:	5b                   	pop    %ebx
  80108d:	5e                   	pop    %esi
  80108e:	5f                   	pop    %edi
  80108f:	5d                   	pop    %ebp
  801090:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801091:	83 ec 08             	sub    $0x8,%esp
  801094:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801097:	50                   	push   %eax
  801098:	ff 36                	push   (%esi)
  80109a:	e8 56 ff ff ff       	call   800ff5 <dev_lookup>
  80109f:	89 c3                	mov    %eax,%ebx
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	78 1a                	js     8010c2 <fd_close+0x77>
		if (dev->dev_close)
  8010a8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010ab:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8010ae:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8010b3:	85 c0                	test   %eax,%eax
  8010b5:	74 0b                	je     8010c2 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8010b7:	83 ec 0c             	sub    $0xc,%esp
  8010ba:	56                   	push   %esi
  8010bb:	ff d0                	call   *%eax
  8010bd:	89 c3                	mov    %eax,%ebx
  8010bf:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8010c2:	83 ec 08             	sub    $0x8,%esp
  8010c5:	56                   	push   %esi
  8010c6:	6a 00                	push   $0x0
  8010c8:	e8 94 fc ff ff       	call   800d61 <sys_page_unmap>
	return r;
  8010cd:	83 c4 10             	add    $0x10,%esp
  8010d0:	eb b5                	jmp    801087 <fd_close+0x3c>

008010d2 <close>:

int
close(int fdnum)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010db:	50                   	push   %eax
  8010dc:	ff 75 08             	push   0x8(%ebp)
  8010df:	e8 c1 fe ff ff       	call   800fa5 <fd_lookup>
  8010e4:	83 c4 10             	add    $0x10,%esp
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	79 02                	jns    8010ed <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8010eb:	c9                   	leave  
  8010ec:	c3                   	ret    
		return fd_close(fd, 1);
  8010ed:	83 ec 08             	sub    $0x8,%esp
  8010f0:	6a 01                	push   $0x1
  8010f2:	ff 75 f4             	push   -0xc(%ebp)
  8010f5:	e8 51 ff ff ff       	call   80104b <fd_close>
  8010fa:	83 c4 10             	add    $0x10,%esp
  8010fd:	eb ec                	jmp    8010eb <close+0x19>

008010ff <close_all>:

void
close_all(void)
{
  8010ff:	55                   	push   %ebp
  801100:	89 e5                	mov    %esp,%ebp
  801102:	53                   	push   %ebx
  801103:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801106:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80110b:	83 ec 0c             	sub    $0xc,%esp
  80110e:	53                   	push   %ebx
  80110f:	e8 be ff ff ff       	call   8010d2 <close>
	for (i = 0; i < MAXFD; i++)
  801114:	83 c3 01             	add    $0x1,%ebx
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	83 fb 20             	cmp    $0x20,%ebx
  80111d:	75 ec                	jne    80110b <close_all+0xc>
}
  80111f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801122:	c9                   	leave  
  801123:	c3                   	ret    

00801124 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	57                   	push   %edi
  801128:	56                   	push   %esi
  801129:	53                   	push   %ebx
  80112a:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80112d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801130:	50                   	push   %eax
  801131:	ff 75 08             	push   0x8(%ebp)
  801134:	e8 6c fe ff ff       	call   800fa5 <fd_lookup>
  801139:	89 c3                	mov    %eax,%ebx
  80113b:	83 c4 10             	add    $0x10,%esp
  80113e:	85 c0                	test   %eax,%eax
  801140:	78 7f                	js     8011c1 <dup+0x9d>
		return r;
	close(newfdnum);
  801142:	83 ec 0c             	sub    $0xc,%esp
  801145:	ff 75 0c             	push   0xc(%ebp)
  801148:	e8 85 ff ff ff       	call   8010d2 <close>

	newfd = INDEX2FD(newfdnum);
  80114d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801150:	c1 e6 0c             	shl    $0xc,%esi
  801153:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801159:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80115c:	89 3c 24             	mov    %edi,(%esp)
  80115f:	e8 da fd ff ff       	call   800f3e <fd2data>
  801164:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801166:	89 34 24             	mov    %esi,(%esp)
  801169:	e8 d0 fd ff ff       	call   800f3e <fd2data>
  80116e:	83 c4 10             	add    $0x10,%esp
  801171:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801174:	89 d8                	mov    %ebx,%eax
  801176:	c1 e8 16             	shr    $0x16,%eax
  801179:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801180:	a8 01                	test   $0x1,%al
  801182:	74 11                	je     801195 <dup+0x71>
  801184:	89 d8                	mov    %ebx,%eax
  801186:	c1 e8 0c             	shr    $0xc,%eax
  801189:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801190:	f6 c2 01             	test   $0x1,%dl
  801193:	75 36                	jne    8011cb <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801195:	89 f8                	mov    %edi,%eax
  801197:	c1 e8 0c             	shr    $0xc,%eax
  80119a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011a1:	83 ec 0c             	sub    $0xc,%esp
  8011a4:	25 07 0e 00 00       	and    $0xe07,%eax
  8011a9:	50                   	push   %eax
  8011aa:	56                   	push   %esi
  8011ab:	6a 00                	push   $0x0
  8011ad:	57                   	push   %edi
  8011ae:	6a 00                	push   $0x0
  8011b0:	e8 6a fb ff ff       	call   800d1f <sys_page_map>
  8011b5:	89 c3                	mov    %eax,%ebx
  8011b7:	83 c4 20             	add    $0x20,%esp
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	78 33                	js     8011f1 <dup+0xcd>
		goto err;

	return newfdnum;
  8011be:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8011c1:	89 d8                	mov    %ebx,%eax
  8011c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c6:	5b                   	pop    %ebx
  8011c7:	5e                   	pop    %esi
  8011c8:	5f                   	pop    %edi
  8011c9:	5d                   	pop    %ebp
  8011ca:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8011cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8011d2:	83 ec 0c             	sub    $0xc,%esp
  8011d5:	25 07 0e 00 00       	and    $0xe07,%eax
  8011da:	50                   	push   %eax
  8011db:	ff 75 d4             	push   -0x2c(%ebp)
  8011de:	6a 00                	push   $0x0
  8011e0:	53                   	push   %ebx
  8011e1:	6a 00                	push   $0x0
  8011e3:	e8 37 fb ff ff       	call   800d1f <sys_page_map>
  8011e8:	89 c3                	mov    %eax,%ebx
  8011ea:	83 c4 20             	add    $0x20,%esp
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	79 a4                	jns    801195 <dup+0x71>
	sys_page_unmap(0, newfd);
  8011f1:	83 ec 08             	sub    $0x8,%esp
  8011f4:	56                   	push   %esi
  8011f5:	6a 00                	push   $0x0
  8011f7:	e8 65 fb ff ff       	call   800d61 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8011fc:	83 c4 08             	add    $0x8,%esp
  8011ff:	ff 75 d4             	push   -0x2c(%ebp)
  801202:	6a 00                	push   $0x0
  801204:	e8 58 fb ff ff       	call   800d61 <sys_page_unmap>
	return r;
  801209:	83 c4 10             	add    $0x10,%esp
  80120c:	eb b3                	jmp    8011c1 <dup+0x9d>

0080120e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80120e:	55                   	push   %ebp
  80120f:	89 e5                	mov    %esp,%ebp
  801211:	56                   	push   %esi
  801212:	53                   	push   %ebx
  801213:	83 ec 18             	sub    $0x18,%esp
  801216:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801219:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121c:	50                   	push   %eax
  80121d:	56                   	push   %esi
  80121e:	e8 82 fd ff ff       	call   800fa5 <fd_lookup>
  801223:	83 c4 10             	add    $0x10,%esp
  801226:	85 c0                	test   %eax,%eax
  801228:	78 3c                	js     801266 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122a:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80122d:	83 ec 08             	sub    $0x8,%esp
  801230:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801233:	50                   	push   %eax
  801234:	ff 33                	push   (%ebx)
  801236:	e8 ba fd ff ff       	call   800ff5 <dev_lookup>
  80123b:	83 c4 10             	add    $0x10,%esp
  80123e:	85 c0                	test   %eax,%eax
  801240:	78 24                	js     801266 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801242:	8b 43 08             	mov    0x8(%ebx),%eax
  801245:	83 e0 03             	and    $0x3,%eax
  801248:	83 f8 01             	cmp    $0x1,%eax
  80124b:	74 20                	je     80126d <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80124d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801250:	8b 40 08             	mov    0x8(%eax),%eax
  801253:	85 c0                	test   %eax,%eax
  801255:	74 37                	je     80128e <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801257:	83 ec 04             	sub    $0x4,%esp
  80125a:	ff 75 10             	push   0x10(%ebp)
  80125d:	ff 75 0c             	push   0xc(%ebp)
  801260:	53                   	push   %ebx
  801261:	ff d0                	call   *%eax
  801263:	83 c4 10             	add    $0x10,%esp
}
  801266:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801269:	5b                   	pop    %ebx
  80126a:	5e                   	pop    %esi
  80126b:	5d                   	pop    %ebp
  80126c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80126d:	a1 00 40 80 00       	mov    0x804000,%eax
  801272:	8b 40 48             	mov    0x48(%eax),%eax
  801275:	83 ec 04             	sub    $0x4,%esp
  801278:	56                   	push   %esi
  801279:	50                   	push   %eax
  80127a:	68 ed 27 80 00       	push   $0x8027ed
  80127f:	e8 82 f0 ff ff       	call   800306 <cprintf>
		return -E_INVAL;
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80128c:	eb d8                	jmp    801266 <read+0x58>
		return -E_NOT_SUPP;
  80128e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801293:	eb d1                	jmp    801266 <read+0x58>

00801295 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801295:	55                   	push   %ebp
  801296:	89 e5                	mov    %esp,%ebp
  801298:	57                   	push   %edi
  801299:	56                   	push   %esi
  80129a:	53                   	push   %ebx
  80129b:	83 ec 0c             	sub    $0xc,%esp
  80129e:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012a1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8012a4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012a9:	eb 02                	jmp    8012ad <readn+0x18>
  8012ab:	01 c3                	add    %eax,%ebx
  8012ad:	39 f3                	cmp    %esi,%ebx
  8012af:	73 21                	jae    8012d2 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012b1:	83 ec 04             	sub    $0x4,%esp
  8012b4:	89 f0                	mov    %esi,%eax
  8012b6:	29 d8                	sub    %ebx,%eax
  8012b8:	50                   	push   %eax
  8012b9:	89 d8                	mov    %ebx,%eax
  8012bb:	03 45 0c             	add    0xc(%ebp),%eax
  8012be:	50                   	push   %eax
  8012bf:	57                   	push   %edi
  8012c0:	e8 49 ff ff ff       	call   80120e <read>
		if (m < 0)
  8012c5:	83 c4 10             	add    $0x10,%esp
  8012c8:	85 c0                	test   %eax,%eax
  8012ca:	78 04                	js     8012d0 <readn+0x3b>
			return m;
		if (m == 0)
  8012cc:	75 dd                	jne    8012ab <readn+0x16>
  8012ce:	eb 02                	jmp    8012d2 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8012d0:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8012d2:	89 d8                	mov    %ebx,%eax
  8012d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012d7:	5b                   	pop    %ebx
  8012d8:	5e                   	pop    %esi
  8012d9:	5f                   	pop    %edi
  8012da:	5d                   	pop    %ebp
  8012db:	c3                   	ret    

008012dc <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012dc:	55                   	push   %ebp
  8012dd:	89 e5                	mov    %esp,%ebp
  8012df:	56                   	push   %esi
  8012e0:	53                   	push   %ebx
  8012e1:	83 ec 18             	sub    $0x18,%esp
  8012e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ea:	50                   	push   %eax
  8012eb:	53                   	push   %ebx
  8012ec:	e8 b4 fc ff ff       	call   800fa5 <fd_lookup>
  8012f1:	83 c4 10             	add    $0x10,%esp
  8012f4:	85 c0                	test   %eax,%eax
  8012f6:	78 37                	js     80132f <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f8:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8012fb:	83 ec 08             	sub    $0x8,%esp
  8012fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801301:	50                   	push   %eax
  801302:	ff 36                	push   (%esi)
  801304:	e8 ec fc ff ff       	call   800ff5 <dev_lookup>
  801309:	83 c4 10             	add    $0x10,%esp
  80130c:	85 c0                	test   %eax,%eax
  80130e:	78 1f                	js     80132f <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801310:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  801314:	74 20                	je     801336 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801316:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801319:	8b 40 0c             	mov    0xc(%eax),%eax
  80131c:	85 c0                	test   %eax,%eax
  80131e:	74 37                	je     801357 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801320:	83 ec 04             	sub    $0x4,%esp
  801323:	ff 75 10             	push   0x10(%ebp)
  801326:	ff 75 0c             	push   0xc(%ebp)
  801329:	56                   	push   %esi
  80132a:	ff d0                	call   *%eax
  80132c:	83 c4 10             	add    $0x10,%esp
}
  80132f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801332:	5b                   	pop    %ebx
  801333:	5e                   	pop    %esi
  801334:	5d                   	pop    %ebp
  801335:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801336:	a1 00 40 80 00       	mov    0x804000,%eax
  80133b:	8b 40 48             	mov    0x48(%eax),%eax
  80133e:	83 ec 04             	sub    $0x4,%esp
  801341:	53                   	push   %ebx
  801342:	50                   	push   %eax
  801343:	68 09 28 80 00       	push   $0x802809
  801348:	e8 b9 ef ff ff       	call   800306 <cprintf>
		return -E_INVAL;
  80134d:	83 c4 10             	add    $0x10,%esp
  801350:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801355:	eb d8                	jmp    80132f <write+0x53>
		return -E_NOT_SUPP;
  801357:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80135c:	eb d1                	jmp    80132f <write+0x53>

0080135e <seek>:

int
seek(int fdnum, off_t offset)
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801364:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801367:	50                   	push   %eax
  801368:	ff 75 08             	push   0x8(%ebp)
  80136b:	e8 35 fc ff ff       	call   800fa5 <fd_lookup>
  801370:	83 c4 10             	add    $0x10,%esp
  801373:	85 c0                	test   %eax,%eax
  801375:	78 0e                	js     801385 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801377:	8b 55 0c             	mov    0xc(%ebp),%edx
  80137a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801380:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801385:	c9                   	leave  
  801386:	c3                   	ret    

00801387 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801387:	55                   	push   %ebp
  801388:	89 e5                	mov    %esp,%ebp
  80138a:	56                   	push   %esi
  80138b:	53                   	push   %ebx
  80138c:	83 ec 18             	sub    $0x18,%esp
  80138f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801392:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801395:	50                   	push   %eax
  801396:	53                   	push   %ebx
  801397:	e8 09 fc ff ff       	call   800fa5 <fd_lookup>
  80139c:	83 c4 10             	add    $0x10,%esp
  80139f:	85 c0                	test   %eax,%eax
  8013a1:	78 34                	js     8013d7 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013a3:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8013a6:	83 ec 08             	sub    $0x8,%esp
  8013a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ac:	50                   	push   %eax
  8013ad:	ff 36                	push   (%esi)
  8013af:	e8 41 fc ff ff       	call   800ff5 <dev_lookup>
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	85 c0                	test   %eax,%eax
  8013b9:	78 1c                	js     8013d7 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013bb:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8013bf:	74 1d                	je     8013de <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8013c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c4:	8b 40 18             	mov    0x18(%eax),%eax
  8013c7:	85 c0                	test   %eax,%eax
  8013c9:	74 34                	je     8013ff <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	ff 75 0c             	push   0xc(%ebp)
  8013d1:	56                   	push   %esi
  8013d2:	ff d0                	call   *%eax
  8013d4:	83 c4 10             	add    $0x10,%esp
}
  8013d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013da:	5b                   	pop    %ebx
  8013db:	5e                   	pop    %esi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    
			thisenv->env_id, fdnum);
  8013de:	a1 00 40 80 00       	mov    0x804000,%eax
  8013e3:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8013e6:	83 ec 04             	sub    $0x4,%esp
  8013e9:	53                   	push   %ebx
  8013ea:	50                   	push   %eax
  8013eb:	68 cc 27 80 00       	push   $0x8027cc
  8013f0:	e8 11 ef ff ff       	call   800306 <cprintf>
		return -E_INVAL;
  8013f5:	83 c4 10             	add    $0x10,%esp
  8013f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013fd:	eb d8                	jmp    8013d7 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8013ff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801404:	eb d1                	jmp    8013d7 <ftruncate+0x50>

00801406 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	56                   	push   %esi
  80140a:	53                   	push   %ebx
  80140b:	83 ec 18             	sub    $0x18,%esp
  80140e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801411:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801414:	50                   	push   %eax
  801415:	ff 75 08             	push   0x8(%ebp)
  801418:	e8 88 fb ff ff       	call   800fa5 <fd_lookup>
  80141d:	83 c4 10             	add    $0x10,%esp
  801420:	85 c0                	test   %eax,%eax
  801422:	78 49                	js     80146d <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801424:	8b 75 f0             	mov    -0x10(%ebp),%esi
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142d:	50                   	push   %eax
  80142e:	ff 36                	push   (%esi)
  801430:	e8 c0 fb ff ff       	call   800ff5 <dev_lookup>
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	85 c0                	test   %eax,%eax
  80143a:	78 31                	js     80146d <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80143c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80143f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801443:	74 2f                	je     801474 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801445:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801448:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80144f:	00 00 00 
	stat->st_isdir = 0;
  801452:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801459:	00 00 00 
	stat->st_dev = dev;
  80145c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	53                   	push   %ebx
  801466:	56                   	push   %esi
  801467:	ff 50 14             	call   *0x14(%eax)
  80146a:	83 c4 10             	add    $0x10,%esp
}
  80146d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801470:	5b                   	pop    %ebx
  801471:	5e                   	pop    %esi
  801472:	5d                   	pop    %ebp
  801473:	c3                   	ret    
		return -E_NOT_SUPP;
  801474:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801479:	eb f2                	jmp    80146d <fstat+0x67>

0080147b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	56                   	push   %esi
  80147f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801480:	83 ec 08             	sub    $0x8,%esp
  801483:	6a 00                	push   $0x0
  801485:	ff 75 08             	push   0x8(%ebp)
  801488:	e8 e4 01 00 00       	call   801671 <open>
  80148d:	89 c3                	mov    %eax,%ebx
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	85 c0                	test   %eax,%eax
  801494:	78 1b                	js     8014b1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801496:	83 ec 08             	sub    $0x8,%esp
  801499:	ff 75 0c             	push   0xc(%ebp)
  80149c:	50                   	push   %eax
  80149d:	e8 64 ff ff ff       	call   801406 <fstat>
  8014a2:	89 c6                	mov    %eax,%esi
	close(fd);
  8014a4:	89 1c 24             	mov    %ebx,(%esp)
  8014a7:	e8 26 fc ff ff       	call   8010d2 <close>
	return r;
  8014ac:	83 c4 10             	add    $0x10,%esp
  8014af:	89 f3                	mov    %esi,%ebx
}
  8014b1:	89 d8                	mov    %ebx,%eax
  8014b3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014b6:	5b                   	pop    %ebx
  8014b7:	5e                   	pop    %esi
  8014b8:	5d                   	pop    %ebp
  8014b9:	c3                   	ret    

008014ba <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8014ba:	55                   	push   %ebp
  8014bb:	89 e5                	mov    %esp,%ebp
  8014bd:	56                   	push   %esi
  8014be:	53                   	push   %ebx
  8014bf:	89 c6                	mov    %eax,%esi
  8014c1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8014c3:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8014ca:	74 27                	je     8014f3 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8014cc:	6a 07                	push   $0x7
  8014ce:	68 00 50 80 00       	push   $0x805000
  8014d3:	56                   	push   %esi
  8014d4:	ff 35 00 60 80 00    	push   0x806000
  8014da:	e8 c4 0b 00 00       	call   8020a3 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8014df:	83 c4 0c             	add    $0xc,%esp
  8014e2:	6a 00                	push   $0x0
  8014e4:	53                   	push   %ebx
  8014e5:	6a 00                	push   $0x0
  8014e7:	e8 50 0b 00 00       	call   80203c <ipc_recv>
}
  8014ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ef:	5b                   	pop    %ebx
  8014f0:	5e                   	pop    %esi
  8014f1:	5d                   	pop    %ebp
  8014f2:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8014f3:	83 ec 0c             	sub    $0xc,%esp
  8014f6:	6a 01                	push   $0x1
  8014f8:	e8 fa 0b 00 00       	call   8020f7 <ipc_find_env>
  8014fd:	a3 00 60 80 00       	mov    %eax,0x806000
  801502:	83 c4 10             	add    $0x10,%esp
  801505:	eb c5                	jmp    8014cc <fsipc+0x12>

00801507 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801507:	55                   	push   %ebp
  801508:	89 e5                	mov    %esp,%ebp
  80150a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80150d:	8b 45 08             	mov    0x8(%ebp),%eax
  801510:	8b 40 0c             	mov    0xc(%eax),%eax
  801513:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801518:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801520:	ba 00 00 00 00       	mov    $0x0,%edx
  801525:	b8 02 00 00 00       	mov    $0x2,%eax
  80152a:	e8 8b ff ff ff       	call   8014ba <fsipc>
}
  80152f:	c9                   	leave  
  801530:	c3                   	ret    

00801531 <devfile_flush>:
{
  801531:	55                   	push   %ebp
  801532:	89 e5                	mov    %esp,%ebp
  801534:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801537:	8b 45 08             	mov    0x8(%ebp),%eax
  80153a:	8b 40 0c             	mov    0xc(%eax),%eax
  80153d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801542:	ba 00 00 00 00       	mov    $0x0,%edx
  801547:	b8 06 00 00 00       	mov    $0x6,%eax
  80154c:	e8 69 ff ff ff       	call   8014ba <fsipc>
}
  801551:	c9                   	leave  
  801552:	c3                   	ret    

00801553 <devfile_stat>:
{
  801553:	55                   	push   %ebp
  801554:	89 e5                	mov    %esp,%ebp
  801556:	53                   	push   %ebx
  801557:	83 ec 04             	sub    $0x4,%esp
  80155a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80155d:	8b 45 08             	mov    0x8(%ebp),%eax
  801560:	8b 40 0c             	mov    0xc(%eax),%eax
  801563:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801568:	ba 00 00 00 00       	mov    $0x0,%edx
  80156d:	b8 05 00 00 00       	mov    $0x5,%eax
  801572:	e8 43 ff ff ff       	call   8014ba <fsipc>
  801577:	85 c0                	test   %eax,%eax
  801579:	78 2c                	js     8015a7 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80157b:	83 ec 08             	sub    $0x8,%esp
  80157e:	68 00 50 80 00       	push   $0x805000
  801583:	53                   	push   %ebx
  801584:	e8 57 f3 ff ff       	call   8008e0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801589:	a1 80 50 80 00       	mov    0x805080,%eax
  80158e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801594:	a1 84 50 80 00       	mov    0x805084,%eax
  801599:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80159f:	83 c4 10             	add    $0x10,%esp
  8015a2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015aa:	c9                   	leave  
  8015ab:	c3                   	ret    

008015ac <devfile_write>:
{
  8015ac:	55                   	push   %ebp
  8015ad:	89 e5                	mov    %esp,%ebp
  8015af:	83 ec 0c             	sub    $0xc,%esp
  8015b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8015b5:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8015ba:	39 d0                	cmp    %edx,%eax
  8015bc:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8015bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8015c2:	8b 52 0c             	mov    0xc(%edx),%edx
  8015c5:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8015cb:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8015d0:	50                   	push   %eax
  8015d1:	ff 75 0c             	push   0xc(%ebp)
  8015d4:	68 08 50 80 00       	push   $0x805008
  8015d9:	e8 98 f4 ff ff       	call   800a76 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8015de:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e3:	b8 04 00 00 00       	mov    $0x4,%eax
  8015e8:	e8 cd fe ff ff       	call   8014ba <fsipc>
}
  8015ed:	c9                   	leave  
  8015ee:	c3                   	ret    

008015ef <devfile_read>:
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	56                   	push   %esi
  8015f3:	53                   	push   %ebx
  8015f4:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8015f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8015fd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801602:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801608:	ba 00 00 00 00       	mov    $0x0,%edx
  80160d:	b8 03 00 00 00       	mov    $0x3,%eax
  801612:	e8 a3 fe ff ff       	call   8014ba <fsipc>
  801617:	89 c3                	mov    %eax,%ebx
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 1f                	js     80163c <devfile_read+0x4d>
	assert(r <= n);
  80161d:	39 f0                	cmp    %esi,%eax
  80161f:	77 24                	ja     801645 <devfile_read+0x56>
	assert(r <= PGSIZE);
  801621:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801626:	7f 33                	jg     80165b <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801628:	83 ec 04             	sub    $0x4,%esp
  80162b:	50                   	push   %eax
  80162c:	68 00 50 80 00       	push   $0x805000
  801631:	ff 75 0c             	push   0xc(%ebp)
  801634:	e8 3d f4 ff ff       	call   800a76 <memmove>
	return r;
  801639:	83 c4 10             	add    $0x10,%esp
}
  80163c:	89 d8                	mov    %ebx,%eax
  80163e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801641:	5b                   	pop    %ebx
  801642:	5e                   	pop    %esi
  801643:	5d                   	pop    %ebp
  801644:	c3                   	ret    
	assert(r <= n);
  801645:	68 3c 28 80 00       	push   $0x80283c
  80164a:	68 43 28 80 00       	push   $0x802843
  80164f:	6a 7c                	push   $0x7c
  801651:	68 58 28 80 00       	push   $0x802858
  801656:	e8 d0 eb ff ff       	call   80022b <_panic>
	assert(r <= PGSIZE);
  80165b:	68 63 28 80 00       	push   $0x802863
  801660:	68 43 28 80 00       	push   $0x802843
  801665:	6a 7d                	push   $0x7d
  801667:	68 58 28 80 00       	push   $0x802858
  80166c:	e8 ba eb ff ff       	call   80022b <_panic>

00801671 <open>:
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	56                   	push   %esi
  801675:	53                   	push   %ebx
  801676:	83 ec 1c             	sub    $0x1c,%esp
  801679:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80167c:	56                   	push   %esi
  80167d:	e8 23 f2 ff ff       	call   8008a5 <strlen>
  801682:	83 c4 10             	add    $0x10,%esp
  801685:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80168a:	7f 6c                	jg     8016f8 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  80168c:	83 ec 0c             	sub    $0xc,%esp
  80168f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801692:	50                   	push   %eax
  801693:	e8 bd f8 ff ff       	call   800f55 <fd_alloc>
  801698:	89 c3                	mov    %eax,%ebx
  80169a:	83 c4 10             	add    $0x10,%esp
  80169d:	85 c0                	test   %eax,%eax
  80169f:	78 3c                	js     8016dd <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  8016a1:	83 ec 08             	sub    $0x8,%esp
  8016a4:	56                   	push   %esi
  8016a5:	68 00 50 80 00       	push   $0x805000
  8016aa:	e8 31 f2 ff ff       	call   8008e0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8016af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016b2:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8016b7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016ba:	b8 01 00 00 00       	mov    $0x1,%eax
  8016bf:	e8 f6 fd ff ff       	call   8014ba <fsipc>
  8016c4:	89 c3                	mov    %eax,%ebx
  8016c6:	83 c4 10             	add    $0x10,%esp
  8016c9:	85 c0                	test   %eax,%eax
  8016cb:	78 19                	js     8016e6 <open+0x75>
	return fd2num(fd);
  8016cd:	83 ec 0c             	sub    $0xc,%esp
  8016d0:	ff 75 f4             	push   -0xc(%ebp)
  8016d3:	e8 56 f8 ff ff       	call   800f2e <fd2num>
  8016d8:	89 c3                	mov    %eax,%ebx
  8016da:	83 c4 10             	add    $0x10,%esp
}
  8016dd:	89 d8                	mov    %ebx,%eax
  8016df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016e2:	5b                   	pop    %ebx
  8016e3:	5e                   	pop    %esi
  8016e4:	5d                   	pop    %ebp
  8016e5:	c3                   	ret    
		fd_close(fd, 0);
  8016e6:	83 ec 08             	sub    $0x8,%esp
  8016e9:	6a 00                	push   $0x0
  8016eb:	ff 75 f4             	push   -0xc(%ebp)
  8016ee:	e8 58 f9 ff ff       	call   80104b <fd_close>
		return r;
  8016f3:	83 c4 10             	add    $0x10,%esp
  8016f6:	eb e5                	jmp    8016dd <open+0x6c>
		return -E_BAD_PATH;
  8016f8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8016fd:	eb de                	jmp    8016dd <open+0x6c>

008016ff <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801705:	ba 00 00 00 00       	mov    $0x0,%edx
  80170a:	b8 08 00 00 00       	mov    $0x8,%eax
  80170f:	e8 a6 fd ff ff       	call   8014ba <fsipc>
}
  801714:	c9                   	leave  
  801715:	c3                   	ret    

00801716 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80171c:	68 6f 28 80 00       	push   $0x80286f
  801721:	ff 75 0c             	push   0xc(%ebp)
  801724:	e8 b7 f1 ff ff       	call   8008e0 <strcpy>
	return 0;
}
  801729:	b8 00 00 00 00       	mov    $0x0,%eax
  80172e:	c9                   	leave  
  80172f:	c3                   	ret    

00801730 <devsock_close>:
{
  801730:	55                   	push   %ebp
  801731:	89 e5                	mov    %esp,%ebp
  801733:	53                   	push   %ebx
  801734:	83 ec 10             	sub    $0x10,%esp
  801737:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80173a:	53                   	push   %ebx
  80173b:	e8 f0 09 00 00       	call   802130 <pageref>
  801740:	89 c2                	mov    %eax,%edx
  801742:	83 c4 10             	add    $0x10,%esp
		return 0;
  801745:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  80174a:	83 fa 01             	cmp    $0x1,%edx
  80174d:	74 05                	je     801754 <devsock_close+0x24>
}
  80174f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801752:	c9                   	leave  
  801753:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  801754:	83 ec 0c             	sub    $0xc,%esp
  801757:	ff 73 0c             	push   0xc(%ebx)
  80175a:	e8 b7 02 00 00       	call   801a16 <nsipc_close>
  80175f:	83 c4 10             	add    $0x10,%esp
  801762:	eb eb                	jmp    80174f <devsock_close+0x1f>

00801764 <devsock_write>:
{
  801764:	55                   	push   %ebp
  801765:	89 e5                	mov    %esp,%ebp
  801767:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  80176a:	6a 00                	push   $0x0
  80176c:	ff 75 10             	push   0x10(%ebp)
  80176f:	ff 75 0c             	push   0xc(%ebp)
  801772:	8b 45 08             	mov    0x8(%ebp),%eax
  801775:	ff 70 0c             	push   0xc(%eax)
  801778:	e8 79 03 00 00       	call   801af6 <nsipc_send>
}
  80177d:	c9                   	leave  
  80177e:	c3                   	ret    

0080177f <devsock_read>:
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801785:	6a 00                	push   $0x0
  801787:	ff 75 10             	push   0x10(%ebp)
  80178a:	ff 75 0c             	push   0xc(%ebp)
  80178d:	8b 45 08             	mov    0x8(%ebp),%eax
  801790:	ff 70 0c             	push   0xc(%eax)
  801793:	e8 ef 02 00 00       	call   801a87 <nsipc_recv>
}
  801798:	c9                   	leave  
  801799:	c3                   	ret    

0080179a <fd2sockid>:
{
  80179a:	55                   	push   %ebp
  80179b:	89 e5                	mov    %esp,%ebp
  80179d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  8017a0:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8017a3:	52                   	push   %edx
  8017a4:	50                   	push   %eax
  8017a5:	e8 fb f7 ff ff       	call   800fa5 <fd_lookup>
  8017aa:	83 c4 10             	add    $0x10,%esp
  8017ad:	85 c0                	test   %eax,%eax
  8017af:	78 10                	js     8017c1 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  8017b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b4:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8017ba:	39 08                	cmp    %ecx,(%eax)
  8017bc:	75 05                	jne    8017c3 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  8017be:	8b 40 0c             	mov    0xc(%eax),%eax
}
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    
		return -E_NOT_SUPP;
  8017c3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017c8:	eb f7                	jmp    8017c1 <fd2sockid+0x27>

008017ca <alloc_sockfd>:
{
  8017ca:	55                   	push   %ebp
  8017cb:	89 e5                	mov    %esp,%ebp
  8017cd:	56                   	push   %esi
  8017ce:	53                   	push   %ebx
  8017cf:	83 ec 1c             	sub    $0x1c,%esp
  8017d2:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  8017d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017d7:	50                   	push   %eax
  8017d8:	e8 78 f7 ff ff       	call   800f55 <fd_alloc>
  8017dd:	89 c3                	mov    %eax,%ebx
  8017df:	83 c4 10             	add    $0x10,%esp
  8017e2:	85 c0                	test   %eax,%eax
  8017e4:	78 43                	js     801829 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  8017e6:	83 ec 04             	sub    $0x4,%esp
  8017e9:	68 07 04 00 00       	push   $0x407
  8017ee:	ff 75 f4             	push   -0xc(%ebp)
  8017f1:	6a 00                	push   $0x0
  8017f3:	e8 e4 f4 ff ff       	call   800cdc <sys_page_alloc>
  8017f8:	89 c3                	mov    %eax,%ebx
  8017fa:	83 c4 10             	add    $0x10,%esp
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	78 28                	js     801829 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  801801:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801804:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80180a:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80180c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80180f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801816:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801819:	83 ec 0c             	sub    $0xc,%esp
  80181c:	50                   	push   %eax
  80181d:	e8 0c f7 ff ff       	call   800f2e <fd2num>
  801822:	89 c3                	mov    %eax,%ebx
  801824:	83 c4 10             	add    $0x10,%esp
  801827:	eb 0c                	jmp    801835 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  801829:	83 ec 0c             	sub    $0xc,%esp
  80182c:	56                   	push   %esi
  80182d:	e8 e4 01 00 00       	call   801a16 <nsipc_close>
		return r;
  801832:	83 c4 10             	add    $0x10,%esp
}
  801835:	89 d8                	mov    %ebx,%eax
  801837:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80183a:	5b                   	pop    %ebx
  80183b:	5e                   	pop    %esi
  80183c:	5d                   	pop    %ebp
  80183d:	c3                   	ret    

0080183e <accept>:
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801844:	8b 45 08             	mov    0x8(%ebp),%eax
  801847:	e8 4e ff ff ff       	call   80179a <fd2sockid>
  80184c:	85 c0                	test   %eax,%eax
  80184e:	78 1b                	js     80186b <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801850:	83 ec 04             	sub    $0x4,%esp
  801853:	ff 75 10             	push   0x10(%ebp)
  801856:	ff 75 0c             	push   0xc(%ebp)
  801859:	50                   	push   %eax
  80185a:	e8 0e 01 00 00       	call   80196d <nsipc_accept>
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	85 c0                	test   %eax,%eax
  801864:	78 05                	js     80186b <accept+0x2d>
	return alloc_sockfd(r);
  801866:	e8 5f ff ff ff       	call   8017ca <alloc_sockfd>
}
  80186b:	c9                   	leave  
  80186c:	c3                   	ret    

0080186d <bind>:
{
  80186d:	55                   	push   %ebp
  80186e:	89 e5                	mov    %esp,%ebp
  801870:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801873:	8b 45 08             	mov    0x8(%ebp),%eax
  801876:	e8 1f ff ff ff       	call   80179a <fd2sockid>
  80187b:	85 c0                	test   %eax,%eax
  80187d:	78 12                	js     801891 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  80187f:	83 ec 04             	sub    $0x4,%esp
  801882:	ff 75 10             	push   0x10(%ebp)
  801885:	ff 75 0c             	push   0xc(%ebp)
  801888:	50                   	push   %eax
  801889:	e8 31 01 00 00       	call   8019bf <nsipc_bind>
  80188e:	83 c4 10             	add    $0x10,%esp
}
  801891:	c9                   	leave  
  801892:	c3                   	ret    

00801893 <shutdown>:
{
  801893:	55                   	push   %ebp
  801894:	89 e5                	mov    %esp,%ebp
  801896:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  801899:	8b 45 08             	mov    0x8(%ebp),%eax
  80189c:	e8 f9 fe ff ff       	call   80179a <fd2sockid>
  8018a1:	85 c0                	test   %eax,%eax
  8018a3:	78 0f                	js     8018b4 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  8018a5:	83 ec 08             	sub    $0x8,%esp
  8018a8:	ff 75 0c             	push   0xc(%ebp)
  8018ab:	50                   	push   %eax
  8018ac:	e8 43 01 00 00       	call   8019f4 <nsipc_shutdown>
  8018b1:	83 c4 10             	add    $0x10,%esp
}
  8018b4:	c9                   	leave  
  8018b5:	c3                   	ret    

008018b6 <connect>:
{
  8018b6:	55                   	push   %ebp
  8018b7:	89 e5                	mov    %esp,%ebp
  8018b9:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8018bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bf:	e8 d6 fe ff ff       	call   80179a <fd2sockid>
  8018c4:	85 c0                	test   %eax,%eax
  8018c6:	78 12                	js     8018da <connect+0x24>
	return nsipc_connect(r, name, namelen);
  8018c8:	83 ec 04             	sub    $0x4,%esp
  8018cb:	ff 75 10             	push   0x10(%ebp)
  8018ce:	ff 75 0c             	push   0xc(%ebp)
  8018d1:	50                   	push   %eax
  8018d2:	e8 59 01 00 00       	call   801a30 <nsipc_connect>
  8018d7:	83 c4 10             	add    $0x10,%esp
}
  8018da:	c9                   	leave  
  8018db:	c3                   	ret    

008018dc <listen>:
{
  8018dc:	55                   	push   %ebp
  8018dd:	89 e5                	mov    %esp,%ebp
  8018df:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  8018e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e5:	e8 b0 fe ff ff       	call   80179a <fd2sockid>
  8018ea:	85 c0                	test   %eax,%eax
  8018ec:	78 0f                	js     8018fd <listen+0x21>
	return nsipc_listen(r, backlog);
  8018ee:	83 ec 08             	sub    $0x8,%esp
  8018f1:	ff 75 0c             	push   0xc(%ebp)
  8018f4:	50                   	push   %eax
  8018f5:	e8 6b 01 00 00       	call   801a65 <nsipc_listen>
  8018fa:	83 c4 10             	add    $0x10,%esp
}
  8018fd:	c9                   	leave  
  8018fe:	c3                   	ret    

008018ff <socket>:

int
socket(int domain, int type, int protocol)
{
  8018ff:	55                   	push   %ebp
  801900:	89 e5                	mov    %esp,%ebp
  801902:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801905:	ff 75 10             	push   0x10(%ebp)
  801908:	ff 75 0c             	push   0xc(%ebp)
  80190b:	ff 75 08             	push   0x8(%ebp)
  80190e:	e8 41 02 00 00       	call   801b54 <nsipc_socket>
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	85 c0                	test   %eax,%eax
  801918:	78 05                	js     80191f <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80191a:	e8 ab fe ff ff       	call   8017ca <alloc_sockfd>
}
  80191f:	c9                   	leave  
  801920:	c3                   	ret    

00801921 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	53                   	push   %ebx
  801925:	83 ec 04             	sub    $0x4,%esp
  801928:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80192a:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  801931:	74 26                	je     801959 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801933:	6a 07                	push   $0x7
  801935:	68 00 70 80 00       	push   $0x807000
  80193a:	53                   	push   %ebx
  80193b:	ff 35 00 80 80 00    	push   0x808000
  801941:	e8 5d 07 00 00       	call   8020a3 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801946:	83 c4 0c             	add    $0xc,%esp
  801949:	6a 00                	push   $0x0
  80194b:	6a 00                	push   $0x0
  80194d:	6a 00                	push   $0x0
  80194f:	e8 e8 06 00 00       	call   80203c <ipc_recv>
}
  801954:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801957:	c9                   	leave  
  801958:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801959:	83 ec 0c             	sub    $0xc,%esp
  80195c:	6a 02                	push   $0x2
  80195e:	e8 94 07 00 00       	call   8020f7 <ipc_find_env>
  801963:	a3 00 80 80 00       	mov    %eax,0x808000
  801968:	83 c4 10             	add    $0x10,%esp
  80196b:	eb c6                	jmp    801933 <nsipc+0x12>

0080196d <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80196d:	55                   	push   %ebp
  80196e:	89 e5                	mov    %esp,%ebp
  801970:	56                   	push   %esi
  801971:	53                   	push   %ebx
  801972:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801975:	8b 45 08             	mov    0x8(%ebp),%eax
  801978:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80197d:	8b 06                	mov    (%esi),%eax
  80197f:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801984:	b8 01 00 00 00       	mov    $0x1,%eax
  801989:	e8 93 ff ff ff       	call   801921 <nsipc>
  80198e:	89 c3                	mov    %eax,%ebx
  801990:	85 c0                	test   %eax,%eax
  801992:	79 09                	jns    80199d <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  801994:	89 d8                	mov    %ebx,%eax
  801996:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801999:	5b                   	pop    %ebx
  80199a:	5e                   	pop    %esi
  80199b:	5d                   	pop    %ebp
  80199c:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  80199d:	83 ec 04             	sub    $0x4,%esp
  8019a0:	ff 35 10 70 80 00    	push   0x807010
  8019a6:	68 00 70 80 00       	push   $0x807000
  8019ab:	ff 75 0c             	push   0xc(%ebp)
  8019ae:	e8 c3 f0 ff ff       	call   800a76 <memmove>
		*addrlen = ret->ret_addrlen;
  8019b3:	a1 10 70 80 00       	mov    0x807010,%eax
  8019b8:	89 06                	mov    %eax,(%esi)
  8019ba:	83 c4 10             	add    $0x10,%esp
	return r;
  8019bd:	eb d5                	jmp    801994 <nsipc_accept+0x27>

008019bf <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019bf:	55                   	push   %ebp
  8019c0:	89 e5                	mov    %esp,%ebp
  8019c2:	53                   	push   %ebx
  8019c3:	83 ec 08             	sub    $0x8,%esp
  8019c6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8019c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8019cc:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8019d1:	53                   	push   %ebx
  8019d2:	ff 75 0c             	push   0xc(%ebp)
  8019d5:	68 04 70 80 00       	push   $0x807004
  8019da:	e8 97 f0 ff ff       	call   800a76 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  8019df:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  8019e5:	b8 02 00 00 00       	mov    $0x2,%eax
  8019ea:	e8 32 ff ff ff       	call   801921 <nsipc>
}
  8019ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019f2:	c9                   	leave  
  8019f3:	c3                   	ret    

008019f4 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  8019f4:	55                   	push   %ebp
  8019f5:	89 e5                	mov    %esp,%ebp
  8019f7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8019fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fd:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801a02:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a05:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801a0a:	b8 03 00 00 00       	mov    $0x3,%eax
  801a0f:	e8 0d ff ff ff       	call   801921 <nsipc>
}
  801a14:	c9                   	leave  
  801a15:	c3                   	ret    

00801a16 <nsipc_close>:

int
nsipc_close(int s)
{
  801a16:	55                   	push   %ebp
  801a17:	89 e5                	mov    %esp,%ebp
  801a19:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801a1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a1f:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801a24:	b8 04 00 00 00       	mov    $0x4,%eax
  801a29:	e8 f3 fe ff ff       	call   801921 <nsipc>
}
  801a2e:	c9                   	leave  
  801a2f:	c3                   	ret    

00801a30 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a30:	55                   	push   %ebp
  801a31:	89 e5                	mov    %esp,%ebp
  801a33:	53                   	push   %ebx
  801a34:	83 ec 08             	sub    $0x8,%esp
  801a37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801a3a:	8b 45 08             	mov    0x8(%ebp),%eax
  801a3d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801a42:	53                   	push   %ebx
  801a43:	ff 75 0c             	push   0xc(%ebp)
  801a46:	68 04 70 80 00       	push   $0x807004
  801a4b:	e8 26 f0 ff ff       	call   800a76 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801a50:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801a56:	b8 05 00 00 00       	mov    $0x5,%eax
  801a5b:	e8 c1 fe ff ff       	call   801921 <nsipc>
}
  801a60:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a63:	c9                   	leave  
  801a64:	c3                   	ret    

00801a65 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801a65:	55                   	push   %ebp
  801a66:	89 e5                	mov    %esp,%ebp
  801a68:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801a6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6e:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801a73:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a76:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  801a7b:	b8 06 00 00 00       	mov    $0x6,%eax
  801a80:	e8 9c fe ff ff       	call   801921 <nsipc>
}
  801a85:	c9                   	leave  
  801a86:	c3                   	ret    

00801a87 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801a87:	55                   	push   %ebp
  801a88:	89 e5                	mov    %esp,%ebp
  801a8a:	56                   	push   %esi
  801a8b:	53                   	push   %ebx
  801a8c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801a8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a92:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  801a97:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  801a9d:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa0:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801aa5:	b8 07 00 00 00       	mov    $0x7,%eax
  801aaa:	e8 72 fe ff ff       	call   801921 <nsipc>
  801aaf:	89 c3                	mov    %eax,%ebx
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	78 22                	js     801ad7 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  801ab5:	b8 3f 06 00 00       	mov    $0x63f,%eax
  801aba:	39 c6                	cmp    %eax,%esi
  801abc:	0f 4e c6             	cmovle %esi,%eax
  801abf:	39 c3                	cmp    %eax,%ebx
  801ac1:	7f 1d                	jg     801ae0 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801ac3:	83 ec 04             	sub    $0x4,%esp
  801ac6:	53                   	push   %ebx
  801ac7:	68 00 70 80 00       	push   $0x807000
  801acc:	ff 75 0c             	push   0xc(%ebp)
  801acf:	e8 a2 ef ff ff       	call   800a76 <memmove>
  801ad4:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801ad7:	89 d8                	mov    %ebx,%eax
  801ad9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801adc:	5b                   	pop    %ebx
  801add:	5e                   	pop    %esi
  801ade:	5d                   	pop    %ebp
  801adf:	c3                   	ret    
		assert(r < 1600 && r <= len);
  801ae0:	68 7b 28 80 00       	push   $0x80287b
  801ae5:	68 43 28 80 00       	push   $0x802843
  801aea:	6a 62                	push   $0x62
  801aec:	68 90 28 80 00       	push   $0x802890
  801af1:	e8 35 e7 ff ff       	call   80022b <_panic>

00801af6 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	53                   	push   %ebx
  801afa:	83 ec 04             	sub    $0x4,%esp
  801afd:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801b00:	8b 45 08             	mov    0x8(%ebp),%eax
  801b03:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  801b08:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801b0e:	7f 2e                	jg     801b3e <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801b10:	83 ec 04             	sub    $0x4,%esp
  801b13:	53                   	push   %ebx
  801b14:	ff 75 0c             	push   0xc(%ebp)
  801b17:	68 0c 70 80 00       	push   $0x80700c
  801b1c:	e8 55 ef ff ff       	call   800a76 <memmove>
	nsipcbuf.send.req_size = size;
  801b21:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  801b27:	8b 45 14             	mov    0x14(%ebp),%eax
  801b2a:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  801b2f:	b8 08 00 00 00       	mov    $0x8,%eax
  801b34:	e8 e8 fd ff ff       	call   801921 <nsipc>
}
  801b39:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b3c:	c9                   	leave  
  801b3d:	c3                   	ret    
	assert(size < 1600);
  801b3e:	68 9c 28 80 00       	push   $0x80289c
  801b43:	68 43 28 80 00       	push   $0x802843
  801b48:	6a 6d                	push   $0x6d
  801b4a:	68 90 28 80 00       	push   $0x802890
  801b4f:	e8 d7 e6 ff ff       	call   80022b <_panic>

00801b54 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801b62:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b65:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801b6a:	8b 45 10             	mov    0x10(%ebp),%eax
  801b6d:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801b72:	b8 09 00 00 00       	mov    $0x9,%eax
  801b77:	e8 a5 fd ff ff       	call   801921 <nsipc>
}
  801b7c:	c9                   	leave  
  801b7d:	c3                   	ret    

00801b7e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	56                   	push   %esi
  801b82:	53                   	push   %ebx
  801b83:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b86:	83 ec 0c             	sub    $0xc,%esp
  801b89:	ff 75 08             	push   0x8(%ebp)
  801b8c:	e8 ad f3 ff ff       	call   800f3e <fd2data>
  801b91:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b93:	83 c4 08             	add    $0x8,%esp
  801b96:	68 a8 28 80 00       	push   $0x8028a8
  801b9b:	53                   	push   %ebx
  801b9c:	e8 3f ed ff ff       	call   8008e0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ba1:	8b 46 04             	mov    0x4(%esi),%eax
  801ba4:	2b 06                	sub    (%esi),%eax
  801ba6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bac:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bb3:	00 00 00 
	stat->st_dev = &devpipe;
  801bb6:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801bbd:	30 80 00 
	return 0;
}
  801bc0:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bc8:	5b                   	pop    %ebx
  801bc9:	5e                   	pop    %esi
  801bca:	5d                   	pop    %ebp
  801bcb:	c3                   	ret    

00801bcc <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bcc:	55                   	push   %ebp
  801bcd:	89 e5                	mov    %esp,%ebp
  801bcf:	53                   	push   %ebx
  801bd0:	83 ec 0c             	sub    $0xc,%esp
  801bd3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bd6:	53                   	push   %ebx
  801bd7:	6a 00                	push   $0x0
  801bd9:	e8 83 f1 ff ff       	call   800d61 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801bde:	89 1c 24             	mov    %ebx,(%esp)
  801be1:	e8 58 f3 ff ff       	call   800f3e <fd2data>
  801be6:	83 c4 08             	add    $0x8,%esp
  801be9:	50                   	push   %eax
  801bea:	6a 00                	push   $0x0
  801bec:	e8 70 f1 ff ff       	call   800d61 <sys_page_unmap>
}
  801bf1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf4:	c9                   	leave  
  801bf5:	c3                   	ret    

00801bf6 <_pipeisclosed>:
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	57                   	push   %edi
  801bfa:	56                   	push   %esi
  801bfb:	53                   	push   %ebx
  801bfc:	83 ec 1c             	sub    $0x1c,%esp
  801bff:	89 c7                	mov    %eax,%edi
  801c01:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801c03:	a1 00 40 80 00       	mov    0x804000,%eax
  801c08:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c0b:	83 ec 0c             	sub    $0xc,%esp
  801c0e:	57                   	push   %edi
  801c0f:	e8 1c 05 00 00       	call   802130 <pageref>
  801c14:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c17:	89 34 24             	mov    %esi,(%esp)
  801c1a:	e8 11 05 00 00       	call   802130 <pageref>
		nn = thisenv->env_runs;
  801c1f:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801c25:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c28:	83 c4 10             	add    $0x10,%esp
  801c2b:	39 cb                	cmp    %ecx,%ebx
  801c2d:	74 1b                	je     801c4a <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801c2f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c32:	75 cf                	jne    801c03 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c34:	8b 42 58             	mov    0x58(%edx),%eax
  801c37:	6a 01                	push   $0x1
  801c39:	50                   	push   %eax
  801c3a:	53                   	push   %ebx
  801c3b:	68 af 28 80 00       	push   $0x8028af
  801c40:	e8 c1 e6 ff ff       	call   800306 <cprintf>
  801c45:	83 c4 10             	add    $0x10,%esp
  801c48:	eb b9                	jmp    801c03 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c4a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c4d:	0f 94 c0             	sete   %al
  801c50:	0f b6 c0             	movzbl %al,%eax
}
  801c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c56:	5b                   	pop    %ebx
  801c57:	5e                   	pop    %esi
  801c58:	5f                   	pop    %edi
  801c59:	5d                   	pop    %ebp
  801c5a:	c3                   	ret    

00801c5b <devpipe_write>:
{
  801c5b:	55                   	push   %ebp
  801c5c:	89 e5                	mov    %esp,%ebp
  801c5e:	57                   	push   %edi
  801c5f:	56                   	push   %esi
  801c60:	53                   	push   %ebx
  801c61:	83 ec 28             	sub    $0x28,%esp
  801c64:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c67:	56                   	push   %esi
  801c68:	e8 d1 f2 ff ff       	call   800f3e <fd2data>
  801c6d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c6f:	83 c4 10             	add    $0x10,%esp
  801c72:	bf 00 00 00 00       	mov    $0x0,%edi
  801c77:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c7a:	75 09                	jne    801c85 <devpipe_write+0x2a>
	return i;
  801c7c:	89 f8                	mov    %edi,%eax
  801c7e:	eb 23                	jmp    801ca3 <devpipe_write+0x48>
			sys_yield();
  801c80:	e8 38 f0 ff ff       	call   800cbd <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c85:	8b 43 04             	mov    0x4(%ebx),%eax
  801c88:	8b 0b                	mov    (%ebx),%ecx
  801c8a:	8d 51 20             	lea    0x20(%ecx),%edx
  801c8d:	39 d0                	cmp    %edx,%eax
  801c8f:	72 1a                	jb     801cab <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801c91:	89 da                	mov    %ebx,%edx
  801c93:	89 f0                	mov    %esi,%eax
  801c95:	e8 5c ff ff ff       	call   801bf6 <_pipeisclosed>
  801c9a:	85 c0                	test   %eax,%eax
  801c9c:	74 e2                	je     801c80 <devpipe_write+0x25>
				return 0;
  801c9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ca3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ca6:	5b                   	pop    %ebx
  801ca7:	5e                   	pop    %esi
  801ca8:	5f                   	pop    %edi
  801ca9:	5d                   	pop    %ebp
  801caa:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cae:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cb2:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cb5:	89 c2                	mov    %eax,%edx
  801cb7:	c1 fa 1f             	sar    $0x1f,%edx
  801cba:	89 d1                	mov    %edx,%ecx
  801cbc:	c1 e9 1b             	shr    $0x1b,%ecx
  801cbf:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cc2:	83 e2 1f             	and    $0x1f,%edx
  801cc5:	29 ca                	sub    %ecx,%edx
  801cc7:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ccb:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ccf:	83 c0 01             	add    $0x1,%eax
  801cd2:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801cd5:	83 c7 01             	add    $0x1,%edi
  801cd8:	eb 9d                	jmp    801c77 <devpipe_write+0x1c>

00801cda <devpipe_read>:
{
  801cda:	55                   	push   %ebp
  801cdb:	89 e5                	mov    %esp,%ebp
  801cdd:	57                   	push   %edi
  801cde:	56                   	push   %esi
  801cdf:	53                   	push   %ebx
  801ce0:	83 ec 18             	sub    $0x18,%esp
  801ce3:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801ce6:	57                   	push   %edi
  801ce7:	e8 52 f2 ff ff       	call   800f3e <fd2data>
  801cec:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801cee:	83 c4 10             	add    $0x10,%esp
  801cf1:	be 00 00 00 00       	mov    $0x0,%esi
  801cf6:	3b 75 10             	cmp    0x10(%ebp),%esi
  801cf9:	75 13                	jne    801d0e <devpipe_read+0x34>
	return i;
  801cfb:	89 f0                	mov    %esi,%eax
  801cfd:	eb 02                	jmp    801d01 <devpipe_read+0x27>
				return i;
  801cff:	89 f0                	mov    %esi,%eax
}
  801d01:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d04:	5b                   	pop    %ebx
  801d05:	5e                   	pop    %esi
  801d06:	5f                   	pop    %edi
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    
			sys_yield();
  801d09:	e8 af ef ff ff       	call   800cbd <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801d0e:	8b 03                	mov    (%ebx),%eax
  801d10:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d13:	75 18                	jne    801d2d <devpipe_read+0x53>
			if (i > 0)
  801d15:	85 f6                	test   %esi,%esi
  801d17:	75 e6                	jne    801cff <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801d19:	89 da                	mov    %ebx,%edx
  801d1b:	89 f8                	mov    %edi,%eax
  801d1d:	e8 d4 fe ff ff       	call   801bf6 <_pipeisclosed>
  801d22:	85 c0                	test   %eax,%eax
  801d24:	74 e3                	je     801d09 <devpipe_read+0x2f>
				return 0;
  801d26:	b8 00 00 00 00       	mov    $0x0,%eax
  801d2b:	eb d4                	jmp    801d01 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d2d:	99                   	cltd   
  801d2e:	c1 ea 1b             	shr    $0x1b,%edx
  801d31:	01 d0                	add    %edx,%eax
  801d33:	83 e0 1f             	and    $0x1f,%eax
  801d36:	29 d0                	sub    %edx,%eax
  801d38:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d40:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d43:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d46:	83 c6 01             	add    $0x1,%esi
  801d49:	eb ab                	jmp    801cf6 <devpipe_read+0x1c>

00801d4b <pipe>:
{
  801d4b:	55                   	push   %ebp
  801d4c:	89 e5                	mov    %esp,%ebp
  801d4e:	56                   	push   %esi
  801d4f:	53                   	push   %ebx
  801d50:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d56:	50                   	push   %eax
  801d57:	e8 f9 f1 ff ff       	call   800f55 <fd_alloc>
  801d5c:	89 c3                	mov    %eax,%ebx
  801d5e:	83 c4 10             	add    $0x10,%esp
  801d61:	85 c0                	test   %eax,%eax
  801d63:	0f 88 23 01 00 00    	js     801e8c <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d69:	83 ec 04             	sub    $0x4,%esp
  801d6c:	68 07 04 00 00       	push   $0x407
  801d71:	ff 75 f4             	push   -0xc(%ebp)
  801d74:	6a 00                	push   $0x0
  801d76:	e8 61 ef ff ff       	call   800cdc <sys_page_alloc>
  801d7b:	89 c3                	mov    %eax,%ebx
  801d7d:	83 c4 10             	add    $0x10,%esp
  801d80:	85 c0                	test   %eax,%eax
  801d82:	0f 88 04 01 00 00    	js     801e8c <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801d88:	83 ec 0c             	sub    $0xc,%esp
  801d8b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d8e:	50                   	push   %eax
  801d8f:	e8 c1 f1 ff ff       	call   800f55 <fd_alloc>
  801d94:	89 c3                	mov    %eax,%ebx
  801d96:	83 c4 10             	add    $0x10,%esp
  801d99:	85 c0                	test   %eax,%eax
  801d9b:	0f 88 db 00 00 00    	js     801e7c <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da1:	83 ec 04             	sub    $0x4,%esp
  801da4:	68 07 04 00 00       	push   $0x407
  801da9:	ff 75 f0             	push   -0x10(%ebp)
  801dac:	6a 00                	push   $0x0
  801dae:	e8 29 ef ff ff       	call   800cdc <sys_page_alloc>
  801db3:	89 c3                	mov    %eax,%ebx
  801db5:	83 c4 10             	add    $0x10,%esp
  801db8:	85 c0                	test   %eax,%eax
  801dba:	0f 88 bc 00 00 00    	js     801e7c <pipe+0x131>
	va = fd2data(fd0);
  801dc0:	83 ec 0c             	sub    $0xc,%esp
  801dc3:	ff 75 f4             	push   -0xc(%ebp)
  801dc6:	e8 73 f1 ff ff       	call   800f3e <fd2data>
  801dcb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dcd:	83 c4 0c             	add    $0xc,%esp
  801dd0:	68 07 04 00 00       	push   $0x407
  801dd5:	50                   	push   %eax
  801dd6:	6a 00                	push   $0x0
  801dd8:	e8 ff ee ff ff       	call   800cdc <sys_page_alloc>
  801ddd:	89 c3                	mov    %eax,%ebx
  801ddf:	83 c4 10             	add    $0x10,%esp
  801de2:	85 c0                	test   %eax,%eax
  801de4:	0f 88 82 00 00 00    	js     801e6c <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dea:	83 ec 0c             	sub    $0xc,%esp
  801ded:	ff 75 f0             	push   -0x10(%ebp)
  801df0:	e8 49 f1 ff ff       	call   800f3e <fd2data>
  801df5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801dfc:	50                   	push   %eax
  801dfd:	6a 00                	push   $0x0
  801dff:	56                   	push   %esi
  801e00:	6a 00                	push   $0x0
  801e02:	e8 18 ef ff ff       	call   800d1f <sys_page_map>
  801e07:	89 c3                	mov    %eax,%ebx
  801e09:	83 c4 20             	add    $0x20,%esp
  801e0c:	85 c0                	test   %eax,%eax
  801e0e:	78 4e                	js     801e5e <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801e10:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801e15:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e18:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801e1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e1d:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801e24:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e27:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801e29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e2c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e33:	83 ec 0c             	sub    $0xc,%esp
  801e36:	ff 75 f4             	push   -0xc(%ebp)
  801e39:	e8 f0 f0 ff ff       	call   800f2e <fd2num>
  801e3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e41:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e43:	83 c4 04             	add    $0x4,%esp
  801e46:	ff 75 f0             	push   -0x10(%ebp)
  801e49:	e8 e0 f0 ff ff       	call   800f2e <fd2num>
  801e4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e51:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e54:	83 c4 10             	add    $0x10,%esp
  801e57:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e5c:	eb 2e                	jmp    801e8c <pipe+0x141>
	sys_page_unmap(0, va);
  801e5e:	83 ec 08             	sub    $0x8,%esp
  801e61:	56                   	push   %esi
  801e62:	6a 00                	push   $0x0
  801e64:	e8 f8 ee ff ff       	call   800d61 <sys_page_unmap>
  801e69:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e6c:	83 ec 08             	sub    $0x8,%esp
  801e6f:	ff 75 f0             	push   -0x10(%ebp)
  801e72:	6a 00                	push   $0x0
  801e74:	e8 e8 ee ff ff       	call   800d61 <sys_page_unmap>
  801e79:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801e7c:	83 ec 08             	sub    $0x8,%esp
  801e7f:	ff 75 f4             	push   -0xc(%ebp)
  801e82:	6a 00                	push   $0x0
  801e84:	e8 d8 ee ff ff       	call   800d61 <sys_page_unmap>
  801e89:	83 c4 10             	add    $0x10,%esp
}
  801e8c:	89 d8                	mov    %ebx,%eax
  801e8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e91:	5b                   	pop    %ebx
  801e92:	5e                   	pop    %esi
  801e93:	5d                   	pop    %ebp
  801e94:	c3                   	ret    

00801e95 <pipeisclosed>:
{
  801e95:	55                   	push   %ebp
  801e96:	89 e5                	mov    %esp,%ebp
  801e98:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e9e:	50                   	push   %eax
  801e9f:	ff 75 08             	push   0x8(%ebp)
  801ea2:	e8 fe f0 ff ff       	call   800fa5 <fd_lookup>
  801ea7:	83 c4 10             	add    $0x10,%esp
  801eaa:	85 c0                	test   %eax,%eax
  801eac:	78 18                	js     801ec6 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801eae:	83 ec 0c             	sub    $0xc,%esp
  801eb1:	ff 75 f4             	push   -0xc(%ebp)
  801eb4:	e8 85 f0 ff ff       	call   800f3e <fd2data>
  801eb9:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801ebb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebe:	e8 33 fd ff ff       	call   801bf6 <_pipeisclosed>
  801ec3:	83 c4 10             	add    $0x10,%esp
}
  801ec6:	c9                   	leave  
  801ec7:	c3                   	ret    

00801ec8 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801ec8:	b8 00 00 00 00       	mov    $0x0,%eax
  801ecd:	c3                   	ret    

00801ece <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801ed4:	68 c7 28 80 00       	push   $0x8028c7
  801ed9:	ff 75 0c             	push   0xc(%ebp)
  801edc:	e8 ff e9 ff ff       	call   8008e0 <strcpy>
	return 0;
}
  801ee1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee6:	c9                   	leave  
  801ee7:	c3                   	ret    

00801ee8 <devcons_write>:
{
  801ee8:	55                   	push   %ebp
  801ee9:	89 e5                	mov    %esp,%ebp
  801eeb:	57                   	push   %edi
  801eec:	56                   	push   %esi
  801eed:	53                   	push   %ebx
  801eee:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801ef4:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801ef9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801eff:	eb 2e                	jmp    801f2f <devcons_write+0x47>
		m = n - tot;
  801f01:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f04:	29 f3                	sub    %esi,%ebx
  801f06:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801f0b:	39 c3                	cmp    %eax,%ebx
  801f0d:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f10:	83 ec 04             	sub    $0x4,%esp
  801f13:	53                   	push   %ebx
  801f14:	89 f0                	mov    %esi,%eax
  801f16:	03 45 0c             	add    0xc(%ebp),%eax
  801f19:	50                   	push   %eax
  801f1a:	57                   	push   %edi
  801f1b:	e8 56 eb ff ff       	call   800a76 <memmove>
		sys_cputs(buf, m);
  801f20:	83 c4 08             	add    $0x8,%esp
  801f23:	53                   	push   %ebx
  801f24:	57                   	push   %edi
  801f25:	e8 f6 ec ff ff       	call   800c20 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f2a:	01 de                	add    %ebx,%esi
  801f2c:	83 c4 10             	add    $0x10,%esp
  801f2f:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f32:	72 cd                	jb     801f01 <devcons_write+0x19>
}
  801f34:	89 f0                	mov    %esi,%eax
  801f36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f39:	5b                   	pop    %ebx
  801f3a:	5e                   	pop    %esi
  801f3b:	5f                   	pop    %edi
  801f3c:	5d                   	pop    %ebp
  801f3d:	c3                   	ret    

00801f3e <devcons_read>:
{
  801f3e:	55                   	push   %ebp
  801f3f:	89 e5                	mov    %esp,%ebp
  801f41:	83 ec 08             	sub    $0x8,%esp
  801f44:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f49:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f4d:	75 07                	jne    801f56 <devcons_read+0x18>
  801f4f:	eb 1f                	jmp    801f70 <devcons_read+0x32>
		sys_yield();
  801f51:	e8 67 ed ff ff       	call   800cbd <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801f56:	e8 e3 ec ff ff       	call   800c3e <sys_cgetc>
  801f5b:	85 c0                	test   %eax,%eax
  801f5d:	74 f2                	je     801f51 <devcons_read+0x13>
	if (c < 0)
  801f5f:	78 0f                	js     801f70 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801f61:	83 f8 04             	cmp    $0x4,%eax
  801f64:	74 0c                	je     801f72 <devcons_read+0x34>
	*(char*)vbuf = c;
  801f66:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f69:	88 02                	mov    %al,(%edx)
	return 1;
  801f6b:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801f70:	c9                   	leave  
  801f71:	c3                   	ret    
		return 0;
  801f72:	b8 00 00 00 00       	mov    $0x0,%eax
  801f77:	eb f7                	jmp    801f70 <devcons_read+0x32>

00801f79 <cputchar>:
{
  801f79:	55                   	push   %ebp
  801f7a:	89 e5                	mov    %esp,%ebp
  801f7c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f82:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f85:	6a 01                	push   $0x1
  801f87:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f8a:	50                   	push   %eax
  801f8b:	e8 90 ec ff ff       	call   800c20 <sys_cputs>
}
  801f90:	83 c4 10             	add    $0x10,%esp
  801f93:	c9                   	leave  
  801f94:	c3                   	ret    

00801f95 <getchar>:
{
  801f95:	55                   	push   %ebp
  801f96:	89 e5                	mov    %esp,%ebp
  801f98:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f9b:	6a 01                	push   $0x1
  801f9d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fa0:	50                   	push   %eax
  801fa1:	6a 00                	push   $0x0
  801fa3:	e8 66 f2 ff ff       	call   80120e <read>
	if (r < 0)
  801fa8:	83 c4 10             	add    $0x10,%esp
  801fab:	85 c0                	test   %eax,%eax
  801fad:	78 06                	js     801fb5 <getchar+0x20>
	if (r < 1)
  801faf:	74 06                	je     801fb7 <getchar+0x22>
	return c;
  801fb1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801fb5:	c9                   	leave  
  801fb6:	c3                   	ret    
		return -E_EOF;
  801fb7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801fbc:	eb f7                	jmp    801fb5 <getchar+0x20>

00801fbe <iscons>:
{
  801fbe:	55                   	push   %ebp
  801fbf:	89 e5                	mov    %esp,%ebp
  801fc1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fc4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc7:	50                   	push   %eax
  801fc8:	ff 75 08             	push   0x8(%ebp)
  801fcb:	e8 d5 ef ff ff       	call   800fa5 <fd_lookup>
  801fd0:	83 c4 10             	add    $0x10,%esp
  801fd3:	85 c0                	test   %eax,%eax
  801fd5:	78 11                	js     801fe8 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fda:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801fe0:	39 10                	cmp    %edx,(%eax)
  801fe2:	0f 94 c0             	sete   %al
  801fe5:	0f b6 c0             	movzbl %al,%eax
}
  801fe8:	c9                   	leave  
  801fe9:	c3                   	ret    

00801fea <opencons>:
{
  801fea:	55                   	push   %ebp
  801feb:	89 e5                	mov    %esp,%ebp
  801fed:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801ff0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ff3:	50                   	push   %eax
  801ff4:	e8 5c ef ff ff       	call   800f55 <fd_alloc>
  801ff9:	83 c4 10             	add    $0x10,%esp
  801ffc:	85 c0                	test   %eax,%eax
  801ffe:	78 3a                	js     80203a <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802000:	83 ec 04             	sub    $0x4,%esp
  802003:	68 07 04 00 00       	push   $0x407
  802008:	ff 75 f4             	push   -0xc(%ebp)
  80200b:	6a 00                	push   $0x0
  80200d:	e8 ca ec ff ff       	call   800cdc <sys_page_alloc>
  802012:	83 c4 10             	add    $0x10,%esp
  802015:	85 c0                	test   %eax,%eax
  802017:	78 21                	js     80203a <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  802019:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80201c:	8b 15 58 30 80 00    	mov    0x803058,%edx
  802022:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802024:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802027:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80202e:	83 ec 0c             	sub    $0xc,%esp
  802031:	50                   	push   %eax
  802032:	e8 f7 ee ff ff       	call   800f2e <fd2num>
  802037:	83 c4 10             	add    $0x10,%esp
}
  80203a:	c9                   	leave  
  80203b:	c3                   	ret    

0080203c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80203c:	55                   	push   %ebp
  80203d:	89 e5                	mov    %esp,%ebp
  80203f:	56                   	push   %esi
  802040:	53                   	push   %ebx
  802041:	8b 75 08             	mov    0x8(%ebp),%esi
  802044:	8b 45 0c             	mov    0xc(%ebp),%eax
  802047:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  80204a:	85 c0                	test   %eax,%eax
  80204c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802051:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  802054:	83 ec 0c             	sub    $0xc,%esp
  802057:	50                   	push   %eax
  802058:	e8 2f ee ff ff       	call   800e8c <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  80205d:	83 c4 10             	add    $0x10,%esp
  802060:	85 f6                	test   %esi,%esi
  802062:	74 14                	je     802078 <ipc_recv+0x3c>
  802064:	ba 00 00 00 00       	mov    $0x0,%edx
  802069:	85 c0                	test   %eax,%eax
  80206b:	78 09                	js     802076 <ipc_recv+0x3a>
  80206d:	8b 15 00 40 80 00    	mov    0x804000,%edx
  802073:	8b 52 74             	mov    0x74(%edx),%edx
  802076:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  802078:	85 db                	test   %ebx,%ebx
  80207a:	74 14                	je     802090 <ipc_recv+0x54>
  80207c:	ba 00 00 00 00       	mov    $0x0,%edx
  802081:	85 c0                	test   %eax,%eax
  802083:	78 09                	js     80208e <ipc_recv+0x52>
  802085:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80208b:	8b 52 78             	mov    0x78(%edx),%edx
  80208e:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  802090:	85 c0                	test   %eax,%eax
  802092:	78 08                	js     80209c <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  802094:	a1 00 40 80 00       	mov    0x804000,%eax
  802099:	8b 40 70             	mov    0x70(%eax),%eax
}
  80209c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80209f:	5b                   	pop    %ebx
  8020a0:	5e                   	pop    %esi
  8020a1:	5d                   	pop    %ebp
  8020a2:	c3                   	ret    

008020a3 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020a3:	55                   	push   %ebp
  8020a4:	89 e5                	mov    %esp,%ebp
  8020a6:	57                   	push   %edi
  8020a7:	56                   	push   %esi
  8020a8:	53                   	push   %ebx
  8020a9:	83 ec 0c             	sub    $0xc,%esp
  8020ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020af:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  8020b5:	85 db                	test   %ebx,%ebx
  8020b7:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8020bc:	0f 44 d8             	cmove  %eax,%ebx
  8020bf:	eb 05                	jmp    8020c6 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8020c1:	e8 f7 eb ff ff       	call   800cbd <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  8020c6:	ff 75 14             	push   0x14(%ebp)
  8020c9:	53                   	push   %ebx
  8020ca:	56                   	push   %esi
  8020cb:	57                   	push   %edi
  8020cc:	e8 98 ed ff ff       	call   800e69 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  8020d1:	83 c4 10             	add    $0x10,%esp
  8020d4:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020d7:	74 e8                	je     8020c1 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8020d9:	85 c0                	test   %eax,%eax
  8020db:	78 08                	js     8020e5 <ipc_send+0x42>
	}while (r<0);

}
  8020dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020e0:	5b                   	pop    %ebx
  8020e1:	5e                   	pop    %esi
  8020e2:	5f                   	pop    %edi
  8020e3:	5d                   	pop    %ebp
  8020e4:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  8020e5:	50                   	push   %eax
  8020e6:	68 d3 28 80 00       	push   $0x8028d3
  8020eb:	6a 3d                	push   $0x3d
  8020ed:	68 e7 28 80 00       	push   $0x8028e7
  8020f2:	e8 34 e1 ff ff       	call   80022b <_panic>

008020f7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020f7:	55                   	push   %ebp
  8020f8:	89 e5                	mov    %esp,%ebp
  8020fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8020fd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802102:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802105:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80210b:	8b 52 50             	mov    0x50(%edx),%edx
  80210e:	39 ca                	cmp    %ecx,%edx
  802110:	74 11                	je     802123 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802112:	83 c0 01             	add    $0x1,%eax
  802115:	3d 00 04 00 00       	cmp    $0x400,%eax
  80211a:	75 e6                	jne    802102 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  80211c:	b8 00 00 00 00       	mov    $0x0,%eax
  802121:	eb 0b                	jmp    80212e <ipc_find_env+0x37>
			return envs[i].env_id;
  802123:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802126:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80212b:	8b 40 48             	mov    0x48(%eax),%eax
}
  80212e:	5d                   	pop    %ebp
  80212f:	c3                   	ret    

00802130 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802130:	55                   	push   %ebp
  802131:	89 e5                	mov    %esp,%ebp
  802133:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802136:	89 c2                	mov    %eax,%edx
  802138:	c1 ea 16             	shr    $0x16,%edx
  80213b:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802142:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802147:	f6 c1 01             	test   $0x1,%cl
  80214a:	74 1c                	je     802168 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  80214c:	c1 e8 0c             	shr    $0xc,%eax
  80214f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802156:	a8 01                	test   $0x1,%al
  802158:	74 0e                	je     802168 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80215a:	c1 e8 0c             	shr    $0xc,%eax
  80215d:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802164:	ef 
  802165:	0f b7 d2             	movzwl %dx,%edx
}
  802168:	89 d0                	mov    %edx,%eax
  80216a:	5d                   	pop    %ebp
  80216b:	c3                   	ret    
  80216c:	66 90                	xchg   %ax,%ax
  80216e:	66 90                	xchg   %ax,%ax

00802170 <__udivdi3>:
  802170:	f3 0f 1e fb          	endbr32 
  802174:	55                   	push   %ebp
  802175:	57                   	push   %edi
  802176:	56                   	push   %esi
  802177:	53                   	push   %ebx
  802178:	83 ec 1c             	sub    $0x1c,%esp
  80217b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80217f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802183:	8b 74 24 34          	mov    0x34(%esp),%esi
  802187:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80218b:	85 c0                	test   %eax,%eax
  80218d:	75 19                	jne    8021a8 <__udivdi3+0x38>
  80218f:	39 f3                	cmp    %esi,%ebx
  802191:	76 4d                	jbe    8021e0 <__udivdi3+0x70>
  802193:	31 ff                	xor    %edi,%edi
  802195:	89 e8                	mov    %ebp,%eax
  802197:	89 f2                	mov    %esi,%edx
  802199:	f7 f3                	div    %ebx
  80219b:	89 fa                	mov    %edi,%edx
  80219d:	83 c4 1c             	add    $0x1c,%esp
  8021a0:	5b                   	pop    %ebx
  8021a1:	5e                   	pop    %esi
  8021a2:	5f                   	pop    %edi
  8021a3:	5d                   	pop    %ebp
  8021a4:	c3                   	ret    
  8021a5:	8d 76 00             	lea    0x0(%esi),%esi
  8021a8:	39 f0                	cmp    %esi,%eax
  8021aa:	76 14                	jbe    8021c0 <__udivdi3+0x50>
  8021ac:	31 ff                	xor    %edi,%edi
  8021ae:	31 c0                	xor    %eax,%eax
  8021b0:	89 fa                	mov    %edi,%edx
  8021b2:	83 c4 1c             	add    $0x1c,%esp
  8021b5:	5b                   	pop    %ebx
  8021b6:	5e                   	pop    %esi
  8021b7:	5f                   	pop    %edi
  8021b8:	5d                   	pop    %ebp
  8021b9:	c3                   	ret    
  8021ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021c0:	0f bd f8             	bsr    %eax,%edi
  8021c3:	83 f7 1f             	xor    $0x1f,%edi
  8021c6:	75 48                	jne    802210 <__udivdi3+0xa0>
  8021c8:	39 f0                	cmp    %esi,%eax
  8021ca:	72 06                	jb     8021d2 <__udivdi3+0x62>
  8021cc:	31 c0                	xor    %eax,%eax
  8021ce:	39 eb                	cmp    %ebp,%ebx
  8021d0:	77 de                	ja     8021b0 <__udivdi3+0x40>
  8021d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8021d7:	eb d7                	jmp    8021b0 <__udivdi3+0x40>
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	89 d9                	mov    %ebx,%ecx
  8021e2:	85 db                	test   %ebx,%ebx
  8021e4:	75 0b                	jne    8021f1 <__udivdi3+0x81>
  8021e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021eb:	31 d2                	xor    %edx,%edx
  8021ed:	f7 f3                	div    %ebx
  8021ef:	89 c1                	mov    %eax,%ecx
  8021f1:	31 d2                	xor    %edx,%edx
  8021f3:	89 f0                	mov    %esi,%eax
  8021f5:	f7 f1                	div    %ecx
  8021f7:	89 c6                	mov    %eax,%esi
  8021f9:	89 e8                	mov    %ebp,%eax
  8021fb:	89 f7                	mov    %esi,%edi
  8021fd:	f7 f1                	div    %ecx
  8021ff:	89 fa                	mov    %edi,%edx
  802201:	83 c4 1c             	add    $0x1c,%esp
  802204:	5b                   	pop    %ebx
  802205:	5e                   	pop    %esi
  802206:	5f                   	pop    %edi
  802207:	5d                   	pop    %ebp
  802208:	c3                   	ret    
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	89 f9                	mov    %edi,%ecx
  802212:	ba 20 00 00 00       	mov    $0x20,%edx
  802217:	29 fa                	sub    %edi,%edx
  802219:	d3 e0                	shl    %cl,%eax
  80221b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80221f:	89 d1                	mov    %edx,%ecx
  802221:	89 d8                	mov    %ebx,%eax
  802223:	d3 e8                	shr    %cl,%eax
  802225:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802229:	09 c1                	or     %eax,%ecx
  80222b:	89 f0                	mov    %esi,%eax
  80222d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802231:	89 f9                	mov    %edi,%ecx
  802233:	d3 e3                	shl    %cl,%ebx
  802235:	89 d1                	mov    %edx,%ecx
  802237:	d3 e8                	shr    %cl,%eax
  802239:	89 f9                	mov    %edi,%ecx
  80223b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80223f:	89 eb                	mov    %ebp,%ebx
  802241:	d3 e6                	shl    %cl,%esi
  802243:	89 d1                	mov    %edx,%ecx
  802245:	d3 eb                	shr    %cl,%ebx
  802247:	09 f3                	or     %esi,%ebx
  802249:	89 c6                	mov    %eax,%esi
  80224b:	89 f2                	mov    %esi,%edx
  80224d:	89 d8                	mov    %ebx,%eax
  80224f:	f7 74 24 08          	divl   0x8(%esp)
  802253:	89 d6                	mov    %edx,%esi
  802255:	89 c3                	mov    %eax,%ebx
  802257:	f7 64 24 0c          	mull   0xc(%esp)
  80225b:	39 d6                	cmp    %edx,%esi
  80225d:	72 19                	jb     802278 <__udivdi3+0x108>
  80225f:	89 f9                	mov    %edi,%ecx
  802261:	d3 e5                	shl    %cl,%ebp
  802263:	39 c5                	cmp    %eax,%ebp
  802265:	73 04                	jae    80226b <__udivdi3+0xfb>
  802267:	39 d6                	cmp    %edx,%esi
  802269:	74 0d                	je     802278 <__udivdi3+0x108>
  80226b:	89 d8                	mov    %ebx,%eax
  80226d:	31 ff                	xor    %edi,%edi
  80226f:	e9 3c ff ff ff       	jmp    8021b0 <__udivdi3+0x40>
  802274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802278:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80227b:	31 ff                	xor    %edi,%edi
  80227d:	e9 2e ff ff ff       	jmp    8021b0 <__udivdi3+0x40>
  802282:	66 90                	xchg   %ax,%ax
  802284:	66 90                	xchg   %ax,%ax
  802286:	66 90                	xchg   %ax,%ax
  802288:	66 90                	xchg   %ax,%ax
  80228a:	66 90                	xchg   %ax,%ax
  80228c:	66 90                	xchg   %ax,%ax
  80228e:	66 90                	xchg   %ax,%ax

00802290 <__umoddi3>:
  802290:	f3 0f 1e fb          	endbr32 
  802294:	55                   	push   %ebp
  802295:	57                   	push   %edi
  802296:	56                   	push   %esi
  802297:	53                   	push   %ebx
  802298:	83 ec 1c             	sub    $0x1c,%esp
  80229b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80229f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8022a3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8022a7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8022ab:	89 f0                	mov    %esi,%eax
  8022ad:	89 da                	mov    %ebx,%edx
  8022af:	85 ff                	test   %edi,%edi
  8022b1:	75 15                	jne    8022c8 <__umoddi3+0x38>
  8022b3:	39 dd                	cmp    %ebx,%ebp
  8022b5:	76 39                	jbe    8022f0 <__umoddi3+0x60>
  8022b7:	f7 f5                	div    %ebp
  8022b9:	89 d0                	mov    %edx,%eax
  8022bb:	31 d2                	xor    %edx,%edx
  8022bd:	83 c4 1c             	add    $0x1c,%esp
  8022c0:	5b                   	pop    %ebx
  8022c1:	5e                   	pop    %esi
  8022c2:	5f                   	pop    %edi
  8022c3:	5d                   	pop    %ebp
  8022c4:	c3                   	ret    
  8022c5:	8d 76 00             	lea    0x0(%esi),%esi
  8022c8:	39 df                	cmp    %ebx,%edi
  8022ca:	77 f1                	ja     8022bd <__umoddi3+0x2d>
  8022cc:	0f bd cf             	bsr    %edi,%ecx
  8022cf:	83 f1 1f             	xor    $0x1f,%ecx
  8022d2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8022d6:	75 40                	jne    802318 <__umoddi3+0x88>
  8022d8:	39 df                	cmp    %ebx,%edi
  8022da:	72 04                	jb     8022e0 <__umoddi3+0x50>
  8022dc:	39 f5                	cmp    %esi,%ebp
  8022de:	77 dd                	ja     8022bd <__umoddi3+0x2d>
  8022e0:	89 da                	mov    %ebx,%edx
  8022e2:	89 f0                	mov    %esi,%eax
  8022e4:	29 e8                	sub    %ebp,%eax
  8022e6:	19 fa                	sbb    %edi,%edx
  8022e8:	eb d3                	jmp    8022bd <__umoddi3+0x2d>
  8022ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f0:	89 e9                	mov    %ebp,%ecx
  8022f2:	85 ed                	test   %ebp,%ebp
  8022f4:	75 0b                	jne    802301 <__umoddi3+0x71>
  8022f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022fb:	31 d2                	xor    %edx,%edx
  8022fd:	f7 f5                	div    %ebp
  8022ff:	89 c1                	mov    %eax,%ecx
  802301:	89 d8                	mov    %ebx,%eax
  802303:	31 d2                	xor    %edx,%edx
  802305:	f7 f1                	div    %ecx
  802307:	89 f0                	mov    %esi,%eax
  802309:	f7 f1                	div    %ecx
  80230b:	89 d0                	mov    %edx,%eax
  80230d:	31 d2                	xor    %edx,%edx
  80230f:	eb ac                	jmp    8022bd <__umoddi3+0x2d>
  802311:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802318:	8b 44 24 04          	mov    0x4(%esp),%eax
  80231c:	ba 20 00 00 00       	mov    $0x20,%edx
  802321:	29 c2                	sub    %eax,%edx
  802323:	89 c1                	mov    %eax,%ecx
  802325:	89 e8                	mov    %ebp,%eax
  802327:	d3 e7                	shl    %cl,%edi
  802329:	89 d1                	mov    %edx,%ecx
  80232b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80232f:	d3 e8                	shr    %cl,%eax
  802331:	89 c1                	mov    %eax,%ecx
  802333:	8b 44 24 04          	mov    0x4(%esp),%eax
  802337:	09 f9                	or     %edi,%ecx
  802339:	89 df                	mov    %ebx,%edi
  80233b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80233f:	89 c1                	mov    %eax,%ecx
  802341:	d3 e5                	shl    %cl,%ebp
  802343:	89 d1                	mov    %edx,%ecx
  802345:	d3 ef                	shr    %cl,%edi
  802347:	89 c1                	mov    %eax,%ecx
  802349:	89 f0                	mov    %esi,%eax
  80234b:	d3 e3                	shl    %cl,%ebx
  80234d:	89 d1                	mov    %edx,%ecx
  80234f:	89 fa                	mov    %edi,%edx
  802351:	d3 e8                	shr    %cl,%eax
  802353:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802358:	09 d8                	or     %ebx,%eax
  80235a:	f7 74 24 08          	divl   0x8(%esp)
  80235e:	89 d3                	mov    %edx,%ebx
  802360:	d3 e6                	shl    %cl,%esi
  802362:	f7 e5                	mul    %ebp
  802364:	89 c7                	mov    %eax,%edi
  802366:	89 d1                	mov    %edx,%ecx
  802368:	39 d3                	cmp    %edx,%ebx
  80236a:	72 06                	jb     802372 <__umoddi3+0xe2>
  80236c:	75 0e                	jne    80237c <__umoddi3+0xec>
  80236e:	39 c6                	cmp    %eax,%esi
  802370:	73 0a                	jae    80237c <__umoddi3+0xec>
  802372:	29 e8                	sub    %ebp,%eax
  802374:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802378:	89 d1                	mov    %edx,%ecx
  80237a:	89 c7                	mov    %eax,%edi
  80237c:	89 f5                	mov    %esi,%ebp
  80237e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802382:	29 fd                	sub    %edi,%ebp
  802384:	19 cb                	sbb    %ecx,%ebx
  802386:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80238b:	89 d8                	mov    %ebx,%eax
  80238d:	d3 e0                	shl    %cl,%eax
  80238f:	89 f1                	mov    %esi,%ecx
  802391:	d3 ed                	shr    %cl,%ebp
  802393:	d3 eb                	shr    %cl,%ebx
  802395:	09 e8                	or     %ebp,%eax
  802397:	89 da                	mov    %ebx,%edx
  802399:	83 c4 1c             	add    $0x1c,%esp
  80239c:	5b                   	pop    %ebx
  80239d:	5e                   	pop    %esi
  80239e:	5f                   	pop    %edi
  80239f:	5d                   	pop    %ebp
  8023a0:	c3                   	ret    
