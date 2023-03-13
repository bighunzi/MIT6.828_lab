
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
  800042:	e8 3a 01 00 00       	call   800181 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 20 00 10 f0       	push   $0xf0100020
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
  8000b1:	e8 88 04 00 00       	call   80053e <close_all>
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
  800132:	68 8a 1d 80 00       	push   $0x801d8a
  800137:	6a 2a                	push   $0x2a
  800139:	68 a7 1d 80 00       	push   $0x801da7
  80013e:	e8 d0 0e 00 00       	call   801013 <_panic>

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
  8001b3:	68 8a 1d 80 00       	push   $0x801d8a
  8001b8:	6a 2a                	push   $0x2a
  8001ba:	68 a7 1d 80 00       	push   $0x801da7
  8001bf:	e8 4f 0e 00 00       	call   801013 <_panic>

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
  8001f5:	68 8a 1d 80 00       	push   $0x801d8a
  8001fa:	6a 2a                	push   $0x2a
  8001fc:	68 a7 1d 80 00       	push   $0x801da7
  800201:	e8 0d 0e 00 00       	call   801013 <_panic>

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
  800237:	68 8a 1d 80 00       	push   $0x801d8a
  80023c:	6a 2a                	push   $0x2a
  80023e:	68 a7 1d 80 00       	push   $0x801da7
  800243:	e8 cb 0d 00 00       	call   801013 <_panic>

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
  800279:	68 8a 1d 80 00       	push   $0x801d8a
  80027e:	6a 2a                	push   $0x2a
  800280:	68 a7 1d 80 00       	push   $0x801da7
  800285:	e8 89 0d 00 00       	call   801013 <_panic>

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
  8002bb:	68 8a 1d 80 00       	push   $0x801d8a
  8002c0:	6a 2a                	push   $0x2a
  8002c2:	68 a7 1d 80 00       	push   $0x801da7
  8002c7:	e8 47 0d 00 00       	call   801013 <_panic>

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
  8002fd:	68 8a 1d 80 00       	push   $0x801d8a
  800302:	6a 2a                	push   $0x2a
  800304:	68 a7 1d 80 00       	push   $0x801da7
  800309:	e8 05 0d 00 00       	call   801013 <_panic>

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
  800361:	68 8a 1d 80 00       	push   $0x801d8a
  800366:	6a 2a                	push   $0x2a
  800368:	68 a7 1d 80 00       	push   $0x801da7
  80036d:	e8 a1 0c 00 00       	call   801013 <_panic>

00800372 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800375:	8b 45 08             	mov    0x8(%ebp),%eax
  800378:	05 00 00 00 30       	add    $0x30000000,%eax
  80037d:	c1 e8 0c             	shr    $0xc,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80038d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800392:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a1:	89 c2                	mov    %eax,%edx
  8003a3:	c1 ea 16             	shr    $0x16,%edx
  8003a6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003ad:	f6 c2 01             	test   $0x1,%dl
  8003b0:	74 29                	je     8003db <fd_alloc+0x42>
  8003b2:	89 c2                	mov    %eax,%edx
  8003b4:	c1 ea 0c             	shr    $0xc,%edx
  8003b7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003be:	f6 c2 01             	test   $0x1,%dl
  8003c1:	74 18                	je     8003db <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8003c3:	05 00 10 00 00       	add    $0x1000,%eax
  8003c8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003cd:	75 d2                	jne    8003a1 <fd_alloc+0x8>
  8003cf:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8003d4:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8003d9:	eb 05                	jmp    8003e0 <fd_alloc+0x47>
			return 0;
  8003db:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8003e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003e3:	89 02                	mov    %eax,(%edx)
}
  8003e5:	89 c8                	mov    %ecx,%eax
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    

008003e9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ef:	83 f8 1f             	cmp    $0x1f,%eax
  8003f2:	77 30                	ja     800424 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f4:	c1 e0 0c             	shl    $0xc,%eax
  8003f7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003fc:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800402:	f6 c2 01             	test   $0x1,%dl
  800405:	74 24                	je     80042b <fd_lookup+0x42>
  800407:	89 c2                	mov    %eax,%edx
  800409:	c1 ea 0c             	shr    $0xc,%edx
  80040c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800413:	f6 c2 01             	test   $0x1,%dl
  800416:	74 1a                	je     800432 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800418:	8b 55 0c             	mov    0xc(%ebp),%edx
  80041b:	89 02                	mov    %eax,(%edx)
	return 0;
  80041d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800422:	5d                   	pop    %ebp
  800423:	c3                   	ret    
		return -E_INVAL;
  800424:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800429:	eb f7                	jmp    800422 <fd_lookup+0x39>
		return -E_INVAL;
  80042b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800430:	eb f0                	jmp    800422 <fd_lookup+0x39>
  800432:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800437:	eb e9                	jmp    800422 <fd_lookup+0x39>

00800439 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800439:	55                   	push   %ebp
  80043a:	89 e5                	mov    %esp,%ebp
  80043c:	53                   	push   %ebx
  80043d:	83 ec 04             	sub    $0x4,%esp
  800440:	8b 55 08             	mov    0x8(%ebp),%edx
  800443:	b8 34 1e 80 00       	mov    $0x801e34,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800448:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80044d:	39 13                	cmp    %edx,(%ebx)
  80044f:	74 32                	je     800483 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800451:	83 c0 04             	add    $0x4,%eax
  800454:	8b 18                	mov    (%eax),%ebx
  800456:	85 db                	test   %ebx,%ebx
  800458:	75 f3                	jne    80044d <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80045a:	a1 00 40 80 00       	mov    0x804000,%eax
  80045f:	8b 40 48             	mov    0x48(%eax),%eax
  800462:	83 ec 04             	sub    $0x4,%esp
  800465:	52                   	push   %edx
  800466:	50                   	push   %eax
  800467:	68 b8 1d 80 00       	push   $0x801db8
  80046c:	e8 7d 0c 00 00       	call   8010ee <cprintf>
	*dev = 0;
	return -E_INVAL;
  800471:	83 c4 10             	add    $0x10,%esp
  800474:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800479:	8b 55 0c             	mov    0xc(%ebp),%edx
  80047c:	89 1a                	mov    %ebx,(%edx)
}
  80047e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800481:	c9                   	leave  
  800482:	c3                   	ret    
			return 0;
  800483:	b8 00 00 00 00       	mov    $0x0,%eax
  800488:	eb ef                	jmp    800479 <dev_lookup+0x40>

0080048a <fd_close>:
{
  80048a:	55                   	push   %ebp
  80048b:	89 e5                	mov    %esp,%ebp
  80048d:	57                   	push   %edi
  80048e:	56                   	push   %esi
  80048f:	53                   	push   %ebx
  800490:	83 ec 24             	sub    $0x24,%esp
  800493:	8b 75 08             	mov    0x8(%ebp),%esi
  800496:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800499:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80049c:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80049d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004a3:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004a6:	50                   	push   %eax
  8004a7:	e8 3d ff ff ff       	call   8003e9 <fd_lookup>
  8004ac:	89 c3                	mov    %eax,%ebx
  8004ae:	83 c4 10             	add    $0x10,%esp
  8004b1:	85 c0                	test   %eax,%eax
  8004b3:	78 05                	js     8004ba <fd_close+0x30>
	    || fd != fd2)
  8004b5:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004b8:	74 16                	je     8004d0 <fd_close+0x46>
		return (must_exist ? r : 0);
  8004ba:	89 f8                	mov    %edi,%eax
  8004bc:	84 c0                	test   %al,%al
  8004be:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c3:	0f 44 d8             	cmove  %eax,%ebx
}
  8004c6:	89 d8                	mov    %ebx,%eax
  8004c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004cb:	5b                   	pop    %ebx
  8004cc:	5e                   	pop    %esi
  8004cd:	5f                   	pop    %edi
  8004ce:	5d                   	pop    %ebp
  8004cf:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004d6:	50                   	push   %eax
  8004d7:	ff 36                	push   (%esi)
  8004d9:	e8 5b ff ff ff       	call   800439 <dev_lookup>
  8004de:	89 c3                	mov    %eax,%ebx
  8004e0:	83 c4 10             	add    $0x10,%esp
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	78 1a                	js     800501 <fd_close+0x77>
		if (dev->dev_close)
  8004e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ea:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8004ed:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004f2:	85 c0                	test   %eax,%eax
  8004f4:	74 0b                	je     800501 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8004f6:	83 ec 0c             	sub    $0xc,%esp
  8004f9:	56                   	push   %esi
  8004fa:	ff d0                	call   *%eax
  8004fc:	89 c3                	mov    %eax,%ebx
  8004fe:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800501:	83 ec 08             	sub    $0x8,%esp
  800504:	56                   	push   %esi
  800505:	6a 00                	push   $0x0
  800507:	e8 fa fc ff ff       	call   800206 <sys_page_unmap>
	return r;
  80050c:	83 c4 10             	add    $0x10,%esp
  80050f:	eb b5                	jmp    8004c6 <fd_close+0x3c>

00800511 <close>:

int
close(int fdnum)
{
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800517:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051a:	50                   	push   %eax
  80051b:	ff 75 08             	push   0x8(%ebp)
  80051e:	e8 c6 fe ff ff       	call   8003e9 <fd_lookup>
  800523:	83 c4 10             	add    $0x10,%esp
  800526:	85 c0                	test   %eax,%eax
  800528:	79 02                	jns    80052c <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  80052a:	c9                   	leave  
  80052b:	c3                   	ret    
		return fd_close(fd, 1);
  80052c:	83 ec 08             	sub    $0x8,%esp
  80052f:	6a 01                	push   $0x1
  800531:	ff 75 f4             	push   -0xc(%ebp)
  800534:	e8 51 ff ff ff       	call   80048a <fd_close>
  800539:	83 c4 10             	add    $0x10,%esp
  80053c:	eb ec                	jmp    80052a <close+0x19>

0080053e <close_all>:

void
close_all(void)
{
  80053e:	55                   	push   %ebp
  80053f:	89 e5                	mov    %esp,%ebp
  800541:	53                   	push   %ebx
  800542:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800545:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80054a:	83 ec 0c             	sub    $0xc,%esp
  80054d:	53                   	push   %ebx
  80054e:	e8 be ff ff ff       	call   800511 <close>
	for (i = 0; i < MAXFD; i++)
  800553:	83 c3 01             	add    $0x1,%ebx
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	83 fb 20             	cmp    $0x20,%ebx
  80055c:	75 ec                	jne    80054a <close_all+0xc>
}
  80055e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800561:	c9                   	leave  
  800562:	c3                   	ret    

00800563 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800563:	55                   	push   %ebp
  800564:	89 e5                	mov    %esp,%ebp
  800566:	57                   	push   %edi
  800567:	56                   	push   %esi
  800568:	53                   	push   %ebx
  800569:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80056c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80056f:	50                   	push   %eax
  800570:	ff 75 08             	push   0x8(%ebp)
  800573:	e8 71 fe ff ff       	call   8003e9 <fd_lookup>
  800578:	89 c3                	mov    %eax,%ebx
  80057a:	83 c4 10             	add    $0x10,%esp
  80057d:	85 c0                	test   %eax,%eax
  80057f:	78 7f                	js     800600 <dup+0x9d>
		return r;
	close(newfdnum);
  800581:	83 ec 0c             	sub    $0xc,%esp
  800584:	ff 75 0c             	push   0xc(%ebp)
  800587:	e8 85 ff ff ff       	call   800511 <close>

	newfd = INDEX2FD(newfdnum);
  80058c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80058f:	c1 e6 0c             	shl    $0xc,%esi
  800592:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800598:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80059b:	89 3c 24             	mov    %edi,(%esp)
  80059e:	e8 df fd ff ff       	call   800382 <fd2data>
  8005a3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005a5:	89 34 24             	mov    %esi,(%esp)
  8005a8:	e8 d5 fd ff ff       	call   800382 <fd2data>
  8005ad:	83 c4 10             	add    $0x10,%esp
  8005b0:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b3:	89 d8                	mov    %ebx,%eax
  8005b5:	c1 e8 16             	shr    $0x16,%eax
  8005b8:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005bf:	a8 01                	test   $0x1,%al
  8005c1:	74 11                	je     8005d4 <dup+0x71>
  8005c3:	89 d8                	mov    %ebx,%eax
  8005c5:	c1 e8 0c             	shr    $0xc,%eax
  8005c8:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005cf:	f6 c2 01             	test   $0x1,%dl
  8005d2:	75 36                	jne    80060a <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d4:	89 f8                	mov    %edi,%eax
  8005d6:	c1 e8 0c             	shr    $0xc,%eax
  8005d9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e0:	83 ec 0c             	sub    $0xc,%esp
  8005e3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e8:	50                   	push   %eax
  8005e9:	56                   	push   %esi
  8005ea:	6a 00                	push   $0x0
  8005ec:	57                   	push   %edi
  8005ed:	6a 00                	push   $0x0
  8005ef:	e8 d0 fb ff ff       	call   8001c4 <sys_page_map>
  8005f4:	89 c3                	mov    %eax,%ebx
  8005f6:	83 c4 20             	add    $0x20,%esp
  8005f9:	85 c0                	test   %eax,%eax
  8005fb:	78 33                	js     800630 <dup+0xcd>
		goto err;

	return newfdnum;
  8005fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800600:	89 d8                	mov    %ebx,%eax
  800602:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800605:	5b                   	pop    %ebx
  800606:	5e                   	pop    %esi
  800607:	5f                   	pop    %edi
  800608:	5d                   	pop    %ebp
  800609:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80060a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800611:	83 ec 0c             	sub    $0xc,%esp
  800614:	25 07 0e 00 00       	and    $0xe07,%eax
  800619:	50                   	push   %eax
  80061a:	ff 75 d4             	push   -0x2c(%ebp)
  80061d:	6a 00                	push   $0x0
  80061f:	53                   	push   %ebx
  800620:	6a 00                	push   $0x0
  800622:	e8 9d fb ff ff       	call   8001c4 <sys_page_map>
  800627:	89 c3                	mov    %eax,%ebx
  800629:	83 c4 20             	add    $0x20,%esp
  80062c:	85 c0                	test   %eax,%eax
  80062e:	79 a4                	jns    8005d4 <dup+0x71>
	sys_page_unmap(0, newfd);
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	56                   	push   %esi
  800634:	6a 00                	push   $0x0
  800636:	e8 cb fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80063b:	83 c4 08             	add    $0x8,%esp
  80063e:	ff 75 d4             	push   -0x2c(%ebp)
  800641:	6a 00                	push   $0x0
  800643:	e8 be fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  800648:	83 c4 10             	add    $0x10,%esp
  80064b:	eb b3                	jmp    800600 <dup+0x9d>

0080064d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80064d:	55                   	push   %ebp
  80064e:	89 e5                	mov    %esp,%ebp
  800650:	56                   	push   %esi
  800651:	53                   	push   %ebx
  800652:	83 ec 18             	sub    $0x18,%esp
  800655:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800658:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80065b:	50                   	push   %eax
  80065c:	56                   	push   %esi
  80065d:	e8 87 fd ff ff       	call   8003e9 <fd_lookup>
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	85 c0                	test   %eax,%eax
  800667:	78 3c                	js     8006a5 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800669:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80066c:	83 ec 08             	sub    $0x8,%esp
  80066f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800672:	50                   	push   %eax
  800673:	ff 33                	push   (%ebx)
  800675:	e8 bf fd ff ff       	call   800439 <dev_lookup>
  80067a:	83 c4 10             	add    $0x10,%esp
  80067d:	85 c0                	test   %eax,%eax
  80067f:	78 24                	js     8006a5 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800681:	8b 43 08             	mov    0x8(%ebx),%eax
  800684:	83 e0 03             	and    $0x3,%eax
  800687:	83 f8 01             	cmp    $0x1,%eax
  80068a:	74 20                	je     8006ac <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80068c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068f:	8b 40 08             	mov    0x8(%eax),%eax
  800692:	85 c0                	test   %eax,%eax
  800694:	74 37                	je     8006cd <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800696:	83 ec 04             	sub    $0x4,%esp
  800699:	ff 75 10             	push   0x10(%ebp)
  80069c:	ff 75 0c             	push   0xc(%ebp)
  80069f:	53                   	push   %ebx
  8006a0:	ff d0                	call   *%eax
  8006a2:	83 c4 10             	add    $0x10,%esp
}
  8006a5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006a8:	5b                   	pop    %ebx
  8006a9:	5e                   	pop    %esi
  8006aa:	5d                   	pop    %ebp
  8006ab:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006ac:	a1 00 40 80 00       	mov    0x804000,%eax
  8006b1:	8b 40 48             	mov    0x48(%eax),%eax
  8006b4:	83 ec 04             	sub    $0x4,%esp
  8006b7:	56                   	push   %esi
  8006b8:	50                   	push   %eax
  8006b9:	68 f9 1d 80 00       	push   $0x801df9
  8006be:	e8 2b 0a 00 00       	call   8010ee <cprintf>
		return -E_INVAL;
  8006c3:	83 c4 10             	add    $0x10,%esp
  8006c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006cb:	eb d8                	jmp    8006a5 <read+0x58>
		return -E_NOT_SUPP;
  8006cd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006d2:	eb d1                	jmp    8006a5 <read+0x58>

