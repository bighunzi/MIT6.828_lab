
obj/user/faultnostack.debug：     文件格式 elf32-i386


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
  800039:	68 61 03 80 00       	push   $0x800361
  80003e:	6a 00                	push   $0x0
  800040:	e8 76 02 00 00       	call   8002bb <sys_env_set_pgfault_upcall>
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
  80005f:	e8 ce 00 00 00       	call   800132 <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800071:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800076:	85 db                	test   %ebx,%ebx
  800078:	7e 07                	jle    800081 <libmain+0x2d>
		binaryname = argv[0];
  80007a:	8b 06                	mov    (%esi),%eax
  80007c:	a3 00 30 80 00       	mov    %eax,0x803000

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
  80009d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a0:	e8 ae 04 00 00       	call   800553 <close_all>
	sys_env_destroy(0);
  8000a5:	83 ec 0c             	sub    $0xc,%esp
  8000a8:	6a 00                	push   $0x0
  8000aa:	e8 42 00 00 00       	call   8000f1 <sys_env_destroy>
}
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	c9                   	leave  
  8000b3:	c3                   	ret    

008000b4 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b4:	55                   	push   %ebp
  8000b5:	89 e5                	mov    %esp,%ebp
  8000b7:	57                   	push   %edi
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8000bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c5:	89 c3                	mov    %eax,%ebx
  8000c7:	89 c7                	mov    %eax,%edi
  8000c9:	89 c6                	mov    %eax,%esi
  8000cb:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e2:	89 d1                	mov    %edx,%ecx
  8000e4:	89 d3                	mov    %edx,%ebx
  8000e6:	89 d7                	mov    %edx,%edi
  8000e8:	89 d6                	mov    %edx,%esi
  8000ea:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f1:	55                   	push   %ebp
  8000f2:	89 e5                	mov    %esp,%ebp
  8000f4:	57                   	push   %edi
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ff:	8b 55 08             	mov    0x8(%ebp),%edx
  800102:	b8 03 00 00 00       	mov    $0x3,%eax
  800107:	89 cb                	mov    %ecx,%ebx
  800109:	89 cf                	mov    %ecx,%edi
  80010b:	89 ce                	mov    %ecx,%esi
  80010d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80010f:	85 c0                	test   %eax,%eax
  800111:	7f 08                	jg     80011b <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800113:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800116:	5b                   	pop    %ebx
  800117:	5e                   	pop    %esi
  800118:	5f                   	pop    %edi
  800119:	5d                   	pop    %ebp
  80011a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80011b:	83 ec 0c             	sub    $0xc,%esp
  80011e:	50                   	push   %eax
  80011f:	6a 03                	push   $0x3
  800121:	68 2a 1e 80 00       	push   $0x801e2a
  800126:	6a 2a                	push   $0x2a
  800128:	68 47 1e 80 00       	push   $0x801e47
  80012d:	e8 f6 0e 00 00       	call   801028 <_panic>

00800132 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 02 00 00 00       	mov    $0x2,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_yield>:

void
sys_yield(void)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
	asm volatile("int %1\n"
  800157:	ba 00 00 00 00       	mov    $0x0,%edx
  80015c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800161:	89 d1                	mov    %edx,%ecx
  800163:	89 d3                	mov    %edx,%ebx
  800165:	89 d7                	mov    %edx,%edi
  800167:	89 d6                	mov    %edx,%esi
  800169:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016b:	5b                   	pop    %ebx
  80016c:	5e                   	pop    %esi
  80016d:	5f                   	pop    %edi
  80016e:	5d                   	pop    %ebp
  80016f:	c3                   	ret    

00800170 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	57                   	push   %edi
  800174:	56                   	push   %esi
  800175:	53                   	push   %ebx
  800176:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800179:	be 00 00 00 00       	mov    $0x0,%esi
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800184:	b8 04 00 00 00       	mov    $0x4,%eax
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	89 f7                	mov    %esi,%edi
  80018e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800190:	85 c0                	test   %eax,%eax
  800192:	7f 08                	jg     80019c <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800194:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800197:	5b                   	pop    %ebx
  800198:	5e                   	pop    %esi
  800199:	5f                   	pop    %edi
  80019a:	5d                   	pop    %ebp
  80019b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80019c:	83 ec 0c             	sub    $0xc,%esp
  80019f:	50                   	push   %eax
  8001a0:	6a 04                	push   $0x4
  8001a2:	68 2a 1e 80 00       	push   $0x801e2a
  8001a7:	6a 2a                	push   $0x2a
  8001a9:	68 47 1e 80 00       	push   $0x801e47
  8001ae:	e8 75 0e 00 00       	call   801028 <_panic>

008001b3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b3:	55                   	push   %ebp
  8001b4:	89 e5                	mov    %esp,%ebp
  8001b6:	57                   	push   %edi
  8001b7:	56                   	push   %esi
  8001b8:	53                   	push   %ebx
  8001b9:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8001bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c2:	b8 05 00 00 00       	mov    $0x5,%eax
  8001c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ca:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001cd:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d0:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001d2:	85 c0                	test   %eax,%eax
  8001d4:	7f 08                	jg     8001de <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d9:	5b                   	pop    %ebx
  8001da:	5e                   	pop    %esi
  8001db:	5f                   	pop    %edi
  8001dc:	5d                   	pop    %ebp
  8001dd:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001de:	83 ec 0c             	sub    $0xc,%esp
  8001e1:	50                   	push   %eax
  8001e2:	6a 05                	push   $0x5
  8001e4:	68 2a 1e 80 00       	push   $0x801e2a
  8001e9:	6a 2a                	push   $0x2a
  8001eb:	68 47 1e 80 00       	push   $0x801e47
  8001f0:	e8 33 0e 00 00       	call   801028 <_panic>

008001f5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f5:	55                   	push   %ebp
  8001f6:	89 e5                	mov    %esp,%ebp
  8001f8:	57                   	push   %edi
  8001f9:	56                   	push   %esi
  8001fa:	53                   	push   %ebx
  8001fb:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800203:	8b 55 08             	mov    0x8(%ebp),%edx
  800206:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800209:	b8 06 00 00 00       	mov    $0x6,%eax
  80020e:	89 df                	mov    %ebx,%edi
  800210:	89 de                	mov    %ebx,%esi
  800212:	cd 30                	int    $0x30
	if(check && ret > 0)
  800214:	85 c0                	test   %eax,%eax
  800216:	7f 08                	jg     800220 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800218:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021b:	5b                   	pop    %ebx
  80021c:	5e                   	pop    %esi
  80021d:	5f                   	pop    %edi
  80021e:	5d                   	pop    %ebp
  80021f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800220:	83 ec 0c             	sub    $0xc,%esp
  800223:	50                   	push   %eax
  800224:	6a 06                	push   $0x6
  800226:	68 2a 1e 80 00       	push   $0x801e2a
  80022b:	6a 2a                	push   $0x2a
  80022d:	68 47 1e 80 00       	push   $0x801e47
  800232:	e8 f1 0d 00 00       	call   801028 <_panic>

00800237 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	57                   	push   %edi
  80023b:	56                   	push   %esi
  80023c:	53                   	push   %ebx
  80023d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800240:	bb 00 00 00 00       	mov    $0x0,%ebx
  800245:	8b 55 08             	mov    0x8(%ebp),%edx
  800248:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024b:	b8 08 00 00 00       	mov    $0x8,%eax
  800250:	89 df                	mov    %ebx,%edi
  800252:	89 de                	mov    %ebx,%esi
  800254:	cd 30                	int    $0x30
	if(check && ret > 0)
  800256:	85 c0                	test   %eax,%eax
  800258:	7f 08                	jg     800262 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025d:	5b                   	pop    %ebx
  80025e:	5e                   	pop    %esi
  80025f:	5f                   	pop    %edi
  800260:	5d                   	pop    %ebp
  800261:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800262:	83 ec 0c             	sub    $0xc,%esp
  800265:	50                   	push   %eax
  800266:	6a 08                	push   $0x8
  800268:	68 2a 1e 80 00       	push   $0x801e2a
  80026d:	6a 2a                	push   $0x2a
  80026f:	68 47 1e 80 00       	push   $0x801e47
  800274:	e8 af 0d 00 00       	call   801028 <_panic>

00800279 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800279:	55                   	push   %ebp
  80027a:	89 e5                	mov    %esp,%ebp
  80027c:	57                   	push   %edi
  80027d:	56                   	push   %esi
  80027e:	53                   	push   %ebx
  80027f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800282:	bb 00 00 00 00       	mov    $0x0,%ebx
  800287:	8b 55 08             	mov    0x8(%ebp),%edx
  80028a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80028d:	b8 09 00 00 00       	mov    $0x9,%eax
  800292:	89 df                	mov    %ebx,%edi
  800294:	89 de                	mov    %ebx,%esi
  800296:	cd 30                	int    $0x30
	if(check && ret > 0)
  800298:	85 c0                	test   %eax,%eax
  80029a:	7f 08                	jg     8002a4 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80029c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80029f:	5b                   	pop    %ebx
  8002a0:	5e                   	pop    %esi
  8002a1:	5f                   	pop    %edi
  8002a2:	5d                   	pop    %ebp
  8002a3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a4:	83 ec 0c             	sub    $0xc,%esp
  8002a7:	50                   	push   %eax
  8002a8:	6a 09                	push   $0x9
  8002aa:	68 2a 1e 80 00       	push   $0x801e2a
  8002af:	6a 2a                	push   $0x2a
  8002b1:	68 47 1e 80 00       	push   $0x801e47
  8002b6:	e8 6d 0d 00 00       	call   801028 <_panic>

008002bb <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002bb:	55                   	push   %ebp
  8002bc:	89 e5                	mov    %esp,%ebp
  8002be:	57                   	push   %edi
  8002bf:	56                   	push   %esi
  8002c0:	53                   	push   %ebx
  8002c1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002c4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cf:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002d4:	89 df                	mov    %ebx,%edi
  8002d6:	89 de                	mov    %ebx,%esi
  8002d8:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002da:	85 c0                	test   %eax,%eax
  8002dc:	7f 08                	jg     8002e6 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
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
  8002ea:	6a 0a                	push   $0xa
  8002ec:	68 2a 1e 80 00       	push   $0x801e2a
  8002f1:	6a 2a                	push   $0x2a
  8002f3:	68 47 1e 80 00       	push   $0x801e47
  8002f8:	e8 2b 0d 00 00       	call   801028 <_panic>

008002fd <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002fd:	55                   	push   %ebp
  8002fe:	89 e5                	mov    %esp,%ebp
  800300:	57                   	push   %edi
  800301:	56                   	push   %esi
  800302:	53                   	push   %ebx
	asm volatile("int %1\n"
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800309:	b8 0c 00 00 00       	mov    $0xc,%eax
  80030e:	be 00 00 00 00       	mov    $0x0,%esi
  800313:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800316:	8b 7d 14             	mov    0x14(%ebp),%edi
  800319:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031b:	5b                   	pop    %ebx
  80031c:	5e                   	pop    %esi
  80031d:	5f                   	pop    %edi
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	57                   	push   %edi
  800324:	56                   	push   %esi
  800325:	53                   	push   %ebx
  800326:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800329:	b9 00 00 00 00       	mov    $0x0,%ecx
  80032e:	8b 55 08             	mov    0x8(%ebp),%edx
  800331:	b8 0d 00 00 00       	mov    $0xd,%eax
  800336:	89 cb                	mov    %ecx,%ebx
  800338:	89 cf                	mov    %ecx,%edi
  80033a:	89 ce                	mov    %ecx,%esi
  80033c:	cd 30                	int    $0x30
	if(check && ret > 0)
  80033e:	85 c0                	test   %eax,%eax
  800340:	7f 08                	jg     80034a <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800342:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800345:	5b                   	pop    %ebx
  800346:	5e                   	pop    %esi
  800347:	5f                   	pop    %edi
  800348:	5d                   	pop    %ebp
  800349:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80034a:	83 ec 0c             	sub    $0xc,%esp
  80034d:	50                   	push   %eax
  80034e:	6a 0d                	push   $0xd
  800350:	68 2a 1e 80 00       	push   $0x801e2a
  800355:	6a 2a                	push   $0x2a
  800357:	68 47 1e 80 00       	push   $0x801e47
  80035c:	e8 c7 0c 00 00       	call   801028 <_panic>

00800361 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800361:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800362:	a1 04 60 80 00       	mov    0x806004,%eax
	call *%eax
  800367:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800369:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  80036c:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  800370:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  800373:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  800377:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  80037b:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  80037d:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  800380:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  800381:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  800384:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  800385:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  800386:	c3                   	ret    

00800387 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800387:	55                   	push   %ebp
  800388:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80038a:	8b 45 08             	mov    0x8(%ebp),%eax
  80038d:	05 00 00 00 30       	add    $0x30000000,%eax
  800392:	c1 e8 0c             	shr    $0xc,%eax
}
  800395:	5d                   	pop    %ebp
  800396:	c3                   	ret    

00800397 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800397:	55                   	push   %ebp
  800398:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80039a:	8b 45 08             	mov    0x8(%ebp),%eax
  80039d:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003a7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003b6:	89 c2                	mov    %eax,%edx
  8003b8:	c1 ea 16             	shr    $0x16,%edx
  8003bb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003c2:	f6 c2 01             	test   $0x1,%dl
  8003c5:	74 29                	je     8003f0 <fd_alloc+0x42>
  8003c7:	89 c2                	mov    %eax,%edx
  8003c9:	c1 ea 0c             	shr    $0xc,%edx
  8003cc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003d3:	f6 c2 01             	test   $0x1,%dl
  8003d6:	74 18                	je     8003f0 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8003d8:	05 00 10 00 00       	add    $0x1000,%eax
  8003dd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003e2:	75 d2                	jne    8003b6 <fd_alloc+0x8>
  8003e4:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8003e9:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8003ee:	eb 05                	jmp    8003f5 <fd_alloc+0x47>
			return 0;
  8003f0:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8003f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8003f8:	89 02                	mov    %eax,(%edx)
}
  8003fa:	89 c8                	mov    %ecx,%eax
  8003fc:	5d                   	pop    %ebp
  8003fd:	c3                   	ret    

008003fe <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800404:	83 f8 1f             	cmp    $0x1f,%eax
  800407:	77 30                	ja     800439 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800409:	c1 e0 0c             	shl    $0xc,%eax
  80040c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800411:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800417:	f6 c2 01             	test   $0x1,%dl
  80041a:	74 24                	je     800440 <fd_lookup+0x42>
  80041c:	89 c2                	mov    %eax,%edx
  80041e:	c1 ea 0c             	shr    $0xc,%edx
  800421:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800428:	f6 c2 01             	test   $0x1,%dl
  80042b:	74 1a                	je     800447 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80042d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800430:	89 02                	mov    %eax,(%edx)
	return 0;
  800432:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800437:	5d                   	pop    %ebp
  800438:	c3                   	ret    
		return -E_INVAL;
  800439:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80043e:	eb f7                	jmp    800437 <fd_lookup+0x39>
		return -E_INVAL;
  800440:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800445:	eb f0                	jmp    800437 <fd_lookup+0x39>
  800447:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80044c:	eb e9                	jmp    800437 <fd_lookup+0x39>

0080044e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80044e:	55                   	push   %ebp
  80044f:	89 e5                	mov    %esp,%ebp
  800451:	53                   	push   %ebx
  800452:	83 ec 04             	sub    $0x4,%esp
  800455:	8b 55 08             	mov    0x8(%ebp),%edx
  800458:	b8 d4 1e 80 00       	mov    $0x801ed4,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  80045d:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800462:	39 13                	cmp    %edx,(%ebx)
  800464:	74 32                	je     800498 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800466:	83 c0 04             	add    $0x4,%eax
  800469:	8b 18                	mov    (%eax),%ebx
  80046b:	85 db                	test   %ebx,%ebx
  80046d:	75 f3                	jne    800462 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80046f:	a1 00 40 80 00       	mov    0x804000,%eax
  800474:	8b 40 48             	mov    0x48(%eax),%eax
  800477:	83 ec 04             	sub    $0x4,%esp
  80047a:	52                   	push   %edx
  80047b:	50                   	push   %eax
  80047c:	68 58 1e 80 00       	push   $0x801e58
  800481:	e8 7d 0c 00 00       	call   801103 <cprintf>
	*dev = 0;
	return -E_INVAL;
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  80048e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800491:	89 1a                	mov    %ebx,(%edx)
}
  800493:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800496:	c9                   	leave  
  800497:	c3                   	ret    
			return 0;
  800498:	b8 00 00 00 00       	mov    $0x0,%eax
  80049d:	eb ef                	jmp    80048e <dev_lookup+0x40>

