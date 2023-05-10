
obj/user/faultevilhandler.debug：     文件格式 elf32-i386


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
  800042:	e8 3d 01 00 00       	call   800184 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
  80004f:	6a 00                	push   $0x0
  800051:	e8 79 02 00 00       	call   8002cf <sys_env_set_pgfault_upcall>
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
  800070:	e8 d1 00 00 00       	call   800146 <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800080:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800085:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008a:	85 db                	test   %ebx,%ebx
  80008c:	7e 07                	jle    800095 <libmain+0x30>
		binaryname = argv[0];
  80008e:	8b 06                	mov    (%esi),%eax
  800090:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800095:	83 ec 08             	sub    $0x8,%esp
  800098:	56                   	push   %esi
  800099:	53                   	push   %ebx
  80009a:	e8 94 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009f:	e8 0a 00 00 00       	call   8000ae <exit>
}
  8000a4:	83 c4 10             	add    $0x10,%esp
  8000a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000aa:	5b                   	pop    %ebx
  8000ab:	5e                   	pop    %esi
  8000ac:	5d                   	pop    %ebp
  8000ad:	c3                   	ret    

008000ae <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b4:	e8 ee 04 00 00       	call   8005a7 <close_all>
	sys_env_destroy(0);
  8000b9:	83 ec 0c             	sub    $0xc,%esp
  8000bc:	6a 00                	push   $0x0
  8000be:	e8 42 00 00 00       	call   800105 <sys_env_destroy>
}
  8000c3:	83 c4 10             	add    $0x10,%esp
  8000c6:	c9                   	leave  
  8000c7:	c3                   	ret    

008000c8 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	57                   	push   %edi
  8000cc:	56                   	push   %esi
  8000cd:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d9:	89 c3                	mov    %eax,%ebx
  8000db:	89 c7                	mov    %eax,%edi
  8000dd:	89 c6                	mov    %eax,%esi
  8000df:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000e1:	5b                   	pop    %ebx
  8000e2:	5e                   	pop    %esi
  8000e3:	5f                   	pop    %edi
  8000e4:	5d                   	pop    %ebp
  8000e5:	c3                   	ret    

008000e6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e6:	55                   	push   %ebp
  8000e7:	89 e5                	mov    %esp,%ebp
  8000e9:	57                   	push   %edi
  8000ea:	56                   	push   %esi
  8000eb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f6:	89 d1                	mov    %edx,%ecx
  8000f8:	89 d3                	mov    %edx,%ebx
  8000fa:	89 d7                	mov    %edx,%edi
  8000fc:	89 d6                	mov    %edx,%esi
  8000fe:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5f                   	pop    %edi
  800103:	5d                   	pop    %ebp
  800104:	c3                   	ret    

00800105 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800105:	55                   	push   %ebp
  800106:	89 e5                	mov    %esp,%ebp
  800108:	57                   	push   %edi
  800109:	56                   	push   %esi
  80010a:	53                   	push   %ebx
  80010b:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80010e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800113:	8b 55 08             	mov    0x8(%ebp),%edx
  800116:	b8 03 00 00 00       	mov    $0x3,%eax
  80011b:	89 cb                	mov    %ecx,%ebx
  80011d:	89 cf                	mov    %ecx,%edi
  80011f:	89 ce                	mov    %ecx,%esi
  800121:	cd 30                	int    $0x30
	if(check && ret > 0)
  800123:	85 c0                	test   %eax,%eax
  800125:	7f 08                	jg     80012f <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800127:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80012a:	5b                   	pop    %ebx
  80012b:	5e                   	pop    %esi
  80012c:	5f                   	pop    %edi
  80012d:	5d                   	pop    %ebp
  80012e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80012f:	83 ec 0c             	sub    $0xc,%esp
  800132:	50                   	push   %eax
  800133:	6a 03                	push   $0x3
  800135:	68 6a 22 80 00       	push   $0x80226a
  80013a:	6a 2a                	push   $0x2a
  80013c:	68 87 22 80 00       	push   $0x802287
  800141:	e8 9e 13 00 00       	call   8014e4 <_panic>

00800146 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800146:	55                   	push   %ebp
  800147:	89 e5                	mov    %esp,%ebp
  800149:	57                   	push   %edi
  80014a:	56                   	push   %esi
  80014b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80014c:	ba 00 00 00 00       	mov    $0x0,%edx
  800151:	b8 02 00 00 00       	mov    $0x2,%eax
  800156:	89 d1                	mov    %edx,%ecx
  800158:	89 d3                	mov    %edx,%ebx
  80015a:	89 d7                	mov    %edx,%edi
  80015c:	89 d6                	mov    %edx,%esi
  80015e:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800160:	5b                   	pop    %ebx
  800161:	5e                   	pop    %esi
  800162:	5f                   	pop    %edi
  800163:	5d                   	pop    %ebp
  800164:	c3                   	ret    

00800165 <sys_yield>:

void
sys_yield(void)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80016b:	ba 00 00 00 00       	mov    $0x0,%edx
  800170:	b8 0b 00 00 00       	mov    $0xb,%eax
  800175:	89 d1                	mov    %edx,%ecx
  800177:	89 d3                	mov    %edx,%ebx
  800179:	89 d7                	mov    %edx,%edi
  80017b:	89 d6                	mov    %edx,%esi
  80017d:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5f                   	pop    %edi
  800182:	5d                   	pop    %ebp
  800183:	c3                   	ret    

00800184 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800184:	55                   	push   %ebp
  800185:	89 e5                	mov    %esp,%ebp
  800187:	57                   	push   %edi
  800188:	56                   	push   %esi
  800189:	53                   	push   %ebx
  80018a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80018d:	be 00 00 00 00       	mov    $0x0,%esi
  800192:	8b 55 08             	mov    0x8(%ebp),%edx
  800195:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800198:	b8 04 00 00 00       	mov    $0x4,%eax
  80019d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a0:	89 f7                	mov    %esi,%edi
  8001a2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001a4:	85 c0                	test   %eax,%eax
  8001a6:	7f 08                	jg     8001b0 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ab:	5b                   	pop    %ebx
  8001ac:	5e                   	pop    %esi
  8001ad:	5f                   	pop    %edi
  8001ae:	5d                   	pop    %ebp
  8001af:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b0:	83 ec 0c             	sub    $0xc,%esp
  8001b3:	50                   	push   %eax
  8001b4:	6a 04                	push   $0x4
  8001b6:	68 6a 22 80 00       	push   $0x80226a
  8001bb:	6a 2a                	push   $0x2a
  8001bd:	68 87 22 80 00       	push   $0x802287
  8001c2:	e8 1d 13 00 00       	call   8014e4 <_panic>

008001c7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c7:	55                   	push   %ebp
  8001c8:	89 e5                	mov    %esp,%ebp
  8001ca:	57                   	push   %edi
  8001cb:	56                   	push   %esi
  8001cc:	53                   	push   %ebx
  8001cd:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001db:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001de:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001e1:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001e6:	85 c0                	test   %eax,%eax
  8001e8:	7f 08                	jg     8001f2 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ed:	5b                   	pop    %ebx
  8001ee:	5e                   	pop    %esi
  8001ef:	5f                   	pop    %edi
  8001f0:	5d                   	pop    %ebp
  8001f1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001f2:	83 ec 0c             	sub    $0xc,%esp
  8001f5:	50                   	push   %eax
  8001f6:	6a 05                	push   $0x5
  8001f8:	68 6a 22 80 00       	push   $0x80226a
  8001fd:	6a 2a                	push   $0x2a
  8001ff:	68 87 22 80 00       	push   $0x802287
  800204:	e8 db 12 00 00       	call   8014e4 <_panic>

00800209 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	57                   	push   %edi
  80020d:	56                   	push   %esi
  80020e:	53                   	push   %ebx
  80020f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800212:	bb 00 00 00 00       	mov    $0x0,%ebx
  800217:	8b 55 08             	mov    0x8(%ebp),%edx
  80021a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021d:	b8 06 00 00 00       	mov    $0x6,%eax
  800222:	89 df                	mov    %ebx,%edi
  800224:	89 de                	mov    %ebx,%esi
  800226:	cd 30                	int    $0x30
	if(check && ret > 0)
  800228:	85 c0                	test   %eax,%eax
  80022a:	7f 08                	jg     800234 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80022c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022f:	5b                   	pop    %ebx
  800230:	5e                   	pop    %esi
  800231:	5f                   	pop    %edi
  800232:	5d                   	pop    %ebp
  800233:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	50                   	push   %eax
  800238:	6a 06                	push   $0x6
  80023a:	68 6a 22 80 00       	push   $0x80226a
  80023f:	6a 2a                	push   $0x2a
  800241:	68 87 22 80 00       	push   $0x802287
  800246:	e8 99 12 00 00       	call   8014e4 <_panic>

0080024b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	57                   	push   %edi
  80024f:	56                   	push   %esi
  800250:	53                   	push   %ebx
  800251:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800254:	bb 00 00 00 00       	mov    $0x0,%ebx
  800259:	8b 55 08             	mov    0x8(%ebp),%edx
  80025c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025f:	b8 08 00 00 00       	mov    $0x8,%eax
  800264:	89 df                	mov    %ebx,%edi
  800266:	89 de                	mov    %ebx,%esi
  800268:	cd 30                	int    $0x30
	if(check && ret > 0)
  80026a:	85 c0                	test   %eax,%eax
  80026c:	7f 08                	jg     800276 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800271:	5b                   	pop    %ebx
  800272:	5e                   	pop    %esi
  800273:	5f                   	pop    %edi
  800274:	5d                   	pop    %ebp
  800275:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800276:	83 ec 0c             	sub    $0xc,%esp
  800279:	50                   	push   %eax
  80027a:	6a 08                	push   $0x8
  80027c:	68 6a 22 80 00       	push   $0x80226a
  800281:	6a 2a                	push   $0x2a
  800283:	68 87 22 80 00       	push   $0x802287
  800288:	e8 57 12 00 00       	call   8014e4 <_panic>

0080028d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	57                   	push   %edi
  800291:	56                   	push   %esi
  800292:	53                   	push   %ebx
  800293:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800296:	bb 00 00 00 00       	mov    $0x0,%ebx
  80029b:	8b 55 08             	mov    0x8(%ebp),%edx
  80029e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a1:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a6:	89 df                	mov    %ebx,%edi
  8002a8:	89 de                	mov    %ebx,%esi
  8002aa:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002ac:	85 c0                	test   %eax,%eax
  8002ae:	7f 08                	jg     8002b8 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b3:	5b                   	pop    %ebx
  8002b4:	5e                   	pop    %esi
  8002b5:	5f                   	pop    %edi
  8002b6:	5d                   	pop    %ebp
  8002b7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b8:	83 ec 0c             	sub    $0xc,%esp
  8002bb:	50                   	push   %eax
  8002bc:	6a 09                	push   $0x9
  8002be:	68 6a 22 80 00       	push   $0x80226a
  8002c3:	6a 2a                	push   $0x2a
  8002c5:	68 87 22 80 00       	push   $0x802287
  8002ca:	e8 15 12 00 00       	call   8014e4 <_panic>

008002cf <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cf:	55                   	push   %ebp
  8002d0:	89 e5                	mov    %esp,%ebp
  8002d2:	57                   	push   %edi
  8002d3:	56                   	push   %esi
  8002d4:	53                   	push   %ebx
  8002d5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002e8:	89 df                	mov    %ebx,%edi
  8002ea:	89 de                	mov    %ebx,%esi
  8002ec:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002ee:	85 c0                	test   %eax,%eax
  8002f0:	7f 08                	jg     8002fa <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f5:	5b                   	pop    %ebx
  8002f6:	5e                   	pop    %esi
  8002f7:	5f                   	pop    %edi
  8002f8:	5d                   	pop    %ebp
  8002f9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002fa:	83 ec 0c             	sub    $0xc,%esp
  8002fd:	50                   	push   %eax
  8002fe:	6a 0a                	push   $0xa
  800300:	68 6a 22 80 00       	push   $0x80226a
  800305:	6a 2a                	push   $0x2a
  800307:	68 87 22 80 00       	push   $0x802287
  80030c:	e8 d3 11 00 00       	call   8014e4 <_panic>

00800311 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	57                   	push   %edi
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
	asm volatile("int %1\n"
  800317:	8b 55 08             	mov    0x8(%ebp),%edx
  80031a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800322:	be 00 00 00 00       	mov    $0x0,%esi
  800327:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80032a:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032d:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032f:	5b                   	pop    %ebx
  800330:	5e                   	pop    %esi
  800331:	5f                   	pop    %edi
  800332:	5d                   	pop    %ebp
  800333:	c3                   	ret    

00800334 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	57                   	push   %edi
  800338:	56                   	push   %esi
  800339:	53                   	push   %ebx
  80033a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80033d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800342:	8b 55 08             	mov    0x8(%ebp),%edx
  800345:	b8 0d 00 00 00       	mov    $0xd,%eax
  80034a:	89 cb                	mov    %ecx,%ebx
  80034c:	89 cf                	mov    %ecx,%edi
  80034e:	89 ce                	mov    %ecx,%esi
  800350:	cd 30                	int    $0x30
	if(check && ret > 0)
  800352:	85 c0                	test   %eax,%eax
  800354:	7f 08                	jg     80035e <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800356:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800359:	5b                   	pop    %ebx
  80035a:	5e                   	pop    %esi
  80035b:	5f                   	pop    %edi
  80035c:	5d                   	pop    %ebp
  80035d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80035e:	83 ec 0c             	sub    $0xc,%esp
  800361:	50                   	push   %eax
  800362:	6a 0d                	push   $0xd
  800364:	68 6a 22 80 00       	push   $0x80226a
  800369:	6a 2a                	push   $0x2a
  80036b:	68 87 22 80 00       	push   $0x802287
  800370:	e8 6f 11 00 00       	call   8014e4 <_panic>

00800375 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800375:	55                   	push   %ebp
  800376:	89 e5                	mov    %esp,%ebp
  800378:	57                   	push   %edi
  800379:	56                   	push   %esi
  80037a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80037b:	ba 00 00 00 00       	mov    $0x0,%edx
  800380:	b8 0e 00 00 00       	mov    $0xe,%eax
  800385:	89 d1                	mov    %edx,%ecx
  800387:	89 d3                	mov    %edx,%ebx
  800389:	89 d7                	mov    %edx,%edi
  80038b:	89 d6                	mov    %edx,%esi
  80038d:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80038f:	5b                   	pop    %ebx
  800390:	5e                   	pop    %esi
  800391:	5f                   	pop    %edi
  800392:	5d                   	pop    %ebp
  800393:	c3                   	ret    

00800394 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800394:	55                   	push   %ebp
  800395:	89 e5                	mov    %esp,%ebp
  800397:	57                   	push   %edi
  800398:	56                   	push   %esi
  800399:	53                   	push   %ebx
	asm volatile("int %1\n"
  80039a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80039f:	8b 55 08             	mov    0x8(%ebp),%edx
  8003a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003a5:	b8 0f 00 00 00       	mov    $0xf,%eax
  8003aa:	89 df                	mov    %ebx,%edi
  8003ac:	89 de                	mov    %ebx,%esi
  8003ae:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  8003b0:	5b                   	pop    %ebx
  8003b1:	5e                   	pop    %esi
  8003b2:	5f                   	pop    %edi
  8003b3:	5d                   	pop    %ebp
  8003b4:	c3                   	ret    

008003b5 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
  8003b8:	57                   	push   %edi
  8003b9:	56                   	push   %esi
  8003ba:	53                   	push   %ebx
	asm volatile("int %1\n"
  8003bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c6:	b8 10 00 00 00       	mov    $0x10,%eax
  8003cb:	89 df                	mov    %ebx,%edi
  8003cd:	89 de                	mov    %ebx,%esi
  8003cf:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8003d1:	5b                   	pop    %ebx
  8003d2:	5e                   	pop    %esi
  8003d3:	5f                   	pop    %edi
  8003d4:	5d                   	pop    %ebp
  8003d5:	c3                   	ret    

008003d6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003d6:	55                   	push   %ebp
  8003d7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003dc:	05 00 00 00 30       	add    $0x30000000,%eax
  8003e1:	c1 e8 0c             	shr    $0xc,%eax
}
  8003e4:	5d                   	pop    %ebp
  8003e5:	c3                   	ret    

008003e6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003e6:	55                   	push   %ebp
  8003e7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ec:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003f1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003f6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    

008003fd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800405:	89 c2                	mov    %eax,%edx
  800407:	c1 ea 16             	shr    $0x16,%edx
  80040a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800411:	f6 c2 01             	test   $0x1,%dl
  800414:	74 29                	je     80043f <fd_alloc+0x42>
  800416:	89 c2                	mov    %eax,%edx
  800418:	c1 ea 0c             	shr    $0xc,%edx
  80041b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800422:	f6 c2 01             	test   $0x1,%dl
  800425:	74 18                	je     80043f <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800427:	05 00 10 00 00       	add    $0x1000,%eax
  80042c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800431:	75 d2                	jne    800405 <fd_alloc+0x8>
  800433:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800438:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80043d:	eb 05                	jmp    800444 <fd_alloc+0x47>
			return 0;
  80043f:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800444:	8b 55 08             	mov    0x8(%ebp),%edx
  800447:	89 02                	mov    %eax,(%edx)
}
  800449:	89 c8                	mov    %ecx,%eax
  80044b:	5d                   	pop    %ebp
  80044c:	c3                   	ret    

0080044d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80044d:	55                   	push   %ebp
  80044e:	89 e5                	mov    %esp,%ebp
  800450:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800453:	83 f8 1f             	cmp    $0x1f,%eax
  800456:	77 30                	ja     800488 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800458:	c1 e0 0c             	shl    $0xc,%eax
  80045b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800460:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800466:	f6 c2 01             	test   $0x1,%dl
  800469:	74 24                	je     80048f <fd_lookup+0x42>
  80046b:	89 c2                	mov    %eax,%edx
  80046d:	c1 ea 0c             	shr    $0xc,%edx
  800470:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800477:	f6 c2 01             	test   $0x1,%dl
  80047a:	74 1a                	je     800496 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80047c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80047f:	89 02                	mov    %eax,(%edx)
	return 0;
  800481:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800486:	5d                   	pop    %ebp
  800487:	c3                   	ret    
		return -E_INVAL;
  800488:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80048d:	eb f7                	jmp    800486 <fd_lookup+0x39>
		return -E_INVAL;
  80048f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800494:	eb f0                	jmp    800486 <fd_lookup+0x39>
  800496:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80049b:	eb e9                	jmp    800486 <fd_lookup+0x39>

0080049d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80049d:	55                   	push   %ebp
  80049e:	89 e5                	mov    %esp,%ebp
  8004a0:	53                   	push   %ebx
  8004a1:	83 ec 04             	sub    $0x4,%esp
  8004a4:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ac:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8004b1:	39 13                	cmp    %edx,(%ebx)
  8004b3:	74 37                	je     8004ec <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8004b5:	83 c0 01             	add    $0x1,%eax
  8004b8:	8b 1c 85 14 23 80 00 	mov    0x802314(,%eax,4),%ebx
  8004bf:	85 db                	test   %ebx,%ebx
  8004c1:	75 ee                	jne    8004b1 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004c3:	a1 00 40 80 00       	mov    0x804000,%eax
  8004c8:	8b 40 58             	mov    0x58(%eax),%eax
  8004cb:	83 ec 04             	sub    $0x4,%esp
  8004ce:	52                   	push   %edx
  8004cf:	50                   	push   %eax
  8004d0:	68 98 22 80 00       	push   $0x802298
  8004d5:	e8 e5 10 00 00       	call   8015bf <cprintf>
	*dev = 0;
	return -E_INVAL;
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8004e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004e5:	89 1a                	mov    %ebx,(%edx)
}
  8004e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004ea:	c9                   	leave  
  8004eb:	c3                   	ret    
			return 0;
  8004ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f1:	eb ef                	jmp    8004e2 <dev_lookup+0x45>

