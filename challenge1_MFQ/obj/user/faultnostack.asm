
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
  800039:	68 c5 03 80 00       	push   $0x8003c5
  80003e:	6a 00                	push   $0x0
  800040:	e8 79 02 00 00       	call   8002be <sys_env_set_pgfault_upcall>
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
  80005f:	e8 d1 00 00 00       	call   800135 <sys_getenvid>
  800064:	25 ff 03 00 00       	and    $0x3ff,%eax
  800069:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80006f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800074:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800079:	85 db                	test   %ebx,%ebx
  80007b:	7e 07                	jle    800084 <libmain+0x30>
		binaryname = argv[0];
  80007d:	8b 06                	mov    (%esi),%eax
  80007f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	56                   	push   %esi
  800088:	53                   	push   %ebx
  800089:	e8 a5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008e:	e8 0a 00 00 00       	call   80009d <exit>
}
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800099:	5b                   	pop    %ebx
  80009a:	5e                   	pop    %esi
  80009b:	5d                   	pop    %ebp
  80009c:	c3                   	ret    

0080009d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009d:	55                   	push   %ebp
  80009e:	89 e5                	mov    %esp,%ebp
  8000a0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a3:	e8 14 05 00 00       	call   8005bc <close_all>
	sys_env_destroy(0);
  8000a8:	83 ec 0c             	sub    $0xc,%esp
  8000ab:	6a 00                	push   $0x0
  8000ad:	e8 42 00 00 00       	call   8000f4 <sys_env_destroy>
}
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	c9                   	leave  
  8000b6:	c3                   	ret    

008000b7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8000c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000c5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000c8:	89 c3                	mov    %eax,%ebx
  8000ca:	89 c7                	mov    %eax,%edi
  8000cc:	89 c6                	mov    %eax,%esi
  8000ce:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000d0:	5b                   	pop    %ebx
  8000d1:	5e                   	pop    %esi
  8000d2:	5f                   	pop    %edi
  8000d3:	5d                   	pop    %ebp
  8000d4:	c3                   	ret    

008000d5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	57                   	push   %edi
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000db:	ba 00 00 00 00       	mov    $0x0,%edx
  8000e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e5:	89 d1                	mov    %edx,%ecx
  8000e7:	89 d3                	mov    %edx,%ebx
  8000e9:	89 d7                	mov    %edx,%edi
  8000eb:	89 d6                	mov    %edx,%esi
  8000ed:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ef:	5b                   	pop    %ebx
  8000f0:	5e                   	pop    %esi
  8000f1:	5f                   	pop    %edi
  8000f2:	5d                   	pop    %ebp
  8000f3:	c3                   	ret    

008000f4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	57                   	push   %edi
  8000f8:	56                   	push   %esi
  8000f9:	53                   	push   %ebx
  8000fa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000fd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800102:	8b 55 08             	mov    0x8(%ebp),%edx
  800105:	b8 03 00 00 00       	mov    $0x3,%eax
  80010a:	89 cb                	mov    %ecx,%ebx
  80010c:	89 cf                	mov    %ecx,%edi
  80010e:	89 ce                	mov    %ecx,%esi
  800110:	cd 30                	int    $0x30
	if(check && ret > 0)
  800112:	85 c0                	test   %eax,%eax
  800114:	7f 08                	jg     80011e <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800116:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800119:	5b                   	pop    %ebx
  80011a:	5e                   	pop    %esi
  80011b:	5f                   	pop    %edi
  80011c:	5d                   	pop    %ebp
  80011d:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80011e:	83 ec 0c             	sub    $0xc,%esp
  800121:	50                   	push   %eax
  800122:	6a 03                	push   $0x3
  800124:	68 0a 23 80 00       	push   $0x80230a
  800129:	6a 2a                	push   $0x2a
  80012b:	68 27 23 80 00       	push   $0x802327
  800130:	e8 c4 13 00 00       	call   8014f9 <_panic>

