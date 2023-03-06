
obj/user/faultwrite：     文件格式 elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	*(unsigned*)0 = 0;
  800033:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003a:	00 00 00 
}
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800049:	e8 c6 00 00 00       	call   800114 <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008a:	6a 00                	push   $0x0
  80008c:	e8 42 00 00 00       	call   8000d3 <sys_env_destroy>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	57                   	push   %edi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80009c:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a7:	89 c3                	mov    %eax,%ebx
  8000a9:	89 c7                	mov    %eax,%edi
  8000ab:	89 c6                	mov    %eax,%esi
  8000ad:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5f                   	pop    %edi
  8000b2:	5d                   	pop    %ebp
  8000b3:	c3                   	ret    

008000b4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c4:	89 d1                	mov    %edx,%ecx
  8000c6:	89 d3                	mov    %edx,%ebx
  8000c8:	89 d7                	mov    %edx,%edi
  8000ca:	89 d6                	mov    %edx,%esi
  8000cc:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e1:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e4:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e9:	89 cb                	mov    %ecx,%ebx
  8000eb:	89 cf                	mov    %ecx,%edi
  8000ed:	89 ce                	mov    %ecx,%esi
  8000ef:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f1:	85 c0                	test   %eax,%eax
  8000f3:	7f 08                	jg     8000fd <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f8:	5b                   	pop    %ebx
  8000f9:	5e                   	pop    %esi
  8000fa:	5f                   	pop    %edi
  8000fb:	5d                   	pop    %ebp
  8000fc:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	50                   	push   %eax
  800101:	6a 03                	push   $0x3
  800103:	68 4a 0f 80 00       	push   $0x800f4a
  800108:	6a 2a                	push   $0x2a
  80010a:	68 67 0f 80 00       	push   $0x800f67
  80010f:	e8 ed 01 00 00       	call   800301 <_panic>