008004f3 <fd_close>:
{
  8004f3:	55                   	push   %ebp
  8004f4:	89 e5                	mov    %esp,%ebp
  8004f6:	57                   	push   %edi
  8004f7:	56                   	push   %esi
  8004f8:	53                   	push   %ebx
  8004f9:	83 ec 24             	sub    $0x24,%esp
  8004fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004ff:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800502:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800505:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800506:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80050c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80050f:	50                   	push   %eax
  800510:	e8 38 ff ff ff       	call   80044d <fd_lookup>
  800515:	89 c3                	mov    %eax,%ebx
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	78 05                	js     800523 <fd_close+0x30>
	    || fd != fd2)
  80051e:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800521:	74 16                	je     800539 <fd_close+0x46>
		return (must_exist ? r : 0);
  800523:	89 f8                	mov    %edi,%eax
  800525:	84 c0                	test   %al,%al
  800527:	b8 00 00 00 00       	mov    $0x0,%eax
  80052c:	0f 44 d8             	cmove  %eax,%ebx
}
  80052f:	89 d8                	mov    %ebx,%eax
  800531:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800534:	5b                   	pop    %ebx
  800535:	5e                   	pop    %esi
  800536:	5f                   	pop    %edi
  800537:	5d                   	pop    %ebp
  800538:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800539:	83 ec 08             	sub    $0x8,%esp
  80053c:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80053f:	50                   	push   %eax
  800540:	ff 36                	push   (%esi)
  800542:	e8 56 ff ff ff       	call   80049d <dev_lookup>
  800547:	89 c3                	mov    %eax,%ebx
  800549:	83 c4 10             	add    $0x10,%esp
  80054c:	85 c0                	test   %eax,%eax
  80054e:	78 1a                	js     80056a <fd_close+0x77>
		if (dev->dev_close)
  800550:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800553:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800556:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80055b:	85 c0                	test   %eax,%eax
  80055d:	74 0b                	je     80056a <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80055f:	83 ec 0c             	sub    $0xc,%esp
  800562:	56                   	push   %esi
  800563:	ff d0                	call   *%eax
  800565:	89 c3                	mov    %eax,%ebx
  800567:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80056a:	83 ec 08             	sub    $0x8,%esp
  80056d:	56                   	push   %esi
  80056e:	6a 00                	push   $0x0
  800570:	e8 94 fc ff ff       	call   800209 <sys_page_unmap>
	return r;
  800575:	83 c4 10             	add    $0x10,%esp
  800578:	eb b5                	jmp    80052f <fd_close+0x3c>

0080057a <close>:

int
close(int fdnum)
{
  80057a:	55                   	push   %ebp
  80057b:	89 e5                	mov    %esp,%ebp
  80057d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800580:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800583:	50                   	push   %eax
  800584:	ff 75 08             	push   0x8(%ebp)
  800587:	e8 c1 fe ff ff       	call   80044d <fd_lookup>
  80058c:	83 c4 10             	add    $0x10,%esp
  80058f:	85 c0                	test   %eax,%eax
  800591:	79 02                	jns    800595 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800593:	c9                   	leave  
  800594:	c3                   	ret    
		return fd_close(fd, 1);
  800595:	83 ec 08             	sub    $0x8,%esp
  800598:	6a 01                	push   $0x1
  80059a:	ff 75 f4             	push   -0xc(%ebp)
  80059d:	e8 51 ff ff ff       	call   8004f3 <fd_close>
  8005a2:	83 c4 10             	add    $0x10,%esp
  8005a5:	eb ec                	jmp    800593 <close+0x19>

008005a7 <close_all>:

void
close_all(void)
{
  8005a7:	55                   	push   %ebp
  8005a8:	89 e5                	mov    %esp,%ebp
  8005aa:	53                   	push   %ebx
  8005ab:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005ae:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005b3:	83 ec 0c             	sub    $0xc,%esp
  8005b6:	53                   	push   %ebx
  8005b7:	e8 be ff ff ff       	call   80057a <close>
	for (i = 0; i < MAXFD; i++)
  8005bc:	83 c3 01             	add    $0x1,%ebx
  8005bf:	83 c4 10             	add    $0x10,%esp
  8005c2:	83 fb 20             	cmp    $0x20,%ebx
  8005c5:	75 ec                	jne    8005b3 <close_all+0xc>
}
  8005c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005ca:	c9                   	leave  
  8005cb:	c3                   	ret    

008005cc <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005cc:	55                   	push   %ebp
  8005cd:	89 e5                	mov    %esp,%ebp
  8005cf:	57                   	push   %edi
  8005d0:	56                   	push   %esi
  8005d1:	53                   	push   %ebx
  8005d2:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005d5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005d8:	50                   	push   %eax
  8005d9:	ff 75 08             	push   0x8(%ebp)
  8005dc:	e8 6c fe ff ff       	call   80044d <fd_lookup>
  8005e1:	89 c3                	mov    %eax,%ebx
  8005e3:	83 c4 10             	add    $0x10,%esp
  8005e6:	85 c0                	test   %eax,%eax
  8005e8:	78 7f                	js     800669 <dup+0x9d>
		return r;
	close(newfdnum);
  8005ea:	83 ec 0c             	sub    $0xc,%esp
  8005ed:	ff 75 0c             	push   0xc(%ebp)
  8005f0:	e8 85 ff ff ff       	call   80057a <close>

	newfd = INDEX2FD(newfdnum);
  8005f5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005f8:	c1 e6 0c             	shl    $0xc,%esi
  8005fb:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800601:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800604:	89 3c 24             	mov    %edi,(%esp)
  800607:	e8 da fd ff ff       	call   8003e6 <fd2data>
  80060c:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80060e:	89 34 24             	mov    %esi,(%esp)
  800611:	e8 d0 fd ff ff       	call   8003e6 <fd2data>
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80061c:	89 d8                	mov    %ebx,%eax
  80061e:	c1 e8 16             	shr    $0x16,%eax
  800621:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800628:	a8 01                	test   $0x1,%al
  80062a:	74 11                	je     80063d <dup+0x71>
  80062c:	89 d8                	mov    %ebx,%eax
  80062e:	c1 e8 0c             	shr    $0xc,%eax
  800631:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800638:	f6 c2 01             	test   $0x1,%dl
  80063b:	75 36                	jne    800673 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80063d:	89 f8                	mov    %edi,%eax
  80063f:	c1 e8 0c             	shr    $0xc,%eax
  800642:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800649:	83 ec 0c             	sub    $0xc,%esp
  80064c:	25 07 0e 00 00       	and    $0xe07,%eax
  800651:	50                   	push   %eax
  800652:	56                   	push   %esi
  800653:	6a 00                	push   $0x0
  800655:	57                   	push   %edi
  800656:	6a 00                	push   $0x0
  800658:	e8 6a fb ff ff       	call   8001c7 <sys_page_map>
  80065d:	89 c3                	mov    %eax,%ebx
  80065f:	83 c4 20             	add    $0x20,%esp
  800662:	85 c0                	test   %eax,%eax
  800664:	78 33                	js     800699 <dup+0xcd>
		goto err;

	return newfdnum;
  800666:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800669:	89 d8                	mov    %ebx,%eax
  80066b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066e:	5b                   	pop    %ebx
  80066f:	5e                   	pop    %esi
  800670:	5f                   	pop    %edi
  800671:	5d                   	pop    %ebp
  800672:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800673:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80067a:	83 ec 0c             	sub    $0xc,%esp
  80067d:	25 07 0e 00 00       	and    $0xe07,%eax
  800682:	50                   	push   %eax
  800683:	ff 75 d4             	push   -0x2c(%ebp)
  800686:	6a 00                	push   $0x0
  800688:	53                   	push   %ebx
  800689:	6a 00                	push   $0x0
  80068b:	e8 37 fb ff ff       	call   8001c7 <sys_page_map>
  800690:	89 c3                	mov    %eax,%ebx
  800692:	83 c4 20             	add    $0x20,%esp
  800695:	85 c0                	test   %eax,%eax
  800697:	79 a4                	jns    80063d <dup+0x71>
	sys_page_unmap(0, newfd);
  800699:	83 ec 08             	sub    $0x8,%esp
  80069c:	56                   	push   %esi
  80069d:	6a 00                	push   $0x0
  80069f:	e8 65 fb ff ff       	call   800209 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006a4:	83 c4 08             	add    $0x8,%esp
  8006a7:	ff 75 d4             	push   -0x2c(%ebp)
  8006aa:	6a 00                	push   $0x0
  8006ac:	e8 58 fb ff ff       	call   800209 <sys_page_unmap>
	return r;
  8006b1:	83 c4 10             	add    $0x10,%esp
  8006b4:	eb b3                	jmp    800669 <dup+0x9d>

008006b6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006b6:	55                   	push   %ebp
  8006b7:	89 e5                	mov    %esp,%ebp
  8006b9:	56                   	push   %esi
  8006ba:	53                   	push   %ebx
  8006bb:	83 ec 18             	sub    $0x18,%esp
  8006be:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006c4:	50                   	push   %eax
  8006c5:	56                   	push   %esi
  8006c6:	e8 82 fd ff ff       	call   80044d <fd_lookup>
  8006cb:	83 c4 10             	add    $0x10,%esp
  8006ce:	85 c0                	test   %eax,%eax
  8006d0:	78 3c                	js     80070e <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006d2:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8006d5:	83 ec 08             	sub    $0x8,%esp
  8006d8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006db:	50                   	push   %eax
  8006dc:	ff 33                	push   (%ebx)
  8006de:	e8 ba fd ff ff       	call   80049d <dev_lookup>
  8006e3:	83 c4 10             	add    $0x10,%esp
  8006e6:	85 c0                	test   %eax,%eax
  8006e8:	78 24                	js     80070e <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006ea:	8b 43 08             	mov    0x8(%ebx),%eax
  8006ed:	83 e0 03             	and    $0x3,%eax
  8006f0:	83 f8 01             	cmp    $0x1,%eax
  8006f3:	74 20                	je     800715 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f8:	8b 40 08             	mov    0x8(%eax),%eax
  8006fb:	85 c0                	test   %eax,%eax
  8006fd:	74 37                	je     800736 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006ff:	83 ec 04             	sub    $0x4,%esp
  800702:	ff 75 10             	push   0x10(%ebp)
  800705:	ff 75 0c             	push   0xc(%ebp)
  800708:	53                   	push   %ebx
  800709:	ff d0                	call   *%eax
  80070b:	83 c4 10             	add    $0x10,%esp
}
  80070e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800711:	5b                   	pop    %ebx
  800712:	5e                   	pop    %esi
  800713:	5d                   	pop    %ebp
  800714:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800715:	a1 00 40 80 00       	mov    0x804000,%eax
  80071a:	8b 40 58             	mov    0x58(%eax),%eax
  80071d:	83 ec 04             	sub    $0x4,%esp
  800720:	56                   	push   %esi
  800721:	50                   	push   %eax
  800722:	68 d9 22 80 00       	push   $0x8022d9
  800727:	e8 93 0e 00 00       	call   8015bf <cprintf>
		return -E_INVAL;
  80072c:	83 c4 10             	add    $0x10,%esp
  80072f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800734:	eb d8                	jmp    80070e <read+0x58>
		return -E_NOT_SUPP;
  800736:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80073b:	eb d1                	jmp    80070e <read+0x58>

0080073d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80073d:	55                   	push   %ebp
  80073e:	89 e5                	mov    %esp,%ebp
  800740:	57                   	push   %edi
  800741:	56                   	push   %esi
  800742:	53                   	push   %ebx
  800743:	83 ec 0c             	sub    $0xc,%esp
  800746:	8b 7d 08             	mov    0x8(%ebp),%edi
  800749:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80074c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800751:	eb 02                	jmp    800755 <readn+0x18>
  800753:	01 c3                	add    %eax,%ebx
  800755:	39 f3                	cmp    %esi,%ebx
  800757:	73 21                	jae    80077a <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800759:	83 ec 04             	sub    $0x4,%esp
  80075c:	89 f0                	mov    %esi,%eax
  80075e:	29 d8                	sub    %ebx,%eax
  800760:	50                   	push   %eax
  800761:	89 d8                	mov    %ebx,%eax
  800763:	03 45 0c             	add    0xc(%ebp),%eax
  800766:	50                   	push   %eax
  800767:	57                   	push   %edi
  800768:	e8 49 ff ff ff       	call   8006b6 <read>
		if (m < 0)
  80076d:	83 c4 10             	add    $0x10,%esp
  800770:	85 c0                	test   %eax,%eax
  800772:	78 04                	js     800778 <readn+0x3b>
			return m;
		if (m == 0)
  800774:	75 dd                	jne    800753 <readn+0x16>
  800776:	eb 02                	jmp    80077a <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800778:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80077a:	89 d8                	mov    %ebx,%eax
  80077c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80077f:	5b                   	pop    %ebx
  800780:	5e                   	pop    %esi
  800781:	5f                   	pop    %edi
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	56                   	push   %esi
  800788:	53                   	push   %ebx
  800789:	83 ec 18             	sub    $0x18,%esp
  80078c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80078f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800792:	50                   	push   %eax
  800793:	53                   	push   %ebx
  800794:	e8 b4 fc ff ff       	call   80044d <fd_lookup>
  800799:	83 c4 10             	add    $0x10,%esp
  80079c:	85 c0                	test   %eax,%eax
  80079e:	78 37                	js     8007d7 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a0:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8007a3:	83 ec 08             	sub    $0x8,%esp
  8007a6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007a9:	50                   	push   %eax
  8007aa:	ff 36                	push   (%esi)
  8007ac:	e8 ec fc ff ff       	call   80049d <dev_lookup>
  8007b1:	83 c4 10             	add    $0x10,%esp
  8007b4:	85 c0                	test   %eax,%eax
  8007b6:	78 1f                	js     8007d7 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007b8:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8007bc:	74 20                	je     8007de <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007c1:	8b 40 0c             	mov    0xc(%eax),%eax
  8007c4:	85 c0                	test   %eax,%eax
  8007c6:	74 37                	je     8007ff <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007c8:	83 ec 04             	sub    $0x4,%esp
  8007cb:	ff 75 10             	push   0x10(%ebp)
  8007ce:	ff 75 0c             	push   0xc(%ebp)
  8007d1:	56                   	push   %esi
  8007d2:	ff d0                	call   *%eax
  8007d4:	83 c4 10             	add    $0x10,%esp
}
  8007d7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007da:	5b                   	pop    %ebx
  8007db:	5e                   	pop    %esi
  8007dc:	5d                   	pop    %ebp
  8007dd:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007de:	a1 00 40 80 00       	mov    0x804000,%eax
  8007e3:	8b 40 58             	mov    0x58(%eax),%eax
  8007e6:	83 ec 04             	sub    $0x4,%esp
  8007e9:	53                   	push   %ebx
  8007ea:	50                   	push   %eax
  8007eb:	68 f5 22 80 00       	push   $0x8022f5
  8007f0:	e8 ca 0d 00 00       	call   8015bf <cprintf>
		return -E_INVAL;
  8007f5:	83 c4 10             	add    $0x10,%esp
  8007f8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007fd:	eb d8                	jmp    8007d7 <write+0x53>
		return -E_NOT_SUPP;
  8007ff:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800804:	eb d1                	jmp    8007d7 <write+0x53>

00800806 <seek>:

int
seek(int fdnum, off_t offset)
{
  800806:	55                   	push   %ebp
  800807:	89 e5                	mov    %esp,%ebp
  800809:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80080c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80080f:	50                   	push   %eax
  800810:	ff 75 08             	push   0x8(%ebp)
  800813:	e8 35 fc ff ff       	call   80044d <fd_lookup>
  800818:	83 c4 10             	add    $0x10,%esp
  80081b:	85 c0                	test   %eax,%eax
  80081d:	78 0e                	js     80082d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80081f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800822:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800825:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800828:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80082d:	c9                   	leave  
  80082e:	c3                   	ret    

0080082f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80082f:	55                   	push   %ebp
  800830:	89 e5                	mov    %esp,%ebp
  800832:	56                   	push   %esi
  800833:	53                   	push   %ebx
  800834:	83 ec 18             	sub    $0x18,%esp
  800837:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80083a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80083d:	50                   	push   %eax
  80083e:	53                   	push   %ebx
  80083f:	e8 09 fc ff ff       	call   80044d <fd_lookup>
  800844:	83 c4 10             	add    $0x10,%esp
  800847:	85 c0                	test   %eax,%eax
  800849:	78 34                	js     80087f <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80084b:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80084e:	83 ec 08             	sub    $0x8,%esp
  800851:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800854:	50                   	push   %eax
  800855:	ff 36                	push   (%esi)
  800857:	e8 41 fc ff ff       	call   80049d <dev_lookup>
  80085c:	83 c4 10             	add    $0x10,%esp
  80085f:	85 c0                	test   %eax,%eax
  800861:	78 1c                	js     80087f <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800863:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800867:	74 1d                	je     800886 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800869:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80086c:	8b 40 18             	mov    0x18(%eax),%eax
  80086f:	85 c0                	test   %eax,%eax
  800871:	74 34                	je     8008a7 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800873:	83 ec 08             	sub    $0x8,%esp
  800876:	ff 75 0c             	push   0xc(%ebp)
  800879:	56                   	push   %esi
  80087a:	ff d0                	call   *%eax
  80087c:	83 c4 10             	add    $0x10,%esp
}
  80087f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800882:	5b                   	pop    %ebx
  800883:	5e                   	pop    %esi
  800884:	5d                   	pop    %ebp
  800885:	c3                   	ret    
			thisenv->env_id, fdnum);
  800886:	a1 00 40 80 00       	mov    0x804000,%eax
  80088b:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80088e:	83 ec 04             	sub    $0x4,%esp
  800891:	53                   	push   %ebx
  800892:	50                   	push   %eax
  800893:	68 b8 22 80 00       	push   $0x8022b8
  800898:	e8 22 0d 00 00       	call   8015bf <cprintf>
		return -E_INVAL;
  80089d:	83 c4 10             	add    $0x10,%esp
  8008a0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008a5:	eb d8                	jmp    80087f <ftruncate+0x50>
		return -E_NOT_SUPP;
  8008a7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008ac:	eb d1                	jmp    80087f <ftruncate+0x50>