008006d4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006d4:	55                   	push   %ebp
  8006d5:	89 e5                	mov    %esp,%ebp
  8006d7:	57                   	push   %edi
  8006d8:	56                   	push   %esi
  8006d9:	53                   	push   %ebx
  8006da:	83 ec 0c             	sub    $0xc,%esp
  8006dd:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006e0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006e3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006e8:	eb 02                	jmp    8006ec <readn+0x18>
  8006ea:	01 c3                	add    %eax,%ebx
  8006ec:	39 f3                	cmp    %esi,%ebx
  8006ee:	73 21                	jae    800711 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f0:	83 ec 04             	sub    $0x4,%esp
  8006f3:	89 f0                	mov    %esi,%eax
  8006f5:	29 d8                	sub    %ebx,%eax
  8006f7:	50                   	push   %eax
  8006f8:	89 d8                	mov    %ebx,%eax
  8006fa:	03 45 0c             	add    0xc(%ebp),%eax
  8006fd:	50                   	push   %eax
  8006fe:	57                   	push   %edi
  8006ff:	e8 49 ff ff ff       	call   80064d <read>
		if (m < 0)
  800704:	83 c4 10             	add    $0x10,%esp
  800707:	85 c0                	test   %eax,%eax
  800709:	78 04                	js     80070f <readn+0x3b>
			return m;
		if (m == 0)
  80070b:	75 dd                	jne    8006ea <readn+0x16>
  80070d:	eb 02                	jmp    800711 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80070f:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800711:	89 d8                	mov    %ebx,%eax
  800713:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800716:	5b                   	pop    %ebx
  800717:	5e                   	pop    %esi
  800718:	5f                   	pop    %edi
  800719:	5d                   	pop    %ebp
  80071a:	c3                   	ret    

0080071b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80071b:	55                   	push   %ebp
  80071c:	89 e5                	mov    %esp,%ebp
  80071e:	56                   	push   %esi
  80071f:	53                   	push   %ebx
  800720:	83 ec 18             	sub    $0x18,%esp
  800723:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800726:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800729:	50                   	push   %eax
  80072a:	53                   	push   %ebx
  80072b:	e8 b9 fc ff ff       	call   8003e9 <fd_lookup>
  800730:	83 c4 10             	add    $0x10,%esp
  800733:	85 c0                	test   %eax,%eax
  800735:	78 37                	js     80076e <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800737:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80073a:	83 ec 08             	sub    $0x8,%esp
  80073d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800740:	50                   	push   %eax
  800741:	ff 36                	push   (%esi)
  800743:	e8 f1 fc ff ff       	call   800439 <dev_lookup>
  800748:	83 c4 10             	add    $0x10,%esp
  80074b:	85 c0                	test   %eax,%eax
  80074d:	78 1f                	js     80076e <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80074f:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800753:	74 20                	je     800775 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800755:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800758:	8b 40 0c             	mov    0xc(%eax),%eax
  80075b:	85 c0                	test   %eax,%eax
  80075d:	74 37                	je     800796 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80075f:	83 ec 04             	sub    $0x4,%esp
  800762:	ff 75 10             	push   0x10(%ebp)
  800765:	ff 75 0c             	push   0xc(%ebp)
  800768:	56                   	push   %esi
  800769:	ff d0                	call   *%eax
  80076b:	83 c4 10             	add    $0x10,%esp
}
  80076e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800771:	5b                   	pop    %ebx
  800772:	5e                   	pop    %esi
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800775:	a1 00 40 80 00       	mov    0x804000,%eax
  80077a:	8b 40 48             	mov    0x48(%eax),%eax
  80077d:	83 ec 04             	sub    $0x4,%esp
  800780:	53                   	push   %ebx
  800781:	50                   	push   %eax
  800782:	68 15 1e 80 00       	push   $0x801e15
  800787:	e8 62 09 00 00       	call   8010ee <cprintf>
		return -E_INVAL;
  80078c:	83 c4 10             	add    $0x10,%esp
  80078f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800794:	eb d8                	jmp    80076e <write+0x53>
		return -E_NOT_SUPP;
  800796:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80079b:	eb d1                	jmp    80076e <write+0x53>

0080079d <seek>:

int
seek(int fdnum, off_t offset)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007a6:	50                   	push   %eax
  8007a7:	ff 75 08             	push   0x8(%ebp)
  8007aa:	e8 3a fc ff ff       	call   8003e9 <fd_lookup>
  8007af:	83 c4 10             	add    $0x10,%esp
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	78 0e                	js     8007c4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007bc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	56                   	push   %esi
  8007ca:	53                   	push   %ebx
  8007cb:	83 ec 18             	sub    $0x18,%esp
  8007ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007d4:	50                   	push   %eax
  8007d5:	53                   	push   %ebx
  8007d6:	e8 0e fc ff ff       	call   8003e9 <fd_lookup>
  8007db:	83 c4 10             	add    $0x10,%esp
  8007de:	85 c0                	test   %eax,%eax
  8007e0:	78 34                	js     800816 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007e2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8007e5:	83 ec 08             	sub    $0x8,%esp
  8007e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007eb:	50                   	push   %eax
  8007ec:	ff 36                	push   (%esi)
  8007ee:	e8 46 fc ff ff       	call   800439 <dev_lookup>
  8007f3:	83 c4 10             	add    $0x10,%esp
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	78 1c                	js     800816 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007fa:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8007fe:	74 1d                	je     80081d <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800800:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800803:	8b 40 18             	mov    0x18(%eax),%eax
  800806:	85 c0                	test   %eax,%eax
  800808:	74 34                	je     80083e <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80080a:	83 ec 08             	sub    $0x8,%esp
  80080d:	ff 75 0c             	push   0xc(%ebp)
  800810:	56                   	push   %esi
  800811:	ff d0                	call   *%eax
  800813:	83 c4 10             	add    $0x10,%esp
}
  800816:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800819:	5b                   	pop    %ebx
  80081a:	5e                   	pop    %esi
  80081b:	5d                   	pop    %ebp
  80081c:	c3                   	ret    
			thisenv->env_id, fdnum);
  80081d:	a1 00 40 80 00       	mov    0x804000,%eax
  800822:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800825:	83 ec 04             	sub    $0x4,%esp
  800828:	53                   	push   %ebx
  800829:	50                   	push   %eax
  80082a:	68 d8 1d 80 00       	push   $0x801dd8
  80082f:	e8 ba 08 00 00       	call   8010ee <cprintf>
		return -E_INVAL;
  800834:	83 c4 10             	add    $0x10,%esp
  800837:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80083c:	eb d8                	jmp    800816 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80083e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800843:	eb d1                	jmp    800816 <ftruncate+0x50>

00800845 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	56                   	push   %esi
  800849:	53                   	push   %ebx
  80084a:	83 ec 18             	sub    $0x18,%esp
  80084d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800850:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800853:	50                   	push   %eax
  800854:	ff 75 08             	push   0x8(%ebp)
  800857:	e8 8d fb ff ff       	call   8003e9 <fd_lookup>
  80085c:	83 c4 10             	add    $0x10,%esp
  80085f:	85 c0                	test   %eax,%eax
  800861:	78 49                	js     8008ac <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800863:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800866:	83 ec 08             	sub    $0x8,%esp
  800869:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80086c:	50                   	push   %eax
  80086d:	ff 36                	push   (%esi)
  80086f:	e8 c5 fb ff ff       	call   800439 <dev_lookup>
  800874:	83 c4 10             	add    $0x10,%esp
  800877:	85 c0                	test   %eax,%eax
  800879:	78 31                	js     8008ac <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80087b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800882:	74 2f                	je     8008b3 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800884:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800887:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80088e:	00 00 00 
	stat->st_isdir = 0;
  800891:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800898:	00 00 00 
	stat->st_dev = dev;
  80089b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a1:	83 ec 08             	sub    $0x8,%esp
  8008a4:	53                   	push   %ebx
  8008a5:	56                   	push   %esi
  8008a6:	ff 50 14             	call   *0x14(%eax)
  8008a9:	83 c4 10             	add    $0x10,%esp
}
  8008ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008af:	5b                   	pop    %ebx
  8008b0:	5e                   	pop    %esi
  8008b1:	5d                   	pop    %ebp
  8008b2:	c3                   	ret    
		return -E_NOT_SUPP;
  8008b3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008b8:	eb f2                	jmp    8008ac <fstat+0x67>

008008ba <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	56                   	push   %esi
  8008be:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008bf:	83 ec 08             	sub    $0x8,%esp
  8008c2:	6a 00                	push   $0x0
  8008c4:	ff 75 08             	push   0x8(%ebp)
  8008c7:	e8 e4 01 00 00       	call   800ab0 <open>
  8008cc:	89 c3                	mov    %eax,%ebx
  8008ce:	83 c4 10             	add    $0x10,%esp
  8008d1:	85 c0                	test   %eax,%eax
  8008d3:	78 1b                	js     8008f0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d5:	83 ec 08             	sub    $0x8,%esp
  8008d8:	ff 75 0c             	push   0xc(%ebp)
  8008db:	50                   	push   %eax
  8008dc:	e8 64 ff ff ff       	call   800845 <fstat>
  8008e1:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e3:	89 1c 24             	mov    %ebx,(%esp)
  8008e6:	e8 26 fc ff ff       	call   800511 <close>
	return r;
  8008eb:	83 c4 10             	add    $0x10,%esp
  8008ee:	89 f3                	mov    %esi,%ebx
}
  8008f0:	89 d8                	mov    %ebx,%eax
  8008f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f5:	5b                   	pop    %ebx
  8008f6:	5e                   	pop    %esi
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	56                   	push   %esi
  8008fd:	53                   	push   %ebx
  8008fe:	89 c6                	mov    %eax,%esi
  800900:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800902:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800909:	74 27                	je     800932 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80090b:	6a 07                	push   $0x7
  80090d:	68 00 50 80 00       	push   $0x805000
  800912:	56                   	push   %esi
  800913:	ff 35 00 60 80 00    	push   0x806000
  800919:	e8 51 11 00 00       	call   801a6f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80091e:	83 c4 0c             	add    $0xc,%esp
  800921:	6a 00                	push   $0x0
  800923:	53                   	push   %ebx
  800924:	6a 00                	push   $0x0
  800926:	e8 dd 10 00 00       	call   801a08 <ipc_recv>
}
  80092b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80092e:	5b                   	pop    %ebx
  80092f:	5e                   	pop    %esi
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800932:	83 ec 0c             	sub    $0xc,%esp
  800935:	6a 01                	push   $0x1
  800937:	e8 87 11 00 00       	call   801ac3 <ipc_find_env>
  80093c:	a3 00 60 80 00       	mov    %eax,0x806000
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	eb c5                	jmp    80090b <fsipc+0x12>

00800946 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800946:	55                   	push   %ebp
  800947:	89 e5                	mov    %esp,%ebp
  800949:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	8b 40 0c             	mov    0xc(%eax),%eax
  800952:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800957:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80095f:	ba 00 00 00 00       	mov    $0x0,%edx
  800964:	b8 02 00 00 00       	mov    $0x2,%eax
  800969:	e8 8b ff ff ff       	call   8008f9 <fsipc>
}
  80096e:	c9                   	leave  
  80096f:	c3                   	ret    

00800970 <devfile_flush>:
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 40 0c             	mov    0xc(%eax),%eax
  80097c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800981:	ba 00 00 00 00       	mov    $0x0,%edx
  800986:	b8 06 00 00 00       	mov    $0x6,%eax
  80098b:	e8 69 ff ff ff       	call   8008f9 <fsipc>
}
  800990:	c9                   	leave  
  800991:	c3                   	ret    

00800992 <devfile_stat>:
{
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	53                   	push   %ebx
  800996:	83 ec 04             	sub    $0x4,%esp
  800999:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a2:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ac:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b1:	e8 43 ff ff ff       	call   8008f9 <fsipc>
  8009b6:	85 c0                	test   %eax,%eax
  8009b8:	78 2c                	js     8009e6 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009ba:	83 ec 08             	sub    $0x8,%esp
  8009bd:	68 00 50 80 00       	push   $0x805000
  8009c2:	53                   	push   %ebx
  8009c3:	e8 00 0d 00 00       	call   8016c8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c8:	a1 80 50 80 00       	mov    0x805080,%eax
  8009cd:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009d3:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009de:	83 c4 10             	add    $0x10,%esp
  8009e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e9:	c9                   	leave  
  8009ea:	c3                   	ret    

008009eb <devfile_write>:
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	83 ec 0c             	sub    $0xc,%esp
  8009f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009f4:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009f9:	39 d0                	cmp    %edx,%eax
  8009fb:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800a01:	8b 52 0c             	mov    0xc(%edx),%edx
  800a04:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a0a:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a0f:	50                   	push   %eax
  800a10:	ff 75 0c             	push   0xc(%ebp)
  800a13:	68 08 50 80 00       	push   $0x805008
  800a18:	e8 41 0e 00 00       	call   80185e <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800a1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a22:	b8 04 00 00 00       	mov    $0x4,%eax
  800a27:	e8 cd fe ff ff       	call   8008f9 <fsipc>
}
  800a2c:	c9                   	leave  
  800a2d:	c3                   	ret    