0080049f <fd_close>:
{
  80049f:	55                   	push   %ebp
  8004a0:	89 e5                	mov    %esp,%ebp
  8004a2:	57                   	push   %edi
  8004a3:	56                   	push   %esi
  8004a4:	53                   	push   %ebx
  8004a5:	83 ec 24             	sub    $0x24,%esp
  8004a8:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ab:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004ae:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004b1:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004b2:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004b8:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004bb:	50                   	push   %eax
  8004bc:	e8 3d ff ff ff       	call   8003fe <fd_lookup>
  8004c1:	89 c3                	mov    %eax,%ebx
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	78 05                	js     8004cf <fd_close+0x30>
	    || fd != fd2)
  8004ca:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004cd:	74 16                	je     8004e5 <fd_close+0x46>
		return (must_exist ? r : 0);
  8004cf:	89 f8                	mov    %edi,%eax
  8004d1:	84 c0                	test   %al,%al
  8004d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8004d8:	0f 44 d8             	cmove  %eax,%ebx
}
  8004db:	89 d8                	mov    %ebx,%eax
  8004dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004e0:	5b                   	pop    %ebx
  8004e1:	5e                   	pop    %esi
  8004e2:	5f                   	pop    %edi
  8004e3:	5d                   	pop    %ebp
  8004e4:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004e5:	83 ec 08             	sub    $0x8,%esp
  8004e8:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004eb:	50                   	push   %eax
  8004ec:	ff 36                	push   (%esi)
  8004ee:	e8 5b ff ff ff       	call   80044e <dev_lookup>
  8004f3:	89 c3                	mov    %eax,%ebx
  8004f5:	83 c4 10             	add    $0x10,%esp
  8004f8:	85 c0                	test   %eax,%eax
  8004fa:	78 1a                	js     800516 <fd_close+0x77>
		if (dev->dev_close)
  8004fc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ff:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800502:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800507:	85 c0                	test   %eax,%eax
  800509:	74 0b                	je     800516 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80050b:	83 ec 0c             	sub    $0xc,%esp
  80050e:	56                   	push   %esi
  80050f:	ff d0                	call   *%eax
  800511:	89 c3                	mov    %eax,%ebx
  800513:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800516:	83 ec 08             	sub    $0x8,%esp
  800519:	56                   	push   %esi
  80051a:	6a 00                	push   $0x0
  80051c:	e8 d4 fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800521:	83 c4 10             	add    $0x10,%esp
  800524:	eb b5                	jmp    8004db <fd_close+0x3c>

00800526 <close>:

int
close(int fdnum)
{
  800526:	55                   	push   %ebp
  800527:	89 e5                	mov    %esp,%ebp
  800529:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80052c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80052f:	50                   	push   %eax
  800530:	ff 75 08             	push   0x8(%ebp)
  800533:	e8 c6 fe ff ff       	call   8003fe <fd_lookup>
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	85 c0                	test   %eax,%eax
  80053d:	79 02                	jns    800541 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80053f:	c9                   	leave  
  800540:	c3                   	ret    
		return fd_close(fd, 1);
  800541:	83 ec 08             	sub    $0x8,%esp
  800544:	6a 01                	push   $0x1
  800546:	ff 75 f4             	push   -0xc(%ebp)
  800549:	e8 51 ff ff ff       	call   80049f <fd_close>
  80054e:	83 c4 10             	add    $0x10,%esp
  800551:	eb ec                	jmp    80053f <close+0x19>

00800553 <close_all>:

void
close_all(void)
{
  800553:	55                   	push   %ebp
  800554:	89 e5                	mov    %esp,%ebp
  800556:	53                   	push   %ebx
  800557:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80055a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80055f:	83 ec 0c             	sub    $0xc,%esp
  800562:	53                   	push   %ebx
  800563:	e8 be ff ff ff       	call   800526 <close>
	for (i = 0; i < MAXFD; i++)
  800568:	83 c3 01             	add    $0x1,%ebx
  80056b:	83 c4 10             	add    $0x10,%esp
  80056e:	83 fb 20             	cmp    $0x20,%ebx
  800571:	75 ec                	jne    80055f <close_all+0xc>
}
  800573:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800576:	c9                   	leave  
  800577:	c3                   	ret    

00800578 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800578:	55                   	push   %ebp
  800579:	89 e5                	mov    %esp,%ebp
  80057b:	57                   	push   %edi
  80057c:	56                   	push   %esi
  80057d:	53                   	push   %ebx
  80057e:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800581:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800584:	50                   	push   %eax
  800585:	ff 75 08             	push   0x8(%ebp)
  800588:	e8 71 fe ff ff       	call   8003fe <fd_lookup>
  80058d:	89 c3                	mov    %eax,%ebx
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	85 c0                	test   %eax,%eax
  800594:	78 7f                	js     800615 <dup+0x9d>
		return r;
	close(newfdnum);
  800596:	83 ec 0c             	sub    $0xc,%esp
  800599:	ff 75 0c             	push   0xc(%ebp)
  80059c:	e8 85 ff ff ff       	call   800526 <close>

	newfd = INDEX2FD(newfdnum);
  8005a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005a4:	c1 e6 0c             	shl    $0xc,%esi
  8005a7:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b0:	89 3c 24             	mov    %edi,(%esp)
  8005b3:	e8 df fd ff ff       	call   800397 <fd2data>
  8005b8:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005ba:	89 34 24             	mov    %esi,(%esp)
  8005bd:	e8 d5 fd ff ff       	call   800397 <fd2data>
  8005c2:	83 c4 10             	add    $0x10,%esp
  8005c5:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005c8:	89 d8                	mov    %ebx,%eax
  8005ca:	c1 e8 16             	shr    $0x16,%eax
  8005cd:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005d4:	a8 01                	test   $0x1,%al
  8005d6:	74 11                	je     8005e9 <dup+0x71>
  8005d8:	89 d8                	mov    %ebx,%eax
  8005da:	c1 e8 0c             	shr    $0xc,%eax
  8005dd:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005e4:	f6 c2 01             	test   $0x1,%dl
  8005e7:	75 36                	jne    80061f <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e9:	89 f8                	mov    %edi,%eax
  8005eb:	c1 e8 0c             	shr    $0xc,%eax
  8005ee:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f5:	83 ec 0c             	sub    $0xc,%esp
  8005f8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005fd:	50                   	push   %eax
  8005fe:	56                   	push   %esi
  8005ff:	6a 00                	push   $0x0
  800601:	57                   	push   %edi
  800602:	6a 00                	push   $0x0
  800604:	e8 aa fb ff ff       	call   8001b3 <sys_page_map>
  800609:	89 c3                	mov    %eax,%ebx
  80060b:	83 c4 20             	add    $0x20,%esp
  80060e:	85 c0                	test   %eax,%eax
  800610:	78 33                	js     800645 <dup+0xcd>
		goto err;

	return newfdnum;
  800612:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800615:	89 d8                	mov    %ebx,%eax
  800617:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80061a:	5b                   	pop    %ebx
  80061b:	5e                   	pop    %esi
  80061c:	5f                   	pop    %edi
  80061d:	5d                   	pop    %ebp
  80061e:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80061f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800626:	83 ec 0c             	sub    $0xc,%esp
  800629:	25 07 0e 00 00       	and    $0xe07,%eax
  80062e:	50                   	push   %eax
  80062f:	ff 75 d4             	push   -0x2c(%ebp)
  800632:	6a 00                	push   $0x0
  800634:	53                   	push   %ebx
  800635:	6a 00                	push   $0x0
  800637:	e8 77 fb ff ff       	call   8001b3 <sys_page_map>
  80063c:	89 c3                	mov    %eax,%ebx
  80063e:	83 c4 20             	add    $0x20,%esp
  800641:	85 c0                	test   %eax,%eax
  800643:	79 a4                	jns    8005e9 <dup+0x71>
	sys_page_unmap(0, newfd);
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	56                   	push   %esi
  800649:	6a 00                	push   $0x0
  80064b:	e8 a5 fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800650:	83 c4 08             	add    $0x8,%esp
  800653:	ff 75 d4             	push   -0x2c(%ebp)
  800656:	6a 00                	push   $0x0
  800658:	e8 98 fb ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  80065d:	83 c4 10             	add    $0x10,%esp
  800660:	eb b3                	jmp    800615 <dup+0x9d>

00800662 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800662:	55                   	push   %ebp
  800663:	89 e5                	mov    %esp,%ebp
  800665:	56                   	push   %esi
  800666:	53                   	push   %ebx
  800667:	83 ec 18             	sub    $0x18,%esp
  80066a:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80066d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800670:	50                   	push   %eax
  800671:	56                   	push   %esi
  800672:	e8 87 fd ff ff       	call   8003fe <fd_lookup>
  800677:	83 c4 10             	add    $0x10,%esp
  80067a:	85 c0                	test   %eax,%eax
  80067c:	78 3c                	js     8006ba <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80067e:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800687:	50                   	push   %eax
  800688:	ff 33                	push   (%ebx)
  80068a:	e8 bf fd ff ff       	call   80044e <dev_lookup>
  80068f:	83 c4 10             	add    $0x10,%esp
  800692:	85 c0                	test   %eax,%eax
  800694:	78 24                	js     8006ba <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800696:	8b 43 08             	mov    0x8(%ebx),%eax
  800699:	83 e0 03             	and    $0x3,%eax
  80069c:	83 f8 01             	cmp    $0x1,%eax
  80069f:	74 20                	je     8006c1 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006a4:	8b 40 08             	mov    0x8(%eax),%eax
  8006a7:	85 c0                	test   %eax,%eax
  8006a9:	74 37                	je     8006e2 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006ab:	83 ec 04             	sub    $0x4,%esp
  8006ae:	ff 75 10             	push   0x10(%ebp)
  8006b1:	ff 75 0c             	push   0xc(%ebp)
  8006b4:	53                   	push   %ebx
  8006b5:	ff d0                	call   *%eax
  8006b7:	83 c4 10             	add    $0x10,%esp
}
  8006ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006bd:	5b                   	pop    %ebx
  8006be:	5e                   	pop    %esi
  8006bf:	5d                   	pop    %ebp
  8006c0:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006c1:	a1 00 40 80 00       	mov    0x804000,%eax
  8006c6:	8b 40 48             	mov    0x48(%eax),%eax
  8006c9:	83 ec 04             	sub    $0x4,%esp
  8006cc:	56                   	push   %esi
  8006cd:	50                   	push   %eax
  8006ce:	68 99 1e 80 00       	push   $0x801e99
  8006d3:	e8 2b 0a 00 00       	call   801103 <cprintf>
		return -E_INVAL;
  8006d8:	83 c4 10             	add    $0x10,%esp
  8006db:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006e0:	eb d8                	jmp    8006ba <read+0x58>
		return -E_NOT_SUPP;
  8006e2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006e7:	eb d1                	jmp    8006ba <read+0x58>

008006e9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	57                   	push   %edi
  8006ed:	56                   	push   %esi
  8006ee:	53                   	push   %ebx
  8006ef:	83 ec 0c             	sub    $0xc,%esp
  8006f2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006f5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006fd:	eb 02                	jmp    800701 <readn+0x18>
  8006ff:	01 c3                	add    %eax,%ebx
  800701:	39 f3                	cmp    %esi,%ebx
  800703:	73 21                	jae    800726 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800705:	83 ec 04             	sub    $0x4,%esp
  800708:	89 f0                	mov    %esi,%eax
  80070a:	29 d8                	sub    %ebx,%eax
  80070c:	50                   	push   %eax
  80070d:	89 d8                	mov    %ebx,%eax
  80070f:	03 45 0c             	add    0xc(%ebp),%eax
  800712:	50                   	push   %eax
  800713:	57                   	push   %edi
  800714:	e8 49 ff ff ff       	call   800662 <read>
		if (m < 0)
  800719:	83 c4 10             	add    $0x10,%esp
  80071c:	85 c0                	test   %eax,%eax
  80071e:	78 04                	js     800724 <readn+0x3b>
			return m;
		if (m == 0)
  800720:	75 dd                	jne    8006ff <readn+0x16>
  800722:	eb 02                	jmp    800726 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800724:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800726:	89 d8                	mov    %ebx,%eax
  800728:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80072b:	5b                   	pop    %ebx
  80072c:	5e                   	pop    %esi
  80072d:	5f                   	pop    %edi
  80072e:	5d                   	pop    %ebp
  80072f:	c3                   	ret    

00800730 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	56                   	push   %esi
  800734:	53                   	push   %ebx
  800735:	83 ec 18             	sub    $0x18,%esp
  800738:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80073b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80073e:	50                   	push   %eax
  80073f:	53                   	push   %ebx
  800740:	e8 b9 fc ff ff       	call   8003fe <fd_lookup>
  800745:	83 c4 10             	add    $0x10,%esp
  800748:	85 c0                	test   %eax,%eax
  80074a:	78 37                	js     800783 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80074c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80074f:	83 ec 08             	sub    $0x8,%esp
  800752:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800755:	50                   	push   %eax
  800756:	ff 36                	push   (%esi)
  800758:	e8 f1 fc ff ff       	call   80044e <dev_lookup>
  80075d:	83 c4 10             	add    $0x10,%esp
  800760:	85 c0                	test   %eax,%eax
  800762:	78 1f                	js     800783 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800764:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800768:	74 20                	je     80078a <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80076a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80076d:	8b 40 0c             	mov    0xc(%eax),%eax
  800770:	85 c0                	test   %eax,%eax
  800772:	74 37                	je     8007ab <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800774:	83 ec 04             	sub    $0x4,%esp
  800777:	ff 75 10             	push   0x10(%ebp)
  80077a:	ff 75 0c             	push   0xc(%ebp)
  80077d:	56                   	push   %esi
  80077e:	ff d0                	call   *%eax
  800780:	83 c4 10             	add    $0x10,%esp
}
  800783:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800786:	5b                   	pop    %ebx
  800787:	5e                   	pop    %esi
  800788:	5d                   	pop    %ebp
  800789:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80078a:	a1 00 40 80 00       	mov    0x804000,%eax
  80078f:	8b 40 48             	mov    0x48(%eax),%eax
  800792:	83 ec 04             	sub    $0x4,%esp
  800795:	53                   	push   %ebx
  800796:	50                   	push   %eax
  800797:	68 b5 1e 80 00       	push   $0x801eb5
  80079c:	e8 62 09 00 00       	call   801103 <cprintf>
		return -E_INVAL;
  8007a1:	83 c4 10             	add    $0x10,%esp
  8007a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007a9:	eb d8                	jmp    800783 <write+0x53>
		return -E_NOT_SUPP;
  8007ab:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007b0:	eb d1                	jmp    800783 <write+0x53>

008007b2 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b2:	55                   	push   %ebp
  8007b3:	89 e5                	mov    %esp,%ebp
  8007b5:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007bb:	50                   	push   %eax
  8007bc:	ff 75 08             	push   0x8(%ebp)
  8007bf:	e8 3a fc ff ff       	call   8003fe <fd_lookup>
  8007c4:	83 c4 10             	add    $0x10,%esp
  8007c7:	85 c0                	test   %eax,%eax
  8007c9:	78 0e                	js     8007d9 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007d9:	c9                   	leave  
  8007da:	c3                   	ret    

