
obj/user/dumbfork：     文件格式 elf32-i386


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
  800045:	e8 8a 0c 00 00       	call   800cd4 <sys_page_alloc>
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
  80005f:	e8 b3 0c 00 00       	call   800d17 <sys_page_map>
  800064:	83 c4 20             	add    $0x20,%esp
  800067:	85 c0                	test   %eax,%eax
  800069:	78 42                	js     8000ad <duppage+0x7a>
		panic("sys_page_map: %e", r);
	memmove(UTEMP, addr, PGSIZE);
  80006b:	83 ec 04             	sub    $0x4,%esp
  80006e:	68 00 10 00 00       	push   $0x1000
  800073:	53                   	push   %ebx
  800074:	68 00 00 40 00       	push   $0x400000
  800079:	e8 f0 09 00 00       	call   800a6e <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80007e:	83 c4 08             	add    $0x8,%esp
  800081:	68 00 00 40 00       	push   $0x400000
  800086:	6a 00                	push   $0x0
  800088:	e8 cc 0c 00 00       	call   800d59 <sys_page_unmap>
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
  80009c:	68 e0 10 80 00       	push   $0x8010e0
  8000a1:	6a 20                	push   $0x20
  8000a3:	68 f3 10 80 00       	push   $0x8010f3
  8000a8:	e8 76 01 00 00       	call   800223 <_panic>
		panic("sys_page_map: %e", r);
  8000ad:	50                   	push   %eax
  8000ae:	68 03 11 80 00       	push   $0x801103
  8000b3:	6a 22                	push   $0x22
  8000b5:	68 f3 10 80 00       	push   $0x8010f3
  8000ba:	e8 64 01 00 00       	call   800223 <_panic>
		panic("sys_page_unmap: %e", r);
  8000bf:	50                   	push   %eax
  8000c0:	68 14 11 80 00       	push   $0x801114
  8000c5:	6a 25                	push   $0x25
  8000c7:	68 f3 10 80 00       	push   $0x8010f3
  8000cc:	e8 52 01 00 00       	call   800223 <_panic>

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
  8000ec:	e8 a5 0b 00 00       	call   800c96 <sys_getenvid>
  8000f1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000f6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000fe:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800103:	eb 57                	jmp    80015c <dumbfork+0x8b>
		panic("sys_exofork: %e", envid);
  800105:	50                   	push   %eax
  800106:	68 27 11 80 00       	push   $0x801127
  80010b:	6a 37                	push   $0x37
  80010d:	68 f3 10 80 00       	push   $0x8010f3
  800112:	e8 0c 01 00 00       	call   800223 <_panic>

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
  800130:	81 fa 08 20 80 00    	cmp    $0x802008,%edx
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
  800150:	e8 46 0c 00 00       	call   800d9b <sys_env_set_status>
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
  800164:	68 37 11 80 00       	push   $0x801137
  800169:	6a 4c                	push   $0x4c
  80016b:	68 f3 10 80 00       	push   $0x8010f3
  800170:	e8 ae 00 00 00       	call   800223 <_panic>

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
  800187:	bf 4e 11 80 00       	mov    $0x80114e,%edi
  80018c:	b8 55 11 80 00       	mov    $0x801155,%eax
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
  8001a5:	68 5b 11 80 00       	push   $0x80115b
  8001aa:	e8 4f 01 00 00       	call   8002fe <cprintf>
		sys_yield();
  8001af:	e8 01 0b 00 00       	call   800cb5 <sys_yield>
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
  8001d6:	e8 bb 0a 00 00       	call   800c96 <sys_getenvid>
  8001db:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001e0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001e3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001e8:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001ed:	85 db                	test   %ebx,%ebx
  8001ef:	7e 07                	jle    8001f8 <libmain+0x2d>
		binaryname = argv[0];
  8001f1:	8b 06                	mov    (%esi),%eax
  8001f3:	a3 00 20 80 00       	mov    %eax,0x802000

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
  800214:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800217:	6a 00                	push   $0x0
  800219:	e8 37 0a 00 00       	call   800c55 <sys_env_destroy>
}
  80021e:	83 c4 10             	add    $0x10,%esp
  800221:	c9                   	leave  
  800222:	c3                   	ret    

00800223 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	56                   	push   %esi
  800227:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800228:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80022b:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800231:	e8 60 0a 00 00       	call   800c96 <sys_getenvid>
  800236:	83 ec 0c             	sub    $0xc,%esp
  800239:	ff 75 0c             	push   0xc(%ebp)
  80023c:	ff 75 08             	push   0x8(%ebp)
  80023f:	56                   	push   %esi
  800240:	50                   	push   %eax
  800241:	68 78 11 80 00       	push   $0x801178
  800246:	e8 b3 00 00 00       	call   8002fe <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80024b:	83 c4 18             	add    $0x18,%esp
  80024e:	53                   	push   %ebx
  80024f:	ff 75 10             	push   0x10(%ebp)
  800252:	e8 56 00 00 00       	call   8002ad <vcprintf>
	cprintf("\n");
  800257:	c7 04 24 6b 11 80 00 	movl   $0x80116b,(%esp)
  80025e:	e8 9b 00 00 00       	call   8002fe <cprintf>
  800263:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800266:	cc                   	int3   
  800267:	eb fd                	jmp    800266 <_panic+0x43>

00800269 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800269:	55                   	push   %ebp
  80026a:	89 e5                	mov    %esp,%ebp
  80026c:	53                   	push   %ebx
  80026d:	83 ec 04             	sub    $0x4,%esp
  800270:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800273:	8b 13                	mov    (%ebx),%edx
  800275:	8d 42 01             	lea    0x1(%edx),%eax
  800278:	89 03                	mov    %eax,(%ebx)
  80027a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80027d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800281:	3d ff 00 00 00       	cmp    $0xff,%eax
  800286:	74 09                	je     800291 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800288:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80028c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80028f:	c9                   	leave  
  800290:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	68 ff 00 00 00       	push   $0xff
  800299:	8d 43 08             	lea    0x8(%ebx),%eax
  80029c:	50                   	push   %eax
  80029d:	e8 76 09 00 00       	call   800c18 <sys_cputs>
		b->idx = 0;
  8002a2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	eb db                	jmp    800288 <putch+0x1f>

008002ad <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8002b6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8002bd:	00 00 00 
	b.cnt = 0;
  8002c0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8002c7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8002ca:	ff 75 0c             	push   0xc(%ebp)
  8002cd:	ff 75 08             	push   0x8(%ebp)
  8002d0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8002d6:	50                   	push   %eax
  8002d7:	68 69 02 80 00       	push   $0x800269
  8002dc:	e8 14 01 00 00       	call   8003f5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002e1:	83 c4 08             	add    $0x8,%esp
  8002e4:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8002ea:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002f0:	50                   	push   %eax
  8002f1:	e8 22 09 00 00       	call   800c18 <sys_cputs>

	return b.cnt;
}
  8002f6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002fc:	c9                   	leave  
  8002fd:	c3                   	ret    

008002fe <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002fe:	55                   	push   %ebp
  8002ff:	89 e5                	mov    %esp,%ebp
  800301:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800304:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800307:	50                   	push   %eax
  800308:	ff 75 08             	push   0x8(%ebp)
  80030b:	e8 9d ff ff ff       	call   8002ad <vcprintf>
	va_end(ap);

	return cnt;
}
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	57                   	push   %edi
  800316:	56                   	push   %esi
  800317:	53                   	push   %ebx
  800318:	83 ec 1c             	sub    $0x1c,%esp
  80031b:	89 c7                	mov    %eax,%edi
  80031d:	89 d6                	mov    %edx,%esi
  80031f:	8b 45 08             	mov    0x8(%ebp),%eax
  800322:	8b 55 0c             	mov    0xc(%ebp),%edx
  800325:	89 d1                	mov    %edx,%ecx
  800327:	89 c2                	mov    %eax,%edx
  800329:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80032c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80032f:	8b 45 10             	mov    0x10(%ebp),%eax
  800332:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800335:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800338:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80033f:	39 c2                	cmp    %eax,%edx
  800341:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800344:	72 3e                	jb     800384 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800346:	83 ec 0c             	sub    $0xc,%esp
  800349:	ff 75 18             	push   0x18(%ebp)
  80034c:	83 eb 01             	sub    $0x1,%ebx
  80034f:	53                   	push   %ebx
  800350:	50                   	push   %eax
  800351:	83 ec 08             	sub    $0x8,%esp
  800354:	ff 75 e4             	push   -0x1c(%ebp)
  800357:	ff 75 e0             	push   -0x20(%ebp)
  80035a:	ff 75 dc             	push   -0x24(%ebp)
  80035d:	ff 75 d8             	push   -0x28(%ebp)
  800360:	e8 2b 0b 00 00       	call   800e90 <__udivdi3>
  800365:	83 c4 18             	add    $0x18,%esp
  800368:	52                   	push   %edx
  800369:	50                   	push   %eax
  80036a:	89 f2                	mov    %esi,%edx
  80036c:	89 f8                	mov    %edi,%eax
  80036e:	e8 9f ff ff ff       	call   800312 <printnum>
  800373:	83 c4 20             	add    $0x20,%esp
  800376:	eb 13                	jmp    80038b <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800378:	83 ec 08             	sub    $0x8,%esp
  80037b:	56                   	push   %esi
  80037c:	ff 75 18             	push   0x18(%ebp)
  80037f:	ff d7                	call   *%edi
  800381:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800384:	83 eb 01             	sub    $0x1,%ebx
  800387:	85 db                	test   %ebx,%ebx
  800389:	7f ed                	jg     800378 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80038b:	83 ec 08             	sub    $0x8,%esp
  80038e:	56                   	push   %esi
  80038f:	83 ec 04             	sub    $0x4,%esp
  800392:	ff 75 e4             	push   -0x1c(%ebp)
  800395:	ff 75 e0             	push   -0x20(%ebp)
  800398:	ff 75 dc             	push   -0x24(%ebp)
  80039b:	ff 75 d8             	push   -0x28(%ebp)
  80039e:	e8 0d 0c 00 00       	call   800fb0 <__umoddi3>
  8003a3:	83 c4 14             	add    $0x14,%esp
  8003a6:	0f be 80 9b 11 80 00 	movsbl 0x80119b(%eax),%eax
  8003ad:	50                   	push   %eax
  8003ae:	ff d7                	call   *%edi
}
  8003b0:	83 c4 10             	add    $0x10,%esp
  8003b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8003b6:	5b                   	pop    %ebx
  8003b7:	5e                   	pop    %esi
  8003b8:	5f                   	pop    %edi
  8003b9:	5d                   	pop    %ebp
  8003ba:	c3                   	ret    