00800135 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800135:	55                   	push   %ebp
  800136:	89 e5                	mov    %esp,%ebp
  800138:	57                   	push   %edi
  800139:	56                   	push   %esi
  80013a:	53                   	push   %ebx
	asm volatile("int %1\n"
  80013b:	ba 00 00 00 00       	mov    $0x0,%edx
  800140:	b8 02 00 00 00       	mov    $0x2,%eax
  800145:	89 d1                	mov    %edx,%ecx
  800147:	89 d3                	mov    %edx,%ebx
  800149:	89 d7                	mov    %edx,%edi
  80014b:	89 d6                	mov    %edx,%esi
  80014d:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80014f:	5b                   	pop    %ebx
  800150:	5e                   	pop    %esi
  800151:	5f                   	pop    %edi
  800152:	5d                   	pop    %ebp
  800153:	c3                   	ret    

00800154 <sys_yield>:

void
sys_yield(void)
{
  800154:	55                   	push   %ebp
  800155:	89 e5                	mov    %esp,%ebp
  800157:	57                   	push   %edi
  800158:	56                   	push   %esi
  800159:	53                   	push   %ebx
	asm volatile("int %1\n"
  80015a:	ba 00 00 00 00       	mov    $0x0,%edx
  80015f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800164:	89 d1                	mov    %edx,%ecx
  800166:	89 d3                	mov    %edx,%ebx
  800168:	89 d7                	mov    %edx,%edi
  80016a:	89 d6                	mov    %edx,%esi
  80016c:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80016e:	5b                   	pop    %ebx
  80016f:	5e                   	pop    %esi
  800170:	5f                   	pop    %edi
  800171:	5d                   	pop    %ebp
  800172:	c3                   	ret    

00800173 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	57                   	push   %edi
  800177:	56                   	push   %esi
  800178:	53                   	push   %ebx
  800179:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80017c:	be 00 00 00 00       	mov    $0x0,%esi
  800181:	8b 55 08             	mov    0x8(%ebp),%edx
  800184:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800187:	b8 04 00 00 00       	mov    $0x4,%eax
  80018c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018f:	89 f7                	mov    %esi,%edi
  800191:	cd 30                	int    $0x30
	if(check && ret > 0)
  800193:	85 c0                	test   %eax,%eax
  800195:	7f 08                	jg     80019f <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800197:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019a:	5b                   	pop    %ebx
  80019b:	5e                   	pop    %esi
  80019c:	5f                   	pop    %edi
  80019d:	5d                   	pop    %ebp
  80019e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80019f:	83 ec 0c             	sub    $0xc,%esp
  8001a2:	50                   	push   %eax
  8001a3:	6a 04                	push   $0x4
  8001a5:	68 0a 23 80 00       	push   $0x80230a
  8001aa:	6a 2a                	push   $0x2a
  8001ac:	68 27 23 80 00       	push   $0x802327
  8001b1:	e8 43 13 00 00       	call   8014f9 <_panic>

008001b6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001b6:	55                   	push   %ebp
  8001b7:	89 e5                	mov    %esp,%ebp
  8001b9:	57                   	push   %edi
  8001ba:	56                   	push   %esi
  8001bb:	53                   	push   %ebx
  8001bc:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001c5:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001cd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001d0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001d3:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	7f 08                	jg     8001e1 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001dc:	5b                   	pop    %ebx
  8001dd:	5e                   	pop    %esi
  8001de:	5f                   	pop    %edi
  8001df:	5d                   	pop    %ebp
  8001e0:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e1:	83 ec 0c             	sub    $0xc,%esp
  8001e4:	50                   	push   %eax
  8001e5:	6a 05                	push   $0x5
  8001e7:	68 0a 23 80 00       	push   $0x80230a
  8001ec:	6a 2a                	push   $0x2a
  8001ee:	68 27 23 80 00       	push   $0x802327
  8001f3:	e8 01 13 00 00       	call   8014f9 <_panic>

008001f8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001f8:	55                   	push   %ebp
  8001f9:	89 e5                	mov    %esp,%ebp
  8001fb:	57                   	push   %edi
  8001fc:	56                   	push   %esi
  8001fd:	53                   	push   %ebx
  8001fe:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800201:	bb 00 00 00 00       	mov    $0x0,%ebx
  800206:	8b 55 08             	mov    0x8(%ebp),%edx
  800209:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80020c:	b8 06 00 00 00       	mov    $0x6,%eax
  800211:	89 df                	mov    %ebx,%edi
  800213:	89 de                	mov    %ebx,%esi
  800215:	cd 30                	int    $0x30
	if(check && ret > 0)
  800217:	85 c0                	test   %eax,%eax
  800219:	7f 08                	jg     800223 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021e:	5b                   	pop    %ebx
  80021f:	5e                   	pop    %esi
  800220:	5f                   	pop    %edi
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800223:	83 ec 0c             	sub    $0xc,%esp
  800226:	50                   	push   %eax
  800227:	6a 06                	push   $0x6
  800229:	68 0a 23 80 00       	push   $0x80230a
  80022e:	6a 2a                	push   $0x2a
  800230:	68 27 23 80 00       	push   $0x802327
  800235:	e8 bf 12 00 00       	call   8014f9 <_panic>

0080023a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	57                   	push   %edi
  80023e:	56                   	push   %esi
  80023f:	53                   	push   %ebx
  800240:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800243:	bb 00 00 00 00       	mov    $0x0,%ebx
  800248:	8b 55 08             	mov    0x8(%ebp),%edx
  80024b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80024e:	b8 08 00 00 00       	mov    $0x8,%eax
  800253:	89 df                	mov    %ebx,%edi
  800255:	89 de                	mov    %ebx,%esi
  800257:	cd 30                	int    $0x30
	if(check && ret > 0)
  800259:	85 c0                	test   %eax,%eax
  80025b:	7f 08                	jg     800265 <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800260:	5b                   	pop    %ebx
  800261:	5e                   	pop    %esi
  800262:	5f                   	pop    %edi
  800263:	5d                   	pop    %ebp
  800264:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	50                   	push   %eax
  800269:	6a 08                	push   $0x8
  80026b:	68 0a 23 80 00       	push   $0x80230a
  800270:	6a 2a                	push   $0x2a
  800272:	68 27 23 80 00       	push   $0x802327
  800277:	e8 7d 12 00 00       	call   8014f9 <_panic>

0080027c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80027c:	55                   	push   %ebp
  80027d:	89 e5                	mov    %esp,%ebp
  80027f:	57                   	push   %edi
  800280:	56                   	push   %esi
  800281:	53                   	push   %ebx
  800282:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800285:	bb 00 00 00 00       	mov    $0x0,%ebx
  80028a:	8b 55 08             	mov    0x8(%ebp),%edx
  80028d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800290:	b8 09 00 00 00       	mov    $0x9,%eax
  800295:	89 df                	mov    %ebx,%edi
  800297:	89 de                	mov    %ebx,%esi
  800299:	cd 30                	int    $0x30
	if(check && ret > 0)
  80029b:	85 c0                	test   %eax,%eax
  80029d:	7f 08                	jg     8002a7 <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80029f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a2:	5b                   	pop    %ebx
  8002a3:	5e                   	pop    %esi
  8002a4:	5f                   	pop    %edi
  8002a5:	5d                   	pop    %ebp
  8002a6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a7:	83 ec 0c             	sub    $0xc,%esp
  8002aa:	50                   	push   %eax
  8002ab:	6a 09                	push   $0x9
  8002ad:	68 0a 23 80 00       	push   $0x80230a
  8002b2:	6a 2a                	push   $0x2a
  8002b4:	68 27 23 80 00       	push   $0x802327
  8002b9:	e8 3b 12 00 00       	call   8014f9 <_panic>

008002be <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002be:	55                   	push   %ebp
  8002bf:	89 e5                	mov    %esp,%ebp
  8002c1:	57                   	push   %edi
  8002c2:	56                   	push   %esi
  8002c3:	53                   	push   %ebx
  8002c4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002cc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002cf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002d2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002d7:	89 df                	mov    %ebx,%edi
  8002d9:	89 de                	mov    %ebx,%esi
  8002db:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002dd:	85 c0                	test   %eax,%eax
  8002df:	7f 08                	jg     8002e9 <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e4:	5b                   	pop    %ebx
  8002e5:	5e                   	pop    %esi
  8002e6:	5f                   	pop    %edi
  8002e7:	5d                   	pop    %ebp
  8002e8:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e9:	83 ec 0c             	sub    $0xc,%esp
  8002ec:	50                   	push   %eax
  8002ed:	6a 0a                	push   $0xa
  8002ef:	68 0a 23 80 00       	push   $0x80230a
  8002f4:	6a 2a                	push   $0x2a
  8002f6:	68 27 23 80 00       	push   $0x802327
  8002fb:	e8 f9 11 00 00       	call   8014f9 <_panic>

00800300 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	57                   	push   %edi
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
	asm volatile("int %1\n"
  800306:	8b 55 08             	mov    0x8(%ebp),%edx
  800309:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030c:	b8 0c 00 00 00       	mov    $0xc,%eax
  800311:	be 00 00 00 00       	mov    $0x0,%esi
  800316:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800319:	8b 7d 14             	mov    0x14(%ebp),%edi
  80031c:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80031e:	5b                   	pop    %ebx
  80031f:	5e                   	pop    %esi
  800320:	5f                   	pop    %edi
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800323:	55                   	push   %ebp
  800324:	89 e5                	mov    %esp,%ebp
  800326:	57                   	push   %edi
  800327:	56                   	push   %esi
  800328:	53                   	push   %ebx
  800329:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80032c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800331:	8b 55 08             	mov    0x8(%ebp),%edx
  800334:	b8 0d 00 00 00       	mov    $0xd,%eax
  800339:	89 cb                	mov    %ecx,%ebx
  80033b:	89 cf                	mov    %ecx,%edi
  80033d:	89 ce                	mov    %ecx,%esi
  80033f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800341:	85 c0                	test   %eax,%eax
  800343:	7f 08                	jg     80034d <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800345:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800348:	5b                   	pop    %ebx
  800349:	5e                   	pop    %esi
  80034a:	5f                   	pop    %edi
  80034b:	5d                   	pop    %ebp
  80034c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80034d:	83 ec 0c             	sub    $0xc,%esp
  800350:	50                   	push   %eax
  800351:	6a 0d                	push   $0xd
  800353:	68 0a 23 80 00       	push   $0x80230a
  800358:	6a 2a                	push   $0x2a
  80035a:	68 27 23 80 00       	push   $0x802327
  80035f:	e8 95 11 00 00       	call   8014f9 <_panic>

00800364 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
  800367:	57                   	push   %edi
  800368:	56                   	push   %esi
  800369:	53                   	push   %ebx
	asm volatile("int %1\n"
  80036a:	ba 00 00 00 00       	mov    $0x0,%edx
  80036f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800374:	89 d1                	mov    %edx,%ecx
  800376:	89 d3                	mov    %edx,%ebx
  800378:	89 d7                	mov    %edx,%edi
  80037a:	89 d6                	mov    %edx,%esi
  80037c:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80037e:	5b                   	pop    %ebx
  80037f:	5e                   	pop    %esi
  800380:	5f                   	pop    %edi
  800381:	5d                   	pop    %ebp
  800382:	c3                   	ret    

00800383 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
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
  800394:	b8 0f 00 00 00       	mov    $0xf,%eax
  800399:	89 df                	mov    %ebx,%edi
  80039b:	89 de                	mov    %ebx,%esi
  80039d:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  80039f:	5b                   	pop    %ebx
  8003a0:	5e                   	pop    %esi
  8003a1:	5f                   	pop    %edi
  8003a2:	5d                   	pop    %ebp
  8003a3:	c3                   	ret    

008003a4 <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	57                   	push   %edi
  8003a8:	56                   	push   %esi
  8003a9:	53                   	push   %ebx
	asm volatile("int %1\n"
  8003aa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8003af:	8b 55 08             	mov    0x8(%ebp),%edx
  8003b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8003b5:	b8 10 00 00 00       	mov    $0x10,%eax
  8003ba:	89 df                	mov    %ebx,%edi
  8003bc:	89 de                	mov    %ebx,%esi
  8003be:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8003c0:	5b                   	pop    %ebx
  8003c1:	5e                   	pop    %esi
  8003c2:	5f                   	pop    %edi
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8003c5:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8003c6:	a1 04 80 80 00       	mov    0x808004,%eax
	call *%eax
  8003cb:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8003cd:	83 c4 04             	add    $0x4,%esp
	//
	// LAB 4: Your code here. 
	//因为下一步之后就不能再操作常规寄存器了，所以要提前在栈中修改 utf_esp(减4)，以压入utf_eip。
	//struct PushRegs 32字节       EAX:累加器(Accumulator),  EDX：数据寄存器（Data Register） 其实选哪个寄存器应该都可以，
	//因为后面都会恢复重置，但我按照其功能说明选了这两个。
	movl 48(%esp), %eax// %eax中是utf_esp
  8003d0:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax 
  8003d4:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 48(%esp)
  8003d7:	89 44 24 30          	mov    %eax,0x30(%esp)
	//在新utf_esp 存入utf_eip。
	movl 40(%esp), %edx
  8003db:	8b 54 24 28          	mov    0x28(%esp),%edx
	movl %edx, (%eax)
  8003df:	89 10                	mov    %edx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.  
	addl $8, %esp
  8003e1:	83 c4 08             	add    $0x8,%esp
	popal  //弹出 utf_regs 此时 %esp 指向  utf_eip
  8003e4:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.  
	addl $4, %esp
  8003e5:	83 c4 04             	add    $0x4,%esp
	popfl//弹出utf_eflags
  8003e8:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp 
  8003e9:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	// 别忘了！！ ret 指令相当于 popl %eip
	ret
  8003ea:	c3                   	ret    

008003eb <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f1:	05 00 00 00 30       	add    $0x30000000,%eax
  8003f6:	c1 e8 0c             	shr    $0xc,%eax
}
  8003f9:	5d                   	pop    %ebp
  8003fa:	c3                   	ret    

008003fb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800401:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  800406:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80040b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800410:	5d                   	pop    %ebp
  800411:	c3                   	ret    

00800412 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80041a:	89 c2                	mov    %eax,%edx
  80041c:	c1 ea 16             	shr    $0x16,%edx
  80041f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800426:	f6 c2 01             	test   $0x1,%dl
  800429:	74 29                	je     800454 <fd_alloc+0x42>
  80042b:	89 c2                	mov    %eax,%edx
  80042d:	c1 ea 0c             	shr    $0xc,%edx
  800430:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800437:	f6 c2 01             	test   $0x1,%dl
  80043a:	74 18                	je     800454 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  80043c:	05 00 10 00 00       	add    $0x1000,%eax
  800441:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800446:	75 d2                	jne    80041a <fd_alloc+0x8>
  800448:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80044d:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800452:	eb 05                	jmp    800459 <fd_alloc+0x47>
			return 0;
  800454:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800459:	8b 55 08             	mov    0x8(%ebp),%edx
  80045c:	89 02                	mov    %eax,(%edx)
}
  80045e:	89 c8                	mov    %ecx,%eax
  800460:	5d                   	pop    %ebp
  800461:	c3                   	ret    

00800462 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800468:	83 f8 1f             	cmp    $0x1f,%eax
  80046b:	77 30                	ja     80049d <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80046d:	c1 e0 0c             	shl    $0xc,%eax
  800470:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800475:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80047b:	f6 c2 01             	test   $0x1,%dl
  80047e:	74 24                	je     8004a4 <fd_lookup+0x42>
  800480:	89 c2                	mov    %eax,%edx
  800482:	c1 ea 0c             	shr    $0xc,%edx
  800485:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80048c:	f6 c2 01             	test   $0x1,%dl
  80048f:	74 1a                	je     8004ab <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800491:	8b 55 0c             	mov    0xc(%ebp),%edx
  800494:	89 02                	mov    %eax,(%edx)
	return 0;
  800496:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80049b:	5d                   	pop    %ebp
  80049c:	c3                   	ret    
		return -E_INVAL;
  80049d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004a2:	eb f7                	jmp    80049b <fd_lookup+0x39>
		return -E_INVAL;
  8004a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004a9:	eb f0                	jmp    80049b <fd_lookup+0x39>
  8004ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8004b0:	eb e9                	jmp    80049b <fd_lookup+0x39>

008004b2 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8004b2:	55                   	push   %ebp
  8004b3:	89 e5                	mov    %esp,%ebp
  8004b5:	53                   	push   %ebx
  8004b6:	83 ec 04             	sub    $0x4,%esp
  8004b9:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8004bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c1:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  8004c6:	39 13                	cmp    %edx,(%ebx)
  8004c8:	74 37                	je     800501 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  8004ca:	83 c0 01             	add    $0x1,%eax
  8004cd:	8b 1c 85 b4 23 80 00 	mov    0x8023b4(,%eax,4),%ebx
  8004d4:	85 db                	test   %ebx,%ebx
  8004d6:	75 ee                	jne    8004c6 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8004d8:	a1 00 40 80 00       	mov    0x804000,%eax
  8004dd:	8b 40 58             	mov    0x58(%eax),%eax
  8004e0:	83 ec 04             	sub    $0x4,%esp
  8004e3:	52                   	push   %edx
  8004e4:	50                   	push   %eax
  8004e5:	68 38 23 80 00       	push   $0x802338
  8004ea:	e8 e5 10 00 00       	call   8015d4 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8004f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004fa:	89 1a                	mov    %ebx,(%edx)
}
  8004fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004ff:	c9                   	leave  
  800500:	c3                   	ret    
			return 0;
  800501:	b8 00 00 00 00       	mov    $0x0,%eax
  800506:	eb ef                	jmp    8004f7 <dev_lookup+0x45>

00800508 <fd_close>:
{
  800508:	55                   	push   %ebp
  800509:	89 e5                	mov    %esp,%ebp
  80050b:	57                   	push   %edi
  80050c:	56                   	push   %esi
  80050d:	53                   	push   %ebx
  80050e:	83 ec 24             	sub    $0x24,%esp
  800511:	8b 75 08             	mov    0x8(%ebp),%esi
  800514:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800517:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80051a:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80051b:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800521:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800524:	50                   	push   %eax
  800525:	e8 38 ff ff ff       	call   800462 <fd_lookup>
  80052a:	89 c3                	mov    %eax,%ebx
  80052c:	83 c4 10             	add    $0x10,%esp
  80052f:	85 c0                	test   %eax,%eax
  800531:	78 05                	js     800538 <fd_close+0x30>
	    || fd != fd2)
  800533:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800536:	74 16                	je     80054e <fd_close+0x46>
		return (must_exist ? r : 0);
  800538:	89 f8                	mov    %edi,%eax
  80053a:	84 c0                	test   %al,%al
  80053c:	b8 00 00 00 00       	mov    $0x0,%eax
  800541:	0f 44 d8             	cmove  %eax,%ebx
}
  800544:	89 d8                	mov    %ebx,%eax
  800546:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800549:	5b                   	pop    %ebx
  80054a:	5e                   	pop    %esi
  80054b:	5f                   	pop    %edi
  80054c:	5d                   	pop    %ebp
  80054d:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80054e:	83 ec 08             	sub    $0x8,%esp
  800551:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800554:	50                   	push   %eax
  800555:	ff 36                	push   (%esi)
  800557:	e8 56 ff ff ff       	call   8004b2 <dev_lookup>
  80055c:	89 c3                	mov    %eax,%ebx
  80055e:	83 c4 10             	add    $0x10,%esp
  800561:	85 c0                	test   %eax,%eax
  800563:	78 1a                	js     80057f <fd_close+0x77>
		if (dev->dev_close)
  800565:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800568:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80056b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800570:	85 c0                	test   %eax,%eax
  800572:	74 0b                	je     80057f <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800574:	83 ec 0c             	sub    $0xc,%esp
  800577:	56                   	push   %esi
  800578:	ff d0                	call   *%eax
  80057a:	89 c3                	mov    %eax,%ebx
  80057c:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80057f:	83 ec 08             	sub    $0x8,%esp
  800582:	56                   	push   %esi
  800583:	6a 00                	push   $0x0
  800585:	e8 6e fc ff ff       	call   8001f8 <sys_page_unmap>
	return r;
  80058a:	83 c4 10             	add    $0x10,%esp
  80058d:	eb b5                	jmp    800544 <fd_close+0x3c>

0080058f <close>:

int
close(int fdnum)
{
  80058f:	55                   	push   %ebp
  800590:	89 e5                	mov    %esp,%ebp
  800592:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800595:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800598:	50                   	push   %eax
  800599:	ff 75 08             	push   0x8(%ebp)
  80059c:	e8 c1 fe ff ff       	call   800462 <fd_lookup>
  8005a1:	83 c4 10             	add    $0x10,%esp
  8005a4:	85 c0                	test   %eax,%eax
  8005a6:	79 02                	jns    8005aa <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  8005a8:	c9                   	leave  
  8005a9:	c3                   	ret    
		return fd_close(fd, 1);
  8005aa:	83 ec 08             	sub    $0x8,%esp
  8005ad:	6a 01                	push   $0x1
  8005af:	ff 75 f4             	push   -0xc(%ebp)
  8005b2:	e8 51 ff ff ff       	call   800508 <fd_close>
  8005b7:	83 c4 10             	add    $0x10,%esp
  8005ba:	eb ec                	jmp    8005a8 <close+0x19>

008005bc <close_all>:

void
close_all(void)
{
  8005bc:	55                   	push   %ebp
  8005bd:	89 e5                	mov    %esp,%ebp
  8005bf:	53                   	push   %ebx
  8005c0:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8005c3:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8005c8:	83 ec 0c             	sub    $0xc,%esp
  8005cb:	53                   	push   %ebx
  8005cc:	e8 be ff ff ff       	call   80058f <close>
	for (i = 0; i < MAXFD; i++)
  8005d1:	83 c3 01             	add    $0x1,%ebx
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	83 fb 20             	cmp    $0x20,%ebx
  8005da:	75 ec                	jne    8005c8 <close_all+0xc>
}
  8005dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8005df:	c9                   	leave  
  8005e0:	c3                   	ret    

008005e1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005e1:	55                   	push   %ebp
  8005e2:	89 e5                	mov    %esp,%ebp
  8005e4:	57                   	push   %edi
  8005e5:	56                   	push   %esi
  8005e6:	53                   	push   %ebx
  8005e7:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005ea:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005ed:	50                   	push   %eax
  8005ee:	ff 75 08             	push   0x8(%ebp)
  8005f1:	e8 6c fe ff ff       	call   800462 <fd_lookup>
  8005f6:	89 c3                	mov    %eax,%ebx
  8005f8:	83 c4 10             	add    $0x10,%esp
  8005fb:	85 c0                	test   %eax,%eax
  8005fd:	78 7f                	js     80067e <dup+0x9d>
		return r;
	close(newfdnum);
  8005ff:	83 ec 0c             	sub    $0xc,%esp
  800602:	ff 75 0c             	push   0xc(%ebp)
  800605:	e8 85 ff ff ff       	call   80058f <close>

	newfd = INDEX2FD(newfdnum);
  80060a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80060d:	c1 e6 0c             	shl    $0xc,%esi
  800610:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800616:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800619:	89 3c 24             	mov    %edi,(%esp)
  80061c:	e8 da fd ff ff       	call   8003fb <fd2data>
  800621:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800623:	89 34 24             	mov    %esi,(%esp)
  800626:	e8 d0 fd ff ff       	call   8003fb <fd2data>
  80062b:	83 c4 10             	add    $0x10,%esp
  80062e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800631:	89 d8                	mov    %ebx,%eax
  800633:	c1 e8 16             	shr    $0x16,%eax
  800636:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80063d:	a8 01                	test   $0x1,%al
  80063f:	74 11                	je     800652 <dup+0x71>
  800641:	89 d8                	mov    %ebx,%eax
  800643:	c1 e8 0c             	shr    $0xc,%eax
  800646:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80064d:	f6 c2 01             	test   $0x1,%dl
  800650:	75 36                	jne    800688 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800652:	89 f8                	mov    %edi,%eax
  800654:	c1 e8 0c             	shr    $0xc,%eax
  800657:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80065e:	83 ec 0c             	sub    $0xc,%esp
  800661:	25 07 0e 00 00       	and    $0xe07,%eax
  800666:	50                   	push   %eax
  800667:	56                   	push   %esi
  800668:	6a 00                	push   $0x0
  80066a:	57                   	push   %edi
  80066b:	6a 00                	push   $0x0
  80066d:	e8 44 fb ff ff       	call   8001b6 <sys_page_map>
  800672:	89 c3                	mov    %eax,%ebx
  800674:	83 c4 20             	add    $0x20,%esp
  800677:	85 c0                	test   %eax,%eax
  800679:	78 33                	js     8006ae <dup+0xcd>
		goto err;

	return newfdnum;
  80067b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80067e:	89 d8                	mov    %ebx,%eax
  800680:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800683:	5b                   	pop    %ebx
  800684:	5e                   	pop    %esi
  800685:	5f                   	pop    %edi
  800686:	5d                   	pop    %ebp
  800687:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800688:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80068f:	83 ec 0c             	sub    $0xc,%esp
  800692:	25 07 0e 00 00       	and    $0xe07,%eax
  800697:	50                   	push   %eax
  800698:	ff 75 d4             	push   -0x2c(%ebp)
  80069b:	6a 00                	push   $0x0
  80069d:	53                   	push   %ebx
  80069e:	6a 00                	push   $0x0
  8006a0:	e8 11 fb ff ff       	call   8001b6 <sys_page_map>
  8006a5:	89 c3                	mov    %eax,%ebx
  8006a7:	83 c4 20             	add    $0x20,%esp
  8006aa:	85 c0                	test   %eax,%eax
  8006ac:	79 a4                	jns    800652 <dup+0x71>
	sys_page_unmap(0, newfd);
  8006ae:	83 ec 08             	sub    $0x8,%esp
  8006b1:	56                   	push   %esi
  8006b2:	6a 00                	push   $0x0
  8006b4:	e8 3f fb ff ff       	call   8001f8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8006b9:	83 c4 08             	add    $0x8,%esp
  8006bc:	ff 75 d4             	push   -0x2c(%ebp)
  8006bf:	6a 00                	push   $0x0
  8006c1:	e8 32 fb ff ff       	call   8001f8 <sys_page_unmap>
	return r;
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	eb b3                	jmp    80067e <dup+0x9d>

008006cb <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
  8006ce:	56                   	push   %esi
  8006cf:	53                   	push   %ebx
  8006d0:	83 ec 18             	sub    $0x18,%esp
  8006d3:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006d6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006d9:	50                   	push   %eax
  8006da:	56                   	push   %esi
  8006db:	e8 82 fd ff ff       	call   800462 <fd_lookup>
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	85 c0                	test   %eax,%eax
  8006e5:	78 3c                	js     800723 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006e7:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8006ea:	83 ec 08             	sub    $0x8,%esp
  8006ed:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006f0:	50                   	push   %eax
  8006f1:	ff 33                	push   (%ebx)
  8006f3:	e8 ba fd ff ff       	call   8004b2 <dev_lookup>
  8006f8:	83 c4 10             	add    $0x10,%esp
  8006fb:	85 c0                	test   %eax,%eax
  8006fd:	78 24                	js     800723 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006ff:	8b 43 08             	mov    0x8(%ebx),%eax
  800702:	83 e0 03             	and    $0x3,%eax
  800705:	83 f8 01             	cmp    $0x1,%eax
  800708:	74 20                	je     80072a <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80070a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070d:	8b 40 08             	mov    0x8(%eax),%eax
  800710:	85 c0                	test   %eax,%eax
  800712:	74 37                	je     80074b <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800714:	83 ec 04             	sub    $0x4,%esp
  800717:	ff 75 10             	push   0x10(%ebp)
  80071a:	ff 75 0c             	push   0xc(%ebp)
  80071d:	53                   	push   %ebx
  80071e:	ff d0                	call   *%eax
  800720:	83 c4 10             	add    $0x10,%esp
}
  800723:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800726:	5b                   	pop    %ebx
  800727:	5e                   	pop    %esi
  800728:	5d                   	pop    %ebp
  800729:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80072a:	a1 00 40 80 00       	mov    0x804000,%eax
  80072f:	8b 40 58             	mov    0x58(%eax),%eax
  800732:	83 ec 04             	sub    $0x4,%esp
  800735:	56                   	push   %esi
  800736:	50                   	push   %eax
  800737:	68 79 23 80 00       	push   $0x802379
  80073c:	e8 93 0e 00 00       	call   8015d4 <cprintf>
		return -E_INVAL;
  800741:	83 c4 10             	add    $0x10,%esp
  800744:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800749:	eb d8                	jmp    800723 <read+0x58>
		return -E_NOT_SUPP;
  80074b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800750:	eb d1                	jmp    800723 <read+0x58>

00800752 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800752:	55                   	push   %ebp
  800753:	89 e5                	mov    %esp,%ebp
  800755:	57                   	push   %edi
  800756:	56                   	push   %esi
  800757:	53                   	push   %ebx
  800758:	83 ec 0c             	sub    $0xc,%esp
  80075b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80075e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800761:	bb 00 00 00 00       	mov    $0x0,%ebx
  800766:	eb 02                	jmp    80076a <readn+0x18>
  800768:	01 c3                	add    %eax,%ebx
  80076a:	39 f3                	cmp    %esi,%ebx
  80076c:	73 21                	jae    80078f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	89 f0                	mov    %esi,%eax
  800773:	29 d8                	sub    %ebx,%eax
  800775:	50                   	push   %eax
  800776:	89 d8                	mov    %ebx,%eax
  800778:	03 45 0c             	add    0xc(%ebp),%eax
  80077b:	50                   	push   %eax
  80077c:	57                   	push   %edi
  80077d:	e8 49 ff ff ff       	call   8006cb <read>
		if (m < 0)
  800782:	83 c4 10             	add    $0x10,%esp
  800785:	85 c0                	test   %eax,%eax
  800787:	78 04                	js     80078d <readn+0x3b>
			return m;
		if (m == 0)
  800789:	75 dd                	jne    800768 <readn+0x16>
  80078b:	eb 02                	jmp    80078f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80078d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80078f:	89 d8                	mov    %ebx,%eax
  800791:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800794:	5b                   	pop    %ebx
  800795:	5e                   	pop    %esi
  800796:	5f                   	pop    %edi
  800797:	5d                   	pop    %ebp
  800798:	c3                   	ret    

00800799 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	56                   	push   %esi
  80079d:	53                   	push   %ebx
  80079e:	83 ec 18             	sub    $0x18,%esp
  8007a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007a7:	50                   	push   %eax
  8007a8:	53                   	push   %ebx
  8007a9:	e8 b4 fc ff ff       	call   800462 <fd_lookup>
  8007ae:	83 c4 10             	add    $0x10,%esp
  8007b1:	85 c0                	test   %eax,%eax
  8007b3:	78 37                	js     8007ec <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b5:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8007b8:	83 ec 08             	sub    $0x8,%esp
  8007bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007be:	50                   	push   %eax
  8007bf:	ff 36                	push   (%esi)
  8007c1:	e8 ec fc ff ff       	call   8004b2 <dev_lookup>
  8007c6:	83 c4 10             	add    $0x10,%esp
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	78 1f                	js     8007ec <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007cd:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  8007d1:	74 20                	je     8007f3 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8007d9:	85 c0                	test   %eax,%eax
  8007db:	74 37                	je     800814 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007dd:	83 ec 04             	sub    $0x4,%esp
  8007e0:	ff 75 10             	push   0x10(%ebp)
  8007e3:	ff 75 0c             	push   0xc(%ebp)
  8007e6:	56                   	push   %esi
  8007e7:	ff d0                	call   *%eax
  8007e9:	83 c4 10             	add    $0x10,%esp
}
  8007ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007ef:	5b                   	pop    %ebx
  8007f0:	5e                   	pop    %esi
  8007f1:	5d                   	pop    %ebp
  8007f2:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007f3:	a1 00 40 80 00       	mov    0x804000,%eax
  8007f8:	8b 40 58             	mov    0x58(%eax),%eax
  8007fb:	83 ec 04             	sub    $0x4,%esp
  8007fe:	53                   	push   %ebx
  8007ff:	50                   	push   %eax
  800800:	68 95 23 80 00       	push   $0x802395
  800805:	e8 ca 0d 00 00       	call   8015d4 <cprintf>
		return -E_INVAL;
  80080a:	83 c4 10             	add    $0x10,%esp
  80080d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800812:	eb d8                	jmp    8007ec <write+0x53>
		return -E_NOT_SUPP;
  800814:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800819:	eb d1                	jmp    8007ec <write+0x53>

0080081b <seek>:

int
seek(int fdnum, off_t offset)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800821:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800824:	50                   	push   %eax
  800825:	ff 75 08             	push   0x8(%ebp)
  800828:	e8 35 fc ff ff       	call   800462 <fd_lookup>
  80082d:	83 c4 10             	add    $0x10,%esp
  800830:	85 c0                	test   %eax,%eax
  800832:	78 0e                	js     800842 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  800834:	8b 55 0c             	mov    0xc(%ebp),%edx
  800837:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80083a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80083d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800842:	c9                   	leave  
  800843:	c3                   	ret    

00800844 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800844:	55                   	push   %ebp
  800845:	89 e5                	mov    %esp,%ebp
  800847:	56                   	push   %esi
  800848:	53                   	push   %ebx
  800849:	83 ec 18             	sub    $0x18,%esp
  80084c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80084f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800852:	50                   	push   %eax
  800853:	53                   	push   %ebx
  800854:	e8 09 fc ff ff       	call   800462 <fd_lookup>
  800859:	83 c4 10             	add    $0x10,%esp
  80085c:	85 c0                	test   %eax,%eax
  80085e:	78 34                	js     800894 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800860:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800863:	83 ec 08             	sub    $0x8,%esp
  800866:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800869:	50                   	push   %eax
  80086a:	ff 36                	push   (%esi)
  80086c:	e8 41 fc ff ff       	call   8004b2 <dev_lookup>
  800871:	83 c4 10             	add    $0x10,%esp
  800874:	85 c0                	test   %eax,%eax
  800876:	78 1c                	js     800894 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800878:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80087c:	74 1d                	je     80089b <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80087e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800881:	8b 40 18             	mov    0x18(%eax),%eax
  800884:	85 c0                	test   %eax,%eax
  800886:	74 34                	je     8008bc <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800888:	83 ec 08             	sub    $0x8,%esp
  80088b:	ff 75 0c             	push   0xc(%ebp)
  80088e:	56                   	push   %esi
  80088f:	ff d0                	call   *%eax
  800891:	83 c4 10             	add    $0x10,%esp
}
  800894:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800897:	5b                   	pop    %ebx
  800898:	5e                   	pop    %esi
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    
			thisenv->env_id, fdnum);
  80089b:	a1 00 40 80 00       	mov    0x804000,%eax
  8008a0:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8008a3:	83 ec 04             	sub    $0x4,%esp
  8008a6:	53                   	push   %ebx
  8008a7:	50                   	push   %eax
  8008a8:	68 58 23 80 00       	push   $0x802358
  8008ad:	e8 22 0d 00 00       	call   8015d4 <cprintf>
		return -E_INVAL;
  8008b2:	83 c4 10             	add    $0x10,%esp
  8008b5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008ba:	eb d8                	jmp    800894 <ftruncate+0x50>
		return -E_NOT_SUPP;
  8008bc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008c1:	eb d1                	jmp    800894 <ftruncate+0x50>

