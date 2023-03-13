
obj/user/idle.debug：     文件格式 elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 30 80 00 60 	movl   $0x801d60,0x803000
  800040:	1d 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 ff 00 00 00       	call   800147 <sys_yield>
  800048:	eb f9                	jmp    800043 <umain+0x10>

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	56                   	push   %esi
  80004e:	53                   	push   %ebx
  80004f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800052:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800055:	e8 ce 00 00 00       	call   800128 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	55                   	push   %ebp
  800091:	89 e5                	mov    %esp,%ebp
  800093:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800096:	e8 88 04 00 00       	call   800523 <close_all>
	sys_env_destroy(0);
  80009b:	83 ec 0c             	sub    $0xc,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	e8 42 00 00 00       	call   8000e7 <sys_env_destroy>
}
  8000a5:	83 c4 10             	add    $0x10,%esp
  8000a8:	c9                   	leave  
  8000a9:	c3                   	ret    

008000aa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000aa:	55                   	push   %ebp
  8000ab:	89 e5                	mov    %esp,%ebp
  8000ad:	57                   	push   %edi
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bb:	89 c3                	mov    %eax,%ebx
  8000bd:	89 c7                	mov    %eax,%edi
  8000bf:	89 c6                	mov    %eax,%esi
  8000c1:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c3:	5b                   	pop    %ebx
  8000c4:	5e                   	pop    %esi
  8000c5:	5f                   	pop    %edi
  8000c6:	5d                   	pop    %ebp
  8000c7:	c3                   	ret    

008000c8 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d8:	89 d1                	mov    %edx,%ecx
  8000da:	89 d3                	mov    %edx,%ebx
  8000dc:	89 d7                	mov    %edx,%edi
  8000de:	89 d6                	mov    %edx,%esi
  8000e0:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e2:	5b                   	pop    %ebx
  8000e3:	5e                   	pop    %esi
  8000e4:	5f                   	pop    %edi
  8000e5:	5d                   	pop    %ebp
  8000e6:	c3                   	ret    

008000e7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e7:	55                   	push   %ebp
  8000e8:	89 e5                	mov    %esp,%ebp
  8000ea:	57                   	push   %edi
  8000eb:	56                   	push   %esi
  8000ec:	53                   	push   %ebx
  8000ed:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f8:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fd:	89 cb                	mov    %ecx,%ebx
  8000ff:	89 cf                	mov    %ecx,%edi
  800101:	89 ce                	mov    %ecx,%esi
  800103:	cd 30                	int    $0x30
	if(check && ret > 0)
  800105:	85 c0                	test   %eax,%eax
  800107:	7f 08                	jg     800111 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800109:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010c:	5b                   	pop    %ebx
  80010d:	5e                   	pop    %esi
  80010e:	5f                   	pop    %edi
  80010f:	5d                   	pop    %ebp
  800110:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800111:	83 ec 0c             	sub    $0xc,%esp
  800114:	50                   	push   %eax
  800115:	6a 03                	push   $0x3
  800117:	68 6f 1d 80 00       	push   $0x801d6f
  80011c:	6a 2a                	push   $0x2a
  80011e:	68 8c 1d 80 00       	push   $0x801d8c
  800123:	e8 d0 0e 00 00       	call   800ff8 <_panic>

00800128 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800128:	55                   	push   %ebp
  800129:	89 e5                	mov    %esp,%ebp
  80012b:	57                   	push   %edi
  80012c:	56                   	push   %esi
  80012d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80012e:	ba 00 00 00 00       	mov    $0x0,%edx
  800133:	b8 02 00 00 00       	mov    $0x2,%eax
  800138:	89 d1                	mov    %edx,%ecx
  80013a:	89 d3                	mov    %edx,%ebx
  80013c:	89 d7                	mov    %edx,%edi
  80013e:	89 d6                	mov    %edx,%esi
  800140:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800142:	5b                   	pop    %ebx
  800143:	5e                   	pop    %esi
  800144:	5f                   	pop    %edi
  800145:	5d                   	pop    %ebp
  800146:	c3                   	ret    

00800147 <sys_yield>:

void
sys_yield(void)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	57                   	push   %edi
  80014b:	56                   	push   %esi
  80014c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014d:	ba 00 00 00 00       	mov    $0x0,%edx
  800152:	b8 0b 00 00 00       	mov    $0xb,%eax
  800157:	89 d1                	mov    %edx,%ecx
  800159:	89 d3                	mov    %edx,%ebx
  80015b:	89 d7                	mov    %edx,%edi
  80015d:	89 d6                	mov    %edx,%esi
  80015f:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800161:	5b                   	pop    %ebx
  800162:	5e                   	pop    %esi
  800163:	5f                   	pop    %edi
  800164:	5d                   	pop    %ebp
  800165:	c3                   	ret    

00800166 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800166:	55                   	push   %ebp
  800167:	89 e5                	mov    %esp,%ebp
  800169:	57                   	push   %edi
  80016a:	56                   	push   %esi
  80016b:	53                   	push   %ebx
  80016c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80016f:	be 00 00 00 00       	mov    $0x0,%esi
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017a:	b8 04 00 00 00       	mov    $0x4,%eax
  80017f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800182:	89 f7                	mov    %esi,%edi
  800184:	cd 30                	int    $0x30
	if(check && ret > 0)
  800186:	85 c0                	test   %eax,%eax
  800188:	7f 08                	jg     800192 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018d:	5b                   	pop    %ebx
  80018e:	5e                   	pop    %esi
  80018f:	5f                   	pop    %edi
  800190:	5d                   	pop    %ebp
  800191:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	50                   	push   %eax
  800196:	6a 04                	push   $0x4
  800198:	68 6f 1d 80 00       	push   $0x801d6f
  80019d:	6a 2a                	push   $0x2a
  80019f:	68 8c 1d 80 00       	push   $0x801d8c
  8001a4:	e8 4f 0e 00 00       	call   800ff8 <_panic>

008001a9 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a9:	55                   	push   %ebp
  8001aa:	89 e5                	mov    %esp,%ebp
  8001ac:	57                   	push   %edi
  8001ad:	56                   	push   %esi
  8001ae:	53                   	push   %ebx
  8001af:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b8:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c0:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c3:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7f 08                	jg     8001d4 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001cf:	5b                   	pop    %ebx
  8001d0:	5e                   	pop    %esi
  8001d1:	5f                   	pop    %edi
  8001d2:	5d                   	pop    %ebp
  8001d3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d4:	83 ec 0c             	sub    $0xc,%esp
  8001d7:	50                   	push   %eax
  8001d8:	6a 05                	push   $0x5
  8001da:	68 6f 1d 80 00       	push   $0x801d6f
  8001df:	6a 2a                	push   $0x2a
  8001e1:	68 8c 1d 80 00       	push   $0x801d8c
  8001e6:	e8 0d 0e 00 00       	call   800ff8 <_panic>

008001eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001eb:	55                   	push   %ebp
  8001ec:	89 e5                	mov    %esp,%ebp
  8001ee:	57                   	push   %edi
  8001ef:	56                   	push   %esi
  8001f0:	53                   	push   %ebx
  8001f1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ff:	b8 06 00 00 00       	mov    $0x6,%eax
  800204:	89 df                	mov    %ebx,%edi
  800206:	89 de                	mov    %ebx,%esi
  800208:	cd 30                	int    $0x30
	if(check && ret > 0)
  80020a:	85 c0                	test   %eax,%eax
  80020c:	7f 08                	jg     800216 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80020e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800211:	5b                   	pop    %ebx
  800212:	5e                   	pop    %esi
  800213:	5f                   	pop    %edi
  800214:	5d                   	pop    %ebp
  800215:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800216:	83 ec 0c             	sub    $0xc,%esp
  800219:	50                   	push   %eax
  80021a:	6a 06                	push   $0x6
  80021c:	68 6f 1d 80 00       	push   $0x801d6f
  800221:	6a 2a                	push   $0x2a
  800223:	68 8c 1d 80 00       	push   $0x801d8c
  800228:	e8 cb 0d 00 00       	call   800ff8 <_panic>

0080022d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022d:	55                   	push   %ebp
  80022e:	89 e5                	mov    %esp,%ebp
  800230:	57                   	push   %edi
  800231:	56                   	push   %esi
  800232:	53                   	push   %ebx
  800233:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800236:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800241:	b8 08 00 00 00       	mov    $0x8,%eax
  800246:	89 df                	mov    %ebx,%edi
  800248:	89 de                	mov    %ebx,%esi
  80024a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80024c:	85 c0                	test   %eax,%eax
  80024e:	7f 08                	jg     800258 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800250:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800253:	5b                   	pop    %ebx
  800254:	5e                   	pop    %esi
  800255:	5f                   	pop    %edi
  800256:	5d                   	pop    %ebp
  800257:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800258:	83 ec 0c             	sub    $0xc,%esp
  80025b:	50                   	push   %eax
  80025c:	6a 08                	push   $0x8
  80025e:	68 6f 1d 80 00       	push   $0x801d6f
  800263:	6a 2a                	push   $0x2a
  800265:	68 8c 1d 80 00       	push   $0x801d8c
  80026a:	e8 89 0d 00 00       	call   800ff8 <_panic>

0080026f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	57                   	push   %edi
  800273:	56                   	push   %esi
  800274:	53                   	push   %ebx
  800275:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800283:	b8 09 00 00 00       	mov    $0x9,%eax
  800288:	89 df                	mov    %ebx,%edi
  80028a:	89 de                	mov    %ebx,%esi
  80028c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80028e:	85 c0                	test   %eax,%eax
  800290:	7f 08                	jg     80029a <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800292:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800295:	5b                   	pop    %ebx
  800296:	5e                   	pop    %esi
  800297:	5f                   	pop    %edi
  800298:	5d                   	pop    %ebp
  800299:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80029a:	83 ec 0c             	sub    $0xc,%esp
  80029d:	50                   	push   %eax
  80029e:	6a 09                	push   $0x9
  8002a0:	68 6f 1d 80 00       	push   $0x801d6f
  8002a5:	6a 2a                	push   $0x2a
  8002a7:	68 8c 1d 80 00       	push   $0x801d8c
  8002ac:	e8 47 0d 00 00       	call   800ff8 <_panic>

008002b1 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002ba:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002ca:	89 df                	mov    %ebx,%edi
  8002cc:	89 de                	mov    %ebx,%esi
  8002ce:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002d0:	85 c0                	test   %eax,%eax
  8002d2:	7f 08                	jg     8002dc <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002d7:	5b                   	pop    %ebx
  8002d8:	5e                   	pop    %esi
  8002d9:	5f                   	pop    %edi
  8002da:	5d                   	pop    %ebp
  8002db:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002dc:	83 ec 0c             	sub    $0xc,%esp
  8002df:	50                   	push   %eax
  8002e0:	6a 0a                	push   $0xa
  8002e2:	68 6f 1d 80 00       	push   $0x801d6f
  8002e7:	6a 2a                	push   $0x2a
  8002e9:	68 8c 1d 80 00       	push   $0x801d8c
  8002ee:	e8 05 0d 00 00       	call   800ff8 <_panic>

008002f3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	57                   	push   %edi
  8002f7:	56                   	push   %esi
  8002f8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ff:	b8 0c 00 00 00       	mov    $0xc,%eax
  800304:	be 00 00 00 00       	mov    $0x0,%esi
  800309:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80030c:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030f:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800311:	5b                   	pop    %ebx
  800312:	5e                   	pop    %esi
  800313:	5f                   	pop    %edi
  800314:	5d                   	pop    %ebp
  800315:	c3                   	ret    

00800316 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	57                   	push   %edi
  80031a:	56                   	push   %esi
  80031b:	53                   	push   %ebx
  80031c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80031f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800324:	8b 55 08             	mov    0x8(%ebp),%edx
  800327:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032c:	89 cb                	mov    %ecx,%ebx
  80032e:	89 cf                	mov    %ecx,%edi
  800330:	89 ce                	mov    %ecx,%esi
  800332:	cd 30                	int    $0x30
	if(check && ret > 0)
  800334:	85 c0                	test   %eax,%eax
  800336:	7f 08                	jg     800340 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800338:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80033b:	5b                   	pop    %ebx
  80033c:	5e                   	pop    %esi
  80033d:	5f                   	pop    %edi
  80033e:	5d                   	pop    %ebp
  80033f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	50                   	push   %eax
  800344:	6a 0d                	push   $0xd
  800346:	68 6f 1d 80 00       	push   $0x801d6f
  80034b:	6a 2a                	push   $0x2a
  80034d:	68 8c 1d 80 00       	push   $0x801d8c
  800352:	e8 a1 0c 00 00       	call   800ff8 <_panic>

00800357 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035a:	8b 45 08             	mov    0x8(%ebp),%eax
  80035d:	05 00 00 00 30       	add    $0x30000000,%eax
  800362:	c1 e8 0c             	shr    $0xc,%eax
}
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800367:	55                   	push   %ebp
  800368:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80036a:	8b 45 08             	mov    0x8(%ebp),%eax
  80036d:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800372:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800377:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037e:	55                   	push   %ebp
  80037f:	89 e5                	mov    %esp,%ebp
  800381:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800386:	89 c2                	mov    %eax,%edx
  800388:	c1 ea 16             	shr    $0x16,%edx
  80038b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800392:	f6 c2 01             	test   $0x1,%dl
  800395:	74 29                	je     8003c0 <fd_alloc+0x42>
  800397:	89 c2                	mov    %eax,%edx
  800399:	c1 ea 0c             	shr    $0xc,%edx
  80039c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a3:	f6 c2 01             	test   $0x1,%dl
  8003a6:	74 18                	je     8003c0 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8003a8:	05 00 10 00 00       	add    $0x1000,%eax
  8003ad:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b2:	75 d2                	jne    800386 <fd_alloc+0x8>
  8003b4:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8003b9:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8003be:	eb 05                	jmp    8003c5 <fd_alloc+0x47>
			return 0;
  8003c0:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8003c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c8:	89 02                	mov    %eax,(%edx)
}
  8003ca:	89 c8                	mov    %ecx,%eax
  8003cc:	5d                   	pop    %ebp
  8003cd:	c3                   	ret    

008003ce <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
  8003d1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d4:	83 f8 1f             	cmp    $0x1f,%eax
  8003d7:	77 30                	ja     800409 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d9:	c1 e0 0c             	shl    $0xc,%eax
  8003dc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e1:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003e7:	f6 c2 01             	test   $0x1,%dl
  8003ea:	74 24                	je     800410 <fd_lookup+0x42>
  8003ec:	89 c2                	mov    %eax,%edx
  8003ee:	c1 ea 0c             	shr    $0xc,%edx
  8003f1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f8:	f6 c2 01             	test   $0x1,%dl
  8003fb:	74 1a                	je     800417 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800400:	89 02                	mov    %eax,(%edx)
	return 0;
  800402:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800407:	5d                   	pop    %ebp
  800408:	c3                   	ret    
		return -E_INVAL;
  800409:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040e:	eb f7                	jmp    800407 <fd_lookup+0x39>
		return -E_INVAL;
  800410:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800415:	eb f0                	jmp    800407 <fd_lookup+0x39>
  800417:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041c:	eb e9                	jmp    800407 <fd_lookup+0x39>

0080041e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80041e:	55                   	push   %ebp
  80041f:	89 e5                	mov    %esp,%ebp
  800421:	53                   	push   %ebx
  800422:	83 ec 04             	sub    $0x4,%esp
  800425:	8b 55 08             	mov    0x8(%ebp),%edx
  800428:	b8 18 1e 80 00       	mov    $0x801e18,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  80042d:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800432:	39 13                	cmp    %edx,(%ebx)
  800434:	74 32                	je     800468 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800436:	83 c0 04             	add    $0x4,%eax
  800439:	8b 18                	mov    (%eax),%ebx
  80043b:	85 db                	test   %ebx,%ebx
  80043d:	75 f3                	jne    800432 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80043f:	a1 00 40 80 00       	mov    0x804000,%eax
  800444:	8b 40 48             	mov    0x48(%eax),%eax
  800447:	83 ec 04             	sub    $0x4,%esp
  80044a:	52                   	push   %edx
  80044b:	50                   	push   %eax
  80044c:	68 9c 1d 80 00       	push   $0x801d9c
  800451:	e8 7d 0c 00 00       	call   8010d3 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800456:	83 c4 10             	add    $0x10,%esp
  800459:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  80045e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800461:	89 1a                	mov    %ebx,(%edx)
}
  800463:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800466:	c9                   	leave  
  800467:	c3                   	ret    
			return 0;
  800468:	b8 00 00 00 00       	mov    $0x0,%eax
  80046d:	eb ef                	jmp    80045e <dev_lookup+0x40>

