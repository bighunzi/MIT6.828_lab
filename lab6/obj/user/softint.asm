
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
  800082:	e8 ee 04 00 00       	call   800575 <close_all>
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
  800103:	68 2a 22 80 00       	push   $0x80222a
  800108:	6a 2a                	push   $0x2a
  80010a:	68 47 22 80 00       	push   $0x802247
  80010f:	e8 9e 13 00 00       	call   8014b2 <_panic>

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
  800184:	68 2a 22 80 00       	push   $0x80222a
  800189:	6a 2a                	push   $0x2a
  80018b:	68 47 22 80 00       	push   $0x802247
  800190:	e8 1d 13 00 00       	call   8014b2 <_panic>

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
  8001c6:	68 2a 22 80 00       	push   $0x80222a
  8001cb:	6a 2a                	push   $0x2a
  8001cd:	68 47 22 80 00       	push   $0x802247
  8001d2:	e8 db 12 00 00       	call   8014b2 <_panic>

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
  800208:	68 2a 22 80 00       	push   $0x80222a
  80020d:	6a 2a                	push   $0x2a
  80020f:	68 47 22 80 00       	push   $0x802247
  800214:	e8 99 12 00 00       	call   8014b2 <_panic>

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
  80024a:	68 2a 22 80 00       	push   $0x80222a
  80024f:	6a 2a                	push   $0x2a
  800251:	68 47 22 80 00       	push   $0x802247
  800256:	e8 57 12 00 00       	call   8014b2 <_panic>

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
  80028c:	68 2a 22 80 00       	push   $0x80222a
  800291:	6a 2a                	push   $0x2a
  800293:	68 47 22 80 00       	push   $0x802247
  800298:	e8 15 12 00 00       	call   8014b2 <_panic>

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
  8002ce:	68 2a 22 80 00       	push   $0x80222a
  8002d3:	6a 2a                	push   $0x2a
  8002d5:	68 47 22 80 00       	push   $0x802247
  8002da:	e8 d3 11 00 00       	call   8014b2 <_panic>

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
  800332:	68 2a 22 80 00       	push   $0x80222a
  800337:	6a 2a                	push   $0x2a
  800339:	68 47 22 80 00       	push   $0x802247
  80033e:	e8 6f 11 00 00       	call   8014b2 <_panic>

00800343 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800343:	55                   	push   %ebp
  800344:	89 e5                	mov    %esp,%ebp
  800346:	57                   	push   %edi
  800347:	56                   	push   %esi
  800348:	53                   	push   %ebx
	asm volatile("int %1\n"
  800349:	ba 00 00 00 00       	mov    $0x0,%edx
  80034e:	b8 0e 00 00 00       	mov    $0xe,%eax
  800353:	89 d1                	mov    %edx,%ecx
  800355:	89 d3                	mov    %edx,%ebx
  800357:	89 d7                	mov    %edx,%edi
  800359:	89 d6                	mov    %edx,%esi
  80035b:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80035d:	5b                   	pop    %ebx
  80035e:	5e                   	pop    %esi
  80035f:	5f                   	pop    %edi
  800360:	5d                   	pop    %ebp
  800361:	c3                   	ret    

00800362 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800362:	55                   	push   %ebp
  800363:	89 e5                	mov    %esp,%ebp
  800365:	57                   	push   %edi
  800366:	56                   	push   %esi
  800367:	53                   	push   %ebx
	asm volatile("int %1\n"
  800368:	bb 00 00 00 00       	mov    $0x0,%ebx
  80036d:	8b 55 08             	mov    0x8(%ebp),%edx
  800370:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800373:	b8 0f 00 00 00       	mov    $0xf,%eax
  800378:	89 df                	mov    %ebx,%edi
  80037a:	89 de                	mov    %ebx,%esi
  80037c:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  80037e:	5b                   	pop    %ebx
  80037f:	5e                   	pop    %esi
  800380:	5f                   	pop    %edi
  800381:	5d                   	pop    %ebp
  800382:	c3                   	ret    

00800383 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800383:	55                   	push   %ebp
  800384:	89 e5                	mov    %esp,%ebp
  800386:	57                   	push   %edi
  800387:	56                   	push   %esi
  800388:	53                   	push   %ebx
	asm volatile("int %1\n"
  800389:	bb 00 00 00 00       	mov    $0x0,%ebx
  80038e:	8b 55 08             	mov    0x8(%ebp),%edx
  800391:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800394:	b8 10 00 00 00       	mov    $0x10,%eax
  800399:	89 df                	mov    %ebx,%edi
  80039b:	89 de                	mov    %ebx,%esi
  80039d:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  80039f:	5b                   	pop    %ebx
  8003a0:	5e                   	pop    %esi
  8003a1:	5f                   	pop    %edi
  8003a2:	5d                   	pop    %ebp
  8003a3:	c3                   	ret    

008003a4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003aa:	05 00 00 00 30       	add    $0x30000000,%eax
  8003af:	c1 e8 0c             	shr    $0xc,%eax
}
  8003b2:	5d                   	pop    %ebp
  8003b3:	c3                   	ret    

008003b4 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003b4:	55                   	push   %ebp
  8003b5:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ba:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003bf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003c4:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003c9:	5d                   	pop    %ebp
  8003ca:	c3                   	ret    

008003cb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003cb:	55                   	push   %ebp
  8003cc:	89 e5                	mov    %esp,%ebp
  8003ce:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003d3:	89 c2                	mov    %eax,%edx
  8003d5:	c1 ea 16             	shr    $0x16,%edx
  8003d8:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003df:	f6 c2 01             	test   $0x1,%dl
  8003e2:	74 29                	je     80040d <fd_alloc+0x42>
  8003e4:	89 c2                	mov    %eax,%edx
  8003e6:	c1 ea 0c             	shr    $0xc,%edx
  8003e9:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f0:	f6 c2 01             	test   $0x1,%dl
  8003f3:	74 18                	je     80040d <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8003f5:	05 00 10 00 00       	add    $0x1000,%eax
  8003fa:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003ff:	75 d2                	jne    8003d3 <fd_alloc+0x8>
  800401:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800406:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80040b:	eb 05                	jmp    800412 <fd_alloc+0x47>
			return 0;
  80040d:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800412:	8b 55 08             	mov    0x8(%ebp),%edx
  800415:	89 02                	mov    %eax,(%edx)
}
  800417:	89 c8                	mov    %ecx,%eax
  800419:	5d                   	pop    %ebp
  80041a:	c3                   	ret    

0080041b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800421:	83 f8 1f             	cmp    $0x1f,%eax
  800424:	77 30                	ja     800456 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800426:	c1 e0 0c             	shl    $0xc,%eax
  800429:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80042e:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800434:	f6 c2 01             	test   $0x1,%dl
  800437:	74 24                	je     80045d <fd_lookup+0x42>
  800439:	89 c2                	mov    %eax,%edx
  80043b:	c1 ea 0c             	shr    $0xc,%edx
  80043e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800445:	f6 c2 01             	test   $0x1,%dl
  800448:	74 1a                	je     800464 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80044a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044d:	89 02                	mov    %eax,(%edx)
	return 0;
  80044f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800454:	5d                   	pop    %ebp
  800455:	c3                   	ret    
		return -E_INVAL;
  800456:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80045b:	eb f7                	jmp    800454 <fd_lookup+0x39>
		return -E_INVAL;
  80045d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800462:	eb f0                	jmp    800454 <fd_lookup+0x39>
  800464:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800469:	eb e9                	jmp    800454 <fd_lookup+0x39>

0080046b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80046b:	55                   	push   %ebp
  80046c:	89 e5                	mov    %esp,%ebp
  80046e:	53                   	push   %ebx
  80046f:	83 ec 04             	sub    $0x4,%esp
  800472:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800475:	b8 00 00 00 00       	mov    $0x0,%eax
  80047a:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80047f:	39 13                	cmp    %edx,(%ebx)
  800481:	74 37                	je     8004ba <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800483:	83 c0 01             	add    $0x1,%eax
  800486:	8b 1c 85 d4 22 80 00 	mov    0x8022d4(,%eax,4),%ebx
  80048d:	85 db                	test   %ebx,%ebx
  80048f:	75 ee                	jne    80047f <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800491:	a1 00 40 80 00       	mov    0x804000,%eax
  800496:	8b 40 48             	mov    0x48(%eax),%eax
  800499:	83 ec 04             	sub    $0x4,%esp
  80049c:	52                   	push   %edx
  80049d:	50                   	push   %eax
  80049e:	68 58 22 80 00       	push   $0x802258
  8004a3:	e8 e5 10 00 00       	call   80158d <cprintf>
	*dev = 0;
	return -E_INVAL;
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8004b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004b3:	89 1a                	mov    %ebx,(%edx)
}
  8004b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004b8:	c9                   	leave  
  8004b9:	c3                   	ret    
			return 0;
  8004ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8004bf:	eb ef                	jmp    8004b0 <dev_lookup+0x45>

008004c1 <fd_close>:
{
  8004c1:	55                   	push   %ebp
  8004c2:	89 e5                	mov    %esp,%ebp
  8004c4:	57                   	push   %edi
  8004c5:	56                   	push   %esi
  8004c6:	53                   	push   %ebx
  8004c7:	83 ec 24             	sub    $0x24,%esp
  8004ca:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cd:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004d0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004d3:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004d4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004da:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004dd:	50                   	push   %eax
  8004de:	e8 38 ff ff ff       	call   80041b <fd_lookup>
  8004e3:	89 c3                	mov    %eax,%ebx
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	85 c0                	test   %eax,%eax
  8004ea:	78 05                	js     8004f1 <fd_close+0x30>
	    || fd != fd2)
  8004ec:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004ef:	74 16                	je     800507 <fd_close+0x46>
		return (must_exist ? r : 0);
  8004f1:	89 f8                	mov    %edi,%eax
  8004f3:	84 c0                	test   %al,%al
  8004f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fa:	0f 44 d8             	cmove  %eax,%ebx
}
  8004fd:	89 d8                	mov    %ebx,%eax
  8004ff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800502:	5b                   	pop    %ebx
  800503:	5e                   	pop    %esi
  800504:	5f                   	pop    %edi
  800505:	5d                   	pop    %ebp
  800506:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800507:	83 ec 08             	sub    $0x8,%esp
  80050a:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80050d:	50                   	push   %eax
  80050e:	ff 36                	push   (%esi)
  800510:	e8 56 ff ff ff       	call   80046b <dev_lookup>
  800515:	89 c3                	mov    %eax,%ebx
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	78 1a                	js     800538 <fd_close+0x77>
		if (dev->dev_close)
  80051e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800521:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800524:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800529:	85 c0                	test   %eax,%eax
  80052b:	74 0b                	je     800538 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80052d:	83 ec 0c             	sub    $0xc,%esp
  800530:	56                   	push   %esi
  800531:	ff d0                	call   *%eax
  800533:	89 c3                	mov    %eax,%ebx
  800535:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800538:	83 ec 08             	sub    $0x8,%esp
  80053b:	56                   	push   %esi
  80053c:	6a 00                	push   $0x0
  80053e:	e8 94 fc ff ff       	call   8001d7 <sys_page_unmap>
	return r;
  800543:	83 c4 10             	add    $0x10,%esp
  800546:	eb b5                	jmp    8004fd <fd_close+0x3c>

00800548 <close>:

int
close(int fdnum)
{
  800548:	55                   	push   %ebp
  800549:	89 e5                	mov    %esp,%ebp
  80054b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80054e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800551:	50                   	push   %eax
  800552:	ff 75 08             	push   0x8(%ebp)
  800555:	e8 c1 fe ff ff       	call   80041b <fd_lookup>
  80055a:	83 c4 10             	add    $0x10,%esp
  80055d:	85 c0                	test   %eax,%eax
  80055f:	79 02                	jns    800563 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800561:	c9                   	leave  
  800562:	c3                   	ret    
		return fd_close(fd, 1);
  800563:	83 ec 08             	sub    $0x8,%esp
  800566:	6a 01                	push   $0x1
  800568:	ff 75 f4             	push   -0xc(%ebp)
  80056b:	e8 51 ff ff ff       	call   8004c1 <fd_close>
  800570:	83 c4 10             	add    $0x10,%esp
  800573:	eb ec                	jmp    800561 <close+0x19>

00800575 <close_all>:

void
close_all(void)
{
  800575:	55                   	push   %ebp
  800576:	89 e5                	mov    %esp,%ebp
  800578:	53                   	push   %ebx
  800579:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80057c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800581:	83 ec 0c             	sub    $0xc,%esp
  800584:	53                   	push   %ebx
  800585:	e8 be ff ff ff       	call   800548 <close>
	for (i = 0; i < MAXFD; i++)
  80058a:	83 c3 01             	add    $0x1,%ebx
  80058d:	83 c4 10             	add    $0x10,%esp
  800590:	83 fb 20             	cmp    $0x20,%ebx
  800593:	75 ec                	jne    800581 <close_all+0xc>
}
  800595:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800598:	c9                   	leave  
  800599:	c3                   	ret    

0080059a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80059a:	55                   	push   %ebp
  80059b:	89 e5                	mov    %esp,%ebp
  80059d:	57                   	push   %edi
  80059e:	56                   	push   %esi
  80059f:	53                   	push   %ebx
  8005a0:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005a3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005a6:	50                   	push   %eax
  8005a7:	ff 75 08             	push   0x8(%ebp)
  8005aa:	e8 6c fe ff ff       	call   80041b <fd_lookup>
  8005af:	89 c3                	mov    %eax,%ebx
  8005b1:	83 c4 10             	add    $0x10,%esp
  8005b4:	85 c0                	test   %eax,%eax
  8005b6:	78 7f                	js     800637 <dup+0x9d>
		return r;
	close(newfdnum);
  8005b8:	83 ec 0c             	sub    $0xc,%esp
  8005bb:	ff 75 0c             	push   0xc(%ebp)
  8005be:	e8 85 ff ff ff       	call   800548 <close>

	newfd = INDEX2FD(newfdnum);
  8005c3:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005c6:	c1 e6 0c             	shl    $0xc,%esi
  8005c9:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d2:	89 3c 24             	mov    %edi,(%esp)
  8005d5:	e8 da fd ff ff       	call   8003b4 <fd2data>
  8005da:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005dc:	89 34 24             	mov    %esi,(%esp)
  8005df:	e8 d0 fd ff ff       	call   8003b4 <fd2data>
  8005e4:	83 c4 10             	add    $0x10,%esp
  8005e7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005ea:	89 d8                	mov    %ebx,%eax
  8005ec:	c1 e8 16             	shr    $0x16,%eax
  8005ef:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005f6:	a8 01                	test   $0x1,%al
  8005f8:	74 11                	je     80060b <dup+0x71>
  8005fa:	89 d8                	mov    %ebx,%eax
  8005fc:	c1 e8 0c             	shr    $0xc,%eax
  8005ff:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800606:	f6 c2 01             	test   $0x1,%dl
  800609:	75 36                	jne    800641 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060b:	89 f8                	mov    %edi,%eax
  80060d:	c1 e8 0c             	shr    $0xc,%eax
  800610:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800617:	83 ec 0c             	sub    $0xc,%esp
  80061a:	25 07 0e 00 00       	and    $0xe07,%eax
  80061f:	50                   	push   %eax
  800620:	56                   	push   %esi
  800621:	6a 00                	push   $0x0
  800623:	57                   	push   %edi
  800624:	6a 00                	push   $0x0
  800626:	e8 6a fb ff ff       	call   800195 <sys_page_map>
  80062b:	89 c3                	mov    %eax,%ebx
  80062d:	83 c4 20             	add    $0x20,%esp
  800630:	85 c0                	test   %eax,%eax
  800632:	78 33                	js     800667 <dup+0xcd>
		goto err;

	return newfdnum;
  800634:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800637:	89 d8                	mov    %ebx,%eax
  800639:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063c:	5b                   	pop    %ebx
  80063d:	5e                   	pop    %esi
  80063e:	5f                   	pop    %edi
  80063f:	5d                   	pop    %ebp
  800640:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800641:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800648:	83 ec 0c             	sub    $0xc,%esp
  80064b:	25 07 0e 00 00       	and    $0xe07,%eax
  800650:	50                   	push   %eax
  800651:	ff 75 d4             	push   -0x2c(%ebp)
  800654:	6a 00                	push   $0x0
  800656:	53                   	push   %ebx
  800657:	6a 00                	push   $0x0
  800659:	e8 37 fb ff ff       	call   800195 <sys_page_map>
  80065e:	89 c3                	mov    %eax,%ebx
  800660:	83 c4 20             	add    $0x20,%esp
  800663:	85 c0                	test   %eax,%eax
  800665:	79 a4                	jns    80060b <dup+0x71>
	sys_page_unmap(0, newfd);
  800667:	83 ec 08             	sub    $0x8,%esp
  80066a:	56                   	push   %esi
  80066b:	6a 00                	push   $0x0
  80066d:	e8 65 fb ff ff       	call   8001d7 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800672:	83 c4 08             	add    $0x8,%esp
  800675:	ff 75 d4             	push   -0x2c(%ebp)
  800678:	6a 00                	push   $0x0
  80067a:	e8 58 fb ff ff       	call   8001d7 <sys_page_unmap>
	return r;
  80067f:	83 c4 10             	add    $0x10,%esp
  800682:	eb b3                	jmp    800637 <dup+0x9d>

00800684 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800684:	55                   	push   %ebp
  800685:	89 e5                	mov    %esp,%ebp
  800687:	56                   	push   %esi
  800688:	53                   	push   %ebx
  800689:	83 ec 18             	sub    $0x18,%esp
  80068c:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80068f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800692:	50                   	push   %eax
  800693:	56                   	push   %esi
  800694:	e8 82 fd ff ff       	call   80041b <fd_lookup>
  800699:	83 c4 10             	add    $0x10,%esp
  80069c:	85 c0                	test   %eax,%eax
  80069e:	78 3c                	js     8006dc <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a0:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8006a3:	83 ec 08             	sub    $0x8,%esp
  8006a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006a9:	50                   	push   %eax
  8006aa:	ff 33                	push   (%ebx)
  8006ac:	e8 ba fd ff ff       	call   80046b <dev_lookup>
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	85 c0                	test   %eax,%eax
  8006b6:	78 24                	js     8006dc <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006b8:	8b 43 08             	mov    0x8(%ebx),%eax
  8006bb:	83 e0 03             	and    $0x3,%eax
  8006be:	83 f8 01             	cmp    $0x1,%eax
  8006c1:	74 20                	je     8006e3 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c6:	8b 40 08             	mov    0x8(%eax),%eax
  8006c9:	85 c0                	test   %eax,%eax
  8006cb:	74 37                	je     800704 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006cd:	83 ec 04             	sub    $0x4,%esp
  8006d0:	ff 75 10             	push   0x10(%ebp)
  8006d3:	ff 75 0c             	push   0xc(%ebp)
  8006d6:	53                   	push   %ebx
  8006d7:	ff d0                	call   *%eax
  8006d9:	83 c4 10             	add    $0x10,%esp
}
  8006dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006df:	5b                   	pop    %ebx
  8006e0:	5e                   	pop    %esi
  8006e1:	5d                   	pop    %ebp
  8006e2:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006e3:	a1 00 40 80 00       	mov    0x804000,%eax
  8006e8:	8b 40 48             	mov    0x48(%eax),%eax
  8006eb:	83 ec 04             	sub    $0x4,%esp
  8006ee:	56                   	push   %esi
  8006ef:	50                   	push   %eax
  8006f0:	68 99 22 80 00       	push   $0x802299
  8006f5:	e8 93 0e 00 00       	call   80158d <cprintf>
		return -E_INVAL;
  8006fa:	83 c4 10             	add    $0x10,%esp
  8006fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800702:	eb d8                	jmp    8006dc <read+0x58>
		return -E_NOT_SUPP;
  800704:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800709:	eb d1                	jmp    8006dc <read+0x58>