00800a2e <devfile_read>:
{
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	56                   	push   %esi
  800a32:	53                   	push   %ebx
  800a33:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a36:	8b 45 08             	mov    0x8(%ebp),%eax
  800a39:	8b 40 0c             	mov    0xc(%eax),%eax
  800a3c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a41:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a47:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4c:	b8 03 00 00 00       	mov    $0x3,%eax
  800a51:	e8 a3 fe ff ff       	call   8008f9 <fsipc>
  800a56:	89 c3                	mov    %eax,%ebx
  800a58:	85 c0                	test   %eax,%eax
  800a5a:	78 1f                	js     800a7b <devfile_read+0x4d>
	assert(r <= n);
  800a5c:	39 f0                	cmp    %esi,%eax
  800a5e:	77 24                	ja     800a84 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a60:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a65:	7f 33                	jg     800a9a <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a67:	83 ec 04             	sub    $0x4,%esp
  800a6a:	50                   	push   %eax
  800a6b:	68 00 50 80 00       	push   $0x805000
  800a70:	ff 75 0c             	push   0xc(%ebp)
  800a73:	e8 e6 0d 00 00       	call   80185e <memmove>
	return r;
  800a78:	83 c4 10             	add    $0x10,%esp
}
  800a7b:	89 d8                	mov    %ebx,%eax
  800a7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    
	assert(r <= n);
  800a84:	68 44 1e 80 00       	push   $0x801e44
  800a89:	68 4b 1e 80 00       	push   $0x801e4b
  800a8e:	6a 7c                	push   $0x7c
  800a90:	68 60 1e 80 00       	push   $0x801e60
  800a95:	e8 79 05 00 00       	call   801013 <_panic>
	assert(r <= PGSIZE);
  800a9a:	68 6b 1e 80 00       	push   $0x801e6b
  800a9f:	68 4b 1e 80 00       	push   $0x801e4b
  800aa4:	6a 7d                	push   $0x7d
  800aa6:	68 60 1e 80 00       	push   $0x801e60
  800aab:	e8 63 05 00 00       	call   801013 <_panic>

00800ab0 <open>:
{
  800ab0:	55                   	push   %ebp
  800ab1:	89 e5                	mov    %esp,%ebp
  800ab3:	56                   	push   %esi
  800ab4:	53                   	push   %ebx
  800ab5:	83 ec 1c             	sub    $0x1c,%esp
  800ab8:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800abb:	56                   	push   %esi
  800abc:	e8 cc 0b 00 00       	call   80168d <strlen>
  800ac1:	83 c4 10             	add    $0x10,%esp
  800ac4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ac9:	7f 6c                	jg     800b37 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800acb:	83 ec 0c             	sub    $0xc,%esp
  800ace:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ad1:	50                   	push   %eax
  800ad2:	e8 c2 f8 ff ff       	call   800399 <fd_alloc>
  800ad7:	89 c3                	mov    %eax,%ebx
  800ad9:	83 c4 10             	add    $0x10,%esp
  800adc:	85 c0                	test   %eax,%eax
  800ade:	78 3c                	js     800b1c <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800ae0:	83 ec 08             	sub    $0x8,%esp
  800ae3:	56                   	push   %esi
  800ae4:	68 00 50 80 00       	push   $0x805000
  800ae9:	e8 da 0b 00 00       	call   8016c8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af1:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800af6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af9:	b8 01 00 00 00       	mov    $0x1,%eax
  800afe:	e8 f6 fd ff ff       	call   8008f9 <fsipc>
  800b03:	89 c3                	mov    %eax,%ebx
  800b05:	83 c4 10             	add    $0x10,%esp
  800b08:	85 c0                	test   %eax,%eax
  800b0a:	78 19                	js     800b25 <open+0x75>
	return fd2num(fd);
  800b0c:	83 ec 0c             	sub    $0xc,%esp
  800b0f:	ff 75 f4             	push   -0xc(%ebp)
  800b12:	e8 5b f8 ff ff       	call   800372 <fd2num>
  800b17:	89 c3                	mov    %eax,%ebx
  800b19:	83 c4 10             	add    $0x10,%esp
}
  800b1c:	89 d8                	mov    %ebx,%eax
  800b1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b21:	5b                   	pop    %ebx
  800b22:	5e                   	pop    %esi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    
		fd_close(fd, 0);
  800b25:	83 ec 08             	sub    $0x8,%esp
  800b28:	6a 00                	push   $0x0
  800b2a:	ff 75 f4             	push   -0xc(%ebp)
  800b2d:	e8 58 f9 ff ff       	call   80048a <fd_close>
		return r;
  800b32:	83 c4 10             	add    $0x10,%esp
  800b35:	eb e5                	jmp    800b1c <open+0x6c>
		return -E_BAD_PATH;
  800b37:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b3c:	eb de                	jmp    800b1c <open+0x6c>

00800b3e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b3e:	55                   	push   %ebp
  800b3f:	89 e5                	mov    %esp,%ebp
  800b41:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 08 00 00 00       	mov    $0x8,%eax
  800b4e:	e8 a6 fd ff ff       	call   8008f9 <fsipc>
}
  800b53:	c9                   	leave  
  800b54:	c3                   	ret    

00800b55 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	56                   	push   %esi
  800b59:	53                   	push   %ebx
  800b5a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b5d:	83 ec 0c             	sub    $0xc,%esp
  800b60:	ff 75 08             	push   0x8(%ebp)
  800b63:	e8 1a f8 ff ff       	call   800382 <fd2data>
  800b68:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b6a:	83 c4 08             	add    $0x8,%esp
  800b6d:	68 77 1e 80 00       	push   $0x801e77
  800b72:	53                   	push   %ebx
  800b73:	e8 50 0b 00 00       	call   8016c8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b78:	8b 46 04             	mov    0x4(%esi),%eax
  800b7b:	2b 06                	sub    (%esi),%eax
  800b7d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b83:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b8a:	00 00 00 
	stat->st_dev = &devpipe;
  800b8d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b94:	30 80 00 
	return 0;
}
  800b97:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 0c             	sub    $0xc,%esp
  800baa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bad:	53                   	push   %ebx
  800bae:	6a 00                	push   $0x0
  800bb0:	e8 51 f6 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bb5:	89 1c 24             	mov    %ebx,(%esp)
  800bb8:	e8 c5 f7 ff ff       	call   800382 <fd2data>
  800bbd:	83 c4 08             	add    $0x8,%esp
  800bc0:	50                   	push   %eax
  800bc1:	6a 00                	push   $0x0
  800bc3:	e8 3e f6 ff ff       	call   800206 <sys_page_unmap>
}
  800bc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bcb:	c9                   	leave  
  800bcc:	c3                   	ret    

00800bcd <_pipeisclosed>:
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 1c             	sub    $0x1c,%esp
  800bd6:	89 c7                	mov    %eax,%edi
  800bd8:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bda:	a1 00 40 80 00       	mov    0x804000,%eax
  800bdf:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800be2:	83 ec 0c             	sub    $0xc,%esp
  800be5:	57                   	push   %edi
  800be6:	e8 11 0f 00 00       	call   801afc <pageref>
  800beb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bee:	89 34 24             	mov    %esi,(%esp)
  800bf1:	e8 06 0f 00 00       	call   801afc <pageref>
		nn = thisenv->env_runs;
  800bf6:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800bfc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bff:	83 c4 10             	add    $0x10,%esp
  800c02:	39 cb                	cmp    %ecx,%ebx
  800c04:	74 1b                	je     800c21 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c06:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c09:	75 cf                	jne    800bda <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c0b:	8b 42 58             	mov    0x58(%edx),%eax
  800c0e:	6a 01                	push   $0x1
  800c10:	50                   	push   %eax
  800c11:	53                   	push   %ebx
  800c12:	68 7e 1e 80 00       	push   $0x801e7e
  800c17:	e8 d2 04 00 00       	call   8010ee <cprintf>
  800c1c:	83 c4 10             	add    $0x10,%esp
  800c1f:	eb b9                	jmp    800bda <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c21:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c24:	0f 94 c0             	sete   %al
  800c27:	0f b6 c0             	movzbl %al,%eax
}
  800c2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <devpipe_write>:
{
  800c32:	55                   	push   %ebp
  800c33:	89 e5                	mov    %esp,%ebp
  800c35:	57                   	push   %edi
  800c36:	56                   	push   %esi
  800c37:	53                   	push   %ebx
  800c38:	83 ec 28             	sub    $0x28,%esp
  800c3b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c3e:	56                   	push   %esi
  800c3f:	e8 3e f7 ff ff       	call   800382 <fd2data>
  800c44:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c46:	83 c4 10             	add    $0x10,%esp
  800c49:	bf 00 00 00 00       	mov    $0x0,%edi
  800c4e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c51:	75 09                	jne    800c5c <devpipe_write+0x2a>
	return i;
  800c53:	89 f8                	mov    %edi,%eax
  800c55:	eb 23                	jmp    800c7a <devpipe_write+0x48>
			sys_yield();
  800c57:	e8 06 f5 ff ff       	call   800162 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c5c:	8b 43 04             	mov    0x4(%ebx),%eax
  800c5f:	8b 0b                	mov    (%ebx),%ecx
  800c61:	8d 51 20             	lea    0x20(%ecx),%edx
  800c64:	39 d0                	cmp    %edx,%eax
  800c66:	72 1a                	jb     800c82 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  800c68:	89 da                	mov    %ebx,%edx
  800c6a:	89 f0                	mov    %esi,%eax
  800c6c:	e8 5c ff ff ff       	call   800bcd <_pipeisclosed>
  800c71:	85 c0                	test   %eax,%eax
  800c73:	74 e2                	je     800c57 <devpipe_write+0x25>
				return 0;
  800c75:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c82:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c85:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c89:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c8c:	89 c2                	mov    %eax,%edx
  800c8e:	c1 fa 1f             	sar    $0x1f,%edx
  800c91:	89 d1                	mov    %edx,%ecx
  800c93:	c1 e9 1b             	shr    $0x1b,%ecx
  800c96:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c99:	83 e2 1f             	and    $0x1f,%edx
  800c9c:	29 ca                	sub    %ecx,%edx
  800c9e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ca2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ca6:	83 c0 01             	add    $0x1,%eax
  800ca9:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cac:	83 c7 01             	add    $0x1,%edi
  800caf:	eb 9d                	jmp    800c4e <devpipe_write+0x1c>

00800cb1 <devpipe_read>:
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	57                   	push   %edi
  800cb5:	56                   	push   %esi
  800cb6:	53                   	push   %ebx
  800cb7:	83 ec 18             	sub    $0x18,%esp
  800cba:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cbd:	57                   	push   %edi
  800cbe:	e8 bf f6 ff ff       	call   800382 <fd2data>
  800cc3:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cc5:	83 c4 10             	add    $0x10,%esp
  800cc8:	be 00 00 00 00       	mov    $0x0,%esi
  800ccd:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cd0:	75 13                	jne    800ce5 <devpipe_read+0x34>
	return i;
  800cd2:	89 f0                	mov    %esi,%eax
  800cd4:	eb 02                	jmp    800cd8 <devpipe_read+0x27>
				return i;
  800cd6:	89 f0                	mov    %esi,%eax
}
  800cd8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdb:	5b                   	pop    %ebx
  800cdc:	5e                   	pop    %esi
  800cdd:	5f                   	pop    %edi
  800cde:	5d                   	pop    %ebp
  800cdf:	c3                   	ret    
			sys_yield();
  800ce0:	e8 7d f4 ff ff       	call   800162 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800ce5:	8b 03                	mov    (%ebx),%eax
  800ce7:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cea:	75 18                	jne    800d04 <devpipe_read+0x53>
			if (i > 0)
  800cec:	85 f6                	test   %esi,%esi
  800cee:	75 e6                	jne    800cd6 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  800cf0:	89 da                	mov    %ebx,%edx
  800cf2:	89 f8                	mov    %edi,%eax
  800cf4:	e8 d4 fe ff ff       	call   800bcd <_pipeisclosed>
  800cf9:	85 c0                	test   %eax,%eax
  800cfb:	74 e3                	je     800ce0 <devpipe_read+0x2f>
				return 0;
  800cfd:	b8 00 00 00 00       	mov    $0x0,%eax
  800d02:	eb d4                	jmp    800cd8 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d04:	99                   	cltd   
  800d05:	c1 ea 1b             	shr    $0x1b,%edx
  800d08:	01 d0                	add    %edx,%eax
  800d0a:	83 e0 1f             	and    $0x1f,%eax
  800d0d:	29 d0                	sub    %edx,%eax
  800d0f:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d17:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d1a:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d1d:	83 c6 01             	add    $0x1,%esi
  800d20:	eb ab                	jmp    800ccd <devpipe_read+0x1c>

