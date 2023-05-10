
obj/user/buggyhello.debug：     文件格式 elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 68 00 00 00       	call   8000aa <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 d1 00 00 00       	call   800128 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x30>
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
  800096:	e8 ee 04 00 00       	call   800589 <close_all>
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
  800117:	68 4a 22 80 00       	push   $0x80224a
  80011c:	6a 2a                	push   $0x2a
  80011e:	68 67 22 80 00       	push   $0x802267
  800123:	e8 9e 13 00 00       	call   8014c6 <_panic>

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
  800198:	68 4a 22 80 00       	push   $0x80224a
  80019d:	6a 2a                	push   $0x2a
  80019f:	68 67 22 80 00       	push   $0x802267
  8001a4:	e8 1d 13 00 00       	call   8014c6 <_panic>

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
  8001da:	68 4a 22 80 00       	push   $0x80224a
  8001df:	6a 2a                	push   $0x2a
  8001e1:	68 67 22 80 00       	push   $0x802267
  8001e6:	e8 db 12 00 00       	call   8014c6 <_panic>

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
  80021c:	68 4a 22 80 00       	push   $0x80224a
  800221:	6a 2a                	push   $0x2a
  800223:	68 67 22 80 00       	push   $0x802267
  800228:	e8 99 12 00 00       	call   8014c6 <_panic>

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
  80025e:	68 4a 22 80 00       	push   $0x80224a
  800263:	6a 2a                	push   $0x2a
  800265:	68 67 22 80 00       	push   $0x802267
  80026a:	e8 57 12 00 00       	call   8014c6 <_panic>

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
  8002a0:	68 4a 22 80 00       	push   $0x80224a
  8002a5:	6a 2a                	push   $0x2a
  8002a7:	68 67 22 80 00       	push   $0x802267
  8002ac:	e8 15 12 00 00       	call   8014c6 <_panic>

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
  8002e2:	68 4a 22 80 00       	push   $0x80224a
  8002e7:	6a 2a                	push   $0x2a
  8002e9:	68 67 22 80 00       	push   $0x802267
  8002ee:	e8 d3 11 00 00       	call   8014c6 <_panic>

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
  800346:	68 4a 22 80 00       	push   $0x80224a
  80034b:	6a 2a                	push   $0x2a
  80034d:	68 67 22 80 00       	push   $0x802267
  800352:	e8 6f 11 00 00       	call   8014c6 <_panic>

00800357 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	57                   	push   %edi
  80035b:	56                   	push   %esi
  80035c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80035d:	ba 00 00 00 00       	mov    $0x0,%edx
  800362:	b8 0e 00 00 00       	mov    $0xe,%eax
  800367:	89 d1                	mov    %edx,%ecx
  800369:	89 d3                	mov    %edx,%ebx
  80036b:	89 d7                	mov    %edx,%edi
  80036d:	89 d6                	mov    %edx,%esi
  80036f:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800371:	5b                   	pop    %ebx
  800372:	5e                   	pop    %esi
  800373:	5f                   	pop    %edi
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	57                   	push   %edi
  80037a:	56                   	push   %esi
  80037b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80037c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800381:	8b 55 08             	mov    0x8(%ebp),%edx
  800384:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800387:	b8 0f 00 00 00       	mov    $0xf,%eax
  80038c:	89 df                	mov    %ebx,%edi
  80038e:	89 de                	mov    %ebx,%esi
  800390:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800392:	5b                   	pop    %ebx
  800393:	5e                   	pop    %esi
  800394:	5f                   	pop    %edi
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	57                   	push   %edi
  80039b:	56                   	push   %esi
  80039c:	53                   	push   %ebx
	asm volatile("int %1\n"
  80039d:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003a8:	b8 10 00 00 00       	mov    $0x10,%eax
  8003ad:	89 df                	mov    %ebx,%edi
  8003af:	89 de                	mov    %ebx,%esi
  8003b1:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8003b3:	5b                   	pop    %ebx
  8003b4:	5e                   	pop    %esi
  8003b5:	5f                   	pop    %edi
  8003b6:	5d                   	pop    %ebp
  8003b7:	c3                   	ret    

008003b8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003b8:	55                   	push   %ebp
  8003b9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003be:	05 00 00 00 30       	add    $0x30000000,%eax
  8003c3:	c1 e8 0c             	shr    $0xc,%eax
}
  8003c6:	5d                   	pop    %ebp
  8003c7:	c3                   	ret    

008003c8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003c8:	55                   	push   %ebp
  8003c9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ce:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003d3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003d8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003dd:	5d                   	pop    %ebp
  8003de:	c3                   	ret    

008003df <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003e7:	89 c2                	mov    %eax,%edx
  8003e9:	c1 ea 16             	shr    $0x16,%edx
  8003ec:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003f3:	f6 c2 01             	test   $0x1,%dl
  8003f6:	74 29                	je     800421 <fd_alloc+0x42>
  8003f8:	89 c2                	mov    %eax,%edx
  8003fa:	c1 ea 0c             	shr    $0xc,%edx
  8003fd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800404:	f6 c2 01             	test   $0x1,%dl
  800407:	74 18                	je     800421 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800409:	05 00 10 00 00       	add    $0x1000,%eax
  80040e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800413:	75 d2                	jne    8003e7 <fd_alloc+0x8>
  800415:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80041a:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80041f:	eb 05                	jmp    800426 <fd_alloc+0x47>
			return 0;
  800421:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800426:	8b 55 08             	mov    0x8(%ebp),%edx
  800429:	89 02                	mov    %eax,(%edx)
}
  80042b:	89 c8                	mov    %ecx,%eax
  80042d:	5d                   	pop    %ebp
  80042e:	c3                   	ret    

0080042f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80042f:	55                   	push   %ebp
  800430:	89 e5                	mov    %esp,%ebp
  800432:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800435:	83 f8 1f             	cmp    $0x1f,%eax
  800438:	77 30                	ja     80046a <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80043a:	c1 e0 0c             	shl    $0xc,%eax
  80043d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800442:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800448:	f6 c2 01             	test   $0x1,%dl
  80044b:	74 24                	je     800471 <fd_lookup+0x42>
  80044d:	89 c2                	mov    %eax,%edx
  80044f:	c1 ea 0c             	shr    $0xc,%edx
  800452:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800459:	f6 c2 01             	test   $0x1,%dl
  80045c:	74 1a                	je     800478 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80045e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800461:	89 02                	mov    %eax,(%edx)
	return 0;
  800463:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800468:	5d                   	pop    %ebp
  800469:	c3                   	ret    
		return -E_INVAL;
  80046a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80046f:	eb f7                	jmp    800468 <fd_lookup+0x39>
		return -E_INVAL;
  800471:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800476:	eb f0                	jmp    800468 <fd_lookup+0x39>
  800478:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80047d:	eb e9                	jmp    800468 <fd_lookup+0x39>

0080047f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80047f:	55                   	push   %ebp
  800480:	89 e5                	mov    %esp,%ebp
  800482:	53                   	push   %ebx
  800483:	83 ec 04             	sub    $0x4,%esp
  800486:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800489:	b8 00 00 00 00       	mov    $0x0,%eax
  80048e:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800493:	39 13                	cmp    %edx,(%ebx)
  800495:	74 37                	je     8004ce <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800497:	83 c0 01             	add    $0x1,%eax
  80049a:	8b 1c 85 f4 22 80 00 	mov    0x8022f4(,%eax,4),%ebx
  8004a1:	85 db                	test   %ebx,%ebx
  8004a3:	75 ee                	jne    800493 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004a5:	a1 00 40 80 00       	mov    0x804000,%eax
  8004aa:	8b 40 58             	mov    0x58(%eax),%eax
  8004ad:	83 ec 04             	sub    $0x4,%esp
  8004b0:	52                   	push   %edx
  8004b1:	50                   	push   %eax
  8004b2:	68 78 22 80 00       	push   $0x802278
  8004b7:	e8 e5 10 00 00       	call   8015a1 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8004c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004c7:	89 1a                	mov    %ebx,(%edx)
}
  8004c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004cc:	c9                   	leave  
  8004cd:	c3                   	ret    
			return 0;
  8004ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d3:	eb ef                	jmp    8004c4 <dev_lookup+0x45>

008004d5 <fd_close>:
{
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
  8004d8:	57                   	push   %edi
  8004d9:	56                   	push   %esi
  8004da:	53                   	push   %ebx
  8004db:	83 ec 24             	sub    $0x24,%esp
  8004de:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004e7:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004e8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004ee:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004f1:	50                   	push   %eax
  8004f2:	e8 38 ff ff ff       	call   80042f <fd_lookup>
  8004f7:	89 c3                	mov    %eax,%ebx
  8004f9:	83 c4 10             	add    $0x10,%esp
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	78 05                	js     800505 <fd_close+0x30>
	    || fd != fd2)
  800500:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800503:	74 16                	je     80051b <fd_close+0x46>
		return (must_exist ? r : 0);
  800505:	89 f8                	mov    %edi,%eax
  800507:	84 c0                	test   %al,%al
  800509:	b8 00 00 00 00       	mov    $0x0,%eax
  80050e:	0f 44 d8             	cmove  %eax,%ebx
}
  800511:	89 d8                	mov    %ebx,%eax
  800513:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800516:	5b                   	pop    %ebx
  800517:	5e                   	pop    %esi
  800518:	5f                   	pop    %edi
  800519:	5d                   	pop    %ebp
  80051a:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80051b:	83 ec 08             	sub    $0x8,%esp
  80051e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800521:	50                   	push   %eax
  800522:	ff 36                	push   (%esi)
  800524:	e8 56 ff ff ff       	call   80047f <dev_lookup>
  800529:	89 c3                	mov    %eax,%ebx
  80052b:	83 c4 10             	add    $0x10,%esp
  80052e:	85 c0                	test   %eax,%eax
  800530:	78 1a                	js     80054c <fd_close+0x77>
		if (dev->dev_close)
  800532:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800535:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800538:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80053d:	85 c0                	test   %eax,%eax
  80053f:	74 0b                	je     80054c <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800541:	83 ec 0c             	sub    $0xc,%esp
  800544:	56                   	push   %esi
  800545:	ff d0                	call   *%eax
  800547:	89 c3                	mov    %eax,%ebx
  800549:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	56                   	push   %esi
  800550:	6a 00                	push   $0x0
  800552:	e8 94 fc ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800557:	83 c4 10             	add    $0x10,%esp
  80055a:	eb b5                	jmp    800511 <fd_close+0x3c>

0080055c <close>:

int
close(int fdnum)
{
  80055c:	55                   	push   %ebp
  80055d:	89 e5                	mov    %esp,%ebp
  80055f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800562:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800565:	50                   	push   %eax
  800566:	ff 75 08             	push   0x8(%ebp)
  800569:	e8 c1 fe ff ff       	call   80042f <fd_lookup>
  80056e:	83 c4 10             	add    $0x10,%esp
  800571:	85 c0                	test   %eax,%eax
  800573:	79 02                	jns    800577 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800575:	c9                   	leave  
  800576:	c3                   	ret    
		return fd_close(fd, 1);
  800577:	83 ec 08             	sub    $0x8,%esp
  80057a:	6a 01                	push   $0x1
  80057c:	ff 75 f4             	push   -0xc(%ebp)
  80057f:	e8 51 ff ff ff       	call   8004d5 <fd_close>
  800584:	83 c4 10             	add    $0x10,%esp
  800587:	eb ec                	jmp    800575 <close+0x19>

00800589 <close_all>:

void
close_all(void)
{
  800589:	55                   	push   %ebp
  80058a:	89 e5                	mov    %esp,%ebp
  80058c:	53                   	push   %ebx
  80058d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800590:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800595:	83 ec 0c             	sub    $0xc,%esp
  800598:	53                   	push   %ebx
  800599:	e8 be ff ff ff       	call   80055c <close>
	for (i = 0; i < MAXFD; i++)
  80059e:	83 c3 01             	add    $0x1,%ebx
  8005a1:	83 c4 10             	add    $0x10,%esp
  8005a4:	83 fb 20             	cmp    $0x20,%ebx
  8005a7:	75 ec                	jne    800595 <close_all+0xc>
}
  8005a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005ac:	c9                   	leave  
  8005ad:	c3                   	ret    

008005ae <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005ae:	55                   	push   %ebp
  8005af:	89 e5                	mov    %esp,%ebp
  8005b1:	57                   	push   %edi
  8005b2:	56                   	push   %esi
  8005b3:	53                   	push   %ebx
  8005b4:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005ba:	50                   	push   %eax
  8005bb:	ff 75 08             	push   0x8(%ebp)
  8005be:	e8 6c fe ff ff       	call   80042f <fd_lookup>
  8005c3:	89 c3                	mov    %eax,%ebx
  8005c5:	83 c4 10             	add    $0x10,%esp
  8005c8:	85 c0                	test   %eax,%eax
  8005ca:	78 7f                	js     80064b <dup+0x9d>
		return r;
	close(newfdnum);
  8005cc:	83 ec 0c             	sub    $0xc,%esp
  8005cf:	ff 75 0c             	push   0xc(%ebp)
  8005d2:	e8 85 ff ff ff       	call   80055c <close>

	newfd = INDEX2FD(newfdnum);
  8005d7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005da:	c1 e6 0c             	shl    $0xc,%esi
  8005dd:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005e6:	89 3c 24             	mov    %edi,(%esp)
  8005e9:	e8 da fd ff ff       	call   8003c8 <fd2data>
  8005ee:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005f0:	89 34 24             	mov    %esi,(%esp)
  8005f3:	e8 d0 fd ff ff       	call   8003c8 <fd2data>
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005fe:	89 d8                	mov    %ebx,%eax
  800600:	c1 e8 16             	shr    $0x16,%eax
  800603:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80060a:	a8 01                	test   $0x1,%al
  80060c:	74 11                	je     80061f <dup+0x71>
  80060e:	89 d8                	mov    %ebx,%eax
  800610:	c1 e8 0c             	shr    $0xc,%eax
  800613:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80061a:	f6 c2 01             	test   $0x1,%dl
  80061d:	75 36                	jne    800655 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061f:	89 f8                	mov    %edi,%eax
  800621:	c1 e8 0c             	shr    $0xc,%eax
  800624:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80062b:	83 ec 0c             	sub    $0xc,%esp
  80062e:	25 07 0e 00 00       	and    $0xe07,%eax
  800633:	50                   	push   %eax
  800634:	56                   	push   %esi
  800635:	6a 00                	push   $0x0
  800637:	57                   	push   %edi
  800638:	6a 00                	push   $0x0
  80063a:	e8 6a fb ff ff       	call   8001a9 <sys_page_map>
  80063f:	89 c3                	mov    %eax,%ebx
  800641:	83 c4 20             	add    $0x20,%esp
  800644:	85 c0                	test   %eax,%eax
  800646:	78 33                	js     80067b <dup+0xcd>
		goto err;

	return newfdnum;
  800648:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80064b:	89 d8                	mov    %ebx,%eax
  80064d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800650:	5b                   	pop    %ebx
  800651:	5e                   	pop    %esi
  800652:	5f                   	pop    %edi
  800653:	5d                   	pop    %ebp
  800654:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800655:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80065c:	83 ec 0c             	sub    $0xc,%esp
  80065f:	25 07 0e 00 00       	and    $0xe07,%eax
  800664:	50                   	push   %eax
  800665:	ff 75 d4             	push   -0x2c(%ebp)
  800668:	6a 00                	push   $0x0
  80066a:	53                   	push   %ebx
  80066b:	6a 00                	push   $0x0
  80066d:	e8 37 fb ff ff       	call   8001a9 <sys_page_map>
  800672:	89 c3                	mov    %eax,%ebx
  800674:	83 c4 20             	add    $0x20,%esp
  800677:	85 c0                	test   %eax,%eax
  800679:	79 a4                	jns    80061f <dup+0x71>
	sys_page_unmap(0, newfd);
  80067b:	83 ec 08             	sub    $0x8,%esp
  80067e:	56                   	push   %esi
  80067f:	6a 00                	push   $0x0
  800681:	e8 65 fb ff ff       	call   8001eb <sys_page_unmap>
	sys_page_unmap(0, nva);
  800686:	83 c4 08             	add    $0x8,%esp
  800689:	ff 75 d4             	push   -0x2c(%ebp)
  80068c:	6a 00                	push   $0x0
  80068e:	e8 58 fb ff ff       	call   8001eb <sys_page_unmap>
	return r;
  800693:	83 c4 10             	add    $0x10,%esp
  800696:	eb b3                	jmp    80064b <dup+0x9d>

00800698 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800698:	55                   	push   %ebp
  800699:	89 e5                	mov    %esp,%ebp
  80069b:	56                   	push   %esi
  80069c:	53                   	push   %ebx
  80069d:	83 ec 18             	sub    $0x18,%esp
  8006a0:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006a6:	50                   	push   %eax
  8006a7:	56                   	push   %esi
  8006a8:	e8 82 fd ff ff       	call   80042f <fd_lookup>
  8006ad:	83 c4 10             	add    $0x10,%esp
  8006b0:	85 c0                	test   %eax,%eax
  8006b2:	78 3c                	js     8006f0 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b4:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8006b7:	83 ec 08             	sub    $0x8,%esp
  8006ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006bd:	50                   	push   %eax
  8006be:	ff 33                	push   (%ebx)
  8006c0:	e8 ba fd ff ff       	call   80047f <dev_lookup>
  8006c5:	83 c4 10             	add    $0x10,%esp
  8006c8:	85 c0                	test   %eax,%eax
  8006ca:	78 24                	js     8006f0 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006cc:	8b 43 08             	mov    0x8(%ebx),%eax
  8006cf:	83 e0 03             	and    $0x3,%eax
  8006d2:	83 f8 01             	cmp    $0x1,%eax
  8006d5:	74 20                	je     8006f7 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006da:	8b 40 08             	mov    0x8(%eax),%eax
  8006dd:	85 c0                	test   %eax,%eax
  8006df:	74 37                	je     800718 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006e1:	83 ec 04             	sub    $0x4,%esp
  8006e4:	ff 75 10             	push   0x10(%ebp)
  8006e7:	ff 75 0c             	push   0xc(%ebp)
  8006ea:	53                   	push   %ebx
  8006eb:	ff d0                	call   *%eax
  8006ed:	83 c4 10             	add    $0x10,%esp
}
  8006f0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006f3:	5b                   	pop    %ebx
  8006f4:	5e                   	pop    %esi
  8006f5:	5d                   	pop    %ebp
  8006f6:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006f7:	a1 00 40 80 00       	mov    0x804000,%eax
  8006fc:	8b 40 58             	mov    0x58(%eax),%eax
  8006ff:	83 ec 04             	sub    $0x4,%esp
  800702:	56                   	push   %esi
  800703:	50                   	push   %eax
  800704:	68 b9 22 80 00       	push   $0x8022b9
  800709:	e8 93 0e 00 00       	call   8015a1 <cprintf>
		return -E_INVAL;
  80070e:	83 c4 10             	add    $0x10,%esp
  800711:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800716:	eb d8                	jmp    8006f0 <read+0x58>
		return -E_NOT_SUPP;
  800718:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80071d:	eb d1                	jmp    8006f0 <read+0x58>

