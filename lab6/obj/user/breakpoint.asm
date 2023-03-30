
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
  800081:	e8 ee 04 00 00       	call   800574 <close_all>
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
  800102:	68 2a 22 80 00       	push   $0x80222a
  800107:	6a 2a                	push   $0x2a
  800109:	68 47 22 80 00       	push   $0x802247
  80010e:	e8 9e 13 00 00       	call   8014b1 <_panic>

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
  800183:	68 2a 22 80 00       	push   $0x80222a
  800188:	6a 2a                	push   $0x2a
  80018a:	68 47 22 80 00       	push   $0x802247
  80018f:	e8 1d 13 00 00       	call   8014b1 <_panic>

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
  8001c5:	68 2a 22 80 00       	push   $0x80222a
  8001ca:	6a 2a                	push   $0x2a
  8001cc:	68 47 22 80 00       	push   $0x802247
  8001d1:	e8 db 12 00 00       	call   8014b1 <_panic>

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
  800207:	68 2a 22 80 00       	push   $0x80222a
  80020c:	6a 2a                	push   $0x2a
  80020e:	68 47 22 80 00       	push   $0x802247
  800213:	e8 99 12 00 00       	call   8014b1 <_panic>

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
  800249:	68 2a 22 80 00       	push   $0x80222a
  80024e:	6a 2a                	push   $0x2a
  800250:	68 47 22 80 00       	push   $0x802247
  800255:	e8 57 12 00 00       	call   8014b1 <_panic>

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
  80028b:	68 2a 22 80 00       	push   $0x80222a
  800290:	6a 2a                	push   $0x2a
  800292:	68 47 22 80 00       	push   $0x802247
  800297:	e8 15 12 00 00       	call   8014b1 <_panic>

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
  8002cd:	68 2a 22 80 00       	push   $0x80222a
  8002d2:	6a 2a                	push   $0x2a
  8002d4:	68 47 22 80 00       	push   $0x802247
  8002d9:	e8 d3 11 00 00       	call   8014b1 <_panic>

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
  800331:	68 2a 22 80 00       	push   $0x80222a
  800336:	6a 2a                	push   $0x2a
  800338:	68 47 22 80 00       	push   $0x802247
  80033d:	e8 6f 11 00 00       	call   8014b1 <_panic>

00800342 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800342:	55                   	push   %ebp
  800343:	89 e5                	mov    %esp,%ebp
  800345:	57                   	push   %edi
  800346:	56                   	push   %esi
  800347:	53                   	push   %ebx
	asm volatile("int %1\n"
  800348:	ba 00 00 00 00       	mov    $0x0,%edx
  80034d:	b8 0e 00 00 00       	mov    $0xe,%eax
  800352:	89 d1                	mov    %edx,%ecx
  800354:	89 d3                	mov    %edx,%ebx
  800356:	89 d7                	mov    %edx,%edi
  800358:	89 d6                	mov    %edx,%esi
  80035a:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80035c:	5b                   	pop    %ebx
  80035d:	5e                   	pop    %esi
  80035e:	5f                   	pop    %edi
  80035f:	5d                   	pop    %ebp
  800360:	c3                   	ret    

00800361 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800361:	55                   	push   %ebp
  800362:	89 e5                	mov    %esp,%ebp
  800364:	57                   	push   %edi
  800365:	56                   	push   %esi
  800366:	53                   	push   %ebx
	asm volatile("int %1\n"
  800367:	bb 00 00 00 00       	mov    $0x0,%ebx
  80036c:	8b 55 08             	mov    0x8(%ebp),%edx
  80036f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800372:	b8 0f 00 00 00       	mov    $0xf,%eax
  800377:	89 df                	mov    %ebx,%edi
  800379:	89 de                	mov    %ebx,%esi
  80037b:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  80037d:	5b                   	pop    %ebx
  80037e:	5e                   	pop    %esi
  80037f:	5f                   	pop    %edi
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	57                   	push   %edi
  800386:	56                   	push   %esi
  800387:	53                   	push   %ebx
	asm volatile("int %1\n"
  800388:	bb 00 00 00 00       	mov    $0x0,%ebx
  80038d:	8b 55 08             	mov    0x8(%ebp),%edx
  800390:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800393:	b8 10 00 00 00       	mov    $0x10,%eax
  800398:	89 df                	mov    %ebx,%edi
  80039a:	89 de                	mov    %ebx,%esi
  80039c:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  80039e:	5b                   	pop    %ebx
  80039f:	5e                   	pop    %esi
  8003a0:	5f                   	pop    %edi
  8003a1:	5d                   	pop    %ebp
  8003a2:	c3                   	ret    

008003a3 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a9:	05 00 00 00 30       	add    $0x30000000,%eax
  8003ae:	c1 e8 0c             	shr    $0xc,%eax
}
  8003b1:	5d                   	pop    %ebp
  8003b2:	c3                   	ret    

008003b3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b9:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003be:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003c3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003d2:	89 c2                	mov    %eax,%edx
  8003d4:	c1 ea 16             	shr    $0x16,%edx
  8003d7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003de:	f6 c2 01             	test   $0x1,%dl
  8003e1:	74 29                	je     80040c <fd_alloc+0x42>
  8003e3:	89 c2                	mov    %eax,%edx
  8003e5:	c1 ea 0c             	shr    $0xc,%edx
  8003e8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ef:	f6 c2 01             	test   $0x1,%dl
  8003f2:	74 18                	je     80040c <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8003f4:	05 00 10 00 00       	add    $0x1000,%eax
  8003f9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003fe:	75 d2                	jne    8003d2 <fd_alloc+0x8>
  800400:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800405:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80040a:	eb 05                	jmp    800411 <fd_alloc+0x47>
			return 0;
  80040c:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800411:	8b 55 08             	mov    0x8(%ebp),%edx
  800414:	89 02                	mov    %eax,(%edx)
}
  800416:	89 c8                	mov    %ecx,%eax
  800418:	5d                   	pop    %ebp
  800419:	c3                   	ret    

0080041a <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80041a:	55                   	push   %ebp
  80041b:	89 e5                	mov    %esp,%ebp
  80041d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800420:	83 f8 1f             	cmp    $0x1f,%eax
  800423:	77 30                	ja     800455 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800425:	c1 e0 0c             	shl    $0xc,%eax
  800428:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80042d:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800433:	f6 c2 01             	test   $0x1,%dl
  800436:	74 24                	je     80045c <fd_lookup+0x42>
  800438:	89 c2                	mov    %eax,%edx
  80043a:	c1 ea 0c             	shr    $0xc,%edx
  80043d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800444:	f6 c2 01             	test   $0x1,%dl
  800447:	74 1a                	je     800463 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800449:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044c:	89 02                	mov    %eax,(%edx)
	return 0;
  80044e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800453:	5d                   	pop    %ebp
  800454:	c3                   	ret    
		return -E_INVAL;
  800455:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80045a:	eb f7                	jmp    800453 <fd_lookup+0x39>
		return -E_INVAL;
  80045c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800461:	eb f0                	jmp    800453 <fd_lookup+0x39>
  800463:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800468:	eb e9                	jmp    800453 <fd_lookup+0x39>

0080046a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
  80046d:	53                   	push   %ebx
  80046e:	83 ec 04             	sub    $0x4,%esp
  800471:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800474:	b8 00 00 00 00       	mov    $0x0,%eax
  800479:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  80047e:	39 13                	cmp    %edx,(%ebx)
  800480:	74 37                	je     8004b9 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800482:	83 c0 01             	add    $0x1,%eax
  800485:	8b 1c 85 d4 22 80 00 	mov    0x8022d4(,%eax,4),%ebx
  80048c:	85 db                	test   %ebx,%ebx
  80048e:	75 ee                	jne    80047e <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800490:	a1 00 40 80 00       	mov    0x804000,%eax
  800495:	8b 40 48             	mov    0x48(%eax),%eax
  800498:	83 ec 04             	sub    $0x4,%esp
  80049b:	52                   	push   %edx
  80049c:	50                   	push   %eax
  80049d:	68 58 22 80 00       	push   $0x802258
  8004a2:	e8 e5 10 00 00       	call   80158c <cprintf>
	*dev = 0;
	return -E_INVAL;
  8004a7:	83 c4 10             	add    $0x10,%esp
  8004aa:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8004af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004b2:	89 1a                	mov    %ebx,(%edx)
}
  8004b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004b7:	c9                   	leave  
  8004b8:	c3                   	ret    
			return 0;
  8004b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8004be:	eb ef                	jmp    8004af <dev_lookup+0x45>

008004c0 <fd_close>:
{
  8004c0:	55                   	push   %ebp
  8004c1:	89 e5                	mov    %esp,%ebp
  8004c3:	57                   	push   %edi
  8004c4:	56                   	push   %esi
  8004c5:	53                   	push   %ebx
  8004c6:	83 ec 24             	sub    $0x24,%esp
  8004c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cc:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004cf:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004d2:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004d3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004d9:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004dc:	50                   	push   %eax
  8004dd:	e8 38 ff ff ff       	call   80041a <fd_lookup>
  8004e2:	89 c3                	mov    %eax,%ebx
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	85 c0                	test   %eax,%eax
  8004e9:	78 05                	js     8004f0 <fd_close+0x30>
	    || fd != fd2)
  8004eb:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004ee:	74 16                	je     800506 <fd_close+0x46>
		return (must_exist ? r : 0);
  8004f0:	89 f8                	mov    %edi,%eax
  8004f2:	84 c0                	test   %al,%al
  8004f4:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f9:	0f 44 d8             	cmove  %eax,%ebx
}
  8004fc:	89 d8                	mov    %ebx,%eax
  8004fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800501:	5b                   	pop    %ebx
  800502:	5e                   	pop    %esi
  800503:	5f                   	pop    %edi
  800504:	5d                   	pop    %ebp
  800505:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800506:	83 ec 08             	sub    $0x8,%esp
  800509:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80050c:	50                   	push   %eax
  80050d:	ff 36                	push   (%esi)
  80050f:	e8 56 ff ff ff       	call   80046a <dev_lookup>
  800514:	89 c3                	mov    %eax,%ebx
  800516:	83 c4 10             	add    $0x10,%esp
  800519:	85 c0                	test   %eax,%eax
  80051b:	78 1a                	js     800537 <fd_close+0x77>
		if (dev->dev_close)
  80051d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800520:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800523:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800528:	85 c0                	test   %eax,%eax
  80052a:	74 0b                	je     800537 <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80052c:	83 ec 0c             	sub    $0xc,%esp
  80052f:	56                   	push   %esi
  800530:	ff d0                	call   *%eax
  800532:	89 c3                	mov    %eax,%ebx
  800534:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800537:	83 ec 08             	sub    $0x8,%esp
  80053a:	56                   	push   %esi
  80053b:	6a 00                	push   $0x0
  80053d:	e8 94 fc ff ff       	call   8001d6 <sys_page_unmap>
	return r;
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	eb b5                	jmp    8004fc <fd_close+0x3c>

00800547 <close>:

int
close(int fdnum)
{
  800547:	55                   	push   %ebp
  800548:	89 e5                	mov    %esp,%ebp
  80054a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80054d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800550:	50                   	push   %eax
  800551:	ff 75 08             	push   0x8(%ebp)
  800554:	e8 c1 fe ff ff       	call   80041a <fd_lookup>
  800559:	83 c4 10             	add    $0x10,%esp
  80055c:	85 c0                	test   %eax,%eax
  80055e:	79 02                	jns    800562 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800560:	c9                   	leave  
  800561:	c3                   	ret    
		return fd_close(fd, 1);
  800562:	83 ec 08             	sub    $0x8,%esp
  800565:	6a 01                	push   $0x1
  800567:	ff 75 f4             	push   -0xc(%ebp)
  80056a:	e8 51 ff ff ff       	call   8004c0 <fd_close>
  80056f:	83 c4 10             	add    $0x10,%esp
  800572:	eb ec                	jmp    800560 <close+0x19>

00800574 <close_all>:

void
close_all(void)
{
  800574:	55                   	push   %ebp
  800575:	89 e5                	mov    %esp,%ebp
  800577:	53                   	push   %ebx
  800578:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80057b:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800580:	83 ec 0c             	sub    $0xc,%esp
  800583:	53                   	push   %ebx
  800584:	e8 be ff ff ff       	call   800547 <close>
	for (i = 0; i < MAXFD; i++)
  800589:	83 c3 01             	add    $0x1,%ebx
  80058c:	83 c4 10             	add    $0x10,%esp
  80058f:	83 fb 20             	cmp    $0x20,%ebx
  800592:	75 ec                	jne    800580 <close_all+0xc>
}
  800594:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800597:	c9                   	leave  
  800598:	c3                   	ret    

00800599 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800599:	55                   	push   %ebp
  80059a:	89 e5                	mov    %esp,%ebp
  80059c:	57                   	push   %edi
  80059d:	56                   	push   %esi
  80059e:	53                   	push   %ebx
  80059f:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005a5:	50                   	push   %eax
  8005a6:	ff 75 08             	push   0x8(%ebp)
  8005a9:	e8 6c fe ff ff       	call   80041a <fd_lookup>
  8005ae:	89 c3                	mov    %eax,%ebx
  8005b0:	83 c4 10             	add    $0x10,%esp
  8005b3:	85 c0                	test   %eax,%eax
  8005b5:	78 7f                	js     800636 <dup+0x9d>
		return r;
	close(newfdnum);
  8005b7:	83 ec 0c             	sub    $0xc,%esp
  8005ba:	ff 75 0c             	push   0xc(%ebp)
  8005bd:	e8 85 ff ff ff       	call   800547 <close>

	newfd = INDEX2FD(newfdnum);
  8005c2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005c5:	c1 e6 0c             	shl    $0xc,%esi
  8005c8:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d1:	89 3c 24             	mov    %edi,(%esp)
  8005d4:	e8 da fd ff ff       	call   8003b3 <fd2data>
  8005d9:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005db:	89 34 24             	mov    %esi,(%esp)
  8005de:	e8 d0 fd ff ff       	call   8003b3 <fd2data>
  8005e3:	83 c4 10             	add    $0x10,%esp
  8005e6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005e9:	89 d8                	mov    %ebx,%eax
  8005eb:	c1 e8 16             	shr    $0x16,%eax
  8005ee:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005f5:	a8 01                	test   $0x1,%al
  8005f7:	74 11                	je     80060a <dup+0x71>
  8005f9:	89 d8                	mov    %ebx,%eax
  8005fb:	c1 e8 0c             	shr    $0xc,%eax
  8005fe:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800605:	f6 c2 01             	test   $0x1,%dl
  800608:	75 36                	jne    800640 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060a:	89 f8                	mov    %edi,%eax
  80060c:	c1 e8 0c             	shr    $0xc,%eax
  80060f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800616:	83 ec 0c             	sub    $0xc,%esp
  800619:	25 07 0e 00 00       	and    $0xe07,%eax
  80061e:	50                   	push   %eax
  80061f:	56                   	push   %esi
  800620:	6a 00                	push   $0x0
  800622:	57                   	push   %edi
  800623:	6a 00                	push   $0x0
  800625:	e8 6a fb ff ff       	call   800194 <sys_page_map>
  80062a:	89 c3                	mov    %eax,%ebx
  80062c:	83 c4 20             	add    $0x20,%esp
  80062f:	85 c0                	test   %eax,%eax
  800631:	78 33                	js     800666 <dup+0xcd>
		goto err;

	return newfdnum;
  800633:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800636:	89 d8                	mov    %ebx,%eax
  800638:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063b:	5b                   	pop    %ebx
  80063c:	5e                   	pop    %esi
  80063d:	5f                   	pop    %edi
  80063e:	5d                   	pop    %ebp
  80063f:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800640:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800647:	83 ec 0c             	sub    $0xc,%esp
  80064a:	25 07 0e 00 00       	and    $0xe07,%eax
  80064f:	50                   	push   %eax
  800650:	ff 75 d4             	push   -0x2c(%ebp)
  800653:	6a 00                	push   $0x0
  800655:	53                   	push   %ebx
  800656:	6a 00                	push   $0x0
  800658:	e8 37 fb ff ff       	call   800194 <sys_page_map>
  80065d:	89 c3                	mov    %eax,%ebx
  80065f:	83 c4 20             	add    $0x20,%esp
  800662:	85 c0                	test   %eax,%eax
  800664:	79 a4                	jns    80060a <dup+0x71>
	sys_page_unmap(0, newfd);
  800666:	83 ec 08             	sub    $0x8,%esp
  800669:	56                   	push   %esi
  80066a:	6a 00                	push   $0x0
  80066c:	e8 65 fb ff ff       	call   8001d6 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800671:	83 c4 08             	add    $0x8,%esp
  800674:	ff 75 d4             	push   -0x2c(%ebp)
  800677:	6a 00                	push   $0x0
  800679:	e8 58 fb ff ff       	call   8001d6 <sys_page_unmap>
	return r;
  80067e:	83 c4 10             	add    $0x10,%esp
  800681:	eb b3                	jmp    800636 <dup+0x9d>

00800683 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800683:	55                   	push   %ebp
  800684:	89 e5                	mov    %esp,%ebp
  800686:	56                   	push   %esi
  800687:	53                   	push   %ebx
  800688:	83 ec 18             	sub    $0x18,%esp
  80068b:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80068e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800691:	50                   	push   %eax
  800692:	56                   	push   %esi
  800693:	e8 82 fd ff ff       	call   80041a <fd_lookup>
  800698:	83 c4 10             	add    $0x10,%esp
  80069b:	85 c0                	test   %eax,%eax
  80069d:	78 3c                	js     8006db <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80069f:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8006a2:	83 ec 08             	sub    $0x8,%esp
  8006a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006a8:	50                   	push   %eax
  8006a9:	ff 33                	push   (%ebx)
  8006ab:	e8 ba fd ff ff       	call   80046a <dev_lookup>
  8006b0:	83 c4 10             	add    $0x10,%esp
  8006b3:	85 c0                	test   %eax,%eax
  8006b5:	78 24                	js     8006db <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006b7:	8b 43 08             	mov    0x8(%ebx),%eax
  8006ba:	83 e0 03             	and    $0x3,%eax
  8006bd:	83 f8 01             	cmp    $0x1,%eax
  8006c0:	74 20                	je     8006e2 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c5:	8b 40 08             	mov    0x8(%eax),%eax
  8006c8:	85 c0                	test   %eax,%eax
  8006ca:	74 37                	je     800703 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006cc:	83 ec 04             	sub    $0x4,%esp
  8006cf:	ff 75 10             	push   0x10(%ebp)
  8006d2:	ff 75 0c             	push   0xc(%ebp)
  8006d5:	53                   	push   %ebx
  8006d6:	ff d0                	call   *%eax
  8006d8:	83 c4 10             	add    $0x10,%esp
}
  8006db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006de:	5b                   	pop    %ebx
  8006df:	5e                   	pop    %esi
  8006e0:	5d                   	pop    %ebp
  8006e1:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006e2:	a1 00 40 80 00       	mov    0x804000,%eax
  8006e7:	8b 40 48             	mov    0x48(%eax),%eax
  8006ea:	83 ec 04             	sub    $0x4,%esp
  8006ed:	56                   	push   %esi
  8006ee:	50                   	push   %eax
  8006ef:	68 99 22 80 00       	push   $0x802299
  8006f4:	e8 93 0e 00 00       	call   80158c <cprintf>
		return -E_INVAL;
  8006f9:	83 c4 10             	add    $0x10,%esp
  8006fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800701:	eb d8                	jmp    8006db <read+0x58>
		return -E_NOT_SUPP;
  800703:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800708:	eb d1                	jmp    8006db <read+0x58>

