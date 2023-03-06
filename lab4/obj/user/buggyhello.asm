
obj/user/buggyhello：     文件格式 elf32-i386


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
  80003d:	e8 5d 00 00 00       	call   80009f <sys_cputs>
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
  800052:	e8 c6 00 00 00       	call   80011d <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800093:	6a 00                	push   $0x0
  800095:	e8 42 00 00 00       	call   8000dc <sys_env_destroy>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	c9                   	leave  
  80009e:	c3                   	ret    

0080009f <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009f:	55                   	push   %ebp
  8000a0:	89 e5                	mov    %esp,%ebp
  8000a2:	57                   	push   %edi
  8000a3:	56                   	push   %esi
  8000a4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8000aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	89 c3                	mov    %eax,%ebx
  8000b2:	89 c7                	mov    %eax,%edi
  8000b4:	89 c6                	mov    %eax,%esi
  8000b6:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b8:	5b                   	pop    %ebx
  8000b9:	5e                   	pop    %esi
  8000ba:	5f                   	pop    %edi
  8000bb:	5d                   	pop    %ebp
  8000bc:	c3                   	ret    

008000bd <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	57                   	push   %edi
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c8:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cd:	89 d1                	mov    %edx,%ecx
  8000cf:	89 d3                	mov    %edx,%ebx
  8000d1:	89 d7                	mov    %edx,%edi
  8000d3:	89 d6                	mov    %edx,%esi
  8000d5:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d7:	5b                   	pop    %ebx
  8000d8:	5e                   	pop    %esi
  8000d9:	5f                   	pop    %edi
  8000da:	5d                   	pop    %ebp
  8000db:	c3                   	ret    

008000dc <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000dc:	55                   	push   %ebp
  8000dd:	89 e5                	mov    %esp,%ebp
  8000df:	57                   	push   %edi
  8000e0:	56                   	push   %esi
  8000e1:	53                   	push   %ebx
  8000e2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ea:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	89 cb                	mov    %ecx,%ebx
  8000f4:	89 cf                	mov    %ecx,%edi
  8000f6:	89 ce                	mov    %ecx,%esi
  8000f8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	7f 08                	jg     800106 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800101:	5b                   	pop    %ebx
  800102:	5e                   	pop    %esi
  800103:	5f                   	pop    %edi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	6a 03                	push   $0x3
  80010c:	68 4a 0f 80 00       	push   $0x800f4a
  800111:	6a 2a                	push   $0x2a
  800113:	68 67 0f 80 00       	push   $0x800f67
  800118:	e8 ed 01 00 00       	call   80030a <_panic>

