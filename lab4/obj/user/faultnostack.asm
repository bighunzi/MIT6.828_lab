
obj/user/faultnostack：     文件格式 elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	68 17 03 80 00       	push   $0x800317
  80003e:	6a 00                	push   $0x0
  800040:	e8 2c 02 00 00       	call   800271 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800045:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80004c:	00 00 00 
}
  80004f:	83 c4 10             	add    $0x10,%esp
  800052:	c9                   	leave  
  800053:	c3                   	ret    

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	56                   	push   %esi
  800058:	53                   	push   %ebx
  800059:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005c:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  80005f:	e8 c6 00 00 00       	call   80012a <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800081:	83 ec 08             	sub    $0x8,%esp
  800084:	56                   	push   %esi
  800085:	53                   	push   %ebx
  800086:	e8 a8 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008b:	e8 0a 00 00 00       	call   80009a <exit>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5d                   	pop    %ebp
  800099:	c3                   	ret    

0080009a <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009a:	55                   	push   %ebp
  80009b:	89 e5                	mov    %esp,%ebp
  80009d:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000a0:	6a 00                	push   $0x0
  8000a2:	e8 42 00 00 00       	call   8000e9 <sys_env_destroy>
}
  8000a7:	83 c4 10             	add    $0x10,%esp
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bd:	89 c3                	mov    %eax,%ebx
  8000bf:	89 c7                	mov    %eax,%edi
  8000c1:	89 c6                	mov    %eax,%esi
  8000c3:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c5:	5b                   	pop    %ebx
  8000c6:	5e                   	pop    %esi
  8000c7:	5f                   	pop    %edi
  8000c8:	5d                   	pop    %ebp
  8000c9:	c3                   	ret    

008000ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8000ca:	55                   	push   %ebp
  8000cb:	89 e5                	mov    %esp,%ebp
  8000cd:	57                   	push   %edi
  8000ce:	56                   	push   %esi
  8000cf:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8000da:	89 d1                	mov    %edx,%ecx
  8000dc:	89 d3                	mov    %edx,%ebx
  8000de:	89 d7                	mov    %edx,%edi
  8000e0:	89 d6                	mov    %edx,%esi
  8000e2:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e4:	5b                   	pop    %ebx
  8000e5:	5e                   	pop    %esi
  8000e6:	5f                   	pop    %edi
  8000e7:	5d                   	pop    %ebp
  8000e8:	c3                   	ret    

008000e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e9:	55                   	push   %ebp
  8000ea:	89 e5                	mov    %esp,%ebp
  8000ec:	57                   	push   %edi
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ff:	89 cb                	mov    %ecx,%ebx
  800101:	89 cf                	mov    %ecx,%edi
  800103:	89 ce                	mov    %ecx,%esi
  800105:	cd 30                	int    $0x30
	if(check && ret > 0)
  800107:	85 c0                	test   %eax,%eax
  800109:	7f 08                	jg     800113 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800113:	83 ec 0c             	sub    $0xc,%esp
  800116:	50                   	push   %eax
  800117:	6a 03                	push   $0x3
  800119:	68 0a 10 80 00       	push   $0x80100a
  80011e:	6a 2a                	push   $0x2a
  800120:	68 27 10 80 00       	push   $0x801027
  800125:	e8 13 02 00 00       	call   80033d <_panic>

0080012a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012a:	55                   	push   %ebp
  80012b:	89 e5                	mov    %esp,%ebp
  80012d:	57                   	push   %edi
  80012e:	56                   	push   %esi
  80012f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 02 00 00 00       	mov    $0x2,%eax
  80013a:	89 d1                	mov    %edx,%ecx
  80013c:	89 d3                	mov    %edx,%ebx
  80013e:	89 d7                	mov    %edx,%edi
  800140:	89 d6                	mov    %edx,%esi
  800142:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_yield>:

void
sys_yield(void)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	57                   	push   %edi
  80014d:	56                   	push   %esi
  80014e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014f:	ba 00 00 00 00       	mov    $0x0,%edx
  800154:	b8 0a 00 00 00       	mov    $0xa,%eax
  800159:	89 d1                	mov    %edx,%ecx
  80015b:	89 d3                	mov    %edx,%ebx
  80015d:	89 d7                	mov    %edx,%edi
  80015f:	89 d6                	mov    %edx,%esi
  800161:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800163:	5b                   	pop    %ebx
  800164:	5e                   	pop    %esi
  800165:	5f                   	pop    %edi
  800166:	5d                   	pop    %ebp
  800167:	c3                   	ret    

00800168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800168:	55                   	push   %ebp
  800169:	89 e5                	mov    %esp,%ebp
  80016b:	57                   	push   %edi
  80016c:	56                   	push   %esi
  80016d:	53                   	push   %ebx
  80016e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800171:	be 00 00 00 00       	mov    $0x0,%esi
  800176:	8b 55 08             	mov    0x8(%ebp),%edx
  800179:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80017c:	b8 04 00 00 00       	mov    $0x4,%eax
  800181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800184:	89 f7                	mov    %esi,%edi
  800186:	cd 30                	int    $0x30
	if(check && ret > 0)
  800188:	85 c0                	test   %eax,%eax
  80018a:	7f 08                	jg     800194 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80018f:	5b                   	pop    %ebx
  800190:	5e                   	pop    %esi
  800191:	5f                   	pop    %edi
  800192:	5d                   	pop    %ebp
  800193:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800194:	83 ec 0c             	sub    $0xc,%esp
  800197:	50                   	push   %eax
  800198:	6a 04                	push   $0x4
  80019a:	68 0a 10 80 00       	push   $0x80100a
  80019f:	6a 2a                	push   $0x2a
  8001a1:	68 27 10 80 00       	push   $0x801027
  8001a6:	e8 92 01 00 00       	call   80033d <_panic>

008001ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	57                   	push   %edi
  8001af:	56                   	push   %esi
  8001b0:	53                   	push   %ebx
  8001b1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ba:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ca:	85 c0                	test   %eax,%eax
  8001cc:	7f 08                	jg     8001d6 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d1:	5b                   	pop    %ebx
  8001d2:	5e                   	pop    %esi
  8001d3:	5f                   	pop    %edi
  8001d4:	5d                   	pop    %ebp
  8001d5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d6:	83 ec 0c             	sub    $0xc,%esp
  8001d9:	50                   	push   %eax
  8001da:	6a 05                	push   $0x5
  8001dc:	68 0a 10 80 00       	push   $0x80100a
  8001e1:	6a 2a                	push   $0x2a
  8001e3:	68 27 10 80 00       	push   $0x801027
  8001e8:	e8 50 01 00 00       	call   80033d <_panic>

008001ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	57                   	push   %edi
  8001f1:	56                   	push   %esi
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800201:	b8 06 00 00 00       	mov    $0x6,%eax
  800206:	89 df                	mov    %ebx,%edi
  800208:	89 de                	mov    %ebx,%esi
  80020a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80020c:	85 c0                	test   %eax,%eax
  80020e:	7f 08                	jg     800218 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800210:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800213:	5b                   	pop    %ebx
  800214:	5e                   	pop    %esi
  800215:	5f                   	pop    %edi
  800216:	5d                   	pop    %ebp
  800217:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800218:	83 ec 0c             	sub    $0xc,%esp
  80021b:	50                   	push   %eax
  80021c:	6a 06                	push   $0x6
  80021e:	68 0a 10 80 00       	push   $0x80100a
  800223:	6a 2a                	push   $0x2a
  800225:	68 27 10 80 00       	push   $0x801027
  80022a:	e8 0e 01 00 00       	call   80033d <_panic>

0080022f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022f:	55                   	push   %ebp
  800230:	89 e5                	mov    %esp,%ebp
  800232:	57                   	push   %edi
  800233:	56                   	push   %esi
  800234:	53                   	push   %ebx
  800235:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023d:	8b 55 08             	mov    0x8(%ebp),%edx
  800240:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800243:	b8 08 00 00 00       	mov    $0x8,%eax
  800248:	89 df                	mov    %ebx,%edi
  80024a:	89 de                	mov    %ebx,%esi
  80024c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80024e:	85 c0                	test   %eax,%eax
  800250:	7f 08                	jg     80025a <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800252:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800255:	5b                   	pop    %ebx
  800256:	5e                   	pop    %esi
  800257:	5f                   	pop    %edi
  800258:	5d                   	pop    %ebp
  800259:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80025a:	83 ec 0c             	sub    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	6a 08                	push   $0x8
  800260:	68 0a 10 80 00       	push   $0x80100a
  800265:	6a 2a                	push   $0x2a
  800267:	68 27 10 80 00       	push   $0x801027
  80026c:	e8 cc 00 00 00       	call   80033d <_panic>

