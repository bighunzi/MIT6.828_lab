
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
	call libmain//调用lib/libmain.c中的libmain()
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
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800040:	e8 c6 00 00 00       	call   80010b <sys_getenvid>
  800045:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80004d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800052:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800057:	85 db                	test   %ebx,%ebx
  800059:	7e 07                	jle    800062 <libmain+0x2d>
		binaryname = argv[0];
  80005b:	8b 06                	mov    (%esi),%eax
  80005d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800062:	83 ec 08             	sub    $0x8,%esp
  800065:	56                   	push   %esi
  800066:	53                   	push   %ebx
  800067:	e8 c7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80006c:	e8 0a 00 00 00       	call   80007b <exit>
}
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800077:	5b                   	pop    %ebx
  800078:	5e                   	pop    %esi
  800079:	5d                   	pop    %ebp
  80007a:	c3                   	ret    

0080007b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800081:	6a 00                	push   $0x0
  800083:	e8 42 00 00 00       	call   8000ca <sys_env_destroy>
}
  800088:	83 c4 10             	add    $0x10,%esp
  80008b:	c9                   	leave  
  80008c:	c3                   	ret    

0080008d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	57                   	push   %edi
  800091:	56                   	push   %esi
  800092:	53                   	push   %ebx
	asm volatile("int %1\n"
  800093:	b8 00 00 00 00       	mov    $0x0,%eax
  800098:	8b 55 08             	mov    0x8(%ebp),%edx
  80009b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80009e:	89 c3                	mov    %eax,%ebx
  8000a0:	89 c7                	mov    %eax,%edi
  8000a2:	89 c6                	mov    %eax,%esi
  8000a4:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000a6:	5b                   	pop    %ebx
  8000a7:	5e                   	pop    %esi
  8000a8:	5f                   	pop    %edi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	57                   	push   %edi
  8000af:	56                   	push   %esi
  8000b0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000bb:	89 d1                	mov    %edx,%ecx
  8000bd:	89 d3                	mov    %edx,%ebx
  8000bf:	89 d7                	mov    %edx,%edi
  8000c1:	89 d6                	mov    %edx,%esi
  8000c3:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
  8000d0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000db:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e0:	89 cb                	mov    %ecx,%ebx
  8000e2:	89 cf                	mov    %ecx,%edi
  8000e4:	89 ce                	mov    %ecx,%esi
  8000e6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000e8:	85 c0                	test   %eax,%eax
  8000ea:	7f 08                	jg     8000f4 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ef:	5b                   	pop    %ebx
  8000f0:	5e                   	pop    %esi
  8000f1:	5f                   	pop    %edi
  8000f2:	5d                   	pop    %ebp
  8000f3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f4:	83 ec 0c             	sub    $0xc,%esp
  8000f7:	50                   	push   %eax
  8000f8:	6a 03                	push   $0x3
  8000fa:	68 4a 0f 80 00       	push   $0x800f4a
  8000ff:	6a 2a                	push   $0x2a
  800101:	68 67 0f 80 00       	push   $0x800f67
  800106:	e8 ed 01 00 00       	call   8002f8 <_panic>

0080010b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	57                   	push   %edi
  80010f:	56                   	push   %esi
  800110:	53                   	push   %ebx
	asm volatile("int %1\n"
  800111:	ba 00 00 00 00       	mov    $0x0,%edx
  800116:	b8 02 00 00 00       	mov    $0x2,%eax
  80011b:	89 d1                	mov    %edx,%ecx
  80011d:	89 d3                	mov    %edx,%ebx
  80011f:	89 d7                	mov    %edx,%edi
  800121:	89 d6                	mov    %edx,%esi
  800123:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800125:	5b                   	pop    %ebx
  800126:	5e                   	pop    %esi
  800127:	5f                   	pop    %edi
  800128:	5d                   	pop    %ebp
  800129:	c3                   	ret    

0080012a <sys_yield>:

void
sys_yield(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 0a 00 00 00       	mov    $0xa,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
  80014f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800152:	be 00 00 00 00       	mov    $0x0,%esi
  800157:	8b 55 08             	mov    0x8(%ebp),%edx
  80015a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80015d:	b8 04 00 00 00       	mov    $0x4,%eax
  800162:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800165:	89 f7                	mov    %esi,%edi
  800167:	cd 30                	int    $0x30
	if(check && ret > 0)
  800169:	85 c0                	test   %eax,%eax
  80016b:	7f 08                	jg     800175 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80016d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800170:	5b                   	pop    %ebx
  800171:	5e                   	pop    %esi
  800172:	5f                   	pop    %edi
  800173:	5d                   	pop    %ebp
  800174:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800175:	83 ec 0c             	sub    $0xc,%esp
  800178:	50                   	push   %eax
  800179:	6a 04                	push   $0x4
  80017b:	68 4a 0f 80 00       	push   $0x800f4a
  800180:	6a 2a                	push   $0x2a
  800182:	68 67 0f 80 00       	push   $0x800f67
  800187:	e8 6c 01 00 00       	call   8002f8 <_panic>

0080018c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	57                   	push   %edi
  800190:	56                   	push   %esi
  800191:	53                   	push   %ebx
  800192:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800195:	8b 55 08             	mov    0x8(%ebp),%edx
  800198:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80019b:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001a6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001a9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ab:	85 c0                	test   %eax,%eax
  8001ad:	7f 08                	jg     8001b7 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001af:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b2:	5b                   	pop    %ebx
  8001b3:	5e                   	pop    %esi
  8001b4:	5f                   	pop    %edi
  8001b5:	5d                   	pop    %ebp
  8001b6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b7:	83 ec 0c             	sub    $0xc,%esp
  8001ba:	50                   	push   %eax
  8001bb:	6a 05                	push   $0x5
  8001bd:	68 4a 0f 80 00       	push   $0x800f4a
  8001c2:	6a 2a                	push   $0x2a
  8001c4:	68 67 0f 80 00       	push   $0x800f67
  8001c9:	e8 2a 01 00 00       	call   8002f8 <_panic>

008001ce <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ce:	55                   	push   %ebp
  8001cf:	89 e5                	mov    %esp,%ebp
  8001d1:	57                   	push   %edi
  8001d2:	56                   	push   %esi
  8001d3:	53                   	push   %ebx
  8001d4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001dc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e2:	b8 06 00 00 00       	mov    $0x6,%eax
  8001e7:	89 df                	mov    %ebx,%edi
  8001e9:	89 de                	mov    %ebx,%esi
  8001eb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ed:	85 c0                	test   %eax,%eax
  8001ef:	7f 08                	jg     8001f9 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f4:	5b                   	pop    %ebx
  8001f5:	5e                   	pop    %esi
  8001f6:	5f                   	pop    %edi
  8001f7:	5d                   	pop    %ebp
  8001f8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f9:	83 ec 0c             	sub    $0xc,%esp
  8001fc:	50                   	push   %eax
  8001fd:	6a 06                	push   $0x6
  8001ff:	68 4a 0f 80 00       	push   $0x800f4a
  800204:	6a 2a                	push   $0x2a
  800206:	68 67 0f 80 00       	push   $0x800f67
  80020b:	e8 e8 00 00 00       	call   8002f8 <_panic>

00800210 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	57                   	push   %edi
  800214:	56                   	push   %esi
  800215:	53                   	push   %ebx
  800216:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800219:	bb 00 00 00 00       	mov    $0x0,%ebx
  80021e:	8b 55 08             	mov    0x8(%ebp),%edx
  800221:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800224:	b8 08 00 00 00       	mov    $0x8,%eax
  800229:	89 df                	mov    %ebx,%edi
  80022b:	89 de                	mov    %ebx,%esi
  80022d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80022f:	85 c0                	test   %eax,%eax
  800231:	7f 08                	jg     80023b <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800233:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800236:	5b                   	pop    %ebx
  800237:	5e                   	pop    %esi
  800238:	5f                   	pop    %edi
  800239:	5d                   	pop    %ebp
  80023a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80023b:	83 ec 0c             	sub    $0xc,%esp
  80023e:	50                   	push   %eax
  80023f:	6a 08                	push   $0x8
  800241:	68 4a 0f 80 00       	push   $0x800f4a
  800246:	6a 2a                	push   $0x2a
  800248:	68 67 0f 80 00       	push   $0x800f67
  80024d:	e8 a6 00 00 00       	call   8002f8 <_panic>

00800252 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	57                   	push   %edi
  800256:	56                   	push   %esi
  800257:	53                   	push   %ebx
  800258:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80025b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800260:	8b 55 08             	mov    0x8(%ebp),%edx
  800263:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800266:	b8 09 00 00 00       	mov    $0x9,%eax
  80026b:	89 df                	mov    %ebx,%edi
  80026d:	89 de                	mov    %ebx,%esi
  80026f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800271:	85 c0                	test   %eax,%eax
  800273:	7f 08                	jg     80027d <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800275:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800278:	5b                   	pop    %ebx
  800279:	5e                   	pop    %esi
  80027a:	5f                   	pop    %edi
  80027b:	5d                   	pop    %ebp
  80027c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80027d:	83 ec 0c             	sub    $0xc,%esp
  800280:	50                   	push   %eax
  800281:	6a 09                	push   $0x9
  800283:	68 4a 0f 80 00       	push   $0x800f4a
  800288:	6a 2a                	push   $0x2a
  80028a:	68 67 0f 80 00       	push   $0x800f67
  80028f:	e8 64 00 00 00       	call   8002f8 <_panic>

00800294 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	57                   	push   %edi
  800298:	56                   	push   %esi
  800299:	53                   	push   %ebx
	asm volatile("int %1\n"
  80029a:	8b 55 08             	mov    0x8(%ebp),%edx
  80029d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002a5:	be 00 00 00 00       	mov    $0x0,%esi
  8002aa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ad:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b0:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002b2:	5b                   	pop    %ebx
  8002b3:	5e                   	pop    %esi
  8002b4:	5f                   	pop    %edi
  8002b5:	5d                   	pop    %ebp
  8002b6:	c3                   	ret    

008002b7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	57                   	push   %edi
  8002bb:	56                   	push   %esi
  8002bc:	53                   	push   %ebx
  8002bd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c8:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002cd:	89 cb                	mov    %ecx,%ebx
  8002cf:	89 cf                	mov    %ecx,%edi
  8002d1:	89 ce                	mov    %ecx,%esi
  8002d3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d5:	85 c0                	test   %eax,%eax
  8002d7:	7f 08                	jg     8002e1 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002dc:	5b                   	pop    %ebx
  8002dd:	5e                   	pop    %esi
  8002de:	5f                   	pop    %edi
  8002df:	5d                   	pop    %ebp
  8002e0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e1:	83 ec 0c             	sub    $0xc,%esp
  8002e4:	50                   	push   %eax
  8002e5:	6a 0c                	push   $0xc
  8002e7:	68 4a 0f 80 00       	push   $0x800f4a
  8002ec:	6a 2a                	push   $0x2a
  8002ee:	68 67 0f 80 00       	push   $0x800f67
  8002f3:	e8 00 00 00 00       	call   8002f8 <_panic>

008002f8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002fd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800300:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800306:	e8 00 fe ff ff       	call   80010b <sys_getenvid>
  80030b:	83 ec 0c             	sub    $0xc,%esp
  80030e:	ff 75 0c             	push   0xc(%ebp)
  800311:	ff 75 08             	push   0x8(%ebp)
  800314:	56                   	push   %esi
  800315:	50                   	push   %eax
  800316:	68 78 0f 80 00       	push   $0x800f78
  80031b:	e8 b3 00 00 00       	call   8003d3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800320:	83 c4 18             	add    $0x18,%esp
  800323:	53                   	push   %ebx
  800324:	ff 75 10             	push   0x10(%ebp)
  800327:	e8 56 00 00 00       	call   800382 <vcprintf>
	cprintf("\n");
  80032c:	c7 04 24 9b 0f 80 00 	movl   $0x800f9b,(%esp)
  800333:	e8 9b 00 00 00       	call   8003d3 <cprintf>
  800338:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80033b:	cc                   	int3   
  80033c:	eb fd                	jmp    80033b <_panic+0x43>

0080033e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	53                   	push   %ebx
  800342:	83 ec 04             	sub    $0x4,%esp
  800345:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800348:	8b 13                	mov    (%ebx),%edx
  80034a:	8d 42 01             	lea    0x1(%edx),%eax
  80034d:	89 03                	mov    %eax,(%ebx)
  80034f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800352:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800356:	3d ff 00 00 00       	cmp    $0xff,%eax
  80035b:	74 09                	je     800366 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80035d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800361:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800364:	c9                   	leave  
  800365:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800366:	83 ec 08             	sub    $0x8,%esp
  800369:	68 ff 00 00 00       	push   $0xff
  80036e:	8d 43 08             	lea    0x8(%ebx),%eax
  800371:	50                   	push   %eax
  800372:	e8 16 fd ff ff       	call   80008d <sys_cputs>
		b->idx = 0;
  800377:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80037d:	83 c4 10             	add    $0x10,%esp
  800380:	eb db                	jmp    80035d <putch+0x1f>

00800382 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80038b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800392:	00 00 00 
	b.cnt = 0;
  800395:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80039c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80039f:	ff 75 0c             	push   0xc(%ebp)
  8003a2:	ff 75 08             	push   0x8(%ebp)
  8003a5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003ab:	50                   	push   %eax
  8003ac:	68 3e 03 80 00       	push   $0x80033e
  8003b1:	e8 14 01 00 00       	call   8004ca <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003b6:	83 c4 08             	add    $0x8,%esp
  8003b9:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8003bf:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003c5:	50                   	push   %eax
  8003c6:	e8 c2 fc ff ff       	call   80008d <sys_cputs>

	return b.cnt;
}
  8003cb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003d1:	c9                   	leave  
  8003d2:	c3                   	ret    

008003d3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
  8003d6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003d9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003dc:	50                   	push   %eax
  8003dd:	ff 75 08             	push   0x8(%ebp)
  8003e0:	e8 9d ff ff ff       	call   800382 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003e5:	c9                   	leave  
  8003e6:	c3                   	ret    

008003e7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003e7:	55                   	push   %ebp
  8003e8:	89 e5                	mov    %esp,%ebp
  8003ea:	57                   	push   %edi
  8003eb:	56                   	push   %esi
  8003ec:	53                   	push   %ebx
  8003ed:	83 ec 1c             	sub    $0x1c,%esp
  8003f0:	89 c7                	mov    %eax,%edi
  8003f2:	89 d6                	mov    %edx,%esi
  8003f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fa:	89 d1                	mov    %edx,%ecx
  8003fc:	89 c2                	mov    %eax,%edx
  8003fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800401:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800404:	8b 45 10             	mov    0x10(%ebp),%eax
  800407:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80040a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80040d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800414:	39 c2                	cmp    %eax,%edx
  800416:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800419:	72 3e                	jb     800459 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80041b:	83 ec 0c             	sub    $0xc,%esp
  80041e:	ff 75 18             	push   0x18(%ebp)
  800421:	83 eb 01             	sub    $0x1,%ebx
  800424:	53                   	push   %ebx
  800425:	50                   	push   %eax
  800426:	83 ec 08             	sub    $0x8,%esp
  800429:	ff 75 e4             	push   -0x1c(%ebp)
  80042c:	ff 75 e0             	push   -0x20(%ebp)
  80042f:	ff 75 dc             	push   -0x24(%ebp)
  800432:	ff 75 d8             	push   -0x28(%ebp)
  800435:	e8 b6 08 00 00       	call   800cf0 <__udivdi3>
  80043a:	83 c4 18             	add    $0x18,%esp
  80043d:	52                   	push   %edx
  80043e:	50                   	push   %eax
  80043f:	89 f2                	mov    %esi,%edx
  800441:	89 f8                	mov    %edi,%eax
  800443:	e8 9f ff ff ff       	call   8003e7 <printnum>
  800448:	83 c4 20             	add    $0x20,%esp
  80044b:	eb 13                	jmp    800460 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	56                   	push   %esi
  800451:	ff 75 18             	push   0x18(%ebp)
  800454:	ff d7                	call   *%edi
  800456:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800459:	83 eb 01             	sub    $0x1,%ebx
  80045c:	85 db                	test   %ebx,%ebx
  80045e:	7f ed                	jg     80044d <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800460:	83 ec 08             	sub    $0x8,%esp
  800463:	56                   	push   %esi
  800464:	83 ec 04             	sub    $0x4,%esp
  800467:	ff 75 e4             	push   -0x1c(%ebp)
  80046a:	ff 75 e0             	push   -0x20(%ebp)
  80046d:	ff 75 dc             	push   -0x24(%ebp)
  800470:	ff 75 d8             	push   -0x28(%ebp)
  800473:	e8 98 09 00 00       	call   800e10 <__umoddi3>
  800478:	83 c4 14             	add    $0x14,%esp
  80047b:	0f be 80 9d 0f 80 00 	movsbl 0x800f9d(%eax),%eax
  800482:	50                   	push   %eax
  800483:	ff d7                	call   *%edi
}
  800485:	83 c4 10             	add    $0x10,%esp
  800488:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80048b:	5b                   	pop    %ebx
  80048c:	5e                   	pop    %esi
  80048d:	5f                   	pop    %edi
  80048e:	5d                   	pop    %ebp
  80048f:	c3                   	ret    

00800490 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800490:	55                   	push   %ebp
  800491:	89 e5                	mov    %esp,%ebp
  800493:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800496:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80049a:	8b 10                	mov    (%eax),%edx
  80049c:	3b 50 04             	cmp    0x4(%eax),%edx
  80049f:	73 0a                	jae    8004ab <sprintputch+0x1b>
		*b->buf++ = ch;
  8004a1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004a4:	89 08                	mov    %ecx,(%eax)
  8004a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004a9:	88 02                	mov    %al,(%edx)
}
  8004ab:	5d                   	pop    %ebp
  8004ac:	c3                   	ret    

008004ad <printfmt>:
{
  8004ad:	55                   	push   %ebp
  8004ae:	89 e5                	mov    %esp,%ebp
  8004b0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004b3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004b6:	50                   	push   %eax
  8004b7:	ff 75 10             	push   0x10(%ebp)
  8004ba:	ff 75 0c             	push   0xc(%ebp)
  8004bd:	ff 75 08             	push   0x8(%ebp)
  8004c0:	e8 05 00 00 00       	call   8004ca <vprintfmt>
}
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	c9                   	leave  
  8004c9:	c3                   	ret    

008004ca <vprintfmt>:
{
  8004ca:	55                   	push   %ebp
  8004cb:	89 e5                	mov    %esp,%ebp
  8004cd:	57                   	push   %edi
  8004ce:	56                   	push   %esi
  8004cf:	53                   	push   %ebx
  8004d0:	83 ec 3c             	sub    $0x3c,%esp
  8004d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004dc:	eb 0a                	jmp    8004e8 <vprintfmt+0x1e>
			putch(ch, putdat);
  8004de:	83 ec 08             	sub    $0x8,%esp
  8004e1:	53                   	push   %ebx
  8004e2:	50                   	push   %eax
  8004e3:	ff d6                	call   *%esi
  8004e5:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004e8:	83 c7 01             	add    $0x1,%edi
  8004eb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004ef:	83 f8 25             	cmp    $0x25,%eax
  8004f2:	74 0c                	je     800500 <vprintfmt+0x36>
			if (ch == '\0')
  8004f4:	85 c0                	test   %eax,%eax
  8004f6:	75 e6                	jne    8004de <vprintfmt+0x14>
}
  8004f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004fb:	5b                   	pop    %ebx
  8004fc:	5e                   	pop    %esi
  8004fd:	5f                   	pop    %edi
  8004fe:	5d                   	pop    %ebp
  8004ff:	c3                   	ret    
		padc = ' ';
  800500:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800504:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80050b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800512:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800519:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80051e:	8d 47 01             	lea    0x1(%edi),%eax
  800521:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800524:	0f b6 17             	movzbl (%edi),%edx
  800527:	8d 42 dd             	lea    -0x23(%edx),%eax
  80052a:	3c 55                	cmp    $0x55,%al
  80052c:	0f 87 bb 03 00 00    	ja     8008ed <vprintfmt+0x423>
  800532:	0f b6 c0             	movzbl %al,%eax
  800535:	ff 24 85 60 10 80 00 	jmp    *0x801060(,%eax,4)
  80053c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80053f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800543:	eb d9                	jmp    80051e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800545:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800548:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80054c:	eb d0                	jmp    80051e <vprintfmt+0x54>
  80054e:	0f b6 d2             	movzbl %dl,%edx
  800551:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800554:	b8 00 00 00 00       	mov    $0x0,%eax
  800559:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80055c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80055f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800563:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800566:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800569:	83 f9 09             	cmp    $0x9,%ecx
  80056c:	77 55                	ja     8005c3 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80056e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800571:	eb e9                	jmp    80055c <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800573:	8b 45 14             	mov    0x14(%ebp),%eax
  800576:	8b 00                	mov    (%eax),%eax
  800578:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80057b:	8b 45 14             	mov    0x14(%ebp),%eax
  80057e:	8d 40 04             	lea    0x4(%eax),%eax
  800581:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800584:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800587:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058b:	79 91                	jns    80051e <vprintfmt+0x54>
				width = precision, precision = -1;
  80058d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800590:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800593:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80059a:	eb 82                	jmp    80051e <vprintfmt+0x54>
  80059c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80059f:	85 d2                	test   %edx,%edx
  8005a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a6:	0f 49 c2             	cmovns %edx,%eax
  8005a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005af:	e9 6a ff ff ff       	jmp    80051e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005b7:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005be:	e9 5b ff ff ff       	jmp    80051e <vprintfmt+0x54>
  8005c3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c9:	eb bc                	jmp    800587 <vprintfmt+0xbd>
			lflag++;
  8005cb:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005d1:	e9 48 ff ff ff       	jmp    80051e <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8d 78 04             	lea    0x4(%eax),%edi
  8005dc:	83 ec 08             	sub    $0x8,%esp
  8005df:	53                   	push   %ebx
  8005e0:	ff 30                	push   (%eax)
  8005e2:	ff d6                	call   *%esi
			break;
  8005e4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005e7:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005ea:	e9 9d 02 00 00       	jmp    80088c <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8005ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f2:	8d 78 04             	lea    0x4(%eax),%edi
  8005f5:	8b 10                	mov    (%eax),%edx
  8005f7:	89 d0                	mov    %edx,%eax
  8005f9:	f7 d8                	neg    %eax
  8005fb:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8005fe:	83 f8 08             	cmp    $0x8,%eax
  800601:	7f 23                	jg     800626 <vprintfmt+0x15c>
  800603:	8b 14 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%edx
  80060a:	85 d2                	test   %edx,%edx
  80060c:	74 18                	je     800626 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80060e:	52                   	push   %edx
  80060f:	68 be 0f 80 00       	push   $0x800fbe
  800614:	53                   	push   %ebx
  800615:	56                   	push   %esi
  800616:	e8 92 fe ff ff       	call   8004ad <printfmt>
  80061b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80061e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800621:	e9 66 02 00 00       	jmp    80088c <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800626:	50                   	push   %eax
  800627:	68 b5 0f 80 00       	push   $0x800fb5
  80062c:	53                   	push   %ebx
  80062d:	56                   	push   %esi
  80062e:	e8 7a fe ff ff       	call   8004ad <printfmt>
  800633:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800636:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800639:	e9 4e 02 00 00       	jmp    80088c <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80063e:	8b 45 14             	mov    0x14(%ebp),%eax
  800641:	83 c0 04             	add    $0x4,%eax
  800644:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80064c:	85 d2                	test   %edx,%edx
  80064e:	b8 ae 0f 80 00       	mov    $0x800fae,%eax
  800653:	0f 45 c2             	cmovne %edx,%eax
  800656:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800659:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80065d:	7e 06                	jle    800665 <vprintfmt+0x19b>
  80065f:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800663:	75 0d                	jne    800672 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800665:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800668:	89 c7                	mov    %eax,%edi
  80066a:	03 45 e0             	add    -0x20(%ebp),%eax
  80066d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800670:	eb 55                	jmp    8006c7 <vprintfmt+0x1fd>
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	ff 75 d8             	push   -0x28(%ebp)
  800678:	ff 75 cc             	push   -0x34(%ebp)
  80067b:	e8 0a 03 00 00       	call   80098a <strnlen>
  800680:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800683:	29 c1                	sub    %eax,%ecx
  800685:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800688:	83 c4 10             	add    $0x10,%esp
  80068b:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80068d:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800691:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800694:	eb 0f                	jmp    8006a5 <vprintfmt+0x1db>
					putch(padc, putdat);
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	53                   	push   %ebx
  80069a:	ff 75 e0             	push   -0x20(%ebp)
  80069d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80069f:	83 ef 01             	sub    $0x1,%edi
  8006a2:	83 c4 10             	add    $0x10,%esp
  8006a5:	85 ff                	test   %edi,%edi
  8006a7:	7f ed                	jg     800696 <vprintfmt+0x1cc>
  8006a9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006ac:	85 d2                	test   %edx,%edx
  8006ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b3:	0f 49 c2             	cmovns %edx,%eax
  8006b6:	29 c2                	sub    %eax,%edx
  8006b8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006bb:	eb a8                	jmp    800665 <vprintfmt+0x19b>
					putch(ch, putdat);
  8006bd:	83 ec 08             	sub    $0x8,%esp
  8006c0:	53                   	push   %ebx
  8006c1:	52                   	push   %edx
  8006c2:	ff d6                	call   *%esi
  8006c4:	83 c4 10             	add    $0x10,%esp
  8006c7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006ca:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006cc:	83 c7 01             	add    $0x1,%edi
  8006cf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006d3:	0f be d0             	movsbl %al,%edx
  8006d6:	85 d2                	test   %edx,%edx
  8006d8:	74 4b                	je     800725 <vprintfmt+0x25b>
  8006da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006de:	78 06                	js     8006e6 <vprintfmt+0x21c>
  8006e0:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8006e4:	78 1e                	js     800704 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8006e6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006ea:	74 d1                	je     8006bd <vprintfmt+0x1f3>
  8006ec:	0f be c0             	movsbl %al,%eax
  8006ef:	83 e8 20             	sub    $0x20,%eax
  8006f2:	83 f8 5e             	cmp    $0x5e,%eax
  8006f5:	76 c6                	jbe    8006bd <vprintfmt+0x1f3>
					putch('?', putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	53                   	push   %ebx
  8006fb:	6a 3f                	push   $0x3f
  8006fd:	ff d6                	call   *%esi
  8006ff:	83 c4 10             	add    $0x10,%esp
  800702:	eb c3                	jmp    8006c7 <vprintfmt+0x1fd>
  800704:	89 cf                	mov    %ecx,%edi
  800706:	eb 0e                	jmp    800716 <vprintfmt+0x24c>
				putch(' ', putdat);
  800708:	83 ec 08             	sub    $0x8,%esp
  80070b:	53                   	push   %ebx
  80070c:	6a 20                	push   $0x20
  80070e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800710:	83 ef 01             	sub    $0x1,%edi
  800713:	83 c4 10             	add    $0x10,%esp
  800716:	85 ff                	test   %edi,%edi
  800718:	7f ee                	jg     800708 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80071a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80071d:	89 45 14             	mov    %eax,0x14(%ebp)
  800720:	e9 67 01 00 00       	jmp    80088c <vprintfmt+0x3c2>
  800725:	89 cf                	mov    %ecx,%edi
  800727:	eb ed                	jmp    800716 <vprintfmt+0x24c>
	if (lflag >= 2)
  800729:	83 f9 01             	cmp    $0x1,%ecx
  80072c:	7f 1b                	jg     800749 <vprintfmt+0x27f>
	else if (lflag)
  80072e:	85 c9                	test   %ecx,%ecx
  800730:	74 63                	je     800795 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800732:	8b 45 14             	mov    0x14(%ebp),%eax
  800735:	8b 00                	mov    (%eax),%eax
  800737:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80073a:	99                   	cltd   
  80073b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80073e:	8b 45 14             	mov    0x14(%ebp),%eax
  800741:	8d 40 04             	lea    0x4(%eax),%eax
  800744:	89 45 14             	mov    %eax,0x14(%ebp)
  800747:	eb 17                	jmp    800760 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800749:	8b 45 14             	mov    0x14(%ebp),%eax
  80074c:	8b 50 04             	mov    0x4(%eax),%edx
  80074f:	8b 00                	mov    (%eax),%eax
  800751:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800754:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800757:	8b 45 14             	mov    0x14(%ebp),%eax
  80075a:	8d 40 08             	lea    0x8(%eax),%eax
  80075d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800760:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800763:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800766:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80076b:	85 c9                	test   %ecx,%ecx
  80076d:	0f 89 ff 00 00 00    	jns    800872 <vprintfmt+0x3a8>
				putch('-', putdat);
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	53                   	push   %ebx
  800777:	6a 2d                	push   $0x2d
  800779:	ff d6                	call   *%esi
				num = -(long long) num;
  80077b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80077e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800781:	f7 da                	neg    %edx
  800783:	83 d1 00             	adc    $0x0,%ecx
  800786:	f7 d9                	neg    %ecx
  800788:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80078b:	bf 0a 00 00 00       	mov    $0xa,%edi
  800790:	e9 dd 00 00 00       	jmp    800872 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  800795:	8b 45 14             	mov    0x14(%ebp),%eax
  800798:	8b 00                	mov    (%eax),%eax
  80079a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80079d:	99                   	cltd   
  80079e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a4:	8d 40 04             	lea    0x4(%eax),%eax
  8007a7:	89 45 14             	mov    %eax,0x14(%ebp)
  8007aa:	eb b4                	jmp    800760 <vprintfmt+0x296>
	if (lflag >= 2)
  8007ac:	83 f9 01             	cmp    $0x1,%ecx
  8007af:	7f 1e                	jg     8007cf <vprintfmt+0x305>
	else if (lflag)
  8007b1:	85 c9                	test   %ecx,%ecx
  8007b3:	74 32                	je     8007e7 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8007b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b8:	8b 10                	mov    (%eax),%edx
  8007ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007bf:	8d 40 04             	lea    0x4(%eax),%eax
  8007c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007c5:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8007ca:	e9 a3 00 00 00       	jmp    800872 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d2:	8b 10                	mov    (%eax),%edx
  8007d4:	8b 48 04             	mov    0x4(%eax),%ecx
  8007d7:	8d 40 08             	lea    0x8(%eax),%eax
  8007da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007dd:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8007e2:	e9 8b 00 00 00       	jmp    800872 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ea:	8b 10                	mov    (%eax),%edx
  8007ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f1:	8d 40 04             	lea    0x4(%eax),%eax
  8007f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007f7:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8007fc:	eb 74                	jmp    800872 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8007fe:	83 f9 01             	cmp    $0x1,%ecx
  800801:	7f 1b                	jg     80081e <vprintfmt+0x354>
	else if (lflag)
  800803:	85 c9                	test   %ecx,%ecx
  800805:	74 2c                	je     800833 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800807:	8b 45 14             	mov    0x14(%ebp),%eax
  80080a:	8b 10                	mov    (%eax),%edx
  80080c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800811:	8d 40 04             	lea    0x4(%eax),%eax
  800814:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800817:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80081c:	eb 54                	jmp    800872 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80081e:	8b 45 14             	mov    0x14(%ebp),%eax
  800821:	8b 10                	mov    (%eax),%edx
  800823:	8b 48 04             	mov    0x4(%eax),%ecx
  800826:	8d 40 08             	lea    0x8(%eax),%eax
  800829:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80082c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800831:	eb 3f                	jmp    800872 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800833:	8b 45 14             	mov    0x14(%ebp),%eax
  800836:	8b 10                	mov    (%eax),%edx
  800838:	b9 00 00 00 00       	mov    $0x0,%ecx
  80083d:	8d 40 04             	lea    0x4(%eax),%eax
  800840:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800843:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800848:	eb 28                	jmp    800872 <vprintfmt+0x3a8>
			putch('0', putdat);
  80084a:	83 ec 08             	sub    $0x8,%esp
  80084d:	53                   	push   %ebx
  80084e:	6a 30                	push   $0x30
  800850:	ff d6                	call   *%esi
			putch('x', putdat);
  800852:	83 c4 08             	add    $0x8,%esp
  800855:	53                   	push   %ebx
  800856:	6a 78                	push   $0x78
  800858:	ff d6                	call   *%esi
			num = (unsigned long long)
  80085a:	8b 45 14             	mov    0x14(%ebp),%eax
  80085d:	8b 10                	mov    (%eax),%edx
  80085f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800864:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800867:	8d 40 04             	lea    0x4(%eax),%eax
  80086a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80086d:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800872:	83 ec 0c             	sub    $0xc,%esp
  800875:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800879:	50                   	push   %eax
  80087a:	ff 75 e0             	push   -0x20(%ebp)
  80087d:	57                   	push   %edi
  80087e:	51                   	push   %ecx
  80087f:	52                   	push   %edx
  800880:	89 da                	mov    %ebx,%edx
  800882:	89 f0                	mov    %esi,%eax
  800884:	e8 5e fb ff ff       	call   8003e7 <printnum>
			break;
  800889:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80088c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80088f:	e9 54 fc ff ff       	jmp    8004e8 <vprintfmt+0x1e>
	if (lflag >= 2)
  800894:	83 f9 01             	cmp    $0x1,%ecx
  800897:	7f 1b                	jg     8008b4 <vprintfmt+0x3ea>
	else if (lflag)
  800899:	85 c9                	test   %ecx,%ecx
  80089b:	74 2c                	je     8008c9 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  80089d:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a0:	8b 10                	mov    (%eax),%edx
  8008a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008a7:	8d 40 04             	lea    0x4(%eax),%eax
  8008aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008ad:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8008b2:	eb be                	jmp    800872 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8008b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b7:	8b 10                	mov    (%eax),%edx
  8008b9:	8b 48 04             	mov    0x4(%eax),%ecx
  8008bc:	8d 40 08             	lea    0x8(%eax),%eax
  8008bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008c2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8008c7:	eb a9                	jmp    800872 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8008c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cc:	8b 10                	mov    (%eax),%edx
  8008ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008d3:	8d 40 04             	lea    0x4(%eax),%eax
  8008d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008d9:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8008de:	eb 92                	jmp    800872 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8008e0:	83 ec 08             	sub    $0x8,%esp
  8008e3:	53                   	push   %ebx
  8008e4:	6a 25                	push   $0x25
  8008e6:	ff d6                	call   *%esi
			break;
  8008e8:	83 c4 10             	add    $0x10,%esp
  8008eb:	eb 9f                	jmp    80088c <vprintfmt+0x3c2>
			putch('%', putdat);
  8008ed:	83 ec 08             	sub    $0x8,%esp
  8008f0:	53                   	push   %ebx
  8008f1:	6a 25                	push   $0x25
  8008f3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008f5:	83 c4 10             	add    $0x10,%esp
  8008f8:	89 f8                	mov    %edi,%eax
  8008fa:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8008fe:	74 05                	je     800905 <vprintfmt+0x43b>
  800900:	83 e8 01             	sub    $0x1,%eax
  800903:	eb f5                	jmp    8008fa <vprintfmt+0x430>
  800905:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800908:	eb 82                	jmp    80088c <vprintfmt+0x3c2>

0080090a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	83 ec 18             	sub    $0x18,%esp
  800910:	8b 45 08             	mov    0x8(%ebp),%eax
  800913:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800916:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800919:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80091d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800920:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800927:	85 c0                	test   %eax,%eax
  800929:	74 26                	je     800951 <vsnprintf+0x47>
  80092b:	85 d2                	test   %edx,%edx
  80092d:	7e 22                	jle    800951 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80092f:	ff 75 14             	push   0x14(%ebp)
  800932:	ff 75 10             	push   0x10(%ebp)
  800935:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800938:	50                   	push   %eax
  800939:	68 90 04 80 00       	push   $0x800490
  80093e:	e8 87 fb ff ff       	call   8004ca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800943:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800946:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800949:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094c:	83 c4 10             	add    $0x10,%esp
}
  80094f:	c9                   	leave  
  800950:	c3                   	ret    
		return -E_INVAL;
  800951:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800956:	eb f7                	jmp    80094f <vsnprintf+0x45>

00800958 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800958:	55                   	push   %ebp
  800959:	89 e5                	mov    %esp,%ebp
  80095b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80095e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800961:	50                   	push   %eax
  800962:	ff 75 10             	push   0x10(%ebp)
  800965:	ff 75 0c             	push   0xc(%ebp)
  800968:	ff 75 08             	push   0x8(%ebp)
  80096b:	e8 9a ff ff ff       	call   80090a <vsnprintf>
	va_end(ap);

	return rc;
}
  800970:	c9                   	leave  
  800971:	c3                   	ret    

