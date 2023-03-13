
obj/user/softint.debug：     文件格式 elf32-i386


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
  80002c:	e8 05 00 00 00       	call   800036 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	asm volatile("int $14");	// page fault
  800033:	cd 0e                	int    $0xe
}
  800035:	c3                   	ret    

00800036 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800036:	55                   	push   %ebp
  800037:	89 e5                	mov    %esp,%ebp
  800039:	56                   	push   %esi
  80003a:	53                   	push   %ebx
  80003b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800041:	e8 ce 00 00 00       	call   800114 <sys_getenvid>
  800046:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80004e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800053:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800058:	85 db                	test   %ebx,%ebx
  80005a:	7e 07                	jle    800063 <libmain+0x2d>
		binaryname = argv[0];
  80005c:	8b 06                	mov    (%esi),%eax
  80005e:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800063:	83 ec 08             	sub    $0x8,%esp
  800066:	56                   	push   %esi
  800067:	53                   	push   %ebx
  800068:	e8 c6 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80006d:	e8 0a 00 00 00       	call   80007c <exit>
}
  800072:	83 c4 10             	add    $0x10,%esp
  800075:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800078:	5b                   	pop    %ebx
  800079:	5e                   	pop    %esi
  80007a:	5d                   	pop    %ebp
  80007b:	c3                   	ret    

0080007c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007c:	55                   	push   %ebp
  80007d:	89 e5                	mov    %esp,%ebp
  80007f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800082:	e8 88 04 00 00       	call   80050f <close_all>
	sys_env_destroy(0);
  800087:	83 ec 0c             	sub    $0xc,%esp
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
  800103:	68 6a 1d 80 00       	push   $0x801d6a
  800108:	6a 2a                	push   $0x2a
  80010a:	68 87 1d 80 00       	push   $0x801d87
  80010f:	e8 d0 0e 00 00       	call   800fe4 <_panic>

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
  80013e:	b8 0b 00 00 00       	mov    $0xb,%eax
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
  800184:	68 6a 1d 80 00       	push   $0x801d6a
  800189:	6a 2a                	push   $0x2a
  80018b:	68 87 1d 80 00       	push   $0x801d87
  800190:	e8 4f 0e 00 00       	call   800fe4 <_panic>

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
  8001c6:	68 6a 1d 80 00       	push   $0x801d6a
  8001cb:	6a 2a                	push   $0x2a
  8001cd:	68 87 1d 80 00       	push   $0x801d87
  8001d2:	e8 0d 0e 00 00       	call   800fe4 <_panic>

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
  800208:	68 6a 1d 80 00       	push   $0x801d6a
  80020d:	6a 2a                	push   $0x2a
  80020f:	68 87 1d 80 00       	push   $0x801d87
  800214:	e8 cb 0d 00 00       	call   800fe4 <_panic>

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
  80024a:	68 6a 1d 80 00       	push   $0x801d6a
  80024f:	6a 2a                	push   $0x2a
  800251:	68 87 1d 80 00       	push   $0x801d87
  800256:	e8 89 0d 00 00       	call   800fe4 <_panic>

0080025b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
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
  80027c:	7f 08                	jg     800286 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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
  80028c:	68 6a 1d 80 00       	push   $0x801d6a
  800291:	6a 2a                	push   $0x2a
  800293:	68 87 1d 80 00       	push   $0x801d87
  800298:	e8 47 0d 00 00       	call   800fe4 <_panic>

0080029d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	57                   	push   %edi
  8002a1:	56                   	push   %esi
  8002a2:	53                   	push   %ebx
  8002a3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002a6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b6:	89 df                	mov    %ebx,%edi
  8002b8:	89 de                	mov    %ebx,%esi
  8002ba:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002bc:	85 c0                	test   %eax,%eax
  8002be:	7f 08                	jg     8002c8 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c3:	5b                   	pop    %ebx
  8002c4:	5e                   	pop    %esi
  8002c5:	5f                   	pop    %edi
  8002c6:	5d                   	pop    %ebp
  8002c7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c8:	83 ec 0c             	sub    $0xc,%esp
  8002cb:	50                   	push   %eax
  8002cc:	6a 0a                	push   $0xa
  8002ce:	68 6a 1d 80 00       	push   $0x801d6a
  8002d3:	6a 2a                	push   $0x2a
  8002d5:	68 87 1d 80 00       	push   $0x801d87
  8002da:	e8 05 0d 00 00       	call   800fe4 <_panic>

008002df <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002df:	55                   	push   %ebp
  8002e0:	89 e5                	mov    %esp,%ebp
  8002e2:	57                   	push   %edi
  8002e3:	56                   	push   %esi
  8002e4:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002e5:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002eb:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f0:	be 00 00 00 00       	mov    $0x0,%esi
  8002f5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002f8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fb:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002fd:	5b                   	pop    %ebx
  8002fe:	5e                   	pop    %esi
  8002ff:	5f                   	pop    %edi
  800300:	5d                   	pop    %ebp
  800301:	c3                   	ret    

00800302 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800302:	55                   	push   %ebp
  800303:	89 e5                	mov    %esp,%ebp
  800305:	57                   	push   %edi
  800306:	56                   	push   %esi
  800307:	53                   	push   %ebx
  800308:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80030b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800310:	8b 55 08             	mov    0x8(%ebp),%edx
  800313:	b8 0d 00 00 00       	mov    $0xd,%eax
  800318:	89 cb                	mov    %ecx,%ebx
  80031a:	89 cf                	mov    %ecx,%edi
  80031c:	89 ce                	mov    %ecx,%esi
  80031e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800320:	85 c0                	test   %eax,%eax
  800322:	7f 08                	jg     80032c <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800324:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800327:	5b                   	pop    %ebx
  800328:	5e                   	pop    %esi
  800329:	5f                   	pop    %edi
  80032a:	5d                   	pop    %ebp
  80032b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80032c:	83 ec 0c             	sub    $0xc,%esp
  80032f:	50                   	push   %eax
  800330:	6a 0d                	push   $0xd
  800332:	68 6a 1d 80 00       	push   $0x801d6a
  800337:	6a 2a                	push   $0x2a
  800339:	68 87 1d 80 00       	push   $0x801d87
  80033e:	e8 a1 0c 00 00       	call   800fe4 <_panic>

00800343 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800346:	8b 45 08             	mov    0x8(%ebp),%eax
  800349:	05 00 00 00 30       	add    $0x30000000,%eax
  80034e:	c1 e8 0c             	shr    $0xc,%eax
}
  800351:	5d                   	pop    %ebp
  800352:	c3                   	ret    

00800353 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800353:	55                   	push   %ebp
  800354:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800356:	8b 45 08             	mov    0x8(%ebp),%eax
  800359:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80035e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800363:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800368:	5d                   	pop    %ebp
  800369:	c3                   	ret    

0080036a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80036a:	55                   	push   %ebp
  80036b:	89 e5                	mov    %esp,%ebp
  80036d:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800372:	89 c2                	mov    %eax,%edx
  800374:	c1 ea 16             	shr    $0x16,%edx
  800377:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80037e:	f6 c2 01             	test   $0x1,%dl
  800381:	74 29                	je     8003ac <fd_alloc+0x42>
  800383:	89 c2                	mov    %eax,%edx
  800385:	c1 ea 0c             	shr    $0xc,%edx
  800388:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80038f:	f6 c2 01             	test   $0x1,%dl
  800392:	74 18                	je     8003ac <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800394:	05 00 10 00 00       	add    $0x1000,%eax
  800399:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80039e:	75 d2                	jne    800372 <fd_alloc+0x8>
  8003a0:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8003a5:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8003aa:	eb 05                	jmp    8003b1 <fd_alloc+0x47>
			return 0;
  8003ac:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8003b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b4:	89 02                	mov    %eax,(%edx)
}
  8003b6:	89 c8                	mov    %ecx,%eax
  8003b8:	5d                   	pop    %ebp
  8003b9:	c3                   	ret    

008003ba <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ba:	55                   	push   %ebp
  8003bb:	89 e5                	mov    %esp,%ebp
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c0:	83 f8 1f             	cmp    $0x1f,%eax
  8003c3:	77 30                	ja     8003f5 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c5:	c1 e0 0c             	shl    $0xc,%eax
  8003c8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003cd:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003d3:	f6 c2 01             	test   $0x1,%dl
  8003d6:	74 24                	je     8003fc <fd_lookup+0x42>
  8003d8:	89 c2                	mov    %eax,%edx
  8003da:	c1 ea 0c             	shr    $0xc,%edx
  8003dd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e4:	f6 c2 01             	test   $0x1,%dl
  8003e7:	74 1a                	je     800403 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ec:	89 02                	mov    %eax,(%edx)
	return 0;
  8003ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003f3:	5d                   	pop    %ebp
  8003f4:	c3                   	ret    
		return -E_INVAL;
  8003f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003fa:	eb f7                	jmp    8003f3 <fd_lookup+0x39>
		return -E_INVAL;
  8003fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800401:	eb f0                	jmp    8003f3 <fd_lookup+0x39>
  800403:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800408:	eb e9                	jmp    8003f3 <fd_lookup+0x39>

0080040a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80040a:	55                   	push   %ebp
  80040b:	89 e5                	mov    %esp,%ebp
  80040d:	53                   	push   %ebx
  80040e:	83 ec 04             	sub    $0x4,%esp
  800411:	8b 55 08             	mov    0x8(%ebp),%edx
  800414:	b8 14 1e 80 00       	mov    $0x801e14,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800419:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80041e:	39 13                	cmp    %edx,(%ebx)
  800420:	74 32                	je     800454 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800422:	83 c0 04             	add    $0x4,%eax
  800425:	8b 18                	mov    (%eax),%ebx
  800427:	85 db                	test   %ebx,%ebx
  800429:	75 f3                	jne    80041e <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80042b:	a1 00 40 80 00       	mov    0x804000,%eax
  800430:	8b 40 48             	mov    0x48(%eax),%eax
  800433:	83 ec 04             	sub    $0x4,%esp
  800436:	52                   	push   %edx
  800437:	50                   	push   %eax
  800438:	68 98 1d 80 00       	push   $0x801d98
  80043d:	e8 7d 0c 00 00       	call   8010bf <cprintf>
	*dev = 0;
	return -E_INVAL;
  800442:	83 c4 10             	add    $0x10,%esp
  800445:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  80044a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044d:	89 1a                	mov    %ebx,(%edx)
}
  80044f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800452:	c9                   	leave  
  800453:	c3                   	ret    
			return 0;
  800454:	b8 00 00 00 00       	mov    $0x0,%eax
  800459:	eb ef                	jmp    80044a <dev_lookup+0x40>

0080045b <fd_close>:
{
  80045b:	55                   	push   %ebp
  80045c:	89 e5                	mov    %esp,%ebp
  80045e:	57                   	push   %edi
  80045f:	56                   	push   %esi
  800460:	53                   	push   %ebx
  800461:	83 ec 24             	sub    $0x24,%esp
  800464:	8b 75 08             	mov    0x8(%ebp),%esi
  800467:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80046a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80046d:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80046e:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800474:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800477:	50                   	push   %eax
  800478:	e8 3d ff ff ff       	call   8003ba <fd_lookup>
  80047d:	89 c3                	mov    %eax,%ebx
  80047f:	83 c4 10             	add    $0x10,%esp
  800482:	85 c0                	test   %eax,%eax
  800484:	78 05                	js     80048b <fd_close+0x30>
	    || fd != fd2)
  800486:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800489:	74 16                	je     8004a1 <fd_close+0x46>
		return (must_exist ? r : 0);
  80048b:	89 f8                	mov    %edi,%eax
  80048d:	84 c0                	test   %al,%al
  80048f:	b8 00 00 00 00       	mov    $0x0,%eax
  800494:	0f 44 d8             	cmove  %eax,%ebx
}
  800497:	89 d8                	mov    %ebx,%eax
  800499:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80049c:	5b                   	pop    %ebx
  80049d:	5e                   	pop    %esi
  80049e:	5f                   	pop    %edi
  80049f:	5d                   	pop    %ebp
  8004a0:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a1:	83 ec 08             	sub    $0x8,%esp
  8004a4:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004a7:	50                   	push   %eax
  8004a8:	ff 36                	push   (%esi)
  8004aa:	e8 5b ff ff ff       	call   80040a <dev_lookup>
  8004af:	89 c3                	mov    %eax,%ebx
  8004b1:	83 c4 10             	add    $0x10,%esp
  8004b4:	85 c0                	test   %eax,%eax
  8004b6:	78 1a                	js     8004d2 <fd_close+0x77>
		if (dev->dev_close)
  8004b8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004bb:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8004be:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004c3:	85 c0                	test   %eax,%eax
  8004c5:	74 0b                	je     8004d2 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8004c7:	83 ec 0c             	sub    $0xc,%esp
  8004ca:	56                   	push   %esi
  8004cb:	ff d0                	call   *%eax
  8004cd:	89 c3                	mov    %eax,%ebx
  8004cf:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004d2:	83 ec 08             	sub    $0x8,%esp
  8004d5:	56                   	push   %esi
  8004d6:	6a 00                	push   $0x0
  8004d8:	e8 fa fc ff ff       	call   8001d7 <sys_page_unmap>
	return r;
  8004dd:	83 c4 10             	add    $0x10,%esp
  8004e0:	eb b5                	jmp    800497 <fd_close+0x3c>

008004e2 <close>:

int
close(int fdnum)
{
  8004e2:	55                   	push   %ebp
  8004e3:	89 e5                	mov    %esp,%ebp
  8004e5:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004eb:	50                   	push   %eax
  8004ec:	ff 75 08             	push   0x8(%ebp)
  8004ef:	e8 c6 fe ff ff       	call   8003ba <fd_lookup>
  8004f4:	83 c4 10             	add    $0x10,%esp
  8004f7:	85 c0                	test   %eax,%eax
  8004f9:	79 02                	jns    8004fd <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8004fb:	c9                   	leave  
  8004fc:	c3                   	ret    
		return fd_close(fd, 1);
  8004fd:	83 ec 08             	sub    $0x8,%esp
  800500:	6a 01                	push   $0x1
  800502:	ff 75 f4             	push   -0xc(%ebp)
  800505:	e8 51 ff ff ff       	call   80045b <fd_close>
  80050a:	83 c4 10             	add    $0x10,%esp
  80050d:	eb ec                	jmp    8004fb <close+0x19>

0080050f <close_all>:

void
close_all(void)
{
  80050f:	55                   	push   %ebp
  800510:	89 e5                	mov    %esp,%ebp
  800512:	53                   	push   %ebx
  800513:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800516:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051b:	83 ec 0c             	sub    $0xc,%esp
  80051e:	53                   	push   %ebx
  80051f:	e8 be ff ff ff       	call   8004e2 <close>
	for (i = 0; i < MAXFD; i++)
  800524:	83 c3 01             	add    $0x1,%ebx
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	83 fb 20             	cmp    $0x20,%ebx
  80052d:	75 ec                	jne    80051b <close_all+0xc>
}
  80052f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800532:	c9                   	leave  
  800533:	c3                   	ret    

00800534 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800534:	55                   	push   %ebp
  800535:	89 e5                	mov    %esp,%ebp
  800537:	57                   	push   %edi
  800538:	56                   	push   %esi
  800539:	53                   	push   %ebx
  80053a:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80053d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800540:	50                   	push   %eax
  800541:	ff 75 08             	push   0x8(%ebp)
  800544:	e8 71 fe ff ff       	call   8003ba <fd_lookup>
  800549:	89 c3                	mov    %eax,%ebx
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	85 c0                	test   %eax,%eax
  800550:	78 7f                	js     8005d1 <dup+0x9d>
		return r;
	close(newfdnum);
  800552:	83 ec 0c             	sub    $0xc,%esp
  800555:	ff 75 0c             	push   0xc(%ebp)
  800558:	e8 85 ff ff ff       	call   8004e2 <close>

	newfd = INDEX2FD(newfdnum);
  80055d:	8b 75 0c             	mov    0xc(%ebp),%esi
  800560:	c1 e6 0c             	shl    $0xc,%esi
  800563:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800569:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056c:	89 3c 24             	mov    %edi,(%esp)
  80056f:	e8 df fd ff ff       	call   800353 <fd2data>
  800574:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800576:	89 34 24             	mov    %esi,(%esp)
  800579:	e8 d5 fd ff ff       	call   800353 <fd2data>
  80057e:	83 c4 10             	add    $0x10,%esp
  800581:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800584:	89 d8                	mov    %ebx,%eax
  800586:	c1 e8 16             	shr    $0x16,%eax
  800589:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800590:	a8 01                	test   $0x1,%al
  800592:	74 11                	je     8005a5 <dup+0x71>
  800594:	89 d8                	mov    %ebx,%eax
  800596:	c1 e8 0c             	shr    $0xc,%eax
  800599:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a0:	f6 c2 01             	test   $0x1,%dl
  8005a3:	75 36                	jne    8005db <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005a5:	89 f8                	mov    %edi,%eax
  8005a7:	c1 e8 0c             	shr    $0xc,%eax
  8005aa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b1:	83 ec 0c             	sub    $0xc,%esp
  8005b4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b9:	50                   	push   %eax
  8005ba:	56                   	push   %esi
  8005bb:	6a 00                	push   $0x0
  8005bd:	57                   	push   %edi
  8005be:	6a 00                	push   $0x0
  8005c0:	e8 d0 fb ff ff       	call   800195 <sys_page_map>
  8005c5:	89 c3                	mov    %eax,%ebx
  8005c7:	83 c4 20             	add    $0x20,%esp
  8005ca:	85 c0                	test   %eax,%eax
  8005cc:	78 33                	js     800601 <dup+0xcd>
		goto err;

	return newfdnum;
  8005ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005d1:	89 d8                	mov    %ebx,%eax
  8005d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005d6:	5b                   	pop    %ebx
  8005d7:	5e                   	pop    %esi
  8005d8:	5f                   	pop    %edi
  8005d9:	5d                   	pop    %ebp
  8005da:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005db:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e2:	83 ec 0c             	sub    $0xc,%esp
  8005e5:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ea:	50                   	push   %eax
  8005eb:	ff 75 d4             	push   -0x2c(%ebp)
  8005ee:	6a 00                	push   $0x0
  8005f0:	53                   	push   %ebx
  8005f1:	6a 00                	push   $0x0
  8005f3:	e8 9d fb ff ff       	call   800195 <sys_page_map>
  8005f8:	89 c3                	mov    %eax,%ebx
  8005fa:	83 c4 20             	add    $0x20,%esp
  8005fd:	85 c0                	test   %eax,%eax
  8005ff:	79 a4                	jns    8005a5 <dup+0x71>
	sys_page_unmap(0, newfd);
  800601:	83 ec 08             	sub    $0x8,%esp
  800604:	56                   	push   %esi
  800605:	6a 00                	push   $0x0
  800607:	e8 cb fb ff ff       	call   8001d7 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80060c:	83 c4 08             	add    $0x8,%esp
  80060f:	ff 75 d4             	push   -0x2c(%ebp)
  800612:	6a 00                	push   $0x0
  800614:	e8 be fb ff ff       	call   8001d7 <sys_page_unmap>
	return r;
  800619:	83 c4 10             	add    $0x10,%esp
  80061c:	eb b3                	jmp    8005d1 <dup+0x9d>

0080061e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80061e:	55                   	push   %ebp
  80061f:	89 e5                	mov    %esp,%ebp
  800621:	56                   	push   %esi
  800622:	53                   	push   %ebx
  800623:	83 ec 18             	sub    $0x18,%esp
  800626:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800629:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80062c:	50                   	push   %eax
  80062d:	56                   	push   %esi
  80062e:	e8 87 fd ff ff       	call   8003ba <fd_lookup>
  800633:	83 c4 10             	add    $0x10,%esp
  800636:	85 c0                	test   %eax,%eax
  800638:	78 3c                	js     800676 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80063a:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800643:	50                   	push   %eax
  800644:	ff 33                	push   (%ebx)
  800646:	e8 bf fd ff ff       	call   80040a <dev_lookup>
  80064b:	83 c4 10             	add    $0x10,%esp
  80064e:	85 c0                	test   %eax,%eax
  800650:	78 24                	js     800676 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800652:	8b 43 08             	mov    0x8(%ebx),%eax
  800655:	83 e0 03             	and    $0x3,%eax
  800658:	83 f8 01             	cmp    $0x1,%eax
  80065b:	74 20                	je     80067d <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80065d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800660:	8b 40 08             	mov    0x8(%eax),%eax
  800663:	85 c0                	test   %eax,%eax
  800665:	74 37                	je     80069e <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800667:	83 ec 04             	sub    $0x4,%esp
  80066a:	ff 75 10             	push   0x10(%ebp)
  80066d:	ff 75 0c             	push   0xc(%ebp)
  800670:	53                   	push   %ebx
  800671:	ff d0                	call   *%eax
  800673:	83 c4 10             	add    $0x10,%esp
}
  800676:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800679:	5b                   	pop    %ebx
  80067a:	5e                   	pop    %esi
  80067b:	5d                   	pop    %ebp
  80067c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80067d:	a1 00 40 80 00       	mov    0x804000,%eax
  800682:	8b 40 48             	mov    0x48(%eax),%eax
  800685:	83 ec 04             	sub    $0x4,%esp
  800688:	56                   	push   %esi
  800689:	50                   	push   %eax
  80068a:	68 d9 1d 80 00       	push   $0x801dd9
  80068f:	e8 2b 0a 00 00       	call   8010bf <cprintf>
		return -E_INVAL;
  800694:	83 c4 10             	add    $0x10,%esp
  800697:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80069c:	eb d8                	jmp    800676 <read+0x58>
		return -E_NOT_SUPP;
  80069e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006a3:	eb d1                	jmp    800676 <read+0x58>

008006a5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006a5:	55                   	push   %ebp
  8006a6:	89 e5                	mov    %esp,%ebp
  8006a8:	57                   	push   %edi
  8006a9:	56                   	push   %esi
  8006aa:	53                   	push   %ebx
  8006ab:	83 ec 0c             	sub    $0xc,%esp
  8006ae:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006b1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006b4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006b9:	eb 02                	jmp    8006bd <readn+0x18>
  8006bb:	01 c3                	add    %eax,%ebx
  8006bd:	39 f3                	cmp    %esi,%ebx
  8006bf:	73 21                	jae    8006e2 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006c1:	83 ec 04             	sub    $0x4,%esp
  8006c4:	89 f0                	mov    %esi,%eax
  8006c6:	29 d8                	sub    %ebx,%eax
  8006c8:	50                   	push   %eax
  8006c9:	89 d8                	mov    %ebx,%eax
  8006cb:	03 45 0c             	add    0xc(%ebp),%eax
  8006ce:	50                   	push   %eax
  8006cf:	57                   	push   %edi
  8006d0:	e8 49 ff ff ff       	call   80061e <read>
		if (m < 0)
  8006d5:	83 c4 10             	add    $0x10,%esp
  8006d8:	85 c0                	test   %eax,%eax
  8006da:	78 04                	js     8006e0 <readn+0x3b>
			return m;
		if (m == 0)
  8006dc:	75 dd                	jne    8006bb <readn+0x16>
  8006de:	eb 02                	jmp    8006e2 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006e0:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006e2:	89 d8                	mov    %ebx,%eax
  8006e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e7:	5b                   	pop    %ebx
  8006e8:	5e                   	pop    %esi
  8006e9:	5f                   	pop    %edi
  8006ea:	5d                   	pop    %ebp
  8006eb:	c3                   	ret    

008006ec <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006ec:	55                   	push   %ebp
  8006ed:	89 e5                	mov    %esp,%ebp
  8006ef:	56                   	push   %esi
  8006f0:	53                   	push   %ebx
  8006f1:	83 ec 18             	sub    $0x18,%esp
  8006f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006fa:	50                   	push   %eax
  8006fb:	53                   	push   %ebx
  8006fc:	e8 b9 fc ff ff       	call   8003ba <fd_lookup>
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	85 c0                	test   %eax,%eax
  800706:	78 37                	js     80073f <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800708:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80070b:	83 ec 08             	sub    $0x8,%esp
  80070e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800711:	50                   	push   %eax
  800712:	ff 36                	push   (%esi)
  800714:	e8 f1 fc ff ff       	call   80040a <dev_lookup>
  800719:	83 c4 10             	add    $0x10,%esp
  80071c:	85 c0                	test   %eax,%eax
  80071e:	78 1f                	js     80073f <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800720:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800724:	74 20                	je     800746 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800726:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800729:	8b 40 0c             	mov    0xc(%eax),%eax
  80072c:	85 c0                	test   %eax,%eax
  80072e:	74 37                	je     800767 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800730:	83 ec 04             	sub    $0x4,%esp
  800733:	ff 75 10             	push   0x10(%ebp)
  800736:	ff 75 0c             	push   0xc(%ebp)
  800739:	56                   	push   %esi
  80073a:	ff d0                	call   *%eax
  80073c:	83 c4 10             	add    $0x10,%esp
}
  80073f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800742:	5b                   	pop    %ebx
  800743:	5e                   	pop    %esi
  800744:	5d                   	pop    %ebp
  800745:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800746:	a1 00 40 80 00       	mov    0x804000,%eax
  80074b:	8b 40 48             	mov    0x48(%eax),%eax
  80074e:	83 ec 04             	sub    $0x4,%esp
  800751:	53                   	push   %ebx
  800752:	50                   	push   %eax
  800753:	68 f5 1d 80 00       	push   $0x801df5
  800758:	e8 62 09 00 00       	call   8010bf <cprintf>
		return -E_INVAL;
  80075d:	83 c4 10             	add    $0x10,%esp
  800760:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800765:	eb d8                	jmp    80073f <write+0x53>
		return -E_NOT_SUPP;
  800767:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80076c:	eb d1                	jmp    80073f <write+0x53>

0080076e <seek>:

int
seek(int fdnum, off_t offset)
{
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800774:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800777:	50                   	push   %eax
  800778:	ff 75 08             	push   0x8(%ebp)
  80077b:	e8 3a fc ff ff       	call   8003ba <fd_lookup>
  800780:	83 c4 10             	add    $0x10,%esp
  800783:	85 c0                	test   %eax,%eax
  800785:	78 0e                	js     800795 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800787:	8b 55 0c             	mov    0xc(%ebp),%edx
  80078a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800790:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800795:	c9                   	leave  
  800796:	c3                   	ret    

00800797 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	56                   	push   %esi
  80079b:	53                   	push   %ebx
  80079c:	83 ec 18             	sub    $0x18,%esp
  80079f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007a5:	50                   	push   %eax
  8007a6:	53                   	push   %ebx
  8007a7:	e8 0e fc ff ff       	call   8003ba <fd_lookup>
  8007ac:	83 c4 10             	add    $0x10,%esp
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	78 34                	js     8007e7 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b3:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8007b6:	83 ec 08             	sub    $0x8,%esp
  8007b9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007bc:	50                   	push   %eax
  8007bd:	ff 36                	push   (%esi)
  8007bf:	e8 46 fc ff ff       	call   80040a <dev_lookup>
  8007c4:	83 c4 10             	add    $0x10,%esp
  8007c7:	85 c0                	test   %eax,%eax
  8007c9:	78 1c                	js     8007e7 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007cb:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8007cf:	74 1d                	je     8007ee <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d4:	8b 40 18             	mov    0x18(%eax),%eax
  8007d7:	85 c0                	test   %eax,%eax
  8007d9:	74 34                	je     80080f <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007db:	83 ec 08             	sub    $0x8,%esp
  8007de:	ff 75 0c             	push   0xc(%ebp)
  8007e1:	56                   	push   %esi
  8007e2:	ff d0                	call   *%eax
  8007e4:	83 c4 10             	add    $0x10,%esp
}
  8007e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007ea:	5b                   	pop    %ebx
  8007eb:	5e                   	pop    %esi
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007ee:	a1 00 40 80 00       	mov    0x804000,%eax
  8007f3:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f6:	83 ec 04             	sub    $0x4,%esp
  8007f9:	53                   	push   %ebx
  8007fa:	50                   	push   %eax
  8007fb:	68 b8 1d 80 00       	push   $0x801db8
  800800:	e8 ba 08 00 00       	call   8010bf <cprintf>
		return -E_INVAL;
  800805:	83 c4 10             	add    $0x10,%esp
  800808:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80080d:	eb d8                	jmp    8007e7 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80080f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800814:	eb d1                	jmp    8007e7 <ftruncate+0x50>

00800816 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	56                   	push   %esi
  80081a:	53                   	push   %ebx
  80081b:	83 ec 18             	sub    $0x18,%esp
  80081e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800821:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800824:	50                   	push   %eax
  800825:	ff 75 08             	push   0x8(%ebp)
  800828:	e8 8d fb ff ff       	call   8003ba <fd_lookup>
  80082d:	83 c4 10             	add    $0x10,%esp
  800830:	85 c0                	test   %eax,%eax
  800832:	78 49                	js     80087d <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800834:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800837:	83 ec 08             	sub    $0x8,%esp
  80083a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80083d:	50                   	push   %eax
  80083e:	ff 36                	push   (%esi)
  800840:	e8 c5 fb ff ff       	call   80040a <dev_lookup>
  800845:	83 c4 10             	add    $0x10,%esp
  800848:	85 c0                	test   %eax,%eax
  80084a:	78 31                	js     80087d <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80084c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800853:	74 2f                	je     800884 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800855:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800858:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80085f:	00 00 00 
	stat->st_isdir = 0;
  800862:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800869:	00 00 00 
	stat->st_dev = dev;
  80086c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800872:	83 ec 08             	sub    $0x8,%esp
  800875:	53                   	push   %ebx
  800876:	56                   	push   %esi
  800877:	ff 50 14             	call   *0x14(%eax)
  80087a:	83 c4 10             	add    $0x10,%esp
}
  80087d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800880:	5b                   	pop    %ebx
  800881:	5e                   	pop    %esi
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    
		return -E_NOT_SUPP;
  800884:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800889:	eb f2                	jmp    80087d <fstat+0x67>