00800d22 <pipe>:
{
  800d22:	55                   	push   %ebp
  800d23:	89 e5                	mov    %esp,%ebp
  800d25:	56                   	push   %esi
  800d26:	53                   	push   %ebx
  800d27:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d2a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d2d:	50                   	push   %eax
  800d2e:	e8 66 f6 ff ff       	call   800399 <fd_alloc>
  800d33:	89 c3                	mov    %eax,%ebx
  800d35:	83 c4 10             	add    $0x10,%esp
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	0f 88 23 01 00 00    	js     800e63 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d40:	83 ec 04             	sub    $0x4,%esp
  800d43:	68 07 04 00 00       	push   $0x407
  800d48:	ff 75 f4             	push   -0xc(%ebp)
  800d4b:	6a 00                	push   $0x0
  800d4d:	e8 2f f4 ff ff       	call   800181 <sys_page_alloc>
  800d52:	89 c3                	mov    %eax,%ebx
  800d54:	83 c4 10             	add    $0x10,%esp
  800d57:	85 c0                	test   %eax,%eax
  800d59:	0f 88 04 01 00 00    	js     800e63 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  800d5f:	83 ec 0c             	sub    $0xc,%esp
  800d62:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d65:	50                   	push   %eax
  800d66:	e8 2e f6 ff ff       	call   800399 <fd_alloc>
  800d6b:	89 c3                	mov    %eax,%ebx
  800d6d:	83 c4 10             	add    $0x10,%esp
  800d70:	85 c0                	test   %eax,%eax
  800d72:	0f 88 db 00 00 00    	js     800e53 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d78:	83 ec 04             	sub    $0x4,%esp
  800d7b:	68 07 04 00 00       	push   $0x407
  800d80:	ff 75 f0             	push   -0x10(%ebp)
  800d83:	6a 00                	push   $0x0
  800d85:	e8 f7 f3 ff ff       	call   800181 <sys_page_alloc>
  800d8a:	89 c3                	mov    %eax,%ebx
  800d8c:	83 c4 10             	add    $0x10,%esp
  800d8f:	85 c0                	test   %eax,%eax
  800d91:	0f 88 bc 00 00 00    	js     800e53 <pipe+0x131>
	va = fd2data(fd0);
  800d97:	83 ec 0c             	sub    $0xc,%esp
  800d9a:	ff 75 f4             	push   -0xc(%ebp)
  800d9d:	e8 e0 f5 ff ff       	call   800382 <fd2data>
  800da2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da4:	83 c4 0c             	add    $0xc,%esp
  800da7:	68 07 04 00 00       	push   $0x407
  800dac:	50                   	push   %eax
  800dad:	6a 00                	push   $0x0
  800daf:	e8 cd f3 ff ff       	call   800181 <sys_page_alloc>
  800db4:	89 c3                	mov    %eax,%ebx
  800db6:	83 c4 10             	add    $0x10,%esp
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	0f 88 82 00 00 00    	js     800e43 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc1:	83 ec 0c             	sub    $0xc,%esp
  800dc4:	ff 75 f0             	push   -0x10(%ebp)
  800dc7:	e8 b6 f5 ff ff       	call   800382 <fd2data>
  800dcc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dd3:	50                   	push   %eax
  800dd4:	6a 00                	push   $0x0
  800dd6:	56                   	push   %esi
  800dd7:	6a 00                	push   $0x0
  800dd9:	e8 e6 f3 ff ff       	call   8001c4 <sys_page_map>
  800dde:	89 c3                	mov    %eax,%ebx
  800de0:	83 c4 20             	add    $0x20,%esp
  800de3:	85 c0                	test   %eax,%eax
  800de5:	78 4e                	js     800e35 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  800de7:	a1 20 30 80 00       	mov    0x803020,%eax
  800dec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800def:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800df1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800df4:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800dfb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dfe:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e00:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e03:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e0a:	83 ec 0c             	sub    $0xc,%esp
  800e0d:	ff 75 f4             	push   -0xc(%ebp)
  800e10:	e8 5d f5 ff ff       	call   800372 <fd2num>
  800e15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e18:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e1a:	83 c4 04             	add    $0x4,%esp
  800e1d:	ff 75 f0             	push   -0x10(%ebp)
  800e20:	e8 4d f5 ff ff       	call   800372 <fd2num>
  800e25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e28:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e2b:	83 c4 10             	add    $0x10,%esp
  800e2e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e33:	eb 2e                	jmp    800e63 <pipe+0x141>
	sys_page_unmap(0, va);
  800e35:	83 ec 08             	sub    $0x8,%esp
  800e38:	56                   	push   %esi
  800e39:	6a 00                	push   $0x0
  800e3b:	e8 c6 f3 ff ff       	call   800206 <sys_page_unmap>
  800e40:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e43:	83 ec 08             	sub    $0x8,%esp
  800e46:	ff 75 f0             	push   -0x10(%ebp)
  800e49:	6a 00                	push   $0x0
  800e4b:	e8 b6 f3 ff ff       	call   800206 <sys_page_unmap>
  800e50:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e53:	83 ec 08             	sub    $0x8,%esp
  800e56:	ff 75 f4             	push   -0xc(%ebp)
  800e59:	6a 00                	push   $0x0
  800e5b:	e8 a6 f3 ff ff       	call   800206 <sys_page_unmap>
  800e60:	83 c4 10             	add    $0x10,%esp
}
  800e63:	89 d8                	mov    %ebx,%eax
  800e65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e68:	5b                   	pop    %ebx
  800e69:	5e                   	pop    %esi
  800e6a:	5d                   	pop    %ebp
  800e6b:	c3                   	ret    

00800e6c <pipeisclosed>:
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e72:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e75:	50                   	push   %eax
  800e76:	ff 75 08             	push   0x8(%ebp)
  800e79:	e8 6b f5 ff ff       	call   8003e9 <fd_lookup>
  800e7e:	83 c4 10             	add    $0x10,%esp
  800e81:	85 c0                	test   %eax,%eax
  800e83:	78 18                	js     800e9d <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e85:	83 ec 0c             	sub    $0xc,%esp
  800e88:	ff 75 f4             	push   -0xc(%ebp)
  800e8b:	e8 f2 f4 ff ff       	call   800382 <fd2data>
  800e90:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800e92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e95:	e8 33 fd ff ff       	call   800bcd <_pipeisclosed>
  800e9a:	83 c4 10             	add    $0x10,%esp
}
  800e9d:	c9                   	leave  
  800e9e:	c3                   	ret    

00800e9f <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  800e9f:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea4:	c3                   	ret    

00800ea5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800eab:	68 96 1e 80 00       	push   $0x801e96
  800eb0:	ff 75 0c             	push   0xc(%ebp)
  800eb3:	e8 10 08 00 00       	call   8016c8 <strcpy>
	return 0;
}
  800eb8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebd:	c9                   	leave  
  800ebe:	c3                   	ret    

00800ebf <devcons_write>:
{
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	57                   	push   %edi
  800ec3:	56                   	push   %esi
  800ec4:	53                   	push   %ebx
  800ec5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ecb:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ed0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800ed6:	eb 2e                	jmp    800f06 <devcons_write+0x47>
		m = n - tot;
  800ed8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800edb:	29 f3                	sub    %esi,%ebx
  800edd:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800ee2:	39 c3                	cmp    %eax,%ebx
  800ee4:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ee7:	83 ec 04             	sub    $0x4,%esp
  800eea:	53                   	push   %ebx
  800eeb:	89 f0                	mov    %esi,%eax
  800eed:	03 45 0c             	add    0xc(%ebp),%eax
  800ef0:	50                   	push   %eax
  800ef1:	57                   	push   %edi
  800ef2:	e8 67 09 00 00       	call   80185e <memmove>
		sys_cputs(buf, m);
  800ef7:	83 c4 08             	add    $0x8,%esp
  800efa:	53                   	push   %ebx
  800efb:	57                   	push   %edi
  800efc:	e8 c4 f1 ff ff       	call   8000c5 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f01:	01 de                	add    %ebx,%esi
  800f03:	83 c4 10             	add    $0x10,%esp
  800f06:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f09:	72 cd                	jb     800ed8 <devcons_write+0x19>
}
  800f0b:	89 f0                	mov    %esi,%eax
  800f0d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f10:	5b                   	pop    %ebx
  800f11:	5e                   	pop    %esi
  800f12:	5f                   	pop    %edi
  800f13:	5d                   	pop    %ebp
  800f14:	c3                   	ret    

00800f15 <devcons_read>:
{
  800f15:	55                   	push   %ebp
  800f16:	89 e5                	mov    %esp,%ebp
  800f18:	83 ec 08             	sub    $0x8,%esp
  800f1b:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f20:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f24:	75 07                	jne    800f2d <devcons_read+0x18>
  800f26:	eb 1f                	jmp    800f47 <devcons_read+0x32>
		sys_yield();
  800f28:	e8 35 f2 ff ff       	call   800162 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f2d:	e8 b1 f1 ff ff       	call   8000e3 <sys_cgetc>
  800f32:	85 c0                	test   %eax,%eax
  800f34:	74 f2                	je     800f28 <devcons_read+0x13>
	if (c < 0)
  800f36:	78 0f                	js     800f47 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  800f38:	83 f8 04             	cmp    $0x4,%eax
  800f3b:	74 0c                	je     800f49 <devcons_read+0x34>
	*(char*)vbuf = c;
  800f3d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f40:	88 02                	mov    %al,(%edx)
	return 1;
  800f42:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f47:	c9                   	leave  
  800f48:	c3                   	ret    
		return 0;
  800f49:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4e:	eb f7                	jmp    800f47 <devcons_read+0x32>

00800f50 <cputchar>:
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f56:	8b 45 08             	mov    0x8(%ebp),%eax
  800f59:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f5c:	6a 01                	push   $0x1
  800f5e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f61:	50                   	push   %eax
  800f62:	e8 5e f1 ff ff       	call   8000c5 <sys_cputs>
}
  800f67:	83 c4 10             	add    $0x10,%esp
  800f6a:	c9                   	leave  
  800f6b:	c3                   	ret    

00800f6c <getchar>:
{
  800f6c:	55                   	push   %ebp
  800f6d:	89 e5                	mov    %esp,%ebp
  800f6f:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f72:	6a 01                	push   $0x1
  800f74:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f77:	50                   	push   %eax
  800f78:	6a 00                	push   $0x0
  800f7a:	e8 ce f6 ff ff       	call   80064d <read>
	if (r < 0)
  800f7f:	83 c4 10             	add    $0x10,%esp
  800f82:	85 c0                	test   %eax,%eax
  800f84:	78 06                	js     800f8c <getchar+0x20>
	if (r < 1)
  800f86:	74 06                	je     800f8e <getchar+0x22>
	return c;
  800f88:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800f8c:	c9                   	leave  
  800f8d:	c3                   	ret    
		return -E_EOF;
  800f8e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800f93:	eb f7                	jmp    800f8c <getchar+0x20>

00800f95 <iscons>:
{
  800f95:	55                   	push   %ebp
  800f96:	89 e5                	mov    %esp,%ebp
  800f98:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f9b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9e:	50                   	push   %eax
  800f9f:	ff 75 08             	push   0x8(%ebp)
  800fa2:	e8 42 f4 ff ff       	call   8003e9 <fd_lookup>
  800fa7:	83 c4 10             	add    $0x10,%esp
  800faa:	85 c0                	test   %eax,%eax
  800fac:	78 11                	js     800fbf <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800fae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fb1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fb7:	39 10                	cmp    %edx,(%eax)
  800fb9:	0f 94 c0             	sete   %al
  800fbc:	0f b6 c0             	movzbl %al,%eax
}
  800fbf:	c9                   	leave  
  800fc0:	c3                   	ret    

00800fc1 <opencons>:
{
  800fc1:	55                   	push   %ebp
  800fc2:	89 e5                	mov    %esp,%ebp
  800fc4:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fc7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fca:	50                   	push   %eax
  800fcb:	e8 c9 f3 ff ff       	call   800399 <fd_alloc>
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	78 3a                	js     801011 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fd7:	83 ec 04             	sub    $0x4,%esp
  800fda:	68 07 04 00 00       	push   $0x407
  800fdf:	ff 75 f4             	push   -0xc(%ebp)
  800fe2:	6a 00                	push   $0x0
  800fe4:	e8 98 f1 ff ff       	call   800181 <sys_page_alloc>
  800fe9:	83 c4 10             	add    $0x10,%esp
  800fec:	85 c0                	test   %eax,%eax
  800fee:	78 21                	js     801011 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800ff0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800ffb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ffe:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801005:	83 ec 0c             	sub    $0xc,%esp
  801008:	50                   	push   %eax
  801009:	e8 64 f3 ff ff       	call   800372 <fd2num>
  80100e:	83 c4 10             	add    $0x10,%esp
}
  801011:	c9                   	leave  
  801012:	c3                   	ret    

00801013 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801013:	55                   	push   %ebp
  801014:	89 e5                	mov    %esp,%ebp
  801016:	56                   	push   %esi
  801017:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801018:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80101b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801021:	e8 1d f1 ff ff       	call   800143 <sys_getenvid>
  801026:	83 ec 0c             	sub    $0xc,%esp
  801029:	ff 75 0c             	push   0xc(%ebp)
  80102c:	ff 75 08             	push   0x8(%ebp)
  80102f:	56                   	push   %esi
  801030:	50                   	push   %eax
  801031:	68 a4 1e 80 00       	push   $0x801ea4
  801036:	e8 b3 00 00 00       	call   8010ee <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80103b:	83 c4 18             	add    $0x18,%esp
  80103e:	53                   	push   %ebx
  80103f:	ff 75 10             	push   0x10(%ebp)
  801042:	e8 56 00 00 00       	call   80109d <vcprintf>
	cprintf("\n");
  801047:	c7 04 24 8f 1e 80 00 	movl   $0x801e8f,(%esp)
  80104e:	e8 9b 00 00 00       	call   8010ee <cprintf>
  801053:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801056:	cc                   	int3   
  801057:	eb fd                	jmp    801056 <_panic+0x43>

00801059 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801059:	55                   	push   %ebp
  80105a:	89 e5                	mov    %esp,%ebp
  80105c:	53                   	push   %ebx
  80105d:	83 ec 04             	sub    $0x4,%esp
  801060:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801063:	8b 13                	mov    (%ebx),%edx
  801065:	8d 42 01             	lea    0x1(%edx),%eax
  801068:	89 03                	mov    %eax,(%ebx)
  80106a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80106d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801071:	3d ff 00 00 00       	cmp    $0xff,%eax
  801076:	74 09                	je     801081 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801078:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80107c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107f:	c9                   	leave  
  801080:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801081:	83 ec 08             	sub    $0x8,%esp
  801084:	68 ff 00 00 00       	push   $0xff
  801089:	8d 43 08             	lea    0x8(%ebx),%eax
  80108c:	50                   	push   %eax
  80108d:	e8 33 f0 ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  801092:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801098:	83 c4 10             	add    $0x10,%esp
  80109b:	eb db                	jmp    801078 <putch+0x1f>

0080109d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010a6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010ad:	00 00 00 
	b.cnt = 0;
  8010b0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010b7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010ba:	ff 75 0c             	push   0xc(%ebp)
  8010bd:	ff 75 08             	push   0x8(%ebp)
  8010c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010c6:	50                   	push   %eax
  8010c7:	68 59 10 80 00       	push   $0x801059
  8010cc:	e8 14 01 00 00       	call   8011e5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010d1:	83 c4 08             	add    $0x8,%esp
  8010d4:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8010da:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010e0:	50                   	push   %eax
  8010e1:	e8 df ef ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  8010e6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010ec:	c9                   	leave  
  8010ed:	c3                   	ret    

008010ee <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010f4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010f7:	50                   	push   %eax
  8010f8:	ff 75 08             	push   0x8(%ebp)
  8010fb:	e8 9d ff ff ff       	call   80109d <vcprintf>
	va_end(ap);

	return cnt;
}
  801100:	c9                   	leave  
  801101:	c3                   	ret    