0080070a <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	57                   	push   %edi
  80070e:	56                   	push   %esi
  80070f:	53                   	push   %ebx
  800710:	83 ec 0c             	sub    $0xc,%esp
  800713:	8b 7d 08             	mov    0x8(%ebp),%edi
  800716:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800719:	bb 00 00 00 00       	mov    $0x0,%ebx
  80071e:	eb 02                	jmp    800722 <readn+0x18>
  800720:	01 c3                	add    %eax,%ebx
  800722:	39 f3                	cmp    %esi,%ebx
  800724:	73 21                	jae    800747 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800726:	83 ec 04             	sub    $0x4,%esp
  800729:	89 f0                	mov    %esi,%eax
  80072b:	29 d8                	sub    %ebx,%eax
  80072d:	50                   	push   %eax
  80072e:	89 d8                	mov    %ebx,%eax
  800730:	03 45 0c             	add    0xc(%ebp),%eax
  800733:	50                   	push   %eax
  800734:	57                   	push   %edi
  800735:	e8 49 ff ff ff       	call   800683 <read>
		if (m < 0)
  80073a:	83 c4 10             	add    $0x10,%esp
  80073d:	85 c0                	test   %eax,%eax
  80073f:	78 04                	js     800745 <readn+0x3b>
			return m;
		if (m == 0)
  800741:	75 dd                	jne    800720 <readn+0x16>
  800743:	eb 02                	jmp    800747 <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800745:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  800747:	89 d8                	mov    %ebx,%eax
  800749:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074c:	5b                   	pop    %ebx
  80074d:	5e                   	pop    %esi
  80074e:	5f                   	pop    %edi
  80074f:	5d                   	pop    %ebp
  800750:	c3                   	ret    

00800751 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800751:	55                   	push   %ebp
  800752:	89 e5                	mov    %esp,%ebp
  800754:	56                   	push   %esi
  800755:	53                   	push   %ebx
  800756:	83 ec 18             	sub    $0x18,%esp
  800759:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80075c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80075f:	50                   	push   %eax
  800760:	53                   	push   %ebx
  800761:	e8 b4 fc ff ff       	call   80041a <fd_lookup>
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	85 c0                	test   %eax,%eax
  80076b:	78 37                	js     8007a4 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80076d:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800770:	83 ec 08             	sub    $0x8,%esp
  800773:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800776:	50                   	push   %eax
  800777:	ff 36                	push   (%esi)
  800779:	e8 ec fc ff ff       	call   80046a <dev_lookup>
  80077e:	83 c4 10             	add    $0x10,%esp
  800781:	85 c0                	test   %eax,%eax
  800783:	78 1f                	js     8007a4 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800785:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800789:	74 20                	je     8007ab <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80078b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078e:	8b 40 0c             	mov    0xc(%eax),%eax
  800791:	85 c0                	test   %eax,%eax
  800793:	74 37                	je     8007cc <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800795:	83 ec 04             	sub    $0x4,%esp
  800798:	ff 75 10             	push   0x10(%ebp)
  80079b:	ff 75 0c             	push   0xc(%ebp)
  80079e:	56                   	push   %esi
  80079f:	ff d0                	call   *%eax
  8007a1:	83 c4 10             	add    $0x10,%esp
}
  8007a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007a7:	5b                   	pop    %ebx
  8007a8:	5e                   	pop    %esi
  8007a9:	5d                   	pop    %ebp
  8007aa:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007ab:	a1 00 40 80 00       	mov    0x804000,%eax
  8007b0:	8b 40 48             	mov    0x48(%eax),%eax
  8007b3:	83 ec 04             	sub    $0x4,%esp
  8007b6:	53                   	push   %ebx
  8007b7:	50                   	push   %eax
  8007b8:	68 b5 22 80 00       	push   $0x8022b5
  8007bd:	e8 ca 0d 00 00       	call   80158c <cprintf>
		return -E_INVAL;
  8007c2:	83 c4 10             	add    $0x10,%esp
  8007c5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007ca:	eb d8                	jmp    8007a4 <write+0x53>
		return -E_NOT_SUPP;
  8007cc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007d1:	eb d1                	jmp    8007a4 <write+0x53>

008007d3 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007d9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007dc:	50                   	push   %eax
  8007dd:	ff 75 08             	push   0x8(%ebp)
  8007e0:	e8 35 fc ff ff       	call   80041a <fd_lookup>
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	85 c0                	test   %eax,%eax
  8007ea:	78 0e                	js     8007fa <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f2:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fa:	c9                   	leave  
  8007fb:	c3                   	ret    

008007fc <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007fc:	55                   	push   %ebp
  8007fd:	89 e5                	mov    %esp,%ebp
  8007ff:	56                   	push   %esi
  800800:	53                   	push   %ebx
  800801:	83 ec 18             	sub    $0x18,%esp
  800804:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800807:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80080a:	50                   	push   %eax
  80080b:	53                   	push   %ebx
  80080c:	e8 09 fc ff ff       	call   80041a <fd_lookup>
  800811:	83 c4 10             	add    $0x10,%esp
  800814:	85 c0                	test   %eax,%eax
  800816:	78 34                	js     80084c <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800818:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800821:	50                   	push   %eax
  800822:	ff 36                	push   (%esi)
  800824:	e8 41 fc ff ff       	call   80046a <dev_lookup>
  800829:	83 c4 10             	add    $0x10,%esp
  80082c:	85 c0                	test   %eax,%eax
  80082e:	78 1c                	js     80084c <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800830:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800834:	74 1d                	je     800853 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800836:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800839:	8b 40 18             	mov    0x18(%eax),%eax
  80083c:	85 c0                	test   %eax,%eax
  80083e:	74 34                	je     800874 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800840:	83 ec 08             	sub    $0x8,%esp
  800843:	ff 75 0c             	push   0xc(%ebp)
  800846:	56                   	push   %esi
  800847:	ff d0                	call   *%eax
  800849:	83 c4 10             	add    $0x10,%esp
}
  80084c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80084f:	5b                   	pop    %ebx
  800850:	5e                   	pop    %esi
  800851:	5d                   	pop    %ebp
  800852:	c3                   	ret    
			thisenv->env_id, fdnum);
  800853:	a1 00 40 80 00       	mov    0x804000,%eax
  800858:	8b 40 48             	mov    0x48(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80085b:	83 ec 04             	sub    $0x4,%esp
  80085e:	53                   	push   %ebx
  80085f:	50                   	push   %eax
  800860:	68 78 22 80 00       	push   $0x802278
  800865:	e8 22 0d 00 00       	call   80158c <cprintf>
		return -E_INVAL;
  80086a:	83 c4 10             	add    $0x10,%esp
  80086d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800872:	eb d8                	jmp    80084c <ftruncate+0x50>
		return -E_NOT_SUPP;
  800874:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800879:	eb d1                	jmp    80084c <ftruncate+0x50>

0080087b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	56                   	push   %esi
  80087f:	53                   	push   %ebx
  800880:	83 ec 18             	sub    $0x18,%esp
  800883:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800886:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800889:	50                   	push   %eax
  80088a:	ff 75 08             	push   0x8(%ebp)
  80088d:	e8 88 fb ff ff       	call   80041a <fd_lookup>
  800892:	83 c4 10             	add    $0x10,%esp
  800895:	85 c0                	test   %eax,%eax
  800897:	78 49                	js     8008e2 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800899:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80089c:	83 ec 08             	sub    $0x8,%esp
  80089f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a2:	50                   	push   %eax
  8008a3:	ff 36                	push   (%esi)
  8008a5:	e8 c0 fb ff ff       	call   80046a <dev_lookup>
  8008aa:	83 c4 10             	add    $0x10,%esp
  8008ad:	85 c0                	test   %eax,%eax
  8008af:	78 31                	js     8008e2 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8008b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b4:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008b8:	74 2f                	je     8008e9 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008ba:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008bd:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008c4:	00 00 00 
	stat->st_isdir = 0;
  8008c7:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ce:	00 00 00 
	stat->st_dev = dev;
  8008d1:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008d7:	83 ec 08             	sub    $0x8,%esp
  8008da:	53                   	push   %ebx
  8008db:	56                   	push   %esi
  8008dc:	ff 50 14             	call   *0x14(%eax)
  8008df:	83 c4 10             	add    $0x10,%esp
}
  8008e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008e5:	5b                   	pop    %ebx
  8008e6:	5e                   	pop    %esi
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    
		return -E_NOT_SUPP;
  8008e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008ee:	eb f2                	jmp    8008e2 <fstat+0x67>

008008f0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	56                   	push   %esi
  8008f4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008f5:	83 ec 08             	sub    $0x8,%esp
  8008f8:	6a 00                	push   $0x0
  8008fa:	ff 75 08             	push   0x8(%ebp)
  8008fd:	e8 e4 01 00 00       	call   800ae6 <open>
  800902:	89 c3                	mov    %eax,%ebx
  800904:	83 c4 10             	add    $0x10,%esp
  800907:	85 c0                	test   %eax,%eax
  800909:	78 1b                	js     800926 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80090b:	83 ec 08             	sub    $0x8,%esp
  80090e:	ff 75 0c             	push   0xc(%ebp)
  800911:	50                   	push   %eax
  800912:	e8 64 ff ff ff       	call   80087b <fstat>
  800917:	89 c6                	mov    %eax,%esi
	close(fd);
  800919:	89 1c 24             	mov    %ebx,(%esp)
  80091c:	e8 26 fc ff ff       	call   800547 <close>
	return r;
  800921:	83 c4 10             	add    $0x10,%esp
  800924:	89 f3                	mov    %esi,%ebx
}
  800926:	89 d8                	mov    %ebx,%eax
  800928:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80092b:	5b                   	pop    %ebx
  80092c:	5e                   	pop    %esi
  80092d:	5d                   	pop    %ebp
  80092e:	c3                   	ret    

0080092f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80092f:	55                   	push   %ebp
  800930:	89 e5                	mov    %esp,%ebp
  800932:	56                   	push   %esi
  800933:	53                   	push   %ebx
  800934:	89 c6                	mov    %eax,%esi
  800936:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800938:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  80093f:	74 27                	je     800968 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800941:	6a 07                	push   $0x7
  800943:	68 00 50 80 00       	push   $0x805000
  800948:	56                   	push   %esi
  800949:	ff 35 00 60 80 00    	push   0x806000
  80094f:	e8 b9 15 00 00       	call   801f0d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800954:	83 c4 0c             	add    $0xc,%esp
  800957:	6a 00                	push   $0x0
  800959:	53                   	push   %ebx
  80095a:	6a 00                	push   $0x0
  80095c:	e8 45 15 00 00       	call   801ea6 <ipc_recv>
}
  800961:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800964:	5b                   	pop    %ebx
  800965:	5e                   	pop    %esi
  800966:	5d                   	pop    %ebp
  800967:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800968:	83 ec 0c             	sub    $0xc,%esp
  80096b:	6a 01                	push   $0x1
  80096d:	e8 ef 15 00 00       	call   801f61 <ipc_find_env>
  800972:	a3 00 60 80 00       	mov    %eax,0x806000
  800977:	83 c4 10             	add    $0x10,%esp
  80097a:	eb c5                	jmp    800941 <fsipc+0x12>

0080097c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80097c:	55                   	push   %ebp
  80097d:	89 e5                	mov    %esp,%ebp
  80097f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	8b 40 0c             	mov    0xc(%eax),%eax
  800988:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80098d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800990:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800995:	ba 00 00 00 00       	mov    $0x0,%edx
  80099a:	b8 02 00 00 00       	mov    $0x2,%eax
  80099f:	e8 8b ff ff ff       	call   80092f <fsipc>
}
  8009a4:	c9                   	leave  
  8009a5:	c3                   	ret    

008009a6 <devfile_flush>:
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8009af:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bc:	b8 06 00 00 00       	mov    $0x6,%eax
  8009c1:	e8 69 ff ff ff       	call   80092f <fsipc>
}
  8009c6:	c9                   	leave  
  8009c7:	c3                   	ret    