00800972 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800972:	55                   	push   %ebp
  800973:	89 e5                	mov    %esp,%ebp
  800975:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800978:	b8 00 00 00 00       	mov    $0x0,%eax
  80097d:	eb 03                	jmp    800982 <strlen+0x10>
		n++;
  80097f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800982:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800986:	75 f7                	jne    80097f <strlen+0xd>
	return n;
}
  800988:	5d                   	pop    %ebp
  800989:	c3                   	ret    

0080098a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80098a:	55                   	push   %ebp
  80098b:	89 e5                	mov    %esp,%ebp
  80098d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800990:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800993:	b8 00 00 00 00       	mov    $0x0,%eax
  800998:	eb 03                	jmp    80099d <strnlen+0x13>
		n++;
  80099a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80099d:	39 d0                	cmp    %edx,%eax
  80099f:	74 08                	je     8009a9 <strnlen+0x1f>
  8009a1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009a5:	75 f3                	jne    80099a <strnlen+0x10>
  8009a7:	89 c2                	mov    %eax,%edx
	return n;
}
  8009a9:	89 d0                	mov    %edx,%eax
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ad:	55                   	push   %ebp
  8009ae:	89 e5                	mov    %esp,%ebp
  8009b0:	53                   	push   %ebx
  8009b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009bc:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8009c0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8009c3:	83 c0 01             	add    $0x1,%eax
  8009c6:	84 d2                	test   %dl,%dl
  8009c8:	75 f2                	jne    8009bc <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009ca:	89 c8                	mov    %ecx,%eax
  8009cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009cf:	c9                   	leave  
  8009d0:	c3                   	ret    