008007db <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	56                   	push   %esi
  8007df:	53                   	push   %ebx
  8007e0:	83 ec 18             	sub    $0x18,%esp
  8007e3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007e9:	50                   	push   %eax
  8007ea:	53                   	push   %ebx
  8007eb:	e8 0e fc ff ff       	call   8003fe <fd_lookup>
  8007f0:	83 c4 10             	add    $0x10,%esp
  8007f3:	85 c0                	test   %eax,%eax
  8007f5:	78 34                	js     80082b <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007f7:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800800:	50                   	push   %eax
  800801:	ff 36                	push   (%esi)
  800803:	e8 46 fc ff ff       	call   80044e <dev_lookup>
  800808:	83 c4 10             	add    $0x10,%esp
  80080b:	85 c0                	test   %eax,%eax
  80080d:	78 1c                	js     80082b <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80080f:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800813:	74 1d                	je     800832 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800815:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800818:	8b 40 18             	mov    0x18(%eax),%eax
  80081b:	85 c0                	test   %eax,%eax
  80081d:	74 34                	je     800853 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	ff 75 0c             	push   0xc(%ebp)
  800825:	56                   	push   %esi
  800826:	ff d0                	call   *%eax
  800828:	83 c4 10             	add    $0x10,%esp
}
  80082b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80082e:	5b                   	pop    %ebx
  80082f:	5e                   	pop    %esi
  800830:	5d                   	pop    %ebp
  800831:	c3                   	ret    
			thisenv->env_id, fdnum);
  800832:	a1 00 40 80 00       	mov    0x804000,%eax
  800837:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80083a:	83 ec 04             	sub    $0x4,%esp
  80083d:	53                   	push   %ebx
  80083e:	50                   	push   %eax
  80083f:	68 78 1e 80 00       	push   $0x801e78
  800844:	e8 ba 08 00 00       	call   801103 <cprintf>
		return -E_INVAL;
  800849:	83 c4 10             	add    $0x10,%esp
  80084c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800851:	eb d8                	jmp    80082b <ftruncate+0x50>
		return -E_NOT_SUPP;
  800853:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800858:	eb d1                	jmp    80082b <ftruncate+0x50>

0080085a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	56                   	push   %esi
  80085e:	53                   	push   %ebx
  80085f:	83 ec 18             	sub    $0x18,%esp
  800862:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800865:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800868:	50                   	push   %eax
  800869:	ff 75 08             	push   0x8(%ebp)
  80086c:	e8 8d fb ff ff       	call   8003fe <fd_lookup>
  800871:	83 c4 10             	add    $0x10,%esp
  800874:	85 c0                	test   %eax,%eax
  800876:	78 49                	js     8008c1 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800878:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80087b:	83 ec 08             	sub    $0x8,%esp
  80087e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800881:	50                   	push   %eax
  800882:	ff 36                	push   (%esi)
  800884:	e8 c5 fb ff ff       	call   80044e <dev_lookup>
  800889:	83 c4 10             	add    $0x10,%esp
  80088c:	85 c0                	test   %eax,%eax
  80088e:	78 31                	js     8008c1 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  800890:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800893:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800897:	74 2f                	je     8008c8 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800899:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80089c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008a3:	00 00 00 
	stat->st_isdir = 0;
  8008a6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ad:	00 00 00 
	stat->st_dev = dev;
  8008b0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008b6:	83 ec 08             	sub    $0x8,%esp
  8008b9:	53                   	push   %ebx
  8008ba:	56                   	push   %esi
  8008bb:	ff 50 14             	call   *0x14(%eax)
  8008be:	83 c4 10             	add    $0x10,%esp
}
  8008c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008c4:	5b                   	pop    %ebx
  8008c5:	5e                   	pop    %esi
  8008c6:	5d                   	pop    %ebp
  8008c7:	c3                   	ret    
		return -E_NOT_SUPP;
  8008c8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008cd:	eb f2                	jmp    8008c1 <fstat+0x67>

008008cf <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008cf:	55                   	push   %ebp
  8008d0:	89 e5                	mov    %esp,%ebp
  8008d2:	56                   	push   %esi
  8008d3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008d4:	83 ec 08             	sub    $0x8,%esp
  8008d7:	6a 00                	push   $0x0
  8008d9:	ff 75 08             	push   0x8(%ebp)
  8008dc:	e8 e4 01 00 00       	call   800ac5 <open>
  8008e1:	89 c3                	mov    %eax,%ebx
  8008e3:	83 c4 10             	add    $0x10,%esp
  8008e6:	85 c0                	test   %eax,%eax
  8008e8:	78 1b                	js     800905 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008ea:	83 ec 08             	sub    $0x8,%esp
  8008ed:	ff 75 0c             	push   0xc(%ebp)
  8008f0:	50                   	push   %eax
  8008f1:	e8 64 ff ff ff       	call   80085a <fstat>
  8008f6:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f8:	89 1c 24             	mov    %ebx,(%esp)
  8008fb:	e8 26 fc ff ff       	call   800526 <close>
	return r;
  800900:	83 c4 10             	add    $0x10,%esp
  800903:	89 f3                	mov    %esi,%ebx
}
  800905:	89 d8                	mov    %ebx,%eax
  800907:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80090a:	5b                   	pop    %ebx
  80090b:	5e                   	pop    %esi
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80090e:	55                   	push   %ebp
  80090f:	89 e5                	mov    %esp,%ebp
  800911:	56                   	push   %esi
  800912:	53                   	push   %ebx
  800913:	89 c6                	mov    %eax,%esi
  800915:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800917:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80091e:	74 27                	je     800947 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800920:	6a 07                	push   $0x7
  800922:	68 00 50 80 00       	push   $0x805000
  800927:	56                   	push   %esi
  800928:	ff 35 00 60 80 00    	push   0x806000
  80092e:	e8 c7 11 00 00       	call   801afa <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800933:	83 c4 0c             	add    $0xc,%esp
  800936:	6a 00                	push   $0x0
  800938:	53                   	push   %ebx
  800939:	6a 00                	push   $0x0
  80093b:	e8 53 11 00 00       	call   801a93 <ipc_recv>
}
  800940:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800943:	5b                   	pop    %ebx
  800944:	5e                   	pop    %esi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800947:	83 ec 0c             	sub    $0xc,%esp
  80094a:	6a 01                	push   $0x1
  80094c:	e8 fd 11 00 00       	call   801b4e <ipc_find_env>
  800951:	a3 00 60 80 00       	mov    %eax,0x806000
  800956:	83 c4 10             	add    $0x10,%esp
  800959:	eb c5                	jmp    800920 <fsipc+0x12>

0080095b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80095b:	55                   	push   %ebp
  80095c:	89 e5                	mov    %esp,%ebp
  80095e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800961:	8b 45 08             	mov    0x8(%ebp),%eax
  800964:	8b 40 0c             	mov    0xc(%eax),%eax
  800967:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80096c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800974:	ba 00 00 00 00       	mov    $0x0,%edx
  800979:	b8 02 00 00 00       	mov    $0x2,%eax
  80097e:	e8 8b ff ff ff       	call   80090e <fsipc>
}
  800983:	c9                   	leave  
  800984:	c3                   	ret    

00800985 <devfile_flush>:
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8b 40 0c             	mov    0xc(%eax),%eax
  800991:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800996:	ba 00 00 00 00       	mov    $0x0,%edx
  80099b:	b8 06 00 00 00       	mov    $0x6,%eax
  8009a0:	e8 69 ff ff ff       	call   80090e <fsipc>
}
  8009a5:	c9                   	leave  
  8009a6:	c3                   	ret    

008009a7 <devfile_stat>:
{
  8009a7:	55                   	push   %ebp
  8009a8:	89 e5                	mov    %esp,%ebp
  8009aa:	53                   	push   %ebx
  8009ab:	83 ec 04             	sub    $0x4,%esp
  8009ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c1:	b8 05 00 00 00       	mov    $0x5,%eax
  8009c6:	e8 43 ff ff ff       	call   80090e <fsipc>
  8009cb:	85 c0                	test   %eax,%eax
  8009cd:	78 2c                	js     8009fb <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009cf:	83 ec 08             	sub    $0x8,%esp
  8009d2:	68 00 50 80 00       	push   $0x805000
  8009d7:	53                   	push   %ebx
  8009d8:	e8 00 0d 00 00       	call   8016dd <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009dd:	a1 80 50 80 00       	mov    0x805080,%eax
  8009e2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009e8:	a1 84 50 80 00       	mov    0x805084,%eax
  8009ed:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009f3:	83 c4 10             	add    $0x10,%esp
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009fe:	c9                   	leave  
  8009ff:	c3                   	ret    

00800a00 <devfile_write>:
{
  800a00:	55                   	push   %ebp
  800a01:	89 e5                	mov    %esp,%ebp
  800a03:	83 ec 0c             	sub    $0xc,%esp
  800a06:	8b 45 10             	mov    0x10(%ebp),%eax
  800a09:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a0e:	39 d0                	cmp    %edx,%eax
  800a10:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a13:	8b 55 08             	mov    0x8(%ebp),%edx
  800a16:	8b 52 0c             	mov    0xc(%edx),%edx
  800a19:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a1f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a24:	50                   	push   %eax
  800a25:	ff 75 0c             	push   0xc(%ebp)
  800a28:	68 08 50 80 00       	push   $0x805008
  800a2d:	e8 41 0e 00 00       	call   801873 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800a32:	ba 00 00 00 00       	mov    $0x0,%edx
  800a37:	b8 04 00 00 00       	mov    $0x4,%eax
  800a3c:	e8 cd fe ff ff       	call   80090e <fsipc>
}
  800a41:	c9                   	leave  
  800a42:	c3                   	ret    

00800a43 <devfile_read>:
{
  800a43:	55                   	push   %ebp
  800a44:	89 e5                	mov    %esp,%ebp
  800a46:	56                   	push   %esi
  800a47:	53                   	push   %ebx
  800a48:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a51:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a56:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a5c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a61:	b8 03 00 00 00       	mov    $0x3,%eax
  800a66:	e8 a3 fe ff ff       	call   80090e <fsipc>
  800a6b:	89 c3                	mov    %eax,%ebx
  800a6d:	85 c0                	test   %eax,%eax
  800a6f:	78 1f                	js     800a90 <devfile_read+0x4d>
	assert(r <= n);
  800a71:	39 f0                	cmp    %esi,%eax
  800a73:	77 24                	ja     800a99 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a75:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a7a:	7f 33                	jg     800aaf <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a7c:	83 ec 04             	sub    $0x4,%esp
  800a7f:	50                   	push   %eax
  800a80:	68 00 50 80 00       	push   $0x805000
  800a85:	ff 75 0c             	push   0xc(%ebp)
  800a88:	e8 e6 0d 00 00       	call   801873 <memmove>
	return r;
  800a8d:	83 c4 10             	add    $0x10,%esp
}
  800a90:	89 d8                	mov    %ebx,%eax
  800a92:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    
	assert(r <= n);
  800a99:	68 e4 1e 80 00       	push   $0x801ee4
  800a9e:	68 eb 1e 80 00       	push   $0x801eeb
  800aa3:	6a 7c                	push   $0x7c
  800aa5:	68 00 1f 80 00       	push   $0x801f00
  800aaa:	e8 79 05 00 00       	call   801028 <_panic>
	assert(r <= PGSIZE);
  800aaf:	68 0b 1f 80 00       	push   $0x801f0b
  800ab4:	68 eb 1e 80 00       	push   $0x801eeb
  800ab9:	6a 7d                	push   $0x7d
  800abb:	68 00 1f 80 00       	push   $0x801f00
  800ac0:	e8 63 05 00 00       	call   801028 <_panic>

00800ac5 <open>:
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	56                   	push   %esi
  800ac9:	53                   	push   %ebx
  800aca:	83 ec 1c             	sub    $0x1c,%esp
  800acd:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800ad0:	56                   	push   %esi
  800ad1:	e8 cc 0b 00 00       	call   8016a2 <strlen>
  800ad6:	83 c4 10             	add    $0x10,%esp
  800ad9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ade:	7f 6c                	jg     800b4c <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800ae0:	83 ec 0c             	sub    $0xc,%esp
  800ae3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ae6:	50                   	push   %eax
  800ae7:	e8 c2 f8 ff ff       	call   8003ae <fd_alloc>
  800aec:	89 c3                	mov    %eax,%ebx
  800aee:	83 c4 10             	add    $0x10,%esp
  800af1:	85 c0                	test   %eax,%eax
  800af3:	78 3c                	js     800b31 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800af5:	83 ec 08             	sub    $0x8,%esp
  800af8:	56                   	push   %esi
  800af9:	68 00 50 80 00       	push   $0x805000
  800afe:	e8 da 0b 00 00       	call   8016dd <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b03:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b06:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b0b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b0e:	b8 01 00 00 00       	mov    $0x1,%eax
  800b13:	e8 f6 fd ff ff       	call   80090e <fsipc>
  800b18:	89 c3                	mov    %eax,%ebx
  800b1a:	83 c4 10             	add    $0x10,%esp
  800b1d:	85 c0                	test   %eax,%eax
  800b1f:	78 19                	js     800b3a <open+0x75>
	return fd2num(fd);
  800b21:	83 ec 0c             	sub    $0xc,%esp
  800b24:	ff 75 f4             	push   -0xc(%ebp)
  800b27:	e8 5b f8 ff ff       	call   800387 <fd2num>
  800b2c:	89 c3                	mov    %eax,%ebx
  800b2e:	83 c4 10             	add    $0x10,%esp
}
  800b31:	89 d8                	mov    %ebx,%eax
  800b33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5d                   	pop    %ebp
  800b39:	c3                   	ret    
		fd_close(fd, 0);
  800b3a:	83 ec 08             	sub    $0x8,%esp
  800b3d:	6a 00                	push   $0x0
  800b3f:	ff 75 f4             	push   -0xc(%ebp)
  800b42:	e8 58 f9 ff ff       	call   80049f <fd_close>
		return r;
  800b47:	83 c4 10             	add    $0x10,%esp
  800b4a:	eb e5                	jmp    800b31 <open+0x6c>
		return -E_BAD_PATH;
  800b4c:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b51:	eb de                	jmp    800b31 <open+0x6c>

00800b53 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b59:	ba 00 00 00 00       	mov    $0x0,%edx
  800b5e:	b8 08 00 00 00       	mov    $0x8,%eax
  800b63:	e8 a6 fd ff ff       	call   80090e <fsipc>
}
  800b68:	c9                   	leave  
  800b69:	c3                   	ret    

00800b6a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
  800b6f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b72:	83 ec 0c             	sub    $0xc,%esp
  800b75:	ff 75 08             	push   0x8(%ebp)
  800b78:	e8 1a f8 ff ff       	call   800397 <fd2data>
  800b7d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b7f:	83 c4 08             	add    $0x8,%esp
  800b82:	68 17 1f 80 00       	push   $0x801f17
  800b87:	53                   	push   %ebx
  800b88:	e8 50 0b 00 00       	call   8016dd <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b8d:	8b 46 04             	mov    0x4(%esi),%eax
  800b90:	2b 06                	sub    (%esi),%eax
  800b92:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b98:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b9f:	00 00 00 
	stat->st_dev = &devpipe;
  800ba2:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800ba9:	30 80 00 
	return 0;
}
  800bac:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bb4:	5b                   	pop    %ebx
  800bb5:	5e                   	pop    %esi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	53                   	push   %ebx
  800bbc:	83 ec 0c             	sub    $0xc,%esp
  800bbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bc2:	53                   	push   %ebx
  800bc3:	6a 00                	push   $0x0
  800bc5:	e8 2b f6 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bca:	89 1c 24             	mov    %ebx,(%esp)
  800bcd:	e8 c5 f7 ff ff       	call   800397 <fd2data>
  800bd2:	83 c4 08             	add    $0x8,%esp
  800bd5:	50                   	push   %eax
  800bd6:	6a 00                	push   $0x0
  800bd8:	e8 18 f6 ff ff       	call   8001f5 <sys_page_unmap>
}
  800bdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800be0:	c9                   	leave  
  800be1:	c3                   	ret    

00800be2 <_pipeisclosed>:
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	83 ec 1c             	sub    $0x1c,%esp
  800beb:	89 c7                	mov    %eax,%edi
  800bed:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bef:	a1 00 40 80 00       	mov    0x804000,%eax
  800bf4:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bf7:	83 ec 0c             	sub    $0xc,%esp
  800bfa:	57                   	push   %edi
  800bfb:	e8 87 0f 00 00       	call   801b87 <pageref>
  800c00:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c03:	89 34 24             	mov    %esi,(%esp)
  800c06:	e8 7c 0f 00 00       	call   801b87 <pageref>
		nn = thisenv->env_runs;
  800c0b:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800c11:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c14:	83 c4 10             	add    $0x10,%esp
  800c17:	39 cb                	cmp    %ecx,%ebx
  800c19:	74 1b                	je     800c36 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c1b:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c1e:	75 cf                	jne    800bef <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c20:	8b 42 58             	mov    0x58(%edx),%eax
  800c23:	6a 01                	push   $0x1
  800c25:	50                   	push   %eax
  800c26:	53                   	push   %ebx
  800c27:	68 1e 1f 80 00       	push   $0x801f1e
  800c2c:	e8 d2 04 00 00       	call   801103 <cprintf>
  800c31:	83 c4 10             	add    $0x10,%esp
  800c34:	eb b9                	jmp    800bef <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c36:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c39:	0f 94 c0             	sete   %al
  800c3c:	0f b6 c0             	movzbl %al,%eax
}
  800c3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c42:	5b                   	pop    %ebx
  800c43:	5e                   	pop    %esi
  800c44:	5f                   	pop    %edi
  800c45:	5d                   	pop    %ebp
  800c46:	c3                   	ret    

