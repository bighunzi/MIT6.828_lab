
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
  800040:	e8 d1 00 00 00       	call   800116 <sys_getenvid>
  800045:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004a:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800050:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800055:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005a:	85 db                	test   %ebx,%ebx
  80005c:	7e 07                	jle    800065 <libmain+0x30>
		binaryname = argv[0];
  80005e:	8b 06                	mov    (%esi),%eax
  800060:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800065:	83 ec 08             	sub    $0x8,%esp
  800068:	56                   	push   %esi
  800069:	53                   	push   %ebx
  80006a:	e8 c4 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80006f:	e8 0a 00 00 00       	call   80007e <exit>
}
  800074:	83 c4 10             	add    $0x10,%esp
  800077:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007a:	5b                   	pop    %ebx
  80007b:	5e                   	pop    %esi
  80007c:	5d                   	pop    %ebp
  80007d:	c3                   	ret    

0080007e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800084:	e8 ee 04 00 00       	call   800577 <close_all>
	sys_env_destroy(0);
  800089:	83 ec 0c             	sub    $0xc,%esp
  80008c:	6a 00                	push   $0x0
  80008e:	e8 42 00 00 00       	call   8000d5 <sys_env_destroy>
}
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	c9                   	leave  
  800097:	c3                   	ret    

00800098 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	57                   	push   %edi
  80009c:	56                   	push   %esi
  80009d:	53                   	push   %ebx
	asm volatile("int %1\n"
  80009e:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a9:	89 c3                	mov    %eax,%ebx
  8000ab:	89 c7                	mov    %eax,%edi
  8000ad:	89 c6                	mov    %eax,%esi
  8000af:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b1:	5b                   	pop    %ebx
  8000b2:	5e                   	pop    %esi
  8000b3:	5f                   	pop    %edi
  8000b4:	5d                   	pop    %ebp
  8000b5:	c3                   	ret    

008000b6 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000b6:	55                   	push   %ebp
  8000b7:	89 e5                	mov    %esp,%ebp
  8000b9:	57                   	push   %edi
  8000ba:	56                   	push   %esi
  8000bb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c1:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c6:	89 d1                	mov    %edx,%ecx
  8000c8:	89 d3                	mov    %edx,%ebx
  8000ca:	89 d7                	mov    %edx,%edi
  8000cc:	89 d6                	mov    %edx,%esi
  8000ce:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d0:	5b                   	pop    %ebx
  8000d1:	5e                   	pop    %esi
  8000d2:	5f                   	pop    %edi
  8000d3:	5d                   	pop    %ebp
  8000d4:	c3                   	ret    

008000d5 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	57                   	push   %edi
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
  8000db:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e6:	b8 03 00 00 00       	mov    $0x3,%eax
  8000eb:	89 cb                	mov    %ecx,%ebx
  8000ed:	89 cf                	mov    %ecx,%edi
  8000ef:	89 ce                	mov    %ecx,%esi
  8000f1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f3:	85 c0                	test   %eax,%eax
  8000f5:	7f 08                	jg     8000ff <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000fa:	5b                   	pop    %ebx
  8000fb:	5e                   	pop    %esi
  8000fc:	5f                   	pop    %edi
  8000fd:	5d                   	pop    %ebp
  8000fe:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ff:	83 ec 0c             	sub    $0xc,%esp
  800102:	50                   	push   %eax
  800103:	6a 03                	push   $0x3
  800105:	68 4a 22 80 00       	push   $0x80224a
  80010a:	6a 2a                	push   $0x2a
  80010c:	68 67 22 80 00       	push   $0x802267
  800111:	e8 9e 13 00 00       	call   8014b4 <_panic>

00800116 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	57                   	push   %edi
  80011a:	56                   	push   %esi
  80011b:	53                   	push   %ebx
	asm volatile("int %1\n"
  80011c:	ba 00 00 00 00       	mov    $0x0,%edx
  800121:	b8 02 00 00 00       	mov    $0x2,%eax
  800126:	89 d1                	mov    %edx,%ecx
  800128:	89 d3                	mov    %edx,%ebx
  80012a:	89 d7                	mov    %edx,%edi
  80012c:	89 d6                	mov    %edx,%esi
  80012e:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800130:	5b                   	pop    %ebx
  800131:	5e                   	pop    %esi
  800132:	5f                   	pop    %edi
  800133:	5d                   	pop    %ebp
  800134:	c3                   	ret    

00800135 <sys_yield>:

void
sys_yield(void)
{
  800135:	55                   	push   %ebp
  800136:	89 e5                	mov    %esp,%ebp
  800138:	57                   	push   %edi
  800139:	56                   	push   %esi
  80013a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013b:	ba 00 00 00 00       	mov    $0x0,%edx
  800140:	b8 0b 00 00 00       	mov    $0xb,%eax
  800145:	89 d1                	mov    %edx,%ecx
  800147:	89 d3                	mov    %edx,%ebx
  800149:	89 d7                	mov    %edx,%edi
  80014b:	89 d6                	mov    %edx,%esi
  80014d:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5f                   	pop    %edi
  800152:	5d                   	pop    %ebp
  800153:	c3                   	ret    

00800154 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	57                   	push   %edi
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
  80015a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80015d:	be 00 00 00 00       	mov    $0x0,%esi
  800162:	8b 55 08             	mov    0x8(%ebp),%edx
  800165:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800168:	b8 04 00 00 00       	mov    $0x4,%eax
  80016d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800170:	89 f7                	mov    %esi,%edi
  800172:	cd 30                	int    $0x30
	if(check && ret > 0)
  800174:	85 c0                	test   %eax,%eax
  800176:	7f 08                	jg     800180 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800178:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80017b:	5b                   	pop    %ebx
  80017c:	5e                   	pop    %esi
  80017d:	5f                   	pop    %edi
  80017e:	5d                   	pop    %ebp
  80017f:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800180:	83 ec 0c             	sub    $0xc,%esp
  800183:	50                   	push   %eax
  800184:	6a 04                	push   $0x4
  800186:	68 4a 22 80 00       	push   $0x80224a
  80018b:	6a 2a                	push   $0x2a
  80018d:	68 67 22 80 00       	push   $0x802267
  800192:	e8 1d 13 00 00       	call   8014b4 <_panic>

00800197 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	57                   	push   %edi
  80019b:	56                   	push   %esi
  80019c:	53                   	push   %ebx
  80019d:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ab:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ae:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b1:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b4:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001b6:	85 c0                	test   %eax,%eax
  8001b8:	7f 08                	jg     8001c2 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bd:	5b                   	pop    %ebx
  8001be:	5e                   	pop    %esi
  8001bf:	5f                   	pop    %edi
  8001c0:	5d                   	pop    %ebp
  8001c1:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c2:	83 ec 0c             	sub    $0xc,%esp
  8001c5:	50                   	push   %eax
  8001c6:	6a 05                	push   $0x5
  8001c8:	68 4a 22 80 00       	push   $0x80224a
  8001cd:	6a 2a                	push   $0x2a
  8001cf:	68 67 22 80 00       	push   $0x802267
  8001d4:	e8 db 12 00 00       	call   8014b4 <_panic>

008001d9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d9:	55                   	push   %ebp
  8001da:	89 e5                	mov    %esp,%ebp
  8001dc:	57                   	push   %edi
  8001dd:	56                   	push   %esi
  8001de:	53                   	push   %ebx
  8001df:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f2:	89 df                	mov    %ebx,%edi
  8001f4:	89 de                	mov    %ebx,%esi
  8001f6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001f8:	85 c0                	test   %eax,%eax
  8001fa:	7f 08                	jg     800204 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8001fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ff:	5b                   	pop    %ebx
  800200:	5e                   	pop    %esi
  800201:	5f                   	pop    %edi
  800202:	5d                   	pop    %ebp
  800203:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800204:	83 ec 0c             	sub    $0xc,%esp
  800207:	50                   	push   %eax
  800208:	6a 06                	push   $0x6
  80020a:	68 4a 22 80 00       	push   $0x80224a
  80020f:	6a 2a                	push   $0x2a
  800211:	68 67 22 80 00       	push   $0x802267
  800216:	e8 99 12 00 00       	call   8014b4 <_panic>

0080021b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80021b:	55                   	push   %ebp
  80021c:	89 e5                	mov    %esp,%ebp
  80021e:	57                   	push   %edi
  80021f:	56                   	push   %esi
  800220:	53                   	push   %ebx
  800221:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800224:	bb 00 00 00 00       	mov    $0x0,%ebx
  800229:	8b 55 08             	mov    0x8(%ebp),%edx
  80022c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022f:	b8 08 00 00 00       	mov    $0x8,%eax
  800234:	89 df                	mov    %ebx,%edi
  800236:	89 de                	mov    %ebx,%esi
  800238:	cd 30                	int    $0x30
	if(check && ret > 0)
  80023a:	85 c0                	test   %eax,%eax
  80023c:	7f 08                	jg     800246 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80023e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800241:	5b                   	pop    %ebx
  800242:	5e                   	pop    %esi
  800243:	5f                   	pop    %edi
  800244:	5d                   	pop    %ebp
  800245:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800246:	83 ec 0c             	sub    $0xc,%esp
  800249:	50                   	push   %eax
  80024a:	6a 08                	push   $0x8
  80024c:	68 4a 22 80 00       	push   $0x80224a
  800251:	6a 2a                	push   $0x2a
  800253:	68 67 22 80 00       	push   $0x802267
  800258:	e8 57 12 00 00       	call   8014b4 <_panic>

0080025d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
  800260:	57                   	push   %edi
  800261:	56                   	push   %esi
  800262:	53                   	push   %ebx
  800263:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800266:	bb 00 00 00 00       	mov    $0x0,%ebx
  80026b:	8b 55 08             	mov    0x8(%ebp),%edx
  80026e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800271:	b8 09 00 00 00       	mov    $0x9,%eax
  800276:	89 df                	mov    %ebx,%edi
  800278:	89 de                	mov    %ebx,%esi
  80027a:	cd 30                	int    $0x30
	if(check && ret > 0)
  80027c:	85 c0                	test   %eax,%eax
  80027e:	7f 08                	jg     800288 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800280:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800283:	5b                   	pop    %ebx
  800284:	5e                   	pop    %esi
  800285:	5f                   	pop    %edi
  800286:	5d                   	pop    %ebp
  800287:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800288:	83 ec 0c             	sub    $0xc,%esp
  80028b:	50                   	push   %eax
  80028c:	6a 09                	push   $0x9
  80028e:	68 4a 22 80 00       	push   $0x80224a
  800293:	6a 2a                	push   $0x2a
  800295:	68 67 22 80 00       	push   $0x802267
  80029a:	e8 15 12 00 00       	call   8014b4 <_panic>

0080029f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	57                   	push   %edi
  8002a3:	56                   	push   %esi
  8002a4:	53                   	push   %ebx
  8002a5:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b8:	89 df                	mov    %ebx,%edi
  8002ba:	89 de                	mov    %ebx,%esi
  8002bc:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002be:	85 c0                	test   %eax,%eax
  8002c0:	7f 08                	jg     8002ca <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c5:	5b                   	pop    %ebx
  8002c6:	5e                   	pop    %esi
  8002c7:	5f                   	pop    %edi
  8002c8:	5d                   	pop    %ebp
  8002c9:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ca:	83 ec 0c             	sub    $0xc,%esp
  8002cd:	50                   	push   %eax
  8002ce:	6a 0a                	push   $0xa
  8002d0:	68 4a 22 80 00       	push   $0x80224a
  8002d5:	6a 2a                	push   $0x2a
  8002d7:	68 67 22 80 00       	push   $0x802267
  8002dc:	e8 d3 11 00 00       	call   8014b4 <_panic>

008002e1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e1:	55                   	push   %ebp
  8002e2:	89 e5                	mov    %esp,%ebp
  8002e4:	57                   	push   %edi
  8002e5:	56                   	push   %esi
  8002e6:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002e7:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002ed:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f2:	be 00 00 00 00       	mov    $0x0,%esi
  8002f7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002fa:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002fd:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002ff:	5b                   	pop    %ebx
  800300:	5e                   	pop    %esi
  800301:	5f                   	pop    %edi
  800302:	5d                   	pop    %ebp
  800303:	c3                   	ret    

00800304 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	57                   	push   %edi
  800308:	56                   	push   %esi
  800309:	53                   	push   %ebx
  80030a:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80030d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800312:	8b 55 08             	mov    0x8(%ebp),%edx
  800315:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031a:	89 cb                	mov    %ecx,%ebx
  80031c:	89 cf                	mov    %ecx,%edi
  80031e:	89 ce                	mov    %ecx,%esi
  800320:	cd 30                	int    $0x30
	if(check && ret > 0)
  800322:	85 c0                	test   %eax,%eax
  800324:	7f 08                	jg     80032e <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800326:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800329:	5b                   	pop    %ebx
  80032a:	5e                   	pop    %esi
  80032b:	5f                   	pop    %edi
  80032c:	5d                   	pop    %ebp
  80032d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80032e:	83 ec 0c             	sub    $0xc,%esp
  800331:	50                   	push   %eax
  800332:	6a 0d                	push   $0xd
  800334:	68 4a 22 80 00       	push   $0x80224a
  800339:	6a 2a                	push   $0x2a
  80033b:	68 67 22 80 00       	push   $0x802267
  800340:	e8 6f 11 00 00       	call   8014b4 <_panic>

00800345 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800345:	55                   	push   %ebp
  800346:	89 e5                	mov    %esp,%ebp
  800348:	57                   	push   %edi
  800349:	56                   	push   %esi
  80034a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80034b:	ba 00 00 00 00       	mov    $0x0,%edx
  800350:	b8 0e 00 00 00       	mov    $0xe,%eax
  800355:	89 d1                	mov    %edx,%ecx
  800357:	89 d3                	mov    %edx,%ebx
  800359:	89 d7                	mov    %edx,%edi
  80035b:	89 d6                	mov    %edx,%esi
  80035d:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80035f:	5b                   	pop    %ebx
  800360:	5e                   	pop    %esi
  800361:	5f                   	pop    %edi
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	57                   	push   %edi
  800368:	56                   	push   %esi
  800369:	53                   	push   %ebx
	asm volatile("int %1\n"
  80036a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80036f:	8b 55 08             	mov    0x8(%ebp),%edx
  800372:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800375:	b8 0f 00 00 00       	mov    $0xf,%eax
  80037a:	89 df                	mov    %ebx,%edi
  80037c:	89 de                	mov    %ebx,%esi
  80037e:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800380:	5b                   	pop    %ebx
  800381:	5e                   	pop    %esi
  800382:	5f                   	pop    %edi
  800383:	5d                   	pop    %ebp
  800384:	c3                   	ret    

00800385 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  800385:	55                   	push   %ebp
  800386:	89 e5                	mov    %esp,%ebp
  800388:	57                   	push   %edi
  800389:	56                   	push   %esi
  80038a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80038b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800390:	8b 55 08             	mov    0x8(%ebp),%edx
  800393:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800396:	b8 10 00 00 00       	mov    $0x10,%eax
  80039b:	89 df                	mov    %ebx,%edi
  80039d:	89 de                	mov    %ebx,%esi
  80039f:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8003a1:	5b                   	pop    %ebx
  8003a2:	5e                   	pop    %esi
  8003a3:	5f                   	pop    %edi
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ac:	05 00 00 00 30       	add    $0x30000000,%eax
  8003b1:	c1 e8 0c             	shr    $0xc,%eax
}
  8003b4:	5d                   	pop    %ebp
  8003b5:	c3                   	ret    

008003b6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003b6:	55                   	push   %ebp
  8003b7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8003bc:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003c1:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003c6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003d5:	89 c2                	mov    %eax,%edx
  8003d7:	c1 ea 16             	shr    $0x16,%edx
  8003da:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e1:	f6 c2 01             	test   $0x1,%dl
  8003e4:	74 29                	je     80040f <fd_alloc+0x42>
  8003e6:	89 c2                	mov    %eax,%edx
  8003e8:	c1 ea 0c             	shr    $0xc,%edx
  8003eb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f2:	f6 c2 01             	test   $0x1,%dl
  8003f5:	74 18                	je     80040f <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8003f7:	05 00 10 00 00       	add    $0x1000,%eax
  8003fc:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800401:	75 d2                	jne    8003d5 <fd_alloc+0x8>
  800403:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  800408:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  80040d:	eb 05                	jmp    800414 <fd_alloc+0x47>
			return 0;
  80040f:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800414:	8b 55 08             	mov    0x8(%ebp),%edx
  800417:	89 02                	mov    %eax,(%edx)
}
  800419:	89 c8                	mov    %ecx,%eax
  80041b:	5d                   	pop    %ebp
  80041c:	c3                   	ret    

0080041d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80041d:	55                   	push   %ebp
  80041e:	89 e5                	mov    %esp,%ebp
  800420:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800423:	83 f8 1f             	cmp    $0x1f,%eax
  800426:	77 30                	ja     800458 <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800428:	c1 e0 0c             	shl    $0xc,%eax
  80042b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800430:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800436:	f6 c2 01             	test   $0x1,%dl
  800439:	74 24                	je     80045f <fd_lookup+0x42>
  80043b:	89 c2                	mov    %eax,%edx
  80043d:	c1 ea 0c             	shr    $0xc,%edx
  800440:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800447:	f6 c2 01             	test   $0x1,%dl
  80044a:	74 1a                	je     800466 <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80044c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044f:	89 02                	mov    %eax,(%edx)
	return 0;
  800451:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800456:	5d                   	pop    %ebp
  800457:	c3                   	ret    
		return -E_INVAL;
  800458:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80045d:	eb f7                	jmp    800456 <fd_lookup+0x39>
		return -E_INVAL;
  80045f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800464:	eb f0                	jmp    800456 <fd_lookup+0x39>
  800466:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80046b:	eb e9                	jmp    800456 <fd_lookup+0x39>

0080046d <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80046d:	55                   	push   %ebp
  80046e:	89 e5                	mov    %esp,%ebp
  800470:	53                   	push   %ebx
  800471:	83 ec 04             	sub    $0x4,%esp
  800474:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800477:	b8 00 00 00 00       	mov    $0x0,%eax
  80047c:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800481:	39 13                	cmp    %edx,(%ebx)
  800483:	74 37                	je     8004bc <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  800485:	83 c0 01             	add    $0x1,%eax
  800488:	8b 1c 85 f4 22 80 00 	mov    0x8022f4(,%eax,4),%ebx
  80048f:	85 db                	test   %ebx,%ebx
  800491:	75 ee                	jne    800481 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800493:	a1 00 40 80 00       	mov    0x804000,%eax
  800498:	8b 40 58             	mov    0x58(%eax),%eax
  80049b:	83 ec 04             	sub    $0x4,%esp
  80049e:	52                   	push   %edx
  80049f:	50                   	push   %eax
  8004a0:	68 78 22 80 00       	push   $0x802278
  8004a5:	e8 e5 10 00 00       	call   80158f <cprintf>
	*dev = 0;
	return -E_INVAL;
  8004aa:	83 c4 10             	add    $0x10,%esp
  8004ad:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8004b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004b5:	89 1a                	mov    %ebx,(%edx)
}
  8004b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004ba:	c9                   	leave  
  8004bb:	c3                   	ret    
			return 0;
  8004bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c1:	eb ef                	jmp    8004b2 <dev_lookup+0x45>

008004c3 <fd_close>:
{
  8004c3:	55                   	push   %ebp
  8004c4:	89 e5                	mov    %esp,%ebp
  8004c6:	57                   	push   %edi
  8004c7:	56                   	push   %esi
  8004c8:	53                   	push   %ebx
  8004c9:	83 ec 24             	sub    $0x24,%esp
  8004cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cf:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004d2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004d5:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004d6:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004dc:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004df:	50                   	push   %eax
  8004e0:	e8 38 ff ff ff       	call   80041d <fd_lookup>
  8004e5:	89 c3                	mov    %eax,%ebx
  8004e7:	83 c4 10             	add    $0x10,%esp
  8004ea:	85 c0                	test   %eax,%eax
  8004ec:	78 05                	js     8004f3 <fd_close+0x30>
	    || fd != fd2)
  8004ee:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004f1:	74 16                	je     800509 <fd_close+0x46>
		return (must_exist ? r : 0);
  8004f3:	89 f8                	mov    %edi,%eax
  8004f5:	84 c0                	test   %al,%al
  8004f7:	b8 00 00 00 00       	mov    $0x0,%eax
  8004fc:	0f 44 d8             	cmove  %eax,%ebx
}
  8004ff:	89 d8                	mov    %ebx,%eax
  800501:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800504:	5b                   	pop    %ebx
  800505:	5e                   	pop    %esi
  800506:	5f                   	pop    %edi
  800507:	5d                   	pop    %ebp
  800508:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800509:	83 ec 08             	sub    $0x8,%esp
  80050c:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80050f:	50                   	push   %eax
  800510:	ff 36                	push   (%esi)
  800512:	e8 56 ff ff ff       	call   80046d <dev_lookup>
  800517:	89 c3                	mov    %eax,%ebx
  800519:	83 c4 10             	add    $0x10,%esp
  80051c:	85 c0                	test   %eax,%eax
  80051e:	78 1a                	js     80053a <fd_close+0x77>
		if (dev->dev_close)
  800520:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800523:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800526:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80052b:	85 c0                	test   %eax,%eax
  80052d:	74 0b                	je     80053a <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  80052f:	83 ec 0c             	sub    $0xc,%esp
  800532:	56                   	push   %esi
  800533:	ff d0                	call   *%eax
  800535:	89 c3                	mov    %eax,%ebx
  800537:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	56                   	push   %esi
  80053e:	6a 00                	push   $0x0
  800540:	e8 94 fc ff ff       	call   8001d9 <sys_page_unmap>
	return r;
  800545:	83 c4 10             	add    $0x10,%esp
  800548:	eb b5                	jmp    8004ff <fd_close+0x3c>