0080071f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80071f:	55                   	push   %ebp
  800720:	89 e5                	mov    %esp,%ebp
  800722:	57                   	push   %edi
  800723:	56                   	push   %esi
  800724:	53                   	push   %ebx
  800725:	83 ec 0c             	sub    $0xc,%esp
  800728:	8b 7d 08             	mov    0x8(%ebp),%edi
  80072b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80072e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800733:	eb 02                	jmp    800737 <readn+0x18>
  800735:	01 c3                	add    %eax,%ebx
  800737:	39 f3                	cmp    %esi,%ebx
  800739:	73 21                	jae    80075c <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80073b:	83 ec 04             	sub    $0x4,%esp
  80073e:	89 f0                	mov    %esi,%eax
  800740:	29 d8                	sub    %ebx,%eax
  800742:	50                   	push   %eax
  800743:	89 d8                	mov    %ebx,%eax
  800745:	03 45 0c             	add    0xc(%ebp),%eax
  800748:	50                   	push   %eax
  800749:	57                   	push   %edi
  80074a:	e8 49 ff ff ff       	call   800698 <read>
		if (m < 0)
  80074f:	83 c4 10             	add    $0x10,%esp
  800752:	85 c0                	test   %eax,%eax
  800754:	78 04                	js     80075a <readn+0x3b>
			return m;
		if (m == 0)
  800756:	75 dd                	jne    800735 <readn+0x16>
  800758:	eb 02                	jmp    80075c <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80075a:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80075c:	89 d8                	mov    %ebx,%eax
  80075e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800761:	5b                   	pop    %ebx
  800762:	5e                   	pop    %esi
  800763:	5f                   	pop    %edi
  800764:	5d                   	pop    %ebp
  800765:	c3                   	ret    

00800766 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	56                   	push   %esi
  80076a:	53                   	push   %ebx
  80076b:	83 ec 18             	sub    $0x18,%esp
  80076e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800771:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800774:	50                   	push   %eax
  800775:	53                   	push   %ebx
  800776:	e8 b4 fc ff ff       	call   80042f <fd_lookup>
  80077b:	83 c4 10             	add    $0x10,%esp
  80077e:	85 c0                	test   %eax,%eax
  800780:	78 37                	js     8007b9 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800782:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800785:	83 ec 08             	sub    $0x8,%esp
  800788:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80078b:	50                   	push   %eax
  80078c:	ff 36                	push   (%esi)
  80078e:	e8 ec fc ff ff       	call   80047f <dev_lookup>
  800793:	83 c4 10             	add    $0x10,%esp
  800796:	85 c0                	test   %eax,%eax
  800798:	78 1f                	js     8007b9 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80079a:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80079e:	74 20                	je     8007c0 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007a3:	8b 40 0c             	mov    0xc(%eax),%eax
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	74 37                	je     8007e1 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007aa:	83 ec 04             	sub    $0x4,%esp
  8007ad:	ff 75 10             	push   0x10(%ebp)
  8007b0:	ff 75 0c             	push   0xc(%ebp)
  8007b3:	56                   	push   %esi
  8007b4:	ff d0                	call   *%eax
  8007b6:	83 c4 10             	add    $0x10,%esp
}
  8007b9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007bc:	5b                   	pop    %ebx
  8007bd:	5e                   	pop    %esi
  8007be:	5d                   	pop    %ebp
  8007bf:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007c0:	a1 00 40 80 00       	mov    0x804000,%eax
  8007c5:	8b 40 58             	mov    0x58(%eax),%eax
  8007c8:	83 ec 04             	sub    $0x4,%esp
  8007cb:	53                   	push   %ebx
  8007cc:	50                   	push   %eax
  8007cd:	68 d5 22 80 00       	push   $0x8022d5
  8007d2:	e8 ca 0d 00 00       	call   8015a1 <cprintf>
		return -E_INVAL;
  8007d7:	83 c4 10             	add    $0x10,%esp
  8007da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007df:	eb d8                	jmp    8007b9 <write+0x53>
		return -E_NOT_SUPP;
  8007e1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007e6:	eb d1                	jmp    8007b9 <write+0x53>

008007e8 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007f1:	50                   	push   %eax
  8007f2:	ff 75 08             	push   0x8(%ebp)
  8007f5:	e8 35 fc ff ff       	call   80042f <fd_lookup>
  8007fa:	83 c4 10             	add    $0x10,%esp
  8007fd:	85 c0                	test   %eax,%eax
  8007ff:	78 0e                	js     80080f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800801:	8b 55 0c             	mov    0xc(%ebp),%edx
  800804:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800807:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80080a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80080f:	c9                   	leave  
  800810:	c3                   	ret    

00800811 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800811:	55                   	push   %ebp
  800812:	89 e5                	mov    %esp,%ebp
  800814:	56                   	push   %esi
  800815:	53                   	push   %ebx
  800816:	83 ec 18             	sub    $0x18,%esp
  800819:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80081c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80081f:	50                   	push   %eax
  800820:	53                   	push   %ebx
  800821:	e8 09 fc ff ff       	call   80042f <fd_lookup>
  800826:	83 c4 10             	add    $0x10,%esp
  800829:	85 c0                	test   %eax,%eax
  80082b:	78 34                	js     800861 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082d:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800830:	83 ec 08             	sub    $0x8,%esp
  800833:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800836:	50                   	push   %eax
  800837:	ff 36                	push   (%esi)
  800839:	e8 41 fc ff ff       	call   80047f <dev_lookup>
  80083e:	83 c4 10             	add    $0x10,%esp
  800841:	85 c0                	test   %eax,%eax
  800843:	78 1c                	js     800861 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800845:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800849:	74 1d                	je     800868 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80084b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084e:	8b 40 18             	mov    0x18(%eax),%eax
  800851:	85 c0                	test   %eax,%eax
  800853:	74 34                	je     800889 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800855:	83 ec 08             	sub    $0x8,%esp
  800858:	ff 75 0c             	push   0xc(%ebp)
  80085b:	56                   	push   %esi
  80085c:	ff d0                	call   *%eax
  80085e:	83 c4 10             	add    $0x10,%esp
}
  800861:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800864:	5b                   	pop    %ebx
  800865:	5e                   	pop    %esi
  800866:	5d                   	pop    %ebp
  800867:	c3                   	ret    
			thisenv->env_id, fdnum);
  800868:	a1 00 40 80 00       	mov    0x804000,%eax
  80086d:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800870:	83 ec 04             	sub    $0x4,%esp
  800873:	53                   	push   %ebx
  800874:	50                   	push   %eax
  800875:	68 98 22 80 00       	push   $0x802298
  80087a:	e8 22 0d 00 00       	call   8015a1 <cprintf>
		return -E_INVAL;
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800887:	eb d8                	jmp    800861 <ftruncate+0x50>
		return -E_NOT_SUPP;
  800889:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80088e:	eb d1                	jmp    800861 <ftruncate+0x50>

00800890 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	56                   	push   %esi
  800894:	53                   	push   %ebx
  800895:	83 ec 18             	sub    $0x18,%esp
  800898:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80089b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80089e:	50                   	push   %eax
  80089f:	ff 75 08             	push   0x8(%ebp)
  8008a2:	e8 88 fb ff ff       	call   80042f <fd_lookup>
  8008a7:	83 c4 10             	add    $0x10,%esp
  8008aa:	85 c0                	test   %eax,%eax
  8008ac:	78 49                	js     8008f7 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ae:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8008b1:	83 ec 08             	sub    $0x8,%esp
  8008b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008b7:	50                   	push   %eax
  8008b8:	ff 36                	push   (%esi)
  8008ba:	e8 c0 fb ff ff       	call   80047f <dev_lookup>
  8008bf:	83 c4 10             	add    $0x10,%esp
  8008c2:	85 c0                	test   %eax,%eax
  8008c4:	78 31                	js     8008f7 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8008c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008cd:	74 2f                	je     8008fe <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008cf:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008d2:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008d9:	00 00 00 
	stat->st_isdir = 0;
  8008dc:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008e3:	00 00 00 
	stat->st_dev = dev;
  8008e6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ec:	83 ec 08             	sub    $0x8,%esp
  8008ef:	53                   	push   %ebx
  8008f0:	56                   	push   %esi
  8008f1:	ff 50 14             	call   *0x14(%eax)
  8008f4:	83 c4 10             	add    $0x10,%esp
}
  8008f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    
		return -E_NOT_SUPP;
  8008fe:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800903:	eb f2                	jmp    8008f7 <fstat+0x67>

00800905 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	56                   	push   %esi
  800909:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80090a:	83 ec 08             	sub    $0x8,%esp
  80090d:	6a 00                	push   $0x0
  80090f:	ff 75 08             	push   0x8(%ebp)
  800912:	e8 e4 01 00 00       	call   800afb <open>
  800917:	89 c3                	mov    %eax,%ebx
  800919:	83 c4 10             	add    $0x10,%esp
  80091c:	85 c0                	test   %eax,%eax
  80091e:	78 1b                	js     80093b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800920:	83 ec 08             	sub    $0x8,%esp
  800923:	ff 75 0c             	push   0xc(%ebp)
  800926:	50                   	push   %eax
  800927:	e8 64 ff ff ff       	call   800890 <fstat>
  80092c:	89 c6                	mov    %eax,%esi
	close(fd);
  80092e:	89 1c 24             	mov    %ebx,(%esp)
  800931:	e8 26 fc ff ff       	call   80055c <close>
	return r;
  800936:	83 c4 10             	add    $0x10,%esp
  800939:	89 f3                	mov    %esi,%ebx
}
  80093b:	89 d8                	mov    %ebx,%eax
  80093d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800940:	5b                   	pop    %ebx
  800941:	5e                   	pop    %esi
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	56                   	push   %esi
  800948:	53                   	push   %ebx
  800949:	89 c6                	mov    %eax,%esi
  80094b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80094d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800954:	74 27                	je     80097d <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800956:	6a 07                	push   $0x7
  800958:	68 00 50 80 00       	push   $0x805000
  80095d:	56                   	push   %esi
  80095e:	ff 35 00 60 80 00    	push   0x806000
  800964:	e8 c2 15 00 00       	call   801f2b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800969:	83 c4 0c             	add    $0xc,%esp
  80096c:	6a 00                	push   $0x0
  80096e:	53                   	push   %ebx
  80096f:	6a 00                	push   $0x0
  800971:	e8 45 15 00 00       	call   801ebb <ipc_recv>
}
  800976:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800979:	5b                   	pop    %ebx
  80097a:	5e                   	pop    %esi
  80097b:	5d                   	pop    %ebp
  80097c:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80097d:	83 ec 0c             	sub    $0xc,%esp
  800980:	6a 01                	push   $0x1
  800982:	e8 f8 15 00 00       	call   801f7f <ipc_find_env>
  800987:	a3 00 60 80 00       	mov    %eax,0x806000
  80098c:	83 c4 10             	add    $0x10,%esp
  80098f:	eb c5                	jmp    800956 <fsipc+0x12>

00800991 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800997:	8b 45 08             	mov    0x8(%ebp),%eax
  80099a:	8b 40 0c             	mov    0xc(%eax),%eax
  80099d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8009af:	b8 02 00 00 00       	mov    $0x2,%eax
  8009b4:	e8 8b ff ff ff       	call   800944 <fsipc>
}
  8009b9:	c9                   	leave  
  8009ba:	c3                   	ret    

008009bb <devfile_flush>:
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d1:	b8 06 00 00 00       	mov    $0x6,%eax
  8009d6:	e8 69 ff ff ff       	call   800944 <fsipc>
}
  8009db:	c9                   	leave  
  8009dc:	c3                   	ret    

008009dd <devfile_stat>:
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	53                   	push   %ebx
  8009e1:	83 ec 04             	sub    $0x4,%esp
  8009e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ed:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f7:	b8 05 00 00 00       	mov    $0x5,%eax
  8009fc:	e8 43 ff ff ff       	call   800944 <fsipc>
  800a01:	85 c0                	test   %eax,%eax
  800a03:	78 2c                	js     800a31 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a05:	83 ec 08             	sub    $0x8,%esp
  800a08:	68 00 50 80 00       	push   $0x805000
  800a0d:	53                   	push   %ebx
  800a0e:	e8 68 11 00 00       	call   801b7b <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a13:	a1 80 50 80 00       	mov    0x805080,%eax
  800a18:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a1e:	a1 84 50 80 00       	mov    0x805084,%eax
  800a23:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a29:	83 c4 10             	add    $0x10,%esp
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a31:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a34:	c9                   	leave  
  800a35:	c3                   	ret    

00800a36 <devfile_write>:
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	83 ec 0c             	sub    $0xc,%esp
  800a3c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a3f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a44:	39 d0                	cmp    %edx,%eax
  800a46:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a49:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4c:	8b 52 0c             	mov    0xc(%edx),%edx
  800a4f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a55:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a5a:	50                   	push   %eax
  800a5b:	ff 75 0c             	push   0xc(%ebp)
  800a5e:	68 08 50 80 00       	push   $0x805008
  800a63:	e8 a9 12 00 00       	call   801d11 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800a68:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6d:	b8 04 00 00 00       	mov    $0x4,%eax
  800a72:	e8 cd fe ff ff       	call   800944 <fsipc>
}
  800a77:	c9                   	leave  
  800a78:	c3                   	ret    

00800a79 <devfile_read>:
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	56                   	push   %esi
  800a7d:	53                   	push   %ebx
  800a7e:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a81:	8b 45 08             	mov    0x8(%ebp),%eax
  800a84:	8b 40 0c             	mov    0xc(%eax),%eax
  800a87:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a8c:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a92:	ba 00 00 00 00       	mov    $0x0,%edx
  800a97:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9c:	e8 a3 fe ff ff       	call   800944 <fsipc>
  800aa1:	89 c3                	mov    %eax,%ebx
  800aa3:	85 c0                	test   %eax,%eax
  800aa5:	78 1f                	js     800ac6 <devfile_read+0x4d>
	assert(r <= n);
  800aa7:	39 f0                	cmp    %esi,%eax
  800aa9:	77 24                	ja     800acf <devfile_read+0x56>
	assert(r <= PGSIZE);
  800aab:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ab0:	7f 33                	jg     800ae5 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ab2:	83 ec 04             	sub    $0x4,%esp
  800ab5:	50                   	push   %eax
  800ab6:	68 00 50 80 00       	push   $0x805000
  800abb:	ff 75 0c             	push   0xc(%ebp)
  800abe:	e8 4e 12 00 00       	call   801d11 <memmove>
	return r;
  800ac3:	83 c4 10             	add    $0x10,%esp
}
  800ac6:	89 d8                	mov    %ebx,%eax
  800ac8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800acb:	5b                   	pop    %ebx
  800acc:	5e                   	pop    %esi
  800acd:	5d                   	pop    %ebp
  800ace:	c3                   	ret    
	assert(r <= n);
  800acf:	68 08 23 80 00       	push   $0x802308
  800ad4:	68 0f 23 80 00       	push   $0x80230f
  800ad9:	6a 7c                	push   $0x7c
  800adb:	68 24 23 80 00       	push   $0x802324
  800ae0:	e8 e1 09 00 00       	call   8014c6 <_panic>
	assert(r <= PGSIZE);
  800ae5:	68 2f 23 80 00       	push   $0x80232f
  800aea:	68 0f 23 80 00       	push   $0x80230f
  800aef:	6a 7d                	push   $0x7d
  800af1:	68 24 23 80 00       	push   $0x802324
  800af6:	e8 cb 09 00 00       	call   8014c6 <_panic>

