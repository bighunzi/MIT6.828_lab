
obj/user/badsegment.debug：     文件格式 elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void
umain(int argc, char **argv)
{
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800033:	66 b8 28 00          	mov    $0x28,%ax
  800037:	8e d8                	mov    %eax,%ds
}
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800042:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	//定义在kern/syscall.c中的sys_getenvid()可以获得curenv->env_id。
	//而之前我们知道env_id 0~9位 是在envs数组中的索引。(在inc/env.h中，并且有专门的宏 ENVX(envid) 供调用)
	thisenv = &envs[ENVX(sys_getenvid())];
  800045:	e8 d1 00 00 00       	call   80011b <sys_getenvid>
  80004a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004f:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  800055:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005a:	a3 00 40 80 00       	mov    %eax,0x804000

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005f:	85 db                	test   %ebx,%ebx
  800061:	7e 07                	jle    80006a <libmain+0x30>
		binaryname = argv[0];
  800063:	8b 06                	mov    (%esi),%eax
  800065:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006a:	83 ec 08             	sub    $0x8,%esp
  80006d:	56                   	push   %esi
  80006e:	53                   	push   %ebx
  80006f:	e8 bf ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800074:	e8 0a 00 00 00       	call   800083 <exit>
}
  800079:	83 c4 10             	add    $0x10,%esp
  80007c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80007f:	5b                   	pop    %ebx
  800080:	5e                   	pop    %esi
  800081:	5d                   	pop    %ebp
  800082:	c3                   	ret    

00800083 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800083:	55                   	push   %ebp
  800084:	89 e5                	mov    %esp,%ebp
  800086:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800089:	e8 ee 04 00 00       	call   80057c <close_all>
	sys_env_destroy(0);
  80008e:	83 ec 0c             	sub    $0xc,%esp
  800091:	6a 00                	push   $0x0
  800093:	e8 42 00 00 00       	call   8000da <sys_env_destroy>
}
  800098:	83 c4 10             	add    $0x10,%esp
  80009b:	c9                   	leave  
  80009c:	c3                   	ret    

0080009d <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009d:	55                   	push   %ebp
  80009e:	89 e5                	mov    %esp,%ebp
  8000a0:	57                   	push   %edi
  8000a1:	56                   	push   %esi
  8000a2:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ae:	89 c3                	mov    %eax,%ebx
  8000b0:	89 c7                	mov    %eax,%edi
  8000b2:	89 c6                	mov    %eax,%esi
  8000b4:	cd 30                	int    $0x30
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b6:	5b                   	pop    %ebx
  8000b7:	5e                   	pop    %esi
  8000b8:	5f                   	pop    %edi
  8000b9:	5d                   	pop    %ebp
  8000ba:	c3                   	ret    