00801102 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801102:	55                   	push   %ebp
  801103:	89 e5                	mov    %esp,%ebp
  801105:	57                   	push   %edi
  801106:	56                   	push   %esi
  801107:	53                   	push   %ebx
  801108:	83 ec 1c             	sub    $0x1c,%esp
  80110b:	89 c7                	mov    %eax,%edi
  80110d:	89 d6                	mov    %edx,%esi
  80110f:	8b 45 08             	mov    0x8(%ebp),%eax
  801112:	8b 55 0c             	mov    0xc(%ebp),%edx
  801115:	89 d1                	mov    %edx,%ecx
  801117:	89 c2                	mov    %eax,%edx
  801119:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80111c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80111f:	8b 45 10             	mov    0x10(%ebp),%eax
  801122:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801125:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801128:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80112f:	39 c2                	cmp    %eax,%edx
  801131:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801134:	72 3e                	jb     801174 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801136:	83 ec 0c             	sub    $0xc,%esp
  801139:	ff 75 18             	push   0x18(%ebp)
  80113c:	83 eb 01             	sub    $0x1,%ebx
  80113f:	53                   	push   %ebx
  801140:	50                   	push   %eax
  801141:	83 ec 08             	sub    $0x8,%esp
  801144:	ff 75 e4             	push   -0x1c(%ebp)
  801147:	ff 75 e0             	push   -0x20(%ebp)
  80114a:	ff 75 dc             	push   -0x24(%ebp)
  80114d:	ff 75 d8             	push   -0x28(%ebp)
  801150:	e8 eb 09 00 00       	call   801b40 <__udivdi3>
  801155:	83 c4 18             	add    $0x18,%esp
  801158:	52                   	push   %edx
  801159:	50                   	push   %eax
  80115a:	89 f2                	mov    %esi,%edx
  80115c:	89 f8                	mov    %edi,%eax
  80115e:	e8 9f ff ff ff       	call   801102 <printnum>
  801163:	83 c4 20             	add    $0x20,%esp
  801166:	eb 13                	jmp    80117b <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801168:	83 ec 08             	sub    $0x8,%esp
  80116b:	56                   	push   %esi
  80116c:	ff 75 18             	push   0x18(%ebp)
  80116f:	ff d7                	call   *%edi
  801171:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801174:	83 eb 01             	sub    $0x1,%ebx
  801177:	85 db                	test   %ebx,%ebx
  801179:	7f ed                	jg     801168 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80117b:	83 ec 08             	sub    $0x8,%esp
  80117e:	56                   	push   %esi
  80117f:	83 ec 04             	sub    $0x4,%esp
  801182:	ff 75 e4             	push   -0x1c(%ebp)
  801185:	ff 75 e0             	push   -0x20(%ebp)
  801188:	ff 75 dc             	push   -0x24(%ebp)
  80118b:	ff 75 d8             	push   -0x28(%ebp)
  80118e:	e8 cd 0a 00 00       	call   801c60 <__umoddi3>
  801193:	83 c4 14             	add    $0x14,%esp
  801196:	0f be 80 c7 1e 80 00 	movsbl 0x801ec7(%eax),%eax
  80119d:	50                   	push   %eax
  80119e:	ff d7                	call   *%edi
}
  8011a0:	83 c4 10             	add    $0x10,%esp
  8011a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a6:	5b                   	pop    %ebx
  8011a7:	5e                   	pop    %esi
  8011a8:	5f                   	pop    %edi
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    

008011ab <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8011b1:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8011b5:	8b 10                	mov    (%eax),%edx
  8011b7:	3b 50 04             	cmp    0x4(%eax),%edx
  8011ba:	73 0a                	jae    8011c6 <sprintputch+0x1b>
		*b->buf++ = ch;
  8011bc:	8d 4a 01             	lea    0x1(%edx),%ecx
  8011bf:	89 08                	mov    %ecx,(%eax)
  8011c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c4:	88 02                	mov    %al,(%edx)
}
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    

008011c8 <printfmt>:
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011ce:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011d1:	50                   	push   %eax
  8011d2:	ff 75 10             	push   0x10(%ebp)
  8011d5:	ff 75 0c             	push   0xc(%ebp)
  8011d8:	ff 75 08             	push   0x8(%ebp)
  8011db:	e8 05 00 00 00       	call   8011e5 <vprintfmt>
}
  8011e0:	83 c4 10             	add    $0x10,%esp
  8011e3:	c9                   	leave  
  8011e4:	c3                   	ret    

008011e5 <vprintfmt>:
{
  8011e5:	55                   	push   %ebp
  8011e6:	89 e5                	mov    %esp,%ebp
  8011e8:	57                   	push   %edi
  8011e9:	56                   	push   %esi
  8011ea:	53                   	push   %ebx
  8011eb:	83 ec 3c             	sub    $0x3c,%esp
  8011ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8011f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011f4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011f7:	eb 0a                	jmp    801203 <vprintfmt+0x1e>
			putch(ch, putdat);
  8011f9:	83 ec 08             	sub    $0x8,%esp
  8011fc:	53                   	push   %ebx
  8011fd:	50                   	push   %eax
  8011fe:	ff d6                	call   *%esi
  801200:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801203:	83 c7 01             	add    $0x1,%edi
  801206:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80120a:	83 f8 25             	cmp    $0x25,%eax
  80120d:	74 0c                	je     80121b <vprintfmt+0x36>
			if (ch == '\0')
  80120f:	85 c0                	test   %eax,%eax
  801211:	75 e6                	jne    8011f9 <vprintfmt+0x14>
}
  801213:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801216:	5b                   	pop    %ebx
  801217:	5e                   	pop    %esi
  801218:	5f                   	pop    %edi
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    
		padc = ' ';
  80121b:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80121f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  801226:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80122d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801234:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801239:	8d 47 01             	lea    0x1(%edi),%eax
  80123c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80123f:	0f b6 17             	movzbl (%edi),%edx
  801242:	8d 42 dd             	lea    -0x23(%edx),%eax
  801245:	3c 55                	cmp    $0x55,%al
  801247:	0f 87 bb 03 00 00    	ja     801608 <vprintfmt+0x423>
  80124d:	0f b6 c0             	movzbl %al,%eax
  801250:	ff 24 85 00 20 80 00 	jmp    *0x802000(,%eax,4)
  801257:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80125a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80125e:	eb d9                	jmp    801239 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801260:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801263:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801267:	eb d0                	jmp    801239 <vprintfmt+0x54>
  801269:	0f b6 d2             	movzbl %dl,%edx
  80126c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80126f:	b8 00 00 00 00       	mov    $0x0,%eax
  801274:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801277:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80127a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80127e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801281:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801284:	83 f9 09             	cmp    $0x9,%ecx
  801287:	77 55                	ja     8012de <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  801289:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80128c:	eb e9                	jmp    801277 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80128e:	8b 45 14             	mov    0x14(%ebp),%eax
  801291:	8b 00                	mov    (%eax),%eax
  801293:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801296:	8b 45 14             	mov    0x14(%ebp),%eax
  801299:	8d 40 04             	lea    0x4(%eax),%eax
  80129c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80129f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8012a2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8012a6:	79 91                	jns    801239 <vprintfmt+0x54>
				width = precision, precision = -1;
  8012a8:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8012ab:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8012ae:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8012b5:	eb 82                	jmp    801239 <vprintfmt+0x54>
  8012b7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8012ba:	85 d2                	test   %edx,%edx
  8012bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c1:	0f 49 c2             	cmovns %edx,%eax
  8012c4:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012ca:	e9 6a ff ff ff       	jmp    801239 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8012cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012d2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8012d9:	e9 5b ff ff ff       	jmp    801239 <vprintfmt+0x54>
  8012de:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012e4:	eb bc                	jmp    8012a2 <vprintfmt+0xbd>
			lflag++;
  8012e6:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012ec:	e9 48 ff ff ff       	jmp    801239 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8012f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f4:	8d 78 04             	lea    0x4(%eax),%edi
  8012f7:	83 ec 08             	sub    $0x8,%esp
  8012fa:	53                   	push   %ebx
  8012fb:	ff 30                	push   (%eax)
  8012fd:	ff d6                	call   *%esi
			break;
  8012ff:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  801302:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  801305:	e9 9d 02 00 00       	jmp    8015a7 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  80130a:	8b 45 14             	mov    0x14(%ebp),%eax
  80130d:	8d 78 04             	lea    0x4(%eax),%edi
  801310:	8b 10                	mov    (%eax),%edx
  801312:	89 d0                	mov    %edx,%eax
  801314:	f7 d8                	neg    %eax
  801316:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801319:	83 f8 0f             	cmp    $0xf,%eax
  80131c:	7f 23                	jg     801341 <vprintfmt+0x15c>
  80131e:	8b 14 85 60 21 80 00 	mov    0x802160(,%eax,4),%edx
  801325:	85 d2                	test   %edx,%edx
  801327:	74 18                	je     801341 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  801329:	52                   	push   %edx
  80132a:	68 5d 1e 80 00       	push   $0x801e5d
  80132f:	53                   	push   %ebx
  801330:	56                   	push   %esi
  801331:	e8 92 fe ff ff       	call   8011c8 <printfmt>
  801336:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801339:	89 7d 14             	mov    %edi,0x14(%ebp)
  80133c:	e9 66 02 00 00       	jmp    8015a7 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  801341:	50                   	push   %eax
  801342:	68 df 1e 80 00       	push   $0x801edf
  801347:	53                   	push   %ebx
  801348:	56                   	push   %esi
  801349:	e8 7a fe ff ff       	call   8011c8 <printfmt>
  80134e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801351:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801354:	e9 4e 02 00 00       	jmp    8015a7 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  801359:	8b 45 14             	mov    0x14(%ebp),%eax
  80135c:	83 c0 04             	add    $0x4,%eax
  80135f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801362:	8b 45 14             	mov    0x14(%ebp),%eax
  801365:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801367:	85 d2                	test   %edx,%edx
  801369:	b8 d8 1e 80 00       	mov    $0x801ed8,%eax
  80136e:	0f 45 c2             	cmovne %edx,%eax
  801371:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801374:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801378:	7e 06                	jle    801380 <vprintfmt+0x19b>
  80137a:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80137e:	75 0d                	jne    80138d <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801380:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801383:	89 c7                	mov    %eax,%edi
  801385:	03 45 e0             	add    -0x20(%ebp),%eax
  801388:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80138b:	eb 55                	jmp    8013e2 <vprintfmt+0x1fd>
  80138d:	83 ec 08             	sub    $0x8,%esp
  801390:	ff 75 d8             	push   -0x28(%ebp)
  801393:	ff 75 cc             	push   -0x34(%ebp)
  801396:	e8 0a 03 00 00       	call   8016a5 <strnlen>
  80139b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80139e:	29 c1                	sub    %eax,%ecx
  8013a0:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  8013a3:	83 c4 10             	add    $0x10,%esp
  8013a6:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  8013a8:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  8013ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8013af:	eb 0f                	jmp    8013c0 <vprintfmt+0x1db>
					putch(padc, putdat);
  8013b1:	83 ec 08             	sub    $0x8,%esp
  8013b4:	53                   	push   %ebx
  8013b5:	ff 75 e0             	push   -0x20(%ebp)
  8013b8:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8013ba:	83 ef 01             	sub    $0x1,%edi
  8013bd:	83 c4 10             	add    $0x10,%esp
  8013c0:	85 ff                	test   %edi,%edi
  8013c2:	7f ed                	jg     8013b1 <vprintfmt+0x1cc>
  8013c4:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8013c7:	85 d2                	test   %edx,%edx
  8013c9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ce:	0f 49 c2             	cmovns %edx,%eax
  8013d1:	29 c2                	sub    %eax,%edx
  8013d3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8013d6:	eb a8                	jmp    801380 <vprintfmt+0x19b>
					putch(ch, putdat);
  8013d8:	83 ec 08             	sub    $0x8,%esp
  8013db:	53                   	push   %ebx
  8013dc:	52                   	push   %edx
  8013dd:	ff d6                	call   *%esi
  8013df:	83 c4 10             	add    $0x10,%esp
  8013e2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013e5:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013e7:	83 c7 01             	add    $0x1,%edi
  8013ea:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8013ee:	0f be d0             	movsbl %al,%edx
  8013f1:	85 d2                	test   %edx,%edx
  8013f3:	74 4b                	je     801440 <vprintfmt+0x25b>
  8013f5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013f9:	78 06                	js     801401 <vprintfmt+0x21c>
  8013fb:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8013ff:	78 1e                	js     80141f <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  801401:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801405:	74 d1                	je     8013d8 <vprintfmt+0x1f3>
  801407:	0f be c0             	movsbl %al,%eax
  80140a:	83 e8 20             	sub    $0x20,%eax
  80140d:	83 f8 5e             	cmp    $0x5e,%eax
  801410:	76 c6                	jbe    8013d8 <vprintfmt+0x1f3>
					putch('?', putdat);
  801412:	83 ec 08             	sub    $0x8,%esp
  801415:	53                   	push   %ebx
  801416:	6a 3f                	push   $0x3f
  801418:	ff d6                	call   *%esi
  80141a:	83 c4 10             	add    $0x10,%esp
  80141d:	eb c3                	jmp    8013e2 <vprintfmt+0x1fd>
  80141f:	89 cf                	mov    %ecx,%edi
  801421:	eb 0e                	jmp    801431 <vprintfmt+0x24c>
				putch(' ', putdat);
  801423:	83 ec 08             	sub    $0x8,%esp
  801426:	53                   	push   %ebx
  801427:	6a 20                	push   $0x20
  801429:	ff d6                	call   *%esi
			for (; width > 0; width--)
  80142b:	83 ef 01             	sub    $0x1,%edi
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	85 ff                	test   %edi,%edi
  801433:	7f ee                	jg     801423 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  801435:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801438:	89 45 14             	mov    %eax,0x14(%ebp)
  80143b:	e9 67 01 00 00       	jmp    8015a7 <vprintfmt+0x3c2>
  801440:	89 cf                	mov    %ecx,%edi
  801442:	eb ed                	jmp    801431 <vprintfmt+0x24c>
	if (lflag >= 2)
  801444:	83 f9 01             	cmp    $0x1,%ecx
  801447:	7f 1b                	jg     801464 <vprintfmt+0x27f>
	else if (lflag)
  801449:	85 c9                	test   %ecx,%ecx
  80144b:	74 63                	je     8014b0 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80144d:	8b 45 14             	mov    0x14(%ebp),%eax
  801450:	8b 00                	mov    (%eax),%eax
  801452:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801455:	99                   	cltd   
  801456:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801459:	8b 45 14             	mov    0x14(%ebp),%eax
  80145c:	8d 40 04             	lea    0x4(%eax),%eax
  80145f:	89 45 14             	mov    %eax,0x14(%ebp)
  801462:	eb 17                	jmp    80147b <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801464:	8b 45 14             	mov    0x14(%ebp),%eax
  801467:	8b 50 04             	mov    0x4(%eax),%edx
  80146a:	8b 00                	mov    (%eax),%eax
  80146c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80146f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801472:	8b 45 14             	mov    0x14(%ebp),%eax
  801475:	8d 40 08             	lea    0x8(%eax),%eax
  801478:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80147b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80147e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801481:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801486:	85 c9                	test   %ecx,%ecx
  801488:	0f 89 ff 00 00 00    	jns    80158d <vprintfmt+0x3a8>
				putch('-', putdat);
  80148e:	83 ec 08             	sub    $0x8,%esp
  801491:	53                   	push   %ebx
  801492:	6a 2d                	push   $0x2d
  801494:	ff d6                	call   *%esi
				num = -(long long) num;
  801496:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801499:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80149c:	f7 da                	neg    %edx
  80149e:	83 d1 00             	adc    $0x0,%ecx
  8014a1:	f7 d9                	neg    %ecx
  8014a3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8014a6:	bf 0a 00 00 00       	mov    $0xa,%edi
  8014ab:	e9 dd 00 00 00       	jmp    80158d <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  8014b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014b3:	8b 00                	mov    (%eax),%eax
  8014b5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014b8:	99                   	cltd   
  8014b9:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8014bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8014bf:	8d 40 04             	lea    0x4(%eax),%eax
  8014c2:	89 45 14             	mov    %eax,0x14(%ebp)
  8014c5:	eb b4                	jmp    80147b <vprintfmt+0x296>
	if (lflag >= 2)
  8014c7:	83 f9 01             	cmp    $0x1,%ecx
  8014ca:	7f 1e                	jg     8014ea <vprintfmt+0x305>
	else if (lflag)
  8014cc:	85 c9                	test   %ecx,%ecx
  8014ce:	74 32                	je     801502 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8014d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d3:	8b 10                	mov    (%eax),%edx
  8014d5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014da:	8d 40 04             	lea    0x4(%eax),%eax
  8014dd:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014e0:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8014e5:	e9 a3 00 00 00       	jmp    80158d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8014ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ed:	8b 10                	mov    (%eax),%edx
  8014ef:	8b 48 04             	mov    0x4(%eax),%ecx
  8014f2:	8d 40 08             	lea    0x8(%eax),%eax
  8014f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014f8:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8014fd:	e9 8b 00 00 00       	jmp    80158d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801502:	8b 45 14             	mov    0x14(%ebp),%eax
  801505:	8b 10                	mov    (%eax),%edx
  801507:	b9 00 00 00 00       	mov    $0x0,%ecx
  80150c:	8d 40 04             	lea    0x4(%eax),%eax
  80150f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801512:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  801517:	eb 74                	jmp    80158d <vprintfmt+0x3a8>
	if (lflag >= 2)
  801519:	83 f9 01             	cmp    $0x1,%ecx
  80151c:	7f 1b                	jg     801539 <vprintfmt+0x354>
	else if (lflag)
  80151e:	85 c9                	test   %ecx,%ecx
  801520:	74 2c                	je     80154e <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  801522:	8b 45 14             	mov    0x14(%ebp),%eax
  801525:	8b 10                	mov    (%eax),%edx
  801527:	b9 00 00 00 00       	mov    $0x0,%ecx
  80152c:	8d 40 04             	lea    0x4(%eax),%eax
  80152f:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801532:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  801537:	eb 54                	jmp    80158d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801539:	8b 45 14             	mov    0x14(%ebp),%eax
  80153c:	8b 10                	mov    (%eax),%edx
  80153e:	8b 48 04             	mov    0x4(%eax),%ecx
  801541:	8d 40 08             	lea    0x8(%eax),%eax
  801544:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801547:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80154c:	eb 3f                	jmp    80158d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80154e:	8b 45 14             	mov    0x14(%ebp),%eax
  801551:	8b 10                	mov    (%eax),%edx
  801553:	b9 00 00 00 00       	mov    $0x0,%ecx
  801558:	8d 40 04             	lea    0x4(%eax),%eax
  80155b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80155e:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801563:	eb 28                	jmp    80158d <vprintfmt+0x3a8>
			putch('0', putdat);
  801565:	83 ec 08             	sub    $0x8,%esp
  801568:	53                   	push   %ebx
  801569:	6a 30                	push   $0x30
  80156b:	ff d6                	call   *%esi
			putch('x', putdat);
  80156d:	83 c4 08             	add    $0x8,%esp
  801570:	53                   	push   %ebx
  801571:	6a 78                	push   $0x78
  801573:	ff d6                	call   *%esi
			num = (unsigned long long)
  801575:	8b 45 14             	mov    0x14(%ebp),%eax
  801578:	8b 10                	mov    (%eax),%edx
  80157a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80157f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801582:	8d 40 04             	lea    0x4(%eax),%eax
  801585:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801588:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80158d:	83 ec 0c             	sub    $0xc,%esp
  801590:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801594:	50                   	push   %eax
  801595:	ff 75 e0             	push   -0x20(%ebp)
  801598:	57                   	push   %edi
  801599:	51                   	push   %ecx
  80159a:	52                   	push   %edx
  80159b:	89 da                	mov    %ebx,%edx
  80159d:	89 f0                	mov    %esi,%eax
  80159f:	e8 5e fb ff ff       	call   801102 <printnum>
			break;
  8015a4:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  8015a7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8015aa:	e9 54 fc ff ff       	jmp    801203 <vprintfmt+0x1e>
	if (lflag >= 2)
  8015af:	83 f9 01             	cmp    $0x1,%ecx
  8015b2:	7f 1b                	jg     8015cf <vprintfmt+0x3ea>
	else if (lflag)
  8015b4:	85 c9                	test   %ecx,%ecx
  8015b6:	74 2c                	je     8015e4 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  8015b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015bb:	8b 10                	mov    (%eax),%edx
  8015bd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015c2:	8d 40 04             	lea    0x4(%eax),%eax
  8015c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015c8:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8015cd:	eb be                	jmp    80158d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8015cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d2:	8b 10                	mov    (%eax),%edx
  8015d4:	8b 48 04             	mov    0x4(%eax),%ecx
  8015d7:	8d 40 08             	lea    0x8(%eax),%eax
  8015da:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015dd:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8015e2:	eb a9                	jmp    80158d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8015e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8015e7:	8b 10                	mov    (%eax),%edx
  8015e9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015ee:	8d 40 04             	lea    0x4(%eax),%eax
  8015f1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015f4:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8015f9:	eb 92                	jmp    80158d <vprintfmt+0x3a8>
			putch(ch, putdat);
  8015fb:	83 ec 08             	sub    $0x8,%esp
  8015fe:	53                   	push   %ebx
  8015ff:	6a 25                	push   $0x25
  801601:	ff d6                	call   *%esi
			break;
  801603:	83 c4 10             	add    $0x10,%esp
  801606:	eb 9f                	jmp    8015a7 <vprintfmt+0x3c2>
			putch('%', putdat);
  801608:	83 ec 08             	sub    $0x8,%esp
  80160b:	53                   	push   %ebx
  80160c:	6a 25                	push   $0x25
  80160e:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	89 f8                	mov    %edi,%eax
  801615:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801619:	74 05                	je     801620 <vprintfmt+0x43b>
  80161b:	83 e8 01             	sub    $0x1,%eax
  80161e:	eb f5                	jmp    801615 <vprintfmt+0x430>
  801620:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801623:	eb 82                	jmp    8015a7 <vprintfmt+0x3c2>