00800afb <open>:
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	56                   	push   %esi
  800aff:	53                   	push   %ebx
  800b00:	83 ec 1c             	sub    $0x1c,%esp
  800b03:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b06:	56                   	push   %esi
  800b07:	e8 34 10 00 00       	call   801b40 <strlen>
  800b0c:	83 c4 10             	add    $0x10,%esp
  800b0f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b14:	7f 6c                	jg     800b82 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800b16:	83 ec 0c             	sub    $0xc,%esp
  800b19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b1c:	50                   	push   %eax
  800b1d:	e8 bd f8 ff ff       	call   8003df <fd_alloc>
  800b22:	89 c3                	mov    %eax,%ebx
  800b24:	83 c4 10             	add    $0x10,%esp
  800b27:	85 c0                	test   %eax,%eax
  800b29:	78 3c                	js     800b67 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800b2b:	83 ec 08             	sub    $0x8,%esp
  800b2e:	56                   	push   %esi
  800b2f:	68 00 50 80 00       	push   $0x805000
  800b34:	e8 42 10 00 00       	call   801b7b <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3c:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b41:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b44:	b8 01 00 00 00       	mov    $0x1,%eax
  800b49:	e8 f6 fd ff ff       	call   800944 <fsipc>
  800b4e:	89 c3                	mov    %eax,%ebx
  800b50:	83 c4 10             	add    $0x10,%esp
  800b53:	85 c0                	test   %eax,%eax
  800b55:	78 19                	js     800b70 <open+0x75>
	return fd2num(fd);
  800b57:	83 ec 0c             	sub    $0xc,%esp
  800b5a:	ff 75 f4             	push   -0xc(%ebp)
  800b5d:	e8 56 f8 ff ff       	call   8003b8 <fd2num>
  800b62:	89 c3                	mov    %eax,%ebx
  800b64:	83 c4 10             	add    $0x10,%esp
}
  800b67:	89 d8                	mov    %ebx,%eax
  800b69:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5d                   	pop    %ebp
  800b6f:	c3                   	ret    
		fd_close(fd, 0);
  800b70:	83 ec 08             	sub    $0x8,%esp
  800b73:	6a 00                	push   $0x0
  800b75:	ff 75 f4             	push   -0xc(%ebp)
  800b78:	e8 58 f9 ff ff       	call   8004d5 <fd_close>
		return r;
  800b7d:	83 c4 10             	add    $0x10,%esp
  800b80:	eb e5                	jmp    800b67 <open+0x6c>
		return -E_BAD_PATH;
  800b82:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b87:	eb de                	jmp    800b67 <open+0x6c>

00800b89 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b89:	55                   	push   %ebp
  800b8a:	89 e5                	mov    %esp,%ebp
  800b8c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b8f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b94:	b8 08 00 00 00       	mov    $0x8,%eax
  800b99:	e8 a6 fd ff ff       	call   800944 <fsipc>
}
  800b9e:	c9                   	leave  
  800b9f:	c3                   	ret    

00800ba0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800ba6:	68 3b 23 80 00       	push   $0x80233b
  800bab:	ff 75 0c             	push   0xc(%ebp)
  800bae:	e8 c8 0f 00 00       	call   801b7b <strcpy>
	return 0;
}
  800bb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb8:	c9                   	leave  
  800bb9:	c3                   	ret    

00800bba <devsock_close>:
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	53                   	push   %ebx
  800bbe:	83 ec 10             	sub    $0x10,%esp
  800bc1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bc4:	53                   	push   %ebx
  800bc5:	e8 f4 13 00 00       	call   801fbe <pageref>
  800bca:	89 c2                	mov    %eax,%edx
  800bcc:	83 c4 10             	add    $0x10,%esp
		return 0;
  800bcf:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800bd4:	83 fa 01             	cmp    $0x1,%edx
  800bd7:	74 05                	je     800bde <devsock_close+0x24>
}
  800bd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bdc:	c9                   	leave  
  800bdd:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800bde:	83 ec 0c             	sub    $0xc,%esp
  800be1:	ff 73 0c             	push   0xc(%ebx)
  800be4:	e8 b7 02 00 00       	call   800ea0 <nsipc_close>
  800be9:	83 c4 10             	add    $0x10,%esp
  800bec:	eb eb                	jmp    800bd9 <devsock_close+0x1f>

00800bee <devsock_write>:
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bf4:	6a 00                	push   $0x0
  800bf6:	ff 75 10             	push   0x10(%ebp)
  800bf9:	ff 75 0c             	push   0xc(%ebp)
  800bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bff:	ff 70 0c             	push   0xc(%eax)
  800c02:	e8 79 03 00 00       	call   800f80 <nsipc_send>
}
  800c07:	c9                   	leave  
  800c08:	c3                   	ret    

00800c09 <devsock_read>:
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c0f:	6a 00                	push   $0x0
  800c11:	ff 75 10             	push   0x10(%ebp)
  800c14:	ff 75 0c             	push   0xc(%ebp)
  800c17:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1a:	ff 70 0c             	push   0xc(%eax)
  800c1d:	e8 ef 02 00 00       	call   800f11 <nsipc_recv>
}
  800c22:	c9                   	leave  
  800c23:	c3                   	ret    

00800c24 <fd2sockid>:
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c2a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c2d:	52                   	push   %edx
  800c2e:	50                   	push   %eax
  800c2f:	e8 fb f7 ff ff       	call   80042f <fd_lookup>
  800c34:	83 c4 10             	add    $0x10,%esp
  800c37:	85 c0                	test   %eax,%eax
  800c39:	78 10                	js     800c4b <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800c3b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c3e:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c44:	39 08                	cmp    %ecx,(%eax)
  800c46:	75 05                	jne    800c4d <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c48:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c4b:	c9                   	leave  
  800c4c:	c3                   	ret    
		return -E_NOT_SUPP;
  800c4d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c52:	eb f7                	jmp    800c4b <fd2sockid+0x27>

00800c54 <alloc_sockfd>:
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	56                   	push   %esi
  800c58:	53                   	push   %ebx
  800c59:	83 ec 1c             	sub    $0x1c,%esp
  800c5c:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c61:	50                   	push   %eax
  800c62:	e8 78 f7 ff ff       	call   8003df <fd_alloc>
  800c67:	89 c3                	mov    %eax,%ebx
  800c69:	83 c4 10             	add    $0x10,%esp
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	78 43                	js     800cb3 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c70:	83 ec 04             	sub    $0x4,%esp
  800c73:	68 07 04 00 00       	push   $0x407
  800c78:	ff 75 f4             	push   -0xc(%ebp)
  800c7b:	6a 00                	push   $0x0
  800c7d:	e8 e4 f4 ff ff       	call   800166 <sys_page_alloc>
  800c82:	89 c3                	mov    %eax,%ebx
  800c84:	83 c4 10             	add    $0x10,%esp
  800c87:	85 c0                	test   %eax,%eax
  800c89:	78 28                	js     800cb3 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c8e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c94:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c99:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800ca0:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800ca3:	83 ec 0c             	sub    $0xc,%esp
  800ca6:	50                   	push   %eax
  800ca7:	e8 0c f7 ff ff       	call   8003b8 <fd2num>
  800cac:	89 c3                	mov    %eax,%ebx
  800cae:	83 c4 10             	add    $0x10,%esp
  800cb1:	eb 0c                	jmp    800cbf <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800cb3:	83 ec 0c             	sub    $0xc,%esp
  800cb6:	56                   	push   %esi
  800cb7:	e8 e4 01 00 00       	call   800ea0 <nsipc_close>
		return r;
  800cbc:	83 c4 10             	add    $0x10,%esp
}
  800cbf:	89 d8                	mov    %ebx,%eax
  800cc1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cc4:	5b                   	pop    %ebx
  800cc5:	5e                   	pop    %esi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <accept>:
{
  800cc8:	55                   	push   %ebp
  800cc9:	89 e5                	mov    %esp,%ebp
  800ccb:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cce:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd1:	e8 4e ff ff ff       	call   800c24 <fd2sockid>
  800cd6:	85 c0                	test   %eax,%eax
  800cd8:	78 1b                	js     800cf5 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cda:	83 ec 04             	sub    $0x4,%esp
  800cdd:	ff 75 10             	push   0x10(%ebp)
  800ce0:	ff 75 0c             	push   0xc(%ebp)
  800ce3:	50                   	push   %eax
  800ce4:	e8 0e 01 00 00       	call   800df7 <nsipc_accept>
  800ce9:	83 c4 10             	add    $0x10,%esp
  800cec:	85 c0                	test   %eax,%eax
  800cee:	78 05                	js     800cf5 <accept+0x2d>
	return alloc_sockfd(r);
  800cf0:	e8 5f ff ff ff       	call   800c54 <alloc_sockfd>
}
  800cf5:	c9                   	leave  
  800cf6:	c3                   	ret    

00800cf7 <bind>:
{
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cfd:	8b 45 08             	mov    0x8(%ebp),%eax
  800d00:	e8 1f ff ff ff       	call   800c24 <fd2sockid>
  800d05:	85 c0                	test   %eax,%eax
  800d07:	78 12                	js     800d1b <bind+0x24>
	return nsipc_bind(r, name, namelen);
  800d09:	83 ec 04             	sub    $0x4,%esp
  800d0c:	ff 75 10             	push   0x10(%ebp)
  800d0f:	ff 75 0c             	push   0xc(%ebp)
  800d12:	50                   	push   %eax
  800d13:	e8 31 01 00 00       	call   800e49 <nsipc_bind>
  800d18:	83 c4 10             	add    $0x10,%esp
}
  800d1b:	c9                   	leave  
  800d1c:	c3                   	ret    

00800d1d <shutdown>:
{
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d23:	8b 45 08             	mov    0x8(%ebp),%eax
  800d26:	e8 f9 fe ff ff       	call   800c24 <fd2sockid>
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	78 0f                	js     800d3e <shutdown+0x21>
	return nsipc_shutdown(r, how);
  800d2f:	83 ec 08             	sub    $0x8,%esp
  800d32:	ff 75 0c             	push   0xc(%ebp)
  800d35:	50                   	push   %eax
  800d36:	e8 43 01 00 00       	call   800e7e <nsipc_shutdown>
  800d3b:	83 c4 10             	add    $0x10,%esp
}
  800d3e:	c9                   	leave  
  800d3f:	c3                   	ret    

00800d40 <connect>:
{
  800d40:	55                   	push   %ebp
  800d41:	89 e5                	mov    %esp,%ebp
  800d43:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d46:	8b 45 08             	mov    0x8(%ebp),%eax
  800d49:	e8 d6 fe ff ff       	call   800c24 <fd2sockid>
  800d4e:	85 c0                	test   %eax,%eax
  800d50:	78 12                	js     800d64 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  800d52:	83 ec 04             	sub    $0x4,%esp
  800d55:	ff 75 10             	push   0x10(%ebp)
  800d58:	ff 75 0c             	push   0xc(%ebp)
  800d5b:	50                   	push   %eax
  800d5c:	e8 59 01 00 00       	call   800eba <nsipc_connect>
  800d61:	83 c4 10             	add    $0x10,%esp
}
  800d64:	c9                   	leave  
  800d65:	c3                   	ret    

00800d66 <listen>:
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6f:	e8 b0 fe ff ff       	call   800c24 <fd2sockid>
  800d74:	85 c0                	test   %eax,%eax
  800d76:	78 0f                	js     800d87 <listen+0x21>
	return nsipc_listen(r, backlog);
  800d78:	83 ec 08             	sub    $0x8,%esp
  800d7b:	ff 75 0c             	push   0xc(%ebp)
  800d7e:	50                   	push   %eax
  800d7f:	e8 6b 01 00 00       	call   800eef <nsipc_listen>
  800d84:	83 c4 10             	add    $0x10,%esp
}
  800d87:	c9                   	leave  
  800d88:	c3                   	ret    

00800d89 <socket>:

int
socket(int domain, int type, int protocol)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d8f:	ff 75 10             	push   0x10(%ebp)
  800d92:	ff 75 0c             	push   0xc(%ebp)
  800d95:	ff 75 08             	push   0x8(%ebp)
  800d98:	e8 41 02 00 00       	call   800fde <nsipc_socket>
  800d9d:	83 c4 10             	add    $0x10,%esp
  800da0:	85 c0                	test   %eax,%eax
  800da2:	78 05                	js     800da9 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800da4:	e8 ab fe ff ff       	call   800c54 <alloc_sockfd>
}
  800da9:	c9                   	leave  
  800daa:	c3                   	ret    

00800dab <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800dab:	55                   	push   %ebp
  800dac:	89 e5                	mov    %esp,%ebp
  800dae:	53                   	push   %ebx
  800daf:	83 ec 04             	sub    $0x4,%esp
  800db2:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800db4:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  800dbb:	74 26                	je     800de3 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dbd:	6a 07                	push   $0x7
  800dbf:	68 00 70 80 00       	push   $0x807000
  800dc4:	53                   	push   %ebx
  800dc5:	ff 35 00 80 80 00    	push   0x808000
  800dcb:	e8 5b 11 00 00       	call   801f2b <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dd0:	83 c4 0c             	add    $0xc,%esp
  800dd3:	6a 00                	push   $0x0
  800dd5:	6a 00                	push   $0x0
  800dd7:	6a 00                	push   $0x0
  800dd9:	e8 dd 10 00 00       	call   801ebb <ipc_recv>
}
  800dde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800de1:	c9                   	leave  
  800de2:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	6a 02                	push   $0x2
  800de8:	e8 92 11 00 00       	call   801f7f <ipc_find_env>
  800ded:	a3 00 80 80 00       	mov    %eax,0x808000
  800df2:	83 c4 10             	add    $0x10,%esp
  800df5:	eb c6                	jmp    800dbd <nsipc+0x12>

00800df7 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800df7:	55                   	push   %ebp
  800df8:	89 e5                	mov    %esp,%ebp
  800dfa:	56                   	push   %esi
  800dfb:	53                   	push   %ebx
  800dfc:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800dff:	8b 45 08             	mov    0x8(%ebp),%eax
  800e02:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e07:	8b 06                	mov    (%esi),%eax
  800e09:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e0e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e13:	e8 93 ff ff ff       	call   800dab <nsipc>
  800e18:	89 c3                	mov    %eax,%ebx
  800e1a:	85 c0                	test   %eax,%eax
  800e1c:	79 09                	jns    800e27 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800e1e:	89 d8                	mov    %ebx,%eax
  800e20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e23:	5b                   	pop    %ebx
  800e24:	5e                   	pop    %esi
  800e25:	5d                   	pop    %ebp
  800e26:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e27:	83 ec 04             	sub    $0x4,%esp
  800e2a:	ff 35 10 70 80 00    	push   0x807010
  800e30:	68 00 70 80 00       	push   $0x807000
  800e35:	ff 75 0c             	push   0xc(%ebp)
  800e38:	e8 d4 0e 00 00       	call   801d11 <memmove>
		*addrlen = ret->ret_addrlen;
  800e3d:	a1 10 70 80 00       	mov    0x807010,%eax
  800e42:	89 06                	mov    %eax,(%esi)
  800e44:	83 c4 10             	add    $0x10,%esp
	return r;
  800e47:	eb d5                	jmp    800e1e <nsipc_accept+0x27>

00800e49 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 08             	sub    $0x8,%esp
  800e50:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e53:	8b 45 08             	mov    0x8(%ebp),%eax
  800e56:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e5b:	53                   	push   %ebx
  800e5c:	ff 75 0c             	push   0xc(%ebp)
  800e5f:	68 04 70 80 00       	push   $0x807004
  800e64:	e8 a8 0e 00 00       	call   801d11 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e69:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  800e6f:	b8 02 00 00 00       	mov    $0x2,%eax
  800e74:	e8 32 ff ff ff       	call   800dab <nsipc>
}
  800e79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e7c:	c9                   	leave  
  800e7d:	c3                   	ret    

00800e7e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e84:	8b 45 08             	mov    0x8(%ebp),%eax
  800e87:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  800e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8f:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  800e94:	b8 03 00 00 00       	mov    $0x3,%eax
  800e99:	e8 0d ff ff ff       	call   800dab <nsipc>
}
  800e9e:	c9                   	leave  
  800e9f:	c3                   	ret    

00800ea0 <nsipc_close>:

int
nsipc_close(int s)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea9:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  800eae:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb3:	e8 f3 fe ff ff       	call   800dab <nsipc>
}
  800eb8:	c9                   	leave  
  800eb9:	c3                   	ret    

00800eba <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	53                   	push   %ebx
  800ebe:	83 ec 08             	sub    $0x8,%esp
  800ec1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec7:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ecc:	53                   	push   %ebx
  800ecd:	ff 75 0c             	push   0xc(%ebp)
  800ed0:	68 04 70 80 00       	push   $0x807004
  800ed5:	e8 37 0e 00 00       	call   801d11 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800eda:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  800ee0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ee5:	e8 c1 fe ff ff       	call   800dab <nsipc>
}
  800eea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eed:	c9                   	leave  
  800eee:	c3                   	ret    

00800eef <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ef5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef8:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  800efd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f00:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  800f05:	b8 06 00 00 00       	mov    $0x6,%eax
  800f0a:	e8 9c fe ff ff       	call   800dab <nsipc>
}
  800f0f:	c9                   	leave  
  800f10:	c3                   	ret    

