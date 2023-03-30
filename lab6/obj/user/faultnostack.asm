
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
  800039:	68 c2 03 80 00       	push   $0x8003c2
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
  8000a0:	e8 14 05 00 00       	call   8005b9 <close_all>
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
  800121:	68 ea 22 80 00       	push   $0x8022ea
  800126:	6a 2a                	push   $0x2a
  800128:	68 07 23 80 00       	push   $0x802307
  80012d:	e8 c4 13 00 00       	call   8014f6 <_panic>

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
  8001a2:	68 ea 22 80 00       	push   $0x8022ea
  8001a7:	6a 2a                	push   $0x2a
  8001a9:	68 07 23 80 00       	push   $0x802307
  8001ae:	e8 43 13 00 00       	call   8014f6 <_panic>

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
  8001e4:	68 ea 22 80 00       	push   $0x8022ea
  8001e9:	6a 2a                	push   $0x2a
  8001eb:	68 07 23 80 00       	push   $0x802307
  8001f0:	e8 01 13 00 00       	call   8014f6 <_panic>

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
  800226:	68 ea 22 80 00       	push   $0x8022ea
  80022b:	6a 2a                	push   $0x2a
  80022d:	68 07 23 80 00       	push   $0x802307
  800232:	e8 bf 12 00 00       	call   8014f6 <_panic>

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
  800268:	68 ea 22 80 00       	push   $0x8022ea
  80026d:	6a 2a                	push   $0x2a
  80026f:	68 07 23 80 00       	push   $0x802307
  800274:	e8 7d 12 00 00       	call   8014f6 <_panic>

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
  8002aa:	68 ea 22 80 00       	push   $0x8022ea
  8002af:	6a 2a                	push   $0x2a
  8002b1:	68 07 23 80 00       	push   $0x802307
  8002b6:	e8 3b 12 00 00       	call   8014f6 <_panic>

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
  8002ec:	68 ea 22 80 00       	push   $0x8022ea
  8002f1:	6a 2a                	push   $0x2a
  8002f3:	68 07 23 80 00       	push   $0x802307
  8002f8:	e8 f9 11 00 00       	call   8014f6 <_panic>

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
  800350:	68 ea 22 80 00       	push   $0x8022ea
  800355:	6a 2a                	push   $0x2a
  800357:	68 07 23 80 00       	push   $0x802307
  80035c:	e8 95 11 00 00       	call   8014f6 <_panic>

00800361 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	57                   	push   %edi
  800365:	56                   	push   %esi
  800366:	53                   	push   %ebx
	asm volatile("int %1\n"
  800367:	ba 00 00 00 00       	mov    $0x0,%edx
  80036c:	b8 0e 00 00 00       	mov    $0xe,%eax
  800371:	89 d1                	mov    %edx,%ecx
  800373:	89 d3                	mov    %edx,%ebx
  800375:	89 d7                	mov    %edx,%edi
  800377:	89 d6                	mov    %edx,%esi
  800379:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80037b:	5b                   	pop    %ebx
  80037c:	5e                   	pop    %esi
  80037d:	5f                   	pop    %edi
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	57                   	push   %edi
  800384:	56                   	push   %esi
  800385:	53                   	push   %ebx
	asm volatile("int %1\n"
  800386:	bb 00 00 00 00       	mov    $0x0,%ebx
  80038b:	8b 55 08             	mov    0x8(%ebp),%edx
  80038e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800391:	b8 0f 00 00 00       	mov    $0xf,%eax
  800396:	89 df                	mov    %ebx,%edi
  800398:	89 de                	mov    %ebx,%esi
  80039a:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  80039c:	5b                   	pop    %ebx
  80039d:	5e                   	pop    %esi
  80039e:	5f                   	pop    %edi
  80039f:	5d                   	pop    %ebp
  8003a0:	c3                   	ret    

008003a1 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
  8003a4:	57                   	push   %edi
  8003a5:	56                   	push   %esi
  8003a6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8003a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8003af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003b2:	b8 10 00 00 00       	mov    $0x10,%eax
  8003b7:	89 df                	mov    %ebx,%edi
  8003b9:	89 de                	mov    %ebx,%esi
  8003bb:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8003bd:	5b                   	pop    %ebx
  8003be:	5e                   	pop    %esi
  8003bf:	5f                   	pop    %edi
  8003c0:	5d                   	pop    %ebp
  8003c1:	c3                   	ret    

008003c2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8003c2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8003c3:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  8003c8:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8003ca:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  8003cd:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  8003d1:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  8003d4:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  8003d8:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  8003dc:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  8003de:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  8003e1:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  8003e2:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  8003e5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  8003e6:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  8003e7:	c3                   	ret    

008003e8 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ee:	05 00 00 00 30       	add    $0x30000000,%eax
  8003f3:	c1 e8 0c             	shr    $0xc,%eax
}
  8003f6:	5d                   	pop    %ebp
  8003f7:	c3                   	ret    

008003f8 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003f8:	55                   	push   %ebp
  8003f9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fe:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800403:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800408:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80040d:	5d                   	pop    %ebp
  80040e:	c3                   	ret    

0080040f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80040f:	55                   	push   %ebp
  800410:	89 e5                	mov    %esp,%ebp
  800412:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 16             	shr    $0x16,%edx
  80041c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800423:	f6 c2 01             	test   $0x1,%dl
  800426:	74 29                	je     800451 <fd_alloc+0x42>
  800428:	89 c2                	mov    %eax,%edx
  80042a:	c1 ea 0c             	shr    $0xc,%edx
  80042d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800434:	f6 c2 01             	test   $0x1,%dl
  800437:	74 18                	je     800451 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800439:	05 00 10 00 00       	add    $0x1000,%eax
  80043e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800443:	75 d2                	jne    800417 <fd_alloc+0x8>
  800445:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80044a:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80044f:	eb 05                	jmp    800456 <fd_alloc+0x47>
			return 0;
  800451:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800456:	8b 55 08             	mov    0x8(%ebp),%edx
  800459:	89 02                	mov    %eax,(%edx)
}
  80045b:	89 c8                	mov    %ecx,%eax
  80045d:	5d                   	pop    %ebp
  80045e:	c3                   	ret    

0080045f <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80045f:	55                   	push   %ebp
  800460:	89 e5                	mov    %esp,%ebp
  800462:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800465:	83 f8 1f             	cmp    $0x1f,%eax
  800468:	77 30                	ja     80049a <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80046a:	c1 e0 0c             	shl    $0xc,%eax
  80046d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800472:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800478:	f6 c2 01             	test   $0x1,%dl
  80047b:	74 24                	je     8004a1 <fd_lookup+0x42>
  80047d:	89 c2                	mov    %eax,%edx
  80047f:	c1 ea 0c             	shr    $0xc,%edx
  800482:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800489:	f6 c2 01             	test   $0x1,%dl
  80048c:	74 1a                	je     8004a8 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80048e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800491:	89 02                	mov    %eax,(%edx)
	return 0;
  800493:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800498:	5d                   	pop    %ebp
  800499:	c3                   	ret    
		return -E_INVAL;
  80049a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80049f:	eb f7                	jmp    800498 <fd_lookup+0x39>
		return -E_INVAL;
  8004a1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004a6:	eb f0                	jmp    800498 <fd_lookup+0x39>
  8004a8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004ad:	eb e9                	jmp    800498 <fd_lookup+0x39>

008004af <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004af:	55                   	push   %ebp
  8004b0:	89 e5                	mov    %esp,%ebp
  8004b2:	53                   	push   %ebx
  8004b3:	83 ec 04             	sub    $0x4,%esp
  8004b6:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004be:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8004c3:	39 13                	cmp    %edx,(%ebx)
  8004c5:	74 37                	je     8004fe <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8004c7:	83 c0 01             	add    $0x1,%eax
  8004ca:	8b 1c 85 94 23 80 00 	mov    0x802394(,%eax,4),%ebx
  8004d1:	85 db                	test   %ebx,%ebx
  8004d3:	75 ee                	jne    8004c3 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004d5:	a1 00 40 80 00       	mov    0x804000,%eax
  8004da:	8b 40 48             	mov    0x48(%eax),%eax
  8004dd:	83 ec 04             	sub    $0x4,%esp
  8004e0:	52                   	push   %edx
  8004e1:	50                   	push   %eax
  8004e2:	68 18 23 80 00       	push   $0x802318
  8004e7:	e8 e5 10 00 00       	call   8015d1 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8004ec:	83 c4 10             	add    $0x10,%esp
  8004ef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8004f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f7:	89 1a                	mov    %ebx,(%edx)
}
  8004f9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004fc:	c9                   	leave  
  8004fd:	c3                   	ret    
			return 0;
  8004fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800503:	eb ef                	jmp    8004f4 <dev_lookup+0x45>

00800505 <fd_close>:
{
  800505:	55                   	push   %ebp
  800506:	89 e5                	mov    %esp,%ebp
  800508:	57                   	push   %edi
  800509:	56                   	push   %esi
  80050a:	53                   	push   %ebx
  80050b:	83 ec 24             	sub    $0x24,%esp
  80050e:	8b 75 08             	mov    0x8(%ebp),%esi
  800511:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800514:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800517:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800518:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80051e:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800521:	50                   	push   %eax
  800522:	e8 38 ff ff ff       	call   80045f <fd_lookup>
  800527:	89 c3                	mov    %eax,%ebx
  800529:	83 c4 10             	add    $0x10,%esp
  80052c:	85 c0                	test   %eax,%eax
  80052e:	78 05                	js     800535 <fd_close+0x30>
	    || fd != fd2)
  800530:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800533:	74 16                	je     80054b <fd_close+0x46>
		return (must_exist ? r : 0);
  800535:	89 f8                	mov    %edi,%eax
  800537:	84 c0                	test   %al,%al
  800539:	b8 00 00 00 00       	mov    $0x0,%eax
  80053e:	0f 44 d8             	cmove  %eax,%ebx
}
  800541:	89 d8                	mov    %ebx,%eax
  800543:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800546:	5b                   	pop    %ebx
  800547:	5e                   	pop    %esi
  800548:	5f                   	pop    %edi
  800549:	5d                   	pop    %ebp
  80054a:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800551:	50                   	push   %eax
  800552:	ff 36                	push   (%esi)
  800554:	e8 56 ff ff ff       	call   8004af <dev_lookup>
  800559:	89 c3                	mov    %eax,%ebx
  80055b:	83 c4 10             	add    $0x10,%esp
  80055e:	85 c0                	test   %eax,%eax
  800560:	78 1a                	js     80057c <fd_close+0x77>
		if (dev->dev_close)
  800562:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800565:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800568:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80056d:	85 c0                	test   %eax,%eax
  80056f:	74 0b                	je     80057c <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800571:	83 ec 0c             	sub    $0xc,%esp
  800574:	56                   	push   %esi
  800575:	ff d0                	call   *%eax
  800577:	89 c3                	mov    %eax,%ebx
  800579:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80057c:	83 ec 08             	sub    $0x8,%esp
  80057f:	56                   	push   %esi
  800580:	6a 00                	push   $0x0
  800582:	e8 6e fc ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	eb b5                	jmp    800541 <fd_close+0x3c>

0080058c <close>:

int
close(int fdnum)
{
  80058c:	55                   	push   %ebp
  80058d:	89 e5                	mov    %esp,%ebp
  80058f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800592:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800595:	50                   	push   %eax
  800596:	ff 75 08             	push   0x8(%ebp)
  800599:	e8 c1 fe ff ff       	call   80045f <fd_lookup>
  80059e:	83 c4 10             	add    $0x10,%esp
  8005a1:	85 c0                	test   %eax,%eax
  8005a3:	79 02                	jns    8005a7 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8005a5:	c9                   	leave  
  8005a6:	c3                   	ret    
		return fd_close(fd, 1);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	6a 01                	push   $0x1
  8005ac:	ff 75 f4             	push   -0xc(%ebp)
  8005af:	e8 51 ff ff ff       	call   800505 <fd_close>
  8005b4:	83 c4 10             	add    $0x10,%esp
  8005b7:	eb ec                	jmp    8005a5 <close+0x19>

008005b9 <close_all>:

void
close_all(void)
{
  8005b9:	55                   	push   %ebp
  8005ba:	89 e5                	mov    %esp,%ebp
  8005bc:	53                   	push   %ebx
  8005bd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005c0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005c5:	83 ec 0c             	sub    $0xc,%esp
  8005c8:	53                   	push   %ebx
  8005c9:	e8 be ff ff ff       	call   80058c <close>
	for (i = 0; i < MAXFD; i++)
  8005ce:	83 c3 01             	add    $0x1,%ebx
  8005d1:	83 c4 10             	add    $0x10,%esp
  8005d4:	83 fb 20             	cmp    $0x20,%ebx
  8005d7:	75 ec                	jne    8005c5 <close_all+0xc>
}
  8005d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005dc:	c9                   	leave  
  8005dd:	c3                   	ret    

008005de <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005de:	55                   	push   %ebp
  8005df:	89 e5                	mov    %esp,%ebp
  8005e1:	57                   	push   %edi
  8005e2:	56                   	push   %esi
  8005e3:	53                   	push   %ebx
  8005e4:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005e7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005ea:	50                   	push   %eax
  8005eb:	ff 75 08             	push   0x8(%ebp)
  8005ee:	e8 6c fe ff ff       	call   80045f <fd_lookup>
  8005f3:	89 c3                	mov    %eax,%ebx
  8005f5:	83 c4 10             	add    $0x10,%esp
  8005f8:	85 c0                	test   %eax,%eax
  8005fa:	78 7f                	js     80067b <dup+0x9d>
		return r;
	close(newfdnum);
  8005fc:	83 ec 0c             	sub    $0xc,%esp
  8005ff:	ff 75 0c             	push   0xc(%ebp)
  800602:	e8 85 ff ff ff       	call   80058c <close>

	newfd = INDEX2FD(newfdnum);
  800607:	8b 75 0c             	mov    0xc(%ebp),%esi
  80060a:	c1 e6 0c             	shl    $0xc,%esi
  80060d:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800613:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800616:	89 3c 24             	mov    %edi,(%esp)
  800619:	e8 da fd ff ff       	call   8003f8 <fd2data>
  80061e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800620:	89 34 24             	mov    %esi,(%esp)
  800623:	e8 d0 fd ff ff       	call   8003f8 <fd2data>
  800628:	83 c4 10             	add    $0x10,%esp
  80062b:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80062e:	89 d8                	mov    %ebx,%eax
  800630:	c1 e8 16             	shr    $0x16,%eax
  800633:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80063a:	a8 01                	test   $0x1,%al
  80063c:	74 11                	je     80064f <dup+0x71>
  80063e:	89 d8                	mov    %ebx,%eax
  800640:	c1 e8 0c             	shr    $0xc,%eax
  800643:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80064a:	f6 c2 01             	test   $0x1,%dl
  80064d:	75 36                	jne    800685 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80064f:	89 f8                	mov    %edi,%eax
  800651:	c1 e8 0c             	shr    $0xc,%eax
  800654:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80065b:	83 ec 0c             	sub    $0xc,%esp
  80065e:	25 07 0e 00 00       	and    $0xe07,%eax
  800663:	50                   	push   %eax
  800664:	56                   	push   %esi
  800665:	6a 00                	push   $0x0
  800667:	57                   	push   %edi
  800668:	6a 00                	push   $0x0
  80066a:	e8 44 fb ff ff       	call   8001b3 <sys_page_map>
  80066f:	89 c3                	mov    %eax,%ebx
  800671:	83 c4 20             	add    $0x20,%esp
  800674:	85 c0                	test   %eax,%eax
  800676:	78 33                	js     8006ab <dup+0xcd>
		goto err;

	return newfdnum;
  800678:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80067b:	89 d8                	mov    %ebx,%eax
  80067d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800680:	5b                   	pop    %ebx
  800681:	5e                   	pop    %esi
  800682:	5f                   	pop    %edi
  800683:	5d                   	pop    %ebp
  800684:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800685:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80068c:	83 ec 0c             	sub    $0xc,%esp
  80068f:	25 07 0e 00 00       	and    $0xe07,%eax
  800694:	50                   	push   %eax
  800695:	ff 75 d4             	push   -0x2c(%ebp)
  800698:	6a 00                	push   $0x0
  80069a:	53                   	push   %ebx
  80069b:	6a 00                	push   $0x0
  80069d:	e8 11 fb ff ff       	call   8001b3 <sys_page_map>
  8006a2:	89 c3                	mov    %eax,%ebx
  8006a4:	83 c4 20             	add    $0x20,%esp
  8006a7:	85 c0                	test   %eax,%eax
  8006a9:	79 a4                	jns    80064f <dup+0x71>
	sys_page_unmap(0, newfd);
  8006ab:	83 ec 08             	sub    $0x8,%esp
  8006ae:	56                   	push   %esi
  8006af:	6a 00                	push   $0x0
  8006b1:	e8 3f fb ff ff       	call   8001f5 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006b6:	83 c4 08             	add    $0x8,%esp
  8006b9:	ff 75 d4             	push   -0x2c(%ebp)
  8006bc:	6a 00                	push   $0x0
  8006be:	e8 32 fb ff ff       	call   8001f5 <sys_page_unmap>
	return r;
  8006c3:	83 c4 10             	add    $0x10,%esp
  8006c6:	eb b3                	jmp    80067b <dup+0x9d>

008006c8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	56                   	push   %esi
  8006cc:	53                   	push   %ebx
  8006cd:	83 ec 18             	sub    $0x18,%esp
  8006d0:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006d3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006d6:	50                   	push   %eax
  8006d7:	56                   	push   %esi
  8006d8:	e8 82 fd ff ff       	call   80045f <fd_lookup>
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	78 3c                	js     800720 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e4:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8006e7:	83 ec 08             	sub    $0x8,%esp
  8006ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006ed:	50                   	push   %eax
  8006ee:	ff 33                	push   (%ebx)
  8006f0:	e8 ba fd ff ff       	call   8004af <dev_lookup>
  8006f5:	83 c4 10             	add    $0x10,%esp
  8006f8:	85 c0                	test   %eax,%eax
  8006fa:	78 24                	js     800720 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006fc:	8b 43 08             	mov    0x8(%ebx),%eax
  8006ff:	83 e0 03             	and    $0x3,%eax
  800702:	83 f8 01             	cmp    $0x1,%eax
  800705:	74 20                	je     800727 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800707:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070a:	8b 40 08             	mov    0x8(%eax),%eax
  80070d:	85 c0                	test   %eax,%eax
  80070f:	74 37                	je     800748 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800711:	83 ec 04             	sub    $0x4,%esp
  800714:	ff 75 10             	push   0x10(%ebp)
  800717:	ff 75 0c             	push   0xc(%ebp)
  80071a:	53                   	push   %ebx
  80071b:	ff d0                	call   *%eax
  80071d:	83 c4 10             	add    $0x10,%esp
}
  800720:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800723:	5b                   	pop    %ebx
  800724:	5e                   	pop    %esi
  800725:	5d                   	pop    %ebp
  800726:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800727:	a1 00 40 80 00       	mov    0x804000,%eax
  80072c:	8b 40 48             	mov    0x48(%eax),%eax
  80072f:	83 ec 04             	sub    $0x4,%esp
  800732:	56                   	push   %esi
  800733:	50                   	push   %eax
  800734:	68 59 23 80 00       	push   $0x802359
  800739:	e8 93 0e 00 00       	call   8015d1 <cprintf>
		return -E_INVAL;
  80073e:	83 c4 10             	add    $0x10,%esp
  800741:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800746:	eb d8                	jmp    800720 <read+0x58>
		return -E_NOT_SUPP;
  800748:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80074d:	eb d1                	jmp    800720 <read+0x58>