008003bb <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003c1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003c5:	8b 10                	mov    (%eax),%edx
  8003c7:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ca:	73 0a                	jae    8003d6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8003cc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003cf:	89 08                	mov    %ecx,(%eax)
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d4:	88 02                	mov    %al,(%edx)
}
  8003d6:	5d                   	pop    %ebp
  8003d7:	c3                   	ret    

008003d8 <printfmt>:
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003de:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003e1:	50                   	push   %eax
  8003e2:	ff 75 10             	push   0x10(%ebp)
  8003e5:	ff 75 0c             	push   0xc(%ebp)
  8003e8:	ff 75 08             	push   0x8(%ebp)
  8003eb:	e8 05 00 00 00       	call   8003f5 <vprintfmt>
}
  8003f0:	83 c4 10             	add    $0x10,%esp
  8003f3:	c9                   	leave  
  8003f4:	c3                   	ret    

008003f5 <vprintfmt>:
{
  8003f5:	55                   	push   %ebp
  8003f6:	89 e5                	mov    %esp,%ebp
  8003f8:	57                   	push   %edi
  8003f9:	56                   	push   %esi
  8003fa:	53                   	push   %ebx
  8003fb:	83 ec 3c             	sub    $0x3c,%esp
  8003fe:	8b 75 08             	mov    0x8(%ebp),%esi
  800401:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800404:	8b 7d 10             	mov    0x10(%ebp),%edi
  800407:	eb 0a                	jmp    800413 <vprintfmt+0x1e>
			putch(ch, putdat);
  800409:	83 ec 08             	sub    $0x8,%esp
  80040c:	53                   	push   %ebx
  80040d:	50                   	push   %eax
  80040e:	ff d6                	call   *%esi
  800410:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800413:	83 c7 01             	add    $0x1,%edi
  800416:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80041a:	83 f8 25             	cmp    $0x25,%eax
  80041d:	74 0c                	je     80042b <vprintfmt+0x36>
			if (ch == '\0')
  80041f:	85 c0                	test   %eax,%eax
  800421:	75 e6                	jne    800409 <vprintfmt+0x14>
}
  800423:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800426:	5b                   	pop    %ebx
  800427:	5e                   	pop    %esi
  800428:	5f                   	pop    %edi
  800429:	5d                   	pop    %ebp
  80042a:	c3                   	ret    
		padc = ' ';
  80042b:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80042f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800436:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80043d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800444:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800449:	8d 47 01             	lea    0x1(%edi),%eax
  80044c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80044f:	0f b6 17             	movzbl (%edi),%edx
  800452:	8d 42 dd             	lea    -0x23(%edx),%eax
  800455:	3c 55                	cmp    $0x55,%al
  800457:	0f 87 bb 03 00 00    	ja     800818 <vprintfmt+0x423>
  80045d:	0f b6 c0             	movzbl %al,%eax
  800460:	ff 24 85 60 12 80 00 	jmp    *0x801260(,%eax,4)
  800467:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80046a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80046e:	eb d9                	jmp    800449 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800470:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800473:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800477:	eb d0                	jmp    800449 <vprintfmt+0x54>
  800479:	0f b6 d2             	movzbl %dl,%edx
  80047c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80047f:	b8 00 00 00 00       	mov    $0x0,%eax
  800484:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800487:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80048a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80048e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800491:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800494:	83 f9 09             	cmp    $0x9,%ecx
  800497:	77 55                	ja     8004ee <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800499:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80049c:	eb e9                	jmp    800487 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80049e:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a1:	8b 00                	mov    (%eax),%eax
  8004a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a9:	8d 40 04             	lea    0x4(%eax),%eax
  8004ac:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004af:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004b6:	79 91                	jns    800449 <vprintfmt+0x54>
				width = precision, precision = -1;
  8004b8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004be:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004c5:	eb 82                	jmp    800449 <vprintfmt+0x54>
  8004c7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004ca:	85 d2                	test   %edx,%edx
  8004cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d1:	0f 49 c2             	cmovns %edx,%eax
  8004d4:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004da:	e9 6a ff ff ff       	jmp    800449 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8004df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004e2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004e9:	e9 5b ff ff ff       	jmp    800449 <vprintfmt+0x54>
  8004ee:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f4:	eb bc                	jmp    8004b2 <vprintfmt+0xbd>
			lflag++;
  8004f6:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004fc:	e9 48 ff ff ff       	jmp    800449 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800501:	8b 45 14             	mov    0x14(%ebp),%eax
  800504:	8d 78 04             	lea    0x4(%eax),%edi
  800507:	83 ec 08             	sub    $0x8,%esp
  80050a:	53                   	push   %ebx
  80050b:	ff 30                	push   (%eax)
  80050d:	ff d6                	call   *%esi
			break;
  80050f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800512:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  800515:	e9 9d 02 00 00       	jmp    8007b7 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80051a:	8b 45 14             	mov    0x14(%ebp),%eax
  80051d:	8d 78 04             	lea    0x4(%eax),%edi
  800520:	8b 10                	mov    (%eax),%edx
  800522:	89 d0                	mov    %edx,%eax
  800524:	f7 d8                	neg    %eax
  800526:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800529:	83 f8 08             	cmp    $0x8,%eax
  80052c:	7f 23                	jg     800551 <vprintfmt+0x15c>
  80052e:	8b 14 85 c0 13 80 00 	mov    0x8013c0(,%eax,4),%edx
  800535:	85 d2                	test   %edx,%edx
  800537:	74 18                	je     800551 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800539:	52                   	push   %edx
  80053a:	68 bc 11 80 00       	push   $0x8011bc
  80053f:	53                   	push   %ebx
  800540:	56                   	push   %esi
  800541:	e8 92 fe ff ff       	call   8003d8 <printfmt>
  800546:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800549:	89 7d 14             	mov    %edi,0x14(%ebp)
  80054c:	e9 66 02 00 00       	jmp    8007b7 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800551:	50                   	push   %eax
  800552:	68 b3 11 80 00       	push   $0x8011b3
  800557:	53                   	push   %ebx
  800558:	56                   	push   %esi
  800559:	e8 7a fe ff ff       	call   8003d8 <printfmt>
  80055e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800561:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800564:	e9 4e 02 00 00       	jmp    8007b7 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	83 c0 04             	add    $0x4,%eax
  80056f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800577:	85 d2                	test   %edx,%edx
  800579:	b8 ac 11 80 00       	mov    $0x8011ac,%eax
  80057e:	0f 45 c2             	cmovne %edx,%eax
  800581:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800584:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800588:	7e 06                	jle    800590 <vprintfmt+0x19b>
  80058a:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80058e:	75 0d                	jne    80059d <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800590:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800593:	89 c7                	mov    %eax,%edi
  800595:	03 45 e0             	add    -0x20(%ebp),%eax
  800598:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80059b:	eb 55                	jmp    8005f2 <vprintfmt+0x1fd>
  80059d:	83 ec 08             	sub    $0x8,%esp
  8005a0:	ff 75 d8             	push   -0x28(%ebp)
  8005a3:	ff 75 cc             	push   -0x34(%ebp)
  8005a6:	e8 0a 03 00 00       	call   8008b5 <strnlen>
  8005ab:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005ae:	29 c1                	sub    %eax,%ecx
  8005b0:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8005b3:	83 c4 10             	add    $0x10,%esp
  8005b6:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8005b8:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8005bc:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bf:	eb 0f                	jmp    8005d0 <vprintfmt+0x1db>
					putch(padc, putdat);
  8005c1:	83 ec 08             	sub    $0x8,%esp
  8005c4:	53                   	push   %ebx
  8005c5:	ff 75 e0             	push   -0x20(%ebp)
  8005c8:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ca:	83 ef 01             	sub    $0x1,%edi
  8005cd:	83 c4 10             	add    $0x10,%esp
  8005d0:	85 ff                	test   %edi,%edi
  8005d2:	7f ed                	jg     8005c1 <vprintfmt+0x1cc>
  8005d4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005d7:	85 d2                	test   %edx,%edx
  8005d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8005de:	0f 49 c2             	cmovns %edx,%eax
  8005e1:	29 c2                	sub    %eax,%edx
  8005e3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005e6:	eb a8                	jmp    800590 <vprintfmt+0x19b>
					putch(ch, putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	53                   	push   %ebx
  8005ec:	52                   	push   %edx
  8005ed:	ff d6                	call   *%esi
  8005ef:	83 c4 10             	add    $0x10,%esp
  8005f2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005f5:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f7:	83 c7 01             	add    $0x1,%edi
  8005fa:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005fe:	0f be d0             	movsbl %al,%edx
  800601:	85 d2                	test   %edx,%edx
  800603:	74 4b                	je     800650 <vprintfmt+0x25b>
  800605:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800609:	78 06                	js     800611 <vprintfmt+0x21c>
  80060b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80060f:	78 1e                	js     80062f <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800611:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800615:	74 d1                	je     8005e8 <vprintfmt+0x1f3>
  800617:	0f be c0             	movsbl %al,%eax
  80061a:	83 e8 20             	sub    $0x20,%eax
  80061d:	83 f8 5e             	cmp    $0x5e,%eax
  800620:	76 c6                	jbe    8005e8 <vprintfmt+0x1f3>
					putch('?', putdat);
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	53                   	push   %ebx
  800626:	6a 3f                	push   $0x3f
  800628:	ff d6                	call   *%esi
  80062a:	83 c4 10             	add    $0x10,%esp
  80062d:	eb c3                	jmp    8005f2 <vprintfmt+0x1fd>
  80062f:	89 cf                	mov    %ecx,%edi
  800631:	eb 0e                	jmp    800641 <vprintfmt+0x24c>
				putch(' ', putdat);
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	53                   	push   %ebx
  800637:	6a 20                	push   $0x20
  800639:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80063b:	83 ef 01             	sub    $0x1,%edi
  80063e:	83 c4 10             	add    $0x10,%esp
  800641:	85 ff                	test   %edi,%edi
  800643:	7f ee                	jg     800633 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800645:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800648:	89 45 14             	mov    %eax,0x14(%ebp)
  80064b:	e9 67 01 00 00       	jmp    8007b7 <vprintfmt+0x3c2>
  800650:	89 cf                	mov    %ecx,%edi
  800652:	eb ed                	jmp    800641 <vprintfmt+0x24c>
	if (lflag >= 2)
  800654:	83 f9 01             	cmp    $0x1,%ecx
  800657:	7f 1b                	jg     800674 <vprintfmt+0x27f>
	else if (lflag)
  800659:	85 c9                	test   %ecx,%ecx
  80065b:	74 63                	je     8006c0 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8b 00                	mov    (%eax),%eax
  800662:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800665:	99                   	cltd   
  800666:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800669:	8b 45 14             	mov    0x14(%ebp),%eax
  80066c:	8d 40 04             	lea    0x4(%eax),%eax
  80066f:	89 45 14             	mov    %eax,0x14(%ebp)
  800672:	eb 17                	jmp    80068b <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8b 50 04             	mov    0x4(%eax),%edx
  80067a:	8b 00                	mov    (%eax),%eax
  80067c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80067f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800682:	8b 45 14             	mov    0x14(%ebp),%eax
  800685:	8d 40 08             	lea    0x8(%eax),%eax
  800688:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80068b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80068e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800691:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800696:	85 c9                	test   %ecx,%ecx
  800698:	0f 89 ff 00 00 00    	jns    80079d <vprintfmt+0x3a8>
				putch('-', putdat);
  80069e:	83 ec 08             	sub    $0x8,%esp
  8006a1:	53                   	push   %ebx
  8006a2:	6a 2d                	push   $0x2d
  8006a4:	ff d6                	call   *%esi
				num = -(long long) num;
  8006a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8006a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8006ac:	f7 da                	neg    %edx
  8006ae:	83 d1 00             	adc    $0x0,%ecx
  8006b1:	f7 d9                	neg    %ecx
  8006b3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8006b6:	bf 0a 00 00 00       	mov    $0xa,%edi
  8006bb:	e9 dd 00 00 00       	jmp    80079d <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8006c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c3:	8b 00                	mov    (%eax),%eax
  8006c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c8:	99                   	cltd   
  8006c9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8d 40 04             	lea    0x4(%eax),%eax
  8006d2:	89 45 14             	mov    %eax,0x14(%ebp)
  8006d5:	eb b4                	jmp    80068b <vprintfmt+0x296>
	if (lflag >= 2)
  8006d7:	83 f9 01             	cmp    $0x1,%ecx
  8006da:	7f 1e                	jg     8006fa <vprintfmt+0x305>
	else if (lflag)
  8006dc:	85 c9                	test   %ecx,%ecx
  8006de:	74 32                	je     800712 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8006e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e3:	8b 10                	mov    (%eax),%edx
  8006e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006ea:	8d 40 04             	lea    0x4(%eax),%eax
  8006ed:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8006f0:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8006f5:	e9 a3 00 00 00       	jmp    80079d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8006fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8006fd:	8b 10                	mov    (%eax),%edx
  8006ff:	8b 48 04             	mov    0x4(%eax),%ecx
  800702:	8d 40 08             	lea    0x8(%eax),%eax
  800705:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800708:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80070d:	e9 8b 00 00 00       	jmp    80079d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800712:	8b 45 14             	mov    0x14(%ebp),%eax
  800715:	8b 10                	mov    (%eax),%edx
  800717:	b9 00 00 00 00       	mov    $0x0,%ecx
  80071c:	8d 40 04             	lea    0x4(%eax),%eax
  80071f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800722:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800727:	eb 74                	jmp    80079d <vprintfmt+0x3a8>
	if (lflag >= 2)
  800729:	83 f9 01             	cmp    $0x1,%ecx
  80072c:	7f 1b                	jg     800749 <vprintfmt+0x354>
	else if (lflag)
  80072e:	85 c9                	test   %ecx,%ecx
  800730:	74 2c                	je     80075e <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8b 10                	mov    (%eax),%edx
  800737:	b9 00 00 00 00       	mov    $0x0,%ecx
  80073c:	8d 40 04             	lea    0x4(%eax),%eax
  80073f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800742:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800747:	eb 54                	jmp    80079d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800749:	8b 45 14             	mov    0x14(%ebp),%eax
  80074c:	8b 10                	mov    (%eax),%edx
  80074e:	8b 48 04             	mov    0x4(%eax),%ecx
  800751:	8d 40 08             	lea    0x8(%eax),%eax
  800754:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800757:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80075c:	eb 3f                	jmp    80079d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80075e:	8b 45 14             	mov    0x14(%ebp),%eax
  800761:	8b 10                	mov    (%eax),%edx
  800763:	b9 00 00 00 00       	mov    $0x0,%ecx
  800768:	8d 40 04             	lea    0x4(%eax),%eax
  80076b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80076e:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800773:	eb 28                	jmp    80079d <vprintfmt+0x3a8>
			putch('0', putdat);
  800775:	83 ec 08             	sub    $0x8,%esp
  800778:	53                   	push   %ebx
  800779:	6a 30                	push   $0x30
  80077b:	ff d6                	call   *%esi
			putch('x', putdat);
  80077d:	83 c4 08             	add    $0x8,%esp
  800780:	53                   	push   %ebx
  800781:	6a 78                	push   $0x78
  800783:	ff d6                	call   *%esi
			num = (unsigned long long)
  800785:	8b 45 14             	mov    0x14(%ebp),%eax
  800788:	8b 10                	mov    (%eax),%edx
  80078a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80078f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800792:	8d 40 04             	lea    0x4(%eax),%eax
  800795:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800798:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80079d:	83 ec 0c             	sub    $0xc,%esp
  8007a0:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8007a4:	50                   	push   %eax
  8007a5:	ff 75 e0             	push   -0x20(%ebp)
  8007a8:	57                   	push   %edi
  8007a9:	51                   	push   %ecx
  8007aa:	52                   	push   %edx
  8007ab:	89 da                	mov    %ebx,%edx
  8007ad:	89 f0                	mov    %esi,%eax
  8007af:	e8 5e fb ff ff       	call   800312 <printnum>
			break;
  8007b4:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8007b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007ba:	e9 54 fc ff ff       	jmp    800413 <vprintfmt+0x1e>
	if (lflag >= 2)
  8007bf:	83 f9 01             	cmp    $0x1,%ecx
  8007c2:	7f 1b                	jg     8007df <vprintfmt+0x3ea>
	else if (lflag)
  8007c4:	85 c9                	test   %ecx,%ecx
  8007c6:	74 2c                	je     8007f4 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8007c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cb:	8b 10                	mov    (%eax),%edx
  8007cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d2:	8d 40 04             	lea    0x4(%eax),%eax
  8007d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007d8:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8007dd:	eb be                	jmp    80079d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	8b 10                	mov    (%eax),%edx
  8007e4:	8b 48 04             	mov    0x4(%eax),%ecx
  8007e7:	8d 40 08             	lea    0x8(%eax),%eax
  8007ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8007ed:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8007f2:	eb a9                	jmp    80079d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f7:	8b 10                	mov    (%eax),%edx
  8007f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fe:	8d 40 04             	lea    0x4(%eax),%eax
  800801:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800804:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800809:	eb 92                	jmp    80079d <vprintfmt+0x3a8>
			putch(ch, putdat);
  80080b:	83 ec 08             	sub    $0x8,%esp
  80080e:	53                   	push   %ebx
  80080f:	6a 25                	push   $0x25
  800811:	ff d6                	call   *%esi
			break;
  800813:	83 c4 10             	add    $0x10,%esp
  800816:	eb 9f                	jmp    8007b7 <vprintfmt+0x3c2>
			putch('%', putdat);
  800818:	83 ec 08             	sub    $0x8,%esp
  80081b:	53                   	push   %ebx
  80081c:	6a 25                	push   $0x25
  80081e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800820:	83 c4 10             	add    $0x10,%esp
  800823:	89 f8                	mov    %edi,%eax
  800825:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800829:	74 05                	je     800830 <vprintfmt+0x43b>
  80082b:	83 e8 01             	sub    $0x1,%eax
  80082e:	eb f5                	jmp    800825 <vprintfmt+0x430>
  800830:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800833:	eb 82                	jmp    8007b7 <vprintfmt+0x3c2>

00800835 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800835:	55                   	push   %ebp
  800836:	89 e5                	mov    %esp,%ebp
  800838:	83 ec 18             	sub    $0x18,%esp
  80083b:	8b 45 08             	mov    0x8(%ebp),%eax
  80083e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800841:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800844:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800848:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80084b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800852:	85 c0                	test   %eax,%eax
  800854:	74 26                	je     80087c <vsnprintf+0x47>
  800856:	85 d2                	test   %edx,%edx
  800858:	7e 22                	jle    80087c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80085a:	ff 75 14             	push   0x14(%ebp)
  80085d:	ff 75 10             	push   0x10(%ebp)
  800860:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800863:	50                   	push   %eax
  800864:	68 bb 03 80 00       	push   $0x8003bb
  800869:	e8 87 fb ff ff       	call   8003f5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80086e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800871:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800874:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800877:	83 c4 10             	add    $0x10,%esp
}
  80087a:	c9                   	leave  
  80087b:	c3                   	ret    
		return -E_INVAL;
  80087c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800881:	eb f7                	jmp    80087a <vsnprintf+0x45>