00800271 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800271:	55                   	push   %ebp
  800272:	89 e5                	mov    %esp,%ebp
  800274:	57                   	push   %edi
  800275:	56                   	push   %esi
  800276:	53                   	push   %ebx
  800277:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80027a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027f:	8b 55 08             	mov    0x8(%ebp),%edx
  800282:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800285:	b8 09 00 00 00       	mov    $0x9,%eax
  80028a:	89 df                	mov    %ebx,%edi
  80028c:	89 de                	mov    %ebx,%esi
  80028e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800290:	85 c0                	test   %eax,%eax
  800292:	7f 08                	jg     80029c <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800294:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800297:	5b                   	pop    %ebx
  800298:	5e                   	pop    %esi
  800299:	5f                   	pop    %edi
  80029a:	5d                   	pop    %ebp
  80029b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80029c:	83 ec 0c             	sub    $0xc,%esp
  80029f:	50                   	push   %eax
  8002a0:	6a 09                	push   $0x9
  8002a2:	68 0a 10 80 00       	push   $0x80100a
  8002a7:	6a 2a                	push   $0x2a
  8002a9:	68 27 10 80 00       	push   $0x801027
  8002ae:	e8 8a 00 00 00       	call   80033d <_panic>

008002b3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	57                   	push   %edi
  8002b7:	56                   	push   %esi
  8002b8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002c4:	be 00 00 00 00       	mov    $0x0,%esi
  8002c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002cc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002cf:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002d1:	5b                   	pop    %ebx
  8002d2:	5e                   	pop    %esi
  8002d3:	5f                   	pop    %edi
  8002d4:	5d                   	pop    %ebp
  8002d5:	c3                   	ret    

008002d6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d6:	55                   	push   %ebp
  8002d7:	89 e5                	mov    %esp,%ebp
  8002d9:	57                   	push   %edi
  8002da:	56                   	push   %esi
  8002db:	53                   	push   %ebx
  8002dc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002df:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e7:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ec:	89 cb                	mov    %ecx,%ebx
  8002ee:	89 cf                	mov    %ecx,%edi
  8002f0:	89 ce                	mov    %ecx,%esi
  8002f2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002f4:	85 c0                	test   %eax,%eax
  8002f6:	7f 08                	jg     800300 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fb:	5b                   	pop    %ebx
  8002fc:	5e                   	pop    %esi
  8002fd:	5f                   	pop    %edi
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800300:	83 ec 0c             	sub    $0xc,%esp
  800303:	50                   	push   %eax
  800304:	6a 0c                	push   $0xc
  800306:	68 0a 10 80 00       	push   $0x80100a
  80030b:	6a 2a                	push   $0x2a
  80030d:	68 27 10 80 00       	push   $0x801027
  800312:	e8 26 00 00 00       	call   80033d <_panic>

00800317 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800317:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800318:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  80031d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80031f:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  800322:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  800326:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  800329:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  80032d:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  800331:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  800333:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  800336:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  800337:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  80033a:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  80033b:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  80033c:	c3                   	ret    

0080033d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	56                   	push   %esi
  800341:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800342:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800345:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80034b:	e8 da fd ff ff       	call   80012a <sys_getenvid>
  800350:	83 ec 0c             	sub    $0xc,%esp
  800353:	ff 75 0c             	push   0xc(%ebp)
  800356:	ff 75 08             	push   0x8(%ebp)
  800359:	56                   	push   %esi
  80035a:	50                   	push   %eax
  80035b:	68 38 10 80 00       	push   $0x801038
  800360:	e8 b3 00 00 00       	call   800418 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800365:	83 c4 18             	add    $0x18,%esp
  800368:	53                   	push   %ebx
  800369:	ff 75 10             	push   0x10(%ebp)
  80036c:	e8 56 00 00 00       	call   8003c7 <vcprintf>
	cprintf("\n");
  800371:	c7 04 24 5b 10 80 00 	movl   $0x80105b,(%esp)
  800378:	e8 9b 00 00 00       	call   800418 <cprintf>
  80037d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800380:	cc                   	int3   
  800381:	eb fd                	jmp    800380 <_panic+0x43>

00800383 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	53                   	push   %ebx
  800387:	83 ec 04             	sub    $0x4,%esp
  80038a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80038d:	8b 13                	mov    (%ebx),%edx
  80038f:	8d 42 01             	lea    0x1(%edx),%eax
  800392:	89 03                	mov    %eax,(%ebx)
  800394:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800397:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80039b:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a0:	74 09                	je     8003ab <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003a2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003a9:	c9                   	leave  
  8003aa:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003ab:	83 ec 08             	sub    $0x8,%esp
  8003ae:	68 ff 00 00 00       	push   $0xff
  8003b3:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b6:	50                   	push   %eax
  8003b7:	e8 f0 fc ff ff       	call   8000ac <sys_cputs>
		b->idx = 0;
  8003bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003c2:	83 c4 10             	add    $0x10,%esp
  8003c5:	eb db                	jmp    8003a2 <putch+0x1f>

008003c7 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003c7:	55                   	push   %ebp
  8003c8:	89 e5                	mov    %esp,%ebp
  8003ca:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003d0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003d7:	00 00 00 
	b.cnt = 0;
  8003da:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003e1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003e4:	ff 75 0c             	push   0xc(%ebp)
  8003e7:	ff 75 08             	push   0x8(%ebp)
  8003ea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003f0:	50                   	push   %eax
  8003f1:	68 83 03 80 00       	push   $0x800383
  8003f6:	e8 14 01 00 00       	call   80050f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003fb:	83 c4 08             	add    $0x8,%esp
  8003fe:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  800404:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80040a:	50                   	push   %eax
  80040b:	e8 9c fc ff ff       	call   8000ac <sys_cputs>

	return b.cnt;
}
  800410:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800416:	c9                   	leave  
  800417:	c3                   	ret    

00800418 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800418:	55                   	push   %ebp
  800419:	89 e5                	mov    %esp,%ebp
  80041b:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80041e:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800421:	50                   	push   %eax
  800422:	ff 75 08             	push   0x8(%ebp)
  800425:	e8 9d ff ff ff       	call   8003c7 <vcprintf>
	va_end(ap);

	return cnt;
}
  80042a:	c9                   	leave  
  80042b:	c3                   	ret    

0080042c <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80042c:	55                   	push   %ebp
  80042d:	89 e5                	mov    %esp,%ebp
  80042f:	57                   	push   %edi
  800430:	56                   	push   %esi
  800431:	53                   	push   %ebx
  800432:	83 ec 1c             	sub    $0x1c,%esp
  800435:	89 c7                	mov    %eax,%edi
  800437:	89 d6                	mov    %edx,%esi
  800439:	8b 45 08             	mov    0x8(%ebp),%eax
  80043c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043f:	89 d1                	mov    %edx,%ecx
  800441:	89 c2                	mov    %eax,%edx
  800443:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800446:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800449:	8b 45 10             	mov    0x10(%ebp),%eax
  80044c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80044f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800452:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800459:	39 c2                	cmp    %eax,%edx
  80045b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80045e:	72 3e                	jb     80049e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800460:	83 ec 0c             	sub    $0xc,%esp
  800463:	ff 75 18             	push   0x18(%ebp)
  800466:	83 eb 01             	sub    $0x1,%ebx
  800469:	53                   	push   %ebx
  80046a:	50                   	push   %eax
  80046b:	83 ec 08             	sub    $0x8,%esp
  80046e:	ff 75 e4             	push   -0x1c(%ebp)
  800471:	ff 75 e0             	push   -0x20(%ebp)
  800474:	ff 75 dc             	push   -0x24(%ebp)
  800477:	ff 75 d8             	push   -0x28(%ebp)
  80047a:	e8 31 09 00 00       	call   800db0 <__udivdi3>
  80047f:	83 c4 18             	add    $0x18,%esp
  800482:	52                   	push   %edx
  800483:	50                   	push   %eax
  800484:	89 f2                	mov    %esi,%edx
  800486:	89 f8                	mov    %edi,%eax
  800488:	e8 9f ff ff ff       	call   80042c <printnum>
  80048d:	83 c4 20             	add    $0x20,%esp
  800490:	eb 13                	jmp    8004a5 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800492:	83 ec 08             	sub    $0x8,%esp
  800495:	56                   	push   %esi
  800496:	ff 75 18             	push   0x18(%ebp)
  800499:	ff d7                	call   *%edi
  80049b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80049e:	83 eb 01             	sub    $0x1,%ebx
  8004a1:	85 db                	test   %ebx,%ebx
  8004a3:	7f ed                	jg     800492 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004a5:	83 ec 08             	sub    $0x8,%esp
  8004a8:	56                   	push   %esi
  8004a9:	83 ec 04             	sub    $0x4,%esp
  8004ac:	ff 75 e4             	push   -0x1c(%ebp)
  8004af:	ff 75 e0             	push   -0x20(%ebp)
  8004b2:	ff 75 dc             	push   -0x24(%ebp)
  8004b5:	ff 75 d8             	push   -0x28(%ebp)
  8004b8:	e8 13 0a 00 00       	call   800ed0 <__umoddi3>
  8004bd:	83 c4 14             	add    $0x14,%esp
  8004c0:	0f be 80 5d 10 80 00 	movsbl 0x80105d(%eax),%eax
  8004c7:	50                   	push   %eax
  8004c8:	ff d7                	call   *%edi
}
  8004ca:	83 c4 10             	add    $0x10,%esp
  8004cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d0:	5b                   	pop    %ebx
  8004d1:	5e                   	pop    %esi
  8004d2:	5f                   	pop    %edi
  8004d3:	5d                   	pop    %ebp
  8004d4:	c3                   	ret    