008008ae <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	56                   	push   %esi
  8008b2:	53                   	push   %ebx
  8008b3:	83 ec 18             	sub    $0x18,%esp
  8008b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008bc:	50                   	push   %eax
  8008bd:	ff 75 08             	push   0x8(%ebp)
  8008c0:	e8 88 fb ff ff       	call   80044d <fd_lookup>
  8008c5:	83 c4 10             	add    $0x10,%esp
  8008c8:	85 c0                	test   %eax,%eax
  8008ca:	78 49                	js     800915 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008cc:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8008cf:	83 ec 08             	sub    $0x8,%esp
  8008d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008d5:	50                   	push   %eax
  8008d6:	ff 36                	push   (%esi)
  8008d8:	e8 c0 fb ff ff       	call   80049d <dev_lookup>
  8008dd:	83 c4 10             	add    $0x10,%esp
  8008e0:	85 c0                	test   %eax,%eax
  8008e2:	78 31                	js     800915 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8008e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008eb:	74 2f                	je     80091c <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008ed:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008f0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008f7:	00 00 00 
	stat->st_isdir = 0;
  8008fa:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800901:	00 00 00 
	stat->st_dev = dev;
  800904:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80090a:	83 ec 08             	sub    $0x8,%esp
  80090d:	53                   	push   %ebx
  80090e:	56                   	push   %esi
  80090f:	ff 50 14             	call   *0x14(%eax)
  800912:	83 c4 10             	add    $0x10,%esp
}
  800915:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800918:	5b                   	pop    %ebx
  800919:	5e                   	pop    %esi
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    
		return -E_NOT_SUPP;
  80091c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800921:	eb f2                	jmp    800915 <fstat+0x67>

00800923 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	56                   	push   %esi
  800927:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800928:	83 ec 08             	sub    $0x8,%esp
  80092b:	6a 00                	push   $0x0
  80092d:	ff 75 08             	push   0x8(%ebp)
  800930:	e8 e4 01 00 00       	call   800b19 <open>
  800935:	89 c3                	mov    %eax,%ebx
  800937:	83 c4 10             	add    $0x10,%esp
  80093a:	85 c0                	test   %eax,%eax
  80093c:	78 1b                	js     800959 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80093e:	83 ec 08             	sub    $0x8,%esp
  800941:	ff 75 0c             	push   0xc(%ebp)
  800944:	50                   	push   %eax
  800945:	e8 64 ff ff ff       	call   8008ae <fstat>
  80094a:	89 c6                	mov    %eax,%esi
	close(fd);
  80094c:	89 1c 24             	mov    %ebx,(%esp)
  80094f:	e8 26 fc ff ff       	call   80057a <close>
	return r;
  800954:	83 c4 10             	add    $0x10,%esp
  800957:	89 f3                	mov    %esi,%ebx
}
  800959:	89 d8                	mov    %ebx,%eax
  80095b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80095e:	5b                   	pop    %ebx
  80095f:	5e                   	pop    %esi
  800960:	5d                   	pop    %ebp
  800961:	c3                   	ret    

00800962 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	56                   	push   %esi
  800966:	53                   	push   %ebx
  800967:	89 c6                	mov    %eax,%esi
  800969:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80096b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800972:	74 27                	je     80099b <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800974:	6a 07                	push   $0x7
  800976:	68 00 50 80 00       	push   $0x805000
  80097b:	56                   	push   %esi
  80097c:	ff 35 00 60 80 00    	push   0x806000
  800982:	e8 c2 15 00 00       	call   801f49 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800987:	83 c4 0c             	add    $0xc,%esp
  80098a:	6a 00                	push   $0x0
  80098c:	53                   	push   %ebx
  80098d:	6a 00                	push   $0x0
  80098f:	e8 45 15 00 00       	call   801ed9 <ipc_recv>
}
  800994:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800997:	5b                   	pop    %ebx
  800998:	5e                   	pop    %esi
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80099b:	83 ec 0c             	sub    $0xc,%esp
  80099e:	6a 01                	push   $0x1
  8009a0:	e8 f8 15 00 00       	call   801f9d <ipc_find_env>
  8009a5:	a3 00 60 80 00       	mov    %eax,0x806000
  8009aa:	83 c4 10             	add    $0x10,%esp
  8009ad:	eb c5                	jmp    800974 <fsipc+0x12>

008009af <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
  8009b2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009bb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cd:	b8 02 00 00 00       	mov    $0x2,%eax
  8009d2:	e8 8b ff ff ff       	call   800962 <fsipc>
}
  8009d7:	c9                   	leave  
  8009d8:	c3                   	ret    

008009d9 <devfile_flush>:
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009df:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ef:	b8 06 00 00 00       	mov    $0x6,%eax
  8009f4:	e8 69 ff ff ff       	call   800962 <fsipc>
}
  8009f9:	c9                   	leave  
  8009fa:	c3                   	ret    

008009fb <devfile_stat>:
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	53                   	push   %ebx
  8009ff:	83 ec 04             	sub    $0x4,%esp
  800a02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a05:	8b 45 08             	mov    0x8(%ebp),%eax
  800a08:	8b 40 0c             	mov    0xc(%eax),%eax
  800a0b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a10:	ba 00 00 00 00       	mov    $0x0,%edx
  800a15:	b8 05 00 00 00       	mov    $0x5,%eax
  800a1a:	e8 43 ff ff ff       	call   800962 <fsipc>
  800a1f:	85 c0                	test   %eax,%eax
  800a21:	78 2c                	js     800a4f <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a23:	83 ec 08             	sub    $0x8,%esp
  800a26:	68 00 50 80 00       	push   $0x805000
  800a2b:	53                   	push   %ebx
  800a2c:	e8 68 11 00 00       	call   801b99 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a31:	a1 80 50 80 00       	mov    0x805080,%eax
  800a36:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a3c:	a1 84 50 80 00       	mov    0x805084,%eax
  800a41:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a47:	83 c4 10             	add    $0x10,%esp
  800a4a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a52:	c9                   	leave  
  800a53:	c3                   	ret    

00800a54 <devfile_write>:
{
  800a54:	55                   	push   %ebp
  800a55:	89 e5                	mov    %esp,%ebp
  800a57:	83 ec 0c             	sub    $0xc,%esp
  800a5a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a5d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a62:	39 d0                	cmp    %edx,%eax
  800a64:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a67:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6a:	8b 52 0c             	mov    0xc(%edx),%edx
  800a6d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a73:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a78:	50                   	push   %eax
  800a79:	ff 75 0c             	push   0xc(%ebp)
  800a7c:	68 08 50 80 00       	push   $0x805008
  800a81:	e8 a9 12 00 00       	call   801d2f <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800a86:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8b:	b8 04 00 00 00       	mov    $0x4,%eax
  800a90:	e8 cd fe ff ff       	call   800962 <fsipc>
}
  800a95:	c9                   	leave  
  800a96:	c3                   	ret    

00800a97 <devfile_read>:
{
  800a97:	55                   	push   %ebp
  800a98:	89 e5                	mov    %esp,%ebp
  800a9a:	56                   	push   %esi
  800a9b:	53                   	push   %ebx
  800a9c:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa2:	8b 40 0c             	mov    0xc(%eax),%eax
  800aa5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800aaa:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ab0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab5:	b8 03 00 00 00       	mov    $0x3,%eax
  800aba:	e8 a3 fe ff ff       	call   800962 <fsipc>
  800abf:	89 c3                	mov    %eax,%ebx
  800ac1:	85 c0                	test   %eax,%eax
  800ac3:	78 1f                	js     800ae4 <devfile_read+0x4d>
	assert(r <= n);
  800ac5:	39 f0                	cmp    %esi,%eax
  800ac7:	77 24                	ja     800aed <devfile_read+0x56>
	assert(r <= PGSIZE);
  800ac9:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ace:	7f 33                	jg     800b03 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ad0:	83 ec 04             	sub    $0x4,%esp
  800ad3:	50                   	push   %eax
  800ad4:	68 00 50 80 00       	push   $0x805000
  800ad9:	ff 75 0c             	push   0xc(%ebp)
  800adc:	e8 4e 12 00 00       	call   801d2f <memmove>
	return r;
  800ae1:	83 c4 10             	add    $0x10,%esp
}
  800ae4:	89 d8                	mov    %ebx,%eax
  800ae6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5d                   	pop    %ebp
  800aec:	c3                   	ret    
	assert(r <= n);
  800aed:	68 28 23 80 00       	push   $0x802328
  800af2:	68 2f 23 80 00       	push   $0x80232f
  800af7:	6a 7c                	push   $0x7c
  800af9:	68 44 23 80 00       	push   $0x802344
  800afe:	e8 e1 09 00 00       	call   8014e4 <_panic>
	assert(r <= PGSIZE);
  800b03:	68 4f 23 80 00       	push   $0x80234f
  800b08:	68 2f 23 80 00       	push   $0x80232f
  800b0d:	6a 7d                	push   $0x7d
  800b0f:	68 44 23 80 00       	push   $0x802344
  800b14:	e8 cb 09 00 00       	call   8014e4 <_panic>

00800b19 <open>:
{
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	56                   	push   %esi
  800b1d:	53                   	push   %ebx
  800b1e:	83 ec 1c             	sub    $0x1c,%esp
  800b21:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b24:	56                   	push   %esi
  800b25:	e8 34 10 00 00       	call   801b5e <strlen>
  800b2a:	83 c4 10             	add    $0x10,%esp
  800b2d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b32:	7f 6c                	jg     800ba0 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800b34:	83 ec 0c             	sub    $0xc,%esp
  800b37:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b3a:	50                   	push   %eax
  800b3b:	e8 bd f8 ff ff       	call   8003fd <fd_alloc>
  800b40:	89 c3                	mov    %eax,%ebx
  800b42:	83 c4 10             	add    $0x10,%esp
  800b45:	85 c0                	test   %eax,%eax
  800b47:	78 3c                	js     800b85 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800b49:	83 ec 08             	sub    $0x8,%esp
  800b4c:	56                   	push   %esi
  800b4d:	68 00 50 80 00       	push   $0x805000
  800b52:	e8 42 10 00 00       	call   801b99 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5a:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b5f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b62:	b8 01 00 00 00       	mov    $0x1,%eax
  800b67:	e8 f6 fd ff ff       	call   800962 <fsipc>
  800b6c:	89 c3                	mov    %eax,%ebx
  800b6e:	83 c4 10             	add    $0x10,%esp
  800b71:	85 c0                	test   %eax,%eax
  800b73:	78 19                	js     800b8e <open+0x75>
	return fd2num(fd);
  800b75:	83 ec 0c             	sub    $0xc,%esp
  800b78:	ff 75 f4             	push   -0xc(%ebp)
  800b7b:	e8 56 f8 ff ff       	call   8003d6 <fd2num>
  800b80:	89 c3                	mov    %eax,%ebx
  800b82:	83 c4 10             	add    $0x10,%esp
}
  800b85:	89 d8                	mov    %ebx,%eax
  800b87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b8a:	5b                   	pop    %ebx
  800b8b:	5e                   	pop    %esi
  800b8c:	5d                   	pop    %ebp
  800b8d:	c3                   	ret    
		fd_close(fd, 0);
  800b8e:	83 ec 08             	sub    $0x8,%esp
  800b91:	6a 00                	push   $0x0
  800b93:	ff 75 f4             	push   -0xc(%ebp)
  800b96:	e8 58 f9 ff ff       	call   8004f3 <fd_close>
		return r;
  800b9b:	83 c4 10             	add    $0x10,%esp
  800b9e:	eb e5                	jmp    800b85 <open+0x6c>
		return -E_BAD_PATH;
  800ba0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800ba5:	eb de                	jmp    800b85 <open+0x6c>

00800ba7 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ba7:	55                   	push   %ebp
  800ba8:	89 e5                	mov    %esp,%ebp
  800baa:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bad:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb2:	b8 08 00 00 00       	mov    $0x8,%eax
  800bb7:	e8 a6 fd ff ff       	call   800962 <fsipc>
}
  800bbc:	c9                   	leave  
  800bbd:	c3                   	ret    

00800bbe <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bc4:	68 5b 23 80 00       	push   $0x80235b
  800bc9:	ff 75 0c             	push   0xc(%ebp)
  800bcc:	e8 c8 0f 00 00       	call   801b99 <strcpy>
	return 0;
}
  800bd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd6:	c9                   	leave  
  800bd7:	c3                   	ret    

00800bd8 <devsock_close>:
{
  800bd8:	55                   	push   %ebp
  800bd9:	89 e5                	mov    %esp,%ebp
  800bdb:	53                   	push   %ebx
  800bdc:	83 ec 10             	sub    $0x10,%esp
  800bdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800be2:	53                   	push   %ebx
  800be3:	e8 f4 13 00 00       	call   801fdc <pageref>
  800be8:	89 c2                	mov    %eax,%edx
  800bea:	83 c4 10             	add    $0x10,%esp
		return 0;
  800bed:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800bf2:	83 fa 01             	cmp    $0x1,%edx
  800bf5:	74 05                	je     800bfc <devsock_close+0x24>
}
  800bf7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800bfc:	83 ec 0c             	sub    $0xc,%esp
  800bff:	ff 73 0c             	push   0xc(%ebx)
  800c02:	e8 b7 02 00 00       	call   800ebe <nsipc_close>
  800c07:	83 c4 10             	add    $0x10,%esp
  800c0a:	eb eb                	jmp    800bf7 <devsock_close+0x1f>

00800c0c <devsock_write>:
{
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c12:	6a 00                	push   $0x0
  800c14:	ff 75 10             	push   0x10(%ebp)
  800c17:	ff 75 0c             	push   0xc(%ebp)
  800c1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1d:	ff 70 0c             	push   0xc(%eax)
  800c20:	e8 79 03 00 00       	call   800f9e <nsipc_send>
}
  800c25:	c9                   	leave  
  800c26:	c3                   	ret    

00800c27 <devsock_read>:
{
  800c27:	55                   	push   %ebp
  800c28:	89 e5                	mov    %esp,%ebp
  800c2a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c2d:	6a 00                	push   $0x0
  800c2f:	ff 75 10             	push   0x10(%ebp)
  800c32:	ff 75 0c             	push   0xc(%ebp)
  800c35:	8b 45 08             	mov    0x8(%ebp),%eax
  800c38:	ff 70 0c             	push   0xc(%eax)
  800c3b:	e8 ef 02 00 00       	call   800f2f <nsipc_recv>
}
  800c40:	c9                   	leave  
  800c41:	c3                   	ret    

00800c42 <fd2sockid>:
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c48:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c4b:	52                   	push   %edx
  800c4c:	50                   	push   %eax
  800c4d:	e8 fb f7 ff ff       	call   80044d <fd_lookup>
  800c52:	83 c4 10             	add    $0x10,%esp
  800c55:	85 c0                	test   %eax,%eax
  800c57:	78 10                	js     800c69 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800c59:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c5c:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c62:	39 08                	cmp    %ecx,(%eax)
  800c64:	75 05                	jne    800c6b <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c66:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c69:	c9                   	leave  
  800c6a:	c3                   	ret    
		return -E_NOT_SUPP;
  800c6b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c70:	eb f7                	jmp    800c69 <fd2sockid+0x27>

00800c72 <alloc_sockfd>:
{
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	56                   	push   %esi
  800c76:	53                   	push   %ebx
  800c77:	83 ec 1c             	sub    $0x1c,%esp
  800c7a:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c7f:	50                   	push   %eax
  800c80:	e8 78 f7 ff ff       	call   8003fd <fd_alloc>
  800c85:	89 c3                	mov    %eax,%ebx
  800c87:	83 c4 10             	add    $0x10,%esp
  800c8a:	85 c0                	test   %eax,%eax
  800c8c:	78 43                	js     800cd1 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c8e:	83 ec 04             	sub    $0x4,%esp
  800c91:	68 07 04 00 00       	push   $0x407
  800c96:	ff 75 f4             	push   -0xc(%ebp)
  800c99:	6a 00                	push   $0x0
  800c9b:	e8 e4 f4 ff ff       	call   800184 <sys_page_alloc>
  800ca0:	89 c3                	mov    %eax,%ebx
  800ca2:	83 c4 10             	add    $0x10,%esp
  800ca5:	85 c0                	test   %eax,%eax
  800ca7:	78 28                	js     800cd1 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800ca9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cac:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800cb2:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cbe:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cc1:	83 ec 0c             	sub    $0xc,%esp
  800cc4:	50                   	push   %eax
  800cc5:	e8 0c f7 ff ff       	call   8003d6 <fd2num>
  800cca:	89 c3                	mov    %eax,%ebx
  800ccc:	83 c4 10             	add    $0x10,%esp
  800ccf:	eb 0c                	jmp    800cdd <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800cd1:	83 ec 0c             	sub    $0xc,%esp
  800cd4:	56                   	push   %esi
  800cd5:	e8 e4 01 00 00       	call   800ebe <nsipc_close>
		return r;
  800cda:	83 c4 10             	add    $0x10,%esp
}
  800cdd:	89 d8                	mov    %ebx,%eax
  800cdf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5d                   	pop    %ebp
  800ce5:	c3                   	ret    

00800ce6 <accept>:
{
  800ce6:	55                   	push   %ebp
  800ce7:	89 e5                	mov    %esp,%ebp
  800ce9:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cec:	8b 45 08             	mov    0x8(%ebp),%eax
  800cef:	e8 4e ff ff ff       	call   800c42 <fd2sockid>
  800cf4:	85 c0                	test   %eax,%eax
  800cf6:	78 1b                	js     800d13 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cf8:	83 ec 04             	sub    $0x4,%esp
  800cfb:	ff 75 10             	push   0x10(%ebp)
  800cfe:	ff 75 0c             	push   0xc(%ebp)
  800d01:	50                   	push   %eax
  800d02:	e8 0e 01 00 00       	call   800e15 <nsipc_accept>
  800d07:	83 c4 10             	add    $0x10,%esp
  800d0a:	85 c0                	test   %eax,%eax
  800d0c:	78 05                	js     800d13 <accept+0x2d>
	return alloc_sockfd(r);
  800d0e:	e8 5f ff ff ff       	call   800c72 <alloc_sockfd>
}
  800d13:	c9                   	leave  
  800d14:	c3                   	ret    

00800d15 <bind>:
{
  800d15:	55                   	push   %ebp
  800d16:	89 e5                	mov    %esp,%ebp
  800d18:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1e:	e8 1f ff ff ff       	call   800c42 <fd2sockid>
  800d23:	85 c0                	test   %eax,%eax
  800d25:	78 12                	js     800d39 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  800d27:	83 ec 04             	sub    $0x4,%esp
  800d2a:	ff 75 10             	push   0x10(%ebp)
  800d2d:	ff 75 0c             	push   0xc(%ebp)
  800d30:	50                   	push   %eax
  800d31:	e8 31 01 00 00       	call   800e67 <nsipc_bind>
  800d36:	83 c4 10             	add    $0x10,%esp
}
  800d39:	c9                   	leave  
  800d3a:	c3                   	ret    