0080011d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	57                   	push   %edi
  800121:	56                   	push   %esi
  800122:	53                   	push   %ebx
	asm volatile("int %1\n"
  800123:	ba 00 00 00 00       	mov    $0x0,%edx
  800128:	b8 02 00 00 00       	mov    $0x2,%eax
  80012d:	89 d1                	mov    %edx,%ecx
  80012f:	89 d3                	mov    %edx,%ebx
  800131:	89 d7                	mov    %edx,%edi
  800133:	89 d6                	mov    %edx,%esi
  800135:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800137:	5b                   	pop    %ebx
  800138:	5e                   	pop    %esi
  800139:	5f                   	pop    %edi
  80013a:	5d                   	pop    %ebp
  80013b:	c3                   	ret    

0080013c <sys_yield>:

void
sys_yield(void)
{
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	57                   	push   %edi
  800140:	56                   	push   %esi
  800141:	53                   	push   %ebx
	asm volatile("int %1\n"
  800142:	ba 00 00 00 00       	mov    $0x0,%edx
  800147:	b8 0a 00 00 00       	mov    $0xa,%eax
  80014c:	89 d1                	mov    %edx,%ecx
  80014e:	89 d3                	mov    %edx,%ebx
  800150:	89 d7                	mov    %edx,%edi
  800152:	89 d6                	mov    %edx,%esi
  800154:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800156:	5b                   	pop    %ebx
  800157:	5e                   	pop    %esi
  800158:	5f                   	pop    %edi
  800159:	5d                   	pop    %ebp
  80015a:	c3                   	ret    

0080015b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015b:	55                   	push   %ebp
  80015c:	89 e5                	mov    %esp,%ebp
  80015e:	57                   	push   %edi
  80015f:	56                   	push   %esi
  800160:	53                   	push   %ebx
  800161:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800164:	be 00 00 00 00       	mov    $0x0,%esi
  800169:	8b 55 08             	mov    0x8(%ebp),%edx
  80016c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016f:	b8 04 00 00 00       	mov    $0x4,%eax
  800174:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800177:	89 f7                	mov    %esi,%edi
  800179:	cd 30                	int    $0x30
	if(check && ret > 0)
  80017b:	85 c0                	test   %eax,%eax
  80017d:	7f 08                	jg     800187 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80017f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800182:	5b                   	pop    %ebx
  800183:	5e                   	pop    %esi
  800184:	5f                   	pop    %edi
  800185:	5d                   	pop    %ebp
  800186:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	50                   	push   %eax
  80018b:	6a 04                	push   $0x4
  80018d:	68 4a 0f 80 00       	push   $0x800f4a
  800192:	6a 2a                	push   $0x2a
  800194:	68 67 0f 80 00       	push   $0x800f67
  800199:	e8 6c 01 00 00       	call   80030a <_panic>

0080019e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019e:	55                   	push   %ebp
  80019f:	89 e5                	mov    %esp,%ebp
  8001a1:	57                   	push   %edi
  8001a2:	56                   	push   %esi
  8001a3:	53                   	push   %ebx
  8001a4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001aa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ad:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b8:	8b 75 18             	mov    0x18(%ebp),%esi
  8001bb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001bd:	85 c0                	test   %eax,%eax
  8001bf:	7f 08                	jg     8001c9 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c4:	5b                   	pop    %ebx
  8001c5:	5e                   	pop    %esi
  8001c6:	5f                   	pop    %edi
  8001c7:	5d                   	pop    %ebp
  8001c8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 05                	push   $0x5
  8001cf:	68 4a 0f 80 00       	push   $0x800f4a
  8001d4:	6a 2a                	push   $0x2a
  8001d6:	68 67 0f 80 00       	push   $0x800f67
  8001db:	e8 2a 01 00 00       	call   80030a <_panic>

008001e0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e0:	55                   	push   %ebp
  8001e1:	89 e5                	mov    %esp,%ebp
  8001e3:	57                   	push   %edi
  8001e4:	56                   	push   %esi
  8001e5:	53                   	push   %ebx
  8001e6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f4:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f9:	89 df                	mov    %ebx,%edi
  8001fb:	89 de                	mov    %ebx,%esi
  8001fd:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001ff:	85 c0                	test   %eax,%eax
  800201:	7f 08                	jg     80020b <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800203:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800206:	5b                   	pop    %ebx
  800207:	5e                   	pop    %esi
  800208:	5f                   	pop    %edi
  800209:	5d                   	pop    %ebp
  80020a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80020b:	83 ec 0c             	sub    $0xc,%esp
  80020e:	50                   	push   %eax
  80020f:	6a 06                	push   $0x6
  800211:	68 4a 0f 80 00       	push   $0x800f4a
  800216:	6a 2a                	push   $0x2a
  800218:	68 67 0f 80 00       	push   $0x800f67
  80021d:	e8 e8 00 00 00       	call   80030a <_panic>

00800222 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800222:	55                   	push   %ebp
  800223:	89 e5                	mov    %esp,%ebp
  800225:	57                   	push   %edi
  800226:	56                   	push   %esi
  800227:	53                   	push   %ebx
  800228:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80022b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800230:	8b 55 08             	mov    0x8(%ebp),%edx
  800233:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800236:	b8 08 00 00 00       	mov    $0x8,%eax
  80023b:	89 df                	mov    %ebx,%edi
  80023d:	89 de                	mov    %ebx,%esi
  80023f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800241:	85 c0                	test   %eax,%eax
  800243:	7f 08                	jg     80024d <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800245:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800248:	5b                   	pop    %ebx
  800249:	5e                   	pop    %esi
  80024a:	5f                   	pop    %edi
  80024b:	5d                   	pop    %ebp
  80024c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	50                   	push   %eax
  800251:	6a 08                	push   $0x8
  800253:	68 4a 0f 80 00       	push   $0x800f4a
  800258:	6a 2a                	push   $0x2a
  80025a:	68 67 0f 80 00       	push   $0x800f67
  80025f:	e8 a6 00 00 00       	call   80030a <_panic>

00800264 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	57                   	push   %edi
  800268:	56                   	push   %esi
  800269:	53                   	push   %ebx
  80026a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80026d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800272:	8b 55 08             	mov    0x8(%ebp),%edx
  800275:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800278:	b8 09 00 00 00       	mov    $0x9,%eax
  80027d:	89 df                	mov    %ebx,%edi
  80027f:	89 de                	mov    %ebx,%esi
  800281:	cd 30                	int    $0x30
	if(check && ret > 0)
  800283:	85 c0                	test   %eax,%eax
  800285:	7f 08                	jg     80028f <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800287:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80028a:	5b                   	pop    %ebx
  80028b:	5e                   	pop    %esi
  80028c:	5f                   	pop    %edi
  80028d:	5d                   	pop    %ebp
  80028e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 09                	push   $0x9
  800295:	68 4a 0f 80 00       	push   $0x800f4a
  80029a:	6a 2a                	push   $0x2a
  80029c:	68 67 0f 80 00       	push   $0x800f67
  8002a1:	e8 64 00 00 00       	call   80030a <_panic>

008002a6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a6:	55                   	push   %ebp
  8002a7:	89 e5                	mov    %esp,%ebp
  8002a9:	57                   	push   %edi
  8002aa:	56                   	push   %esi
  8002ab:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8002af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b2:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002b7:	be 00 00 00 00       	mov    $0x0,%esi
  8002bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002bf:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c2:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002c4:	5b                   	pop    %ebx
  8002c5:	5e                   	pop    %esi
  8002c6:	5f                   	pop    %edi
  8002c7:	5d                   	pop    %ebp
  8002c8:	c3                   	ret    

008002c9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c9:	55                   	push   %ebp
  8002ca:	89 e5                	mov    %esp,%ebp
  8002cc:	57                   	push   %edi
  8002cd:	56                   	push   %esi
  8002ce:	53                   	push   %ebx
  8002cf:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002da:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002df:	89 cb                	mov    %ecx,%ebx
  8002e1:	89 cf                	mov    %ecx,%edi
  8002e3:	89 ce                	mov    %ecx,%esi
  8002e5:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002e7:	85 c0                	test   %eax,%eax
  8002e9:	7f 08                	jg     8002f3 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ee:	5b                   	pop    %ebx
  8002ef:	5e                   	pop    %esi
  8002f0:	5f                   	pop    %edi
  8002f1:	5d                   	pop    %ebp
  8002f2:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f3:	83 ec 0c             	sub    $0xc,%esp
  8002f6:	50                   	push   %eax
  8002f7:	6a 0c                	push   $0xc
  8002f9:	68 4a 0f 80 00       	push   $0x800f4a
  8002fe:	6a 2a                	push   $0x2a
  800300:	68 67 0f 80 00       	push   $0x800f67
  800305:	e8 00 00 00 00       	call   80030a <_panic>

0080030a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	56                   	push   %esi
  80030e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80030f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800312:	8b 35 00 20 80 00    	mov    0x802000,%esi
  800318:	e8 00 fe ff ff       	call   80011d <sys_getenvid>
  80031d:	83 ec 0c             	sub    $0xc,%esp
  800320:	ff 75 0c             	push   0xc(%ebp)
  800323:	ff 75 08             	push   0x8(%ebp)
  800326:	56                   	push   %esi
  800327:	50                   	push   %eax
  800328:	68 78 0f 80 00       	push   $0x800f78
  80032d:	e8 b3 00 00 00       	call   8003e5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800332:	83 c4 18             	add    $0x18,%esp
  800335:	53                   	push   %ebx
  800336:	ff 75 10             	push   0x10(%ebp)
  800339:	e8 56 00 00 00       	call   800394 <vcprintf>
	cprintf("\n");
  80033e:	c7 04 24 9b 0f 80 00 	movl   $0x800f9b,(%esp)
  800345:	e8 9b 00 00 00       	call   8003e5 <cprintf>
  80034a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80034d:	cc                   	int3   
  80034e:	eb fd                	jmp    80034d <_panic+0x43>

00800350 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800350:	55                   	push   %ebp
  800351:	89 e5                	mov    %esp,%ebp
  800353:	53                   	push   %ebx
  800354:	83 ec 04             	sub    $0x4,%esp
  800357:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80035a:	8b 13                	mov    (%ebx),%edx
  80035c:	8d 42 01             	lea    0x1(%edx),%eax
  80035f:	89 03                	mov    %eax,(%ebx)
  800361:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800364:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800368:	3d ff 00 00 00       	cmp    $0xff,%eax
  80036d:	74 09                	je     800378 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80036f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800373:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800376:	c9                   	leave  
  800377:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800378:	83 ec 08             	sub    $0x8,%esp
  80037b:	68 ff 00 00 00       	push   $0xff
  800380:	8d 43 08             	lea    0x8(%ebx),%eax
  800383:	50                   	push   %eax
  800384:	e8 16 fd ff ff       	call   80009f <sys_cputs>
		b->idx = 0;
  800389:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038f:	83 c4 10             	add    $0x10,%esp
  800392:	eb db                	jmp    80036f <putch+0x1f>

00800394 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80039d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a4:	00 00 00 
	b.cnt = 0;
  8003a7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003ae:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b1:	ff 75 0c             	push   0xc(%ebp)
  8003b4:	ff 75 08             	push   0x8(%ebp)
  8003b7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003bd:	50                   	push   %eax
  8003be:	68 50 03 80 00       	push   $0x800350
  8003c3:	e8 14 01 00 00       	call   8004dc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003c8:	83 c4 08             	add    $0x8,%esp
  8003cb:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8003d1:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003d7:	50                   	push   %eax
  8003d8:	e8 c2 fc ff ff       	call   80009f <sys_cputs>

	return b.cnt;
}
  8003dd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e3:	c9                   	leave  
  8003e4:	c3                   	ret    

008003e5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003eb:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003ee:	50                   	push   %eax
  8003ef:	ff 75 08             	push   0x8(%ebp)
  8003f2:	e8 9d ff ff ff       	call   800394 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003f7:	c9                   	leave  
  8003f8:	c3                   	ret    

008003f9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f9:	55                   	push   %ebp
  8003fa:	89 e5                	mov    %esp,%ebp
  8003fc:	57                   	push   %edi
  8003fd:	56                   	push   %esi
  8003fe:	53                   	push   %ebx
  8003ff:	83 ec 1c             	sub    $0x1c,%esp
  800402:	89 c7                	mov    %eax,%edi
  800404:	89 d6                	mov    %edx,%esi
  800406:	8b 45 08             	mov    0x8(%ebp),%eax
  800409:	8b 55 0c             	mov    0xc(%ebp),%edx
  80040c:	89 d1                	mov    %edx,%ecx
  80040e:	89 c2                	mov    %eax,%edx
  800410:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800413:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800416:	8b 45 10             	mov    0x10(%ebp),%eax
  800419:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80041c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800426:	39 c2                	cmp    %eax,%edx
  800428:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80042b:	72 3e                	jb     80046b <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042d:	83 ec 0c             	sub    $0xc,%esp
  800430:	ff 75 18             	push   0x18(%ebp)
  800433:	83 eb 01             	sub    $0x1,%ebx
  800436:	53                   	push   %ebx
  800437:	50                   	push   %eax
  800438:	83 ec 08             	sub    $0x8,%esp
  80043b:	ff 75 e4             	push   -0x1c(%ebp)
  80043e:	ff 75 e0             	push   -0x20(%ebp)
  800441:	ff 75 dc             	push   -0x24(%ebp)
  800444:	ff 75 d8             	push   -0x28(%ebp)
  800447:	e8 b4 08 00 00       	call   800d00 <__udivdi3>
  80044c:	83 c4 18             	add    $0x18,%esp
  80044f:	52                   	push   %edx
  800450:	50                   	push   %eax
  800451:	89 f2                	mov    %esi,%edx
  800453:	89 f8                	mov    %edi,%eax
  800455:	e8 9f ff ff ff       	call   8003f9 <printnum>
  80045a:	83 c4 20             	add    $0x20,%esp
  80045d:	eb 13                	jmp    800472 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	56                   	push   %esi
  800463:	ff 75 18             	push   0x18(%ebp)
  800466:	ff d7                	call   *%edi
  800468:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80046b:	83 eb 01             	sub    $0x1,%ebx
  80046e:	85 db                	test   %ebx,%ebx
  800470:	7f ed                	jg     80045f <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800472:	83 ec 08             	sub    $0x8,%esp
  800475:	56                   	push   %esi
  800476:	83 ec 04             	sub    $0x4,%esp
  800479:	ff 75 e4             	push   -0x1c(%ebp)
  80047c:	ff 75 e0             	push   -0x20(%ebp)
  80047f:	ff 75 dc             	push   -0x24(%ebp)
  800482:	ff 75 d8             	push   -0x28(%ebp)
  800485:	e8 96 09 00 00       	call   800e20 <__umoddi3>
  80048a:	83 c4 14             	add    $0x14,%esp
  80048d:	0f be 80 9d 0f 80 00 	movsbl 0x800f9d(%eax),%eax
  800494:	50                   	push   %eax
  800495:	ff d7                	call   *%edi
}
  800497:	83 c4 10             	add    $0x10,%esp
  80049a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80049d:	5b                   	pop    %ebx
  80049e:	5e                   	pop    %esi
  80049f:	5f                   	pop    %edi
  8004a0:	5d                   	pop    %ebp
  8004a1:	c3                   	ret    

008004a2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004a2:	55                   	push   %ebp
  8004a3:	89 e5                	mov    %esp,%ebp
  8004a5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004a8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004ac:	8b 10                	mov    (%eax),%edx
  8004ae:	3b 50 04             	cmp    0x4(%eax),%edx
  8004b1:	73 0a                	jae    8004bd <sprintputch+0x1b>
		*b->buf++ = ch;
  8004b3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004b6:	89 08                	mov    %ecx,(%eax)
  8004b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bb:	88 02                	mov    %al,(%edx)
}
  8004bd:	5d                   	pop    %ebp
  8004be:	c3                   	ret    

