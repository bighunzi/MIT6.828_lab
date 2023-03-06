
obj/user/idle：     文件格式 elf32-i386


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
  800039:	c7 05 00 20 80 00 60 	movl   $0x800f60,0x802000
  800040:	0f 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 f7 00 00 00       	call   80013f <sys_yield>
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
  800055:	e8 c6 00 00 00       	call   800120 <sys_getenvid>
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x2d>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 20 80 00       	mov    %eax,0x802000

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
  800093:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f0:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7f 08                	jg     800109 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800101:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800104:	5b                   	pop    %ebx
  800105:	5e                   	pop    %esi
  800106:	5f                   	pop    %edi
  800107:	5d                   	pop    %ebp
  800108:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800109:	83 ec 0c             	sub    $0xc,%esp
  80010c:	50                   	push   %eax
  80010d:	6a 03                	push   $0x3
  80010f:	68 6f 0f 80 00       	push   $0x800f6f
  800114:	6a 2a                	push   $0x2a
  800116:	68 8c 0f 80 00       	push   $0x800f8c
  80011b:	e8 ed 01 00 00       	call   80030d <_panic>

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	8b 55 08             	mov    0x8(%ebp),%edx
  80016f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800172:	b8 04 00 00 00       	mov    $0x4,%eax
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7f 08                	jg     80018a <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800182:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800185:	5b                   	pop    %ebx
  800186:	5e                   	pop    %esi
  800187:	5f                   	pop    %edi
  800188:	5d                   	pop    %ebp
  800189:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80018a:	83 ec 0c             	sub    $0xc,%esp
  80018d:	50                   	push   %eax
  80018e:	6a 04                	push   $0x4
  800190:	68 6f 0f 80 00       	push   $0x800f6f
  800195:	6a 2a                	push   $0x2a
  800197:	68 8c 0f 80 00       	push   $0x800f8c
  80019c:	e8 6c 01 00 00       	call   80030d <_panic>

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b0:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7f 08                	jg     8001cc <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c7:	5b                   	pop    %ebx
  8001c8:	5e                   	pop    %esi
  8001c9:	5f                   	pop    %edi
  8001ca:	5d                   	pop    %ebp
  8001cb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	50                   	push   %eax
  8001d0:	6a 05                	push   $0x5
  8001d2:	68 6f 0f 80 00       	push   $0x800f6f
  8001d7:	6a 2a                	push   $0x2a
  8001d9:	68 8c 0f 80 00       	push   $0x800f8c
  8001de:	e8 2a 01 00 00       	call   80030d <_panic>

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f7:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7f 08                	jg     80020e <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800206:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800209:	5b                   	pop    %ebx
  80020a:	5e                   	pop    %esi
  80020b:	5f                   	pop    %edi
  80020c:	5d                   	pop    %ebp
  80020d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80020e:	83 ec 0c             	sub    $0xc,%esp
  800211:	50                   	push   %eax
  800212:	6a 06                	push   $0x6
  800214:	68 6f 0f 80 00       	push   $0x800f6f
  800219:	6a 2a                	push   $0x2a
  80021b:	68 8c 0f 80 00       	push   $0x800f8c
  800220:	e8 e8 00 00 00       	call   80030d <_panic>

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	8b 55 08             	mov    0x8(%ebp),%edx
  800236:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800239:	b8 08 00 00 00       	mov    $0x8,%eax
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7f 08                	jg     800250 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800248:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024b:	5b                   	pop    %ebx
  80024c:	5e                   	pop    %esi
  80024d:	5f                   	pop    %edi
  80024e:	5d                   	pop    %ebp
  80024f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800250:	83 ec 0c             	sub    $0xc,%esp
  800253:	50                   	push   %eax
  800254:	6a 08                	push   $0x8
  800256:	68 6f 0f 80 00       	push   $0x800f6f
  80025b:	6a 2a                	push   $0x2a
  80025d:	68 8c 0f 80 00       	push   $0x800f8c
  800262:	e8 a6 00 00 00       	call   80030d <_panic>

00800267 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	8b 55 08             	mov    0x8(%ebp),%edx
  800278:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027b:	b8 09 00 00 00       	mov    $0x9,%eax
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7f 08                	jg     800292 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80028a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028d:	5b                   	pop    %ebx
  80028e:	5e                   	pop    %esi
  80028f:	5f                   	pop    %edi
  800290:	5d                   	pop    %ebp
  800291:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800292:	83 ec 0c             	sub    $0xc,%esp
  800295:	50                   	push   %eax
  800296:	6a 09                	push   $0x9
  800298:	68 6f 0f 80 00       	push   $0x800f6f
  80029d:	6a 2a                	push   $0x2a
  80029f:	68 8c 0f 80 00       	push   $0x800f8c
  8002a4:	e8 64 00 00 00       	call   80030d <_panic>

008002a9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002af:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002ba:	be 00 00 00 00       	mov    $0x0,%esi
  8002bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c5:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002da:	8b 55 08             	mov    0x8(%ebp),%edx
  8002dd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e2:	89 cb                	mov    %ecx,%ebx
  8002e4:	89 cf                	mov    %ecx,%edi
  8002e6:	89 ce                	mov    %ecx,%esi
  8002e8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	7f 08                	jg     8002f6 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f1:	5b                   	pop    %ebx
  8002f2:	5e                   	pop    %esi
  8002f3:	5f                   	pop    %edi
  8002f4:	5d                   	pop    %ebp
  8002f5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f6:	83 ec 0c             	sub    $0xc,%esp
  8002f9:	50                   	push   %eax
  8002fa:	6a 0c                	push   $0xc
  8002fc:	68 6f 0f 80 00       	push   $0x800f6f
  800301:	6a 2a                	push   $0x2a
  800303:	68 8c 0f 80 00       	push   $0x800f8c
  800308:	e8 00 00 00 00       	call   80030d <_panic>

0080030d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	56                   	push   %esi
  800311:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800312:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800315:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80031b:	e8 00 fe ff ff       	call   800120 <sys_getenvid>
  800320:	83 ec 0c             	sub    $0xc,%esp
  800323:	ff 75 0c             	push   0xc(%ebp)
  800326:	ff 75 08             	push   0x8(%ebp)
  800329:	56                   	push   %esi
  80032a:	50                   	push   %eax
  80032b:	68 9c 0f 80 00       	push   $0x800f9c
  800330:	e8 b3 00 00 00       	call   8003e8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800335:	83 c4 18             	add    $0x18,%esp
  800338:	53                   	push   %ebx
  800339:	ff 75 10             	push   0x10(%ebp)
  80033c:	e8 56 00 00 00       	call   800397 <vcprintf>
	cprintf("\n");
  800341:	c7 04 24 bf 0f 80 00 	movl   $0x800fbf,(%esp)
  800348:	e8 9b 00 00 00       	call   8003e8 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800350:	cc                   	int3   
  800351:	eb fd                	jmp    800350 <_panic+0x43>

00800353 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
  800356:	53                   	push   %ebx
  800357:	83 ec 04             	sub    $0x4,%esp
  80035a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80035d:	8b 13                	mov    (%ebx),%edx
  80035f:	8d 42 01             	lea    0x1(%edx),%eax
  800362:	89 03                	mov    %eax,(%ebx)
  800364:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800367:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80036b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800370:	74 09                	je     80037b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800372:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800376:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800379:	c9                   	leave  
  80037a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80037b:	83 ec 08             	sub    $0x8,%esp
  80037e:	68 ff 00 00 00       	push   $0xff
  800383:	8d 43 08             	lea    0x8(%ebx),%eax
  800386:	50                   	push   %eax
  800387:	e8 16 fd ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  80038c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800392:	83 c4 10             	add    $0x10,%esp
  800395:	eb db                	jmp    800372 <putch+0x1f>