00800d3b <shutdown>:
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d41:	8b 45 08             	mov    0x8(%ebp),%eax
  800d44:	e8 f9 fe ff ff       	call   800c42 <fd2sockid>
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	78 0f                	js     800d5c <shutdown+0x21>
	return nsipc_shutdown(r, how);
  800d4d:	83 ec 08             	sub    $0x8,%esp
  800d50:	ff 75 0c             	push   0xc(%ebp)
  800d53:	50                   	push   %eax
  800d54:	e8 43 01 00 00       	call   800e9c <nsipc_shutdown>
  800d59:	83 c4 10             	add    $0x10,%esp
}
  800d5c:	c9                   	leave  
  800d5d:	c3                   	ret    

00800d5e <connect>:
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d64:	8b 45 08             	mov    0x8(%ebp),%eax
  800d67:	e8 d6 fe ff ff       	call   800c42 <fd2sockid>
  800d6c:	85 c0                	test   %eax,%eax
  800d6e:	78 12                	js     800d82 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  800d70:	83 ec 04             	sub    $0x4,%esp
  800d73:	ff 75 10             	push   0x10(%ebp)
  800d76:	ff 75 0c             	push   0xc(%ebp)
  800d79:	50                   	push   %eax
  800d7a:	e8 59 01 00 00       	call   800ed8 <nsipc_connect>
  800d7f:	83 c4 10             	add    $0x10,%esp
}
  800d82:	c9                   	leave  
  800d83:	c3                   	ret    

00800d84 <listen>:
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
  800d87:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8d:	e8 b0 fe ff ff       	call   800c42 <fd2sockid>
  800d92:	85 c0                	test   %eax,%eax
  800d94:	78 0f                	js     800da5 <listen+0x21>
	return nsipc_listen(r, backlog);
  800d96:	83 ec 08             	sub    $0x8,%esp
  800d99:	ff 75 0c             	push   0xc(%ebp)
  800d9c:	50                   	push   %eax
  800d9d:	e8 6b 01 00 00       	call   800f0d <nsipc_listen>
  800da2:	83 c4 10             	add    $0x10,%esp
}
  800da5:	c9                   	leave  
  800da6:	c3                   	ret    

00800da7 <socket>:

int
socket(int domain, int type, int protocol)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800dad:	ff 75 10             	push   0x10(%ebp)
  800db0:	ff 75 0c             	push   0xc(%ebp)
  800db3:	ff 75 08             	push   0x8(%ebp)
  800db6:	e8 41 02 00 00       	call   800ffc <nsipc_socket>
  800dbb:	83 c4 10             	add    $0x10,%esp
  800dbe:	85 c0                	test   %eax,%eax
  800dc0:	78 05                	js     800dc7 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800dc2:	e8 ab fe ff ff       	call   800c72 <alloc_sockfd>
}
  800dc7:	c9                   	leave  
  800dc8:	c3                   	ret    

00800dc9 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	53                   	push   %ebx
  800dcd:	83 ec 04             	sub    $0x4,%esp
  800dd0:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dd2:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  800dd9:	74 26                	je     800e01 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800ddb:	6a 07                	push   $0x7
  800ddd:	68 00 70 80 00       	push   $0x807000
  800de2:	53                   	push   %ebx
  800de3:	ff 35 00 80 80 00    	push   0x808000
  800de9:	e8 5b 11 00 00       	call   801f49 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dee:	83 c4 0c             	add    $0xc,%esp
  800df1:	6a 00                	push   $0x0
  800df3:	6a 00                	push   $0x0
  800df5:	6a 00                	push   $0x0
  800df7:	e8 dd 10 00 00       	call   801ed9 <ipc_recv>
}
  800dfc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dff:	c9                   	leave  
  800e00:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e01:	83 ec 0c             	sub    $0xc,%esp
  800e04:	6a 02                	push   $0x2
  800e06:	e8 92 11 00 00       	call   801f9d <ipc_find_env>
  800e0b:	a3 00 80 80 00       	mov    %eax,0x808000
  800e10:	83 c4 10             	add    $0x10,%esp
  800e13:	eb c6                	jmp    800ddb <nsipc+0x12>

00800e15 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e15:	55                   	push   %ebp
  800e16:	89 e5                	mov    %esp,%ebp
  800e18:	56                   	push   %esi
  800e19:	53                   	push   %ebx
  800e1a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e20:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e25:	8b 06                	mov    (%esi),%eax
  800e27:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e2c:	b8 01 00 00 00       	mov    $0x1,%eax
  800e31:	e8 93 ff ff ff       	call   800dc9 <nsipc>
  800e36:	89 c3                	mov    %eax,%ebx
  800e38:	85 c0                	test   %eax,%eax
  800e3a:	79 09                	jns    800e45 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800e3c:	89 d8                	mov    %ebx,%eax
  800e3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e45:	83 ec 04             	sub    $0x4,%esp
  800e48:	ff 35 10 70 80 00    	push   0x807010
  800e4e:	68 00 70 80 00       	push   $0x807000
  800e53:	ff 75 0c             	push   0xc(%ebp)
  800e56:	e8 d4 0e 00 00       	call   801d2f <memmove>
		*addrlen = ret->ret_addrlen;
  800e5b:	a1 10 70 80 00       	mov    0x807010,%eax
  800e60:	89 06                	mov    %eax,(%esi)
  800e62:	83 c4 10             	add    $0x10,%esp
	return r;
  800e65:	eb d5                	jmp    800e3c <nsipc_accept+0x27>

00800e67 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e67:	55                   	push   %ebp
  800e68:	89 e5                	mov    %esp,%ebp
  800e6a:	53                   	push   %ebx
  800e6b:	83 ec 08             	sub    $0x8,%esp
  800e6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e71:	8b 45 08             	mov    0x8(%ebp),%eax
  800e74:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e79:	53                   	push   %ebx
  800e7a:	ff 75 0c             	push   0xc(%ebp)
  800e7d:	68 04 70 80 00       	push   $0x807004
  800e82:	e8 a8 0e 00 00       	call   801d2f <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e87:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  800e8d:	b8 02 00 00 00       	mov    $0x2,%eax
  800e92:	e8 32 ff ff ff       	call   800dc9 <nsipc>
}
  800e97:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e9a:	c9                   	leave  
  800e9b:	c3                   	ret    

00800e9c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e9c:	55                   	push   %ebp
  800e9d:	89 e5                	mov    %esp,%ebp
  800e9f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800ea2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  800eaa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ead:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  800eb2:	b8 03 00 00 00       	mov    $0x3,%eax
  800eb7:	e8 0d ff ff ff       	call   800dc9 <nsipc>
}
  800ebc:	c9                   	leave  
  800ebd:	c3                   	ret    

00800ebe <nsipc_close>:

int
nsipc_close(int s)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec7:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  800ecc:	b8 04 00 00 00       	mov    $0x4,%eax
  800ed1:	e8 f3 fe ff ff       	call   800dc9 <nsipc>
}
  800ed6:	c9                   	leave  
  800ed7:	c3                   	ret    

00800ed8 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	53                   	push   %ebx
  800edc:	83 ec 08             	sub    $0x8,%esp
  800edf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ee2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee5:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800eea:	53                   	push   %ebx
  800eeb:	ff 75 0c             	push   0xc(%ebp)
  800eee:	68 04 70 80 00       	push   $0x807004
  800ef3:	e8 37 0e 00 00       	call   801d2f <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ef8:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  800efe:	b8 05 00 00 00       	mov    $0x5,%eax
  800f03:	e8 c1 fe ff ff       	call   800dc9 <nsipc>
}
  800f08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f0b:	c9                   	leave  
  800f0c:	c3                   	ret    

00800f0d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f13:	8b 45 08             	mov    0x8(%ebp),%eax
  800f16:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  800f1b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1e:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  800f23:	b8 06 00 00 00       	mov    $0x6,%eax
  800f28:	e8 9c fe ff ff       	call   800dc9 <nsipc>
}
  800f2d:	c9                   	leave  
  800f2e:	c3                   	ret    

00800f2f <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	56                   	push   %esi
  800f33:	53                   	push   %ebx
  800f34:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f37:	8b 45 08             	mov    0x8(%ebp),%eax
  800f3a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  800f3f:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  800f45:	8b 45 14             	mov    0x14(%ebp),%eax
  800f48:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f4d:	b8 07 00 00 00       	mov    $0x7,%eax
  800f52:	e8 72 fe ff ff       	call   800dc9 <nsipc>
  800f57:	89 c3                	mov    %eax,%ebx
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	78 22                	js     800f7f <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  800f5d:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f62:	39 c6                	cmp    %eax,%esi
  800f64:	0f 4e c6             	cmovle %esi,%eax
  800f67:	39 c3                	cmp    %eax,%ebx
  800f69:	7f 1d                	jg     800f88 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f6b:	83 ec 04             	sub    $0x4,%esp
  800f6e:	53                   	push   %ebx
  800f6f:	68 00 70 80 00       	push   $0x807000
  800f74:	ff 75 0c             	push   0xc(%ebp)
  800f77:	e8 b3 0d 00 00       	call   801d2f <memmove>
  800f7c:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f7f:	89 d8                	mov    %ebx,%eax
  800f81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f84:	5b                   	pop    %ebx
  800f85:	5e                   	pop    %esi
  800f86:	5d                   	pop    %ebp
  800f87:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f88:	68 67 23 80 00       	push   $0x802367
  800f8d:	68 2f 23 80 00       	push   $0x80232f
  800f92:	6a 62                	push   $0x62
  800f94:	68 7c 23 80 00       	push   $0x80237c
  800f99:	e8 46 05 00 00       	call   8014e4 <_panic>

00800f9e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	53                   	push   %ebx
  800fa2:	83 ec 04             	sub    $0x4,%esp
  800fa5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fa8:	8b 45 08             	mov    0x8(%ebp),%eax
  800fab:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  800fb0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fb6:	7f 2e                	jg     800fe6 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fb8:	83 ec 04             	sub    $0x4,%esp
  800fbb:	53                   	push   %ebx
  800fbc:	ff 75 0c             	push   0xc(%ebp)
  800fbf:	68 0c 70 80 00       	push   $0x80700c
  800fc4:	e8 66 0d 00 00       	call   801d2f <memmove>
	nsipcbuf.send.req_size = size;
  800fc9:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  800fcf:	8b 45 14             	mov    0x14(%ebp),%eax
  800fd2:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  800fd7:	b8 08 00 00 00       	mov    $0x8,%eax
  800fdc:	e8 e8 fd ff ff       	call   800dc9 <nsipc>
}
  800fe1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe4:	c9                   	leave  
  800fe5:	c3                   	ret    
	assert(size < 1600);
  800fe6:	68 88 23 80 00       	push   $0x802388
  800feb:	68 2f 23 80 00       	push   $0x80232f
  800ff0:	6a 6d                	push   $0x6d
  800ff2:	68 7c 23 80 00       	push   $0x80237c
  800ff7:	e8 e8 04 00 00       	call   8014e4 <_panic>

00800ffc <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801002:	8b 45 08             	mov    0x8(%ebp),%eax
  801005:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80100a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80100d:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801012:	8b 45 10             	mov    0x10(%ebp),%eax
  801015:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80101a:	b8 09 00 00 00       	mov    $0x9,%eax
  80101f:	e8 a5 fd ff ff       	call   800dc9 <nsipc>
}
  801024:	c9                   	leave  
  801025:	c3                   	ret    

00801026 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	56                   	push   %esi
  80102a:	53                   	push   %ebx
  80102b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80102e:	83 ec 0c             	sub    $0xc,%esp
  801031:	ff 75 08             	push   0x8(%ebp)
  801034:	e8 ad f3 ff ff       	call   8003e6 <fd2data>
  801039:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80103b:	83 c4 08             	add    $0x8,%esp
  80103e:	68 94 23 80 00       	push   $0x802394
  801043:	53                   	push   %ebx
  801044:	e8 50 0b 00 00       	call   801b99 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801049:	8b 46 04             	mov    0x4(%esi),%eax
  80104c:	2b 06                	sub    (%esi),%eax
  80104e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801054:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80105b:	00 00 00 
	stat->st_dev = &devpipe;
  80105e:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801065:	30 80 00 
	return 0;
}
  801068:	b8 00 00 00 00       	mov    $0x0,%eax
  80106d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801070:	5b                   	pop    %ebx
  801071:	5e                   	pop    %esi
  801072:	5d                   	pop    %ebp
  801073:	c3                   	ret    

00801074 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	53                   	push   %ebx
  801078:	83 ec 0c             	sub    $0xc,%esp
  80107b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80107e:	53                   	push   %ebx
  80107f:	6a 00                	push   $0x0
  801081:	e8 83 f1 ff ff       	call   800209 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801086:	89 1c 24             	mov    %ebx,(%esp)
  801089:	e8 58 f3 ff ff       	call   8003e6 <fd2data>
  80108e:	83 c4 08             	add    $0x8,%esp
  801091:	50                   	push   %eax
  801092:	6a 00                	push   $0x0
  801094:	e8 70 f1 ff ff       	call   800209 <sys_page_unmap>
}
  801099:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80109c:	c9                   	leave  
  80109d:	c3                   	ret    

0080109e <_pipeisclosed>:
{
  80109e:	55                   	push   %ebp
  80109f:	89 e5                	mov    %esp,%ebp
  8010a1:	57                   	push   %edi
  8010a2:	56                   	push   %esi
  8010a3:	53                   	push   %ebx
  8010a4:	83 ec 1c             	sub    $0x1c,%esp
  8010a7:	89 c7                	mov    %eax,%edi
  8010a9:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8010ab:	a1 00 40 80 00       	mov    0x804000,%eax
  8010b0:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8010b3:	83 ec 0c             	sub    $0xc,%esp
  8010b6:	57                   	push   %edi
  8010b7:	e8 20 0f 00 00       	call   801fdc <pageref>
  8010bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010bf:	89 34 24             	mov    %esi,(%esp)
  8010c2:	e8 15 0f 00 00       	call   801fdc <pageref>
		nn = thisenv->env_runs;
  8010c7:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8010cd:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  8010d0:	83 c4 10             	add    $0x10,%esp
  8010d3:	39 cb                	cmp    %ecx,%ebx
  8010d5:	74 1b                	je     8010f2 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010d7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010da:	75 cf                	jne    8010ab <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010dc:	8b 42 68             	mov    0x68(%edx),%eax
  8010df:	6a 01                	push   $0x1
  8010e1:	50                   	push   %eax
  8010e2:	53                   	push   %ebx
  8010e3:	68 9b 23 80 00       	push   $0x80239b
  8010e8:	e8 d2 04 00 00       	call   8015bf <cprintf>
  8010ed:	83 c4 10             	add    $0x10,%esp
  8010f0:	eb b9                	jmp    8010ab <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010f2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010f5:	0f 94 c0             	sete   %al
  8010f8:	0f b6 c0             	movzbl %al,%eax
}
  8010fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fe:	5b                   	pop    %ebx
  8010ff:	5e                   	pop    %esi
  801100:	5f                   	pop    %edi
  801101:	5d                   	pop    %ebp
  801102:	c3                   	ret    