008004d5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
  8004d8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004db:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004df:	8b 10                	mov    (%eax),%edx
  8004e1:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e4:	73 0a                	jae    8004f0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004e6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004e9:	89 08                	mov    %ecx,(%eax)
  8004eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ee:	88 02                	mov    %al,(%edx)
}
  8004f0:	5d                   	pop    %ebp
  8004f1:	c3                   	ret    

008004f2 <printfmt>:
{
  8004f2:	55                   	push   %ebp
  8004f3:	89 e5                	mov    %esp,%ebp
  8004f5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004f8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004fb:	50                   	push   %eax
  8004fc:	ff 75 10             	push   0x10(%ebp)
  8004ff:	ff 75 0c             	push   0xc(%ebp)
  800502:	ff 75 08             	push   0x8(%ebp)
  800505:	e8 05 00 00 00       	call   80050f <vprintfmt>
}
  80050a:	83 c4 10             	add    $0x10,%esp
  80050d:	c9                   	leave  
  80050e:	c3                   	ret    

0080050f <vprintfmt>:
{
  80050f:	55                   	push   %ebp
  800510:	89 e5                	mov    %esp,%ebp
  800512:	57                   	push   %edi
  800513:	56                   	push   %esi
  800514:	53                   	push   %ebx
  800515:	83 ec 3c             	sub    $0x3c,%esp
  800518:	8b 75 08             	mov    0x8(%ebp),%esi
  80051b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800521:	eb 0a                	jmp    80052d <vprintfmt+0x1e>
			putch(ch, putdat);
  800523:	83 ec 08             	sub    $0x8,%esp
  800526:	53                   	push   %ebx
  800527:	50                   	push   %eax
  800528:	ff d6                	call   *%esi
  80052a:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80052d:	83 c7 01             	add    $0x1,%edi
  800530:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800534:	83 f8 25             	cmp    $0x25,%eax
  800537:	74 0c                	je     800545 <vprintfmt+0x36>
			if (ch == '\0')
  800539:	85 c0                	test   %eax,%eax
  80053b:	75 e6                	jne    800523 <vprintfmt+0x14>
}
  80053d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800540:	5b                   	pop    %ebx
  800541:	5e                   	pop    %esi
  800542:	5f                   	pop    %edi
  800543:	5d                   	pop    %ebp
  800544:	c3                   	ret    
		padc = ' ';
  800545:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800549:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800550:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800557:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80055e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800563:	8d 47 01             	lea    0x1(%edi),%eax
  800566:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800569:	0f b6 17             	movzbl (%edi),%edx
  80056c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80056f:	3c 55                	cmp    $0x55,%al
  800571:	0f 87 bb 03 00 00    	ja     800932 <vprintfmt+0x423>
  800577:	0f b6 c0             	movzbl %al,%eax
  80057a:	ff 24 85 20 11 80 00 	jmp    *0x801120(,%eax,4)
  800581:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800584:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800588:	eb d9                	jmp    800563 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80058a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800591:	eb d0                	jmp    800563 <vprintfmt+0x54>
  800593:	0f b6 d2             	movzbl %dl,%edx
  800596:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800599:	b8 00 00 00 00       	mov    $0x0,%eax
  80059e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005a1:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005a4:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005a8:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005ab:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005ae:	83 f9 09             	cmp    $0x9,%ecx
  8005b1:	77 55                	ja     800608 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  8005b3:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005b6:	eb e9                	jmp    8005a1 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8005b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bb:	8b 00                	mov    (%eax),%eax
  8005bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c3:	8d 40 04             	lea    0x4(%eax),%eax
  8005c6:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005cc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d0:	79 91                	jns    800563 <vprintfmt+0x54>
				width = precision, precision = -1;
  8005d2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005d8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005df:	eb 82                	jmp    800563 <vprintfmt+0x54>
  8005e1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005e4:	85 d2                	test   %edx,%edx
  8005e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8005eb:	0f 49 c2             	cmovns %edx,%eax
  8005ee:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005f4:	e9 6a ff ff ff       	jmp    800563 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005fc:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800603:	e9 5b ff ff ff       	jmp    800563 <vprintfmt+0x54>
  800608:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80060b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80060e:	eb bc                	jmp    8005cc <vprintfmt+0xbd>
			lflag++;
  800610:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800613:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800616:	e9 48 ff ff ff       	jmp    800563 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8d 78 04             	lea    0x4(%eax),%edi
  800621:	83 ec 08             	sub    $0x8,%esp
  800624:	53                   	push   %ebx
  800625:	ff 30                	push   (%eax)
  800627:	ff d6                	call   *%esi
			break;
  800629:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  80062c:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80062f:	e9 9d 02 00 00       	jmp    8008d1 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 78 04             	lea    0x4(%eax),%edi
  80063a:	8b 10                	mov    (%eax),%edx
  80063c:	89 d0                	mov    %edx,%eax
  80063e:	f7 d8                	neg    %eax
  800640:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800643:	83 f8 08             	cmp    $0x8,%eax
  800646:	7f 23                	jg     80066b <vprintfmt+0x15c>
  800648:	8b 14 85 80 12 80 00 	mov    0x801280(,%eax,4),%edx
  80064f:	85 d2                	test   %edx,%edx
  800651:	74 18                	je     80066b <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800653:	52                   	push   %edx
  800654:	68 7e 10 80 00       	push   $0x80107e
  800659:	53                   	push   %ebx
  80065a:	56                   	push   %esi
  80065b:	e8 92 fe ff ff       	call   8004f2 <printfmt>
  800660:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800663:	89 7d 14             	mov    %edi,0x14(%ebp)
  800666:	e9 66 02 00 00       	jmp    8008d1 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80066b:	50                   	push   %eax
  80066c:	68 75 10 80 00       	push   $0x801075
  800671:	53                   	push   %ebx
  800672:	56                   	push   %esi
  800673:	e8 7a fe ff ff       	call   8004f2 <printfmt>
  800678:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80067b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80067e:	e9 4e 02 00 00       	jmp    8008d1 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	83 c0 04             	add    $0x4,%eax
  800689:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800691:	85 d2                	test   %edx,%edx
  800693:	b8 6e 10 80 00       	mov    $0x80106e,%eax
  800698:	0f 45 c2             	cmovne %edx,%eax
  80069b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80069e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006a2:	7e 06                	jle    8006aa <vprintfmt+0x19b>
  8006a4:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006a8:	75 0d                	jne    8006b7 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006aa:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006ad:	89 c7                	mov    %eax,%edi
  8006af:	03 45 e0             	add    -0x20(%ebp),%eax
  8006b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b5:	eb 55                	jmp    80070c <vprintfmt+0x1fd>
  8006b7:	83 ec 08             	sub    $0x8,%esp
  8006ba:	ff 75 d8             	push   -0x28(%ebp)
  8006bd:	ff 75 cc             	push   -0x34(%ebp)
  8006c0:	e8 0a 03 00 00       	call   8009cf <strnlen>
  8006c5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006c8:	29 c1                	sub    %eax,%ecx
  8006ca:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8006cd:	83 c4 10             	add    $0x10,%esp
  8006d0:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8006d2:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006d6:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d9:	eb 0f                	jmp    8006ea <vprintfmt+0x1db>
					putch(padc, putdat);
  8006db:	83 ec 08             	sub    $0x8,%esp
  8006de:	53                   	push   %ebx
  8006df:	ff 75 e0             	push   -0x20(%ebp)
  8006e2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e4:	83 ef 01             	sub    $0x1,%edi
  8006e7:	83 c4 10             	add    $0x10,%esp
  8006ea:	85 ff                	test   %edi,%edi
  8006ec:	7f ed                	jg     8006db <vprintfmt+0x1cc>
  8006ee:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006f1:	85 d2                	test   %edx,%edx
  8006f3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f8:	0f 49 c2             	cmovns %edx,%eax
  8006fb:	29 c2                	sub    %eax,%edx
  8006fd:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800700:	eb a8                	jmp    8006aa <vprintfmt+0x19b>
					putch(ch, putdat);
  800702:	83 ec 08             	sub    $0x8,%esp
  800705:	53                   	push   %ebx
  800706:	52                   	push   %edx
  800707:	ff d6                	call   *%esi
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80070f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800711:	83 c7 01             	add    $0x1,%edi
  800714:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800718:	0f be d0             	movsbl %al,%edx
  80071b:	85 d2                	test   %edx,%edx
  80071d:	74 4b                	je     80076a <vprintfmt+0x25b>
  80071f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800723:	78 06                	js     80072b <vprintfmt+0x21c>
  800725:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800729:	78 1e                	js     800749 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80072b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80072f:	74 d1                	je     800702 <vprintfmt+0x1f3>
  800731:	0f be c0             	movsbl %al,%eax
  800734:	83 e8 20             	sub    $0x20,%eax
  800737:	83 f8 5e             	cmp    $0x5e,%eax
  80073a:	76 c6                	jbe    800702 <vprintfmt+0x1f3>
					putch('?', putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	53                   	push   %ebx
  800740:	6a 3f                	push   $0x3f
  800742:	ff d6                	call   *%esi
  800744:	83 c4 10             	add    $0x10,%esp
  800747:	eb c3                	jmp    80070c <vprintfmt+0x1fd>
  800749:	89 cf                	mov    %ecx,%edi
  80074b:	eb 0e                	jmp    80075b <vprintfmt+0x24c>
				putch(' ', putdat);
  80074d:	83 ec 08             	sub    $0x8,%esp
  800750:	53                   	push   %ebx
  800751:	6a 20                	push   $0x20
  800753:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800755:	83 ef 01             	sub    $0x1,%edi
  800758:	83 c4 10             	add    $0x10,%esp
  80075b:	85 ff                	test   %edi,%edi
  80075d:	7f ee                	jg     80074d <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80075f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800762:	89 45 14             	mov    %eax,0x14(%ebp)
  800765:	e9 67 01 00 00       	jmp    8008d1 <vprintfmt+0x3c2>
  80076a:	89 cf                	mov    %ecx,%edi
  80076c:	eb ed                	jmp    80075b <vprintfmt+0x24c>
	if (lflag >= 2)
  80076e:	83 f9 01             	cmp    $0x1,%ecx
  800771:	7f 1b                	jg     80078e <vprintfmt+0x27f>
	else if (lflag)
  800773:	85 c9                	test   %ecx,%ecx
  800775:	74 63                	je     8007da <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800777:	8b 45 14             	mov    0x14(%ebp),%eax
  80077a:	8b 00                	mov    (%eax),%eax
  80077c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80077f:	99                   	cltd   
  800780:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8d 40 04             	lea    0x4(%eax),%eax
  800789:	89 45 14             	mov    %eax,0x14(%ebp)
  80078c:	eb 17                	jmp    8007a5 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80078e:	8b 45 14             	mov    0x14(%ebp),%eax
  800791:	8b 50 04             	mov    0x4(%eax),%edx
  800794:	8b 00                	mov    (%eax),%eax
  800796:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800799:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80079c:	8b 45 14             	mov    0x14(%ebp),%eax
  80079f:	8d 40 08             	lea    0x8(%eax),%eax
  8007a2:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  8007a5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007a8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  8007ab:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  8007b0:	85 c9                	test   %ecx,%ecx
  8007b2:	0f 89 ff 00 00 00    	jns    8008b7 <vprintfmt+0x3a8>
				putch('-', putdat);
  8007b8:	83 ec 08             	sub    $0x8,%esp
  8007bb:	53                   	push   %ebx
  8007bc:	6a 2d                	push   $0x2d
  8007be:	ff d6                	call   *%esi
				num = -(long long) num;
  8007c0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007c3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007c6:	f7 da                	neg    %edx
  8007c8:	83 d1 00             	adc    $0x0,%ecx
  8007cb:	f7 d9                	neg    %ecx
  8007cd:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007d0:	bf 0a 00 00 00       	mov    $0xa,%edi
  8007d5:	e9 dd 00 00 00       	jmp    8008b7 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8007da:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dd:	8b 00                	mov    (%eax),%eax
  8007df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007e2:	99                   	cltd   
  8007e3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007e6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e9:	8d 40 04             	lea    0x4(%eax),%eax
  8007ec:	89 45 14             	mov    %eax,0x14(%ebp)
  8007ef:	eb b4                	jmp    8007a5 <vprintfmt+0x296>
	if (lflag >= 2)
  8007f1:	83 f9 01             	cmp    $0x1,%ecx
  8007f4:	7f 1e                	jg     800814 <vprintfmt+0x305>
	else if (lflag)
  8007f6:	85 c9                	test   %ecx,%ecx
  8007f8:	74 32                	je     80082c <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8007fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fd:	8b 10                	mov    (%eax),%edx
  8007ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  800804:	8d 40 04             	lea    0x4(%eax),%eax
  800807:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80080a:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80080f:	e9 a3 00 00 00       	jmp    8008b7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800814:	8b 45 14             	mov    0x14(%ebp),%eax
  800817:	8b 10                	mov    (%eax),%edx
  800819:	8b 48 04             	mov    0x4(%eax),%ecx
  80081c:	8d 40 08             	lea    0x8(%eax),%eax
  80081f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800822:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800827:	e9 8b 00 00 00       	jmp    8008b7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80082c:	8b 45 14             	mov    0x14(%ebp),%eax
  80082f:	8b 10                	mov    (%eax),%edx
  800831:	b9 00 00 00 00       	mov    $0x0,%ecx
  800836:	8d 40 04             	lea    0x4(%eax),%eax
  800839:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80083c:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800841:	eb 74                	jmp    8008b7 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800843:	83 f9 01             	cmp    $0x1,%ecx
  800846:	7f 1b                	jg     800863 <vprintfmt+0x354>
	else if (lflag)
  800848:	85 c9                	test   %ecx,%ecx
  80084a:	74 2c                	je     800878 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80084c:	8b 45 14             	mov    0x14(%ebp),%eax
  80084f:	8b 10                	mov    (%eax),%edx
  800851:	b9 00 00 00 00       	mov    $0x0,%ecx
  800856:	8d 40 04             	lea    0x4(%eax),%eax
  800859:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80085c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800861:	eb 54                	jmp    8008b7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800863:	8b 45 14             	mov    0x14(%ebp),%eax
  800866:	8b 10                	mov    (%eax),%edx
  800868:	8b 48 04             	mov    0x4(%eax),%ecx
  80086b:	8d 40 08             	lea    0x8(%eax),%eax
  80086e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800871:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800876:	eb 3f                	jmp    8008b7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800878:	8b 45 14             	mov    0x14(%ebp),%eax
  80087b:	8b 10                	mov    (%eax),%edx
  80087d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800882:	8d 40 04             	lea    0x4(%eax),%eax
  800885:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800888:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80088d:	eb 28                	jmp    8008b7 <vprintfmt+0x3a8>
			putch('0', putdat);
  80088f:	83 ec 08             	sub    $0x8,%esp
  800892:	53                   	push   %ebx
  800893:	6a 30                	push   $0x30
  800895:	ff d6                	call   *%esi
			putch('x', putdat);
  800897:	83 c4 08             	add    $0x8,%esp
  80089a:	53                   	push   %ebx
  80089b:	6a 78                	push   $0x78
  80089d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80089f:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a2:	8b 10                	mov    (%eax),%edx
  8008a4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8008a9:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  8008ac:	8d 40 04             	lea    0x4(%eax),%eax
  8008af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008b2:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8008b7:	83 ec 0c             	sub    $0xc,%esp
  8008ba:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8008be:	50                   	push   %eax
  8008bf:	ff 75 e0             	push   -0x20(%ebp)
  8008c2:	57                   	push   %edi
  8008c3:	51                   	push   %ecx
  8008c4:	52                   	push   %edx
  8008c5:	89 da                	mov    %ebx,%edx
  8008c7:	89 f0                	mov    %esi,%eax
  8008c9:	e8 5e fb ff ff       	call   80042c <printnum>
			break;
  8008ce:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008d4:	e9 54 fc ff ff       	jmp    80052d <vprintfmt+0x1e>
	if (lflag >= 2)
  8008d9:	83 f9 01             	cmp    $0x1,%ecx
  8008dc:	7f 1b                	jg     8008f9 <vprintfmt+0x3ea>
	else if (lflag)
  8008de:	85 c9                	test   %ecx,%ecx
  8008e0:	74 2c                	je     80090e <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8008e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e5:	8b 10                	mov    (%eax),%edx
  8008e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ec:	8d 40 04             	lea    0x4(%eax),%eax
  8008ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008f2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8008f7:	eb be                	jmp    8008b7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8008f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fc:	8b 10                	mov    (%eax),%edx
  8008fe:	8b 48 04             	mov    0x4(%eax),%ecx
  800901:	8d 40 08             	lea    0x8(%eax),%eax
  800904:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800907:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  80090c:	eb a9                	jmp    8008b7 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80090e:	8b 45 14             	mov    0x14(%ebp),%eax
  800911:	8b 10                	mov    (%eax),%edx
  800913:	b9 00 00 00 00       	mov    $0x0,%ecx
  800918:	8d 40 04             	lea    0x4(%eax),%eax
  80091b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80091e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  800923:	eb 92                	jmp    8008b7 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800925:	83 ec 08             	sub    $0x8,%esp
  800928:	53                   	push   %ebx
  800929:	6a 25                	push   $0x25
  80092b:	ff d6                	call   *%esi
			break;
  80092d:	83 c4 10             	add    $0x10,%esp
  800930:	eb 9f                	jmp    8008d1 <vprintfmt+0x3c2>
			putch('%', putdat);
  800932:	83 ec 08             	sub    $0x8,%esp
  800935:	53                   	push   %ebx
  800936:	6a 25                	push   $0x25
  800938:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80093a:	83 c4 10             	add    $0x10,%esp
  80093d:	89 f8                	mov    %edi,%eax
  80093f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800943:	74 05                	je     80094a <vprintfmt+0x43b>
  800945:	83 e8 01             	sub    $0x1,%eax
  800948:	eb f5                	jmp    80093f <vprintfmt+0x430>
  80094a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80094d:	eb 82                	jmp    8008d1 <vprintfmt+0x3c2>

0080094f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
  800952:	83 ec 18             	sub    $0x18,%esp
  800955:	8b 45 08             	mov    0x8(%ebp),%eax
  800958:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80095b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80095e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800962:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800965:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80096c:	85 c0                	test   %eax,%eax
  80096e:	74 26                	je     800996 <vsnprintf+0x47>
  800970:	85 d2                	test   %edx,%edx
  800972:	7e 22                	jle    800996 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800974:	ff 75 14             	push   0x14(%ebp)
  800977:	ff 75 10             	push   0x10(%ebp)
  80097a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80097d:	50                   	push   %eax
  80097e:	68 d5 04 80 00       	push   $0x8004d5
  800983:	e8 87 fb ff ff       	call   80050f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800988:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80098b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80098e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800991:	83 c4 10             	add    $0x10,%esp
}
  800994:	c9                   	leave  
  800995:	c3                   	ret    
		return -E_INVAL;
  800996:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80099b:	eb f7                	jmp    800994 <vsnprintf+0x45>