0080054a <close>:

int
close(int fdnum)
{
  80054a:	55                   	push   %ebp
  80054b:	89 e5                	mov    %esp,%ebp
  80054d:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800550:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800553:	50                   	push   %eax
  800554:	ff 75 08             	push   0x8(%ebp)
  800557:	e8 c1 fe ff ff       	call   80041d <fd_lookup>
  80055c:	83 c4 10             	add    $0x10,%esp
  80055f:	85 c0                	test   %eax,%eax
  800561:	79 02                	jns    800565 <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800563:	c9                   	leave  
  800564:	c3                   	ret    
		return fd_close(fd, 1);
  800565:	83 ec 08             	sub    $0x8,%esp
  800568:	6a 01                	push   $0x1
  80056a:	ff 75 f4             	push   -0xc(%ebp)
  80056d:	e8 51 ff ff ff       	call   8004c3 <fd_close>
  800572:	83 c4 10             	add    $0x10,%esp
  800575:	eb ec                	jmp    800563 <close+0x19>

00800577 <close_all>:

void
close_all(void)
{
  800577:	55                   	push   %ebp
  800578:	89 e5                	mov    %esp,%ebp
  80057a:	53                   	push   %ebx
  80057b:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80057e:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800583:	83 ec 0c             	sub    $0xc,%esp
  800586:	53                   	push   %ebx
  800587:	e8 be ff ff ff       	call   80054a <close>
	for (i = 0; i < MAXFD; i++)
  80058c:	83 c3 01             	add    $0x1,%ebx
  80058f:	83 c4 10             	add    $0x10,%esp
  800592:	83 fb 20             	cmp    $0x20,%ebx
  800595:	75 ec                	jne    800583 <close_all+0xc>
}
  800597:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80059a:	c9                   	leave  
  80059b:	c3                   	ret    

0080059c <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80059c:	55                   	push   %ebp
  80059d:	89 e5                	mov    %esp,%ebp
  80059f:	57                   	push   %edi
  8005a0:	56                   	push   %esi
  8005a1:	53                   	push   %ebx
  8005a2:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005a5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005a8:	50                   	push   %eax
  8005a9:	ff 75 08             	push   0x8(%ebp)
  8005ac:	e8 6c fe ff ff       	call   80041d <fd_lookup>
  8005b1:	89 c3                	mov    %eax,%ebx
  8005b3:	83 c4 10             	add    $0x10,%esp
  8005b6:	85 c0                	test   %eax,%eax
  8005b8:	78 7f                	js     800639 <dup+0x9d>
		return r;
	close(newfdnum);
  8005ba:	83 ec 0c             	sub    $0xc,%esp
  8005bd:	ff 75 0c             	push   0xc(%ebp)
  8005c0:	e8 85 ff ff ff       	call   80054a <close>

	newfd = INDEX2FD(newfdnum);
  8005c5:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005c8:	c1 e6 0c             	shl    $0xc,%esi
  8005cb:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d4:	89 3c 24             	mov    %edi,(%esp)
  8005d7:	e8 da fd ff ff       	call   8003b6 <fd2data>
  8005dc:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005de:	89 34 24             	mov    %esi,(%esp)
  8005e1:	e8 d0 fd ff ff       	call   8003b6 <fd2data>
  8005e6:	83 c4 10             	add    $0x10,%esp
  8005e9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005ec:	89 d8                	mov    %ebx,%eax
  8005ee:	c1 e8 16             	shr    $0x16,%eax
  8005f1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005f8:	a8 01                	test   $0x1,%al
  8005fa:	74 11                	je     80060d <dup+0x71>
  8005fc:	89 d8                	mov    %ebx,%eax
  8005fe:	c1 e8 0c             	shr    $0xc,%eax
  800601:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800608:	f6 c2 01             	test   $0x1,%dl
  80060b:	75 36                	jne    800643 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060d:	89 f8                	mov    %edi,%eax
  80060f:	c1 e8 0c             	shr    $0xc,%eax
  800612:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800619:	83 ec 0c             	sub    $0xc,%esp
  80061c:	25 07 0e 00 00       	and    $0xe07,%eax
  800621:	50                   	push   %eax
  800622:	56                   	push   %esi
  800623:	6a 00                	push   $0x0
  800625:	57                   	push   %edi
  800626:	6a 00                	push   $0x0
  800628:	e8 6a fb ff ff       	call   800197 <sys_page_map>
  80062d:	89 c3                	mov    %eax,%ebx
  80062f:	83 c4 20             	add    $0x20,%esp
  800632:	85 c0                	test   %eax,%eax
  800634:	78 33                	js     800669 <dup+0xcd>
		goto err;

	return newfdnum;
  800636:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800639:	89 d8                	mov    %ebx,%eax
  80063b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80063e:	5b                   	pop    %ebx
  80063f:	5e                   	pop    %esi
  800640:	5f                   	pop    %edi
  800641:	5d                   	pop    %ebp
  800642:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800643:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80064a:	83 ec 0c             	sub    $0xc,%esp
  80064d:	25 07 0e 00 00       	and    $0xe07,%eax
  800652:	50                   	push   %eax
  800653:	ff 75 d4             	push   -0x2c(%ebp)
  800656:	6a 00                	push   $0x0
  800658:	53                   	push   %ebx
  800659:	6a 00                	push   $0x0
  80065b:	e8 37 fb ff ff       	call   800197 <sys_page_map>
  800660:	89 c3                	mov    %eax,%ebx
  800662:	83 c4 20             	add    $0x20,%esp
  800665:	85 c0                	test   %eax,%eax
  800667:	79 a4                	jns    80060d <dup+0x71>
	sys_page_unmap(0, newfd);
  800669:	83 ec 08             	sub    $0x8,%esp
  80066c:	56                   	push   %esi
  80066d:	6a 00                	push   $0x0
  80066f:	e8 65 fb ff ff       	call   8001d9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800674:	83 c4 08             	add    $0x8,%esp
  800677:	ff 75 d4             	push   -0x2c(%ebp)
  80067a:	6a 00                	push   $0x0
  80067c:	e8 58 fb ff ff       	call   8001d9 <sys_page_unmap>
	return r;
  800681:	83 c4 10             	add    $0x10,%esp
  800684:	eb b3                	jmp    800639 <dup+0x9d>

00800686 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800686:	55                   	push   %ebp
  800687:	89 e5                	mov    %esp,%ebp
  800689:	56                   	push   %esi
  80068a:	53                   	push   %ebx
  80068b:	83 ec 18             	sub    $0x18,%esp
  80068e:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800691:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800694:	50                   	push   %eax
  800695:	56                   	push   %esi
  800696:	e8 82 fd ff ff       	call   80041d <fd_lookup>
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	85 c0                	test   %eax,%eax
  8006a0:	78 3c                	js     8006de <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a2:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8006a5:	83 ec 08             	sub    $0x8,%esp
  8006a8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006ab:	50                   	push   %eax
  8006ac:	ff 33                	push   (%ebx)
  8006ae:	e8 ba fd ff ff       	call   80046d <dev_lookup>
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	85 c0                	test   %eax,%eax
  8006b8:	78 24                	js     8006de <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006ba:	8b 43 08             	mov    0x8(%ebx),%eax
  8006bd:	83 e0 03             	and    $0x3,%eax
  8006c0:	83 f8 01             	cmp    $0x1,%eax
  8006c3:	74 20                	je     8006e5 <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006c8:	8b 40 08             	mov    0x8(%eax),%eax
  8006cb:	85 c0                	test   %eax,%eax
  8006cd:	74 37                	je     800706 <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006cf:	83 ec 04             	sub    $0x4,%esp
  8006d2:	ff 75 10             	push   0x10(%ebp)
  8006d5:	ff 75 0c             	push   0xc(%ebp)
  8006d8:	53                   	push   %ebx
  8006d9:	ff d0                	call   *%eax
  8006db:	83 c4 10             	add    $0x10,%esp
}
  8006de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006e1:	5b                   	pop    %ebx
  8006e2:	5e                   	pop    %esi
  8006e3:	5d                   	pop    %ebp
  8006e4:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006e5:	a1 00 40 80 00       	mov    0x804000,%eax
  8006ea:	8b 40 58             	mov    0x58(%eax),%eax
  8006ed:	83 ec 04             	sub    $0x4,%esp
  8006f0:	56                   	push   %esi
  8006f1:	50                   	push   %eax
  8006f2:	68 b9 22 80 00       	push   $0x8022b9
  8006f7:	e8 93 0e 00 00       	call   80158f <cprintf>
		return -E_INVAL;
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800704:	eb d8                	jmp    8006de <read+0x58>
		return -E_NOT_SUPP;
  800706:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80070b:	eb d1                	jmp    8006de <read+0x58>

0080070d <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80070d:	55                   	push   %ebp
  80070e:	89 e5                	mov    %esp,%ebp
  800710:	57                   	push   %edi
  800711:	56                   	push   %esi
  800712:	53                   	push   %ebx
  800713:	83 ec 0c             	sub    $0xc,%esp
  800716:	8b 7d 08             	mov    0x8(%ebp),%edi
  800719:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80071c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800721:	eb 02                	jmp    800725 <readn+0x18>
  800723:	01 c3                	add    %eax,%ebx
  800725:	39 f3                	cmp    %esi,%ebx
  800727:	73 21                	jae    80074a <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800729:	83 ec 04             	sub    $0x4,%esp
  80072c:	89 f0                	mov    %esi,%eax
  80072e:	29 d8                	sub    %ebx,%eax
  800730:	50                   	push   %eax
  800731:	89 d8                	mov    %ebx,%eax
  800733:	03 45 0c             	add    0xc(%ebp),%eax
  800736:	50                   	push   %eax
  800737:	57                   	push   %edi
  800738:	e8 49 ff ff ff       	call   800686 <read>
		if (m < 0)
  80073d:	83 c4 10             	add    $0x10,%esp
  800740:	85 c0                	test   %eax,%eax
  800742:	78 04                	js     800748 <readn+0x3b>
			return m;
		if (m == 0)
  800744:	75 dd                	jne    800723 <readn+0x16>
  800746:	eb 02                	jmp    80074a <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800748:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80074a:	89 d8                	mov    %ebx,%eax
  80074c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80074f:	5b                   	pop    %ebx
  800750:	5e                   	pop    %esi
  800751:	5f                   	pop    %edi
  800752:	5d                   	pop    %ebp
  800753:	c3                   	ret    

00800754 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800754:	55                   	push   %ebp
  800755:	89 e5                	mov    %esp,%ebp
  800757:	56                   	push   %esi
  800758:	53                   	push   %ebx
  800759:	83 ec 18             	sub    $0x18,%esp
  80075c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80075f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800762:	50                   	push   %eax
  800763:	53                   	push   %ebx
  800764:	e8 b4 fc ff ff       	call   80041d <fd_lookup>
  800769:	83 c4 10             	add    $0x10,%esp
  80076c:	85 c0                	test   %eax,%eax
  80076e:	78 37                	js     8007a7 <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800770:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800773:	83 ec 08             	sub    $0x8,%esp
  800776:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800779:	50                   	push   %eax
  80077a:	ff 36                	push   (%esi)
  80077c:	e8 ec fc ff ff       	call   80046d <dev_lookup>
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	85 c0                	test   %eax,%eax
  800786:	78 1f                	js     8007a7 <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800788:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80078c:	74 20                	je     8007ae <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80078e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800791:	8b 40 0c             	mov    0xc(%eax),%eax
  800794:	85 c0                	test   %eax,%eax
  800796:	74 37                	je     8007cf <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800798:	83 ec 04             	sub    $0x4,%esp
  80079b:	ff 75 10             	push   0x10(%ebp)
  80079e:	ff 75 0c             	push   0xc(%ebp)
  8007a1:	56                   	push   %esi
  8007a2:	ff d0                	call   *%eax
  8007a4:	83 c4 10             	add    $0x10,%esp
}
  8007a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007aa:	5b                   	pop    %ebx
  8007ab:	5e                   	pop    %esi
  8007ac:	5d                   	pop    %ebp
  8007ad:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007ae:	a1 00 40 80 00       	mov    0x804000,%eax
  8007b3:	8b 40 58             	mov    0x58(%eax),%eax
  8007b6:	83 ec 04             	sub    $0x4,%esp
  8007b9:	53                   	push   %ebx
  8007ba:	50                   	push   %eax
  8007bb:	68 d5 22 80 00       	push   $0x8022d5
  8007c0:	e8 ca 0d 00 00       	call   80158f <cprintf>
		return -E_INVAL;
  8007c5:	83 c4 10             	add    $0x10,%esp
  8007c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007cd:	eb d8                	jmp    8007a7 <write+0x53>
		return -E_NOT_SUPP;
  8007cf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007d4:	eb d1                	jmp    8007a7 <write+0x53>

008007d6 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007df:	50                   	push   %eax
  8007e0:	ff 75 08             	push   0x8(%ebp)
  8007e3:	e8 35 fc ff ff       	call   80041d <fd_lookup>
  8007e8:	83 c4 10             	add    $0x10,%esp
  8007eb:	85 c0                	test   %eax,%eax
  8007ed:	78 0e                	js     8007fd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007f5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    

008007ff <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	56                   	push   %esi
  800803:	53                   	push   %ebx
  800804:	83 ec 18             	sub    $0x18,%esp
  800807:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80080a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80080d:	50                   	push   %eax
  80080e:	53                   	push   %ebx
  80080f:	e8 09 fc ff ff       	call   80041d <fd_lookup>
  800814:	83 c4 10             	add    $0x10,%esp
  800817:	85 c0                	test   %eax,%eax
  800819:	78 34                	js     80084f <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80081b:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80081e:	83 ec 08             	sub    $0x8,%esp
  800821:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800824:	50                   	push   %eax
  800825:	ff 36                	push   (%esi)
  800827:	e8 41 fc ff ff       	call   80046d <dev_lookup>
  80082c:	83 c4 10             	add    $0x10,%esp
  80082f:	85 c0                	test   %eax,%eax
  800831:	78 1c                	js     80084f <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800833:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800837:	74 1d                	je     800856 <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  800839:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083c:	8b 40 18             	mov    0x18(%eax),%eax
  80083f:	85 c0                	test   %eax,%eax
  800841:	74 34                	je     800877 <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800843:	83 ec 08             	sub    $0x8,%esp
  800846:	ff 75 0c             	push   0xc(%ebp)
  800849:	56                   	push   %esi
  80084a:	ff d0                	call   *%eax
  80084c:	83 c4 10             	add    $0x10,%esp
}
  80084f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800852:	5b                   	pop    %ebx
  800853:	5e                   	pop    %esi
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    
			thisenv->env_id, fdnum);
  800856:	a1 00 40 80 00       	mov    0x804000,%eax
  80085b:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80085e:	83 ec 04             	sub    $0x4,%esp
  800861:	53                   	push   %ebx
  800862:	50                   	push   %eax
  800863:	68 98 22 80 00       	push   $0x802298
  800868:	e8 22 0d 00 00       	call   80158f <cprintf>
		return -E_INVAL;
  80086d:	83 c4 10             	add    $0x10,%esp
  800870:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800875:	eb d8                	jmp    80084f <ftruncate+0x50>
		return -E_NOT_SUPP;
  800877:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80087c:	eb d1                	jmp    80084f <ftruncate+0x50>

0080087e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
  800883:	83 ec 18             	sub    $0x18,%esp
  800886:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800889:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80088c:	50                   	push   %eax
  80088d:	ff 75 08             	push   0x8(%ebp)
  800890:	e8 88 fb ff ff       	call   80041d <fd_lookup>
  800895:	83 c4 10             	add    $0x10,%esp
  800898:	85 c0                	test   %eax,%eax
  80089a:	78 49                	js     8008e5 <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80089c:	8b 75 f0             	mov    -0x10(%ebp),%esi
  80089f:	83 ec 08             	sub    $0x8,%esp
  8008a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008a5:	50                   	push   %eax
  8008a6:	ff 36                	push   (%esi)
  8008a8:	e8 c0 fb ff ff       	call   80046d <dev_lookup>
  8008ad:	83 c4 10             	add    $0x10,%esp
  8008b0:	85 c0                	test   %eax,%eax
  8008b2:	78 31                	js     8008e5 <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8008b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008b7:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008bb:	74 2f                	je     8008ec <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008bd:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c0:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008c7:	00 00 00 
	stat->st_isdir = 0;
  8008ca:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008d1:	00 00 00 
	stat->st_dev = dev;
  8008d4:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008da:	83 ec 08             	sub    $0x8,%esp
  8008dd:	53                   	push   %ebx
  8008de:	56                   	push   %esi
  8008df:	ff 50 14             	call   *0x14(%eax)
  8008e2:	83 c4 10             	add    $0x10,%esp
}
  8008e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008e8:	5b                   	pop    %ebx
  8008e9:	5e                   	pop    %esi
  8008ea:	5d                   	pop    %ebp
  8008eb:	c3                   	ret    
		return -E_NOT_SUPP;
  8008ec:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008f1:	eb f2                	jmp    8008e5 <fstat+0x67>