008004bf <printfmt>:
{
  8004bf:	55                   	push   %ebp
  8004c0:	89 e5                	mov    %esp,%ebp
  8004c2:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004c5:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004c8:	50                   	push   %eax
  8004c9:	ff 75 10             	push   0x10(%ebp)
  8004cc:	ff 75 0c             	push   0xc(%ebp)
  8004cf:	ff 75 08             	push   0x8(%ebp)
  8004d2:	e8 05 00 00 00       	call   8004dc <vprintfmt>
}
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	c9                   	leave  
  8004db:	c3                   	ret    

008004dc <vprintfmt>:
{
  8004dc:	55                   	push   %ebp
  8004dd:	89 e5                	mov    %esp,%ebp
  8004df:	57                   	push   %edi
  8004e0:	56                   	push   %esi
  8004e1:	53                   	push   %ebx
  8004e2:	83 ec 3c             	sub    $0x3c,%esp
  8004e5:	8b 75 08             	mov    0x8(%ebp),%esi
  8004e8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004eb:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004ee:	eb 0a                	jmp    8004fa <vprintfmt+0x1e>
			putch(ch, putdat);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	53                   	push   %ebx
  8004f4:	50                   	push   %eax
  8004f5:	ff d6                	call   *%esi
  8004f7:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004fa:	83 c7 01             	add    $0x1,%edi
  8004fd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800501:	83 f8 25             	cmp    $0x25,%eax
  800504:	74 0c                	je     800512 <vprintfmt+0x36>
			if (ch == '\0')
  800506:	85 c0                	test   %eax,%eax
  800508:	75 e6                	jne    8004f0 <vprintfmt+0x14>
}
  80050a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80050d:	5b                   	pop    %ebx
  80050e:	5e                   	pop    %esi
  80050f:	5f                   	pop    %edi
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    
		padc = ' ';
  800512:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800516:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80051d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800524:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80052b:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800530:	8d 47 01             	lea    0x1(%edi),%eax
  800533:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800536:	0f b6 17             	movzbl (%edi),%edx
  800539:	8d 42 dd             	lea    -0x23(%edx),%eax
  80053c:	3c 55                	cmp    $0x55,%al
  80053e:	0f 87 bb 03 00 00    	ja     8008ff <vprintfmt+0x423>
  800544:	0f b6 c0             	movzbl %al,%eax
  800547:	ff 24 85 60 10 80 00 	jmp    *0x801060(,%eax,4)
  80054e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800551:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800555:	eb d9                	jmp    800530 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  800557:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80055a:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80055e:	eb d0                	jmp    800530 <vprintfmt+0x54>
  800560:	0f b6 d2             	movzbl %dl,%edx
  800563:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800566:	b8 00 00 00 00       	mov    $0x0,%eax
  80056b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80056e:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800571:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800575:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800578:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80057b:	83 f9 09             	cmp    $0x9,%ecx
  80057e:	77 55                	ja     8005d5 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800580:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800583:	eb e9                	jmp    80056e <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8b 00                	mov    (%eax),%eax
  80058a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8d 40 04             	lea    0x4(%eax),%eax
  800593:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800596:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800599:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80059d:	79 91                	jns    800530 <vprintfmt+0x54>
				width = precision, precision = -1;
  80059f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005ac:	eb 82                	jmp    800530 <vprintfmt+0x54>
  8005ae:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005b1:	85 d2                	test   %edx,%edx
  8005b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b8:	0f 49 c2             	cmovns %edx,%eax
  8005bb:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005c1:	e9 6a ff ff ff       	jmp    800530 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005c6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005c9:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005d0:	e9 5b ff ff ff       	jmp    800530 <vprintfmt+0x54>
  8005d5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005db:	eb bc                	jmp    800599 <vprintfmt+0xbd>
			lflag++;
  8005dd:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005e3:	e9 48 ff ff ff       	jmp    800530 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8005e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005eb:	8d 78 04             	lea    0x4(%eax),%edi
  8005ee:	83 ec 08             	sub    $0x8,%esp
  8005f1:	53                   	push   %ebx
  8005f2:	ff 30                	push   (%eax)
  8005f4:	ff d6                	call   *%esi
			break;
  8005f6:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005f9:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005fc:	e9 9d 02 00 00       	jmp    80089e <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  800601:	8b 45 14             	mov    0x14(%ebp),%eax
  800604:	8d 78 04             	lea    0x4(%eax),%edi
  800607:	8b 10                	mov    (%eax),%edx
  800609:	89 d0                	mov    %edx,%eax
  80060b:	f7 d8                	neg    %eax
  80060d:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800610:	83 f8 08             	cmp    $0x8,%eax
  800613:	7f 23                	jg     800638 <vprintfmt+0x15c>
  800615:	8b 14 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%edx
  80061c:	85 d2                	test   %edx,%edx
  80061e:	74 18                	je     800638 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800620:	52                   	push   %edx
  800621:	68 be 0f 80 00       	push   $0x800fbe
  800626:	53                   	push   %ebx
  800627:	56                   	push   %esi
  800628:	e8 92 fe ff ff       	call   8004bf <printfmt>
  80062d:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800630:	89 7d 14             	mov    %edi,0x14(%ebp)
  800633:	e9 66 02 00 00       	jmp    80089e <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  800638:	50                   	push   %eax
  800639:	68 b5 0f 80 00       	push   $0x800fb5
  80063e:	53                   	push   %ebx
  80063f:	56                   	push   %esi
  800640:	e8 7a fe ff ff       	call   8004bf <printfmt>
  800645:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800648:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80064b:	e9 4e 02 00 00       	jmp    80089e <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	83 c0 04             	add    $0x4,%eax
  800656:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80065e:	85 d2                	test   %edx,%edx
  800660:	b8 ae 0f 80 00       	mov    $0x800fae,%eax
  800665:	0f 45 c2             	cmovne %edx,%eax
  800668:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80066b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80066f:	7e 06                	jle    800677 <vprintfmt+0x19b>
  800671:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800675:	75 0d                	jne    800684 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  800677:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80067a:	89 c7                	mov    %eax,%edi
  80067c:	03 45 e0             	add    -0x20(%ebp),%eax
  80067f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800682:	eb 55                	jmp    8006d9 <vprintfmt+0x1fd>
  800684:	83 ec 08             	sub    $0x8,%esp
  800687:	ff 75 d8             	push   -0x28(%ebp)
  80068a:	ff 75 cc             	push   -0x34(%ebp)
  80068d:	e8 0a 03 00 00       	call   80099c <strnlen>
  800692:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800695:	29 c1                	sub    %eax,%ecx
  800697:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80069a:	83 c4 10             	add    $0x10,%esp
  80069d:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80069f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8006a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a6:	eb 0f                	jmp    8006b7 <vprintfmt+0x1db>
					putch(padc, putdat);
  8006a8:	83 ec 08             	sub    $0x8,%esp
  8006ab:	53                   	push   %ebx
  8006ac:	ff 75 e0             	push   -0x20(%ebp)
  8006af:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b1:	83 ef 01             	sub    $0x1,%edi
  8006b4:	83 c4 10             	add    $0x10,%esp
  8006b7:	85 ff                	test   %edi,%edi
  8006b9:	7f ed                	jg     8006a8 <vprintfmt+0x1cc>
  8006bb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006be:	85 d2                	test   %edx,%edx
  8006c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c5:	0f 49 c2             	cmovns %edx,%eax
  8006c8:	29 c2                	sub    %eax,%edx
  8006ca:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006cd:	eb a8                	jmp    800677 <vprintfmt+0x19b>
					putch(ch, putdat);
  8006cf:	83 ec 08             	sub    $0x8,%esp
  8006d2:	53                   	push   %ebx
  8006d3:	52                   	push   %edx
  8006d4:	ff d6                	call   *%esi
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006dc:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006de:	83 c7 01             	add    $0x1,%edi
  8006e1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006e5:	0f be d0             	movsbl %al,%edx
  8006e8:	85 d2                	test   %edx,%edx
  8006ea:	74 4b                	je     800737 <vprintfmt+0x25b>
  8006ec:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006f0:	78 06                	js     8006f8 <vprintfmt+0x21c>
  8006f2:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8006f6:	78 1e                	js     800716 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8006f8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006fc:	74 d1                	je     8006cf <vprintfmt+0x1f3>
  8006fe:	0f be c0             	movsbl %al,%eax
  800701:	83 e8 20             	sub    $0x20,%eax
  800704:	83 f8 5e             	cmp    $0x5e,%eax
  800707:	76 c6                	jbe    8006cf <vprintfmt+0x1f3>
					putch('?', putdat);
  800709:	83 ec 08             	sub    $0x8,%esp
  80070c:	53                   	push   %ebx
  80070d:	6a 3f                	push   $0x3f
  80070f:	ff d6                	call   *%esi
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	eb c3                	jmp    8006d9 <vprintfmt+0x1fd>
  800716:	89 cf                	mov    %ecx,%edi
  800718:	eb 0e                	jmp    800728 <vprintfmt+0x24c>
				putch(' ', putdat);
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	53                   	push   %ebx
  80071e:	6a 20                	push   $0x20
  800720:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800722:	83 ef 01             	sub    $0x1,%edi
  800725:	83 c4 10             	add    $0x10,%esp
  800728:	85 ff                	test   %edi,%edi
  80072a:	7f ee                	jg     80071a <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80072c:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80072f:	89 45 14             	mov    %eax,0x14(%ebp)
  800732:	e9 67 01 00 00       	jmp    80089e <vprintfmt+0x3c2>
  800737:	89 cf                	mov    %ecx,%edi
  800739:	eb ed                	jmp    800728 <vprintfmt+0x24c>
	if (lflag >= 2)
  80073b:	83 f9 01             	cmp    $0x1,%ecx
  80073e:	7f 1b                	jg     80075b <vprintfmt+0x27f>
	else if (lflag)
  800740:	85 c9                	test   %ecx,%ecx
  800742:	74 63                	je     8007a7 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800744:	8b 45 14             	mov    0x14(%ebp),%eax
  800747:	8b 00                	mov    (%eax),%eax
  800749:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80074c:	99                   	cltd   
  80074d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800750:	8b 45 14             	mov    0x14(%ebp),%eax
  800753:	8d 40 04             	lea    0x4(%eax),%eax
  800756:	89 45 14             	mov    %eax,0x14(%ebp)
  800759:	eb 17                	jmp    800772 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80075b:	8b 45 14             	mov    0x14(%ebp),%eax
  80075e:	8b 50 04             	mov    0x4(%eax),%edx
  800761:	8b 00                	mov    (%eax),%eax
  800763:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800766:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800769:	8b 45 14             	mov    0x14(%ebp),%eax
  80076c:	8d 40 08             	lea    0x8(%eax),%eax
  80076f:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800772:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800775:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  800778:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80077d:	85 c9                	test   %ecx,%ecx
  80077f:	0f 89 ff 00 00 00    	jns    800884 <vprintfmt+0x3a8>
				putch('-', putdat);
  800785:	83 ec 08             	sub    $0x8,%esp
  800788:	53                   	push   %ebx
  800789:	6a 2d                	push   $0x2d
  80078b:	ff d6                	call   *%esi
				num = -(long long) num;
  80078d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800790:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800793:	f7 da                	neg    %edx
  800795:	83 d1 00             	adc    $0x0,%ecx
  800798:	f7 d9                	neg    %ecx
  80079a:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80079d:	bf 0a 00 00 00       	mov    $0xa,%edi
  8007a2:	e9 dd 00 00 00       	jmp    800884 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8007a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007aa:	8b 00                	mov    (%eax),%eax
  8007ac:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007af:	99                   	cltd   
  8007b0:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b6:	8d 40 04             	lea    0x4(%eax),%eax
  8007b9:	89 45 14             	mov    %eax,0x14(%ebp)
  8007bc:	eb b4                	jmp    800772 <vprintfmt+0x296>
	if (lflag >= 2)
  8007be:	83 f9 01             	cmp    $0x1,%ecx
  8007c1:	7f 1e                	jg     8007e1 <vprintfmt+0x305>
	else if (lflag)
  8007c3:	85 c9                	test   %ecx,%ecx
  8007c5:	74 32                	je     8007f9 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8007c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ca:	8b 10                	mov    (%eax),%edx
  8007cc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007d1:	8d 40 04             	lea    0x4(%eax),%eax
  8007d4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007d7:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8007dc:	e9 a3 00 00 00       	jmp    800884 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e4:	8b 10                	mov    (%eax),%edx
  8007e6:	8b 48 04             	mov    0x4(%eax),%ecx
  8007e9:	8d 40 08             	lea    0x8(%eax),%eax
  8007ec:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007ef:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8007f4:	e9 8b 00 00 00       	jmp    800884 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fc:	8b 10                	mov    (%eax),%edx
  8007fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800803:	8d 40 04             	lea    0x4(%eax),%eax
  800806:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800809:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80080e:	eb 74                	jmp    800884 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800810:	83 f9 01             	cmp    $0x1,%ecx
  800813:	7f 1b                	jg     800830 <vprintfmt+0x354>
	else if (lflag)
  800815:	85 c9                	test   %ecx,%ecx
  800817:	74 2c                	je     800845 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800819:	8b 45 14             	mov    0x14(%ebp),%eax
  80081c:	8b 10                	mov    (%eax),%edx
  80081e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800823:	8d 40 04             	lea    0x4(%eax),%eax
  800826:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800829:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80082e:	eb 54                	jmp    800884 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800830:	8b 45 14             	mov    0x14(%ebp),%eax
  800833:	8b 10                	mov    (%eax),%edx
  800835:	8b 48 04             	mov    0x4(%eax),%ecx
  800838:	8d 40 08             	lea    0x8(%eax),%eax
  80083b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80083e:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800843:	eb 3f                	jmp    800884 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800845:	8b 45 14             	mov    0x14(%ebp),%eax
  800848:	8b 10                	mov    (%eax),%edx
  80084a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80084f:	8d 40 04             	lea    0x4(%eax),%eax
  800852:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800855:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80085a:	eb 28                	jmp    800884 <vprintfmt+0x3a8>
			putch('0', putdat);
  80085c:	83 ec 08             	sub    $0x8,%esp
  80085f:	53                   	push   %ebx
  800860:	6a 30                	push   $0x30
  800862:	ff d6                	call   *%esi
			putch('x', putdat);
  800864:	83 c4 08             	add    $0x8,%esp
  800867:	53                   	push   %ebx
  800868:	6a 78                	push   $0x78
  80086a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80086c:	8b 45 14             	mov    0x14(%ebp),%eax
  80086f:	8b 10                	mov    (%eax),%edx
  800871:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800876:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800879:	8d 40 04             	lea    0x4(%eax),%eax
  80087c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80087f:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800884:	83 ec 0c             	sub    $0xc,%esp
  800887:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80088b:	50                   	push   %eax
  80088c:	ff 75 e0             	push   -0x20(%ebp)
  80088f:	57                   	push   %edi
  800890:	51                   	push   %ecx
  800891:	52                   	push   %edx
  800892:	89 da                	mov    %ebx,%edx
  800894:	89 f0                	mov    %esi,%eax
  800896:	e8 5e fb ff ff       	call   8003f9 <printnum>
			break;
  80089b:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  80089e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008a1:	e9 54 fc ff ff       	jmp    8004fa <vprintfmt+0x1e>
	if (lflag >= 2)
  8008a6:	83 f9 01             	cmp    $0x1,%ecx
  8008a9:	7f 1b                	jg     8008c6 <vprintfmt+0x3ea>
	else if (lflag)
  8008ab:	85 c9                	test   %ecx,%ecx
  8008ad:	74 2c                	je     8008db <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8008af:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b2:	8b 10                	mov    (%eax),%edx
  8008b4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b9:	8d 40 04             	lea    0x4(%eax),%eax
  8008bc:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008bf:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8008c4:	eb be                	jmp    800884 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8008c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c9:	8b 10                	mov    (%eax),%edx
  8008cb:	8b 48 04             	mov    0x4(%eax),%ecx
  8008ce:	8d 40 08             	lea    0x8(%eax),%eax
  8008d1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008d4:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8008d9:	eb a9                	jmp    800884 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8008db:	8b 45 14             	mov    0x14(%ebp),%eax
  8008de:	8b 10                	mov    (%eax),%edx
  8008e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008e5:	8d 40 04             	lea    0x4(%eax),%eax
  8008e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008eb:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8008f0:	eb 92                	jmp    800884 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8008f2:	83 ec 08             	sub    $0x8,%esp
  8008f5:	53                   	push   %ebx
  8008f6:	6a 25                	push   $0x25
  8008f8:	ff d6                	call   *%esi
			break;
  8008fa:	83 c4 10             	add    $0x10,%esp
  8008fd:	eb 9f                	jmp    80089e <vprintfmt+0x3c2>
			putch('%', putdat);
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	53                   	push   %ebx
  800903:	6a 25                	push   $0x25
  800905:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800907:	83 c4 10             	add    $0x10,%esp
  80090a:	89 f8                	mov    %edi,%eax
  80090c:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800910:	74 05                	je     800917 <vprintfmt+0x43b>
  800912:	83 e8 01             	sub    $0x1,%eax
  800915:	eb f5                	jmp    80090c <vprintfmt+0x430>
  800917:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80091a:	eb 82                	jmp    80089e <vprintfmt+0x3c2>

