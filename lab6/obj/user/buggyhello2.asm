
obj/user/buggyhello2.debug：     文件格式 elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	push   0x803000
  800044:	e8 65 00 00 00       	call   8000ae <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 ce 00 00 00       	call   80012c <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 ee 04 00 00       	call   80058d <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 42 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fc:	b8 03 00 00 00       	mov    $0x3,%eax
  800101:	89 cb                	mov    %ecx,%ebx
  800103:	89 cf                	mov    %ecx,%edi
  800105:	89 ce                	mov    %ecx,%esi
  800107:	cd 30                	int    $0x30
	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7f 08                	jg     800115 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800110:	5b                   	pop    %ebx
  800111:	5e                   	pop    %esi
  800112:	5f                   	pop    %edi
  800113:	5d                   	pop    %ebp
  800114:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	50                   	push   %eax
  800119:	6a 03                	push   $0x3
  80011b:	68 58 22 80 00       	push   $0x802258
  800120:	6a 2a                	push   $0x2a
  800122:	68 75 22 80 00       	push   $0x802275
  800127:	e8 9e 13 00 00       	call   8014ca <_panic>

0080012c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 02 00 00 00       	mov    $0x2,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800173:	be 00 00 00 00       	mov    $0x0,%esi
  800178:	8b 55 08             	mov    0x8(%ebp),%edx
  80017b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017e:	b8 04 00 00 00       	mov    $0x4,%eax
  800183:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800186:	89 f7                	mov    %esi,%edi
  800188:	cd 30                	int    $0x30
	if(check && ret > 0)
  80018a:	85 c0                	test   %eax,%eax
  80018c:	7f 08                	jg     800196 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800191:	5b                   	pop    %ebx
  800192:	5e                   	pop    %esi
  800193:	5f                   	pop    %edi
  800194:	5d                   	pop    %ebp
  800195:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800196:	83 ec 0c             	sub    $0xc,%esp
  800199:	50                   	push   %eax
  80019a:	6a 04                	push   $0x4
  80019c:	68 58 22 80 00       	push   $0x802258
  8001a1:	6a 2a                	push   $0x2a
  8001a3:	68 75 22 80 00       	push   $0x802275
  8001a8:	e8 1d 13 00 00       	call   8014ca <_panic>

008001ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bc:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ca:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	7f 08                	jg     8001d8 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d3:	5b                   	pop    %ebx
  8001d4:	5e                   	pop    %esi
  8001d5:	5f                   	pop    %edi
  8001d6:	5d                   	pop    %ebp
  8001d7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d8:	83 ec 0c             	sub    $0xc,%esp
  8001db:	50                   	push   %eax
  8001dc:	6a 05                	push   $0x5
  8001de:	68 58 22 80 00       	push   $0x802258
  8001e3:	6a 2a                	push   $0x2a
  8001e5:	68 75 22 80 00       	push   $0x802275
  8001ea:	e8 db 12 00 00       	call   8014ca <_panic>

008001ef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800203:	b8 06 00 00 00       	mov    $0x6,%eax
  800208:	89 df                	mov    %ebx,%edi
  80020a:	89 de                	mov    %ebx,%esi
  80020c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80020e:	85 c0                	test   %eax,%eax
  800210:	7f 08                	jg     80021a <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800212:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800215:	5b                   	pop    %ebx
  800216:	5e                   	pop    %esi
  800217:	5f                   	pop    %edi
  800218:	5d                   	pop    %ebp
  800219:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80021a:	83 ec 0c             	sub    $0xc,%esp
  80021d:	50                   	push   %eax
  80021e:	6a 06                	push   $0x6
  800220:	68 58 22 80 00       	push   $0x802258
  800225:	6a 2a                	push   $0x2a
  800227:	68 75 22 80 00       	push   $0x802275
  80022c:	e8 99 12 00 00       	call   8014ca <_panic>

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	8b 55 08             	mov    0x8(%ebp),%edx
  800242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800245:	b8 08 00 00 00       	mov    $0x8,%eax
  80024a:	89 df                	mov    %ebx,%edi
  80024c:	89 de                	mov    %ebx,%esi
  80024e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7f 08                	jg     80025c <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800254:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800257:	5b                   	pop    %ebx
  800258:	5e                   	pop    %esi
  800259:	5f                   	pop    %edi
  80025a:	5d                   	pop    %ebp
  80025b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80025c:	83 ec 0c             	sub    $0xc,%esp
  80025f:	50                   	push   %eax
  800260:	6a 08                	push   $0x8
  800262:	68 58 22 80 00       	push   $0x802258
  800267:	6a 2a                	push   $0x2a
  800269:	68 75 22 80 00       	push   $0x802275
  80026e:	e8 57 12 00 00       	call   8014ca <_panic>

00800273 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	8b 55 08             	mov    0x8(%ebp),%edx
  800284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800287:	b8 09 00 00 00       	mov    $0x9,%eax
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7f 08                	jg     80029e <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800296:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800299:	5b                   	pop    %ebx
  80029a:	5e                   	pop    %esi
  80029b:	5f                   	pop    %edi
  80029c:	5d                   	pop    %ebp
  80029d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80029e:	83 ec 0c             	sub    $0xc,%esp
  8002a1:	50                   	push   %eax
  8002a2:	6a 09                	push   $0x9
  8002a4:	68 58 22 80 00       	push   $0x802258
  8002a9:	6a 2a                	push   $0x2a
  8002ab:	68 75 22 80 00       	push   $0x802275
  8002b0:	e8 15 12 00 00       	call   8014ca <_panic>

008002b5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ce:	89 df                	mov    %ebx,%edi
  8002d0:	89 de                	mov    %ebx,%esi
  8002d2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7f 08                	jg     8002e0 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002db:	5b                   	pop    %ebx
  8002dc:	5e                   	pop    %esi
  8002dd:	5f                   	pop    %edi
  8002de:	5d                   	pop    %ebp
  8002df:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e0:	83 ec 0c             	sub    $0xc,%esp
  8002e3:	50                   	push   %eax
  8002e4:	6a 0a                	push   $0xa
  8002e6:	68 58 22 80 00       	push   $0x802258
  8002eb:	6a 2a                	push   $0x2a
  8002ed:	68 75 22 80 00       	push   $0x802275
  8002f2:	e8 d3 11 00 00       	call   8014ca <_panic>

008002f7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	b8 0c 00 00 00       	mov    $0xc,%eax
  800308:	be 00 00 00 00       	mov    $0x0,%esi
  80030d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800310:	8b 7d 14             	mov    0x14(%ebp),%edi
  800313:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	8b 55 08             	mov    0x8(%ebp),%edx
  80032b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800330:	89 cb                	mov    %ecx,%ebx
  800332:	89 cf                	mov    %ecx,%edi
  800334:	89 ce                	mov    %ecx,%esi
  800336:	cd 30                	int    $0x30
	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7f 08                	jg     800344 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80033c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033f:	5b                   	pop    %ebx
  800340:	5e                   	pop    %esi
  800341:	5f                   	pop    %edi
  800342:	5d                   	pop    %ebp
  800343:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800344:	83 ec 0c             	sub    $0xc,%esp
  800347:	50                   	push   %eax
  800348:	6a 0d                	push   $0xd
  80034a:	68 58 22 80 00       	push   $0x802258
  80034f:	6a 2a                	push   $0x2a
  800351:	68 75 22 80 00       	push   $0x802275
  800356:	e8 6f 11 00 00       	call   8014ca <_panic>

0080035b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
  80035e:	57                   	push   %edi
  80035f:	56                   	push   %esi
  800360:	53                   	push   %ebx
	asm volatile("int %1\n"
  800361:	ba 00 00 00 00       	mov    $0x0,%edx
  800366:	b8 0e 00 00 00       	mov    $0xe,%eax
  80036b:	89 d1                	mov    %edx,%ecx
  80036d:	89 d3                	mov    %edx,%ebx
  80036f:	89 d7                	mov    %edx,%edi
  800371:	89 d6                	mov    %edx,%esi
  800373:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800375:	5b                   	pop    %ebx
  800376:	5e                   	pop    %esi
  800377:	5f                   	pop    %edi
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	57                   	push   %edi
  80037e:	56                   	push   %esi
  80037f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800380:	bb 00 00 00 00       	mov    $0x0,%ebx
  800385:	8b 55 08             	mov    0x8(%ebp),%edx
  800388:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80038b:	b8 0f 00 00 00       	mov    $0xf,%eax
  800390:	89 df                	mov    %ebx,%edi
  800392:	89 de                	mov    %ebx,%esi
  800394:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800396:	5b                   	pop    %ebx
  800397:	5e                   	pop    %esi
  800398:	5f                   	pop    %edi
  800399:	5d                   	pop    %ebp
  80039a:	c3                   	ret    

0080039b <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  80039b:	55                   	push   %ebp
  80039c:	89 e5                	mov    %esp,%ebp
  80039e:	57                   	push   %edi
  80039f:	56                   	push   %esi
  8003a0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8003a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003ac:	b8 10 00 00 00       	mov    $0x10,%eax
  8003b1:	89 df                	mov    %ebx,%edi
  8003b3:	89 de                	mov    %ebx,%esi
  8003b5:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8003b7:	5b                   	pop    %ebx
  8003b8:	5e                   	pop    %esi
  8003b9:	5f                   	pop    %edi
  8003ba:	5d                   	pop    %ebp
  8003bb:	c3                   	ret    

008003bc <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003bc:	55                   	push   %ebp
  8003bd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c2:	05 00 00 00 30       	add    $0x30000000,%eax
  8003c7:	c1 e8 0c             	shr    $0xc,%eax
}
  8003ca:	5d                   	pop    %ebp
  8003cb:	c3                   	ret    

008003cc <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003cc:	55                   	push   %ebp
  8003cd:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d2:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003d7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003dc:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003e1:	5d                   	pop    %ebp
  8003e2:	c3                   	ret    

008003e3 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
  8003e6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003eb:	89 c2                	mov    %eax,%edx
  8003ed:	c1 ea 16             	shr    $0x16,%edx
  8003f0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003f7:	f6 c2 01             	test   $0x1,%dl
  8003fa:	74 29                	je     800425 <fd_alloc+0x42>
  8003fc:	89 c2                	mov    %eax,%edx
  8003fe:	c1 ea 0c             	shr    $0xc,%edx
  800401:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800408:	f6 c2 01             	test   $0x1,%dl
  80040b:	74 18                	je     800425 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  80040d:	05 00 10 00 00       	add    $0x1000,%eax
  800412:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800417:	75 d2                	jne    8003eb <fd_alloc+0x8>
  800419:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80041e:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800423:	eb 05                	jmp    80042a <fd_alloc+0x47>
			return 0;
  800425:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  80042a:	8b 55 08             	mov    0x8(%ebp),%edx
  80042d:	89 02                	mov    %eax,(%edx)
}
  80042f:	89 c8                	mov    %ecx,%eax
  800431:	5d                   	pop    %ebp
  800432:	c3                   	ret    

00800433 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800433:	55                   	push   %ebp
  800434:	89 e5                	mov    %esp,%ebp
  800436:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800439:	83 f8 1f             	cmp    $0x1f,%eax
  80043c:	77 30                	ja     80046e <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80043e:	c1 e0 0c             	shl    $0xc,%eax
  800441:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800446:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80044c:	f6 c2 01             	test   $0x1,%dl
  80044f:	74 24                	je     800475 <fd_lookup+0x42>
  800451:	89 c2                	mov    %eax,%edx
  800453:	c1 ea 0c             	shr    $0xc,%edx
  800456:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80045d:	f6 c2 01             	test   $0x1,%dl
  800460:	74 1a                	je     80047c <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800462:	8b 55 0c             	mov    0xc(%ebp),%edx
  800465:	89 02                	mov    %eax,(%edx)
	return 0;
  800467:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80046c:	5d                   	pop    %ebp
  80046d:	c3                   	ret    
		return -E_INVAL;
  80046e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800473:	eb f7                	jmp    80046c <fd_lookup+0x39>
		return -E_INVAL;
  800475:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80047a:	eb f0                	jmp    80046c <fd_lookup+0x39>
  80047c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800481:	eb e9                	jmp    80046c <fd_lookup+0x39>

00800483 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800483:	55                   	push   %ebp
  800484:	89 e5                	mov    %esp,%ebp
  800486:	53                   	push   %ebx
  800487:	83 ec 04             	sub    $0x4,%esp
  80048a:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80048d:	b8 00 00 00 00       	mov    $0x0,%eax
  800492:	bb 08 30 80 00       	mov    $0x803008,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800497:	39 13                	cmp    %edx,(%ebx)
  800499:	74 37                	je     8004d2 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  80049b:	83 c0 01             	add    $0x1,%eax
  80049e:	8b 1c 85 00 23 80 00 	mov    0x802300(,%eax,4),%ebx
  8004a5:	85 db                	test   %ebx,%ebx
  8004a7:	75 ee                	jne    800497 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004a9:	a1 00 40 80 00       	mov    0x804000,%eax
  8004ae:	8b 40 48             	mov    0x48(%eax),%eax
  8004b1:	83 ec 04             	sub    $0x4,%esp
  8004b4:	52                   	push   %edx
  8004b5:	50                   	push   %eax
  8004b6:	68 84 22 80 00       	push   $0x802284
  8004bb:	e8 e5 10 00 00       	call   8015a5 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8004c0:	83 c4 10             	add    $0x10,%esp
  8004c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8004c8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004cb:	89 1a                	mov    %ebx,(%edx)
}
  8004cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004d0:	c9                   	leave  
  8004d1:	c3                   	ret    
			return 0;
  8004d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d7:	eb ef                	jmp    8004c8 <dev_lookup+0x45>

008004d9 <fd_close>:
{
  8004d9:	55                   	push   %ebp
  8004da:	89 e5                	mov    %esp,%ebp
  8004dc:	57                   	push   %edi
  8004dd:	56                   	push   %esi
  8004de:	53                   	push   %ebx
  8004df:	83 ec 24             	sub    $0x24,%esp
  8004e2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e5:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e8:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004eb:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004ec:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004f2:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004f5:	50                   	push   %eax
  8004f6:	e8 38 ff ff ff       	call   800433 <fd_lookup>
  8004fb:	89 c3                	mov    %eax,%ebx
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	85 c0                	test   %eax,%eax
  800502:	78 05                	js     800509 <fd_close+0x30>
	    || fd != fd2)
  800504:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800507:	74 16                	je     80051f <fd_close+0x46>
		return (must_exist ? r : 0);
  800509:	89 f8                	mov    %edi,%eax
  80050b:	84 c0                	test   %al,%al
  80050d:	b8 00 00 00 00       	mov    $0x0,%eax
  800512:	0f 44 d8             	cmove  %eax,%ebx
}
  800515:	89 d8                	mov    %ebx,%eax
  800517:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80051a:	5b                   	pop    %ebx
  80051b:	5e                   	pop    %esi
  80051c:	5f                   	pop    %edi
  80051d:	5d                   	pop    %ebp
  80051e:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80051f:	83 ec 08             	sub    $0x8,%esp
  800522:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800525:	50                   	push   %eax
  800526:	ff 36                	push   (%esi)
  800528:	e8 56 ff ff ff       	call   800483 <dev_lookup>
  80052d:	89 c3                	mov    %eax,%ebx
  80052f:	83 c4 10             	add    $0x10,%esp
  800532:	85 c0                	test   %eax,%eax
  800534:	78 1a                	js     800550 <fd_close+0x77>
		if (dev->dev_close)
  800536:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800539:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80053c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800541:	85 c0                	test   %eax,%eax
  800543:	74 0b                	je     800550 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800545:	83 ec 0c             	sub    $0xc,%esp
  800548:	56                   	push   %esi
  800549:	ff d0                	call   *%eax
  80054b:	89 c3                	mov    %eax,%ebx
  80054d:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800550:	83 ec 08             	sub    $0x8,%esp
  800553:	56                   	push   %esi
  800554:	6a 00                	push   $0x0
  800556:	e8 94 fc ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80055b:	83 c4 10             	add    $0x10,%esp
  80055e:	eb b5                	jmp    800515 <fd_close+0x3c>

00800560 <close>:

int
close(int fdnum)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800566:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800569:	50                   	push   %eax
  80056a:	ff 75 08             	push   0x8(%ebp)
  80056d:	e8 c1 fe ff ff       	call   800433 <fd_lookup>
  800572:	83 c4 10             	add    $0x10,%esp
  800575:	85 c0                	test   %eax,%eax
  800577:	79 02                	jns    80057b <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800579:	c9                   	leave  
  80057a:	c3                   	ret    
		return fd_close(fd, 1);
  80057b:	83 ec 08             	sub    $0x8,%esp
  80057e:	6a 01                	push   $0x1
  800580:	ff 75 f4             	push   -0xc(%ebp)
  800583:	e8 51 ff ff ff       	call   8004d9 <fd_close>
  800588:	83 c4 10             	add    $0x10,%esp
  80058b:	eb ec                	jmp    800579 <close+0x19>

0080058d <close_all>:

void
close_all(void)
{
  80058d:	55                   	push   %ebp
  80058e:	89 e5                	mov    %esp,%ebp
  800590:	53                   	push   %ebx
  800591:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800594:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800599:	83 ec 0c             	sub    $0xc,%esp
  80059c:	53                   	push   %ebx
  80059d:	e8 be ff ff ff       	call   800560 <close>
	for (i = 0; i < MAXFD; i++)
  8005a2:	83 c3 01             	add    $0x1,%ebx
  8005a5:	83 c4 10             	add    $0x10,%esp
  8005a8:	83 fb 20             	cmp    $0x20,%ebx
  8005ab:	75 ec                	jne    800599 <close_all+0xc>
}
  8005ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005b0:	c9                   	leave  
  8005b1:	c3                   	ret    