008008c3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8008c3:	55                   	push   %ebp
  8008c4:	89 e5                	mov    %esp,%ebp
  8008c6:	56                   	push   %esi
  8008c7:	53                   	push   %ebx
  8008c8:	83 ec 18             	sub    $0x18,%esp
  8008cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8008ce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8008d1:	50                   	push   %eax
  8008d2:	ff 75 08             	push   0x8(%ebp)
  8008d5:	e8 88 fb ff ff       	call   800462 <fd_lookup>
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	78 49                	js     80092a <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008e1:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8008e4:	83 ec 08             	sub    $0x8,%esp
  8008e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ea:	50                   	push   %eax
  8008eb:	ff 36                	push   (%esi)
  8008ed:	e8 c0 fb ff ff       	call   8004b2 <dev_lookup>
  8008f2:	83 c4 10             	add    $0x10,%esp
  8008f5:	85 c0                	test   %eax,%eax
  8008f7:	78 31                	js     80092a <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8008f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008fc:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800900:	74 2f                	je     800931 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800902:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800905:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80090c:	00 00 00 
	stat->st_isdir = 0;
  80090f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800916:	00 00 00 
	stat->st_dev = dev;
  800919:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80091f:	83 ec 08             	sub    $0x8,%esp
  800922:	53                   	push   %ebx
  800923:	56                   	push   %esi
  800924:	ff 50 14             	call   *0x14(%eax)
  800927:	83 c4 10             	add    $0x10,%esp
}
  80092a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80092d:	5b                   	pop    %ebx
  80092e:	5e                   	pop    %esi
  80092f:	5d                   	pop    %ebp
  800930:	c3                   	ret    
		return -E_NOT_SUPP;
  800931:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800936:	eb f2                	jmp    80092a <fstat+0x67>

00800938 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800938:	55                   	push   %ebp
  800939:	89 e5                	mov    %esp,%ebp
  80093b:	56                   	push   %esi
  80093c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80093d:	83 ec 08             	sub    $0x8,%esp
  800940:	6a 00                	push   $0x0
  800942:	ff 75 08             	push   0x8(%ebp)
  800945:	e8 e4 01 00 00       	call   800b2e <open>
  80094a:	89 c3                	mov    %eax,%ebx
  80094c:	83 c4 10             	add    $0x10,%esp
  80094f:	85 c0                	test   %eax,%eax
  800951:	78 1b                	js     80096e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800953:	83 ec 08             	sub    $0x8,%esp
  800956:	ff 75 0c             	push   0xc(%ebp)
  800959:	50                   	push   %eax
  80095a:	e8 64 ff ff ff       	call   8008c3 <fstat>
  80095f:	89 c6                	mov    %eax,%esi
	close(fd);
  800961:	89 1c 24             	mov    %ebx,(%esp)
  800964:	e8 26 fc ff ff       	call   80058f <close>
	return r;
  800969:	83 c4 10             	add    $0x10,%esp
  80096c:	89 f3                	mov    %esi,%ebx
}
  80096e:	89 d8                	mov    %ebx,%eax
  800970:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800973:	5b                   	pop    %ebx
  800974:	5e                   	pop    %esi
  800975:	5d                   	pop    %ebp
  800976:	c3                   	ret    

00800977 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	56                   	push   %esi
  80097b:	53                   	push   %ebx
  80097c:	89 c6                	mov    %eax,%esi
  80097e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800980:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800987:	74 27                	je     8009b0 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800989:	6a 07                	push   $0x7
  80098b:	68 00 50 80 00       	push   $0x805000
  800990:	56                   	push   %esi
  800991:	ff 35 00 60 80 00    	push   0x806000
  800997:	e8 38 16 00 00       	call   801fd4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80099c:	83 c4 0c             	add    $0xc,%esp
  80099f:	6a 00                	push   $0x0
  8009a1:	53                   	push   %ebx
  8009a2:	6a 00                	push   $0x0
  8009a4:	e8 bb 15 00 00       	call   801f64 <ipc_recv>
}
  8009a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8009ac:	5b                   	pop    %ebx
  8009ad:	5e                   	pop    %esi
  8009ae:	5d                   	pop    %ebp
  8009af:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8009b0:	83 ec 0c             	sub    $0xc,%esp
  8009b3:	6a 01                	push   $0x1
  8009b5:	e8 6e 16 00 00       	call   802028 <ipc_find_env>
  8009ba:	a3 00 60 80 00       	mov    %eax,0x806000
  8009bf:	83 c4 10             	add    $0x10,%esp
  8009c2:	eb c5                	jmp    800989 <fsipc+0x12>

008009c4 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 40 0c             	mov    0xc(%eax),%eax
  8009d0:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8009d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d8:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009e2:	b8 02 00 00 00       	mov    $0x2,%eax
  8009e7:	e8 8b ff ff ff       	call   800977 <fsipc>
}
  8009ec:	c9                   	leave  
  8009ed:	c3                   	ret    

008009ee <devfile_flush>:
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009fa:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009ff:	ba 00 00 00 00       	mov    $0x0,%edx
  800a04:	b8 06 00 00 00       	mov    $0x6,%eax
  800a09:	e8 69 ff ff ff       	call   800977 <fsipc>
}
  800a0e:	c9                   	leave  
  800a0f:	c3                   	ret    

00800a10 <devfile_stat>:
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	53                   	push   %ebx
  800a14:	83 ec 04             	sub    $0x4,%esp
  800a17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800a1a:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1d:	8b 40 0c             	mov    0xc(%eax),%eax
  800a20:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800a25:	ba 00 00 00 00       	mov    $0x0,%edx
  800a2a:	b8 05 00 00 00       	mov    $0x5,%eax
  800a2f:	e8 43 ff ff ff       	call   800977 <fsipc>
  800a34:	85 c0                	test   %eax,%eax
  800a36:	78 2c                	js     800a64 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a38:	83 ec 08             	sub    $0x8,%esp
  800a3b:	68 00 50 80 00       	push   $0x805000
  800a40:	53                   	push   %ebx
  800a41:	e8 68 11 00 00       	call   801bae <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a46:	a1 80 50 80 00       	mov    0x805080,%eax
  800a4b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a51:	a1 84 50 80 00       	mov    0x805084,%eax
  800a56:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a5c:	83 c4 10             	add    $0x10,%esp
  800a5f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a67:	c9                   	leave  
  800a68:	c3                   	ret    

00800a69 <devfile_write>:
{
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	83 ec 0c             	sub    $0xc,%esp
  800a6f:	8b 45 10             	mov    0x10(%ebp),%eax
  800a72:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a77:	39 d0                	cmp    %edx,%eax
  800a79:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a7f:	8b 52 0c             	mov    0xc(%edx),%edx
  800a82:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a88:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a8d:	50                   	push   %eax
  800a8e:	ff 75 0c             	push   0xc(%ebp)
  800a91:	68 08 50 80 00       	push   $0x805008
  800a96:	e8 a9 12 00 00       	call   801d44 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800a9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800aa0:	b8 04 00 00 00       	mov    $0x4,%eax
  800aa5:	e8 cd fe ff ff       	call   800977 <fsipc>
}
  800aaa:	c9                   	leave  
  800aab:	c3                   	ret    

00800aac <devfile_read>:
{
  800aac:	55                   	push   %ebp
  800aad:	89 e5                	mov    %esp,%ebp
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
  800ab1:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	8b 40 0c             	mov    0xc(%eax),%eax
  800aba:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800abf:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800ac5:	ba 00 00 00 00       	mov    $0x0,%edx
  800aca:	b8 03 00 00 00       	mov    $0x3,%eax
  800acf:	e8 a3 fe ff ff       	call   800977 <fsipc>
  800ad4:	89 c3                	mov    %eax,%ebx
  800ad6:	85 c0                	test   %eax,%eax
  800ad8:	78 1f                	js     800af9 <devfile_read+0x4d>
	assert(r <= n);
  800ada:	39 f0                	cmp    %esi,%eax
  800adc:	77 24                	ja     800b02 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800ade:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ae3:	7f 33                	jg     800b18 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ae5:	83 ec 04             	sub    $0x4,%esp
  800ae8:	50                   	push   %eax
  800ae9:	68 00 50 80 00       	push   $0x805000
  800aee:	ff 75 0c             	push   0xc(%ebp)
  800af1:	e8 4e 12 00 00       	call   801d44 <memmove>
	return r;
  800af6:	83 c4 10             	add    $0x10,%esp
}
  800af9:	89 d8                	mov    %ebx,%eax
  800afb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    
	assert(r <= n);
  800b02:	68 c8 23 80 00       	push   $0x8023c8
  800b07:	68 cf 23 80 00       	push   $0x8023cf
  800b0c:	6a 7c                	push   $0x7c
  800b0e:	68 e4 23 80 00       	push   $0x8023e4
  800b13:	e8 e1 09 00 00       	call   8014f9 <_panic>
	assert(r <= PGSIZE);
  800b18:	68 ef 23 80 00       	push   $0x8023ef
  800b1d:	68 cf 23 80 00       	push   $0x8023cf
  800b22:	6a 7d                	push   $0x7d
  800b24:	68 e4 23 80 00       	push   $0x8023e4
  800b29:	e8 cb 09 00 00       	call   8014f9 <_panic>

00800b2e <open>:
{
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	56                   	push   %esi
  800b32:	53                   	push   %ebx
  800b33:	83 ec 1c             	sub    $0x1c,%esp
  800b36:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800b39:	56                   	push   %esi
  800b3a:	e8 34 10 00 00       	call   801b73 <strlen>
  800b3f:	83 c4 10             	add    $0x10,%esp
  800b42:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b47:	7f 6c                	jg     800bb5 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800b49:	83 ec 0c             	sub    $0xc,%esp
  800b4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b4f:	50                   	push   %eax
  800b50:	e8 bd f8 ff ff       	call   800412 <fd_alloc>
  800b55:	89 c3                	mov    %eax,%ebx
  800b57:	83 c4 10             	add    $0x10,%esp
  800b5a:	85 c0                	test   %eax,%eax
  800b5c:	78 3c                	js     800b9a <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800b5e:	83 ec 08             	sub    $0x8,%esp
  800b61:	56                   	push   %esi
  800b62:	68 00 50 80 00       	push   $0x805000
  800b67:	e8 42 10 00 00       	call   801bae <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6f:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b74:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b77:	b8 01 00 00 00       	mov    $0x1,%eax
  800b7c:	e8 f6 fd ff ff       	call   800977 <fsipc>
  800b81:	89 c3                	mov    %eax,%ebx
  800b83:	83 c4 10             	add    $0x10,%esp
  800b86:	85 c0                	test   %eax,%eax
  800b88:	78 19                	js     800ba3 <open+0x75>
	return fd2num(fd);
  800b8a:	83 ec 0c             	sub    $0xc,%esp
  800b8d:	ff 75 f4             	push   -0xc(%ebp)
  800b90:	e8 56 f8 ff ff       	call   8003eb <fd2num>
  800b95:	89 c3                	mov    %eax,%ebx
  800b97:	83 c4 10             	add    $0x10,%esp
}
  800b9a:	89 d8                	mov    %ebx,%eax
  800b9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b9f:	5b                   	pop    %ebx
  800ba0:	5e                   	pop    %esi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    
		fd_close(fd, 0);
  800ba3:	83 ec 08             	sub    $0x8,%esp
  800ba6:	6a 00                	push   $0x0
  800ba8:	ff 75 f4             	push   -0xc(%ebp)
  800bab:	e8 58 f9 ff ff       	call   800508 <fd_close>
		return r;
  800bb0:	83 c4 10             	add    $0x10,%esp
  800bb3:	eb e5                	jmp    800b9a <open+0x6c>
		return -E_BAD_PATH;
  800bb5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800bba:	eb de                	jmp    800b9a <open+0x6c>

00800bbc <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800bbc:	55                   	push   %ebp
  800bbd:	89 e5                	mov    %esp,%ebp
  800bbf:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800bc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bc7:	b8 08 00 00 00       	mov    $0x8,%eax
  800bcc:	e8 a6 fd ff ff       	call   800977 <fsipc>
}
  800bd1:	c9                   	leave  
  800bd2:	c3                   	ret    

00800bd3 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800bd3:	55                   	push   %ebp
  800bd4:	89 e5                	mov    %esp,%ebp
  800bd6:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800bd9:	68 fb 23 80 00       	push   $0x8023fb
  800bde:	ff 75 0c             	push   0xc(%ebp)
  800be1:	e8 c8 0f 00 00       	call   801bae <strcpy>
	return 0;
}
  800be6:	b8 00 00 00 00       	mov    $0x0,%eax
  800beb:	c9                   	leave  
  800bec:	c3                   	ret    

00800bed <devsock_close>:
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	53                   	push   %ebx
  800bf1:	83 ec 10             	sub    $0x10,%esp
  800bf4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bf7:	53                   	push   %ebx
  800bf8:	e8 6a 14 00 00       	call   802067 <pageref>
  800bfd:	89 c2                	mov    %eax,%edx
  800bff:	83 c4 10             	add    $0x10,%esp
		return 0;
  800c02:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800c07:	83 fa 01             	cmp    $0x1,%edx
  800c0a:	74 05                	je     800c11 <devsock_close+0x24>
}
  800c0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800c0f:	c9                   	leave  
  800c10:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800c11:	83 ec 0c             	sub    $0xc,%esp
  800c14:	ff 73 0c             	push   0xc(%ebx)
  800c17:	e8 b7 02 00 00       	call   800ed3 <nsipc_close>
  800c1c:	83 c4 10             	add    $0x10,%esp
  800c1f:	eb eb                	jmp    800c0c <devsock_close+0x1f>

00800c21 <devsock_write>:
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800c27:	6a 00                	push   $0x0
  800c29:	ff 75 10             	push   0x10(%ebp)
  800c2c:	ff 75 0c             	push   0xc(%ebp)
  800c2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c32:	ff 70 0c             	push   0xc(%eax)
  800c35:	e8 79 03 00 00       	call   800fb3 <nsipc_send>
}
  800c3a:	c9                   	leave  
  800c3b:	c3                   	ret    

00800c3c <devsock_read>:
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c42:	6a 00                	push   $0x0
  800c44:	ff 75 10             	push   0x10(%ebp)
  800c47:	ff 75 0c             	push   0xc(%ebp)
  800c4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4d:	ff 70 0c             	push   0xc(%eax)
  800c50:	e8 ef 02 00 00       	call   800f44 <nsipc_recv>
}
  800c55:	c9                   	leave  
  800c56:	c3                   	ret    

00800c57 <fd2sockid>:
{
  800c57:	55                   	push   %ebp
  800c58:	89 e5                	mov    %esp,%ebp
  800c5a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c5d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c60:	52                   	push   %edx
  800c61:	50                   	push   %eax
  800c62:	e8 fb f7 ff ff       	call   800462 <fd_lookup>
  800c67:	83 c4 10             	add    $0x10,%esp
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	78 10                	js     800c7e <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c71:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c77:	39 08                	cmp    %ecx,(%eax)
  800c79:	75 05                	jne    800c80 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c7b:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c7e:	c9                   	leave  
  800c7f:	c3                   	ret    
		return -E_NOT_SUPP;
  800c80:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c85:	eb f7                	jmp    800c7e <fd2sockid+0x27>

00800c87 <alloc_sockfd>:
{
  800c87:	55                   	push   %ebp
  800c88:	89 e5                	mov    %esp,%ebp
  800c8a:	56                   	push   %esi
  800c8b:	53                   	push   %ebx
  800c8c:	83 ec 1c             	sub    $0x1c,%esp
  800c8f:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c94:	50                   	push   %eax
  800c95:	e8 78 f7 ff ff       	call   800412 <fd_alloc>
  800c9a:	89 c3                	mov    %eax,%ebx
  800c9c:	83 c4 10             	add    $0x10,%esp
  800c9f:	85 c0                	test   %eax,%eax
  800ca1:	78 43                	js     800ce6 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800ca3:	83 ec 04             	sub    $0x4,%esp
  800ca6:	68 07 04 00 00       	push   $0x407
  800cab:	ff 75 f4             	push   -0xc(%ebp)
  800cae:	6a 00                	push   $0x0
  800cb0:	e8 be f4 ff ff       	call   800173 <sys_page_alloc>
  800cb5:	89 c3                	mov    %eax,%ebx
  800cb7:	83 c4 10             	add    $0x10,%esp
  800cba:	85 c0                	test   %eax,%eax
  800cbc:	78 28                	js     800ce6 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800cbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cc1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800cc7:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800cc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ccc:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cd3:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cd6:	83 ec 0c             	sub    $0xc,%esp
  800cd9:	50                   	push   %eax
  800cda:	e8 0c f7 ff ff       	call   8003eb <fd2num>
  800cdf:	89 c3                	mov    %eax,%ebx
  800ce1:	83 c4 10             	add    $0x10,%esp
  800ce4:	eb 0c                	jmp    800cf2 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800ce6:	83 ec 0c             	sub    $0xc,%esp
  800ce9:	56                   	push   %esi
  800cea:	e8 e4 01 00 00       	call   800ed3 <nsipc_close>
		return r;
  800cef:	83 c4 10             	add    $0x10,%esp
}
  800cf2:	89 d8                	mov    %ebx,%eax
  800cf4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5d                   	pop    %ebp
  800cfa:	c3                   	ret    

00800cfb <accept>:
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d01:	8b 45 08             	mov    0x8(%ebp),%eax
  800d04:	e8 4e ff ff ff       	call   800c57 <fd2sockid>
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	78 1b                	js     800d28 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800d0d:	83 ec 04             	sub    $0x4,%esp
  800d10:	ff 75 10             	push   0x10(%ebp)
  800d13:	ff 75 0c             	push   0xc(%ebp)
  800d16:	50                   	push   %eax
  800d17:	e8 0e 01 00 00       	call   800e2a <nsipc_accept>
  800d1c:	83 c4 10             	add    $0x10,%esp
  800d1f:	85 c0                	test   %eax,%eax
  800d21:	78 05                	js     800d28 <accept+0x2d>
	return alloc_sockfd(r);
  800d23:	e8 5f ff ff ff       	call   800c87 <alloc_sockfd>
}
  800d28:	c9                   	leave  
  800d29:	c3                   	ret    

00800d2a <bind>:
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d30:	8b 45 08             	mov    0x8(%ebp),%eax
  800d33:	e8 1f ff ff ff       	call   800c57 <fd2sockid>
  800d38:	85 c0                	test   %eax,%eax
  800d3a:	78 12                	js     800d4e <bind+0x24>
	return nsipc_bind(r, name, namelen);
  800d3c:	83 ec 04             	sub    $0x4,%esp
  800d3f:	ff 75 10             	push   0x10(%ebp)
  800d42:	ff 75 0c             	push   0xc(%ebp)
  800d45:	50                   	push   %eax
  800d46:	e8 31 01 00 00       	call   800e7c <nsipc_bind>
  800d4b:	83 c4 10             	add    $0x10,%esp
}
  800d4e:	c9                   	leave  
  800d4f:	c3                   	ret    

00800d50 <shutdown>:
{
  800d50:	55                   	push   %ebp
  800d51:	89 e5                	mov    %esp,%ebp
  800d53:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d56:	8b 45 08             	mov    0x8(%ebp),%eax
  800d59:	e8 f9 fe ff ff       	call   800c57 <fd2sockid>
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	78 0f                	js     800d71 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  800d62:	83 ec 08             	sub    $0x8,%esp
  800d65:	ff 75 0c             	push   0xc(%ebp)
  800d68:	50                   	push   %eax
  800d69:	e8 43 01 00 00       	call   800eb1 <nsipc_shutdown>
  800d6e:	83 c4 10             	add    $0x10,%esp
}
  800d71:	c9                   	leave  
  800d72:	c3                   	ret    

00800d73 <connect>:
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d79:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7c:	e8 d6 fe ff ff       	call   800c57 <fd2sockid>
  800d81:	85 c0                	test   %eax,%eax
  800d83:	78 12                	js     800d97 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  800d85:	83 ec 04             	sub    $0x4,%esp
  800d88:	ff 75 10             	push   0x10(%ebp)
  800d8b:	ff 75 0c             	push   0xc(%ebp)
  800d8e:	50                   	push   %eax
  800d8f:	e8 59 01 00 00       	call   800eed <nsipc_connect>
  800d94:	83 c4 10             	add    $0x10,%esp
}
  800d97:	c9                   	leave  
  800d98:	c3                   	ret    

