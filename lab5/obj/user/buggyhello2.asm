
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
  80009a:	e8 88 04 00 00       	call   800527 <close_all>
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
  80011b:	68 98 1d 80 00       	push   $0x801d98
  800120:	6a 2a                	push   $0x2a
  800122:	68 b5 1d 80 00       	push   $0x801db5
  800127:	e8 d0 0e 00 00       	call   800ffc <_panic>

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
  80019c:	68 98 1d 80 00       	push   $0x801d98
  8001a1:	6a 2a                	push   $0x2a
  8001a3:	68 b5 1d 80 00       	push   $0x801db5
  8001a8:	e8 4f 0e 00 00       	call   800ffc <_panic>

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
  8001de:	68 98 1d 80 00       	push   $0x801d98
  8001e3:	6a 2a                	push   $0x2a
  8001e5:	68 b5 1d 80 00       	push   $0x801db5
  8001ea:	e8 0d 0e 00 00       	call   800ffc <_panic>

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
  800220:	68 98 1d 80 00       	push   $0x801d98
  800225:	6a 2a                	push   $0x2a
  800227:	68 b5 1d 80 00       	push   $0x801db5
  80022c:	e8 cb 0d 00 00       	call   800ffc <_panic>

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
  800262:	68 98 1d 80 00       	push   $0x801d98
  800267:	6a 2a                	push   $0x2a
  800269:	68 b5 1d 80 00       	push   $0x801db5
  80026e:	e8 89 0d 00 00       	call   800ffc <_panic>

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
  8002a4:	68 98 1d 80 00       	push   $0x801d98
  8002a9:	6a 2a                	push   $0x2a
  8002ab:	68 b5 1d 80 00       	push   $0x801db5
  8002b0:	e8 47 0d 00 00       	call   800ffc <_panic>

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
  8002e6:	68 98 1d 80 00       	push   $0x801d98
  8002eb:	6a 2a                	push   $0x2a
  8002ed:	68 b5 1d 80 00       	push   $0x801db5
  8002f2:	e8 05 0d 00 00       	call   800ffc <_panic>

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
  80034a:	68 98 1d 80 00       	push   $0x801d98
  80034f:	6a 2a                	push   $0x2a
  800351:	68 b5 1d 80 00       	push   $0x801db5
  800356:	e8 a1 0c 00 00       	call   800ffc <_panic>

0080035b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	c1 e8 0c             	shr    $0xc,%eax
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800376:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80037b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80038a:	89 c2                	mov    %eax,%edx
  80038c:	c1 ea 16             	shr    $0x16,%edx
  80038f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800396:	f6 c2 01             	test   $0x1,%dl
  800399:	74 29                	je     8003c4 <fd_alloc+0x42>
  80039b:	89 c2                	mov    %eax,%edx
  80039d:	c1 ea 0c             	shr    $0xc,%edx
  8003a0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a7:	f6 c2 01             	test   $0x1,%dl
  8003aa:	74 18                	je     8003c4 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8003ac:	05 00 10 00 00       	add    $0x1000,%eax
  8003b1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b6:	75 d2                	jne    80038a <fd_alloc+0x8>
  8003b8:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8003bd:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8003c2:	eb 05                	jmp    8003c9 <fd_alloc+0x47>
			return 0;
  8003c4:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8003c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003cc:	89 02                	mov    %eax,(%edx)
}
  8003ce:	89 c8                	mov    %ecx,%eax
  8003d0:	5d                   	pop    %ebp
  8003d1:	c3                   	ret    

008003d2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
  8003d5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d8:	83 f8 1f             	cmp    $0x1f,%eax
  8003db:	77 30                	ja     80040d <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003dd:	c1 e0 0c             	shl    $0xc,%eax
  8003e0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e5:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003eb:	f6 c2 01             	test   $0x1,%dl
  8003ee:	74 24                	je     800414 <fd_lookup+0x42>
  8003f0:	89 c2                	mov    %eax,%edx
  8003f2:	c1 ea 0c             	shr    $0xc,%edx
  8003f5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fc:	f6 c2 01             	test   $0x1,%dl
  8003ff:	74 1a                	je     80041b <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800401:	8b 55 0c             	mov    0xc(%ebp),%edx
  800404:	89 02                	mov    %eax,(%edx)
	return 0;
  800406:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80040b:	5d                   	pop    %ebp
  80040c:	c3                   	ret    
		return -E_INVAL;
  80040d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800412:	eb f7                	jmp    80040b <fd_lookup+0x39>
		return -E_INVAL;
  800414:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800419:	eb f0                	jmp    80040b <fd_lookup+0x39>
  80041b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800420:	eb e9                	jmp    80040b <fd_lookup+0x39>

00800422 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800422:	55                   	push   %ebp
  800423:	89 e5                	mov    %esp,%ebp
  800425:	53                   	push   %ebx
  800426:	83 ec 04             	sub    $0x4,%esp
  800429:	8b 55 08             	mov    0x8(%ebp),%edx
  80042c:	b8 40 1e 80 00       	mov    $0x801e40,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800431:	bb 08 30 80 00       	mov    $0x803008,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800436:	39 13                	cmp    %edx,(%ebx)
  800438:	74 32                	je     80046c <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  80043a:	83 c0 04             	add    $0x4,%eax
  80043d:	8b 18                	mov    (%eax),%ebx
  80043f:	85 db                	test   %ebx,%ebx
  800441:	75 f3                	jne    800436 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800443:	a1 00 40 80 00       	mov    0x804000,%eax
  800448:	8b 40 48             	mov    0x48(%eax),%eax
  80044b:	83 ec 04             	sub    $0x4,%esp
  80044e:	52                   	push   %edx
  80044f:	50                   	push   %eax
  800450:	68 c4 1d 80 00       	push   $0x801dc4
  800455:	e8 7d 0c 00 00       	call   8010d7 <cprintf>
	*dev = 0;
	return -E_INVAL;
  80045a:	83 c4 10             	add    $0x10,%esp
  80045d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800462:	8b 55 0c             	mov    0xc(%ebp),%edx
  800465:	89 1a                	mov    %ebx,(%edx)
}
  800467:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80046a:	c9                   	leave  
  80046b:	c3                   	ret    
			return 0;
  80046c:	b8 00 00 00 00       	mov    $0x0,%eax
  800471:	eb ef                	jmp    800462 <dev_lookup+0x40>

00800473 <fd_close>:
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	57                   	push   %edi
  800477:	56                   	push   %esi
  800478:	53                   	push   %ebx
  800479:	83 ec 24             	sub    $0x24,%esp
  80047c:	8b 75 08             	mov    0x8(%ebp),%esi
  80047f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800482:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800485:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800486:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80048f:	50                   	push   %eax
  800490:	e8 3d ff ff ff       	call   8003d2 <fd_lookup>
  800495:	89 c3                	mov    %eax,%ebx
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	85 c0                	test   %eax,%eax
  80049c:	78 05                	js     8004a3 <fd_close+0x30>
	    || fd != fd2)
  80049e:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004a1:	74 16                	je     8004b9 <fd_close+0x46>
		return (must_exist ? r : 0);
  8004a3:	89 f8                	mov    %edi,%eax
  8004a5:	84 c0                	test   %al,%al
  8004a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ac:	0f 44 d8             	cmove  %eax,%ebx
}
  8004af:	89 d8                	mov    %ebx,%eax
  8004b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b4:	5b                   	pop    %ebx
  8004b5:	5e                   	pop    %esi
  8004b6:	5f                   	pop    %edi
  8004b7:	5d                   	pop    %ebp
  8004b8:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004b9:	83 ec 08             	sub    $0x8,%esp
  8004bc:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004bf:	50                   	push   %eax
  8004c0:	ff 36                	push   (%esi)
  8004c2:	e8 5b ff ff ff       	call   800422 <dev_lookup>
  8004c7:	89 c3                	mov    %eax,%ebx
  8004c9:	83 c4 10             	add    $0x10,%esp
  8004cc:	85 c0                	test   %eax,%eax
  8004ce:	78 1a                	js     8004ea <fd_close+0x77>
		if (dev->dev_close)
  8004d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d3:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8004d6:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004db:	85 c0                	test   %eax,%eax
  8004dd:	74 0b                	je     8004ea <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8004df:	83 ec 0c             	sub    $0xc,%esp
  8004e2:	56                   	push   %esi
  8004e3:	ff d0                	call   *%eax
  8004e5:	89 c3                	mov    %eax,%ebx
  8004e7:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004ea:	83 ec 08             	sub    $0x8,%esp
  8004ed:	56                   	push   %esi
  8004ee:	6a 00                	push   $0x0
  8004f0:	e8 fa fc ff ff       	call   8001ef <sys_page_unmap>
	return r;
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	eb b5                	jmp    8004af <fd_close+0x3c>

008004fa <close>:

int
close(int fdnum)
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800500:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800503:	50                   	push   %eax
  800504:	ff 75 08             	push   0x8(%ebp)
  800507:	e8 c6 fe ff ff       	call   8003d2 <fd_lookup>
  80050c:	83 c4 10             	add    $0x10,%esp
  80050f:	85 c0                	test   %eax,%eax
  800511:	79 02                	jns    800515 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800513:	c9                   	leave  
  800514:	c3                   	ret    
		return fd_close(fd, 1);
  800515:	83 ec 08             	sub    $0x8,%esp
  800518:	6a 01                	push   $0x1
  80051a:	ff 75 f4             	push   -0xc(%ebp)
  80051d:	e8 51 ff ff ff       	call   800473 <fd_close>
  800522:	83 c4 10             	add    $0x10,%esp
  800525:	eb ec                	jmp    800513 <close+0x19>

00800527 <close_all>:

void
close_all(void)
{
  800527:	55                   	push   %ebp
  800528:	89 e5                	mov    %esp,%ebp
  80052a:	53                   	push   %ebx
  80052b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80052e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800533:	83 ec 0c             	sub    $0xc,%esp
  800536:	53                   	push   %ebx
  800537:	e8 be ff ff ff       	call   8004fa <close>
	for (i = 0; i < MAXFD; i++)
  80053c:	83 c3 01             	add    $0x1,%ebx
  80053f:	83 c4 10             	add    $0x10,%esp
  800542:	83 fb 20             	cmp    $0x20,%ebx
  800545:	75 ec                	jne    800533 <close_all+0xc>
}
  800547:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80054a:	c9                   	leave  
  80054b:	c3                   	ret    

0080054c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80054c:	55                   	push   %ebp
  80054d:	89 e5                	mov    %esp,%ebp
  80054f:	57                   	push   %edi
  800550:	56                   	push   %esi
  800551:	53                   	push   %ebx
  800552:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800555:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800558:	50                   	push   %eax
  800559:	ff 75 08             	push   0x8(%ebp)
  80055c:	e8 71 fe ff ff       	call   8003d2 <fd_lookup>
  800561:	89 c3                	mov    %eax,%ebx
  800563:	83 c4 10             	add    $0x10,%esp
  800566:	85 c0                	test   %eax,%eax
  800568:	78 7f                	js     8005e9 <dup+0x9d>
		return r;
	close(newfdnum);
  80056a:	83 ec 0c             	sub    $0xc,%esp
  80056d:	ff 75 0c             	push   0xc(%ebp)
  800570:	e8 85 ff ff ff       	call   8004fa <close>

	newfd = INDEX2FD(newfdnum);
  800575:	8b 75 0c             	mov    0xc(%ebp),%esi
  800578:	c1 e6 0c             	shl    $0xc,%esi
  80057b:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800581:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800584:	89 3c 24             	mov    %edi,(%esp)
  800587:	e8 df fd ff ff       	call   80036b <fd2data>
  80058c:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80058e:	89 34 24             	mov    %esi,(%esp)
  800591:	e8 d5 fd ff ff       	call   80036b <fd2data>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80059c:	89 d8                	mov    %ebx,%eax
  80059e:	c1 e8 16             	shr    $0x16,%eax
  8005a1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a8:	a8 01                	test   $0x1,%al
  8005aa:	74 11                	je     8005bd <dup+0x71>
  8005ac:	89 d8                	mov    %ebx,%eax
  8005ae:	c1 e8 0c             	shr    $0xc,%eax
  8005b1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b8:	f6 c2 01             	test   $0x1,%dl
  8005bb:	75 36                	jne    8005f3 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005bd:	89 f8                	mov    %edi,%eax
  8005bf:	c1 e8 0c             	shr    $0xc,%eax
  8005c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c9:	83 ec 0c             	sub    $0xc,%esp
  8005cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d1:	50                   	push   %eax
  8005d2:	56                   	push   %esi
  8005d3:	6a 00                	push   $0x0
  8005d5:	57                   	push   %edi
  8005d6:	6a 00                	push   $0x0
  8005d8:	e8 d0 fb ff ff       	call   8001ad <sys_page_map>
  8005dd:	89 c3                	mov    %eax,%ebx
  8005df:	83 c4 20             	add    $0x20,%esp
  8005e2:	85 c0                	test   %eax,%eax
  8005e4:	78 33                	js     800619 <dup+0xcd>
		goto err;

	return newfdnum;
  8005e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005e9:	89 d8                	mov    %ebx,%eax
  8005eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005ee:	5b                   	pop    %ebx
  8005ef:	5e                   	pop    %esi
  8005f0:	5f                   	pop    %edi
  8005f1:	5d                   	pop    %ebp
  8005f2:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fa:	83 ec 0c             	sub    $0xc,%esp
  8005fd:	25 07 0e 00 00       	and    $0xe07,%eax
  800602:	50                   	push   %eax
  800603:	ff 75 d4             	push   -0x2c(%ebp)
  800606:	6a 00                	push   $0x0
  800608:	53                   	push   %ebx
  800609:	6a 00                	push   $0x0
  80060b:	e8 9d fb ff ff       	call   8001ad <sys_page_map>
  800610:	89 c3                	mov    %eax,%ebx
  800612:	83 c4 20             	add    $0x20,%esp
  800615:	85 c0                	test   %eax,%eax
  800617:	79 a4                	jns    8005bd <dup+0x71>
	sys_page_unmap(0, newfd);
  800619:	83 ec 08             	sub    $0x8,%esp
  80061c:	56                   	push   %esi
  80061d:	6a 00                	push   $0x0
  80061f:	e8 cb fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  800624:	83 c4 08             	add    $0x8,%esp
  800627:	ff 75 d4             	push   -0x2c(%ebp)
  80062a:	6a 00                	push   $0x0
  80062c:	e8 be fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  800631:	83 c4 10             	add    $0x10,%esp
  800634:	eb b3                	jmp    8005e9 <dup+0x9d>