00800114 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	57                   	push   %edi
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	asm volatile("int %1\n"
  80011a:	ba 00 00 00 00       	mov    $0x0,%edx
  80011f:	b8 02 00 00 00       	mov    $0x2,%eax
  800124:	89 d1                	mov    %edx,%ecx
  800126:	89 d3                	mov    %edx,%ebx
  800128:	89 d7                	mov    %edx,%edi
  80012a:	89 d6                	mov    %edx,%esi
  80012c:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <sys_yield>:

void
sys_yield(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	57                   	push   %edi
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	asm volatile("int %1\n"
  800139:	ba 00 00 00 00       	mov    $0x0,%edx
  80013e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800143:	89 d1                	mov    %edx,%ecx
  800145:	89 d3                	mov    %edx,%ebx
  800147:	89 d7                	mov    %edx,%edi
  800149:	89 d6                	mov    %edx,%esi
  80014b:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80014d:	5b                   	pop    %ebx
  80014e:	5e                   	pop    %esi
  80014f:	5f                   	pop    %edi
  800150:	5d                   	pop    %ebp
  800151:	c3                   	ret    

00800152 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800152:	55                   	push   %ebp
  800153:	89 e5                	mov    %esp,%ebp
  800155:	57                   	push   %edi
  800156:	56                   	push   %esi
  800157:	53                   	push   %ebx
  800158:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80015b:	be 00 00 00 00       	mov    $0x0,%esi
  800160:	8b 55 08             	mov    0x8(%ebp),%edx
  800163:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800166:	b8 04 00 00 00       	mov    $0x4,%eax
  80016b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80016e:	89 f7                	mov    %esi,%edi
  800170:	cd 30                	int    $0x30
	if(check && ret > 0)
  800172:	85 c0                	test   %eax,%eax
  800174:	7f 08                	jg     80017e <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800176:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800179:	5b                   	pop    %ebx
  80017a:	5e                   	pop    %esi
  80017b:	5f                   	pop    %edi
  80017c:	5d                   	pop    %ebp
  80017d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	50                   	push   %eax
  800182:	6a 04                	push   $0x4
  800184:	68 4a 0f 80 00       	push   $0x800f4a
  800189:	6a 2a                	push   $0x2a
  80018b:	68 67 0f 80 00       	push   $0x800f67
  800190:	e8 6c 01 00 00       	call   800301 <_panic>

00800195 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	57                   	push   %edi
  800199:	56                   	push   %esi
  80019a:	53                   	push   %ebx
  80019b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80019e:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a4:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ac:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001af:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	7f 08                	jg     8001c0 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bb:	5b                   	pop    %ebx
  8001bc:	5e                   	pop    %esi
  8001bd:	5f                   	pop    %edi
  8001be:	5d                   	pop    %ebp
  8001bf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	50                   	push   %eax
  8001c4:	6a 05                	push   $0x5
  8001c6:	68 4a 0f 80 00       	push   $0x800f4a
  8001cb:	6a 2a                	push   $0x2a
  8001cd:	68 67 0f 80 00       	push   $0x800f67
  8001d2:	e8 2a 01 00 00       	call   800301 <_panic>

008001d7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	57                   	push   %edi
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001eb:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f0:	89 df                	mov    %ebx,%edi
  8001f2:	89 de                	mov    %ebx,%esi
  8001f4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001f6:	85 c0                	test   %eax,%eax
  8001f8:	7f 08                	jg     800202 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fd:	5b                   	pop    %ebx
  8001fe:	5e                   	pop    %esi
  8001ff:	5f                   	pop    %edi
  800200:	5d                   	pop    %ebp
  800201:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	50                   	push   %eax
  800206:	6a 06                	push   $0x6
  800208:	68 4a 0f 80 00       	push   $0x800f4a
  80020d:	6a 2a                	push   $0x2a
  80020f:	68 67 0f 80 00       	push   $0x800f67
  800214:	e8 e8 00 00 00       	call   800301 <_panic>

00800219 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	57                   	push   %edi
  80021d:	56                   	push   %esi
  80021e:	53                   	push   %ebx
  80021f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800222:	bb 00 00 00 00       	mov    $0x0,%ebx
  800227:	8b 55 08             	mov    0x8(%ebp),%edx
  80022a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022d:	b8 08 00 00 00       	mov    $0x8,%eax
  800232:	89 df                	mov    %ebx,%edi
  800234:	89 de                	mov    %ebx,%esi
  800236:	cd 30                	int    $0x30
	if(check && ret > 0)
  800238:	85 c0                	test   %eax,%eax
  80023a:	7f 08                	jg     800244 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80023c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023f:	5b                   	pop    %ebx
  800240:	5e                   	pop    %esi
  800241:	5f                   	pop    %edi
  800242:	5d                   	pop    %ebp
  800243:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	50                   	push   %eax
  800248:	6a 08                	push   $0x8
  80024a:	68 4a 0f 80 00       	push   $0x800f4a
  80024f:	6a 2a                	push   $0x2a
  800251:	68 67 0f 80 00       	push   $0x800f67
  800256:	e8 a6 00 00 00       	call   800301 <_panic>

0080025b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	57                   	push   %edi
  80025f:	56                   	push   %esi
  800260:	53                   	push   %ebx
  800261:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800264:	bb 00 00 00 00       	mov    $0x0,%ebx
  800269:	8b 55 08             	mov    0x8(%ebp),%edx
  80026c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026f:	b8 09 00 00 00       	mov    $0x9,%eax
  800274:	89 df                	mov    %ebx,%edi
  800276:	89 de                	mov    %ebx,%esi
  800278:	cd 30                	int    $0x30
	if(check && ret > 0)
  80027a:	85 c0                	test   %eax,%eax
  80027c:	7f 08                	jg     800286 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80027e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800281:	5b                   	pop    %ebx
  800282:	5e                   	pop    %esi
  800283:	5f                   	pop    %edi
  800284:	5d                   	pop    %ebp
  800285:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	50                   	push   %eax
  80028a:	6a 09                	push   $0x9
  80028c:	68 4a 0f 80 00       	push   $0x800f4a
  800291:	6a 2a                	push   $0x2a
  800293:	68 67 0f 80 00       	push   $0x800f67
  800298:	e8 64 00 00 00       	call   800301 <_panic>

0080029d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	57                   	push   %edi
  8002a1:	56                   	push   %esi
  8002a2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a9:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002ae:	be 00 00 00 00       	mov    $0x0,%esi
  8002b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b9:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002bb:	5b                   	pop    %ebx
  8002bc:	5e                   	pop    %esi
  8002bd:	5f                   	pop    %edi
  8002be:	5d                   	pop    %ebp
  8002bf:	c3                   	ret    

008002c0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d1:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002d6:	89 cb                	mov    %ecx,%ebx
  8002d8:	89 cf                	mov    %ecx,%edi
  8002da:	89 ce                	mov    %ecx,%esi
  8002dc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002de:	85 c0                	test   %eax,%eax
  8002e0:	7f 08                	jg     8002ea <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e5:	5b                   	pop    %ebx
  8002e6:	5e                   	pop    %esi
  8002e7:	5f                   	pop    %edi
  8002e8:	5d                   	pop    %ebp
  8002e9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ea:	83 ec 0c             	sub    $0xc,%esp
  8002ed:	50                   	push   %eax
  8002ee:	6a 0c                	push   $0xc
  8002f0:	68 4a 0f 80 00       	push   $0x800f4a
  8002f5:	6a 2a                	push   $0x2a
  8002f7:	68 67 0f 80 00       	push   $0x800f67
  8002fc:	e8 00 00 00 00       	call   800301 <_panic>

00800301 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800306:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800309:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80030f:	e8 00 fe ff ff       	call   800114 <sys_getenvid>
  800314:	83 ec 0c             	sub    $0xc,%esp
  800317:	ff 75 0c             	push   0xc(%ebp)
  80031a:	ff 75 08             	push   0x8(%ebp)
  80031d:	56                   	push   %esi
  80031e:	50                   	push   %eax
  80031f:	68 78 0f 80 00       	push   $0x800f78
  800324:	e8 b3 00 00 00       	call   8003dc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800329:	83 c4 18             	add    $0x18,%esp
  80032c:	53                   	push   %ebx
  80032d:	ff 75 10             	push   0x10(%ebp)
  800330:	e8 56 00 00 00       	call   80038b <vcprintf>
	cprintf("\n");
  800335:	c7 04 24 9b 0f 80 00 	movl   $0x800f9b,(%esp)
  80033c:	e8 9b 00 00 00       	call   8003dc <cprintf>
  800341:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800344:	cc                   	int3   
  800345:	eb fd                	jmp    800344 <_panic+0x43>

00800347 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	53                   	push   %ebx
  80034b:	83 ec 04             	sub    $0x4,%esp
  80034e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800351:	8b 13                	mov    (%ebx),%edx
  800353:	8d 42 01             	lea    0x1(%edx),%eax
  800356:	89 03                	mov    %eax,(%ebx)
  800358:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80035b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80035f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800364:	74 09                	je     80036f <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800366:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80036a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80036d:	c9                   	leave  
  80036e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80036f:	83 ec 08             	sub    $0x8,%esp
  800372:	68 ff 00 00 00       	push   $0xff
  800377:	8d 43 08             	lea    0x8(%ebx),%eax
  80037a:	50                   	push   %eax
  80037b:	e8 16 fd ff ff       	call   800096 <sys_cputs>
		b->idx = 0;
  800380:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800386:	83 c4 10             	add    $0x10,%esp
  800389:	eb db                	jmp    800366 <putch+0x1f>

0080038b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80038b:	55                   	push   %ebp
  80038c:	89 e5                	mov    %esp,%ebp
  80038e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800394:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80039b:	00 00 00 
	b.cnt = 0;
  80039e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003a5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a8:	ff 75 0c             	push   0xc(%ebp)
  8003ab:	ff 75 08             	push   0x8(%ebp)
  8003ae:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003b4:	50                   	push   %eax
  8003b5:	68 47 03 80 00       	push   $0x800347
  8003ba:	e8 14 01 00 00       	call   8004d3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003bf:	83 c4 08             	add    $0x8,%esp
  8003c2:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8003c8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003ce:	50                   	push   %eax
  8003cf:	e8 c2 fc ff ff       	call   800096 <sys_cputs>

	return b.cnt;
}
  8003d4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003da:	c9                   	leave  
  8003db:	c3                   	ret    

008003dc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003dc:	55                   	push   %ebp
  8003dd:	89 e5                	mov    %esp,%ebp
  8003df:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003e5:	50                   	push   %eax
  8003e6:	ff 75 08             	push   0x8(%ebp)
  8003e9:	e8 9d ff ff ff       	call   80038b <vcprintf>
	va_end(ap);

	return cnt;
}
  8003ee:	c9                   	leave  
  8003ef:	c3                   	ret    

008003f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	57                   	push   %edi
  8003f4:	56                   	push   %esi
  8003f5:	53                   	push   %ebx
  8003f6:	83 ec 1c             	sub    $0x1c,%esp
  8003f9:	89 c7                	mov    %eax,%edi
  8003fb:	89 d6                	mov    %edx,%esi
  8003fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800400:	8b 55 0c             	mov    0xc(%ebp),%edx
  800403:	89 d1                	mov    %edx,%ecx
  800405:	89 c2                	mov    %eax,%edx
  800407:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80040d:	8b 45 10             	mov    0x10(%ebp),%eax
  800410:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800413:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800416:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80041d:	39 c2                	cmp    %eax,%edx
  80041f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800422:	72 3e                	jb     800462 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800424:	83 ec 0c             	sub    $0xc,%esp
  800427:	ff 75 18             	push   0x18(%ebp)
  80042a:	83 eb 01             	sub    $0x1,%ebx
  80042d:	53                   	push   %ebx
  80042e:	50                   	push   %eax
  80042f:	83 ec 08             	sub    $0x8,%esp
  800432:	ff 75 e4             	push   -0x1c(%ebp)
  800435:	ff 75 e0             	push   -0x20(%ebp)
  800438:	ff 75 dc             	push   -0x24(%ebp)
  80043b:	ff 75 d8             	push   -0x28(%ebp)
  80043e:	e8 bd 08 00 00       	call   800d00 <__udivdi3>
  800443:	83 c4 18             	add    $0x18,%esp
  800446:	52                   	push   %edx
  800447:	50                   	push   %eax
  800448:	89 f2                	mov    %esi,%edx
  80044a:	89 f8                	mov    %edi,%eax
  80044c:	e8 9f ff ff ff       	call   8003f0 <printnum>
  800451:	83 c4 20             	add    $0x20,%esp
  800454:	eb 13                	jmp    800469 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800456:	83 ec 08             	sub    $0x8,%esp
  800459:	56                   	push   %esi
  80045a:	ff 75 18             	push   0x18(%ebp)
  80045d:	ff d7                	call   *%edi
  80045f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800462:	83 eb 01             	sub    $0x1,%ebx
  800465:	85 db                	test   %ebx,%ebx
  800467:	7f ed                	jg     800456 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800469:	83 ec 08             	sub    $0x8,%esp
  80046c:	56                   	push   %esi
  80046d:	83 ec 04             	sub    $0x4,%esp
  800470:	ff 75 e4             	push   -0x1c(%ebp)
  800473:	ff 75 e0             	push   -0x20(%ebp)
  800476:	ff 75 dc             	push   -0x24(%ebp)
  800479:	ff 75 d8             	push   -0x28(%ebp)
  80047c:	e8 9f 09 00 00       	call   800e20 <__umoddi3>
  800481:	83 c4 14             	add    $0x14,%esp
  800484:	0f be 80 9d 0f 80 00 	movsbl 0x800f9d(%eax),%eax
  80048b:	50                   	push   %eax
  80048c:	ff d7                	call   *%edi
}
  80048e:	83 c4 10             	add    $0x10,%esp
  800491:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800494:	5b                   	pop    %ebx
  800495:	5e                   	pop    %esi
  800496:	5f                   	pop    %edi
  800497:	5d                   	pop    %ebp
  800498:	c3                   	ret    