008008f3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	56                   	push   %esi
  8008f7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008f8:	83 ec 08             	sub    $0x8,%esp
  8008fb:	6a 00                	push   $0x0
  8008fd:	ff 75 08             	push   0x8(%ebp)
  800900:	e8 e4 01 00 00       	call   800ae9 <open>
  800905:	89 c3                	mov    %eax,%ebx
  800907:	83 c4 10             	add    $0x10,%esp
  80090a:	85 c0                	test   %eax,%eax
  80090c:	78 1b                	js     800929 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80090e:	83 ec 08             	sub    $0x8,%esp
  800911:	ff 75 0c             	push   0xc(%ebp)
  800914:	50                   	push   %eax
  800915:	e8 64 ff ff ff       	call   80087e <fstat>
  80091a:	89 c6                	mov    %eax,%esi
	close(fd);
  80091c:	89 1c 24             	mov    %ebx,(%esp)
  80091f:	e8 26 fc ff ff       	call   80054a <close>
	return r;
  800924:	83 c4 10             	add    $0x10,%esp
  800927:	89 f3                	mov    %esi,%ebx
}
  800929:	89 d8                	mov    %ebx,%eax
  80092b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80092e:	5b                   	pop    %ebx
  80092f:	5e                   	pop    %esi
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800932:	55                   	push   %ebp
  800933:	89 e5                	mov    %esp,%ebp
  800935:	56                   	push   %esi
  800936:	53                   	push   %ebx
  800937:	89 c6                	mov    %eax,%esi
  800939:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80093b:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800942:	74 27                	je     80096b <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800944:	6a 07                	push   $0x7
  800946:	68 00 50 80 00       	push   $0x805000
  80094b:	56                   	push   %esi
  80094c:	ff 35 00 60 80 00    	push   0x806000
  800952:	e8 c2 15 00 00       	call   801f19 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800957:	83 c4 0c             	add    $0xc,%esp
  80095a:	6a 00                	push   $0x0
  80095c:	53                   	push   %ebx
  80095d:	6a 00                	push   $0x0
  80095f:	e8 45 15 00 00       	call   801ea9 <ipc_recv>
}
  800964:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800967:	5b                   	pop    %ebx
  800968:	5e                   	pop    %esi
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80096b:	83 ec 0c             	sub    $0xc,%esp
  80096e:	6a 01                	push   $0x1
  800970:	e8 f8 15 00 00       	call   801f6d <ipc_find_env>
  800975:	a3 00 60 80 00       	mov    %eax,0x806000
  80097a:	83 c4 10             	add    $0x10,%esp
  80097d:	eb c5                	jmp    800944 <fsipc+0x12>

0080097f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 40 0c             	mov    0xc(%eax),%eax
  80098b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800990:	8b 45 0c             	mov    0xc(%ebp),%eax
  800993:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800998:	ba 00 00 00 00       	mov    $0x0,%edx
  80099d:	b8 02 00 00 00       	mov    $0x2,%eax
  8009a2:	e8 8b ff ff ff       	call   800932 <fsipc>
}
  8009a7:	c9                   	leave  
  8009a8:	c3                   	ret    

008009a9 <devfile_flush>:
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009af:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b5:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bf:	b8 06 00 00 00       	mov    $0x6,%eax
  8009c4:	e8 69 ff ff ff       	call   800932 <fsipc>
}
  8009c9:	c9                   	leave  
  8009ca:	c3                   	ret    

008009cb <devfile_stat>:
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	53                   	push   %ebx
  8009cf:	83 ec 04             	sub    $0x4,%esp
  8009d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8009db:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e5:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ea:	e8 43 ff ff ff       	call   800932 <fsipc>
  8009ef:	85 c0                	test   %eax,%eax
  8009f1:	78 2c                	js     800a1f <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009f3:	83 ec 08             	sub    $0x8,%esp
  8009f6:	68 00 50 80 00       	push   $0x805000
  8009fb:	53                   	push   %ebx
  8009fc:	e8 68 11 00 00       	call   801b69 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a01:	a1 80 50 80 00       	mov    0x805080,%eax
  800a06:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a0c:	a1 84 50 80 00       	mov    0x805084,%eax
  800a11:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a17:	83 c4 10             	add    $0x10,%esp
  800a1a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a22:	c9                   	leave  
  800a23:	c3                   	ret    

00800a24 <devfile_write>:
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	83 ec 0c             	sub    $0xc,%esp
  800a2a:	8b 45 10             	mov    0x10(%ebp),%eax
  800a2d:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a32:	39 d0                	cmp    %edx,%eax
  800a34:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a37:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3a:	8b 52 0c             	mov    0xc(%edx),%edx
  800a3d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a43:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a48:	50                   	push   %eax
  800a49:	ff 75 0c             	push   0xc(%ebp)
  800a4c:	68 08 50 80 00       	push   $0x805008
  800a51:	e8 a9 12 00 00       	call   801cff <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800a56:	ba 00 00 00 00       	mov    $0x0,%edx
  800a5b:	b8 04 00 00 00       	mov    $0x4,%eax
  800a60:	e8 cd fe ff ff       	call   800932 <fsipc>
}
  800a65:	c9                   	leave  
  800a66:	c3                   	ret    

00800a67 <devfile_read>:
{
  800a67:	55                   	push   %ebp
  800a68:	89 e5                	mov    %esp,%ebp
  800a6a:	56                   	push   %esi
  800a6b:	53                   	push   %ebx
  800a6c:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a6f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a72:	8b 40 0c             	mov    0xc(%eax),%eax
  800a75:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a7a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a80:	ba 00 00 00 00       	mov    $0x0,%edx
  800a85:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8a:	e8 a3 fe ff ff       	call   800932 <fsipc>
  800a8f:	89 c3                	mov    %eax,%ebx
  800a91:	85 c0                	test   %eax,%eax
  800a93:	78 1f                	js     800ab4 <devfile_read+0x4d>
	assert(r <= n);
  800a95:	39 f0                	cmp    %esi,%eax
  800a97:	77 24                	ja     800abd <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a99:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a9e:	7f 33                	jg     800ad3 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aa0:	83 ec 04             	sub    $0x4,%esp
  800aa3:	50                   	push   %eax
  800aa4:	68 00 50 80 00       	push   $0x805000
  800aa9:	ff 75 0c             	push   0xc(%ebp)
  800aac:	e8 4e 12 00 00       	call   801cff <memmove>
	return r;
  800ab1:	83 c4 10             	add    $0x10,%esp
}
  800ab4:	89 d8                	mov    %ebx,%eax
  800ab6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    
	assert(r <= n);
  800abd:	68 08 23 80 00       	push   $0x802308
  800ac2:	68 0f 23 80 00       	push   $0x80230f
  800ac7:	6a 7c                	push   $0x7c
  800ac9:	68 24 23 80 00       	push   $0x802324
  800ace:	e8 e1 09 00 00       	call   8014b4 <_panic>
	assert(r <= PGSIZE);
  800ad3:	68 2f 23 80 00       	push   $0x80232f
  800ad8:	68 0f 23 80 00       	push   $0x80230f
  800add:	6a 7d                	push   $0x7d
  800adf:	68 24 23 80 00       	push   $0x802324
  800ae4:	e8 cb 09 00 00       	call   8014b4 <_panic>

00800ae9 <open>:
{
  800ae9:	55                   	push   %ebp
  800aea:	89 e5                	mov    %esp,%ebp
  800aec:	56                   	push   %esi
  800aed:	53                   	push   %ebx
  800aee:	83 ec 1c             	sub    $0x1c,%esp
  800af1:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800af4:	56                   	push   %esi
  800af5:	e8 34 10 00 00       	call   801b2e <strlen>
  800afa:	83 c4 10             	add    $0x10,%esp
  800afd:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b02:	7f 6c                	jg     800b70 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800b04:	83 ec 0c             	sub    $0xc,%esp
  800b07:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b0a:	50                   	push   %eax
  800b0b:	e8 bd f8 ff ff       	call   8003cd <fd_alloc>
  800b10:	89 c3                	mov    %eax,%ebx
  800b12:	83 c4 10             	add    $0x10,%esp
  800b15:	85 c0                	test   %eax,%eax
  800b17:	78 3c                	js     800b55 <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800b19:	83 ec 08             	sub    $0x8,%esp
  800b1c:	56                   	push   %esi
  800b1d:	68 00 50 80 00       	push   $0x805000
  800b22:	e8 42 10 00 00       	call   801b69 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2a:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b2f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b32:	b8 01 00 00 00       	mov    $0x1,%eax
  800b37:	e8 f6 fd ff ff       	call   800932 <fsipc>
  800b3c:	89 c3                	mov    %eax,%ebx
  800b3e:	83 c4 10             	add    $0x10,%esp
  800b41:	85 c0                	test   %eax,%eax
  800b43:	78 19                	js     800b5e <open+0x75>
	return fd2num(fd);
  800b45:	83 ec 0c             	sub    $0xc,%esp
  800b48:	ff 75 f4             	push   -0xc(%ebp)
  800b4b:	e8 56 f8 ff ff       	call   8003a6 <fd2num>
  800b50:	89 c3                	mov    %eax,%ebx
  800b52:	83 c4 10             	add    $0x10,%esp
}
  800b55:	89 d8                	mov    %ebx,%eax
  800b57:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b5a:	5b                   	pop    %ebx
  800b5b:	5e                   	pop    %esi
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    
		fd_close(fd, 0);
  800b5e:	83 ec 08             	sub    $0x8,%esp
  800b61:	6a 00                	push   $0x0
  800b63:	ff 75 f4             	push   -0xc(%ebp)
  800b66:	e8 58 f9 ff ff       	call   8004c3 <fd_close>
		return r;
  800b6b:	83 c4 10             	add    $0x10,%esp
  800b6e:	eb e5                	jmp    800b55 <open+0x6c>
		return -E_BAD_PATH;
  800b70:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b75:	eb de                	jmp    800b55 <open+0x6c>

00800b77 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b77:	55                   	push   %ebp
  800b78:	89 e5                	mov    %esp,%ebp
  800b7a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b7d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b82:	b8 08 00 00 00       	mov    $0x8,%eax
  800b87:	e8 a6 fd ff ff       	call   800932 <fsipc>
}
  800b8c:	c9                   	leave  
  800b8d:	c3                   	ret    

00800b8e <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b94:	68 3b 23 80 00       	push   $0x80233b
  800b99:	ff 75 0c             	push   0xc(%ebp)
  800b9c:	e8 c8 0f 00 00       	call   801b69 <strcpy>
	return 0;
}
  800ba1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba6:	c9                   	leave  
  800ba7:	c3                   	ret    

00800ba8 <devsock_close>:
{
  800ba8:	55                   	push   %ebp
  800ba9:	89 e5                	mov    %esp,%ebp
  800bab:	53                   	push   %ebx
  800bac:	83 ec 10             	sub    $0x10,%esp
  800baf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bb2:	53                   	push   %ebx
  800bb3:	e8 f4 13 00 00       	call   801fac <pageref>
  800bb8:	89 c2                	mov    %eax,%edx
  800bba:	83 c4 10             	add    $0x10,%esp
		return 0;
  800bbd:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800bc2:	83 fa 01             	cmp    $0x1,%edx
  800bc5:	74 05                	je     800bcc <devsock_close+0x24>
}
  800bc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bca:	c9                   	leave  
  800bcb:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800bcc:	83 ec 0c             	sub    $0xc,%esp
  800bcf:	ff 73 0c             	push   0xc(%ebx)
  800bd2:	e8 b7 02 00 00       	call   800e8e <nsipc_close>
  800bd7:	83 c4 10             	add    $0x10,%esp
  800bda:	eb eb                	jmp    800bc7 <devsock_close+0x1f>

00800bdc <devsock_write>:
{
  800bdc:	55                   	push   %ebp
  800bdd:	89 e5                	mov    %esp,%ebp
  800bdf:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800be2:	6a 00                	push   $0x0
  800be4:	ff 75 10             	push   0x10(%ebp)
  800be7:	ff 75 0c             	push   0xc(%ebp)
  800bea:	8b 45 08             	mov    0x8(%ebp),%eax
  800bed:	ff 70 0c             	push   0xc(%eax)
  800bf0:	e8 79 03 00 00       	call   800f6e <nsipc_send>
}
  800bf5:	c9                   	leave  
  800bf6:	c3                   	ret    

00800bf7 <devsock_read>:
{
  800bf7:	55                   	push   %ebp
  800bf8:	89 e5                	mov    %esp,%ebp
  800bfa:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800bfd:	6a 00                	push   $0x0
  800bff:	ff 75 10             	push   0x10(%ebp)
  800c02:	ff 75 0c             	push   0xc(%ebp)
  800c05:	8b 45 08             	mov    0x8(%ebp),%eax
  800c08:	ff 70 0c             	push   0xc(%eax)
  800c0b:	e8 ef 02 00 00       	call   800eff <nsipc_recv>
}
  800c10:	c9                   	leave  
  800c11:	c3                   	ret    

00800c12 <fd2sockid>:
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c18:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c1b:	52                   	push   %edx
  800c1c:	50                   	push   %eax
  800c1d:	e8 fb f7 ff ff       	call   80041d <fd_lookup>
  800c22:	83 c4 10             	add    $0x10,%esp
  800c25:	85 c0                	test   %eax,%eax
  800c27:	78 10                	js     800c39 <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c2c:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c32:	39 08                	cmp    %ecx,(%eax)
  800c34:	75 05                	jne    800c3b <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c36:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c39:	c9                   	leave  
  800c3a:	c3                   	ret    
		return -E_NOT_SUPP;
  800c3b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c40:	eb f7                	jmp    800c39 <fd2sockid+0x27>

00800c42 <alloc_sockfd>:
{
  800c42:	55                   	push   %ebp
  800c43:	89 e5                	mov    %esp,%ebp
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	83 ec 1c             	sub    $0x1c,%esp
  800c4a:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c4f:	50                   	push   %eax
  800c50:	e8 78 f7 ff ff       	call   8003cd <fd_alloc>
  800c55:	89 c3                	mov    %eax,%ebx
  800c57:	83 c4 10             	add    $0x10,%esp
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	78 43                	js     800ca1 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c5e:	83 ec 04             	sub    $0x4,%esp
  800c61:	68 07 04 00 00       	push   $0x407
  800c66:	ff 75 f4             	push   -0xc(%ebp)
  800c69:	6a 00                	push   $0x0
  800c6b:	e8 e4 f4 ff ff       	call   800154 <sys_page_alloc>
  800c70:	89 c3                	mov    %eax,%ebx
  800c72:	83 c4 10             	add    $0x10,%esp
  800c75:	85 c0                	test   %eax,%eax
  800c77:	78 28                	js     800ca1 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c7c:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c82:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c87:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c8e:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800c91:	83 ec 0c             	sub    $0xc,%esp
  800c94:	50                   	push   %eax
  800c95:	e8 0c f7 ff ff       	call   8003a6 <fd2num>
  800c9a:	89 c3                	mov    %eax,%ebx
  800c9c:	83 c4 10             	add    $0x10,%esp
  800c9f:	eb 0c                	jmp    800cad <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800ca1:	83 ec 0c             	sub    $0xc,%esp
  800ca4:	56                   	push   %esi
  800ca5:	e8 e4 01 00 00       	call   800e8e <nsipc_close>
		return r;
  800caa:	83 c4 10             	add    $0x10,%esp
}
  800cad:	89 d8                	mov    %ebx,%eax
  800caf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5d                   	pop    %ebp
  800cb5:	c3                   	ret    

00800cb6 <accept>:
{
  800cb6:	55                   	push   %ebp
  800cb7:	89 e5                	mov    %esp,%ebp
  800cb9:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cbc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbf:	e8 4e ff ff ff       	call   800c12 <fd2sockid>
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	78 1b                	js     800ce3 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cc8:	83 ec 04             	sub    $0x4,%esp
  800ccb:	ff 75 10             	push   0x10(%ebp)
  800cce:	ff 75 0c             	push   0xc(%ebp)
  800cd1:	50                   	push   %eax
  800cd2:	e8 0e 01 00 00       	call   800de5 <nsipc_accept>
  800cd7:	83 c4 10             	add    $0x10,%esp
  800cda:	85 c0                	test   %eax,%eax
  800cdc:	78 05                	js     800ce3 <accept+0x2d>
	return alloc_sockfd(r);
  800cde:	e8 5f ff ff ff       	call   800c42 <alloc_sockfd>
}
  800ce3:	c9                   	leave  
  800ce4:	c3                   	ret    

00800ce5 <bind>:
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800ceb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cee:	e8 1f ff ff ff       	call   800c12 <fd2sockid>
  800cf3:	85 c0                	test   %eax,%eax
  800cf5:	78 12                	js     800d09 <bind+0x24>
	return nsipc_bind(r, name, namelen);
  800cf7:	83 ec 04             	sub    $0x4,%esp
  800cfa:	ff 75 10             	push   0x10(%ebp)
  800cfd:	ff 75 0c             	push   0xc(%ebp)
  800d00:	50                   	push   %eax
  800d01:	e8 31 01 00 00       	call   800e37 <nsipc_bind>
  800d06:	83 c4 10             	add    $0x10,%esp
}
  800d09:	c9                   	leave  
  800d0a:	c3                   	ret    

00800d0b <shutdown>:
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d11:	8b 45 08             	mov    0x8(%ebp),%eax
  800d14:	e8 f9 fe ff ff       	call   800c12 <fd2sockid>
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	78 0f                	js     800d2c <shutdown+0x21>
	return nsipc_shutdown(r, how);
  800d1d:	83 ec 08             	sub    $0x8,%esp
  800d20:	ff 75 0c             	push   0xc(%ebp)
  800d23:	50                   	push   %eax
  800d24:	e8 43 01 00 00       	call   800e6c <nsipc_shutdown>
  800d29:	83 c4 10             	add    $0x10,%esp
}
  800d2c:	c9                   	leave  
  800d2d:	c3                   	ret    

00800d2e <connect>:
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d34:	8b 45 08             	mov    0x8(%ebp),%eax
  800d37:	e8 d6 fe ff ff       	call   800c12 <fd2sockid>
  800d3c:	85 c0                	test   %eax,%eax
  800d3e:	78 12                	js     800d52 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  800d40:	83 ec 04             	sub    $0x4,%esp
  800d43:	ff 75 10             	push   0x10(%ebp)
  800d46:	ff 75 0c             	push   0xc(%ebp)
  800d49:	50                   	push   %eax
  800d4a:	e8 59 01 00 00       	call   800ea8 <nsipc_connect>
  800d4f:	83 c4 10             	add    $0x10,%esp
}
  800d52:	c9                   	leave  
  800d53:	c3                   	ret    