0080074f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80074f:	55                   	push   %ebp
  800750:	89 e5                	mov    %esp,%ebp
  800752:	57                   	push   %edi
  800753:	56                   	push   %esi
  800754:	53                   	push   %ebx
  800755:	83 ec 0c             	sub    $0xc,%esp
  800758:	8b 7d 08             	mov    0x8(%ebp),%edi
  80075b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80075e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800763:	eb 02                	jmp    800767 <readn+0x18>
  800765:	01 c3                	add    %eax,%ebx
  800767:	39 f3                	cmp    %esi,%ebx
  800769:	73 21                	jae    80078c <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80076b:	83 ec 04             	sub    $0x4,%esp
  80076e:	89 f0                	mov    %esi,%eax
  800770:	29 d8                	sub    %ebx,%eax
  800772:	50                   	push   %eax
  800773:	89 d8                	mov    %ebx,%eax
  800775:	03 45 0c             	add    0xc(%ebp),%eax
  800778:	50                   	push   %eax
  800779:	57                   	push   %edi
  80077a:	e8 49 ff ff ff       	call   8006c8 <read>
		if (m < 0)
  80077f:	83 c4 10             	add    $0x10,%esp
  800782:	85 c0                	test   %eax,%eax
  800784:	78 04                	js     80078a <readn+0x3b>
			return m;
		if (m == 0)
  800786:	75 dd                	jne    800765 <readn+0x16>
  800788:	eb 02                	jmp    80078c <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80078a:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80078c:	89 d8                	mov    %ebx,%eax
  80078e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800791:	5b                   	pop    %ebx
  800792:	5e                   	pop    %esi
  800793:	5f                   	pop    %edi
  800794:	5d                   	pop    %ebp
  800795:	c3                   	ret    

00800796 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	56                   	push   %esi
  80079a:	53                   	push   %ebx
  80079b:	83 ec 18             	sub    $0x18,%esp
  80079e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007a4:	50                   	push   %eax
  8007a5:	53                   	push   %ebx
  8007a6:	e8 b4 fc ff ff       	call   80045f <fd_lookup>
  8007ab:	83 c4 10             	add    $0x10,%esp
  8007ae:	85 c0                	test   %eax,%eax
  8007b0:	78 37                	js     8007e9 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007bb:	50                   	push   %eax
  8007bc:	ff 36                	push   (%esi)
  8007be:	e8 ec fc ff ff       	call   8004af <dev_lookup>
  8007c3:	83 c4 10             	add    $0x10,%esp
  8007c6:	85 c0                	test   %eax,%eax
  8007c8:	78 1f                	js     8007e9 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ca:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8007ce:	74 20                	je     8007f0 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d3:	8b 40 0c             	mov    0xc(%eax),%eax
  8007d6:	85 c0                	test   %eax,%eax
  8007d8:	74 37                	je     800811 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007da:	83 ec 04             	sub    $0x4,%esp
  8007dd:	ff 75 10             	push   0x10(%ebp)
  8007e0:	ff 75 0c             	push   0xc(%ebp)
  8007e3:	56                   	push   %esi
  8007e4:	ff d0                	call   *%eax
  8007e6:	83 c4 10             	add    $0x10,%esp
}
  8007e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007ec:	5b                   	pop    %ebx
  8007ed:	5e                   	pop    %esi
  8007ee:	5d                   	pop    %ebp
  8007ef:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007f0:	a1 00 40 80 00       	mov    0x804000,%eax
  8007f5:	8b 40 48             	mov    0x48(%eax),%eax
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	53                   	push   %ebx
  8007fc:	50                   	push   %eax
  8007fd:	68 75 23 80 00       	push   $0x802375
  800802:	e8 ca 0d 00 00       	call   8015d1 <cprintf>
		return -E_INVAL;
  800807:	83 c4 10             	add    $0x10,%esp
  80080a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80080f:	eb d8                	jmp    8007e9 <write+0x53>
		return -E_NOT_SUPP;
  800811:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800816:	eb d1                	jmp    8007e9 <write+0x53>

00800818 <seek>:

int
seek(int fdnum, off_t offset)
{
  800818:	55                   	push   %ebp
  800819:	89 e5                	mov    %esp,%ebp
  80081b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80081e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800821:	50                   	push   %eax
  800822:	ff 75 08             	push   0x8(%ebp)
  800825:	e8 35 fc ff ff       	call   80045f <fd_lookup>
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	85 c0                	test   %eax,%eax
  80082f:	78 0e                	js     80083f <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800831:	8b 55 0c             	mov    0xc(%ebp),%edx
  800834:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800837:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80083a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80083f:	c9                   	leave  
  800840:	c3                   	ret    

00800841 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	56                   	push   %esi
  800845:	53                   	push   %ebx
  800846:	83 ec 18             	sub    $0x18,%esp
  800849:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80084c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80084f:	50                   	push   %eax
  800850:	53                   	push   %ebx
  800851:	e8 09 fc ff ff       	call   80045f <fd_lookup>
  800856:	83 c4 10             	add    $0x10,%esp
  800859:	85 c0                	test   %eax,%eax
  80085b:	78 34                	js     800891 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085d:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800860:	83 ec 08             	sub    $0x8,%esp
  800863:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800866:	50                   	push   %eax
  800867:	ff 36                	push   (%esi)
  800869:	e8 41 fc ff ff       	call   8004af <dev_lookup>
  80086e:	83 c4 10             	add    $0x10,%esp
  800871:	85 c0                	test   %eax,%eax
  800873:	78 1c                	js     800891 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800875:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800879:	74 1d                	je     800898 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80087b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087e:	8b 40 18             	mov    0x18(%eax),%eax
  800881:	85 c0                	test   %eax,%eax
  800883:	74 34                	je     8008b9 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	ff 75 0c             	push   0xc(%ebp)
  80088b:	56                   	push   %esi
  80088c:	ff d0                	call   *%eax
  80088e:	83 c4 10             	add    $0x10,%esp
}
  800891:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800894:	5b                   	pop    %ebx
  800895:	5e                   	pop    %esi
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    
			thisenv->env_id, fdnum);
  800898:	a1 00 40 80 00       	mov    0x804000,%eax
  80089d:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008a0:	83 ec 04             	sub    $0x4,%esp
  8008a3:	53                   	push   %ebx
  8008a4:	50                   	push   %eax
  8008a5:	68 38 23 80 00       	push   $0x802338
  8008aa:	e8 22 0d 00 00       	call   8015d1 <cprintf>
		return -E_INVAL;
  8008af:	83 c4 10             	add    $0x10,%esp
  8008b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008b7:	eb d8                	jmp    800891 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8008b9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008be:	eb d1                	jmp    800891 <ftruncate+0x50>

008008c0 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	56                   	push   %esi
  8008c4:	53                   	push   %ebx
  8008c5:	83 ec 18             	sub    $0x18,%esp
  8008c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008ce:	50                   	push   %eax
  8008cf:	ff 75 08             	push   0x8(%ebp)
  8008d2:	e8 88 fb ff ff       	call   80045f <fd_lookup>
  8008d7:	83 c4 10             	add    $0x10,%esp
  8008da:	85 c0                	test   %eax,%eax
  8008dc:	78 49                	js     800927 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008de:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008e7:	50                   	push   %eax
  8008e8:	ff 36                	push   (%esi)
  8008ea:	e8 c0 fb ff ff       	call   8004af <dev_lookup>
  8008ef:	83 c4 10             	add    $0x10,%esp
  8008f2:	85 c0                	test   %eax,%eax
  8008f4:	78 31                	js     800927 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8008f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008f9:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008fd:	74 2f                	je     80092e <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008ff:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800902:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800909:	00 00 00 
	stat->st_isdir = 0;
  80090c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800913:	00 00 00 
	stat->st_dev = dev;
  800916:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80091c:	83 ec 08             	sub    $0x8,%esp
  80091f:	53                   	push   %ebx
  800920:	56                   	push   %esi
  800921:	ff 50 14             	call   *0x14(%eax)
  800924:	83 c4 10             	add    $0x10,%esp
}
  800927:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80092a:	5b                   	pop    %ebx
  80092b:	5e                   	pop    %esi
  80092c:	5d                   	pop    %ebp
  80092d:	c3                   	ret    
		return -E_NOT_SUPP;
  80092e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800933:	eb f2                	jmp    800927 <fstat+0x67>

00800935 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	56                   	push   %esi
  800939:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80093a:	83 ec 08             	sub    $0x8,%esp
  80093d:	6a 00                	push   $0x0
  80093f:	ff 75 08             	push   0x8(%ebp)
  800942:	e8 e4 01 00 00       	call   800b2b <open>
  800947:	89 c3                	mov    %eax,%ebx
  800949:	83 c4 10             	add    $0x10,%esp
  80094c:	85 c0                	test   %eax,%eax
  80094e:	78 1b                	js     80096b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800950:	83 ec 08             	sub    $0x8,%esp
  800953:	ff 75 0c             	push   0xc(%ebp)
  800956:	50                   	push   %eax
  800957:	e8 64 ff ff ff       	call   8008c0 <fstat>
  80095c:	89 c6                	mov    %eax,%esi
	close(fd);
  80095e:	89 1c 24             	mov    %ebx,(%esp)
  800961:	e8 26 fc ff ff       	call   80058c <close>
	return r;
  800966:	83 c4 10             	add    $0x10,%esp
  800969:	89 f3                	mov    %esi,%ebx
}
  80096b:	89 d8                	mov    %ebx,%eax
  80096d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800970:	5b                   	pop    %ebx
  800971:	5e                   	pop    %esi
  800972:	5d                   	pop    %ebp
  800973:	c3                   	ret    

00800974 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800974:	55                   	push   %ebp
  800975:	89 e5                	mov    %esp,%ebp
  800977:	56                   	push   %esi
  800978:	53                   	push   %ebx
  800979:	89 c6                	mov    %eax,%esi
  80097b:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80097d:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800984:	74 27                	je     8009ad <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800986:	6a 07                	push   $0x7
  800988:	68 00 50 80 00       	push   $0x805000
  80098d:	56                   	push   %esi
  80098e:	ff 35 00 60 80 00    	push   0x806000
  800994:	e8 2f 16 00 00       	call   801fc8 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800999:	83 c4 0c             	add    $0xc,%esp
  80099c:	6a 00                	push   $0x0
  80099e:	53                   	push   %ebx
  80099f:	6a 00                	push   $0x0
  8009a1:	e8 bb 15 00 00       	call   801f61 <ipc_recv>
}
  8009a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009a9:	5b                   	pop    %ebx
  8009aa:	5e                   	pop    %esi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009ad:	83 ec 0c             	sub    $0xc,%esp
  8009b0:	6a 01                	push   $0x1
  8009b2:	e8 65 16 00 00       	call   80201c <ipc_find_env>
  8009b7:	a3 00 60 80 00       	mov    %eax,0x806000
  8009bc:	83 c4 10             	add    $0x10,%esp
  8009bf:	eb c5                	jmp    800986 <fsipc+0x12>

008009c1 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009c1:	55                   	push   %ebp
  8009c2:	89 e5                	mov    %esp,%ebp
  8009c4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8009cd:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009da:	ba 00 00 00 00       	mov    $0x0,%edx
  8009df:	b8 02 00 00 00       	mov    $0x2,%eax
  8009e4:	e8 8b ff ff ff       	call   800974 <fsipc>
}
  8009e9:	c9                   	leave  
  8009ea:	c3                   	ret    

008009eb <devfile_flush>:
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f4:	8b 40 0c             	mov    0xc(%eax),%eax
  8009f7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800a01:	b8 06 00 00 00       	mov    $0x6,%eax
  800a06:	e8 69 ff ff ff       	call   800974 <fsipc>
}
  800a0b:	c9                   	leave  
  800a0c:	c3                   	ret    

00800a0d <devfile_stat>:
{
  800a0d:	55                   	push   %ebp
  800a0e:	89 e5                	mov    %esp,%ebp
  800a10:	53                   	push   %ebx
  800a11:	83 ec 04             	sub    $0x4,%esp
  800a14:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a17:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1a:	8b 40 0c             	mov    0xc(%eax),%eax
  800a1d:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a22:	ba 00 00 00 00       	mov    $0x0,%edx
  800a27:	b8 05 00 00 00       	mov    $0x5,%eax
  800a2c:	e8 43 ff ff ff       	call   800974 <fsipc>
  800a31:	85 c0                	test   %eax,%eax
  800a33:	78 2c                	js     800a61 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a35:	83 ec 08             	sub    $0x8,%esp
  800a38:	68 00 50 80 00       	push   $0x805000
  800a3d:	53                   	push   %ebx
  800a3e:	e8 68 11 00 00       	call   801bab <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a43:	a1 80 50 80 00       	mov    0x805080,%eax
  800a48:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a4e:	a1 84 50 80 00       	mov    0x805084,%eax
  800a53:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a59:	83 c4 10             	add    $0x10,%esp
  800a5c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a61:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a64:	c9                   	leave  
  800a65:	c3                   	ret    

00800a66 <devfile_write>:
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	83 ec 0c             	sub    $0xc,%esp
  800a6c:	8b 45 10             	mov    0x10(%ebp),%eax
  800a6f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a74:	39 d0                	cmp    %edx,%eax
  800a76:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a79:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7c:	8b 52 0c             	mov    0xc(%edx),%edx
  800a7f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a85:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a8a:	50                   	push   %eax
  800a8b:	ff 75 0c             	push   0xc(%ebp)
  800a8e:	68 08 50 80 00       	push   $0x805008
  800a93:	e8 a9 12 00 00       	call   801d41 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800a98:	ba 00 00 00 00       	mov    $0x0,%edx
  800a9d:	b8 04 00 00 00       	mov    $0x4,%eax
  800aa2:	e8 cd fe ff ff       	call   800974 <fsipc>
}
  800aa7:	c9                   	leave  
  800aa8:	c3                   	ret    

00800aa9 <devfile_read>:
{
  800aa9:	55                   	push   %ebp
  800aaa:	89 e5                	mov    %esp,%ebp
  800aac:	56                   	push   %esi
  800aad:	53                   	push   %ebx
  800aae:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ab1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab4:	8b 40 0c             	mov    0xc(%eax),%eax
  800ab7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800abc:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ac2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac7:	b8 03 00 00 00       	mov    $0x3,%eax
  800acc:	e8 a3 fe ff ff       	call   800974 <fsipc>
  800ad1:	89 c3                	mov    %eax,%ebx
  800ad3:	85 c0                	test   %eax,%eax
  800ad5:	78 1f                	js     800af6 <devfile_read+0x4d>
	assert(r <= n);
  800ad7:	39 f0                	cmp    %esi,%eax
  800ad9:	77 24                	ja     800aff <devfile_read+0x56>
	assert(r <= PGSIZE);
  800adb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ae0:	7f 33                	jg     800b15 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae2:	83 ec 04             	sub    $0x4,%esp
  800ae5:	50                   	push   %eax
  800ae6:	68 00 50 80 00       	push   $0x805000
  800aeb:	ff 75 0c             	push   0xc(%ebp)
  800aee:	e8 4e 12 00 00       	call   801d41 <memmove>
	return r;
  800af3:	83 c4 10             	add    $0x10,%esp
}
  800af6:	89 d8                	mov    %ebx,%eax
  800af8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800afb:	5b                   	pop    %ebx
  800afc:	5e                   	pop    %esi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    
	assert(r <= n);
  800aff:	68 a8 23 80 00       	push   $0x8023a8
  800b04:	68 af 23 80 00       	push   $0x8023af
  800b09:	6a 7c                	push   $0x7c
  800b0b:	68 c4 23 80 00       	push   $0x8023c4
  800b10:	e8 e1 09 00 00       	call   8014f6 <_panic>
	assert(r <= PGSIZE);
  800b15:	68 cf 23 80 00       	push   $0x8023cf
  800b1a:	68 af 23 80 00       	push   $0x8023af
  800b1f:	6a 7d                	push   $0x7d
  800b21:	68 c4 23 80 00       	push   $0x8023c4
  800b26:	e8 cb 09 00 00       	call   8014f6 <_panic>