008000bb <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	57                   	push   %edi
  8000bf:	56                   	push   %esi
  8000c0:	53                   	push   %ebx
	asm volatile("int %1\n"
  8000c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cb:	89 d1                	mov    %edx,%ecx
  8000cd:	89 d3                	mov    %edx,%ebx
  8000cf:	89 d7                	mov    %edx,%edi
  8000d1:	89 d6                	mov    %edx,%esi
  8000d3:	cd 30                	int    $0x30
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d5:	5b                   	pop    %ebx
  8000d6:	5e                   	pop    %esi
  8000d7:	5f                   	pop    %edi
  8000d8:	5d                   	pop    %ebp
  8000d9:	c3                   	ret    

008000da <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000da:	55                   	push   %ebp
  8000db:	89 e5                	mov    %esp,%ebp
  8000dd:	57                   	push   %edi
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
  8000e0:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8000e3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e8:	8b 55 08             	mov    0x8(%ebp),%edx
  8000eb:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f0:	89 cb                	mov    %ecx,%ebx
  8000f2:	89 cf                	mov    %ecx,%edi
  8000f4:	89 ce                	mov    %ecx,%esi
  8000f6:	cd 30                	int    $0x30
	if(check && ret > 0)
  8000f8:	85 c0                	test   %eax,%eax
  8000fa:	7f 08                	jg     800104 <sys_env_destroy+0x2a>
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8000fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ff:	5b                   	pop    %ebx
  800100:	5e                   	pop    %esi
  800101:	5f                   	pop    %edi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800104:	83 ec 0c             	sub    $0xc,%esp
  800107:	50                   	push   %eax
  800108:	6a 03                	push   $0x3
  80010a:	68 4a 22 80 00       	push   $0x80224a
  80010f:	6a 2a                	push   $0x2a
  800111:	68 67 22 80 00       	push   $0x802267
  800116:	e8 9e 13 00 00       	call   8014b9 <_panic>

0080011b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	57                   	push   %edi
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
	asm volatile("int %1\n"
  800121:	ba 00 00 00 00       	mov    $0x0,%edx
  800126:	b8 02 00 00 00       	mov    $0x2,%eax
  80012b:	89 d1                	mov    %edx,%ecx
  80012d:	89 d3                	mov    %edx,%ebx
  80012f:	89 d7                	mov    %edx,%edi
  800131:	89 d6                	mov    %edx,%esi
  800133:	cd 30                	int    $0x30
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800135:	5b                   	pop    %ebx
  800136:	5e                   	pop    %esi
  800137:	5f                   	pop    %edi
  800138:	5d                   	pop    %ebp
  800139:	c3                   	ret    

0080013a <sys_yield>:

void
sys_yield(void)
{
  80013a:	55                   	push   %ebp
  80013b:	89 e5                	mov    %esp,%ebp
  80013d:	57                   	push   %edi
  80013e:	56                   	push   %esi
  80013f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800140:	ba 00 00 00 00       	mov    $0x0,%edx
  800145:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014a:	89 d1                	mov    %edx,%ecx
  80014c:	89 d3                	mov    %edx,%ebx
  80014e:	89 d7                	mov    %edx,%edi
  800150:	89 d6                	mov    %edx,%esi
  800152:	cd 30                	int    $0x30
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800154:	5b                   	pop    %ebx
  800155:	5e                   	pop    %esi
  800156:	5f                   	pop    %edi
  800157:	5d                   	pop    %ebp
  800158:	c3                   	ret    

00800159 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	57                   	push   %edi
  80015d:	56                   	push   %esi
  80015e:	53                   	push   %ebx
  80015f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800162:	be 00 00 00 00       	mov    $0x0,%esi
  800167:	8b 55 08             	mov    0x8(%ebp),%edx
  80016a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80016d:	b8 04 00 00 00       	mov    $0x4,%eax
  800172:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800175:	89 f7                	mov    %esi,%edi
  800177:	cd 30                	int    $0x30
	if(check && ret > 0)
  800179:	85 c0                	test   %eax,%eax
  80017b:	7f 08                	jg     800185 <sys_page_alloc+0x2c>
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80017d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800180:	5b                   	pop    %ebx
  800181:	5e                   	pop    %esi
  800182:	5f                   	pop    %edi
  800183:	5d                   	pop    %ebp
  800184:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	50                   	push   %eax
  800189:	6a 04                	push   $0x4
  80018b:	68 4a 22 80 00       	push   $0x80224a
  800190:	6a 2a                	push   $0x2a
  800192:	68 67 22 80 00       	push   $0x802267
  800197:	e8 1d 13 00 00       	call   8014b9 <_panic>

0080019c <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	57                   	push   %edi
  8001a0:	56                   	push   %esi
  8001a1:	53                   	push   %ebx
  8001a2:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ab:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b6:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b9:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001bb:	85 c0                	test   %eax,%eax
  8001bd:	7f 08                	jg     8001c7 <sys_page_map+0x2b>
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001c2:	5b                   	pop    %ebx
  8001c3:	5e                   	pop    %esi
  8001c4:	5f                   	pop    %edi
  8001c5:	5d                   	pop    %ebp
  8001c6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c7:	83 ec 0c             	sub    $0xc,%esp
  8001ca:	50                   	push   %eax
  8001cb:	6a 05                	push   $0x5
  8001cd:	68 4a 22 80 00       	push   $0x80224a
  8001d2:	6a 2a                	push   $0x2a
  8001d4:	68 67 22 80 00       	push   $0x802267
  8001d9:	e8 db 12 00 00       	call   8014b9 <_panic>

008001de <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001de:	55                   	push   %ebp
  8001df:	89 e5                	mov    %esp,%ebp
  8001e1:	57                   	push   %edi
  8001e2:	56                   	push   %esi
  8001e3:	53                   	push   %ebx
  8001e4:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8001e7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f2:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f7:	89 df                	mov    %ebx,%edi
  8001f9:	89 de                	mov    %ebx,%esi
  8001fb:	cd 30                	int    $0x30
	if(check && ret > 0)
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	7f 08                	jg     800209 <sys_page_unmap+0x2b>
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800201:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800204:	5b                   	pop    %ebx
  800205:	5e                   	pop    %esi
  800206:	5f                   	pop    %edi
  800207:	5d                   	pop    %ebp
  800208:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800209:	83 ec 0c             	sub    $0xc,%esp
  80020c:	50                   	push   %eax
  80020d:	6a 06                	push   $0x6
  80020f:	68 4a 22 80 00       	push   $0x80224a
  800214:	6a 2a                	push   $0x2a
  800216:	68 67 22 80 00       	push   $0x802267
  80021b:	e8 99 12 00 00       	call   8014b9 <_panic>

00800220 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	57                   	push   %edi
  800224:	56                   	push   %esi
  800225:	53                   	push   %ebx
  800226:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800229:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022e:	8b 55 08             	mov    0x8(%ebp),%edx
  800231:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800234:	b8 08 00 00 00       	mov    $0x8,%eax
  800239:	89 df                	mov    %ebx,%edi
  80023b:	89 de                	mov    %ebx,%esi
  80023d:	cd 30                	int    $0x30
	if(check && ret > 0)
  80023f:	85 c0                	test   %eax,%eax
  800241:	7f 08                	jg     80024b <sys_env_set_status+0x2b>
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800243:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800246:	5b                   	pop    %ebx
  800247:	5e                   	pop    %esi
  800248:	5f                   	pop    %edi
  800249:	5d                   	pop    %ebp
  80024a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80024b:	83 ec 0c             	sub    $0xc,%esp
  80024e:	50                   	push   %eax
  80024f:	6a 08                	push   $0x8
  800251:	68 4a 22 80 00       	push   $0x80224a
  800256:	6a 2a                	push   $0x2a
  800258:	68 67 22 80 00       	push   $0x802267
  80025d:	e8 57 12 00 00       	call   8014b9 <_panic>

00800262 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800262:	55                   	push   %ebp
  800263:	89 e5                	mov    %esp,%ebp
  800265:	57                   	push   %edi
  800266:	56                   	push   %esi
  800267:	53                   	push   %ebx
  800268:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  80026b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800270:	8b 55 08             	mov    0x8(%ebp),%edx
  800273:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800276:	b8 09 00 00 00       	mov    $0x9,%eax
  80027b:	89 df                	mov    %ebx,%edi
  80027d:	89 de                	mov    %ebx,%esi
  80027f:	cd 30                	int    $0x30
	if(check && ret > 0)
  800281:	85 c0                	test   %eax,%eax
  800283:	7f 08                	jg     80028d <sys_env_set_trapframe+0x2b>
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800285:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800288:	5b                   	pop    %ebx
  800289:	5e                   	pop    %esi
  80028a:	5f                   	pop    %edi
  80028b:	5d                   	pop    %ebp
  80028c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80028d:	83 ec 0c             	sub    $0xc,%esp
  800290:	50                   	push   %eax
  800291:	6a 09                	push   $0x9
  800293:	68 4a 22 80 00       	push   $0x80224a
  800298:	6a 2a                	push   $0x2a
  80029a:	68 67 22 80 00       	push   $0x802267
  80029f:	e8 15 12 00 00       	call   8014b9 <_panic>

008002a4 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a4:	55                   	push   %ebp
  8002a5:	89 e5                	mov    %esp,%ebp
  8002a7:	57                   	push   %edi
  8002a8:	56                   	push   %esi
  8002a9:	53                   	push   %ebx
  8002aa:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  8002ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002bd:	89 df                	mov    %ebx,%edi
  8002bf:	89 de                	mov    %ebx,%esi
  8002c1:	cd 30                	int    $0x30
	if(check && ret > 0)
  8002c3:	85 c0                	test   %eax,%eax
  8002c5:	7f 08                	jg     8002cf <sys_env_set_pgfault_upcall+0x2b>
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002ca:	5b                   	pop    %ebx
  8002cb:	5e                   	pop    %esi
  8002cc:	5f                   	pop    %edi
  8002cd:	5d                   	pop    %ebp
  8002ce:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cf:	83 ec 0c             	sub    $0xc,%esp
  8002d2:	50                   	push   %eax
  8002d3:	6a 0a                	push   $0xa
  8002d5:	68 4a 22 80 00       	push   $0x80224a
  8002da:	6a 2a                	push   $0x2a
  8002dc:	68 67 22 80 00       	push   $0x802267
  8002e1:	e8 d3 11 00 00       	call   8014b9 <_panic>

008002e6 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	57                   	push   %edi
  8002ea:	56                   	push   %esi
  8002eb:	53                   	push   %ebx
	asm volatile("int %1\n"
  8002ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f7:	be 00 00 00 00       	mov    $0x0,%esi
  8002fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ff:	8b 7d 14             	mov    0x14(%ebp),%edi
  800302:	cd 30                	int    $0x30
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800304:	5b                   	pop    %ebx
  800305:	5e                   	pop    %esi
  800306:	5f                   	pop    %edi
  800307:	5d                   	pop    %ebp
  800308:	c3                   	ret    

00800309 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800309:	55                   	push   %ebp
  80030a:	89 e5                	mov    %esp,%ebp
  80030c:	57                   	push   %edi
  80030d:	56                   	push   %esi
  80030e:	53                   	push   %ebx
  80030f:	83 ec 0c             	sub    $0xc,%esp
	asm volatile("int %1\n"
  800312:	b9 00 00 00 00       	mov    $0x0,%ecx
  800317:	8b 55 08             	mov    0x8(%ebp),%edx
  80031a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031f:	89 cb                	mov    %ecx,%ebx
  800321:	89 cf                	mov    %ecx,%edi
  800323:	89 ce                	mov    %ecx,%esi
  800325:	cd 30                	int    $0x30
	if(check && ret > 0)
  800327:	85 c0                	test   %eax,%eax
  800329:	7f 08                	jg     800333 <sys_ipc_recv+0x2a>
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80032b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80032e:	5b                   	pop    %ebx
  80032f:	5e                   	pop    %esi
  800330:	5f                   	pop    %edi
  800331:	5d                   	pop    %ebp
  800332:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800333:	83 ec 0c             	sub    $0xc,%esp
  800336:	50                   	push   %eax
  800337:	6a 0d                	push   $0xd
  800339:	68 4a 22 80 00       	push   $0x80224a
  80033e:	6a 2a                	push   $0x2a
  800340:	68 67 22 80 00       	push   $0x802267
  800345:	e8 6f 11 00 00       	call   8014b9 <_panic>

0080034a <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	57                   	push   %edi
  80034e:	56                   	push   %esi
  80034f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800350:	ba 00 00 00 00       	mov    $0x0,%edx
  800355:	b8 0e 00 00 00       	mov    $0xe,%eax
  80035a:	89 d1                	mov    %edx,%ecx
  80035c:	89 d3                	mov    %edx,%ebx
  80035e:	89 d7                	mov    %edx,%edi
  800360:	89 d6                	mov    %edx,%esi
  800362:	cd 30                	int    $0x30
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800364:	5b                   	pop    %ebx
  800365:	5e                   	pop    %esi
  800366:	5f                   	pop    %edi
  800367:	5d                   	pop    %ebp
  800368:	c3                   	ret    

00800369 <sys_e1000_try_send>:

int
sys_e1000_try_send(void *buf, size_t len)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	57                   	push   %edi
  80036d:	56                   	push   %esi
  80036e:	53                   	push   %ebx
	asm volatile("int %1\n"
  80036f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800374:	8b 55 08             	mov    0x8(%ebp),%edx
  800377:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80037a:	b8 0f 00 00 00       	mov    $0xf,%eax
  80037f:	89 df                	mov    %ebx,%edi
  800381:	89 de                	mov    %ebx,%esi
  800383:	cd 30                	int    $0x30
    return syscall(SYS_e1000_try_send, 0, (uint32_t)buf, len, 0, 0, 0);
}
  800385:	5b                   	pop    %ebx
  800386:	5e                   	pop    %esi
  800387:	5f                   	pop    %edi
  800388:	5d                   	pop    %ebp
  800389:	c3                   	ret    

0080038a <sys_e1000_recv>:

int
sys_e1000_recv(void *dstva, size_t *len)
{
  80038a:	55                   	push   %ebp
  80038b:	89 e5                	mov    %esp,%ebp
  80038d:	57                   	push   %edi
  80038e:	56                   	push   %esi
  80038f:	53                   	push   %ebx
	asm volatile("int %1\n"
  800390:	bb 00 00 00 00       	mov    $0x0,%ebx
  800395:	8b 55 08             	mov    0x8(%ebp),%edx
  800398:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80039b:	b8 10 00 00 00       	mov    $0x10,%eax
  8003a0:	89 df                	mov    %ebx,%edi
  8003a2:	89 de                	mov    %ebx,%esi
  8003a4:	cd 30                	int    $0x30
    return syscall(SYS_e1000_recv, 0, (uint32_t) dstva, (uint32_t) len, 0, 0, 0);
}
  8003a6:	5b                   	pop    %ebx
  8003a7:	5e                   	pop    %esi
  8003a8:	5f                   	pop    %edi
  8003a9:	5d                   	pop    %ebp
  8003aa:	c3                   	ret    

008003ab <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b1:	05 00 00 00 30       	add    $0x30000000,%eax
  8003b6:	c1 e8 0c             	shr    $0xc,%eax
}
  8003b9:	5d                   	pop    %ebp
  8003ba:	c3                   	ret    

008003bb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8003be:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c1:	05 00 00 00 30       	add    $0x30000000,%eax
	return INDEX2DATA(fd2num(fd));
  8003c6:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003cb:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003d0:	5d                   	pop    %ebp
  8003d1:	c3                   	ret    

008003d2 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003d2:	55                   	push   %ebp
  8003d3:	89 e5                	mov    %esp,%ebp
  8003d5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003da:	89 c2                	mov    %eax,%edx
  8003dc:	c1 ea 16             	shr    $0x16,%edx
  8003df:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e6:	f6 c2 01             	test   $0x1,%dl
  8003e9:	74 29                	je     800414 <fd_alloc+0x42>
  8003eb:	89 c2                	mov    %eax,%edx
  8003ed:	c1 ea 0c             	shr    $0xc,%edx
  8003f0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f7:	f6 c2 01             	test   $0x1,%dl
  8003fa:	74 18                	je     800414 <fd_alloc+0x42>
	for (i = 0; i < MAXFD; i++) {
  8003fc:	05 00 10 00 00       	add    $0x1000,%eax
  800401:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800406:	75 d2                	jne    8003da <fd_alloc+0x8>
  800408:	b8 00 00 00 00       	mov    $0x0,%eax
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
	return -E_MAX_OPEN;
  80040d:	b9 f6 ff ff ff       	mov    $0xfffffff6,%ecx
  800412:	eb 05                	jmp    800419 <fd_alloc+0x47>
			return 0;
  800414:	b9 00 00 00 00       	mov    $0x0,%ecx
			*fd_store = fd;
  800419:	8b 55 08             	mov    0x8(%ebp),%edx
  80041c:	89 02                	mov    %eax,(%edx)
}
  80041e:	89 c8                	mov    %ecx,%eax
  800420:	5d                   	pop    %ebp
  800421:	c3                   	ret    

00800422 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800422:	55                   	push   %ebp
  800423:	89 e5                	mov    %esp,%ebp
  800425:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800428:	83 f8 1f             	cmp    $0x1f,%eax
  80042b:	77 30                	ja     80045d <fd_lookup+0x3b>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80042d:	c1 e0 0c             	shl    $0xc,%eax
  800430:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800435:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80043b:	f6 c2 01             	test   $0x1,%dl
  80043e:	74 24                	je     800464 <fd_lookup+0x42>
  800440:	89 c2                	mov    %eax,%edx
  800442:	c1 ea 0c             	shr    $0xc,%edx
  800445:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80044c:	f6 c2 01             	test   $0x1,%dl
  80044f:	74 1a                	je     80046b <fd_lookup+0x49>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800451:	8b 55 0c             	mov    0xc(%ebp),%edx
  800454:	89 02                	mov    %eax,(%edx)
	return 0;
  800456:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80045b:	5d                   	pop    %ebp
  80045c:	c3                   	ret    
		return -E_INVAL;
  80045d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800462:	eb f7                	jmp    80045b <fd_lookup+0x39>
		return -E_INVAL;
  800464:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800469:	eb f0                	jmp    80045b <fd_lookup+0x39>
  80046b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800470:	eb e9                	jmp    80045b <fd_lookup+0x39>

00800472 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800472:	55                   	push   %ebp
  800473:	89 e5                	mov    %esp,%ebp
  800475:	53                   	push   %ebx
  800476:	83 ec 04             	sub    $0x4,%esp
  800479:	8b 55 08             	mov    0x8(%ebp),%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80047c:	b8 00 00 00 00       	mov    $0x0,%eax
  800481:	bb 04 30 80 00       	mov    $0x803004,%ebx
		if (devtab[i]->dev_id == dev_id) {
  800486:	39 13                	cmp    %edx,(%ebx)
  800488:	74 37                	je     8004c1 <dev_lookup+0x4f>
	for (i = 0; devtab[i]; i++)
  80048a:	83 c0 01             	add    $0x1,%eax
  80048d:	8b 1c 85 f4 22 80 00 	mov    0x8022f4(,%eax,4),%ebx
  800494:	85 db                	test   %ebx,%ebx
  800496:	75 ee                	jne    800486 <dev_lookup+0x14>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800498:	a1 00 40 80 00       	mov    0x804000,%eax
  80049d:	8b 40 58             	mov    0x58(%eax),%eax
  8004a0:	83 ec 04             	sub    $0x4,%esp
  8004a3:	52                   	push   %edx
  8004a4:	50                   	push   %eax
  8004a5:	68 78 22 80 00       	push   $0x802278
  8004aa:	e8 e5 10 00 00       	call   801594 <cprintf>
	*dev = 0;
	return -E_INVAL;
  8004af:	83 c4 10             	add    $0x10,%esp
  8004b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			*dev = devtab[i];
  8004b7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ba:	89 1a                	mov    %ebx,(%edx)
}
  8004bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004bf:	c9                   	leave  
  8004c0:	c3                   	ret    
			return 0;
  8004c1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004c6:	eb ef                	jmp    8004b7 <dev_lookup+0x45>

008004c8 <fd_close>:
{
  8004c8:	55                   	push   %ebp
  8004c9:	89 e5                	mov    %esp,%ebp
  8004cb:	57                   	push   %edi
  8004cc:	56                   	push   %esi
  8004cd:	53                   	push   %ebx
  8004ce:	83 ec 24             	sub    $0x24,%esp
  8004d1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d4:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004d7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8004da:	50                   	push   %eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8004db:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004e1:	c1 e8 0c             	shr    $0xc,%eax
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004e4:	50                   	push   %eax
  8004e5:	e8 38 ff ff ff       	call   800422 <fd_lookup>
  8004ea:	89 c3                	mov    %eax,%ebx
  8004ec:	83 c4 10             	add    $0x10,%esp
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	78 05                	js     8004f8 <fd_close+0x30>
	    || fd != fd2)
  8004f3:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8004f6:	74 16                	je     80050e <fd_close+0x46>
		return (must_exist ? r : 0);
  8004f8:	89 f8                	mov    %edi,%eax
  8004fa:	84 c0                	test   %al,%al
  8004fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800501:	0f 44 d8             	cmove  %eax,%ebx
}
  800504:	89 d8                	mov    %ebx,%eax
  800506:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800509:	5b                   	pop    %ebx
  80050a:	5e                   	pop    %esi
  80050b:	5f                   	pop    %edi
  80050c:	5d                   	pop    %ebp
  80050d:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80050e:	83 ec 08             	sub    $0x8,%esp
  800511:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800514:	50                   	push   %eax
  800515:	ff 36                	push   (%esi)
  800517:	e8 56 ff ff ff       	call   800472 <dev_lookup>
  80051c:	89 c3                	mov    %eax,%ebx
  80051e:	83 c4 10             	add    $0x10,%esp
  800521:	85 c0                	test   %eax,%eax
  800523:	78 1a                	js     80053f <fd_close+0x77>
		if (dev->dev_close)
  800525:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800528:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80052b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800530:	85 c0                	test   %eax,%eax
  800532:	74 0b                	je     80053f <fd_close+0x77>
			r = (*dev->dev_close)(fd);
  800534:	83 ec 0c             	sub    $0xc,%esp
  800537:	56                   	push   %esi
  800538:	ff d0                	call   *%eax
  80053a:	89 c3                	mov    %eax,%ebx
  80053c:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	56                   	push   %esi
  800543:	6a 00                	push   $0x0
  800545:	e8 94 fc ff ff       	call   8001de <sys_page_unmap>
	return r;
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	eb b5                	jmp    800504 <fd_close+0x3c>

0080054f <close>:

int
close(int fdnum)
{
  80054f:	55                   	push   %ebp
  800550:	89 e5                	mov    %esp,%ebp
  800552:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800555:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800558:	50                   	push   %eax
  800559:	ff 75 08             	push   0x8(%ebp)
  80055c:	e8 c1 fe ff ff       	call   800422 <fd_lookup>
  800561:	83 c4 10             	add    $0x10,%esp
  800564:	85 c0                	test   %eax,%eax
  800566:	79 02                	jns    80056a <close+0x1b>
		return r;
	else
		return fd_close(fd, 1);
}
  800568:	c9                   	leave  
  800569:	c3                   	ret    
		return fd_close(fd, 1);
  80056a:	83 ec 08             	sub    $0x8,%esp
  80056d:	6a 01                	push   $0x1
  80056f:	ff 75 f4             	push   -0xc(%ebp)
  800572:	e8 51 ff ff ff       	call   8004c8 <fd_close>
  800577:	83 c4 10             	add    $0x10,%esp
  80057a:	eb ec                	jmp    800568 <close+0x19>

0080057c <close_all>:

void
close_all(void)
{
  80057c:	55                   	push   %ebp
  80057d:	89 e5                	mov    %esp,%ebp
  80057f:	53                   	push   %ebx
  800580:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800583:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800588:	83 ec 0c             	sub    $0xc,%esp
  80058b:	53                   	push   %ebx
  80058c:	e8 be ff ff ff       	call   80054f <close>
	for (i = 0; i < MAXFD; i++)
  800591:	83 c3 01             	add    $0x1,%ebx
  800594:	83 c4 10             	add    $0x10,%esp
  800597:	83 fb 20             	cmp    $0x20,%ebx
  80059a:	75 ec                	jne    800588 <close_all+0xc>
}
  80059c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80059f:	c9                   	leave  
  8005a0:	c3                   	ret    

008005a1 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8005a1:	55                   	push   %ebp
  8005a2:	89 e5                	mov    %esp,%ebp
  8005a4:	57                   	push   %edi
  8005a5:	56                   	push   %esi
  8005a6:	53                   	push   %ebx
  8005a7:	83 ec 34             	sub    $0x34,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8005aa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8005ad:	50                   	push   %eax
  8005ae:	ff 75 08             	push   0x8(%ebp)
  8005b1:	e8 6c fe ff ff       	call   800422 <fd_lookup>
  8005b6:	89 c3                	mov    %eax,%ebx
  8005b8:	83 c4 10             	add    $0x10,%esp
  8005bb:	85 c0                	test   %eax,%eax
  8005bd:	78 7f                	js     80063e <dup+0x9d>
		return r;
	close(newfdnum);
  8005bf:	83 ec 0c             	sub    $0xc,%esp
  8005c2:	ff 75 0c             	push   0xc(%ebp)
  8005c5:	e8 85 ff ff ff       	call   80054f <close>

	newfd = INDEX2FD(newfdnum);
  8005ca:	8b 75 0c             	mov    0xc(%ebp),%esi
  8005cd:	c1 e6 0c             	shl    $0xc,%esi
  8005d0:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8005d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005d9:	89 3c 24             	mov    %edi,(%esp)
  8005dc:	e8 da fd ff ff       	call   8003bb <fd2data>
  8005e1:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8005e3:	89 34 24             	mov    %esi,(%esp)
  8005e6:	e8 d0 fd ff ff       	call   8003bb <fd2data>
  8005eb:	83 c4 10             	add    $0x10,%esp
  8005ee:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005f1:	89 d8                	mov    %ebx,%eax
  8005f3:	c1 e8 16             	shr    $0x16,%eax
  8005f6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005fd:	a8 01                	test   $0x1,%al
  8005ff:	74 11                	je     800612 <dup+0x71>
  800601:	89 d8                	mov    %ebx,%eax
  800603:	c1 e8 0c             	shr    $0xc,%eax
  800606:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80060d:	f6 c2 01             	test   $0x1,%dl
  800610:	75 36                	jne    800648 <dup+0xa7>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800612:	89 f8                	mov    %edi,%eax
  800614:	c1 e8 0c             	shr    $0xc,%eax
  800617:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80061e:	83 ec 0c             	sub    $0xc,%esp
  800621:	25 07 0e 00 00       	and    $0xe07,%eax
  800626:	50                   	push   %eax
  800627:	56                   	push   %esi
  800628:	6a 00                	push   $0x0
  80062a:	57                   	push   %edi
  80062b:	6a 00                	push   $0x0
  80062d:	e8 6a fb ff ff       	call   80019c <sys_page_map>
  800632:	89 c3                	mov    %eax,%ebx
  800634:	83 c4 20             	add    $0x20,%esp
  800637:	85 c0                	test   %eax,%eax
  800639:	78 33                	js     80066e <dup+0xcd>
		goto err;

	return newfdnum;
  80063b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80063e:	89 d8                	mov    %ebx,%eax
  800640:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800643:	5b                   	pop    %ebx
  800644:	5e                   	pop    %esi
  800645:	5f                   	pop    %edi
  800646:	5d                   	pop    %ebp
  800647:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800648:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80064f:	83 ec 0c             	sub    $0xc,%esp
  800652:	25 07 0e 00 00       	and    $0xe07,%eax
  800657:	50                   	push   %eax
  800658:	ff 75 d4             	push   -0x2c(%ebp)
  80065b:	6a 00                	push   $0x0
  80065d:	53                   	push   %ebx
  80065e:	6a 00                	push   $0x0
  800660:	e8 37 fb ff ff       	call   80019c <sys_page_map>
  800665:	89 c3                	mov    %eax,%ebx
  800667:	83 c4 20             	add    $0x20,%esp
  80066a:	85 c0                	test   %eax,%eax
  80066c:	79 a4                	jns    800612 <dup+0x71>
	sys_page_unmap(0, newfd);
  80066e:	83 ec 08             	sub    $0x8,%esp
  800671:	56                   	push   %esi
  800672:	6a 00                	push   $0x0
  800674:	e8 65 fb ff ff       	call   8001de <sys_page_unmap>
	sys_page_unmap(0, nva);
  800679:	83 c4 08             	add    $0x8,%esp
  80067c:	ff 75 d4             	push   -0x2c(%ebp)
  80067f:	6a 00                	push   $0x0
  800681:	e8 58 fb ff ff       	call   8001de <sys_page_unmap>
	return r;
  800686:	83 c4 10             	add    $0x10,%esp
  800689:	eb b3                	jmp    80063e <dup+0x9d>

0080068b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80068b:	55                   	push   %ebp
  80068c:	89 e5                	mov    %esp,%ebp
  80068e:	56                   	push   %esi
  80068f:	53                   	push   %ebx
  800690:	83 ec 18             	sub    $0x18,%esp
  800693:	8b 75 08             	mov    0x8(%ebp),%esi
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800696:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800699:	50                   	push   %eax
  80069a:	56                   	push   %esi
  80069b:	e8 82 fd ff ff       	call   800422 <fd_lookup>
  8006a0:	83 c4 10             	add    $0x10,%esp
  8006a3:	85 c0                	test   %eax,%eax
  8006a5:	78 3c                	js     8006e3 <read+0x58>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a7:	8b 5d f0             	mov    -0x10(%ebp),%ebx
  8006aa:	83 ec 08             	sub    $0x8,%esp
  8006ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006b0:	50                   	push   %eax
  8006b1:	ff 33                	push   (%ebx)
  8006b3:	e8 ba fd ff ff       	call   800472 <dev_lookup>
  8006b8:	83 c4 10             	add    $0x10,%esp
  8006bb:	85 c0                	test   %eax,%eax
  8006bd:	78 24                	js     8006e3 <read+0x58>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006bf:	8b 43 08             	mov    0x8(%ebx),%eax
  8006c2:	83 e0 03             	and    $0x3,%eax
  8006c5:	83 f8 01             	cmp    $0x1,%eax
  8006c8:	74 20                	je     8006ea <read+0x5f>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8006ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006cd:	8b 40 08             	mov    0x8(%eax),%eax
  8006d0:	85 c0                	test   %eax,%eax
  8006d2:	74 37                	je     80070b <read+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006d4:	83 ec 04             	sub    $0x4,%esp
  8006d7:	ff 75 10             	push   0x10(%ebp)
  8006da:	ff 75 0c             	push   0xc(%ebp)
  8006dd:	53                   	push   %ebx
  8006de:	ff d0                	call   *%eax
  8006e0:	83 c4 10             	add    $0x10,%esp
}
  8006e3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006e6:	5b                   	pop    %ebx
  8006e7:	5e                   	pop    %esi
  8006e8:	5d                   	pop    %ebp
  8006e9:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006ea:	a1 00 40 80 00       	mov    0x804000,%eax
  8006ef:	8b 40 58             	mov    0x58(%eax),%eax
  8006f2:	83 ec 04             	sub    $0x4,%esp
  8006f5:	56                   	push   %esi
  8006f6:	50                   	push   %eax
  8006f7:	68 b9 22 80 00       	push   $0x8022b9
  8006fc:	e8 93 0e 00 00       	call   801594 <cprintf>
		return -E_INVAL;
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800709:	eb d8                	jmp    8006e3 <read+0x58>
		return -E_NOT_SUPP;
  80070b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800710:	eb d1                	jmp    8006e3 <read+0x58>

00800712 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800712:	55                   	push   %ebp
  800713:	89 e5                	mov    %esp,%ebp
  800715:	57                   	push   %edi
  800716:	56                   	push   %esi
  800717:	53                   	push   %ebx
  800718:	83 ec 0c             	sub    $0xc,%esp
  80071b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80071e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800721:	bb 00 00 00 00       	mov    $0x0,%ebx
  800726:	eb 02                	jmp    80072a <readn+0x18>
  800728:	01 c3                	add    %eax,%ebx
  80072a:	39 f3                	cmp    %esi,%ebx
  80072c:	73 21                	jae    80074f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80072e:	83 ec 04             	sub    $0x4,%esp
  800731:	89 f0                	mov    %esi,%eax
  800733:	29 d8                	sub    %ebx,%eax
  800735:	50                   	push   %eax
  800736:	89 d8                	mov    %ebx,%eax
  800738:	03 45 0c             	add    0xc(%ebp),%eax
  80073b:	50                   	push   %eax
  80073c:	57                   	push   %edi
  80073d:	e8 49 ff ff ff       	call   80068b <read>
		if (m < 0)
  800742:	83 c4 10             	add    $0x10,%esp
  800745:	85 c0                	test   %eax,%eax
  800747:	78 04                	js     80074d <readn+0x3b>
			return m;
		if (m == 0)
  800749:	75 dd                	jne    800728 <readn+0x16>
  80074b:	eb 02                	jmp    80074f <readn+0x3d>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80074d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80074f:	89 d8                	mov    %ebx,%eax
  800751:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800754:	5b                   	pop    %ebx
  800755:	5e                   	pop    %esi
  800756:	5f                   	pop    %edi
  800757:	5d                   	pop    %ebp
  800758:	c3                   	ret    

00800759 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	56                   	push   %esi
  80075d:	53                   	push   %ebx
  80075e:	83 ec 18             	sub    $0x18,%esp
  800761:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800764:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800767:	50                   	push   %eax
  800768:	53                   	push   %ebx
  800769:	e8 b4 fc ff ff       	call   800422 <fd_lookup>
  80076e:	83 c4 10             	add    $0x10,%esp
  800771:	85 c0                	test   %eax,%eax
  800773:	78 37                	js     8007ac <write+0x53>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800775:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800778:	83 ec 08             	sub    $0x8,%esp
  80077b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80077e:	50                   	push   %eax
  80077f:	ff 36                	push   (%esi)
  800781:	e8 ec fc ff ff       	call   800472 <dev_lookup>
  800786:	83 c4 10             	add    $0x10,%esp
  800789:	85 c0                	test   %eax,%eax
  80078b:	78 1f                	js     8007ac <write+0x53>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80078d:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  800791:	74 20                	je     8007b3 <write+0x5a>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800793:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800796:	8b 40 0c             	mov    0xc(%eax),%eax
  800799:	85 c0                	test   %eax,%eax
  80079b:	74 37                	je     8007d4 <write+0x7b>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80079d:	83 ec 04             	sub    $0x4,%esp
  8007a0:	ff 75 10             	push   0x10(%ebp)
  8007a3:	ff 75 0c             	push   0xc(%ebp)
  8007a6:	56                   	push   %esi
  8007a7:	ff d0                	call   *%eax
  8007a9:	83 c4 10             	add    $0x10,%esp
}
  8007ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8007af:	5b                   	pop    %ebx
  8007b0:	5e                   	pop    %esi
  8007b1:	5d                   	pop    %ebp
  8007b2:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8007b3:	a1 00 40 80 00       	mov    0x804000,%eax
  8007b8:	8b 40 58             	mov    0x58(%eax),%eax
  8007bb:	83 ec 04             	sub    $0x4,%esp
  8007be:	53                   	push   %ebx
  8007bf:	50                   	push   %eax
  8007c0:	68 d5 22 80 00       	push   $0x8022d5
  8007c5:	e8 ca 0d 00 00       	call   801594 <cprintf>
		return -E_INVAL;
  8007ca:	83 c4 10             	add    $0x10,%esp
  8007cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d2:	eb d8                	jmp    8007ac <write+0x53>
		return -E_NOT_SUPP;
  8007d4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8007d9:	eb d1                	jmp    8007ac <write+0x53>

008007db <seek>:

int
seek(int fdnum, off_t offset)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e4:	50                   	push   %eax
  8007e5:	ff 75 08             	push   0x8(%ebp)
  8007e8:	e8 35 fc ff ff       	call   800422 <fd_lookup>
  8007ed:	83 c4 10             	add    $0x10,%esp
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	78 0e                	js     800802 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007fa:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800802:	c9                   	leave  
  800803:	c3                   	ret    

00800804 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	56                   	push   %esi
  800808:	53                   	push   %ebx
  800809:	83 ec 18             	sub    $0x18,%esp
  80080c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80080f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800812:	50                   	push   %eax
  800813:	53                   	push   %ebx
  800814:	e8 09 fc ff ff       	call   800422 <fd_lookup>
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	85 c0                	test   %eax,%eax
  80081e:	78 34                	js     800854 <ftruncate+0x50>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800820:	8b 75 f0             	mov    -0x10(%ebp),%esi
  800823:	83 ec 08             	sub    $0x8,%esp
  800826:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800829:	50                   	push   %eax
  80082a:	ff 36                	push   (%esi)
  80082c:	e8 41 fc ff ff       	call   800472 <dev_lookup>
  800831:	83 c4 10             	add    $0x10,%esp
  800834:	85 c0                	test   %eax,%eax
  800836:	78 1c                	js     800854 <ftruncate+0x50>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800838:	f6 46 08 03          	testb  $0x3,0x8(%esi)
  80083c:	74 1d                	je     80085b <ftruncate+0x57>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80083e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800841:	8b 40 18             	mov    0x18(%eax),%eax
  800844:	85 c0                	test   %eax,%eax
  800846:	74 34                	je     80087c <ftruncate+0x78>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800848:	83 ec 08             	sub    $0x8,%esp
  80084b:	ff 75 0c             	push   0xc(%ebp)
  80084e:	56                   	push   %esi
  80084f:	ff d0                	call   *%eax
  800851:	83 c4 10             	add    $0x10,%esp
}
  800854:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800857:	5b                   	pop    %ebx
  800858:	5e                   	pop    %esi
  800859:	5d                   	pop    %ebp
  80085a:	c3                   	ret    
			thisenv->env_id, fdnum);
  80085b:	a1 00 40 80 00       	mov    0x804000,%eax
  800860:	8b 40 58             	mov    0x58(%eax),%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800863:	83 ec 04             	sub    $0x4,%esp
  800866:	53                   	push   %ebx
  800867:	50                   	push   %eax
  800868:	68 98 22 80 00       	push   $0x802298
  80086d:	e8 22 0d 00 00       	call   801594 <cprintf>
		return -E_INVAL;
  800872:	83 c4 10             	add    $0x10,%esp
  800875:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80087a:	eb d8                	jmp    800854 <ftruncate+0x50>
		return -E_NOT_SUPP;
  80087c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800881:	eb d1                	jmp    800854 <ftruncate+0x50>