0080070b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	57                   	push   %edi
  80070f:	56                   	push   %esi
  800710:	53                   	push   %ebx
  800711:	83 ec 0c             	sub    $0xc,%esp
  800714:	8b 7d 08             	mov    0x8(%ebp),%edi
  800717:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80071a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80071f:	eb 02                	jmp    800723 <readn+0x18>
  800721:	01 c3                	add    %eax,%ebx
  800723:	39 f3                	cmp    %esi,%ebx
  800725:	73 21                	jae    800748 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800727:	83 ec 04             	sub    $0x4,%esp
  80072a:	89 f0                	mov    %esi,%eax
  80072c:	29 d8                	sub    %ebx,%eax
  80072e:	50                   	push   %eax
  80072f:	89 d8                	mov    %ebx,%eax
  800731:	03 45 0c             	add    0xc(%ebp),%eax
  800734:	50                   	push   %eax
  800735:	57                   	push   %edi
  800736:	e8 49 ff ff ff       	call   800684 <read>
		if (m < 0)
  80073b:	83 c4 10             	add    $0x10,%esp
  80073e:	85 c0                	test   %eax,%eax
  800740:	78 04                	js     800746 <readn+0x3b>
			return m;
		if (m == 0)
  800742:	75 dd                	jne    800721 <readn+0x16>
  800744:	eb 02                	jmp    800748 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800746:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800748:	89 d8                	mov    %ebx,%eax
  80074a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074d:	5b                   	pop    %ebx
  80074e:	5e                   	pop    %esi
  80074f:	5f                   	pop    %edi
  800750:	5d                   	pop    %ebp
  800751:	c3                   	ret    

00800752 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	56                   	push   %esi
  800756:	53                   	push   %ebx
  800757:	83 ec 18             	sub    $0x18,%esp
  80075a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80075d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800760:	50                   	push   %eax
  800761:	53                   	push   %ebx
  800762:	e8 b4 fc ff ff       	call   80041b <fd_lookup>
  800767:	83 c4 10             	add    $0x10,%esp
  80076a:	85 c0                	test   %eax,%eax
  80076c:	78 37                	js     8007a5 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80076e:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800771:	83 ec 08             	sub    $0x8,%esp
  800774:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800777:	50                   	push   %eax
  800778:	ff 36                	push   (%esi)
  80077a:	e8 ec fc ff ff       	call   80046b <dev_lookup>
  80077f:	83 c4 10             	add    $0x10,%esp
  800782:	85 c0                	test   %eax,%eax
  800784:	78 1f                	js     8007a5 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800786:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80078a:	74 20                	je     8007ac <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80078c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078f:	8b 40 0c             	mov    0xc(%eax),%eax
  800792:	85 c0                	test   %eax,%eax
  800794:	74 37                	je     8007cd <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800796:	83 ec 04             	sub    $0x4,%esp
  800799:	ff 75 10             	push   0x10(%ebp)
  80079c:	ff 75 0c             	push   0xc(%ebp)
  80079f:	56                   	push   %esi
  8007a0:	ff d0                	call   *%eax
  8007a2:	83 c4 10             	add    $0x10,%esp
}
  8007a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007a8:	5b                   	pop    %ebx
  8007a9:	5e                   	pop    %esi
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007ac:	a1 00 40 80 00       	mov    0x804000,%eax
  8007b1:	8b 40 48             	mov    0x48(%eax),%eax
  8007b4:	83 ec 04             	sub    $0x4,%esp
  8007b7:	53                   	push   %ebx
  8007b8:	50                   	push   %eax
  8007b9:	68 b5 22 80 00       	push   $0x8022b5
  8007be:	e8 ca 0d 00 00       	call   80158d <cprintf>
		return -E_INVAL;
  8007c3:	83 c4 10             	add    $0x10,%esp
  8007c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007cb:	eb d8                	jmp    8007a5 <write+0x53>
		return -E_NOT_SUPP;
  8007cd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007d2:	eb d1                	jmp    8007a5 <write+0x53>

008007d4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d4:	55                   	push   %ebp
  8007d5:	89 e5                	mov    %esp,%ebp
  8007d7:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007dd:	50                   	push   %eax
  8007de:	ff 75 08             	push   0x8(%ebp)
  8007e1:	e8 35 fc ff ff       	call   80041b <fd_lookup>
  8007e6:	83 c4 10             	add    $0x10,%esp
  8007e9:	85 c0                	test   %eax,%eax
  8007eb:	78 0e                	js     8007fb <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fb:	c9                   	leave  
  8007fc:	c3                   	ret    

008007fd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007fd:	55                   	push   %ebp
  8007fe:	89 e5                	mov    %esp,%ebp
  800800:	56                   	push   %esi
  800801:	53                   	push   %ebx
  800802:	83 ec 18             	sub    $0x18,%esp
  800805:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800808:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80080b:	50                   	push   %eax
  80080c:	53                   	push   %ebx
  80080d:	e8 09 fc ff ff       	call   80041b <fd_lookup>
  800812:	83 c4 10             	add    $0x10,%esp
  800815:	85 c0                	test   %eax,%eax
  800817:	78 34                	js     80084d <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800819:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80081c:	83 ec 08             	sub    $0x8,%esp
  80081f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800822:	50                   	push   %eax
  800823:	ff 36                	push   (%esi)
  800825:	e8 41 fc ff ff       	call   80046b <dev_lookup>
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	85 c0                	test   %eax,%eax
  80082f:	78 1c                	js     80084d <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800831:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800835:	74 1d                	je     800854 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800837:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083a:	8b 40 18             	mov    0x18(%eax),%eax
  80083d:	85 c0                	test   %eax,%eax
  80083f:	74 34                	je     800875 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800841:	83 ec 08             	sub    $0x8,%esp
  800844:	ff 75 0c             	push   0xc(%ebp)
  800847:	56                   	push   %esi
  800848:	ff d0                	call   *%eax
  80084a:	83 c4 10             	add    $0x10,%esp
}
  80084d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800850:	5b                   	pop    %ebx
  800851:	5e                   	pop    %esi
  800852:	5d                   	pop    %ebp
  800853:	c3                   	ret    
			thisenv->env_id, fdnum);
  800854:	a1 00 40 80 00       	mov    0x804000,%eax
  800859:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80085c:	83 ec 04             	sub    $0x4,%esp
  80085f:	53                   	push   %ebx
  800860:	50                   	push   %eax
  800861:	68 78 22 80 00       	push   $0x802278
  800866:	e8 22 0d 00 00       	call   80158d <cprintf>
		return -E_INVAL;
  80086b:	83 c4 10             	add    $0x10,%esp
  80086e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800873:	eb d8                	jmp    80084d <ftruncate+0x50>
		return -E_NOT_SUPP;
  800875:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80087a:	eb d1                	jmp    80084d <ftruncate+0x50>

0080087c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	56                   	push   %esi
  800880:	53                   	push   %ebx
  800881:	83 ec 18             	sub    $0x18,%esp
  800884:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800887:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80088a:	50                   	push   %eax
  80088b:	ff 75 08             	push   0x8(%ebp)
  80088e:	e8 88 fb ff ff       	call   80041b <fd_lookup>
  800893:	83 c4 10             	add    $0x10,%esp
  800896:	85 c0                	test   %eax,%eax
  800898:	78 49                	js     8008e3 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80089a:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80089d:	83 ec 08             	sub    $0x8,%esp
  8008a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a3:	50                   	push   %eax
  8008a4:	ff 36                	push   (%esi)
  8008a6:	e8 c0 fb ff ff       	call   80046b <dev_lookup>
  8008ab:	83 c4 10             	add    $0x10,%esp
  8008ae:	85 c0                	test   %eax,%eax
  8008b0:	78 31                	js     8008e3 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8008b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008b9:	74 2f                	je     8008ea <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008bb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008be:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008c5:	00 00 00 
	stat->st_isdir = 0;
  8008c8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008cf:	00 00 00 
	stat->st_dev = dev;
  8008d2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008d8:	83 ec 08             	sub    $0x8,%esp
  8008db:	53                   	push   %ebx
  8008dc:	56                   	push   %esi
  8008dd:	ff 50 14             	call   *0x14(%eax)
  8008e0:	83 c4 10             	add    $0x10,%esp
}
  8008e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008e6:	5b                   	pop    %ebx
  8008e7:	5e                   	pop    %esi
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    
		return -E_NOT_SUPP;
  8008ea:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008ef:	eb f2                	jmp    8008e3 <fstat+0x67>

008008f1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	56                   	push   %esi
  8008f5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008f6:	83 ec 08             	sub    $0x8,%esp
  8008f9:	6a 00                	push   $0x0
  8008fb:	ff 75 08             	push   0x8(%ebp)
  8008fe:	e8 e4 01 00 00       	call   800ae7 <open>
  800903:	89 c3                	mov    %eax,%ebx
  800905:	83 c4 10             	add    $0x10,%esp
  800908:	85 c0                	test   %eax,%eax
  80090a:	78 1b                	js     800927 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80090c:	83 ec 08             	sub    $0x8,%esp
  80090f:	ff 75 0c             	push   0xc(%ebp)
  800912:	50                   	push   %eax
  800913:	e8 64 ff ff ff       	call   80087c <fstat>
  800918:	89 c6                	mov    %eax,%esi
	close(fd);
  80091a:	89 1c 24             	mov    %ebx,(%esp)
  80091d:	e8 26 fc ff ff       	call   800548 <close>
	return r;
  800922:	83 c4 10             	add    $0x10,%esp
  800925:	89 f3                	mov    %esi,%ebx
}
  800927:	89 d8                	mov    %ebx,%eax
  800929:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80092c:	5b                   	pop    %ebx
  80092d:	5e                   	pop    %esi
  80092e:	5d                   	pop    %ebp
  80092f:	c3                   	ret    

00800930 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800930:	55                   	push   %ebp
  800931:	89 e5                	mov    %esp,%ebp
  800933:	56                   	push   %esi
  800934:	53                   	push   %ebx
  800935:	89 c6                	mov    %eax,%esi
  800937:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800939:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800940:	74 27                	je     800969 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800942:	6a 07                	push   $0x7
  800944:	68 00 50 80 00       	push   $0x805000
  800949:	56                   	push   %esi
  80094a:	ff 35 00 60 80 00    	push   0x806000
  800950:	e8 b9 15 00 00       	call   801f0e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800955:	83 c4 0c             	add    $0xc,%esp
  800958:	6a 00                	push   $0x0
  80095a:	53                   	push   %ebx
  80095b:	6a 00                	push   $0x0
  80095d:	e8 45 15 00 00       	call   801ea7 <ipc_recv>
}
  800962:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800965:	5b                   	pop    %ebx
  800966:	5e                   	pop    %esi
  800967:	5d                   	pop    %ebp
  800968:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800969:	83 ec 0c             	sub    $0xc,%esp
  80096c:	6a 01                	push   $0x1
  80096e:	e8 ef 15 00 00       	call   801f62 <ipc_find_env>
  800973:	a3 00 60 80 00       	mov    %eax,0x806000
  800978:	83 c4 10             	add    $0x10,%esp
  80097b:	eb c5                	jmp    800942 <fsipc+0x12>

0080097d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80097d:	55                   	push   %ebp
  80097e:	89 e5                	mov    %esp,%ebp
  800980:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800983:	8b 45 08             	mov    0x8(%ebp),%eax
  800986:	8b 40 0c             	mov    0xc(%eax),%eax
  800989:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80098e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800991:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800996:	ba 00 00 00 00       	mov    $0x0,%edx
  80099b:	b8 02 00 00 00       	mov    $0x2,%eax
  8009a0:	e8 8b ff ff ff       	call   800930 <fsipc>
}
  8009a5:	c9                   	leave  
  8009a6:	c3                   	ret    

008009a7 <devfile_flush>:
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bd:	b8 06 00 00 00       	mov    $0x6,%eax
  8009c2:	e8 69 ff ff ff       	call   800930 <fsipc>
}
  8009c7:	c9                   	leave  
  8009c8:	c3                   	ret    

008009c9 <devfile_stat>:
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	53                   	push   %ebx
  8009cd:	83 ec 04             	sub    $0x4,%esp
  8009d0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009de:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e3:	b8 05 00 00 00       	mov    $0x5,%eax
  8009e8:	e8 43 ff ff ff       	call   800930 <fsipc>
  8009ed:	85 c0                	test   %eax,%eax
  8009ef:	78 2c                	js     800a1d <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009f1:	83 ec 08             	sub    $0x8,%esp
  8009f4:	68 00 50 80 00       	push   $0x805000
  8009f9:	53                   	push   %ebx
  8009fa:	e8 68 11 00 00       	call   801b67 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ff:	a1 80 50 80 00       	mov    0x805080,%eax
  800a04:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a0a:	a1 84 50 80 00       	mov    0x805084,%eax
  800a0f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a15:	83 c4 10             	add    $0x10,%esp
  800a18:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a20:	c9                   	leave  
  800a21:	c3                   	ret    

00800a22 <devfile_write>:
{
  800a22:	55                   	push   %ebp
  800a23:	89 e5                	mov    %esp,%ebp
  800a25:	83 ec 0c             	sub    $0xc,%esp
  800a28:	8b 45 10             	mov    0x10(%ebp),%eax
  800a2b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a30:	39 d0                	cmp    %edx,%eax
  800a32:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a35:	8b 55 08             	mov    0x8(%ebp),%edx
  800a38:	8b 52 0c             	mov    0xc(%edx),%edx
  800a3b:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a41:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a46:	50                   	push   %eax
  800a47:	ff 75 0c             	push   0xc(%ebp)
  800a4a:	68 08 50 80 00       	push   $0x805008
  800a4f:	e8 a9 12 00 00       	call   801cfd <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800a54:	ba 00 00 00 00       	mov    $0x0,%edx
  800a59:	b8 04 00 00 00       	mov    $0x4,%eax
  800a5e:	e8 cd fe ff ff       	call   800930 <fsipc>
}
  800a63:	c9                   	leave  
  800a64:	c3                   	ret    

00800a65 <devfile_read>:
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
  800a6a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a6d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a70:	8b 40 0c             	mov    0xc(%eax),%eax
  800a73:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a78:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a7e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a83:	b8 03 00 00 00       	mov    $0x3,%eax
  800a88:	e8 a3 fe ff ff       	call   800930 <fsipc>
  800a8d:	89 c3                	mov    %eax,%ebx
  800a8f:	85 c0                	test   %eax,%eax
  800a91:	78 1f                	js     800ab2 <devfile_read+0x4d>
	assert(r <= n);
  800a93:	39 f0                	cmp    %esi,%eax
  800a95:	77 24                	ja     800abb <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a97:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a9c:	7f 33                	jg     800ad1 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a9e:	83 ec 04             	sub    $0x4,%esp
  800aa1:	50                   	push   %eax
  800aa2:	68 00 50 80 00       	push   $0x805000
  800aa7:	ff 75 0c             	push   0xc(%ebp)
  800aaa:	e8 4e 12 00 00       	call   801cfd <memmove>
	return r;
  800aaf:	83 c4 10             	add    $0x10,%esp
}
  800ab2:	89 d8                	mov    %ebx,%eax
  800ab4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    
	assert(r <= n);
  800abb:	68 e8 22 80 00       	push   $0x8022e8
  800ac0:	68 ef 22 80 00       	push   $0x8022ef
  800ac5:	6a 7c                	push   $0x7c
  800ac7:	68 04 23 80 00       	push   $0x802304
  800acc:	e8 e1 09 00 00       	call   8014b2 <_panic>
	assert(r <= PGSIZE);
  800ad1:	68 0f 23 80 00       	push   $0x80230f
  800ad6:	68 ef 22 80 00       	push   $0x8022ef
  800adb:	6a 7d                	push   $0x7d
  800add:	68 04 23 80 00       	push   $0x802304
  800ae2:	e8 cb 09 00 00       	call   8014b2 <_panic>

