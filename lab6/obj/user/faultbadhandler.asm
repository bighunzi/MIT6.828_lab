
obj/user/faultbadhandler.debug：     文件格式 elf32-i386


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
  800042:	e8 3a 01 00 00       	call   800181 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 ef be ad de       	push   $0xdeadbeef
  80004f:	6a 00                	push   $0x0
  800051:	e8 76 02 00 00       	call   8002cc <sys_env_set_pgfault_upcall>
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
  800070:	e8 ce 00 00 00       	call   800143 <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 30 80 00       	mov    %eax,0x803000

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
  8000ae:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b1:	e8 ee 04 00 00       	call   8005a4 <close_all>
	sys_env_destroy(0);
  8000b6:	83 ec 0c             	sub    $0xc,%esp
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 42 00 00 00       	call   800102 <sys_env_destroy>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80010b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800110:	8b 55 08             	mov    0x8(%ebp),%edx
  800113:	b8 03 00 00 00       	mov    $0x3,%eax
  800118:	89 cb                	mov    %ecx,%ebx
  80011a:	89 cf                	mov    %ecx,%edi
  80011c:	89 ce                	mov    %ecx,%esi
  80011e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800120:	85 c0                	test   %eax,%eax
  800122:	7f 08                	jg     80012c <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80012c:	83 ec 0c             	sub    $0xc,%esp
  80012f:	50                   	push   %eax
  800130:	6a 03                	push   $0x3
  800132:	68 6a 22 80 00       	push   $0x80226a
  800137:	6a 2a                	push   $0x2a
  800139:	68 87 22 80 00       	push   $0x802287
  80013e:	e8 9e 13 00 00       	call   8014e1 <_panic>

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	8b 55 08             	mov    0x8(%ebp),%edx
  800192:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800195:	b8 04 00 00 00       	mov    $0x4,%eax
  80019a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7f 08                	jg     8001ad <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ad:	83 ec 0c             	sub    $0xc,%esp
  8001b0:	50                   	push   %eax
  8001b1:	6a 04                	push   $0x4
  8001b3:	68 6a 22 80 00       	push   $0x80226a
  8001b8:	6a 2a                	push   $0x2a
  8001ba:	68 87 22 80 00       	push   $0x802287
  8001bf:	e8 1d 13 00 00       	call   8014e1 <_panic>

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d3:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7f 08                	jg     8001ef <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5e                   	pop    %esi
  8001ec:	5f                   	pop    %edi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001ef:	83 ec 0c             	sub    $0xc,%esp
  8001f2:	50                   	push   %eax
  8001f3:	6a 05                	push   $0x5
  8001f5:	68 6a 22 80 00       	push   $0x80226a
  8001fa:	6a 2a                	push   $0x2a
  8001fc:	68 87 22 80 00       	push   $0x802287
  800201:	e8 db 12 00 00       	call   8014e1 <_panic>

00800206 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80020f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800214:	8b 55 08             	mov    0x8(%ebp),%edx
  800217:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021a:	b8 06 00 00 00       	mov    $0x6,%eax
  80021f:	89 df                	mov    %ebx,%edi
  800221:	89 de                	mov    %ebx,%esi
  800223:	cd 30                	int    $0x30
	if(check && ret > 0)
  800225:	85 c0                	test   %eax,%eax
  800227:	7f 08                	jg     800231 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800231:	83 ec 0c             	sub    $0xc,%esp
  800234:	50                   	push   %eax
  800235:	6a 06                	push   $0x6
  800237:	68 6a 22 80 00       	push   $0x80226a
  80023c:	6a 2a                	push   $0x2a
  80023e:	68 87 22 80 00       	push   $0x802287
  800243:	e8 99 12 00 00       	call   8014e1 <_panic>

00800248 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	8b 55 08             	mov    0x8(%ebp),%edx
  800259:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025c:	b8 08 00 00 00       	mov    $0x8,%eax
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7f 08                	jg     800273 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800273:	83 ec 0c             	sub    $0xc,%esp
  800276:	50                   	push   %eax
  800277:	6a 08                	push   $0x8
  800279:	68 6a 22 80 00       	push   $0x80226a
  80027e:	6a 2a                	push   $0x2a
  800280:	68 87 22 80 00       	push   $0x802287
  800285:	e8 57 12 00 00       	call   8014e1 <_panic>

0080028a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800293:	bb 00 00 00 00       	mov    $0x0,%ebx
  800298:	8b 55 08             	mov    0x8(%ebp),%edx
  80029b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029e:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a3:	89 df                	mov    %ebx,%edi
  8002a5:	89 de                	mov    %ebx,%esi
  8002a7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002a9:	85 c0                	test   %eax,%eax
  8002ab:	7f 08                	jg     8002b5 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002b5:	83 ec 0c             	sub    $0xc,%esp
  8002b8:	50                   	push   %eax
  8002b9:	6a 09                	push   $0x9
  8002bb:	68 6a 22 80 00       	push   $0x80226a
  8002c0:	6a 2a                	push   $0x2a
  8002c2:	68 87 22 80 00       	push   $0x802287
  8002c7:	e8 15 12 00 00       	call   8014e1 <_panic>

008002cc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002da:	8b 55 08             	mov    0x8(%ebp),%edx
  8002dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002e5:	89 df                	mov    %ebx,%edi
  8002e7:	89 de                	mov    %ebx,%esi
  8002e9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	7f 08                	jg     8002f7 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f7:	83 ec 0c             	sub    $0xc,%esp
  8002fa:	50                   	push   %eax
  8002fb:	6a 0a                	push   $0xa
  8002fd:	68 6a 22 80 00       	push   $0x80226a
  800302:	6a 2a                	push   $0x2a
  800304:	68 87 22 80 00       	push   $0x802287
  800309:	e8 d3 11 00 00       	call   8014e1 <_panic>

0080030e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
	asm volatile("int %1\n"
  800314:	8b 55 08             	mov    0x8(%ebp),%edx
  800317:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80031a:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031f:	be 00 00 00 00       	mov    $0x0,%esi
  800324:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800327:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032a:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	8b 55 08             	mov    0x8(%ebp),%edx
  800342:	b8 0d 00 00 00       	mov    $0xd,%eax
  800347:	89 cb                	mov    %ecx,%ebx
  800349:	89 cf                	mov    %ecx,%edi
  80034b:	89 ce                	mov    %ecx,%esi
  80034d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80034f:	85 c0                	test   %eax,%eax
  800351:	7f 08                	jg     80035b <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80035b:	83 ec 0c             	sub    $0xc,%esp
  80035e:	50                   	push   %eax
  80035f:	6a 0d                	push   $0xd
  800361:	68 6a 22 80 00       	push   $0x80226a
  800366:	6a 2a                	push   $0x2a
  800368:	68 87 22 80 00       	push   $0x802287
  80036d:	e8 6f 11 00 00       	call   8014e1 <_panic>

00800372 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	57                   	push   %edi
  800376:	56                   	push   %esi
  800377:	53                   	push   %ebx
	asm volatile("int %1\n"
  800378:	ba 00 00 00 00       	mov    $0x0,%edx
  80037d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800382:	89 d1                	mov    %edx,%ecx
  800384:	89 d3                	mov    %edx,%ebx
  800386:	89 d7                	mov    %edx,%edi
  800388:	89 d6                	mov    %edx,%esi
  80038a:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80038c:	5b                   	pop    %ebx
  80038d:	5e                   	pop    %esi
  80038e:	5f                   	pop    %edi
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800391:	55                   	push   %ebp
  800392:	89 e5                	mov    %esp,%ebp
  800394:	57                   	push   %edi
  800395:	56                   	push   %esi
  800396:	53                   	push   %ebx
	asm volatile("int %1\n"
  800397:	bb 00 00 00 00       	mov    $0x0,%ebx
  80039c:	8b 55 08             	mov    0x8(%ebp),%edx
  80039f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003a2:	b8 0f 00 00 00       	mov    $0xf,%eax
  8003a7:	89 df                	mov    %ebx,%edi
  8003a9:	89 de                	mov    %ebx,%esi
  8003ab:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  8003ad:	5b                   	pop    %ebx
  8003ae:	5e                   	pop    %esi
  8003af:	5f                   	pop    %edi
  8003b0:	5d                   	pop    %ebp
  8003b1:	c3                   	ret    

008003b2 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  8003b2:	55                   	push   %ebp
  8003b3:	89 e5                	mov    %esp,%ebp
  8003b5:	57                   	push   %edi
  8003b6:	56                   	push   %esi
  8003b7:	53                   	push   %ebx
	asm volatile("int %1\n"
  8003b8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003bd:	8b 55 08             	mov    0x8(%ebp),%edx
  8003c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003c3:	b8 10 00 00 00       	mov    $0x10,%eax
  8003c8:	89 df                	mov    %ebx,%edi
  8003ca:	89 de                	mov    %ebx,%esi
  8003cc:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8003ce:	5b                   	pop    %ebx
  8003cf:	5e                   	pop    %esi
  8003d0:	5f                   	pop    %edi
  8003d1:	5d                   	pop    %ebp
  8003d2:	c3                   	ret    

008003d3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003d3:	55                   	push   %ebp
  8003d4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003d9:	05 00 00 00 30       	add    $0x30000000,%eax
  8003de:	c1 e8 0c             	shr    $0xc,%eax
}
  8003e1:	5d                   	pop    %ebp
  8003e2:	c3                   	ret    

008003e3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003e3:	55                   	push   %ebp
  8003e4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e9:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003ee:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003f3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003f8:	5d                   	pop    %ebp
  8003f9:	c3                   	ret    

008003fa <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003fa:	55                   	push   %ebp
  8003fb:	89 e5                	mov    %esp,%ebp
  8003fd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800402:	89 c2                	mov    %eax,%edx
  800404:	c1 ea 16             	shr    $0x16,%edx
  800407:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80040e:	f6 c2 01             	test   $0x1,%dl
  800411:	74 29                	je     80043c <fd_alloc+0x42>
  800413:	89 c2                	mov    %eax,%edx
  800415:	c1 ea 0c             	shr    $0xc,%edx
  800418:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80041f:	f6 c2 01             	test   $0x1,%dl
  800422:	74 18                	je     80043c <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800424:	05 00 10 00 00       	add    $0x1000,%eax
  800429:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80042e:	75 d2                	jne    800402 <fd_alloc+0x8>
  800430:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800435:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80043a:	eb 05                	jmp    800441 <fd_alloc+0x47>
			return 0;
  80043c:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800441:	8b 55 08             	mov    0x8(%ebp),%edx
  800444:	89 02                	mov    %eax,(%edx)
}
  800446:	89 c8                	mov    %ecx,%eax
  800448:	5d                   	pop    %ebp
  800449:	c3                   	ret    

0080044a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80044a:	55                   	push   %ebp
  80044b:	89 e5                	mov    %esp,%ebp
  80044d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800450:	83 f8 1f             	cmp    $0x1f,%eax
  800453:	77 30                	ja     800485 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800455:	c1 e0 0c             	shl    $0xc,%eax
  800458:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80045d:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800463:	f6 c2 01             	test   $0x1,%dl
  800466:	74 24                	je     80048c <fd_lookup+0x42>
  800468:	89 c2                	mov    %eax,%edx
  80046a:	c1 ea 0c             	shr    $0xc,%edx
  80046d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800474:	f6 c2 01             	test   $0x1,%dl
  800477:	74 1a                	je     800493 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800479:	8b 55 0c             	mov    0xc(%ebp),%edx
  80047c:	89 02                	mov    %eax,(%edx)
	return 0;
  80047e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800483:	5d                   	pop    %ebp
  800484:	c3                   	ret    
		return -E_INVAL;
  800485:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80048a:	eb f7                	jmp    800483 <fd_lookup+0x39>
		return -E_INVAL;
  80048c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800491:	eb f0                	jmp    800483 <fd_lookup+0x39>
  800493:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800498:	eb e9                	jmp    800483 <fd_lookup+0x39>

0080049a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80049a:	55                   	push   %ebp
  80049b:	89 e5                	mov    %esp,%ebp
  80049d:	53                   	push   %ebx
  80049e:	83 ec 04             	sub    $0x4,%esp
  8004a1:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004a9:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8004ae:	39 13                	cmp    %edx,(%ebx)
  8004b0:	74 37                	je     8004e9 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8004b2:	83 c0 01             	add    $0x1,%eax
  8004b5:	8b 1c 85 14 23 80 00 	mov    0x802314(,%eax,4),%ebx
  8004bc:	85 db                	test   %ebx,%ebx
  8004be:	75 ee                	jne    8004ae <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004c0:	a1 00 40 80 00       	mov    0x804000,%eax
  8004c5:	8b 40 48             	mov    0x48(%eax),%eax
  8004c8:	83 ec 04             	sub    $0x4,%esp
  8004cb:	52                   	push   %edx
  8004cc:	50                   	push   %eax
  8004cd:	68 98 22 80 00       	push   $0x802298
  8004d2:	e8 e5 10 00 00       	call   8015bc <cprintf>
	*dev = 0;
	return -E_INVAL;
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8004df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004e2:	89 1a                	mov    %ebx,(%edx)
}
  8004e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004e7:	c9                   	leave  
  8004e8:	c3                   	ret    
			return 0;
  8004e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004ee:	eb ef                	jmp    8004df <dev_lookup+0x45>

008004f0 <fd_close>:
{
  8004f0:	55                   	push   %ebp
  8004f1:	89 e5                	mov    %esp,%ebp
  8004f3:	57                   	push   %edi
  8004f4:	56                   	push   %esi
  8004f5:	53                   	push   %ebx
  8004f6:	83 ec 24             	sub    $0x24,%esp
  8004f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004fc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004ff:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800502:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800503:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800509:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80050c:	50                   	push   %eax
  80050d:	e8 38 ff ff ff       	call   80044a <fd_lookup>
  800512:	89 c3                	mov    %eax,%ebx
  800514:	83 c4 10             	add    $0x10,%esp
  800517:	85 c0                	test   %eax,%eax
  800519:	78 05                	js     800520 <fd_close+0x30>
	    || fd != fd2)
  80051b:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80051e:	74 16                	je     800536 <fd_close+0x46>
		return (must_exist ? r : 0);
  800520:	89 f8                	mov    %edi,%eax
  800522:	84 c0                	test   %al,%al
  800524:	b8 00 00 00 00       	mov    $0x0,%eax
  800529:	0f 44 d8             	cmove  %eax,%ebx
}
  80052c:	89 d8                	mov    %ebx,%eax
  80052e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800531:	5b                   	pop    %ebx
  800532:	5e                   	pop    %esi
  800533:	5f                   	pop    %edi
  800534:	5d                   	pop    %ebp
  800535:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800536:	83 ec 08             	sub    $0x8,%esp
  800539:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80053c:	50                   	push   %eax
  80053d:	ff 36                	push   (%esi)
  80053f:	e8 56 ff ff ff       	call   80049a <dev_lookup>
  800544:	89 c3                	mov    %eax,%ebx
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	85 c0                	test   %eax,%eax
  80054b:	78 1a                	js     800567 <fd_close+0x77>
		if (dev->dev_close)
  80054d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800550:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800553:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800558:	85 c0                	test   %eax,%eax
  80055a:	74 0b                	je     800567 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80055c:	83 ec 0c             	sub    $0xc,%esp
  80055f:	56                   	push   %esi
  800560:	ff d0                	call   *%eax
  800562:	89 c3                	mov    %eax,%ebx
  800564:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800567:	83 ec 08             	sub    $0x8,%esp
  80056a:	56                   	push   %esi
  80056b:	6a 00                	push   $0x0
  80056d:	e8 94 fc ff ff       	call   800206 <sys_page_unmap>
	return r;
  800572:	83 c4 10             	add    $0x10,%esp
  800575:	eb b5                	jmp    80052c <fd_close+0x3c>

00800577 <close>:

int
close(int fdnum)
{
  800577:	55                   	push   %ebp
  800578:	89 e5                	mov    %esp,%ebp
  80057a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80057d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800580:	50                   	push   %eax
  800581:	ff 75 08             	push   0x8(%ebp)
  800584:	e8 c1 fe ff ff       	call   80044a <fd_lookup>
  800589:	83 c4 10             	add    $0x10,%esp
  80058c:	85 c0                	test   %eax,%eax
  80058e:	79 02                	jns    800592 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800590:	c9                   	leave  
  800591:	c3                   	ret    
		return fd_close(fd, 1);
  800592:	83 ec 08             	sub    $0x8,%esp
  800595:	6a 01                	push   $0x1
  800597:	ff 75 f4             	push   -0xc(%ebp)
  80059a:	e8 51 ff ff ff       	call   8004f0 <fd_close>
  80059f:	83 c4 10             	add    $0x10,%esp
  8005a2:	eb ec                	jmp    800590 <close+0x19>

008005a4 <close_all>:

void
close_all(void)
{
  8005a4:	55                   	push   %ebp
  8005a5:	89 e5                	mov    %esp,%ebp
  8005a7:	53                   	push   %ebx
  8005a8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005ab:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005b0:	83 ec 0c             	sub    $0xc,%esp
  8005b3:	53                   	push   %ebx
  8005b4:	e8 be ff ff ff       	call   800577 <close>
	for (i = 0; i < MAXFD; i++)
  8005b9:	83 c3 01             	add    $0x1,%ebx
  8005bc:	83 c4 10             	add    $0x10,%esp
  8005bf:	83 fb 20             	cmp    $0x20,%ebx
  8005c2:	75 ec                	jne    8005b0 <close_all+0xc>
}
  8005c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005c7:	c9                   	leave  
  8005c8:	c3                   	ret    

008005c9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005c9:	55                   	push   %ebp
  8005ca:	89 e5                	mov    %esp,%ebp
  8005cc:	57                   	push   %edi
  8005cd:	56                   	push   %esi
  8005ce:	53                   	push   %ebx
  8005cf:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005d2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005d5:	50                   	push   %eax
  8005d6:	ff 75 08             	push   0x8(%ebp)
  8005d9:	e8 6c fe ff ff       	call   80044a <fd_lookup>
  8005de:	89 c3                	mov    %eax,%ebx
  8005e0:	83 c4 10             	add    $0x10,%esp
  8005e3:	85 c0                	test   %eax,%eax
  8005e5:	78 7f                	js     800666 <dup+0x9d>
		return r;
	close(newfdnum);
  8005e7:	83 ec 0c             	sub    $0xc,%esp
  8005ea:	ff 75 0c             	push   0xc(%ebp)
  8005ed:	e8 85 ff ff ff       	call   800577 <close>

	newfd = INDEX2FD(newfdnum);
  8005f2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005f5:	c1 e6 0c             	shl    $0xc,%esi
  8005f8:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800601:	89 3c 24             	mov    %edi,(%esp)
  800604:	e8 da fd ff ff       	call   8003e3 <fd2data>
  800609:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80060b:	89 34 24             	mov    %esi,(%esp)
  80060e:	e8 d0 fd ff ff       	call   8003e3 <fd2data>
  800613:	83 c4 10             	add    $0x10,%esp
  800616:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800619:	89 d8                	mov    %ebx,%eax
  80061b:	c1 e8 16             	shr    $0x16,%eax
  80061e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800625:	a8 01                	test   $0x1,%al
  800627:	74 11                	je     80063a <dup+0x71>
  800629:	89 d8                	mov    %ebx,%eax
  80062b:	c1 e8 0c             	shr    $0xc,%eax
  80062e:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800635:	f6 c2 01             	test   $0x1,%dl
  800638:	75 36                	jne    800670 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80063a:	89 f8                	mov    %edi,%eax
  80063c:	c1 e8 0c             	shr    $0xc,%eax
  80063f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800646:	83 ec 0c             	sub    $0xc,%esp
  800649:	25 07 0e 00 00       	and    $0xe07,%eax
  80064e:	50                   	push   %eax
  80064f:	56                   	push   %esi
  800650:	6a 00                	push   $0x0
  800652:	57                   	push   %edi
  800653:	6a 00                	push   $0x0
  800655:	e8 6a fb ff ff       	call   8001c4 <sys_page_map>
  80065a:	89 c3                	mov    %eax,%ebx
  80065c:	83 c4 20             	add    $0x20,%esp
  80065f:	85 c0                	test   %eax,%eax
  800661:	78 33                	js     800696 <dup+0xcd>
		goto err;

	return newfdnum;
  800663:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800666:	89 d8                	mov    %ebx,%eax
  800668:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066b:	5b                   	pop    %ebx
  80066c:	5e                   	pop    %esi
  80066d:	5f                   	pop    %edi
  80066e:	5d                   	pop    %ebp
  80066f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800670:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800677:	83 ec 0c             	sub    $0xc,%esp
  80067a:	25 07 0e 00 00       	and    $0xe07,%eax
  80067f:	50                   	push   %eax
  800680:	ff 75 d4             	push   -0x2c(%ebp)
  800683:	6a 00                	push   $0x0
  800685:	53                   	push   %ebx
  800686:	6a 00                	push   $0x0
  800688:	e8 37 fb ff ff       	call   8001c4 <sys_page_map>
  80068d:	89 c3                	mov    %eax,%ebx
  80068f:	83 c4 20             	add    $0x20,%esp
  800692:	85 c0                	test   %eax,%eax
  800694:	79 a4                	jns    80063a <dup+0x71>
	sys_page_unmap(0, newfd);
  800696:	83 ec 08             	sub    $0x8,%esp
  800699:	56                   	push   %esi
  80069a:	6a 00                	push   $0x0
  80069c:	e8 65 fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006a1:	83 c4 08             	add    $0x8,%esp
  8006a4:	ff 75 d4             	push   -0x2c(%ebp)
  8006a7:	6a 00                	push   $0x0
  8006a9:	e8 58 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  8006ae:	83 c4 10             	add    $0x10,%esp
  8006b1:	eb b3                	jmp    800666 <dup+0x9d>

008006b3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006b3:	55                   	push   %ebp
  8006b4:	89 e5                	mov    %esp,%ebp
  8006b6:	56                   	push   %esi
  8006b7:	53                   	push   %ebx
  8006b8:	83 ec 18             	sub    $0x18,%esp
  8006bb:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006c1:	50                   	push   %eax
  8006c2:	56                   	push   %esi
  8006c3:	e8 82 fd ff ff       	call   80044a <fd_lookup>
  8006c8:	83 c4 10             	add    $0x10,%esp
  8006cb:	85 c0                	test   %eax,%eax
  8006cd:	78 3c                	js     80070b <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006cf:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8006d2:	83 ec 08             	sub    $0x8,%esp
  8006d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006d8:	50                   	push   %eax
  8006d9:	ff 33                	push   (%ebx)
  8006db:	e8 ba fd ff ff       	call   80049a <dev_lookup>
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	78 24                	js     80070b <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006e7:	8b 43 08             	mov    0x8(%ebx),%eax
  8006ea:	83 e0 03             	and    $0x3,%eax
  8006ed:	83 f8 01             	cmp    $0x1,%eax
  8006f0:	74 20                	je     800712 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f5:	8b 40 08             	mov    0x8(%eax),%eax
  8006f8:	85 c0                	test   %eax,%eax
  8006fa:	74 37                	je     800733 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006fc:	83 ec 04             	sub    $0x4,%esp
  8006ff:	ff 75 10             	push   0x10(%ebp)
  800702:	ff 75 0c             	push   0xc(%ebp)
  800705:	53                   	push   %ebx
  800706:	ff d0                	call   *%eax
  800708:	83 c4 10             	add    $0x10,%esp
}
  80070b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80070e:	5b                   	pop    %ebx
  80070f:	5e                   	pop    %esi
  800710:	5d                   	pop    %ebp
  800711:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800712:	a1 00 40 80 00       	mov    0x804000,%eax
  800717:	8b 40 48             	mov    0x48(%eax),%eax
  80071a:	83 ec 04             	sub    $0x4,%esp
  80071d:	56                   	push   %esi
  80071e:	50                   	push   %eax
  80071f:	68 d9 22 80 00       	push   $0x8022d9
  800724:	e8 93 0e 00 00       	call   8015bc <cprintf>
		return -E_INVAL;
  800729:	83 c4 10             	add    $0x10,%esp
  80072c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800731:	eb d8                	jmp    80070b <read+0x58>
		return -E_NOT_SUPP;
  800733:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800738:	eb d1                	jmp    80070b <read+0x58>

0080073a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80073a:	55                   	push   %ebp
  80073b:	89 e5                	mov    %esp,%ebp
  80073d:	57                   	push   %edi
  80073e:	56                   	push   %esi
  80073f:	53                   	push   %ebx
  800740:	83 ec 0c             	sub    $0xc,%esp
  800743:	8b 7d 08             	mov    0x8(%ebp),%edi
  800746:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800749:	bb 00 00 00 00       	mov    $0x0,%ebx
  80074e:	eb 02                	jmp    800752 <readn+0x18>
  800750:	01 c3                	add    %eax,%ebx
  800752:	39 f3                	cmp    %esi,%ebx
  800754:	73 21                	jae    800777 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800756:	83 ec 04             	sub    $0x4,%esp
  800759:	89 f0                	mov    %esi,%eax
  80075b:	29 d8                	sub    %ebx,%eax
  80075d:	50                   	push   %eax
  80075e:	89 d8                	mov    %ebx,%eax
  800760:	03 45 0c             	add    0xc(%ebp),%eax
  800763:	50                   	push   %eax
  800764:	57                   	push   %edi
  800765:	e8 49 ff ff ff       	call   8006b3 <read>
		if (m < 0)
  80076a:	83 c4 10             	add    $0x10,%esp
  80076d:	85 c0                	test   %eax,%eax
  80076f:	78 04                	js     800775 <readn+0x3b>
			return m;
		if (m == 0)
  800771:	75 dd                	jne    800750 <readn+0x16>
  800773:	eb 02                	jmp    800777 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800775:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800777:	89 d8                	mov    %ebx,%eax
  800779:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80077c:	5b                   	pop    %ebx
  80077d:	5e                   	pop    %esi
  80077e:	5f                   	pop    %edi
  80077f:	5d                   	pop    %ebp
  800780:	c3                   	ret    

00800781 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	56                   	push   %esi
  800785:	53                   	push   %ebx
  800786:	83 ec 18             	sub    $0x18,%esp
  800789:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80078c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80078f:	50                   	push   %eax
  800790:	53                   	push   %ebx
  800791:	e8 b4 fc ff ff       	call   80044a <fd_lookup>
  800796:	83 c4 10             	add    $0x10,%esp
  800799:	85 c0                	test   %eax,%eax
  80079b:	78 37                	js     8007d4 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80079d:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8007a0:	83 ec 08             	sub    $0x8,%esp
  8007a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007a6:	50                   	push   %eax
  8007a7:	ff 36                	push   (%esi)
  8007a9:	e8 ec fc ff ff       	call   80049a <dev_lookup>
  8007ae:	83 c4 10             	add    $0x10,%esp
  8007b1:	85 c0                	test   %eax,%eax
  8007b3:	78 1f                	js     8007d4 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007b5:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8007b9:	74 20                	je     8007db <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007be:	8b 40 0c             	mov    0xc(%eax),%eax
  8007c1:	85 c0                	test   %eax,%eax
  8007c3:	74 37                	je     8007fc <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007c5:	83 ec 04             	sub    $0x4,%esp
  8007c8:	ff 75 10             	push   0x10(%ebp)
  8007cb:	ff 75 0c             	push   0xc(%ebp)
  8007ce:	56                   	push   %esi
  8007cf:	ff d0                	call   *%eax
  8007d1:	83 c4 10             	add    $0x10,%esp
}
  8007d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007d7:	5b                   	pop    %ebx
  8007d8:	5e                   	pop    %esi
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007db:	a1 00 40 80 00       	mov    0x804000,%eax
  8007e0:	8b 40 48             	mov    0x48(%eax),%eax
  8007e3:	83 ec 04             	sub    $0x4,%esp
  8007e6:	53                   	push   %ebx
  8007e7:	50                   	push   %eax
  8007e8:	68 f5 22 80 00       	push   $0x8022f5
  8007ed:	e8 ca 0d 00 00       	call   8015bc <cprintf>
		return -E_INVAL;
  8007f2:	83 c4 10             	add    $0x10,%esp
  8007f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007fa:	eb d8                	jmp    8007d4 <write+0x53>
		return -E_NOT_SUPP;
  8007fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800801:	eb d1                	jmp    8007d4 <write+0x53>

00800803 <seek>:

int
seek(int fdnum, off_t offset)
{
  800803:	55                   	push   %ebp
  800804:	89 e5                	mov    %esp,%ebp
  800806:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800809:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80080c:	50                   	push   %eax
  80080d:	ff 75 08             	push   0x8(%ebp)
  800810:	e8 35 fc ff ff       	call   80044a <fd_lookup>
  800815:	83 c4 10             	add    $0x10,%esp
  800818:	85 c0                	test   %eax,%eax
  80081a:	78 0e                	js     80082a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80081c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800822:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800825:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80082a:	c9                   	leave  
  80082b:	c3                   	ret    

0080082c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80082c:	55                   	push   %ebp
  80082d:	89 e5                	mov    %esp,%ebp
  80082f:	56                   	push   %esi
  800830:	53                   	push   %ebx
  800831:	83 ec 18             	sub    $0x18,%esp
  800834:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800837:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80083a:	50                   	push   %eax
  80083b:	53                   	push   %ebx
  80083c:	e8 09 fc ff ff       	call   80044a <fd_lookup>
  800841:	83 c4 10             	add    $0x10,%esp
  800844:	85 c0                	test   %eax,%eax
  800846:	78 34                	js     80087c <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800848:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80084b:	83 ec 08             	sub    $0x8,%esp
  80084e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800851:	50                   	push   %eax
  800852:	ff 36                	push   (%esi)
  800854:	e8 41 fc ff ff       	call   80049a <dev_lookup>
  800859:	83 c4 10             	add    $0x10,%esp
  80085c:	85 c0                	test   %eax,%eax
  80085e:	78 1c                	js     80087c <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800860:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800864:	74 1d                	je     800883 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800866:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800869:	8b 40 18             	mov    0x18(%eax),%eax
  80086c:	85 c0                	test   %eax,%eax
  80086e:	74 34                	je     8008a4 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800870:	83 ec 08             	sub    $0x8,%esp
  800873:	ff 75 0c             	push   0xc(%ebp)
  800876:	56                   	push   %esi
  800877:	ff d0                	call   *%eax
  800879:	83 c4 10             	add    $0x10,%esp
}
  80087c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80087f:	5b                   	pop    %ebx
  800880:	5e                   	pop    %esi
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    
			thisenv->env_id, fdnum);
  800883:	a1 00 40 80 00       	mov    0x804000,%eax
  800888:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80088b:	83 ec 04             	sub    $0x4,%esp
  80088e:	53                   	push   %ebx
  80088f:	50                   	push   %eax
  800890:	68 b8 22 80 00       	push   $0x8022b8
  800895:	e8 22 0d 00 00       	call   8015bc <cprintf>
		return -E_INVAL;
  80089a:	83 c4 10             	add    $0x10,%esp
  80089d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008a2:	eb d8                	jmp    80087c <ftruncate+0x50>
		return -E_NOT_SUPP;
  8008a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008a9:	eb d1                	jmp    80087c <ftruncate+0x50>

008008ab <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	56                   	push   %esi
  8008af:	53                   	push   %ebx
  8008b0:	83 ec 18             	sub    $0x18,%esp
  8008b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008b9:	50                   	push   %eax
  8008ba:	ff 75 08             	push   0x8(%ebp)
  8008bd:	e8 88 fb ff ff       	call   80044a <fd_lookup>
  8008c2:	83 c4 10             	add    $0x10,%esp
  8008c5:	85 c0                	test   %eax,%eax
  8008c7:	78 49                	js     800912 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008c9:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8008cc:	83 ec 08             	sub    $0x8,%esp
  8008cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008d2:	50                   	push   %eax
  8008d3:	ff 36                	push   (%esi)
  8008d5:	e8 c0 fb ff ff       	call   80049a <dev_lookup>
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	78 31                	js     800912 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8008e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008e4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008e8:	74 2f                	je     800919 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008ea:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008ed:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008f4:	00 00 00 
	stat->st_isdir = 0;
  8008f7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008fe:	00 00 00 
	stat->st_dev = dev;
  800901:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800907:	83 ec 08             	sub    $0x8,%esp
  80090a:	53                   	push   %ebx
  80090b:	56                   	push   %esi
  80090c:	ff 50 14             	call   *0x14(%eax)
  80090f:	83 c4 10             	add    $0x10,%esp
}
  800912:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800915:	5b                   	pop    %ebx
  800916:	5e                   	pop    %esi
  800917:	5d                   	pop    %ebp
  800918:	c3                   	ret    
		return -E_NOT_SUPP;
  800919:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80091e:	eb f2                	jmp    800912 <fstat+0x67>

00800920 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	56                   	push   %esi
  800924:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800925:	83 ec 08             	sub    $0x8,%esp
  800928:	6a 00                	push   $0x0
  80092a:	ff 75 08             	push   0x8(%ebp)
  80092d:	e8 e4 01 00 00       	call   800b16 <open>
  800932:	89 c3                	mov    %eax,%ebx
  800934:	83 c4 10             	add    $0x10,%esp
  800937:	85 c0                	test   %eax,%eax
  800939:	78 1b                	js     800956 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80093b:	83 ec 08             	sub    $0x8,%esp
  80093e:	ff 75 0c             	push   0xc(%ebp)
  800941:	50                   	push   %eax
  800942:	e8 64 ff ff ff       	call   8008ab <fstat>
  800947:	89 c6                	mov    %eax,%esi
	close(fd);
  800949:	89 1c 24             	mov    %ebx,(%esp)
  80094c:	e8 26 fc ff ff       	call   800577 <close>
	return r;
  800951:	83 c4 10             	add    $0x10,%esp
  800954:	89 f3                	mov    %esi,%ebx
}
  800956:	89 d8                	mov    %ebx,%eax
  800958:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80095b:	5b                   	pop    %ebx
  80095c:	5e                   	pop    %esi
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80095f:	55                   	push   %ebp
  800960:	89 e5                	mov    %esp,%ebp
  800962:	56                   	push   %esi
  800963:	53                   	push   %ebx
  800964:	89 c6                	mov    %eax,%esi
  800966:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800968:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80096f:	74 27                	je     800998 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800971:	6a 07                	push   $0x7
  800973:	68 00 50 80 00       	push   $0x805000
  800978:	56                   	push   %esi
  800979:	ff 35 00 60 80 00    	push   0x806000
  80097f:	e8 b9 15 00 00       	call   801f3d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800984:	83 c4 0c             	add    $0xc,%esp
  800987:	6a 00                	push   $0x0
  800989:	53                   	push   %ebx
  80098a:	6a 00                	push   $0x0
  80098c:	e8 45 15 00 00       	call   801ed6 <ipc_recv>
}
  800991:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800994:	5b                   	pop    %ebx
  800995:	5e                   	pop    %esi
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800998:	83 ec 0c             	sub    $0xc,%esp
  80099b:	6a 01                	push   $0x1
  80099d:	e8 ef 15 00 00       	call   801f91 <ipc_find_env>
  8009a2:	a3 00 60 80 00       	mov    %eax,0x806000
  8009a7:	83 c4 10             	add    $0x10,%esp
  8009aa:	eb c5                	jmp    800971 <fsipc+0x12>

008009ac <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009ac:	55                   	push   %ebp
  8009ad:	89 e5                	mov    %esp,%ebp
  8009af:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009bd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009c0:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009c5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ca:	b8 02 00 00 00       	mov    $0x2,%eax
  8009cf:	e8 8b ff ff ff       	call   80095f <fsipc>
}
  8009d4:	c9                   	leave  
  8009d5:	c3                   	ret    

008009d6 <devfile_flush>:
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8009df:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ec:	b8 06 00 00 00       	mov    $0x6,%eax
  8009f1:	e8 69 ff ff ff       	call   80095f <fsipc>
}
  8009f6:	c9                   	leave  
  8009f7:	c3                   	ret    