00800f11 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	56                   	push   %esi
  800f15:	53                   	push   %ebx
  800f16:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f19:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  800f21:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  800f27:	8b 45 14             	mov    0x14(%ebp),%eax
  800f2a:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f2f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f34:	e8 72 fe ff ff       	call   800dab <nsipc>
  800f39:	89 c3                	mov    %eax,%ebx
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	78 22                	js     800f61 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  800f3f:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f44:	39 c6                	cmp    %eax,%esi
  800f46:	0f 4e c6             	cmovle %esi,%eax
  800f49:	39 c3                	cmp    %eax,%ebx
  800f4b:	7f 1d                	jg     800f6a <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f4d:	83 ec 04             	sub    $0x4,%esp
  800f50:	53                   	push   %ebx
  800f51:	68 00 70 80 00       	push   $0x807000
  800f56:	ff 75 0c             	push   0xc(%ebp)
  800f59:	e8 b3 0d 00 00       	call   801d11 <memmove>
  800f5e:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f61:	89 d8                	mov    %ebx,%eax
  800f63:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f66:	5b                   	pop    %ebx
  800f67:	5e                   	pop    %esi
  800f68:	5d                   	pop    %ebp
  800f69:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f6a:	68 47 23 80 00       	push   $0x802347
  800f6f:	68 0f 23 80 00       	push   $0x80230f
  800f74:	6a 62                	push   $0x62
  800f76:	68 5c 23 80 00       	push   $0x80235c
  800f7b:	e8 46 05 00 00       	call   8014c6 <_panic>

00800f80 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	53                   	push   %ebx
  800f84:	83 ec 04             	sub    $0x4,%esp
  800f87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8d:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  800f92:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f98:	7f 2e                	jg     800fc8 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f9a:	83 ec 04             	sub    $0x4,%esp
  800f9d:	53                   	push   %ebx
  800f9e:	ff 75 0c             	push   0xc(%ebp)
  800fa1:	68 0c 70 80 00       	push   $0x80700c
  800fa6:	e8 66 0d 00 00       	call   801d11 <memmove>
	nsipcbuf.send.req_size = size;
  800fab:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  800fb1:	8b 45 14             	mov    0x14(%ebp),%eax
  800fb4:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  800fb9:	b8 08 00 00 00       	mov    $0x8,%eax
  800fbe:	e8 e8 fd ff ff       	call   800dab <nsipc>
}
  800fc3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fc6:	c9                   	leave  
  800fc7:	c3                   	ret    
	assert(size < 1600);
  800fc8:	68 68 23 80 00       	push   $0x802368
  800fcd:	68 0f 23 80 00       	push   $0x80230f
  800fd2:	6a 6d                	push   $0x6d
  800fd4:	68 5c 23 80 00       	push   $0x80235c
  800fd9:	e8 e8 04 00 00       	call   8014c6 <_panic>

00800fde <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fde:	55                   	push   %ebp
  800fdf:	89 e5                	mov    %esp,%ebp
  800fe1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fe4:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  800fec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fef:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  800ff4:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff7:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  800ffc:	b8 09 00 00 00       	mov    $0x9,%eax
  801001:	e8 a5 fd ff ff       	call   800dab <nsipc>
}
  801006:	c9                   	leave  
  801007:	c3                   	ret    

00801008 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801008:	55                   	push   %ebp
  801009:	89 e5                	mov    %esp,%ebp
  80100b:	56                   	push   %esi
  80100c:	53                   	push   %ebx
  80100d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801010:	83 ec 0c             	sub    $0xc,%esp
  801013:	ff 75 08             	push   0x8(%ebp)
  801016:	e8 ad f3 ff ff       	call   8003c8 <fd2data>
  80101b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80101d:	83 c4 08             	add    $0x8,%esp
  801020:	68 74 23 80 00       	push   $0x802374
  801025:	53                   	push   %ebx
  801026:	e8 50 0b 00 00       	call   801b7b <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80102b:	8b 46 04             	mov    0x4(%esi),%eax
  80102e:	2b 06                	sub    (%esi),%eax
  801030:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801036:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80103d:	00 00 00 
	stat->st_dev = &devpipe;
  801040:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801047:	30 80 00 
	return 0;
}
  80104a:	b8 00 00 00 00       	mov    $0x0,%eax
  80104f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801052:	5b                   	pop    %ebx
  801053:	5e                   	pop    %esi
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	53                   	push   %ebx
  80105a:	83 ec 0c             	sub    $0xc,%esp
  80105d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801060:	53                   	push   %ebx
  801061:	6a 00                	push   $0x0
  801063:	e8 83 f1 ff ff       	call   8001eb <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801068:	89 1c 24             	mov    %ebx,(%esp)
  80106b:	e8 58 f3 ff ff       	call   8003c8 <fd2data>
  801070:	83 c4 08             	add    $0x8,%esp
  801073:	50                   	push   %eax
  801074:	6a 00                	push   $0x0
  801076:	e8 70 f1 ff ff       	call   8001eb <sys_page_unmap>
}
  80107b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107e:	c9                   	leave  
  80107f:	c3                   	ret    

00801080 <_pipeisclosed>:
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	57                   	push   %edi
  801084:	56                   	push   %esi
  801085:	53                   	push   %ebx
  801086:	83 ec 1c             	sub    $0x1c,%esp
  801089:	89 c7                	mov    %eax,%edi
  80108b:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80108d:	a1 00 40 80 00       	mov    0x804000,%eax
  801092:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801095:	83 ec 0c             	sub    $0xc,%esp
  801098:	57                   	push   %edi
  801099:	e8 20 0f 00 00       	call   801fbe <pageref>
  80109e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010a1:	89 34 24             	mov    %esi,(%esp)
  8010a4:	e8 15 0f 00 00       	call   801fbe <pageref>
		nn = thisenv->env_runs;
  8010a9:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8010af:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  8010b2:	83 c4 10             	add    $0x10,%esp
  8010b5:	39 cb                	cmp    %ecx,%ebx
  8010b7:	74 1b                	je     8010d4 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010b9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010bc:	75 cf                	jne    80108d <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010be:	8b 42 68             	mov    0x68(%edx),%eax
  8010c1:	6a 01                	push   $0x1
  8010c3:	50                   	push   %eax
  8010c4:	53                   	push   %ebx
  8010c5:	68 7b 23 80 00       	push   $0x80237b
  8010ca:	e8 d2 04 00 00       	call   8015a1 <cprintf>
  8010cf:	83 c4 10             	add    $0x10,%esp
  8010d2:	eb b9                	jmp    80108d <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010d4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010d7:	0f 94 c0             	sete   %al
  8010da:	0f b6 c0             	movzbl %al,%eax
}
  8010dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e0:	5b                   	pop    %ebx
  8010e1:	5e                   	pop    %esi
  8010e2:	5f                   	pop    %edi
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    

008010e5 <devpipe_write>:
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	57                   	push   %edi
  8010e9:	56                   	push   %esi
  8010ea:	53                   	push   %ebx
  8010eb:	83 ec 28             	sub    $0x28,%esp
  8010ee:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8010f1:	56                   	push   %esi
  8010f2:	e8 d1 f2 ff ff       	call   8003c8 <fd2data>
  8010f7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8010f9:	83 c4 10             	add    $0x10,%esp
  8010fc:	bf 00 00 00 00       	mov    $0x0,%edi
  801101:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801104:	75 09                	jne    80110f <devpipe_write+0x2a>
	return i;
  801106:	89 f8                	mov    %edi,%eax
  801108:	eb 23                	jmp    80112d <devpipe_write+0x48>
			sys_yield();
  80110a:	e8 38 f0 ff ff       	call   800147 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80110f:	8b 43 04             	mov    0x4(%ebx),%eax
  801112:	8b 0b                	mov    (%ebx),%ecx
  801114:	8d 51 20             	lea    0x20(%ecx),%edx
  801117:	39 d0                	cmp    %edx,%eax
  801119:	72 1a                	jb     801135 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  80111b:	89 da                	mov    %ebx,%edx
  80111d:	89 f0                	mov    %esi,%eax
  80111f:	e8 5c ff ff ff       	call   801080 <_pipeisclosed>
  801124:	85 c0                	test   %eax,%eax
  801126:	74 e2                	je     80110a <devpipe_write+0x25>
				return 0;
  801128:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80112d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801130:	5b                   	pop    %ebx
  801131:	5e                   	pop    %esi
  801132:	5f                   	pop    %edi
  801133:	5d                   	pop    %ebp
  801134:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801135:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801138:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80113c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80113f:	89 c2                	mov    %eax,%edx
  801141:	c1 fa 1f             	sar    $0x1f,%edx
  801144:	89 d1                	mov    %edx,%ecx
  801146:	c1 e9 1b             	shr    $0x1b,%ecx
  801149:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80114c:	83 e2 1f             	and    $0x1f,%edx
  80114f:	29 ca                	sub    %ecx,%edx
  801151:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801155:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801159:	83 c0 01             	add    $0x1,%eax
  80115c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80115f:	83 c7 01             	add    $0x1,%edi
  801162:	eb 9d                	jmp    801101 <devpipe_write+0x1c>

00801164 <devpipe_read>:
{
  801164:	55                   	push   %ebp
  801165:	89 e5                	mov    %esp,%ebp
  801167:	57                   	push   %edi
  801168:	56                   	push   %esi
  801169:	53                   	push   %ebx
  80116a:	83 ec 18             	sub    $0x18,%esp
  80116d:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801170:	57                   	push   %edi
  801171:	e8 52 f2 ff ff       	call   8003c8 <fd2data>
  801176:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801178:	83 c4 10             	add    $0x10,%esp
  80117b:	be 00 00 00 00       	mov    $0x0,%esi
  801180:	3b 75 10             	cmp    0x10(%ebp),%esi
  801183:	75 13                	jne    801198 <devpipe_read+0x34>
	return i;
  801185:	89 f0                	mov    %esi,%eax
  801187:	eb 02                	jmp    80118b <devpipe_read+0x27>
				return i;
  801189:	89 f0                	mov    %esi,%eax
}
  80118b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80118e:	5b                   	pop    %ebx
  80118f:	5e                   	pop    %esi
  801190:	5f                   	pop    %edi
  801191:	5d                   	pop    %ebp
  801192:	c3                   	ret    
			sys_yield();
  801193:	e8 af ef ff ff       	call   800147 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801198:	8b 03                	mov    (%ebx),%eax
  80119a:	3b 43 04             	cmp    0x4(%ebx),%eax
  80119d:	75 18                	jne    8011b7 <devpipe_read+0x53>
			if (i > 0)
  80119f:	85 f6                	test   %esi,%esi
  8011a1:	75 e6                	jne    801189 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8011a3:	89 da                	mov    %ebx,%edx
  8011a5:	89 f8                	mov    %edi,%eax
  8011a7:	e8 d4 fe ff ff       	call   801080 <_pipeisclosed>
  8011ac:	85 c0                	test   %eax,%eax
  8011ae:	74 e3                	je     801193 <devpipe_read+0x2f>
				return 0;
  8011b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b5:	eb d4                	jmp    80118b <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011b7:	99                   	cltd   
  8011b8:	c1 ea 1b             	shr    $0x1b,%edx
  8011bb:	01 d0                	add    %edx,%eax
  8011bd:	83 e0 1f             	and    $0x1f,%eax
  8011c0:	29 d0                	sub    %edx,%eax
  8011c2:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011ca:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011cd:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011d0:	83 c6 01             	add    $0x1,%esi
  8011d3:	eb ab                	jmp    801180 <devpipe_read+0x1c>

008011d5 <pipe>:
{
  8011d5:	55                   	push   %ebp
  8011d6:	89 e5                	mov    %esp,%ebp
  8011d8:	56                   	push   %esi
  8011d9:	53                   	push   %ebx
  8011da:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e0:	50                   	push   %eax
  8011e1:	e8 f9 f1 ff ff       	call   8003df <fd_alloc>
  8011e6:	89 c3                	mov    %eax,%ebx
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	0f 88 23 01 00 00    	js     801316 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011f3:	83 ec 04             	sub    $0x4,%esp
  8011f6:	68 07 04 00 00       	push   $0x407
  8011fb:	ff 75 f4             	push   -0xc(%ebp)
  8011fe:	6a 00                	push   $0x0
  801200:	e8 61 ef ff ff       	call   800166 <sys_page_alloc>
  801205:	89 c3                	mov    %eax,%ebx
  801207:	83 c4 10             	add    $0x10,%esp
  80120a:	85 c0                	test   %eax,%eax
  80120c:	0f 88 04 01 00 00    	js     801316 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801212:	83 ec 0c             	sub    $0xc,%esp
  801215:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801218:	50                   	push   %eax
  801219:	e8 c1 f1 ff ff       	call   8003df <fd_alloc>
  80121e:	89 c3                	mov    %eax,%ebx
  801220:	83 c4 10             	add    $0x10,%esp
  801223:	85 c0                	test   %eax,%eax
  801225:	0f 88 db 00 00 00    	js     801306 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80122b:	83 ec 04             	sub    $0x4,%esp
  80122e:	68 07 04 00 00       	push   $0x407
  801233:	ff 75 f0             	push   -0x10(%ebp)
  801236:	6a 00                	push   $0x0
  801238:	e8 29 ef ff ff       	call   800166 <sys_page_alloc>
  80123d:	89 c3                	mov    %eax,%ebx
  80123f:	83 c4 10             	add    $0x10,%esp
  801242:	85 c0                	test   %eax,%eax
  801244:	0f 88 bc 00 00 00    	js     801306 <pipe+0x131>
	va = fd2data(fd0);
  80124a:	83 ec 0c             	sub    $0xc,%esp
  80124d:	ff 75 f4             	push   -0xc(%ebp)
  801250:	e8 73 f1 ff ff       	call   8003c8 <fd2data>
  801255:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801257:	83 c4 0c             	add    $0xc,%esp
  80125a:	68 07 04 00 00       	push   $0x407
  80125f:	50                   	push   %eax
  801260:	6a 00                	push   $0x0
  801262:	e8 ff ee ff ff       	call   800166 <sys_page_alloc>
  801267:	89 c3                	mov    %eax,%ebx
  801269:	83 c4 10             	add    $0x10,%esp
  80126c:	85 c0                	test   %eax,%eax
  80126e:	0f 88 82 00 00 00    	js     8012f6 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801274:	83 ec 0c             	sub    $0xc,%esp
  801277:	ff 75 f0             	push   -0x10(%ebp)
  80127a:	e8 49 f1 ff ff       	call   8003c8 <fd2data>
  80127f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801286:	50                   	push   %eax
  801287:	6a 00                	push   $0x0
  801289:	56                   	push   %esi
  80128a:	6a 00                	push   $0x0
  80128c:	e8 18 ef ff ff       	call   8001a9 <sys_page_map>
  801291:	89 c3                	mov    %eax,%ebx
  801293:	83 c4 20             	add    $0x20,%esp
  801296:	85 c0                	test   %eax,%eax
  801298:	78 4e                	js     8012e8 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  80129a:	a1 3c 30 80 00       	mov    0x80303c,%eax
  80129f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a2:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8012a4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012a7:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8012ae:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012b1:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012bd:	83 ec 0c             	sub    $0xc,%esp
  8012c0:	ff 75 f4             	push   -0xc(%ebp)
  8012c3:	e8 f0 f0 ff ff       	call   8003b8 <fd2num>
  8012c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012cb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012cd:	83 c4 04             	add    $0x4,%esp
  8012d0:	ff 75 f0             	push   -0x10(%ebp)
  8012d3:	e8 e0 f0 ff ff       	call   8003b8 <fd2num>
  8012d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012db:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012e6:	eb 2e                	jmp    801316 <pipe+0x141>
	sys_page_unmap(0, va);
  8012e8:	83 ec 08             	sub    $0x8,%esp
  8012eb:	56                   	push   %esi
  8012ec:	6a 00                	push   $0x0
  8012ee:	e8 f8 ee ff ff       	call   8001eb <sys_page_unmap>
  8012f3:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8012f6:	83 ec 08             	sub    $0x8,%esp
  8012f9:	ff 75 f0             	push   -0x10(%ebp)
  8012fc:	6a 00                	push   $0x0
  8012fe:	e8 e8 ee ff ff       	call   8001eb <sys_page_unmap>
  801303:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801306:	83 ec 08             	sub    $0x8,%esp
  801309:	ff 75 f4             	push   -0xc(%ebp)
  80130c:	6a 00                	push   $0x0
  80130e:	e8 d8 ee ff ff       	call   8001eb <sys_page_unmap>
  801313:	83 c4 10             	add    $0x10,%esp
}
  801316:	89 d8                	mov    %ebx,%eax
  801318:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80131b:	5b                   	pop    %ebx
  80131c:	5e                   	pop    %esi
  80131d:	5d                   	pop    %ebp
  80131e:	c3                   	ret    

0080131f <pipeisclosed>:
{
  80131f:	55                   	push   %ebp
  801320:	89 e5                	mov    %esp,%ebp
  801322:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801325:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801328:	50                   	push   %eax
  801329:	ff 75 08             	push   0x8(%ebp)
  80132c:	e8 fe f0 ff ff       	call   80042f <fd_lookup>
  801331:	83 c4 10             	add    $0x10,%esp
  801334:	85 c0                	test   %eax,%eax
  801336:	78 18                	js     801350 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801338:	83 ec 0c             	sub    $0xc,%esp
  80133b:	ff 75 f4             	push   -0xc(%ebp)
  80133e:	e8 85 f0 ff ff       	call   8003c8 <fd2data>
  801343:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801345:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801348:	e8 33 fd ff ff       	call   801080 <_pipeisclosed>
  80134d:	83 c4 10             	add    $0x10,%esp
}
  801350:	c9                   	leave  
  801351:	c3                   	ret    

00801352 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801352:	b8 00 00 00 00       	mov    $0x0,%eax
  801357:	c3                   	ret    