00800499 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800499:	55                   	push   %ebp
  80049a:	89 e5                	mov    %esp,%ebp
  80049c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80049f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004a3:	8b 10                	mov    (%eax),%edx
  8004a5:	3b 50 04             	cmp    0x4(%eax),%edx
  8004a8:	73 0a                	jae    8004b4 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004aa:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004ad:	89 08                	mov    %ecx,(%eax)
  8004af:	8b 45 08             	mov    0x8(%ebp),%eax
  8004b2:	88 02                	mov    %al,(%edx)
}
  8004b4:	5d                   	pop    %ebp
  8004b5:	c3                   	ret    

008004b6 <printfmt>:
{
  8004b6:	55                   	push   %ebp
  8004b7:	89 e5                	mov    %esp,%ebp
  8004b9:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004bc:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004bf:	50                   	push   %eax
  8004c0:	ff 75 10             	push   0x10(%ebp)
  8004c3:	ff 75 0c             	push   0xc(%ebp)
  8004c6:	ff 75 08             	push   0x8(%ebp)
  8004c9:	e8 05 00 00 00       	call   8004d3 <vprintfmt>
}
  8004ce:	83 c4 10             	add    $0x10,%esp
  8004d1:	c9                   	leave  
  8004d2:	c3                   	ret    