008009f8 <devfile_stat>:
{
  8009f8:	55                   	push   %ebp
  8009f9:	89 e5                	mov    %esp,%ebp
  8009fb:	53                   	push   %ebx
  8009fc:	83 ec 04             	sub    $0x4,%esp
  8009ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
  800a05:	8b 40 0c             	mov    0xc(%eax),%eax
  800a08:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a0d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a12:	b8 05 00 00 00       	mov    $0x5,%eax
  800a17:	e8 43 ff ff ff       	call   80095f <fsipc>
  800a1c:	85 c0                	test   %eax,%eax
  800a1e:	78 2c                	js     800a4c <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a20:	83 ec 08             	sub    $0x8,%esp
  800a23:	68 00 50 80 00       	push   $0x805000
  800a28:	53                   	push   %ebx
  800a29:	e8 68 11 00 00       	call   801b96 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a2e:	a1 80 50 80 00       	mov    0x805080,%eax
  800a33:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a39:	a1 84 50 80 00       	mov    0x805084,%eax
  800a3e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a44:	83 c4 10             	add    $0x10,%esp
  800a47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a4f:	c9                   	leave  
  800a50:	c3                   	ret    

00800a51 <devfile_write>:
{
  800a51:	55                   	push   %ebp
  800a52:	89 e5                	mov    %esp,%ebp
  800a54:	83 ec 0c             	sub    $0xc,%esp
  800a57:	8b 45 10             	mov    0x10(%ebp),%eax
  800a5a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a5f:	39 d0                	cmp    %edx,%eax
  800a61:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a64:	8b 55 08             	mov    0x8(%ebp),%edx
  800a67:	8b 52 0c             	mov    0xc(%edx),%edx
  800a6a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a70:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a75:	50                   	push   %eax
  800a76:	ff 75 0c             	push   0xc(%ebp)
  800a79:	68 08 50 80 00       	push   $0x805008
  800a7e:	e8 a9 12 00 00       	call   801d2c <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800a83:	ba 00 00 00 00       	mov    $0x0,%edx
  800a88:	b8 04 00 00 00       	mov    $0x4,%eax
  800a8d:	e8 cd fe ff ff       	call   80095f <fsipc>
}
  800a92:	c9                   	leave  
  800a93:	c3                   	ret    

00800a94 <devfile_read>:
{
  800a94:	55                   	push   %ebp
  800a95:	89 e5                	mov    %esp,%ebp
  800a97:	56                   	push   %esi
  800a98:	53                   	push   %ebx
  800a99:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9f:	8b 40 0c             	mov    0xc(%eax),%eax
  800aa2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800aa7:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800aad:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab2:	b8 03 00 00 00       	mov    $0x3,%eax
  800ab7:	e8 a3 fe ff ff       	call   80095f <fsipc>
  800abc:	89 c3                	mov    %eax,%ebx
  800abe:	85 c0                	test   %eax,%eax
  800ac0:	78 1f                	js     800ae1 <devfile_read+0x4d>
	assert(r <= n);
  800ac2:	39 f0                	cmp    %esi,%eax
  800ac4:	77 24                	ja     800aea <devfile_read+0x56>
	assert(r <= PGSIZE);
  800ac6:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800acb:	7f 33                	jg     800b00 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800acd:	83 ec 04             	sub    $0x4,%esp
  800ad0:	50                   	push   %eax
  800ad1:	68 00 50 80 00       	push   $0x805000
  800ad6:	ff 75 0c             	push   0xc(%ebp)
  800ad9:	e8 4e 12 00 00       	call   801d2c <memmove>
	return r;
  800ade:	83 c4 10             	add    $0x10,%esp
}
  800ae1:	89 d8                	mov    %ebx,%eax
  800ae3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ae6:	5b                   	pop    %ebx
  800ae7:	5e                   	pop    %esi
  800ae8:	5d                   	pop    %ebp
  800ae9:	c3                   	ret    
	assert(r <= n);
  800aea:	68 28 23 80 00       	push   $0x802328
  800aef:	68 2f 23 80 00       	push   $0x80232f
  800af4:	6a 7c                	push   $0x7c
  800af6:	68 44 23 80 00       	push   $0x802344
  800afb:	e8 e1 09 00 00       	call   8014e1 <_panic>
	assert(r <= PGSIZE);
  800b00:	68 4f 23 80 00       	push   $0x80234f
  800b05:	68 2f 23 80 00       	push   $0x80232f
  800b0a:	6a 7d                	push   $0x7d
  800b0c:	68 44 23 80 00       	push   $0x802344
  800b11:	e8 cb 09 00 00       	call   8014e1 <_panic>

00800b16 <open>:
{
  800b16:	55                   	push   %ebp
  800b17:	89 e5                	mov    %esp,%ebp
  800b19:	56                   	push   %esi
  800b1a:	53                   	push   %ebx
  800b1b:	83 ec 1c             	sub    $0x1c,%esp
  800b1e:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b21:	56                   	push   %esi
  800b22:	e8 34 10 00 00       	call   801b5b <strlen>
  800b27:	83 c4 10             	add    $0x10,%esp
  800b2a:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b2f:	7f 6c                	jg     800b9d <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800b31:	83 ec 0c             	sub    $0xc,%esp
  800b34:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b37:	50                   	push   %eax
  800b38:	e8 bd f8 ff ff       	call   8003fa <fd_alloc>
  800b3d:	89 c3                	mov    %eax,%ebx
  800b3f:	83 c4 10             	add    $0x10,%esp
  800b42:	85 c0                	test   %eax,%eax
  800b44:	78 3c                	js     800b82 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800b46:	83 ec 08             	sub    $0x8,%esp
  800b49:	56                   	push   %esi
  800b4a:	68 00 50 80 00       	push   $0x805000
  800b4f:	e8 42 10 00 00       	call   801b96 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b57:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b5c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b64:	e8 f6 fd ff ff       	call   80095f <fsipc>
  800b69:	89 c3                	mov    %eax,%ebx
  800b6b:	83 c4 10             	add    $0x10,%esp
  800b6e:	85 c0                	test   %eax,%eax
  800b70:	78 19                	js     800b8b <open+0x75>
	return fd2num(fd);
  800b72:	83 ec 0c             	sub    $0xc,%esp
  800b75:	ff 75 f4             	push   -0xc(%ebp)
  800b78:	e8 56 f8 ff ff       	call   8003d3 <fd2num>
  800b7d:	89 c3                	mov    %eax,%ebx
  800b7f:	83 c4 10             	add    $0x10,%esp
}
  800b82:	89 d8                	mov    %ebx,%eax
  800b84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b87:	5b                   	pop    %ebx
  800b88:	5e                   	pop    %esi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    
		fd_close(fd, 0);
  800b8b:	83 ec 08             	sub    $0x8,%esp
  800b8e:	6a 00                	push   $0x0
  800b90:	ff 75 f4             	push   -0xc(%ebp)
  800b93:	e8 58 f9 ff ff       	call   8004f0 <fd_close>
		return r;
  800b98:	83 c4 10             	add    $0x10,%esp
  800b9b:	eb e5                	jmp    800b82 <open+0x6c>
		return -E_BAD_PATH;
  800b9d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800ba2:	eb de                	jmp    800b82 <open+0x6c>

00800ba4 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800ba4:	55                   	push   %ebp
  800ba5:	89 e5                	mov    %esp,%ebp
  800ba7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800baa:	ba 00 00 00 00       	mov    $0x0,%edx
  800baf:	b8 08 00 00 00       	mov    $0x8,%eax
  800bb4:	e8 a6 fd ff ff       	call   80095f <fsipc>
}
  800bb9:	c9                   	leave  
  800bba:	c3                   	ret    

00800bbb <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bc1:	68 5b 23 80 00       	push   $0x80235b
  800bc6:	ff 75 0c             	push   0xc(%ebp)
  800bc9:	e8 c8 0f 00 00       	call   801b96 <strcpy>
	return 0;
}
  800bce:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd3:	c9                   	leave  
  800bd4:	c3                   	ret    

00800bd5 <devsock_close>:
{
  800bd5:	55                   	push   %ebp
  800bd6:	89 e5                	mov    %esp,%ebp
  800bd8:	53                   	push   %ebx
  800bd9:	83 ec 10             	sub    $0x10,%esp
  800bdc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bdf:	53                   	push   %ebx
  800be0:	e8 e5 13 00 00       	call   801fca <pageref>
  800be5:	89 c2                	mov    %eax,%edx
  800be7:	83 c4 10             	add    $0x10,%esp
		return 0;
  800bea:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800bef:	83 fa 01             	cmp    $0x1,%edx
  800bf2:	74 05                	je     800bf9 <devsock_close+0x24>
}
  800bf4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf7:	c9                   	leave  
  800bf8:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800bf9:	83 ec 0c             	sub    $0xc,%esp
  800bfc:	ff 73 0c             	push   0xc(%ebx)
  800bff:	e8 b7 02 00 00       	call   800ebb <nsipc_close>
  800c04:	83 c4 10             	add    $0x10,%esp
  800c07:	eb eb                	jmp    800bf4 <devsock_close+0x1f>

00800c09 <devsock_write>:
{
  800c09:	55                   	push   %ebp
  800c0a:	89 e5                	mov    %esp,%ebp
  800c0c:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c0f:	6a 00                	push   $0x0
  800c11:	ff 75 10             	push   0x10(%ebp)
  800c14:	ff 75 0c             	push   0xc(%ebp)
  800c17:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1a:	ff 70 0c             	push   0xc(%eax)
  800c1d:	e8 79 03 00 00       	call   800f9b <nsipc_send>
}
  800c22:	c9                   	leave  
  800c23:	c3                   	ret    

00800c24 <devsock_read>:
{
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c2a:	6a 00                	push   $0x0
  800c2c:	ff 75 10             	push   0x10(%ebp)
  800c2f:	ff 75 0c             	push   0xc(%ebp)
  800c32:	8b 45 08             	mov    0x8(%ebp),%eax
  800c35:	ff 70 0c             	push   0xc(%eax)
  800c38:	e8 ef 02 00 00       	call   800f2c <nsipc_recv>
}
  800c3d:	c9                   	leave  
  800c3e:	c3                   	ret    

00800c3f <fd2sockid>:
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c45:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c48:	52                   	push   %edx
  800c49:	50                   	push   %eax
  800c4a:	e8 fb f7 ff ff       	call   80044a <fd_lookup>
  800c4f:	83 c4 10             	add    $0x10,%esp
  800c52:	85 c0                	test   %eax,%eax
  800c54:	78 10                	js     800c66 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800c56:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c59:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c5f:	39 08                	cmp    %ecx,(%eax)
  800c61:	75 05                	jne    800c68 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c63:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c66:	c9                   	leave  
  800c67:	c3                   	ret    
		return -E_NOT_SUPP;
  800c68:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c6d:	eb f7                	jmp    800c66 <fd2sockid+0x27>

00800c6f <alloc_sockfd>:
{
  800c6f:	55                   	push   %ebp
  800c70:	89 e5                	mov    %esp,%ebp
  800c72:	56                   	push   %esi
  800c73:	53                   	push   %ebx
  800c74:	83 ec 1c             	sub    $0x1c,%esp
  800c77:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c7c:	50                   	push   %eax
  800c7d:	e8 78 f7 ff ff       	call   8003fa <fd_alloc>
  800c82:	89 c3                	mov    %eax,%ebx
  800c84:	83 c4 10             	add    $0x10,%esp
  800c87:	85 c0                	test   %eax,%eax
  800c89:	78 43                	js     800cce <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c8b:	83 ec 04             	sub    $0x4,%esp
  800c8e:	68 07 04 00 00       	push   $0x407
  800c93:	ff 75 f4             	push   -0xc(%ebp)
  800c96:	6a 00                	push   $0x0
  800c98:	e8 e4 f4 ff ff       	call   800181 <sys_page_alloc>
  800c9d:	89 c3                	mov    %eax,%ebx
  800c9f:	83 c4 10             	add    $0x10,%esp
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	78 28                	js     800cce <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800ca6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca9:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800caf:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cb1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cb4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cbb:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cbe:	83 ec 0c             	sub    $0xc,%esp
  800cc1:	50                   	push   %eax
  800cc2:	e8 0c f7 ff ff       	call   8003d3 <fd2num>
  800cc7:	89 c3                	mov    %eax,%ebx
  800cc9:	83 c4 10             	add    $0x10,%esp
  800ccc:	eb 0c                	jmp    800cda <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800cce:	83 ec 0c             	sub    $0xc,%esp
  800cd1:	56                   	push   %esi
  800cd2:	e8 e4 01 00 00       	call   800ebb <nsipc_close>
		return r;
  800cd7:	83 c4 10             	add    $0x10,%esp
}
  800cda:	89 d8                	mov    %ebx,%eax
  800cdc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5d                   	pop    %ebp
  800ce2:	c3                   	ret    

00800ce3 <accept>:
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cec:	e8 4e ff ff ff       	call   800c3f <fd2sockid>
  800cf1:	85 c0                	test   %eax,%eax
  800cf3:	78 1b                	js     800d10 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cf5:	83 ec 04             	sub    $0x4,%esp
  800cf8:	ff 75 10             	push   0x10(%ebp)
  800cfb:	ff 75 0c             	push   0xc(%ebp)
  800cfe:	50                   	push   %eax
  800cff:	e8 0e 01 00 00       	call   800e12 <nsipc_accept>
  800d04:	83 c4 10             	add    $0x10,%esp
  800d07:	85 c0                	test   %eax,%eax
  800d09:	78 05                	js     800d10 <accept+0x2d>
	return alloc_sockfd(r);
  800d0b:	e8 5f ff ff ff       	call   800c6f <alloc_sockfd>
}
  800d10:	c9                   	leave  
  800d11:	c3                   	ret    

00800d12 <bind>:
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d18:	8b 45 08             	mov    0x8(%ebp),%eax
  800d1b:	e8 1f ff ff ff       	call   800c3f <fd2sockid>
  800d20:	85 c0                	test   %eax,%eax
  800d22:	78 12                	js     800d36 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  800d24:	83 ec 04             	sub    $0x4,%esp
  800d27:	ff 75 10             	push   0x10(%ebp)
  800d2a:	ff 75 0c             	push   0xc(%ebp)
  800d2d:	50                   	push   %eax
  800d2e:	e8 31 01 00 00       	call   800e64 <nsipc_bind>
  800d33:	83 c4 10             	add    $0x10,%esp
}
  800d36:	c9                   	leave  
  800d37:	c3                   	ret    

00800d38 <shutdown>:
{
  800d38:	55                   	push   %ebp
  800d39:	89 e5                	mov    %esp,%ebp
  800d3b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d41:	e8 f9 fe ff ff       	call   800c3f <fd2sockid>
  800d46:	85 c0                	test   %eax,%eax
  800d48:	78 0f                	js     800d59 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  800d4a:	83 ec 08             	sub    $0x8,%esp
  800d4d:	ff 75 0c             	push   0xc(%ebp)
  800d50:	50                   	push   %eax
  800d51:	e8 43 01 00 00       	call   800e99 <nsipc_shutdown>
  800d56:	83 c4 10             	add    $0x10,%esp
}
  800d59:	c9                   	leave  
  800d5a:	c3                   	ret    

00800d5b <connect>:
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d61:	8b 45 08             	mov    0x8(%ebp),%eax
  800d64:	e8 d6 fe ff ff       	call   800c3f <fd2sockid>
  800d69:	85 c0                	test   %eax,%eax
  800d6b:	78 12                	js     800d7f <connect+0x24>
	return nsipc_connect(r, name, namelen);
  800d6d:	83 ec 04             	sub    $0x4,%esp
  800d70:	ff 75 10             	push   0x10(%ebp)
  800d73:	ff 75 0c             	push   0xc(%ebp)
  800d76:	50                   	push   %eax
  800d77:	e8 59 01 00 00       	call   800ed5 <nsipc_connect>
  800d7c:	83 c4 10             	add    $0x10,%esp
}
  800d7f:	c9                   	leave  
  800d80:	c3                   	ret    

00800d81 <listen>:
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d87:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8a:	e8 b0 fe ff ff       	call   800c3f <fd2sockid>
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	78 0f                	js     800da2 <listen+0x21>
	return nsipc_listen(r, backlog);
  800d93:	83 ec 08             	sub    $0x8,%esp
  800d96:	ff 75 0c             	push   0xc(%ebp)
  800d99:	50                   	push   %eax
  800d9a:	e8 6b 01 00 00       	call   800f0a <nsipc_listen>
  800d9f:	83 c4 10             	add    $0x10,%esp
}
  800da2:	c9                   	leave  
  800da3:	c3                   	ret    

00800da4 <socket>:

int
socket(int domain, int type, int protocol)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800daa:	ff 75 10             	push   0x10(%ebp)
  800dad:	ff 75 0c             	push   0xc(%ebp)
  800db0:	ff 75 08             	push   0x8(%ebp)
  800db3:	e8 41 02 00 00       	call   800ff9 <nsipc_socket>
  800db8:	83 c4 10             	add    $0x10,%esp
  800dbb:	85 c0                	test   %eax,%eax
  800dbd:	78 05                	js     800dc4 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800dbf:	e8 ab fe ff ff       	call   800c6f <alloc_sockfd>
}
  800dc4:	c9                   	leave  
  800dc5:	c3                   	ret    

00800dc6 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
  800dc9:	53                   	push   %ebx
  800dca:	83 ec 04             	sub    $0x4,%esp
  800dcd:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800dcf:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  800dd6:	74 26                	je     800dfe <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dd8:	6a 07                	push   $0x7
  800dda:	68 00 70 80 00       	push   $0x807000
  800ddf:	53                   	push   %ebx
  800de0:	ff 35 00 80 80 00    	push   0x808000
  800de6:	e8 52 11 00 00       	call   801f3d <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800deb:	83 c4 0c             	add    $0xc,%esp
  800dee:	6a 00                	push   $0x0
  800df0:	6a 00                	push   $0x0
  800df2:	6a 00                	push   $0x0
  800df4:	e8 dd 10 00 00       	call   801ed6 <ipc_recv>
}
  800df9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dfc:	c9                   	leave  
  800dfd:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dfe:	83 ec 0c             	sub    $0xc,%esp
  800e01:	6a 02                	push   $0x2
  800e03:	e8 89 11 00 00       	call   801f91 <ipc_find_env>
  800e08:	a3 00 80 80 00       	mov    %eax,0x808000
  800e0d:	83 c4 10             	add    $0x10,%esp
  800e10:	eb c6                	jmp    800dd8 <nsipc+0x12>