00800883 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800883:	55                   	push   %ebp
  800884:	89 e5                	mov    %esp,%ebp
  800886:	56                   	push   %esi
  800887:	53                   	push   %ebx
  800888:	83 ec 18             	sub    $0x18,%esp
  80088b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80088e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800891:	50                   	push   %eax
  800892:	ff 75 08             	push   0x8(%ebp)
  800895:	e8 88 fb ff ff       	call   800422 <fd_lookup>
  80089a:	83 c4 10             	add    $0x10,%esp
  80089d:	85 c0                	test   %eax,%eax
  80089f:	78 49                	js     8008ea <fstat+0x67>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a1:	8b 75 f0             	mov    -0x10(%ebp),%esi
  8008a4:	83 ec 08             	sub    $0x8,%esp
  8008a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008aa:	50                   	push   %eax
  8008ab:	ff 36                	push   (%esi)
  8008ad:	e8 c0 fb ff ff       	call   800472 <dev_lookup>
  8008b2:	83 c4 10             	add    $0x10,%esp
  8008b5:	85 c0                	test   %eax,%eax
  8008b7:	78 31                	js     8008ea <fstat+0x67>
		return r;
	if (!dev->dev_stat)
  8008b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008bc:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c0:	74 2f                	je     8008f1 <fstat+0x6e>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008c2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008c5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008cc:	00 00 00 
	stat->st_isdir = 0;
  8008cf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008d6:	00 00 00 
	stat->st_dev = dev;
  8008d9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008df:	83 ec 08             	sub    $0x8,%esp
  8008e2:	53                   	push   %ebx
  8008e3:	56                   	push   %esi
  8008e4:	ff 50 14             	call   *0x14(%eax)
  8008e7:	83 c4 10             	add    $0x10,%esp
}
  8008ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ed:	5b                   	pop    %ebx
  8008ee:	5e                   	pop    %esi
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    
		return -E_NOT_SUPP;
  8008f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008f6:	eb f2                	jmp    8008ea <fstat+0x67>

008008f8 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008f8:	55                   	push   %ebp
  8008f9:	89 e5                	mov    %esp,%ebp
  8008fb:	56                   	push   %esi
  8008fc:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008fd:	83 ec 08             	sub    $0x8,%esp
  800900:	6a 00                	push   $0x0
  800902:	ff 75 08             	push   0x8(%ebp)
  800905:	e8 e4 01 00 00       	call   800aee <open>
  80090a:	89 c3                	mov    %eax,%ebx
  80090c:	83 c4 10             	add    $0x10,%esp
  80090f:	85 c0                	test   %eax,%eax
  800911:	78 1b                	js     80092e <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800913:	83 ec 08             	sub    $0x8,%esp
  800916:	ff 75 0c             	push   0xc(%ebp)
  800919:	50                   	push   %eax
  80091a:	e8 64 ff ff ff       	call   800883 <fstat>
  80091f:	89 c6                	mov    %eax,%esi
	close(fd);
  800921:	89 1c 24             	mov    %ebx,(%esp)
  800924:	e8 26 fc ff ff       	call   80054f <close>
	return r;
  800929:	83 c4 10             	add    $0x10,%esp
  80092c:	89 f3                	mov    %esi,%ebx
}
  80092e:	89 d8                	mov    %ebx,%eax
  800930:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800933:	5b                   	pop    %ebx
  800934:	5e                   	pop    %esi
  800935:	5d                   	pop    %ebp
  800936:	c3                   	ret    

00800937 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800937:	55                   	push   %ebp
  800938:	89 e5                	mov    %esp,%ebp
  80093a:	56                   	push   %esi
  80093b:	53                   	push   %ebx
  80093c:	89 c6                	mov    %eax,%esi
  80093e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800940:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  800947:	74 27                	je     800970 <fsipc+0x39>
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800949:	6a 07                	push   $0x7
  80094b:	68 00 50 80 00       	push   $0x805000
  800950:	56                   	push   %esi
  800951:	ff 35 00 60 80 00    	push   0x806000
  800957:	e8 c2 15 00 00       	call   801f1e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80095c:	83 c4 0c             	add    $0xc,%esp
  80095f:	6a 00                	push   $0x0
  800961:	53                   	push   %ebx
  800962:	6a 00                	push   $0x0
  800964:	e8 45 15 00 00       	call   801eae <ipc_recv>
}
  800969:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80096c:	5b                   	pop    %ebx
  80096d:	5e                   	pop    %esi
  80096e:	5d                   	pop    %ebp
  80096f:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800970:	83 ec 0c             	sub    $0xc,%esp
  800973:	6a 01                	push   $0x1
  800975:	e8 f8 15 00 00       	call   801f72 <ipc_find_env>
  80097a:	a3 00 60 80 00       	mov    %eax,0x806000
  80097f:	83 c4 10             	add    $0x10,%esp
  800982:	eb c5                	jmp    800949 <fsipc+0x12>

00800984 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8b 40 0c             	mov    0xc(%eax),%eax
  800990:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800995:	8b 45 0c             	mov    0xc(%ebp),%eax
  800998:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80099d:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a2:	b8 02 00 00 00       	mov    $0x2,%eax
  8009a7:	e8 8b ff ff ff       	call   800937 <fsipc>
}
  8009ac:	c9                   	leave  
  8009ad:	c3                   	ret    

008009ae <devfile_flush>:
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ba:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8009c4:	b8 06 00 00 00       	mov    $0x6,%eax
  8009c9:	e8 69 ff ff ff       	call   800937 <fsipc>
}
  8009ce:	c9                   	leave  
  8009cf:	c3                   	ret    

008009d0 <devfile_stat>:
{
  8009d0:	55                   	push   %ebp
  8009d1:	89 e5                	mov    %esp,%ebp
  8009d3:	53                   	push   %ebx
  8009d4:	83 ec 04             	sub    $0x4,%esp
  8009d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009da:	8b 45 08             	mov    0x8(%ebp),%eax
  8009dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8009ef:	e8 43 ff ff ff       	call   800937 <fsipc>
  8009f4:	85 c0                	test   %eax,%eax
  8009f6:	78 2c                	js     800a24 <devfile_stat+0x54>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009f8:	83 ec 08             	sub    $0x8,%esp
  8009fb:	68 00 50 80 00       	push   $0x805000
  800a00:	53                   	push   %ebx
  800a01:	e8 68 11 00 00       	call   801b6e <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a06:	a1 80 50 80 00       	mov    0x805080,%eax
  800a0b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a11:	a1 84 50 80 00       	mov    0x805084,%eax
  800a16:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a1c:	83 c4 10             	add    $0x10,%esp
  800a1f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a27:	c9                   	leave  
  800a28:	c3                   	ret    

00800a29 <devfile_write>:
{
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	83 ec 0c             	sub    $0xc,%esp
  800a2f:	8b 45 10             	mov    0x10(%ebp),%eax
  800a32:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a37:	39 d0                	cmp    %edx,%eax
  800a39:	0f 47 c2             	cmova  %edx,%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a3c:	8b 55 08             	mov    0x8(%ebp),%edx
  800a3f:	8b 52 0c             	mov    0xc(%edx),%edx
  800a42:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a48:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a4d:	50                   	push   %eax
  800a4e:	ff 75 0c             	push   0xc(%ebp)
  800a51:	68 08 50 80 00       	push   $0x805008
  800a56:	e8 a9 12 00 00       	call   801d04 <memmove>
	return  fsipc(FSREQ_WRITE, NULL);
  800a5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a60:	b8 04 00 00 00       	mov    $0x4,%eax
  800a65:	e8 cd fe ff ff       	call   800937 <fsipc>
}
  800a6a:	c9                   	leave  
  800a6b:	c3                   	ret    

00800a6c <devfile_read>:
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	56                   	push   %esi
  800a70:	53                   	push   %ebx
  800a71:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
  800a77:	8b 40 0c             	mov    0xc(%eax),%eax
  800a7a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a7f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a85:	ba 00 00 00 00       	mov    $0x0,%edx
  800a8a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a8f:	e8 a3 fe ff ff       	call   800937 <fsipc>
  800a94:	89 c3                	mov    %eax,%ebx
  800a96:	85 c0                	test   %eax,%eax
  800a98:	78 1f                	js     800ab9 <devfile_read+0x4d>
	assert(r <= n);
  800a9a:	39 f0                	cmp    %esi,%eax
  800a9c:	77 24                	ja     800ac2 <devfile_read+0x56>
	assert(r <= PGSIZE);
  800a9e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800aa3:	7f 33                	jg     800ad8 <devfile_read+0x6c>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800aa5:	83 ec 04             	sub    $0x4,%esp
  800aa8:	50                   	push   %eax
  800aa9:	68 00 50 80 00       	push   $0x805000
  800aae:	ff 75 0c             	push   0xc(%ebp)
  800ab1:	e8 4e 12 00 00       	call   801d04 <memmove>
	return r;
  800ab6:	83 c4 10             	add    $0x10,%esp
}
  800ab9:	89 d8                	mov    %ebx,%eax
  800abb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800abe:	5b                   	pop    %ebx
  800abf:	5e                   	pop    %esi
  800ac0:	5d                   	pop    %ebp
  800ac1:	c3                   	ret    
	assert(r <= n);
  800ac2:	68 08 23 80 00       	push   $0x802308
  800ac7:	68 0f 23 80 00       	push   $0x80230f
  800acc:	6a 7c                	push   $0x7c
  800ace:	68 24 23 80 00       	push   $0x802324
  800ad3:	e8 e1 09 00 00       	call   8014b9 <_panic>
	assert(r <= PGSIZE);
  800ad8:	68 2f 23 80 00       	push   $0x80232f
  800add:	68 0f 23 80 00       	push   $0x80230f
  800ae2:	6a 7d                	push   $0x7d
  800ae4:	68 24 23 80 00       	push   $0x802324
  800ae9:	e8 cb 09 00 00       	call   8014b9 <_panic>

00800aee <open>:
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	56                   	push   %esi
  800af2:	53                   	push   %ebx
  800af3:	83 ec 1c             	sub    $0x1c,%esp
  800af6:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800af9:	56                   	push   %esi
  800afa:	e8 34 10 00 00       	call   801b33 <strlen>
  800aff:	83 c4 10             	add    $0x10,%esp
  800b02:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b07:	7f 6c                	jg     800b75 <open+0x87>
	if ((r = fd_alloc(&fd)) < 0)
  800b09:	83 ec 0c             	sub    $0xc,%esp
  800b0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b0f:	50                   	push   %eax
  800b10:	e8 bd f8 ff ff       	call   8003d2 <fd_alloc>
  800b15:	89 c3                	mov    %eax,%ebx
  800b17:	83 c4 10             	add    $0x10,%esp
  800b1a:	85 c0                	test   %eax,%eax
  800b1c:	78 3c                	js     800b5a <open+0x6c>
	strcpy(fsipcbuf.open.req_path, path);
  800b1e:	83 ec 08             	sub    $0x8,%esp
  800b21:	56                   	push   %esi
  800b22:	68 00 50 80 00       	push   $0x805000
  800b27:	e8 42 10 00 00       	call   801b6e <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2f:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b37:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3c:	e8 f6 fd ff ff       	call   800937 <fsipc>
  800b41:	89 c3                	mov    %eax,%ebx
  800b43:	83 c4 10             	add    $0x10,%esp
  800b46:	85 c0                	test   %eax,%eax
  800b48:	78 19                	js     800b63 <open+0x75>
	return fd2num(fd);
  800b4a:	83 ec 0c             	sub    $0xc,%esp
  800b4d:	ff 75 f4             	push   -0xc(%ebp)
  800b50:	e8 56 f8 ff ff       	call   8003ab <fd2num>
  800b55:	89 c3                	mov    %eax,%ebx
  800b57:	83 c4 10             	add    $0x10,%esp
}
  800b5a:	89 d8                	mov    %ebx,%eax
  800b5c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b5f:	5b                   	pop    %ebx
  800b60:	5e                   	pop    %esi
  800b61:	5d                   	pop    %ebp
  800b62:	c3                   	ret    
		fd_close(fd, 0);
  800b63:	83 ec 08             	sub    $0x8,%esp
  800b66:	6a 00                	push   $0x0
  800b68:	ff 75 f4             	push   -0xc(%ebp)
  800b6b:	e8 58 f9 ff ff       	call   8004c8 <fd_close>
		return r;
  800b70:	83 c4 10             	add    $0x10,%esp
  800b73:	eb e5                	jmp    800b5a <open+0x6c>
		return -E_BAD_PATH;
  800b75:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b7a:	eb de                	jmp    800b5a <open+0x6c>

00800b7c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b7c:	55                   	push   %ebp
  800b7d:	89 e5                	mov    %esp,%ebp
  800b7f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b82:	ba 00 00 00 00       	mov    $0x0,%edx
  800b87:	b8 08 00 00 00       	mov    $0x8,%eax
  800b8c:	e8 a6 fd ff ff       	call   800937 <fsipc>
}
  800b91:	c9                   	leave  
  800b92:	c3                   	ret    

00800b93 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b93:	55                   	push   %ebp
  800b94:	89 e5                	mov    %esp,%ebp
  800b96:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800b99:	68 3b 23 80 00       	push   $0x80233b
  800b9e:	ff 75 0c             	push   0xc(%ebp)
  800ba1:	e8 c8 0f 00 00       	call   801b6e <strcpy>
	return 0;
}
  800ba6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bab:	c9                   	leave  
  800bac:	c3                   	ret    

00800bad <devsock_close>:
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	53                   	push   %ebx
  800bb1:	83 ec 10             	sub    $0x10,%esp
  800bb4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bb7:	53                   	push   %ebx
  800bb8:	e8 f4 13 00 00       	call   801fb1 <pageref>
  800bbd:	89 c2                	mov    %eax,%edx
  800bbf:	83 c4 10             	add    $0x10,%esp
		return 0;
  800bc2:	b8 00 00 00 00       	mov    $0x0,%eax
	if (pageref(fd) == 1)
  800bc7:	83 fa 01             	cmp    $0x1,%edx
  800bca:	74 05                	je     800bd1 <devsock_close+0x24>
}
  800bcc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bcf:	c9                   	leave  
  800bd0:	c3                   	ret    
		return nsipc_close(fd->fd_sock.sockid);
  800bd1:	83 ec 0c             	sub    $0xc,%esp
  800bd4:	ff 73 0c             	push   0xc(%ebx)
  800bd7:	e8 b7 02 00 00       	call   800e93 <nsipc_close>
  800bdc:	83 c4 10             	add    $0x10,%esp
  800bdf:	eb eb                	jmp    800bcc <devsock_close+0x1f>

00800be1 <devsock_write>:
{
  800be1:	55                   	push   %ebp
  800be2:	89 e5                	mov    %esp,%ebp
  800be4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800be7:	6a 00                	push   $0x0
  800be9:	ff 75 10             	push   0x10(%ebp)
  800bec:	ff 75 0c             	push   0xc(%ebp)
  800bef:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf2:	ff 70 0c             	push   0xc(%eax)
  800bf5:	e8 79 03 00 00       	call   800f73 <nsipc_send>
}
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    

00800bfc <devsock_read>:
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c02:	6a 00                	push   $0x0
  800c04:	ff 75 10             	push   0x10(%ebp)
  800c07:	ff 75 0c             	push   0xc(%ebp)
  800c0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0d:	ff 70 0c             	push   0xc(%eax)
  800c10:	e8 ef 02 00 00       	call   800f04 <nsipc_recv>
}
  800c15:	c9                   	leave  
  800c16:	c3                   	ret    

00800c17 <fd2sockid>:
{
  800c17:	55                   	push   %ebp
  800c18:	89 e5                	mov    %esp,%ebp
  800c1a:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c1d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c20:	52                   	push   %edx
  800c21:	50                   	push   %eax
  800c22:	e8 fb f7 ff ff       	call   800422 <fd_lookup>
  800c27:	83 c4 10             	add    $0x10,%esp
  800c2a:	85 c0                	test   %eax,%eax
  800c2c:	78 10                	js     800c3e <fd2sockid+0x27>
	if (sfd->fd_dev_id != devsock.dev_id)
  800c2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c31:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c37:	39 08                	cmp    %ecx,(%eax)
  800c39:	75 05                	jne    800c40 <fd2sockid+0x29>
	return sfd->fd_sock.sockid;
  800c3b:	8b 40 0c             	mov    0xc(%eax),%eax
}
  800c3e:	c9                   	leave  
  800c3f:	c3                   	ret    
		return -E_NOT_SUPP;
  800c40:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800c45:	eb f7                	jmp    800c3e <fd2sockid+0x27>