0080091c <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80091c:	55                   	push   %ebp
  80091d:	89 e5                	mov    %esp,%ebp
  80091f:	83 ec 18             	sub    $0x18,%esp
  800922:	8b 45 08             	mov    0x8(%ebp),%eax
  800925:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800928:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80092b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80092f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800932:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800939:	85 c0                	test   %eax,%eax
  80093b:	74 26                	je     800963 <vsnprintf+0x47>
  80093d:	85 d2                	test   %edx,%edx
  80093f:	7e 22                	jle    800963 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800941:	ff 75 14             	push   0x14(%ebp)
  800944:	ff 75 10             	push   0x10(%ebp)
  800947:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80094a:	50                   	push   %eax
  80094b:	68 a2 04 80 00       	push   $0x8004a2
  800950:	e8 87 fb ff ff       	call   8004dc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800955:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800958:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80095b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095e:	83 c4 10             	add    $0x10,%esp
}
  800961:	c9                   	leave  
  800962:	c3                   	ret    
		return -E_INVAL;
  800963:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800968:	eb f7                	jmp    800961 <vsnprintf+0x45>

0080096a <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80096a:	55                   	push   %ebp
  80096b:	89 e5                	mov    %esp,%ebp
  80096d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800970:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800973:	50                   	push   %eax
  800974:	ff 75 10             	push   0x10(%ebp)
  800977:	ff 75 0c             	push   0xc(%ebp)
  80097a:	ff 75 08             	push   0x8(%ebp)
  80097d:	e8 9a ff ff ff       	call   80091c <vsnprintf>
	va_end(ap);

	return rc;
}
  800982:	c9                   	leave  
  800983:	c3                   	ret    