00800883 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800889:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80088c:	50                   	push   %eax
  80088d:	ff 75 10             	push   0x10(%ebp)
  800890:	ff 75 0c             	push   0xc(%ebp)
  800893:	ff 75 08             	push   0x8(%ebp)
  800896:	e8 9a ff ff ff       	call   800835 <vsnprintf>
	va_end(ap);

	return rc;
}
  80089b:	c9                   	leave  
  80089c:	c3                   	ret    

0080089d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80089d:	55                   	push   %ebp
  80089e:	89 e5                	mov    %esp,%ebp
  8008a0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a8:	eb 03                	jmp    8008ad <strlen+0x10>
		n++;
  8008aa:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8008ad:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b1:	75 f7                	jne    8008aa <strlen+0xd>
	return n;
}
  8008b3:	5d                   	pop    %ebp
  8008b4:	c3                   	ret    

008008b5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008be:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c3:	eb 03                	jmp    8008c8 <strnlen+0x13>
		n++;
  8008c5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c8:	39 d0                	cmp    %edx,%eax
  8008ca:	74 08                	je     8008d4 <strnlen+0x1f>
  8008cc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008d0:	75 f3                	jne    8008c5 <strnlen+0x10>
  8008d2:	89 c2                	mov    %eax,%edx
	return n;
}
  8008d4:	89 d0                	mov    %edx,%eax
  8008d6:	5d                   	pop    %ebp
  8008d7:	c3                   	ret    