00800636 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800636:	55                   	push   %ebp
  800637:	89 e5                	mov    %esp,%ebp
  800639:	56                   	push   %esi
  80063a:	53                   	push   %ebx
  80063b:	83 ec 18             	sub    $0x18,%esp
  80063e:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800641:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800644:	50                   	push   %eax
  800645:	56                   	push   %esi
  800646:	e8 87 fd ff ff       	call   8003d2 <fd_lookup>
  80064b:	83 c4 10             	add    $0x10,%esp
  80064e:	85 c0                	test   %eax,%eax
  800650:	78 3c                	js     80068e <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800652:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80065b:	50                   	push   %eax
  80065c:	ff 33                	push   (%ebx)
  80065e:	e8 bf fd ff ff       	call   800422 <dev_lookup>
  800663:	83 c4 10             	add    $0x10,%esp
  800666:	85 c0                	test   %eax,%eax
  800668:	78 24                	js     80068e <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80066a:	8b 43 08             	mov    0x8(%ebx),%eax
  80066d:	83 e0 03             	and    $0x3,%eax
  800670:	83 f8 01             	cmp    $0x1,%eax
  800673:	74 20                	je     800695 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800675:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800678:	8b 40 08             	mov    0x8(%eax),%eax
  80067b:	85 c0                	test   %eax,%eax
  80067d:	74 37                	je     8006b6 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80067f:	83 ec 04             	sub    $0x4,%esp
  800682:	ff 75 10             	push   0x10(%ebp)
  800685:	ff 75 0c             	push   0xc(%ebp)
  800688:	53                   	push   %ebx
  800689:	ff d0                	call   *%eax
  80068b:	83 c4 10             	add    $0x10,%esp
}
  80068e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800691:	5b                   	pop    %ebx
  800692:	5e                   	pop    %esi
  800693:	5d                   	pop    %ebp
  800694:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800695:	a1 00 40 80 00       	mov    0x804000,%eax
  80069a:	8b 40 48             	mov    0x48(%eax),%eax
  80069d:	83 ec 04             	sub    $0x4,%esp
  8006a0:	56                   	push   %esi
  8006a1:	50                   	push   %eax
  8006a2:	68 05 1e 80 00       	push   $0x801e05
  8006a7:	e8 2b 0a 00 00       	call   8010d7 <cprintf>
		return -E_INVAL;
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b4:	eb d8                	jmp    80068e <read+0x58>
		return -E_NOT_SUPP;
  8006b6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006bb:	eb d1                	jmp    80068e <read+0x58>

008006bd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	57                   	push   %edi
  8006c1:	56                   	push   %esi
  8006c2:	53                   	push   %ebx
  8006c3:	83 ec 0c             	sub    $0xc,%esp
  8006c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d1:	eb 02                	jmp    8006d5 <readn+0x18>
  8006d3:	01 c3                	add    %eax,%ebx
  8006d5:	39 f3                	cmp    %esi,%ebx
  8006d7:	73 21                	jae    8006fa <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d9:	83 ec 04             	sub    $0x4,%esp
  8006dc:	89 f0                	mov    %esi,%eax
  8006de:	29 d8                	sub    %ebx,%eax
  8006e0:	50                   	push   %eax
  8006e1:	89 d8                	mov    %ebx,%eax
  8006e3:	03 45 0c             	add    0xc(%ebp),%eax
  8006e6:	50                   	push   %eax
  8006e7:	57                   	push   %edi
  8006e8:	e8 49 ff ff ff       	call   800636 <read>
		if (m < 0)
  8006ed:	83 c4 10             	add    $0x10,%esp
  8006f0:	85 c0                	test   %eax,%eax
  8006f2:	78 04                	js     8006f8 <readn+0x3b>
			return m;
		if (m == 0)
  8006f4:	75 dd                	jne    8006d3 <readn+0x16>
  8006f6:	eb 02                	jmp    8006fa <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f8:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006fa:	89 d8                	mov    %ebx,%eax
  8006fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ff:	5b                   	pop    %ebx
  800700:	5e                   	pop    %esi
  800701:	5f                   	pop    %edi
  800702:	5d                   	pop    %ebp
  800703:	c3                   	ret    

00800704 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	56                   	push   %esi
  800708:	53                   	push   %ebx
  800709:	83 ec 18             	sub    $0x18,%esp
  80070c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800712:	50                   	push   %eax
  800713:	53                   	push   %ebx
  800714:	e8 b9 fc ff ff       	call   8003d2 <fd_lookup>
  800719:	83 c4 10             	add    $0x10,%esp
  80071c:	85 c0                	test   %eax,%eax
  80071e:	78 37                	js     800757 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800720:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800723:	83 ec 08             	sub    $0x8,%esp
  800726:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800729:	50                   	push   %eax
  80072a:	ff 36                	push   (%esi)
  80072c:	e8 f1 fc ff ff       	call   800422 <dev_lookup>
  800731:	83 c4 10             	add    $0x10,%esp
  800734:	85 c0                	test   %eax,%eax
  800736:	78 1f                	js     800757 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800738:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80073c:	74 20                	je     80075e <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80073e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800741:	8b 40 0c             	mov    0xc(%eax),%eax
  800744:	85 c0                	test   %eax,%eax
  800746:	74 37                	je     80077f <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800748:	83 ec 04             	sub    $0x4,%esp
  80074b:	ff 75 10             	push   0x10(%ebp)
  80074e:	ff 75 0c             	push   0xc(%ebp)
  800751:	56                   	push   %esi
  800752:	ff d0                	call   *%eax
  800754:	83 c4 10             	add    $0x10,%esp
}
  800757:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80075a:	5b                   	pop    %ebx
  80075b:	5e                   	pop    %esi
  80075c:	5d                   	pop    %ebp
  80075d:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80075e:	a1 00 40 80 00       	mov    0x804000,%eax
  800763:	8b 40 48             	mov    0x48(%eax),%eax
  800766:	83 ec 04             	sub    $0x4,%esp
  800769:	53                   	push   %ebx
  80076a:	50                   	push   %eax
  80076b:	68 21 1e 80 00       	push   $0x801e21
  800770:	e8 62 09 00 00       	call   8010d7 <cprintf>
		return -E_INVAL;
  800775:	83 c4 10             	add    $0x10,%esp
  800778:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80077d:	eb d8                	jmp    800757 <write+0x53>
		return -E_NOT_SUPP;
  80077f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800784:	eb d1                	jmp    800757 <write+0x53>

00800786 <seek>:

int
seek(int fdnum, off_t offset)
{
  800786:	55                   	push   %ebp
  800787:	89 e5                	mov    %esp,%ebp
  800789:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80078c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80078f:	50                   	push   %eax
  800790:	ff 75 08             	push   0x8(%ebp)
  800793:	e8 3a fc ff ff       	call   8003d2 <fd_lookup>
  800798:	83 c4 10             	add    $0x10,%esp
  80079b:	85 c0                	test   %eax,%eax
  80079d:	78 0e                	js     8007ad <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80079f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007ad:	c9                   	leave  
  8007ae:	c3                   	ret    

008007af <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007af:	55                   	push   %ebp
  8007b0:	89 e5                	mov    %esp,%ebp
  8007b2:	56                   	push   %esi
  8007b3:	53                   	push   %ebx
  8007b4:	83 ec 18             	sub    $0x18,%esp
  8007b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ba:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007bd:	50                   	push   %eax
  8007be:	53                   	push   %ebx
  8007bf:	e8 0e fc ff ff       	call   8003d2 <fd_lookup>
  8007c4:	83 c4 10             	add    $0x10,%esp
  8007c7:	85 c0                	test   %eax,%eax
  8007c9:	78 34                	js     8007ff <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007cb:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8007ce:	83 ec 08             	sub    $0x8,%esp
  8007d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d4:	50                   	push   %eax
  8007d5:	ff 36                	push   (%esi)
  8007d7:	e8 46 fc ff ff       	call   800422 <dev_lookup>
  8007dc:	83 c4 10             	add    $0x10,%esp
  8007df:	85 c0                	test   %eax,%eax
  8007e1:	78 1c                	js     8007ff <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007e3:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8007e7:	74 1d                	je     800806 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ec:	8b 40 18             	mov    0x18(%eax),%eax
  8007ef:	85 c0                	test   %eax,%eax
  8007f1:	74 34                	je     800827 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007f3:	83 ec 08             	sub    $0x8,%esp
  8007f6:	ff 75 0c             	push   0xc(%ebp)
  8007f9:	56                   	push   %esi
  8007fa:	ff d0                	call   *%eax
  8007fc:	83 c4 10             	add    $0x10,%esp
}
  8007ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800802:	5b                   	pop    %ebx
  800803:	5e                   	pop    %esi
  800804:	5d                   	pop    %ebp
  800805:	c3                   	ret    
			thisenv->env_id, fdnum);
  800806:	a1 00 40 80 00       	mov    0x804000,%eax
  80080b:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80080e:	83 ec 04             	sub    $0x4,%esp
  800811:	53                   	push   %ebx
  800812:	50                   	push   %eax
  800813:	68 e4 1d 80 00       	push   $0x801de4
  800818:	e8 ba 08 00 00       	call   8010d7 <cprintf>
		return -E_INVAL;
  80081d:	83 c4 10             	add    $0x10,%esp
  800820:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800825:	eb d8                	jmp    8007ff <ftruncate+0x50>
		return -E_NOT_SUPP;
  800827:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80082c:	eb d1                	jmp    8007ff <ftruncate+0x50>

0080082e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	56                   	push   %esi
  800832:	53                   	push   %ebx
  800833:	83 ec 18             	sub    $0x18,%esp
  800836:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800839:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80083c:	50                   	push   %eax
  80083d:	ff 75 08             	push   0x8(%ebp)
  800840:	e8 8d fb ff ff       	call   8003d2 <fd_lookup>
  800845:	83 c4 10             	add    $0x10,%esp
  800848:	85 c0                	test   %eax,%eax
  80084a:	78 49                	js     800895 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80084c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80084f:	83 ec 08             	sub    $0x8,%esp
  800852:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800855:	50                   	push   %eax
  800856:	ff 36                	push   (%esi)
  800858:	e8 c5 fb ff ff       	call   800422 <dev_lookup>
  80085d:	83 c4 10             	add    $0x10,%esp
  800860:	85 c0                	test   %eax,%eax
  800862:	78 31                	js     800895 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  800864:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800867:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80086b:	74 2f                	je     80089c <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80086d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800870:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800877:	00 00 00 
	stat->st_isdir = 0;
  80087a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800881:	00 00 00 
	stat->st_dev = dev;
  800884:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80088a:	83 ec 08             	sub    $0x8,%esp
  80088d:	53                   	push   %ebx
  80088e:	56                   	push   %esi
  80088f:	ff 50 14             	call   *0x14(%eax)
  800892:	83 c4 10             	add    $0x10,%esp
}
  800895:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800898:	5b                   	pop    %ebx
  800899:	5e                   	pop    %esi
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    
		return -E_NOT_SUPP;
  80089c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008a1:	eb f2                	jmp    800895 <fstat+0x67>

008008a3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	56                   	push   %esi
  8008a7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	6a 00                	push   $0x0
  8008ad:	ff 75 08             	push   0x8(%ebp)
  8008b0:	e8 e4 01 00 00       	call   800a99 <open>
  8008b5:	89 c3                	mov    %eax,%ebx
  8008b7:	83 c4 10             	add    $0x10,%esp
  8008ba:	85 c0                	test   %eax,%eax
  8008bc:	78 1b                	js     8008d9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	ff 75 0c             	push   0xc(%ebp)
  8008c4:	50                   	push   %eax
  8008c5:	e8 64 ff ff ff       	call   80082e <fstat>
  8008ca:	89 c6                	mov    %eax,%esi
	close(fd);
  8008cc:	89 1c 24             	mov    %ebx,(%esp)
  8008cf:	e8 26 fc ff ff       	call   8004fa <close>
	return r;
  8008d4:	83 c4 10             	add    $0x10,%esp
  8008d7:	89 f3                	mov    %esi,%ebx
}
  8008d9:	89 d8                	mov    %ebx,%eax
  8008db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008de:	5b                   	pop    %ebx
  8008df:	5e                   	pop    %esi
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	56                   	push   %esi
  8008e6:	53                   	push   %ebx
  8008e7:	89 c6                	mov    %eax,%esi
  8008e9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008eb:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8008f2:	74 27                	je     80091b <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008f4:	6a 07                	push   $0x7
  8008f6:	68 00 50 80 00       	push   $0x805000
  8008fb:	56                   	push   %esi
  8008fc:	ff 35 00 60 80 00    	push   0x806000
  800902:	e8 51 11 00 00       	call   801a58 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800907:	83 c4 0c             	add    $0xc,%esp
  80090a:	6a 00                	push   $0x0
  80090c:	53                   	push   %ebx
  80090d:	6a 00                	push   $0x0
  80090f:	e8 dd 10 00 00       	call   8019f1 <ipc_recv>
}
  800914:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800917:	5b                   	pop    %ebx
  800918:	5e                   	pop    %esi
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80091b:	83 ec 0c             	sub    $0xc,%esp
  80091e:	6a 01                	push   $0x1
  800920:	e8 87 11 00 00       	call   801aac <ipc_find_env>
  800925:	a3 00 60 80 00       	mov    %eax,0x806000
  80092a:	83 c4 10             	add    $0x10,%esp
  80092d:	eb c5                	jmp    8008f4 <fsipc+0x12>

0080092f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	8b 40 0c             	mov    0xc(%eax),%eax
  80093b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800940:	8b 45 0c             	mov    0xc(%ebp),%eax
  800943:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800948:	ba 00 00 00 00       	mov    $0x0,%edx
  80094d:	b8 02 00 00 00       	mov    $0x2,%eax
  800952:	e8 8b ff ff ff       	call   8008e2 <fsipc>
}
  800957:	c9                   	leave  
  800958:	c3                   	ret    

00800959 <devfile_flush>:
{
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80095f:	8b 45 08             	mov    0x8(%ebp),%eax
  800962:	8b 40 0c             	mov    0xc(%eax),%eax
  800965:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80096a:	ba 00 00 00 00       	mov    $0x0,%edx
  80096f:	b8 06 00 00 00       	mov    $0x6,%eax
  800974:	e8 69 ff ff ff       	call   8008e2 <fsipc>
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <devfile_stat>:
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	53                   	push   %ebx
  80097f:	83 ec 04             	sub    $0x4,%esp
  800982:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 40 0c             	mov    0xc(%eax),%eax
  80098b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800990:	ba 00 00 00 00       	mov    $0x0,%edx
  800995:	b8 05 00 00 00       	mov    $0x5,%eax
  80099a:	e8 43 ff ff ff       	call   8008e2 <fsipc>
  80099f:	85 c0                	test   %eax,%eax
  8009a1:	78 2c                	js     8009cf <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009a3:	83 ec 08             	sub    $0x8,%esp
  8009a6:	68 00 50 80 00       	push   $0x805000
  8009ab:	53                   	push   %ebx
  8009ac:	e8 00 0d 00 00       	call   8016b1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009b1:	a1 80 50 80 00       	mov    0x805080,%eax
  8009b6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009bc:	a1 84 50 80 00       	mov    0x805084,%eax
  8009c1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009c7:	83 c4 10             	add    $0x10,%esp
  8009ca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d2:	c9                   	leave  
  8009d3:	c3                   	ret    

008009d4 <devfile_write>:
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	83 ec 0c             	sub    $0xc,%esp
  8009da:	8b 45 10             	mov    0x10(%ebp),%eax
  8009dd:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009e2:	39 d0                	cmp    %edx,%eax
  8009e4:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ea:	8b 52 0c             	mov    0xc(%edx),%edx
  8009ed:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009f3:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8009f8:	50                   	push   %eax
  8009f9:	ff 75 0c             	push   0xc(%ebp)
  8009fc:	68 08 50 80 00       	push   $0x805008
  800a01:	e8 41 0e 00 00       	call   801847 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800a06:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0b:	b8 04 00 00 00       	mov    $0x4,%eax
  800a10:	e8 cd fe ff ff       	call   8008e2 <fsipc>
}
  800a15:	c9                   	leave  
  800a16:	c3                   	ret    