00800ae7 <open>:
{
  800ae7:	55                   	push   %ebp
  800ae8:	89 e5                	mov    %esp,%ebp
  800aea:	56                   	push   %esi
  800aeb:	53                   	push   %ebx
  800aec:	83 ec 1c             	sub    $0x1c,%esp
  800aef:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800af2:	56                   	push   %esi
  800af3:	e8 34 10 00 00       	call   801b2c <strlen>
  800af8:	83 c4 10             	add    $0x10,%esp
  800afb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b00:	7f 6c                	jg     800b6e <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800b02:	83 ec 0c             	sub    $0xc,%esp
  800b05:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b08:	50                   	push   %eax
  800b09:	e8 bd f8 ff ff       	call   8003cb <fd_alloc>
  800b0e:	89 c3                	mov    %eax,%ebx
  800b10:	83 c4 10             	add    $0x10,%esp
  800b13:	85 c0                	test   %eax,%eax
  800b15:	78 3c                	js     800b53 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800b17:	83 ec 08             	sub    $0x8,%esp
  800b1a:	56                   	push   %esi
  800b1b:	68 00 50 80 00       	push   $0x805000
  800b20:	e8 42 10 00 00       	call   801b67 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b28:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b30:	b8 01 00 00 00       	mov    $0x1,%eax
  800b35:	e8 f6 fd ff ff       	call   800930 <fsipc>
  800b3a:	89 c3                	mov    %eax,%ebx
  800b3c:	83 c4 10             	add    $0x10,%esp
  800b3f:	85 c0                	test   %eax,%eax
  800b41:	78 19                	js     800b5c <open+0x75>
	return fd2num(fd);
  800b43:	83 ec 0c             	sub    $0xc,%esp
  800b46:	ff 75 f4             	push   -0xc(%ebp)
  800b49:	e8 56 f8 ff ff       	call   8003a4 <fd2num>
  800b4e:	89 c3                	mov    %eax,%ebx
  800b50:	83 c4 10             	add    $0x10,%esp
}
  800b53:	89 d8                	mov    %ebx,%eax
  800b55:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b58:	5b                   	pop    %ebx
  800b59:	5e                   	pop    %esi
  800b5a:	5d                   	pop    %ebp
  800b5b:	c3                   	ret    
		fd_close(fd, 0);
  800b5c:	83 ec 08             	sub    $0x8,%esp
  800b5f:	6a 00                	push   $0x0
  800b61:	ff 75 f4             	push   -0xc(%ebp)
  800b64:	e8 58 f9 ff ff       	call   8004c1 <fd_close>
		return r;
  800b69:	83 c4 10             	add    $0x10,%esp
  800b6c:	eb e5                	jmp    800b53 <open+0x6c>
		return -E_BAD_PATH;
  800b6e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b73:	eb de                	jmp    800b53 <open+0x6c>

00800b75 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800b80:	b8 08 00 00 00       	mov    $0x8,%eax
  800b85:	e8 a6 fd ff ff       	call   800930 <fsipc>
}
  800b8a:	c9                   	leave  
  800b8b:	c3                   	ret    

00800b8c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b8c:	55                   	push   %ebp
  800b8d:	89 e5                	mov    %esp,%ebp
  800b8f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b92:	68 1b 23 80 00       	push   $0x80231b
  800b97:	ff 75 0c             	push   0xc(%ebp)
  800b9a:	e8 c8 0f 00 00       	call   801b67 <strcpy>
	return 0;
}
  800b9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba4:	c9                   	leave  
  800ba5:	c3                   	ret    

00800ba6 <devsock_close>:
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	53                   	push   %ebx
  800baa:	83 ec 10             	sub    $0x10,%esp
  800bad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bb0:	53                   	push   %ebx
  800bb1:	e8 e5 13 00 00       	call   801f9b <pageref>
  800bb6:	89 c2                	mov    %eax,%edx
  800bb8:	83 c4 10             	add    $0x10,%esp
		return 0;
  800bbb:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800bc0:	83 fa 01             	cmp    $0x1,%edx
  800bc3:	74 05                	je     800bca <devsock_close+0x24>
}
  800bc5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc8:	c9                   	leave  
  800bc9:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800bca:	83 ec 0c             	sub    $0xc,%esp
  800bcd:	ff 73 0c             	push   0xc(%ebx)
  800bd0:	e8 b7 02 00 00       	call   800e8c <nsipc_close>
  800bd5:	83 c4 10             	add    $0x10,%esp
  800bd8:	eb eb                	jmp    800bc5 <devsock_close+0x1f>

00800bda <devsock_write>:
{
  800bda:	55                   	push   %ebp
  800bdb:	89 e5                	mov    %esp,%ebp
  800bdd:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800be0:	6a 00                	push   $0x0
  800be2:	ff 75 10             	push   0x10(%ebp)
  800be5:	ff 75 0c             	push   0xc(%ebp)
  800be8:	8b 45 08             	mov    0x8(%ebp),%eax
  800beb:	ff 70 0c             	push   0xc(%eax)
  800bee:	e8 79 03 00 00       	call   800f6c <nsipc_send>
}
  800bf3:	c9                   	leave  
  800bf4:	c3                   	ret    

00800bf5 <devsock_read>:
{
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800bfb:	6a 00                	push   $0x0
  800bfd:	ff 75 10             	push   0x10(%ebp)
  800c00:	ff 75 0c             	push   0xc(%ebp)
  800c03:	8b 45 08             	mov    0x8(%ebp),%eax
  800c06:	ff 70 0c             	push   0xc(%eax)
  800c09:	e8 ef 02 00 00       	call   800efd <nsipc_recv>
}
  800c0e:	c9                   	leave  
  800c0f:	c3                   	ret    

00800c10 <fd2sockid>:
{
  800c10:	55                   	push   %ebp
  800c11:	89 e5                	mov    %esp,%ebp
  800c13:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c16:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c19:	52                   	push   %edx
  800c1a:	50                   	push   %eax
  800c1b:	e8 fb f7 ff ff       	call   80041b <fd_lookup>
  800c20:	83 c4 10             	add    $0x10,%esp
  800c23:	85 c0                	test   %eax,%eax
  800c25:	78 10                	js     800c37 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c2a:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c30:	39 08                	cmp    %ecx,(%eax)
  800c32:	75 05                	jne    800c39 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c34:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c37:	c9                   	leave  
  800c38:	c3                   	ret    
		return -E_NOT_SUPP;
  800c39:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c3e:	eb f7                	jmp    800c37 <fd2sockid+0x27>

00800c40 <alloc_sockfd>:
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	83 ec 1c             	sub    $0x1c,%esp
  800c48:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c4d:	50                   	push   %eax
  800c4e:	e8 78 f7 ff ff       	call   8003cb <fd_alloc>
  800c53:	89 c3                	mov    %eax,%ebx
  800c55:	83 c4 10             	add    $0x10,%esp
  800c58:	85 c0                	test   %eax,%eax
  800c5a:	78 43                	js     800c9f <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c5c:	83 ec 04             	sub    $0x4,%esp
  800c5f:	68 07 04 00 00       	push   $0x407
  800c64:	ff 75 f4             	push   -0xc(%ebp)
  800c67:	6a 00                	push   $0x0
  800c69:	e8 e4 f4 ff ff       	call   800152 <sys_page_alloc>
  800c6e:	89 c3                	mov    %eax,%ebx
  800c70:	83 c4 10             	add    $0x10,%esp
  800c73:	85 c0                	test   %eax,%eax
  800c75:	78 28                	js     800c9f <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c7a:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c80:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c85:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c8c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800c8f:	83 ec 0c             	sub    $0xc,%esp
  800c92:	50                   	push   %eax
  800c93:	e8 0c f7 ff ff       	call   8003a4 <fd2num>
  800c98:	89 c3                	mov    %eax,%ebx
  800c9a:	83 c4 10             	add    $0x10,%esp
  800c9d:	eb 0c                	jmp    800cab <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800c9f:	83 ec 0c             	sub    $0xc,%esp
  800ca2:	56                   	push   %esi
  800ca3:	e8 e4 01 00 00       	call   800e8c <nsipc_close>
		return r;
  800ca8:	83 c4 10             	add    $0x10,%esp
}
  800cab:	89 d8                	mov    %ebx,%eax
  800cad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cb0:	5b                   	pop    %ebx
  800cb1:	5e                   	pop    %esi
  800cb2:	5d                   	pop    %ebp
  800cb3:	c3                   	ret    

00800cb4 <accept>:
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cba:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbd:	e8 4e ff ff ff       	call   800c10 <fd2sockid>
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	78 1b                	js     800ce1 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cc6:	83 ec 04             	sub    $0x4,%esp
  800cc9:	ff 75 10             	push   0x10(%ebp)
  800ccc:	ff 75 0c             	push   0xc(%ebp)
  800ccf:	50                   	push   %eax
  800cd0:	e8 0e 01 00 00       	call   800de3 <nsipc_accept>
  800cd5:	83 c4 10             	add    $0x10,%esp
  800cd8:	85 c0                	test   %eax,%eax
  800cda:	78 05                	js     800ce1 <accept+0x2d>
	return alloc_sockfd(r);
  800cdc:	e8 5f ff ff ff       	call   800c40 <alloc_sockfd>
}
  800ce1:	c9                   	leave  
  800ce2:	c3                   	ret    

00800ce3 <bind>:
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cec:	e8 1f ff ff ff       	call   800c10 <fd2sockid>
  800cf1:	85 c0                	test   %eax,%eax
  800cf3:	78 12                	js     800d07 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  800cf5:	83 ec 04             	sub    $0x4,%esp
  800cf8:	ff 75 10             	push   0x10(%ebp)
  800cfb:	ff 75 0c             	push   0xc(%ebp)
  800cfe:	50                   	push   %eax
  800cff:	e8 31 01 00 00       	call   800e35 <nsipc_bind>
  800d04:	83 c4 10             	add    $0x10,%esp
}
  800d07:	c9                   	leave  
  800d08:	c3                   	ret    

00800d09 <shutdown>:
{
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d12:	e8 f9 fe ff ff       	call   800c10 <fd2sockid>
  800d17:	85 c0                	test   %eax,%eax
  800d19:	78 0f                	js     800d2a <shutdown+0x21>
	return nsipc_shutdown(r, how);
  800d1b:	83 ec 08             	sub    $0x8,%esp
  800d1e:	ff 75 0c             	push   0xc(%ebp)
  800d21:	50                   	push   %eax
  800d22:	e8 43 01 00 00       	call   800e6a <nsipc_shutdown>
  800d27:	83 c4 10             	add    $0x10,%esp
}
  800d2a:	c9                   	leave  
  800d2b:	c3                   	ret    

00800d2c <connect>:
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d32:	8b 45 08             	mov    0x8(%ebp),%eax
  800d35:	e8 d6 fe ff ff       	call   800c10 <fd2sockid>
  800d3a:	85 c0                	test   %eax,%eax
  800d3c:	78 12                	js     800d50 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  800d3e:	83 ec 04             	sub    $0x4,%esp
  800d41:	ff 75 10             	push   0x10(%ebp)
  800d44:	ff 75 0c             	push   0xc(%ebp)
  800d47:	50                   	push   %eax
  800d48:	e8 59 01 00 00       	call   800ea6 <nsipc_connect>
  800d4d:	83 c4 10             	add    $0x10,%esp
}
  800d50:	c9                   	leave  
  800d51:	c3                   	ret    

00800d52 <listen>:
{
  800d52:	55                   	push   %ebp
  800d53:	89 e5                	mov    %esp,%ebp
  800d55:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5b:	e8 b0 fe ff ff       	call   800c10 <fd2sockid>
  800d60:	85 c0                	test   %eax,%eax
  800d62:	78 0f                	js     800d73 <listen+0x21>
	return nsipc_listen(r, backlog);
  800d64:	83 ec 08             	sub    $0x8,%esp
  800d67:	ff 75 0c             	push   0xc(%ebp)
  800d6a:	50                   	push   %eax
  800d6b:	e8 6b 01 00 00       	call   800edb <nsipc_listen>
  800d70:	83 c4 10             	add    $0x10,%esp
}
  800d73:	c9                   	leave  
  800d74:	c3                   	ret    

00800d75 <socket>:

int
socket(int domain, int type, int protocol)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d7b:	ff 75 10             	push   0x10(%ebp)
  800d7e:	ff 75 0c             	push   0xc(%ebp)
  800d81:	ff 75 08             	push   0x8(%ebp)
  800d84:	e8 41 02 00 00       	call   800fca <nsipc_socket>
  800d89:	83 c4 10             	add    $0x10,%esp
  800d8c:	85 c0                	test   %eax,%eax
  800d8e:	78 05                	js     800d95 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800d90:	e8 ab fe ff ff       	call   800c40 <alloc_sockfd>
}
  800d95:	c9                   	leave  
  800d96:	c3                   	ret    

00800d97 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
  800d9a:	53                   	push   %ebx
  800d9b:	83 ec 04             	sub    $0x4,%esp
  800d9e:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800da0:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  800da7:	74 26                	je     800dcf <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800da9:	6a 07                	push   $0x7
  800dab:	68 00 70 80 00       	push   $0x807000
  800db0:	53                   	push   %ebx
  800db1:	ff 35 00 80 80 00    	push   0x808000
  800db7:	e8 52 11 00 00       	call   801f0e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dbc:	83 c4 0c             	add    $0xc,%esp
  800dbf:	6a 00                	push   $0x0
  800dc1:	6a 00                	push   $0x0
  800dc3:	6a 00                	push   $0x0
  800dc5:	e8 dd 10 00 00       	call   801ea7 <ipc_recv>
}
  800dca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dcd:	c9                   	leave  
  800dce:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dcf:	83 ec 0c             	sub    $0xc,%esp
  800dd2:	6a 02                	push   $0x2
  800dd4:	e8 89 11 00 00       	call   801f62 <ipc_find_env>
  800dd9:	a3 00 80 80 00       	mov    %eax,0x808000
  800dde:	83 c4 10             	add    $0x10,%esp
  800de1:	eb c6                	jmp    800da9 <nsipc+0x12>

00800de3 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800de3:	55                   	push   %ebp
  800de4:	89 e5                	mov    %esp,%ebp
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800deb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dee:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800df3:	8b 06                	mov    (%esi),%eax
  800df5:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800dfa:	b8 01 00 00 00       	mov    $0x1,%eax
  800dff:	e8 93 ff ff ff       	call   800d97 <nsipc>
  800e04:	89 c3                	mov    %eax,%ebx
  800e06:	85 c0                	test   %eax,%eax
  800e08:	79 09                	jns    800e13 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800e0a:	89 d8                	mov    %ebx,%eax
  800e0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e0f:	5b                   	pop    %ebx
  800e10:	5e                   	pop    %esi
  800e11:	5d                   	pop    %ebp
  800e12:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e13:	83 ec 04             	sub    $0x4,%esp
  800e16:	ff 35 10 70 80 00    	push   0x807010
  800e1c:	68 00 70 80 00       	push   $0x807000
  800e21:	ff 75 0c             	push   0xc(%ebp)
  800e24:	e8 d4 0e 00 00       	call   801cfd <memmove>
		*addrlen = ret->ret_addrlen;
  800e29:	a1 10 70 80 00       	mov    0x807010,%eax
  800e2e:	89 06                	mov    %eax,(%esi)
  800e30:	83 c4 10             	add    $0x10,%esp
	return r;
  800e33:	eb d5                	jmp    800e0a <nsipc_accept+0x27>

00800e35 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	53                   	push   %ebx
  800e39:	83 ec 08             	sub    $0x8,%esp
  800e3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e42:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e47:	53                   	push   %ebx
  800e48:	ff 75 0c             	push   0xc(%ebp)
  800e4b:	68 04 70 80 00       	push   $0x807004
  800e50:	e8 a8 0e 00 00       	call   801cfd <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e55:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  800e5b:	b8 02 00 00 00       	mov    $0x2,%eax
  800e60:	e8 32 ff ff ff       	call   800d97 <nsipc>
}
  800e65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e68:	c9                   	leave  
  800e69:	c3                   	ret    

00800e6a <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e70:	8b 45 08             	mov    0x8(%ebp),%eax
  800e73:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  800e78:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7b:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  800e80:	b8 03 00 00 00       	mov    $0x3,%eax
  800e85:	e8 0d ff ff ff       	call   800d97 <nsipc>
}
  800e8a:	c9                   	leave  
  800e8b:	c3                   	ret    

00800e8c <nsipc_close>:

int
nsipc_close(int s)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e92:	8b 45 08             	mov    0x8(%ebp),%eax
  800e95:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  800e9a:	b8 04 00 00 00       	mov    $0x4,%eax
  800e9f:	e8 f3 fe ff ff       	call   800d97 <nsipc>
}
  800ea4:	c9                   	leave  
  800ea5:	c3                   	ret    

00800ea6 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ea6:	55                   	push   %ebp
  800ea7:	89 e5                	mov    %esp,%ebp
  800ea9:	53                   	push   %ebx
  800eaa:	83 ec 08             	sub    $0x8,%esp
  800ead:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800eb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb3:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800eb8:	53                   	push   %ebx
  800eb9:	ff 75 0c             	push   0xc(%ebp)
  800ebc:	68 04 70 80 00       	push   $0x807004
  800ec1:	e8 37 0e 00 00       	call   801cfd <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ec6:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  800ecc:	b8 05 00 00 00       	mov    $0x5,%eax
  800ed1:	e8 c1 fe ff ff       	call   800d97 <nsipc>
}
  800ed6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed9:	c9                   	leave  
  800eda:	c3                   	ret    