00800e12 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	56                   	push   %esi
  800e16:	53                   	push   %ebx
  800e17:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1d:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e22:	8b 06                	mov    (%esi),%eax
  800e24:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e29:	b8 01 00 00 00       	mov    $0x1,%eax
  800e2e:	e8 93 ff ff ff       	call   800dc6 <nsipc>
  800e33:	89 c3                	mov    %eax,%ebx
  800e35:	85 c0                	test   %eax,%eax
  800e37:	79 09                	jns    800e42 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800e39:	89 d8                	mov    %ebx,%eax
  800e3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e3e:	5b                   	pop    %ebx
  800e3f:	5e                   	pop    %esi
  800e40:	5d                   	pop    %ebp
  800e41:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e42:	83 ec 04             	sub    $0x4,%esp
  800e45:	ff 35 10 70 80 00    	push   0x807010
  800e4b:	68 00 70 80 00       	push   $0x807000
  800e50:	ff 75 0c             	push   0xc(%ebp)
  800e53:	e8 d4 0e 00 00       	call   801d2c <memmove>
		*addrlen = ret->ret_addrlen;
  800e58:	a1 10 70 80 00       	mov    0x807010,%eax
  800e5d:	89 06                	mov    %eax,(%esi)
  800e5f:	83 c4 10             	add    $0x10,%esp
	return r;
  800e62:	eb d5                	jmp    800e39 <nsipc_accept+0x27>

00800e64 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	53                   	push   %ebx
  800e68:	83 ec 08             	sub    $0x8,%esp
  800e6b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e71:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e76:	53                   	push   %ebx
  800e77:	ff 75 0c             	push   0xc(%ebp)
  800e7a:	68 04 70 80 00       	push   $0x807004
  800e7f:	e8 a8 0e 00 00       	call   801d2c <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e84:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  800e8a:	b8 02 00 00 00       	mov    $0x2,%eax
  800e8f:	e8 32 ff ff ff       	call   800dc6 <nsipc>
}
  800e94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e97:	c9                   	leave  
  800e98:	c3                   	ret    

00800e99 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  800ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eaa:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  800eaf:	b8 03 00 00 00       	mov    $0x3,%eax
  800eb4:	e8 0d ff ff ff       	call   800dc6 <nsipc>
}
  800eb9:	c9                   	leave  
  800eba:	c3                   	ret    

00800ebb <nsipc_close>:

int
nsipc_close(int s)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ec1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec4:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  800ec9:	b8 04 00 00 00       	mov    $0x4,%eax
  800ece:	e8 f3 fe ff ff       	call   800dc6 <nsipc>
}
  800ed3:	c9                   	leave  
  800ed4:	c3                   	ret    

00800ed5 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	53                   	push   %ebx
  800ed9:	83 ec 08             	sub    $0x8,%esp
  800edc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800edf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee2:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ee7:	53                   	push   %ebx
  800ee8:	ff 75 0c             	push   0xc(%ebp)
  800eeb:	68 04 70 80 00       	push   $0x807004
  800ef0:	e8 37 0e 00 00       	call   801d2c <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ef5:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  800efb:	b8 05 00 00 00       	mov    $0x5,%eax
  800f00:	e8 c1 fe ff ff       	call   800dc6 <nsipc>
}
  800f05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f08:	c9                   	leave  
  800f09:	c3                   	ret    

00800f0a <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f10:	8b 45 08             	mov    0x8(%ebp),%eax
  800f13:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  800f18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1b:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  800f20:	b8 06 00 00 00       	mov    $0x6,%eax
  800f25:	e8 9c fe ff ff       	call   800dc6 <nsipc>
}
  800f2a:	c9                   	leave  
  800f2b:	c3                   	ret    

00800f2c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	56                   	push   %esi
  800f30:	53                   	push   %ebx
  800f31:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f34:	8b 45 08             	mov    0x8(%ebp),%eax
  800f37:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  800f3c:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  800f42:	8b 45 14             	mov    0x14(%ebp),%eax
  800f45:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f4a:	b8 07 00 00 00       	mov    $0x7,%eax
  800f4f:	e8 72 fe ff ff       	call   800dc6 <nsipc>
  800f54:	89 c3                	mov    %eax,%ebx
  800f56:	85 c0                	test   %eax,%eax
  800f58:	78 22                	js     800f7c <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  800f5a:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f5f:	39 c6                	cmp    %eax,%esi
  800f61:	0f 4e c6             	cmovle %esi,%eax
  800f64:	39 c3                	cmp    %eax,%ebx
  800f66:	7f 1d                	jg     800f85 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f68:	83 ec 04             	sub    $0x4,%esp
  800f6b:	53                   	push   %ebx
  800f6c:	68 00 70 80 00       	push   $0x807000
  800f71:	ff 75 0c             	push   0xc(%ebp)
  800f74:	e8 b3 0d 00 00       	call   801d2c <memmove>
  800f79:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f7c:	89 d8                	mov    %ebx,%eax
  800f7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f81:	5b                   	pop    %ebx
  800f82:	5e                   	pop    %esi
  800f83:	5d                   	pop    %ebp
  800f84:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f85:	68 67 23 80 00       	push   $0x802367
  800f8a:	68 2f 23 80 00       	push   $0x80232f
  800f8f:	6a 62                	push   $0x62
  800f91:	68 7c 23 80 00       	push   $0x80237c
  800f96:	e8 46 05 00 00       	call   8014e1 <_panic>

00800f9b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f9b:	55                   	push   %ebp
  800f9c:	89 e5                	mov    %esp,%ebp
  800f9e:	53                   	push   %ebx
  800f9f:	83 ec 04             	sub    $0x4,%esp
  800fa2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fa5:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa8:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  800fad:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fb3:	7f 2e                	jg     800fe3 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fb5:	83 ec 04             	sub    $0x4,%esp
  800fb8:	53                   	push   %ebx
  800fb9:	ff 75 0c             	push   0xc(%ebp)
  800fbc:	68 0c 70 80 00       	push   $0x80700c
  800fc1:	e8 66 0d 00 00       	call   801d2c <memmove>
	nsipcbuf.send.req_size = size;
  800fc6:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  800fcc:	8b 45 14             	mov    0x14(%ebp),%eax
  800fcf:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  800fd4:	b8 08 00 00 00       	mov    $0x8,%eax
  800fd9:	e8 e8 fd ff ff       	call   800dc6 <nsipc>
}
  800fde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe1:	c9                   	leave  
  800fe2:	c3                   	ret    
	assert(size < 1600);
  800fe3:	68 88 23 80 00       	push   $0x802388
  800fe8:	68 2f 23 80 00       	push   $0x80232f
  800fed:	6a 6d                	push   $0x6d
  800fef:	68 7c 23 80 00       	push   $0x80237c
  800ff4:	e8 e8 04 00 00       	call   8014e1 <_panic>

00800ff9 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800ff9:	55                   	push   %ebp
  800ffa:	89 e5                	mov    %esp,%ebp
  800ffc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fff:	8b 45 08             	mov    0x8(%ebp),%eax
  801002:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  801007:	8b 45 0c             	mov    0xc(%ebp),%eax
  80100a:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80100f:	8b 45 10             	mov    0x10(%ebp),%eax
  801012:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  801017:	b8 09 00 00 00       	mov    $0x9,%eax
  80101c:	e8 a5 fd ff ff       	call   800dc6 <nsipc>
}
  801021:	c9                   	leave  
  801022:	c3                   	ret    

00801023 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	56                   	push   %esi
  801027:	53                   	push   %ebx
  801028:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80102b:	83 ec 0c             	sub    $0xc,%esp
  80102e:	ff 75 08             	push   0x8(%ebp)
  801031:	e8 ad f3 ff ff       	call   8003e3 <fd2data>
  801036:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801038:	83 c4 08             	add    $0x8,%esp
  80103b:	68 94 23 80 00       	push   $0x802394
  801040:	53                   	push   %ebx
  801041:	e8 50 0b 00 00       	call   801b96 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801046:	8b 46 04             	mov    0x4(%esi),%eax
  801049:	2b 06                	sub    (%esi),%eax
  80104b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801051:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801058:	00 00 00 
	stat->st_dev = &devpipe;
  80105b:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801062:	30 80 00 
	return 0;
}
  801065:	b8 00 00 00 00       	mov    $0x0,%eax
  80106a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80106d:	5b                   	pop    %ebx
  80106e:	5e                   	pop    %esi
  80106f:	5d                   	pop    %ebp
  801070:	c3                   	ret    

00801071 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801071:	55                   	push   %ebp
  801072:	89 e5                	mov    %esp,%ebp
  801074:	53                   	push   %ebx
  801075:	83 ec 0c             	sub    $0xc,%esp
  801078:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80107b:	53                   	push   %ebx
  80107c:	6a 00                	push   $0x0
  80107e:	e8 83 f1 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801083:	89 1c 24             	mov    %ebx,(%esp)
  801086:	e8 58 f3 ff ff       	call   8003e3 <fd2data>
  80108b:	83 c4 08             	add    $0x8,%esp
  80108e:	50                   	push   %eax
  80108f:	6a 00                	push   $0x0
  801091:	e8 70 f1 ff ff       	call   800206 <sys_page_unmap>
}
  801096:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801099:	c9                   	leave  
  80109a:	c3                   	ret    

0080109b <_pipeisclosed>:
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	57                   	push   %edi
  80109f:	56                   	push   %esi
  8010a0:	53                   	push   %ebx
  8010a1:	83 ec 1c             	sub    $0x1c,%esp
  8010a4:	89 c7                	mov    %eax,%edi
  8010a6:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8010a8:	a1 00 40 80 00       	mov    0x804000,%eax
  8010ad:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8010b0:	83 ec 0c             	sub    $0xc,%esp
  8010b3:	57                   	push   %edi
  8010b4:	e8 11 0f 00 00       	call   801fca <pageref>
  8010b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010bc:	89 34 24             	mov    %esi,(%esp)
  8010bf:	e8 06 0f 00 00       	call   801fca <pageref>
		nn = thisenv->env_runs;
  8010c4:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8010ca:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010cd:	83 c4 10             	add    $0x10,%esp
  8010d0:	39 cb                	cmp    %ecx,%ebx
  8010d2:	74 1b                	je     8010ef <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010d4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010d7:	75 cf                	jne    8010a8 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010d9:	8b 42 58             	mov    0x58(%edx),%eax
  8010dc:	6a 01                	push   $0x1
  8010de:	50                   	push   %eax
  8010df:	53                   	push   %ebx
  8010e0:	68 9b 23 80 00       	push   $0x80239b
  8010e5:	e8 d2 04 00 00       	call   8015bc <cprintf>
  8010ea:	83 c4 10             	add    $0x10,%esp
  8010ed:	eb b9                	jmp    8010a8 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010ef:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010f2:	0f 94 c0             	sete   %al
  8010f5:	0f b6 c0             	movzbl %al,%eax
}
  8010f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fb:	5b                   	pop    %ebx
  8010fc:	5e                   	pop    %esi
  8010fd:	5f                   	pop    %edi
  8010fe:	5d                   	pop    %ebp
  8010ff:	c3                   	ret    

00801100 <devpipe_write>:
{
  801100:	55                   	push   %ebp
  801101:	89 e5                	mov    %esp,%ebp
  801103:	57                   	push   %edi
  801104:	56                   	push   %esi
  801105:	53                   	push   %ebx
  801106:	83 ec 28             	sub    $0x28,%esp
  801109:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80110c:	56                   	push   %esi
  80110d:	e8 d1 f2 ff ff       	call   8003e3 <fd2data>
  801112:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801114:	83 c4 10             	add    $0x10,%esp
  801117:	bf 00 00 00 00       	mov    $0x0,%edi
  80111c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80111f:	75 09                	jne    80112a <devpipe_write+0x2a>
	return i;
  801121:	89 f8                	mov    %edi,%eax
  801123:	eb 23                	jmp    801148 <devpipe_write+0x48>
			sys_yield();
  801125:	e8 38 f0 ff ff       	call   800162 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80112a:	8b 43 04             	mov    0x4(%ebx),%eax
  80112d:	8b 0b                	mov    (%ebx),%ecx
  80112f:	8d 51 20             	lea    0x20(%ecx),%edx
  801132:	39 d0                	cmp    %edx,%eax
  801134:	72 1a                	jb     801150 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801136:	89 da                	mov    %ebx,%edx
  801138:	89 f0                	mov    %esi,%eax
  80113a:	e8 5c ff ff ff       	call   80109b <_pipeisclosed>
  80113f:	85 c0                	test   %eax,%eax
  801141:	74 e2                	je     801125 <devpipe_write+0x25>
				return 0;
  801143:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801148:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80114b:	5b                   	pop    %ebx
  80114c:	5e                   	pop    %esi
  80114d:	5f                   	pop    %edi
  80114e:	5d                   	pop    %ebp
  80114f:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801150:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801153:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801157:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80115a:	89 c2                	mov    %eax,%edx
  80115c:	c1 fa 1f             	sar    $0x1f,%edx
  80115f:	89 d1                	mov    %edx,%ecx
  801161:	c1 e9 1b             	shr    $0x1b,%ecx
  801164:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801167:	83 e2 1f             	and    $0x1f,%edx
  80116a:	29 ca                	sub    %ecx,%edx
  80116c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801170:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801174:	83 c0 01             	add    $0x1,%eax
  801177:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80117a:	83 c7 01             	add    $0x1,%edi
  80117d:	eb 9d                	jmp    80111c <devpipe_write+0x1c>

0080117f <devpipe_read>:
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	57                   	push   %edi
  801183:	56                   	push   %esi
  801184:	53                   	push   %ebx
  801185:	83 ec 18             	sub    $0x18,%esp
  801188:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80118b:	57                   	push   %edi
  80118c:	e8 52 f2 ff ff       	call   8003e3 <fd2data>
  801191:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801193:	83 c4 10             	add    $0x10,%esp
  801196:	be 00 00 00 00       	mov    $0x0,%esi
  80119b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80119e:	75 13                	jne    8011b3 <devpipe_read+0x34>
	return i;
  8011a0:	89 f0                	mov    %esi,%eax
  8011a2:	eb 02                	jmp    8011a6 <devpipe_read+0x27>
				return i;
  8011a4:	89 f0                	mov    %esi,%eax
}
  8011a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a9:	5b                   	pop    %ebx
  8011aa:	5e                   	pop    %esi
  8011ab:	5f                   	pop    %edi
  8011ac:	5d                   	pop    %ebp
  8011ad:	c3                   	ret    
			sys_yield();
  8011ae:	e8 af ef ff ff       	call   800162 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8011b3:	8b 03                	mov    (%ebx),%eax
  8011b5:	3b 43 04             	cmp    0x4(%ebx),%eax
  8011b8:	75 18                	jne    8011d2 <devpipe_read+0x53>
			if (i > 0)
  8011ba:	85 f6                	test   %esi,%esi
  8011bc:	75 e6                	jne    8011a4 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8011be:	89 da                	mov    %ebx,%edx
  8011c0:	89 f8                	mov    %edi,%eax
  8011c2:	e8 d4 fe ff ff       	call   80109b <_pipeisclosed>
  8011c7:	85 c0                	test   %eax,%eax
  8011c9:	74 e3                	je     8011ae <devpipe_read+0x2f>
				return 0;
  8011cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d0:	eb d4                	jmp    8011a6 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011d2:	99                   	cltd   
  8011d3:	c1 ea 1b             	shr    $0x1b,%edx
  8011d6:	01 d0                	add    %edx,%eax
  8011d8:	83 e0 1f             	and    $0x1f,%eax
  8011db:	29 d0                	sub    %edx,%eax
  8011dd:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011e5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011e8:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011eb:	83 c6 01             	add    $0x1,%esi
  8011ee:	eb ab                	jmp    80119b <devpipe_read+0x1c>

008011f0 <pipe>:
{
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	56                   	push   %esi
  8011f4:	53                   	push   %ebx
  8011f5:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fb:	50                   	push   %eax
  8011fc:	e8 f9 f1 ff ff       	call   8003fa <fd_alloc>
  801201:	89 c3                	mov    %eax,%ebx
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	85 c0                	test   %eax,%eax
  801208:	0f 88 23 01 00 00    	js     801331 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80120e:	83 ec 04             	sub    $0x4,%esp
  801211:	68 07 04 00 00       	push   $0x407
  801216:	ff 75 f4             	push   -0xc(%ebp)
  801219:	6a 00                	push   $0x0
  80121b:	e8 61 ef ff ff       	call   800181 <sys_page_alloc>
  801220:	89 c3                	mov    %eax,%ebx
  801222:	83 c4 10             	add    $0x10,%esp
  801225:	85 c0                	test   %eax,%eax
  801227:	0f 88 04 01 00 00    	js     801331 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  80122d:	83 ec 0c             	sub    $0xc,%esp
  801230:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801233:	50                   	push   %eax
  801234:	e8 c1 f1 ff ff       	call   8003fa <fd_alloc>
  801239:	89 c3                	mov    %eax,%ebx
  80123b:	83 c4 10             	add    $0x10,%esp
  80123e:	85 c0                	test   %eax,%eax
  801240:	0f 88 db 00 00 00    	js     801321 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801246:	83 ec 04             	sub    $0x4,%esp
  801249:	68 07 04 00 00       	push   $0x407
  80124e:	ff 75 f0             	push   -0x10(%ebp)
  801251:	6a 00                	push   $0x0
  801253:	e8 29 ef ff ff       	call   800181 <sys_page_alloc>
  801258:	89 c3                	mov    %eax,%ebx
  80125a:	83 c4 10             	add    $0x10,%esp
  80125d:	85 c0                	test   %eax,%eax
  80125f:	0f 88 bc 00 00 00    	js     801321 <pipe+0x131>
	va = fd2data(fd0);
  801265:	83 ec 0c             	sub    $0xc,%esp
  801268:	ff 75 f4             	push   -0xc(%ebp)
  80126b:	e8 73 f1 ff ff       	call   8003e3 <fd2data>
  801270:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801272:	83 c4 0c             	add    $0xc,%esp
  801275:	68 07 04 00 00       	push   $0x407
  80127a:	50                   	push   %eax
  80127b:	6a 00                	push   $0x0
  80127d:	e8 ff ee ff ff       	call   800181 <sys_page_alloc>
  801282:	89 c3                	mov    %eax,%ebx
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	85 c0                	test   %eax,%eax
  801289:	0f 88 82 00 00 00    	js     801311 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80128f:	83 ec 0c             	sub    $0xc,%esp
  801292:	ff 75 f0             	push   -0x10(%ebp)
  801295:	e8 49 f1 ff ff       	call   8003e3 <fd2data>
  80129a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012a1:	50                   	push   %eax
  8012a2:	6a 00                	push   $0x0
  8012a4:	56                   	push   %esi
  8012a5:	6a 00                	push   $0x0
  8012a7:	e8 18 ef ff ff       	call   8001c4 <sys_page_map>
  8012ac:	89 c3                	mov    %eax,%ebx
  8012ae:	83 c4 20             	add    $0x20,%esp
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	78 4e                	js     801303 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8012b5:	a1 3c 30 80 00       	mov    0x80303c,%eax
  8012ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bd:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8012bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012c2:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8012c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012cc:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012d8:	83 ec 0c             	sub    $0xc,%esp
  8012db:	ff 75 f4             	push   -0xc(%ebp)
  8012de:	e8 f0 f0 ff ff       	call   8003d3 <fd2num>
  8012e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012e8:	83 c4 04             	add    $0x4,%esp
  8012eb:	ff 75 f0             	push   -0x10(%ebp)
  8012ee:	e8 e0 f0 ff ff       	call   8003d3 <fd2num>
  8012f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012f6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012f9:	83 c4 10             	add    $0x10,%esp
  8012fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801301:	eb 2e                	jmp    801331 <pipe+0x141>
	sys_page_unmap(0, va);
  801303:	83 ec 08             	sub    $0x8,%esp
  801306:	56                   	push   %esi
  801307:	6a 00                	push   $0x0
  801309:	e8 f8 ee ff ff       	call   800206 <sys_page_unmap>
  80130e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801311:	83 ec 08             	sub    $0x8,%esp
  801314:	ff 75 f0             	push   -0x10(%ebp)
  801317:	6a 00                	push   $0x0
  801319:	e8 e8 ee ff ff       	call   800206 <sys_page_unmap>
  80131e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801321:	83 ec 08             	sub    $0x8,%esp
  801324:	ff 75 f4             	push   -0xc(%ebp)
  801327:	6a 00                	push   $0x0
  801329:	e8 d8 ee ff ff       	call   800206 <sys_page_unmap>
  80132e:	83 c4 10             	add    $0x10,%esp
}
  801331:	89 d8                	mov    %ebx,%eax
  801333:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801336:	5b                   	pop    %ebx
  801337:	5e                   	pop    %esi
  801338:	5d                   	pop    %ebp
  801339:	c3                   	ret    