00800c47 <alloc_sockfd>:
{
  800c47:	55                   	push   %ebp
  800c48:	89 e5                	mov    %esp,%ebp
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 1c             	sub    $0x1c,%esp
  800c4f:	89 c6                	mov    %eax,%esi
	if ((r = fd_alloc(&sfd)) < 0
  800c51:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c54:	50                   	push   %eax
  800c55:	e8 78 f7 ff ff       	call   8003d2 <fd_alloc>
  800c5a:	89 c3                	mov    %eax,%ebx
  800c5c:	83 c4 10             	add    $0x10,%esp
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	78 43                	js     800ca6 <alloc_sockfd+0x5f>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c63:	83 ec 04             	sub    $0x4,%esp
  800c66:	68 07 04 00 00       	push   $0x407
  800c6b:	ff 75 f4             	push   -0xc(%ebp)
  800c6e:	6a 00                	push   $0x0
  800c70:	e8 e4 f4 ff ff       	call   800159 <sys_page_alloc>
  800c75:	89 c3                	mov    %eax,%ebx
  800c77:	83 c4 10             	add    $0x10,%esp
  800c7a:	85 c0                	test   %eax,%eax
  800c7c:	78 28                	js     800ca6 <alloc_sockfd+0x5f>
	sfd->fd_dev_id = devsock.dev_id;
  800c7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c81:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c87:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800c89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c8c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800c93:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800c96:	83 ec 0c             	sub    $0xc,%esp
  800c99:	50                   	push   %eax
  800c9a:	e8 0c f7 ff ff       	call   8003ab <fd2num>
  800c9f:	89 c3                	mov    %eax,%ebx
  800ca1:	83 c4 10             	add    $0x10,%esp
  800ca4:	eb 0c                	jmp    800cb2 <alloc_sockfd+0x6b>
		nsipc_close(sockid);
  800ca6:	83 ec 0c             	sub    $0xc,%esp
  800ca9:	56                   	push   %esi
  800caa:	e8 e4 01 00 00       	call   800e93 <nsipc_close>
		return r;
  800caf:	83 c4 10             	add    $0x10,%esp
}
  800cb2:	89 d8                	mov    %ebx,%eax
  800cb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <accept>:
{
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc4:	e8 4e ff ff ff       	call   800c17 <fd2sockid>
  800cc9:	85 c0                	test   %eax,%eax
  800ccb:	78 1b                	js     800ce8 <accept+0x2d>
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800ccd:	83 ec 04             	sub    $0x4,%esp
  800cd0:	ff 75 10             	push   0x10(%ebp)
  800cd3:	ff 75 0c             	push   0xc(%ebp)
  800cd6:	50                   	push   %eax
  800cd7:	e8 0e 01 00 00       	call   800dea <nsipc_accept>
  800cdc:	83 c4 10             	add    $0x10,%esp
  800cdf:	85 c0                	test   %eax,%eax
  800ce1:	78 05                	js     800ce8 <accept+0x2d>
	return alloc_sockfd(r);
  800ce3:	e8 5f ff ff ff       	call   800c47 <alloc_sockfd>
}
  800ce8:	c9                   	leave  
  800ce9:	c3                   	ret    

00800cea <bind>:
{
  800cea:	55                   	push   %ebp
  800ceb:	89 e5                	mov    %esp,%ebp
  800ced:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800cf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf3:	e8 1f ff ff ff       	call   800c17 <fd2sockid>
  800cf8:	85 c0                	test   %eax,%eax
  800cfa:	78 12                	js     800d0e <bind+0x24>
	return nsipc_bind(r, name, namelen);
  800cfc:	83 ec 04             	sub    $0x4,%esp
  800cff:	ff 75 10             	push   0x10(%ebp)
  800d02:	ff 75 0c             	push   0xc(%ebp)
  800d05:	50                   	push   %eax
  800d06:	e8 31 01 00 00       	call   800e3c <nsipc_bind>
  800d0b:	83 c4 10             	add    $0x10,%esp
}
  800d0e:	c9                   	leave  
  800d0f:	c3                   	ret    

00800d10 <shutdown>:
{
  800d10:	55                   	push   %ebp
  800d11:	89 e5                	mov    %esp,%ebp
  800d13:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d16:	8b 45 08             	mov    0x8(%ebp),%eax
  800d19:	e8 f9 fe ff ff       	call   800c17 <fd2sockid>
  800d1e:	85 c0                	test   %eax,%eax
  800d20:	78 0f                	js     800d31 <shutdown+0x21>
	return nsipc_shutdown(r, how);
  800d22:	83 ec 08             	sub    $0x8,%esp
  800d25:	ff 75 0c             	push   0xc(%ebp)
  800d28:	50                   	push   %eax
  800d29:	e8 43 01 00 00       	call   800e71 <nsipc_shutdown>
  800d2e:	83 c4 10             	add    $0x10,%esp
}
  800d31:	c9                   	leave  
  800d32:	c3                   	ret    

00800d33 <connect>:
{
  800d33:	55                   	push   %ebp
  800d34:	89 e5                	mov    %esp,%ebp
  800d36:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d39:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3c:	e8 d6 fe ff ff       	call   800c17 <fd2sockid>
  800d41:	85 c0                	test   %eax,%eax
  800d43:	78 12                	js     800d57 <connect+0x24>
	return nsipc_connect(r, name, namelen);
  800d45:	83 ec 04             	sub    $0x4,%esp
  800d48:	ff 75 10             	push   0x10(%ebp)
  800d4b:	ff 75 0c             	push   0xc(%ebp)
  800d4e:	50                   	push   %eax
  800d4f:	e8 59 01 00 00       	call   800ead <nsipc_connect>
  800d54:	83 c4 10             	add    $0x10,%esp
}
  800d57:	c9                   	leave  
  800d58:	c3                   	ret    

00800d59 <listen>:
{
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	83 ec 08             	sub    $0x8,%esp
	if ((r = fd2sockid(s)) < 0)
  800d5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d62:	e8 b0 fe ff ff       	call   800c17 <fd2sockid>
  800d67:	85 c0                	test   %eax,%eax
  800d69:	78 0f                	js     800d7a <listen+0x21>
	return nsipc_listen(r, backlog);
  800d6b:	83 ec 08             	sub    $0x8,%esp
  800d6e:	ff 75 0c             	push   0xc(%ebp)
  800d71:	50                   	push   %eax
  800d72:	e8 6b 01 00 00       	call   800ee2 <nsipc_listen>
  800d77:	83 c4 10             	add    $0x10,%esp
}
  800d7a:	c9                   	leave  
  800d7b:	c3                   	ret    

00800d7c <socket>:

int
socket(int domain, int type, int protocol)
{
  800d7c:	55                   	push   %ebp
  800d7d:	89 e5                	mov    %esp,%ebp
  800d7f:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d82:	ff 75 10             	push   0x10(%ebp)
  800d85:	ff 75 0c             	push   0xc(%ebp)
  800d88:	ff 75 08             	push   0x8(%ebp)
  800d8b:	e8 41 02 00 00       	call   800fd1 <nsipc_socket>
  800d90:	83 c4 10             	add    $0x10,%esp
  800d93:	85 c0                	test   %eax,%eax
  800d95:	78 05                	js     800d9c <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800d97:	e8 ab fe ff ff       	call   800c47 <alloc_sockfd>
}
  800d9c:	c9                   	leave  
  800d9d:	c3                   	ret    

00800d9e <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	53                   	push   %ebx
  800da2:	83 ec 04             	sub    $0x4,%esp
  800da5:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800da7:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  800dae:	74 26                	je     800dd6 <nsipc+0x38>
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800db0:	6a 07                	push   $0x7
  800db2:	68 00 70 80 00       	push   $0x807000
  800db7:	53                   	push   %ebx
  800db8:	ff 35 00 80 80 00    	push   0x808000
  800dbe:	e8 5b 11 00 00       	call   801f1e <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800dc3:	83 c4 0c             	add    $0xc,%esp
  800dc6:	6a 00                	push   $0x0
  800dc8:	6a 00                	push   $0x0
  800dca:	6a 00                	push   $0x0
  800dcc:	e8 dd 10 00 00       	call   801eae <ipc_recv>
}
  800dd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dd4:	c9                   	leave  
  800dd5:	c3                   	ret    
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dd6:	83 ec 0c             	sub    $0xc,%esp
  800dd9:	6a 02                	push   $0x2
  800ddb:	e8 92 11 00 00       	call   801f72 <ipc_find_env>
  800de0:	a3 00 80 80 00       	mov    %eax,0x808000
  800de5:	83 c4 10             	add    $0x10,%esp
  800de8:	eb c6                	jmp    800db0 <nsipc+0x12>

00800dea <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	56                   	push   %esi
  800dee:	53                   	push   %ebx
  800def:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800df2:	8b 45 08             	mov    0x8(%ebp),%eax
  800df5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800dfa:	8b 06                	mov    (%esi),%eax
  800dfc:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e01:	b8 01 00 00 00       	mov    $0x1,%eax
  800e06:	e8 93 ff ff ff       	call   800d9e <nsipc>
  800e0b:	89 c3                	mov    %eax,%ebx
  800e0d:	85 c0                	test   %eax,%eax
  800e0f:	79 09                	jns    800e1a <nsipc_accept+0x30>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
		*addrlen = ret->ret_addrlen;
	}
	return r;
}
  800e11:	89 d8                	mov    %ebx,%eax
  800e13:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e16:	5b                   	pop    %ebx
  800e17:	5e                   	pop    %esi
  800e18:	5d                   	pop    %ebp
  800e19:	c3                   	ret    
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e1a:	83 ec 04             	sub    $0x4,%esp
  800e1d:	ff 35 10 70 80 00    	push   0x807010
  800e23:	68 00 70 80 00       	push   $0x807000
  800e28:	ff 75 0c             	push   0xc(%ebp)
  800e2b:	e8 d4 0e 00 00       	call   801d04 <memmove>
		*addrlen = ret->ret_addrlen;
  800e30:	a1 10 70 80 00       	mov    0x807010,%eax
  800e35:	89 06                	mov    %eax,(%esi)
  800e37:	83 c4 10             	add    $0x10,%esp
	return r;
  800e3a:	eb d5                	jmp    800e11 <nsipc_accept+0x27>

00800e3c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e3c:	55                   	push   %ebp
  800e3d:	89 e5                	mov    %esp,%ebp
  800e3f:	53                   	push   %ebx
  800e40:	83 ec 08             	sub    $0x8,%esp
  800e43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e46:	8b 45 08             	mov    0x8(%ebp),%eax
  800e49:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e4e:	53                   	push   %ebx
  800e4f:	ff 75 0c             	push   0xc(%ebp)
  800e52:	68 04 70 80 00       	push   $0x807004
  800e57:	e8 a8 0e 00 00       	call   801d04 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e5c:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  800e62:	b8 02 00 00 00       	mov    $0x2,%eax
  800e67:	e8 32 ff ff ff       	call   800d9e <nsipc>
}
  800e6c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e6f:	c9                   	leave  
  800e70:	c3                   	ret    

00800e71 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e77:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7a:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  800e7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e82:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  800e87:	b8 03 00 00 00       	mov    $0x3,%eax
  800e8c:	e8 0d ff ff ff       	call   800d9e <nsipc>
}
  800e91:	c9                   	leave  
  800e92:	c3                   	ret    

00800e93 <nsipc_close>:

int
nsipc_close(int s)
{
  800e93:	55                   	push   %ebp
  800e94:	89 e5                	mov    %esp,%ebp
  800e96:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800e99:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9c:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  800ea1:	b8 04 00 00 00       	mov    $0x4,%eax
  800ea6:	e8 f3 fe ff ff       	call   800d9e <nsipc>
}
  800eab:	c9                   	leave  
  800eac:	c3                   	ret    

00800ead <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800ead:	55                   	push   %ebp
  800eae:	89 e5                	mov    %esp,%ebp
  800eb0:	53                   	push   %ebx
  800eb1:	83 ec 08             	sub    $0x8,%esp
  800eb4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eba:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ebf:	53                   	push   %ebx
  800ec0:	ff 75 0c             	push   0xc(%ebp)
  800ec3:	68 04 70 80 00       	push   $0x807004
  800ec8:	e8 37 0e 00 00       	call   801d04 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800ecd:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  800ed3:	b8 05 00 00 00       	mov    $0x5,%eax
  800ed8:	e8 c1 fe ff ff       	call   800d9e <nsipc>
}
  800edd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ee0:	c9                   	leave  
  800ee1:	c3                   	ret    

00800ee2 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ee8:	8b 45 08             	mov    0x8(%ebp),%eax
  800eeb:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  800ef0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef3:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  800ef8:	b8 06 00 00 00       	mov    $0x6,%eax
  800efd:	e8 9c fe ff ff       	call   800d9e <nsipc>
}
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	56                   	push   %esi
  800f08:	53                   	push   %ebx
  800f09:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f0c:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  800f14:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  800f1a:	8b 45 14             	mov    0x14(%ebp),%eax
  800f1d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f22:	b8 07 00 00 00       	mov    $0x7,%eax
  800f27:	e8 72 fe ff ff       	call   800d9e <nsipc>
  800f2c:	89 c3                	mov    %eax,%ebx
  800f2e:	85 c0                	test   %eax,%eax
  800f30:	78 22                	js     800f54 <nsipc_recv+0x50>
		assert(r < 1600 && r <= len);
  800f32:	b8 3f 06 00 00       	mov    $0x63f,%eax
  800f37:	39 c6                	cmp    %eax,%esi
  800f39:	0f 4e c6             	cmovle %esi,%eax
  800f3c:	39 c3                	cmp    %eax,%ebx
  800f3e:	7f 1d                	jg     800f5d <nsipc_recv+0x59>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f40:	83 ec 04             	sub    $0x4,%esp
  800f43:	53                   	push   %ebx
  800f44:	68 00 70 80 00       	push   $0x807000
  800f49:	ff 75 0c             	push   0xc(%ebp)
  800f4c:	e8 b3 0d 00 00       	call   801d04 <memmove>
  800f51:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f54:	89 d8                	mov    %ebx,%eax
  800f56:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f59:	5b                   	pop    %ebx
  800f5a:	5e                   	pop    %esi
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    
		assert(r < 1600 && r <= len);
  800f5d:	68 47 23 80 00       	push   $0x802347
  800f62:	68 0f 23 80 00       	push   $0x80230f
  800f67:	6a 62                	push   $0x62
  800f69:	68 5c 23 80 00       	push   $0x80235c
  800f6e:	e8 46 05 00 00       	call   8014b9 <_panic>

00800f73 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f73:	55                   	push   %ebp
  800f74:	89 e5                	mov    %esp,%ebp
  800f76:	53                   	push   %ebx
  800f77:	83 ec 04             	sub    $0x4,%esp
  800f7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800f80:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  800f85:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f8b:	7f 2e                	jg     800fbb <nsipc_send+0x48>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800f8d:	83 ec 04             	sub    $0x4,%esp
  800f90:	53                   	push   %ebx
  800f91:	ff 75 0c             	push   0xc(%ebp)
  800f94:	68 0c 70 80 00       	push   $0x80700c
  800f99:	e8 66 0d 00 00       	call   801d04 <memmove>
	nsipcbuf.send.req_size = size;
  800f9e:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  800fa4:	8b 45 14             	mov    0x14(%ebp),%eax
  800fa7:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  800fac:	b8 08 00 00 00       	mov    $0x8,%eax
  800fb1:	e8 e8 fd ff ff       	call   800d9e <nsipc>
}
  800fb6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb9:	c9                   	leave  
  800fba:	c3                   	ret    
	assert(size < 1600);
  800fbb:	68 68 23 80 00       	push   $0x802368
  800fc0:	68 0f 23 80 00       	push   $0x80230f
  800fc5:	6a 6d                	push   $0x6d
  800fc7:	68 5c 23 80 00       	push   $0x80235c
  800fcc:	e8 e8 04 00 00       	call   8014b9 <_panic>

00800fd1 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fd1:	55                   	push   %ebp
  800fd2:	89 e5                	mov    %esp,%ebp
  800fd4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800fda:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  800fdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe2:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  800fe7:	8b 45 10             	mov    0x10(%ebp),%eax
  800fea:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  800fef:	b8 09 00 00 00       	mov    $0x9,%eax
  800ff4:	e8 a5 fd ff ff       	call   800d9e <nsipc>
}
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    

00800ffb <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	56                   	push   %esi
  800fff:	53                   	push   %ebx
  801000:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801003:	83 ec 0c             	sub    $0xc,%esp
  801006:	ff 75 08             	push   0x8(%ebp)
  801009:	e8 ad f3 ff ff       	call   8003bb <fd2data>
  80100e:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801010:	83 c4 08             	add    $0x8,%esp
  801013:	68 74 23 80 00       	push   $0x802374
  801018:	53                   	push   %ebx
  801019:	e8 50 0b 00 00       	call   801b6e <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80101e:	8b 46 04             	mov    0x4(%esi),%eax
  801021:	2b 06                	sub    (%esi),%eax
  801023:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801029:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801030:	00 00 00 
	stat->st_dev = &devpipe;
  801033:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80103a:	30 80 00 
	return 0;
}
  80103d:	b8 00 00 00 00       	mov    $0x0,%eax
  801042:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801045:	5b                   	pop    %ebx
  801046:	5e                   	pop    %esi
  801047:	5d                   	pop    %ebp
  801048:	c3                   	ret    

00801049 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801049:	55                   	push   %ebp
  80104a:	89 e5                	mov    %esp,%ebp
  80104c:	53                   	push   %ebx
  80104d:	83 ec 0c             	sub    $0xc,%esp
  801050:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801053:	53                   	push   %ebx
  801054:	6a 00                	push   $0x0
  801056:	e8 83 f1 ff ff       	call   8001de <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80105b:	89 1c 24             	mov    %ebx,(%esp)
  80105e:	e8 58 f3 ff ff       	call   8003bb <fd2data>
  801063:	83 c4 08             	add    $0x8,%esp
  801066:	50                   	push   %eax
  801067:	6a 00                	push   $0x0
  801069:	e8 70 f1 ff ff       	call   8001de <sys_page_unmap>
}
  80106e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801071:	c9                   	leave  
  801072:	c3                   	ret    

00801073 <_pipeisclosed>:
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	57                   	push   %edi
  801077:	56                   	push   %esi
  801078:	53                   	push   %ebx
  801079:	83 ec 1c             	sub    $0x1c,%esp
  80107c:	89 c7                	mov    %eax,%edi
  80107e:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801080:	a1 00 40 80 00       	mov    0x804000,%eax
  801085:	8b 58 68             	mov    0x68(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801088:	83 ec 0c             	sub    $0xc,%esp
  80108b:	57                   	push   %edi
  80108c:	e8 20 0f 00 00       	call   801fb1 <pageref>
  801091:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801094:	89 34 24             	mov    %esi,(%esp)
  801097:	e8 15 0f 00 00       	call   801fb1 <pageref>
		nn = thisenv->env_runs;
  80109c:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8010a2:	8b 4a 68             	mov    0x68(%edx),%ecx
		if (n == nn)
  8010a5:	83 c4 10             	add    $0x10,%esp
  8010a8:	39 cb                	cmp    %ecx,%ebx
  8010aa:	74 1b                	je     8010c7 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8010ac:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010af:	75 cf                	jne    801080 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010b1:	8b 42 68             	mov    0x68(%edx),%eax
  8010b4:	6a 01                	push   $0x1
  8010b6:	50                   	push   %eax
  8010b7:	53                   	push   %ebx
  8010b8:	68 7b 23 80 00       	push   $0x80237b
  8010bd:	e8 d2 04 00 00       	call   801594 <cprintf>
  8010c2:	83 c4 10             	add    $0x10,%esp
  8010c5:	eb b9                	jmp    801080 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8010c7:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8010ca:	0f 94 c0             	sete   %al
  8010cd:	0f b6 c0             	movzbl %al,%eax
}
  8010d0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010d3:	5b                   	pop    %ebx
  8010d4:	5e                   	pop    %esi
  8010d5:	5f                   	pop    %edi
  8010d6:	5d                   	pop    %ebp
  8010d7:	c3                   	ret    