00800c47 <devpipe_write>:
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	57                   	push   %edi
  800c4b:	56                   	push   %esi
  800c4c:	53                   	push   %ebx
  800c4d:	83 ec 28             	sub    $0x28,%esp
  800c50:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c53:	56                   	push   %esi
  800c54:	e8 3e f7 ff ff       	call   800397 <fd2data>
  800c59:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c5b:	83 c4 10             	add    $0x10,%esp
  800c5e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c63:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c66:	75 09                	jne    800c71 <devpipe_write+0x2a>
	return i;
  800c68:	89 f8                	mov    %edi,%eax
  800c6a:	eb 23                	jmp    800c8f <devpipe_write+0x48>
			sys_yield();
  800c6c:	e8 e0 f4 ff ff       	call   800151 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c71:	8b 43 04             	mov    0x4(%ebx),%eax
  800c74:	8b 0b                	mov    (%ebx),%ecx
  800c76:	8d 51 20             	lea    0x20(%ecx),%edx
  800c79:	39 d0                	cmp    %edx,%eax
  800c7b:	72 1a                	jb     800c97 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  800c7d:	89 da                	mov    %ebx,%edx
  800c7f:	89 f0                	mov    %esi,%eax
  800c81:	e8 5c ff ff ff       	call   800be2 <_pipeisclosed>
  800c86:	85 c0                	test   %eax,%eax
  800c88:	74 e2                	je     800c6c <devpipe_write+0x25>
				return 0;
  800c8a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c92:	5b                   	pop    %ebx
  800c93:	5e                   	pop    %esi
  800c94:	5f                   	pop    %edi
  800c95:	5d                   	pop    %ebp
  800c96:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c9a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c9e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ca1:	89 c2                	mov    %eax,%edx
  800ca3:	c1 fa 1f             	sar    $0x1f,%edx
  800ca6:	89 d1                	mov    %edx,%ecx
  800ca8:	c1 e9 1b             	shr    $0x1b,%ecx
  800cab:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cae:	83 e2 1f             	and    $0x1f,%edx
  800cb1:	29 ca                	sub    %ecx,%edx
  800cb3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cb7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cbb:	83 c0 01             	add    $0x1,%eax
  800cbe:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cc1:	83 c7 01             	add    $0x1,%edi
  800cc4:	eb 9d                	jmp    800c63 <devpipe_write+0x1c>

00800cc6 <devpipe_read>:
{
  800cc6:	55                   	push   %ebp
  800cc7:	89 e5                	mov    %esp,%ebp
  800cc9:	57                   	push   %edi
  800cca:	56                   	push   %esi
  800ccb:	53                   	push   %ebx
  800ccc:	83 ec 18             	sub    $0x18,%esp
  800ccf:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cd2:	57                   	push   %edi
  800cd3:	e8 bf f6 ff ff       	call   800397 <fd2data>
  800cd8:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cda:	83 c4 10             	add    $0x10,%esp
  800cdd:	be 00 00 00 00       	mov    $0x0,%esi
  800ce2:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ce5:	75 13                	jne    800cfa <devpipe_read+0x34>
	return i;
  800ce7:	89 f0                	mov    %esi,%eax
  800ce9:	eb 02                	jmp    800ced <devpipe_read+0x27>
				return i;
  800ceb:	89 f0                	mov    %esi,%eax
}
  800ced:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    
			sys_yield();
  800cf5:	e8 57 f4 ff ff       	call   800151 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800cfa:	8b 03                	mov    (%ebx),%eax
  800cfc:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cff:	75 18                	jne    800d19 <devpipe_read+0x53>
			if (i > 0)
  800d01:	85 f6                	test   %esi,%esi
  800d03:	75 e6                	jne    800ceb <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  800d05:	89 da                	mov    %ebx,%edx
  800d07:	89 f8                	mov    %edi,%eax
  800d09:	e8 d4 fe ff ff       	call   800be2 <_pipeisclosed>
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	74 e3                	je     800cf5 <devpipe_read+0x2f>
				return 0;
  800d12:	b8 00 00 00 00       	mov    $0x0,%eax
  800d17:	eb d4                	jmp    800ced <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d19:	99                   	cltd   
  800d1a:	c1 ea 1b             	shr    $0x1b,%edx
  800d1d:	01 d0                	add    %edx,%eax
  800d1f:	83 e0 1f             	and    $0x1f,%eax
  800d22:	29 d0                	sub    %edx,%eax
  800d24:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2c:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d2f:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d32:	83 c6 01             	add    $0x1,%esi
  800d35:	eb ab                	jmp    800ce2 <devpipe_read+0x1c>

00800d37 <pipe>:
{
  800d37:	55                   	push   %ebp
  800d38:	89 e5                	mov    %esp,%ebp
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
  800d3c:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d3f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d42:	50                   	push   %eax
  800d43:	e8 66 f6 ff ff       	call   8003ae <fd_alloc>
  800d48:	89 c3                	mov    %eax,%ebx
  800d4a:	83 c4 10             	add    $0x10,%esp
  800d4d:	85 c0                	test   %eax,%eax
  800d4f:	0f 88 23 01 00 00    	js     800e78 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d55:	83 ec 04             	sub    $0x4,%esp
  800d58:	68 07 04 00 00       	push   $0x407
  800d5d:	ff 75 f4             	push   -0xc(%ebp)
  800d60:	6a 00                	push   $0x0
  800d62:	e8 09 f4 ff ff       	call   800170 <sys_page_alloc>
  800d67:	89 c3                	mov    %eax,%ebx
  800d69:	83 c4 10             	add    $0x10,%esp
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	0f 88 04 01 00 00    	js     800e78 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  800d74:	83 ec 0c             	sub    $0xc,%esp
  800d77:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d7a:	50                   	push   %eax
  800d7b:	e8 2e f6 ff ff       	call   8003ae <fd_alloc>
  800d80:	89 c3                	mov    %eax,%ebx
  800d82:	83 c4 10             	add    $0x10,%esp
  800d85:	85 c0                	test   %eax,%eax
  800d87:	0f 88 db 00 00 00    	js     800e68 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8d:	83 ec 04             	sub    $0x4,%esp
  800d90:	68 07 04 00 00       	push   $0x407
  800d95:	ff 75 f0             	push   -0x10(%ebp)
  800d98:	6a 00                	push   $0x0
  800d9a:	e8 d1 f3 ff ff       	call   800170 <sys_page_alloc>
  800d9f:	89 c3                	mov    %eax,%ebx
  800da1:	83 c4 10             	add    $0x10,%esp
  800da4:	85 c0                	test   %eax,%eax
  800da6:	0f 88 bc 00 00 00    	js     800e68 <pipe+0x131>
	va = fd2data(fd0);
  800dac:	83 ec 0c             	sub    $0xc,%esp
  800daf:	ff 75 f4             	push   -0xc(%ebp)
  800db2:	e8 e0 f5 ff ff       	call   800397 <fd2data>
  800db7:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db9:	83 c4 0c             	add    $0xc,%esp
  800dbc:	68 07 04 00 00       	push   $0x407
  800dc1:	50                   	push   %eax
  800dc2:	6a 00                	push   $0x0
  800dc4:	e8 a7 f3 ff ff       	call   800170 <sys_page_alloc>
  800dc9:	89 c3                	mov    %eax,%ebx
  800dcb:	83 c4 10             	add    $0x10,%esp
  800dce:	85 c0                	test   %eax,%eax
  800dd0:	0f 88 82 00 00 00    	js     800e58 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd6:	83 ec 0c             	sub    $0xc,%esp
  800dd9:	ff 75 f0             	push   -0x10(%ebp)
  800ddc:	e8 b6 f5 ff ff       	call   800397 <fd2data>
  800de1:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800de8:	50                   	push   %eax
  800de9:	6a 00                	push   $0x0
  800deb:	56                   	push   %esi
  800dec:	6a 00                	push   $0x0
  800dee:	e8 c0 f3 ff ff       	call   8001b3 <sys_page_map>
  800df3:	89 c3                	mov    %eax,%ebx
  800df5:	83 c4 20             	add    $0x20,%esp
  800df8:	85 c0                	test   %eax,%eax
  800dfa:	78 4e                	js     800e4a <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  800dfc:	a1 20 30 80 00       	mov    0x803020,%eax
  800e01:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e04:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e06:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e09:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e10:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e13:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e18:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e1f:	83 ec 0c             	sub    $0xc,%esp
  800e22:	ff 75 f4             	push   -0xc(%ebp)
  800e25:	e8 5d f5 ff ff       	call   800387 <fd2num>
  800e2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e2f:	83 c4 04             	add    $0x4,%esp
  800e32:	ff 75 f0             	push   -0x10(%ebp)
  800e35:	e8 4d f5 ff ff       	call   800387 <fd2num>
  800e3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e40:	83 c4 10             	add    $0x10,%esp
  800e43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e48:	eb 2e                	jmp    800e78 <pipe+0x141>
	sys_page_unmap(0, va);
  800e4a:	83 ec 08             	sub    $0x8,%esp
  800e4d:	56                   	push   %esi
  800e4e:	6a 00                	push   $0x0
  800e50:	e8 a0 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e55:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e58:	83 ec 08             	sub    $0x8,%esp
  800e5b:	ff 75 f0             	push   -0x10(%ebp)
  800e5e:	6a 00                	push   $0x0
  800e60:	e8 90 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e65:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e68:	83 ec 08             	sub    $0x8,%esp
  800e6b:	ff 75 f4             	push   -0xc(%ebp)
  800e6e:	6a 00                	push   $0x0
  800e70:	e8 80 f3 ff ff       	call   8001f5 <sys_page_unmap>
  800e75:	83 c4 10             	add    $0x10,%esp
}
  800e78:	89 d8                	mov    %ebx,%eax
  800e7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <pipeisclosed>:
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e8a:	50                   	push   %eax
  800e8b:	ff 75 08             	push   0x8(%ebp)
  800e8e:	e8 6b f5 ff ff       	call   8003fe <fd_lookup>
  800e93:	83 c4 10             	add    $0x10,%esp
  800e96:	85 c0                	test   %eax,%eax
  800e98:	78 18                	js     800eb2 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e9a:	83 ec 0c             	sub    $0xc,%esp
  800e9d:	ff 75 f4             	push   -0xc(%ebp)
  800ea0:	e8 f2 f4 ff ff       	call   800397 <fd2data>
  800ea5:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eaa:	e8 33 fd ff ff       	call   800be2 <_pipeisclosed>
  800eaf:	83 c4 10             	add    $0x10,%esp
}
  800eb2:	c9                   	leave  
  800eb3:	c3                   	ret    

00800eb4 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  800eb4:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb9:	c3                   	ret    

00800eba <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ec0:	68 36 1f 80 00       	push   $0x801f36
  800ec5:	ff 75 0c             	push   0xc(%ebp)
  800ec8:	e8 10 08 00 00       	call   8016dd <strcpy>
	return 0;
}
  800ecd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed2:	c9                   	leave  
  800ed3:	c3                   	ret    

00800ed4 <devcons_write>:
{
  800ed4:	55                   	push   %ebp
  800ed5:	89 e5                	mov    %esp,%ebp
  800ed7:	57                   	push   %edi
  800ed8:	56                   	push   %esi
  800ed9:	53                   	push   %ebx
  800eda:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ee0:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ee5:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800eeb:	eb 2e                	jmp    800f1b <devcons_write+0x47>
		m = n - tot;
  800eed:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef0:	29 f3                	sub    %esi,%ebx
  800ef2:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800ef7:	39 c3                	cmp    %eax,%ebx
  800ef9:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800efc:	83 ec 04             	sub    $0x4,%esp
  800eff:	53                   	push   %ebx
  800f00:	89 f0                	mov    %esi,%eax
  800f02:	03 45 0c             	add    0xc(%ebp),%eax
  800f05:	50                   	push   %eax
  800f06:	57                   	push   %edi
  800f07:	e8 67 09 00 00       	call   801873 <memmove>
		sys_cputs(buf, m);
  800f0c:	83 c4 08             	add    $0x8,%esp
  800f0f:	53                   	push   %ebx
  800f10:	57                   	push   %edi
  800f11:	e8 9e f1 ff ff       	call   8000b4 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f16:	01 de                	add    %ebx,%esi
  800f18:	83 c4 10             	add    $0x10,%esp
  800f1b:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f1e:	72 cd                	jb     800eed <devcons_write+0x19>
}
  800f20:	89 f0                	mov    %esi,%eax
  800f22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f25:	5b                   	pop    %ebx
  800f26:	5e                   	pop    %esi
  800f27:	5f                   	pop    %edi
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    

00800f2a <devcons_read>:
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	83 ec 08             	sub    $0x8,%esp
  800f30:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f35:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f39:	75 07                	jne    800f42 <devcons_read+0x18>
  800f3b:	eb 1f                	jmp    800f5c <devcons_read+0x32>
		sys_yield();
  800f3d:	e8 0f f2 ff ff       	call   800151 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f42:	e8 8b f1 ff ff       	call   8000d2 <sys_cgetc>
  800f47:	85 c0                	test   %eax,%eax
  800f49:	74 f2                	je     800f3d <devcons_read+0x13>
	if (c < 0)
  800f4b:	78 0f                	js     800f5c <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  800f4d:	83 f8 04             	cmp    $0x4,%eax
  800f50:	74 0c                	je     800f5e <devcons_read+0x34>
	*(char*)vbuf = c;
  800f52:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f55:	88 02                	mov    %al,(%edx)
	return 1;
  800f57:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f5c:	c9                   	leave  
  800f5d:	c3                   	ret    
		return 0;
  800f5e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f63:	eb f7                	jmp    800f5c <devcons_read+0x32>

00800f65 <cputchar>:
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f71:	6a 01                	push   $0x1
  800f73:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f76:	50                   	push   %eax
  800f77:	e8 38 f1 ff ff       	call   8000b4 <sys_cputs>
}
  800f7c:	83 c4 10             	add    $0x10,%esp
  800f7f:	c9                   	leave  
  800f80:	c3                   	ret    

00800f81 <getchar>:
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f87:	6a 01                	push   $0x1
  800f89:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f8c:	50                   	push   %eax
  800f8d:	6a 00                	push   $0x0
  800f8f:	e8 ce f6 ff ff       	call   800662 <read>
	if (r < 0)
  800f94:	83 c4 10             	add    $0x10,%esp
  800f97:	85 c0                	test   %eax,%eax
  800f99:	78 06                	js     800fa1 <getchar+0x20>
	if (r < 1)
  800f9b:	74 06                	je     800fa3 <getchar+0x22>
	return c;
  800f9d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fa1:	c9                   	leave  
  800fa2:	c3                   	ret    
		return -E_EOF;
  800fa3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fa8:	eb f7                	jmp    800fa1 <getchar+0x20>

00800faa <iscons>:
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb3:	50                   	push   %eax
  800fb4:	ff 75 08             	push   0x8(%ebp)
  800fb7:	e8 42 f4 ff ff       	call   8003fe <fd_lookup>
  800fbc:	83 c4 10             	add    $0x10,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	78 11                	js     800fd4 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fcc:	39 10                	cmp    %edx,(%eax)
  800fce:	0f 94 c0             	sete   %al
  800fd1:	0f b6 c0             	movzbl %al,%eax
}
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <opencons>:
{
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdf:	50                   	push   %eax
  800fe0:	e8 c9 f3 ff ff       	call   8003ae <fd_alloc>
  800fe5:	83 c4 10             	add    $0x10,%esp
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	78 3a                	js     801026 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fec:	83 ec 04             	sub    $0x4,%esp
  800fef:	68 07 04 00 00       	push   $0x407
  800ff4:	ff 75 f4             	push   -0xc(%ebp)
  800ff7:	6a 00                	push   $0x0
  800ff9:	e8 72 f1 ff ff       	call   800170 <sys_page_alloc>
  800ffe:	83 c4 10             	add    $0x10,%esp
  801001:	85 c0                	test   %eax,%eax
  801003:	78 21                	js     801026 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801005:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801008:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80100e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801010:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801013:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80101a:	83 ec 0c             	sub    $0xc,%esp
  80101d:	50                   	push   %eax
  80101e:	e8 64 f3 ff ff       	call   800387 <fd2num>
  801023:	83 c4 10             	add    $0x10,%esp
}
  801026:	c9                   	leave  
  801027:	c3                   	ret    

