
obj/user/faultbadhandler：     文件格式 elf32-i386


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
  80002c:	e8 34 00 00 00       	call   800065 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	6a 07                	push   $0x7
  80003b:	68 00 f0 bf ee       	push   $0xeebff000
  800040:	6a 00                	push   $0x0
  800042:	e8 32 01 00 00       	call   800179 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 ef be ad de       	push   $0xdeadbeef
  80004f:	6a 00                	push   $0x0
  800051:	e8 2c 02 00 00       	call   800282 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800056:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80005d:	00 00 00 
}
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	c9                   	leave  
  800064:	c3                   	ret    

00800065 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800065:	55                   	push   %ebp
  800066:	89 e5                	mov    %esp,%ebp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80006d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800070:	e8 c6 00 00 00       	call   80013b <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800092:	83 ec 08             	sub    $0x8,%esp
  800095:	56                   	push   %esi
  800096:	53                   	push   %ebx
  800097:	e8 97 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009c:	e8 0a 00 00 00       	call   8000ab <exit>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a7:	5b                   	pop    %ebx
  8000a8:	5e                   	pop    %esi
  8000a9:	5d                   	pop    %ebp
  8000aa:	c3                   	ret    

008000ab <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ab:	55                   	push   %ebp
  8000ac:	89 e5                	mov    %esp,%ebp
  8000ae:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  8000b1:	6a 00                	push   $0x0
  8000b3:	e8 42 00 00 00       	call   8000fa <sys_env_destroy>
}
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ce:	89 c3                	mov    %eax,%ebx
  8000d0:	89 c7                	mov    %eax,%edi
  8000d2:	89 c6                	mov    %eax,%esi
  8000d4:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_cgetc>:

int
sys_cgetc(void)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000eb:	89 d1                	mov    %edx,%ecx
  8000ed:	89 d3                	mov    %edx,%ebx
  8000ef:	89 d7                	mov    %edx,%edi
  8000f1:	89 d6                	mov    %edx,%esi
  8000f3:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000f5:	5b                   	pop    %ebx
  8000f6:	5e                   	pop    %esi
  8000f7:	5f                   	pop    %edi
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	57                   	push   %edi
  8000fe:	56                   	push   %esi
  8000ff:	53                   	push   %ebx
  800100:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800103:	b9 00 00 00 00       	mov    $0x0,%ecx
  800108:	8b 55 08             	mov    0x8(%ebp),%edx
  80010b:	b8 03 00 00 00       	mov    $0x3,%eax
  800110:	89 cb                	mov    %ecx,%ebx
  800112:	89 cf                	mov    %ecx,%edi
  800114:	89 ce                	mov    %ecx,%esi
  800116:	cd 30                	int    $0x30
	if(check && ret > 0)
  800118:	85 c0                	test   %eax,%eax
  80011a:	7f 08                	jg     800124 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011f:	5b                   	pop    %ebx
  800120:	5e                   	pop    %esi
  800121:	5f                   	pop    %edi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	6a 03                	push   $0x3
  80012a:	68 6a 0f 80 00       	push   $0x800f6a
  80012f:	6a 2a                	push   $0x2a
  800131:	68 87 0f 80 00       	push   $0x800f87
  800136:	e8 ed 01 00 00       	call   800328 <_panic>

0080013b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 02 00 00 00       	mov    $0x2,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_yield>:

void
sys_yield(void)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800160:	ba 00 00 00 00       	mov    $0x0,%edx
  800165:	b8 0a 00 00 00       	mov    $0xa,%eax
  80016a:	89 d1                	mov    %edx,%ecx
  80016c:	89 d3                	mov    %edx,%ebx
  80016e:	89 d7                	mov    %edx,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800174:	5b                   	pop    %ebx
  800175:	5e                   	pop    %esi
  800176:	5f                   	pop    %edi
  800177:	5d                   	pop    %ebp
  800178:	c3                   	ret    

00800179 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800179:	55                   	push   %ebp
  80017a:	89 e5                	mov    %esp,%ebp
  80017c:	57                   	push   %edi
  80017d:	56                   	push   %esi
  80017e:	53                   	push   %ebx
  80017f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800182:	be 00 00 00 00       	mov    $0x0,%esi
  800187:	8b 55 08             	mov    0x8(%ebp),%edx
  80018a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018d:	b8 04 00 00 00       	mov    $0x4,%eax
  800192:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800195:	89 f7                	mov    %esi,%edi
  800197:	cd 30                	int    $0x30
	if(check && ret > 0)
  800199:	85 c0                	test   %eax,%eax
  80019b:	7f 08                	jg     8001a5 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a0:	5b                   	pop    %ebx
  8001a1:	5e                   	pop    %esi
  8001a2:	5f                   	pop    %edi
  8001a3:	5d                   	pop    %ebp
  8001a4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	83 ec 0c             	sub    $0xc,%esp
  8001a8:	50                   	push   %eax
  8001a9:	6a 04                	push   $0x4
  8001ab:	68 6a 0f 80 00       	push   $0x800f6a
  8001b0:	6a 2a                	push   $0x2a
  8001b2:	68 87 0f 80 00       	push   $0x800f87
  8001b7:	e8 6c 01 00 00       	call   800328 <_panic>

008001bc <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001c5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001cb:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001d3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001db:	85 c0                	test   %eax,%eax
  8001dd:	7f 08                	jg     8001e7 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5f                   	pop    %edi
  8001e5:	5d                   	pop    %ebp
  8001e6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	50                   	push   %eax
  8001eb:	6a 05                	push   $0x5
  8001ed:	68 6a 0f 80 00       	push   $0x800f6a
  8001f2:	6a 2a                	push   $0x2a
  8001f4:	68 87 0f 80 00       	push   $0x800f87
  8001f9:	e8 2a 01 00 00       	call   800328 <_panic>

008001fe <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	57                   	push   %edi
  800202:	56                   	push   %esi
  800203:	53                   	push   %ebx
  800204:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800207:	bb 00 00 00 00       	mov    $0x0,%ebx
  80020c:	8b 55 08             	mov    0x8(%ebp),%edx
  80020f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800212:	b8 06 00 00 00       	mov    $0x6,%eax
  800217:	89 df                	mov    %ebx,%edi
  800219:	89 de                	mov    %ebx,%esi
  80021b:	cd 30                	int    $0x30
	if(check && ret > 0)
  80021d:	85 c0                	test   %eax,%eax
  80021f:	7f 08                	jg     800229 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5f                   	pop    %edi
  800227:	5d                   	pop    %ebp
  800228:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800229:	83 ec 0c             	sub    $0xc,%esp
  80022c:	50                   	push   %eax
  80022d:	6a 06                	push   $0x6
  80022f:	68 6a 0f 80 00       	push   $0x800f6a
  800234:	6a 2a                	push   $0x2a
  800236:	68 87 0f 80 00       	push   $0x800f87
  80023b:	e8 e8 00 00 00       	call   800328 <_panic>

00800240 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	57                   	push   %edi
  800244:	56                   	push   %esi
  800245:	53                   	push   %ebx
  800246:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800249:	bb 00 00 00 00       	mov    $0x0,%ebx
  80024e:	8b 55 08             	mov    0x8(%ebp),%edx
  800251:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800254:	b8 08 00 00 00       	mov    $0x8,%eax
  800259:	89 df                	mov    %ebx,%edi
  80025b:	89 de                	mov    %ebx,%esi
  80025d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80025f:	85 c0                	test   %eax,%eax
  800261:	7f 08                	jg     80026b <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80026b:	83 ec 0c             	sub    $0xc,%esp
  80026e:	50                   	push   %eax
  80026f:	6a 08                	push   $0x8
  800271:	68 6a 0f 80 00       	push   $0x800f6a
  800276:	6a 2a                	push   $0x2a
  800278:	68 87 0f 80 00       	push   $0x800f87
  80027d:	e8 a6 00 00 00       	call   800328 <_panic>