00800d54 <listen>:
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5d:	e8 b0 fe ff ff       	call   800c12 <fd2sockid>
  800d62:	85 c0                	test   %eax,%eax
  800d64:	78 0f                	js     800d75 <listen+0x21>
	return nsipc_listen(r, backlog);
  800d66:	83 ec 08             	sub    $0x8,%esp
  800d69:	ff 75 0c             	push   0xc(%ebp)
  800d6c:	50                   	push   %eax
  800d6d:	e8 6b 01 00 00       	call   800edd <nsipc_listen>
  800d72:	83 c4 10             	add    $0x10,%esp
}
  800d75:	c9                   	leave  
  800d76:	c3                   	ret    

00800d77 <socket>:

int
socket(int domain, int type, int protocol)
{
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d7d:	ff 75 10             	push   0x10(%ebp)
  800d80:	ff 75 0c             	push   0xc(%ebp)
  800d83:	ff 75 08             	push   0x8(%ebp)
  800d86:	e8 41 02 00 00       	call   800fcc <nsipc_socket>
  800d8b:	83 c4 10             	add    $0x10,%esp
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	78 05                	js     800d97 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800d92:	e8 ab fe ff ff       	call   800c42 <alloc_sockfd>
}
  800d97:	c9                   	leave  
  800d98:	c3                   	ret    

00800d99 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	53                   	push   %ebx
  800d9d:	83 ec 04             	sub    $0x4,%esp
  800da0:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800da2:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  800da9:	74 26                	je     800dd1 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dab:	6a 07                	push   $0x7
  800dad:	68 00 70 80 00       	push   $0x807000
  800db2:	53                   	push   %ebx
  800db3:	ff 35 00 80 80 00    	push   0x808000
  800db9:	e8 5b 11 00 00       	call   801f19 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dbe:	83 c4 0c             	add    $0xc,%esp
  800dc1:	6a 00                	push   $0x0
  800dc3:	6a 00                	push   $0x0
  800dc5:	6a 00                	push   $0x0
  800dc7:	e8 dd 10 00 00       	call   801ea9 <ipc_recv>
}
  800dcc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dcf:	c9                   	leave  
  800dd0:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dd1:	83 ec 0c             	sub    $0xc,%esp
  800dd4:	6a 02                	push   $0x2
  800dd6:	e8 92 11 00 00       	call   801f6d <ipc_find_env>
  800ddb:	a3 00 80 80 00       	mov    %eax,0x808000
  800de0:	83 c4 10             	add    $0x10,%esp
  800de3:	eb c6                	jmp    800dab <nsipc+0x12>

00800de5 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	56                   	push   %esi
  800de9:	53                   	push   %ebx
  800dea:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800ded:	8b 45 08             	mov    0x8(%ebp),%eax
  800df0:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800df5:	8b 06                	mov    (%esi),%eax
  800df7:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800dfc:	b8 01 00 00 00       	mov    $0x1,%eax
  800e01:	e8 93 ff ff ff       	call   800d99 <nsipc>
  800e06:	89 c3                	mov    %eax,%ebx
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	79 09                	jns    800e15 <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800e0c:	89 d8                	mov    %ebx,%eax
  800e0e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e11:	5b                   	pop    %ebx
  800e12:	5e                   	pop    %esi
  800e13:	5d                   	pop    %ebp
  800e14:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e15:	83 ec 04             	sub    $0x4,%esp
  800e18:	ff 35 10 70 80 00    	push   0x807010
  800e1e:	68 00 70 80 00       	push   $0x807000
  800e23:	ff 75 0c             	push   0xc(%ebp)
  800e26:	e8 d4 0e 00 00       	call   801cff <memmove>
		*addrlen = ret->ret_addrlen;
  800e2b:	a1 10 70 80 00       	mov    0x807010,%eax
  800e30:	89 06                	mov    %eax,(%esi)
  800e32:	83 c4 10             	add    $0x10,%esp
	return r;
  800e35:	eb d5                	jmp    800e0c <nsipc_accept+0x27>

00800e37 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e37:	55                   	push   %ebp
  800e38:	89 e5                	mov    %esp,%ebp
  800e3a:	53                   	push   %ebx
  800e3b:	83 ec 08             	sub    $0x8,%esp
  800e3e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e41:	8b 45 08             	mov    0x8(%ebp),%eax
  800e44:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e49:	53                   	push   %ebx
  800e4a:	ff 75 0c             	push   0xc(%ebp)
  800e4d:	68 04 70 80 00       	push   $0x807004
  800e52:	e8 a8 0e 00 00       	call   801cff <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e57:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  800e5d:	b8 02 00 00 00       	mov    $0x2,%eax
  800e62:	e8 32 ff ff ff       	call   800d99 <nsipc>
}
  800e67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e6a:	c9                   	leave  
  800e6b:	c3                   	ret    

00800e6c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e72:	8b 45 08             	mov    0x8(%ebp),%eax
  800e75:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  800e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  800e82:	b8 03 00 00 00       	mov    $0x3,%eax
  800e87:	e8 0d ff ff ff       	call   800d99 <nsipc>
}
  800e8c:	c9                   	leave  
  800e8d:	c3                   	ret    

00800e8e <nsipc_close>:

int
nsipc_close(int s)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e94:	8b 45 08             	mov    0x8(%ebp),%eax
  800e97:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  800e9c:	b8 04 00 00 00       	mov    $0x4,%eax
  800ea1:	e8 f3 fe ff ff       	call   800d99 <nsipc>
}
  800ea6:	c9                   	leave  
  800ea7:	c3                   	ret    

00800ea8 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ea8:	55                   	push   %ebp
  800ea9:	89 e5                	mov    %esp,%ebp
  800eab:	53                   	push   %ebx
  800eac:	83 ec 08             	sub    $0x8,%esp
  800eaf:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800eb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb5:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800eba:	53                   	push   %ebx
  800ebb:	ff 75 0c             	push   0xc(%ebp)
  800ebe:	68 04 70 80 00       	push   $0x807004
  800ec3:	e8 37 0e 00 00       	call   801cff <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ec8:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  800ece:	b8 05 00 00 00       	mov    $0x5,%eax
  800ed3:	e8 c1 fe ff ff       	call   800d99 <nsipc>
}
  800ed8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800edb:	c9                   	leave  
  800edc:	c3                   	ret    

00800edd <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ee3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee6:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  800eeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eee:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  800ef3:	b8 06 00 00 00       	mov    $0x6,%eax
  800ef8:	e8 9c fe ff ff       	call   800d99 <nsipc>
}
  800efd:	c9                   	leave  
  800efe:	c3                   	ret    

00800eff <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800eff:	55                   	push   %ebp
  800f00:	89 e5                	mov    %esp,%ebp
  800f02:	56                   	push   %esi
  800f03:	53                   	push   %ebx
  800f04:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f07:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  800f0f:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  800f15:	8b 45 14             	mov    0x14(%ebp),%eax
  800f18:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f1d:	b8 07 00 00 00       	mov    $0x7,%eax
  800f22:	e8 72 fe ff ff       	call   800d99 <nsipc>
  800f27:	89 c3                	mov    %eax,%ebx
  800f29:	85 c0                	test   %eax,%eax
  800f2b:	78 22                	js     800f4f <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  800f2d:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f32:	39 c6                	cmp    %eax,%esi
  800f34:	0f 4e c6             	cmovle %esi,%eax
  800f37:	39 c3                	cmp    %eax,%ebx
  800f39:	7f 1d                	jg     800f58 <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f3b:	83 ec 04             	sub    $0x4,%esp
  800f3e:	53                   	push   %ebx
  800f3f:	68 00 70 80 00       	push   $0x807000
  800f44:	ff 75 0c             	push   0xc(%ebp)
  800f47:	e8 b3 0d 00 00       	call   801cff <memmove>
  800f4c:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f4f:	89 d8                	mov    %ebx,%eax
  800f51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f54:	5b                   	pop    %ebx
  800f55:	5e                   	pop    %esi
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f58:	68 47 23 80 00       	push   $0x802347
  800f5d:	68 0f 23 80 00       	push   $0x80230f
  800f62:	6a 62                	push   $0x62
  800f64:	68 5c 23 80 00       	push   $0x80235c
  800f69:	e8 46 05 00 00       	call   8014b4 <_panic>

00800f6e <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	53                   	push   %ebx
  800f72:	83 ec 04             	sub    $0x4,%esp
  800f75:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f78:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  800f80:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f86:	7f 2e                	jg     800fb6 <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f88:	83 ec 04             	sub    $0x4,%esp
  800f8b:	53                   	push   %ebx
  800f8c:	ff 75 0c             	push   0xc(%ebp)
  800f8f:	68 0c 70 80 00       	push   $0x80700c
  800f94:	e8 66 0d 00 00       	call   801cff <memmove>
	nsipcbuf.send.req_size = size;
  800f99:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  800f9f:	8b 45 14             	mov    0x14(%ebp),%eax
  800fa2:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  800fa7:	b8 08 00 00 00       	mov    $0x8,%eax
  800fac:	e8 e8 fd ff ff       	call   800d99 <nsipc>
}
  800fb1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb4:	c9                   	leave  
  800fb5:	c3                   	ret    
	assert(size < 1600);
  800fb6:	68 68 23 80 00       	push   $0x802368
  800fbb:	68 0f 23 80 00       	push   $0x80230f
  800fc0:	6a 6d                	push   $0x6d
  800fc2:	68 5c 23 80 00       	push   $0x80235c
  800fc7:	e8 e8 04 00 00       	call   8014b4 <_panic>

00800fcc <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fcc:	55                   	push   %ebp
  800fcd:	89 e5                	mov    %esp,%ebp
  800fcf:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fd2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fd5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  800fda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdd:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  800fe2:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe5:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  800fea:	b8 09 00 00 00       	mov    $0x9,%eax
  800fef:	e8 a5 fd ff ff       	call   800d99 <nsipc>
}
  800ff4:	c9                   	leave  
  800ff5:	c3                   	ret    

00800ff6 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	56                   	push   %esi
  800ffa:	53                   	push   %ebx
  800ffb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800ffe:	83 ec 0c             	sub    $0xc,%esp
  801001:	ff 75 08             	push   0x8(%ebp)
  801004:	e8 ad f3 ff ff       	call   8003b6 <fd2data>
  801009:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80100b:	83 c4 08             	add    $0x8,%esp
  80100e:	68 74 23 80 00       	push   $0x802374
  801013:	53                   	push   %ebx
  801014:	e8 50 0b 00 00       	call   801b69 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801019:	8b 46 04             	mov    0x4(%esi),%eax
  80101c:	2b 06                	sub    (%esi),%eax
  80101e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801024:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80102b:	00 00 00 
	stat->st_dev = &devpipe;
  80102e:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801035:	30 80 00 
	return 0;
}
  801038:	b8 00 00 00 00       	mov    $0x0,%eax
  80103d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801040:	5b                   	pop    %ebx
  801041:	5e                   	pop    %esi
  801042:	5d                   	pop    %ebp
  801043:	c3                   	ret    

00801044 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	53                   	push   %ebx
  801048:	83 ec 0c             	sub    $0xc,%esp
  80104b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80104e:	53                   	push   %ebx
  80104f:	6a 00                	push   $0x0
  801051:	e8 83 f1 ff ff       	call   8001d9 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801056:	89 1c 24             	mov    %ebx,(%esp)
  801059:	e8 58 f3 ff ff       	call   8003b6 <fd2data>
  80105e:	83 c4 08             	add    $0x8,%esp
  801061:	50                   	push   %eax
  801062:	6a 00                	push   $0x0
  801064:	e8 70 f1 ff ff       	call   8001d9 <sys_page_unmap>
}
  801069:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80106c:	c9                   	leave  
  80106d:	c3                   	ret    

0080106e <_pipeisclosed>:
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	57                   	push   %edi
  801072:	56                   	push   %esi
  801073:	53                   	push   %ebx
  801074:	83 ec 1c             	sub    $0x1c,%esp
  801077:	89 c7                	mov    %eax,%edi
  801079:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80107b:	a1 00 40 80 00       	mov    0x804000,%eax
  801080:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801083:	83 ec 0c             	sub    $0xc,%esp
  801086:	57                   	push   %edi
  801087:	e8 20 0f 00 00       	call   801fac <pageref>
  80108c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80108f:	89 34 24             	mov    %esi,(%esp)
  801092:	e8 15 0f 00 00       	call   801fac <pageref>
		nn = thisenv->env_runs;
  801097:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80109d:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  8010a0:	83 c4 10             	add    $0x10,%esp
  8010a3:	39 cb                	cmp    %ecx,%ebx
  8010a5:	74 1b                	je     8010c2 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010a7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010aa:	75 cf                	jne    80107b <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010ac:	8b 42 68             	mov    0x68(%edx),%eax
  8010af:	6a 01                	push   $0x1
  8010b1:	50                   	push   %eax
  8010b2:	53                   	push   %ebx
  8010b3:	68 7b 23 80 00       	push   $0x80237b
  8010b8:	e8 d2 04 00 00       	call   80158f <cprintf>
  8010bd:	83 c4 10             	add    $0x10,%esp
  8010c0:	eb b9                	jmp    80107b <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010c2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010c5:	0f 94 c0             	sete   %al
  8010c8:	0f b6 c0             	movzbl %al,%eax
}
  8010cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010ce:	5b                   	pop    %ebx
  8010cf:	5e                   	pop    %esi
  8010d0:	5f                   	pop    %edi
  8010d1:	5d                   	pop    %ebp
  8010d2:	c3                   	ret    

008010d3 <devpipe_write>:
{
  8010d3:	55                   	push   %ebp
  8010d4:	89 e5                	mov    %esp,%ebp
  8010d6:	57                   	push   %edi
  8010d7:	56                   	push   %esi
  8010d8:	53                   	push   %ebx
  8010d9:	83 ec 28             	sub    $0x28,%esp
  8010dc:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8010df:	56                   	push   %esi
  8010e0:	e8 d1 f2 ff ff       	call   8003b6 <fd2data>
  8010e5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8010e7:	83 c4 10             	add    $0x10,%esp
  8010ea:	bf 00 00 00 00       	mov    $0x0,%edi
  8010ef:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8010f2:	75 09                	jne    8010fd <devpipe_write+0x2a>
	return i;
  8010f4:	89 f8                	mov    %edi,%eax
  8010f6:	eb 23                	jmp    80111b <devpipe_write+0x48>
			sys_yield();
  8010f8:	e8 38 f0 ff ff       	call   800135 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8010fd:	8b 43 04             	mov    0x4(%ebx),%eax
  801100:	8b 0b                	mov    (%ebx),%ecx
  801102:	8d 51 20             	lea    0x20(%ecx),%edx
  801105:	39 d0                	cmp    %edx,%eax
  801107:	72 1a                	jb     801123 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  801109:	89 da                	mov    %ebx,%edx
  80110b:	89 f0                	mov    %esi,%eax
  80110d:	e8 5c ff ff ff       	call   80106e <_pipeisclosed>
  801112:	85 c0                	test   %eax,%eax
  801114:	74 e2                	je     8010f8 <devpipe_write+0x25>
				return 0;
  801116:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80111b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80111e:	5b                   	pop    %ebx
  80111f:	5e                   	pop    %esi
  801120:	5f                   	pop    %edi
  801121:	5d                   	pop    %ebp
  801122:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801123:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801126:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80112a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80112d:	89 c2                	mov    %eax,%edx
  80112f:	c1 fa 1f             	sar    $0x1f,%edx
  801132:	89 d1                	mov    %edx,%ecx
  801134:	c1 e9 1b             	shr    $0x1b,%ecx
  801137:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80113a:	83 e2 1f             	and    $0x1f,%edx
  80113d:	29 ca                	sub    %ecx,%edx
  80113f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801143:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801147:	83 c0 01             	add    $0x1,%eax
  80114a:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80114d:	83 c7 01             	add    $0x1,%edi
  801150:	eb 9d                	jmp    8010ef <devpipe_write+0x1c>

00801152 <devpipe_read>:
{
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	57                   	push   %edi
  801156:	56                   	push   %esi
  801157:	53                   	push   %ebx
  801158:	83 ec 18             	sub    $0x18,%esp
  80115b:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80115e:	57                   	push   %edi
  80115f:	e8 52 f2 ff ff       	call   8003b6 <fd2data>
  801164:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801166:	83 c4 10             	add    $0x10,%esp
  801169:	be 00 00 00 00       	mov    $0x0,%esi
  80116e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801171:	75 13                	jne    801186 <devpipe_read+0x34>
	return i;
  801173:	89 f0                	mov    %esi,%eax
  801175:	eb 02                	jmp    801179 <devpipe_read+0x27>
				return i;
  801177:	89 f0                	mov    %esi,%eax
}
  801179:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80117c:	5b                   	pop    %ebx
  80117d:	5e                   	pop    %esi
  80117e:	5f                   	pop    %edi
  80117f:	5d                   	pop    %ebp
  801180:	c3                   	ret    
			sys_yield();
  801181:	e8 af ef ff ff       	call   800135 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801186:	8b 03                	mov    (%ebx),%eax
  801188:	3b 43 04             	cmp    0x4(%ebx),%eax
  80118b:	75 18                	jne    8011a5 <devpipe_read+0x53>
			if (i > 0)
  80118d:	85 f6                	test   %esi,%esi
  80118f:	75 e6                	jne    801177 <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801191:	89 da                	mov    %ebx,%edx
  801193:	89 f8                	mov    %edi,%eax
  801195:	e8 d4 fe ff ff       	call   80106e <_pipeisclosed>
  80119a:	85 c0                	test   %eax,%eax
  80119c:	74 e3                	je     801181 <devpipe_read+0x2f>
				return 0;
  80119e:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a3:	eb d4                	jmp    801179 <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011a5:	99                   	cltd   
  8011a6:	c1 ea 1b             	shr    $0x1b,%edx
  8011a9:	01 d0                	add    %edx,%eax
  8011ab:	83 e0 1f             	and    $0x1f,%eax
  8011ae:	29 d0                	sub    %edx,%eax
  8011b0:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b8:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011bb:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011be:	83 c6 01             	add    $0x1,%esi
  8011c1:	eb ab                	jmp    80116e <devpipe_read+0x1c>

008011c3 <pipe>:
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	56                   	push   %esi
  8011c7:	53                   	push   %ebx
  8011c8:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ce:	50                   	push   %eax
  8011cf:	e8 f9 f1 ff ff       	call   8003cd <fd_alloc>
  8011d4:	89 c3                	mov    %eax,%ebx
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	0f 88 23 01 00 00    	js     801304 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011e1:	83 ec 04             	sub    $0x4,%esp
  8011e4:	68 07 04 00 00       	push   $0x407
  8011e9:	ff 75 f4             	push   -0xc(%ebp)
  8011ec:	6a 00                	push   $0x0
  8011ee:	e8 61 ef ff ff       	call   800154 <sys_page_alloc>
  8011f3:	89 c3                	mov    %eax,%ebx
  8011f5:	83 c4 10             	add    $0x10,%esp
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	0f 88 04 01 00 00    	js     801304 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801200:	83 ec 0c             	sub    $0xc,%esp
  801203:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801206:	50                   	push   %eax
  801207:	e8 c1 f1 ff ff       	call   8003cd <fd_alloc>
  80120c:	89 c3                	mov    %eax,%ebx
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	85 c0                	test   %eax,%eax
  801213:	0f 88 db 00 00 00    	js     8012f4 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801219:	83 ec 04             	sub    $0x4,%esp
  80121c:	68 07 04 00 00       	push   $0x407
  801221:	ff 75 f0             	push   -0x10(%ebp)
  801224:	6a 00                	push   $0x0
  801226:	e8 29 ef ff ff       	call   800154 <sys_page_alloc>
  80122b:	89 c3                	mov    %eax,%ebx
  80122d:	83 c4 10             	add    $0x10,%esp
  801230:	85 c0                	test   %eax,%eax
  801232:	0f 88 bc 00 00 00    	js     8012f4 <pipe+0x131>
	va = fd2data(fd0);
  801238:	83 ec 0c             	sub    $0xc,%esp
  80123b:	ff 75 f4             	push   -0xc(%ebp)
  80123e:	e8 73 f1 ff ff       	call   8003b6 <fd2data>
  801243:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801245:	83 c4 0c             	add    $0xc,%esp
  801248:	68 07 04 00 00       	push   $0x407
  80124d:	50                   	push   %eax
  80124e:	6a 00                	push   $0x0
  801250:	e8 ff ee ff ff       	call   800154 <sys_page_alloc>
  801255:	89 c3                	mov    %eax,%ebx
  801257:	83 c4 10             	add    $0x10,%esp
  80125a:	85 c0                	test   %eax,%eax
  80125c:	0f 88 82 00 00 00    	js     8012e4 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801262:	83 ec 0c             	sub    $0xc,%esp
  801265:	ff 75 f0             	push   -0x10(%ebp)
  801268:	e8 49 f1 ff ff       	call   8003b6 <fd2data>
  80126d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801274:	50                   	push   %eax
  801275:	6a 00                	push   $0x0
  801277:	56                   	push   %esi
  801278:	6a 00                	push   $0x0
  80127a:	e8 18 ef ff ff       	call   800197 <sys_page_map>
  80127f:	89 c3                	mov    %eax,%ebx
  801281:	83 c4 20             	add    $0x20,%esp
  801284:	85 c0                	test   %eax,%eax
  801286:	78 4e                	js     8012d6 <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  801288:	a1 3c 30 80 00       	mov    0x80303c,%eax
  80128d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801290:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801292:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801295:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80129c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80129f:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012a1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a4:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012ab:	83 ec 0c             	sub    $0xc,%esp
  8012ae:	ff 75 f4             	push   -0xc(%ebp)
  8012b1:	e8 f0 f0 ff ff       	call   8003a6 <fd2num>
  8012b6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012b9:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012bb:	83 c4 04             	add    $0x4,%esp
  8012be:	ff 75 f0             	push   -0x10(%ebp)
  8012c1:	e8 e0 f0 ff ff       	call   8003a6 <fd2num>
  8012c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012c9:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012cc:	83 c4 10             	add    $0x10,%esp
  8012cf:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012d4:	eb 2e                	jmp    801304 <pipe+0x141>
	sys_page_unmap(0, va);
  8012d6:	83 ec 08             	sub    $0x8,%esp
  8012d9:	56                   	push   %esi
  8012da:	6a 00                	push   $0x0
  8012dc:	e8 f8 ee ff ff       	call   8001d9 <sys_page_unmap>
  8012e1:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8012e4:	83 ec 08             	sub    $0x8,%esp
  8012e7:	ff 75 f0             	push   -0x10(%ebp)
  8012ea:	6a 00                	push   $0x0
  8012ec:	e8 e8 ee ff ff       	call   8001d9 <sys_page_unmap>
  8012f1:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8012f4:	83 ec 08             	sub    $0x8,%esp
  8012f7:	ff 75 f4             	push   -0xc(%ebp)
  8012fa:	6a 00                	push   $0x0
  8012fc:	e8 d8 ee ff ff       	call   8001d9 <sys_page_unmap>
  801301:	83 c4 10             	add    $0x10,%esp
}
  801304:	89 d8                	mov    %ebx,%eax
  801306:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801309:	5b                   	pop    %ebx
  80130a:	5e                   	pop    %esi
  80130b:	5d                   	pop    %ebp
  80130c:	c3                   	ret    