008010d8 <devpipe_write>:
{
  8010d8:	55                   	push   %ebp
  8010d9:	89 e5                	mov    %esp,%ebp
  8010db:	57                   	push   %edi
  8010dc:	56                   	push   %esi
  8010dd:	53                   	push   %ebx
  8010de:	83 ec 28             	sub    $0x28,%esp
  8010e1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8010e4:	56                   	push   %esi
  8010e5:	e8 d1 f2 ff ff       	call   8003bb <fd2data>
  8010ea:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8010ec:	83 c4 10             	add    $0x10,%esp
  8010ef:	bf 00 00 00 00       	mov    $0x0,%edi
  8010f4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8010f7:	75 09                	jne    801102 <devpipe_write+0x2a>
	return i;
  8010f9:	89 f8                	mov    %edi,%eax
  8010fb:	eb 23                	jmp    801120 <devpipe_write+0x48>
			sys_yield();
  8010fd:	e8 38 f0 ff ff       	call   80013a <sys_yield>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801102:	8b 43 04             	mov    0x4(%ebx),%eax
  801105:	8b 0b                	mov    (%ebx),%ecx
  801107:	8d 51 20             	lea    0x20(%ecx),%edx
  80110a:	39 d0                	cmp    %edx,%eax
  80110c:	72 1a                	jb     801128 <devpipe_write+0x50>
			if (_pipeisclosed(fd, p))
  80110e:	89 da                	mov    %ebx,%edx
  801110:	89 f0                	mov    %esi,%eax
  801112:	e8 5c ff ff ff       	call   801073 <_pipeisclosed>
  801117:	85 c0                	test   %eax,%eax
  801119:	74 e2                	je     8010fd <devpipe_write+0x25>
				return 0;
  80111b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801120:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801123:	5b                   	pop    %ebx
  801124:	5e                   	pop    %esi
  801125:	5f                   	pop    %edi
  801126:	5d                   	pop    %ebp
  801127:	c3                   	ret    
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801128:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80112f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801132:	89 c2                	mov    %eax,%edx
  801134:	c1 fa 1f             	sar    $0x1f,%edx
  801137:	89 d1                	mov    %edx,%ecx
  801139:	c1 e9 1b             	shr    $0x1b,%ecx
  80113c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80113f:	83 e2 1f             	and    $0x1f,%edx
  801142:	29 ca                	sub    %ecx,%edx
  801144:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801148:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80114c:	83 c0 01             	add    $0x1,%eax
  80114f:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801152:	83 c7 01             	add    $0x1,%edi
  801155:	eb 9d                	jmp    8010f4 <devpipe_write+0x1c>

00801157 <devpipe_read>:
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	57                   	push   %edi
  80115b:	56                   	push   %esi
  80115c:	53                   	push   %ebx
  80115d:	83 ec 18             	sub    $0x18,%esp
  801160:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801163:	57                   	push   %edi
  801164:	e8 52 f2 ff ff       	call   8003bb <fd2data>
  801169:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80116b:	83 c4 10             	add    $0x10,%esp
  80116e:	be 00 00 00 00       	mov    $0x0,%esi
  801173:	3b 75 10             	cmp    0x10(%ebp),%esi
  801176:	75 13                	jne    80118b <devpipe_read+0x34>
	return i;
  801178:	89 f0                	mov    %esi,%eax
  80117a:	eb 02                	jmp    80117e <devpipe_read+0x27>
				return i;
  80117c:	89 f0                	mov    %esi,%eax
}
  80117e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801181:	5b                   	pop    %ebx
  801182:	5e                   	pop    %esi
  801183:	5f                   	pop    %edi
  801184:	5d                   	pop    %ebp
  801185:	c3                   	ret    
			sys_yield();
  801186:	e8 af ef ff ff       	call   80013a <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80118b:	8b 03                	mov    (%ebx),%eax
  80118d:	3b 43 04             	cmp    0x4(%ebx),%eax
  801190:	75 18                	jne    8011aa <devpipe_read+0x53>
			if (i > 0)
  801192:	85 f6                	test   %esi,%esi
  801194:	75 e6                	jne    80117c <devpipe_read+0x25>
			if (_pipeisclosed(fd, p))
  801196:	89 da                	mov    %ebx,%edx
  801198:	89 f8                	mov    %edi,%eax
  80119a:	e8 d4 fe ff ff       	call   801073 <_pipeisclosed>
  80119f:	85 c0                	test   %eax,%eax
  8011a1:	74 e3                	je     801186 <devpipe_read+0x2f>
				return 0;
  8011a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011a8:	eb d4                	jmp    80117e <devpipe_read+0x27>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011aa:	99                   	cltd   
  8011ab:	c1 ea 1b             	shr    $0x1b,%edx
  8011ae:	01 d0                	add    %edx,%eax
  8011b0:	83 e0 1f             	and    $0x1f,%eax
  8011b3:	29 d0                	sub    %edx,%eax
  8011b5:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8011ba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bd:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8011c0:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8011c3:	83 c6 01             	add    $0x1,%esi
  8011c6:	eb ab                	jmp    801173 <devpipe_read+0x1c>

008011c8 <pipe>:
{
  8011c8:	55                   	push   %ebp
  8011c9:	89 e5                	mov    %esp,%ebp
  8011cb:	56                   	push   %esi
  8011cc:	53                   	push   %ebx
  8011cd:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8011d0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d3:	50                   	push   %eax
  8011d4:	e8 f9 f1 ff ff       	call   8003d2 <fd_alloc>
  8011d9:	89 c3                	mov    %eax,%ebx
  8011db:	83 c4 10             	add    $0x10,%esp
  8011de:	85 c0                	test   %eax,%eax
  8011e0:	0f 88 23 01 00 00    	js     801309 <pipe+0x141>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011e6:	83 ec 04             	sub    $0x4,%esp
  8011e9:	68 07 04 00 00       	push   $0x407
  8011ee:	ff 75 f4             	push   -0xc(%ebp)
  8011f1:	6a 00                	push   $0x0
  8011f3:	e8 61 ef ff ff       	call   800159 <sys_page_alloc>
  8011f8:	89 c3                	mov    %eax,%ebx
  8011fa:	83 c4 10             	add    $0x10,%esp
  8011fd:	85 c0                	test   %eax,%eax
  8011ff:	0f 88 04 01 00 00    	js     801309 <pipe+0x141>
	if ((r = fd_alloc(&fd1)) < 0
  801205:	83 ec 0c             	sub    $0xc,%esp
  801208:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120b:	50                   	push   %eax
  80120c:	e8 c1 f1 ff ff       	call   8003d2 <fd_alloc>
  801211:	89 c3                	mov    %eax,%ebx
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	85 c0                	test   %eax,%eax
  801218:	0f 88 db 00 00 00    	js     8012f9 <pipe+0x131>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80121e:	83 ec 04             	sub    $0x4,%esp
  801221:	68 07 04 00 00       	push   $0x407
  801226:	ff 75 f0             	push   -0x10(%ebp)
  801229:	6a 00                	push   $0x0
  80122b:	e8 29 ef ff ff       	call   800159 <sys_page_alloc>
  801230:	89 c3                	mov    %eax,%ebx
  801232:	83 c4 10             	add    $0x10,%esp
  801235:	85 c0                	test   %eax,%eax
  801237:	0f 88 bc 00 00 00    	js     8012f9 <pipe+0x131>
	va = fd2data(fd0);
  80123d:	83 ec 0c             	sub    $0xc,%esp
  801240:	ff 75 f4             	push   -0xc(%ebp)
  801243:	e8 73 f1 ff ff       	call   8003bb <fd2data>
  801248:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80124a:	83 c4 0c             	add    $0xc,%esp
  80124d:	68 07 04 00 00       	push   $0x407
  801252:	50                   	push   %eax
  801253:	6a 00                	push   $0x0
  801255:	e8 ff ee ff ff       	call   800159 <sys_page_alloc>
  80125a:	89 c3                	mov    %eax,%ebx
  80125c:	83 c4 10             	add    $0x10,%esp
  80125f:	85 c0                	test   %eax,%eax
  801261:	0f 88 82 00 00 00    	js     8012e9 <pipe+0x121>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801267:	83 ec 0c             	sub    $0xc,%esp
  80126a:	ff 75 f0             	push   -0x10(%ebp)
  80126d:	e8 49 f1 ff ff       	call   8003bb <fd2data>
  801272:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801279:	50                   	push   %eax
  80127a:	6a 00                	push   $0x0
  80127c:	56                   	push   %esi
  80127d:	6a 00                	push   $0x0
  80127f:	e8 18 ef ff ff       	call   80019c <sys_page_map>
  801284:	89 c3                	mov    %eax,%ebx
  801286:	83 c4 20             	add    $0x20,%esp
  801289:	85 c0                	test   %eax,%eax
  80128b:	78 4e                	js     8012db <pipe+0x113>
	fd0->fd_dev_id = devpipe.dev_id;
  80128d:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801292:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801295:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801297:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80129a:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8012a1:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012a4:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8012a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a9:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8012b0:	83 ec 0c             	sub    $0xc,%esp
  8012b3:	ff 75 f4             	push   -0xc(%ebp)
  8012b6:	e8 f0 f0 ff ff       	call   8003ab <fd2num>
  8012bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012be:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012c0:	83 c4 04             	add    $0x4,%esp
  8012c3:	ff 75 f0             	push   -0x10(%ebp)
  8012c6:	e8 e0 f0 ff ff       	call   8003ab <fd2num>
  8012cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ce:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012d9:	eb 2e                	jmp    801309 <pipe+0x141>
	sys_page_unmap(0, va);
  8012db:	83 ec 08             	sub    $0x8,%esp
  8012de:	56                   	push   %esi
  8012df:	6a 00                	push   $0x0
  8012e1:	e8 f8 ee ff ff       	call   8001de <sys_page_unmap>
  8012e6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8012e9:	83 ec 08             	sub    $0x8,%esp
  8012ec:	ff 75 f0             	push   -0x10(%ebp)
  8012ef:	6a 00                	push   $0x0
  8012f1:	e8 e8 ee ff ff       	call   8001de <sys_page_unmap>
  8012f6:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8012f9:	83 ec 08             	sub    $0x8,%esp
  8012fc:	ff 75 f4             	push   -0xc(%ebp)
  8012ff:	6a 00                	push   $0x0
  801301:	e8 d8 ee ff ff       	call   8001de <sys_page_unmap>
  801306:	83 c4 10             	add    $0x10,%esp
}
  801309:	89 d8                	mov    %ebx,%eax
  80130b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80130e:	5b                   	pop    %ebx
  80130f:	5e                   	pop    %esi
  801310:	5d                   	pop    %ebp
  801311:	c3                   	ret    

00801312 <pipeisclosed>:
{
  801312:	55                   	push   %ebp
  801313:	89 e5                	mov    %esp,%ebp
  801315:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801318:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80131b:	50                   	push   %eax
  80131c:	ff 75 08             	push   0x8(%ebp)
  80131f:	e8 fe f0 ff ff       	call   800422 <fd_lookup>
  801324:	83 c4 10             	add    $0x10,%esp
  801327:	85 c0                	test   %eax,%eax
  801329:	78 18                	js     801343 <pipeisclosed+0x31>
	p = (struct Pipe*) fd2data(fd);
  80132b:	83 ec 0c             	sub    $0xc,%esp
  80132e:	ff 75 f4             	push   -0xc(%ebp)
  801331:	e8 85 f0 ff ff       	call   8003bb <fd2data>
  801336:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801338:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133b:	e8 33 fd ff ff       	call   801073 <_pipeisclosed>
  801340:	83 c4 10             	add    $0x10,%esp
}
  801343:	c9                   	leave  
  801344:	c3                   	ret    

00801345 <devcons_close>:
devcons_close(struct Fd *fd)
{
	USED(fd);

	return 0;
}
  801345:	b8 00 00 00 00       	mov    $0x0,%eax
  80134a:	c3                   	ret    

0080134b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801351:	68 93 23 80 00       	push   $0x802393
  801356:	ff 75 0c             	push   0xc(%ebp)
  801359:	e8 10 08 00 00       	call   801b6e <strcpy>
	return 0;
}
  80135e:	b8 00 00 00 00       	mov    $0x0,%eax
  801363:	c9                   	leave  
  801364:	c3                   	ret    

00801365 <devcons_write>:
{
  801365:	55                   	push   %ebp
  801366:	89 e5                	mov    %esp,%ebp
  801368:	57                   	push   %edi
  801369:	56                   	push   %esi
  80136a:	53                   	push   %ebx
  80136b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801371:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801376:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80137c:	eb 2e                	jmp    8013ac <devcons_write+0x47>
		m = n - tot;
  80137e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801381:	29 f3                	sub    %esi,%ebx
  801383:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801388:	39 c3                	cmp    %eax,%ebx
  80138a:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80138d:	83 ec 04             	sub    $0x4,%esp
  801390:	53                   	push   %ebx
  801391:	89 f0                	mov    %esi,%eax
  801393:	03 45 0c             	add    0xc(%ebp),%eax
  801396:	50                   	push   %eax
  801397:	57                   	push   %edi
  801398:	e8 67 09 00 00       	call   801d04 <memmove>
		sys_cputs(buf, m);
  80139d:	83 c4 08             	add    $0x8,%esp
  8013a0:	53                   	push   %ebx
  8013a1:	57                   	push   %edi
  8013a2:	e8 f6 ec ff ff       	call   80009d <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8013a7:	01 de                	add    %ebx,%esi
  8013a9:	83 c4 10             	add    $0x10,%esp
  8013ac:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013af:	72 cd                	jb     80137e <devcons_write+0x19>
}
  8013b1:	89 f0                	mov    %esi,%eax
  8013b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013b6:	5b                   	pop    %ebx
  8013b7:	5e                   	pop    %esi
  8013b8:	5f                   	pop    %edi
  8013b9:	5d                   	pop    %ebp
  8013ba:	c3                   	ret    

008013bb <devcons_read>:
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	83 ec 08             	sub    $0x8,%esp
  8013c1:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8013c6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013ca:	75 07                	jne    8013d3 <devcons_read+0x18>
  8013cc:	eb 1f                	jmp    8013ed <devcons_read+0x32>
		sys_yield();
  8013ce:	e8 67 ed ff ff       	call   80013a <sys_yield>
	while ((c = sys_cgetc()) == 0)
  8013d3:	e8 e3 ec ff ff       	call   8000bb <sys_cgetc>
  8013d8:	85 c0                	test   %eax,%eax
  8013da:	74 f2                	je     8013ce <devcons_read+0x13>
	if (c < 0)
  8013dc:	78 0f                	js     8013ed <devcons_read+0x32>
	if (c == 0x04)	// ctl-d is eof
  8013de:	83 f8 04             	cmp    $0x4,%eax
  8013e1:	74 0c                	je     8013ef <devcons_read+0x34>
	*(char*)vbuf = c;
  8013e3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8013e6:	88 02                	mov    %al,(%edx)
	return 1;
  8013e8:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8013ed:	c9                   	leave  
  8013ee:	c3                   	ret    
		return 0;
  8013ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8013f4:	eb f7                	jmp    8013ed <devcons_read+0x32>

008013f6 <cputchar>:
{
  8013f6:	55                   	push   %ebp
  8013f7:	89 e5                	mov    %esp,%ebp
  8013f9:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8013fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ff:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801402:	6a 01                	push   $0x1
  801404:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801407:	50                   	push   %eax
  801408:	e8 90 ec ff ff       	call   80009d <sys_cputs>
}
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	c9                   	leave  
  801411:	c3                   	ret    

00801412 <getchar>:
{
  801412:	55                   	push   %ebp
  801413:	89 e5                	mov    %esp,%ebp
  801415:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801418:	6a 01                	push   $0x1
  80141a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80141d:	50                   	push   %eax
  80141e:	6a 00                	push   $0x0
  801420:	e8 66 f2 ff ff       	call   80068b <read>
	if (r < 0)
  801425:	83 c4 10             	add    $0x10,%esp
  801428:	85 c0                	test   %eax,%eax
  80142a:	78 06                	js     801432 <getchar+0x20>
	if (r < 1)
  80142c:	74 06                	je     801434 <getchar+0x22>
	return c;
  80142e:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801432:	c9                   	leave  
  801433:	c3                   	ret    
		return -E_EOF;
  801434:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801439:	eb f7                	jmp    801432 <getchar+0x20>

0080143b <iscons>:
{
  80143b:	55                   	push   %ebp
  80143c:	89 e5                	mov    %esp,%ebp
  80143e:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801441:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801444:	50                   	push   %eax
  801445:	ff 75 08             	push   0x8(%ebp)
  801448:	e8 d5 ef ff ff       	call   800422 <fd_lookup>
  80144d:	83 c4 10             	add    $0x10,%esp
  801450:	85 c0                	test   %eax,%eax
  801452:	78 11                	js     801465 <iscons+0x2a>
	return fd->fd_dev_id == devcons.dev_id;
  801454:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801457:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80145d:	39 10                	cmp    %edx,(%eax)
  80145f:	0f 94 c0             	sete   %al
  801462:	0f b6 c0             	movzbl %al,%eax
}
  801465:	c9                   	leave  
  801466:	c3                   	ret    

00801467 <opencons>:
{
  801467:	55                   	push   %ebp
  801468:	89 e5                	mov    %esp,%ebp
  80146a:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80146d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801470:	50                   	push   %eax
  801471:	e8 5c ef ff ff       	call   8003d2 <fd_alloc>
  801476:	83 c4 10             	add    $0x10,%esp
  801479:	85 c0                	test   %eax,%eax
  80147b:	78 3a                	js     8014b7 <opencons+0x50>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80147d:	83 ec 04             	sub    $0x4,%esp
  801480:	68 07 04 00 00       	push   $0x407
  801485:	ff 75 f4             	push   -0xc(%ebp)
  801488:	6a 00                	push   $0x0
  80148a:	e8 ca ec ff ff       	call   800159 <sys_page_alloc>
  80148f:	83 c4 10             	add    $0x10,%esp
  801492:	85 c0                	test   %eax,%eax
  801494:	78 21                	js     8014b7 <opencons+0x50>
	fd->fd_dev_id = devcons.dev_id;
  801496:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801499:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80149f:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014a4:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014ab:	83 ec 0c             	sub    $0xc,%esp
  8014ae:	50                   	push   %eax
  8014af:	e8 f7 ee ff ff       	call   8003ab <fd2num>
  8014b4:	83 c4 10             	add    $0x10,%esp
}
  8014b7:	c9                   	leave  
  8014b8:	c3                   	ret    

008014b9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014b9:	55                   	push   %ebp
  8014ba:	89 e5                	mov    %esp,%ebp
  8014bc:	56                   	push   %esi
  8014bd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014be:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014c1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014c7:	e8 4f ec ff ff       	call   80011b <sys_getenvid>
  8014cc:	83 ec 0c             	sub    $0xc,%esp
  8014cf:	ff 75 0c             	push   0xc(%ebp)
  8014d2:	ff 75 08             	push   0x8(%ebp)
  8014d5:	56                   	push   %esi
  8014d6:	50                   	push   %eax
  8014d7:	68 a0 23 80 00       	push   $0x8023a0
  8014dc:	e8 b3 00 00 00       	call   801594 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8014e1:	83 c4 18             	add    $0x18,%esp
  8014e4:	53                   	push   %ebx
  8014e5:	ff 75 10             	push   0x10(%ebp)
  8014e8:	e8 56 00 00 00       	call   801543 <vcprintf>
	cprintf("\n");
  8014ed:	c7 04 24 8c 23 80 00 	movl   $0x80238c,(%esp)
  8014f4:	e8 9b 00 00 00       	call   801594 <cprintf>
  8014f9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8014fc:	cc                   	int3   
  8014fd:	eb fd                	jmp    8014fc <_panic+0x43>

008014ff <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8014ff:	55                   	push   %ebp
  801500:	89 e5                	mov    %esp,%ebp
  801502:	53                   	push   %ebx
  801503:	83 ec 04             	sub    $0x4,%esp
  801506:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801509:	8b 13                	mov    (%ebx),%edx
  80150b:	8d 42 01             	lea    0x1(%edx),%eax
  80150e:	89 03                	mov    %eax,(%ebx)
  801510:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801513:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801517:	3d ff 00 00 00       	cmp    $0xff,%eax
  80151c:	74 09                	je     801527 <putch+0x28>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80151e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801522:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801525:	c9                   	leave  
  801526:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  801527:	83 ec 08             	sub    $0x8,%esp
  80152a:	68 ff 00 00 00       	push   $0xff
  80152f:	8d 43 08             	lea    0x8(%ebx),%eax
  801532:	50                   	push   %eax
  801533:	e8 65 eb ff ff       	call   80009d <sys_cputs>
		b->idx = 0;
  801538:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80153e:	83 c4 10             	add    $0x10,%esp
  801541:	eb db                	jmp    80151e <putch+0x1f>

00801543 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801543:	55                   	push   %ebp
  801544:	89 e5                	mov    %esp,%ebp
  801546:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80154c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801553:	00 00 00 
	b.cnt = 0;
  801556:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80155d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801560:	ff 75 0c             	push   0xc(%ebp)
  801563:	ff 75 08             	push   0x8(%ebp)
  801566:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80156c:	50                   	push   %eax
  80156d:	68 ff 14 80 00       	push   $0x8014ff
  801572:	e8 14 01 00 00       	call   80168b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801577:	83 c4 08             	add    $0x8,%esp
  80157a:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
  801580:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801586:	50                   	push   %eax
  801587:	e8 11 eb ff ff       	call   80009d <sys_cputs>

	return b.cnt;
}
  80158c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801592:	c9                   	leave  
  801593:	c3                   	ret    