008004d3 <vprintfmt>:
{
  8004d3:	55                   	push   %ebp
  8004d4:	89 e5                	mov    %esp,%ebp
  8004d6:	57                   	push   %edi
  8004d7:	56                   	push   %esi
  8004d8:	53                   	push   %ebx
  8004d9:	83 ec 3c             	sub    $0x3c,%esp
  8004dc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004e5:	eb 0a                	jmp    8004f1 <vprintfmt+0x1e>
			putch(ch, putdat);
  8004e7:	83 ec 08             	sub    $0x8,%esp
  8004ea:	53                   	push   %ebx
  8004eb:	50                   	push   %eax
  8004ec:	ff d6                	call   *%esi
  8004ee:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8004f1:	83 c7 01             	add    $0x1,%edi
  8004f4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f8:	83 f8 25             	cmp    $0x25,%eax
  8004fb:	74 0c                	je     800509 <vprintfmt+0x36>
			if (ch == '\0')
  8004fd:	85 c0                	test   %eax,%eax
  8004ff:	75 e6                	jne    8004e7 <vprintfmt+0x14>
}
  800501:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800504:	5b                   	pop    %ebx
  800505:	5e                   	pop    %esi
  800506:	5f                   	pop    %edi
  800507:	5d                   	pop    %ebp
  800508:	c3                   	ret    
		padc = ' ';
  800509:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80050d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800514:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80051b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800522:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800527:	8d 47 01             	lea    0x1(%edi),%eax
  80052a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80052d:	0f b6 17             	movzbl (%edi),%edx
  800530:	8d 42 dd             	lea    -0x23(%edx),%eax
  800533:	3c 55                	cmp    $0x55,%al
  800535:	0f 87 bb 03 00 00    	ja     8008f6 <vprintfmt+0x423>
  80053b:	0f b6 c0             	movzbl %al,%eax
  80053e:	ff 24 85 60 10 80 00 	jmp    *0x801060(,%eax,4)
  800545:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800548:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80054c:	eb d9                	jmp    800527 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80054e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800551:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800555:	eb d0                	jmp    800527 <vprintfmt+0x54>
  800557:	0f b6 d2             	movzbl %dl,%edx
  80055a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80055d:	b8 00 00 00 00       	mov    $0x0,%eax
  800562:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800565:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800568:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80056c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80056f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800572:	83 f9 09             	cmp    $0x9,%ecx
  800575:	77 55                	ja     8005cc <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  800577:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80057a:	eb e9                	jmp    800565 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	8b 00                	mov    (%eax),%eax
  800581:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8d 40 04             	lea    0x4(%eax),%eax
  80058a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80058d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800590:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800594:	79 91                	jns    800527 <vprintfmt+0x54>
				width = precision, precision = -1;
  800596:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800599:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80059c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005a3:	eb 82                	jmp    800527 <vprintfmt+0x54>
  8005a5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005a8:	85 d2                	test   %edx,%edx
  8005aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8005af:	0f 49 c2             	cmovns %edx,%eax
  8005b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005b8:	e9 6a ff ff ff       	jmp    800527 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8005bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005c0:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005c7:	e9 5b ff ff ff       	jmp    800527 <vprintfmt+0x54>
  8005cc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d2:	eb bc                	jmp    800590 <vprintfmt+0xbd>
			lflag++;
  8005d4:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005da:	e9 48 ff ff ff       	jmp    800527 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8005df:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e2:	8d 78 04             	lea    0x4(%eax),%edi
  8005e5:	83 ec 08             	sub    $0x8,%esp
  8005e8:	53                   	push   %ebx
  8005e9:	ff 30                	push   (%eax)
  8005eb:	ff d6                	call   *%esi
			break;
  8005ed:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8005f0:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8005f3:	e9 9d 02 00 00       	jmp    800895 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8005f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fb:	8d 78 04             	lea    0x4(%eax),%edi
  8005fe:	8b 10                	mov    (%eax),%edx
  800600:	89 d0                	mov    %edx,%eax
  800602:	f7 d8                	neg    %eax
  800604:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800607:	83 f8 08             	cmp    $0x8,%eax
  80060a:	7f 23                	jg     80062f <vprintfmt+0x15c>
  80060c:	8b 14 85 c0 11 80 00 	mov    0x8011c0(,%eax,4),%edx
  800613:	85 d2                	test   %edx,%edx
  800615:	74 18                	je     80062f <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  800617:	52                   	push   %edx
  800618:	68 be 0f 80 00       	push   $0x800fbe
  80061d:	53                   	push   %ebx
  80061e:	56                   	push   %esi
  80061f:	e8 92 fe ff ff       	call   8004b6 <printfmt>
  800624:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  800627:	89 7d 14             	mov    %edi,0x14(%ebp)
  80062a:	e9 66 02 00 00       	jmp    800895 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80062f:	50                   	push   %eax
  800630:	68 b5 0f 80 00       	push   $0x800fb5
  800635:	53                   	push   %ebx
  800636:	56                   	push   %esi
  800637:	e8 7a fe ff ff       	call   8004b6 <printfmt>
  80063c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80063f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  800642:	e9 4e 02 00 00       	jmp    800895 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  800647:	8b 45 14             	mov    0x14(%ebp),%eax
  80064a:	83 c0 04             	add    $0x4,%eax
  80064d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  800655:	85 d2                	test   %edx,%edx
  800657:	b8 ae 0f 80 00       	mov    $0x800fae,%eax
  80065c:	0f 45 c2             	cmovne %edx,%eax
  80065f:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800662:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800666:	7e 06                	jle    80066e <vprintfmt+0x19b>
  800668:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80066c:	75 0d                	jne    80067b <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80066e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800671:	89 c7                	mov    %eax,%edi
  800673:	03 45 e0             	add    -0x20(%ebp),%eax
  800676:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800679:	eb 55                	jmp    8006d0 <vprintfmt+0x1fd>
  80067b:	83 ec 08             	sub    $0x8,%esp
  80067e:	ff 75 d8             	push   -0x28(%ebp)
  800681:	ff 75 cc             	push   -0x34(%ebp)
  800684:	e8 0a 03 00 00       	call   800993 <strnlen>
  800689:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80068c:	29 c1                	sub    %eax,%ecx
  80068e:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  800696:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80069a:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80069d:	eb 0f                	jmp    8006ae <vprintfmt+0x1db>
					putch(padc, putdat);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	53                   	push   %ebx
  8006a3:	ff 75 e0             	push   -0x20(%ebp)
  8006a6:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a8:	83 ef 01             	sub    $0x1,%edi
  8006ab:	83 c4 10             	add    $0x10,%esp
  8006ae:	85 ff                	test   %edi,%edi
  8006b0:	7f ed                	jg     80069f <vprintfmt+0x1cc>
  8006b2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006b5:	85 d2                	test   %edx,%edx
  8006b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8006bc:	0f 49 c2             	cmovns %edx,%eax
  8006bf:	29 c2                	sub    %eax,%edx
  8006c1:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006c4:	eb a8                	jmp    80066e <vprintfmt+0x19b>
					putch(ch, putdat);
  8006c6:	83 ec 08             	sub    $0x8,%esp
  8006c9:	53                   	push   %ebx
  8006ca:	52                   	push   %edx
  8006cb:	ff d6                	call   *%esi
  8006cd:	83 c4 10             	add    $0x10,%esp
  8006d0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006d3:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006d5:	83 c7 01             	add    $0x1,%edi
  8006d8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006dc:	0f be d0             	movsbl %al,%edx
  8006df:	85 d2                	test   %edx,%edx
  8006e1:	74 4b                	je     80072e <vprintfmt+0x25b>
  8006e3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006e7:	78 06                	js     8006ef <vprintfmt+0x21c>
  8006e9:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8006ed:	78 1e                	js     80070d <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8006ef:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006f3:	74 d1                	je     8006c6 <vprintfmt+0x1f3>
  8006f5:	0f be c0             	movsbl %al,%eax
  8006f8:	83 e8 20             	sub    $0x20,%eax
  8006fb:	83 f8 5e             	cmp    $0x5e,%eax
  8006fe:	76 c6                	jbe    8006c6 <vprintfmt+0x1f3>
					putch('?', putdat);
  800700:	83 ec 08             	sub    $0x8,%esp
  800703:	53                   	push   %ebx
  800704:	6a 3f                	push   $0x3f
  800706:	ff d6                	call   *%esi
  800708:	83 c4 10             	add    $0x10,%esp
  80070b:	eb c3                	jmp    8006d0 <vprintfmt+0x1fd>
  80070d:	89 cf                	mov    %ecx,%edi
  80070f:	eb 0e                	jmp    80071f <vprintfmt+0x24c>
				putch(' ', putdat);
  800711:	83 ec 08             	sub    $0x8,%esp
  800714:	53                   	push   %ebx
  800715:	6a 20                	push   $0x20
  800717:	ff d6                	call   *%esi
			for (; width > 0; width--)
  800719:	83 ef 01             	sub    $0x1,%edi
  80071c:	83 c4 10             	add    $0x10,%esp
  80071f:	85 ff                	test   %edi,%edi
  800721:	7f ee                	jg     800711 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  800723:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800726:	89 45 14             	mov    %eax,0x14(%ebp)
  800729:	e9 67 01 00 00       	jmp    800895 <vprintfmt+0x3c2>
  80072e:	89 cf                	mov    %ecx,%edi
  800730:	eb ed                	jmp    80071f <vprintfmt+0x24c>
	if (lflag >= 2)
  800732:	83 f9 01             	cmp    $0x1,%ecx
  800735:	7f 1b                	jg     800752 <vprintfmt+0x27f>
	else if (lflag)
  800737:	85 c9                	test   %ecx,%ecx
  800739:	74 63                	je     80079e <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80073b:	8b 45 14             	mov    0x14(%ebp),%eax
  80073e:	8b 00                	mov    (%eax),%eax
  800740:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800743:	99                   	cltd   
  800744:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800747:	8b 45 14             	mov    0x14(%ebp),%eax
  80074a:	8d 40 04             	lea    0x4(%eax),%eax
  80074d:	89 45 14             	mov    %eax,0x14(%ebp)
  800750:	eb 17                	jmp    800769 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  800752:	8b 45 14             	mov    0x14(%ebp),%eax
  800755:	8b 50 04             	mov    0x4(%eax),%edx
  800758:	8b 00                	mov    (%eax),%eax
  80075a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80075d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800760:	8b 45 14             	mov    0x14(%ebp),%eax
  800763:	8d 40 08             	lea    0x8(%eax),%eax
  800766:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  800769:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80076c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80076f:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  800774:	85 c9                	test   %ecx,%ecx
  800776:	0f 89 ff 00 00 00    	jns    80087b <vprintfmt+0x3a8>
				putch('-', putdat);
  80077c:	83 ec 08             	sub    $0x8,%esp
  80077f:	53                   	push   %ebx
  800780:	6a 2d                	push   $0x2d
  800782:	ff d6                	call   *%esi
				num = -(long long) num;
  800784:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800787:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80078a:	f7 da                	neg    %edx
  80078c:	83 d1 00             	adc    $0x0,%ecx
  80078f:	f7 d9                	neg    %ecx
  800791:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800794:	bf 0a 00 00 00       	mov    $0xa,%edi
  800799:	e9 dd 00 00 00       	jmp    80087b <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80079e:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a1:	8b 00                	mov    (%eax),%eax
  8007a3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a6:	99                   	cltd   
  8007a7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	8d 40 04             	lea    0x4(%eax),%eax
  8007b0:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b3:	eb b4                	jmp    800769 <vprintfmt+0x296>
	if (lflag >= 2)
  8007b5:	83 f9 01             	cmp    $0x1,%ecx
  8007b8:	7f 1e                	jg     8007d8 <vprintfmt+0x305>
	else if (lflag)
  8007ba:	85 c9                	test   %ecx,%ecx
  8007bc:	74 32                	je     8007f0 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8007be:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c1:	8b 10                	mov    (%eax),%edx
  8007c3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007c8:	8d 40 04             	lea    0x4(%eax),%eax
  8007cb:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007ce:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8007d3:	e9 a3 00 00 00       	jmp    80087b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8007d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007db:	8b 10                	mov    (%eax),%edx
  8007dd:	8b 48 04             	mov    0x4(%eax),%ecx
  8007e0:	8d 40 08             	lea    0x8(%eax),%eax
  8007e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8007e6:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8007eb:	e9 8b 00 00 00       	jmp    80087b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8007f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f3:	8b 10                	mov    (%eax),%edx
  8007f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8007fa:	8d 40 04             	lea    0x4(%eax),%eax
  8007fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  800800:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  800805:	eb 74                	jmp    80087b <vprintfmt+0x3a8>
	if (lflag >= 2)
  800807:	83 f9 01             	cmp    $0x1,%ecx
  80080a:	7f 1b                	jg     800827 <vprintfmt+0x354>
	else if (lflag)
  80080c:	85 c9                	test   %ecx,%ecx
  80080e:	74 2c                	je     80083c <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	8b 10                	mov    (%eax),%edx
  800815:	b9 00 00 00 00       	mov    $0x0,%ecx
  80081a:	8d 40 04             	lea    0x4(%eax),%eax
  80081d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800820:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  800825:	eb 54                	jmp    80087b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  800827:	8b 45 14             	mov    0x14(%ebp),%eax
  80082a:	8b 10                	mov    (%eax),%edx
  80082c:	8b 48 04             	mov    0x4(%eax),%ecx
  80082f:	8d 40 08             	lea    0x8(%eax),%eax
  800832:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  800835:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80083a:	eb 3f                	jmp    80087b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80083c:	8b 45 14             	mov    0x14(%ebp),%eax
  80083f:	8b 10                	mov    (%eax),%edx
  800841:	b9 00 00 00 00       	mov    $0x0,%ecx
  800846:	8d 40 04             	lea    0x4(%eax),%eax
  800849:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80084c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  800851:	eb 28                	jmp    80087b <vprintfmt+0x3a8>
			putch('0', putdat);
  800853:	83 ec 08             	sub    $0x8,%esp
  800856:	53                   	push   %ebx
  800857:	6a 30                	push   $0x30
  800859:	ff d6                	call   *%esi
			putch('x', putdat);
  80085b:	83 c4 08             	add    $0x8,%esp
  80085e:	53                   	push   %ebx
  80085f:	6a 78                	push   $0x78
  800861:	ff d6                	call   *%esi
			num = (unsigned long long)
  800863:	8b 45 14             	mov    0x14(%ebp),%eax
  800866:	8b 10                	mov    (%eax),%edx
  800868:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80086d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  800870:	8d 40 04             	lea    0x4(%eax),%eax
  800873:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800876:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80087b:	83 ec 0c             	sub    $0xc,%esp
  80087e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  800882:	50                   	push   %eax
  800883:	ff 75 e0             	push   -0x20(%ebp)
  800886:	57                   	push   %edi
  800887:	51                   	push   %ecx
  800888:	52                   	push   %edx
  800889:	89 da                	mov    %ebx,%edx
  80088b:	89 f0                	mov    %esi,%eax
  80088d:	e8 5e fb ff ff       	call   8003f0 <printnum>
			break;
  800892:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  800895:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800898:	e9 54 fc ff ff       	jmp    8004f1 <vprintfmt+0x1e>
	if (lflag >= 2)
  80089d:	83 f9 01             	cmp    $0x1,%ecx
  8008a0:	7f 1b                	jg     8008bd <vprintfmt+0x3ea>
	else if (lflag)
  8008a2:	85 c9                	test   %ecx,%ecx
  8008a4:	74 2c                	je     8008d2 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8008a6:	8b 45 14             	mov    0x14(%ebp),%eax
  8008a9:	8b 10                	mov    (%eax),%edx
  8008ab:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008b0:	8d 40 04             	lea    0x4(%eax),%eax
  8008b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008b6:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8008bb:	eb be                	jmp    80087b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8008bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8008c0:	8b 10                	mov    (%eax),%edx
  8008c2:	8b 48 04             	mov    0x4(%eax),%ecx
  8008c5:	8d 40 08             	lea    0x8(%eax),%eax
  8008c8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008cb:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8008d0:	eb a9                	jmp    80087b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8008d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008d5:	8b 10                	mov    (%eax),%edx
  8008d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008dc:	8d 40 04             	lea    0x4(%eax),%eax
  8008df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008e2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8008e7:	eb 92                	jmp    80087b <vprintfmt+0x3a8>
			putch(ch, putdat);
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	53                   	push   %ebx
  8008ed:	6a 25                	push   $0x25
  8008ef:	ff d6                	call   *%esi
			break;
  8008f1:	83 c4 10             	add    $0x10,%esp
  8008f4:	eb 9f                	jmp    800895 <vprintfmt+0x3c2>
			putch('%', putdat);
  8008f6:	83 ec 08             	sub    $0x8,%esp
  8008f9:	53                   	push   %ebx
  8008fa:	6a 25                	push   $0x25
  8008fc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	89 f8                	mov    %edi,%eax
  800903:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800907:	74 05                	je     80090e <vprintfmt+0x43b>
  800909:	83 e8 01             	sub    $0x1,%eax
  80090c:	eb f5                	jmp    800903 <vprintfmt+0x430>
  80090e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800911:	eb 82                	jmp    800895 <vprintfmt+0x3c2>