00801103 <devpipe_write>:
{
  801103:	55                   	push   %ebp
  801104:	89 e5                	mov    %esp,%ebp
  801106:	57                   	push   %edi
  801107:	56                   	push   %esi
  801108:	53                   	push   %ebx
  801109:	83 ec 28             	sub    $0x28,%esp
  80110c:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80110f:	56                   	push   %esi
  801110:	e8 d1 f2 ff ff       	call   8003e6 <fd2data>
  801115:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801117:	83 c4 10             	add    $0x10,%esp
  80111a:	bf 00 00 00 00       	mov    $0x0,%edi
  80111f:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801122:	75 09                	jne    80112d <devpipe_write+0x2a>
	return i;
  801124:	89 f8                	mov    %edi,%eax
  801126:	eb 23                	jmp    80114b <devpipe_write+0x48>
			sys_yield();
  801128:	e8 38 f0 ff ff       	call   800165 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80112d:	8b 43 04             	mov    0x4(%ebx),%eax
  801130:	8b 0b                	mov    (%ebx),%ecx
  801132:	8d 51 20             	lea    0x20(%ecx),%edx
  801135:	39 d0                	cmp    %edx,%eax
  801137:	72 1a                	jb     801153 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801139:	89 da                	mov    %ebx,%edx
  80113b:	89 f0                	mov    %esi,%eax
  80113d:	e8 5c ff ff ff       	call   80109e <_pipeisclosed>
  801142:	85 c0                	test   %eax,%eax
  801144:	74 e2                	je     801128 <devpipe_write+0x25>
				return 0;
  801146:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80114b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114e:	5b                   	pop    %ebx
  80114f:	5e                   	pop    %esi
  801150:	5f                   	pop    %edi
  801151:	5d                   	pop    %ebp
  801152:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801153:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801156:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80115a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80115d:	89 c2                	mov    %eax,%edx
  80115f:	c1 fa 1f             	sar    $0x1f,%edx
  801162:	89 d1                	mov    %edx,%ecx
  801164:	c1 e9 1b             	shr    $0x1b,%ecx
  801167:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80116a:	83 e2 1f             	and    $0x1f,%edx
  80116d:	29 ca                	sub    %ecx,%edx
  80116f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801173:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801177:	83 c0 01             	add    $0x1,%eax
  80117a:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80117d:	83 c7 01             	add    $0x1,%edi
  801180:	eb 9d                	jmp    80111f <devpipe_write+0x1c>

00801182 <devpipe_read>:
{
  801182:	55                   	push   %ebp
  801183:	89 e5                	mov    %esp,%ebp
  801185:	57                   	push   %edi
  801186:	56                   	push   %esi
  801187:	53                   	push   %ebx
  801188:	83 ec 18             	sub    $0x18,%esp
  80118b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80118e:	57                   	push   %edi
  80118f:	e8 52 f2 ff ff       	call   8003e6 <fd2data>
  801194:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801196:	83 c4 10             	add    $0x10,%esp
  801199:	be 00 00 00 00       	mov    $0x0,%esi
  80119e:	3b 75 10             	cmp    0x10(%ebp),%esi
  8011a1:	75 13                	jne    8011b6 <devpipe_read+0x34>
	return i;
  8011a3:	89 f0                	mov    %esi,%eax
  8011a5:	eb 02                	jmp    8011a9 <devpipe_read+0x27>
				return i;
  8011a7:	89 f0                	mov    %esi,%eax
}
  8011a9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ac:	5b                   	pop    %ebx
  8011ad:	5e                   	pop    %esi
  8011ae:	5f                   	pop    %edi
  8011af:	5d                   	pop    %ebp
  8011b0:	c3                   	ret    
			sys_yield();
  8011b1:	e8 af ef ff ff       	call   800165 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8011b6:	8b 03                	mov    (%ebx),%eax
  8011b8:	3b 43 04             	cmp    0x4(%ebx),%eax
  8011bb:	75 18                	jne    8011d5 <devpipe_read+0x53>
			if (i > 0)
  8011bd:	85 f6                	test   %esi,%esi
  8011bf:	75 e6                	jne    8011a7 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8011c1:	89 da                	mov    %ebx,%edx
  8011c3:	89 f8                	mov    %edi,%eax
  8011c5:	e8 d4 fe ff ff       	call   80109e <_pipeisclosed>
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	74 e3                	je     8011b1 <devpipe_read+0x2f>
				return 0;
  8011ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d3:	eb d4                	jmp    8011a9 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011d5:	99                   	cltd   
  8011d6:	c1 ea 1b             	shr    $0x1b,%edx
  8011d9:	01 d0                	add    %edx,%eax
  8011db:	83 e0 1f             	and    $0x1f,%eax
  8011de:	29 d0                	sub    %edx,%eax
  8011e0:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e8:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011eb:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011ee:	83 c6 01             	add    $0x1,%esi
  8011f1:	eb ab                	jmp    80119e <devpipe_read+0x1c>

008011f3 <pipe>:
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	56                   	push   %esi
  8011f7:	53                   	push   %ebx
  8011f8:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fe:	50                   	push   %eax
  8011ff:	e8 f9 f1 ff ff       	call   8003fd <fd_alloc>
  801204:	89 c3                	mov    %eax,%ebx
  801206:	83 c4 10             	add    $0x10,%esp
  801209:	85 c0                	test   %eax,%eax
  80120b:	0f 88 23 01 00 00    	js     801334 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801211:	83 ec 04             	sub    $0x4,%esp
  801214:	68 07 04 00 00       	push   $0x407
  801219:	ff 75 f4             	push   -0xc(%ebp)
  80121c:	6a 00                	push   $0x0
  80121e:	e8 61 ef ff ff       	call   800184 <sys_page_alloc>
  801223:	89 c3                	mov    %eax,%ebx
  801225:	83 c4 10             	add    $0x10,%esp
  801228:	85 c0                	test   %eax,%eax
  80122a:	0f 88 04 01 00 00    	js     801334 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801230:	83 ec 0c             	sub    $0xc,%esp
  801233:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801236:	50                   	push   %eax
  801237:	e8 c1 f1 ff ff       	call   8003fd <fd_alloc>
  80123c:	89 c3                	mov    %eax,%ebx
  80123e:	83 c4 10             	add    $0x10,%esp
  801241:	85 c0                	test   %eax,%eax
  801243:	0f 88 db 00 00 00    	js     801324 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801249:	83 ec 04             	sub    $0x4,%esp
  80124c:	68 07 04 00 00       	push   $0x407
  801251:	ff 75 f0             	push   -0x10(%ebp)
  801254:	6a 00                	push   $0x0
  801256:	e8 29 ef ff ff       	call   800184 <sys_page_alloc>
  80125b:	89 c3                	mov    %eax,%ebx
  80125d:	83 c4 10             	add    $0x10,%esp
  801260:	85 c0                	test   %eax,%eax
  801262:	0f 88 bc 00 00 00    	js     801324 <pipe+0x131>
	va = fd2data(fd0);
  801268:	83 ec 0c             	sub    $0xc,%esp
  80126b:	ff 75 f4             	push   -0xc(%ebp)
  80126e:	e8 73 f1 ff ff       	call   8003e6 <fd2data>
  801273:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801275:	83 c4 0c             	add    $0xc,%esp
  801278:	68 07 04 00 00       	push   $0x407
  80127d:	50                   	push   %eax
  80127e:	6a 00                	push   $0x0
  801280:	e8 ff ee ff ff       	call   800184 <sys_page_alloc>
  801285:	89 c3                	mov    %eax,%ebx
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	85 c0                	test   %eax,%eax
  80128c:	0f 88 82 00 00 00    	js     801314 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801292:	83 ec 0c             	sub    $0xc,%esp
  801295:	ff 75 f0             	push   -0x10(%ebp)
  801298:	e8 49 f1 ff ff       	call   8003e6 <fd2data>
  80129d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012a4:	50                   	push   %eax
  8012a5:	6a 00                	push   $0x0
  8012a7:	56                   	push   %esi
  8012a8:	6a 00                	push   $0x0
  8012aa:	e8 18 ef ff ff       	call   8001c7 <sys_page_map>
  8012af:	89 c3                	mov    %eax,%ebx
  8012b1:	83 c4 20             	add    $0x20,%esp
  8012b4:	85 c0                	test   %eax,%eax
  8012b6:	78 4e                	js     801306 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8012b8:	a1 3c 30 80 00       	mov    0x80303c,%eax
  8012bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c0:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8012c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c5:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8012cc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012cf:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012db:	83 ec 0c             	sub    $0xc,%esp
  8012de:	ff 75 f4             	push   -0xc(%ebp)
  8012e1:	e8 f0 f0 ff ff       	call   8003d6 <fd2num>
  8012e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012eb:	83 c4 04             	add    $0x4,%esp
  8012ee:	ff 75 f0             	push   -0x10(%ebp)
  8012f1:	e8 e0 f0 ff ff       	call   8003d6 <fd2num>
  8012f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012fc:	83 c4 10             	add    $0x10,%esp
  8012ff:	bb 00 00 00 00       	mov    $0x0,%ebx
  801304:	eb 2e                	jmp    801334 <pipe+0x141>
	sys_page_unmap(0, va);
  801306:	83 ec 08             	sub    $0x8,%esp
  801309:	56                   	push   %esi
  80130a:	6a 00                	push   $0x0
  80130c:	e8 f8 ee ff ff       	call   800209 <sys_page_unmap>
  801311:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801314:	83 ec 08             	sub    $0x8,%esp
  801317:	ff 75 f0             	push   -0x10(%ebp)
  80131a:	6a 00                	push   $0x0
  80131c:	e8 e8 ee ff ff       	call   800209 <sys_page_unmap>
  801321:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801324:	83 ec 08             	sub    $0x8,%esp
  801327:	ff 75 f4             	push   -0xc(%ebp)
  80132a:	6a 00                	push   $0x0
  80132c:	e8 d8 ee ff ff       	call   800209 <sys_page_unmap>
  801331:	83 c4 10             	add    $0x10,%esp
}
  801334:	89 d8                	mov    %ebx,%eax
  801336:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801339:	5b                   	pop    %ebx
  80133a:	5e                   	pop    %esi
  80133b:	5d                   	pop    %ebp
  80133c:	c3                   	ret    

0080133d <pipeisclosed>:
{
  80133d:	55                   	push   %ebp
  80133e:	89 e5                	mov    %esp,%ebp
  801340:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801343:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801346:	50                   	push   %eax
  801347:	ff 75 08             	push   0x8(%ebp)
  80134a:	e8 fe f0 ff ff       	call   80044d <fd_lookup>
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	85 c0                	test   %eax,%eax
  801354:	78 18                	js     80136e <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801356:	83 ec 0c             	sub    $0xc,%esp
  801359:	ff 75 f4             	push   -0xc(%ebp)
  80135c:	e8 85 f0 ff ff       	call   8003e6 <fd2data>
  801361:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801363:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801366:	e8 33 fd ff ff       	call   80109e <_pipeisclosed>
  80136b:	83 c4 10             	add    $0x10,%esp
}
  80136e:	c9                   	leave  
  80136f:	c3                   	ret    

00801370 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801370:	b8 00 00 00 00       	mov    $0x0,%eax
  801375:	c3                   	ret    

00801376 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801376:	55                   	push   %ebp
  801377:	89 e5                	mov    %esp,%ebp
  801379:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80137c:	68 b3 23 80 00       	push   $0x8023b3
  801381:	ff 75 0c             	push   0xc(%ebp)
  801384:	e8 10 08 00 00       	call   801b99 <strcpy>
	return 0;
}
  801389:	b8 00 00 00 00       	mov    $0x0,%eax
  80138e:	c9                   	leave  
  80138f:	c3                   	ret    

00801390 <devcons_write>:
{
  801390:	55                   	push   %ebp
  801391:	89 e5                	mov    %esp,%ebp
  801393:	57                   	push   %edi
  801394:	56                   	push   %esi
  801395:	53                   	push   %ebx
  801396:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80139c:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8013a1:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8013a7:	eb 2e                	jmp    8013d7 <devcons_write+0x47>
		m = n - tot;
  8013a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013ac:	29 f3                	sub    %esi,%ebx
  8013ae:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8013b3:	39 c3                	cmp    %eax,%ebx
  8013b5:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8013b8:	83 ec 04             	sub    $0x4,%esp
  8013bb:	53                   	push   %ebx
  8013bc:	89 f0                	mov    %esi,%eax
  8013be:	03 45 0c             	add    0xc(%ebp),%eax
  8013c1:	50                   	push   %eax
  8013c2:	57                   	push   %edi
  8013c3:	e8 67 09 00 00       	call   801d2f <memmove>
		sys_cputs(buf, m);
  8013c8:	83 c4 08             	add    $0x8,%esp
  8013cb:	53                   	push   %ebx
  8013cc:	57                   	push   %edi
  8013cd:	e8 f6 ec ff ff       	call   8000c8 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013d2:	01 de                	add    %ebx,%esi
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013da:	72 cd                	jb     8013a9 <devcons_write+0x19>
}
  8013dc:	89 f0                	mov    %esi,%eax
  8013de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013e1:	5b                   	pop    %ebx
  8013e2:	5e                   	pop    %esi
  8013e3:	5f                   	pop    %edi
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    

008013e6 <devcons_read>:
{
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	83 ec 08             	sub    $0x8,%esp
  8013ec:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8013f1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013f5:	75 07                	jne    8013fe <devcons_read+0x18>
  8013f7:	eb 1f                	jmp    801418 <devcons_read+0x32>
		sys_yield();
  8013f9:	e8 67 ed ff ff       	call   800165 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8013fe:	e8 e3 ec ff ff       	call   8000e6 <sys_cgetc>
  801403:	85 c0                	test   %eax,%eax
  801405:	74 f2                	je     8013f9 <devcons_read+0x13>
	if (c < 0)
  801407:	78 0f                	js     801418 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801409:	83 f8 04             	cmp    $0x4,%eax
  80140c:	74 0c                	je     80141a <devcons_read+0x34>
	*(char*)vbuf = c;
  80140e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801411:	88 02                	mov    %al,(%edx)
	return 1;
  801413:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801418:	c9                   	leave  
  801419:	c3                   	ret    
		return 0;
  80141a:	b8 00 00 00 00       	mov    $0x0,%eax
  80141f:	eb f7                	jmp    801418 <devcons_read+0x32>

00801421 <cputchar>:
{
  801421:	55                   	push   %ebp
  801422:	89 e5                	mov    %esp,%ebp
  801424:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801427:	8b 45 08             	mov    0x8(%ebp),%eax
  80142a:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80142d:	6a 01                	push   $0x1
  80142f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801432:	50                   	push   %eax
  801433:	e8 90 ec ff ff       	call   8000c8 <sys_cputs>
}
  801438:	83 c4 10             	add    $0x10,%esp
  80143b:	c9                   	leave  
  80143c:	c3                   	ret    

0080143d <getchar>:
{
  80143d:	55                   	push   %ebp
  80143e:	89 e5                	mov    %esp,%ebp
  801440:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801443:	6a 01                	push   $0x1
  801445:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801448:	50                   	push   %eax
  801449:	6a 00                	push   $0x0
  80144b:	e8 66 f2 ff ff       	call   8006b6 <read>
	if (r < 0)
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	85 c0                	test   %eax,%eax
  801455:	78 06                	js     80145d <getchar+0x20>
	if (r < 1)
  801457:	74 06                	je     80145f <getchar+0x22>
	return c;
  801459:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80145d:	c9                   	leave  
  80145e:	c3                   	ret    
		return -E_EOF;
  80145f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801464:	eb f7                	jmp    80145d <getchar+0x20>

00801466 <iscons>:
{
  801466:	55                   	push   %ebp
  801467:	89 e5                	mov    %esp,%ebp
  801469:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80146c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146f:	50                   	push   %eax
  801470:	ff 75 08             	push   0x8(%ebp)
  801473:	e8 d5 ef ff ff       	call   80044d <fd_lookup>
  801478:	83 c4 10             	add    $0x10,%esp
  80147b:	85 c0                	test   %eax,%eax
  80147d:	78 11                	js     801490 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80147f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801482:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801488:	39 10                	cmp    %edx,(%eax)
  80148a:	0f 94 c0             	sete   %al
  80148d:	0f b6 c0             	movzbl %al,%eax
}
  801490:	c9                   	leave  
  801491:	c3                   	ret    

00801492 <opencons>:
{
  801492:	55                   	push   %ebp
  801493:	89 e5                	mov    %esp,%ebp
  801495:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801498:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80149b:	50                   	push   %eax
  80149c:	e8 5c ef ff ff       	call   8003fd <fd_alloc>
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 3a                	js     8014e2 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014a8:	83 ec 04             	sub    $0x4,%esp
  8014ab:	68 07 04 00 00       	push   $0x407
  8014b0:	ff 75 f4             	push   -0xc(%ebp)
  8014b3:	6a 00                	push   $0x0
  8014b5:	e8 ca ec ff ff       	call   800184 <sys_page_alloc>
  8014ba:	83 c4 10             	add    $0x10,%esp
  8014bd:	85 c0                	test   %eax,%eax
  8014bf:	78 21                	js     8014e2 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8014c1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014ca:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014d6:	83 ec 0c             	sub    $0xc,%esp
  8014d9:	50                   	push   %eax
  8014da:	e8 f7 ee ff ff       	call   8003d6 <fd2num>
  8014df:	83 c4 10             	add    $0x10,%esp
}
  8014e2:	c9                   	leave  
  8014e3:	c3                   	ret    

008014e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	56                   	push   %esi
  8014e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014ec:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014f2:	e8 4f ec ff ff       	call   800146 <sys_getenvid>
  8014f7:	83 ec 0c             	sub    $0xc,%esp
  8014fa:	ff 75 0c             	push   0xc(%ebp)
  8014fd:	ff 75 08             	push   0x8(%ebp)
  801500:	56                   	push   %esi
  801501:	50                   	push   %eax
  801502:	68 c0 23 80 00       	push   $0x8023c0
  801507:	e8 b3 00 00 00       	call   8015bf <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80150c:	83 c4 18             	add    $0x18,%esp
  80150f:	53                   	push   %ebx
  801510:	ff 75 10             	push   0x10(%ebp)
  801513:	e8 56 00 00 00       	call   80156e <vcprintf>
	cprintf("\n");
  801518:	c7 04 24 ac 23 80 00 	movl   $0x8023ac,(%esp)
  80151f:	e8 9b 00 00 00       	call   8015bf <cprintf>
  801524:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801527:	cc                   	int3   
  801528:	eb fd                	jmp    801527 <_panic+0x43>

0080152a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	53                   	push   %ebx
  80152e:	83 ec 04             	sub    $0x4,%esp
  801531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801534:	8b 13                	mov    (%ebx),%edx
  801536:	8d 42 01             	lea    0x1(%edx),%eax
  801539:	89 03                	mov    %eax,(%ebx)
  80153b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80153e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801542:	3d ff 00 00 00       	cmp    $0xff,%eax
  801547:	74 09                	je     801552 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801549:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80154d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801550:	c9                   	leave  
  801551:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801552:	83 ec 08             	sub    $0x8,%esp
  801555:	68 ff 00 00 00       	push   $0xff
  80155a:	8d 43 08             	lea    0x8(%ebx),%eax
  80155d:	50                   	push   %eax
  80155e:	e8 65 eb ff ff       	call   8000c8 <sys_cputs>
		b->idx = 0;
  801563:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801569:	83 c4 10             	add    $0x10,%esp
  80156c:	eb db                	jmp    801549 <putch+0x1f>

0080156e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80156e:	55                   	push   %ebp
  80156f:	89 e5                	mov    %esp,%ebp
  801571:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801577:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80157e:	00 00 00 
	b.cnt = 0;
  801581:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801588:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80158b:	ff 75 0c             	push   0xc(%ebp)
  80158e:	ff 75 08             	push   0x8(%ebp)
  801591:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801597:	50                   	push   %eax
  801598:	68 2a 15 80 00       	push   $0x80152a
  80159d:	e8 14 01 00 00       	call   8016b6 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015a2:	83 c4 08             	add    $0x8,%esp
  8015a5:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8015ab:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015b1:	50                   	push   %eax
  8015b2:	e8 11 eb ff ff       	call   8000c8 <sys_cputs>

	return b.cnt;
}
  8015b7:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015bd:	c9                   	leave  
  8015be:	c3                   	ret    

008015bf <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015c5:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015c8:	50                   	push   %eax
  8015c9:	ff 75 08             	push   0x8(%ebp)
  8015cc:	e8 9d ff ff ff       	call   80156e <vcprintf>
	va_end(ap);

	return cnt;
}
  8015d1:	c9                   	leave  
  8015d2:	c3                   	ret    

008015d3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015d3:	55                   	push   %ebp
  8015d4:	89 e5                	mov    %esp,%ebp
  8015d6:	57                   	push   %edi
  8015d7:	56                   	push   %esi
  8015d8:	53                   	push   %ebx
  8015d9:	83 ec 1c             	sub    $0x1c,%esp
  8015dc:	89 c7                	mov    %eax,%edi
  8015de:	89 d6                	mov    %edx,%esi
  8015e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e6:	89 d1                	mov    %edx,%ecx
  8015e8:	89 c2                	mov    %eax,%edx
  8015ea:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015ed:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8015f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8015f3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015f9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801600:	39 c2                	cmp    %eax,%edx
  801602:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801605:	72 3e                	jb     801645 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801607:	83 ec 0c             	sub    $0xc,%esp
  80160a:	ff 75 18             	push   0x18(%ebp)
  80160d:	83 eb 01             	sub    $0x1,%ebx
  801610:	53                   	push   %ebx
  801611:	50                   	push   %eax
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	ff 75 e4             	push   -0x1c(%ebp)
  801618:	ff 75 e0             	push   -0x20(%ebp)
  80161b:	ff 75 dc             	push   -0x24(%ebp)
  80161e:	ff 75 d8             	push   -0x28(%ebp)
  801621:	e8 fa 09 00 00       	call   802020 <__udivdi3>
  801626:	83 c4 18             	add    $0x18,%esp
  801629:	52                   	push   %edx
  80162a:	50                   	push   %eax
  80162b:	89 f2                	mov    %esi,%edx
  80162d:	89 f8                	mov    %edi,%eax
  80162f:	e8 9f ff ff ff       	call   8015d3 <printnum>
  801634:	83 c4 20             	add    $0x20,%esp
  801637:	eb 13                	jmp    80164c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801639:	83 ec 08             	sub    $0x8,%esp
  80163c:	56                   	push   %esi
  80163d:	ff 75 18             	push   0x18(%ebp)
  801640:	ff d7                	call   *%edi
  801642:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801645:	83 eb 01             	sub    $0x1,%ebx
  801648:	85 db                	test   %ebx,%ebx
  80164a:	7f ed                	jg     801639 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80164c:	83 ec 08             	sub    $0x8,%esp
  80164f:	56                   	push   %esi
  801650:	83 ec 04             	sub    $0x4,%esp
  801653:	ff 75 e4             	push   -0x1c(%ebp)
  801656:	ff 75 e0             	push   -0x20(%ebp)
  801659:	ff 75 dc             	push   -0x24(%ebp)
  80165c:	ff 75 d8             	push   -0x28(%ebp)
  80165f:	e8 dc 0a 00 00       	call   802140 <__umoddi3>
  801664:	83 c4 14             	add    $0x14,%esp
  801667:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  80166e:	50                   	push   %eax
  80166f:	ff d7                	call   *%edi
}
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801677:	5b                   	pop    %ebx
  801678:	5e                   	pop    %esi
  801679:	5f                   	pop    %edi
  80167a:	5d                   	pop    %ebp
  80167b:	c3                   	ret    