00801594 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801594:	55                   	push   %ebp
  801595:	89 e5                	mov    %esp,%ebp
  801597:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80159a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80159d:	50                   	push   %eax
  80159e:	ff 75 08             	push   0x8(%ebp)
  8015a1:	e8 9d ff ff ff       	call   801543 <vcprintf>
	va_end(ap);

	return cnt;
}
  8015a6:	c9                   	leave  
  8015a7:	c3                   	ret    

008015a8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015a8:	55                   	push   %ebp
  8015a9:	89 e5                	mov    %esp,%ebp
  8015ab:	57                   	push   %edi
  8015ac:	56                   	push   %esi
  8015ad:	53                   	push   %ebx
  8015ae:	83 ec 1c             	sub    $0x1c,%esp
  8015b1:	89 c7                	mov    %eax,%edi
  8015b3:	89 d6                	mov    %edx,%esi
  8015b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015bb:	89 d1                	mov    %edx,%ecx
  8015bd:	89 c2                	mov    %eax,%edx
  8015bf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8015c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8015c8:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015ce:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8015d5:	39 c2                	cmp    %eax,%edx
  8015d7:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8015da:	72 3e                	jb     80161a <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8015dc:	83 ec 0c             	sub    $0xc,%esp
  8015df:	ff 75 18             	push   0x18(%ebp)
  8015e2:	83 eb 01             	sub    $0x1,%ebx
  8015e5:	53                   	push   %ebx
  8015e6:	50                   	push   %eax
  8015e7:	83 ec 08             	sub    $0x8,%esp
  8015ea:	ff 75 e4             	push   -0x1c(%ebp)
  8015ed:	ff 75 e0             	push   -0x20(%ebp)
  8015f0:	ff 75 dc             	push   -0x24(%ebp)
  8015f3:	ff 75 d8             	push   -0x28(%ebp)
  8015f6:	e8 f5 09 00 00       	call   801ff0 <__udivdi3>
  8015fb:	83 c4 18             	add    $0x18,%esp
  8015fe:	52                   	push   %edx
  8015ff:	50                   	push   %eax
  801600:	89 f2                	mov    %esi,%edx
  801602:	89 f8                	mov    %edi,%eax
  801604:	e8 9f ff ff ff       	call   8015a8 <printnum>
  801609:	83 c4 20             	add    $0x20,%esp
  80160c:	eb 13                	jmp    801621 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80160e:	83 ec 08             	sub    $0x8,%esp
  801611:	56                   	push   %esi
  801612:	ff 75 18             	push   0x18(%ebp)
  801615:	ff d7                	call   *%edi
  801617:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80161a:	83 eb 01             	sub    $0x1,%ebx
  80161d:	85 db                	test   %ebx,%ebx
  80161f:	7f ed                	jg     80160e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801621:	83 ec 08             	sub    $0x8,%esp
  801624:	56                   	push   %esi
  801625:	83 ec 04             	sub    $0x4,%esp
  801628:	ff 75 e4             	push   -0x1c(%ebp)
  80162b:	ff 75 e0             	push   -0x20(%ebp)
  80162e:	ff 75 dc             	push   -0x24(%ebp)
  801631:	ff 75 d8             	push   -0x28(%ebp)
  801634:	e8 d7 0a 00 00       	call   802110 <__umoddi3>
  801639:	83 c4 14             	add    $0x14,%esp
  80163c:	0f be 80 c3 23 80 00 	movsbl 0x8023c3(%eax),%eax
  801643:	50                   	push   %eax
  801644:	ff d7                	call   *%edi
}
  801646:	83 c4 10             	add    $0x10,%esp
  801649:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80164c:	5b                   	pop    %ebx
  80164d:	5e                   	pop    %esi
  80164e:	5f                   	pop    %edi
  80164f:	5d                   	pop    %ebp
  801650:	c3                   	ret    

00801651 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801651:	55                   	push   %ebp
  801652:	89 e5                	mov    %esp,%ebp
  801654:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801657:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80165b:	8b 10                	mov    (%eax),%edx
  80165d:	3b 50 04             	cmp    0x4(%eax),%edx
  801660:	73 0a                	jae    80166c <sprintputch+0x1b>
		*b->buf++ = ch;
  801662:	8d 4a 01             	lea    0x1(%edx),%ecx
  801665:	89 08                	mov    %ecx,(%eax)
  801667:	8b 45 08             	mov    0x8(%ebp),%eax
  80166a:	88 02                	mov    %al,(%edx)
}
  80166c:	5d                   	pop    %ebp
  80166d:	c3                   	ret    

0080166e <printfmt>:
{
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801674:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801677:	50                   	push   %eax
  801678:	ff 75 10             	push   0x10(%ebp)
  80167b:	ff 75 0c             	push   0xc(%ebp)
  80167e:	ff 75 08             	push   0x8(%ebp)
  801681:	e8 05 00 00 00       	call   80168b <vprintfmt>
}
  801686:	83 c4 10             	add    $0x10,%esp
  801689:	c9                   	leave  
  80168a:	c3                   	ret    

0080168b <vprintfmt>:
{
  80168b:	55                   	push   %ebp
  80168c:	89 e5                	mov    %esp,%ebp
  80168e:	57                   	push   %edi
  80168f:	56                   	push   %esi
  801690:	53                   	push   %ebx
  801691:	83 ec 3c             	sub    $0x3c,%esp
  801694:	8b 75 08             	mov    0x8(%ebp),%esi
  801697:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80169a:	8b 7d 10             	mov    0x10(%ebp),%edi
  80169d:	eb 0a                	jmp    8016a9 <vprintfmt+0x1e>
			putch(ch, putdat);
  80169f:	83 ec 08             	sub    $0x8,%esp
  8016a2:	53                   	push   %ebx
  8016a3:	50                   	push   %eax
  8016a4:	ff d6                	call   *%esi
  8016a6:	83 c4 10             	add    $0x10,%esp
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016a9:	83 c7 01             	add    $0x1,%edi
  8016ac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016b0:	83 f8 25             	cmp    $0x25,%eax
  8016b3:	74 0c                	je     8016c1 <vprintfmt+0x36>
			if (ch == '\0')
  8016b5:	85 c0                	test   %eax,%eax
  8016b7:	75 e6                	jne    80169f <vprintfmt+0x14>
}
  8016b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016bc:	5b                   	pop    %ebx
  8016bd:	5e                   	pop    %esi
  8016be:	5f                   	pop    %edi
  8016bf:	5d                   	pop    %ebp
  8016c0:	c3                   	ret    
		padc = ' ';
  8016c1:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8016c5:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8016cc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8016d3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8016da:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8016df:	8d 47 01             	lea    0x1(%edi),%eax
  8016e2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016e5:	0f b6 17             	movzbl (%edi),%edx
  8016e8:	8d 42 dd             	lea    -0x23(%edx),%eax
  8016eb:	3c 55                	cmp    $0x55,%al
  8016ed:	0f 87 bb 03 00 00    	ja     801aae <vprintfmt+0x423>
  8016f3:	0f b6 c0             	movzbl %al,%eax
  8016f6:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
  8016fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801700:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801704:	eb d9                	jmp    8016df <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801706:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801709:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80170d:	eb d0                	jmp    8016df <vprintfmt+0x54>
  80170f:	0f b6 d2             	movzbl %dl,%edx
  801712:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801715:	b8 00 00 00 00       	mov    $0x0,%eax
  80171a:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80171d:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801720:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801724:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801727:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80172a:	83 f9 09             	cmp    $0x9,%ecx
  80172d:	77 55                	ja     801784 <vprintfmt+0xf9>
			for (precision = 0; ; ++fmt) {
  80172f:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801732:	eb e9                	jmp    80171d <vprintfmt+0x92>
			precision = va_arg(ap, int);
  801734:	8b 45 14             	mov    0x14(%ebp),%eax
  801737:	8b 00                	mov    (%eax),%eax
  801739:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80173c:	8b 45 14             	mov    0x14(%ebp),%eax
  80173f:	8d 40 04             	lea    0x4(%eax),%eax
  801742:	89 45 14             	mov    %eax,0x14(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801745:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801748:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80174c:	79 91                	jns    8016df <vprintfmt+0x54>
				width = precision, precision = -1;
  80174e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801751:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801754:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80175b:	eb 82                	jmp    8016df <vprintfmt+0x54>
  80175d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801760:	85 d2                	test   %edx,%edx
  801762:	b8 00 00 00 00       	mov    $0x0,%eax
  801767:	0f 49 c2             	cmovns %edx,%eax
  80176a:	89 45 e0             	mov    %eax,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80176d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801770:	e9 6a ff ff ff       	jmp    8016df <vprintfmt+0x54>
		switch (ch = *(unsigned char *) fmt++) {
  801775:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801778:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80177f:	e9 5b ff ff ff       	jmp    8016df <vprintfmt+0x54>
  801784:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801787:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80178a:	eb bc                	jmp    801748 <vprintfmt+0xbd>
			lflag++;
  80178c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80178f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801792:	e9 48 ff ff ff       	jmp    8016df <vprintfmt+0x54>
			putch(va_arg(ap, int), putdat);
  801797:	8b 45 14             	mov    0x14(%ebp),%eax
  80179a:	8d 78 04             	lea    0x4(%eax),%edi
  80179d:	83 ec 08             	sub    $0x8,%esp
  8017a0:	53                   	push   %ebx
  8017a1:	ff 30                	push   (%eax)
  8017a3:	ff d6                	call   *%esi
			break;
  8017a5:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
  8017a8:	89 7d 14             	mov    %edi,0x14(%ebp)
			break;
  8017ab:	e9 9d 02 00 00       	jmp    801a4d <vprintfmt+0x3c2>
			err = va_arg(ap, int);
  8017b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8017b3:	8d 78 04             	lea    0x4(%eax),%edi
  8017b6:	8b 10                	mov    (%eax),%edx
  8017b8:	89 d0                	mov    %edx,%eax
  8017ba:	f7 d8                	neg    %eax
  8017bc:	0f 48 c2             	cmovs  %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017bf:	83 f8 0f             	cmp    $0xf,%eax
  8017c2:	7f 23                	jg     8017e7 <vprintfmt+0x15c>
  8017c4:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  8017cb:	85 d2                	test   %edx,%edx
  8017cd:	74 18                	je     8017e7 <vprintfmt+0x15c>
				printfmt(putch, putdat, "%s", p);
  8017cf:	52                   	push   %edx
  8017d0:	68 21 23 80 00       	push   $0x802321
  8017d5:	53                   	push   %ebx
  8017d6:	56                   	push   %esi
  8017d7:	e8 92 fe ff ff       	call   80166e <printfmt>
  8017dc:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8017df:	89 7d 14             	mov    %edi,0x14(%ebp)
  8017e2:	e9 66 02 00 00       	jmp    801a4d <vprintfmt+0x3c2>
				printfmt(putch, putdat, "error %d", err);
  8017e7:	50                   	push   %eax
  8017e8:	68 db 23 80 00       	push   $0x8023db
  8017ed:	53                   	push   %ebx
  8017ee:	56                   	push   %esi
  8017ef:	e8 7a fe ff ff       	call   80166e <printfmt>
  8017f4:	83 c4 10             	add    $0x10,%esp
			err = va_arg(ap, int);
  8017f7:	89 7d 14             	mov    %edi,0x14(%ebp)
				printfmt(putch, putdat, "error %d", err);
  8017fa:	e9 4e 02 00 00       	jmp    801a4d <vprintfmt+0x3c2>
			if ((p = va_arg(ap, char *)) == NULL)
  8017ff:	8b 45 14             	mov    0x14(%ebp),%eax
  801802:	83 c0 04             	add    $0x4,%eax
  801805:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801808:	8b 45 14             	mov    0x14(%ebp),%eax
  80180b:	8b 10                	mov    (%eax),%edx
				p = "(null)";
  80180d:	85 d2                	test   %edx,%edx
  80180f:	b8 d4 23 80 00       	mov    $0x8023d4,%eax
  801814:	0f 45 c2             	cmovne %edx,%eax
  801817:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80181a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80181e:	7e 06                	jle    801826 <vprintfmt+0x19b>
  801820:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801824:	75 0d                	jne    801833 <vprintfmt+0x1a8>
				for (width -= strnlen(p, precision); width > 0; width--)
  801826:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801829:	89 c7                	mov    %eax,%edi
  80182b:	03 45 e0             	add    -0x20(%ebp),%eax
  80182e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801831:	eb 55                	jmp    801888 <vprintfmt+0x1fd>
  801833:	83 ec 08             	sub    $0x8,%esp
  801836:	ff 75 d8             	push   -0x28(%ebp)
  801839:	ff 75 cc             	push   -0x34(%ebp)
  80183c:	e8 0a 03 00 00       	call   801b4b <strnlen>
  801841:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801844:	29 c1                	sub    %eax,%ecx
  801846:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  801849:	83 c4 10             	add    $0x10,%esp
  80184c:	89 cf                	mov    %ecx,%edi
					putch(padc, putdat);
  80184e:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801852:	89 45 e0             	mov    %eax,-0x20(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801855:	eb 0f                	jmp    801866 <vprintfmt+0x1db>
					putch(padc, putdat);
  801857:	83 ec 08             	sub    $0x8,%esp
  80185a:	53                   	push   %ebx
  80185b:	ff 75 e0             	push   -0x20(%ebp)
  80185e:	ff d6                	call   *%esi
				for (width -= strnlen(p, precision); width > 0; width--)
  801860:	83 ef 01             	sub    $0x1,%edi
  801863:	83 c4 10             	add    $0x10,%esp
  801866:	85 ff                	test   %edi,%edi
  801868:	7f ed                	jg     801857 <vprintfmt+0x1cc>
  80186a:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80186d:	85 d2                	test   %edx,%edx
  80186f:	b8 00 00 00 00       	mov    $0x0,%eax
  801874:	0f 49 c2             	cmovns %edx,%eax
  801877:	29 c2                	sub    %eax,%edx
  801879:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80187c:	eb a8                	jmp    801826 <vprintfmt+0x19b>
					putch(ch, putdat);
  80187e:	83 ec 08             	sub    $0x8,%esp
  801881:	53                   	push   %ebx
  801882:	52                   	push   %edx
  801883:	ff d6                	call   *%esi
  801885:	83 c4 10             	add    $0x10,%esp
  801888:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80188b:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80188d:	83 c7 01             	add    $0x1,%edi
  801890:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801894:	0f be d0             	movsbl %al,%edx
  801897:	85 d2                	test   %edx,%edx
  801899:	74 4b                	je     8018e6 <vprintfmt+0x25b>
  80189b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80189f:	78 06                	js     8018a7 <vprintfmt+0x21c>
  8018a1:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8018a5:	78 1e                	js     8018c5 <vprintfmt+0x23a>
				if (altflag && (ch < ' ' || ch > '~'))
  8018a7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8018ab:	74 d1                	je     80187e <vprintfmt+0x1f3>
  8018ad:	0f be c0             	movsbl %al,%eax
  8018b0:	83 e8 20             	sub    $0x20,%eax
  8018b3:	83 f8 5e             	cmp    $0x5e,%eax
  8018b6:	76 c6                	jbe    80187e <vprintfmt+0x1f3>
					putch('?', putdat);
  8018b8:	83 ec 08             	sub    $0x8,%esp
  8018bb:	53                   	push   %ebx
  8018bc:	6a 3f                	push   $0x3f
  8018be:	ff d6                	call   *%esi
  8018c0:	83 c4 10             	add    $0x10,%esp
  8018c3:	eb c3                	jmp    801888 <vprintfmt+0x1fd>
  8018c5:	89 cf                	mov    %ecx,%edi
  8018c7:	eb 0e                	jmp    8018d7 <vprintfmt+0x24c>
				putch(' ', putdat);
  8018c9:	83 ec 08             	sub    $0x8,%esp
  8018cc:	53                   	push   %ebx
  8018cd:	6a 20                	push   $0x20
  8018cf:	ff d6                	call   *%esi
			for (; width > 0; width--)
  8018d1:	83 ef 01             	sub    $0x1,%edi
  8018d4:	83 c4 10             	add    $0x10,%esp
  8018d7:	85 ff                	test   %edi,%edi
  8018d9:	7f ee                	jg     8018c9 <vprintfmt+0x23e>
			if ((p = va_arg(ap, char *)) == NULL)
  8018db:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8018de:	89 45 14             	mov    %eax,0x14(%ebp)
  8018e1:	e9 67 01 00 00       	jmp    801a4d <vprintfmt+0x3c2>
  8018e6:	89 cf                	mov    %ecx,%edi
  8018e8:	eb ed                	jmp    8018d7 <vprintfmt+0x24c>
	if (lflag >= 2)
  8018ea:	83 f9 01             	cmp    $0x1,%ecx
  8018ed:	7f 1b                	jg     80190a <vprintfmt+0x27f>
	else if (lflag)
  8018ef:	85 c9                	test   %ecx,%ecx
  8018f1:	74 63                	je     801956 <vprintfmt+0x2cb>
		return va_arg(*ap, long);
  8018f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8018f6:	8b 00                	mov    (%eax),%eax
  8018f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8018fb:	99                   	cltd   
  8018fc:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8018ff:	8b 45 14             	mov    0x14(%ebp),%eax
  801902:	8d 40 04             	lea    0x4(%eax),%eax
  801905:	89 45 14             	mov    %eax,0x14(%ebp)
  801908:	eb 17                	jmp    801921 <vprintfmt+0x296>
		return va_arg(*ap, long long);
  80190a:	8b 45 14             	mov    0x14(%ebp),%eax
  80190d:	8b 50 04             	mov    0x4(%eax),%edx
  801910:	8b 00                	mov    (%eax),%eax
  801912:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801915:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801918:	8b 45 14             	mov    0x14(%ebp),%eax
  80191b:	8d 40 08             	lea    0x8(%eax),%eax
  80191e:	89 45 14             	mov    %eax,0x14(%ebp)
			if ((long long) num < 0) {
  801921:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801924:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			base = 10;
  801927:	bf 0a 00 00 00       	mov    $0xa,%edi
			if ((long long) num < 0) {
  80192c:	85 c9                	test   %ecx,%ecx
  80192e:	0f 89 ff 00 00 00    	jns    801a33 <vprintfmt+0x3a8>
				putch('-', putdat);
  801934:	83 ec 08             	sub    $0x8,%esp
  801937:	53                   	push   %ebx
  801938:	6a 2d                	push   $0x2d
  80193a:	ff d6                	call   *%esi
				num = -(long long) num;
  80193c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80193f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801942:	f7 da                	neg    %edx
  801944:	83 d1 00             	adc    $0x0,%ecx
  801947:	f7 d9                	neg    %ecx
  801949:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80194c:	bf 0a 00 00 00       	mov    $0xa,%edi
  801951:	e9 dd 00 00 00       	jmp    801a33 <vprintfmt+0x3a8>
		return va_arg(*ap, int);
  801956:	8b 45 14             	mov    0x14(%ebp),%eax
  801959:	8b 00                	mov    (%eax),%eax
  80195b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80195e:	99                   	cltd   
  80195f:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801962:	8b 45 14             	mov    0x14(%ebp),%eax
  801965:	8d 40 04             	lea    0x4(%eax),%eax
  801968:	89 45 14             	mov    %eax,0x14(%ebp)
  80196b:	eb b4                	jmp    801921 <vprintfmt+0x296>
	if (lflag >= 2)
  80196d:	83 f9 01             	cmp    $0x1,%ecx
  801970:	7f 1e                	jg     801990 <vprintfmt+0x305>
	else if (lflag)
  801972:	85 c9                	test   %ecx,%ecx
  801974:	74 32                	je     8019a8 <vprintfmt+0x31d>
		return va_arg(*ap, unsigned long);
  801976:	8b 45 14             	mov    0x14(%ebp),%eax
  801979:	8b 10                	mov    (%eax),%edx
  80197b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801980:	8d 40 04             	lea    0x4(%eax),%eax
  801983:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  801986:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long);
  80198b:	e9 a3 00 00 00       	jmp    801a33 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801990:	8b 45 14             	mov    0x14(%ebp),%eax
  801993:	8b 10                	mov    (%eax),%edx
  801995:	8b 48 04             	mov    0x4(%eax),%ecx
  801998:	8d 40 08             	lea    0x8(%eax),%eax
  80199b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  80199e:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned long long);
  8019a3:	e9 8b 00 00 00       	jmp    801a33 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ab:	8b 10                	mov    (%eax),%edx
  8019ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019b2:	8d 40 04             	lea    0x4(%eax),%eax
  8019b5:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 10;
  8019b8:	bf 0a 00 00 00       	mov    $0xa,%edi
		return va_arg(*ap, unsigned int);
  8019bd:	eb 74                	jmp    801a33 <vprintfmt+0x3a8>
	if (lflag >= 2)
  8019bf:	83 f9 01             	cmp    $0x1,%ecx
  8019c2:	7f 1b                	jg     8019df <vprintfmt+0x354>
	else if (lflag)
  8019c4:	85 c9                	test   %ecx,%ecx
  8019c6:	74 2c                	je     8019f4 <vprintfmt+0x369>
		return va_arg(*ap, unsigned long);
  8019c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8019cb:	8b 10                	mov    (%eax),%edx
  8019cd:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019d2:	8d 40 04             	lea    0x4(%eax),%eax
  8019d5:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019d8:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long);
  8019dd:	eb 54                	jmp    801a33 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  8019df:	8b 45 14             	mov    0x14(%ebp),%eax
  8019e2:	8b 10                	mov    (%eax),%edx
  8019e4:	8b 48 04             	mov    0x4(%eax),%ecx
  8019e7:	8d 40 08             	lea    0x8(%eax),%eax
  8019ea:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  8019ed:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned long long);
  8019f2:	eb 3f                	jmp    801a33 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  8019f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8019f7:	8b 10                	mov    (%eax),%edx
  8019f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8019fe:	8d 40 04             	lea    0x4(%eax),%eax
  801a01:	89 45 14             	mov    %eax,0x14(%ebp)
			base=8;
  801a04:	bf 08 00 00 00       	mov    $0x8,%edi
		return va_arg(*ap, unsigned int);
  801a09:	eb 28                	jmp    801a33 <vprintfmt+0x3a8>
			putch('0', putdat);
  801a0b:	83 ec 08             	sub    $0x8,%esp
  801a0e:	53                   	push   %ebx
  801a0f:	6a 30                	push   $0x30
  801a11:	ff d6                	call   *%esi
			putch('x', putdat);
  801a13:	83 c4 08             	add    $0x8,%esp
  801a16:	53                   	push   %ebx
  801a17:	6a 78                	push   $0x78
  801a19:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a1b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a1e:	8b 10                	mov    (%eax),%edx
  801a20:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801a25:	83 c4 10             	add    $0x10,%esp
				(uintptr_t) va_arg(ap, void *);
  801a28:	8d 40 04             	lea    0x4(%eax),%eax
  801a2b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a2e:	bf 10 00 00 00       	mov    $0x10,%edi
			printnum(putch, putdat, num, base, width, padc);
  801a33:	83 ec 0c             	sub    $0xc,%esp
  801a36:	0f be 45 d3          	movsbl -0x2d(%ebp),%eax
  801a3a:	50                   	push   %eax
  801a3b:	ff 75 e0             	push   -0x20(%ebp)
  801a3e:	57                   	push   %edi
  801a3f:	51                   	push   %ecx
  801a40:	52                   	push   %edx
  801a41:	89 da                	mov    %ebx,%edx
  801a43:	89 f0                	mov    %esi,%eax
  801a45:	e8 5e fb ff ff       	call   8015a8 <printnum>
			break;
  801a4a:	83 c4 20             	add    $0x20,%esp
			err = va_arg(ap, int);
  801a4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801a50:	e9 54 fc ff ff       	jmp    8016a9 <vprintfmt+0x1e>
	if (lflag >= 2)
  801a55:	83 f9 01             	cmp    $0x1,%ecx
  801a58:	7f 1b                	jg     801a75 <vprintfmt+0x3ea>
	else if (lflag)
  801a5a:	85 c9                	test   %ecx,%ecx
  801a5c:	74 2c                	je     801a8a <vprintfmt+0x3ff>
		return va_arg(*ap, unsigned long);
  801a5e:	8b 45 14             	mov    0x14(%ebp),%eax
  801a61:	8b 10                	mov    (%eax),%edx
  801a63:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a68:	8d 40 04             	lea    0x4(%eax),%eax
  801a6b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a6e:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long);
  801a73:	eb be                	jmp    801a33 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned long long);
  801a75:	8b 45 14             	mov    0x14(%ebp),%eax
  801a78:	8b 10                	mov    (%eax),%edx
  801a7a:	8b 48 04             	mov    0x4(%eax),%ecx
  801a7d:	8d 40 08             	lea    0x8(%eax),%eax
  801a80:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a83:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned long long);
  801a88:	eb a9                	jmp    801a33 <vprintfmt+0x3a8>
		return va_arg(*ap, unsigned int);
  801a8a:	8b 45 14             	mov    0x14(%ebp),%eax
  801a8d:	8b 10                	mov    (%eax),%edx
  801a8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a94:	8d 40 04             	lea    0x4(%eax),%eax
  801a97:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a9a:	bf 10 00 00 00       	mov    $0x10,%edi
		return va_arg(*ap, unsigned int);
  801a9f:	eb 92                	jmp    801a33 <vprintfmt+0x3a8>
			putch(ch, putdat);
  801aa1:	83 ec 08             	sub    $0x8,%esp
  801aa4:	53                   	push   %ebx
  801aa5:	6a 25                	push   $0x25
  801aa7:	ff d6                	call   *%esi
			break;
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	eb 9f                	jmp    801a4d <vprintfmt+0x3c2>
			putch('%', putdat);
  801aae:	83 ec 08             	sub    $0x8,%esp
  801ab1:	53                   	push   %ebx
  801ab2:	6a 25                	push   $0x25
  801ab4:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	89 f8                	mov    %edi,%eax
  801abb:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  801abf:	74 05                	je     801ac6 <vprintfmt+0x43b>
  801ac1:	83 e8 01             	sub    $0x1,%eax
  801ac4:	eb f5                	jmp    801abb <vprintfmt+0x430>
  801ac6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ac9:	eb 82                	jmp    801a4d <vprintfmt+0x3c2>