00801358 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801358:	55                   	push   %ebp
  801359:	89 e5                	mov    %esp,%ebp
  80135b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80135e:	68 93 23 80 00       	push   $0x802393
  801363:	ff 75 0c             	push   0xc(%ebp)
  801366:	e8 10 08 00 00       	call   801b7b <strcpy>
	return 0;
}
  80136b:	b8 00 00 00 00       	mov    $0x0,%eax
  801370:	c9                   	leave  
  801371:	c3                   	ret    

00801372 <devcons_write>:
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	57                   	push   %edi
  801376:	56                   	push   %esi
  801377:	53                   	push   %ebx
  801378:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80137e:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801383:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801389:	eb 2e                	jmp    8013b9 <devcons_write+0x47>
		m = n - tot;
  80138b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80138e:	29 f3                	sub    %esi,%ebx
  801390:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801395:	39 c3                	cmp    %eax,%ebx
  801397:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80139a:	83 ec 04             	sub    $0x4,%esp
  80139d:	53                   	push   %ebx
  80139e:	89 f0                	mov    %esi,%eax
  8013a0:	03 45 0c             	add    0xc(%ebp),%eax
  8013a3:	50                   	push   %eax
  8013a4:	57                   	push   %edi
  8013a5:	e8 67 09 00 00       	call   801d11 <memmove>
		sys_cputs(buf, m);
  8013aa:	83 c4 08             	add    $0x8,%esp
  8013ad:	53                   	push   %ebx
  8013ae:	57                   	push   %edi
  8013af:	e8 f6 ec ff ff       	call   8000aa <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013b4:	01 de                	add    %ebx,%esi
  8013b6:	83 c4 10             	add    $0x10,%esp
  8013b9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013bc:	72 cd                	jb     80138b <devcons_write+0x19>
}
  8013be:	89 f0                	mov    %esi,%eax
  8013c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013c3:	5b                   	pop    %ebx
  8013c4:	5e                   	pop    %esi
  8013c5:	5f                   	pop    %edi
  8013c6:	5d                   	pop    %ebp
  8013c7:	c3                   	ret    

008013c8 <devcons_read>:
{
  8013c8:	55                   	push   %ebp
  8013c9:	89 e5                	mov    %esp,%ebp
  8013cb:	83 ec 08             	sub    $0x8,%esp
  8013ce:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8013d3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013d7:	75 07                	jne    8013e0 <devcons_read+0x18>
  8013d9:	eb 1f                	jmp    8013fa <devcons_read+0x32>
		sys_yield();
  8013db:	e8 67 ed ff ff       	call   800147 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8013e0:	e8 e3 ec ff ff       	call   8000c8 <sys_cgetc>
  8013e5:	85 c0                	test   %eax,%eax
  8013e7:	74 f2                	je     8013db <devcons_read+0x13>
	if (c < 0)
  8013e9:	78 0f                	js     8013fa <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8013eb:	83 f8 04             	cmp    $0x4,%eax
  8013ee:	74 0c                	je     8013fc <devcons_read+0x34>
	*(char*)vbuf = c;
  8013f0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013f3:	88 02                	mov    %al,(%edx)
	return 1;
  8013f5:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8013fa:	c9                   	leave  
  8013fb:	c3                   	ret    
		return 0;
  8013fc:	b8 00 00 00 00       	mov    $0x0,%eax
  801401:	eb f7                	jmp    8013fa <devcons_read+0x32>

00801403 <cputchar>:
{
  801403:	55                   	push   %ebp
  801404:	89 e5                	mov    %esp,%ebp
  801406:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801409:	8b 45 08             	mov    0x8(%ebp),%eax
  80140c:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80140f:	6a 01                	push   $0x1
  801411:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801414:	50                   	push   %eax
  801415:	e8 90 ec ff ff       	call   8000aa <sys_cputs>
}
  80141a:	83 c4 10             	add    $0x10,%esp
  80141d:	c9                   	leave  
  80141e:	c3                   	ret    

0080141f <getchar>:
{
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801425:	6a 01                	push   $0x1
  801427:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80142a:	50                   	push   %eax
  80142b:	6a 00                	push   $0x0
  80142d:	e8 66 f2 ff ff       	call   800698 <read>
	if (r < 0)
  801432:	83 c4 10             	add    $0x10,%esp
  801435:	85 c0                	test   %eax,%eax
  801437:	78 06                	js     80143f <getchar+0x20>
	if (r < 1)
  801439:	74 06                	je     801441 <getchar+0x22>
	return c;
  80143b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80143f:	c9                   	leave  
  801440:	c3                   	ret    
		return -E_EOF;
  801441:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801446:	eb f7                	jmp    80143f <getchar+0x20>

00801448 <iscons>:
{
  801448:	55                   	push   %ebp
  801449:	89 e5                	mov    %esp,%ebp
  80144b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80144e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801451:	50                   	push   %eax
  801452:	ff 75 08             	push   0x8(%ebp)
  801455:	e8 d5 ef ff ff       	call   80042f <fd_lookup>
  80145a:	83 c4 10             	add    $0x10,%esp
  80145d:	85 c0                	test   %eax,%eax
  80145f:	78 11                	js     801472 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801461:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801464:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80146a:	39 10                	cmp    %edx,(%eax)
  80146c:	0f 94 c0             	sete   %al
  80146f:	0f b6 c0             	movzbl %al,%eax
}
  801472:	c9                   	leave  
  801473:	c3                   	ret    

00801474 <opencons>:
{
  801474:	55                   	push   %ebp
  801475:	89 e5                	mov    %esp,%ebp
  801477:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80147a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147d:	50                   	push   %eax
  80147e:	e8 5c ef ff ff       	call   8003df <fd_alloc>
  801483:	83 c4 10             	add    $0x10,%esp
  801486:	85 c0                	test   %eax,%eax
  801488:	78 3a                	js     8014c4 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80148a:	83 ec 04             	sub    $0x4,%esp
  80148d:	68 07 04 00 00       	push   $0x407
  801492:	ff 75 f4             	push   -0xc(%ebp)
  801495:	6a 00                	push   $0x0
  801497:	e8 ca ec ff ff       	call   800166 <sys_page_alloc>
  80149c:	83 c4 10             	add    $0x10,%esp
  80149f:	85 c0                	test   %eax,%eax
  8014a1:	78 21                	js     8014c4 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8014a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a6:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014ac:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014b1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014b8:	83 ec 0c             	sub    $0xc,%esp
  8014bb:	50                   	push   %eax
  8014bc:	e8 f7 ee ff ff       	call   8003b8 <fd2num>
  8014c1:	83 c4 10             	add    $0x10,%esp
}
  8014c4:	c9                   	leave  
  8014c5:	c3                   	ret    

008014c6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014c6:	55                   	push   %ebp
  8014c7:	89 e5                	mov    %esp,%ebp
  8014c9:	56                   	push   %esi
  8014ca:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014cb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014ce:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014d4:	e8 4f ec ff ff       	call   800128 <sys_getenvid>
  8014d9:	83 ec 0c             	sub    $0xc,%esp
  8014dc:	ff 75 0c             	push   0xc(%ebp)
  8014df:	ff 75 08             	push   0x8(%ebp)
  8014e2:	56                   	push   %esi
  8014e3:	50                   	push   %eax
  8014e4:	68 a0 23 80 00       	push   $0x8023a0
  8014e9:	e8 b3 00 00 00       	call   8015a1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014ee:	83 c4 18             	add    $0x18,%esp
  8014f1:	53                   	push   %ebx
  8014f2:	ff 75 10             	push   0x10(%ebp)
  8014f5:	e8 56 00 00 00       	call   801550 <vcprintf>
	cprintf("\n");
  8014fa:	c7 04 24 8c 23 80 00 	movl   $0x80238c,(%esp)
  801501:	e8 9b 00 00 00       	call   8015a1 <cprintf>
  801506:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801509:	cc                   	int3   
  80150a:	eb fd                	jmp    801509 <_panic+0x43>

0080150c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80150c:	55                   	push   %ebp
  80150d:	89 e5                	mov    %esp,%ebp
  80150f:	53                   	push   %ebx
  801510:	83 ec 04             	sub    $0x4,%esp
  801513:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801516:	8b 13                	mov    (%ebx),%edx
  801518:	8d 42 01             	lea    0x1(%edx),%eax
  80151b:	89 03                	mov    %eax,(%ebx)
  80151d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801520:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801524:	3d ff 00 00 00       	cmp    $0xff,%eax
  801529:	74 09                	je     801534 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80152b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80152f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801532:	c9                   	leave  
  801533:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801534:	83 ec 08             	sub    $0x8,%esp
  801537:	68 ff 00 00 00       	push   $0xff
  80153c:	8d 43 08             	lea    0x8(%ebx),%eax
  80153f:	50                   	push   %eax
  801540:	e8 65 eb ff ff       	call   8000aa <sys_cputs>
		b->idx = 0;
  801545:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80154b:	83 c4 10             	add    $0x10,%esp
  80154e:	eb db                	jmp    80152b <putch+0x1f>

00801550 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801550:	55                   	push   %ebp
  801551:	89 e5                	mov    %esp,%ebp
  801553:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801559:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801560:	00 00 00 
	b.cnt = 0;
  801563:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80156a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80156d:	ff 75 0c             	push   0xc(%ebp)
  801570:	ff 75 08             	push   0x8(%ebp)
  801573:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801579:	50                   	push   %eax
  80157a:	68 0c 15 80 00       	push   $0x80150c
  80157f:	e8 14 01 00 00       	call   801698 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801584:	83 c4 08             	add    $0x8,%esp
  801587:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80158d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801593:	50                   	push   %eax
  801594:	e8 11 eb ff ff       	call   8000aa <sys_cputs>

	return b.cnt;
}
  801599:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80159f:	c9                   	leave  
  8015a0:	c3                   	ret    

008015a1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015a7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015aa:	50                   	push   %eax
  8015ab:	ff 75 08             	push   0x8(%ebp)
  8015ae:	e8 9d ff ff ff       	call   801550 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015b3:	c9                   	leave  
  8015b4:	c3                   	ret    

008015b5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015b5:	55                   	push   %ebp
  8015b6:	89 e5                	mov    %esp,%ebp
  8015b8:	57                   	push   %edi
  8015b9:	56                   	push   %esi
  8015ba:	53                   	push   %ebx
  8015bb:	83 ec 1c             	sub    $0x1c,%esp
  8015be:	89 c7                	mov    %eax,%edi
  8015c0:	89 d6                	mov    %edx,%esi
  8015c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015c5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015c8:	89 d1                	mov    %edx,%ecx
  8015ca:	89 c2                	mov    %eax,%edx
  8015cc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015cf:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8015d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8015d5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015d8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015db:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8015e2:	39 c2                	cmp    %eax,%edx
  8015e4:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8015e7:	72 3e                	jb     801627 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015e9:	83 ec 0c             	sub    $0xc,%esp
  8015ec:	ff 75 18             	push   0x18(%ebp)
  8015ef:	83 eb 01             	sub    $0x1,%ebx
  8015f2:	53                   	push   %ebx
  8015f3:	50                   	push   %eax
  8015f4:	83 ec 08             	sub    $0x8,%esp
  8015f7:	ff 75 e4             	push   -0x1c(%ebp)
  8015fa:	ff 75 e0             	push   -0x20(%ebp)
  8015fd:	ff 75 dc             	push   -0x24(%ebp)
  801600:	ff 75 d8             	push   -0x28(%ebp)
  801603:	e8 f8 09 00 00       	call   802000 <__udivdi3>
  801608:	83 c4 18             	add    $0x18,%esp
  80160b:	52                   	push   %edx
  80160c:	50                   	push   %eax
  80160d:	89 f2                	mov    %esi,%edx
  80160f:	89 f8                	mov    %edi,%eax
  801611:	e8 9f ff ff ff       	call   8015b5 <printnum>
  801616:	83 c4 20             	add    $0x20,%esp
  801619:	eb 13                	jmp    80162e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80161b:	83 ec 08             	sub    $0x8,%esp
  80161e:	56                   	push   %esi
  80161f:	ff 75 18             	push   0x18(%ebp)
  801622:	ff d7                	call   *%edi
  801624:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801627:	83 eb 01             	sub    $0x1,%ebx
  80162a:	85 db                	test   %ebx,%ebx
  80162c:	7f ed                	jg     80161b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80162e:	83 ec 08             	sub    $0x8,%esp
  801631:	56                   	push   %esi
  801632:	83 ec 04             	sub    $0x4,%esp
  801635:	ff 75 e4             	push   -0x1c(%ebp)
  801638:	ff 75 e0             	push   -0x20(%ebp)
  80163b:	ff 75 dc             	push   -0x24(%ebp)
  80163e:	ff 75 d8             	push   -0x28(%ebp)
  801641:	e8 da 0a 00 00       	call   802120 <__umoddi3>
  801646:	83 c4 14             	add    $0x14,%esp
  801649:	0f be 80 c3 23 80 00 	movsbl 0x8023c3(%eax),%eax
  801650:	50                   	push   %eax
  801651:	ff d7                	call   *%edi
}
  801653:	83 c4 10             	add    $0x10,%esp
  801656:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801659:	5b                   	pop    %ebx
  80165a:	5e                   	pop    %esi
  80165b:	5f                   	pop    %edi
  80165c:	5d                   	pop    %ebp
  80165d:	c3                   	ret    

0080165e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80165e:	55                   	push   %ebp
  80165f:	89 e5                	mov    %esp,%ebp
  801661:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801664:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801668:	8b 10                	mov    (%eax),%edx
  80166a:	3b 50 04             	cmp    0x4(%eax),%edx
  80166d:	73 0a                	jae    801679 <sprintputch+0x1b>
		*b->buf++ = ch;
  80166f:	8d 4a 01             	lea    0x1(%edx),%ecx
  801672:	89 08                	mov    %ecx,(%eax)
  801674:	8b 45 08             	mov    0x8(%ebp),%eax
  801677:	88 02                	mov    %al,(%edx)
}
  801679:	5d                   	pop    %ebp
  80167a:	c3                   	ret    

0080167b <printfmt>:
{
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801681:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801684:	50                   	push   %eax
  801685:	ff 75 10             	push   0x10(%ebp)
  801688:	ff 75 0c             	push   0xc(%ebp)
  80168b:	ff 75 08             	push   0x8(%ebp)
  80168e:	e8 05 00 00 00       	call   801698 <vprintfmt>
}
  801693:	83 c4 10             	add    $0x10,%esp
  801696:	c9                   	leave  
  801697:	c3                   	ret    