0080167c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801682:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801686:	8b 10                	mov    (%eax),%edx
  801688:	3b 50 04             	cmp    0x4(%eax),%edx
  80168b:	73 0a                	jae    801697 <sprintputch+0x1b>
		*b->buf++ = ch;
  80168d:	8d 4a 01             	lea    0x1(%edx),%ecx
  801690:	89 08                	mov    %ecx,(%eax)
  801692:	8b 45 08             	mov    0x8(%ebp),%eax
  801695:	88 02                	mov    %al,(%edx)
}
  801697:	5d                   	pop    %ebp
  801698:	c3                   	ret    

00801699 <printfmt>:
{
  801699:	55                   	push   %ebp
  80169a:	89 e5                	mov    %esp,%ebp
  80169c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80169f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016a2:	50                   	push   %eax
  8016a3:	ff 75 10             	push   0x10(%ebp)
  8016a6:	ff 75 0c             	push   0xc(%ebp)
  8016a9:	ff 75 08             	push   0x8(%ebp)
  8016ac:	e8 05 00 00 00       	call   8016b6 <vprintfmt>
}
  8016b1:	83 c4 10             	add    $0x10,%esp
  8016b4:	c9                   	leave  
  8016b5:	c3                   	ret    

008016b6 <vprintfmt>:
{
  8016b6:	55                   	push   %ebp
  8016b7:	89 e5                	mov    %esp,%ebp
  8016b9:	57                   	push   %edi
  8016ba:	56                   	push   %esi
  8016bb:	53                   	push   %ebx
  8016bc:	83 ec 3c             	sub    $0x3c,%esp
  8016bf:	8b 75 08             	mov    0x8(%ebp),%esi
  8016c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016c5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016c8:	eb 0a                	jmp    8016d4 <vprintfmt+0x1e>
			putch(ch, putdat);
  8016ca:	83 ec 08             	sub    $0x8,%esp
  8016cd:	53                   	push   %ebx
  8016ce:	50                   	push   %eax
  8016cf:	ff d6                	call   *%esi
  8016d1:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016d4:	83 c7 01             	add    $0x1,%edi
  8016d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016db:	83 f8 25             	cmp    $0x25,%eax
  8016de:	74 0c                	je     8016ec <vprintfmt+0x36>
			if (ch == '\0')
  8016e0:	85 c0                	test   %eax,%eax
  8016e2:	75 e6                	jne    8016ca <vprintfmt+0x14>
}
  8016e4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e7:	5b                   	pop    %ebx
  8016e8:	5e                   	pop    %esi
  8016e9:	5f                   	pop    %edi
  8016ea:	5d                   	pop    %ebp
  8016eb:	c3                   	ret    
		padc = ' ';
  8016ec:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8016f0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8016f7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8016fe:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801705:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80170a:	8d 47 01             	lea    0x1(%edi),%eax
  80170d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801710:	0f b6 17             	movzbl (%edi),%edx
  801713:	8d 42 dd             	lea    -0x23(%edx),%eax
  801716:	3c 55                	cmp    $0x55,%al
  801718:	0f 87 bb 03 00 00    	ja     801ad9 <vprintfmt+0x423>
  80171e:	0f b6 c0             	movzbl %al,%eax
  801721:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  801728:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80172b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80172f:	eb d9                	jmp    80170a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801731:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801734:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801738:	eb d0                	jmp    80170a <vprintfmt+0x54>
  80173a:	0f b6 d2             	movzbl %dl,%edx
  80173d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801740:	b8 00 00 00 00       	mov    $0x0,%eax
  801745:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801748:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80174b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80174f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801752:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801755:	83 f9 09             	cmp    $0x9,%ecx
  801758:	77 55                	ja     8017af <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80175a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80175d:	eb e9                	jmp    801748 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80175f:	8b 45 14             	mov    0x14(%ebp),%eax
  801762:	8b 00                	mov    (%eax),%eax
  801764:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801767:	8b 45 14             	mov    0x14(%ebp),%eax
  80176a:	8d 40 04             	lea    0x4(%eax),%eax
  80176d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801770:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801773:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801777:	79 91                	jns    80170a <vprintfmt+0x54>
				width = precision, precision = -1;
  801779:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80177c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80177f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801786:	eb 82                	jmp    80170a <vprintfmt+0x54>
  801788:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80178b:	85 d2                	test   %edx,%edx
  80178d:	b8 00 00 00 00       	mov    $0x0,%eax
  801792:	0f 49 c2             	cmovns %edx,%eax
  801795:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801798:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80179b:	e9 6a ff ff ff       	jmp    80170a <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8017a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8017a3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8017aa:	e9 5b ff ff ff       	jmp    80170a <vprintfmt+0x54>
  8017af:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8017b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017b5:	eb bc                	jmp    801773 <vprintfmt+0xbd>
			lflag++;
  8017b7:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8017ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017bd:	e9 48 ff ff ff       	jmp    80170a <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8017c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8017c5:	8d 78 04             	lea    0x4(%eax),%edi
  8017c8:	83 ec 08             	sub    $0x8,%esp
  8017cb:	53                   	push   %ebx
  8017cc:	ff 30                	push   (%eax)
  8017ce:	ff d6                	call   *%esi
			break;
  8017d0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017d3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017d6:	e9 9d 02 00 00       	jmp    801a78 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8017db:	8b 45 14             	mov    0x14(%ebp),%eax
  8017de:	8d 78 04             	lea    0x4(%eax),%edi
  8017e1:	8b 10                	mov    (%eax),%edx
  8017e3:	89 d0                	mov    %edx,%eax
  8017e5:	f7 d8                	neg    %eax
  8017e7:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017ea:	83 f8 0f             	cmp    $0xf,%eax
  8017ed:	7f 23                	jg     801812 <vprintfmt+0x15c>
  8017ef:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  8017f6:	85 d2                	test   %edx,%edx
  8017f8:	74 18                	je     801812 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8017fa:	52                   	push   %edx
  8017fb:	68 41 23 80 00       	push   $0x802341
  801800:	53                   	push   %ebx
  801801:	56                   	push   %esi
  801802:	e8 92 fe ff ff       	call   801699 <printfmt>
  801807:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80180a:	89 7d 14             	mov    %edi,0x14(%ebp)
  80180d:	e9 66 02 00 00       	jmp    801a78 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  801812:	50                   	push   %eax
  801813:	68 fb 23 80 00       	push   $0x8023fb
  801818:	53                   	push   %ebx
  801819:	56                   	push   %esi
  80181a:	e8 7a fe ff ff       	call   801699 <printfmt>
  80181f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801822:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801825:	e9 4e 02 00 00       	jmp    801a78 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80182a:	8b 45 14             	mov    0x14(%ebp),%eax
  80182d:	83 c0 04             	add    $0x4,%eax
  801830:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801833:	8b 45 14             	mov    0x14(%ebp),%eax
  801836:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801838:	85 d2                	test   %edx,%edx
  80183a:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  80183f:	0f 45 c2             	cmovne %edx,%eax
  801842:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801845:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801849:	7e 06                	jle    801851 <vprintfmt+0x19b>
  80184b:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80184f:	75 0d                	jne    80185e <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801851:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801854:	89 c7                	mov    %eax,%edi
  801856:	03 45 e0             	add    -0x20(%ebp),%eax
  801859:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80185c:	eb 55                	jmp    8018b3 <vprintfmt+0x1fd>
  80185e:	83 ec 08             	sub    $0x8,%esp
  801861:	ff 75 d8             	push   -0x28(%ebp)
  801864:	ff 75 cc             	push   -0x34(%ebp)
  801867:	e8 0a 03 00 00       	call   801b76 <strnlen>
  80186c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80186f:	29 c1                	sub    %eax,%ecx
  801871:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801874:	83 c4 10             	add    $0x10,%esp
  801877:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  801879:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80187d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801880:	eb 0f                	jmp    801891 <vprintfmt+0x1db>
					putch(padc, putdat);
  801882:	83 ec 08             	sub    $0x8,%esp
  801885:	53                   	push   %ebx
  801886:	ff 75 e0             	push   -0x20(%ebp)
  801889:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80188b:	83 ef 01             	sub    $0x1,%edi
  80188e:	83 c4 10             	add    $0x10,%esp
  801891:	85 ff                	test   %edi,%edi
  801893:	7f ed                	jg     801882 <vprintfmt+0x1cc>
  801895:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801898:	85 d2                	test   %edx,%edx
  80189a:	b8 00 00 00 00       	mov    $0x0,%eax
  80189f:	0f 49 c2             	cmovns %edx,%eax
  8018a2:	29 c2                	sub    %eax,%edx
  8018a4:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8018a7:	eb a8                	jmp    801851 <vprintfmt+0x19b>
					putch(ch, putdat);
  8018a9:	83 ec 08             	sub    $0x8,%esp
  8018ac:	53                   	push   %ebx
  8018ad:	52                   	push   %edx
  8018ae:	ff d6                	call   *%esi
  8018b0:	83 c4 10             	add    $0x10,%esp
  8018b3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018b6:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018b8:	83 c7 01             	add    $0x1,%edi
  8018bb:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018bf:	0f be d0             	movsbl %al,%edx
  8018c2:	85 d2                	test   %edx,%edx
  8018c4:	74 4b                	je     801911 <vprintfmt+0x25b>
  8018c6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018ca:	78 06                	js     8018d2 <vprintfmt+0x21c>
  8018cc:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018d0:	78 1e                	js     8018f0 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8018d2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018d6:	74 d1                	je     8018a9 <vprintfmt+0x1f3>
  8018d8:	0f be c0             	movsbl %al,%eax
  8018db:	83 e8 20             	sub    $0x20,%eax
  8018de:	83 f8 5e             	cmp    $0x5e,%eax
  8018e1:	76 c6                	jbe    8018a9 <vprintfmt+0x1f3>
					putch('?', putdat);
  8018e3:	83 ec 08             	sub    $0x8,%esp
  8018e6:	53                   	push   %ebx
  8018e7:	6a 3f                	push   $0x3f
  8018e9:	ff d6                	call   *%esi
  8018eb:	83 c4 10             	add    $0x10,%esp
  8018ee:	eb c3                	jmp    8018b3 <vprintfmt+0x1fd>
  8018f0:	89 cf                	mov    %ecx,%edi
  8018f2:	eb 0e                	jmp    801902 <vprintfmt+0x24c>
				putch(' ', putdat);
  8018f4:	83 ec 08             	sub    $0x8,%esp
  8018f7:	53                   	push   %ebx
  8018f8:	6a 20                	push   $0x20
  8018fa:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8018fc:	83 ef 01             	sub    $0x1,%edi
  8018ff:	83 c4 10             	add    $0x10,%esp
  801902:	85 ff                	test   %edi,%edi
  801904:	7f ee                	jg     8018f4 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  801906:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801909:	89 45 14             	mov    %eax,0x14(%ebp)
  80190c:	e9 67 01 00 00       	jmp    801a78 <vprintfmt+0x3c2>
  801911:	89 cf                	mov    %ecx,%edi
  801913:	eb ed                	jmp    801902 <vprintfmt+0x24c>
	if (lflag >= 2)
  801915:	83 f9 01             	cmp    $0x1,%ecx
  801918:	7f 1b                	jg     801935 <vprintfmt+0x27f>
	else if (lflag)
  80191a:	85 c9                	test   %ecx,%ecx
  80191c:	74 63                	je     801981 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80191e:	8b 45 14             	mov    0x14(%ebp),%eax
  801921:	8b 00                	mov    (%eax),%eax
  801923:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801926:	99                   	cltd   
  801927:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80192a:	8b 45 14             	mov    0x14(%ebp),%eax
  80192d:	8d 40 04             	lea    0x4(%eax),%eax
  801930:	89 45 14             	mov    %eax,0x14(%ebp)
  801933:	eb 17                	jmp    80194c <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801935:	8b 45 14             	mov    0x14(%ebp),%eax
  801938:	8b 50 04             	mov    0x4(%eax),%edx
  80193b:	8b 00                	mov    (%eax),%eax
  80193d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801940:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801943:	8b 45 14             	mov    0x14(%ebp),%eax
  801946:	8d 40 08             	lea    0x8(%eax),%eax
  801949:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80194c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80194f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801952:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801957:	85 c9                	test   %ecx,%ecx
  801959:	0f 89 ff 00 00 00    	jns    801a5e <vprintfmt+0x3a8>
				putch('-', putdat);
  80195f:	83 ec 08             	sub    $0x8,%esp
  801962:	53                   	push   %ebx
  801963:	6a 2d                	push   $0x2d
  801965:	ff d6                	call   *%esi
				num = -(long long) num;
  801967:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80196a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80196d:	f7 da                	neg    %edx
  80196f:	83 d1 00             	adc    $0x0,%ecx
  801972:	f7 d9                	neg    %ecx
  801974:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801977:	bf 0a 00 00 00       	mov    $0xa,%edi
  80197c:	e9 dd 00 00 00       	jmp    801a5e <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801981:	8b 45 14             	mov    0x14(%ebp),%eax
  801984:	8b 00                	mov    (%eax),%eax
  801986:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801989:	99                   	cltd   
  80198a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80198d:	8b 45 14             	mov    0x14(%ebp),%eax
  801990:	8d 40 04             	lea    0x4(%eax),%eax
  801993:	89 45 14             	mov    %eax,0x14(%ebp)
  801996:	eb b4                	jmp    80194c <vprintfmt+0x296>
	if (lflag >= 2)
  801998:	83 f9 01             	cmp    $0x1,%ecx
  80199b:	7f 1e                	jg     8019bb <vprintfmt+0x305>
	else if (lflag)
  80199d:	85 c9                	test   %ecx,%ecx
  80199f:	74 32                	je     8019d3 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8019a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a4:	8b 10                	mov    (%eax),%edx
  8019a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019ab:	8d 40 04             	lea    0x4(%eax),%eax
  8019ae:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019b1:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8019b6:	e9 a3 00 00 00       	jmp    801a5e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8019bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8019be:	8b 10                	mov    (%eax),%edx
  8019c0:	8b 48 04             	mov    0x4(%eax),%ecx
  8019c3:	8d 40 08             	lea    0x8(%eax),%eax
  8019c6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019c9:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8019ce:	e9 8b 00 00 00       	jmp    801a5e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d6:	8b 10                	mov    (%eax),%edx
  8019d8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019dd:	8d 40 04             	lea    0x4(%eax),%eax
  8019e0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019e3:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8019e8:	eb 74                	jmp    801a5e <vprintfmt+0x3a8>
	if (lflag >= 2)
  8019ea:	83 f9 01             	cmp    $0x1,%ecx
  8019ed:	7f 1b                	jg     801a0a <vprintfmt+0x354>
	else if (lflag)
  8019ef:	85 c9                	test   %ecx,%ecx
  8019f1:	74 2c                	je     801a1f <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8019f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f6:	8b 10                	mov    (%eax),%edx
  8019f8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019fd:	8d 40 04             	lea    0x4(%eax),%eax
  801a00:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a03:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  801a08:	eb 54                	jmp    801a5e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801a0a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a0d:	8b 10                	mov    (%eax),%edx
  801a0f:	8b 48 04             	mov    0x4(%eax),%ecx
  801a12:	8d 40 08             	lea    0x8(%eax),%eax
  801a15:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a18:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  801a1d:	eb 3f                	jmp    801a5e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801a1f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a22:	8b 10                	mov    (%eax),%edx
  801a24:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a29:	8d 40 04             	lea    0x4(%eax),%eax
  801a2c:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a2f:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801a34:	eb 28                	jmp    801a5e <vprintfmt+0x3a8>
			putch('0', putdat);
  801a36:	83 ec 08             	sub    $0x8,%esp
  801a39:	53                   	push   %ebx
  801a3a:	6a 30                	push   $0x30
  801a3c:	ff d6                	call   *%esi
			putch('x', putdat);
  801a3e:	83 c4 08             	add    $0x8,%esp
  801a41:	53                   	push   %ebx
  801a42:	6a 78                	push   $0x78
  801a44:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a46:	8b 45 14             	mov    0x14(%ebp),%eax
  801a49:	8b 10                	mov    (%eax),%edx
  801a4b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a50:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a53:	8d 40 04             	lea    0x4(%eax),%eax
  801a56:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a59:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801a5e:	83 ec 0c             	sub    $0xc,%esp
  801a61:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801a65:	50                   	push   %eax
  801a66:	ff 75 e0             	push   -0x20(%ebp)
  801a69:	57                   	push   %edi
  801a6a:	51                   	push   %ecx
  801a6b:	52                   	push   %edx
  801a6c:	89 da                	mov    %ebx,%edx
  801a6e:	89 f0                	mov    %esi,%eax
  801a70:	e8 5e fb ff ff       	call   8015d3 <printnum>
			break;
  801a75:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801a78:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a7b:	e9 54 fc ff ff       	jmp    8016d4 <vprintfmt+0x1e>
	if (lflag >= 2)
  801a80:	83 f9 01             	cmp    $0x1,%ecx
  801a83:	7f 1b                	jg     801aa0 <vprintfmt+0x3ea>
	else if (lflag)
  801a85:	85 c9                	test   %ecx,%ecx
  801a87:	74 2c                	je     801ab5 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801a89:	8b 45 14             	mov    0x14(%ebp),%eax
  801a8c:	8b 10                	mov    (%eax),%edx
  801a8e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a93:	8d 40 04             	lea    0x4(%eax),%eax
  801a96:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a99:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  801a9e:	eb be                	jmp    801a5e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801aa0:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa3:	8b 10                	mov    (%eax),%edx
  801aa5:	8b 48 04             	mov    0x4(%eax),%ecx
  801aa8:	8d 40 08             	lea    0x8(%eax),%eax
  801aab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801aae:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  801ab3:	eb a9                	jmp    801a5e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801ab5:	8b 45 14             	mov    0x14(%ebp),%eax
  801ab8:	8b 10                	mov    (%eax),%edx
  801aba:	b9 00 00 00 00       	mov    $0x0,%ecx
  801abf:	8d 40 04             	lea    0x4(%eax),%eax
  801ac2:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ac5:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  801aca:	eb 92                	jmp    801a5e <vprintfmt+0x3a8>
			putch(ch, putdat);
  801acc:	83 ec 08             	sub    $0x8,%esp
  801acf:	53                   	push   %ebx
  801ad0:	6a 25                	push   $0x25
  801ad2:	ff d6                	call   *%esi
			break;
  801ad4:	83 c4 10             	add    $0x10,%esp
  801ad7:	eb 9f                	jmp    801a78 <vprintfmt+0x3c2>
			putch('%', putdat);
  801ad9:	83 ec 08             	sub    $0x8,%esp
  801adc:	53                   	push   %ebx
  801add:	6a 25                	push   $0x25
  801adf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ae1:	83 c4 10             	add    $0x10,%esp
  801ae4:	89 f8                	mov    %edi,%eax
  801ae6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801aea:	74 05                	je     801af1 <vprintfmt+0x43b>
  801aec:	83 e8 01             	sub    $0x1,%eax
  801aef:	eb f5                	jmp    801ae6 <vprintfmt+0x430>
  801af1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801af4:	eb 82                	jmp    801a78 <vprintfmt+0x3c2>