00800397 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
  80039a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a7:	00 00 00 
	b.cnt = 0;
  8003aa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b4:	ff 75 0c             	push   0xc(%ebp)
  8003b7:	ff 75 08             	push   0x8(%ebp)
  8003ba:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c0:	50                   	push   %eax
  8003c1:	68 53 03 80 00       	push   $0x800353
  8003c6:	e8 14 01 00 00       	call   8004df <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003cb:	83 c4 08             	add    $0x8,%esp
  8003ce:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8003d4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003da:	50                   	push   %eax
  8003db:	e8 c2 fc ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  8003e0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e6:	c9                   	leave  
  8003e7:	c3                   	ret    

008003e8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003ee:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f1:	50                   	push   %eax
  8003f2:	ff 75 08             	push   0x8(%ebp)
  8003f5:	e8 9d ff ff ff       	call   800397 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fa:	c9                   	leave  
  8003fb:	c3                   	ret    

008003fc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003fc:	55                   	push   %ebp
  8003fd:	89 e5                	mov    %esp,%ebp
  8003ff:	57                   	push   %edi
  800400:	56                   	push   %esi
  800401:	53                   	push   %ebx
  800402:	83 ec 1c             	sub    $0x1c,%esp
  800405:	89 c7                	mov    %eax,%edi
  800407:	89 d6                	mov    %edx,%esi
  800409:	8b 45 08             	mov    0x8(%ebp),%eax
  80040c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80040f:	89 d1                	mov    %edx,%ecx
  800411:	89 c2                	mov    %eax,%edx
  800413:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800416:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800419:	8b 45 10             	mov    0x10(%ebp),%eax
  80041c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80041f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800422:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800429:	39 c2                	cmp    %eax,%edx
  80042b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80042e:	72 3e                	jb     80046e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800430:	83 ec 0c             	sub    $0xc,%esp
  800433:	ff 75 18             	push   0x18(%ebp)
  800436:	83 eb 01             	sub    $0x1,%ebx
  800439:	53                   	push   %ebx
  80043a:	50                   	push   %eax
  80043b:	83 ec 08             	sub    $0x8,%esp
  80043e:	ff 75 e4             	push   -0x1c(%ebp)
  800441:	ff 75 e0             	push   -0x20(%ebp)
  800444:	ff 75 dc             	push   -0x24(%ebp)
  800447:	ff 75 d8             	push   -0x28(%ebp)
  80044a:	e8 c1 08 00 00       	call   800d10 <__udivdi3>
  80044f:	83 c4 18             	add    $0x18,%esp
  800452:	52                   	push   %edx
  800453:	50                   	push   %eax
  800454:	89 f2                	mov    %esi,%edx
  800456:	89 f8                	mov    %edi,%eax
  800458:	e8 9f ff ff ff       	call   8003fc <printnum>
  80045d:	83 c4 20             	add    $0x20,%esp
  800460:	eb 13                	jmp    800475 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	56                   	push   %esi
  800466:	ff 75 18             	push   0x18(%ebp)
  800469:	ff d7                	call   *%edi
  80046b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80046e:	83 eb 01             	sub    $0x1,%ebx
  800471:	85 db                	test   %ebx,%ebx
  800473:	7f ed                	jg     800462 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800475:	83 ec 08             	sub    $0x8,%esp
  800478:	56                   	push   %esi
  800479:	83 ec 04             	sub    $0x4,%esp
  80047c:	ff 75 e4             	push   -0x1c(%ebp)
  80047f:	ff 75 e0             	push   -0x20(%ebp)
  800482:	ff 75 dc             	push   -0x24(%ebp)
  800485:	ff 75 d8             	push   -0x28(%ebp)
  800488:	e8 a3 09 00 00       	call   800e30 <__umoddi3>
  80048d:	83 c4 14             	add    $0x14,%esp
  800490:	0f be 80 c1 0f 80 00 	movsbl 0x800fc1(%eax),%eax
  800497:	50                   	push   %eax
  800498:	ff d7                	call   *%edi
}
  80049a:	83 c4 10             	add    $0x10,%esp
  80049d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a0:	5b                   	pop    %ebx
  8004a1:	5e                   	pop    %esi
  8004a2:	5f                   	pop    %edi
  8004a3:	5d                   	pop    %ebp
  8004a4:	c3                   	ret    

008004a5 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a5:	55                   	push   %ebp
  8004a6:	89 e5                	mov    %esp,%ebp
  8004a8:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ab:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004af:	8b 10                	mov    (%eax),%edx
  8004b1:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b4:	73 0a                	jae    8004c0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004b6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004b9:	89 08                	mov    %ecx,(%eax)
  8004bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8004be:	88 02                	mov    %al,(%edx)
}
  8004c0:	5d                   	pop    %ebp
  8004c1:	c3                   	ret    

008004c2 <printfmt>:
{
  8004c2:	55                   	push   %ebp
  8004c3:	89 e5                	mov    %esp,%ebp
  8004c5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004c8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004cb:	50                   	push   %eax
  8004cc:	ff 75 10             	push   0x10(%ebp)
  8004cf:	ff 75 0c             	push   0xc(%ebp)
  8004d2:	ff 75 08             	push   0x8(%ebp)
  8004d5:	e8 05 00 00 00       	call   8004df <vprintfmt>
}
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	c9                   	leave  
  8004de:	c3                   	ret    