0080130d <pipeisclosed>:
{
  80130d:	55                   	push   %ebp
  80130e:	89 e5                	mov    %esp,%ebp
  801310:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801313:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801316:	50                   	push   %eax
  801317:	ff 75 08             	push   0x8(%ebp)
  80131a:	e8 fe f0 ff ff       	call   80041d <fd_lookup>
  80131f:	83 c4 10             	add    $0x10,%esp
  801322:	85 c0                	test   %eax,%eax
  801324:	78 18                	js     80133e <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  801326:	83 ec 0c             	sub    $0xc,%esp
  801329:	ff 75 f4             	push   -0xc(%ebp)
  80132c:	e8 85 f0 ff ff       	call   8003b6 <fd2data>
  801331:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801333:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801336:	e8 33 fd ff ff       	call   80106e <_pipeisclosed>
  80133b:	83 c4 10             	add    $0x10,%esp
}
  80133e:	c9                   	leave  
  80133f:	c3                   	ret    

00801340 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801340:	b8 00 00 00 00       	mov    $0x0,%eax
  801345:	c3                   	ret    

00801346 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80134c:	68 93 23 80 00       	push   $0x802393
  801351:	ff 75 0c             	push   0xc(%ebp)
  801354:	e8 10 08 00 00       	call   801b69 <strcpy>
	return 0;
}
  801359:	b8 00 00 00 00       	mov    $0x0,%eax
  80135e:	c9                   	leave  
  80135f:	c3                   	ret    

00801360 <devcons_write>:
{
  801360:	55                   	push   %ebp
  801361:	89 e5                	mov    %esp,%ebp
  801363:	57                   	push   %edi
  801364:	56                   	push   %esi
  801365:	53                   	push   %ebx
  801366:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80136c:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801371:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801377:	eb 2e                	jmp    8013a7 <devcons_write+0x47>
		m = n - tot;
  801379:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80137c:	29 f3                	sub    %esi,%ebx
  80137e:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801383:	39 c3                	cmp    %eax,%ebx
  801385:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801388:	83 ec 04             	sub    $0x4,%esp
  80138b:	53                   	push   %ebx
  80138c:	89 f0                	mov    %esi,%eax
  80138e:	03 45 0c             	add    0xc(%ebp),%eax
  801391:	50                   	push   %eax
  801392:	57                   	push   %edi
  801393:	e8 67 09 00 00       	call   801cff <memmove>
		sys_cputs(buf, m);
  801398:	83 c4 08             	add    $0x8,%esp
  80139b:	53                   	push   %ebx
  80139c:	57                   	push   %edi
  80139d:	e8 f6 ec ff ff       	call   800098 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013a2:	01 de                	add    %ebx,%esi
  8013a4:	83 c4 10             	add    $0x10,%esp
  8013a7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013aa:	72 cd                	jb     801379 <devcons_write+0x19>
}
  8013ac:	89 f0                	mov    %esi,%eax
  8013ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b1:	5b                   	pop    %ebx
  8013b2:	5e                   	pop    %esi
  8013b3:	5f                   	pop    %edi
  8013b4:	5d                   	pop    %ebp
  8013b5:	c3                   	ret    

008013b6 <devcons_read>:
{
  8013b6:	55                   	push   %ebp
  8013b7:	89 e5                	mov    %esp,%ebp
  8013b9:	83 ec 08             	sub    $0x8,%esp
  8013bc:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8013c1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013c5:	75 07                	jne    8013ce <devcons_read+0x18>
  8013c7:	eb 1f                	jmp    8013e8 <devcons_read+0x32>
		sys_yield();
  8013c9:	e8 67 ed ff ff       	call   800135 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8013ce:	e8 e3 ec ff ff       	call   8000b6 <sys_cgetc>
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	74 f2                	je     8013c9 <devcons_read+0x13>
	if (c < 0)
  8013d7:	78 0f                	js     8013e8 <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8013d9:	83 f8 04             	cmp    $0x4,%eax
  8013dc:	74 0c                	je     8013ea <devcons_read+0x34>
	*(char*)vbuf = c;
  8013de:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013e1:	88 02                	mov    %al,(%edx)
	return 1;
  8013e3:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8013e8:	c9                   	leave  
  8013e9:	c3                   	ret    
		return 0;
  8013ea:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ef:	eb f7                	jmp    8013e8 <devcons_read+0x32>

008013f1 <cputchar>:
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013fa:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8013fd:	6a 01                	push   $0x1
  8013ff:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801402:	50                   	push   %eax
  801403:	e8 90 ec ff ff       	call   800098 <sys_cputs>
}
  801408:	83 c4 10             	add    $0x10,%esp
  80140b:	c9                   	leave  
  80140c:	c3                   	ret    

0080140d <getchar>:
{
  80140d:	55                   	push   %ebp
  80140e:	89 e5                	mov    %esp,%ebp
  801410:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801413:	6a 01                	push   $0x1
  801415:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801418:	50                   	push   %eax
  801419:	6a 00                	push   $0x0
  80141b:	e8 66 f2 ff ff       	call   800686 <read>
	if (r < 0)
  801420:	83 c4 10             	add    $0x10,%esp
  801423:	85 c0                	test   %eax,%eax
  801425:	78 06                	js     80142d <getchar+0x20>
	if (r < 1)
  801427:	74 06                	je     80142f <getchar+0x22>
	return c;
  801429:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80142d:	c9                   	leave  
  80142e:	c3                   	ret    
		return -E_EOF;
  80142f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801434:	eb f7                	jmp    80142d <getchar+0x20>

00801436 <iscons>:
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80143c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80143f:	50                   	push   %eax
  801440:	ff 75 08             	push   0x8(%ebp)
  801443:	e8 d5 ef ff ff       	call   80041d <fd_lookup>
  801448:	83 c4 10             	add    $0x10,%esp
  80144b:	85 c0                	test   %eax,%eax
  80144d:	78 11                	js     801460 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  80144f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801452:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801458:	39 10                	cmp    %edx,(%eax)
  80145a:	0f 94 c0             	sete   %al
  80145d:	0f b6 c0             	movzbl %al,%eax
}
  801460:	c9                   	leave  
  801461:	c3                   	ret    

00801462 <opencons>:
{
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801468:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80146b:	50                   	push   %eax
  80146c:	e8 5c ef ff ff       	call   8003cd <fd_alloc>
  801471:	83 c4 10             	add    $0x10,%esp
  801474:	85 c0                	test   %eax,%eax
  801476:	78 3a                	js     8014b2 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801478:	83 ec 04             	sub    $0x4,%esp
  80147b:	68 07 04 00 00       	push   $0x407
  801480:	ff 75 f4             	push   -0xc(%ebp)
  801483:	6a 00                	push   $0x0
  801485:	e8 ca ec ff ff       	call   800154 <sys_page_alloc>
  80148a:	83 c4 10             	add    $0x10,%esp
  80148d:	85 c0                	test   %eax,%eax
  80148f:	78 21                	js     8014b2 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801491:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801494:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80149a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80149c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014a6:	83 ec 0c             	sub    $0xc,%esp
  8014a9:	50                   	push   %eax
  8014aa:	e8 f7 ee ff ff       	call   8003a6 <fd2num>
  8014af:	83 c4 10             	add    $0x10,%esp
}
  8014b2:	c9                   	leave  
  8014b3:	c3                   	ret    

008014b4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014b4:	55                   	push   %ebp
  8014b5:	89 e5                	mov    %esp,%ebp
  8014b7:	56                   	push   %esi
  8014b8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014b9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014bc:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014c2:	e8 4f ec ff ff       	call   800116 <sys_getenvid>
  8014c7:	83 ec 0c             	sub    $0xc,%esp
  8014ca:	ff 75 0c             	push   0xc(%ebp)
  8014cd:	ff 75 08             	push   0x8(%ebp)
  8014d0:	56                   	push   %esi
  8014d1:	50                   	push   %eax
  8014d2:	68 a0 23 80 00       	push   $0x8023a0
  8014d7:	e8 b3 00 00 00       	call   80158f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014dc:	83 c4 18             	add    $0x18,%esp
  8014df:	53                   	push   %ebx
  8014e0:	ff 75 10             	push   0x10(%ebp)
  8014e3:	e8 56 00 00 00       	call   80153e <vcprintf>
	cprintf("\n");
  8014e8:	c7 04 24 8c 23 80 00 	movl   $0x80238c,(%esp)
  8014ef:	e8 9b 00 00 00       	call   80158f <cprintf>
  8014f4:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014f7:	cc                   	int3   
  8014f8:	eb fd                	jmp    8014f7 <_panic+0x43>

008014fa <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8014fa:	55                   	push   %ebp
  8014fb:	89 e5                	mov    %esp,%ebp
  8014fd:	53                   	push   %ebx
  8014fe:	83 ec 04             	sub    $0x4,%esp
  801501:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801504:	8b 13                	mov    (%ebx),%edx
  801506:	8d 42 01             	lea    0x1(%edx),%eax
  801509:	89 03                	mov    %eax,(%ebx)
  80150b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80150e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801512:	3d ff 00 00 00       	cmp    $0xff,%eax
  801517:	74 09                	je     801522 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  801519:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80151d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801520:	c9                   	leave  
  801521:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801522:	83 ec 08             	sub    $0x8,%esp
  801525:	68 ff 00 00 00       	push   $0xff
  80152a:	8d 43 08             	lea    0x8(%ebx),%eax
  80152d:	50                   	push   %eax
  80152e:	e8 65 eb ff ff       	call   800098 <sys_cputs>
		b->idx = 0;
  801533:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801539:	83 c4 10             	add    $0x10,%esp
  80153c:	eb db                	jmp    801519 <putch+0x1f>

0080153e <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80153e:	55                   	push   %ebp
  80153f:	89 e5                	mov    %esp,%ebp
  801541:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801547:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80154e:	00 00 00 
	b.cnt = 0;
  801551:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801558:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80155b:	ff 75 0c             	push   0xc(%ebp)
  80155e:	ff 75 08             	push   0x8(%ebp)
  801561:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801567:	50                   	push   %eax
  801568:	68 fa 14 80 00       	push   $0x8014fa
  80156d:	e8 14 01 00 00       	call   801686 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801572:	83 c4 08             	add    $0x8,%esp
  801575:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  80157b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801581:	50                   	push   %eax
  801582:	e8 11 eb ff ff       	call   800098 <sys_cputs>

	return b.cnt;
}
  801587:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80158d:	c9                   	leave  
  80158e:	c3                   	ret    

0080158f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80158f:	55                   	push   %ebp
  801590:	89 e5                	mov    %esp,%ebp
  801592:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801595:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801598:	50                   	push   %eax
  801599:	ff 75 08             	push   0x8(%ebp)
  80159c:	e8 9d ff ff ff       	call   80153e <vcprintf>
	va_end(ap);

	return cnt;
}
  8015a1:	c9                   	leave  
  8015a2:	c3                   	ret    

008015a3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015a3:	55                   	push   %ebp
  8015a4:	89 e5                	mov    %esp,%ebp
  8015a6:	57                   	push   %edi
  8015a7:	56                   	push   %esi
  8015a8:	53                   	push   %ebx
  8015a9:	83 ec 1c             	sub    $0x1c,%esp
  8015ac:	89 c7                	mov    %eax,%edi
  8015ae:	89 d6                	mov    %edx,%esi
  8015b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015b6:	89 d1                	mov    %edx,%ecx
  8015b8:	89 c2                	mov    %eax,%edx
  8015ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015bd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8015c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8015c3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015c9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8015d0:	39 c2                	cmp    %eax,%edx
  8015d2:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8015d5:	72 3e                	jb     801615 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015d7:	83 ec 0c             	sub    $0xc,%esp
  8015da:	ff 75 18             	push   0x18(%ebp)
  8015dd:	83 eb 01             	sub    $0x1,%ebx
  8015e0:	53                   	push   %ebx
  8015e1:	50                   	push   %eax
  8015e2:	83 ec 08             	sub    $0x8,%esp
  8015e5:	ff 75 e4             	push   -0x1c(%ebp)
  8015e8:	ff 75 e0             	push   -0x20(%ebp)
  8015eb:	ff 75 dc             	push   -0x24(%ebp)
  8015ee:	ff 75 d8             	push   -0x28(%ebp)
  8015f1:	e8 fa 09 00 00       	call   801ff0 <__udivdi3>
  8015f6:	83 c4 18             	add    $0x18,%esp
  8015f9:	52                   	push   %edx
  8015fa:	50                   	push   %eax
  8015fb:	89 f2                	mov    %esi,%edx
  8015fd:	89 f8                	mov    %edi,%eax
  8015ff:	e8 9f ff ff ff       	call   8015a3 <printnum>
  801604:	83 c4 20             	add    $0x20,%esp
  801607:	eb 13                	jmp    80161c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801609:	83 ec 08             	sub    $0x8,%esp
  80160c:	56                   	push   %esi
  80160d:	ff 75 18             	push   0x18(%ebp)
  801610:	ff d7                	call   *%edi
  801612:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  801615:	83 eb 01             	sub    $0x1,%ebx
  801618:	85 db                	test   %ebx,%ebx
  80161a:	7f ed                	jg     801609 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80161c:	83 ec 08             	sub    $0x8,%esp
  80161f:	56                   	push   %esi
  801620:	83 ec 04             	sub    $0x4,%esp
  801623:	ff 75 e4             	push   -0x1c(%ebp)
  801626:	ff 75 e0             	push   -0x20(%ebp)
  801629:	ff 75 dc             	push   -0x24(%ebp)
  80162c:	ff 75 d8             	push   -0x28(%ebp)
  80162f:	e8 dc 0a 00 00       	call   802110 <__umoddi3>
  801634:	83 c4 14             	add    $0x14,%esp
  801637:	0f be 80 c3 23 80 00 	movsbl 0x8023c3(%eax),%eax
  80163e:	50                   	push   %eax
  80163f:	ff d7                	call   *%edi
}
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801647:	5b                   	pop    %ebx
  801648:	5e                   	pop    %esi
  801649:	5f                   	pop    %edi
  80164a:	5d                   	pop    %ebp
  80164b:	c3                   	ret    

0080164c <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801652:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801656:	8b 10                	mov    (%eax),%edx
  801658:	3b 50 04             	cmp    0x4(%eax),%edx
  80165b:	73 0a                	jae    801667 <sprintputch+0x1b>
		*b->buf++ = ch;
  80165d:	8d 4a 01             	lea    0x1(%edx),%ecx
  801660:	89 08                	mov    %ecx,(%eax)
  801662:	8b 45 08             	mov    0x8(%ebp),%eax
  801665:	88 02                	mov    %al,(%edx)
}
  801667:	5d                   	pop    %ebp
  801668:	c3                   	ret    