008009d1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	53                   	push   %ebx
  8009d5:	83 ec 10             	sub    $0x10,%esp
  8009d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009db:	53                   	push   %ebx
  8009dc:	e8 91 ff ff ff       	call   800972 <strlen>
  8009e1:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8009e4:	ff 75 0c             	push   0xc(%ebp)
  8009e7:	01 d8                	add    %ebx,%eax
  8009e9:	50                   	push   %eax
  8009ea:	e8 be ff ff ff       	call   8009ad <strcpy>
	return dst;
}
  8009ef:	89 d8                	mov    %ebx,%eax
  8009f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f4:	c9                   	leave  
  8009f5:	c3                   	ret    

008009f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	56                   	push   %esi
  8009fa:	53                   	push   %ebx
  8009fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8009fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a01:	89 f3                	mov    %esi,%ebx
  800a03:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a06:	89 f0                	mov    %esi,%eax
  800a08:	eb 0f                	jmp    800a19 <strncpy+0x23>
		*dst++ = *src;
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	0f b6 0a             	movzbl (%edx),%ecx
  800a10:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a13:	80 f9 01             	cmp    $0x1,%cl
  800a16:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800a19:	39 d8                	cmp    %ebx,%eax
  800a1b:	75 ed                	jne    800a0a <strncpy+0x14>
	}
	return ret;
}
  800a1d:	89 f0                	mov    %esi,%eax
  800a1f:	5b                   	pop    %ebx
  800a20:	5e                   	pop    %esi
  800a21:	5d                   	pop    %ebp
  800a22:	c3                   	ret    