008004df <vprintfmt>:
{
  8004df:	55                   	push   %ebp
  8004e0:	89 e5                	mov    %esp,%ebp
  8004e2:	57                   	push   %edi
  8004e3:	56                   	push   %esi
  8004e4:	53                   	push   %ebx
  8004e5:	83 ec 3c             	sub    $0x3c,%esp
  8004e8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004eb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004f1:	eb 0a                	jmp    8004fd <vprintfmt+0x1e>
			putch(ch, putdat);
  8004f3:	83 ec 08             	sub    $0x8,%esp
  8004f6:	53                   	push   %ebx
  8004f7:	50                   	push   %eax
  8004f8:	ff d6                	call   *%esi
  8004fa:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004fd:	83 c7 01             	add    $0x1,%edi
  800500:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800504:	83 f8 25             	cmp    $0x25,%eax
  800507:	74 0c                	je     800515 <vprintfmt+0x36>
			if (ch == '\0')
  800509:	85 c0                	test   %eax,%eax
  80050b:	75 e6                	jne    8004f3 <vprintfmt+0x14>
}
  80050d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800510:	5b                   	pop    %ebx
  800511:	5e                   	pop    %esi
  800512:	5f                   	pop    %edi
  800513:	5d                   	pop    %ebp
  800514:	c3                   	ret    
		padc = ' ';
  800515:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800519:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800520:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800527:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80052e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800533:	8d 47 01             	lea    0x1(%edi),%eax
  800536:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800539:	0f b6 17             	movzbl (%edi),%edx
  80053c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80053f:	3c 55                	cmp    $0x55,%al
  800541:	0f 87 bb 03 00 00    	ja     800902 <vprintfmt+0x423>
  800547:	0f b6 c0             	movzbl %al,%eax
  80054a:	ff 24 85 80 10 80 00 	jmp    *0x801080(,%eax,4)
  800551:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800554:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800558:	eb d9                	jmp    800533 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80055a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800561:	eb d0                	jmp    800533 <vprintfmt+0x54>
  800563:	0f b6 d2             	movzbl %dl,%edx
  800566:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800569:	b8 00 00 00 00       	mov    $0x0,%eax
  80056e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800571:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800574:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800578:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80057b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80057e:	83 f9 09             	cmp    $0x9,%ecx
  800581:	77 55                	ja     8005d8 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800583:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800586:	eb e9                	jmp    800571 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8b 00                	mov    (%eax),%eax
  80058d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800590:	8b 45 14             	mov    0x14(%ebp),%eax
  800593:	8d 40 04             	lea    0x4(%eax),%eax
  800596:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800599:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80059c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005a0:	79 91                	jns    800533 <vprintfmt+0x54>
				width = precision, precision = -1;
  8005a2:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005af:	eb 82                	jmp    800533 <vprintfmt+0x54>
  8005b1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005b4:	85 d2                	test   %edx,%edx
  8005b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8005bb:	0f 49 c2             	cmovns %edx,%eax
  8005be:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005c4:	e9 6a ff ff ff       	jmp    800533 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005cc:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005d3:	e9 5b ff ff ff       	jmp    800533 <vprintfmt+0x54>
  8005d8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005de:	eb bc                	jmp    80059c <vprintfmt+0xbd>
			lflag++;
  8005e0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005e6:	e9 48 ff ff ff       	jmp    800533 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8005eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ee:	8d 78 04             	lea    0x4(%eax),%edi
  8005f1:	83 ec 08             	sub    $0x8,%esp
  8005f4:	53                   	push   %ebx
  8005f5:	ff 30                	push   (%eax)
  8005f7:	ff d6                	call   *%esi
			break;
  8005f9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005fc:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005ff:	e9 9d 02 00 00       	jmp    8008a1 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 78 04             	lea    0x4(%eax),%edi
  80060a:	8b 10                	mov    (%eax),%edx
  80060c:	89 d0                	mov    %edx,%eax
  80060e:	f7 d8                	neg    %eax
  800610:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800613:	83 f8 08             	cmp    $0x8,%eax
  800616:	7f 23                	jg     80063b <vprintfmt+0x15c>
  800618:	8b 14 85 e0 11 80 00 	mov    0x8011e0(,%eax,4),%edx
  80061f:	85 d2                	test   %edx,%edx
  800621:	74 18                	je     80063b <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800623:	52                   	push   %edx
  800624:	68 e2 0f 80 00       	push   $0x800fe2
  800629:	53                   	push   %ebx
  80062a:	56                   	push   %esi
  80062b:	e8 92 fe ff ff       	call   8004c2 <printfmt>
  800630:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800633:	89 7d 14             	mov    %edi,0x14(%ebp)
  800636:	e9 66 02 00 00       	jmp    8008a1 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80063b:	50                   	push   %eax
  80063c:	68 d9 0f 80 00       	push   $0x800fd9
  800641:	53                   	push   %ebx
  800642:	56                   	push   %esi
  800643:	e8 7a fe ff ff       	call   8004c2 <printfmt>
  800648:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80064b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80064e:	e9 4e 02 00 00       	jmp    8008a1 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	83 c0 04             	add    $0x4,%eax
  800659:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800661:	85 d2                	test   %edx,%edx
  800663:	b8 d2 0f 80 00       	mov    $0x800fd2,%eax
  800668:	0f 45 c2             	cmovne %edx,%eax
  80066b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80066e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800672:	7e 06                	jle    80067a <vprintfmt+0x19b>
  800674:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800678:	75 0d                	jne    800687 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80067a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80067d:	89 c7                	mov    %eax,%edi
  80067f:	03 45 e0             	add    -0x20(%ebp),%eax
  800682:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800685:	eb 55                	jmp    8006dc <vprintfmt+0x1fd>
  800687:	83 ec 08             	sub    $0x8,%esp
  80068a:	ff 75 d8             	push   -0x28(%ebp)
  80068d:	ff 75 cc             	push   -0x34(%ebp)
  800690:	e8 0a 03 00 00       	call   80099f <strnlen>
  800695:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800698:	29 c1                	sub    %eax,%ecx
  80069a:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80069d:	83 c4 10             	add    $0x10,%esp
  8006a0:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8006a2:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006a6:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a9:	eb 0f                	jmp    8006ba <vprintfmt+0x1db>
					putch(padc, putdat);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	53                   	push   %ebx
  8006af:	ff 75 e0             	push   -0x20(%ebp)
  8006b2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b4:	83 ef 01             	sub    $0x1,%edi
  8006b7:	83 c4 10             	add    $0x10,%esp
  8006ba:	85 ff                	test   %edi,%edi
  8006bc:	7f ed                	jg     8006ab <vprintfmt+0x1cc>
  8006be:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006c1:	85 d2                	test   %edx,%edx
  8006c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c8:	0f 49 c2             	cmovns %edx,%eax
  8006cb:	29 c2                	sub    %eax,%edx
  8006cd:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006d0:	eb a8                	jmp    80067a <vprintfmt+0x19b>
					putch(ch, putdat);
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	53                   	push   %ebx
  8006d6:	52                   	push   %edx
  8006d7:	ff d6                	call   *%esi
  8006d9:	83 c4 10             	add    $0x10,%esp
  8006dc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006df:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e1:	83 c7 01             	add    $0x1,%edi
  8006e4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006e8:	0f be d0             	movsbl %al,%edx
  8006eb:	85 d2                	test   %edx,%edx
  8006ed:	74 4b                	je     80073a <vprintfmt+0x25b>
  8006ef:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006f3:	78 06                	js     8006fb <vprintfmt+0x21c>
  8006f5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8006f9:	78 1e                	js     800719 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8006fb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006ff:	74 d1                	je     8006d2 <vprintfmt+0x1f3>
  800701:	0f be c0             	movsbl %al,%eax
  800704:	83 e8 20             	sub    $0x20,%eax
  800707:	83 f8 5e             	cmp    $0x5e,%eax
  80070a:	76 c6                	jbe    8006d2 <vprintfmt+0x1f3>
					putch('?', putdat);
  80070c:	83 ec 08             	sub    $0x8,%esp
  80070f:	53                   	push   %ebx
  800710:	6a 3f                	push   $0x3f
  800712:	ff d6                	call   *%esi
  800714:	83 c4 10             	add    $0x10,%esp
  800717:	eb c3                	jmp    8006dc <vprintfmt+0x1fd>
  800719:	89 cf                	mov    %ecx,%edi
  80071b:	eb 0e                	jmp    80072b <vprintfmt+0x24c>
				putch(' ', putdat);
  80071d:	83 ec 08             	sub    $0x8,%esp
  800720:	53                   	push   %ebx
  800721:	6a 20                	push   $0x20
  800723:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800725:	83 ef 01             	sub    $0x1,%edi
  800728:	83 c4 10             	add    $0x10,%esp
  80072b:	85 ff                	test   %edi,%edi
  80072d:	7f ee                	jg     80071d <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80072f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800732:	89 45 14             	mov    %eax,0x14(%ebp)
  800735:	e9 67 01 00 00       	jmp    8008a1 <vprintfmt+0x3c2>
  80073a:	89 cf                	mov    %ecx,%edi
  80073c:	eb ed                	jmp    80072b <vprintfmt+0x24c>
	if (lflag >= 2)
  80073e:	83 f9 01             	cmp    $0x1,%ecx
  800741:	7f 1b                	jg     80075e <vprintfmt+0x27f>
	else if (lflag)
  800743:	85 c9                	test   %ecx,%ecx
  800745:	74 63                	je     8007aa <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	8b 00                	mov    (%eax),%eax
  80074c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80074f:	99                   	cltd   
  800750:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800753:	8b 45 14             	mov    0x14(%ebp),%eax
  800756:	8d 40 04             	lea    0x4(%eax),%eax
  800759:	89 45 14             	mov    %eax,0x14(%ebp)
  80075c:	eb 17                	jmp    800775 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80075e:	8b 45 14             	mov    0x14(%ebp),%eax
  800761:	8b 50 04             	mov    0x4(%eax),%edx
  800764:	8b 00                	mov    (%eax),%eax
  800766:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800769:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80076c:	8b 45 14             	mov    0x14(%ebp),%eax
  80076f:	8d 40 08             	lea    0x8(%eax),%eax
  800772:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800775:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800778:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80077b:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800780:	85 c9                	test   %ecx,%ecx
  800782:	0f 89 ff 00 00 00    	jns    800887 <vprintfmt+0x3a8>
				putch('-', putdat);
  800788:	83 ec 08             	sub    $0x8,%esp
  80078b:	53                   	push   %ebx
  80078c:	6a 2d                	push   $0x2d
  80078e:	ff d6                	call   *%esi
				num = -(long long) num;
  800790:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800793:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800796:	f7 da                	neg    %edx
  800798:	83 d1 00             	adc    $0x0,%ecx
  80079b:	f7 d9                	neg    %ecx
  80079d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007a0:	bf 0a 00 00 00       	mov    $0xa,%edi
  8007a5:	e9 dd 00 00 00       	jmp    800887 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	8b 00                	mov    (%eax),%eax
  8007af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007b2:	99                   	cltd   
  8007b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b9:	8d 40 04             	lea    0x4(%eax),%eax
  8007bc:	89 45 14             	mov    %eax,0x14(%ebp)
  8007bf:	eb b4                	jmp    800775 <vprintfmt+0x296>
	if (lflag >= 2)
  8007c1:	83 f9 01             	cmp    $0x1,%ecx
  8007c4:	7f 1e                	jg     8007e4 <vprintfmt+0x305>
	else if (lflag)
  8007c6:	85 c9                	test   %ecx,%ecx
  8007c8:	74 32                	je     8007fc <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8007ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cd:	8b 10                	mov    (%eax),%edx
  8007cf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d4:	8d 40 04             	lea    0x4(%eax),%eax
  8007d7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007da:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8007df:	e9 a3 00 00 00       	jmp    800887 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e7:	8b 10                	mov    (%eax),%edx
  8007e9:	8b 48 04             	mov    0x4(%eax),%ecx
  8007ec:	8d 40 08             	lea    0x8(%eax),%eax
  8007ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007f2:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8007f7:	e9 8b 00 00 00       	jmp    800887 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ff:	8b 10                	mov    (%eax),%edx
  800801:	b9 00 00 00 00       	mov    $0x0,%ecx
  800806:	8d 40 04             	lea    0x4(%eax),%eax
  800809:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80080c:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800811:	eb 74                	jmp    800887 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800813:	83 f9 01             	cmp    $0x1,%ecx
  800816:	7f 1b                	jg     800833 <vprintfmt+0x354>
	else if (lflag)
  800818:	85 c9                	test   %ecx,%ecx
  80081a:	74 2c                	je     800848 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80081c:	8b 45 14             	mov    0x14(%ebp),%eax
  80081f:	8b 10                	mov    (%eax),%edx
  800821:	b9 00 00 00 00       	mov    $0x0,%ecx
  800826:	8d 40 04             	lea    0x4(%eax),%eax
  800829:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80082c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800831:	eb 54                	jmp    800887 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800833:	8b 45 14             	mov    0x14(%ebp),%eax
  800836:	8b 10                	mov    (%eax),%edx
  800838:	8b 48 04             	mov    0x4(%eax),%ecx
  80083b:	8d 40 08             	lea    0x8(%eax),%eax
  80083e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800841:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800846:	eb 3f                	jmp    800887 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800848:	8b 45 14             	mov    0x14(%ebp),%eax
  80084b:	8b 10                	mov    (%eax),%edx
  80084d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800852:	8d 40 04             	lea    0x4(%eax),%eax
  800855:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800858:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80085d:	eb 28                	jmp    800887 <vprintfmt+0x3a8>
			putch('0', putdat);
  80085f:	83 ec 08             	sub    $0x8,%esp
  800862:	53                   	push   %ebx
  800863:	6a 30                	push   $0x30
  800865:	ff d6                	call   *%esi
			putch('x', putdat);
  800867:	83 c4 08             	add    $0x8,%esp
  80086a:	53                   	push   %ebx
  80086b:	6a 78                	push   $0x78
  80086d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80086f:	8b 45 14             	mov    0x14(%ebp),%eax
  800872:	8b 10                	mov    (%eax),%edx
  800874:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800879:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80087c:	8d 40 04             	lea    0x4(%eax),%eax
  80087f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800882:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800887:	83 ec 0c             	sub    $0xc,%esp
  80088a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80088e:	50                   	push   %eax
  80088f:	ff 75 e0             	push   -0x20(%ebp)
  800892:	57                   	push   %edi
  800893:	51                   	push   %ecx
  800894:	52                   	push   %edx
  800895:	89 da                	mov    %ebx,%edx
  800897:	89 f0                	mov    %esi,%eax
  800899:	e8 5e fb ff ff       	call   8003fc <printnum>
			break;
  80089e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8008a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008a4:	e9 54 fc ff ff       	jmp    8004fd <vprintfmt+0x1e>
	if (lflag >= 2)
  8008a9:	83 f9 01             	cmp    $0x1,%ecx
  8008ac:	7f 1b                	jg     8008c9 <vprintfmt+0x3ea>
	else if (lflag)
  8008ae:	85 c9                	test   %ecx,%ecx
  8008b0:	74 2c                	je     8008de <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	8b 10                	mov    (%eax),%edx
  8008b7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008bc:	8d 40 04             	lea    0x4(%eax),%eax
  8008bf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008c2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8008c7:	eb be                	jmp    800887 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8008c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cc:	8b 10                	mov    (%eax),%edx
  8008ce:	8b 48 04             	mov    0x4(%eax),%ecx
  8008d1:	8d 40 08             	lea    0x8(%eax),%eax
  8008d4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008d7:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8008dc:	eb a9                	jmp    800887 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8008de:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e1:	8b 10                	mov    (%eax),%edx
  8008e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008e8:	8d 40 04             	lea    0x4(%eax),%eax
  8008eb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008ee:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8008f3:	eb 92                	jmp    800887 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8008f5:	83 ec 08             	sub    $0x8,%esp
  8008f8:	53                   	push   %ebx
  8008f9:	6a 25                	push   $0x25
  8008fb:	ff d6                	call   *%esi
			break;
  8008fd:	83 c4 10             	add    $0x10,%esp
  800900:	eb 9f                	jmp    8008a1 <vprintfmt+0x3c2>
			putch('%', putdat);
  800902:	83 ec 08             	sub    $0x8,%esp
  800905:	53                   	push   %ebx
  800906:	6a 25                	push   $0x25
  800908:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80090a:	83 c4 10             	add    $0x10,%esp
  80090d:	89 f8                	mov    %edi,%eax
  80090f:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800913:	74 05                	je     80091a <vprintfmt+0x43b>
  800915:	83 e8 01             	sub    $0x1,%eax
  800918:	eb f5                	jmp    80090f <vprintfmt+0x430>
  80091a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80091d:	eb 82                	jmp    8008a1 <vprintfmt+0x3c2>