00800b2b <open>:
{
  800b2b:	55                   	push   %ebp
  800b2c:	89 e5                	mov    %esp,%ebp
  800b2e:	56                   	push   %esi
  800b2f:	53                   	push   %ebx
  800b30:	83 ec 1c             	sub    $0x1c,%esp
  800b33:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b36:	56                   	push   %esi
  800b37:	e8 34 10 00 00       	call   801b70 <strlen>
  800b3c:	83 c4 10             	add    $0x10,%esp
  800b3f:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b44:	7f 6c                	jg     800bb2 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800b46:	83 ec 0c             	sub    $0xc,%esp
  800b49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b4c:	50                   	push   %eax
  800b4d:	e8 bd f8 ff ff       	call   80040f <fd_alloc>
  800b52:	89 c3                	mov    %eax,%ebx
  800b54:	83 c4 10             	add    $0x10,%esp
  800b57:	85 c0                	test   %eax,%eax
  800b59:	78 3c                	js     800b97 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800b5b:	83 ec 08             	sub    $0x8,%esp
  800b5e:	56                   	push   %esi
  800b5f:	68 00 50 80 00       	push   $0x805000
  800b64:	e8 42 10 00 00       	call   801bab <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6c:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b71:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b74:	b8 01 00 00 00       	mov    $0x1,%eax
  800b79:	e8 f6 fd ff ff       	call   800974 <fsipc>
  800b7e:	89 c3                	mov    %eax,%ebx
  800b80:	83 c4 10             	add    $0x10,%esp
  800b83:	85 c0                	test   %eax,%eax
  800b85:	78 19                	js     800ba0 <open+0x75>
	return fd2num(fd);
  800b87:	83 ec 0c             	sub    $0xc,%esp
  800b8a:	ff 75 f4             	push   -0xc(%ebp)
  800b8d:	e8 56 f8 ff ff       	call   8003e8 <fd2num>
  800b92:	89 c3                	mov    %eax,%ebx
  800b94:	83 c4 10             	add    $0x10,%esp
}
  800b97:	89 d8                	mov    %ebx,%eax
  800b99:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b9c:	5b                   	pop    %ebx
  800b9d:	5e                   	pop    %esi
  800b9e:	5d                   	pop    %ebp
  800b9f:	c3                   	ret    
		fd_close(fd, 0);
  800ba0:	83 ec 08             	sub    $0x8,%esp
  800ba3:	6a 00                	push   $0x0
  800ba5:	ff 75 f4             	push   -0xc(%ebp)
  800ba8:	e8 58 f9 ff ff       	call   800505 <fd_close>
		return r;
  800bad:	83 c4 10             	add    $0x10,%esp
  800bb0:	eb e5                	jmp    800b97 <open+0x6c>
		return -E_BAD_PATH;
  800bb2:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800bb7:	eb de                	jmp    800b97 <open+0x6c>

00800bb9 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bbf:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc4:	b8 08 00 00 00       	mov    $0x8,%eax
  800bc9:	e8 a6 fd ff ff       	call   800974 <fsipc>
}
  800bce:	c9                   	leave  
  800bcf:	c3                   	ret    

00800bd0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bd6:	68 db 23 80 00       	push   $0x8023db
  800bdb:	ff 75 0c             	push   0xc(%ebp)
  800bde:	e8 c8 0f 00 00       	call   801bab <strcpy>
	return 0;
}
  800be3:	b8 00 00 00 00       	mov    $0x0,%eax
  800be8:	c9                   	leave  
  800be9:	c3                   	ret    

00800bea <devsock_close>:
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	53                   	push   %ebx
  800bee:	83 ec 10             	sub    $0x10,%esp
  800bf1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bf4:	53                   	push   %ebx
  800bf5:	e8 5b 14 00 00       	call   802055 <pageref>
  800bfa:	89 c2                	mov    %eax,%edx
  800bfc:	83 c4 10             	add    $0x10,%esp
		return 0;
  800bff:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800c04:	83 fa 01             	cmp    $0x1,%edx
  800c07:	74 05                	je     800c0e <devsock_close+0x24>
}
  800c09:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c0c:	c9                   	leave  
  800c0d:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800c0e:	83 ec 0c             	sub    $0xc,%esp
  800c11:	ff 73 0c             	push   0xc(%ebx)
  800c14:	e8 b7 02 00 00       	call   800ed0 <nsipc_close>
  800c19:	83 c4 10             	add    $0x10,%esp
  800c1c:	eb eb                	jmp    800c09 <devsock_close+0x1f>

00800c1e <devsock_write>:
{
  800c1e:	55                   	push   %ebp
  800c1f:	89 e5                	mov    %esp,%ebp
  800c21:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c24:	6a 00                	push   $0x0
  800c26:	ff 75 10             	push   0x10(%ebp)
  800c29:	ff 75 0c             	push   0xc(%ebp)
  800c2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c2f:	ff 70 0c             	push   0xc(%eax)
  800c32:	e8 79 03 00 00       	call   800fb0 <nsipc_send>
}
  800c37:	c9                   	leave  
  800c38:	c3                   	ret    

00800c39 <devsock_read>:
{
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c3f:	6a 00                	push   $0x0
  800c41:	ff 75 10             	push   0x10(%ebp)
  800c44:	ff 75 0c             	push   0xc(%ebp)
  800c47:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4a:	ff 70 0c             	push   0xc(%eax)
  800c4d:	e8 ef 02 00 00       	call   800f41 <nsipc_recv>
}
  800c52:	c9                   	leave  
  800c53:	c3                   	ret    

00800c54 <fd2sockid>:
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c5a:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c5d:	52                   	push   %edx
  800c5e:	50                   	push   %eax
  800c5f:	e8 fb f7 ff ff       	call   80045f <fd_lookup>
  800c64:	83 c4 10             	add    $0x10,%esp
  800c67:	85 c0                	test   %eax,%eax
  800c69:	78 10                	js     800c7b <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800c6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c6e:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c74:	39 08                	cmp    %ecx,(%eax)
  800c76:	75 05                	jne    800c7d <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c78:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c7b:	c9                   	leave  
  800c7c:	c3                   	ret    
		return -E_NOT_SUPP;
  800c7d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c82:	eb f7                	jmp    800c7b <fd2sockid+0x27>

00800c84 <alloc_sockfd>:
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 1c             	sub    $0x1c,%esp
  800c8c:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c91:	50                   	push   %eax
  800c92:	e8 78 f7 ff ff       	call   80040f <fd_alloc>
  800c97:	89 c3                	mov    %eax,%ebx
  800c99:	83 c4 10             	add    $0x10,%esp
  800c9c:	85 c0                	test   %eax,%eax
  800c9e:	78 43                	js     800ce3 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800ca0:	83 ec 04             	sub    $0x4,%esp
  800ca3:	68 07 04 00 00       	push   $0x407
  800ca8:	ff 75 f4             	push   -0xc(%ebp)
  800cab:	6a 00                	push   $0x0
  800cad:	e8 be f4 ff ff       	call   800170 <sys_page_alloc>
  800cb2:	89 c3                	mov    %eax,%ebx
  800cb4:	83 c4 10             	add    $0x10,%esp
  800cb7:	85 c0                	test   %eax,%eax
  800cb9:	78 28                	js     800ce3 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800cbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cbe:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800cc4:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cc9:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cd0:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cd3:	83 ec 0c             	sub    $0xc,%esp
  800cd6:	50                   	push   %eax
  800cd7:	e8 0c f7 ff ff       	call   8003e8 <fd2num>
  800cdc:	89 c3                	mov    %eax,%ebx
  800cde:	83 c4 10             	add    $0x10,%esp
  800ce1:	eb 0c                	jmp    800cef <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800ce3:	83 ec 0c             	sub    $0xc,%esp
  800ce6:	56                   	push   %esi
  800ce7:	e8 e4 01 00 00       	call   800ed0 <nsipc_close>
		return r;
  800cec:	83 c4 10             	add    $0x10,%esp
}
  800cef:	89 d8                	mov    %ebx,%eax
  800cf1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cf4:	5b                   	pop    %ebx
  800cf5:	5e                   	pop    %esi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <accept>:
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800d01:	e8 4e ff ff ff       	call   800c54 <fd2sockid>
  800d06:	85 c0                	test   %eax,%eax
  800d08:	78 1b                	js     800d25 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d0a:	83 ec 04             	sub    $0x4,%esp
  800d0d:	ff 75 10             	push   0x10(%ebp)
  800d10:	ff 75 0c             	push   0xc(%ebp)
  800d13:	50                   	push   %eax
  800d14:	e8 0e 01 00 00       	call   800e27 <nsipc_accept>
  800d19:	83 c4 10             	add    $0x10,%esp
  800d1c:	85 c0                	test   %eax,%eax
  800d1e:	78 05                	js     800d25 <accept+0x2d>
	return alloc_sockfd(r);
  800d20:	e8 5f ff ff ff       	call   800c84 <alloc_sockfd>
}
  800d25:	c9                   	leave  
  800d26:	c3                   	ret    

00800d27 <bind>:
{
  800d27:	55                   	push   %ebp
  800d28:	89 e5                	mov    %esp,%ebp
  800d2a:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d2d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d30:	e8 1f ff ff ff       	call   800c54 <fd2sockid>
  800d35:	85 c0                	test   %eax,%eax
  800d37:	78 12                	js     800d4b <bind+0x24>
	return nsipc_bind(r, name, namelen);
  800d39:	83 ec 04             	sub    $0x4,%esp
  800d3c:	ff 75 10             	push   0x10(%ebp)
  800d3f:	ff 75 0c             	push   0xc(%ebp)
  800d42:	50                   	push   %eax
  800d43:	e8 31 01 00 00       	call   800e79 <nsipc_bind>
  800d48:	83 c4 10             	add    $0x10,%esp
}
  800d4b:	c9                   	leave  
  800d4c:	c3                   	ret    

00800d4d <shutdown>:
{
  800d4d:	55                   	push   %ebp
  800d4e:	89 e5                	mov    %esp,%ebp
  800d50:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d53:	8b 45 08             	mov    0x8(%ebp),%eax
  800d56:	e8 f9 fe ff ff       	call   800c54 <fd2sockid>
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	78 0f                	js     800d6e <shutdown+0x21>
	return nsipc_shutdown(r, how);
  800d5f:	83 ec 08             	sub    $0x8,%esp
  800d62:	ff 75 0c             	push   0xc(%ebp)
  800d65:	50                   	push   %eax
  800d66:	e8 43 01 00 00       	call   800eae <nsipc_shutdown>
  800d6b:	83 c4 10             	add    $0x10,%esp
}
  800d6e:	c9                   	leave  
  800d6f:	c3                   	ret    

00800d70 <connect>:
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d76:	8b 45 08             	mov    0x8(%ebp),%eax
  800d79:	e8 d6 fe ff ff       	call   800c54 <fd2sockid>
  800d7e:	85 c0                	test   %eax,%eax
  800d80:	78 12                	js     800d94 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  800d82:	83 ec 04             	sub    $0x4,%esp
  800d85:	ff 75 10             	push   0x10(%ebp)
  800d88:	ff 75 0c             	push   0xc(%ebp)
  800d8b:	50                   	push   %eax
  800d8c:	e8 59 01 00 00       	call   800eea <nsipc_connect>
  800d91:	83 c4 10             	add    $0x10,%esp
}
  800d94:	c9                   	leave  
  800d95:	c3                   	ret    

00800d96 <listen>:
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9f:	e8 b0 fe ff ff       	call   800c54 <fd2sockid>
  800da4:	85 c0                	test   %eax,%eax
  800da6:	78 0f                	js     800db7 <listen+0x21>
	return nsipc_listen(r, backlog);
  800da8:	83 ec 08             	sub    $0x8,%esp
  800dab:	ff 75 0c             	push   0xc(%ebp)
  800dae:	50                   	push   %eax
  800daf:	e8 6b 01 00 00       	call   800f1f <nsipc_listen>
  800db4:	83 c4 10             	add    $0x10,%esp
}
  800db7:	c9                   	leave  
  800db8:	c3                   	ret    

00800db9 <socket>:

int
socket(int domain, int type, int protocol)
{
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
  800dbc:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800dbf:	ff 75 10             	push   0x10(%ebp)
  800dc2:	ff 75 0c             	push   0xc(%ebp)
  800dc5:	ff 75 08             	push   0x8(%ebp)
  800dc8:	e8 41 02 00 00       	call   80100e <nsipc_socket>
  800dcd:	83 c4 10             	add    $0x10,%esp
  800dd0:	85 c0                	test   %eax,%eax
  800dd2:	78 05                	js     800dd9 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800dd4:	e8 ab fe ff ff       	call   800c84 <alloc_sockfd>
}
  800dd9:	c9                   	leave  
  800dda:	c3                   	ret    

00800ddb <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
  800dde:	53                   	push   %ebx
  800ddf:	83 ec 04             	sub    $0x4,%esp
  800de2:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800de4:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  800deb:	74 26                	je     800e13 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800ded:	6a 07                	push   $0x7
  800def:	68 00 70 80 00       	push   $0x807000
  800df4:	53                   	push   %ebx
  800df5:	ff 35 00 80 80 00    	push   0x808000
  800dfb:	e8 c8 11 00 00       	call   801fc8 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e00:	83 c4 0c             	add    $0xc,%esp
  800e03:	6a 00                	push   $0x0
  800e05:	6a 00                	push   $0x0
  800e07:	6a 00                	push   $0x0
  800e09:	e8 53 11 00 00       	call   801f61 <ipc_recv>
}
  800e0e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e11:	c9                   	leave  
  800e12:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e13:	83 ec 0c             	sub    $0xc,%esp
  800e16:	6a 02                	push   $0x2
  800e18:	e8 ff 11 00 00       	call   80201c <ipc_find_env>
  800e1d:	a3 00 80 80 00       	mov    %eax,0x808000
  800e22:	83 c4 10             	add    $0x10,%esp
  800e25:	eb c6                	jmp    800ded <nsipc+0x12>

00800e27 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e27:	55                   	push   %ebp
  800e28:	89 e5                	mov    %esp,%ebp
  800e2a:	56                   	push   %esi
  800e2b:	53                   	push   %ebx
  800e2c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e32:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e37:	8b 06                	mov    (%esi),%eax
  800e39:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e3e:	b8 01 00 00 00       	mov    $0x1,%eax
  800e43:	e8 93 ff ff ff       	call   800ddb <nsipc>
  800e48:	89 c3                	mov    %eax,%ebx
  800e4a:	85 c0                	test   %eax,%eax
  800e4c:	79 09                	jns    800e57 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800e4e:	89 d8                	mov    %ebx,%eax
  800e50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e53:	5b                   	pop    %ebx
  800e54:	5e                   	pop    %esi
  800e55:	5d                   	pop    %ebp
  800e56:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e57:	83 ec 04             	sub    $0x4,%esp
  800e5a:	ff 35 10 70 80 00    	push   0x807010
  800e60:	68 00 70 80 00       	push   $0x807000
  800e65:	ff 75 0c             	push   0xc(%ebp)
  800e68:	e8 d4 0e 00 00       	call   801d41 <memmove>
		*addrlen = ret->ret_addrlen;
  800e6d:	a1 10 70 80 00       	mov    0x807010,%eax
  800e72:	89 06                	mov    %eax,(%esi)
  800e74:	83 c4 10             	add    $0x10,%esp
	return r;
  800e77:	eb d5                	jmp    800e4e <nsipc_accept+0x27>

00800e79 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e79:	55                   	push   %ebp
  800e7a:	89 e5                	mov    %esp,%ebp
  800e7c:	53                   	push   %ebx
  800e7d:	83 ec 08             	sub    $0x8,%esp
  800e80:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e83:	8b 45 08             	mov    0x8(%ebp),%eax
  800e86:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e8b:	53                   	push   %ebx
  800e8c:	ff 75 0c             	push   0xc(%ebp)
  800e8f:	68 04 70 80 00       	push   $0x807004
  800e94:	e8 a8 0e 00 00       	call   801d41 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e99:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  800e9f:	b8 02 00 00 00       	mov    $0x2,%eax
  800ea4:	e8 32 ff ff ff       	call   800ddb <nsipc>
}
  800ea9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eac:	c9                   	leave  
  800ead:	c3                   	ret    

00800eae <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800eb4:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb7:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  800ebc:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ebf:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  800ec4:	b8 03 00 00 00       	mov    $0x3,%eax
  800ec9:	e8 0d ff ff ff       	call   800ddb <nsipc>
}
  800ece:	c9                   	leave  
  800ecf:	c3                   	ret    

00800ed0 <nsipc_close>:

int
nsipc_close(int s)
{
  800ed0:	55                   	push   %ebp
  800ed1:	89 e5                	mov    %esp,%ebp
  800ed3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ed6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ed9:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  800ede:	b8 04 00 00 00       	mov    $0x4,%eax
  800ee3:	e8 f3 fe ff ff       	call   800ddb <nsipc>
}
  800ee8:	c9                   	leave  
  800ee9:	c3                   	ret    

00800eea <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eea:	55                   	push   %ebp
  800eeb:	89 e5                	mov    %esp,%ebp
  800eed:	53                   	push   %ebx
  800eee:	83 ec 08             	sub    $0x8,%esp
  800ef1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ef4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef7:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800efc:	53                   	push   %ebx
  800efd:	ff 75 0c             	push   0xc(%ebp)
  800f00:	68 04 70 80 00       	push   $0x807004
  800f05:	e8 37 0e 00 00       	call   801d41 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f0a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  800f10:	b8 05 00 00 00       	mov    $0x5,%eax
  800f15:	e8 c1 fe ff ff       	call   800ddb <nsipc>
}
  800f1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f1d:	c9                   	leave  
  800f1e:	c3                   	ret    

00800f1f <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f1f:	55                   	push   %ebp
  800f20:	89 e5                	mov    %esp,%ebp
  800f22:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f25:	8b 45 08             	mov    0x8(%ebp),%eax
  800f28:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  800f2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f30:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  800f35:	b8 06 00 00 00       	mov    $0x6,%eax
  800f3a:	e8 9c fe ff ff       	call   800ddb <nsipc>
}
  800f3f:	c9                   	leave  
  800f40:	c3                   	ret    