00800913 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800913:	55                   	push   %ebp
  800914:	89 e5                	mov    %esp,%ebp
  800916:	83 ec 18             	sub    $0x18,%esp
  800919:	8b 45 08             	mov    0x8(%ebp),%eax
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80091f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800922:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800926:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800929:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800930:	85 c0                	test   %eax,%eax
  800932:	74 26                	je     80095a <vsnprintf+0x47>
  800934:	85 d2                	test   %edx,%edx
  800936:	7e 22                	jle    80095a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800938:	ff 75 14             	push   0x14(%ebp)
  80093b:	ff 75 10             	push   0x10(%ebp)
  80093e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800941:	50                   	push   %eax
  800942:	68 99 04 80 00       	push   $0x800499
  800947:	e8 87 fb ff ff       	call   8004d3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80094c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80094f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800952:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800955:	83 c4 10             	add    $0x10,%esp
}
  800958:	c9                   	leave  
  800959:	c3                   	ret    
		return -E_INVAL;
  80095a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80095f:	eb f7                	jmp    800958 <vsnprintf+0x45>

00800961 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800967:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80096a:	50                   	push   %eax
  80096b:	ff 75 10             	push   0x10(%ebp)
  80096e:	ff 75 0c             	push   0xc(%ebp)
  800971:	ff 75 08             	push   0x8(%ebp)
  800974:	e8 9a ff ff ff       	call   800913 <vsnprintf>
	va_end(ap);

	return rc;
}
  800979:	c9                   	leave  
  80097a:	c3                   	ret    