00800edb <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800edb:	55                   	push   %ebp
  800edc:	89 e5                	mov    %esp,%ebp
  800ede:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ee1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee4:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  800ee9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eec:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  800ef1:	b8 06 00 00 00       	mov    $0x6,%eax
  800ef6:	e8 9c fe ff ff       	call   800d97 <nsipc>
}
  800efb:	c9                   	leave  
  800efc:	c3                   	ret    

00800efd <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	56                   	push   %esi
  800f01:	53                   	push   %ebx
  800f02:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f05:	8b 45 08             	mov    0x8(%ebp),%eax
  800f08:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  800f0d:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  800f13:	8b 45 14             	mov    0x14(%ebp),%eax
  800f16:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f1b:	b8 07 00 00 00       	mov    $0x7,%eax
  800f20:	e8 72 fe ff ff       	call   800d97 <nsipc>
  800f25:	89 c3                	mov    %eax,%ebx
  800f27:	85 c0                	test   %eax,%eax
  800f29:	78 22                	js     800f4d <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  800f2b:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f30:	39 c6                	cmp    %eax,%esi
  800f32:	0f 4e c6             	cmovle %esi,%eax
  800f35:	39 c3                	cmp    %eax,%ebx
  800f37:	7f 1d                	jg     800f56 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f39:	83 ec 04             	sub    $0x4,%esp
  800f3c:	53                   	push   %ebx
  800f3d:	68 00 70 80 00       	push   $0x807000
  800f42:	ff 75 0c             	push   0xc(%ebp)
  800f45:	e8 b3 0d 00 00       	call   801cfd <memmove>
  800f4a:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f4d:	89 d8                	mov    %ebx,%eax
  800f4f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f52:	5b                   	pop    %ebx
  800f53:	5e                   	pop    %esi
  800f54:	5d                   	pop    %ebp
  800f55:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f56:	68 27 23 80 00       	push   $0x802327
  800f5b:	68 ef 22 80 00       	push   $0x8022ef
  800f60:	6a 62                	push   $0x62
  800f62:	68 3c 23 80 00       	push   $0x80233c
  800f67:	e8 46 05 00 00       	call   8014b2 <_panic>

00800f6c <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	53                   	push   %ebx
  800f70:	83 ec 04             	sub    $0x4,%esp
  800f73:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f76:	8b 45 08             	mov    0x8(%ebp),%eax
  800f79:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  800f7e:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f84:	7f 2e                	jg     800fb4 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f86:	83 ec 04             	sub    $0x4,%esp
  800f89:	53                   	push   %ebx
  800f8a:	ff 75 0c             	push   0xc(%ebp)
  800f8d:	68 0c 70 80 00       	push   $0x80700c
  800f92:	e8 66 0d 00 00       	call   801cfd <memmove>
	nsipcbuf.send.req_size = size;
  800f97:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  800f9d:	8b 45 14             	mov    0x14(%ebp),%eax
  800fa0:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  800fa5:	b8 08 00 00 00       	mov    $0x8,%eax
  800faa:	e8 e8 fd ff ff       	call   800d97 <nsipc>
}
  800faf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb2:	c9                   	leave  
  800fb3:	c3                   	ret    
	assert(size < 1600);
  800fb4:	68 48 23 80 00       	push   $0x802348
  800fb9:	68 ef 22 80 00       	push   $0x8022ef
  800fbe:	6a 6d                	push   $0x6d
  800fc0:	68 3c 23 80 00       	push   $0x80233c
  800fc5:	e8 e8 04 00 00       	call   8014b2 <_panic>

00800fca <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fca:	55                   	push   %ebp
  800fcb:	89 e5                	mov    %esp,%ebp
  800fcd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd3:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  800fd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdb:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  800fe0:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe3:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  800fe8:	b8 09 00 00 00       	mov    $0x9,%eax
  800fed:	e8 a5 fd ff ff       	call   800d97 <nsipc>
}
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	56                   	push   %esi
  800ff8:	53                   	push   %ebx
  800ff9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ffc:	83 ec 0c             	sub    $0xc,%esp
  800fff:	ff 75 08             	push   0x8(%ebp)
  801002:	e8 ad f3 ff ff       	call   8003b4 <fd2data>
  801007:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801009:	83 c4 08             	add    $0x8,%esp
  80100c:	68 54 23 80 00       	push   $0x802354
  801011:	53                   	push   %ebx
  801012:	e8 50 0b 00 00       	call   801b67 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801017:	8b 46 04             	mov    0x4(%esi),%eax
  80101a:	2b 06                	sub    (%esi),%eax
  80101c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801022:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801029:	00 00 00 
	stat->st_dev = &devpipe;
  80102c:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801033:	30 80 00 
	return 0;
}
  801036:	b8 00 00 00 00       	mov    $0x0,%eax
  80103b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80103e:	5b                   	pop    %ebx
  80103f:	5e                   	pop    %esi
  801040:	5d                   	pop    %ebp
  801041:	c3                   	ret    

00801042 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	53                   	push   %ebx
  801046:	83 ec 0c             	sub    $0xc,%esp
  801049:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80104c:	53                   	push   %ebx
  80104d:	6a 00                	push   $0x0
  80104f:	e8 83 f1 ff ff       	call   8001d7 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801054:	89 1c 24             	mov    %ebx,(%esp)
  801057:	e8 58 f3 ff ff       	call   8003b4 <fd2data>
  80105c:	83 c4 08             	add    $0x8,%esp
  80105f:	50                   	push   %eax
  801060:	6a 00                	push   $0x0
  801062:	e8 70 f1 ff ff       	call   8001d7 <sys_page_unmap>
}
  801067:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106a:	c9                   	leave  
  80106b:	c3                   	ret    

0080106c <_pipeisclosed>:
{
  80106c:	55                   	push   %ebp
  80106d:	89 e5                	mov    %esp,%ebp
  80106f:	57                   	push   %edi
  801070:	56                   	push   %esi
  801071:	53                   	push   %ebx
  801072:	83 ec 1c             	sub    $0x1c,%esp
  801075:	89 c7                	mov    %eax,%edi
  801077:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801079:	a1 00 40 80 00       	mov    0x804000,%eax
  80107e:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801081:	83 ec 0c             	sub    $0xc,%esp
  801084:	57                   	push   %edi
  801085:	e8 11 0f 00 00       	call   801f9b <pageref>
  80108a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80108d:	89 34 24             	mov    %esi,(%esp)
  801090:	e8 06 0f 00 00       	call   801f9b <pageref>
		nn = thisenv->env_runs;
  801095:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80109b:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80109e:	83 c4 10             	add    $0x10,%esp
  8010a1:	39 cb                	cmp    %ecx,%ebx
  8010a3:	74 1b                	je     8010c0 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010a5:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010a8:	75 cf                	jne    801079 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010aa:	8b 42 58             	mov    0x58(%edx),%eax
  8010ad:	6a 01                	push   $0x1
  8010af:	50                   	push   %eax
  8010b0:	53                   	push   %ebx
  8010b1:	68 5b 23 80 00       	push   $0x80235b
  8010b6:	e8 d2 04 00 00       	call   80158d <cprintf>
  8010bb:	83 c4 10             	add    $0x10,%esp
  8010be:	eb b9                	jmp    801079 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010c0:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010c3:	0f 94 c0             	sete   %al
  8010c6:	0f b6 c0             	movzbl %al,%eax
}
  8010c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cc:	5b                   	pop    %ebx
  8010cd:	5e                   	pop    %esi
  8010ce:	5f                   	pop    %edi
  8010cf:	5d                   	pop    %ebp
  8010d0:	c3                   	ret    

008010d1 <devpipe_write>:
{
  8010d1:	55                   	push   %ebp
  8010d2:	89 e5                	mov    %esp,%ebp
  8010d4:	57                   	push   %edi
  8010d5:	56                   	push   %esi
  8010d6:	53                   	push   %ebx
  8010d7:	83 ec 28             	sub    $0x28,%esp
  8010da:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8010dd:	56                   	push   %esi
  8010de:	e8 d1 f2 ff ff       	call   8003b4 <fd2data>
  8010e3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8010e5:	83 c4 10             	add    $0x10,%esp
  8010e8:	bf 00 00 00 00       	mov    $0x0,%edi
  8010ed:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8010f0:	75 09                	jne    8010fb <devpipe_write+0x2a>
	return i;
  8010f2:	89 f8                	mov    %edi,%eax
  8010f4:	eb 23                	jmp    801119 <devpipe_write+0x48>
			sys_yield();
  8010f6:	e8 38 f0 ff ff       	call   800133 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8010fb:	8b 43 04             	mov    0x4(%ebx),%eax
  8010fe:	8b 0b                	mov    (%ebx),%ecx
  801100:	8d 51 20             	lea    0x20(%ecx),%edx
  801103:	39 d0                	cmp    %edx,%eax
  801105:	72 1a                	jb     801121 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801107:	89 da                	mov    %ebx,%edx
  801109:	89 f0                	mov    %esi,%eax
  80110b:	e8 5c ff ff ff       	call   80106c <_pipeisclosed>
  801110:	85 c0                	test   %eax,%eax
  801112:	74 e2                	je     8010f6 <devpipe_write+0x25>
				return 0;
  801114:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801119:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111c:	5b                   	pop    %ebx
  80111d:	5e                   	pop    %esi
  80111e:	5f                   	pop    %edi
  80111f:	5d                   	pop    %ebp
  801120:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801121:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801124:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801128:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80112b:	89 c2                	mov    %eax,%edx
  80112d:	c1 fa 1f             	sar    $0x1f,%edx
  801130:	89 d1                	mov    %edx,%ecx
  801132:	c1 e9 1b             	shr    $0x1b,%ecx
  801135:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801138:	83 e2 1f             	and    $0x1f,%edx
  80113b:	29 ca                	sub    %ecx,%edx
  80113d:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801141:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801145:	83 c0 01             	add    $0x1,%eax
  801148:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80114b:	83 c7 01             	add    $0x1,%edi
  80114e:	eb 9d                	jmp    8010ed <devpipe_write+0x1c>

00801150 <devpipe_read>:
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	57                   	push   %edi
  801154:	56                   	push   %esi
  801155:	53                   	push   %ebx
  801156:	83 ec 18             	sub    $0x18,%esp
  801159:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80115c:	57                   	push   %edi
  80115d:	e8 52 f2 ff ff       	call   8003b4 <fd2data>
  801162:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801164:	83 c4 10             	add    $0x10,%esp
  801167:	be 00 00 00 00       	mov    $0x0,%esi
  80116c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80116f:	75 13                	jne    801184 <devpipe_read+0x34>
	return i;
  801171:	89 f0                	mov    %esi,%eax
  801173:	eb 02                	jmp    801177 <devpipe_read+0x27>
				return i;
  801175:	89 f0                	mov    %esi,%eax
}
  801177:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117a:	5b                   	pop    %ebx
  80117b:	5e                   	pop    %esi
  80117c:	5f                   	pop    %edi
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    
			sys_yield();
  80117f:	e8 af ef ff ff       	call   800133 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801184:	8b 03                	mov    (%ebx),%eax
  801186:	3b 43 04             	cmp    0x4(%ebx),%eax
  801189:	75 18                	jne    8011a3 <devpipe_read+0x53>
			if (i > 0)
  80118b:	85 f6                	test   %esi,%esi
  80118d:	75 e6                	jne    801175 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  80118f:	89 da                	mov    %ebx,%edx
  801191:	89 f8                	mov    %edi,%eax
  801193:	e8 d4 fe ff ff       	call   80106c <_pipeisclosed>
  801198:	85 c0                	test   %eax,%eax
  80119a:	74 e3                	je     80117f <devpipe_read+0x2f>
				return 0;
  80119c:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a1:	eb d4                	jmp    801177 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011a3:	99                   	cltd   
  8011a4:	c1 ea 1b             	shr    $0x1b,%edx
  8011a7:	01 d0                	add    %edx,%eax
  8011a9:	83 e0 1f             	and    $0x1f,%eax
  8011ac:	29 d0                	sub    %edx,%eax
  8011ae:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011b9:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011bc:	83 c6 01             	add    $0x1,%esi
  8011bf:	eb ab                	jmp    80116c <devpipe_read+0x1c>

008011c1 <pipe>:
{
  8011c1:	55                   	push   %ebp
  8011c2:	89 e5                	mov    %esp,%ebp
  8011c4:	56                   	push   %esi
  8011c5:	53                   	push   %ebx
  8011c6:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cc:	50                   	push   %eax
  8011cd:	e8 f9 f1 ff ff       	call   8003cb <fd_alloc>
  8011d2:	89 c3                	mov    %eax,%ebx
  8011d4:	83 c4 10             	add    $0x10,%esp
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	0f 88 23 01 00 00    	js     801302 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011df:	83 ec 04             	sub    $0x4,%esp
  8011e2:	68 07 04 00 00       	push   $0x407
  8011e7:	ff 75 f4             	push   -0xc(%ebp)
  8011ea:	6a 00                	push   $0x0
  8011ec:	e8 61 ef ff ff       	call   800152 <sys_page_alloc>
  8011f1:	89 c3                	mov    %eax,%ebx
  8011f3:	83 c4 10             	add    $0x10,%esp
  8011f6:	85 c0                	test   %eax,%eax
  8011f8:	0f 88 04 01 00 00    	js     801302 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  8011fe:	83 ec 0c             	sub    $0xc,%esp
  801201:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801204:	50                   	push   %eax
  801205:	e8 c1 f1 ff ff       	call   8003cb <fd_alloc>
  80120a:	89 c3                	mov    %eax,%ebx
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	85 c0                	test   %eax,%eax
  801211:	0f 88 db 00 00 00    	js     8012f2 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801217:	83 ec 04             	sub    $0x4,%esp
  80121a:	68 07 04 00 00       	push   $0x407
  80121f:	ff 75 f0             	push   -0x10(%ebp)
  801222:	6a 00                	push   $0x0
  801224:	e8 29 ef ff ff       	call   800152 <sys_page_alloc>
  801229:	89 c3                	mov    %eax,%ebx
  80122b:	83 c4 10             	add    $0x10,%esp
  80122e:	85 c0                	test   %eax,%eax
  801230:	0f 88 bc 00 00 00    	js     8012f2 <pipe+0x131>
	va = fd2data(fd0);
  801236:	83 ec 0c             	sub    $0xc,%esp
  801239:	ff 75 f4             	push   -0xc(%ebp)
  80123c:	e8 73 f1 ff ff       	call   8003b4 <fd2data>
  801241:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801243:	83 c4 0c             	add    $0xc,%esp
  801246:	68 07 04 00 00       	push   $0x407
  80124b:	50                   	push   %eax
  80124c:	6a 00                	push   $0x0
  80124e:	e8 ff ee ff ff       	call   800152 <sys_page_alloc>
  801253:	89 c3                	mov    %eax,%ebx
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	85 c0                	test   %eax,%eax
  80125a:	0f 88 82 00 00 00    	js     8012e2 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801260:	83 ec 0c             	sub    $0xc,%esp
  801263:	ff 75 f0             	push   -0x10(%ebp)
  801266:	e8 49 f1 ff ff       	call   8003b4 <fd2data>
  80126b:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801272:	50                   	push   %eax
  801273:	6a 00                	push   $0x0
  801275:	56                   	push   %esi
  801276:	6a 00                	push   $0x0
  801278:	e8 18 ef ff ff       	call   800195 <sys_page_map>
  80127d:	89 c3                	mov    %eax,%ebx
  80127f:	83 c4 20             	add    $0x20,%esp
  801282:	85 c0                	test   %eax,%eax
  801284:	78 4e                	js     8012d4 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801286:	a1 3c 30 80 00       	mov    0x80303c,%eax
  80128b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80128e:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801290:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801293:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80129a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80129d:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80129f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a2:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012a9:	83 ec 0c             	sub    $0xc,%esp
  8012ac:	ff 75 f4             	push   -0xc(%ebp)
  8012af:	e8 f0 f0 ff ff       	call   8003a4 <fd2num>
  8012b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b7:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012b9:	83 c4 04             	add    $0x4,%esp
  8012bc:	ff 75 f0             	push   -0x10(%ebp)
  8012bf:	e8 e0 f0 ff ff       	call   8003a4 <fd2num>
  8012c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c7:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012ca:	83 c4 10             	add    $0x10,%esp
  8012cd:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012d2:	eb 2e                	jmp    801302 <pipe+0x141>
	sys_page_unmap(0, va);
  8012d4:	83 ec 08             	sub    $0x8,%esp
  8012d7:	56                   	push   %esi
  8012d8:	6a 00                	push   $0x0
  8012da:	e8 f8 ee ff ff       	call   8001d7 <sys_page_unmap>
  8012df:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8012e2:	83 ec 08             	sub    $0x8,%esp
  8012e5:	ff 75 f0             	push   -0x10(%ebp)
  8012e8:	6a 00                	push   $0x0
  8012ea:	e8 e8 ee ff ff       	call   8001d7 <sys_page_unmap>
  8012ef:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8012f2:	83 ec 08             	sub    $0x8,%esp
  8012f5:	ff 75 f4             	push   -0xc(%ebp)
  8012f8:	6a 00                	push   $0x0
  8012fa:	e8 d8 ee ff ff       	call   8001d7 <sys_page_unmap>
  8012ff:	83 c4 10             	add    $0x10,%esp
}
  801302:	89 d8                	mov    %ebx,%eax
  801304:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801307:	5b                   	pop    %ebx
  801308:	5e                   	pop    %esi
  801309:	5d                   	pop    %ebp
  80130a:	c3                   	ret    