00801669 <printfmt>:
{
  801669:	55                   	push   %ebp
  80166a:	89 e5                	mov    %esp,%ebp
  80166c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80166f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801672:	50                   	push   %eax
  801673:	ff 75 10             	push   0x10(%ebp)
  801676:	ff 75 0c             	push   0xc(%ebp)
  801679:	ff 75 08             	push   0x8(%ebp)
  80167c:	e8 05 00 00 00       	call   801686 <vprintfmt>
}
  801681:	83 c4 10             	add    $0x10,%esp
  801684:	c9                   	leave  
  801685:	c3                   	ret    

00801686 <vprintfmt>:
{
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	57                   	push   %edi
  80168a:	56                   	push   %esi
  80168b:	53                   	push   %ebx
  80168c:	83 ec 3c             	sub    $0x3c,%esp
  80168f:	8b 75 08             	mov    0x8(%ebp),%esi
  801692:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801695:	8b 7d 10             	mov    0x10(%ebp),%edi
  801698:	eb 0a                	jmp    8016a4 <vprintfmt+0x1e>
			putch(ch, putdat);
  80169a:	83 ec 08             	sub    $0x8,%esp
  80169d:	53                   	push   %ebx
  80169e:	50                   	push   %eax
  80169f:	ff d6                	call   *%esi
  8016a1:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016a4:	83 c7 01             	add    $0x1,%edi
  8016a7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016ab:	83 f8 25             	cmp    $0x25,%eax
  8016ae:	74 0c                	je     8016bc <vprintfmt+0x36>
			if (ch == '\0')
  8016b0:	85 c0                	test   %eax,%eax
  8016b2:	75 e6                	jne    80169a <vprintfmt+0x14>
}
  8016b4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b7:	5b                   	pop    %ebx
  8016b8:	5e                   	pop    %esi
  8016b9:	5f                   	pop    %edi
  8016ba:	5d                   	pop    %ebp
  8016bb:	c3                   	ret    
		padc = ' ';
  8016bc:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8016c0:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8016c7:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8016ce:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8016d5:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8016da:	8d 47 01             	lea    0x1(%edi),%eax
  8016dd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016e0:	0f b6 17             	movzbl (%edi),%edx
  8016e3:	8d 42 dd             	lea    -0x23(%edx),%eax
  8016e6:	3c 55                	cmp    $0x55,%al
  8016e8:	0f 87 bb 03 00 00    	ja     801aa9 <vprintfmt+0x423>
  8016ee:	0f b6 c0             	movzbl %al,%eax
  8016f1:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
  8016f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8016fb:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8016ff:	eb d9                	jmp    8016da <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801701:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801704:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801708:	eb d0                	jmp    8016da <vprintfmt+0x54>
  80170a:	0f b6 d2             	movzbl %dl,%edx
  80170d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801710:	b8 00 00 00 00       	mov    $0x0,%eax
  801715:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801718:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80171b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80171f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801722:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801725:	83 f9 09             	cmp    $0x9,%ecx
  801728:	77 55                	ja     80177f <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80172a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80172d:	eb e9                	jmp    801718 <vprintfmt+0x92>
			precision = va_arg(ap, int);
  80172f:	8b 45 14             	mov    0x14(%ebp),%eax
  801732:	8b 00                	mov    (%eax),%eax
  801734:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801737:	8b 45 14             	mov    0x14(%ebp),%eax
  80173a:	8d 40 04             	lea    0x4(%eax),%eax
  80173d:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801740:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801743:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801747:	79 91                	jns    8016da <vprintfmt+0x54>
				width = precision, precision = -1;
  801749:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80174c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80174f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801756:	eb 82                	jmp    8016da <vprintfmt+0x54>
  801758:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80175b:	85 d2                	test   %edx,%edx
  80175d:	b8 00 00 00 00       	mov    $0x0,%eax
  801762:	0f 49 c2             	cmovns %edx,%eax
  801765:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801768:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80176b:	e9 6a ff ff ff       	jmp    8016da <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801770:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801773:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80177a:	e9 5b ff ff ff       	jmp    8016da <vprintfmt+0x54>
  80177f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801782:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801785:	eb bc                	jmp    801743 <vprintfmt+0xbd>
			lflag++;
  801787:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80178a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80178d:	e9 48 ff ff ff       	jmp    8016da <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  801792:	8b 45 14             	mov    0x14(%ebp),%eax
  801795:	8d 78 04             	lea    0x4(%eax),%edi
  801798:	83 ec 08             	sub    $0x8,%esp
  80179b:	53                   	push   %ebx
  80179c:	ff 30                	push   (%eax)
  80179e:	ff d6                	call   *%esi
			break;
  8017a0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017a3:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017a6:	e9 9d 02 00 00       	jmp    801a48 <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8017ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8017ae:	8d 78 04             	lea    0x4(%eax),%edi
  8017b1:	8b 10                	mov    (%eax),%edx
  8017b3:	89 d0                	mov    %edx,%eax
  8017b5:	f7 d8                	neg    %eax
  8017b7:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017ba:	83 f8 0f             	cmp    $0xf,%eax
  8017bd:	7f 23                	jg     8017e2 <vprintfmt+0x15c>
  8017bf:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  8017c6:	85 d2                	test   %edx,%edx
  8017c8:	74 18                	je     8017e2 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8017ca:	52                   	push   %edx
  8017cb:	68 21 23 80 00       	push   $0x802321
  8017d0:	53                   	push   %ebx
  8017d1:	56                   	push   %esi
  8017d2:	e8 92 fe ff ff       	call   801669 <printfmt>
  8017d7:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8017da:	89 7d 14             	mov    %edi,0x14(%ebp)
  8017dd:	e9 66 02 00 00       	jmp    801a48 <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8017e2:	50                   	push   %eax
  8017e3:	68 db 23 80 00       	push   $0x8023db
  8017e8:	53                   	push   %ebx
  8017e9:	56                   	push   %esi
  8017ea:	e8 7a fe ff ff       	call   801669 <printfmt>
  8017ef:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8017f2:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8017f5:	e9 4e 02 00 00       	jmp    801a48 <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8017fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8017fd:	83 c0 04             	add    $0x4,%eax
  801800:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801803:	8b 45 14             	mov    0x14(%ebp),%eax
  801806:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  801808:	85 d2                	test   %edx,%edx
  80180a:	b8 d4 23 80 00       	mov    $0x8023d4,%eax
  80180f:	0f 45 c2             	cmovne %edx,%eax
  801812:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801815:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801819:	7e 06                	jle    801821 <vprintfmt+0x19b>
  80181b:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80181f:	75 0d                	jne    80182e <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801821:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801824:	89 c7                	mov    %eax,%edi
  801826:	03 45 e0             	add    -0x20(%ebp),%eax
  801829:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80182c:	eb 55                	jmp    801883 <vprintfmt+0x1fd>
  80182e:	83 ec 08             	sub    $0x8,%esp
  801831:	ff 75 d8             	push   -0x28(%ebp)
  801834:	ff 75 cc             	push   -0x34(%ebp)
  801837:	e8 0a 03 00 00       	call   801b46 <strnlen>
  80183c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80183f:	29 c1                	sub    %eax,%ecx
  801841:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801844:	83 c4 10             	add    $0x10,%esp
  801847:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  801849:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  80184d:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801850:	eb 0f                	jmp    801861 <vprintfmt+0x1db>
					putch(padc, putdat);
  801852:	83 ec 08             	sub    $0x8,%esp
  801855:	53                   	push   %ebx
  801856:	ff 75 e0             	push   -0x20(%ebp)
  801859:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  80185b:	83 ef 01             	sub    $0x1,%edi
  80185e:	83 c4 10             	add    $0x10,%esp
  801861:	85 ff                	test   %edi,%edi
  801863:	7f ed                	jg     801852 <vprintfmt+0x1cc>
  801865:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  801868:	85 d2                	test   %edx,%edx
  80186a:	b8 00 00 00 00       	mov    $0x0,%eax
  80186f:	0f 49 c2             	cmovns %edx,%eax
  801872:	29 c2                	sub    %eax,%edx
  801874:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801877:	eb a8                	jmp    801821 <vprintfmt+0x19b>
					putch(ch, putdat);
  801879:	83 ec 08             	sub    $0x8,%esp
  80187c:	53                   	push   %ebx
  80187d:	52                   	push   %edx
  80187e:	ff d6                	call   *%esi
  801880:	83 c4 10             	add    $0x10,%esp
  801883:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801886:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801888:	83 c7 01             	add    $0x1,%edi
  80188b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80188f:	0f be d0             	movsbl %al,%edx
  801892:	85 d2                	test   %edx,%edx
  801894:	74 4b                	je     8018e1 <vprintfmt+0x25b>
  801896:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80189a:	78 06                	js     8018a2 <vprintfmt+0x21c>
  80189c:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018a0:	78 1e                	js     8018c0 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8018a2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018a6:	74 d1                	je     801879 <vprintfmt+0x1f3>
  8018a8:	0f be c0             	movsbl %al,%eax
  8018ab:	83 e8 20             	sub    $0x20,%eax
  8018ae:	83 f8 5e             	cmp    $0x5e,%eax
  8018b1:	76 c6                	jbe    801879 <vprintfmt+0x1f3>
					putch('?', putdat);
  8018b3:	83 ec 08             	sub    $0x8,%esp
  8018b6:	53                   	push   %ebx
  8018b7:	6a 3f                	push   $0x3f
  8018b9:	ff d6                	call   *%esi
  8018bb:	83 c4 10             	add    $0x10,%esp
  8018be:	eb c3                	jmp    801883 <vprintfmt+0x1fd>
  8018c0:	89 cf                	mov    %ecx,%edi
  8018c2:	eb 0e                	jmp    8018d2 <vprintfmt+0x24c>
				putch(' ', putdat);
  8018c4:	83 ec 08             	sub    $0x8,%esp
  8018c7:	53                   	push   %ebx
  8018c8:	6a 20                	push   $0x20
  8018ca:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8018cc:	83 ef 01             	sub    $0x1,%edi
  8018cf:	83 c4 10             	add    $0x10,%esp
  8018d2:	85 ff                	test   %edi,%edi
  8018d4:	7f ee                	jg     8018c4 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8018d6:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8018d9:	89 45 14             	mov    %eax,0x14(%ebp)
  8018dc:	e9 67 01 00 00       	jmp    801a48 <vprintfmt+0x3c2>
  8018e1:	89 cf                	mov    %ecx,%edi
  8018e3:	eb ed                	jmp    8018d2 <vprintfmt+0x24c>
	if (lflag >= 2)
  8018e5:	83 f9 01             	cmp    $0x1,%ecx
  8018e8:	7f 1b                	jg     801905 <vprintfmt+0x27f>
	else if (lflag)
  8018ea:	85 c9                	test   %ecx,%ecx
  8018ec:	74 63                	je     801951 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8018ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f1:	8b 00                	mov    (%eax),%eax
  8018f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018f6:	99                   	cltd   
  8018f7:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8018fa:	8b 45 14             	mov    0x14(%ebp),%eax
  8018fd:	8d 40 04             	lea    0x4(%eax),%eax
  801900:	89 45 14             	mov    %eax,0x14(%ebp)
  801903:	eb 17                	jmp    80191c <vprintfmt+0x296>
		return va_arg(*ap, long long);
  801905:	8b 45 14             	mov    0x14(%ebp),%eax
  801908:	8b 50 04             	mov    0x4(%eax),%edx
  80190b:	8b 00                	mov    (%eax),%eax
  80190d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801910:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801913:	8b 45 14             	mov    0x14(%ebp),%eax
  801916:	8d 40 08             	lea    0x8(%eax),%eax
  801919:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  80191c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80191f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801922:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  801927:	85 c9                	test   %ecx,%ecx
  801929:	0f 89 ff 00 00 00    	jns    801a2e <vprintfmt+0x3a8>
				putch('-', putdat);
  80192f:	83 ec 08             	sub    $0x8,%esp
  801932:	53                   	push   %ebx
  801933:	6a 2d                	push   $0x2d
  801935:	ff d6                	call   *%esi
				num = -(long long) num;
  801937:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80193a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80193d:	f7 da                	neg    %edx
  80193f:	83 d1 00             	adc    $0x0,%ecx
  801942:	f7 d9                	neg    %ecx
  801944:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801947:	bf 0a 00 00 00       	mov    $0xa,%edi
  80194c:	e9 dd 00 00 00       	jmp    801a2e <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801951:	8b 45 14             	mov    0x14(%ebp),%eax
  801954:	8b 00                	mov    (%eax),%eax
  801956:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801959:	99                   	cltd   
  80195a:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80195d:	8b 45 14             	mov    0x14(%ebp),%eax
  801960:	8d 40 04             	lea    0x4(%eax),%eax
  801963:	89 45 14             	mov    %eax,0x14(%ebp)
  801966:	eb b4                	jmp    80191c <vprintfmt+0x296>
	if (lflag >= 2)
  801968:	83 f9 01             	cmp    $0x1,%ecx
  80196b:	7f 1e                	jg     80198b <vprintfmt+0x305>
	else if (lflag)
  80196d:	85 c9                	test   %ecx,%ecx
  80196f:	74 32                	je     8019a3 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  801971:	8b 45 14             	mov    0x14(%ebp),%eax
  801974:	8b 10                	mov    (%eax),%edx
  801976:	b9 00 00 00 00       	mov    $0x0,%ecx
  80197b:	8d 40 04             	lea    0x4(%eax),%eax
  80197e:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801981:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  801986:	e9 a3 00 00 00       	jmp    801a2e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  80198b:	8b 45 14             	mov    0x14(%ebp),%eax
  80198e:	8b 10                	mov    (%eax),%edx
  801990:	8b 48 04             	mov    0x4(%eax),%ecx
  801993:	8d 40 08             	lea    0x8(%eax),%eax
  801996:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801999:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  80199e:	e9 8b 00 00 00       	jmp    801a2e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a6:	8b 10                	mov    (%eax),%edx
  8019a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019ad:	8d 40 04             	lea    0x4(%eax),%eax
  8019b0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019b3:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8019b8:	eb 74                	jmp    801a2e <vprintfmt+0x3a8>
	if (lflag >= 2)
  8019ba:	83 f9 01             	cmp    $0x1,%ecx
  8019bd:	7f 1b                	jg     8019da <vprintfmt+0x354>
	else if (lflag)
  8019bf:	85 c9                	test   %ecx,%ecx
  8019c1:	74 2c                	je     8019ef <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8019c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c6:	8b 10                	mov    (%eax),%edx
  8019c8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019cd:	8d 40 04             	lea    0x4(%eax),%eax
  8019d0:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019d3:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8019d8:	eb 54                	jmp    801a2e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8019da:	8b 45 14             	mov    0x14(%ebp),%eax
  8019dd:	8b 10                	mov    (%eax),%edx
  8019df:	8b 48 04             	mov    0x4(%eax),%ecx
  8019e2:	8d 40 08             	lea    0x8(%eax),%eax
  8019e5:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019e8:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8019ed:	eb 3f                	jmp    801a2e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f2:	8b 10                	mov    (%eax),%edx
  8019f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019f9:	8d 40 04             	lea    0x4(%eax),%eax
  8019fc:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019ff:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801a04:	eb 28                	jmp    801a2e <vprintfmt+0x3a8>
			putch('0', putdat);
  801a06:	83 ec 08             	sub    $0x8,%esp
  801a09:	53                   	push   %ebx
  801a0a:	6a 30                	push   $0x30
  801a0c:	ff d6                	call   *%esi
			putch('x', putdat);
  801a0e:	83 c4 08             	add    $0x8,%esp
  801a11:	53                   	push   %ebx
  801a12:	6a 78                	push   $0x78
  801a14:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a16:	8b 45 14             	mov    0x14(%ebp),%eax
  801a19:	8b 10                	mov    (%eax),%edx
  801a1b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a20:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a23:	8d 40 04             	lea    0x4(%eax),%eax
  801a26:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a29:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801a2e:	83 ec 0c             	sub    $0xc,%esp
  801a31:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801a35:	50                   	push   %eax
  801a36:	ff 75 e0             	push   -0x20(%ebp)
  801a39:	57                   	push   %edi
  801a3a:	51                   	push   %ecx
  801a3b:	52                   	push   %edx
  801a3c:	89 da                	mov    %ebx,%edx
  801a3e:	89 f0                	mov    %esi,%eax
  801a40:	e8 5e fb ff ff       	call   8015a3 <printnum>
			break;
  801a45:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801a48:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a4b:	e9 54 fc ff ff       	jmp    8016a4 <vprintfmt+0x1e>
	if (lflag >= 2)
  801a50:	83 f9 01             	cmp    $0x1,%ecx
  801a53:	7f 1b                	jg     801a70 <vprintfmt+0x3ea>
	else if (lflag)
  801a55:	85 c9                	test   %ecx,%ecx
  801a57:	74 2c                	je     801a85 <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801a59:	8b 45 14             	mov    0x14(%ebp),%eax
  801a5c:	8b 10                	mov    (%eax),%edx
  801a5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a63:	8d 40 04             	lea    0x4(%eax),%eax
  801a66:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a69:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  801a6e:	eb be                	jmp    801a2e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801a70:	8b 45 14             	mov    0x14(%ebp),%eax
  801a73:	8b 10                	mov    (%eax),%edx
  801a75:	8b 48 04             	mov    0x4(%eax),%ecx
  801a78:	8d 40 08             	lea    0x8(%eax),%eax
  801a7b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a7e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  801a83:	eb a9                	jmp    801a2e <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801a85:	8b 45 14             	mov    0x14(%ebp),%eax
  801a88:	8b 10                	mov    (%eax),%edx
  801a8a:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a8f:	8d 40 04             	lea    0x4(%eax),%eax
  801a92:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a95:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  801a9a:	eb 92                	jmp    801a2e <vprintfmt+0x3a8>
			putch(ch, putdat);
  801a9c:	83 ec 08             	sub    $0x8,%esp
  801a9f:	53                   	push   %ebx
  801aa0:	6a 25                	push   $0x25
  801aa2:	ff d6                	call   *%esi
			break;
  801aa4:	83 c4 10             	add    $0x10,%esp
  801aa7:	eb 9f                	jmp    801a48 <vprintfmt+0x3c2>
			putch('%', putdat);
  801aa9:	83 ec 08             	sub    $0x8,%esp
  801aac:	53                   	push   %ebx
  801aad:	6a 25                	push   $0x25
  801aaf:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ab1:	83 c4 10             	add    $0x10,%esp
  801ab4:	89 f8                	mov    %edi,%eax
  801ab6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801aba:	74 05                	je     801ac1 <vprintfmt+0x43b>
  801abc:	83 e8 01             	sub    $0x1,%eax
  801abf:	eb f5                	jmp    801ab6 <vprintfmt+0x430>
  801ac1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ac4:	eb 82                	jmp    801a48 <vprintfmt+0x3c2>

