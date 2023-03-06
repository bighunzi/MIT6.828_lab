
obj/user/badsegment：     文件格式 elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void
umain(int argc, char **argv)
{
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800033:	66 b8 28 00          	mov    $0x28,%ax
  800037:	8e d8                	mov    %eax,%ds
}
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800045:	e8 c6 00 00 00       	call   800110 <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800052:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800057:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005c:	85 db                	test   %ebx,%ebx
  80005e:	7e 07                	jle    800067 <libmain+0x2d>
		binaryname = argv[0];
  800060:	8b 06                	mov    (%esi),%eax
  800062:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800067:	83 ec 08             	sub    $0x8,%esp
  80006a:	56                   	push   %esi
  80006b:	53                   	push   %ebx
  80006c:	e8 c2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800071:	e8 0a 00 00 00       	call   800080 <exit>
}
  800076:	83 c4 10             	add    $0x10,%esp
  800079:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007c:	5b                   	pop    %ebx
  80007d:	5e                   	pop    %esi
  80007e:	5d                   	pop    %ebp
  80007f:	c3                   	ret    

00800080 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  800086:	6a 00                	push   $0x0
  800088:	e8 42 00 00 00       	call   8000cf <sys_env_destroy>
}
  80008d:	83 c4 10             	add    $0x10,%esp
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	57                   	push   %edi
  800096:	56                   	push   %esi
  800097:	53                   	push   %ebx
	asm volatile("int %1\n"
  800098:	b8 00 00 00 00       	mov    $0x0,%eax
  80009d:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a3:	89 c3                	mov    %eax,%ebx
  8000a5:	89 c7                	mov    %eax,%edi
  8000a7:	89 c6                	mov    %eax,%esi
  8000a9:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ab:	5b                   	pop    %ebx
  8000ac:	5e                   	pop    %esi
  8000ad:	5f                   	pop    %edi
  8000ae:	5d                   	pop    %ebp
  8000af:	c3                   	ret    

008000b0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	57                   	push   %edi
  8000b4:	56                   	push   %esi
  8000b5:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c0:	89 d1                	mov    %edx,%ecx
  8000c2:	89 d3                	mov    %edx,%ebx
  8000c4:	89 d7                	mov    %edx,%edi
  8000c6:	89 d6                	mov    %edx,%esi
  8000c8:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ca:	5b                   	pop    %ebx
  8000cb:	5e                   	pop    %esi
  8000cc:	5f                   	pop    %edi
  8000cd:	5d                   	pop    %ebp
  8000ce:	c3                   	ret    

008000cf <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000cf:	55                   	push   %ebp
  8000d0:	89 e5                	mov    %esp,%ebp
  8000d2:	57                   	push   %edi
  8000d3:	56                   	push   %esi
  8000d4:	53                   	push   %ebx
  8000d5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e0:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e5:	89 cb                	mov    %ecx,%ebx
  8000e7:	89 cf                	mov    %ecx,%edi
  8000e9:	89 ce                	mov    %ecx,%esi
  8000eb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	7f 08                	jg     8000f9 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f4:	5b                   	pop    %ebx
  8000f5:	5e                   	pop    %esi
  8000f6:	5f                   	pop    %edi
  8000f7:	5d                   	pop    %ebp
  8000f8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f9:	83 ec 0c             	sub    $0xc,%esp
  8000fc:	50                   	push   %eax
  8000fd:	6a 03                	push   $0x3
  8000ff:	68 4a 0f 80 00       	push   $0x800f4a
  800104:	6a 2a                	push   $0x2a
  800106:	68 67 0f 80 00       	push   $0x800f67
  80010b:	e8 ed 01 00 00       	call   8002fd <_panic>

00800110 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	57                   	push   %edi
  800114:	56                   	push   %esi
  800115:	53                   	push   %ebx
	asm volatile("int %1\n"
  800116:	ba 00 00 00 00       	mov    $0x0,%edx
  80011b:	b8 02 00 00 00       	mov    $0x2,%eax
  800120:	89 d1                	mov    %edx,%ecx
  800122:	89 d3                	mov    %edx,%ebx
  800124:	89 d7                	mov    %edx,%edi
  800126:	89 d6                	mov    %edx,%esi
  800128:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    

0080012f <sys_yield>:

void
sys_yield(void)
{
  80012f:	55                   	push   %ebp
  800130:	89 e5                	mov    %esp,%ebp
  800132:	57                   	push   %edi
  800133:	56                   	push   %esi
  800134:	53                   	push   %ebx
	asm volatile("int %1\n"
  800135:	ba 00 00 00 00       	mov    $0x0,%edx
  80013a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80013f:	89 d1                	mov    %edx,%ecx
  800141:	89 d3                	mov    %edx,%ebx
  800143:	89 d7                	mov    %edx,%edi
  800145:	89 d6                	mov    %edx,%esi
  800147:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800149:	5b                   	pop    %ebx
  80014a:	5e                   	pop    %esi
  80014b:	5f                   	pop    %edi
  80014c:	5d                   	pop    %ebp
  80014d:	c3                   	ret    

0080014e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	57                   	push   %edi
  800152:	56                   	push   %esi
  800153:	53                   	push   %ebx
  800154:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800157:	be 00 00 00 00       	mov    $0x0,%esi
  80015c:	8b 55 08             	mov    0x8(%ebp),%edx
  80015f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800162:	b8 04 00 00 00       	mov    $0x4,%eax
  800167:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80016a:	89 f7                	mov    %esi,%edi
  80016c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80016e:	85 c0                	test   %eax,%eax
  800170:	7f 08                	jg     80017a <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800172:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800175:	5b                   	pop    %ebx
  800176:	5e                   	pop    %esi
  800177:	5f                   	pop    %edi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80017a:	83 ec 0c             	sub    $0xc,%esp
  80017d:	50                   	push   %eax
  80017e:	6a 04                	push   $0x4
  800180:	68 4a 0f 80 00       	push   $0x800f4a
  800185:	6a 2a                	push   $0x2a
  800187:	68 67 0f 80 00       	push   $0x800f67
  80018c:	e8 6c 01 00 00       	call   8002fd <_panic>

00800191 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800191:	55                   	push   %ebp
  800192:	89 e5                	mov    %esp,%ebp
  800194:	57                   	push   %edi
  800195:	56                   	push   %esi
  800196:	53                   	push   %ebx
  800197:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80019a:	8b 55 08             	mov    0x8(%ebp),%edx
  80019d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a0:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ab:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ae:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b0:	85 c0                	test   %eax,%eax
  8001b2:	7f 08                	jg     8001bc <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001b7:	5b                   	pop    %ebx
  8001b8:	5e                   	pop    %esi
  8001b9:	5f                   	pop    %edi
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bc:	83 ec 0c             	sub    $0xc,%esp
  8001bf:	50                   	push   %eax
  8001c0:	6a 05                	push   $0x5
  8001c2:	68 4a 0f 80 00       	push   $0x800f4a
  8001c7:	6a 2a                	push   $0x2a
  8001c9:	68 67 0f 80 00       	push   $0x800f67
  8001ce:	e8 2a 01 00 00       	call   8002fd <_panic>

008001d3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d3:	55                   	push   %ebp
  8001d4:	89 e5                	mov    %esp,%ebp
  8001d6:	57                   	push   %edi
  8001d7:	56                   	push   %esi
  8001d8:	53                   	push   %ebx
  8001d9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001dc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001e7:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ec:	89 df                	mov    %ebx,%edi
  8001ee:	89 de                	mov    %ebx,%esi
  8001f0:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001f2:	85 c0                	test   %eax,%eax
  8001f4:	7f 08                	jg     8001fe <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001f9:	5b                   	pop    %ebx
  8001fa:	5e                   	pop    %esi
  8001fb:	5f                   	pop    %edi
  8001fc:	5d                   	pop    %ebp
  8001fd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fe:	83 ec 0c             	sub    $0xc,%esp
  800201:	50                   	push   %eax
  800202:	6a 06                	push   $0x6
  800204:	68 4a 0f 80 00       	push   $0x800f4a
  800209:	6a 2a                	push   $0x2a
  80020b:	68 67 0f 80 00       	push   $0x800f67
  800210:	e8 e8 00 00 00       	call   8002fd <_panic>

00800215 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	57                   	push   %edi
  800219:	56                   	push   %esi
  80021a:	53                   	push   %ebx
  80021b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80021e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800223:	8b 55 08             	mov    0x8(%ebp),%edx
  800226:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800229:	b8 08 00 00 00       	mov    $0x8,%eax
  80022e:	89 df                	mov    %ebx,%edi
  800230:	89 de                	mov    %ebx,%esi
  800232:	cd 30                	int    $0x30
	if(check && ret > 0)
  800234:	85 c0                	test   %eax,%eax
  800236:	7f 08                	jg     800240 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800238:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023b:	5b                   	pop    %ebx
  80023c:	5e                   	pop    %esi
  80023d:	5f                   	pop    %edi
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800240:	83 ec 0c             	sub    $0xc,%esp
  800243:	50                   	push   %eax
  800244:	6a 08                	push   $0x8
  800246:	68 4a 0f 80 00       	push   $0x800f4a
  80024b:	6a 2a                	push   $0x2a
  80024d:	68 67 0f 80 00       	push   $0x800f67
  800252:	e8 a6 00 00 00       	call   8002fd <_panic>

00800257 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	57                   	push   %edi
  80025b:	56                   	push   %esi
  80025c:	53                   	push   %ebx
  80025d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800260:	bb 00 00 00 00       	mov    $0x0,%ebx
  800265:	8b 55 08             	mov    0x8(%ebp),%edx
  800268:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026b:	b8 09 00 00 00       	mov    $0x9,%eax
  800270:	89 df                	mov    %ebx,%edi
  800272:	89 de                	mov    %ebx,%esi
  800274:	cd 30                	int    $0x30
	if(check && ret > 0)
  800276:	85 c0                	test   %eax,%eax
  800278:	7f 08                	jg     800282 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80027a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80027d:	5b                   	pop    %ebx
  80027e:	5e                   	pop    %esi
  80027f:	5f                   	pop    %edi
  800280:	5d                   	pop    %ebp
  800281:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800282:	83 ec 0c             	sub    $0xc,%esp
  800285:	50                   	push   %eax
  800286:	6a 09                	push   $0x9
  800288:	68 4a 0f 80 00       	push   $0x800f4a
  80028d:	6a 2a                	push   $0x2a
  80028f:	68 67 0f 80 00       	push   $0x800f67
  800294:	e8 64 00 00 00       	call   8002fd <_panic>

00800299 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800299:	55                   	push   %ebp
  80029a:	89 e5                	mov    %esp,%ebp
  80029c:	57                   	push   %edi
  80029d:	56                   	push   %esi
  80029e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80029f:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a5:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002aa:	be 00 00 00 00       	mov    $0x0,%esi
  8002af:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b5:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002b7:	5b                   	pop    %ebx
  8002b8:	5e                   	pop    %esi
  8002b9:	5f                   	pop    %edi
  8002ba:	5d                   	pop    %ebp
  8002bb:	c3                   	ret    

008002bc <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002bc:	55                   	push   %ebp
  8002bd:	89 e5                	mov    %esp,%ebp
  8002bf:	57                   	push   %edi
  8002c0:	56                   	push   %esi
  8002c1:	53                   	push   %ebx
  8002c2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002d2:	89 cb                	mov    %ecx,%ebx
  8002d4:	89 cf                	mov    %ecx,%edi
  8002d6:	89 ce                	mov    %ecx,%esi
  8002d8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7f 08                	jg     8002e6 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e6:	83 ec 0c             	sub    $0xc,%esp
  8002e9:	50                   	push   %eax
  8002ea:	6a 0c                	push   $0xc
  8002ec:	68 4a 0f 80 00       	push   $0x800f4a
  8002f1:	6a 2a                	push   $0x2a
  8002f3:	68 67 0f 80 00       	push   $0x800f67
  8002f8:	e8 00 00 00 00       	call   8002fd <_panic>

008002fd <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	56                   	push   %esi
  800301:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800302:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800305:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80030b:	e8 00 fe ff ff       	call   800110 <sys_getenvid>
  800310:	83 ec 0c             	sub    $0xc,%esp
  800313:	ff 75 0c             	push   0xc(%ebp)
  800316:	ff 75 08             	push   0x8(%ebp)
  800319:	56                   	push   %esi
  80031a:	50                   	push   %eax
  80031b:	68 78 0f 80 00       	push   $0x800f78
  800320:	e8 b3 00 00 00       	call   8003d8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800325:	83 c4 18             	add    $0x18,%esp
  800328:	53                   	push   %ebx
  800329:	ff 75 10             	push   0x10(%ebp)
  80032c:	e8 56 00 00 00       	call   800387 <vcprintf>
	cprintf("\n");
  800331:	c7 04 24 9b 0f 80 00 	movl   $0x800f9b,(%esp)
  800338:	e8 9b 00 00 00       	call   8003d8 <cprintf>
  80033d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800340:	cc                   	int3   
  800341:	eb fd                	jmp    800340 <_panic+0x43>

00800343 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	53                   	push   %ebx
  800347:	83 ec 04             	sub    $0x4,%esp
  80034a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80034d:	8b 13                	mov    (%ebx),%edx
  80034f:	8d 42 01             	lea    0x1(%edx),%eax
  800352:	89 03                	mov    %eax,(%ebx)
  800354:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800357:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80035b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800360:	74 09                	je     80036b <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800362:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800366:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800369:	c9                   	leave  
  80036a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80036b:	83 ec 08             	sub    $0x8,%esp
  80036e:	68 ff 00 00 00       	push   $0xff
  800373:	8d 43 08             	lea    0x8(%ebx),%eax
  800376:	50                   	push   %eax
  800377:	e8 16 fd ff ff       	call   800092 <sys_cputs>
		b->idx = 0;
  80037c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800382:	83 c4 10             	add    $0x10,%esp
  800385:	eb db                	jmp    800362 <putch+0x1f>

00800387 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
  80038a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800390:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800397:	00 00 00 
	b.cnt = 0;
  80039a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003a1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a4:	ff 75 0c             	push   0xc(%ebp)
  8003a7:	ff 75 08             	push   0x8(%ebp)
  8003aa:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003b0:	50                   	push   %eax
  8003b1:	68 43 03 80 00       	push   $0x800343
  8003b6:	e8 14 01 00 00       	call   8004cf <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003bb:	83 c4 08             	add    $0x8,%esp
  8003be:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8003c4:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ca:	50                   	push   %eax
  8003cb:	e8 c2 fc ff ff       	call   800092 <sys_cputs>

	return b.cnt;
}
  8003d0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003d6:	c9                   	leave  
  8003d7:	c3                   	ret    

008003d8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003de:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003e1:	50                   	push   %eax
  8003e2:	ff 75 08             	push   0x8(%ebp)
  8003e5:	e8 9d ff ff ff       	call   800387 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003ea:	c9                   	leave  
  8003eb:	c3                   	ret    

008003ec <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ec:	55                   	push   %ebp
  8003ed:	89 e5                	mov    %esp,%ebp
  8003ef:	57                   	push   %edi
  8003f0:	56                   	push   %esi
  8003f1:	53                   	push   %ebx
  8003f2:	83 ec 1c             	sub    $0x1c,%esp
  8003f5:	89 c7                	mov    %eax,%edi
  8003f7:	89 d6                	mov    %edx,%esi
  8003f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ff:	89 d1                	mov    %edx,%ecx
  800401:	89 c2                	mov    %eax,%edx
  800403:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800406:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800409:	8b 45 10             	mov    0x10(%ebp),%eax
  80040c:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80040f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800412:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800419:	39 c2                	cmp    %eax,%edx
  80041b:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80041e:	72 3e                	jb     80045e <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800420:	83 ec 0c             	sub    $0xc,%esp
  800423:	ff 75 18             	push   0x18(%ebp)
  800426:	83 eb 01             	sub    $0x1,%ebx
  800429:	53                   	push   %ebx
  80042a:	50                   	push   %eax
  80042b:	83 ec 08             	sub    $0x8,%esp
  80042e:	ff 75 e4             	push   -0x1c(%ebp)
  800431:	ff 75 e0             	push   -0x20(%ebp)
  800434:	ff 75 dc             	push   -0x24(%ebp)
  800437:	ff 75 d8             	push   -0x28(%ebp)
  80043a:	e8 c1 08 00 00       	call   800d00 <__udivdi3>
  80043f:	83 c4 18             	add    $0x18,%esp
  800442:	52                   	push   %edx
  800443:	50                   	push   %eax
  800444:	89 f2                	mov    %esi,%edx
  800446:	89 f8                	mov    %edi,%eax
  800448:	e8 9f ff ff ff       	call   8003ec <printnum>
  80044d:	83 c4 20             	add    $0x20,%esp
  800450:	eb 13                	jmp    800465 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800452:	83 ec 08             	sub    $0x8,%esp
  800455:	56                   	push   %esi
  800456:	ff 75 18             	push   0x18(%ebp)
  800459:	ff d7                	call   *%edi
  80045b:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80045e:	83 eb 01             	sub    $0x1,%ebx
  800461:	85 db                	test   %ebx,%ebx
  800463:	7f ed                	jg     800452 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	56                   	push   %esi
  800469:	83 ec 04             	sub    $0x4,%esp
  80046c:	ff 75 e4             	push   -0x1c(%ebp)
  80046f:	ff 75 e0             	push   -0x20(%ebp)
  800472:	ff 75 dc             	push   -0x24(%ebp)
  800475:	ff 75 d8             	push   -0x28(%ebp)
  800478:	e8 a3 09 00 00       	call   800e20 <__umoddi3>
  80047d:	83 c4 14             	add    $0x14,%esp
  800480:	0f be 80 9d 0f 80 00 	movsbl 0x800f9d(%eax),%eax
  800487:	50                   	push   %eax
  800488:	ff d7                	call   *%edi
}
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800490:	5b                   	pop    %ebx
  800491:	5e                   	pop    %esi
  800492:	5f                   	pop    %edi
  800493:	5d                   	pop    %ebp
  800494:	c3                   	ret    

00800495 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800495:	55                   	push   %ebp
  800496:	89 e5                	mov    %esp,%ebp
  800498:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80049b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80049f:	8b 10                	mov    (%eax),%edx
  8004a1:	3b 50 04             	cmp    0x4(%eax),%edx
  8004a4:	73 0a                	jae    8004b0 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004a6:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004a9:	89 08                	mov    %ecx,(%eax)
  8004ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ae:	88 02                	mov    %al,(%edx)
}
  8004b0:	5d                   	pop    %ebp
  8004b1:	c3                   	ret    

008004b2 <printfmt>:
{
  8004b2:	55                   	push   %ebp
  8004b3:	89 e5                	mov    %esp,%ebp
  8004b5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004b8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004bb:	50                   	push   %eax
  8004bc:	ff 75 10             	push   0x10(%ebp)
  8004bf:	ff 75 0c             	push   0xc(%ebp)
  8004c2:	ff 75 08             	push   0x8(%ebp)
  8004c5:	e8 05 00 00 00       	call   8004cf <vprintfmt>
}
  8004ca:	83 c4 10             	add    $0x10,%esp
  8004cd:	c9                   	leave  
  8004ce:	c3                   	ret    

008004cf <vprintfmt>:
{
  8004cf:	55                   	push   %ebp
  8004d0:	89 e5                	mov    %esp,%ebp
  8004d2:	57                   	push   %edi
  8004d3:	56                   	push   %esi
  8004d4:	53                   	push   %ebx
  8004d5:	83 ec 3c             	sub    $0x3c,%esp
  8004d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004de:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004e1:	eb 0a                	jmp    8004ed <vprintfmt+0x1e>
			putch(ch, putdat);
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	53                   	push   %ebx
  8004e7:	50                   	push   %eax
  8004e8:	ff d6                	call   *%esi
  8004ea:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004ed:	83 c7 01             	add    $0x1,%edi
  8004f0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f4:	83 f8 25             	cmp    $0x25,%eax
  8004f7:	74 0c                	je     800505 <vprintfmt+0x36>
			if (ch == '\0')
  8004f9:	85 c0                	test   %eax,%eax
  8004fb:	75 e6                	jne    8004e3 <vprintfmt+0x14>
}
  8004fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800500:	5b                   	pop    %ebx
  800501:	5e                   	pop    %esi
  800502:	5f                   	pop    %edi
  800503:	5d                   	pop    %ebp
  800504:	c3                   	ret    
		padc = ' ';
  800505:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800509:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800510:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800517:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80051e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800523:	8d 47 01             	lea    0x1(%edi),%eax
  800526:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800529:	0f b6 17             	movzbl (%edi),%edx
  80052c:	8d 42 dd             	lea    -0x23(%edx),%eax
  80052f:	3c 55                	cmp    $0x55,%al
  800531:	0f 87 bb 03 00 00    	ja     8008f2 <vprintfmt+0x423>
  800537:	0f b6 c0             	movzbl %al,%eax
  80053a:	ff 24 85 60 10 80 00 	jmp    *0x801060(,%eax,4)
  800541:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800544:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800548:	eb d9                	jmp    800523 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80054a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80054d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800551:	eb d0                	jmp    800523 <vprintfmt+0x54>
  800553:	0f b6 d2             	movzbl %dl,%edx
  800556:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800559:	b8 00 00 00 00       	mov    $0x0,%eax
  80055e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800561:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800564:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800568:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80056b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80056e:	83 f9 09             	cmp    $0x9,%ecx
  800571:	77 55                	ja     8005c8 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800573:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800576:	eb e9                	jmp    800561 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8b 00                	mov    (%eax),%eax
  80057d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800580:	8b 45 14             	mov    0x14(%ebp),%eax
  800583:	8d 40 04             	lea    0x4(%eax),%eax
  800586:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800589:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80058c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800590:	79 91                	jns    800523 <vprintfmt+0x54>
				width = precision, precision = -1;
  800592:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800595:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800598:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80059f:	eb 82                	jmp    800523 <vprintfmt+0x54>
  8005a1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005a4:	85 d2                	test   %edx,%edx
  8005a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ab:	0f 49 c2             	cmovns %edx,%eax
  8005ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005b4:	e9 6a ff ff ff       	jmp    800523 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005bc:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005c3:	e9 5b ff ff ff       	jmp    800523 <vprintfmt+0x54>
  8005c8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ce:	eb bc                	jmp    80058c <vprintfmt+0xbd>
			lflag++;
  8005d0:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005d6:	e9 48 ff ff ff       	jmp    800523 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8d 78 04             	lea    0x4(%eax),%edi
  8005e1:	83 ec 08             	sub    $0x8,%esp
  8005e4:	53                   	push   %ebx
  8005e5:	ff 30                	push   (%eax)
  8005e7:	ff d6                	call   *%esi
			break;
  8005e9:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005ec:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005ef:	e9 9d 02 00 00       	jmp    800891 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 78 04             	lea    0x4(%eax),%edi
  8005fa:	8b 10                	mov    (%eax),%edx
  8005fc:	89 d0                	mov    %edx,%eax
  8005fe:	f7 d8                	neg    %eax
  800600:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800603:	83 f8 08             	cmp    $0x8,%eax
  800606:	7f 23                	jg     80062b <vprintfmt+0x15c>
  800608:	8b 14 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%edx
  80060f:	85 d2                	test   %edx,%edx
  800611:	74 18                	je     80062b <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800613:	52                   	push   %edx
  800614:	68 be 0f 80 00       	push   $0x800fbe
  800619:	53                   	push   %ebx
  80061a:	56                   	push   %esi
  80061b:	e8 92 fe ff ff       	call   8004b2 <printfmt>
  800620:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800623:	89 7d 14             	mov    %edi,0x14(%ebp)
  800626:	e9 66 02 00 00       	jmp    800891 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80062b:	50                   	push   %eax
  80062c:	68 b5 0f 80 00       	push   $0x800fb5
  800631:	53                   	push   %ebx
  800632:	56                   	push   %esi
  800633:	e8 7a fe ff ff       	call   8004b2 <printfmt>
  800638:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80063b:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80063e:	e9 4e 02 00 00       	jmp    800891 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	83 c0 04             	add    $0x4,%eax
  800649:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80064c:	8b 45 14             	mov    0x14(%ebp),%eax
  80064f:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800651:	85 d2                	test   %edx,%edx
  800653:	b8 ae 0f 80 00       	mov    $0x800fae,%eax
  800658:	0f 45 c2             	cmovne %edx,%eax
  80065b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80065e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800662:	7e 06                	jle    80066a <vprintfmt+0x19b>
  800664:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800668:	75 0d                	jne    800677 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80066a:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80066d:	89 c7                	mov    %eax,%edi
  80066f:	03 45 e0             	add    -0x20(%ebp),%eax
  800672:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800675:	eb 55                	jmp    8006cc <vprintfmt+0x1fd>
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	ff 75 d8             	push   -0x28(%ebp)
  80067d:	ff 75 cc             	push   -0x34(%ebp)
  800680:	e8 0a 03 00 00       	call   80098f <strnlen>
  800685:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800688:	29 c1                	sub    %eax,%ecx
  80068a:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80068d:	83 c4 10             	add    $0x10,%esp
  800690:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800692:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800696:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800699:	eb 0f                	jmp    8006aa <vprintfmt+0x1db>
					putch(padc, putdat);
  80069b:	83 ec 08             	sub    $0x8,%esp
  80069e:	53                   	push   %ebx
  80069f:	ff 75 e0             	push   -0x20(%ebp)
  8006a2:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a4:	83 ef 01             	sub    $0x1,%edi
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	85 ff                	test   %edi,%edi
  8006ac:	7f ed                	jg     80069b <vprintfmt+0x1cc>
  8006ae:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006b1:	85 d2                	test   %edx,%edx
  8006b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b8:	0f 49 c2             	cmovns %edx,%eax
  8006bb:	29 c2                	sub    %eax,%edx
  8006bd:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006c0:	eb a8                	jmp    80066a <vprintfmt+0x19b>
					putch(ch, putdat);
  8006c2:	83 ec 08             	sub    $0x8,%esp
  8006c5:	53                   	push   %ebx
  8006c6:	52                   	push   %edx
  8006c7:	ff d6                	call   *%esi
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006cf:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d1:	83 c7 01             	add    $0x1,%edi
  8006d4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006d8:	0f be d0             	movsbl %al,%edx
  8006db:	85 d2                	test   %edx,%edx
  8006dd:	74 4b                	je     80072a <vprintfmt+0x25b>
  8006df:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006e3:	78 06                	js     8006eb <vprintfmt+0x21c>
  8006e5:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8006e9:	78 1e                	js     800709 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8006eb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006ef:	74 d1                	je     8006c2 <vprintfmt+0x1f3>
  8006f1:	0f be c0             	movsbl %al,%eax
  8006f4:	83 e8 20             	sub    $0x20,%eax
  8006f7:	83 f8 5e             	cmp    $0x5e,%eax
  8006fa:	76 c6                	jbe    8006c2 <vprintfmt+0x1f3>
					putch('?', putdat);
  8006fc:	83 ec 08             	sub    $0x8,%esp
  8006ff:	53                   	push   %ebx
  800700:	6a 3f                	push   $0x3f
  800702:	ff d6                	call   *%esi
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	eb c3                	jmp    8006cc <vprintfmt+0x1fd>
  800709:	89 cf                	mov    %ecx,%edi
  80070b:	eb 0e                	jmp    80071b <vprintfmt+0x24c>
				putch(' ', putdat);
  80070d:	83 ec 08             	sub    $0x8,%esp
  800710:	53                   	push   %ebx
  800711:	6a 20                	push   $0x20
  800713:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800715:	83 ef 01             	sub    $0x1,%edi
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	85 ff                	test   %edi,%edi
  80071d:	7f ee                	jg     80070d <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80071f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800722:	89 45 14             	mov    %eax,0x14(%ebp)
  800725:	e9 67 01 00 00       	jmp    800891 <vprintfmt+0x3c2>
  80072a:	89 cf                	mov    %ecx,%edi
  80072c:	eb ed                	jmp    80071b <vprintfmt+0x24c>
	if (lflag >= 2)
  80072e:	83 f9 01             	cmp    $0x1,%ecx
  800731:	7f 1b                	jg     80074e <vprintfmt+0x27f>
	else if (lflag)
  800733:	85 c9                	test   %ecx,%ecx
  800735:	74 63                	je     80079a <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  800737:	8b 45 14             	mov    0x14(%ebp),%eax
  80073a:	8b 00                	mov    (%eax),%eax
  80073c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80073f:	99                   	cltd   
  800740:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800743:	8b 45 14             	mov    0x14(%ebp),%eax
  800746:	8d 40 04             	lea    0x4(%eax),%eax
  800749:	89 45 14             	mov    %eax,0x14(%ebp)
  80074c:	eb 17                	jmp    800765 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80074e:	8b 45 14             	mov    0x14(%ebp),%eax
  800751:	8b 50 04             	mov    0x4(%eax),%edx
  800754:	8b 00                	mov    (%eax),%eax
  800756:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800759:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80075c:	8b 45 14             	mov    0x14(%ebp),%eax
  80075f:	8d 40 08             	lea    0x8(%eax),%eax
  800762:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800765:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800768:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80076b:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800770:	85 c9                	test   %ecx,%ecx
  800772:	0f 89 ff 00 00 00    	jns    800877 <vprintfmt+0x3a8>
				putch('-', putdat);
  800778:	83 ec 08             	sub    $0x8,%esp
  80077b:	53                   	push   %ebx
  80077c:	6a 2d                	push   $0x2d
  80077e:	ff d6                	call   *%esi
				num = -(long long) num;
  800780:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800783:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800786:	f7 da                	neg    %edx
  800788:	83 d1 00             	adc    $0x0,%ecx
  80078b:	f7 d9                	neg    %ecx
  80078d:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800790:	bf 0a 00 00 00       	mov    $0xa,%edi
  800795:	e9 dd 00 00 00       	jmp    800877 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80079a:	8b 45 14             	mov    0x14(%ebp),%eax
  80079d:	8b 00                	mov    (%eax),%eax
  80079f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a2:	99                   	cltd   
  8007a3:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a9:	8d 40 04             	lea    0x4(%eax),%eax
  8007ac:	89 45 14             	mov    %eax,0x14(%ebp)
  8007af:	eb b4                	jmp    800765 <vprintfmt+0x296>
	if (lflag >= 2)
  8007b1:	83 f9 01             	cmp    $0x1,%ecx
  8007b4:	7f 1e                	jg     8007d4 <vprintfmt+0x305>
	else if (lflag)
  8007b6:	85 c9                	test   %ecx,%ecx
  8007b8:	74 32                	je     8007ec <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8007ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8007bd:	8b 10                	mov    (%eax),%edx
  8007bf:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c4:	8d 40 04             	lea    0x4(%eax),%eax
  8007c7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007ca:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8007cf:	e9 a3 00 00 00       	jmp    800877 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	8b 10                	mov    (%eax),%edx
  8007d9:	8b 48 04             	mov    0x4(%eax),%ecx
  8007dc:	8d 40 08             	lea    0x8(%eax),%eax
  8007df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007e2:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8007e7:	e9 8b 00 00 00       	jmp    800877 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ef:	8b 10                	mov    (%eax),%edx
  8007f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007f6:	8d 40 04             	lea    0x4(%eax),%eax
  8007f9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007fc:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800801:	eb 74                	jmp    800877 <vprintfmt+0x3a8>
	if (lflag >= 2)
  800803:	83 f9 01             	cmp    $0x1,%ecx
  800806:	7f 1b                	jg     800823 <vprintfmt+0x354>
	else if (lflag)
  800808:	85 c9                	test   %ecx,%ecx
  80080a:	74 2c                	je     800838 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  80080c:	8b 45 14             	mov    0x14(%ebp),%eax
  80080f:	8b 10                	mov    (%eax),%edx
  800811:	b9 00 00 00 00       	mov    $0x0,%ecx
  800816:	8d 40 04             	lea    0x4(%eax),%eax
  800819:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80081c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800821:	eb 54                	jmp    800877 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800823:	8b 45 14             	mov    0x14(%ebp),%eax
  800826:	8b 10                	mov    (%eax),%edx
  800828:	8b 48 04             	mov    0x4(%eax),%ecx
  80082b:	8d 40 08             	lea    0x8(%eax),%eax
  80082e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800831:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  800836:	eb 3f                	jmp    800877 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  800838:	8b 45 14             	mov    0x14(%ebp),%eax
  80083b:	8b 10                	mov    (%eax),%edx
  80083d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800842:	8d 40 04             	lea    0x4(%eax),%eax
  800845:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800848:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80084d:	eb 28                	jmp    800877 <vprintfmt+0x3a8>
			putch('0', putdat);
  80084f:	83 ec 08             	sub    $0x8,%esp
  800852:	53                   	push   %ebx
  800853:	6a 30                	push   $0x30
  800855:	ff d6                	call   *%esi
			putch('x', putdat);
  800857:	83 c4 08             	add    $0x8,%esp
  80085a:	53                   	push   %ebx
  80085b:	6a 78                	push   $0x78
  80085d:	ff d6                	call   *%esi
			num = (unsigned long long)
  80085f:	8b 45 14             	mov    0x14(%ebp),%eax
  800862:	8b 10                	mov    (%eax),%edx
  800864:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800869:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80086c:	8d 40 04             	lea    0x4(%eax),%eax
  80086f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800872:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  800877:	83 ec 0c             	sub    $0xc,%esp
  80087a:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80087e:	50                   	push   %eax
  80087f:	ff 75 e0             	push   -0x20(%ebp)
  800882:	57                   	push   %edi
  800883:	51                   	push   %ecx
  800884:	52                   	push   %edx
  800885:	89 da                	mov    %ebx,%edx
  800887:	89 f0                	mov    %esi,%eax
  800889:	e8 5e fb ff ff       	call   8003ec <printnum>
			break;
  80088e:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800891:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800894:	e9 54 fc ff ff       	jmp    8004ed <vprintfmt+0x1e>
	if (lflag >= 2)
  800899:	83 f9 01             	cmp    $0x1,%ecx
  80089c:	7f 1b                	jg     8008b9 <vprintfmt+0x3ea>
	else if (lflag)
  80089e:	85 c9                	test   %ecx,%ecx
  8008a0:	74 2c                	je     8008ce <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8008a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a5:	8b 10                	mov    (%eax),%edx
  8008a7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ac:	8d 40 04             	lea    0x4(%eax),%eax
  8008af:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008b2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8008b7:	eb be                	jmp    800877 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8008b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bc:	8b 10                	mov    (%eax),%edx
  8008be:	8b 48 04             	mov    0x4(%eax),%ecx
  8008c1:	8d 40 08             	lea    0x8(%eax),%eax
  8008c4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008c7:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8008cc:	eb a9                	jmp    800877 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8008ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d1:	8b 10                	mov    (%eax),%edx
  8008d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008d8:	8d 40 04             	lea    0x4(%eax),%eax
  8008db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008de:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8008e3:	eb 92                	jmp    800877 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8008e5:	83 ec 08             	sub    $0x8,%esp
  8008e8:	53                   	push   %ebx
  8008e9:	6a 25                	push   $0x25
  8008eb:	ff d6                	call   *%esi
			break;
  8008ed:	83 c4 10             	add    $0x10,%esp
  8008f0:	eb 9f                	jmp    800891 <vprintfmt+0x3c2>
			putch('%', putdat);
  8008f2:	83 ec 08             	sub    $0x8,%esp
  8008f5:	53                   	push   %ebx
  8008f6:	6a 25                	push   $0x25
  8008f8:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008fa:	83 c4 10             	add    $0x10,%esp
  8008fd:	89 f8                	mov    %edi,%eax
  8008ff:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800903:	74 05                	je     80090a <vprintfmt+0x43b>
  800905:	83 e8 01             	sub    $0x1,%eax
  800908:	eb f5                	jmp    8008ff <vprintfmt+0x430>
  80090a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80090d:	eb 82                	jmp    800891 <vprintfmt+0x3c2>

0080090f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80090f:	55                   	push   %ebp
  800910:	89 e5                	mov    %esp,%ebp
  800912:	83 ec 18             	sub    $0x18,%esp
  800915:	8b 45 08             	mov    0x8(%ebp),%eax
  800918:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80091b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80091e:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800922:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800925:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80092c:	85 c0                	test   %eax,%eax
  80092e:	74 26                	je     800956 <vsnprintf+0x47>
  800930:	85 d2                	test   %edx,%edx
  800932:	7e 22                	jle    800956 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800934:	ff 75 14             	push   0x14(%ebp)
  800937:	ff 75 10             	push   0x10(%ebp)
  80093a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80093d:	50                   	push   %eax
  80093e:	68 95 04 80 00       	push   $0x800495
  800943:	e8 87 fb ff ff       	call   8004cf <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800948:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80094b:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80094e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800951:	83 c4 10             	add    $0x10,%esp
}
  800954:	c9                   	leave  
  800955:	c3                   	ret    
		return -E_INVAL;
  800956:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80095b:	eb f7                	jmp    800954 <vsnprintf+0x45>