0080091f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	83 ec 18             	sub    $0x18,%esp
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80092b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80092e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800932:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800935:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80093c:	85 c0                	test   %eax,%eax
  80093e:	74 26                	je     800966 <vsnprintf+0x47>
  800940:	85 d2                	test   %edx,%edx
  800942:	7e 22                	jle    800966 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800944:	ff 75 14             	push   0x14(%ebp)
  800947:	ff 75 10             	push   0x10(%ebp)
  80094a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80094d:	50                   	push   %eax
  80094e:	68 a5 04 80 00       	push   $0x8004a5
  800953:	e8 87 fb ff ff       	call   8004df <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800958:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80095b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80095e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800961:	83 c4 10             	add    $0x10,%esp
}
  800964:	c9                   	leave  
  800965:	c3                   	ret    
		return -E_INVAL;
  800966:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80096b:	eb f7                	jmp    800964 <vsnprintf+0x45>

0080096d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80096d:	55                   	push   %ebp
  80096e:	89 e5                	mov    %esp,%ebp
  800970:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800973:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800976:	50                   	push   %eax
  800977:	ff 75 10             	push   0x10(%ebp)
  80097a:	ff 75 0c             	push   0xc(%ebp)
  80097d:	ff 75 08             	push   0x8(%ebp)
  800980:	e8 9a ff ff ff       	call   80091f <vsnprintf>
	va_end(ap);

	return rc;
}
  800985:	c9                   	leave  
  800986:	c3                   	ret    