00800984 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80098a:	b8 00 00 00 00       	mov    $0x0,%eax
  80098f:	eb 03                	jmp    800994 <strlen+0x10>
		n++;
  800991:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800994:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800998:	75 f7                	jne    800991 <strlen+0xd>
	return n;
}
  80099a:	5d                   	pop    %ebp
  80099b:	c3                   	ret    

0080099c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009a2:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8009aa:	eb 03                	jmp    8009af <strnlen+0x13>
		n++;
  8009ac:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009af:	39 d0                	cmp    %edx,%eax
  8009b1:	74 08                	je     8009bb <strnlen+0x1f>
  8009b3:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009b7:	75 f3                	jne    8009ac <strnlen+0x10>
  8009b9:	89 c2                	mov    %eax,%edx
	return n;
}
  8009bb:	89 d0                	mov    %edx,%eax
  8009bd:	5d                   	pop    %ebp
  8009be:	c3                   	ret    

008009bf <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009bf:	55                   	push   %ebp
  8009c0:	89 e5                	mov    %esp,%ebp
  8009c2:	53                   	push   %ebx
  8009c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8009ce:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8009d2:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8009d5:	83 c0 01             	add    $0x1,%eax
  8009d8:	84 d2                	test   %dl,%dl
  8009da:	75 f2                	jne    8009ce <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009dc:	89 c8                	mov    %ecx,%eax
  8009de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e1:	c9                   	leave  
  8009e2:	c3                   	ret    

008009e3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	53                   	push   %ebx
  8009e7:	83 ec 10             	sub    $0x10,%esp
  8009ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009ed:	53                   	push   %ebx
  8009ee:	e8 91 ff ff ff       	call   800984 <strlen>
  8009f3:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8009f6:	ff 75 0c             	push   0xc(%ebp)
  8009f9:	01 d8                	add    %ebx,%eax
  8009fb:	50                   	push   %eax
  8009fc:	e8 be ff ff ff       	call   8009bf <strcpy>
	return dst;
}
  800a01:	89 d8                	mov    %ebx,%eax
  800a03:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a06:	c9                   	leave  
  800a07:	c3                   	ret    

00800a08 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	56                   	push   %esi
  800a0c:	53                   	push   %ebx
  800a0d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a10:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a13:	89 f3                	mov    %esi,%ebx
  800a15:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a18:	89 f0                	mov    %esi,%eax
  800a1a:	eb 0f                	jmp    800a2b <strncpy+0x23>
		*dst++ = *src;
  800a1c:	83 c0 01             	add    $0x1,%eax
  800a1f:	0f b6 0a             	movzbl (%edx),%ecx
  800a22:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a25:	80 f9 01             	cmp    $0x1,%cl
  800a28:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800a2b:	39 d8                	cmp    %ebx,%eax
  800a2d:	75 ed                	jne    800a1c <strncpy+0x14>
	}
	return ret;
}
  800a2f:	89 f0                	mov    %esi,%eax
  800a31:	5b                   	pop    %ebx
  800a32:	5e                   	pop    %esi
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	56                   	push   %esi
  800a39:	53                   	push   %ebx
  800a3a:	8b 75 08             	mov    0x8(%ebp),%esi
  800a3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a40:	8b 55 10             	mov    0x10(%ebp),%edx
  800a43:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a45:	85 d2                	test   %edx,%edx
  800a47:	74 21                	je     800a6a <strlcpy+0x35>
  800a49:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a4d:	89 f2                	mov    %esi,%edx
  800a4f:	eb 09                	jmp    800a5a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a51:	83 c1 01             	add    $0x1,%ecx
  800a54:	83 c2 01             	add    $0x1,%edx
  800a57:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800a5a:	39 c2                	cmp    %eax,%edx
  800a5c:	74 09                	je     800a67 <strlcpy+0x32>
  800a5e:	0f b6 19             	movzbl (%ecx),%ebx
  800a61:	84 db                	test   %bl,%bl
  800a63:	75 ec                	jne    800a51 <strlcpy+0x1c>
  800a65:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a67:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a6a:	29 f0                	sub    %esi,%eax
}
  800a6c:	5b                   	pop    %ebx
  800a6d:	5e                   	pop    %esi
  800a6e:	5d                   	pop    %ebp
  800a6f:	c3                   	ret    