00800a23 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2e:	8b 55 10             	mov    0x10(%ebp),%edx
  800a31:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a33:	85 d2                	test   %edx,%edx
  800a35:	74 21                	je     800a58 <strlcpy+0x35>
  800a37:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a3b:	89 f2                	mov    %esi,%edx
  800a3d:	eb 09                	jmp    800a48 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a3f:	83 c1 01             	add    $0x1,%ecx
  800a42:	83 c2 01             	add    $0x1,%edx
  800a45:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800a48:	39 c2                	cmp    %eax,%edx
  800a4a:	74 09                	je     800a55 <strlcpy+0x32>
  800a4c:	0f b6 19             	movzbl (%ecx),%ebx
  800a4f:	84 db                	test   %bl,%bl
  800a51:	75 ec                	jne    800a3f <strlcpy+0x1c>
  800a53:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a55:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a58:	29 f0                	sub    %esi,%eax
}
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a64:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a67:	eb 06                	jmp    800a6f <strcmp+0x11>
		p++, q++;
  800a69:	83 c1 01             	add    $0x1,%ecx
  800a6c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a6f:	0f b6 01             	movzbl (%ecx),%eax
  800a72:	84 c0                	test   %al,%al
  800a74:	74 04                	je     800a7a <strcmp+0x1c>
  800a76:	3a 02                	cmp    (%edx),%al
  800a78:	74 ef                	je     800a69 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a7a:	0f b6 c0             	movzbl %al,%eax
  800a7d:	0f b6 12             	movzbl (%edx),%edx
  800a80:	29 d0                	sub    %edx,%eax
}
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    