00800987 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80098d:	b8 00 00 00 00       	mov    $0x0,%eax
  800992:	eb 03                	jmp    800997 <strlen+0x10>
		n++;
  800994:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800997:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80099b:	75 f7                	jne    800994 <strlen+0xd>
	return n;
}
  80099d:	5d                   	pop    %ebp
  80099e:	c3                   	ret    

0080099f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80099f:	55                   	push   %ebp
  8009a0:	89 e5                	mov    %esp,%ebp
  8009a2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ad:	eb 03                	jmp    8009b2 <strnlen+0x13>
		n++;
  8009af:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009b2:	39 d0                	cmp    %edx,%eax
  8009b4:	74 08                	je     8009be <strnlen+0x1f>
  8009b6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009ba:	75 f3                	jne    8009af <strnlen+0x10>
  8009bc:	89 c2                	mov    %eax,%edx
	return n;
}
  8009be:	89 d0                	mov    %edx,%eax
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	53                   	push   %ebx
  8009c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8009d5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8009d8:	83 c0 01             	add    $0x1,%eax
  8009db:	84 d2                	test   %dl,%dl
  8009dd:	75 f2                	jne    8009d1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009df:	89 c8                	mov    %ecx,%eax
  8009e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e4:	c9                   	leave  
  8009e5:	c3                   	ret    

008009e6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	53                   	push   %ebx
  8009ea:	83 ec 10             	sub    $0x10,%esp
  8009ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009f0:	53                   	push   %ebx
  8009f1:	e8 91 ff ff ff       	call   800987 <strlen>
  8009f6:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8009f9:	ff 75 0c             	push   0xc(%ebp)
  8009fc:	01 d8                	add    %ebx,%eax
  8009fe:	50                   	push   %eax
  8009ff:	e8 be ff ff ff       	call   8009c2 <strcpy>
	return dst;
}
  800a04:	89 d8                	mov    %ebx,%eax
  800a06:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a09:	c9                   	leave  
  800a0a:	c3                   	ret    

00800a0b <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	56                   	push   %esi
  800a0f:	53                   	push   %ebx
  800a10:	8b 75 08             	mov    0x8(%ebp),%esi
  800a13:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a16:	89 f3                	mov    %esi,%ebx
  800a18:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a1b:	89 f0                	mov    %esi,%eax
  800a1d:	eb 0f                	jmp    800a2e <strncpy+0x23>
		*dst++ = *src;
  800a1f:	83 c0 01             	add    $0x1,%eax
  800a22:	0f b6 0a             	movzbl (%edx),%ecx
  800a25:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a28:	80 f9 01             	cmp    $0x1,%cl
  800a2b:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800a2e:	39 d8                	cmp    %ebx,%eax
  800a30:	75 ed                	jne    800a1f <strncpy+0x14>
	}
	return ret;
}
  800a32:	89 f0                	mov    %esi,%eax
  800a34:	5b                   	pop    %ebx
  800a35:	5e                   	pop    %esi
  800a36:	5d                   	pop    %ebp
  800a37:	c3                   	ret    

00800a38 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a38:	55                   	push   %ebp
  800a39:	89 e5                	mov    %esp,%ebp
  800a3b:	56                   	push   %esi
  800a3c:	53                   	push   %ebx
  800a3d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a43:	8b 55 10             	mov    0x10(%ebp),%edx
  800a46:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a48:	85 d2                	test   %edx,%edx
  800a4a:	74 21                	je     800a6d <strlcpy+0x35>
  800a4c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a50:	89 f2                	mov    %esi,%edx
  800a52:	eb 09                	jmp    800a5d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a54:	83 c1 01             	add    $0x1,%ecx
  800a57:	83 c2 01             	add    $0x1,%edx
  800a5a:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800a5d:	39 c2                	cmp    %eax,%edx
  800a5f:	74 09                	je     800a6a <strlcpy+0x32>
  800a61:	0f b6 19             	movzbl (%ecx),%ebx
  800a64:	84 db                	test   %bl,%bl
  800a66:	75 ec                	jne    800a54 <strlcpy+0x1c>
  800a68:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a6a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a6d:	29 f0                	sub    %esi,%eax
}
  800a6f:	5b                   	pop    %ebx
  800a70:	5e                   	pop    %esi
  800a71:	5d                   	pop    %ebp
  800a72:	c3                   	ret    

00800a73 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a73:	55                   	push   %ebp
  800a74:	89 e5                	mov    %esp,%ebp
  800a76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a79:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a7c:	eb 06                	jmp    800a84 <strcmp+0x11>
		p++, q++;
  800a7e:	83 c1 01             	add    $0x1,%ecx
  800a81:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a84:	0f b6 01             	movzbl (%ecx),%eax
  800a87:	84 c0                	test   %al,%al
  800a89:	74 04                	je     800a8f <strcmp+0x1c>
  800a8b:	3a 02                	cmp    (%edx),%al
  800a8d:	74 ef                	je     800a7e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a8f:	0f b6 c0             	movzbl %al,%eax
  800a92:	0f b6 12             	movzbl (%edx),%edx
  800a95:	29 d0                	sub    %edx,%eax
}
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	53                   	push   %ebx
  800a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa0:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa3:	89 c3                	mov    %eax,%ebx
  800aa5:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800aa8:	eb 06                	jmp    800ab0 <strncmp+0x17>
		n--, p++, q++;
  800aaa:	83 c0 01             	add    $0x1,%eax
  800aad:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800ab0:	39 d8                	cmp    %ebx,%eax
  800ab2:	74 18                	je     800acc <strncmp+0x33>
  800ab4:	0f b6 08             	movzbl (%eax),%ecx
  800ab7:	84 c9                	test   %cl,%cl
  800ab9:	74 04                	je     800abf <strncmp+0x26>
  800abb:	3a 0a                	cmp    (%edx),%cl
  800abd:	74 eb                	je     800aaa <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800abf:	0f b6 00             	movzbl (%eax),%eax
  800ac2:	0f b6 12             	movzbl (%edx),%edx
  800ac5:	29 d0                	sub    %edx,%eax
}
  800ac7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aca:	c9                   	leave  
  800acb:	c3                   	ret    
		return 0;
  800acc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad1:	eb f4                	jmp    800ac7 <strncmp+0x2e>

00800ad3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad3:	55                   	push   %ebp
  800ad4:	89 e5                	mov    %esp,%ebp
  800ad6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800add:	eb 03                	jmp    800ae2 <strchr+0xf>
  800adf:	83 c0 01             	add    $0x1,%eax
  800ae2:	0f b6 10             	movzbl (%eax),%edx
  800ae5:	84 d2                	test   %dl,%dl
  800ae7:	74 06                	je     800aef <strchr+0x1c>
		if (*s == c)
  800ae9:	38 ca                	cmp    %cl,%dl
  800aeb:	75 f2                	jne    800adf <strchr+0xc>
  800aed:	eb 05                	jmp    800af4 <strchr+0x21>
			return (char *) s;
	return 0;
  800aef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	8b 45 08             	mov    0x8(%ebp),%eax
  800afc:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b00:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b03:	38 ca                	cmp    %cl,%dl
  800b05:	74 09                	je     800b10 <strfind+0x1a>
  800b07:	84 d2                	test   %dl,%dl
  800b09:	74 05                	je     800b10 <strfind+0x1a>
	for (; *s; s++)
  800b0b:	83 c0 01             	add    $0x1,%eax
  800b0e:	eb f0                	jmp    800b00 <strfind+0xa>
			break;
	return (char *) s;
}
  800b10:	5d                   	pop    %ebp
  800b11:	c3                   	ret    