00800a70 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a70:	55                   	push   %ebp
  800a71:	89 e5                	mov    %esp,%ebp
  800a73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a76:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a79:	eb 06                	jmp    800a81 <strcmp+0x11>
		p++, q++;
  800a7b:	83 c1 01             	add    $0x1,%ecx
  800a7e:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a81:	0f b6 01             	movzbl (%ecx),%eax
  800a84:	84 c0                	test   %al,%al
  800a86:	74 04                	je     800a8c <strcmp+0x1c>
  800a88:	3a 02                	cmp    (%edx),%al
  800a8a:	74 ef                	je     800a7b <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a8c:	0f b6 c0             	movzbl %al,%eax
  800a8f:	0f b6 12             	movzbl (%edx),%edx
  800a92:	29 d0                	sub    %edx,%eax
}
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	53                   	push   %ebx
  800a9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800aa0:	89 c3                	mov    %eax,%ebx
  800aa2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800aa5:	eb 06                	jmp    800aad <strncmp+0x17>
		n--, p++, q++;
  800aa7:	83 c0 01             	add    $0x1,%eax
  800aaa:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800aad:	39 d8                	cmp    %ebx,%eax
  800aaf:	74 18                	je     800ac9 <strncmp+0x33>
  800ab1:	0f b6 08             	movzbl (%eax),%ecx
  800ab4:	84 c9                	test   %cl,%cl
  800ab6:	74 04                	je     800abc <strncmp+0x26>
  800ab8:	3a 0a                	cmp    (%edx),%cl
  800aba:	74 eb                	je     800aa7 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800abc:	0f b6 00             	movzbl (%eax),%eax
  800abf:	0f b6 12             	movzbl (%edx),%edx
  800ac2:	29 d0                	sub    %edx,%eax
}
  800ac4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ac7:	c9                   	leave  
  800ac8:	c3                   	ret    
		return 0;
  800ac9:	b8 00 00 00 00       	mov    $0x0,%eax
  800ace:	eb f4                	jmp    800ac4 <strncmp+0x2e>

00800ad0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ada:	eb 03                	jmp    800adf <strchr+0xf>
  800adc:	83 c0 01             	add    $0x1,%eax
  800adf:	0f b6 10             	movzbl (%eax),%edx
  800ae2:	84 d2                	test   %dl,%dl
  800ae4:	74 06                	je     800aec <strchr+0x1c>
		if (*s == c)
  800ae6:	38 ca                	cmp    %cl,%dl
  800ae8:	75 f2                	jne    800adc <strchr+0xc>
  800aea:	eb 05                	jmp    800af1 <strchr+0x21>
			return (char *) s;
	return 0;
  800aec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	8b 45 08             	mov    0x8(%ebp),%eax
  800af9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800afd:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b00:	38 ca                	cmp    %cl,%dl
  800b02:	74 09                	je     800b0d <strfind+0x1a>
  800b04:	84 d2                	test   %dl,%dl
  800b06:	74 05                	je     800b0d <strfind+0x1a>
	for (; *s; s++)
  800b08:	83 c0 01             	add    $0x1,%eax
  800b0b:	eb f0                	jmp    800afd <strfind+0xa>
			break;
	return (char *) s;
}
  800b0d:	5d                   	pop    %ebp
  800b0e:	c3                   	ret    

00800b0f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	57                   	push   %edi
  800b13:	56                   	push   %esi
  800b14:	53                   	push   %ebx
  800b15:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b18:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b1b:	85 c9                	test   %ecx,%ecx
  800b1d:	74 2f                	je     800b4e <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b1f:	89 f8                	mov    %edi,%eax
  800b21:	09 c8                	or     %ecx,%eax
  800b23:	a8 03                	test   $0x3,%al
  800b25:	75 21                	jne    800b48 <memset+0x39>
		c &= 0xFF;
  800b27:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b2b:	89 d0                	mov    %edx,%eax
  800b2d:	c1 e0 08             	shl    $0x8,%eax
  800b30:	89 d3                	mov    %edx,%ebx
  800b32:	c1 e3 18             	shl    $0x18,%ebx
  800b35:	89 d6                	mov    %edx,%esi
  800b37:	c1 e6 10             	shl    $0x10,%esi
  800b3a:	09 f3                	or     %esi,%ebx
  800b3c:	09 da                	or     %ebx,%edx
  800b3e:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b40:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b43:	fc                   	cld    
  800b44:	f3 ab                	rep stos %eax,%es:(%edi)
  800b46:	eb 06                	jmp    800b4e <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4b:	fc                   	cld    
  800b4c:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b4e:	89 f8                	mov    %edi,%eax
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	57                   	push   %edi
  800b59:	56                   	push   %esi
  800b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b60:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b63:	39 c6                	cmp    %eax,%esi
  800b65:	73 32                	jae    800b99 <memmove+0x44>
  800b67:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b6a:	39 c2                	cmp    %eax,%edx
  800b6c:	76 2b                	jbe    800b99 <memmove+0x44>
		s += n;
		d += n;
  800b6e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b71:	89 d6                	mov    %edx,%esi
  800b73:	09 fe                	or     %edi,%esi
  800b75:	09 ce                	or     %ecx,%esi
  800b77:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b7d:	75 0e                	jne    800b8d <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b7f:	83 ef 04             	sub    $0x4,%edi
  800b82:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b85:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b88:	fd                   	std    
  800b89:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b8b:	eb 09                	jmp    800b96 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b8d:	83 ef 01             	sub    $0x1,%edi
  800b90:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b93:	fd                   	std    
  800b94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b96:	fc                   	cld    
  800b97:	eb 1a                	jmp    800bb3 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b99:	89 f2                	mov    %esi,%edx
  800b9b:	09 c2                	or     %eax,%edx
  800b9d:	09 ca                	or     %ecx,%edx
  800b9f:	f6 c2 03             	test   $0x3,%dl
  800ba2:	75 0a                	jne    800bae <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800ba4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ba7:	89 c7                	mov    %eax,%edi
  800ba9:	fc                   	cld    
  800baa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bac:	eb 05                	jmp    800bb3 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800bae:	89 c7                	mov    %eax,%edi
  800bb0:	fc                   	cld    
  800bb1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bb3:	5e                   	pop    %esi
  800bb4:	5f                   	pop    %edi
  800bb5:	5d                   	pop    %ebp
  800bb6:	c3                   	ret    

00800bb7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bbd:	ff 75 10             	push   0x10(%ebp)
  800bc0:	ff 75 0c             	push   0xc(%ebp)
  800bc3:	ff 75 08             	push   0x8(%ebp)
  800bc6:	e8 8a ff ff ff       	call   800b55 <memmove>
}
  800bcb:	c9                   	leave  
  800bcc:	c3                   	ret    

00800bcd <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	56                   	push   %esi
  800bd1:	53                   	push   %ebx
  800bd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd8:	89 c6                	mov    %eax,%esi
  800bda:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bdd:	eb 06                	jmp    800be5 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bdf:	83 c0 01             	add    $0x1,%eax
  800be2:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800be5:	39 f0                	cmp    %esi,%eax
  800be7:	74 14                	je     800bfd <memcmp+0x30>
		if (*s1 != *s2)
  800be9:	0f b6 08             	movzbl (%eax),%ecx
  800bec:	0f b6 1a             	movzbl (%edx),%ebx
  800bef:	38 d9                	cmp    %bl,%cl
  800bf1:	74 ec                	je     800bdf <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800bf3:	0f b6 c1             	movzbl %cl,%eax
  800bf6:	0f b6 db             	movzbl %bl,%ebx
  800bf9:	29 d8                	sub    %ebx,%eax
  800bfb:	eb 05                	jmp    800c02 <memcmp+0x35>
	}

	return 0;
  800bfd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c02:	5b                   	pop    %ebx
  800c03:	5e                   	pop    %esi
  800c04:	5d                   	pop    %ebp
  800c05:	c3                   	ret    

00800c06 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c0f:	89 c2                	mov    %eax,%edx
  800c11:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c14:	eb 03                	jmp    800c19 <memfind+0x13>
  800c16:	83 c0 01             	add    $0x1,%eax
  800c19:	39 d0                	cmp    %edx,%eax
  800c1b:	73 04                	jae    800c21 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c1d:	38 08                	cmp    %cl,(%eax)
  800c1f:	75 f5                	jne    800c16 <memfind+0x10>
			break;
	return (void *) s;
}
  800c21:	5d                   	pop    %ebp
  800c22:	c3                   	ret    