0080046f <fd_close>:
{
  80046f:	55                   	push   %ebp
  800470:	89 e5                	mov    %esp,%ebp
  800472:	57                   	push   %edi
  800473:	56                   	push   %esi
  800474:	53                   	push   %ebx
  800475:	83 ec 24             	sub    $0x24,%esp
  800478:	8b 75 08             	mov    0x8(%ebp),%esi
  80047b:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80047e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800481:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800482:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800488:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80048b:	50                   	push   %eax
  80048c:	e8 3d ff ff ff       	call   8003ce <fd_lookup>
  800491:	89 c3                	mov    %eax,%ebx
  800493:	83 c4 10             	add    $0x10,%esp
  800496:	85 c0                	test   %eax,%eax
  800498:	78 05                	js     80049f <fd_close+0x30>
	    || fd != fd2)
  80049a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80049d:	74 16                	je     8004b5 <fd_close+0x46>
		return (must_exist ? r : 0);
  80049f:	89 f8                	mov    %edi,%eax
  8004a1:	84 c0                	test   %al,%al
  8004a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a8:	0f 44 d8             	cmove  %eax,%ebx
}
  8004ab:	89 d8                	mov    %ebx,%eax
  8004ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004b0:	5b                   	pop    %ebx
  8004b1:	5e                   	pop    %esi
  8004b2:	5f                   	pop    %edi
  8004b3:	5d                   	pop    %ebp
  8004b4:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004b5:	83 ec 08             	sub    $0x8,%esp
  8004b8:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004bb:	50                   	push   %eax
  8004bc:	ff 36                	push   (%esi)
  8004be:	e8 5b ff ff ff       	call   80041e <dev_lookup>
  8004c3:	89 c3                	mov    %eax,%ebx
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	78 1a                	js     8004e6 <fd_close+0x77>
		if (dev->dev_close)
  8004cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004cf:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8004d2:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004d7:	85 c0                	test   %eax,%eax
  8004d9:	74 0b                	je     8004e6 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8004db:	83 ec 0c             	sub    $0xc,%esp
  8004de:	56                   	push   %esi
  8004df:	ff d0                	call   *%eax
  8004e1:	89 c3                	mov    %eax,%ebx
  8004e3:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	56                   	push   %esi
  8004ea:	6a 00                	push   $0x0
  8004ec:	e8 fa fc ff ff       	call   8001eb <sys_page_unmap>
	return r;
  8004f1:	83 c4 10             	add    $0x10,%esp
  8004f4:	eb b5                	jmp    8004ab <fd_close+0x3c>

008004f6 <close>:

int
close(int fdnum)
{
  8004f6:	55                   	push   %ebp
  8004f7:	89 e5                	mov    %esp,%ebp
  8004f9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ff:	50                   	push   %eax
  800500:	ff 75 08             	push   0x8(%ebp)
  800503:	e8 c6 fe ff ff       	call   8003ce <fd_lookup>
  800508:	83 c4 10             	add    $0x10,%esp
  80050b:	85 c0                	test   %eax,%eax
  80050d:	79 02                	jns    800511 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80050f:	c9                   	leave  
  800510:	c3                   	ret    
		return fd_close(fd, 1);
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	6a 01                	push   $0x1
  800516:	ff 75 f4             	push   -0xc(%ebp)
  800519:	e8 51 ff ff ff       	call   80046f <fd_close>
  80051e:	83 c4 10             	add    $0x10,%esp
  800521:	eb ec                	jmp    80050f <close+0x19>

00800523 <close_all>:

void
close_all(void)
{
  800523:	55                   	push   %ebp
  800524:	89 e5                	mov    %esp,%ebp
  800526:	53                   	push   %ebx
  800527:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80052a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052f:	83 ec 0c             	sub    $0xc,%esp
  800532:	53                   	push   %ebx
  800533:	e8 be ff ff ff       	call   8004f6 <close>
	for (i = 0; i < MAXFD; i++)
  800538:	83 c3 01             	add    $0x1,%ebx
  80053b:	83 c4 10             	add    $0x10,%esp
  80053e:	83 fb 20             	cmp    $0x20,%ebx
  800541:	75 ec                	jne    80052f <close_all+0xc>
}
  800543:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800546:	c9                   	leave  
  800547:	c3                   	ret    

00800548 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800548:	55                   	push   %ebp
  800549:	89 e5                	mov    %esp,%ebp
  80054b:	57                   	push   %edi
  80054c:	56                   	push   %esi
  80054d:	53                   	push   %ebx
  80054e:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800551:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800554:	50                   	push   %eax
  800555:	ff 75 08             	push   0x8(%ebp)
  800558:	e8 71 fe ff ff       	call   8003ce <fd_lookup>
  80055d:	89 c3                	mov    %eax,%ebx
  80055f:	83 c4 10             	add    $0x10,%esp
  800562:	85 c0                	test   %eax,%eax
  800564:	78 7f                	js     8005e5 <dup+0x9d>
		return r;
	close(newfdnum);
  800566:	83 ec 0c             	sub    $0xc,%esp
  800569:	ff 75 0c             	push   0xc(%ebp)
  80056c:	e8 85 ff ff ff       	call   8004f6 <close>

	newfd = INDEX2FD(newfdnum);
  800571:	8b 75 0c             	mov    0xc(%ebp),%esi
  800574:	c1 e6 0c             	shl    $0xc,%esi
  800577:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80057d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800580:	89 3c 24             	mov    %edi,(%esp)
  800583:	e8 df fd ff ff       	call   800367 <fd2data>
  800588:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80058a:	89 34 24             	mov    %esi,(%esp)
  80058d:	e8 d5 fd ff ff       	call   800367 <fd2data>
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800598:	89 d8                	mov    %ebx,%eax
  80059a:	c1 e8 16             	shr    $0x16,%eax
  80059d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a4:	a8 01                	test   $0x1,%al
  8005a6:	74 11                	je     8005b9 <dup+0x71>
  8005a8:	89 d8                	mov    %ebx,%eax
  8005aa:	c1 e8 0c             	shr    $0xc,%eax
  8005ad:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b4:	f6 c2 01             	test   $0x1,%dl
  8005b7:	75 36                	jne    8005ef <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005b9:	89 f8                	mov    %edi,%eax
  8005bb:	c1 e8 0c             	shr    $0xc,%eax
  8005be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c5:	83 ec 0c             	sub    $0xc,%esp
  8005c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005cd:	50                   	push   %eax
  8005ce:	56                   	push   %esi
  8005cf:	6a 00                	push   $0x0
  8005d1:	57                   	push   %edi
  8005d2:	6a 00                	push   $0x0
  8005d4:	e8 d0 fb ff ff       	call   8001a9 <sys_page_map>
  8005d9:	89 c3                	mov    %eax,%ebx
  8005db:	83 c4 20             	add    $0x20,%esp
  8005de:	85 c0                	test   %eax,%eax
  8005e0:	78 33                	js     800615 <dup+0xcd>
		goto err;

	return newfdnum;
  8005e2:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005e5:	89 d8                	mov    %ebx,%eax
  8005e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005ea:	5b                   	pop    %ebx
  8005eb:	5e                   	pop    %esi
  8005ec:	5f                   	pop    %edi
  8005ed:	5d                   	pop    %ebp
  8005ee:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ef:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f6:	83 ec 0c             	sub    $0xc,%esp
  8005f9:	25 07 0e 00 00       	and    $0xe07,%eax
  8005fe:	50                   	push   %eax
  8005ff:	ff 75 d4             	push   -0x2c(%ebp)
  800602:	6a 00                	push   $0x0
  800604:	53                   	push   %ebx
  800605:	6a 00                	push   $0x0
  800607:	e8 9d fb ff ff       	call   8001a9 <sys_page_map>
  80060c:	89 c3                	mov    %eax,%ebx
  80060e:	83 c4 20             	add    $0x20,%esp
  800611:	85 c0                	test   %eax,%eax
  800613:	79 a4                	jns    8005b9 <dup+0x71>
	sys_page_unmap(0, newfd);
  800615:	83 ec 08             	sub    $0x8,%esp
  800618:	56                   	push   %esi
  800619:	6a 00                	push   $0x0
  80061b:	e8 cb fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  800620:	83 c4 08             	add    $0x8,%esp
  800623:	ff 75 d4             	push   -0x2c(%ebp)
  800626:	6a 00                	push   $0x0
  800628:	e8 be fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  80062d:	83 c4 10             	add    $0x10,%esp
  800630:	eb b3                	jmp    8005e5 <dup+0x9d>

00800632 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800632:	55                   	push   %ebp
  800633:	89 e5                	mov    %esp,%ebp
  800635:	56                   	push   %esi
  800636:	53                   	push   %ebx
  800637:	83 ec 18             	sub    $0x18,%esp
  80063a:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800640:	50                   	push   %eax
  800641:	56                   	push   %esi
  800642:	e8 87 fd ff ff       	call   8003ce <fd_lookup>
  800647:	83 c4 10             	add    $0x10,%esp
  80064a:	85 c0                	test   %eax,%eax
  80064c:	78 3c                	js     80068a <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80064e:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800657:	50                   	push   %eax
  800658:	ff 33                	push   (%ebx)
  80065a:	e8 bf fd ff ff       	call   80041e <dev_lookup>
  80065f:	83 c4 10             	add    $0x10,%esp
  800662:	85 c0                	test   %eax,%eax
  800664:	78 24                	js     80068a <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800666:	8b 43 08             	mov    0x8(%ebx),%eax
  800669:	83 e0 03             	and    $0x3,%eax
  80066c:	83 f8 01             	cmp    $0x1,%eax
  80066f:	74 20                	je     800691 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800671:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800674:	8b 40 08             	mov    0x8(%eax),%eax
  800677:	85 c0                	test   %eax,%eax
  800679:	74 37                	je     8006b2 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80067b:	83 ec 04             	sub    $0x4,%esp
  80067e:	ff 75 10             	push   0x10(%ebp)
  800681:	ff 75 0c             	push   0xc(%ebp)
  800684:	53                   	push   %ebx
  800685:	ff d0                	call   *%eax
  800687:	83 c4 10             	add    $0x10,%esp
}
  80068a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80068d:	5b                   	pop    %ebx
  80068e:	5e                   	pop    %esi
  80068f:	5d                   	pop    %ebp
  800690:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800691:	a1 00 40 80 00       	mov    0x804000,%eax
  800696:	8b 40 48             	mov    0x48(%eax),%eax
  800699:	83 ec 04             	sub    $0x4,%esp
  80069c:	56                   	push   %esi
  80069d:	50                   	push   %eax
  80069e:	68 dd 1d 80 00       	push   $0x801ddd
  8006a3:	e8 2b 0a 00 00       	call   8010d3 <cprintf>
		return -E_INVAL;
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b0:	eb d8                	jmp    80068a <read+0x58>
		return -E_NOT_SUPP;
  8006b2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006b7:	eb d1                	jmp    80068a <read+0x58>

008006b9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b9:	55                   	push   %ebp
  8006ba:	89 e5                	mov    %esp,%ebp
  8006bc:	57                   	push   %edi
  8006bd:	56                   	push   %esi
  8006be:	53                   	push   %ebx
  8006bf:	83 ec 0c             	sub    $0xc,%esp
  8006c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006cd:	eb 02                	jmp    8006d1 <readn+0x18>
  8006cf:	01 c3                	add    %eax,%ebx
  8006d1:	39 f3                	cmp    %esi,%ebx
  8006d3:	73 21                	jae    8006f6 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d5:	83 ec 04             	sub    $0x4,%esp
  8006d8:	89 f0                	mov    %esi,%eax
  8006da:	29 d8                	sub    %ebx,%eax
  8006dc:	50                   	push   %eax
  8006dd:	89 d8                	mov    %ebx,%eax
  8006df:	03 45 0c             	add    0xc(%ebp),%eax
  8006e2:	50                   	push   %eax
  8006e3:	57                   	push   %edi
  8006e4:	e8 49 ff ff ff       	call   800632 <read>
		if (m < 0)
  8006e9:	83 c4 10             	add    $0x10,%esp
  8006ec:	85 c0                	test   %eax,%eax
  8006ee:	78 04                	js     8006f4 <readn+0x3b>
			return m;
		if (m == 0)
  8006f0:	75 dd                	jne    8006cf <readn+0x16>
  8006f2:	eb 02                	jmp    8006f6 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f4:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006f6:	89 d8                	mov    %ebx,%eax
  8006f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fb:	5b                   	pop    %ebx
  8006fc:	5e                   	pop    %esi
  8006fd:	5f                   	pop    %edi
  8006fe:	5d                   	pop    %ebp
  8006ff:	c3                   	ret    

00800700 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	56                   	push   %esi
  800704:	53                   	push   %ebx
  800705:	83 ec 18             	sub    $0x18,%esp
  800708:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070e:	50                   	push   %eax
  80070f:	53                   	push   %ebx
  800710:	e8 b9 fc ff ff       	call   8003ce <fd_lookup>
  800715:	83 c4 10             	add    $0x10,%esp
  800718:	85 c0                	test   %eax,%eax
  80071a:	78 37                	js     800753 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80071f:	83 ec 08             	sub    $0x8,%esp
  800722:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800725:	50                   	push   %eax
  800726:	ff 36                	push   (%esi)
  800728:	e8 f1 fc ff ff       	call   80041e <dev_lookup>
  80072d:	83 c4 10             	add    $0x10,%esp
  800730:	85 c0                	test   %eax,%eax
  800732:	78 1f                	js     800753 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800734:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800738:	74 20                	je     80075a <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80073a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80073d:	8b 40 0c             	mov    0xc(%eax),%eax
  800740:	85 c0                	test   %eax,%eax
  800742:	74 37                	je     80077b <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800744:	83 ec 04             	sub    $0x4,%esp
  800747:	ff 75 10             	push   0x10(%ebp)
  80074a:	ff 75 0c             	push   0xc(%ebp)
  80074d:	56                   	push   %esi
  80074e:	ff d0                	call   *%eax
  800750:	83 c4 10             	add    $0x10,%esp
}
  800753:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800756:	5b                   	pop    %ebx
  800757:	5e                   	pop    %esi
  800758:	5d                   	pop    %ebp
  800759:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80075a:	a1 00 40 80 00       	mov    0x804000,%eax
  80075f:	8b 40 48             	mov    0x48(%eax),%eax
  800762:	83 ec 04             	sub    $0x4,%esp
  800765:	53                   	push   %ebx
  800766:	50                   	push   %eax
  800767:	68 f9 1d 80 00       	push   $0x801df9
  80076c:	e8 62 09 00 00       	call   8010d3 <cprintf>
		return -E_INVAL;
  800771:	83 c4 10             	add    $0x10,%esp
  800774:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800779:	eb d8                	jmp    800753 <write+0x53>
		return -E_NOT_SUPP;
  80077b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800780:	eb d1                	jmp    800753 <write+0x53>

00800782 <seek>:

int
seek(int fdnum, off_t offset)
{
  800782:	55                   	push   %ebp
  800783:	89 e5                	mov    %esp,%ebp
  800785:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800788:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80078b:	50                   	push   %eax
  80078c:	ff 75 08             	push   0x8(%ebp)
  80078f:	e8 3a fc ff ff       	call   8003ce <fd_lookup>
  800794:	83 c4 10             	add    $0x10,%esp
  800797:	85 c0                	test   %eax,%eax
  800799:	78 0e                	js     8007a9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80079b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80079e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007a4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007a9:	c9                   	leave  
  8007aa:	c3                   	ret    

008007ab <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007ab:	55                   	push   %ebp
  8007ac:	89 e5                	mov    %esp,%ebp
  8007ae:	56                   	push   %esi
  8007af:	53                   	push   %ebx
  8007b0:	83 ec 18             	sub    $0x18,%esp
  8007b3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b9:	50                   	push   %eax
  8007ba:	53                   	push   %ebx
  8007bb:	e8 0e fc ff ff       	call   8003ce <fd_lookup>
  8007c0:	83 c4 10             	add    $0x10,%esp
  8007c3:	85 c0                	test   %eax,%eax
  8007c5:	78 34                	js     8007fb <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c7:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8007ca:	83 ec 08             	sub    $0x8,%esp
  8007cd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d0:	50                   	push   %eax
  8007d1:	ff 36                	push   (%esi)
  8007d3:	e8 46 fc ff ff       	call   80041e <dev_lookup>
  8007d8:	83 c4 10             	add    $0x10,%esp
  8007db:	85 c0                	test   %eax,%eax
  8007dd:	78 1c                	js     8007fb <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007df:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8007e3:	74 1d                	je     800802 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007e8:	8b 40 18             	mov    0x18(%eax),%eax
  8007eb:	85 c0                	test   %eax,%eax
  8007ed:	74 34                	je     800823 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007ef:	83 ec 08             	sub    $0x8,%esp
  8007f2:	ff 75 0c             	push   0xc(%ebp)
  8007f5:	56                   	push   %esi
  8007f6:	ff d0                	call   *%eax
  8007f8:	83 c4 10             	add    $0x10,%esp
}
  8007fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007fe:	5b                   	pop    %ebx
  8007ff:	5e                   	pop    %esi
  800800:	5d                   	pop    %ebp
  800801:	c3                   	ret    
			thisenv->env_id, fdnum);
  800802:	a1 00 40 80 00       	mov    0x804000,%eax
  800807:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80080a:	83 ec 04             	sub    $0x4,%esp
  80080d:	53                   	push   %ebx
  80080e:	50                   	push   %eax
  80080f:	68 bc 1d 80 00       	push   $0x801dbc
  800814:	e8 ba 08 00 00       	call   8010d3 <cprintf>
		return -E_INVAL;
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800821:	eb d8                	jmp    8007fb <ftruncate+0x50>
		return -E_NOT_SUPP;
  800823:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800828:	eb d1                	jmp    8007fb <ftruncate+0x50>

0080082a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	56                   	push   %esi
  80082e:	53                   	push   %ebx
  80082f:	83 ec 18             	sub    $0x18,%esp
  800832:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800835:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800838:	50                   	push   %eax
  800839:	ff 75 08             	push   0x8(%ebp)
  80083c:	e8 8d fb ff ff       	call   8003ce <fd_lookup>
  800841:	83 c4 10             	add    $0x10,%esp
  800844:	85 c0                	test   %eax,%eax
  800846:	78 49                	js     800891 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800848:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80084b:	83 ec 08             	sub    $0x8,%esp
  80084e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800851:	50                   	push   %eax
  800852:	ff 36                	push   (%esi)
  800854:	e8 c5 fb ff ff       	call   80041e <dev_lookup>
  800859:	83 c4 10             	add    $0x10,%esp
  80085c:	85 c0                	test   %eax,%eax
  80085e:	78 31                	js     800891 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  800860:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800863:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800867:	74 2f                	je     800898 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800869:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80086c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800873:	00 00 00 
	stat->st_isdir = 0;
  800876:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80087d:	00 00 00 
	stat->st_dev = dev;
  800880:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800886:	83 ec 08             	sub    $0x8,%esp
  800889:	53                   	push   %ebx
  80088a:	56                   	push   %esi
  80088b:	ff 50 14             	call   *0x14(%eax)
  80088e:	83 c4 10             	add    $0x10,%esp
}
  800891:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800894:	5b                   	pop    %ebx
  800895:	5e                   	pop    %esi
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    
		return -E_NOT_SUPP;
  800898:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80089d:	eb f2                	jmp    800891 <fstat+0x67>

0080089f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80089f:	55                   	push   %ebp
  8008a0:	89 e5                	mov    %esp,%ebp
  8008a2:	56                   	push   %esi
  8008a3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008a4:	83 ec 08             	sub    $0x8,%esp
  8008a7:	6a 00                	push   $0x0
  8008a9:	ff 75 08             	push   0x8(%ebp)
  8008ac:	e8 e4 01 00 00       	call   800a95 <open>
  8008b1:	89 c3                	mov    %eax,%ebx
  8008b3:	83 c4 10             	add    $0x10,%esp
  8008b6:	85 c0                	test   %eax,%eax
  8008b8:	78 1b                	js     8008d5 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008ba:	83 ec 08             	sub    $0x8,%esp
  8008bd:	ff 75 0c             	push   0xc(%ebp)
  8008c0:	50                   	push   %eax
  8008c1:	e8 64 ff ff ff       	call   80082a <fstat>
  8008c6:	89 c6                	mov    %eax,%esi
	close(fd);
  8008c8:	89 1c 24             	mov    %ebx,(%esp)
  8008cb:	e8 26 fc ff ff       	call   8004f6 <close>
	return r;
  8008d0:	83 c4 10             	add    $0x10,%esp
  8008d3:	89 f3                	mov    %esi,%ebx
}
  8008d5:	89 d8                	mov    %ebx,%eax
  8008d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008da:	5b                   	pop    %ebx
  8008db:	5e                   	pop    %esi
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	56                   	push   %esi
  8008e2:	53                   	push   %ebx
  8008e3:	89 c6                	mov    %eax,%esi
  8008e5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008e7:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8008ee:	74 27                	je     800917 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008f0:	6a 07                	push   $0x7
  8008f2:	68 00 50 80 00       	push   $0x805000
  8008f7:	56                   	push   %esi
  8008f8:	ff 35 00 60 80 00    	push   0x806000
  8008fe:	e8 51 11 00 00       	call   801a54 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800903:	83 c4 0c             	add    $0xc,%esp
  800906:	6a 00                	push   $0x0
  800908:	53                   	push   %ebx
  800909:	6a 00                	push   $0x0
  80090b:	e8 dd 10 00 00       	call   8019ed <ipc_recv>
}
  800910:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800913:	5b                   	pop    %ebx
  800914:	5e                   	pop    %esi
  800915:	5d                   	pop    %ebp
  800916:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800917:	83 ec 0c             	sub    $0xc,%esp
  80091a:	6a 01                	push   $0x1
  80091c:	e8 87 11 00 00       	call   801aa8 <ipc_find_env>
  800921:	a3 00 60 80 00       	mov    %eax,0x806000
  800926:	83 c4 10             	add    $0x10,%esp
  800929:	eb c5                	jmp    8008f0 <fsipc+0x12>

0080092b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	8b 40 0c             	mov    0xc(%eax),%eax
  800937:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80093c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800944:	ba 00 00 00 00       	mov    $0x0,%edx
  800949:	b8 02 00 00 00       	mov    $0x2,%eax
  80094e:	e8 8b ff ff ff       	call   8008de <fsipc>
}
  800953:	c9                   	leave  
  800954:	c3                   	ret    

00800955 <devfile_flush>:
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	8b 40 0c             	mov    0xc(%eax),%eax
  800961:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800966:	ba 00 00 00 00       	mov    $0x0,%edx
  80096b:	b8 06 00 00 00       	mov    $0x6,%eax
  800970:	e8 69 ff ff ff       	call   8008de <fsipc>
}
  800975:	c9                   	leave  
  800976:	c3                   	ret    

00800977 <devfile_stat>:
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	53                   	push   %ebx
  80097b:	83 ec 04             	sub    $0x4,%esp
  80097e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 40 0c             	mov    0xc(%eax),%eax
  800987:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80098c:	ba 00 00 00 00       	mov    $0x0,%edx
  800991:	b8 05 00 00 00       	mov    $0x5,%eax
  800996:	e8 43 ff ff ff       	call   8008de <fsipc>
  80099b:	85 c0                	test   %eax,%eax
  80099d:	78 2c                	js     8009cb <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80099f:	83 ec 08             	sub    $0x8,%esp
  8009a2:	68 00 50 80 00       	push   $0x805000
  8009a7:	53                   	push   %ebx
  8009a8:	e8 00 0d 00 00       	call   8016ad <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ad:	a1 80 50 80 00       	mov    0x805080,%eax
  8009b2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b8:	a1 84 50 80 00       	mov    0x805084,%eax
  8009bd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009c3:	83 c4 10             	add    $0x10,%esp
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ce:	c9                   	leave  
  8009cf:	c3                   	ret    

008009d0 <devfile_write>:
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	83 ec 0c             	sub    $0xc,%esp
  8009d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8009d9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009de:	39 d0                	cmp    %edx,%eax
  8009e0:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e6:	8b 52 0c             	mov    0xc(%edx),%edx
  8009e9:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009ef:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8009f4:	50                   	push   %eax
  8009f5:	ff 75 0c             	push   0xc(%ebp)
  8009f8:	68 08 50 80 00       	push   $0x805008
  8009fd:	e8 41 0e 00 00       	call   801843 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800a02:	ba 00 00 00 00       	mov    $0x0,%edx
  800a07:	b8 04 00 00 00       	mov    $0x4,%eax
  800a0c:	e8 cd fe ff ff       	call   8008de <fsipc>
}
  800a11:	c9                   	leave  
  800a12:	c3                   	ret    

00800a13 <devfile_read>:
{
  800a13:	55                   	push   %ebp
  800a14:	89 e5                	mov    %esp,%ebp
  800a16:	56                   	push   %esi
  800a17:	53                   	push   %ebx
  800a18:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a21:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a26:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a2c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a31:	b8 03 00 00 00       	mov    $0x3,%eax
  800a36:	e8 a3 fe ff ff       	call   8008de <fsipc>
  800a3b:	89 c3                	mov    %eax,%ebx
  800a3d:	85 c0                	test   %eax,%eax
  800a3f:	78 1f                	js     800a60 <devfile_read+0x4d>
	assert(r <= n);
  800a41:	39 f0                	cmp    %esi,%eax
  800a43:	77 24                	ja     800a69 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a45:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a4a:	7f 33                	jg     800a7f <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a4c:	83 ec 04             	sub    $0x4,%esp
  800a4f:	50                   	push   %eax
  800a50:	68 00 50 80 00       	push   $0x805000
  800a55:	ff 75 0c             	push   0xc(%ebp)
  800a58:	e8 e6 0d 00 00       	call   801843 <memmove>
	return r;
  800a5d:	83 c4 10             	add    $0x10,%esp
}
  800a60:	89 d8                	mov    %ebx,%eax
  800a62:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a65:	5b                   	pop    %ebx
  800a66:	5e                   	pop    %esi
  800a67:	5d                   	pop    %ebp
  800a68:	c3                   	ret    
	assert(r <= n);
  800a69:	68 28 1e 80 00       	push   $0x801e28
  800a6e:	68 2f 1e 80 00       	push   $0x801e2f
  800a73:	6a 7c                	push   $0x7c
  800a75:	68 44 1e 80 00       	push   $0x801e44
  800a7a:	e8 79 05 00 00       	call   800ff8 <_panic>
	assert(r <= PGSIZE);
  800a7f:	68 4f 1e 80 00       	push   $0x801e4f
  800a84:	68 2f 1e 80 00       	push   $0x801e2f
  800a89:	6a 7d                	push   $0x7d
  800a8b:	68 44 1e 80 00       	push   $0x801e44
  800a90:	e8 63 05 00 00       	call   800ff8 <_panic>

00800a95 <open>:
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	56                   	push   %esi
  800a99:	53                   	push   %ebx
  800a9a:	83 ec 1c             	sub    $0x1c,%esp
  800a9d:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800aa0:	56                   	push   %esi
  800aa1:	e8 cc 0b 00 00       	call   801672 <strlen>
  800aa6:	83 c4 10             	add    $0x10,%esp
  800aa9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aae:	7f 6c                	jg     800b1c <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800ab0:	83 ec 0c             	sub    $0xc,%esp
  800ab3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ab6:	50                   	push   %eax
  800ab7:	e8 c2 f8 ff ff       	call   80037e <fd_alloc>
  800abc:	89 c3                	mov    %eax,%ebx
  800abe:	83 c4 10             	add    $0x10,%esp
  800ac1:	85 c0                	test   %eax,%eax
  800ac3:	78 3c                	js     800b01 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800ac5:	83 ec 08             	sub    $0x8,%esp
  800ac8:	56                   	push   %esi
  800ac9:	68 00 50 80 00       	push   $0x805000
  800ace:	e8 da 0b 00 00       	call   8016ad <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ad3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad6:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800adb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ade:	b8 01 00 00 00       	mov    $0x1,%eax
  800ae3:	e8 f6 fd ff ff       	call   8008de <fsipc>
  800ae8:	89 c3                	mov    %eax,%ebx
  800aea:	83 c4 10             	add    $0x10,%esp
  800aed:	85 c0                	test   %eax,%eax
  800aef:	78 19                	js     800b0a <open+0x75>
	return fd2num(fd);
  800af1:	83 ec 0c             	sub    $0xc,%esp
  800af4:	ff 75 f4             	push   -0xc(%ebp)
  800af7:	e8 5b f8 ff ff       	call   800357 <fd2num>
  800afc:	89 c3                	mov    %eax,%ebx
  800afe:	83 c4 10             	add    $0x10,%esp
}
  800b01:	89 d8                	mov    %ebx,%eax
  800b03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b06:	5b                   	pop    %ebx
  800b07:	5e                   	pop    %esi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    
		fd_close(fd, 0);
  800b0a:	83 ec 08             	sub    $0x8,%esp
  800b0d:	6a 00                	push   $0x0
  800b0f:	ff 75 f4             	push   -0xc(%ebp)
  800b12:	e8 58 f9 ff ff       	call   80046f <fd_close>
		return r;
  800b17:	83 c4 10             	add    $0x10,%esp
  800b1a:	eb e5                	jmp    800b01 <open+0x6c>
		return -E_BAD_PATH;
  800b1c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b21:	eb de                	jmp    800b01 <open+0x6c>

00800b23 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b23:	55                   	push   %ebp
  800b24:	89 e5                	mov    %esp,%ebp
  800b26:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b29:	ba 00 00 00 00       	mov    $0x0,%edx
  800b2e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b33:	e8 a6 fd ff ff       	call   8008de <fsipc>
}
  800b38:	c9                   	leave  
  800b39:	c3                   	ret    

00800b3a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b3a:	55                   	push   %ebp
  800b3b:	89 e5                	mov    %esp,%ebp
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b42:	83 ec 0c             	sub    $0xc,%esp
  800b45:	ff 75 08             	push   0x8(%ebp)
  800b48:	e8 1a f8 ff ff       	call   800367 <fd2data>
  800b4d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b4f:	83 c4 08             	add    $0x8,%esp
  800b52:	68 5b 1e 80 00       	push   $0x801e5b
  800b57:	53                   	push   %ebx
  800b58:	e8 50 0b 00 00       	call   8016ad <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b5d:	8b 46 04             	mov    0x4(%esi),%eax
  800b60:	2b 06                	sub    (%esi),%eax
  800b62:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b68:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b6f:	00 00 00 
	stat->st_dev = &devpipe;
  800b72:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b79:	30 80 00 
	return 0;
}
  800b7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b84:	5b                   	pop    %ebx
  800b85:	5e                   	pop    %esi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	53                   	push   %ebx
  800b8c:	83 ec 0c             	sub    $0xc,%esp
  800b8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b92:	53                   	push   %ebx
  800b93:	6a 00                	push   $0x0
  800b95:	e8 51 f6 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b9a:	89 1c 24             	mov    %ebx,(%esp)
  800b9d:	e8 c5 f7 ff ff       	call   800367 <fd2data>
  800ba2:	83 c4 08             	add    $0x8,%esp
  800ba5:	50                   	push   %eax
  800ba6:	6a 00                	push   $0x0
  800ba8:	e8 3e f6 ff ff       	call   8001eb <sys_page_unmap>
}
  800bad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bb0:	c9                   	leave  
  800bb1:	c3                   	ret    

