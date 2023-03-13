
obj/user/breakpoint.debug：     文件格式 elf32-i386


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
  80002c:	e8 04 00 00 00       	call   800035 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
	asm volatile("int $3");
  800033:	cc                   	int3   
}
  800034:	c3                   	ret    

00800035 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800035:	55                   	push   %ebp
  800036:	89 e5                	mov    %esp,%ebp
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80003d:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800040:	e8 ce 00 00 00       	call   800113 <sys_getenvid>
  800045:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80004d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800052:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800057:	85 db                	test   %ebx,%ebx
  800059:	7e 07                	jle    800062 <libmain+0x2d>
		binaryname = argv[0];
  80005b:	8b 06                	mov    (%esi),%eax
  80005d:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800062:	83 ec 08             	sub    $0x8,%esp
  800065:	56                   	push   %esi
  800066:	53                   	push   %ebx
  800067:	e8 c7 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80006c:	e8 0a 00 00 00       	call   80007b <exit>
}
  800071:	83 c4 10             	add    $0x10,%esp
  800074:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800077:	5b                   	pop    %ebx
  800078:	5e                   	pop    %esi
  800079:	5d                   	pop    %ebp
  80007a:	c3                   	ret    

0080007b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800081:	e8 88 04 00 00       	call   80050e <close_all>
	sys_env_destroy(0);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	6a 00                	push   $0x0
  80008b:	e8 42 00 00 00       	call   8000d2 <sys_env_destroy>
}
  800090:	83 c4 10             	add    $0x10,%esp
  800093:	c9                   	leave  
  800094:	c3                   	ret    

00800095 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800095:	55                   	push   %ebp
  800096:	89 e5                	mov    %esp,%ebp
  800098:	57                   	push   %edi
  800099:	56                   	push   %esi
  80009a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80009b:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a6:	89 c3                	mov    %eax,%ebx
  8000a8:	89 c7                	mov    %eax,%edi
  8000aa:	89 c6                	mov    %eax,%esi
  8000ac:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ae:	5b                   	pop    %ebx
  8000af:	5e                   	pop    %esi
  8000b0:	5f                   	pop    %edi
  8000b1:	5d                   	pop    %ebp
  8000b2:	c3                   	ret    

008000b3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	57                   	push   %edi
  8000b7:	56                   	push   %esi
  8000b8:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000be:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c3:	89 d1                	mov    %edx,%ecx
  8000c5:	89 d3                	mov    %edx,%ebx
  8000c7:	89 d7                	mov    %edx,%edi
  8000c9:	89 d6                	mov    %edx,%esi
  8000cb:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000cd:	5b                   	pop    %ebx
  8000ce:	5e                   	pop    %esi
  8000cf:	5f                   	pop    %edi
  8000d0:	5d                   	pop    %ebp
  8000d1:	c3                   	ret    

008000d2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d2:	55                   	push   %ebp
  8000d3:	89 e5                	mov    %esp,%ebp
  8000d5:	57                   	push   %edi
  8000d6:	56                   	push   %esi
  8000d7:	53                   	push   %ebx
  8000d8:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000db:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e3:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e8:	89 cb                	mov    %ecx,%ebx
  8000ea:	89 cf                	mov    %ecx,%edi
  8000ec:	89 ce                	mov    %ecx,%esi
  8000ee:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f0:	85 c0                	test   %eax,%eax
  8000f2:	7f 08                	jg     8000fc <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5f                   	pop    %edi
  8000fa:	5d                   	pop    %ebp
  8000fb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fc:	83 ec 0c             	sub    $0xc,%esp
  8000ff:	50                   	push   %eax
  800100:	6a 03                	push   $0x3
  800102:	68 6a 1d 80 00       	push   $0x801d6a
  800107:	6a 2a                	push   $0x2a
  800109:	68 87 1d 80 00       	push   $0x801d87
  80010e:	e8 d0 0e 00 00       	call   800fe3 <_panic>

00800113 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	57                   	push   %edi
  800117:	56                   	push   %esi
  800118:	53                   	push   %ebx
	asm volatile("int %1\n"
  800119:	ba 00 00 00 00       	mov    $0x0,%edx
  80011e:	b8 02 00 00 00       	mov    $0x2,%eax
  800123:	89 d1                	mov    %edx,%ecx
  800125:	89 d3                	mov    %edx,%ebx
  800127:	89 d7                	mov    %edx,%edi
  800129:	89 d6                	mov    %edx,%esi
  80012b:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012d:	5b                   	pop    %ebx
  80012e:	5e                   	pop    %esi
  80012f:	5f                   	pop    %edi
  800130:	5d                   	pop    %ebp
  800131:	c3                   	ret    

00800132 <sys_yield>:

void
sys_yield(void)
{
  800132:	55                   	push   %ebp
  800133:	89 e5                	mov    %esp,%ebp
  800135:	57                   	push   %edi
  800136:	56                   	push   %esi
  800137:	53                   	push   %ebx
	asm volatile("int %1\n"
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800142:	89 d1                	mov    %edx,%ecx
  800144:	89 d3                	mov    %edx,%ebx
  800146:	89 d7                	mov    %edx,%edi
  800148:	89 d6                	mov    %edx,%esi
  80014a:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80014c:	5b                   	pop    %ebx
  80014d:	5e                   	pop    %esi
  80014e:	5f                   	pop    %edi
  80014f:	5d                   	pop    %ebp
  800150:	c3                   	ret    

00800151 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	57                   	push   %edi
  800155:	56                   	push   %esi
  800156:	53                   	push   %ebx
  800157:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80015a:	be 00 00 00 00       	mov    $0x0,%esi
  80015f:	8b 55 08             	mov    0x8(%ebp),%edx
  800162:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800165:	b8 04 00 00 00       	mov    $0x4,%eax
  80016a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80016d:	89 f7                	mov    %esi,%edi
  80016f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800171:	85 c0                	test   %eax,%eax
  800173:	7f 08                	jg     80017d <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800175:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800178:	5b                   	pop    %ebx
  800179:	5e                   	pop    %esi
  80017a:	5f                   	pop    %edi
  80017b:	5d                   	pop    %ebp
  80017c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80017d:	83 ec 0c             	sub    $0xc,%esp
  800180:	50                   	push   %eax
  800181:	6a 04                	push   $0x4
  800183:	68 6a 1d 80 00       	push   $0x801d6a
  800188:	6a 2a                	push   $0x2a
  80018a:	68 87 1d 80 00       	push   $0x801d87
  80018f:	e8 4f 0e 00 00       	call   800fe3 <_panic>

00800194 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	57                   	push   %edi
  800198:	56                   	push   %esi
  800199:	53                   	push   %ebx
  80019a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80019d:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a3:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ab:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001ae:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b3:	85 c0                	test   %eax,%eax
  8001b5:	7f 08                	jg     8001bf <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001b7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5e                   	pop    %esi
  8001bc:	5f                   	pop    %edi
  8001bd:	5d                   	pop    %ebp
  8001be:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001bf:	83 ec 0c             	sub    $0xc,%esp
  8001c2:	50                   	push   %eax
  8001c3:	6a 05                	push   $0x5
  8001c5:	68 6a 1d 80 00       	push   $0x801d6a
  8001ca:	6a 2a                	push   $0x2a
  8001cc:	68 87 1d 80 00       	push   $0x801d87
  8001d1:	e8 0d 0e 00 00       	call   800fe3 <_panic>

008001d6 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	57                   	push   %edi
  8001da:	56                   	push   %esi
  8001db:	53                   	push   %ebx
  8001dc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001df:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ea:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ef:	89 df                	mov    %ebx,%edi
  8001f1:	89 de                	mov    %ebx,%esi
  8001f3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001f5:	85 c0                	test   %eax,%eax
  8001f7:	7f 08                	jg     800201 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001fc:	5b                   	pop    %ebx
  8001fd:	5e                   	pop    %esi
  8001fe:	5f                   	pop    %edi
  8001ff:	5d                   	pop    %ebp
  800200:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800201:	83 ec 0c             	sub    $0xc,%esp
  800204:	50                   	push   %eax
  800205:	6a 06                	push   $0x6
  800207:	68 6a 1d 80 00       	push   $0x801d6a
  80020c:	6a 2a                	push   $0x2a
  80020e:	68 87 1d 80 00       	push   $0x801d87
  800213:	e8 cb 0d 00 00       	call   800fe3 <_panic>

00800218 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	57                   	push   %edi
  80021c:	56                   	push   %esi
  80021d:	53                   	push   %ebx
  80021e:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800221:	bb 00 00 00 00       	mov    $0x0,%ebx
  800226:	8b 55 08             	mov    0x8(%ebp),%edx
  800229:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022c:	b8 08 00 00 00       	mov    $0x8,%eax
  800231:	89 df                	mov    %ebx,%edi
  800233:	89 de                	mov    %ebx,%esi
  800235:	cd 30                	int    $0x30
	if(check && ret > 0)
  800237:	85 c0                	test   %eax,%eax
  800239:	7f 08                	jg     800243 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80023b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80023e:	5b                   	pop    %ebx
  80023f:	5e                   	pop    %esi
  800240:	5f                   	pop    %edi
  800241:	5d                   	pop    %ebp
  800242:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800243:	83 ec 0c             	sub    $0xc,%esp
  800246:	50                   	push   %eax
  800247:	6a 08                	push   $0x8
  800249:	68 6a 1d 80 00       	push   $0x801d6a
  80024e:	6a 2a                	push   $0x2a
  800250:	68 87 1d 80 00       	push   $0x801d87
  800255:	e8 89 0d 00 00       	call   800fe3 <_panic>

0080025a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025a:	55                   	push   %ebp
  80025b:	89 e5                	mov    %esp,%ebp
  80025d:	57                   	push   %edi
  80025e:	56                   	push   %esi
  80025f:	53                   	push   %ebx
  800260:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800263:	bb 00 00 00 00       	mov    $0x0,%ebx
  800268:	8b 55 08             	mov    0x8(%ebp),%edx
  80026b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80026e:	b8 09 00 00 00       	mov    $0x9,%eax
  800273:	89 df                	mov    %ebx,%edi
  800275:	89 de                	mov    %ebx,%esi
  800277:	cd 30                	int    $0x30
	if(check && ret > 0)
  800279:	85 c0                	test   %eax,%eax
  80027b:	7f 08                	jg     800285 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80027d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800280:	5b                   	pop    %ebx
  800281:	5e                   	pop    %esi
  800282:	5f                   	pop    %edi
  800283:	5d                   	pop    %ebp
  800284:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800285:	83 ec 0c             	sub    $0xc,%esp
  800288:	50                   	push   %eax
  800289:	6a 09                	push   $0x9
  80028b:	68 6a 1d 80 00       	push   $0x801d6a
  800290:	6a 2a                	push   $0x2a
  800292:	68 87 1d 80 00       	push   $0x801d87
  800297:	e8 47 0d 00 00       	call   800fe3 <_panic>

0080029c <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80029c:	55                   	push   %ebp
  80029d:	89 e5                	mov    %esp,%ebp
  80029f:	57                   	push   %edi
  8002a0:	56                   	push   %esi
  8002a1:	53                   	push   %ebx
  8002a2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b5:	89 df                	mov    %ebx,%edi
  8002b7:	89 de                	mov    %ebx,%esi
  8002b9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002bb:	85 c0                	test   %eax,%eax
  8002bd:	7f 08                	jg     8002c7 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c2:	5b                   	pop    %ebx
  8002c3:	5e                   	pop    %esi
  8002c4:	5f                   	pop    %edi
  8002c5:	5d                   	pop    %ebp
  8002c6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c7:	83 ec 0c             	sub    $0xc,%esp
  8002ca:	50                   	push   %eax
  8002cb:	6a 0a                	push   $0xa
  8002cd:	68 6a 1d 80 00       	push   $0x801d6a
  8002d2:	6a 2a                	push   $0x2a
  8002d4:	68 87 1d 80 00       	push   $0x801d87
  8002d9:	e8 05 0d 00 00       	call   800fe3 <_panic>

008002de <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	57                   	push   %edi
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002e4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ea:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ef:	be 00 00 00 00       	mov    $0x0,%esi
  8002f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002f7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fa:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	57                   	push   %edi
  800305:	56                   	push   %esi
  800306:	53                   	push   %ebx
  800307:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80030a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80030f:	8b 55 08             	mov    0x8(%ebp),%edx
  800312:	b8 0d 00 00 00       	mov    $0xd,%eax
  800317:	89 cb                	mov    %ecx,%ebx
  800319:	89 cf                	mov    %ecx,%edi
  80031b:	89 ce                	mov    %ecx,%esi
  80031d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80031f:	85 c0                	test   %eax,%eax
  800321:	7f 08                	jg     80032b <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800323:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800326:	5b                   	pop    %ebx
  800327:	5e                   	pop    %esi
  800328:	5f                   	pop    %edi
  800329:	5d                   	pop    %ebp
  80032a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80032b:	83 ec 0c             	sub    $0xc,%esp
  80032e:	50                   	push   %eax
  80032f:	6a 0d                	push   $0xd
  800331:	68 6a 1d 80 00       	push   $0x801d6a
  800336:	6a 2a                	push   $0x2a
  800338:	68 87 1d 80 00       	push   $0x801d87
  80033d:	e8 a1 0c 00 00       	call   800fe3 <_panic>

00800342 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800345:	8b 45 08             	mov    0x8(%ebp),%eax
  800348:	05 00 00 00 30       	add    $0x30000000,%eax
  80034d:	c1 e8 0c             	shr    $0xc,%eax
}
  800350:	5d                   	pop    %ebp
  800351:	c3                   	ret    

00800352 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800352:	55                   	push   %ebp
  800353:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800355:	8b 45 08             	mov    0x8(%ebp),%eax
  800358:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  80035d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800362:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    

00800369 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800371:	89 c2                	mov    %eax,%edx
  800373:	c1 ea 16             	shr    $0x16,%edx
  800376:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80037d:	f6 c2 01             	test   $0x1,%dl
  800380:	74 29                	je     8003ab <fd_alloc+0x42>
  800382:	89 c2                	mov    %eax,%edx
  800384:	c1 ea 0c             	shr    $0xc,%edx
  800387:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80038e:	f6 c2 01             	test   $0x1,%dl
  800391:	74 18                	je     8003ab <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  800393:	05 00 10 00 00       	add    $0x1000,%eax
  800398:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80039d:	75 d2                	jne    800371 <fd_alloc+0x8>
  80039f:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  8003a4:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  8003a9:	eb 05                	jmp    8003b0 <fd_alloc+0x47>
			return 0;
  8003ab:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  8003b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b3:	89 02                	mov    %eax,(%edx)
}
  8003b5:	89 c8                	mov    %ecx,%eax
  8003b7:	5d                   	pop    %ebp
  8003b8:	c3                   	ret    

008003b9 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003b9:	55                   	push   %ebp
  8003ba:	89 e5                	mov    %esp,%ebp
  8003bc:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003bf:	83 f8 1f             	cmp    $0x1f,%eax
  8003c2:	77 30                	ja     8003f4 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003c4:	c1 e0 0c             	shl    $0xc,%eax
  8003c7:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003cc:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003d2:	f6 c2 01             	test   $0x1,%dl
  8003d5:	74 24                	je     8003fb <fd_lookup+0x42>
  8003d7:	89 c2                	mov    %eax,%edx
  8003d9:	c1 ea 0c             	shr    $0xc,%edx
  8003dc:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e3:	f6 c2 01             	test   $0x1,%dl
  8003e6:	74 1a                	je     800402 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003eb:	89 02                	mov    %eax,(%edx)
	return 0;
  8003ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003f2:	5d                   	pop    %ebp
  8003f3:	c3                   	ret    
		return -E_INVAL;
  8003f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003f9:	eb f7                	jmp    8003f2 <fd_lookup+0x39>
		return -E_INVAL;
  8003fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800400:	eb f0                	jmp    8003f2 <fd_lookup+0x39>
  800402:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800407:	eb e9                	jmp    8003f2 <fd_lookup+0x39>

00800409 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	53                   	push   %ebx
  80040d:	83 ec 04             	sub    $0x4,%esp
  800410:	8b 55 08             	mov    0x8(%ebp),%edx
  800413:	b8 14 1e 80 00       	mov    $0x801e14,%eax
	int i;
	for (i = 0; devtab[i]; i++)
  800418:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80041d:	39 13                	cmp    %edx,(%ebx)
  80041f:	74 32                	je     800453 <dev_lookup+0x4a>
	for (i = 0; devtab[i]; i++)
  800421:	83 c0 04             	add    $0x4,%eax
  800424:	8b 18                	mov    (%eax),%ebx
  800426:	85 db                	test   %ebx,%ebx
  800428:	75 f3                	jne    80041d <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80042a:	a1 00 40 80 00       	mov    0x804000,%eax
  80042f:	8b 40 48             	mov    0x48(%eax),%eax
  800432:	83 ec 04             	sub    $0x4,%esp
  800435:	52                   	push   %edx
  800436:	50                   	push   %eax
  800437:	68 98 1d 80 00       	push   $0x801d98
  80043c:	e8 7d 0c 00 00       	call   8010be <cprintf>
	*dev = 0;
	return -E_INVAL;
  800441:	83 c4 10             	add    $0x10,%esp
  800444:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  800449:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044c:	89 1a                	mov    %ebx,(%edx)
}
  80044e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800451:	c9                   	leave  
  800452:	c3                   	ret    
			return 0;
  800453:	b8 00 00 00 00       	mov    $0x0,%eax
  800458:	eb ef                	jmp    800449 <dev_lookup+0x40>