00801acb <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801acb:	55                   	push   %ebp
  801acc:	89 e5                	mov    %esp,%ebp
  801ace:	83 ec 18             	sub    $0x18,%esp
  801ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801ad7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801ada:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801ade:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ae1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801ae8:	85 c0                	test   %eax,%eax
  801aea:	74 26                	je     801b12 <vsnprintf+0x47>
  801aec:	85 d2                	test   %edx,%edx
  801aee:	7e 22                	jle    801b12 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801af0:	ff 75 14             	push   0x14(%ebp)
  801af3:	ff 75 10             	push   0x10(%ebp)
  801af6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801af9:	50                   	push   %eax
  801afa:	68 51 16 80 00       	push   $0x801651
  801aff:	e8 87 fb ff ff       	call   80168b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b04:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b07:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0d:	83 c4 10             	add    $0x10,%esp
}
  801b10:	c9                   	leave  
  801b11:	c3                   	ret    
		return -E_INVAL;
  801b12:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b17:	eb f7                	jmp    801b10 <vsnprintf+0x45>

00801b19 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b1f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b22:	50                   	push   %eax
  801b23:	ff 75 10             	push   0x10(%ebp)
  801b26:	ff 75 0c             	push   0xc(%ebp)
  801b29:	ff 75 08             	push   0x8(%ebp)
  801b2c:	e8 9a ff ff ff       	call   801acb <vsnprintf>
	va_end(ap);

	return rc;
}
  801b31:	c9                   	leave  
  801b32:	c3                   	ret    

00801b33 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b39:	b8 00 00 00 00       	mov    $0x0,%eax
  801b3e:	eb 03                	jmp    801b43 <strlen+0x10>
		n++;
  801b40:	83 c0 01             	add    $0x1,%eax
	for (n = 0; *s != '\0'; s++)
  801b43:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b47:	75 f7                	jne    801b40 <strlen+0xd>
	return n;
}
  801b49:	5d                   	pop    %ebp
  801b4a:	c3                   	ret    

00801b4b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b51:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b54:	b8 00 00 00 00       	mov    $0x0,%eax
  801b59:	eb 03                	jmp    801b5e <strnlen+0x13>
		n++;
  801b5b:	83 c0 01             	add    $0x1,%eax
	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801b5e:	39 d0                	cmp    %edx,%eax
  801b60:	74 08                	je     801b6a <strnlen+0x1f>
  801b62:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801b66:	75 f3                	jne    801b5b <strnlen+0x10>
  801b68:	89 c2                	mov    %eax,%edx
	return n;
}
  801b6a:	89 d0                	mov    %edx,%eax
  801b6c:	5d                   	pop    %ebp
  801b6d:	c3                   	ret    

00801b6e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	53                   	push   %ebx
  801b72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b75:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801b78:	b8 00 00 00 00       	mov    $0x0,%eax
  801b7d:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  801b81:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  801b84:	83 c0 01             	add    $0x1,%eax
  801b87:	84 d2                	test   %dl,%dl
  801b89:	75 f2                	jne    801b7d <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  801b8b:	89 c8                	mov    %ecx,%eax
  801b8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b90:	c9                   	leave  
  801b91:	c3                   	ret    

00801b92 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	53                   	push   %ebx
  801b96:	83 ec 10             	sub    $0x10,%esp
  801b99:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801b9c:	53                   	push   %ebx
  801b9d:	e8 91 ff ff ff       	call   801b33 <strlen>
  801ba2:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801ba5:	ff 75 0c             	push   0xc(%ebp)
  801ba8:	01 d8                	add    %ebx,%eax
  801baa:	50                   	push   %eax
  801bab:	e8 be ff ff ff       	call   801b6e <strcpy>
	return dst;
}
  801bb0:	89 d8                	mov    %ebx,%eax
  801bb2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bb5:	c9                   	leave  
  801bb6:	c3                   	ret    

00801bb7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	56                   	push   %esi
  801bbb:	53                   	push   %ebx
  801bbc:	8b 75 08             	mov    0x8(%ebp),%esi
  801bbf:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bc2:	89 f3                	mov    %esi,%ebx
  801bc4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801bc7:	89 f0                	mov    %esi,%eax
  801bc9:	eb 0f                	jmp    801bda <strncpy+0x23>
		*dst++ = *src;
  801bcb:	83 c0 01             	add    $0x1,%eax
  801bce:	0f b6 0a             	movzbl (%edx),%ecx
  801bd1:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801bd4:	80 f9 01             	cmp    $0x1,%cl
  801bd7:	83 da ff             	sbb    $0xffffffff,%edx
	for (i = 0; i < size; i++) {
  801bda:	39 d8                	cmp    %ebx,%eax
  801bdc:	75 ed                	jne    801bcb <strncpy+0x14>
	}
	return ret;
}
  801bde:	89 f0                	mov    %esi,%eax
  801be0:	5b                   	pop    %ebx
  801be1:	5e                   	pop    %esi
  801be2:	5d                   	pop    %ebp
  801be3:	c3                   	ret    

00801be4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	56                   	push   %esi
  801be8:	53                   	push   %ebx
  801be9:	8b 75 08             	mov    0x8(%ebp),%esi
  801bec:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bef:	8b 55 10             	mov    0x10(%ebp),%edx
  801bf2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801bf4:	85 d2                	test   %edx,%edx
  801bf6:	74 21                	je     801c19 <strlcpy+0x35>
  801bf8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801bfc:	89 f2                	mov    %esi,%edx
  801bfe:	eb 09                	jmp    801c09 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c00:	83 c1 01             	add    $0x1,%ecx
  801c03:	83 c2 01             	add    $0x1,%edx
  801c06:	88 5a ff             	mov    %bl,-0x1(%edx)
		while (--size > 0 && *src != '\0')
  801c09:	39 c2                	cmp    %eax,%edx
  801c0b:	74 09                	je     801c16 <strlcpy+0x32>
  801c0d:	0f b6 19             	movzbl (%ecx),%ebx
  801c10:	84 db                	test   %bl,%bl
  801c12:	75 ec                	jne    801c00 <strlcpy+0x1c>
  801c14:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801c16:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c19:	29 f0                	sub    %esi,%eax
}
  801c1b:	5b                   	pop    %ebx
  801c1c:	5e                   	pop    %esi
  801c1d:	5d                   	pop    %ebp
  801c1e:	c3                   	ret    

00801c1f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c1f:	55                   	push   %ebp
  801c20:	89 e5                	mov    %esp,%ebp
  801c22:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c25:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c28:	eb 06                	jmp    801c30 <strcmp+0x11>
		p++, q++;
  801c2a:	83 c1 01             	add    $0x1,%ecx
  801c2d:	83 c2 01             	add    $0x1,%edx
	while (*p && *p == *q)
  801c30:	0f b6 01             	movzbl (%ecx),%eax
  801c33:	84 c0                	test   %al,%al
  801c35:	74 04                	je     801c3b <strcmp+0x1c>
  801c37:	3a 02                	cmp    (%edx),%al
  801c39:	74 ef                	je     801c2a <strcmp+0xb>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c3b:	0f b6 c0             	movzbl %al,%eax
  801c3e:	0f b6 12             	movzbl (%edx),%edx
  801c41:	29 d0                	sub    %edx,%eax
}
  801c43:	5d                   	pop    %ebp
  801c44:	c3                   	ret    

00801c45 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c45:	55                   	push   %ebp
  801c46:	89 e5                	mov    %esp,%ebp
  801c48:	53                   	push   %ebx
  801c49:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c4f:	89 c3                	mov    %eax,%ebx
  801c51:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801c54:	eb 06                	jmp    801c5c <strncmp+0x17>
		n--, p++, q++;
  801c56:	83 c0 01             	add    $0x1,%eax
  801c59:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801c5c:	39 d8                	cmp    %ebx,%eax
  801c5e:	74 18                	je     801c78 <strncmp+0x33>
  801c60:	0f b6 08             	movzbl (%eax),%ecx
  801c63:	84 c9                	test   %cl,%cl
  801c65:	74 04                	je     801c6b <strncmp+0x26>
  801c67:	3a 0a                	cmp    (%edx),%cl
  801c69:	74 eb                	je     801c56 <strncmp+0x11>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801c6b:	0f b6 00             	movzbl (%eax),%eax
  801c6e:	0f b6 12             	movzbl (%edx),%edx
  801c71:	29 d0                	sub    %edx,%eax
}
  801c73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c76:	c9                   	leave  
  801c77:	c3                   	ret    
		return 0;
  801c78:	b8 00 00 00 00       	mov    $0x0,%eax
  801c7d:	eb f4                	jmp    801c73 <strncmp+0x2e>

00801c7f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801c7f:	55                   	push   %ebp
  801c80:	89 e5                	mov    %esp,%ebp
  801c82:	8b 45 08             	mov    0x8(%ebp),%eax
  801c85:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801c89:	eb 03                	jmp    801c8e <strchr+0xf>
  801c8b:	83 c0 01             	add    $0x1,%eax
  801c8e:	0f b6 10             	movzbl (%eax),%edx
  801c91:	84 d2                	test   %dl,%dl
  801c93:	74 06                	je     801c9b <strchr+0x1c>
		if (*s == c)
  801c95:	38 ca                	cmp    %cl,%dl
  801c97:	75 f2                	jne    801c8b <strchr+0xc>
  801c99:	eb 05                	jmp    801ca0 <strchr+0x21>
			return (char *) s;
	return 0;
  801c9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ca0:	5d                   	pop    %ebp
  801ca1:	c3                   	ret    

00801ca2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cac:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801caf:	38 ca                	cmp    %cl,%dl
  801cb1:	74 09                	je     801cbc <strfind+0x1a>
  801cb3:	84 d2                	test   %dl,%dl
  801cb5:	74 05                	je     801cbc <strfind+0x1a>
	for (; *s; s++)
  801cb7:	83 c0 01             	add    $0x1,%eax
  801cba:	eb f0                	jmp    801cac <strfind+0xa>
			break;
	return (char *) s;
}
  801cbc:	5d                   	pop    %ebp
  801cbd:	c3                   	ret    