00800d99 <listen>:
{
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d9f:	8b 45 08             	mov    0x8(%ebp),%eax
  800da2:	e8 b0 fe ff ff       	call   800c57 <fd2sockid>
  800da7:	85 c0                	test   %eax,%eax
  800da9:	78 0f                	js     800dba <listen+0x21>
	return nsipc_listen(r, backlog);
  800dab:	83 ec 08             	sub    $0x8,%esp
  800dae:	ff 75 0c             	push   0xc(%ebp)
  800db1:	50                   	push   %eax
  800db2:	e8 6b 01 00 00       	call   800f22 <nsipc_listen>
  800db7:	83 c4 10             	add    $0x10,%esp
}
  800dba:	c9                   	leave  
  800dbb:	c3                   	ret    

00800dbc <socket>:

int
socket(int domain, int type, int protocol)
{
  800dbc:	55                   	push   %ebp
  800dbd:	89 e5                	mov    %esp,%ebp
  800dbf:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800dc2:	ff 75 10             	push   0x10(%ebp)
  800dc5:	ff 75 0c             	push   0xc(%ebp)
  800dc8:	ff 75 08             	push   0x8(%ebp)
  800dcb:	e8 41 02 00 00       	call   801011 <nsipc_socket>
  800dd0:	83 c4 10             	add    $0x10,%esp
  800dd3:	85 c0                	test   %eax,%eax
  800dd5:	78 05                	js     800ddc <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800dd7:	e8 ab fe ff ff       	call   800c87 <alloc_sockfd>
}
  800ddc:	c9                   	leave  
  800ddd:	c3                   	ret    

00800dde <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	53                   	push   %ebx
  800de2:	83 ec 04             	sub    $0x4,%esp
  800de5:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800de7:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  800dee:	74 26                	je     800e16 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800df0:	6a 07                	push   $0x7
  800df2:	68 00 70 80 00       	push   $0x807000
  800df7:	53                   	push   %ebx
  800df8:	ff 35 00 80 80 00    	push   0x808000
  800dfe:	e8 d1 11 00 00       	call   801fd4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800e03:	83 c4 0c             	add    $0xc,%esp
  800e06:	6a 00                	push   $0x0
  800e08:	6a 00                	push   $0x0
  800e0a:	6a 00                	push   $0x0
  800e0c:	e8 53 11 00 00       	call   801f64 <ipc_recv>
}
  800e11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e14:	c9                   	leave  
  800e15:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800e16:	83 ec 0c             	sub    $0xc,%esp
  800e19:	6a 02                	push   $0x2
  800e1b:	e8 08 12 00 00       	call   802028 <ipc_find_env>
  800e20:	a3 00 80 80 00       	mov    %eax,0x808000
  800e25:	83 c4 10             	add    $0x10,%esp
  800e28:	eb c6                	jmp    800df0 <nsipc+0x12>

00800e2a <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	56                   	push   %esi
  800e2e:	53                   	push   %ebx
  800e2f:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e32:	8b 45 08             	mov    0x8(%ebp),%eax
  800e35:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e3a:	8b 06                	mov    (%esi),%eax
  800e3c:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e41:	b8 01 00 00 00       	mov    $0x1,%eax
  800e46:	e8 93 ff ff ff       	call   800dde <nsipc>
  800e4b:	89 c3                	mov    %eax,%ebx
  800e4d:	85 c0                	test   %eax,%eax
  800e4f:	79 09                	jns    800e5a <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800e51:	89 d8                	mov    %ebx,%eax
  800e53:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e56:	5b                   	pop    %ebx
  800e57:	5e                   	pop    %esi
  800e58:	5d                   	pop    %ebp
  800e59:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e5a:	83 ec 04             	sub    $0x4,%esp
  800e5d:	ff 35 10 70 80 00    	push   0x807010
  800e63:	68 00 70 80 00       	push   $0x807000
  800e68:	ff 75 0c             	push   0xc(%ebp)
  800e6b:	e8 d4 0e 00 00       	call   801d44 <memmove>
		*addrlen = ret->ret_addrlen;
  800e70:	a1 10 70 80 00       	mov    0x807010,%eax
  800e75:	89 06                	mov    %eax,(%esi)
  800e77:	83 c4 10             	add    $0x10,%esp
	return r;
  800e7a:	eb d5                	jmp    800e51 <nsipc_accept+0x27>

00800e7c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	53                   	push   %ebx
  800e80:	83 ec 08             	sub    $0x8,%esp
  800e83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e86:	8b 45 08             	mov    0x8(%ebp),%eax
  800e89:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e8e:	53                   	push   %ebx
  800e8f:	ff 75 0c             	push   0xc(%ebp)
  800e92:	68 04 70 80 00       	push   $0x807004
  800e97:	e8 a8 0e 00 00       	call   801d44 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e9c:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  800ea2:	b8 02 00 00 00       	mov    $0x2,%eax
  800ea7:	e8 32 ff ff ff       	call   800dde <nsipc>
}
  800eac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eaf:	c9                   	leave  
  800eb0:	c3                   	ret    

00800eb1 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eba:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  800ebf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec2:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  800ec7:	b8 03 00 00 00       	mov    $0x3,%eax
  800ecc:	e8 0d ff ff ff       	call   800dde <nsipc>
}
  800ed1:	c9                   	leave  
  800ed2:	c3                   	ret    

00800ed3 <nsipc_close>:

int
nsipc_close(int s)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ed9:	8b 45 08             	mov    0x8(%ebp),%eax
  800edc:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  800ee1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ee6:	e8 f3 fe ff ff       	call   800dde <nsipc>
}
  800eeb:	c9                   	leave  
  800eec:	c3                   	ret    

00800eed <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eed:	55                   	push   %ebp
  800eee:	89 e5                	mov    %esp,%ebp
  800ef0:	53                   	push   %ebx
  800ef1:	83 ec 08             	sub    $0x8,%esp
  800ef4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  800efa:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800eff:	53                   	push   %ebx
  800f00:	ff 75 0c             	push   0xc(%ebp)
  800f03:	68 04 70 80 00       	push   $0x807004
  800f08:	e8 37 0e 00 00       	call   801d44 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800f0d:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  800f13:	b8 05 00 00 00       	mov    $0x5,%eax
  800f18:	e8 c1 fe ff ff       	call   800dde <nsipc>
}
  800f1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f20:	c9                   	leave  
  800f21:	c3                   	ret    

00800f22 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800f22:	55                   	push   %ebp
  800f23:	89 e5                	mov    %esp,%ebp
  800f25:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800f28:	8b 45 08             	mov    0x8(%ebp),%eax
  800f2b:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  800f30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f33:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  800f38:	b8 06 00 00 00       	mov    $0x6,%eax
  800f3d:	e8 9c fe ff ff       	call   800dde <nsipc>
}
  800f42:	c9                   	leave  
  800f43:	c3                   	ret    

00800f44 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	56                   	push   %esi
  800f48:	53                   	push   %ebx
  800f49:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f4c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f4f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  800f54:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  800f5a:	8b 45 14             	mov    0x14(%ebp),%eax
  800f5d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f62:	b8 07 00 00 00       	mov    $0x7,%eax
  800f67:	e8 72 fe ff ff       	call   800dde <nsipc>
  800f6c:	89 c3                	mov    %eax,%ebx
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	78 22                	js     800f94 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  800f72:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f77:	39 c6                	cmp    %eax,%esi
  800f79:	0f 4e c6             	cmovle %esi,%eax
  800f7c:	39 c3                	cmp    %eax,%ebx
  800f7e:	7f 1d                	jg     800f9d <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f80:	83 ec 04             	sub    $0x4,%esp
  800f83:	53                   	push   %ebx
  800f84:	68 00 70 80 00       	push   $0x807000
  800f89:	ff 75 0c             	push   0xc(%ebp)
  800f8c:	e8 b3 0d 00 00       	call   801d44 <memmove>
  800f91:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f94:	89 d8                	mov    %ebx,%eax
  800f96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f99:	5b                   	pop    %ebx
  800f9a:	5e                   	pop    %esi
  800f9b:	5d                   	pop    %ebp
  800f9c:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f9d:	68 07 24 80 00       	push   $0x802407
  800fa2:	68 cf 23 80 00       	push   $0x8023cf
  800fa7:	6a 62                	push   $0x62
  800fa9:	68 1c 24 80 00       	push   $0x80241c
  800fae:	e8 46 05 00 00       	call   8014f9 <_panic>

00800fb3 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	53                   	push   %ebx
  800fb7:	83 ec 04             	sub    $0x4,%esp
  800fba:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800fbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc0:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  800fc5:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800fcb:	7f 2e                	jg     800ffb <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fcd:	83 ec 04             	sub    $0x4,%esp
  800fd0:	53                   	push   %ebx
  800fd1:	ff 75 0c             	push   0xc(%ebp)
  800fd4:	68 0c 70 80 00       	push   $0x80700c
  800fd9:	e8 66 0d 00 00       	call   801d44 <memmove>
	nsipcbuf.send.req_size = size;
  800fde:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  800fe4:	8b 45 14             	mov    0x14(%ebp),%eax
  800fe7:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  800fec:	b8 08 00 00 00       	mov    $0x8,%eax
  800ff1:	e8 e8 fd ff ff       	call   800dde <nsipc>
}
  800ff6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    
	assert(size < 1600);
  800ffb:	68 28 24 80 00       	push   $0x802428
  801000:	68 cf 23 80 00       	push   $0x8023cf
  801005:	6a 6d                	push   $0x6d
  801007:	68 1c 24 80 00       	push   $0x80241c
  80100c:	e8 e8 04 00 00       	call   8014f9 <_panic>

00801011 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801011:	55                   	push   %ebp
  801012:	89 e5                	mov    %esp,%ebp
  801014:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801017:	8b 45 08             	mov    0x8(%ebp),%eax
  80101a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  80101f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801022:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  801027:	8b 45 10             	mov    0x10(%ebp),%eax
  80102a:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  80102f:	b8 09 00 00 00       	mov    $0x9,%eax
  801034:	e8 a5 fd ff ff       	call   800dde <nsipc>
}
  801039:	c9                   	leave  
  80103a:	c3                   	ret    

0080103b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80103b:	55                   	push   %ebp
  80103c:	89 e5                	mov    %esp,%ebp
  80103e:	56                   	push   %esi
  80103f:	53                   	push   %ebx
  801040:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801043:	83 ec 0c             	sub    $0xc,%esp
  801046:	ff 75 08             	push   0x8(%ebp)
  801049:	e8 ad f3 ff ff       	call   8003fb <fd2data>
  80104e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801050:	83 c4 08             	add    $0x8,%esp
  801053:	68 34 24 80 00       	push   $0x802434
  801058:	53                   	push   %ebx
  801059:	e8 50 0b 00 00       	call   801bae <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80105e:	8b 46 04             	mov    0x4(%esi),%eax
  801061:	2b 06                	sub    (%esi),%eax
  801063:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801069:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801070:	00 00 00 
	stat->st_dev = &devpipe;
  801073:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80107a:	30 80 00 
	return 0;
}
  80107d:	b8 00 00 00 00       	mov    $0x0,%eax
  801082:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801085:	5b                   	pop    %ebx
  801086:	5e                   	pop    %esi
  801087:	5d                   	pop    %ebp
  801088:	c3                   	ret    

00801089 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801089:	55                   	push   %ebp
  80108a:	89 e5                	mov    %esp,%ebp
  80108c:	53                   	push   %ebx
  80108d:	83 ec 0c             	sub    $0xc,%esp
  801090:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801093:	53                   	push   %ebx
  801094:	6a 00                	push   $0x0
  801096:	e8 5d f1 ff ff       	call   8001f8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80109b:	89 1c 24             	mov    %ebx,(%esp)
  80109e:	e8 58 f3 ff ff       	call   8003fb <fd2data>
  8010a3:	83 c4 08             	add    $0x8,%esp
  8010a6:	50                   	push   %eax
  8010a7:	6a 00                	push   $0x0
  8010a9:	e8 4a f1 ff ff       	call   8001f8 <sys_page_unmap>
}
  8010ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b1:	c9                   	leave  
  8010b2:	c3                   	ret    

008010b3 <_pipeisclosed>:
{
  8010b3:	55                   	push   %ebp
  8010b4:	89 e5                	mov    %esp,%ebp
  8010b6:	57                   	push   %edi
  8010b7:	56                   	push   %esi
  8010b8:	53                   	push   %ebx
  8010b9:	83 ec 1c             	sub    $0x1c,%esp
  8010bc:	89 c7                	mov    %eax,%edi
  8010be:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8010c0:	a1 00 40 80 00       	mov    0x804000,%eax
  8010c5:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8010c8:	83 ec 0c             	sub    $0xc,%esp
  8010cb:	57                   	push   %edi
  8010cc:	e8 96 0f 00 00       	call   802067 <pageref>
  8010d1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8010d4:	89 34 24             	mov    %esi,(%esp)
  8010d7:	e8 8b 0f 00 00       	call   802067 <pageref>
		nn = thisenv->env_runs;
  8010dc:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8010e2:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  8010e5:	83 c4 10             	add    $0x10,%esp
  8010e8:	39 cb                	cmp    %ecx,%ebx
  8010ea:	74 1b                	je     801107 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010ec:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010ef:	75 cf                	jne    8010c0 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010f1:	8b 42 68             	mov    0x68(%edx),%eax
  8010f4:	6a 01                	push   $0x1
  8010f6:	50                   	push   %eax
  8010f7:	53                   	push   %ebx
  8010f8:	68 3b 24 80 00       	push   $0x80243b
  8010fd:	e8 d2 04 00 00       	call   8015d4 <cprintf>
  801102:	83 c4 10             	add    $0x10,%esp
  801105:	eb b9                	jmp    8010c0 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801107:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80110a:	0f 94 c0             	sete   %al
  80110d:	0f b6 c0             	movzbl %al,%eax
}
  801110:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801113:	5b                   	pop    %ebx
  801114:	5e                   	pop    %esi
  801115:	5f                   	pop    %edi
  801116:	5d                   	pop    %ebp
  801117:	c3                   	ret    

00801118 <devpipe_write>:
{
  801118:	55                   	push   %ebp
  801119:	89 e5                	mov    %esp,%ebp
  80111b:	57                   	push   %edi
  80111c:	56                   	push   %esi
  80111d:	53                   	push   %ebx
  80111e:	83 ec 28             	sub    $0x28,%esp
  801121:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801124:	56                   	push   %esi
  801125:	e8 d1 f2 ff ff       	call   8003fb <fd2data>
  80112a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80112c:	83 c4 10             	add    $0x10,%esp
  80112f:	bf 00 00 00 00       	mov    $0x0,%edi
  801134:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801137:	75 09                	jne    801142 <devpipe_write+0x2a>
	return i;
  801139:	89 f8                	mov    %edi,%eax
  80113b:	eb 23                	jmp    801160 <devpipe_write+0x48>
			sys_yield();
  80113d:	e8 12 f0 ff ff       	call   800154 <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801142:	8b 43 04             	mov    0x4(%ebx),%eax
  801145:	8b 0b                	mov    (%ebx),%ecx
  801147:	8d 51 20             	lea    0x20(%ecx),%edx
  80114a:	39 d0                	cmp    %edx,%eax
  80114c:	72 1a                	jb     801168 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  80114e:	89 da                	mov    %ebx,%edx
  801150:	89 f0                	mov    %esi,%eax
  801152:	e8 5c ff ff ff       	call   8010b3 <_pipeisclosed>
  801157:	85 c0                	test   %eax,%eax
  801159:	74 e2                	je     80113d <devpipe_write+0x25>
				return 0;
  80115b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801160:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801163:	5b                   	pop    %ebx
  801164:	5e                   	pop    %esi
  801165:	5f                   	pop    %edi
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801168:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80116b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80116f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801172:	89 c2                	mov    %eax,%edx
  801174:	c1 fa 1f             	sar    $0x1f,%edx
  801177:	89 d1                	mov    %edx,%ecx
  801179:	c1 e9 1b             	shr    $0x1b,%ecx
  80117c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80117f:	83 e2 1f             	and    $0x1f,%edx
  801182:	29 ca                	sub    %ecx,%edx
  801184:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801188:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80118c:	83 c0 01             	add    $0x1,%eax
  80118f:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801192:	83 c7 01             	add    $0x1,%edi
  801195:	eb 9d                	jmp    801134 <devpipe_write+0x1c>

00801197 <devpipe_read>:
{
  801197:	55                   	push   %ebp
  801198:	89 e5                	mov    %esp,%ebp
  80119a:	57                   	push   %edi
  80119b:	56                   	push   %esi
  80119c:	53                   	push   %ebx
  80119d:	83 ec 18             	sub    $0x18,%esp
  8011a0:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8011a3:	57                   	push   %edi
  8011a4:	e8 52 f2 ff ff       	call   8003fb <fd2data>
  8011a9:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8011ab:	83 c4 10             	add    $0x10,%esp
  8011ae:	be 00 00 00 00       	mov    $0x0,%esi
  8011b3:	3b 75 10             	cmp    0x10(%ebp),%esi
  8011b6:	75 13                	jne    8011cb <devpipe_read+0x34>
	return i;
  8011b8:	89 f0                	mov    %esi,%eax
  8011ba:	eb 02                	jmp    8011be <devpipe_read+0x27>
				return i;
  8011bc:	89 f0                	mov    %esi,%eax
}
  8011be:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c1:	5b                   	pop    %ebx
  8011c2:	5e                   	pop    %esi
  8011c3:	5f                   	pop    %edi
  8011c4:	5d                   	pop    %ebp
  8011c5:	c3                   	ret    
			sys_yield();
  8011c6:	e8 89 ef ff ff       	call   800154 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8011cb:	8b 03                	mov    (%ebx),%eax
  8011cd:	3b 43 04             	cmp    0x4(%ebx),%eax
  8011d0:	75 18                	jne    8011ea <devpipe_read+0x53>
			if (i > 0)
  8011d2:	85 f6                	test   %esi,%esi
  8011d4:	75 e6                	jne    8011bc <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  8011d6:	89 da                	mov    %ebx,%edx
  8011d8:	89 f8                	mov    %edi,%eax
  8011da:	e8 d4 fe ff ff       	call   8010b3 <_pipeisclosed>
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	74 e3                	je     8011c6 <devpipe_read+0x2f>
				return 0;
  8011e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011e8:	eb d4                	jmp    8011be <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011ea:	99                   	cltd   
  8011eb:	c1 ea 1b             	shr    $0x1b,%edx
  8011ee:	01 d0                	add    %edx,%eax
  8011f0:	83 e0 1f             	and    $0x1f,%eax
  8011f3:	29 d0                	sub    %edx,%eax
  8011f5:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011fd:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801200:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801203:	83 c6 01             	add    $0x1,%esi
  801206:	eb ab                	jmp    8011b3 <devpipe_read+0x1c>

00801208 <pipe>:
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	56                   	push   %esi
  80120c:	53                   	push   %ebx
  80120d:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801210:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801213:	50                   	push   %eax
  801214:	e8 f9 f1 ff ff       	call   800412 <fd_alloc>
  801219:	89 c3                	mov    %eax,%ebx
  80121b:	83 c4 10             	add    $0x10,%esp
  80121e:	85 c0                	test   %eax,%eax
  801220:	0f 88 23 01 00 00    	js     801349 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801226:	83 ec 04             	sub    $0x4,%esp
  801229:	68 07 04 00 00       	push   $0x407
  80122e:	ff 75 f4             	push   -0xc(%ebp)
  801231:	6a 00                	push   $0x0
  801233:	e8 3b ef ff ff       	call   800173 <sys_page_alloc>
  801238:	89 c3                	mov    %eax,%ebx
  80123a:	83 c4 10             	add    $0x10,%esp
  80123d:	85 c0                	test   %eax,%eax
  80123f:	0f 88 04 01 00 00    	js     801349 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801245:	83 ec 0c             	sub    $0xc,%esp
  801248:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124b:	50                   	push   %eax
  80124c:	e8 c1 f1 ff ff       	call   800412 <fd_alloc>
  801251:	89 c3                	mov    %eax,%ebx
  801253:	83 c4 10             	add    $0x10,%esp
  801256:	85 c0                	test   %eax,%eax
  801258:	0f 88 db 00 00 00    	js     801339 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80125e:	83 ec 04             	sub    $0x4,%esp
  801261:	68 07 04 00 00       	push   $0x407
  801266:	ff 75 f0             	push   -0x10(%ebp)
  801269:	6a 00                	push   $0x0
  80126b:	e8 03 ef ff ff       	call   800173 <sys_page_alloc>
  801270:	89 c3                	mov    %eax,%ebx
  801272:	83 c4 10             	add    $0x10,%esp
  801275:	85 c0                	test   %eax,%eax
  801277:	0f 88 bc 00 00 00    	js     801339 <pipe+0x131>
	va = fd2data(fd0);
  80127d:	83 ec 0c             	sub    $0xc,%esp
  801280:	ff 75 f4             	push   -0xc(%ebp)
  801283:	e8 73 f1 ff ff       	call   8003fb <fd2data>
  801288:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80128a:	83 c4 0c             	add    $0xc,%esp
  80128d:	68 07 04 00 00       	push   $0x407
  801292:	50                   	push   %eax
  801293:	6a 00                	push   $0x0
  801295:	e8 d9 ee ff ff       	call   800173 <sys_page_alloc>
  80129a:	89 c3                	mov    %eax,%ebx
  80129c:	83 c4 10             	add    $0x10,%esp
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	0f 88 82 00 00 00    	js     801329 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8012a7:	83 ec 0c             	sub    $0xc,%esp
  8012aa:	ff 75 f0             	push   -0x10(%ebp)
  8012ad:	e8 49 f1 ff ff       	call   8003fb <fd2data>
  8012b2:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8012b9:	50                   	push   %eax
  8012ba:	6a 00                	push   $0x0
  8012bc:	56                   	push   %esi
  8012bd:	6a 00                	push   $0x0
  8012bf:	e8 f2 ee ff ff       	call   8001b6 <sys_page_map>
  8012c4:	89 c3                	mov    %eax,%ebx
  8012c6:	83 c4 20             	add    $0x20,%esp
  8012c9:	85 c0                	test   %eax,%eax
  8012cb:	78 4e                	js     80131b <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  8012cd:	a1 3c 30 80 00       	mov    0x80303c,%eax
  8012d2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012d5:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8012d7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012da:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8012e1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012e4:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012e9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012f0:	83 ec 0c             	sub    $0xc,%esp
  8012f3:	ff 75 f4             	push   -0xc(%ebp)
  8012f6:	e8 f0 f0 ff ff       	call   8003eb <fd2num>
  8012fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012fe:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801300:	83 c4 04             	add    $0x4,%esp
  801303:	ff 75 f0             	push   -0x10(%ebp)
  801306:	e8 e0 f0 ff ff       	call   8003eb <fd2num>
  80130b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80130e:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801311:	83 c4 10             	add    $0x10,%esp
  801314:	bb 00 00 00 00       	mov    $0x0,%ebx
  801319:	eb 2e                	jmp    801349 <pipe+0x141>
	sys_page_unmap(0, va);
  80131b:	83 ec 08             	sub    $0x8,%esp
  80131e:	56                   	push   %esi
  80131f:	6a 00                	push   $0x0
  801321:	e8 d2 ee ff ff       	call   8001f8 <sys_page_unmap>
  801326:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801329:	83 ec 08             	sub    $0x8,%esp
  80132c:	ff 75 f0             	push   -0x10(%ebp)
  80132f:	6a 00                	push   $0x0
  801331:	e8 c2 ee ff ff       	call   8001f8 <sys_page_unmap>
  801336:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801339:	83 ec 08             	sub    $0x8,%esp
  80133c:	ff 75 f4             	push   -0xc(%ebp)
  80133f:	6a 00                	push   $0x0
  801341:	e8 b2 ee ff ff       	call   8001f8 <sys_page_unmap>
  801346:	83 c4 10             	add    $0x10,%esp
}
  801349:	89 d8                	mov    %ebx,%eax
  80134b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80134e:	5b                   	pop    %ebx
  80134f:	5e                   	pop    %esi
  801350:	5d                   	pop    %ebp
  801351:	c3                   	ret    