00800a17 <devfile_read>:
{
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	56                   	push   %esi
  800a1b:	53                   	push   %ebx
  800a1c:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a1f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a22:	8b 40 0c             	mov    0xc(%eax),%eax
  800a25:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a2a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a30:	ba 00 00 00 00       	mov    $0x0,%edx
  800a35:	b8 03 00 00 00       	mov    $0x3,%eax
  800a3a:	e8 a3 fe ff ff       	call   8008e2 <fsipc>
  800a3f:	89 c3                	mov    %eax,%ebx
  800a41:	85 c0                	test   %eax,%eax
  800a43:	78 1f                	js     800a64 <devfile_read+0x4d>
	assert(r <= n);
  800a45:	39 f0                	cmp    %esi,%eax
  800a47:	77 24                	ja     800a6d <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a49:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a4e:	7f 33                	jg     800a83 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a50:	83 ec 04             	sub    $0x4,%esp
  800a53:	50                   	push   %eax
  800a54:	68 00 50 80 00       	push   $0x805000
  800a59:	ff 75 0c             	push   0xc(%ebp)
  800a5c:	e8 e6 0d 00 00       	call   801847 <memmove>
	return r;
  800a61:	83 c4 10             	add    $0x10,%esp
}
  800a64:	89 d8                	mov    %ebx,%eax
  800a66:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a69:	5b                   	pop    %ebx
  800a6a:	5e                   	pop    %esi
  800a6b:	5d                   	pop    %ebp
  800a6c:	c3                   	ret    
	assert(r <= n);
  800a6d:	68 50 1e 80 00       	push   $0x801e50
  800a72:	68 57 1e 80 00       	push   $0x801e57
  800a77:	6a 7c                	push   $0x7c
  800a79:	68 6c 1e 80 00       	push   $0x801e6c
  800a7e:	e8 79 05 00 00       	call   800ffc <_panic>
	assert(r <= PGSIZE);
  800a83:	68 77 1e 80 00       	push   $0x801e77
  800a88:	68 57 1e 80 00       	push   $0x801e57
  800a8d:	6a 7d                	push   $0x7d
  800a8f:	68 6c 1e 80 00       	push   $0x801e6c
  800a94:	e8 63 05 00 00       	call   800ffc <_panic>

00800a99 <open>:
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	56                   	push   %esi
  800a9d:	53                   	push   %ebx
  800a9e:	83 ec 1c             	sub    $0x1c,%esp
  800aa1:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800aa4:	56                   	push   %esi
  800aa5:	e8 cc 0b 00 00       	call   801676 <strlen>
  800aaa:	83 c4 10             	add    $0x10,%esp
  800aad:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ab2:	7f 6c                	jg     800b20 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800ab4:	83 ec 0c             	sub    $0xc,%esp
  800ab7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aba:	50                   	push   %eax
  800abb:	e8 c2 f8 ff ff       	call   800382 <fd_alloc>
  800ac0:	89 c3                	mov    %eax,%ebx
  800ac2:	83 c4 10             	add    $0x10,%esp
  800ac5:	85 c0                	test   %eax,%eax
  800ac7:	78 3c                	js     800b05 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800ac9:	83 ec 08             	sub    $0x8,%esp
  800acc:	56                   	push   %esi
  800acd:	68 00 50 80 00       	push   $0x805000
  800ad2:	e8 da 0b 00 00       	call   8016b1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ad7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ada:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800adf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ae2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae7:	e8 f6 fd ff ff       	call   8008e2 <fsipc>
  800aec:	89 c3                	mov    %eax,%ebx
  800aee:	83 c4 10             	add    $0x10,%esp
  800af1:	85 c0                	test   %eax,%eax
  800af3:	78 19                	js     800b0e <open+0x75>
	return fd2num(fd);
  800af5:	83 ec 0c             	sub    $0xc,%esp
  800af8:	ff 75 f4             	push   -0xc(%ebp)
  800afb:	e8 5b f8 ff ff       	call   80035b <fd2num>
  800b00:	89 c3                	mov    %eax,%ebx
  800b02:	83 c4 10             	add    $0x10,%esp
}
  800b05:	89 d8                	mov    %ebx,%eax
  800b07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b0a:	5b                   	pop    %ebx
  800b0b:	5e                   	pop    %esi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    
		fd_close(fd, 0);
  800b0e:	83 ec 08             	sub    $0x8,%esp
  800b11:	6a 00                	push   $0x0
  800b13:	ff 75 f4             	push   -0xc(%ebp)
  800b16:	e8 58 f9 ff ff       	call   800473 <fd_close>
		return r;
  800b1b:	83 c4 10             	add    $0x10,%esp
  800b1e:	eb e5                	jmp    800b05 <open+0x6c>
		return -E_BAD_PATH;
  800b20:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b25:	eb de                	jmp    800b05 <open+0x6c>

00800b27 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b27:	55                   	push   %ebp
  800b28:	89 e5                	mov    %esp,%ebp
  800b2a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b32:	b8 08 00 00 00       	mov    $0x8,%eax
  800b37:	e8 a6 fd ff ff       	call   8008e2 <fsipc>
}
  800b3c:	c9                   	leave  
  800b3d:	c3                   	ret    

00800b3e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	56                   	push   %esi
  800b42:	53                   	push   %ebx
  800b43:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b46:	83 ec 0c             	sub    $0xc,%esp
  800b49:	ff 75 08             	push   0x8(%ebp)
  800b4c:	e8 1a f8 ff ff       	call   80036b <fd2data>
  800b51:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b53:	83 c4 08             	add    $0x8,%esp
  800b56:	68 83 1e 80 00       	push   $0x801e83
  800b5b:	53                   	push   %ebx
  800b5c:	e8 50 0b 00 00       	call   8016b1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b61:	8b 46 04             	mov    0x4(%esi),%eax
  800b64:	2b 06                	sub    (%esi),%eax
  800b66:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b6c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b73:	00 00 00 
	stat->st_dev = &devpipe;
  800b76:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800b7d:	30 80 00 
	return 0;
}
  800b80:	b8 00 00 00 00       	mov    $0x0,%eax
  800b85:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b88:	5b                   	pop    %ebx
  800b89:	5e                   	pop    %esi
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	53                   	push   %ebx
  800b90:	83 ec 0c             	sub    $0xc,%esp
  800b93:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b96:	53                   	push   %ebx
  800b97:	6a 00                	push   $0x0
  800b99:	e8 51 f6 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b9e:	89 1c 24             	mov    %ebx,(%esp)
  800ba1:	e8 c5 f7 ff ff       	call   80036b <fd2data>
  800ba6:	83 c4 08             	add    $0x8,%esp
  800ba9:	50                   	push   %eax
  800baa:	6a 00                	push   $0x0
  800bac:	e8 3e f6 ff ff       	call   8001ef <sys_page_unmap>
}
  800bb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bb4:	c9                   	leave  
  800bb5:	c3                   	ret    

00800bb6 <_pipeisclosed>:
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	57                   	push   %edi
  800bba:	56                   	push   %esi
  800bbb:	53                   	push   %ebx
  800bbc:	83 ec 1c             	sub    $0x1c,%esp
  800bbf:	89 c7                	mov    %eax,%edi
  800bc1:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bc3:	a1 00 40 80 00       	mov    0x804000,%eax
  800bc8:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bcb:	83 ec 0c             	sub    $0xc,%esp
  800bce:	57                   	push   %edi
  800bcf:	e8 11 0f 00 00       	call   801ae5 <pageref>
  800bd4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bd7:	89 34 24             	mov    %esi,(%esp)
  800bda:	e8 06 0f 00 00       	call   801ae5 <pageref>
		nn = thisenv->env_runs;
  800bdf:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800be5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800be8:	83 c4 10             	add    $0x10,%esp
  800beb:	39 cb                	cmp    %ecx,%ebx
  800bed:	74 1b                	je     800c0a <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800bef:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800bf2:	75 cf                	jne    800bc3 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bf4:	8b 42 58             	mov    0x58(%edx),%eax
  800bf7:	6a 01                	push   $0x1
  800bf9:	50                   	push   %eax
  800bfa:	53                   	push   %ebx
  800bfb:	68 8a 1e 80 00       	push   $0x801e8a
  800c00:	e8 d2 04 00 00       	call   8010d7 <cprintf>
  800c05:	83 c4 10             	add    $0x10,%esp
  800c08:	eb b9                	jmp    800bc3 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c0a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c0d:	0f 94 c0             	sete   %al
  800c10:	0f b6 c0             	movzbl %al,%eax
}
  800c13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c16:	5b                   	pop    %ebx
  800c17:	5e                   	pop    %esi
  800c18:	5f                   	pop    %edi
  800c19:	5d                   	pop    %ebp
  800c1a:	c3                   	ret    

00800c1b <devpipe_write>:
{
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	57                   	push   %edi
  800c1f:	56                   	push   %esi
  800c20:	53                   	push   %ebx
  800c21:	83 ec 28             	sub    $0x28,%esp
  800c24:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c27:	56                   	push   %esi
  800c28:	e8 3e f7 ff ff       	call   80036b <fd2data>
  800c2d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c2f:	83 c4 10             	add    $0x10,%esp
  800c32:	bf 00 00 00 00       	mov    $0x0,%edi
  800c37:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c3a:	75 09                	jne    800c45 <devpipe_write+0x2a>
	return i;
  800c3c:	89 f8                	mov    %edi,%eax
  800c3e:	eb 23                	jmp    800c63 <devpipe_write+0x48>
			sys_yield();
  800c40:	e8 06 f5 ff ff       	call   80014b <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c45:	8b 43 04             	mov    0x4(%ebx),%eax
  800c48:	8b 0b                	mov    (%ebx),%ecx
  800c4a:	8d 51 20             	lea    0x20(%ecx),%edx
  800c4d:	39 d0                	cmp    %edx,%eax
  800c4f:	72 1a                	jb     800c6b <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  800c51:	89 da                	mov    %ebx,%edx
  800c53:	89 f0                	mov    %esi,%eax
  800c55:	e8 5c ff ff ff       	call   800bb6 <_pipeisclosed>
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	74 e2                	je     800c40 <devpipe_write+0x25>
				return 0;
  800c5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c66:	5b                   	pop    %ebx
  800c67:	5e                   	pop    %esi
  800c68:	5f                   	pop    %edi
  800c69:	5d                   	pop    %ebp
  800c6a:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c72:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c75:	89 c2                	mov    %eax,%edx
  800c77:	c1 fa 1f             	sar    $0x1f,%edx
  800c7a:	89 d1                	mov    %edx,%ecx
  800c7c:	c1 e9 1b             	shr    $0x1b,%ecx
  800c7f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c82:	83 e2 1f             	and    $0x1f,%edx
  800c85:	29 ca                	sub    %ecx,%edx
  800c87:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c8b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c8f:	83 c0 01             	add    $0x1,%eax
  800c92:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c95:	83 c7 01             	add    $0x1,%edi
  800c98:	eb 9d                	jmp    800c37 <devpipe_write+0x1c>

00800c9a <devpipe_read>:
{
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	57                   	push   %edi
  800c9e:	56                   	push   %esi
  800c9f:	53                   	push   %ebx
  800ca0:	83 ec 18             	sub    $0x18,%esp
  800ca3:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800ca6:	57                   	push   %edi
  800ca7:	e8 bf f6 ff ff       	call   80036b <fd2data>
  800cac:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cae:	83 c4 10             	add    $0x10,%esp
  800cb1:	be 00 00 00 00       	mov    $0x0,%esi
  800cb6:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cb9:	75 13                	jne    800cce <devpipe_read+0x34>
	return i;
  800cbb:	89 f0                	mov    %esi,%eax
  800cbd:	eb 02                	jmp    800cc1 <devpipe_read+0x27>
				return i;
  800cbf:	89 f0                	mov    %esi,%eax
}
  800cc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5f                   	pop    %edi
  800cc7:	5d                   	pop    %ebp
  800cc8:	c3                   	ret    
			sys_yield();
  800cc9:	e8 7d f4 ff ff       	call   80014b <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800cce:	8b 03                	mov    (%ebx),%eax
  800cd0:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cd3:	75 18                	jne    800ced <devpipe_read+0x53>
			if (i > 0)
  800cd5:	85 f6                	test   %esi,%esi
  800cd7:	75 e6                	jne    800cbf <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  800cd9:	89 da                	mov    %ebx,%edx
  800cdb:	89 f8                	mov    %edi,%eax
  800cdd:	e8 d4 fe ff ff       	call   800bb6 <_pipeisclosed>
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	74 e3                	je     800cc9 <devpipe_read+0x2f>
				return 0;
  800ce6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ceb:	eb d4                	jmp    800cc1 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800ced:	99                   	cltd   
  800cee:	c1 ea 1b             	shr    $0x1b,%edx
  800cf1:	01 d0                	add    %edx,%eax
  800cf3:	83 e0 1f             	and    $0x1f,%eax
  800cf6:	29 d0                	sub    %edx,%eax
  800cf8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800cfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d00:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d03:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d06:	83 c6 01             	add    $0x1,%esi
  800d09:	eb ab                	jmp    800cb6 <devpipe_read+0x1c>

00800d0b <pipe>:
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
  800d10:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d13:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d16:	50                   	push   %eax
  800d17:	e8 66 f6 ff ff       	call   800382 <fd_alloc>
  800d1c:	89 c3                	mov    %eax,%ebx
  800d1e:	83 c4 10             	add    $0x10,%esp
  800d21:	85 c0                	test   %eax,%eax
  800d23:	0f 88 23 01 00 00    	js     800e4c <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d29:	83 ec 04             	sub    $0x4,%esp
  800d2c:	68 07 04 00 00       	push   $0x407
  800d31:	ff 75 f4             	push   -0xc(%ebp)
  800d34:	6a 00                	push   $0x0
  800d36:	e8 2f f4 ff ff       	call   80016a <sys_page_alloc>
  800d3b:	89 c3                	mov    %eax,%ebx
  800d3d:	83 c4 10             	add    $0x10,%esp
  800d40:	85 c0                	test   %eax,%eax
  800d42:	0f 88 04 01 00 00    	js     800e4c <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  800d48:	83 ec 0c             	sub    $0xc,%esp
  800d4b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d4e:	50                   	push   %eax
  800d4f:	e8 2e f6 ff ff       	call   800382 <fd_alloc>
  800d54:	89 c3                	mov    %eax,%ebx
  800d56:	83 c4 10             	add    $0x10,%esp
  800d59:	85 c0                	test   %eax,%eax
  800d5b:	0f 88 db 00 00 00    	js     800e3c <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d61:	83 ec 04             	sub    $0x4,%esp
  800d64:	68 07 04 00 00       	push   $0x407
  800d69:	ff 75 f0             	push   -0x10(%ebp)
  800d6c:	6a 00                	push   $0x0
  800d6e:	e8 f7 f3 ff ff       	call   80016a <sys_page_alloc>
  800d73:	89 c3                	mov    %eax,%ebx
  800d75:	83 c4 10             	add    $0x10,%esp
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	0f 88 bc 00 00 00    	js     800e3c <pipe+0x131>
	va = fd2data(fd0);
  800d80:	83 ec 0c             	sub    $0xc,%esp
  800d83:	ff 75 f4             	push   -0xc(%ebp)
  800d86:	e8 e0 f5 ff ff       	call   80036b <fd2data>
  800d8b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8d:	83 c4 0c             	add    $0xc,%esp
  800d90:	68 07 04 00 00       	push   $0x407
  800d95:	50                   	push   %eax
  800d96:	6a 00                	push   $0x0
  800d98:	e8 cd f3 ff ff       	call   80016a <sys_page_alloc>
  800d9d:	89 c3                	mov    %eax,%ebx
  800d9f:	83 c4 10             	add    $0x10,%esp
  800da2:	85 c0                	test   %eax,%eax
  800da4:	0f 88 82 00 00 00    	js     800e2c <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800daa:	83 ec 0c             	sub    $0xc,%esp
  800dad:	ff 75 f0             	push   -0x10(%ebp)
  800db0:	e8 b6 f5 ff ff       	call   80036b <fd2data>
  800db5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dbc:	50                   	push   %eax
  800dbd:	6a 00                	push   $0x0
  800dbf:	56                   	push   %esi
  800dc0:	6a 00                	push   $0x0
  800dc2:	e8 e6 f3 ff ff       	call   8001ad <sys_page_map>
  800dc7:	89 c3                	mov    %eax,%ebx
  800dc9:	83 c4 20             	add    $0x20,%esp
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	78 4e                	js     800e1e <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  800dd0:	a1 24 30 80 00       	mov    0x803024,%eax
  800dd5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dd8:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800dda:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ddd:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800de4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800de7:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800de9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dec:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800df3:	83 ec 0c             	sub    $0xc,%esp
  800df6:	ff 75 f4             	push   -0xc(%ebp)
  800df9:	e8 5d f5 ff ff       	call   80035b <fd2num>
  800dfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e01:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e03:	83 c4 04             	add    $0x4,%esp
  800e06:	ff 75 f0             	push   -0x10(%ebp)
  800e09:	e8 4d f5 ff ff       	call   80035b <fd2num>
  800e0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e11:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e14:	83 c4 10             	add    $0x10,%esp
  800e17:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e1c:	eb 2e                	jmp    800e4c <pipe+0x141>
	sys_page_unmap(0, va);
  800e1e:	83 ec 08             	sub    $0x8,%esp
  800e21:	56                   	push   %esi
  800e22:	6a 00                	push   $0x0
  800e24:	e8 c6 f3 ff ff       	call   8001ef <sys_page_unmap>
  800e29:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e2c:	83 ec 08             	sub    $0x8,%esp
  800e2f:	ff 75 f0             	push   -0x10(%ebp)
  800e32:	6a 00                	push   $0x0
  800e34:	e8 b6 f3 ff ff       	call   8001ef <sys_page_unmap>
  800e39:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e3c:	83 ec 08             	sub    $0x8,%esp
  800e3f:	ff 75 f4             	push   -0xc(%ebp)
  800e42:	6a 00                	push   $0x0
  800e44:	e8 a6 f3 ff ff       	call   8001ef <sys_page_unmap>
  800e49:	83 c4 10             	add    $0x10,%esp
}
  800e4c:	89 d8                	mov    %ebx,%eax
  800e4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e51:	5b                   	pop    %ebx
  800e52:	5e                   	pop    %esi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    