00800f41 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	56                   	push   %esi
  800f45:	53                   	push   %ebx
  800f46:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f49:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4c:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  800f51:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  800f57:	8b 45 14             	mov    0x14(%ebp),%eax
  800f5a:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f5f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f64:	e8 72 fe ff ff       	call   800ddb <nsipc>
  800f69:	89 c3                	mov    %eax,%ebx
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	78 22                	js     800f91 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  800f6f:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f74:	39 c6                	cmp    %eax,%esi
  800f76:	0f 4e c6             	cmovle %esi,%eax
  800f79:	39 c3                	cmp    %eax,%ebx
  800f7b:	7f 1d                	jg     800f9a <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f7d:	83 ec 04             	sub    $0x4,%esp
  800f80:	53                   	push   %ebx
  800f81:	68 00 70 80 00       	push   $0x807000
  800f86:	ff 75 0c             	push   0xc(%ebp)
  800f89:	e8 b3 0d 00 00       	call   801d41 <memmove>
  800f8e:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f91:	89 d8                	mov    %ebx,%eax
  800f93:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f96:	5b                   	pop    %ebx
  800f97:	5e                   	pop    %esi
  800f98:	5d                   	pop    %ebp
  800f99:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f9a:	68 e7 23 80 00       	push   $0x8023e7
  800f9f:	68 af 23 80 00       	push   $0x8023af
  800fa4:	6a 62                	push   $0x62
  800fa6:	68 fc 23 80 00       	push   $0x8023fc
  800fab:	e8 46 05 00 00       	call   8014f6 <_panic>

00800fb0 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800fb0:	55                   	push   %ebp
  800fb1:	89 e5                	mov    %esp,%ebp
  800fb3:	53                   	push   %ebx
  800fb4:	83 ec 04             	sub    $0x4,%esp
  800fb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fba:	8b 45 08             	mov    0x8(%ebp),%eax
  800fbd:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  800fc2:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fc8:	7f 2e                	jg     800ff8 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fca:	83 ec 04             	sub    $0x4,%esp
  800fcd:	53                   	push   %ebx
  800fce:	ff 75 0c             	push   0xc(%ebp)
  800fd1:	68 0c 70 80 00       	push   $0x80700c
  800fd6:	e8 66 0d 00 00       	call   801d41 <memmove>
	nsipcbuf.send.req_size = size;
  800fdb:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  800fe1:	8b 45 14             	mov    0x14(%ebp),%eax
  800fe4:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  800fe9:	b8 08 00 00 00       	mov    $0x8,%eax
  800fee:	e8 e8 fd ff ff       	call   800ddb <nsipc>
}
  800ff3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff6:	c9                   	leave  
  800ff7:	c3                   	ret    
	assert(size < 1600);
  800ff8:	68 08 24 80 00       	push   $0x802408
  800ffd:	68 af 23 80 00       	push   $0x8023af
  801002:	6a 6d                	push   $0x6d
  801004:	68 fc 23 80 00       	push   $0x8023fc
  801009:	e8 e8 04 00 00       	call   8014f6 <_panic>

0080100e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80100e:	55                   	push   %ebp
  80100f:	89 e5                	mov    %esp,%ebp
  801011:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801014:	8b 45 08             	mov    0x8(%ebp),%eax
  801017:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80101c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101f:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801024:	8b 45 10             	mov    0x10(%ebp),%eax
  801027:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80102c:	b8 09 00 00 00       	mov    $0x9,%eax
  801031:	e8 a5 fd ff ff       	call   800ddb <nsipc>
}
  801036:	c9                   	leave  
  801037:	c3                   	ret    

00801038 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801038:	55                   	push   %ebp
  801039:	89 e5                	mov    %esp,%ebp
  80103b:	56                   	push   %esi
  80103c:	53                   	push   %ebx
  80103d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801040:	83 ec 0c             	sub    $0xc,%esp
  801043:	ff 75 08             	push   0x8(%ebp)
  801046:	e8 ad f3 ff ff       	call   8003f8 <fd2data>
  80104b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80104d:	83 c4 08             	add    $0x8,%esp
  801050:	68 14 24 80 00       	push   $0x802414
  801055:	53                   	push   %ebx
  801056:	e8 50 0b 00 00       	call   801bab <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80105b:	8b 46 04             	mov    0x4(%esi),%eax
  80105e:	2b 06                	sub    (%esi),%eax
  801060:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801066:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80106d:	00 00 00 
	stat->st_dev = &devpipe;
  801070:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801077:	30 80 00 
	return 0;
}
  80107a:	b8 00 00 00 00       	mov    $0x0,%eax
  80107f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801082:	5b                   	pop    %ebx
  801083:	5e                   	pop    %esi
  801084:	5d                   	pop    %ebp
  801085:	c3                   	ret    

00801086 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	53                   	push   %ebx
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801090:	53                   	push   %ebx
  801091:	6a 00                	push   $0x0
  801093:	e8 5d f1 ff ff       	call   8001f5 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801098:	89 1c 24             	mov    %ebx,(%esp)
  80109b:	e8 58 f3 ff ff       	call   8003f8 <fd2data>
  8010a0:	83 c4 08             	add    $0x8,%esp
  8010a3:	50                   	push   %eax
  8010a4:	6a 00                	push   $0x0
  8010a6:	e8 4a f1 ff ff       	call   8001f5 <sys_page_unmap>
}
  8010ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010ae:	c9                   	leave  
  8010af:	c3                   	ret    

008010b0 <_pipeisclosed>:
{
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	57                   	push   %edi
  8010b4:	56                   	push   %esi
  8010b5:	53                   	push   %ebx
  8010b6:	83 ec 1c             	sub    $0x1c,%esp
  8010b9:	89 c7                	mov    %eax,%edi
  8010bb:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8010bd:	a1 00 40 80 00       	mov    0x804000,%eax
  8010c2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8010c5:	83 ec 0c             	sub    $0xc,%esp
  8010c8:	57                   	push   %edi
  8010c9:	e8 87 0f 00 00       	call   802055 <pageref>
  8010ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010d1:	89 34 24             	mov    %esi,(%esp)
  8010d4:	e8 7c 0f 00 00       	call   802055 <pageref>
		nn = thisenv->env_runs;
  8010d9:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8010df:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010e2:	83 c4 10             	add    $0x10,%esp
  8010e5:	39 cb                	cmp    %ecx,%ebx
  8010e7:	74 1b                	je     801104 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010e9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010ec:	75 cf                	jne    8010bd <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010ee:	8b 42 58             	mov    0x58(%edx),%eax
  8010f1:	6a 01                	push   $0x1
  8010f3:	50                   	push   %eax
  8010f4:	53                   	push   %ebx
  8010f5:	68 1b 24 80 00       	push   $0x80241b
  8010fa:	e8 d2 04 00 00       	call   8015d1 <cprintf>
  8010ff:	83 c4 10             	add    $0x10,%esp
  801102:	eb b9                	jmp    8010bd <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801104:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801107:	0f 94 c0             	sete   %al
  80110a:	0f b6 c0             	movzbl %al,%eax
}
  80110d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801110:	5b                   	pop    %ebx
  801111:	5e                   	pop    %esi
  801112:	5f                   	pop    %edi
  801113:	5d                   	pop    %ebp
  801114:	c3                   	ret    

00801115 <devpipe_write>:
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	57                   	push   %edi
  801119:	56                   	push   %esi
  80111a:	53                   	push   %ebx
  80111b:	83 ec 28             	sub    $0x28,%esp
  80111e:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801121:	56                   	push   %esi
  801122:	e8 d1 f2 ff ff       	call   8003f8 <fd2data>
  801127:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801129:	83 c4 10             	add    $0x10,%esp
  80112c:	bf 00 00 00 00       	mov    $0x0,%edi
  801131:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801134:	75 09                	jne    80113f <devpipe_write+0x2a>
	return i;
  801136:	89 f8                	mov    %edi,%eax
  801138:	eb 23                	jmp    80115d <devpipe_write+0x48>
			sys_yield();
  80113a:	e8 12 f0 ff ff       	call   800151 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80113f:	8b 43 04             	mov    0x4(%ebx),%eax
  801142:	8b 0b                	mov    (%ebx),%ecx
  801144:	8d 51 20             	lea    0x20(%ecx),%edx
  801147:	39 d0                	cmp    %edx,%eax
  801149:	72 1a                	jb     801165 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  80114b:	89 da                	mov    %ebx,%edx
  80114d:	89 f0                	mov    %esi,%eax
  80114f:	e8 5c ff ff ff       	call   8010b0 <_pipeisclosed>
  801154:	85 c0                	test   %eax,%eax
  801156:	74 e2                	je     80113a <devpipe_write+0x25>
				return 0;
  801158:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80115d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801160:	5b                   	pop    %ebx
  801161:	5e                   	pop    %esi
  801162:	5f                   	pop    %edi
  801163:	5d                   	pop    %ebp
  801164:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801165:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801168:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80116c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80116f:	89 c2                	mov    %eax,%edx
  801171:	c1 fa 1f             	sar    $0x1f,%edx
  801174:	89 d1                	mov    %edx,%ecx
  801176:	c1 e9 1b             	shr    $0x1b,%ecx
  801179:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80117c:	83 e2 1f             	and    $0x1f,%edx
  80117f:	29 ca                	sub    %ecx,%edx
  801181:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801185:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801189:	83 c0 01             	add    $0x1,%eax
  80118c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80118f:	83 c7 01             	add    $0x1,%edi
  801192:	eb 9d                	jmp    801131 <devpipe_write+0x1c>

00801194 <devpipe_read>:
{
  801194:	55                   	push   %ebp
  801195:	89 e5                	mov    %esp,%ebp
  801197:	57                   	push   %edi
  801198:	56                   	push   %esi
  801199:	53                   	push   %ebx
  80119a:	83 ec 18             	sub    $0x18,%esp
  80119d:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8011a0:	57                   	push   %edi
  8011a1:	e8 52 f2 ff ff       	call   8003f8 <fd2data>
  8011a6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8011a8:	83 c4 10             	add    $0x10,%esp
  8011ab:	be 00 00 00 00       	mov    $0x0,%esi
  8011b0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8011b3:	75 13                	jne    8011c8 <devpipe_read+0x34>
	return i;
  8011b5:	89 f0                	mov    %esi,%eax
  8011b7:	eb 02                	jmp    8011bb <devpipe_read+0x27>
				return i;
  8011b9:	89 f0                	mov    %esi,%eax
}
  8011bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011be:	5b                   	pop    %ebx
  8011bf:	5e                   	pop    %esi
  8011c0:	5f                   	pop    %edi
  8011c1:	5d                   	pop    %ebp
  8011c2:	c3                   	ret    
			sys_yield();
  8011c3:	e8 89 ef ff ff       	call   800151 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8011c8:	8b 03                	mov    (%ebx),%eax
  8011ca:	3b 43 04             	cmp    0x4(%ebx),%eax
  8011cd:	75 18                	jne    8011e7 <devpipe_read+0x53>
			if (i > 0)
  8011cf:	85 f6                	test   %esi,%esi
  8011d1:	75 e6                	jne    8011b9 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8011d3:	89 da                	mov    %ebx,%edx
  8011d5:	89 f8                	mov    %edi,%eax
  8011d7:	e8 d4 fe ff ff       	call   8010b0 <_pipeisclosed>
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	74 e3                	je     8011c3 <devpipe_read+0x2f>
				return 0;
  8011e0:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e5:	eb d4                	jmp    8011bb <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011e7:	99                   	cltd   
  8011e8:	c1 ea 1b             	shr    $0x1b,%edx
  8011eb:	01 d0                	add    %edx,%eax
  8011ed:	83 e0 1f             	and    $0x1f,%eax
  8011f0:	29 d0                	sub    %edx,%eax
  8011f2:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fa:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011fd:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801200:	83 c6 01             	add    $0x1,%esi
  801203:	eb ab                	jmp    8011b0 <devpipe_read+0x1c>

00801205 <pipe>:
{
  801205:	55                   	push   %ebp
  801206:	89 e5                	mov    %esp,%ebp
  801208:	56                   	push   %esi
  801209:	53                   	push   %ebx
  80120a:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  80120d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801210:	50                   	push   %eax
  801211:	e8 f9 f1 ff ff       	call   80040f <fd_alloc>
  801216:	89 c3                	mov    %eax,%ebx
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	85 c0                	test   %eax,%eax
  80121d:	0f 88 23 01 00 00    	js     801346 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801223:	83 ec 04             	sub    $0x4,%esp
  801226:	68 07 04 00 00       	push   $0x407
  80122b:	ff 75 f4             	push   -0xc(%ebp)
  80122e:	6a 00                	push   $0x0
  801230:	e8 3b ef ff ff       	call   800170 <sys_page_alloc>
  801235:	89 c3                	mov    %eax,%ebx
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	85 c0                	test   %eax,%eax
  80123c:	0f 88 04 01 00 00    	js     801346 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801242:	83 ec 0c             	sub    $0xc,%esp
  801245:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801248:	50                   	push   %eax
  801249:	e8 c1 f1 ff ff       	call   80040f <fd_alloc>
  80124e:	89 c3                	mov    %eax,%ebx
  801250:	83 c4 10             	add    $0x10,%esp
  801253:	85 c0                	test   %eax,%eax
  801255:	0f 88 db 00 00 00    	js     801336 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80125b:	83 ec 04             	sub    $0x4,%esp
  80125e:	68 07 04 00 00       	push   $0x407
  801263:	ff 75 f0             	push   -0x10(%ebp)
  801266:	6a 00                	push   $0x0
  801268:	e8 03 ef ff ff       	call   800170 <sys_page_alloc>
  80126d:	89 c3                	mov    %eax,%ebx
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	0f 88 bc 00 00 00    	js     801336 <pipe+0x131>
	va = fd2data(fd0);
  80127a:	83 ec 0c             	sub    $0xc,%esp
  80127d:	ff 75 f4             	push   -0xc(%ebp)
  801280:	e8 73 f1 ff ff       	call   8003f8 <fd2data>
  801285:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801287:	83 c4 0c             	add    $0xc,%esp
  80128a:	68 07 04 00 00       	push   $0x407
  80128f:	50                   	push   %eax
  801290:	6a 00                	push   $0x0
  801292:	e8 d9 ee ff ff       	call   800170 <sys_page_alloc>
  801297:	89 c3                	mov    %eax,%ebx
  801299:	83 c4 10             	add    $0x10,%esp
  80129c:	85 c0                	test   %eax,%eax
  80129e:	0f 88 82 00 00 00    	js     801326 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012a4:	83 ec 0c             	sub    $0xc,%esp
  8012a7:	ff 75 f0             	push   -0x10(%ebp)
  8012aa:	e8 49 f1 ff ff       	call   8003f8 <fd2data>
  8012af:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012b6:	50                   	push   %eax
  8012b7:	6a 00                	push   $0x0
  8012b9:	56                   	push   %esi
  8012ba:	6a 00                	push   $0x0
  8012bc:	e8 f2 ee ff ff       	call   8001b3 <sys_page_map>
  8012c1:	89 c3                	mov    %eax,%ebx
  8012c3:	83 c4 20             	add    $0x20,%esp
  8012c6:	85 c0                	test   %eax,%eax
  8012c8:	78 4e                	js     801318 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8012ca:	a1 3c 30 80 00       	mov    0x80303c,%eax
  8012cf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d2:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8012d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d7:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8012de:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012e1:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012ed:	83 ec 0c             	sub    $0xc,%esp
  8012f0:	ff 75 f4             	push   -0xc(%ebp)
  8012f3:	e8 f0 f0 ff ff       	call   8003e8 <fd2num>
  8012f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012fb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012fd:	83 c4 04             	add    $0x4,%esp
  801300:	ff 75 f0             	push   -0x10(%ebp)
  801303:	e8 e0 f0 ff ff       	call   8003e8 <fd2num>
  801308:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80130b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	bb 00 00 00 00       	mov    $0x0,%ebx
  801316:	eb 2e                	jmp    801346 <pipe+0x141>
	sys_page_unmap(0, va);
  801318:	83 ec 08             	sub    $0x8,%esp
  80131b:	56                   	push   %esi
  80131c:	6a 00                	push   $0x0
  80131e:	e8 d2 ee ff ff       	call   8001f5 <sys_page_unmap>
  801323:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801326:	83 ec 08             	sub    $0x8,%esp
  801329:	ff 75 f0             	push   -0x10(%ebp)
  80132c:	6a 00                	push   $0x0
  80132e:	e8 c2 ee ff ff       	call   8001f5 <sys_page_unmap>
  801333:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801336:	83 ec 08             	sub    $0x8,%esp
  801339:	ff 75 f4             	push   -0xc(%ebp)
  80133c:	6a 00                	push   $0x0
  80133e:	e8 b2 ee ff ff       	call   8001f5 <sys_page_unmap>
  801343:	83 c4 10             	add    $0x10,%esp
}
  801346:	89 d8                	mov    %ebx,%eax
  801348:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80134b:	5b                   	pop    %ebx
  80134c:	5e                   	pop    %esi
  80134d:	5d                   	pop    %ebp
  80134e:	c3                   	ret    

0080134f <pipeisclosed>:
{
  80134f:	55                   	push   %ebp
  801350:	89 e5                	mov    %esp,%ebp
  801352:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801355:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801358:	50                   	push   %eax
  801359:	ff 75 08             	push   0x8(%ebp)
  80135c:	e8 fe f0 ff ff       	call   80045f <fd_lookup>
  801361:	83 c4 10             	add    $0x10,%esp
  801364:	85 c0                	test   %eax,%eax
  801366:	78 18                	js     801380 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801368:	83 ec 0c             	sub    $0xc,%esp
  80136b:	ff 75 f4             	push   -0xc(%ebp)
  80136e:	e8 85 f0 ff ff       	call   8003f8 <fd2data>
  801373:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801375:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801378:	e8 33 fd ff ff       	call   8010b0 <_pipeisclosed>
  80137d:	83 c4 10             	add    $0x10,%esp
}
  801380:	c9                   	leave  
  801381:	c3                   	ret    

00801382 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801382:	b8 00 00 00 00       	mov    $0x0,%eax
  801387:	c3                   	ret    