00801352 <pipeisclosed>:
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801358:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135b:	50                   	push   %eax
  80135c:	ff 75 08             	push   0x8(%ebp)
  80135f:	e8 fe f0 ff ff       	call   800462 <fd_lookup>
  801364:	83 c4 10             	add    $0x10,%esp
  801367:	85 c0                	test   %eax,%eax
  801369:	78 18                	js     801383 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80136b:	83 ec 0c             	sub    $0xc,%esp
  80136e:	ff 75 f4             	push   -0xc(%ebp)
  801371:	e8 85 f0 ff ff       	call   8003fb <fd2data>
  801376:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801378:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80137b:	e8 33 fd ff ff       	call   8010b3 <_pipeisclosed>
  801380:	83 c4 10             	add    $0x10,%esp
}
  801383:	c9                   	leave  
  801384:	c3                   	ret    

00801385 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801385:	b8 00 00 00 00       	mov    $0x0,%eax
  80138a:	c3                   	ret    

0080138b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80138b:	55                   	push   %ebp
  80138c:	89 e5                	mov    %esp,%ebp
  80138e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801391:	68 53 24 80 00       	push   $0x802453
  801396:	ff 75 0c             	push   0xc(%ebp)
  801399:	e8 10 08 00 00       	call   801bae <strcpy>
	return 0;
}
  80139e:	b8 00 00 00 00       	mov    $0x0,%eax
  8013a3:	c9                   	leave  
  8013a4:	c3                   	ret    

008013a5 <devcons_write>:
{
  8013a5:	55                   	push   %ebp
  8013a6:	89 e5                	mov    %esp,%ebp
  8013a8:	57                   	push   %edi
  8013a9:	56                   	push   %esi
  8013aa:	53                   	push   %ebx
  8013ab:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8013b1:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8013b6:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8013bc:	eb 2e                	jmp    8013ec <devcons_write+0x47>
		m = n - tot;
  8013be:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013c1:	29 f3                	sub    %esi,%ebx
  8013c3:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8013c8:	39 c3                	cmp    %eax,%ebx
  8013ca:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8013cd:	83 ec 04             	sub    $0x4,%esp
  8013d0:	53                   	push   %ebx
  8013d1:	89 f0                	mov    %esi,%eax
  8013d3:	03 45 0c             	add    0xc(%ebp),%eax
  8013d6:	50                   	push   %eax
  8013d7:	57                   	push   %edi
  8013d8:	e8 67 09 00 00       	call   801d44 <memmove>
		sys_cputs(buf, m);
  8013dd:	83 c4 08             	add    $0x8,%esp
  8013e0:	53                   	push   %ebx
  8013e1:	57                   	push   %edi
  8013e2:	e8 d0 ec ff ff       	call   8000b7 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013e7:	01 de                	add    %ebx,%esi
  8013e9:	83 c4 10             	add    $0x10,%esp
  8013ec:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013ef:	72 cd                	jb     8013be <devcons_write+0x19>
}
  8013f1:	89 f0                	mov    %esi,%eax
  8013f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f6:	5b                   	pop    %ebx
  8013f7:	5e                   	pop    %esi
  8013f8:	5f                   	pop    %edi
  8013f9:	5d                   	pop    %ebp
  8013fa:	c3                   	ret    

008013fb <devcons_read>:
{
  8013fb:	55                   	push   %ebp
  8013fc:	89 e5                	mov    %esp,%ebp
  8013fe:	83 ec 08             	sub    $0x8,%esp
  801401:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801406:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80140a:	75 07                	jne    801413 <devcons_read+0x18>
  80140c:	eb 1f                	jmp    80142d <devcons_read+0x32>
		sys_yield();
  80140e:	e8 41 ed ff ff       	call   800154 <sys_yield>
	while ((c = sys_cgetc()) == 0)
  801413:	e8 bd ec ff ff       	call   8000d5 <sys_cgetc>
  801418:	85 c0                	test   %eax,%eax
  80141a:	74 f2                	je     80140e <devcons_read+0x13>
	if (c < 0)
  80141c:	78 0f                	js     80142d <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  80141e:	83 f8 04             	cmp    $0x4,%eax
  801421:	74 0c                	je     80142f <devcons_read+0x34>
	*(char*)vbuf = c;
  801423:	8b 55 0c             	mov    0xc(%ebp),%edx
  801426:	88 02                	mov    %al,(%edx)
	return 1;
  801428:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80142d:	c9                   	leave  
  80142e:	c3                   	ret    
		return 0;
  80142f:	b8 00 00 00 00       	mov    $0x0,%eax
  801434:	eb f7                	jmp    80142d <devcons_read+0x32>

00801436 <cputchar>:
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80143c:	8b 45 08             	mov    0x8(%ebp),%eax
  80143f:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801442:	6a 01                	push   $0x1
  801444:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801447:	50                   	push   %eax
  801448:	e8 6a ec ff ff       	call   8000b7 <sys_cputs>
}
  80144d:	83 c4 10             	add    $0x10,%esp
  801450:	c9                   	leave  
  801451:	c3                   	ret    

00801452 <getchar>:
{
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801458:	6a 01                	push   $0x1
  80145a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80145d:	50                   	push   %eax
  80145e:	6a 00                	push   $0x0
  801460:	e8 66 f2 ff ff       	call   8006cb <read>
	if (r < 0)
  801465:	83 c4 10             	add    $0x10,%esp
  801468:	85 c0                	test   %eax,%eax
  80146a:	78 06                	js     801472 <getchar+0x20>
	if (r < 1)
  80146c:	74 06                	je     801474 <getchar+0x22>
	return c;
  80146e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801472:	c9                   	leave  
  801473:	c3                   	ret    
		return -E_EOF;
  801474:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801479:	eb f7                	jmp    801472 <getchar+0x20>

0080147b <iscons>:
{
  80147b:	55                   	push   %ebp
  80147c:	89 e5                	mov    %esp,%ebp
  80147e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801484:	50                   	push   %eax
  801485:	ff 75 08             	push   0x8(%ebp)
  801488:	e8 d5 ef ff ff       	call   800462 <fd_lookup>
  80148d:	83 c4 10             	add    $0x10,%esp
  801490:	85 c0                	test   %eax,%eax
  801492:	78 11                	js     8014a5 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801494:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801497:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80149d:	39 10                	cmp    %edx,(%eax)
  80149f:	0f 94 c0             	sete   %al
  8014a2:	0f b6 c0             	movzbl %al,%eax
}
  8014a5:	c9                   	leave  
  8014a6:	c3                   	ret    

008014a7 <opencons>:
{
  8014a7:	55                   	push   %ebp
  8014a8:	89 e5                	mov    %esp,%ebp
  8014aa:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8014ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b0:	50                   	push   %eax
  8014b1:	e8 5c ef ff ff       	call   800412 <fd_alloc>
  8014b6:	83 c4 10             	add    $0x10,%esp
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	78 3a                	js     8014f7 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014bd:	83 ec 04             	sub    $0x4,%esp
  8014c0:	68 07 04 00 00       	push   $0x407
  8014c5:	ff 75 f4             	push   -0xc(%ebp)
  8014c8:	6a 00                	push   $0x0
  8014ca:	e8 a4 ec ff ff       	call   800173 <sys_page_alloc>
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	85 c0                	test   %eax,%eax
  8014d4:	78 21                	js     8014f7 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  8014d6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014d9:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014df:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014eb:	83 ec 0c             	sub    $0xc,%esp
  8014ee:	50                   	push   %eax
  8014ef:	e8 f7 ee ff ff       	call   8003eb <fd2num>
  8014f4:	83 c4 10             	add    $0x10,%esp
}
  8014f7:	c9                   	leave  
  8014f8:	c3                   	ret    

008014f9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014f9:	55                   	push   %ebp
  8014fa:	89 e5                	mov    %esp,%ebp
  8014fc:	56                   	push   %esi
  8014fd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014fe:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801501:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801507:	e8 29 ec ff ff       	call   800135 <sys_getenvid>
  80150c:	83 ec 0c             	sub    $0xc,%esp
  80150f:	ff 75 0c             	push   0xc(%ebp)
  801512:	ff 75 08             	push   0x8(%ebp)
  801515:	56                   	push   %esi
  801516:	50                   	push   %eax
  801517:	68 60 24 80 00       	push   $0x802460
  80151c:	e8 b3 00 00 00       	call   8015d4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801521:	83 c4 18             	add    $0x18,%esp
  801524:	53                   	push   %ebx
  801525:	ff 75 10             	push   0x10(%ebp)
  801528:	e8 56 00 00 00       	call   801583 <vcprintf>
	cprintf("\n");
  80152d:	c7 04 24 4c 24 80 00 	movl   $0x80244c,(%esp)
  801534:	e8 9b 00 00 00       	call   8015d4 <cprintf>
  801539:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80153c:	cc                   	int3   
  80153d:	eb fd                	jmp    80153c <_panic+0x43>

0080153f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	53                   	push   %ebx
  801543:	83 ec 04             	sub    $0x4,%esp
  801546:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801549:	8b 13                	mov    (%ebx),%edx
  80154b:	8d 42 01             	lea    0x1(%edx),%eax
  80154e:	89 03                	mov    %eax,(%ebx)
  801550:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801553:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801557:	3d ff 00 00 00       	cmp    $0xff,%eax
  80155c:	74 09                	je     801567 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80155e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801562:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801565:	c9                   	leave  
  801566:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801567:	83 ec 08             	sub    $0x8,%esp
  80156a:	68 ff 00 00 00       	push   $0xff
  80156f:	8d 43 08             	lea    0x8(%ebx),%eax
  801572:	50                   	push   %eax
  801573:	e8 3f eb ff ff       	call   8000b7 <sys_cputs>
		b->idx = 0;
  801578:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80157e:	83 c4 10             	add    $0x10,%esp
  801581:	eb db                	jmp    80155e <putch+0x1f>

00801583 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80158c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801593:	00 00 00 
	b.cnt = 0;
  801596:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80159d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8015a0:	ff 75 0c             	push   0xc(%ebp)
  8015a3:	ff 75 08             	push   0x8(%ebp)
  8015a6:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8015ac:	50                   	push   %eax
  8015ad:	68 3f 15 80 00       	push   $0x80153f
  8015b2:	e8 14 01 00 00       	call   8016cb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015b7:	83 c4 08             	add    $0x8,%esp
  8015ba:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  8015c0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015c6:	50                   	push   %eax
  8015c7:	e8 eb ea ff ff       	call   8000b7 <sys_cputs>

	return b.cnt;
}
  8015cc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015d2:	c9                   	leave  
  8015d3:	c3                   	ret    

008015d4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015d4:	55                   	push   %ebp
  8015d5:	89 e5                	mov    %esp,%ebp
  8015d7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015da:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015dd:	50                   	push   %eax
  8015de:	ff 75 08             	push   0x8(%ebp)
  8015e1:	e8 9d ff ff ff       	call   801583 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015e6:	c9                   	leave  
  8015e7:	c3                   	ret    

008015e8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015e8:	55                   	push   %ebp
  8015e9:	89 e5                	mov    %esp,%ebp
  8015eb:	57                   	push   %edi
  8015ec:	56                   	push   %esi
  8015ed:	53                   	push   %ebx
  8015ee:	83 ec 1c             	sub    $0x1c,%esp
  8015f1:	89 c7                	mov    %eax,%edi
  8015f3:	89 d6                	mov    %edx,%esi
  8015f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015fb:	89 d1                	mov    %edx,%ecx
  8015fd:	89 c2                	mov    %eax,%edx
  8015ff:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801602:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801605:	8b 45 10             	mov    0x10(%ebp),%eax
  801608:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80160b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80160e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801615:	39 c2                	cmp    %eax,%edx
  801617:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80161a:	72 3e                	jb     80165a <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80161c:	83 ec 0c             	sub    $0xc,%esp
  80161f:	ff 75 18             	push   0x18(%ebp)
  801622:	83 eb 01             	sub    $0x1,%ebx
  801625:	53                   	push   %ebx
  801626:	50                   	push   %eax
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	ff 75 e4             	push   -0x1c(%ebp)
  80162d:	ff 75 e0             	push   -0x20(%ebp)
  801630:	ff 75 dc             	push   -0x24(%ebp)
  801633:	ff 75 d8             	push   -0x28(%ebp)
  801636:	e8 75 0a 00 00       	call   8020b0 <__udivdi3>
  80163b:	83 c4 18             	add    $0x18,%esp
  80163e:	52                   	push   %edx
  80163f:	50                   	push   %eax
  801640:	89 f2                	mov    %esi,%edx
  801642:	89 f8                	mov    %edi,%eax
  801644:	e8 9f ff ff ff       	call   8015e8 <printnum>
  801649:	83 c4 20             	add    $0x20,%esp
  80164c:	eb 13                	jmp    801661 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80164e:	83 ec 08             	sub    $0x8,%esp
  801651:	56                   	push   %esi
  801652:	ff 75 18             	push   0x18(%ebp)
  801655:	ff d7                	call   *%edi
  801657:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80165a:	83 eb 01             	sub    $0x1,%ebx
  80165d:	85 db                	test   %ebx,%ebx
  80165f:	7f ed                	jg     80164e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801661:	83 ec 08             	sub    $0x8,%esp
  801664:	56                   	push   %esi
  801665:	83 ec 04             	sub    $0x4,%esp
  801668:	ff 75 e4             	push   -0x1c(%ebp)
  80166b:	ff 75 e0             	push   -0x20(%ebp)
  80166e:	ff 75 dc             	push   -0x24(%ebp)
  801671:	ff 75 d8             	push   -0x28(%ebp)
  801674:	e8 57 0b 00 00       	call   8021d0 <__umoddi3>
  801679:	83 c4 14             	add    $0x14,%esp
  80167c:	0f be 80 83 24 80 00 	movsbl 0x802483(%eax),%eax
  801683:	50                   	push   %eax
  801684:	ff d7                	call   *%edi
}
  801686:	83 c4 10             	add    $0x10,%esp
  801689:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80168c:	5b                   	pop    %ebx
  80168d:	5e                   	pop    %esi
  80168e:	5f                   	pop    %edi
  80168f:	5d                   	pop    %ebp
  801690:	c3                   	ret    

00801691 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801697:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80169b:	8b 10                	mov    (%eax),%edx
  80169d:	3b 50 04             	cmp    0x4(%eax),%edx
  8016a0:	73 0a                	jae    8016ac <sprintputch+0x1b>
		*b->buf++ = ch;
  8016a2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8016a5:	89 08                	mov    %ecx,(%eax)
  8016a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8016aa:	88 02                	mov    %al,(%edx)
}
  8016ac:	5d                   	pop    %ebp
  8016ad:	c3                   	ret    

008016ae <printfmt>:
{
  8016ae:	55                   	push   %ebp
  8016af:	89 e5                	mov    %esp,%ebp
  8016b1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8016b4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016b7:	50                   	push   %eax
  8016b8:	ff 75 10             	push   0x10(%ebp)
  8016bb:	ff 75 0c             	push   0xc(%ebp)
  8016be:	ff 75 08             	push   0x8(%ebp)
  8016c1:	e8 05 00 00 00       	call   8016cb <vprintfmt>
}
  8016c6:	83 c4 10             	add    $0x10,%esp
  8016c9:	c9                   	leave  
  8016ca:	c3                   	ret    