00800bb2 <_pipeisclosed>:
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	83 ec 1c             	sub    $0x1c,%esp
  800bbb:	89 c7                	mov    %eax,%edi
  800bbd:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bbf:	a1 00 40 80 00       	mov    0x804000,%eax
  800bc4:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bc7:	83 ec 0c             	sub    $0xc,%esp
  800bca:	57                   	push   %edi
  800bcb:	e8 11 0f 00 00       	call   801ae1 <pageref>
  800bd0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bd3:	89 34 24             	mov    %esi,(%esp)
  800bd6:	e8 06 0f 00 00       	call   801ae1 <pageref>
		nn = thisenv->env_runs;
  800bdb:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800be1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800be4:	83 c4 10             	add    $0x10,%esp
  800be7:	39 cb                	cmp    %ecx,%ebx
  800be9:	74 1b                	je     800c06 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800beb:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800bee:	75 cf                	jne    800bbf <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bf0:	8b 42 58             	mov    0x58(%edx),%eax
  800bf3:	6a 01                	push   $0x1
  800bf5:	50                   	push   %eax
  800bf6:	53                   	push   %ebx
  800bf7:	68 62 1e 80 00       	push   $0x801e62
  800bfc:	e8 d2 04 00 00       	call   8010d3 <cprintf>
  800c01:	83 c4 10             	add    $0x10,%esp
  800c04:	eb b9                	jmp    800bbf <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c06:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c09:	0f 94 c0             	sete   %al
  800c0c:	0f b6 c0             	movzbl %al,%eax
}
  800c0f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c12:	5b                   	pop    %ebx
  800c13:	5e                   	pop    %esi
  800c14:	5f                   	pop    %edi
  800c15:	5d                   	pop    %ebp
  800c16:	c3                   	ret    

00800c17 <devpipe_write>:
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	57                   	push   %edi
  800c1b:	56                   	push   %esi
  800c1c:	53                   	push   %ebx
  800c1d:	83 ec 28             	sub    $0x28,%esp
  800c20:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c23:	56                   	push   %esi
  800c24:	e8 3e f7 ff ff       	call   800367 <fd2data>
  800c29:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c2b:	83 c4 10             	add    $0x10,%esp
  800c2e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c33:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c36:	75 09                	jne    800c41 <devpipe_write+0x2a>
	return i;
  800c38:	89 f8                	mov    %edi,%eax
  800c3a:	eb 23                	jmp    800c5f <devpipe_write+0x48>
			sys_yield();
  800c3c:	e8 06 f5 ff ff       	call   800147 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c41:	8b 43 04             	mov    0x4(%ebx),%eax
  800c44:	8b 0b                	mov    (%ebx),%ecx
  800c46:	8d 51 20             	lea    0x20(%ecx),%edx
  800c49:	39 d0                	cmp    %edx,%eax
  800c4b:	72 1a                	jb     800c67 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  800c4d:	89 da                	mov    %ebx,%edx
  800c4f:	89 f0                	mov    %esi,%eax
  800c51:	e8 5c ff ff ff       	call   800bb2 <_pipeisclosed>
  800c56:	85 c0                	test   %eax,%eax
  800c58:	74 e2                	je     800c3c <devpipe_write+0x25>
				return 0;
  800c5a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c5f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c62:	5b                   	pop    %ebx
  800c63:	5e                   	pop    %esi
  800c64:	5f                   	pop    %edi
  800c65:	5d                   	pop    %ebp
  800c66:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c67:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c6a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c6e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c71:	89 c2                	mov    %eax,%edx
  800c73:	c1 fa 1f             	sar    $0x1f,%edx
  800c76:	89 d1                	mov    %edx,%ecx
  800c78:	c1 e9 1b             	shr    $0x1b,%ecx
  800c7b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c7e:	83 e2 1f             	and    $0x1f,%edx
  800c81:	29 ca                	sub    %ecx,%edx
  800c83:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c87:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c8b:	83 c0 01             	add    $0x1,%eax
  800c8e:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c91:	83 c7 01             	add    $0x1,%edi
  800c94:	eb 9d                	jmp    800c33 <devpipe_write+0x1c>

00800c96 <devpipe_read>:
{
  800c96:	55                   	push   %ebp
  800c97:	89 e5                	mov    %esp,%ebp
  800c99:	57                   	push   %edi
  800c9a:	56                   	push   %esi
  800c9b:	53                   	push   %ebx
  800c9c:	83 ec 18             	sub    $0x18,%esp
  800c9f:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800ca2:	57                   	push   %edi
  800ca3:	e8 bf f6 ff ff       	call   800367 <fd2data>
  800ca8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800caa:	83 c4 10             	add    $0x10,%esp
  800cad:	be 00 00 00 00       	mov    $0x0,%esi
  800cb2:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cb5:	75 13                	jne    800cca <devpipe_read+0x34>
	return i;
  800cb7:	89 f0                	mov    %esi,%eax
  800cb9:	eb 02                	jmp    800cbd <devpipe_read+0x27>
				return i;
  800cbb:	89 f0                	mov    %esi,%eax
}
  800cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    
			sys_yield();
  800cc5:	e8 7d f4 ff ff       	call   800147 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800cca:	8b 03                	mov    (%ebx),%eax
  800ccc:	3b 43 04             	cmp    0x4(%ebx),%eax
  800ccf:	75 18                	jne    800ce9 <devpipe_read+0x53>
			if (i > 0)
  800cd1:	85 f6                	test   %esi,%esi
  800cd3:	75 e6                	jne    800cbb <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  800cd5:	89 da                	mov    %ebx,%edx
  800cd7:	89 f8                	mov    %edi,%eax
  800cd9:	e8 d4 fe ff ff       	call   800bb2 <_pipeisclosed>
  800cde:	85 c0                	test   %eax,%eax
  800ce0:	74 e3                	je     800cc5 <devpipe_read+0x2f>
				return 0;
  800ce2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce7:	eb d4                	jmp    800cbd <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800ce9:	99                   	cltd   
  800cea:	c1 ea 1b             	shr    $0x1b,%edx
  800ced:	01 d0                	add    %edx,%eax
  800cef:	83 e0 1f             	and    $0x1f,%eax
  800cf2:	29 d0                	sub    %edx,%eax
  800cf4:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800cf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfc:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800cff:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d02:	83 c6 01             	add    $0x1,%esi
  800d05:	eb ab                	jmp    800cb2 <devpipe_read+0x1c>

00800d07 <pipe>:
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d0f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d12:	50                   	push   %eax
  800d13:	e8 66 f6 ff ff       	call   80037e <fd_alloc>
  800d18:	89 c3                	mov    %eax,%ebx
  800d1a:	83 c4 10             	add    $0x10,%esp
  800d1d:	85 c0                	test   %eax,%eax
  800d1f:	0f 88 23 01 00 00    	js     800e48 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d25:	83 ec 04             	sub    $0x4,%esp
  800d28:	68 07 04 00 00       	push   $0x407
  800d2d:	ff 75 f4             	push   -0xc(%ebp)
  800d30:	6a 00                	push   $0x0
  800d32:	e8 2f f4 ff ff       	call   800166 <sys_page_alloc>
  800d37:	89 c3                	mov    %eax,%ebx
  800d39:	83 c4 10             	add    $0x10,%esp
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	0f 88 04 01 00 00    	js     800e48 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  800d44:	83 ec 0c             	sub    $0xc,%esp
  800d47:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d4a:	50                   	push   %eax
  800d4b:	e8 2e f6 ff ff       	call   80037e <fd_alloc>
  800d50:	89 c3                	mov    %eax,%ebx
  800d52:	83 c4 10             	add    $0x10,%esp
  800d55:	85 c0                	test   %eax,%eax
  800d57:	0f 88 db 00 00 00    	js     800e38 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d5d:	83 ec 04             	sub    $0x4,%esp
  800d60:	68 07 04 00 00       	push   $0x407
  800d65:	ff 75 f0             	push   -0x10(%ebp)
  800d68:	6a 00                	push   $0x0
  800d6a:	e8 f7 f3 ff ff       	call   800166 <sys_page_alloc>
  800d6f:	89 c3                	mov    %eax,%ebx
  800d71:	83 c4 10             	add    $0x10,%esp
  800d74:	85 c0                	test   %eax,%eax
  800d76:	0f 88 bc 00 00 00    	js     800e38 <pipe+0x131>
	va = fd2data(fd0);
  800d7c:	83 ec 0c             	sub    $0xc,%esp
  800d7f:	ff 75 f4             	push   -0xc(%ebp)
  800d82:	e8 e0 f5 ff ff       	call   800367 <fd2data>
  800d87:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d89:	83 c4 0c             	add    $0xc,%esp
  800d8c:	68 07 04 00 00       	push   $0x407
  800d91:	50                   	push   %eax
  800d92:	6a 00                	push   $0x0
  800d94:	e8 cd f3 ff ff       	call   800166 <sys_page_alloc>
  800d99:	89 c3                	mov    %eax,%ebx
  800d9b:	83 c4 10             	add    $0x10,%esp
  800d9e:	85 c0                	test   %eax,%eax
  800da0:	0f 88 82 00 00 00    	js     800e28 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da6:	83 ec 0c             	sub    $0xc,%esp
  800da9:	ff 75 f0             	push   -0x10(%ebp)
  800dac:	e8 b6 f5 ff ff       	call   800367 <fd2data>
  800db1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800db8:	50                   	push   %eax
  800db9:	6a 00                	push   $0x0
  800dbb:	56                   	push   %esi
  800dbc:	6a 00                	push   $0x0
  800dbe:	e8 e6 f3 ff ff       	call   8001a9 <sys_page_map>
  800dc3:	89 c3                	mov    %eax,%ebx
  800dc5:	83 c4 20             	add    $0x20,%esp
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	78 4e                	js     800e1a <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  800dcc:	a1 20 30 80 00       	mov    0x803020,%eax
  800dd1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dd4:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800dd6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dd9:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800de0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800de3:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800de8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800def:	83 ec 0c             	sub    $0xc,%esp
  800df2:	ff 75 f4             	push   -0xc(%ebp)
  800df5:	e8 5d f5 ff ff       	call   800357 <fd2num>
  800dfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dfd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800dff:	83 c4 04             	add    $0x4,%esp
  800e02:	ff 75 f0             	push   -0x10(%ebp)
  800e05:	e8 4d f5 ff ff       	call   800357 <fd2num>
  800e0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e10:	83 c4 10             	add    $0x10,%esp
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	eb 2e                	jmp    800e48 <pipe+0x141>
	sys_page_unmap(0, va);
  800e1a:	83 ec 08             	sub    $0x8,%esp
  800e1d:	56                   	push   %esi
  800e1e:	6a 00                	push   $0x0
  800e20:	e8 c6 f3 ff ff       	call   8001eb <sys_page_unmap>
  800e25:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e28:	83 ec 08             	sub    $0x8,%esp
  800e2b:	ff 75 f0             	push   -0x10(%ebp)
  800e2e:	6a 00                	push   $0x0
  800e30:	e8 b6 f3 ff ff       	call   8001eb <sys_page_unmap>
  800e35:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e38:	83 ec 08             	sub    $0x8,%esp
  800e3b:	ff 75 f4             	push   -0xc(%ebp)
  800e3e:	6a 00                	push   $0x0
  800e40:	e8 a6 f3 ff ff       	call   8001eb <sys_page_unmap>
  800e45:	83 c4 10             	add    $0x10,%esp
}
  800e48:	89 d8                	mov    %ebx,%eax
  800e4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e4d:	5b                   	pop    %ebx
  800e4e:	5e                   	pop    %esi
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <pipeisclosed>:
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e5a:	50                   	push   %eax
  800e5b:	ff 75 08             	push   0x8(%ebp)
  800e5e:	e8 6b f5 ff ff       	call   8003ce <fd_lookup>
  800e63:	83 c4 10             	add    $0x10,%esp
  800e66:	85 c0                	test   %eax,%eax
  800e68:	78 18                	js     800e82 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e6a:	83 ec 0c             	sub    $0xc,%esp
  800e6d:	ff 75 f4             	push   -0xc(%ebp)
  800e70:	e8 f2 f4 ff ff       	call   800367 <fd2data>
  800e75:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800e77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e7a:	e8 33 fd ff ff       	call   800bb2 <_pipeisclosed>
  800e7f:	83 c4 10             	add    $0x10,%esp
}
  800e82:	c9                   	leave  
  800e83:	c3                   	ret    

00800e84 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  800e84:	b8 00 00 00 00       	mov    $0x0,%eax
  800e89:	c3                   	ret    

00800e8a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
  800e8d:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e90:	68 7a 1e 80 00       	push   $0x801e7a
  800e95:	ff 75 0c             	push   0xc(%ebp)
  800e98:	e8 10 08 00 00       	call   8016ad <strcpy>
	return 0;
}
  800e9d:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea2:	c9                   	leave  
  800ea3:	c3                   	ret    

00800ea4 <devcons_write>:
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	57                   	push   %edi
  800ea8:	56                   	push   %esi
  800ea9:	53                   	push   %ebx
  800eaa:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800eb0:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800eb5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800ebb:	eb 2e                	jmp    800eeb <devcons_write+0x47>
		m = n - tot;
  800ebd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ec0:	29 f3                	sub    %esi,%ebx
  800ec2:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800ec7:	39 c3                	cmp    %eax,%ebx
  800ec9:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ecc:	83 ec 04             	sub    $0x4,%esp
  800ecf:	53                   	push   %ebx
  800ed0:	89 f0                	mov    %esi,%eax
  800ed2:	03 45 0c             	add    0xc(%ebp),%eax
  800ed5:	50                   	push   %eax
  800ed6:	57                   	push   %edi
  800ed7:	e8 67 09 00 00       	call   801843 <memmove>
		sys_cputs(buf, m);
  800edc:	83 c4 08             	add    $0x8,%esp
  800edf:	53                   	push   %ebx
  800ee0:	57                   	push   %edi
  800ee1:	e8 c4 f1 ff ff       	call   8000aa <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800ee6:	01 de                	add    %ebx,%esi
  800ee8:	83 c4 10             	add    $0x10,%esp
  800eeb:	3b 75 10             	cmp    0x10(%ebp),%esi
  800eee:	72 cd                	jb     800ebd <devcons_write+0x19>
}
  800ef0:	89 f0                	mov    %esi,%eax
  800ef2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef5:	5b                   	pop    %ebx
  800ef6:	5e                   	pop    %esi
  800ef7:	5f                   	pop    %edi
  800ef8:	5d                   	pop    %ebp
  800ef9:	c3                   	ret    

00800efa <devcons_read>:
{
  800efa:	55                   	push   %ebp
  800efb:	89 e5                	mov    %esp,%ebp
  800efd:	83 ec 08             	sub    $0x8,%esp
  800f00:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f05:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f09:	75 07                	jne    800f12 <devcons_read+0x18>
  800f0b:	eb 1f                	jmp    800f2c <devcons_read+0x32>
		sys_yield();
  800f0d:	e8 35 f2 ff ff       	call   800147 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f12:	e8 b1 f1 ff ff       	call   8000c8 <sys_cgetc>
  800f17:	85 c0                	test   %eax,%eax
  800f19:	74 f2                	je     800f0d <devcons_read+0x13>
	if (c < 0)
  800f1b:	78 0f                	js     800f2c <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  800f1d:	83 f8 04             	cmp    $0x4,%eax
  800f20:	74 0c                	je     800f2e <devcons_read+0x34>
	*(char*)vbuf = c;
  800f22:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f25:	88 02                	mov    %al,(%edx)
	return 1;
  800f27:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f2c:	c9                   	leave  
  800f2d:	c3                   	ret    
		return 0;
  800f2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f33:	eb f7                	jmp    800f2c <devcons_read+0x32>

00800f35 <cputchar>:
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f41:	6a 01                	push   $0x1
  800f43:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f46:	50                   	push   %eax
  800f47:	e8 5e f1 ff ff       	call   8000aa <sys_cputs>
}
  800f4c:	83 c4 10             	add    $0x10,%esp
  800f4f:	c9                   	leave  
  800f50:	c3                   	ret    