00801625 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801625:	55                   	push   %ebp
  801626:	89 e5                	mov    %esp,%ebp
  801628:	83 ec 18             	sub    $0x18,%esp
  80162b:	8b 45 08             	mov    0x8(%ebp),%eax
  80162e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801631:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801634:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801638:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80163b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801642:	85 c0                	test   %eax,%eax
  801644:	74 26                	je     80166c <vsnprintf+0x47>
  801646:	85 d2                	test   %edx,%edx
  801648:	7e 22                	jle    80166c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80164a:	ff 75 14             	push   0x14(%ebp)
  80164d:	ff 75 10             	push   0x10(%ebp)
  801650:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801653:	50                   	push   %eax
  801654:	68 ab 11 80 00       	push   $0x8011ab
  801659:	e8 87 fb ff ff       	call   8011e5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80165e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801661:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801664:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801667:	83 c4 10             	add    $0x10,%esp
}
  80166a:	c9                   	leave  
  80166b:	c3                   	ret    
		return -E_INVAL;
  80166c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801671:	eb f7                	jmp    80166a <vsnprintf+0x45>

00801673 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801673:	55                   	push   %ebp
  801674:	89 e5                	mov    %esp,%ebp
  801676:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801679:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80167c:	50                   	push   %eax
  80167d:	ff 75 10             	push   0x10(%ebp)
  801680:	ff 75 0c             	push   0xc(%ebp)
  801683:	ff 75 08             	push   0x8(%ebp)
  801686:	e8 9a ff ff ff       	call   801625 <vsnprintf>
	va_end(ap);

	return rc;
}
  80168b:	c9                   	leave  
  80168c:	c3                   	ret    

0080168d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80168d:	55                   	push   %ebp
  80168e:	89 e5                	mov    %esp,%ebp
  801690:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801693:	b8 00 00 00 00       	mov    $0x0,%eax
  801698:	eb 03                	jmp    80169d <strlen+0x10>
		n++;
  80169a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80169d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016a1:	75 f7                	jne    80169a <strlen+0xd>
	return n;
}
  8016a3:	5d                   	pop    %ebp
  8016a4:	c3                   	ret    

008016a5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b3:	eb 03                	jmp    8016b8 <strnlen+0x13>
		n++;
  8016b5:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016b8:	39 d0                	cmp    %edx,%eax
  8016ba:	74 08                	je     8016c4 <strnlen+0x1f>
  8016bc:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016c0:	75 f3                	jne    8016b5 <strnlen+0x10>
  8016c2:	89 c2                	mov    %eax,%edx
	return n;
}
  8016c4:	89 d0                	mov    %edx,%eax
  8016c6:	5d                   	pop    %ebp
  8016c7:	c3                   	ret    

008016c8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	53                   	push   %ebx
  8016cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8016d7:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016db:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016de:	83 c0 01             	add    $0x1,%eax
  8016e1:	84 d2                	test   %dl,%dl
  8016e3:	75 f2                	jne    8016d7 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8016e5:	89 c8                	mov    %ecx,%eax
  8016e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ea:	c9                   	leave  
  8016eb:	c3                   	ret    

008016ec <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	53                   	push   %ebx
  8016f0:	83 ec 10             	sub    $0x10,%esp
  8016f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016f6:	53                   	push   %ebx
  8016f7:	e8 91 ff ff ff       	call   80168d <strlen>
  8016fc:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8016ff:	ff 75 0c             	push   0xc(%ebp)
  801702:	01 d8                	add    %ebx,%eax
  801704:	50                   	push   %eax
  801705:	e8 be ff ff ff       	call   8016c8 <strcpy>
	return dst;
}
  80170a:	89 d8                	mov    %ebx,%eax
  80170c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170f:	c9                   	leave  
  801710:	c3                   	ret    

00801711 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	56                   	push   %esi
  801715:	53                   	push   %ebx
  801716:	8b 75 08             	mov    0x8(%ebp),%esi
  801719:	8b 55 0c             	mov    0xc(%ebp),%edx
  80171c:	89 f3                	mov    %esi,%ebx
  80171e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801721:	89 f0                	mov    %esi,%eax
  801723:	eb 0f                	jmp    801734 <strncpy+0x23>
		*dst++ = *src;
  801725:	83 c0 01             	add    $0x1,%eax
  801728:	0f b6 0a             	movzbl (%edx),%ecx
  80172b:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80172e:	80 f9 01             	cmp    $0x1,%cl
  801731:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801734:	39 d8                	cmp    %ebx,%eax
  801736:	75 ed                	jne    801725 <strncpy+0x14>
	}
	return ret;
}
  801738:	89 f0                	mov    %esi,%eax
  80173a:	5b                   	pop    %ebx
  80173b:	5e                   	pop    %esi
  80173c:	5d                   	pop    %ebp
  80173d:	c3                   	ret    

0080173e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80173e:	55                   	push   %ebp
  80173f:	89 e5                	mov    %esp,%ebp
  801741:	56                   	push   %esi
  801742:	53                   	push   %ebx
  801743:	8b 75 08             	mov    0x8(%ebp),%esi
  801746:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801749:	8b 55 10             	mov    0x10(%ebp),%edx
  80174c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80174e:	85 d2                	test   %edx,%edx
  801750:	74 21                	je     801773 <strlcpy+0x35>
  801752:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801756:	89 f2                	mov    %esi,%edx
  801758:	eb 09                	jmp    801763 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80175a:	83 c1 01             	add    $0x1,%ecx
  80175d:	83 c2 01             	add    $0x1,%edx
  801760:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801763:	39 c2                	cmp    %eax,%edx
  801765:	74 09                	je     801770 <strlcpy+0x32>
  801767:	0f b6 19             	movzbl (%ecx),%ebx
  80176a:	84 db                	test   %bl,%bl
  80176c:	75 ec                	jne    80175a <strlcpy+0x1c>
  80176e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801770:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801773:	29 f0                	sub    %esi,%eax
}
  801775:	5b                   	pop    %ebx
  801776:	5e                   	pop    %esi
  801777:	5d                   	pop    %ebp
  801778:	c3                   	ret    

00801779 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801779:	55                   	push   %ebp
  80177a:	89 e5                	mov    %esp,%ebp
  80177c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80177f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801782:	eb 06                	jmp    80178a <strcmp+0x11>
		p++, q++;
  801784:	83 c1 01             	add    $0x1,%ecx
  801787:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80178a:	0f b6 01             	movzbl (%ecx),%eax
  80178d:	84 c0                	test   %al,%al
  80178f:	74 04                	je     801795 <strcmp+0x1c>
  801791:	3a 02                	cmp    (%edx),%al
  801793:	74 ef                	je     801784 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801795:	0f b6 c0             	movzbl %al,%eax
  801798:	0f b6 12             	movzbl (%edx),%edx
  80179b:	29 d0                	sub    %edx,%eax
}
  80179d:	5d                   	pop    %ebp
  80179e:	c3                   	ret    

0080179f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80179f:	55                   	push   %ebp
  8017a0:	89 e5                	mov    %esp,%ebp
  8017a2:	53                   	push   %ebx
  8017a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017a9:	89 c3                	mov    %eax,%ebx
  8017ab:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017ae:	eb 06                	jmp    8017b6 <strncmp+0x17>
		n--, p++, q++;
  8017b0:	83 c0 01             	add    $0x1,%eax
  8017b3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017b6:	39 d8                	cmp    %ebx,%eax
  8017b8:	74 18                	je     8017d2 <strncmp+0x33>
  8017ba:	0f b6 08             	movzbl (%eax),%ecx
  8017bd:	84 c9                	test   %cl,%cl
  8017bf:	74 04                	je     8017c5 <strncmp+0x26>
  8017c1:	3a 0a                	cmp    (%edx),%cl
  8017c3:	74 eb                	je     8017b0 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017c5:	0f b6 00             	movzbl (%eax),%eax
  8017c8:	0f b6 12             	movzbl (%edx),%edx
  8017cb:	29 d0                	sub    %edx,%eax
}
  8017cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d0:	c9                   	leave  
  8017d1:	c3                   	ret    
		return 0;
  8017d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d7:	eb f4                	jmp    8017cd <strncmp+0x2e>