00801af6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	83 ec 18             	sub    $0x18,%esp
  801afc:	8b 45 08             	mov    0x8(%ebp),%eax
  801aff:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b02:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b05:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b09:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b0c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b13:	85 c0                	test   %eax,%eax
  801b15:	74 26                	je     801b3d <vsnprintf+0x47>
  801b17:	85 d2                	test   %edx,%edx
  801b19:	7e 22                	jle    801b3d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b1b:	ff 75 14             	push   0x14(%ebp)
  801b1e:	ff 75 10             	push   0x10(%ebp)
  801b21:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b24:	50                   	push   %eax
  801b25:	68 7c 16 80 00       	push   $0x80167c
  801b2a:	e8 87 fb ff ff       	call   8016b6 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b2f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b32:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b38:	83 c4 10             	add    $0x10,%esp
}
  801b3b:	c9                   	leave  
  801b3c:	c3                   	ret    
		return -E_INVAL;
  801b3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b42:	eb f7                	jmp    801b3b <vsnprintf+0x45>

00801b44 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b44:	55                   	push   %ebp
  801b45:	89 e5                	mov    %esp,%ebp
  801b47:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b4a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b4d:	50                   	push   %eax
  801b4e:	ff 75 10             	push   0x10(%ebp)
  801b51:	ff 75 0c             	push   0xc(%ebp)
  801b54:	ff 75 08             	push   0x8(%ebp)
  801b57:	e8 9a ff ff ff       	call   801af6 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b5c:	c9                   	leave  
  801b5d:	c3                   	ret    

00801b5e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b64:	b8 00 00 00 00       	mov    $0x0,%eax
  801b69:	eb 03                	jmp    801b6e <strlen+0x10>
		n++;
  801b6b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801b6e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b72:	75 f7                	jne    801b6b <strlen+0xd>
	return n;
}
  801b74:	5d                   	pop    %ebp
  801b75:	c3                   	ret    

00801b76 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b76:	55                   	push   %ebp
  801b77:	89 e5                	mov    %esp,%ebp
  801b79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b7c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b7f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b84:	eb 03                	jmp    801b89 <strnlen+0x13>
		n++;
  801b86:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b89:	39 d0                	cmp    %edx,%eax
  801b8b:	74 08                	je     801b95 <strnlen+0x1f>
  801b8d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801b91:	75 f3                	jne    801b86 <strnlen+0x10>
  801b93:	89 c2                	mov    %eax,%edx
	return n;
}
  801b95:	89 d0                	mov    %edx,%eax
  801b97:	5d                   	pop    %ebp
  801b98:	c3                   	ret    

00801b99 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b99:	55                   	push   %ebp
  801b9a:	89 e5                	mov    %esp,%ebp
  801b9c:	53                   	push   %ebx
  801b9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ba0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801ba3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba8:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801bac:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801baf:	83 c0 01             	add    $0x1,%eax
  801bb2:	84 d2                	test   %dl,%dl
  801bb4:	75 f2                	jne    801ba8 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801bb6:	89 c8                	mov    %ecx,%eax
  801bb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bbb:	c9                   	leave  
  801bbc:	c3                   	ret    

00801bbd <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bbd:	55                   	push   %ebp
  801bbe:	89 e5                	mov    %esp,%ebp
  801bc0:	53                   	push   %ebx
  801bc1:	83 ec 10             	sub    $0x10,%esp
  801bc4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bc7:	53                   	push   %ebx
  801bc8:	e8 91 ff ff ff       	call   801b5e <strlen>
  801bcd:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801bd0:	ff 75 0c             	push   0xc(%ebp)
  801bd3:	01 d8                	add    %ebx,%eax
  801bd5:	50                   	push   %eax
  801bd6:	e8 be ff ff ff       	call   801b99 <strcpy>
	return dst;
}
  801bdb:	89 d8                	mov    %ebx,%eax
  801bdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be0:	c9                   	leave  
  801be1:	c3                   	ret    

00801be2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	56                   	push   %esi
  801be6:	53                   	push   %ebx
  801be7:	8b 75 08             	mov    0x8(%ebp),%esi
  801bea:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bed:	89 f3                	mov    %esi,%ebx
  801bef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bf2:	89 f0                	mov    %esi,%eax
  801bf4:	eb 0f                	jmp    801c05 <strncpy+0x23>
		*dst++ = *src;
  801bf6:	83 c0 01             	add    $0x1,%eax
  801bf9:	0f b6 0a             	movzbl (%edx),%ecx
  801bfc:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bff:	80 f9 01             	cmp    $0x1,%cl
  801c02:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801c05:	39 d8                	cmp    %ebx,%eax
  801c07:	75 ed                	jne    801bf6 <strncpy+0x14>
	}
	return ret;
}
  801c09:	89 f0                	mov    %esi,%eax
  801c0b:	5b                   	pop    %ebx
  801c0c:	5e                   	pop    %esi
  801c0d:	5d                   	pop    %ebp
  801c0e:	c3                   	ret    

00801c0f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c0f:	55                   	push   %ebp
  801c10:	89 e5                	mov    %esp,%ebp
  801c12:	56                   	push   %esi
  801c13:	53                   	push   %ebx
  801c14:	8b 75 08             	mov    0x8(%ebp),%esi
  801c17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c1a:	8b 55 10             	mov    0x10(%ebp),%edx
  801c1d:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c1f:	85 d2                	test   %edx,%edx
  801c21:	74 21                	je     801c44 <strlcpy+0x35>
  801c23:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c27:	89 f2                	mov    %esi,%edx
  801c29:	eb 09                	jmp    801c34 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c2b:	83 c1 01             	add    $0x1,%ecx
  801c2e:	83 c2 01             	add    $0x1,%edx
  801c31:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801c34:	39 c2                	cmp    %eax,%edx
  801c36:	74 09                	je     801c41 <strlcpy+0x32>
  801c38:	0f b6 19             	movzbl (%ecx),%ebx
  801c3b:	84 db                	test   %bl,%bl
  801c3d:	75 ec                	jne    801c2b <strlcpy+0x1c>
  801c3f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801c41:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c44:	29 f0                	sub    %esi,%eax
}
  801c46:	5b                   	pop    %ebx
  801c47:	5e                   	pop    %esi
  801c48:	5d                   	pop    %ebp
  801c49:	c3                   	ret    

00801c4a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c4a:	55                   	push   %ebp
  801c4b:	89 e5                	mov    %esp,%ebp
  801c4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c50:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c53:	eb 06                	jmp    801c5b <strcmp+0x11>
		p++, q++;
  801c55:	83 c1 01             	add    $0x1,%ecx
  801c58:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801c5b:	0f b6 01             	movzbl (%ecx),%eax
  801c5e:	84 c0                	test   %al,%al
  801c60:	74 04                	je     801c66 <strcmp+0x1c>
  801c62:	3a 02                	cmp    (%edx),%al
  801c64:	74 ef                	je     801c55 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c66:	0f b6 c0             	movzbl %al,%eax
  801c69:	0f b6 12             	movzbl (%edx),%edx
  801c6c:	29 d0                	sub    %edx,%eax
}
  801c6e:	5d                   	pop    %ebp
  801c6f:	c3                   	ret    

00801c70 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	53                   	push   %ebx
  801c74:	8b 45 08             	mov    0x8(%ebp),%eax
  801c77:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c7a:	89 c3                	mov    %eax,%ebx
  801c7c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c7f:	eb 06                	jmp    801c87 <strncmp+0x17>
		n--, p++, q++;
  801c81:	83 c0 01             	add    $0x1,%eax
  801c84:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801c87:	39 d8                	cmp    %ebx,%eax
  801c89:	74 18                	je     801ca3 <strncmp+0x33>
  801c8b:	0f b6 08             	movzbl (%eax),%ecx
  801c8e:	84 c9                	test   %cl,%cl
  801c90:	74 04                	je     801c96 <strncmp+0x26>
  801c92:	3a 0a                	cmp    (%edx),%cl
  801c94:	74 eb                	je     801c81 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c96:	0f b6 00             	movzbl (%eax),%eax
  801c99:	0f b6 12             	movzbl (%edx),%edx
  801c9c:	29 d0                	sub    %edx,%eax
}
  801c9e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ca1:	c9                   	leave  
  801ca2:	c3                   	ret    
		return 0;
  801ca3:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca8:	eb f4                	jmp    801c9e <strncmp+0x2e>

00801caa <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801caa:	55                   	push   %ebp
  801cab:	89 e5                	mov    %esp,%ebp
  801cad:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cb4:	eb 03                	jmp    801cb9 <strchr+0xf>
  801cb6:	83 c0 01             	add    $0x1,%eax
  801cb9:	0f b6 10             	movzbl (%eax),%edx
  801cbc:	84 d2                	test   %dl,%dl
  801cbe:	74 06                	je     801cc6 <strchr+0x1c>
		if (*s == c)
  801cc0:	38 ca                	cmp    %cl,%dl
  801cc2:	75 f2                	jne    801cb6 <strchr+0xc>
  801cc4:	eb 05                	jmp    801ccb <strchr+0x21>
			return (char *) s;
	return 0;
  801cc6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ccb:	5d                   	pop    %ebp
  801ccc:	c3                   	ret    

00801ccd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801ccd:	55                   	push   %ebp
  801cce:	89 e5                	mov    %esp,%ebp
  801cd0:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cd7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cda:	38 ca                	cmp    %cl,%dl
  801cdc:	74 09                	je     801ce7 <strfind+0x1a>
  801cde:	84 d2                	test   %dl,%dl
  801ce0:	74 05                	je     801ce7 <strfind+0x1a>
	for (; *s; s++)
  801ce2:	83 c0 01             	add    $0x1,%eax
  801ce5:	eb f0                	jmp    801cd7 <strfind+0xa>
			break;
	return (char *) s;
}
  801ce7:	5d                   	pop    %ebp
  801ce8:	c3                   	ret    

00801ce9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	57                   	push   %edi
  801ced:	56                   	push   %esi
  801cee:	53                   	push   %ebx
  801cef:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cf2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cf5:	85 c9                	test   %ecx,%ecx
  801cf7:	74 2f                	je     801d28 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cf9:	89 f8                	mov    %edi,%eax
  801cfb:	09 c8                	or     %ecx,%eax
  801cfd:	a8 03                	test   $0x3,%al
  801cff:	75 21                	jne    801d22 <memset+0x39>
		c &= 0xFF;
  801d01:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d05:	89 d0                	mov    %edx,%eax
  801d07:	c1 e0 08             	shl    $0x8,%eax
  801d0a:	89 d3                	mov    %edx,%ebx
  801d0c:	c1 e3 18             	shl    $0x18,%ebx
  801d0f:	89 d6                	mov    %edx,%esi
  801d11:	c1 e6 10             	shl    $0x10,%esi
  801d14:	09 f3                	or     %esi,%ebx
  801d16:	09 da                	or     %ebx,%edx
  801d18:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801d1a:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801d1d:	fc                   	cld    
  801d1e:	f3 ab                	rep stos %eax,%es:(%edi)
  801d20:	eb 06                	jmp    801d28 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d22:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d25:	fc                   	cld    
  801d26:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d28:	89 f8                	mov    %edi,%eax
  801d2a:	5b                   	pop    %ebx
  801d2b:	5e                   	pop    %esi
  801d2c:	5f                   	pop    %edi
  801d2d:	5d                   	pop    %ebp
  801d2e:	c3                   	ret    

00801d2f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d2f:	55                   	push   %ebp
  801d30:	89 e5                	mov    %esp,%ebp
  801d32:	57                   	push   %edi
  801d33:	56                   	push   %esi
  801d34:	8b 45 08             	mov    0x8(%ebp),%eax
  801d37:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d3a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d3d:	39 c6                	cmp    %eax,%esi
  801d3f:	73 32                	jae    801d73 <memmove+0x44>
  801d41:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d44:	39 c2                	cmp    %eax,%edx
  801d46:	76 2b                	jbe    801d73 <memmove+0x44>
		s += n;
		d += n;
  801d48:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d4b:	89 d6                	mov    %edx,%esi
  801d4d:	09 fe                	or     %edi,%esi
  801d4f:	09 ce                	or     %ecx,%esi
  801d51:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d57:	75 0e                	jne    801d67 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d59:	83 ef 04             	sub    $0x4,%edi
  801d5c:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d5f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801d62:	fd                   	std    
  801d63:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d65:	eb 09                	jmp    801d70 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d67:	83 ef 01             	sub    $0x1,%edi
  801d6a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801d6d:	fd                   	std    
  801d6e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d70:	fc                   	cld    
  801d71:	eb 1a                	jmp    801d8d <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d73:	89 f2                	mov    %esi,%edx
  801d75:	09 c2                	or     %eax,%edx
  801d77:	09 ca                	or     %ecx,%edx
  801d79:	f6 c2 03             	test   $0x3,%dl
  801d7c:	75 0a                	jne    801d88 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801d7e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801d81:	89 c7                	mov    %eax,%edi
  801d83:	fc                   	cld    
  801d84:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d86:	eb 05                	jmp    801d8d <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801d88:	89 c7                	mov    %eax,%edi
  801d8a:	fc                   	cld    
  801d8b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d8d:	5e                   	pop    %esi
  801d8e:	5f                   	pop    %edi
  801d8f:	5d                   	pop    %ebp
  801d90:	c3                   	ret    

00801d91 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d91:	55                   	push   %ebp
  801d92:	89 e5                	mov    %esp,%ebp
  801d94:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d97:	ff 75 10             	push   0x10(%ebp)
  801d9a:	ff 75 0c             	push   0xc(%ebp)
  801d9d:	ff 75 08             	push   0x8(%ebp)
  801da0:	e8 8a ff ff ff       	call   801d2f <memmove>
}
  801da5:	c9                   	leave  
  801da6:	c3                   	ret    

00801da7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801da7:	55                   	push   %ebp
  801da8:	89 e5                	mov    %esp,%ebp
  801daa:	56                   	push   %esi
  801dab:	53                   	push   %ebx
  801dac:	8b 45 08             	mov    0x8(%ebp),%eax
  801daf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801db2:	89 c6                	mov    %eax,%esi
  801db4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801db7:	eb 06                	jmp    801dbf <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801db9:	83 c0 01             	add    $0x1,%eax
  801dbc:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801dbf:	39 f0                	cmp    %esi,%eax
  801dc1:	74 14                	je     801dd7 <memcmp+0x30>
		if (*s1 != *s2)
  801dc3:	0f b6 08             	movzbl (%eax),%ecx
  801dc6:	0f b6 1a             	movzbl (%edx),%ebx
  801dc9:	38 d9                	cmp    %bl,%cl
  801dcb:	74 ec                	je     801db9 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801dcd:	0f b6 c1             	movzbl %cl,%eax
  801dd0:	0f b6 db             	movzbl %bl,%ebx
  801dd3:	29 d8                	sub    %ebx,%eax
  801dd5:	eb 05                	jmp    801ddc <memcmp+0x35>
	}

	return 0;
  801dd7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ddc:	5b                   	pop    %ebx
  801ddd:	5e                   	pop    %esi
  801dde:	5d                   	pop    %ebp
  801ddf:	c3                   	ret    

00801de0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	8b 45 08             	mov    0x8(%ebp),%eax
  801de6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801de9:	89 c2                	mov    %eax,%edx
  801deb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801dee:	eb 03                	jmp    801df3 <memfind+0x13>
  801df0:	83 c0 01             	add    $0x1,%eax
  801df3:	39 d0                	cmp    %edx,%eax
  801df5:	73 04                	jae    801dfb <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801df7:	38 08                	cmp    %cl,(%eax)
  801df9:	75 f5                	jne    801df0 <memfind+0x10>
			break;
	return (void *) s;
}
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    

00801dfd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dfd:	55                   	push   %ebp
  801dfe:	89 e5                	mov    %esp,%ebp
  801e00:	57                   	push   %edi
  801e01:	56                   	push   %esi
  801e02:	53                   	push   %ebx
  801e03:	8b 55 08             	mov    0x8(%ebp),%edx
  801e06:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e09:	eb 03                	jmp    801e0e <strtol+0x11>
		s++;
  801e0b:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801e0e:	0f b6 02             	movzbl (%edx),%eax
  801e11:	3c 20                	cmp    $0x20,%al
  801e13:	74 f6                	je     801e0b <strtol+0xe>
  801e15:	3c 09                	cmp    $0x9,%al
  801e17:	74 f2                	je     801e0b <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801e19:	3c 2b                	cmp    $0x2b,%al
  801e1b:	74 2a                	je     801e47 <strtol+0x4a>
	int neg = 0;
  801e1d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801e22:	3c 2d                	cmp    $0x2d,%al
  801e24:	74 2b                	je     801e51 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e26:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e2c:	75 0f                	jne    801e3d <strtol+0x40>
  801e2e:	80 3a 30             	cmpb   $0x30,(%edx)
  801e31:	74 28                	je     801e5b <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e33:	85 db                	test   %ebx,%ebx
  801e35:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e3a:	0f 44 d8             	cmove  %eax,%ebx
  801e3d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e42:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801e45:	eb 46                	jmp    801e8d <strtol+0x90>
		s++;
  801e47:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801e4a:	bf 00 00 00 00       	mov    $0x0,%edi
  801e4f:	eb d5                	jmp    801e26 <strtol+0x29>
		s++, neg = 1;
  801e51:	83 c2 01             	add    $0x1,%edx
  801e54:	bf 01 00 00 00       	mov    $0x1,%edi
  801e59:	eb cb                	jmp    801e26 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e5b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e5f:	74 0e                	je     801e6f <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801e61:	85 db                	test   %ebx,%ebx
  801e63:	75 d8                	jne    801e3d <strtol+0x40>
		s++, base = 8;
  801e65:	83 c2 01             	add    $0x1,%edx
  801e68:	bb 08 00 00 00       	mov    $0x8,%ebx
  801e6d:	eb ce                	jmp    801e3d <strtol+0x40>
		s += 2, base = 16;
  801e6f:	83 c2 02             	add    $0x2,%edx
  801e72:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e77:	eb c4                	jmp    801e3d <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801e79:	0f be c0             	movsbl %al,%eax
  801e7c:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801e7f:	3b 45 10             	cmp    0x10(%ebp),%eax
  801e82:	7d 3a                	jge    801ebe <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801e84:	83 c2 01             	add    $0x1,%edx
  801e87:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801e8b:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801e8d:	0f b6 02             	movzbl (%edx),%eax
  801e90:	8d 70 d0             	lea    -0x30(%eax),%esi
  801e93:	89 f3                	mov    %esi,%ebx
  801e95:	80 fb 09             	cmp    $0x9,%bl
  801e98:	76 df                	jbe    801e79 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  801e9a:	8d 70 9f             	lea    -0x61(%eax),%esi
  801e9d:	89 f3                	mov    %esi,%ebx
  801e9f:	80 fb 19             	cmp    $0x19,%bl
  801ea2:	77 08                	ja     801eac <strtol+0xaf>
			dig = *s - 'a' + 10;
  801ea4:	0f be c0             	movsbl %al,%eax
  801ea7:	83 e8 57             	sub    $0x57,%eax
  801eaa:	eb d3                	jmp    801e7f <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801eac:	8d 70 bf             	lea    -0x41(%eax),%esi
  801eaf:	89 f3                	mov    %esi,%ebx
  801eb1:	80 fb 19             	cmp    $0x19,%bl
  801eb4:	77 08                	ja     801ebe <strtol+0xc1>
			dig = *s - 'A' + 10;
  801eb6:	0f be c0             	movsbl %al,%eax
  801eb9:	83 e8 37             	sub    $0x37,%eax
  801ebc:	eb c1                	jmp    801e7f <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801ebe:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ec2:	74 05                	je     801ec9 <strtol+0xcc>
		*endptr = (char *) s;
  801ec4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec7:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801ec9:	89 c8                	mov    %ecx,%eax
  801ecb:	f7 d8                	neg    %eax
  801ecd:	85 ff                	test   %edi,%edi
  801ecf:	0f 45 c8             	cmovne %eax,%ecx
}
  801ed2:	89 c8                	mov    %ecx,%eax
  801ed4:	5b                   	pop    %ebx
  801ed5:	5e                   	pop    %esi
  801ed6:	5f                   	pop    %edi
  801ed7:	5d                   	pop    %ebp
  801ed8:	c3                   	ret    