00801028 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	56                   	push   %esi
  80102c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80102d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801030:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801036:	e8 f7 f0 ff ff       	call   800132 <sys_getenvid>
  80103b:	83 ec 0c             	sub    $0xc,%esp
  80103e:	ff 75 0c             	push   0xc(%ebp)
  801041:	ff 75 08             	push   0x8(%ebp)
  801044:	56                   	push   %esi
  801045:	50                   	push   %eax
  801046:	68 44 1f 80 00       	push   $0x801f44
  80104b:	e8 b3 00 00 00       	call   801103 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801050:	83 c4 18             	add    $0x18,%esp
  801053:	53                   	push   %ebx
  801054:	ff 75 10             	push   0x10(%ebp)
  801057:	e8 56 00 00 00       	call   8010b2 <vcprintf>
	cprintf("\n");
  80105c:	c7 04 24 2f 1f 80 00 	movl   $0x801f2f,(%esp)
  801063:	e8 9b 00 00 00       	call   801103 <cprintf>
  801068:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80106b:	cc                   	int3   
  80106c:	eb fd                	jmp    80106b <_panic+0x43>

0080106e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	53                   	push   %ebx
  801072:	83 ec 04             	sub    $0x4,%esp
  801075:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801078:	8b 13                	mov    (%ebx),%edx
  80107a:	8d 42 01             	lea    0x1(%edx),%eax
  80107d:	89 03                	mov    %eax,(%ebx)
  80107f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801082:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801086:	3d ff 00 00 00       	cmp    $0xff,%eax
  80108b:	74 09                	je     801096 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80108d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801091:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801094:	c9                   	leave  
  801095:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801096:	83 ec 08             	sub    $0x8,%esp
  801099:	68 ff 00 00 00       	push   $0xff
  80109e:	8d 43 08             	lea    0x8(%ebx),%eax
  8010a1:	50                   	push   %eax
  8010a2:	e8 0d f0 ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  8010a7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010ad:	83 c4 10             	add    $0x10,%esp
  8010b0:	eb db                	jmp    80108d <putch+0x1f>

008010b2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010b2:	55                   	push   %ebp
  8010b3:	89 e5                	mov    %esp,%ebp
  8010b5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010bb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010c2:	00 00 00 
	b.cnt = 0;
  8010c5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010cc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010cf:	ff 75 0c             	push   0xc(%ebp)
  8010d2:	ff 75 08             	push   0x8(%ebp)
  8010d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010db:	50                   	push   %eax
  8010dc:	68 6e 10 80 00       	push   $0x80106e
  8010e1:	e8 14 01 00 00       	call   8011fa <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010e6:	83 c4 08             	add    $0x8,%esp
  8010e9:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8010ef:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010f5:	50                   	push   %eax
  8010f6:	e8 b9 ef ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  8010fb:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801101:	c9                   	leave  
  801102:	c3                   	ret    

00801103 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801103:	55                   	push   %ebp
  801104:	89 e5                	mov    %esp,%ebp
  801106:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801109:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80110c:	50                   	push   %eax
  80110d:	ff 75 08             	push   0x8(%ebp)
  801110:	e8 9d ff ff ff       	call   8010b2 <vcprintf>
	va_end(ap);

	return cnt;
}
  801115:	c9                   	leave  
  801116:	c3                   	ret    

00801117 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	57                   	push   %edi
  80111b:	56                   	push   %esi
  80111c:	53                   	push   %ebx
  80111d:	83 ec 1c             	sub    $0x1c,%esp
  801120:	89 c7                	mov    %eax,%edi
  801122:	89 d6                	mov    %edx,%esi
  801124:	8b 45 08             	mov    0x8(%ebp),%eax
  801127:	8b 55 0c             	mov    0xc(%ebp),%edx
  80112a:	89 d1                	mov    %edx,%ecx
  80112c:	89 c2                	mov    %eax,%edx
  80112e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801131:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801134:	8b 45 10             	mov    0x10(%ebp),%eax
  801137:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80113a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80113d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801144:	39 c2                	cmp    %eax,%edx
  801146:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801149:	72 3e                	jb     801189 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80114b:	83 ec 0c             	sub    $0xc,%esp
  80114e:	ff 75 18             	push   0x18(%ebp)
  801151:	83 eb 01             	sub    $0x1,%ebx
  801154:	53                   	push   %ebx
  801155:	50                   	push   %eax
  801156:	83 ec 08             	sub    $0x8,%esp
  801159:	ff 75 e4             	push   -0x1c(%ebp)
  80115c:	ff 75 e0             	push   -0x20(%ebp)
  80115f:	ff 75 dc             	push   -0x24(%ebp)
  801162:	ff 75 d8             	push   -0x28(%ebp)
  801165:	e8 66 0a 00 00       	call   801bd0 <__udivdi3>
  80116a:	83 c4 18             	add    $0x18,%esp
  80116d:	52                   	push   %edx
  80116e:	50                   	push   %eax
  80116f:	89 f2                	mov    %esi,%edx
  801171:	89 f8                	mov    %edi,%eax
  801173:	e8 9f ff ff ff       	call   801117 <printnum>
  801178:	83 c4 20             	add    $0x20,%esp
  80117b:	eb 13                	jmp    801190 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80117d:	83 ec 08             	sub    $0x8,%esp
  801180:	56                   	push   %esi
  801181:	ff 75 18             	push   0x18(%ebp)
  801184:	ff d7                	call   *%edi
  801186:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801189:	83 eb 01             	sub    $0x1,%ebx
  80118c:	85 db                	test   %ebx,%ebx
  80118e:	7f ed                	jg     80117d <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801190:	83 ec 08             	sub    $0x8,%esp
  801193:	56                   	push   %esi
  801194:	83 ec 04             	sub    $0x4,%esp
  801197:	ff 75 e4             	push   -0x1c(%ebp)
  80119a:	ff 75 e0             	push   -0x20(%ebp)
  80119d:	ff 75 dc             	push   -0x24(%ebp)
  8011a0:	ff 75 d8             	push   -0x28(%ebp)
  8011a3:	e8 48 0b 00 00       	call   801cf0 <__umoddi3>
  8011a8:	83 c4 14             	add    $0x14,%esp
  8011ab:	0f be 80 67 1f 80 00 	movsbl 0x801f67(%eax),%eax
  8011b2:	50                   	push   %eax
  8011b3:	ff d7                	call   *%edi
}
  8011b5:	83 c4 10             	add    $0x10,%esp
  8011b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011bb:	5b                   	pop    %ebx
  8011bc:	5e                   	pop    %esi
  8011bd:	5f                   	pop    %edi
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    

008011c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011c6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011ca:	8b 10                	mov    (%eax),%edx
  8011cc:	3b 50 04             	cmp    0x4(%eax),%edx
  8011cf:	73 0a                	jae    8011db <sprintputch+0x1b>
		*b->buf++ = ch;
  8011d1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011d4:	89 08                	mov    %ecx,(%eax)
  8011d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d9:	88 02                	mov    %al,(%edx)
}
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    

008011dd <printfmt>:
{
  8011dd:	55                   	push   %ebp
  8011de:	89 e5                	mov    %esp,%ebp
  8011e0:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011e3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011e6:	50                   	push   %eax
  8011e7:	ff 75 10             	push   0x10(%ebp)
  8011ea:	ff 75 0c             	push   0xc(%ebp)
  8011ed:	ff 75 08             	push   0x8(%ebp)
  8011f0:	e8 05 00 00 00       	call   8011fa <vprintfmt>
}
  8011f5:	83 c4 10             	add    $0x10,%esp
  8011f8:	c9                   	leave  
  8011f9:	c3                   	ret    