00801388 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801388:	55                   	push   %ebp
  801389:	89 e5                	mov    %esp,%ebp
  80138b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80138e:	68 33 24 80 00       	push   $0x802433
  801393:	ff 75 0c             	push   0xc(%ebp)
  801396:	e8 10 08 00 00       	call   801bab <strcpy>
	return 0;
}
  80139b:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a0:	c9                   	leave  
  8013a1:	c3                   	ret    

008013a2 <devcons_write>:
{
  8013a2:	55                   	push   %ebp
  8013a3:	89 e5                	mov    %esp,%ebp
  8013a5:	57                   	push   %edi
  8013a6:	56                   	push   %esi
  8013a7:	53                   	push   %ebx
  8013a8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8013ae:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8013b3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8013b9:	eb 2e                	jmp    8013e9 <devcons_write+0x47>
		m = n - tot;
  8013bb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013be:	29 f3                	sub    %esi,%ebx
  8013c0:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8013c5:	39 c3                	cmp    %eax,%ebx
  8013c7:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8013ca:	83 ec 04             	sub    $0x4,%esp
  8013cd:	53                   	push   %ebx
  8013ce:	89 f0                	mov    %esi,%eax
  8013d0:	03 45 0c             	add    0xc(%ebp),%eax
  8013d3:	50                   	push   %eax
  8013d4:	57                   	push   %edi
  8013d5:	e8 67 09 00 00       	call   801d41 <memmove>
		sys_cputs(buf, m);
  8013da:	83 c4 08             	add    $0x8,%esp
  8013dd:	53                   	push   %ebx
  8013de:	57                   	push   %edi
  8013df:	e8 d0 ec ff ff       	call   8000b4 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013e4:	01 de                	add    %ebx,%esi
  8013e6:	83 c4 10             	add    $0x10,%esp
  8013e9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013ec:	72 cd                	jb     8013bb <devcons_write+0x19>
}
  8013ee:	89 f0                	mov    %esi,%eax
  8013f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f3:	5b                   	pop    %ebx
  8013f4:	5e                   	pop    %esi
  8013f5:	5f                   	pop    %edi
  8013f6:	5d                   	pop    %ebp
  8013f7:	c3                   	ret    

008013f8 <devcons_read>:
{
  8013f8:	55                   	push   %ebp
  8013f9:	89 e5                	mov    %esp,%ebp
  8013fb:	83 ec 08             	sub    $0x8,%esp
  8013fe:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801403:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801407:	75 07                	jne    801410 <devcons_read+0x18>
  801409:	eb 1f                	jmp    80142a <devcons_read+0x32>
		sys_yield();
  80140b:	e8 41 ed ff ff       	call   800151 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801410:	e8 bd ec ff ff       	call   8000d2 <sys_cgetc>
  801415:	85 c0                	test   %eax,%eax
  801417:	74 f2                	je     80140b <devcons_read+0x13>
	if (c < 0)
  801419:	78 0f                	js     80142a <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  80141b:	83 f8 04             	cmp    $0x4,%eax
  80141e:	74 0c                	je     80142c <devcons_read+0x34>
	*(char*)vbuf = c;
  801420:	8b 55 0c             	mov    0xc(%ebp),%edx
  801423:	88 02                	mov    %al,(%edx)
	return 1;
  801425:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80142a:	c9                   	leave  
  80142b:	c3                   	ret    
		return 0;
  80142c:	b8 00 00 00 00       	mov    $0x0,%eax
  801431:	eb f7                	jmp    80142a <devcons_read+0x32>

00801433 <cputchar>:
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801439:	8b 45 08             	mov    0x8(%ebp),%eax
  80143c:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80143f:	6a 01                	push   $0x1
  801441:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801444:	50                   	push   %eax
  801445:	e8 6a ec ff ff       	call   8000b4 <sys_cputs>
}
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	c9                   	leave  
  80144e:	c3                   	ret    

0080144f <getchar>:
{
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801455:	6a 01                	push   $0x1
  801457:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80145a:	50                   	push   %eax
  80145b:	6a 00                	push   $0x0
  80145d:	e8 66 f2 ff ff       	call   8006c8 <read>
	if (r < 0)
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	85 c0                	test   %eax,%eax
  801467:	78 06                	js     80146f <getchar+0x20>
	if (r < 1)
  801469:	74 06                	je     801471 <getchar+0x22>
	return c;
  80146b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80146f:	c9                   	leave  
  801470:	c3                   	ret    
		return -E_EOF;
  801471:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801476:	eb f7                	jmp    80146f <getchar+0x20>

00801478 <iscons>:
{
  801478:	55                   	push   %ebp
  801479:	89 e5                	mov    %esp,%ebp
  80147b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80147e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801481:	50                   	push   %eax
  801482:	ff 75 08             	push   0x8(%ebp)
  801485:	e8 d5 ef ff ff       	call   80045f <fd_lookup>
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	85 c0                	test   %eax,%eax
  80148f:	78 11                	js     8014a2 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801491:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801494:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80149a:	39 10                	cmp    %edx,(%eax)
  80149c:	0f 94 c0             	sete   %al
  80149f:	0f b6 c0             	movzbl %al,%eax
}
  8014a2:	c9                   	leave  
  8014a3:	c3                   	ret    

008014a4 <opencons>:
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
  8014a7:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8014aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ad:	50                   	push   %eax
  8014ae:	e8 5c ef ff ff       	call   80040f <fd_alloc>
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	85 c0                	test   %eax,%eax
  8014b8:	78 3a                	js     8014f4 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014ba:	83 ec 04             	sub    $0x4,%esp
  8014bd:	68 07 04 00 00       	push   $0x407
  8014c2:	ff 75 f4             	push   -0xc(%ebp)
  8014c5:	6a 00                	push   $0x0
  8014c7:	e8 a4 ec ff ff       	call   800170 <sys_page_alloc>
  8014cc:	83 c4 10             	add    $0x10,%esp
  8014cf:	85 c0                	test   %eax,%eax
  8014d1:	78 21                	js     8014f4 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8014d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d6:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014dc:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014e8:	83 ec 0c             	sub    $0xc,%esp
  8014eb:	50                   	push   %eax
  8014ec:	e8 f7 ee ff ff       	call   8003e8 <fd2num>
  8014f1:	83 c4 10             	add    $0x10,%esp
}
  8014f4:	c9                   	leave  
  8014f5:	c3                   	ret    

008014f6 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	56                   	push   %esi
  8014fa:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014fb:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014fe:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801504:	e8 29 ec ff ff       	call   800132 <sys_getenvid>
  801509:	83 ec 0c             	sub    $0xc,%esp
  80150c:	ff 75 0c             	push   0xc(%ebp)
  80150f:	ff 75 08             	push   0x8(%ebp)
  801512:	56                   	push   %esi
  801513:	50                   	push   %eax
  801514:	68 40 24 80 00       	push   $0x802440
  801519:	e8 b3 00 00 00       	call   8015d1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80151e:	83 c4 18             	add    $0x18,%esp
  801521:	53                   	push   %ebx
  801522:	ff 75 10             	push   0x10(%ebp)
  801525:	e8 56 00 00 00       	call   801580 <vcprintf>
	cprintf("\n");
  80152a:	c7 04 24 2c 24 80 00 	movl   $0x80242c,(%esp)
  801531:	e8 9b 00 00 00       	call   8015d1 <cprintf>
  801536:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801539:	cc                   	int3   
  80153a:	eb fd                	jmp    801539 <_panic+0x43>

0080153c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	53                   	push   %ebx
  801540:	83 ec 04             	sub    $0x4,%esp
  801543:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801546:	8b 13                	mov    (%ebx),%edx
  801548:	8d 42 01             	lea    0x1(%edx),%eax
  80154b:	89 03                	mov    %eax,(%ebx)
  80154d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801550:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801554:	3d ff 00 00 00       	cmp    $0xff,%eax
  801559:	74 09                	je     801564 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80155b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80155f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801562:	c9                   	leave  
  801563:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801564:	83 ec 08             	sub    $0x8,%esp
  801567:	68 ff 00 00 00       	push   $0xff
  80156c:	8d 43 08             	lea    0x8(%ebx),%eax
  80156f:	50                   	push   %eax
  801570:	e8 3f eb ff ff       	call   8000b4 <sys_cputs>
		b->idx = 0;
  801575:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80157b:	83 c4 10             	add    $0x10,%esp
  80157e:	eb db                	jmp    80155b <putch+0x1f>

00801580 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801589:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801590:	00 00 00 
	b.cnt = 0;
  801593:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80159a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80159d:	ff 75 0c             	push   0xc(%ebp)
  8015a0:	ff 75 08             	push   0x8(%ebp)
  8015a3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015a9:	50                   	push   %eax
  8015aa:	68 3c 15 80 00       	push   $0x80153c
  8015af:	e8 14 01 00 00       	call   8016c8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015b4:	83 c4 08             	add    $0x8,%esp
  8015b7:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8015bd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015c3:	50                   	push   %eax
  8015c4:	e8 eb ea ff ff       	call   8000b4 <sys_cputs>

	return b.cnt;
}
  8015c9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015cf:	c9                   	leave  
  8015d0:	c3                   	ret    

008015d1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015d7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015da:	50                   	push   %eax
  8015db:	ff 75 08             	push   0x8(%ebp)
  8015de:	e8 9d ff ff ff       	call   801580 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015e3:	c9                   	leave  
  8015e4:	c3                   	ret    

008015e5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015e5:	55                   	push   %ebp
  8015e6:	89 e5                	mov    %esp,%ebp
  8015e8:	57                   	push   %edi
  8015e9:	56                   	push   %esi
  8015ea:	53                   	push   %ebx
  8015eb:	83 ec 1c             	sub    $0x1c,%esp
  8015ee:	89 c7                	mov    %eax,%edi
  8015f0:	89 d6                	mov    %edx,%esi
  8015f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015f8:	89 d1                	mov    %edx,%ecx
  8015fa:	89 c2                	mov    %eax,%edx
  8015fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015ff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801602:	8b 45 10             	mov    0x10(%ebp),%eax
  801605:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801608:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80160b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801612:	39 c2                	cmp    %eax,%edx
  801614:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801617:	72 3e                	jb     801657 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801619:	83 ec 0c             	sub    $0xc,%esp
  80161c:	ff 75 18             	push   0x18(%ebp)
  80161f:	83 eb 01             	sub    $0x1,%ebx
  801622:	53                   	push   %ebx
  801623:	50                   	push   %eax
  801624:	83 ec 08             	sub    $0x8,%esp
  801627:	ff 75 e4             	push   -0x1c(%ebp)
  80162a:	ff 75 e0             	push   -0x20(%ebp)
  80162d:	ff 75 dc             	push   -0x24(%ebp)
  801630:	ff 75 d8             	push   -0x28(%ebp)
  801633:	e8 68 0a 00 00       	call   8020a0 <__udivdi3>
  801638:	83 c4 18             	add    $0x18,%esp
  80163b:	52                   	push   %edx
  80163c:	50                   	push   %eax
  80163d:	89 f2                	mov    %esi,%edx
  80163f:	89 f8                	mov    %edi,%eax
  801641:	e8 9f ff ff ff       	call   8015e5 <printnum>
  801646:	83 c4 20             	add    $0x20,%esp
  801649:	eb 13                	jmp    80165e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80164b:	83 ec 08             	sub    $0x8,%esp
  80164e:	56                   	push   %esi
  80164f:	ff 75 18             	push   0x18(%ebp)
  801652:	ff d7                	call   *%edi
  801654:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801657:	83 eb 01             	sub    $0x1,%ebx
  80165a:	85 db                	test   %ebx,%ebx
  80165c:	7f ed                	jg     80164b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80165e:	83 ec 08             	sub    $0x8,%esp
  801661:	56                   	push   %esi
  801662:	83 ec 04             	sub    $0x4,%esp
  801665:	ff 75 e4             	push   -0x1c(%ebp)
  801668:	ff 75 e0             	push   -0x20(%ebp)
  80166b:	ff 75 dc             	push   -0x24(%ebp)
  80166e:	ff 75 d8             	push   -0x28(%ebp)
  801671:	e8 4a 0b 00 00       	call   8021c0 <__umoddi3>
  801676:	83 c4 14             	add    $0x14,%esp
  801679:	0f be 80 63 24 80 00 	movsbl 0x802463(%eax),%eax
  801680:	50                   	push   %eax
  801681:	ff d7                	call   *%edi
}
  801683:	83 c4 10             	add    $0x10,%esp
  801686:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801689:	5b                   	pop    %ebx
  80168a:	5e                   	pop    %esi
  80168b:	5f                   	pop    %edi
  80168c:	5d                   	pop    %ebp
  80168d:	c3                   	ret    

0080168e <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80168e:	55                   	push   %ebp
  80168f:	89 e5                	mov    %esp,%ebp
  801691:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801694:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801698:	8b 10                	mov    (%eax),%edx
  80169a:	3b 50 04             	cmp    0x4(%eax),%edx
  80169d:	73 0a                	jae    8016a9 <sprintputch+0x1b>
		*b->buf++ = ch;
  80169f:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016a2:	89 08                	mov    %ecx,(%eax)
  8016a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a7:	88 02                	mov    %al,(%edx)
}
  8016a9:	5d                   	pop    %ebp
  8016aa:	c3                   	ret    

008016ab <printfmt>:
{
  8016ab:	55                   	push   %ebp
  8016ac:	89 e5                	mov    %esp,%ebp
  8016ae:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8016b1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016b4:	50                   	push   %eax
  8016b5:	ff 75 10             	push   0x10(%ebp)
  8016b8:	ff 75 0c             	push   0xc(%ebp)
  8016bb:	ff 75 08             	push   0x8(%ebp)
  8016be:	e8 05 00 00 00       	call   8016c8 <vprintfmt>
}
  8016c3:	83 c4 10             	add    $0x10,%esp
  8016c6:	c9                   	leave  
  8016c7:	c3                   	ret    