008005b2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005b2:	55                   	push   %ebp
  8005b3:	89 e5                	mov    %esp,%ebp
  8005b5:	57                   	push   %edi
  8005b6:	56                   	push   %esi
  8005b7:	53                   	push   %ebx
  8005b8:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005bb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005be:	50                   	push   %eax
  8005bf:	ff 75 08             	push   0x8(%ebp)
  8005c2:	e8 6c fe ff ff       	call   800433 <fd_lookup>
  8005c7:	89 c3                	mov    %eax,%ebx
  8005c9:	83 c4 10             	add    $0x10,%esp
  8005cc:	85 c0                	test   %eax,%eax
  8005ce:	78 7f                	js     80064f <dup+0x9d>
		return r;
	close(newfdnum);
  8005d0:	83 ec 0c             	sub    $0xc,%esp
  8005d3:	ff 75 0c             	push   0xc(%ebp)
  8005d6:	e8 85 ff ff ff       	call   800560 <close>

	newfd = INDEX2FD(newfdnum);
  8005db:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005de:	c1 e6 0c             	shl    $0xc,%esi
  8005e1:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005e7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ea:	89 3c 24             	mov    %edi,(%esp)
  8005ed:	e8 da fd ff ff       	call   8003cc <fd2data>
  8005f2:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005f4:	89 34 24             	mov    %esi,(%esp)
  8005f7:	e8 d0 fd ff ff       	call   8003cc <fd2data>
  8005fc:	83 c4 10             	add    $0x10,%esp
  8005ff:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800602:	89 d8                	mov    %ebx,%eax
  800604:	c1 e8 16             	shr    $0x16,%eax
  800607:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80060e:	a8 01                	test   $0x1,%al
  800610:	74 11                	je     800623 <dup+0x71>
  800612:	89 d8                	mov    %ebx,%eax
  800614:	c1 e8 0c             	shr    $0xc,%eax
  800617:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80061e:	f6 c2 01             	test   $0x1,%dl
  800621:	75 36                	jne    800659 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800623:	89 f8                	mov    %edi,%eax
  800625:	c1 e8 0c             	shr    $0xc,%eax
  800628:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80062f:	83 ec 0c             	sub    $0xc,%esp
  800632:	25 07 0e 00 00       	and    $0xe07,%eax
  800637:	50                   	push   %eax
  800638:	56                   	push   %esi
  800639:	6a 00                	push   $0x0
  80063b:	57                   	push   %edi
  80063c:	6a 00                	push   $0x0
  80063e:	e8 6a fb ff ff       	call   8001ad <sys_page_map>
  800643:	89 c3                	mov    %eax,%ebx
  800645:	83 c4 20             	add    $0x20,%esp
  800648:	85 c0                	test   %eax,%eax
  80064a:	78 33                	js     80067f <dup+0xcd>
		goto err;

	return newfdnum;
  80064c:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80064f:	89 d8                	mov    %ebx,%eax
  800651:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800654:	5b                   	pop    %ebx
  800655:	5e                   	pop    %esi
  800656:	5f                   	pop    %edi
  800657:	5d                   	pop    %ebp
  800658:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800659:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800660:	83 ec 0c             	sub    $0xc,%esp
  800663:	25 07 0e 00 00       	and    $0xe07,%eax
  800668:	50                   	push   %eax
  800669:	ff 75 d4             	push   -0x2c(%ebp)
  80066c:	6a 00                	push   $0x0
  80066e:	53                   	push   %ebx
  80066f:	6a 00                	push   $0x0
  800671:	e8 37 fb ff ff       	call   8001ad <sys_page_map>
  800676:	89 c3                	mov    %eax,%ebx
  800678:	83 c4 20             	add    $0x20,%esp
  80067b:	85 c0                	test   %eax,%eax
  80067d:	79 a4                	jns    800623 <dup+0x71>
	sys_page_unmap(0, newfd);
  80067f:	83 ec 08             	sub    $0x8,%esp
  800682:	56                   	push   %esi
  800683:	6a 00                	push   $0x0
  800685:	e8 65 fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  80068a:	83 c4 08             	add    $0x8,%esp
  80068d:	ff 75 d4             	push   -0x2c(%ebp)
  800690:	6a 00                	push   $0x0
  800692:	e8 58 fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  800697:	83 c4 10             	add    $0x10,%esp
  80069a:	eb b3                	jmp    80064f <dup+0x9d>

0080069c <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
  80069f:	56                   	push   %esi
  8006a0:	53                   	push   %ebx
  8006a1:	83 ec 18             	sub    $0x18,%esp
  8006a4:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006aa:	50                   	push   %eax
  8006ab:	56                   	push   %esi
  8006ac:	e8 82 fd ff ff       	call   800433 <fd_lookup>
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	78 3c                	js     8006f4 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b8:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8006bb:	83 ec 08             	sub    $0x8,%esp
  8006be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006c1:	50                   	push   %eax
  8006c2:	ff 33                	push   (%ebx)
  8006c4:	e8 ba fd ff ff       	call   800483 <dev_lookup>
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	85 c0                	test   %eax,%eax
  8006ce:	78 24                	js     8006f4 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006d0:	8b 43 08             	mov    0x8(%ebx),%eax
  8006d3:	83 e0 03             	and    $0x3,%eax
  8006d6:	83 f8 01             	cmp    $0x1,%eax
  8006d9:	74 20                	je     8006fb <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006de:	8b 40 08             	mov    0x8(%eax),%eax
  8006e1:	85 c0                	test   %eax,%eax
  8006e3:	74 37                	je     80071c <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006e5:	83 ec 04             	sub    $0x4,%esp
  8006e8:	ff 75 10             	push   0x10(%ebp)
  8006eb:	ff 75 0c             	push   0xc(%ebp)
  8006ee:	53                   	push   %ebx
  8006ef:	ff d0                	call   *%eax
  8006f1:	83 c4 10             	add    $0x10,%esp
}
  8006f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006f7:	5b                   	pop    %ebx
  8006f8:	5e                   	pop    %esi
  8006f9:	5d                   	pop    %ebp
  8006fa:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006fb:	a1 00 40 80 00       	mov    0x804000,%eax
  800700:	8b 40 48             	mov    0x48(%eax),%eax
  800703:	83 ec 04             	sub    $0x4,%esp
  800706:	56                   	push   %esi
  800707:	50                   	push   %eax
  800708:	68 c5 22 80 00       	push   $0x8022c5
  80070d:	e8 93 0e 00 00       	call   8015a5 <cprintf>
		return -E_INVAL;
  800712:	83 c4 10             	add    $0x10,%esp
  800715:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80071a:	eb d8                	jmp    8006f4 <read+0x58>
		return -E_NOT_SUPP;
  80071c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800721:	eb d1                	jmp    8006f4 <read+0x58>

00800723 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800723:	55                   	push   %ebp
  800724:	89 e5                	mov    %esp,%ebp
  800726:	57                   	push   %edi
  800727:	56                   	push   %esi
  800728:	53                   	push   %ebx
  800729:	83 ec 0c             	sub    $0xc,%esp
  80072c:	8b 7d 08             	mov    0x8(%ebp),%edi
  80072f:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800732:	bb 00 00 00 00       	mov    $0x0,%ebx
  800737:	eb 02                	jmp    80073b <readn+0x18>
  800739:	01 c3                	add    %eax,%ebx
  80073b:	39 f3                	cmp    %esi,%ebx
  80073d:	73 21                	jae    800760 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80073f:	83 ec 04             	sub    $0x4,%esp
  800742:	89 f0                	mov    %esi,%eax
  800744:	29 d8                	sub    %ebx,%eax
  800746:	50                   	push   %eax
  800747:	89 d8                	mov    %ebx,%eax
  800749:	03 45 0c             	add    0xc(%ebp),%eax
  80074c:	50                   	push   %eax
  80074d:	57                   	push   %edi
  80074e:	e8 49 ff ff ff       	call   80069c <read>
		if (m < 0)
  800753:	83 c4 10             	add    $0x10,%esp
  800756:	85 c0                	test   %eax,%eax
  800758:	78 04                	js     80075e <readn+0x3b>
			return m;
		if (m == 0)
  80075a:	75 dd                	jne    800739 <readn+0x16>
  80075c:	eb 02                	jmp    800760 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80075e:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800760:	89 d8                	mov    %ebx,%eax
  800762:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800765:	5b                   	pop    %ebx
  800766:	5e                   	pop    %esi
  800767:	5f                   	pop    %edi
  800768:	5d                   	pop    %ebp
  800769:	c3                   	ret    

0080076a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80076a:	55                   	push   %ebp
  80076b:	89 e5                	mov    %esp,%ebp
  80076d:	56                   	push   %esi
  80076e:	53                   	push   %ebx
  80076f:	83 ec 18             	sub    $0x18,%esp
  800772:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800775:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800778:	50                   	push   %eax
  800779:	53                   	push   %ebx
  80077a:	e8 b4 fc ff ff       	call   800433 <fd_lookup>
  80077f:	83 c4 10             	add    $0x10,%esp
  800782:	85 c0                	test   %eax,%eax
  800784:	78 37                	js     8007bd <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800786:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800789:	83 ec 08             	sub    $0x8,%esp
  80078c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80078f:	50                   	push   %eax
  800790:	ff 36                	push   (%esi)
  800792:	e8 ec fc ff ff       	call   800483 <dev_lookup>
  800797:	83 c4 10             	add    $0x10,%esp
  80079a:	85 c0                	test   %eax,%eax
  80079c:	78 1f                	js     8007bd <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80079e:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8007a2:	74 20                	je     8007c4 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8007aa:	85 c0                	test   %eax,%eax
  8007ac:	74 37                	je     8007e5 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007ae:	83 ec 04             	sub    $0x4,%esp
  8007b1:	ff 75 10             	push   0x10(%ebp)
  8007b4:	ff 75 0c             	push   0xc(%ebp)
  8007b7:	56                   	push   %esi
  8007b8:	ff d0                	call   *%eax
  8007ba:	83 c4 10             	add    $0x10,%esp
}
  8007bd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007c0:	5b                   	pop    %ebx
  8007c1:	5e                   	pop    %esi
  8007c2:	5d                   	pop    %ebp
  8007c3:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007c4:	a1 00 40 80 00       	mov    0x804000,%eax
  8007c9:	8b 40 48             	mov    0x48(%eax),%eax
  8007cc:	83 ec 04             	sub    $0x4,%esp
  8007cf:	53                   	push   %ebx
  8007d0:	50                   	push   %eax
  8007d1:	68 e1 22 80 00       	push   $0x8022e1
  8007d6:	e8 ca 0d 00 00       	call   8015a5 <cprintf>
		return -E_INVAL;
  8007db:	83 c4 10             	add    $0x10,%esp
  8007de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e3:	eb d8                	jmp    8007bd <write+0x53>
		return -E_NOT_SUPP;
  8007e5:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007ea:	eb d1                	jmp    8007bd <write+0x53>

008007ec <seek>:

int
seek(int fdnum, off_t offset)
{
  8007ec:	55                   	push   %ebp
  8007ed:	89 e5                	mov    %esp,%ebp
  8007ef:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f5:	50                   	push   %eax
  8007f6:	ff 75 08             	push   0x8(%ebp)
  8007f9:	e8 35 fc ff ff       	call   800433 <fd_lookup>
  8007fe:	83 c4 10             	add    $0x10,%esp
  800801:	85 c0                	test   %eax,%eax
  800803:	78 0e                	js     800813 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800805:	8b 55 0c             	mov    0xc(%ebp),%edx
  800808:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80080b:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80080e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800813:	c9                   	leave  
  800814:	c3                   	ret    

00800815 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	56                   	push   %esi
  800819:	53                   	push   %ebx
  80081a:	83 ec 18             	sub    $0x18,%esp
  80081d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800820:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800823:	50                   	push   %eax
  800824:	53                   	push   %ebx
  800825:	e8 09 fc ff ff       	call   800433 <fd_lookup>
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	85 c0                	test   %eax,%eax
  80082f:	78 34                	js     800865 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800831:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800834:	83 ec 08             	sub    $0x8,%esp
  800837:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80083a:	50                   	push   %eax
  80083b:	ff 36                	push   (%esi)
  80083d:	e8 41 fc ff ff       	call   800483 <dev_lookup>
  800842:	83 c4 10             	add    $0x10,%esp
  800845:	85 c0                	test   %eax,%eax
  800847:	78 1c                	js     800865 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800849:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80084d:	74 1d                	je     80086c <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80084f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800852:	8b 40 18             	mov    0x18(%eax),%eax
  800855:	85 c0                	test   %eax,%eax
  800857:	74 34                	je     80088d <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800859:	83 ec 08             	sub    $0x8,%esp
  80085c:	ff 75 0c             	push   0xc(%ebp)
  80085f:	56                   	push   %esi
  800860:	ff d0                	call   *%eax
  800862:	83 c4 10             	add    $0x10,%esp
}
  800865:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800868:	5b                   	pop    %ebx
  800869:	5e                   	pop    %esi
  80086a:	5d                   	pop    %ebp
  80086b:	c3                   	ret    
			thisenv->env_id, fdnum);
  80086c:	a1 00 40 80 00       	mov    0x804000,%eax
  800871:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800874:	83 ec 04             	sub    $0x4,%esp
  800877:	53                   	push   %ebx
  800878:	50                   	push   %eax
  800879:	68 a4 22 80 00       	push   $0x8022a4
  80087e:	e8 22 0d 00 00       	call   8015a5 <cprintf>
		return -E_INVAL;
  800883:	83 c4 10             	add    $0x10,%esp
  800886:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80088b:	eb d8                	jmp    800865 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80088d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800892:	eb d1                	jmp    800865 <ftruncate+0x50>

00800894 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	56                   	push   %esi
  800898:	53                   	push   %ebx
  800899:	83 ec 18             	sub    $0x18,%esp
  80089c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80089f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008a2:	50                   	push   %eax
  8008a3:	ff 75 08             	push   0x8(%ebp)
  8008a6:	e8 88 fb ff ff       	call   800433 <fd_lookup>
  8008ab:	83 c4 10             	add    $0x10,%esp
  8008ae:	85 c0                	test   %eax,%eax
  8008b0:	78 49                	js     8008fb <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8008b5:	83 ec 08             	sub    $0x8,%esp
  8008b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008bb:	50                   	push   %eax
  8008bc:	ff 36                	push   (%esi)
  8008be:	e8 c0 fb ff ff       	call   800483 <dev_lookup>
  8008c3:	83 c4 10             	add    $0x10,%esp
  8008c6:	85 c0                	test   %eax,%eax
  8008c8:	78 31                	js     8008fb <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8008ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008cd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008d1:	74 2f                	je     800902 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008d3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008d6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008dd:	00 00 00 
	stat->st_isdir = 0;
  8008e0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008e7:	00 00 00 
	stat->st_dev = dev;
  8008ea:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008f0:	83 ec 08             	sub    $0x8,%esp
  8008f3:	53                   	push   %ebx
  8008f4:	56                   	push   %esi
  8008f5:	ff 50 14             	call   *0x14(%eax)
  8008f8:	83 c4 10             	add    $0x10,%esp
}
  8008fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008fe:	5b                   	pop    %ebx
  8008ff:	5e                   	pop    %esi
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    
		return -E_NOT_SUPP;
  800902:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800907:	eb f2                	jmp    8008fb <fstat+0x67>

00800909 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	56                   	push   %esi
  80090d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80090e:	83 ec 08             	sub    $0x8,%esp
  800911:	6a 00                	push   $0x0
  800913:	ff 75 08             	push   0x8(%ebp)
  800916:	e8 e4 01 00 00       	call   800aff <open>
  80091b:	89 c3                	mov    %eax,%ebx
  80091d:	83 c4 10             	add    $0x10,%esp
  800920:	85 c0                	test   %eax,%eax
  800922:	78 1b                	js     80093f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800924:	83 ec 08             	sub    $0x8,%esp
  800927:	ff 75 0c             	push   0xc(%ebp)
  80092a:	50                   	push   %eax
  80092b:	e8 64 ff ff ff       	call   800894 <fstat>
  800930:	89 c6                	mov    %eax,%esi
	close(fd);
  800932:	89 1c 24             	mov    %ebx,(%esp)
  800935:	e8 26 fc ff ff       	call   800560 <close>
	return r;
  80093a:	83 c4 10             	add    $0x10,%esp
  80093d:	89 f3                	mov    %esi,%ebx
}
  80093f:	89 d8                	mov    %ebx,%eax
  800941:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800944:	5b                   	pop    %ebx
  800945:	5e                   	pop    %esi
  800946:	5d                   	pop    %ebp
  800947:	c3                   	ret    

00800948 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	56                   	push   %esi
  80094c:	53                   	push   %ebx
  80094d:	89 c6                	mov    %eax,%esi
  80094f:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800951:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800958:	74 27                	je     800981 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80095a:	6a 07                	push   $0x7
  80095c:	68 00 50 80 00       	push   $0x805000
  800961:	56                   	push   %esi
  800962:	ff 35 00 60 80 00    	push   0x806000
  800968:	e8 b9 15 00 00       	call   801f26 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80096d:	83 c4 0c             	add    $0xc,%esp
  800970:	6a 00                	push   $0x0
  800972:	53                   	push   %ebx
  800973:	6a 00                	push   $0x0
  800975:	e8 45 15 00 00       	call   801ebf <ipc_recv>
}
  80097a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80097d:	5b                   	pop    %ebx
  80097e:	5e                   	pop    %esi
  80097f:	5d                   	pop    %ebp
  800980:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800981:	83 ec 0c             	sub    $0xc,%esp
  800984:	6a 01                	push   $0x1
  800986:	e8 ef 15 00 00       	call   801f7a <ipc_find_env>
  80098b:	a3 00 60 80 00       	mov    %eax,0x806000
  800990:	83 c4 10             	add    $0x10,%esp
  800993:	eb c5                	jmp    80095a <fsipc+0x12>

00800995 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b3:	b8 02 00 00 00       	mov    $0x2,%eax
  8009b8:	e8 8b ff ff ff       	call   800948 <fsipc>
}
  8009bd:	c9                   	leave  
  8009be:	c3                   	ret    

008009bf <devfile_flush>:
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009cb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d5:	b8 06 00 00 00       	mov    $0x6,%eax
  8009da:	e8 69 ff ff ff       	call   800948 <fsipc>
}
  8009df:	c9                   	leave  
  8009e0:	c3                   	ret    