00800f51 <getchar>:
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f57:	6a 01                	push   $0x1
  800f59:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f5c:	50                   	push   %eax
  800f5d:	6a 00                	push   $0x0
  800f5f:	e8 ce f6 ff ff       	call   800632 <read>
	if (r < 0)
  800f64:	83 c4 10             	add    $0x10,%esp
  800f67:	85 c0                	test   %eax,%eax
  800f69:	78 06                	js     800f71 <getchar+0x20>
	if (r < 1)
  800f6b:	74 06                	je     800f73 <getchar+0x22>
	return c;
  800f6d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800f71:	c9                   	leave  
  800f72:	c3                   	ret    
		return -E_EOF;
  800f73:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800f78:	eb f7                	jmp    800f71 <getchar+0x20>

00800f7a <iscons>:
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f80:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f83:	50                   	push   %eax
  800f84:	ff 75 08             	push   0x8(%ebp)
  800f87:	e8 42 f4 ff ff       	call   8003ce <fd_lookup>
  800f8c:	83 c4 10             	add    $0x10,%esp
  800f8f:	85 c0                	test   %eax,%eax
  800f91:	78 11                	js     800fa4 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800f93:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f96:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f9c:	39 10                	cmp    %edx,(%eax)
  800f9e:	0f 94 c0             	sete   %al
  800fa1:	0f b6 c0             	movzbl %al,%eax
}
  800fa4:	c9                   	leave  
  800fa5:	c3                   	ret    

00800fa6 <opencons>:
{
  800fa6:	55                   	push   %ebp
  800fa7:	89 e5                	mov    %esp,%ebp
  800fa9:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fac:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800faf:	50                   	push   %eax
  800fb0:	e8 c9 f3 ff ff       	call   80037e <fd_alloc>
  800fb5:	83 c4 10             	add    $0x10,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	78 3a                	js     800ff6 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fbc:	83 ec 04             	sub    $0x4,%esp
  800fbf:	68 07 04 00 00       	push   $0x407
  800fc4:	ff 75 f4             	push   -0xc(%ebp)
  800fc7:	6a 00                	push   $0x0
  800fc9:	e8 98 f1 ff ff       	call   800166 <sys_page_alloc>
  800fce:	83 c4 10             	add    $0x10,%esp
  800fd1:	85 c0                	test   %eax,%eax
  800fd3:	78 21                	js     800ff6 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800fd5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fde:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fe0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fea:	83 ec 0c             	sub    $0xc,%esp
  800fed:	50                   	push   %eax
  800fee:	e8 64 f3 ff ff       	call   800357 <fd2num>
  800ff3:	83 c4 10             	add    $0x10,%esp
}
  800ff6:	c9                   	leave  
  800ff7:	c3                   	ret    

00800ff8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
  800ffb:	56                   	push   %esi
  800ffc:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ffd:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801000:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801006:	e8 1d f1 ff ff       	call   800128 <sys_getenvid>
  80100b:	83 ec 0c             	sub    $0xc,%esp
  80100e:	ff 75 0c             	push   0xc(%ebp)
  801011:	ff 75 08             	push   0x8(%ebp)
  801014:	56                   	push   %esi
  801015:	50                   	push   %eax
  801016:	68 88 1e 80 00       	push   $0x801e88
  80101b:	e8 b3 00 00 00       	call   8010d3 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801020:	83 c4 18             	add    $0x18,%esp
  801023:	53                   	push   %ebx
  801024:	ff 75 10             	push   0x10(%ebp)
  801027:	e8 56 00 00 00       	call   801082 <vcprintf>
	cprintf("\n");
  80102c:	c7 04 24 73 1e 80 00 	movl   $0x801e73,(%esp)
  801033:	e8 9b 00 00 00       	call   8010d3 <cprintf>
  801038:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80103b:	cc                   	int3   
  80103c:	eb fd                	jmp    80103b <_panic+0x43>

0080103e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	53                   	push   %ebx
  801042:	83 ec 04             	sub    $0x4,%esp
  801045:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801048:	8b 13                	mov    (%ebx),%edx
  80104a:	8d 42 01             	lea    0x1(%edx),%eax
  80104d:	89 03                	mov    %eax,(%ebx)
  80104f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801052:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801056:	3d ff 00 00 00       	cmp    $0xff,%eax
  80105b:	74 09                	je     801066 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80105d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801061:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801064:	c9                   	leave  
  801065:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801066:	83 ec 08             	sub    $0x8,%esp
  801069:	68 ff 00 00 00       	push   $0xff
  80106e:	8d 43 08             	lea    0x8(%ebx),%eax
  801071:	50                   	push   %eax
  801072:	e8 33 f0 ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  801077:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80107d:	83 c4 10             	add    $0x10,%esp
  801080:	eb db                	jmp    80105d <putch+0x1f>

00801082 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801082:	55                   	push   %ebp
  801083:	89 e5                	mov    %esp,%ebp
  801085:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80108b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801092:	00 00 00 
	b.cnt = 0;
  801095:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80109c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80109f:	ff 75 0c             	push   0xc(%ebp)
  8010a2:	ff 75 08             	push   0x8(%ebp)
  8010a5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010ab:	50                   	push   %eax
  8010ac:	68 3e 10 80 00       	push   $0x80103e
  8010b1:	e8 14 01 00 00       	call   8011ca <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010b6:	83 c4 08             	add    $0x8,%esp
  8010b9:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8010bf:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010c5:	50                   	push   %eax
  8010c6:	e8 df ef ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  8010cb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010d1:	c9                   	leave  
  8010d2:	c3                   	ret    

008010d3 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010d9:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010dc:	50                   	push   %eax
  8010dd:	ff 75 08             	push   0x8(%ebp)
  8010e0:	e8 9d ff ff ff       	call   801082 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010e5:	c9                   	leave  
  8010e6:	c3                   	ret    

008010e7 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	57                   	push   %edi
  8010eb:	56                   	push   %esi
  8010ec:	53                   	push   %ebx
  8010ed:	83 ec 1c             	sub    $0x1c,%esp
  8010f0:	89 c7                	mov    %eax,%edi
  8010f2:	89 d6                	mov    %edx,%esi
  8010f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010fa:	89 d1                	mov    %edx,%ecx
  8010fc:	89 c2                	mov    %eax,%edx
  8010fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801101:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801104:	8b 45 10             	mov    0x10(%ebp),%eax
  801107:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80110a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80110d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801114:	39 c2                	cmp    %eax,%edx
  801116:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801119:	72 3e                	jb     801159 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80111b:	83 ec 0c             	sub    $0xc,%esp
  80111e:	ff 75 18             	push   0x18(%ebp)
  801121:	83 eb 01             	sub    $0x1,%ebx
  801124:	53                   	push   %ebx
  801125:	50                   	push   %eax
  801126:	83 ec 08             	sub    $0x8,%esp
  801129:	ff 75 e4             	push   -0x1c(%ebp)
  80112c:	ff 75 e0             	push   -0x20(%ebp)
  80112f:	ff 75 dc             	push   -0x24(%ebp)
  801132:	ff 75 d8             	push   -0x28(%ebp)
  801135:	e8 e6 09 00 00       	call   801b20 <__udivdi3>
  80113a:	83 c4 18             	add    $0x18,%esp
  80113d:	52                   	push   %edx
  80113e:	50                   	push   %eax
  80113f:	89 f2                	mov    %esi,%edx
  801141:	89 f8                	mov    %edi,%eax
  801143:	e8 9f ff ff ff       	call   8010e7 <printnum>
  801148:	83 c4 20             	add    $0x20,%esp
  80114b:	eb 13                	jmp    801160 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80114d:	83 ec 08             	sub    $0x8,%esp
  801150:	56                   	push   %esi
  801151:	ff 75 18             	push   0x18(%ebp)
  801154:	ff d7                	call   *%edi
  801156:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801159:	83 eb 01             	sub    $0x1,%ebx
  80115c:	85 db                	test   %ebx,%ebx
  80115e:	7f ed                	jg     80114d <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801160:	83 ec 08             	sub    $0x8,%esp
  801163:	56                   	push   %esi
  801164:	83 ec 04             	sub    $0x4,%esp
  801167:	ff 75 e4             	push   -0x1c(%ebp)
  80116a:	ff 75 e0             	push   -0x20(%ebp)
  80116d:	ff 75 dc             	push   -0x24(%ebp)
  801170:	ff 75 d8             	push   -0x28(%ebp)
  801173:	e8 c8 0a 00 00       	call   801c40 <__umoddi3>
  801178:	83 c4 14             	add    $0x14,%esp
  80117b:	0f be 80 ab 1e 80 00 	movsbl 0x801eab(%eax),%eax
  801182:	50                   	push   %eax
  801183:	ff d7                	call   *%edi
}
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118b:	5b                   	pop    %ebx
  80118c:	5e                   	pop    %esi
  80118d:	5f                   	pop    %edi
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    

00801190 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801196:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80119a:	8b 10                	mov    (%eax),%edx
  80119c:	3b 50 04             	cmp    0x4(%eax),%edx
  80119f:	73 0a                	jae    8011ab <sprintputch+0x1b>
		*b->buf++ = ch;
  8011a1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011a4:	89 08                	mov    %ecx,(%eax)
  8011a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011a9:	88 02                	mov    %al,(%edx)
}
  8011ab:	5d                   	pop    %ebp
  8011ac:	c3                   	ret    

008011ad <printfmt>:
{
  8011ad:	55                   	push   %ebp
  8011ae:	89 e5                	mov    %esp,%ebp
  8011b0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011b3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011b6:	50                   	push   %eax
  8011b7:	ff 75 10             	push   0x10(%ebp)
  8011ba:	ff 75 0c             	push   0xc(%ebp)
  8011bd:	ff 75 08             	push   0x8(%ebp)
  8011c0:	e8 05 00 00 00       	call   8011ca <vprintfmt>
}
  8011c5:	83 c4 10             	add    $0x10,%esp
  8011c8:	c9                   	leave  
  8011c9:	c3                   	ret    

