
obj/user/faultwritekernel.debug：     文件格式 elf32-i386


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
	*(unsigned*)0xf0100000 = 0;
  800033:	c7 05 00 00 10 f0 00 	movl   $0x0,0xf0100000
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
  800049:	e8 ce 00 00 00       	call   80011c <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800087:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008a:	e8 88 04 00 00       	call   800517 <close_all>
	sys_env_destroy(0);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	6a 00                	push   $0x0
  800094:	e8 42 00 00 00       	call   8000db <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ac:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ec:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7f 08                	jg     800105 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5f                   	pop    %edi
  800103:	5d                   	pop    %ebp
  800104:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800105:	83 ec 0c             	sub    $0xc,%esp
  800108:	50                   	push   %eax
  800109:	6a 03                	push   $0x3
  80010b:	68 6a 1d 80 00       	push   $0x801d6a
  800110:	6a 2a                	push   $0x2a
  800112:	68 87 1d 80 00       	push   $0x801d87
  800117:	e8 d0 0e 00 00       	call   800fec <_panic>

0080011c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	57                   	push   %edi
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
	asm volatile("int %1\n"
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 02 00 00 00       	mov    $0x2,%eax
  80012c:	89 d1                	mov    %edx,%ecx
  80012e:	89 d3                	mov    %edx,%ebx
  800130:	89 d7                	mov    %edx,%edi
  800132:	89 d6                	mov    %edx,%esi
  800134:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_yield>:

void
sys_yield(void)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	57                   	push   %edi
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
	asm volatile("int %1\n"
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800163:	be 00 00 00 00       	mov    $0x0,%esi
  800168:	8b 55 08             	mov    0x8(%ebp),%edx
  80016b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016e:	b8 04 00 00 00       	mov    $0x4,%eax
  800173:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800176:	89 f7                	mov    %esi,%edi
  800178:	cd 30                	int    $0x30
	if(check && ret > 0)
  80017a:	85 c0                	test   %eax,%eax
  80017c:	7f 08                	jg     800186 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80017e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800181:	5b                   	pop    %ebx
  800182:	5e                   	pop    %esi
  800183:	5f                   	pop    %edi
  800184:	5d                   	pop    %ebp
  800185:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800186:	83 ec 0c             	sub    $0xc,%esp
  800189:	50                   	push   %eax
  80018a:	6a 04                	push   $0x4
  80018c:	68 6a 1d 80 00       	push   $0x801d6a
  800191:	6a 2a                	push   $0x2a
  800193:	68 87 1d 80 00       	push   $0x801d87
  800198:	e8 4f 0e 00 00       	call   800fec <_panic>

0080019d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ac:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ba:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001bc:	85 c0                	test   %eax,%eax
  8001be:	7f 08                	jg     8001c8 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c3:	5b                   	pop    %ebx
  8001c4:	5e                   	pop    %esi
  8001c5:	5f                   	pop    %edi
  8001c6:	5d                   	pop    %ebp
  8001c7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c8:	83 ec 0c             	sub    $0xc,%esp
  8001cb:	50                   	push   %eax
  8001cc:	6a 05                	push   $0x5
  8001ce:	68 6a 1d 80 00       	push   $0x801d6a
  8001d3:	6a 2a                	push   $0x2a
  8001d5:	68 87 1d 80 00       	push   $0x801d87
  8001da:	e8 0d 0e 00 00       	call   800fec <_panic>

008001df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f3:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f8:	89 df                	mov    %ebx,%edi
  8001fa:	89 de                	mov    %ebx,%esi
  8001fc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7f 08                	jg     80020a <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800202:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800205:	5b                   	pop    %ebx
  800206:	5e                   	pop    %esi
  800207:	5f                   	pop    %edi
  800208:	5d                   	pop    %ebp
  800209:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80020a:	83 ec 0c             	sub    $0xc,%esp
  80020d:	50                   	push   %eax
  80020e:	6a 06                	push   $0x6
  800210:	68 6a 1d 80 00       	push   $0x801d6a
  800215:	6a 2a                	push   $0x2a
  800217:	68 87 1d 80 00       	push   $0x801d87
  80021c:	e8 cb 0d 00 00       	call   800fec <_panic>

00800221 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022f:	8b 55 08             	mov    0x8(%ebp),%edx
  800232:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800235:	b8 08 00 00 00       	mov    $0x8,%eax
  80023a:	89 df                	mov    %ebx,%edi
  80023c:	89 de                	mov    %ebx,%esi
  80023e:	cd 30                	int    $0x30
	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7f 08                	jg     80024c <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800244:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800247:	5b                   	pop    %ebx
  800248:	5e                   	pop    %esi
  800249:	5f                   	pop    %edi
  80024a:	5d                   	pop    %ebp
  80024b:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	50                   	push   %eax
  800250:	6a 08                	push   $0x8
  800252:	68 6a 1d 80 00       	push   $0x801d6a
  800257:	6a 2a                	push   $0x2a
  800259:	68 87 1d 80 00       	push   $0x801d87
  80025e:	e8 89 0d 00 00       	call   800fec <_panic>

00800263 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	8b 55 08             	mov    0x8(%ebp),%edx
  800274:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800277:	b8 09 00 00 00       	mov    $0x9,%eax
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30
	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7f 08                	jg     80028e <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800286:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800289:	5b                   	pop    %ebx
  80028a:	5e                   	pop    %esi
  80028b:	5f                   	pop    %edi
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80028e:	83 ec 0c             	sub    $0xc,%esp
  800291:	50                   	push   %eax
  800292:	6a 09                	push   $0x9
  800294:	68 6a 1d 80 00       	push   $0x801d6a
  800299:	6a 2a                	push   $0x2a
  80029b:	68 87 1d 80 00       	push   $0x801d87
  8002a0:	e8 47 0d 00 00       	call   800fec <_panic>

008002a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002be:	89 df                	mov    %ebx,%edi
  8002c0:	89 de                	mov    %ebx,%esi
  8002c2:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	7f 08                	jg     8002d0 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cb:	5b                   	pop    %ebx
  8002cc:	5e                   	pop    %esi
  8002cd:	5f                   	pop    %edi
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d0:	83 ec 0c             	sub    $0xc,%esp
  8002d3:	50                   	push   %eax
  8002d4:	6a 0a                	push   $0xa
  8002d6:	68 6a 1d 80 00       	push   $0x801d6a
  8002db:	6a 2a                	push   $0x2a
  8002dd:	68 87 1d 80 00       	push   $0x801d87
  8002e2:	e8 05 0d 00 00       	call   800fec <_panic>

008002e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f3:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f8:	be 00 00 00 00       	mov    $0x0,%esi
  8002fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800300:	8b 7d 14             	mov    0x14(%ebp),%edi
  800303:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800313:	b9 00 00 00 00       	mov    $0x0,%ecx
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	b8 0d 00 00 00       	mov    $0xd,%eax
  800320:	89 cb                	mov    %ecx,%ebx
  800322:	89 cf                	mov    %ecx,%edi
  800324:	89 ce                	mov    %ecx,%esi
  800326:	cd 30                	int    $0x30
	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7f 08                	jg     800334 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80032c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032f:	5b                   	pop    %ebx
  800330:	5e                   	pop    %esi
  800331:	5f                   	pop    %edi
  800332:	5d                   	pop    %ebp
  800333:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800334:	83 ec 0c             	sub    $0xc,%esp
  800337:	50                   	push   %eax
  800338:	6a 0d                	push   $0xd
  80033a:	68 6a 1d 80 00       	push   $0x801d6a
  80033f:	6a 2a                	push   $0x2a
  800341:	68 87 1d 80 00       	push   $0x801d87
  800346:	e8 a1 0c 00 00       	call   800fec <_panic>

0080034b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	05 00 00 00 30       	add    $0x30000000,%eax
  800356:	c1 e8 0c             	shr    $0xc,%eax
}
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800366:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80037a:	89 c2                	mov    %eax,%edx
  80037c:	c1 ea 16             	shr    $0x16,%edx
  80037f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800386:	f6 c2 01             	test   $0x1,%dl
  800389:	74 29                	je     8003b4 <fd_alloc+0x42>
  80038b:	89 c2                	mov    %eax,%edx
  80038d:	c1 ea 0c             	shr    $0xc,%edx
  800390:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800397:	f6 c2 01             	test   $0x1,%dl
  80039a:	74 18                	je     8003b4 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  80039c:	05 00 10 00 00       	add    $0x1000,%eax
  8003a1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003a6:	75 d2                	jne    80037a <fd_alloc+0x8>
  8003a8:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8003ad:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8003b2:	eb 05                	jmp    8003b9 <fd_alloc+0x47>
			return 0;
  8003b4:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8003b9:	8b 55 08             	mov    0x8(%ebp),%edx
  8003bc:	89 02                	mov    %eax,(%edx)
}
  8003be:	89 c8                	mov    %ecx,%eax
  8003c0:	5d                   	pop    %ebp
  8003c1:	c3                   	ret    

008003c2 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c2:	55                   	push   %ebp
  8003c3:	89 e5                	mov    %esp,%ebp
  8003c5:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c8:	83 f8 1f             	cmp    $0x1f,%eax
  8003cb:	77 30                	ja     8003fd <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003cd:	c1 e0 0c             	shl    $0xc,%eax
  8003d0:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d5:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003db:	f6 c2 01             	test   $0x1,%dl
  8003de:	74 24                	je     800404 <fd_lookup+0x42>
  8003e0:	89 c2                	mov    %eax,%edx
  8003e2:	c1 ea 0c             	shr    $0xc,%edx
  8003e5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ec:	f6 c2 01             	test   $0x1,%dl
  8003ef:	74 1a                	je     80040b <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f4:	89 02                	mov    %eax,(%edx)
	return 0;
  8003f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    
		return -E_INVAL;
  8003fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800402:	eb f7                	jmp    8003fb <fd_lookup+0x39>
		return -E_INVAL;
  800404:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800409:	eb f0                	jmp    8003fb <fd_lookup+0x39>
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800410:	eb e9                	jmp    8003fb <fd_lookup+0x39>

00800412 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	53                   	push   %ebx
  800416:	83 ec 04             	sub    $0x4,%esp
  800419:	8b 55 08             	mov    0x8(%ebp),%edx
  80041c:	b8 14 1e 80 00       	mov    $0x801e14,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800421:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800426:	39 13                	cmp    %edx,(%ebx)
  800428:	74 32                	je     80045c <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  80042a:	83 c0 04             	add    $0x4,%eax
  80042d:	8b 18                	mov    (%eax),%ebx
  80042f:	85 db                	test   %ebx,%ebx
  800431:	75 f3                	jne    800426 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800433:	a1 00 40 80 00       	mov    0x804000,%eax
  800438:	8b 40 48             	mov    0x48(%eax),%eax
  80043b:	83 ec 04             	sub    $0x4,%esp
  80043e:	52                   	push   %edx
  80043f:	50                   	push   %eax
  800440:	68 98 1d 80 00       	push   $0x801d98
  800445:	e8 7d 0c 00 00       	call   8010c7 <cprintf>
	*dev = 0;
	return -E_INVAL;
  80044a:	83 c4 10             	add    $0x10,%esp
  80044d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800452:	8b 55 0c             	mov    0xc(%ebp),%edx
  800455:	89 1a                	mov    %ebx,(%edx)
}
  800457:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80045a:	c9                   	leave  
  80045b:	c3                   	ret    
			return 0;
  80045c:	b8 00 00 00 00       	mov    $0x0,%eax
  800461:	eb ef                	jmp    800452 <dev_lookup+0x40>

00800463 <fd_close>:
{
  800463:	55                   	push   %ebp
  800464:	89 e5                	mov    %esp,%ebp
  800466:	57                   	push   %edi
  800467:	56                   	push   %esi
  800468:	53                   	push   %ebx
  800469:	83 ec 24             	sub    $0x24,%esp
  80046c:	8b 75 08             	mov    0x8(%ebp),%esi
  80046f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800472:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800475:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800476:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80047c:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80047f:	50                   	push   %eax
  800480:	e8 3d ff ff ff       	call   8003c2 <fd_lookup>
  800485:	89 c3                	mov    %eax,%ebx
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	85 c0                	test   %eax,%eax
  80048c:	78 05                	js     800493 <fd_close+0x30>
	    || fd != fd2)
  80048e:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800491:	74 16                	je     8004a9 <fd_close+0x46>
		return (must_exist ? r : 0);
  800493:	89 f8                	mov    %edi,%eax
  800495:	84 c0                	test   %al,%al
  800497:	b8 00 00 00 00       	mov    $0x0,%eax
  80049c:	0f 44 d8             	cmove  %eax,%ebx
}
  80049f:	89 d8                	mov    %ebx,%eax
  8004a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a4:	5b                   	pop    %ebx
  8004a5:	5e                   	pop    %esi
  8004a6:	5f                   	pop    %edi
  8004a7:	5d                   	pop    %ebp
  8004a8:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004af:	50                   	push   %eax
  8004b0:	ff 36                	push   (%esi)
  8004b2:	e8 5b ff ff ff       	call   800412 <dev_lookup>
  8004b7:	89 c3                	mov    %eax,%ebx
  8004b9:	83 c4 10             	add    $0x10,%esp
  8004bc:	85 c0                	test   %eax,%eax
  8004be:	78 1a                	js     8004da <fd_close+0x77>
		if (dev->dev_close)
  8004c0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c3:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8004c6:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004cb:	85 c0                	test   %eax,%eax
  8004cd:	74 0b                	je     8004da <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8004cf:	83 ec 0c             	sub    $0xc,%esp
  8004d2:	56                   	push   %esi
  8004d3:	ff d0                	call   *%eax
  8004d5:	89 c3                	mov    %eax,%ebx
  8004d7:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004da:	83 ec 08             	sub    $0x8,%esp
  8004dd:	56                   	push   %esi
  8004de:	6a 00                	push   $0x0
  8004e0:	e8 fa fc ff ff       	call   8001df <sys_page_unmap>
	return r;
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	eb b5                	jmp    80049f <fd_close+0x3c>

008004ea <close>:

int
close(int fdnum)
{
  8004ea:	55                   	push   %ebp
  8004eb:	89 e5                	mov    %esp,%ebp
  8004ed:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f3:	50                   	push   %eax
  8004f4:	ff 75 08             	push   0x8(%ebp)
  8004f7:	e8 c6 fe ff ff       	call   8003c2 <fd_lookup>
  8004fc:	83 c4 10             	add    $0x10,%esp
  8004ff:	85 c0                	test   %eax,%eax
  800501:	79 02                	jns    800505 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800503:	c9                   	leave  
  800504:	c3                   	ret    
		return fd_close(fd, 1);
  800505:	83 ec 08             	sub    $0x8,%esp
  800508:	6a 01                	push   $0x1
  80050a:	ff 75 f4             	push   -0xc(%ebp)
  80050d:	e8 51 ff ff ff       	call   800463 <fd_close>
  800512:	83 c4 10             	add    $0x10,%esp
  800515:	eb ec                	jmp    800503 <close+0x19>

00800517 <close_all>:

void
close_all(void)
{
  800517:	55                   	push   %ebp
  800518:	89 e5                	mov    %esp,%ebp
  80051a:	53                   	push   %ebx
  80051b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80051e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800523:	83 ec 0c             	sub    $0xc,%esp
  800526:	53                   	push   %ebx
  800527:	e8 be ff ff ff       	call   8004ea <close>
	for (i = 0; i < MAXFD; i++)
  80052c:	83 c3 01             	add    $0x1,%ebx
  80052f:	83 c4 10             	add    $0x10,%esp
  800532:	83 fb 20             	cmp    $0x20,%ebx
  800535:	75 ec                	jne    800523 <close_all+0xc>
}
  800537:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80053a:	c9                   	leave  
  80053b:	c3                   	ret    

0080053c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80053c:	55                   	push   %ebp
  80053d:	89 e5                	mov    %esp,%ebp
  80053f:	57                   	push   %edi
  800540:	56                   	push   %esi
  800541:	53                   	push   %ebx
  800542:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800545:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800548:	50                   	push   %eax
  800549:	ff 75 08             	push   0x8(%ebp)
  80054c:	e8 71 fe ff ff       	call   8003c2 <fd_lookup>
  800551:	89 c3                	mov    %eax,%ebx
  800553:	83 c4 10             	add    $0x10,%esp
  800556:	85 c0                	test   %eax,%eax
  800558:	78 7f                	js     8005d9 <dup+0x9d>
		return r;
	close(newfdnum);
  80055a:	83 ec 0c             	sub    $0xc,%esp
  80055d:	ff 75 0c             	push   0xc(%ebp)
  800560:	e8 85 ff ff ff       	call   8004ea <close>

	newfd = INDEX2FD(newfdnum);
  800565:	8b 75 0c             	mov    0xc(%ebp),%esi
  800568:	c1 e6 0c             	shl    $0xc,%esi
  80056b:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800571:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800574:	89 3c 24             	mov    %edi,(%esp)
  800577:	e8 df fd ff ff       	call   80035b <fd2data>
  80057c:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80057e:	89 34 24             	mov    %esi,(%esp)
  800581:	e8 d5 fd ff ff       	call   80035b <fd2data>
  800586:	83 c4 10             	add    $0x10,%esp
  800589:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80058c:	89 d8                	mov    %ebx,%eax
  80058e:	c1 e8 16             	shr    $0x16,%eax
  800591:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800598:	a8 01                	test   $0x1,%al
  80059a:	74 11                	je     8005ad <dup+0x71>
  80059c:	89 d8                	mov    %ebx,%eax
  80059e:	c1 e8 0c             	shr    $0xc,%eax
  8005a1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a8:	f6 c2 01             	test   $0x1,%dl
  8005ab:	75 36                	jne    8005e3 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ad:	89 f8                	mov    %edi,%eax
  8005af:	c1 e8 0c             	shr    $0xc,%eax
  8005b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b9:	83 ec 0c             	sub    $0xc,%esp
  8005bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c1:	50                   	push   %eax
  8005c2:	56                   	push   %esi
  8005c3:	6a 00                	push   $0x0
  8005c5:	57                   	push   %edi
  8005c6:	6a 00                	push   $0x0
  8005c8:	e8 d0 fb ff ff       	call   80019d <sys_page_map>
  8005cd:	89 c3                	mov    %eax,%ebx
  8005cf:	83 c4 20             	add    $0x20,%esp
  8005d2:	85 c0                	test   %eax,%eax
  8005d4:	78 33                	js     800609 <dup+0xcd>
		goto err;

	return newfdnum;
  8005d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005d9:	89 d8                	mov    %ebx,%eax
  8005db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005de:	5b                   	pop    %ebx
  8005df:	5e                   	pop    %esi
  8005e0:	5f                   	pop    %edi
  8005e1:	5d                   	pop    %ebp
  8005e2:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005e3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ea:	83 ec 0c             	sub    $0xc,%esp
  8005ed:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f2:	50                   	push   %eax
  8005f3:	ff 75 d4             	push   -0x2c(%ebp)
  8005f6:	6a 00                	push   $0x0
  8005f8:	53                   	push   %ebx
  8005f9:	6a 00                	push   $0x0
  8005fb:	e8 9d fb ff ff       	call   80019d <sys_page_map>
  800600:	89 c3                	mov    %eax,%ebx
  800602:	83 c4 20             	add    $0x20,%esp
  800605:	85 c0                	test   %eax,%eax
  800607:	79 a4                	jns    8005ad <dup+0x71>
	sys_page_unmap(0, newfd);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	56                   	push   %esi
  80060d:	6a 00                	push   $0x0
  80060f:	e8 cb fb ff ff       	call   8001df <sys_page_unmap>
	sys_page_unmap(0, nva);
  800614:	83 c4 08             	add    $0x8,%esp
  800617:	ff 75 d4             	push   -0x2c(%ebp)
  80061a:	6a 00                	push   $0x0
  80061c:	e8 be fb ff ff       	call   8001df <sys_page_unmap>
	return r;
  800621:	83 c4 10             	add    $0x10,%esp
  800624:	eb b3                	jmp    8005d9 <dup+0x9d>

00800626 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800626:	55                   	push   %ebp
  800627:	89 e5                	mov    %esp,%ebp
  800629:	56                   	push   %esi
  80062a:	53                   	push   %ebx
  80062b:	83 ec 18             	sub    $0x18,%esp
  80062e:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800631:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800634:	50                   	push   %eax
  800635:	56                   	push   %esi
  800636:	e8 87 fd ff ff       	call   8003c2 <fd_lookup>
  80063b:	83 c4 10             	add    $0x10,%esp
  80063e:	85 c0                	test   %eax,%eax
  800640:	78 3c                	js     80067e <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800642:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  800645:	83 ec 08             	sub    $0x8,%esp
  800648:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064b:	50                   	push   %eax
  80064c:	ff 33                	push   (%ebx)
  80064e:	e8 bf fd ff ff       	call   800412 <dev_lookup>
  800653:	83 c4 10             	add    $0x10,%esp
  800656:	85 c0                	test   %eax,%eax
  800658:	78 24                	js     80067e <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80065a:	8b 43 08             	mov    0x8(%ebx),%eax
  80065d:	83 e0 03             	and    $0x3,%eax
  800660:	83 f8 01             	cmp    $0x1,%eax
  800663:	74 20                	je     800685 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800665:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800668:	8b 40 08             	mov    0x8(%eax),%eax
  80066b:	85 c0                	test   %eax,%eax
  80066d:	74 37                	je     8006a6 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80066f:	83 ec 04             	sub    $0x4,%esp
  800672:	ff 75 10             	push   0x10(%ebp)
  800675:	ff 75 0c             	push   0xc(%ebp)
  800678:	53                   	push   %ebx
  800679:	ff d0                	call   *%eax
  80067b:	83 c4 10             	add    $0x10,%esp
}
  80067e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800681:	5b                   	pop    %ebx
  800682:	5e                   	pop    %esi
  800683:	5d                   	pop    %ebp
  800684:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800685:	a1 00 40 80 00       	mov    0x804000,%eax
  80068a:	8b 40 48             	mov    0x48(%eax),%eax
  80068d:	83 ec 04             	sub    $0x4,%esp
  800690:	56                   	push   %esi
  800691:	50                   	push   %eax
  800692:	68 d9 1d 80 00       	push   $0x801dd9
  800697:	e8 2b 0a 00 00       	call   8010c7 <cprintf>
		return -E_INVAL;
  80069c:	83 c4 10             	add    $0x10,%esp
  80069f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006a4:	eb d8                	jmp    80067e <read+0x58>
		return -E_NOT_SUPP;
  8006a6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006ab:	eb d1                	jmp    80067e <read+0x58>

008006ad <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	57                   	push   %edi
  8006b1:	56                   	push   %esi
  8006b2:	53                   	push   %ebx
  8006b3:	83 ec 0c             	sub    $0xc,%esp
  8006b6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006b9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006c1:	eb 02                	jmp    8006c5 <readn+0x18>
  8006c3:	01 c3                	add    %eax,%ebx
  8006c5:	39 f3                	cmp    %esi,%ebx
  8006c7:	73 21                	jae    8006ea <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006c9:	83 ec 04             	sub    $0x4,%esp
  8006cc:	89 f0                	mov    %esi,%eax
  8006ce:	29 d8                	sub    %ebx,%eax
  8006d0:	50                   	push   %eax
  8006d1:	89 d8                	mov    %ebx,%eax
  8006d3:	03 45 0c             	add    0xc(%ebp),%eax
  8006d6:	50                   	push   %eax
  8006d7:	57                   	push   %edi
  8006d8:	e8 49 ff ff ff       	call   800626 <read>
		if (m < 0)
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	78 04                	js     8006e8 <readn+0x3b>
			return m;
		if (m == 0)
  8006e4:	75 dd                	jne    8006c3 <readn+0x16>
  8006e6:	eb 02                	jmp    8006ea <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006e8:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006ea:	89 d8                	mov    %ebx,%eax
  8006ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ef:	5b                   	pop    %ebx
  8006f0:	5e                   	pop    %esi
  8006f1:	5f                   	pop    %edi
  8006f2:	5d                   	pop    %ebp
  8006f3:	c3                   	ret    

008006f4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006f4:	55                   	push   %ebp
  8006f5:	89 e5                	mov    %esp,%ebp
  8006f7:	56                   	push   %esi
  8006f8:	53                   	push   %ebx
  8006f9:	83 ec 18             	sub    $0x18,%esp
  8006fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800702:	50                   	push   %eax
  800703:	53                   	push   %ebx
  800704:	e8 b9 fc ff ff       	call   8003c2 <fd_lookup>
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	85 c0                	test   %eax,%eax
  80070e:	78 37                	js     800747 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800710:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800713:	83 ec 08             	sub    $0x8,%esp
  800716:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800719:	50                   	push   %eax
  80071a:	ff 36                	push   (%esi)
  80071c:	e8 f1 fc ff ff       	call   800412 <dev_lookup>
  800721:	83 c4 10             	add    $0x10,%esp
  800724:	85 c0                	test   %eax,%eax
  800726:	78 1f                	js     800747 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800728:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80072c:	74 20                	je     80074e <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80072e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800731:	8b 40 0c             	mov    0xc(%eax),%eax
  800734:	85 c0                	test   %eax,%eax
  800736:	74 37                	je     80076f <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800738:	83 ec 04             	sub    $0x4,%esp
  80073b:	ff 75 10             	push   0x10(%ebp)
  80073e:	ff 75 0c             	push   0xc(%ebp)
  800741:	56                   	push   %esi
  800742:	ff d0                	call   *%eax
  800744:	83 c4 10             	add    $0x10,%esp
}
  800747:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80074a:	5b                   	pop    %ebx
  80074b:	5e                   	pop    %esi
  80074c:	5d                   	pop    %ebp
  80074d:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074e:	a1 00 40 80 00       	mov    0x804000,%eax
  800753:	8b 40 48             	mov    0x48(%eax),%eax
  800756:	83 ec 04             	sub    $0x4,%esp
  800759:	53                   	push   %ebx
  80075a:	50                   	push   %eax
  80075b:	68 f5 1d 80 00       	push   $0x801df5
  800760:	e8 62 09 00 00       	call   8010c7 <cprintf>
		return -E_INVAL;
  800765:	83 c4 10             	add    $0x10,%esp
  800768:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076d:	eb d8                	jmp    800747 <write+0x53>
		return -E_NOT_SUPP;
  80076f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800774:	eb d1                	jmp    800747 <write+0x53>

00800776 <seek>:

int
seek(int fdnum, off_t offset)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80077c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80077f:	50                   	push   %eax
  800780:	ff 75 08             	push   0x8(%ebp)
  800783:	e8 3a fc ff ff       	call   8003c2 <fd_lookup>
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	85 c0                	test   %eax,%eax
  80078d:	78 0e                	js     80079d <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80078f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800792:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800795:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800798:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80079d:	c9                   	leave  
  80079e:	c3                   	ret    

0080079f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80079f:	55                   	push   %ebp
  8007a0:	89 e5                	mov    %esp,%ebp
  8007a2:	56                   	push   %esi
  8007a3:	53                   	push   %ebx
  8007a4:	83 ec 18             	sub    $0x18,%esp
  8007a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ad:	50                   	push   %eax
  8007ae:	53                   	push   %ebx
  8007af:	e8 0e fc ff ff       	call   8003c2 <fd_lookup>
  8007b4:	83 c4 10             	add    $0x10,%esp
  8007b7:	85 c0                	test   %eax,%eax
  8007b9:	78 34                	js     8007ef <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007bb:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8007be:	83 ec 08             	sub    $0x8,%esp
  8007c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c4:	50                   	push   %eax
  8007c5:	ff 36                	push   (%esi)
  8007c7:	e8 46 fc ff ff       	call   800412 <dev_lookup>
  8007cc:	83 c4 10             	add    $0x10,%esp
  8007cf:	85 c0                	test   %eax,%eax
  8007d1:	78 1c                	js     8007ef <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007d3:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8007d7:	74 1d                	je     8007f6 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007dc:	8b 40 18             	mov    0x18(%eax),%eax
  8007df:	85 c0                	test   %eax,%eax
  8007e1:	74 34                	je     800817 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007e3:	83 ec 08             	sub    $0x8,%esp
  8007e6:	ff 75 0c             	push   0xc(%ebp)
  8007e9:	56                   	push   %esi
  8007ea:	ff d0                	call   *%eax
  8007ec:	83 c4 10             	add    $0x10,%esp
}
  8007ef:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007f2:	5b                   	pop    %ebx
  8007f3:	5e                   	pop    %esi
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007f6:	a1 00 40 80 00       	mov    0x804000,%eax
  8007fb:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007fe:	83 ec 04             	sub    $0x4,%esp
  800801:	53                   	push   %ebx
  800802:	50                   	push   %eax
  800803:	68 b8 1d 80 00       	push   $0x801db8
  800808:	e8 ba 08 00 00       	call   8010c7 <cprintf>
		return -E_INVAL;
  80080d:	83 c4 10             	add    $0x10,%esp
  800810:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800815:	eb d8                	jmp    8007ef <ftruncate+0x50>
		return -E_NOT_SUPP;
  800817:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80081c:	eb d1                	jmp    8007ef <ftruncate+0x50>

0080081e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80081e:	55                   	push   %ebp
  80081f:	89 e5                	mov    %esp,%ebp
  800821:	56                   	push   %esi
  800822:	53                   	push   %ebx
  800823:	83 ec 18             	sub    $0x18,%esp
  800826:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800829:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80082c:	50                   	push   %eax
  80082d:	ff 75 08             	push   0x8(%ebp)
  800830:	e8 8d fb ff ff       	call   8003c2 <fd_lookup>
  800835:	83 c4 10             	add    $0x10,%esp
  800838:	85 c0                	test   %eax,%eax
  80083a:	78 49                	js     800885 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80083f:	83 ec 08             	sub    $0x8,%esp
  800842:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800845:	50                   	push   %eax
  800846:	ff 36                	push   (%esi)
  800848:	e8 c5 fb ff ff       	call   800412 <dev_lookup>
  80084d:	83 c4 10             	add    $0x10,%esp
  800850:	85 c0                	test   %eax,%eax
  800852:	78 31                	js     800885 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  800854:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800857:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80085b:	74 2f                	je     80088c <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80085d:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800860:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800867:	00 00 00 
	stat->st_isdir = 0;
  80086a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800871:	00 00 00 
	stat->st_dev = dev;
  800874:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80087a:	83 ec 08             	sub    $0x8,%esp
  80087d:	53                   	push   %ebx
  80087e:	56                   	push   %esi
  80087f:	ff 50 14             	call   *0x14(%eax)
  800882:	83 c4 10             	add    $0x10,%esp
}
  800885:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800888:	5b                   	pop    %ebx
  800889:	5e                   	pop    %esi
  80088a:	5d                   	pop    %ebp
  80088b:	c3                   	ret    
		return -E_NOT_SUPP;
  80088c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800891:	eb f2                	jmp    800885 <fstat+0x67>