008009e1 <devfile_stat>:
{
  8009e1:	55                   	push   %ebp
  8009e2:	89 e5                	mov    %esp,%ebp
  8009e4:	53                   	push   %ebx
  8009e5:	83 ec 04             	sub    $0x4,%esp
  8009e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ee:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fb:	b8 05 00 00 00       	mov    $0x5,%eax
  800a00:	e8 43 ff ff ff       	call   800948 <fsipc>
  800a05:	85 c0                	test   %eax,%eax
  800a07:	78 2c                	js     800a35 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a09:	83 ec 08             	sub    $0x8,%esp
  800a0c:	68 00 50 80 00       	push   $0x805000
  800a11:	53                   	push   %ebx
  800a12:	e8 68 11 00 00       	call   801b7f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a17:	a1 80 50 80 00       	mov    0x805080,%eax
  800a1c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a22:	a1 84 50 80 00       	mov    0x805084,%eax
  800a27:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a2d:	83 c4 10             	add    $0x10,%esp
  800a30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a38:	c9                   	leave  
  800a39:	c3                   	ret    

00800a3a <devfile_write>:
{
  800a3a:	55                   	push   %ebp
  800a3b:	89 e5                	mov    %esp,%ebp
  800a3d:	83 ec 0c             	sub    $0xc,%esp
  800a40:	8b 45 10             	mov    0x10(%ebp),%eax
  800a43:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a48:	39 d0                	cmp    %edx,%eax
  800a4a:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800a50:	8b 52 0c             	mov    0xc(%edx),%edx
  800a53:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a59:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a5e:	50                   	push   %eax
  800a5f:	ff 75 0c             	push   0xc(%ebp)
  800a62:	68 08 50 80 00       	push   $0x805008
  800a67:	e8 a9 12 00 00       	call   801d15 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800a6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a71:	b8 04 00 00 00       	mov    $0x4,%eax
  800a76:	e8 cd fe ff ff       	call   800948 <fsipc>
}
  800a7b:	c9                   	leave  
  800a7c:	c3                   	ret    

00800a7d <devfile_read>:
{
  800a7d:	55                   	push   %ebp
  800a7e:	89 e5                	mov    %esp,%ebp
  800a80:	56                   	push   %esi
  800a81:	53                   	push   %ebx
  800a82:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a85:	8b 45 08             	mov    0x8(%ebp),%eax
  800a88:	8b 40 0c             	mov    0xc(%eax),%eax
  800a8b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a90:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a96:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9b:	b8 03 00 00 00       	mov    $0x3,%eax
  800aa0:	e8 a3 fe ff ff       	call   800948 <fsipc>
  800aa5:	89 c3                	mov    %eax,%ebx
  800aa7:	85 c0                	test   %eax,%eax
  800aa9:	78 1f                	js     800aca <devfile_read+0x4d>
	assert(r <= n);
  800aab:	39 f0                	cmp    %esi,%eax
  800aad:	77 24                	ja     800ad3 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800aaf:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ab4:	7f 33                	jg     800ae9 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ab6:	83 ec 04             	sub    $0x4,%esp
  800ab9:	50                   	push   %eax
  800aba:	68 00 50 80 00       	push   $0x805000
  800abf:	ff 75 0c             	push   0xc(%ebp)
  800ac2:	e8 4e 12 00 00       	call   801d15 <memmove>
	return r;
  800ac7:	83 c4 10             	add    $0x10,%esp
}
  800aca:	89 d8                	mov    %ebx,%eax
  800acc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800acf:	5b                   	pop    %ebx
  800ad0:	5e                   	pop    %esi
  800ad1:	5d                   	pop    %ebp
  800ad2:	c3                   	ret    
	assert(r <= n);
  800ad3:	68 14 23 80 00       	push   $0x802314
  800ad8:	68 1b 23 80 00       	push   $0x80231b
  800add:	6a 7c                	push   $0x7c
  800adf:	68 30 23 80 00       	push   $0x802330
  800ae4:	e8 e1 09 00 00       	call   8014ca <_panic>
	assert(r <= PGSIZE);
  800ae9:	68 3b 23 80 00       	push   $0x80233b
  800aee:	68 1b 23 80 00       	push   $0x80231b
  800af3:	6a 7d                	push   $0x7d
  800af5:	68 30 23 80 00       	push   $0x802330
  800afa:	e8 cb 09 00 00       	call   8014ca <_panic>

00800aff <open>:
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
  800b04:	83 ec 1c             	sub    $0x1c,%esp
  800b07:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b0a:	56                   	push   %esi
  800b0b:	e8 34 10 00 00       	call   801b44 <strlen>
  800b10:	83 c4 10             	add    $0x10,%esp
  800b13:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b18:	7f 6c                	jg     800b86 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800b1a:	83 ec 0c             	sub    $0xc,%esp
  800b1d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b20:	50                   	push   %eax
  800b21:	e8 bd f8 ff ff       	call   8003e3 <fd_alloc>
  800b26:	89 c3                	mov    %eax,%ebx
  800b28:	83 c4 10             	add    $0x10,%esp
  800b2b:	85 c0                	test   %eax,%eax
  800b2d:	78 3c                	js     800b6b <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800b2f:	83 ec 08             	sub    $0x8,%esp
  800b32:	56                   	push   %esi
  800b33:	68 00 50 80 00       	push   $0x805000
  800b38:	e8 42 10 00 00       	call   801b7f <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b40:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b45:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b48:	b8 01 00 00 00       	mov    $0x1,%eax
  800b4d:	e8 f6 fd ff ff       	call   800948 <fsipc>
  800b52:	89 c3                	mov    %eax,%ebx
  800b54:	83 c4 10             	add    $0x10,%esp
  800b57:	85 c0                	test   %eax,%eax
  800b59:	78 19                	js     800b74 <open+0x75>
	return fd2num(fd);
  800b5b:	83 ec 0c             	sub    $0xc,%esp
  800b5e:	ff 75 f4             	push   -0xc(%ebp)
  800b61:	e8 56 f8 ff ff       	call   8003bc <fd2num>
  800b66:	89 c3                	mov    %eax,%ebx
  800b68:	83 c4 10             	add    $0x10,%esp
}
  800b6b:	89 d8                	mov    %ebx,%eax
  800b6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    
		fd_close(fd, 0);
  800b74:	83 ec 08             	sub    $0x8,%esp
  800b77:	6a 00                	push   $0x0
  800b79:	ff 75 f4             	push   -0xc(%ebp)
  800b7c:	e8 58 f9 ff ff       	call   8004d9 <fd_close>
		return r;
  800b81:	83 c4 10             	add    $0x10,%esp
  800b84:	eb e5                	jmp    800b6b <open+0x6c>
		return -E_BAD_PATH;
  800b86:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b8b:	eb de                	jmp    800b6b <open+0x6c>

00800b8d <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b93:	ba 00 00 00 00       	mov    $0x0,%edx
  800b98:	b8 08 00 00 00       	mov    $0x8,%eax
  800b9d:	e8 a6 fd ff ff       	call   800948 <fsipc>
}
  800ba2:	c9                   	leave  
  800ba3:	c3                   	ret    

00800ba4 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800baa:	68 47 23 80 00       	push   $0x802347
  800baf:	ff 75 0c             	push   0xc(%ebp)
  800bb2:	e8 c8 0f 00 00       	call   801b7f <strcpy>
	return 0;
}
  800bb7:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbc:	c9                   	leave  
  800bbd:	c3                   	ret    

00800bbe <devsock_close>:
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	53                   	push   %ebx
  800bc2:	83 ec 10             	sub    $0x10,%esp
  800bc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bc8:	53                   	push   %ebx
  800bc9:	e8 e5 13 00 00       	call   801fb3 <pageref>
  800bce:	89 c2                	mov    %eax,%edx
  800bd0:	83 c4 10             	add    $0x10,%esp
		return 0;
  800bd3:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800bd8:	83 fa 01             	cmp    $0x1,%edx
  800bdb:	74 05                	je     800be2 <devsock_close+0x24>
}
  800bdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be0:	c9                   	leave  
  800be1:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800be2:	83 ec 0c             	sub    $0xc,%esp
  800be5:	ff 73 0c             	push   0xc(%ebx)
  800be8:	e8 b7 02 00 00       	call   800ea4 <nsipc_close>
  800bed:	83 c4 10             	add    $0x10,%esp
  800bf0:	eb eb                	jmp    800bdd <devsock_close+0x1f>

00800bf2 <devsock_write>:
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bf8:	6a 00                	push   $0x0
  800bfa:	ff 75 10             	push   0x10(%ebp)
  800bfd:	ff 75 0c             	push   0xc(%ebp)
  800c00:	8b 45 08             	mov    0x8(%ebp),%eax
  800c03:	ff 70 0c             	push   0xc(%eax)
  800c06:	e8 79 03 00 00       	call   800f84 <nsipc_send>
}
  800c0b:	c9                   	leave  
  800c0c:	c3                   	ret    

00800c0d <devsock_read>:
{
  800c0d:	55                   	push   %ebp
  800c0e:	89 e5                	mov    %esp,%ebp
  800c10:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c13:	6a 00                	push   $0x0
  800c15:	ff 75 10             	push   0x10(%ebp)
  800c18:	ff 75 0c             	push   0xc(%ebp)
  800c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1e:	ff 70 0c             	push   0xc(%eax)
  800c21:	e8 ef 02 00 00       	call   800f15 <nsipc_recv>
}
  800c26:	c9                   	leave  
  800c27:	c3                   	ret    

00800c28 <fd2sockid>:
{
  800c28:	55                   	push   %ebp
  800c29:	89 e5                	mov    %esp,%ebp
  800c2b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c2e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c31:	52                   	push   %edx
  800c32:	50                   	push   %eax
  800c33:	e8 fb f7 ff ff       	call   800433 <fd_lookup>
  800c38:	83 c4 10             	add    $0x10,%esp
  800c3b:	85 c0                	test   %eax,%eax
  800c3d:	78 10                	js     800c4f <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800c3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c42:	8b 0d 24 30 80 00    	mov    0x803024,%ecx
  800c48:	39 08                	cmp    %ecx,(%eax)
  800c4a:	75 05                	jne    800c51 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c4c:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c4f:	c9                   	leave  
  800c50:	c3                   	ret    
		return -E_NOT_SUPP;
  800c51:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c56:	eb f7                	jmp    800c4f <fd2sockid+0x27>

00800c58 <alloc_sockfd>:
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	56                   	push   %esi
  800c5c:	53                   	push   %ebx
  800c5d:	83 ec 1c             	sub    $0x1c,%esp
  800c60:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c65:	50                   	push   %eax
  800c66:	e8 78 f7 ff ff       	call   8003e3 <fd_alloc>
  800c6b:	89 c3                	mov    %eax,%ebx
  800c6d:	83 c4 10             	add    $0x10,%esp
  800c70:	85 c0                	test   %eax,%eax
  800c72:	78 43                	js     800cb7 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c74:	83 ec 04             	sub    $0x4,%esp
  800c77:	68 07 04 00 00       	push   $0x407
  800c7c:	ff 75 f4             	push   -0xc(%ebp)
  800c7f:	6a 00                	push   $0x0
  800c81:	e8 e4 f4 ff ff       	call   80016a <sys_page_alloc>
  800c86:	89 c3                	mov    %eax,%ebx
  800c88:	83 c4 10             	add    $0x10,%esp
  800c8b:	85 c0                	test   %eax,%eax
  800c8d:	78 28                	js     800cb7 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c8f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c92:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800c98:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c9d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800ca4:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ca7:	83 ec 0c             	sub    $0xc,%esp
  800caa:	50                   	push   %eax
  800cab:	e8 0c f7 ff ff       	call   8003bc <fd2num>
  800cb0:	89 c3                	mov    %eax,%ebx
  800cb2:	83 c4 10             	add    $0x10,%esp
  800cb5:	eb 0c                	jmp    800cc3 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800cb7:	83 ec 0c             	sub    $0xc,%esp
  800cba:	56                   	push   %esi
  800cbb:	e8 e4 01 00 00       	call   800ea4 <nsipc_close>
		return r;
  800cc0:	83 c4 10             	add    $0x10,%esp
}
  800cc3:	89 d8                	mov    %ebx,%eax
  800cc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cc8:	5b                   	pop    %ebx
  800cc9:	5e                   	pop    %esi
  800cca:	5d                   	pop    %ebp
  800ccb:	c3                   	ret    

00800ccc <accept>:
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd5:	e8 4e ff ff ff       	call   800c28 <fd2sockid>
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	78 1b                	js     800cf9 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cde:	83 ec 04             	sub    $0x4,%esp
  800ce1:	ff 75 10             	push   0x10(%ebp)
  800ce4:	ff 75 0c             	push   0xc(%ebp)
  800ce7:	50                   	push   %eax
  800ce8:	e8 0e 01 00 00       	call   800dfb <nsipc_accept>
  800ced:	83 c4 10             	add    $0x10,%esp
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	78 05                	js     800cf9 <accept+0x2d>
	return alloc_sockfd(r);
  800cf4:	e8 5f ff ff ff       	call   800c58 <alloc_sockfd>
}
  800cf9:	c9                   	leave  
  800cfa:	c3                   	ret    

00800cfb <bind>:
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d01:	8b 45 08             	mov    0x8(%ebp),%eax
  800d04:	e8 1f ff ff ff       	call   800c28 <fd2sockid>
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	78 12                	js     800d1f <bind+0x24>
	return nsipc_bind(r, name, namelen);
  800d0d:	83 ec 04             	sub    $0x4,%esp
  800d10:	ff 75 10             	push   0x10(%ebp)
  800d13:	ff 75 0c             	push   0xc(%ebp)
  800d16:	50                   	push   %eax
  800d17:	e8 31 01 00 00       	call   800e4d <nsipc_bind>
  800d1c:	83 c4 10             	add    $0x10,%esp
}
  800d1f:	c9                   	leave  
  800d20:	c3                   	ret    

00800d21 <shutdown>:
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d27:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2a:	e8 f9 fe ff ff       	call   800c28 <fd2sockid>
  800d2f:	85 c0                	test   %eax,%eax
  800d31:	78 0f                	js     800d42 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  800d33:	83 ec 08             	sub    $0x8,%esp
  800d36:	ff 75 0c             	push   0xc(%ebp)
  800d39:	50                   	push   %eax
  800d3a:	e8 43 01 00 00       	call   800e82 <nsipc_shutdown>
  800d3f:	83 c4 10             	add    $0x10,%esp
}
  800d42:	c9                   	leave  
  800d43:	c3                   	ret    

00800d44 <connect>:
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4d:	e8 d6 fe ff ff       	call   800c28 <fd2sockid>
  800d52:	85 c0                	test   %eax,%eax
  800d54:	78 12                	js     800d68 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  800d56:	83 ec 04             	sub    $0x4,%esp
  800d59:	ff 75 10             	push   0x10(%ebp)
  800d5c:	ff 75 0c             	push   0xc(%ebp)
  800d5f:	50                   	push   %eax
  800d60:	e8 59 01 00 00       	call   800ebe <nsipc_connect>
  800d65:	83 c4 10             	add    $0x10,%esp
}
  800d68:	c9                   	leave  
  800d69:	c3                   	ret    

00800d6a <listen>:
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d70:	8b 45 08             	mov    0x8(%ebp),%eax
  800d73:	e8 b0 fe ff ff       	call   800c28 <fd2sockid>
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	78 0f                	js     800d8b <listen+0x21>
	return nsipc_listen(r, backlog);
  800d7c:	83 ec 08             	sub    $0x8,%esp
  800d7f:	ff 75 0c             	push   0xc(%ebp)
  800d82:	50                   	push   %eax
  800d83:	e8 6b 01 00 00       	call   800ef3 <nsipc_listen>
  800d88:	83 c4 10             	add    $0x10,%esp
}
  800d8b:	c9                   	leave  
  800d8c:	c3                   	ret    

00800d8d <socket>:

int
socket(int domain, int type, int protocol)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d93:	ff 75 10             	push   0x10(%ebp)
  800d96:	ff 75 0c             	push   0xc(%ebp)
  800d99:	ff 75 08             	push   0x8(%ebp)
  800d9c:	e8 41 02 00 00       	call   800fe2 <nsipc_socket>
  800da1:	83 c4 10             	add    $0x10,%esp
  800da4:	85 c0                	test   %eax,%eax
  800da6:	78 05                	js     800dad <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800da8:	e8 ab fe ff ff       	call   800c58 <alloc_sockfd>
}
  800dad:	c9                   	leave  
  800dae:	c3                   	ret    

00800daf <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	53                   	push   %ebx
  800db3:	83 ec 04             	sub    $0x4,%esp
  800db6:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800db8:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  800dbf:	74 26                	je     800de7 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dc1:	6a 07                	push   $0x7
  800dc3:	68 00 70 80 00       	push   $0x807000
  800dc8:	53                   	push   %ebx
  800dc9:	ff 35 00 80 80 00    	push   0x808000
  800dcf:	e8 52 11 00 00       	call   801f26 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dd4:	83 c4 0c             	add    $0xc,%esp
  800dd7:	6a 00                	push   $0x0
  800dd9:	6a 00                	push   $0x0
  800ddb:	6a 00                	push   $0x0
  800ddd:	e8 dd 10 00 00       	call   801ebf <ipc_recv>
}
  800de2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800de5:	c9                   	leave  
  800de6:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800de7:	83 ec 0c             	sub    $0xc,%esp
  800dea:	6a 02                	push   $0x2
  800dec:	e8 89 11 00 00       	call   801f7a <ipc_find_env>
  800df1:	a3 00 80 80 00       	mov    %eax,0x808000
  800df6:	83 c4 10             	add    $0x10,%esp
  800df9:	eb c6                	jmp    800dc1 <nsipc+0x12>