008011fa <vprintfmt>:
{
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	57                   	push   %edi
  8011fe:	56                   	push   %esi
  8011ff:	53                   	push   %ebx
  801200:	83 ec 3c             	sub    $0x3c,%esp
  801203:	8b 75 08             	mov    0x8(%ebp),%esi
  801206:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801209:	8b 7d 10             	mov    0x10(%ebp),%edi
  80120c:	eb 0a                	jmp    801218 <vprintfmt+0x1e>
			putch(ch, putdat);
  80120e:	83 ec 08             	sub    $0x8,%esp
  801211:	53                   	push   %ebx
  801212:	50                   	push   %eax
  801213:	ff d6                	call   *%esi
  801215:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801218:	83 c7 01             	add    $0x1,%edi
  80121b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80121f:	83 f8 25             	cmp    $0x25,%eax
  801222:	74 0c                	je     801230 <vprintfmt+0x36>
			if (ch == '\0')
  801224:	85 c0                	test   %eax,%eax
  801226:	75 e6                	jne    80120e <vprintfmt+0x14>
}
  801228:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80122b:	5b                   	pop    %ebx
  80122c:	5e                   	pop    %esi
  80122d:	5f                   	pop    %edi
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    
		padc = ' ';
  801230:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  801234:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80123b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801242:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801249:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80124e:	8d 47 01             	lea    0x1(%edi),%eax
  801251:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801254:	0f b6 17             	movzbl (%edi),%edx
  801257:	8d 42 dd             	lea    -0x23(%edx),%eax
  80125a:	3c 55                	cmp    $0x55,%al
  80125c:	0f 87 bb 03 00 00    	ja     80161d <vprintfmt+0x423>
  801262:	0f b6 c0             	movzbl %al,%eax
  801265:	ff 24 85 a0 20 80 00 	jmp    *0x8020a0(,%eax,4)
  80126c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80126f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801273:	eb d9                	jmp    80124e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801275:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801278:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80127c:	eb d0                	jmp    80124e <vprintfmt+0x54>
  80127e:	0f b6 d2             	movzbl %dl,%edx
  801281:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801284:	b8 00 00 00 00       	mov    $0x0,%eax
  801289:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80128c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80128f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801293:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801296:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801299:	83 f9 09             	cmp    $0x9,%ecx
  80129c:	77 55                	ja     8012f3 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80129e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8012a1:	eb e9                	jmp    80128c <vprintfmt+0x92>
			precision = va_arg(ap, int);
  8012a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8012a6:	8b 00                	mov    (%eax),%eax
  8012a8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ae:	8d 40 04             	lea    0x4(%eax),%eax
  8012b1:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8012b7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012bb:	79 91                	jns    80124e <vprintfmt+0x54>
				width = precision, precision = -1;
  8012bd:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012c3:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8012ca:	eb 82                	jmp    80124e <vprintfmt+0x54>
  8012cc:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8012cf:	85 d2                	test   %edx,%edx
  8012d1:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d6:	0f 49 c2             	cmovns %edx,%eax
  8012d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012df:	e9 6a ff ff ff       	jmp    80124e <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8012e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012e7:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8012ee:	e9 5b ff ff ff       	jmp    80124e <vprintfmt+0x54>
  8012f3:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012f9:	eb bc                	jmp    8012b7 <vprintfmt+0xbd>
			lflag++;
  8012fb:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801301:	e9 48 ff ff ff       	jmp    80124e <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  801306:	8b 45 14             	mov    0x14(%ebp),%eax
  801309:	8d 78 04             	lea    0x4(%eax),%edi
  80130c:	83 ec 08             	sub    $0x8,%esp
  80130f:	53                   	push   %ebx
  801310:	ff 30                	push   (%eax)
  801312:	ff d6                	call   *%esi
			break;
  801314:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801317:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  80131a:	e9 9d 02 00 00       	jmp    8015bc <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80131f:	8b 45 14             	mov    0x14(%ebp),%eax
  801322:	8d 78 04             	lea    0x4(%eax),%edi
  801325:	8b 10                	mov    (%eax),%edx
  801327:	89 d0                	mov    %edx,%eax
  801329:	f7 d8                	neg    %eax
  80132b:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80132e:	83 f8 0f             	cmp    $0xf,%eax
  801331:	7f 23                	jg     801356 <vprintfmt+0x15c>
  801333:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  80133a:	85 d2                	test   %edx,%edx
  80133c:	74 18                	je     801356 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80133e:	52                   	push   %edx
  80133f:	68 fd 1e 80 00       	push   $0x801efd
  801344:	53                   	push   %ebx
  801345:	56                   	push   %esi
  801346:	e8 92 fe ff ff       	call   8011dd <printfmt>
  80134b:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80134e:	89 7d 14             	mov    %edi,0x14(%ebp)
  801351:	e9 66 02 00 00       	jmp    8015bc <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  801356:	50                   	push   %eax
  801357:	68 7f 1f 80 00       	push   $0x801f7f
  80135c:	53                   	push   %ebx
  80135d:	56                   	push   %esi
  80135e:	e8 7a fe ff ff       	call   8011dd <printfmt>
  801363:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801366:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801369:	e9 4e 02 00 00       	jmp    8015bc <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80136e:	8b 45 14             	mov    0x14(%ebp),%eax
  801371:	83 c0 04             	add    $0x4,%eax
  801374:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801377:	8b 45 14             	mov    0x14(%ebp),%eax
  80137a:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80137c:	85 d2                	test   %edx,%edx
  80137e:	b8 78 1f 80 00       	mov    $0x801f78,%eax
  801383:	0f 45 c2             	cmovne %edx,%eax
  801386:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801389:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80138d:	7e 06                	jle    801395 <vprintfmt+0x19b>
  80138f:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801393:	75 0d                	jne    8013a2 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801395:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801398:	89 c7                	mov    %eax,%edi
  80139a:	03 45 e0             	add    -0x20(%ebp),%eax
  80139d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013a0:	eb 55                	jmp    8013f7 <vprintfmt+0x1fd>
  8013a2:	83 ec 08             	sub    $0x8,%esp
  8013a5:	ff 75 d8             	push   -0x28(%ebp)
  8013a8:	ff 75 cc             	push   -0x34(%ebp)
  8013ab:	e8 0a 03 00 00       	call   8016ba <strnlen>
  8013b0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013b3:	29 c1                	sub    %eax,%ecx
  8013b5:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8013bd:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8013c1:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8013c4:	eb 0f                	jmp    8013d5 <vprintfmt+0x1db>
					putch(padc, putdat);
  8013c6:	83 ec 08             	sub    $0x8,%esp
  8013c9:	53                   	push   %ebx
  8013ca:	ff 75 e0             	push   -0x20(%ebp)
  8013cd:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013cf:	83 ef 01             	sub    $0x1,%edi
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	85 ff                	test   %edi,%edi
  8013d7:	7f ed                	jg     8013c6 <vprintfmt+0x1cc>
  8013d9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8013dc:	85 d2                	test   %edx,%edx
  8013de:	b8 00 00 00 00       	mov    $0x0,%eax
  8013e3:	0f 49 c2             	cmovns %edx,%eax
  8013e6:	29 c2                	sub    %eax,%edx
  8013e8:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8013eb:	eb a8                	jmp    801395 <vprintfmt+0x19b>
					putch(ch, putdat);
  8013ed:	83 ec 08             	sub    $0x8,%esp
  8013f0:	53                   	push   %ebx
  8013f1:	52                   	push   %edx
  8013f2:	ff d6                	call   *%esi
  8013f4:	83 c4 10             	add    $0x10,%esp
  8013f7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013fa:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013fc:	83 c7 01             	add    $0x1,%edi
  8013ff:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801403:	0f be d0             	movsbl %al,%edx
  801406:	85 d2                	test   %edx,%edx
  801408:	74 4b                	je     801455 <vprintfmt+0x25b>
  80140a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80140e:	78 06                	js     801416 <vprintfmt+0x21c>
  801410:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  801414:	78 1e                	js     801434 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  801416:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80141a:	74 d1                	je     8013ed <vprintfmt+0x1f3>
  80141c:	0f be c0             	movsbl %al,%eax
  80141f:	83 e8 20             	sub    $0x20,%eax
  801422:	83 f8 5e             	cmp    $0x5e,%eax
  801425:	76 c6                	jbe    8013ed <vprintfmt+0x1f3>
					putch('?', putdat);
  801427:	83 ec 08             	sub    $0x8,%esp
  80142a:	53                   	push   %ebx
  80142b:	6a 3f                	push   $0x3f
  80142d:	ff d6                	call   *%esi
  80142f:	83 c4 10             	add    $0x10,%esp
  801432:	eb c3                	jmp    8013f7 <vprintfmt+0x1fd>
  801434:	89 cf                	mov    %ecx,%edi
  801436:	eb 0e                	jmp    801446 <vprintfmt+0x24c>
				putch(' ', putdat);
  801438:	83 ec 08             	sub    $0x8,%esp
  80143b:	53                   	push   %ebx
  80143c:	6a 20                	push   $0x20
  80143e:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801440:	83 ef 01             	sub    $0x1,%edi
  801443:	83 c4 10             	add    $0x10,%esp
  801446:	85 ff                	test   %edi,%edi
  801448:	7f ee                	jg     801438 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80144a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80144d:	89 45 14             	mov    %eax,0x14(%ebp)
  801450:	e9 67 01 00 00       	jmp    8015bc <vprintfmt+0x3c2>
  801455:	89 cf                	mov    %ecx,%edi
  801457:	eb ed                	jmp    801446 <vprintfmt+0x24c>
	if (lflag >= 2)
  801459:	83 f9 01             	cmp    $0x1,%ecx
  80145c:	7f 1b                	jg     801479 <vprintfmt+0x27f>
	else if (lflag)
  80145e:	85 c9                	test   %ecx,%ecx
  801460:	74 63                	je     8014c5 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  801462:	8b 45 14             	mov    0x14(%ebp),%eax
  801465:	8b 00                	mov    (%eax),%eax
  801467:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80146a:	99                   	cltd   
  80146b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80146e:	8b 45 14             	mov    0x14(%ebp),%eax
  801471:	8d 40 04             	lea    0x4(%eax),%eax
  801474:	89 45 14             	mov    %eax,0x14(%ebp)
  801477:	eb 17                	jmp    801490 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801479:	8b 45 14             	mov    0x14(%ebp),%eax
  80147c:	8b 50 04             	mov    0x4(%eax),%edx
  80147f:	8b 00                	mov    (%eax),%eax
  801481:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801484:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801487:	8b 45 14             	mov    0x14(%ebp),%eax
  80148a:	8d 40 08             	lea    0x8(%eax),%eax
  80148d:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801490:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801493:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801496:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80149b:	85 c9                	test   %ecx,%ecx
  80149d:	0f 89 ff 00 00 00    	jns    8015a2 <vprintfmt+0x3a8>
				putch('-', putdat);
  8014a3:	83 ec 08             	sub    $0x8,%esp
  8014a6:	53                   	push   %ebx
  8014a7:	6a 2d                	push   $0x2d
  8014a9:	ff d6                	call   *%esi
				num = -(long long) num;
  8014ab:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014ae:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014b1:	f7 da                	neg    %edx
  8014b3:	83 d1 00             	adc    $0x0,%ecx
  8014b6:	f7 d9                	neg    %ecx
  8014b8:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8014bb:	bf 0a 00 00 00       	mov    $0xa,%edi
  8014c0:	e9 dd 00 00 00       	jmp    8015a2 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8014c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c8:	8b 00                	mov    (%eax),%eax
  8014ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014cd:	99                   	cltd   
  8014ce:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014d1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d4:	8d 40 04             	lea    0x4(%eax),%eax
  8014d7:	89 45 14             	mov    %eax,0x14(%ebp)
  8014da:	eb b4                	jmp    801490 <vprintfmt+0x296>
	if (lflag >= 2)
  8014dc:	83 f9 01             	cmp    $0x1,%ecx
  8014df:	7f 1e                	jg     8014ff <vprintfmt+0x305>
	else if (lflag)
  8014e1:	85 c9                	test   %ecx,%ecx
  8014e3:	74 32                	je     801517 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8014e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e8:	8b 10                	mov    (%eax),%edx
  8014ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014ef:	8d 40 04             	lea    0x4(%eax),%eax
  8014f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014f5:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8014fa:	e9 a3 00 00 00       	jmp    8015a2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8014ff:	8b 45 14             	mov    0x14(%ebp),%eax
  801502:	8b 10                	mov    (%eax),%edx
  801504:	8b 48 04             	mov    0x4(%eax),%ecx
  801507:	8d 40 08             	lea    0x8(%eax),%eax
  80150a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80150d:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  801512:	e9 8b 00 00 00       	jmp    8015a2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801517:	8b 45 14             	mov    0x14(%ebp),%eax
  80151a:	8b 10                	mov    (%eax),%edx
  80151c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801521:	8d 40 04             	lea    0x4(%eax),%eax
  801524:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801527:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  80152c:	eb 74                	jmp    8015a2 <vprintfmt+0x3a8>
	if (lflag >= 2)
  80152e:	83 f9 01             	cmp    $0x1,%ecx
  801531:	7f 1b                	jg     80154e <vprintfmt+0x354>
	else if (lflag)
  801533:	85 c9                	test   %ecx,%ecx
  801535:	74 2c                	je     801563 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  801537:	8b 45 14             	mov    0x14(%ebp),%eax
  80153a:	8b 10                	mov    (%eax),%edx
  80153c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801541:	8d 40 04             	lea    0x4(%eax),%eax
  801544:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801547:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  80154c:	eb 54                	jmp    8015a2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80154e:	8b 45 14             	mov    0x14(%ebp),%eax
  801551:	8b 10                	mov    (%eax),%edx
  801553:	8b 48 04             	mov    0x4(%eax),%ecx
  801556:	8d 40 08             	lea    0x8(%eax),%eax
  801559:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80155c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  801561:	eb 3f                	jmp    8015a2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801563:	8b 45 14             	mov    0x14(%ebp),%eax
  801566:	8b 10                	mov    (%eax),%edx
  801568:	b9 00 00 00 00       	mov    $0x0,%ecx
  80156d:	8d 40 04             	lea    0x4(%eax),%eax
  801570:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801573:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801578:	eb 28                	jmp    8015a2 <vprintfmt+0x3a8>
			putch('0', putdat);
  80157a:	83 ec 08             	sub    $0x8,%esp
  80157d:	53                   	push   %ebx
  80157e:	6a 30                	push   $0x30
  801580:	ff d6                	call   *%esi
			putch('x', putdat);
  801582:	83 c4 08             	add    $0x8,%esp
  801585:	53                   	push   %ebx
  801586:	6a 78                	push   $0x78
  801588:	ff d6                	call   *%esi
			num = (unsigned long long)
  80158a:	8b 45 14             	mov    0x14(%ebp),%eax
  80158d:	8b 10                	mov    (%eax),%edx
  80158f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801594:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801597:	8d 40 04             	lea    0x4(%eax),%eax
  80159a:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80159d:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  8015a2:	83 ec 0c             	sub    $0xc,%esp
  8015a5:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8015a9:	50                   	push   %eax
  8015aa:	ff 75 e0             	push   -0x20(%ebp)
  8015ad:	57                   	push   %edi
  8015ae:	51                   	push   %ecx
  8015af:	52                   	push   %edx
  8015b0:	89 da                	mov    %ebx,%edx
  8015b2:	89 f0                	mov    %esi,%eax
  8015b4:	e8 5e fb ff ff       	call   801117 <printnum>
			break;
  8015b9:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015bf:	e9 54 fc ff ff       	jmp    801218 <vprintfmt+0x1e>
	if (lflag >= 2)
  8015c4:	83 f9 01             	cmp    $0x1,%ecx
  8015c7:	7f 1b                	jg     8015e4 <vprintfmt+0x3ea>
	else if (lflag)
  8015c9:	85 c9                	test   %ecx,%ecx
  8015cb:	74 2c                	je     8015f9 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8015cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d0:	8b 10                	mov    (%eax),%edx
  8015d2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015d7:	8d 40 04             	lea    0x4(%eax),%eax
  8015da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015dd:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8015e2:	eb be                	jmp    8015a2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8015e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e7:	8b 10                	mov    (%eax),%edx
  8015e9:	8b 48 04             	mov    0x4(%eax),%ecx
  8015ec:	8d 40 08             	lea    0x8(%eax),%eax
  8015ef:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015f2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8015f7:	eb a9                	jmp    8015a2 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8015f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8015fc:	8b 10                	mov    (%eax),%edx
  8015fe:	b9 00 00 00 00       	mov    $0x0,%ecx
  801603:	8d 40 04             	lea    0x4(%eax),%eax
  801606:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801609:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  80160e:	eb 92                	jmp    8015a2 <vprintfmt+0x3a8>
			putch(ch, putdat);
  801610:	83 ec 08             	sub    $0x8,%esp
  801613:	53                   	push   %ebx
  801614:	6a 25                	push   $0x25
  801616:	ff d6                	call   *%esi
			break;
  801618:	83 c4 10             	add    $0x10,%esp
  80161b:	eb 9f                	jmp    8015bc <vprintfmt+0x3c2>
			putch('%', putdat);
  80161d:	83 ec 08             	sub    $0x8,%esp
  801620:	53                   	push   %ebx
  801621:	6a 25                	push   $0x25
  801623:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801625:	83 c4 10             	add    $0x10,%esp
  801628:	89 f8                	mov    %edi,%eax
  80162a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80162e:	74 05                	je     801635 <vprintfmt+0x43b>
  801630:	83 e8 01             	sub    $0x1,%eax
  801633:	eb f5                	jmp    80162a <vprintfmt+0x430>
  801635:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801638:	eb 82                	jmp    8015bc <vprintfmt+0x3c2>

0080163a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80163a:	55                   	push   %ebp
  80163b:	89 e5                	mov    %esp,%ebp
  80163d:	83 ec 18             	sub    $0x18,%esp
  801640:	8b 45 08             	mov    0x8(%ebp),%eax
  801643:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801646:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801649:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80164d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801650:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801657:	85 c0                	test   %eax,%eax
  801659:	74 26                	je     801681 <vsnprintf+0x47>
  80165b:	85 d2                	test   %edx,%edx
  80165d:	7e 22                	jle    801681 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80165f:	ff 75 14             	push   0x14(%ebp)
  801662:	ff 75 10             	push   0x10(%ebp)
  801665:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801668:	50                   	push   %eax
  801669:	68 c0 11 80 00       	push   $0x8011c0
  80166e:	e8 87 fb ff ff       	call   8011fa <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801673:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801676:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801679:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167c:	83 c4 10             	add    $0x10,%esp
}
  80167f:	c9                   	leave  
  801680:	c3                   	ret    
		return -E_INVAL;
  801681:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801686:	eb f7                	jmp    80167f <vsnprintf+0x45>

00801688 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80168e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801691:	50                   	push   %eax
  801692:	ff 75 10             	push   0x10(%ebp)
  801695:	ff 75 0c             	push   0xc(%ebp)
  801698:	ff 75 08             	push   0x8(%ebp)
  80169b:	e8 9a ff ff ff       	call   80163a <vsnprintf>
	va_end(ap);

	return rc;
}
  8016a0:	c9                   	leave  
  8016a1:	c3                   	ret    

008016a2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016a2:	55                   	push   %ebp
  8016a3:	89 e5                	mov    %esp,%ebp
  8016a5:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ad:	eb 03                	jmp    8016b2 <strlen+0x10>
		n++;
  8016af:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  8016b2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016b6:	75 f7                	jne    8016af <strlen+0xd>
	return n;
}
  8016b8:	5d                   	pop    %ebp
  8016b9:	c3                   	ret    

008016ba <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c0:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016c8:	eb 03                	jmp    8016cd <strnlen+0x13>
		n++;
  8016ca:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016cd:	39 d0                	cmp    %edx,%eax
  8016cf:	74 08                	je     8016d9 <strnlen+0x1f>
  8016d1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016d5:	75 f3                	jne    8016ca <strnlen+0x10>
  8016d7:	89 c2                	mov    %eax,%edx
	return n;
}
  8016d9:	89 d0                	mov    %edx,%eax
  8016db:	5d                   	pop    %ebp
  8016dc:	c3                   	ret    

008016dd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016dd:	55                   	push   %ebp
  8016de:	89 e5                	mov    %esp,%ebp
  8016e0:	53                   	push   %ebx
  8016e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ec:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016f0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016f3:	83 c0 01             	add    $0x1,%eax
  8016f6:	84 d2                	test   %dl,%dl
  8016f8:	75 f2                	jne    8016ec <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8016fa:	89 c8                	mov    %ecx,%eax
  8016fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ff:	c9                   	leave  
  801700:	c3                   	ret    

00801701 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801701:	55                   	push   %ebp
  801702:	89 e5                	mov    %esp,%ebp
  801704:	53                   	push   %ebx
  801705:	83 ec 10             	sub    $0x10,%esp
  801708:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80170b:	53                   	push   %ebx
  80170c:	e8 91 ff ff ff       	call   8016a2 <strlen>
  801711:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801714:	ff 75 0c             	push   0xc(%ebp)
  801717:	01 d8                	add    %ebx,%eax
  801719:	50                   	push   %eax
  80171a:	e8 be ff ff ff       	call   8016dd <strcpy>
	return dst;
}
  80171f:	89 d8                	mov    %ebx,%eax
  801721:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801724:	c9                   	leave  
  801725:	c3                   	ret    

00801726 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801726:	55                   	push   %ebp
  801727:	89 e5                	mov    %esp,%ebp
  801729:	56                   	push   %esi
  80172a:	53                   	push   %ebx
  80172b:	8b 75 08             	mov    0x8(%ebp),%esi
  80172e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801731:	89 f3                	mov    %esi,%ebx
  801733:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801736:	89 f0                	mov    %esi,%eax
  801738:	eb 0f                	jmp    801749 <strncpy+0x23>
		*dst++ = *src;
  80173a:	83 c0 01             	add    $0x1,%eax
  80173d:	0f b6 0a             	movzbl (%edx),%ecx
  801740:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801743:	80 f9 01             	cmp    $0x1,%cl
  801746:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801749:	39 d8                	cmp    %ebx,%eax
  80174b:	75 ed                	jne    80173a <strncpy+0x14>
	}
	return ret;
}
  80174d:	89 f0                	mov    %esi,%eax
  80174f:	5b                   	pop    %ebx
  801750:	5e                   	pop    %esi
  801751:	5d                   	pop    %ebp
  801752:	c3                   	ret    

00801753 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801753:	55                   	push   %ebp
  801754:	89 e5                	mov    %esp,%ebp
  801756:	56                   	push   %esi
  801757:	53                   	push   %ebx
  801758:	8b 75 08             	mov    0x8(%ebp),%esi
  80175b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80175e:	8b 55 10             	mov    0x10(%ebp),%edx
  801761:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801763:	85 d2                	test   %edx,%edx
  801765:	74 21                	je     801788 <strlcpy+0x35>
  801767:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80176b:	89 f2                	mov    %esi,%edx
  80176d:	eb 09                	jmp    801778 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80176f:	83 c1 01             	add    $0x1,%ecx
  801772:	83 c2 01             	add    $0x1,%edx
  801775:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801778:	39 c2                	cmp    %eax,%edx
  80177a:	74 09                	je     801785 <strlcpy+0x32>
  80177c:	0f b6 19             	movzbl (%ecx),%ebx
  80177f:	84 db                	test   %bl,%bl
  801781:	75 ec                	jne    80176f <strlcpy+0x1c>
  801783:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801785:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801788:	29 f0                	sub    %esi,%eax
}
  80178a:	5b                   	pop    %ebx
  80178b:	5e                   	pop    %esi
  80178c:	5d                   	pop    %ebp
  80178d:	c3                   	ret    

0080178e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80178e:	55                   	push   %ebp
  80178f:	89 e5                	mov    %esp,%ebp
  801791:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801794:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801797:	eb 06                	jmp    80179f <strcmp+0x11>
		p++, q++;
  801799:	83 c1 01             	add    $0x1,%ecx
  80179c:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80179f:	0f b6 01             	movzbl (%ecx),%eax
  8017a2:	84 c0                	test   %al,%al
  8017a4:	74 04                	je     8017aa <strcmp+0x1c>
  8017a6:	3a 02                	cmp    (%edx),%al
  8017a8:	74 ef                	je     801799 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017aa:	0f b6 c0             	movzbl %al,%eax
  8017ad:	0f b6 12             	movzbl (%edx),%edx
  8017b0:	29 d0                	sub    %edx,%eax
}
  8017b2:	5d                   	pop    %ebp
  8017b3:	c3                   	ret    