0080045a <fd_close>:
{
  80045a:	55                   	push   %ebp
  80045b:	89 e5                	mov    %esp,%ebp
  80045d:	57                   	push   %edi
  80045e:	56                   	push   %esi
  80045f:	53                   	push   %ebx
  800460:	83 ec 24             	sub    $0x24,%esp
  800463:	8b 75 08             	mov    0x8(%ebp),%esi
  800466:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800469:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80046c:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80046d:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800473:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800476:	50                   	push   %eax
  800477:	e8 3d ff ff ff       	call   8003b9 <fd_lookup>
  80047c:	89 c3                	mov    %eax,%ebx
  80047e:	83 c4 10             	add    $0x10,%esp
  800481:	85 c0                	test   %eax,%eax
  800483:	78 05                	js     80048a <fd_close+0x30>
	    || fd != fd2)
  800485:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800488:	74 16                	je     8004a0 <fd_close+0x46>
		return (must_exist ? r : 0);
  80048a:	89 f8                	mov    %edi,%eax
  80048c:	84 c0                	test   %al,%al
  80048e:	b8 00 00 00 00       	mov    $0x0,%eax
  800493:	0f 44 d8             	cmove  %eax,%ebx
}
  800496:	89 d8                	mov    %ebx,%eax
  800498:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80049b:	5b                   	pop    %ebx
  80049c:	5e                   	pop    %esi
  80049d:	5f                   	pop    %edi
  80049e:	5d                   	pop    %ebp
  80049f:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a0:	83 ec 08             	sub    $0x8,%esp
  8004a3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004a6:	50                   	push   %eax
  8004a7:	ff 36                	push   (%esi)
  8004a9:	e8 5b ff ff ff       	call   800409 <dev_lookup>
  8004ae:	89 c3                	mov    %eax,%ebx
  8004b0:	83 c4 10             	add    $0x10,%esp
  8004b3:	85 c0                	test   %eax,%eax
  8004b5:	78 1a                	js     8004d1 <fd_close+0x77>
		if (dev->dev_close)
  8004b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ba:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8004bd:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004c2:	85 c0                	test   %eax,%eax
  8004c4:	74 0b                	je     8004d1 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  8004c6:	83 ec 0c             	sub    $0xc,%esp
  8004c9:	56                   	push   %esi
  8004ca:	ff d0                	call   *%eax
  8004cc:	89 c3                	mov    %eax,%ebx
  8004ce:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004d1:	83 ec 08             	sub    $0x8,%esp
  8004d4:	56                   	push   %esi
  8004d5:	6a 00                	push   $0x0
  8004d7:	e8 fa fc ff ff       	call   8001d6 <sys_page_unmap>
	return r;
  8004dc:	83 c4 10             	add    $0x10,%esp
  8004df:	eb b5                	jmp    800496 <fd_close+0x3c>

008004e1 <close>:

int
close(int fdnum)
{
  8004e1:	55                   	push   %ebp
  8004e2:	89 e5                	mov    %esp,%ebp
  8004e4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ea:	50                   	push   %eax
  8004eb:	ff 75 08             	push   0x8(%ebp)
  8004ee:	e8 c6 fe ff ff       	call   8003b9 <fd_lookup>
  8004f3:	83 c4 10             	add    $0x10,%esp
  8004f6:	85 c0                	test   %eax,%eax
  8004f8:	79 02                	jns    8004fc <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8004fa:	c9                   	leave  
  8004fb:	c3                   	ret    
		return fd_close(fd, 1);
  8004fc:	83 ec 08             	sub    $0x8,%esp
  8004ff:	6a 01                	push   $0x1
  800501:	ff 75 f4             	push   -0xc(%ebp)
  800504:	e8 51 ff ff ff       	call   80045a <fd_close>
  800509:	83 c4 10             	add    $0x10,%esp
  80050c:	eb ec                	jmp    8004fa <close+0x19>

0080050e <close_all>:

void
close_all(void)
{
  80050e:	55                   	push   %ebp
  80050f:	89 e5                	mov    %esp,%ebp
  800511:	53                   	push   %ebx
  800512:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800515:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80051a:	83 ec 0c             	sub    $0xc,%esp
  80051d:	53                   	push   %ebx
  80051e:	e8 be ff ff ff       	call   8004e1 <close>
	for (i = 0; i < MAXFD; i++)
  800523:	83 c3 01             	add    $0x1,%ebx
  800526:	83 c4 10             	add    $0x10,%esp
  800529:	83 fb 20             	cmp    $0x20,%ebx
  80052c:	75 ec                	jne    80051a <close_all+0xc>
}
  80052e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800531:	c9                   	leave  
  800532:	c3                   	ret    

00800533 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800533:	55                   	push   %ebp
  800534:	89 e5                	mov    %esp,%ebp
  800536:	57                   	push   %edi
  800537:	56                   	push   %esi
  800538:	53                   	push   %ebx
  800539:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80053c:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80053f:	50                   	push   %eax
  800540:	ff 75 08             	push   0x8(%ebp)
  800543:	e8 71 fe ff ff       	call   8003b9 <fd_lookup>
  800548:	89 c3                	mov    %eax,%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	85 c0                	test   %eax,%eax
  80054f:	78 7f                	js     8005d0 <dup+0x9d>
		return r;
	close(newfdnum);
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	ff 75 0c             	push   0xc(%ebp)
  800557:	e8 85 ff ff ff       	call   8004e1 <close>

	newfd = INDEX2FD(newfdnum);
  80055c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80055f:	c1 e6 0c             	shl    $0xc,%esi
  800562:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800568:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056b:	89 3c 24             	mov    %edi,(%esp)
  80056e:	e8 df fd ff ff       	call   800352 <fd2data>
  800573:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800575:	89 34 24             	mov    %esi,(%esp)
  800578:	e8 d5 fd ff ff       	call   800352 <fd2data>
  80057d:	83 c4 10             	add    $0x10,%esp
  800580:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800583:	89 d8                	mov    %ebx,%eax
  800585:	c1 e8 16             	shr    $0x16,%eax
  800588:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80058f:	a8 01                	test   $0x1,%al
  800591:	74 11                	je     8005a4 <dup+0x71>
  800593:	89 d8                	mov    %ebx,%eax
  800595:	c1 e8 0c             	shr    $0xc,%eax
  800598:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80059f:	f6 c2 01             	test   $0x1,%dl
  8005a2:	75 36                	jne    8005da <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005a4:	89 f8                	mov    %edi,%eax
  8005a6:	c1 e8 0c             	shr    $0xc,%eax
  8005a9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b0:	83 ec 0c             	sub    $0xc,%esp
  8005b3:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b8:	50                   	push   %eax
  8005b9:	56                   	push   %esi
  8005ba:	6a 00                	push   $0x0
  8005bc:	57                   	push   %edi
  8005bd:	6a 00                	push   $0x0
  8005bf:	e8 d0 fb ff ff       	call   800194 <sys_page_map>
  8005c4:	89 c3                	mov    %eax,%ebx
  8005c6:	83 c4 20             	add    $0x20,%esp
  8005c9:	85 c0                	test   %eax,%eax
  8005cb:	78 33                	js     800600 <dup+0xcd>
		goto err;

	return newfdnum;
  8005cd:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005d0:	89 d8                	mov    %ebx,%eax
  8005d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005d5:	5b                   	pop    %ebx
  8005d6:	5e                   	pop    %esi
  8005d7:	5f                   	pop    %edi
  8005d8:	5d                   	pop    %ebp
  8005d9:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005da:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e1:	83 ec 0c             	sub    $0xc,%esp
  8005e4:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e9:	50                   	push   %eax
  8005ea:	ff 75 d4             	push   -0x2c(%ebp)
  8005ed:	6a 00                	push   $0x0
  8005ef:	53                   	push   %ebx
  8005f0:	6a 00                	push   $0x0
  8005f2:	e8 9d fb ff ff       	call   800194 <sys_page_map>
  8005f7:	89 c3                	mov    %eax,%ebx
  8005f9:	83 c4 20             	add    $0x20,%esp
  8005fc:	85 c0                	test   %eax,%eax
  8005fe:	79 a4                	jns    8005a4 <dup+0x71>
	sys_page_unmap(0, newfd);
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	56                   	push   %esi
  800604:	6a 00                	push   $0x0
  800606:	e8 cb fb ff ff       	call   8001d6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80060b:	83 c4 08             	add    $0x8,%esp
  80060e:	ff 75 d4             	push   -0x2c(%ebp)
  800611:	6a 00                	push   $0x0
  800613:	e8 be fb ff ff       	call   8001d6 <sys_page_unmap>
	return r;
  800618:	83 c4 10             	add    $0x10,%esp
  80061b:	eb b3                	jmp    8005d0 <dup+0x9d>

0080061d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80061d:	55                   	push   %ebp
  80061e:	89 e5                	mov    %esp,%ebp
  800620:	56                   	push   %esi
  800621:	53                   	push   %ebx
  800622:	83 ec 18             	sub    $0x18,%esp
  800625:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800628:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80062b:	50                   	push   %eax
  80062c:	56                   	push   %esi
  80062d:	e8 87 fd ff ff       	call   8003b9 <fd_lookup>
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	85 c0                	test   %eax,%eax
  800637:	78 3c                	js     800675 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800639:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  80063c:	83 ec 08             	sub    $0x8,%esp
  80063f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800642:	50                   	push   %eax
  800643:	ff 33                	push   (%ebx)
  800645:	e8 bf fd ff ff       	call   800409 <dev_lookup>
  80064a:	83 c4 10             	add    $0x10,%esp
  80064d:	85 c0                	test   %eax,%eax
  80064f:	78 24                	js     800675 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800651:	8b 43 08             	mov    0x8(%ebx),%eax
  800654:	83 e0 03             	and    $0x3,%eax
  800657:	83 f8 01             	cmp    $0x1,%eax
  80065a:	74 20                	je     80067c <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80065c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80065f:	8b 40 08             	mov    0x8(%eax),%eax
  800662:	85 c0                	test   %eax,%eax
  800664:	74 37                	je     80069d <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800666:	83 ec 04             	sub    $0x4,%esp
  800669:	ff 75 10             	push   0x10(%ebp)
  80066c:	ff 75 0c             	push   0xc(%ebp)
  80066f:	53                   	push   %ebx
  800670:	ff d0                	call   *%eax
  800672:	83 c4 10             	add    $0x10,%esp
}
  800675:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800678:	5b                   	pop    %ebx
  800679:	5e                   	pop    %esi
  80067a:	5d                   	pop    %ebp
  80067b:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80067c:	a1 00 40 80 00       	mov    0x804000,%eax
  800681:	8b 40 48             	mov    0x48(%eax),%eax
  800684:	83 ec 04             	sub    $0x4,%esp
  800687:	56                   	push   %esi
  800688:	50                   	push   %eax
  800689:	68 d9 1d 80 00       	push   $0x801dd9
  80068e:	e8 2b 0a 00 00       	call   8010be <cprintf>
		return -E_INVAL;
  800693:	83 c4 10             	add    $0x10,%esp
  800696:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80069b:	eb d8                	jmp    800675 <read+0x58>
		return -E_NOT_SUPP;
  80069d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006a2:	eb d1                	jmp    800675 <read+0x58>

008006a4 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006a4:	55                   	push   %ebp
  8006a5:	89 e5                	mov    %esp,%ebp
  8006a7:	57                   	push   %edi
  8006a8:	56                   	push   %esi
  8006a9:	53                   	push   %ebx
  8006aa:	83 ec 0c             	sub    $0xc,%esp
  8006ad:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006b0:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006b8:	eb 02                	jmp    8006bc <readn+0x18>
  8006ba:	01 c3                	add    %eax,%ebx
  8006bc:	39 f3                	cmp    %esi,%ebx
  8006be:	73 21                	jae    8006e1 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006c0:	83 ec 04             	sub    $0x4,%esp
  8006c3:	89 f0                	mov    %esi,%eax
  8006c5:	29 d8                	sub    %ebx,%eax
  8006c7:	50                   	push   %eax
  8006c8:	89 d8                	mov    %ebx,%eax
  8006ca:	03 45 0c             	add    0xc(%ebp),%eax
  8006cd:	50                   	push   %eax
  8006ce:	57                   	push   %edi
  8006cf:	e8 49 ff ff ff       	call   80061d <read>
		if (m < 0)
  8006d4:	83 c4 10             	add    $0x10,%esp
  8006d7:	85 c0                	test   %eax,%eax
  8006d9:	78 04                	js     8006df <readn+0x3b>
			return m;
		if (m == 0)
  8006db:	75 dd                	jne    8006ba <readn+0x16>
  8006dd:	eb 02                	jmp    8006e1 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006df:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006e1:	89 d8                	mov    %ebx,%eax
  8006e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e6:	5b                   	pop    %ebx
  8006e7:	5e                   	pop    %esi
  8006e8:	5f                   	pop    %edi
  8006e9:	5d                   	pop    %ebp
  8006ea:	c3                   	ret    