00800dfb <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	56                   	push   %esi
  800dff:	53                   	push   %ebx
  800e00:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e03:	8b 45 08             	mov    0x8(%ebp),%eax
  800e06:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e0b:	8b 06                	mov    (%esi),%eax
  800e0d:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e12:	b8 01 00 00 00       	mov    $0x1,%eax
  800e17:	e8 93 ff ff ff       	call   800daf <nsipc>
  800e1c:	89 c3                	mov    %eax,%ebx
  800e1e:	85 c0                	test   %eax,%eax
  800e20:	79 09                	jns    800e2b <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800e22:	89 d8                	mov    %ebx,%eax
  800e24:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e27:	5b                   	pop    %ebx
  800e28:	5e                   	pop    %esi
  800e29:	5d                   	pop    %ebp
  800e2a:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e2b:	83 ec 04             	sub    $0x4,%esp
  800e2e:	ff 35 10 70 80 00    	push   0x807010
  800e34:	68 00 70 80 00       	push   $0x807000
  800e39:	ff 75 0c             	push   0xc(%ebp)
  800e3c:	e8 d4 0e 00 00       	call   801d15 <memmove>
		*addrlen = ret->ret_addrlen;
  800e41:	a1 10 70 80 00       	mov    0x807010,%eax
  800e46:	89 06                	mov    %eax,(%esi)
  800e48:	83 c4 10             	add    $0x10,%esp
	return r;
  800e4b:	eb d5                	jmp    800e22 <nsipc_accept+0x27>

00800e4d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e4d:	55                   	push   %ebp
  800e4e:	89 e5                	mov    %esp,%ebp
  800e50:	53                   	push   %ebx
  800e51:	83 ec 08             	sub    $0x8,%esp
  800e54:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e57:	8b 45 08             	mov    0x8(%ebp),%eax
  800e5a:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e5f:	53                   	push   %ebx
  800e60:	ff 75 0c             	push   0xc(%ebp)
  800e63:	68 04 70 80 00       	push   $0x807004
  800e68:	e8 a8 0e 00 00       	call   801d15 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e6d:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  800e73:	b8 02 00 00 00       	mov    $0x2,%eax
  800e78:	e8 32 ff ff ff       	call   800daf <nsipc>
}
  800e7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e80:	c9                   	leave  
  800e81:	c3                   	ret    

00800e82 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e88:	8b 45 08             	mov    0x8(%ebp),%eax
  800e8b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  800e90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e93:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  800e98:	b8 03 00 00 00       	mov    $0x3,%eax
  800e9d:	e8 0d ff ff ff       	call   800daf <nsipc>
}
  800ea2:	c9                   	leave  
  800ea3:	c3                   	ret    

00800ea4 <nsipc_close>:

int
nsipc_close(int s)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800eaa:	8b 45 08             	mov    0x8(%ebp),%eax
  800ead:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  800eb2:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb7:	e8 f3 fe ff ff       	call   800daf <nsipc>
}
  800ebc:	c9                   	leave  
  800ebd:	c3                   	ret    

00800ebe <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	53                   	push   %ebx
  800ec2:	83 ec 08             	sub    $0x8,%esp
  800ec5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ec8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ecb:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ed0:	53                   	push   %ebx
  800ed1:	ff 75 0c             	push   0xc(%ebp)
  800ed4:	68 04 70 80 00       	push   $0x807004
  800ed9:	e8 37 0e 00 00       	call   801d15 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ede:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  800ee4:	b8 05 00 00 00       	mov    $0x5,%eax
  800ee9:	e8 c1 fe ff ff       	call   800daf <nsipc>
}
  800eee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ef1:	c9                   	leave  
  800ef2:	c3                   	ret    

00800ef3 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ef3:	55                   	push   %ebp
  800ef4:	89 e5                	mov    %esp,%ebp
  800ef6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ef9:	8b 45 08             	mov    0x8(%ebp),%eax
  800efc:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  800f01:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f04:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  800f09:	b8 06 00 00 00       	mov    $0x6,%eax
  800f0e:	e8 9c fe ff ff       	call   800daf <nsipc>
}
  800f13:	c9                   	leave  
  800f14:	c3                   	ret    

00800f15 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	56                   	push   %esi
  800f19:	53                   	push   %ebx
  800f1a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f20:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  800f25:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  800f2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800f2e:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f33:	b8 07 00 00 00       	mov    $0x7,%eax
  800f38:	e8 72 fe ff ff       	call   800daf <nsipc>
  800f3d:	89 c3                	mov    %eax,%ebx
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	78 22                	js     800f65 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  800f43:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f48:	39 c6                	cmp    %eax,%esi
  800f4a:	0f 4e c6             	cmovle %esi,%eax
  800f4d:	39 c3                	cmp    %eax,%ebx
  800f4f:	7f 1d                	jg     800f6e <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f51:	83 ec 04             	sub    $0x4,%esp
  800f54:	53                   	push   %ebx
  800f55:	68 00 70 80 00       	push   $0x807000
  800f5a:	ff 75 0c             	push   0xc(%ebp)
  800f5d:	e8 b3 0d 00 00       	call   801d15 <memmove>
  800f62:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f65:	89 d8                	mov    %ebx,%eax
  800f67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f6a:	5b                   	pop    %ebx
  800f6b:	5e                   	pop    %esi
  800f6c:	5d                   	pop    %ebp
  800f6d:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f6e:	68 53 23 80 00       	push   $0x802353
  800f73:	68 1b 23 80 00       	push   $0x80231b
  800f78:	6a 62                	push   $0x62
  800f7a:	68 68 23 80 00       	push   $0x802368
  800f7f:	e8 46 05 00 00       	call   8014ca <_panic>

00800f84 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	53                   	push   %ebx
  800f88:	83 ec 04             	sub    $0x4,%esp
  800f8b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f91:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  800f96:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f9c:	7f 2e                	jg     800fcc <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f9e:	83 ec 04             	sub    $0x4,%esp
  800fa1:	53                   	push   %ebx
  800fa2:	ff 75 0c             	push   0xc(%ebp)
  800fa5:	68 0c 70 80 00       	push   $0x80700c
  800faa:	e8 66 0d 00 00       	call   801d15 <memmove>
	nsipcbuf.send.req_size = size;
  800faf:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  800fb5:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb8:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  800fbd:	b8 08 00 00 00       	mov    $0x8,%eax
  800fc2:	e8 e8 fd ff ff       	call   800daf <nsipc>
}
  800fc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fca:	c9                   	leave  
  800fcb:	c3                   	ret    
	assert(size < 1600);
  800fcc:	68 74 23 80 00       	push   $0x802374
  800fd1:	68 1b 23 80 00       	push   $0x80231b
  800fd6:	6a 6d                	push   $0x6d
  800fd8:	68 68 23 80 00       	push   $0x802368
  800fdd:	e8 e8 04 00 00       	call   8014ca <_panic>

00800fe2 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fe8:	8b 45 08             	mov    0x8(%ebp),%eax
  800feb:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  800ff0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ff3:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  800ff8:	8b 45 10             	mov    0x10(%ebp),%eax
  800ffb:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801000:	b8 09 00 00 00       	mov    $0x9,%eax
  801005:	e8 a5 fd ff ff       	call   800daf <nsipc>
}
  80100a:	c9                   	leave  
  80100b:	c3                   	ret    

0080100c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	56                   	push   %esi
  801010:	53                   	push   %ebx
  801011:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801014:	83 ec 0c             	sub    $0xc,%esp
  801017:	ff 75 08             	push   0x8(%ebp)
  80101a:	e8 ad f3 ff ff       	call   8003cc <fd2data>
  80101f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801021:	83 c4 08             	add    $0x8,%esp
  801024:	68 80 23 80 00       	push   $0x802380
  801029:	53                   	push   %ebx
  80102a:	e8 50 0b 00 00       	call   801b7f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80102f:	8b 46 04             	mov    0x4(%esi),%eax
  801032:	2b 06                	sub    (%esi),%eax
  801034:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80103a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801041:	00 00 00 
	stat->st_dev = &devpipe;
  801044:	c7 83 88 00 00 00 40 	movl   $0x803040,0x88(%ebx)
  80104b:	30 80 00 
	return 0;
}
  80104e:	b8 00 00 00 00       	mov    $0x0,%eax
  801053:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801056:	5b                   	pop    %ebx
  801057:	5e                   	pop    %esi
  801058:	5d                   	pop    %ebp
  801059:	c3                   	ret    

0080105a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	53                   	push   %ebx
  80105e:	83 ec 0c             	sub    $0xc,%esp
  801061:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801064:	53                   	push   %ebx
  801065:	6a 00                	push   $0x0
  801067:	e8 83 f1 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80106c:	89 1c 24             	mov    %ebx,(%esp)
  80106f:	e8 58 f3 ff ff       	call   8003cc <fd2data>
  801074:	83 c4 08             	add    $0x8,%esp
  801077:	50                   	push   %eax
  801078:	6a 00                	push   $0x0
  80107a:	e8 70 f1 ff ff       	call   8001ef <sys_page_unmap>
}
  80107f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801082:	c9                   	leave  
  801083:	c3                   	ret    

00801084 <_pipeisclosed>:
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	57                   	push   %edi
  801088:	56                   	push   %esi
  801089:	53                   	push   %ebx
  80108a:	83 ec 1c             	sub    $0x1c,%esp
  80108d:	89 c7                	mov    %eax,%edi
  80108f:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801091:	a1 00 40 80 00       	mov    0x804000,%eax
  801096:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801099:	83 ec 0c             	sub    $0xc,%esp
  80109c:	57                   	push   %edi
  80109d:	e8 11 0f 00 00       	call   801fb3 <pageref>
  8010a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010a5:	89 34 24             	mov    %esi,(%esp)
  8010a8:	e8 06 0f 00 00       	call   801fb3 <pageref>
		nn = thisenv->env_runs;
  8010ad:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8010b3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010b6:	83 c4 10             	add    $0x10,%esp
  8010b9:	39 cb                	cmp    %ecx,%ebx
  8010bb:	74 1b                	je     8010d8 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010bd:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010c0:	75 cf                	jne    801091 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010c2:	8b 42 58             	mov    0x58(%edx),%eax
  8010c5:	6a 01                	push   $0x1
  8010c7:	50                   	push   %eax
  8010c8:	53                   	push   %ebx
  8010c9:	68 87 23 80 00       	push   $0x802387
  8010ce:	e8 d2 04 00 00       	call   8015a5 <cprintf>
  8010d3:	83 c4 10             	add    $0x10,%esp
  8010d6:	eb b9                	jmp    801091 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010d8:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010db:	0f 94 c0             	sete   %al
  8010de:	0f b6 c0             	movzbl %al,%eax
}
  8010e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e4:	5b                   	pop    %ebx
  8010e5:	5e                   	pop    %esi
  8010e6:	5f                   	pop    %edi
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <devpipe_write>:
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	57                   	push   %edi
  8010ed:	56                   	push   %esi
  8010ee:	53                   	push   %ebx
  8010ef:	83 ec 28             	sub    $0x28,%esp
  8010f2:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8010f5:	56                   	push   %esi
  8010f6:	e8 d1 f2 ff ff       	call   8003cc <fd2data>
  8010fb:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8010fd:	83 c4 10             	add    $0x10,%esp
  801100:	bf 00 00 00 00       	mov    $0x0,%edi
  801105:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801108:	75 09                	jne    801113 <devpipe_write+0x2a>
	return i;
  80110a:	89 f8                	mov    %edi,%eax
  80110c:	eb 23                	jmp    801131 <devpipe_write+0x48>
			sys_yield();
  80110e:	e8 38 f0 ff ff       	call   80014b <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801113:	8b 43 04             	mov    0x4(%ebx),%eax
  801116:	8b 0b                	mov    (%ebx),%ecx
  801118:	8d 51 20             	lea    0x20(%ecx),%edx
  80111b:	39 d0                	cmp    %edx,%eax
  80111d:	72 1a                	jb     801139 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  80111f:	89 da                	mov    %ebx,%edx
  801121:	89 f0                	mov    %esi,%eax
  801123:	e8 5c ff ff ff       	call   801084 <_pipeisclosed>
  801128:	85 c0                	test   %eax,%eax
  80112a:	74 e2                	je     80110e <devpipe_write+0x25>
				return 0;
  80112c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801131:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801134:	5b                   	pop    %ebx
  801135:	5e                   	pop    %esi
  801136:	5f                   	pop    %edi
  801137:	5d                   	pop    %ebp
  801138:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801139:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80113c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801140:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801143:	89 c2                	mov    %eax,%edx
  801145:	c1 fa 1f             	sar    $0x1f,%edx
  801148:	89 d1                	mov    %edx,%ecx
  80114a:	c1 e9 1b             	shr    $0x1b,%ecx
  80114d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801150:	83 e2 1f             	and    $0x1f,%edx
  801153:	29 ca                	sub    %ecx,%edx
  801155:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801159:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80115d:	83 c0 01             	add    $0x1,%eax
  801160:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801163:	83 c7 01             	add    $0x1,%edi
  801166:	eb 9d                	jmp    801105 <devpipe_write+0x1c>

00801168 <devpipe_read>:
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	57                   	push   %edi
  80116c:	56                   	push   %esi
  80116d:	53                   	push   %ebx
  80116e:	83 ec 18             	sub    $0x18,%esp
  801171:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801174:	57                   	push   %edi
  801175:	e8 52 f2 ff ff       	call   8003cc <fd2data>
  80117a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80117c:	83 c4 10             	add    $0x10,%esp
  80117f:	be 00 00 00 00       	mov    $0x0,%esi
  801184:	3b 75 10             	cmp    0x10(%ebp),%esi
  801187:	75 13                	jne    80119c <devpipe_read+0x34>
	return i;
  801189:	89 f0                	mov    %esi,%eax
  80118b:	eb 02                	jmp    80118f <devpipe_read+0x27>
				return i;
  80118d:	89 f0                	mov    %esi,%eax
}
  80118f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801192:	5b                   	pop    %ebx
  801193:	5e                   	pop    %esi
  801194:	5f                   	pop    %edi
  801195:	5d                   	pop    %ebp
  801196:	c3                   	ret    
			sys_yield();
  801197:	e8 af ef ff ff       	call   80014b <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80119c:	8b 03                	mov    (%ebx),%eax
  80119e:	3b 43 04             	cmp    0x4(%ebx),%eax
  8011a1:	75 18                	jne    8011bb <devpipe_read+0x53>
			if (i > 0)
  8011a3:	85 f6                	test   %esi,%esi
  8011a5:	75 e6                	jne    80118d <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8011a7:	89 da                	mov    %ebx,%edx
  8011a9:	89 f8                	mov    %edi,%eax
  8011ab:	e8 d4 fe ff ff       	call   801084 <_pipeisclosed>
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	74 e3                	je     801197 <devpipe_read+0x2f>
				return 0;
  8011b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b9:	eb d4                	jmp    80118f <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011bb:	99                   	cltd   
  8011bc:	c1 ea 1b             	shr    $0x1b,%edx
  8011bf:	01 d0                	add    %edx,%eax
  8011c1:	83 e0 1f             	and    $0x1f,%eax
  8011c4:	29 d0                	sub    %edx,%eax
  8011c6:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ce:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011d1:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011d4:	83 c6 01             	add    $0x1,%esi
  8011d7:	eb ab                	jmp    801184 <devpipe_read+0x1c>

008011d9 <pipe>:
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	56                   	push   %esi
  8011dd:	53                   	push   %ebx
  8011de:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e4:	50                   	push   %eax
  8011e5:	e8 f9 f1 ff ff       	call   8003e3 <fd_alloc>
  8011ea:	89 c3                	mov    %eax,%ebx
  8011ec:	83 c4 10             	add    $0x10,%esp
  8011ef:	85 c0                	test   %eax,%eax
  8011f1:	0f 88 23 01 00 00    	js     80131a <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011f7:	83 ec 04             	sub    $0x4,%esp
  8011fa:	68 07 04 00 00       	push   $0x407
  8011ff:	ff 75 f4             	push   -0xc(%ebp)
  801202:	6a 00                	push   $0x0
  801204:	e8 61 ef ff ff       	call   80016a <sys_page_alloc>
  801209:	89 c3                	mov    %eax,%ebx
  80120b:	83 c4 10             	add    $0x10,%esp
  80120e:	85 c0                	test   %eax,%eax
  801210:	0f 88 04 01 00 00    	js     80131a <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801216:	83 ec 0c             	sub    $0xc,%esp
  801219:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121c:	50                   	push   %eax
  80121d:	e8 c1 f1 ff ff       	call   8003e3 <fd_alloc>
  801222:	89 c3                	mov    %eax,%ebx
  801224:	83 c4 10             	add    $0x10,%esp
  801227:	85 c0                	test   %eax,%eax
  801229:	0f 88 db 00 00 00    	js     80130a <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80122f:	83 ec 04             	sub    $0x4,%esp
  801232:	68 07 04 00 00       	push   $0x407
  801237:	ff 75 f0             	push   -0x10(%ebp)
  80123a:	6a 00                	push   $0x0
  80123c:	e8 29 ef ff ff       	call   80016a <sys_page_alloc>
  801241:	89 c3                	mov    %eax,%ebx
  801243:	83 c4 10             	add    $0x10,%esp
  801246:	85 c0                	test   %eax,%eax
  801248:	0f 88 bc 00 00 00    	js     80130a <pipe+0x131>
	va = fd2data(fd0);
  80124e:	83 ec 0c             	sub    $0xc,%esp
  801251:	ff 75 f4             	push   -0xc(%ebp)
  801254:	e8 73 f1 ff ff       	call   8003cc <fd2data>
  801259:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80125b:	83 c4 0c             	add    $0xc,%esp
  80125e:	68 07 04 00 00       	push   $0x407
  801263:	50                   	push   %eax
  801264:	6a 00                	push   $0x0
  801266:	e8 ff ee ff ff       	call   80016a <sys_page_alloc>
  80126b:	89 c3                	mov    %eax,%ebx
  80126d:	83 c4 10             	add    $0x10,%esp
  801270:	85 c0                	test   %eax,%eax
  801272:	0f 88 82 00 00 00    	js     8012fa <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801278:	83 ec 0c             	sub    $0xc,%esp
  80127b:	ff 75 f0             	push   -0x10(%ebp)
  80127e:	e8 49 f1 ff ff       	call   8003cc <fd2data>
  801283:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80128a:	50                   	push   %eax
  80128b:	6a 00                	push   $0x0
  80128d:	56                   	push   %esi
  80128e:	6a 00                	push   $0x0
  801290:	e8 18 ef ff ff       	call   8001ad <sys_page_map>
  801295:	89 c3                	mov    %eax,%ebx
  801297:	83 c4 20             	add    $0x20,%esp
  80129a:	85 c0                	test   %eax,%eax
  80129c:	78 4e                	js     8012ec <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  80129e:	a1 40 30 80 00       	mov    0x803040,%eax
  8012a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a6:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8012a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ab:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8012b2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012b5:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ba:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012c1:	83 ec 0c             	sub    $0xc,%esp
  8012c4:	ff 75 f4             	push   -0xc(%ebp)
  8012c7:	e8 f0 f0 ff ff       	call   8003bc <fd2num>
  8012cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012cf:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012d1:	83 c4 04             	add    $0x4,%esp
  8012d4:	ff 75 f0             	push   -0x10(%ebp)
  8012d7:	e8 e0 f0 ff ff       	call   8003bc <fd2num>
  8012dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012df:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012e2:	83 c4 10             	add    $0x10,%esp
  8012e5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ea:	eb 2e                	jmp    80131a <pipe+0x141>
	sys_page_unmap(0, va);
  8012ec:	83 ec 08             	sub    $0x8,%esp
  8012ef:	56                   	push   %esi
  8012f0:	6a 00                	push   $0x0
  8012f2:	e8 f8 ee ff ff       	call   8001ef <sys_page_unmap>
  8012f7:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8012fa:	83 ec 08             	sub    $0x8,%esp
  8012fd:	ff 75 f0             	push   -0x10(%ebp)
  801300:	6a 00                	push   $0x0
  801302:	e8 e8 ee ff ff       	call   8001ef <sys_page_unmap>
  801307:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80130a:	83 ec 08             	sub    $0x8,%esp
  80130d:	ff 75 f4             	push   -0xc(%ebp)
  801310:	6a 00                	push   $0x0
  801312:	e8 d8 ee ff ff       	call   8001ef <sys_page_unmap>
  801317:	83 c4 10             	add    $0x10,%esp
}
  80131a:	89 d8                	mov    %ebx,%eax
  80131c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131f:	5b                   	pop    %ebx
  801320:	5e                   	pop    %esi
  801321:	5d                   	pop    %ebp
  801322:	c3                   	ret    