0080097b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800981:	b8 00 00 00 00       	mov    $0x0,%eax
  800986:	eb 03                	jmp    80098b <strlen+0x10>
		n++;
  800988:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80098b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80098f:	75 f7                	jne    800988 <strlen+0xd>
	return n;
}
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800993:	55                   	push   %ebp
  800994:	89 e5                	mov    %esp,%ebp
  800996:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800999:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80099c:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a1:	eb 03                	jmp    8009a6 <strnlen+0x13>
		n++;
  8009a3:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a6:	39 d0                	cmp    %edx,%eax
  8009a8:	74 08                	je     8009b2 <strnlen+0x1f>
  8009aa:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8009ae:	75 f3                	jne    8009a3 <strnlen+0x10>
  8009b0:	89 c2                	mov    %eax,%edx
	return n;
}
  8009b2:	89 d0                	mov    %edx,%eax
  8009b4:	5d                   	pop    %ebp
  8009b5:	c3                   	ret    

008009b6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	53                   	push   %ebx
  8009ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c5:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8009c9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8009cc:	83 c0 01             	add    $0x1,%eax
  8009cf:	84 d2                	test   %dl,%dl
  8009d1:	75 f2                	jne    8009c5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8009d3:	89 c8                	mov    %ecx,%eax
  8009d5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d8:	c9                   	leave  
  8009d9:	c3                   	ret    

008009da <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009da:	55                   	push   %ebp
  8009db:	89 e5                	mov    %esp,%ebp
  8009dd:	53                   	push   %ebx
  8009de:	83 ec 10             	sub    $0x10,%esp
  8009e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009e4:	53                   	push   %ebx
  8009e5:	e8 91 ff ff ff       	call   80097b <strlen>
  8009ea:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8009ed:	ff 75 0c             	push   0xc(%ebp)
  8009f0:	01 d8                	add    %ebx,%eax
  8009f2:	50                   	push   %eax
  8009f3:	e8 be ff ff ff       	call   8009b6 <strcpy>
	return dst;
}
  8009f8:	89 d8                	mov    %ebx,%eax
  8009fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 75 08             	mov    0x8(%ebp),%esi
  800a07:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a0a:	89 f3                	mov    %esi,%ebx
  800a0c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a0f:	89 f0                	mov    %esi,%eax
  800a11:	eb 0f                	jmp    800a22 <strncpy+0x23>
		*dst++ = *src;
  800a13:	83 c0 01             	add    $0x1,%eax
  800a16:	0f b6 0a             	movzbl (%edx),%ecx
  800a19:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a1c:	80 f9 01             	cmp    $0x1,%cl
  800a1f:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  800a22:	39 d8                	cmp    %ebx,%eax
  800a24:	75 ed                	jne    800a13 <strncpy+0x14>
	}
	return ret;
}
  800a26:	89 f0                	mov    %esi,%eax
  800a28:	5b                   	pop    %ebx
  800a29:	5e                   	pop    %esi
  800a2a:	5d                   	pop    %ebp
  800a2b:	c3                   	ret    

00800a2c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	56                   	push   %esi
  800a30:	53                   	push   %ebx
  800a31:	8b 75 08             	mov    0x8(%ebp),%esi
  800a34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a37:	8b 55 10             	mov    0x10(%ebp),%edx
  800a3a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a3c:	85 d2                	test   %edx,%edx
  800a3e:	74 21                	je     800a61 <strlcpy+0x35>
  800a40:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a44:	89 f2                	mov    %esi,%edx
  800a46:	eb 09                	jmp    800a51 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a48:	83 c1 01             	add    $0x1,%ecx
  800a4b:	83 c2 01             	add    $0x1,%edx
  800a4e:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  800a51:	39 c2                	cmp    %eax,%edx
  800a53:	74 09                	je     800a5e <strlcpy+0x32>
  800a55:	0f b6 19             	movzbl (%ecx),%ebx
  800a58:	84 db                	test   %bl,%bl
  800a5a:	75 ec                	jne    800a48 <strlcpy+0x1c>
  800a5c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a5e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a61:	29 f0                	sub    %esi,%eax
}
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a6d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a70:	eb 06                	jmp    800a78 <strcmp+0x11>
		p++, q++;
  800a72:	83 c1 01             	add    $0x1,%ecx
  800a75:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  800a78:	0f b6 01             	movzbl (%ecx),%eax
  800a7b:	84 c0                	test   %al,%al
  800a7d:	74 04                	je     800a83 <strcmp+0x1c>
  800a7f:	3a 02                	cmp    (%edx),%al
  800a81:	74 ef                	je     800a72 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a83:	0f b6 c0             	movzbl %al,%eax
  800a86:	0f b6 12             	movzbl (%edx),%edx
  800a89:	29 d0                	sub    %edx,%eax
}
  800a8b:	5d                   	pop    %ebp
  800a8c:	c3                   	ret    