00801698 <vprintfmt>:
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	57                   	push   %edi
  80169c:	56                   	push   %esi
  80169d:	53                   	push   %ebx
  80169e:	83 ec 3c             	sub    $0x3c,%esp
  8016a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8016a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016a7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016aa:	eb 0a                	jmp    8016b6 <vprintfmt+0x1e>
			putch(ch, putdat);
  8016ac:	83 ec 08             	sub    $0x8,%esp
  8016af:	53                   	push   %ebx
  8016b0:	50                   	push   %eax
  8016b1:	ff d6                	call   *%esi
  8016b3:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016b6:	83 c7 01             	add    $0x1,%edi
  8016b9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016bd:	83 f8 25             	cmp    $0x25,%eax
  8016c0:	74 0c                	je     8016ce <vprintfmt+0x36>
			if (ch == '\0')
  8016c2:	85 c0                	test   %eax,%eax
  8016c4:	75 e6                	jne    8016ac <vprintfmt+0x14>
}
  8016c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c9:	5b                   	pop    %ebx
  8016ca:	5e                   	pop    %esi
  8016cb:	5f                   	pop    %edi
  8016cc:	5d                   	pop    %ebp
  8016cd:	c3                   	ret    
		padc = ' ';
  8016ce:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8016d2:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8016d9:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8016e0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8016e7:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8016ec:	8d 47 01             	lea    0x1(%edi),%eax
  8016ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016f2:	0f b6 17             	movzbl (%edi),%edx
  8016f5:	8d 42 dd             	lea    -0x23(%edx),%eax
  8016f8:	3c 55                	cmp    $0x55,%al
  8016fa:	0f 87 bb 03 00 00    	ja     801abb <vprintfmt+0x423>
  801700:	0f b6 c0             	movzbl %al,%eax
  801703:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
  80170a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80170d:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801711:	eb d9                	jmp    8016ec <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801713:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801716:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80171a:	eb d0                	jmp    8016ec <vprintfmt+0x54>
  80171c:	0f b6 d2             	movzbl %dl,%edx
  80171f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801722:	b8 00 00 00 00       	mov    $0x0,%eax
  801727:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80172a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80172d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801731:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801734:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801737:	83 f9 09             	cmp    $0x9,%ecx
  80173a:	77 55                	ja     801791 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80173c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80173f:	eb e9                	jmp    80172a <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801741:	8b 45 14             	mov    0x14(%ebp),%eax
  801744:	8b 00                	mov    (%eax),%eax
  801746:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801749:	8b 45 14             	mov    0x14(%ebp),%eax
  80174c:	8d 40 04             	lea    0x4(%eax),%eax
  80174f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801752:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801755:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801759:	79 91                	jns    8016ec <vprintfmt+0x54>
				width = precision, precision = -1;
  80175b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80175e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801761:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801768:	eb 82                	jmp    8016ec <vprintfmt+0x54>
  80176a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80176d:	85 d2                	test   %edx,%edx
  80176f:	b8 00 00 00 00       	mov    $0x0,%eax
  801774:	0f 49 c2             	cmovns %edx,%eax
  801777:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80177a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80177d:	e9 6a ff ff ff       	jmp    8016ec <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801782:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801785:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80178c:	e9 5b ff ff ff       	jmp    8016ec <vprintfmt+0x54>
  801791:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801794:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801797:	eb bc                	jmp    801755 <vprintfmt+0xbd>
			lflag++;
  801799:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80179c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80179f:	e9 48 ff ff ff       	jmp    8016ec <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8017a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8017a7:	8d 78 04             	lea    0x4(%eax),%edi
  8017aa:	83 ec 08             	sub    $0x8,%esp
  8017ad:	53                   	push   %ebx
  8017ae:	ff 30                	push   (%eax)
  8017b0:	ff d6                	call   *%esi
			break;
  8017b2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017b5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017b8:	e9 9d 02 00 00       	jmp    801a5a <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8017bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8017c0:	8d 78 04             	lea    0x4(%eax),%edi
  8017c3:	8b 10                	mov    (%eax),%edx
  8017c5:	89 d0                	mov    %edx,%eax
  8017c7:	f7 d8                	neg    %eax
  8017c9:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017cc:	83 f8 0f             	cmp    $0xf,%eax
  8017cf:	7f 23                	jg     8017f4 <vprintfmt+0x15c>
  8017d1:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  8017d8:	85 d2                	test   %edx,%edx
  8017da:	74 18                	je     8017f4 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8017dc:	52                   	push   %edx
  8017dd:	68 21 23 80 00       	push   $0x802321
  8017e2:	53                   	push   %ebx
  8017e3:	56                   	push   %esi
  8017e4:	e8 92 fe ff ff       	call   80167b <printfmt>
  8017e9:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8017ec:	89 7d 14             	mov    %edi,0x14(%ebp)
  8017ef:	e9 66 02 00 00       	jmp    801a5a <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8017f4:	50                   	push   %eax
  8017f5:	68 db 23 80 00       	push   $0x8023db
  8017fa:	53                   	push   %ebx
  8017fb:	56                   	push   %esi
  8017fc:	e8 7a fe ff ff       	call   80167b <printfmt>
  801801:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801804:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801807:	e9 4e 02 00 00       	jmp    801a5a <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80180c:	8b 45 14             	mov    0x14(%ebp),%eax
  80180f:	83 c0 04             	add    $0x4,%eax
  801812:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801815:	8b 45 14             	mov    0x14(%ebp),%eax
  801818:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80181a:	85 d2                	test   %edx,%edx
  80181c:	b8 d4 23 80 00       	mov    $0x8023d4,%eax
  801821:	0f 45 c2             	cmovne %edx,%eax
  801824:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801827:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80182b:	7e 06                	jle    801833 <vprintfmt+0x19b>
  80182d:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801831:	75 0d                	jne    801840 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801833:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801836:	89 c7                	mov    %eax,%edi
  801838:	03 45 e0             	add    -0x20(%ebp),%eax
  80183b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80183e:	eb 55                	jmp    801895 <vprintfmt+0x1fd>
  801840:	83 ec 08             	sub    $0x8,%esp
  801843:	ff 75 d8             	push   -0x28(%ebp)
  801846:	ff 75 cc             	push   -0x34(%ebp)
  801849:	e8 0a 03 00 00       	call   801b58 <strnlen>
  80184e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801851:	29 c1                	sub    %eax,%ecx
  801853:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801856:	83 c4 10             	add    $0x10,%esp
  801859:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80185b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80185f:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801862:	eb 0f                	jmp    801873 <vprintfmt+0x1db>
					putch(padc, putdat);
  801864:	83 ec 08             	sub    $0x8,%esp
  801867:	53                   	push   %ebx
  801868:	ff 75 e0             	push   -0x20(%ebp)
  80186b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80186d:	83 ef 01             	sub    $0x1,%edi
  801870:	83 c4 10             	add    $0x10,%esp
  801873:	85 ff                	test   %edi,%edi
  801875:	7f ed                	jg     801864 <vprintfmt+0x1cc>
  801877:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80187a:	85 d2                	test   %edx,%edx
  80187c:	b8 00 00 00 00       	mov    $0x0,%eax
  801881:	0f 49 c2             	cmovns %edx,%eax
  801884:	29 c2                	sub    %eax,%edx
  801886:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801889:	eb a8                	jmp    801833 <vprintfmt+0x19b>
					putch(ch, putdat);
  80188b:	83 ec 08             	sub    $0x8,%esp
  80188e:	53                   	push   %ebx
  80188f:	52                   	push   %edx
  801890:	ff d6                	call   *%esi
  801892:	83 c4 10             	add    $0x10,%esp
  801895:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801898:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80189a:	83 c7 01             	add    $0x1,%edi
  80189d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018a1:	0f be d0             	movsbl %al,%edx
  8018a4:	85 d2                	test   %edx,%edx
  8018a6:	74 4b                	je     8018f3 <vprintfmt+0x25b>
  8018a8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018ac:	78 06                	js     8018b4 <vprintfmt+0x21c>
  8018ae:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018b2:	78 1e                	js     8018d2 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8018b4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018b8:	74 d1                	je     80188b <vprintfmt+0x1f3>
  8018ba:	0f be c0             	movsbl %al,%eax
  8018bd:	83 e8 20             	sub    $0x20,%eax
  8018c0:	83 f8 5e             	cmp    $0x5e,%eax
  8018c3:	76 c6                	jbe    80188b <vprintfmt+0x1f3>
					putch('?', putdat);
  8018c5:	83 ec 08             	sub    $0x8,%esp
  8018c8:	53                   	push   %ebx
  8018c9:	6a 3f                	push   $0x3f
  8018cb:	ff d6                	call   *%esi
  8018cd:	83 c4 10             	add    $0x10,%esp
  8018d0:	eb c3                	jmp    801895 <vprintfmt+0x1fd>
  8018d2:	89 cf                	mov    %ecx,%edi
  8018d4:	eb 0e                	jmp    8018e4 <vprintfmt+0x24c>
				putch(' ', putdat);
  8018d6:	83 ec 08             	sub    $0x8,%esp
  8018d9:	53                   	push   %ebx
  8018da:	6a 20                	push   $0x20
  8018dc:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8018de:	83 ef 01             	sub    $0x1,%edi
  8018e1:	83 c4 10             	add    $0x10,%esp
  8018e4:	85 ff                	test   %edi,%edi
  8018e6:	7f ee                	jg     8018d6 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8018e8:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8018eb:	89 45 14             	mov    %eax,0x14(%ebp)
  8018ee:	e9 67 01 00 00       	jmp    801a5a <vprintfmt+0x3c2>
  8018f3:	89 cf                	mov    %ecx,%edi
  8018f5:	eb ed                	jmp    8018e4 <vprintfmt+0x24c>
	if (lflag >= 2)
  8018f7:	83 f9 01             	cmp    $0x1,%ecx
  8018fa:	7f 1b                	jg     801917 <vprintfmt+0x27f>
	else if (lflag)
  8018fc:	85 c9                	test   %ecx,%ecx
  8018fe:	74 63                	je     801963 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  801900:	8b 45 14             	mov    0x14(%ebp),%eax
  801903:	8b 00                	mov    (%eax),%eax
  801905:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801908:	99                   	cltd   
  801909:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80190c:	8b 45 14             	mov    0x14(%ebp),%eax
  80190f:	8d 40 04             	lea    0x4(%eax),%eax
  801912:	89 45 14             	mov    %eax,0x14(%ebp)
  801915:	eb 17                	jmp    80192e <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801917:	8b 45 14             	mov    0x14(%ebp),%eax
  80191a:	8b 50 04             	mov    0x4(%eax),%edx
  80191d:	8b 00                	mov    (%eax),%eax
  80191f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801922:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801925:	8b 45 14             	mov    0x14(%ebp),%eax
  801928:	8d 40 08             	lea    0x8(%eax),%eax
  80192b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80192e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801931:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801934:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801939:	85 c9                	test   %ecx,%ecx
  80193b:	0f 89 ff 00 00 00    	jns    801a40 <vprintfmt+0x3a8>
				putch('-', putdat);
  801941:	83 ec 08             	sub    $0x8,%esp
  801944:	53                   	push   %ebx
  801945:	6a 2d                	push   $0x2d
  801947:	ff d6                	call   *%esi
				num = -(long long) num;
  801949:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80194c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80194f:	f7 da                	neg    %edx
  801951:	83 d1 00             	adc    $0x0,%ecx
  801954:	f7 d9                	neg    %ecx
  801956:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801959:	bf 0a 00 00 00       	mov    $0xa,%edi
  80195e:	e9 dd 00 00 00       	jmp    801a40 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801963:	8b 45 14             	mov    0x14(%ebp),%eax
  801966:	8b 00                	mov    (%eax),%eax
  801968:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80196b:	99                   	cltd   
  80196c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80196f:	8b 45 14             	mov    0x14(%ebp),%eax
  801972:	8d 40 04             	lea    0x4(%eax),%eax
  801975:	89 45 14             	mov    %eax,0x14(%ebp)
  801978:	eb b4                	jmp    80192e <vprintfmt+0x296>
	if (lflag >= 2)
  80197a:	83 f9 01             	cmp    $0x1,%ecx
  80197d:	7f 1e                	jg     80199d <vprintfmt+0x305>
	else if (lflag)
  80197f:	85 c9                	test   %ecx,%ecx
  801981:	74 32                	je     8019b5 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  801983:	8b 45 14             	mov    0x14(%ebp),%eax
  801986:	8b 10                	mov    (%eax),%edx
  801988:	b9 00 00 00 00       	mov    $0x0,%ecx
  80198d:	8d 40 04             	lea    0x4(%eax),%eax
  801990:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801993:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  801998:	e9 a3 00 00 00       	jmp    801a40 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80199d:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a0:	8b 10                	mov    (%eax),%edx
  8019a2:	8b 48 04             	mov    0x4(%eax),%ecx
  8019a5:	8d 40 08             	lea    0x8(%eax),%eax
  8019a8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019ab:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8019b0:	e9 8b 00 00 00       	jmp    801a40 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b8:	8b 10                	mov    (%eax),%edx
  8019ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019bf:	8d 40 04             	lea    0x4(%eax),%eax
  8019c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019c5:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8019ca:	eb 74                	jmp    801a40 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8019cc:	83 f9 01             	cmp    $0x1,%ecx
  8019cf:	7f 1b                	jg     8019ec <vprintfmt+0x354>
	else if (lflag)
  8019d1:	85 c9                	test   %ecx,%ecx
  8019d3:	74 2c                	je     801a01 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8019d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d8:	8b 10                	mov    (%eax),%edx
  8019da:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019df:	8d 40 04             	lea    0x4(%eax),%eax
  8019e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019e5:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8019ea:	eb 54                	jmp    801a40 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8019ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ef:	8b 10                	mov    (%eax),%edx
  8019f1:	8b 48 04             	mov    0x4(%eax),%ecx
  8019f4:	8d 40 08             	lea    0x8(%eax),%eax
  8019f7:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019fa:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8019ff:	eb 3f                	jmp    801a40 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801a01:	8b 45 14             	mov    0x14(%ebp),%eax
  801a04:	8b 10                	mov    (%eax),%edx
  801a06:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a0b:	8d 40 04             	lea    0x4(%eax),%eax
  801a0e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a11:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801a16:	eb 28                	jmp    801a40 <vprintfmt+0x3a8>
			putch('0', putdat);
  801a18:	83 ec 08             	sub    $0x8,%esp
  801a1b:	53                   	push   %ebx
  801a1c:	6a 30                	push   $0x30
  801a1e:	ff d6                	call   *%esi
			putch('x', putdat);
  801a20:	83 c4 08             	add    $0x8,%esp
  801a23:	53                   	push   %ebx
  801a24:	6a 78                	push   $0x78
  801a26:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a28:	8b 45 14             	mov    0x14(%ebp),%eax
  801a2b:	8b 10                	mov    (%eax),%edx
  801a2d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a32:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a35:	8d 40 04             	lea    0x4(%eax),%eax
  801a38:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a3b:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801a40:	83 ec 0c             	sub    $0xc,%esp
  801a43:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801a47:	50                   	push   %eax
  801a48:	ff 75 e0             	push   -0x20(%ebp)
  801a4b:	57                   	push   %edi
  801a4c:	51                   	push   %ecx
  801a4d:	52                   	push   %edx
  801a4e:	89 da                	mov    %ebx,%edx
  801a50:	89 f0                	mov    %esi,%eax
  801a52:	e8 5e fb ff ff       	call   8015b5 <printnum>
			break;
  801a57:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801a5a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a5d:	e9 54 fc ff ff       	jmp    8016b6 <vprintfmt+0x1e>
	if (lflag >= 2)
  801a62:	83 f9 01             	cmp    $0x1,%ecx
  801a65:	7f 1b                	jg     801a82 <vprintfmt+0x3ea>
	else if (lflag)
  801a67:	85 c9                	test   %ecx,%ecx
  801a69:	74 2c                	je     801a97 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801a6b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a6e:	8b 10                	mov    (%eax),%edx
  801a70:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a75:	8d 40 04             	lea    0x4(%eax),%eax
  801a78:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a7b:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  801a80:	eb be                	jmp    801a40 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801a82:	8b 45 14             	mov    0x14(%ebp),%eax
  801a85:	8b 10                	mov    (%eax),%edx
  801a87:	8b 48 04             	mov    0x4(%eax),%ecx
  801a8a:	8d 40 08             	lea    0x8(%eax),%eax
  801a8d:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a90:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  801a95:	eb a9                	jmp    801a40 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801a97:	8b 45 14             	mov    0x14(%ebp),%eax
  801a9a:	8b 10                	mov    (%eax),%edx
  801a9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801aa1:	8d 40 04             	lea    0x4(%eax),%eax
  801aa4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801aa7:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  801aac:	eb 92                	jmp    801a40 <vprintfmt+0x3a8>
			putch(ch, putdat);
  801aae:	83 ec 08             	sub    $0x8,%esp
  801ab1:	53                   	push   %ebx
  801ab2:	6a 25                	push   $0x25
  801ab4:	ff d6                	call   *%esi
			break;
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	eb 9f                	jmp    801a5a <vprintfmt+0x3c2>
			putch('%', putdat);
  801abb:	83 ec 08             	sub    $0x8,%esp
  801abe:	53                   	push   %ebx
  801abf:	6a 25                	push   $0x25
  801ac1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	89 f8                	mov    %edi,%eax
  801ac8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801acc:	74 05                	je     801ad3 <vprintfmt+0x43b>
  801ace:	83 e8 01             	sub    $0x1,%eax
  801ad1:	eb f5                	jmp    801ac8 <vprintfmt+0x430>
  801ad3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ad6:	eb 82                	jmp    801a5a <vprintfmt+0x3c2>

00801ad8 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	83 ec 18             	sub    $0x18,%esp
  801ade:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae1:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ae4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ae7:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801aeb:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801aee:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801af5:	85 c0                	test   %eax,%eax
  801af7:	74 26                	je     801b1f <vsnprintf+0x47>
  801af9:	85 d2                	test   %edx,%edx
  801afb:	7e 22                	jle    801b1f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801afd:	ff 75 14             	push   0x14(%ebp)
  801b00:	ff 75 10             	push   0x10(%ebp)
  801b03:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b06:	50                   	push   %eax
  801b07:	68 5e 16 80 00       	push   $0x80165e
  801b0c:	e8 87 fb ff ff       	call   801698 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b11:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b14:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1a:	83 c4 10             	add    $0x10,%esp
}
  801b1d:	c9                   	leave  
  801b1e:	c3                   	ret    
		return -E_INVAL;
  801b1f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b24:	eb f7                	jmp    801b1d <vsnprintf+0x45>

00801b26 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b26:	55                   	push   %ebp
  801b27:	89 e5                	mov    %esp,%ebp
  801b29:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b2c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b2f:	50                   	push   %eax
  801b30:	ff 75 10             	push   0x10(%ebp)
  801b33:	ff 75 0c             	push   0xc(%ebp)
  801b36:	ff 75 08             	push   0x8(%ebp)
  801b39:	e8 9a ff ff ff       	call   801ad8 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b3e:	c9                   	leave  
  801b3f:	c3                   	ret    

00801b40 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b40:	55                   	push   %ebp
  801b41:	89 e5                	mov    %esp,%ebp
  801b43:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b46:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4b:	eb 03                	jmp    801b50 <strlen+0x10>
		n++;
  801b4d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801b50:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b54:	75 f7                	jne    801b4d <strlen+0xd>
	return n;
}
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    

00801b58 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b58:	55                   	push   %ebp
  801b59:	89 e5                	mov    %esp,%ebp
  801b5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b5e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b61:	b8 00 00 00 00       	mov    $0x0,%eax
  801b66:	eb 03                	jmp    801b6b <strnlen+0x13>
		n++;
  801b68:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b6b:	39 d0                	cmp    %edx,%eax
  801b6d:	74 08                	je     801b77 <strnlen+0x1f>
  801b6f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801b73:	75 f3                	jne    801b68 <strnlen+0x10>
  801b75:	89 c2                	mov    %eax,%edx
	return n;
}
  801b77:	89 d0                	mov    %edx,%eax
  801b79:	5d                   	pop    %ebp
  801b7a:	c3                   	ret    

00801b7b <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	53                   	push   %ebx
  801b7f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b85:	b8 00 00 00 00       	mov    $0x0,%eax
  801b8a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801b8e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801b91:	83 c0 01             	add    $0x1,%eax
  801b94:	84 d2                	test   %dl,%dl
  801b96:	75 f2                	jne    801b8a <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801b98:	89 c8                	mov    %ecx,%eax
  801b9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b9d:	c9                   	leave  
  801b9e:	c3                   	ret    