0080130b <pipeisclosed>:
{
  80130b:	55                   	push   %ebp
  80130c:	89 e5                	mov    %esp,%ebp
  80130e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801311:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801314:	50                   	push   %eax
  801315:	ff 75 08             	push   0x8(%ebp)
  801318:	e8 fe f0 ff ff       	call   80041b <fd_lookup>
  80131d:	83 c4 10             	add    $0x10,%esp
  801320:	85 c0                	test   %eax,%eax
  801322:	78 18                	js     80133c <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801324:	83 ec 0c             	sub    $0xc,%esp
  801327:	ff 75 f4             	push   -0xc(%ebp)
  80132a:	e8 85 f0 ff ff       	call   8003b4 <fd2data>
  80132f:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801331:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801334:	e8 33 fd ff ff       	call   80106c <_pipeisclosed>
  801339:	83 c4 10             	add    $0x10,%esp
}
  80133c:	c9                   	leave  
  80133d:	c3                   	ret    

0080133e <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80133e:	b8 00 00 00 00       	mov    $0x0,%eax
  801343:	c3                   	ret    

00801344 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801344:	55                   	push   %ebp
  801345:	89 e5                	mov    %esp,%ebp
  801347:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80134a:	68 73 23 80 00       	push   $0x802373
  80134f:	ff 75 0c             	push   0xc(%ebp)
  801352:	e8 10 08 00 00       	call   801b67 <strcpy>
	return 0;
}
  801357:	b8 00 00 00 00       	mov    $0x0,%eax
  80135c:	c9                   	leave  
  80135d:	c3                   	ret    

0080135e <devcons_write>:
{
  80135e:	55                   	push   %ebp
  80135f:	89 e5                	mov    %esp,%ebp
  801361:	57                   	push   %edi
  801362:	56                   	push   %esi
  801363:	53                   	push   %ebx
  801364:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80136a:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80136f:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801375:	eb 2e                	jmp    8013a5 <devcons_write+0x47>
		m = n - tot;
  801377:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80137a:	29 f3                	sub    %esi,%ebx
  80137c:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801381:	39 c3                	cmp    %eax,%ebx
  801383:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801386:	83 ec 04             	sub    $0x4,%esp
  801389:	53                   	push   %ebx
  80138a:	89 f0                	mov    %esi,%eax
  80138c:	03 45 0c             	add    0xc(%ebp),%eax
  80138f:	50                   	push   %eax
  801390:	57                   	push   %edi
  801391:	e8 67 09 00 00       	call   801cfd <memmove>
		sys_cputs(buf, m);
  801396:	83 c4 08             	add    $0x8,%esp
  801399:	53                   	push   %ebx
  80139a:	57                   	push   %edi
  80139b:	e8 f6 ec ff ff       	call   800096 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013a0:	01 de                	add    %ebx,%esi
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013a8:	72 cd                	jb     801377 <devcons_write+0x19>
}
  8013aa:	89 f0                	mov    %esi,%eax
  8013ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013af:	5b                   	pop    %ebx
  8013b0:	5e                   	pop    %esi
  8013b1:	5f                   	pop    %edi
  8013b2:	5d                   	pop    %ebp
  8013b3:	c3                   	ret    

008013b4 <devcons_read>:
{
  8013b4:	55                   	push   %ebp
  8013b5:	89 e5                	mov    %esp,%ebp
  8013b7:	83 ec 08             	sub    $0x8,%esp
  8013ba:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8013bf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013c3:	75 07                	jne    8013cc <devcons_read+0x18>
  8013c5:	eb 1f                	jmp    8013e6 <devcons_read+0x32>
		sys_yield();
  8013c7:	e8 67 ed ff ff       	call   800133 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8013cc:	e8 e3 ec ff ff       	call   8000b4 <sys_cgetc>
  8013d1:	85 c0                	test   %eax,%eax
  8013d3:	74 f2                	je     8013c7 <devcons_read+0x13>
	if (c < 0)
  8013d5:	78 0f                	js     8013e6 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8013d7:	83 f8 04             	cmp    $0x4,%eax
  8013da:	74 0c                	je     8013e8 <devcons_read+0x34>
	*(char*)vbuf = c;
  8013dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013df:	88 02                	mov    %al,(%edx)
	return 1;
  8013e1:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8013e6:	c9                   	leave  
  8013e7:	c3                   	ret    
		return 0;
  8013e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ed:	eb f7                	jmp    8013e6 <devcons_read+0x32>

008013ef <cputchar>:
{
  8013ef:	55                   	push   %ebp
  8013f0:	89 e5                	mov    %esp,%ebp
  8013f2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f8:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8013fb:	6a 01                	push   $0x1
  8013fd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801400:	50                   	push   %eax
  801401:	e8 90 ec ff ff       	call   800096 <sys_cputs>
}
  801406:	83 c4 10             	add    $0x10,%esp
  801409:	c9                   	leave  
  80140a:	c3                   	ret    

0080140b <getchar>:
{
  80140b:	55                   	push   %ebp
  80140c:	89 e5                	mov    %esp,%ebp
  80140e:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801411:	6a 01                	push   $0x1
  801413:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801416:	50                   	push   %eax
  801417:	6a 00                	push   $0x0
  801419:	e8 66 f2 ff ff       	call   800684 <read>
	if (r < 0)
  80141e:	83 c4 10             	add    $0x10,%esp
  801421:	85 c0                	test   %eax,%eax
  801423:	78 06                	js     80142b <getchar+0x20>
	if (r < 1)
  801425:	74 06                	je     80142d <getchar+0x22>
	return c;
  801427:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80142b:	c9                   	leave  
  80142c:	c3                   	ret    
		return -E_EOF;
  80142d:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801432:	eb f7                	jmp    80142b <getchar+0x20>

00801434 <iscons>:
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80143a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143d:	50                   	push   %eax
  80143e:	ff 75 08             	push   0x8(%ebp)
  801441:	e8 d5 ef ff ff       	call   80041b <fd_lookup>
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 11                	js     80145e <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80144d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801450:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801456:	39 10                	cmp    %edx,(%eax)
  801458:	0f 94 c0             	sete   %al
  80145b:	0f b6 c0             	movzbl %al,%eax
}
  80145e:	c9                   	leave  
  80145f:	c3                   	ret    

00801460 <opencons>:
{
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801466:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801469:	50                   	push   %eax
  80146a:	e8 5c ef ff ff       	call   8003cb <fd_alloc>
  80146f:	83 c4 10             	add    $0x10,%esp
  801472:	85 c0                	test   %eax,%eax
  801474:	78 3a                	js     8014b0 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801476:	83 ec 04             	sub    $0x4,%esp
  801479:	68 07 04 00 00       	push   $0x407
  80147e:	ff 75 f4             	push   -0xc(%ebp)
  801481:	6a 00                	push   $0x0
  801483:	e8 ca ec ff ff       	call   800152 <sys_page_alloc>
  801488:	83 c4 10             	add    $0x10,%esp
  80148b:	85 c0                	test   %eax,%eax
  80148d:	78 21                	js     8014b0 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80148f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801492:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801498:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80149a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149d:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014a4:	83 ec 0c             	sub    $0xc,%esp
  8014a7:	50                   	push   %eax
  8014a8:	e8 f7 ee ff ff       	call   8003a4 <fd2num>
  8014ad:	83 c4 10             	add    $0x10,%esp
}
  8014b0:	c9                   	leave  
  8014b1:	c3                   	ret    

008014b2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014b2:	55                   	push   %ebp
  8014b3:	89 e5                	mov    %esp,%ebp
  8014b5:	56                   	push   %esi
  8014b6:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014b7:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014ba:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014c0:	e8 4f ec ff ff       	call   800114 <sys_getenvid>
  8014c5:	83 ec 0c             	sub    $0xc,%esp
  8014c8:	ff 75 0c             	push   0xc(%ebp)
  8014cb:	ff 75 08             	push   0x8(%ebp)
  8014ce:	56                   	push   %esi
  8014cf:	50                   	push   %eax
  8014d0:	68 80 23 80 00       	push   $0x802380
  8014d5:	e8 b3 00 00 00       	call   80158d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014da:	83 c4 18             	add    $0x18,%esp
  8014dd:	53                   	push   %ebx
  8014de:	ff 75 10             	push   0x10(%ebp)
  8014e1:	e8 56 00 00 00       	call   80153c <vcprintf>
	cprintf("\n");
  8014e6:	c7 04 24 6c 23 80 00 	movl   $0x80236c,(%esp)
  8014ed:	e8 9b 00 00 00       	call   80158d <cprintf>
  8014f2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014f5:	cc                   	int3   
  8014f6:	eb fd                	jmp    8014f5 <_panic+0x43>

008014f8 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8014f8:	55                   	push   %ebp
  8014f9:	89 e5                	mov    %esp,%ebp
  8014fb:	53                   	push   %ebx
  8014fc:	83 ec 04             	sub    $0x4,%esp
  8014ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801502:	8b 13                	mov    (%ebx),%edx
  801504:	8d 42 01             	lea    0x1(%edx),%eax
  801507:	89 03                	mov    %eax,(%ebx)
  801509:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80150c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801510:	3d ff 00 00 00       	cmp    $0xff,%eax
  801515:	74 09                	je     801520 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801517:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80151b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151e:	c9                   	leave  
  80151f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801520:	83 ec 08             	sub    $0x8,%esp
  801523:	68 ff 00 00 00       	push   $0xff
  801528:	8d 43 08             	lea    0x8(%ebx),%eax
  80152b:	50                   	push   %eax
  80152c:	e8 65 eb ff ff       	call   800096 <sys_cputs>
		b->idx = 0;
  801531:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801537:	83 c4 10             	add    $0x10,%esp
  80153a:	eb db                	jmp    801517 <putch+0x1f>

0080153c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801545:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80154c:	00 00 00 
	b.cnt = 0;
  80154f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801556:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801559:	ff 75 0c             	push   0xc(%ebp)
  80155c:	ff 75 08             	push   0x8(%ebp)
  80155f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801565:	50                   	push   %eax
  801566:	68 f8 14 80 00       	push   $0x8014f8
  80156b:	e8 14 01 00 00       	call   801684 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801570:	83 c4 08             	add    $0x8,%esp
  801573:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  801579:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80157f:	50                   	push   %eax
  801580:	e8 11 eb ff ff       	call   800096 <sys_cputs>

	return b.cnt;
}
  801585:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80158b:	c9                   	leave  
  80158c:	c3                   	ret    

0080158d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80158d:	55                   	push   %ebp
  80158e:	89 e5                	mov    %esp,%ebp
  801590:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801593:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801596:	50                   	push   %eax
  801597:	ff 75 08             	push   0x8(%ebp)
  80159a:	e8 9d ff ff ff       	call   80153c <vcprintf>
	va_end(ap);

	return cnt;
}
  80159f:	c9                   	leave  
  8015a0:	c3                   	ret    

008015a1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	57                   	push   %edi
  8015a5:	56                   	push   %esi
  8015a6:	53                   	push   %ebx
  8015a7:	83 ec 1c             	sub    $0x1c,%esp
  8015aa:	89 c7                	mov    %eax,%edi
  8015ac:	89 d6                	mov    %edx,%esi
  8015ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b4:	89 d1                	mov    %edx,%ecx
  8015b6:	89 c2                	mov    %eax,%edx
  8015b8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015bb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8015be:	8b 45 10             	mov    0x10(%ebp),%eax
  8015c1:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015c7:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8015ce:	39 c2                	cmp    %eax,%edx
  8015d0:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8015d3:	72 3e                	jb     801613 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015d5:	83 ec 0c             	sub    $0xc,%esp
  8015d8:	ff 75 18             	push   0x18(%ebp)
  8015db:	83 eb 01             	sub    $0x1,%ebx
  8015de:	53                   	push   %ebx
  8015df:	50                   	push   %eax
  8015e0:	83 ec 08             	sub    $0x8,%esp
  8015e3:	ff 75 e4             	push   -0x1c(%ebp)
  8015e6:	ff 75 e0             	push   -0x20(%ebp)
  8015e9:	ff 75 dc             	push   -0x24(%ebp)
  8015ec:	ff 75 d8             	push   -0x28(%ebp)
  8015ef:	e8 ec 09 00 00       	call   801fe0 <__udivdi3>
  8015f4:	83 c4 18             	add    $0x18,%esp
  8015f7:	52                   	push   %edx
  8015f8:	50                   	push   %eax
  8015f9:	89 f2                	mov    %esi,%edx
  8015fb:	89 f8                	mov    %edi,%eax
  8015fd:	e8 9f ff ff ff       	call   8015a1 <printnum>
  801602:	83 c4 20             	add    $0x20,%esp
  801605:	eb 13                	jmp    80161a <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801607:	83 ec 08             	sub    $0x8,%esp
  80160a:	56                   	push   %esi
  80160b:	ff 75 18             	push   0x18(%ebp)
  80160e:	ff d7                	call   *%edi
  801610:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801613:	83 eb 01             	sub    $0x1,%ebx
  801616:	85 db                	test   %ebx,%ebx
  801618:	7f ed                	jg     801607 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80161a:	83 ec 08             	sub    $0x8,%esp
  80161d:	56                   	push   %esi
  80161e:	83 ec 04             	sub    $0x4,%esp
  801621:	ff 75 e4             	push   -0x1c(%ebp)
  801624:	ff 75 e0             	push   -0x20(%ebp)
  801627:	ff 75 dc             	push   -0x24(%ebp)
  80162a:	ff 75 d8             	push   -0x28(%ebp)
  80162d:	e8 ce 0a 00 00       	call   802100 <__umoddi3>
  801632:	83 c4 14             	add    $0x14,%esp
  801635:	0f be 80 a3 23 80 00 	movsbl 0x8023a3(%eax),%eax
  80163c:	50                   	push   %eax
  80163d:	ff d7                	call   *%edi
}
  80163f:	83 c4 10             	add    $0x10,%esp
  801642:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801645:	5b                   	pop    %ebx
  801646:	5e                   	pop    %esi
  801647:	5f                   	pop    %edi
  801648:	5d                   	pop    %ebp
  801649:	c3                   	ret    

0080164a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80164a:	55                   	push   %ebp
  80164b:	89 e5                	mov    %esp,%ebp
  80164d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801650:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801654:	8b 10                	mov    (%eax),%edx
  801656:	3b 50 04             	cmp    0x4(%eax),%edx
  801659:	73 0a                	jae    801665 <sprintputch+0x1b>
		*b->buf++ = ch;
  80165b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80165e:	89 08                	mov    %ecx,(%eax)
  801660:	8b 45 08             	mov    0x8(%ebp),%eax
  801663:	88 02                	mov    %al,(%edx)
}
  801665:	5d                   	pop    %ebp
  801666:	c3                   	ret    

00801667 <printfmt>:
{
  801667:	55                   	push   %ebp
  801668:	89 e5                	mov    %esp,%ebp
  80166a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80166d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801670:	50                   	push   %eax
  801671:	ff 75 10             	push   0x10(%ebp)
  801674:	ff 75 0c             	push   0xc(%ebp)
  801677:	ff 75 08             	push   0x8(%ebp)
  80167a:	e8 05 00 00 00       	call   801684 <vprintfmt>
}
  80167f:	83 c4 10             	add    $0x10,%esp
  801682:	c9                   	leave  
  801683:	c3                   	ret    