00800282 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	57                   	push   %edi
  800286:	56                   	push   %esi
  800287:	53                   	push   %ebx
  800288:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80028b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800290:	8b 55 08             	mov    0x8(%ebp),%edx
  800293:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800296:	b8 09 00 00 00       	mov    $0x9,%eax
  80029b:	89 df                	mov    %ebx,%edi
  80029d:	89 de                	mov    %ebx,%esi
  80029f:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002a1:	85 c0                	test   %eax,%eax
  8002a3:	7f 08                	jg     8002ad <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a8:	5b                   	pop    %ebx
  8002a9:	5e                   	pop    %esi
  8002aa:	5f                   	pop    %edi
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	50                   	push   %eax
  8002b1:	6a 09                	push   $0x9
  8002b3:	68 6a 0f 80 00       	push   $0x800f6a
  8002b8:	6a 2a                	push   $0x2a
  8002ba:	68 87 0f 80 00       	push   $0x800f87
  8002bf:	e8 64 00 00 00       	call   800328 <_panic>

008002c4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	57                   	push   %edi
  8002c8:	56                   	push   %esi
  8002c9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002d5:	be 00 00 00 00       	mov    $0x0,%esi
  8002da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002dd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002e0:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
  8002ed:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f8:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fd:	89 cb                	mov    %ecx,%ebx
  8002ff:	89 cf                	mov    %ecx,%edi
  800301:	89 ce                	mov    %ecx,%esi
  800303:	cd 30                	int    $0x30
	if(check && ret > 0)
  800305:	85 c0                	test   %eax,%eax
  800307:	7f 08                	jg     800311 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800309:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030c:	5b                   	pop    %ebx
  80030d:	5e                   	pop    %esi
  80030e:	5f                   	pop    %edi
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800311:	83 ec 0c             	sub    $0xc,%esp
  800314:	50                   	push   %eax
  800315:	6a 0c                	push   $0xc
  800317:	68 6a 0f 80 00       	push   $0x800f6a
  80031c:	6a 2a                	push   $0x2a
  80031e:	68 87 0f 80 00       	push   $0x800f87
  800323:	e8 00 00 00 00       	call   800328 <_panic>

00800328 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	56                   	push   %esi
  80032c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80032d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800330:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800336:	e8 00 fe ff ff       	call   80013b <sys_getenvid>
  80033b:	83 ec 0c             	sub    $0xc,%esp
  80033e:	ff 75 0c             	push   0xc(%ebp)
  800341:	ff 75 08             	push   0x8(%ebp)
  800344:	56                   	push   %esi
  800345:	50                   	push   %eax
  800346:	68 98 0f 80 00       	push   $0x800f98
  80034b:	e8 b3 00 00 00       	call   800403 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800350:	83 c4 18             	add    $0x18,%esp
  800353:	53                   	push   %ebx
  800354:	ff 75 10             	push   0x10(%ebp)
  800357:	e8 56 00 00 00       	call   8003b2 <vcprintf>
	cprintf("\n");
  80035c:	c7 04 24 bb 0f 80 00 	movl   $0x800fbb,(%esp)
  800363:	e8 9b 00 00 00       	call   800403 <cprintf>
  800368:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80036b:	cc                   	int3   
  80036c:	eb fd                	jmp    80036b <_panic+0x43>

0080036e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	53                   	push   %ebx
  800372:	83 ec 04             	sub    $0x4,%esp
  800375:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800378:	8b 13                	mov    (%ebx),%edx
  80037a:	8d 42 01             	lea    0x1(%edx),%eax
  80037d:	89 03                	mov    %eax,(%ebx)
  80037f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800382:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800386:	3d ff 00 00 00       	cmp    $0xff,%eax
  80038b:	74 09                	je     800396 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80038d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800391:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800394:	c9                   	leave  
  800395:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800396:	83 ec 08             	sub    $0x8,%esp
  800399:	68 ff 00 00 00       	push   $0xff
  80039e:	8d 43 08             	lea    0x8(%ebx),%eax
  8003a1:	50                   	push   %eax
  8003a2:	e8 16 fd ff ff       	call   8000bd <sys_cputs>
		b->idx = 0;
  8003a7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003ad:	83 c4 10             	add    $0x10,%esp
  8003b0:	eb db                	jmp    80038d <putch+0x1f>

008003b2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003bb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003c2:	00 00 00 
	b.cnt = 0;
  8003c5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003cc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003cf:	ff 75 0c             	push   0xc(%ebp)
  8003d2:	ff 75 08             	push   0x8(%ebp)
  8003d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003db:	50                   	push   %eax
  8003dc:	68 6e 03 80 00       	push   $0x80036e
  8003e1:	e8 14 01 00 00       	call   8004fa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003e6:	83 c4 08             	add    $0x8,%esp
  8003e9:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8003ef:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003f5:	50                   	push   %eax
  8003f6:	e8 c2 fc ff ff       	call   8000bd <sys_cputs>

	return b.cnt;
}
  8003fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800401:	c9                   	leave  
  800402:	c3                   	ret    

00800403 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800409:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80040c:	50                   	push   %eax
  80040d:	ff 75 08             	push   0x8(%ebp)
  800410:	e8 9d ff ff ff       	call   8003b2 <vcprintf>
	va_end(ap);

	return cnt;
}
  800415:	c9                   	leave  
  800416:	c3                   	ret    

00800417 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	57                   	push   %edi
  80041b:	56                   	push   %esi
  80041c:	53                   	push   %ebx
  80041d:	83 ec 1c             	sub    $0x1c,%esp
  800420:	89 c7                	mov    %eax,%edi
  800422:	89 d6                	mov    %edx,%esi
  800424:	8b 45 08             	mov    0x8(%ebp),%eax
  800427:	8b 55 0c             	mov    0xc(%ebp),%edx
  80042a:	89 d1                	mov    %edx,%ecx
  80042c:	89 c2                	mov    %eax,%edx
  80042e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800431:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800434:	8b 45 10             	mov    0x10(%ebp),%eax
  800437:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80043a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80043d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800444:	39 c2                	cmp    %eax,%edx
  800446:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800449:	72 3e                	jb     800489 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80044b:	83 ec 0c             	sub    $0xc,%esp
  80044e:	ff 75 18             	push   0x18(%ebp)
  800451:	83 eb 01             	sub    $0x1,%ebx
  800454:	53                   	push   %ebx
  800455:	50                   	push   %eax
  800456:	83 ec 08             	sub    $0x8,%esp
  800459:	ff 75 e4             	push   -0x1c(%ebp)
  80045c:	ff 75 e0             	push   -0x20(%ebp)
  80045f:	ff 75 dc             	push   -0x24(%ebp)
  800462:	ff 75 d8             	push   -0x28(%ebp)
  800465:	e8 b6 08 00 00       	call   800d20 <__udivdi3>
  80046a:	83 c4 18             	add    $0x18,%esp
  80046d:	52                   	push   %edx
  80046e:	50                   	push   %eax
  80046f:	89 f2                	mov    %esi,%edx
  800471:	89 f8                	mov    %edi,%eax
  800473:	e8 9f ff ff ff       	call   800417 <printnum>
  800478:	83 c4 20             	add    $0x20,%esp
  80047b:	eb 13                	jmp    800490 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	56                   	push   %esi
  800481:	ff 75 18             	push   0x18(%ebp)
  800484:	ff d7                	call   *%edi
  800486:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800489:	83 eb 01             	sub    $0x1,%ebx
  80048c:	85 db                	test   %ebx,%ebx
  80048e:	7f ed                	jg     80047d <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	56                   	push   %esi
  800494:	83 ec 04             	sub    $0x4,%esp
  800497:	ff 75 e4             	push   -0x1c(%ebp)
  80049a:	ff 75 e0             	push   -0x20(%ebp)
  80049d:	ff 75 dc             	push   -0x24(%ebp)
  8004a0:	ff 75 d8             	push   -0x28(%ebp)
  8004a3:	e8 98 09 00 00       	call   800e40 <__umoddi3>
  8004a8:	83 c4 14             	add    $0x14,%esp
  8004ab:	0f be 80 bd 0f 80 00 	movsbl 0x800fbd(%eax),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff d7                	call   *%edi
}
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004bb:	5b                   	pop    %ebx
  8004bc:	5e                   	pop    %esi
  8004bd:	5f                   	pop    %edi
  8004be:	5d                   	pop    %ebp
  8004bf:	c3                   	ret    

008004c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004c6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ca:	8b 10                	mov    (%eax),%edx
  8004cc:	3b 50 04             	cmp    0x4(%eax),%edx
  8004cf:	73 0a                	jae    8004db <sprintputch+0x1b>
		*b->buf++ = ch;
  8004d1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004d4:	89 08                	mov    %ecx,(%eax)
  8004d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d9:	88 02                	mov    %al,(%edx)
}
  8004db:	5d                   	pop    %ebp
  8004dc:	c3                   	ret    