008009c8 <devfile_stat>:
{
  8009c8:	55                   	push   %ebp
  8009c9:	89 e5                	mov    %esp,%ebp
  8009cb:	53                   	push   %ebx
  8009cc:	83 ec 04             	sub    $0x4,%esp
  8009cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e2:	b8 05 00 00 00       	mov    $0x5,%eax
  8009e7:	e8 43 ff ff ff       	call   80092f <fsipc>
  8009ec:	85 c0                	test   %eax,%eax
  8009ee:	78 2c                	js     800a1c <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009f0:	83 ec 08             	sub    $0x8,%esp
  8009f3:	68 00 50 80 00       	push   $0x805000
  8009f8:	53                   	push   %ebx
  8009f9:	e8 68 11 00 00       	call   801b66 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009fe:	a1 80 50 80 00       	mov    0x805080,%eax
  800a03:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a09:	a1 84 50 80 00       	mov    0x805084,%eax
  800a0e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a14:	83 c4 10             	add    $0x10,%esp
  800a17:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a1f:	c9                   	leave  
  800a20:	c3                   	ret    

00800a21 <devfile_write>:
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	83 ec 0c             	sub    $0xc,%esp
  800a27:	8b 45 10             	mov    0x10(%ebp),%eax
  800a2a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a2f:	39 d0                	cmp    %edx,%eax
  800a31:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a34:	8b 55 08             	mov    0x8(%ebp),%edx
  800a37:	8b 52 0c             	mov    0xc(%edx),%edx
  800a3a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a40:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a45:	50                   	push   %eax
  800a46:	ff 75 0c             	push   0xc(%ebp)
  800a49:	68 08 50 80 00       	push   $0x805008
  800a4e:	e8 a9 12 00 00       	call   801cfc <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800a53:	ba 00 00 00 00       	mov    $0x0,%edx
  800a58:	b8 04 00 00 00       	mov    $0x4,%eax
  800a5d:	e8 cd fe ff ff       	call   80092f <fsipc>
}
  800a62:	c9                   	leave  
  800a63:	c3                   	ret    

00800a64 <devfile_read>:
{
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	56                   	push   %esi
  800a68:	53                   	push   %ebx
  800a69:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6f:	8b 40 0c             	mov    0xc(%eax),%eax
  800a72:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a77:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800a82:	b8 03 00 00 00       	mov    $0x3,%eax
  800a87:	e8 a3 fe ff ff       	call   80092f <fsipc>
  800a8c:	89 c3                	mov    %eax,%ebx
  800a8e:	85 c0                	test   %eax,%eax
  800a90:	78 1f                	js     800ab1 <devfile_read+0x4d>
	assert(r <= n);
  800a92:	39 f0                	cmp    %esi,%eax
  800a94:	77 24                	ja     800aba <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a96:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a9b:	7f 33                	jg     800ad0 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a9d:	83 ec 04             	sub    $0x4,%esp
  800aa0:	50                   	push   %eax
  800aa1:	68 00 50 80 00       	push   $0x805000
  800aa6:	ff 75 0c             	push   0xc(%ebp)
  800aa9:	e8 4e 12 00 00       	call   801cfc <memmove>
	return r;
  800aae:	83 c4 10             	add    $0x10,%esp
}
  800ab1:	89 d8                	mov    %ebx,%eax
  800ab3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ab6:	5b                   	pop    %ebx
  800ab7:	5e                   	pop    %esi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    
	assert(r <= n);
  800aba:	68 e8 22 80 00       	push   $0x8022e8
  800abf:	68 ef 22 80 00       	push   $0x8022ef
  800ac4:	6a 7c                	push   $0x7c
  800ac6:	68 04 23 80 00       	push   $0x802304
  800acb:	e8 e1 09 00 00       	call   8014b1 <_panic>
	assert(r <= PGSIZE);
  800ad0:	68 0f 23 80 00       	push   $0x80230f
  800ad5:	68 ef 22 80 00       	push   $0x8022ef
  800ada:	6a 7d                	push   $0x7d
  800adc:	68 04 23 80 00       	push   $0x802304
  800ae1:	e8 cb 09 00 00       	call   8014b1 <_panic>

00800ae6 <open>:
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	56                   	push   %esi
  800aea:	53                   	push   %ebx
  800aeb:	83 ec 1c             	sub    $0x1c,%esp
  800aee:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800af1:	56                   	push   %esi
  800af2:	e8 34 10 00 00       	call   801b2b <strlen>
  800af7:	83 c4 10             	add    $0x10,%esp
  800afa:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aff:	7f 6c                	jg     800b6d <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800b01:	83 ec 0c             	sub    $0xc,%esp
  800b04:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b07:	50                   	push   %eax
  800b08:	e8 bd f8 ff ff       	call   8003ca <fd_alloc>
  800b0d:	89 c3                	mov    %eax,%ebx
  800b0f:	83 c4 10             	add    $0x10,%esp
  800b12:	85 c0                	test   %eax,%eax
  800b14:	78 3c                	js     800b52 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800b16:	83 ec 08             	sub    $0x8,%esp
  800b19:	56                   	push   %esi
  800b1a:	68 00 50 80 00       	push   $0x805000
  800b1f:	e8 42 10 00 00       	call   801b66 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b27:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b2f:	b8 01 00 00 00       	mov    $0x1,%eax
  800b34:	e8 f6 fd ff ff       	call   80092f <fsipc>
  800b39:	89 c3                	mov    %eax,%ebx
  800b3b:	83 c4 10             	add    $0x10,%esp
  800b3e:	85 c0                	test   %eax,%eax
  800b40:	78 19                	js     800b5b <open+0x75>
	return fd2num(fd);
  800b42:	83 ec 0c             	sub    $0xc,%esp
  800b45:	ff 75 f4             	push   -0xc(%ebp)
  800b48:	e8 56 f8 ff ff       	call   8003a3 <fd2num>
  800b4d:	89 c3                	mov    %eax,%ebx
  800b4f:	83 c4 10             	add    $0x10,%esp
}
  800b52:	89 d8                	mov    %ebx,%eax
  800b54:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b57:	5b                   	pop    %ebx
  800b58:	5e                   	pop    %esi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    
		fd_close(fd, 0);
  800b5b:	83 ec 08             	sub    $0x8,%esp
  800b5e:	6a 00                	push   $0x0
  800b60:	ff 75 f4             	push   -0xc(%ebp)
  800b63:	e8 58 f9 ff ff       	call   8004c0 <fd_close>
		return r;
  800b68:	83 c4 10             	add    $0x10,%esp
  800b6b:	eb e5                	jmp    800b52 <open+0x6c>
		return -E_BAD_PATH;
  800b6d:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b72:	eb de                	jmp    800b52 <open+0x6c>

00800b74 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b74:	55                   	push   %ebp
  800b75:	89 e5                	mov    %esp,%ebp
  800b77:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b7a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7f:	b8 08 00 00 00       	mov    $0x8,%eax
  800b84:	e8 a6 fd ff ff       	call   80092f <fsipc>
}
  800b89:	c9                   	leave  
  800b8a:	c3                   	ret    

00800b8b <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b91:	68 1b 23 80 00       	push   $0x80231b
  800b96:	ff 75 0c             	push   0xc(%ebp)
  800b99:	e8 c8 0f 00 00       	call   801b66 <strcpy>
	return 0;
}
  800b9e:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba3:	c9                   	leave  
  800ba4:	c3                   	ret    

00800ba5 <devsock_close>:
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	53                   	push   %ebx
  800ba9:	83 ec 10             	sub    $0x10,%esp
  800bac:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800baf:	53                   	push   %ebx
  800bb0:	e8 e5 13 00 00       	call   801f9a <pageref>
  800bb5:	89 c2                	mov    %eax,%edx
  800bb7:	83 c4 10             	add    $0x10,%esp
		return 0;
  800bba:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800bbf:	83 fa 01             	cmp    $0x1,%edx
  800bc2:	74 05                	je     800bc9 <devsock_close+0x24>
}
  800bc4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc7:	c9                   	leave  
  800bc8:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800bc9:	83 ec 0c             	sub    $0xc,%esp
  800bcc:	ff 73 0c             	push   0xc(%ebx)
  800bcf:	e8 b7 02 00 00       	call   800e8b <nsipc_close>
  800bd4:	83 c4 10             	add    $0x10,%esp
  800bd7:	eb eb                	jmp    800bc4 <devsock_close+0x1f>

00800bd9 <devsock_write>:
{
  800bd9:	55                   	push   %ebp
  800bda:	89 e5                	mov    %esp,%ebp
  800bdc:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bdf:	6a 00                	push   $0x0
  800be1:	ff 75 10             	push   0x10(%ebp)
  800be4:	ff 75 0c             	push   0xc(%ebp)
  800be7:	8b 45 08             	mov    0x8(%ebp),%eax
  800bea:	ff 70 0c             	push   0xc(%eax)
  800bed:	e8 79 03 00 00       	call   800f6b <nsipc_send>
}
  800bf2:	c9                   	leave  
  800bf3:	c3                   	ret    

00800bf4 <devsock_read>:
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800bfa:	6a 00                	push   $0x0
  800bfc:	ff 75 10             	push   0x10(%ebp)
  800bff:	ff 75 0c             	push   0xc(%ebp)
  800c02:	8b 45 08             	mov    0x8(%ebp),%eax
  800c05:	ff 70 0c             	push   0xc(%eax)
  800c08:	e8 ef 02 00 00       	call   800efc <nsipc_recv>
}
  800c0d:	c9                   	leave  
  800c0e:	c3                   	ret    

00800c0f <fd2sockid>:
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c15:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c18:	52                   	push   %edx
  800c19:	50                   	push   %eax
  800c1a:	e8 fb f7 ff ff       	call   80041a <fd_lookup>
  800c1f:	83 c4 10             	add    $0x10,%esp
  800c22:	85 c0                	test   %eax,%eax
  800c24:	78 10                	js     800c36 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800c26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c29:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c2f:	39 08                	cmp    %ecx,(%eax)
  800c31:	75 05                	jne    800c38 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c33:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c36:	c9                   	leave  
  800c37:	c3                   	ret    
		return -E_NOT_SUPP;
  800c38:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c3d:	eb f7                	jmp    800c36 <fd2sockid+0x27>

00800c3f <alloc_sockfd>:
{
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	56                   	push   %esi
  800c43:	53                   	push   %ebx
  800c44:	83 ec 1c             	sub    $0x1c,%esp
  800c47:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c4c:	50                   	push   %eax
  800c4d:	e8 78 f7 ff ff       	call   8003ca <fd_alloc>
  800c52:	89 c3                	mov    %eax,%ebx
  800c54:	83 c4 10             	add    $0x10,%esp
  800c57:	85 c0                	test   %eax,%eax
  800c59:	78 43                	js     800c9e <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c5b:	83 ec 04             	sub    $0x4,%esp
  800c5e:	68 07 04 00 00       	push   $0x407
  800c63:	ff 75 f4             	push   -0xc(%ebp)
  800c66:	6a 00                	push   $0x0
  800c68:	e8 e4 f4 ff ff       	call   800151 <sys_page_alloc>
  800c6d:	89 c3                	mov    %eax,%ebx
  800c6f:	83 c4 10             	add    $0x10,%esp
  800c72:	85 c0                	test   %eax,%eax
  800c74:	78 28                	js     800c9e <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c76:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c79:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c7f:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c81:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c84:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c8b:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800c8e:	83 ec 0c             	sub    $0xc,%esp
  800c91:	50                   	push   %eax
  800c92:	e8 0c f7 ff ff       	call   8003a3 <fd2num>
  800c97:	89 c3                	mov    %eax,%ebx
  800c99:	83 c4 10             	add    $0x10,%esp
  800c9c:	eb 0c                	jmp    800caa <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800c9e:	83 ec 0c             	sub    $0xc,%esp
  800ca1:	56                   	push   %esi
  800ca2:	e8 e4 01 00 00       	call   800e8b <nsipc_close>
		return r;
  800ca7:	83 c4 10             	add    $0x10,%esp
}
  800caa:	89 d8                	mov    %ebx,%eax
  800cac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800caf:	5b                   	pop    %ebx
  800cb0:	5e                   	pop    %esi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <accept>:
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbc:	e8 4e ff ff ff       	call   800c0f <fd2sockid>
  800cc1:	85 c0                	test   %eax,%eax
  800cc3:	78 1b                	js     800ce0 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cc5:	83 ec 04             	sub    $0x4,%esp
  800cc8:	ff 75 10             	push   0x10(%ebp)
  800ccb:	ff 75 0c             	push   0xc(%ebp)
  800cce:	50                   	push   %eax
  800ccf:	e8 0e 01 00 00       	call   800de2 <nsipc_accept>
  800cd4:	83 c4 10             	add    $0x10,%esp
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	78 05                	js     800ce0 <accept+0x2d>
	return alloc_sockfd(r);
  800cdb:	e8 5f ff ff ff       	call   800c3f <alloc_sockfd>
}
  800ce0:	c9                   	leave  
  800ce1:	c3                   	ret    

00800ce2 <bind>:
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800ce8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ceb:	e8 1f ff ff ff       	call   800c0f <fd2sockid>
  800cf0:	85 c0                	test   %eax,%eax
  800cf2:	78 12                	js     800d06 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  800cf4:	83 ec 04             	sub    $0x4,%esp
  800cf7:	ff 75 10             	push   0x10(%ebp)
  800cfa:	ff 75 0c             	push   0xc(%ebp)
  800cfd:	50                   	push   %eax
  800cfe:	e8 31 01 00 00       	call   800e34 <nsipc_bind>
  800d03:	83 c4 10             	add    $0x10,%esp
}
  800d06:	c9                   	leave  
  800d07:	c3                   	ret    

00800d08 <shutdown>:
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d11:	e8 f9 fe ff ff       	call   800c0f <fd2sockid>
  800d16:	85 c0                	test   %eax,%eax
  800d18:	78 0f                	js     800d29 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  800d1a:	83 ec 08             	sub    $0x8,%esp
  800d1d:	ff 75 0c             	push   0xc(%ebp)
  800d20:	50                   	push   %eax
  800d21:	e8 43 01 00 00       	call   800e69 <nsipc_shutdown>
  800d26:	83 c4 10             	add    $0x10,%esp
}
  800d29:	c9                   	leave  
  800d2a:	c3                   	ret    

00800d2b <connect>:
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d31:	8b 45 08             	mov    0x8(%ebp),%eax
  800d34:	e8 d6 fe ff ff       	call   800c0f <fd2sockid>
  800d39:	85 c0                	test   %eax,%eax
  800d3b:	78 12                	js     800d4f <connect+0x24>
	return nsipc_connect(r, name, namelen);
  800d3d:	83 ec 04             	sub    $0x4,%esp
  800d40:	ff 75 10             	push   0x10(%ebp)
  800d43:	ff 75 0c             	push   0xc(%ebp)
  800d46:	50                   	push   %eax
  800d47:	e8 59 01 00 00       	call   800ea5 <nsipc_connect>
  800d4c:	83 c4 10             	add    $0x10,%esp
}
  800d4f:	c9                   	leave  
  800d50:	c3                   	ret    

00800d51 <listen>:
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d57:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5a:	e8 b0 fe ff ff       	call   800c0f <fd2sockid>
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	78 0f                	js     800d72 <listen+0x21>
	return nsipc_listen(r, backlog);
  800d63:	83 ec 08             	sub    $0x8,%esp
  800d66:	ff 75 0c             	push   0xc(%ebp)
  800d69:	50                   	push   %eax
  800d6a:	e8 6b 01 00 00       	call   800eda <nsipc_listen>
  800d6f:	83 c4 10             	add    $0x10,%esp
}
  800d72:	c9                   	leave  
  800d73:	c3                   	ret    

00800d74 <socket>:

int
socket(int domain, int type, int protocol)
{
  800d74:	55                   	push   %ebp
  800d75:	89 e5                	mov    %esp,%ebp
  800d77:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d7a:	ff 75 10             	push   0x10(%ebp)
  800d7d:	ff 75 0c             	push   0xc(%ebp)
  800d80:	ff 75 08             	push   0x8(%ebp)
  800d83:	e8 41 02 00 00       	call   800fc9 <nsipc_socket>
  800d88:	83 c4 10             	add    $0x10,%esp
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	78 05                	js     800d94 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800d8f:	e8 ab fe ff ff       	call   800c3f <alloc_sockfd>
}
  800d94:	c9                   	leave  
  800d95:	c3                   	ret    

00800d96 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	53                   	push   %ebx
  800d9a:	83 ec 04             	sub    $0x4,%esp
  800d9d:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800d9f:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  800da6:	74 26                	je     800dce <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800da8:	6a 07                	push   $0x7
  800daa:	68 00 70 80 00       	push   $0x807000
  800daf:	53                   	push   %ebx
  800db0:	ff 35 00 80 80 00    	push   0x808000
  800db6:	e8 52 11 00 00       	call   801f0d <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dbb:	83 c4 0c             	add    $0xc,%esp
  800dbe:	6a 00                	push   $0x0
  800dc0:	6a 00                	push   $0x0
  800dc2:	6a 00                	push   $0x0
  800dc4:	e8 dd 10 00 00       	call   801ea6 <ipc_recv>
}
  800dc9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dcc:	c9                   	leave  
  800dcd:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dce:	83 ec 0c             	sub    $0xc,%esp
  800dd1:	6a 02                	push   $0x2
  800dd3:	e8 89 11 00 00       	call   801f61 <ipc_find_env>
  800dd8:	a3 00 80 80 00       	mov    %eax,0x808000
  800ddd:	83 c4 10             	add    $0x10,%esp
  800de0:	eb c6                	jmp    800da8 <nsipc+0x12>