00801684 <vprintfmt>:
{
  801684:	55                   	push   %ebp
  801685:	89 e5                	mov    %esp,%ebp
  801687:	57                   	push   %edi
  801688:	56                   	push   %esi
  801689:	53                   	push   %ebx
  80168a:	83 ec 3c             	sub    $0x3c,%esp
  80168d:	8b 75 08             	mov    0x8(%ebp),%esi
  801690:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801693:	8b 7d 10             	mov    0x10(%ebp),%edi
  801696:	eb 0a                	jmp    8016a2 <vprintfmt+0x1e>
			putch(ch, putdat);
  801698:	83 ec 08             	sub    $0x8,%esp
  80169b:	53                   	push   %ebx
  80169c:	50                   	push   %eax
  80169d:	ff d6                	call   *%esi
  80169f:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016a2:	83 c7 01             	add    $0x1,%edi
  8016a5:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016a9:	83 f8 25             	cmp    $0x25,%eax
  8016ac:	74 0c                	je     8016ba <vprintfmt+0x36>
			if (ch == '\0')
  8016ae:	85 c0                	test   %eax,%eax
  8016b0:	75 e6                	jne    801698 <vprintfmt+0x14>
}
  8016b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b5:	5b                   	pop    %ebx
  8016b6:	5e                   	pop    %esi
  8016b7:	5f                   	pop    %edi
  8016b8:	5d                   	pop    %ebp
  8016b9:	c3                   	ret    
		padc = ' ';
  8016ba:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8016be:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8016c5:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8016cc:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8016d3:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8016d8:	8d 47 01             	lea    0x1(%edi),%eax
  8016db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016de:	0f b6 17             	movzbl (%edi),%edx
  8016e1:	8d 42 dd             	lea    -0x23(%edx),%eax
  8016e4:	3c 55                	cmp    $0x55,%al
  8016e6:	0f 87 bb 03 00 00    	ja     801aa7 <vprintfmt+0x423>
  8016ec:	0f b6 c0             	movzbl %al,%eax
  8016ef:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  8016f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8016f9:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8016fd:	eb d9                	jmp    8016d8 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8016ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801702:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801706:	eb d0                	jmp    8016d8 <vprintfmt+0x54>
  801708:	0f b6 d2             	movzbl %dl,%edx
  80170b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80170e:	b8 00 00 00 00       	mov    $0x0,%eax
  801713:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801716:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801719:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80171d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801720:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801723:	83 f9 09             	cmp    $0x9,%ecx
  801726:	77 55                	ja     80177d <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  801728:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80172b:	eb e9                	jmp    801716 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80172d:	8b 45 14             	mov    0x14(%ebp),%eax
  801730:	8b 00                	mov    (%eax),%eax
  801732:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801735:	8b 45 14             	mov    0x14(%ebp),%eax
  801738:	8d 40 04             	lea    0x4(%eax),%eax
  80173b:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80173e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801741:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801745:	79 91                	jns    8016d8 <vprintfmt+0x54>
				width = precision, precision = -1;
  801747:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80174a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80174d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801754:	eb 82                	jmp    8016d8 <vprintfmt+0x54>
  801756:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801759:	85 d2                	test   %edx,%edx
  80175b:	b8 00 00 00 00       	mov    $0x0,%eax
  801760:	0f 49 c2             	cmovns %edx,%eax
  801763:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801766:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801769:	e9 6a ff ff ff       	jmp    8016d8 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80176e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801771:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801778:	e9 5b ff ff ff       	jmp    8016d8 <vprintfmt+0x54>
  80177d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801780:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801783:	eb bc                	jmp    801741 <vprintfmt+0xbd>
			lflag++;
  801785:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801788:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80178b:	e9 48 ff ff ff       	jmp    8016d8 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  801790:	8b 45 14             	mov    0x14(%ebp),%eax
  801793:	8d 78 04             	lea    0x4(%eax),%edi
  801796:	83 ec 08             	sub    $0x8,%esp
  801799:	53                   	push   %ebx
  80179a:	ff 30                	push   (%eax)
  80179c:	ff d6                	call   *%esi
			break;
  80179e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017a1:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017a4:	e9 9d 02 00 00       	jmp    801a46 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8017a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ac:	8d 78 04             	lea    0x4(%eax),%edi
  8017af:	8b 10                	mov    (%eax),%edx
  8017b1:	89 d0                	mov    %edx,%eax
  8017b3:	f7 d8                	neg    %eax
  8017b5:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017b8:	83 f8 0f             	cmp    $0xf,%eax
  8017bb:	7f 23                	jg     8017e0 <vprintfmt+0x15c>
  8017bd:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  8017c4:	85 d2                	test   %edx,%edx
  8017c6:	74 18                	je     8017e0 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8017c8:	52                   	push   %edx
  8017c9:	68 01 23 80 00       	push   $0x802301
  8017ce:	53                   	push   %ebx
  8017cf:	56                   	push   %esi
  8017d0:	e8 92 fe ff ff       	call   801667 <printfmt>
  8017d5:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8017d8:	89 7d 14             	mov    %edi,0x14(%ebp)
  8017db:	e9 66 02 00 00       	jmp    801a46 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8017e0:	50                   	push   %eax
  8017e1:	68 bb 23 80 00       	push   $0x8023bb
  8017e6:	53                   	push   %ebx
  8017e7:	56                   	push   %esi
  8017e8:	e8 7a fe ff ff       	call   801667 <printfmt>
  8017ed:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8017f0:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8017f3:	e9 4e 02 00 00       	jmp    801a46 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8017f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8017fb:	83 c0 04             	add    $0x4,%eax
  8017fe:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801801:	8b 45 14             	mov    0x14(%ebp),%eax
  801804:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801806:	85 d2                	test   %edx,%edx
  801808:	b8 b4 23 80 00       	mov    $0x8023b4,%eax
  80180d:	0f 45 c2             	cmovne %edx,%eax
  801810:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801813:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801817:	7e 06                	jle    80181f <vprintfmt+0x19b>
  801819:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80181d:	75 0d                	jne    80182c <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80181f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801822:	89 c7                	mov    %eax,%edi
  801824:	03 45 e0             	add    -0x20(%ebp),%eax
  801827:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80182a:	eb 55                	jmp    801881 <vprintfmt+0x1fd>
  80182c:	83 ec 08             	sub    $0x8,%esp
  80182f:	ff 75 d8             	push   -0x28(%ebp)
  801832:	ff 75 cc             	push   -0x34(%ebp)
  801835:	e8 0a 03 00 00       	call   801b44 <strnlen>
  80183a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80183d:	29 c1                	sub    %eax,%ecx
  80183f:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801842:	83 c4 10             	add    $0x10,%esp
  801845:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  801847:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80184b:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80184e:	eb 0f                	jmp    80185f <vprintfmt+0x1db>
					putch(padc, putdat);
  801850:	83 ec 08             	sub    $0x8,%esp
  801853:	53                   	push   %ebx
  801854:	ff 75 e0             	push   -0x20(%ebp)
  801857:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801859:	83 ef 01             	sub    $0x1,%edi
  80185c:	83 c4 10             	add    $0x10,%esp
  80185f:	85 ff                	test   %edi,%edi
  801861:	7f ed                	jg     801850 <vprintfmt+0x1cc>
  801863:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801866:	85 d2                	test   %edx,%edx
  801868:	b8 00 00 00 00       	mov    $0x0,%eax
  80186d:	0f 49 c2             	cmovns %edx,%eax
  801870:	29 c2                	sub    %eax,%edx
  801872:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801875:	eb a8                	jmp    80181f <vprintfmt+0x19b>
					putch(ch, putdat);
  801877:	83 ec 08             	sub    $0x8,%esp
  80187a:	53                   	push   %ebx
  80187b:	52                   	push   %edx
  80187c:	ff d6                	call   *%esi
  80187e:	83 c4 10             	add    $0x10,%esp
  801881:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801884:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801886:	83 c7 01             	add    $0x1,%edi
  801889:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80188d:	0f be d0             	movsbl %al,%edx
  801890:	85 d2                	test   %edx,%edx
  801892:	74 4b                	je     8018df <vprintfmt+0x25b>
  801894:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801898:	78 06                	js     8018a0 <vprintfmt+0x21c>
  80189a:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80189e:	78 1e                	js     8018be <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8018a0:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018a4:	74 d1                	je     801877 <vprintfmt+0x1f3>
  8018a6:	0f be c0             	movsbl %al,%eax
  8018a9:	83 e8 20             	sub    $0x20,%eax
  8018ac:	83 f8 5e             	cmp    $0x5e,%eax
  8018af:	76 c6                	jbe    801877 <vprintfmt+0x1f3>
					putch('?', putdat);
  8018b1:	83 ec 08             	sub    $0x8,%esp
  8018b4:	53                   	push   %ebx
  8018b5:	6a 3f                	push   $0x3f
  8018b7:	ff d6                	call   *%esi
  8018b9:	83 c4 10             	add    $0x10,%esp
  8018bc:	eb c3                	jmp    801881 <vprintfmt+0x1fd>
  8018be:	89 cf                	mov    %ecx,%edi
  8018c0:	eb 0e                	jmp    8018d0 <vprintfmt+0x24c>
				putch(' ', putdat);
  8018c2:	83 ec 08             	sub    $0x8,%esp
  8018c5:	53                   	push   %ebx
  8018c6:	6a 20                	push   $0x20
  8018c8:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8018ca:	83 ef 01             	sub    $0x1,%edi
  8018cd:	83 c4 10             	add    $0x10,%esp
  8018d0:	85 ff                	test   %edi,%edi
  8018d2:	7f ee                	jg     8018c2 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8018d4:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8018d7:	89 45 14             	mov    %eax,0x14(%ebp)
  8018da:	e9 67 01 00 00       	jmp    801a46 <vprintfmt+0x3c2>
  8018df:	89 cf                	mov    %ecx,%edi
  8018e1:	eb ed                	jmp    8018d0 <vprintfmt+0x24c>
	if (lflag >= 2)
  8018e3:	83 f9 01             	cmp    $0x1,%ecx
  8018e6:	7f 1b                	jg     801903 <vprintfmt+0x27f>
	else if (lflag)
  8018e8:	85 c9                	test   %ecx,%ecx
  8018ea:	74 63                	je     80194f <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8018ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8018ef:	8b 00                	mov    (%eax),%eax
  8018f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018f4:	99                   	cltd   
  8018f5:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8018f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8018fb:	8d 40 04             	lea    0x4(%eax),%eax
  8018fe:	89 45 14             	mov    %eax,0x14(%ebp)
  801901:	eb 17                	jmp    80191a <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801903:	8b 45 14             	mov    0x14(%ebp),%eax
  801906:	8b 50 04             	mov    0x4(%eax),%edx
  801909:	8b 00                	mov    (%eax),%eax
  80190b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80190e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801911:	8b 45 14             	mov    0x14(%ebp),%eax
  801914:	8d 40 08             	lea    0x8(%eax),%eax
  801917:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80191a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80191d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801920:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801925:	85 c9                	test   %ecx,%ecx
  801927:	0f 89 ff 00 00 00    	jns    801a2c <vprintfmt+0x3a8>
				putch('-', putdat);
  80192d:	83 ec 08             	sub    $0x8,%esp
  801930:	53                   	push   %ebx
  801931:	6a 2d                	push   $0x2d
  801933:	ff d6                	call   *%esi
				num = -(long long) num;
  801935:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801938:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80193b:	f7 da                	neg    %edx
  80193d:	83 d1 00             	adc    $0x0,%ecx
  801940:	f7 d9                	neg    %ecx
  801942:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801945:	bf 0a 00 00 00       	mov    $0xa,%edi
  80194a:	e9 dd 00 00 00       	jmp    801a2c <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80194f:	8b 45 14             	mov    0x14(%ebp),%eax
  801952:	8b 00                	mov    (%eax),%eax
  801954:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801957:	99                   	cltd   
  801958:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80195b:	8b 45 14             	mov    0x14(%ebp),%eax
  80195e:	8d 40 04             	lea    0x4(%eax),%eax
  801961:	89 45 14             	mov    %eax,0x14(%ebp)
  801964:	eb b4                	jmp    80191a <vprintfmt+0x296>
	if (lflag >= 2)
  801966:	83 f9 01             	cmp    $0x1,%ecx
  801969:	7f 1e                	jg     801989 <vprintfmt+0x305>
	else if (lflag)
  80196b:	85 c9                	test   %ecx,%ecx
  80196d:	74 32                	je     8019a1 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80196f:	8b 45 14             	mov    0x14(%ebp),%eax
  801972:	8b 10                	mov    (%eax),%edx
  801974:	b9 00 00 00 00       	mov    $0x0,%ecx
  801979:	8d 40 04             	lea    0x4(%eax),%eax
  80197c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80197f:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  801984:	e9 a3 00 00 00       	jmp    801a2c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801989:	8b 45 14             	mov    0x14(%ebp),%eax
  80198c:	8b 10                	mov    (%eax),%edx
  80198e:	8b 48 04             	mov    0x4(%eax),%ecx
  801991:	8d 40 08             	lea    0x8(%eax),%eax
  801994:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801997:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80199c:	e9 8b 00 00 00       	jmp    801a2c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a4:	8b 10                	mov    (%eax),%edx
  8019a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019ab:	8d 40 04             	lea    0x4(%eax),%eax
  8019ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019b1:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8019b6:	eb 74                	jmp    801a2c <vprintfmt+0x3a8>
	if (lflag >= 2)
  8019b8:	83 f9 01             	cmp    $0x1,%ecx
  8019bb:	7f 1b                	jg     8019d8 <vprintfmt+0x354>
	else if (lflag)
  8019bd:	85 c9                	test   %ecx,%ecx
  8019bf:	74 2c                	je     8019ed <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8019c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c4:	8b 10                	mov    (%eax),%edx
  8019c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019cb:	8d 40 04             	lea    0x4(%eax),%eax
  8019ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019d1:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8019d6:	eb 54                	jmp    801a2c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8019d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8019db:	8b 10                	mov    (%eax),%edx
  8019dd:	8b 48 04             	mov    0x4(%eax),%ecx
  8019e0:	8d 40 08             	lea    0x8(%eax),%eax
  8019e3:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019e6:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8019eb:	eb 3f                	jmp    801a2c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f0:	8b 10                	mov    (%eax),%edx
  8019f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019f7:	8d 40 04             	lea    0x4(%eax),%eax
  8019fa:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019fd:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801a02:	eb 28                	jmp    801a2c <vprintfmt+0x3a8>
			putch('0', putdat);
  801a04:	83 ec 08             	sub    $0x8,%esp
  801a07:	53                   	push   %ebx
  801a08:	6a 30                	push   $0x30
  801a0a:	ff d6                	call   *%esi
			putch('x', putdat);
  801a0c:	83 c4 08             	add    $0x8,%esp
  801a0f:	53                   	push   %ebx
  801a10:	6a 78                	push   $0x78
  801a12:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a14:	8b 45 14             	mov    0x14(%ebp),%eax
  801a17:	8b 10                	mov    (%eax),%edx
  801a19:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a1e:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a21:	8d 40 04             	lea    0x4(%eax),%eax
  801a24:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a27:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801a2c:	83 ec 0c             	sub    $0xc,%esp
  801a2f:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801a33:	50                   	push   %eax
  801a34:	ff 75 e0             	push   -0x20(%ebp)
  801a37:	57                   	push   %edi
  801a38:	51                   	push   %ecx
  801a39:	52                   	push   %edx
  801a3a:	89 da                	mov    %ebx,%edx
  801a3c:	89 f0                	mov    %esi,%eax
  801a3e:	e8 5e fb ff ff       	call   8015a1 <printnum>
			break;
  801a43:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801a46:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a49:	e9 54 fc ff ff       	jmp    8016a2 <vprintfmt+0x1e>
	if (lflag >= 2)
  801a4e:	83 f9 01             	cmp    $0x1,%ecx
  801a51:	7f 1b                	jg     801a6e <vprintfmt+0x3ea>
	else if (lflag)
  801a53:	85 c9                	test   %ecx,%ecx
  801a55:	74 2c                	je     801a83 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801a57:	8b 45 14             	mov    0x14(%ebp),%eax
  801a5a:	8b 10                	mov    (%eax),%edx
  801a5c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a61:	8d 40 04             	lea    0x4(%eax),%eax
  801a64:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a67:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  801a6c:	eb be                	jmp    801a2c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801a6e:	8b 45 14             	mov    0x14(%ebp),%eax
  801a71:	8b 10                	mov    (%eax),%edx
  801a73:	8b 48 04             	mov    0x4(%eax),%ecx
  801a76:	8d 40 08             	lea    0x8(%eax),%eax
  801a79:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a7c:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  801a81:	eb a9                	jmp    801a2c <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801a83:	8b 45 14             	mov    0x14(%ebp),%eax
  801a86:	8b 10                	mov    (%eax),%edx
  801a88:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a8d:	8d 40 04             	lea    0x4(%eax),%eax
  801a90:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a93:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  801a98:	eb 92                	jmp    801a2c <vprintfmt+0x3a8>
			putch(ch, putdat);
  801a9a:	83 ec 08             	sub    $0x8,%esp
  801a9d:	53                   	push   %ebx
  801a9e:	6a 25                	push   $0x25
  801aa0:	ff d6                	call   *%esi
			break;
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	eb 9f                	jmp    801a46 <vprintfmt+0x3c2>
			putch('%', putdat);
  801aa7:	83 ec 08             	sub    $0x8,%esp
  801aaa:	53                   	push   %ebx
  801aab:	6a 25                	push   $0x25
  801aad:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801aaf:	83 c4 10             	add    $0x10,%esp
  801ab2:	89 f8                	mov    %edi,%eax
  801ab4:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801ab8:	74 05                	je     801abf <vprintfmt+0x43b>
  801aba:	83 e8 01             	sub    $0x1,%eax
  801abd:	eb f5                	jmp    801ab4 <vprintfmt+0x430>
  801abf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ac2:	eb 82                	jmp    801a46 <vprintfmt+0x3c2>

00801ac4 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	83 ec 18             	sub    $0x18,%esp
  801aca:	8b 45 08             	mov    0x8(%ebp),%eax
  801acd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ad0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ad3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ad7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ada:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ae1:	85 c0                	test   %eax,%eax
  801ae3:	74 26                	je     801b0b <vsnprintf+0x47>
  801ae5:	85 d2                	test   %edx,%edx
  801ae7:	7e 22                	jle    801b0b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ae9:	ff 75 14             	push   0x14(%ebp)
  801aec:	ff 75 10             	push   0x10(%ebp)
  801aef:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801af2:	50                   	push   %eax
  801af3:	68 4a 16 80 00       	push   $0x80164a
  801af8:	e8 87 fb ff ff       	call   801684 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801afd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b00:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b06:	83 c4 10             	add    $0x10,%esp
}
  801b09:	c9                   	leave  
  801b0a:	c3                   	ret    
		return -E_INVAL;
  801b0b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b10:	eb f7                	jmp    801b09 <vsnprintf+0x45>

00801b12 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b18:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b1b:	50                   	push   %eax
  801b1c:	ff 75 10             	push   0x10(%ebp)
  801b1f:	ff 75 0c             	push   0xc(%ebp)
  801b22:	ff 75 08             	push   0x8(%ebp)
  801b25:	e8 9a ff ff ff       	call   801ac4 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b2a:	c9                   	leave  
  801b2b:	c3                   	ret    

00801b2c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b2c:	55                   	push   %ebp
  801b2d:	89 e5                	mov    %esp,%ebp
  801b2f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b32:	b8 00 00 00 00       	mov    $0x0,%eax
  801b37:	eb 03                	jmp    801b3c <strlen+0x10>
		n++;
  801b39:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801b3c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b40:	75 f7                	jne    801b39 <strlen+0xd>
	return n;
}
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    

00801b44 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b4a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b4d:	b8 00 00 00 00       	mov    $0x0,%eax
  801b52:	eb 03                	jmp    801b57 <strnlen+0x13>
		n++;
  801b54:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b57:	39 d0                	cmp    %edx,%eax
  801b59:	74 08                	je     801b63 <strnlen+0x1f>
  801b5b:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801b5f:	75 f3                	jne    801b54 <strnlen+0x10>
  801b61:	89 c2                	mov    %eax,%edx
	return n;
}
  801b63:	89 d0                	mov    %edx,%eax
  801b65:	5d                   	pop    %ebp
  801b66:	c3                   	ret    