0080088b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	56                   	push   %esi
  80088f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800890:	83 ec 08             	sub    $0x8,%esp
  800893:	6a 00                	push   $0x0
  800895:	ff 75 08             	push   0x8(%ebp)
  800898:	e8 e4 01 00 00       	call   800a81 <open>
  80089d:	89 c3                	mov    %eax,%ebx
  80089f:	83 c4 10             	add    $0x10,%esp
  8008a2:	85 c0                	test   %eax,%eax
  8008a4:	78 1b                	js     8008c1 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008a6:	83 ec 08             	sub    $0x8,%esp
  8008a9:	ff 75 0c             	push   0xc(%ebp)
  8008ac:	50                   	push   %eax
  8008ad:	e8 64 ff ff ff       	call   800816 <fstat>
  8008b2:	89 c6                	mov    %eax,%esi
	close(fd);
  8008b4:	89 1c 24             	mov    %ebx,(%esp)
  8008b7:	e8 26 fc ff ff       	call   8004e2 <close>
	return r;
  8008bc:	83 c4 10             	add    $0x10,%esp
  8008bf:	89 f3                	mov    %esi,%ebx
}
  8008c1:	89 d8                	mov    %ebx,%eax
  8008c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008c6:	5b                   	pop    %ebx
  8008c7:	5e                   	pop    %esi
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	56                   	push   %esi
  8008ce:	53                   	push   %ebx
  8008cf:	89 c6                	mov    %eax,%esi
  8008d1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008d3:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8008da:	74 27                	je     800903 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008dc:	6a 07                	push   $0x7
  8008de:	68 00 50 80 00       	push   $0x805000
  8008e3:	56                   	push   %esi
  8008e4:	ff 35 00 60 80 00    	push   0x806000
  8008ea:	e8 51 11 00 00       	call   801a40 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008ef:	83 c4 0c             	add    $0xc,%esp
  8008f2:	6a 00                	push   $0x0
  8008f4:	53                   	push   %ebx
  8008f5:	6a 00                	push   $0x0
  8008f7:	e8 dd 10 00 00       	call   8019d9 <ipc_recv>
}
  8008fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800903:	83 ec 0c             	sub    $0xc,%esp
  800906:	6a 01                	push   $0x1
  800908:	e8 87 11 00 00       	call   801a94 <ipc_find_env>
  80090d:	a3 00 60 80 00       	mov    %eax,0x806000
  800912:	83 c4 10             	add    $0x10,%esp
  800915:	eb c5                	jmp    8008dc <fsipc+0x12>

00800917 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800917:	55                   	push   %ebp
  800918:	89 e5                	mov    %esp,%ebp
  80091a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80091d:	8b 45 08             	mov    0x8(%ebp),%eax
  800920:	8b 40 0c             	mov    0xc(%eax),%eax
  800923:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800928:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800930:	ba 00 00 00 00       	mov    $0x0,%edx
  800935:	b8 02 00 00 00       	mov    $0x2,%eax
  80093a:	e8 8b ff ff ff       	call   8008ca <fsipc>
}
  80093f:	c9                   	leave  
  800940:	c3                   	ret    

00800941 <devfile_flush>:
{
  800941:	55                   	push   %ebp
  800942:	89 e5                	mov    %esp,%ebp
  800944:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800947:	8b 45 08             	mov    0x8(%ebp),%eax
  80094a:	8b 40 0c             	mov    0xc(%eax),%eax
  80094d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800952:	ba 00 00 00 00       	mov    $0x0,%edx
  800957:	b8 06 00 00 00       	mov    $0x6,%eax
  80095c:	e8 69 ff ff ff       	call   8008ca <fsipc>
}
  800961:	c9                   	leave  
  800962:	c3                   	ret    

00800963 <devfile_stat>:
{
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	53                   	push   %ebx
  800967:	83 ec 04             	sub    $0x4,%esp
  80096a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	8b 40 0c             	mov    0xc(%eax),%eax
  800973:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800978:	ba 00 00 00 00       	mov    $0x0,%edx
  80097d:	b8 05 00 00 00       	mov    $0x5,%eax
  800982:	e8 43 ff ff ff       	call   8008ca <fsipc>
  800987:	85 c0                	test   %eax,%eax
  800989:	78 2c                	js     8009b7 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80098b:	83 ec 08             	sub    $0x8,%esp
  80098e:	68 00 50 80 00       	push   $0x805000
  800993:	53                   	push   %ebx
  800994:	e8 00 0d 00 00       	call   801699 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800999:	a1 80 50 80 00       	mov    0x805080,%eax
  80099e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009a4:	a1 84 50 80 00       	mov    0x805084,%eax
  8009a9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009af:	83 c4 10             	add    $0x10,%esp
  8009b2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ba:	c9                   	leave  
  8009bb:	c3                   	ret    

008009bc <devfile_write>:
{
  8009bc:	55                   	push   %ebp
  8009bd:	89 e5                	mov    %esp,%ebp
  8009bf:	83 ec 0c             	sub    $0xc,%esp
  8009c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c5:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009ca:	39 d0                	cmp    %edx,%eax
  8009cc:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009cf:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d2:	8b 52 0c             	mov    0xc(%edx),%edx
  8009d5:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009db:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8009e0:	50                   	push   %eax
  8009e1:	ff 75 0c             	push   0xc(%ebp)
  8009e4:	68 08 50 80 00       	push   $0x805008
  8009e9:	e8 41 0e 00 00       	call   80182f <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8009ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f3:	b8 04 00 00 00       	mov    $0x4,%eax
  8009f8:	e8 cd fe ff ff       	call   8008ca <fsipc>
}
  8009fd:	c9                   	leave  
  8009fe:	c3                   	ret    

008009ff <devfile_read>:
{
  8009ff:	55                   	push   %ebp
  800a00:	89 e5                	mov    %esp,%ebp
  800a02:	56                   	push   %esi
  800a03:	53                   	push   %ebx
  800a04:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	8b 40 0c             	mov    0xc(%eax),%eax
  800a0d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a12:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a18:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1d:	b8 03 00 00 00       	mov    $0x3,%eax
  800a22:	e8 a3 fe ff ff       	call   8008ca <fsipc>
  800a27:	89 c3                	mov    %eax,%ebx
  800a29:	85 c0                	test   %eax,%eax
  800a2b:	78 1f                	js     800a4c <devfile_read+0x4d>
	assert(r <= n);
  800a2d:	39 f0                	cmp    %esi,%eax
  800a2f:	77 24                	ja     800a55 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a31:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a36:	7f 33                	jg     800a6b <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a38:	83 ec 04             	sub    $0x4,%esp
  800a3b:	50                   	push   %eax
  800a3c:	68 00 50 80 00       	push   $0x805000
  800a41:	ff 75 0c             	push   0xc(%ebp)
  800a44:	e8 e6 0d 00 00       	call   80182f <memmove>
	return r;
  800a49:	83 c4 10             	add    $0x10,%esp
}
  800a4c:	89 d8                	mov    %ebx,%eax
  800a4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a51:	5b                   	pop    %ebx
  800a52:	5e                   	pop    %esi
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    
	assert(r <= n);
  800a55:	68 24 1e 80 00       	push   $0x801e24
  800a5a:	68 2b 1e 80 00       	push   $0x801e2b
  800a5f:	6a 7c                	push   $0x7c
  800a61:	68 40 1e 80 00       	push   $0x801e40
  800a66:	e8 79 05 00 00       	call   800fe4 <_panic>
	assert(r <= PGSIZE);
  800a6b:	68 4b 1e 80 00       	push   $0x801e4b
  800a70:	68 2b 1e 80 00       	push   $0x801e2b
  800a75:	6a 7d                	push   $0x7d
  800a77:	68 40 1e 80 00       	push   $0x801e40
  800a7c:	e8 63 05 00 00       	call   800fe4 <_panic>

00800a81 <open>:
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	56                   	push   %esi
  800a85:	53                   	push   %ebx
  800a86:	83 ec 1c             	sub    $0x1c,%esp
  800a89:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800a8c:	56                   	push   %esi
  800a8d:	e8 cc 0b 00 00       	call   80165e <strlen>
  800a92:	83 c4 10             	add    $0x10,%esp
  800a95:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a9a:	7f 6c                	jg     800b08 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800a9c:	83 ec 0c             	sub    $0xc,%esp
  800a9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aa2:	50                   	push   %eax
  800aa3:	e8 c2 f8 ff ff       	call   80036a <fd_alloc>
  800aa8:	89 c3                	mov    %eax,%ebx
  800aaa:	83 c4 10             	add    $0x10,%esp
  800aad:	85 c0                	test   %eax,%eax
  800aaf:	78 3c                	js     800aed <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800ab1:	83 ec 08             	sub    $0x8,%esp
  800ab4:	56                   	push   %esi
  800ab5:	68 00 50 80 00       	push   $0x805000
  800aba:	e8 da 0b 00 00       	call   801699 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800abf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac2:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ac7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aca:	b8 01 00 00 00       	mov    $0x1,%eax
  800acf:	e8 f6 fd ff ff       	call   8008ca <fsipc>
  800ad4:	89 c3                	mov    %eax,%ebx
  800ad6:	83 c4 10             	add    $0x10,%esp
  800ad9:	85 c0                	test   %eax,%eax
  800adb:	78 19                	js     800af6 <open+0x75>
	return fd2num(fd);
  800add:	83 ec 0c             	sub    $0xc,%esp
  800ae0:	ff 75 f4             	push   -0xc(%ebp)
  800ae3:	e8 5b f8 ff ff       	call   800343 <fd2num>
  800ae8:	89 c3                	mov    %eax,%ebx
  800aea:	83 c4 10             	add    $0x10,%esp
}
  800aed:	89 d8                	mov    %ebx,%eax
  800aef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    
		fd_close(fd, 0);
  800af6:	83 ec 08             	sub    $0x8,%esp
  800af9:	6a 00                	push   $0x0
  800afb:	ff 75 f4             	push   -0xc(%ebp)
  800afe:	e8 58 f9 ff ff       	call   80045b <fd_close>
		return r;
  800b03:	83 c4 10             	add    $0x10,%esp
  800b06:	eb e5                	jmp    800aed <open+0x6c>
		return -E_BAD_PATH;
  800b08:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b0d:	eb de                	jmp    800aed <open+0x6c>

00800b0f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b0f:	55                   	push   %ebp
  800b10:	89 e5                	mov    %esp,%ebp
  800b12:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b15:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1a:	b8 08 00 00 00       	mov    $0x8,%eax
  800b1f:	e8 a6 fd ff ff       	call   8008ca <fsipc>
}
  800b24:	c9                   	leave  
  800b25:	c3                   	ret    

00800b26 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b26:	55                   	push   %ebp
  800b27:	89 e5                	mov    %esp,%ebp
  800b29:	56                   	push   %esi
  800b2a:	53                   	push   %ebx
  800b2b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b2e:	83 ec 0c             	sub    $0xc,%esp
  800b31:	ff 75 08             	push   0x8(%ebp)
  800b34:	e8 1a f8 ff ff       	call   800353 <fd2data>
  800b39:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b3b:	83 c4 08             	add    $0x8,%esp
  800b3e:	68 57 1e 80 00       	push   $0x801e57
  800b43:	53                   	push   %ebx
  800b44:	e8 50 0b 00 00       	call   801699 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b49:	8b 46 04             	mov    0x4(%esi),%eax
  800b4c:	2b 06                	sub    (%esi),%eax
  800b4e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b54:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b5b:	00 00 00 
	stat->st_dev = &devpipe;
  800b5e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b65:	30 80 00 
	return 0;
}
  800b68:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5d                   	pop    %ebp
  800b73:	c3                   	ret    

00800b74 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	53                   	push   %ebx
  800b78:	83 ec 0c             	sub    $0xc,%esp
  800b7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b7e:	53                   	push   %ebx
  800b7f:	6a 00                	push   $0x0
  800b81:	e8 51 f6 ff ff       	call   8001d7 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b86:	89 1c 24             	mov    %ebx,(%esp)
  800b89:	e8 c5 f7 ff ff       	call   800353 <fd2data>
  800b8e:	83 c4 08             	add    $0x8,%esp
  800b91:	50                   	push   %eax
  800b92:	6a 00                	push   $0x0
  800b94:	e8 3e f6 ff ff       	call   8001d7 <sys_page_unmap>
}
  800b99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b9c:	c9                   	leave  
  800b9d:	c3                   	ret    

00800b9e <_pipeisclosed>:
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	57                   	push   %edi
  800ba2:	56                   	push   %esi
  800ba3:	53                   	push   %ebx
  800ba4:	83 ec 1c             	sub    $0x1c,%esp
  800ba7:	89 c7                	mov    %eax,%edi
  800ba9:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bab:	a1 00 40 80 00       	mov    0x804000,%eax
  800bb0:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bb3:	83 ec 0c             	sub    $0xc,%esp
  800bb6:	57                   	push   %edi
  800bb7:	e8 11 0f 00 00       	call   801acd <pageref>
  800bbc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bbf:	89 34 24             	mov    %esi,(%esp)
  800bc2:	e8 06 0f 00 00       	call   801acd <pageref>
		nn = thisenv->env_runs;
  800bc7:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800bcd:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bd0:	83 c4 10             	add    $0x10,%esp
  800bd3:	39 cb                	cmp    %ecx,%ebx
  800bd5:	74 1b                	je     800bf2 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800bd7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800bda:	75 cf                	jne    800bab <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bdc:	8b 42 58             	mov    0x58(%edx),%eax
  800bdf:	6a 01                	push   $0x1
  800be1:	50                   	push   %eax
  800be2:	53                   	push   %ebx
  800be3:	68 5e 1e 80 00       	push   $0x801e5e
  800be8:	e8 d2 04 00 00       	call   8010bf <cprintf>
  800bed:	83 c4 10             	add    $0x10,%esp
  800bf0:	eb b9                	jmp    800bab <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800bf2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800bf5:	0f 94 c0             	sete   %al
  800bf8:	0f b6 c0             	movzbl %al,%eax
}
  800bfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfe:	5b                   	pop    %ebx
  800bff:	5e                   	pop    %esi
  800c00:	5f                   	pop    %edi
  800c01:	5d                   	pop    %ebp
  800c02:	c3                   	ret    

00800c03 <devpipe_write>:
{
  800c03:	55                   	push   %ebp
  800c04:	89 e5                	mov    %esp,%ebp
  800c06:	57                   	push   %edi
  800c07:	56                   	push   %esi
  800c08:	53                   	push   %ebx
  800c09:	83 ec 28             	sub    $0x28,%esp
  800c0c:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c0f:	56                   	push   %esi
  800c10:	e8 3e f7 ff ff       	call   800353 <fd2data>
  800c15:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c17:	83 c4 10             	add    $0x10,%esp
  800c1a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c1f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c22:	75 09                	jne    800c2d <devpipe_write+0x2a>
	return i;
  800c24:	89 f8                	mov    %edi,%eax
  800c26:	eb 23                	jmp    800c4b <devpipe_write+0x48>
			sys_yield();
  800c28:	e8 06 f5 ff ff       	call   800133 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c2d:	8b 43 04             	mov    0x4(%ebx),%eax
  800c30:	8b 0b                	mov    (%ebx),%ecx
  800c32:	8d 51 20             	lea    0x20(%ecx),%edx
  800c35:	39 d0                	cmp    %edx,%eax
  800c37:	72 1a                	jb     800c53 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  800c39:	89 da                	mov    %ebx,%edx
  800c3b:	89 f0                	mov    %esi,%eax
  800c3d:	e8 5c ff ff ff       	call   800b9e <_pipeisclosed>
  800c42:	85 c0                	test   %eax,%eax
  800c44:	74 e2                	je     800c28 <devpipe_write+0x25>
				return 0;
  800c46:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4e:	5b                   	pop    %ebx
  800c4f:	5e                   	pop    %esi
  800c50:	5f                   	pop    %edi
  800c51:	5d                   	pop    %ebp
  800c52:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c56:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c5a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c5d:	89 c2                	mov    %eax,%edx
  800c5f:	c1 fa 1f             	sar    $0x1f,%edx
  800c62:	89 d1                	mov    %edx,%ecx
  800c64:	c1 e9 1b             	shr    $0x1b,%ecx
  800c67:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c6a:	83 e2 1f             	and    $0x1f,%edx
  800c6d:	29 ca                	sub    %ecx,%edx
  800c6f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c73:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c77:	83 c0 01             	add    $0x1,%eax
  800c7a:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c7d:	83 c7 01             	add    $0x1,%edi
  800c80:	eb 9d                	jmp    800c1f <devpipe_write+0x1c>

00800c82 <devpipe_read>:
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 18             	sub    $0x18,%esp
  800c8b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800c8e:	57                   	push   %edi
  800c8f:	e8 bf f6 ff ff       	call   800353 <fd2data>
  800c94:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c96:	83 c4 10             	add    $0x10,%esp
  800c99:	be 00 00 00 00       	mov    $0x0,%esi
  800c9e:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ca1:	75 13                	jne    800cb6 <devpipe_read+0x34>
	return i;
  800ca3:	89 f0                	mov    %esi,%eax
  800ca5:	eb 02                	jmp    800ca9 <devpipe_read+0x27>
				return i;
  800ca7:	89 f0                	mov    %esi,%eax
}
  800ca9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cac:	5b                   	pop    %ebx
  800cad:	5e                   	pop    %esi
  800cae:	5f                   	pop    %edi
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    
			sys_yield();
  800cb1:	e8 7d f4 ff ff       	call   800133 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800cb6:	8b 03                	mov    (%ebx),%eax
  800cb8:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cbb:	75 18                	jne    800cd5 <devpipe_read+0x53>
			if (i > 0)
  800cbd:	85 f6                	test   %esi,%esi
  800cbf:	75 e6                	jne    800ca7 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  800cc1:	89 da                	mov    %ebx,%edx
  800cc3:	89 f8                	mov    %edi,%eax
  800cc5:	e8 d4 fe ff ff       	call   800b9e <_pipeisclosed>
  800cca:	85 c0                	test   %eax,%eax
  800ccc:	74 e3                	je     800cb1 <devpipe_read+0x2f>
				return 0;
  800cce:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd3:	eb d4                	jmp    800ca9 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cd5:	99                   	cltd   
  800cd6:	c1 ea 1b             	shr    $0x1b,%edx
  800cd9:	01 d0                	add    %edx,%eax
  800cdb:	83 e0 1f             	and    $0x1f,%eax
  800cde:	29 d0                	sub    %edx,%eax
  800ce0:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800ce5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce8:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800ceb:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800cee:	83 c6 01             	add    $0x1,%esi
  800cf1:	eb ab                	jmp    800c9e <devpipe_read+0x1c>