00801ed9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	56                   	push   %esi
  801edd:	53                   	push   %ebx
  801ede:	8b 75 08             	mov    0x8(%ebp),%esi
  801ee1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801eee:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801ef1:	83 ec 0c             	sub    $0xc,%esp
  801ef4:	50                   	push   %eax
  801ef5:	e8 3a e4 ff ff       	call   800334 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801efa:	83 c4 10             	add    $0x10,%esp
  801efd:	85 f6                	test   %esi,%esi
  801eff:	74 17                	je     801f18 <ipc_recv+0x3f>
  801f01:	ba 00 00 00 00       	mov    $0x0,%edx
  801f06:	85 c0                	test   %eax,%eax
  801f08:	78 0c                	js     801f16 <ipc_recv+0x3d>
  801f0a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f10:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801f16:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801f18:	85 db                	test   %ebx,%ebx
  801f1a:	74 17                	je     801f33 <ipc_recv+0x5a>
  801f1c:	ba 00 00 00 00       	mov    $0x0,%edx
  801f21:	85 c0                	test   %eax,%eax
  801f23:	78 0c                	js     801f31 <ipc_recv+0x58>
  801f25:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f2b:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801f31:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f33:	85 c0                	test   %eax,%eax
  801f35:	78 0b                	js     801f42 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801f37:	a1 00 40 80 00       	mov    0x804000,%eax
  801f3c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  801f42:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f45:	5b                   	pop    %ebx
  801f46:	5e                   	pop    %esi
  801f47:	5d                   	pop    %ebp
  801f48:	c3                   	ret    

00801f49 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f49:	55                   	push   %ebp
  801f4a:	89 e5                	mov    %esp,%ebp
  801f4c:	57                   	push   %edi
  801f4d:	56                   	push   %esi
  801f4e:	53                   	push   %ebx
  801f4f:	83 ec 0c             	sub    $0xc,%esp
  801f52:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f55:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f5b:	85 db                	test   %ebx,%ebx
  801f5d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f62:	0f 44 d8             	cmove  %eax,%ebx
  801f65:	eb 05                	jmp    801f6c <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f67:	e8 f9 e1 ff ff       	call   800165 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f6c:	ff 75 14             	push   0x14(%ebp)
  801f6f:	53                   	push   %ebx
  801f70:	56                   	push   %esi
  801f71:	57                   	push   %edi
  801f72:	e8 9a e3 ff ff       	call   800311 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f77:	83 c4 10             	add    $0x10,%esp
  801f7a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f7d:	74 e8                	je     801f67 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f7f:	85 c0                	test   %eax,%eax
  801f81:	78 08                	js     801f8b <ipc_send+0x42>
	}while (r<0);

}
  801f83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f86:	5b                   	pop    %ebx
  801f87:	5e                   	pop    %esi
  801f88:	5f                   	pop    %edi
  801f89:	5d                   	pop    %ebp
  801f8a:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f8b:	50                   	push   %eax
  801f8c:	68 df 26 80 00       	push   $0x8026df
  801f91:	6a 3d                	push   $0x3d
  801f93:	68 f3 26 80 00       	push   $0x8026f3
  801f98:	e8 47 f5 ff ff       	call   8014e4 <_panic>

00801f9d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f9d:	55                   	push   %ebp
  801f9e:	89 e5                	mov    %esp,%ebp
  801fa0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fa3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fa8:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  801fae:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fb4:	8b 52 60             	mov    0x60(%edx),%edx
  801fb7:	39 ca                	cmp    %ecx,%edx
  801fb9:	74 11                	je     801fcc <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  801fbb:	83 c0 01             	add    $0x1,%eax
  801fbe:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fc3:	75 e3                	jne    801fa8 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801fc5:	b8 00 00 00 00       	mov    $0x0,%eax
  801fca:	eb 0e                	jmp    801fda <ipc_find_env+0x3d>
			return envs[i].env_id;
  801fcc:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  801fd2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fd7:	8b 40 58             	mov    0x58(%eax),%eax
}
  801fda:	5d                   	pop    %ebp
  801fdb:	c3                   	ret    

00801fdc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fdc:	55                   	push   %ebp
  801fdd:	89 e5                	mov    %esp,%ebp
  801fdf:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fe2:	89 c2                	mov    %eax,%edx
  801fe4:	c1 ea 16             	shr    $0x16,%edx
  801fe7:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fee:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801ff3:	f6 c1 01             	test   $0x1,%cl
  801ff6:	74 1c                	je     802014 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801ff8:	c1 e8 0c             	shr    $0xc,%eax
  801ffb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802002:	a8 01                	test   $0x1,%al
  802004:	74 0e                	je     802014 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802006:	c1 e8 0c             	shr    $0xc,%eax
  802009:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802010:	ef 
  802011:	0f b7 d2             	movzwl %dx,%edx
}
  802014:	89 d0                	mov    %edx,%eax
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	66 90                	xchg   %ax,%ax
  80201a:	66 90                	xchg   %ax,%ax
  80201c:	66 90                	xchg   %ax,%ax
  80201e:	66 90                	xchg   %ax,%ax

00802020 <__udivdi3>:
  802020:	f3 0f 1e fb          	endbr32 
  802024:	55                   	push   %ebp
  802025:	57                   	push   %edi
  802026:	56                   	push   %esi
  802027:	53                   	push   %ebx
  802028:	83 ec 1c             	sub    $0x1c,%esp
  80202b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80202f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802033:	8b 74 24 34          	mov    0x34(%esp),%esi
  802037:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80203b:	85 c0                	test   %eax,%eax
  80203d:	75 19                	jne    802058 <__udivdi3+0x38>
  80203f:	39 f3                	cmp    %esi,%ebx
  802041:	76 4d                	jbe    802090 <__udivdi3+0x70>
  802043:	31 ff                	xor    %edi,%edi
  802045:	89 e8                	mov    %ebp,%eax
  802047:	89 f2                	mov    %esi,%edx
  802049:	f7 f3                	div    %ebx
  80204b:	89 fa                	mov    %edi,%edx
  80204d:	83 c4 1c             	add    $0x1c,%esp
  802050:	5b                   	pop    %ebx
  802051:	5e                   	pop    %esi
  802052:	5f                   	pop    %edi
  802053:	5d                   	pop    %ebp
  802054:	c3                   	ret    
  802055:	8d 76 00             	lea    0x0(%esi),%esi
  802058:	39 f0                	cmp    %esi,%eax
  80205a:	76 14                	jbe    802070 <__udivdi3+0x50>
  80205c:	31 ff                	xor    %edi,%edi
  80205e:	31 c0                	xor    %eax,%eax
  802060:	89 fa                	mov    %edi,%edx
  802062:	83 c4 1c             	add    $0x1c,%esp
  802065:	5b                   	pop    %ebx
  802066:	5e                   	pop    %esi
  802067:	5f                   	pop    %edi
  802068:	5d                   	pop    %ebp
  802069:	c3                   	ret    
  80206a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802070:	0f bd f8             	bsr    %eax,%edi
  802073:	83 f7 1f             	xor    $0x1f,%edi
  802076:	75 48                	jne    8020c0 <__udivdi3+0xa0>
  802078:	39 f0                	cmp    %esi,%eax
  80207a:	72 06                	jb     802082 <__udivdi3+0x62>
  80207c:	31 c0                	xor    %eax,%eax
  80207e:	39 eb                	cmp    %ebp,%ebx
  802080:	77 de                	ja     802060 <__udivdi3+0x40>
  802082:	b8 01 00 00 00       	mov    $0x1,%eax
  802087:	eb d7                	jmp    802060 <__udivdi3+0x40>
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	89 d9                	mov    %ebx,%ecx
  802092:	85 db                	test   %ebx,%ebx
  802094:	75 0b                	jne    8020a1 <__udivdi3+0x81>
  802096:	b8 01 00 00 00       	mov    $0x1,%eax
  80209b:	31 d2                	xor    %edx,%edx
  80209d:	f7 f3                	div    %ebx
  80209f:	89 c1                	mov    %eax,%ecx
  8020a1:	31 d2                	xor    %edx,%edx
  8020a3:	89 f0                	mov    %esi,%eax
  8020a5:	f7 f1                	div    %ecx
  8020a7:	89 c6                	mov    %eax,%esi
  8020a9:	89 e8                	mov    %ebp,%eax
  8020ab:	89 f7                	mov    %esi,%edi
  8020ad:	f7 f1                	div    %ecx
  8020af:	89 fa                	mov    %edi,%edx
  8020b1:	83 c4 1c             	add    $0x1c,%esp
  8020b4:	5b                   	pop    %ebx
  8020b5:	5e                   	pop    %esi
  8020b6:	5f                   	pop    %edi
  8020b7:	5d                   	pop    %ebp
  8020b8:	c3                   	ret    
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	89 f9                	mov    %edi,%ecx
  8020c2:	ba 20 00 00 00       	mov    $0x20,%edx
  8020c7:	29 fa                	sub    %edi,%edx
  8020c9:	d3 e0                	shl    %cl,%eax
  8020cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020cf:	89 d1                	mov    %edx,%ecx
  8020d1:	89 d8                	mov    %ebx,%eax
  8020d3:	d3 e8                	shr    %cl,%eax
  8020d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020d9:	09 c1                	or     %eax,%ecx
  8020db:	89 f0                	mov    %esi,%eax
  8020dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020e1:	89 f9                	mov    %edi,%ecx
  8020e3:	d3 e3                	shl    %cl,%ebx
  8020e5:	89 d1                	mov    %edx,%ecx
  8020e7:	d3 e8                	shr    %cl,%eax
  8020e9:	89 f9                	mov    %edi,%ecx
  8020eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020ef:	89 eb                	mov    %ebp,%ebx
  8020f1:	d3 e6                	shl    %cl,%esi
  8020f3:	89 d1                	mov    %edx,%ecx
  8020f5:	d3 eb                	shr    %cl,%ebx
  8020f7:	09 f3                	or     %esi,%ebx
  8020f9:	89 c6                	mov    %eax,%esi
  8020fb:	89 f2                	mov    %esi,%edx
  8020fd:	89 d8                	mov    %ebx,%eax
  8020ff:	f7 74 24 08          	divl   0x8(%esp)
  802103:	89 d6                	mov    %edx,%esi
  802105:	89 c3                	mov    %eax,%ebx
  802107:	f7 64 24 0c          	mull   0xc(%esp)
  80210b:	39 d6                	cmp    %edx,%esi
  80210d:	72 19                	jb     802128 <__udivdi3+0x108>
  80210f:	89 f9                	mov    %edi,%ecx
  802111:	d3 e5                	shl    %cl,%ebp
  802113:	39 c5                	cmp    %eax,%ebp
  802115:	73 04                	jae    80211b <__udivdi3+0xfb>
  802117:	39 d6                	cmp    %edx,%esi
  802119:	74 0d                	je     802128 <__udivdi3+0x108>
  80211b:	89 d8                	mov    %ebx,%eax
  80211d:	31 ff                	xor    %edi,%edi
  80211f:	e9 3c ff ff ff       	jmp    802060 <__udivdi3+0x40>
  802124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802128:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80212b:	31 ff                	xor    %edi,%edi
  80212d:	e9 2e ff ff ff       	jmp    802060 <__udivdi3+0x40>
  802132:	66 90                	xchg   %ax,%ax
  802134:	66 90                	xchg   %ax,%ax
  802136:	66 90                	xchg   %ax,%ax
  802138:	66 90                	xchg   %ax,%ax
  80213a:	66 90                	xchg   %ax,%ax
  80213c:	66 90                	xchg   %ax,%ax
  80213e:	66 90                	xchg   %ax,%ax

00802140 <__umoddi3>:
  802140:	f3 0f 1e fb          	endbr32 
  802144:	55                   	push   %ebp
  802145:	57                   	push   %edi
  802146:	56                   	push   %esi
  802147:	53                   	push   %ebx
  802148:	83 ec 1c             	sub    $0x1c,%esp
  80214b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80214f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802153:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802157:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80215b:	89 f0                	mov    %esi,%eax
  80215d:	89 da                	mov    %ebx,%edx
  80215f:	85 ff                	test   %edi,%edi
  802161:	75 15                	jne    802178 <__umoddi3+0x38>
  802163:	39 dd                	cmp    %ebx,%ebp
  802165:	76 39                	jbe    8021a0 <__umoddi3+0x60>
  802167:	f7 f5                	div    %ebp
  802169:	89 d0                	mov    %edx,%eax
  80216b:	31 d2                	xor    %edx,%edx
  80216d:	83 c4 1c             	add    $0x1c,%esp
  802170:	5b                   	pop    %ebx
  802171:	5e                   	pop    %esi
  802172:	5f                   	pop    %edi
  802173:	5d                   	pop    %ebp
  802174:	c3                   	ret    
  802175:	8d 76 00             	lea    0x0(%esi),%esi
  802178:	39 df                	cmp    %ebx,%edi
  80217a:	77 f1                	ja     80216d <__umoddi3+0x2d>
  80217c:	0f bd cf             	bsr    %edi,%ecx
  80217f:	83 f1 1f             	xor    $0x1f,%ecx
  802182:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802186:	75 40                	jne    8021c8 <__umoddi3+0x88>
  802188:	39 df                	cmp    %ebx,%edi
  80218a:	72 04                	jb     802190 <__umoddi3+0x50>
  80218c:	39 f5                	cmp    %esi,%ebp
  80218e:	77 dd                	ja     80216d <__umoddi3+0x2d>
  802190:	89 da                	mov    %ebx,%edx
  802192:	89 f0                	mov    %esi,%eax
  802194:	29 e8                	sub    %ebp,%eax
  802196:	19 fa                	sbb    %edi,%edx
  802198:	eb d3                	jmp    80216d <__umoddi3+0x2d>
  80219a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021a0:	89 e9                	mov    %ebp,%ecx
  8021a2:	85 ed                	test   %ebp,%ebp
  8021a4:	75 0b                	jne    8021b1 <__umoddi3+0x71>
  8021a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021ab:	31 d2                	xor    %edx,%edx
  8021ad:	f7 f5                	div    %ebp
  8021af:	89 c1                	mov    %eax,%ecx
  8021b1:	89 d8                	mov    %ebx,%eax
  8021b3:	31 d2                	xor    %edx,%edx
  8021b5:	f7 f1                	div    %ecx
  8021b7:	89 f0                	mov    %esi,%eax
  8021b9:	f7 f1                	div    %ecx
  8021bb:	89 d0                	mov    %edx,%eax
  8021bd:	31 d2                	xor    %edx,%edx
  8021bf:	eb ac                	jmp    80216d <__umoddi3+0x2d>
  8021c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021c8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021cc:	ba 20 00 00 00       	mov    $0x20,%edx
  8021d1:	29 c2                	sub    %eax,%edx
  8021d3:	89 c1                	mov    %eax,%ecx
  8021d5:	89 e8                	mov    %ebp,%eax
  8021d7:	d3 e7                	shl    %cl,%edi
  8021d9:	89 d1                	mov    %edx,%ecx
  8021db:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021df:	d3 e8                	shr    %cl,%eax
  8021e1:	89 c1                	mov    %eax,%ecx
  8021e3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021e7:	09 f9                	or     %edi,%ecx
  8021e9:	89 df                	mov    %ebx,%edi
  8021eb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ef:	89 c1                	mov    %eax,%ecx
  8021f1:	d3 e5                	shl    %cl,%ebp
  8021f3:	89 d1                	mov    %edx,%ecx
  8021f5:	d3 ef                	shr    %cl,%edi
  8021f7:	89 c1                	mov    %eax,%ecx
  8021f9:	89 f0                	mov    %esi,%eax
  8021fb:	d3 e3                	shl    %cl,%ebx
  8021fd:	89 d1                	mov    %edx,%ecx
  8021ff:	89 fa                	mov    %edi,%edx
  802201:	d3 e8                	shr    %cl,%eax
  802203:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802208:	09 d8                	or     %ebx,%eax
  80220a:	f7 74 24 08          	divl   0x8(%esp)
  80220e:	89 d3                	mov    %edx,%ebx
  802210:	d3 e6                	shl    %cl,%esi
  802212:	f7 e5                	mul    %ebp
  802214:	89 c7                	mov    %eax,%edi
  802216:	89 d1                	mov    %edx,%ecx
  802218:	39 d3                	cmp    %edx,%ebx
  80221a:	72 06                	jb     802222 <__umoddi3+0xe2>
  80221c:	75 0e                	jne    80222c <__umoddi3+0xec>
  80221e:	39 c6                	cmp    %eax,%esi
  802220:	73 0a                	jae    80222c <__umoddi3+0xec>
  802222:	29 e8                	sub    %ebp,%eax
  802224:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802228:	89 d1                	mov    %edx,%ecx
  80222a:	89 c7                	mov    %eax,%edi
  80222c:	89 f5                	mov    %esi,%ebp
  80222e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802232:	29 fd                	sub    %edi,%ebp
  802234:	19 cb                	sbb    %ecx,%ebx
  802236:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80223b:	89 d8                	mov    %ebx,%eax
  80223d:	d3 e0                	shl    %cl,%eax
  80223f:	89 f1                	mov    %esi,%ecx
  802241:	d3 ed                	shr    %cl,%ebp
  802243:	d3 eb                	shr    %cl,%ebx
  802245:	09 e8                	or     %ebp,%eax
  802247:	89 da                	mov    %ebx,%edx
  802249:	83 c4 1c             	add    $0x1c,%esp
  80224c:	5b                   	pop    %ebx
  80224d:	5e                   	pop    %esi
  80224e:	5f                   	pop    %edi
  80224f:	5d                   	pop    %ebp
  802250:	c3                   	ret    