008006eb <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006eb:	55                   	push   %ebp
  8006ec:	89 e5                	mov    %esp,%ebp
  8006ee:	56                   	push   %esi
  8006ef:	53                   	push   %ebx
  8006f0:	83 ec 18             	sub    $0x18,%esp
  8006f3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006f6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006f9:	50                   	push   %eax
  8006fa:	53                   	push   %ebx
  8006fb:	e8 b9 fc ff ff       	call   8003b9 <fd_lookup>
  800700:	83 c4 10             	add    $0x10,%esp
  800703:	85 c0                	test   %eax,%eax
  800705:	78 37                	js     80073e <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800707:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800710:	50                   	push   %eax
  800711:	ff 36                	push   (%esi)
  800713:	e8 f1 fc ff ff       	call   800409 <dev_lookup>
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	85 c0                	test   %eax,%eax
  80071d:	78 1f                	js     80073e <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80071f:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800723:	74 20                	je     800745 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800725:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800728:	8b 40 0c             	mov    0xc(%eax),%eax
  80072b:	85 c0                	test   %eax,%eax
  80072d:	74 37                	je     800766 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80072f:	83 ec 04             	sub    $0x4,%esp
  800732:	ff 75 10             	push   0x10(%ebp)
  800735:	ff 75 0c             	push   0xc(%ebp)
  800738:	56                   	push   %esi
  800739:	ff d0                	call   *%eax
  80073b:	83 c4 10             	add    $0x10,%esp
}
  80073e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800741:	5b                   	pop    %ebx
  800742:	5e                   	pop    %esi
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800745:	a1 00 40 80 00       	mov    0x804000,%eax
  80074a:	8b 40 48             	mov    0x48(%eax),%eax
  80074d:	83 ec 04             	sub    $0x4,%esp
  800750:	53                   	push   %ebx
  800751:	50                   	push   %eax
  800752:	68 f5 1d 80 00       	push   $0x801df5
  800757:	e8 62 09 00 00       	call   8010be <cprintf>
		return -E_INVAL;
  80075c:	83 c4 10             	add    $0x10,%esp
  80075f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800764:	eb d8                	jmp    80073e <write+0x53>
		return -E_NOT_SUPP;
  800766:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80076b:	eb d1                	jmp    80073e <write+0x53>

0080076d <seek>:

int
seek(int fdnum, off_t offset)
{
  80076d:	55                   	push   %ebp
  80076e:	89 e5                	mov    %esp,%ebp
  800770:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800773:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800776:	50                   	push   %eax
  800777:	ff 75 08             	push   0x8(%ebp)
  80077a:	e8 3a fc ff ff       	call   8003b9 <fd_lookup>
  80077f:	83 c4 10             	add    $0x10,%esp
  800782:	85 c0                	test   %eax,%eax
  800784:	78 0e                	js     800794 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800786:	8b 55 0c             	mov    0xc(%ebp),%edx
  800789:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80078f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
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
  8007a6:	e8 0e fc ff ff       	call   8003b9 <fd_lookup>
  8007ab:	83 c4 10             	add    $0x10,%esp
  8007ae:	85 c0                	test   %eax,%eax
  8007b0:	78 34                	js     8007e6 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b2:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007bb:	50                   	push   %eax
  8007bc:	ff 36                	push   (%esi)
  8007be:	e8 46 fc ff ff       	call   800409 <dev_lookup>
  8007c3:	83 c4 10             	add    $0x10,%esp
  8007c6:	85 c0                	test   %eax,%eax
  8007c8:	78 1c                	js     8007e6 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ca:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8007ce:	74 1d                	je     8007ed <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d3:	8b 40 18             	mov    0x18(%eax),%eax
  8007d6:	85 c0                	test   %eax,%eax
  8007d8:	74 34                	je     80080e <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007da:	83 ec 08             	sub    $0x8,%esp
  8007dd:	ff 75 0c             	push   0xc(%ebp)
  8007e0:	56                   	push   %esi
  8007e1:	ff d0                	call   *%eax
  8007e3:	83 c4 10             	add    $0x10,%esp
}
  8007e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007e9:	5b                   	pop    %ebx
  8007ea:	5e                   	pop    %esi
  8007eb:	5d                   	pop    %ebp
  8007ec:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007ed:	a1 00 40 80 00       	mov    0x804000,%eax
  8007f2:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f5:	83 ec 04             	sub    $0x4,%esp
  8007f8:	53                   	push   %ebx
  8007f9:	50                   	push   %eax
  8007fa:	68 b8 1d 80 00       	push   $0x801db8
  8007ff:	e8 ba 08 00 00       	call   8010be <cprintf>
		return -E_INVAL;
  800804:	83 c4 10             	add    $0x10,%esp
  800807:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80080c:	eb d8                	jmp    8007e6 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80080e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800813:	eb d1                	jmp    8007e6 <ftruncate+0x50>

00800815 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	56                   	push   %esi
  800819:	53                   	push   %ebx
  80081a:	83 ec 18             	sub    $0x18,%esp
  80081d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800820:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800823:	50                   	push   %eax
  800824:	ff 75 08             	push   0x8(%ebp)
  800827:	e8 8d fb ff ff       	call   8003b9 <fd_lookup>
  80082c:	83 c4 10             	add    $0x10,%esp
  80082f:	85 c0                	test   %eax,%eax
  800831:	78 49                	js     80087c <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800833:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800836:	83 ec 08             	sub    $0x8,%esp
  800839:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80083c:	50                   	push   %eax
  80083d:	ff 36                	push   (%esi)
  80083f:	e8 c5 fb ff ff       	call   800409 <dev_lookup>
  800844:	83 c4 10             	add    $0x10,%esp
  800847:	85 c0                	test   %eax,%eax
  800849:	78 31                	js     80087c <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  80084b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800852:	74 2f                	je     800883 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800854:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800857:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80085e:	00 00 00 
	stat->st_isdir = 0;
  800861:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800868:	00 00 00 
	stat->st_dev = dev;
  80086b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800871:	83 ec 08             	sub    $0x8,%esp
  800874:	53                   	push   %ebx
  800875:	56                   	push   %esi
  800876:	ff 50 14             	call   *0x14(%eax)
  800879:	83 c4 10             	add    $0x10,%esp
}
  80087c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80087f:	5b                   	pop    %ebx
  800880:	5e                   	pop    %esi
  800881:	5d                   	pop    %ebp
  800882:	c3                   	ret    
		return -E_NOT_SUPP;
  800883:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800888:	eb f2                	jmp    80087c <fstat+0x67>

0080088a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	56                   	push   %esi
  80088e:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80088f:	83 ec 08             	sub    $0x8,%esp
  800892:	6a 00                	push   $0x0
  800894:	ff 75 08             	push   0x8(%ebp)
  800897:	e8 e4 01 00 00       	call   800a80 <open>
  80089c:	89 c3                	mov    %eax,%ebx
  80089e:	83 c4 10             	add    $0x10,%esp
  8008a1:	85 c0                	test   %eax,%eax
  8008a3:	78 1b                	js     8008c0 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	ff 75 0c             	push   0xc(%ebp)
  8008ab:	50                   	push   %eax
  8008ac:	e8 64 ff ff ff       	call   800815 <fstat>
  8008b1:	89 c6                	mov    %eax,%esi
	close(fd);
  8008b3:	89 1c 24             	mov    %ebx,(%esp)
  8008b6:	e8 26 fc ff ff       	call   8004e1 <close>
	return r;
  8008bb:	83 c4 10             	add    $0x10,%esp
  8008be:	89 f3                	mov    %esi,%ebx
}
  8008c0:	89 d8                	mov    %ebx,%eax
  8008c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008c5:	5b                   	pop    %ebx
  8008c6:	5e                   	pop    %esi
  8008c7:	5d                   	pop    %ebp
  8008c8:	c3                   	ret    

008008c9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008c9:	55                   	push   %ebp
  8008ca:	89 e5                	mov    %esp,%ebp
  8008cc:	56                   	push   %esi
  8008cd:	53                   	push   %ebx
  8008ce:	89 c6                	mov    %eax,%esi
  8008d0:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008d2:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8008d9:	74 27                	je     800902 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008db:	6a 07                	push   $0x7
  8008dd:	68 00 50 80 00       	push   $0x805000
  8008e2:	56                   	push   %esi
  8008e3:	ff 35 00 60 80 00    	push   0x806000
  8008e9:	e8 51 11 00 00       	call   801a3f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008ee:	83 c4 0c             	add    $0xc,%esp
  8008f1:	6a 00                	push   $0x0
  8008f3:	53                   	push   %ebx
  8008f4:	6a 00                	push   $0x0
  8008f6:	e8 dd 10 00 00       	call   8019d8 <ipc_recv>
}
  8008fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008fe:	5b                   	pop    %ebx
  8008ff:	5e                   	pop    %esi
  800900:	5d                   	pop    %ebp
  800901:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800902:	83 ec 0c             	sub    $0xc,%esp
  800905:	6a 01                	push   $0x1
  800907:	e8 87 11 00 00       	call   801a93 <ipc_find_env>
  80090c:	a3 00 60 80 00       	mov    %eax,0x806000
  800911:	83 c4 10             	add    $0x10,%esp
  800914:	eb c5                	jmp    8008db <fsipc+0x12>

00800916 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80091c:	8b 45 08             	mov    0x8(%ebp),%eax
  80091f:	8b 40 0c             	mov    0xc(%eax),%eax
  800922:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800927:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092a:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80092f:	ba 00 00 00 00       	mov    $0x0,%edx
  800934:	b8 02 00 00 00       	mov    $0x2,%eax
  800939:	e8 8b ff ff ff       	call   8008c9 <fsipc>
}
  80093e:	c9                   	leave  
  80093f:	c3                   	ret    

00800940 <devfile_flush>:
{
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	8b 40 0c             	mov    0xc(%eax),%eax
  80094c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800951:	ba 00 00 00 00       	mov    $0x0,%edx
  800956:	b8 06 00 00 00       	mov    $0x6,%eax
  80095b:	e8 69 ff ff ff       	call   8008c9 <fsipc>
}
  800960:	c9                   	leave  
  800961:	c3                   	ret    

00800962 <devfile_stat>:
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	53                   	push   %ebx
  800966:	83 ec 04             	sub    $0x4,%esp
  800969:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80096c:	8b 45 08             	mov    0x8(%ebp),%eax
  80096f:	8b 40 0c             	mov    0xc(%eax),%eax
  800972:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800977:	ba 00 00 00 00       	mov    $0x0,%edx
  80097c:	b8 05 00 00 00       	mov    $0x5,%eax
  800981:	e8 43 ff ff ff       	call   8008c9 <fsipc>
  800986:	85 c0                	test   %eax,%eax
  800988:	78 2c                	js     8009b6 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80098a:	83 ec 08             	sub    $0x8,%esp
  80098d:	68 00 50 80 00       	push   $0x805000
  800992:	53                   	push   %ebx
  800993:	e8 00 0d 00 00       	call   801698 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800998:	a1 80 50 80 00       	mov    0x805080,%eax
  80099d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009a3:	a1 84 50 80 00       	mov    0x805084,%eax
  8009a8:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ae:	83 c4 10             	add    $0x10,%esp
  8009b1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009b9:	c9                   	leave  
  8009ba:	c3                   	ret    

008009bb <devfile_write>:
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	83 ec 0c             	sub    $0xc,%esp
  8009c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c4:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009c9:	39 d0                	cmp    %edx,%eax
  8009cb:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009ce:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d1:	8b 52 0c             	mov    0xc(%edx),%edx
  8009d4:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009da:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8009df:	50                   	push   %eax
  8009e0:	ff 75 0c             	push   0xc(%ebp)
  8009e3:	68 08 50 80 00       	push   $0x805008
  8009e8:	e8 41 0e 00 00       	call   80182e <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  8009ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f2:	b8 04 00 00 00       	mov    $0x4,%eax
  8009f7:	e8 cd fe ff ff       	call   8008c9 <fsipc>
}
  8009fc:	c9                   	leave  
  8009fd:	c3                   	ret    

008009fe <devfile_read>:
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	56                   	push   %esi
  800a02:	53                   	push   %ebx
  800a03:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a06:	8b 45 08             	mov    0x8(%ebp),%eax
  800a09:	8b 40 0c             	mov    0xc(%eax),%eax
  800a0c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a11:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a17:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1c:	b8 03 00 00 00       	mov    $0x3,%eax
  800a21:	e8 a3 fe ff ff       	call   8008c9 <fsipc>
  800a26:	89 c3                	mov    %eax,%ebx
  800a28:	85 c0                	test   %eax,%eax
  800a2a:	78 1f                	js     800a4b <devfile_read+0x4d>
	assert(r <= n);
  800a2c:	39 f0                	cmp    %esi,%eax
  800a2e:	77 24                	ja     800a54 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a30:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a35:	7f 33                	jg     800a6a <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a37:	83 ec 04             	sub    $0x4,%esp
  800a3a:	50                   	push   %eax
  800a3b:	68 00 50 80 00       	push   $0x805000
  800a40:	ff 75 0c             	push   0xc(%ebp)
  800a43:	e8 e6 0d 00 00       	call   80182e <memmove>
	return r;
  800a48:	83 c4 10             	add    $0x10,%esp
}
  800a4b:	89 d8                	mov    %ebx,%eax
  800a4d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a50:	5b                   	pop    %ebx
  800a51:	5e                   	pop    %esi
  800a52:	5d                   	pop    %ebp
  800a53:	c3                   	ret    
	assert(r <= n);
  800a54:	68 24 1e 80 00       	push   $0x801e24
  800a59:	68 2b 1e 80 00       	push   $0x801e2b
  800a5e:	6a 7c                	push   $0x7c
  800a60:	68 40 1e 80 00       	push   $0x801e40
  800a65:	e8 79 05 00 00       	call   800fe3 <_panic>
	assert(r <= PGSIZE);
  800a6a:	68 4b 1e 80 00       	push   $0x801e4b
  800a6f:	68 2b 1e 80 00       	push   $0x801e2b
  800a74:	6a 7d                	push   $0x7d
  800a76:	68 40 1e 80 00       	push   $0x801e40
  800a7b:	e8 63 05 00 00       	call   800fe3 <_panic>