00800cf3 <pipe>:
{
  800cf3:	55                   	push   %ebp
  800cf4:	89 e5                	mov    %esp,%ebp
  800cf6:	56                   	push   %esi
  800cf7:	53                   	push   %ebx
  800cf8:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800cfb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cfe:	50                   	push   %eax
  800cff:	e8 66 f6 ff ff       	call   80036a <fd_alloc>
  800d04:	89 c3                	mov    %eax,%ebx
  800d06:	83 c4 10             	add    $0x10,%esp
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	0f 88 23 01 00 00    	js     800e34 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d11:	83 ec 04             	sub    $0x4,%esp
  800d14:	68 07 04 00 00       	push   $0x407
  800d19:	ff 75 f4             	push   -0xc(%ebp)
  800d1c:	6a 00                	push   $0x0
  800d1e:	e8 2f f4 ff ff       	call   800152 <sys_page_alloc>
  800d23:	89 c3                	mov    %eax,%ebx
  800d25:	83 c4 10             	add    $0x10,%esp
  800d28:	85 c0                	test   %eax,%eax
  800d2a:	0f 88 04 01 00 00    	js     800e34 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  800d30:	83 ec 0c             	sub    $0xc,%esp
  800d33:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d36:	50                   	push   %eax
  800d37:	e8 2e f6 ff ff       	call   80036a <fd_alloc>
  800d3c:	89 c3                	mov    %eax,%ebx
  800d3e:	83 c4 10             	add    $0x10,%esp
  800d41:	85 c0                	test   %eax,%eax
  800d43:	0f 88 db 00 00 00    	js     800e24 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d49:	83 ec 04             	sub    $0x4,%esp
  800d4c:	68 07 04 00 00       	push   $0x407
  800d51:	ff 75 f0             	push   -0x10(%ebp)
  800d54:	6a 00                	push   $0x0
  800d56:	e8 f7 f3 ff ff       	call   800152 <sys_page_alloc>
  800d5b:	89 c3                	mov    %eax,%ebx
  800d5d:	83 c4 10             	add    $0x10,%esp
  800d60:	85 c0                	test   %eax,%eax
  800d62:	0f 88 bc 00 00 00    	js     800e24 <pipe+0x131>
	va = fd2data(fd0);
  800d68:	83 ec 0c             	sub    $0xc,%esp
  800d6b:	ff 75 f4             	push   -0xc(%ebp)
  800d6e:	e8 e0 f5 ff ff       	call   800353 <fd2data>
  800d73:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d75:	83 c4 0c             	add    $0xc,%esp
  800d78:	68 07 04 00 00       	push   $0x407
  800d7d:	50                   	push   %eax
  800d7e:	6a 00                	push   $0x0
  800d80:	e8 cd f3 ff ff       	call   800152 <sys_page_alloc>
  800d85:	89 c3                	mov    %eax,%ebx
  800d87:	83 c4 10             	add    $0x10,%esp
  800d8a:	85 c0                	test   %eax,%eax
  800d8c:	0f 88 82 00 00 00    	js     800e14 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d92:	83 ec 0c             	sub    $0xc,%esp
  800d95:	ff 75 f0             	push   -0x10(%ebp)
  800d98:	e8 b6 f5 ff ff       	call   800353 <fd2data>
  800d9d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800da4:	50                   	push   %eax
  800da5:	6a 00                	push   $0x0
  800da7:	56                   	push   %esi
  800da8:	6a 00                	push   $0x0
  800daa:	e8 e6 f3 ff ff       	call   800195 <sys_page_map>
  800daf:	89 c3                	mov    %eax,%ebx
  800db1:	83 c4 20             	add    $0x20,%esp
  800db4:	85 c0                	test   %eax,%eax
  800db6:	78 4e                	js     800e06 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  800db8:	a1 20 30 80 00       	mov    0x803020,%eax
  800dbd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dc0:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800dc2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dc5:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800dcc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dcf:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800dd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dd4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800ddb:	83 ec 0c             	sub    $0xc,%esp
  800dde:	ff 75 f4             	push   -0xc(%ebp)
  800de1:	e8 5d f5 ff ff       	call   800343 <fd2num>
  800de6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800deb:	83 c4 04             	add    $0x4,%esp
  800dee:	ff 75 f0             	push   -0x10(%ebp)
  800df1:	e8 4d f5 ff ff       	call   800343 <fd2num>
  800df6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800dfc:	83 c4 10             	add    $0x10,%esp
  800dff:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e04:	eb 2e                	jmp    800e34 <pipe+0x141>
	sys_page_unmap(0, va);
  800e06:	83 ec 08             	sub    $0x8,%esp
  800e09:	56                   	push   %esi
  800e0a:	6a 00                	push   $0x0
  800e0c:	e8 c6 f3 ff ff       	call   8001d7 <sys_page_unmap>
  800e11:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e14:	83 ec 08             	sub    $0x8,%esp
  800e17:	ff 75 f0             	push   -0x10(%ebp)
  800e1a:	6a 00                	push   $0x0
  800e1c:	e8 b6 f3 ff ff       	call   8001d7 <sys_page_unmap>
  800e21:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e24:	83 ec 08             	sub    $0x8,%esp
  800e27:	ff 75 f4             	push   -0xc(%ebp)
  800e2a:	6a 00                	push   $0x0
  800e2c:	e8 a6 f3 ff ff       	call   8001d7 <sys_page_unmap>
  800e31:	83 c4 10             	add    $0x10,%esp
}
  800e34:	89 d8                	mov    %ebx,%eax
  800e36:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e39:	5b                   	pop    %ebx
  800e3a:	5e                   	pop    %esi
  800e3b:	5d                   	pop    %ebp
  800e3c:	c3                   	ret    

00800e3d <pipeisclosed>:
{
  800e3d:	55                   	push   %ebp
  800e3e:	89 e5                	mov    %esp,%ebp
  800e40:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e46:	50                   	push   %eax
  800e47:	ff 75 08             	push   0x8(%ebp)
  800e4a:	e8 6b f5 ff ff       	call   8003ba <fd_lookup>
  800e4f:	83 c4 10             	add    $0x10,%esp
  800e52:	85 c0                	test   %eax,%eax
  800e54:	78 18                	js     800e6e <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e56:	83 ec 0c             	sub    $0xc,%esp
  800e59:	ff 75 f4             	push   -0xc(%ebp)
  800e5c:	e8 f2 f4 ff ff       	call   800353 <fd2data>
  800e61:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800e63:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e66:	e8 33 fd ff ff       	call   800b9e <_pipeisclosed>
  800e6b:	83 c4 10             	add    $0x10,%esp
}
  800e6e:	c9                   	leave  
  800e6f:	c3                   	ret    

00800e70 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  800e70:	b8 00 00 00 00       	mov    $0x0,%eax
  800e75:	c3                   	ret    

00800e76 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e76:	55                   	push   %ebp
  800e77:	89 e5                	mov    %esp,%ebp
  800e79:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e7c:	68 76 1e 80 00       	push   $0x801e76
  800e81:	ff 75 0c             	push   0xc(%ebp)
  800e84:	e8 10 08 00 00       	call   801699 <strcpy>
	return 0;
}
  800e89:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8e:	c9                   	leave  
  800e8f:	c3                   	ret    

00800e90 <devcons_write>:
{
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	57                   	push   %edi
  800e94:	56                   	push   %esi
  800e95:	53                   	push   %ebx
  800e96:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800e9c:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ea1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800ea7:	eb 2e                	jmp    800ed7 <devcons_write+0x47>
		m = n - tot;
  800ea9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eac:	29 f3                	sub    %esi,%ebx
  800eae:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800eb3:	39 c3                	cmp    %eax,%ebx
  800eb5:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800eb8:	83 ec 04             	sub    $0x4,%esp
  800ebb:	53                   	push   %ebx
  800ebc:	89 f0                	mov    %esi,%eax
  800ebe:	03 45 0c             	add    0xc(%ebp),%eax
  800ec1:	50                   	push   %eax
  800ec2:	57                   	push   %edi
  800ec3:	e8 67 09 00 00       	call   80182f <memmove>
		sys_cputs(buf, m);
  800ec8:	83 c4 08             	add    $0x8,%esp
  800ecb:	53                   	push   %ebx
  800ecc:	57                   	push   %edi
  800ecd:	e8 c4 f1 ff ff       	call   800096 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800ed2:	01 de                	add    %ebx,%esi
  800ed4:	83 c4 10             	add    $0x10,%esp
  800ed7:	3b 75 10             	cmp    0x10(%ebp),%esi
  800eda:	72 cd                	jb     800ea9 <devcons_write+0x19>
}
  800edc:	89 f0                	mov    %esi,%eax
  800ede:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee1:	5b                   	pop    %ebx
  800ee2:	5e                   	pop    %esi
  800ee3:	5f                   	pop    %edi
  800ee4:	5d                   	pop    %ebp
  800ee5:	c3                   	ret    

00800ee6 <devcons_read>:
{
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	83 ec 08             	sub    $0x8,%esp
  800eec:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800ef1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ef5:	75 07                	jne    800efe <devcons_read+0x18>
  800ef7:	eb 1f                	jmp    800f18 <devcons_read+0x32>
		sys_yield();
  800ef9:	e8 35 f2 ff ff       	call   800133 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800efe:	e8 b1 f1 ff ff       	call   8000b4 <sys_cgetc>
  800f03:	85 c0                	test   %eax,%eax
  800f05:	74 f2                	je     800ef9 <devcons_read+0x13>
	if (c < 0)
  800f07:	78 0f                	js     800f18 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  800f09:	83 f8 04             	cmp    $0x4,%eax
  800f0c:	74 0c                	je     800f1a <devcons_read+0x34>
	*(char*)vbuf = c;
  800f0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f11:	88 02                	mov    %al,(%edx)
	return 1;
  800f13:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f18:	c9                   	leave  
  800f19:	c3                   	ret    
		return 0;
  800f1a:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1f:	eb f7                	jmp    800f18 <devcons_read+0x32>

00800f21 <cputchar>:
{
  800f21:	55                   	push   %ebp
  800f22:	89 e5                	mov    %esp,%ebp
  800f24:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f27:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2a:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f2d:	6a 01                	push   $0x1
  800f2f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f32:	50                   	push   %eax
  800f33:	e8 5e f1 ff ff       	call   800096 <sys_cputs>
}
  800f38:	83 c4 10             	add    $0x10,%esp
  800f3b:	c9                   	leave  
  800f3c:	c3                   	ret    

00800f3d <getchar>:
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f43:	6a 01                	push   $0x1
  800f45:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f48:	50                   	push   %eax
  800f49:	6a 00                	push   $0x0
  800f4b:	e8 ce f6 ff ff       	call   80061e <read>
	if (r < 0)
  800f50:	83 c4 10             	add    $0x10,%esp
  800f53:	85 c0                	test   %eax,%eax
  800f55:	78 06                	js     800f5d <getchar+0x20>
	if (r < 1)
  800f57:	74 06                	je     800f5f <getchar+0x22>
	return c;
  800f59:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800f5d:	c9                   	leave  
  800f5e:	c3                   	ret    
		return -E_EOF;
  800f5f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800f64:	eb f7                	jmp    800f5d <getchar+0x20>

00800f66 <iscons>:
{
  800f66:	55                   	push   %ebp
  800f67:	89 e5                	mov    %esp,%ebp
  800f69:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f6c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f6f:	50                   	push   %eax
  800f70:	ff 75 08             	push   0x8(%ebp)
  800f73:	e8 42 f4 ff ff       	call   8003ba <fd_lookup>
  800f78:	83 c4 10             	add    $0x10,%esp
  800f7b:	85 c0                	test   %eax,%eax
  800f7d:	78 11                	js     800f90 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800f7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f82:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f88:	39 10                	cmp    %edx,(%eax)
  800f8a:	0f 94 c0             	sete   %al
  800f8d:	0f b6 c0             	movzbl %al,%eax
}
  800f90:	c9                   	leave  
  800f91:	c3                   	ret    

00800f92 <opencons>:
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800f98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9b:	50                   	push   %eax
  800f9c:	e8 c9 f3 ff ff       	call   80036a <fd_alloc>
  800fa1:	83 c4 10             	add    $0x10,%esp
  800fa4:	85 c0                	test   %eax,%eax
  800fa6:	78 3a                	js     800fe2 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fa8:	83 ec 04             	sub    $0x4,%esp
  800fab:	68 07 04 00 00       	push   $0x407
  800fb0:	ff 75 f4             	push   -0xc(%ebp)
  800fb3:	6a 00                	push   $0x0
  800fb5:	e8 98 f1 ff ff       	call   800152 <sys_page_alloc>
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	78 21                	js     800fe2 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800fc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fca:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fcc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fcf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fd6:	83 ec 0c             	sub    $0xc,%esp
  800fd9:	50                   	push   %eax
  800fda:	e8 64 f3 ff ff       	call   800343 <fd2num>
  800fdf:	83 c4 10             	add    $0x10,%esp
}
  800fe2:	c9                   	leave  
  800fe3:	c3                   	ret    

00800fe4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	56                   	push   %esi
  800fe8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fe9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fec:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800ff2:	e8 1d f1 ff ff       	call   800114 <sys_getenvid>
  800ff7:	83 ec 0c             	sub    $0xc,%esp
  800ffa:	ff 75 0c             	push   0xc(%ebp)
  800ffd:	ff 75 08             	push   0x8(%ebp)
  801000:	56                   	push   %esi
  801001:	50                   	push   %eax
  801002:	68 84 1e 80 00       	push   $0x801e84
  801007:	e8 b3 00 00 00       	call   8010bf <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80100c:	83 c4 18             	add    $0x18,%esp
  80100f:	53                   	push   %ebx
  801010:	ff 75 10             	push   0x10(%ebp)
  801013:	e8 56 00 00 00       	call   80106e <vcprintf>
	cprintf("\n");
  801018:	c7 04 24 6f 1e 80 00 	movl   $0x801e6f,(%esp)
  80101f:	e8 9b 00 00 00       	call   8010bf <cprintf>
  801024:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801027:	cc                   	int3   
  801028:	eb fd                	jmp    801027 <_panic+0x43>