00800de2 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	56                   	push   %esi
  800de6:	53                   	push   %ebx
  800de7:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800dea:	8b 45 08             	mov    0x8(%ebp),%eax
  800ded:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800df2:	8b 06                	mov    (%esi),%eax
  800df4:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800df9:	b8 01 00 00 00       	mov    $0x1,%eax
  800dfe:	e8 93 ff ff ff       	call   800d96 <nsipc>
  800e03:	89 c3                	mov    %eax,%ebx
  800e05:	85 c0                	test   %eax,%eax
  800e07:	79 09                	jns    800e12 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800e09:	89 d8                	mov    %ebx,%eax
  800e0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e0e:	5b                   	pop    %ebx
  800e0f:	5e                   	pop    %esi
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e12:	83 ec 04             	sub    $0x4,%esp
  800e15:	ff 35 10 70 80 00    	push   0x807010
  800e1b:	68 00 70 80 00       	push   $0x807000
  800e20:	ff 75 0c             	push   0xc(%ebp)
  800e23:	e8 d4 0e 00 00       	call   801cfc <memmove>
		*addrlen = ret->ret_addrlen;
  800e28:	a1 10 70 80 00       	mov    0x807010,%eax
  800e2d:	89 06                	mov    %eax,(%esi)
  800e2f:	83 c4 10             	add    $0x10,%esp
	return r;
  800e32:	eb d5                	jmp    800e09 <nsipc_accept+0x27>

00800e34 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	53                   	push   %ebx
  800e38:	83 ec 08             	sub    $0x8,%esp
  800e3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e41:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e46:	53                   	push   %ebx
  800e47:	ff 75 0c             	push   0xc(%ebp)
  800e4a:	68 04 70 80 00       	push   $0x807004
  800e4f:	e8 a8 0e 00 00       	call   801cfc <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e54:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  800e5a:	b8 02 00 00 00       	mov    $0x2,%eax
  800e5f:	e8 32 ff ff ff       	call   800d96 <nsipc>
}
  800e64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e67:	c9                   	leave  
  800e68:	c3                   	ret    

00800e69 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e69:	55                   	push   %ebp
  800e6a:	89 e5                	mov    %esp,%ebp
  800e6c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e72:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  800e77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7a:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  800e7f:	b8 03 00 00 00       	mov    $0x3,%eax
  800e84:	e8 0d ff ff ff       	call   800d96 <nsipc>
}
  800e89:	c9                   	leave  
  800e8a:	c3                   	ret    

00800e8b <nsipc_close>:

int
nsipc_close(int s)
{
  800e8b:	55                   	push   %ebp
  800e8c:	89 e5                	mov    %esp,%ebp
  800e8e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e91:	8b 45 08             	mov    0x8(%ebp),%eax
  800e94:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  800e99:	b8 04 00 00 00       	mov    $0x4,%eax
  800e9e:	e8 f3 fe ff ff       	call   800d96 <nsipc>
}
  800ea3:	c9                   	leave  
  800ea4:	c3                   	ret    

00800ea5 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ea5:	55                   	push   %ebp
  800ea6:	89 e5                	mov    %esp,%ebp
  800ea8:	53                   	push   %ebx
  800ea9:	83 ec 08             	sub    $0x8,%esp
  800eac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800eaf:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb2:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800eb7:	53                   	push   %ebx
  800eb8:	ff 75 0c             	push   0xc(%ebp)
  800ebb:	68 04 70 80 00       	push   $0x807004
  800ec0:	e8 37 0e 00 00       	call   801cfc <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ec5:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  800ecb:	b8 05 00 00 00       	mov    $0x5,%eax
  800ed0:	e8 c1 fe ff ff       	call   800d96 <nsipc>
}
  800ed5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed8:	c9                   	leave  
  800ed9:	c3                   	ret    

00800eda <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ee0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee3:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  800ee8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eeb:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  800ef0:	b8 06 00 00 00       	mov    $0x6,%eax
  800ef5:	e8 9c fe ff ff       	call   800d96 <nsipc>
}
  800efa:	c9                   	leave  
  800efb:	c3                   	ret    

00800efc <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	56                   	push   %esi
  800f00:	53                   	push   %ebx
  800f01:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f04:	8b 45 08             	mov    0x8(%ebp),%eax
  800f07:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  800f0c:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  800f12:	8b 45 14             	mov    0x14(%ebp),%eax
  800f15:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f1a:	b8 07 00 00 00       	mov    $0x7,%eax
  800f1f:	e8 72 fe ff ff       	call   800d96 <nsipc>
  800f24:	89 c3                	mov    %eax,%ebx
  800f26:	85 c0                	test   %eax,%eax
  800f28:	78 22                	js     800f4c <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  800f2a:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f2f:	39 c6                	cmp    %eax,%esi
  800f31:	0f 4e c6             	cmovle %esi,%eax
  800f34:	39 c3                	cmp    %eax,%ebx
  800f36:	7f 1d                	jg     800f55 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f38:	83 ec 04             	sub    $0x4,%esp
  800f3b:	53                   	push   %ebx
  800f3c:	68 00 70 80 00       	push   $0x807000
  800f41:	ff 75 0c             	push   0xc(%ebp)
  800f44:	e8 b3 0d 00 00       	call   801cfc <memmove>
  800f49:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f4c:	89 d8                	mov    %ebx,%eax
  800f4e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f51:	5b                   	pop    %ebx
  800f52:	5e                   	pop    %esi
  800f53:	5d                   	pop    %ebp
  800f54:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f55:	68 27 23 80 00       	push   $0x802327
  800f5a:	68 ef 22 80 00       	push   $0x8022ef
  800f5f:	6a 62                	push   $0x62
  800f61:	68 3c 23 80 00       	push   $0x80233c
  800f66:	e8 46 05 00 00       	call   8014b1 <_panic>

00800f6b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f6b:	55                   	push   %ebp
  800f6c:	89 e5                	mov    %esp,%ebp
  800f6e:	53                   	push   %ebx
  800f6f:	83 ec 04             	sub    $0x4,%esp
  800f72:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f75:	8b 45 08             	mov    0x8(%ebp),%eax
  800f78:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  800f7d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f83:	7f 2e                	jg     800fb3 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f85:	83 ec 04             	sub    $0x4,%esp
  800f88:	53                   	push   %ebx
  800f89:	ff 75 0c             	push   0xc(%ebp)
  800f8c:	68 0c 70 80 00       	push   $0x80700c
  800f91:	e8 66 0d 00 00       	call   801cfc <memmove>
	nsipcbuf.send.req_size = size;
  800f96:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  800f9c:	8b 45 14             	mov    0x14(%ebp),%eax
  800f9f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  800fa4:	b8 08 00 00 00       	mov    $0x8,%eax
  800fa9:	e8 e8 fd ff ff       	call   800d96 <nsipc>
}
  800fae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb1:	c9                   	leave  
  800fb2:	c3                   	ret    
	assert(size < 1600);
  800fb3:	68 48 23 80 00       	push   $0x802348
  800fb8:	68 ef 22 80 00       	push   $0x8022ef
  800fbd:	6a 6d                	push   $0x6d
  800fbf:	68 3c 23 80 00       	push   $0x80233c
  800fc4:	e8 e8 04 00 00       	call   8014b1 <_panic>

00800fc9 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fc9:	55                   	push   %ebp
  800fca:	89 e5                	mov    %esp,%ebp
  800fcc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fcf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd2:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  800fd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fda:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  800fdf:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe2:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  800fe7:	b8 09 00 00 00       	mov    $0x9,%eax
  800fec:	e8 a5 fd ff ff       	call   800d96 <nsipc>
}
  800ff1:	c9                   	leave  
  800ff2:	c3                   	ret    

00800ff3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	56                   	push   %esi
  800ff7:	53                   	push   %ebx
  800ff8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ffb:	83 ec 0c             	sub    $0xc,%esp
  800ffe:	ff 75 08             	push   0x8(%ebp)
  801001:	e8 ad f3 ff ff       	call   8003b3 <fd2data>
  801006:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801008:	83 c4 08             	add    $0x8,%esp
  80100b:	68 54 23 80 00       	push   $0x802354
  801010:	53                   	push   %ebx
  801011:	e8 50 0b 00 00       	call   801b66 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801016:	8b 46 04             	mov    0x4(%esi),%eax
  801019:	2b 06                	sub    (%esi),%eax
  80101b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801021:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801028:	00 00 00 
	stat->st_dev = &devpipe;
  80102b:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801032:	30 80 00 
	return 0;
}
  801035:	b8 00 00 00 00       	mov    $0x0,%eax
  80103a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80103d:	5b                   	pop    %ebx
  80103e:	5e                   	pop    %esi
  80103f:	5d                   	pop    %ebp
  801040:	c3                   	ret    

00801041 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801041:	55                   	push   %ebp
  801042:	89 e5                	mov    %esp,%ebp
  801044:	53                   	push   %ebx
  801045:	83 ec 0c             	sub    $0xc,%esp
  801048:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80104b:	53                   	push   %ebx
  80104c:	6a 00                	push   $0x0
  80104e:	e8 83 f1 ff ff       	call   8001d6 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801053:	89 1c 24             	mov    %ebx,(%esp)
  801056:	e8 58 f3 ff ff       	call   8003b3 <fd2data>
  80105b:	83 c4 08             	add    $0x8,%esp
  80105e:	50                   	push   %eax
  80105f:	6a 00                	push   $0x0
  801061:	e8 70 f1 ff ff       	call   8001d6 <sys_page_unmap>
}
  801066:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801069:	c9                   	leave  
  80106a:	c3                   	ret    

0080106b <_pipeisclosed>:
{
  80106b:	55                   	push   %ebp
  80106c:	89 e5                	mov    %esp,%ebp
  80106e:	57                   	push   %edi
  80106f:	56                   	push   %esi
  801070:	53                   	push   %ebx
  801071:	83 ec 1c             	sub    $0x1c,%esp
  801074:	89 c7                	mov    %eax,%edi
  801076:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801078:	a1 00 40 80 00       	mov    0x804000,%eax
  80107d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801080:	83 ec 0c             	sub    $0xc,%esp
  801083:	57                   	push   %edi
  801084:	e8 11 0f 00 00       	call   801f9a <pageref>
  801089:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80108c:	89 34 24             	mov    %esi,(%esp)
  80108f:	e8 06 0f 00 00       	call   801f9a <pageref>
		nn = thisenv->env_runs;
  801094:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80109a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80109d:	83 c4 10             	add    $0x10,%esp
  8010a0:	39 cb                	cmp    %ecx,%ebx
  8010a2:	74 1b                	je     8010bf <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010a4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010a7:	75 cf                	jne    801078 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010a9:	8b 42 58             	mov    0x58(%edx),%eax
  8010ac:	6a 01                	push   $0x1
  8010ae:	50                   	push   %eax
  8010af:	53                   	push   %ebx
  8010b0:	68 5b 23 80 00       	push   $0x80235b
  8010b5:	e8 d2 04 00 00       	call   80158c <cprintf>
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	eb b9                	jmp    801078 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010bf:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010c2:	0f 94 c0             	sete   %al
  8010c5:	0f b6 c0             	movzbl %al,%eax
}
  8010c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010cb:	5b                   	pop    %ebx
  8010cc:	5e                   	pop    %esi
  8010cd:	5f                   	pop    %edi
  8010ce:	5d                   	pop    %ebp
  8010cf:	c3                   	ret    

008010d0 <devpipe_write>:
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	57                   	push   %edi
  8010d4:	56                   	push   %esi
  8010d5:	53                   	push   %ebx
  8010d6:	83 ec 28             	sub    $0x28,%esp
  8010d9:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8010dc:	56                   	push   %esi
  8010dd:	e8 d1 f2 ff ff       	call   8003b3 <fd2data>
  8010e2:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8010e4:	83 c4 10             	add    $0x10,%esp
  8010e7:	bf 00 00 00 00       	mov    $0x0,%edi
  8010ec:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8010ef:	75 09                	jne    8010fa <devpipe_write+0x2a>
	return i;
  8010f1:	89 f8                	mov    %edi,%eax
  8010f3:	eb 23                	jmp    801118 <devpipe_write+0x48>
			sys_yield();
  8010f5:	e8 38 f0 ff ff       	call   800132 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8010fa:	8b 43 04             	mov    0x4(%ebx),%eax
  8010fd:	8b 0b                	mov    (%ebx),%ecx
  8010ff:	8d 51 20             	lea    0x20(%ecx),%edx
  801102:	39 d0                	cmp    %edx,%eax
  801104:	72 1a                	jb     801120 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801106:	89 da                	mov    %ebx,%edx
  801108:	89 f0                	mov    %esi,%eax
  80110a:	e8 5c ff ff ff       	call   80106b <_pipeisclosed>
  80110f:	85 c0                	test   %eax,%eax
  801111:	74 e2                	je     8010f5 <devpipe_write+0x25>
				return 0;
  801113:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111b:	5b                   	pop    %ebx
  80111c:	5e                   	pop    %esi
  80111d:	5f                   	pop    %edi
  80111e:	5d                   	pop    %ebp
  80111f:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801120:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801123:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801127:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80112a:	89 c2                	mov    %eax,%edx
  80112c:	c1 fa 1f             	sar    $0x1f,%edx
  80112f:	89 d1                	mov    %edx,%ecx
  801131:	c1 e9 1b             	shr    $0x1b,%ecx
  801134:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801137:	83 e2 1f             	and    $0x1f,%edx
  80113a:	29 ca                	sub    %ecx,%edx
  80113c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801140:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801144:	83 c0 01             	add    $0x1,%eax
  801147:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80114a:	83 c7 01             	add    $0x1,%edi
  80114d:	eb 9d                	jmp    8010ec <devpipe_write+0x1c>

0080114f <devpipe_read>:
{
  80114f:	55                   	push   %ebp
  801150:	89 e5                	mov    %esp,%ebp
  801152:	57                   	push   %edi
  801153:	56                   	push   %esi
  801154:	53                   	push   %ebx
  801155:	83 ec 18             	sub    $0x18,%esp
  801158:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80115b:	57                   	push   %edi
  80115c:	e8 52 f2 ff ff       	call   8003b3 <fd2data>
  801161:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801163:	83 c4 10             	add    $0x10,%esp
  801166:	be 00 00 00 00       	mov    $0x0,%esi
  80116b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80116e:	75 13                	jne    801183 <devpipe_read+0x34>
	return i;
  801170:	89 f0                	mov    %esi,%eax
  801172:	eb 02                	jmp    801176 <devpipe_read+0x27>
				return i;
  801174:	89 f0                	mov    %esi,%eax
}
  801176:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801179:	5b                   	pop    %ebx
  80117a:	5e                   	pop    %esi
  80117b:	5f                   	pop    %edi
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    
			sys_yield();
  80117e:	e8 af ef ff ff       	call   800132 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801183:	8b 03                	mov    (%ebx),%eax
  801185:	3b 43 04             	cmp    0x4(%ebx),%eax
  801188:	75 18                	jne    8011a2 <devpipe_read+0x53>
			if (i > 0)
  80118a:	85 f6                	test   %esi,%esi
  80118c:	75 e6                	jne    801174 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  80118e:	89 da                	mov    %ebx,%edx
  801190:	89 f8                	mov    %edi,%eax
  801192:	e8 d4 fe ff ff       	call   80106b <_pipeisclosed>
  801197:	85 c0                	test   %eax,%eax
  801199:	74 e3                	je     80117e <devpipe_read+0x2f>
				return 0;
  80119b:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a0:	eb d4                	jmp    801176 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011a2:	99                   	cltd   
  8011a3:	c1 ea 1b             	shr    $0x1b,%edx
  8011a6:	01 d0                	add    %edx,%eax
  8011a8:	83 e0 1f             	and    $0x1f,%eax
  8011ab:	29 d0                	sub    %edx,%eax
  8011ad:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011b8:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011bb:	83 c6 01             	add    $0x1,%esi
  8011be:	eb ab                	jmp    80116b <devpipe_read+0x1c>