00800b12 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b12:	55                   	push   %ebp
  800b13:	89 e5                	mov    %esp,%ebp
  800b15:	57                   	push   %edi
  800b16:	56                   	push   %esi
  800b17:	53                   	push   %ebx
  800b18:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b1e:	85 c9                	test   %ecx,%ecx
  800b20:	74 2f                	je     800b51 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b22:	89 f8                	mov    %edi,%eax
  800b24:	09 c8                	or     %ecx,%eax
  800b26:	a8 03                	test   $0x3,%al
  800b28:	75 21                	jne    800b4b <memset+0x39>
		c &= 0xFF;
  800b2a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b2e:	89 d0                	mov    %edx,%eax
  800b30:	c1 e0 08             	shl    $0x8,%eax
  800b33:	89 d3                	mov    %edx,%ebx
  800b35:	c1 e3 18             	shl    $0x18,%ebx
  800b38:	89 d6                	mov    %edx,%esi
  800b3a:	c1 e6 10             	shl    $0x10,%esi
  800b3d:	09 f3                	or     %esi,%ebx
  800b3f:	09 da                	or     %ebx,%edx
  800b41:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b43:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b46:	fc                   	cld    
  800b47:	f3 ab                	rep stos %eax,%es:(%edi)
  800b49:	eb 06                	jmp    800b51 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4e:	fc                   	cld    
  800b4f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b51:	89 f8                	mov    %edi,%eax
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b60:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b63:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b66:	39 c6                	cmp    %eax,%esi
  800b68:	73 32                	jae    800b9c <memmove+0x44>
  800b6a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b6d:	39 c2                	cmp    %eax,%edx
  800b6f:	76 2b                	jbe    800b9c <memmove+0x44>
		s += n;
		d += n;
  800b71:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b74:	89 d6                	mov    %edx,%esi
  800b76:	09 fe                	or     %edi,%esi
  800b78:	09 ce                	or     %ecx,%esi
  800b7a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b80:	75 0e                	jne    800b90 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b82:	83 ef 04             	sub    $0x4,%edi
  800b85:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b88:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b8b:	fd                   	std    
  800b8c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b8e:	eb 09                	jmp    800b99 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b90:	83 ef 01             	sub    $0x1,%edi
  800b93:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b96:	fd                   	std    
  800b97:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b99:	fc                   	cld    
  800b9a:	eb 1a                	jmp    800bb6 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b9c:	89 f2                	mov    %esi,%edx
  800b9e:	09 c2                	or     %eax,%edx
  800ba0:	09 ca                	or     %ecx,%edx
  800ba2:	f6 c2 03             	test   $0x3,%dl
  800ba5:	75 0a                	jne    800bb1 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ba7:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800baa:	89 c7                	mov    %eax,%edi
  800bac:	fc                   	cld    
  800bad:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800baf:	eb 05                	jmp    800bb6 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800bb1:	89 c7                	mov    %eax,%edi
  800bb3:	fc                   	cld    
  800bb4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bb6:	5e                   	pop    %esi
  800bb7:	5f                   	pop    %edi
  800bb8:	5d                   	pop    %ebp
  800bb9:	c3                   	ret    

00800bba <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bba:	55                   	push   %ebp
  800bbb:	89 e5                	mov    %esp,%ebp
  800bbd:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bc0:	ff 75 10             	push   0x10(%ebp)
  800bc3:	ff 75 0c             	push   0xc(%ebp)
  800bc6:	ff 75 08             	push   0x8(%ebp)
  800bc9:	e8 8a ff ff ff       	call   800b58 <memmove>
}
  800bce:	c9                   	leave  
  800bcf:	c3                   	ret    

00800bd0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	56                   	push   %esi
  800bd4:	53                   	push   %ebx
  800bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bdb:	89 c6                	mov    %eax,%esi
  800bdd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be0:	eb 06                	jmp    800be8 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800be2:	83 c0 01             	add    $0x1,%eax
  800be5:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800be8:	39 f0                	cmp    %esi,%eax
  800bea:	74 14                	je     800c00 <memcmp+0x30>
		if (*s1 != *s2)
  800bec:	0f b6 08             	movzbl (%eax),%ecx
  800bef:	0f b6 1a             	movzbl (%edx),%ebx
  800bf2:	38 d9                	cmp    %bl,%cl
  800bf4:	74 ec                	je     800be2 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800bf6:	0f b6 c1             	movzbl %cl,%eax
  800bf9:	0f b6 db             	movzbl %bl,%ebx
  800bfc:	29 d8                	sub    %ebx,%eax
  800bfe:	eb 05                	jmp    800c05 <memcmp+0x35>
	}

	return 0;
  800c00:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5d                   	pop    %ebp
  800c08:	c3                   	ret    

00800c09 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c12:	89 c2                	mov    %eax,%edx
  800c14:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c17:	eb 03                	jmp    800c1c <memfind+0x13>
  800c19:	83 c0 01             	add    $0x1,%eax
  800c1c:	39 d0                	cmp    %edx,%eax
  800c1e:	73 04                	jae    800c24 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c20:	38 08                	cmp    %cl,(%eax)
  800c22:	75 f5                	jne    800c19 <memfind+0x10>
			break;
	return (void *) s;
}
  800c24:	5d                   	pop    %ebp
  800c25:	c3                   	ret    