008008d8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008d8:	55                   	push   %ebp
  8008d9:	89 e5                	mov    %esp,%ebp
  8008db:	53                   	push   %ebx
  8008dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e7:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8008eb:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8008ee:	83 c0 01             	add    $0x1,%eax
  8008f1:	84 d2                	test   %dl,%dl
  8008f3:	75 f2                	jne    8008e7 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008f5:	89 c8                	mov    %ecx,%eax
  8008f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008fa:	c9                   	leave  
  8008fb:	c3                   	ret    

008008fc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	53                   	push   %ebx
  800900:	83 ec 10             	sub    $0x10,%esp
  800903:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800906:	53                   	push   %ebx
  800907:	e8 91 ff ff ff       	call   80089d <strlen>
  80090c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80090f:	ff 75 0c             	push   0xc(%ebp)
  800912:	01 d8                	add    %ebx,%eax
  800914:	50                   	push   %eax
  800915:	e8 be ff ff ff       	call   8008d8 <strcpy>
	return dst;
}
  80091a:	89 d8                	mov    %ebx,%eax
  80091c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80091f:	c9                   	leave  
  800920:	c3                   	ret    

00800921 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	56                   	push   %esi
  800925:	53                   	push   %ebx
  800926:	8b 75 08             	mov    0x8(%ebp),%esi
  800929:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092c:	89 f3                	mov    %esi,%ebx
  80092e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800931:	89 f0                	mov    %esi,%eax
  800933:	eb 0f                	jmp    800944 <strncpy+0x23>
		*dst++ = *src;
  800935:	83 c0 01             	add    $0x1,%eax
  800938:	0f b6 0a             	movzbl (%edx),%ecx
  80093b:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80093e:	80 f9 01             	cmp    $0x1,%cl
  800941:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800944:	39 d8                	cmp    %ebx,%eax
  800946:	75 ed                	jne    800935 <strncpy+0x14>
	}
	return ret;
}
  800948:	89 f0                	mov    %esi,%eax
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	56                   	push   %esi
  800952:	53                   	push   %ebx
  800953:	8b 75 08             	mov    0x8(%ebp),%esi
  800956:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800959:	8b 55 10             	mov    0x10(%ebp),%edx
  80095c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80095e:	85 d2                	test   %edx,%edx
  800960:	74 21                	je     800983 <strlcpy+0x35>
  800962:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800966:	89 f2                	mov    %esi,%edx
  800968:	eb 09                	jmp    800973 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80096a:	83 c1 01             	add    $0x1,%ecx
  80096d:	83 c2 01             	add    $0x1,%edx
  800970:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800973:	39 c2                	cmp    %eax,%edx
  800975:	74 09                	je     800980 <strlcpy+0x32>
  800977:	0f b6 19             	movzbl (%ecx),%ebx
  80097a:	84 db                	test   %bl,%bl
  80097c:	75 ec                	jne    80096a <strlcpy+0x1c>
  80097e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800980:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800983:	29 f0                	sub    %esi,%eax
}
  800985:	5b                   	pop    %ebx
  800986:	5e                   	pop    %esi
  800987:	5d                   	pop    %ebp
  800988:	c3                   	ret    