00800a84 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a84:	55                   	push   %ebp
  800a85:	89 e5                	mov    %esp,%ebp
  800a87:	53                   	push   %ebx
  800a88:	8b 45 08             	mov    0x8(%ebp),%eax
  800a8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8e:	89 c3                	mov    %eax,%ebx
  800a90:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a93:	eb 06                	jmp    800a9b <strncmp+0x17>
		n--, p++, q++;
  800a95:	83 c0 01             	add    $0x1,%eax
  800a98:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a9b:	39 d8                	cmp    %ebx,%eax
  800a9d:	74 18                	je     800ab7 <strncmp+0x33>
  800a9f:	0f b6 08             	movzbl (%eax),%ecx
  800aa2:	84 c9                	test   %cl,%cl
  800aa4:	74 04                	je     800aaa <strncmp+0x26>
  800aa6:	3a 0a                	cmp    (%edx),%cl
  800aa8:	74 eb                	je     800a95 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aaa:	0f b6 00             	movzbl (%eax),%eax
  800aad:	0f b6 12             	movzbl (%edx),%edx
  800ab0:	29 d0                	sub    %edx,%eax
}
  800ab2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ab5:	c9                   	leave  
  800ab6:	c3                   	ret    
		return 0;
  800ab7:	b8 00 00 00 00       	mov    $0x0,%eax
  800abc:	eb f4                	jmp    800ab2 <strncmp+0x2e>