0080095d <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80095d:	55                   	push   %ebp
  80095e:	89 e5                	mov    %esp,%ebp
  800960:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800963:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800966:	50                   	push   %eax
  800967:	ff 75 10             	push   0x10(%ebp)
  80096a:	ff 75 0c             	push   0xc(%ebp)
  80096d:	ff 75 08             	push   0x8(%ebp)
  800970:	e8 9a ff ff ff       	call   80090f <vsnprintf>
	va_end(ap);

	return rc;
}
  800975:	c9                   	leave  
  800976:	c3                   	ret    

00800977 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80097d:	b8 00 00 00 00       	mov    $0x0,%eax
  800982:	eb 03                	jmp    800987 <strlen+0x10>
		n++;
  800984:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  800987:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80098b:	75 f7                	jne    800984 <strlen+0xd>
	return n;
}
  80098d:	5d                   	pop    %ebp
  80098e:	c3                   	ret    

0080098f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80098f:	55                   	push   %ebp
  800990:	89 e5                	mov    %esp,%ebp
  800992:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800995:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800998:	b8 00 00 00 00       	mov    $0x0,%eax
  80099d:	eb 03                	jmp    8009a2 <strnlen+0x13>
		n++;
  80099f:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a2:	39 d0                	cmp    %edx,%eax
  8009a4:	74 08                	je     8009ae <strnlen+0x1f>
  8009a6:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009aa:	75 f3                	jne    80099f <strnlen+0x10>
  8009ac:	89 c2                	mov    %eax,%edx
	return n;
}
  8009ae:	89 d0                	mov    %edx,%eax
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
  8009b5:	53                   	push   %ebx
  8009b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c1:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8009c5:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8009c8:	83 c0 01             	add    $0x1,%eax
  8009cb:	84 d2                	test   %dl,%dl
  8009cd:	75 f2                	jne    8009c1 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009cf:	89 c8                	mov    %ecx,%eax
  8009d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d4:	c9                   	leave  
  8009d5:	c3                   	ret    