008016c8 <vprintfmt>:
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	57                   	push   %edi
  8016cc:	56                   	push   %esi
  8016cd:	53                   	push   %ebx
  8016ce:	83 ec 3c             	sub    $0x3c,%esp
  8016d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8016d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016d7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016da:	eb 0a                	jmp    8016e6 <vprintfmt+0x1e>
			putch(ch, putdat);
  8016dc:	83 ec 08             	sub    $0x8,%esp
  8016df:	53                   	push   %ebx
  8016e0:	50                   	push   %eax
  8016e1:	ff d6                	call   *%esi
  8016e3:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016e6:	83 c7 01             	add    $0x1,%edi
  8016e9:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016ed:	83 f8 25             	cmp    $0x25,%eax
  8016f0:	74 0c                	je     8016fe <vprintfmt+0x36>
			if (ch == '\0')
  8016f2:	85 c0                	test   %eax,%eax
  8016f4:	75 e6                	jne    8016dc <vprintfmt+0x14>
}
  8016f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f9:	5b                   	pop    %ebx
  8016fa:	5e                   	pop    %esi
  8016fb:	5f                   	pop    %edi
  8016fc:	5d                   	pop    %ebp
  8016fd:	c3                   	ret    
		padc = ' ';
  8016fe:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  801702:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801709:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801710:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801717:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80171c:	8d 47 01             	lea    0x1(%edi),%eax
  80171f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801722:	0f b6 17             	movzbl (%edi),%edx
  801725:	8d 42 dd             	lea    -0x23(%edx),%eax
  801728:	3c 55                	cmp    $0x55,%al
  80172a:	0f 87 bb 03 00 00    	ja     801aeb <vprintfmt+0x423>
  801730:	0f b6 c0             	movzbl %al,%eax
  801733:	ff 24 85 a0 25 80 00 	jmp    *0x8025a0(,%eax,4)
  80173a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80173d:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801741:	eb d9                	jmp    80171c <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801743:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801746:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80174a:	eb d0                	jmp    80171c <vprintfmt+0x54>
  80174c:	0f b6 d2             	movzbl %dl,%edx
  80174f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801752:	b8 00 00 00 00       	mov    $0x0,%eax
  801757:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80175a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80175d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801761:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801764:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801767:	83 f9 09             	cmp    $0x9,%ecx
  80176a:	77 55                	ja     8017c1 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80176c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80176f:	eb e9                	jmp    80175a <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801771:	8b 45 14             	mov    0x14(%ebp),%eax
  801774:	8b 00                	mov    (%eax),%eax
  801776:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801779:	8b 45 14             	mov    0x14(%ebp),%eax
  80177c:	8d 40 04             	lea    0x4(%eax),%eax
  80177f:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801782:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801785:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801789:	79 91                	jns    80171c <vprintfmt+0x54>
				width = precision, precision = -1;
  80178b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80178e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801791:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801798:	eb 82                	jmp    80171c <vprintfmt+0x54>
  80179a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80179d:	85 d2                	test   %edx,%edx
  80179f:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a4:	0f 49 c2             	cmovns %edx,%eax
  8017a7:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8017aa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017ad:	e9 6a ff ff ff       	jmp    80171c <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8017b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8017b5:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8017bc:	e9 5b ff ff ff       	jmp    80171c <vprintfmt+0x54>
  8017c1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8017c4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017c7:	eb bc                	jmp    801785 <vprintfmt+0xbd>
			lflag++;
  8017c9:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8017cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017cf:	e9 48 ff ff ff       	jmp    80171c <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8017d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8017d7:	8d 78 04             	lea    0x4(%eax),%edi
  8017da:	83 ec 08             	sub    $0x8,%esp
  8017dd:	53                   	push   %ebx
  8017de:	ff 30                	push   (%eax)
  8017e0:	ff d6                	call   *%esi
			break;
  8017e2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017e5:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017e8:	e9 9d 02 00 00       	jmp    801a8a <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8017ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8017f0:	8d 78 04             	lea    0x4(%eax),%edi
  8017f3:	8b 10                	mov    (%eax),%edx
  8017f5:	89 d0                	mov    %edx,%eax
  8017f7:	f7 d8                	neg    %eax
  8017f9:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017fc:	83 f8 0f             	cmp    $0xf,%eax
  8017ff:	7f 23                	jg     801824 <vprintfmt+0x15c>
  801801:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  801808:	85 d2                	test   %edx,%edx
  80180a:	74 18                	je     801824 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80180c:	52                   	push   %edx
  80180d:	68 c1 23 80 00       	push   $0x8023c1
  801812:	53                   	push   %ebx
  801813:	56                   	push   %esi
  801814:	e8 92 fe ff ff       	call   8016ab <printfmt>
  801819:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80181c:	89 7d 14             	mov    %edi,0x14(%ebp)
  80181f:	e9 66 02 00 00       	jmp    801a8a <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  801824:	50                   	push   %eax
  801825:	68 7b 24 80 00       	push   $0x80247b
  80182a:	53                   	push   %ebx
  80182b:	56                   	push   %esi
  80182c:	e8 7a fe ff ff       	call   8016ab <printfmt>
  801831:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801834:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801837:	e9 4e 02 00 00       	jmp    801a8a <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80183c:	8b 45 14             	mov    0x14(%ebp),%eax
  80183f:	83 c0 04             	add    $0x4,%eax
  801842:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801845:	8b 45 14             	mov    0x14(%ebp),%eax
  801848:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80184a:	85 d2                	test   %edx,%edx
  80184c:	b8 74 24 80 00       	mov    $0x802474,%eax
  801851:	0f 45 c2             	cmovne %edx,%eax
  801854:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801857:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80185b:	7e 06                	jle    801863 <vprintfmt+0x19b>
  80185d:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801861:	75 0d                	jne    801870 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801863:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801866:	89 c7                	mov    %eax,%edi
  801868:	03 45 e0             	add    -0x20(%ebp),%eax
  80186b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80186e:	eb 55                	jmp    8018c5 <vprintfmt+0x1fd>
  801870:	83 ec 08             	sub    $0x8,%esp
  801873:	ff 75 d8             	push   -0x28(%ebp)
  801876:	ff 75 cc             	push   -0x34(%ebp)
  801879:	e8 0a 03 00 00       	call   801b88 <strnlen>
  80187e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801881:	29 c1                	sub    %eax,%ecx
  801883:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801886:	83 c4 10             	add    $0x10,%esp
  801889:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80188b:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80188f:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801892:	eb 0f                	jmp    8018a3 <vprintfmt+0x1db>
					putch(padc, putdat);
  801894:	83 ec 08             	sub    $0x8,%esp
  801897:	53                   	push   %ebx
  801898:	ff 75 e0             	push   -0x20(%ebp)
  80189b:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80189d:	83 ef 01             	sub    $0x1,%edi
  8018a0:	83 c4 10             	add    $0x10,%esp
  8018a3:	85 ff                	test   %edi,%edi
  8018a5:	7f ed                	jg     801894 <vprintfmt+0x1cc>
  8018a7:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8018aa:	85 d2                	test   %edx,%edx
  8018ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b1:	0f 49 c2             	cmovns %edx,%eax
  8018b4:	29 c2                	sub    %eax,%edx
  8018b6:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8018b9:	eb a8                	jmp    801863 <vprintfmt+0x19b>
					putch(ch, putdat);
  8018bb:	83 ec 08             	sub    $0x8,%esp
  8018be:	53                   	push   %ebx
  8018bf:	52                   	push   %edx
  8018c0:	ff d6                	call   *%esi
  8018c2:	83 c4 10             	add    $0x10,%esp
  8018c5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018c8:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018ca:	83 c7 01             	add    $0x1,%edi
  8018cd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018d1:	0f be d0             	movsbl %al,%edx
  8018d4:	85 d2                	test   %edx,%edx
  8018d6:	74 4b                	je     801923 <vprintfmt+0x25b>
  8018d8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018dc:	78 06                	js     8018e4 <vprintfmt+0x21c>
  8018de:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018e2:	78 1e                	js     801902 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8018e4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018e8:	74 d1                	je     8018bb <vprintfmt+0x1f3>
  8018ea:	0f be c0             	movsbl %al,%eax
  8018ed:	83 e8 20             	sub    $0x20,%eax
  8018f0:	83 f8 5e             	cmp    $0x5e,%eax
  8018f3:	76 c6                	jbe    8018bb <vprintfmt+0x1f3>
					putch('?', putdat);
  8018f5:	83 ec 08             	sub    $0x8,%esp
  8018f8:	53                   	push   %ebx
  8018f9:	6a 3f                	push   $0x3f
  8018fb:	ff d6                	call   *%esi
  8018fd:	83 c4 10             	add    $0x10,%esp
  801900:	eb c3                	jmp    8018c5 <vprintfmt+0x1fd>
  801902:	89 cf                	mov    %ecx,%edi
  801904:	eb 0e                	jmp    801914 <vprintfmt+0x24c>
				putch(' ', putdat);
  801906:	83 ec 08             	sub    $0x8,%esp
  801909:	53                   	push   %ebx
  80190a:	6a 20                	push   $0x20
  80190c:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80190e:	83 ef 01             	sub    $0x1,%edi
  801911:	83 c4 10             	add    $0x10,%esp
  801914:	85 ff                	test   %edi,%edi
  801916:	7f ee                	jg     801906 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  801918:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80191b:	89 45 14             	mov    %eax,0x14(%ebp)
  80191e:	e9 67 01 00 00       	jmp    801a8a <vprintfmt+0x3c2>
  801923:	89 cf                	mov    %ecx,%edi
  801925:	eb ed                	jmp    801914 <vprintfmt+0x24c>
	if (lflag >= 2)
  801927:	83 f9 01             	cmp    $0x1,%ecx
  80192a:	7f 1b                	jg     801947 <vprintfmt+0x27f>
	else if (lflag)
  80192c:	85 c9                	test   %ecx,%ecx
  80192e:	74 63                	je     801993 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  801930:	8b 45 14             	mov    0x14(%ebp),%eax
  801933:	8b 00                	mov    (%eax),%eax
  801935:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801938:	99                   	cltd   
  801939:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80193c:	8b 45 14             	mov    0x14(%ebp),%eax
  80193f:	8d 40 04             	lea    0x4(%eax),%eax
  801942:	89 45 14             	mov    %eax,0x14(%ebp)
  801945:	eb 17                	jmp    80195e <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801947:	8b 45 14             	mov    0x14(%ebp),%eax
  80194a:	8b 50 04             	mov    0x4(%eax),%edx
  80194d:	8b 00                	mov    (%eax),%eax
  80194f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801952:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801955:	8b 45 14             	mov    0x14(%ebp),%eax
  801958:	8d 40 08             	lea    0x8(%eax),%eax
  80195b:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80195e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801961:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801964:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801969:	85 c9                	test   %ecx,%ecx
  80196b:	0f 89 ff 00 00 00    	jns    801a70 <vprintfmt+0x3a8>
				putch('-', putdat);
  801971:	83 ec 08             	sub    $0x8,%esp
  801974:	53                   	push   %ebx
  801975:	6a 2d                	push   $0x2d
  801977:	ff d6                	call   *%esi
				num = -(long long) num;
  801979:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80197c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80197f:	f7 da                	neg    %edx
  801981:	83 d1 00             	adc    $0x0,%ecx
  801984:	f7 d9                	neg    %ecx
  801986:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801989:	bf 0a 00 00 00       	mov    $0xa,%edi
  80198e:	e9 dd 00 00 00       	jmp    801a70 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801993:	8b 45 14             	mov    0x14(%ebp),%eax
  801996:	8b 00                	mov    (%eax),%eax
  801998:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80199b:	99                   	cltd   
  80199c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80199f:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a2:	8d 40 04             	lea    0x4(%eax),%eax
  8019a5:	89 45 14             	mov    %eax,0x14(%ebp)
  8019a8:	eb b4                	jmp    80195e <vprintfmt+0x296>
	if (lflag >= 2)
  8019aa:	83 f9 01             	cmp    $0x1,%ecx
  8019ad:	7f 1e                	jg     8019cd <vprintfmt+0x305>
	else if (lflag)
  8019af:	85 c9                	test   %ecx,%ecx
  8019b1:	74 32                	je     8019e5 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8019b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b6:	8b 10                	mov    (%eax),%edx
  8019b8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019bd:	8d 40 04             	lea    0x4(%eax),%eax
  8019c0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019c3:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8019c8:	e9 a3 00 00 00       	jmp    801a70 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8019cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d0:	8b 10                	mov    (%eax),%edx
  8019d2:	8b 48 04             	mov    0x4(%eax),%ecx
  8019d5:	8d 40 08             	lea    0x8(%eax),%eax
  8019d8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019db:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8019e0:	e9 8b 00 00 00       	jmp    801a70 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8019e8:	8b 10                	mov    (%eax),%edx
  8019ea:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019ef:	8d 40 04             	lea    0x4(%eax),%eax
  8019f2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019f5:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8019fa:	eb 74                	jmp    801a70 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8019fc:	83 f9 01             	cmp    $0x1,%ecx
  8019ff:	7f 1b                	jg     801a1c <vprintfmt+0x354>
	else if (lflag)
  801a01:	85 c9                	test   %ecx,%ecx
  801a03:	74 2c                	je     801a31 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  801a05:	8b 45 14             	mov    0x14(%ebp),%eax
  801a08:	8b 10                	mov    (%eax),%edx
  801a0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a0f:	8d 40 04             	lea    0x4(%eax),%eax
  801a12:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a15:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  801a1a:	eb 54                	jmp    801a70 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801a1c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a1f:	8b 10                	mov    (%eax),%edx
  801a21:	8b 48 04             	mov    0x4(%eax),%ecx
  801a24:	8d 40 08             	lea    0x8(%eax),%eax
  801a27:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a2a:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  801a2f:	eb 3f                	jmp    801a70 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801a31:	8b 45 14             	mov    0x14(%ebp),%eax
  801a34:	8b 10                	mov    (%eax),%edx
  801a36:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a3b:	8d 40 04             	lea    0x4(%eax),%eax
  801a3e:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a41:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801a46:	eb 28                	jmp    801a70 <vprintfmt+0x3a8>
			putch('0', putdat);
  801a48:	83 ec 08             	sub    $0x8,%esp
  801a4b:	53                   	push   %ebx
  801a4c:	6a 30                	push   $0x30
  801a4e:	ff d6                	call   *%esi
			putch('x', putdat);
  801a50:	83 c4 08             	add    $0x8,%esp
  801a53:	53                   	push   %ebx
  801a54:	6a 78                	push   $0x78
  801a56:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a58:	8b 45 14             	mov    0x14(%ebp),%eax
  801a5b:	8b 10                	mov    (%eax),%edx
  801a5d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a62:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a65:	8d 40 04             	lea    0x4(%eax),%eax
  801a68:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a6b:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801a70:	83 ec 0c             	sub    $0xc,%esp
  801a73:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801a77:	50                   	push   %eax
  801a78:	ff 75 e0             	push   -0x20(%ebp)
  801a7b:	57                   	push   %edi
  801a7c:	51                   	push   %ecx
  801a7d:	52                   	push   %edx
  801a7e:	89 da                	mov    %ebx,%edx
  801a80:	89 f0                	mov    %esi,%eax
  801a82:	e8 5e fb ff ff       	call   8015e5 <printnum>
			break;
  801a87:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801a8a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a8d:	e9 54 fc ff ff       	jmp    8016e6 <vprintfmt+0x1e>
	if (lflag >= 2)
  801a92:	83 f9 01             	cmp    $0x1,%ecx
  801a95:	7f 1b                	jg     801ab2 <vprintfmt+0x3ea>
	else if (lflag)
  801a97:	85 c9                	test   %ecx,%ecx
  801a99:	74 2c                	je     801ac7 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801a9b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a9e:	8b 10                	mov    (%eax),%edx
  801aa0:	b9 00 00 00 00       	mov    $0x0,%ecx
  801aa5:	8d 40 04             	lea    0x4(%eax),%eax
  801aa8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801aab:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  801ab0:	eb be                	jmp    801a70 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801ab2:	8b 45 14             	mov    0x14(%ebp),%eax
  801ab5:	8b 10                	mov    (%eax),%edx
  801ab7:	8b 48 04             	mov    0x4(%eax),%ecx
  801aba:	8d 40 08             	lea    0x8(%eax),%eax
  801abd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ac0:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  801ac5:	eb a9                	jmp    801a70 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801ac7:	8b 45 14             	mov    0x14(%ebp),%eax
  801aca:	8b 10                	mov    (%eax),%edx
  801acc:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ad1:	8d 40 04             	lea    0x4(%eax),%eax
  801ad4:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ad7:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  801adc:	eb 92                	jmp    801a70 <vprintfmt+0x3a8>
			putch(ch, putdat);
  801ade:	83 ec 08             	sub    $0x8,%esp
  801ae1:	53                   	push   %ebx
  801ae2:	6a 25                	push   $0x25
  801ae4:	ff d6                	call   *%esi
			break;
  801ae6:	83 c4 10             	add    $0x10,%esp
  801ae9:	eb 9f                	jmp    801a8a <vprintfmt+0x3c2>
			putch('%', putdat);
  801aeb:	83 ec 08             	sub    $0x8,%esp
  801aee:	53                   	push   %ebx
  801aef:	6a 25                	push   $0x25
  801af1:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801af3:	83 c4 10             	add    $0x10,%esp
  801af6:	89 f8                	mov    %edi,%eax
  801af8:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801afc:	74 05                	je     801b03 <vprintfmt+0x43b>
  801afe:	83 e8 01             	sub    $0x1,%eax
  801b01:	eb f5                	jmp    801af8 <vprintfmt+0x430>
  801b03:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b06:	eb 82                	jmp    801a8a <vprintfmt+0x3c2>

00801b08 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b08:	55                   	push   %ebp
  801b09:	89 e5                	mov    %esp,%ebp
  801b0b:	83 ec 18             	sub    $0x18,%esp
  801b0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b11:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b14:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b17:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b1b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b1e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b25:	85 c0                	test   %eax,%eax
  801b27:	74 26                	je     801b4f <vsnprintf+0x47>
  801b29:	85 d2                	test   %edx,%edx
  801b2b:	7e 22                	jle    801b4f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b2d:	ff 75 14             	push   0x14(%ebp)
  801b30:	ff 75 10             	push   0x10(%ebp)
  801b33:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b36:	50                   	push   %eax
  801b37:	68 8e 16 80 00       	push   $0x80168e
  801b3c:	e8 87 fb ff ff       	call   8016c8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b41:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b44:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b47:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4a:	83 c4 10             	add    $0x10,%esp
}
  801b4d:	c9                   	leave  
  801b4e:	c3                   	ret    
		return -E_INVAL;
  801b4f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b54:	eb f7                	jmp    801b4d <vsnprintf+0x45>

00801b56 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b56:	55                   	push   %ebp
  801b57:	89 e5                	mov    %esp,%ebp
  801b59:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b5c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b5f:	50                   	push   %eax
  801b60:	ff 75 10             	push   0x10(%ebp)
  801b63:	ff 75 0c             	push   0xc(%ebp)
  801b66:	ff 75 08             	push   0x8(%ebp)
  801b69:	e8 9a ff ff ff       	call   801b08 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b6e:	c9                   	leave  
  801b6f:	c3                   	ret    

00801b70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b76:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7b:	eb 03                	jmp    801b80 <strlen+0x10>
		n++;
  801b7d:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801b80:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b84:	75 f7                	jne    801b7d <strlen+0xd>
	return n;
}
  801b86:	5d                   	pop    %ebp
  801b87:	c3                   	ret    

00801b88 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b8e:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b91:	b8 00 00 00 00       	mov    $0x0,%eax
  801b96:	eb 03                	jmp    801b9b <strnlen+0x13>
		n++;
  801b98:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b9b:	39 d0                	cmp    %edx,%eax
  801b9d:	74 08                	je     801ba7 <strnlen+0x1f>
  801b9f:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801ba3:	75 f3                	jne    801b98 <strnlen+0x10>
  801ba5:	89 c2                	mov    %eax,%edx
	return n;
}
  801ba7:	89 d0                	mov    %edx,%eax
  801ba9:	5d                   	pop    %ebp
  801baa:	c3                   	ret    

00801bab <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bab:	55                   	push   %ebp
  801bac:	89 e5                	mov    %esp,%ebp
  801bae:	53                   	push   %ebx
  801baf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bb2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801bb5:	b8 00 00 00 00       	mov    $0x0,%eax
  801bba:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801bbe:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801bc1:	83 c0 01             	add    $0x1,%eax
  801bc4:	84 d2                	test   %dl,%dl
  801bc6:	75 f2                	jne    801bba <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801bc8:	89 c8                	mov    %ecx,%eax
  801bca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bcd:	c9                   	leave  
  801bce:	c3                   	ret    

00801bcf <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	53                   	push   %ebx
  801bd3:	83 ec 10             	sub    $0x10,%esp
  801bd6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bd9:	53                   	push   %ebx
  801bda:	e8 91 ff ff ff       	call   801b70 <strlen>
  801bdf:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801be2:	ff 75 0c             	push   0xc(%ebp)
  801be5:	01 d8                	add    %ebx,%eax
  801be7:	50                   	push   %eax
  801be8:	e8 be ff ff ff       	call   801bab <strcpy>
	return dst;
}
  801bed:	89 d8                	mov    %ebx,%eax
  801bef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf2:	c9                   	leave  
  801bf3:	c3                   	ret    

00801bf4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bf4:	55                   	push   %ebp
  801bf5:	89 e5                	mov    %esp,%ebp
  801bf7:	56                   	push   %esi
  801bf8:	53                   	push   %ebx
  801bf9:	8b 75 08             	mov    0x8(%ebp),%esi
  801bfc:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bff:	89 f3                	mov    %esi,%ebx
  801c01:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c04:	89 f0                	mov    %esi,%eax
  801c06:	eb 0f                	jmp    801c17 <strncpy+0x23>
		*dst++ = *src;
  801c08:	83 c0 01             	add    $0x1,%eax
  801c0b:	0f b6 0a             	movzbl (%edx),%ecx
  801c0e:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c11:	80 f9 01             	cmp    $0x1,%cl
  801c14:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801c17:	39 d8                	cmp    %ebx,%eax
  801c19:	75 ed                	jne    801c08 <strncpy+0x14>
	}
	return ret;
}
  801c1b:	89 f0                	mov    %esi,%eax
  801c1d:	5b                   	pop    %ebx
  801c1e:	5e                   	pop    %esi
  801c1f:	5d                   	pop    %ebp
  801c20:	c3                   	ret    