00800a8d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a8d:	55                   	push   %ebp
  800a8e:	89 e5                	mov    %esp,%ebp
  800a90:	53                   	push   %ebx
  800a91:	8b 45 08             	mov    0x8(%ebp),%eax
  800a94:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a97:	89 c3                	mov    %eax,%ebx
  800a99:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a9c:	eb 06                	jmp    800aa4 <strncmp+0x17>
		n--, p++, q++;
  800a9e:	83 c0 01             	add    $0x1,%eax
  800aa1:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800aa4:	39 d8                	cmp    %ebx,%eax
  800aa6:	74 18                	je     800ac0 <strncmp+0x33>
  800aa8:	0f b6 08             	movzbl (%eax),%ecx
  800aab:	84 c9                	test   %cl,%cl
  800aad:	74 04                	je     800ab3 <strncmp+0x26>
  800aaf:	3a 0a                	cmp    (%edx),%cl
  800ab1:	74 eb                	je     800a9e <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab3:	0f b6 00             	movzbl (%eax),%eax
  800ab6:	0f b6 12             	movzbl (%edx),%edx
  800ab9:	29 d0                	sub    %edx,%eax
}
  800abb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800abe:	c9                   	leave  
  800abf:	c3                   	ret    
		return 0;
  800ac0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac5:	eb f4                	jmp    800abb <strncmp+0x2e>

00800ac7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ac7:	55                   	push   %ebp
  800ac8:	89 e5                	mov    %esp,%ebp
  800aca:	8b 45 08             	mov    0x8(%ebp),%eax
  800acd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ad1:	eb 03                	jmp    800ad6 <strchr+0xf>
  800ad3:	83 c0 01             	add    $0x1,%eax
  800ad6:	0f b6 10             	movzbl (%eax),%edx
  800ad9:	84 d2                	test   %dl,%dl
  800adb:	74 06                	je     800ae3 <strchr+0x1c>
		if (*s == c)
  800add:	38 ca                	cmp    %cl,%dl
  800adf:	75 f2                	jne    800ad3 <strchr+0xc>
  800ae1:	eb 05                	jmp    800ae8 <strchr+0x21>
			return (char *) s;
	return 0;
  800ae3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    

00800aea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800aea:	55                   	push   %ebp
  800aeb:	89 e5                	mov    %esp,%ebp
  800aed:	8b 45 08             	mov    0x8(%ebp),%eax
  800af0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800af4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800af7:	38 ca                	cmp    %cl,%dl
  800af9:	74 09                	je     800b04 <strfind+0x1a>
  800afb:	84 d2                	test   %dl,%dl
  800afd:	74 05                	je     800b04 <strfind+0x1a>
	for (; *s; s++)
  800aff:	83 c0 01             	add    $0x1,%eax
  800b02:	eb f0                	jmp    800af4 <strfind+0xa>
			break;
	return (char *) s;
}
  800b04:	5d                   	pop    %ebp
  800b05:	c3                   	ret    

00800b06 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b06:	55                   	push   %ebp
  800b07:	89 e5                	mov    %esp,%ebp
  800b09:	57                   	push   %edi
  800b0a:	56                   	push   %esi
  800b0b:	53                   	push   %ebx
  800b0c:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b12:	85 c9                	test   %ecx,%ecx
  800b14:	74 2f                	je     800b45 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b16:	89 f8                	mov    %edi,%eax
  800b18:	09 c8                	or     %ecx,%eax
  800b1a:	a8 03                	test   $0x3,%al
  800b1c:	75 21                	jne    800b3f <memset+0x39>
		c &= 0xFF;
  800b1e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b22:	89 d0                	mov    %edx,%eax
  800b24:	c1 e0 08             	shl    $0x8,%eax
  800b27:	89 d3                	mov    %edx,%ebx
  800b29:	c1 e3 18             	shl    $0x18,%ebx
  800b2c:	89 d6                	mov    %edx,%esi
  800b2e:	c1 e6 10             	shl    $0x10,%esi
  800b31:	09 f3                	or     %esi,%ebx
  800b33:	09 da                	or     %ebx,%edx
  800b35:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800b37:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  800b3a:	fc                   	cld    
  800b3b:	f3 ab                	rep stos %eax,%es:(%edi)
  800b3d:	eb 06                	jmp    800b45 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b42:	fc                   	cld    
  800b43:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b45:	89 f8                	mov    %edi,%eax
  800b47:	5b                   	pop    %ebx
  800b48:	5e                   	pop    %esi
  800b49:	5f                   	pop    %edi
  800b4a:	5d                   	pop    %ebp
  800b4b:	c3                   	ret    

00800b4c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b4c:	55                   	push   %ebp
  800b4d:	89 e5                	mov    %esp,%ebp
  800b4f:	57                   	push   %edi
  800b50:	56                   	push   %esi
  800b51:	8b 45 08             	mov    0x8(%ebp),%eax
  800b54:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b57:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b5a:	39 c6                	cmp    %eax,%esi
  800b5c:	73 32                	jae    800b90 <memmove+0x44>
  800b5e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b61:	39 c2                	cmp    %eax,%edx
  800b63:	76 2b                	jbe    800b90 <memmove+0x44>
		s += n;
		d += n;
  800b65:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b68:	89 d6                	mov    %edx,%esi
  800b6a:	09 fe                	or     %edi,%esi
  800b6c:	09 ce                	or     %ecx,%esi
  800b6e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b74:	75 0e                	jne    800b84 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b76:	83 ef 04             	sub    $0x4,%edi
  800b79:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b7c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b7f:	fd                   	std    
  800b80:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b82:	eb 09                	jmp    800b8d <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b84:	83 ef 01             	sub    $0x1,%edi
  800b87:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b8a:	fd                   	std    
  800b8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b8d:	fc                   	cld    
  800b8e:	eb 1a                	jmp    800baa <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b90:	89 f2                	mov    %esi,%edx
  800b92:	09 c2                	or     %eax,%edx
  800b94:	09 ca                	or     %ecx,%edx
  800b96:	f6 c2 03             	test   $0x3,%dl
  800b99:	75 0a                	jne    800ba5 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b9b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b9e:	89 c7                	mov    %eax,%edi
  800ba0:	fc                   	cld    
  800ba1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba3:	eb 05                	jmp    800baa <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  800ba5:	89 c7                	mov    %eax,%edi
  800ba7:	fc                   	cld    
  800ba8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800baa:	5e                   	pop    %esi
  800bab:	5f                   	pop    %edi
  800bac:	5d                   	pop    %ebp
  800bad:	c3                   	ret    