0080102a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80102a:	55                   	push   %ebp
  80102b:	89 e5                	mov    %esp,%ebp
  80102d:	53                   	push   %ebx
  80102e:	83 ec 04             	sub    $0x4,%esp
  801031:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801034:	8b 13                	mov    (%ebx),%edx
  801036:	8d 42 01             	lea    0x1(%edx),%eax
  801039:	89 03                	mov    %eax,(%ebx)
  80103b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80103e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801042:	3d ff 00 00 00       	cmp    $0xff,%eax
  801047:	74 09                	je     801052 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801049:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80104d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801050:	c9                   	leave  
  801051:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801052:	83 ec 08             	sub    $0x8,%esp
  801055:	68 ff 00 00 00       	push   $0xff
  80105a:	8d 43 08             	lea    0x8(%ebx),%eax
  80105d:	50                   	push   %eax
  80105e:	e8 33 f0 ff ff       	call   800096 <sys_cputs>
		b->idx = 0;
  801063:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801069:	83 c4 10             	add    $0x10,%esp
  80106c:	eb db                	jmp    801049 <putch+0x1f>

0080106e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801077:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80107e:	00 00 00 
	b.cnt = 0;
  801081:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801088:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80108b:	ff 75 0c             	push   0xc(%ebp)
  80108e:	ff 75 08             	push   0x8(%ebp)
  801091:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801097:	50                   	push   %eax
  801098:	68 2a 10 80 00       	push   $0x80102a
  80109d:	e8 14 01 00 00       	call   8011b6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010a2:	83 c4 08             	add    $0x8,%esp
  8010a5:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8010ab:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010b1:	50                   	push   %eax
  8010b2:	e8 df ef ff ff       	call   800096 <sys_cputs>

	return b.cnt;
}
  8010b7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010bd:	c9                   	leave  
  8010be:	c3                   	ret    

008010bf <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010c5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010c8:	50                   	push   %eax
  8010c9:	ff 75 08             	push   0x8(%ebp)
  8010cc:	e8 9d ff ff ff       	call   80106e <vcprintf>
	va_end(ap);

	return cnt;
}
  8010d1:	c9                   	leave  
  8010d2:	c3                   	ret    

008010d3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	57                   	push   %edi
  8010d7:	56                   	push   %esi
  8010d8:	53                   	push   %ebx
  8010d9:	83 ec 1c             	sub    $0x1c,%esp
  8010dc:	89 c7                	mov    %eax,%edi
  8010de:	89 d6                	mov    %edx,%esi
  8010e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010e6:	89 d1                	mov    %edx,%ecx
  8010e8:	89 c2                	mov    %eax,%edx
  8010ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010ed:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8010f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8010f3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010f9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801100:	39 c2                	cmp    %eax,%edx
  801102:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801105:	72 3e                	jb     801145 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801107:	83 ec 0c             	sub    $0xc,%esp
  80110a:	ff 75 18             	push   0x18(%ebp)
  80110d:	83 eb 01             	sub    $0x1,%ebx
  801110:	53                   	push   %ebx
  801111:	50                   	push   %eax
  801112:	83 ec 08             	sub    $0x8,%esp
  801115:	ff 75 e4             	push   -0x1c(%ebp)
  801118:	ff 75 e0             	push   -0x20(%ebp)
  80111b:	ff 75 dc             	push   -0x24(%ebp)
  80111e:	ff 75 d8             	push   -0x28(%ebp)
  801121:	e8 ea 09 00 00       	call   801b10 <__udivdi3>
  801126:	83 c4 18             	add    $0x18,%esp
  801129:	52                   	push   %edx
  80112a:	50                   	push   %eax
  80112b:	89 f2                	mov    %esi,%edx
  80112d:	89 f8                	mov    %edi,%eax
  80112f:	e8 9f ff ff ff       	call   8010d3 <printnum>
  801134:	83 c4 20             	add    $0x20,%esp
  801137:	eb 13                	jmp    80114c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801139:	83 ec 08             	sub    $0x8,%esp
  80113c:	56                   	push   %esi
  80113d:	ff 75 18             	push   0x18(%ebp)
  801140:	ff d7                	call   *%edi
  801142:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801145:	83 eb 01             	sub    $0x1,%ebx
  801148:	85 db                	test   %ebx,%ebx
  80114a:	7f ed                	jg     801139 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80114c:	83 ec 08             	sub    $0x8,%esp
  80114f:	56                   	push   %esi
  801150:	83 ec 04             	sub    $0x4,%esp
  801153:	ff 75 e4             	push   -0x1c(%ebp)
  801156:	ff 75 e0             	push   -0x20(%ebp)
  801159:	ff 75 dc             	push   -0x24(%ebp)
  80115c:	ff 75 d8             	push   -0x28(%ebp)
  80115f:	e8 cc 0a 00 00       	call   801c30 <__umoddi3>
  801164:	83 c4 14             	add    $0x14,%esp
  801167:	0f be 80 a7 1e 80 00 	movsbl 0x801ea7(%eax),%eax
  80116e:	50                   	push   %eax
  80116f:	ff d7                	call   *%edi
}
  801171:	83 c4 10             	add    $0x10,%esp
  801174:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801177:	5b                   	pop    %ebx
  801178:	5e                   	pop    %esi
  801179:	5f                   	pop    %edi
  80117a:	5d                   	pop    %ebp
  80117b:	c3                   	ret    

0080117c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80117c:	55                   	push   %ebp
  80117d:	89 e5                	mov    %esp,%ebp
  80117f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801182:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801186:	8b 10                	mov    (%eax),%edx
  801188:	3b 50 04             	cmp    0x4(%eax),%edx
  80118b:	73 0a                	jae    801197 <sprintputch+0x1b>
		*b->buf++ = ch;
  80118d:	8d 4a 01             	lea    0x1(%edx),%ecx
  801190:	89 08                	mov    %ecx,(%eax)
  801192:	8b 45 08             	mov    0x8(%ebp),%eax
  801195:	88 02                	mov    %al,(%edx)
}
  801197:	5d                   	pop    %ebp
  801198:	c3                   	ret    

00801199 <printfmt>:
{
  801199:	55                   	push   %ebp
  80119a:	89 e5                	mov    %esp,%ebp
  80119c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80119f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011a2:	50                   	push   %eax
  8011a3:	ff 75 10             	push   0x10(%ebp)
  8011a6:	ff 75 0c             	push   0xc(%ebp)
  8011a9:	ff 75 08             	push   0x8(%ebp)
  8011ac:	e8 05 00 00 00       	call   8011b6 <vprintfmt>
}
  8011b1:	83 c4 10             	add    $0x10,%esp
  8011b4:	c9                   	leave  
  8011b5:	c3                   	ret    