008004dd <printfmt>:
{
  8004dd:	55                   	push   %ebp
  8004de:	89 e5                	mov    %esp,%ebp
  8004e0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004e3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004e6:	50                   	push   %eax
  8004e7:	ff 75 10             	push   0x10(%ebp)
  8004ea:	ff 75 0c             	push   0xc(%ebp)
  8004ed:	ff 75 08             	push   0x8(%ebp)
  8004f0:	e8 05 00 00 00       	call   8004fa <vprintfmt>
}
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	c9                   	leave  
  8004f9:	c3                   	ret    

008004fa <vprintfmt>:
{
  8004fa:	55                   	push   %ebp
  8004fb:	89 e5                	mov    %esp,%ebp
  8004fd:	57                   	push   %edi
  8004fe:	56                   	push   %esi
  8004ff:	53                   	push   %ebx
  800500:	83 ec 3c             	sub    $0x3c,%esp
  800503:	8b 75 08             	mov    0x8(%ebp),%esi
  800506:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800509:	8b 7d 10             	mov    0x10(%ebp),%edi
  80050c:	eb 0a                	jmp    800518 <vprintfmt+0x1e>
			putch(ch, putdat);
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	53                   	push   %ebx
  800512:	50                   	push   %eax
  800513:	ff d6                	call   *%esi
  800515:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800518:	83 c7 01             	add    $0x1,%edi
  80051b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80051f:	83 f8 25             	cmp    $0x25,%eax
  800522:	74 0c                	je     800530 <vprintfmt+0x36>
			if (ch == '\0')
  800524:	85 c0                	test   %eax,%eax
  800526:	75 e6                	jne    80050e <vprintfmt+0x14>
}
  800528:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80052b:	5b                   	pop    %ebx
  80052c:	5e                   	pop    %esi
  80052d:	5f                   	pop    %edi
  80052e:	5d                   	pop    %ebp
  80052f:	c3                   	ret    
		padc = ' ';
  800530:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800534:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80053b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800542:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800549:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	8d 47 01             	lea    0x1(%edi),%eax
  800551:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800554:	0f b6 17             	movzbl (%edi),%edx
  800557:	8d 42 dd             	lea    -0x23(%edx),%eax
  80055a:	3c 55                	cmp    $0x55,%al
  80055c:	0f 87 bb 03 00 00    	ja     80091d <vprintfmt+0x423>
  800562:	0f b6 c0             	movzbl %al,%eax
  800565:	ff 24 85 80 10 80 00 	jmp    *0x801080(,%eax,4)
  80056c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80056f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800573:	eb d9                	jmp    80054e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800575:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800578:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80057c:	eb d0                	jmp    80054e <vprintfmt+0x54>
  80057e:	0f b6 d2             	movzbl %dl,%edx
  800581:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800584:	b8 00 00 00 00       	mov    $0x0,%eax
  800589:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80058c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80058f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800593:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800596:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800599:	83 f9 09             	cmp    $0x9,%ecx
  80059c:	77 55                	ja     8005f3 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80059e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005a1:	eb e9                	jmp    80058c <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8005a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a6:	8b 00                	mov    (%eax),%eax
  8005a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ae:	8d 40 04             	lea    0x4(%eax),%eax
  8005b1:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005b7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005bb:	79 91                	jns    80054e <vprintfmt+0x54>
				width = precision, precision = -1;
  8005bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005c3:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005ca:	eb 82                	jmp    80054e <vprintfmt+0x54>
  8005cc:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005cf:	85 d2                	test   %edx,%edx
  8005d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005d6:	0f 49 c2             	cmovns %edx,%eax
  8005d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005df:	e9 6a ff ff ff       	jmp    80054e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005e7:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005ee:	e9 5b ff ff ff       	jmp    80054e <vprintfmt+0x54>
  8005f3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f9:	eb bc                	jmp    8005b7 <vprintfmt+0xbd>
			lflag++;
  8005fb:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800601:	e9 48 ff ff ff       	jmp    80054e <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  800606:	8b 45 14             	mov    0x14(%ebp),%eax
  800609:	8d 78 04             	lea    0x4(%eax),%edi
  80060c:	83 ec 08             	sub    $0x8,%esp
  80060f:	53                   	push   %ebx
  800610:	ff 30                	push   (%eax)
  800612:	ff d6                	call   *%esi
			break;
  800614:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  800617:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80061a:	e9 9d 02 00 00       	jmp    8008bc <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80061f:	8b 45 14             	mov    0x14(%ebp),%eax
  800622:	8d 78 04             	lea    0x4(%eax),%edi
  800625:	8b 10                	mov    (%eax),%edx
  800627:	89 d0                	mov    %edx,%eax
  800629:	f7 d8                	neg    %eax
  80062b:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80062e:	83 f8 08             	cmp    $0x8,%eax
  800631:	7f 23                	jg     800656 <vprintfmt+0x15c>
  800633:	8b 14 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%edx
  80063a:	85 d2                	test   %edx,%edx
  80063c:	74 18                	je     800656 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80063e:	52                   	push   %edx
  80063f:	68 de 0f 80 00       	push   $0x800fde
  800644:	53                   	push   %ebx
  800645:	56                   	push   %esi
  800646:	e8 92 fe ff ff       	call   8004dd <printfmt>
  80064b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80064e:	89 7d 14             	mov    %edi,0x14(%ebp)
  800651:	e9 66 02 00 00       	jmp    8008bc <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800656:	50                   	push   %eax
  800657:	68 d5 0f 80 00       	push   $0x800fd5
  80065c:	53                   	push   %ebx
  80065d:	56                   	push   %esi
  80065e:	e8 7a fe ff ff       	call   8004dd <printfmt>
  800663:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800666:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800669:	e9 4e 02 00 00       	jmp    8008bc <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80066e:	8b 45 14             	mov    0x14(%ebp),%eax
  800671:	83 c0 04             	add    $0x4,%eax
  800674:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800677:	8b 45 14             	mov    0x14(%ebp),%eax
  80067a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80067c:	85 d2                	test   %edx,%edx
  80067e:	b8 ce 0f 80 00       	mov    $0x800fce,%eax
  800683:	0f 45 c2             	cmovne %edx,%eax
  800686:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800689:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80068d:	7e 06                	jle    800695 <vprintfmt+0x19b>
  80068f:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800693:	75 0d                	jne    8006a2 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800695:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800698:	89 c7                	mov    %eax,%edi
  80069a:	03 45 e0             	add    -0x20(%ebp),%eax
  80069d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006a0:	eb 55                	jmp    8006f7 <vprintfmt+0x1fd>
  8006a2:	83 ec 08             	sub    $0x8,%esp
  8006a5:	ff 75 d8             	push   -0x28(%ebp)
  8006a8:	ff 75 cc             	push   -0x34(%ebp)
  8006ab:	e8 0a 03 00 00       	call   8009ba <strnlen>
  8006b0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006b3:	29 c1                	sub    %eax,%ecx
  8006b5:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8006bd:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006c4:	eb 0f                	jmp    8006d5 <vprintfmt+0x1db>
					putch(padc, putdat);
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	53                   	push   %ebx
  8006ca:	ff 75 e0             	push   -0x20(%ebp)
  8006cd:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cf:	83 ef 01             	sub    $0x1,%edi
  8006d2:	83 c4 10             	add    $0x10,%esp
  8006d5:	85 ff                	test   %edi,%edi
  8006d7:	7f ed                	jg     8006c6 <vprintfmt+0x1cc>
  8006d9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006dc:	85 d2                	test   %edx,%edx
  8006de:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e3:	0f 49 c2             	cmovns %edx,%eax
  8006e6:	29 c2                	sub    %eax,%edx
  8006e8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006eb:	eb a8                	jmp    800695 <vprintfmt+0x19b>
					putch(ch, putdat);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	53                   	push   %ebx
  8006f1:	52                   	push   %edx
  8006f2:	ff d6                	call   *%esi
  8006f4:	83 c4 10             	add    $0x10,%esp
  8006f7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006fa:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006fc:	83 c7 01             	add    $0x1,%edi
  8006ff:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800703:	0f be d0             	movsbl %al,%edx
  800706:	85 d2                	test   %edx,%edx
  800708:	74 4b                	je     800755 <vprintfmt+0x25b>
  80070a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80070e:	78 06                	js     800716 <vprintfmt+0x21c>
  800710:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800714:	78 1e                	js     800734 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  800716:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80071a:	74 d1                	je     8006ed <vprintfmt+0x1f3>
  80071c:	0f be c0             	movsbl %al,%eax
  80071f:	83 e8 20             	sub    $0x20,%eax
  800722:	83 f8 5e             	cmp    $0x5e,%eax
  800725:	76 c6                	jbe    8006ed <vprintfmt+0x1f3>
					putch('?', putdat);
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	53                   	push   %ebx
  80072b:	6a 3f                	push   $0x3f
  80072d:	ff d6                	call   *%esi
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	eb c3                	jmp    8006f7 <vprintfmt+0x1fd>
  800734:	89 cf                	mov    %ecx,%edi
  800736:	eb 0e                	jmp    800746 <vprintfmt+0x24c>
				putch(' ', putdat);
  800738:	83 ec 08             	sub    $0x8,%esp
  80073b:	53                   	push   %ebx
  80073c:	6a 20                	push   $0x20
  80073e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800740:	83 ef 01             	sub    $0x1,%edi
  800743:	83 c4 10             	add    $0x10,%esp
  800746:	85 ff                	test   %edi,%edi
  800748:	7f ee                	jg     800738 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80074a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80074d:	89 45 14             	mov    %eax,0x14(%ebp)
  800750:	e9 67 01 00 00       	jmp    8008bc <vprintfmt+0x3c2>
  800755:	89 cf                	mov    %ecx,%edi
  800757:	eb ed                	jmp    800746 <vprintfmt+0x24c>
	if (lflag >= 2)
  800759:	83 f9 01             	cmp    $0x1,%ecx
  80075c:	7f 1b                	jg     800779 <vprintfmt+0x27f>
	else if (lflag)
  80075e:	85 c9                	test   %ecx,%ecx
  800760:	74 63                	je     8007c5 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800762:	8b 45 14             	mov    0x14(%ebp),%eax
  800765:	8b 00                	mov    (%eax),%eax
  800767:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80076a:	99                   	cltd   
  80076b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80076e:	8b 45 14             	mov    0x14(%ebp),%eax
  800771:	8d 40 04             	lea    0x4(%eax),%eax
  800774:	89 45 14             	mov    %eax,0x14(%ebp)
  800777:	eb 17                	jmp    800790 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800779:	8b 45 14             	mov    0x14(%ebp),%eax
  80077c:	8b 50 04             	mov    0x4(%eax),%edx
  80077f:	8b 00                	mov    (%eax),%eax
  800781:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800784:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800787:	8b 45 14             	mov    0x14(%ebp),%eax
  80078a:	8d 40 08             	lea    0x8(%eax),%eax
  80078d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800790:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800793:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800796:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80079b:	85 c9                	test   %ecx,%ecx
  80079d:	0f 89 ff 00 00 00    	jns    8008a2 <vprintfmt+0x3a8>
				putch('-', putdat);
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	53                   	push   %ebx
  8007a7:	6a 2d                	push   $0x2d
  8007a9:	ff d6                	call   *%esi
				num = -(long long) num;
  8007ab:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007ae:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007b1:	f7 da                	neg    %edx
  8007b3:	83 d1 00             	adc    $0x0,%ecx
  8007b6:	f7 d9                	neg    %ecx
  8007b8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007bb:	bf 0a 00 00 00       	mov    $0xa,%edi
  8007c0:	e9 dd 00 00 00       	jmp    8008a2 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8007c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c8:	8b 00                	mov    (%eax),%eax
  8007ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007cd:	99                   	cltd   
  8007ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d4:	8d 40 04             	lea    0x4(%eax),%eax
  8007d7:	89 45 14             	mov    %eax,0x14(%ebp)
  8007da:	eb b4                	jmp    800790 <vprintfmt+0x296>
	if (lflag >= 2)
  8007dc:	83 f9 01             	cmp    $0x1,%ecx
  8007df:	7f 1e                	jg     8007ff <vprintfmt+0x305>
	else if (lflag)
  8007e1:	85 c9                	test   %ecx,%ecx
  8007e3:	74 32                	je     800817 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8007e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e8:	8b 10                	mov    (%eax),%edx
  8007ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007ef:	8d 40 04             	lea    0x4(%eax),%eax
  8007f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007f5:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8007fa:	e9 a3 00 00 00       	jmp    8008a2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800802:	8b 10                	mov    (%eax),%edx
  800804:	8b 48 04             	mov    0x4(%eax),%ecx
  800807:	8d 40 08             	lea    0x8(%eax),%eax
  80080a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80080d:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  800812:	e9 8b 00 00 00       	jmp    8008a2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800817:	8b 45 14             	mov    0x14(%ebp),%eax
  80081a:	8b 10                	mov    (%eax),%edx
  80081c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800821:	8d 40 04             	lea    0x4(%eax),%eax
  800824:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800827:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80082c:	eb 74                	jmp    8008a2 <vprintfmt+0x3a8>
	if (lflag >= 2)
  80082e:	83 f9 01             	cmp    $0x1,%ecx
  800831:	7f 1b                	jg     80084e <vprintfmt+0x354>
	else if (lflag)
  800833:	85 c9                	test   %ecx,%ecx
  800835:	74 2c                	je     800863 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800837:	8b 45 14             	mov    0x14(%ebp),%eax
  80083a:	8b 10                	mov    (%eax),%edx
  80083c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800841:	8d 40 04             	lea    0x4(%eax),%eax
  800844:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800847:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80084c:	eb 54                	jmp    8008a2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80084e:	8b 45 14             	mov    0x14(%ebp),%eax
  800851:	8b 10                	mov    (%eax),%edx
  800853:	8b 48 04             	mov    0x4(%eax),%ecx
  800856:	8d 40 08             	lea    0x8(%eax),%eax
  800859:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80085c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800861:	eb 3f                	jmp    8008a2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800863:	8b 45 14             	mov    0x14(%ebp),%eax
  800866:	8b 10                	mov    (%eax),%edx
  800868:	b9 00 00 00 00       	mov    $0x0,%ecx
  80086d:	8d 40 04             	lea    0x4(%eax),%eax
  800870:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800873:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800878:	eb 28                	jmp    8008a2 <vprintfmt+0x3a8>
			putch('0', putdat);
  80087a:	83 ec 08             	sub    $0x8,%esp
  80087d:	53                   	push   %ebx
  80087e:	6a 30                	push   $0x30
  800880:	ff d6                	call   *%esi
			putch('x', putdat);
  800882:	83 c4 08             	add    $0x8,%esp
  800885:	53                   	push   %ebx
  800886:	6a 78                	push   $0x78
  800888:	ff d6                	call   *%esi
			num = (unsigned long long)
  80088a:	8b 45 14             	mov    0x14(%ebp),%eax
  80088d:	8b 10                	mov    (%eax),%edx
  80088f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800894:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800897:	8d 40 04             	lea    0x4(%eax),%eax
  80089a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80089d:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8008a2:	83 ec 0c             	sub    $0xc,%esp
  8008a5:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8008a9:	50                   	push   %eax
  8008aa:	ff 75 e0             	push   -0x20(%ebp)
  8008ad:	57                   	push   %edi
  8008ae:	51                   	push   %ecx
  8008af:	52                   	push   %edx
  8008b0:	89 da                	mov    %ebx,%edx
  8008b2:	89 f0                	mov    %esi,%eax
  8008b4:	e8 5e fb ff ff       	call   800417 <printnum>
			break;
  8008b9:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008bf:	e9 54 fc ff ff       	jmp    800518 <vprintfmt+0x1e>
	if (lflag >= 2)
  8008c4:	83 f9 01             	cmp    $0x1,%ecx
  8008c7:	7f 1b                	jg     8008e4 <vprintfmt+0x3ea>
	else if (lflag)
  8008c9:	85 c9                	test   %ecx,%ecx
  8008cb:	74 2c                	je     8008f9 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8008cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d0:	8b 10                	mov    (%eax),%edx
  8008d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008d7:	8d 40 04             	lea    0x4(%eax),%eax
  8008da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008dd:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8008e2:	eb be                	jmp    8008a2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8008e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e7:	8b 10                	mov    (%eax),%edx
  8008e9:	8b 48 04             	mov    0x4(%eax),%ecx
  8008ec:	8d 40 08             	lea    0x8(%eax),%eax
  8008ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008f2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8008f7:	eb a9                	jmp    8008a2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8008f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008fc:	8b 10                	mov    (%eax),%edx
  8008fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800903:	8d 40 04             	lea    0x4(%eax),%eax
  800906:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800909:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80090e:	eb 92                	jmp    8008a2 <vprintfmt+0x3a8>
			putch(ch, putdat);
  800910:	83 ec 08             	sub    $0x8,%esp
  800913:	53                   	push   %ebx
  800914:	6a 25                	push   $0x25
  800916:	ff d6                	call   *%esi
			break;
  800918:	83 c4 10             	add    $0x10,%esp
  80091b:	eb 9f                	jmp    8008bc <vprintfmt+0x3c2>
			putch('%', putdat);
  80091d:	83 ec 08             	sub    $0x8,%esp
  800920:	53                   	push   %ebx
  800921:	6a 25                	push   $0x25
  800923:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800925:	83 c4 10             	add    $0x10,%esp
  800928:	89 f8                	mov    %edi,%eax
  80092a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80092e:	74 05                	je     800935 <vprintfmt+0x43b>
  800930:	83 e8 01             	sub    $0x1,%eax
  800933:	eb f5                	jmp    80092a <vprintfmt+0x430>
  800935:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800938:	eb 82                	jmp    8008bc <vprintfmt+0x3c2>