00801b67 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b67:	55                   	push   %ebp
  801b68:	89 e5                	mov    %esp,%ebp
  801b6a:	53                   	push   %ebx
  801b6b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b6e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b71:	b8 00 00 00 00       	mov    $0x0,%eax
  801b76:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801b7a:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801b7d:	83 c0 01             	add    $0x1,%eax
  801b80:	84 d2                	test   %dl,%dl
  801b82:	75 f2                	jne    801b76 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801b84:	89 c8                	mov    %ecx,%eax
  801b86:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    

00801b8b <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	53                   	push   %ebx
  801b8f:	83 ec 10             	sub    $0x10,%esp
  801b92:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b95:	53                   	push   %ebx
  801b96:	e8 91 ff ff ff       	call   801b2c <strlen>
  801b9b:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801b9e:	ff 75 0c             	push   0xc(%ebp)
  801ba1:	01 d8                	add    %ebx,%eax
  801ba3:	50                   	push   %eax
  801ba4:	e8 be ff ff ff       	call   801b67 <strcpy>
	return dst;
}
  801ba9:	89 d8                	mov    %ebx,%eax
  801bab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bae:	c9                   	leave  
  801baf:	c3                   	ret    

00801bb0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	56                   	push   %esi
  801bb4:	53                   	push   %ebx
  801bb5:	8b 75 08             	mov    0x8(%ebp),%esi
  801bb8:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bbb:	89 f3                	mov    %esi,%ebx
  801bbd:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bc0:	89 f0                	mov    %esi,%eax
  801bc2:	eb 0f                	jmp    801bd3 <strncpy+0x23>
		*dst++ = *src;
  801bc4:	83 c0 01             	add    $0x1,%eax
  801bc7:	0f b6 0a             	movzbl (%edx),%ecx
  801bca:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bcd:	80 f9 01             	cmp    $0x1,%cl
  801bd0:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801bd3:	39 d8                	cmp    %ebx,%eax
  801bd5:	75 ed                	jne    801bc4 <strncpy+0x14>
	}
	return ret;
}
  801bd7:	89 f0                	mov    %esi,%eax
  801bd9:	5b                   	pop    %ebx
  801bda:	5e                   	pop    %esi
  801bdb:	5d                   	pop    %ebp
  801bdc:	c3                   	ret    

00801bdd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bdd:	55                   	push   %ebp
  801bde:	89 e5                	mov    %esp,%ebp
  801be0:	56                   	push   %esi
  801be1:	53                   	push   %ebx
  801be2:	8b 75 08             	mov    0x8(%ebp),%esi
  801be5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be8:	8b 55 10             	mov    0x10(%ebp),%edx
  801beb:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bed:	85 d2                	test   %edx,%edx
  801bef:	74 21                	je     801c12 <strlcpy+0x35>
  801bf1:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bf5:	89 f2                	mov    %esi,%edx
  801bf7:	eb 09                	jmp    801c02 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bf9:	83 c1 01             	add    $0x1,%ecx
  801bfc:	83 c2 01             	add    $0x1,%edx
  801bff:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801c02:	39 c2                	cmp    %eax,%edx
  801c04:	74 09                	je     801c0f <strlcpy+0x32>
  801c06:	0f b6 19             	movzbl (%ecx),%ebx
  801c09:	84 db                	test   %bl,%bl
  801c0b:	75 ec                	jne    801bf9 <strlcpy+0x1c>
  801c0d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801c0f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c12:	29 f0                	sub    %esi,%eax
}
  801c14:	5b                   	pop    %ebx
  801c15:	5e                   	pop    %esi
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    

00801c18 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c1e:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c21:	eb 06                	jmp    801c29 <strcmp+0x11>
		p++, q++;
  801c23:	83 c1 01             	add    $0x1,%ecx
  801c26:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801c29:	0f b6 01             	movzbl (%ecx),%eax
  801c2c:	84 c0                	test   %al,%al
  801c2e:	74 04                	je     801c34 <strcmp+0x1c>
  801c30:	3a 02                	cmp    (%edx),%al
  801c32:	74 ef                	je     801c23 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c34:	0f b6 c0             	movzbl %al,%eax
  801c37:	0f b6 12             	movzbl (%edx),%edx
  801c3a:	29 d0                	sub    %edx,%eax
}
  801c3c:	5d                   	pop    %ebp
  801c3d:	c3                   	ret    

00801c3e <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c3e:	55                   	push   %ebp
  801c3f:	89 e5                	mov    %esp,%ebp
  801c41:	53                   	push   %ebx
  801c42:	8b 45 08             	mov    0x8(%ebp),%eax
  801c45:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c48:	89 c3                	mov    %eax,%ebx
  801c4a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c4d:	eb 06                	jmp    801c55 <strncmp+0x17>
		n--, p++, q++;
  801c4f:	83 c0 01             	add    $0x1,%eax
  801c52:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801c55:	39 d8                	cmp    %ebx,%eax
  801c57:	74 18                	je     801c71 <strncmp+0x33>
  801c59:	0f b6 08             	movzbl (%eax),%ecx
  801c5c:	84 c9                	test   %cl,%cl
  801c5e:	74 04                	je     801c64 <strncmp+0x26>
  801c60:	3a 0a                	cmp    (%edx),%cl
  801c62:	74 eb                	je     801c4f <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c64:	0f b6 00             	movzbl (%eax),%eax
  801c67:	0f b6 12             	movzbl (%edx),%edx
  801c6a:	29 d0                	sub    %edx,%eax
}
  801c6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c6f:	c9                   	leave  
  801c70:	c3                   	ret    
		return 0;
  801c71:	b8 00 00 00 00       	mov    $0x0,%eax
  801c76:	eb f4                	jmp    801c6c <strncmp+0x2e>

00801c78 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c78:	55                   	push   %ebp
  801c79:	89 e5                	mov    %esp,%ebp
  801c7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c82:	eb 03                	jmp    801c87 <strchr+0xf>
  801c84:	83 c0 01             	add    $0x1,%eax
  801c87:	0f b6 10             	movzbl (%eax),%edx
  801c8a:	84 d2                	test   %dl,%dl
  801c8c:	74 06                	je     801c94 <strchr+0x1c>
		if (*s == c)
  801c8e:	38 ca                	cmp    %cl,%dl
  801c90:	75 f2                	jne    801c84 <strchr+0xc>
  801c92:	eb 05                	jmp    801c99 <strchr+0x21>
			return (char *) s;
	return 0;
  801c94:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c99:	5d                   	pop    %ebp
  801c9a:	c3                   	ret    

00801c9b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ca5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801ca8:	38 ca                	cmp    %cl,%dl
  801caa:	74 09                	je     801cb5 <strfind+0x1a>
  801cac:	84 d2                	test   %dl,%dl
  801cae:	74 05                	je     801cb5 <strfind+0x1a>
	for (; *s; s++)
  801cb0:	83 c0 01             	add    $0x1,%eax
  801cb3:	eb f0                	jmp    801ca5 <strfind+0xa>
			break;
	return (char *) s;
}
  801cb5:	5d                   	pop    %ebp
  801cb6:	c3                   	ret    

00801cb7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cb7:	55                   	push   %ebp
  801cb8:	89 e5                	mov    %esp,%ebp
  801cba:	57                   	push   %edi
  801cbb:	56                   	push   %esi
  801cbc:	53                   	push   %ebx
  801cbd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cc0:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cc3:	85 c9                	test   %ecx,%ecx
  801cc5:	74 2f                	je     801cf6 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cc7:	89 f8                	mov    %edi,%eax
  801cc9:	09 c8                	or     %ecx,%eax
  801ccb:	a8 03                	test   $0x3,%al
  801ccd:	75 21                	jne    801cf0 <memset+0x39>
		c &= 0xFF;
  801ccf:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cd3:	89 d0                	mov    %edx,%eax
  801cd5:	c1 e0 08             	shl    $0x8,%eax
  801cd8:	89 d3                	mov    %edx,%ebx
  801cda:	c1 e3 18             	shl    $0x18,%ebx
  801cdd:	89 d6                	mov    %edx,%esi
  801cdf:	c1 e6 10             	shl    $0x10,%esi
  801ce2:	09 f3                	or     %esi,%ebx
  801ce4:	09 da                	or     %ebx,%edx
  801ce6:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801ce8:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801ceb:	fc                   	cld    
  801cec:	f3 ab                	rep stos %eax,%es:(%edi)
  801cee:	eb 06                	jmp    801cf6 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cf0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf3:	fc                   	cld    
  801cf4:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cf6:	89 f8                	mov    %edi,%eax
  801cf8:	5b                   	pop    %ebx
  801cf9:	5e                   	pop    %esi
  801cfa:	5f                   	pop    %edi
  801cfb:	5d                   	pop    %ebp
  801cfc:	c3                   	ret    

00801cfd <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cfd:	55                   	push   %ebp
  801cfe:	89 e5                	mov    %esp,%ebp
  801d00:	57                   	push   %edi
  801d01:	56                   	push   %esi
  801d02:	8b 45 08             	mov    0x8(%ebp),%eax
  801d05:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d08:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d0b:	39 c6                	cmp    %eax,%esi
  801d0d:	73 32                	jae    801d41 <memmove+0x44>
  801d0f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d12:	39 c2                	cmp    %eax,%edx
  801d14:	76 2b                	jbe    801d41 <memmove+0x44>
		s += n;
		d += n;
  801d16:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d19:	89 d6                	mov    %edx,%esi
  801d1b:	09 fe                	or     %edi,%esi
  801d1d:	09 ce                	or     %ecx,%esi
  801d1f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d25:	75 0e                	jne    801d35 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d27:	83 ef 04             	sub    $0x4,%edi
  801d2a:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d2d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801d30:	fd                   	std    
  801d31:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d33:	eb 09                	jmp    801d3e <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d35:	83 ef 01             	sub    $0x1,%edi
  801d38:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801d3b:	fd                   	std    
  801d3c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d3e:	fc                   	cld    
  801d3f:	eb 1a                	jmp    801d5b <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d41:	89 f2                	mov    %esi,%edx
  801d43:	09 c2                	or     %eax,%edx
  801d45:	09 ca                	or     %ecx,%edx
  801d47:	f6 c2 03             	test   $0x3,%dl
  801d4a:	75 0a                	jne    801d56 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801d4c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801d4f:	89 c7                	mov    %eax,%edi
  801d51:	fc                   	cld    
  801d52:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d54:	eb 05                	jmp    801d5b <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801d56:	89 c7                	mov    %eax,%edi
  801d58:	fc                   	cld    
  801d59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d5b:	5e                   	pop    %esi
  801d5c:	5f                   	pop    %edi
  801d5d:	5d                   	pop    %ebp
  801d5e:	c3                   	ret    

00801d5f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d5f:	55                   	push   %ebp
  801d60:	89 e5                	mov    %esp,%ebp
  801d62:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d65:	ff 75 10             	push   0x10(%ebp)
  801d68:	ff 75 0c             	push   0xc(%ebp)
  801d6b:	ff 75 08             	push   0x8(%ebp)
  801d6e:	e8 8a ff ff ff       	call   801cfd <memmove>
}
  801d73:	c9                   	leave  
  801d74:	c3                   	ret    

00801d75 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	56                   	push   %esi
  801d79:	53                   	push   %ebx
  801d7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d80:	89 c6                	mov    %eax,%esi
  801d82:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d85:	eb 06                	jmp    801d8d <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801d87:	83 c0 01             	add    $0x1,%eax
  801d8a:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801d8d:	39 f0                	cmp    %esi,%eax
  801d8f:	74 14                	je     801da5 <memcmp+0x30>
		if (*s1 != *s2)
  801d91:	0f b6 08             	movzbl (%eax),%ecx
  801d94:	0f b6 1a             	movzbl (%edx),%ebx
  801d97:	38 d9                	cmp    %bl,%cl
  801d99:	74 ec                	je     801d87 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801d9b:	0f b6 c1             	movzbl %cl,%eax
  801d9e:	0f b6 db             	movzbl %bl,%ebx
  801da1:	29 d8                	sub    %ebx,%eax
  801da3:	eb 05                	jmp    801daa <memcmp+0x35>
	}

	return 0;
  801da5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801daa:	5b                   	pop    %ebx
  801dab:	5e                   	pop    %esi
  801dac:	5d                   	pop    %ebp
  801dad:	c3                   	ret    

00801dae <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dae:	55                   	push   %ebp
  801daf:	89 e5                	mov    %esp,%ebp
  801db1:	8b 45 08             	mov    0x8(%ebp),%eax
  801db4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801db7:	89 c2                	mov    %eax,%edx
  801db9:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801dbc:	eb 03                	jmp    801dc1 <memfind+0x13>
  801dbe:	83 c0 01             	add    $0x1,%eax
  801dc1:	39 d0                	cmp    %edx,%eax
  801dc3:	73 04                	jae    801dc9 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801dc5:	38 08                	cmp    %cl,(%eax)
  801dc7:	75 f5                	jne    801dbe <memfind+0x10>
			break;
	return (void *) s;
}
  801dc9:	5d                   	pop    %ebp
  801dca:	c3                   	ret    

00801dcb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dcb:	55                   	push   %ebp
  801dcc:	89 e5                	mov    %esp,%ebp
  801dce:	57                   	push   %edi
  801dcf:	56                   	push   %esi
  801dd0:	53                   	push   %ebx
  801dd1:	8b 55 08             	mov    0x8(%ebp),%edx
  801dd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dd7:	eb 03                	jmp    801ddc <strtol+0x11>
		s++;
  801dd9:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801ddc:	0f b6 02             	movzbl (%edx),%eax
  801ddf:	3c 20                	cmp    $0x20,%al
  801de1:	74 f6                	je     801dd9 <strtol+0xe>
  801de3:	3c 09                	cmp    $0x9,%al
  801de5:	74 f2                	je     801dd9 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801de7:	3c 2b                	cmp    $0x2b,%al
  801de9:	74 2a                	je     801e15 <strtol+0x4a>
	int neg = 0;
  801deb:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801df0:	3c 2d                	cmp    $0x2d,%al
  801df2:	74 2b                	je     801e1f <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801df4:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801dfa:	75 0f                	jne    801e0b <strtol+0x40>
  801dfc:	80 3a 30             	cmpb   $0x30,(%edx)
  801dff:	74 28                	je     801e29 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e01:	85 db                	test   %ebx,%ebx
  801e03:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e08:	0f 44 d8             	cmove  %eax,%ebx
  801e0b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e10:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801e13:	eb 46                	jmp    801e5b <strtol+0x90>
		s++;
  801e15:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801e18:	bf 00 00 00 00       	mov    $0x0,%edi
  801e1d:	eb d5                	jmp    801df4 <strtol+0x29>
		s++, neg = 1;
  801e1f:	83 c2 01             	add    $0x1,%edx
  801e22:	bf 01 00 00 00       	mov    $0x1,%edi
  801e27:	eb cb                	jmp    801df4 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e29:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e2d:	74 0e                	je     801e3d <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801e2f:	85 db                	test   %ebx,%ebx
  801e31:	75 d8                	jne    801e0b <strtol+0x40>
		s++, base = 8;
  801e33:	83 c2 01             	add    $0x1,%edx
  801e36:	bb 08 00 00 00       	mov    $0x8,%ebx
  801e3b:	eb ce                	jmp    801e0b <strtol+0x40>
		s += 2, base = 16;
  801e3d:	83 c2 02             	add    $0x2,%edx
  801e40:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e45:	eb c4                	jmp    801e0b <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801e47:	0f be c0             	movsbl %al,%eax
  801e4a:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801e4d:	3b 45 10             	cmp    0x10(%ebp),%eax
  801e50:	7d 3a                	jge    801e8c <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801e52:	83 c2 01             	add    $0x1,%edx
  801e55:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801e59:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801e5b:	0f b6 02             	movzbl (%edx),%eax
  801e5e:	8d 70 d0             	lea    -0x30(%eax),%esi
  801e61:	89 f3                	mov    %esi,%ebx
  801e63:	80 fb 09             	cmp    $0x9,%bl
  801e66:	76 df                	jbe    801e47 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  801e68:	8d 70 9f             	lea    -0x61(%eax),%esi
  801e6b:	89 f3                	mov    %esi,%ebx
  801e6d:	80 fb 19             	cmp    $0x19,%bl
  801e70:	77 08                	ja     801e7a <strtol+0xaf>
			dig = *s - 'a' + 10;
  801e72:	0f be c0             	movsbl %al,%eax
  801e75:	83 e8 57             	sub    $0x57,%eax
  801e78:	eb d3                	jmp    801e4d <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801e7a:	8d 70 bf             	lea    -0x41(%eax),%esi
  801e7d:	89 f3                	mov    %esi,%ebx
  801e7f:	80 fb 19             	cmp    $0x19,%bl
  801e82:	77 08                	ja     801e8c <strtol+0xc1>
			dig = *s - 'A' + 10;
  801e84:	0f be c0             	movsbl %al,%eax
  801e87:	83 e8 37             	sub    $0x37,%eax
  801e8a:	eb c1                	jmp    801e4d <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801e8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e90:	74 05                	je     801e97 <strtol+0xcc>
		*endptr = (char *) s;
  801e92:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e95:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801e97:	89 c8                	mov    %ecx,%eax
  801e99:	f7 d8                	neg    %eax
  801e9b:	85 ff                	test   %edi,%edi
  801e9d:	0f 45 c8             	cmovne %eax,%ecx
}
  801ea0:	89 c8                	mov    %ecx,%eax
  801ea2:	5b                   	pop    %ebx
  801ea3:	5e                   	pop    %esi
  801ea4:	5f                   	pop    %edi
  801ea5:	5d                   	pop    %ebp
  801ea6:	c3                   	ret    