0080133a <pipeisclosed>:
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801340:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801343:	50                   	push   %eax
  801344:	ff 75 08             	push   0x8(%ebp)
  801347:	e8 fe f0 ff ff       	call   80044a <fd_lookup>
  80134c:	83 c4 10             	add    $0x10,%esp
  80134f:	85 c0                	test   %eax,%eax
  801351:	78 18                	js     80136b <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801353:	83 ec 0c             	sub    $0xc,%esp
  801356:	ff 75 f4             	push   -0xc(%ebp)
  801359:	e8 85 f0 ff ff       	call   8003e3 <fd2data>
  80135e:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801360:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801363:	e8 33 fd ff ff       	call   80109b <_pipeisclosed>
  801368:	83 c4 10             	add    $0x10,%esp
}
  80136b:	c9                   	leave  
  80136c:	c3                   	ret    

0080136d <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80136d:	b8 00 00 00 00       	mov    $0x0,%eax
  801372:	c3                   	ret    

00801373 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801379:	68 b3 23 80 00       	push   $0x8023b3
  80137e:	ff 75 0c             	push   0xc(%ebp)
  801381:	e8 10 08 00 00       	call   801b96 <strcpy>
	return 0;
}
  801386:	b8 00 00 00 00       	mov    $0x0,%eax
  80138b:	c9                   	leave  
  80138c:	c3                   	ret    

0080138d <devcons_write>:
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	57                   	push   %edi
  801391:	56                   	push   %esi
  801392:	53                   	push   %ebx
  801393:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801399:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80139e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8013a4:	eb 2e                	jmp    8013d4 <devcons_write+0x47>
		m = n - tot;
  8013a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013a9:	29 f3                	sub    %esi,%ebx
  8013ab:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8013b0:	39 c3                	cmp    %eax,%ebx
  8013b2:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8013b5:	83 ec 04             	sub    $0x4,%esp
  8013b8:	53                   	push   %ebx
  8013b9:	89 f0                	mov    %esi,%eax
  8013bb:	03 45 0c             	add    0xc(%ebp),%eax
  8013be:	50                   	push   %eax
  8013bf:	57                   	push   %edi
  8013c0:	e8 67 09 00 00       	call   801d2c <memmove>
		sys_cputs(buf, m);
  8013c5:	83 c4 08             	add    $0x8,%esp
  8013c8:	53                   	push   %ebx
  8013c9:	57                   	push   %edi
  8013ca:	e8 f6 ec ff ff       	call   8000c5 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013cf:	01 de                	add    %ebx,%esi
  8013d1:	83 c4 10             	add    $0x10,%esp
  8013d4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013d7:	72 cd                	jb     8013a6 <devcons_write+0x19>
}
  8013d9:	89 f0                	mov    %esi,%eax
  8013db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013de:	5b                   	pop    %ebx
  8013df:	5e                   	pop    %esi
  8013e0:	5f                   	pop    %edi
  8013e1:	5d                   	pop    %ebp
  8013e2:	c3                   	ret    

008013e3 <devcons_read>:
{
  8013e3:	55                   	push   %ebp
  8013e4:	89 e5                	mov    %esp,%ebp
  8013e6:	83 ec 08             	sub    $0x8,%esp
  8013e9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8013ee:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013f2:	75 07                	jne    8013fb <devcons_read+0x18>
  8013f4:	eb 1f                	jmp    801415 <devcons_read+0x32>
		sys_yield();
  8013f6:	e8 67 ed ff ff       	call   800162 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8013fb:	e8 e3 ec ff ff       	call   8000e3 <sys_cgetc>
  801400:	85 c0                	test   %eax,%eax
  801402:	74 f2                	je     8013f6 <devcons_read+0x13>
	if (c < 0)
  801404:	78 0f                	js     801415 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  801406:	83 f8 04             	cmp    $0x4,%eax
  801409:	74 0c                	je     801417 <devcons_read+0x34>
	*(char*)vbuf = c;
  80140b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80140e:	88 02                	mov    %al,(%edx)
	return 1;
  801410:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801415:	c9                   	leave  
  801416:	c3                   	ret    
		return 0;
  801417:	b8 00 00 00 00       	mov    $0x0,%eax
  80141c:	eb f7                	jmp    801415 <devcons_read+0x32>

0080141e <cputchar>:
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801424:	8b 45 08             	mov    0x8(%ebp),%eax
  801427:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  80142a:	6a 01                	push   $0x1
  80142c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80142f:	50                   	push   %eax
  801430:	e8 90 ec ff ff       	call   8000c5 <sys_cputs>
}
  801435:	83 c4 10             	add    $0x10,%esp
  801438:	c9                   	leave  
  801439:	c3                   	ret    

0080143a <getchar>:
{
  80143a:	55                   	push   %ebp
  80143b:	89 e5                	mov    %esp,%ebp
  80143d:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801440:	6a 01                	push   $0x1
  801442:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801445:	50                   	push   %eax
  801446:	6a 00                	push   $0x0
  801448:	e8 66 f2 ff ff       	call   8006b3 <read>
	if (r < 0)
  80144d:	83 c4 10             	add    $0x10,%esp
  801450:	85 c0                	test   %eax,%eax
  801452:	78 06                	js     80145a <getchar+0x20>
	if (r < 1)
  801454:	74 06                	je     80145c <getchar+0x22>
	return c;
  801456:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80145a:	c9                   	leave  
  80145b:	c3                   	ret    
		return -E_EOF;
  80145c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801461:	eb f7                	jmp    80145a <getchar+0x20>

00801463 <iscons>:
{
  801463:	55                   	push   %ebp
  801464:	89 e5                	mov    %esp,%ebp
  801466:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801469:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146c:	50                   	push   %eax
  80146d:	ff 75 08             	push   0x8(%ebp)
  801470:	e8 d5 ef ff ff       	call   80044a <fd_lookup>
  801475:	83 c4 10             	add    $0x10,%esp
  801478:	85 c0                	test   %eax,%eax
  80147a:	78 11                	js     80148d <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80147c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801485:	39 10                	cmp    %edx,(%eax)
  801487:	0f 94 c0             	sete   %al
  80148a:	0f b6 c0             	movzbl %al,%eax
}
  80148d:	c9                   	leave  
  80148e:	c3                   	ret    

0080148f <opencons>:
{
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
  801492:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801495:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801498:	50                   	push   %eax
  801499:	e8 5c ef ff ff       	call   8003fa <fd_alloc>
  80149e:	83 c4 10             	add    $0x10,%esp
  8014a1:	85 c0                	test   %eax,%eax
  8014a3:	78 3a                	js     8014df <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014a5:	83 ec 04             	sub    $0x4,%esp
  8014a8:	68 07 04 00 00       	push   $0x407
  8014ad:	ff 75 f4             	push   -0xc(%ebp)
  8014b0:	6a 00                	push   $0x0
  8014b2:	e8 ca ec ff ff       	call   800181 <sys_page_alloc>
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	78 21                	js     8014df <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8014be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c1:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014c7:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014d3:	83 ec 0c             	sub    $0xc,%esp
  8014d6:	50                   	push   %eax
  8014d7:	e8 f7 ee ff ff       	call   8003d3 <fd2num>
  8014dc:	83 c4 10             	add    $0x10,%esp
}
  8014df:	c9                   	leave  
  8014e0:	c3                   	ret    

008014e1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014e1:	55                   	push   %ebp
  8014e2:	89 e5                	mov    %esp,%ebp
  8014e4:	56                   	push   %esi
  8014e5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014e6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014e9:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014ef:	e8 4f ec ff ff       	call   800143 <sys_getenvid>
  8014f4:	83 ec 0c             	sub    $0xc,%esp
  8014f7:	ff 75 0c             	push   0xc(%ebp)
  8014fa:	ff 75 08             	push   0x8(%ebp)
  8014fd:	56                   	push   %esi
  8014fe:	50                   	push   %eax
  8014ff:	68 c0 23 80 00       	push   $0x8023c0
  801504:	e8 b3 00 00 00       	call   8015bc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801509:	83 c4 18             	add    $0x18,%esp
  80150c:	53                   	push   %ebx
  80150d:	ff 75 10             	push   0x10(%ebp)
  801510:	e8 56 00 00 00       	call   80156b <vcprintf>
	cprintf("\n");
  801515:	c7 04 24 ac 23 80 00 	movl   $0x8023ac,(%esp)
  80151c:	e8 9b 00 00 00       	call   8015bc <cprintf>
  801521:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801524:	cc                   	int3   
  801525:	eb fd                	jmp    801524 <_panic+0x43>

00801527 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801527:	55                   	push   %ebp
  801528:	89 e5                	mov    %esp,%ebp
  80152a:	53                   	push   %ebx
  80152b:	83 ec 04             	sub    $0x4,%esp
  80152e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801531:	8b 13                	mov    (%ebx),%edx
  801533:	8d 42 01             	lea    0x1(%edx),%eax
  801536:	89 03                	mov    %eax,(%ebx)
  801538:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80153b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80153f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801544:	74 09                	je     80154f <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801546:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80154a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154d:	c9                   	leave  
  80154e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80154f:	83 ec 08             	sub    $0x8,%esp
  801552:	68 ff 00 00 00       	push   $0xff
  801557:	8d 43 08             	lea    0x8(%ebx),%eax
  80155a:	50                   	push   %eax
  80155b:	e8 65 eb ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  801560:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	eb db                	jmp    801546 <putch+0x1f>

0080156b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801574:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80157b:	00 00 00 
	b.cnt = 0;
  80157e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801585:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801588:	ff 75 0c             	push   0xc(%ebp)
  80158b:	ff 75 08             	push   0x8(%ebp)
  80158e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801594:	50                   	push   %eax
  801595:	68 27 15 80 00       	push   $0x801527
  80159a:	e8 14 01 00 00       	call   8016b3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80159f:	83 c4 08             	add    $0x8,%esp
  8015a2:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8015a8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015ae:	50                   	push   %eax
  8015af:	e8 11 eb ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  8015b4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015ba:	c9                   	leave  
  8015bb:	c3                   	ret    

008015bc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015c2:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015c5:	50                   	push   %eax
  8015c6:	ff 75 08             	push   0x8(%ebp)
  8015c9:	e8 9d ff ff ff       	call   80156b <vcprintf>
	va_end(ap);

	return cnt;
}
  8015ce:	c9                   	leave  
  8015cf:	c3                   	ret    

008015d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015d0:	55                   	push   %ebp
  8015d1:	89 e5                	mov    %esp,%ebp
  8015d3:	57                   	push   %edi
  8015d4:	56                   	push   %esi
  8015d5:	53                   	push   %ebx
  8015d6:	83 ec 1c             	sub    $0x1c,%esp
  8015d9:	89 c7                	mov    %eax,%edi
  8015db:	89 d6                	mov    %edx,%esi
  8015dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e3:	89 d1                	mov    %edx,%ecx
  8015e5:	89 c2                	mov    %eax,%edx
  8015e7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015ea:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8015ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8015f0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015f6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8015fd:	39 c2                	cmp    %eax,%edx
  8015ff:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801602:	72 3e                	jb     801642 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801604:	83 ec 0c             	sub    $0xc,%esp
  801607:	ff 75 18             	push   0x18(%ebp)
  80160a:	83 eb 01             	sub    $0x1,%ebx
  80160d:	53                   	push   %ebx
  80160e:	50                   	push   %eax
  80160f:	83 ec 08             	sub    $0x8,%esp
  801612:	ff 75 e4             	push   -0x1c(%ebp)
  801615:	ff 75 e0             	push   -0x20(%ebp)
  801618:	ff 75 dc             	push   -0x24(%ebp)
  80161b:	ff 75 d8             	push   -0x28(%ebp)
  80161e:	e8 ed 09 00 00       	call   802010 <__udivdi3>
  801623:	83 c4 18             	add    $0x18,%esp
  801626:	52                   	push   %edx
  801627:	50                   	push   %eax
  801628:	89 f2                	mov    %esi,%edx
  80162a:	89 f8                	mov    %edi,%eax
  80162c:	e8 9f ff ff ff       	call   8015d0 <printnum>
  801631:	83 c4 20             	add    $0x20,%esp
  801634:	eb 13                	jmp    801649 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801636:	83 ec 08             	sub    $0x8,%esp
  801639:	56                   	push   %esi
  80163a:	ff 75 18             	push   0x18(%ebp)
  80163d:	ff d7                	call   *%edi
  80163f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801642:	83 eb 01             	sub    $0x1,%ebx
  801645:	85 db                	test   %ebx,%ebx
  801647:	7f ed                	jg     801636 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801649:	83 ec 08             	sub    $0x8,%esp
  80164c:	56                   	push   %esi
  80164d:	83 ec 04             	sub    $0x4,%esp
  801650:	ff 75 e4             	push   -0x1c(%ebp)
  801653:	ff 75 e0             	push   -0x20(%ebp)
  801656:	ff 75 dc             	push   -0x24(%ebp)
  801659:	ff 75 d8             	push   -0x28(%ebp)
  80165c:	e8 cf 0a 00 00       	call   802130 <__umoddi3>
  801661:	83 c4 14             	add    $0x14,%esp
  801664:	0f be 80 e3 23 80 00 	movsbl 0x8023e3(%eax),%eax
  80166b:	50                   	push   %eax
  80166c:	ff d7                	call   *%edi
}
  80166e:	83 c4 10             	add    $0x10,%esp
  801671:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801674:	5b                   	pop    %ebx
  801675:	5e                   	pop    %esi
  801676:	5f                   	pop    %edi
  801677:	5d                   	pop    %ebp
  801678:	c3                   	ret    

00801679 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801679:	55                   	push   %ebp
  80167a:	89 e5                	mov    %esp,%ebp
  80167c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80167f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801683:	8b 10                	mov    (%eax),%edx
  801685:	3b 50 04             	cmp    0x4(%eax),%edx
  801688:	73 0a                	jae    801694 <sprintputch+0x1b>
		*b->buf++ = ch;
  80168a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80168d:	89 08                	mov    %ecx,(%eax)
  80168f:	8b 45 08             	mov    0x8(%ebp),%eax
  801692:	88 02                	mov    %al,(%edx)
}
  801694:	5d                   	pop    %ebp
  801695:	c3                   	ret    

00801696 <printfmt>:
{
  801696:	55                   	push   %ebp
  801697:	89 e5                	mov    %esp,%ebp
  801699:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80169c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80169f:	50                   	push   %eax
  8016a0:	ff 75 10             	push   0x10(%ebp)
  8016a3:	ff 75 0c             	push   0xc(%ebp)
  8016a6:	ff 75 08             	push   0x8(%ebp)
  8016a9:	e8 05 00 00 00       	call   8016b3 <vprintfmt>
}
  8016ae:	83 c4 10             	add    $0x10,%esp
  8016b1:	c9                   	leave  
  8016b2:	c3                   	ret    