008009d6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	53                   	push   %ebx
  8009da:	83 ec 10             	sub    $0x10,%esp
  8009dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009e0:	53                   	push   %ebx
  8009e1:	e8 91 ff ff ff       	call   800977 <strlen>
  8009e6:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8009e9:	ff 75 0c             	push   0xc(%ebp)
  8009ec:	01 d8                	add    %ebx,%eax
  8009ee:	50                   	push   %eax
  8009ef:	e8 be ff ff ff       	call   8009b2 <strcpy>
	return dst;
}
  8009f4:	89 d8                	mov    %ebx,%eax
  8009f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f9:	c9                   	leave  
  8009fa:	c3                   	ret    

008009fb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	56                   	push   %esi
  8009ff:	53                   	push   %ebx
  800a00:	8b 75 08             	mov    0x8(%ebp),%esi
  800a03:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a06:	89 f3                	mov    %esi,%ebx
  800a08:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a0b:	89 f0                	mov    %esi,%eax
  800a0d:	eb 0f                	jmp    800a1e <strncpy+0x23>
		*dst++ = *src;
  800a0f:	83 c0 01             	add    $0x1,%eax
  800a12:	0f b6 0a             	movzbl (%edx),%ecx
  800a15:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a18:	80 f9 01             	cmp    $0x1,%cl
  800a1b:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800a1e:	39 d8                	cmp    %ebx,%eax
  800a20:	75 ed                	jne    800a0f <strncpy+0x14>
	}
	return ret;
}
  800a22:	89 f0                	mov    %esi,%eax
  800a24:	5b                   	pop    %ebx
  800a25:	5e                   	pop    %esi
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	56                   	push   %esi
  800a2c:	53                   	push   %ebx
  800a2d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a33:	8b 55 10             	mov    0x10(%ebp),%edx
  800a36:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a38:	85 d2                	test   %edx,%edx
  800a3a:	74 21                	je     800a5d <strlcpy+0x35>
  800a3c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a40:	89 f2                	mov    %esi,%edx
  800a42:	eb 09                	jmp    800a4d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a44:	83 c1 01             	add    $0x1,%ecx
  800a47:	83 c2 01             	add    $0x1,%edx
  800a4a:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800a4d:	39 c2                	cmp    %eax,%edx
  800a4f:	74 09                	je     800a5a <strlcpy+0x32>
  800a51:	0f b6 19             	movzbl (%ecx),%ebx
  800a54:	84 db                	test   %bl,%bl
  800a56:	75 ec                	jne    800a44 <strlcpy+0x1c>
  800a58:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a5a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a5d:	29 f0                	sub    %esi,%eax
}
  800a5f:	5b                   	pop    %ebx
  800a60:	5e                   	pop    %esi
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a69:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a6c:	eb 06                	jmp    800a74 <strcmp+0x11>
		p++, q++;
  800a6e:	83 c1 01             	add    $0x1,%ecx
  800a71:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a74:	0f b6 01             	movzbl (%ecx),%eax
  800a77:	84 c0                	test   %al,%al
  800a79:	74 04                	je     800a7f <strcmp+0x1c>
  800a7b:	3a 02                	cmp    (%edx),%al
  800a7d:	74 ef                	je     800a6e <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a7f:	0f b6 c0             	movzbl %al,%eax
  800a82:	0f b6 12             	movzbl (%edx),%edx
  800a85:	29 d0                	sub    %edx,%eax
}
  800a87:	5d                   	pop    %ebp
  800a88:	c3                   	ret    