00801ea7 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	56                   	push   %esi
  801eab:	53                   	push   %ebx
  801eac:	8b 75 08             	mov    0x8(%ebp),%esi
  801eaf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801eb5:	85 c0                	test   %eax,%eax
  801eb7:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ebc:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801ebf:	83 ec 0c             	sub    $0xc,%esp
  801ec2:	50                   	push   %eax
  801ec3:	e8 3a e4 ff ff       	call   800302 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ec8:	83 c4 10             	add    $0x10,%esp
  801ecb:	85 f6                	test   %esi,%esi
  801ecd:	74 14                	je     801ee3 <ipc_recv+0x3c>
  801ecf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ed4:	85 c0                	test   %eax,%eax
  801ed6:	78 09                	js     801ee1 <ipc_recv+0x3a>
  801ed8:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ede:	8b 52 74             	mov    0x74(%edx),%edx
  801ee1:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801ee3:	85 db                	test   %ebx,%ebx
  801ee5:	74 14                	je     801efb <ipc_recv+0x54>
  801ee7:	ba 00 00 00 00       	mov    $0x0,%edx
  801eec:	85 c0                	test   %eax,%eax
  801eee:	78 09                	js     801ef9 <ipc_recv+0x52>
  801ef0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ef6:	8b 52 78             	mov    0x78(%edx),%edx
  801ef9:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801efb:	85 c0                	test   %eax,%eax
  801efd:	78 08                	js     801f07 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801eff:	a1 00 40 80 00       	mov    0x804000,%eax
  801f04:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f07:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f0a:	5b                   	pop    %ebx
  801f0b:	5e                   	pop    %esi
  801f0c:	5d                   	pop    %ebp
  801f0d:	c3                   	ret    

00801f0e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f0e:	55                   	push   %ebp
  801f0f:	89 e5                	mov    %esp,%ebp
  801f11:	57                   	push   %edi
  801f12:	56                   	push   %esi
  801f13:	53                   	push   %ebx
  801f14:	83 ec 0c             	sub    $0xc,%esp
  801f17:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f1a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f20:	85 db                	test   %ebx,%ebx
  801f22:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f27:	0f 44 d8             	cmove  %eax,%ebx
  801f2a:	eb 05                	jmp    801f31 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f2c:	e8 02 e2 ff ff       	call   800133 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f31:	ff 75 14             	push   0x14(%ebp)
  801f34:	53                   	push   %ebx
  801f35:	56                   	push   %esi
  801f36:	57                   	push   %edi
  801f37:	e8 a3 e3 ff ff       	call   8002df <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f3c:	83 c4 10             	add    $0x10,%esp
  801f3f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f42:	74 e8                	je     801f2c <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f44:	85 c0                	test   %eax,%eax
  801f46:	78 08                	js     801f50 <ipc_send+0x42>
	}while (r<0);

}
  801f48:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4b:	5b                   	pop    %ebx
  801f4c:	5e                   	pop    %esi
  801f4d:	5f                   	pop    %edi
  801f4e:	5d                   	pop    %ebp
  801f4f:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f50:	50                   	push   %eax
  801f51:	68 9f 26 80 00       	push   $0x80269f
  801f56:	6a 3d                	push   $0x3d
  801f58:	68 b3 26 80 00       	push   $0x8026b3
  801f5d:	e8 50 f5 ff ff       	call   8014b2 <_panic>

00801f62 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f62:	55                   	push   %ebp
  801f63:	89 e5                	mov    %esp,%ebp
  801f65:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f68:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f6d:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f70:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f76:	8b 52 50             	mov    0x50(%edx),%edx
  801f79:	39 ca                	cmp    %ecx,%edx
  801f7b:	74 11                	je     801f8e <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801f7d:	83 c0 01             	add    $0x1,%eax
  801f80:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f85:	75 e6                	jne    801f6d <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801f87:	b8 00 00 00 00       	mov    $0x0,%eax
  801f8c:	eb 0b                	jmp    801f99 <ipc_find_env+0x37>
			return envs[i].env_id;
  801f8e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f91:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f96:	8b 40 48             	mov    0x48(%eax),%eax
}
  801f99:	5d                   	pop    %ebp
  801f9a:	c3                   	ret    

00801f9b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa1:	89 c2                	mov    %eax,%edx
  801fa3:	c1 ea 16             	shr    $0x16,%edx
  801fa6:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fad:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fb2:	f6 c1 01             	test   $0x1,%cl
  801fb5:	74 1c                	je     801fd3 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801fb7:	c1 e8 0c             	shr    $0xc,%eax
  801fba:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fc1:	a8 01                	test   $0x1,%al
  801fc3:	74 0e                	je     801fd3 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fc5:	c1 e8 0c             	shr    $0xc,%eax
  801fc8:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801fcf:	ef 
  801fd0:	0f b7 d2             	movzwl %dx,%edx
}
  801fd3:	89 d0                	mov    %edx,%eax
  801fd5:	5d                   	pop    %ebp
  801fd6:	c3                   	ret    
  801fd7:	66 90                	xchg   %ax,%ax
  801fd9:	66 90                	xchg   %ax,%ax
  801fdb:	66 90                	xchg   %ax,%ax
  801fdd:	66 90                	xchg   %ax,%ax
  801fdf:	90                   	nop

00801fe0 <__udivdi3>:
  801fe0:	f3 0f 1e fb          	endbr32 
  801fe4:	55                   	push   %ebp
  801fe5:	57                   	push   %edi
  801fe6:	56                   	push   %esi
  801fe7:	53                   	push   %ebx
  801fe8:	83 ec 1c             	sub    $0x1c,%esp
  801feb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801fef:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801ff3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ff7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801ffb:	85 c0                	test   %eax,%eax
  801ffd:	75 19                	jne    802018 <__udivdi3+0x38>
  801fff:	39 f3                	cmp    %esi,%ebx
  802001:	76 4d                	jbe    802050 <__udivdi3+0x70>
  802003:	31 ff                	xor    %edi,%edi
  802005:	89 e8                	mov    %ebp,%eax
  802007:	89 f2                	mov    %esi,%edx
  802009:	f7 f3                	div    %ebx
  80200b:	89 fa                	mov    %edi,%edx
  80200d:	83 c4 1c             	add    $0x1c,%esp
  802010:	5b                   	pop    %ebx
  802011:	5e                   	pop    %esi
  802012:	5f                   	pop    %edi
  802013:	5d                   	pop    %ebp
  802014:	c3                   	ret    
  802015:	8d 76 00             	lea    0x0(%esi),%esi
  802018:	39 f0                	cmp    %esi,%eax
  80201a:	76 14                	jbe    802030 <__udivdi3+0x50>
  80201c:	31 ff                	xor    %edi,%edi
  80201e:	31 c0                	xor    %eax,%eax
  802020:	89 fa                	mov    %edi,%edx
  802022:	83 c4 1c             	add    $0x1c,%esp
  802025:	5b                   	pop    %ebx
  802026:	5e                   	pop    %esi
  802027:	5f                   	pop    %edi
  802028:	5d                   	pop    %ebp
  802029:	c3                   	ret    
  80202a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802030:	0f bd f8             	bsr    %eax,%edi
  802033:	83 f7 1f             	xor    $0x1f,%edi
  802036:	75 48                	jne    802080 <__udivdi3+0xa0>
  802038:	39 f0                	cmp    %esi,%eax
  80203a:	72 06                	jb     802042 <__udivdi3+0x62>
  80203c:	31 c0                	xor    %eax,%eax
  80203e:	39 eb                	cmp    %ebp,%ebx
  802040:	77 de                	ja     802020 <__udivdi3+0x40>
  802042:	b8 01 00 00 00       	mov    $0x1,%eax
  802047:	eb d7                	jmp    802020 <__udivdi3+0x40>
  802049:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802050:	89 d9                	mov    %ebx,%ecx
  802052:	85 db                	test   %ebx,%ebx
  802054:	75 0b                	jne    802061 <__udivdi3+0x81>
  802056:	b8 01 00 00 00       	mov    $0x1,%eax
  80205b:	31 d2                	xor    %edx,%edx
  80205d:	f7 f3                	div    %ebx
  80205f:	89 c1                	mov    %eax,%ecx
  802061:	31 d2                	xor    %edx,%edx
  802063:	89 f0                	mov    %esi,%eax
  802065:	f7 f1                	div    %ecx
  802067:	89 c6                	mov    %eax,%esi
  802069:	89 e8                	mov    %ebp,%eax
  80206b:	89 f7                	mov    %esi,%edi
  80206d:	f7 f1                	div    %ecx
  80206f:	89 fa                	mov    %edi,%edx
  802071:	83 c4 1c             	add    $0x1c,%esp
  802074:	5b                   	pop    %ebx
  802075:	5e                   	pop    %esi
  802076:	5f                   	pop    %edi
  802077:	5d                   	pop    %ebp
  802078:	c3                   	ret    
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	89 f9                	mov    %edi,%ecx
  802082:	ba 20 00 00 00       	mov    $0x20,%edx
  802087:	29 fa                	sub    %edi,%edx
  802089:	d3 e0                	shl    %cl,%eax
  80208b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80208f:	89 d1                	mov    %edx,%ecx
  802091:	89 d8                	mov    %ebx,%eax
  802093:	d3 e8                	shr    %cl,%eax
  802095:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802099:	09 c1                	or     %eax,%ecx
  80209b:	89 f0                	mov    %esi,%eax
  80209d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020a1:	89 f9                	mov    %edi,%ecx
  8020a3:	d3 e3                	shl    %cl,%ebx
  8020a5:	89 d1                	mov    %edx,%ecx
  8020a7:	d3 e8                	shr    %cl,%eax
  8020a9:	89 f9                	mov    %edi,%ecx
  8020ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020af:	89 eb                	mov    %ebp,%ebx
  8020b1:	d3 e6                	shl    %cl,%esi
  8020b3:	89 d1                	mov    %edx,%ecx
  8020b5:	d3 eb                	shr    %cl,%ebx
  8020b7:	09 f3                	or     %esi,%ebx
  8020b9:	89 c6                	mov    %eax,%esi
  8020bb:	89 f2                	mov    %esi,%edx
  8020bd:	89 d8                	mov    %ebx,%eax
  8020bf:	f7 74 24 08          	divl   0x8(%esp)
  8020c3:	89 d6                	mov    %edx,%esi
  8020c5:	89 c3                	mov    %eax,%ebx
  8020c7:	f7 64 24 0c          	mull   0xc(%esp)
  8020cb:	39 d6                	cmp    %edx,%esi
  8020cd:	72 19                	jb     8020e8 <__udivdi3+0x108>
  8020cf:	89 f9                	mov    %edi,%ecx
  8020d1:	d3 e5                	shl    %cl,%ebp
  8020d3:	39 c5                	cmp    %eax,%ebp
  8020d5:	73 04                	jae    8020db <__udivdi3+0xfb>
  8020d7:	39 d6                	cmp    %edx,%esi
  8020d9:	74 0d                	je     8020e8 <__udivdi3+0x108>
  8020db:	89 d8                	mov    %ebx,%eax
  8020dd:	31 ff                	xor    %edi,%edi
  8020df:	e9 3c ff ff ff       	jmp    802020 <__udivdi3+0x40>
  8020e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020e8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8020eb:	31 ff                	xor    %edi,%edi
  8020ed:	e9 2e ff ff ff       	jmp    802020 <__udivdi3+0x40>
  8020f2:	66 90                	xchg   %ax,%ax
  8020f4:	66 90                	xchg   %ax,%ax
  8020f6:	66 90                	xchg   %ax,%ax
  8020f8:	66 90                	xchg   %ax,%ax
  8020fa:	66 90                	xchg   %ax,%ax
  8020fc:	66 90                	xchg   %ax,%ax
  8020fe:	66 90                	xchg   %ax,%ax

00802100 <__umoddi3>:
  802100:	f3 0f 1e fb          	endbr32 
  802104:	55                   	push   %ebp
  802105:	57                   	push   %edi
  802106:	56                   	push   %esi
  802107:	53                   	push   %ebx
  802108:	83 ec 1c             	sub    $0x1c,%esp
  80210b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80210f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802113:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802117:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80211b:	89 f0                	mov    %esi,%eax
  80211d:	89 da                	mov    %ebx,%edx
  80211f:	85 ff                	test   %edi,%edi
  802121:	75 15                	jne    802138 <__umoddi3+0x38>
  802123:	39 dd                	cmp    %ebx,%ebp
  802125:	76 39                	jbe    802160 <__umoddi3+0x60>
  802127:	f7 f5                	div    %ebp
  802129:	89 d0                	mov    %edx,%eax
  80212b:	31 d2                	xor    %edx,%edx
  80212d:	83 c4 1c             	add    $0x1c,%esp
  802130:	5b                   	pop    %ebx
  802131:	5e                   	pop    %esi
  802132:	5f                   	pop    %edi
  802133:	5d                   	pop    %ebp
  802134:	c3                   	ret    
  802135:	8d 76 00             	lea    0x0(%esi),%esi
  802138:	39 df                	cmp    %ebx,%edi
  80213a:	77 f1                	ja     80212d <__umoddi3+0x2d>
  80213c:	0f bd cf             	bsr    %edi,%ecx
  80213f:	83 f1 1f             	xor    $0x1f,%ecx
  802142:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802146:	75 40                	jne    802188 <__umoddi3+0x88>
  802148:	39 df                	cmp    %ebx,%edi
  80214a:	72 04                	jb     802150 <__umoddi3+0x50>
  80214c:	39 f5                	cmp    %esi,%ebp
  80214e:	77 dd                	ja     80212d <__umoddi3+0x2d>
  802150:	89 da                	mov    %ebx,%edx
  802152:	89 f0                	mov    %esi,%eax
  802154:	29 e8                	sub    %ebp,%eax
  802156:	19 fa                	sbb    %edi,%edx
  802158:	eb d3                	jmp    80212d <__umoddi3+0x2d>
  80215a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802160:	89 e9                	mov    %ebp,%ecx
  802162:	85 ed                	test   %ebp,%ebp
  802164:	75 0b                	jne    802171 <__umoddi3+0x71>
  802166:	b8 01 00 00 00       	mov    $0x1,%eax
  80216b:	31 d2                	xor    %edx,%edx
  80216d:	f7 f5                	div    %ebp
  80216f:	89 c1                	mov    %eax,%ecx
  802171:	89 d8                	mov    %ebx,%eax
  802173:	31 d2                	xor    %edx,%edx
  802175:	f7 f1                	div    %ecx
  802177:	89 f0                	mov    %esi,%eax
  802179:	f7 f1                	div    %ecx
  80217b:	89 d0                	mov    %edx,%eax
  80217d:	31 d2                	xor    %edx,%edx
  80217f:	eb ac                	jmp    80212d <__umoddi3+0x2d>
  802181:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802188:	8b 44 24 04          	mov    0x4(%esp),%eax
  80218c:	ba 20 00 00 00       	mov    $0x20,%edx
  802191:	29 c2                	sub    %eax,%edx
  802193:	89 c1                	mov    %eax,%ecx
  802195:	89 e8                	mov    %ebp,%eax
  802197:	d3 e7                	shl    %cl,%edi
  802199:	89 d1                	mov    %edx,%ecx
  80219b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80219f:	d3 e8                	shr    %cl,%eax
  8021a1:	89 c1                	mov    %eax,%ecx
  8021a3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021a7:	09 f9                	or     %edi,%ecx
  8021a9:	89 df                	mov    %ebx,%edi
  8021ab:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021af:	89 c1                	mov    %eax,%ecx
  8021b1:	d3 e5                	shl    %cl,%ebp
  8021b3:	89 d1                	mov    %edx,%ecx
  8021b5:	d3 ef                	shr    %cl,%edi
  8021b7:	89 c1                	mov    %eax,%ecx
  8021b9:	89 f0                	mov    %esi,%eax
  8021bb:	d3 e3                	shl    %cl,%ebx
  8021bd:	89 d1                	mov    %edx,%ecx
  8021bf:	89 fa                	mov    %edi,%edx
  8021c1:	d3 e8                	shr    %cl,%eax
  8021c3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021c8:	09 d8                	or     %ebx,%eax
  8021ca:	f7 74 24 08          	divl   0x8(%esp)
  8021ce:	89 d3                	mov    %edx,%ebx
  8021d0:	d3 e6                	shl    %cl,%esi
  8021d2:	f7 e5                	mul    %ebp
  8021d4:	89 c7                	mov    %eax,%edi
  8021d6:	89 d1                	mov    %edx,%ecx
  8021d8:	39 d3                	cmp    %edx,%ebx
  8021da:	72 06                	jb     8021e2 <__umoddi3+0xe2>
  8021dc:	75 0e                	jne    8021ec <__umoddi3+0xec>
  8021de:	39 c6                	cmp    %eax,%esi
  8021e0:	73 0a                	jae    8021ec <__umoddi3+0xec>
  8021e2:	29 e8                	sub    %ebp,%eax
  8021e4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8021e8:	89 d1                	mov    %edx,%ecx
  8021ea:	89 c7                	mov    %eax,%edi
  8021ec:	89 f5                	mov    %esi,%ebp
  8021ee:	8b 74 24 04          	mov    0x4(%esp),%esi
  8021f2:	29 fd                	sub    %edi,%ebp
  8021f4:	19 cb                	sbb    %ecx,%ebx
  8021f6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8021fb:	89 d8                	mov    %ebx,%eax
  8021fd:	d3 e0                	shl    %cl,%eax
  8021ff:	89 f1                	mov    %esi,%ecx
  802201:	d3 ed                	shr    %cl,%ebp
  802203:	d3 eb                	shr    %cl,%ebx
  802205:	09 e8                	or     %ebp,%eax
  802207:	89 da                	mov    %ebx,%edx
  802209:	83 c4 1c             	add    $0x1c,%esp
  80220c:	5b                   	pop    %ebx
  80220d:	5e                   	pop    %esi
  80220e:	5f                   	pop    %edi
  80220f:	5d                   	pop    %ebp
  802210:	c3                   	ret    