008016b3 <vprintfmt>:
{
  8016b3:	55                   	push   %ebp
  8016b4:	89 e5                	mov    %esp,%ebp
  8016b6:	57                   	push   %edi
  8016b7:	56                   	push   %esi
  8016b8:	53                   	push   %ebx
  8016b9:	83 ec 3c             	sub    $0x3c,%esp
  8016bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8016bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016c2:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016c5:	eb 0a                	jmp    8016d1 <vprintfmt+0x1e>
			putch(ch, putdat);
  8016c7:	83 ec 08             	sub    $0x8,%esp
  8016ca:	53                   	push   %ebx
  8016cb:	50                   	push   %eax
  8016cc:	ff d6                	call   *%esi
  8016ce:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016d1:	83 c7 01             	add    $0x1,%edi
  8016d4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016d8:	83 f8 25             	cmp    $0x25,%eax
  8016db:	74 0c                	je     8016e9 <vprintfmt+0x36>
			if (ch == '\0')
  8016dd:	85 c0                	test   %eax,%eax
  8016df:	75 e6                	jne    8016c7 <vprintfmt+0x14>
}
  8016e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e4:	5b                   	pop    %ebx
  8016e5:	5e                   	pop    %esi
  8016e6:	5f                   	pop    %edi
  8016e7:	5d                   	pop    %ebp
  8016e8:	c3                   	ret    
		padc = ' ';
  8016e9:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8016ed:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8016f4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8016fb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801702:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801707:	8d 47 01             	lea    0x1(%edi),%eax
  80170a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80170d:	0f b6 17             	movzbl (%edi),%edx
  801710:	8d 42 dd             	lea    -0x23(%edx),%eax
  801713:	3c 55                	cmp    $0x55,%al
  801715:	0f 87 bb 03 00 00    	ja     801ad6 <vprintfmt+0x423>
  80171b:	0f b6 c0             	movzbl %al,%eax
  80171e:	ff 24 85 20 25 80 00 	jmp    *0x802520(,%eax,4)
  801725:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801728:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80172c:	eb d9                	jmp    801707 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80172e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801731:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801735:	eb d0                	jmp    801707 <vprintfmt+0x54>
  801737:	0f b6 d2             	movzbl %dl,%edx
  80173a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80173d:	b8 00 00 00 00       	mov    $0x0,%eax
  801742:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801745:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801748:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80174c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80174f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801752:	83 f9 09             	cmp    $0x9,%ecx
  801755:	77 55                	ja     8017ac <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  801757:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80175a:	eb e9                	jmp    801745 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80175c:	8b 45 14             	mov    0x14(%ebp),%eax
  80175f:	8b 00                	mov    (%eax),%eax
  801761:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801764:	8b 45 14             	mov    0x14(%ebp),%eax
  801767:	8d 40 04             	lea    0x4(%eax),%eax
  80176a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80176d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801770:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801774:	79 91                	jns    801707 <vprintfmt+0x54>
				width = precision, precision = -1;
  801776:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801779:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80177c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801783:	eb 82                	jmp    801707 <vprintfmt+0x54>
  801785:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801788:	85 d2                	test   %edx,%edx
  80178a:	b8 00 00 00 00       	mov    $0x0,%eax
  80178f:	0f 49 c2             	cmovns %edx,%eax
  801792:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801795:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801798:	e9 6a ff ff ff       	jmp    801707 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80179d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8017a0:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8017a7:	e9 5b ff ff ff       	jmp    801707 <vprintfmt+0x54>
  8017ac:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8017af:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017b2:	eb bc                	jmp    801770 <vprintfmt+0xbd>
			lflag++;
  8017b4:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8017b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017ba:	e9 48 ff ff ff       	jmp    801707 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8017bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8017c2:	8d 78 04             	lea    0x4(%eax),%edi
  8017c5:	83 ec 08             	sub    $0x8,%esp
  8017c8:	53                   	push   %ebx
  8017c9:	ff 30                	push   (%eax)
  8017cb:	ff d6                	call   *%esi
			break;
  8017cd:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017d0:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017d3:	e9 9d 02 00 00       	jmp    801a75 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8017d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8017db:	8d 78 04             	lea    0x4(%eax),%edi
  8017de:	8b 10                	mov    (%eax),%edx
  8017e0:	89 d0                	mov    %edx,%eax
  8017e2:	f7 d8                	neg    %eax
  8017e4:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017e7:	83 f8 0f             	cmp    $0xf,%eax
  8017ea:	7f 23                	jg     80180f <vprintfmt+0x15c>
  8017ec:	8b 14 85 80 26 80 00 	mov    0x802680(,%eax,4),%edx
  8017f3:	85 d2                	test   %edx,%edx
  8017f5:	74 18                	je     80180f <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8017f7:	52                   	push   %edx
  8017f8:	68 41 23 80 00       	push   $0x802341
  8017fd:	53                   	push   %ebx
  8017fe:	56                   	push   %esi
  8017ff:	e8 92 fe ff ff       	call   801696 <printfmt>
  801804:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801807:	89 7d 14             	mov    %edi,0x14(%ebp)
  80180a:	e9 66 02 00 00       	jmp    801a75 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80180f:	50                   	push   %eax
  801810:	68 fb 23 80 00       	push   $0x8023fb
  801815:	53                   	push   %ebx
  801816:	56                   	push   %esi
  801817:	e8 7a fe ff ff       	call   801696 <printfmt>
  80181c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80181f:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801822:	e9 4e 02 00 00       	jmp    801a75 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  801827:	8b 45 14             	mov    0x14(%ebp),%eax
  80182a:	83 c0 04             	add    $0x4,%eax
  80182d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801830:	8b 45 14             	mov    0x14(%ebp),%eax
  801833:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801835:	85 d2                	test   %edx,%edx
  801837:	b8 f4 23 80 00       	mov    $0x8023f4,%eax
  80183c:	0f 45 c2             	cmovne %edx,%eax
  80183f:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801842:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801846:	7e 06                	jle    80184e <vprintfmt+0x19b>
  801848:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80184c:	75 0d                	jne    80185b <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80184e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801851:	89 c7                	mov    %eax,%edi
  801853:	03 45 e0             	add    -0x20(%ebp),%eax
  801856:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801859:	eb 55                	jmp    8018b0 <vprintfmt+0x1fd>
  80185b:	83 ec 08             	sub    $0x8,%esp
  80185e:	ff 75 d8             	push   -0x28(%ebp)
  801861:	ff 75 cc             	push   -0x34(%ebp)
  801864:	e8 0a 03 00 00       	call   801b73 <strnlen>
  801869:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80186c:	29 c1                	sub    %eax,%ecx
  80186e:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801871:	83 c4 10             	add    $0x10,%esp
  801874:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  801876:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80187a:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80187d:	eb 0f                	jmp    80188e <vprintfmt+0x1db>
					putch(padc, putdat);
  80187f:	83 ec 08             	sub    $0x8,%esp
  801882:	53                   	push   %ebx
  801883:	ff 75 e0             	push   -0x20(%ebp)
  801886:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801888:	83 ef 01             	sub    $0x1,%edi
  80188b:	83 c4 10             	add    $0x10,%esp
  80188e:	85 ff                	test   %edi,%edi
  801890:	7f ed                	jg     80187f <vprintfmt+0x1cc>
  801892:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801895:	85 d2                	test   %edx,%edx
  801897:	b8 00 00 00 00       	mov    $0x0,%eax
  80189c:	0f 49 c2             	cmovns %edx,%eax
  80189f:	29 c2                	sub    %eax,%edx
  8018a1:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8018a4:	eb a8                	jmp    80184e <vprintfmt+0x19b>
					putch(ch, putdat);
  8018a6:	83 ec 08             	sub    $0x8,%esp
  8018a9:	53                   	push   %ebx
  8018aa:	52                   	push   %edx
  8018ab:	ff d6                	call   *%esi
  8018ad:	83 c4 10             	add    $0x10,%esp
  8018b0:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018b3:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018b5:	83 c7 01             	add    $0x1,%edi
  8018b8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018bc:	0f be d0             	movsbl %al,%edx
  8018bf:	85 d2                	test   %edx,%edx
  8018c1:	74 4b                	je     80190e <vprintfmt+0x25b>
  8018c3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018c7:	78 06                	js     8018cf <vprintfmt+0x21c>
  8018c9:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018cd:	78 1e                	js     8018ed <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8018cf:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018d3:	74 d1                	je     8018a6 <vprintfmt+0x1f3>
  8018d5:	0f be c0             	movsbl %al,%eax
  8018d8:	83 e8 20             	sub    $0x20,%eax
  8018db:	83 f8 5e             	cmp    $0x5e,%eax
  8018de:	76 c6                	jbe    8018a6 <vprintfmt+0x1f3>
					putch('?', putdat);
  8018e0:	83 ec 08             	sub    $0x8,%esp
  8018e3:	53                   	push   %ebx
  8018e4:	6a 3f                	push   $0x3f
  8018e6:	ff d6                	call   *%esi
  8018e8:	83 c4 10             	add    $0x10,%esp
  8018eb:	eb c3                	jmp    8018b0 <vprintfmt+0x1fd>
  8018ed:	89 cf                	mov    %ecx,%edi
  8018ef:	eb 0e                	jmp    8018ff <vprintfmt+0x24c>
				putch(' ', putdat);
  8018f1:	83 ec 08             	sub    $0x8,%esp
  8018f4:	53                   	push   %ebx
  8018f5:	6a 20                	push   $0x20
  8018f7:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8018f9:	83 ef 01             	sub    $0x1,%edi
  8018fc:	83 c4 10             	add    $0x10,%esp
  8018ff:	85 ff                	test   %edi,%edi
  801901:	7f ee                	jg     8018f1 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  801903:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801906:	89 45 14             	mov    %eax,0x14(%ebp)
  801909:	e9 67 01 00 00       	jmp    801a75 <vprintfmt+0x3c2>
  80190e:	89 cf                	mov    %ecx,%edi
  801910:	eb ed                	jmp    8018ff <vprintfmt+0x24c>
	if (lflag >= 2)
  801912:	83 f9 01             	cmp    $0x1,%ecx
  801915:	7f 1b                	jg     801932 <vprintfmt+0x27f>
	else if (lflag)
  801917:	85 c9                	test   %ecx,%ecx
  801919:	74 63                	je     80197e <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80191b:	8b 45 14             	mov    0x14(%ebp),%eax
  80191e:	8b 00                	mov    (%eax),%eax
  801920:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801923:	99                   	cltd   
  801924:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801927:	8b 45 14             	mov    0x14(%ebp),%eax
  80192a:	8d 40 04             	lea    0x4(%eax),%eax
  80192d:	89 45 14             	mov    %eax,0x14(%ebp)
  801930:	eb 17                	jmp    801949 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801932:	8b 45 14             	mov    0x14(%ebp),%eax
  801935:	8b 50 04             	mov    0x4(%eax),%edx
  801938:	8b 00                	mov    (%eax),%eax
  80193a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80193d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801940:	8b 45 14             	mov    0x14(%ebp),%eax
  801943:	8d 40 08             	lea    0x8(%eax),%eax
  801946:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801949:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80194c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80194f:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801954:	85 c9                	test   %ecx,%ecx
  801956:	0f 89 ff 00 00 00    	jns    801a5b <vprintfmt+0x3a8>
				putch('-', putdat);
  80195c:	83 ec 08             	sub    $0x8,%esp
  80195f:	53                   	push   %ebx
  801960:	6a 2d                	push   $0x2d
  801962:	ff d6                	call   *%esi
				num = -(long long) num;
  801964:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801967:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80196a:	f7 da                	neg    %edx
  80196c:	83 d1 00             	adc    $0x0,%ecx
  80196f:	f7 d9                	neg    %ecx
  801971:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801974:	bf 0a 00 00 00       	mov    $0xa,%edi
  801979:	e9 dd 00 00 00       	jmp    801a5b <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80197e:	8b 45 14             	mov    0x14(%ebp),%eax
  801981:	8b 00                	mov    (%eax),%eax
  801983:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801986:	99                   	cltd   
  801987:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80198a:	8b 45 14             	mov    0x14(%ebp),%eax
  80198d:	8d 40 04             	lea    0x4(%eax),%eax
  801990:	89 45 14             	mov    %eax,0x14(%ebp)
  801993:	eb b4                	jmp    801949 <vprintfmt+0x296>
	if (lflag >= 2)
  801995:	83 f9 01             	cmp    $0x1,%ecx
  801998:	7f 1e                	jg     8019b8 <vprintfmt+0x305>
	else if (lflag)
  80199a:	85 c9                	test   %ecx,%ecx
  80199c:	74 32                	je     8019d0 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80199e:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a1:	8b 10                	mov    (%eax),%edx
  8019a3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019a8:	8d 40 04             	lea    0x4(%eax),%eax
  8019ab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019ae:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8019b3:	e9 a3 00 00 00       	jmp    801a5b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8019b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8019bb:	8b 10                	mov    (%eax),%edx
  8019bd:	8b 48 04             	mov    0x4(%eax),%ecx
  8019c0:	8d 40 08             	lea    0x8(%eax),%eax
  8019c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019c6:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8019cb:	e9 8b 00 00 00       	jmp    801a5b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d3:	8b 10                	mov    (%eax),%edx
  8019d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019da:	8d 40 04             	lea    0x4(%eax),%eax
  8019dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019e0:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8019e5:	eb 74                	jmp    801a5b <vprintfmt+0x3a8>
	if (lflag >= 2)
  8019e7:	83 f9 01             	cmp    $0x1,%ecx
  8019ea:	7f 1b                	jg     801a07 <vprintfmt+0x354>
	else if (lflag)
  8019ec:	85 c9                	test   %ecx,%ecx
  8019ee:	74 2c                	je     801a1c <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8019f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f3:	8b 10                	mov    (%eax),%edx
  8019f5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019fa:	8d 40 04             	lea    0x4(%eax),%eax
  8019fd:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a00:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  801a05:	eb 54                	jmp    801a5b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801a07:	8b 45 14             	mov    0x14(%ebp),%eax
  801a0a:	8b 10                	mov    (%eax),%edx
  801a0c:	8b 48 04             	mov    0x4(%eax),%ecx
  801a0f:	8d 40 08             	lea    0x8(%eax),%eax
  801a12:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a15:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  801a1a:	eb 3f                	jmp    801a5b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801a1c:	8b 45 14             	mov    0x14(%ebp),%eax
  801a1f:	8b 10                	mov    (%eax),%edx
  801a21:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a26:	8d 40 04             	lea    0x4(%eax),%eax
  801a29:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a2c:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801a31:	eb 28                	jmp    801a5b <vprintfmt+0x3a8>
			putch('0', putdat);
  801a33:	83 ec 08             	sub    $0x8,%esp
  801a36:	53                   	push   %ebx
  801a37:	6a 30                	push   $0x30
  801a39:	ff d6                	call   *%esi
			putch('x', putdat);
  801a3b:	83 c4 08             	add    $0x8,%esp
  801a3e:	53                   	push   %ebx
  801a3f:	6a 78                	push   $0x78
  801a41:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a43:	8b 45 14             	mov    0x14(%ebp),%eax
  801a46:	8b 10                	mov    (%eax),%edx
  801a48:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a4d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a50:	8d 40 04             	lea    0x4(%eax),%eax
  801a53:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a56:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801a5b:	83 ec 0c             	sub    $0xc,%esp
  801a5e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801a62:	50                   	push   %eax
  801a63:	ff 75 e0             	push   -0x20(%ebp)
  801a66:	57                   	push   %edi
  801a67:	51                   	push   %ecx
  801a68:	52                   	push   %edx
  801a69:	89 da                	mov    %ebx,%edx
  801a6b:	89 f0                	mov    %esi,%eax
  801a6d:	e8 5e fb ff ff       	call   8015d0 <printnum>
			break;
  801a72:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801a75:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a78:	e9 54 fc ff ff       	jmp    8016d1 <vprintfmt+0x1e>
	if (lflag >= 2)
  801a7d:	83 f9 01             	cmp    $0x1,%ecx
  801a80:	7f 1b                	jg     801a9d <vprintfmt+0x3ea>
	else if (lflag)
  801a82:	85 c9                	test   %ecx,%ecx
  801a84:	74 2c                	je     801ab2 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801a86:	8b 45 14             	mov    0x14(%ebp),%eax
  801a89:	8b 10                	mov    (%eax),%edx
  801a8b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a90:	8d 40 04             	lea    0x4(%eax),%eax
  801a93:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a96:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  801a9b:	eb be                	jmp    801a5b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801a9d:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa0:	8b 10                	mov    (%eax),%edx
  801aa2:	8b 48 04             	mov    0x4(%eax),%ecx
  801aa5:	8d 40 08             	lea    0x8(%eax),%eax
  801aa8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801aab:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  801ab0:	eb a9                	jmp    801a5b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801ab2:	8b 45 14             	mov    0x14(%ebp),%eax
  801ab5:	8b 10                	mov    (%eax),%edx
  801ab7:	b9 00 00 00 00       	mov    $0x0,%ecx
  801abc:	8d 40 04             	lea    0x4(%eax),%eax
  801abf:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ac2:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  801ac7:	eb 92                	jmp    801a5b <vprintfmt+0x3a8>
			putch(ch, putdat);
  801ac9:	83 ec 08             	sub    $0x8,%esp
  801acc:	53                   	push   %ebx
  801acd:	6a 25                	push   $0x25
  801acf:	ff d6                	call   *%esi
			break;
  801ad1:	83 c4 10             	add    $0x10,%esp
  801ad4:	eb 9f                	jmp    801a75 <vprintfmt+0x3c2>
			putch('%', putdat);
  801ad6:	83 ec 08             	sub    $0x8,%esp
  801ad9:	53                   	push   %ebx
  801ada:	6a 25                	push   $0x25
  801adc:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ade:	83 c4 10             	add    $0x10,%esp
  801ae1:	89 f8                	mov    %edi,%eax
  801ae3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801ae7:	74 05                	je     801aee <vprintfmt+0x43b>
  801ae9:	83 e8 01             	sub    $0x1,%eax
  801aec:	eb f5                	jmp    801ae3 <vprintfmt+0x430>
  801aee:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801af1:	eb 82                	jmp    801a75 <vprintfmt+0x3c2>

00801af3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801af3:	55                   	push   %ebp
  801af4:	89 e5                	mov    %esp,%ebp
  801af6:	83 ec 18             	sub    $0x18,%esp
  801af9:	8b 45 08             	mov    0x8(%ebp),%eax
  801afc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801aff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b02:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b06:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b09:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b10:	85 c0                	test   %eax,%eax
  801b12:	74 26                	je     801b3a <vsnprintf+0x47>
  801b14:	85 d2                	test   %edx,%edx
  801b16:	7e 22                	jle    801b3a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b18:	ff 75 14             	push   0x14(%ebp)
  801b1b:	ff 75 10             	push   0x10(%ebp)
  801b1e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b21:	50                   	push   %eax
  801b22:	68 79 16 80 00       	push   $0x801679
  801b27:	e8 87 fb ff ff       	call   8016b3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b2f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b35:	83 c4 10             	add    $0x10,%esp
}
  801b38:	c9                   	leave  
  801b39:	c3                   	ret    
		return -E_INVAL;
  801b3a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b3f:	eb f7                	jmp    801b38 <vsnprintf+0x45>

00801b41 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b41:	55                   	push   %ebp
  801b42:	89 e5                	mov    %esp,%ebp
  801b44:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b47:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b4a:	50                   	push   %eax
  801b4b:	ff 75 10             	push   0x10(%ebp)
  801b4e:	ff 75 0c             	push   0xc(%ebp)
  801b51:	ff 75 08             	push   0x8(%ebp)
  801b54:	e8 9a ff ff ff       	call   801af3 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b59:	c9                   	leave  
  801b5a:	c3                   	ret    

00801b5b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b5b:	55                   	push   %ebp
  801b5c:	89 e5                	mov    %esp,%ebp
  801b5e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b61:	b8 00 00 00 00       	mov    $0x0,%eax
  801b66:	eb 03                	jmp    801b6b <strlen+0x10>
		n++;
  801b68:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801b6b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b6f:	75 f7                	jne    801b68 <strlen+0xd>
	return n;
}
  801b71:	5d                   	pop    %ebp
  801b72:	c3                   	ret    