00800c23 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c23:	55                   	push   %ebp
  800c24:	89 e5                	mov    %esp,%ebp
  800c26:	57                   	push   %edi
  800c27:	56                   	push   %esi
  800c28:	53                   	push   %ebx
  800c29:	8b 55 08             	mov    0x8(%ebp),%edx
  800c2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c2f:	eb 03                	jmp    800c34 <strtol+0x11>
		s++;
  800c31:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800c34:	0f b6 02             	movzbl (%edx),%eax
  800c37:	3c 20                	cmp    $0x20,%al
  800c39:	74 f6                	je     800c31 <strtol+0xe>
  800c3b:	3c 09                	cmp    $0x9,%al
  800c3d:	74 f2                	je     800c31 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c3f:	3c 2b                	cmp    $0x2b,%al
  800c41:	74 2a                	je     800c6d <strtol+0x4a>
	int neg = 0;
  800c43:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c48:	3c 2d                	cmp    $0x2d,%al
  800c4a:	74 2b                	je     800c77 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c4c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c52:	75 0f                	jne    800c63 <strtol+0x40>
  800c54:	80 3a 30             	cmpb   $0x30,(%edx)
  800c57:	74 28                	je     800c81 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c59:	85 db                	test   %ebx,%ebx
  800c5b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c60:	0f 44 d8             	cmove  %eax,%ebx
  800c63:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c68:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c6b:	eb 46                	jmp    800cb3 <strtol+0x90>
		s++;
  800c6d:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800c70:	bf 00 00 00 00       	mov    $0x0,%edi
  800c75:	eb d5                	jmp    800c4c <strtol+0x29>
		s++, neg = 1;
  800c77:	83 c2 01             	add    $0x1,%edx
  800c7a:	bf 01 00 00 00       	mov    $0x1,%edi
  800c7f:	eb cb                	jmp    800c4c <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c81:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c85:	74 0e                	je     800c95 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800c87:	85 db                	test   %ebx,%ebx
  800c89:	75 d8                	jne    800c63 <strtol+0x40>
		s++, base = 8;
  800c8b:	83 c2 01             	add    $0x1,%edx
  800c8e:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c93:	eb ce                	jmp    800c63 <strtol+0x40>
		s += 2, base = 16;
  800c95:	83 c2 02             	add    $0x2,%edx
  800c98:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c9d:	eb c4                	jmp    800c63 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c9f:	0f be c0             	movsbl %al,%eax
  800ca2:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ca5:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ca8:	7d 3a                	jge    800ce4 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800caa:	83 c2 01             	add    $0x1,%edx
  800cad:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800cb1:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800cb3:	0f b6 02             	movzbl (%edx),%eax
  800cb6:	8d 70 d0             	lea    -0x30(%eax),%esi
  800cb9:	89 f3                	mov    %esi,%ebx
  800cbb:	80 fb 09             	cmp    $0x9,%bl
  800cbe:	76 df                	jbe    800c9f <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800cc0:	8d 70 9f             	lea    -0x61(%eax),%esi
  800cc3:	89 f3                	mov    %esi,%ebx
  800cc5:	80 fb 19             	cmp    $0x19,%bl
  800cc8:	77 08                	ja     800cd2 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800cca:	0f be c0             	movsbl %al,%eax
  800ccd:	83 e8 57             	sub    $0x57,%eax
  800cd0:	eb d3                	jmp    800ca5 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800cd2:	8d 70 bf             	lea    -0x41(%eax),%esi
  800cd5:	89 f3                	mov    %esi,%ebx
  800cd7:	80 fb 19             	cmp    $0x19,%bl
  800cda:	77 08                	ja     800ce4 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800cdc:	0f be c0             	movsbl %al,%eax
  800cdf:	83 e8 37             	sub    $0x37,%eax
  800ce2:	eb c1                	jmp    800ca5 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ce4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ce8:	74 05                	je     800cef <strtol+0xcc>
		*endptr = (char *) s;
  800cea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ced:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800cef:	89 c8                	mov    %ecx,%eax
  800cf1:	f7 d8                	neg    %eax
  800cf3:	85 ff                	test   %edi,%edi
  800cf5:	0f 45 c8             	cmovne %eax,%ecx
}
  800cf8:	89 c8                	mov    %ecx,%eax
  800cfa:	5b                   	pop    %ebx
  800cfb:	5e                   	pop    %esi
  800cfc:	5f                   	pop    %edi
  800cfd:	5d                   	pop    %ebp
  800cfe:	c3                   	ret    
  800cff:	90                   	nop

00800d00 <__udivdi3>:
  800d00:	f3 0f 1e fb          	endbr32 
  800d04:	55                   	push   %ebp
  800d05:	57                   	push   %edi
  800d06:	56                   	push   %esi
  800d07:	53                   	push   %ebx
  800d08:	83 ec 1c             	sub    $0x1c,%esp
  800d0b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  800d0f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  800d13:	8b 74 24 34          	mov    0x34(%esp),%esi
  800d17:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  800d1b:	85 c0                	test   %eax,%eax
  800d1d:	75 19                	jne    800d38 <__udivdi3+0x38>
  800d1f:	39 f3                	cmp    %esi,%ebx
  800d21:	76 4d                	jbe    800d70 <__udivdi3+0x70>
  800d23:	31 ff                	xor    %edi,%edi
  800d25:	89 e8                	mov    %ebp,%eax
  800d27:	89 f2                	mov    %esi,%edx
  800d29:	f7 f3                	div    %ebx
  800d2b:	89 fa                	mov    %edi,%edx
  800d2d:	83 c4 1c             	add    $0x1c,%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    
  800d35:	8d 76 00             	lea    0x0(%esi),%esi
  800d38:	39 f0                	cmp    %esi,%eax
  800d3a:	76 14                	jbe    800d50 <__udivdi3+0x50>
  800d3c:	31 ff                	xor    %edi,%edi
  800d3e:	31 c0                	xor    %eax,%eax
  800d40:	89 fa                	mov    %edi,%edx
  800d42:	83 c4 1c             	add    $0x1c,%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    
  800d4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800d50:	0f bd f8             	bsr    %eax,%edi
  800d53:	83 f7 1f             	xor    $0x1f,%edi
  800d56:	75 48                	jne    800da0 <__udivdi3+0xa0>
  800d58:	39 f0                	cmp    %esi,%eax
  800d5a:	72 06                	jb     800d62 <__udivdi3+0x62>
  800d5c:	31 c0                	xor    %eax,%eax
  800d5e:	39 eb                	cmp    %ebp,%ebx
  800d60:	77 de                	ja     800d40 <__udivdi3+0x40>
  800d62:	b8 01 00 00 00       	mov    $0x1,%eax
  800d67:	eb d7                	jmp    800d40 <__udivdi3+0x40>
  800d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d70:	89 d9                	mov    %ebx,%ecx
  800d72:	85 db                	test   %ebx,%ebx
  800d74:	75 0b                	jne    800d81 <__udivdi3+0x81>
  800d76:	b8 01 00 00 00       	mov    $0x1,%eax
  800d7b:	31 d2                	xor    %edx,%edx
  800d7d:	f7 f3                	div    %ebx
  800d7f:	89 c1                	mov    %eax,%ecx
  800d81:	31 d2                	xor    %edx,%edx
  800d83:	89 f0                	mov    %esi,%eax
  800d85:	f7 f1                	div    %ecx
  800d87:	89 c6                	mov    %eax,%esi
  800d89:	89 e8                	mov    %ebp,%eax
  800d8b:	89 f7                	mov    %esi,%edi
  800d8d:	f7 f1                	div    %ecx
  800d8f:	89 fa                	mov    %edi,%edx
  800d91:	83 c4 1c             	add    $0x1c,%esp
  800d94:	5b                   	pop    %ebx
  800d95:	5e                   	pop    %esi
  800d96:	5f                   	pop    %edi
  800d97:	5d                   	pop    %ebp
  800d98:	c3                   	ret    
  800d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800da0:	89 f9                	mov    %edi,%ecx
  800da2:	ba 20 00 00 00       	mov    $0x20,%edx
  800da7:	29 fa                	sub    %edi,%edx
  800da9:	d3 e0                	shl    %cl,%eax
  800dab:	89 44 24 08          	mov    %eax,0x8(%esp)
  800daf:	89 d1                	mov    %edx,%ecx
  800db1:	89 d8                	mov    %ebx,%eax
  800db3:	d3 e8                	shr    %cl,%eax
  800db5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800db9:	09 c1                	or     %eax,%ecx
  800dbb:	89 f0                	mov    %esi,%eax
  800dbd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800dc1:	89 f9                	mov    %edi,%ecx
  800dc3:	d3 e3                	shl    %cl,%ebx
  800dc5:	89 d1                	mov    %edx,%ecx
  800dc7:	d3 e8                	shr    %cl,%eax
  800dc9:	89 f9                	mov    %edi,%ecx
  800dcb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800dcf:	89 eb                	mov    %ebp,%ebx
  800dd1:	d3 e6                	shl    %cl,%esi
  800dd3:	89 d1                	mov    %edx,%ecx
  800dd5:	d3 eb                	shr    %cl,%ebx
  800dd7:	09 f3                	or     %esi,%ebx
  800dd9:	89 c6                	mov    %eax,%esi
  800ddb:	89 f2                	mov    %esi,%edx
  800ddd:	89 d8                	mov    %ebx,%eax
  800ddf:	f7 74 24 08          	divl   0x8(%esp)
  800de3:	89 d6                	mov    %edx,%esi
  800de5:	89 c3                	mov    %eax,%ebx
  800de7:	f7 64 24 0c          	mull   0xc(%esp)
  800deb:	39 d6                	cmp    %edx,%esi
  800ded:	72 19                	jb     800e08 <__udivdi3+0x108>
  800def:	89 f9                	mov    %edi,%ecx
  800df1:	d3 e5                	shl    %cl,%ebp
  800df3:	39 c5                	cmp    %eax,%ebp
  800df5:	73 04                	jae    800dfb <__udivdi3+0xfb>
  800df7:	39 d6                	cmp    %edx,%esi
  800df9:	74 0d                	je     800e08 <__udivdi3+0x108>
  800dfb:	89 d8                	mov    %ebx,%eax
  800dfd:	31 ff                	xor    %edi,%edi
  800dff:	e9 3c ff ff ff       	jmp    800d40 <__udivdi3+0x40>
  800e04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e08:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800e0b:	31 ff                	xor    %edi,%edi
  800e0d:	e9 2e ff ff ff       	jmp    800d40 <__udivdi3+0x40>
  800e12:	66 90                	xchg   %ax,%ax
  800e14:	66 90                	xchg   %ax,%ax
  800e16:	66 90                	xchg   %ax,%ax
  800e18:	66 90                	xchg   %ax,%ax
  800e1a:	66 90                	xchg   %ax,%ax
  800e1c:	66 90                	xchg   %ax,%ax
  800e1e:	66 90                	xchg   %ax,%ax