00801ac6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	83 ec 18             	sub    $0x18,%esp
  801acc:	8b 45 08             	mov    0x8(%ebp),%eax
  801acf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ad2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ad5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ad9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801adc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ae3:	85 c0                	test   %eax,%eax
  801ae5:	74 26                	je     801b0d <vsnprintf+0x47>
  801ae7:	85 d2                	test   %edx,%edx
  801ae9:	7e 22                	jle    801b0d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801aeb:	ff 75 14             	push   0x14(%ebp)
  801aee:	ff 75 10             	push   0x10(%ebp)
  801af1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801af4:	50                   	push   %eax
  801af5:	68 4c 16 80 00       	push   $0x80164c
  801afa:	e8 87 fb ff ff       	call   801686 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801aff:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b02:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b08:	83 c4 10             	add    $0x10,%esp
}
  801b0b:	c9                   	leave  
  801b0c:	c3                   	ret    
		return -E_INVAL;
  801b0d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b12:	eb f7                	jmp    801b0b <vsnprintf+0x45>

00801b14 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b1a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b1d:	50                   	push   %eax
  801b1e:	ff 75 10             	push   0x10(%ebp)
  801b21:	ff 75 0c             	push   0xc(%ebp)
  801b24:	ff 75 08             	push   0x8(%ebp)
  801b27:	e8 9a ff ff ff       	call   801ac6 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b2c:	c9                   	leave  
  801b2d:	c3                   	ret    

00801b2e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b34:	b8 00 00 00 00       	mov    $0x0,%eax
  801b39:	eb 03                	jmp    801b3e <strlen+0x10>
		n++;
  801b3b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801b3e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b42:	75 f7                	jne    801b3b <strlen+0xd>
	return n;
}
  801b44:	5d                   	pop    %ebp
  801b45:	c3                   	ret    

00801b46 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b46:	55                   	push   %ebp
  801b47:	89 e5                	mov    %esp,%ebp
  801b49:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b4c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b4f:	b8 00 00 00 00       	mov    $0x0,%eax
  801b54:	eb 03                	jmp    801b59 <strnlen+0x13>
		n++;
  801b56:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b59:	39 d0                	cmp    %edx,%eax
  801b5b:	74 08                	je     801b65 <strnlen+0x1f>
  801b5d:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801b61:	75 f3                	jne    801b56 <strnlen+0x10>
  801b63:	89 c2                	mov    %eax,%edx
	return n;
}
  801b65:	89 d0                	mov    %edx,%eax
  801b67:	5d                   	pop    %ebp
  801b68:	c3                   	ret    

00801b69 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	53                   	push   %ebx
  801b6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b70:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b73:	b8 00 00 00 00       	mov    $0x0,%eax
  801b78:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801b7c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801b7f:	83 c0 01             	add    $0x1,%eax
  801b82:	84 d2                	test   %dl,%dl
  801b84:	75 f2                	jne    801b78 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801b86:	89 c8                	mov    %ecx,%eax
  801b88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b8b:	c9                   	leave  
  801b8c:	c3                   	ret    

00801b8d <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b8d:	55                   	push   %ebp
  801b8e:	89 e5                	mov    %esp,%ebp
  801b90:	53                   	push   %ebx
  801b91:	83 ec 10             	sub    $0x10,%esp
  801b94:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b97:	53                   	push   %ebx
  801b98:	e8 91 ff ff ff       	call   801b2e <strlen>
  801b9d:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801ba0:	ff 75 0c             	push   0xc(%ebp)
  801ba3:	01 d8                	add    %ebx,%eax
  801ba5:	50                   	push   %eax
  801ba6:	e8 be ff ff ff       	call   801b69 <strcpy>
	return dst;
}
  801bab:	89 d8                	mov    %ebx,%eax
  801bad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb0:	c9                   	leave  
  801bb1:	c3                   	ret    

00801bb2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bb2:	55                   	push   %ebp
  801bb3:	89 e5                	mov    %esp,%ebp
  801bb5:	56                   	push   %esi
  801bb6:	53                   	push   %ebx
  801bb7:	8b 75 08             	mov    0x8(%ebp),%esi
  801bba:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bbd:	89 f3                	mov    %esi,%ebx
  801bbf:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bc2:	89 f0                	mov    %esi,%eax
  801bc4:	eb 0f                	jmp    801bd5 <strncpy+0x23>
		*dst++ = *src;
  801bc6:	83 c0 01             	add    $0x1,%eax
  801bc9:	0f b6 0a             	movzbl (%edx),%ecx
  801bcc:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bcf:	80 f9 01             	cmp    $0x1,%cl
  801bd2:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801bd5:	39 d8                	cmp    %ebx,%eax
  801bd7:	75 ed                	jne    801bc6 <strncpy+0x14>
	}
	return ret;
}
  801bd9:	89 f0                	mov    %esi,%eax
  801bdb:	5b                   	pop    %ebx
  801bdc:	5e                   	pop    %esi
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	56                   	push   %esi
  801be3:	53                   	push   %ebx
  801be4:	8b 75 08             	mov    0x8(%ebp),%esi
  801be7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bea:	8b 55 10             	mov    0x10(%ebp),%edx
  801bed:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bef:	85 d2                	test   %edx,%edx
  801bf1:	74 21                	je     801c14 <strlcpy+0x35>
  801bf3:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bf7:	89 f2                	mov    %esi,%edx
  801bf9:	eb 09                	jmp    801c04 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801bfb:	83 c1 01             	add    $0x1,%ecx
  801bfe:	83 c2 01             	add    $0x1,%edx
  801c01:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801c04:	39 c2                	cmp    %eax,%edx
  801c06:	74 09                	je     801c11 <strlcpy+0x32>
  801c08:	0f b6 19             	movzbl (%ecx),%ebx
  801c0b:	84 db                	test   %bl,%bl
  801c0d:	75 ec                	jne    801bfb <strlcpy+0x1c>
  801c0f:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801c11:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c14:	29 f0                	sub    %esi,%eax
}
  801c16:	5b                   	pop    %ebx
  801c17:	5e                   	pop    %esi
  801c18:	5d                   	pop    %ebp
  801c19:	c3                   	ret    

00801c1a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c1a:	55                   	push   %ebp
  801c1b:	89 e5                	mov    %esp,%ebp
  801c1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c20:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c23:	eb 06                	jmp    801c2b <strcmp+0x11>
		p++, q++;
  801c25:	83 c1 01             	add    $0x1,%ecx
  801c28:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801c2b:	0f b6 01             	movzbl (%ecx),%eax
  801c2e:	84 c0                	test   %al,%al
  801c30:	74 04                	je     801c36 <strcmp+0x1c>
  801c32:	3a 02                	cmp    (%edx),%al
  801c34:	74 ef                	je     801c25 <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c36:	0f b6 c0             	movzbl %al,%eax
  801c39:	0f b6 12             	movzbl (%edx),%edx
  801c3c:	29 d0                	sub    %edx,%eax
}
  801c3e:	5d                   	pop    %ebp
  801c3f:	c3                   	ret    

00801c40 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	53                   	push   %ebx
  801c44:	8b 45 08             	mov    0x8(%ebp),%eax
  801c47:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c4a:	89 c3                	mov    %eax,%ebx
  801c4c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c4f:	eb 06                	jmp    801c57 <strncmp+0x17>
		n--, p++, q++;
  801c51:	83 c0 01             	add    $0x1,%eax
  801c54:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801c57:	39 d8                	cmp    %ebx,%eax
  801c59:	74 18                	je     801c73 <strncmp+0x33>
  801c5b:	0f b6 08             	movzbl (%eax),%ecx
  801c5e:	84 c9                	test   %cl,%cl
  801c60:	74 04                	je     801c66 <strncmp+0x26>
  801c62:	3a 0a                	cmp    (%edx),%cl
  801c64:	74 eb                	je     801c51 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c66:	0f b6 00             	movzbl (%eax),%eax
  801c69:	0f b6 12             	movzbl (%edx),%edx
  801c6c:	29 d0                	sub    %edx,%eax
}
  801c6e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c71:	c9                   	leave  
  801c72:	c3                   	ret    
		return 0;
  801c73:	b8 00 00 00 00       	mov    $0x0,%eax
  801c78:	eb f4                	jmp    801c6e <strncmp+0x2e>

00801c7a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c7a:	55                   	push   %ebp
  801c7b:	89 e5                	mov    %esp,%ebp
  801c7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c80:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c84:	eb 03                	jmp    801c89 <strchr+0xf>
  801c86:	83 c0 01             	add    $0x1,%eax
  801c89:	0f b6 10             	movzbl (%eax),%edx
  801c8c:	84 d2                	test   %dl,%dl
  801c8e:	74 06                	je     801c96 <strchr+0x1c>
		if (*s == c)
  801c90:	38 ca                	cmp    %cl,%dl
  801c92:	75 f2                	jne    801c86 <strchr+0xc>
  801c94:	eb 05                	jmp    801c9b <strchr+0x21>
			return (char *) s;
	return 0;
  801c96:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c9b:	5d                   	pop    %ebp
  801c9c:	c3                   	ret    

00801c9d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801ca7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801caa:	38 ca                	cmp    %cl,%dl
  801cac:	74 09                	je     801cb7 <strfind+0x1a>
  801cae:	84 d2                	test   %dl,%dl
  801cb0:	74 05                	je     801cb7 <strfind+0x1a>
	for (; *s; s++)
  801cb2:	83 c0 01             	add    $0x1,%eax
  801cb5:	eb f0                	jmp    801ca7 <strfind+0xa>
			break;
	return (char *) s;
}
  801cb7:	5d                   	pop    %ebp
  801cb8:	c3                   	ret    

00801cb9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cb9:	55                   	push   %ebp
  801cba:	89 e5                	mov    %esp,%ebp
  801cbc:	57                   	push   %edi
  801cbd:	56                   	push   %esi
  801cbe:	53                   	push   %ebx
  801cbf:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cc2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cc5:	85 c9                	test   %ecx,%ecx
  801cc7:	74 2f                	je     801cf8 <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cc9:	89 f8                	mov    %edi,%eax
  801ccb:	09 c8                	or     %ecx,%eax
  801ccd:	a8 03                	test   $0x3,%al
  801ccf:	75 21                	jne    801cf2 <memset+0x39>
		c &= 0xFF;
  801cd1:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cd5:	89 d0                	mov    %edx,%eax
  801cd7:	c1 e0 08             	shl    $0x8,%eax
  801cda:	89 d3                	mov    %edx,%ebx
  801cdc:	c1 e3 18             	shl    $0x18,%ebx
  801cdf:	89 d6                	mov    %edx,%esi
  801ce1:	c1 e6 10             	shl    $0x10,%esi
  801ce4:	09 f3                	or     %esi,%ebx
  801ce6:	09 da                	or     %ebx,%edx
  801ce8:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801cea:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801ced:	fc                   	cld    
  801cee:	f3 ab                	rep stos %eax,%es:(%edi)
  801cf0:	eb 06                	jmp    801cf8 <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cf2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cf5:	fc                   	cld    
  801cf6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cf8:	89 f8                	mov    %edi,%eax
  801cfa:	5b                   	pop    %ebx
  801cfb:	5e                   	pop    %esi
  801cfc:	5f                   	pop    %edi
  801cfd:	5d                   	pop    %ebp
  801cfe:	c3                   	ret    

00801cff <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801cff:	55                   	push   %ebp
  801d00:	89 e5                	mov    %esp,%ebp
  801d02:	57                   	push   %edi
  801d03:	56                   	push   %esi
  801d04:	8b 45 08             	mov    0x8(%ebp),%eax
  801d07:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d0d:	39 c6                	cmp    %eax,%esi
  801d0f:	73 32                	jae    801d43 <memmove+0x44>
  801d11:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d14:	39 c2                	cmp    %eax,%edx
  801d16:	76 2b                	jbe    801d43 <memmove+0x44>
		s += n;
		d += n;
  801d18:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d1b:	89 d6                	mov    %edx,%esi
  801d1d:	09 fe                	or     %edi,%esi
  801d1f:	09 ce                	or     %ecx,%esi
  801d21:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d27:	75 0e                	jne    801d37 <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d29:	83 ef 04             	sub    $0x4,%edi
  801d2c:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d2f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801d32:	fd                   	std    
  801d33:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d35:	eb 09                	jmp    801d40 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d37:	83 ef 01             	sub    $0x1,%edi
  801d3a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801d3d:	fd                   	std    
  801d3e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d40:	fc                   	cld    
  801d41:	eb 1a                	jmp    801d5d <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d43:	89 f2                	mov    %esi,%edx
  801d45:	09 c2                	or     %eax,%edx
  801d47:	09 ca                	or     %ecx,%edx
  801d49:	f6 c2 03             	test   $0x3,%dl
  801d4c:	75 0a                	jne    801d58 <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801d4e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801d51:	89 c7                	mov    %eax,%edi
  801d53:	fc                   	cld    
  801d54:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d56:	eb 05                	jmp    801d5d <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801d58:	89 c7                	mov    %eax,%edi
  801d5a:	fc                   	cld    
  801d5b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d5d:	5e                   	pop    %esi
  801d5e:	5f                   	pop    %edi
  801d5f:	5d                   	pop    %ebp
  801d60:	c3                   	ret    

00801d61 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d61:	55                   	push   %ebp
  801d62:	89 e5                	mov    %esp,%ebp
  801d64:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d67:	ff 75 10             	push   0x10(%ebp)
  801d6a:	ff 75 0c             	push   0xc(%ebp)
  801d6d:	ff 75 08             	push   0x8(%ebp)
  801d70:	e8 8a ff ff ff       	call   801cff <memmove>
}
  801d75:	c9                   	leave  
  801d76:	c3                   	ret    

00801d77 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d77:	55                   	push   %ebp
  801d78:	89 e5                	mov    %esp,%ebp
  801d7a:	56                   	push   %esi
  801d7b:	53                   	push   %ebx
  801d7c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d82:	89 c6                	mov    %eax,%esi
  801d84:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d87:	eb 06                	jmp    801d8f <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801d89:	83 c0 01             	add    $0x1,%eax
  801d8c:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801d8f:	39 f0                	cmp    %esi,%eax
  801d91:	74 14                	je     801da7 <memcmp+0x30>
		if (*s1 != *s2)
  801d93:	0f b6 08             	movzbl (%eax),%ecx
  801d96:	0f b6 1a             	movzbl (%edx),%ebx
  801d99:	38 d9                	cmp    %bl,%cl
  801d9b:	74 ec                	je     801d89 <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801d9d:	0f b6 c1             	movzbl %cl,%eax
  801da0:	0f b6 db             	movzbl %bl,%ebx
  801da3:	29 d8                	sub    %ebx,%eax
  801da5:	eb 05                	jmp    801dac <memcmp+0x35>
	}

	return 0;
  801da7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dac:	5b                   	pop    %ebx
  801dad:	5e                   	pop    %esi
  801dae:	5d                   	pop    %ebp
  801daf:	c3                   	ret    

00801db0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
  801db3:	8b 45 08             	mov    0x8(%ebp),%eax
  801db6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801db9:	89 c2                	mov    %eax,%edx
  801dbb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801dbe:	eb 03                	jmp    801dc3 <memfind+0x13>
  801dc0:	83 c0 01             	add    $0x1,%eax
  801dc3:	39 d0                	cmp    %edx,%eax
  801dc5:	73 04                	jae    801dcb <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801dc7:	38 08                	cmp    %cl,(%eax)
  801dc9:	75 f5                	jne    801dc0 <memfind+0x10>
			break;
	return (void *) s;
}
  801dcb:	5d                   	pop    %ebp
  801dcc:	c3                   	ret    

00801dcd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dcd:	55                   	push   %ebp
  801dce:	89 e5                	mov    %esp,%ebp
  801dd0:	57                   	push   %edi
  801dd1:	56                   	push   %esi
  801dd2:	53                   	push   %ebx
  801dd3:	8b 55 08             	mov    0x8(%ebp),%edx
  801dd6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dd9:	eb 03                	jmp    801dde <strtol+0x11>
		s++;
  801ddb:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801dde:	0f b6 02             	movzbl (%edx),%eax
  801de1:	3c 20                	cmp    $0x20,%al
  801de3:	74 f6                	je     801ddb <strtol+0xe>
  801de5:	3c 09                	cmp    $0x9,%al
  801de7:	74 f2                	je     801ddb <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801de9:	3c 2b                	cmp    $0x2b,%al
  801deb:	74 2a                	je     801e17 <strtol+0x4a>
	int neg = 0;
  801ded:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801df2:	3c 2d                	cmp    $0x2d,%al
  801df4:	74 2b                	je     801e21 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801df6:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801dfc:	75 0f                	jne    801e0d <strtol+0x40>
  801dfe:	80 3a 30             	cmpb   $0x30,(%edx)
  801e01:	74 28                	je     801e2b <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e03:	85 db                	test   %ebx,%ebx
  801e05:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e0a:	0f 44 d8             	cmove  %eax,%ebx
  801e0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e12:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801e15:	eb 46                	jmp    801e5d <strtol+0x90>
		s++;
  801e17:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801e1a:	bf 00 00 00 00       	mov    $0x0,%edi
  801e1f:	eb d5                	jmp    801df6 <strtol+0x29>
		s++, neg = 1;
  801e21:	83 c2 01             	add    $0x1,%edx
  801e24:	bf 01 00 00 00       	mov    $0x1,%edi
  801e29:	eb cb                	jmp    801df6 <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e2b:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e2f:	74 0e                	je     801e3f <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801e31:	85 db                	test   %ebx,%ebx
  801e33:	75 d8                	jne    801e0d <strtol+0x40>
		s++, base = 8;
  801e35:	83 c2 01             	add    $0x1,%edx
  801e38:	bb 08 00 00 00       	mov    $0x8,%ebx
  801e3d:	eb ce                	jmp    801e0d <strtol+0x40>
		s += 2, base = 16;
  801e3f:	83 c2 02             	add    $0x2,%edx
  801e42:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e47:	eb c4                	jmp    801e0d <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801e49:	0f be c0             	movsbl %al,%eax
  801e4c:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801e4f:	3b 45 10             	cmp    0x10(%ebp),%eax
  801e52:	7d 3a                	jge    801e8e <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801e54:	83 c2 01             	add    $0x1,%edx
  801e57:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801e5b:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801e5d:	0f b6 02             	movzbl (%edx),%eax
  801e60:	8d 70 d0             	lea    -0x30(%eax),%esi
  801e63:	89 f3                	mov    %esi,%ebx
  801e65:	80 fb 09             	cmp    $0x9,%bl
  801e68:	76 df                	jbe    801e49 <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  801e6a:	8d 70 9f             	lea    -0x61(%eax),%esi
  801e6d:	89 f3                	mov    %esi,%ebx
  801e6f:	80 fb 19             	cmp    $0x19,%bl
  801e72:	77 08                	ja     801e7c <strtol+0xaf>
			dig = *s - 'a' + 10;
  801e74:	0f be c0             	movsbl %al,%eax
  801e77:	83 e8 57             	sub    $0x57,%eax
  801e7a:	eb d3                	jmp    801e4f <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801e7c:	8d 70 bf             	lea    -0x41(%eax),%esi
  801e7f:	89 f3                	mov    %esi,%ebx
  801e81:	80 fb 19             	cmp    $0x19,%bl
  801e84:	77 08                	ja     801e8e <strtol+0xc1>
			dig = *s - 'A' + 10;
  801e86:	0f be c0             	movsbl %al,%eax
  801e89:	83 e8 37             	sub    $0x37,%eax
  801e8c:	eb c1                	jmp    801e4f <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801e8e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e92:	74 05                	je     801e99 <strtol+0xcc>
		*endptr = (char *) s;
  801e94:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e97:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801e99:	89 c8                	mov    %ecx,%eax
  801e9b:	f7 d8                	neg    %eax
  801e9d:	85 ff                	test   %edi,%edi
  801e9f:	0f 45 c8             	cmovne %eax,%ecx
}
  801ea2:	89 c8                	mov    %ecx,%eax
  801ea4:	5b                   	pop    %ebx
  801ea5:	5e                   	pop    %esi
  801ea6:	5f                   	pop    %edi
  801ea7:	5d                   	pop    %ebp
  801ea8:	c3                   	ret    