008016cb <vprintfmt>:
{
  8016cb:	55                   	push   %ebp
  8016cc:	89 e5                	mov    %esp,%ebp
  8016ce:	57                   	push   %edi
  8016cf:	56                   	push   %esi
  8016d0:	53                   	push   %ebx
  8016d1:	83 ec 3c             	sub    $0x3c,%esp
  8016d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8016d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016da:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016dd:	eb 0a                	jmp    8016e9 <vprintfmt+0x1e>
			putch(ch, putdat);
  8016df:	83 ec 08             	sub    $0x8,%esp
  8016e2:	53                   	push   %ebx
  8016e3:	50                   	push   %eax
  8016e4:	ff d6                	call   *%esi
  8016e6:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016e9:	83 c7 01             	add    $0x1,%edi
  8016ec:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016f0:	83 f8 25             	cmp    $0x25,%eax
  8016f3:	74 0c                	je     801701 <vprintfmt+0x36>
			if (ch == '\0')
  8016f5:	85 c0                	test   %eax,%eax
  8016f7:	75 e6                	jne    8016df <vprintfmt+0x14>
}
  8016f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016fc:	5b                   	pop    %ebx
  8016fd:	5e                   	pop    %esi
  8016fe:	5f                   	pop    %edi
  8016ff:	5d                   	pop    %ebp
  801700:	c3                   	ret    
		padc = ' ';
  801701:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  801705:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80170c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  801713:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80171a:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80171f:	8d 47 01             	lea    0x1(%edi),%eax
  801722:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801725:	0f b6 17             	movzbl (%edi),%edx
  801728:	8d 42 dd             	lea    -0x23(%edx),%eax
  80172b:	3c 55                	cmp    $0x55,%al
  80172d:	0f 87 bb 03 00 00    	ja     801aee <vprintfmt+0x423>
  801733:	0f b6 c0             	movzbl %al,%eax
  801736:	ff 24 85 c0 25 80 00 	jmp    *0x8025c0(,%eax,4)
  80173d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801740:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801744:	eb d9                	jmp    80171f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801746:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801749:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80174d:	eb d0                	jmp    80171f <vprintfmt+0x54>
  80174f:	0f b6 d2             	movzbl %dl,%edx
  801752:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801755:	b8 00 00 00 00       	mov    $0x0,%eax
  80175a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80175d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801760:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801764:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801767:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80176a:	83 f9 09             	cmp    $0x9,%ecx
  80176d:	77 55                	ja     8017c4 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80176f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801772:	eb e9                	jmp    80175d <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801774:	8b 45 14             	mov    0x14(%ebp),%eax
  801777:	8b 00                	mov    (%eax),%eax
  801779:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80177c:	8b 45 14             	mov    0x14(%ebp),%eax
  80177f:	8d 40 04             	lea    0x4(%eax),%eax
  801782:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801785:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801788:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80178c:	79 91                	jns    80171f <vprintfmt+0x54>
				width = precision, precision = -1;
  80178e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801791:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801794:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80179b:	eb 82                	jmp    80171f <vprintfmt+0x54>
  80179d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8017a0:	85 d2                	test   %edx,%edx
  8017a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8017a7:	0f 49 c2             	cmovns %edx,%eax
  8017aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8017ad:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017b0:	e9 6a ff ff ff       	jmp    80171f <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  8017b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8017b8:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8017bf:	e9 5b ff ff ff       	jmp    80171f <vprintfmt+0x54>
  8017c4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8017c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8017ca:	eb bc                	jmp    801788 <vprintfmt+0xbd>
			lflag++;
  8017cc:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8017cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8017d2:	e9 48 ff ff ff       	jmp    80171f <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  8017d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8017da:	8d 78 04             	lea    0x4(%eax),%edi
  8017dd:	83 ec 08             	sub    $0x8,%esp
  8017e0:	53                   	push   %ebx
  8017e1:	ff 30                	push   (%eax)
  8017e3:	ff d6                	call   *%esi
			break;
  8017e5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017e8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017eb:	e9 9d 02 00 00       	jmp    801a8d <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8017f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8017f3:	8d 78 04             	lea    0x4(%eax),%edi
  8017f6:	8b 10                	mov    (%eax),%edx
  8017f8:	89 d0                	mov    %edx,%eax
  8017fa:	f7 d8                	neg    %eax
  8017fc:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017ff:	83 f8 0f             	cmp    $0xf,%eax
  801802:	7f 23                	jg     801827 <vprintfmt+0x15c>
  801804:	8b 14 85 20 27 80 00 	mov    0x802720(,%eax,4),%edx
  80180b:	85 d2                	test   %edx,%edx
  80180d:	74 18                	je     801827 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  80180f:	52                   	push   %edx
  801810:	68 e1 23 80 00       	push   $0x8023e1
  801815:	53                   	push   %ebx
  801816:	56                   	push   %esi
  801817:	e8 92 fe ff ff       	call   8016ae <printfmt>
  80181c:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  80181f:	89 7d 14             	mov    %edi,0x14(%ebp)
  801822:	e9 66 02 00 00       	jmp    801a8d <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  801827:	50                   	push   %eax
  801828:	68 9b 24 80 00       	push   $0x80249b
  80182d:	53                   	push   %ebx
  80182e:	56                   	push   %esi
  80182f:	e8 7a fe ff ff       	call   8016ae <printfmt>
  801834:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  801837:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  80183a:	e9 4e 02 00 00       	jmp    801a8d <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  80183f:	8b 45 14             	mov    0x14(%ebp),%eax
  801842:	83 c0 04             	add    $0x4,%eax
  801845:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801848:	8b 45 14             	mov    0x14(%ebp),%eax
  80184b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80184d:	85 d2                	test   %edx,%edx
  80184f:	b8 94 24 80 00       	mov    $0x802494,%eax
  801854:	0f 45 c2             	cmovne %edx,%eax
  801857:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80185a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80185e:	7e 06                	jle    801866 <vprintfmt+0x19b>
  801860:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801864:	75 0d                	jne    801873 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801866:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801869:	89 c7                	mov    %eax,%edi
  80186b:	03 45 e0             	add    -0x20(%ebp),%eax
  80186e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801871:	eb 55                	jmp    8018c8 <vprintfmt+0x1fd>
  801873:	83 ec 08             	sub    $0x8,%esp
  801876:	ff 75 d8             	push   -0x28(%ebp)
  801879:	ff 75 cc             	push   -0x34(%ebp)
  80187c:	e8 0a 03 00 00       	call   801b8b <strnlen>
  801881:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801884:	29 c1                	sub    %eax,%ecx
  801886:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80188e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801892:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801895:	eb 0f                	jmp    8018a6 <vprintfmt+0x1db>
					putch(padc, putdat);
  801897:	83 ec 08             	sub    $0x8,%esp
  80189a:	53                   	push   %ebx
  80189b:	ff 75 e0             	push   -0x20(%ebp)
  80189e:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  8018a0:	83 ef 01             	sub    $0x1,%edi
  8018a3:	83 c4 10             	add    $0x10,%esp
  8018a6:	85 ff                	test   %edi,%edi
  8018a8:	7f ed                	jg     801897 <vprintfmt+0x1cc>
  8018aa:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8018ad:	85 d2                	test   %edx,%edx
  8018af:	b8 00 00 00 00       	mov    $0x0,%eax
  8018b4:	0f 49 c2             	cmovns %edx,%eax
  8018b7:	29 c2                	sub    %eax,%edx
  8018b9:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8018bc:	eb a8                	jmp    801866 <vprintfmt+0x19b>
					putch(ch, putdat);
  8018be:	83 ec 08             	sub    $0x8,%esp
  8018c1:	53                   	push   %ebx
  8018c2:	52                   	push   %edx
  8018c3:	ff d6                	call   *%esi
  8018c5:	83 c4 10             	add    $0x10,%esp
  8018c8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8018cb:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018cd:	83 c7 01             	add    $0x1,%edi
  8018d0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8018d4:	0f be d0             	movsbl %al,%edx
  8018d7:	85 d2                	test   %edx,%edx
  8018d9:	74 4b                	je     801926 <vprintfmt+0x25b>
  8018db:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018df:	78 06                	js     8018e7 <vprintfmt+0x21c>
  8018e1:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018e5:	78 1e                	js     801905 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8018e7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018eb:	74 d1                	je     8018be <vprintfmt+0x1f3>
  8018ed:	0f be c0             	movsbl %al,%eax
  8018f0:	83 e8 20             	sub    $0x20,%eax
  8018f3:	83 f8 5e             	cmp    $0x5e,%eax
  8018f6:	76 c6                	jbe    8018be <vprintfmt+0x1f3>
					putch('?', putdat);
  8018f8:	83 ec 08             	sub    $0x8,%esp
  8018fb:	53                   	push   %ebx
  8018fc:	6a 3f                	push   $0x3f
  8018fe:	ff d6                	call   *%esi
  801900:	83 c4 10             	add    $0x10,%esp
  801903:	eb c3                	jmp    8018c8 <vprintfmt+0x1fd>
  801905:	89 cf                	mov    %ecx,%edi
  801907:	eb 0e                	jmp    801917 <vprintfmt+0x24c>
				putch(' ', putdat);
  801909:	83 ec 08             	sub    $0x8,%esp
  80190c:	53                   	push   %ebx
  80190d:	6a 20                	push   $0x20
  80190f:	ff d6                	call   *%esi
			for (; width > 0; width--)
  801911:	83 ef 01             	sub    $0x1,%edi
  801914:	83 c4 10             	add    $0x10,%esp
  801917:	85 ff                	test   %edi,%edi
  801919:	7f ee                	jg     801909 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  80191b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80191e:	89 45 14             	mov    %eax,0x14(%ebp)
  801921:	e9 67 01 00 00       	jmp    801a8d <vprintfmt+0x3c2>
  801926:	89 cf                	mov    %ecx,%edi
  801928:	eb ed                	jmp    801917 <vprintfmt+0x24c>
	if (lflag >= 2)
  80192a:	83 f9 01             	cmp    $0x1,%ecx
  80192d:	7f 1b                	jg     80194a <vprintfmt+0x27f>
	else if (lflag)
  80192f:	85 c9                	test   %ecx,%ecx
  801931:	74 63                	je     801996 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  801933:	8b 45 14             	mov    0x14(%ebp),%eax
  801936:	8b 00                	mov    (%eax),%eax
  801938:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80193b:	99                   	cltd   
  80193c:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80193f:	8b 45 14             	mov    0x14(%ebp),%eax
  801942:	8d 40 04             	lea    0x4(%eax),%eax
  801945:	89 45 14             	mov    %eax,0x14(%ebp)
  801948:	eb 17                	jmp    801961 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80194a:	8b 45 14             	mov    0x14(%ebp),%eax
  80194d:	8b 50 04             	mov    0x4(%eax),%edx
  801950:	8b 00                	mov    (%eax),%eax
  801952:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801955:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801958:	8b 45 14             	mov    0x14(%ebp),%eax
  80195b:	8d 40 08             	lea    0x8(%eax),%eax
  80195e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801961:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801964:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801967:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80196c:	85 c9                	test   %ecx,%ecx
  80196e:	0f 89 ff 00 00 00    	jns    801a73 <vprintfmt+0x3a8>
				putch('-', putdat);
  801974:	83 ec 08             	sub    $0x8,%esp
  801977:	53                   	push   %ebx
  801978:	6a 2d                	push   $0x2d
  80197a:	ff d6                	call   *%esi
				num = -(long long) num;
  80197c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80197f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801982:	f7 da                	neg    %edx
  801984:	83 d1 00             	adc    $0x0,%ecx
  801987:	f7 d9                	neg    %ecx
  801989:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80198c:	bf 0a 00 00 00       	mov    $0xa,%edi
  801991:	e9 dd 00 00 00       	jmp    801a73 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801996:	8b 45 14             	mov    0x14(%ebp),%eax
  801999:	8b 00                	mov    (%eax),%eax
  80199b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80199e:	99                   	cltd   
  80199f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8019a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a5:	8d 40 04             	lea    0x4(%eax),%eax
  8019a8:	89 45 14             	mov    %eax,0x14(%ebp)
  8019ab:	eb b4                	jmp    801961 <vprintfmt+0x296>
	if (lflag >= 2)
  8019ad:	83 f9 01             	cmp    $0x1,%ecx
  8019b0:	7f 1e                	jg     8019d0 <vprintfmt+0x305>
	else if (lflag)
  8019b2:	85 c9                	test   %ecx,%ecx
  8019b4:	74 32                	je     8019e8 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  8019b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8019b9:	8b 10                	mov    (%eax),%edx
  8019bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019c0:	8d 40 04             	lea    0x4(%eax),%eax
  8019c3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019c6:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  8019cb:	e9 a3 00 00 00       	jmp    801a73 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8019d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8019d3:	8b 10                	mov    (%eax),%edx
  8019d5:	8b 48 04             	mov    0x4(%eax),%ecx
  8019d8:	8d 40 08             	lea    0x8(%eax),%eax
  8019db:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019de:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8019e3:	e9 8b 00 00 00       	jmp    801a73 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019e8:	8b 45 14             	mov    0x14(%ebp),%eax
  8019eb:	8b 10                	mov    (%eax),%edx
  8019ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019f2:	8d 40 04             	lea    0x4(%eax),%eax
  8019f5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019f8:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8019fd:	eb 74                	jmp    801a73 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8019ff:	83 f9 01             	cmp    $0x1,%ecx
  801a02:	7f 1b                	jg     801a1f <vprintfmt+0x354>
	else if (lflag)
  801a04:	85 c9                	test   %ecx,%ecx
  801a06:	74 2c                	je     801a34 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  801a08:	8b 45 14             	mov    0x14(%ebp),%eax
  801a0b:	8b 10                	mov    (%eax),%edx
  801a0d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a12:	8d 40 04             	lea    0x4(%eax),%eax
  801a15:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a18:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  801a1d:	eb 54                	jmp    801a73 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801a1f:	8b 45 14             	mov    0x14(%ebp),%eax
  801a22:	8b 10                	mov    (%eax),%edx
  801a24:	8b 48 04             	mov    0x4(%eax),%ecx
  801a27:	8d 40 08             	lea    0x8(%eax),%eax
  801a2a:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a2d:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  801a32:	eb 3f                	jmp    801a73 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801a34:	8b 45 14             	mov    0x14(%ebp),%eax
  801a37:	8b 10                	mov    (%eax),%edx
  801a39:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a3e:	8d 40 04             	lea    0x4(%eax),%eax
  801a41:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a44:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801a49:	eb 28                	jmp    801a73 <vprintfmt+0x3a8>
			putch('0', putdat);
  801a4b:	83 ec 08             	sub    $0x8,%esp
  801a4e:	53                   	push   %ebx
  801a4f:	6a 30                	push   $0x30
  801a51:	ff d6                	call   *%esi
			putch('x', putdat);
  801a53:	83 c4 08             	add    $0x8,%esp
  801a56:	53                   	push   %ebx
  801a57:	6a 78                	push   $0x78
  801a59:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a5b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a5e:	8b 10                	mov    (%eax),%edx
  801a60:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a65:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a68:	8d 40 04             	lea    0x4(%eax),%eax
  801a6b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a6e:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801a73:	83 ec 0c             	sub    $0xc,%esp
  801a76:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801a7a:	50                   	push   %eax
  801a7b:	ff 75 e0             	push   -0x20(%ebp)
  801a7e:	57                   	push   %edi
  801a7f:	51                   	push   %ecx
  801a80:	52                   	push   %edx
  801a81:	89 da                	mov    %ebx,%edx
  801a83:	89 f0                	mov    %esi,%eax
  801a85:	e8 5e fb ff ff       	call   8015e8 <printnum>
			break;
  801a8a:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801a8d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a90:	e9 54 fc ff ff       	jmp    8016e9 <vprintfmt+0x1e>
	if (lflag >= 2)
  801a95:	83 f9 01             	cmp    $0x1,%ecx
  801a98:	7f 1b                	jg     801ab5 <vprintfmt+0x3ea>
	else if (lflag)
  801a9a:	85 c9                	test   %ecx,%ecx
  801a9c:	74 2c                	je     801aca <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801a9e:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa1:	8b 10                	mov    (%eax),%edx
  801aa3:	b9 00 00 00 00       	mov    $0x0,%ecx
  801aa8:	8d 40 04             	lea    0x4(%eax),%eax
  801aab:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801aae:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  801ab3:	eb be                	jmp    801a73 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801ab5:	8b 45 14             	mov    0x14(%ebp),%eax
  801ab8:	8b 10                	mov    (%eax),%edx
  801aba:	8b 48 04             	mov    0x4(%eax),%ecx
  801abd:	8d 40 08             	lea    0x8(%eax),%eax
  801ac0:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ac3:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  801ac8:	eb a9                	jmp    801a73 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801aca:	8b 45 14             	mov    0x14(%ebp),%eax
  801acd:	8b 10                	mov    (%eax),%edx
  801acf:	b9 00 00 00 00       	mov    $0x0,%ecx
  801ad4:	8d 40 04             	lea    0x4(%eax),%eax
  801ad7:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801ada:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  801adf:	eb 92                	jmp    801a73 <vprintfmt+0x3a8>
			putch(ch, putdat);
  801ae1:	83 ec 08             	sub    $0x8,%esp
  801ae4:	53                   	push   %ebx
  801ae5:	6a 25                	push   $0x25
  801ae7:	ff d6                	call   *%esi
			break;
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	eb 9f                	jmp    801a8d <vprintfmt+0x3c2>
			putch('%', putdat);
  801aee:	83 ec 08             	sub    $0x8,%esp
  801af1:	53                   	push   %ebx
  801af2:	6a 25                	push   $0x25
  801af4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	89 f8                	mov    %edi,%eax
  801afb:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801aff:	74 05                	je     801b06 <vprintfmt+0x43b>
  801b01:	83 e8 01             	sub    $0x1,%eax
  801b04:	eb f5                	jmp    801afb <vprintfmt+0x430>
  801b06:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b09:	eb 82                	jmp    801a8d <vprintfmt+0x3c2>

00801b0b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	83 ec 18             	sub    $0x18,%esp
  801b11:	8b 45 08             	mov    0x8(%ebp),%eax
  801b14:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b17:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b1a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b1e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b21:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b28:	85 c0                	test   %eax,%eax
  801b2a:	74 26                	je     801b52 <vsnprintf+0x47>
  801b2c:	85 d2                	test   %edx,%edx
  801b2e:	7e 22                	jle    801b52 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b30:	ff 75 14             	push   0x14(%ebp)
  801b33:	ff 75 10             	push   0x10(%ebp)
  801b36:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b39:	50                   	push   %eax
  801b3a:	68 91 16 80 00       	push   $0x801691
  801b3f:	e8 87 fb ff ff       	call   8016cb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b44:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b47:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b4d:	83 c4 10             	add    $0x10,%esp
}
  801b50:	c9                   	leave  
  801b51:	c3                   	ret    
		return -E_INVAL;
  801b52:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b57:	eb f7                	jmp    801b50 <vsnprintf+0x45>

00801b59 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b59:	55                   	push   %ebp
  801b5a:	89 e5                	mov    %esp,%ebp
  801b5c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b5f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b62:	50                   	push   %eax
  801b63:	ff 75 10             	push   0x10(%ebp)
  801b66:	ff 75 0c             	push   0xc(%ebp)
  801b69:	ff 75 08             	push   0x8(%ebp)
  801b6c:	e8 9a ff ff ff       	call   801b0b <vsnprintf>
	va_end(ap);

	return rc;
}
  801b71:	c9                   	leave  
  801b72:	c3                   	ret    

00801b73 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b79:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7e:	eb 03                	jmp    801b83 <strlen+0x10>
		n++;
  801b80:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801b83:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b87:	75 f7                	jne    801b80 <strlen+0xd>
	return n;
}
  801b89:	5d                   	pop    %ebp
  801b8a:	c3                   	ret    