0080093a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	83 ec 18             	sub    $0x18,%esp
  800940:	8b 45 08             	mov    0x8(%ebp),%eax
  800943:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800946:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800949:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80094d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800950:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800957:	85 c0                	test   %eax,%eax
  800959:	74 26                	je     800981 <vsnprintf+0x47>
  80095b:	85 d2                	test   %edx,%edx
  80095d:	7e 22                	jle    800981 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80095f:	ff 75 14             	push   0x14(%ebp)
  800962:	ff 75 10             	push   0x10(%ebp)
  800965:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800968:	50                   	push   %eax
  800969:	68 c0 04 80 00       	push   $0x8004c0
  80096e:	e8 87 fb ff ff       	call   8004fa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800973:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800976:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800979:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80097c:	83 c4 10             	add    $0x10,%esp
}
  80097f:	c9                   	leave  
  800980:	c3                   	ret    
		return -E_INVAL;
  800981:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800986:	eb f7                	jmp    80097f <vsnprintf+0x45>

00800988 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80098e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800991:	50                   	push   %eax
  800992:	ff 75 10             	push   0x10(%ebp)
  800995:	ff 75 0c             	push   0xc(%ebp)
  800998:	ff 75 08             	push   0x8(%ebp)
  80099b:	e8 9a ff ff ff       	call   80093a <vsnprintf>
	va_end(ap);

	return rc;
}
  8009a0:	c9                   	leave  
  8009a1:	c3                   	ret    