008011b6 <vprintfmt>:
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	57                   	push   %edi
  8011ba:	56                   	push   %esi
  8011bb:	53                   	push   %ebx
  8011bc:	83 ec 3c             	sub    $0x3c,%esp
  8011bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8011c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011c5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011c8:	eb 0a                	jmp    8011d4 <vprintfmt+0x1e>
			putch(ch, putdat);
  8011ca:	83 ec 08             	sub    $0x8,%esp
  8011cd:	53                   	push   %ebx
  8011ce:	50                   	push   %eax
  8011cf:	ff d6                	call   *%esi
  8011d1:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8011d4:	83 c7 01             	add    $0x1,%edi
  8011d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8011db:	83 f8 25             	cmp    $0x25,%eax
  8011de:	74 0c                	je     8011ec <vprintfmt+0x36>
			if (ch == '\0')
  8011e0:	85 c0                	test   %eax,%eax
  8011e2:	75 e6                	jne    8011ca <vprintfmt+0x14>
}
  8011e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e7:	5b                   	pop    %ebx
  8011e8:	5e                   	pop    %esi
  8011e9:	5f                   	pop    %edi
  8011ea:	5d                   	pop    %ebp
  8011eb:	c3                   	ret    
		padc = ' ';
  8011ec:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8011f0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8011f7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8011fe:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801205:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80120a:	8d 47 01             	lea    0x1(%edi),%eax
  80120d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801210:	0f b6 17             	movzbl (%edi),%edx
  801213:	8d 42 dd             	lea    -0x23(%edx),%eax
  801216:	3c 55                	cmp    $0x55,%al
  801218:	0f 87 bb 03 00 00    	ja     8015d9 <vprintfmt+0x423>
  80121e:	0f b6 c0             	movzbl %al,%eax
  801221:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  801228:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80122b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80122f:	eb d9                	jmp    80120a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801231:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801234:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801238:	eb d0                	jmp    80120a <vprintfmt+0x54>
  80123a:	0f b6 d2             	movzbl %dl,%edx
  80123d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801240:	b8 00 00 00 00       	mov    $0x0,%eax
  801245:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801248:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80124b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80124f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801252:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801255:	83 f9 09             	cmp    $0x9,%ecx
  801258:	77 55                	ja     8012af <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80125a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80125d:	eb e9                	jmp    801248 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80125f:	8b 45 14             	mov    0x14(%ebp),%eax
  801262:	8b 00                	mov    (%eax),%eax
  801264:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801267:	8b 45 14             	mov    0x14(%ebp),%eax
  80126a:	8d 40 04             	lea    0x4(%eax),%eax
  80126d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801270:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801273:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801277:	79 91                	jns    80120a <vprintfmt+0x54>
				width = precision, precision = -1;
  801279:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80127c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80127f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801286:	eb 82                	jmp    80120a <vprintfmt+0x54>
  801288:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80128b:	85 d2                	test   %edx,%edx
  80128d:	b8 00 00 00 00       	mov    $0x0,%eax
  801292:	0f 49 c2             	cmovns %edx,%eax
  801295:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801298:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80129b:	e9 6a ff ff ff       	jmp    80120a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8012a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012a3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8012aa:	e9 5b ff ff ff       	jmp    80120a <vprintfmt+0x54>
  8012af:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012b5:	eb bc                	jmp    801273 <vprintfmt+0xbd>
			lflag++;
  8012b7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012bd:	e9 48 ff ff ff       	jmp    80120a <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8012c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c5:	8d 78 04             	lea    0x4(%eax),%edi
  8012c8:	83 ec 08             	sub    $0x8,%esp
  8012cb:	53                   	push   %ebx
  8012cc:	ff 30                	push   (%eax)
  8012ce:	ff d6                	call   *%esi
			break;
  8012d0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8012d3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8012d6:	e9 9d 02 00 00       	jmp    801578 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8012db:	8b 45 14             	mov    0x14(%ebp),%eax
  8012de:	8d 78 04             	lea    0x4(%eax),%edi
  8012e1:	8b 10                	mov    (%eax),%edx
  8012e3:	89 d0                	mov    %edx,%eax
  8012e5:	f7 d8                	neg    %eax
  8012e7:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8012ea:	83 f8 0f             	cmp    $0xf,%eax
  8012ed:	7f 23                	jg     801312 <vprintfmt+0x15c>
  8012ef:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  8012f6:	85 d2                	test   %edx,%edx
  8012f8:	74 18                	je     801312 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8012fa:	52                   	push   %edx
  8012fb:	68 3d 1e 80 00       	push   $0x801e3d
  801300:	53                   	push   %ebx
  801301:	56                   	push   %esi
  801302:	e8 92 fe ff ff       	call   801199 <printfmt>
  801307:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80130a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80130d:	e9 66 02 00 00       	jmp    801578 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  801312:	50                   	push   %eax
  801313:	68 bf 1e 80 00       	push   $0x801ebf
  801318:	53                   	push   %ebx
  801319:	56                   	push   %esi
  80131a:	e8 7a fe ff ff       	call   801199 <printfmt>
  80131f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801322:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801325:	e9 4e 02 00 00       	jmp    801578 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80132a:	8b 45 14             	mov    0x14(%ebp),%eax
  80132d:	83 c0 04             	add    $0x4,%eax
  801330:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801333:	8b 45 14             	mov    0x14(%ebp),%eax
  801336:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801338:	85 d2                	test   %edx,%edx
  80133a:	b8 b8 1e 80 00       	mov    $0x801eb8,%eax
  80133f:	0f 45 c2             	cmovne %edx,%eax
  801342:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801345:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801349:	7e 06                	jle    801351 <vprintfmt+0x19b>
  80134b:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80134f:	75 0d                	jne    80135e <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801351:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801354:	89 c7                	mov    %eax,%edi
  801356:	03 45 e0             	add    -0x20(%ebp),%eax
  801359:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80135c:	eb 55                	jmp    8013b3 <vprintfmt+0x1fd>
  80135e:	83 ec 08             	sub    $0x8,%esp
  801361:	ff 75 d8             	push   -0x28(%ebp)
  801364:	ff 75 cc             	push   -0x34(%ebp)
  801367:	e8 0a 03 00 00       	call   801676 <strnlen>
  80136c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80136f:	29 c1                	sub    %eax,%ecx
  801371:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801374:	83 c4 10             	add    $0x10,%esp
  801377:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  801379:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80137d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801380:	eb 0f                	jmp    801391 <vprintfmt+0x1db>
					putch(padc, putdat);
  801382:	83 ec 08             	sub    $0x8,%esp
  801385:	53                   	push   %ebx
  801386:	ff 75 e0             	push   -0x20(%ebp)
  801389:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80138b:	83 ef 01             	sub    $0x1,%edi
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	85 ff                	test   %edi,%edi
  801393:	7f ed                	jg     801382 <vprintfmt+0x1cc>
  801395:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801398:	85 d2                	test   %edx,%edx
  80139a:	b8 00 00 00 00       	mov    $0x0,%eax
  80139f:	0f 49 c2             	cmovns %edx,%eax
  8013a2:	29 c2                	sub    %eax,%edx
  8013a4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8013a7:	eb a8                	jmp    801351 <vprintfmt+0x19b>
					putch(ch, putdat);
  8013a9:	83 ec 08             	sub    $0x8,%esp
  8013ac:	53                   	push   %ebx
  8013ad:	52                   	push   %edx
  8013ae:	ff d6                	call   *%esi
  8013b0:	83 c4 10             	add    $0x10,%esp
  8013b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013b6:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013b8:	83 c7 01             	add    $0x1,%edi
  8013bb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8013bf:	0f be d0             	movsbl %al,%edx
  8013c2:	85 d2                	test   %edx,%edx
  8013c4:	74 4b                	je     801411 <vprintfmt+0x25b>
  8013c6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013ca:	78 06                	js     8013d2 <vprintfmt+0x21c>
  8013cc:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8013d0:	78 1e                	js     8013f0 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8013d2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8013d6:	74 d1                	je     8013a9 <vprintfmt+0x1f3>
  8013d8:	0f be c0             	movsbl %al,%eax
  8013db:	83 e8 20             	sub    $0x20,%eax
  8013de:	83 f8 5e             	cmp    $0x5e,%eax
  8013e1:	76 c6                	jbe    8013a9 <vprintfmt+0x1f3>
					putch('?', putdat);
  8013e3:	83 ec 08             	sub    $0x8,%esp
  8013e6:	53                   	push   %ebx
  8013e7:	6a 3f                	push   $0x3f
  8013e9:	ff d6                	call   *%esi
  8013eb:	83 c4 10             	add    $0x10,%esp
  8013ee:	eb c3                	jmp    8013b3 <vprintfmt+0x1fd>
  8013f0:	89 cf                	mov    %ecx,%edi
  8013f2:	eb 0e                	jmp    801402 <vprintfmt+0x24c>
				putch(' ', putdat);
  8013f4:	83 ec 08             	sub    $0x8,%esp
  8013f7:	53                   	push   %ebx
  8013f8:	6a 20                	push   $0x20
  8013fa:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8013fc:	83 ef 01             	sub    $0x1,%edi
  8013ff:	83 c4 10             	add    $0x10,%esp
  801402:	85 ff                	test   %edi,%edi
  801404:	7f ee                	jg     8013f4 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  801406:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801409:	89 45 14             	mov    %eax,0x14(%ebp)
  80140c:	e9 67 01 00 00       	jmp    801578 <vprintfmt+0x3c2>
  801411:	89 cf                	mov    %ecx,%edi
  801413:	eb ed                	jmp    801402 <vprintfmt+0x24c>
	if (lflag >= 2)
  801415:	83 f9 01             	cmp    $0x1,%ecx
  801418:	7f 1b                	jg     801435 <vprintfmt+0x27f>
	else if (lflag)
  80141a:	85 c9                	test   %ecx,%ecx
  80141c:	74 63                	je     801481 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80141e:	8b 45 14             	mov    0x14(%ebp),%eax
  801421:	8b 00                	mov    (%eax),%eax
  801423:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801426:	99                   	cltd   
  801427:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80142a:	8b 45 14             	mov    0x14(%ebp),%eax
  80142d:	8d 40 04             	lea    0x4(%eax),%eax
  801430:	89 45 14             	mov    %eax,0x14(%ebp)
  801433:	eb 17                	jmp    80144c <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801435:	8b 45 14             	mov    0x14(%ebp),%eax
  801438:	8b 50 04             	mov    0x4(%eax),%edx
  80143b:	8b 00                	mov    (%eax),%eax
  80143d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801440:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801443:	8b 45 14             	mov    0x14(%ebp),%eax
  801446:	8d 40 08             	lea    0x8(%eax),%eax
  801449:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80144c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80144f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801452:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801457:	85 c9                	test   %ecx,%ecx
  801459:	0f 89 ff 00 00 00    	jns    80155e <vprintfmt+0x3a8>
				putch('-', putdat);
  80145f:	83 ec 08             	sub    $0x8,%esp
  801462:	53                   	push   %ebx
  801463:	6a 2d                	push   $0x2d
  801465:	ff d6                	call   *%esi
				num = -(long long) num;
  801467:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80146a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80146d:	f7 da                	neg    %edx
  80146f:	83 d1 00             	adc    $0x0,%ecx
  801472:	f7 d9                	neg    %ecx
  801474:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801477:	bf 0a 00 00 00       	mov    $0xa,%edi
  80147c:	e9 dd 00 00 00       	jmp    80155e <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801481:	8b 45 14             	mov    0x14(%ebp),%eax
  801484:	8b 00                	mov    (%eax),%eax
  801486:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801489:	99                   	cltd   
  80148a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80148d:	8b 45 14             	mov    0x14(%ebp),%eax
  801490:	8d 40 04             	lea    0x4(%eax),%eax
  801493:	89 45 14             	mov    %eax,0x14(%ebp)
  801496:	eb b4                	jmp    80144c <vprintfmt+0x296>
	if (lflag >= 2)
  801498:	83 f9 01             	cmp    $0x1,%ecx
  80149b:	7f 1e                	jg     8014bb <vprintfmt+0x305>
	else if (lflag)
  80149d:	85 c9                	test   %ecx,%ecx
  80149f:	74 32                	je     8014d3 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8014a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a4:	8b 10                	mov    (%eax),%edx
  8014a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014ab:	8d 40 04             	lea    0x4(%eax),%eax
  8014ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014b1:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8014b6:	e9 a3 00 00 00       	jmp    80155e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8014bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8014be:	8b 10                	mov    (%eax),%edx
  8014c0:	8b 48 04             	mov    0x4(%eax),%ecx
  8014c3:	8d 40 08             	lea    0x8(%eax),%eax
  8014c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014c9:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8014ce:	e9 8b 00 00 00       	jmp    80155e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8014d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d6:	8b 10                	mov    (%eax),%edx
  8014d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014dd:	8d 40 04             	lea    0x4(%eax),%eax
  8014e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014e3:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8014e8:	eb 74                	jmp    80155e <vprintfmt+0x3a8>
	if (lflag >= 2)
  8014ea:	83 f9 01             	cmp    $0x1,%ecx
  8014ed:	7f 1b                	jg     80150a <vprintfmt+0x354>
	else if (lflag)
  8014ef:	85 c9                	test   %ecx,%ecx
  8014f1:	74 2c                	je     80151f <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8014f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f6:	8b 10                	mov    (%eax),%edx
  8014f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014fd:	8d 40 04             	lea    0x4(%eax),%eax
  801500:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801503:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  801508:	eb 54                	jmp    80155e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80150a:	8b 45 14             	mov    0x14(%ebp),%eax
  80150d:	8b 10                	mov    (%eax),%edx
  80150f:	8b 48 04             	mov    0x4(%eax),%ecx
  801512:	8d 40 08             	lea    0x8(%eax),%eax
  801515:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801518:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80151d:	eb 3f                	jmp    80155e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80151f:	8b 45 14             	mov    0x14(%ebp),%eax
  801522:	8b 10                	mov    (%eax),%edx
  801524:	b9 00 00 00 00       	mov    $0x0,%ecx
  801529:	8d 40 04             	lea    0x4(%eax),%eax
  80152c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80152f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801534:	eb 28                	jmp    80155e <vprintfmt+0x3a8>
			putch('0', putdat);
  801536:	83 ec 08             	sub    $0x8,%esp
  801539:	53                   	push   %ebx
  80153a:	6a 30                	push   $0x30
  80153c:	ff d6                	call   *%esi
			putch('x', putdat);
  80153e:	83 c4 08             	add    $0x8,%esp
  801541:	53                   	push   %ebx
  801542:	6a 78                	push   $0x78
  801544:	ff d6                	call   *%esi
			num = (unsigned long long)
  801546:	8b 45 14             	mov    0x14(%ebp),%eax
  801549:	8b 10                	mov    (%eax),%edx
  80154b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801550:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801553:	8d 40 04             	lea    0x4(%eax),%eax
  801556:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801559:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80155e:	83 ec 0c             	sub    $0xc,%esp
  801561:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801565:	50                   	push   %eax
  801566:	ff 75 e0             	push   -0x20(%ebp)
  801569:	57                   	push   %edi
  80156a:	51                   	push   %ecx
  80156b:	52                   	push   %edx
  80156c:	89 da                	mov    %ebx,%edx
  80156e:	89 f0                	mov    %esi,%eax
  801570:	e8 5e fb ff ff       	call   8010d3 <printnum>
			break;
  801575:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801578:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80157b:	e9 54 fc ff ff       	jmp    8011d4 <vprintfmt+0x1e>
	if (lflag >= 2)
  801580:	83 f9 01             	cmp    $0x1,%ecx
  801583:	7f 1b                	jg     8015a0 <vprintfmt+0x3ea>
	else if (lflag)
  801585:	85 c9                	test   %ecx,%ecx
  801587:	74 2c                	je     8015b5 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801589:	8b 45 14             	mov    0x14(%ebp),%eax
  80158c:	8b 10                	mov    (%eax),%edx
  80158e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801593:	8d 40 04             	lea    0x4(%eax),%eax
  801596:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801599:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  80159e:	eb be                	jmp    80155e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8015a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a3:	8b 10                	mov    (%eax),%edx
  8015a5:	8b 48 04             	mov    0x4(%eax),%ecx
  8015a8:	8d 40 08             	lea    0x8(%eax),%eax
  8015ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015ae:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8015b3:	eb a9                	jmp    80155e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8015b5:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b8:	8b 10                	mov    (%eax),%edx
  8015ba:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015bf:	8d 40 04             	lea    0x4(%eax),%eax
  8015c2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015c5:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8015ca:	eb 92                	jmp    80155e <vprintfmt+0x3a8>
			putch(ch, putdat);
  8015cc:	83 ec 08             	sub    $0x8,%esp
  8015cf:	53                   	push   %ebx
  8015d0:	6a 25                	push   $0x25
  8015d2:	ff d6                	call   *%esi
			break;
  8015d4:	83 c4 10             	add    $0x10,%esp
  8015d7:	eb 9f                	jmp    801578 <vprintfmt+0x3c2>
			putch('%', putdat);
  8015d9:	83 ec 08             	sub    $0x8,%esp
  8015dc:	53                   	push   %ebx
  8015dd:	6a 25                	push   $0x25
  8015df:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	89 f8                	mov    %edi,%eax
  8015e6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8015ea:	74 05                	je     8015f1 <vprintfmt+0x43b>
  8015ec:	83 e8 01             	sub    $0x1,%eax
  8015ef:	eb f5                	jmp    8015e6 <vprintfmt+0x430>
  8015f1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015f4:	eb 82                	jmp    801578 <vprintfmt+0x3c2>

008015f6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015f6:	55                   	push   %ebp
  8015f7:	89 e5                	mov    %esp,%ebp
  8015f9:	83 ec 18             	sub    $0x18,%esp
  8015fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ff:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801602:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801605:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801609:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80160c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801613:	85 c0                	test   %eax,%eax
  801615:	74 26                	je     80163d <vsnprintf+0x47>
  801617:	85 d2                	test   %edx,%edx
  801619:	7e 22                	jle    80163d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80161b:	ff 75 14             	push   0x14(%ebp)
  80161e:	ff 75 10             	push   0x10(%ebp)
  801621:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801624:	50                   	push   %eax
  801625:	68 7c 11 80 00       	push   $0x80117c
  80162a:	e8 87 fb ff ff       	call   8011b6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80162f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801632:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801635:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801638:	83 c4 10             	add    $0x10,%esp
}
  80163b:	c9                   	leave  
  80163c:	c3                   	ret    
		return -E_INVAL;
  80163d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801642:	eb f7                	jmp    80163b <vsnprintf+0x45>

00801644 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801644:	55                   	push   %ebp
  801645:	89 e5                	mov    %esp,%ebp
  801647:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80164a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80164d:	50                   	push   %eax
  80164e:	ff 75 10             	push   0x10(%ebp)
  801651:	ff 75 0c             	push   0xc(%ebp)
  801654:	ff 75 08             	push   0x8(%ebp)
  801657:	e8 9a ff ff ff       	call   8015f6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80165c:	c9                   	leave  
  80165d:	c3                   	ret    

0080165e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80165e:	55                   	push   %ebp
  80165f:	89 e5                	mov    %esp,%ebp
  801661:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801664:	b8 00 00 00 00       	mov    $0x0,%eax
  801669:	eb 03                	jmp    80166e <strlen+0x10>
		n++;
  80166b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80166e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801672:	75 f7                	jne    80166b <strlen+0xd>
	return n;
}
  801674:	5d                   	pop    %ebp
  801675:	c3                   	ret    

00801676 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80167c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80167f:	b8 00 00 00 00       	mov    $0x0,%eax
  801684:	eb 03                	jmp    801689 <strnlen+0x13>
		n++;
  801686:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801689:	39 d0                	cmp    %edx,%eax
  80168b:	74 08                	je     801695 <strnlen+0x1f>
  80168d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801691:	75 f3                	jne    801686 <strnlen+0x10>
  801693:	89 c2                	mov    %eax,%edx
	return n;
}
  801695:	89 d0                	mov    %edx,%eax
  801697:	5d                   	pop    %ebp
  801698:	c3                   	ret    

00801699 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	53                   	push   %ebx
  80169d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016ac:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016af:	83 c0 01             	add    $0x1,%eax
  8016b2:	84 d2                	test   %dl,%dl
  8016b4:	75 f2                	jne    8016a8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8016b6:	89 c8                	mov    %ecx,%eax
  8016b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bb:	c9                   	leave  
  8016bc:	c3                   	ret    

008016bd <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	53                   	push   %ebx
  8016c1:	83 ec 10             	sub    $0x10,%esp
  8016c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016c7:	53                   	push   %ebx
  8016c8:	e8 91 ff ff ff       	call   80165e <strlen>
  8016cd:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8016d0:	ff 75 0c             	push   0xc(%ebp)
  8016d3:	01 d8                	add    %ebx,%eax
  8016d5:	50                   	push   %eax
  8016d6:	e8 be ff ff ff       	call   801699 <strcpy>
	return dst;
}
  8016db:	89 d8                	mov    %ebx,%eax
  8016dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e0:	c9                   	leave  
  8016e1:	c3                   	ret    

008016e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016e2:	55                   	push   %ebp
  8016e3:	89 e5                	mov    %esp,%ebp
  8016e5:	56                   	push   %esi
  8016e6:	53                   	push   %ebx
  8016e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ed:	89 f3                	mov    %esi,%ebx
  8016ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016f2:	89 f0                	mov    %esi,%eax
  8016f4:	eb 0f                	jmp    801705 <strncpy+0x23>
		*dst++ = *src;
  8016f6:	83 c0 01             	add    $0x1,%eax
  8016f9:	0f b6 0a             	movzbl (%edx),%ecx
  8016fc:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016ff:	80 f9 01             	cmp    $0x1,%cl
  801702:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801705:	39 d8                	cmp    %ebx,%eax
  801707:	75 ed                	jne    8016f6 <strncpy+0x14>
	}
	return ret;
}
  801709:	89 f0                	mov    %esi,%eax
  80170b:	5b                   	pop    %ebx
  80170c:	5e                   	pop    %esi
  80170d:	5d                   	pop    %ebp
  80170e:	c3                   	ret    

0080170f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	56                   	push   %esi
  801713:	53                   	push   %ebx
  801714:	8b 75 08             	mov    0x8(%ebp),%esi
  801717:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80171a:	8b 55 10             	mov    0x10(%ebp),%edx
  80171d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80171f:	85 d2                	test   %edx,%edx
  801721:	74 21                	je     801744 <strlcpy+0x35>
  801723:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801727:	89 f2                	mov    %esi,%edx
  801729:	eb 09                	jmp    801734 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80172b:	83 c1 01             	add    $0x1,%ecx
  80172e:	83 c2 01             	add    $0x1,%edx
  801731:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801734:	39 c2                	cmp    %eax,%edx
  801736:	74 09                	je     801741 <strlcpy+0x32>
  801738:	0f b6 19             	movzbl (%ecx),%ebx
  80173b:	84 db                	test   %bl,%bl
  80173d:	75 ec                	jne    80172b <strlcpy+0x1c>
  80173f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801741:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801744:	29 f0                	sub    %esi,%eax
}
  801746:	5b                   	pop    %ebx
  801747:	5e                   	pop    %esi
  801748:	5d                   	pop    %ebp
  801749:	c3                   	ret    

0080174a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80174a:	55                   	push   %ebp
  80174b:	89 e5                	mov    %esp,%ebp
  80174d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801750:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801753:	eb 06                	jmp    80175b <strcmp+0x11>
		p++, q++;
  801755:	83 c1 01             	add    $0x1,%ecx
  801758:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80175b:	0f b6 01             	movzbl (%ecx),%eax
  80175e:	84 c0                	test   %al,%al
  801760:	74 04                	je     801766 <strcmp+0x1c>
  801762:	3a 02                	cmp    (%edx),%al
  801764:	74 ef                	je     801755 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801766:	0f b6 c0             	movzbl %al,%eax
  801769:	0f b6 12             	movzbl (%edx),%edx
  80176c:	29 d0                	sub    %edx,%eax
}
  80176e:	5d                   	pop    %ebp
  80176f:	c3                   	ret    