00800a80 <open>:
{
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	56                   	push   %esi
  800a84:	53                   	push   %ebx
  800a85:	83 ec 1c             	sub    $0x1c,%esp
  800a88:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800a8b:	56                   	push   %esi
  800a8c:	e8 cc 0b 00 00       	call   80165d <strlen>
  800a91:	83 c4 10             	add    $0x10,%esp
  800a94:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800a99:	7f 6c                	jg     800b07 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800a9b:	83 ec 0c             	sub    $0xc,%esp
  800a9e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aa1:	50                   	push   %eax
  800aa2:	e8 c2 f8 ff ff       	call   800369 <fd_alloc>
  800aa7:	89 c3                	mov    %eax,%ebx
  800aa9:	83 c4 10             	add    $0x10,%esp
  800aac:	85 c0                	test   %eax,%eax
  800aae:	78 3c                	js     800aec <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800ab0:	83 ec 08             	sub    $0x8,%esp
  800ab3:	56                   	push   %esi
  800ab4:	68 00 50 80 00       	push   $0x805000
  800ab9:	e8 da 0b 00 00       	call   801698 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac1:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ac6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ac9:	b8 01 00 00 00       	mov    $0x1,%eax
  800ace:	e8 f6 fd ff ff       	call   8008c9 <fsipc>
  800ad3:	89 c3                	mov    %eax,%ebx
  800ad5:	83 c4 10             	add    $0x10,%esp
  800ad8:	85 c0                	test   %eax,%eax
  800ada:	78 19                	js     800af5 <open+0x75>
	return fd2num(fd);
  800adc:	83 ec 0c             	sub    $0xc,%esp
  800adf:	ff 75 f4             	push   -0xc(%ebp)
  800ae2:	e8 5b f8 ff ff       	call   800342 <fd2num>
  800ae7:	89 c3                	mov    %eax,%ebx
  800ae9:	83 c4 10             	add    $0x10,%esp
}
  800aec:	89 d8                	mov    %ebx,%eax
  800aee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af1:	5b                   	pop    %ebx
  800af2:	5e                   	pop    %esi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    
		fd_close(fd, 0);
  800af5:	83 ec 08             	sub    $0x8,%esp
  800af8:	6a 00                	push   $0x0
  800afa:	ff 75 f4             	push   -0xc(%ebp)
  800afd:	e8 58 f9 ff ff       	call   80045a <fd_close>
		return r;
  800b02:	83 c4 10             	add    $0x10,%esp
  800b05:	eb e5                	jmp    800aec <open+0x6c>
		return -E_BAD_PATH;
  800b07:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b0c:	eb de                	jmp    800aec <open+0x6c>

00800b0e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b14:	ba 00 00 00 00       	mov    $0x0,%edx
  800b19:	b8 08 00 00 00       	mov    $0x8,%eax
  800b1e:	e8 a6 fd ff ff       	call   8008c9 <fsipc>
}
  800b23:	c9                   	leave  
  800b24:	c3                   	ret    

00800b25 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	56                   	push   %esi
  800b29:	53                   	push   %ebx
  800b2a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b2d:	83 ec 0c             	sub    $0xc,%esp
  800b30:	ff 75 08             	push   0x8(%ebp)
  800b33:	e8 1a f8 ff ff       	call   800352 <fd2data>
  800b38:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b3a:	83 c4 08             	add    $0x8,%esp
  800b3d:	68 57 1e 80 00       	push   $0x801e57
  800b42:	53                   	push   %ebx
  800b43:	e8 50 0b 00 00       	call   801698 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b48:	8b 46 04             	mov    0x4(%esi),%eax
  800b4b:	2b 06                	sub    (%esi),%eax
  800b4d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b53:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b5a:	00 00 00 
	stat->st_dev = &devpipe;
  800b5d:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b64:	30 80 00 
	return 0;
}
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b6f:	5b                   	pop    %ebx
  800b70:	5e                   	pop    %esi
  800b71:	5d                   	pop    %ebp
  800b72:	c3                   	ret    

00800b73 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b73:	55                   	push   %ebp
  800b74:	89 e5                	mov    %esp,%ebp
  800b76:	53                   	push   %ebx
  800b77:	83 ec 0c             	sub    $0xc,%esp
  800b7a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800b7d:	53                   	push   %ebx
  800b7e:	6a 00                	push   $0x0
  800b80:	e8 51 f6 ff ff       	call   8001d6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800b85:	89 1c 24             	mov    %ebx,(%esp)
  800b88:	e8 c5 f7 ff ff       	call   800352 <fd2data>
  800b8d:	83 c4 08             	add    $0x8,%esp
  800b90:	50                   	push   %eax
  800b91:	6a 00                	push   $0x0
  800b93:	e8 3e f6 ff ff       	call   8001d6 <sys_page_unmap>
}
  800b98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b9b:	c9                   	leave  
  800b9c:	c3                   	ret    

00800b9d <_pipeisclosed>:
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 1c             	sub    $0x1c,%esp
  800ba6:	89 c7                	mov    %eax,%edi
  800ba8:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800baa:	a1 00 40 80 00       	mov    0x804000,%eax
  800baf:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bb2:	83 ec 0c             	sub    $0xc,%esp
  800bb5:	57                   	push   %edi
  800bb6:	e8 11 0f 00 00       	call   801acc <pageref>
  800bbb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bbe:	89 34 24             	mov    %esi,(%esp)
  800bc1:	e8 06 0f 00 00       	call   801acc <pageref>
		nn = thisenv->env_runs;
  800bc6:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800bcc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bcf:	83 c4 10             	add    $0x10,%esp
  800bd2:	39 cb                	cmp    %ecx,%ebx
  800bd4:	74 1b                	je     800bf1 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800bd6:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800bd9:	75 cf                	jne    800baa <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800bdb:	8b 42 58             	mov    0x58(%edx),%eax
  800bde:	6a 01                	push   $0x1
  800be0:	50                   	push   %eax
  800be1:	53                   	push   %ebx
  800be2:	68 5e 1e 80 00       	push   $0x801e5e
  800be7:	e8 d2 04 00 00       	call   8010be <cprintf>
  800bec:	83 c4 10             	add    $0x10,%esp
  800bef:	eb b9                	jmp    800baa <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800bf1:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800bf4:	0f 94 c0             	sete   %al
  800bf7:	0f b6 c0             	movzbl %al,%eax
}
  800bfa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfd:	5b                   	pop    %ebx
  800bfe:	5e                   	pop    %esi
  800bff:	5f                   	pop    %edi
  800c00:	5d                   	pop    %ebp
  800c01:	c3                   	ret    

00800c02 <devpipe_write>:
{
  800c02:	55                   	push   %ebp
  800c03:	89 e5                	mov    %esp,%ebp
  800c05:	57                   	push   %edi
  800c06:	56                   	push   %esi
  800c07:	53                   	push   %ebx
  800c08:	83 ec 28             	sub    $0x28,%esp
  800c0b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c0e:	56                   	push   %esi
  800c0f:	e8 3e f7 ff ff       	call   800352 <fd2data>
  800c14:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c16:	83 c4 10             	add    $0x10,%esp
  800c19:	bf 00 00 00 00       	mov    $0x0,%edi
  800c1e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c21:	75 09                	jne    800c2c <devpipe_write+0x2a>
	return i;
  800c23:	89 f8                	mov    %edi,%eax
  800c25:	eb 23                	jmp    800c4a <devpipe_write+0x48>
			sys_yield();
  800c27:	e8 06 f5 ff ff       	call   800132 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c2c:	8b 43 04             	mov    0x4(%ebx),%eax
  800c2f:	8b 0b                	mov    (%ebx),%ecx
  800c31:	8d 51 20             	lea    0x20(%ecx),%edx
  800c34:	39 d0                	cmp    %edx,%eax
  800c36:	72 1a                	jb     800c52 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  800c38:	89 da                	mov    %ebx,%edx
  800c3a:	89 f0                	mov    %esi,%eax
  800c3c:	e8 5c ff ff ff       	call   800b9d <_pipeisclosed>
  800c41:	85 c0                	test   %eax,%eax
  800c43:	74 e2                	je     800c27 <devpipe_write+0x25>
				return 0;
  800c45:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c4a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4d:	5b                   	pop    %ebx
  800c4e:	5e                   	pop    %esi
  800c4f:	5f                   	pop    %edi
  800c50:	5d                   	pop    %ebp
  800c51:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c52:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c55:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c59:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c5c:	89 c2                	mov    %eax,%edx
  800c5e:	c1 fa 1f             	sar    $0x1f,%edx
  800c61:	89 d1                	mov    %edx,%ecx
  800c63:	c1 e9 1b             	shr    $0x1b,%ecx
  800c66:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c69:	83 e2 1f             	and    $0x1f,%edx
  800c6c:	29 ca                	sub    %ecx,%edx
  800c6e:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c72:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c76:	83 c0 01             	add    $0x1,%eax
  800c79:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c7c:	83 c7 01             	add    $0x1,%edi
  800c7f:	eb 9d                	jmp    800c1e <devpipe_write+0x1c>

00800c81 <devpipe_read>:
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	57                   	push   %edi
  800c85:	56                   	push   %esi
  800c86:	53                   	push   %ebx
  800c87:	83 ec 18             	sub    $0x18,%esp
  800c8a:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800c8d:	57                   	push   %edi
  800c8e:	e8 bf f6 ff ff       	call   800352 <fd2data>
  800c93:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c95:	83 c4 10             	add    $0x10,%esp
  800c98:	be 00 00 00 00       	mov    $0x0,%esi
  800c9d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ca0:	75 13                	jne    800cb5 <devpipe_read+0x34>
	return i;
  800ca2:	89 f0                	mov    %esi,%eax
  800ca4:	eb 02                	jmp    800ca8 <devpipe_read+0x27>
				return i;
  800ca6:	89 f0                	mov    %esi,%eax
}
  800ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    
			sys_yield();
  800cb0:	e8 7d f4 ff ff       	call   800132 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800cb5:	8b 03                	mov    (%ebx),%eax
  800cb7:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cba:	75 18                	jne    800cd4 <devpipe_read+0x53>
			if (i > 0)
  800cbc:	85 f6                	test   %esi,%esi
  800cbe:	75 e6                	jne    800ca6 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  800cc0:	89 da                	mov    %ebx,%edx
  800cc2:	89 f8                	mov    %edi,%eax
  800cc4:	e8 d4 fe ff ff       	call   800b9d <_pipeisclosed>
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	74 e3                	je     800cb0 <devpipe_read+0x2f>
				return 0;
  800ccd:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd2:	eb d4                	jmp    800ca8 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cd4:	99                   	cltd   
  800cd5:	c1 ea 1b             	shr    $0x1b,%edx
  800cd8:	01 d0                	add    %edx,%eax
  800cda:	83 e0 1f             	and    $0x1f,%eax
  800cdd:	29 d0                	sub    %edx,%eax
  800cdf:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800ce4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce7:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800cea:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800ced:	83 c6 01             	add    $0x1,%esi
  800cf0:	eb ab                	jmp    800c9d <devpipe_read+0x1c>

00800cf2 <pipe>:
{
  800cf2:	55                   	push   %ebp
  800cf3:	89 e5                	mov    %esp,%ebp
  800cf5:	56                   	push   %esi
  800cf6:	53                   	push   %ebx
  800cf7:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800cfa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800cfd:	50                   	push   %eax
  800cfe:	e8 66 f6 ff ff       	call   800369 <fd_alloc>
  800d03:	89 c3                	mov    %eax,%ebx
  800d05:	83 c4 10             	add    $0x10,%esp
  800d08:	85 c0                	test   %eax,%eax
  800d0a:	0f 88 23 01 00 00    	js     800e33 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d10:	83 ec 04             	sub    $0x4,%esp
  800d13:	68 07 04 00 00       	push   $0x407
  800d18:	ff 75 f4             	push   -0xc(%ebp)
  800d1b:	6a 00                	push   $0x0
  800d1d:	e8 2f f4 ff ff       	call   800151 <sys_page_alloc>
  800d22:	89 c3                	mov    %eax,%ebx
  800d24:	83 c4 10             	add    $0x10,%esp
  800d27:	85 c0                	test   %eax,%eax
  800d29:	0f 88 04 01 00 00    	js     800e33 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  800d2f:	83 ec 0c             	sub    $0xc,%esp
  800d32:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d35:	50                   	push   %eax
  800d36:	e8 2e f6 ff ff       	call   800369 <fd_alloc>
  800d3b:	89 c3                	mov    %eax,%ebx
  800d3d:	83 c4 10             	add    $0x10,%esp
  800d40:	85 c0                	test   %eax,%eax
  800d42:	0f 88 db 00 00 00    	js     800e23 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d48:	83 ec 04             	sub    $0x4,%esp
  800d4b:	68 07 04 00 00       	push   $0x407
  800d50:	ff 75 f0             	push   -0x10(%ebp)
  800d53:	6a 00                	push   $0x0
  800d55:	e8 f7 f3 ff ff       	call   800151 <sys_page_alloc>
  800d5a:	89 c3                	mov    %eax,%ebx
  800d5c:	83 c4 10             	add    $0x10,%esp
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	0f 88 bc 00 00 00    	js     800e23 <pipe+0x131>
	va = fd2data(fd0);
  800d67:	83 ec 0c             	sub    $0xc,%esp
  800d6a:	ff 75 f4             	push   -0xc(%ebp)
  800d6d:	e8 e0 f5 ff ff       	call   800352 <fd2data>
  800d72:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d74:	83 c4 0c             	add    $0xc,%esp
  800d77:	68 07 04 00 00       	push   $0x407
  800d7c:	50                   	push   %eax
  800d7d:	6a 00                	push   $0x0
  800d7f:	e8 cd f3 ff ff       	call   800151 <sys_page_alloc>
  800d84:	89 c3                	mov    %eax,%ebx
  800d86:	83 c4 10             	add    $0x10,%esp
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	0f 88 82 00 00 00    	js     800e13 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d91:	83 ec 0c             	sub    $0xc,%esp
  800d94:	ff 75 f0             	push   -0x10(%ebp)
  800d97:	e8 b6 f5 ff ff       	call   800352 <fd2data>
  800d9c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800da3:	50                   	push   %eax
  800da4:	6a 00                	push   $0x0
  800da6:	56                   	push   %esi
  800da7:	6a 00                	push   $0x0
  800da9:	e8 e6 f3 ff ff       	call   800194 <sys_page_map>
  800dae:	89 c3                	mov    %eax,%ebx
  800db0:	83 c4 20             	add    $0x20,%esp
  800db3:	85 c0                	test   %eax,%eax
  800db5:	78 4e                	js     800e05 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  800db7:	a1 20 30 80 00       	mov    0x803020,%eax
  800dbc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dbf:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800dc1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dc4:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800dcb:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800dce:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800dd0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800dd3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800dda:	83 ec 0c             	sub    $0xc,%esp
  800ddd:	ff 75 f4             	push   -0xc(%ebp)
  800de0:	e8 5d f5 ff ff       	call   800342 <fd2num>
  800de5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800dea:	83 c4 04             	add    $0x4,%esp
  800ded:	ff 75 f0             	push   -0x10(%ebp)
  800df0:	e8 4d f5 ff ff       	call   800342 <fd2num>
  800df5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800df8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800dfb:	83 c4 10             	add    $0x10,%esp
  800dfe:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e03:	eb 2e                	jmp    800e33 <pipe+0x141>
	sys_page_unmap(0, va);
  800e05:	83 ec 08             	sub    $0x8,%esp
  800e08:	56                   	push   %esi
  800e09:	6a 00                	push   $0x0
  800e0b:	e8 c6 f3 ff ff       	call   8001d6 <sys_page_unmap>
  800e10:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e13:	83 ec 08             	sub    $0x8,%esp
  800e16:	ff 75 f0             	push   -0x10(%ebp)
  800e19:	6a 00                	push   $0x0
  800e1b:	e8 b6 f3 ff ff       	call   8001d6 <sys_page_unmap>
  800e20:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e23:	83 ec 08             	sub    $0x8,%esp
  800e26:	ff 75 f4             	push   -0xc(%ebp)
  800e29:	6a 00                	push   $0x0
  800e2b:	e8 a6 f3 ff ff       	call   8001d6 <sys_page_unmap>
  800e30:	83 c4 10             	add    $0x10,%esp
}
  800e33:	89 d8                	mov    %ebx,%eax
  800e35:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e38:	5b                   	pop    %ebx
  800e39:	5e                   	pop    %esi
  800e3a:	5d                   	pop    %ebp
  800e3b:	c3                   	ret    