00800c26 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c26:	55                   	push   %ebp
  800c27:	89 e5                	mov    %esp,%ebp
  800c29:	57                   	push   %edi
  800c2a:	56                   	push   %esi
  800c2b:	53                   	push   %ebx
  800c2c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c32:	eb 03                	jmp    800c37 <strtol+0x11>
		s++;
  800c34:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800c37:	0f b6 02             	movzbl (%edx),%eax
  800c3a:	3c 20                	cmp    $0x20,%al
  800c3c:	74 f6                	je     800c34 <strtol+0xe>
  800c3e:	3c 09                	cmp    $0x9,%al
  800c40:	74 f2                	je     800c34 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c42:	3c 2b                	cmp    $0x2b,%al
  800c44:	74 2a                	je     800c70 <strtol+0x4a>
	int neg = 0;
  800c46:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c4b:	3c 2d                	cmp    $0x2d,%al
  800c4d:	74 2b                	je     800c7a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c4f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c55:	75 0f                	jne    800c66 <strtol+0x40>
  800c57:	80 3a 30             	cmpb   $0x30,(%edx)
  800c5a:	74 28                	je     800c84 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c5c:	85 db                	test   %ebx,%ebx
  800c5e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c63:	0f 44 d8             	cmove  %eax,%ebx
  800c66:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c6b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c6e:	eb 46                	jmp    800cb6 <strtol+0x90>
		s++;
  800c70:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800c73:	bf 00 00 00 00       	mov    $0x0,%edi
  800c78:	eb d5                	jmp    800c4f <strtol+0x29>
		s++, neg = 1;
  800c7a:	83 c2 01             	add    $0x1,%edx
  800c7d:	bf 01 00 00 00       	mov    $0x1,%edi
  800c82:	eb cb                	jmp    800c4f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c84:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c88:	74 0e                	je     800c98 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800c8a:	85 db                	test   %ebx,%ebx
  800c8c:	75 d8                	jne    800c66 <strtol+0x40>
		s++, base = 8;
  800c8e:	83 c2 01             	add    $0x1,%edx
  800c91:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c96:	eb ce                	jmp    800c66 <strtol+0x40>
		s += 2, base = 16;
  800c98:	83 c2 02             	add    $0x2,%edx
  800c9b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ca0:	eb c4                	jmp    800c66 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ca2:	0f be c0             	movsbl %al,%eax
  800ca5:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ca8:	3b 45 10             	cmp    0x10(%ebp),%eax
  800cab:	7d 3a                	jge    800ce7 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800cad:	83 c2 01             	add    $0x1,%edx
  800cb0:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800cb4:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800cb6:	0f b6 02             	movzbl (%edx),%eax
  800cb9:	8d 70 d0             	lea    -0x30(%eax),%esi
  800cbc:	89 f3                	mov    %esi,%ebx
  800cbe:	80 fb 09             	cmp    $0x9,%bl
  800cc1:	76 df                	jbe    800ca2 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800cc3:	8d 70 9f             	lea    -0x61(%eax),%esi
  800cc6:	89 f3                	mov    %esi,%ebx
  800cc8:	80 fb 19             	cmp    $0x19,%bl
  800ccb:	77 08                	ja     800cd5 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800ccd:	0f be c0             	movsbl %al,%eax
  800cd0:	83 e8 57             	sub    $0x57,%eax
  800cd3:	eb d3                	jmp    800ca8 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800cd5:	8d 70 bf             	lea    -0x41(%eax),%esi
  800cd8:	89 f3                	mov    %esi,%ebx
  800cda:	80 fb 19             	cmp    $0x19,%bl
  800cdd:	77 08                	ja     800ce7 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800cdf:	0f be c0             	movsbl %al,%eax
  800ce2:	83 e8 37             	sub    $0x37,%eax
  800ce5:	eb c1                	jmp    800ca8 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ce7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ceb:	74 05                	je     800cf2 <strtol+0xcc>
		*endptr = (char *) s;
  800ced:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf0:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800cf2:	89 c8                	mov    %ecx,%eax
  800cf4:	f7 d8                	neg    %eax
  800cf6:	85 ff                	test   %edi,%edi
  800cf8:	0f 45 c8             	cmovne %eax,%ecx
}
  800cfb:	89 c8                	mov    %ecx,%eax
  800cfd:	5b                   	pop    %ebx
  800cfe:	5e                   	pop    %esi
  800cff:	5f                   	pop    %edi
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    
  800d02:	66 90                	xchg   %ax,%ax
  800d04:	66 90                	xchg   %ax,%ax
  800d06:	66 90                	xchg   %ax,%ax
  800d08:	66 90                	xchg   %ax,%ax
  800d0a:	66 90                	xchg   %ax,%ax
  800d0c:	66 90                	xchg   %ax,%ax
  800d0e:	66 90                	xchg   %ax,%ax

00800d10 <__udivdi3>:
  800d10:	f3 0f 1e fb          	endbr32 
  800d14:	55                   	push   %ebp
  800d15:	57                   	push   %edi
  800d16:	56                   	push   %esi
  800d17:	53                   	push   %ebx
  800d18:	83 ec 1c             	sub    $0x1c,%esp
  800d1b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800d1f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d23:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d27:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	75 19                	jne    800d48 <__udivdi3+0x38>
  800d2f:	39 f3                	cmp    %esi,%ebx
  800d31:	76 4d                	jbe    800d80 <__udivdi3+0x70>
  800d33:	31 ff                	xor    %edi,%edi
  800d35:	89 e8                	mov    %ebp,%eax
  800d37:	89 f2                	mov    %esi,%edx
  800d39:	f7 f3                	div    %ebx
  800d3b:	89 fa                	mov    %edi,%edx
  800d3d:	83 c4 1c             	add    $0x1c,%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    
  800d45:	8d 76 00             	lea    0x0(%esi),%esi
  800d48:	39 f0                	cmp    %esi,%eax
  800d4a:	76 14                	jbe    800d60 <__udivdi3+0x50>
  800d4c:	31 ff                	xor    %edi,%edi
  800d4e:	31 c0                	xor    %eax,%eax
  800d50:	89 fa                	mov    %edi,%edx
  800d52:	83 c4 1c             	add    $0x1c,%esp
  800d55:	5b                   	pop    %ebx
  800d56:	5e                   	pop    %esi
  800d57:	5f                   	pop    %edi
  800d58:	5d                   	pop    %ebp
  800d59:	c3                   	ret    
  800d5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d60:	0f bd f8             	bsr    %eax,%edi
  800d63:	83 f7 1f             	xor    $0x1f,%edi
  800d66:	75 48                	jne    800db0 <__udivdi3+0xa0>
  800d68:	39 f0                	cmp    %esi,%eax
  800d6a:	72 06                	jb     800d72 <__udivdi3+0x62>
  800d6c:	31 c0                	xor    %eax,%eax
  800d6e:	39 eb                	cmp    %ebp,%ebx
  800d70:	77 de                	ja     800d50 <__udivdi3+0x40>
  800d72:	b8 01 00 00 00       	mov    $0x1,%eax
  800d77:	eb d7                	jmp    800d50 <__udivdi3+0x40>
  800d79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d80:	89 d9                	mov    %ebx,%ecx
  800d82:	85 db                	test   %ebx,%ebx
  800d84:	75 0b                	jne    800d91 <__udivdi3+0x81>
  800d86:	b8 01 00 00 00       	mov    $0x1,%eax
  800d8b:	31 d2                	xor    %edx,%edx
  800d8d:	f7 f3                	div    %ebx
  800d8f:	89 c1                	mov    %eax,%ecx
  800d91:	31 d2                	xor    %edx,%edx
  800d93:	89 f0                	mov    %esi,%eax
  800d95:	f7 f1                	div    %ecx
  800d97:	89 c6                	mov    %eax,%esi
  800d99:	89 e8                	mov    %ebp,%eax
  800d9b:	89 f7                	mov    %esi,%edi
  800d9d:	f7 f1                	div    %ecx
  800d9f:	89 fa                	mov    %edi,%edx
  800da1:	83 c4 1c             	add    $0x1c,%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    
  800da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800db0:	89 f9                	mov    %edi,%ecx
  800db2:	ba 20 00 00 00       	mov    $0x20,%edx
  800db7:	29 fa                	sub    %edi,%edx
  800db9:	d3 e0                	shl    %cl,%eax
  800dbb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dbf:	89 d1                	mov    %edx,%ecx
  800dc1:	89 d8                	mov    %ebx,%eax
  800dc3:	d3 e8                	shr    %cl,%eax
  800dc5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800dc9:	09 c1                	or     %eax,%ecx
  800dcb:	89 f0                	mov    %esi,%eax
  800dcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dd1:	89 f9                	mov    %edi,%ecx
  800dd3:	d3 e3                	shl    %cl,%ebx
  800dd5:	89 d1                	mov    %edx,%ecx
  800dd7:	d3 e8                	shr    %cl,%eax
  800dd9:	89 f9                	mov    %edi,%ecx
  800ddb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800ddf:	89 eb                	mov    %ebp,%ebx
  800de1:	d3 e6                	shl    %cl,%esi
  800de3:	89 d1                	mov    %edx,%ecx
  800de5:	d3 eb                	shr    %cl,%ebx
  800de7:	09 f3                	or     %esi,%ebx
  800de9:	89 c6                	mov    %eax,%esi
  800deb:	89 f2                	mov    %esi,%edx
  800ded:	89 d8                	mov    %ebx,%eax
  800def:	f7 74 24 08          	divl   0x8(%esp)
  800df3:	89 d6                	mov    %edx,%esi
  800df5:	89 c3                	mov    %eax,%ebx
  800df7:	f7 64 24 0c          	mull   0xc(%esp)
  800dfb:	39 d6                	cmp    %edx,%esi
  800dfd:	72 19                	jb     800e18 <__udivdi3+0x108>
  800dff:	89 f9                	mov    %edi,%ecx
  800e01:	d3 e5                	shl    %cl,%ebp
  800e03:	39 c5                	cmp    %eax,%ebp
  800e05:	73 04                	jae    800e0b <__udivdi3+0xfb>
  800e07:	39 d6                	cmp    %edx,%esi
  800e09:	74 0d                	je     800e18 <__udivdi3+0x108>
  800e0b:	89 d8                	mov    %ebx,%eax
  800e0d:	31 ff                	xor    %edi,%edi
  800e0f:	e9 3c ff ff ff       	jmp    800d50 <__udivdi3+0x40>
  800e14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e18:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e1b:	31 ff                	xor    %edi,%edi
  800e1d:	e9 2e ff ff ff       	jmp    800d50 <__udivdi3+0x40>
  800e22:	66 90                	xchg   %ax,%ax
  800e24:	66 90                	xchg   %ax,%ax
  800e26:	66 90                	xchg   %ax,%ax
  800e28:	66 90                	xchg   %ax,%ax
  800e2a:	66 90                	xchg   %ax,%ax
  800e2c:	66 90                	xchg   %ax,%ax
  800e2e:	66 90                	xchg   %ax,%ax