00801323 <pipeisclosed>:
{
  801323:	55                   	push   %ebp
  801324:	89 e5                	mov    %esp,%ebp
  801326:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801329:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80132c:	50                   	push   %eax
  80132d:	ff 75 08             	push   0x8(%ebp)
  801330:	e8 fe f0 ff ff       	call   800433 <fd_lookup>
  801335:	83 c4 10             	add    $0x10,%esp
  801338:	85 c0                	test   %eax,%eax
  80133a:	78 18                	js     801354 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80133c:	83 ec 0c             	sub    $0xc,%esp
  80133f:	ff 75 f4             	push   -0xc(%ebp)
  801342:	e8 85 f0 ff ff       	call   8003cc <fd2data>
  801347:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801349:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134c:	e8 33 fd ff ff       	call   801084 <_pipeisclosed>
  801351:	83 c4 10             	add    $0x10,%esp
}
  801354:	c9                   	leave  
  801355:	c3                   	ret    

00801356 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801356:	b8 00 00 00 00       	mov    $0x0,%eax
  80135b:	c3                   	ret    

0080135c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80135c:	55                   	push   %ebp
  80135d:	89 e5                	mov    %esp,%ebp
  80135f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801362:	68 9f 23 80 00       	push   $0x80239f
  801367:	ff 75 0c             	push   0xc(%ebp)
  80136a:	e8 10 08 00 00       	call   801b7f <strcpy>
	return 0;
}
  80136f:	b8 00 00 00 00       	mov    $0x0,%eax
  801374:	c9                   	leave  
  801375:	c3                   	ret    

00801376 <devcons_write>:
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	57                   	push   %edi
  80137a:	56                   	push   %esi
  80137b:	53                   	push   %ebx
  80137c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801382:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801387:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80138d:	eb 2e                	jmp    8013bd <devcons_write+0x47>
		m = n - tot;
  80138f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801392:	29 f3                	sub    %esi,%ebx
  801394:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801399:	39 c3                	cmp    %eax,%ebx
  80139b:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80139e:	83 ec 04             	sub    $0x4,%esp
  8013a1:	53                   	push   %ebx
  8013a2:	89 f0                	mov    %esi,%eax
  8013a4:	03 45 0c             	add    0xc(%ebp),%eax
  8013a7:	50                   	push   %eax
  8013a8:	57                   	push   %edi
  8013a9:	e8 67 09 00 00       	call   801d15 <memmove>
		sys_cputs(buf, m);
  8013ae:	83 c4 08             	add    $0x8,%esp
  8013b1:	53                   	push   %ebx
  8013b2:	57                   	push   %edi
  8013b3:	e8 f6 ec ff ff       	call   8000ae <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013b8:	01 de                	add    %ebx,%esi
  8013ba:	83 c4 10             	add    $0x10,%esp
  8013bd:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013c0:	72 cd                	jb     80138f <devcons_write+0x19>
}
  8013c2:	89 f0                	mov    %esi,%eax
  8013c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c7:	5b                   	pop    %ebx
  8013c8:	5e                   	pop    %esi
  8013c9:	5f                   	pop    %edi
  8013ca:	5d                   	pop    %ebp
  8013cb:	c3                   	ret    

008013cc <devcons_read>:
{
  8013cc:	55                   	push   %ebp
  8013cd:	89 e5                	mov    %esp,%ebp
  8013cf:	83 ec 08             	sub    $0x8,%esp
  8013d2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8013d7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013db:	75 07                	jne    8013e4 <devcons_read+0x18>
  8013dd:	eb 1f                	jmp    8013fe <devcons_read+0x32>
		sys_yield();
  8013df:	e8 67 ed ff ff       	call   80014b <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8013e4:	e8 e3 ec ff ff       	call   8000cc <sys_cgetc>
  8013e9:	85 c0                	test   %eax,%eax
  8013eb:	74 f2                	je     8013df <devcons_read+0x13>
	if (c < 0)
  8013ed:	78 0f                	js     8013fe <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8013ef:	83 f8 04             	cmp    $0x4,%eax
  8013f2:	74 0c                	je     801400 <devcons_read+0x34>
	*(char*)vbuf = c;
  8013f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013f7:	88 02                	mov    %al,(%edx)
	return 1;
  8013f9:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8013fe:	c9                   	leave  
  8013ff:	c3                   	ret    
		return 0;
  801400:	b8 00 00 00 00       	mov    $0x0,%eax
  801405:	eb f7                	jmp    8013fe <devcons_read+0x32>

00801407 <cputchar>:
{
  801407:	55                   	push   %ebp
  801408:	89 e5                	mov    %esp,%ebp
  80140a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80140d:	8b 45 08             	mov    0x8(%ebp),%eax
  801410:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801413:	6a 01                	push   $0x1
  801415:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801418:	50                   	push   %eax
  801419:	e8 90 ec ff ff       	call   8000ae <sys_cputs>
}
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	c9                   	leave  
  801422:	c3                   	ret    

00801423 <getchar>:
{
  801423:	55                   	push   %ebp
  801424:	89 e5                	mov    %esp,%ebp
  801426:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801429:	6a 01                	push   $0x1
  80142b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80142e:	50                   	push   %eax
  80142f:	6a 00                	push   $0x0
  801431:	e8 66 f2 ff ff       	call   80069c <read>
	if (r < 0)
  801436:	83 c4 10             	add    $0x10,%esp
  801439:	85 c0                	test   %eax,%eax
  80143b:	78 06                	js     801443 <getchar+0x20>
	if (r < 1)
  80143d:	74 06                	je     801445 <getchar+0x22>
	return c;
  80143f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801443:	c9                   	leave  
  801444:	c3                   	ret    
		return -E_EOF;
  801445:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80144a:	eb f7                	jmp    801443 <getchar+0x20>

0080144c <iscons>:
{
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
  80144f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801452:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801455:	50                   	push   %eax
  801456:	ff 75 08             	push   0x8(%ebp)
  801459:	e8 d5 ef ff ff       	call   800433 <fd_lookup>
  80145e:	83 c4 10             	add    $0x10,%esp
  801461:	85 c0                	test   %eax,%eax
  801463:	78 11                	js     801476 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801465:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801468:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  80146e:	39 10                	cmp    %edx,(%eax)
  801470:	0f 94 c0             	sete   %al
  801473:	0f b6 c0             	movzbl %al,%eax
}
  801476:	c9                   	leave  
  801477:	c3                   	ret    

00801478 <opencons>:
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
  80147b:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80147e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801481:	50                   	push   %eax
  801482:	e8 5c ef ff ff       	call   8003e3 <fd_alloc>
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 3a                	js     8014c8 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80148e:	83 ec 04             	sub    $0x4,%esp
  801491:	68 07 04 00 00       	push   $0x407
  801496:	ff 75 f4             	push   -0xc(%ebp)
  801499:	6a 00                	push   $0x0
  80149b:	e8 ca ec ff ff       	call   80016a <sys_page_alloc>
  8014a0:	83 c4 10             	add    $0x10,%esp
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 21                	js     8014c8 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8014a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014aa:	8b 15 5c 30 80 00    	mov    0x80305c,%edx
  8014b0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014bc:	83 ec 0c             	sub    $0xc,%esp
  8014bf:	50                   	push   %eax
  8014c0:	e8 f7 ee ff ff       	call   8003bc <fd2num>
  8014c5:	83 c4 10             	add    $0x10,%esp
}
  8014c8:	c9                   	leave  
  8014c9:	c3                   	ret    

008014ca <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014ca:	55                   	push   %ebp
  8014cb:	89 e5                	mov    %esp,%ebp
  8014cd:	56                   	push   %esi
  8014ce:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014cf:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014d2:	8b 35 04 30 80 00    	mov    0x803004,%esi
  8014d8:	e8 4f ec ff ff       	call   80012c <sys_getenvid>
  8014dd:	83 ec 0c             	sub    $0xc,%esp
  8014e0:	ff 75 0c             	push   0xc(%ebp)
  8014e3:	ff 75 08             	push   0x8(%ebp)
  8014e6:	56                   	push   %esi
  8014e7:	50                   	push   %eax
  8014e8:	68 ac 23 80 00       	push   $0x8023ac
  8014ed:	e8 b3 00 00 00       	call   8015a5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014f2:	83 c4 18             	add    $0x18,%esp
  8014f5:	53                   	push   %ebx
  8014f6:	ff 75 10             	push   0x10(%ebp)
  8014f9:	e8 56 00 00 00       	call   801554 <vcprintf>
	cprintf("\n");
  8014fe:	c7 04 24 98 23 80 00 	movl   $0x802398,(%esp)
  801505:	e8 9b 00 00 00       	call   8015a5 <cprintf>
  80150a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80150d:	cc                   	int3   
  80150e:	eb fd                	jmp    80150d <_panic+0x43>

00801510 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	53                   	push   %ebx
  801514:	83 ec 04             	sub    $0x4,%esp
  801517:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80151a:	8b 13                	mov    (%ebx),%edx
  80151c:	8d 42 01             	lea    0x1(%edx),%eax
  80151f:	89 03                	mov    %eax,(%ebx)
  801521:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801524:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801528:	3d ff 00 00 00       	cmp    $0xff,%eax
  80152d:	74 09                	je     801538 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80152f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801533:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801536:	c9                   	leave  
  801537:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801538:	83 ec 08             	sub    $0x8,%esp
  80153b:	68 ff 00 00 00       	push   $0xff
  801540:	8d 43 08             	lea    0x8(%ebx),%eax
  801543:	50                   	push   %eax
  801544:	e8 65 eb ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  801549:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80154f:	83 c4 10             	add    $0x10,%esp
  801552:	eb db                	jmp    80152f <putch+0x1f>

00801554 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801554:	55                   	push   %ebp
  801555:	89 e5                	mov    %esp,%ebp
  801557:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80155d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801564:	00 00 00 
	b.cnt = 0;
  801567:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80156e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801571:	ff 75 0c             	push   0xc(%ebp)
  801574:	ff 75 08             	push   0x8(%ebp)
  801577:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80157d:	50                   	push   %eax
  80157e:	68 10 15 80 00       	push   $0x801510
  801583:	e8 14 01 00 00       	call   80169c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801588:	83 c4 08             	add    $0x8,%esp
  80158b:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  801591:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801597:	50                   	push   %eax
  801598:	e8 11 eb ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  80159d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015a3:	c9                   	leave  
  8015a4:	c3                   	ret    

008015a5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015ab:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015ae:	50                   	push   %eax
  8015af:	ff 75 08             	push   0x8(%ebp)
  8015b2:	e8 9d ff ff ff       	call   801554 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015b7:	c9                   	leave  
  8015b8:	c3                   	ret    

008015b9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015b9:	55                   	push   %ebp
  8015ba:	89 e5                	mov    %esp,%ebp
  8015bc:	57                   	push   %edi
  8015bd:	56                   	push   %esi
  8015be:	53                   	push   %ebx
  8015bf:	83 ec 1c             	sub    $0x1c,%esp
  8015c2:	89 c7                	mov    %eax,%edi
  8015c4:	89 d6                	mov    %edx,%esi
  8015c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015cc:	89 d1                	mov    %edx,%ecx
  8015ce:	89 c2                	mov    %eax,%edx
  8015d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015d3:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8015d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8015d9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015dc:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015df:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8015e6:	39 c2                	cmp    %eax,%edx
  8015e8:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8015eb:	72 3e                	jb     80162b <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015ed:	83 ec 0c             	sub    $0xc,%esp
  8015f0:	ff 75 18             	push   0x18(%ebp)
  8015f3:	83 eb 01             	sub    $0x1,%ebx
  8015f6:	53                   	push   %ebx
  8015f7:	50                   	push   %eax
  8015f8:	83 ec 08             	sub    $0x8,%esp
  8015fb:	ff 75 e4             	push   -0x1c(%ebp)
  8015fe:	ff 75 e0             	push   -0x20(%ebp)
  801601:	ff 75 dc             	push   -0x24(%ebp)
  801604:	ff 75 d8             	push   -0x28(%ebp)
  801607:	e8 e4 09 00 00       	call   801ff0 <__udivdi3>
  80160c:	83 c4 18             	add    $0x18,%esp
  80160f:	52                   	push   %edx
  801610:	50                   	push   %eax
  801611:	89 f2                	mov    %esi,%edx
  801613:	89 f8                	mov    %edi,%eax
  801615:	e8 9f ff ff ff       	call   8015b9 <printnum>
  80161a:	83 c4 20             	add    $0x20,%esp
  80161d:	eb 13                	jmp    801632 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80161f:	83 ec 08             	sub    $0x8,%esp
  801622:	56                   	push   %esi
  801623:	ff 75 18             	push   0x18(%ebp)
  801626:	ff d7                	call   *%edi
  801628:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80162b:	83 eb 01             	sub    $0x1,%ebx
  80162e:	85 db                	test   %ebx,%ebx
  801630:	7f ed                	jg     80161f <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801632:	83 ec 08             	sub    $0x8,%esp
  801635:	56                   	push   %esi
  801636:	83 ec 04             	sub    $0x4,%esp
  801639:	ff 75 e4             	push   -0x1c(%ebp)
  80163c:	ff 75 e0             	push   -0x20(%ebp)
  80163f:	ff 75 dc             	push   -0x24(%ebp)
  801642:	ff 75 d8             	push   -0x28(%ebp)
  801645:	e8 c6 0a 00 00       	call   802110 <__umoddi3>
  80164a:	83 c4 14             	add    $0x14,%esp
  80164d:	0f be 80 cf 23 80 00 	movsbl 0x8023cf(%eax),%eax
  801654:	50                   	push   %eax
  801655:	ff d7                	call   *%edi
}
  801657:	83 c4 10             	add    $0x10,%esp
  80165a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80165d:	5b                   	pop    %ebx
  80165e:	5e                   	pop    %esi
  80165f:	5f                   	pop    %edi
  801660:	5d                   	pop    %ebp
  801661:	c3                   	ret    

00801662 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801662:	55                   	push   %ebp
  801663:	89 e5                	mov    %esp,%ebp
  801665:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801668:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80166c:	8b 10                	mov    (%eax),%edx
  80166e:	3b 50 04             	cmp    0x4(%eax),%edx
  801671:	73 0a                	jae    80167d <sprintputch+0x1b>
		*b->buf++ = ch;
  801673:	8d 4a 01             	lea    0x1(%edx),%ecx
  801676:	89 08                	mov    %ecx,(%eax)
  801678:	8b 45 08             	mov    0x8(%ebp),%eax
  80167b:	88 02                	mov    %al,(%edx)
}
  80167d:	5d                   	pop    %ebp
  80167e:	c3                   	ret    

0080167f <printfmt>:
{
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801685:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801688:	50                   	push   %eax
  801689:	ff 75 10             	push   0x10(%ebp)
  80168c:	ff 75 0c             	push   0xc(%ebp)
  80168f:	ff 75 08             	push   0x8(%ebp)
  801692:	e8 05 00 00 00       	call   80169c <vprintfmt>
}
  801697:	83 c4 10             	add    $0x10,%esp
  80169a:	c9                   	leave  
  80169b:	c3                   	ret    