00800e3c <pipeisclosed>:
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e42:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e45:	50                   	push   %eax
  800e46:	ff 75 08             	push   0x8(%ebp)
  800e49:	e8 6b f5 ff ff       	call   8003b9 <fd_lookup>
  800e4e:	83 c4 10             	add    $0x10,%esp
  800e51:	85 c0                	test   %eax,%eax
  800e53:	78 18                	js     800e6d <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  800e55:	83 ec 0c             	sub    $0xc,%esp
  800e58:	ff 75 f4             	push   -0xc(%ebp)
  800e5b:	e8 f2 f4 ff ff       	call   800352 <fd2data>
  800e60:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800e62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e65:	e8 33 fd ff ff       	call   800b9d <_pipeisclosed>
  800e6a:	83 c4 10             	add    $0x10,%esp
}
  800e6d:	c9                   	leave  
  800e6e:	c3                   	ret    

00800e6f <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  800e6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e74:	c3                   	ret    

00800e75 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800e7b:	68 76 1e 80 00       	push   $0x801e76
  800e80:	ff 75 0c             	push   0xc(%ebp)
  800e83:	e8 10 08 00 00       	call   801698 <strcpy>
	return 0;
}
  800e88:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8d:	c9                   	leave  
  800e8e:	c3                   	ret    

00800e8f <devcons_write>:
{
  800e8f:	55                   	push   %ebp
  800e90:	89 e5                	mov    %esp,%ebp
  800e92:	57                   	push   %edi
  800e93:	56                   	push   %esi
  800e94:	53                   	push   %ebx
  800e95:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800e9b:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ea0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800ea6:	eb 2e                	jmp    800ed6 <devcons_write+0x47>
		m = n - tot;
  800ea8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eab:	29 f3                	sub    %esi,%ebx
  800ead:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800eb2:	39 c3                	cmp    %eax,%ebx
  800eb4:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800eb7:	83 ec 04             	sub    $0x4,%esp
  800eba:	53                   	push   %ebx
  800ebb:	89 f0                	mov    %esi,%eax
  800ebd:	03 45 0c             	add    0xc(%ebp),%eax
  800ec0:	50                   	push   %eax
  800ec1:	57                   	push   %edi
  800ec2:	e8 67 09 00 00       	call   80182e <memmove>
		sys_cputs(buf, m);
  800ec7:	83 c4 08             	add    $0x8,%esp
  800eca:	53                   	push   %ebx
  800ecb:	57                   	push   %edi
  800ecc:	e8 c4 f1 ff ff       	call   800095 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800ed1:	01 de                	add    %ebx,%esi
  800ed3:	83 c4 10             	add    $0x10,%esp
  800ed6:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ed9:	72 cd                	jb     800ea8 <devcons_write+0x19>
}
  800edb:	89 f0                	mov    %esi,%eax
  800edd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <devcons_read>:
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	83 ec 08             	sub    $0x8,%esp
  800eeb:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800ef0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800ef4:	75 07                	jne    800efd <devcons_read+0x18>
  800ef6:	eb 1f                	jmp    800f17 <devcons_read+0x32>
		sys_yield();
  800ef8:	e8 35 f2 ff ff       	call   800132 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  800efd:	e8 b1 f1 ff ff       	call   8000b3 <sys_cgetc>
  800f02:	85 c0                	test   %eax,%eax
  800f04:	74 f2                	je     800ef8 <devcons_read+0x13>
	if (c < 0)
  800f06:	78 0f                	js     800f17 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  800f08:	83 f8 04             	cmp    $0x4,%eax
  800f0b:	74 0c                	je     800f19 <devcons_read+0x34>
	*(char*)vbuf = c;
  800f0d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f10:	88 02                	mov    %al,(%edx)
	return 1;
  800f12:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f17:	c9                   	leave  
  800f18:	c3                   	ret    
		return 0;
  800f19:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1e:	eb f7                	jmp    800f17 <devcons_read+0x32>

00800f20 <cputchar>:
{
  800f20:	55                   	push   %ebp
  800f21:	89 e5                	mov    %esp,%ebp
  800f23:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f26:	8b 45 08             	mov    0x8(%ebp),%eax
  800f29:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f2c:	6a 01                	push   $0x1
  800f2e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f31:	50                   	push   %eax
  800f32:	e8 5e f1 ff ff       	call   800095 <sys_cputs>
}
  800f37:	83 c4 10             	add    $0x10,%esp
  800f3a:	c9                   	leave  
  800f3b:	c3                   	ret    

00800f3c <getchar>:
{
  800f3c:	55                   	push   %ebp
  800f3d:	89 e5                	mov    %esp,%ebp
  800f3f:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f42:	6a 01                	push   $0x1
  800f44:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f47:	50                   	push   %eax
  800f48:	6a 00                	push   $0x0
  800f4a:	e8 ce f6 ff ff       	call   80061d <read>
	if (r < 0)
  800f4f:	83 c4 10             	add    $0x10,%esp
  800f52:	85 c0                	test   %eax,%eax
  800f54:	78 06                	js     800f5c <getchar+0x20>
	if (r < 1)
  800f56:	74 06                	je     800f5e <getchar+0x22>
	return c;
  800f58:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800f5c:	c9                   	leave  
  800f5d:	c3                   	ret    
		return -E_EOF;
  800f5e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800f63:	eb f7                	jmp    800f5c <getchar+0x20>

00800f65 <iscons>:
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f6e:	50                   	push   %eax
  800f6f:	ff 75 08             	push   0x8(%ebp)
  800f72:	e8 42 f4 ff ff       	call   8003b9 <fd_lookup>
  800f77:	83 c4 10             	add    $0x10,%esp
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	78 11                	js     800f8f <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  800f7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800f81:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800f87:	39 10                	cmp    %edx,(%eax)
  800f89:	0f 94 c0             	sete   %al
  800f8c:	0f b6 c0             	movzbl %al,%eax
}
  800f8f:	c9                   	leave  
  800f90:	c3                   	ret    

00800f91 <opencons>:
{
  800f91:	55                   	push   %ebp
  800f92:	89 e5                	mov    %esp,%ebp
  800f94:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800f97:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9a:	50                   	push   %eax
  800f9b:	e8 c9 f3 ff ff       	call   800369 <fd_alloc>
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	78 3a                	js     800fe1 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fa7:	83 ec 04             	sub    $0x4,%esp
  800faa:	68 07 04 00 00       	push   $0x407
  800faf:	ff 75 f4             	push   -0xc(%ebp)
  800fb2:	6a 00                	push   $0x0
  800fb4:	e8 98 f1 ff ff       	call   800151 <sys_page_alloc>
  800fb9:	83 c4 10             	add    $0x10,%esp
  800fbc:	85 c0                	test   %eax,%eax
  800fbe:	78 21                	js     800fe1 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  800fc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fc9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fce:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800fd5:	83 ec 0c             	sub    $0xc,%esp
  800fd8:	50                   	push   %eax
  800fd9:	e8 64 f3 ff ff       	call   800342 <fd2num>
  800fde:	83 c4 10             	add    $0x10,%esp
}
  800fe1:	c9                   	leave  
  800fe2:	c3                   	ret    

00800fe3 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	56                   	push   %esi
  800fe7:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800fe8:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800feb:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800ff1:	e8 1d f1 ff ff       	call   800113 <sys_getenvid>
  800ff6:	83 ec 0c             	sub    $0xc,%esp
  800ff9:	ff 75 0c             	push   0xc(%ebp)
  800ffc:	ff 75 08             	push   0x8(%ebp)
  800fff:	56                   	push   %esi
  801000:	50                   	push   %eax
  801001:	68 84 1e 80 00       	push   $0x801e84
  801006:	e8 b3 00 00 00       	call   8010be <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80100b:	83 c4 18             	add    $0x18,%esp
  80100e:	53                   	push   %ebx
  80100f:	ff 75 10             	push   0x10(%ebp)
  801012:	e8 56 00 00 00       	call   80106d <vcprintf>
	cprintf("\n");
  801017:	c7 04 24 6f 1e 80 00 	movl   $0x801e6f,(%esp)
  80101e:	e8 9b 00 00 00       	call   8010be <cprintf>
  801023:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801026:	cc                   	int3   
  801027:	eb fd                	jmp    801026 <_panic+0x43>

00801029 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801029:	55                   	push   %ebp
  80102a:	89 e5                	mov    %esp,%ebp
  80102c:	53                   	push   %ebx
  80102d:	83 ec 04             	sub    $0x4,%esp
  801030:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801033:	8b 13                	mov    (%ebx),%edx
  801035:	8d 42 01             	lea    0x1(%edx),%eax
  801038:	89 03                	mov    %eax,(%ebx)
  80103a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80103d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801041:	3d ff 00 00 00       	cmp    $0xff,%eax
  801046:	74 09                	je     801051 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801048:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80104c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80104f:	c9                   	leave  
  801050:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801051:	83 ec 08             	sub    $0x8,%esp
  801054:	68 ff 00 00 00       	push   $0xff
  801059:	8d 43 08             	lea    0x8(%ebx),%eax
  80105c:	50                   	push   %eax
  80105d:	e8 33 f0 ff ff       	call   800095 <sys_cputs>
		b->idx = 0;
  801062:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801068:	83 c4 10             	add    $0x10,%esp
  80106b:	eb db                	jmp    801048 <putch+0x1f>

0080106d <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801076:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80107d:	00 00 00 
	b.cnt = 0;
  801080:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801087:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80108a:	ff 75 0c             	push   0xc(%ebp)
  80108d:	ff 75 08             	push   0x8(%ebp)
  801090:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801096:	50                   	push   %eax
  801097:	68 29 10 80 00       	push   $0x801029
  80109c:	e8 14 01 00 00       	call   8011b5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010a1:	83 c4 08             	add    $0x8,%esp
  8010a4:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8010aa:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010b0:	50                   	push   %eax
  8010b1:	e8 df ef ff ff       	call   800095 <sys_cputs>

	return b.cnt;
}
  8010b6:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8010bc:	c9                   	leave  
  8010bd:	c3                   	ret    

008010be <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8010c4:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8010c7:	50                   	push   %eax
  8010c8:	ff 75 08             	push   0x8(%ebp)
  8010cb:	e8 9d ff ff ff       	call   80106d <vcprintf>
	va_end(ap);

	return cnt;
}
  8010d0:	c9                   	leave  
  8010d1:	c3                   	ret    

008010d2 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	57                   	push   %edi
  8010d6:	56                   	push   %esi
  8010d7:	53                   	push   %ebx
  8010d8:	83 ec 1c             	sub    $0x1c,%esp
  8010db:	89 c7                	mov    %eax,%edi
  8010dd:	89 d6                	mov    %edx,%esi
  8010df:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010e5:	89 d1                	mov    %edx,%ecx
  8010e7:	89 c2                	mov    %eax,%edx
  8010e9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8010ec:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8010ef:	8b 45 10             	mov    0x10(%ebp),%eax
  8010f2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8010f5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010f8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8010ff:	39 c2                	cmp    %eax,%edx
  801101:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801104:	72 3e                	jb     801144 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801106:	83 ec 0c             	sub    $0xc,%esp
  801109:	ff 75 18             	push   0x18(%ebp)
  80110c:	83 eb 01             	sub    $0x1,%ebx
  80110f:	53                   	push   %ebx
  801110:	50                   	push   %eax
  801111:	83 ec 08             	sub    $0x8,%esp
  801114:	ff 75 e4             	push   -0x1c(%ebp)
  801117:	ff 75 e0             	push   -0x20(%ebp)
  80111a:	ff 75 dc             	push   -0x24(%ebp)
  80111d:	ff 75 d8             	push   -0x28(%ebp)
  801120:	e8 eb 09 00 00       	call   801b10 <__udivdi3>
  801125:	83 c4 18             	add    $0x18,%esp
  801128:	52                   	push   %edx
  801129:	50                   	push   %eax
  80112a:	89 f2                	mov    %esi,%edx
  80112c:	89 f8                	mov    %edi,%eax
  80112e:	e8 9f ff ff ff       	call   8010d2 <printnum>
  801133:	83 c4 20             	add    $0x20,%esp
  801136:	eb 13                	jmp    80114b <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801138:	83 ec 08             	sub    $0x8,%esp
  80113b:	56                   	push   %esi
  80113c:	ff 75 18             	push   0x18(%ebp)
  80113f:	ff d7                	call   *%edi
  801141:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801144:	83 eb 01             	sub    $0x1,%ebx
  801147:	85 db                	test   %ebx,%ebx
  801149:	7f ed                	jg     801138 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80114b:	83 ec 08             	sub    $0x8,%esp
  80114e:	56                   	push   %esi
  80114f:	83 ec 04             	sub    $0x4,%esp
  801152:	ff 75 e4             	push   -0x1c(%ebp)
  801155:	ff 75 e0             	push   -0x20(%ebp)
  801158:	ff 75 dc             	push   -0x24(%ebp)
  80115b:	ff 75 d8             	push   -0x28(%ebp)
  80115e:	e8 cd 0a 00 00       	call   801c30 <__umoddi3>
  801163:	83 c4 14             	add    $0x14,%esp
  801166:	0f be 80 a7 1e 80 00 	movsbl 0x801ea7(%eax),%eax
  80116d:	50                   	push   %eax
  80116e:	ff d7                	call   *%edi
}
  801170:	83 c4 10             	add    $0x10,%esp
  801173:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801176:	5b                   	pop    %ebx
  801177:	5e                   	pop    %esi
  801178:	5f                   	pop    %edi
  801179:	5d                   	pop    %ebp
  80117a:	c3                   	ret    