00800893 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	6a 00                	push   $0x0
  80089d:	ff 75 08             	push   0x8(%ebp)
  8008a0:	e8 e4 01 00 00       	call   800a89 <open>
  8008a5:	89 c3                	mov    %eax,%ebx
  8008a7:	83 c4 10             	add    $0x10,%esp
  8008aa:	85 c0                	test   %eax,%eax
  8008ac:	78 1b                	js     8008c9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	ff 75 0c             	push   0xc(%ebp)
  8008b4:	50                   	push   %eax
  8008b5:	e8 64 ff ff ff       	call   80081e <fstat>
  8008ba:	89 c6                	mov    %eax,%esi
	close(fd);
  8008bc:	89 1c 24             	mov    %ebx,(%esp)
  8008bf:	e8 26 fc ff ff       	call   8004ea <close>
	return r;
  8008c4:	83 c4 10             	add    $0x10,%esp
  8008c7:	89 f3                	mov    %esi,%ebx
}
  8008c9:	89 d8                	mov    %ebx,%eax
  8008cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ce:	5b                   	pop    %ebx
  8008cf:	5e                   	pop    %esi
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	56                   	push   %esi
  8008d6:	53                   	push   %ebx
  8008d7:	89 c6                	mov    %eax,%esi
  8008d9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008db:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8008e2:	74 27                	je     80090b <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008e4:	6a 07                	push   $0x7
  8008e6:	68 00 50 80 00       	push   $0x805000
  8008eb:	56                   	push   %esi
  8008ec:	ff 35 00 60 80 00    	push   0x806000
  8008f2:	e8 51 11 00 00       	call   801a48 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008f7:	83 c4 0c             	add    $0xc,%esp
  8008fa:	6a 00                	push   $0x0
  8008fc:	53                   	push   %ebx
  8008fd:	6a 00                	push   $0x0
  8008ff:	e8 dd 10 00 00       	call   8019e1 <ipc_recv>
}
  800904:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800907:	5b                   	pop    %ebx
  800908:	5e                   	pop    %esi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80090b:	83 ec 0c             	sub    $0xc,%esp
  80090e:	6a 01                	push   $0x1
  800910:	e8 87 11 00 00       	call   801a9c <ipc_find_env>
  800915:	a3 00 60 80 00       	mov    %eax,0x806000
  80091a:	83 c4 10             	add    $0x10,%esp
  80091d:	eb c5                	jmp    8008e4 <fsipc+0x12>

0080091f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80091f:	55                   	push   %ebp
  800920:	89 e5                	mov    %esp,%ebp
  800922:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800925:	8b 45 08             	mov    0x8(%ebp),%eax
  800928:	8b 40 0c             	mov    0xc(%eax),%eax
  80092b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800930:	8b 45 0c             	mov    0xc(%ebp),%eax
  800933:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800938:	ba 00 00 00 00       	mov    $0x0,%edx
  80093d:	b8 02 00 00 00       	mov    $0x2,%eax
  800942:	e8 8b ff ff ff       	call   8008d2 <fsipc>
}
  800947:	c9                   	leave  
  800948:	c3                   	ret    

00800949 <devfile_flush>:
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 40 0c             	mov    0xc(%eax),%eax
  800955:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80095a:	ba 00 00 00 00       	mov    $0x0,%edx
  80095f:	b8 06 00 00 00       	mov    $0x6,%eax
  800964:	e8 69 ff ff ff       	call   8008d2 <fsipc>
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <devfile_stat>:
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	53                   	push   %ebx
  80096f:	83 ec 04             	sub    $0x4,%esp
  800972:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 40 0c             	mov    0xc(%eax),%eax
  80097b:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800980:	ba 00 00 00 00       	mov    $0x0,%edx
  800985:	b8 05 00 00 00       	mov    $0x5,%eax
  80098a:	e8 43 ff ff ff       	call   8008d2 <fsipc>
  80098f:	85 c0                	test   %eax,%eax
  800991:	78 2c                	js     8009bf <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800993:	83 ec 08             	sub    $0x8,%esp
  800996:	68 00 50 80 00       	push   $0x805000
  80099b:	53                   	push   %ebx
  80099c:	e8 00 0d 00 00       	call   8016a1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009a1:	a1 80 50 80 00       	mov    0x805080,%eax
  8009a6:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009ac:	a1 84 50 80 00       	mov    0x805084,%eax
  8009b1:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009b7:	83 c4 10             	add    $0x10,%esp
  8009ba:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c2:	c9                   	leave  
  8009c3:	c3                   	ret    

008009c4 <devfile_write>:
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	83 ec 0c             	sub    $0xc,%esp
  8009ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8009cd:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009d2:	39 d0                	cmp    %edx,%eax
  8009d4:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009d7:	8b 55 08             	mov    0x8(%ebp),%edx
  8009da:	8b 52 0c             	mov    0xc(%edx),%edx
  8009dd:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009e3:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8009e8:	50                   	push   %eax
  8009e9:	ff 75 0c             	push   0xc(%ebp)
  8009ec:	68 08 50 80 00       	push   $0x805008
  8009f1:	e8 41 0e 00 00       	call   801837 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8009f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fb:	b8 04 00 00 00       	mov    $0x4,%eax
  800a00:	e8 cd fe ff ff       	call   8008d2 <fsipc>
}
  800a05:	c9                   	leave  
  800a06:	c3                   	ret    

00800a07 <devfile_read>:
{
  800a07:	55                   	push   %ebp
  800a08:	89 e5                	mov    %esp,%ebp
  800a0a:	56                   	push   %esi
  800a0b:	53                   	push   %ebx
  800a0c:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a12:	8b 40 0c             	mov    0xc(%eax),%eax
  800a15:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a1a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a20:	ba 00 00 00 00       	mov    $0x0,%edx
  800a25:	b8 03 00 00 00       	mov    $0x3,%eax
  800a2a:	e8 a3 fe ff ff       	call   8008d2 <fsipc>
  800a2f:	89 c3                	mov    %eax,%ebx
  800a31:	85 c0                	test   %eax,%eax
  800a33:	78 1f                	js     800a54 <devfile_read+0x4d>
	assert(r <= n);
  800a35:	39 f0                	cmp    %esi,%eax
  800a37:	77 24                	ja     800a5d <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a39:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a3e:	7f 33                	jg     800a73 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a40:	83 ec 04             	sub    $0x4,%esp
  800a43:	50                   	push   %eax
  800a44:	68 00 50 80 00       	push   $0x805000
  800a49:	ff 75 0c             	push   0xc(%ebp)
  800a4c:	e8 e6 0d 00 00       	call   801837 <memmove>
	return r;
  800a51:	83 c4 10             	add    $0x10,%esp
}
  800a54:	89 d8                	mov    %ebx,%eax
  800a56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a59:	5b                   	pop    %ebx
  800a5a:	5e                   	pop    %esi
  800a5b:	5d                   	pop    %ebp
  800a5c:	c3                   	ret    
	assert(r <= n);
  800a5d:	68 24 1e 80 00       	push   $0x801e24
  800a62:	68 2b 1e 80 00       	push   $0x801e2b
  800a67:	6a 7c                	push   $0x7c
  800a69:	68 40 1e 80 00       	push   $0x801e40
  800a6e:	e8 79 05 00 00       	call   800fec <_panic>
	assert(r <= PGSIZE);
  800a73:	68 4b 1e 80 00       	push   $0x801e4b
  800a78:	68 2b 1e 80 00       	push   $0x801e2b
  800a7d:	6a 7d                	push   $0x7d
  800a7f:	68 40 1e 80 00       	push   $0x801e40
  800a84:	e8 63 05 00 00       	call   800fec <_panic>

00800a89 <open>:
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	56                   	push   %esi
  800a8d:	53                   	push   %ebx
  800a8e:	83 ec 1c             	sub    $0x1c,%esp
  800a91:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800a94:	56                   	push   %esi
  800a95:	e8 cc 0b 00 00       	call   801666 <strlen>
  800a9a:	83 c4 10             	add    $0x10,%esp
  800a9d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aa2:	7f 6c                	jg     800b10 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800aa4:	83 ec 0c             	sub    $0xc,%esp
  800aa7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aaa:	50                   	push   %eax
  800aab:	e8 c2 f8 ff ff       	call   800372 <fd_alloc>
  800ab0:	89 c3                	mov    %eax,%ebx
  800ab2:	83 c4 10             	add    $0x10,%esp
  800ab5:	85 c0                	test   %eax,%eax
  800ab7:	78 3c                	js     800af5 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800ab9:	83 ec 08             	sub    $0x8,%esp
  800abc:	56                   	push   %esi
  800abd:	68 00 50 80 00       	push   $0x805000
  800ac2:	e8 da 0b 00 00       	call   8016a1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ac7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aca:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800acf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ad2:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad7:	e8 f6 fd ff ff       	call   8008d2 <fsipc>
  800adc:	89 c3                	mov    %eax,%ebx
  800ade:	83 c4 10             	add    $0x10,%esp
  800ae1:	85 c0                	test   %eax,%eax
  800ae3:	78 19                	js     800afe <open+0x75>
	return fd2num(fd);
  800ae5:	83 ec 0c             	sub    $0xc,%esp
  800ae8:	ff 75 f4             	push   -0xc(%ebp)
  800aeb:	e8 5b f8 ff ff       	call   80034b <fd2num>
  800af0:	89 c3                	mov    %eax,%ebx
  800af2:	83 c4 10             	add    $0x10,%esp
}
  800af5:	89 d8                	mov    %ebx,%eax
  800af7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    
		fd_close(fd, 0);
  800afe:	83 ec 08             	sub    $0x8,%esp
  800b01:	6a 00                	push   $0x0
  800b03:	ff 75 f4             	push   -0xc(%ebp)
  800b06:	e8 58 f9 ff ff       	call   800463 <fd_close>
		return r;
  800b0b:	83 c4 10             	add    $0x10,%esp
  800b0e:	eb e5                	jmp    800af5 <open+0x6c>
		return -E_BAD_PATH;
  800b10:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b15:	eb de                	jmp    800af5 <open+0x6c>

00800b17 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b17:	55                   	push   %ebp
  800b18:	89 e5                	mov    %esp,%ebp
  800b1a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b22:	b8 08 00 00 00       	mov    $0x8,%eax
  800b27:	e8 a6 fd ff ff       	call   8008d2 <fsipc>
}
  800b2c:	c9                   	leave  
  800b2d:	c3                   	ret    

00800b2e <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b36:	83 ec 0c             	sub    $0xc,%esp
  800b39:	ff 75 08             	push   0x8(%ebp)
  800b3c:	e8 1a f8 ff ff       	call   80035b <fd2data>
  800b41:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b43:	83 c4 08             	add    $0x8,%esp
  800b46:	68 57 1e 80 00       	push   $0x801e57
  800b4b:	53                   	push   %ebx
  800b4c:	e8 50 0b 00 00       	call   8016a1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b51:	8b 46 04             	mov    0x4(%esi),%eax
  800b54:	2b 06                	sub    (%esi),%eax
  800b56:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b5c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b63:	00 00 00 
	stat->st_dev = &devpipe;
  800b66:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b6d:	30 80 00 
	return 0;
}
  800b70:	b8 00 00 00 00       	mov    $0x0,%eax
  800b75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5d                   	pop    %ebp
  800b7b:	c3                   	ret    

00800b7c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	53                   	push   %ebx
  800b80:	83 ec 0c             	sub    $0xc,%esp
  800b83:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b86:	53                   	push   %ebx
  800b87:	6a 00                	push   $0x0
  800b89:	e8 51 f6 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b8e:	89 1c 24             	mov    %ebx,(%esp)
  800b91:	e8 c5 f7 ff ff       	call   80035b <fd2data>
  800b96:	83 c4 08             	add    $0x8,%esp
  800b99:	50                   	push   %eax
  800b9a:	6a 00                	push   $0x0
  800b9c:	e8 3e f6 ff ff       	call   8001df <sys_page_unmap>
}
  800ba1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ba4:	c9                   	leave  
  800ba5:	c3                   	ret    

00800ba6 <_pipeisclosed>:
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	57                   	push   %edi
  800baa:	56                   	push   %esi
  800bab:	53                   	push   %ebx
  800bac:	83 ec 1c             	sub    $0x1c,%esp
  800baf:	89 c7                	mov    %eax,%edi
  800bb1:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bb3:	a1 00 40 80 00       	mov    0x804000,%eax
  800bb8:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bbb:	83 ec 0c             	sub    $0xc,%esp
  800bbe:	57                   	push   %edi
  800bbf:	e8 11 0f 00 00       	call   801ad5 <pageref>
  800bc4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bc7:	89 34 24             	mov    %esi,(%esp)
  800bca:	e8 06 0f 00 00       	call   801ad5 <pageref>
		nn = thisenv->env_runs;
  800bcf:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800bd5:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bd8:	83 c4 10             	add    $0x10,%esp
  800bdb:	39 cb                	cmp    %ecx,%ebx
  800bdd:	74 1b                	je     800bfa <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800bdf:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800be2:	75 cf                	jne    800bb3 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800be4:	8b 42 58             	mov    0x58(%edx),%eax
  800be7:	6a 01                	push   $0x1
  800be9:	50                   	push   %eax
  800bea:	53                   	push   %ebx
  800beb:	68 5e 1e 80 00       	push   $0x801e5e
  800bf0:	e8 d2 04 00 00       	call   8010c7 <cprintf>
  800bf5:	83 c4 10             	add    $0x10,%esp
  800bf8:	eb b9                	jmp    800bb3 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800bfa:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800bfd:	0f 94 c0             	sete   %al
  800c00:	0f b6 c0             	movzbl %al,%eax
}
  800c03:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c06:	5b                   	pop    %ebx
  800c07:	5e                   	pop    %esi
  800c08:	5f                   	pop    %edi
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <devpipe_write>:
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	57                   	push   %edi
  800c0f:	56                   	push   %esi
  800c10:	53                   	push   %ebx
  800c11:	83 ec 28             	sub    $0x28,%esp
  800c14:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c17:	56                   	push   %esi
  800c18:	e8 3e f7 ff ff       	call   80035b <fd2data>
  800c1d:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c1f:	83 c4 10             	add    $0x10,%esp
  800c22:	bf 00 00 00 00       	mov    $0x0,%edi
  800c27:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c2a:	75 09                	jne    800c35 <devpipe_write+0x2a>
	return i;
  800c2c:	89 f8                	mov    %edi,%eax
  800c2e:	eb 23                	jmp    800c53 <devpipe_write+0x48>
			sys_yield();
  800c30:	e8 06 f5 ff ff       	call   80013b <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c35:	8b 43 04             	mov    0x4(%ebx),%eax
  800c38:	8b 0b                	mov    (%ebx),%ecx
  800c3a:	8d 51 20             	lea    0x20(%ecx),%edx
  800c3d:	39 d0                	cmp    %edx,%eax
  800c3f:	72 1a                	jb     800c5b <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  800c41:	89 da                	mov    %ebx,%edx
  800c43:	89 f0                	mov    %esi,%eax
  800c45:	e8 5c ff ff ff       	call   800ba6 <_pipeisclosed>
  800c4a:	85 c0                	test   %eax,%eax
  800c4c:	74 e2                	je     800c30 <devpipe_write+0x25>
				return 0;
  800c4e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c56:	5b                   	pop    %ebx
  800c57:	5e                   	pop    %esi
  800c58:	5f                   	pop    %edi
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c5e:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c62:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c65:	89 c2                	mov    %eax,%edx
  800c67:	c1 fa 1f             	sar    $0x1f,%edx
  800c6a:	89 d1                	mov    %edx,%ecx
  800c6c:	c1 e9 1b             	shr    $0x1b,%ecx
  800c6f:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c72:	83 e2 1f             	and    $0x1f,%edx
  800c75:	29 ca                	sub    %ecx,%edx
  800c77:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c7b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c7f:	83 c0 01             	add    $0x1,%eax
  800c82:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c85:	83 c7 01             	add    $0x1,%edi
  800c88:	eb 9d                	jmp    800c27 <devpipe_write+0x1c>