0080099d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009a3:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009a6:	50                   	push   %eax
  8009a7:	ff 75 10             	push   0x10(%ebp)
  8009aa:	ff 75 0c             	push   0xc(%ebp)
  8009ad:	ff 75 08             	push   0x8(%ebp)
  8009b0:	e8 9a ff ff ff       	call   80094f <vsnprintf>
	va_end(ap);

	return rc;
}
  8009b5:	c9                   	leave  
  8009b6:	c3                   	ret    

008009b7 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c2:	eb 03                	jmp    8009c7 <strlen+0x10>
		n++;
  8009c4:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009c7:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009cb:	75 f7                	jne    8009c4 <strlen+0xd>
	return n;
}
  8009cd:	5d                   	pop    %ebp
  8009ce:	c3                   	ret    

008009cf <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009cf:	55                   	push   %ebp
  8009d0:	89 e5                	mov    %esp,%ebp
  8009d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8009dd:	eb 03                	jmp    8009e2 <strnlen+0x13>
		n++;
  8009df:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e2:	39 d0                	cmp    %edx,%eax
  8009e4:	74 08                	je     8009ee <strnlen+0x1f>
  8009e6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009ea:	75 f3                	jne    8009df <strnlen+0x10>
  8009ec:	89 c2                	mov    %eax,%edx
	return n;
}
  8009ee:	89 d0                	mov    %edx,%eax
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	53                   	push   %ebx
  8009f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800a01:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a05:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a08:	83 c0 01             	add    $0x1,%eax
  800a0b:	84 d2                	test   %dl,%dl
  800a0d:	75 f2                	jne    800a01 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a0f:	89 c8                	mov    %ecx,%eax
  800a11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a14:	c9                   	leave  
  800a15:	c3                   	ret    