0080169c <vprintfmt>:
{
  80169c:	55                   	push   %ebp
  80169d:	89 e5                	mov    %esp,%ebp
  80169f:	57                   	push   %edi
  8016a0:	56                   	push   %esi
  8016a1:	53                   	push   %ebx
  8016a2:	83 ec 3c             	sub    $0x3c,%esp
  8016a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8016a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016ab:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016ae:	eb 0a                	jmp    8016ba <vprintfmt+0x1e>
			putch(ch, putdat);
  8016b0:	83 ec 08             	sub    $0x8,%esp
  8016b3:	53                   	push   %ebx
  8016b4:	50                   	push   %eax
  8016b5:	ff d6                	call   *%esi
  8016b7:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016ba:	83 c7 01             	add    $0x1,%edi
  8016bd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016c1:	83 f8 25             	cmp    $0x25,%eax
  8016c4:	74 0c                	je     8016d2 <vprintfmt+0x36>
			if (ch == '\0')
  8016c6:	85 c0                	test   %eax,%eax
  8016c8:	75 e6                	jne    8016b0 <vprintfmt+0x14>
}
  8016ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016cd:	5b                   	pop    %ebx
  8016ce:	5e                   	pop    %esi
  8016cf:	5f                   	pop    %edi
  8016d0:	5d                   	pop    %ebp
  8016d1:	c3                   	ret    
		padc = ' ';
  8016d2:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8016d6:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8016dd:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8016e4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8016eb:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8016f0:	8d 47 01             	lea    0x1(%edi),%eax
  8016f3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016f6:	0f b6 17             	movzbl (%edi),%edx
  8016f9:	8d 42 dd             	lea    -0x23(%edx),%eax
  8016fc:	3c 55                	cmp    $0x55,%al
  8016fe:	0f 87 bb 03 00 00    	ja     801abf <vprintfmt+0x423>
  801704:	0f b6 c0             	movzbl %al,%eax
  801707:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  80170e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801711:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801715:	eb d9                	jmp    8016f0 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801717:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80171a:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80171e:	eb d0                	jmp    8016f0 <vprintfmt+0x54>
  801720:	0f b6 d2             	movzbl %dl,%edx
  801723:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801726:	b8 00 00 00 00       	mov    $0x0,%eax
  80172b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80172e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801731:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801735:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801738:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80173b:	83 f9 09             	cmp    $0x9,%ecx
  80173e:	77 55                	ja     801795 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  801740:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801743:	eb e9                	jmp    80172e <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801745:	8b 45 14             	mov    0x14(%ebp),%eax
  801748:	8b 00                	mov    (%eax),%eax
  80174a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80174d:	8b 45 14             	mov    0x14(%ebp),%eax
  801750:	8d 40 04             	lea    0x4(%eax),%eax
  801753:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801756:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801759:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80175d:	79 91                	jns    8016f0 <vprintfmt+0x54>
				width = precision, precision = -1;
  80175f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801762:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801765:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80176c:	eb 82                	jmp    8016f0 <vprintfmt+0x54>
  80176e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801771:	85 d2                	test   %edx,%edx
  801773:	b8 00 00 00 00       	mov    $0x0,%eax
  801778:	0f 49 c2             	cmovns %edx,%eax
  80177b:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80177e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801781:	e9 6a ff ff ff       	jmp    8016f0 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801786:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801789:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801790:	e9 5b ff ff ff       	jmp    8016f0 <vprintfmt+0x54>
  801795:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801798:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80179b:	eb bc                	jmp    801759 <vprintfmt+0xbd>
			lflag++;
  80179d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8017a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017a3:	e9 48 ff ff ff       	jmp    8016f0 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8017a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ab:	8d 78 04             	lea    0x4(%eax),%edi
  8017ae:	83 ec 08             	sub    $0x8,%esp
  8017b1:	53                   	push   %ebx
  8017b2:	ff 30                	push   (%eax)
  8017b4:	ff d6                	call   *%esi
			break;
  8017b6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017b9:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017bc:	e9 9d 02 00 00       	jmp    801a5e <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8017c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8017c4:	8d 78 04             	lea    0x4(%eax),%edi
  8017c7:	8b 10                	mov    (%eax),%edx
  8017c9:	89 d0                	mov    %edx,%eax
  8017cb:	f7 d8                	neg    %eax
  8017cd:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017d0:	83 f8 0f             	cmp    $0xf,%eax
  8017d3:	7f 23                	jg     8017f8 <vprintfmt+0x15c>
  8017d5:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  8017dc:	85 d2                	test   %edx,%edx
  8017de:	74 18                	je     8017f8 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8017e0:	52                   	push   %edx
  8017e1:	68 2d 23 80 00       	push   $0x80232d
  8017e6:	53                   	push   %ebx
  8017e7:	56                   	push   %esi
  8017e8:	e8 92 fe ff ff       	call   80167f <printfmt>
  8017ed:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8017f0:	89 7d 14             	mov    %edi,0x14(%ebp)
  8017f3:	e9 66 02 00 00       	jmp    801a5e <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8017f8:	50                   	push   %eax
  8017f9:	68 e7 23 80 00       	push   $0x8023e7
  8017fe:	53                   	push   %ebx
  8017ff:	56                   	push   %esi
  801800:	e8 7a fe ff ff       	call   80167f <printfmt>
  801805:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801808:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80180b:	e9 4e 02 00 00       	jmp    801a5e <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  801810:	8b 45 14             	mov    0x14(%ebp),%eax
  801813:	83 c0 04             	add    $0x4,%eax
  801816:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801819:	8b 45 14             	mov    0x14(%ebp),%eax
  80181c:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80181e:	85 d2                	test   %edx,%edx
  801820:	b8 e0 23 80 00       	mov    $0x8023e0,%eax
  801825:	0f 45 c2             	cmovne %edx,%eax
  801828:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80182b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80182f:	7e 06                	jle    801837 <vprintfmt+0x19b>
  801831:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801835:	75 0d                	jne    801844 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801837:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80183a:	89 c7                	mov    %eax,%edi
  80183c:	03 45 e0             	add    -0x20(%ebp),%eax
  80183f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801842:	eb 55                	jmp    801899 <vprintfmt+0x1fd>
  801844:	83 ec 08             	sub    $0x8,%esp
  801847:	ff 75 d8             	push   -0x28(%ebp)
  80184a:	ff 75 cc             	push   -0x34(%ebp)
  80184d:	e8 0a 03 00 00       	call   801b5c <strnlen>
  801852:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801855:	29 c1                	sub    %eax,%ecx
  801857:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80185a:	83 c4 10             	add    $0x10,%esp
  80185d:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80185f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801863:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801866:	eb 0f                	jmp    801877 <vprintfmt+0x1db>
					putch(padc, putdat);
  801868:	83 ec 08             	sub    $0x8,%esp
  80186b:	53                   	push   %ebx
  80186c:	ff 75 e0             	push   -0x20(%ebp)
  80186f:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801871:	83 ef 01             	sub    $0x1,%edi
  801874:	83 c4 10             	add    $0x10,%esp
  801877:	85 ff                	test   %edi,%edi
  801879:	7f ed                	jg     801868 <vprintfmt+0x1cc>
  80187b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80187e:	85 d2                	test   %edx,%edx
  801880:	b8 00 00 00 00       	mov    $0x0,%eax
  801885:	0f 49 c2             	cmovns %edx,%eax
  801888:	29 c2                	sub    %eax,%edx
  80188a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80188d:	eb a8                	jmp    801837 <vprintfmt+0x19b>
					putch(ch, putdat);
  80188f:	83 ec 08             	sub    $0x8,%esp
  801892:	53                   	push   %ebx
  801893:	52                   	push   %edx
  801894:	ff d6                	call   *%esi
  801896:	83 c4 10             	add    $0x10,%esp
  801899:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80189c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80189e:	83 c7 01             	add    $0x1,%edi
  8018a1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018a5:	0f be d0             	movsbl %al,%edx
  8018a8:	85 d2                	test   %edx,%edx
  8018aa:	74 4b                	je     8018f7 <vprintfmt+0x25b>
  8018ac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018b0:	78 06                	js     8018b8 <vprintfmt+0x21c>
  8018b2:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018b6:	78 1e                	js     8018d6 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8018b8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018bc:	74 d1                	je     80188f <vprintfmt+0x1f3>
  8018be:	0f be c0             	movsbl %al,%eax
  8018c1:	83 e8 20             	sub    $0x20,%eax
  8018c4:	83 f8 5e             	cmp    $0x5e,%eax
  8018c7:	76 c6                	jbe    80188f <vprintfmt+0x1f3>
					putch('?', putdat);
  8018c9:	83 ec 08             	sub    $0x8,%esp
  8018cc:	53                   	push   %ebx
  8018cd:	6a 3f                	push   $0x3f
  8018cf:	ff d6                	call   *%esi
  8018d1:	83 c4 10             	add    $0x10,%esp
  8018d4:	eb c3                	jmp    801899 <vprintfmt+0x1fd>
  8018d6:	89 cf                	mov    %ecx,%edi
  8018d8:	eb 0e                	jmp    8018e8 <vprintfmt+0x24c>
				putch(' ', putdat);
  8018da:	83 ec 08             	sub    $0x8,%esp
  8018dd:	53                   	push   %ebx
  8018de:	6a 20                	push   $0x20
  8018e0:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8018e2:	83 ef 01             	sub    $0x1,%edi
  8018e5:	83 c4 10             	add    $0x10,%esp
  8018e8:	85 ff                	test   %edi,%edi
  8018ea:	7f ee                	jg     8018da <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8018ec:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8018ef:	89 45 14             	mov    %eax,0x14(%ebp)
  8018f2:	e9 67 01 00 00       	jmp    801a5e <vprintfmt+0x3c2>
  8018f7:	89 cf                	mov    %ecx,%edi
  8018f9:	eb ed                	jmp    8018e8 <vprintfmt+0x24c>
	if (lflag >= 2)
  8018fb:	83 f9 01             	cmp    $0x1,%ecx
  8018fe:	7f 1b                	jg     80191b <vprintfmt+0x27f>
	else if (lflag)
  801900:	85 c9                	test   %ecx,%ecx
  801902:	74 63                	je     801967 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  801904:	8b 45 14             	mov    0x14(%ebp),%eax
  801907:	8b 00                	mov    (%eax),%eax
  801909:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80190c:	99                   	cltd   
  80190d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801910:	8b 45 14             	mov    0x14(%ebp),%eax
  801913:	8d 40 04             	lea    0x4(%eax),%eax
  801916:	89 45 14             	mov    %eax,0x14(%ebp)
  801919:	eb 17                	jmp    801932 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80191b:	8b 45 14             	mov    0x14(%ebp),%eax
  80191e:	8b 50 04             	mov    0x4(%eax),%edx
  801921:	8b 00                	mov    (%eax),%eax
  801923:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801926:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801929:	8b 45 14             	mov    0x14(%ebp),%eax
  80192c:	8d 40 08             	lea    0x8(%eax),%eax
  80192f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801932:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801935:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801938:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80193d:	85 c9                	test   %ecx,%ecx
  80193f:	0f 89 ff 00 00 00    	jns    801a44 <vprintfmt+0x3a8>
				putch('-', putdat);
  801945:	83 ec 08             	sub    $0x8,%esp
  801948:	53                   	push   %ebx
  801949:	6a 2d                	push   $0x2d
  80194b:	ff d6                	call   *%esi
				num = -(long long) num;
  80194d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801950:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801953:	f7 da                	neg    %edx
  801955:	83 d1 00             	adc    $0x0,%ecx
  801958:	f7 d9                	neg    %ecx
  80195a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80195d:	bf 0a 00 00 00       	mov    $0xa,%edi
  801962:	e9 dd 00 00 00       	jmp    801a44 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801967:	8b 45 14             	mov    0x14(%ebp),%eax
  80196a:	8b 00                	mov    (%eax),%eax
  80196c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80196f:	99                   	cltd   
  801970:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801973:	8b 45 14             	mov    0x14(%ebp),%eax
  801976:	8d 40 04             	lea    0x4(%eax),%eax
  801979:	89 45 14             	mov    %eax,0x14(%ebp)
  80197c:	eb b4                	jmp    801932 <vprintfmt+0x296>
	if (lflag >= 2)
  80197e:	83 f9 01             	cmp    $0x1,%ecx
  801981:	7f 1e                	jg     8019a1 <vprintfmt+0x305>
	else if (lflag)
  801983:	85 c9                	test   %ecx,%ecx
  801985:	74 32                	je     8019b9 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  801987:	8b 45 14             	mov    0x14(%ebp),%eax
  80198a:	8b 10                	mov    (%eax),%edx
  80198c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801991:	8d 40 04             	lea    0x4(%eax),%eax
  801994:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801997:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80199c:	e9 a3 00 00 00       	jmp    801a44 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8019a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a4:	8b 10                	mov    (%eax),%edx
  8019a6:	8b 48 04             	mov    0x4(%eax),%ecx
  8019a9:	8d 40 08             	lea    0x8(%eax),%eax
  8019ac:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019af:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8019b4:	e9 8b 00 00 00       	jmp    801a44 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019bc:	8b 10                	mov    (%eax),%edx
  8019be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019c3:	8d 40 04             	lea    0x4(%eax),%eax
  8019c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019c9:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8019ce:	eb 74                	jmp    801a44 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8019d0:	83 f9 01             	cmp    $0x1,%ecx
  8019d3:	7f 1b                	jg     8019f0 <vprintfmt+0x354>
	else if (lflag)
  8019d5:	85 c9                	test   %ecx,%ecx
  8019d7:	74 2c                	je     801a05 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8019d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019dc:	8b 10                	mov    (%eax),%edx
  8019de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019e3:	8d 40 04             	lea    0x4(%eax),%eax
  8019e6:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019e9:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8019ee:	eb 54                	jmp    801a44 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8019f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f3:	8b 10                	mov    (%eax),%edx
  8019f5:	8b 48 04             	mov    0x4(%eax),%ecx
  8019f8:	8d 40 08             	lea    0x8(%eax),%eax
  8019fb:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019fe:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  801a03:	eb 3f                	jmp    801a44 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801a05:	8b 45 14             	mov    0x14(%ebp),%eax
  801a08:	8b 10                	mov    (%eax),%edx
  801a0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a0f:	8d 40 04             	lea    0x4(%eax),%eax
  801a12:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a15:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801a1a:	eb 28                	jmp    801a44 <vprintfmt+0x3a8>
			putch('0', putdat);
  801a1c:	83 ec 08             	sub    $0x8,%esp
  801a1f:	53                   	push   %ebx
  801a20:	6a 30                	push   $0x30
  801a22:	ff d6                	call   *%esi
			putch('x', putdat);
  801a24:	83 c4 08             	add    $0x8,%esp
  801a27:	53                   	push   %ebx
  801a28:	6a 78                	push   $0x78
  801a2a:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a2c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a2f:	8b 10                	mov    (%eax),%edx
  801a31:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a36:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a39:	8d 40 04             	lea    0x4(%eax),%eax
  801a3c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a3f:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801a44:	83 ec 0c             	sub    $0xc,%esp
  801a47:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801a4b:	50                   	push   %eax
  801a4c:	ff 75 e0             	push   -0x20(%ebp)
  801a4f:	57                   	push   %edi
  801a50:	51                   	push   %ecx
  801a51:	52                   	push   %edx
  801a52:	89 da                	mov    %ebx,%edx
  801a54:	89 f0                	mov    %esi,%eax
  801a56:	e8 5e fb ff ff       	call   8015b9 <printnum>
			break;
  801a5b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801a5e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a61:	e9 54 fc ff ff       	jmp    8016ba <vprintfmt+0x1e>
	if (lflag >= 2)
  801a66:	83 f9 01             	cmp    $0x1,%ecx
  801a69:	7f 1b                	jg     801a86 <vprintfmt+0x3ea>
	else if (lflag)
  801a6b:	85 c9                	test   %ecx,%ecx
  801a6d:	74 2c                	je     801a9b <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801a6f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a72:	8b 10                	mov    (%eax),%edx
  801a74:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a79:	8d 40 04             	lea    0x4(%eax),%eax
  801a7c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a7f:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  801a84:	eb be                	jmp    801a44 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801a86:	8b 45 14             	mov    0x14(%ebp),%eax
  801a89:	8b 10                	mov    (%eax),%edx
  801a8b:	8b 48 04             	mov    0x4(%eax),%ecx
  801a8e:	8d 40 08             	lea    0x8(%eax),%eax
  801a91:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a94:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  801a99:	eb a9                	jmp    801a44 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801a9b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a9e:	8b 10                	mov    (%eax),%edx
  801aa0:	b9 00 00 00 00       	mov    $0x0,%ecx
  801aa5:	8d 40 04             	lea    0x4(%eax),%eax
  801aa8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801aab:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  801ab0:	eb 92                	jmp    801a44 <vprintfmt+0x3a8>
			putch(ch, putdat);
  801ab2:	83 ec 08             	sub    $0x8,%esp
  801ab5:	53                   	push   %ebx
  801ab6:	6a 25                	push   $0x25
  801ab8:	ff d6                	call   *%esi
			break;
  801aba:	83 c4 10             	add    $0x10,%esp
  801abd:	eb 9f                	jmp    801a5e <vprintfmt+0x3c2>
			putch('%', putdat);
  801abf:	83 ec 08             	sub    $0x8,%esp
  801ac2:	53                   	push   %ebx
  801ac3:	6a 25                	push   $0x25
  801ac5:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ac7:	83 c4 10             	add    $0x10,%esp
  801aca:	89 f8                	mov    %edi,%eax
  801acc:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801ad0:	74 05                	je     801ad7 <vprintfmt+0x43b>
  801ad2:	83 e8 01             	sub    $0x1,%eax
  801ad5:	eb f5                	jmp    801acc <vprintfmt+0x430>
  801ad7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ada:	eb 82                	jmp    801a5e <vprintfmt+0x3c2>

00801adc <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801adc:	55                   	push   %ebp
  801add:	89 e5                	mov    %esp,%ebp
  801adf:	83 ec 18             	sub    $0x18,%esp
  801ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae5:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ae8:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801aeb:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801aef:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801af2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801af9:	85 c0                	test   %eax,%eax
  801afb:	74 26                	je     801b23 <vsnprintf+0x47>
  801afd:	85 d2                	test   %edx,%edx
  801aff:	7e 22                	jle    801b23 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b01:	ff 75 14             	push   0x14(%ebp)
  801b04:	ff 75 10             	push   0x10(%ebp)
  801b07:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b0a:	50                   	push   %eax
  801b0b:	68 62 16 80 00       	push   $0x801662
  801b10:	e8 87 fb ff ff       	call   80169c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b15:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b18:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1e:	83 c4 10             	add    $0x10,%esp
}
  801b21:	c9                   	leave  
  801b22:	c3                   	ret    
		return -E_INVAL;
  801b23:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b28:	eb f7                	jmp    801b21 <vsnprintf+0x45>

00801b2a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b30:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b33:	50                   	push   %eax
  801b34:	ff 75 10             	push   0x10(%ebp)
  801b37:	ff 75 0c             	push   0xc(%ebp)
  801b3a:	ff 75 08             	push   0x8(%ebp)
  801b3d:	e8 9a ff ff ff       	call   801adc <vsnprintf>
	va_end(ap);

	return rc;
}
  801b42:	c9                   	leave  
  801b43:	c3                   	ret    