00800c8a <devpipe_read>:
{
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	57                   	push   %edi
  800c8e:	56                   	push   %esi
  800c8f:	53                   	push   %ebx
  800c90:	83 ec 18             	sub    $0x18,%esp
  800c93:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800c96:	57                   	push   %edi
  800c97:	e8 bf f6 ff ff       	call   80035b <fd2data>
  800c9c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c9e:	83 c4 10             	add    $0x10,%esp
  800ca1:	be 00 00 00 00       	mov    $0x0,%esi
  800ca6:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ca9:	75 13                	jne    800cbe <devpipe_read+0x34>
	return i;
  800cab:	89 f0                	mov    %esi,%eax
  800cad:	eb 02                	jmp    800cb1 <devpipe_read+0x27>
				return i;
  800caf:	89 f0                	mov    %esi,%eax
}
  800cb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb4:	5b                   	pop    %ebx
  800cb5:	5e                   	pop    %esi
  800cb6:	5f                   	pop    %edi
  800cb7:	5d                   	pop    %ebp
  800cb8:	c3                   	ret    
			sys_yield();
  800cb9:	e8 7d f4 ff ff       	call   80013b <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800cbe:	8b 03                	mov    (%ebx),%eax
  800cc0:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cc3:	75 18                	jne    800cdd <devpipe_read+0x53>
			if (i > 0)
  800cc5:	85 f6                	test   %esi,%esi
  800cc7:	75 e6                	jne    800caf <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  800cc9:	89 da                	mov    %ebx,%edx
  800ccb:	89 f8                	mov    %edi,%eax
  800ccd:	e8 d4 fe ff ff       	call   800ba6 <_pipeisclosed>
  800cd2:	85 c0                	test   %eax,%eax
  800cd4:	74 e3                	je     800cb9 <devpipe_read+0x2f>
				return 0;
  800cd6:	b8 00 00 00 00       	mov    $0x0,%eax
  800cdb:	eb d4                	jmp    800cb1 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cdd:	99                   	cltd   
  800cde:	c1 ea 1b             	shr    $0x1b,%edx
  800ce1:	01 d0                	add    %edx,%eax
  800ce3:	83 e0 1f             	and    $0x1f,%eax
  800ce6:	29 d0                	sub    %edx,%eax
  800ce8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800ced:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf0:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800cf3:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800cf6:	83 c6 01             	add    $0x1,%esi
  800cf9:	eb ab                	jmp    800ca6 <devpipe_read+0x1c>

00800cfb <pipe>:
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
  800d00:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d06:	50                   	push   %eax
  800d07:	e8 66 f6 ff ff       	call   800372 <fd_alloc>
  800d0c:	89 c3                	mov    %eax,%ebx
  800d0e:	83 c4 10             	add    $0x10,%esp
  800d11:	85 c0                	test   %eax,%eax
  800d13:	0f 88 23 01 00 00    	js     800e3c <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d19:	83 ec 04             	sub    $0x4,%esp
  800d1c:	68 07 04 00 00       	push   $0x407
  800d21:	ff 75 f4             	push   -0xc(%ebp)
  800d24:	6a 00                	push   $0x0
  800d26:	e8 2f f4 ff ff       	call   80015a <sys_page_alloc>
  800d2b:	89 c3                	mov    %eax,%ebx
  800d2d:	83 c4 10             	add    $0x10,%esp
  800d30:	85 c0                	test   %eax,%eax
  800d32:	0f 88 04 01 00 00    	js     800e3c <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  800d38:	83 ec 0c             	sub    $0xc,%esp
  800d3b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d3e:	50                   	push   %eax
  800d3f:	e8 2e f6 ff ff       	call   800372 <fd_alloc>
  800d44:	89 c3                	mov    %eax,%ebx
  800d46:	83 c4 10             	add    $0x10,%esp
  800d49:	85 c0                	test   %eax,%eax
  800d4b:	0f 88 db 00 00 00    	js     800e2c <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d51:	83 ec 04             	sub    $0x4,%esp
  800d54:	68 07 04 00 00       	push   $0x407
  800d59:	ff 75 f0             	push   -0x10(%ebp)
  800d5c:	6a 00                	push   $0x0
  800d5e:	e8 f7 f3 ff ff       	call   80015a <sys_page_alloc>
  800d63:	89 c3                	mov    %eax,%ebx
  800d65:	83 c4 10             	add    $0x10,%esp
  800d68:	85 c0                	test   %eax,%eax
  800d6a:	0f 88 bc 00 00 00    	js     800e2c <pipe+0x131>
	va = fd2data(fd0);
  800d70:	83 ec 0c             	sub    $0xc,%esp
  800d73:	ff 75 f4             	push   -0xc(%ebp)
  800d76:	e8 e0 f5 ff ff       	call   80035b <fd2data>
  800d7b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7d:	83 c4 0c             	add    $0xc,%esp
  800d80:	68 07 04 00 00       	push   $0x407
  800d85:	50                   	push   %eax
  800d86:	6a 00                	push   $0x0
  800d88:	e8 cd f3 ff ff       	call   80015a <sys_page_alloc>
  800d8d:	89 c3                	mov    %eax,%ebx
  800d8f:	83 c4 10             	add    $0x10,%esp
  800d92:	85 c0                	test   %eax,%eax
  800d94:	0f 88 82 00 00 00    	js     800e1c <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d9a:	83 ec 0c             	sub    $0xc,%esp
  800d9d:	ff 75 f0             	push   -0x10(%ebp)
  800da0:	e8 b6 f5 ff ff       	call   80035b <fd2data>
  800da5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dac:	50                   	push   %eax
  800dad:	6a 00                	push   $0x0
  800daf:	56                   	push   %esi
  800db0:	6a 00                	push   $0x0
  800db2:	e8 e6 f3 ff ff       	call   80019d <sys_page_map>
  800db7:	89 c3                	mov    %eax,%ebx
  800db9:	83 c4 20             	add    $0x20,%esp
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	78 4e                	js     800e0e <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  800dc0:	a1 20 30 80 00       	mov    0x803020,%eax
  800dc5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dc8:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800dca:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dcd:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800dd4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dd7:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800dd9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ddc:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800de3:	83 ec 0c             	sub    $0xc,%esp
  800de6:	ff 75 f4             	push   -0xc(%ebp)
  800de9:	e8 5d f5 ff ff       	call   80034b <fd2num>
  800dee:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df1:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800df3:	83 c4 04             	add    $0x4,%esp
  800df6:	ff 75 f0             	push   -0x10(%ebp)
  800df9:	e8 4d f5 ff ff       	call   80034b <fd2num>
  800dfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e01:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e04:	83 c4 10             	add    $0x10,%esp
  800e07:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0c:	eb 2e                	jmp    800e3c <pipe+0x141>
	sys_page_unmap(0, va);
  800e0e:	83 ec 08             	sub    $0x8,%esp
  800e11:	56                   	push   %esi
  800e12:	6a 00                	push   $0x0
  800e14:	e8 c6 f3 ff ff       	call   8001df <sys_page_unmap>
  800e19:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e1c:	83 ec 08             	sub    $0x8,%esp
  800e1f:	ff 75 f0             	push   -0x10(%ebp)
  800e22:	6a 00                	push   $0x0
  800e24:	e8 b6 f3 ff ff       	call   8001df <sys_page_unmap>
  800e29:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e2c:	83 ec 08             	sub    $0x8,%esp
  800e2f:	ff 75 f4             	push   -0xc(%ebp)
  800e32:	6a 00                	push   $0x0
  800e34:	e8 a6 f3 ff ff       	call   8001df <sys_page_unmap>
  800e39:	83 c4 10             	add    $0x10,%esp
}
  800e3c:	89 d8                	mov    %ebx,%eax
  800e3e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e41:	5b                   	pop    %ebx
  800e42:	5e                   	pop    %esi
  800e43:	5d                   	pop    %ebp
  800e44:	c3                   	ret    

00800e45 <pipeisclosed>:
{
  800e45:	55                   	push   %ebp
  800e46:	89 e5                	mov    %esp,%ebp
  800e48:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e4b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e4e:	50                   	push   %eax
  800e4f:	ff 75 08             	push   0x8(%ebp)
  800e52:	e8 6b f5 ff ff       	call   8003c2 <fd_lookup>
  800e57:	83 c4 10             	add    $0x10,%esp
  800e5a:	85 c0                	test   %eax,%eax
  800e5c:	78 18                	js     800e76 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e5e:	83 ec 0c             	sub    $0xc,%esp
  800e61:	ff 75 f4             	push   -0xc(%ebp)
  800e64:	e8 f2 f4 ff ff       	call   80035b <fd2data>
  800e69:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e6e:	e8 33 fd ff ff       	call   800ba6 <_pipeisclosed>
  800e73:	83 c4 10             	add    $0x10,%esp
}
  800e76:	c9                   	leave  
  800e77:	c3                   	ret    

00800e78 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  800e78:	b8 00 00 00 00       	mov    $0x0,%eax
  800e7d:	c3                   	ret    

00800e7e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e84:	68 76 1e 80 00       	push   $0x801e76
  800e89:	ff 75 0c             	push   0xc(%ebp)
  800e8c:	e8 10 08 00 00       	call   8016a1 <strcpy>
	return 0;
}
  800e91:	b8 00 00 00 00       	mov    $0x0,%eax
  800e96:	c9                   	leave  
  800e97:	c3                   	ret    

00800e98 <devcons_write>:
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	57                   	push   %edi
  800e9c:	56                   	push   %esi
  800e9d:	53                   	push   %ebx
  800e9e:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ea4:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ea9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800eaf:	eb 2e                	jmp    800edf <devcons_write+0x47>
		m = n - tot;
  800eb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eb4:	29 f3                	sub    %esi,%ebx
  800eb6:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800ebb:	39 c3                	cmp    %eax,%ebx
  800ebd:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800ec0:	83 ec 04             	sub    $0x4,%esp
  800ec3:	53                   	push   %ebx
  800ec4:	89 f0                	mov    %esi,%eax
  800ec6:	03 45 0c             	add    0xc(%ebp),%eax
  800ec9:	50                   	push   %eax
  800eca:	57                   	push   %edi
  800ecb:	e8 67 09 00 00       	call   801837 <memmove>
		sys_cputs(buf, m);
  800ed0:	83 c4 08             	add    $0x8,%esp
  800ed3:	53                   	push   %ebx
  800ed4:	57                   	push   %edi
  800ed5:	e8 c4 f1 ff ff       	call   80009e <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800eda:	01 de                	add    %ebx,%esi
  800edc:	83 c4 10             	add    $0x10,%esp
  800edf:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ee2:	72 cd                	jb     800eb1 <devcons_write+0x19>
}
  800ee4:	89 f0                	mov    %esi,%eax
  800ee6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee9:	5b                   	pop    %ebx
  800eea:	5e                   	pop    %esi
  800eeb:	5f                   	pop    %edi
  800eec:	5d                   	pop    %ebp
  800eed:	c3                   	ret    

00800eee <devcons_read>:
{
  800eee:	55                   	push   %ebp
  800eef:	89 e5                	mov    %esp,%ebp
  800ef1:	83 ec 08             	sub    $0x8,%esp
  800ef4:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800ef9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800efd:	75 07                	jne    800f06 <devcons_read+0x18>
  800eff:	eb 1f                	jmp    800f20 <devcons_read+0x32>
		sys_yield();
  800f01:	e8 35 f2 ff ff       	call   80013b <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800f06:	e8 b1 f1 ff ff       	call   8000bc <sys_cgetc>
  800f0b:	85 c0                	test   %eax,%eax
  800f0d:	74 f2                	je     800f01 <devcons_read+0x13>
	if (c < 0)
  800f0f:	78 0f                	js     800f20 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  800f11:	83 f8 04             	cmp    $0x4,%eax
  800f14:	74 0c                	je     800f22 <devcons_read+0x34>
	*(char*)vbuf = c;
  800f16:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f19:	88 02                	mov    %al,(%edx)
	return 1;
  800f1b:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f20:	c9                   	leave  
  800f21:	c3                   	ret    
		return 0;
  800f22:	b8 00 00 00 00       	mov    $0x0,%eax
  800f27:	eb f7                	jmp    800f20 <devcons_read+0x32>

00800f29 <cputchar>:
{
  800f29:	55                   	push   %ebp
  800f2a:	89 e5                	mov    %esp,%ebp
  800f2c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f32:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f35:	6a 01                	push   $0x1
  800f37:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f3a:	50                   	push   %eax
  800f3b:	e8 5e f1 ff ff       	call   80009e <sys_cputs>
}
  800f40:	83 c4 10             	add    $0x10,%esp
  800f43:	c9                   	leave  
  800f44:	c3                   	ret    

00800f45 <getchar>:
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f4b:	6a 01                	push   $0x1
  800f4d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f50:	50                   	push   %eax
  800f51:	6a 00                	push   $0x0
  800f53:	e8 ce f6 ff ff       	call   800626 <read>
	if (r < 0)
  800f58:	83 c4 10             	add    $0x10,%esp
  800f5b:	85 c0                	test   %eax,%eax
  800f5d:	78 06                	js     800f65 <getchar+0x20>
	if (r < 1)
  800f5f:	74 06                	je     800f67 <getchar+0x22>
	return c;
  800f61:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800f65:	c9                   	leave  
  800f66:	c3                   	ret    
		return -E_EOF;
  800f67:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800f6c:	eb f7                	jmp    800f65 <getchar+0x20>

00800f6e <iscons>:
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f74:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f77:	50                   	push   %eax
  800f78:	ff 75 08             	push   0x8(%ebp)
  800f7b:	e8 42 f4 ff ff       	call   8003c2 <fd_lookup>
  800f80:	83 c4 10             	add    $0x10,%esp
  800f83:	85 c0                	test   %eax,%eax
  800f85:	78 11                	js     800f98 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800f87:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f8a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f90:	39 10                	cmp    %edx,(%eax)
  800f92:	0f 94 c0             	sete   %al
  800f95:	0f b6 c0             	movzbl %al,%eax
}
  800f98:	c9                   	leave  
  800f99:	c3                   	ret    

00800f9a <opencons>:
{
  800f9a:	55                   	push   %ebp
  800f9b:	89 e5                	mov    %esp,%ebp
  800f9d:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800fa0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa3:	50                   	push   %eax
  800fa4:	e8 c9 f3 ff ff       	call   800372 <fd_alloc>
  800fa9:	83 c4 10             	add    $0x10,%esp
  800fac:	85 c0                	test   %eax,%eax
  800fae:	78 3a                	js     800fea <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fb0:	83 ec 04             	sub    $0x4,%esp
  800fb3:	68 07 04 00 00       	push   $0x407
  800fb8:	ff 75 f4             	push   -0xc(%ebp)
  800fbb:	6a 00                	push   $0x0
  800fbd:	e8 98 f1 ff ff       	call   80015a <sys_page_alloc>
  800fc2:	83 c4 10             	add    $0x10,%esp
  800fc5:	85 c0                	test   %eax,%eax
  800fc7:	78 21                	js     800fea <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fcc:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fd2:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fde:	83 ec 0c             	sub    $0xc,%esp
  800fe1:	50                   	push   %eax
  800fe2:	e8 64 f3 ff ff       	call   80034b <fd2num>
  800fe7:	83 c4 10             	add    $0x10,%esp
}
  800fea:	c9                   	leave  
  800feb:	c3                   	ret    