00800989 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800989:	55                   	push   %ebp
  80098a:	89 e5                	mov    %esp,%ebp
  80098c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800992:	eb 06                	jmp    80099a <strcmp+0x11>
		p++, q++;
  800994:	83 c1 01             	add    $0x1,%ecx
  800997:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80099a:	0f b6 01             	movzbl (%ecx),%eax
  80099d:	84 c0                	test   %al,%al
  80099f:	74 04                	je     8009a5 <strcmp+0x1c>
  8009a1:	3a 02                	cmp    (%edx),%al
  8009a3:	74 ef                	je     800994 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a5:	0f b6 c0             	movzbl %al,%eax
  8009a8:	0f b6 12             	movzbl (%edx),%edx
  8009ab:	29 d0                	sub    %edx,%eax
}
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	53                   	push   %ebx
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b9:	89 c3                	mov    %eax,%ebx
  8009bb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009be:	eb 06                	jmp    8009c6 <strncmp+0x17>
		n--, p++, q++;
  8009c0:	83 c0 01             	add    $0x1,%eax
  8009c3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009c6:	39 d8                	cmp    %ebx,%eax
  8009c8:	74 18                	je     8009e2 <strncmp+0x33>
  8009ca:	0f b6 08             	movzbl (%eax),%ecx
  8009cd:	84 c9                	test   %cl,%cl
  8009cf:	74 04                	je     8009d5 <strncmp+0x26>
  8009d1:	3a 0a                	cmp    (%edx),%cl
  8009d3:	74 eb                	je     8009c0 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d5:	0f b6 00             	movzbl (%eax),%eax
  8009d8:	0f b6 12             	movzbl (%edx),%edx
  8009db:	29 d0                	sub    %edx,%eax
}
  8009dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e0:	c9                   	leave  
  8009e1:	c3                   	ret    
		return 0;
  8009e2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009e7:	eb f4                	jmp    8009dd <strncmp+0x2e>

008009e9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009e9:	55                   	push   %ebp
  8009ea:	89 e5                	mov    %esp,%ebp
  8009ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f3:	eb 03                	jmp    8009f8 <strchr+0xf>
  8009f5:	83 c0 01             	add    $0x1,%eax
  8009f8:	0f b6 10             	movzbl (%eax),%edx
  8009fb:	84 d2                	test   %dl,%dl
  8009fd:	74 06                	je     800a05 <strchr+0x1c>
		if (*s == c)
  8009ff:	38 ca                	cmp    %cl,%dl
  800a01:	75 f2                	jne    8009f5 <strchr+0xc>
  800a03:	eb 05                	jmp    800a0a <strchr+0x21>
			return (char *) s;
	return 0;
  800a05:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0a:	5d                   	pop    %ebp
  800a0b:	c3                   	ret    

00800a0c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a16:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a19:	38 ca                	cmp    %cl,%dl
  800a1b:	74 09                	je     800a26 <strfind+0x1a>
  800a1d:	84 d2                	test   %dl,%dl
  800a1f:	74 05                	je     800a26 <strfind+0x1a>
	for (; *s; s++)
  800a21:	83 c0 01             	add    $0x1,%eax
  800a24:	eb f0                	jmp    800a16 <strfind+0xa>
			break;
	return (char *) s;
}
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	57                   	push   %edi
  800a2c:	56                   	push   %esi
  800a2d:	53                   	push   %ebx
  800a2e:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a31:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a34:	85 c9                	test   %ecx,%ecx
  800a36:	74 2f                	je     800a67 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a38:	89 f8                	mov    %edi,%eax
  800a3a:	09 c8                	or     %ecx,%eax
  800a3c:	a8 03                	test   $0x3,%al
  800a3e:	75 21                	jne    800a61 <memset+0x39>
		c &= 0xFF;
  800a40:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a44:	89 d0                	mov    %edx,%eax
  800a46:	c1 e0 08             	shl    $0x8,%eax
  800a49:	89 d3                	mov    %edx,%ebx
  800a4b:	c1 e3 18             	shl    $0x18,%ebx
  800a4e:	89 d6                	mov    %edx,%esi
  800a50:	c1 e6 10             	shl    $0x10,%esi
  800a53:	09 f3                	or     %esi,%ebx
  800a55:	09 da                	or     %ebx,%edx
  800a57:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800a59:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800a5c:	fc                   	cld    
  800a5d:	f3 ab                	rep stos %eax,%es:(%edi)
  800a5f:	eb 06                	jmp    800a67 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a64:	fc                   	cld    
  800a65:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a67:	89 f8                	mov    %edi,%eax
  800a69:	5b                   	pop    %ebx
  800a6a:	5e                   	pop    %esi
  800a6b:	5f                   	pop    %edi
  800a6c:	5d                   	pop    %ebp
  800a6d:	c3                   	ret    

00800a6e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	57                   	push   %edi
  800a72:	56                   	push   %esi
  800a73:	8b 45 08             	mov    0x8(%ebp),%eax
  800a76:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a79:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a7c:	39 c6                	cmp    %eax,%esi
  800a7e:	73 32                	jae    800ab2 <memmove+0x44>
  800a80:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a83:	39 c2                	cmp    %eax,%edx
  800a85:	76 2b                	jbe    800ab2 <memmove+0x44>
		s += n;
		d += n;
  800a87:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8a:	89 d6                	mov    %edx,%esi
  800a8c:	09 fe                	or     %edi,%esi
  800a8e:	09 ce                	or     %ecx,%esi
  800a90:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a96:	75 0e                	jne    800aa6 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a98:	83 ef 04             	sub    $0x4,%edi
  800a9b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a9e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800aa1:	fd                   	std    
  800aa2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800aa4:	eb 09                	jmp    800aaf <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aa6:	83 ef 01             	sub    $0x1,%edi
  800aa9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800aac:	fd                   	std    
  800aad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aaf:	fc                   	cld    
  800ab0:	eb 1a                	jmp    800acc <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab2:	89 f2                	mov    %esi,%edx
  800ab4:	09 c2                	or     %eax,%edx
  800ab6:	09 ca                	or     %ecx,%edx
  800ab8:	f6 c2 03             	test   $0x3,%dl
  800abb:	75 0a                	jne    800ac7 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800abd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ac0:	89 c7                	mov    %eax,%edi
  800ac2:	fc                   	cld    
  800ac3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ac5:	eb 05                	jmp    800acc <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800ac7:	89 c7                	mov    %eax,%edi
  800ac9:	fc                   	cld    
  800aca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800acc:	5e                   	pop    %esi
  800acd:	5f                   	pop    %edi
  800ace:	5d                   	pop    %ebp
  800acf:	c3                   	ret    

00800ad0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad6:	ff 75 10             	push   0x10(%ebp)
  800ad9:	ff 75 0c             	push   0xc(%ebp)
  800adc:	ff 75 08             	push   0x8(%ebp)
  800adf:	e8 8a ff ff ff       	call   800a6e <memmove>
}
  800ae4:	c9                   	leave  
  800ae5:	c3                   	ret    

00800ae6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  800aee:	8b 55 0c             	mov    0xc(%ebp),%edx
  800af1:	89 c6                	mov    %eax,%esi
  800af3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af6:	eb 06                	jmp    800afe <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800af8:	83 c0 01             	add    $0x1,%eax
  800afb:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800afe:	39 f0                	cmp    %esi,%eax
  800b00:	74 14                	je     800b16 <memcmp+0x30>
		if (*s1 != *s2)
  800b02:	0f b6 08             	movzbl (%eax),%ecx
  800b05:	0f b6 1a             	movzbl (%edx),%ebx
  800b08:	38 d9                	cmp    %bl,%cl
  800b0a:	74 ec                	je     800af8 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800b0c:	0f b6 c1             	movzbl %cl,%eax
  800b0f:	0f b6 db             	movzbl %bl,%ebx
  800b12:	29 d8                	sub    %ebx,%eax
  800b14:	eb 05                	jmp    800b1b <memcmp+0x35>
	}

	return 0;
  800b16:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b1b:	5b                   	pop    %ebx
  800b1c:	5e                   	pop    %esi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    