008009a2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009a2:	55                   	push   %ebp
  8009a3:	89 e5                	mov    %esp,%ebp
  8009a5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ad:	eb 03                	jmp    8009b2 <strlen+0x10>
		n++;
  8009af:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8009b2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009b6:	75 f7                	jne    8009af <strlen+0xd>
	return n;
}
  8009b8:	5d                   	pop    %ebp
  8009b9:	c3                   	ret    

008009ba <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009ba:	55                   	push   %ebp
  8009bb:	89 e5                	mov    %esp,%ebp
  8009bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c8:	eb 03                	jmp    8009cd <strnlen+0x13>
		n++;
  8009ca:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009cd:	39 d0                	cmp    %edx,%eax
  8009cf:	74 08                	je     8009d9 <strnlen+0x1f>
  8009d1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009d5:	75 f3                	jne    8009ca <strnlen+0x10>
  8009d7:	89 c2                	mov    %eax,%edx
	return n;
}
  8009d9:	89 d0                	mov    %edx,%eax
  8009db:	5d                   	pop    %ebp
  8009dc:	c3                   	ret    

008009dd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	53                   	push   %ebx
  8009e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ec:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8009f0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8009f3:	83 c0 01             	add    $0x1,%eax
  8009f6:	84 d2                	test   %dl,%dl
  8009f8:	75 f2                	jne    8009ec <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009fa:	89 c8                	mov    %ecx,%eax
  8009fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ff:	c9                   	leave  
  800a00:	c3                   	ret    

00800a01 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a01:	55                   	push   %ebp
  800a02:	89 e5                	mov    %esp,%ebp
  800a04:	53                   	push   %ebx
  800a05:	83 ec 10             	sub    $0x10,%esp
  800a08:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a0b:	53                   	push   %ebx
  800a0c:	e8 91 ff ff ff       	call   8009a2 <strlen>
  800a11:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a14:	ff 75 0c             	push   0xc(%ebp)
  800a17:	01 d8                	add    %ebx,%eax
  800a19:	50                   	push   %eax
  800a1a:	e8 be ff ff ff       	call   8009dd <strcpy>
	return dst;
}
  800a1f:	89 d8                	mov    %ebx,%eax
  800a21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a24:	c9                   	leave  
  800a25:	c3                   	ret    

00800a26 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	56                   	push   %esi
  800a2a:	53                   	push   %ebx
  800a2b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a2e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a31:	89 f3                	mov    %esi,%ebx
  800a33:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a36:	89 f0                	mov    %esi,%eax
  800a38:	eb 0f                	jmp    800a49 <strncpy+0x23>
		*dst++ = *src;
  800a3a:	83 c0 01             	add    $0x1,%eax
  800a3d:	0f b6 0a             	movzbl (%edx),%ecx
  800a40:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a43:	80 f9 01             	cmp    $0x1,%cl
  800a46:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800a49:	39 d8                	cmp    %ebx,%eax
  800a4b:	75 ed                	jne    800a3a <strncpy+0x14>
	}
	return ret;
}
  800a4d:	89 f0                	mov    %esi,%eax
  800a4f:	5b                   	pop    %ebx
  800a50:	5e                   	pop    %esi
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	56                   	push   %esi
  800a57:	53                   	push   %ebx
  800a58:	8b 75 08             	mov    0x8(%ebp),%esi
  800a5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a5e:	8b 55 10             	mov    0x10(%ebp),%edx
  800a61:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a63:	85 d2                	test   %edx,%edx
  800a65:	74 21                	je     800a88 <strlcpy+0x35>
  800a67:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a6b:	89 f2                	mov    %esi,%edx
  800a6d:	eb 09                	jmp    800a78 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a6f:	83 c1 01             	add    $0x1,%ecx
  800a72:	83 c2 01             	add    $0x1,%edx
  800a75:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800a78:	39 c2                	cmp    %eax,%edx
  800a7a:	74 09                	je     800a85 <strlcpy+0x32>
  800a7c:	0f b6 19             	movzbl (%ecx),%ebx
  800a7f:	84 db                	test   %bl,%bl
  800a81:	75 ec                	jne    800a6f <strlcpy+0x1c>
  800a83:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a85:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a88:	29 f0                	sub    %esi,%eax
}
  800a8a:	5b                   	pop    %ebx
  800a8b:	5e                   	pop    %esi
  800a8c:	5d                   	pop    %ebp
  800a8d:	c3                   	ret    