00800e20 <__umoddi3>:
  800e20:	f3 0f 1e fb          	endbr32 
  800e24:	55                   	push   %ebp
  800e25:	57                   	push   %edi
  800e26:	56                   	push   %esi
  800e27:	53                   	push   %ebx
  800e28:	83 ec 1c             	sub    $0x1c,%esp
  800e2b:	8b 74 24 30          	mov    0x30(%esp),%esi
  800e2f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  800e33:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  800e37:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  800e3b:	89 f0                	mov    %esi,%eax
  800e3d:	89 da                	mov    %ebx,%edx
  800e3f:	85 ff                	test   %edi,%edi
  800e41:	75 15                	jne    800e58 <__umoddi3+0x38>
  800e43:	39 dd                	cmp    %ebx,%ebp
  800e45:	76 39                	jbe    800e80 <__umoddi3+0x60>
  800e47:	f7 f5                	div    %ebp
  800e49:	89 d0                	mov    %edx,%eax
  800e4b:	31 d2                	xor    %edx,%edx
  800e4d:	83 c4 1c             	add    $0x1c,%esp
  800e50:	5b                   	pop    %ebx
  800e51:	5e                   	pop    %esi
  800e52:	5f                   	pop    %edi
  800e53:	5d                   	pop    %ebp
  800e54:	c3                   	ret    
  800e55:	8d 76 00             	lea    0x0(%esi),%esi
  800e58:	39 df                	cmp    %ebx,%edi
  800e5a:	77 f1                	ja     800e4d <__umoddi3+0x2d>
  800e5c:	0f bd cf             	bsr    %edi,%ecx
  800e5f:	83 f1 1f             	xor    $0x1f,%ecx
  800e62:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800e66:	75 40                	jne    800ea8 <__umoddi3+0x88>
  800e68:	39 df                	cmp    %ebx,%edi
  800e6a:	72 04                	jb     800e70 <__umoddi3+0x50>
  800e6c:	39 f5                	cmp    %esi,%ebp
  800e6e:	77 dd                	ja     800e4d <__umoddi3+0x2d>
  800e70:	89 da                	mov    %ebx,%edx
  800e72:	89 f0                	mov    %esi,%eax
  800e74:	29 e8                	sub    %ebp,%eax
  800e76:	19 fa                	sbb    %edi,%edx
  800e78:	eb d3                	jmp    800e4d <__umoddi3+0x2d>
  800e7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e80:	89 e9                	mov    %ebp,%ecx
  800e82:	85 ed                	test   %ebp,%ebp
  800e84:	75 0b                	jne    800e91 <__umoddi3+0x71>
  800e86:	b8 01 00 00 00       	mov    $0x1,%eax
  800e8b:	31 d2                	xor    %edx,%edx
  800e8d:	f7 f5                	div    %ebp
  800e8f:	89 c1                	mov    %eax,%ecx
  800e91:	89 d8                	mov    %ebx,%eax
  800e93:	31 d2                	xor    %edx,%edx
  800e95:	f7 f1                	div    %ecx
  800e97:	89 f0                	mov    %esi,%eax
  800e99:	f7 f1                	div    %ecx
  800e9b:	89 d0                	mov    %edx,%eax
  800e9d:	31 d2                	xor    %edx,%edx
  800e9f:	eb ac                	jmp    800e4d <__umoddi3+0x2d>
  800ea1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ea8:	8b 44 24 04          	mov    0x4(%esp),%eax
  800eac:	ba 20 00 00 00       	mov    $0x20,%edx
  800eb1:	29 c2                	sub    %eax,%edx
  800eb3:	89 c1                	mov    %eax,%ecx
  800eb5:	89 e8                	mov    %ebp,%eax
  800eb7:	d3 e7                	shl    %cl,%edi
  800eb9:	89 d1                	mov    %edx,%ecx
  800ebb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ebf:	d3 e8                	shr    %cl,%eax
  800ec1:	89 c1                	mov    %eax,%ecx
  800ec3:	8b 44 24 04          	mov    0x4(%esp),%eax
  800ec7:	09 f9                	or     %edi,%ecx
  800ec9:	89 df                	mov    %ebx,%edi
  800ecb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800ecf:	89 c1                	mov    %eax,%ecx
  800ed1:	d3 e5                	shl    %cl,%ebp
  800ed3:	89 d1                	mov    %edx,%ecx
  800ed5:	d3 ef                	shr    %cl,%edi
  800ed7:	89 c1                	mov    %eax,%ecx
  800ed9:	89 f0                	mov    %esi,%eax
  800edb:	d3 e3                	shl    %cl,%ebx
  800edd:	89 d1                	mov    %edx,%ecx
  800edf:	89 fa                	mov    %edi,%edx
  800ee1:	d3 e8                	shr    %cl,%eax
  800ee3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  800ee8:	09 d8                	or     %ebx,%eax
  800eea:	f7 74 24 08          	divl   0x8(%esp)
  800eee:	89 d3                	mov    %edx,%ebx
  800ef0:	d3 e6                	shl    %cl,%esi
  800ef2:	f7 e5                	mul    %ebp
  800ef4:	89 c7                	mov    %eax,%edi
  800ef6:	89 d1                	mov    %edx,%ecx
  800ef8:	39 d3                	cmp    %edx,%ebx
  800efa:	72 06                	jb     800f02 <__umoddi3+0xe2>
  800efc:	75 0e                	jne    800f0c <__umoddi3+0xec>
  800efe:	39 c6                	cmp    %eax,%esi
  800f00:	73 0a                	jae    800f0c <__umoddi3+0xec>
  800f02:	29 e8                	sub    %ebp,%eax
  800f04:	1b 54 24 08          	sbb    0x8(%esp),%edx
  800f08:	89 d1                	mov    %edx,%ecx
  800f0a:	89 c7                	mov    %eax,%edi
  800f0c:	89 f5                	mov    %esi,%ebp
  800f0e:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f12:	29 fd                	sub    %edi,%ebp
  800f14:	19 cb                	sbb    %ecx,%ebx
  800f16:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  800f1b:	89 d8                	mov    %ebx,%eax
  800f1d:	d3 e0                	shl    %cl,%eax
  800f1f:	89 f1                	mov    %esi,%ecx
  800f21:	d3 ed                	shr    %cl,%ebp
  800f23:	d3 eb                	shr    %cl,%ebx
  800f25:	09 e8                	or     %ebp,%eax
  800f27:	89 da                	mov    %ebx,%edx
  800f29:	83 c4 1c             	add    $0x1c,%esp
  800f2c:	5b                   	pop    %ebx
  800f2d:	5e                   	pop    %esi
  800f2e:	5f                   	pop    %edi
  800f2f:	5d                   	pop    %ebp
  800f30:	c3                   	ret    