00800a89 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	53                   	push   %ebx
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a93:	89 c3                	mov    %eax,%ebx
  800a95:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a98:	eb 06                	jmp    800aa0 <strncmp+0x17>
		n--, p++, q++;
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800aa0:	39 d8                	cmp    %ebx,%eax
  800aa2:	74 18                	je     800abc <strncmp+0x33>
  800aa4:	0f b6 08             	movzbl (%eax),%ecx
  800aa7:	84 c9                	test   %cl,%cl
  800aa9:	74 04                	je     800aaf <strncmp+0x26>
  800aab:	3a 0a                	cmp    (%edx),%cl
  800aad:	74 eb                	je     800a9a <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aaf:	0f b6 00             	movzbl (%eax),%eax
  800ab2:	0f b6 12             	movzbl (%edx),%edx
  800ab5:	29 d0                	sub    %edx,%eax
}
  800ab7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aba:	c9                   	leave  
  800abb:	c3                   	ret    
		return 0;
  800abc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac1:	eb f4                	jmp    800ab7 <strncmp+0x2e>

00800ac3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ac3:	55                   	push   %ebp
  800ac4:	89 e5                	mov    %esp,%ebp
  800ac6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800acd:	eb 03                	jmp    800ad2 <strchr+0xf>
  800acf:	83 c0 01             	add    $0x1,%eax
  800ad2:	0f b6 10             	movzbl (%eax),%edx
  800ad5:	84 d2                	test   %dl,%dl
  800ad7:	74 06                	je     800adf <strchr+0x1c>
		if (*s == c)
  800ad9:	38 ca                	cmp    %cl,%dl
  800adb:	75 f2                	jne    800acf <strchr+0xc>
  800add:	eb 05                	jmp    800ae4 <strchr+0x21>
			return (char *) s;
	return 0;
  800adf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  800aec:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800af3:	38 ca                	cmp    %cl,%dl
  800af5:	74 09                	je     800b00 <strfind+0x1a>
  800af7:	84 d2                	test   %dl,%dl
  800af9:	74 05                	je     800b00 <strfind+0x1a>
	for (; *s; s++)
  800afb:	83 c0 01             	add    $0x1,%eax
  800afe:	eb f0                	jmp    800af0 <strfind+0xa>
			break;
	return (char *) s;
}
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b0b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b0e:	85 c9                	test   %ecx,%ecx
  800b10:	74 2f                	je     800b41 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b12:	89 f8                	mov    %edi,%eax
  800b14:	09 c8                	or     %ecx,%eax
  800b16:	a8 03                	test   $0x3,%al
  800b18:	75 21                	jne    800b3b <memset+0x39>
		c &= 0xFF;
  800b1a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b1e:	89 d0                	mov    %edx,%eax
  800b20:	c1 e0 08             	shl    $0x8,%eax
  800b23:	89 d3                	mov    %edx,%ebx
  800b25:	c1 e3 18             	shl    $0x18,%ebx
  800b28:	89 d6                	mov    %edx,%esi
  800b2a:	c1 e6 10             	shl    $0x10,%esi
  800b2d:	09 f3                	or     %esi,%ebx
  800b2f:	09 da                	or     %ebx,%edx
  800b31:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b33:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b36:	fc                   	cld    
  800b37:	f3 ab                	rep stos %eax,%es:(%edi)
  800b39:	eb 06                	jmp    800b41 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3e:	fc                   	cld    
  800b3f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b41:	89 f8                	mov    %edi,%eax
  800b43:	5b                   	pop    %ebx
  800b44:	5e                   	pop    %esi
  800b45:	5f                   	pop    %edi
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b50:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b53:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b56:	39 c6                	cmp    %eax,%esi
  800b58:	73 32                	jae    800b8c <memmove+0x44>
  800b5a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b5d:	39 c2                	cmp    %eax,%edx
  800b5f:	76 2b                	jbe    800b8c <memmove+0x44>
		s += n;
		d += n;
  800b61:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b64:	89 d6                	mov    %edx,%esi
  800b66:	09 fe                	or     %edi,%esi
  800b68:	09 ce                	or     %ecx,%esi
  800b6a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b70:	75 0e                	jne    800b80 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b72:	83 ef 04             	sub    $0x4,%edi
  800b75:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b78:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b7b:	fd                   	std    
  800b7c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b7e:	eb 09                	jmp    800b89 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b80:	83 ef 01             	sub    $0x1,%edi
  800b83:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b86:	fd                   	std    
  800b87:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b89:	fc                   	cld    
  800b8a:	eb 1a                	jmp    800ba6 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b8c:	89 f2                	mov    %esi,%edx
  800b8e:	09 c2                	or     %eax,%edx
  800b90:	09 ca                	or     %ecx,%edx
  800b92:	f6 c2 03             	test   $0x3,%dl
  800b95:	75 0a                	jne    800ba1 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b97:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b9a:	89 c7                	mov    %eax,%edi
  800b9c:	fc                   	cld    
  800b9d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b9f:	eb 05                	jmp    800ba6 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800ba1:	89 c7                	mov    %eax,%edi
  800ba3:	fc                   	cld    
  800ba4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bb0:	ff 75 10             	push   0x10(%ebp)
  800bb3:	ff 75 0c             	push   0xc(%ebp)
  800bb6:	ff 75 08             	push   0x8(%ebp)
  800bb9:	e8 8a ff ff ff       	call   800b48 <memmove>
}
  800bbe:	c9                   	leave  
  800bbf:	c3                   	ret    