00800e55 <pipeisclosed>:
{
  800e55:	55                   	push   %ebp
  800e56:	89 e5                	mov    %esp,%ebp
  800e58:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e5e:	50                   	push   %eax
  800e5f:	ff 75 08             	push   0x8(%ebp)
  800e62:	e8 6b f5 ff ff       	call   8003d2 <fd_lookup>
  800e67:	83 c4 10             	add    $0x10,%esp
  800e6a:	85 c0                	test   %eax,%eax
  800e6c:	78 18                	js     800e86 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e6e:	83 ec 0c             	sub    $0xc,%esp
  800e71:	ff 75 f4             	push   -0xc(%ebp)
  800e74:	e8 f2 f4 ff ff       	call   80036b <fd2data>
  800e79:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7e:	e8 33 fd ff ff       	call   800bb6 <_pipeisclosed>
  800e83:	83 c4 10             	add    $0x10,%esp
}
  800e86:	c9                   	leave  
  800e87:	c3                   	ret    

00800e88 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  800e88:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8d:	c3                   	ret    

00800e8e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e94:	68 a2 1e 80 00       	push   $0x801ea2
  800e99:	ff 75 0c             	push   0xc(%ebp)
  800e9c:	e8 10 08 00 00       	call   8016b1 <strcpy>
	return 0;
}
  800ea1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea6:	c9                   	leave  
  800ea7:	c3                   	ret    

00800ea8 <devcons_write>:
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	57                   	push   %edi
  800eac:	56                   	push   %esi
  800ead:	53                   	push   %ebx
  800eae:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800eb4:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800eb9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800ebf:	eb 2e                	jmp    800eef <devcons_write+0x47>
		m = n - tot;
  800ec1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec4:	29 f3                	sub    %esi,%ebx
  800ec6:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800ecb:	39 c3                	cmp    %eax,%ebx
  800ecd:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ed0:	83 ec 04             	sub    $0x4,%esp
  800ed3:	53                   	push   %ebx
  800ed4:	89 f0                	mov    %esi,%eax
  800ed6:	03 45 0c             	add    0xc(%ebp),%eax
  800ed9:	50                   	push   %eax
  800eda:	57                   	push   %edi
  800edb:	e8 67 09 00 00       	call   801847 <memmove>
		sys_cputs(buf, m);
  800ee0:	83 c4 08             	add    $0x8,%esp
  800ee3:	53                   	push   %ebx
  800ee4:	57                   	push   %edi
  800ee5:	e8 c4 f1 ff ff       	call   8000ae <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800eea:	01 de                	add    %ebx,%esi
  800eec:	83 c4 10             	add    $0x10,%esp
  800eef:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ef2:	72 cd                	jb     800ec1 <devcons_write+0x19>
}
  800ef4:	89 f0                	mov    %esi,%eax
  800ef6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef9:	5b                   	pop    %ebx
  800efa:	5e                   	pop    %esi
  800efb:	5f                   	pop    %edi
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    

00800efe <devcons_read>:
{
  800efe:	55                   	push   %ebp
  800eff:	89 e5                	mov    %esp,%ebp
  800f01:	83 ec 08             	sub    $0x8,%esp
  800f04:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f09:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f0d:	75 07                	jne    800f16 <devcons_read+0x18>
  800f0f:	eb 1f                	jmp    800f30 <devcons_read+0x32>
		sys_yield();
  800f11:	e8 35 f2 ff ff       	call   80014b <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f16:	e8 b1 f1 ff ff       	call   8000cc <sys_cgetc>
  800f1b:	85 c0                	test   %eax,%eax
  800f1d:	74 f2                	je     800f11 <devcons_read+0x13>
	if (c < 0)
  800f1f:	78 0f                	js     800f30 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  800f21:	83 f8 04             	cmp    $0x4,%eax
  800f24:	74 0c                	je     800f32 <devcons_read+0x34>
	*(char*)vbuf = c;
  800f26:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f29:	88 02                	mov    %al,(%edx)
	return 1;
  800f2b:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f30:	c9                   	leave  
  800f31:	c3                   	ret    
		return 0;
  800f32:	b8 00 00 00 00       	mov    $0x0,%eax
  800f37:	eb f7                	jmp    800f30 <devcons_read+0x32>

00800f39 <cputchar>:
{
  800f39:	55                   	push   %ebp
  800f3a:	89 e5                	mov    %esp,%ebp
  800f3c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f42:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f45:	6a 01                	push   $0x1
  800f47:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f4a:	50                   	push   %eax
  800f4b:	e8 5e f1 ff ff       	call   8000ae <sys_cputs>
}
  800f50:	83 c4 10             	add    $0x10,%esp
  800f53:	c9                   	leave  
  800f54:	c3                   	ret    

00800f55 <getchar>:
{
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f5b:	6a 01                	push   $0x1
  800f5d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f60:	50                   	push   %eax
  800f61:	6a 00                	push   $0x0
  800f63:	e8 ce f6 ff ff       	call   800636 <read>
	if (r < 0)
  800f68:	83 c4 10             	add    $0x10,%esp
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	78 06                	js     800f75 <getchar+0x20>
	if (r < 1)
  800f6f:	74 06                	je     800f77 <getchar+0x22>
	return c;
  800f71:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800f75:	c9                   	leave  
  800f76:	c3                   	ret    
		return -E_EOF;
  800f77:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800f7c:	eb f7                	jmp    800f75 <getchar+0x20>

00800f7e <iscons>:
{
  800f7e:	55                   	push   %ebp
  800f7f:	89 e5                	mov    %esp,%ebp
  800f81:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f84:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f87:	50                   	push   %eax
  800f88:	ff 75 08             	push   0x8(%ebp)
  800f8b:	e8 42 f4 ff ff       	call   8003d2 <fd_lookup>
  800f90:	83 c4 10             	add    $0x10,%esp
  800f93:	85 c0                	test   %eax,%eax
  800f95:	78 11                	js     800fa8 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f9a:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800fa0:	39 10                	cmp    %edx,(%eax)
  800fa2:	0f 94 c0             	sete   %al
  800fa5:	0f b6 c0             	movzbl %al,%eax
}
  800fa8:	c9                   	leave  
  800fa9:	c3                   	ret    

00800faa <opencons>:
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb3:	50                   	push   %eax
  800fb4:	e8 c9 f3 ff ff       	call   800382 <fd_alloc>
  800fb9:	83 c4 10             	add    $0x10,%esp
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	78 3a                	js     800ffa <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fc0:	83 ec 04             	sub    $0x4,%esp
  800fc3:	68 07 04 00 00       	push   $0x407
  800fc8:	ff 75 f4             	push   -0xc(%ebp)
  800fcb:	6a 00                	push   $0x0
  800fcd:	e8 98 f1 ff ff       	call   80016a <sys_page_alloc>
  800fd2:	83 c4 10             	add    $0x10,%esp
  800fd5:	85 c0                	test   %eax,%eax
  800fd7:	78 21                	js     800ffa <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800fd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fdc:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800fe2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fe4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fee:	83 ec 0c             	sub    $0xc,%esp
  800ff1:	50                   	push   %eax
  800ff2:	e8 64 f3 ff ff       	call   80035b <fd2num>
  800ff7:	83 c4 10             	add    $0x10,%esp
}
  800ffa:	c9                   	leave  
  800ffb:	c3                   	ret    

00800ffc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	56                   	push   %esi
  801000:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801001:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801004:	8b 35 04 30 80 00    	mov    0x803004,%esi
  80100a:	e8 1d f1 ff ff       	call   80012c <sys_getenvid>
  80100f:	83 ec 0c             	sub    $0xc,%esp
  801012:	ff 75 0c             	push   0xc(%ebp)
  801015:	ff 75 08             	push   0x8(%ebp)
  801018:	56                   	push   %esi
  801019:	50                   	push   %eax
  80101a:	68 b0 1e 80 00       	push   $0x801eb0
  80101f:	e8 b3 00 00 00       	call   8010d7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801024:	83 c4 18             	add    $0x18,%esp
  801027:	53                   	push   %ebx
  801028:	ff 75 10             	push   0x10(%ebp)
  80102b:	e8 56 00 00 00       	call   801086 <vcprintf>
	cprintf("\n");
  801030:	c7 04 24 9b 1e 80 00 	movl   $0x801e9b,(%esp)
  801037:	e8 9b 00 00 00       	call   8010d7 <cprintf>
  80103c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80103f:	cc                   	int3   
  801040:	eb fd                	jmp    80103f <_panic+0x43>

00801042 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	53                   	push   %ebx
  801046:	83 ec 04             	sub    $0x4,%esp
  801049:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80104c:	8b 13                	mov    (%ebx),%edx
  80104e:	8d 42 01             	lea    0x1(%edx),%eax
  801051:	89 03                	mov    %eax,(%ebx)
  801053:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801056:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80105a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80105f:	74 09                	je     80106a <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801061:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801065:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801068:	c9                   	leave  
  801069:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80106a:	83 ec 08             	sub    $0x8,%esp
  80106d:	68 ff 00 00 00       	push   $0xff
  801072:	8d 43 08             	lea    0x8(%ebx),%eax
  801075:	50                   	push   %eax
  801076:	e8 33 f0 ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  80107b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801081:	83 c4 10             	add    $0x10,%esp
  801084:	eb db                	jmp    801061 <putch+0x1f>

00801086 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80108f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801096:	00 00 00 
	b.cnt = 0;
  801099:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010a0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010a3:	ff 75 0c             	push   0xc(%ebp)
  8010a6:	ff 75 08             	push   0x8(%ebp)
  8010a9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010af:	50                   	push   %eax
  8010b0:	68 42 10 80 00       	push   $0x801042
  8010b5:	e8 14 01 00 00       	call   8011ce <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010ba:	83 c4 08             	add    $0x8,%esp
  8010bd:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8010c3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010c9:	50                   	push   %eax
  8010ca:	e8 df ef ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  8010cf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010d5:	c9                   	leave  
  8010d6:	c3                   	ret    

008010d7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010dd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010e0:	50                   	push   %eax
  8010e1:	ff 75 08             	push   0x8(%ebp)
  8010e4:	e8 9d ff ff ff       	call   801086 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010e9:	c9                   	leave  
  8010ea:	c3                   	ret    

008010eb <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	57                   	push   %edi
  8010ef:	56                   	push   %esi
  8010f0:	53                   	push   %ebx
  8010f1:	83 ec 1c             	sub    $0x1c,%esp
  8010f4:	89 c7                	mov    %eax,%edi
  8010f6:	89 d6                	mov    %edx,%esi
  8010f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010fe:	89 d1                	mov    %edx,%ecx
  801100:	89 c2                	mov    %eax,%edx
  801102:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801105:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801108:	8b 45 10             	mov    0x10(%ebp),%eax
  80110b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80110e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801111:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801118:	39 c2                	cmp    %eax,%edx
  80111a:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80111d:	72 3e                	jb     80115d <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80111f:	83 ec 0c             	sub    $0xc,%esp
  801122:	ff 75 18             	push   0x18(%ebp)
  801125:	83 eb 01             	sub    $0x1,%ebx
  801128:	53                   	push   %ebx
  801129:	50                   	push   %eax
  80112a:	83 ec 08             	sub    $0x8,%esp
  80112d:	ff 75 e4             	push   -0x1c(%ebp)
  801130:	ff 75 e0             	push   -0x20(%ebp)
  801133:	ff 75 dc             	push   -0x24(%ebp)
  801136:	ff 75 d8             	push   -0x28(%ebp)
  801139:	e8 f2 09 00 00       	call   801b30 <__udivdi3>
  80113e:	83 c4 18             	add    $0x18,%esp
  801141:	52                   	push   %edx
  801142:	50                   	push   %eax
  801143:	89 f2                	mov    %esi,%edx
  801145:	89 f8                	mov    %edi,%eax
  801147:	e8 9f ff ff ff       	call   8010eb <printnum>
  80114c:	83 c4 20             	add    $0x20,%esp
  80114f:	eb 13                	jmp    801164 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801151:	83 ec 08             	sub    $0x8,%esp
  801154:	56                   	push   %esi
  801155:	ff 75 18             	push   0x18(%ebp)
  801158:	ff d7                	call   *%edi
  80115a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80115d:	83 eb 01             	sub    $0x1,%ebx
  801160:	85 db                	test   %ebx,%ebx
  801162:	7f ed                	jg     801151 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801164:	83 ec 08             	sub    $0x8,%esp
  801167:	56                   	push   %esi
  801168:	83 ec 04             	sub    $0x4,%esp
  80116b:	ff 75 e4             	push   -0x1c(%ebp)
  80116e:	ff 75 e0             	push   -0x20(%ebp)
  801171:	ff 75 dc             	push   -0x24(%ebp)
  801174:	ff 75 d8             	push   -0x28(%ebp)
  801177:	e8 d4 0a 00 00       	call   801c50 <__umoddi3>
  80117c:	83 c4 14             	add    $0x14,%esp
  80117f:	0f be 80 d3 1e 80 00 	movsbl 0x801ed3(%eax),%eax
  801186:	50                   	push   %eax
  801187:	ff d7                	call   *%edi
}
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118f:	5b                   	pop    %ebx
  801190:	5e                   	pop    %esi
  801191:	5f                   	pop    %edi
  801192:	5d                   	pop    %ebp
  801193:	c3                   	ret    