00801c21 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c21:	55                   	push   %ebp
  801c22:	89 e5                	mov    %esp,%ebp
  801c24:	56                   	push   %esi
  801c25:	53                   	push   %ebx
  801c26:	8b 75 08             	mov    0x8(%ebp),%esi
  801c29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c2c:	8b 55 10             	mov    0x10(%ebp),%edx
  801c2f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c31:	85 d2                	test   %edx,%edx
  801c33:	74 21                	je     801c56 <strlcpy+0x35>
  801c35:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c39:	89 f2                	mov    %esi,%edx
  801c3b:	eb 09                	jmp    801c46 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c3d:	83 c1 01             	add    $0x1,%ecx
  801c40:	83 c2 01             	add    $0x1,%edx
  801c43:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801c46:	39 c2                	cmp    %eax,%edx
  801c48:	74 09                	je     801c53 <strlcpy+0x32>
  801c4a:	0f b6 19             	movzbl (%ecx),%ebx
  801c4d:	84 db                	test   %bl,%bl
  801c4f:	75 ec                	jne    801c3d <strlcpy+0x1c>
  801c51:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801c53:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c56:	29 f0                	sub    %esi,%eax
}
  801c58:	5b                   	pop    %ebx
  801c59:	5e                   	pop    %esi
  801c5a:	5d                   	pop    %ebp
  801c5b:	c3                   	ret    

00801c5c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c62:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c65:	eb 06                	jmp    801c6d <strcmp+0x11>
		p++, q++;
  801c67:	83 c1 01             	add    $0x1,%ecx
  801c6a:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801c6d:	0f b6 01             	movzbl (%ecx),%eax
  801c70:	84 c0                	test   %al,%al
  801c72:	74 04                	je     801c78 <strcmp+0x1c>
  801c74:	3a 02                	cmp    (%edx),%al
  801c76:	74 ef                	je     801c67 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c78:	0f b6 c0             	movzbl %al,%eax
  801c7b:	0f b6 12             	movzbl (%edx),%edx
  801c7e:	29 d0                	sub    %edx,%eax
}
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    

00801c82 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c82:	55                   	push   %ebp
  801c83:	89 e5                	mov    %esp,%ebp
  801c85:	53                   	push   %ebx
  801c86:	8b 45 08             	mov    0x8(%ebp),%eax
  801c89:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c8c:	89 c3                	mov    %eax,%ebx
  801c8e:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c91:	eb 06                	jmp    801c99 <strncmp+0x17>
		n--, p++, q++;
  801c93:	83 c0 01             	add    $0x1,%eax
  801c96:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801c99:	39 d8                	cmp    %ebx,%eax
  801c9b:	74 18                	je     801cb5 <strncmp+0x33>
  801c9d:	0f b6 08             	movzbl (%eax),%ecx
  801ca0:	84 c9                	test   %cl,%cl
  801ca2:	74 04                	je     801ca8 <strncmp+0x26>
  801ca4:	3a 0a                	cmp    (%edx),%cl
  801ca6:	74 eb                	je     801c93 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801ca8:	0f b6 00             	movzbl (%eax),%eax
  801cab:	0f b6 12             	movzbl (%edx),%edx
  801cae:	29 d0                	sub    %edx,%eax
}
  801cb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cb3:	c9                   	leave  
  801cb4:	c3                   	ret    
		return 0;
  801cb5:	b8 00 00 00 00       	mov    $0x0,%eax
  801cba:	eb f4                	jmp    801cb0 <strncmp+0x2e>

00801cbc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801cbc:	55                   	push   %ebp
  801cbd:	89 e5                	mov    %esp,%ebp
  801cbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cc6:	eb 03                	jmp    801ccb <strchr+0xf>
  801cc8:	83 c0 01             	add    $0x1,%eax
  801ccb:	0f b6 10             	movzbl (%eax),%edx
  801cce:	84 d2                	test   %dl,%dl
  801cd0:	74 06                	je     801cd8 <strchr+0x1c>
		if (*s == c)
  801cd2:	38 ca                	cmp    %cl,%dl
  801cd4:	75 f2                	jne    801cc8 <strchr+0xc>
  801cd6:	eb 05                	jmp    801cdd <strchr+0x21>
			return (char *) s;
	return 0;
  801cd8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cdd:	5d                   	pop    %ebp
  801cde:	c3                   	ret    

00801cdf <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ce9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cec:	38 ca                	cmp    %cl,%dl
  801cee:	74 09                	je     801cf9 <strfind+0x1a>
  801cf0:	84 d2                	test   %dl,%dl
  801cf2:	74 05                	je     801cf9 <strfind+0x1a>
	for (; *s; s++)
  801cf4:	83 c0 01             	add    $0x1,%eax
  801cf7:	eb f0                	jmp    801ce9 <strfind+0xa>
			break;
	return (char *) s;
}
  801cf9:	5d                   	pop    %ebp
  801cfa:	c3                   	ret    

00801cfb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	57                   	push   %edi
  801cff:	56                   	push   %esi
  801d00:	53                   	push   %ebx
  801d01:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d04:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d07:	85 c9                	test   %ecx,%ecx
  801d09:	74 2f                	je     801d3a <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d0b:	89 f8                	mov    %edi,%eax
  801d0d:	09 c8                	or     %ecx,%eax
  801d0f:	a8 03                	test   $0x3,%al
  801d11:	75 21                	jne    801d34 <memset+0x39>
		c &= 0xFF;
  801d13:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d17:	89 d0                	mov    %edx,%eax
  801d19:	c1 e0 08             	shl    $0x8,%eax
  801d1c:	89 d3                	mov    %edx,%ebx
  801d1e:	c1 e3 18             	shl    $0x18,%ebx
  801d21:	89 d6                	mov    %edx,%esi
  801d23:	c1 e6 10             	shl    $0x10,%esi
  801d26:	09 f3                	or     %esi,%ebx
  801d28:	09 da                	or     %ebx,%edx
  801d2a:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801d2c:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801d2f:	fc                   	cld    
  801d30:	f3 ab                	rep stos %eax,%es:(%edi)
  801d32:	eb 06                	jmp    801d3a <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d34:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d37:	fc                   	cld    
  801d38:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d3a:	89 f8                	mov    %edi,%eax
  801d3c:	5b                   	pop    %ebx
  801d3d:	5e                   	pop    %esi
  801d3e:	5f                   	pop    %edi
  801d3f:	5d                   	pop    %ebp
  801d40:	c3                   	ret    

00801d41 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d41:	55                   	push   %ebp
  801d42:	89 e5                	mov    %esp,%ebp
  801d44:	57                   	push   %edi
  801d45:	56                   	push   %esi
  801d46:	8b 45 08             	mov    0x8(%ebp),%eax
  801d49:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d4c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d4f:	39 c6                	cmp    %eax,%esi
  801d51:	73 32                	jae    801d85 <memmove+0x44>
  801d53:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d56:	39 c2                	cmp    %eax,%edx
  801d58:	76 2b                	jbe    801d85 <memmove+0x44>
		s += n;
		d += n;
  801d5a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d5d:	89 d6                	mov    %edx,%esi
  801d5f:	09 fe                	or     %edi,%esi
  801d61:	09 ce                	or     %ecx,%esi
  801d63:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d69:	75 0e                	jne    801d79 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d6b:	83 ef 04             	sub    $0x4,%edi
  801d6e:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d71:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801d74:	fd                   	std    
  801d75:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d77:	eb 09                	jmp    801d82 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d79:	83 ef 01             	sub    $0x1,%edi
  801d7c:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801d7f:	fd                   	std    
  801d80:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d82:	fc                   	cld    
  801d83:	eb 1a                	jmp    801d9f <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d85:	89 f2                	mov    %esi,%edx
  801d87:	09 c2                	or     %eax,%edx
  801d89:	09 ca                	or     %ecx,%edx
  801d8b:	f6 c2 03             	test   $0x3,%dl
  801d8e:	75 0a                	jne    801d9a <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801d90:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801d93:	89 c7                	mov    %eax,%edi
  801d95:	fc                   	cld    
  801d96:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d98:	eb 05                	jmp    801d9f <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801d9a:	89 c7                	mov    %eax,%edi
  801d9c:	fc                   	cld    
  801d9d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d9f:	5e                   	pop    %esi
  801da0:	5f                   	pop    %edi
  801da1:	5d                   	pop    %ebp
  801da2:	c3                   	ret    

00801da3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801da9:	ff 75 10             	push   0x10(%ebp)
  801dac:	ff 75 0c             	push   0xc(%ebp)
  801daf:	ff 75 08             	push   0x8(%ebp)
  801db2:	e8 8a ff ff ff       	call   801d41 <memmove>
}
  801db7:	c9                   	leave  
  801db8:	c3                   	ret    

00801db9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801db9:	55                   	push   %ebp
  801dba:	89 e5                	mov    %esp,%ebp
  801dbc:	56                   	push   %esi
  801dbd:	53                   	push   %ebx
  801dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc1:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc4:	89 c6                	mov    %eax,%esi
  801dc6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dc9:	eb 06                	jmp    801dd1 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801dcb:	83 c0 01             	add    $0x1,%eax
  801dce:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801dd1:	39 f0                	cmp    %esi,%eax
  801dd3:	74 14                	je     801de9 <memcmp+0x30>
		if (*s1 != *s2)
  801dd5:	0f b6 08             	movzbl (%eax),%ecx
  801dd8:	0f b6 1a             	movzbl (%edx),%ebx
  801ddb:	38 d9                	cmp    %bl,%cl
  801ddd:	74 ec                	je     801dcb <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801ddf:	0f b6 c1             	movzbl %cl,%eax
  801de2:	0f b6 db             	movzbl %bl,%ebx
  801de5:	29 d8                	sub    %ebx,%eax
  801de7:	eb 05                	jmp    801dee <memcmp+0x35>
	}

	return 0;
  801de9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dee:	5b                   	pop    %ebx
  801def:	5e                   	pop    %esi
  801df0:	5d                   	pop    %ebp
  801df1:	c3                   	ret    

00801df2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801df2:	55                   	push   %ebp
  801df3:	89 e5                	mov    %esp,%ebp
  801df5:	8b 45 08             	mov    0x8(%ebp),%eax
  801df8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801dfb:	89 c2                	mov    %eax,%edx
  801dfd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801e00:	eb 03                	jmp    801e05 <memfind+0x13>
  801e02:	83 c0 01             	add    $0x1,%eax
  801e05:	39 d0                	cmp    %edx,%eax
  801e07:	73 04                	jae    801e0d <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e09:	38 08                	cmp    %cl,(%eax)
  801e0b:	75 f5                	jne    801e02 <memfind+0x10>
			break;
	return (void *) s;
}
  801e0d:	5d                   	pop    %ebp
  801e0e:	c3                   	ret    

00801e0f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	57                   	push   %edi
  801e13:	56                   	push   %esi
  801e14:	53                   	push   %ebx
  801e15:	8b 55 08             	mov    0x8(%ebp),%edx
  801e18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e1b:	eb 03                	jmp    801e20 <strtol+0x11>
		s++;
  801e1d:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801e20:	0f b6 02             	movzbl (%edx),%eax
  801e23:	3c 20                	cmp    $0x20,%al
  801e25:	74 f6                	je     801e1d <strtol+0xe>
  801e27:	3c 09                	cmp    $0x9,%al
  801e29:	74 f2                	je     801e1d <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801e2b:	3c 2b                	cmp    $0x2b,%al
  801e2d:	74 2a                	je     801e59 <strtol+0x4a>
	int neg = 0;
  801e2f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801e34:	3c 2d                	cmp    $0x2d,%al
  801e36:	74 2b                	je     801e63 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e38:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e3e:	75 0f                	jne    801e4f <strtol+0x40>
  801e40:	80 3a 30             	cmpb   $0x30,(%edx)
  801e43:	74 28                	je     801e6d <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e45:	85 db                	test   %ebx,%ebx
  801e47:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e4c:	0f 44 d8             	cmove  %eax,%ebx
  801e4f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e54:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801e57:	eb 46                	jmp    801e9f <strtol+0x90>
		s++;
  801e59:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801e5c:	bf 00 00 00 00       	mov    $0x0,%edi
  801e61:	eb d5                	jmp    801e38 <strtol+0x29>
		s++, neg = 1;
  801e63:	83 c2 01             	add    $0x1,%edx
  801e66:	bf 01 00 00 00       	mov    $0x1,%edi
  801e6b:	eb cb                	jmp    801e38 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e6d:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e71:	74 0e                	je     801e81 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801e73:	85 db                	test   %ebx,%ebx
  801e75:	75 d8                	jne    801e4f <strtol+0x40>
		s++, base = 8;
  801e77:	83 c2 01             	add    $0x1,%edx
  801e7a:	bb 08 00 00 00       	mov    $0x8,%ebx
  801e7f:	eb ce                	jmp    801e4f <strtol+0x40>
		s += 2, base = 16;
  801e81:	83 c2 02             	add    $0x2,%edx
  801e84:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e89:	eb c4                	jmp    801e4f <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801e8b:	0f be c0             	movsbl %al,%eax
  801e8e:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801e91:	3b 45 10             	cmp    0x10(%ebp),%eax
  801e94:	7d 3a                	jge    801ed0 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801e96:	83 c2 01             	add    $0x1,%edx
  801e99:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801e9d:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801e9f:	0f b6 02             	movzbl (%edx),%eax
  801ea2:	8d 70 d0             	lea    -0x30(%eax),%esi
  801ea5:	89 f3                	mov    %esi,%ebx
  801ea7:	80 fb 09             	cmp    $0x9,%bl
  801eaa:	76 df                	jbe    801e8b <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  801eac:	8d 70 9f             	lea    -0x61(%eax),%esi
  801eaf:	89 f3                	mov    %esi,%ebx
  801eb1:	80 fb 19             	cmp    $0x19,%bl
  801eb4:	77 08                	ja     801ebe <strtol+0xaf>
			dig = *s - 'a' + 10;
  801eb6:	0f be c0             	movsbl %al,%eax
  801eb9:	83 e8 57             	sub    $0x57,%eax
  801ebc:	eb d3                	jmp    801e91 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801ebe:	8d 70 bf             	lea    -0x41(%eax),%esi
  801ec1:	89 f3                	mov    %esi,%ebx
  801ec3:	80 fb 19             	cmp    $0x19,%bl
  801ec6:	77 08                	ja     801ed0 <strtol+0xc1>
			dig = *s - 'A' + 10;
  801ec8:	0f be c0             	movsbl %al,%eax
  801ecb:	83 e8 37             	sub    $0x37,%eax
  801ece:	eb c1                	jmp    801e91 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801ed0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ed4:	74 05                	je     801edb <strtol+0xcc>
		*endptr = (char *) s;
  801ed6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ed9:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801edb:	89 c8                	mov    %ecx,%eax
  801edd:	f7 d8                	neg    %eax
  801edf:	85 ff                	test   %edi,%edi
  801ee1:	0f 45 c8             	cmovne %eax,%ecx
}
  801ee4:	89 c8                	mov    %ecx,%eax
  801ee6:	5b                   	pop    %ebx
  801ee7:	5e                   	pop    %esi
  801ee8:	5f                   	pop    %edi
  801ee9:	5d                   	pop    %ebp
  801eea:	c3                   	ret    

00801eeb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eeb:	55                   	push   %ebp
  801eec:	89 e5                	mov    %esp,%ebp
  801eee:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  801ef1:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  801ef8:	74 0a                	je     801f04 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801efa:	8b 45 08             	mov    0x8(%ebp),%eax
  801efd:	a3 04 80 80 00       	mov    %eax,0x808004
}
  801f02:	c9                   	leave  
  801f03:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  801f04:	e8 29 e2 ff ff       	call   800132 <sys_getenvid>
  801f09:	83 ec 04             	sub    $0x4,%esp
  801f0c:	68 07 0e 00 00       	push   $0xe07
  801f11:	68 00 f0 bf ee       	push   $0xeebff000
  801f16:	50                   	push   %eax
  801f17:	e8 54 e2 ff ff       	call   800170 <sys_page_alloc>
		if (r < 0) {
  801f1c:	83 c4 10             	add    $0x10,%esp
  801f1f:	85 c0                	test   %eax,%eax
  801f21:	78 2c                	js     801f4f <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801f23:	e8 0a e2 ff ff       	call   800132 <sys_getenvid>
  801f28:	83 ec 08             	sub    $0x8,%esp
  801f2b:	68 c2 03 80 00       	push   $0x8003c2
  801f30:	50                   	push   %eax
  801f31:	e8 85 e3 ff ff       	call   8002bb <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801f36:	83 c4 10             	add    $0x10,%esp
  801f39:	85 c0                	test   %eax,%eax
  801f3b:	79 bd                	jns    801efa <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  801f3d:	50                   	push   %eax
  801f3e:	68 a0 27 80 00       	push   $0x8027a0
  801f43:	6a 28                	push   $0x28
  801f45:	68 d6 27 80 00       	push   $0x8027d6
  801f4a:	e8 a7 f5 ff ff       	call   8014f6 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  801f4f:	50                   	push   %eax
  801f50:	68 60 27 80 00       	push   $0x802760
  801f55:	6a 23                	push   $0x23
  801f57:	68 d6 27 80 00       	push   $0x8027d6
  801f5c:	e8 95 f5 ff ff       	call   8014f6 <_panic>

00801f61 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	56                   	push   %esi
  801f65:	53                   	push   %ebx
  801f66:	8b 75 08             	mov    0x8(%ebp),%esi
  801f69:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f6c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801f6f:	85 c0                	test   %eax,%eax
  801f71:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f76:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801f79:	83 ec 0c             	sub    $0xc,%esp
  801f7c:	50                   	push   %eax
  801f7d:	e8 9e e3 ff ff       	call   800320 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801f82:	83 c4 10             	add    $0x10,%esp
  801f85:	85 f6                	test   %esi,%esi
  801f87:	74 14                	je     801f9d <ipc_recv+0x3c>
  801f89:	ba 00 00 00 00       	mov    $0x0,%edx
  801f8e:	85 c0                	test   %eax,%eax
  801f90:	78 09                	js     801f9b <ipc_recv+0x3a>
  801f92:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f98:	8b 52 74             	mov    0x74(%edx),%edx
  801f9b:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801f9d:	85 db                	test   %ebx,%ebx
  801f9f:	74 14                	je     801fb5 <ipc_recv+0x54>
  801fa1:	ba 00 00 00 00       	mov    $0x0,%edx
  801fa6:	85 c0                	test   %eax,%eax
  801fa8:	78 09                	js     801fb3 <ipc_recv+0x52>
  801faa:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801fb0:	8b 52 78             	mov    0x78(%edx),%edx
  801fb3:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801fb5:	85 c0                	test   %eax,%eax
  801fb7:	78 08                	js     801fc1 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801fb9:	a1 00 40 80 00       	mov    0x804000,%eax
  801fbe:	8b 40 70             	mov    0x70(%eax),%eax
}
  801fc1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fc4:	5b                   	pop    %ebx
  801fc5:	5e                   	pop    %esi
  801fc6:	5d                   	pop    %ebp
  801fc7:	c3                   	ret    