008011c0 <pipe>:
{
  8011c0:	55                   	push   %ebp
  8011c1:	89 e5                	mov    %esp,%ebp
  8011c3:	56                   	push   %esi
  8011c4:	53                   	push   %ebx
  8011c5:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cb:	50                   	push   %eax
  8011cc:	e8 f9 f1 ff ff       	call   8003ca <fd_alloc>
  8011d1:	89 c3                	mov    %eax,%ebx
  8011d3:	83 c4 10             	add    $0x10,%esp
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	0f 88 23 01 00 00    	js     801301 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011de:	83 ec 04             	sub    $0x4,%esp
  8011e1:	68 07 04 00 00       	push   $0x407
  8011e6:	ff 75 f4             	push   -0xc(%ebp)
  8011e9:	6a 00                	push   $0x0
  8011eb:	e8 61 ef ff ff       	call   800151 <sys_page_alloc>
  8011f0:	89 c3                	mov    %eax,%ebx
  8011f2:	83 c4 10             	add    $0x10,%esp
  8011f5:	85 c0                	test   %eax,%eax
  8011f7:	0f 88 04 01 00 00    	js     801301 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  8011fd:	83 ec 0c             	sub    $0xc,%esp
  801200:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801203:	50                   	push   %eax
  801204:	e8 c1 f1 ff ff       	call   8003ca <fd_alloc>
  801209:	89 c3                	mov    %eax,%ebx
  80120b:	83 c4 10             	add    $0x10,%esp
  80120e:	85 c0                	test   %eax,%eax
  801210:	0f 88 db 00 00 00    	js     8012f1 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801216:	83 ec 04             	sub    $0x4,%esp
  801219:	68 07 04 00 00       	push   $0x407
  80121e:	ff 75 f0             	push   -0x10(%ebp)
  801221:	6a 00                	push   $0x0
  801223:	e8 29 ef ff ff       	call   800151 <sys_page_alloc>
  801228:	89 c3                	mov    %eax,%ebx
  80122a:	83 c4 10             	add    $0x10,%esp
  80122d:	85 c0                	test   %eax,%eax
  80122f:	0f 88 bc 00 00 00    	js     8012f1 <pipe+0x131>
	va = fd2data(fd0);
  801235:	83 ec 0c             	sub    $0xc,%esp
  801238:	ff 75 f4             	push   -0xc(%ebp)
  80123b:	e8 73 f1 ff ff       	call   8003b3 <fd2data>
  801240:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801242:	83 c4 0c             	add    $0xc,%esp
  801245:	68 07 04 00 00       	push   $0x407
  80124a:	50                   	push   %eax
  80124b:	6a 00                	push   $0x0
  80124d:	e8 ff ee ff ff       	call   800151 <sys_page_alloc>
  801252:	89 c3                	mov    %eax,%ebx
  801254:	83 c4 10             	add    $0x10,%esp
  801257:	85 c0                	test   %eax,%eax
  801259:	0f 88 82 00 00 00    	js     8012e1 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80125f:	83 ec 0c             	sub    $0xc,%esp
  801262:	ff 75 f0             	push   -0x10(%ebp)
  801265:	e8 49 f1 ff ff       	call   8003b3 <fd2data>
  80126a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801271:	50                   	push   %eax
  801272:	6a 00                	push   $0x0
  801274:	56                   	push   %esi
  801275:	6a 00                	push   $0x0
  801277:	e8 18 ef ff ff       	call   800194 <sys_page_map>
  80127c:	89 c3                	mov    %eax,%ebx
  80127e:	83 c4 20             	add    $0x20,%esp
  801281:	85 c0                	test   %eax,%eax
  801283:	78 4e                	js     8012d3 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801285:	a1 3c 30 80 00       	mov    0x80303c,%eax
  80128a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80128d:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80128f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801292:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801299:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80129c:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80129e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012a8:	83 ec 0c             	sub    $0xc,%esp
  8012ab:	ff 75 f4             	push   -0xc(%ebp)
  8012ae:	e8 f0 f0 ff ff       	call   8003a3 <fd2num>
  8012b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012b8:	83 c4 04             	add    $0x4,%esp
  8012bb:	ff 75 f0             	push   -0x10(%ebp)
  8012be:	e8 e0 f0 ff ff       	call   8003a3 <fd2num>
  8012c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012d1:	eb 2e                	jmp    801301 <pipe+0x141>
	sys_page_unmap(0, va);
  8012d3:	83 ec 08             	sub    $0x8,%esp
  8012d6:	56                   	push   %esi
  8012d7:	6a 00                	push   $0x0
  8012d9:	e8 f8 ee ff ff       	call   8001d6 <sys_page_unmap>
  8012de:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8012e1:	83 ec 08             	sub    $0x8,%esp
  8012e4:	ff 75 f0             	push   -0x10(%ebp)
  8012e7:	6a 00                	push   $0x0
  8012e9:	e8 e8 ee ff ff       	call   8001d6 <sys_page_unmap>
  8012ee:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8012f1:	83 ec 08             	sub    $0x8,%esp
  8012f4:	ff 75 f4             	push   -0xc(%ebp)
  8012f7:	6a 00                	push   $0x0
  8012f9:	e8 d8 ee ff ff       	call   8001d6 <sys_page_unmap>
  8012fe:	83 c4 10             	add    $0x10,%esp
}
  801301:	89 d8                	mov    %ebx,%eax
  801303:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801306:	5b                   	pop    %ebx
  801307:	5e                   	pop    %esi
  801308:	5d                   	pop    %ebp
  801309:	c3                   	ret    

0080130a <pipeisclosed>:
{
  80130a:	55                   	push   %ebp
  80130b:	89 e5                	mov    %esp,%ebp
  80130d:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801310:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801313:	50                   	push   %eax
  801314:	ff 75 08             	push   0x8(%ebp)
  801317:	e8 fe f0 ff ff       	call   80041a <fd_lookup>
  80131c:	83 c4 10             	add    $0x10,%esp
  80131f:	85 c0                	test   %eax,%eax
  801321:	78 18                	js     80133b <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801323:	83 ec 0c             	sub    $0xc,%esp
  801326:	ff 75 f4             	push   -0xc(%ebp)
  801329:	e8 85 f0 ff ff       	call   8003b3 <fd2data>
  80132e:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801330:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801333:	e8 33 fd ff ff       	call   80106b <_pipeisclosed>
  801338:	83 c4 10             	add    $0x10,%esp
}
  80133b:	c9                   	leave  
  80133c:	c3                   	ret    

0080133d <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  80133d:	b8 00 00 00 00       	mov    $0x0,%eax
  801342:	c3                   	ret    

00801343 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801343:	55                   	push   %ebp
  801344:	89 e5                	mov    %esp,%ebp
  801346:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801349:	68 73 23 80 00       	push   $0x802373
  80134e:	ff 75 0c             	push   0xc(%ebp)
  801351:	e8 10 08 00 00       	call   801b66 <strcpy>
	return 0;
}
  801356:	b8 00 00 00 00       	mov    $0x0,%eax
  80135b:	c9                   	leave  
  80135c:	c3                   	ret    

0080135d <devcons_write>:
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	57                   	push   %edi
  801361:	56                   	push   %esi
  801362:	53                   	push   %ebx
  801363:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801369:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80136e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801374:	eb 2e                	jmp    8013a4 <devcons_write+0x47>
		m = n - tot;
  801376:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801379:	29 f3                	sub    %esi,%ebx
  80137b:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801380:	39 c3                	cmp    %eax,%ebx
  801382:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801385:	83 ec 04             	sub    $0x4,%esp
  801388:	53                   	push   %ebx
  801389:	89 f0                	mov    %esi,%eax
  80138b:	03 45 0c             	add    0xc(%ebp),%eax
  80138e:	50                   	push   %eax
  80138f:	57                   	push   %edi
  801390:	e8 67 09 00 00       	call   801cfc <memmove>
		sys_cputs(buf, m);
  801395:	83 c4 08             	add    $0x8,%esp
  801398:	53                   	push   %ebx
  801399:	57                   	push   %edi
  80139a:	e8 f6 ec ff ff       	call   800095 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80139f:	01 de                	add    %ebx,%esi
  8013a1:	83 c4 10             	add    $0x10,%esp
  8013a4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013a7:	72 cd                	jb     801376 <devcons_write+0x19>
}
  8013a9:	89 f0                	mov    %esi,%eax
  8013ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013ae:	5b                   	pop    %ebx
  8013af:	5e                   	pop    %esi
  8013b0:	5f                   	pop    %edi
  8013b1:	5d                   	pop    %ebp
  8013b2:	c3                   	ret    

008013b3 <devcons_read>:
{
  8013b3:	55                   	push   %ebp
  8013b4:	89 e5                	mov    %esp,%ebp
  8013b6:	83 ec 08             	sub    $0x8,%esp
  8013b9:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8013be:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013c2:	75 07                	jne    8013cb <devcons_read+0x18>
  8013c4:	eb 1f                	jmp    8013e5 <devcons_read+0x32>
		sys_yield();
  8013c6:	e8 67 ed ff ff       	call   800132 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8013cb:	e8 e3 ec ff ff       	call   8000b3 <sys_cgetc>
  8013d0:	85 c0                	test   %eax,%eax
  8013d2:	74 f2                	je     8013c6 <devcons_read+0x13>
	if (c < 0)
  8013d4:	78 0f                	js     8013e5 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8013d6:	83 f8 04             	cmp    $0x4,%eax
  8013d9:	74 0c                	je     8013e7 <devcons_read+0x34>
	*(char*)vbuf = c;
  8013db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013de:	88 02                	mov    %al,(%edx)
	return 1;
  8013e0:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8013e5:	c9                   	leave  
  8013e6:	c3                   	ret    
		return 0;
  8013e7:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ec:	eb f7                	jmp    8013e5 <devcons_read+0x32>

008013ee <cputchar>:
{
  8013ee:	55                   	push   %ebp
  8013ef:	89 e5                	mov    %esp,%ebp
  8013f1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f7:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8013fa:	6a 01                	push   $0x1
  8013fc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8013ff:	50                   	push   %eax
  801400:	e8 90 ec ff ff       	call   800095 <sys_cputs>
}
  801405:	83 c4 10             	add    $0x10,%esp
  801408:	c9                   	leave  
  801409:	c3                   	ret    

0080140a <getchar>:
{
  80140a:	55                   	push   %ebp
  80140b:	89 e5                	mov    %esp,%ebp
  80140d:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801410:	6a 01                	push   $0x1
  801412:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801415:	50                   	push   %eax
  801416:	6a 00                	push   $0x0
  801418:	e8 66 f2 ff ff       	call   800683 <read>
	if (r < 0)
  80141d:	83 c4 10             	add    $0x10,%esp
  801420:	85 c0                	test   %eax,%eax
  801422:	78 06                	js     80142a <getchar+0x20>
	if (r < 1)
  801424:	74 06                	je     80142c <getchar+0x22>
	return c;
  801426:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80142a:	c9                   	leave  
  80142b:	c3                   	ret    
		return -E_EOF;
  80142c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801431:	eb f7                	jmp    80142a <getchar+0x20>

00801433 <iscons>:
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801439:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143c:	50                   	push   %eax
  80143d:	ff 75 08             	push   0x8(%ebp)
  801440:	e8 d5 ef ff ff       	call   80041a <fd_lookup>
  801445:	83 c4 10             	add    $0x10,%esp
  801448:	85 c0                	test   %eax,%eax
  80144a:	78 11                	js     80145d <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80144c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80144f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801455:	39 10                	cmp    %edx,(%eax)
  801457:	0f 94 c0             	sete   %al
  80145a:	0f b6 c0             	movzbl %al,%eax
}
  80145d:	c9                   	leave  
  80145e:	c3                   	ret    

0080145f <opencons>:
{
  80145f:	55                   	push   %ebp
  801460:	89 e5                	mov    %esp,%ebp
  801462:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801465:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801468:	50                   	push   %eax
  801469:	e8 5c ef ff ff       	call   8003ca <fd_alloc>
  80146e:	83 c4 10             	add    $0x10,%esp
  801471:	85 c0                	test   %eax,%eax
  801473:	78 3a                	js     8014af <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801475:	83 ec 04             	sub    $0x4,%esp
  801478:	68 07 04 00 00       	push   $0x407
  80147d:	ff 75 f4             	push   -0xc(%ebp)
  801480:	6a 00                	push   $0x0
  801482:	e8 ca ec ff ff       	call   800151 <sys_page_alloc>
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 21                	js     8014af <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  80148e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801491:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801497:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801499:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014a3:	83 ec 0c             	sub    $0xc,%esp
  8014a6:	50                   	push   %eax
  8014a7:	e8 f7 ee ff ff       	call   8003a3 <fd2num>
  8014ac:	83 c4 10             	add    $0x10,%esp
}
  8014af:	c9                   	leave  
  8014b0:	c3                   	ret    

008014b1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014b1:	55                   	push   %ebp
  8014b2:	89 e5                	mov    %esp,%ebp
  8014b4:	56                   	push   %esi
  8014b5:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014b6:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014b9:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014bf:	e8 4f ec ff ff       	call   800113 <sys_getenvid>
  8014c4:	83 ec 0c             	sub    $0xc,%esp
  8014c7:	ff 75 0c             	push   0xc(%ebp)
  8014ca:	ff 75 08             	push   0x8(%ebp)
  8014cd:	56                   	push   %esi
  8014ce:	50                   	push   %eax
  8014cf:	68 80 23 80 00       	push   $0x802380
  8014d4:	e8 b3 00 00 00       	call   80158c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014d9:	83 c4 18             	add    $0x18,%esp
  8014dc:	53                   	push   %ebx
  8014dd:	ff 75 10             	push   0x10(%ebp)
  8014e0:	e8 56 00 00 00       	call   80153b <vcprintf>
	cprintf("\n");
  8014e5:	c7 04 24 6c 23 80 00 	movl   $0x80236c,(%esp)
  8014ec:	e8 9b 00 00 00       	call   80158c <cprintf>
  8014f1:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014f4:	cc                   	int3   
  8014f5:	eb fd                	jmp    8014f4 <_panic+0x43>

008014f7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8014f7:	55                   	push   %ebp
  8014f8:	89 e5                	mov    %esp,%ebp
  8014fa:	53                   	push   %ebx
  8014fb:	83 ec 04             	sub    $0x4,%esp
  8014fe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801501:	8b 13                	mov    (%ebx),%edx
  801503:	8d 42 01             	lea    0x1(%edx),%eax
  801506:	89 03                	mov    %eax,(%ebx)
  801508:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80150b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80150f:	3d ff 00 00 00       	cmp    $0xff,%eax
  801514:	74 09                	je     80151f <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801516:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80151a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80151d:	c9                   	leave  
  80151e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80151f:	83 ec 08             	sub    $0x8,%esp
  801522:	68 ff 00 00 00       	push   $0xff
  801527:	8d 43 08             	lea    0x8(%ebx),%eax
  80152a:	50                   	push   %eax
  80152b:	e8 65 eb ff ff       	call   800095 <sys_cputs>
		b->idx = 0;
  801530:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801536:	83 c4 10             	add    $0x10,%esp
  801539:	eb db                	jmp    801516 <putch+0x1f>

0080153b <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801544:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80154b:	00 00 00 
	b.cnt = 0;
  80154e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801555:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801558:	ff 75 0c             	push   0xc(%ebp)
  80155b:	ff 75 08             	push   0x8(%ebp)
  80155e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801564:	50                   	push   %eax
  801565:	68 f7 14 80 00       	push   $0x8014f7
  80156a:	e8 14 01 00 00       	call   801683 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80156f:	83 c4 08             	add    $0x8,%esp
  801572:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  801578:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80157e:	50                   	push   %eax
  80157f:	e8 11 eb ff ff       	call   800095 <sys_cputs>

	return b.cnt;
}
  801584:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80158a:	c9                   	leave  
  80158b:	c3                   	ret    

0080158c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80158c:	55                   	push   %ebp
  80158d:	89 e5                	mov    %esp,%ebp
  80158f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801592:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801595:	50                   	push   %eax
  801596:	ff 75 08             	push   0x8(%ebp)
  801599:	e8 9d ff ff ff       	call   80153b <vcprintf>
	va_end(ap);

	return cnt;
}
  80159e:	c9                   	leave  
  80159f:	c3                   	ret    