00800abe <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac8:	eb 03                	jmp    800acd <strchr+0xf>
  800aca:	83 c0 01             	add    $0x1,%eax
  800acd:	0f b6 10             	movzbl (%eax),%edx
  800ad0:	84 d2                	test   %dl,%dl
  800ad2:	74 06                	je     800ada <strchr+0x1c>
		if (*s == c)
  800ad4:	38 ca                	cmp    %cl,%dl
  800ad6:	75 f2                	jne    800aca <strchr+0xc>
  800ad8:	eb 05                	jmp    800adf <strchr+0x21>
			return (char *) s;
	return 0;
  800ada:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aeb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aee:	38 ca                	cmp    %cl,%dl
  800af0:	74 09                	je     800afb <strfind+0x1a>
  800af2:	84 d2                	test   %dl,%dl
  800af4:	74 05                	je     800afb <strfind+0x1a>
	for (; *s; s++)
  800af6:	83 c0 01             	add    $0x1,%eax
  800af9:	eb f0                	jmp    800aeb <strfind+0xa>
			break;
	return (char *) s;
}
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800afd:	55                   	push   %ebp
  800afe:	89 e5                	mov    %esp,%ebp
  800b00:	57                   	push   %edi
  800b01:	56                   	push   %esi
  800b02:	53                   	push   %ebx
  800b03:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b06:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b09:	85 c9                	test   %ecx,%ecx
  800b0b:	74 2f                	je     800b3c <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b0d:	89 f8                	mov    %edi,%eax
  800b0f:	09 c8                	or     %ecx,%eax
  800b11:	a8 03                	test   $0x3,%al
  800b13:	75 21                	jne    800b36 <memset+0x39>
		c &= 0xFF;
  800b15:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b19:	89 d0                	mov    %edx,%eax
  800b1b:	c1 e0 08             	shl    $0x8,%eax
  800b1e:	89 d3                	mov    %edx,%ebx
  800b20:	c1 e3 18             	shl    $0x18,%ebx
  800b23:	89 d6                	mov    %edx,%esi
  800b25:	c1 e6 10             	shl    $0x10,%esi
  800b28:	09 f3                	or     %esi,%ebx
  800b2a:	09 da                	or     %ebx,%edx
  800b2c:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b2e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b31:	fc                   	cld    
  800b32:	f3 ab                	rep stos %eax,%es:(%edi)
  800b34:	eb 06                	jmp    800b3c <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b39:	fc                   	cld    
  800b3a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b3c:	89 f8                	mov    %edi,%eax
  800b3e:	5b                   	pop    %ebx
  800b3f:	5e                   	pop    %esi
  800b40:	5f                   	pop    %edi
  800b41:	5d                   	pop    %ebp
  800b42:	c3                   	ret    

00800b43 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b43:	55                   	push   %ebp
  800b44:	89 e5                	mov    %esp,%ebp
  800b46:	57                   	push   %edi
  800b47:	56                   	push   %esi
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
  800b4b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b51:	39 c6                	cmp    %eax,%esi
  800b53:	73 32                	jae    800b87 <memmove+0x44>
  800b55:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b58:	39 c2                	cmp    %eax,%edx
  800b5a:	76 2b                	jbe    800b87 <memmove+0x44>
		s += n;
		d += n;
  800b5c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b5f:	89 d6                	mov    %edx,%esi
  800b61:	09 fe                	or     %edi,%esi
  800b63:	09 ce                	or     %ecx,%esi
  800b65:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b6b:	75 0e                	jne    800b7b <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b6d:	83 ef 04             	sub    $0x4,%edi
  800b70:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b73:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b76:	fd                   	std    
  800b77:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b79:	eb 09                	jmp    800b84 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b7b:	83 ef 01             	sub    $0x1,%edi
  800b7e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b81:	fd                   	std    
  800b82:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b84:	fc                   	cld    
  800b85:	eb 1a                	jmp    800ba1 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b87:	89 f2                	mov    %esi,%edx
  800b89:	09 c2                	or     %eax,%edx
  800b8b:	09 ca                	or     %ecx,%edx
  800b8d:	f6 c2 03             	test   $0x3,%dl
  800b90:	75 0a                	jne    800b9c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b92:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b95:	89 c7                	mov    %eax,%edi
  800b97:	fc                   	cld    
  800b98:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b9a:	eb 05                	jmp    800ba1 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800b9c:	89 c7                	mov    %eax,%edi
  800b9e:	fc                   	cld    
  800b9f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bab:	ff 75 10             	push   0x10(%ebp)
  800bae:	ff 75 0c             	push   0xc(%ebp)
  800bb1:	ff 75 08             	push   0x8(%ebp)
  800bb4:	e8 8a ff ff ff       	call   800b43 <memmove>
}
  800bb9:	c9                   	leave  
  800bba:	c3                   	ret    

00800bbb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	56                   	push   %esi
  800bbf:	53                   	push   %ebx
  800bc0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bc6:	89 c6                	mov    %eax,%esi
  800bc8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bcb:	eb 06                	jmp    800bd3 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bcd:	83 c0 01             	add    $0x1,%eax
  800bd0:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800bd3:	39 f0                	cmp    %esi,%eax
  800bd5:	74 14                	je     800beb <memcmp+0x30>
		if (*s1 != *s2)
  800bd7:	0f b6 08             	movzbl (%eax),%ecx
  800bda:	0f b6 1a             	movzbl (%edx),%ebx
  800bdd:	38 d9                	cmp    %bl,%cl
  800bdf:	74 ec                	je     800bcd <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800be1:	0f b6 c1             	movzbl %cl,%eax
  800be4:	0f b6 db             	movzbl %bl,%ebx
  800be7:	29 d8                	sub    %ebx,%eax
  800be9:	eb 05                	jmp    800bf0 <memcmp+0x35>
	}

	return 0;
  800beb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf0:	5b                   	pop    %ebx
  800bf1:	5e                   	pop    %esi
  800bf2:	5d                   	pop    %ebp
  800bf3:	c3                   	ret    

00800bf4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800bfd:	89 c2                	mov    %eax,%edx
  800bff:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c02:	eb 03                	jmp    800c07 <memfind+0x13>
  800c04:	83 c0 01             	add    $0x1,%eax
  800c07:	39 d0                	cmp    %edx,%eax
  800c09:	73 04                	jae    800c0f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c0b:	38 08                	cmp    %cl,(%eax)
  800c0d:	75 f5                	jne    800c04 <memfind+0x10>
			break;
	return (void *) s;
}
  800c0f:	5d                   	pop    %ebp
  800c10:	c3                   	ret    