00801b8b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b91:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b94:	b8 00 00 00 00       	mov    $0x0,%eax
  801b99:	eb 03                	jmp    801b9e <strnlen+0x13>
		n++;
  801b9b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b9e:	39 d0                	cmp    %edx,%eax
  801ba0:	74 08                	je     801baa <strnlen+0x1f>
  801ba2:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801ba6:	75 f3                	jne    801b9b <strnlen+0x10>
  801ba8:	89 c2                	mov    %eax,%edx
	return n;
}
  801baa:	89 d0                	mov    %edx,%eax
  801bac:	5d                   	pop    %ebp
  801bad:	c3                   	ret    

00801bae <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bae:	55                   	push   %ebp
  801baf:	89 e5                	mov    %esp,%ebp
  801bb1:	53                   	push   %ebx
  801bb2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bb5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801bb8:	b8 00 00 00 00       	mov    $0x0,%eax
  801bbd:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801bc1:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801bc4:	83 c0 01             	add    $0x1,%eax
  801bc7:	84 d2                	test   %dl,%dl
  801bc9:	75 f2                	jne    801bbd <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801bcb:	89 c8                	mov    %ecx,%eax
  801bcd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd0:	c9                   	leave  
  801bd1:	c3                   	ret    

00801bd2 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	53                   	push   %ebx
  801bd6:	83 ec 10             	sub    $0x10,%esp
  801bd9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801bdc:	53                   	push   %ebx
  801bdd:	e8 91 ff ff ff       	call   801b73 <strlen>
  801be2:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801be5:	ff 75 0c             	push   0xc(%ebp)
  801be8:	01 d8                	add    %ebx,%eax
  801bea:	50                   	push   %eax
  801beb:	e8 be ff ff ff       	call   801bae <strcpy>
	return dst;
}
  801bf0:	89 d8                	mov    %ebx,%eax
  801bf2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bf5:	c9                   	leave  
  801bf6:	c3                   	ret    

00801bf7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	56                   	push   %esi
  801bfb:	53                   	push   %ebx
  801bfc:	8b 75 08             	mov    0x8(%ebp),%esi
  801bff:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c02:	89 f3                	mov    %esi,%ebx
  801c04:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c07:	89 f0                	mov    %esi,%eax
  801c09:	eb 0f                	jmp    801c1a <strncpy+0x23>
		*dst++ = *src;
  801c0b:	83 c0 01             	add    $0x1,%eax
  801c0e:	0f b6 0a             	movzbl (%edx),%ecx
  801c11:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c14:	80 f9 01             	cmp    $0x1,%cl
  801c17:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801c1a:	39 d8                	cmp    %ebx,%eax
  801c1c:	75 ed                	jne    801c0b <strncpy+0x14>
	}
	return ret;
}
  801c1e:	89 f0                	mov    %esi,%eax
  801c20:	5b                   	pop    %ebx
  801c21:	5e                   	pop    %esi
  801c22:	5d                   	pop    %ebp
  801c23:	c3                   	ret    

00801c24 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c24:	55                   	push   %ebp
  801c25:	89 e5                	mov    %esp,%ebp
  801c27:	56                   	push   %esi
  801c28:	53                   	push   %ebx
  801c29:	8b 75 08             	mov    0x8(%ebp),%esi
  801c2c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c2f:	8b 55 10             	mov    0x10(%ebp),%edx
  801c32:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c34:	85 d2                	test   %edx,%edx
  801c36:	74 21                	je     801c59 <strlcpy+0x35>
  801c38:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c3c:	89 f2                	mov    %esi,%edx
  801c3e:	eb 09                	jmp    801c49 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c40:	83 c1 01             	add    $0x1,%ecx
  801c43:	83 c2 01             	add    $0x1,%edx
  801c46:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801c49:	39 c2                	cmp    %eax,%edx
  801c4b:	74 09                	je     801c56 <strlcpy+0x32>
  801c4d:	0f b6 19             	movzbl (%ecx),%ebx
  801c50:	84 db                	test   %bl,%bl
  801c52:	75 ec                	jne    801c40 <strlcpy+0x1c>
  801c54:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801c56:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c59:	29 f0                	sub    %esi,%eax
}
  801c5b:	5b                   	pop    %ebx
  801c5c:	5e                   	pop    %esi
  801c5d:	5d                   	pop    %ebp
  801c5e:	c3                   	ret    

00801c5f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c5f:	55                   	push   %ebp
  801c60:	89 e5                	mov    %esp,%ebp
  801c62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c65:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c68:	eb 06                	jmp    801c70 <strcmp+0x11>
		p++, q++;
  801c6a:	83 c1 01             	add    $0x1,%ecx
  801c6d:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801c70:	0f b6 01             	movzbl (%ecx),%eax
  801c73:	84 c0                	test   %al,%al
  801c75:	74 04                	je     801c7b <strcmp+0x1c>
  801c77:	3a 02                	cmp    (%edx),%al
  801c79:	74 ef                	je     801c6a <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c7b:	0f b6 c0             	movzbl %al,%eax
  801c7e:	0f b6 12             	movzbl (%edx),%edx
  801c81:	29 d0                	sub    %edx,%eax
}
  801c83:	5d                   	pop    %ebp
  801c84:	c3                   	ret    

00801c85 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c85:	55                   	push   %ebp
  801c86:	89 e5                	mov    %esp,%ebp
  801c88:	53                   	push   %ebx
  801c89:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c8f:	89 c3                	mov    %eax,%ebx
  801c91:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c94:	eb 06                	jmp    801c9c <strncmp+0x17>
		n--, p++, q++;
  801c96:	83 c0 01             	add    $0x1,%eax
  801c99:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801c9c:	39 d8                	cmp    %ebx,%eax
  801c9e:	74 18                	je     801cb8 <strncmp+0x33>
  801ca0:	0f b6 08             	movzbl (%eax),%ecx
  801ca3:	84 c9                	test   %cl,%cl
  801ca5:	74 04                	je     801cab <strncmp+0x26>
  801ca7:	3a 0a                	cmp    (%edx),%cl
  801ca9:	74 eb                	je     801c96 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cab:	0f b6 00             	movzbl (%eax),%eax
  801cae:	0f b6 12             	movzbl (%edx),%edx
  801cb1:	29 d0                	sub    %edx,%eax
}
  801cb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cb6:	c9                   	leave  
  801cb7:	c3                   	ret    
		return 0;
  801cb8:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbd:	eb f4                	jmp    801cb3 <strncmp+0x2e>

00801cbf <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cc9:	eb 03                	jmp    801cce <strchr+0xf>
  801ccb:	83 c0 01             	add    $0x1,%eax
  801cce:	0f b6 10             	movzbl (%eax),%edx
  801cd1:	84 d2                	test   %dl,%dl
  801cd3:	74 06                	je     801cdb <strchr+0x1c>
		if (*s == c)
  801cd5:	38 ca                	cmp    %cl,%dl
  801cd7:	75 f2                	jne    801ccb <strchr+0xc>
  801cd9:	eb 05                	jmp    801ce0 <strchr+0x21>
			return (char *) s;
	return 0;
  801cdb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ce0:	5d                   	pop    %ebp
  801ce1:	c3                   	ret    

00801ce2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801ce2:	55                   	push   %ebp
  801ce3:	89 e5                	mov    %esp,%ebp
  801ce5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cec:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cef:	38 ca                	cmp    %cl,%dl
  801cf1:	74 09                	je     801cfc <strfind+0x1a>
  801cf3:	84 d2                	test   %dl,%dl
  801cf5:	74 05                	je     801cfc <strfind+0x1a>
	for (; *s; s++)
  801cf7:	83 c0 01             	add    $0x1,%eax
  801cfa:	eb f0                	jmp    801cec <strfind+0xa>
			break;
	return (char *) s;
}
  801cfc:	5d                   	pop    %ebp
  801cfd:	c3                   	ret    

00801cfe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	57                   	push   %edi
  801d02:	56                   	push   %esi
  801d03:	53                   	push   %ebx
  801d04:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d07:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d0a:	85 c9                	test   %ecx,%ecx
  801d0c:	74 2f                	je     801d3d <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d0e:	89 f8                	mov    %edi,%eax
  801d10:	09 c8                	or     %ecx,%eax
  801d12:	a8 03                	test   $0x3,%al
  801d14:	75 21                	jne    801d37 <memset+0x39>
		c &= 0xFF;
  801d16:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d1a:	89 d0                	mov    %edx,%eax
  801d1c:	c1 e0 08             	shl    $0x8,%eax
  801d1f:	89 d3                	mov    %edx,%ebx
  801d21:	c1 e3 18             	shl    $0x18,%ebx
  801d24:	89 d6                	mov    %edx,%esi
  801d26:	c1 e6 10             	shl    $0x10,%esi
  801d29:	09 f3                	or     %esi,%ebx
  801d2b:	09 da                	or     %ebx,%edx
  801d2d:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801d2f:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801d32:	fc                   	cld    
  801d33:	f3 ab                	rep stos %eax,%es:(%edi)
  801d35:	eb 06                	jmp    801d3d <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d37:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d3a:	fc                   	cld    
  801d3b:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d3d:	89 f8                	mov    %edi,%eax
  801d3f:	5b                   	pop    %ebx
  801d40:	5e                   	pop    %esi
  801d41:	5f                   	pop    %edi
  801d42:	5d                   	pop    %ebp
  801d43:	c3                   	ret    

00801d44 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
  801d47:	57                   	push   %edi
  801d48:	56                   	push   %esi
  801d49:	8b 45 08             	mov    0x8(%ebp),%eax
  801d4c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d4f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d52:	39 c6                	cmp    %eax,%esi
  801d54:	73 32                	jae    801d88 <memmove+0x44>
  801d56:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d59:	39 c2                	cmp    %eax,%edx
  801d5b:	76 2b                	jbe    801d88 <memmove+0x44>
		s += n;
		d += n;
  801d5d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d60:	89 d6                	mov    %edx,%esi
  801d62:	09 fe                	or     %edi,%esi
  801d64:	09 ce                	or     %ecx,%esi
  801d66:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d6c:	75 0e                	jne    801d7c <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d6e:	83 ef 04             	sub    $0x4,%edi
  801d71:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d74:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801d77:	fd                   	std    
  801d78:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d7a:	eb 09                	jmp    801d85 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d7c:	83 ef 01             	sub    $0x1,%edi
  801d7f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801d82:	fd                   	std    
  801d83:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d85:	fc                   	cld    
  801d86:	eb 1a                	jmp    801da2 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d88:	89 f2                	mov    %esi,%edx
  801d8a:	09 c2                	or     %eax,%edx
  801d8c:	09 ca                	or     %ecx,%edx
  801d8e:	f6 c2 03             	test   $0x3,%dl
  801d91:	75 0a                	jne    801d9d <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801d93:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801d96:	89 c7                	mov    %eax,%edi
  801d98:	fc                   	cld    
  801d99:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d9b:	eb 05                	jmp    801da2 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801d9d:	89 c7                	mov    %eax,%edi
  801d9f:	fc                   	cld    
  801da0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801da2:	5e                   	pop    %esi
  801da3:	5f                   	pop    %edi
  801da4:	5d                   	pop    %ebp
  801da5:	c3                   	ret    

00801da6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801da6:	55                   	push   %ebp
  801da7:	89 e5                	mov    %esp,%ebp
  801da9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801dac:	ff 75 10             	push   0x10(%ebp)
  801daf:	ff 75 0c             	push   0xc(%ebp)
  801db2:	ff 75 08             	push   0x8(%ebp)
  801db5:	e8 8a ff ff ff       	call   801d44 <memmove>
}
  801dba:	c9                   	leave  
  801dbb:	c3                   	ret    

00801dbc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801dbc:	55                   	push   %ebp
  801dbd:	89 e5                	mov    %esp,%ebp
  801dbf:	56                   	push   %esi
  801dc0:	53                   	push   %ebx
  801dc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc7:	89 c6                	mov    %eax,%esi
  801dc9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dcc:	eb 06                	jmp    801dd4 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801dce:	83 c0 01             	add    $0x1,%eax
  801dd1:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801dd4:	39 f0                	cmp    %esi,%eax
  801dd6:	74 14                	je     801dec <memcmp+0x30>
		if (*s1 != *s2)
  801dd8:	0f b6 08             	movzbl (%eax),%ecx
  801ddb:	0f b6 1a             	movzbl (%edx),%ebx
  801dde:	38 d9                	cmp    %bl,%cl
  801de0:	74 ec                	je     801dce <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801de2:	0f b6 c1             	movzbl %cl,%eax
  801de5:	0f b6 db             	movzbl %bl,%ebx
  801de8:	29 d8                	sub    %ebx,%eax
  801dea:	eb 05                	jmp    801df1 <memcmp+0x35>
	}

	return 0;
  801dec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801df1:	5b                   	pop    %ebx
  801df2:	5e                   	pop    %esi
  801df3:	5d                   	pop    %ebp
  801df4:	c3                   	ret    

00801df5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801dfe:	89 c2                	mov    %eax,%edx
  801e00:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801e03:	eb 03                	jmp    801e08 <memfind+0x13>
  801e05:	83 c0 01             	add    $0x1,%eax
  801e08:	39 d0                	cmp    %edx,%eax
  801e0a:	73 04                	jae    801e10 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e0c:	38 08                	cmp    %cl,(%eax)
  801e0e:	75 f5                	jne    801e05 <memfind+0x10>
			break;
	return (void *) s;
}
  801e10:	5d                   	pop    %ebp
  801e11:	c3                   	ret    

00801e12 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	57                   	push   %edi
  801e16:	56                   	push   %esi
  801e17:	53                   	push   %ebx
  801e18:	8b 55 08             	mov    0x8(%ebp),%edx
  801e1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e1e:	eb 03                	jmp    801e23 <strtol+0x11>
		s++;
  801e20:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801e23:	0f b6 02             	movzbl (%edx),%eax
  801e26:	3c 20                	cmp    $0x20,%al
  801e28:	74 f6                	je     801e20 <strtol+0xe>
  801e2a:	3c 09                	cmp    $0x9,%al
  801e2c:	74 f2                	je     801e20 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801e2e:	3c 2b                	cmp    $0x2b,%al
  801e30:	74 2a                	je     801e5c <strtol+0x4a>
	int neg = 0;
  801e32:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801e37:	3c 2d                	cmp    $0x2d,%al
  801e39:	74 2b                	je     801e66 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e3b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e41:	75 0f                	jne    801e52 <strtol+0x40>
  801e43:	80 3a 30             	cmpb   $0x30,(%edx)
  801e46:	74 28                	je     801e70 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e48:	85 db                	test   %ebx,%ebx
  801e4a:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e4f:	0f 44 d8             	cmove  %eax,%ebx
  801e52:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e57:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801e5a:	eb 46                	jmp    801ea2 <strtol+0x90>
		s++;
  801e5c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801e5f:	bf 00 00 00 00       	mov    $0x0,%edi
  801e64:	eb d5                	jmp    801e3b <strtol+0x29>
		s++, neg = 1;
  801e66:	83 c2 01             	add    $0x1,%edx
  801e69:	bf 01 00 00 00       	mov    $0x1,%edi
  801e6e:	eb cb                	jmp    801e3b <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e70:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e74:	74 0e                	je     801e84 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801e76:	85 db                	test   %ebx,%ebx
  801e78:	75 d8                	jne    801e52 <strtol+0x40>
		s++, base = 8;
  801e7a:	83 c2 01             	add    $0x1,%edx
  801e7d:	bb 08 00 00 00       	mov    $0x8,%ebx
  801e82:	eb ce                	jmp    801e52 <strtol+0x40>
		s += 2, base = 16;
  801e84:	83 c2 02             	add    $0x2,%edx
  801e87:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e8c:	eb c4                	jmp    801e52 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801e8e:	0f be c0             	movsbl %al,%eax
  801e91:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801e94:	3b 45 10             	cmp    0x10(%ebp),%eax
  801e97:	7d 3a                	jge    801ed3 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801e99:	83 c2 01             	add    $0x1,%edx
  801e9c:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801ea0:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801ea2:	0f b6 02             	movzbl (%edx),%eax
  801ea5:	8d 70 d0             	lea    -0x30(%eax),%esi
  801ea8:	89 f3                	mov    %esi,%ebx
  801eaa:	80 fb 09             	cmp    $0x9,%bl
  801ead:	76 df                	jbe    801e8e <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  801eaf:	8d 70 9f             	lea    -0x61(%eax),%esi
  801eb2:	89 f3                	mov    %esi,%ebx
  801eb4:	80 fb 19             	cmp    $0x19,%bl
  801eb7:	77 08                	ja     801ec1 <strtol+0xaf>
			dig = *s - 'a' + 10;
  801eb9:	0f be c0             	movsbl %al,%eax
  801ebc:	83 e8 57             	sub    $0x57,%eax
  801ebf:	eb d3                	jmp    801e94 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801ec1:	8d 70 bf             	lea    -0x41(%eax),%esi
  801ec4:	89 f3                	mov    %esi,%ebx
  801ec6:	80 fb 19             	cmp    $0x19,%bl
  801ec9:	77 08                	ja     801ed3 <strtol+0xc1>
			dig = *s - 'A' + 10;
  801ecb:	0f be c0             	movsbl %al,%eax
  801ece:	83 e8 37             	sub    $0x37,%eax
  801ed1:	eb c1                	jmp    801e94 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801ed3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801ed7:	74 05                	je     801ede <strtol+0xcc>
		*endptr = (char *) s;
  801ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
  801edc:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801ede:	89 c8                	mov    %ecx,%eax
  801ee0:	f7 d8                	neg    %eax
  801ee2:	85 ff                	test   %edi,%edi
  801ee4:	0f 45 c8             	cmovne %eax,%ecx
}
  801ee7:	89 c8                	mov    %ecx,%eax
  801ee9:	5b                   	pop    %ebx
  801eea:	5e                   	pop    %esi
  801eeb:	5f                   	pop    %edi
  801eec:	5d                   	pop    %ebp
  801eed:	c3                   	ret    