00800fec <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fec:	55                   	push   %ebp
  800fed:	89 e5                	mov    %esp,%ebp
  800fef:	56                   	push   %esi
  800ff0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800ff1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800ff4:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800ffa:	e8 1d f1 ff ff       	call   80011c <sys_getenvid>
  800fff:	83 ec 0c             	sub    $0xc,%esp
  801002:	ff 75 0c             	push   0xc(%ebp)
  801005:	ff 75 08             	push   0x8(%ebp)
  801008:	56                   	push   %esi
  801009:	50                   	push   %eax
  80100a:	68 84 1e 80 00       	push   $0x801e84
  80100f:	e8 b3 00 00 00       	call   8010c7 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801014:	83 c4 18             	add    $0x18,%esp
  801017:	53                   	push   %ebx
  801018:	ff 75 10             	push   0x10(%ebp)
  80101b:	e8 56 00 00 00       	call   801076 <vcprintf>
	cprintf("\n");
  801020:	c7 04 24 6f 1e 80 00 	movl   $0x801e6f,(%esp)
  801027:	e8 9b 00 00 00       	call   8010c7 <cprintf>
  80102c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80102f:	cc                   	int3   
  801030:	eb fd                	jmp    80102f <_panic+0x43>

00801032 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	53                   	push   %ebx
  801036:	83 ec 04             	sub    $0x4,%esp
  801039:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80103c:	8b 13                	mov    (%ebx),%edx
  80103e:	8d 42 01             	lea    0x1(%edx),%eax
  801041:	89 03                	mov    %eax,(%ebx)
  801043:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801046:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80104a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80104f:	74 09                	je     80105a <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801051:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801055:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801058:	c9                   	leave  
  801059:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80105a:	83 ec 08             	sub    $0x8,%esp
  80105d:	68 ff 00 00 00       	push   $0xff
  801062:	8d 43 08             	lea    0x8(%ebx),%eax
  801065:	50                   	push   %eax
  801066:	e8 33 f0 ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  80106b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801071:	83 c4 10             	add    $0x10,%esp
  801074:	eb db                	jmp    801051 <putch+0x1f>

00801076 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80107f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801086:	00 00 00 
	b.cnt = 0;
  801089:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801090:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801093:	ff 75 0c             	push   0xc(%ebp)
  801096:	ff 75 08             	push   0x8(%ebp)
  801099:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80109f:	50                   	push   %eax
  8010a0:	68 32 10 80 00       	push   $0x801032
  8010a5:	e8 14 01 00 00       	call   8011be <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010aa:	83 c4 08             	add    $0x8,%esp
  8010ad:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8010b3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010b9:	50                   	push   %eax
  8010ba:	e8 df ef ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  8010bf:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010c5:	c9                   	leave  
  8010c6:	c3                   	ret    

008010c7 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010cd:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010d0:	50                   	push   %eax
  8010d1:	ff 75 08             	push   0x8(%ebp)
  8010d4:	e8 9d ff ff ff       	call   801076 <vcprintf>
	va_end(ap);

	return cnt;
}
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    

008010db <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	57                   	push   %edi
  8010df:	56                   	push   %esi
  8010e0:	53                   	push   %ebx
  8010e1:	83 ec 1c             	sub    $0x1c,%esp
  8010e4:	89 c7                	mov    %eax,%edi
  8010e6:	89 d6                	mov    %edx,%esi
  8010e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ee:	89 d1                	mov    %edx,%ecx
  8010f0:	89 c2                	mov    %eax,%edx
  8010f2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010f5:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8010f8:	8b 45 10             	mov    0x10(%ebp),%eax
  8010fb:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801101:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801108:	39 c2                	cmp    %eax,%edx
  80110a:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80110d:	72 3e                	jb     80114d <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80110f:	83 ec 0c             	sub    $0xc,%esp
  801112:	ff 75 18             	push   0x18(%ebp)
  801115:	83 eb 01             	sub    $0x1,%ebx
  801118:	53                   	push   %ebx
  801119:	50                   	push   %eax
  80111a:	83 ec 08             	sub    $0x8,%esp
  80111d:	ff 75 e4             	push   -0x1c(%ebp)
  801120:	ff 75 e0             	push   -0x20(%ebp)
  801123:	ff 75 dc             	push   -0x24(%ebp)
  801126:	ff 75 d8             	push   -0x28(%ebp)
  801129:	e8 f2 09 00 00       	call   801b20 <__udivdi3>
  80112e:	83 c4 18             	add    $0x18,%esp
  801131:	52                   	push   %edx
  801132:	50                   	push   %eax
  801133:	89 f2                	mov    %esi,%edx
  801135:	89 f8                	mov    %edi,%eax
  801137:	e8 9f ff ff ff       	call   8010db <printnum>
  80113c:	83 c4 20             	add    $0x20,%esp
  80113f:	eb 13                	jmp    801154 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801141:	83 ec 08             	sub    $0x8,%esp
  801144:	56                   	push   %esi
  801145:	ff 75 18             	push   0x18(%ebp)
  801148:	ff d7                	call   *%edi
  80114a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80114d:	83 eb 01             	sub    $0x1,%ebx
  801150:	85 db                	test   %ebx,%ebx
  801152:	7f ed                	jg     801141 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801154:	83 ec 08             	sub    $0x8,%esp
  801157:	56                   	push   %esi
  801158:	83 ec 04             	sub    $0x4,%esp
  80115b:	ff 75 e4             	push   -0x1c(%ebp)
  80115e:	ff 75 e0             	push   -0x20(%ebp)
  801161:	ff 75 dc             	push   -0x24(%ebp)
  801164:	ff 75 d8             	push   -0x28(%ebp)
  801167:	e8 d4 0a 00 00       	call   801c40 <__umoddi3>
  80116c:	83 c4 14             	add    $0x14,%esp
  80116f:	0f be 80 a7 1e 80 00 	movsbl 0x801ea7(%eax),%eax
  801176:	50                   	push   %eax
  801177:	ff d7                	call   *%edi
}
  801179:	83 c4 10             	add    $0x10,%esp
  80117c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117f:	5b                   	pop    %ebx
  801180:	5e                   	pop    %esi
  801181:	5f                   	pop    %edi
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80118a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80118e:	8b 10                	mov    (%eax),%edx
  801190:	3b 50 04             	cmp    0x4(%eax),%edx
  801193:	73 0a                	jae    80119f <sprintputch+0x1b>
		*b->buf++ = ch;
  801195:	8d 4a 01             	lea    0x1(%edx),%ecx
  801198:	89 08                	mov    %ecx,(%eax)
  80119a:	8b 45 08             	mov    0x8(%ebp),%eax
  80119d:	88 02                	mov    %al,(%edx)
}
  80119f:	5d                   	pop    %ebp
  8011a0:	c3                   	ret    

008011a1 <printfmt>:
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8011a7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011aa:	50                   	push   %eax
  8011ab:	ff 75 10             	push   0x10(%ebp)
  8011ae:	ff 75 0c             	push   0xc(%ebp)
  8011b1:	ff 75 08             	push   0x8(%ebp)
  8011b4:	e8 05 00 00 00       	call   8011be <vprintfmt>
}
  8011b9:	83 c4 10             	add    $0x10,%esp
  8011bc:	c9                   	leave  
  8011bd:	c3                   	ret    