00800c11 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c11:	55                   	push   %ebp
  800c12:	89 e5                	mov    %esp,%ebp
  800c14:	57                   	push   %edi
  800c15:	56                   	push   %esi
  800c16:	53                   	push   %ebx
  800c17:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1d:	eb 03                	jmp    800c22 <strtol+0x11>
		s++;
  800c1f:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800c22:	0f b6 02             	movzbl (%edx),%eax
  800c25:	3c 20                	cmp    $0x20,%al
  800c27:	74 f6                	je     800c1f <strtol+0xe>
  800c29:	3c 09                	cmp    $0x9,%al
  800c2b:	74 f2                	je     800c1f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c2d:	3c 2b                	cmp    $0x2b,%al
  800c2f:	74 2a                	je     800c5b <strtol+0x4a>
	int neg = 0;
  800c31:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c36:	3c 2d                	cmp    $0x2d,%al
  800c38:	74 2b                	je     800c65 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c3a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c40:	75 0f                	jne    800c51 <strtol+0x40>
  800c42:	80 3a 30             	cmpb   $0x30,(%edx)
  800c45:	74 28                	je     800c6f <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c47:	85 db                	test   %ebx,%ebx
  800c49:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c4e:	0f 44 d8             	cmove  %eax,%ebx
  800c51:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c56:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c59:	eb 46                	jmp    800ca1 <strtol+0x90>
		s++;
  800c5b:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800c5e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c63:	eb d5                	jmp    800c3a <strtol+0x29>
		s++, neg = 1;
  800c65:	83 c2 01             	add    $0x1,%edx
  800c68:	bf 01 00 00 00       	mov    $0x1,%edi
  800c6d:	eb cb                	jmp    800c3a <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c6f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c73:	74 0e                	je     800c83 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800c75:	85 db                	test   %ebx,%ebx
  800c77:	75 d8                	jne    800c51 <strtol+0x40>
		s++, base = 8;
  800c79:	83 c2 01             	add    $0x1,%edx
  800c7c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c81:	eb ce                	jmp    800c51 <strtol+0x40>
		s += 2, base = 16;
  800c83:	83 c2 02             	add    $0x2,%edx
  800c86:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c8b:	eb c4                	jmp    800c51 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c8d:	0f be c0             	movsbl %al,%eax
  800c90:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c93:	3b 45 10             	cmp    0x10(%ebp),%eax
  800c96:	7d 3a                	jge    800cd2 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c98:	83 c2 01             	add    $0x1,%edx
  800c9b:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800c9f:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ca1:	0f b6 02             	movzbl (%edx),%eax
  800ca4:	8d 70 d0             	lea    -0x30(%eax),%esi
  800ca7:	89 f3                	mov    %esi,%ebx
  800ca9:	80 fb 09             	cmp    $0x9,%bl
  800cac:	76 df                	jbe    800c8d <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800cae:	8d 70 9f             	lea    -0x61(%eax),%esi
  800cb1:	89 f3                	mov    %esi,%ebx
  800cb3:	80 fb 19             	cmp    $0x19,%bl
  800cb6:	77 08                	ja     800cc0 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800cb8:	0f be c0             	movsbl %al,%eax
  800cbb:	83 e8 57             	sub    $0x57,%eax
  800cbe:	eb d3                	jmp    800c93 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800cc0:	8d 70 bf             	lea    -0x41(%eax),%esi
  800cc3:	89 f3                	mov    %esi,%ebx
  800cc5:	80 fb 19             	cmp    $0x19,%bl
  800cc8:	77 08                	ja     800cd2 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800cca:	0f be c0             	movsbl %al,%eax
  800ccd:	83 e8 37             	sub    $0x37,%eax
  800cd0:	eb c1                	jmp    800c93 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800cd2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cd6:	74 05                	je     800cdd <strtol+0xcc>
		*endptr = (char *) s;
  800cd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cdb:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800cdd:	89 c8                	mov    %ecx,%eax
  800cdf:	f7 d8                	neg    %eax
  800ce1:	85 ff                	test   %edi,%edi
  800ce3:	0f 45 c8             	cmovne %eax,%ecx
}
  800ce6:	89 c8                	mov    %ecx,%eax
  800ce8:	5b                   	pop    %ebx
  800ce9:	5e                   	pop    %esi
  800cea:	5f                   	pop    %edi
  800ceb:	5d                   	pop    %ebp
  800cec:	c3                   	ret    
  800ced:	66 90                	xchg   %ax,%ax
  800cef:	90                   	nop

00800cf0 <__udivdi3>:
  800cf0:	f3 0f 1e fb          	endbr32 
  800cf4:	55                   	push   %ebp
  800cf5:	57                   	push   %edi
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
  800cf8:	83 ec 1c             	sub    $0x1c,%esp
  800cfb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800cff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d03:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d07:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	75 19                	jne    800d28 <__udivdi3+0x38>
  800d0f:	39 f3                	cmp    %esi,%ebx
  800d11:	76 4d                	jbe    800d60 <__udivdi3+0x70>
  800d13:	31 ff                	xor    %edi,%edi
  800d15:	89 e8                	mov    %ebp,%eax
  800d17:	89 f2                	mov    %esi,%edx
  800d19:	f7 f3                	div    %ebx
  800d1b:	89 fa                	mov    %edi,%edx
  800d1d:	83 c4 1c             	add    $0x1c,%esp
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    
  800d25:	8d 76 00             	lea    0x0(%esi),%esi
  800d28:	39 f0                	cmp    %esi,%eax
  800d2a:	76 14                	jbe    800d40 <__udivdi3+0x50>
  800d2c:	31 ff                	xor    %edi,%edi
  800d2e:	31 c0                	xor    %eax,%eax
  800d30:	89 fa                	mov    %edi,%edx
  800d32:	83 c4 1c             	add    $0x1c,%esp
  800d35:	5b                   	pop    %ebx
  800d36:	5e                   	pop    %esi
  800d37:	5f                   	pop    %edi
  800d38:	5d                   	pop    %ebp
  800d39:	c3                   	ret    
  800d3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d40:	0f bd f8             	bsr    %eax,%edi
  800d43:	83 f7 1f             	xor    $0x1f,%edi
  800d46:	75 48                	jne    800d90 <__udivdi3+0xa0>
  800d48:	39 f0                	cmp    %esi,%eax
  800d4a:	72 06                	jb     800d52 <__udivdi3+0x62>
  800d4c:	31 c0                	xor    %eax,%eax
  800d4e:	39 eb                	cmp    %ebp,%ebx
  800d50:	77 de                	ja     800d30 <__udivdi3+0x40>
  800d52:	b8 01 00 00 00       	mov    $0x1,%eax
  800d57:	eb d7                	jmp    800d30 <__udivdi3+0x40>
  800d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d60:	89 d9                	mov    %ebx,%ecx
  800d62:	85 db                	test   %ebx,%ebx
  800d64:	75 0b                	jne    800d71 <__udivdi3+0x81>
  800d66:	b8 01 00 00 00       	mov    $0x1,%eax
  800d6b:	31 d2                	xor    %edx,%edx
  800d6d:	f7 f3                	div    %ebx
  800d6f:	89 c1                	mov    %eax,%ecx
  800d71:	31 d2                	xor    %edx,%edx
  800d73:	89 f0                	mov    %esi,%eax
  800d75:	f7 f1                	div    %ecx
  800d77:	89 c6                	mov    %eax,%esi
  800d79:	89 e8                	mov    %ebp,%eax
  800d7b:	89 f7                	mov    %esi,%edi
  800d7d:	f7 f1                	div    %ecx
  800d7f:	89 fa                	mov    %edi,%edx
  800d81:	83 c4 1c             	add    $0x1c,%esp
  800d84:	5b                   	pop    %ebx
  800d85:	5e                   	pop    %esi
  800d86:	5f                   	pop    %edi
  800d87:	5d                   	pop    %ebp
  800d88:	c3                   	ret    
  800d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d90:	89 f9                	mov    %edi,%ecx
  800d92:	ba 20 00 00 00       	mov    $0x20,%edx
  800d97:	29 fa                	sub    %edi,%edx
  800d99:	d3 e0                	shl    %cl,%eax
  800d9b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d9f:	89 d1                	mov    %edx,%ecx
  800da1:	89 d8                	mov    %ebx,%eax
  800da3:	d3 e8                	shr    %cl,%eax
  800da5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800da9:	09 c1                	or     %eax,%ecx
  800dab:	89 f0                	mov    %esi,%eax
  800dad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800db1:	89 f9                	mov    %edi,%ecx
  800db3:	d3 e3                	shl    %cl,%ebx
  800db5:	89 d1                	mov    %edx,%ecx
  800db7:	d3 e8                	shr    %cl,%eax
  800db9:	89 f9                	mov    %edi,%ecx
  800dbb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800dbf:	89 eb                	mov    %ebp,%ebx
  800dc1:	d3 e6                	shl    %cl,%esi
  800dc3:	89 d1                	mov    %edx,%ecx
  800dc5:	d3 eb                	shr    %cl,%ebx
  800dc7:	09 f3                	or     %esi,%ebx
  800dc9:	89 c6                	mov    %eax,%esi
  800dcb:	89 f2                	mov    %esi,%edx
  800dcd:	89 d8                	mov    %ebx,%eax
  800dcf:	f7 74 24 08          	divl   0x8(%esp)
  800dd3:	89 d6                	mov    %edx,%esi
  800dd5:	89 c3                	mov    %eax,%ebx
  800dd7:	f7 64 24 0c          	mull   0xc(%esp)
  800ddb:	39 d6                	cmp    %edx,%esi
  800ddd:	72 19                	jb     800df8 <__udivdi3+0x108>
  800ddf:	89 f9                	mov    %edi,%ecx
  800de1:	d3 e5                	shl    %cl,%ebp
  800de3:	39 c5                	cmp    %eax,%ebp
  800de5:	73 04                	jae    800deb <__udivdi3+0xfb>
  800de7:	39 d6                	cmp    %edx,%esi
  800de9:	74 0d                	je     800df8 <__udivdi3+0x108>
  800deb:	89 d8                	mov    %ebx,%eax
  800ded:	31 ff                	xor    %edi,%edi
  800def:	e9 3c ff ff ff       	jmp    800d30 <__udivdi3+0x40>
  800df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800df8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800dfb:	31 ff                	xor    %edi,%edi
  800dfd:	e9 2e ff ff ff       	jmp    800d30 <__udivdi3+0x40>
  800e02:	66 90                	xchg   %ax,%ax
  800e04:	66 90                	xchg   %ax,%ax
  800e06:	66 90                	xchg   %ax,%ax
  800e08:	66 90                	xchg   %ax,%ax
  800e0a:	66 90                	xchg   %ax,%ax
  800e0c:	66 90                	xchg   %ax,%ax
  800e0e:	66 90                	xchg   %ax,%ax