00800a8e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a8e:	55                   	push   %ebp
  800a8f:	89 e5                	mov    %esp,%ebp
  800a91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a94:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a97:	eb 06                	jmp    800a9f <strcmp+0x11>
		p++, q++;
  800a99:	83 c1 01             	add    $0x1,%ecx
  800a9c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a9f:	0f b6 01             	movzbl (%ecx),%eax
  800aa2:	84 c0                	test   %al,%al
  800aa4:	74 04                	je     800aaa <strcmp+0x1c>
  800aa6:	3a 02                	cmp    (%edx),%al
  800aa8:	74 ef                	je     800a99 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800aaa:	0f b6 c0             	movzbl %al,%eax
  800aad:	0f b6 12             	movzbl (%edx),%edx
  800ab0:	29 d0                	sub    %edx,%eax
}
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	53                   	push   %ebx
  800ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  800abb:	8b 55 0c             	mov    0xc(%ebp),%edx
  800abe:	89 c3                	mov    %eax,%ebx
  800ac0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ac3:	eb 06                	jmp    800acb <strncmp+0x17>
		n--, p++, q++;
  800ac5:	83 c0 01             	add    $0x1,%eax
  800ac8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800acb:	39 d8                	cmp    %ebx,%eax
  800acd:	74 18                	je     800ae7 <strncmp+0x33>
  800acf:	0f b6 08             	movzbl (%eax),%ecx
  800ad2:	84 c9                	test   %cl,%cl
  800ad4:	74 04                	je     800ada <strncmp+0x26>
  800ad6:	3a 0a                	cmp    (%edx),%cl
  800ad8:	74 eb                	je     800ac5 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ada:	0f b6 00             	movzbl (%eax),%eax
  800add:	0f b6 12             	movzbl (%edx),%edx
  800ae0:	29 d0                	sub    %edx,%eax
}
  800ae2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ae5:	c9                   	leave  
  800ae6:	c3                   	ret    
		return 0;
  800ae7:	b8 00 00 00 00       	mov    $0x0,%eax
  800aec:	eb f4                	jmp    800ae2 <strncmp+0x2e>

00800aee <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	8b 45 08             	mov    0x8(%ebp),%eax
  800af4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af8:	eb 03                	jmp    800afd <strchr+0xf>
  800afa:	83 c0 01             	add    $0x1,%eax
  800afd:	0f b6 10             	movzbl (%eax),%edx
  800b00:	84 d2                	test   %dl,%dl
  800b02:	74 06                	je     800b0a <strchr+0x1c>
		if (*s == c)
  800b04:	38 ca                	cmp    %cl,%dl
  800b06:	75 f2                	jne    800afa <strchr+0xc>
  800b08:	eb 05                	jmp    800b0f <strchr+0x21>
			return (char *) s;
	return 0;
  800b0a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	8b 45 08             	mov    0x8(%ebp),%eax
  800b17:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b1b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b1e:	38 ca                	cmp    %cl,%dl
  800b20:	74 09                	je     800b2b <strfind+0x1a>
  800b22:	84 d2                	test   %dl,%dl
  800b24:	74 05                	je     800b2b <strfind+0x1a>
	for (; *s; s++)
  800b26:	83 c0 01             	add    $0x1,%eax
  800b29:	eb f0                	jmp    800b1b <strfind+0xa>
			break;
	return (char *) s;
}
  800b2b:	5d                   	pop    %ebp
  800b2c:	c3                   	ret    

00800b2d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b2d:	55                   	push   %ebp
  800b2e:	89 e5                	mov    %esp,%ebp
  800b30:	57                   	push   %edi
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b36:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b39:	85 c9                	test   %ecx,%ecx
  800b3b:	74 2f                	je     800b6c <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b3d:	89 f8                	mov    %edi,%eax
  800b3f:	09 c8                	or     %ecx,%eax
  800b41:	a8 03                	test   $0x3,%al
  800b43:	75 21                	jne    800b66 <memset+0x39>
		c &= 0xFF;
  800b45:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b49:	89 d0                	mov    %edx,%eax
  800b4b:	c1 e0 08             	shl    $0x8,%eax
  800b4e:	89 d3                	mov    %edx,%ebx
  800b50:	c1 e3 18             	shl    $0x18,%ebx
  800b53:	89 d6                	mov    %edx,%esi
  800b55:	c1 e6 10             	shl    $0x10,%esi
  800b58:	09 f3                	or     %esi,%ebx
  800b5a:	09 da                	or     %ebx,%edx
  800b5c:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b5e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b61:	fc                   	cld    
  800b62:	f3 ab                	rep stos %eax,%es:(%edi)
  800b64:	eb 06                	jmp    800b6c <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b69:	fc                   	cld    
  800b6a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b6c:	89 f8                	mov    %edi,%eax
  800b6e:	5b                   	pop    %ebx
  800b6f:	5e                   	pop    %esi
  800b70:	5f                   	pop    %edi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	57                   	push   %edi
  800b77:	56                   	push   %esi
  800b78:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b81:	39 c6                	cmp    %eax,%esi
  800b83:	73 32                	jae    800bb7 <memmove+0x44>
  800b85:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b88:	39 c2                	cmp    %eax,%edx
  800b8a:	76 2b                	jbe    800bb7 <memmove+0x44>
		s += n;
		d += n;
  800b8c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8f:	89 d6                	mov    %edx,%esi
  800b91:	09 fe                	or     %edi,%esi
  800b93:	09 ce                	or     %ecx,%esi
  800b95:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b9b:	75 0e                	jne    800bab <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b9d:	83 ef 04             	sub    $0x4,%edi
  800ba0:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ba3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ba6:	fd                   	std    
  800ba7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba9:	eb 09                	jmp    800bb4 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800bab:	83 ef 01             	sub    $0x1,%edi
  800bae:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800bb1:	fd                   	std    
  800bb2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bb4:	fc                   	cld    
  800bb5:	eb 1a                	jmp    800bd1 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb7:	89 f2                	mov    %esi,%edx
  800bb9:	09 c2                	or     %eax,%edx
  800bbb:	09 ca                	or     %ecx,%edx
  800bbd:	f6 c2 03             	test   $0x3,%dl
  800bc0:	75 0a                	jne    800bcc <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800bc2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800bc5:	89 c7                	mov    %eax,%edi
  800bc7:	fc                   	cld    
  800bc8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bca:	eb 05                	jmp    800bd1 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800bcc:	89 c7                	mov    %eax,%edi
  800bce:	fc                   	cld    
  800bcf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bd1:	5e                   	pop    %esi
  800bd2:	5f                   	pop    %edi
  800bd3:	5d                   	pop    %ebp
  800bd4:	c3                   	ret    

00800bd5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bdb:	ff 75 10             	push   0x10(%ebp)
  800bde:	ff 75 0c             	push   0xc(%ebp)
  800be1:	ff 75 08             	push   0x8(%ebp)
  800be4:	e8 8a ff ff ff       	call   800b73 <memmove>
}
  800be9:	c9                   	leave  
  800bea:	c3                   	ret    

00800beb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	56                   	push   %esi
  800bef:	53                   	push   %ebx
  800bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bf6:	89 c6                	mov    %eax,%esi
  800bf8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bfb:	eb 06                	jmp    800c03 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bfd:	83 c0 01             	add    $0x1,%eax
  800c00:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800c03:	39 f0                	cmp    %esi,%eax
  800c05:	74 14                	je     800c1b <memcmp+0x30>
		if (*s1 != *s2)
  800c07:	0f b6 08             	movzbl (%eax),%ecx
  800c0a:	0f b6 1a             	movzbl (%edx),%ebx
  800c0d:	38 d9                	cmp    %bl,%cl
  800c0f:	74 ec                	je     800bfd <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800c11:	0f b6 c1             	movzbl %cl,%eax
  800c14:	0f b6 db             	movzbl %bl,%ebx
  800c17:	29 d8                	sub    %ebx,%eax
  800c19:	eb 05                	jmp    800c20 <memcmp+0x35>
	}

	return 0;
  800c1b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c20:	5b                   	pop    %ebx
  800c21:	5e                   	pop    %esi
  800c22:	5d                   	pop    %ebp
  800c23:	c3                   	ret    