008011be <vprintfmt>:
{
  8011be:	55                   	push   %ebp
  8011bf:	89 e5                	mov    %esp,%ebp
  8011c1:	57                   	push   %edi
  8011c2:	56                   	push   %esi
  8011c3:	53                   	push   %ebx
  8011c4:	83 ec 3c             	sub    $0x3c,%esp
  8011c7:	8b 75 08             	mov    0x8(%ebp),%esi
  8011ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011cd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011d0:	eb 0a                	jmp    8011dc <vprintfmt+0x1e>
			putch(ch, putdat);
  8011d2:	83 ec 08             	sub    $0x8,%esp
  8011d5:	53                   	push   %ebx
  8011d6:	50                   	push   %eax
  8011d7:	ff d6                	call   *%esi
  8011d9:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8011dc:	83 c7 01             	add    $0x1,%edi
  8011df:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8011e3:	83 f8 25             	cmp    $0x25,%eax
  8011e6:	74 0c                	je     8011f4 <vprintfmt+0x36>
			if (ch == '\0')
  8011e8:	85 c0                	test   %eax,%eax
  8011ea:	75 e6                	jne    8011d2 <vprintfmt+0x14>
}
  8011ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ef:	5b                   	pop    %ebx
  8011f0:	5e                   	pop    %esi
  8011f1:	5f                   	pop    %edi
  8011f2:	5d                   	pop    %ebp
  8011f3:	c3                   	ret    
		padc = ' ';
  8011f4:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8011f8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8011ff:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801206:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80120d:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801212:	8d 47 01             	lea    0x1(%edi),%eax
  801215:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801218:	0f b6 17             	movzbl (%edi),%edx
  80121b:	8d 42 dd             	lea    -0x23(%edx),%eax
  80121e:	3c 55                	cmp    $0x55,%al
  801220:	0f 87 bb 03 00 00    	ja     8015e1 <vprintfmt+0x423>
  801226:	0f b6 c0             	movzbl %al,%eax
  801229:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  801230:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801233:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801237:	eb d9                	jmp    801212 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801239:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80123c:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801240:	eb d0                	jmp    801212 <vprintfmt+0x54>
  801242:	0f b6 d2             	movzbl %dl,%edx
  801245:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801248:	b8 00 00 00 00       	mov    $0x0,%eax
  80124d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801250:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801253:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801257:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80125a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80125d:	83 f9 09             	cmp    $0x9,%ecx
  801260:	77 55                	ja     8012b7 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  801262:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801265:	eb e9                	jmp    801250 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801267:	8b 45 14             	mov    0x14(%ebp),%eax
  80126a:	8b 00                	mov    (%eax),%eax
  80126c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80126f:	8b 45 14             	mov    0x14(%ebp),%eax
  801272:	8d 40 04             	lea    0x4(%eax),%eax
  801275:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801278:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80127b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80127f:	79 91                	jns    801212 <vprintfmt+0x54>
				width = precision, precision = -1;
  801281:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801284:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801287:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80128e:	eb 82                	jmp    801212 <vprintfmt+0x54>
  801290:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801293:	85 d2                	test   %edx,%edx
  801295:	b8 00 00 00 00       	mov    $0x0,%eax
  80129a:	0f 49 c2             	cmovns %edx,%eax
  80129d:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8012a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012a3:	e9 6a ff ff ff       	jmp    801212 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8012a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012ab:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8012b2:	e9 5b ff ff ff       	jmp    801212 <vprintfmt+0x54>
  8012b7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012bd:	eb bc                	jmp    80127b <vprintfmt+0xbd>
			lflag++;
  8012bf:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012c5:	e9 48 ff ff ff       	jmp    801212 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8012ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8012cd:	8d 78 04             	lea    0x4(%eax),%edi
  8012d0:	83 ec 08             	sub    $0x8,%esp
  8012d3:	53                   	push   %ebx
  8012d4:	ff 30                	push   (%eax)
  8012d6:	ff d6                	call   *%esi
			break;
  8012d8:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8012db:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8012de:	e9 9d 02 00 00       	jmp    801580 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8012e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e6:	8d 78 04             	lea    0x4(%eax),%edi
  8012e9:	8b 10                	mov    (%eax),%edx
  8012eb:	89 d0                	mov    %edx,%eax
  8012ed:	f7 d8                	neg    %eax
  8012ef:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8012f2:	83 f8 0f             	cmp    $0xf,%eax
  8012f5:	7f 23                	jg     80131a <vprintfmt+0x15c>
  8012f7:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  8012fe:	85 d2                	test   %edx,%edx
  801300:	74 18                	je     80131a <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  801302:	52                   	push   %edx
  801303:	68 3d 1e 80 00       	push   $0x801e3d
  801308:	53                   	push   %ebx
  801309:	56                   	push   %esi
  80130a:	e8 92 fe ff ff       	call   8011a1 <printfmt>
  80130f:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801312:	89 7d 14             	mov    %edi,0x14(%ebp)
  801315:	e9 66 02 00 00       	jmp    801580 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  80131a:	50                   	push   %eax
  80131b:	68 bf 1e 80 00       	push   $0x801ebf
  801320:	53                   	push   %ebx
  801321:	56                   	push   %esi
  801322:	e8 7a fe ff ff       	call   8011a1 <printfmt>
  801327:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80132a:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80132d:	e9 4e 02 00 00       	jmp    801580 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  801332:	8b 45 14             	mov    0x14(%ebp),%eax
  801335:	83 c0 04             	add    $0x4,%eax
  801338:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80133b:	8b 45 14             	mov    0x14(%ebp),%eax
  80133e:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801340:	85 d2                	test   %edx,%edx
  801342:	b8 b8 1e 80 00       	mov    $0x801eb8,%eax
  801347:	0f 45 c2             	cmovne %edx,%eax
  80134a:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80134d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801351:	7e 06                	jle    801359 <vprintfmt+0x19b>
  801353:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801357:	75 0d                	jne    801366 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801359:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80135c:	89 c7                	mov    %eax,%edi
  80135e:	03 45 e0             	add    -0x20(%ebp),%eax
  801361:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801364:	eb 55                	jmp    8013bb <vprintfmt+0x1fd>
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	ff 75 d8             	push   -0x28(%ebp)
  80136c:	ff 75 cc             	push   -0x34(%ebp)
  80136f:	e8 0a 03 00 00       	call   80167e <strnlen>
  801374:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801377:	29 c1                	sub    %eax,%ecx
  801379:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  80137c:	83 c4 10             	add    $0x10,%esp
  80137f:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  801381:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801385:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801388:	eb 0f                	jmp    801399 <vprintfmt+0x1db>
					putch(padc, putdat);
  80138a:	83 ec 08             	sub    $0x8,%esp
  80138d:	53                   	push   %ebx
  80138e:	ff 75 e0             	push   -0x20(%ebp)
  801391:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801393:	83 ef 01             	sub    $0x1,%edi
  801396:	83 c4 10             	add    $0x10,%esp
  801399:	85 ff                	test   %edi,%edi
  80139b:	7f ed                	jg     80138a <vprintfmt+0x1cc>
  80139d:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8013a0:	85 d2                	test   %edx,%edx
  8013a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a7:	0f 49 c2             	cmovns %edx,%eax
  8013aa:	29 c2                	sub    %eax,%edx
  8013ac:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8013af:	eb a8                	jmp    801359 <vprintfmt+0x19b>
					putch(ch, putdat);
  8013b1:	83 ec 08             	sub    $0x8,%esp
  8013b4:	53                   	push   %ebx
  8013b5:	52                   	push   %edx
  8013b6:	ff d6                	call   *%esi
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013be:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013c0:	83 c7 01             	add    $0x1,%edi
  8013c3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8013c7:	0f be d0             	movsbl %al,%edx
  8013ca:	85 d2                	test   %edx,%edx
  8013cc:	74 4b                	je     801419 <vprintfmt+0x25b>
  8013ce:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013d2:	78 06                	js     8013da <vprintfmt+0x21c>
  8013d4:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8013d8:	78 1e                	js     8013f8 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8013da:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8013de:	74 d1                	je     8013b1 <vprintfmt+0x1f3>
  8013e0:	0f be c0             	movsbl %al,%eax
  8013e3:	83 e8 20             	sub    $0x20,%eax
  8013e6:	83 f8 5e             	cmp    $0x5e,%eax
  8013e9:	76 c6                	jbe    8013b1 <vprintfmt+0x1f3>
					putch('?', putdat);
  8013eb:	83 ec 08             	sub    $0x8,%esp
  8013ee:	53                   	push   %ebx
  8013ef:	6a 3f                	push   $0x3f
  8013f1:	ff d6                	call   *%esi
  8013f3:	83 c4 10             	add    $0x10,%esp
  8013f6:	eb c3                	jmp    8013bb <vprintfmt+0x1fd>
  8013f8:	89 cf                	mov    %ecx,%edi
  8013fa:	eb 0e                	jmp    80140a <vprintfmt+0x24c>
				putch(' ', putdat);
  8013fc:	83 ec 08             	sub    $0x8,%esp
  8013ff:	53                   	push   %ebx
  801400:	6a 20                	push   $0x20
  801402:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801404:	83 ef 01             	sub    $0x1,%edi
  801407:	83 c4 10             	add    $0x10,%esp
  80140a:	85 ff                	test   %edi,%edi
  80140c:	7f ee                	jg     8013fc <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80140e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801411:	89 45 14             	mov    %eax,0x14(%ebp)
  801414:	e9 67 01 00 00       	jmp    801580 <vprintfmt+0x3c2>
  801419:	89 cf                	mov    %ecx,%edi
  80141b:	eb ed                	jmp    80140a <vprintfmt+0x24c>
	if (lflag >= 2)
  80141d:	83 f9 01             	cmp    $0x1,%ecx
  801420:	7f 1b                	jg     80143d <vprintfmt+0x27f>
	else if (lflag)
  801422:	85 c9                	test   %ecx,%ecx
  801424:	74 63                	je     801489 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  801426:	8b 45 14             	mov    0x14(%ebp),%eax
  801429:	8b 00                	mov    (%eax),%eax
  80142b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80142e:	99                   	cltd   
  80142f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801432:	8b 45 14             	mov    0x14(%ebp),%eax
  801435:	8d 40 04             	lea    0x4(%eax),%eax
  801438:	89 45 14             	mov    %eax,0x14(%ebp)
  80143b:	eb 17                	jmp    801454 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80143d:	8b 45 14             	mov    0x14(%ebp),%eax
  801440:	8b 50 04             	mov    0x4(%eax),%edx
  801443:	8b 00                	mov    (%eax),%eax
  801445:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801448:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80144b:	8b 45 14             	mov    0x14(%ebp),%eax
  80144e:	8d 40 08             	lea    0x8(%eax),%eax
  801451:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801454:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801457:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80145a:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80145f:	85 c9                	test   %ecx,%ecx
  801461:	0f 89 ff 00 00 00    	jns    801566 <vprintfmt+0x3a8>
				putch('-', putdat);
  801467:	83 ec 08             	sub    $0x8,%esp
  80146a:	53                   	push   %ebx
  80146b:	6a 2d                	push   $0x2d
  80146d:	ff d6                	call   *%esi
				num = -(long long) num;
  80146f:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801472:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801475:	f7 da                	neg    %edx
  801477:	83 d1 00             	adc    $0x0,%ecx
  80147a:	f7 d9                	neg    %ecx
  80147c:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80147f:	bf 0a 00 00 00       	mov    $0xa,%edi
  801484:	e9 dd 00 00 00       	jmp    801566 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801489:	8b 45 14             	mov    0x14(%ebp),%eax
  80148c:	8b 00                	mov    (%eax),%eax
  80148e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801491:	99                   	cltd   
  801492:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801495:	8b 45 14             	mov    0x14(%ebp),%eax
  801498:	8d 40 04             	lea    0x4(%eax),%eax
  80149b:	89 45 14             	mov    %eax,0x14(%ebp)
  80149e:	eb b4                	jmp    801454 <vprintfmt+0x296>
	if (lflag >= 2)
  8014a0:	83 f9 01             	cmp    $0x1,%ecx
  8014a3:	7f 1e                	jg     8014c3 <vprintfmt+0x305>
	else if (lflag)
  8014a5:	85 c9                	test   %ecx,%ecx
  8014a7:	74 32                	je     8014db <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8014a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ac:	8b 10                	mov    (%eax),%edx
  8014ae:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014b3:	8d 40 04             	lea    0x4(%eax),%eax
  8014b6:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014b9:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8014be:	e9 a3 00 00 00       	jmp    801566 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8014c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8014c6:	8b 10                	mov    (%eax),%edx
  8014c8:	8b 48 04             	mov    0x4(%eax),%ecx
  8014cb:	8d 40 08             	lea    0x8(%eax),%eax
  8014ce:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014d1:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8014d6:	e9 8b 00 00 00       	jmp    801566 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8014db:	8b 45 14             	mov    0x14(%ebp),%eax
  8014de:	8b 10                	mov    (%eax),%edx
  8014e0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014e5:	8d 40 04             	lea    0x4(%eax),%eax
  8014e8:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014eb:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8014f0:	eb 74                	jmp    801566 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8014f2:	83 f9 01             	cmp    $0x1,%ecx
  8014f5:	7f 1b                	jg     801512 <vprintfmt+0x354>
	else if (lflag)
  8014f7:	85 c9                	test   %ecx,%ecx
  8014f9:	74 2c                	je     801527 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8014fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fe:	8b 10                	mov    (%eax),%edx
  801500:	b9 00 00 00 00       	mov    $0x0,%ecx
  801505:	8d 40 04             	lea    0x4(%eax),%eax
  801508:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80150b:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  801510:	eb 54                	jmp    801566 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801512:	8b 45 14             	mov    0x14(%ebp),%eax
  801515:	8b 10                	mov    (%eax),%edx
  801517:	8b 48 04             	mov    0x4(%eax),%ecx
  80151a:	8d 40 08             	lea    0x8(%eax),%eax
  80151d:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801520:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  801525:	eb 3f                	jmp    801566 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801527:	8b 45 14             	mov    0x14(%ebp),%eax
  80152a:	8b 10                	mov    (%eax),%edx
  80152c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801531:	8d 40 04             	lea    0x4(%eax),%eax
  801534:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801537:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  80153c:	eb 28                	jmp    801566 <vprintfmt+0x3a8>
			putch('0', putdat);
  80153e:	83 ec 08             	sub    $0x8,%esp
  801541:	53                   	push   %ebx
  801542:	6a 30                	push   $0x30
  801544:	ff d6                	call   *%esi
			putch('x', putdat);
  801546:	83 c4 08             	add    $0x8,%esp
  801549:	53                   	push   %ebx
  80154a:	6a 78                	push   $0x78
  80154c:	ff d6                	call   *%esi
			num = (unsigned long long)
  80154e:	8b 45 14             	mov    0x14(%ebp),%eax
  801551:	8b 10                	mov    (%eax),%edx
  801553:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801558:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  80155b:	8d 40 04             	lea    0x4(%eax),%eax
  80155e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801561:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801566:	83 ec 0c             	sub    $0xc,%esp
  801569:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80156d:	50                   	push   %eax
  80156e:	ff 75 e0             	push   -0x20(%ebp)
  801571:	57                   	push   %edi
  801572:	51                   	push   %ecx
  801573:	52                   	push   %edx
  801574:	89 da                	mov    %ebx,%edx
  801576:	89 f0                	mov    %esi,%eax
  801578:	e8 5e fb ff ff       	call   8010db <printnum>
			break;
  80157d:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801580:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801583:	e9 54 fc ff ff       	jmp    8011dc <vprintfmt+0x1e>
	if (lflag >= 2)
  801588:	83 f9 01             	cmp    $0x1,%ecx
  80158b:	7f 1b                	jg     8015a8 <vprintfmt+0x3ea>
	else if (lflag)
  80158d:	85 c9                	test   %ecx,%ecx
  80158f:	74 2c                	je     8015bd <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801591:	8b 45 14             	mov    0x14(%ebp),%eax
  801594:	8b 10                	mov    (%eax),%edx
  801596:	b9 00 00 00 00       	mov    $0x0,%ecx
  80159b:	8d 40 04             	lea    0x4(%eax),%eax
  80159e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015a1:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  8015a6:	eb be                	jmp    801566 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8015a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ab:	8b 10                	mov    (%eax),%edx
  8015ad:	8b 48 04             	mov    0x4(%eax),%ecx
  8015b0:	8d 40 08             	lea    0x8(%eax),%eax
  8015b3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015b6:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8015bb:	eb a9                	jmp    801566 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8015bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8015c0:	8b 10                	mov    (%eax),%edx
  8015c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015c7:	8d 40 04             	lea    0x4(%eax),%eax
  8015ca:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015cd:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8015d2:	eb 92                	jmp    801566 <vprintfmt+0x3a8>
			putch(ch, putdat);
  8015d4:	83 ec 08             	sub    $0x8,%esp
  8015d7:	53                   	push   %ebx
  8015d8:	6a 25                	push   $0x25
  8015da:	ff d6                	call   *%esi
			break;
  8015dc:	83 c4 10             	add    $0x10,%esp
  8015df:	eb 9f                	jmp    801580 <vprintfmt+0x3c2>
			putch('%', putdat);
  8015e1:	83 ec 08             	sub    $0x8,%esp
  8015e4:	53                   	push   %ebx
  8015e5:	6a 25                	push   $0x25
  8015e7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	89 f8                	mov    %edi,%eax
  8015ee:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8015f2:	74 05                	je     8015f9 <vprintfmt+0x43b>
  8015f4:	83 e8 01             	sub    $0x1,%eax
  8015f7:	eb f5                	jmp    8015ee <vprintfmt+0x430>
  8015f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015fc:	eb 82                	jmp    801580 <vprintfmt+0x3c2>

008015fe <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015fe:	55                   	push   %ebp
  8015ff:	89 e5                	mov    %esp,%ebp
  801601:	83 ec 18             	sub    $0x18,%esp
  801604:	8b 45 08             	mov    0x8(%ebp),%eax
  801607:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80160a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80160d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801611:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801614:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80161b:	85 c0                	test   %eax,%eax
  80161d:	74 26                	je     801645 <vsnprintf+0x47>
  80161f:	85 d2                	test   %edx,%edx
  801621:	7e 22                	jle    801645 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801623:	ff 75 14             	push   0x14(%ebp)
  801626:	ff 75 10             	push   0x10(%ebp)
  801629:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80162c:	50                   	push   %eax
  80162d:	68 84 11 80 00       	push   $0x801184
  801632:	e8 87 fb ff ff       	call   8011be <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801637:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80163a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80163d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801640:	83 c4 10             	add    $0x10,%esp
}
  801643:	c9                   	leave  
  801644:	c3                   	ret    
		return -E_INVAL;
  801645:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80164a:	eb f7                	jmp    801643 <vsnprintf+0x45>

0080164c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801652:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801655:	50                   	push   %eax
  801656:	ff 75 10             	push   0x10(%ebp)
  801659:	ff 75 0c             	push   0xc(%ebp)
  80165c:	ff 75 08             	push   0x8(%ebp)
  80165f:	e8 9a ff ff ff       	call   8015fe <vsnprintf>
	va_end(ap);

	return rc;
}
  801664:	c9                   	leave  
  801665:	c3                   	ret    

00801666 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80166c:	b8 00 00 00 00       	mov    $0x0,%eax
  801671:	eb 03                	jmp    801676 <strlen+0x10>
		n++;
  801673:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801676:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80167a:	75 f7                	jne    801673 <strlen+0xd>
	return n;
}
  80167c:	5d                   	pop    %ebp
  80167d:	c3                   	ret    

0080167e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801684:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801687:	b8 00 00 00 00       	mov    $0x0,%eax
  80168c:	eb 03                	jmp    801691 <strnlen+0x13>
		n++;
  80168e:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801691:	39 d0                	cmp    %edx,%eax
  801693:	74 08                	je     80169d <strnlen+0x1f>
  801695:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801699:	75 f3                	jne    80168e <strnlen+0x10>
  80169b:	89 c2                	mov    %eax,%edx
	return n;
}
  80169d:	89 d0                	mov    %edx,%eax
  80169f:	5d                   	pop    %ebp
  8016a0:	c3                   	ret    

008016a1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	53                   	push   %ebx
  8016a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b0:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016b4:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016b7:	83 c0 01             	add    $0x1,%eax
  8016ba:	84 d2                	test   %dl,%dl
  8016bc:	75 f2                	jne    8016b0 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8016be:	89 c8                	mov    %ecx,%eax
  8016c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c3:	c9                   	leave  
  8016c4:	c3                   	ret    

008016c5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	53                   	push   %ebx
  8016c9:	83 ec 10             	sub    $0x10,%esp
  8016cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016cf:	53                   	push   %ebx
  8016d0:	e8 91 ff ff ff       	call   801666 <strlen>
  8016d5:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8016d8:	ff 75 0c             	push   0xc(%ebp)
  8016db:	01 d8                	add    %ebx,%eax
  8016dd:	50                   	push   %eax
  8016de:	e8 be ff ff ff       	call   8016a1 <strcpy>
	return dst;
}
  8016e3:	89 d8                	mov    %ebx,%eax
  8016e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e8:	c9                   	leave  
  8016e9:	c3                   	ret    

008016ea <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	56                   	push   %esi
  8016ee:	53                   	push   %ebx
  8016ef:	8b 75 08             	mov    0x8(%ebp),%esi
  8016f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016f5:	89 f3                	mov    %esi,%ebx
  8016f7:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016fa:	89 f0                	mov    %esi,%eax
  8016fc:	eb 0f                	jmp    80170d <strncpy+0x23>
		*dst++ = *src;
  8016fe:	83 c0 01             	add    $0x1,%eax
  801701:	0f b6 0a             	movzbl (%edx),%ecx
  801704:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801707:	80 f9 01             	cmp    $0x1,%cl
  80170a:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  80170d:	39 d8                	cmp    %ebx,%eax
  80170f:	75 ed                	jne    8016fe <strncpy+0x14>
	}
	return ret;
}
  801711:	89 f0                	mov    %esi,%eax
  801713:	5b                   	pop    %ebx
  801714:	5e                   	pop    %esi
  801715:	5d                   	pop    %ebp
  801716:	c3                   	ret    

00801717 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	56                   	push   %esi
  80171b:	53                   	push   %ebx
  80171c:	8b 75 08             	mov    0x8(%ebp),%esi
  80171f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801722:	8b 55 10             	mov    0x10(%ebp),%edx
  801725:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801727:	85 d2                	test   %edx,%edx
  801729:	74 21                	je     80174c <strlcpy+0x35>
  80172b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80172f:	89 f2                	mov    %esi,%edx
  801731:	eb 09                	jmp    80173c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801733:	83 c1 01             	add    $0x1,%ecx
  801736:	83 c2 01             	add    $0x1,%edx
  801739:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  80173c:	39 c2                	cmp    %eax,%edx
  80173e:	74 09                	je     801749 <strlcpy+0x32>
  801740:	0f b6 19             	movzbl (%ecx),%ebx
  801743:	84 db                	test   %bl,%bl
  801745:	75 ec                	jne    801733 <strlcpy+0x1c>
  801747:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801749:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80174c:	29 f0                	sub    %esi,%eax
}
  80174e:	5b                   	pop    %ebx
  80174f:	5e                   	pop    %esi
  801750:	5d                   	pop    %ebp
  801751:	c3                   	ret    

00801752 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801752:	55                   	push   %ebp
  801753:	89 e5                	mov    %esp,%ebp
  801755:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801758:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80175b:	eb 06                	jmp    801763 <strcmp+0x11>
		p++, q++;
  80175d:	83 c1 01             	add    $0x1,%ecx
  801760:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801763:	0f b6 01             	movzbl (%ecx),%eax
  801766:	84 c0                	test   %al,%al
  801768:	74 04                	je     80176e <strcmp+0x1c>
  80176a:	3a 02                	cmp    (%edx),%al
  80176c:	74 ef                	je     80175d <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80176e:	0f b6 c0             	movzbl %al,%eax
  801771:	0f b6 12             	movzbl (%edx),%edx
  801774:	29 d0                	sub    %edx,%eax
}
  801776:	5d                   	pop    %ebp
  801777:	c3                   	ret    