00801b44 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b4a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4f:	eb 03                	jmp    801b54 <strlen+0x10>
		n++;
  801b51:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801b54:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b58:	75 f7                	jne    801b51 <strlen+0xd>
	return n;
}
  801b5a:	5d                   	pop    %ebp
  801b5b:	c3                   	ret    

00801b5c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b5c:	55                   	push   %ebp
  801b5d:	89 e5                	mov    %esp,%ebp
  801b5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b62:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b65:	b8 00 00 00 00       	mov    $0x0,%eax
  801b6a:	eb 03                	jmp    801b6f <strnlen+0x13>
		n++;
  801b6c:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b6f:	39 d0                	cmp    %edx,%eax
  801b71:	74 08                	je     801b7b <strnlen+0x1f>
  801b73:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801b77:	75 f3                	jne    801b6c <strnlen+0x10>
  801b79:	89 c2                	mov    %eax,%edx
	return n;
}
  801b7b:	89 d0                	mov    %edx,%eax
  801b7d:	5d                   	pop    %ebp
  801b7e:	c3                   	ret    

00801b7f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	53                   	push   %ebx
  801b83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b86:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b89:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8e:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801b92:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801b95:	83 c0 01             	add    $0x1,%eax
  801b98:	84 d2                	test   %dl,%dl
  801b9a:	75 f2                	jne    801b8e <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801b9c:	89 c8                	mov    %ecx,%eax
  801b9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ba1:	c9                   	leave  
  801ba2:	c3                   	ret    

00801ba3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	53                   	push   %ebx
  801ba7:	83 ec 10             	sub    $0x10,%esp
  801baa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bad:	53                   	push   %ebx
  801bae:	e8 91 ff ff ff       	call   801b44 <strlen>
  801bb3:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801bb6:	ff 75 0c             	push   0xc(%ebp)
  801bb9:	01 d8                	add    %ebx,%eax
  801bbb:	50                   	push   %eax
  801bbc:	e8 be ff ff ff       	call   801b7f <strcpy>
	return dst;
}
  801bc1:	89 d8                	mov    %ebx,%eax
  801bc3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc6:	c9                   	leave  
  801bc7:	c3                   	ret    

00801bc8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bc8:	55                   	push   %ebp
  801bc9:	89 e5                	mov    %esp,%ebp
  801bcb:	56                   	push   %esi
  801bcc:	53                   	push   %ebx
  801bcd:	8b 75 08             	mov    0x8(%ebp),%esi
  801bd0:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bd3:	89 f3                	mov    %esi,%ebx
  801bd5:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bd8:	89 f0                	mov    %esi,%eax
  801bda:	eb 0f                	jmp    801beb <strncpy+0x23>
		*dst++ = *src;
  801bdc:	83 c0 01             	add    $0x1,%eax
  801bdf:	0f b6 0a             	movzbl (%edx),%ecx
  801be2:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801be5:	80 f9 01             	cmp    $0x1,%cl
  801be8:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801beb:	39 d8                	cmp    %ebx,%eax
  801bed:	75 ed                	jne    801bdc <strncpy+0x14>
	}
	return ret;
}
  801bef:	89 f0                	mov    %esi,%eax
  801bf1:	5b                   	pop    %ebx
  801bf2:	5e                   	pop    %esi
  801bf3:	5d                   	pop    %ebp
  801bf4:	c3                   	ret    

00801bf5 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bf5:	55                   	push   %ebp
  801bf6:	89 e5                	mov    %esp,%ebp
  801bf8:	56                   	push   %esi
  801bf9:	53                   	push   %ebx
  801bfa:	8b 75 08             	mov    0x8(%ebp),%esi
  801bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c00:	8b 55 10             	mov    0x10(%ebp),%edx
  801c03:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c05:	85 d2                	test   %edx,%edx
  801c07:	74 21                	je     801c2a <strlcpy+0x35>
  801c09:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c0d:	89 f2                	mov    %esi,%edx
  801c0f:	eb 09                	jmp    801c1a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c11:	83 c1 01             	add    $0x1,%ecx
  801c14:	83 c2 01             	add    $0x1,%edx
  801c17:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801c1a:	39 c2                	cmp    %eax,%edx
  801c1c:	74 09                	je     801c27 <strlcpy+0x32>
  801c1e:	0f b6 19             	movzbl (%ecx),%ebx
  801c21:	84 db                	test   %bl,%bl
  801c23:	75 ec                	jne    801c11 <strlcpy+0x1c>
  801c25:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801c27:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c2a:	29 f0                	sub    %esi,%eax
}
  801c2c:	5b                   	pop    %ebx
  801c2d:	5e                   	pop    %esi
  801c2e:	5d                   	pop    %ebp
  801c2f:	c3                   	ret    

00801c30 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c30:	55                   	push   %ebp
  801c31:	89 e5                	mov    %esp,%ebp
  801c33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c36:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c39:	eb 06                	jmp    801c41 <strcmp+0x11>
		p++, q++;
  801c3b:	83 c1 01             	add    $0x1,%ecx
  801c3e:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801c41:	0f b6 01             	movzbl (%ecx),%eax
  801c44:	84 c0                	test   %al,%al
  801c46:	74 04                	je     801c4c <strcmp+0x1c>
  801c48:	3a 02                	cmp    (%edx),%al
  801c4a:	74 ef                	je     801c3b <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c4c:	0f b6 c0             	movzbl %al,%eax
  801c4f:	0f b6 12             	movzbl (%edx),%edx
  801c52:	29 d0                	sub    %edx,%eax
}
  801c54:	5d                   	pop    %ebp
  801c55:	c3                   	ret    

00801c56 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c56:	55                   	push   %ebp
  801c57:	89 e5                	mov    %esp,%ebp
  801c59:	53                   	push   %ebx
  801c5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c60:	89 c3                	mov    %eax,%ebx
  801c62:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c65:	eb 06                	jmp    801c6d <strncmp+0x17>
		n--, p++, q++;
  801c67:	83 c0 01             	add    $0x1,%eax
  801c6a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801c6d:	39 d8                	cmp    %ebx,%eax
  801c6f:	74 18                	je     801c89 <strncmp+0x33>
  801c71:	0f b6 08             	movzbl (%eax),%ecx
  801c74:	84 c9                	test   %cl,%cl
  801c76:	74 04                	je     801c7c <strncmp+0x26>
  801c78:	3a 0a                	cmp    (%edx),%cl
  801c7a:	74 eb                	je     801c67 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c7c:	0f b6 00             	movzbl (%eax),%eax
  801c7f:	0f b6 12             	movzbl (%edx),%edx
  801c82:	29 d0                	sub    %edx,%eax
}
  801c84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c87:	c9                   	leave  
  801c88:	c3                   	ret    
		return 0;
  801c89:	b8 00 00 00 00       	mov    $0x0,%eax
  801c8e:	eb f4                	jmp    801c84 <strncmp+0x2e>

00801c90 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	8b 45 08             	mov    0x8(%ebp),%eax
  801c96:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c9a:	eb 03                	jmp    801c9f <strchr+0xf>
  801c9c:	83 c0 01             	add    $0x1,%eax
  801c9f:	0f b6 10             	movzbl (%eax),%edx
  801ca2:	84 d2                	test   %dl,%dl
  801ca4:	74 06                	je     801cac <strchr+0x1c>
		if (*s == c)
  801ca6:	38 ca                	cmp    %cl,%dl
  801ca8:	75 f2                	jne    801c9c <strchr+0xc>
  801caa:	eb 05                	jmp    801cb1 <strchr+0x21>
			return (char *) s;
	return 0;
  801cac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cb1:	5d                   	pop    %ebp
  801cb2:	c3                   	ret    

00801cb3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cbd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cc0:	38 ca                	cmp    %cl,%dl
  801cc2:	74 09                	je     801ccd <strfind+0x1a>
  801cc4:	84 d2                	test   %dl,%dl
  801cc6:	74 05                	je     801ccd <strfind+0x1a>
	for (; *s; s++)
  801cc8:	83 c0 01             	add    $0x1,%eax
  801ccb:	eb f0                	jmp    801cbd <strfind+0xa>
			break;
	return (char *) s;
}
  801ccd:	5d                   	pop    %ebp
  801cce:	c3                   	ret    

00801ccf <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	57                   	push   %edi
  801cd3:	56                   	push   %esi
  801cd4:	53                   	push   %ebx
  801cd5:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cd8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cdb:	85 c9                	test   %ecx,%ecx
  801cdd:	74 2f                	je     801d0e <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cdf:	89 f8                	mov    %edi,%eax
  801ce1:	09 c8                	or     %ecx,%eax
  801ce3:	a8 03                	test   $0x3,%al
  801ce5:	75 21                	jne    801d08 <memset+0x39>
		c &= 0xFF;
  801ce7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ceb:	89 d0                	mov    %edx,%eax
  801ced:	c1 e0 08             	shl    $0x8,%eax
  801cf0:	89 d3                	mov    %edx,%ebx
  801cf2:	c1 e3 18             	shl    $0x18,%ebx
  801cf5:	89 d6                	mov    %edx,%esi
  801cf7:	c1 e6 10             	shl    $0x10,%esi
  801cfa:	09 f3                	or     %esi,%ebx
  801cfc:	09 da                	or     %ebx,%edx
  801cfe:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801d00:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801d03:	fc                   	cld    
  801d04:	f3 ab                	rep stos %eax,%es:(%edi)
  801d06:	eb 06                	jmp    801d0e <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d0b:	fc                   	cld    
  801d0c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d0e:	89 f8                	mov    %edi,%eax
  801d10:	5b                   	pop    %ebx
  801d11:	5e                   	pop    %esi
  801d12:	5f                   	pop    %edi
  801d13:	5d                   	pop    %ebp
  801d14:	c3                   	ret    

00801d15 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d15:	55                   	push   %ebp
  801d16:	89 e5                	mov    %esp,%ebp
  801d18:	57                   	push   %edi
  801d19:	56                   	push   %esi
  801d1a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d20:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d23:	39 c6                	cmp    %eax,%esi
  801d25:	73 32                	jae    801d59 <memmove+0x44>
  801d27:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d2a:	39 c2                	cmp    %eax,%edx
  801d2c:	76 2b                	jbe    801d59 <memmove+0x44>
		s += n;
		d += n;
  801d2e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d31:	89 d6                	mov    %edx,%esi
  801d33:	09 fe                	or     %edi,%esi
  801d35:	09 ce                	or     %ecx,%esi
  801d37:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d3d:	75 0e                	jne    801d4d <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d3f:	83 ef 04             	sub    $0x4,%edi
  801d42:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d45:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801d48:	fd                   	std    
  801d49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d4b:	eb 09                	jmp    801d56 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d4d:	83 ef 01             	sub    $0x1,%edi
  801d50:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801d53:	fd                   	std    
  801d54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d56:	fc                   	cld    
  801d57:	eb 1a                	jmp    801d73 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d59:	89 f2                	mov    %esi,%edx
  801d5b:	09 c2                	or     %eax,%edx
  801d5d:	09 ca                	or     %ecx,%edx
  801d5f:	f6 c2 03             	test   $0x3,%dl
  801d62:	75 0a                	jne    801d6e <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801d64:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801d67:	89 c7                	mov    %eax,%edi
  801d69:	fc                   	cld    
  801d6a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d6c:	eb 05                	jmp    801d73 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801d6e:	89 c7                	mov    %eax,%edi
  801d70:	fc                   	cld    
  801d71:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d73:	5e                   	pop    %esi
  801d74:	5f                   	pop    %edi
  801d75:	5d                   	pop    %ebp
  801d76:	c3                   	ret    

00801d77 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d77:	55                   	push   %ebp
  801d78:	89 e5                	mov    %esp,%ebp
  801d7a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d7d:	ff 75 10             	push   0x10(%ebp)
  801d80:	ff 75 0c             	push   0xc(%ebp)
  801d83:	ff 75 08             	push   0x8(%ebp)
  801d86:	e8 8a ff ff ff       	call   801d15 <memmove>
}
  801d8b:	c9                   	leave  
  801d8c:	c3                   	ret    

00801d8d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d8d:	55                   	push   %ebp
  801d8e:	89 e5                	mov    %esp,%ebp
  801d90:	56                   	push   %esi
  801d91:	53                   	push   %ebx
  801d92:	8b 45 08             	mov    0x8(%ebp),%eax
  801d95:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d98:	89 c6                	mov    %eax,%esi
  801d9a:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d9d:	eb 06                	jmp    801da5 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801d9f:	83 c0 01             	add    $0x1,%eax
  801da2:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801da5:	39 f0                	cmp    %esi,%eax
  801da7:	74 14                	je     801dbd <memcmp+0x30>
		if (*s1 != *s2)
  801da9:	0f b6 08             	movzbl (%eax),%ecx
  801dac:	0f b6 1a             	movzbl (%edx),%ebx
  801daf:	38 d9                	cmp    %bl,%cl
  801db1:	74 ec                	je     801d9f <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801db3:	0f b6 c1             	movzbl %cl,%eax
  801db6:	0f b6 db             	movzbl %bl,%ebx
  801db9:	29 d8                	sub    %ebx,%eax
  801dbb:	eb 05                	jmp    801dc2 <memcmp+0x35>
	}

	return 0;
  801dbd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dc2:	5b                   	pop    %ebx
  801dc3:	5e                   	pop    %esi
  801dc4:	5d                   	pop    %ebp
  801dc5:	c3                   	ret    

00801dc6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801dcf:	89 c2                	mov    %eax,%edx
  801dd1:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801dd4:	eb 03                	jmp    801dd9 <memfind+0x13>
  801dd6:	83 c0 01             	add    $0x1,%eax
  801dd9:	39 d0                	cmp    %edx,%eax
  801ddb:	73 04                	jae    801de1 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801ddd:	38 08                	cmp    %cl,(%eax)
  801ddf:	75 f5                	jne    801dd6 <memfind+0x10>
			break;
	return (void *) s;
}
  801de1:	5d                   	pop    %ebp
  801de2:	c3                   	ret    

00801de3 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801de3:	55                   	push   %ebp
  801de4:	89 e5                	mov    %esp,%ebp
  801de6:	57                   	push   %edi
  801de7:	56                   	push   %esi
  801de8:	53                   	push   %ebx
  801de9:	8b 55 08             	mov    0x8(%ebp),%edx
  801dec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801def:	eb 03                	jmp    801df4 <strtol+0x11>
		s++;
  801df1:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801df4:	0f b6 02             	movzbl (%edx),%eax
  801df7:	3c 20                	cmp    $0x20,%al
  801df9:	74 f6                	je     801df1 <strtol+0xe>
  801dfb:	3c 09                	cmp    $0x9,%al
  801dfd:	74 f2                	je     801df1 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801dff:	3c 2b                	cmp    $0x2b,%al
  801e01:	74 2a                	je     801e2d <strtol+0x4a>
	int neg = 0;
  801e03:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801e08:	3c 2d                	cmp    $0x2d,%al
  801e0a:	74 2b                	je     801e37 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e0c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e12:	75 0f                	jne    801e23 <strtol+0x40>
  801e14:	80 3a 30             	cmpb   $0x30,(%edx)
  801e17:	74 28                	je     801e41 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e19:	85 db                	test   %ebx,%ebx
  801e1b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e20:	0f 44 d8             	cmove  %eax,%ebx
  801e23:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e28:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801e2b:	eb 46                	jmp    801e73 <strtol+0x90>
		s++;
  801e2d:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801e30:	bf 00 00 00 00       	mov    $0x0,%edi
  801e35:	eb d5                	jmp    801e0c <strtol+0x29>
		s++, neg = 1;
  801e37:	83 c2 01             	add    $0x1,%edx
  801e3a:	bf 01 00 00 00       	mov    $0x1,%edi
  801e3f:	eb cb                	jmp    801e0c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e41:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e45:	74 0e                	je     801e55 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801e47:	85 db                	test   %ebx,%ebx
  801e49:	75 d8                	jne    801e23 <strtol+0x40>
		s++, base = 8;
  801e4b:	83 c2 01             	add    $0x1,%edx
  801e4e:	bb 08 00 00 00       	mov    $0x8,%ebx
  801e53:	eb ce                	jmp    801e23 <strtol+0x40>
		s += 2, base = 16;
  801e55:	83 c2 02             	add    $0x2,%edx
  801e58:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e5d:	eb c4                	jmp    801e23 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801e5f:	0f be c0             	movsbl %al,%eax
  801e62:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801e65:	3b 45 10             	cmp    0x10(%ebp),%eax
  801e68:	7d 3a                	jge    801ea4 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801e6a:	83 c2 01             	add    $0x1,%edx
  801e6d:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801e71:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801e73:	0f b6 02             	movzbl (%edx),%eax
  801e76:	8d 70 d0             	lea    -0x30(%eax),%esi
  801e79:	89 f3                	mov    %esi,%ebx
  801e7b:	80 fb 09             	cmp    $0x9,%bl
  801e7e:	76 df                	jbe    801e5f <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  801e80:	8d 70 9f             	lea    -0x61(%eax),%esi
  801e83:	89 f3                	mov    %esi,%ebx
  801e85:	80 fb 19             	cmp    $0x19,%bl
  801e88:	77 08                	ja     801e92 <strtol+0xaf>
			dig = *s - 'a' + 10;
  801e8a:	0f be c0             	movsbl %al,%eax
  801e8d:	83 e8 57             	sub    $0x57,%eax
  801e90:	eb d3                	jmp    801e65 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801e92:	8d 70 bf             	lea    -0x41(%eax),%esi
  801e95:	89 f3                	mov    %esi,%ebx
  801e97:	80 fb 19             	cmp    $0x19,%bl
  801e9a:	77 08                	ja     801ea4 <strtol+0xc1>
			dig = *s - 'A' + 10;
  801e9c:	0f be c0             	movsbl %al,%eax
  801e9f:	83 e8 37             	sub    $0x37,%eax
  801ea2:	eb c1                	jmp    801e65 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801ea4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ea8:	74 05                	je     801eaf <strtol+0xcc>
		*endptr = (char *) s;
  801eaa:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ead:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801eaf:	89 c8                	mov    %ecx,%eax
  801eb1:	f7 d8                	neg    %eax
  801eb3:	85 ff                	test   %edi,%edi
  801eb5:	0f 45 c8             	cmovne %eax,%ecx
}
  801eb8:	89 c8                	mov    %ecx,%eax
  801eba:	5b                   	pop    %ebx
  801ebb:	5e                   	pop    %esi
  801ebc:	5f                   	pop    %edi
  801ebd:	5d                   	pop    %ebp
  801ebe:	c3                   	ret    