00801cbe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801cbe:	55                   	push   %ebp
  801cbf:	89 e5                	mov    %esp,%ebp
  801cc1:	57                   	push   %edi
  801cc2:	56                   	push   %esi
  801cc3:	53                   	push   %ebx
  801cc4:	8b 7d 08             	mov    0x8(%ebp),%edi
  801cc7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801cca:	85 c9                	test   %ecx,%ecx
  801ccc:	74 2f                	je     801cfd <memset+0x3f>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801cce:	89 f8                	mov    %edi,%eax
  801cd0:	09 c8                	or     %ecx,%eax
  801cd2:	a8 03                	test   $0x3,%al
  801cd4:	75 21                	jne    801cf7 <memset+0x39>
		c &= 0xFF;
  801cd6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801cda:	89 d0                	mov    %edx,%eax
  801cdc:	c1 e0 08             	shl    $0x8,%eax
  801cdf:	89 d3                	mov    %edx,%ebx
  801ce1:	c1 e3 18             	shl    $0x18,%ebx
  801ce4:	89 d6                	mov    %edx,%esi
  801ce6:	c1 e6 10             	shl    $0x10,%esi
  801ce9:	09 f3                	or     %esi,%ebx
  801ceb:	09 da                	or     %ebx,%edx
  801ced:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  801cef:	c1 e9 02             	shr    $0x2,%ecx
		asm volatile("cld; rep stosl\n"
  801cf2:	fc                   	cld    
  801cf3:	f3 ab                	rep stos %eax,%es:(%edi)
  801cf5:	eb 06                	jmp    801cfd <memset+0x3f>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801cf7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cfa:	fc                   	cld    
  801cfb:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801cfd:	89 f8                	mov    %edi,%eax
  801cff:	5b                   	pop    %ebx
  801d00:	5e                   	pop    %esi
  801d01:	5f                   	pop    %edi
  801d02:	5d                   	pop    %ebp
  801d03:	c3                   	ret    

00801d04 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d04:	55                   	push   %ebp
  801d05:	89 e5                	mov    %esp,%ebp
  801d07:	57                   	push   %edi
  801d08:	56                   	push   %esi
  801d09:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0c:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d12:	39 c6                	cmp    %eax,%esi
  801d14:	73 32                	jae    801d48 <memmove+0x44>
  801d16:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d19:	39 c2                	cmp    %eax,%edx
  801d1b:	76 2b                	jbe    801d48 <memmove+0x44>
		s += n;
		d += n;
  801d1d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d20:	89 d6                	mov    %edx,%esi
  801d22:	09 fe                	or     %edi,%esi
  801d24:	09 ce                	or     %ecx,%esi
  801d26:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d2c:	75 0e                	jne    801d3c <memmove+0x38>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801d2e:	83 ef 04             	sub    $0x4,%edi
  801d31:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d34:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801d37:	fd                   	std    
  801d38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d3a:	eb 09                	jmp    801d45 <memmove+0x41>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801d3c:	83 ef 01             	sub    $0x1,%edi
  801d3f:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801d42:	fd                   	std    
  801d43:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d45:	fc                   	cld    
  801d46:	eb 1a                	jmp    801d62 <memmove+0x5e>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d48:	89 f2                	mov    %esi,%edx
  801d4a:	09 c2                	or     %eax,%edx
  801d4c:	09 ca                	or     %ecx,%edx
  801d4e:	f6 c2 03             	test   $0x3,%dl
  801d51:	75 0a                	jne    801d5d <memmove+0x59>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  801d53:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  801d56:	89 c7                	mov    %eax,%edi
  801d58:	fc                   	cld    
  801d59:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d5b:	eb 05                	jmp    801d62 <memmove+0x5e>
		else
			asm volatile("cld; rep movsb\n"
  801d5d:	89 c7                	mov    %eax,%edi
  801d5f:	fc                   	cld    
  801d60:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801d62:	5e                   	pop    %esi
  801d63:	5f                   	pop    %edi
  801d64:	5d                   	pop    %ebp
  801d65:	c3                   	ret    

00801d66 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801d66:	55                   	push   %ebp
  801d67:	89 e5                	mov    %esp,%ebp
  801d69:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801d6c:	ff 75 10             	push   0x10(%ebp)
  801d6f:	ff 75 0c             	push   0xc(%ebp)
  801d72:	ff 75 08             	push   0x8(%ebp)
  801d75:	e8 8a ff ff ff       	call   801d04 <memmove>
}
  801d7a:	c9                   	leave  
  801d7b:	c3                   	ret    

00801d7c <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	56                   	push   %esi
  801d80:	53                   	push   %ebx
  801d81:	8b 45 08             	mov    0x8(%ebp),%eax
  801d84:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d87:	89 c6                	mov    %eax,%esi
  801d89:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801d8c:	eb 06                	jmp    801d94 <memcmp+0x18>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801d8e:	83 c0 01             	add    $0x1,%eax
  801d91:	83 c2 01             	add    $0x1,%edx
	while (n-- > 0) {
  801d94:	39 f0                	cmp    %esi,%eax
  801d96:	74 14                	je     801dac <memcmp+0x30>
		if (*s1 != *s2)
  801d98:	0f b6 08             	movzbl (%eax),%ecx
  801d9b:	0f b6 1a             	movzbl (%edx),%ebx
  801d9e:	38 d9                	cmp    %bl,%cl
  801da0:	74 ec                	je     801d8e <memcmp+0x12>
			return (int) *s1 - (int) *s2;
  801da2:	0f b6 c1             	movzbl %cl,%eax
  801da5:	0f b6 db             	movzbl %bl,%ebx
  801da8:	29 d8                	sub    %ebx,%eax
  801daa:	eb 05                	jmp    801db1 <memcmp+0x35>
	}

	return 0;
  801dac:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801db1:	5b                   	pop    %ebx
  801db2:	5e                   	pop    %esi
  801db3:	5d                   	pop    %ebp
  801db4:	c3                   	ret    

00801db5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801db5:	55                   	push   %ebp
  801db6:	89 e5                	mov    %esp,%ebp
  801db8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801dbe:	89 c2                	mov    %eax,%edx
  801dc0:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801dc3:	eb 03                	jmp    801dc8 <memfind+0x13>
  801dc5:	83 c0 01             	add    $0x1,%eax
  801dc8:	39 d0                	cmp    %edx,%eax
  801dca:	73 04                	jae    801dd0 <memfind+0x1b>
		if (*(const unsigned char *) s == (unsigned char) c)
  801dcc:	38 08                	cmp    %cl,(%eax)
  801dce:	75 f5                	jne    801dc5 <memfind+0x10>
			break;
	return (void *) s;
}
  801dd0:	5d                   	pop    %ebp
  801dd1:	c3                   	ret    

00801dd2 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
  801dd5:	57                   	push   %edi
  801dd6:	56                   	push   %esi
  801dd7:	53                   	push   %ebx
  801dd8:	8b 55 08             	mov    0x8(%ebp),%edx
  801ddb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801dde:	eb 03                	jmp    801de3 <strtol+0x11>
		s++;
  801de0:	83 c2 01             	add    $0x1,%edx
	while (*s == ' ' || *s == '\t')
  801de3:	0f b6 02             	movzbl (%edx),%eax
  801de6:	3c 20                	cmp    $0x20,%al
  801de8:	74 f6                	je     801de0 <strtol+0xe>
  801dea:	3c 09                	cmp    $0x9,%al
  801dec:	74 f2                	je     801de0 <strtol+0xe>

	// plus/minus sign
	if (*s == '+')
  801dee:	3c 2b                	cmp    $0x2b,%al
  801df0:	74 2a                	je     801e1c <strtol+0x4a>
	int neg = 0;
  801df2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801df7:	3c 2d                	cmp    $0x2d,%al
  801df9:	74 2b                	je     801e26 <strtol+0x54>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801dfb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e01:	75 0f                	jne    801e12 <strtol+0x40>
  801e03:	80 3a 30             	cmpb   $0x30,(%edx)
  801e06:	74 28                	je     801e30 <strtol+0x5e>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e08:	85 db                	test   %ebx,%ebx
  801e0a:	b8 0a 00 00 00       	mov    $0xa,%eax
  801e0f:	0f 44 d8             	cmove  %eax,%ebx
  801e12:	b9 00 00 00 00       	mov    $0x0,%ecx
  801e17:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801e1a:	eb 46                	jmp    801e62 <strtol+0x90>
		s++;
  801e1c:	83 c2 01             	add    $0x1,%edx
	int neg = 0;
  801e1f:	bf 00 00 00 00       	mov    $0x0,%edi
  801e24:	eb d5                	jmp    801dfb <strtol+0x29>
		s++, neg = 1;
  801e26:	83 c2 01             	add    $0x1,%edx
  801e29:	bf 01 00 00 00       	mov    $0x1,%edi
  801e2e:	eb cb                	jmp    801dfb <strtol+0x29>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e30:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  801e34:	74 0e                	je     801e44 <strtol+0x72>
	else if (base == 0 && s[0] == '0')
  801e36:	85 db                	test   %ebx,%ebx
  801e38:	75 d8                	jne    801e12 <strtol+0x40>
		s++, base = 8;
  801e3a:	83 c2 01             	add    $0x1,%edx
  801e3d:	bb 08 00 00 00       	mov    $0x8,%ebx
  801e42:	eb ce                	jmp    801e12 <strtol+0x40>
		s += 2, base = 16;
  801e44:	83 c2 02             	add    $0x2,%edx
  801e47:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e4c:	eb c4                	jmp    801e12 <strtol+0x40>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  801e4e:	0f be c0             	movsbl %al,%eax
  801e51:	83 e8 30             	sub    $0x30,%eax
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801e54:	3b 45 10             	cmp    0x10(%ebp),%eax
  801e57:	7d 3a                	jge    801e93 <strtol+0xc1>
			break;
		s++, val = (val * base) + dig;
  801e59:	83 c2 01             	add    $0x1,%edx
  801e5c:	0f af 4d 10          	imul   0x10(%ebp),%ecx
  801e60:	01 c1                	add    %eax,%ecx
		if (*s >= '0' && *s <= '9')
  801e62:	0f b6 02             	movzbl (%edx),%eax
  801e65:	8d 70 d0             	lea    -0x30(%eax),%esi
  801e68:	89 f3                	mov    %esi,%ebx
  801e6a:	80 fb 09             	cmp    $0x9,%bl
  801e6d:	76 df                	jbe    801e4e <strtol+0x7c>
		else if (*s >= 'a' && *s <= 'z')
  801e6f:	8d 70 9f             	lea    -0x61(%eax),%esi
  801e72:	89 f3                	mov    %esi,%ebx
  801e74:	80 fb 19             	cmp    $0x19,%bl
  801e77:	77 08                	ja     801e81 <strtol+0xaf>
			dig = *s - 'a' + 10;
  801e79:	0f be c0             	movsbl %al,%eax
  801e7c:	83 e8 57             	sub    $0x57,%eax
  801e7f:	eb d3                	jmp    801e54 <strtol+0x82>
		else if (*s >= 'A' && *s <= 'Z')
  801e81:	8d 70 bf             	lea    -0x41(%eax),%esi
  801e84:	89 f3                	mov    %esi,%ebx
  801e86:	80 fb 19             	cmp    $0x19,%bl
  801e89:	77 08                	ja     801e93 <strtol+0xc1>
			dig = *s - 'A' + 10;
  801e8b:	0f be c0             	movsbl %al,%eax
  801e8e:	83 e8 37             	sub    $0x37,%eax
  801e91:	eb c1                	jmp    801e54 <strtol+0x82>
		// we don't properly detect overflow!
	}

	if (endptr)
  801e93:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801e97:	74 05                	je     801e9e <strtol+0xcc>
		*endptr = (char *) s;
  801e99:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e9c:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801e9e:	89 c8                	mov    %ecx,%eax
  801ea0:	f7 d8                	neg    %eax
  801ea2:	85 ff                	test   %edi,%edi
  801ea4:	0f 45 c8             	cmovne %eax,%ecx
}
  801ea7:	89 c8                	mov    %ecx,%eax
  801ea9:	5b                   	pop    %ebx
  801eaa:	5e                   	pop    %esi
  801eab:	5f                   	pop    %edi
  801eac:	5d                   	pop    %ebp
  801ead:	c3                   	ret    

00801eae <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page. 也就是UTOP)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801eae:	55                   	push   %ebp
  801eaf:	89 e5                	mov    %esp,%ebp
  801eb1:	56                   	push   %esi
  801eb2:	53                   	push   %ebx
  801eb3:	8b 75 08             	mov    0x8(%ebp),%esi
  801eb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801eb9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_recv not implemented");
	if(!pg) pg=(void *) UTOP;
  801ebc:	85 c0                	test   %eax,%eax
  801ebe:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ec3:	0f 44 c2             	cmove  %edx,%eax
	int r=sys_ipc_recv(pg);
  801ec6:	83 ec 0c             	sub    $0xc,%esp
  801ec9:	50                   	push   %eax
  801eca:	e8 3a e4 ff ff       	call   800309 <sys_ipc_recv>
	
	//thisenv在lib/libmain.c中定义。 currenv在kern/env.h中定义。
	//这里注释要求用thisenv。
	//应该是因为用户环境下没有权限访问currenv，只能利用libmain()函数中定义的thisenv。
	if(from_env_store) *from_env_store = (r < 0? 0 : thisenv->env_ipc_from);
  801ecf:	83 c4 10             	add    $0x10,%esp
  801ed2:	85 f6                	test   %esi,%esi
  801ed4:	74 17                	je     801eed <ipc_recv+0x3f>
  801ed6:	ba 00 00 00 00       	mov    $0x0,%edx
  801edb:	85 c0                	test   %eax,%eax
  801edd:	78 0c                	js     801eeb <ipc_recv+0x3d>
  801edf:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801ee5:	8b 92 84 00 00 00    	mov    0x84(%edx),%edx
  801eeb:	89 16                	mov    %edx,(%esi)
	if(perm_store) *perm_store= (r<0? 0:thisenv->env_ipc_perm);
  801eed:	85 db                	test   %ebx,%ebx
  801eef:	74 17                	je     801f08 <ipc_recv+0x5a>
  801ef1:	ba 00 00 00 00       	mov    $0x0,%edx
  801ef6:	85 c0                	test   %eax,%eax
  801ef8:	78 0c                	js     801f06 <ipc_recv+0x58>
  801efa:	8b 15 00 40 80 00    	mov    0x804000,%edx
  801f00:	8b 92 88 00 00 00    	mov    0x88(%edx),%edx
  801f06:	89 13                	mov    %edx,(%ebx)
	
	if(r<0) return r;
  801f08:	85 c0                	test   %eax,%eax
  801f0a:	78 0b                	js     801f17 <ipc_recv+0x69>
	
	return thisenv->env_ipc_value;
  801f0c:	a1 00 40 80 00       	mov    0x804000,%eax
  801f11:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
}
  801f17:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f1a:	5b                   	pop    %ebx
  801f1b:	5e                   	pop    %esi
  801f1c:	5d                   	pop    %ebp
  801f1d:	c3                   	ret    

00801f1e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f1e:	55                   	push   %ebp
  801f1f:	89 e5                	mov    %esp,%ebp
  801f21:	57                   	push   %edi
  801f22:	56                   	push   %esi
  801f23:	53                   	push   %ebx
  801f24:	83 ec 0c             	sub    $0xc,%esp
  801f27:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f2a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	//panic("ipc_send not implemented");
	int r;
	if (!pg)  pg = (void *) UTOP;
  801f30:	85 db                	test   %ebx,%ebx
  801f32:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f37:	0f 44 d8             	cmove  %eax,%ebx
  801f3a:	eb 05                	jmp    801f41 <ipc_send+0x23>
	
	do{
		r=sys_ipc_try_send(to_env, val, pg, perm);
		//用户级程序不能直接调用 sched_yeild();
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f3c:	e8 f9 e1 ff ff       	call   80013a <sys_yield>
		r=sys_ipc_try_send(to_env, val, pg, perm);
  801f41:	ff 75 14             	push   0x14(%ebp)
  801f44:	53                   	push   %ebx
  801f45:	56                   	push   %esi
  801f46:	57                   	push   %edi
  801f47:	e8 9a e3 ff ff       	call   8002e6 <sys_ipc_try_send>
		if( r==-E_IPC_NOT_RECV ) sys_yield();
  801f4c:	83 c4 10             	add    $0x10,%esp
  801f4f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f52:	74 e8                	je     801f3c <ipc_send+0x1e>
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f54:	85 c0                	test   %eax,%eax
  801f56:	78 08                	js     801f60 <ipc_send+0x42>
	}while (r<0);

}
  801f58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f5b:	5b                   	pop    %ebx
  801f5c:	5e                   	pop    %esi
  801f5d:	5f                   	pop    %edi
  801f5e:	5d                   	pop    %ebp
  801f5f:	c3                   	ret    
		else if( r<0 && (r!=-E_IPC_NOT_RECV) ) panic("ipc_send failed: %e", r);
  801f60:	50                   	push   %eax
  801f61:	68 bf 26 80 00       	push   $0x8026bf
  801f66:	6a 3d                	push   $0x3d
  801f68:	68 d3 26 80 00       	push   $0x8026d3
  801f6d:	e8 47 f5 ff ff       	call   8014b9 <_panic>

00801f72 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f72:	55                   	push   %ebp
  801f73:	89 e5                	mov    %esp,%ebp
  801f75:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801f78:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801f7d:	69 d0 8c 00 00 00    	imul   $0x8c,%eax,%edx
  801f83:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801f89:	8b 52 60             	mov    0x60(%edx),%edx
  801f8c:	39 ca                	cmp    %ecx,%edx
  801f8e:	74 11                	je     801fa1 <ipc_find_env+0x2f>
	for (i = 0; i < NENV; i++)
  801f90:	83 c0 01             	add    $0x1,%eax
  801f93:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f98:	75 e3                	jne    801f7d <ipc_find_env+0xb>
			return envs[i].env_id;
	return 0;
  801f9a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f9f:	eb 0e                	jmp    801faf <ipc_find_env+0x3d>
			return envs[i].env_id;
  801fa1:	69 c0 8c 00 00 00    	imul   $0x8c,%eax,%eax
  801fa7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fac:	8b 40 58             	mov    0x58(%eax),%eax
}
  801faf:	5d                   	pop    %ebp
  801fb0:	c3                   	ret    

00801fb1 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fb1:	55                   	push   %ebp
  801fb2:	89 e5                	mov    %esp,%ebp
  801fb4:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801fb7:	89 c2                	mov    %eax,%edx
  801fb9:	c1 ea 16             	shr    $0x16,%edx
  801fbc:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801fc3:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801fc8:	f6 c1 01             	test   $0x1,%cl
  801fcb:	74 1c                	je     801fe9 <pageref+0x38>
	pte = uvpt[PGNUM(v)];
  801fcd:	c1 e8 0c             	shr    $0xc,%eax
  801fd0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801fd7:	a8 01                	test   $0x1,%al
  801fd9:	74 0e                	je     801fe9 <pageref+0x38>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801fdb:	c1 e8 0c             	shr    $0xc,%eax
  801fde:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801fe5:	ef 
  801fe6:	0f b7 d2             	movzwl %dx,%edx
}
  801fe9:	89 d0                	mov    %edx,%eax
  801feb:	5d                   	pop    %ebp
  801fec:	c3                   	ret    
  801fed:	66 90                	xchg   %ax,%ax
  801fef:	90                   	nop

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