00801778 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	53                   	push   %ebx
  80177c:	8b 45 08             	mov    0x8(%ebp),%eax
  80177f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801782:	89 c3                	mov    %eax,%ebx
  801784:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801787:	eb 06                	jmp    80178f <strncmp+0x17>
		n--, p++, q++;
  801789:	83 c0 01             	add    $0x1,%eax
  80178c:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80178f:	39 d8                	cmp    %ebx,%eax
  801791:	74 18                	je     8017ab <strncmp+0x33>
  801793:	0f b6 08             	movzbl (%eax),%ecx
  801796:	84 c9                	test   %cl,%cl
  801798:	74 04                	je     80179e <strncmp+0x26>
  80179a:	3a 0a                	cmp    (%edx),%cl
  80179c:	74 eb                	je     801789 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80179e:	0f b6 00             	movzbl (%eax),%eax
  8017a1:	0f b6 12             	movzbl (%edx),%edx
  8017a4:	29 d0                	sub    %edx,%eax
}
  8017a6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a9:	c9                   	leave  
  8017aa:	c3                   	ret    
		return 0;
  8017ab:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b0:	eb f4                	jmp    8017a6 <strncmp+0x2e>

008017b2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017b2:	55                   	push   %ebp
  8017b3:	89 e5                	mov    %esp,%ebp
  8017b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017bc:	eb 03                	jmp    8017c1 <strchr+0xf>
  8017be:	83 c0 01             	add    $0x1,%eax
  8017c1:	0f b6 10             	movzbl (%eax),%edx
  8017c4:	84 d2                	test   %dl,%dl
  8017c6:	74 06                	je     8017ce <strchr+0x1c>
		if (*s == c)
  8017c8:	38 ca                	cmp    %cl,%dl
  8017ca:	75 f2                	jne    8017be <strchr+0xc>
  8017cc:	eb 05                	jmp    8017d3 <strchr+0x21>
			return (char *) s;
	return 0;
  8017ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d3:	5d                   	pop    %ebp
  8017d4:	c3                   	ret    

008017d5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017d5:	55                   	push   %ebp
  8017d6:	89 e5                	mov    %esp,%ebp
  8017d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017db:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017df:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017e2:	38 ca                	cmp    %cl,%dl
  8017e4:	74 09                	je     8017ef <strfind+0x1a>
  8017e6:	84 d2                	test   %dl,%dl
  8017e8:	74 05                	je     8017ef <strfind+0x1a>
	for (; *s; s++)
  8017ea:	83 c0 01             	add    $0x1,%eax
  8017ed:	eb f0                	jmp    8017df <strfind+0xa>
			break;
	return (char *) s;
}
  8017ef:	5d                   	pop    %ebp
  8017f0:	c3                   	ret    

008017f1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	57                   	push   %edi
  8017f5:	56                   	push   %esi
  8017f6:	53                   	push   %ebx
  8017f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017fd:	85 c9                	test   %ecx,%ecx
  8017ff:	74 2f                	je     801830 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801801:	89 f8                	mov    %edi,%eax
  801803:	09 c8                	or     %ecx,%eax
  801805:	a8 03                	test   $0x3,%al
  801807:	75 21                	jne    80182a <memset+0x39>
		c &= 0xFF;
  801809:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80180d:	89 d0                	mov    %edx,%eax
  80180f:	c1 e0 08             	shl    $0x8,%eax
  801812:	89 d3                	mov    %edx,%ebx
  801814:	c1 e3 18             	shl    $0x18,%ebx
  801817:	89 d6                	mov    %edx,%esi
  801819:	c1 e6 10             	shl    $0x10,%esi
  80181c:	09 f3                	or     %esi,%ebx
  80181e:	09 da                	or     %ebx,%edx
  801820:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801822:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801825:	fc                   	cld    
  801826:	f3 ab                	rep stos %eax,%es:(%edi)
  801828:	eb 06                	jmp    801830 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80182a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182d:	fc                   	cld    
  80182e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801830:	89 f8                	mov    %edi,%eax
  801832:	5b                   	pop    %ebx
  801833:	5e                   	pop    %esi
  801834:	5f                   	pop    %edi
  801835:	5d                   	pop    %ebp
  801836:	c3                   	ret    

00801837 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801837:	55                   	push   %ebp
  801838:	89 e5                	mov    %esp,%ebp
  80183a:	57                   	push   %edi
  80183b:	56                   	push   %esi
  80183c:	8b 45 08             	mov    0x8(%ebp),%eax
  80183f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801842:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801845:	39 c6                	cmp    %eax,%esi
  801847:	73 32                	jae    80187b <memmove+0x44>
  801849:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80184c:	39 c2                	cmp    %eax,%edx
  80184e:	76 2b                	jbe    80187b <memmove+0x44>
		s += n;
		d += n;
  801850:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801853:	89 d6                	mov    %edx,%esi
  801855:	09 fe                	or     %edi,%esi
  801857:	09 ce                	or     %ecx,%esi
  801859:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80185f:	75 0e                	jne    80186f <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801861:	83 ef 04             	sub    $0x4,%edi
  801864:	8d 72 fc             	lea    -0x4(%edx),%esi
  801867:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80186a:	fd                   	std    
  80186b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80186d:	eb 09                	jmp    801878 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80186f:	83 ef 01             	sub    $0x1,%edi
  801872:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801875:	fd                   	std    
  801876:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801878:	fc                   	cld    
  801879:	eb 1a                	jmp    801895 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80187b:	89 f2                	mov    %esi,%edx
  80187d:	09 c2                	or     %eax,%edx
  80187f:	09 ca                	or     %ecx,%edx
  801881:	f6 c2 03             	test   $0x3,%dl
  801884:	75 0a                	jne    801890 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801886:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801889:	89 c7                	mov    %eax,%edi
  80188b:	fc                   	cld    
  80188c:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80188e:	eb 05                	jmp    801895 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801890:	89 c7                	mov    %eax,%edi
  801892:	fc                   	cld    
  801893:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801895:	5e                   	pop    %esi
  801896:	5f                   	pop    %edi
  801897:	5d                   	pop    %ebp
  801898:	c3                   	ret    

00801899 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80189f:	ff 75 10             	push   0x10(%ebp)
  8018a2:	ff 75 0c             	push   0xc(%ebp)
  8018a5:	ff 75 08             	push   0x8(%ebp)
  8018a8:	e8 8a ff ff ff       	call   801837 <memmove>
}
  8018ad:	c9                   	leave  
  8018ae:	c3                   	ret    

008018af <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	56                   	push   %esi
  8018b3:	53                   	push   %ebx
  8018b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8018b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ba:	89 c6                	mov    %eax,%esi
  8018bc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018bf:	eb 06                	jmp    8018c7 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8018c1:	83 c0 01             	add    $0x1,%eax
  8018c4:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8018c7:	39 f0                	cmp    %esi,%eax
  8018c9:	74 14                	je     8018df <memcmp+0x30>
		if (*s1 != *s2)
  8018cb:	0f b6 08             	movzbl (%eax),%ecx
  8018ce:	0f b6 1a             	movzbl (%edx),%ebx
  8018d1:	38 d9                	cmp    %bl,%cl
  8018d3:	74 ec                	je     8018c1 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8018d5:	0f b6 c1             	movzbl %cl,%eax
  8018d8:	0f b6 db             	movzbl %bl,%ebx
  8018db:	29 d8                	sub    %ebx,%eax
  8018dd:	eb 05                	jmp    8018e4 <memcmp+0x35>
	}

	return 0;
  8018df:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018e4:	5b                   	pop    %ebx
  8018e5:	5e                   	pop    %esi
  8018e6:	5d                   	pop    %ebp
  8018e7:	c3                   	ret    

008018e8 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018e8:	55                   	push   %ebp
  8018e9:	89 e5                	mov    %esp,%ebp
  8018eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8018f1:	89 c2                	mov    %eax,%edx
  8018f3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018f6:	eb 03                	jmp    8018fb <memfind+0x13>
  8018f8:	83 c0 01             	add    $0x1,%eax
  8018fb:	39 d0                	cmp    %edx,%eax
  8018fd:	73 04                	jae    801903 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018ff:	38 08                	cmp    %cl,(%eax)
  801901:	75 f5                	jne    8018f8 <memfind+0x10>
			break;
	return (void *) s;
}
  801903:	5d                   	pop    %ebp
  801904:	c3                   	ret    

00801905 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801905:	55                   	push   %ebp
  801906:	89 e5                	mov    %esp,%ebp
  801908:	57                   	push   %edi
  801909:	56                   	push   %esi
  80190a:	53                   	push   %ebx
  80190b:	8b 55 08             	mov    0x8(%ebp),%edx
  80190e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801911:	eb 03                	jmp    801916 <strtol+0x11>
		s++;
  801913:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801916:	0f b6 02             	movzbl (%edx),%eax
  801919:	3c 20                	cmp    $0x20,%al
  80191b:	74 f6                	je     801913 <strtol+0xe>
  80191d:	3c 09                	cmp    $0x9,%al
  80191f:	74 f2                	je     801913 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801921:	3c 2b                	cmp    $0x2b,%al
  801923:	74 2a                	je     80194f <strtol+0x4a>
	int neg = 0;
  801925:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80192a:	3c 2d                	cmp    $0x2d,%al
  80192c:	74 2b                	je     801959 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80192e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801934:	75 0f                	jne    801945 <strtol+0x40>
  801936:	80 3a 30             	cmpb   $0x30,(%edx)
  801939:	74 28                	je     801963 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80193b:	85 db                	test   %ebx,%ebx
  80193d:	b8 0a 00 00 00       	mov    $0xa,%eax
  801942:	0f 44 d8             	cmove  %eax,%ebx
  801945:	b9 00 00 00 00       	mov    $0x0,%ecx
  80194a:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80194d:	eb 46                	jmp    801995 <strtol+0x90>
		s++;
  80194f:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801952:	bf 00 00 00 00       	mov    $0x0,%edi
  801957:	eb d5                	jmp    80192e <strtol+0x29>
		s++, neg = 1;
  801959:	83 c2 01             	add    $0x1,%edx
  80195c:	bf 01 00 00 00       	mov    $0x1,%edi
  801961:	eb cb                	jmp    80192e <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801963:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801967:	74 0e                	je     801977 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801969:	85 db                	test   %ebx,%ebx
  80196b:	75 d8                	jne    801945 <strtol+0x40>
		s++, base = 8;
  80196d:	83 c2 01             	add    $0x1,%edx
  801970:	bb 08 00 00 00       	mov    $0x8,%ebx
  801975:	eb ce                	jmp    801945 <strtol+0x40>
		s += 2, base = 16;
  801977:	83 c2 02             	add    $0x2,%edx
  80197a:	bb 10 00 00 00       	mov    $0x10,%ebx
  80197f:	eb c4                	jmp    801945 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801981:	0f be c0             	movsbl %al,%eax
  801984:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801987:	3b 45 10             	cmp    0x10(%ebp),%eax
  80198a:	7d 3a                	jge    8019c6 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  80198c:	83 c2 01             	add    $0x1,%edx
  80198f:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801993:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801995:	0f b6 02             	movzbl (%edx),%eax
  801998:	8d 70 d0             	lea    -0x30(%eax),%esi
  80199b:	89 f3                	mov    %esi,%ebx
  80199d:	80 fb 09             	cmp    $0x9,%bl
  8019a0:	76 df                	jbe    801981 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  8019a2:	8d 70 9f             	lea    -0x61(%eax),%esi
  8019a5:	89 f3                	mov    %esi,%ebx
  8019a7:	80 fb 19             	cmp    $0x19,%bl
  8019aa:	77 08                	ja     8019b4 <strtol+0xaf>
			dig = *s - 'a' + 10;
  8019ac:	0f be c0             	movsbl %al,%eax
  8019af:	83 e8 57             	sub    $0x57,%eax
  8019b2:	eb d3                	jmp    801987 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8019b4:	8d 70 bf             	lea    -0x41(%eax),%esi
  8019b7:	89 f3                	mov    %esi,%ebx
  8019b9:	80 fb 19             	cmp    $0x19,%bl
  8019bc:	77 08                	ja     8019c6 <strtol+0xc1>
			dig = *s - 'A' + 10;
  8019be:	0f be c0             	movsbl %al,%eax
  8019c1:	83 e8 37             	sub    $0x37,%eax
  8019c4:	eb c1                	jmp    801987 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8019c6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019ca:	74 05                	je     8019d1 <strtol+0xcc>
		*endptr = (char *) s;
  8019cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019cf:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8019d1:	89 c8                	mov    %ecx,%eax
  8019d3:	f7 d8                	neg    %eax
  8019d5:	85 ff                	test   %edi,%edi
  8019d7:	0f 45 c8             	cmovne %eax,%ecx
}
  8019da:	89 c8                	mov    %ecx,%eax
  8019dc:	5b                   	pop    %ebx
  8019dd:	5e                   	pop    %esi
  8019de:	5f                   	pop    %edi
  8019df:	5d                   	pop    %ebp
  8019e0:	c3                   	ret    

008019e1 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019e1:	55                   	push   %ebp
  8019e2:	89 e5                	mov    %esp,%ebp
  8019e4:	56                   	push   %esi
  8019e5:	53                   	push   %ebx
  8019e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8019e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8019ef:	85 c0                	test   %eax,%eax
  8019f1:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019f6:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8019f9:	83 ec 0c             	sub    $0xc,%esp
  8019fc:	50                   	push   %eax
  8019fd:	e8 08 e9 ff ff       	call   80030a <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801a02:	83 c4 10             	add    $0x10,%esp
  801a05:	85 f6                	test   %esi,%esi
  801a07:	74 14                	je     801a1d <ipc_recv+0x3c>
  801a09:	ba 00 00 00 00       	mov    $0x0,%edx
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	78 09                	js     801a1b <ipc_recv+0x3a>
  801a12:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a18:	8b 52 74             	mov    0x74(%edx),%edx
  801a1b:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801a1d:	85 db                	test   %ebx,%ebx
  801a1f:	74 14                	je     801a35 <ipc_recv+0x54>
  801a21:	ba 00 00 00 00       	mov    $0x0,%edx
  801a26:	85 c0                	test   %eax,%eax
  801a28:	78 09                	js     801a33 <ipc_recv+0x52>
  801a2a:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a30:	8b 52 78             	mov    0x78(%edx),%edx
  801a33:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801a35:	85 c0                	test   %eax,%eax
  801a37:	78 08                	js     801a41 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801a39:	a1 00 40 80 00       	mov    0x804000,%eax
  801a3e:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a41:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a44:	5b                   	pop    %ebx
  801a45:	5e                   	pop    %esi
  801a46:	5d                   	pop    %ebp
  801a47:	c3                   	ret    

00801a48 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	57                   	push   %edi
  801a4c:	56                   	push   %esi
  801a4d:	53                   	push   %ebx
  801a4e:	83 ec 0c             	sub    $0xc,%esp
  801a51:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a54:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801a5a:	85 db                	test   %ebx,%ebx
  801a5c:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a61:	0f 44 d8             	cmove  %eax,%ebx
  801a64:	eb 05                	jmp    801a6b <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a66:	e8 d0 e6 ff ff       	call   80013b <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801a6b:	ff 75 14             	push   0x14(%ebp)
  801a6e:	53                   	push   %ebx
  801a6f:	56                   	push   %esi
  801a70:	57                   	push   %edi
  801a71:	e8 71 e8 ff ff       	call   8002e7 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a76:	83 c4 10             	add    $0x10,%esp
  801a79:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a7c:	74 e8                	je     801a66 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801a7e:	85 c0                	test   %eax,%eax
  801a80:	78 08                	js     801a8a <ipc_send+0x42>
	}while (r<0);

}
  801a82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a85:	5b                   	pop    %ebx
  801a86:	5e                   	pop    %esi
  801a87:	5f                   	pop    %edi
  801a88:	5d                   	pop    %ebp
  801a89:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801a8a:	50                   	push   %eax
  801a8b:	68 9f 21 80 00       	push   $0x80219f
  801a90:	6a 3d                	push   $0x3d
  801a92:	68 b3 21 80 00       	push   $0x8021b3
  801a97:	e8 50 f5 ff ff       	call   800fec <_panic>