00801ebf <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ebf:	55                   	push   %ebp
  801ec0:	89 e5                	mov    %esp,%ebp
  801ec2:	56                   	push   %esi
  801ec3:	53                   	push   %ebx
  801ec4:	8b 75 08             	mov    0x8(%ebp),%esi
  801ec7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801ecd:	85 c0                	test   %eax,%eax
  801ecf:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ed4:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801ed7:	83 ec 0c             	sub    $0xc,%esp
  801eda:	50                   	push   %eax
  801edb:	e8 3a e4 ff ff       	call   80031a <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ee0:	83 c4 10             	add    $0x10,%esp
  801ee3:	85 f6                	test   %esi,%esi
  801ee5:	74 14                	je     801efb <ipc_recv+0x3c>
  801ee7:	ba 00 00 00 00       	mov    $0x0,%edx
  801eec:	85 c0                	test   %eax,%eax
  801eee:	78 09                	js     801ef9 <ipc_recv+0x3a>
  801ef0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ef6:	8b 52 74             	mov    0x74(%edx),%edx
  801ef9:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801efb:	85 db                	test   %ebx,%ebx
  801efd:	74 14                	je     801f13 <ipc_recv+0x54>
  801eff:	ba 00 00 00 00       	mov    $0x0,%edx
  801f04:	85 c0                	test   %eax,%eax
  801f06:	78 09                	js     801f11 <ipc_recv+0x52>
  801f08:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f0e:	8b 52 78             	mov    0x78(%edx),%edx
  801f11:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f13:	85 c0                	test   %eax,%eax
  801f15:	78 08                	js     801f1f <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801f17:	a1 00 40 80 00       	mov    0x804000,%eax
  801f1c:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f1f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f22:	5b                   	pop    %ebx
  801f23:	5e                   	pop    %esi
  801f24:	5d                   	pop    %ebp
  801f25:	c3                   	ret    

00801f26 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f26:	55                   	push   %ebp
  801f27:	89 e5                	mov    %esp,%ebp
  801f29:	57                   	push   %edi
  801f2a:	56                   	push   %esi
  801f2b:	53                   	push   %ebx
  801f2c:	83 ec 0c             	sub    $0xc,%esp
  801f2f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f32:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f35:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f38:	85 db                	test   %ebx,%ebx
  801f3a:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f3f:	0f 44 d8             	cmove  %eax,%ebx
  801f42:	eb 05                	jmp    801f49 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f44:	e8 02 e2 ff ff       	call   80014b <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f49:	ff 75 14             	push   0x14(%ebp)
  801f4c:	53                   	push   %ebx
  801f4d:	56                   	push   %esi
  801f4e:	57                   	push   %edi
  801f4f:	e8 a3 e3 ff ff       	call   8002f7 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f54:	83 c4 10             	add    $0x10,%esp
  801f57:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f5a:	74 e8                	je     801f44 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f5c:	85 c0                	test   %eax,%eax
  801f5e:	78 08                	js     801f68 <ipc_send+0x42>
	}while (r<0);

}
  801f60:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f63:	5b                   	pop    %ebx
  801f64:	5e                   	pop    %esi
  801f65:	5f                   	pop    %edi
  801f66:	5d                   	pop    %ebp
  801f67:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f68:	50                   	push   %eax
  801f69:	68 df 26 80 00       	push   $0x8026df
  801f6e:	6a 3d                	push   $0x3d
  801f70:	68 f3 26 80 00       	push   $0x8026f3
  801f75:	e8 50 f5 ff ff       	call   8014ca <_panic>

00801f7a <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f7a:	55                   	push   %ebp
  801f7b:	89 e5                	mov    %esp,%ebp
  801f7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f80:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f85:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f88:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f8e:	8b 52 50             	mov    0x50(%edx),%edx
  801f91:	39 ca                	cmp    %ecx,%edx
  801f93:	74 11                	je     801fa6 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801f95:	83 c0 01             	add    $0x1,%eax
  801f98:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f9d:	75 e6                	jne    801f85 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801f9f:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa4:	eb 0b                	jmp    801fb1 <ipc_find_env+0x37>
			return envs[i].env_id;
  801fa6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fa9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fae:	8b 40 48             	mov    0x48(%eax),%eax
}
  801fb1:	5d                   	pop    %ebp
  801fb2:	c3                   	ret    

00801fb3 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fb3:	55                   	push   %ebp
  801fb4:	89 e5                	mov    %esp,%ebp
  801fb6:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb9:	89 c2                	mov    %eax,%edx
  801fbb:	c1 ea 16             	shr    $0x16,%edx
  801fbe:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fc5:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fca:	f6 c1 01             	test   $0x1,%cl
  801fcd:	74 1c                	je     801feb <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801fcf:	c1 e8 0c             	shr    $0xc,%eax
  801fd2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fd9:	a8 01                	test   $0x1,%al
  801fdb:	74 0e                	je     801feb <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fdd:	c1 e8 0c             	shr    $0xc,%eax
  801fe0:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801fe7:	ef 
  801fe8:	0f b7 d2             	movzwl %dx,%edx
}
  801feb:	89 d0                	mov    %edx,%eax
  801fed:	5d                   	pop    %ebp
  801fee:	c3                   	ret    
  801fef:	90                   	nop

00801ff0 <__udivdi3>:
  801ff0:	f3 0f 1e fb          	endbr32 
  801ff4:	55                   	push   %ebp
  801ff5:	57                   	push   %edi
  801ff6:	56                   	push   %esi
  801ff7:	53                   	push   %ebx
  801ff8:	83 ec 1c             	sub    $0x1c,%esp
  801ffb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801fff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802003:	8b 74 24 34          	mov    0x34(%esp),%esi
  802007:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80200b:	85 c0                	test   %eax,%eax
  80200d:	75 19                	jne    802028 <__udivdi3+0x38>
  80200f:	39 f3                	cmp    %esi,%ebx
  802011:	76 4d                	jbe    802060 <__udivdi3+0x70>
  802013:	31 ff                	xor    %edi,%edi
  802015:	89 e8                	mov    %ebp,%eax
  802017:	89 f2                	mov    %esi,%edx
  802019:	f7 f3                	div    %ebx
  80201b:	89 fa                	mov    %edi,%edx
  80201d:	83 c4 1c             	add    $0x1c,%esp
  802020:	5b                   	pop    %ebx
  802021:	5e                   	pop    %esi
  802022:	5f                   	pop    %edi
  802023:	5d                   	pop    %ebp
  802024:	c3                   	ret    
  802025:	8d 76 00             	lea    0x0(%esi),%esi
  802028:	39 f0                	cmp    %esi,%eax
  80202a:	76 14                	jbe    802040 <__udivdi3+0x50>
  80202c:	31 ff                	xor    %edi,%edi
  80202e:	31 c0                	xor    %eax,%eax
  802030:	89 fa                	mov    %edi,%edx
  802032:	83 c4 1c             	add    $0x1c,%esp
  802035:	5b                   	pop    %ebx
  802036:	5e                   	pop    %esi
  802037:	5f                   	pop    %edi
  802038:	5d                   	pop    %ebp
  802039:	c3                   	ret    
  80203a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802040:	0f bd f8             	bsr    %eax,%edi
  802043:	83 f7 1f             	xor    $0x1f,%edi
  802046:	75 48                	jne    802090 <__udivdi3+0xa0>
  802048:	39 f0                	cmp    %esi,%eax
  80204a:	72 06                	jb     802052 <__udivdi3+0x62>
  80204c:	31 c0                	xor    %eax,%eax
  80204e:	39 eb                	cmp    %ebp,%ebx
  802050:	77 de                	ja     802030 <__udivdi3+0x40>
  802052:	b8 01 00 00 00       	mov    $0x1,%eax
  802057:	eb d7                	jmp    802030 <__udivdi3+0x40>
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	89 d9                	mov    %ebx,%ecx
  802062:	85 db                	test   %ebx,%ebx
  802064:	75 0b                	jne    802071 <__udivdi3+0x81>
  802066:	b8 01 00 00 00       	mov    $0x1,%eax
  80206b:	31 d2                	xor    %edx,%edx
  80206d:	f7 f3                	div    %ebx
  80206f:	89 c1                	mov    %eax,%ecx
  802071:	31 d2                	xor    %edx,%edx
  802073:	89 f0                	mov    %esi,%eax
  802075:	f7 f1                	div    %ecx
  802077:	89 c6                	mov    %eax,%esi
  802079:	89 e8                	mov    %ebp,%eax
  80207b:	89 f7                	mov    %esi,%edi
  80207d:	f7 f1                	div    %ecx
  80207f:	89 fa                	mov    %edi,%edx
  802081:	83 c4 1c             	add    $0x1c,%esp
  802084:	5b                   	pop    %ebx
  802085:	5e                   	pop    %esi
  802086:	5f                   	pop    %edi
  802087:	5d                   	pop    %ebp
  802088:	c3                   	ret    
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	89 f9                	mov    %edi,%ecx
  802092:	ba 20 00 00 00       	mov    $0x20,%edx
  802097:	29 fa                	sub    %edi,%edx
  802099:	d3 e0                	shl    %cl,%eax
  80209b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80209f:	89 d1                	mov    %edx,%ecx
  8020a1:	89 d8                	mov    %ebx,%eax
  8020a3:	d3 e8                	shr    %cl,%eax
  8020a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020a9:	09 c1                	or     %eax,%ecx
  8020ab:	89 f0                	mov    %esi,%eax
  8020ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020b1:	89 f9                	mov    %edi,%ecx
  8020b3:	d3 e3                	shl    %cl,%ebx
  8020b5:	89 d1                	mov    %edx,%ecx
  8020b7:	d3 e8                	shr    %cl,%eax
  8020b9:	89 f9                	mov    %edi,%ecx
  8020bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020bf:	89 eb                	mov    %ebp,%ebx
  8020c1:	d3 e6                	shl    %cl,%esi
  8020c3:	89 d1                	mov    %edx,%ecx
  8020c5:	d3 eb                	shr    %cl,%ebx
  8020c7:	09 f3                	or     %esi,%ebx
  8020c9:	89 c6                	mov    %eax,%esi
  8020cb:	89 f2                	mov    %esi,%edx
  8020cd:	89 d8                	mov    %ebx,%eax
  8020cf:	f7 74 24 08          	divl   0x8(%esp)
  8020d3:	89 d6                	mov    %edx,%esi
  8020d5:	89 c3                	mov    %eax,%ebx
  8020d7:	f7 64 24 0c          	mull   0xc(%esp)
  8020db:	39 d6                	cmp    %edx,%esi
  8020dd:	72 19                	jb     8020f8 <__udivdi3+0x108>
  8020df:	89 f9                	mov    %edi,%ecx
  8020e1:	d3 e5                	shl    %cl,%ebp
  8020e3:	39 c5                	cmp    %eax,%ebp
  8020e5:	73 04                	jae    8020eb <__udivdi3+0xfb>
  8020e7:	39 d6                	cmp    %edx,%esi
  8020e9:	74 0d                	je     8020f8 <__udivdi3+0x108>
  8020eb:	89 d8                	mov    %ebx,%eax
  8020ed:	31 ff                	xor    %edi,%edi
  8020ef:	e9 3c ff ff ff       	jmp    802030 <__udivdi3+0x40>
  8020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8020fb:	31 ff                	xor    %edi,%edi
  8020fd:	e9 2e ff ff ff       	jmp    802030 <__udivdi3+0x40>
  802102:	66 90                	xchg   %ax,%ax
  802104:	66 90                	xchg   %ax,%ax
  802106:	66 90                	xchg   %ax,%ax
  802108:	66 90                	xchg   %ax,%ax
  80210a:	66 90                	xchg   %ax,%ax
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__umoddi3>:
  802110:	f3 0f 1e fb          	endbr32 
  802114:	55                   	push   %ebp
  802115:	57                   	push   %edi
  802116:	56                   	push   %esi
  802117:	53                   	push   %ebx
  802118:	83 ec 1c             	sub    $0x1c,%esp
  80211b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80211f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802123:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802127:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80212b:	89 f0                	mov    %esi,%eax
  80212d:	89 da                	mov    %ebx,%edx
  80212f:	85 ff                	test   %edi,%edi
  802131:	75 15                	jne    802148 <__umoddi3+0x38>
  802133:	39 dd                	cmp    %ebx,%ebp
  802135:	76 39                	jbe    802170 <__umoddi3+0x60>
  802137:	f7 f5                	div    %ebp
  802139:	89 d0                	mov    %edx,%eax
  80213b:	31 d2                	xor    %edx,%edx
  80213d:	83 c4 1c             	add    $0x1c,%esp
  802140:	5b                   	pop    %ebx
  802141:	5e                   	pop    %esi
  802142:	5f                   	pop    %edi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    
  802145:	8d 76 00             	lea    0x0(%esi),%esi
  802148:	39 df                	cmp    %ebx,%edi
  80214a:	77 f1                	ja     80213d <__umoddi3+0x2d>
  80214c:	0f bd cf             	bsr    %edi,%ecx
  80214f:	83 f1 1f             	xor    $0x1f,%ecx
  802152:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802156:	75 40                	jne    802198 <__umoddi3+0x88>
  802158:	39 df                	cmp    %ebx,%edi
  80215a:	72 04                	jb     802160 <__umoddi3+0x50>
  80215c:	39 f5                	cmp    %esi,%ebp
  80215e:	77 dd                	ja     80213d <__umoddi3+0x2d>
  802160:	89 da                	mov    %ebx,%edx
  802162:	89 f0                	mov    %esi,%eax
  802164:	29 e8                	sub    %ebp,%eax
  802166:	19 fa                	sbb    %edi,%edx
  802168:	eb d3                	jmp    80213d <__umoddi3+0x2d>
  80216a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802170:	89 e9                	mov    %ebp,%ecx
  802172:	85 ed                	test   %ebp,%ebp
  802174:	75 0b                	jne    802181 <__umoddi3+0x71>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f5                	div    %ebp
  80217f:	89 c1                	mov    %eax,%ecx
  802181:	89 d8                	mov    %ebx,%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	f7 f1                	div    %ecx
  802187:	89 f0                	mov    %esi,%eax
  802189:	f7 f1                	div    %ecx
  80218b:	89 d0                	mov    %edx,%eax
  80218d:	31 d2                	xor    %edx,%edx
  80218f:	eb ac                	jmp    80213d <__umoddi3+0x2d>
  802191:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802198:	8b 44 24 04          	mov    0x4(%esp),%eax
  80219c:	ba 20 00 00 00       	mov    $0x20,%edx
  8021a1:	29 c2                	sub    %eax,%edx
  8021a3:	89 c1                	mov    %eax,%ecx
  8021a5:	89 e8                	mov    %ebp,%eax
  8021a7:	d3 e7                	shl    %cl,%edi
  8021a9:	89 d1                	mov    %edx,%ecx
  8021ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021af:	d3 e8                	shr    %cl,%eax
  8021b1:	89 c1                	mov    %eax,%ecx
  8021b3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021b7:	09 f9                	or     %edi,%ecx
  8021b9:	89 df                	mov    %ebx,%edi
  8021bb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021bf:	89 c1                	mov    %eax,%ecx
  8021c1:	d3 e5                	shl    %cl,%ebp
  8021c3:	89 d1                	mov    %edx,%ecx
  8021c5:	d3 ef                	shr    %cl,%edi
  8021c7:	89 c1                	mov    %eax,%ecx
  8021c9:	89 f0                	mov    %esi,%eax
  8021cb:	d3 e3                	shl    %cl,%ebx
  8021cd:	89 d1                	mov    %edx,%ecx
  8021cf:	89 fa                	mov    %edi,%edx
  8021d1:	d3 e8                	shr    %cl,%eax
  8021d3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021d8:	09 d8                	or     %ebx,%eax
  8021da:	f7 74 24 08          	divl   0x8(%esp)
  8021de:	89 d3                	mov    %edx,%ebx
  8021e0:	d3 e6                	shl    %cl,%esi
  8021e2:	f7 e5                	mul    %ebp
  8021e4:	89 c7                	mov    %eax,%edi
  8021e6:	89 d1                	mov    %edx,%ecx
  8021e8:	39 d3                	cmp    %edx,%ebx
  8021ea:	72 06                	jb     8021f2 <__umoddi3+0xe2>
  8021ec:	75 0e                	jne    8021fc <__umoddi3+0xec>
  8021ee:	39 c6                	cmp    %eax,%esi
  8021f0:	73 0a                	jae    8021fc <__umoddi3+0xec>
  8021f2:	29 e8                	sub    %ebp,%eax
  8021f4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8021f8:	89 d1                	mov    %edx,%ecx
  8021fa:	89 c7                	mov    %eax,%edi
  8021fc:	89 f5                	mov    %esi,%ebp
  8021fe:	8b 74 24 04          	mov    0x4(%esp),%esi
  802202:	29 fd                	sub    %edi,%ebp
  802204:	19 cb                	sbb    %ecx,%ebx
  802206:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80220b:	89 d8                	mov    %ebx,%eax
  80220d:	d3 e0                	shl    %cl,%eax
  80220f:	89 f1                	mov    %esi,%ecx
  802211:	d3 ed                	shr    %cl,%ebp
  802213:	d3 eb                	shr    %cl,%ebx
  802215:	09 e8                	or     %ebp,%eax
  802217:	89 da                	mov    %ebx,%edx
  802219:	83 c4 1c             	add    $0x1c,%esp
  80221c:	5b                   	pop    %ebx
  80221d:	5e                   	pop    %esi
  80221e:	5f                   	pop    %edi
  80221f:	5d                   	pop    %ebp
  802220:	c3                   	ret    