00800bc0 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	56                   	push   %esi
  800bc4:	53                   	push   %ebx
  800bc5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcb:	89 c6                	mov    %eax,%esi
  800bcd:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd0:	eb 06                	jmp    800bd8 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bd2:	83 c0 01             	add    $0x1,%eax
  800bd5:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800bd8:	39 f0                	cmp    %esi,%eax
  800bda:	74 14                	je     800bf0 <memcmp+0x30>
		if (*s1 != *s2)
  800bdc:	0f b6 08             	movzbl (%eax),%ecx
  800bdf:	0f b6 1a             	movzbl (%edx),%ebx
  800be2:	38 d9                	cmp    %bl,%cl
  800be4:	74 ec                	je     800bd2 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800be6:	0f b6 c1             	movzbl %cl,%eax
  800be9:	0f b6 db             	movzbl %bl,%ebx
  800bec:	29 d8                	sub    %ebx,%eax
  800bee:	eb 05                	jmp    800bf5 <memcmp+0x35>
	}

	return 0;
  800bf0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5d                   	pop    %ebp
  800bf8:	c3                   	ret    

00800bf9 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c02:	89 c2                	mov    %eax,%edx
  800c04:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c07:	eb 03                	jmp    800c0c <memfind+0x13>
  800c09:	83 c0 01             	add    $0x1,%eax
  800c0c:	39 d0                	cmp    %edx,%eax
  800c0e:	73 04                	jae    800c14 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c10:	38 08                	cmp    %cl,(%eax)
  800c12:	75 f5                	jne    800c09 <memfind+0x10>
			break;
	return (void *) s;
}
  800c14:	5d                   	pop    %ebp
  800c15:	c3                   	ret    