00801b73 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b79:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b7c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b81:	eb 03                	jmp    801b86 <strnlen+0x13>
		n++;
  801b83:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b86:	39 d0                	cmp    %edx,%eax
  801b88:	74 08                	je     801b92 <strnlen+0x1f>
  801b8a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801b8e:	75 f3                	jne    801b83 <strnlen+0x10>
  801b90:	89 c2                	mov    %eax,%edx
	return n;
}
  801b92:	89 d0                	mov    %edx,%eax
  801b94:	5d                   	pop    %ebp
  801b95:	c3                   	ret    

00801b96 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b96:	55                   	push   %ebp
  801b97:	89 e5                	mov    %esp,%ebp
  801b99:	53                   	push   %ebx
  801b9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b9d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801ba0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ba5:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801ba9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801bac:	83 c0 01             	add    $0x1,%eax
  801baf:	84 d2                	test   %dl,%dl
  801bb1:	75 f2                	jne    801ba5 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801bb3:	89 c8                	mov    %ecx,%eax
  801bb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb8:	c9                   	leave  
  801bb9:	c3                   	ret    

00801bba <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	53                   	push   %ebx
  801bbe:	83 ec 10             	sub    $0x10,%esp
  801bc1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bc4:	53                   	push   %ebx
  801bc5:	e8 91 ff ff ff       	call   801b5b <strlen>
  801bca:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801bcd:	ff 75 0c             	push   0xc(%ebp)
  801bd0:	01 d8                	add    %ebx,%eax
  801bd2:	50                   	push   %eax
  801bd3:	e8 be ff ff ff       	call   801b96 <strcpy>
	return dst;
}
  801bd8:	89 d8                	mov    %ebx,%eax
  801bda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bdd:	c9                   	leave  
  801bde:	c3                   	ret    

00801bdf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	56                   	push   %esi
  801be3:	53                   	push   %ebx
  801be4:	8b 75 08             	mov    0x8(%ebp),%esi
  801be7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bea:	89 f3                	mov    %esi,%ebx
  801bec:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bef:	89 f0                	mov    %esi,%eax
  801bf1:	eb 0f                	jmp    801c02 <strncpy+0x23>
		*dst++ = *src;
  801bf3:	83 c0 01             	add    $0x1,%eax
  801bf6:	0f b6 0a             	movzbl (%edx),%ecx
  801bf9:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bfc:	80 f9 01             	cmp    $0x1,%cl
  801bff:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801c02:	39 d8                	cmp    %ebx,%eax
  801c04:	75 ed                	jne    801bf3 <strncpy+0x14>
	}
	return ret;
}
  801c06:	89 f0                	mov    %esi,%eax
  801c08:	5b                   	pop    %ebx
  801c09:	5e                   	pop    %esi
  801c0a:	5d                   	pop    %ebp
  801c0b:	c3                   	ret    

00801c0c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c0c:	55                   	push   %ebp
  801c0d:	89 e5                	mov    %esp,%ebp
  801c0f:	56                   	push   %esi
  801c10:	53                   	push   %ebx
  801c11:	8b 75 08             	mov    0x8(%ebp),%esi
  801c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c17:	8b 55 10             	mov    0x10(%ebp),%edx
  801c1a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c1c:	85 d2                	test   %edx,%edx
  801c1e:	74 21                	je     801c41 <strlcpy+0x35>
  801c20:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c24:	89 f2                	mov    %esi,%edx
  801c26:	eb 09                	jmp    801c31 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c28:	83 c1 01             	add    $0x1,%ecx
  801c2b:	83 c2 01             	add    $0x1,%edx
  801c2e:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801c31:	39 c2                	cmp    %eax,%edx
  801c33:	74 09                	je     801c3e <strlcpy+0x32>
  801c35:	0f b6 19             	movzbl (%ecx),%ebx
  801c38:	84 db                	test   %bl,%bl
  801c3a:	75 ec                	jne    801c28 <strlcpy+0x1c>
  801c3c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801c3e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c41:	29 f0                	sub    %esi,%eax
}
  801c43:	5b                   	pop    %ebx
  801c44:	5e                   	pop    %esi
  801c45:	5d                   	pop    %ebp
  801c46:	c3                   	ret    

00801c47 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c47:	55                   	push   %ebp
  801c48:	89 e5                	mov    %esp,%ebp
  801c4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c4d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c50:	eb 06                	jmp    801c58 <strcmp+0x11>
		p++, q++;
  801c52:	83 c1 01             	add    $0x1,%ecx
  801c55:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801c58:	0f b6 01             	movzbl (%ecx),%eax
  801c5b:	84 c0                	test   %al,%al
  801c5d:	74 04                	je     801c63 <strcmp+0x1c>
  801c5f:	3a 02                	cmp    (%edx),%al
  801c61:	74 ef                	je     801c52 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c63:	0f b6 c0             	movzbl %al,%eax
  801c66:	0f b6 12             	movzbl (%edx),%edx
  801c69:	29 d0                	sub    %edx,%eax
}
  801c6b:	5d                   	pop    %ebp
  801c6c:	c3                   	ret    

00801c6d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	53                   	push   %ebx
  801c71:	8b 45 08             	mov    0x8(%ebp),%eax
  801c74:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c77:	89 c3                	mov    %eax,%ebx
  801c79:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c7c:	eb 06                	jmp    801c84 <strncmp+0x17>
		n--, p++, q++;
  801c7e:	83 c0 01             	add    $0x1,%eax
  801c81:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801c84:	39 d8                	cmp    %ebx,%eax
  801c86:	74 18                	je     801ca0 <strncmp+0x33>
  801c88:	0f b6 08             	movzbl (%eax),%ecx
  801c8b:	84 c9                	test   %cl,%cl
  801c8d:	74 04                	je     801c93 <strncmp+0x26>
  801c8f:	3a 0a                	cmp    (%edx),%cl
  801c91:	74 eb                	je     801c7e <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c93:	0f b6 00             	movzbl (%eax),%eax
  801c96:	0f b6 12             	movzbl (%edx),%edx
  801c99:	29 d0                	sub    %edx,%eax
}
  801c9b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c9e:	c9                   	leave  
  801c9f:	c3                   	ret    
		return 0;
  801ca0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ca5:	eb f4                	jmp    801c9b <strncmp+0x2e>

00801ca7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801ca7:	55                   	push   %ebp
  801ca8:	89 e5                	mov    %esp,%ebp
  801caa:	8b 45 08             	mov    0x8(%ebp),%eax
  801cad:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cb1:	eb 03                	jmp    801cb6 <strchr+0xf>
  801cb3:	83 c0 01             	add    $0x1,%eax
  801cb6:	0f b6 10             	movzbl (%eax),%edx
  801cb9:	84 d2                	test   %dl,%dl
  801cbb:	74 06                	je     801cc3 <strchr+0x1c>
		if (*s == c)
  801cbd:	38 ca                	cmp    %cl,%dl
  801cbf:	75 f2                	jne    801cb3 <strchr+0xc>
  801cc1:	eb 05                	jmp    801cc8 <strchr+0x21>
			return (char *) s;
	return 0;
  801cc3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801cc8:	5d                   	pop    %ebp
  801cc9:	c3                   	ret    

00801cca <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cca:	55                   	push   %ebp
  801ccb:	89 e5                	mov    %esp,%ebp
  801ccd:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cd4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cd7:	38 ca                	cmp    %cl,%dl
  801cd9:	74 09                	je     801ce4 <strfind+0x1a>
  801cdb:	84 d2                	test   %dl,%dl
  801cdd:	74 05                	je     801ce4 <strfind+0x1a>
	for (; *s; s++)
  801cdf:	83 c0 01             	add    $0x1,%eax
  801ce2:	eb f0                	jmp    801cd4 <strfind+0xa>
			break;
	return (char *) s;
}
  801ce4:	5d                   	pop    %ebp
  801ce5:	c3                   	ret    

00801ce6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801ce6:	55                   	push   %ebp
  801ce7:	89 e5                	mov    %esp,%ebp
  801ce9:	57                   	push   %edi
  801cea:	56                   	push   %esi
  801ceb:	53                   	push   %ebx
  801cec:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cf2:	85 c9                	test   %ecx,%ecx
  801cf4:	74 2f                	je     801d25 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cf6:	89 f8                	mov    %edi,%eax
  801cf8:	09 c8                	or     %ecx,%eax
  801cfa:	a8 03                	test   $0x3,%al
  801cfc:	75 21                	jne    801d1f <memset+0x39>
		c &= 0xFF;
  801cfe:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d02:	89 d0                	mov    %edx,%eax
  801d04:	c1 e0 08             	shl    $0x8,%eax
  801d07:	89 d3                	mov    %edx,%ebx
  801d09:	c1 e3 18             	shl    $0x18,%ebx
  801d0c:	89 d6                	mov    %edx,%esi
  801d0e:	c1 e6 10             	shl    $0x10,%esi
  801d11:	09 f3                	or     %esi,%ebx
  801d13:	09 da                	or     %ebx,%edx
  801d15:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801d17:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801d1a:	fc                   	cld    
  801d1b:	f3 ab                	rep stos %eax,%es:(%edi)
  801d1d:	eb 06                	jmp    801d25 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d1f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d22:	fc                   	cld    
  801d23:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d25:	89 f8                	mov    %edi,%eax
  801d27:	5b                   	pop    %ebx
  801d28:	5e                   	pop    %esi
  801d29:	5f                   	pop    %edi
  801d2a:	5d                   	pop    %ebp
  801d2b:	c3                   	ret    

00801d2c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d2c:	55                   	push   %ebp
  801d2d:	89 e5                	mov    %esp,%ebp
  801d2f:	57                   	push   %edi
  801d30:	56                   	push   %esi
  801d31:	8b 45 08             	mov    0x8(%ebp),%eax
  801d34:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d37:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d3a:	39 c6                	cmp    %eax,%esi
  801d3c:	73 32                	jae    801d70 <memmove+0x44>
  801d3e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d41:	39 c2                	cmp    %eax,%edx
  801d43:	76 2b                	jbe    801d70 <memmove+0x44>
		s += n;
		d += n;
  801d45:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d48:	89 d6                	mov    %edx,%esi
  801d4a:	09 fe                	or     %edi,%esi
  801d4c:	09 ce                	or     %ecx,%esi
  801d4e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d54:	75 0e                	jne    801d64 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d56:	83 ef 04             	sub    $0x4,%edi
  801d59:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d5c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801d5f:	fd                   	std    
  801d60:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d62:	eb 09                	jmp    801d6d <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d64:	83 ef 01             	sub    $0x1,%edi
  801d67:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801d6a:	fd                   	std    
  801d6b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d6d:	fc                   	cld    
  801d6e:	eb 1a                	jmp    801d8a <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d70:	89 f2                	mov    %esi,%edx
  801d72:	09 c2                	or     %eax,%edx
  801d74:	09 ca                	or     %ecx,%edx
  801d76:	f6 c2 03             	test   $0x3,%dl
  801d79:	75 0a                	jne    801d85 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801d7b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801d7e:	89 c7                	mov    %eax,%edi
  801d80:	fc                   	cld    
  801d81:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d83:	eb 05                	jmp    801d8a <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801d85:	89 c7                	mov    %eax,%edi
  801d87:	fc                   	cld    
  801d88:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d8a:	5e                   	pop    %esi
  801d8b:	5f                   	pop    %edi
  801d8c:	5d                   	pop    %ebp
  801d8d:	c3                   	ret    

00801d8e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d8e:	55                   	push   %ebp
  801d8f:	89 e5                	mov    %esp,%ebp
  801d91:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d94:	ff 75 10             	push   0x10(%ebp)
  801d97:	ff 75 0c             	push   0xc(%ebp)
  801d9a:	ff 75 08             	push   0x8(%ebp)
  801d9d:	e8 8a ff ff ff       	call   801d2c <memmove>
}
  801da2:	c9                   	leave  
  801da3:	c3                   	ret    

00801da4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801da4:	55                   	push   %ebp
  801da5:	89 e5                	mov    %esp,%ebp
  801da7:	56                   	push   %esi
  801da8:	53                   	push   %ebx
  801da9:	8b 45 08             	mov    0x8(%ebp),%eax
  801dac:	8b 55 0c             	mov    0xc(%ebp),%edx
  801daf:	89 c6                	mov    %eax,%esi
  801db1:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801db4:	eb 06                	jmp    801dbc <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801db6:	83 c0 01             	add    $0x1,%eax
  801db9:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801dbc:	39 f0                	cmp    %esi,%eax
  801dbe:	74 14                	je     801dd4 <memcmp+0x30>
		if (*s1 != *s2)
  801dc0:	0f b6 08             	movzbl (%eax),%ecx
  801dc3:	0f b6 1a             	movzbl (%edx),%ebx
  801dc6:	38 d9                	cmp    %bl,%cl
  801dc8:	74 ec                	je     801db6 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801dca:	0f b6 c1             	movzbl %cl,%eax
  801dcd:	0f b6 db             	movzbl %bl,%ebx
  801dd0:	29 d8                	sub    %ebx,%eax
  801dd2:	eb 05                	jmp    801dd9 <memcmp+0x35>
	}

	return 0;
  801dd4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dd9:	5b                   	pop    %ebx
  801dda:	5e                   	pop    %esi
  801ddb:	5d                   	pop    %ebp
  801ddc:	c3                   	ret    

00801ddd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801ddd:	55                   	push   %ebp
  801dde:	89 e5                	mov    %esp,%ebp
  801de0:	8b 45 08             	mov    0x8(%ebp),%eax
  801de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801de6:	89 c2                	mov    %eax,%edx
  801de8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801deb:	eb 03                	jmp    801df0 <memfind+0x13>
  801ded:	83 c0 01             	add    $0x1,%eax
  801df0:	39 d0                	cmp    %edx,%eax
  801df2:	73 04                	jae    801df8 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801df4:	38 08                	cmp    %cl,(%eax)
  801df6:	75 f5                	jne    801ded <memfind+0x10>
			break;
	return (void *) s;
}
  801df8:	5d                   	pop    %ebp
  801df9:	c3                   	ret    

00801dfa <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dfa:	55                   	push   %ebp
  801dfb:	89 e5                	mov    %esp,%ebp
  801dfd:	57                   	push   %edi
  801dfe:	56                   	push   %esi
  801dff:	53                   	push   %ebx
  801e00:	8b 55 08             	mov    0x8(%ebp),%edx
  801e03:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e06:	eb 03                	jmp    801e0b <strtol+0x11>
		s++;
  801e08:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801e0b:	0f b6 02             	movzbl (%edx),%eax
  801e0e:	3c 20                	cmp    $0x20,%al
  801e10:	74 f6                	je     801e08 <strtol+0xe>
  801e12:	3c 09                	cmp    $0x9,%al
  801e14:	74 f2                	je     801e08 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801e16:	3c 2b                	cmp    $0x2b,%al
  801e18:	74 2a                	je     801e44 <strtol+0x4a>
	int neg = 0;
  801e1a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801e1f:	3c 2d                	cmp    $0x2d,%al
  801e21:	74 2b                	je     801e4e <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e23:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e29:	75 0f                	jne    801e3a <strtol+0x40>
  801e2b:	80 3a 30             	cmpb   $0x30,(%edx)
  801e2e:	74 28                	je     801e58 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e30:	85 db                	test   %ebx,%ebx
  801e32:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e37:	0f 44 d8             	cmove  %eax,%ebx
  801e3a:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e3f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801e42:	eb 46                	jmp    801e8a <strtol+0x90>
		s++;
  801e44:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801e47:	bf 00 00 00 00       	mov    $0x0,%edi
  801e4c:	eb d5                	jmp    801e23 <strtol+0x29>
		s++, neg = 1;
  801e4e:	83 c2 01             	add    $0x1,%edx
  801e51:	bf 01 00 00 00       	mov    $0x1,%edi
  801e56:	eb cb                	jmp    801e23 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e58:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e5c:	74 0e                	je     801e6c <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801e5e:	85 db                	test   %ebx,%ebx
  801e60:	75 d8                	jne    801e3a <strtol+0x40>
		s++, base = 8;
  801e62:	83 c2 01             	add    $0x1,%edx
  801e65:	bb 08 00 00 00       	mov    $0x8,%ebx
  801e6a:	eb ce                	jmp    801e3a <strtol+0x40>
		s += 2, base = 16;
  801e6c:	83 c2 02             	add    $0x2,%edx
  801e6f:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e74:	eb c4                	jmp    801e3a <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801e76:	0f be c0             	movsbl %al,%eax
  801e79:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801e7c:	3b 45 10             	cmp    0x10(%ebp),%eax
  801e7f:	7d 3a                	jge    801ebb <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801e81:	83 c2 01             	add    $0x1,%edx
  801e84:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801e88:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801e8a:	0f b6 02             	movzbl (%edx),%eax
  801e8d:	8d 70 d0             	lea    -0x30(%eax),%esi
  801e90:	89 f3                	mov    %esi,%ebx
  801e92:	80 fb 09             	cmp    $0x9,%bl
  801e95:	76 df                	jbe    801e76 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  801e97:	8d 70 9f             	lea    -0x61(%eax),%esi
  801e9a:	89 f3                	mov    %esi,%ebx
  801e9c:	80 fb 19             	cmp    $0x19,%bl
  801e9f:	77 08                	ja     801ea9 <strtol+0xaf>
			dig = *s - 'a' + 10;
  801ea1:	0f be c0             	movsbl %al,%eax
  801ea4:	83 e8 57             	sub    $0x57,%eax
  801ea7:	eb d3                	jmp    801e7c <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801ea9:	8d 70 bf             	lea    -0x41(%eax),%esi
  801eac:	89 f3                	mov    %esi,%ebx
  801eae:	80 fb 19             	cmp    $0x19,%bl
  801eb1:	77 08                	ja     801ebb <strtol+0xc1>
			dig = *s - 'A' + 10;
  801eb3:	0f be c0             	movsbl %al,%eax
  801eb6:	83 e8 37             	sub    $0x37,%eax
  801eb9:	eb c1                	jmp    801e7c <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801ebb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ebf:	74 05                	je     801ec6 <strtol+0xcc>
		*endptr = (char *) s;
  801ec1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec4:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801ec6:	89 c8                	mov    %ecx,%eax
  801ec8:	f7 d8                	neg    %eax
  801eca:	85 ff                	test   %edi,%edi
  801ecc:	0f 45 c8             	cmovne %eax,%ecx
}
  801ecf:	89 c8                	mov    %ecx,%eax
  801ed1:	5b                   	pop    %ebx
  801ed2:	5e                   	pop    %esi
  801ed3:	5f                   	pop    %edi
  801ed4:	5d                   	pop    %ebp
  801ed5:	c3                   	ret    