00800bae <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bae:	55                   	push   %ebp
  800baf:	89 e5                	mov    %esp,%ebp
  800bb1:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bb4:	ff 75 10             	push   0x10(%ebp)
  800bb7:	ff 75 0c             	push   0xc(%ebp)
  800bba:	ff 75 08             	push   0x8(%ebp)
  800bbd:	e8 8a ff ff ff       	call   800b4c <memmove>
}
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    

00800bc4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcf:	89 c6                	mov    %eax,%esi
  800bd1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd4:	eb 06                	jmp    800bdc <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bd6:	83 c0 01             	add    $0x1,%eax
  800bd9:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  800bdc:	39 f0                	cmp    %esi,%eax
  800bde:	74 14                	je     800bf4 <memcmp+0x30>
		if (*s1 != *s2)
  800be0:	0f b6 08             	movzbl (%eax),%ecx
  800be3:	0f b6 1a             	movzbl (%edx),%ebx
  800be6:	38 d9                	cmp    %bl,%cl
  800be8:	74 ec                	je     800bd6 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  800bea:	0f b6 c1             	movzbl %cl,%eax
  800bed:	0f b6 db             	movzbl %bl,%ebx
  800bf0:	29 d8                	sub    %ebx,%eax
  800bf2:	eb 05                	jmp    800bf9 <memcmp+0x35>
	}

	return 0;
  800bf4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5d                   	pop    %ebp
  800bfc:	c3                   	ret    

00800bfd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	8b 45 08             	mov    0x8(%ebp),%eax
  800c03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c06:	89 c2                	mov    %eax,%edx
  800c08:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c0b:	eb 03                	jmp    800c10 <memfind+0x13>
  800c0d:	83 c0 01             	add    $0x1,%eax
  800c10:	39 d0                	cmp    %edx,%eax
  800c12:	73 04                	jae    800c18 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c14:	38 08                	cmp    %cl,(%eax)
  800c16:	75 f5                	jne    800c0d <memfind+0x10>
			break;
	return (void *) s;
}
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	57                   	push   %edi
  800c1e:	56                   	push   %esi
  800c1f:	53                   	push   %ebx
  800c20:	8b 55 08             	mov    0x8(%ebp),%edx
  800c23:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c26:	eb 03                	jmp    800c2b <strtol+0x11>
		s++;
  800c28:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  800c2b:	0f b6 02             	movzbl (%edx),%eax
  800c2e:	3c 20                	cmp    $0x20,%al
  800c30:	74 f6                	je     800c28 <strtol+0xe>
  800c32:	3c 09                	cmp    $0x9,%al
  800c34:	74 f2                	je     800c28 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  800c36:	3c 2b                	cmp    $0x2b,%al
  800c38:	74 2a                	je     800c64 <strtol+0x4a>
	int neg = 0;
  800c3a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c3f:	3c 2d                	cmp    $0x2d,%al
  800c41:	74 2b                	je     800c6e <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c43:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c49:	75 0f                	jne    800c5a <strtol+0x40>
  800c4b:	80 3a 30             	cmpb   $0x30,(%edx)
  800c4e:	74 28                	je     800c78 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c50:	85 db                	test   %ebx,%ebx
  800c52:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c57:	0f 44 d8             	cmove  %eax,%ebx
  800c5a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c5f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c62:	eb 46                	jmp    800caa <strtol+0x90>
		s++;
  800c64:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  800c67:	bf 00 00 00 00       	mov    $0x0,%edi
  800c6c:	eb d5                	jmp    800c43 <strtol+0x29>
		s++, neg = 1;
  800c6e:	83 c2 01             	add    $0x1,%edx
  800c71:	bf 01 00 00 00       	mov    $0x1,%edi
  800c76:	eb cb                	jmp    800c43 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c78:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c7c:	74 0e                	je     800c8c <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  800c7e:	85 db                	test   %ebx,%ebx
  800c80:	75 d8                	jne    800c5a <strtol+0x40>
		s++, base = 8;
  800c82:	83 c2 01             	add    $0x1,%edx
  800c85:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c8a:	eb ce                	jmp    800c5a <strtol+0x40>
		s += 2, base = 16;
  800c8c:	83 c2 02             	add    $0x2,%edx
  800c8f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c94:	eb c4                	jmp    800c5a <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c96:	0f be c0             	movsbl %al,%eax
  800c99:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c9c:	3b 45 10             	cmp    0x10(%ebp),%eax
  800c9f:	7d 3a                	jge    800cdb <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  800ca1:	83 c2 01             	add    $0x1,%edx
  800ca4:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  800ca8:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  800caa:	0f b6 02             	movzbl (%edx),%eax
  800cad:	8d 70 d0             	lea    -0x30(%eax),%esi
  800cb0:	89 f3                	mov    %esi,%ebx
  800cb2:	80 fb 09             	cmp    $0x9,%bl
  800cb5:	76 df                	jbe    800c96 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  800cb7:	8d 70 9f             	lea    -0x61(%eax),%esi
  800cba:	89 f3                	mov    %esi,%ebx
  800cbc:	80 fb 19             	cmp    $0x19,%bl
  800cbf:	77 08                	ja     800cc9 <strtol+0xaf>
			dig = *s - 'a' + 10;
  800cc1:	0f be c0             	movsbl %al,%eax
  800cc4:	83 e8 57             	sub    $0x57,%eax
  800cc7:	eb d3                	jmp    800c9c <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  800cc9:	8d 70 bf             	lea    -0x41(%eax),%esi
  800ccc:	89 f3                	mov    %esi,%ebx
  800cce:	80 fb 19             	cmp    $0x19,%bl
  800cd1:	77 08                	ja     800cdb <strtol+0xc1>
			dig = *s - 'A' + 10;
  800cd3:	0f be c0             	movsbl %al,%eax
  800cd6:	83 e8 37             	sub    $0x37,%eax
  800cd9:	eb c1                	jmp    800c9c <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  800cdb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cdf:	74 05                	je     800ce6 <strtol+0xcc>
		*endptr = (char *) s;
  800ce1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce4:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  800ce6:	89 c8                	mov    %ecx,%eax
  800ce8:	f7 d8                	neg    %eax
  800cea:	85 ff                	test   %edi,%edi
  800cec:	0f 45 c8             	cmovne %eax,%ecx
}
  800cef:	89 c8                	mov    %ecx,%eax
  800cf1:	5b                   	pop    %ebx
  800cf2:	5e                   	pop    %esi
  800cf3:	5f                   	pop    %edi
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    
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