00801b9f <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b9f:	55                   	push   %ebp
  801ba0:	89 e5                	mov    %esp,%ebp
  801ba2:	53                   	push   %ebx
  801ba3:	83 ec 10             	sub    $0x10,%esp
  801ba6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801ba9:	53                   	push   %ebx
  801baa:	e8 91 ff ff ff       	call   801b40 <strlen>
  801baf:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801bb2:	ff 75 0c             	push   0xc(%ebp)
  801bb5:	01 d8                	add    %ebx,%eax
  801bb7:	50                   	push   %eax
  801bb8:	e8 be ff ff ff       	call   801b7b <strcpy>
	return dst;
}
  801bbd:	89 d8                	mov    %ebx,%eax
  801bbf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bc2:	c9                   	leave  
  801bc3:	c3                   	ret    

00801bc4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bc4:	55                   	push   %ebp
  801bc5:	89 e5                	mov    %esp,%ebp
  801bc7:	56                   	push   %esi
  801bc8:	53                   	push   %ebx
  801bc9:	8b 75 08             	mov    0x8(%ebp),%esi
  801bcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bcf:	89 f3                	mov    %esi,%ebx
  801bd1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bd4:	89 f0                	mov    %esi,%eax
  801bd6:	eb 0f                	jmp    801be7 <strncpy+0x23>
		*dst++ = *src;
  801bd8:	83 c0 01             	add    $0x1,%eax
  801bdb:	0f b6 0a             	movzbl (%edx),%ecx
  801bde:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801be1:	80 f9 01             	cmp    $0x1,%cl
  801be4:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801be7:	39 d8                	cmp    %ebx,%eax
  801be9:	75 ed                	jne    801bd8 <strncpy+0x14>
	}
	return ret;
}
  801beb:	89 f0                	mov    %esi,%eax
  801bed:	5b                   	pop    %ebx
  801bee:	5e                   	pop    %esi
  801bef:	5d                   	pop    %ebp
  801bf0:	c3                   	ret    

00801bf1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	56                   	push   %esi
  801bf5:	53                   	push   %ebx
  801bf6:	8b 75 08             	mov    0x8(%ebp),%esi
  801bf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bfc:	8b 55 10             	mov    0x10(%ebp),%edx
  801bff:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c01:	85 d2                	test   %edx,%edx
  801c03:	74 21                	je     801c26 <strlcpy+0x35>
  801c05:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c09:	89 f2                	mov    %esi,%edx
  801c0b:	eb 09                	jmp    801c16 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c0d:	83 c1 01             	add    $0x1,%ecx
  801c10:	83 c2 01             	add    $0x1,%edx
  801c13:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801c16:	39 c2                	cmp    %eax,%edx
  801c18:	74 09                	je     801c23 <strlcpy+0x32>
  801c1a:	0f b6 19             	movzbl (%ecx),%ebx
  801c1d:	84 db                	test   %bl,%bl
  801c1f:	75 ec                	jne    801c0d <strlcpy+0x1c>
  801c21:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801c23:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c26:	29 f0                	sub    %esi,%eax
}
  801c28:	5b                   	pop    %ebx
  801c29:	5e                   	pop    %esi
  801c2a:	5d                   	pop    %ebp
  801c2b:	c3                   	ret    

00801c2c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c2c:	55                   	push   %ebp
  801c2d:	89 e5                	mov    %esp,%ebp
  801c2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c32:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c35:	eb 06                	jmp    801c3d <strcmp+0x11>
		p++, q++;
  801c37:	83 c1 01             	add    $0x1,%ecx
  801c3a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801c3d:	0f b6 01             	movzbl (%ecx),%eax
  801c40:	84 c0                	test   %al,%al
  801c42:	74 04                	je     801c48 <strcmp+0x1c>
  801c44:	3a 02                	cmp    (%edx),%al
  801c46:	74 ef                	je     801c37 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c48:	0f b6 c0             	movzbl %al,%eax
  801c4b:	0f b6 12             	movzbl (%edx),%edx
  801c4e:	29 d0                	sub    %edx,%eax
}
  801c50:	5d                   	pop    %ebp
  801c51:	c3                   	ret    

00801c52 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	53                   	push   %ebx
  801c56:	8b 45 08             	mov    0x8(%ebp),%eax
  801c59:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c5c:	89 c3                	mov    %eax,%ebx
  801c5e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c61:	eb 06                	jmp    801c69 <strncmp+0x17>
		n--, p++, q++;
  801c63:	83 c0 01             	add    $0x1,%eax
  801c66:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801c69:	39 d8                	cmp    %ebx,%eax
  801c6b:	74 18                	je     801c85 <strncmp+0x33>
  801c6d:	0f b6 08             	movzbl (%eax),%ecx
  801c70:	84 c9                	test   %cl,%cl
  801c72:	74 04                	je     801c78 <strncmp+0x26>
  801c74:	3a 0a                	cmp    (%edx),%cl
  801c76:	74 eb                	je     801c63 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c78:	0f b6 00             	movzbl (%eax),%eax
  801c7b:	0f b6 12             	movzbl (%edx),%edx
  801c7e:	29 d0                	sub    %edx,%eax
}
  801c80:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c83:	c9                   	leave  
  801c84:	c3                   	ret    
		return 0;
  801c85:	b8 00 00 00 00       	mov    $0x0,%eax
  801c8a:	eb f4                	jmp    801c80 <strncmp+0x2e>

00801c8c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c8c:	55                   	push   %ebp
  801c8d:	89 e5                	mov    %esp,%ebp
  801c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  801c92:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c96:	eb 03                	jmp    801c9b <strchr+0xf>
  801c98:	83 c0 01             	add    $0x1,%eax
  801c9b:	0f b6 10             	movzbl (%eax),%edx
  801c9e:	84 d2                	test   %dl,%dl
  801ca0:	74 06                	je     801ca8 <strchr+0x1c>
		if (*s == c)
  801ca2:	38 ca                	cmp    %cl,%dl
  801ca4:	75 f2                	jne    801c98 <strchr+0xc>
  801ca6:	eb 05                	jmp    801cad <strchr+0x21>
			return (char *) s;
	return 0;
  801ca8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cad:	5d                   	pop    %ebp
  801cae:	c3                   	ret    

00801caf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801caf:	55                   	push   %ebp
  801cb0:	89 e5                	mov    %esp,%ebp
  801cb2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cb9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cbc:	38 ca                	cmp    %cl,%dl
  801cbe:	74 09                	je     801cc9 <strfind+0x1a>
  801cc0:	84 d2                	test   %dl,%dl
  801cc2:	74 05                	je     801cc9 <strfind+0x1a>
	for (; *s; s++)
  801cc4:	83 c0 01             	add    $0x1,%eax
  801cc7:	eb f0                	jmp    801cb9 <strfind+0xa>
			break;
	return (char *) s;
}
  801cc9:	5d                   	pop    %ebp
  801cca:	c3                   	ret    

00801ccb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	57                   	push   %edi
  801ccf:	56                   	push   %esi
  801cd0:	53                   	push   %ebx
  801cd1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cd4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cd7:	85 c9                	test   %ecx,%ecx
  801cd9:	74 2f                	je     801d0a <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cdb:	89 f8                	mov    %edi,%eax
  801cdd:	09 c8                	or     %ecx,%eax
  801cdf:	a8 03                	test   $0x3,%al
  801ce1:	75 21                	jne    801d04 <memset+0x39>
		c &= 0xFF;
  801ce3:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801ce7:	89 d0                	mov    %edx,%eax
  801ce9:	c1 e0 08             	shl    $0x8,%eax
  801cec:	89 d3                	mov    %edx,%ebx
  801cee:	c1 e3 18             	shl    $0x18,%ebx
  801cf1:	89 d6                	mov    %edx,%esi
  801cf3:	c1 e6 10             	shl    $0x10,%esi
  801cf6:	09 f3                	or     %esi,%ebx
  801cf8:	09 da                	or     %ebx,%edx
  801cfa:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801cfc:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801cff:	fc                   	cld    
  801d00:	f3 ab                	rep stos %eax,%es:(%edi)
  801d02:	eb 06                	jmp    801d0a <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d07:	fc                   	cld    
  801d08:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d0a:	89 f8                	mov    %edi,%eax
  801d0c:	5b                   	pop    %ebx
  801d0d:	5e                   	pop    %esi
  801d0e:	5f                   	pop    %edi
  801d0f:	5d                   	pop    %ebp
  801d10:	c3                   	ret    

00801d11 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
  801d14:	57                   	push   %edi
  801d15:	56                   	push   %esi
  801d16:	8b 45 08             	mov    0x8(%ebp),%eax
  801d19:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d1c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d1f:	39 c6                	cmp    %eax,%esi
  801d21:	73 32                	jae    801d55 <memmove+0x44>
  801d23:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d26:	39 c2                	cmp    %eax,%edx
  801d28:	76 2b                	jbe    801d55 <memmove+0x44>
		s += n;
		d += n;
  801d2a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d2d:	89 d6                	mov    %edx,%esi
  801d2f:	09 fe                	or     %edi,%esi
  801d31:	09 ce                	or     %ecx,%esi
  801d33:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d39:	75 0e                	jne    801d49 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d3b:	83 ef 04             	sub    $0x4,%edi
  801d3e:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d41:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801d44:	fd                   	std    
  801d45:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d47:	eb 09                	jmp    801d52 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d49:	83 ef 01             	sub    $0x1,%edi
  801d4c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801d4f:	fd                   	std    
  801d50:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d52:	fc                   	cld    
  801d53:	eb 1a                	jmp    801d6f <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d55:	89 f2                	mov    %esi,%edx
  801d57:	09 c2                	or     %eax,%edx
  801d59:	09 ca                	or     %ecx,%edx
  801d5b:	f6 c2 03             	test   $0x3,%dl
  801d5e:	75 0a                	jne    801d6a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801d60:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801d63:	89 c7                	mov    %eax,%edi
  801d65:	fc                   	cld    
  801d66:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d68:	eb 05                	jmp    801d6f <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801d6a:	89 c7                	mov    %eax,%edi
  801d6c:	fc                   	cld    
  801d6d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d6f:	5e                   	pop    %esi
  801d70:	5f                   	pop    %edi
  801d71:	5d                   	pop    %ebp
  801d72:	c3                   	ret    

00801d73 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d73:	55                   	push   %ebp
  801d74:	89 e5                	mov    %esp,%ebp
  801d76:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d79:	ff 75 10             	push   0x10(%ebp)
  801d7c:	ff 75 0c             	push   0xc(%ebp)
  801d7f:	ff 75 08             	push   0x8(%ebp)
  801d82:	e8 8a ff ff ff       	call   801d11 <memmove>
}
  801d87:	c9                   	leave  
  801d88:	c3                   	ret    

00801d89 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d89:	55                   	push   %ebp
  801d8a:	89 e5                	mov    %esp,%ebp
  801d8c:	56                   	push   %esi
  801d8d:	53                   	push   %ebx
  801d8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801d91:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d94:	89 c6                	mov    %eax,%esi
  801d96:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d99:	eb 06                	jmp    801da1 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801d9b:	83 c0 01             	add    $0x1,%eax
  801d9e:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801da1:	39 f0                	cmp    %esi,%eax
  801da3:	74 14                	je     801db9 <memcmp+0x30>
		if (*s1 != *s2)
  801da5:	0f b6 08             	movzbl (%eax),%ecx
  801da8:	0f b6 1a             	movzbl (%edx),%ebx
  801dab:	38 d9                	cmp    %bl,%cl
  801dad:	74 ec                	je     801d9b <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801daf:	0f b6 c1             	movzbl %cl,%eax
  801db2:	0f b6 db             	movzbl %bl,%ebx
  801db5:	29 d8                	sub    %ebx,%eax
  801db7:	eb 05                	jmp    801dbe <memcmp+0x35>
	}

	return 0;
  801db9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dbe:	5b                   	pop    %ebx
  801dbf:	5e                   	pop    %esi
  801dc0:	5d                   	pop    %ebp
  801dc1:	c3                   	ret    

00801dc2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dc2:	55                   	push   %ebp
  801dc3:	89 e5                	mov    %esp,%ebp
  801dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801dcb:	89 c2                	mov    %eax,%edx
  801dcd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801dd0:	eb 03                	jmp    801dd5 <memfind+0x13>
  801dd2:	83 c0 01             	add    $0x1,%eax
  801dd5:	39 d0                	cmp    %edx,%eax
  801dd7:	73 04                	jae    801ddd <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801dd9:	38 08                	cmp    %cl,(%eax)
  801ddb:	75 f5                	jne    801dd2 <memfind+0x10>
			break;
	return (void *) s;
}
  801ddd:	5d                   	pop    %ebp
  801dde:	c3                   	ret    

00801ddf <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801ddf:	55                   	push   %ebp
  801de0:	89 e5                	mov    %esp,%ebp
  801de2:	57                   	push   %edi
  801de3:	56                   	push   %esi
  801de4:	53                   	push   %ebx
  801de5:	8b 55 08             	mov    0x8(%ebp),%edx
  801de8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801deb:	eb 03                	jmp    801df0 <strtol+0x11>
		s++;
  801ded:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801df0:	0f b6 02             	movzbl (%edx),%eax
  801df3:	3c 20                	cmp    $0x20,%al
  801df5:	74 f6                	je     801ded <strtol+0xe>
  801df7:	3c 09                	cmp    $0x9,%al
  801df9:	74 f2                	je     801ded <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801dfb:	3c 2b                	cmp    $0x2b,%al
  801dfd:	74 2a                	je     801e29 <strtol+0x4a>
	int neg = 0;
  801dff:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801e04:	3c 2d                	cmp    $0x2d,%al
  801e06:	74 2b                	je     801e33 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e08:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e0e:	75 0f                	jne    801e1f <strtol+0x40>
  801e10:	80 3a 30             	cmpb   $0x30,(%edx)
  801e13:	74 28                	je     801e3d <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e15:	85 db                	test   %ebx,%ebx
  801e17:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e1c:	0f 44 d8             	cmove  %eax,%ebx
  801e1f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e24:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801e27:	eb 46                	jmp    801e6f <strtol+0x90>
		s++;
  801e29:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801e2c:	bf 00 00 00 00       	mov    $0x0,%edi
  801e31:	eb d5                	jmp    801e08 <strtol+0x29>
		s++, neg = 1;
  801e33:	83 c2 01             	add    $0x1,%edx
  801e36:	bf 01 00 00 00       	mov    $0x1,%edi
  801e3b:	eb cb                	jmp    801e08 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e3d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e41:	74 0e                	je     801e51 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801e43:	85 db                	test   %ebx,%ebx
  801e45:	75 d8                	jne    801e1f <strtol+0x40>
		s++, base = 8;
  801e47:	83 c2 01             	add    $0x1,%edx
  801e4a:	bb 08 00 00 00       	mov    $0x8,%ebx
  801e4f:	eb ce                	jmp    801e1f <strtol+0x40>
		s += 2, base = 16;
  801e51:	83 c2 02             	add    $0x2,%edx
  801e54:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e59:	eb c4                	jmp    801e1f <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801e5b:	0f be c0             	movsbl %al,%eax
  801e5e:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801e61:	3b 45 10             	cmp    0x10(%ebp),%eax
  801e64:	7d 3a                	jge    801ea0 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801e66:	83 c2 01             	add    $0x1,%edx
  801e69:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801e6d:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801e6f:	0f b6 02             	movzbl (%edx),%eax
  801e72:	8d 70 d0             	lea    -0x30(%eax),%esi
  801e75:	89 f3                	mov    %esi,%ebx
  801e77:	80 fb 09             	cmp    $0x9,%bl
  801e7a:	76 df                	jbe    801e5b <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  801e7c:	8d 70 9f             	lea    -0x61(%eax),%esi
  801e7f:	89 f3                	mov    %esi,%ebx
  801e81:	80 fb 19             	cmp    $0x19,%bl
  801e84:	77 08                	ja     801e8e <strtol+0xaf>
			dig = *s - 'a' + 10;
  801e86:	0f be c0             	movsbl %al,%eax
  801e89:	83 e8 57             	sub    $0x57,%eax
  801e8c:	eb d3                	jmp    801e61 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801e8e:	8d 70 bf             	lea    -0x41(%eax),%esi
  801e91:	89 f3                	mov    %esi,%ebx
  801e93:	80 fb 19             	cmp    $0x19,%bl
  801e96:	77 08                	ja     801ea0 <strtol+0xc1>
			dig = *s - 'A' + 10;
  801e98:	0f be c0             	movsbl %al,%eax
  801e9b:	83 e8 37             	sub    $0x37,%eax
  801e9e:	eb c1                	jmp    801e61 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801ea0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ea4:	74 05                	je     801eab <strtol+0xcc>
		*endptr = (char *) s;
  801ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea9:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801eab:	89 c8                	mov    %ecx,%eax
  801ead:	f7 d8                	neg    %eax
  801eaf:	85 ff                	test   %edi,%edi
  801eb1:	0f 45 c8             	cmovne %eax,%ecx
}
  801eb4:	89 c8                	mov    %ecx,%eax
  801eb6:	5b                   	pop    %ebx
  801eb7:	5e                   	pop    %esi
  801eb8:	5f                   	pop    %edi
  801eb9:	5d                   	pop    %ebp
  801eba:	c3                   	ret    