00800a16 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	53                   	push   %ebx
  800a1a:	83 ec 10             	sub    $0x10,%esp
  800a1d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a20:	53                   	push   %ebx
  800a21:	e8 91 ff ff ff       	call   8009b7 <strlen>
  800a26:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a29:	ff 75 0c             	push   0xc(%ebp)
  800a2c:	01 d8                	add    %ebx,%eax
  800a2e:	50                   	push   %eax
  800a2f:	e8 be ff ff ff       	call   8009f2 <strcpy>
	return dst;
}
  800a34:	89 d8                	mov    %ebx,%eax
  800a36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a39:	c9                   	leave  
  800a3a:	c3                   	ret    

00800a3b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	56                   	push   %esi
  800a3f:	53                   	push   %ebx
  800a40:	8b 75 08             	mov    0x8(%ebp),%esi
  800a43:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a46:	89 f3                	mov    %esi,%ebx
  800a48:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a4b:	89 f0                	mov    %esi,%eax
  800a4d:	eb 0f                	jmp    800a5e <strncpy+0x23>
		*dst++ = *src;
  800a4f:	83 c0 01             	add    $0x1,%eax
  800a52:	0f b6 0a             	movzbl (%edx),%ecx
  800a55:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a58:	80 f9 01             	cmp    $0x1,%cl
  800a5b:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800a5e:	39 d8                	cmp    %ebx,%eax
  800a60:	75 ed                	jne    800a4f <strncpy+0x14>
	}
	return ret;
}
  800a62:	89 f0                	mov    %esi,%eax
  800a64:	5b                   	pop    %ebx
  800a65:	5e                   	pop    %esi
  800a66:	5d                   	pop    %ebp
  800a67:	c3                   	ret    

00800a68 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a68:	55                   	push   %ebp
  800a69:	89 e5                	mov    %esp,%ebp
  800a6b:	56                   	push   %esi
  800a6c:	53                   	push   %ebx
  800a6d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a73:	8b 55 10             	mov    0x10(%ebp),%edx
  800a76:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a78:	85 d2                	test   %edx,%edx
  800a7a:	74 21                	je     800a9d <strlcpy+0x35>
  800a7c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a80:	89 f2                	mov    %esi,%edx
  800a82:	eb 09                	jmp    800a8d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a84:	83 c1 01             	add    $0x1,%ecx
  800a87:	83 c2 01             	add    $0x1,%edx
  800a8a:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800a8d:	39 c2                	cmp    %eax,%edx
  800a8f:	74 09                	je     800a9a <strlcpy+0x32>
  800a91:	0f b6 19             	movzbl (%ecx),%ebx
  800a94:	84 db                	test   %bl,%bl
  800a96:	75 ec                	jne    800a84 <strlcpy+0x1c>
  800a98:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a9a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a9d:	29 f0                	sub    %esi,%eax
}
  800a9f:	5b                   	pop    %ebx
  800aa0:	5e                   	pop    %esi
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aa3:	55                   	push   %ebp
  800aa4:	89 e5                	mov    %esp,%ebp
  800aa6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aa9:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aac:	eb 06                	jmp    800ab4 <strcmp+0x11>
		p++, q++;
  800aae:	83 c1 01             	add    $0x1,%ecx
  800ab1:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800ab4:	0f b6 01             	movzbl (%ecx),%eax
  800ab7:	84 c0                	test   %al,%al
  800ab9:	74 04                	je     800abf <strcmp+0x1c>
  800abb:	3a 02                	cmp    (%edx),%al
  800abd:	74 ef                	je     800aae <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800abf:	0f b6 c0             	movzbl %al,%eax
  800ac2:	0f b6 12             	movzbl (%edx),%edx
  800ac5:	29 d0                	sub    %edx,%eax
}
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	53                   	push   %ebx
  800acd:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ad3:	89 c3                	mov    %eax,%ebx
  800ad5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ad8:	eb 06                	jmp    800ae0 <strncmp+0x17>
		n--, p++, q++;
  800ada:	83 c0 01             	add    $0x1,%eax
  800add:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ae0:	39 d8                	cmp    %ebx,%eax
  800ae2:	74 18                	je     800afc <strncmp+0x33>
  800ae4:	0f b6 08             	movzbl (%eax),%ecx
  800ae7:	84 c9                	test   %cl,%cl
  800ae9:	74 04                	je     800aef <strncmp+0x26>
  800aeb:	3a 0a                	cmp    (%edx),%cl
  800aed:	74 eb                	je     800ada <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aef:	0f b6 00             	movzbl (%eax),%eax
  800af2:	0f b6 12             	movzbl (%edx),%edx
  800af5:	29 d0                	sub    %edx,%eax
}
  800af7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800afa:	c9                   	leave  
  800afb:	c3                   	ret    
		return 0;
  800afc:	b8 00 00 00 00       	mov    $0x0,%eax
  800b01:	eb f4                	jmp    800af7 <strncmp+0x2e>