008017b4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	53                   	push   %ebx
  8017b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017be:	89 c3                	mov    %eax,%ebx
  8017c0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017c3:	eb 06                	jmp    8017cb <strncmp+0x17>
		n--, p++, q++;
  8017c5:	83 c0 01             	add    $0x1,%eax
  8017c8:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017cb:	39 d8                	cmp    %ebx,%eax
  8017cd:	74 18                	je     8017e7 <strncmp+0x33>
  8017cf:	0f b6 08             	movzbl (%eax),%ecx
  8017d2:	84 c9                	test   %cl,%cl
  8017d4:	74 04                	je     8017da <strncmp+0x26>
  8017d6:	3a 0a                	cmp    (%edx),%cl
  8017d8:	74 eb                	je     8017c5 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017da:	0f b6 00             	movzbl (%eax),%eax
  8017dd:	0f b6 12             	movzbl (%edx),%edx
  8017e0:	29 d0                	sub    %edx,%eax
}
  8017e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017e5:	c9                   	leave  
  8017e6:	c3                   	ret    
		return 0;
  8017e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ec:	eb f4                	jmp    8017e2 <strncmp+0x2e>

008017ee <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017f8:	eb 03                	jmp    8017fd <strchr+0xf>
  8017fa:	83 c0 01             	add    $0x1,%eax
  8017fd:	0f b6 10             	movzbl (%eax),%edx
  801800:	84 d2                	test   %dl,%dl
  801802:	74 06                	je     80180a <strchr+0x1c>
		if (*s == c)
  801804:	38 ca                	cmp    %cl,%dl
  801806:	75 f2                	jne    8017fa <strchr+0xc>
  801808:	eb 05                	jmp    80180f <strchr+0x21>
			return (char *) s;
	return 0;
  80180a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80180f:	5d                   	pop    %ebp
  801810:	c3                   	ret    

00801811 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	8b 45 08             	mov    0x8(%ebp),%eax
  801817:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80181b:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80181e:	38 ca                	cmp    %cl,%dl
  801820:	74 09                	je     80182b <strfind+0x1a>
  801822:	84 d2                	test   %dl,%dl
  801824:	74 05                	je     80182b <strfind+0x1a>
	for (; *s; s++)
  801826:	83 c0 01             	add    $0x1,%eax
  801829:	eb f0                	jmp    80181b <strfind+0xa>
			break;
	return (char *) s;
}
  80182b:	5d                   	pop    %ebp
  80182c:	c3                   	ret    

0080182d <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80182d:	55                   	push   %ebp
  80182e:	89 e5                	mov    %esp,%ebp
  801830:	57                   	push   %edi
  801831:	56                   	push   %esi
  801832:	53                   	push   %ebx
  801833:	8b 7d 08             	mov    0x8(%ebp),%edi
  801836:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801839:	85 c9                	test   %ecx,%ecx
  80183b:	74 2f                	je     80186c <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80183d:	89 f8                	mov    %edi,%eax
  80183f:	09 c8                	or     %ecx,%eax
  801841:	a8 03                	test   $0x3,%al
  801843:	75 21                	jne    801866 <memset+0x39>
		c &= 0xFF;
  801845:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801849:	89 d0                	mov    %edx,%eax
  80184b:	c1 e0 08             	shl    $0x8,%eax
  80184e:	89 d3                	mov    %edx,%ebx
  801850:	c1 e3 18             	shl    $0x18,%ebx
  801853:	89 d6                	mov    %edx,%esi
  801855:	c1 e6 10             	shl    $0x10,%esi
  801858:	09 f3                	or     %esi,%ebx
  80185a:	09 da                	or     %ebx,%edx
  80185c:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  80185e:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801861:	fc                   	cld    
  801862:	f3 ab                	rep stos %eax,%es:(%edi)
  801864:	eb 06                	jmp    80186c <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801866:	8b 45 0c             	mov    0xc(%ebp),%eax
  801869:	fc                   	cld    
  80186a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80186c:	89 f8                	mov    %edi,%eax
  80186e:	5b                   	pop    %ebx
  80186f:	5e                   	pop    %esi
  801870:	5f                   	pop    %edi
  801871:	5d                   	pop    %ebp
  801872:	c3                   	ret    

00801873 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	57                   	push   %edi
  801877:	56                   	push   %esi
  801878:	8b 45 08             	mov    0x8(%ebp),%eax
  80187b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80187e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801881:	39 c6                	cmp    %eax,%esi
  801883:	73 32                	jae    8018b7 <memmove+0x44>
  801885:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801888:	39 c2                	cmp    %eax,%edx
  80188a:	76 2b                	jbe    8018b7 <memmove+0x44>
		s += n;
		d += n;
  80188c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80188f:	89 d6                	mov    %edx,%esi
  801891:	09 fe                	or     %edi,%esi
  801893:	09 ce                	or     %ecx,%esi
  801895:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80189b:	75 0e                	jne    8018ab <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80189d:	83 ef 04             	sub    $0x4,%edi
  8018a0:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018a3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018a6:	fd                   	std    
  8018a7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a9:	eb 09                	jmp    8018b4 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018ab:	83 ef 01             	sub    $0x1,%edi
  8018ae:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018b1:	fd                   	std    
  8018b2:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018b4:	fc                   	cld    
  8018b5:	eb 1a                	jmp    8018d1 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b7:	89 f2                	mov    %esi,%edx
  8018b9:	09 c2                	or     %eax,%edx
  8018bb:	09 ca                	or     %ecx,%edx
  8018bd:	f6 c2 03             	test   $0x3,%dl
  8018c0:	75 0a                	jne    8018cc <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018c2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018c5:	89 c7                	mov    %eax,%edi
  8018c7:	fc                   	cld    
  8018c8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ca:	eb 05                	jmp    8018d1 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8018cc:	89 c7                	mov    %eax,%edi
  8018ce:	fc                   	cld    
  8018cf:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018d1:	5e                   	pop    %esi
  8018d2:	5f                   	pop    %edi
  8018d3:	5d                   	pop    %ebp
  8018d4:	c3                   	ret    

008018d5 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8018db:	ff 75 10             	push   0x10(%ebp)
  8018de:	ff 75 0c             	push   0xc(%ebp)
  8018e1:	ff 75 08             	push   0x8(%ebp)
  8018e4:	e8 8a ff ff ff       	call   801873 <memmove>
}
  8018e9:	c9                   	leave  
  8018ea:	c3                   	ret    

008018eb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018eb:	55                   	push   %ebp
  8018ec:	89 e5                	mov    %esp,%ebp
  8018ee:	56                   	push   %esi
  8018ef:	53                   	push   %ebx
  8018f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f6:	89 c6                	mov    %eax,%esi
  8018f8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018fb:	eb 06                	jmp    801903 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8018fd:	83 c0 01             	add    $0x1,%eax
  801900:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801903:	39 f0                	cmp    %esi,%eax
  801905:	74 14                	je     80191b <memcmp+0x30>
		if (*s1 != *s2)
  801907:	0f b6 08             	movzbl (%eax),%ecx
  80190a:	0f b6 1a             	movzbl (%edx),%ebx
  80190d:	38 d9                	cmp    %bl,%cl
  80190f:	74 ec                	je     8018fd <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801911:	0f b6 c1             	movzbl %cl,%eax
  801914:	0f b6 db             	movzbl %bl,%ebx
  801917:	29 d8                	sub    %ebx,%eax
  801919:	eb 05                	jmp    801920 <memcmp+0x35>
	}

	return 0;
  80191b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801920:	5b                   	pop    %ebx
  801921:	5e                   	pop    %esi
  801922:	5d                   	pop    %ebp
  801923:	c3                   	ret    

00801924 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	8b 45 08             	mov    0x8(%ebp),%eax
  80192a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80192d:	89 c2                	mov    %eax,%edx
  80192f:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801932:	eb 03                	jmp    801937 <memfind+0x13>
  801934:	83 c0 01             	add    $0x1,%eax
  801937:	39 d0                	cmp    %edx,%eax
  801939:	73 04                	jae    80193f <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  80193b:	38 08                	cmp    %cl,(%eax)
  80193d:	75 f5                	jne    801934 <memfind+0x10>
			break;
	return (void *) s;
}
  80193f:	5d                   	pop    %ebp
  801940:	c3                   	ret    

00801941 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801941:	55                   	push   %ebp
  801942:	89 e5                	mov    %esp,%ebp
  801944:	57                   	push   %edi
  801945:	56                   	push   %esi
  801946:	53                   	push   %ebx
  801947:	8b 55 08             	mov    0x8(%ebp),%edx
  80194a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80194d:	eb 03                	jmp    801952 <strtol+0x11>
		s++;
  80194f:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801952:	0f b6 02             	movzbl (%edx),%eax
  801955:	3c 20                	cmp    $0x20,%al
  801957:	74 f6                	je     80194f <strtol+0xe>
  801959:	3c 09                	cmp    $0x9,%al
  80195b:	74 f2                	je     80194f <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  80195d:	3c 2b                	cmp    $0x2b,%al
  80195f:	74 2a                	je     80198b <strtol+0x4a>
	int neg = 0;
  801961:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801966:	3c 2d                	cmp    $0x2d,%al
  801968:	74 2b                	je     801995 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80196a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801970:	75 0f                	jne    801981 <strtol+0x40>
  801972:	80 3a 30             	cmpb   $0x30,(%edx)
  801975:	74 28                	je     80199f <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801977:	85 db                	test   %ebx,%ebx
  801979:	b8 0a 00 00 00       	mov    $0xa,%eax
  80197e:	0f 44 d8             	cmove  %eax,%ebx
  801981:	b9 00 00 00 00       	mov    $0x0,%ecx
  801986:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801989:	eb 46                	jmp    8019d1 <strtol+0x90>
		s++;
  80198b:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  80198e:	bf 00 00 00 00       	mov    $0x0,%edi
  801993:	eb d5                	jmp    80196a <strtol+0x29>
		s++, neg = 1;
  801995:	83 c2 01             	add    $0x1,%edx
  801998:	bf 01 00 00 00       	mov    $0x1,%edi
  80199d:	eb cb                	jmp    80196a <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80199f:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  8019a3:	74 0e                	je     8019b3 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  8019a5:	85 db                	test   %ebx,%ebx
  8019a7:	75 d8                	jne    801981 <strtol+0x40>
		s++, base = 8;
  8019a9:	83 c2 01             	add    $0x1,%edx
  8019ac:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019b1:	eb ce                	jmp    801981 <strtol+0x40>
		s += 2, base = 16;
  8019b3:	83 c2 02             	add    $0x2,%edx
  8019b6:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019bb:	eb c4                	jmp    801981 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8019bd:	0f be c0             	movsbl %al,%eax
  8019c0:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019c3:	3b 45 10             	cmp    0x10(%ebp),%eax
  8019c6:	7d 3a                	jge    801a02 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  8019c8:	83 c2 01             	add    $0x1,%edx
  8019cb:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  8019cf:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  8019d1:	0f b6 02             	movzbl (%edx),%eax
  8019d4:	8d 70 d0             	lea    -0x30(%eax),%esi
  8019d7:	89 f3                	mov    %esi,%ebx
  8019d9:	80 fb 09             	cmp    $0x9,%bl
  8019dc:	76 df                	jbe    8019bd <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  8019de:	8d 70 9f             	lea    -0x61(%eax),%esi
  8019e1:	89 f3                	mov    %esi,%ebx
  8019e3:	80 fb 19             	cmp    $0x19,%bl
  8019e6:	77 08                	ja     8019f0 <strtol+0xaf>
			dig = *s - 'a' + 10;
  8019e8:	0f be c0             	movsbl %al,%eax
  8019eb:	83 e8 57             	sub    $0x57,%eax
  8019ee:	eb d3                	jmp    8019c3 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8019f0:	8d 70 bf             	lea    -0x41(%eax),%esi
  8019f3:	89 f3                	mov    %esi,%ebx
  8019f5:	80 fb 19             	cmp    $0x19,%bl
  8019f8:	77 08                	ja     801a02 <strtol+0xc1>
			dig = *s - 'A' + 10;
  8019fa:	0f be c0             	movsbl %al,%eax
  8019fd:	83 e8 37             	sub    $0x37,%eax
  801a00:	eb c1                	jmp    8019c3 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a02:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a06:	74 05                	je     801a0d <strtol+0xcc>
		*endptr = (char *) s;
  801a08:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a0b:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801a0d:	89 c8                	mov    %ecx,%eax
  801a0f:	f7 d8                	neg    %eax
  801a11:	85 ff                	test   %edi,%edi
  801a13:	0f 45 c8             	cmovne %eax,%ecx
}
  801a16:	89 c8                	mov    %ecx,%eax
  801a18:	5b                   	pop    %ebx
  801a19:	5e                   	pop    %esi
  801a1a:	5f                   	pop    %edi
  801a1b:	5d                   	pop    %ebp
  801a1c:	c3                   	ret    

00801a1d <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  801a23:	83 3d 04 60 80 00 00 	cmpl   $0x0,0x806004
  801a2a:	74 0a                	je     801a36 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2f:	a3 04 60 80 00       	mov    %eax,0x806004
}
  801a34:	c9                   	leave  
  801a35:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  801a36:	e8 f7 e6 ff ff       	call   800132 <sys_getenvid>
  801a3b:	83 ec 04             	sub    $0x4,%esp
  801a3e:	68 07 0e 00 00       	push   $0xe07
  801a43:	68 00 f0 bf ee       	push   $0xeebff000
  801a48:	50                   	push   %eax
  801a49:	e8 22 e7 ff ff       	call   800170 <sys_page_alloc>
		if (r < 0) {
  801a4e:	83 c4 10             	add    $0x10,%esp
  801a51:	85 c0                	test   %eax,%eax
  801a53:	78 2c                	js     801a81 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801a55:	e8 d8 e6 ff ff       	call   800132 <sys_getenvid>
  801a5a:	83 ec 08             	sub    $0x8,%esp
  801a5d:	68 61 03 80 00       	push   $0x800361
  801a62:	50                   	push   %eax
  801a63:	e8 53 e8 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801a68:	83 c4 10             	add    $0x10,%esp
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	79 bd                	jns    801a2c <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  801a6f:	50                   	push   %eax
  801a70:	68 a0 22 80 00       	push   $0x8022a0
  801a75:	6a 28                	push   $0x28
  801a77:	68 d6 22 80 00       	push   $0x8022d6
  801a7c:	e8 a7 f5 ff ff       	call   801028 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  801a81:	50                   	push   %eax
  801a82:	68 60 22 80 00       	push   $0x802260
  801a87:	6a 23                	push   $0x23
  801a89:	68 d6 22 80 00       	push   $0x8022d6
  801a8e:	e8 95 f5 ff ff       	call   801028 <_panic>

00801a93 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	56                   	push   %esi
  801a97:	53                   	push   %ebx
  801a98:	8b 75 08             	mov    0x8(%ebp),%esi
  801a9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801aa1:	85 c0                	test   %eax,%eax
  801aa3:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801aa8:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801aab:	83 ec 0c             	sub    $0xc,%esp
  801aae:	50                   	push   %eax
  801aaf:	e8 6c e8 ff ff       	call   800320 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ab4:	83 c4 10             	add    $0x10,%esp
  801ab7:	85 f6                	test   %esi,%esi
  801ab9:	74 14                	je     801acf <ipc_recv+0x3c>
  801abb:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac0:	85 c0                	test   %eax,%eax
  801ac2:	78 09                	js     801acd <ipc_recv+0x3a>
  801ac4:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801aca:	8b 52 74             	mov    0x74(%edx),%edx
  801acd:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801acf:	85 db                	test   %ebx,%ebx
  801ad1:	74 14                	je     801ae7 <ipc_recv+0x54>
  801ad3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	78 09                	js     801ae5 <ipc_recv+0x52>
  801adc:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ae2:	8b 52 78             	mov    0x78(%edx),%edx
  801ae5:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	78 08                	js     801af3 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801aeb:	a1 00 40 80 00       	mov    0x804000,%eax
  801af0:	8b 40 70             	mov    0x70(%eax),%eax
}
  801af3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af6:	5b                   	pop    %ebx
  801af7:	5e                   	pop    %esi
  801af8:	5d                   	pop    %ebp
  801af9:	c3                   	ret    