00801a9c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a9c:	55                   	push   %ebp
  801a9d:	89 e5                	mov    %esp,%ebp
  801a9f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801aa2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801aa7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801aaa:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ab0:	8b 52 50             	mov    0x50(%edx),%edx
  801ab3:	39 ca                	cmp    %ecx,%edx
  801ab5:	74 11                	je     801ac8 <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801ab7:	83 c0 01             	add    $0x1,%eax
  801aba:	3d 00 04 00 00       	cmp    $0x400,%eax
  801abf:	75 e6                	jne    801aa7 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801ac1:	b8 00 00 00 00       	mov    $0x0,%eax
  801ac6:	eb 0b                	jmp    801ad3 <ipc_find_env+0x37>
			return envs[i].env_id;
  801ac8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801acb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ad0:	8b 40 48             	mov    0x48(%eax),%eax
}
  801ad3:	5d                   	pop    %ebp
  801ad4:	c3                   	ret    

00801ad5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801adb:	89 c2                	mov    %eax,%edx
  801add:	c1 ea 16             	shr    $0x16,%edx
  801ae0:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801ae7:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801aec:	f6 c1 01             	test   $0x1,%cl
  801aef:	74 1c                	je     801b0d <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801af1:	c1 e8 0c             	shr    $0xc,%eax
  801af4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801afb:	a8 01                	test   $0x1,%al
  801afd:	74 0e                	je     801b0d <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801aff:	c1 e8 0c             	shr    $0xc,%eax
  801b02:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b09:	ef 
  801b0a:	0f b7 d2             	movzwl %dx,%edx
}
  801b0d:	89 d0                	mov    %edx,%eax
  801b0f:	5d                   	pop    %ebp
  801b10:	c3                   	ret    
  801b11:	66 90                	xchg   %ax,%ax
  801b13:	66 90                	xchg   %ax,%ax
  801b15:	66 90                	xchg   %ax,%ax
  801b17:	66 90                	xchg   %ax,%ax
  801b19:	66 90                	xchg   %ax,%ax
  801b1b:	66 90                	xchg   %ax,%ax
  801b1d:	66 90                	xchg   %ax,%ax
  801b1f:	90                   	nop

00801b20 <__udivdi3>:
  801b20:	f3 0f 1e fb          	endbr32 
  801b24:	55                   	push   %ebp
  801b25:	57                   	push   %edi
  801b26:	56                   	push   %esi
  801b27:	53                   	push   %ebx
  801b28:	83 ec 1c             	sub    $0x1c,%esp
  801b2b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801b2f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b33:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b37:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b3b:	85 c0                	test   %eax,%eax
  801b3d:	75 19                	jne    801b58 <__udivdi3+0x38>
  801b3f:	39 f3                	cmp    %esi,%ebx
  801b41:	76 4d                	jbe    801b90 <__udivdi3+0x70>
  801b43:	31 ff                	xor    %edi,%edi
  801b45:	89 e8                	mov    %ebp,%eax
  801b47:	89 f2                	mov    %esi,%edx
  801b49:	f7 f3                	div    %ebx
  801b4b:	89 fa                	mov    %edi,%edx
  801b4d:	83 c4 1c             	add    $0x1c,%esp
  801b50:	5b                   	pop    %ebx
  801b51:	5e                   	pop    %esi
  801b52:	5f                   	pop    %edi
  801b53:	5d                   	pop    %ebp
  801b54:	c3                   	ret    
  801b55:	8d 76 00             	lea    0x0(%esi),%esi
  801b58:	39 f0                	cmp    %esi,%eax
  801b5a:	76 14                	jbe    801b70 <__udivdi3+0x50>
  801b5c:	31 ff                	xor    %edi,%edi
  801b5e:	31 c0                	xor    %eax,%eax
  801b60:	89 fa                	mov    %edi,%edx
  801b62:	83 c4 1c             	add    $0x1c,%esp
  801b65:	5b                   	pop    %ebx
  801b66:	5e                   	pop    %esi
  801b67:	5f                   	pop    %edi
  801b68:	5d                   	pop    %ebp
  801b69:	c3                   	ret    
  801b6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801b70:	0f bd f8             	bsr    %eax,%edi
  801b73:	83 f7 1f             	xor    $0x1f,%edi
  801b76:	75 48                	jne    801bc0 <__udivdi3+0xa0>
  801b78:	39 f0                	cmp    %esi,%eax
  801b7a:	72 06                	jb     801b82 <__udivdi3+0x62>
  801b7c:	31 c0                	xor    %eax,%eax
  801b7e:	39 eb                	cmp    %ebp,%ebx
  801b80:	77 de                	ja     801b60 <__udivdi3+0x40>
  801b82:	b8 01 00 00 00       	mov    $0x1,%eax
  801b87:	eb d7                	jmp    801b60 <__udivdi3+0x40>
  801b89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801b90:	89 d9                	mov    %ebx,%ecx
  801b92:	85 db                	test   %ebx,%ebx
  801b94:	75 0b                	jne    801ba1 <__udivdi3+0x81>
  801b96:	b8 01 00 00 00       	mov    $0x1,%eax
  801b9b:	31 d2                	xor    %edx,%edx
  801b9d:	f7 f3                	div    %ebx
  801b9f:	89 c1                	mov    %eax,%ecx
  801ba1:	31 d2                	xor    %edx,%edx
  801ba3:	89 f0                	mov    %esi,%eax
  801ba5:	f7 f1                	div    %ecx
  801ba7:	89 c6                	mov    %eax,%esi
  801ba9:	89 e8                	mov    %ebp,%eax
  801bab:	89 f7                	mov    %esi,%edi
  801bad:	f7 f1                	div    %ecx
  801baf:	89 fa                	mov    %edi,%edx
  801bb1:	83 c4 1c             	add    $0x1c,%esp
  801bb4:	5b                   	pop    %ebx
  801bb5:	5e                   	pop    %esi
  801bb6:	5f                   	pop    %edi
  801bb7:	5d                   	pop    %ebp
  801bb8:	c3                   	ret    
  801bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bc0:	89 f9                	mov    %edi,%ecx
  801bc2:	ba 20 00 00 00       	mov    $0x20,%edx
  801bc7:	29 fa                	sub    %edi,%edx
  801bc9:	d3 e0                	shl    %cl,%eax
  801bcb:	89 44 24 08          	mov    %eax,0x8(%esp)
  801bcf:	89 d1                	mov    %edx,%ecx
  801bd1:	89 d8                	mov    %ebx,%eax
  801bd3:	d3 e8                	shr    %cl,%eax
  801bd5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801bd9:	09 c1                	or     %eax,%ecx
  801bdb:	89 f0                	mov    %esi,%eax
  801bdd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801be1:	89 f9                	mov    %edi,%ecx
  801be3:	d3 e3                	shl    %cl,%ebx
  801be5:	89 d1                	mov    %edx,%ecx
  801be7:	d3 e8                	shr    %cl,%eax
  801be9:	89 f9                	mov    %edi,%ecx
  801beb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801bef:	89 eb                	mov    %ebp,%ebx
  801bf1:	d3 e6                	shl    %cl,%esi
  801bf3:	89 d1                	mov    %edx,%ecx
  801bf5:	d3 eb                	shr    %cl,%ebx
  801bf7:	09 f3                	or     %esi,%ebx
  801bf9:	89 c6                	mov    %eax,%esi
  801bfb:	89 f2                	mov    %esi,%edx
  801bfd:	89 d8                	mov    %ebx,%eax
  801bff:	f7 74 24 08          	divl   0x8(%esp)
  801c03:	89 d6                	mov    %edx,%esi
  801c05:	89 c3                	mov    %eax,%ebx
  801c07:	f7 64 24 0c          	mull   0xc(%esp)
  801c0b:	39 d6                	cmp    %edx,%esi
  801c0d:	72 19                	jb     801c28 <__udivdi3+0x108>
  801c0f:	89 f9                	mov    %edi,%ecx
  801c11:	d3 e5                	shl    %cl,%ebp
  801c13:	39 c5                	cmp    %eax,%ebp
  801c15:	73 04                	jae    801c1b <__udivdi3+0xfb>
  801c17:	39 d6                	cmp    %edx,%esi
  801c19:	74 0d                	je     801c28 <__udivdi3+0x108>
  801c1b:	89 d8                	mov    %ebx,%eax
  801c1d:	31 ff                	xor    %edi,%edi
  801c1f:	e9 3c ff ff ff       	jmp    801b60 <__udivdi3+0x40>
  801c24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c28:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c2b:	31 ff                	xor    %edi,%edi
  801c2d:	e9 2e ff ff ff       	jmp    801b60 <__udivdi3+0x40>
  801c32:	66 90                	xchg   %ax,%ax
  801c34:	66 90                	xchg   %ax,%ax
  801c36:	66 90                	xchg   %ax,%ax
  801c38:	66 90                	xchg   %ax,%ax
  801c3a:	66 90                	xchg   %ax,%ax
  801c3c:	66 90                	xchg   %ax,%ax
  801c3e:	66 90                	xchg   %ax,%ax

00801c40 <__umoddi3>:
  801c40:	f3 0f 1e fb          	endbr32 
  801c44:	55                   	push   %ebp
  801c45:	57                   	push   %edi
  801c46:	56                   	push   %esi
  801c47:	53                   	push   %ebx
  801c48:	83 ec 1c             	sub    $0x1c,%esp
  801c4b:	8b 74 24 30          	mov    0x30(%esp),%esi
  801c4f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801c53:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  801c57:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  801c5b:	89 f0                	mov    %esi,%eax
  801c5d:	89 da                	mov    %ebx,%edx
  801c5f:	85 ff                	test   %edi,%edi
  801c61:	75 15                	jne    801c78 <__umoddi3+0x38>
  801c63:	39 dd                	cmp    %ebx,%ebp
  801c65:	76 39                	jbe    801ca0 <__umoddi3+0x60>
  801c67:	f7 f5                	div    %ebp
  801c69:	89 d0                	mov    %edx,%eax
  801c6b:	31 d2                	xor    %edx,%edx
  801c6d:	83 c4 1c             	add    $0x1c,%esp
  801c70:	5b                   	pop    %ebx
  801c71:	5e                   	pop    %esi
  801c72:	5f                   	pop    %edi
  801c73:	5d                   	pop    %ebp
  801c74:	c3                   	ret    
  801c75:	8d 76 00             	lea    0x0(%esi),%esi
  801c78:	39 df                	cmp    %ebx,%edi
  801c7a:	77 f1                	ja     801c6d <__umoddi3+0x2d>
  801c7c:	0f bd cf             	bsr    %edi,%ecx
  801c7f:	83 f1 1f             	xor    $0x1f,%ecx
  801c82:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  801c86:	75 40                	jne    801cc8 <__umoddi3+0x88>
  801c88:	39 df                	cmp    %ebx,%edi
  801c8a:	72 04                	jb     801c90 <__umoddi3+0x50>
  801c8c:	39 f5                	cmp    %esi,%ebp
  801c8e:	77 dd                	ja     801c6d <__umoddi3+0x2d>
  801c90:	89 da                	mov    %ebx,%edx
  801c92:	89 f0                	mov    %esi,%eax
  801c94:	29 e8                	sub    %ebp,%eax
  801c96:	19 fa                	sbb    %edi,%edx
  801c98:	eb d3                	jmp    801c6d <__umoddi3+0x2d>
  801c9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ca0:	89 e9                	mov    %ebp,%ecx
  801ca2:	85 ed                	test   %ebp,%ebp
  801ca4:	75 0b                	jne    801cb1 <__umoddi3+0x71>
  801ca6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cab:	31 d2                	xor    %edx,%edx
  801cad:	f7 f5                	div    %ebp
  801caf:	89 c1                	mov    %eax,%ecx
  801cb1:	89 d8                	mov    %ebx,%eax
  801cb3:	31 d2                	xor    %edx,%edx
  801cb5:	f7 f1                	div    %ecx
  801cb7:	89 f0                	mov    %esi,%eax
  801cb9:	f7 f1                	div    %ecx
  801cbb:	89 d0                	mov    %edx,%eax
  801cbd:	31 d2                	xor    %edx,%edx
  801cbf:	eb ac                	jmp    801c6d <__umoddi3+0x2d>
  801cc1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cc8:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ccc:	ba 20 00 00 00       	mov    $0x20,%edx
  801cd1:	29 c2                	sub    %eax,%edx
  801cd3:	89 c1                	mov    %eax,%ecx
  801cd5:	89 e8                	mov    %ebp,%eax
  801cd7:	d3 e7                	shl    %cl,%edi
  801cd9:	89 d1                	mov    %edx,%ecx
  801cdb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801cdf:	d3 e8                	shr    %cl,%eax
  801ce1:	89 c1                	mov    %eax,%ecx
  801ce3:	8b 44 24 04          	mov    0x4(%esp),%eax
  801ce7:	09 f9                	or     %edi,%ecx
  801ce9:	89 df                	mov    %ebx,%edi
  801ceb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cef:	89 c1                	mov    %eax,%ecx
  801cf1:	d3 e5                	shl    %cl,%ebp
  801cf3:	89 d1                	mov    %edx,%ecx
  801cf5:	d3 ef                	shr    %cl,%edi
  801cf7:	89 c1                	mov    %eax,%ecx
  801cf9:	89 f0                	mov    %esi,%eax
  801cfb:	d3 e3                	shl    %cl,%ebx
  801cfd:	89 d1                	mov    %edx,%ecx
  801cff:	89 fa                	mov    %edi,%edx
  801d01:	d3 e8                	shr    %cl,%eax
  801d03:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d08:	09 d8                	or     %ebx,%eax
  801d0a:	f7 74 24 08          	divl   0x8(%esp)
  801d0e:	89 d3                	mov    %edx,%ebx
  801d10:	d3 e6                	shl    %cl,%esi
  801d12:	f7 e5                	mul    %ebp
  801d14:	89 c7                	mov    %eax,%edi
  801d16:	89 d1                	mov    %edx,%ecx
  801d18:	39 d3                	cmp    %edx,%ebx
  801d1a:	72 06                	jb     801d22 <__umoddi3+0xe2>
  801d1c:	75 0e                	jne    801d2c <__umoddi3+0xec>
  801d1e:	39 c6                	cmp    %eax,%esi
  801d20:	73 0a                	jae    801d2c <__umoddi3+0xec>
  801d22:	29 e8                	sub    %ebp,%eax
  801d24:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801d28:	89 d1                	mov    %edx,%ecx
  801d2a:	89 c7                	mov    %eax,%edi
  801d2c:	89 f5                	mov    %esi,%ebp
  801d2e:	8b 74 24 04          	mov    0x4(%esp),%esi
  801d32:	29 fd                	sub    %edi,%ebp
  801d34:	19 cb                	sbb    %ecx,%ebx
  801d36:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  801d3b:	89 d8                	mov    %ebx,%eax
  801d3d:	d3 e0                	shl    %cl,%eax
  801d3f:	89 f1                	mov    %esi,%ecx
  801d41:	d3 ed                	shr    %cl,%ebp
  801d43:	d3 eb                	shr    %cl,%ebx
  801d45:	09 e8                	or     %ebp,%eax
  801d47:	89 da                	mov    %ebx,%edx
  801d49:	83 c4 1c             	add    $0x1c,%esp
  801d4c:	5b                   	pop    %ebx
  801d4d:	5e                   	pop    %esi
  801d4e:	5f                   	pop    %edi
  801d4f:	5d                   	pop    %ebp
  801d50:	c3                   	ret    