00800e10 <__umoddi3>:
  800e10:	f3 0f 1e fb          	endbr32 
  800e14:	55                   	push   %ebp
  800e15:	57                   	push   %edi
  800e16:	56                   	push   %esi
  800e17:	53                   	push   %ebx
  800e18:	83 ec 1c             	sub    $0x1c,%esp
  800e1b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e1f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e23:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800e27:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800e2b:	89 f0                	mov    %esi,%eax
  800e2d:	89 da                	mov    %ebx,%edx
  800e2f:	85 ff                	test   %edi,%edi
  800e31:	75 15                	jne    800e48 <__umoddi3+0x38>
  800e33:	39 dd                	cmp    %ebx,%ebp
  800e35:	76 39                	jbe    800e70 <__umoddi3+0x60>
  800e37:	f7 f5                	div    %ebp
  800e39:	89 d0                	mov    %edx,%eax
  800e3b:	31 d2                	xor    %edx,%edx
  800e3d:	83 c4 1c             	add    $0x1c,%esp
  800e40:	5b                   	pop    %ebx
  800e41:	5e                   	pop    %esi
  800e42:	5f                   	pop    %edi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    
  800e45:	8d 76 00             	lea    0x0(%esi),%esi
  800e48:	39 df                	cmp    %ebx,%edi
  800e4a:	77 f1                	ja     800e3d <__umoddi3+0x2d>
  800e4c:	0f bd cf             	bsr    %edi,%ecx
  800e4f:	83 f1 1f             	xor    $0x1f,%ecx
  800e52:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e56:	75 40                	jne    800e98 <__umoddi3+0x88>
  800e58:	39 df                	cmp    %ebx,%edi
  800e5a:	72 04                	jb     800e60 <__umoddi3+0x50>
  800e5c:	39 f5                	cmp    %esi,%ebp
  800e5e:	77 dd                	ja     800e3d <__umoddi3+0x2d>
  800e60:	89 da                	mov    %ebx,%edx
  800e62:	89 f0                	mov    %esi,%eax
  800e64:	29 e8                	sub    %ebp,%eax
  800e66:	19 fa                	sbb    %edi,%edx
  800e68:	eb d3                	jmp    800e3d <__umoddi3+0x2d>
  800e6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e70:	89 e9                	mov    %ebp,%ecx
  800e72:	85 ed                	test   %ebp,%ebp
  800e74:	75 0b                	jne    800e81 <__umoddi3+0x71>
  800e76:	b8 01 00 00 00       	mov    $0x1,%eax
  800e7b:	31 d2                	xor    %edx,%edx
  800e7d:	f7 f5                	div    %ebp
  800e7f:	89 c1                	mov    %eax,%ecx
  800e81:	89 d8                	mov    %ebx,%eax
  800e83:	31 d2                	xor    %edx,%edx
  800e85:	f7 f1                	div    %ecx
  800e87:	89 f0                	mov    %esi,%eax
  800e89:	f7 f1                	div    %ecx
  800e8b:	89 d0                	mov    %edx,%eax
  800e8d:	31 d2                	xor    %edx,%edx
  800e8f:	eb ac                	jmp    800e3d <__umoddi3+0x2d>
  800e91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e98:	8b 44 24 04          	mov    0x4(%esp),%eax
  800e9c:	ba 20 00 00 00       	mov    $0x20,%edx
  800ea1:	29 c2                	sub    %eax,%edx
  800ea3:	89 c1                	mov    %eax,%ecx
  800ea5:	89 e8                	mov    %ebp,%eax
  800ea7:	d3 e7                	shl    %cl,%edi
  800ea9:	89 d1                	mov    %edx,%ecx
  800eab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800eaf:	d3 e8                	shr    %cl,%eax
  800eb1:	89 c1                	mov    %eax,%ecx
  800eb3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800eb7:	09 f9                	or     %edi,%ecx
  800eb9:	89 df                	mov    %ebx,%edi
  800ebb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ebf:	89 c1                	mov    %eax,%ecx
  800ec1:	d3 e5                	shl    %cl,%ebp
  800ec3:	89 d1                	mov    %edx,%ecx
  800ec5:	d3 ef                	shr    %cl,%edi
  800ec7:	89 c1                	mov    %eax,%ecx
  800ec9:	89 f0                	mov    %esi,%eax
  800ecb:	d3 e3                	shl    %cl,%ebx
  800ecd:	89 d1                	mov    %edx,%ecx
  800ecf:	89 fa                	mov    %edi,%edx
  800ed1:	d3 e8                	shr    %cl,%eax
  800ed3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ed8:	09 d8                	or     %ebx,%eax
  800eda:	f7 74 24 08          	divl   0x8(%esp)
  800ede:	89 d3                	mov    %edx,%ebx
  800ee0:	d3 e6                	shl    %cl,%esi
  800ee2:	f7 e5                	mul    %ebp
  800ee4:	89 c7                	mov    %eax,%edi
  800ee6:	89 d1                	mov    %edx,%ecx
  800ee8:	39 d3                	cmp    %edx,%ebx
  800eea:	72 06                	jb     800ef2 <__umoddi3+0xe2>
  800eec:	75 0e                	jne    800efc <__umoddi3+0xec>
  800eee:	39 c6                	cmp    %eax,%esi
  800ef0:	73 0a                	jae    800efc <__umoddi3+0xec>
  800ef2:	29 e8                	sub    %ebp,%eax
  800ef4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800ef8:	89 d1                	mov    %edx,%ecx
  800efa:	89 c7                	mov    %eax,%edi
  800efc:	89 f5                	mov    %esi,%ebp
  800efe:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f02:	29 fd                	sub    %edi,%ebp
  800f04:	19 cb                	sbb    %ecx,%ebx
  800f06:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f0b:	89 d8                	mov    %ebx,%eax
  800f0d:	d3 e0                	shl    %cl,%eax
  800f0f:	89 f1                	mov    %esi,%ecx
  800f11:	d3 ed                	shr    %cl,%ebp
  800f13:	d3 eb                	shr    %cl,%ebx
  800f15:	09 e8                	or     %ebp,%eax
  800f17:	89 da                	mov    %ebx,%edx
  800f19:	83 c4 1c             	add    $0x1c,%esp
  800f1c:	5b                   	pop    %ebx
  800f1d:	5e                   	pop    %esi
  800f1e:	5f                   	pop    %edi
  800f1f:	5d                   	pop    %ebp
  800f20:	c3                   	ret    