00800c24 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c2d:	89 c2                	mov    %eax,%edx
  800c2f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c32:	eb 03                	jmp    800c37 <memfind+0x13>
  800c34:	83 c0 01             	add    $0x1,%eax
  800c37:	39 d0                	cmp    %edx,%eax
  800c39:	73 04                	jae    800c3f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c3b:	38 08                	cmp    %cl,(%eax)
  800c3d:	75 f5                	jne    800c34 <memfind+0x10>
			break;
	return (void *) s;
}
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c4d:	eb 03                	jmp    800c52 <strtol+0x11>
		s++;
  800c4f:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800c52:	0f b6 02             	movzbl (%edx),%eax
  800c55:	3c 20                	cmp    $0x20,%al
  800c57:	74 f6                	je     800c4f <strtol+0xe>
  800c59:	3c 09                	cmp    $0x9,%al
  800c5b:	74 f2                	je     800c4f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c5d:	3c 2b                	cmp    $0x2b,%al
  800c5f:	74 2a                	je     800c8b <strtol+0x4a>
	int neg = 0;
  800c61:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c66:	3c 2d                	cmp    $0x2d,%al
  800c68:	74 2b                	je     800c95 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c6a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c70:	75 0f                	jne    800c81 <strtol+0x40>
  800c72:	80 3a 30             	cmpb   $0x30,(%edx)
  800c75:	74 28                	je     800c9f <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c77:	85 db                	test   %ebx,%ebx
  800c79:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c7e:	0f 44 d8             	cmove  %eax,%ebx
  800c81:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c86:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c89:	eb 46                	jmp    800cd1 <strtol+0x90>
		s++;
  800c8b:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800c8e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c93:	eb d5                	jmp    800c6a <strtol+0x29>
		s++, neg = 1;
  800c95:	83 c2 01             	add    $0x1,%edx
  800c98:	bf 01 00 00 00       	mov    $0x1,%edi
  800c9d:	eb cb                	jmp    800c6a <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c9f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800ca3:	74 0e                	je     800cb3 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800ca5:	85 db                	test   %ebx,%ebx
  800ca7:	75 d8                	jne    800c81 <strtol+0x40>
		s++, base = 8;
  800ca9:	83 c2 01             	add    $0x1,%edx
  800cac:	bb 08 00 00 00       	mov    $0x8,%ebx
  800cb1:	eb ce                	jmp    800c81 <strtol+0x40>
		s += 2, base = 16;
  800cb3:	83 c2 02             	add    $0x2,%edx
  800cb6:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cbb:	eb c4                	jmp    800c81 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800cbd:	0f be c0             	movsbl %al,%eax
  800cc0:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800cc3:	3b 45 10             	cmp    0x10(%ebp),%eax
  800cc6:	7d 3a                	jge    800d02 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800cc8:	83 c2 01             	add    $0x1,%edx
  800ccb:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ccf:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800cd1:	0f b6 02             	movzbl (%edx),%eax
  800cd4:	8d 70 d0             	lea    -0x30(%eax),%esi
  800cd7:	89 f3                	mov    %esi,%ebx
  800cd9:	80 fb 09             	cmp    $0x9,%bl
  800cdc:	76 df                	jbe    800cbd <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800cde:	8d 70 9f             	lea    -0x61(%eax),%esi
  800ce1:	89 f3                	mov    %esi,%ebx
  800ce3:	80 fb 19             	cmp    $0x19,%bl
  800ce6:	77 08                	ja     800cf0 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ce8:	0f be c0             	movsbl %al,%eax
  800ceb:	83 e8 57             	sub    $0x57,%eax
  800cee:	eb d3                	jmp    800cc3 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800cf0:	8d 70 bf             	lea    -0x41(%eax),%esi
  800cf3:	89 f3                	mov    %esi,%ebx
  800cf5:	80 fb 19             	cmp    $0x19,%bl
  800cf8:	77 08                	ja     800d02 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800cfa:	0f be c0             	movsbl %al,%eax
  800cfd:	83 e8 37             	sub    $0x37,%eax
  800d00:	eb c1                	jmp    800cc3 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d06:	74 05                	je     800d0d <strtol+0xcc>
		*endptr = (char *) s;
  800d08:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0b:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800d0d:	89 c8                	mov    %ecx,%eax
  800d0f:	f7 d8                	neg    %eax
  800d11:	85 ff                	test   %edi,%edi
  800d13:	0f 45 c8             	cmovne %eax,%ecx
}
  800d16:	89 c8                	mov    %ecx,%eax
  800d18:	5b                   	pop    %ebx
  800d19:	5e                   	pop    %esi
  800d1a:	5f                   	pop    %edi
  800d1b:	5d                   	pop    %ebp
  800d1c:	c3                   	ret    
  800d1d:	66 90                	xchg   %ax,%ax
  800d1f:	90                   	nop

00800d20 <__udivdi3>:
  800d20:	f3 0f 1e fb          	endbr32 
  800d24:	55                   	push   %ebp
  800d25:	57                   	push   %edi
  800d26:	56                   	push   %esi
  800d27:	53                   	push   %ebx
  800d28:	83 ec 1c             	sub    $0x1c,%esp
  800d2b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800d2f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d33:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d37:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	75 19                	jne    800d58 <__udivdi3+0x38>
  800d3f:	39 f3                	cmp    %esi,%ebx
  800d41:	76 4d                	jbe    800d90 <__udivdi3+0x70>
  800d43:	31 ff                	xor    %edi,%edi
  800d45:	89 e8                	mov    %ebp,%eax
  800d47:	89 f2                	mov    %esi,%edx
  800d49:	f7 f3                	div    %ebx
  800d4b:	89 fa                	mov    %edi,%edx
  800d4d:	83 c4 1c             	add    $0x1c,%esp
  800d50:	5b                   	pop    %ebx
  800d51:	5e                   	pop    %esi
  800d52:	5f                   	pop    %edi
  800d53:	5d                   	pop    %ebp
  800d54:	c3                   	ret    
  800d55:	8d 76 00             	lea    0x0(%esi),%esi
  800d58:	39 f0                	cmp    %esi,%eax
  800d5a:	76 14                	jbe    800d70 <__udivdi3+0x50>
  800d5c:	31 ff                	xor    %edi,%edi
  800d5e:	31 c0                	xor    %eax,%eax
  800d60:	89 fa                	mov    %edi,%edx
  800d62:	83 c4 1c             	add    $0x1c,%esp
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    
  800d6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d70:	0f bd f8             	bsr    %eax,%edi
  800d73:	83 f7 1f             	xor    $0x1f,%edi
  800d76:	75 48                	jne    800dc0 <__udivdi3+0xa0>
  800d78:	39 f0                	cmp    %esi,%eax
  800d7a:	72 06                	jb     800d82 <__udivdi3+0x62>
  800d7c:	31 c0                	xor    %eax,%eax
  800d7e:	39 eb                	cmp    %ebp,%ebx
  800d80:	77 de                	ja     800d60 <__udivdi3+0x40>
  800d82:	b8 01 00 00 00       	mov    $0x1,%eax
  800d87:	eb d7                	jmp    800d60 <__udivdi3+0x40>
  800d89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d90:	89 d9                	mov    %ebx,%ecx
  800d92:	85 db                	test   %ebx,%ebx
  800d94:	75 0b                	jne    800da1 <__udivdi3+0x81>
  800d96:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9b:	31 d2                	xor    %edx,%edx
  800d9d:	f7 f3                	div    %ebx
  800d9f:	89 c1                	mov    %eax,%ecx
  800da1:	31 d2                	xor    %edx,%edx
  800da3:	89 f0                	mov    %esi,%eax
  800da5:	f7 f1                	div    %ecx
  800da7:	89 c6                	mov    %eax,%esi
  800da9:	89 e8                	mov    %ebp,%eax
  800dab:	89 f7                	mov    %esi,%edi
  800dad:	f7 f1                	div    %ecx
  800daf:	89 fa                	mov    %edi,%edx
  800db1:	83 c4 1c             	add    $0x1c,%esp
  800db4:	5b                   	pop    %ebx
  800db5:	5e                   	pop    %esi
  800db6:	5f                   	pop    %edi
  800db7:	5d                   	pop    %ebp
  800db8:	c3                   	ret    
  800db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800dc0:	89 f9                	mov    %edi,%ecx
  800dc2:	ba 20 00 00 00       	mov    $0x20,%edx
  800dc7:	29 fa                	sub    %edi,%edx
  800dc9:	d3 e0                	shl    %cl,%eax
  800dcb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dcf:	89 d1                	mov    %edx,%ecx
  800dd1:	89 d8                	mov    %ebx,%eax
  800dd3:	d3 e8                	shr    %cl,%eax
  800dd5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800dd9:	09 c1                	or     %eax,%ecx
  800ddb:	89 f0                	mov    %esi,%eax
  800ddd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800de1:	89 f9                	mov    %edi,%ecx
  800de3:	d3 e3                	shl    %cl,%ebx
  800de5:	89 d1                	mov    %edx,%ecx
  800de7:	d3 e8                	shr    %cl,%eax
  800de9:	89 f9                	mov    %edi,%ecx
  800deb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800def:	89 eb                	mov    %ebp,%ebx
  800df1:	d3 e6                	shl    %cl,%esi
  800df3:	89 d1                	mov    %edx,%ecx
  800df5:	d3 eb                	shr    %cl,%ebx
  800df7:	09 f3                	or     %esi,%ebx
  800df9:	89 c6                	mov    %eax,%esi
  800dfb:	89 f2                	mov    %esi,%edx
  800dfd:	89 d8                	mov    %ebx,%eax
  800dff:	f7 74 24 08          	divl   0x8(%esp)
  800e03:	89 d6                	mov    %edx,%esi
  800e05:	89 c3                	mov    %eax,%ebx
  800e07:	f7 64 24 0c          	mull   0xc(%esp)
  800e0b:	39 d6                	cmp    %edx,%esi
  800e0d:	72 19                	jb     800e28 <__udivdi3+0x108>
  800e0f:	89 f9                	mov    %edi,%ecx
  800e11:	d3 e5                	shl    %cl,%ebp
  800e13:	39 c5                	cmp    %eax,%ebp
  800e15:	73 04                	jae    800e1b <__udivdi3+0xfb>
  800e17:	39 d6                	cmp    %edx,%esi
  800e19:	74 0d                	je     800e28 <__udivdi3+0x108>
  800e1b:	89 d8                	mov    %ebx,%eax
  800e1d:	31 ff                	xor    %edi,%edi
  800e1f:	e9 3c ff ff ff       	jmp    800d60 <__udivdi3+0x40>
  800e24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e28:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e2b:	31 ff                	xor    %edi,%edi
  800e2d:	e9 2e ff ff ff       	jmp    800d60 <__udivdi3+0x40>
  800e32:	66 90                	xchg   %ax,%ax
  800e34:	66 90                	xchg   %ax,%ax
  800e36:	66 90                	xchg   %ax,%ax
  800e38:	66 90                	xchg   %ax,%ax
  800e3a:	66 90                	xchg   %ax,%ax
  800e3c:	66 90                	xchg   %ax,%ax
  800e3e:	66 90                	xchg   %ax,%ax