00801770 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801770:	55                   	push   %ebp
  801771:	89 e5                	mov    %esp,%ebp
  801773:	53                   	push   %ebx
  801774:	8b 45 08             	mov    0x8(%ebp),%eax
  801777:	8b 55 0c             	mov    0xc(%ebp),%edx
  80177a:	89 c3                	mov    %eax,%ebx
  80177c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80177f:	eb 06                	jmp    801787 <strncmp+0x17>
		n--, p++, q++;
  801781:	83 c0 01             	add    $0x1,%eax
  801784:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801787:	39 d8                	cmp    %ebx,%eax
  801789:	74 18                	je     8017a3 <strncmp+0x33>
  80178b:	0f b6 08             	movzbl (%eax),%ecx
  80178e:	84 c9                	test   %cl,%cl
  801790:	74 04                	je     801796 <strncmp+0x26>
  801792:	3a 0a                	cmp    (%edx),%cl
  801794:	74 eb                	je     801781 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801796:	0f b6 00             	movzbl (%eax),%eax
  801799:	0f b6 12             	movzbl (%edx),%edx
  80179c:	29 d0                	sub    %edx,%eax
}
  80179e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a1:	c9                   	leave  
  8017a2:	c3                   	ret    
		return 0;
  8017a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a8:	eb f4                	jmp    80179e <strncmp+0x2e>

008017aa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017b4:	eb 03                	jmp    8017b9 <strchr+0xf>
  8017b6:	83 c0 01             	add    $0x1,%eax
  8017b9:	0f b6 10             	movzbl (%eax),%edx
  8017bc:	84 d2                	test   %dl,%dl
  8017be:	74 06                	je     8017c6 <strchr+0x1c>
		if (*s == c)
  8017c0:	38 ca                	cmp    %cl,%dl
  8017c2:	75 f2                	jne    8017b6 <strchr+0xc>
  8017c4:	eb 05                	jmp    8017cb <strchr+0x21>
			return (char *) s;
	return 0;
  8017c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017cb:	5d                   	pop    %ebp
  8017cc:	c3                   	ret    

008017cd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017d7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017da:	38 ca                	cmp    %cl,%dl
  8017dc:	74 09                	je     8017e7 <strfind+0x1a>
  8017de:	84 d2                	test   %dl,%dl
  8017e0:	74 05                	je     8017e7 <strfind+0x1a>
	for (; *s; s++)
  8017e2:	83 c0 01             	add    $0x1,%eax
  8017e5:	eb f0                	jmp    8017d7 <strfind+0xa>
			break;
	return (char *) s;
}
  8017e7:	5d                   	pop    %ebp
  8017e8:	c3                   	ret    

008017e9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	57                   	push   %edi
  8017ed:	56                   	push   %esi
  8017ee:	53                   	push   %ebx
  8017ef:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017f5:	85 c9                	test   %ecx,%ecx
  8017f7:	74 2f                	je     801828 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017f9:	89 f8                	mov    %edi,%eax
  8017fb:	09 c8                	or     %ecx,%eax
  8017fd:	a8 03                	test   $0x3,%al
  8017ff:	75 21                	jne    801822 <memset+0x39>
		c &= 0xFF;
  801801:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801805:	89 d0                	mov    %edx,%eax
  801807:	c1 e0 08             	shl    $0x8,%eax
  80180a:	89 d3                	mov    %edx,%ebx
  80180c:	c1 e3 18             	shl    $0x18,%ebx
  80180f:	89 d6                	mov    %edx,%esi
  801811:	c1 e6 10             	shl    $0x10,%esi
  801814:	09 f3                	or     %esi,%ebx
  801816:	09 da                	or     %ebx,%edx
  801818:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80181a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80181d:	fc                   	cld    
  80181e:	f3 ab                	rep stos %eax,%es:(%edi)
  801820:	eb 06                	jmp    801828 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801822:	8b 45 0c             	mov    0xc(%ebp),%eax
  801825:	fc                   	cld    
  801826:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801828:	89 f8                	mov    %edi,%eax
  80182a:	5b                   	pop    %ebx
  80182b:	5e                   	pop    %esi
  80182c:	5f                   	pop    %edi
  80182d:	5d                   	pop    %ebp
  80182e:	c3                   	ret    

0080182f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80182f:	55                   	push   %ebp
  801830:	89 e5                	mov    %esp,%ebp
  801832:	57                   	push   %edi
  801833:	56                   	push   %esi
  801834:	8b 45 08             	mov    0x8(%ebp),%eax
  801837:	8b 75 0c             	mov    0xc(%ebp),%esi
  80183a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80183d:	39 c6                	cmp    %eax,%esi
  80183f:	73 32                	jae    801873 <memmove+0x44>
  801841:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801844:	39 c2                	cmp    %eax,%edx
  801846:	76 2b                	jbe    801873 <memmove+0x44>
		s += n;
		d += n;
  801848:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80184b:	89 d6                	mov    %edx,%esi
  80184d:	09 fe                	or     %edi,%esi
  80184f:	09 ce                	or     %ecx,%esi
  801851:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801857:	75 0e                	jne    801867 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801859:	83 ef 04             	sub    $0x4,%edi
  80185c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80185f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801862:	fd                   	std    
  801863:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801865:	eb 09                	jmp    801870 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801867:	83 ef 01             	sub    $0x1,%edi
  80186a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80186d:	fd                   	std    
  80186e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801870:	fc                   	cld    
  801871:	eb 1a                	jmp    80188d <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801873:	89 f2                	mov    %esi,%edx
  801875:	09 c2                	or     %eax,%edx
  801877:	09 ca                	or     %ecx,%edx
  801879:	f6 c2 03             	test   $0x3,%dl
  80187c:	75 0a                	jne    801888 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80187e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801881:	89 c7                	mov    %eax,%edi
  801883:	fc                   	cld    
  801884:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801886:	eb 05                	jmp    80188d <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801888:	89 c7                	mov    %eax,%edi
  80188a:	fc                   	cld    
  80188b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80188d:	5e                   	pop    %esi
  80188e:	5f                   	pop    %edi
  80188f:	5d                   	pop    %ebp
  801890:	c3                   	ret    

00801891 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801891:	55                   	push   %ebp
  801892:	89 e5                	mov    %esp,%ebp
  801894:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801897:	ff 75 10             	push   0x10(%ebp)
  80189a:	ff 75 0c             	push   0xc(%ebp)
  80189d:	ff 75 08             	push   0x8(%ebp)
  8018a0:	e8 8a ff ff ff       	call   80182f <memmove>
}
  8018a5:	c9                   	leave  
  8018a6:	c3                   	ret    

008018a7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018a7:	55                   	push   %ebp
  8018a8:	89 e5                	mov    %esp,%ebp
  8018aa:	56                   	push   %esi
  8018ab:	53                   	push   %ebx
  8018ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8018af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018b2:	89 c6                	mov    %eax,%esi
  8018b4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018b7:	eb 06                	jmp    8018bf <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8018b9:	83 c0 01             	add    $0x1,%eax
  8018bc:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8018bf:	39 f0                	cmp    %esi,%eax
  8018c1:	74 14                	je     8018d7 <memcmp+0x30>
		if (*s1 != *s2)
  8018c3:	0f b6 08             	movzbl (%eax),%ecx
  8018c6:	0f b6 1a             	movzbl (%edx),%ebx
  8018c9:	38 d9                	cmp    %bl,%cl
  8018cb:	74 ec                	je     8018b9 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8018cd:	0f b6 c1             	movzbl %cl,%eax
  8018d0:	0f b6 db             	movzbl %bl,%ebx
  8018d3:	29 d8                	sub    %ebx,%eax
  8018d5:	eb 05                	jmp    8018dc <memcmp+0x35>
	}

	return 0;
  8018d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018dc:	5b                   	pop    %ebx
  8018dd:	5e                   	pop    %esi
  8018de:	5d                   	pop    %ebp
  8018df:	c3                   	ret    

008018e0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8018e9:	89 c2                	mov    %eax,%edx
  8018eb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018ee:	eb 03                	jmp    8018f3 <memfind+0x13>
  8018f0:	83 c0 01             	add    $0x1,%eax
  8018f3:	39 d0                	cmp    %edx,%eax
  8018f5:	73 04                	jae    8018fb <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018f7:	38 08                	cmp    %cl,(%eax)
  8018f9:	75 f5                	jne    8018f0 <memfind+0x10>
			break;
	return (void *) s;
}
  8018fb:	5d                   	pop    %ebp
  8018fc:	c3                   	ret    

008018fd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018fd:	55                   	push   %ebp
  8018fe:	89 e5                	mov    %esp,%ebp
  801900:	57                   	push   %edi
  801901:	56                   	push   %esi
  801902:	53                   	push   %ebx
  801903:	8b 55 08             	mov    0x8(%ebp),%edx
  801906:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801909:	eb 03                	jmp    80190e <strtol+0x11>
		s++;
  80190b:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  80190e:	0f b6 02             	movzbl (%edx),%eax
  801911:	3c 20                	cmp    $0x20,%al
  801913:	74 f6                	je     80190b <strtol+0xe>
  801915:	3c 09                	cmp    $0x9,%al
  801917:	74 f2                	je     80190b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801919:	3c 2b                	cmp    $0x2b,%al
  80191b:	74 2a                	je     801947 <strtol+0x4a>
	int neg = 0;
  80191d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801922:	3c 2d                	cmp    $0x2d,%al
  801924:	74 2b                	je     801951 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801926:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80192c:	75 0f                	jne    80193d <strtol+0x40>
  80192e:	80 3a 30             	cmpb   $0x30,(%edx)
  801931:	74 28                	je     80195b <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801933:	85 db                	test   %ebx,%ebx
  801935:	b8 0a 00 00 00       	mov    $0xa,%eax
  80193a:	0f 44 d8             	cmove  %eax,%ebx
  80193d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801942:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801945:	eb 46                	jmp    80198d <strtol+0x90>
		s++;
  801947:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  80194a:	bf 00 00 00 00       	mov    $0x0,%edi
  80194f:	eb d5                	jmp    801926 <strtol+0x29>
		s++, neg = 1;
  801951:	83 c2 01             	add    $0x1,%edx
  801954:	bf 01 00 00 00       	mov    $0x1,%edi
  801959:	eb cb                	jmp    801926 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80195b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80195f:	74 0e                	je     80196f <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801961:	85 db                	test   %ebx,%ebx
  801963:	75 d8                	jne    80193d <strtol+0x40>
		s++, base = 8;
  801965:	83 c2 01             	add    $0x1,%edx
  801968:	bb 08 00 00 00       	mov    $0x8,%ebx
  80196d:	eb ce                	jmp    80193d <strtol+0x40>
		s += 2, base = 16;
  80196f:	83 c2 02             	add    $0x2,%edx
  801972:	bb 10 00 00 00       	mov    $0x10,%ebx
  801977:	eb c4                	jmp    80193d <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801979:	0f be c0             	movsbl %al,%eax
  80197c:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80197f:	3b 45 10             	cmp    0x10(%ebp),%eax
  801982:	7d 3a                	jge    8019be <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801984:	83 c2 01             	add    $0x1,%edx
  801987:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  80198b:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  80198d:	0f b6 02             	movzbl (%edx),%eax
  801990:	8d 70 d0             	lea    -0x30(%eax),%esi
  801993:	89 f3                	mov    %esi,%ebx
  801995:	80 fb 09             	cmp    $0x9,%bl
  801998:	76 df                	jbe    801979 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  80199a:	8d 70 9f             	lea    -0x61(%eax),%esi
  80199d:	89 f3                	mov    %esi,%ebx
  80199f:	80 fb 19             	cmp    $0x19,%bl
  8019a2:	77 08                	ja     8019ac <strtol+0xaf>
			dig = *s - 'a' + 10;
  8019a4:	0f be c0             	movsbl %al,%eax
  8019a7:	83 e8 57             	sub    $0x57,%eax
  8019aa:	eb d3                	jmp    80197f <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8019ac:	8d 70 bf             	lea    -0x41(%eax),%esi
  8019af:	89 f3                	mov    %esi,%ebx
  8019b1:	80 fb 19             	cmp    $0x19,%bl
  8019b4:	77 08                	ja     8019be <strtol+0xc1>
			dig = *s - 'A' + 10;
  8019b6:	0f be c0             	movsbl %al,%eax
  8019b9:	83 e8 37             	sub    $0x37,%eax
  8019bc:	eb c1                	jmp    80197f <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8019be:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019c2:	74 05                	je     8019c9 <strtol+0xcc>
		*endptr = (char *) s;
  8019c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c7:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8019c9:	89 c8                	mov    %ecx,%eax
  8019cb:	f7 d8                	neg    %eax
  8019cd:	85 ff                	test   %edi,%edi
  8019cf:	0f 45 c8             	cmovne %eax,%ecx
}
  8019d2:	89 c8                	mov    %ecx,%eax
  8019d4:	5b                   	pop    %ebx
  8019d5:	5e                   	pop    %esi
  8019d6:	5f                   	pop    %edi
  8019d7:	5d                   	pop    %ebp
  8019d8:	c3                   	ret    

008019d9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019d9:	55                   	push   %ebp
  8019da:	89 e5                	mov    %esp,%ebp
  8019dc:	56                   	push   %esi
  8019dd:	53                   	push   %ebx
  8019de:	8b 75 08             	mov    0x8(%ebp),%esi
  8019e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8019e7:	85 c0                	test   %eax,%eax
  8019e9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019ee:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8019f1:	83 ec 0c             	sub    $0xc,%esp
  8019f4:	50                   	push   %eax
  8019f5:	e8 08 e9 ff ff       	call   800302 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8019fa:	83 c4 10             	add    $0x10,%esp
  8019fd:	85 f6                	test   %esi,%esi
  8019ff:	74 14                	je     801a15 <ipc_recv+0x3c>
  801a01:	ba 00 00 00 00       	mov    $0x0,%edx
  801a06:	85 c0                	test   %eax,%eax
  801a08:	78 09                	js     801a13 <ipc_recv+0x3a>
  801a0a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a10:	8b 52 74             	mov    0x74(%edx),%edx
  801a13:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801a15:	85 db                	test   %ebx,%ebx
  801a17:	74 14                	je     801a2d <ipc_recv+0x54>
  801a19:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	78 09                	js     801a2b <ipc_recv+0x52>
  801a22:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a28:	8b 52 78             	mov    0x78(%edx),%edx
  801a2b:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801a2d:	85 c0                	test   %eax,%eax
  801a2f:	78 08                	js     801a39 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801a31:	a1 00 40 80 00       	mov    0x804000,%eax
  801a36:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a39:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a3c:	5b                   	pop    %ebx
  801a3d:	5e                   	pop    %esi
  801a3e:	5d                   	pop    %ebp
  801a3f:	c3                   	ret    

00801a40 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	57                   	push   %edi
  801a44:	56                   	push   %esi
  801a45:	53                   	push   %ebx
  801a46:	83 ec 0c             	sub    $0xc,%esp
  801a49:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a4f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801a52:	85 db                	test   %ebx,%ebx
  801a54:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a59:	0f 44 d8             	cmove  %eax,%ebx
  801a5c:	eb 05                	jmp    801a63 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a5e:	e8 d0 e6 ff ff       	call   800133 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801a63:	ff 75 14             	push   0x14(%ebp)
  801a66:	53                   	push   %ebx
  801a67:	56                   	push   %esi
  801a68:	57                   	push   %edi
  801a69:	e8 71 e8 ff ff       	call   8002df <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a6e:	83 c4 10             	add    $0x10,%esp
  801a71:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a74:	74 e8                	je     801a5e <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801a76:	85 c0                	test   %eax,%eax
  801a78:	78 08                	js     801a82 <ipc_send+0x42>
	}while (r<0);

}
  801a7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a7d:	5b                   	pop    %ebx
  801a7e:	5e                   	pop    %esi
  801a7f:	5f                   	pop    %edi
  801a80:	5d                   	pop    %ebp
  801a81:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801a82:	50                   	push   %eax
  801a83:	68 9f 21 80 00       	push   $0x80219f
  801a88:	6a 3d                	push   $0x3d
  801a8a:	68 b3 21 80 00       	push   $0x8021b3
  801a8f:	e8 50 f5 ff ff       	call   800fe4 <_panic>