00801194 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80119a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80119e:	8b 10                	mov    (%eax),%edx
  8011a0:	3b 50 04             	cmp    0x4(%eax),%edx
  8011a3:	73 0a                	jae    8011af <sprintputch+0x1b>
		*b->buf++ = ch;
  8011a5:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011a8:	89 08                	mov    %ecx,(%eax)
  8011aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8011ad:	88 02                	mov    %al,(%edx)
}
  8011af:	5d                   	pop    %ebp
  8011b0:	c3                   	ret    

008011b1 <printfmt>:
{
  8011b1:	55                   	push   %ebp
  8011b2:	89 e5                	mov    %esp,%ebp
  8011b4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011b7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011ba:	50                   	push   %eax
  8011bb:	ff 75 10             	push   0x10(%ebp)
  8011be:	ff 75 0c             	push   0xc(%ebp)
  8011c1:	ff 75 08             	push   0x8(%ebp)
  8011c4:	e8 05 00 00 00       	call   8011ce <vprintfmt>
}
  8011c9:	83 c4 10             	add    $0x10,%esp
  8011cc:	c9                   	leave  
  8011cd:	c3                   	ret    

008011ce <vprintfmt>:
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
  8011d1:	57                   	push   %edi
  8011d2:	56                   	push   %esi
  8011d3:	53                   	push   %ebx
  8011d4:	83 ec 3c             	sub    $0x3c,%esp
  8011d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8011da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011dd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011e0:	eb 0a                	jmp    8011ec <vprintfmt+0x1e>
			putch(ch, putdat);
  8011e2:	83 ec 08             	sub    $0x8,%esp
  8011e5:	53                   	push   %ebx
  8011e6:	50                   	push   %eax
  8011e7:	ff d6                	call   *%esi
  8011e9:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8011ec:	83 c7 01             	add    $0x1,%edi
  8011ef:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8011f3:	83 f8 25             	cmp    $0x25,%eax
  8011f6:	74 0c                	je     801204 <vprintfmt+0x36>
			if (ch == '\0')
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	75 e6                	jne    8011e2 <vprintfmt+0x14>
}
  8011fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ff:	5b                   	pop    %ebx
  801200:	5e                   	pop    %esi
  801201:	5f                   	pop    %edi
  801202:	5d                   	pop    %ebp
  801203:	c3                   	ret    
		padc = ' ';
  801204:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  801208:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80120f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801216:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80121d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801222:	8d 47 01             	lea    0x1(%edi),%eax
  801225:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801228:	0f b6 17             	movzbl (%edi),%edx
  80122b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80122e:	3c 55                	cmp    $0x55,%al
  801230:	0f 87 bb 03 00 00    	ja     8015f1 <vprintfmt+0x423>
  801236:	0f b6 c0             	movzbl %al,%eax
  801239:	ff 24 85 20 20 80 00 	jmp    *0x802020(,%eax,4)
  801240:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801243:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801247:	eb d9                	jmp    801222 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801249:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80124c:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801250:	eb d0                	jmp    801222 <vprintfmt+0x54>
  801252:	0f b6 d2             	movzbl %dl,%edx
  801255:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801258:	b8 00 00 00 00       	mov    $0x0,%eax
  80125d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801260:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801263:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801267:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80126a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80126d:	83 f9 09             	cmp    $0x9,%ecx
  801270:	77 55                	ja     8012c7 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  801272:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801275:	eb e9                	jmp    801260 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801277:	8b 45 14             	mov    0x14(%ebp),%eax
  80127a:	8b 00                	mov    (%eax),%eax
  80127c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80127f:	8b 45 14             	mov    0x14(%ebp),%eax
  801282:	8d 40 04             	lea    0x4(%eax),%eax
  801285:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801288:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80128b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80128f:	79 91                	jns    801222 <vprintfmt+0x54>
				width = precision, precision = -1;
  801291:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801294:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801297:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80129e:	eb 82                	jmp    801222 <vprintfmt+0x54>
  8012a0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8012a3:	85 d2                	test   %edx,%edx
  8012a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8012aa:	0f 49 c2             	cmovns %edx,%eax
  8012ad:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012b3:	e9 6a ff ff ff       	jmp    801222 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8012b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012bb:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8012c2:	e9 5b ff ff ff       	jmp    801222 <vprintfmt+0x54>
  8012c7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012cd:	eb bc                	jmp    80128b <vprintfmt+0xbd>
			lflag++;
  8012cf:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012d5:	e9 48 ff ff ff       	jmp    801222 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8012da:	8b 45 14             	mov    0x14(%ebp),%eax
  8012dd:	8d 78 04             	lea    0x4(%eax),%edi
  8012e0:	83 ec 08             	sub    $0x8,%esp
  8012e3:	53                   	push   %ebx
  8012e4:	ff 30                	push   (%eax)
  8012e6:	ff d6                	call   *%esi
			break;
  8012e8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8012eb:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8012ee:	e9 9d 02 00 00       	jmp    801590 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8012f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f6:	8d 78 04             	lea    0x4(%eax),%edi
  8012f9:	8b 10                	mov    (%eax),%edx
  8012fb:	89 d0                	mov    %edx,%eax
  8012fd:	f7 d8                	neg    %eax
  8012ff:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801302:	83 f8 0f             	cmp    $0xf,%eax
  801305:	7f 23                	jg     80132a <vprintfmt+0x15c>
  801307:	8b 14 85 80 21 80 00 	mov    0x802180(,%eax,4),%edx
  80130e:	85 d2                	test   %edx,%edx
  801310:	74 18                	je     80132a <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  801312:	52                   	push   %edx
  801313:	68 69 1e 80 00       	push   $0x801e69
  801318:	53                   	push   %ebx
  801319:	56                   	push   %esi
  80131a:	e8 92 fe ff ff       	call   8011b1 <printfmt>
  80131f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801322:	89 7d 14             	mov    %edi,0x14(%ebp)
  801325:	e9 66 02 00 00       	jmp    801590 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80132a:	50                   	push   %eax
  80132b:	68 eb 1e 80 00       	push   $0x801eeb
  801330:	53                   	push   %ebx
  801331:	56                   	push   %esi
  801332:	e8 7a fe ff ff       	call   8011b1 <printfmt>
  801337:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80133a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80133d:	e9 4e 02 00 00       	jmp    801590 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  801342:	8b 45 14             	mov    0x14(%ebp),%eax
  801345:	83 c0 04             	add    $0x4,%eax
  801348:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80134b:	8b 45 14             	mov    0x14(%ebp),%eax
  80134e:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801350:	85 d2                	test   %edx,%edx
  801352:	b8 e4 1e 80 00       	mov    $0x801ee4,%eax
  801357:	0f 45 c2             	cmovne %edx,%eax
  80135a:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80135d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801361:	7e 06                	jle    801369 <vprintfmt+0x19b>
  801363:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801367:	75 0d                	jne    801376 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801369:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80136c:	89 c7                	mov    %eax,%edi
  80136e:	03 45 e0             	add    -0x20(%ebp),%eax
  801371:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801374:	eb 55                	jmp    8013cb <vprintfmt+0x1fd>
  801376:	83 ec 08             	sub    $0x8,%esp
  801379:	ff 75 d8             	push   -0x28(%ebp)
  80137c:	ff 75 cc             	push   -0x34(%ebp)
  80137f:	e8 0a 03 00 00       	call   80168e <strnlen>
  801384:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801387:	29 c1                	sub    %eax,%ecx
  801389:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80138c:	83 c4 10             	add    $0x10,%esp
  80138f:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  801391:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801395:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801398:	eb 0f                	jmp    8013a9 <vprintfmt+0x1db>
					putch(padc, putdat);
  80139a:	83 ec 08             	sub    $0x8,%esp
  80139d:	53                   	push   %ebx
  80139e:	ff 75 e0             	push   -0x20(%ebp)
  8013a1:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013a3:	83 ef 01             	sub    $0x1,%edi
  8013a6:	83 c4 10             	add    $0x10,%esp
  8013a9:	85 ff                	test   %edi,%edi
  8013ab:	7f ed                	jg     80139a <vprintfmt+0x1cc>
  8013ad:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8013b0:	85 d2                	test   %edx,%edx
  8013b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b7:	0f 49 c2             	cmovns %edx,%eax
  8013ba:	29 c2                	sub    %eax,%edx
  8013bc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8013bf:	eb a8                	jmp    801369 <vprintfmt+0x19b>
					putch(ch, putdat);
  8013c1:	83 ec 08             	sub    $0x8,%esp
  8013c4:	53                   	push   %ebx
  8013c5:	52                   	push   %edx
  8013c6:	ff d6                	call   *%esi
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013ce:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013d0:	83 c7 01             	add    $0x1,%edi
  8013d3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8013d7:	0f be d0             	movsbl %al,%edx
  8013da:	85 d2                	test   %edx,%edx
  8013dc:	74 4b                	je     801429 <vprintfmt+0x25b>
  8013de:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013e2:	78 06                	js     8013ea <vprintfmt+0x21c>
  8013e4:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8013e8:	78 1e                	js     801408 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8013ea:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8013ee:	74 d1                	je     8013c1 <vprintfmt+0x1f3>
  8013f0:	0f be c0             	movsbl %al,%eax
  8013f3:	83 e8 20             	sub    $0x20,%eax
  8013f6:	83 f8 5e             	cmp    $0x5e,%eax
  8013f9:	76 c6                	jbe    8013c1 <vprintfmt+0x1f3>
					putch('?', putdat);
  8013fb:	83 ec 08             	sub    $0x8,%esp
  8013fe:	53                   	push   %ebx
  8013ff:	6a 3f                	push   $0x3f
  801401:	ff d6                	call   *%esi
  801403:	83 c4 10             	add    $0x10,%esp
  801406:	eb c3                	jmp    8013cb <vprintfmt+0x1fd>
  801408:	89 cf                	mov    %ecx,%edi
  80140a:	eb 0e                	jmp    80141a <vprintfmt+0x24c>
				putch(' ', putdat);
  80140c:	83 ec 08             	sub    $0x8,%esp
  80140f:	53                   	push   %ebx
  801410:	6a 20                	push   $0x20
  801412:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801414:	83 ef 01             	sub    $0x1,%edi
  801417:	83 c4 10             	add    $0x10,%esp
  80141a:	85 ff                	test   %edi,%edi
  80141c:	7f ee                	jg     80140c <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80141e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801421:	89 45 14             	mov    %eax,0x14(%ebp)
  801424:	e9 67 01 00 00       	jmp    801590 <vprintfmt+0x3c2>
  801429:	89 cf                	mov    %ecx,%edi
  80142b:	eb ed                	jmp    80141a <vprintfmt+0x24c>
	if (lflag >= 2)
  80142d:	83 f9 01             	cmp    $0x1,%ecx
  801430:	7f 1b                	jg     80144d <vprintfmt+0x27f>
	else if (lflag)
  801432:	85 c9                	test   %ecx,%ecx
  801434:	74 63                	je     801499 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  801436:	8b 45 14             	mov    0x14(%ebp),%eax
  801439:	8b 00                	mov    (%eax),%eax
  80143b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80143e:	99                   	cltd   
  80143f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801442:	8b 45 14             	mov    0x14(%ebp),%eax
  801445:	8d 40 04             	lea    0x4(%eax),%eax
  801448:	89 45 14             	mov    %eax,0x14(%ebp)
  80144b:	eb 17                	jmp    801464 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80144d:	8b 45 14             	mov    0x14(%ebp),%eax
  801450:	8b 50 04             	mov    0x4(%eax),%edx
  801453:	8b 00                	mov    (%eax),%eax
  801455:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801458:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80145b:	8b 45 14             	mov    0x14(%ebp),%eax
  80145e:	8d 40 08             	lea    0x8(%eax),%eax
  801461:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801464:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801467:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80146a:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80146f:	85 c9                	test   %ecx,%ecx
  801471:	0f 89 ff 00 00 00    	jns    801576 <vprintfmt+0x3a8>
				putch('-', putdat);
  801477:	83 ec 08             	sub    $0x8,%esp
  80147a:	53                   	push   %ebx
  80147b:	6a 2d                	push   $0x2d
  80147d:	ff d6                	call   *%esi
				num = -(long long) num;
  80147f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801482:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801485:	f7 da                	neg    %edx
  801487:	83 d1 00             	adc    $0x0,%ecx
  80148a:	f7 d9                	neg    %ecx
  80148c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80148f:	bf 0a 00 00 00       	mov    $0xa,%edi
  801494:	e9 dd 00 00 00       	jmp    801576 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801499:	8b 45 14             	mov    0x14(%ebp),%eax
  80149c:	8b 00                	mov    (%eax),%eax
  80149e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014a1:	99                   	cltd   
  8014a2:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a8:	8d 40 04             	lea    0x4(%eax),%eax
  8014ab:	89 45 14             	mov    %eax,0x14(%ebp)
  8014ae:	eb b4                	jmp    801464 <vprintfmt+0x296>
	if (lflag >= 2)
  8014b0:	83 f9 01             	cmp    $0x1,%ecx
  8014b3:	7f 1e                	jg     8014d3 <vprintfmt+0x305>
	else if (lflag)
  8014b5:	85 c9                	test   %ecx,%ecx
  8014b7:	74 32                	je     8014eb <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8014b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014bc:	8b 10                	mov    (%eax),%edx
  8014be:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014c3:	8d 40 04             	lea    0x4(%eax),%eax
  8014c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014c9:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8014ce:	e9 a3 00 00 00       	jmp    801576 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8014d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d6:	8b 10                	mov    (%eax),%edx
  8014d8:	8b 48 04             	mov    0x4(%eax),%ecx
  8014db:	8d 40 08             	lea    0x8(%eax),%eax
  8014de:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014e1:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8014e6:	e9 8b 00 00 00       	jmp    801576 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8014eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ee:	8b 10                	mov    (%eax),%edx
  8014f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014f5:	8d 40 04             	lea    0x4(%eax),%eax
  8014f8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014fb:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  801500:	eb 74                	jmp    801576 <vprintfmt+0x3a8>
	if (lflag >= 2)
  801502:	83 f9 01             	cmp    $0x1,%ecx
  801505:	7f 1b                	jg     801522 <vprintfmt+0x354>
	else if (lflag)
  801507:	85 c9                	test   %ecx,%ecx
  801509:	74 2c                	je     801537 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80150b:	8b 45 14             	mov    0x14(%ebp),%eax
  80150e:	8b 10                	mov    (%eax),%edx
  801510:	b9 00 00 00 00       	mov    $0x0,%ecx
  801515:	8d 40 04             	lea    0x4(%eax),%eax
  801518:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80151b:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  801520:	eb 54                	jmp    801576 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801522:	8b 45 14             	mov    0x14(%ebp),%eax
  801525:	8b 10                	mov    (%eax),%edx
  801527:	8b 48 04             	mov    0x4(%eax),%ecx
  80152a:	8d 40 08             	lea    0x8(%eax),%eax
  80152d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801530:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  801535:	eb 3f                	jmp    801576 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801537:	8b 45 14             	mov    0x14(%ebp),%eax
  80153a:	8b 10                	mov    (%eax),%edx
  80153c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801541:	8d 40 04             	lea    0x4(%eax),%eax
  801544:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801547:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80154c:	eb 28                	jmp    801576 <vprintfmt+0x3a8>
			putch('0', putdat);
  80154e:	83 ec 08             	sub    $0x8,%esp
  801551:	53                   	push   %ebx
  801552:	6a 30                	push   $0x30
  801554:	ff d6                	call   *%esi
			putch('x', putdat);
  801556:	83 c4 08             	add    $0x8,%esp
  801559:	53                   	push   %ebx
  80155a:	6a 78                	push   $0x78
  80155c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80155e:	8b 45 14             	mov    0x14(%ebp),%eax
  801561:	8b 10                	mov    (%eax),%edx
  801563:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801568:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80156b:	8d 40 04             	lea    0x4(%eax),%eax
  80156e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801571:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801576:	83 ec 0c             	sub    $0xc,%esp
  801579:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80157d:	50                   	push   %eax
  80157e:	ff 75 e0             	push   -0x20(%ebp)
  801581:	57                   	push   %edi
  801582:	51                   	push   %ecx
  801583:	52                   	push   %edx
  801584:	89 da                	mov    %ebx,%edx
  801586:	89 f0                	mov    %esi,%eax
  801588:	e8 5e fb ff ff       	call   8010eb <printnum>
			break;
  80158d:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801590:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801593:	e9 54 fc ff ff       	jmp    8011ec <vprintfmt+0x1e>
	if (lflag >= 2)
  801598:	83 f9 01             	cmp    $0x1,%ecx
  80159b:	7f 1b                	jg     8015b8 <vprintfmt+0x3ea>
	else if (lflag)
  80159d:	85 c9                	test   %ecx,%ecx
  80159f:	74 2c                	je     8015cd <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8015a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a4:	8b 10                	mov    (%eax),%edx
  8015a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015ab:	8d 40 04             	lea    0x4(%eax),%eax
  8015ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015b1:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8015b6:	eb be                	jmp    801576 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8015b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015bb:	8b 10                	mov    (%eax),%edx
  8015bd:	8b 48 04             	mov    0x4(%eax),%ecx
  8015c0:	8d 40 08             	lea    0x8(%eax),%eax
  8015c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015c6:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8015cb:	eb a9                	jmp    801576 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8015cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d0:	8b 10                	mov    (%eax),%edx
  8015d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015d7:	8d 40 04             	lea    0x4(%eax),%eax
  8015da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015dd:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8015e2:	eb 92                	jmp    801576 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8015e4:	83 ec 08             	sub    $0x8,%esp
  8015e7:	53                   	push   %ebx
  8015e8:	6a 25                	push   $0x25
  8015ea:	ff d6                	call   *%esi
			break;
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	eb 9f                	jmp    801590 <vprintfmt+0x3c2>
			putch('%', putdat);
  8015f1:	83 ec 08             	sub    $0x8,%esp
  8015f4:	53                   	push   %ebx
  8015f5:	6a 25                	push   $0x25
  8015f7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	89 f8                	mov    %edi,%eax
  8015fe:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801602:	74 05                	je     801609 <vprintfmt+0x43b>
  801604:	83 e8 01             	sub    $0x1,%eax
  801607:	eb f5                	jmp    8015fe <vprintfmt+0x430>
  801609:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80160c:	eb 82                	jmp    801590 <vprintfmt+0x3c2>