00800c16 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c16:	55                   	push   %ebp
  800c17:	89 e5                	mov    %esp,%ebp
  800c19:	57                   	push   %edi
  800c1a:	56                   	push   %esi
  800c1b:	53                   	push   %ebx
  800c1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c1f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c22:	eb 03                	jmp    800c27 <strtol+0x11>
		s++;
  800c24:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800c27:	0f b6 02             	movzbl (%edx),%eax
  800c2a:	3c 20                	cmp    $0x20,%al
  800c2c:	74 f6                	je     800c24 <strtol+0xe>
  800c2e:	3c 09                	cmp    $0x9,%al
  800c30:	74 f2                	je     800c24 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c32:	3c 2b                	cmp    $0x2b,%al
  800c34:	74 2a                	je     800c60 <strtol+0x4a>
	int neg = 0;
  800c36:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c3b:	3c 2d                	cmp    $0x2d,%al
  800c3d:	74 2b                	je     800c6a <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c3f:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c45:	75 0f                	jne    800c56 <strtol+0x40>
  800c47:	80 3a 30             	cmpb   $0x30,(%edx)
  800c4a:	74 28                	je     800c74 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c4c:	85 db                	test   %ebx,%ebx
  800c4e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c53:	0f 44 d8             	cmove  %eax,%ebx
  800c56:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c5b:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c5e:	eb 46                	jmp    800ca6 <strtol+0x90>
		s++;
  800c60:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800c63:	bf 00 00 00 00       	mov    $0x0,%edi
  800c68:	eb d5                	jmp    800c3f <strtol+0x29>
		s++, neg = 1;
  800c6a:	83 c2 01             	add    $0x1,%edx
  800c6d:	bf 01 00 00 00       	mov    $0x1,%edi
  800c72:	eb cb                	jmp    800c3f <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c74:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c78:	74 0e                	je     800c88 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800c7a:	85 db                	test   %ebx,%ebx
  800c7c:	75 d8                	jne    800c56 <strtol+0x40>
		s++, base = 8;
  800c7e:	83 c2 01             	add    $0x1,%edx
  800c81:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c86:	eb ce                	jmp    800c56 <strtol+0x40>
		s += 2, base = 16;
  800c88:	83 c2 02             	add    $0x2,%edx
  800c8b:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c90:	eb c4                	jmp    800c56 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c92:	0f be c0             	movsbl %al,%eax
  800c95:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c98:	3b 45 10             	cmp    0x10(%ebp),%eax
  800c9b:	7d 3a                	jge    800cd7 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800c9d:	83 c2 01             	add    $0x1,%edx
  800ca0:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ca4:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800ca6:	0f b6 02             	movzbl (%edx),%eax
  800ca9:	8d 70 d0             	lea    -0x30(%eax),%esi
  800cac:	89 f3                	mov    %esi,%ebx
  800cae:	80 fb 09             	cmp    $0x9,%bl
  800cb1:	76 df                	jbe    800c92 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800cb3:	8d 70 9f             	lea    -0x61(%eax),%esi
  800cb6:	89 f3                	mov    %esi,%ebx
  800cb8:	80 fb 19             	cmp    $0x19,%bl
  800cbb:	77 08                	ja     800cc5 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800cbd:	0f be c0             	movsbl %al,%eax
  800cc0:	83 e8 57             	sub    $0x57,%eax
  800cc3:	eb d3                	jmp    800c98 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800cc5:	8d 70 bf             	lea    -0x41(%eax),%esi
  800cc8:	89 f3                	mov    %esi,%ebx
  800cca:	80 fb 19             	cmp    $0x19,%bl
  800ccd:	77 08                	ja     800cd7 <strtol+0xc1>
			dig = *s - 'A' + 10;
  800ccf:	0f be c0             	movsbl %al,%eax
  800cd2:	83 e8 37             	sub    $0x37,%eax
  800cd5:	eb c1                	jmp    800c98 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800cd7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cdb:	74 05                	je     800ce2 <strtol+0xcc>
		*endptr = (char *) s;
  800cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce0:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ce2:	89 c8                	mov    %ecx,%eax
  800ce4:	f7 d8                	neg    %eax
  800ce6:	85 ff                	test   %edi,%edi
  800ce8:	0f 45 c8             	cmovne %eax,%ecx
}
  800ceb:	89 c8                	mov    %ecx,%eax
  800ced:	5b                   	pop    %ebx
  800cee:	5e                   	pop    %esi
  800cef:	5f                   	pop    %edi
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    
  800cf2:	66 90                	xchg   %ax,%ax
  800cf4:	66 90                	xchg   %ax,%ax
  800cf6:	66 90                	xchg   %ax,%ax
  800cf8:	66 90                	xchg   %ax,%ax
  800cfa:	66 90                	xchg   %ax,%ax
  800cfc:	66 90                	xchg   %ax,%ax
  800cfe:	66 90                	xchg   %ax,%ax

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