008011ca <vprintfmt>:
{
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
  8011cd:	57                   	push   %edi
  8011ce:	56                   	push   %esi
  8011cf:	53                   	push   %ebx
  8011d0:	83 ec 3c             	sub    $0x3c,%esp
  8011d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8011d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011d9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011dc:	eb 0a                	jmp    8011e8 <vprintfmt+0x1e>
			putch(ch, putdat);
  8011de:	83 ec 08             	sub    $0x8,%esp
  8011e1:	53                   	push   %ebx
  8011e2:	50                   	push   %eax
  8011e3:	ff d6                	call   *%esi
  8011e5:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8011e8:	83 c7 01             	add    $0x1,%edi
  8011eb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8011ef:	83 f8 25             	cmp    $0x25,%eax
  8011f2:	74 0c                	je     801200 <vprintfmt+0x36>
			if (ch == '\0')
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	75 e6                	jne    8011de <vprintfmt+0x14>
}
  8011f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fb:	5b                   	pop    %ebx
  8011fc:	5e                   	pop    %esi
  8011fd:	5f                   	pop    %edi
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    
		padc = ' ';
  801200:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  801204:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80120b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801212:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801219:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80121e:	8d 47 01             	lea    0x1(%edi),%eax
  801221:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801224:	0f b6 17             	movzbl (%edi),%edx
  801227:	8d 42 dd             	lea    -0x23(%edx),%eax
  80122a:	3c 55                	cmp    $0x55,%al
  80122c:	0f 87 bb 03 00 00    	ja     8015ed <vprintfmt+0x423>
  801232:	0f b6 c0             	movzbl %al,%eax
  801235:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  80123c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80123f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801243:	eb d9                	jmp    80121e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801245:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801248:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80124c:	eb d0                	jmp    80121e <vprintfmt+0x54>
  80124e:	0f b6 d2             	movzbl %dl,%edx
  801251:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801254:	b8 00 00 00 00       	mov    $0x0,%eax
  801259:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80125c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80125f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801263:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801266:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801269:	83 f9 09             	cmp    $0x9,%ecx
  80126c:	77 55                	ja     8012c3 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80126e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801271:	eb e9                	jmp    80125c <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801273:	8b 45 14             	mov    0x14(%ebp),%eax
  801276:	8b 00                	mov    (%eax),%eax
  801278:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80127b:	8b 45 14             	mov    0x14(%ebp),%eax
  80127e:	8d 40 04             	lea    0x4(%eax),%eax
  801281:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801284:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801287:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80128b:	79 91                	jns    80121e <vprintfmt+0x54>
				width = precision, precision = -1;
  80128d:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801290:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801293:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80129a:	eb 82                	jmp    80121e <vprintfmt+0x54>
  80129c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80129f:	85 d2                	test   %edx,%edx
  8012a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012a6:	0f 49 c2             	cmovns %edx,%eax
  8012a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012af:	e9 6a ff ff ff       	jmp    80121e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8012b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012b7:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8012be:	e9 5b ff ff ff       	jmp    80121e <vprintfmt+0x54>
  8012c3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012c9:	eb bc                	jmp    801287 <vprintfmt+0xbd>
			lflag++;
  8012cb:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012d1:	e9 48 ff ff ff       	jmp    80121e <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8012d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8012d9:	8d 78 04             	lea    0x4(%eax),%edi
  8012dc:	83 ec 08             	sub    $0x8,%esp
  8012df:	53                   	push   %ebx
  8012e0:	ff 30                	push   (%eax)
  8012e2:	ff d6                	call   *%esi
			break;
  8012e4:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8012e7:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8012ea:	e9 9d 02 00 00       	jmp    80158c <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8012ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f2:	8d 78 04             	lea    0x4(%eax),%edi
  8012f5:	8b 10                	mov    (%eax),%edx
  8012f7:	89 d0                	mov    %edx,%eax
  8012f9:	f7 d8                	neg    %eax
  8012fb:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8012fe:	83 f8 0f             	cmp    $0xf,%eax
  801301:	7f 23                	jg     801326 <vprintfmt+0x15c>
  801303:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  80130a:	85 d2                	test   %edx,%edx
  80130c:	74 18                	je     801326 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80130e:	52                   	push   %edx
  80130f:	68 41 1e 80 00       	push   $0x801e41
  801314:	53                   	push   %ebx
  801315:	56                   	push   %esi
  801316:	e8 92 fe ff ff       	call   8011ad <printfmt>
  80131b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80131e:	89 7d 14             	mov    %edi,0x14(%ebp)
  801321:	e9 66 02 00 00       	jmp    80158c <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  801326:	50                   	push   %eax
  801327:	68 c3 1e 80 00       	push   $0x801ec3
  80132c:	53                   	push   %ebx
  80132d:	56                   	push   %esi
  80132e:	e8 7a fe ff ff       	call   8011ad <printfmt>
  801333:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801336:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801339:	e9 4e 02 00 00       	jmp    80158c <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80133e:	8b 45 14             	mov    0x14(%ebp),%eax
  801341:	83 c0 04             	add    $0x4,%eax
  801344:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801347:	8b 45 14             	mov    0x14(%ebp),%eax
  80134a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80134c:	85 d2                	test   %edx,%edx
  80134e:	b8 bc 1e 80 00       	mov    $0x801ebc,%eax
  801353:	0f 45 c2             	cmovne %edx,%eax
  801356:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801359:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80135d:	7e 06                	jle    801365 <vprintfmt+0x19b>
  80135f:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801363:	75 0d                	jne    801372 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801365:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801368:	89 c7                	mov    %eax,%edi
  80136a:	03 45 e0             	add    -0x20(%ebp),%eax
  80136d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801370:	eb 55                	jmp    8013c7 <vprintfmt+0x1fd>
  801372:	83 ec 08             	sub    $0x8,%esp
  801375:	ff 75 d8             	push   -0x28(%ebp)
  801378:	ff 75 cc             	push   -0x34(%ebp)
  80137b:	e8 0a 03 00 00       	call   80168a <strnlen>
  801380:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801383:	29 c1                	sub    %eax,%ecx
  801385:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80138d:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801391:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801394:	eb 0f                	jmp    8013a5 <vprintfmt+0x1db>
					putch(padc, putdat);
  801396:	83 ec 08             	sub    $0x8,%esp
  801399:	53                   	push   %ebx
  80139a:	ff 75 e0             	push   -0x20(%ebp)
  80139d:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80139f:	83 ef 01             	sub    $0x1,%edi
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	85 ff                	test   %edi,%edi
  8013a7:	7f ed                	jg     801396 <vprintfmt+0x1cc>
  8013a9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8013ac:	85 d2                	test   %edx,%edx
  8013ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8013b3:	0f 49 c2             	cmovns %edx,%eax
  8013b6:	29 c2                	sub    %eax,%edx
  8013b8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8013bb:	eb a8                	jmp    801365 <vprintfmt+0x19b>
					putch(ch, putdat);
  8013bd:	83 ec 08             	sub    $0x8,%esp
  8013c0:	53                   	push   %ebx
  8013c1:	52                   	push   %edx
  8013c2:	ff d6                	call   *%esi
  8013c4:	83 c4 10             	add    $0x10,%esp
  8013c7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013ca:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013cc:	83 c7 01             	add    $0x1,%edi
  8013cf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8013d3:	0f be d0             	movsbl %al,%edx
  8013d6:	85 d2                	test   %edx,%edx
  8013d8:	74 4b                	je     801425 <vprintfmt+0x25b>
  8013da:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013de:	78 06                	js     8013e6 <vprintfmt+0x21c>
  8013e0:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8013e4:	78 1e                	js     801404 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8013e6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8013ea:	74 d1                	je     8013bd <vprintfmt+0x1f3>
  8013ec:	0f be c0             	movsbl %al,%eax
  8013ef:	83 e8 20             	sub    $0x20,%eax
  8013f2:	83 f8 5e             	cmp    $0x5e,%eax
  8013f5:	76 c6                	jbe    8013bd <vprintfmt+0x1f3>
					putch('?', putdat);
  8013f7:	83 ec 08             	sub    $0x8,%esp
  8013fa:	53                   	push   %ebx
  8013fb:	6a 3f                	push   $0x3f
  8013fd:	ff d6                	call   *%esi
  8013ff:	83 c4 10             	add    $0x10,%esp
  801402:	eb c3                	jmp    8013c7 <vprintfmt+0x1fd>
  801404:	89 cf                	mov    %ecx,%edi
  801406:	eb 0e                	jmp    801416 <vprintfmt+0x24c>
				putch(' ', putdat);
  801408:	83 ec 08             	sub    $0x8,%esp
  80140b:	53                   	push   %ebx
  80140c:	6a 20                	push   $0x20
  80140e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801410:	83 ef 01             	sub    $0x1,%edi
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	85 ff                	test   %edi,%edi
  801418:	7f ee                	jg     801408 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80141a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80141d:	89 45 14             	mov    %eax,0x14(%ebp)
  801420:	e9 67 01 00 00       	jmp    80158c <vprintfmt+0x3c2>
  801425:	89 cf                	mov    %ecx,%edi
  801427:	eb ed                	jmp    801416 <vprintfmt+0x24c>
	if (lflag >= 2)
  801429:	83 f9 01             	cmp    $0x1,%ecx
  80142c:	7f 1b                	jg     801449 <vprintfmt+0x27f>
	else if (lflag)
  80142e:	85 c9                	test   %ecx,%ecx
  801430:	74 63                	je     801495 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  801432:	8b 45 14             	mov    0x14(%ebp),%eax
  801435:	8b 00                	mov    (%eax),%eax
  801437:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80143a:	99                   	cltd   
  80143b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80143e:	8b 45 14             	mov    0x14(%ebp),%eax
  801441:	8d 40 04             	lea    0x4(%eax),%eax
  801444:	89 45 14             	mov    %eax,0x14(%ebp)
  801447:	eb 17                	jmp    801460 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801449:	8b 45 14             	mov    0x14(%ebp),%eax
  80144c:	8b 50 04             	mov    0x4(%eax),%edx
  80144f:	8b 00                	mov    (%eax),%eax
  801451:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801454:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801457:	8b 45 14             	mov    0x14(%ebp),%eax
  80145a:	8d 40 08             	lea    0x8(%eax),%eax
  80145d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801460:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801463:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801466:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80146b:	85 c9                	test   %ecx,%ecx
  80146d:	0f 89 ff 00 00 00    	jns    801572 <vprintfmt+0x3a8>
				putch('-', putdat);
  801473:	83 ec 08             	sub    $0x8,%esp
  801476:	53                   	push   %ebx
  801477:	6a 2d                	push   $0x2d
  801479:	ff d6                	call   *%esi
				num = -(long long) num;
  80147b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80147e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801481:	f7 da                	neg    %edx
  801483:	83 d1 00             	adc    $0x0,%ecx
  801486:	f7 d9                	neg    %ecx
  801488:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80148b:	bf 0a 00 00 00       	mov    $0xa,%edi
  801490:	e9 dd 00 00 00       	jmp    801572 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801495:	8b 45 14             	mov    0x14(%ebp),%eax
  801498:	8b 00                	mov    (%eax),%eax
  80149a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80149d:	99                   	cltd   
  80149e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a4:	8d 40 04             	lea    0x4(%eax),%eax
  8014a7:	89 45 14             	mov    %eax,0x14(%ebp)
  8014aa:	eb b4                	jmp    801460 <vprintfmt+0x296>
	if (lflag >= 2)
  8014ac:	83 f9 01             	cmp    $0x1,%ecx
  8014af:	7f 1e                	jg     8014cf <vprintfmt+0x305>
	else if (lflag)
  8014b1:	85 c9                	test   %ecx,%ecx
  8014b3:	74 32                	je     8014e7 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8014b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b8:	8b 10                	mov    (%eax),%edx
  8014ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014bf:	8d 40 04             	lea    0x4(%eax),%eax
  8014c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014c5:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8014ca:	e9 a3 00 00 00       	jmp    801572 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8014cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d2:	8b 10                	mov    (%eax),%edx
  8014d4:	8b 48 04             	mov    0x4(%eax),%ecx
  8014d7:	8d 40 08             	lea    0x8(%eax),%eax
  8014da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014dd:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8014e2:	e9 8b 00 00 00       	jmp    801572 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8014e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ea:	8b 10                	mov    (%eax),%edx
  8014ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014f1:	8d 40 04             	lea    0x4(%eax),%eax
  8014f4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014f7:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8014fc:	eb 74                	jmp    801572 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8014fe:	83 f9 01             	cmp    $0x1,%ecx
  801501:	7f 1b                	jg     80151e <vprintfmt+0x354>
	else if (lflag)
  801503:	85 c9                	test   %ecx,%ecx
  801505:	74 2c                	je     801533 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  801507:	8b 45 14             	mov    0x14(%ebp),%eax
  80150a:	8b 10                	mov    (%eax),%edx
  80150c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801511:	8d 40 04             	lea    0x4(%eax),%eax
  801514:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801517:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80151c:	eb 54                	jmp    801572 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80151e:	8b 45 14             	mov    0x14(%ebp),%eax
  801521:	8b 10                	mov    (%eax),%edx
  801523:	8b 48 04             	mov    0x4(%eax),%ecx
  801526:	8d 40 08             	lea    0x8(%eax),%eax
  801529:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80152c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  801531:	eb 3f                	jmp    801572 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801533:	8b 45 14             	mov    0x14(%ebp),%eax
  801536:	8b 10                	mov    (%eax),%edx
  801538:	b9 00 00 00 00       	mov    $0x0,%ecx
  80153d:	8d 40 04             	lea    0x4(%eax),%eax
  801540:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801543:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801548:	eb 28                	jmp    801572 <vprintfmt+0x3a8>
			putch('0', putdat);
  80154a:	83 ec 08             	sub    $0x8,%esp
  80154d:	53                   	push   %ebx
  80154e:	6a 30                	push   $0x30
  801550:	ff d6                	call   *%esi
			putch('x', putdat);
  801552:	83 c4 08             	add    $0x8,%esp
  801555:	53                   	push   %ebx
  801556:	6a 78                	push   $0x78
  801558:	ff d6                	call   *%esi
			num = (unsigned long long)
  80155a:	8b 45 14             	mov    0x14(%ebp),%eax
  80155d:	8b 10                	mov    (%eax),%edx
  80155f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801564:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801567:	8d 40 04             	lea    0x4(%eax),%eax
  80156a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80156d:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801572:	83 ec 0c             	sub    $0xc,%esp
  801575:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801579:	50                   	push   %eax
  80157a:	ff 75 e0             	push   -0x20(%ebp)
  80157d:	57                   	push   %edi
  80157e:	51                   	push   %ecx
  80157f:	52                   	push   %edx
  801580:	89 da                	mov    %ebx,%edx
  801582:	89 f0                	mov    %esi,%eax
  801584:	e8 5e fb ff ff       	call   8010e7 <printnum>
			break;
  801589:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80158c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80158f:	e9 54 fc ff ff       	jmp    8011e8 <vprintfmt+0x1e>
	if (lflag >= 2)
  801594:	83 f9 01             	cmp    $0x1,%ecx
  801597:	7f 1b                	jg     8015b4 <vprintfmt+0x3ea>
	else if (lflag)
  801599:	85 c9                	test   %ecx,%ecx
  80159b:	74 2c                	je     8015c9 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  80159d:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a0:	8b 10                	mov    (%eax),%edx
  8015a2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015a7:	8d 40 04             	lea    0x4(%eax),%eax
  8015aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015ad:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8015b2:	eb be                	jmp    801572 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8015b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b7:	8b 10                	mov    (%eax),%edx
  8015b9:	8b 48 04             	mov    0x4(%eax),%ecx
  8015bc:	8d 40 08             	lea    0x8(%eax),%eax
  8015bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015c2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8015c7:	eb a9                	jmp    801572 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8015c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8015cc:	8b 10                	mov    (%eax),%edx
  8015ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015d3:	8d 40 04             	lea    0x4(%eax),%eax
  8015d6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015d9:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8015de:	eb 92                	jmp    801572 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8015e0:	83 ec 08             	sub    $0x8,%esp
  8015e3:	53                   	push   %ebx
  8015e4:	6a 25                	push   $0x25
  8015e6:	ff d6                	call   *%esi
			break;
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	eb 9f                	jmp    80158c <vprintfmt+0x3c2>
			putch('%', putdat);
  8015ed:	83 ec 08             	sub    $0x8,%esp
  8015f0:	53                   	push   %ebx
  8015f1:	6a 25                	push   $0x25
  8015f3:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015f5:	83 c4 10             	add    $0x10,%esp
  8015f8:	89 f8                	mov    %edi,%eax
  8015fa:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8015fe:	74 05                	je     801605 <vprintfmt+0x43b>
  801600:	83 e8 01             	sub    $0x1,%eax
  801603:	eb f5                	jmp    8015fa <vprintfmt+0x430>
  801605:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801608:	eb 82                	jmp    80158c <vprintfmt+0x3c2>

0080160a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80160a:	55                   	push   %ebp
  80160b:	89 e5                	mov    %esp,%ebp
  80160d:	83 ec 18             	sub    $0x18,%esp
  801610:	8b 45 08             	mov    0x8(%ebp),%eax
  801613:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801616:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801619:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80161d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801620:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801627:	85 c0                	test   %eax,%eax
  801629:	74 26                	je     801651 <vsnprintf+0x47>
  80162b:	85 d2                	test   %edx,%edx
  80162d:	7e 22                	jle    801651 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80162f:	ff 75 14             	push   0x14(%ebp)
  801632:	ff 75 10             	push   0x10(%ebp)
  801635:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801638:	50                   	push   %eax
  801639:	68 90 11 80 00       	push   $0x801190
  80163e:	e8 87 fb ff ff       	call   8011ca <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801643:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801646:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801649:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80164c:	83 c4 10             	add    $0x10,%esp
}
  80164f:	c9                   	leave  
  801650:	c3                   	ret    
		return -E_INVAL;
  801651:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801656:	eb f7                	jmp    80164f <vsnprintf+0x45>

00801658 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
  80165b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80165e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801661:	50                   	push   %eax
  801662:	ff 75 10             	push   0x10(%ebp)
  801665:	ff 75 0c             	push   0xc(%ebp)
  801668:	ff 75 08             	push   0x8(%ebp)
  80166b:	e8 9a ff ff ff       	call   80160a <vsnprintf>
	va_end(ap);

	return rc;
}
  801670:	c9                   	leave  
  801671:	c3                   	ret    

00801672 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801672:	55                   	push   %ebp
  801673:	89 e5                	mov    %esp,%ebp
  801675:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801678:	b8 00 00 00 00       	mov    $0x0,%eax
  80167d:	eb 03                	jmp    801682 <strlen+0x10>
		n++;
  80167f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801682:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801686:	75 f7                	jne    80167f <strlen+0xd>
	return n;
}
  801688:	5d                   	pop    %ebp
  801689:	c3                   	ret    

0080168a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
  80168d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801690:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801693:	b8 00 00 00 00       	mov    $0x0,%eax
  801698:	eb 03                	jmp    80169d <strnlen+0x13>
		n++;
  80169a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80169d:	39 d0                	cmp    %edx,%eax
  80169f:	74 08                	je     8016a9 <strnlen+0x1f>
  8016a1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016a5:	75 f3                	jne    80169a <strnlen+0x10>
  8016a7:	89 c2                	mov    %eax,%edx
	return n;
}
  8016a9:	89 d0                	mov    %edx,%eax
  8016ab:	5d                   	pop    %ebp
  8016ac:	c3                   	ret    

008016ad <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	53                   	push   %ebx
  8016b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016bc:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016c0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016c3:	83 c0 01             	add    $0x1,%eax
  8016c6:	84 d2                	test   %dl,%dl
  8016c8:	75 f2                	jne    8016bc <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8016ca:	89 c8                	mov    %ecx,%eax
  8016cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016cf:	c9                   	leave  
  8016d0:	c3                   	ret    

008016d1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	53                   	push   %ebx
  8016d5:	83 ec 10             	sub    $0x10,%esp
  8016d8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016db:	53                   	push   %ebx
  8016dc:	e8 91 ff ff ff       	call   801672 <strlen>
  8016e1:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8016e4:	ff 75 0c             	push   0xc(%ebp)
  8016e7:	01 d8                	add    %ebx,%eax
  8016e9:	50                   	push   %eax
  8016ea:	e8 be ff ff ff       	call   8016ad <strcpy>
	return dst;
}
  8016ef:	89 d8                	mov    %ebx,%eax
  8016f1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f4:	c9                   	leave  
  8016f5:	c3                   	ret    

008016f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	56                   	push   %esi
  8016fa:	53                   	push   %ebx
  8016fb:	8b 75 08             	mov    0x8(%ebp),%esi
  8016fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801701:	89 f3                	mov    %esi,%ebx
  801703:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801706:	89 f0                	mov    %esi,%eax
  801708:	eb 0f                	jmp    801719 <strncpy+0x23>
		*dst++ = *src;
  80170a:	83 c0 01             	add    $0x1,%eax
  80170d:	0f b6 0a             	movzbl (%edx),%ecx
  801710:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801713:	80 f9 01             	cmp    $0x1,%cl
  801716:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801719:	39 d8                	cmp    %ebx,%eax
  80171b:	75 ed                	jne    80170a <strncpy+0x14>
	}
	return ret;
}
  80171d:	89 f0                	mov    %esi,%eax
  80171f:	5b                   	pop    %ebx
  801720:	5e                   	pop    %esi
  801721:	5d                   	pop    %ebp
  801722:	c3                   	ret    

00801723 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801723:	55                   	push   %ebp
  801724:	89 e5                	mov    %esp,%ebp
  801726:	56                   	push   %esi
  801727:	53                   	push   %ebx
  801728:	8b 75 08             	mov    0x8(%ebp),%esi
  80172b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172e:	8b 55 10             	mov    0x10(%ebp),%edx
  801731:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801733:	85 d2                	test   %edx,%edx
  801735:	74 21                	je     801758 <strlcpy+0x35>
  801737:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80173b:	89 f2                	mov    %esi,%edx
  80173d:	eb 09                	jmp    801748 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80173f:	83 c1 01             	add    $0x1,%ecx
  801742:	83 c2 01             	add    $0x1,%edx
  801745:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801748:	39 c2                	cmp    %eax,%edx
  80174a:	74 09                	je     801755 <strlcpy+0x32>
  80174c:	0f b6 19             	movzbl (%ecx),%ebx
  80174f:	84 db                	test   %bl,%bl
  801751:	75 ec                	jne    80173f <strlcpy+0x1c>
  801753:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801755:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801758:	29 f0                	sub    %esi,%eax
}
  80175a:	5b                   	pop    %ebx
  80175b:	5e                   	pop    %esi
  80175c:	5d                   	pop    %ebp
  80175d:	c3                   	ret    