00801ea9 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ea9:	55                   	push   %ebp
  801eaa:	89 e5                	mov    %esp,%ebp
  801eac:	56                   	push   %esi
  801ead:	53                   	push   %ebx
  801eae:	8b 75 08             	mov    0x8(%ebp),%esi
  801eb1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801eb7:	85 c0                	test   %eax,%eax
  801eb9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ebe:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801ec1:	83 ec 0c             	sub    $0xc,%esp
  801ec4:	50                   	push   %eax
  801ec5:	e8 3a e4 ff ff       	call   800304 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801eca:	83 c4 10             	add    $0x10,%esp
  801ecd:	85 f6                	test   %esi,%esi
  801ecf:	74 17                	je     801ee8 <ipc_recv+0x3f>
  801ed1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ed6:	85 c0                	test   %eax,%eax
  801ed8:	78 0c                	js     801ee6 <ipc_recv+0x3d>
  801eda:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ee0:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801ee6:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801ee8:	85 db                	test   %ebx,%ebx
  801eea:	74 17                	je     801f03 <ipc_recv+0x5a>
  801eec:	ba 00 00 00 00       	mov    $0x0,%edx
  801ef1:	85 c0                	test   %eax,%eax
  801ef3:	78 0c                	js     801f01 <ipc_recv+0x58>
  801ef5:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801efb:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801f01:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f03:	85 c0                	test   %eax,%eax
  801f05:	78 0b                	js     801f12 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801f07:	a1 00 40 80 00       	mov    0x804000,%eax
  801f0c:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  801f12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f15:	5b                   	pop    %ebx
  801f16:	5e                   	pop    %esi
  801f17:	5d                   	pop    %ebp
  801f18:	c3                   	ret    

00801f19 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f19:	55                   	push   %ebp
  801f1a:	89 e5                	mov    %esp,%ebp
  801f1c:	57                   	push   %edi
  801f1d:	56                   	push   %esi
  801f1e:	53                   	push   %ebx
  801f1f:	83 ec 0c             	sub    $0xc,%esp
  801f22:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f25:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f28:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f2b:	85 db                	test   %ebx,%ebx
  801f2d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f32:	0f 44 d8             	cmove  %eax,%ebx
  801f35:	eb 05                	jmp    801f3c <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f37:	e8 f9 e1 ff ff       	call   800135 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f3c:	ff 75 14             	push   0x14(%ebp)
  801f3f:	53                   	push   %ebx
  801f40:	56                   	push   %esi
  801f41:	57                   	push   %edi
  801f42:	e8 9a e3 ff ff       	call   8002e1 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f47:	83 c4 10             	add    $0x10,%esp
  801f4a:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f4d:	74 e8                	je     801f37 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f4f:	85 c0                	test   %eax,%eax
  801f51:	78 08                	js     801f5b <ipc_send+0x42>
	}while (r<0);

}
  801f53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f56:	5b                   	pop    %ebx
  801f57:	5e                   	pop    %esi
  801f58:	5f                   	pop    %edi
  801f59:	5d                   	pop    %ebp
  801f5a:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f5b:	50                   	push   %eax
  801f5c:	68 bf 26 80 00       	push   $0x8026bf
  801f61:	6a 3d                	push   $0x3d
  801f63:	68 d3 26 80 00       	push   $0x8026d3
  801f68:	e8 47 f5 ff ff       	call   8014b4 <_panic>

00801f6d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f6d:	55                   	push   %ebp
  801f6e:	89 e5                	mov    %esp,%ebp
  801f70:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f73:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f78:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  801f7e:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f84:	8b 52 60             	mov    0x60(%edx),%edx
  801f87:	39 ca                	cmp    %ecx,%edx
  801f89:	74 11                	je     801f9c <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  801f8b:	83 c0 01             	add    $0x1,%eax
  801f8e:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f93:	75 e3                	jne    801f78 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801f95:	b8 00 00 00 00       	mov    $0x0,%eax
  801f9a:	eb 0e                	jmp    801faa <ipc_find_env+0x3d>
			return envs[i].env_id;
  801f9c:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  801fa2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fa7:	8b 40 58             	mov    0x58(%eax),%eax
}
  801faa:	5d                   	pop    %ebp
  801fab:	c3                   	ret    

00801fac <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fac:	55                   	push   %ebp
  801fad:	89 e5                	mov    %esp,%ebp
  801faf:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb2:	89 c2                	mov    %eax,%edx
  801fb4:	c1 ea 16             	shr    $0x16,%edx
  801fb7:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fbe:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fc3:	f6 c1 01             	test   $0x1,%cl
  801fc6:	74 1c                	je     801fe4 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801fc8:	c1 e8 0c             	shr    $0xc,%eax
  801fcb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fd2:	a8 01                	test   $0x1,%al
  801fd4:	74 0e                	je     801fe4 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fd6:	c1 e8 0c             	shr    $0xc,%eax
  801fd9:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801fe0:	ef 
  801fe1:	0f b7 d2             	movzwl %dx,%edx
}
  801fe4:	89 d0                	mov    %edx,%eax
  801fe6:	5d                   	pop    %ebp
  801fe7:	c3                   	ret    
  801fe8:	66 90                	xchg   %ax,%ax
  801fea:	66 90                	xchg   %ax,%ax
  801fec:	66 90                	xchg   %ax,%ax
  801fee:	66 90                	xchg   %ax,%ax

00801ff0 <__udivdi3>:
  801ff0:	f3 0f 1e fb          	endbr32 
  801ff4:	55                   	push   %ebp
  801ff5:	57                   	push   %edi
  801ff6:	56                   	push   %esi
  801ff7:	53                   	push   %ebx
  801ff8:	83 ec 1c             	sub    $0x1c,%esp
  801ffb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801fff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802003:	8b 74 24 34          	mov    0x34(%esp),%esi
  802007:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80200b:	85 c0                	test   %eax,%eax
  80200d:	75 19                	jne    802028 <__udivdi3+0x38>
  80200f:	39 f3                	cmp    %esi,%ebx
  802011:	76 4d                	jbe    802060 <__udivdi3+0x70>
  802013:	31 ff                	xor    %edi,%edi
  802015:	89 e8                	mov    %ebp,%eax
  802017:	89 f2                	mov    %esi,%edx
  802019:	f7 f3                	div    %ebx
  80201b:	89 fa                	mov    %edi,%edx
  80201d:	83 c4 1c             	add    $0x1c,%esp
  802020:	5b                   	pop    %ebx
  802021:	5e                   	pop    %esi
  802022:	5f                   	pop    %edi
  802023:	5d                   	pop    %ebp
  802024:	c3                   	ret    
  802025:	8d 76 00             	lea    0x0(%esi),%esi
  802028:	39 f0                	cmp    %esi,%eax
  80202a:	76 14                	jbe    802040 <__udivdi3+0x50>
  80202c:	31 ff                	xor    %edi,%edi
  80202e:	31 c0                	xor    %eax,%eax
  802030:	89 fa                	mov    %edi,%edx
  802032:	83 c4 1c             	add    $0x1c,%esp
  802035:	5b                   	pop    %ebx
  802036:	5e                   	pop    %esi
  802037:	5f                   	pop    %edi
  802038:	5d                   	pop    %ebp
  802039:	c3                   	ret    
  80203a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802040:	0f bd f8             	bsr    %eax,%edi
  802043:	83 f7 1f             	xor    $0x1f,%edi
  802046:	75 48                	jne    802090 <__udivdi3+0xa0>
  802048:	39 f0                	cmp    %esi,%eax
  80204a:	72 06                	jb     802052 <__udivdi3+0x62>
  80204c:	31 c0                	xor    %eax,%eax
  80204e:	39 eb                	cmp    %ebp,%ebx
  802050:	77 de                	ja     802030 <__udivdi3+0x40>
  802052:	b8 01 00 00 00       	mov    $0x1,%eax
  802057:	eb d7                	jmp    802030 <__udivdi3+0x40>
  802059:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802060:	89 d9                	mov    %ebx,%ecx
  802062:	85 db                	test   %ebx,%ebx
  802064:	75 0b                	jne    802071 <__udivdi3+0x81>
  802066:	b8 01 00 00 00       	mov    $0x1,%eax
  80206b:	31 d2                	xor    %edx,%edx
  80206d:	f7 f3                	div    %ebx
  80206f:	89 c1                	mov    %eax,%ecx
  802071:	31 d2                	xor    %edx,%edx
  802073:	89 f0                	mov    %esi,%eax
  802075:	f7 f1                	div    %ecx
  802077:	89 c6                	mov    %eax,%esi
  802079:	89 e8                	mov    %ebp,%eax
  80207b:	89 f7                	mov    %esi,%edi
  80207d:	f7 f1                	div    %ecx
  80207f:	89 fa                	mov    %edi,%edx
  802081:	83 c4 1c             	add    $0x1c,%esp
  802084:	5b                   	pop    %ebx
  802085:	5e                   	pop    %esi
  802086:	5f                   	pop    %edi
  802087:	5d                   	pop    %ebp
  802088:	c3                   	ret    
  802089:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802090:	89 f9                	mov    %edi,%ecx
  802092:	ba 20 00 00 00       	mov    $0x20,%edx
  802097:	29 fa                	sub    %edi,%edx
  802099:	d3 e0                	shl    %cl,%eax
  80209b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80209f:	89 d1                	mov    %edx,%ecx
  8020a1:	89 d8                	mov    %ebx,%eax
  8020a3:	d3 e8                	shr    %cl,%eax
  8020a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8020a9:	09 c1                	or     %eax,%ecx
  8020ab:	89 f0                	mov    %esi,%eax
  8020ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8020b1:	89 f9                	mov    %edi,%ecx
  8020b3:	d3 e3                	shl    %cl,%ebx
  8020b5:	89 d1                	mov    %edx,%ecx
  8020b7:	d3 e8                	shr    %cl,%eax
  8020b9:	89 f9                	mov    %edi,%ecx
  8020bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8020bf:	89 eb                	mov    %ebp,%ebx
  8020c1:	d3 e6                	shl    %cl,%esi
  8020c3:	89 d1                	mov    %edx,%ecx
  8020c5:	d3 eb                	shr    %cl,%ebx
  8020c7:	09 f3                	or     %esi,%ebx
  8020c9:	89 c6                	mov    %eax,%esi
  8020cb:	89 f2                	mov    %esi,%edx
  8020cd:	89 d8                	mov    %ebx,%eax
  8020cf:	f7 74 24 08          	divl   0x8(%esp)
  8020d3:	89 d6                	mov    %edx,%esi
  8020d5:	89 c3                	mov    %eax,%ebx
  8020d7:	f7 64 24 0c          	mull   0xc(%esp)
  8020db:	39 d6                	cmp    %edx,%esi
  8020dd:	72 19                	jb     8020f8 <__udivdi3+0x108>
  8020df:	89 f9                	mov    %edi,%ecx
  8020e1:	d3 e5                	shl    %cl,%ebp
  8020e3:	39 c5                	cmp    %eax,%ebp
  8020e5:	73 04                	jae    8020eb <__udivdi3+0xfb>
  8020e7:	39 d6                	cmp    %edx,%esi
  8020e9:	74 0d                	je     8020f8 <__udivdi3+0x108>
  8020eb:	89 d8                	mov    %ebx,%eax
  8020ed:	31 ff                	xor    %edi,%edi
  8020ef:	e9 3c ff ff ff       	jmp    802030 <__udivdi3+0x40>
  8020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8020fb:	31 ff                	xor    %edi,%edi
  8020fd:	e9 2e ff ff ff       	jmp    802030 <__udivdi3+0x40>
  802102:	66 90                	xchg   %ax,%ax
  802104:	66 90                	xchg   %ax,%ax
  802106:	66 90                	xchg   %ax,%ax
  802108:	66 90                	xchg   %ax,%ax
  80210a:	66 90                	xchg   %ax,%ax
  80210c:	66 90                	xchg   %ax,%ax
  80210e:	66 90                	xchg   %ax,%ax

00802110 <__umoddi3>:
  802110:	f3 0f 1e fb          	endbr32 
  802114:	55                   	push   %ebp
  802115:	57                   	push   %edi
  802116:	56                   	push   %esi
  802117:	53                   	push   %ebx
  802118:	83 ec 1c             	sub    $0x1c,%esp
  80211b:	8b 74 24 30          	mov    0x30(%esp),%esi
  80211f:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802123:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  802127:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  80212b:	89 f0                	mov    %esi,%eax
  80212d:	89 da                	mov    %ebx,%edx
  80212f:	85 ff                	test   %edi,%edi
  802131:	75 15                	jne    802148 <__umoddi3+0x38>
  802133:	39 dd                	cmp    %ebx,%ebp
  802135:	76 39                	jbe    802170 <__umoddi3+0x60>
  802137:	f7 f5                	div    %ebp
  802139:	89 d0                	mov    %edx,%eax
  80213b:	31 d2                	xor    %edx,%edx
  80213d:	83 c4 1c             	add    $0x1c,%esp
  802140:	5b                   	pop    %ebx
  802141:	5e                   	pop    %esi
  802142:	5f                   	pop    %edi
  802143:	5d                   	pop    %ebp
  802144:	c3                   	ret    
  802145:	8d 76 00             	lea    0x0(%esi),%esi
  802148:	39 df                	cmp    %ebx,%edi
  80214a:	77 f1                	ja     80213d <__umoddi3+0x2d>
  80214c:	0f bd cf             	bsr    %edi,%ecx
  80214f:	83 f1 1f             	xor    $0x1f,%ecx
  802152:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802156:	75 40                	jne    802198 <__umoddi3+0x88>
  802158:	39 df                	cmp    %ebx,%edi
  80215a:	72 04                	jb     802160 <__umoddi3+0x50>
  80215c:	39 f5                	cmp    %esi,%ebp
  80215e:	77 dd                	ja     80213d <__umoddi3+0x2d>
  802160:	89 da                	mov    %ebx,%edx
  802162:	89 f0                	mov    %esi,%eax
  802164:	29 e8                	sub    %ebp,%eax
  802166:	19 fa                	sbb    %edi,%edx
  802168:	eb d3                	jmp    80213d <__umoddi3+0x2d>
  80216a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802170:	89 e9                	mov    %ebp,%ecx
  802172:	85 ed                	test   %ebp,%ebp
  802174:	75 0b                	jne    802181 <__umoddi3+0x71>
  802176:	b8 01 00 00 00       	mov    $0x1,%eax
  80217b:	31 d2                	xor    %edx,%edx
  80217d:	f7 f5                	div    %ebp
  80217f:	89 c1                	mov    %eax,%ecx
  802181:	89 d8                	mov    %ebx,%eax
  802183:	31 d2                	xor    %edx,%edx
  802185:	f7 f1                	div    %ecx
  802187:	89 f0                	mov    %esi,%eax
  802189:	f7 f1                	div    %ecx
  80218b:	89 d0                	mov    %edx,%eax
  80218d:	31 d2                	xor    %edx,%edx
  80218f:	eb ac                	jmp    80213d <__umoddi3+0x2d>
  802191:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802198:	8b 44 24 04          	mov    0x4(%esp),%eax
  80219c:	ba 20 00 00 00       	mov    $0x20,%edx
  8021a1:	29 c2                	sub    %eax,%edx
  8021a3:	89 c1                	mov    %eax,%ecx
  8021a5:	89 e8                	mov    %ebp,%eax
  8021a7:	d3 e7                	shl    %cl,%edi
  8021a9:	89 d1                	mov    %edx,%ecx
  8021ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8021af:	d3 e8                	shr    %cl,%eax
  8021b1:	89 c1                	mov    %eax,%ecx
  8021b3:	8b 44 24 04          	mov    0x4(%esp),%eax
  8021b7:	09 f9                	or     %edi,%ecx
  8021b9:	89 df                	mov    %ebx,%edi
  8021bb:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021bf:	89 c1                	mov    %eax,%ecx
  8021c1:	d3 e5                	shl    %cl,%ebp
  8021c3:	89 d1                	mov    %edx,%ecx
  8021c5:	d3 ef                	shr    %cl,%edi
  8021c7:	89 c1                	mov    %eax,%ecx
  8021c9:	89 f0                	mov    %esi,%eax
  8021cb:	d3 e3                	shl    %cl,%ebx
  8021cd:	89 d1                	mov    %edx,%ecx
  8021cf:	89 fa                	mov    %edi,%edx
  8021d1:	d3 e8                	shr    %cl,%eax
  8021d3:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8021d8:	09 d8                	or     %ebx,%eax
  8021da:	f7 74 24 08          	divl   0x8(%esp)
  8021de:	89 d3                	mov    %edx,%ebx
  8021e0:	d3 e6                	shl    %cl,%esi
  8021e2:	f7 e5                	mul    %ebp
  8021e4:	89 c7                	mov    %eax,%edi
  8021e6:	89 d1                	mov    %edx,%ecx
  8021e8:	39 d3                	cmp    %edx,%ebx
  8021ea:	72 06                	jb     8021f2 <__umoddi3+0xe2>
  8021ec:	75 0e                	jne    8021fc <__umoddi3+0xec>
  8021ee:	39 c6                	cmp    %eax,%esi
  8021f0:	73 0a                	jae    8021fc <__umoddi3+0xec>
  8021f2:	29 e8                	sub    %ebp,%eax
  8021f4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8021f8:	89 d1                	mov    %edx,%ecx
  8021fa:	89 c7                	mov    %eax,%edi
  8021fc:	89 f5                	mov    %esi,%ebp
  8021fe:	8b 74 24 04          	mov    0x4(%esp),%esi
  802202:	29 fd                	sub    %edi,%ebp
  802204:	19 cb                	sbb    %ecx,%ebx
  802206:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  80220b:	89 d8                	mov    %ebx,%eax
  80220d:	d3 e0                	shl    %cl,%eax
  80220f:	89 f1                	mov    %esi,%ecx
  802211:	d3 ed                	shr    %cl,%ebp
  802213:	d3 eb                	shr    %cl,%ebx
  802215:	09 e8                	or     %ebp,%eax
  802217:	89 da                	mov    %ebx,%edx
  802219:	83 c4 1c             	add    $0x1c,%esp
  80221c:	5b                   	pop    %ebx
  80221d:	5e                   	pop    %esi
  80221e:	5f                   	pop    %edi
  80221f:	5d                   	pop    %ebp
  802220:	c3                   	ret    