0080117b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80117b:	55                   	push   %ebp
  80117c:	89 e5                	mov    %esp,%ebp
  80117e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801181:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801185:	8b 10                	mov    (%eax),%edx
  801187:	3b 50 04             	cmp    0x4(%eax),%edx
  80118a:	73 0a                	jae    801196 <sprintputch+0x1b>
		*b->buf++ = ch;
  80118c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80118f:	89 08                	mov    %ecx,(%eax)
  801191:	8b 45 08             	mov    0x8(%ebp),%eax
  801194:	88 02                	mov    %al,(%edx)
}
  801196:	5d                   	pop    %ebp
  801197:	c3                   	ret    

00801198 <printfmt>:
{
  801198:	55                   	push   %ebp
  801199:	89 e5                	mov    %esp,%ebp
  80119b:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80119e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8011a1:	50                   	push   %eax
  8011a2:	ff 75 10             	push   0x10(%ebp)
  8011a5:	ff 75 0c             	push   0xc(%ebp)
  8011a8:	ff 75 08             	push   0x8(%ebp)
  8011ab:	e8 05 00 00 00       	call   8011b5 <vprintfmt>
}
  8011b0:	83 c4 10             	add    $0x10,%esp
  8011b3:	c9                   	leave  
  8011b4:	c3                   	ret    

008011b5 <vprintfmt>:
{
  8011b5:	55                   	push   %ebp
  8011b6:	89 e5                	mov    %esp,%ebp
  8011b8:	57                   	push   %edi
  8011b9:	56                   	push   %esi
  8011ba:	53                   	push   %ebx
  8011bb:	83 ec 3c             	sub    $0x3c,%esp
  8011be:	8b 75 08             	mov    0x8(%ebp),%esi
  8011c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8011c4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011c7:	eb 0a                	jmp    8011d3 <vprintfmt+0x1e>
			putch(ch, putdat);
  8011c9:	83 ec 08             	sub    $0x8,%esp
  8011cc:	53                   	push   %ebx
  8011cd:	50                   	push   %eax
  8011ce:	ff d6                	call   *%esi
  8011d0:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8011d3:	83 c7 01             	add    $0x1,%edi
  8011d6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8011da:	83 f8 25             	cmp    $0x25,%eax
  8011dd:	74 0c                	je     8011eb <vprintfmt+0x36>
			if (ch == '\0')
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	75 e6                	jne    8011c9 <vprintfmt+0x14>
}
  8011e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e6:	5b                   	pop    %ebx
  8011e7:	5e                   	pop    %esi
  8011e8:	5f                   	pop    %edi
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    
		padc = ' ';
  8011eb:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8011ef:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8011f6:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8011fd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  801204:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801209:	8d 47 01             	lea    0x1(%edi),%eax
  80120c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80120f:	0f b6 17             	movzbl (%edi),%edx
  801212:	8d 42 dd             	lea    -0x23(%edx),%eax
  801215:	3c 55                	cmp    $0x55,%al
  801217:	0f 87 bb 03 00 00    	ja     8015d8 <vprintfmt+0x423>
  80121d:	0f b6 c0             	movzbl %al,%eax
  801220:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  801227:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80122a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80122e:	eb d9                	jmp    801209 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801230:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801233:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801237:	eb d0                	jmp    801209 <vprintfmt+0x54>
  801239:	0f b6 d2             	movzbl %dl,%edx
  80123c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80123f:	b8 00 00 00 00       	mov    $0x0,%eax
  801244:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801247:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80124a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80124e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801251:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801254:	83 f9 09             	cmp    $0x9,%ecx
  801257:	77 55                	ja     8012ae <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  801259:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80125c:	eb e9                	jmp    801247 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80125e:	8b 45 14             	mov    0x14(%ebp),%eax
  801261:	8b 00                	mov    (%eax),%eax
  801263:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801266:	8b 45 14             	mov    0x14(%ebp),%eax
  801269:	8d 40 04             	lea    0x4(%eax),%eax
  80126c:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80126f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801272:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801276:	79 91                	jns    801209 <vprintfmt+0x54>
				width = precision, precision = -1;
  801278:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80127b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80127e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801285:	eb 82                	jmp    801209 <vprintfmt+0x54>
  801287:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80128a:	85 d2                	test   %edx,%edx
  80128c:	b8 00 00 00 00       	mov    $0x0,%eax
  801291:	0f 49 c2             	cmovns %edx,%eax
  801294:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801297:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80129a:	e9 6a ff ff ff       	jmp    801209 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80129f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8012a2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8012a9:	e9 5b ff ff ff       	jmp    801209 <vprintfmt+0x54>
  8012ae:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8012b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8012b4:	eb bc                	jmp    801272 <vprintfmt+0xbd>
			lflag++;
  8012b6:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012b9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8012bc:	e9 48 ff ff ff       	jmp    801209 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8012c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8012c4:	8d 78 04             	lea    0x4(%eax),%edi
  8012c7:	83 ec 08             	sub    $0x8,%esp
  8012ca:	53                   	push   %ebx
  8012cb:	ff 30                	push   (%eax)
  8012cd:	ff d6                	call   *%esi
			break;
  8012cf:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8012d2:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8012d5:	e9 9d 02 00 00       	jmp    801577 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8012da:	8b 45 14             	mov    0x14(%ebp),%eax
  8012dd:	8d 78 04             	lea    0x4(%eax),%edi
  8012e0:	8b 10                	mov    (%eax),%edx
  8012e2:	89 d0                	mov    %edx,%eax
  8012e4:	f7 d8                	neg    %eax
  8012e6:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8012e9:	83 f8 0f             	cmp    $0xf,%eax
  8012ec:	7f 23                	jg     801311 <vprintfmt+0x15c>
  8012ee:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  8012f5:	85 d2                	test   %edx,%edx
  8012f7:	74 18                	je     801311 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8012f9:	52                   	push   %edx
  8012fa:	68 3d 1e 80 00       	push   $0x801e3d
  8012ff:	53                   	push   %ebx
  801300:	56                   	push   %esi
  801301:	e8 92 fe ff ff       	call   801198 <printfmt>
  801306:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801309:	89 7d 14             	mov    %edi,0x14(%ebp)
  80130c:	e9 66 02 00 00       	jmp    801577 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  801311:	50                   	push   %eax
  801312:	68 bf 1e 80 00       	push   $0x801ebf
  801317:	53                   	push   %ebx
  801318:	56                   	push   %esi
  801319:	e8 7a fe ff ff       	call   801198 <printfmt>
  80131e:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801321:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  801324:	e9 4e 02 00 00       	jmp    801577 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  801329:	8b 45 14             	mov    0x14(%ebp),%eax
  80132c:	83 c0 04             	add    $0x4,%eax
  80132f:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801332:	8b 45 14             	mov    0x14(%ebp),%eax
  801335:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801337:	85 d2                	test   %edx,%edx
  801339:	b8 b8 1e 80 00       	mov    $0x801eb8,%eax
  80133e:	0f 45 c2             	cmovne %edx,%eax
  801341:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801344:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801348:	7e 06                	jle    801350 <vprintfmt+0x19b>
  80134a:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80134e:	75 0d                	jne    80135d <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801350:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801353:	89 c7                	mov    %eax,%edi
  801355:	03 45 e0             	add    -0x20(%ebp),%eax
  801358:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80135b:	eb 55                	jmp    8013b2 <vprintfmt+0x1fd>
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	ff 75 d8             	push   -0x28(%ebp)
  801363:	ff 75 cc             	push   -0x34(%ebp)
  801366:	e8 0a 03 00 00       	call   801675 <strnlen>
  80136b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80136e:	29 c1                	sub    %eax,%ecx
  801370:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801373:	83 c4 10             	add    $0x10,%esp
  801376:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  801378:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80137c:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80137f:	eb 0f                	jmp    801390 <vprintfmt+0x1db>
					putch(padc, putdat);
  801381:	83 ec 08             	sub    $0x8,%esp
  801384:	53                   	push   %ebx
  801385:	ff 75 e0             	push   -0x20(%ebp)
  801388:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80138a:	83 ef 01             	sub    $0x1,%edi
  80138d:	83 c4 10             	add    $0x10,%esp
  801390:	85 ff                	test   %edi,%edi
  801392:	7f ed                	jg     801381 <vprintfmt+0x1cc>
  801394:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801397:	85 d2                	test   %edx,%edx
  801399:	b8 00 00 00 00       	mov    $0x0,%eax
  80139e:	0f 49 c2             	cmovns %edx,%eax
  8013a1:	29 c2                	sub    %eax,%edx
  8013a3:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8013a6:	eb a8                	jmp    801350 <vprintfmt+0x19b>
					putch(ch, putdat);
  8013a8:	83 ec 08             	sub    $0x8,%esp
  8013ab:	53                   	push   %ebx
  8013ac:	52                   	push   %edx
  8013ad:	ff d6                	call   *%esi
  8013af:	83 c4 10             	add    $0x10,%esp
  8013b2:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013b5:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8013b7:	83 c7 01             	add    $0x1,%edi
  8013ba:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8013be:	0f be d0             	movsbl %al,%edx
  8013c1:	85 d2                	test   %edx,%edx
  8013c3:	74 4b                	je     801410 <vprintfmt+0x25b>
  8013c5:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8013c9:	78 06                	js     8013d1 <vprintfmt+0x21c>
  8013cb:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8013cf:	78 1e                	js     8013ef <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8013d1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8013d5:	74 d1                	je     8013a8 <vprintfmt+0x1f3>
  8013d7:	0f be c0             	movsbl %al,%eax
  8013da:	83 e8 20             	sub    $0x20,%eax
  8013dd:	83 f8 5e             	cmp    $0x5e,%eax
  8013e0:	76 c6                	jbe    8013a8 <vprintfmt+0x1f3>
					putch('?', putdat);
  8013e2:	83 ec 08             	sub    $0x8,%esp
  8013e5:	53                   	push   %ebx
  8013e6:	6a 3f                	push   $0x3f
  8013e8:	ff d6                	call   *%esi
  8013ea:	83 c4 10             	add    $0x10,%esp
  8013ed:	eb c3                	jmp    8013b2 <vprintfmt+0x1fd>
  8013ef:	89 cf                	mov    %ecx,%edi
  8013f1:	eb 0e                	jmp    801401 <vprintfmt+0x24c>
				putch(' ', putdat);
  8013f3:	83 ec 08             	sub    $0x8,%esp
  8013f6:	53                   	push   %ebx
  8013f7:	6a 20                	push   $0x20
  8013f9:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8013fb:	83 ef 01             	sub    $0x1,%edi
  8013fe:	83 c4 10             	add    $0x10,%esp
  801401:	85 ff                	test   %edi,%edi
  801403:	7f ee                	jg     8013f3 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  801405:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801408:	89 45 14             	mov    %eax,0x14(%ebp)
  80140b:	e9 67 01 00 00       	jmp    801577 <vprintfmt+0x3c2>
  801410:	89 cf                	mov    %ecx,%edi
  801412:	eb ed                	jmp    801401 <vprintfmt+0x24c>
	if (lflag >= 2)
  801414:	83 f9 01             	cmp    $0x1,%ecx
  801417:	7f 1b                	jg     801434 <vprintfmt+0x27f>
	else if (lflag)
  801419:	85 c9                	test   %ecx,%ecx
  80141b:	74 63                	je     801480 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  80141d:	8b 45 14             	mov    0x14(%ebp),%eax
  801420:	8b 00                	mov    (%eax),%eax
  801422:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801425:	99                   	cltd   
  801426:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801429:	8b 45 14             	mov    0x14(%ebp),%eax
  80142c:	8d 40 04             	lea    0x4(%eax),%eax
  80142f:	89 45 14             	mov    %eax,0x14(%ebp)
  801432:	eb 17                	jmp    80144b <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801434:	8b 45 14             	mov    0x14(%ebp),%eax
  801437:	8b 50 04             	mov    0x4(%eax),%edx
  80143a:	8b 00                	mov    (%eax),%eax
  80143c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80143f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801442:	8b 45 14             	mov    0x14(%ebp),%eax
  801445:	8d 40 08             	lea    0x8(%eax),%eax
  801448:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80144b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80144e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801451:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801456:	85 c9                	test   %ecx,%ecx
  801458:	0f 89 ff 00 00 00    	jns    80155d <vprintfmt+0x3a8>
				putch('-', putdat);
  80145e:	83 ec 08             	sub    $0x8,%esp
  801461:	53                   	push   %ebx
  801462:	6a 2d                	push   $0x2d
  801464:	ff d6                	call   *%esi
				num = -(long long) num;
  801466:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801469:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80146c:	f7 da                	neg    %edx
  80146e:	83 d1 00             	adc    $0x0,%ecx
  801471:	f7 d9                	neg    %ecx
  801473:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801476:	bf 0a 00 00 00       	mov    $0xa,%edi
  80147b:	e9 dd 00 00 00       	jmp    80155d <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801480:	8b 45 14             	mov    0x14(%ebp),%eax
  801483:	8b 00                	mov    (%eax),%eax
  801485:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801488:	99                   	cltd   
  801489:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80148c:	8b 45 14             	mov    0x14(%ebp),%eax
  80148f:	8d 40 04             	lea    0x4(%eax),%eax
  801492:	89 45 14             	mov    %eax,0x14(%ebp)
  801495:	eb b4                	jmp    80144b <vprintfmt+0x296>
	if (lflag >= 2)
  801497:	83 f9 01             	cmp    $0x1,%ecx
  80149a:	7f 1e                	jg     8014ba <vprintfmt+0x305>
	else if (lflag)
  80149c:	85 c9                	test   %ecx,%ecx
  80149e:	74 32                	je     8014d2 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8014a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014a3:	8b 10                	mov    (%eax),%edx
  8014a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014aa:	8d 40 04             	lea    0x4(%eax),%eax
  8014ad:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014b0:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8014b5:	e9 a3 00 00 00       	jmp    80155d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8014ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8014bd:	8b 10                	mov    (%eax),%edx
  8014bf:	8b 48 04             	mov    0x4(%eax),%ecx
  8014c2:	8d 40 08             	lea    0x8(%eax),%eax
  8014c5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014c8:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8014cd:	e9 8b 00 00 00       	jmp    80155d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8014d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d5:	8b 10                	mov    (%eax),%edx
  8014d7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014dc:	8d 40 04             	lea    0x4(%eax),%eax
  8014df:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8014e2:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8014e7:	eb 74                	jmp    80155d <vprintfmt+0x3a8>
	if (lflag >= 2)
  8014e9:	83 f9 01             	cmp    $0x1,%ecx
  8014ec:	7f 1b                	jg     801509 <vprintfmt+0x354>
	else if (lflag)
  8014ee:	85 c9                	test   %ecx,%ecx
  8014f0:	74 2c                	je     80151e <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8014f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f5:	8b 10                	mov    (%eax),%edx
  8014f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014fc:	8d 40 04             	lea    0x4(%eax),%eax
  8014ff:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801502:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  801507:	eb 54                	jmp    80155d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801509:	8b 45 14             	mov    0x14(%ebp),%eax
  80150c:	8b 10                	mov    (%eax),%edx
  80150e:	8b 48 04             	mov    0x4(%eax),%ecx
  801511:	8d 40 08             	lea    0x8(%eax),%eax
  801514:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801517:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  80151c:	eb 3f                	jmp    80155d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  80151e:	8b 45 14             	mov    0x14(%ebp),%eax
  801521:	8b 10                	mov    (%eax),%edx
  801523:	b9 00 00 00 00       	mov    $0x0,%ecx
  801528:	8d 40 04             	lea    0x4(%eax),%eax
  80152b:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  80152e:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801533:	eb 28                	jmp    80155d <vprintfmt+0x3a8>
			putch('0', putdat);
  801535:	83 ec 08             	sub    $0x8,%esp
  801538:	53                   	push   %ebx
  801539:	6a 30                	push   $0x30
  80153b:	ff d6                	call   *%esi
			putch('x', putdat);
  80153d:	83 c4 08             	add    $0x8,%esp
  801540:	53                   	push   %ebx
  801541:	6a 78                	push   $0x78
  801543:	ff d6                	call   *%esi
			num = (unsigned long long)
  801545:	8b 45 14             	mov    0x14(%ebp),%eax
  801548:	8b 10                	mov    (%eax),%edx
  80154a:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80154f:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801552:	8d 40 04             	lea    0x4(%eax),%eax
  801555:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801558:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  80155d:	83 ec 0c             	sub    $0xc,%esp
  801560:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801564:	50                   	push   %eax
  801565:	ff 75 e0             	push   -0x20(%ebp)
  801568:	57                   	push   %edi
  801569:	51                   	push   %ecx
  80156a:	52                   	push   %edx
  80156b:	89 da                	mov    %ebx,%edx
  80156d:	89 f0                	mov    %esi,%eax
  80156f:	e8 5e fb ff ff       	call   8010d2 <printnum>
			break;
  801574:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801577:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80157a:	e9 54 fc ff ff       	jmp    8011d3 <vprintfmt+0x1e>
	if (lflag >= 2)
  80157f:	83 f9 01             	cmp    $0x1,%ecx
  801582:	7f 1b                	jg     80159f <vprintfmt+0x3ea>
	else if (lflag)
  801584:	85 c9                	test   %ecx,%ecx
  801586:	74 2c                	je     8015b4 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801588:	8b 45 14             	mov    0x14(%ebp),%eax
  80158b:	8b 10                	mov    (%eax),%edx
  80158d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801592:	8d 40 04             	lea    0x4(%eax),%eax
  801595:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801598:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  80159d:	eb be                	jmp    80155d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80159f:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a2:	8b 10                	mov    (%eax),%edx
  8015a4:	8b 48 04             	mov    0x4(%eax),%ecx
  8015a7:	8d 40 08             	lea    0x8(%eax),%eax
  8015aa:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015ad:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  8015b2:	eb a9                	jmp    80155d <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8015b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b7:	8b 10                	mov    (%eax),%edx
  8015b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015be:	8d 40 04             	lea    0x4(%eax),%eax
  8015c1:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8015c4:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  8015c9:	eb 92                	jmp    80155d <vprintfmt+0x3a8>
			putch(ch, putdat);
  8015cb:	83 ec 08             	sub    $0x8,%esp
  8015ce:	53                   	push   %ebx
  8015cf:	6a 25                	push   $0x25
  8015d1:	ff d6                	call   *%esi
			break;
  8015d3:	83 c4 10             	add    $0x10,%esp
  8015d6:	eb 9f                	jmp    801577 <vprintfmt+0x3c2>
			putch('%', putdat);
  8015d8:	83 ec 08             	sub    $0x8,%esp
  8015db:	53                   	push   %ebx
  8015dc:	6a 25                	push   $0x25
  8015de:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015e0:	83 c4 10             	add    $0x10,%esp
  8015e3:	89 f8                	mov    %edi,%eax
  8015e5:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8015e9:	74 05                	je     8015f0 <vprintfmt+0x43b>
  8015eb:	83 e8 01             	sub    $0x1,%eax
  8015ee:	eb f5                	jmp    8015e5 <vprintfmt+0x430>
  8015f0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015f3:	eb 82                	jmp    801577 <vprintfmt+0x3c2>