00800b03 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	8b 45 08             	mov    0x8(%ebp),%eax
  800b09:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b0d:	eb 03                	jmp    800b12 <strchr+0xf>
  800b0f:	83 c0 01             	add    $0x1,%eax
  800b12:	0f b6 10             	movzbl (%eax),%edx
  800b15:	84 d2                	test   %dl,%dl
  800b17:	74 06                	je     800b1f <strchr+0x1c>
		if (*s == c)
  800b19:	38 ca                	cmp    %cl,%dl
  800b1b:	75 f2                	jne    800b0f <strchr+0xc>
  800b1d:	eb 05                	jmp    800b24 <strchr+0x21>
			return (char *) s;
	return 0;
  800b1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b24:	5d                   	pop    %ebp
  800b25:	c3                   	ret    

00800b26 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b30:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b33:	38 ca                	cmp    %cl,%dl
  800b35:	74 09                	je     800b40 <strfind+0x1a>
  800b37:	84 d2                	test   %dl,%dl
  800b39:	74 05                	je     800b40 <strfind+0x1a>
	for (; *s; s++)
  800b3b:	83 c0 01             	add    $0x1,%eax
  800b3e:	eb f0                	jmp    800b30 <strfind+0xa>
			break;
	return (char *) s;
}
  800b40:	5d                   	pop    %ebp
  800b41:	c3                   	ret    

00800b42 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
  800b48:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b4b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b4e:	85 c9                	test   %ecx,%ecx
  800b50:	74 2f                	je     800b81 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b52:	89 f8                	mov    %edi,%eax
  800b54:	09 c8                	or     %ecx,%eax
  800b56:	a8 03                	test   $0x3,%al
  800b58:	75 21                	jne    800b7b <memset+0x39>
		c &= 0xFF;
  800b5a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b5e:	89 d0                	mov    %edx,%eax
  800b60:	c1 e0 08             	shl    $0x8,%eax
  800b63:	89 d3                	mov    %edx,%ebx
  800b65:	c1 e3 18             	shl    $0x18,%ebx
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	c1 e6 10             	shl    $0x10,%esi
  800b6d:	09 f3                	or     %esi,%ebx
  800b6f:	09 da                	or     %ebx,%edx
  800b71:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b73:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b76:	fc                   	cld    
  800b77:	f3 ab                	rep stos %eax,%es:(%edi)
  800b79:	eb 06                	jmp    800b81 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7e:	fc                   	cld    
  800b7f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b81:	89 f8                	mov    %edi,%eax
  800b83:	5b                   	pop    %ebx
  800b84:	5e                   	pop    %esi
  800b85:	5f                   	pop    %edi
  800b86:	5d                   	pop    %ebp
  800b87:	c3                   	ret    

00800b88 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b88:	55                   	push   %ebp
  800b89:	89 e5                	mov    %esp,%ebp
  800b8b:	57                   	push   %edi
  800b8c:	56                   	push   %esi
  800b8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b90:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b93:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b96:	39 c6                	cmp    %eax,%esi
  800b98:	73 32                	jae    800bcc <memmove+0x44>
  800b9a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b9d:	39 c2                	cmp    %eax,%edx
  800b9f:	76 2b                	jbe    800bcc <memmove+0x44>
		s += n;
		d += n;
  800ba1:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ba4:	89 d6                	mov    %edx,%esi
  800ba6:	09 fe                	or     %edi,%esi
  800ba8:	09 ce                	or     %ecx,%esi
  800baa:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800bb0:	75 0e                	jne    800bc0 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800bb2:	83 ef 04             	sub    $0x4,%edi
  800bb5:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bb8:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800bbb:	fd                   	std    
  800bbc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bbe:	eb 09                	jmp    800bc9 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bc0:	83 ef 01             	sub    $0x1,%edi
  800bc3:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bc6:	fd                   	std    
  800bc7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bc9:	fc                   	cld    
  800bca:	eb 1a                	jmp    800be6 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bcc:	89 f2                	mov    %esi,%edx
  800bce:	09 c2                	or     %eax,%edx
  800bd0:	09 ca                	or     %ecx,%edx
  800bd2:	f6 c2 03             	test   $0x3,%dl
  800bd5:	75 0a                	jne    800be1 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bd7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800bda:	89 c7                	mov    %eax,%edi
  800bdc:	fc                   	cld    
  800bdd:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bdf:	eb 05                	jmp    800be6 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800be1:	89 c7                	mov    %eax,%edi
  800be3:	fc                   	cld    
  800be4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800be6:	5e                   	pop    %esi
  800be7:	5f                   	pop    %edi
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bf0:	ff 75 10             	push   0x10(%ebp)
  800bf3:	ff 75 0c             	push   0xc(%ebp)
  800bf6:	ff 75 08             	push   0x8(%ebp)
  800bf9:	e8 8a ff ff ff       	call   800b88 <memmove>
}
  800bfe:	c9                   	leave  
  800bff:	c3                   	ret    

00800c00 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c00:	55                   	push   %ebp
  800c01:	89 e5                	mov    %esp,%ebp
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	8b 45 08             	mov    0x8(%ebp),%eax
  800c08:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c0b:	89 c6                	mov    %eax,%esi
  800c0d:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c10:	eb 06                	jmp    800c18 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c12:	83 c0 01             	add    $0x1,%eax
  800c15:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800c18:	39 f0                	cmp    %esi,%eax
  800c1a:	74 14                	je     800c30 <memcmp+0x30>
		if (*s1 != *s2)
  800c1c:	0f b6 08             	movzbl (%eax),%ecx
  800c1f:	0f b6 1a             	movzbl (%edx),%ebx
  800c22:	38 d9                	cmp    %bl,%cl
  800c24:	74 ec                	je     800c12 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800c26:	0f b6 c1             	movzbl %cl,%eax
  800c29:	0f b6 db             	movzbl %bl,%ebx
  800c2c:	29 d8                	sub    %ebx,%eax
  800c2e:	eb 05                	jmp    800c35 <memcmp+0x35>
	}

	return 0;
  800c30:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5d                   	pop    %ebp
  800c38:	c3                   	ret    