0080175e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80175e:	55                   	push   %ebp
  80175f:	89 e5                	mov    %esp,%ebp
  801761:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801764:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801767:	eb 06                	jmp    80176f <strcmp+0x11>
		p++, q++;
  801769:	83 c1 01             	add    $0x1,%ecx
  80176c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80176f:	0f b6 01             	movzbl (%ecx),%eax
  801772:	84 c0                	test   %al,%al
  801774:	74 04                	je     80177a <strcmp+0x1c>
  801776:	3a 02                	cmp    (%edx),%al
  801778:	74 ef                	je     801769 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80177a:	0f b6 c0             	movzbl %al,%eax
  80177d:	0f b6 12             	movzbl (%edx),%edx
  801780:	29 d0                	sub    %edx,%eax
}
  801782:	5d                   	pop    %ebp
  801783:	c3                   	ret    

00801784 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	53                   	push   %ebx
  801788:	8b 45 08             	mov    0x8(%ebp),%eax
  80178b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80178e:	89 c3                	mov    %eax,%ebx
  801790:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801793:	eb 06                	jmp    80179b <strncmp+0x17>
		n--, p++, q++;
  801795:	83 c0 01             	add    $0x1,%eax
  801798:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80179b:	39 d8                	cmp    %ebx,%eax
  80179d:	74 18                	je     8017b7 <strncmp+0x33>
  80179f:	0f b6 08             	movzbl (%eax),%ecx
  8017a2:	84 c9                	test   %cl,%cl
  8017a4:	74 04                	je     8017aa <strncmp+0x26>
  8017a6:	3a 0a                	cmp    (%edx),%cl
  8017a8:	74 eb                	je     801795 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017aa:	0f b6 00             	movzbl (%eax),%eax
  8017ad:	0f b6 12             	movzbl (%edx),%edx
  8017b0:	29 d0                	sub    %edx,%eax
}
  8017b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017b5:	c9                   	leave  
  8017b6:	c3                   	ret    
		return 0;
  8017b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8017bc:	eb f4                	jmp    8017b2 <strncmp+0x2e>

008017be <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017be:	55                   	push   %ebp
  8017bf:	89 e5                	mov    %esp,%ebp
  8017c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017c8:	eb 03                	jmp    8017cd <strchr+0xf>
  8017ca:	83 c0 01             	add    $0x1,%eax
  8017cd:	0f b6 10             	movzbl (%eax),%edx
  8017d0:	84 d2                	test   %dl,%dl
  8017d2:	74 06                	je     8017da <strchr+0x1c>
		if (*s == c)
  8017d4:	38 ca                	cmp    %cl,%dl
  8017d6:	75 f2                	jne    8017ca <strchr+0xc>
  8017d8:	eb 05                	jmp    8017df <strchr+0x21>
			return (char *) s;
	return 0;
  8017da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017df:	5d                   	pop    %ebp
  8017e0:	c3                   	ret    

008017e1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017e1:	55                   	push   %ebp
  8017e2:	89 e5                	mov    %esp,%ebp
  8017e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017eb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017ee:	38 ca                	cmp    %cl,%dl
  8017f0:	74 09                	je     8017fb <strfind+0x1a>
  8017f2:	84 d2                	test   %dl,%dl
  8017f4:	74 05                	je     8017fb <strfind+0x1a>
	for (; *s; s++)
  8017f6:	83 c0 01             	add    $0x1,%eax
  8017f9:	eb f0                	jmp    8017eb <strfind+0xa>
			break;
	return (char *) s;
}
  8017fb:	5d                   	pop    %ebp
  8017fc:	c3                   	ret    

008017fd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	57                   	push   %edi
  801801:	56                   	push   %esi
  801802:	53                   	push   %ebx
  801803:	8b 7d 08             	mov    0x8(%ebp),%edi
  801806:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801809:	85 c9                	test   %ecx,%ecx
  80180b:	74 2f                	je     80183c <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80180d:	89 f8                	mov    %edi,%eax
  80180f:	09 c8                	or     %ecx,%eax
  801811:	a8 03                	test   $0x3,%al
  801813:	75 21                	jne    801836 <memset+0x39>
		c &= 0xFF;
  801815:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801819:	89 d0                	mov    %edx,%eax
  80181b:	c1 e0 08             	shl    $0x8,%eax
  80181e:	89 d3                	mov    %edx,%ebx
  801820:	c1 e3 18             	shl    $0x18,%ebx
  801823:	89 d6                	mov    %edx,%esi
  801825:	c1 e6 10             	shl    $0x10,%esi
  801828:	09 f3                	or     %esi,%ebx
  80182a:	09 da                	or     %ebx,%edx
  80182c:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80182e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801831:	fc                   	cld    
  801832:	f3 ab                	rep stos %eax,%es:(%edi)
  801834:	eb 06                	jmp    80183c <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801836:	8b 45 0c             	mov    0xc(%ebp),%eax
  801839:	fc                   	cld    
  80183a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80183c:	89 f8                	mov    %edi,%eax
  80183e:	5b                   	pop    %ebx
  80183f:	5e                   	pop    %esi
  801840:	5f                   	pop    %edi
  801841:	5d                   	pop    %ebp
  801842:	c3                   	ret    

00801843 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801843:	55                   	push   %ebp
  801844:	89 e5                	mov    %esp,%ebp
  801846:	57                   	push   %edi
  801847:	56                   	push   %esi
  801848:	8b 45 08             	mov    0x8(%ebp),%eax
  80184b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80184e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801851:	39 c6                	cmp    %eax,%esi
  801853:	73 32                	jae    801887 <memmove+0x44>
  801855:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801858:	39 c2                	cmp    %eax,%edx
  80185a:	76 2b                	jbe    801887 <memmove+0x44>
		s += n;
		d += n;
  80185c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80185f:	89 d6                	mov    %edx,%esi
  801861:	09 fe                	or     %edi,%esi
  801863:	09 ce                	or     %ecx,%esi
  801865:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80186b:	75 0e                	jne    80187b <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80186d:	83 ef 04             	sub    $0x4,%edi
  801870:	8d 72 fc             	lea    -0x4(%edx),%esi
  801873:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801876:	fd                   	std    
  801877:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801879:	eb 09                	jmp    801884 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80187b:	83 ef 01             	sub    $0x1,%edi
  80187e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801881:	fd                   	std    
  801882:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801884:	fc                   	cld    
  801885:	eb 1a                	jmp    8018a1 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801887:	89 f2                	mov    %esi,%edx
  801889:	09 c2                	or     %eax,%edx
  80188b:	09 ca                	or     %ecx,%edx
  80188d:	f6 c2 03             	test   $0x3,%dl
  801890:	75 0a                	jne    80189c <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801892:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801895:	89 c7                	mov    %eax,%edi
  801897:	fc                   	cld    
  801898:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80189a:	eb 05                	jmp    8018a1 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  80189c:	89 c7                	mov    %eax,%edi
  80189e:	fc                   	cld    
  80189f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018a1:	5e                   	pop    %esi
  8018a2:	5f                   	pop    %edi
  8018a3:	5d                   	pop    %ebp
  8018a4:	c3                   	ret    

008018a5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8018ab:	ff 75 10             	push   0x10(%ebp)
  8018ae:	ff 75 0c             	push   0xc(%ebp)
  8018b1:	ff 75 08             	push   0x8(%ebp)
  8018b4:	e8 8a ff ff ff       	call   801843 <memmove>
}
  8018b9:	c9                   	leave  
  8018ba:	c3                   	ret    

008018bb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	56                   	push   %esi
  8018bf:	53                   	push   %ebx
  8018c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018c6:	89 c6                	mov    %eax,%esi
  8018c8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018cb:	eb 06                	jmp    8018d3 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8018cd:	83 c0 01             	add    $0x1,%eax
  8018d0:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8018d3:	39 f0                	cmp    %esi,%eax
  8018d5:	74 14                	je     8018eb <memcmp+0x30>
		if (*s1 != *s2)
  8018d7:	0f b6 08             	movzbl (%eax),%ecx
  8018da:	0f b6 1a             	movzbl (%edx),%ebx
  8018dd:	38 d9                	cmp    %bl,%cl
  8018df:	74 ec                	je     8018cd <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8018e1:	0f b6 c1             	movzbl %cl,%eax
  8018e4:	0f b6 db             	movzbl %bl,%ebx
  8018e7:	29 d8                	sub    %ebx,%eax
  8018e9:	eb 05                	jmp    8018f0 <memcmp+0x35>
	}

	return 0;
  8018eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f0:	5b                   	pop    %ebx
  8018f1:	5e                   	pop    %esi
  8018f2:	5d                   	pop    %ebp
  8018f3:	c3                   	ret    

008018f4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8018fd:	89 c2                	mov    %eax,%edx
  8018ff:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801902:	eb 03                	jmp    801907 <memfind+0x13>
  801904:	83 c0 01             	add    $0x1,%eax
  801907:	39 d0                	cmp    %edx,%eax
  801909:	73 04                	jae    80190f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80190b:	38 08                	cmp    %cl,(%eax)
  80190d:	75 f5                	jne    801904 <memfind+0x10>
			break;
	return (void *) s;
}
  80190f:	5d                   	pop    %ebp
  801910:	c3                   	ret    

00801911 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801911:	55                   	push   %ebp
  801912:	89 e5                	mov    %esp,%ebp
  801914:	57                   	push   %edi
  801915:	56                   	push   %esi
  801916:	53                   	push   %ebx
  801917:	8b 55 08             	mov    0x8(%ebp),%edx
  80191a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80191d:	eb 03                	jmp    801922 <strtol+0x11>
		s++;
  80191f:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801922:	0f b6 02             	movzbl (%edx),%eax
  801925:	3c 20                	cmp    $0x20,%al
  801927:	74 f6                	je     80191f <strtol+0xe>
  801929:	3c 09                	cmp    $0x9,%al
  80192b:	74 f2                	je     80191f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  80192d:	3c 2b                	cmp    $0x2b,%al
  80192f:	74 2a                	je     80195b <strtol+0x4a>
	int neg = 0;
  801931:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801936:	3c 2d                	cmp    $0x2d,%al
  801938:	74 2b                	je     801965 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80193a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801940:	75 0f                	jne    801951 <strtol+0x40>
  801942:	80 3a 30             	cmpb   $0x30,(%edx)
  801945:	74 28                	je     80196f <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801947:	85 db                	test   %ebx,%ebx
  801949:	b8 0a 00 00 00       	mov    $0xa,%eax
  80194e:	0f 44 d8             	cmove  %eax,%ebx
  801951:	b9 00 00 00 00       	mov    $0x0,%ecx
  801956:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801959:	eb 46                	jmp    8019a1 <strtol+0x90>
		s++;
  80195b:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  80195e:	bf 00 00 00 00       	mov    $0x0,%edi
  801963:	eb d5                	jmp    80193a <strtol+0x29>
		s++, neg = 1;
  801965:	83 c2 01             	add    $0x1,%edx
  801968:	bf 01 00 00 00       	mov    $0x1,%edi
  80196d:	eb cb                	jmp    80193a <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80196f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801973:	74 0e                	je     801983 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801975:	85 db                	test   %ebx,%ebx
  801977:	75 d8                	jne    801951 <strtol+0x40>
		s++, base = 8;
  801979:	83 c2 01             	add    $0x1,%edx
  80197c:	bb 08 00 00 00       	mov    $0x8,%ebx
  801981:	eb ce                	jmp    801951 <strtol+0x40>
		s += 2, base = 16;
  801983:	83 c2 02             	add    $0x2,%edx
  801986:	bb 10 00 00 00       	mov    $0x10,%ebx
  80198b:	eb c4                	jmp    801951 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  80198d:	0f be c0             	movsbl %al,%eax
  801990:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801993:	3b 45 10             	cmp    0x10(%ebp),%eax
  801996:	7d 3a                	jge    8019d2 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801998:	83 c2 01             	add    $0x1,%edx
  80199b:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  80199f:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  8019a1:	0f b6 02             	movzbl (%edx),%eax
  8019a4:	8d 70 d0             	lea    -0x30(%eax),%esi
  8019a7:	89 f3                	mov    %esi,%ebx
  8019a9:	80 fb 09             	cmp    $0x9,%bl
  8019ac:	76 df                	jbe    80198d <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  8019ae:	8d 70 9f             	lea    -0x61(%eax),%esi
  8019b1:	89 f3                	mov    %esi,%ebx
  8019b3:	80 fb 19             	cmp    $0x19,%bl
  8019b6:	77 08                	ja     8019c0 <strtol+0xaf>
			dig = *s - 'a' + 10;
  8019b8:	0f be c0             	movsbl %al,%eax
  8019bb:	83 e8 57             	sub    $0x57,%eax
  8019be:	eb d3                	jmp    801993 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8019c0:	8d 70 bf             	lea    -0x41(%eax),%esi
  8019c3:	89 f3                	mov    %esi,%ebx
  8019c5:	80 fb 19             	cmp    $0x19,%bl
  8019c8:	77 08                	ja     8019d2 <strtol+0xc1>
			dig = *s - 'A' + 10;
  8019ca:	0f be c0             	movsbl %al,%eax
  8019cd:	83 e8 37             	sub    $0x37,%eax
  8019d0:	eb c1                	jmp    801993 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8019d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019d6:	74 05                	je     8019dd <strtol+0xcc>
		*endptr = (char *) s;
  8019d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019db:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8019dd:	89 c8                	mov    %ecx,%eax
  8019df:	f7 d8                	neg    %eax
  8019e1:	85 ff                	test   %edi,%edi
  8019e3:	0f 45 c8             	cmovne %eax,%ecx
}
  8019e6:	89 c8                	mov    %ecx,%eax
  8019e8:	5b                   	pop    %ebx
  8019e9:	5e                   	pop    %esi
  8019ea:	5f                   	pop    %edi
  8019eb:	5d                   	pop    %ebp
  8019ec:	c3                   	ret    

008019ed <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019ed:	55                   	push   %ebp
  8019ee:	89 e5                	mov    %esp,%ebp
  8019f0:	56                   	push   %esi
  8019f1:	53                   	push   %ebx
  8019f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8019f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8019fb:	85 c0                	test   %eax,%eax
  8019fd:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a02:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801a05:	83 ec 0c             	sub    $0xc,%esp
  801a08:	50                   	push   %eax
  801a09:	e8 08 e9 ff ff       	call   800316 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801a0e:	83 c4 10             	add    $0x10,%esp
  801a11:	85 f6                	test   %esi,%esi
  801a13:	74 14                	je     801a29 <ipc_recv+0x3c>
  801a15:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 09                	js     801a27 <ipc_recv+0x3a>
  801a1e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a24:	8b 52 74             	mov    0x74(%edx),%edx
  801a27:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801a29:	85 db                	test   %ebx,%ebx
  801a2b:	74 14                	je     801a41 <ipc_recv+0x54>
  801a2d:	ba 00 00 00 00       	mov    $0x0,%edx
  801a32:	85 c0                	test   %eax,%eax
  801a34:	78 09                	js     801a3f <ipc_recv+0x52>
  801a36:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a3c:	8b 52 78             	mov    0x78(%edx),%edx
  801a3f:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801a41:	85 c0                	test   %eax,%eax
  801a43:	78 08                	js     801a4d <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801a45:	a1 00 40 80 00       	mov    0x804000,%eax
  801a4a:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a50:	5b                   	pop    %ebx
  801a51:	5e                   	pop    %esi
  801a52:	5d                   	pop    %ebp
  801a53:	c3                   	ret    