00800e30 <__umoddi3>:
  800e30:	f3 0f 1e fb          	endbr32 
  800e34:	55                   	push   %ebp
  800e35:	57                   	push   %edi
  800e36:	56                   	push   %esi
  800e37:	53                   	push   %ebx
  800e38:	83 ec 1c             	sub    $0x1c,%esp
  800e3b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e43:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800e47:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800e4b:	89 f0                	mov    %esi,%eax
  800e4d:	89 da                	mov    %ebx,%edx
  800e4f:	85 ff                	test   %edi,%edi
  800e51:	75 15                	jne    800e68 <__umoddi3+0x38>
  800e53:	39 dd                	cmp    %ebx,%ebp
  800e55:	76 39                	jbe    800e90 <__umoddi3+0x60>
  800e57:	f7 f5                	div    %ebp
  800e59:	89 d0                	mov    %edx,%eax
  800e5b:	31 d2                	xor    %edx,%edx
  800e5d:	83 c4 1c             	add    $0x1c,%esp
  800e60:	5b                   	pop    %ebx
  800e61:	5e                   	pop    %esi
  800e62:	5f                   	pop    %edi
  800e63:	5d                   	pop    %ebp
  800e64:	c3                   	ret    
  800e65:	8d 76 00             	lea    0x0(%esi),%esi
  800e68:	39 df                	cmp    %ebx,%edi
  800e6a:	77 f1                	ja     800e5d <__umoddi3+0x2d>
  800e6c:	0f bd cf             	bsr    %edi,%ecx
  800e6f:	83 f1 1f             	xor    $0x1f,%ecx
  800e72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e76:	75 40                	jne    800eb8 <__umoddi3+0x88>
  800e78:	39 df                	cmp    %ebx,%edi
  800e7a:	72 04                	jb     800e80 <__umoddi3+0x50>
  800e7c:	39 f5                	cmp    %esi,%ebp
  800e7e:	77 dd                	ja     800e5d <__umoddi3+0x2d>
  800e80:	89 da                	mov    %ebx,%edx
  800e82:	89 f0                	mov    %esi,%eax
  800e84:	29 e8                	sub    %ebp,%eax
  800e86:	19 fa                	sbb    %edi,%edx
  800e88:	eb d3                	jmp    800e5d <__umoddi3+0x2d>
  800e8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e90:	89 e9                	mov    %ebp,%ecx
  800e92:	85 ed                	test   %ebp,%ebp
  800e94:	75 0b                	jne    800ea1 <__umoddi3+0x71>
  800e96:	b8 01 00 00 00       	mov    $0x1,%eax
  800e9b:	31 d2                	xor    %edx,%edx
  800e9d:	f7 f5                	div    %ebp
  800e9f:	89 c1                	mov    %eax,%ecx
  800ea1:	89 d8                	mov    %ebx,%eax
  800ea3:	31 d2                	xor    %edx,%edx
  800ea5:	f7 f1                	div    %ecx
  800ea7:	89 f0                	mov    %esi,%eax
  800ea9:	f7 f1                	div    %ecx
  800eab:	89 d0                	mov    %edx,%eax
  800ead:	31 d2                	xor    %edx,%edx
  800eaf:	eb ac                	jmp    800e5d <__umoddi3+0x2d>
  800eb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ebc:	ba 20 00 00 00       	mov    $0x20,%edx
  800ec1:	29 c2                	sub    %eax,%edx
  800ec3:	89 c1                	mov    %eax,%ecx
  800ec5:	89 e8                	mov    %ebp,%eax
  800ec7:	d3 e7                	shl    %cl,%edi
  800ec9:	89 d1                	mov    %edx,%ecx
  800ecb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ecf:	d3 e8                	shr    %cl,%eax
  800ed1:	89 c1                	mov    %eax,%ecx
  800ed3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ed7:	09 f9                	or     %edi,%ecx
  800ed9:	89 df                	mov    %ebx,%edi
  800edb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800edf:	89 c1                	mov    %eax,%ecx
  800ee1:	d3 e5                	shl    %cl,%ebp
  800ee3:	89 d1                	mov    %edx,%ecx
  800ee5:	d3 ef                	shr    %cl,%edi
  800ee7:	89 c1                	mov    %eax,%ecx
  800ee9:	89 f0                	mov    %esi,%eax
  800eeb:	d3 e3                	shl    %cl,%ebx
  800eed:	89 d1                	mov    %edx,%ecx
  800eef:	89 fa                	mov    %edi,%edx
  800ef1:	d3 e8                	shr    %cl,%eax
  800ef3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ef8:	09 d8                	or     %ebx,%eax
  800efa:	f7 74 24 08          	divl   0x8(%esp)
  800efe:	89 d3                	mov    %edx,%ebx
  800f00:	d3 e6                	shl    %cl,%esi
  800f02:	f7 e5                	mul    %ebp
  800f04:	89 c7                	mov    %eax,%edi
  800f06:	89 d1                	mov    %edx,%ecx
  800f08:	39 d3                	cmp    %edx,%ebx
  800f0a:	72 06                	jb     800f12 <__umoddi3+0xe2>
  800f0c:	75 0e                	jne    800f1c <__umoddi3+0xec>
  800f0e:	39 c6                	cmp    %eax,%esi
  800f10:	73 0a                	jae    800f1c <__umoddi3+0xec>
  800f12:	29 e8                	sub    %ebp,%eax
  800f14:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800f18:	89 d1                	mov    %edx,%ecx
  800f1a:	89 c7                	mov    %eax,%edi
  800f1c:	89 f5                	mov    %esi,%ebp
  800f1e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f22:	29 fd                	sub    %edi,%ebp
  800f24:	19 cb                	sbb    %ecx,%ebx
  800f26:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f2b:	89 d8                	mov    %ebx,%eax
  800f2d:	d3 e0                	shl    %cl,%eax
  800f2f:	89 f1                	mov    %esi,%ecx
  800f31:	d3 ed                	shr    %cl,%ebp
  800f33:	d3 eb                	shr    %cl,%ebx
  800f35:	09 e8                	or     %ebp,%eax
  800f37:	89 da                	mov    %ebx,%edx
  800f39:	83 c4 1c             	add    $0x1c,%esp
  800f3c:	5b                   	pop    %ebx
  800f3d:	5e                   	pop    %esi
  800f3e:	5f                   	pop    %edi
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    