00800e40 <__umoddi3>:
  800e40:	f3 0f 1e fb          	endbr32 
  800e44:	55                   	push   %ebp
  800e45:	57                   	push   %edi
  800e46:	56                   	push   %esi
  800e47:	53                   	push   %ebx
  800e48:	83 ec 1c             	sub    $0x1c,%esp
  800e4b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e4f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e53:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800e57:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800e5b:	89 f0                	mov    %esi,%eax
  800e5d:	89 da                	mov    %ebx,%edx
  800e5f:	85 ff                	test   %edi,%edi
  800e61:	75 15                	jne    800e78 <__umoddi3+0x38>
  800e63:	39 dd                	cmp    %ebx,%ebp
  800e65:	76 39                	jbe    800ea0 <__umoddi3+0x60>
  800e67:	f7 f5                	div    %ebp
  800e69:	89 d0                	mov    %edx,%eax
  800e6b:	31 d2                	xor    %edx,%edx
  800e6d:	83 c4 1c             	add    $0x1c,%esp
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5f                   	pop    %edi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    
  800e75:	8d 76 00             	lea    0x0(%esi),%esi
  800e78:	39 df                	cmp    %ebx,%edi
  800e7a:	77 f1                	ja     800e6d <__umoddi3+0x2d>
  800e7c:	0f bd cf             	bsr    %edi,%ecx
  800e7f:	83 f1 1f             	xor    $0x1f,%ecx
  800e82:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e86:	75 40                	jne    800ec8 <__umoddi3+0x88>
  800e88:	39 df                	cmp    %ebx,%edi
  800e8a:	72 04                	jb     800e90 <__umoddi3+0x50>
  800e8c:	39 f5                	cmp    %esi,%ebp
  800e8e:	77 dd                	ja     800e6d <__umoddi3+0x2d>
  800e90:	89 da                	mov    %ebx,%edx
  800e92:	89 f0                	mov    %esi,%eax
  800e94:	29 e8                	sub    %ebp,%eax
  800e96:	19 fa                	sbb    %edi,%edx
  800e98:	eb d3                	jmp    800e6d <__umoddi3+0x2d>
  800e9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800ea0:	89 e9                	mov    %ebp,%ecx
  800ea2:	85 ed                	test   %ebp,%ebp
  800ea4:	75 0b                	jne    800eb1 <__umoddi3+0x71>
  800ea6:	b8 01 00 00 00       	mov    $0x1,%eax
  800eab:	31 d2                	xor    %edx,%edx
  800ead:	f7 f5                	div    %ebp
  800eaf:	89 c1                	mov    %eax,%ecx
  800eb1:	89 d8                	mov    %ebx,%eax
  800eb3:	31 d2                	xor    %edx,%edx
  800eb5:	f7 f1                	div    %ecx
  800eb7:	89 f0                	mov    %esi,%eax
  800eb9:	f7 f1                	div    %ecx
  800ebb:	89 d0                	mov    %edx,%eax
  800ebd:	31 d2                	xor    %edx,%edx
  800ebf:	eb ac                	jmp    800e6d <__umoddi3+0x2d>
  800ec1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ec8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ecc:	ba 20 00 00 00       	mov    $0x20,%edx
  800ed1:	29 c2                	sub    %eax,%edx
  800ed3:	89 c1                	mov    %eax,%ecx
  800ed5:	89 e8                	mov    %ebp,%eax
  800ed7:	d3 e7                	shl    %cl,%edi
  800ed9:	89 d1                	mov    %edx,%ecx
  800edb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800edf:	d3 e8                	shr    %cl,%eax
  800ee1:	89 c1                	mov    %eax,%ecx
  800ee3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ee7:	09 f9                	or     %edi,%ecx
  800ee9:	89 df                	mov    %ebx,%edi
  800eeb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800eef:	89 c1                	mov    %eax,%ecx
  800ef1:	d3 e5                	shl    %cl,%ebp
  800ef3:	89 d1                	mov    %edx,%ecx
  800ef5:	d3 ef                	shr    %cl,%edi
  800ef7:	89 c1                	mov    %eax,%ecx
  800ef9:	89 f0                	mov    %esi,%eax
  800efb:	d3 e3                	shl    %cl,%ebx
  800efd:	89 d1                	mov    %edx,%ecx
  800eff:	89 fa                	mov    %edi,%edx
  800f01:	d3 e8                	shr    %cl,%eax
  800f03:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800f08:	09 d8                	or     %ebx,%eax
  800f0a:	f7 74 24 08          	divl   0x8(%esp)
  800f0e:	89 d3                	mov    %edx,%ebx
  800f10:	d3 e6                	shl    %cl,%esi
  800f12:	f7 e5                	mul    %ebp
  800f14:	89 c7                	mov    %eax,%edi
  800f16:	89 d1                	mov    %edx,%ecx
  800f18:	39 d3                	cmp    %edx,%ebx
  800f1a:	72 06                	jb     800f22 <__umoddi3+0xe2>
  800f1c:	75 0e                	jne    800f2c <__umoddi3+0xec>
  800f1e:	39 c6                	cmp    %eax,%esi
  800f20:	73 0a                	jae    800f2c <__umoddi3+0xec>
  800f22:	29 e8                	sub    %ebp,%eax
  800f24:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800f28:	89 d1                	mov    %edx,%ecx
  800f2a:	89 c7                	mov    %eax,%edi
  800f2c:	89 f5                	mov    %esi,%ebp
  800f2e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f32:	29 fd                	sub    %edi,%ebp
  800f34:	19 cb                	sbb    %ecx,%ebx
  800f36:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f3b:	89 d8                	mov    %ebx,%eax
  800f3d:	d3 e0                	shl    %cl,%eax
  800f3f:	89 f1                	mov    %esi,%ecx
  800f41:	d3 ed                	shr    %cl,%ebp
  800f43:	d3 eb                	shr    %cl,%ebx
  800f45:	09 e8                	or     %ebp,%eax
  800f47:	89 da                	mov    %ebx,%edx
  800f49:	83 c4 1c             	add    $0x1c,%esp
  800f4c:	5b                   	pop    %ebx
  800f4d:	5e                   	pop    %esi
  800f4e:	5f                   	pop    %edi
  800f4f:	5d                   	pop    %ebp
  800f50:	c3                   	ret    