0080160e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	83 ec 18             	sub    $0x18,%esp
  801614:	8b 45 08             	mov    0x8(%ebp),%eax
  801617:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80161a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80161d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801621:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801624:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80162b:	85 c0                	test   %eax,%eax
  80162d:	74 26                	je     801655 <vsnprintf+0x47>
  80162f:	85 d2                	test   %edx,%edx
  801631:	7e 22                	jle    801655 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801633:	ff 75 14             	push   0x14(%ebp)
  801636:	ff 75 10             	push   0x10(%ebp)
  801639:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80163c:	50                   	push   %eax
  80163d:	68 94 11 80 00       	push   $0x801194
  801642:	e8 87 fb ff ff       	call   8011ce <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801647:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80164a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80164d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801650:	83 c4 10             	add    $0x10,%esp
}
  801653:	c9                   	leave  
  801654:	c3                   	ret    
		return -E_INVAL;
  801655:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80165a:	eb f7                	jmp    801653 <vsnprintf+0x45>

0080165c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801662:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801665:	50                   	push   %eax
  801666:	ff 75 10             	push   0x10(%ebp)
  801669:	ff 75 0c             	push   0xc(%ebp)
  80166c:	ff 75 08             	push   0x8(%ebp)
  80166f:	e8 9a ff ff ff       	call   80160e <vsnprintf>
	va_end(ap);

	return rc;
}
  801674:	c9                   	leave  
  801675:	c3                   	ret    

00801676 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80167c:	b8 00 00 00 00       	mov    $0x0,%eax
  801681:	eb 03                	jmp    801686 <strlen+0x10>
		n++;
  801683:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801686:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80168a:	75 f7                	jne    801683 <strlen+0xd>
	return n;
}
  80168c:	5d                   	pop    %ebp
  80168d:	c3                   	ret    

0080168e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801694:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801697:	b8 00 00 00 00       	mov    $0x0,%eax
  80169c:	eb 03                	jmp    8016a1 <strnlen+0x13>
		n++;
  80169e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a1:	39 d0                	cmp    %edx,%eax
  8016a3:	74 08                	je     8016ad <strnlen+0x1f>
  8016a5:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016a9:	75 f3                	jne    80169e <strnlen+0x10>
  8016ab:	89 c2                	mov    %eax,%edx
	return n;
}
  8016ad:	89 d0                	mov    %edx,%eax
  8016af:	5d                   	pop    %ebp
  8016b0:	c3                   	ret    

008016b1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016b1:	55                   	push   %ebp
  8016b2:	89 e5                	mov    %esp,%ebp
  8016b4:	53                   	push   %ebx
  8016b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c0:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016c4:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016c7:	83 c0 01             	add    $0x1,%eax
  8016ca:	84 d2                	test   %dl,%dl
  8016cc:	75 f2                	jne    8016c0 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8016ce:	89 c8                	mov    %ecx,%eax
  8016d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016d3:	c9                   	leave  
  8016d4:	c3                   	ret    

008016d5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016d5:	55                   	push   %ebp
  8016d6:	89 e5                	mov    %esp,%ebp
  8016d8:	53                   	push   %ebx
  8016d9:	83 ec 10             	sub    $0x10,%esp
  8016dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016df:	53                   	push   %ebx
  8016e0:	e8 91 ff ff ff       	call   801676 <strlen>
  8016e5:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8016e8:	ff 75 0c             	push   0xc(%ebp)
  8016eb:	01 d8                	add    %ebx,%eax
  8016ed:	50                   	push   %eax
  8016ee:	e8 be ff ff ff       	call   8016b1 <strcpy>
	return dst;
}
  8016f3:	89 d8                	mov    %ebx,%eax
  8016f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f8:	c9                   	leave  
  8016f9:	c3                   	ret    

008016fa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	56                   	push   %esi
  8016fe:	53                   	push   %ebx
  8016ff:	8b 75 08             	mov    0x8(%ebp),%esi
  801702:	8b 55 0c             	mov    0xc(%ebp),%edx
  801705:	89 f3                	mov    %esi,%ebx
  801707:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80170a:	89 f0                	mov    %esi,%eax
  80170c:	eb 0f                	jmp    80171d <strncpy+0x23>
		*dst++ = *src;
  80170e:	83 c0 01             	add    $0x1,%eax
  801711:	0f b6 0a             	movzbl (%edx),%ecx
  801714:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801717:	80 f9 01             	cmp    $0x1,%cl
  80171a:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80171d:	39 d8                	cmp    %ebx,%eax
  80171f:	75 ed                	jne    80170e <strncpy+0x14>
	}
	return ret;
}
  801721:	89 f0                	mov    %esi,%eax
  801723:	5b                   	pop    %ebx
  801724:	5e                   	pop    %esi
  801725:	5d                   	pop    %ebp
  801726:	c3                   	ret    

00801727 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801727:	55                   	push   %ebp
  801728:	89 e5                	mov    %esp,%ebp
  80172a:	56                   	push   %esi
  80172b:	53                   	push   %ebx
  80172c:	8b 75 08             	mov    0x8(%ebp),%esi
  80172f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801732:	8b 55 10             	mov    0x10(%ebp),%edx
  801735:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801737:	85 d2                	test   %edx,%edx
  801739:	74 21                	je     80175c <strlcpy+0x35>
  80173b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80173f:	89 f2                	mov    %esi,%edx
  801741:	eb 09                	jmp    80174c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801743:	83 c1 01             	add    $0x1,%ecx
  801746:	83 c2 01             	add    $0x1,%edx
  801749:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80174c:	39 c2                	cmp    %eax,%edx
  80174e:	74 09                	je     801759 <strlcpy+0x32>
  801750:	0f b6 19             	movzbl (%ecx),%ebx
  801753:	84 db                	test   %bl,%bl
  801755:	75 ec                	jne    801743 <strlcpy+0x1c>
  801757:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801759:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80175c:	29 f0                	sub    %esi,%eax
}
  80175e:	5b                   	pop    %ebx
  80175f:	5e                   	pop    %esi
  801760:	5d                   	pop    %ebp
  801761:	c3                   	ret    

00801762 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801768:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80176b:	eb 06                	jmp    801773 <strcmp+0x11>
		p++, q++;
  80176d:	83 c1 01             	add    $0x1,%ecx
  801770:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801773:	0f b6 01             	movzbl (%ecx),%eax
  801776:	84 c0                	test   %al,%al
  801778:	74 04                	je     80177e <strcmp+0x1c>
  80177a:	3a 02                	cmp    (%edx),%al
  80177c:	74 ef                	je     80176d <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80177e:	0f b6 c0             	movzbl %al,%eax
  801781:	0f b6 12             	movzbl (%edx),%edx
  801784:	29 d0                	sub    %edx,%eax
}
  801786:	5d                   	pop    %ebp
  801787:	c3                   	ret    

00801788 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801788:	55                   	push   %ebp
  801789:	89 e5                	mov    %esp,%ebp
  80178b:	53                   	push   %ebx
  80178c:	8b 45 08             	mov    0x8(%ebp),%eax
  80178f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801792:	89 c3                	mov    %eax,%ebx
  801794:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801797:	eb 06                	jmp    80179f <strncmp+0x17>
		n--, p++, q++;
  801799:	83 c0 01             	add    $0x1,%eax
  80179c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80179f:	39 d8                	cmp    %ebx,%eax
  8017a1:	74 18                	je     8017bb <strncmp+0x33>
  8017a3:	0f b6 08             	movzbl (%eax),%ecx
  8017a6:	84 c9                	test   %cl,%cl
  8017a8:	74 04                	je     8017ae <strncmp+0x26>
  8017aa:	3a 0a                	cmp    (%edx),%cl
  8017ac:	74 eb                	je     801799 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ae:	0f b6 00             	movzbl (%eax),%eax
  8017b1:	0f b6 12             	movzbl (%edx),%edx
  8017b4:	29 d0                	sub    %edx,%eax
}
  8017b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b9:	c9                   	leave  
  8017ba:	c3                   	ret    
		return 0;
  8017bb:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c0:	eb f4                	jmp    8017b6 <strncmp+0x2e>