008015a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	57                   	push   %edi
  8015a4:	56                   	push   %esi
  8015a5:	53                   	push   %ebx
  8015a6:	83 ec 1c             	sub    $0x1c,%esp
  8015a9:	89 c7                	mov    %eax,%edi
  8015ab:	89 d6                	mov    %edx,%esi
  8015ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b3:	89 d1                	mov    %edx,%ecx
  8015b5:	89 c2                	mov    %eax,%edx
  8015b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8015bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8015c0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015c6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8015cd:	39 c2                	cmp    %eax,%edx
  8015cf:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8015d2:	72 3e                	jb     801612 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015d4:	83 ec 0c             	sub    $0xc,%esp
  8015d7:	ff 75 18             	push   0x18(%ebp)
  8015da:	83 eb 01             	sub    $0x1,%ebx
  8015dd:	53                   	push   %ebx
  8015de:	50                   	push   %eax
  8015df:	83 ec 08             	sub    $0x8,%esp
  8015e2:	ff 75 e4             	push   -0x1c(%ebp)
  8015e5:	ff 75 e0             	push   -0x20(%ebp)
  8015e8:	ff 75 dc             	push   -0x24(%ebp)
  8015eb:	ff 75 d8             	push   -0x28(%ebp)
  8015ee:	e8 ed 09 00 00       	call   801fe0 <__udivdi3>
  8015f3:	83 c4 18             	add    $0x18,%esp
  8015f6:	52                   	push   %edx
  8015f7:	50                   	push   %eax
  8015f8:	89 f2                	mov    %esi,%edx
  8015fa:	89 f8                	mov    %edi,%eax
  8015fc:	e8 9f ff ff ff       	call   8015a0 <printnum>
  801601:	83 c4 20             	add    $0x20,%esp
  801604:	eb 13                	jmp    801619 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801606:	83 ec 08             	sub    $0x8,%esp
  801609:	56                   	push   %esi
  80160a:	ff 75 18             	push   0x18(%ebp)
  80160d:	ff d7                	call   *%edi
  80160f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801612:	83 eb 01             	sub    $0x1,%ebx
  801615:	85 db                	test   %ebx,%ebx
  801617:	7f ed                	jg     801606 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801619:	83 ec 08             	sub    $0x8,%esp
  80161c:	56                   	push   %esi
  80161d:	83 ec 04             	sub    $0x4,%esp
  801620:	ff 75 e4             	push   -0x1c(%ebp)
  801623:	ff 75 e0             	push   -0x20(%ebp)
  801626:	ff 75 dc             	push   -0x24(%ebp)
  801629:	ff 75 d8             	push   -0x28(%ebp)
  80162c:	e8 cf 0a 00 00       	call   802100 <__umoddi3>
  801631:	83 c4 14             	add    $0x14,%esp
  801634:	0f be 80 a3 23 80 00 	movsbl 0x8023a3(%eax),%eax
  80163b:	50                   	push   %eax
  80163c:	ff d7                	call   *%edi
}
  80163e:	83 c4 10             	add    $0x10,%esp
  801641:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801644:	5b                   	pop    %ebx
  801645:	5e                   	pop    %esi
  801646:	5f                   	pop    %edi
  801647:	5d                   	pop    %ebp
  801648:	c3                   	ret    

00801649 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80164f:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801653:	8b 10                	mov    (%eax),%edx
  801655:	3b 50 04             	cmp    0x4(%eax),%edx
  801658:	73 0a                	jae    801664 <sprintputch+0x1b>
		*b->buf++ = ch;
  80165a:	8d 4a 01             	lea    0x1(%edx),%ecx
  80165d:	89 08                	mov    %ecx,(%eax)
  80165f:	8b 45 08             	mov    0x8(%ebp),%eax
  801662:	88 02                	mov    %al,(%edx)
}
  801664:	5d                   	pop    %ebp
  801665:	c3                   	ret    

00801666 <printfmt>:
{
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80166c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80166f:	50                   	push   %eax
  801670:	ff 75 10             	push   0x10(%ebp)
  801673:	ff 75 0c             	push   0xc(%ebp)
  801676:	ff 75 08             	push   0x8(%ebp)
  801679:	e8 05 00 00 00       	call   801683 <vprintfmt>
}
  80167e:	83 c4 10             	add    $0x10,%esp
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <vprintfmt>:
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	57                   	push   %edi
  801687:	56                   	push   %esi
  801688:	53                   	push   %ebx
  801689:	83 ec 3c             	sub    $0x3c,%esp
  80168c:	8b 75 08             	mov    0x8(%ebp),%esi
  80168f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801692:	8b 7d 10             	mov    0x10(%ebp),%edi
  801695:	eb 0a                	jmp    8016a1 <vprintfmt+0x1e>
			putch(ch, putdat);
  801697:	83 ec 08             	sub    $0x8,%esp
  80169a:	53                   	push   %ebx
  80169b:	50                   	push   %eax
  80169c:	ff d6                	call   *%esi
  80169e:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016a1:	83 c7 01             	add    $0x1,%edi
  8016a4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016a8:	83 f8 25             	cmp    $0x25,%eax
  8016ab:	74 0c                	je     8016b9 <vprintfmt+0x36>
			if (ch == '\0')
  8016ad:	85 c0                	test   %eax,%eax
  8016af:	75 e6                	jne    801697 <vprintfmt+0x14>
}
  8016b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b4:	5b                   	pop    %ebx
  8016b5:	5e                   	pop    %esi
  8016b6:	5f                   	pop    %edi
  8016b7:	5d                   	pop    %ebp
  8016b8:	c3                   	ret    
		padc = ' ';
  8016b9:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8016bd:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8016c4:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8016cb:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8016d2:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8016d7:	8d 47 01             	lea    0x1(%edi),%eax
  8016da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016dd:	0f b6 17             	movzbl (%edi),%edx
  8016e0:	8d 42 dd             	lea    -0x23(%edx),%eax
  8016e3:	3c 55                	cmp    $0x55,%al
  8016e5:	0f 87 bb 03 00 00    	ja     801aa6 <vprintfmt+0x423>
  8016eb:	0f b6 c0             	movzbl %al,%eax
  8016ee:	ff 24 85 e0 24 80 00 	jmp    *0x8024e0(,%eax,4)
  8016f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8016f8:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8016fc:	eb d9                	jmp    8016d7 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8016fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801701:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801705:	eb d0                	jmp    8016d7 <vprintfmt+0x54>
  801707:	0f b6 d2             	movzbl %dl,%edx
  80170a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80170d:	b8 00 00 00 00       	mov    $0x0,%eax
  801712:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801715:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801718:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80171c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80171f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801722:	83 f9 09             	cmp    $0x9,%ecx
  801725:	77 55                	ja     80177c <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  801727:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80172a:	eb e9                	jmp    801715 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80172c:	8b 45 14             	mov    0x14(%ebp),%eax
  80172f:	8b 00                	mov    (%eax),%eax
  801731:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801734:	8b 45 14             	mov    0x14(%ebp),%eax
  801737:	8d 40 04             	lea    0x4(%eax),%eax
  80173a:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80173d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801740:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801744:	79 91                	jns    8016d7 <vprintfmt+0x54>
				width = precision, precision = -1;
  801746:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801749:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80174c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801753:	eb 82                	jmp    8016d7 <vprintfmt+0x54>
  801755:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801758:	85 d2                	test   %edx,%edx
  80175a:	b8 00 00 00 00       	mov    $0x0,%eax
  80175f:	0f 49 c2             	cmovns %edx,%eax
  801762:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801765:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801768:	e9 6a ff ff ff       	jmp    8016d7 <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  80176d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801770:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801777:	e9 5b ff ff ff       	jmp    8016d7 <vprintfmt+0x54>
  80177c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80177f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801782:	eb bc                	jmp    801740 <vprintfmt+0xbd>
			lflag++;
  801784:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801787:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80178a:	e9 48 ff ff ff       	jmp    8016d7 <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  80178f:	8b 45 14             	mov    0x14(%ebp),%eax
  801792:	8d 78 04             	lea    0x4(%eax),%edi
  801795:	83 ec 08             	sub    $0x8,%esp
  801798:	53                   	push   %ebx
  801799:	ff 30                	push   (%eax)
  80179b:	ff d6                	call   *%esi
			break;
  80179d:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017a0:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017a3:	e9 9d 02 00 00       	jmp    801a45 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8017a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ab:	8d 78 04             	lea    0x4(%eax),%edi
  8017ae:	8b 10                	mov    (%eax),%edx
  8017b0:	89 d0                	mov    %edx,%eax
  8017b2:	f7 d8                	neg    %eax
  8017b4:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017b7:	83 f8 0f             	cmp    $0xf,%eax
  8017ba:	7f 23                	jg     8017df <vprintfmt+0x15c>
  8017bc:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  8017c3:	85 d2                	test   %edx,%edx
  8017c5:	74 18                	je     8017df <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8017c7:	52                   	push   %edx
  8017c8:	68 01 23 80 00       	push   $0x802301
  8017cd:	53                   	push   %ebx
  8017ce:	56                   	push   %esi
  8017cf:	e8 92 fe ff ff       	call   801666 <printfmt>
  8017d4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8017d7:	89 7d 14             	mov    %edi,0x14(%ebp)
  8017da:	e9 66 02 00 00       	jmp    801a45 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8017df:	50                   	push   %eax
  8017e0:	68 bb 23 80 00       	push   $0x8023bb
  8017e5:	53                   	push   %ebx
  8017e6:	56                   	push   %esi
  8017e7:	e8 7a fe ff ff       	call   801666 <printfmt>
  8017ec:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8017ef:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8017f2:	e9 4e 02 00 00       	jmp    801a45 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8017f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8017fa:	83 c0 04             	add    $0x4,%eax
  8017fd:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801800:	8b 45 14             	mov    0x14(%ebp),%eax
  801803:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801805:	85 d2                	test   %edx,%edx
  801807:	b8 b4 23 80 00       	mov    $0x8023b4,%eax
  80180c:	0f 45 c2             	cmovne %edx,%eax
  80180f:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801812:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801816:	7e 06                	jle    80181e <vprintfmt+0x19b>
  801818:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80181c:	75 0d                	jne    80182b <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  80181e:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801821:	89 c7                	mov    %eax,%edi
  801823:	03 45 e0             	add    -0x20(%ebp),%eax
  801826:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801829:	eb 55                	jmp    801880 <vprintfmt+0x1fd>
  80182b:	83 ec 08             	sub    $0x8,%esp
  80182e:	ff 75 d8             	push   -0x28(%ebp)
  801831:	ff 75 cc             	push   -0x34(%ebp)
  801834:	e8 0a 03 00 00       	call   801b43 <strnlen>
  801839:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80183c:	29 c1                	sub    %eax,%ecx
  80183e:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801841:	83 c4 10             	add    $0x10,%esp
  801844:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  801846:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80184a:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80184d:	eb 0f                	jmp    80185e <vprintfmt+0x1db>
					putch(padc, putdat);
  80184f:	83 ec 08             	sub    $0x8,%esp
  801852:	53                   	push   %ebx
  801853:	ff 75 e0             	push   -0x20(%ebp)
  801856:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801858:	83 ef 01             	sub    $0x1,%edi
  80185b:	83 c4 10             	add    $0x10,%esp
  80185e:	85 ff                	test   %edi,%edi
  801860:	7f ed                	jg     80184f <vprintfmt+0x1cc>
  801862:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801865:	85 d2                	test   %edx,%edx
  801867:	b8 00 00 00 00       	mov    $0x0,%eax
  80186c:	0f 49 c2             	cmovns %edx,%eax
  80186f:	29 c2                	sub    %eax,%edx
  801871:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801874:	eb a8                	jmp    80181e <vprintfmt+0x19b>
					putch(ch, putdat);
  801876:	83 ec 08             	sub    $0x8,%esp
  801879:	53                   	push   %ebx
  80187a:	52                   	push   %edx
  80187b:	ff d6                	call   *%esi
  80187d:	83 c4 10             	add    $0x10,%esp
  801880:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801883:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801885:	83 c7 01             	add    $0x1,%edi
  801888:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80188c:	0f be d0             	movsbl %al,%edx
  80188f:	85 d2                	test   %edx,%edx
  801891:	74 4b                	je     8018de <vprintfmt+0x25b>
  801893:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801897:	78 06                	js     80189f <vprintfmt+0x21c>
  801899:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80189d:	78 1e                	js     8018bd <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  80189f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018a3:	74 d1                	je     801876 <vprintfmt+0x1f3>
  8018a5:	0f be c0             	movsbl %al,%eax
  8018a8:	83 e8 20             	sub    $0x20,%eax
  8018ab:	83 f8 5e             	cmp    $0x5e,%eax
  8018ae:	76 c6                	jbe    801876 <vprintfmt+0x1f3>
					putch('?', putdat);
  8018b0:	83 ec 08             	sub    $0x8,%esp
  8018b3:	53                   	push   %ebx
  8018b4:	6a 3f                	push   $0x3f
  8018b6:	ff d6                	call   *%esi
  8018b8:	83 c4 10             	add    $0x10,%esp
  8018bb:	eb c3                	jmp    801880 <vprintfmt+0x1fd>
  8018bd:	89 cf                	mov    %ecx,%edi
  8018bf:	eb 0e                	jmp    8018cf <vprintfmt+0x24c>
				putch(' ', putdat);
  8018c1:	83 ec 08             	sub    $0x8,%esp
  8018c4:	53                   	push   %ebx
  8018c5:	6a 20                	push   $0x20
  8018c7:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8018c9:	83 ef 01             	sub    $0x1,%edi
  8018cc:	83 c4 10             	add    $0x10,%esp
  8018cf:	85 ff                	test   %edi,%edi
  8018d1:	7f ee                	jg     8018c1 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8018d3:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8018d6:	89 45 14             	mov    %eax,0x14(%ebp)
  8018d9:	e9 67 01 00 00       	jmp    801a45 <vprintfmt+0x3c2>
  8018de:	89 cf                	mov    %ecx,%edi
  8018e0:	eb ed                	jmp    8018cf <vprintfmt+0x24c>
	if (lflag >= 2)
  8018e2:	83 f9 01             	cmp    $0x1,%ecx
  8018e5:	7f 1b                	jg     801902 <vprintfmt+0x27f>
	else if (lflag)
  8018e7:	85 c9                	test   %ecx,%ecx
  8018e9:	74 63                	je     80194e <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8018eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8018ee:	8b 00                	mov    (%eax),%eax
  8018f0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018f3:	99                   	cltd   
  8018f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8018f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8018fa:	8d 40 04             	lea    0x4(%eax),%eax
  8018fd:	89 45 14             	mov    %eax,0x14(%ebp)
  801900:	eb 17                	jmp    801919 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801902:	8b 45 14             	mov    0x14(%ebp),%eax
  801905:	8b 50 04             	mov    0x4(%eax),%edx
  801908:	8b 00                	mov    (%eax),%eax
  80190a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80190d:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801910:	8b 45 14             	mov    0x14(%ebp),%eax
  801913:	8d 40 08             	lea    0x8(%eax),%eax
  801916:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801919:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80191c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  80191f:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801924:	85 c9                	test   %ecx,%ecx
  801926:	0f 89 ff 00 00 00    	jns    801a2b <vprintfmt+0x3a8>
				putch('-', putdat);
  80192c:	83 ec 08             	sub    $0x8,%esp
  80192f:	53                   	push   %ebx
  801930:	6a 2d                	push   $0x2d
  801932:	ff d6                	call   *%esi
				num = -(long long) num;
  801934:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801937:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80193a:	f7 da                	neg    %edx
  80193c:	83 d1 00             	adc    $0x0,%ecx
  80193f:	f7 d9                	neg    %ecx
  801941:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801944:	bf 0a 00 00 00       	mov    $0xa,%edi
  801949:	e9 dd 00 00 00       	jmp    801a2b <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  80194e:	8b 45 14             	mov    0x14(%ebp),%eax
  801951:	8b 00                	mov    (%eax),%eax
  801953:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801956:	99                   	cltd   
  801957:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80195a:	8b 45 14             	mov    0x14(%ebp),%eax
  80195d:	8d 40 04             	lea    0x4(%eax),%eax
  801960:	89 45 14             	mov    %eax,0x14(%ebp)
  801963:	eb b4                	jmp    801919 <vprintfmt+0x296>
	if (lflag >= 2)
  801965:	83 f9 01             	cmp    $0x1,%ecx
  801968:	7f 1e                	jg     801988 <vprintfmt+0x305>
	else if (lflag)
  80196a:	85 c9                	test   %ecx,%ecx
  80196c:	74 32                	je     8019a0 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  80196e:	8b 45 14             	mov    0x14(%ebp),%eax
  801971:	8b 10                	mov    (%eax),%edx
  801973:	b9 00 00 00 00       	mov    $0x0,%ecx
  801978:	8d 40 04             	lea    0x4(%eax),%eax
  80197b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80197e:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  801983:	e9 a3 00 00 00       	jmp    801a2b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801988:	8b 45 14             	mov    0x14(%ebp),%eax
  80198b:	8b 10                	mov    (%eax),%edx
  80198d:	8b 48 04             	mov    0x4(%eax),%ecx
  801990:	8d 40 08             	lea    0x8(%eax),%eax
  801993:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801996:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80199b:	e9 8b 00 00 00       	jmp    801a2b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a3:	8b 10                	mov    (%eax),%edx
  8019a5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019aa:	8d 40 04             	lea    0x4(%eax),%eax
  8019ad:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019b0:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8019b5:	eb 74                	jmp    801a2b <vprintfmt+0x3a8>
	if (lflag >= 2)
  8019b7:	83 f9 01             	cmp    $0x1,%ecx
  8019ba:	7f 1b                	jg     8019d7 <vprintfmt+0x354>
	else if (lflag)
  8019bc:	85 c9                	test   %ecx,%ecx
  8019be:	74 2c                	je     8019ec <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8019c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c3:	8b 10                	mov    (%eax),%edx
  8019c5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019ca:	8d 40 04             	lea    0x4(%eax),%eax
  8019cd:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019d0:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8019d5:	eb 54                	jmp    801a2b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8019d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8019da:	8b 10                	mov    (%eax),%edx
  8019dc:	8b 48 04             	mov    0x4(%eax),%ecx
  8019df:	8d 40 08             	lea    0x8(%eax),%eax
  8019e2:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019e5:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8019ea:	eb 3f                	jmp    801a2b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ef:	8b 10                	mov    (%eax),%edx
  8019f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019f6:	8d 40 04             	lea    0x4(%eax),%eax
  8019f9:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019fc:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801a01:	eb 28                	jmp    801a2b <vprintfmt+0x3a8>
			putch('0', putdat);
  801a03:	83 ec 08             	sub    $0x8,%esp
  801a06:	53                   	push   %ebx
  801a07:	6a 30                	push   $0x30
  801a09:	ff d6                	call   *%esi
			putch('x', putdat);
  801a0b:	83 c4 08             	add    $0x8,%esp
  801a0e:	53                   	push   %ebx
  801a0f:	6a 78                	push   $0x78
  801a11:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a13:	8b 45 14             	mov    0x14(%ebp),%eax
  801a16:	8b 10                	mov    (%eax),%edx
  801a18:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a1d:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a20:	8d 40 04             	lea    0x4(%eax),%eax
  801a23:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a26:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801a2b:	83 ec 0c             	sub    $0xc,%esp
  801a2e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801a32:	50                   	push   %eax
  801a33:	ff 75 e0             	push   -0x20(%ebp)
  801a36:	57                   	push   %edi
  801a37:	51                   	push   %ecx
  801a38:	52                   	push   %edx
  801a39:	89 da                	mov    %ebx,%edx
  801a3b:	89 f0                	mov    %esi,%eax
  801a3d:	e8 5e fb ff ff       	call   8015a0 <printnum>
			break;
  801a42:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801a45:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a48:	e9 54 fc ff ff       	jmp    8016a1 <vprintfmt+0x1e>
	if (lflag >= 2)
  801a4d:	83 f9 01             	cmp    $0x1,%ecx
  801a50:	7f 1b                	jg     801a6d <vprintfmt+0x3ea>
	else if (lflag)
  801a52:	85 c9                	test   %ecx,%ecx
  801a54:	74 2c                	je     801a82 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801a56:	8b 45 14             	mov    0x14(%ebp),%eax
  801a59:	8b 10                	mov    (%eax),%edx
  801a5b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a60:	8d 40 04             	lea    0x4(%eax),%eax
  801a63:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a66:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  801a6b:	eb be                	jmp    801a2b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801a6d:	8b 45 14             	mov    0x14(%ebp),%eax
  801a70:	8b 10                	mov    (%eax),%edx
  801a72:	8b 48 04             	mov    0x4(%eax),%ecx
  801a75:	8d 40 08             	lea    0x8(%eax),%eax
  801a78:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a7b:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  801a80:	eb a9                	jmp    801a2b <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801a82:	8b 45 14             	mov    0x14(%ebp),%eax
  801a85:	8b 10                	mov    (%eax),%edx
  801a87:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a8c:	8d 40 04             	lea    0x4(%eax),%eax
  801a8f:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a92:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  801a97:	eb 92                	jmp    801a2b <vprintfmt+0x3a8>
			putch(ch, putdat);
  801a99:	83 ec 08             	sub    $0x8,%esp
  801a9c:	53                   	push   %ebx
  801a9d:	6a 25                	push   $0x25
  801a9f:	ff d6                	call   *%esi
			break;
  801aa1:	83 c4 10             	add    $0x10,%esp
  801aa4:	eb 9f                	jmp    801a45 <vprintfmt+0x3c2>
			putch('%', putdat);
  801aa6:	83 ec 08             	sub    $0x8,%esp
  801aa9:	53                   	push   %ebx
  801aaa:	6a 25                	push   $0x25
  801aac:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	89 f8                	mov    %edi,%eax
  801ab3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801ab7:	74 05                	je     801abe <vprintfmt+0x43b>
  801ab9:	83 e8 01             	sub    $0x1,%eax
  801abc:	eb f5                	jmp    801ab3 <vprintfmt+0x430>
  801abe:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ac1:	eb 82                	jmp    801a45 <vprintfmt+0x3c2>