00801eee <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801eee:	55                   	push   %ebp
  801eef:	89 e5                	mov    %esp,%ebp
  801ef1:	83 ec 08             	sub    $0x8,%esp
	int r;

	if ( _pgfault_handler == 0) {
  801ef4:	83 3d 04 80 80 00 00 	cmpl   $0x0,0x808004
  801efb:	74 0a                	je     801f07 <set_pgfault_handler+0x19>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
		}
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801efd:	8b 45 08             	mov    0x8(%ebp),%eax
  801f00:	a3 04 80 80 00       	mov    %eax,0x808004
}
  801f05:	c9                   	leave  
  801f06:	c3                   	ret    
		r = sys_page_alloc(sys_getenvid(), (void *)(UXSTACKTOP-PGSIZE), PTE_SYSCALL);
  801f07:	e8 29 e2 ff ff       	call   800135 <sys_getenvid>
  801f0c:	83 ec 04             	sub    $0x4,%esp
  801f0f:	68 07 0e 00 00       	push   $0xe07
  801f14:	68 00 f0 bf ee       	push   $0xeebff000
  801f19:	50                   	push   %eax
  801f1a:	e8 54 e2 ff ff       	call   800173 <sys_page_alloc>
		if (r < 0) {
  801f1f:	83 c4 10             	add    $0x10,%esp
  801f22:	85 c0                	test   %eax,%eax
  801f24:	78 2c                	js     801f52 <set_pgfault_handler+0x64>
		r = sys_env_set_pgfault_upcall(sys_getenvid(), _pgfault_upcall);
  801f26:	e8 0a e2 ff ff       	call   800135 <sys_getenvid>
  801f2b:	83 ec 08             	sub    $0x8,%esp
  801f2e:	68 c5 03 80 00       	push   $0x8003c5
  801f33:	50                   	push   %eax
  801f34:	e8 85 e3 ff ff       	call   8002be <sys_env_set_pgfault_upcall>
		if (r < 0) {
  801f39:	83 c4 10             	add    $0x10,%esp
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	79 bd                	jns    801efd <set_pgfault_handler+0xf>
			panic("set_pgfault_handler : fail to set _pgfault_upcall: %e",r);
  801f40:	50                   	push   %eax
  801f41:	68 c0 27 80 00       	push   $0x8027c0
  801f46:	6a 28                	push   $0x28
  801f48:	68 f6 27 80 00       	push   $0x8027f6
  801f4d:	e8 a7 f5 ff ff       	call   8014f9 <_panic>
			panic("set_pgfault_handler : fail to alloc a page for UXSTACKTOP : %e",r);
  801f52:	50                   	push   %eax
  801f53:	68 80 27 80 00       	push   $0x802780
  801f58:	6a 23                	push   $0x23
  801f5a:	68 f6 27 80 00       	push   $0x8027f6
  801f5f:	e8 95 f5 ff ff       	call   8014f9 <_panic>

00801f64 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f64:	55                   	push   %ebp
  801f65:	89 e5                	mov    %esp,%ebp
  801f67:	56                   	push   %esi
  801f68:	53                   	push   %ebx
  801f69:	8b 75 08             	mov    0x8(%ebp),%esi
  801f6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801f72:	85 c0                	test   %eax,%eax
  801f74:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f79:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801f7c:	83 ec 0c             	sub    $0xc,%esp
  801f7f:	50                   	push   %eax
  801f80:	e8 9e e3 ff ff       	call   800323 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801f85:	83 c4 10             	add    $0x10,%esp
  801f88:	85 f6                	test   %esi,%esi
  801f8a:	74 17                	je     801fa3 <ipc_recv+0x3f>
  801f8c:	ba 00 00 00 00       	mov    $0x0,%edx
  801f91:	85 c0                	test   %eax,%eax
  801f93:	78 0c                	js     801fa1 <ipc_recv+0x3d>
  801f95:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f9b:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801fa1:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801fa3:	85 db                	test   %ebx,%ebx
  801fa5:	74 17                	je     801fbe <ipc_recv+0x5a>
  801fa7:	ba 00 00 00 00       	mov    $0x0,%edx
  801fac:	85 c0                	test   %eax,%eax
  801fae:	78 0c                	js     801fbc <ipc_recv+0x58>
  801fb0:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801fb6:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801fbc:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801fbe:	85 c0                	test   %eax,%eax
  801fc0:	78 0b                	js     801fcd <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801fc2:	a1 00 40 80 00       	mov    0x804000,%eax
  801fc7:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  801fcd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fd0:	5b                   	pop    %ebx
  801fd1:	5e                   	pop    %esi
  801fd2:	5d                   	pop    %ebp
  801fd3:	c3                   	ret    

00801fd4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fd4:	55                   	push   %ebp
  801fd5:	89 e5                	mov    %esp,%ebp
  801fd7:	57                   	push   %edi
  801fd8:	56                   	push   %esi
  801fd9:	53                   	push   %ebx
  801fda:	83 ec 0c             	sub    $0xc,%esp
  801fdd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fe0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fe3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801fe6:	85 db                	test   %ebx,%ebx
  801fe8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fed:	0f 44 d8             	cmove  %eax,%ebx
  801ff0:	eb 05                	jmp    801ff7 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801ff2:	e8 5d e1 ff ff       	call   800154 <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801ff7:	ff 75 14             	push   0x14(%ebp)
  801ffa:	53                   	push   %ebx
  801ffb:	56                   	push   %esi
  801ffc:	57                   	push   %edi
  801ffd:	e8 fe e2 ff ff       	call   800300 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  802002:	83 c4 10             	add    $0x10,%esp
  802005:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802008:	74 e8                	je     801ff2 <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  80200a:	85 c0                	test   %eax,%eax
  80200c:	78 08                	js     802016 <ipc_send+0x42>
	}while (r<0);

}
  80200e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802011:	5b                   	pop    %ebx
  802012:	5e                   	pop    %esi
  802013:	5f                   	pop    %edi
  802014:	5d                   	pop    %ebp
  802015:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  802016:	50                   	push   %eax
  802017:	68 04 28 80 00       	push   $0x802804
  80201c:	6a 3d                	push   $0x3d
  80201e:	68 18 28 80 00       	push   $0x802818
  802023:	e8 d1 f4 ff ff       	call   8014f9 <_panic>

00802028 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802028:	55                   	push   %ebp
  802029:	89 e5                	mov    %esp,%ebp
  80202b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80202e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802033:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  802039:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80203f:	8b 52 60             	mov    0x60(%edx),%edx
  802042:	39 ca                	cmp    %ecx,%edx
  802044:	74 11                	je     802057 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  802046:	83 c0 01             	add    $0x1,%eax
  802049:	3d 00 04 00 00       	cmp    $0x400,%eax
  80204e:	75 e3                	jne    802033 <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  802050:	b8 00 00 00 00       	mov    $0x0,%eax
  802055:	eb 0e                	jmp    802065 <ipc_find_env+0x3d>
			return envs[i].env_id;
  802057:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  80205d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802062:	8b 40 58             	mov    0x58(%eax),%eax
}
  802065:	5d                   	pop    %ebp
  802066:	c3                   	ret    

00802067 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802067:	55                   	push   %ebp
  802068:	89 e5                	mov    %esp,%ebp
  80206a:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80206d:	89 c2                	mov    %eax,%edx
  80206f:	c1 ea 16             	shr    $0x16,%edx
  802072:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802079:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80207e:	f6 c1 01             	test   $0x1,%cl
  802081:	74 1c                	je     80209f <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  802083:	c1 e8 0c             	shr    $0xc,%eax
  802086:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80208d:	a8 01                	test   $0x1,%al
  80208f:	74 0e                	je     80209f <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802091:	c1 e8 0c             	shr    $0xc,%eax
  802094:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80209b:	ef 
  80209c:	0f b7 d2             	movzwl %dx,%edx
}
  80209f:	89 d0                	mov    %edx,%eax
  8020a1:	5d                   	pop    %ebp
  8020a2:	c3                   	ret    
  8020a3:	66 90                	xchg   %ax,%ax
  8020a5:	66 90                	xchg   %ax,%ax
  8020a7:	66 90                	xchg   %ax,%ax
  8020a9:	66 90                	xchg   %ax,%ax
  8020ab:	66 90                	xchg   %ax,%ax
  8020ad:	66 90                	xchg   %ax,%ax
  8020af:	90                   	nop

008020b0 <__udivdi3>:
  8020b0:	f3 0f 1e fb          	endbr32 
  8020b4:	55                   	push   %ebp
  8020b5:	57                   	push   %edi
  8020b6:	56                   	push   %esi
  8020b7:	53                   	push   %ebx
  8020b8:	83 ec 1c             	sub    $0x1c,%esp
  8020bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8020bf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8020c3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8020c7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8020cb:	85 c0                	test   %eax,%eax
  8020cd:	75 19                	jne    8020e8 <__udivdi3+0x38>
  8020cf:	39 f3                	cmp    %esi,%ebx
  8020d1:	76 4d                	jbe    802120 <__udivdi3+0x70>
  8020d3:	31 ff                	xor    %edi,%edi
  8020d5:	89 e8                	mov    %ebp,%eax
  8020d7:	89 f2                	mov    %esi,%edx
  8020d9:	f7 f3                	div    %ebx
  8020db:	89 fa                	mov    %edi,%edx
  8020dd:	83 c4 1c             	add    $0x1c,%esp
  8020e0:	5b                   	pop    %ebx
  8020e1:	5e                   	pop    %esi
  8020e2:	5f                   	pop    %edi
  8020e3:	5d                   	pop    %ebp
  8020e4:	c3                   	ret    
  8020e5:	8d 76 00             	lea    0x0(%esi),%esi
  8020e8:	39 f0                	cmp    %esi,%eax
  8020ea:	76 14                	jbe    802100 <__udivdi3+0x50>
  8020ec:	31 ff                	xor    %edi,%edi
  8020ee:	31 c0                	xor    %eax,%eax
  8020f0:	89 fa                	mov    %edi,%edx
  8020f2:	83 c4 1c             	add    $0x1c,%esp
  8020f5:	5b                   	pop    %ebx
  8020f6:	5e                   	pop    %esi
  8020f7:	5f                   	pop    %edi
  8020f8:	5d                   	pop    %ebp
  8020f9:	c3                   	ret    
  8020fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802100:	0f bd f8             	bsr    %eax,%edi
  802103:	83 f7 1f             	xor    $0x1f,%edi
  802106:	75 48                	jne    802150 <__udivdi3+0xa0>
  802108:	39 f0                	cmp    %esi,%eax
  80210a:	72 06                	jb     802112 <__udivdi3+0x62>
  80210c:	31 c0                	xor    %eax,%eax
  80210e:	39 eb                	cmp    %ebp,%ebx
  802110:	77 de                	ja     8020f0 <__udivdi3+0x40>
  802112:	b8 01 00 00 00       	mov    $0x1,%eax
  802117:	eb d7                	jmp    8020f0 <__udivdi3+0x40>
  802119:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802120:	89 d9                	mov    %ebx,%ecx
  802122:	85 db                	test   %ebx,%ebx
  802124:	75 0b                	jne    802131 <__udivdi3+0x81>
  802126:	b8 01 00 00 00       	mov    $0x1,%eax
  80212b:	31 d2                	xor    %edx,%edx
  80212d:	f7 f3                	div    %ebx
  80212f:	89 c1                	mov    %eax,%ecx
  802131:	31 d2                	xor    %edx,%edx
  802133:	89 f0                	mov    %esi,%eax
  802135:	f7 f1                	div    %ecx
  802137:	89 c6                	mov    %eax,%esi
  802139:	89 e8                	mov    %ebp,%eax
  80213b:	89 f7                	mov    %esi,%edi
  80213d:	f7 f1                	div    %ecx
  80213f:	89 fa                	mov    %edi,%edx
  802141:	83 c4 1c             	add    $0x1c,%esp
  802144:	5b                   	pop    %ebx
  802145:	5e                   	pop    %esi
  802146:	5f                   	pop    %edi
  802147:	5d                   	pop    %ebp
  802148:	c3                   	ret    
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	89 f9                	mov    %edi,%ecx
  802152:	ba 20 00 00 00       	mov    $0x20,%edx
  802157:	29 fa                	sub    %edi,%edx
  802159:	d3 e0                	shl    %cl,%eax
  80215b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80215f:	89 d1                	mov    %edx,%ecx
  802161:	89 d8                	mov    %ebx,%eax
  802163:	d3 e8                	shr    %cl,%eax
  802165:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802169:	09 c1                	or     %eax,%ecx
  80216b:	89 f0                	mov    %esi,%eax
  80216d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802171:	89 f9                	mov    %edi,%ecx
  802173:	d3 e3                	shl    %cl,%ebx
  802175:	89 d1                	mov    %edx,%ecx
  802177:	d3 e8                	shr    %cl,%eax
  802179:	89 f9                	mov    %edi,%ecx
  80217b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80217f:	89 eb                	mov    %ebp,%ebx
  802181:	d3 e6                	shl    %cl,%esi
  802183:	89 d1                	mov    %edx,%ecx
  802185:	d3 eb                	shr    %cl,%ebx
  802187:	09 f3                	or     %esi,%ebx
  802189:	89 c6                	mov    %eax,%esi
  80218b:	89 f2                	mov    %esi,%edx
  80218d:	89 d8                	mov    %ebx,%eax
  80218f:	f7 74 24 08          	divl   0x8(%esp)
  802193:	89 d6                	mov    %edx,%esi
  802195:	89 c3                	mov    %eax,%ebx
  802197:	f7 64 24 0c          	mull   0xc(%esp)
  80219b:	39 d6                	cmp    %edx,%esi
  80219d:	72 19                	jb     8021b8 <__udivdi3+0x108>
  80219f:	89 f9                	mov    %edi,%ecx
  8021a1:	d3 e5                	shl    %cl,%ebp
  8021a3:	39 c5                	cmp    %eax,%ebp
  8021a5:	73 04                	jae    8021ab <__udivdi3+0xfb>
  8021a7:	39 d6                	cmp    %edx,%esi
  8021a9:	74 0d                	je     8021b8 <__udivdi3+0x108>
  8021ab:	89 d8                	mov    %ebx,%eax
  8021ad:	31 ff                	xor    %edi,%edi
  8021af:	e9 3c ff ff ff       	jmp    8020f0 <__udivdi3+0x40>
  8021b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8021bb:	31 ff                	xor    %edi,%edi
  8021bd:	e9 2e ff ff ff       	jmp    8020f0 <__udivdi3+0x40>
  8021c2:	66 90                	xchg   %ax,%ax
  8021c4:	66 90                	xchg   %ax,%ax
  8021c6:	66 90                	xchg   %ax,%ax
  8021c8:	66 90                	xchg   %ax,%ax
  8021ca:	66 90                	xchg   %ax,%ax
  8021cc:	66 90                	xchg   %ax,%ax
  8021ce:	66 90                	xchg   %ax,%ax

008021d0 <__umoddi3>:
  8021d0:	f3 0f 1e fb          	endbr32 
  8021d4:	55                   	push   %ebp
  8021d5:	57                   	push   %edi
  8021d6:	56                   	push   %esi
  8021d7:	53                   	push   %ebx
  8021d8:	83 ec 1c             	sub    $0x1c,%esp
  8021db:	8b 74 24 30          	mov    0x30(%esp),%esi
  8021df:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8021e3:	8b 7c 24 3c          	mov    0x3c(%esp),%edi
  8021e7:	8b 6c 24 38          	mov    0x38(%esp),%ebp
  8021eb:	89 f0                	mov    %esi,%eax
  8021ed:	89 da                	mov    %ebx,%edx
  8021ef:	85 ff                	test   %edi,%edi
  8021f1:	75 15                	jne    802208 <__umoddi3+0x38>
  8021f3:	39 dd                	cmp    %ebx,%ebp
  8021f5:	76 39                	jbe    802230 <__umoddi3+0x60>
  8021f7:	f7 f5                	div    %ebp
  8021f9:	89 d0                	mov    %edx,%eax
  8021fb:	31 d2                	xor    %edx,%edx
  8021fd:	83 c4 1c             	add    $0x1c,%esp
  802200:	5b                   	pop    %ebx
  802201:	5e                   	pop    %esi
  802202:	5f                   	pop    %edi
  802203:	5d                   	pop    %ebp
  802204:	c3                   	ret    
  802205:	8d 76 00             	lea    0x0(%esi),%esi
  802208:	39 df                	cmp    %ebx,%edi
  80220a:	77 f1                	ja     8021fd <__umoddi3+0x2d>
  80220c:	0f bd cf             	bsr    %edi,%ecx
  80220f:	83 f1 1f             	xor    $0x1f,%ecx
  802212:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  802216:	75 40                	jne    802258 <__umoddi3+0x88>
  802218:	39 df                	cmp    %ebx,%edi
  80221a:	72 04                	jb     802220 <__umoddi3+0x50>
  80221c:	39 f5                	cmp    %esi,%ebp
  80221e:	77 dd                	ja     8021fd <__umoddi3+0x2d>
  802220:	89 da                	mov    %ebx,%edx
  802222:	89 f0                	mov    %esi,%eax
  802224:	29 e8                	sub    %ebp,%eax
  802226:	19 fa                	sbb    %edi,%edx
  802228:	eb d3                	jmp    8021fd <__umoddi3+0x2d>
  80222a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802230:	89 e9                	mov    %ebp,%ecx
  802232:	85 ed                	test   %ebp,%ebp
  802234:	75 0b                	jne    802241 <__umoddi3+0x71>
  802236:	b8 01 00 00 00       	mov    $0x1,%eax
  80223b:	31 d2                	xor    %edx,%edx
  80223d:	f7 f5                	div    %ebp
  80223f:	89 c1                	mov    %eax,%ecx
  802241:	89 d8                	mov    %ebx,%eax
  802243:	31 d2                	xor    %edx,%edx
  802245:	f7 f1                	div    %ecx
  802247:	89 f0                	mov    %esi,%eax
  802249:	f7 f1                	div    %ecx
  80224b:	89 d0                	mov    %edx,%eax
  80224d:	31 d2                	xor    %edx,%edx
  80224f:	eb ac                	jmp    8021fd <__umoddi3+0x2d>
  802251:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802258:	8b 44 24 04          	mov    0x4(%esp),%eax
  80225c:	ba 20 00 00 00       	mov    $0x20,%edx
  802261:	29 c2                	sub    %eax,%edx
  802263:	89 c1                	mov    %eax,%ecx
  802265:	89 e8                	mov    %ebp,%eax
  802267:	d3 e7                	shl    %cl,%edi
  802269:	89 d1                	mov    %edx,%ecx
  80226b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80226f:	d3 e8                	shr    %cl,%eax
  802271:	89 c1                	mov    %eax,%ecx
  802273:	8b 44 24 04          	mov    0x4(%esp),%eax
  802277:	09 f9                	or     %edi,%ecx
  802279:	89 df                	mov    %ebx,%edi
  80227b:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80227f:	89 c1                	mov    %eax,%ecx
  802281:	d3 e5                	shl    %cl,%ebp
  802283:	89 d1                	mov    %edx,%ecx
  802285:	d3 ef                	shr    %cl,%edi
  802287:	89 c1                	mov    %eax,%ecx
  802289:	89 f0                	mov    %esi,%eax
  80228b:	d3 e3                	shl    %cl,%ebx
  80228d:	89 d1                	mov    %edx,%ecx
  80228f:	89 fa                	mov    %edi,%edx
  802291:	d3 e8                	shr    %cl,%eax
  802293:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802298:	09 d8                	or     %ebx,%eax
  80229a:	f7 74 24 08          	divl   0x8(%esp)
  80229e:	89 d3                	mov    %edx,%ebx
  8022a0:	d3 e6                	shl    %cl,%esi
  8022a2:	f7 e5                	mul    %ebp
  8022a4:	89 c7                	mov    %eax,%edi
  8022a6:	89 d1                	mov    %edx,%ecx
  8022a8:	39 d3                	cmp    %edx,%ebx
  8022aa:	72 06                	jb     8022b2 <__umoddi3+0xe2>
  8022ac:	75 0e                	jne    8022bc <__umoddi3+0xec>
  8022ae:	39 c6                	cmp    %eax,%esi
  8022b0:	73 0a                	jae    8022bc <__umoddi3+0xec>
  8022b2:	29 e8                	sub    %ebp,%eax
  8022b4:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8022b8:	89 d1                	mov    %edx,%ecx
  8022ba:	89 c7                	mov    %eax,%edi
  8022bc:	89 f5                	mov    %esi,%ebp
  8022be:	8b 74 24 04          	mov    0x4(%esp),%esi
  8022c2:	29 fd                	sub    %edi,%ebp
  8022c4:	19 cb                	sbb    %ecx,%ebx
  8022c6:	0f b6 4c 24 0c       	movzbl 0xc(%esp),%ecx
  8022cb:	89 d8                	mov    %ebx,%eax
  8022cd:	d3 e0                	shl    %cl,%eax
  8022cf:	89 f1                	mov    %esi,%ecx
  8022d1:	d3 ed                	shr    %cl,%ebp
  8022d3:	d3 eb                	shr    %cl,%ebx
  8022d5:	09 e8                	or     %ebp,%eax
  8022d7:	89 da                	mov    %ebx,%edx
  8022d9:	83 c4 1c             	add    $0x1c,%esp
  8022dc:	5b                   	pop    %ebx
  8022dd:	5e                   	pop    %esi
  8022de:	5f                   	pop    %edi
  8022df:	5d                   	pop    %ebp
  8022e0:	c3                   	ret    