008017c2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017cc:	eb 03                	jmp    8017d1 <strchr+0xf>
  8017ce:	83 c0 01             	add    $0x1,%eax
  8017d1:	0f b6 10             	movzbl (%eax),%edx
  8017d4:	84 d2                	test   %dl,%dl
  8017d6:	74 06                	je     8017de <strchr+0x1c>
		if (*s == c)
  8017d8:	38 ca                	cmp    %cl,%dl
  8017da:	75 f2                	jne    8017ce <strchr+0xc>
  8017dc:	eb 05                	jmp    8017e3 <strchr+0x21>
			return (char *) s;
	return 0;
  8017de:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    

008017e5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017eb:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017ef:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017f2:	38 ca                	cmp    %cl,%dl
  8017f4:	74 09                	je     8017ff <strfind+0x1a>
  8017f6:	84 d2                	test   %dl,%dl
  8017f8:	74 05                	je     8017ff <strfind+0x1a>
	for (; *s; s++)
  8017fa:	83 c0 01             	add    $0x1,%eax
  8017fd:	eb f0                	jmp    8017ef <strfind+0xa>
			break;
	return (char *) s;
}
  8017ff:	5d                   	pop    %ebp
  801800:	c3                   	ret    

00801801 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	57                   	push   %edi
  801805:	56                   	push   %esi
  801806:	53                   	push   %ebx
  801807:	8b 7d 08             	mov    0x8(%ebp),%edi
  80180a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80180d:	85 c9                	test   %ecx,%ecx
  80180f:	74 2f                	je     801840 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801811:	89 f8                	mov    %edi,%eax
  801813:	09 c8                	or     %ecx,%eax
  801815:	a8 03                	test   $0x3,%al
  801817:	75 21                	jne    80183a <memset+0x39>
		c &= 0xFF;
  801819:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80181d:	89 d0                	mov    %edx,%eax
  80181f:	c1 e0 08             	shl    $0x8,%eax
  801822:	89 d3                	mov    %edx,%ebx
  801824:	c1 e3 18             	shl    $0x18,%ebx
  801827:	89 d6                	mov    %edx,%esi
  801829:	c1 e6 10             	shl    $0x10,%esi
  80182c:	09 f3                	or     %esi,%ebx
  80182e:	09 da                	or     %ebx,%edx
  801830:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801832:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801835:	fc                   	cld    
  801836:	f3 ab                	rep stos %eax,%es:(%edi)
  801838:	eb 06                	jmp    801840 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80183a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183d:	fc                   	cld    
  80183e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801840:	89 f8                	mov    %edi,%eax
  801842:	5b                   	pop    %ebx
  801843:	5e                   	pop    %esi
  801844:	5f                   	pop    %edi
  801845:	5d                   	pop    %ebp
  801846:	c3                   	ret    

00801847 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801847:	55                   	push   %ebp
  801848:	89 e5                	mov    %esp,%ebp
  80184a:	57                   	push   %edi
  80184b:	56                   	push   %esi
  80184c:	8b 45 08             	mov    0x8(%ebp),%eax
  80184f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801852:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801855:	39 c6                	cmp    %eax,%esi
  801857:	73 32                	jae    80188b <memmove+0x44>
  801859:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80185c:	39 c2                	cmp    %eax,%edx
  80185e:	76 2b                	jbe    80188b <memmove+0x44>
		s += n;
		d += n;
  801860:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801863:	89 d6                	mov    %edx,%esi
  801865:	09 fe                	or     %edi,%esi
  801867:	09 ce                	or     %ecx,%esi
  801869:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80186f:	75 0e                	jne    80187f <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801871:	83 ef 04             	sub    $0x4,%edi
  801874:	8d 72 fc             	lea    -0x4(%edx),%esi
  801877:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80187a:	fd                   	std    
  80187b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80187d:	eb 09                	jmp    801888 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80187f:	83 ef 01             	sub    $0x1,%edi
  801882:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801885:	fd                   	std    
  801886:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801888:	fc                   	cld    
  801889:	eb 1a                	jmp    8018a5 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80188b:	89 f2                	mov    %esi,%edx
  80188d:	09 c2                	or     %eax,%edx
  80188f:	09 ca                	or     %ecx,%edx
  801891:	f6 c2 03             	test   $0x3,%dl
  801894:	75 0a                	jne    8018a0 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801896:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801899:	89 c7                	mov    %eax,%edi
  80189b:	fc                   	cld    
  80189c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80189e:	eb 05                	jmp    8018a5 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8018a0:	89 c7                	mov    %eax,%edi
  8018a2:	fc                   	cld    
  8018a3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018a5:	5e                   	pop    %esi
  8018a6:	5f                   	pop    %edi
  8018a7:	5d                   	pop    %ebp
  8018a8:	c3                   	ret    

008018a9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018a9:	55                   	push   %ebp
  8018aa:	89 e5                	mov    %esp,%ebp
  8018ac:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8018af:	ff 75 10             	push   0x10(%ebp)
  8018b2:	ff 75 0c             	push   0xc(%ebp)
  8018b5:	ff 75 08             	push   0x8(%ebp)
  8018b8:	e8 8a ff ff ff       	call   801847 <memmove>
}
  8018bd:	c9                   	leave  
  8018be:	c3                   	ret    

008018bf <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
  8018c2:	56                   	push   %esi
  8018c3:	53                   	push   %ebx
  8018c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ca:	89 c6                	mov    %eax,%esi
  8018cc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018cf:	eb 06                	jmp    8018d7 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8018d1:	83 c0 01             	add    $0x1,%eax
  8018d4:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8018d7:	39 f0                	cmp    %esi,%eax
  8018d9:	74 14                	je     8018ef <memcmp+0x30>
		if (*s1 != *s2)
  8018db:	0f b6 08             	movzbl (%eax),%ecx
  8018de:	0f b6 1a             	movzbl (%edx),%ebx
  8018e1:	38 d9                	cmp    %bl,%cl
  8018e3:	74 ec                	je     8018d1 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8018e5:	0f b6 c1             	movzbl %cl,%eax
  8018e8:	0f b6 db             	movzbl %bl,%ebx
  8018eb:	29 d8                	sub    %ebx,%eax
  8018ed:	eb 05                	jmp    8018f4 <memcmp+0x35>
	}

	return 0;
  8018ef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f4:	5b                   	pop    %ebx
  8018f5:	5e                   	pop    %esi
  8018f6:	5d                   	pop    %ebp
  8018f7:	c3                   	ret    

008018f8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801901:	89 c2                	mov    %eax,%edx
  801903:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801906:	eb 03                	jmp    80190b <memfind+0x13>
  801908:	83 c0 01             	add    $0x1,%eax
  80190b:	39 d0                	cmp    %edx,%eax
  80190d:	73 04                	jae    801913 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80190f:	38 08                	cmp    %cl,(%eax)
  801911:	75 f5                	jne    801908 <memfind+0x10>
			break;
	return (void *) s;
}
  801913:	5d                   	pop    %ebp
  801914:	c3                   	ret    

00801915 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	57                   	push   %edi
  801919:	56                   	push   %esi
  80191a:	53                   	push   %ebx
  80191b:	8b 55 08             	mov    0x8(%ebp),%edx
  80191e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801921:	eb 03                	jmp    801926 <strtol+0x11>
		s++;
  801923:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801926:	0f b6 02             	movzbl (%edx),%eax
  801929:	3c 20                	cmp    $0x20,%al
  80192b:	74 f6                	je     801923 <strtol+0xe>
  80192d:	3c 09                	cmp    $0x9,%al
  80192f:	74 f2                	je     801923 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801931:	3c 2b                	cmp    $0x2b,%al
  801933:	74 2a                	je     80195f <strtol+0x4a>
	int neg = 0;
  801935:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80193a:	3c 2d                	cmp    $0x2d,%al
  80193c:	74 2b                	je     801969 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80193e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801944:	75 0f                	jne    801955 <strtol+0x40>
  801946:	80 3a 30             	cmpb   $0x30,(%edx)
  801949:	74 28                	je     801973 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80194b:	85 db                	test   %ebx,%ebx
  80194d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801952:	0f 44 d8             	cmove  %eax,%ebx
  801955:	b9 00 00 00 00       	mov    $0x0,%ecx
  80195a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80195d:	eb 46                	jmp    8019a5 <strtol+0x90>
		s++;
  80195f:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801962:	bf 00 00 00 00       	mov    $0x0,%edi
  801967:	eb d5                	jmp    80193e <strtol+0x29>
		s++, neg = 1;
  801969:	83 c2 01             	add    $0x1,%edx
  80196c:	bf 01 00 00 00       	mov    $0x1,%edi
  801971:	eb cb                	jmp    80193e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801973:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801977:	74 0e                	je     801987 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801979:	85 db                	test   %ebx,%ebx
  80197b:	75 d8                	jne    801955 <strtol+0x40>
		s++, base = 8;
  80197d:	83 c2 01             	add    $0x1,%edx
  801980:	bb 08 00 00 00       	mov    $0x8,%ebx
  801985:	eb ce                	jmp    801955 <strtol+0x40>
		s += 2, base = 16;
  801987:	83 c2 02             	add    $0x2,%edx
  80198a:	bb 10 00 00 00       	mov    $0x10,%ebx
  80198f:	eb c4                	jmp    801955 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801991:	0f be c0             	movsbl %al,%eax
  801994:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801997:	3b 45 10             	cmp    0x10(%ebp),%eax
  80199a:	7d 3a                	jge    8019d6 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  80199c:	83 c2 01             	add    $0x1,%edx
  80199f:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  8019a3:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  8019a5:	0f b6 02             	movzbl (%edx),%eax
  8019a8:	8d 70 d0             	lea    -0x30(%eax),%esi
  8019ab:	89 f3                	mov    %esi,%ebx
  8019ad:	80 fb 09             	cmp    $0x9,%bl
  8019b0:	76 df                	jbe    801991 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  8019b2:	8d 70 9f             	lea    -0x61(%eax),%esi
  8019b5:	89 f3                	mov    %esi,%ebx
  8019b7:	80 fb 19             	cmp    $0x19,%bl
  8019ba:	77 08                	ja     8019c4 <strtol+0xaf>
			dig = *s - 'a' + 10;
  8019bc:	0f be c0             	movsbl %al,%eax
  8019bf:	83 e8 57             	sub    $0x57,%eax
  8019c2:	eb d3                	jmp    801997 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8019c4:	8d 70 bf             	lea    -0x41(%eax),%esi
  8019c7:	89 f3                	mov    %esi,%ebx
  8019c9:	80 fb 19             	cmp    $0x19,%bl
  8019cc:	77 08                	ja     8019d6 <strtol+0xc1>
			dig = *s - 'A' + 10;
  8019ce:	0f be c0             	movsbl %al,%eax
  8019d1:	83 e8 37             	sub    $0x37,%eax
  8019d4:	eb c1                	jmp    801997 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8019d6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019da:	74 05                	je     8019e1 <strtol+0xcc>
		*endptr = (char *) s;
  8019dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019df:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8019e1:	89 c8                	mov    %ecx,%eax
  8019e3:	f7 d8                	neg    %eax
  8019e5:	85 ff                	test   %edi,%edi
  8019e7:	0f 45 c8             	cmovne %eax,%ecx
}
  8019ea:	89 c8                	mov    %ecx,%eax
  8019ec:	5b                   	pop    %ebx
  8019ed:	5e                   	pop    %esi
  8019ee:	5f                   	pop    %edi
  8019ef:	5d                   	pop    %ebp
  8019f0:	c3                   	ret    

008019f1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	56                   	push   %esi
  8019f5:	53                   	push   %ebx
  8019f6:	8b 75 08             	mov    0x8(%ebp),%esi
  8019f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8019ff:	85 c0                	test   %eax,%eax
  801a01:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a06:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801a09:	83 ec 0c             	sub    $0xc,%esp
  801a0c:	50                   	push   %eax
  801a0d:	e8 08 e9 ff ff       	call   80031a <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801a12:	83 c4 10             	add    $0x10,%esp
  801a15:	85 f6                	test   %esi,%esi
  801a17:	74 14                	je     801a2d <ipc_recv+0x3c>
  801a19:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	78 09                	js     801a2b <ipc_recv+0x3a>
  801a22:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a28:	8b 52 74             	mov    0x74(%edx),%edx
  801a2b:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801a2d:	85 db                	test   %ebx,%ebx
  801a2f:	74 14                	je     801a45 <ipc_recv+0x54>
  801a31:	ba 00 00 00 00       	mov    $0x0,%edx
  801a36:	85 c0                	test   %eax,%eax
  801a38:	78 09                	js     801a43 <ipc_recv+0x52>
  801a3a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a40:	8b 52 78             	mov    0x78(%edx),%edx
  801a43:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801a45:	85 c0                	test   %eax,%eax
  801a47:	78 08                	js     801a51 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801a49:	a1 00 40 80 00       	mov    0x804000,%eax
  801a4e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a54:	5b                   	pop    %ebx
  801a55:	5e                   	pop    %esi
  801a56:	5d                   	pop    %ebp
  801a57:	c3                   	ret    

00801a58 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a58:	55                   	push   %ebp
  801a59:	89 e5                	mov    %esp,%ebp
  801a5b:	57                   	push   %edi
  801a5c:	56                   	push   %esi
  801a5d:	53                   	push   %ebx
  801a5e:	83 ec 0c             	sub    $0xc,%esp
  801a61:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a64:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801a6a:	85 db                	test   %ebx,%ebx
  801a6c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a71:	0f 44 d8             	cmove  %eax,%ebx
  801a74:	eb 05                	jmp    801a7b <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a76:	e8 d0 e6 ff ff       	call   80014b <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801a7b:	ff 75 14             	push   0x14(%ebp)
  801a7e:	53                   	push   %ebx
  801a7f:	56                   	push   %esi
  801a80:	57                   	push   %edi
  801a81:	e8 71 e8 ff ff       	call   8002f7 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a86:	83 c4 10             	add    $0x10,%esp
  801a89:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a8c:	74 e8                	je     801a76 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	78 08                	js     801a9a <ipc_send+0x42>
	}while (r<0);

}
  801a92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a95:	5b                   	pop    %ebx
  801a96:	5e                   	pop    %esi
  801a97:	5f                   	pop    %edi
  801a98:	5d                   	pop    %ebp
  801a99:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801a9a:	50                   	push   %eax
  801a9b:	68 df 21 80 00       	push   $0x8021df
  801aa0:	6a 3d                	push   $0x3d
  801aa2:	68 f3 21 80 00       	push   $0x8021f3
  801aa7:	e8 50 f5 ff ff       	call   800ffc <_panic>