00801ac3 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	83 ec 18             	sub    $0x18,%esp
  801ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  801acc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801acf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ad2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ad6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ad9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ae0:	85 c0                	test   %eax,%eax
  801ae2:	74 26                	je     801b0a <vsnprintf+0x47>
  801ae4:	85 d2                	test   %edx,%edx
  801ae6:	7e 22                	jle    801b0a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801ae8:	ff 75 14             	push   0x14(%ebp)
  801aeb:	ff 75 10             	push   0x10(%ebp)
  801aee:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801af1:	50                   	push   %eax
  801af2:	68 49 16 80 00       	push   $0x801649
  801af7:	e8 87 fb ff ff       	call   801683 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801afc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801aff:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b05:	83 c4 10             	add    $0x10,%esp
}
  801b08:	c9                   	leave  
  801b09:	c3                   	ret    
		return -E_INVAL;
  801b0a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b0f:	eb f7                	jmp    801b08 <vsnprintf+0x45>

00801b11 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b11:	55                   	push   %ebp
  801b12:	89 e5                	mov    %esp,%ebp
  801b14:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b17:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b1a:	50                   	push   %eax
  801b1b:	ff 75 10             	push   0x10(%ebp)
  801b1e:	ff 75 0c             	push   0xc(%ebp)
  801b21:	ff 75 08             	push   0x8(%ebp)
  801b24:	e8 9a ff ff ff       	call   801ac3 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b29:	c9                   	leave  
  801b2a:	c3                   	ret    

00801b2b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b2b:	55                   	push   %ebp
  801b2c:	89 e5                	mov    %esp,%ebp
  801b2e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b31:	b8 00 00 00 00       	mov    $0x0,%eax
  801b36:	eb 03                	jmp    801b3b <strlen+0x10>
		n++;
  801b38:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801b3b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b3f:	75 f7                	jne    801b38 <strlen+0xd>
	return n;
}
  801b41:	5d                   	pop    %ebp
  801b42:	c3                   	ret    

00801b43 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b43:	55                   	push   %ebp
  801b44:	89 e5                	mov    %esp,%ebp
  801b46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b49:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b51:	eb 03                	jmp    801b56 <strnlen+0x13>
		n++;
  801b53:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b56:	39 d0                	cmp    %edx,%eax
  801b58:	74 08                	je     801b62 <strnlen+0x1f>
  801b5a:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801b5e:	75 f3                	jne    801b53 <strnlen+0x10>
  801b60:	89 c2                	mov    %eax,%edx
	return n;
}
  801b62:	89 d0                	mov    %edx,%eax
  801b64:	5d                   	pop    %ebp
  801b65:	c3                   	ret    

00801b66 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b66:	55                   	push   %ebp
  801b67:	89 e5                	mov    %esp,%ebp
  801b69:	53                   	push   %ebx
  801b6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b6d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b70:	b8 00 00 00 00       	mov    $0x0,%eax
  801b75:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801b79:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801b7c:	83 c0 01             	add    $0x1,%eax
  801b7f:	84 d2                	test   %dl,%dl
  801b81:	75 f2                	jne    801b75 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801b83:	89 c8                	mov    %ecx,%eax
  801b85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b88:	c9                   	leave  
  801b89:	c3                   	ret    

00801b8a <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b8a:	55                   	push   %ebp
  801b8b:	89 e5                	mov    %esp,%ebp
  801b8d:	53                   	push   %ebx
  801b8e:	83 ec 10             	sub    $0x10,%esp
  801b91:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b94:	53                   	push   %ebx
  801b95:	e8 91 ff ff ff       	call   801b2b <strlen>
  801b9a:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801b9d:	ff 75 0c             	push   0xc(%ebp)
  801ba0:	01 d8                	add    %ebx,%eax
  801ba2:	50                   	push   %eax
  801ba3:	e8 be ff ff ff       	call   801b66 <strcpy>
	return dst;
}
  801ba8:	89 d8                	mov    %ebx,%eax
  801baa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bad:	c9                   	leave  
  801bae:	c3                   	ret    

00801baf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801baf:	55                   	push   %ebp
  801bb0:	89 e5                	mov    %esp,%ebp
  801bb2:	56                   	push   %esi
  801bb3:	53                   	push   %ebx
  801bb4:	8b 75 08             	mov    0x8(%ebp),%esi
  801bb7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bba:	89 f3                	mov    %esi,%ebx
  801bbc:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bbf:	89 f0                	mov    %esi,%eax
  801bc1:	eb 0f                	jmp    801bd2 <strncpy+0x23>
		*dst++ = *src;
  801bc3:	83 c0 01             	add    $0x1,%eax
  801bc6:	0f b6 0a             	movzbl (%edx),%ecx
  801bc9:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bcc:	80 f9 01             	cmp    $0x1,%cl
  801bcf:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801bd2:	39 d8                	cmp    %ebx,%eax
  801bd4:	75 ed                	jne    801bc3 <strncpy+0x14>
	}
	return ret;
}
  801bd6:	89 f0                	mov    %esi,%eax
  801bd8:	5b                   	pop    %ebx
  801bd9:	5e                   	pop    %esi
  801bda:	5d                   	pop    %ebp
  801bdb:	c3                   	ret    

00801bdc <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bdc:	55                   	push   %ebp
  801bdd:	89 e5                	mov    %esp,%ebp
  801bdf:	56                   	push   %esi
  801be0:	53                   	push   %ebx
  801be1:	8b 75 08             	mov    0x8(%ebp),%esi
  801be4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801be7:	8b 55 10             	mov    0x10(%ebp),%edx
  801bea:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bec:	85 d2                	test   %edx,%edx
  801bee:	74 21                	je     801c11 <strlcpy+0x35>
  801bf0:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bf4:	89 f2                	mov    %esi,%edx
  801bf6:	eb 09                	jmp    801c01 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bf8:	83 c1 01             	add    $0x1,%ecx
  801bfb:	83 c2 01             	add    $0x1,%edx
  801bfe:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801c01:	39 c2                	cmp    %eax,%edx
  801c03:	74 09                	je     801c0e <strlcpy+0x32>
  801c05:	0f b6 19             	movzbl (%ecx),%ebx
  801c08:	84 db                	test   %bl,%bl
  801c0a:	75 ec                	jne    801bf8 <strlcpy+0x1c>
  801c0c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801c0e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c11:	29 f0                	sub    %esi,%eax
}
  801c13:	5b                   	pop    %ebx
  801c14:	5e                   	pop    %esi
  801c15:	5d                   	pop    %ebp
  801c16:	c3                   	ret    

00801c17 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c17:	55                   	push   %ebp
  801c18:	89 e5                	mov    %esp,%ebp
  801c1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c1d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c20:	eb 06                	jmp    801c28 <strcmp+0x11>
		p++, q++;
  801c22:	83 c1 01             	add    $0x1,%ecx
  801c25:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801c28:	0f b6 01             	movzbl (%ecx),%eax
  801c2b:	84 c0                	test   %al,%al
  801c2d:	74 04                	je     801c33 <strcmp+0x1c>
  801c2f:	3a 02                	cmp    (%edx),%al
  801c31:	74 ef                	je     801c22 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c33:	0f b6 c0             	movzbl %al,%eax
  801c36:	0f b6 12             	movzbl (%edx),%edx
  801c39:	29 d0                	sub    %edx,%eax
}
  801c3b:	5d                   	pop    %ebp
  801c3c:	c3                   	ret    

00801c3d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c3d:	55                   	push   %ebp
  801c3e:	89 e5                	mov    %esp,%ebp
  801c40:	53                   	push   %ebx
  801c41:	8b 45 08             	mov    0x8(%ebp),%eax
  801c44:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c47:	89 c3                	mov    %eax,%ebx
  801c49:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c4c:	eb 06                	jmp    801c54 <strncmp+0x17>
		n--, p++, q++;
  801c4e:	83 c0 01             	add    $0x1,%eax
  801c51:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801c54:	39 d8                	cmp    %ebx,%eax
  801c56:	74 18                	je     801c70 <strncmp+0x33>
  801c58:	0f b6 08             	movzbl (%eax),%ecx
  801c5b:	84 c9                	test   %cl,%cl
  801c5d:	74 04                	je     801c63 <strncmp+0x26>
  801c5f:	3a 0a                	cmp    (%edx),%cl
  801c61:	74 eb                	je     801c4e <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c63:	0f b6 00             	movzbl (%eax),%eax
  801c66:	0f b6 12             	movzbl (%edx),%edx
  801c69:	29 d0                	sub    %edx,%eax
}
  801c6b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c6e:	c9                   	leave  
  801c6f:	c3                   	ret    
		return 0;
  801c70:	b8 00 00 00 00       	mov    $0x0,%eax
  801c75:	eb f4                	jmp    801c6b <strncmp+0x2e>

00801c77 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c77:	55                   	push   %ebp
  801c78:	89 e5                	mov    %esp,%ebp
  801c7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801c7d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c81:	eb 03                	jmp    801c86 <strchr+0xf>
  801c83:	83 c0 01             	add    $0x1,%eax
  801c86:	0f b6 10             	movzbl (%eax),%edx
  801c89:	84 d2                	test   %dl,%dl
  801c8b:	74 06                	je     801c93 <strchr+0x1c>
		if (*s == c)
  801c8d:	38 ca                	cmp    %cl,%dl
  801c8f:	75 f2                	jne    801c83 <strchr+0xc>
  801c91:	eb 05                	jmp    801c98 <strchr+0x21>
			return (char *) s;
	return 0;
  801c93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c98:	5d                   	pop    %ebp
  801c99:	c3                   	ret    

00801c9a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c9a:	55                   	push   %ebp
  801c9b:	89 e5                	mov    %esp,%ebp
  801c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ca4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801ca7:	38 ca                	cmp    %cl,%dl
  801ca9:	74 09                	je     801cb4 <strfind+0x1a>
  801cab:	84 d2                	test   %dl,%dl
  801cad:	74 05                	je     801cb4 <strfind+0x1a>
	for (; *s; s++)
  801caf:	83 c0 01             	add    $0x1,%eax
  801cb2:	eb f0                	jmp    801ca4 <strfind+0xa>
			break;
	return (char *) s;
}
  801cb4:	5d                   	pop    %ebp
  801cb5:	c3                   	ret    