00801fc8 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	57                   	push   %edi
  801fcc:	56                   	push   %esi
  801fcd:	53                   	push   %ebx
  801fce:	83 ec 0c             	sub    $0xc,%esp
  801fd1:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fd4:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801fda:	85 db                	test   %ebx,%ebx
  801fdc:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fe1:	0f 44 d8             	cmove  %eax,%ebx
  801fe4:	eb 05                	jmp    801feb <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801fe6:	e8 66 e1 ff ff       	call   800151 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801feb:	ff 75 14             	push   0x14(%ebp)
  801fee:	53                   	push   %ebx
  801fef:	56                   	push   %esi
  801ff0:	57                   	push   %edi
  801ff1:	e8 07 e3 ff ff       	call   8002fd <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801ff6:	83 c4 10             	add    $0x10,%esp
  801ff9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ffc:	74 e8                	je     801fe6 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801ffe:	85 c0                	test   %eax,%eax
  802000:	78 08                	js     80200a <ipc_send+0x42>
	}while (r<0);

}
  802002:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802005:	5b                   	pop    %ebx
  802006:	5e                   	pop    %esi
  802007:	5f                   	pop    %edi
  802008:	5d                   	pop    %ebp
  802009:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80200a:	50                   	push   %eax
  80200b:	68 e4 27 80 00       	push   $0x8027e4
  802010:	6a 3d                	push   $0x3d
  802012:	68 f8 27 80 00       	push   $0x8027f8
  802017:	e8 da f4 ff ff       	call   8014f6 <_panic>

0080201c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802022:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802027:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80202a:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802030:	8b 52 50             	mov    0x50(%edx),%edx
  802033:	39 ca                	cmp    %ecx,%edx
  802035:	74 11                	je     802048 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  802037:	83 c0 01             	add    $0x1,%eax
  80203a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80203f:	75 e6                	jne    802027 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802041:	b8 00 00 00 00       	mov    $0x0,%eax
  802046:	eb 0b                	jmp    802053 <ipc_find_env+0x37>
			return envs[i].env_id;
  802048:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80204b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802050:	8b 40 48             	mov    0x48(%eax),%eax
}
  802053:	5d                   	pop    %ebp
  802054:	c3                   	ret    

00802055 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802055:	55                   	push   %ebp
  802056:	89 e5                	mov    %esp,%ebp
  802058:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80205b:	89 c2                	mov    %eax,%edx
  80205d:	c1 ea 16             	shr    $0x16,%edx
  802060:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802067:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80206c:	f6 c1 01             	test   $0x1,%cl
  80206f:	74 1c                	je     80208d <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802071:	c1 e8 0c             	shr    $0xc,%eax
  802074:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80207b:	a8 01                	test   $0x1,%al
  80207d:	74 0e                	je     80208d <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80207f:	c1 e8 0c             	shr    $0xc,%eax
  802082:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802089:	ef 
  80208a:	0f b7 d2             	movzwl %dx,%edx
}
  80208d:	89 d0                	mov    %edx,%eax
  80208f:	5d                   	pop    %ebp
  802090:	c3                   	ret    
  802091:	66 90                	xchg   %ax,%ax
  802093:	66 90                	xchg   %ax,%ax
  802095:	66 90                	xchg   %ax,%ax
  802097:	66 90                	xchg   %ax,%ax
  802099:	66 90                	xchg   %ax,%ax
  80209b:	66 90                	xchg   %ax,%ax
  80209d:	66 90                	xchg   %ax,%ax
  80209f:	90                   	nop

008020a0 <__udivdi3>:
  8020a0:	f3 0f 1e fb          	endbr32 
  8020a4:	55                   	push   %ebp
  8020a5:	57                   	push   %edi
  8020a6:	56                   	push   %esi
  8020a7:	53                   	push   %ebx
  8020a8:	83 ec 1c             	sub    $0x1c,%esp
  8020ab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8020af:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8020b3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020b7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8020bb:	85 c0                	test   %eax,%eax
  8020bd:	75 19                	jne    8020d8 <__udivdi3+0x38>
  8020bf:	39 f3                	cmp    %esi,%ebx
  8020c1:	76 4d                	jbe    802110 <__udivdi3+0x70>
  8020c3:	31 ff                	xor    %edi,%edi
  8020c5:	89 e8                	mov    %ebp,%eax
  8020c7:	89 f2                	mov    %esi,%edx
  8020c9:	f7 f3                	div    %ebx
  8020cb:	89 fa                	mov    %edi,%edx
  8020cd:	83 c4 1c             	add    $0x1c,%esp
  8020d0:	5b                   	pop    %ebx
  8020d1:	5e                   	pop    %esi
  8020d2:	5f                   	pop    %edi
  8020d3:	5d                   	pop    %ebp
  8020d4:	c3                   	ret    
  8020d5:	8d 76 00             	lea    0x0(%esi),%esi
  8020d8:	39 f0                	cmp    %esi,%eax
  8020da:	76 14                	jbe    8020f0 <__udivdi3+0x50>
  8020dc:	31 ff                	xor    %edi,%edi
  8020de:	31 c0                	xor    %eax,%eax
  8020e0:	89 fa                	mov    %edi,%edx
  8020e2:	83 c4 1c             	add    $0x1c,%esp
  8020e5:	5b                   	pop    %ebx
  8020e6:	5e                   	pop    %esi
  8020e7:	5f                   	pop    %edi
  8020e8:	5d                   	pop    %ebp
  8020e9:	c3                   	ret    
  8020ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f0:	0f bd f8             	bsr    %eax,%edi
  8020f3:	83 f7 1f             	xor    $0x1f,%edi
  8020f6:	75 48                	jne    802140 <__udivdi3+0xa0>
  8020f8:	39 f0                	cmp    %esi,%eax
  8020fa:	72 06                	jb     802102 <__udivdi3+0x62>
  8020fc:	31 c0                	xor    %eax,%eax
  8020fe:	39 eb                	cmp    %ebp,%ebx
  802100:	77 de                	ja     8020e0 <__udivdi3+0x40>
  802102:	b8 01 00 00 00       	mov    $0x1,%eax
  802107:	eb d7                	jmp    8020e0 <__udivdi3+0x40>
  802109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802110:	89 d9                	mov    %ebx,%ecx
  802112:	85 db                	test   %ebx,%ebx
  802114:	75 0b                	jne    802121 <__udivdi3+0x81>
  802116:	b8 01 00 00 00       	mov    $0x1,%eax
  80211b:	31 d2                	xor    %edx,%edx
  80211d:	f7 f3                	div    %ebx
  80211f:	89 c1                	mov    %eax,%ecx
  802121:	31 d2                	xor    %edx,%edx
  802123:	89 f0                	mov    %esi,%eax
  802125:	f7 f1                	div    %ecx
  802127:	89 c6                	mov    %eax,%esi
  802129:	89 e8                	mov    %ebp,%eax
  80212b:	89 f7                	mov    %esi,%edi
  80212d:	f7 f1                	div    %ecx
  80212f:	89 fa                	mov    %edi,%edx
  802131:	83 c4 1c             	add    $0x1c,%esp
  802134:	5b                   	pop    %ebx
  802135:	5e                   	pop    %esi
  802136:	5f                   	pop    %edi
  802137:	5d                   	pop    %ebp
  802138:	c3                   	ret    
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	89 f9                	mov    %edi,%ecx
  802142:	ba 20 00 00 00       	mov    $0x20,%edx
  802147:	29 fa                	sub    %edi,%edx
  802149:	d3 e0                	shl    %cl,%eax
  80214b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80214f:	89 d1                	mov    %edx,%ecx
  802151:	89 d8                	mov    %ebx,%eax
  802153:	d3 e8                	shr    %cl,%eax
  802155:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802159:	09 c1                	or     %eax,%ecx
  80215b:	89 f0                	mov    %esi,%eax
  80215d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802161:	89 f9                	mov    %edi,%ecx
  802163:	d3 e3                	shl    %cl,%ebx
  802165:	89 d1                	mov    %edx,%ecx
  802167:	d3 e8                	shr    %cl,%eax
  802169:	89 f9                	mov    %edi,%ecx
  80216b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80216f:	89 eb                	mov    %ebp,%ebx
  802171:	d3 e6                	shl    %cl,%esi
  802173:	89 d1                	mov    %edx,%ecx
  802175:	d3 eb                	shr    %cl,%ebx
  802177:	09 f3                	or     %esi,%ebx
  802179:	89 c6                	mov    %eax,%esi
  80217b:	89 f2                	mov    %esi,%edx
  80217d:	89 d8                	mov    %ebx,%eax
  80217f:	f7 74 24 08          	divl   0x8(%esp)
  802183:	89 d6                	mov    %edx,%esi
  802185:	89 c3                	mov    %eax,%ebx
  802187:	f7 64 24 0c          	mull   0xc(%esp)
  80218b:	39 d6                	cmp    %edx,%esi
  80218d:	72 19                	jb     8021a8 <__udivdi3+0x108>
  80218f:	89 f9                	mov    %edi,%ecx
  802191:	d3 e5                	shl    %cl,%ebp
  802193:	39 c5                	cmp    %eax,%ebp
  802195:	73 04                	jae    80219b <__udivdi3+0xfb>
  802197:	39 d6                	cmp    %edx,%esi
  802199:	74 0d                	je     8021a8 <__udivdi3+0x108>
  80219b:	89 d8                	mov    %ebx,%eax
  80219d:	31 ff                	xor    %edi,%edi
  80219f:	e9 3c ff ff ff       	jmp    8020e0 <__udivdi3+0x40>
  8021a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8021ab:	31 ff                	xor    %edi,%edi
  8021ad:	e9 2e ff ff ff       	jmp    8020e0 <__udivdi3+0x40>
  8021b2:	66 90                	xchg   %ax,%ax
  8021b4:	66 90                	xchg   %ax,%ax
  8021b6:	66 90                	xchg   %ax,%ax
  8021b8:	66 90                	xchg   %ax,%ax
  8021ba:	66 90                	xchg   %ax,%ax
  8021bc:	66 90                	xchg   %ax,%ax
  8021be:	66 90                	xchg   %ax,%ax

008021c0 <__umoddi3>:
  8021c0:	f3 0f 1e fb          	endbr32 
  8021c4:	55                   	push   %ebp
  8021c5:	57                   	push   %edi
  8021c6:	56                   	push   %esi
  8021c7:	53                   	push   %ebx
  8021c8:	83 ec 1c             	sub    $0x1c,%esp
  8021cb:	8b 74 24 30          	mov    0x30(%esp),%esi
  8021cf:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8021d3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8021d7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8021db:	89 f0                	mov    %esi,%eax
  8021dd:	89 da                	mov    %ebx,%edx
  8021df:	85 ff                	test   %edi,%edi
  8021e1:	75 15                	jne    8021f8 <__umoddi3+0x38>
  8021e3:	39 dd                	cmp    %ebx,%ebp
  8021e5:	76 39                	jbe    802220 <__umoddi3+0x60>
  8021e7:	f7 f5                	div    %ebp
  8021e9:	89 d0                	mov    %edx,%eax
  8021eb:	31 d2                	xor    %edx,%edx
  8021ed:	83 c4 1c             	add    $0x1c,%esp
  8021f0:	5b                   	pop    %ebx
  8021f1:	5e                   	pop    %esi
  8021f2:	5f                   	pop    %edi
  8021f3:	5d                   	pop    %ebp
  8021f4:	c3                   	ret    
  8021f5:	8d 76 00             	lea    0x0(%esi),%esi
  8021f8:	39 df                	cmp    %ebx,%edi
  8021fa:	77 f1                	ja     8021ed <__umoddi3+0x2d>
  8021fc:	0f bd cf             	bsr    %edi,%ecx
  8021ff:	83 f1 1f             	xor    $0x1f,%ecx
  802202:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802206:	75 40                	jne    802248 <__umoddi3+0x88>
  802208:	39 df                	cmp    %ebx,%edi
  80220a:	72 04                	jb     802210 <__umoddi3+0x50>
  80220c:	39 f5                	cmp    %esi,%ebp
  80220e:	77 dd                	ja     8021ed <__umoddi3+0x2d>
  802210:	89 da                	mov    %ebx,%edx
  802212:	89 f0                	mov    %esi,%eax
  802214:	29 e8                	sub    %ebp,%eax
  802216:	19 fa                	sbb    %edi,%edx
  802218:	eb d3                	jmp    8021ed <__umoddi3+0x2d>
  80221a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802220:	89 e9                	mov    %ebp,%ecx
  802222:	85 ed                	test   %ebp,%ebp
  802224:	75 0b                	jne    802231 <__umoddi3+0x71>
  802226:	b8 01 00 00 00       	mov    $0x1,%eax
  80222b:	31 d2                	xor    %edx,%edx
  80222d:	f7 f5                	div    %ebp
  80222f:	89 c1                	mov    %eax,%ecx
  802231:	89 d8                	mov    %ebx,%eax
  802233:	31 d2                	xor    %edx,%edx
  802235:	f7 f1                	div    %ecx
  802237:	89 f0                	mov    %esi,%eax
  802239:	f7 f1                	div    %ecx
  80223b:	89 d0                	mov    %edx,%eax
  80223d:	31 d2                	xor    %edx,%edx
  80223f:	eb ac                	jmp    8021ed <__umoddi3+0x2d>
  802241:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802248:	8b 44 24 04          	mov    0x4(%esp),%eax
  80224c:	ba 20 00 00 00       	mov    $0x20,%edx
  802251:	29 c2                	sub    %eax,%edx
  802253:	89 c1                	mov    %eax,%ecx
  802255:	89 e8                	mov    %ebp,%eax
  802257:	d3 e7                	shl    %cl,%edi
  802259:	89 d1                	mov    %edx,%ecx
  80225b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80225f:	d3 e8                	shr    %cl,%eax
  802261:	89 c1                	mov    %eax,%ecx
  802263:	8b 44 24 04          	mov    0x4(%esp),%eax
  802267:	09 f9                	or     %edi,%ecx
  802269:	89 df                	mov    %ebx,%edi
  80226b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80226f:	89 c1                	mov    %eax,%ecx
  802271:	d3 e5                	shl    %cl,%ebp
  802273:	89 d1                	mov    %edx,%ecx
  802275:	d3 ef                	shr    %cl,%edi
  802277:	89 c1                	mov    %eax,%ecx
  802279:	89 f0                	mov    %esi,%eax
  80227b:	d3 e3                	shl    %cl,%ebx
  80227d:	89 d1                	mov    %edx,%ecx
  80227f:	89 fa                	mov    %edi,%edx
  802281:	d3 e8                	shr    %cl,%eax
  802283:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802288:	09 d8                	or     %ebx,%eax
  80228a:	f7 74 24 08          	divl   0x8(%esp)
  80228e:	89 d3                	mov    %edx,%ebx
  802290:	d3 e6                	shl    %cl,%esi
  802292:	f7 e5                	mul    %ebp
  802294:	89 c7                	mov    %eax,%edi
  802296:	89 d1                	mov    %edx,%ecx
  802298:	39 d3                	cmp    %edx,%ebx
  80229a:	72 06                	jb     8022a2 <__umoddi3+0xe2>
  80229c:	75 0e                	jne    8022ac <__umoddi3+0xec>
  80229e:	39 c6                	cmp    %eax,%esi
  8022a0:	73 0a                	jae    8022ac <__umoddi3+0xec>
  8022a2:	29 e8                	sub    %ebp,%eax
  8022a4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8022a8:	89 d1                	mov    %edx,%ecx
  8022aa:	89 c7                	mov    %eax,%edi
  8022ac:	89 f5                	mov    %esi,%ebp
  8022ae:	8b 74 24 04          	mov    0x4(%esp),%esi
  8022b2:	29 fd                	sub    %edi,%ebp
  8022b4:	19 cb                	sbb    %ecx,%ebx
  8022b6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8022bb:	89 d8                	mov    %ebx,%eax
  8022bd:	d3 e0                	shl    %cl,%eax
  8022bf:	89 f1                	mov    %esi,%ecx
  8022c1:	d3 ed                	shr    %cl,%ebp
  8022c3:	d3 eb                	shr    %cl,%ebx
  8022c5:	09 e8                	or     %ebp,%eax
  8022c7:	89 da                	mov    %ebx,%edx
  8022c9:	83 c4 1c             	add    $0x1c,%esp
  8022cc:	5b                   	pop    %ebx
  8022cd:	5e                   	pop    %esi
  8022ce:	5f                   	pop    %edi
  8022cf:	5d                   	pop    %ebp
  8022d0:	c3                   	ret    