00801ed6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ed6:	55                   	push   %ebp
  801ed7:	89 e5                	mov    %esp,%ebp
  801ed9:	56                   	push   %esi
  801eda:	53                   	push   %ebx
  801edb:	8b 75 08             	mov    0x8(%ebp),%esi
  801ede:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ee1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801eeb:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801eee:	83 ec 0c             	sub    $0xc,%esp
  801ef1:	50                   	push   %eax
  801ef2:	e8 3a e4 ff ff       	call   800331 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ef7:	83 c4 10             	add    $0x10,%esp
  801efa:	85 f6                	test   %esi,%esi
  801efc:	74 14                	je     801f12 <ipc_recv+0x3c>
  801efe:	ba 00 00 00 00       	mov    $0x0,%edx
  801f03:	85 c0                	test   %eax,%eax
  801f05:	78 09                	js     801f10 <ipc_recv+0x3a>
  801f07:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f0d:	8b 52 74             	mov    0x74(%edx),%edx
  801f10:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801f12:	85 db                	test   %ebx,%ebx
  801f14:	74 14                	je     801f2a <ipc_recv+0x54>
  801f16:	ba 00 00 00 00       	mov    $0x0,%edx
  801f1b:	85 c0                	test   %eax,%eax
  801f1d:	78 09                	js     801f28 <ipc_recv+0x52>
  801f1f:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f25:	8b 52 78             	mov    0x78(%edx),%edx
  801f28:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f2a:	85 c0                	test   %eax,%eax
  801f2c:	78 08                	js     801f36 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801f2e:	a1 00 40 80 00       	mov    0x804000,%eax
  801f33:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f36:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f39:	5b                   	pop    %ebx
  801f3a:	5e                   	pop    %esi
  801f3b:	5d                   	pop    %ebp
  801f3c:	c3                   	ret    

00801f3d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f3d:	55                   	push   %ebp
  801f3e:	89 e5                	mov    %esp,%ebp
  801f40:	57                   	push   %edi
  801f41:	56                   	push   %esi
  801f42:	53                   	push   %ebx
  801f43:	83 ec 0c             	sub    $0xc,%esp
  801f46:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f49:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f4f:	85 db                	test   %ebx,%ebx
  801f51:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f56:	0f 44 d8             	cmove  %eax,%ebx
  801f59:	eb 05                	jmp    801f60 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f5b:	e8 02 e2 ff ff       	call   800162 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f60:	ff 75 14             	push   0x14(%ebp)
  801f63:	53                   	push   %ebx
  801f64:	56                   	push   %esi
  801f65:	57                   	push   %edi
  801f66:	e8 a3 e3 ff ff       	call   80030e <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f6b:	83 c4 10             	add    $0x10,%esp
  801f6e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f71:	74 e8                	je     801f5b <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f73:	85 c0                	test   %eax,%eax
  801f75:	78 08                	js     801f7f <ipc_send+0x42>
	}while (r<0);

}
  801f77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f7a:	5b                   	pop    %ebx
  801f7b:	5e                   	pop    %esi
  801f7c:	5f                   	pop    %edi
  801f7d:	5d                   	pop    %ebp
  801f7e:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f7f:	50                   	push   %eax
  801f80:	68 df 26 80 00       	push   $0x8026df
  801f85:	6a 3d                	push   $0x3d
  801f87:	68 f3 26 80 00       	push   $0x8026f3
  801f8c:	e8 50 f5 ff ff       	call   8014e1 <_panic>

00801f91 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f91:	55                   	push   %ebp
  801f92:	89 e5                	mov    %esp,%ebp
  801f94:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f97:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f9c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f9f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fa5:	8b 52 50             	mov    0x50(%edx),%edx
  801fa8:	39 ca                	cmp    %ecx,%edx
  801faa:	74 11                	je     801fbd <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801fac:	83 c0 01             	add    $0x1,%eax
  801faf:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fb4:	75 e6                	jne    801f9c <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801fb6:	b8 00 00 00 00       	mov    $0x0,%eax
  801fbb:	eb 0b                	jmp    801fc8 <ipc_find_env+0x37>
			return envs[i].env_id;
  801fbd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fc0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fc5:	8b 40 48             	mov    0x48(%eax),%eax
}
  801fc8:	5d                   	pop    %ebp
  801fc9:	c3                   	ret    

00801fca <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fca:	55                   	push   %ebp
  801fcb:	89 e5                	mov    %esp,%ebp
  801fcd:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fd0:	89 c2                	mov    %eax,%edx
  801fd2:	c1 ea 16             	shr    $0x16,%edx
  801fd5:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fdc:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fe1:	f6 c1 01             	test   $0x1,%cl
  801fe4:	74 1c                	je     802002 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801fe6:	c1 e8 0c             	shr    $0xc,%eax
  801fe9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ff0:	a8 01                	test   $0x1,%al
  801ff2:	74 0e                	je     802002 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ff4:	c1 e8 0c             	shr    $0xc,%eax
  801ff7:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801ffe:	ef 
  801fff:	0f b7 d2             	movzwl %dx,%edx
}
  802002:	89 d0                	mov    %edx,%eax
  802004:	5d                   	pop    %ebp
  802005:	c3                   	ret    
  802006:	66 90                	xchg   %ax,%ax
  802008:	66 90                	xchg   %ax,%ax
  80200a:	66 90                	xchg   %ax,%ax
  80200c:	66 90                	xchg   %ax,%ax
  80200e:	66 90                	xchg   %ax,%ax

00802010 <__udivdi3>:
  802010:	f3 0f 1e fb          	endbr32 
  802014:	55                   	push   %ebp
  802015:	57                   	push   %edi
  802016:	56                   	push   %esi
  802017:	53                   	push   %ebx
  802018:	83 ec 1c             	sub    $0x1c,%esp
  80201b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80201f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802023:	8b 74 24 34          	mov    0x34(%esp),%esi
  802027:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80202b:	85 c0                	test   %eax,%eax
  80202d:	75 19                	jne    802048 <__udivdi3+0x38>
  80202f:	39 f3                	cmp    %esi,%ebx
  802031:	76 4d                	jbe    802080 <__udivdi3+0x70>
  802033:	31 ff                	xor    %edi,%edi
  802035:	89 e8                	mov    %ebp,%eax
  802037:	89 f2                	mov    %esi,%edx
  802039:	f7 f3                	div    %ebx
  80203b:	89 fa                	mov    %edi,%edx
  80203d:	83 c4 1c             	add    $0x1c,%esp
  802040:	5b                   	pop    %ebx
  802041:	5e                   	pop    %esi
  802042:	5f                   	pop    %edi
  802043:	5d                   	pop    %ebp
  802044:	c3                   	ret    
  802045:	8d 76 00             	lea    0x0(%esi),%esi
  802048:	39 f0                	cmp    %esi,%eax
  80204a:	76 14                	jbe    802060 <__udivdi3+0x50>
  80204c:	31 ff                	xor    %edi,%edi
  80204e:	31 c0                	xor    %eax,%eax
  802050:	89 fa                	mov    %edi,%edx
  802052:	83 c4 1c             	add    $0x1c,%esp
  802055:	5b                   	pop    %ebx
  802056:	5e                   	pop    %esi
  802057:	5f                   	pop    %edi
  802058:	5d                   	pop    %ebp
  802059:	c3                   	ret    
  80205a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802060:	0f bd f8             	bsr    %eax,%edi
  802063:	83 f7 1f             	xor    $0x1f,%edi
  802066:	75 48                	jne    8020b0 <__udivdi3+0xa0>
  802068:	39 f0                	cmp    %esi,%eax
  80206a:	72 06                	jb     802072 <__udivdi3+0x62>
  80206c:	31 c0                	xor    %eax,%eax
  80206e:	39 eb                	cmp    %ebp,%ebx
  802070:	77 de                	ja     802050 <__udivdi3+0x40>
  802072:	b8 01 00 00 00       	mov    $0x1,%eax
  802077:	eb d7                	jmp    802050 <__udivdi3+0x40>
  802079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802080:	89 d9                	mov    %ebx,%ecx
  802082:	85 db                	test   %ebx,%ebx
  802084:	75 0b                	jne    802091 <__udivdi3+0x81>
  802086:	b8 01 00 00 00       	mov    $0x1,%eax
  80208b:	31 d2                	xor    %edx,%edx
  80208d:	f7 f3                	div    %ebx
  80208f:	89 c1                	mov    %eax,%ecx
  802091:	31 d2                	xor    %edx,%edx
  802093:	89 f0                	mov    %esi,%eax
  802095:	f7 f1                	div    %ecx
  802097:	89 c6                	mov    %eax,%esi
  802099:	89 e8                	mov    %ebp,%eax
  80209b:	89 f7                	mov    %esi,%edi
  80209d:	f7 f1                	div    %ecx
  80209f:	89 fa                	mov    %edi,%edx
  8020a1:	83 c4 1c             	add    $0x1c,%esp
  8020a4:	5b                   	pop    %ebx
  8020a5:	5e                   	pop    %esi
  8020a6:	5f                   	pop    %edi
  8020a7:	5d                   	pop    %ebp
  8020a8:	c3                   	ret    
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	89 f9                	mov    %edi,%ecx
  8020b2:	ba 20 00 00 00       	mov    $0x20,%edx
  8020b7:	29 fa                	sub    %edi,%edx
  8020b9:	d3 e0                	shl    %cl,%eax
  8020bb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020bf:	89 d1                	mov    %edx,%ecx
  8020c1:	89 d8                	mov    %ebx,%eax
  8020c3:	d3 e8                	shr    %cl,%eax
  8020c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020c9:	09 c1                	or     %eax,%ecx
  8020cb:	89 f0                	mov    %esi,%eax
  8020cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020d1:	89 f9                	mov    %edi,%ecx
  8020d3:	d3 e3                	shl    %cl,%ebx
  8020d5:	89 d1                	mov    %edx,%ecx
  8020d7:	d3 e8                	shr    %cl,%eax
  8020d9:	89 f9                	mov    %edi,%ecx
  8020db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020df:	89 eb                	mov    %ebp,%ebx
  8020e1:	d3 e6                	shl    %cl,%esi
  8020e3:	89 d1                	mov    %edx,%ecx
  8020e5:	d3 eb                	shr    %cl,%ebx
  8020e7:	09 f3                	or     %esi,%ebx
  8020e9:	89 c6                	mov    %eax,%esi
  8020eb:	89 f2                	mov    %esi,%edx
  8020ed:	89 d8                	mov    %ebx,%eax
  8020ef:	f7 74 24 08          	divl   0x8(%esp)
  8020f3:	89 d6                	mov    %edx,%esi
  8020f5:	89 c3                	mov    %eax,%ebx
  8020f7:	f7 64 24 0c          	mull   0xc(%esp)
  8020fb:	39 d6                	cmp    %edx,%esi
  8020fd:	72 19                	jb     802118 <__udivdi3+0x108>
  8020ff:	89 f9                	mov    %edi,%ecx
  802101:	d3 e5                	shl    %cl,%ebp
  802103:	39 c5                	cmp    %eax,%ebp
  802105:	73 04                	jae    80210b <__udivdi3+0xfb>
  802107:	39 d6                	cmp    %edx,%esi
  802109:	74 0d                	je     802118 <__udivdi3+0x108>
  80210b:	89 d8                	mov    %ebx,%eax
  80210d:	31 ff                	xor    %edi,%edi
  80210f:	e9 3c ff ff ff       	jmp    802050 <__udivdi3+0x40>
  802114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802118:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80211b:	31 ff                	xor    %edi,%edi
  80211d:	e9 2e ff ff ff       	jmp    802050 <__udivdi3+0x40>
  802122:	66 90                	xchg   %ax,%ax
  802124:	66 90                	xchg   %ax,%ax
  802126:	66 90                	xchg   %ax,%ax
  802128:	66 90                	xchg   %ax,%ax
  80212a:	66 90                	xchg   %ax,%ax
  80212c:	66 90                	xchg   %ax,%ax
  80212e:	66 90                	xchg   %ax,%ax

00802130 <__umoddi3>:
  802130:	f3 0f 1e fb          	endbr32 
  802134:	55                   	push   %ebp
  802135:	57                   	push   %edi
  802136:	56                   	push   %esi
  802137:	53                   	push   %ebx
  802138:	83 ec 1c             	sub    $0x1c,%esp
  80213b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80213f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802143:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802147:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80214b:	89 f0                	mov    %esi,%eax
  80214d:	89 da                	mov    %ebx,%edx
  80214f:	85 ff                	test   %edi,%edi
  802151:	75 15                	jne    802168 <__umoddi3+0x38>
  802153:	39 dd                	cmp    %ebx,%ebp
  802155:	76 39                	jbe    802190 <__umoddi3+0x60>
  802157:	f7 f5                	div    %ebp
  802159:	89 d0                	mov    %edx,%eax
  80215b:	31 d2                	xor    %edx,%edx
  80215d:	83 c4 1c             	add    $0x1c,%esp
  802160:	5b                   	pop    %ebx
  802161:	5e                   	pop    %esi
  802162:	5f                   	pop    %edi
  802163:	5d                   	pop    %ebp
  802164:	c3                   	ret    
  802165:	8d 76 00             	lea    0x0(%esi),%esi
  802168:	39 df                	cmp    %ebx,%edi
  80216a:	77 f1                	ja     80215d <__umoddi3+0x2d>
  80216c:	0f bd cf             	bsr    %edi,%ecx
  80216f:	83 f1 1f             	xor    $0x1f,%ecx
  802172:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802176:	75 40                	jne    8021b8 <__umoddi3+0x88>
  802178:	39 df                	cmp    %ebx,%edi
  80217a:	72 04                	jb     802180 <__umoddi3+0x50>
  80217c:	39 f5                	cmp    %esi,%ebp
  80217e:	77 dd                	ja     80215d <__umoddi3+0x2d>
  802180:	89 da                	mov    %ebx,%edx
  802182:	89 f0                	mov    %esi,%eax
  802184:	29 e8                	sub    %ebp,%eax
  802186:	19 fa                	sbb    %edi,%edx
  802188:	eb d3                	jmp    80215d <__umoddi3+0x2d>
  80218a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802190:	89 e9                	mov    %ebp,%ecx
  802192:	85 ed                	test   %ebp,%ebp
  802194:	75 0b                	jne    8021a1 <__umoddi3+0x71>
  802196:	b8 01 00 00 00       	mov    $0x1,%eax
  80219b:	31 d2                	xor    %edx,%edx
  80219d:	f7 f5                	div    %ebp
  80219f:	89 c1                	mov    %eax,%ecx
  8021a1:	89 d8                	mov    %ebx,%eax
  8021a3:	31 d2                	xor    %edx,%edx
  8021a5:	f7 f1                	div    %ecx
  8021a7:	89 f0                	mov    %esi,%eax
  8021a9:	f7 f1                	div    %ecx
  8021ab:	89 d0                	mov    %edx,%eax
  8021ad:	31 d2                	xor    %edx,%edx
  8021af:	eb ac                	jmp    80215d <__umoddi3+0x2d>
  8021b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021bc:	ba 20 00 00 00       	mov    $0x20,%edx
  8021c1:	29 c2                	sub    %eax,%edx
  8021c3:	89 c1                	mov    %eax,%ecx
  8021c5:	89 e8                	mov    %ebp,%eax
  8021c7:	d3 e7                	shl    %cl,%edi
  8021c9:	89 d1                	mov    %edx,%ecx
  8021cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021cf:	d3 e8                	shr    %cl,%eax
  8021d1:	89 c1                	mov    %eax,%ecx
  8021d3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021d7:	09 f9                	or     %edi,%ecx
  8021d9:	89 df                	mov    %ebx,%edi
  8021db:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021df:	89 c1                	mov    %eax,%ecx
  8021e1:	d3 e5                	shl    %cl,%ebp
  8021e3:	89 d1                	mov    %edx,%ecx
  8021e5:	d3 ef                	shr    %cl,%edi
  8021e7:	89 c1                	mov    %eax,%ecx
  8021e9:	89 f0                	mov    %esi,%eax
  8021eb:	d3 e3                	shl    %cl,%ebx
  8021ed:	89 d1                	mov    %edx,%ecx
  8021ef:	89 fa                	mov    %edi,%edx
  8021f1:	d3 e8                	shr    %cl,%eax
  8021f3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021f8:	09 d8                	or     %ebx,%eax
  8021fa:	f7 74 24 08          	divl   0x8(%esp)
  8021fe:	89 d3                	mov    %edx,%ebx
  802200:	d3 e6                	shl    %cl,%esi
  802202:	f7 e5                	mul    %ebp
  802204:	89 c7                	mov    %eax,%edi
  802206:	89 d1                	mov    %edx,%ecx
  802208:	39 d3                	cmp    %edx,%ebx
  80220a:	72 06                	jb     802212 <__umoddi3+0xe2>
  80220c:	75 0e                	jne    80221c <__umoddi3+0xec>
  80220e:	39 c6                	cmp    %eax,%esi
  802210:	73 0a                	jae    80221c <__umoddi3+0xec>
  802212:	29 e8                	sub    %ebp,%eax
  802214:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802218:	89 d1                	mov    %edx,%ecx
  80221a:	89 c7                	mov    %eax,%edi
  80221c:	89 f5                	mov    %esi,%ebp
  80221e:	8b 74 24 04          	mov    0x4(%esp),%esi
  802222:	29 fd                	sub    %edi,%ebp
  802224:	19 cb                	sbb    %ecx,%ebx
  802226:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80222b:	89 d8                	mov    %ebx,%eax
  80222d:	d3 e0                	shl    %cl,%eax
  80222f:	89 f1                	mov    %esi,%ecx
  802231:	d3 ed                	shr    %cl,%ebp
  802233:	d3 eb                	shr    %cl,%ebx
  802235:	09 e8                	or     %ebp,%eax
  802237:	89 da                	mov    %ebx,%edx
  802239:	83 c4 1c             	add    $0x1c,%esp
  80223c:	5b                   	pop    %ebx
  80223d:	5e                   	pop    %esi
  80223e:	5f                   	pop    %edi
  80223f:	5d                   	pop    %ebp
  802240:	c3                   	ret    