008015f5 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	83 ec 18             	sub    $0x18,%esp
  8015fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801601:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801604:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801608:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80160b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801612:	85 c0                	test   %eax,%eax
  801614:	74 26                	je     80163c <vsnprintf+0x47>
  801616:	85 d2                	test   %edx,%edx
  801618:	7e 22                	jle    80163c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80161a:	ff 75 14             	push   0x14(%ebp)
  80161d:	ff 75 10             	push   0x10(%ebp)
  801620:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801623:	50                   	push   %eax
  801624:	68 7b 11 80 00       	push   $0x80117b
  801629:	e8 87 fb ff ff       	call   8011b5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80162e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801631:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801634:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801637:	83 c4 10             	add    $0x10,%esp
}
  80163a:	c9                   	leave  
  80163b:	c3                   	ret    
		return -E_INVAL;
  80163c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801641:	eb f7                	jmp    80163a <vsnprintf+0x45>

00801643 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801643:	55                   	push   %ebp
  801644:	89 e5                	mov    %esp,%ebp
  801646:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801649:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80164c:	50                   	push   %eax
  80164d:	ff 75 10             	push   0x10(%ebp)
  801650:	ff 75 0c             	push   0xc(%ebp)
  801653:	ff 75 08             	push   0x8(%ebp)
  801656:	e8 9a ff ff ff       	call   8015f5 <vsnprintf>
	va_end(ap);

	return rc;
}
  80165b:	c9                   	leave  
  80165c:	c3                   	ret    

0080165d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80165d:	55                   	push   %ebp
  80165e:	89 e5                	mov    %esp,%ebp
  801660:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801663:	b8 00 00 00 00       	mov    $0x0,%eax
  801668:	eb 03                	jmp    80166d <strlen+0x10>
		n++;
  80166a:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  80166d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801671:	75 f7                	jne    80166a <strlen+0xd>
	return n;
}
  801673:	5d                   	pop    %ebp
  801674:	c3                   	ret    

00801675 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80167b:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80167e:	b8 00 00 00 00       	mov    $0x0,%eax
  801683:	eb 03                	jmp    801688 <strnlen+0x13>
		n++;
  801685:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801688:	39 d0                	cmp    %edx,%eax
  80168a:	74 08                	je     801694 <strnlen+0x1f>
  80168c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801690:	75 f3                	jne    801685 <strnlen+0x10>
  801692:	89 c2                	mov    %eax,%edx
	return n;
}
  801694:	89 d0                	mov    %edx,%eax
  801696:	5d                   	pop    %ebp
  801697:	c3                   	ret    

00801698 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	53                   	push   %ebx
  80169c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80169f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a7:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016ab:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016ae:	83 c0 01             	add    $0x1,%eax
  8016b1:	84 d2                	test   %dl,%dl
  8016b3:	75 f2                	jne    8016a7 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8016b5:	89 c8                	mov    %ecx,%eax
  8016b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ba:	c9                   	leave  
  8016bb:	c3                   	ret    

008016bc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016bc:	55                   	push   %ebp
  8016bd:	89 e5                	mov    %esp,%ebp
  8016bf:	53                   	push   %ebx
  8016c0:	83 ec 10             	sub    $0x10,%esp
  8016c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016c6:	53                   	push   %ebx
  8016c7:	e8 91 ff ff ff       	call   80165d <strlen>
  8016cc:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8016cf:	ff 75 0c             	push   0xc(%ebp)
  8016d2:	01 d8                	add    %ebx,%eax
  8016d4:	50                   	push   %eax
  8016d5:	e8 be ff ff ff       	call   801698 <strcpy>
	return dst;
}
  8016da:	89 d8                	mov    %ebx,%eax
  8016dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016df:	c9                   	leave  
  8016e0:	c3                   	ret    

008016e1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	56                   	push   %esi
  8016e5:	53                   	push   %ebx
  8016e6:	8b 75 08             	mov    0x8(%ebp),%esi
  8016e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ec:	89 f3                	mov    %esi,%ebx
  8016ee:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016f1:	89 f0                	mov    %esi,%eax
  8016f3:	eb 0f                	jmp    801704 <strncpy+0x23>
		*dst++ = *src;
  8016f5:	83 c0 01             	add    $0x1,%eax
  8016f8:	0f b6 0a             	movzbl (%edx),%ecx
  8016fb:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8016fe:	80 f9 01             	cmp    $0x1,%cl
  801701:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801704:	39 d8                	cmp    %ebx,%eax
  801706:	75 ed                	jne    8016f5 <strncpy+0x14>
	}
	return ret;
}
  801708:	89 f0                	mov    %esi,%eax
  80170a:	5b                   	pop    %ebx
  80170b:	5e                   	pop    %esi
  80170c:	5d                   	pop    %ebp
  80170d:	c3                   	ret    

0080170e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	56                   	push   %esi
  801712:	53                   	push   %ebx
  801713:	8b 75 08             	mov    0x8(%ebp),%esi
  801716:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801719:	8b 55 10             	mov    0x10(%ebp),%edx
  80171c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80171e:	85 d2                	test   %edx,%edx
  801720:	74 21                	je     801743 <strlcpy+0x35>
  801722:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801726:	89 f2                	mov    %esi,%edx
  801728:	eb 09                	jmp    801733 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80172a:	83 c1 01             	add    $0x1,%ecx
  80172d:	83 c2 01             	add    $0x1,%edx
  801730:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801733:	39 c2                	cmp    %eax,%edx
  801735:	74 09                	je     801740 <strlcpy+0x32>
  801737:	0f b6 19             	movzbl (%ecx),%ebx
  80173a:	84 db                	test   %bl,%bl
  80173c:	75 ec                	jne    80172a <strlcpy+0x1c>
  80173e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801740:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801743:	29 f0                	sub    %esi,%eax
}
  801745:	5b                   	pop    %ebx
  801746:	5e                   	pop    %esi
  801747:	5d                   	pop    %ebp
  801748:	c3                   	ret    

00801749 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80174f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801752:	eb 06                	jmp    80175a <strcmp+0x11>
		p++, q++;
  801754:	83 c1 01             	add    $0x1,%ecx
  801757:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  80175a:	0f b6 01             	movzbl (%ecx),%eax
  80175d:	84 c0                	test   %al,%al
  80175f:	74 04                	je     801765 <strcmp+0x1c>
  801761:	3a 02                	cmp    (%edx),%al
  801763:	74 ef                	je     801754 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801765:	0f b6 c0             	movzbl %al,%eax
  801768:	0f b6 12             	movzbl (%edx),%edx
  80176b:	29 d0                	sub    %edx,%eax
}
  80176d:	5d                   	pop    %ebp
  80176e:	c3                   	ret    

0080176f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80176f:	55                   	push   %ebp
  801770:	89 e5                	mov    %esp,%ebp
  801772:	53                   	push   %ebx
  801773:	8b 45 08             	mov    0x8(%ebp),%eax
  801776:	8b 55 0c             	mov    0xc(%ebp),%edx
  801779:	89 c3                	mov    %eax,%ebx
  80177b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80177e:	eb 06                	jmp    801786 <strncmp+0x17>
		n--, p++, q++;
  801780:	83 c0 01             	add    $0x1,%eax
  801783:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801786:	39 d8                	cmp    %ebx,%eax
  801788:	74 18                	je     8017a2 <strncmp+0x33>
  80178a:	0f b6 08             	movzbl (%eax),%ecx
  80178d:	84 c9                	test   %cl,%cl
  80178f:	74 04                	je     801795 <strncmp+0x26>
  801791:	3a 0a                	cmp    (%edx),%cl
  801793:	74 eb                	je     801780 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801795:	0f b6 00             	movzbl (%eax),%eax
  801798:	0f b6 12             	movzbl (%edx),%edx
  80179b:	29 d0                	sub    %edx,%eax
}
  80179d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a0:	c9                   	leave  
  8017a1:	c3                   	ret    
		return 0;
  8017a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a7:	eb f4                	jmp    80179d <strncmp+0x2e>

008017a9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8017af:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017b3:	eb 03                	jmp    8017b8 <strchr+0xf>
  8017b5:	83 c0 01             	add    $0x1,%eax
  8017b8:	0f b6 10             	movzbl (%eax),%edx
  8017bb:	84 d2                	test   %dl,%dl
  8017bd:	74 06                	je     8017c5 <strchr+0x1c>
		if (*s == c)
  8017bf:	38 ca                	cmp    %cl,%dl
  8017c1:	75 f2                	jne    8017b5 <strchr+0xc>
  8017c3:	eb 05                	jmp    8017ca <strchr+0x21>
			return (char *) s;
	return 0;
  8017c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ca:	5d                   	pop    %ebp
  8017cb:	c3                   	ret    

008017cc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017cc:	55                   	push   %ebp
  8017cd:	89 e5                	mov    %esp,%ebp
  8017cf:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017d6:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017d9:	38 ca                	cmp    %cl,%dl
  8017db:	74 09                	je     8017e6 <strfind+0x1a>
  8017dd:	84 d2                	test   %dl,%dl
  8017df:	74 05                	je     8017e6 <strfind+0x1a>
	for (; *s; s++)
  8017e1:	83 c0 01             	add    $0x1,%eax
  8017e4:	eb f0                	jmp    8017d6 <strfind+0xa>
			break;
	return (char *) s;
}
  8017e6:	5d                   	pop    %ebp
  8017e7:	c3                   	ret    