00801ebb <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ebb:	55                   	push   %ebp
  801ebc:	89 e5                	mov    %esp,%ebp
  801ebe:	56                   	push   %esi
  801ebf:	53                   	push   %ebx
  801ec0:	8b 75 08             	mov    0x8(%ebp),%esi
  801ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801ec9:	85 c0                	test   %eax,%eax
  801ecb:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ed0:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801ed3:	83 ec 0c             	sub    $0xc,%esp
  801ed6:	50                   	push   %eax
  801ed7:	e8 3a e4 ff ff       	call   800316 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801edc:	83 c4 10             	add    $0x10,%esp
  801edf:	85 f6                	test   %esi,%esi
  801ee1:	74 17                	je     801efa <ipc_recv+0x3f>
  801ee3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ee8:	85 c0                	test   %eax,%eax
  801eea:	78 0c                	js     801ef8 <ipc_recv+0x3d>
  801eec:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ef2:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801ef8:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801efa:	85 db                	test   %ebx,%ebx
  801efc:	74 17                	je     801f15 <ipc_recv+0x5a>
  801efe:	ba 00 00 00 00       	mov    $0x0,%edx
  801f03:	85 c0                	test   %eax,%eax
  801f05:	78 0c                	js     801f13 <ipc_recv+0x58>
  801f07:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f0d:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801f13:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f15:	85 c0                	test   %eax,%eax
  801f17:	78 0b                	js     801f24 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801f19:	a1 00 40 80 00       	mov    0x804000,%eax
  801f1e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  801f24:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f27:	5b                   	pop    %ebx
  801f28:	5e                   	pop    %esi
  801f29:	5d                   	pop    %ebp
  801f2a:	c3                   	ret    

00801f2b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f2b:	55                   	push   %ebp
  801f2c:	89 e5                	mov    %esp,%ebp
  801f2e:	57                   	push   %edi
  801f2f:	56                   	push   %esi
  801f30:	53                   	push   %ebx
  801f31:	83 ec 0c             	sub    $0xc,%esp
  801f34:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f37:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f3d:	85 db                	test   %ebx,%ebx
  801f3f:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f44:	0f 44 d8             	cmove  %eax,%ebx
  801f47:	eb 05                	jmp    801f4e <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f49:	e8 f9 e1 ff ff       	call   800147 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f4e:	ff 75 14             	push   0x14(%ebp)
  801f51:	53                   	push   %ebx
  801f52:	56                   	push   %esi
  801f53:	57                   	push   %edi
  801f54:	e8 9a e3 ff ff       	call   8002f3 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f59:	83 c4 10             	add    $0x10,%esp
  801f5c:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f5f:	74 e8                	je     801f49 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f61:	85 c0                	test   %eax,%eax
  801f63:	78 08                	js     801f6d <ipc_send+0x42>
	}while (r<0);

}
  801f65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f68:	5b                   	pop    %ebx
  801f69:	5e                   	pop    %esi
  801f6a:	5f                   	pop    %edi
  801f6b:	5d                   	pop    %ebp
  801f6c:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f6d:	50                   	push   %eax
  801f6e:	68 bf 26 80 00       	push   $0x8026bf
  801f73:	6a 3d                	push   $0x3d
  801f75:	68 d3 26 80 00       	push   $0x8026d3
  801f7a:	e8 47 f5 ff ff       	call   8014c6 <_panic>

00801f7f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f85:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f8a:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  801f90:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f96:	8b 52 60             	mov    0x60(%edx),%edx
  801f99:	39 ca                	cmp    %ecx,%edx
  801f9b:	74 11                	je     801fae <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  801f9d:	83 c0 01             	add    $0x1,%eax
  801fa0:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fa5:	75 e3                	jne    801f8a <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801fa7:	b8 00 00 00 00       	mov    $0x0,%eax
  801fac:	eb 0e                	jmp    801fbc <ipc_find_env+0x3d>
			return envs[i].env_id;
  801fae:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  801fb4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fb9:	8b 40 58             	mov    0x58(%eax),%eax
}
  801fbc:	5d                   	pop    %ebp
  801fbd:	c3                   	ret    

00801fbe <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fbe:	55                   	push   %ebp
  801fbf:	89 e5                	mov    %esp,%ebp
  801fc1:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fc4:	89 c2                	mov    %eax,%edx
  801fc6:	c1 ea 16             	shr    $0x16,%edx
  801fc9:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fd0:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fd5:	f6 c1 01             	test   $0x1,%cl
  801fd8:	74 1c                	je     801ff6 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801fda:	c1 e8 0c             	shr    $0xc,%eax
  801fdd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fe4:	a8 01                	test   $0x1,%al
  801fe6:	74 0e                	je     801ff6 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fe8:	c1 e8 0c             	shr    $0xc,%eax
  801feb:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801ff2:	ef 
  801ff3:	0f b7 d2             	movzwl %dx,%edx
}
  801ff6:	89 d0                	mov    %edx,%eax
  801ff8:	5d                   	pop    %ebp
  801ff9:	c3                   	ret    
  801ffa:	66 90                	xchg   %ax,%ax
  801ffc:	66 90                	xchg   %ax,%ax
  801ffe:	66 90                	xchg   %ax,%ax

00802000 <__udivdi3>:
  802000:	f3 0f 1e fb          	endbr32 
  802004:	55                   	push   %ebp
  802005:	57                   	push   %edi
  802006:	56                   	push   %esi
  802007:	53                   	push   %ebx
  802008:	83 ec 1c             	sub    $0x1c,%esp
  80200b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80200f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802013:	8b 74 24 34          	mov    0x34(%esp),%esi
  802017:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80201b:	85 c0                	test   %eax,%eax
  80201d:	75 19                	jne    802038 <__udivdi3+0x38>
  80201f:	39 f3                	cmp    %esi,%ebx
  802021:	76 4d                	jbe    802070 <__udivdi3+0x70>
  802023:	31 ff                	xor    %edi,%edi
  802025:	89 e8                	mov    %ebp,%eax
  802027:	89 f2                	mov    %esi,%edx
  802029:	f7 f3                	div    %ebx
  80202b:	89 fa                	mov    %edi,%edx
  80202d:	83 c4 1c             	add    $0x1c,%esp
  802030:	5b                   	pop    %ebx
  802031:	5e                   	pop    %esi
  802032:	5f                   	pop    %edi
  802033:	5d                   	pop    %ebp
  802034:	c3                   	ret    
  802035:	8d 76 00             	lea    0x0(%esi),%esi
  802038:	39 f0                	cmp    %esi,%eax
  80203a:	76 14                	jbe    802050 <__udivdi3+0x50>
  80203c:	31 ff                	xor    %edi,%edi
  80203e:	31 c0                	xor    %eax,%eax
  802040:	89 fa                	mov    %edi,%edx
  802042:	83 c4 1c             	add    $0x1c,%esp
  802045:	5b                   	pop    %ebx
  802046:	5e                   	pop    %esi
  802047:	5f                   	pop    %edi
  802048:	5d                   	pop    %ebp
  802049:	c3                   	ret    
  80204a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802050:	0f bd f8             	bsr    %eax,%edi
  802053:	83 f7 1f             	xor    $0x1f,%edi
  802056:	75 48                	jne    8020a0 <__udivdi3+0xa0>
  802058:	39 f0                	cmp    %esi,%eax
  80205a:	72 06                	jb     802062 <__udivdi3+0x62>
  80205c:	31 c0                	xor    %eax,%eax
  80205e:	39 eb                	cmp    %ebp,%ebx
  802060:	77 de                	ja     802040 <__udivdi3+0x40>
  802062:	b8 01 00 00 00       	mov    $0x1,%eax
  802067:	eb d7                	jmp    802040 <__udivdi3+0x40>
  802069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802070:	89 d9                	mov    %ebx,%ecx
  802072:	85 db                	test   %ebx,%ebx
  802074:	75 0b                	jne    802081 <__udivdi3+0x81>
  802076:	b8 01 00 00 00       	mov    $0x1,%eax
  80207b:	31 d2                	xor    %edx,%edx
  80207d:	f7 f3                	div    %ebx
  80207f:	89 c1                	mov    %eax,%ecx
  802081:	31 d2                	xor    %edx,%edx
  802083:	89 f0                	mov    %esi,%eax
  802085:	f7 f1                	div    %ecx
  802087:	89 c6                	mov    %eax,%esi
  802089:	89 e8                	mov    %ebp,%eax
  80208b:	89 f7                	mov    %esi,%edi
  80208d:	f7 f1                	div    %ecx
  80208f:	89 fa                	mov    %edi,%edx
  802091:	83 c4 1c             	add    $0x1c,%esp
  802094:	5b                   	pop    %ebx
  802095:	5e                   	pop    %esi
  802096:	5f                   	pop    %edi
  802097:	5d                   	pop    %ebp
  802098:	c3                   	ret    
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	89 f9                	mov    %edi,%ecx
  8020a2:	ba 20 00 00 00       	mov    $0x20,%edx
  8020a7:	29 fa                	sub    %edi,%edx
  8020a9:	d3 e0                	shl    %cl,%eax
  8020ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020af:	89 d1                	mov    %edx,%ecx
  8020b1:	89 d8                	mov    %ebx,%eax
  8020b3:	d3 e8                	shr    %cl,%eax
  8020b5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020b9:	09 c1                	or     %eax,%ecx
  8020bb:	89 f0                	mov    %esi,%eax
  8020bd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020c1:	89 f9                	mov    %edi,%ecx
  8020c3:	d3 e3                	shl    %cl,%ebx
  8020c5:	89 d1                	mov    %edx,%ecx
  8020c7:	d3 e8                	shr    %cl,%eax
  8020c9:	89 f9                	mov    %edi,%ecx
  8020cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020cf:	89 eb                	mov    %ebp,%ebx
  8020d1:	d3 e6                	shl    %cl,%esi
  8020d3:	89 d1                	mov    %edx,%ecx
  8020d5:	d3 eb                	shr    %cl,%ebx
  8020d7:	09 f3                	or     %esi,%ebx
  8020d9:	89 c6                	mov    %eax,%esi
  8020db:	89 f2                	mov    %esi,%edx
  8020dd:	89 d8                	mov    %ebx,%eax
  8020df:	f7 74 24 08          	divl   0x8(%esp)
  8020e3:	89 d6                	mov    %edx,%esi
  8020e5:	89 c3                	mov    %eax,%ebx
  8020e7:	f7 64 24 0c          	mull   0xc(%esp)
  8020eb:	39 d6                	cmp    %edx,%esi
  8020ed:	72 19                	jb     802108 <__udivdi3+0x108>
  8020ef:	89 f9                	mov    %edi,%ecx
  8020f1:	d3 e5                	shl    %cl,%ebp
  8020f3:	39 c5                	cmp    %eax,%ebp
  8020f5:	73 04                	jae    8020fb <__udivdi3+0xfb>
  8020f7:	39 d6                	cmp    %edx,%esi
  8020f9:	74 0d                	je     802108 <__udivdi3+0x108>
  8020fb:	89 d8                	mov    %ebx,%eax
  8020fd:	31 ff                	xor    %edi,%edi
  8020ff:	e9 3c ff ff ff       	jmp    802040 <__udivdi3+0x40>
  802104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802108:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80210b:	31 ff                	xor    %edi,%edi
  80210d:	e9 2e ff ff ff       	jmp    802040 <__udivdi3+0x40>
  802112:	66 90                	xchg   %ax,%ax
  802114:	66 90                	xchg   %ax,%ax
  802116:	66 90                	xchg   %ax,%ax
  802118:	66 90                	xchg   %ax,%ax
  80211a:	66 90                	xchg   %ax,%ax
  80211c:	66 90                	xchg   %ax,%ax
  80211e:	66 90                	xchg   %ax,%ax

00802120 <__umoddi3>:
  802120:	f3 0f 1e fb          	endbr32 
  802124:	55                   	push   %ebp
  802125:	57                   	push   %edi
  802126:	56                   	push   %esi
  802127:	53                   	push   %ebx
  802128:	83 ec 1c             	sub    $0x1c,%esp
  80212b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80212f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802133:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802137:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80213b:	89 f0                	mov    %esi,%eax
  80213d:	89 da                	mov    %ebx,%edx
  80213f:	85 ff                	test   %edi,%edi
  802141:	75 15                	jne    802158 <__umoddi3+0x38>
  802143:	39 dd                	cmp    %ebx,%ebp
  802145:	76 39                	jbe    802180 <__umoddi3+0x60>
  802147:	f7 f5                	div    %ebp
  802149:	89 d0                	mov    %edx,%eax
  80214b:	31 d2                	xor    %edx,%edx
  80214d:	83 c4 1c             	add    $0x1c,%esp
  802150:	5b                   	pop    %ebx
  802151:	5e                   	pop    %esi
  802152:	5f                   	pop    %edi
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    
  802155:	8d 76 00             	lea    0x0(%esi),%esi
  802158:	39 df                	cmp    %ebx,%edi
  80215a:	77 f1                	ja     80214d <__umoddi3+0x2d>
  80215c:	0f bd cf             	bsr    %edi,%ecx
  80215f:	83 f1 1f             	xor    $0x1f,%ecx
  802162:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802166:	75 40                	jne    8021a8 <__umoddi3+0x88>
  802168:	39 df                	cmp    %ebx,%edi
  80216a:	72 04                	jb     802170 <__umoddi3+0x50>
  80216c:	39 f5                	cmp    %esi,%ebp
  80216e:	77 dd                	ja     80214d <__umoddi3+0x2d>
  802170:	89 da                	mov    %ebx,%edx
  802172:	89 f0                	mov    %esi,%eax
  802174:	29 e8                	sub    %ebp,%eax
  802176:	19 fa                	sbb    %edi,%edx
  802178:	eb d3                	jmp    80214d <__umoddi3+0x2d>
  80217a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802180:	89 e9                	mov    %ebp,%ecx
  802182:	85 ed                	test   %ebp,%ebp
  802184:	75 0b                	jne    802191 <__umoddi3+0x71>
  802186:	b8 01 00 00 00       	mov    $0x1,%eax
  80218b:	31 d2                	xor    %edx,%edx
  80218d:	f7 f5                	div    %ebp
  80218f:	89 c1                	mov    %eax,%ecx
  802191:	89 d8                	mov    %ebx,%eax
  802193:	31 d2                	xor    %edx,%edx
  802195:	f7 f1                	div    %ecx
  802197:	89 f0                	mov    %esi,%eax
  802199:	f7 f1                	div    %ecx
  80219b:	89 d0                	mov    %edx,%eax
  80219d:	31 d2                	xor    %edx,%edx
  80219f:	eb ac                	jmp    80214d <__umoddi3+0x2d>
  8021a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021ac:	ba 20 00 00 00       	mov    $0x20,%edx
  8021b1:	29 c2                	sub    %eax,%edx
  8021b3:	89 c1                	mov    %eax,%ecx
  8021b5:	89 e8                	mov    %ebp,%eax
  8021b7:	d3 e7                	shl    %cl,%edi
  8021b9:	89 d1                	mov    %edx,%ecx
  8021bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021bf:	d3 e8                	shr    %cl,%eax
  8021c1:	89 c1                	mov    %eax,%ecx
  8021c3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021c7:	09 f9                	or     %edi,%ecx
  8021c9:	89 df                	mov    %ebx,%edi
  8021cb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021cf:	89 c1                	mov    %eax,%ecx
  8021d1:	d3 e5                	shl    %cl,%ebp
  8021d3:	89 d1                	mov    %edx,%ecx
  8021d5:	d3 ef                	shr    %cl,%edi
  8021d7:	89 c1                	mov    %eax,%ecx
  8021d9:	89 f0                	mov    %esi,%eax
  8021db:	d3 e3                	shl    %cl,%ebx
  8021dd:	89 d1                	mov    %edx,%ecx
  8021df:	89 fa                	mov    %edi,%edx
  8021e1:	d3 e8                	shr    %cl,%eax
  8021e3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021e8:	09 d8                	or     %ebx,%eax
  8021ea:	f7 74 24 08          	divl   0x8(%esp)
  8021ee:	89 d3                	mov    %edx,%ebx
  8021f0:	d3 e6                	shl    %cl,%esi
  8021f2:	f7 e5                	mul    %ebp
  8021f4:	89 c7                	mov    %eax,%edi
  8021f6:	89 d1                	mov    %edx,%ecx
  8021f8:	39 d3                	cmp    %edx,%ebx
  8021fa:	72 06                	jb     802202 <__umoddi3+0xe2>
  8021fc:	75 0e                	jne    80220c <__umoddi3+0xec>
  8021fe:	39 c6                	cmp    %eax,%esi
  802200:	73 0a                	jae    80220c <__umoddi3+0xec>
  802202:	29 e8                	sub    %ebp,%eax
  802204:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802208:	89 d1                	mov    %edx,%ecx
  80220a:	89 c7                	mov    %eax,%edi
  80220c:	89 f5                	mov    %esi,%ebp
  80220e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802212:	29 fd                	sub    %edi,%ebp
  802214:	19 cb                	sbb    %ecx,%ebx
  802216:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80221b:	89 d8                	mov    %ebx,%eax
  80221d:	d3 e0                	shl    %cl,%eax
  80221f:	89 f1                	mov    %esi,%ecx
  802221:	d3 ed                	shr    %cl,%ebp
  802223:	d3 eb                	shr    %cl,%ebx
  802225:	09 e8                	or     %ebp,%eax
  802227:	89 da                	mov    %ebx,%edx
  802229:	83 c4 1c             	add    $0x1c,%esp
  80222c:	5b                   	pop    %ebx
  80222d:	5e                   	pop    %esi
  80222e:	5f                   	pop    %edi
  80222f:	5d                   	pop    %ebp
  802230:	c3                   	ret    