00801a94 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a94:	55                   	push   %ebp
  801a95:	89 e5                	mov    %esp,%ebp
  801a97:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801a9a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801a9f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801aa2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801aa8:	8b 52 50             	mov    0x50(%edx),%edx
  801aab:	39 ca                	cmp    %ecx,%edx
  801aad:	74 11                	je     801ac0 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801aaf:	83 c0 01             	add    $0x1,%eax
  801ab2:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ab7:	75 e6                	jne    801a9f <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801ab9:	b8 00 00 00 00       	mov    $0x0,%eax
  801abe:	eb 0b                	jmp    801acb <ipc_find_env+0x37>
			return envs[i].env_id;
  801ac0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ac3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ac8:	8b 40 48             	mov    0x48(%eax),%eax
}
  801acb:	5d                   	pop    %ebp
  801acc:	c3                   	ret    

00801acd <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ad3:	89 c2                	mov    %eax,%edx
  801ad5:	c1 ea 16             	shr    $0x16,%edx
  801ad8:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801adf:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801ae4:	f6 c1 01             	test   $0x1,%cl
  801ae7:	74 1c                	je     801b05 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801ae9:	c1 e8 0c             	shr    $0xc,%eax
  801aec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801af3:	a8 01                	test   $0x1,%al
  801af5:	74 0e                	je     801b05 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801af7:	c1 e8 0c             	shr    $0xc,%eax
  801afa:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b01:	ef 
  801b02:	0f b7 d2             	movzwl %dx,%edx
}
  801b05:	89 d0                	mov    %edx,%eax
  801b07:	5d                   	pop    %ebp
  801b08:	c3                   	ret    
  801b09:	66 90                	xchg   %ax,%ax
  801b0b:	66 90                	xchg   %ax,%ax
  801b0d:	66 90                	xchg   %ax,%ax
  801b0f:	90                   	nop

00801b10 <__udivdi3>:
  801b10:	f3 0f 1e fb          	endbr32 
  801b14:	55                   	push   %ebp
  801b15:	57                   	push   %edi
  801b16:	56                   	push   %esi
  801b17:	53                   	push   %ebx
  801b18:	83 ec 1c             	sub    $0x1c,%esp
  801b1b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801b1f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b23:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b27:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b2b:	85 c0                	test   %eax,%eax
  801b2d:	75 19                	jne    801b48 <__udivdi3+0x38>
  801b2f:	39 f3                	cmp    %esi,%ebx
  801b31:	76 4d                	jbe    801b80 <__udivdi3+0x70>
  801b33:	31 ff                	xor    %edi,%edi
  801b35:	89 e8                	mov    %ebp,%eax
  801b37:	89 f2                	mov    %esi,%edx
  801b39:	f7 f3                	div    %ebx
  801b3b:	89 fa                	mov    %edi,%edx
  801b3d:	83 c4 1c             	add    $0x1c,%esp
  801b40:	5b                   	pop    %ebx
  801b41:	5e                   	pop    %esi
  801b42:	5f                   	pop    %edi
  801b43:	5d                   	pop    %ebp
  801b44:	c3                   	ret    
  801b45:	8d 76 00             	lea    0x0(%esi),%esi
  801b48:	39 f0                	cmp    %esi,%eax
  801b4a:	76 14                	jbe    801b60 <__udivdi3+0x50>
  801b4c:	31 ff                	xor    %edi,%edi
  801b4e:	31 c0                	xor    %eax,%eax
  801b50:	89 fa                	mov    %edi,%edx
  801b52:	83 c4 1c             	add    $0x1c,%esp
  801b55:	5b                   	pop    %ebx
  801b56:	5e                   	pop    %esi
  801b57:	5f                   	pop    %edi
  801b58:	5d                   	pop    %ebp
  801b59:	c3                   	ret    
  801b5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801b60:	0f bd f8             	bsr    %eax,%edi
  801b63:	83 f7 1f             	xor    $0x1f,%edi
  801b66:	75 48                	jne    801bb0 <__udivdi3+0xa0>
  801b68:	39 f0                	cmp    %esi,%eax
  801b6a:	72 06                	jb     801b72 <__udivdi3+0x62>
  801b6c:	31 c0                	xor    %eax,%eax
  801b6e:	39 eb                	cmp    %ebp,%ebx
  801b70:	77 de                	ja     801b50 <__udivdi3+0x40>
  801b72:	b8 01 00 00 00       	mov    $0x1,%eax
  801b77:	eb d7                	jmp    801b50 <__udivdi3+0x40>
  801b79:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b80:	89 d9                	mov    %ebx,%ecx
  801b82:	85 db                	test   %ebx,%ebx
  801b84:	75 0b                	jne    801b91 <__udivdi3+0x81>
  801b86:	b8 01 00 00 00       	mov    $0x1,%eax
  801b8b:	31 d2                	xor    %edx,%edx
  801b8d:	f7 f3                	div    %ebx
  801b8f:	89 c1                	mov    %eax,%ecx
  801b91:	31 d2                	xor    %edx,%edx
  801b93:	89 f0                	mov    %esi,%eax
  801b95:	f7 f1                	div    %ecx
  801b97:	89 c6                	mov    %eax,%esi
  801b99:	89 e8                	mov    %ebp,%eax
  801b9b:	89 f7                	mov    %esi,%edi
  801b9d:	f7 f1                	div    %ecx
  801b9f:	89 fa                	mov    %edi,%edx
  801ba1:	83 c4 1c             	add    $0x1c,%esp
  801ba4:	5b                   	pop    %ebx
  801ba5:	5e                   	pop    %esi
  801ba6:	5f                   	pop    %edi
  801ba7:	5d                   	pop    %ebp
  801ba8:	c3                   	ret    
  801ba9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bb0:	89 f9                	mov    %edi,%ecx
  801bb2:	ba 20 00 00 00       	mov    $0x20,%edx
  801bb7:	29 fa                	sub    %edi,%edx
  801bb9:	d3 e0                	shl    %cl,%eax
  801bbb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bbf:	89 d1                	mov    %edx,%ecx
  801bc1:	89 d8                	mov    %ebx,%eax
  801bc3:	d3 e8                	shr    %cl,%eax
  801bc5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801bc9:	09 c1                	or     %eax,%ecx
  801bcb:	89 f0                	mov    %esi,%eax
  801bcd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801bd1:	89 f9                	mov    %edi,%ecx
  801bd3:	d3 e3                	shl    %cl,%ebx
  801bd5:	89 d1                	mov    %edx,%ecx
  801bd7:	d3 e8                	shr    %cl,%eax
  801bd9:	89 f9                	mov    %edi,%ecx
  801bdb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801bdf:	89 eb                	mov    %ebp,%ebx
  801be1:	d3 e6                	shl    %cl,%esi
  801be3:	89 d1                	mov    %edx,%ecx
  801be5:	d3 eb                	shr    %cl,%ebx
  801be7:	09 f3                	or     %esi,%ebx
  801be9:	89 c6                	mov    %eax,%esi
  801beb:	89 f2                	mov    %esi,%edx
  801bed:	89 d8                	mov    %ebx,%eax
  801bef:	f7 74 24 08          	divl   0x8(%esp)
  801bf3:	89 d6                	mov    %edx,%esi
  801bf5:	89 c3                	mov    %eax,%ebx
  801bf7:	f7 64 24 0c          	mull   0xc(%esp)
  801bfb:	39 d6                	cmp    %edx,%esi
  801bfd:	72 19                	jb     801c18 <__udivdi3+0x108>
  801bff:	89 f9                	mov    %edi,%ecx
  801c01:	d3 e5                	shl    %cl,%ebp
  801c03:	39 c5                	cmp    %eax,%ebp
  801c05:	73 04                	jae    801c0b <__udivdi3+0xfb>
  801c07:	39 d6                	cmp    %edx,%esi
  801c09:	74 0d                	je     801c18 <__udivdi3+0x108>
  801c0b:	89 d8                	mov    %ebx,%eax
  801c0d:	31 ff                	xor    %edi,%edi
  801c0f:	e9 3c ff ff ff       	jmp    801b50 <__udivdi3+0x40>
  801c14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c18:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c1b:	31 ff                	xor    %edi,%edi
  801c1d:	e9 2e ff ff ff       	jmp    801b50 <__udivdi3+0x40>
  801c22:	66 90                	xchg   %ax,%ax
  801c24:	66 90                	xchg   %ax,%ax
  801c26:	66 90                	xchg   %ax,%ax
  801c28:	66 90                	xchg   %ax,%ax
  801c2a:	66 90                	xchg   %ax,%ax
  801c2c:	66 90                	xchg   %ax,%ax
  801c2e:	66 90                	xchg   %ax,%ax

00801c30 <__umoddi3>:
  801c30:	f3 0f 1e fb          	endbr32 
  801c34:	55                   	push   %ebp
  801c35:	57                   	push   %edi
  801c36:	56                   	push   %esi
  801c37:	53                   	push   %ebx
  801c38:	83 ec 1c             	sub    $0x1c,%esp
  801c3b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801c3f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801c43:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801c47:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801c4b:	89 f0                	mov    %esi,%eax
  801c4d:	89 da                	mov    %ebx,%edx
  801c4f:	85 ff                	test   %edi,%edi
  801c51:	75 15                	jne    801c68 <__umoddi3+0x38>
  801c53:	39 dd                	cmp    %ebx,%ebp
  801c55:	76 39                	jbe    801c90 <__umoddi3+0x60>
  801c57:	f7 f5                	div    %ebp
  801c59:	89 d0                	mov    %edx,%eax
  801c5b:	31 d2                	xor    %edx,%edx
  801c5d:	83 c4 1c             	add    $0x1c,%esp
  801c60:	5b                   	pop    %ebx
  801c61:	5e                   	pop    %esi
  801c62:	5f                   	pop    %edi
  801c63:	5d                   	pop    %ebp
  801c64:	c3                   	ret    
  801c65:	8d 76 00             	lea    0x0(%esi),%esi
  801c68:	39 df                	cmp    %ebx,%edi
  801c6a:	77 f1                	ja     801c5d <__umoddi3+0x2d>
  801c6c:	0f bd cf             	bsr    %edi,%ecx
  801c6f:	83 f1 1f             	xor    $0x1f,%ecx
  801c72:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c76:	75 40                	jne    801cb8 <__umoddi3+0x88>
  801c78:	39 df                	cmp    %ebx,%edi
  801c7a:	72 04                	jb     801c80 <__umoddi3+0x50>
  801c7c:	39 f5                	cmp    %esi,%ebp
  801c7e:	77 dd                	ja     801c5d <__umoddi3+0x2d>
  801c80:	89 da                	mov    %ebx,%edx
  801c82:	89 f0                	mov    %esi,%eax
  801c84:	29 e8                	sub    %ebp,%eax
  801c86:	19 fa                	sbb    %edi,%edx
  801c88:	eb d3                	jmp    801c5d <__umoddi3+0x2d>
  801c8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c90:	89 e9                	mov    %ebp,%ecx
  801c92:	85 ed                	test   %ebp,%ebp
  801c94:	75 0b                	jne    801ca1 <__umoddi3+0x71>
  801c96:	b8 01 00 00 00       	mov    $0x1,%eax
  801c9b:	31 d2                	xor    %edx,%edx
  801c9d:	f7 f5                	div    %ebp
  801c9f:	89 c1                	mov    %eax,%ecx
  801ca1:	89 d8                	mov    %ebx,%eax
  801ca3:	31 d2                	xor    %edx,%edx
  801ca5:	f7 f1                	div    %ecx
  801ca7:	89 f0                	mov    %esi,%eax
  801ca9:	f7 f1                	div    %ecx
  801cab:	89 d0                	mov    %edx,%eax
  801cad:	31 d2                	xor    %edx,%edx
  801caf:	eb ac                	jmp    801c5d <__umoddi3+0x2d>
  801cb1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb8:	8b 44 24 04          	mov    0x4(%esp),%eax
  801cbc:	ba 20 00 00 00       	mov    $0x20,%edx
  801cc1:	29 c2                	sub    %eax,%edx
  801cc3:	89 c1                	mov    %eax,%ecx
  801cc5:	89 e8                	mov    %ebp,%eax
  801cc7:	d3 e7                	shl    %cl,%edi
  801cc9:	89 d1                	mov    %edx,%ecx
  801ccb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801ccf:	d3 e8                	shr    %cl,%eax
  801cd1:	89 c1                	mov    %eax,%ecx
  801cd3:	8b 44 24 04          	mov    0x4(%esp),%eax
  801cd7:	09 f9                	or     %edi,%ecx
  801cd9:	89 df                	mov    %ebx,%edi
  801cdb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cdf:	89 c1                	mov    %eax,%ecx
  801ce1:	d3 e5                	shl    %cl,%ebp
  801ce3:	89 d1                	mov    %edx,%ecx
  801ce5:	d3 ef                	shr    %cl,%edi
  801ce7:	89 c1                	mov    %eax,%ecx
  801ce9:	89 f0                	mov    %esi,%eax
  801ceb:	d3 e3                	shl    %cl,%ebx
  801ced:	89 d1                	mov    %edx,%ecx
  801cef:	89 fa                	mov    %edi,%edx
  801cf1:	d3 e8                	shr    %cl,%eax
  801cf3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801cf8:	09 d8                	or     %ebx,%eax
  801cfa:	f7 74 24 08          	divl   0x8(%esp)
  801cfe:	89 d3                	mov    %edx,%ebx
  801d00:	d3 e6                	shl    %cl,%esi
  801d02:	f7 e5                	mul    %ebp
  801d04:	89 c7                	mov    %eax,%edi
  801d06:	89 d1                	mov    %edx,%ecx
  801d08:	39 d3                	cmp    %edx,%ebx
  801d0a:	72 06                	jb     801d12 <__umoddi3+0xe2>
  801d0c:	75 0e                	jne    801d1c <__umoddi3+0xec>
  801d0e:	39 c6                	cmp    %eax,%esi
  801d10:	73 0a                	jae    801d1c <__umoddi3+0xec>
  801d12:	29 e8                	sub    %ebp,%eax
  801d14:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801d18:	89 d1                	mov    %edx,%ecx
  801d1a:	89 c7                	mov    %eax,%edi
  801d1c:	89 f5                	mov    %esi,%ebp
  801d1e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801d22:	29 fd                	sub    %edi,%ebp
  801d24:	19 cb                	sbb    %ecx,%ebx
  801d26:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d2b:	89 d8                	mov    %ebx,%eax
  801d2d:	d3 e0                	shl    %cl,%eax
  801d2f:	89 f1                	mov    %esi,%ecx
  801d31:	d3 ed                	shr    %cl,%ebp
  801d33:	d3 eb                	shr    %cl,%ebx
  801d35:	09 e8                	or     %ebp,%eax
  801d37:	89 da                	mov    %ebx,%edx
  801d39:	83 c4 1c             	add    $0x1c,%esp
  801d3c:	5b                   	pop    %ebx
  801d3d:	5e                   	pop    %esi
  801d3e:	5f                   	pop    %edi
  801d3f:	5d                   	pop    %ebp
  801d40:	c3                   	ret    