00800b1f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
  800b22:	8b 45 08             	mov    0x8(%ebp),%eax
  800b25:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b28:	89 c2                	mov    %eax,%edx
  800b2a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b2d:	eb 03                	jmp    800b32 <memfind+0x13>
  800b2f:	83 c0 01             	add    $0x1,%eax
  800b32:	39 d0                	cmp    %edx,%eax
  800b34:	73 04                	jae    800b3a <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b36:	38 08                	cmp    %cl,(%eax)
  800b38:	75 f5                	jne    800b2f <memfind+0x10>
			break;
	return (void *) s;
}
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	8b 55 08             	mov    0x8(%ebp),%edx
  800b45:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b48:	eb 03                	jmp    800b4d <strtol+0x11>
		s++;
  800b4a:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800b4d:	0f b6 02             	movzbl (%edx),%eax
  800b50:	3c 20                	cmp    $0x20,%al
  800b52:	74 f6                	je     800b4a <strtol+0xe>
  800b54:	3c 09                	cmp    $0x9,%al
  800b56:	74 f2                	je     800b4a <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800b58:	3c 2b                	cmp    $0x2b,%al
  800b5a:	74 2a                	je     800b86 <strtol+0x4a>
	int neg = 0;
  800b5c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800b61:	3c 2d                	cmp    $0x2d,%al
  800b63:	74 2b                	je     800b90 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b65:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800b6b:	75 0f                	jne    800b7c <strtol+0x40>
  800b6d:	80 3a 30             	cmpb   $0x30,(%edx)
  800b70:	74 28                	je     800b9a <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800b72:	85 db                	test   %ebx,%ebx
  800b74:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b79:	0f 44 d8             	cmove  %eax,%ebx
  800b7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b81:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b84:	eb 46                	jmp    800bcc <strtol+0x90>
		s++;
  800b86:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800b89:	bf 00 00 00 00       	mov    $0x0,%edi
  800b8e:	eb d5                	jmp    800b65 <strtol+0x29>
		s++, neg = 1;
  800b90:	83 c2 01             	add    $0x1,%edx
  800b93:	bf 01 00 00 00       	mov    $0x1,%edi
  800b98:	eb cb                	jmp    800b65 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b9a:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b9e:	74 0e                	je     800bae <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ba0:	85 db                	test   %ebx,%ebx
  800ba2:	75 d8                	jne    800b7c <strtol+0x40>
		s++, base = 8;
  800ba4:	83 c2 01             	add    $0x1,%edx
  800ba7:	bb 08 00 00 00       	mov    $0x8,%ebx
  800bac:	eb ce                	jmp    800b7c <strtol+0x40>
		s += 2, base = 16;
  800bae:	83 c2 02             	add    $0x2,%edx
  800bb1:	bb 10 00 00 00       	mov    $0x10,%ebx
  800bb6:	eb c4                	jmp    800b7c <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800bb8:	0f be c0             	movsbl %al,%eax
  800bbb:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800bbe:	3b 45 10             	cmp    0x10(%ebp),%eax
  800bc1:	7d 3a                	jge    800bfd <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800bc3:	83 c2 01             	add    $0x1,%edx
  800bc6:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800bca:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800bcc:	0f b6 02             	movzbl (%edx),%eax
  800bcf:	8d 70 d0             	lea    -0x30(%eax),%esi
  800bd2:	89 f3                	mov    %esi,%ebx
  800bd4:	80 fb 09             	cmp    $0x9,%bl
  800bd7:	76 df                	jbe    800bb8 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800bd9:	8d 70 9f             	lea    -0x61(%eax),%esi
  800bdc:	89 f3                	mov    %esi,%ebx
  800bde:	80 fb 19             	cmp    $0x19,%bl
  800be1:	77 08                	ja     800beb <strtol+0xaf>
			dig = *s - 'a' + 10;
  800be3:	0f be c0             	movsbl %al,%eax
  800be6:	83 e8 57             	sub    $0x57,%eax
  800be9:	eb d3                	jmp    800bbe <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800beb:	8d 70 bf             	lea    -0x41(%eax),%esi
  800bee:	89 f3                	mov    %esi,%ebx
  800bf0:	80 fb 19             	cmp    $0x19,%bl
  800bf3:	77 08                	ja     800bfd <strtol+0xc1>
			dig = *s - 'A' + 10;
  800bf5:	0f be c0             	movsbl %al,%eax
  800bf8:	83 e8 37             	sub    $0x37,%eax
  800bfb:	eb c1                	jmp    800bbe <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800bfd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c01:	74 05                	je     800c08 <strtol+0xcc>
		*endptr = (char *) s;
  800c03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c06:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800c08:	89 c8                	mov    %ecx,%eax
  800c0a:	f7 d8                	neg    %eax
  800c0c:	85 ff                	test   %edi,%edi
  800c0e:	0f 45 c8             	cmovne %eax,%ecx
}
  800c11:	89 c8                	mov    %ecx,%eax
  800c13:	5b                   	pop    %ebx
  800c14:	5e                   	pop    %esi
  800c15:	5f                   	pop    %edi
  800c16:	5d                   	pop    %ebp
  800c17:	c3                   	ret    

00800c18 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	57                   	push   %edi
  800c1c:	56                   	push   %esi
  800c1d:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c1e:	b8 00 00 00 00       	mov    $0x0,%eax
  800c23:	8b 55 08             	mov    0x8(%ebp),%edx
  800c26:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c29:	89 c3                	mov    %eax,%ebx
  800c2b:	89 c7                	mov    %eax,%edi
  800c2d:	89 c6                	mov    %eax,%esi
  800c2f:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5f                   	pop    %edi
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <sys_cgetc>:

int
sys_cgetc(void)
{
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800c41:	b8 01 00 00 00       	mov    $0x1,%eax
  800c46:	89 d1                	mov    %edx,%ecx
  800c48:	89 d3                	mov    %edx,%ebx
  800c4a:	89 d7                	mov    %edx,%edi
  800c4c:	89 d6                	mov    %edx,%esi
  800c4e:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c50:	5b                   	pop    %ebx
  800c51:	5e                   	pop    %esi
  800c52:	5f                   	pop    %edi
  800c53:	5d                   	pop    %ebp
  800c54:	c3                   	ret    

00800c55 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	57                   	push   %edi
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800c5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c63:	8b 55 08             	mov    0x8(%ebp),%edx
  800c66:	b8 03 00 00 00       	mov    $0x3,%eax
  800c6b:	89 cb                	mov    %ecx,%ebx
  800c6d:	89 cf                	mov    %ecx,%edi
  800c6f:	89 ce                	mov    %ecx,%esi
  800c71:	cd 30                	int    $0x30
	if(check && ret > 0)
  800c73:	85 c0                	test   %eax,%eax
  800c75:	7f 08                	jg     800c7f <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c7f:	83 ec 0c             	sub    $0xc,%esp
  800c82:	50                   	push   %eax
  800c83:	6a 03                	push   $0x3
  800c85:	68 e4 13 80 00       	push   $0x8013e4
  800c8a:	6a 2a                	push   $0x2a
  800c8c:	68 01 14 80 00       	push   $0x801401
  800c91:	e8 8d f5 ff ff       	call   800223 <_panic>

00800c96 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
	asm volatile("int %1\n"
  800c9c:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca1:	b8 02 00 00 00       	mov    $0x2,%eax
  800ca6:	89 d1                	mov    %edx,%ecx
  800ca8:	89 d3                	mov    %edx,%ebx
  800caa:	89 d7                	mov    %edx,%edi
  800cac:	89 d6                	mov    %edx,%esi
  800cae:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5f                   	pop    %edi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <sys_yield>:

void
sys_yield(void)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	57                   	push   %edi
  800cb9:	56                   	push   %esi
  800cba:	53                   	push   %ebx
	asm volatile("int %1\n"
  800cbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc5:	89 d1                	mov    %edx,%ecx
  800cc7:	89 d3                	mov    %edx,%ebx
  800cc9:	89 d7                	mov    %edx,%edi
  800ccb:	89 d6                	mov    %edx,%esi
  800ccd:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ccf:	5b                   	pop    %ebx
  800cd0:	5e                   	pop    %esi
  800cd1:	5f                   	pop    %edi
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	57                   	push   %edi
  800cd8:	56                   	push   %esi
  800cd9:	53                   	push   %ebx
  800cda:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800cdd:	be 00 00 00 00       	mov    $0x0,%esi
  800ce2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce8:	b8 04 00 00 00       	mov    $0x4,%eax
  800ced:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cf0:	89 f7                	mov    %esi,%edi
  800cf2:	cd 30                	int    $0x30
	if(check && ret > 0)
  800cf4:	85 c0                	test   %eax,%eax
  800cf6:	7f 08                	jg     800d00 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800cf8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d00:	83 ec 0c             	sub    $0xc,%esp
  800d03:	50                   	push   %eax
  800d04:	6a 04                	push   $0x4
  800d06:	68 e4 13 80 00       	push   $0x8013e4
  800d0b:	6a 2a                	push   $0x2a
  800d0d:	68 01 14 80 00       	push   $0x801401
  800d12:	e8 0c f5 ff ff       	call   800223 <_panic>

00800d17 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d20:	8b 55 08             	mov    0x8(%ebp),%edx
  800d23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d26:	b8 05 00 00 00       	mov    $0x5,%eax
  800d2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d31:	8b 75 18             	mov    0x18(%ebp),%esi
  800d34:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d36:	85 c0                	test   %eax,%eax
  800d38:	7f 08                	jg     800d42 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800d3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d3d:	5b                   	pop    %ebx
  800d3e:	5e                   	pop    %esi
  800d3f:	5f                   	pop    %edi
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d42:	83 ec 0c             	sub    $0xc,%esp
  800d45:	50                   	push   %eax
  800d46:	6a 05                	push   $0x5
  800d48:	68 e4 13 80 00       	push   $0x8013e4
  800d4d:	6a 2a                	push   $0x2a
  800d4f:	68 01 14 80 00       	push   $0x801401
  800d54:	e8 ca f4 ff ff       	call   800223 <_panic>

00800d59 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	57                   	push   %edi
  800d5d:	56                   	push   %esi
  800d5e:	53                   	push   %ebx
  800d5f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800d62:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d67:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d6d:	b8 06 00 00 00       	mov    $0x6,%eax
  800d72:	89 df                	mov    %ebx,%edi
  800d74:	89 de                	mov    %ebx,%esi
  800d76:	cd 30                	int    $0x30
	if(check && ret > 0)
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	7f 08                	jg     800d84 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800d7c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d7f:	5b                   	pop    %ebx
  800d80:	5e                   	pop    %esi
  800d81:	5f                   	pop    %edi
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d84:	83 ec 0c             	sub    $0xc,%esp
  800d87:	50                   	push   %eax
  800d88:	6a 06                	push   $0x6
  800d8a:	68 e4 13 80 00       	push   $0x8013e4
  800d8f:	6a 2a                	push   $0x2a
  800d91:	68 01 14 80 00       	push   $0x801401
  800d96:	e8 88 f4 ff ff       	call   800223 <_panic>

00800d9b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d9b:	55                   	push   %ebp
  800d9c:	89 e5                	mov    %esp,%ebp
  800d9e:	57                   	push   %edi
  800d9f:	56                   	push   %esi
  800da0:	53                   	push   %ebx
  800da1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800da4:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da9:	8b 55 08             	mov    0x8(%ebp),%edx
  800dac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800daf:	b8 08 00 00 00       	mov    $0x8,%eax
  800db4:	89 df                	mov    %ebx,%edi
  800db6:	89 de                	mov    %ebx,%esi
  800db8:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	7f 08                	jg     800dc6 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800dbe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dc1:	5b                   	pop    %ebx
  800dc2:	5e                   	pop    %esi
  800dc3:	5f                   	pop    %edi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dc6:	83 ec 0c             	sub    $0xc,%esp
  800dc9:	50                   	push   %eax
  800dca:	6a 08                	push   $0x8
  800dcc:	68 e4 13 80 00       	push   $0x8013e4
  800dd1:	6a 2a                	push   $0x2a
  800dd3:	68 01 14 80 00       	push   $0x801401
  800dd8:	e8 46 f4 ff ff       	call   800223 <_panic>

00800ddd <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ddd:	55                   	push   %ebp
  800dde:	89 e5                	mov    %esp,%ebp
  800de0:	57                   	push   %edi
  800de1:	56                   	push   %esi
  800de2:	53                   	push   %ebx
  800de3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800de6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800deb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df1:	b8 09 00 00 00       	mov    $0x9,%eax
  800df6:	89 df                	mov    %ebx,%edi
  800df8:	89 de                	mov    %ebx,%esi
  800dfa:	cd 30                	int    $0x30
	if(check && ret > 0)
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	7f 08                	jg     800e08 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5e                   	pop    %esi
  800e05:	5f                   	pop    %edi
  800e06:	5d                   	pop    %ebp
  800e07:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e08:	83 ec 0c             	sub    $0xc,%esp
  800e0b:	50                   	push   %eax
  800e0c:	6a 09                	push   $0x9
  800e0e:	68 e4 13 80 00       	push   $0x8013e4
  800e13:	6a 2a                	push   $0x2a
  800e15:	68 01 14 80 00       	push   $0x801401
  800e1a:	e8 04 f4 ff ff       	call   800223 <_panic>

00800e1f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	57                   	push   %edi
  800e23:	56                   	push   %esi
  800e24:	53                   	push   %ebx
	asm volatile("int %1\n"
  800e25:	8b 55 08             	mov    0x8(%ebp),%edx
  800e28:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e2b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e30:	be 00 00 00 00       	mov    $0x0,%esi
  800e35:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e38:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e3b:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e3d:	5b                   	pop    %ebx
  800e3e:	5e                   	pop    %esi
  800e3f:	5f                   	pop    %edi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    

00800e42 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	57                   	push   %edi
  800e46:	56                   	push   %esi
  800e47:	53                   	push   %ebx
  800e48:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800e4b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e50:	8b 55 08             	mov    0x8(%ebp),%edx
  800e53:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e58:	89 cb                	mov    %ecx,%ebx
  800e5a:	89 cf                	mov    %ecx,%edi
  800e5c:	89 ce                	mov    %ecx,%esi
  800e5e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800e60:	85 c0                	test   %eax,%eax
  800e62:	7f 08                	jg     800e6c <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e64:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e67:	5b                   	pop    %ebx
  800e68:	5e                   	pop    %esi
  800e69:	5f                   	pop    %edi
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6c:	83 ec 0c             	sub    $0xc,%esp
  800e6f:	50                   	push   %eax
  800e70:	6a 0c                	push   $0xc
  800e72:	68 e4 13 80 00       	push   $0x8013e4
  800e77:	6a 2a                	push   $0x2a
  800e79:	68 01 14 80 00       	push   $0x801401
  800e7e:	e8 a0 f3 ff ff       	call   800223 <_panic>
  800e83:	66 90                	xchg   %ax,%ax
  800e85:	66 90                	xchg   %ax,%ax
  800e87:	66 90                	xchg   %ax,%ax
  800e89:	66 90                	xchg   %ax,%ax
  800e8b:	66 90                	xchg   %ax,%ax
  800e8d:	66 90                	xchg   %ax,%ax
  800e8f:	90                   	nop

00800e90 <__udivdi3>:
  800e90:	f3 0f 1e fb          	endbr32 
  800e94:	55                   	push   %ebp
  800e95:	57                   	push   %edi
  800e96:	56                   	push   %esi
  800e97:	53                   	push   %ebx
  800e98:	83 ec 1c             	sub    $0x1c,%esp
  800e9b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800e9f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800ea3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800ea7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800eab:	85 c0                	test   %eax,%eax
  800ead:	75 19                	jne    800ec8 <__udivdi3+0x38>
  800eaf:	39 f3                	cmp    %esi,%ebx
  800eb1:	76 4d                	jbe    800f00 <__udivdi3+0x70>
  800eb3:	31 ff                	xor    %edi,%edi
  800eb5:	89 e8                	mov    %ebp,%eax
  800eb7:	89 f2                	mov    %esi,%edx
  800eb9:	f7 f3                	div    %ebx
  800ebb:	89 fa                	mov    %edi,%edx
  800ebd:	83 c4 1c             	add    $0x1c,%esp
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    
  800ec5:	8d 76 00             	lea    0x0(%esi),%esi
  800ec8:	39 f0                	cmp    %esi,%eax
  800eca:	76 14                	jbe    800ee0 <__udivdi3+0x50>
  800ecc:	31 ff                	xor    %edi,%edi
  800ece:	31 c0                	xor    %eax,%eax
  800ed0:	89 fa                	mov    %edi,%edx
  800ed2:	83 c4 1c             	add    $0x1c,%esp
  800ed5:	5b                   	pop    %ebx
  800ed6:	5e                   	pop    %esi
  800ed7:	5f                   	pop    %edi
  800ed8:	5d                   	pop    %ebp
  800ed9:	c3                   	ret    
  800eda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ee0:	0f bd f8             	bsr    %eax,%edi
  800ee3:	83 f7 1f             	xor    $0x1f,%edi
  800ee6:	75 48                	jne    800f30 <__udivdi3+0xa0>
  800ee8:	39 f0                	cmp    %esi,%eax
  800eea:	72 06                	jb     800ef2 <__udivdi3+0x62>
  800eec:	31 c0                	xor    %eax,%eax
  800eee:	39 eb                	cmp    %ebp,%ebx
  800ef0:	77 de                	ja     800ed0 <__udivdi3+0x40>
  800ef2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ef7:	eb d7                	jmp    800ed0 <__udivdi3+0x40>
  800ef9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f00:	89 d9                	mov    %ebx,%ecx
  800f02:	85 db                	test   %ebx,%ebx
  800f04:	75 0b                	jne    800f11 <__udivdi3+0x81>
  800f06:	b8 01 00 00 00       	mov    $0x1,%eax
  800f0b:	31 d2                	xor    %edx,%edx
  800f0d:	f7 f3                	div    %ebx
  800f0f:	89 c1                	mov    %eax,%ecx
  800f11:	31 d2                	xor    %edx,%edx
  800f13:	89 f0                	mov    %esi,%eax
  800f15:	f7 f1                	div    %ecx
  800f17:	89 c6                	mov    %eax,%esi
  800f19:	89 e8                	mov    %ebp,%eax
  800f1b:	89 f7                	mov    %esi,%edi
  800f1d:	f7 f1                	div    %ecx
  800f1f:	89 fa                	mov    %edi,%edx
  800f21:	83 c4 1c             	add    $0x1c,%esp
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5f                   	pop    %edi
  800f27:	5d                   	pop    %ebp
  800f28:	c3                   	ret    
  800f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f30:	89 f9                	mov    %edi,%ecx
  800f32:	ba 20 00 00 00       	mov    $0x20,%edx
  800f37:	29 fa                	sub    %edi,%edx
  800f39:	d3 e0                	shl    %cl,%eax
  800f3b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f3f:	89 d1                	mov    %edx,%ecx
  800f41:	89 d8                	mov    %ebx,%eax
  800f43:	d3 e8                	shr    %cl,%eax
  800f45:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800f49:	09 c1                	or     %eax,%ecx
  800f4b:	89 f0                	mov    %esi,%eax
  800f4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f51:	89 f9                	mov    %edi,%ecx
  800f53:	d3 e3                	shl    %cl,%ebx
  800f55:	89 d1                	mov    %edx,%ecx
  800f57:	d3 e8                	shr    %cl,%eax
  800f59:	89 f9                	mov    %edi,%ecx
  800f5b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800f5f:	89 eb                	mov    %ebp,%ebx
  800f61:	d3 e6                	shl    %cl,%esi
  800f63:	89 d1                	mov    %edx,%ecx
  800f65:	d3 eb                	shr    %cl,%ebx
  800f67:	09 f3                	or     %esi,%ebx
  800f69:	89 c6                	mov    %eax,%esi
  800f6b:	89 f2                	mov    %esi,%edx
  800f6d:	89 d8                	mov    %ebx,%eax
  800f6f:	f7 74 24 08          	divl   0x8(%esp)
  800f73:	89 d6                	mov    %edx,%esi
  800f75:	89 c3                	mov    %eax,%ebx
  800f77:	f7 64 24 0c          	mull   0xc(%esp)
  800f7b:	39 d6                	cmp    %edx,%esi
  800f7d:	72 19                	jb     800f98 <__udivdi3+0x108>
  800f7f:	89 f9                	mov    %edi,%ecx
  800f81:	d3 e5                	shl    %cl,%ebp
  800f83:	39 c5                	cmp    %eax,%ebp
  800f85:	73 04                	jae    800f8b <__udivdi3+0xfb>
  800f87:	39 d6                	cmp    %edx,%esi
  800f89:	74 0d                	je     800f98 <__udivdi3+0x108>
  800f8b:	89 d8                	mov    %ebx,%eax
  800f8d:	31 ff                	xor    %edi,%edi
  800f8f:	e9 3c ff ff ff       	jmp    800ed0 <__udivdi3+0x40>
  800f94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f98:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800f9b:	31 ff                	xor    %edi,%edi
  800f9d:	e9 2e ff ff ff       	jmp    800ed0 <__udivdi3+0x40>
  800fa2:	66 90                	xchg   %ax,%ax
  800fa4:	66 90                	xchg   %ax,%ax
  800fa6:	66 90                	xchg   %ax,%ax
  800fa8:	66 90                	xchg   %ax,%ax
  800faa:	66 90                	xchg   %ax,%ax
  800fac:	66 90                	xchg   %ax,%ax
  800fae:	66 90                	xchg   %ax,%ax

00800fb0 <__umoddi3>:
  800fb0:	f3 0f 1e fb          	endbr32 
  800fb4:	55                   	push   %ebp
  800fb5:	57                   	push   %edi
  800fb6:	56                   	push   %esi
  800fb7:	53                   	push   %ebx
  800fb8:	83 ec 1c             	sub    $0x1c,%esp
  800fbb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800fbf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800fc3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800fc7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800fcb:	89 f0                	mov    %esi,%eax
  800fcd:	89 da                	mov    %ebx,%edx
  800fcf:	85 ff                	test   %edi,%edi
  800fd1:	75 15                	jne    800fe8 <__umoddi3+0x38>
  800fd3:	39 dd                	cmp    %ebx,%ebp
  800fd5:	76 39                	jbe    801010 <__umoddi3+0x60>
  800fd7:	f7 f5                	div    %ebp
  800fd9:	89 d0                	mov    %edx,%eax
  800fdb:	31 d2                	xor    %edx,%edx
  800fdd:	83 c4 1c             	add    $0x1c,%esp
  800fe0:	5b                   	pop    %ebx
  800fe1:	5e                   	pop    %esi
  800fe2:	5f                   	pop    %edi
  800fe3:	5d                   	pop    %ebp
  800fe4:	c3                   	ret    
  800fe5:	8d 76 00             	lea    0x0(%esi),%esi
  800fe8:	39 df                	cmp    %ebx,%edi
  800fea:	77 f1                	ja     800fdd <__umoddi3+0x2d>
  800fec:	0f bd cf             	bsr    %edi,%ecx
  800fef:	83 f1 1f             	xor    $0x1f,%ecx
  800ff2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800ff6:	75 40                	jne    801038 <__umoddi3+0x88>
  800ff8:	39 df                	cmp    %ebx,%edi
  800ffa:	72 04                	jb     801000 <__umoddi3+0x50>
  800ffc:	39 f5                	cmp    %esi,%ebp
  800ffe:	77 dd                	ja     800fdd <__umoddi3+0x2d>
  801000:	89 da                	mov    %ebx,%edx
  801002:	89 f0                	mov    %esi,%eax
  801004:	29 e8                	sub    %ebp,%eax
  801006:	19 fa                	sbb    %edi,%edx
  801008:	eb d3                	jmp    800fdd <__umoddi3+0x2d>
  80100a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801010:	89 e9                	mov    %ebp,%ecx
  801012:	85 ed                	test   %ebp,%ebp
  801014:	75 0b                	jne    801021 <__umoddi3+0x71>
  801016:	b8 01 00 00 00       	mov    $0x1,%eax
  80101b:	31 d2                	xor    %edx,%edx
  80101d:	f7 f5                	div    %ebp
  80101f:	89 c1                	mov    %eax,%ecx
  801021:	89 d8                	mov    %ebx,%eax
  801023:	31 d2                	xor    %edx,%edx
  801025:	f7 f1                	div    %ecx
  801027:	89 f0                	mov    %esi,%eax
  801029:	f7 f1                	div    %ecx
  80102b:	89 d0                	mov    %edx,%eax
  80102d:	31 d2                	xor    %edx,%edx
  80102f:	eb ac                	jmp    800fdd <__umoddi3+0x2d>
  801031:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801038:	8b 44 24 04          	mov    0x4(%esp),%eax
  80103c:	ba 20 00 00 00       	mov    $0x20,%edx
  801041:	29 c2                	sub    %eax,%edx
  801043:	89 c1                	mov    %eax,%ecx
  801045:	89 e8                	mov    %ebp,%eax
  801047:	d3 e7                	shl    %cl,%edi
  801049:	89 d1                	mov    %edx,%ecx
  80104b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80104f:	d3 e8                	shr    %cl,%eax
  801051:	89 c1                	mov    %eax,%ecx
  801053:	8b 44 24 04          	mov    0x4(%esp),%eax
  801057:	09 f9                	or     %edi,%ecx
  801059:	89 df                	mov    %ebx,%edi
  80105b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80105f:	89 c1                	mov    %eax,%ecx
  801061:	d3 e5                	shl    %cl,%ebp
  801063:	89 d1                	mov    %edx,%ecx
  801065:	d3 ef                	shr    %cl,%edi
  801067:	89 c1                	mov    %eax,%ecx
  801069:	89 f0                	mov    %esi,%eax
  80106b:	d3 e3                	shl    %cl,%ebx
  80106d:	89 d1                	mov    %edx,%ecx
  80106f:	89 fa                	mov    %edi,%edx
  801071:	d3 e8                	shr    %cl,%eax
  801073:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801078:	09 d8                	or     %ebx,%eax
  80107a:	f7 74 24 08          	divl   0x8(%esp)
  80107e:	89 d3                	mov    %edx,%ebx
  801080:	d3 e6                	shl    %cl,%esi
  801082:	f7 e5                	mul    %ebp
  801084:	89 c7                	mov    %eax,%edi
  801086:	89 d1                	mov    %edx,%ecx
  801088:	39 d3                	cmp    %edx,%ebx
  80108a:	72 06                	jb     801092 <__umoddi3+0xe2>
  80108c:	75 0e                	jne    80109c <__umoddi3+0xec>
  80108e:	39 c6                	cmp    %eax,%esi
  801090:	73 0a                	jae    80109c <__umoddi3+0xec>
  801092:	29 e8                	sub    %ebp,%eax
  801094:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801098:	89 d1                	mov    %edx,%ecx
  80109a:	89 c7                	mov    %eax,%edi
  80109c:	89 f5                	mov    %esi,%ebp
  80109e:	8b 74 24 04          	mov    0x4(%esp),%esi
  8010a2:	29 fd                	sub    %edi,%ebp
  8010a4:	19 cb                	sbb    %ecx,%ebx
  8010a6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8010ab:	89 d8                	mov    %ebx,%eax
  8010ad:	d3 e0                	shl    %cl,%eax
  8010af:	89 f1                	mov    %esi,%ecx
  8010b1:	d3 ed                	shr    %cl,%ebp
  8010b3:	d3 eb                	shr    %cl,%ebx
  8010b5:	09 e8                	or     %ebp,%eax
  8010b7:	89 da                	mov    %ebx,%edx
  8010b9:	83 c4 1c             	add    $0x1c,%esp
  8010bc:	5b                   	pop    %ebx
  8010bd:	5e                   	pop    %esi
  8010be:	5f                   	pop    %edi
  8010bf:	5d                   	pop    %ebp
  8010c0:	c3                   	ret    