00800c39 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c42:	89 c2                	mov    %eax,%edx
  800c44:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c47:	eb 03                	jmp    800c4c <memfind+0x13>
  800c49:	83 c0 01             	add    $0x1,%eax
  800c4c:	39 d0                	cmp    %edx,%eax
  800c4e:	73 04                	jae    800c54 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c50:	38 08                	cmp    %cl,(%eax)
  800c52:	75 f5                	jne    800c49 <memfind+0x10>
			break;
	return (void *) s;
}
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	57                   	push   %edi
  800c5a:	56                   	push   %esi
  800c5b:	53                   	push   %ebx
  800c5c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c62:	eb 03                	jmp    800c67 <strtol+0x11>
		s++;
  800c64:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800c67:	0f b6 02             	movzbl (%edx),%eax
  800c6a:	3c 20                	cmp    $0x20,%al
  800c6c:	74 f6                	je     800c64 <strtol+0xe>
  800c6e:	3c 09                	cmp    $0x9,%al
  800c70:	74 f2                	je     800c64 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c72:	3c 2b                	cmp    $0x2b,%al
  800c74:	74 2a                	je     800ca0 <strtol+0x4a>
	int neg = 0;
  800c76:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c7b:	3c 2d                	cmp    $0x2d,%al
  800c7d:	74 2b                	je     800caa <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c7f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c85:	75 0f                	jne    800c96 <strtol+0x40>
  800c87:	80 3a 30             	cmpb   $0x30,(%edx)
  800c8a:	74 28                	je     800cb4 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c8c:	85 db                	test   %ebx,%ebx
  800c8e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c93:	0f 44 d8             	cmove  %eax,%ebx
  800c96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c9b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c9e:	eb 46                	jmp    800ce6 <strtol+0x90>
		s++;
  800ca0:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800ca3:	bf 00 00 00 00       	mov    $0x0,%edi
  800ca8:	eb d5                	jmp    800c7f <strtol+0x29>
		s++, neg = 1;
  800caa:	83 c2 01             	add    $0x1,%edx
  800cad:	bf 01 00 00 00       	mov    $0x1,%edi
  800cb2:	eb cb                	jmp    800c7f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cb4:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cb8:	74 0e                	je     800cc8 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800cba:	85 db                	test   %ebx,%ebx
  800cbc:	75 d8                	jne    800c96 <strtol+0x40>
		s++, base = 8;
  800cbe:	83 c2 01             	add    $0x1,%edx
  800cc1:	bb 08 00 00 00       	mov    $0x8,%ebx
  800cc6:	eb ce                	jmp    800c96 <strtol+0x40>
		s += 2, base = 16;
  800cc8:	83 c2 02             	add    $0x2,%edx
  800ccb:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cd0:	eb c4                	jmp    800c96 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800cd2:	0f be c0             	movsbl %al,%eax
  800cd5:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cd8:	3b 45 10             	cmp    0x10(%ebp),%eax
  800cdb:	7d 3a                	jge    800d17 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800cdd:	83 c2 01             	add    $0x1,%edx
  800ce0:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ce4:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ce6:	0f b6 02             	movzbl (%edx),%eax
  800ce9:	8d 70 d0             	lea    -0x30(%eax),%esi
  800cec:	89 f3                	mov    %esi,%ebx
  800cee:	80 fb 09             	cmp    $0x9,%bl
  800cf1:	76 df                	jbe    800cd2 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800cf3:	8d 70 9f             	lea    -0x61(%eax),%esi
  800cf6:	89 f3                	mov    %esi,%ebx
  800cf8:	80 fb 19             	cmp    $0x19,%bl
  800cfb:	77 08                	ja     800d05 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800cfd:	0f be c0             	movsbl %al,%eax
  800d00:	83 e8 57             	sub    $0x57,%eax
  800d03:	eb d3                	jmp    800cd8 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800d05:	8d 70 bf             	lea    -0x41(%eax),%esi
  800d08:	89 f3                	mov    %esi,%ebx
  800d0a:	80 fb 19             	cmp    $0x19,%bl
  800d0d:	77 08                	ja     800d17 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800d0f:	0f be c0             	movsbl %al,%eax
  800d12:	83 e8 37             	sub    $0x37,%eax
  800d15:	eb c1                	jmp    800cd8 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d17:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d1b:	74 05                	je     800d22 <strtol+0xcc>
		*endptr = (char *) s;
  800d1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d20:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800d22:	89 c8                	mov    %ecx,%eax
  800d24:	f7 d8                	neg    %eax
  800d26:	85 ff                	test   %edi,%edi
  800d28:	0f 45 c8             	cmovne %eax,%ecx
}
  800d2b:	89 c8                	mov    %ecx,%eax
  800d2d:	5b                   	pop    %ebx
  800d2e:	5e                   	pop    %esi
  800d2f:	5f                   	pop    %edi
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  800d38:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800d3f:	74 0a                	je     800d4b <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d41:	8b 45 08             	mov    0x8(%ebp),%eax
  800d44:	a3 08 20 80 00       	mov    %eax,0x802008
}
  800d49:	c9                   	leave  
  800d4a:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  800d4b:	e8 da f3 ff ff       	call   80012a <sys_getenvid>
  800d50:	83 ec 04             	sub    $0x4,%esp
  800d53:	68 07 0e 00 00       	push   $0xe07
  800d58:	68 00 f0 bf ee       	push   $0xeebff000
  800d5d:	50                   	push   %eax
  800d5e:	e8 05 f4 ff ff       	call   800168 <sys_page_alloc>
		if (r < 0) {
  800d63:	83 c4 10             	add    $0x10,%esp
  800d66:	85 c0                	test   %eax,%eax
  800d68:	78 2c                	js     800d96 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  800d6a:	e8 bb f3 ff ff       	call   80012a <sys_getenvid>
  800d6f:	83 ec 08             	sub    $0x8,%esp
  800d72:	68 17 03 80 00       	push   $0x800317
  800d77:	50                   	push   %eax
  800d78:	e8 f4 f4 ff ff       	call   800271 <sys_env_set_pgfault_upcall>
		if (r < 0) {
  800d7d:	83 c4 10             	add    $0x10,%esp
  800d80:	85 c0                	test   %eax,%eax
  800d82:	79 bd                	jns    800d41 <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  800d84:	50                   	push   %eax
  800d85:	68 e4 12 80 00       	push   $0x8012e4
  800d8a:	6a 28                	push   $0x28
  800d8c:	68 1a 13 80 00       	push   $0x80131a
  800d91:	e8 a7 f5 ff ff       	call   80033d <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  800d96:	50                   	push   %eax
  800d97:	68 a4 12 80 00       	push   $0x8012a4
  800d9c:	6a 23                	push   $0x23
  800d9e:	68 1a 13 80 00       	push   $0x80131a
  800da3:	e8 95 f5 ff ff       	call   80033d <_panic>
  800da8:	66 90                	xchg   %ax,%ax
  800daa:	66 90                	xchg   %ax,%ax
  800dac:	66 90                	xchg   %ax,%ax
  800dae:	66 90                	xchg   %ax,%ax

00800db0 <__udivdi3>:
  800db0:	f3 0f 1e fb          	endbr32 
  800db4:	55                   	push   %ebp
  800db5:	57                   	push   %edi
  800db6:	56                   	push   %esi
  800db7:	53                   	push   %ebx
  800db8:	83 ec 1c             	sub    $0x1c,%esp
  800dbb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800dbf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800dc3:	8b 74 24 34          	mov    0x34(%esp),%esi
  800dc7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	75 19                	jne    800de8 <__udivdi3+0x38>
  800dcf:	39 f3                	cmp    %esi,%ebx
  800dd1:	76 4d                	jbe    800e20 <__udivdi3+0x70>
  800dd3:	31 ff                	xor    %edi,%edi
  800dd5:	89 e8                	mov    %ebp,%eax
  800dd7:	89 f2                	mov    %esi,%edx
  800dd9:	f7 f3                	div    %ebx
  800ddb:	89 fa                	mov    %edi,%edx
  800ddd:	83 c4 1c             	add    $0x1c,%esp
  800de0:	5b                   	pop    %ebx
  800de1:	5e                   	pop    %esi
  800de2:	5f                   	pop    %edi
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    
  800de5:	8d 76 00             	lea    0x0(%esi),%esi
  800de8:	39 f0                	cmp    %esi,%eax
  800dea:	76 14                	jbe    800e00 <__udivdi3+0x50>
  800dec:	31 ff                	xor    %edi,%edi
  800dee:	31 c0                	xor    %eax,%eax
  800df0:	89 fa                	mov    %edi,%edx
  800df2:	83 c4 1c             	add    $0x1c,%esp
  800df5:	5b                   	pop    %ebx
  800df6:	5e                   	pop    %esi
  800df7:	5f                   	pop    %edi
  800df8:	5d                   	pop    %ebp
  800df9:	c3                   	ret    
  800dfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e00:	0f bd f8             	bsr    %eax,%edi
  800e03:	83 f7 1f             	xor    $0x1f,%edi
  800e06:	75 48                	jne    800e50 <__udivdi3+0xa0>
  800e08:	39 f0                	cmp    %esi,%eax
  800e0a:	72 06                	jb     800e12 <__udivdi3+0x62>
  800e0c:	31 c0                	xor    %eax,%eax
  800e0e:	39 eb                	cmp    %ebp,%ebx
  800e10:	77 de                	ja     800df0 <__udivdi3+0x40>
  800e12:	b8 01 00 00 00       	mov    $0x1,%eax
  800e17:	eb d7                	jmp    800df0 <__udivdi3+0x40>
  800e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e20:	89 d9                	mov    %ebx,%ecx
  800e22:	85 db                	test   %ebx,%ebx
  800e24:	75 0b                	jne    800e31 <__udivdi3+0x81>
  800e26:	b8 01 00 00 00       	mov    $0x1,%eax
  800e2b:	31 d2                	xor    %edx,%edx
  800e2d:	f7 f3                	div    %ebx
  800e2f:	89 c1                	mov    %eax,%ecx
  800e31:	31 d2                	xor    %edx,%edx
  800e33:	89 f0                	mov    %esi,%eax
  800e35:	f7 f1                	div    %ecx
  800e37:	89 c6                	mov    %eax,%esi
  800e39:	89 e8                	mov    %ebp,%eax
  800e3b:	89 f7                	mov    %esi,%edi
  800e3d:	f7 f1                	div    %ecx
  800e3f:	89 fa                	mov    %edi,%edx
  800e41:	83 c4 1c             	add    $0x1c,%esp
  800e44:	5b                   	pop    %ebx
  800e45:	5e                   	pop    %esi
  800e46:	5f                   	pop    %edi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    
  800e49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800e50:	89 f9                	mov    %edi,%ecx
  800e52:	ba 20 00 00 00       	mov    $0x20,%edx
  800e57:	29 fa                	sub    %edi,%edx
  800e59:	d3 e0                	shl    %cl,%eax
  800e5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e5f:	89 d1                	mov    %edx,%ecx
  800e61:	89 d8                	mov    %ebx,%eax
  800e63:	d3 e8                	shr    %cl,%eax
  800e65:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800e69:	09 c1                	or     %eax,%ecx
  800e6b:	89 f0                	mov    %esi,%eax
  800e6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e71:	89 f9                	mov    %edi,%ecx
  800e73:	d3 e3                	shl    %cl,%ebx
  800e75:	89 d1                	mov    %edx,%ecx
  800e77:	d3 e8                	shr    %cl,%eax
  800e79:	89 f9                	mov    %edi,%ecx
  800e7b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800e7f:	89 eb                	mov    %ebp,%ebx
  800e81:	d3 e6                	shl    %cl,%esi
  800e83:	89 d1                	mov    %edx,%ecx
  800e85:	d3 eb                	shr    %cl,%ebx
  800e87:	09 f3                	or     %esi,%ebx
  800e89:	89 c6                	mov    %eax,%esi
  800e8b:	89 f2                	mov    %esi,%edx
  800e8d:	89 d8                	mov    %ebx,%eax
  800e8f:	f7 74 24 08          	divl   0x8(%esp)
  800e93:	89 d6                	mov    %edx,%esi
  800e95:	89 c3                	mov    %eax,%ebx
  800e97:	f7 64 24 0c          	mull   0xc(%esp)
  800e9b:	39 d6                	cmp    %edx,%esi
  800e9d:	72 19                	jb     800eb8 <__udivdi3+0x108>
  800e9f:	89 f9                	mov    %edi,%ecx
  800ea1:	d3 e5                	shl    %cl,%ebp
  800ea3:	39 c5                	cmp    %eax,%ebp
  800ea5:	73 04                	jae    800eab <__udivdi3+0xfb>
  800ea7:	39 d6                	cmp    %edx,%esi
  800ea9:	74 0d                	je     800eb8 <__udivdi3+0x108>
  800eab:	89 d8                	mov    %ebx,%eax
  800ead:	31 ff                	xor    %edi,%edi
  800eaf:	e9 3c ff ff ff       	jmp    800df0 <__udivdi3+0x40>
  800eb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800eb8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ebb:	31 ff                	xor    %edi,%edi
  800ebd:	e9 2e ff ff ff       	jmp    800df0 <__udivdi3+0x40>
  800ec2:	66 90                	xchg   %ax,%ax
  800ec4:	66 90                	xchg   %ax,%ax
  800ec6:	66 90                	xchg   %ax,%ax
  800ec8:	66 90                	xchg   %ax,%ax
  800eca:	66 90                	xchg   %ax,%ax
  800ecc:	66 90                	xchg   %ax,%ax
  800ece:	66 90                	xchg   %ax,%ax

00800ed0 <__umoddi3>:
  800ed0:	f3 0f 1e fb          	endbr32 
  800ed4:	55                   	push   %ebp
  800ed5:	57                   	push   %edi
  800ed6:	56                   	push   %esi
  800ed7:	53                   	push   %ebx
  800ed8:	83 ec 1c             	sub    $0x1c,%esp
  800edb:	8b 74 24 30          	mov    0x30(%esp),%esi
  800edf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800ee3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800ee7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800eeb:	89 f0                	mov    %esi,%eax
  800eed:	89 da                	mov    %ebx,%edx
  800eef:	85 ff                	test   %edi,%edi
  800ef1:	75 15                	jne    800f08 <__umoddi3+0x38>
  800ef3:	39 dd                	cmp    %ebx,%ebp
  800ef5:	76 39                	jbe    800f30 <__umoddi3+0x60>
  800ef7:	f7 f5                	div    %ebp
  800ef9:	89 d0                	mov    %edx,%eax
  800efb:	31 d2                	xor    %edx,%edx
  800efd:	83 c4 1c             	add    $0x1c,%esp
  800f00:	5b                   	pop    %ebx
  800f01:	5e                   	pop    %esi
  800f02:	5f                   	pop    %edi
  800f03:	5d                   	pop    %ebp
  800f04:	c3                   	ret    
  800f05:	8d 76 00             	lea    0x0(%esi),%esi
  800f08:	39 df                	cmp    %ebx,%edi
  800f0a:	77 f1                	ja     800efd <__umoddi3+0x2d>
  800f0c:	0f bd cf             	bsr    %edi,%ecx
  800f0f:	83 f1 1f             	xor    $0x1f,%ecx
  800f12:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800f16:	75 40                	jne    800f58 <__umoddi3+0x88>
  800f18:	39 df                	cmp    %ebx,%edi
  800f1a:	72 04                	jb     800f20 <__umoddi3+0x50>
  800f1c:	39 f5                	cmp    %esi,%ebp
  800f1e:	77 dd                	ja     800efd <__umoddi3+0x2d>
  800f20:	89 da                	mov    %ebx,%edx
  800f22:	89 f0                	mov    %esi,%eax
  800f24:	29 e8                	sub    %ebp,%eax
  800f26:	19 fa                	sbb    %edi,%edx
  800f28:	eb d3                	jmp    800efd <__umoddi3+0x2d>
  800f2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800f30:	89 e9                	mov    %ebp,%ecx
  800f32:	85 ed                	test   %ebp,%ebp
  800f34:	75 0b                	jne    800f41 <__umoddi3+0x71>
  800f36:	b8 01 00 00 00       	mov    $0x1,%eax
  800f3b:	31 d2                	xor    %edx,%edx
  800f3d:	f7 f5                	div    %ebp
  800f3f:	89 c1                	mov    %eax,%ecx
  800f41:	89 d8                	mov    %ebx,%eax
  800f43:	31 d2                	xor    %edx,%edx
  800f45:	f7 f1                	div    %ecx
  800f47:	89 f0                	mov    %esi,%eax
  800f49:	f7 f1                	div    %ecx
  800f4b:	89 d0                	mov    %edx,%eax
  800f4d:	31 d2                	xor    %edx,%edx
  800f4f:	eb ac                	jmp    800efd <__umoddi3+0x2d>
  800f51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800f58:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f5c:	ba 20 00 00 00       	mov    $0x20,%edx
  800f61:	29 c2                	sub    %eax,%edx
  800f63:	89 c1                	mov    %eax,%ecx
  800f65:	89 e8                	mov    %ebp,%eax
  800f67:	d3 e7                	shl    %cl,%edi
  800f69:	89 d1                	mov    %edx,%ecx
  800f6b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800f6f:	d3 e8                	shr    %cl,%eax
  800f71:	89 c1                	mov    %eax,%ecx
  800f73:	8b 44 24 04          	mov    0x4(%esp),%eax
  800f77:	09 f9                	or     %edi,%ecx
  800f79:	89 df                	mov    %ebx,%edi
  800f7b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f7f:	89 c1                	mov    %eax,%ecx
  800f81:	d3 e5                	shl    %cl,%ebp
  800f83:	89 d1                	mov    %edx,%ecx
  800f85:	d3 ef                	shr    %cl,%edi
  800f87:	89 c1                	mov    %eax,%ecx
  800f89:	89 f0                	mov    %esi,%eax
  800f8b:	d3 e3                	shl    %cl,%ebx
  800f8d:	89 d1                	mov    %edx,%ecx
  800f8f:	89 fa                	mov    %edi,%edx
  800f91:	d3 e8                	shr    %cl,%eax
  800f93:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f98:	09 d8                	or     %ebx,%eax
  800f9a:	f7 74 24 08          	divl   0x8(%esp)
  800f9e:	89 d3                	mov    %edx,%ebx
  800fa0:	d3 e6                	shl    %cl,%esi
  800fa2:	f7 e5                	mul    %ebp
  800fa4:	89 c7                	mov    %eax,%edi
  800fa6:	89 d1                	mov    %edx,%ecx
  800fa8:	39 d3                	cmp    %edx,%ebx
  800faa:	72 06                	jb     800fb2 <__umoddi3+0xe2>
  800fac:	75 0e                	jne    800fbc <__umoddi3+0xec>
  800fae:	39 c6                	cmp    %eax,%esi
  800fb0:	73 0a                	jae    800fbc <__umoddi3+0xec>
  800fb2:	29 e8                	sub    %ebp,%eax
  800fb4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800fb8:	89 d1                	mov    %edx,%ecx
  800fba:	89 c7                	mov    %eax,%edi
  800fbc:	89 f5                	mov    %esi,%ebp
  800fbe:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fc2:	29 fd                	sub    %edi,%ebp
  800fc4:	19 cb                	sbb    %ecx,%ebx
  800fc6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800fcb:	89 d8                	mov    %ebx,%eax
  800fcd:	d3 e0                	shl    %cl,%eax
  800fcf:	89 f1                	mov    %esi,%ecx
  800fd1:	d3 ed                	shr    %cl,%ebp
  800fd3:	d3 eb                	shr    %cl,%ebx
  800fd5:	09 e8                	or     %ebp,%eax
  800fd7:	89 da                	mov    %ebx,%edx
  800fd9:	83 c4 1c             	add    $0x1c,%esp
  800fdc:	5b                   	pop    %ebx
  800fdd:	5e                   	pop    %esi
  800fde:	5f                   	pop    %edi
  800fdf:	5d                   	pop    %ebp
  800fe0:	c3                   	ret    