008017e8 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	57                   	push   %edi
  8017ec:	56                   	push   %esi
  8017ed:	53                   	push   %ebx
  8017ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8017f4:	85 c9                	test   %ecx,%ecx
  8017f6:	74 2f                	je     801827 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8017f8:	89 f8                	mov    %edi,%eax
  8017fa:	09 c8                	or     %ecx,%eax
  8017fc:	a8 03                	test   $0x3,%al
  8017fe:	75 21                	jne    801821 <memset+0x39>
		c &= 0xFF;
  801800:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801804:	89 d0                	mov    %edx,%eax
  801806:	c1 e0 08             	shl    $0x8,%eax
  801809:	89 d3                	mov    %edx,%ebx
  80180b:	c1 e3 18             	shl    $0x18,%ebx
  80180e:	89 d6                	mov    %edx,%esi
  801810:	c1 e6 10             	shl    $0x10,%esi
  801813:	09 f3                	or     %esi,%ebx
  801815:	09 da                	or     %ebx,%edx
  801817:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801819:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  80181c:	fc                   	cld    
  80181d:	f3 ab                	rep stos %eax,%es:(%edi)
  80181f:	eb 06                	jmp    801827 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801821:	8b 45 0c             	mov    0xc(%ebp),%eax
  801824:	fc                   	cld    
  801825:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801827:	89 f8                	mov    %edi,%eax
  801829:	5b                   	pop    %ebx
  80182a:	5e                   	pop    %esi
  80182b:	5f                   	pop    %edi
  80182c:	5d                   	pop    %ebp
  80182d:	c3                   	ret    

0080182e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	57                   	push   %edi
  801832:	56                   	push   %esi
  801833:	8b 45 08             	mov    0x8(%ebp),%eax
  801836:	8b 75 0c             	mov    0xc(%ebp),%esi
  801839:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80183c:	39 c6                	cmp    %eax,%esi
  80183e:	73 32                	jae    801872 <memmove+0x44>
  801840:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801843:	39 c2                	cmp    %eax,%edx
  801845:	76 2b                	jbe    801872 <memmove+0x44>
		s += n;
		d += n;
  801847:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80184a:	89 d6                	mov    %edx,%esi
  80184c:	09 fe                	or     %edi,%esi
  80184e:	09 ce                	or     %ecx,%esi
  801850:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801856:	75 0e                	jne    801866 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801858:	83 ef 04             	sub    $0x4,%edi
  80185b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80185e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801861:	fd                   	std    
  801862:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801864:	eb 09                	jmp    80186f <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801866:	83 ef 01             	sub    $0x1,%edi
  801869:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80186c:	fd                   	std    
  80186d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80186f:	fc                   	cld    
  801870:	eb 1a                	jmp    80188c <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801872:	89 f2                	mov    %esi,%edx
  801874:	09 c2                	or     %eax,%edx
  801876:	09 ca                	or     %ecx,%edx
  801878:	f6 c2 03             	test   $0x3,%dl
  80187b:	75 0a                	jne    801887 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80187d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801880:	89 c7                	mov    %eax,%edi
  801882:	fc                   	cld    
  801883:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801885:	eb 05                	jmp    80188c <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801887:	89 c7                	mov    %eax,%edi
  801889:	fc                   	cld    
  80188a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80188c:	5e                   	pop    %esi
  80188d:	5f                   	pop    %edi
  80188e:	5d                   	pop    %ebp
  80188f:	c3                   	ret    

00801890 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801896:	ff 75 10             	push   0x10(%ebp)
  801899:	ff 75 0c             	push   0xc(%ebp)
  80189c:	ff 75 08             	push   0x8(%ebp)
  80189f:	e8 8a ff ff ff       	call   80182e <memmove>
}
  8018a4:	c9                   	leave  
  8018a5:	c3                   	ret    

008018a6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	56                   	push   %esi
  8018aa:	53                   	push   %ebx
  8018ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018b1:	89 c6                	mov    %eax,%esi
  8018b3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018b6:	eb 06                	jmp    8018be <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8018b8:	83 c0 01             	add    $0x1,%eax
  8018bb:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  8018be:	39 f0                	cmp    %esi,%eax
  8018c0:	74 14                	je     8018d6 <memcmp+0x30>
		if (*s1 != *s2)
  8018c2:	0f b6 08             	movzbl (%eax),%ecx
  8018c5:	0f b6 1a             	movzbl (%edx),%ebx
  8018c8:	38 d9                	cmp    %bl,%cl
  8018ca:	74 ec                	je     8018b8 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  8018cc:	0f b6 c1             	movzbl %cl,%eax
  8018cf:	0f b6 db             	movzbl %bl,%ebx
  8018d2:	29 d8                	sub    %ebx,%eax
  8018d4:	eb 05                	jmp    8018db <memcmp+0x35>
	}

	return 0;
  8018d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018db:	5b                   	pop    %ebx
  8018dc:	5e                   	pop    %esi
  8018dd:	5d                   	pop    %ebp
  8018de:	c3                   	ret    

008018df <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8018e8:	89 c2                	mov    %eax,%edx
  8018ea:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8018ed:	eb 03                	jmp    8018f2 <memfind+0x13>
  8018ef:	83 c0 01             	add    $0x1,%eax
  8018f2:	39 d0                	cmp    %edx,%eax
  8018f4:	73 04                	jae    8018fa <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  8018f6:	38 08                	cmp    %cl,(%eax)
  8018f8:	75 f5                	jne    8018ef <memfind+0x10>
			break;
	return (void *) s;
}
  8018fa:	5d                   	pop    %ebp
  8018fb:	c3                   	ret    

008018fc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	57                   	push   %edi
  801900:	56                   	push   %esi
  801901:	53                   	push   %ebx
  801902:	8b 55 08             	mov    0x8(%ebp),%edx
  801905:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801908:	eb 03                	jmp    80190d <strtol+0x11>
		s++;
  80190a:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  80190d:	0f b6 02             	movzbl (%edx),%eax
  801910:	3c 20                	cmp    $0x20,%al
  801912:	74 f6                	je     80190a <strtol+0xe>
  801914:	3c 09                	cmp    $0x9,%al
  801916:	74 f2                	je     80190a <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801918:	3c 2b                	cmp    $0x2b,%al
  80191a:	74 2a                	je     801946 <strtol+0x4a>
	int neg = 0;
  80191c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801921:	3c 2d                	cmp    $0x2d,%al
  801923:	74 2b                	je     801950 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801925:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80192b:	75 0f                	jne    80193c <strtol+0x40>
  80192d:	80 3a 30             	cmpb   $0x30,(%edx)
  801930:	74 28                	je     80195a <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801932:	85 db                	test   %ebx,%ebx
  801934:	b8 0a 00 00 00       	mov    $0xa,%eax
  801939:	0f 44 d8             	cmove  %eax,%ebx
  80193c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801941:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801944:	eb 46                	jmp    80198c <strtol+0x90>
		s++;
  801946:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801949:	bf 00 00 00 00       	mov    $0x0,%edi
  80194e:	eb d5                	jmp    801925 <strtol+0x29>
		s++, neg = 1;
  801950:	83 c2 01             	add    $0x1,%edx
  801953:	bf 01 00 00 00       	mov    $0x1,%edi
  801958:	eb cb                	jmp    801925 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80195a:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80195e:	74 0e                	je     80196e <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801960:	85 db                	test   %ebx,%ebx
  801962:	75 d8                	jne    80193c <strtol+0x40>
		s++, base = 8;
  801964:	83 c2 01             	add    $0x1,%edx
  801967:	bb 08 00 00 00       	mov    $0x8,%ebx
  80196c:	eb ce                	jmp    80193c <strtol+0x40>
		s += 2, base = 16;
  80196e:	83 c2 02             	add    $0x2,%edx
  801971:	bb 10 00 00 00       	mov    $0x10,%ebx
  801976:	eb c4                	jmp    80193c <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801978:	0f be c0             	movsbl %al,%eax
  80197b:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  80197e:	3b 45 10             	cmp    0x10(%ebp),%eax
  801981:	7d 3a                	jge    8019bd <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801983:	83 c2 01             	add    $0x1,%edx
  801986:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  80198a:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  80198c:	0f b6 02             	movzbl (%edx),%eax
  80198f:	8d 70 d0             	lea    -0x30(%eax),%esi
  801992:	89 f3                	mov    %esi,%ebx
  801994:	80 fb 09             	cmp    $0x9,%bl
  801997:	76 df                	jbe    801978 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  801999:	8d 70 9f             	lea    -0x61(%eax),%esi
  80199c:	89 f3                	mov    %esi,%ebx
  80199e:	80 fb 19             	cmp    $0x19,%bl
  8019a1:	77 08                	ja     8019ab <strtol+0xaf>
			dig = *s - 'a' + 10;
  8019a3:	0f be c0             	movsbl %al,%eax
  8019a6:	83 e8 57             	sub    $0x57,%eax
  8019a9:	eb d3                	jmp    80197e <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  8019ab:	8d 70 bf             	lea    -0x41(%eax),%esi
  8019ae:	89 f3                	mov    %esi,%ebx
  8019b0:	80 fb 19             	cmp    $0x19,%bl
  8019b3:	77 08                	ja     8019bd <strtol+0xc1>
			dig = *s - 'A' + 10;
  8019b5:	0f be c0             	movsbl %al,%eax
  8019b8:	83 e8 37             	sub    $0x37,%eax
  8019bb:	eb c1                	jmp    80197e <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  8019bd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019c1:	74 05                	je     8019c8 <strtol+0xcc>
		*endptr = (char *) s;
  8019c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c6:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8019c8:	89 c8                	mov    %ecx,%eax
  8019ca:	f7 d8                	neg    %eax
  8019cc:	85 ff                	test   %edi,%edi
  8019ce:	0f 45 c8             	cmovne %eax,%ecx
}
  8019d1:	89 c8                	mov    %ecx,%eax
  8019d3:	5b                   	pop    %ebx
  8019d4:	5e                   	pop    %esi
  8019d5:	5f                   	pop    %edi
  8019d6:	5d                   	pop    %ebp
  8019d7:	c3                   	ret    

008019d8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019d8:	55                   	push   %ebp
  8019d9:	89 e5                	mov    %esp,%ebp
  8019db:	56                   	push   %esi
  8019dc:	53                   	push   %ebx
  8019dd:	8b 75 08             	mov    0x8(%ebp),%esi
  8019e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  8019e6:	85 c0                	test   %eax,%eax
  8019e8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8019ed:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  8019f0:	83 ec 0c             	sub    $0xc,%esp
  8019f3:	50                   	push   %eax
  8019f4:	e8 08 e9 ff ff       	call   800301 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//我猜是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  8019f9:	83 c4 10             	add    $0x10,%esp
  8019fc:	85 f6                	test   %esi,%esi
  8019fe:	74 14                	je     801a14 <ipc_recv+0x3c>
  801a00:	ba 00 00 00 00       	mov    $0x0,%edx
  801a05:	85 c0                	test   %eax,%eax
  801a07:	78 09                	js     801a12 <ipc_recv+0x3a>
  801a09:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a0f:	8b 52 74             	mov    0x74(%edx),%edx
  801a12:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801a14:	85 db                	test   %ebx,%ebx
  801a16:	74 14                	je     801a2c <ipc_recv+0x54>
  801a18:	ba 00 00 00 00       	mov    $0x0,%edx
  801a1d:	85 c0                	test   %eax,%eax
  801a1f:	78 09                	js     801a2a <ipc_recv+0x52>
  801a21:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801a27:	8b 52 78             	mov    0x78(%edx),%edx
  801a2a:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801a2c:	85 c0                	test   %eax,%eax
  801a2e:	78 08                	js     801a38 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801a30:	a1 00 40 80 00       	mov    0x804000,%eax
  801a35:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a3b:	5b                   	pop    %ebx
  801a3c:	5e                   	pop    %esi
  801a3d:	5d                   	pop    %ebp
  801a3e:	c3                   	ret    

00801a3f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	57                   	push   %edi
  801a43:	56                   	push   %esi
  801a44:	53                   	push   %ebx
  801a45:	83 ec 0c             	sub    $0xc,%esp
  801a48:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a4b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a4e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801a51:	85 db                	test   %ebx,%ebx
  801a53:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a58:	0f 44 d8             	cmove  %eax,%ebx
  801a5b:	eb 05                	jmp    801a62 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a5d:	e8 d0 e6 ff ff       	call   800132 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801a62:	ff 75 14             	push   0x14(%ebp)
  801a65:	53                   	push   %ebx
  801a66:	56                   	push   %esi
  801a67:	57                   	push   %edi
  801a68:	e8 71 e8 ff ff       	call   8002de <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801a6d:	83 c4 10             	add    $0x10,%esp
  801a70:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a73:	74 e8                	je     801a5d <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801a75:	85 c0                	test   %eax,%eax
  801a77:	78 08                	js     801a81 <ipc_send+0x42>
	}while (r<0);

}
  801a79:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a7c:	5b                   	pop    %ebx
  801a7d:	5e                   	pop    %esi
  801a7e:	5f                   	pop    %edi
  801a7f:	5d                   	pop    %ebp
  801a80:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801a81:	50                   	push   %eax
  801a82:	68 9f 21 80 00       	push   $0x80219f
  801a87:	6a 3d                	push   $0x3d
  801a89:	68 b3 21 80 00       	push   $0x8021b3
  801a8e:	e8 50 f5 ff ff       	call   800fe3 <_panic>

00801a93 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801a99:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801a9e:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801aa1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801aa7:	8b 52 50             	mov    0x50(%edx),%edx
  801aaa:	39 ca                	cmp    %ecx,%edx
  801aac:	74 11                	je     801abf <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801aae:	83 c0 01             	add    $0x1,%eax
  801ab1:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ab6:	75 e6                	jne    801a9e <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801ab8:	b8 00 00 00 00       	mov    $0x0,%eax
  801abd:	eb 0b                	jmp    801aca <ipc_find_env+0x37>
			return envs[i].env_id;
  801abf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ac2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ac7:	8b 40 48             	mov    0x48(%eax),%eax
}
  801aca:	5d                   	pop    %ebp
  801acb:	c3                   	ret    

00801acc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801acc:	55                   	push   %ebp
  801acd:	89 e5                	mov    %esp,%ebp
  801acf:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ad2:	89 c2                	mov    %eax,%edx
  801ad4:	c1 ea 16             	shr    $0x16,%edx
  801ad7:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801ade:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801ae3:	f6 c1 01             	test   $0x1,%cl
  801ae6:	74 1c                	je     801b04 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801ae8:	c1 e8 0c             	shr    $0xc,%eax
  801aeb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801af2:	a8 01                	test   $0x1,%al
  801af4:	74 0e                	je     801b04 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801af6:	c1 e8 0c             	shr    $0xc,%eax
  801af9:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b00:	ef 
  801b01:	0f b7 d2             	movzwl %dx,%edx
}
  801b04:	89 d0                	mov    %edx,%eax
  801b06:	5d                   	pop    %ebp
  801b07:	c3                   	ret    
  801b08:	66 90                	xchg   %ax,%ax
  801b0a:	66 90                	xchg   %ax,%ax
  801b0c:	66 90                	xchg   %ax,%ax
  801b0e:	66 90                	xchg   %ax,%ax

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