00801cb6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cb6:	55                   	push   %ebp
  801cb7:	89 e5                	mov    %esp,%ebp
  801cb9:	57                   	push   %edi
  801cba:	56                   	push   %esi
  801cbb:	53                   	push   %ebx
  801cbc:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cbf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cc2:	85 c9                	test   %ecx,%ecx
  801cc4:	74 2f                	je     801cf5 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cc6:	89 f8                	mov    %edi,%eax
  801cc8:	09 c8                	or     %ecx,%eax
  801cca:	a8 03                	test   $0x3,%al
  801ccc:	75 21                	jne    801cef <memset+0x39>
		c &= 0xFF;
  801cce:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cd2:	89 d0                	mov    %edx,%eax
  801cd4:	c1 e0 08             	shl    $0x8,%eax
  801cd7:	89 d3                	mov    %edx,%ebx
  801cd9:	c1 e3 18             	shl    $0x18,%ebx
  801cdc:	89 d6                	mov    %edx,%esi
  801cde:	c1 e6 10             	shl    $0x10,%esi
  801ce1:	09 f3                	or     %esi,%ebx
  801ce3:	09 da                	or     %ebx,%edx
  801ce5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801ce7:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801cea:	fc                   	cld    
  801ceb:	f3 ab                	rep stos %eax,%es:(%edi)
  801ced:	eb 06                	jmp    801cf5 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cef:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf2:	fc                   	cld    
  801cf3:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cf5:	89 f8                	mov    %edi,%eax
  801cf7:	5b                   	pop    %ebx
  801cf8:	5e                   	pop    %esi
  801cf9:	5f                   	pop    %edi
  801cfa:	5d                   	pop    %ebp
  801cfb:	c3                   	ret    

00801cfc <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cfc:	55                   	push   %ebp
  801cfd:	89 e5                	mov    %esp,%ebp
  801cff:	57                   	push   %edi
  801d00:	56                   	push   %esi
  801d01:	8b 45 08             	mov    0x8(%ebp),%eax
  801d04:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d07:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d0a:	39 c6                	cmp    %eax,%esi
  801d0c:	73 32                	jae    801d40 <memmove+0x44>
  801d0e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d11:	39 c2                	cmp    %eax,%edx
  801d13:	76 2b                	jbe    801d40 <memmove+0x44>
		s += n;
		d += n;
  801d15:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d18:	89 d6                	mov    %edx,%esi
  801d1a:	09 fe                	or     %edi,%esi
  801d1c:	09 ce                	or     %ecx,%esi
  801d1e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d24:	75 0e                	jne    801d34 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d26:	83 ef 04             	sub    $0x4,%edi
  801d29:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d2c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801d2f:	fd                   	std    
  801d30:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d32:	eb 09                	jmp    801d3d <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d34:	83 ef 01             	sub    $0x1,%edi
  801d37:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801d3a:	fd                   	std    
  801d3b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d3d:	fc                   	cld    
  801d3e:	eb 1a                	jmp    801d5a <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d40:	89 f2                	mov    %esi,%edx
  801d42:	09 c2                	or     %eax,%edx
  801d44:	09 ca                	or     %ecx,%edx
  801d46:	f6 c2 03             	test   $0x3,%dl
  801d49:	75 0a                	jne    801d55 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801d4b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801d4e:	89 c7                	mov    %eax,%edi
  801d50:	fc                   	cld    
  801d51:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d53:	eb 05                	jmp    801d5a <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801d55:	89 c7                	mov    %eax,%edi
  801d57:	fc                   	cld    
  801d58:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d5a:	5e                   	pop    %esi
  801d5b:	5f                   	pop    %edi
  801d5c:	5d                   	pop    %ebp
  801d5d:	c3                   	ret    

00801d5e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d64:	ff 75 10             	push   0x10(%ebp)
  801d67:	ff 75 0c             	push   0xc(%ebp)
  801d6a:	ff 75 08             	push   0x8(%ebp)
  801d6d:	e8 8a ff ff ff       	call   801cfc <memmove>
}
  801d72:	c9                   	leave  
  801d73:	c3                   	ret    

00801d74 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d74:	55                   	push   %ebp
  801d75:	89 e5                	mov    %esp,%ebp
  801d77:	56                   	push   %esi
  801d78:	53                   	push   %ebx
  801d79:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d7f:	89 c6                	mov    %eax,%esi
  801d81:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d84:	eb 06                	jmp    801d8c <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801d86:	83 c0 01             	add    $0x1,%eax
  801d89:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801d8c:	39 f0                	cmp    %esi,%eax
  801d8e:	74 14                	je     801da4 <memcmp+0x30>
		if (*s1 != *s2)
  801d90:	0f b6 08             	movzbl (%eax),%ecx
  801d93:	0f b6 1a             	movzbl (%edx),%ebx
  801d96:	38 d9                	cmp    %bl,%cl
  801d98:	74 ec                	je     801d86 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801d9a:	0f b6 c1             	movzbl %cl,%eax
  801d9d:	0f b6 db             	movzbl %bl,%ebx
  801da0:	29 d8                	sub    %ebx,%eax
  801da2:	eb 05                	jmp    801da9 <memcmp+0x35>
	}

	return 0;
  801da4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801da9:	5b                   	pop    %ebx
  801daa:	5e                   	pop    %esi
  801dab:	5d                   	pop    %ebp
  801dac:	c3                   	ret    

00801dad <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801dad:	55                   	push   %ebp
  801dae:	89 e5                	mov    %esp,%ebp
  801db0:	8b 45 08             	mov    0x8(%ebp),%eax
  801db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801db6:	89 c2                	mov    %eax,%edx
  801db8:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801dbb:	eb 03                	jmp    801dc0 <memfind+0x13>
  801dbd:	83 c0 01             	add    $0x1,%eax
  801dc0:	39 d0                	cmp    %edx,%eax
  801dc2:	73 04                	jae    801dc8 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801dc4:	38 08                	cmp    %cl,(%eax)
  801dc6:	75 f5                	jne    801dbd <memfind+0x10>
			break;
	return (void *) s;
}
  801dc8:	5d                   	pop    %ebp
  801dc9:	c3                   	ret    

00801dca <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dca:	55                   	push   %ebp
  801dcb:	89 e5                	mov    %esp,%ebp
  801dcd:	57                   	push   %edi
  801dce:	56                   	push   %esi
  801dcf:	53                   	push   %ebx
  801dd0:	8b 55 08             	mov    0x8(%ebp),%edx
  801dd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dd6:	eb 03                	jmp    801ddb <strtol+0x11>
		s++;
  801dd8:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801ddb:	0f b6 02             	movzbl (%edx),%eax
  801dde:	3c 20                	cmp    $0x20,%al
  801de0:	74 f6                	je     801dd8 <strtol+0xe>
  801de2:	3c 09                	cmp    $0x9,%al
  801de4:	74 f2                	je     801dd8 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801de6:	3c 2b                	cmp    $0x2b,%al
  801de8:	74 2a                	je     801e14 <strtol+0x4a>
	int neg = 0;
  801dea:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801def:	3c 2d                	cmp    $0x2d,%al
  801df1:	74 2b                	je     801e1e <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801df3:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801df9:	75 0f                	jne    801e0a <strtol+0x40>
  801dfb:	80 3a 30             	cmpb   $0x30,(%edx)
  801dfe:	74 28                	je     801e28 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e00:	85 db                	test   %ebx,%ebx
  801e02:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e07:	0f 44 d8             	cmove  %eax,%ebx
  801e0a:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e0f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801e12:	eb 46                	jmp    801e5a <strtol+0x90>
		s++;
  801e14:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801e17:	bf 00 00 00 00       	mov    $0x0,%edi
  801e1c:	eb d5                	jmp    801df3 <strtol+0x29>
		s++, neg = 1;
  801e1e:	83 c2 01             	add    $0x1,%edx
  801e21:	bf 01 00 00 00       	mov    $0x1,%edi
  801e26:	eb cb                	jmp    801df3 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e28:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e2c:	74 0e                	je     801e3c <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801e2e:	85 db                	test   %ebx,%ebx
  801e30:	75 d8                	jne    801e0a <strtol+0x40>
		s++, base = 8;
  801e32:	83 c2 01             	add    $0x1,%edx
  801e35:	bb 08 00 00 00       	mov    $0x8,%ebx
  801e3a:	eb ce                	jmp    801e0a <strtol+0x40>
		s += 2, base = 16;
  801e3c:	83 c2 02             	add    $0x2,%edx
  801e3f:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e44:	eb c4                	jmp    801e0a <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801e46:	0f be c0             	movsbl %al,%eax
  801e49:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801e4c:	3b 45 10             	cmp    0x10(%ebp),%eax
  801e4f:	7d 3a                	jge    801e8b <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801e51:	83 c2 01             	add    $0x1,%edx
  801e54:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801e58:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801e5a:	0f b6 02             	movzbl (%edx),%eax
  801e5d:	8d 70 d0             	lea    -0x30(%eax),%esi
  801e60:	89 f3                	mov    %esi,%ebx
  801e62:	80 fb 09             	cmp    $0x9,%bl
  801e65:	76 df                	jbe    801e46 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  801e67:	8d 70 9f             	lea    -0x61(%eax),%esi
  801e6a:	89 f3                	mov    %esi,%ebx
  801e6c:	80 fb 19             	cmp    $0x19,%bl
  801e6f:	77 08                	ja     801e79 <strtol+0xaf>
			dig = *s - 'a' + 10;
  801e71:	0f be c0             	movsbl %al,%eax
  801e74:	83 e8 57             	sub    $0x57,%eax
  801e77:	eb d3                	jmp    801e4c <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801e79:	8d 70 bf             	lea    -0x41(%eax),%esi
  801e7c:	89 f3                	mov    %esi,%ebx
  801e7e:	80 fb 19             	cmp    $0x19,%bl
  801e81:	77 08                	ja     801e8b <strtol+0xc1>
			dig = *s - 'A' + 10;
  801e83:	0f be c0             	movsbl %al,%eax
  801e86:	83 e8 37             	sub    $0x37,%eax
  801e89:	eb c1                	jmp    801e4c <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801e8b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e8f:	74 05                	je     801e96 <strtol+0xcc>
		*endptr = (char *) s;
  801e91:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e94:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801e96:	89 c8                	mov    %ecx,%eax
  801e98:	f7 d8                	neg    %eax
  801e9a:	85 ff                	test   %edi,%edi
  801e9c:	0f 45 c8             	cmovne %eax,%ecx
}
  801e9f:	89 c8                	mov    %ecx,%eax
  801ea1:	5b                   	pop    %ebx
  801ea2:	5e                   	pop    %esi
  801ea3:	5f                   	pop    %edi
  801ea4:	5d                   	pop    %ebp
  801ea5:	c3                   	ret    

00801ea6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ea6:	55                   	push   %ebp
  801ea7:	89 e5                	mov    %esp,%ebp
  801ea9:	56                   	push   %esi
  801eaa:	53                   	push   %ebx
  801eab:	8b 75 08             	mov    0x8(%ebp),%esi
  801eae:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801eb4:	85 c0                	test   %eax,%eax
  801eb6:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ebb:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801ebe:	83 ec 0c             	sub    $0xc,%esp
  801ec1:	50                   	push   %eax
  801ec2:	e8 3a e4 ff ff       	call   800301 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ec7:	83 c4 10             	add    $0x10,%esp
  801eca:	85 f6                	test   %esi,%esi
  801ecc:	74 14                	je     801ee2 <ipc_recv+0x3c>
  801ece:	ba 00 00 00 00       	mov    $0x0,%edx
  801ed3:	85 c0                	test   %eax,%eax
  801ed5:	78 09                	js     801ee0 <ipc_recv+0x3a>
  801ed7:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801edd:	8b 52 74             	mov    0x74(%edx),%edx
  801ee0:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801ee2:	85 db                	test   %ebx,%ebx
  801ee4:	74 14                	je     801efa <ipc_recv+0x54>
  801ee6:	ba 00 00 00 00       	mov    $0x0,%edx
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	78 09                	js     801ef8 <ipc_recv+0x52>
  801eef:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ef5:	8b 52 78             	mov    0x78(%edx),%edx
  801ef8:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801efa:	85 c0                	test   %eax,%eax
  801efc:	78 08                	js     801f06 <ipc_recv+0x60>
	
	return thisenv->env_ipc_value;
  801efe:	a1 00 40 80 00       	mov    0x804000,%eax
  801f03:	8b 40 70             	mov    0x70(%eax),%eax
}
  801f06:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f09:	5b                   	pop    %ebx
  801f0a:	5e                   	pop    %esi
  801f0b:	5d                   	pop    %ebp
  801f0c:	c3                   	ret    

00801f0d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f0d:	55                   	push   %ebp
  801f0e:	89 e5                	mov    %esp,%ebp
  801f10:	57                   	push   %edi
  801f11:	56                   	push   %esi
  801f12:	53                   	push   %ebx
  801f13:	83 ec 0c             	sub    $0xc,%esp
  801f16:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f19:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f1f:	85 db                	test   %ebx,%ebx
  801f21:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f26:	0f 44 d8             	cmove  %eax,%ebx
  801f29:	eb 05                	jmp    801f30 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f2b:	e8 02 e2 ff ff       	call   800132 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f30:	ff 75 14             	push   0x14(%ebp)
  801f33:	53                   	push   %ebx
  801f34:	56                   	push   %esi
  801f35:	57                   	push   %edi
  801f36:	e8 a3 e3 ff ff       	call   8002de <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f3b:	83 c4 10             	add    $0x10,%esp
  801f3e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f41:	74 e8                	je     801f2b <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f43:	85 c0                	test   %eax,%eax
  801f45:	78 08                	js     801f4f <ipc_send+0x42>
	}while (r<0);

}
  801f47:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4a:	5b                   	pop    %ebx
  801f4b:	5e                   	pop    %esi
  801f4c:	5f                   	pop    %edi
  801f4d:	5d                   	pop    %ebp
  801f4e:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f4f:	50                   	push   %eax
  801f50:	68 9f 26 80 00       	push   $0x80269f
  801f55:	6a 3d                	push   $0x3d
  801f57:	68 b3 26 80 00       	push   $0x8026b3
  801f5c:	e8 50 f5 ff ff       	call   8014b1 <_panic>

00801f61 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f67:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f6c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801f6f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f75:	8b 52 50             	mov    0x50(%edx),%edx
  801f78:	39 ca                	cmp    %ecx,%edx
  801f7a:	74 11                	je     801f8d <ipc_find_env+0x2c>
	for (i = 0; i < NENV; i++)
  801f7c:	83 c0 01             	add    $0x1,%eax
  801f7f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f84:	75 e6                	jne    801f6c <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801f86:	b8 00 00 00 00       	mov    $0x0,%eax
  801f8b:	eb 0b                	jmp    801f98 <ipc_find_env+0x37>
			return envs[i].env_id;
  801f8d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801f90:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801f95:	8b 40 48             	mov    0x48(%eax),%eax
}
  801f98:	5d                   	pop    %ebp
  801f99:	c3                   	ret    

00801f9a <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801f9a:	55                   	push   %ebp
  801f9b:	89 e5                	mov    %esp,%ebp
  801f9d:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fa0:	89 c2                	mov    %eax,%edx
  801fa2:	c1 ea 16             	shr    $0x16,%edx
  801fa5:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fac:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fb1:	f6 c1 01             	test   $0x1,%cl
  801fb4:	74 1c                	je     801fd2 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801fb6:	c1 e8 0c             	shr    $0xc,%eax
  801fb9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fc0:	a8 01                	test   $0x1,%al
  801fc2:	74 0e                	je     801fd2 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fc4:	c1 e8 0c             	shr    $0xc,%eax
  801fc7:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801fce:	ef 
  801fcf:	0f b7 d2             	movzwl %dx,%edx
}
  801fd2:	89 d0                	mov    %edx,%eax
  801fd4:	5d                   	pop    %ebp
  801fd5:	c3                   	ret    
  801fd6:	66 90                	xchg   %ax,%ax
  801fd8:	66 90                	xchg   %ax,%ax
  801fda:	66 90                	xchg   %ax,%ax
  801fdc:	66 90                	xchg   %ax,%ax
  801fde:	66 90                	xchg   %ax,%ax

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