00801afa <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	57                   	push   %edi
  801afe:	56                   	push   %esi
  801aff:	53                   	push   %ebx
  801b00:	83 ec 0c             	sub    $0xc,%esp
  801b03:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b06:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b09:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801b0c:	85 db                	test   %ebx,%ebx
  801b0e:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801b13:	0f 44 d8             	cmove  %eax,%ebx
  801b16:	eb 05                	jmp    801b1d <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801b18:	e8 34 e6 ff ff       	call   800151 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801b1d:	ff 75 14             	push   0x14(%ebp)
  801b20:	53                   	push   %ebx
  801b21:	56                   	push   %esi
  801b22:	57                   	push   %edi
  801b23:	e8 d5 e7 ff ff       	call   8002fd <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801b28:	83 c4 10             	add    $0x10,%esp
  801b2b:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b2e:	74 e8                	je     801b18 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801b30:	85 c0                	test   %eax,%eax
  801b32:	78 08                	js     801b3c <ipc_send+0x42>
	}while (r<0);

}
  801b34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b37:	5b                   	pop    %ebx
  801b38:	5e                   	pop    %esi
  801b39:	5f                   	pop    %edi
  801b3a:	5d                   	pop    %ebp
  801b3b:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801b3c:	50                   	push   %eax
  801b3d:	68 e4 22 80 00       	push   $0x8022e4
  801b42:	6a 3d                	push   $0x3d
  801b44:	68 f8 22 80 00       	push   $0x8022f8
  801b49:	e8 da f4 ff ff       	call   801028 <_panic>

00801b4e <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b4e:	55                   	push   %ebp
  801b4f:	89 e5                	mov    %esp,%ebp
  801b51:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b54:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b59:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b5c:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b62:	8b 52 50             	mov    0x50(%edx),%edx
  801b65:	39 ca                	cmp    %ecx,%edx
  801b67:	74 11                	je     801b7a <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801b69:	83 c0 01             	add    $0x1,%eax
  801b6c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b71:	75 e6                	jne    801b59 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801b73:	b8 00 00 00 00       	mov    $0x0,%eax
  801b78:	eb 0b                	jmp    801b85 <ipc_find_env+0x37>
			return envs[i].env_id;
  801b7a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b7d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b82:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b85:	5d                   	pop    %ebp
  801b86:	c3                   	ret    

00801b87 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b8d:	89 c2                	mov    %eax,%edx
  801b8f:	c1 ea 16             	shr    $0x16,%edx
  801b92:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b99:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b9e:	f6 c1 01             	test   $0x1,%cl
  801ba1:	74 1c                	je     801bbf <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801ba3:	c1 e8 0c             	shr    $0xc,%eax
  801ba6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801bad:	a8 01                	test   $0x1,%al
  801baf:	74 0e                	je     801bbf <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801bb1:	c1 e8 0c             	shr    $0xc,%eax
  801bb4:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801bbb:	ef 
  801bbc:	0f b7 d2             	movzwl %dx,%edx
}
  801bbf:	89 d0                	mov    %edx,%eax
  801bc1:	5d                   	pop    %ebp
  801bc2:	c3                   	ret    
  801bc3:	66 90                	xchg   %ax,%ax
  801bc5:	66 90                	xchg   %ax,%ax
  801bc7:	66 90                	xchg   %ax,%ax
  801bc9:	66 90                	xchg   %ax,%ax
  801bcb:	66 90                	xchg   %ax,%ax
  801bcd:	66 90                	xchg   %ax,%ax
  801bcf:	90                   	nop

00801bd0 <__udivdi3>:
  801bd0:	f3 0f 1e fb          	endbr32 
  801bd4:	55                   	push   %ebp
  801bd5:	57                   	push   %edi
  801bd6:	56                   	push   %esi
  801bd7:	53                   	push   %ebx
  801bd8:	83 ec 1c             	sub    $0x1c,%esp
  801bdb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801bdf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801be3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801be7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801beb:	85 c0                	test   %eax,%eax
  801bed:	75 19                	jne    801c08 <__udivdi3+0x38>
  801bef:	39 f3                	cmp    %esi,%ebx
  801bf1:	76 4d                	jbe    801c40 <__udivdi3+0x70>
  801bf3:	31 ff                	xor    %edi,%edi
  801bf5:	89 e8                	mov    %ebp,%eax
  801bf7:	89 f2                	mov    %esi,%edx
  801bf9:	f7 f3                	div    %ebx
  801bfb:	89 fa                	mov    %edi,%edx
  801bfd:	83 c4 1c             	add    $0x1c,%esp
  801c00:	5b                   	pop    %ebx
  801c01:	5e                   	pop    %esi
  801c02:	5f                   	pop    %edi
  801c03:	5d                   	pop    %ebp
  801c04:	c3                   	ret    
  801c05:	8d 76 00             	lea    0x0(%esi),%esi
  801c08:	39 f0                	cmp    %esi,%eax
  801c0a:	76 14                	jbe    801c20 <__udivdi3+0x50>
  801c0c:	31 ff                	xor    %edi,%edi
  801c0e:	31 c0                	xor    %eax,%eax
  801c10:	89 fa                	mov    %edi,%edx
  801c12:	83 c4 1c             	add    $0x1c,%esp
  801c15:	5b                   	pop    %ebx
  801c16:	5e                   	pop    %esi
  801c17:	5f                   	pop    %edi
  801c18:	5d                   	pop    %ebp
  801c19:	c3                   	ret    
  801c1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c20:	0f bd f8             	bsr    %eax,%edi
  801c23:	83 f7 1f             	xor    $0x1f,%edi
  801c26:	75 48                	jne    801c70 <__udivdi3+0xa0>
  801c28:	39 f0                	cmp    %esi,%eax
  801c2a:	72 06                	jb     801c32 <__udivdi3+0x62>
  801c2c:	31 c0                	xor    %eax,%eax
  801c2e:	39 eb                	cmp    %ebp,%ebx
  801c30:	77 de                	ja     801c10 <__udivdi3+0x40>
  801c32:	b8 01 00 00 00       	mov    $0x1,%eax
  801c37:	eb d7                	jmp    801c10 <__udivdi3+0x40>
  801c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c40:	89 d9                	mov    %ebx,%ecx
  801c42:	85 db                	test   %ebx,%ebx
  801c44:	75 0b                	jne    801c51 <__udivdi3+0x81>
  801c46:	b8 01 00 00 00       	mov    $0x1,%eax
  801c4b:	31 d2                	xor    %edx,%edx
  801c4d:	f7 f3                	div    %ebx
  801c4f:	89 c1                	mov    %eax,%ecx
  801c51:	31 d2                	xor    %edx,%edx
  801c53:	89 f0                	mov    %esi,%eax
  801c55:	f7 f1                	div    %ecx
  801c57:	89 c6                	mov    %eax,%esi
  801c59:	89 e8                	mov    %ebp,%eax
  801c5b:	89 f7                	mov    %esi,%edi
  801c5d:	f7 f1                	div    %ecx
  801c5f:	89 fa                	mov    %edi,%edx
  801c61:	83 c4 1c             	add    $0x1c,%esp
  801c64:	5b                   	pop    %ebx
  801c65:	5e                   	pop    %esi
  801c66:	5f                   	pop    %edi
  801c67:	5d                   	pop    %ebp
  801c68:	c3                   	ret    
  801c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c70:	89 f9                	mov    %edi,%ecx
  801c72:	ba 20 00 00 00       	mov    $0x20,%edx
  801c77:	29 fa                	sub    %edi,%edx
  801c79:	d3 e0                	shl    %cl,%eax
  801c7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c7f:	89 d1                	mov    %edx,%ecx
  801c81:	89 d8                	mov    %ebx,%eax
  801c83:	d3 e8                	shr    %cl,%eax
  801c85:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c89:	09 c1                	or     %eax,%ecx
  801c8b:	89 f0                	mov    %esi,%eax
  801c8d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c91:	89 f9                	mov    %edi,%ecx
  801c93:	d3 e3                	shl    %cl,%ebx
  801c95:	89 d1                	mov    %edx,%ecx
  801c97:	d3 e8                	shr    %cl,%eax
  801c99:	89 f9                	mov    %edi,%ecx
  801c9b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c9f:	89 eb                	mov    %ebp,%ebx
  801ca1:	d3 e6                	shl    %cl,%esi
  801ca3:	89 d1                	mov    %edx,%ecx
  801ca5:	d3 eb                	shr    %cl,%ebx
  801ca7:	09 f3                	or     %esi,%ebx
  801ca9:	89 c6                	mov    %eax,%esi
  801cab:	89 f2                	mov    %esi,%edx
  801cad:	89 d8                	mov    %ebx,%eax
  801caf:	f7 74 24 08          	divl   0x8(%esp)
  801cb3:	89 d6                	mov    %edx,%esi
  801cb5:	89 c3                	mov    %eax,%ebx
  801cb7:	f7 64 24 0c          	mull   0xc(%esp)
  801cbb:	39 d6                	cmp    %edx,%esi
  801cbd:	72 19                	jb     801cd8 <__udivdi3+0x108>
  801cbf:	89 f9                	mov    %edi,%ecx
  801cc1:	d3 e5                	shl    %cl,%ebp
  801cc3:	39 c5                	cmp    %eax,%ebp
  801cc5:	73 04                	jae    801ccb <__udivdi3+0xfb>
  801cc7:	39 d6                	cmp    %edx,%esi
  801cc9:	74 0d                	je     801cd8 <__udivdi3+0x108>
  801ccb:	89 d8                	mov    %ebx,%eax
  801ccd:	31 ff                	xor    %edi,%edi
  801ccf:	e9 3c ff ff ff       	jmp    801c10 <__udivdi3+0x40>
  801cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cd8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801cdb:	31 ff                	xor    %edi,%edi
  801cdd:	e9 2e ff ff ff       	jmp    801c10 <__udivdi3+0x40>
  801ce2:	66 90                	xchg   %ax,%ax
  801ce4:	66 90                	xchg   %ax,%ax
  801ce6:	66 90                	xchg   %ax,%ax
  801ce8:	66 90                	xchg   %ax,%ax
  801cea:	66 90                	xchg   %ax,%ax
  801cec:	66 90                	xchg   %ax,%ax
  801cee:	66 90                	xchg   %ax,%ax

00801cf0 <__umoddi3>:
  801cf0:	f3 0f 1e fb          	endbr32 
  801cf4:	55                   	push   %ebp
  801cf5:	57                   	push   %edi
  801cf6:	56                   	push   %esi
  801cf7:	53                   	push   %ebx
  801cf8:	83 ec 1c             	sub    $0x1c,%esp
  801cfb:	8b 74 24 30          	mov    0x30(%esp),%esi
  801cff:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d03:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801d07:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801d0b:	89 f0                	mov    %esi,%eax
  801d0d:	89 da                	mov    %ebx,%edx
  801d0f:	85 ff                	test   %edi,%edi
  801d11:	75 15                	jne    801d28 <__umoddi3+0x38>
  801d13:	39 dd                	cmp    %ebx,%ebp
  801d15:	76 39                	jbe    801d50 <__umoddi3+0x60>
  801d17:	f7 f5                	div    %ebp
  801d19:	89 d0                	mov    %edx,%eax
  801d1b:	31 d2                	xor    %edx,%edx
  801d1d:	83 c4 1c             	add    $0x1c,%esp
  801d20:	5b                   	pop    %ebx
  801d21:	5e                   	pop    %esi
  801d22:	5f                   	pop    %edi
  801d23:	5d                   	pop    %ebp
  801d24:	c3                   	ret    
  801d25:	8d 76 00             	lea    0x0(%esi),%esi
  801d28:	39 df                	cmp    %ebx,%edi
  801d2a:	77 f1                	ja     801d1d <__umoddi3+0x2d>
  801d2c:	0f bd cf             	bsr    %edi,%ecx
  801d2f:	83 f1 1f             	xor    $0x1f,%ecx
  801d32:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801d36:	75 40                	jne    801d78 <__umoddi3+0x88>
  801d38:	39 df                	cmp    %ebx,%edi
  801d3a:	72 04                	jb     801d40 <__umoddi3+0x50>
  801d3c:	39 f5                	cmp    %esi,%ebp
  801d3e:	77 dd                	ja     801d1d <__umoddi3+0x2d>
  801d40:	89 da                	mov    %ebx,%edx
  801d42:	89 f0                	mov    %esi,%eax
  801d44:	29 e8                	sub    %ebp,%eax
  801d46:	19 fa                	sbb    %edi,%edx
  801d48:	eb d3                	jmp    801d1d <__umoddi3+0x2d>
  801d4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d50:	89 e9                	mov    %ebp,%ecx
  801d52:	85 ed                	test   %ebp,%ebp
  801d54:	75 0b                	jne    801d61 <__umoddi3+0x71>
  801d56:	b8 01 00 00 00       	mov    $0x1,%eax
  801d5b:	31 d2                	xor    %edx,%edx
  801d5d:	f7 f5                	div    %ebp
  801d5f:	89 c1                	mov    %eax,%ecx
  801d61:	89 d8                	mov    %ebx,%eax
  801d63:	31 d2                	xor    %edx,%edx
  801d65:	f7 f1                	div    %ecx
  801d67:	89 f0                	mov    %esi,%eax
  801d69:	f7 f1                	div    %ecx
  801d6b:	89 d0                	mov    %edx,%eax
  801d6d:	31 d2                	xor    %edx,%edx
  801d6f:	eb ac                	jmp    801d1d <__umoddi3+0x2d>
  801d71:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d78:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d7c:	ba 20 00 00 00       	mov    $0x20,%edx
  801d81:	29 c2                	sub    %eax,%edx
  801d83:	89 c1                	mov    %eax,%ecx
  801d85:	89 e8                	mov    %ebp,%eax
  801d87:	d3 e7                	shl    %cl,%edi
  801d89:	89 d1                	mov    %edx,%ecx
  801d8b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801d8f:	d3 e8                	shr    %cl,%eax
  801d91:	89 c1                	mov    %eax,%ecx
  801d93:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d97:	09 f9                	or     %edi,%ecx
  801d99:	89 df                	mov    %ebx,%edi
  801d9b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d9f:	89 c1                	mov    %eax,%ecx
  801da1:	d3 e5                	shl    %cl,%ebp
  801da3:	89 d1                	mov    %edx,%ecx
  801da5:	d3 ef                	shr    %cl,%edi
  801da7:	89 c1                	mov    %eax,%ecx
  801da9:	89 f0                	mov    %esi,%eax
  801dab:	d3 e3                	shl    %cl,%ebx
  801dad:	89 d1                	mov    %edx,%ecx
  801daf:	89 fa                	mov    %edi,%edx
  801db1:	d3 e8                	shr    %cl,%eax
  801db3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801db8:	09 d8                	or     %ebx,%eax
  801dba:	f7 74 24 08          	divl   0x8(%esp)
  801dbe:	89 d3                	mov    %edx,%ebx
  801dc0:	d3 e6                	shl    %cl,%esi
  801dc2:	f7 e5                	mul    %ebp
  801dc4:	89 c7                	mov    %eax,%edi
  801dc6:	89 d1                	mov    %edx,%ecx
  801dc8:	39 d3                	cmp    %edx,%ebx
  801dca:	72 06                	jb     801dd2 <__umoddi3+0xe2>
  801dcc:	75 0e                	jne    801ddc <__umoddi3+0xec>
  801dce:	39 c6                	cmp    %eax,%esi
  801dd0:	73 0a                	jae    801ddc <__umoddi3+0xec>
  801dd2:	29 e8                	sub    %ebp,%eax
  801dd4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801dd8:	89 d1                	mov    %edx,%ecx
  801dda:	89 c7                	mov    %eax,%edi
  801ddc:	89 f5                	mov    %esi,%ebp
  801dde:	8b 74 24 04          	mov    0x4(%esp),%esi
  801de2:	29 fd                	sub    %edi,%ebp
  801de4:	19 cb                	sbb    %ecx,%ebx
  801de6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801deb:	89 d8                	mov    %ebx,%eax
  801ded:	d3 e0                	shl    %cl,%eax
  801def:	89 f1                	mov    %esi,%ecx
  801df1:	d3 ed                	shr    %cl,%ebp
  801df3:	d3 eb                	shr    %cl,%ebx
  801df5:	09 e8                	or     %ebp,%eax
  801df7:	89 da                	mov    %ebx,%edx
  801df9:	83 c4 1c             	add    $0x1c,%esp
  801dfc:	5b                   	pop    %ebx
  801dfd:	5e                   	pop    %esi
  801dfe:	5f                   	pop    %edi
  801dff:	5d                   	pop    %ebp
  801e00:	c3                   	ret    