008017d9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017d9:	55                   	push   %ebp
  8017da:	89 e5                	mov    %esp,%ebp
  8017dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8017df:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017e3:	eb 03                	jmp    8017e8 <strchr+0xf>
  8017e5:	83 c0 01             	add    $0x1,%eax
  8017e8:	0f b6 10             	movzbl (%eax),%edx
  8017eb:	84 d2                	test   %dl,%dl
  8017ed:	74 06                	je     8017f5 <strchr+0x1c>
		if (*s == c)
  8017ef:	38 ca                	cmp    %cl,%dl
  8017f1:	75 f2                	jne    8017e5 <strchr+0xc>
  8017f3:	eb 05                	jmp    8017fa <strchr+0x21>
			return (char *) s;
	return 0;
  8017f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fa:	5d                   	pop    %ebp
  8017fb:	c3                   	ret    

008017fc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017fc:	55                   	push   %ebp
  8017fd:	89 e5                	mov    %esp,%ebp
  8017ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801802:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801806:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801809:	38 ca                	cmp    %cl,%dl
  80180b:	74 09                	je     801816 <strfind+0x1a>
  80180d:	84 d2                	test   %dl,%dl
  80180f:	74 05                	je     801816 <strfind+0x1a>
	for (; *s; s++)
  801811:	83 c0 01             	add    $0x1,%eax
  801814:	eb f0                	jmp    801806 <strfind+0xa>
			break;
	return (char *) s;
}
  801816:	5d                   	pop    %ebp
  801817:	c3                   	ret    

00801818 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801818:	55                   	push   %ebp
  801819:	89 e5                	mov    %esp,%ebp
  80181b:	57                   	push   %edi
  80181c:	56                   	push   %esi
  80181d:	53                   	push   %ebx
  80181e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801821:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801824:	85 c9                	test   %ecx,%ecx
  801826:	74 2f                	je     801857 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801828:	89 f8                	mov    %edi,%eax
  80182a:	09 c8                	or     %ecx,%eax
  80182c:	a8 03                	test   $0x3,%al
  80182e:	75 21                	jne    801851 <memset+0x39>
		c &= 0xFF;
  801830:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801834:	89 d0                	mov    %edx,%eax
  801836:	c1 e0 08             	shl    $0x8,%eax
  801839:	89 d3                	mov    %edx,%ebx
  80183b:	c1 e3 18             	shl    $0x18,%ebx
  80183e:	89 d6                	mov    %edx,%esi
  801840:	c1 e6 10             	shl    $0x10,%esi
  801843:	09 f3                	or     %esi,%ebx
  801845:	09 da                	or     %ebx,%edx
  801847:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801849:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80184c:	fc                   	cld    
  80184d:	f3 ab                	rep stos %eax,%es:(%edi)
  80184f:	eb 06                	jmp    801857 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801851:	8b 45 0c             	mov    0xc(%ebp),%eax
  801854:	fc                   	cld    
  801855:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801857:	89 f8                	mov    %edi,%eax
  801859:	5b                   	pop    %ebx
  80185a:	5e                   	pop    %esi
  80185b:	5f                   	pop    %edi
  80185c:	5d                   	pop    %ebp
  80185d:	c3                   	ret    

0080185e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	57                   	push   %edi
  801862:	56                   	push   %esi
  801863:	8b 45 08             	mov    0x8(%ebp),%eax
  801866:	8b 75 0c             	mov    0xc(%ebp),%esi
  801869:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80186c:	39 c6                	cmp    %eax,%esi
  80186e:	73 32                	jae    8018a2 <memmove+0x44>
  801870:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801873:	39 c2                	cmp    %eax,%edx
  801875:	76 2b                	jbe    8018a2 <memmove+0x44>
		s += n;
		d += n;
  801877:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80187a:	89 d6                	mov    %edx,%esi
  80187c:	09 fe                	or     %edi,%esi
  80187e:	09 ce                	or     %ecx,%esi
  801880:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801886:	75 0e                	jne    801896 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801888:	83 ef 04             	sub    $0x4,%edi
  80188b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80188e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801891:	fd                   	std    
  801892:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801894:	eb 09                	jmp    80189f <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801896:	83 ef 01             	sub    $0x1,%edi
  801899:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80189c:	fd                   	std    
  80189d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80189f:	fc                   	cld    
  8018a0:	eb 1a                	jmp    8018bc <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018a2:	89 f2                	mov    %esi,%edx
  8018a4:	09 c2                	or     %eax,%edx
  8018a6:	09 ca                	or     %ecx,%edx
  8018a8:	f6 c2 03             	test   $0x3,%dl
  8018ab:	75 0a                	jne    8018b7 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018ad:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018b0:	89 c7                	mov    %eax,%edi
  8018b2:	fc                   	cld    
  8018b3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b5:	eb 05                	jmp    8018bc <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  8018b7:	89 c7                	mov    %eax,%edi
  8018b9:	fc                   	cld    
  8018ba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018bc:	5e                   	pop    %esi
  8018bd:	5f                   	pop    %edi
  8018be:	5d                   	pop    %ebp
  8018bf:	c3                   	ret    

008018c0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8018c6:	ff 75 10             	push   0x10(%ebp)
  8018c9:	ff 75 0c             	push   0xc(%ebp)
  8018cc:	ff 75 08             	push   0x8(%ebp)
  8018cf:	e8 8a ff ff ff       	call   80185e <memmove>
}
  8018d4:	c9                   	leave  
  8018d5:	c3                   	ret    

008018d6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
  8018d9:	56                   	push   %esi
  8018da:	53                   	push   %ebx
  8018db:	8b 45 08             	mov    0x8(%ebp),%eax
  8018de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e1:	89 c6                	mov    %eax,%esi
  8018e3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018e6:	eb 06                	jmp    8018ee <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8018e8:	83 c0 01             	add    $0x1,%eax
  8018eb:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8018ee:	39 f0                	cmp    %esi,%eax
  8018f0:	74 14                	je     801906 <memcmp+0x30>
		if (*s1 != *s2)
  8018f2:	0f b6 08             	movzbl (%eax),%ecx
  8018f5:	0f b6 1a             	movzbl (%edx),%ebx
  8018f8:	38 d9                	cmp    %bl,%cl
  8018fa:	74 ec                	je     8018e8 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8018fc:	0f b6 c1             	movzbl %cl,%eax
  8018ff:	0f b6 db             	movzbl %bl,%ebx
  801902:	29 d8                	sub    %ebx,%eax
  801904:	eb 05                	jmp    80190b <memcmp+0x35>
	}

	return 0;
  801906:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80190b:	5b                   	pop    %ebx
  80190c:	5e                   	pop    %esi
  80190d:	5d                   	pop    %ebp
  80190e:	c3                   	ret    

0080190f <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80190f:	55                   	push   %ebp
  801910:	89 e5                	mov    %esp,%ebp
  801912:	8b 45 08             	mov    0x8(%ebp),%eax
  801915:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801918:	89 c2                	mov    %eax,%edx
  80191a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80191d:	eb 03                	jmp    801922 <memfind+0x13>
  80191f:	83 c0 01             	add    $0x1,%eax
  801922:	39 d0                	cmp    %edx,%eax
  801924:	73 04                	jae    80192a <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801926:	38 08                	cmp    %cl,(%eax)
  801928:	75 f5                	jne    80191f <memfind+0x10>
			break;
	return (void *) s;
}
  80192a:	5d                   	pop    %ebp
  80192b:	c3                   	ret    

0080192c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	57                   	push   %edi
  801930:	56                   	push   %esi
  801931:	53                   	push   %ebx
  801932:	8b 55 08             	mov    0x8(%ebp),%edx
  801935:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801938:	eb 03                	jmp    80193d <strtol+0x11>
		s++;
  80193a:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  80193d:	0f b6 02             	movzbl (%edx),%eax
  801940:	3c 20                	cmp    $0x20,%al
  801942:	74 f6                	je     80193a <strtol+0xe>
  801944:	3c 09                	cmp    $0x9,%al
  801946:	74 f2                	je     80193a <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801948:	3c 2b                	cmp    $0x2b,%al
  80194a:	74 2a                	je     801976 <strtol+0x4a>
	int neg = 0;
  80194c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801951:	3c 2d                	cmp    $0x2d,%al
  801953:	74 2b                	je     801980 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801955:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80195b:	75 0f                	jne    80196c <strtol+0x40>
  80195d:	80 3a 30             	cmpb   $0x30,(%edx)
  801960:	74 28                	je     80198a <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801962:	85 db                	test   %ebx,%ebx
  801964:	b8 0a 00 00 00       	mov    $0xa,%eax
  801969:	0f 44 d8             	cmove  %eax,%ebx
  80196c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801971:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801974:	eb 46                	jmp    8019bc <strtol+0x90>
		s++;
  801976:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801979:	bf 00 00 00 00       	mov    $0x0,%edi
  80197e:	eb d5                	jmp    801955 <strtol+0x29>
		s++, neg = 1;
  801980:	83 c2 01             	add    $0x1,%edx
  801983:	bf 01 00 00 00       	mov    $0x1,%edi
  801988:	eb cb                	jmp    801955 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80198a:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80198e:	74 0e                	je     80199e <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801990:	85 db                	test   %ebx,%ebx
  801992:	75 d8                	jne    80196c <strtol+0x40>
		s++, base = 8;
  801994:	83 c2 01             	add    $0x1,%edx
  801997:	bb 08 00 00 00       	mov    $0x8,%ebx
  80199c:	eb ce                	jmp    80196c <strtol+0x40>
		s += 2, base = 16;
  80199e:	83 c2 02             	add    $0x2,%edx
  8019a1:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019a6:	eb c4                	jmp    80196c <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8019a8:	0f be c0             	movsbl %al,%eax
  8019ab:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019ae:	3b 45 10             	cmp    0x10(%ebp),%eax
  8019b1:	7d 3a                	jge    8019ed <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  8019b3:	83 c2 01             	add    $0x1,%edx
  8019b6:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  8019ba:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  8019bc:	0f b6 02             	movzbl (%edx),%eax
  8019bf:	8d 70 d0             	lea    -0x30(%eax),%esi
  8019c2:	89 f3                	mov    %esi,%ebx
  8019c4:	80 fb 09             	cmp    $0x9,%bl
  8019c7:	76 df                	jbe    8019a8 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  8019c9:	8d 70 9f             	lea    -0x61(%eax),%esi
  8019cc:	89 f3                	mov    %esi,%ebx
  8019ce:	80 fb 19             	cmp    $0x19,%bl
  8019d1:	77 08                	ja     8019db <strtol+0xaf>
			dig = *s - 'a' + 10;
  8019d3:	0f be c0             	movsbl %al,%eax
  8019d6:	83 e8 57             	sub    $0x57,%eax
  8019d9:	eb d3                	jmp    8019ae <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8019db:	8d 70 bf             	lea    -0x41(%eax),%esi
  8019de:	89 f3                	mov    %esi,%ebx
  8019e0:	80 fb 19             	cmp    $0x19,%bl
  8019e3:	77 08                	ja     8019ed <strtol+0xc1>
			dig = *s - 'A' + 10;
  8019e5:	0f be c0             	movsbl %al,%eax
  8019e8:	83 e8 37             	sub    $0x37,%eax
  8019eb:	eb c1                	jmp    8019ae <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8019ed:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019f1:	74 05                	je     8019f8 <strtol+0xcc>
		*endptr = (char *) s;
  8019f3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f6:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8019f8:	89 c8                	mov    %ecx,%eax
  8019fa:	f7 d8                	neg    %eax
  8019fc:	85 ff                	test   %edi,%edi
  8019fe:	0f 45 c8             	cmovne %eax,%ecx
}
  801a01:	89 c8                	mov    %ecx,%eax
  801a03:	5b                   	pop    %ebx
  801a04:	5e                   	pop    %esi
  801a05:	5f                   	pop    %edi
  801a06:	5d                   	pop    %ebp
  801a07:	c3                   	ret    

00801a08 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a08:	55                   	push   %ebp
  801a09:	89 e5                	mov    %esp,%ebp
  801a0b:	56                   	push   %esi
  801a0c:	53                   	push   %ebx
  801a0d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801a16:	85 c0                	test   %eax,%eax
  801a18:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a1d:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801a20:	83 ec 0c             	sub    $0xc,%esp
  801a23:	50                   	push   %eax
  801a24:	e8 08 e9 ff ff       	call   800331 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801a29:	83 c4 10             	add    $0x10,%esp
  801a2c:	85 f6                	test   %esi,%esi
  801a2e:	74 14                	je     801a44 <ipc_recv+0x3c>
  801a30:	ba 00 00 00 00       	mov    $0x0,%edx
  801a35:	85 c0                	test   %eax,%eax
  801a37:	78 09                	js     801a42 <ipc_recv+0x3a>
  801a39:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a3f:	8b 52 74             	mov    0x74(%edx),%edx
  801a42:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801a44:	85 db                	test   %ebx,%ebx
  801a46:	74 14                	je     801a5c <ipc_recv+0x54>
  801a48:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4d:	85 c0                	test   %eax,%eax
  801a4f:	78 09                	js     801a5a <ipc_recv+0x52>
  801a51:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a57:	8b 52 78             	mov    0x78(%edx),%edx
  801a5a:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801a5c:	85 c0                	test   %eax,%eax
  801a5e:	78 08                	js     801a68 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801a60:	a1 00 40 80 00       	mov    0x804000,%eax
  801a65:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a68:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6b:	5b                   	pop    %ebx
  801a6c:	5e                   	pop    %esi
  801a6d:	5d                   	pop    %ebp
  801a6e:	c3                   	ret    

00801a6f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	57                   	push   %edi
  801a73:	56                   	push   %esi
  801a74:	53                   	push   %ebx
  801a75:	83 ec 0c             	sub    $0xc,%esp
  801a78:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a7b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a7e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801a81:	85 db                	test   %ebx,%ebx
  801a83:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a88:	0f 44 d8             	cmove  %eax,%ebx
  801a8b:	eb 05                	jmp    801a92 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a8d:	e8 d0 e6 ff ff       	call   800162 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801a92:	ff 75 14             	push   0x14(%ebp)
  801a95:	53                   	push   %ebx
  801a96:	56                   	push   %esi
  801a97:	57                   	push   %edi
  801a98:	e8 71 e8 ff ff       	call   80030e <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aa3:	74 e8                	je     801a8d <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801aa5:	85 c0                	test   %eax,%eax
  801aa7:	78 08                	js     801ab1 <ipc_send+0x42>
	}while (r<0);

}
  801aa9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aac:	5b                   	pop    %ebx
  801aad:	5e                   	pop    %esi
  801aae:	5f                   	pop    %edi
  801aaf:	5d                   	pop    %ebp
  801ab0:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801ab1:	50                   	push   %eax
  801ab2:	68 bf 21 80 00       	push   $0x8021bf
  801ab7:	6a 3d                	push   $0x3d
  801ab9:	68 d3 21 80 00       	push   $0x8021d3
  801abe:	e8 50 f5 ff ff       	call   801013 <_panic>