00801a54 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	57                   	push   %edi
  801a58:	56                   	push   %esi
  801a59:	53                   	push   %ebx
  801a5a:	83 ec 0c             	sub    $0xc,%esp
  801a5d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a60:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801a66:	85 db                	test   %ebx,%ebx
  801a68:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a6d:	0f 44 d8             	cmove  %eax,%ebx
  801a70:	eb 05                	jmp    801a77 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a72:	e8 d0 e6 ff ff       	call   800147 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801a77:	ff 75 14             	push   0x14(%ebp)
  801a7a:	53                   	push   %ebx
  801a7b:	56                   	push   %esi
  801a7c:	57                   	push   %edi
  801a7d:	e8 71 e8 ff ff       	call   8002f3 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a82:	83 c4 10             	add    $0x10,%esp
  801a85:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a88:	74 e8                	je     801a72 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801a8a:	85 c0                	test   %eax,%eax
  801a8c:	78 08                	js     801a96 <ipc_send+0x42>
	}while (r<0);

}
  801a8e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a91:	5b                   	pop    %ebx
  801a92:	5e                   	pop    %esi
  801a93:	5f                   	pop    %edi
  801a94:	5d                   	pop    %ebp
  801a95:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801a96:	50                   	push   %eax
  801a97:	68 9f 21 80 00       	push   $0x80219f
  801a9c:	6a 3d                	push   $0x3d
  801a9e:	68 b3 21 80 00       	push   $0x8021b3
  801aa3:	e8 50 f5 ff ff       	call   800ff8 <_panic>

00801aa8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801aae:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ab3:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ab6:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801abc:	8b 52 50             	mov    0x50(%edx),%edx
  801abf:	39 ca                	cmp    %ecx,%edx
  801ac1:	74 11                	je     801ad4 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801ac3:	83 c0 01             	add    $0x1,%eax
  801ac6:	3d 00 04 00 00       	cmp    $0x400,%eax
  801acb:	75 e6                	jne    801ab3 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801acd:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad2:	eb 0b                	jmp    801adf <ipc_find_env+0x37>
			return envs[i].env_id;
  801ad4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ad7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801adc:	8b 40 48             	mov    0x48(%eax),%eax
}
  801adf:	5d                   	pop    %ebp
  801ae0:	c3                   	ret    

00801ae1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ae1:	55                   	push   %ebp
  801ae2:	89 e5                	mov    %esp,%ebp
  801ae4:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ae7:	89 c2                	mov    %eax,%edx
  801ae9:	c1 ea 16             	shr    $0x16,%edx
  801aec:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801af3:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801af8:	f6 c1 01             	test   $0x1,%cl
  801afb:	74 1c                	je     801b19 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801afd:	c1 e8 0c             	shr    $0xc,%eax
  801b00:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b07:	a8 01                	test   $0x1,%al
  801b09:	74 0e                	je     801b19 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b0b:	c1 e8 0c             	shr    $0xc,%eax
  801b0e:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b15:	ef 
  801b16:	0f b7 d2             	movzwl %dx,%edx
}
  801b19:	89 d0                	mov    %edx,%eax
  801b1b:	5d                   	pop    %ebp
  801b1c:	c3                   	ret    
  801b1d:	66 90                	xchg   %ax,%ax
  801b1f:	90                   	nop

00801b20 <__udivdi3>:
  801b20:	f3 0f 1e fb          	endbr32 
  801b24:	55                   	push   %ebp
  801b25:	57                   	push   %edi
  801b26:	56                   	push   %esi
  801b27:	53                   	push   %ebx
  801b28:	83 ec 1c             	sub    $0x1c,%esp
  801b2b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801b2f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b33:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b37:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b3b:	85 c0                	test   %eax,%eax
  801b3d:	75 19                	jne    801b58 <__udivdi3+0x38>
  801b3f:	39 f3                	cmp    %esi,%ebx
  801b41:	76 4d                	jbe    801b90 <__udivdi3+0x70>
  801b43:	31 ff                	xor    %edi,%edi
  801b45:	89 e8                	mov    %ebp,%eax
  801b47:	89 f2                	mov    %esi,%edx
  801b49:	f7 f3                	div    %ebx
  801b4b:	89 fa                	mov    %edi,%edx
  801b4d:	83 c4 1c             	add    $0x1c,%esp
  801b50:	5b                   	pop    %ebx
  801b51:	5e                   	pop    %esi
  801b52:	5f                   	pop    %edi
  801b53:	5d                   	pop    %ebp
  801b54:	c3                   	ret    
  801b55:	8d 76 00             	lea    0x0(%esi),%esi
  801b58:	39 f0                	cmp    %esi,%eax
  801b5a:	76 14                	jbe    801b70 <__udivdi3+0x50>
  801b5c:	31 ff                	xor    %edi,%edi
  801b5e:	31 c0                	xor    %eax,%eax
  801b60:	89 fa                	mov    %edi,%edx
  801b62:	83 c4 1c             	add    $0x1c,%esp
  801b65:	5b                   	pop    %ebx
  801b66:	5e                   	pop    %esi
  801b67:	5f                   	pop    %edi
  801b68:	5d                   	pop    %ebp
  801b69:	c3                   	ret    
  801b6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801b70:	0f bd f8             	bsr    %eax,%edi
  801b73:	83 f7 1f             	xor    $0x1f,%edi
  801b76:	75 48                	jne    801bc0 <__udivdi3+0xa0>
  801b78:	39 f0                	cmp    %esi,%eax
  801b7a:	72 06                	jb     801b82 <__udivdi3+0x62>
  801b7c:	31 c0                	xor    %eax,%eax
  801b7e:	39 eb                	cmp    %ebp,%ebx
  801b80:	77 de                	ja     801b60 <__udivdi3+0x40>
  801b82:	b8 01 00 00 00       	mov    $0x1,%eax
  801b87:	eb d7                	jmp    801b60 <__udivdi3+0x40>
  801b89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b90:	89 d9                	mov    %ebx,%ecx
  801b92:	85 db                	test   %ebx,%ebx
  801b94:	75 0b                	jne    801ba1 <__udivdi3+0x81>
  801b96:	b8 01 00 00 00       	mov    $0x1,%eax
  801b9b:	31 d2                	xor    %edx,%edx
  801b9d:	f7 f3                	div    %ebx
  801b9f:	89 c1                	mov    %eax,%ecx
  801ba1:	31 d2                	xor    %edx,%edx
  801ba3:	89 f0                	mov    %esi,%eax
  801ba5:	f7 f1                	div    %ecx
  801ba7:	89 c6                	mov    %eax,%esi
  801ba9:	89 e8                	mov    %ebp,%eax
  801bab:	89 f7                	mov    %esi,%edi
  801bad:	f7 f1                	div    %ecx
  801baf:	89 fa                	mov    %edi,%edx
  801bb1:	83 c4 1c             	add    $0x1c,%esp
  801bb4:	5b                   	pop    %ebx
  801bb5:	5e                   	pop    %esi
  801bb6:	5f                   	pop    %edi
  801bb7:	5d                   	pop    %ebp
  801bb8:	c3                   	ret    
  801bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bc0:	89 f9                	mov    %edi,%ecx
  801bc2:	ba 20 00 00 00       	mov    $0x20,%edx
  801bc7:	29 fa                	sub    %edi,%edx
  801bc9:	d3 e0                	shl    %cl,%eax
  801bcb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bcf:	89 d1                	mov    %edx,%ecx
  801bd1:	89 d8                	mov    %ebx,%eax
  801bd3:	d3 e8                	shr    %cl,%eax
  801bd5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801bd9:	09 c1                	or     %eax,%ecx
  801bdb:	89 f0                	mov    %esi,%eax
  801bdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801be1:	89 f9                	mov    %edi,%ecx
  801be3:	d3 e3                	shl    %cl,%ebx
  801be5:	89 d1                	mov    %edx,%ecx
  801be7:	d3 e8                	shr    %cl,%eax
  801be9:	89 f9                	mov    %edi,%ecx
  801beb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801bef:	89 eb                	mov    %ebp,%ebx
  801bf1:	d3 e6                	shl    %cl,%esi
  801bf3:	89 d1                	mov    %edx,%ecx
  801bf5:	d3 eb                	shr    %cl,%ebx
  801bf7:	09 f3                	or     %esi,%ebx
  801bf9:	89 c6                	mov    %eax,%esi
  801bfb:	89 f2                	mov    %esi,%edx
  801bfd:	89 d8                	mov    %ebx,%eax
  801bff:	f7 74 24 08          	divl   0x8(%esp)
  801c03:	89 d6                	mov    %edx,%esi
  801c05:	89 c3                	mov    %eax,%ebx
  801c07:	f7 64 24 0c          	mull   0xc(%esp)
  801c0b:	39 d6                	cmp    %edx,%esi
  801c0d:	72 19                	jb     801c28 <__udivdi3+0x108>
  801c0f:	89 f9                	mov    %edi,%ecx
  801c11:	d3 e5                	shl    %cl,%ebp
  801c13:	39 c5                	cmp    %eax,%ebp
  801c15:	73 04                	jae    801c1b <__udivdi3+0xfb>
  801c17:	39 d6                	cmp    %edx,%esi
  801c19:	74 0d                	je     801c28 <__udivdi3+0x108>
  801c1b:	89 d8                	mov    %ebx,%eax
  801c1d:	31 ff                	xor    %edi,%edi
  801c1f:	e9 3c ff ff ff       	jmp    801b60 <__udivdi3+0x40>
  801c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c28:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c2b:	31 ff                	xor    %edi,%edi
  801c2d:	e9 2e ff ff ff       	jmp    801b60 <__udivdi3+0x40>
  801c32:	66 90                	xchg   %ax,%ax
  801c34:	66 90                	xchg   %ax,%ax
  801c36:	66 90                	xchg   %ax,%ax
  801c38:	66 90                	xchg   %ax,%ax
  801c3a:	66 90                	xchg   %ax,%ax
  801c3c:	66 90                	xchg   %ax,%ax
  801c3e:	66 90                	xchg   %ax,%ax

00801c40 <__umoddi3>:
  801c40:	f3 0f 1e fb          	endbr32 
  801c44:	55                   	push   %ebp
  801c45:	57                   	push   %edi
  801c46:	56                   	push   %esi
  801c47:	53                   	push   %ebx
  801c48:	83 ec 1c             	sub    $0x1c,%esp
  801c4b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801c4f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801c53:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801c57:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801c5b:	89 f0                	mov    %esi,%eax
  801c5d:	89 da                	mov    %ebx,%edx
  801c5f:	85 ff                	test   %edi,%edi
  801c61:	75 15                	jne    801c78 <__umoddi3+0x38>
  801c63:	39 dd                	cmp    %ebx,%ebp
  801c65:	76 39                	jbe    801ca0 <__umoddi3+0x60>
  801c67:	f7 f5                	div    %ebp
  801c69:	89 d0                	mov    %edx,%eax
  801c6b:	31 d2                	xor    %edx,%edx
  801c6d:	83 c4 1c             	add    $0x1c,%esp
  801c70:	5b                   	pop    %ebx
  801c71:	5e                   	pop    %esi
  801c72:	5f                   	pop    %edi
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    
  801c75:	8d 76 00             	lea    0x0(%esi),%esi
  801c78:	39 df                	cmp    %ebx,%edi
  801c7a:	77 f1                	ja     801c6d <__umoddi3+0x2d>
  801c7c:	0f bd cf             	bsr    %edi,%ecx
  801c7f:	83 f1 1f             	xor    $0x1f,%ecx
  801c82:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c86:	75 40                	jne    801cc8 <__umoddi3+0x88>
  801c88:	39 df                	cmp    %ebx,%edi
  801c8a:	72 04                	jb     801c90 <__umoddi3+0x50>
  801c8c:	39 f5                	cmp    %esi,%ebp
  801c8e:	77 dd                	ja     801c6d <__umoddi3+0x2d>
  801c90:	89 da                	mov    %ebx,%edx
  801c92:	89 f0                	mov    %esi,%eax
  801c94:	29 e8                	sub    %ebp,%eax
  801c96:	19 fa                	sbb    %edi,%edx
  801c98:	eb d3                	jmp    801c6d <__umoddi3+0x2d>
  801c9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ca0:	89 e9                	mov    %ebp,%ecx
  801ca2:	85 ed                	test   %ebp,%ebp
  801ca4:	75 0b                	jne    801cb1 <__umoddi3+0x71>
  801ca6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cab:	31 d2                	xor    %edx,%edx
  801cad:	f7 f5                	div    %ebp
  801caf:	89 c1                	mov    %eax,%ecx
  801cb1:	89 d8                	mov    %ebx,%eax
  801cb3:	31 d2                	xor    %edx,%edx
  801cb5:	f7 f1                	div    %ecx
  801cb7:	89 f0                	mov    %esi,%eax
  801cb9:	f7 f1                	div    %ecx
  801cbb:	89 d0                	mov    %edx,%eax
  801cbd:	31 d2                	xor    %edx,%edx
  801cbf:	eb ac                	jmp    801c6d <__umoddi3+0x2d>
  801cc1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cc8:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ccc:	ba 20 00 00 00       	mov    $0x20,%edx
  801cd1:	29 c2                	sub    %eax,%edx
  801cd3:	89 c1                	mov    %eax,%ecx
  801cd5:	89 e8                	mov    %ebp,%eax
  801cd7:	d3 e7                	shl    %cl,%edi
  801cd9:	89 d1                	mov    %edx,%ecx
  801cdb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801cdf:	d3 e8                	shr    %cl,%eax
  801ce1:	89 c1                	mov    %eax,%ecx
  801ce3:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ce7:	09 f9                	or     %edi,%ecx
  801ce9:	89 df                	mov    %ebx,%edi
  801ceb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cef:	89 c1                	mov    %eax,%ecx
  801cf1:	d3 e5                	shl    %cl,%ebp
  801cf3:	89 d1                	mov    %edx,%ecx
  801cf5:	d3 ef                	shr    %cl,%edi
  801cf7:	89 c1                	mov    %eax,%ecx
  801cf9:	89 f0                	mov    %esi,%eax
  801cfb:	d3 e3                	shl    %cl,%ebx
  801cfd:	89 d1                	mov    %edx,%ecx
  801cff:	89 fa                	mov    %edi,%edx
  801d01:	d3 e8                	shr    %cl,%eax
  801d03:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d08:	09 d8                	or     %ebx,%eax
  801d0a:	f7 74 24 08          	divl   0x8(%esp)
  801d0e:	89 d3                	mov    %edx,%ebx
  801d10:	d3 e6                	shl    %cl,%esi
  801d12:	f7 e5                	mul    %ebp
  801d14:	89 c7                	mov    %eax,%edi
  801d16:	89 d1                	mov    %edx,%ecx
  801d18:	39 d3                	cmp    %edx,%ebx
  801d1a:	72 06                	jb     801d22 <__umoddi3+0xe2>
  801d1c:	75 0e                	jne    801d2c <__umoddi3+0xec>
  801d1e:	39 c6                	cmp    %eax,%esi
  801d20:	73 0a                	jae    801d2c <__umoddi3+0xec>
  801d22:	29 e8                	sub    %ebp,%eax
  801d24:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801d28:	89 d1                	mov    %edx,%ecx
  801d2a:	89 c7                	mov    %eax,%edi
  801d2c:	89 f5                	mov    %esi,%ebp
  801d2e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801d32:	29 fd                	sub    %edi,%ebp
  801d34:	19 cb                	sbb    %ecx,%ebx
  801d36:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d3b:	89 d8                	mov    %ebx,%eax
  801d3d:	d3 e0                	shl    %cl,%eax
  801d3f:	89 f1                	mov    %esi,%ecx
  801d41:	d3 ed                	shr    %cl,%ebp
  801d43:	d3 eb                	shr    %cl,%ebx
  801d45:	09 e8                	or     %ebp,%eax
  801d47:	89 da                	mov    %ebx,%edx
  801d49:	83 c4 1c             	add    $0x1c,%esp
  801d4c:	5b                   	pop    %ebx
  801d4d:	5e                   	pop    %esi
  801d4e:	5f                   	pop    %edi
  801d4f:	5d                   	pop    %ebp
  801d50:	c3                   	ret    