00801aac <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aac:	55                   	push   %ebp
  801aad:	89 e5                	mov    %esp,%ebp
  801aaf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ab2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ab7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801aba:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ac0:	8b 52 50             	mov    0x50(%edx),%edx
  801ac3:	39 ca                	cmp    %ecx,%edx
  801ac5:	74 11                	je     801ad8 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801ac7:	83 c0 01             	add    $0x1,%eax
  801aca:	3d 00 04 00 00       	cmp    $0x400,%eax
  801acf:	75 e6                	jne    801ab7 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801ad1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad6:	eb 0b                	jmp    801ae3 <ipc_find_env+0x37>
			return envs[i].env_id;
  801ad8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801adb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ae0:	8b 40 48             	mov    0x48(%eax),%eax
}
  801ae3:	5d                   	pop    %ebp
  801ae4:	c3                   	ret    

00801ae5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801aeb:	89 c2                	mov    %eax,%edx
  801aed:	c1 ea 16             	shr    $0x16,%edx
  801af0:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801af7:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801afc:	f6 c1 01             	test   $0x1,%cl
  801aff:	74 1c                	je     801b1d <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801b01:	c1 e8 0c             	shr    $0xc,%eax
  801b04:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b0b:	a8 01                	test   $0x1,%al
  801b0d:	74 0e                	je     801b1d <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b0f:	c1 e8 0c             	shr    $0xc,%eax
  801b12:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b19:	ef 
  801b1a:	0f b7 d2             	movzwl %dx,%edx
}
  801b1d:	89 d0                	mov    %edx,%eax
  801b1f:	5d                   	pop    %ebp
  801b20:	c3                   	ret    
  801b21:	66 90                	xchg   %ax,%ax
  801b23:	66 90                	xchg   %ax,%ax
  801b25:	66 90                	xchg   %ax,%ax
  801b27:	66 90                	xchg   %ax,%ax
  801b29:	66 90                	xchg   %ax,%ax
  801b2b:	66 90                	xchg   %ax,%ax
  801b2d:	66 90                	xchg   %ax,%ax
  801b2f:	90                   	nop

00801b30 <__udivdi3>:
  801b30:	f3 0f 1e fb          	endbr32 
  801b34:	55                   	push   %ebp
  801b35:	57                   	push   %edi
  801b36:	56                   	push   %esi
  801b37:	53                   	push   %ebx
  801b38:	83 ec 1c             	sub    $0x1c,%esp
  801b3b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801b3f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b43:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b47:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b4b:	85 c0                	test   %eax,%eax
  801b4d:	75 19                	jne    801b68 <__udivdi3+0x38>
  801b4f:	39 f3                	cmp    %esi,%ebx
  801b51:	76 4d                	jbe    801ba0 <__udivdi3+0x70>
  801b53:	31 ff                	xor    %edi,%edi
  801b55:	89 e8                	mov    %ebp,%eax
  801b57:	89 f2                	mov    %esi,%edx
  801b59:	f7 f3                	div    %ebx
  801b5b:	89 fa                	mov    %edi,%edx
  801b5d:	83 c4 1c             	add    $0x1c,%esp
  801b60:	5b                   	pop    %ebx
  801b61:	5e                   	pop    %esi
  801b62:	5f                   	pop    %edi
  801b63:	5d                   	pop    %ebp
  801b64:	c3                   	ret    
  801b65:	8d 76 00             	lea    0x0(%esi),%esi
  801b68:	39 f0                	cmp    %esi,%eax
  801b6a:	76 14                	jbe    801b80 <__udivdi3+0x50>
  801b6c:	31 ff                	xor    %edi,%edi
  801b6e:	31 c0                	xor    %eax,%eax
  801b70:	89 fa                	mov    %edi,%edx
  801b72:	83 c4 1c             	add    $0x1c,%esp
  801b75:	5b                   	pop    %ebx
  801b76:	5e                   	pop    %esi
  801b77:	5f                   	pop    %edi
  801b78:	5d                   	pop    %ebp
  801b79:	c3                   	ret    
  801b7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801b80:	0f bd f8             	bsr    %eax,%edi
  801b83:	83 f7 1f             	xor    $0x1f,%edi
  801b86:	75 48                	jne    801bd0 <__udivdi3+0xa0>
  801b88:	39 f0                	cmp    %esi,%eax
  801b8a:	72 06                	jb     801b92 <__udivdi3+0x62>
  801b8c:	31 c0                	xor    %eax,%eax
  801b8e:	39 eb                	cmp    %ebp,%ebx
  801b90:	77 de                	ja     801b70 <__udivdi3+0x40>
  801b92:	b8 01 00 00 00       	mov    $0x1,%eax
  801b97:	eb d7                	jmp    801b70 <__udivdi3+0x40>
  801b99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ba0:	89 d9                	mov    %ebx,%ecx
  801ba2:	85 db                	test   %ebx,%ebx
  801ba4:	75 0b                	jne    801bb1 <__udivdi3+0x81>
  801ba6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bab:	31 d2                	xor    %edx,%edx
  801bad:	f7 f3                	div    %ebx
  801baf:	89 c1                	mov    %eax,%ecx
  801bb1:	31 d2                	xor    %edx,%edx
  801bb3:	89 f0                	mov    %esi,%eax
  801bb5:	f7 f1                	div    %ecx
  801bb7:	89 c6                	mov    %eax,%esi
  801bb9:	89 e8                	mov    %ebp,%eax
  801bbb:	89 f7                	mov    %esi,%edi
  801bbd:	f7 f1                	div    %ecx
  801bbf:	89 fa                	mov    %edi,%edx
  801bc1:	83 c4 1c             	add    $0x1c,%esp
  801bc4:	5b                   	pop    %ebx
  801bc5:	5e                   	pop    %esi
  801bc6:	5f                   	pop    %edi
  801bc7:	5d                   	pop    %ebp
  801bc8:	c3                   	ret    
  801bc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bd0:	89 f9                	mov    %edi,%ecx
  801bd2:	ba 20 00 00 00       	mov    $0x20,%edx
  801bd7:	29 fa                	sub    %edi,%edx
  801bd9:	d3 e0                	shl    %cl,%eax
  801bdb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bdf:	89 d1                	mov    %edx,%ecx
  801be1:	89 d8                	mov    %ebx,%eax
  801be3:	d3 e8                	shr    %cl,%eax
  801be5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801be9:	09 c1                	or     %eax,%ecx
  801beb:	89 f0                	mov    %esi,%eax
  801bed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801bf1:	89 f9                	mov    %edi,%ecx
  801bf3:	d3 e3                	shl    %cl,%ebx
  801bf5:	89 d1                	mov    %edx,%ecx
  801bf7:	d3 e8                	shr    %cl,%eax
  801bf9:	89 f9                	mov    %edi,%ecx
  801bfb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801bff:	89 eb                	mov    %ebp,%ebx
  801c01:	d3 e6                	shl    %cl,%esi
  801c03:	89 d1                	mov    %edx,%ecx
  801c05:	d3 eb                	shr    %cl,%ebx
  801c07:	09 f3                	or     %esi,%ebx
  801c09:	89 c6                	mov    %eax,%esi
  801c0b:	89 f2                	mov    %esi,%edx
  801c0d:	89 d8                	mov    %ebx,%eax
  801c0f:	f7 74 24 08          	divl   0x8(%esp)
  801c13:	89 d6                	mov    %edx,%esi
  801c15:	89 c3                	mov    %eax,%ebx
  801c17:	f7 64 24 0c          	mull   0xc(%esp)
  801c1b:	39 d6                	cmp    %edx,%esi
  801c1d:	72 19                	jb     801c38 <__udivdi3+0x108>
  801c1f:	89 f9                	mov    %edi,%ecx
  801c21:	d3 e5                	shl    %cl,%ebp
  801c23:	39 c5                	cmp    %eax,%ebp
  801c25:	73 04                	jae    801c2b <__udivdi3+0xfb>
  801c27:	39 d6                	cmp    %edx,%esi
  801c29:	74 0d                	je     801c38 <__udivdi3+0x108>
  801c2b:	89 d8                	mov    %ebx,%eax
  801c2d:	31 ff                	xor    %edi,%edi
  801c2f:	e9 3c ff ff ff       	jmp    801b70 <__udivdi3+0x40>
  801c34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c38:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c3b:	31 ff                	xor    %edi,%edi
  801c3d:	e9 2e ff ff ff       	jmp    801b70 <__udivdi3+0x40>
  801c42:	66 90                	xchg   %ax,%ax
  801c44:	66 90                	xchg   %ax,%ax
  801c46:	66 90                	xchg   %ax,%ax
  801c48:	66 90                	xchg   %ax,%ax
  801c4a:	66 90                	xchg   %ax,%ax
  801c4c:	66 90                	xchg   %ax,%ax
  801c4e:	66 90                	xchg   %ax,%ax

00801c50 <__umoddi3>:
  801c50:	f3 0f 1e fb          	endbr32 
  801c54:	55                   	push   %ebp
  801c55:	57                   	push   %edi
  801c56:	56                   	push   %esi
  801c57:	53                   	push   %ebx
  801c58:	83 ec 1c             	sub    $0x1c,%esp
  801c5b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801c5f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801c63:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801c67:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801c6b:	89 f0                	mov    %esi,%eax
  801c6d:	89 da                	mov    %ebx,%edx
  801c6f:	85 ff                	test   %edi,%edi
  801c71:	75 15                	jne    801c88 <__umoddi3+0x38>
  801c73:	39 dd                	cmp    %ebx,%ebp
  801c75:	76 39                	jbe    801cb0 <__umoddi3+0x60>
  801c77:	f7 f5                	div    %ebp
  801c79:	89 d0                	mov    %edx,%eax
  801c7b:	31 d2                	xor    %edx,%edx
  801c7d:	83 c4 1c             	add    $0x1c,%esp
  801c80:	5b                   	pop    %ebx
  801c81:	5e                   	pop    %esi
  801c82:	5f                   	pop    %edi
  801c83:	5d                   	pop    %ebp
  801c84:	c3                   	ret    
  801c85:	8d 76 00             	lea    0x0(%esi),%esi
  801c88:	39 df                	cmp    %ebx,%edi
  801c8a:	77 f1                	ja     801c7d <__umoddi3+0x2d>
  801c8c:	0f bd cf             	bsr    %edi,%ecx
  801c8f:	83 f1 1f             	xor    $0x1f,%ecx
  801c92:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c96:	75 40                	jne    801cd8 <__umoddi3+0x88>
  801c98:	39 df                	cmp    %ebx,%edi
  801c9a:	72 04                	jb     801ca0 <__umoddi3+0x50>
  801c9c:	39 f5                	cmp    %esi,%ebp
  801c9e:	77 dd                	ja     801c7d <__umoddi3+0x2d>
  801ca0:	89 da                	mov    %ebx,%edx
  801ca2:	89 f0                	mov    %esi,%eax
  801ca4:	29 e8                	sub    %ebp,%eax
  801ca6:	19 fa                	sbb    %edi,%edx
  801ca8:	eb d3                	jmp    801c7d <__umoddi3+0x2d>
  801caa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cb0:	89 e9                	mov    %ebp,%ecx
  801cb2:	85 ed                	test   %ebp,%ebp
  801cb4:	75 0b                	jne    801cc1 <__umoddi3+0x71>
  801cb6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cbb:	31 d2                	xor    %edx,%edx
  801cbd:	f7 f5                	div    %ebp
  801cbf:	89 c1                	mov    %eax,%ecx
  801cc1:	89 d8                	mov    %ebx,%eax
  801cc3:	31 d2                	xor    %edx,%edx
  801cc5:	f7 f1                	div    %ecx
  801cc7:	89 f0                	mov    %esi,%eax
  801cc9:	f7 f1                	div    %ecx
  801ccb:	89 d0                	mov    %edx,%eax
  801ccd:	31 d2                	xor    %edx,%edx
  801ccf:	eb ac                	jmp    801c7d <__umoddi3+0x2d>
  801cd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cd8:	8b 44 24 04          	mov    0x4(%esp),%eax
  801cdc:	ba 20 00 00 00       	mov    $0x20,%edx
  801ce1:	29 c2                	sub    %eax,%edx
  801ce3:	89 c1                	mov    %eax,%ecx
  801ce5:	89 e8                	mov    %ebp,%eax
  801ce7:	d3 e7                	shl    %cl,%edi
  801ce9:	89 d1                	mov    %edx,%ecx
  801ceb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801cef:	d3 e8                	shr    %cl,%eax
  801cf1:	89 c1                	mov    %eax,%ecx
  801cf3:	8b 44 24 04          	mov    0x4(%esp),%eax
  801cf7:	09 f9                	or     %edi,%ecx
  801cf9:	89 df                	mov    %ebx,%edi
  801cfb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cff:	89 c1                	mov    %eax,%ecx
  801d01:	d3 e5                	shl    %cl,%ebp
  801d03:	89 d1                	mov    %edx,%ecx
  801d05:	d3 ef                	shr    %cl,%edi
  801d07:	89 c1                	mov    %eax,%ecx
  801d09:	89 f0                	mov    %esi,%eax
  801d0b:	d3 e3                	shl    %cl,%ebx
  801d0d:	89 d1                	mov    %edx,%ecx
  801d0f:	89 fa                	mov    %edi,%edx
  801d11:	d3 e8                	shr    %cl,%eax
  801d13:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d18:	09 d8                	or     %ebx,%eax
  801d1a:	f7 74 24 08          	divl   0x8(%esp)
  801d1e:	89 d3                	mov    %edx,%ebx
  801d20:	d3 e6                	shl    %cl,%esi
  801d22:	f7 e5                	mul    %ebp
  801d24:	89 c7                	mov    %eax,%edi
  801d26:	89 d1                	mov    %edx,%ecx
  801d28:	39 d3                	cmp    %edx,%ebx
  801d2a:	72 06                	jb     801d32 <__umoddi3+0xe2>
  801d2c:	75 0e                	jne    801d3c <__umoddi3+0xec>
  801d2e:	39 c6                	cmp    %eax,%esi
  801d30:	73 0a                	jae    801d3c <__umoddi3+0xec>
  801d32:	29 e8                	sub    %ebp,%eax
  801d34:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801d38:	89 d1                	mov    %edx,%ecx
  801d3a:	89 c7                	mov    %eax,%edi
  801d3c:	89 f5                	mov    %esi,%ebp
  801d3e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801d42:	29 fd                	sub    %edi,%ebp
  801d44:	19 cb                	sbb    %ecx,%ebx
  801d46:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d4b:	89 d8                	mov    %ebx,%eax
  801d4d:	d3 e0                	shl    %cl,%eax
  801d4f:	89 f1                	mov    %esi,%ecx
  801d51:	d3 ed                	shr    %cl,%ebp
  801d53:	d3 eb                	shr    %cl,%ebx
  801d55:	09 e8                	or     %ebp,%eax
  801d57:	89 da                	mov    %ebx,%edx
  801d59:	83 c4 1c             	add    $0x1c,%esp
  801d5c:	5b                   	pop    %ebx
  801d5d:	5e                   	pop    %esi
  801d5e:	5f                   	pop    %edi
  801d5f:	5d                   	pop    %ebp
  801d60:	c3                   	ret    