00801ac3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ac9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ace:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ad1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ad7:	8b 52 50             	mov    0x50(%edx),%edx
  801ada:	39 ca                	cmp    %ecx,%edx
  801adc:	74 11                	je     801aef <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801ade:	83 c0 01             	add    $0x1,%eax
  801ae1:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ae6:	75 e6                	jne    801ace <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801ae8:	b8 00 00 00 00       	mov    $0x0,%eax
  801aed:	eb 0b                	jmp    801afa <ipc_find_env+0x37>
			return envs[i].env_id;
  801aef:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801af2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801af7:	8b 40 48             	mov    0x48(%eax),%eax
}
  801afa:	5d                   	pop    %ebp
  801afb:	c3                   	ret    

00801afc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801afc:	55                   	push   %ebp
  801afd:	89 e5                	mov    %esp,%ebp
  801aff:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b02:	89 c2                	mov    %eax,%edx
  801b04:	c1 ea 16             	shr    $0x16,%edx
  801b07:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b0e:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b13:	f6 c1 01             	test   $0x1,%cl
  801b16:	74 1c                	je     801b34 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801b18:	c1 e8 0c             	shr    $0xc,%eax
  801b1b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b22:	a8 01                	test   $0x1,%al
  801b24:	74 0e                	je     801b34 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b26:	c1 e8 0c             	shr    $0xc,%eax
  801b29:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b30:	ef 
  801b31:	0f b7 d2             	movzwl %dx,%edx
}
  801b34:	89 d0                	mov    %edx,%eax
  801b36:	5d                   	pop    %ebp
  801b37:	c3                   	ret    
  801b38:	66 90                	xchg   %ax,%ax
  801b3a:	66 90                	xchg   %ax,%ax
  801b3c:	66 90                	xchg   %ax,%ax
  801b3e:	66 90                	xchg   %ax,%ax

00801b40 <__udivdi3>:
  801b40:	f3 0f 1e fb          	endbr32 
  801b44:	55                   	push   %ebp
  801b45:	57                   	push   %edi
  801b46:	56                   	push   %esi
  801b47:	53                   	push   %ebx
  801b48:	83 ec 1c             	sub    $0x1c,%esp
  801b4b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801b4f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b53:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b57:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b5b:	85 c0                	test   %eax,%eax
  801b5d:	75 19                	jne    801b78 <__udivdi3+0x38>
  801b5f:	39 f3                	cmp    %esi,%ebx
  801b61:	76 4d                	jbe    801bb0 <__udivdi3+0x70>
  801b63:	31 ff                	xor    %edi,%edi
  801b65:	89 e8                	mov    %ebp,%eax
  801b67:	89 f2                	mov    %esi,%edx
  801b69:	f7 f3                	div    %ebx
  801b6b:	89 fa                	mov    %edi,%edx
  801b6d:	83 c4 1c             	add    $0x1c,%esp
  801b70:	5b                   	pop    %ebx
  801b71:	5e                   	pop    %esi
  801b72:	5f                   	pop    %edi
  801b73:	5d                   	pop    %ebp
  801b74:	c3                   	ret    
  801b75:	8d 76 00             	lea    0x0(%esi),%esi
  801b78:	39 f0                	cmp    %esi,%eax
  801b7a:	76 14                	jbe    801b90 <__udivdi3+0x50>
  801b7c:	31 ff                	xor    %edi,%edi
  801b7e:	31 c0                	xor    %eax,%eax
  801b80:	89 fa                	mov    %edi,%edx
  801b82:	83 c4 1c             	add    $0x1c,%esp
  801b85:	5b                   	pop    %ebx
  801b86:	5e                   	pop    %esi
  801b87:	5f                   	pop    %edi
  801b88:	5d                   	pop    %ebp
  801b89:	c3                   	ret    
  801b8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801b90:	0f bd f8             	bsr    %eax,%edi
  801b93:	83 f7 1f             	xor    $0x1f,%edi
  801b96:	75 48                	jne    801be0 <__udivdi3+0xa0>
  801b98:	39 f0                	cmp    %esi,%eax
  801b9a:	72 06                	jb     801ba2 <__udivdi3+0x62>
  801b9c:	31 c0                	xor    %eax,%eax
  801b9e:	39 eb                	cmp    %ebp,%ebx
  801ba0:	77 de                	ja     801b80 <__udivdi3+0x40>
  801ba2:	b8 01 00 00 00       	mov    $0x1,%eax
  801ba7:	eb d7                	jmp    801b80 <__udivdi3+0x40>
  801ba9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bb0:	89 d9                	mov    %ebx,%ecx
  801bb2:	85 db                	test   %ebx,%ebx
  801bb4:	75 0b                	jne    801bc1 <__udivdi3+0x81>
  801bb6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bbb:	31 d2                	xor    %edx,%edx
  801bbd:	f7 f3                	div    %ebx
  801bbf:	89 c1                	mov    %eax,%ecx
  801bc1:	31 d2                	xor    %edx,%edx
  801bc3:	89 f0                	mov    %esi,%eax
  801bc5:	f7 f1                	div    %ecx
  801bc7:	89 c6                	mov    %eax,%esi
  801bc9:	89 e8                	mov    %ebp,%eax
  801bcb:	89 f7                	mov    %esi,%edi
  801bcd:	f7 f1                	div    %ecx
  801bcf:	89 fa                	mov    %edi,%edx
  801bd1:	83 c4 1c             	add    $0x1c,%esp
  801bd4:	5b                   	pop    %ebx
  801bd5:	5e                   	pop    %esi
  801bd6:	5f                   	pop    %edi
  801bd7:	5d                   	pop    %ebp
  801bd8:	c3                   	ret    
  801bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801be0:	89 f9                	mov    %edi,%ecx
  801be2:	ba 20 00 00 00       	mov    $0x20,%edx
  801be7:	29 fa                	sub    %edi,%edx
  801be9:	d3 e0                	shl    %cl,%eax
  801beb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bef:	89 d1                	mov    %edx,%ecx
  801bf1:	89 d8                	mov    %ebx,%eax
  801bf3:	d3 e8                	shr    %cl,%eax
  801bf5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801bf9:	09 c1                	or     %eax,%ecx
  801bfb:	89 f0                	mov    %esi,%eax
  801bfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c01:	89 f9                	mov    %edi,%ecx
  801c03:	d3 e3                	shl    %cl,%ebx
  801c05:	89 d1                	mov    %edx,%ecx
  801c07:	d3 e8                	shr    %cl,%eax
  801c09:	89 f9                	mov    %edi,%ecx
  801c0b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c0f:	89 eb                	mov    %ebp,%ebx
  801c11:	d3 e6                	shl    %cl,%esi
  801c13:	89 d1                	mov    %edx,%ecx
  801c15:	d3 eb                	shr    %cl,%ebx
  801c17:	09 f3                	or     %esi,%ebx
  801c19:	89 c6                	mov    %eax,%esi
  801c1b:	89 f2                	mov    %esi,%edx
  801c1d:	89 d8                	mov    %ebx,%eax
  801c1f:	f7 74 24 08          	divl   0x8(%esp)
  801c23:	89 d6                	mov    %edx,%esi
  801c25:	89 c3                	mov    %eax,%ebx
  801c27:	f7 64 24 0c          	mull   0xc(%esp)
  801c2b:	39 d6                	cmp    %edx,%esi
  801c2d:	72 19                	jb     801c48 <__udivdi3+0x108>
  801c2f:	89 f9                	mov    %edi,%ecx
  801c31:	d3 e5                	shl    %cl,%ebp
  801c33:	39 c5                	cmp    %eax,%ebp
  801c35:	73 04                	jae    801c3b <__udivdi3+0xfb>
  801c37:	39 d6                	cmp    %edx,%esi
  801c39:	74 0d                	je     801c48 <__udivdi3+0x108>
  801c3b:	89 d8                	mov    %ebx,%eax
  801c3d:	31 ff                	xor    %edi,%edi
  801c3f:	e9 3c ff ff ff       	jmp    801b80 <__udivdi3+0x40>
  801c44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c48:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c4b:	31 ff                	xor    %edi,%edi
  801c4d:	e9 2e ff ff ff       	jmp    801b80 <__udivdi3+0x40>
  801c52:	66 90                	xchg   %ax,%ax
  801c54:	66 90                	xchg   %ax,%ax
  801c56:	66 90                	xchg   %ax,%ax
  801c58:	66 90                	xchg   %ax,%ax
  801c5a:	66 90                	xchg   %ax,%ax
  801c5c:	66 90                	xchg   %ax,%ax
  801c5e:	66 90                	xchg   %ax,%ax

00801c60 <__umoddi3>:
  801c60:	f3 0f 1e fb          	endbr32 
  801c64:	55                   	push   %ebp
  801c65:	57                   	push   %edi
  801c66:	56                   	push   %esi
  801c67:	53                   	push   %ebx
  801c68:	83 ec 1c             	sub    $0x1c,%esp
  801c6b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801c6f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801c73:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801c77:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801c7b:	89 f0                	mov    %esi,%eax
  801c7d:	89 da                	mov    %ebx,%edx
  801c7f:	85 ff                	test   %edi,%edi
  801c81:	75 15                	jne    801c98 <__umoddi3+0x38>
  801c83:	39 dd                	cmp    %ebx,%ebp
  801c85:	76 39                	jbe    801cc0 <__umoddi3+0x60>
  801c87:	f7 f5                	div    %ebp
  801c89:	89 d0                	mov    %edx,%eax
  801c8b:	31 d2                	xor    %edx,%edx
  801c8d:	83 c4 1c             	add    $0x1c,%esp
  801c90:	5b                   	pop    %ebx
  801c91:	5e                   	pop    %esi
  801c92:	5f                   	pop    %edi
  801c93:	5d                   	pop    %ebp
  801c94:	c3                   	ret    
  801c95:	8d 76 00             	lea    0x0(%esi),%esi
  801c98:	39 df                	cmp    %ebx,%edi
  801c9a:	77 f1                	ja     801c8d <__umoddi3+0x2d>
  801c9c:	0f bd cf             	bsr    %edi,%ecx
  801c9f:	83 f1 1f             	xor    $0x1f,%ecx
  801ca2:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801ca6:	75 40                	jne    801ce8 <__umoddi3+0x88>
  801ca8:	39 df                	cmp    %ebx,%edi
  801caa:	72 04                	jb     801cb0 <__umoddi3+0x50>
  801cac:	39 f5                	cmp    %esi,%ebp
  801cae:	77 dd                	ja     801c8d <__umoddi3+0x2d>
  801cb0:	89 da                	mov    %ebx,%edx
  801cb2:	89 f0                	mov    %esi,%eax
  801cb4:	29 e8                	sub    %ebp,%eax
  801cb6:	19 fa                	sbb    %edi,%edx
  801cb8:	eb d3                	jmp    801c8d <__umoddi3+0x2d>
  801cba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cc0:	89 e9                	mov    %ebp,%ecx
  801cc2:	85 ed                	test   %ebp,%ebp
  801cc4:	75 0b                	jne    801cd1 <__umoddi3+0x71>
  801cc6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ccb:	31 d2                	xor    %edx,%edx
  801ccd:	f7 f5                	div    %ebp
  801ccf:	89 c1                	mov    %eax,%ecx
  801cd1:	89 d8                	mov    %ebx,%eax
  801cd3:	31 d2                	xor    %edx,%edx
  801cd5:	f7 f1                	div    %ecx
  801cd7:	89 f0                	mov    %esi,%eax
  801cd9:	f7 f1                	div    %ecx
  801cdb:	89 d0                	mov    %edx,%eax
  801cdd:	31 d2                	xor    %edx,%edx
  801cdf:	eb ac                	jmp    801c8d <__umoddi3+0x2d>
  801ce1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce8:	8b 44 24 04          	mov    0x4(%esp),%eax
  801cec:	ba 20 00 00 00       	mov    $0x20,%edx
  801cf1:	29 c2                	sub    %eax,%edx
  801cf3:	89 c1                	mov    %eax,%ecx
  801cf5:	89 e8                	mov    %ebp,%eax
  801cf7:	d3 e7                	shl    %cl,%edi
  801cf9:	89 d1                	mov    %edx,%ecx
  801cfb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801cff:	d3 e8                	shr    %cl,%eax
  801d01:	89 c1                	mov    %eax,%ecx
  801d03:	8b 44 24 04          	mov    0x4(%esp),%eax
  801d07:	09 f9                	or     %edi,%ecx
  801d09:	89 df                	mov    %ebx,%edi
  801d0b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d0f:	89 c1                	mov    %eax,%ecx
  801d11:	d3 e5                	shl    %cl,%ebp
  801d13:	89 d1                	mov    %edx,%ecx
  801d15:	d3 ef                	shr    %cl,%edi
  801d17:	89 c1                	mov    %eax,%ecx
  801d19:	89 f0                	mov    %esi,%eax
  801d1b:	d3 e3                	shl    %cl,%ebx
  801d1d:	89 d1                	mov    %edx,%ecx
  801d1f:	89 fa                	mov    %edi,%edx
  801d21:	d3 e8                	shr    %cl,%eax
  801d23:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d28:	09 d8                	or     %ebx,%eax
  801d2a:	f7 74 24 08          	divl   0x8(%esp)
  801d2e:	89 d3                	mov    %edx,%ebx
  801d30:	d3 e6                	shl    %cl,%esi
  801d32:	f7 e5                	mul    %ebp
  801d34:	89 c7                	mov    %eax,%edi
  801d36:	89 d1                	mov    %edx,%ecx
  801d38:	39 d3                	cmp    %edx,%ebx
  801d3a:	72 06                	jb     801d42 <__umoddi3+0xe2>
  801d3c:	75 0e                	jne    801d4c <__umoddi3+0xec>
  801d3e:	39 c6                	cmp    %eax,%esi
  801d40:	73 0a                	jae    801d4c <__umoddi3+0xec>
  801d42:	29 e8                	sub    %ebp,%eax
  801d44:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801d48:	89 d1                	mov    %edx,%ecx
  801d4a:	89 c7                	mov    %eax,%edi
  801d4c:	89 f5                	mov    %esi,%ebp
  801d4e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801d52:	29 fd                	sub    %edi,%ebp
  801d54:	19 cb                	sbb    %ecx,%ebx
  801d56:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d5b:	89 d8                	mov    %ebx,%eax
  801d5d:	d3 e0                	shl    %cl,%eax
  801d5f:	89 f1                	mov    %esi,%ecx
  801d61:	d3 ed                	shr    %cl,%ebp
  801d63:	d3 eb                	shr    %cl,%ebx
  801d65:	09 e8                	or     %ebp,%eax
  801d67:	89 da                	mov    %ebx,%edx
  801d69:	83 c4 1c             	add    $0x1c,%esp
  801d6c:	5b                   	pop    %ebx
  801d6d:	5e                   	pop    %esi
  801d6e:	5f                   	pop    %edi
  801d6f:	5d                   	pop    %ebp
  801d70:	c3                   	ret    
